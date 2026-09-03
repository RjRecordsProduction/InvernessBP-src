local logic_mail = {
  nSelectMailId = 0,
  nJumpBackMailId = nil,
  receiveCoinMailLeftCount = 10,
  nSecurityMailSubTabIndex = nil,
  bOpenTestData = false,
  nJumpSystemMailCfgId = nil,
  friendPresentTypeList = nil,
  GM_PresentType = nil
}
local MailMacro = require("client.slua.logic.mail.mail_macro")
local CONST_REQ_FRIEND_PRESENT_INTERVAL = 3
local MailInfoList, BlackMailList, MessageSender, AttachDecomposeInfo, NeedRemoveMailList, EffectMailIndexList, NewMailList, OpenMailWithParamList, batchSpecialMailIdList, nextGroupAttachItemList, reqFriendPresentTypeTimeRecord
function logic_mail.HandleQueryMailRes(mailsList)
  if logic_mail.bOpenTestData then
    local Mail_Test_Data = RequireBlackList("blacklist.unit_testing.mail.Mail_Test_Data")
    if Mail_Test_Data then
      local TableUtil = require("common.table_util")
      mailsList = TableUtil.CopyTable(Mail_Test_Data)
    end
  end
  logic_mail.ClearMailCacheData()
  for index, mailInfo in pairs(mailsList) do
    if not mailInfo.my_id then
      log(bWriteLog and " [v_wllwu] logic_mail.HandleQueryMailRes not include my_id, index_id =  " .. tostring(index))
    end
    mailInfo.my_id = index
    logic_mail.UnifyOneMailData(mailInfo)
  end
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  redpoint_data.InitMailRedDotCount()
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_LIST)
  logic_mail.BatchReqDeleteDiscardMail()
  local logic_mail_frozen_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mail_frozen_tips)
  logic_mail_frozen_tips:OnGetMailList()
end
function logic_mail.UnifyOneMailData(mailInfo)
  if not mailInfo then
    return
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  if logic_mail_utils.IsBlackFriendMail(mailInfo) then
    if not BlackMailList then
      BlackMailList = {}
    end
    table.insert(BlackMailList, mailInfo.my_id)
    return
  end
  if logic_mail_utils.IsNeedRemoveMail(mailInfo) then
    if not NeedRemoveMailList then
      NeedRemoveMailList = {}
    end
    table.insert(NeedRemoveMailList, mailInfo.my_id)
    return
  end
  mailInfo = logic_mail_utils.AddExtraValue(mailInfo)
  if not MailInfoList then
    MailInfoList = {}
  end
  logic_mail_utils.IsInheritMail(mailInfo)
  MailInfoList[mailInfo.my_id] = mailInfo
  logic_mail.SyncAddMailIndexList(mailInfo)
end
function logic_mail.SyncAddMailIndexList(mailInfo)
  local mailType = mailInfo.opt.type
  local index = mailType
  if mailType == MailMacro.Enum_Mail_Type.System or mailType == MailMacro.Enum_Mail_Type.Friend then
    index = MailMacro.Enum_Mail_Type.System
  end
  if not EffectMailIndexList then
    EffectMailIndexList = {}
  end
  if not EffectMailIndexList[index] then
    EffectMailIndexList[index] = {}
  end
  local cacheMailList = EffectMailIndexList[index]
  local maxCount = 60
  if MailMacro.Enum_Mail_Tab_Config[mailType] then
    maxCount = MailMacro.Enum_Mail_Tab_Config[mailType].MaxCount
  end
  if maxCount <= #cacheMailList then
    logic_mail.DeleteMailWhenReachMaxCount(index)
  end
  table.insert(EffectMailIndexList[index], mailInfo.my_id)
end
function logic_mail.DeleteMailWhenReachMaxCount(index)
  if not MailInfoList or not next(MailInfoList) then
    EffectMailIndexList[index] = {}
    return
  end
  local readIndex = -1
  local notAttachIndex = -1
  local delIndex = -1
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local cacheMailList = EffectMailIndexList[index]
  for idx, id in ipairs(cacheMailList) do
    local mailInfo = MailInfoList[id]
    if mailInfo ~= nil then
      if logic_mail_utils.IsHaveRead(mailInfo) then
        readIndex = idx
        break
      elseif notAttachIndex < 0 and not logic_mail_utils.IsWithAttach(mailInfo) then
        notAttachIndex = idx
      end
    else
      delIndex = idx
      break
    end
  end
  if delIndex <= 0 then
    if 0 < readIndex then
      delIndex = readIndex
    elseif 0 < notAttachIndex then
      delIndex = notAttachIndex
    else
      delIndex = 1
    end
  end
  local delMailId = cacheMailList[delIndex]
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  redpoint_data.UpdateRedPointData(delMailId, false, true)
  if not (EffectMailIndexList and EffectMailIndexList[index]) or not EffectMailIndexList[index][delIndex] then
    log(bWriteLog and "[v_wllwu] logic_mail.DeleteMailWhenReachMaxCount cant remove, delIndex is " .. tostring(delIndex))
    return
  end
  table.remove(EffectMailIndexList[index], delIndex)
end
function logic_mail.BatchReqDeleteDiscardMail()
  local reqList = {}
  if BlackMailList and 0 < #BlackMailList then
    for _, mailId in pairs(BlackMailList) do
      table.insert(reqList, mailId)
    end
    BlackMailList = nil
  end
  if NeedRemoveMailList and next(NeedRemoveMailList) then
    for _, mailId in pairs(NeedRemoveMailList) do
      table.insert(reqList, mailId)
    end
    NeedRemoveMailList = nil
  end
  if #reqList <= 0 then
    return
  end
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.req_delete_mail_list(reqList)
end
local _AddAttachAward = function(items, itemList)
  for _, addItem in ipairs(itemList) do
    if addItem.res_id > 0 and 0 < addItem.count then
      local found = false
      for _, award in ipairs(items) do
        if award.res_id == addItem.res_id and award.valid_hours == addItem.valid_hours and award.expire_ts == addItem.expire_ts then
          award.count = award.count + addItem.count
          found = true
          break
        end
      end
      if not found then
        table.insert(items, addItem)
      end
    end
  end
end
local AddMailAttachAward = function(mailInfo, items)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  if not logic_mail_utils.IsWithAttach(mailInfo) then
    return items
  end
  for _, attachV in pairs(mailInfo.attachList) do
    if attachV.attachId > 0 and 0 < attachV.attachCount then
      local found = false
      for _, award in ipairs(items) do
        if award.res_id == attachV.attachId then
          award.count = award.count + attachV.attachCount
          found = true
          break
        end
      end
      if not found then
        table.insert(items, {
          res_id = attachV.attachId,
          count = attachV.attachCount
        })
      end
    end
  end
  return items
end
function logic_mail.HandleFetchFriendMailRes(list)
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local mailList = {}
  local items = {}
  local resList = {}
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  for _, v in pairs(list) do
    if v.res == NetErrorCode_NONE then
      local mailInfo = MailInfoList and MailInfoList[v.id]
      if mailInfo then
        table.insert(mailList, v.id)
        if v.item_list then
          _AddAttachAward(items, v.item_list)
        else
          items = AddMailAttachAward(mailInfo, items)
        end
        logic_mail.UpdateMailStateAfterRead(v.id, true)
      end
      if logic_mail_utils.IsCanPresentCoin(mailInfo) then
        local mailSenderUid = mailInfo.opt.sender_uid
        local msg = {
          op = logic_mail._GetFriendPresentFromType(list)
        }
        local FriendGiftHandler = require("client.network.Protocol.FriendGiftHandler")
        FriendGiftHandler.send_present_friend_gold_req(tonumber(mailSenderUid), msg)
      end
      logic_return_activity:OldFriendGiftMailReceive(mailInfo)
    elseif not resList[v.res] then
      resList[v.res] = true
    end
  end
  if 0 < #mailList then
    logic_mail._ShowFriendAttachList(items)
  else
    logic_mail._ShowErrorCodeTips(resList)
  end
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.get_friend_misc_info_req()
end
function logic_mail._ShowErrorCodeTips(resList)
  if not resList or not next(resList) then
    return
  end
  for res, _ in pairs(resList) do
    if res == "full" then
      ShowNotice(102010)
    elseif res == "limit" then
      ShowNotice(102029)
    elseif res == "owed-limit" then
      ShowNotice(24226)
    elseif res == "back_user_notify_frd_limit" then
      ShowNotice(48457)
    else
      ShowNotice(102030)
    end
  end
end
function logic_mail._ShowFriendAttachList(itemList)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList, true)
  log(bWriteLog and "[v_wllwu] logic_mail.HandleFetchFriendMailRes update mailList ")
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_LIST)
end
function logic_mail._GetFriendPresentFromType(list)
  local batchMailCount = 0
  for _, v in pairs(list) do
    if v.res == NetErrorCode_NONE then
      batchMailCount = batchMailCount + 1
      if 1 < batchMailCount then
        return MailMacro.Enum_FriendPresentFromType.MailBatchRebate
      end
    end
  end
  return MailMacro.Enum_FriendPresentFromType.MailRebate
end
function logic_mail.HandleDeleteMailListRes()
  log(bWriteLog and "[v_wllwu] logic_mail.HandleDeleteMailListRes ")
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  logic_mail_proto.query_mail_summary_req(MailMacro.Enum_Request_MailList_Source.DeleteMail)
end
function logic_mail.HandleGetFriendMiscInfoRes(result)
  if result.frdUid then
    logic_mail.friendPresentTypeList = logic_mail.friendPresentTypeList or {}
    if logic_mail.GM_PresentType ~= nil then
      logic_mail.friendPresentTypeList[result.frdUid] = {
        present_type = logic_mail.GM_PresentType,
        contDays = 2
      }
    else
      logic_mail.friendPresentTypeList[result.frdUid] = result
    end
  end
  if result.recvLeftGoldCnt == logic_mail.receiveCoinMailLeftCount then
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_PRESENT_COIN_COUNT)
    return
  end
  logic_mail.receiveCoinMailLeftCount = result.recvLeftGoldCnt
  log(bWriteLog and "[v_wllwu] logic_mail.receiveCoinMailLeftCount is\239\188\154" .. tostring(logic_mail.receiveCoinMailLeftCount))
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  redpoint_data.InitMailRedDotCount()
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_PRESENT_COIN_COUNT)
end
function logic_mail.GetFriendPresentType(uid)
  if logic_mail.friendPresentTypeList and logic_mail.friendPresentTypeList[uid] then
    return logic_mail.friendPresentTypeList[uid].present_type
  end
  return MailMacro.Enum_FriendPresent_Type.old
end
function logic_mail.ReqGetFriendPresentType(uid)
  reqFriendPresentTypeTimeRecord = reqFriendPresentTypeTimeRecord or {}
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  reqFriendPresentTypeTimeRecord[uid] = currentTime
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.get_friend_misc_info_req(uid)
end
function logic_mail.IsNeedRequestPresentType(uid)
  if not logic_mail.friendPresentTypeList or not logic_mail.friendPresentTypeList[uid] then
    return true
  end
  if not reqFriendPresentTypeTimeRecord or not reqFriendPresentTypeTimeRecord[uid] then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local lastReqTime = reqFriendPresentTypeTimeRecord[uid]
  if currentTime - lastReqTime >= CONST_REQ_FRIEND_PRESENT_INTERVAL then
    return true
  end
  return false
end
function logic_mail.HandleFetchAttachRes(errCode, mailId, decomposeInfo, item_list)
  if errCode == 0 then
    logic_mail.OnFetchMailAttach(mailId, item_list)
  elseif errCode == 100170010 then
    logic_mail.OnHandleGoldSuitDecompose(mailId, decomposeInfo)
  else
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ERROR, mailId)
    if not errCode or type(errCode) ~= "number" then
      return
    end
    if errCode == 420001 then
      ShowNotice(420001)
      return
    elseif errCode == 100600018 then
      ShowNotice(48457)
      return
    end
    local strTips = LocUtil.GetLocalizeResStr(errCode)
    if strTips and strTips ~= "" then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), strTips)
    end
  end
end
local _UpdateMailReadStateAfterGet = function(mailId)
  local mailData = MailInfoList and MailInfoList[mailId]
  if not mailData then
    return
  end
  mailData.read = true
  if mailData.attachments then
    mailData.attachments.fetched = true
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  mailData.sortIndex = logic_mail_utils.GetMailSortIndex(mailData)
end
function logic_mail.OnFetchMailAttach(mailId, item_list)
  _UpdateMailReadStateAfterGet(mailId)
  logic_mail.ReadOneMail(mailId)
  local decomposeInfo = AttachDecomposeInfo
  if decomposeInfo then
    AttachDecomposeInfo = nil
  end
  logic_mail.ShowRecvAttach(mailId, decomposeInfo, item_list)
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_RECVITEM, mailId)
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local mailInfo = logic_mail.GetMailInfoById(mailId)
  logic_return_activity:OldFriendGiftMailReceive(mailInfo)
end
function logic_mail.ShowRecvAttach(mailId, decomposeInfo, item_list)
  if not MailInfoList or not MailInfoList[mailId] then
    return
  end
  local mailInfo = MailInfoList[mailId]
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local isSpecialMail = false
  if mailInfo.opt and mailInfo.opt.type == 1 and (mailInfo.opt.subtype == 10833 or mailInfo.opt.subtype == 10834) then
    isSpecialMail = true
  end
  local items = {}
  if mailInfo.attachList then
    for _, v in ipairs(mailInfo.attachList) do
      local attachValidTime = v.attachValidTime
      if isSpecialMail and (attachValidTime == 10368000 or attachValidTime == attachValidTime) then
        attachValidTime = attachValidTime / 3600
      end
      local itemData = {
        res_id = v.attachId,
        count = v.attachCount,
        valid_hours = attachValidTime,
        color_id = v.attachColor,
        pattern_id = v.attachPattern
      }
      itemData.extra = logic_mail_utils.GetMailExtraData(v, mailInfo.opt)
      log(bWriteLog and "[v_wllwu]logic_mail.ShowRecvAttach, expire_ts is:" .. tostring(v.expire_ts))
      table.insert(items, itemData)
    end
  end
  if #items <= 0 then
    return
  end
  if mailInfo.opt.type ~= MailMacro.Enum_Mail_Type.Friend and mailInfo.opt.cfg_id ~= 10813 then
    log_tree(bWriteLog and "[v_wllwu] logic_mail.ShowRecvAttach, items is:", items)
    logic_mail.ShowOtherTypeGetItemInfo(items, decomposeInfo)
  else
    if item_list and 0 < #item_list then
      items = item_list
    end
    logic_mail.ShowFriendTypeGetItemInfo(mailInfo, items)
  end
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_RECV_NEW_ITEM, items)
end
local NotifyMailReceiveAllNext = function()
  logic_mail.FetchSpecialAward()
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_RECEIVEALL_NEXT)
end
function logic_mail.ShowOtherTypeGetItemInfo(items, decomposeInfo)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if decomposeInfo then
    local list = {}
    for _, info in ipairs(decomposeInfo) do
      table.insert(list, {
        res_id = info.itemid,
        count = info.count
      })
    end
    local tExtendData = {
      fCloseCallback = logic_mail.FetchSpecialAward
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle(list, false, true, tExtendData)
    return
  end
  local tTempExData = {fCloseCallback = NotifyMailReceiveAllNext}
  Logic_CommonItemGet.ShowPanel_DefaultStyle(items, false, true, tTempExData)
end
function logic_mail.ShowFriendTypeGetItemInfo(mailInfo, items)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  if not logic_mail_utils.IsCanPresentCoin(mailInfo) then
    Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  else
    local senderUid = mailInfo.opt.sender_uid
    local msg = {
      op = MailMacro.Enum_FriendPresentFromType.MailRebate
    }
    local FriendGiftHandler = require("client.network.Protocol.FriendGiftHandler")
    FriendGiftHandler.send_present_friend_gold_req(tonumber(senderUid), msg)
    logic_mail_proto.get_friend_misc_info_req()
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsPlatFriend(senderUid) then
      Logic_CommonItemGet.ShowPanel_DefaultStyle(items, true)
    else
      Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
    end
  end
end
local GetHaveItemId = function(decomposeInfo)
  if not decomposeInfo or not next(decomposeInfo) then
    return
  end
  local firstId, realItems = nil, {}
  for _, info in ipairs(decomposeInfo) do
    if info.original_item_id then
      firstId = firstId or info.original_item_id
      table.insert(realItems, info)
    end
  end
  return firstId, realItems
end
function logic_mail.OnHandleGoldSuitDecompose(mailId, decomposeInfo)
  log_tree(bWriteLog and "[v_wllwu] logic_mail.OnHandleGoldSuitDecompose decomposeInfo = ", decomposeInfo)
  local havaItemId, itemList = GetHaveItemId(decomposeInfo)
  if not (havaItemId and decomposeInfo) or not next(decomposeInfo) then
    log(bWriteLog and " state ==  100170010 , \233\135\145\232\163\133\229\136\134\232\167\163\239\188\140\233\130\174\228\187\182\229\155\158\229\140\133\229\188\130\229\184\184 ")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", havaItemId)
  AttachDecomposeInfo = decomposeInfo
  local title = LocUtil.GetLocalizeResStr(5077)
  local tip
  if 1 < #itemList then
    for index, info in ipairs(itemList) do
      local temp = tip or ""
      if index == 1 then
        temp = LocUtil.LocalizeResFormat(3000105, itemCfg.ItemName)
      end
      local config = CDataTable.GetTableData("Item", info.original_item_id)
      local decomposeItemCfg = CDataTable.GetTableData("Item", info.itemid)
      local temp1 = string.format("%s%s%s", temp, "\n", config.ItemName)
      tip = LocUtil.LocalizeResFormat(3000106, temp1, decomposeItemCfg.ItemName, info.count)
    end
  else
    local info = itemList[1]
    local decomposeItemCfg = CDataTable.GetTableData("Item", info.itemid)
    tip = LocUtil.LocalizeResFormat(11084, itemCfg.ItemName, decomposeItemCfg.ItemName, info.count)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, function()
    local MailHandler = require("client.network.Protocol.MailHandler")
    MailHandler.send_on_fetch_mail_attach(mailId, 1)
  end)
end
function logic_mail.HandleNewMailNotify(mailType, subType, senderUid, mailInfo, indexId)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  if logic_mail_utils.IsPresentedCoin(mailInfo) then
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    if logic_friend_blacklist:IsBlacklist(senderUid) == false and logic_mail.receiveCoinMailLeftCount > 0 then
      logic_mail.AddNewMail(mailInfo, indexId)
    end
  else
    logic_mail.AddNewMail(mailInfo, indexId)
  end
end
function logic_mail.AddNewMail(mailInfo, indexId)
  if not mailInfo or not indexId then
    return
  end
  mailInfo.my_id = indexId
  log(bWriteLog and " [v_wllwu] logic_mail.AddNewMail index_id =  " .. tostring(indexId))
  if not UIManager.IsUIShow(UIManager.UI_Config.Mail_UIBP) then
    logic_mail.UnifyOneMailData(mailInfo)
    if MailInfoList and MailInfoList[indexId] then
      local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
      redpoint_data.UpdateRedPointData(indexId, true)
      EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ON_RECV_NEW_MAIL, mailInfo)
    end
  else
    if not NewMailList then
      NewMailList = {}
    end
    table.insert(NewMailList, mailInfo)
  end
  local logic_xmission_mail_notify = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_mail_notify)
  logic_xmission_mail_notify:OnAddNewMail(mailInfo)
  local logic_mail_frozen_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mail_frozen_tips)
  logic_mail_frozen_tips:OnAddNewMail(mailInfo)
end
function logic_mail.HandleBatchAttachRes(result_reward_id_list)
  local TableUtil = require("common.table_util")
  local needSetMailReadIdList = {}
  batchSpecialMailIdList = {}
  nextGroupAttachItemList = {}
  local listCount = 0
  local resList
  for _, v in ipairs(result_reward_id_list) do
    if v.res == NetErrorCode_NONE and v.award_list and 0 < #v.award_list then
      listCount = listCount + 1
      _UpdateMailReadStateAfterGet(v.id)
      table.insert(needSetMailReadIdList, v.id)
      if listCount == 1 then
        logic_mail.ShowCommonGetUI(v.award_list)
      else
        table.insert(nextGroupAttachItemList, v.award_list)
      end
    elseif v.res == "special" then
      if TableUtil.Find(batchSpecialMailIdList, v.id) == -1 then
        log(bWriteLog and "[v_wllwu] logic_mail.HandleBatchAttachRes, get special mail id is:" .. tostring(v.id))
        table.insert(batchSpecialMailIdList, v.id)
      end
    else
      resList = resList or {}
      if not resList[v.res] then
        resList[v.res] = true
      end
    end
  end
  log_tree(bWriteLog and "[v_wllwu] logic_mail.HandleBatchAttachRes, nextGroupAttachItemList is:", nextGroupAttachItemList)
  if 0 < #needSetMailReadIdList then
    logic_mail.ReadMailList(needSetMailReadIdList)
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_LIST)
  else
    logic_mail.FetchSpecialAward()
    logic_mail._ShowErrorCodeTips(resList)
  end
end
function logic_mail.ShowCommonGetUI(itemList, enterAnimType)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData = {
    fCloseCallback = logic_mail.ShowNextGroupMailAttach,
    nEnterAnimType = enterAnimType
  }
  Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList, true, true, tExtendData)
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_RECV_NEW_ITEM, itemList)
end
function logic_mail.ShowNextGroupMailAttach()
  log(bWriteLog and "[v_wllwu] logic_mail.ShowNextGroupMailAttach")
  if nextGroupAttachItemList and 0 < #nextGroupAttachItemList then
    local itemList = table.remove(nextGroupAttachItemList, 1)
    local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
    logic_mail.ShowCommonGetUI(itemList, CommonItemGet_Const.Enum_EnterAnimType.Quick)
    return
  end
  log(bWriteLog and "[v_wllwu] logic_mail.ShowNextGroupMailAttach judge special award")
  logic_mail.FetchSpecialAward()
end
function logic_mail.HandleSaveNewMailInfo()
  if not NewMailList or #NewMailList <= 0 then
    return
  end
  local hasNew = false
  for _, v in ipairs(NewMailList) do
    if v and v.my_id then
      logic_mail.UnifyOneMailData(v)
      local mailId = v.my_id
      if MailInfoList and MailInfoList[mailId] then
        local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
        redpoint_data.UpdateRedPointData(mailId, true)
        hasNew = true
      end
    end
  end
  NewMailList = nil
  if hasNew then
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ON_RECV_NEW_MAIL)
  end
end
local GetUidList = function(msgList)
  local idList = {}
  local noProfileIdList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(msgList) do
    if v.opt then
      local uid = v.opt.uid or v.opt.uid_sender or v.opt.member_uid
      table.insert(idList, uid)
      local profile = logic_profile:GetLocalProfile(uid)
      if not profile then
        table.insert(noProfileIdList, uid)
      end
    end
  end
  return idList, noProfileIdList
end
function logic_mail.ReqMessageSenderStatus(msgList)
  if not msgList or #msgList <= 0 then
    return
  end
  local idList, noProfileIdList = GetUidList(msgList)
  if #idList <= 0 then
    return
  elseif #noProfileIdList <= 0 then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.Mail, idList, logic_mail.GetMessageSenderOnlineData)
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(noProfileIdList, function()
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.Mail, idList, logic_mail.GetMessageSenderOnlineData)
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_GET_PLAYER_PROFILE)
  end, Enum_PROFILE_REPORT_CFG.MAIL, 0)
end
function logic_mail.GetMessageSenderOnlineData(info)
  local TimeUtil = require("client.common.time_util")
  for gid, v in pairs(info) do
    local profile = {}
    profile.online = v.online
    profile.land_id = v.land_id or 0
    profile.game_id = v.game_id or 0
    profile.teamState = v.teamStateNew
    profile.socialland_type = v.socialland_type or 0
    profile.tplan_type = v.tplan_type or 0
    profile.cwow_type = v.cwow_type or 0
    profile.enable_watch = v.enable_watch
    profile.maxTeamAmount = v.maxTeamAmount
    profile.currentTeamAmount = v.currentTeamAmount
    profile.timeSinceGameBegin = v.timeSinceGameBegin
    profile.timeSinceGameBeginStr = TimeUtil.GetOpenedTimeStr(v.timeSinceGameBegin)
    profile.timeSinceGameBeginStamp = TimeUtil.GetServerTimeInSec() - v.timeSinceGameBegin
    if not MessageSender then
      MessageSender = {}
    end
    MessageSender[tostring(gid)] = profile
  end
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_MESSAGE_PLAYERSTATE)
end
function logic_mail.GetPlayerState(uid)
  if MessageSender then
    return MessageSender[tostring(uid)]
  end
  return nil
end
function logic_mail.GetTabList()
  local tabList = {}
  for tabId, info in pairs(MailMacro.Enum_Mail_Tab_Config) do
    if info.CheckShowFunc == nil or info.CheckShowFunc() then
      info.      info.text = LocUtil.GetLocalizeResStr(info.NameId)
      table.insert(tabList, info)
    end
  end
  return tabList
end
function logic_mail.GetGiftSubTabList()
  local tabList = {}
  for i, info in pairs(MailMacro.Enum_Gift_SubTab_Config) do
    info.bSelected = false
    table.insert(tabList, info)
  end
  table.sort(tabList, function(a, b)
    return a.SubIndex < b.SubIndex
  end)
  return tabList
end
function logic_mail.GetSecuritySubTabList()
  local tabList = {}
  for tabType, info in pairs(MailMacro.Enum_Security_SubTab_Config) do
    info.bSelected = false
    info.    table.insert(tabList, info)
  end
  table.sort(tabList, function(a, b)
    return a.SubIndex < b.SubIndex
  end)
  log_tree(bWriteLog and "[v_wllwu]logic_mail.GetSecuritySubTabList tabList = ", tabList)
  return tabList
end
function logic_mail.ReqAllMailInfo(dontReqMailList)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  local AskForHandler = require("client.network.Protocol.AskForHandler")
  logic_mail_proto.get_friend_misc_info_req()
  if not dontReqMailList then
    local MailMacro = require("client.slua.logic.mail.mail_macro")
    logic_mail_proto.query_mail_summary_req(MailMacro.Enum_Request_MailList_Source.OpenMail)
    AskForHandler.send_cadge_info_req()
  end
  AskForHandler.send_cadge_list_req()
end
function logic_mail.ReadOneMail(mailId)
  log(bWriteLog and "\227\128\144v_wllwu] logic_mail.set_mail_readflag, id:" .. mailId)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.send_on_set_mail_readflag(mailId)
  logic_mail.UpdateMailStateAfterRead(mailId)
end
function logic_mail.UpdateMailStateAfterRead(mailId, isFetchAttach)
  local mailData = MailInfoList and MailInfoList[mailId]
  if mailData then
    mailData.read = true
    if isFetchAttach and mailData.attachments then
      log(bWriteLog and "[v_wllwu] logic_mail.UpdateMailStateAfterRead, isFetchAttach,  mailId: " .. tostring(mailId))
      mailData.attachments.fetched = true
    end
    local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
    mailData.sortIndex = logic_mail_utils.GetMailSortIndex(mailData)
  end
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  redpoint_data.UpdateRedPointData(mailId)
end
function logic_mail.ReadMailList(mailIdList)
  log_tree(bWriteLog and "[v_wllwu] logic_mail.ReadMailList mailIdList is ", mailIdList)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.send_on_read_mail_list(mailIdList)
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  for _, mailId in ipairs(mailIdList) do
    redpoint_data.UpdateRedPointData(mailId)
  end
end
function logic_mail.SortMailList(mailList)
  if mailList and 1 < #mailList then
    table.sort(mailList, function(a1, a2)
      return a1.sortIndex > a2.sortIndex
    end)
  end
end
function logic_mail.SortFriendMail(mailList)
  if not mailList or #mailList <= 1 then
    return mailList
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  table.sort(mailList, function(a, b)
    local aPriority = logic_mail_utils.GetMailSortPriority(a)
    local bPriority = logic_mail_utils.GetMailSortPriority(b)
    if aPriority ~= bPriority then
      return aPriority > bPriority
    end
    local aRelationIndex = LogicFriend.GetRelation(a.opt.sender_uid)
    local bRelationIndex = LogicFriend.GetRelation(b.opt.sender_uid)
    if aRelationIndex ~= bRelationIndex then
      return aRelationIndex > bRelationIndex
    end
    return a.time > b.time
  end)
end
function logic_mail.GetMsgListByMailType(mailType)
  if not MailInfoList or not next(MailInfoList) then
    log(bWriteLog and "[v_wllwu] logic_mail.GetMsgListByMailType MailInfoList is nil ")
    return
  end
  local mailList = {}
  for _, v in pairs(MailInfoList) do
    if v.opt.type == mailType then
      v.IsDefaultSelect = false
      table.insert(mailList, v)
    end
  end
  if mailType == MailMacro.Enum_Mail_Type.Friend then
    logic_mail.SortFriendMail(mailList)
  else
    logic_mail.SortMailList(mailList)
  end
  return logic_mail.GetMailWithDefaultSelect(mailList)
end
function logic_mail.GetMailWithDefaultSelect(mailList, defaultSelectId)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local withAttach = {}
  local haveRead = {}
  if defaultSelectId then
    for _, mailInfo in pairs(mailList) do
      if mailInfo.my_id == defaultSelectId then
        mailInfo.IsDefaultSelect = true
        return mailList
      end
    end
  end
  for _, mailInfo in pairs(mailList) do
    if logic_mail.nJumpBackMailId and mailInfo.my_id == logic_mail.nJumpBackMailId then
      log(bWriteLog and "[chub]GetMailWithDefaultSelect,logic_mail.nSelectMailId2 = " .. tostring(logic_mail.nJumpBackMailId))
      mailInfo.IsDefaultSelect = true
      logic_mail.nJumpBackMailId = nil
      return mailList
    end
    if logic_mail_utils.hasUnRecvAttach(mailInfo) then
      table.insert(withAttach, mailInfo)
    end
    if logic_mail_utils.IsHaveRead(mailInfo) then
      table.insert(haveRead, mailInfo)
    end
  end
  if next(withAttach) then
    table.sort(withAttach, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, mailInfo in pairs(mailList) do
      if withAttach[1] and mailInfo.my_id == withAttach[1].my_id then
        mailInfo.IsDefaultSelect = true
        break
      end
    end
    return mailList
  end
  if next(haveRead) then
    table.sort(haveRead, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, mailInfo in pairs(mailList) do
      if haveRead[1] and mailInfo.my_id == haveRead[1].my_id then
        mailInfo.IsDefaultSelect = true
        break
      end
    end
    return mailList
  end
  log_tree(bWriteLog and "[v_wllwu] logic_mail.GetMsgListByMailType mailList =  ", mailList)
  return mailList
end
function logic_mail.GetSecurityMailList(subtype, defaultSelectedId)
  if not subtype then
    return
  end
  if not MailInfoList then
    return
  end
  local mailList = {}
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  for _, v in pairs(MailInfoList) do
    if v.opt.type == MailMacro.Enum_Mail_Type.Security and (v.opt.subtype == subtype or subtype == MailMacro.Enum_Security_SubTabType.Report and logic_mail_utils.IsReportMailBySubType(v.opt.subtype)) then
      v.IsDefaultSelect = false
      table.insert(mailList, v)
    end
  end
  logic_mail.SortMailList(mailList)
  return logic_mail.GetMailWithDefaultSelect(mailList, defaultSelectedId)
end
function logic_mail.GetMsgCountByMailType(mailType)
  if not MailInfoList or not next(MailInfoList) then
    return 0
  end
  local count = 0
  for _, v in pairs(MailInfoList) do
    if v.opt.type == mailType then
      count = count + 1
    end
  end
  return count
end
function logic_mail.GetSecureMailCount()
  if not MailInfoList or not next(MailInfoList) then
    return 0
  end
  local count = 0
  for _, v in pairs(MailInfoList) do
    if v.opt.type == MailMacro.Enum_Mail_Type.Security and v.opt.subtype ~= MailMacro.Enum_Security_SubTabType.SlapFace and v.opt.subtype ~= MailMacro.Enum_Security_SubTabType.WarningPenalty and v.opt.subtype ~= MailMacro.Enum_Security_SubTabType.TWarningPenalty then
      count = count + 1
    end
  end
  return count
end
function logic_mail.ReadMailInfo(mailInfo)
  if mailInfo.read then
    return
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local mailType = mailInfo.opt.type
  if (mailType == MailMacro.Enum_Mail_Type.System or mailType == MailMacro.Enum_Mail_Type.Security or mailType == MailMacro.Enum_Mail_Type.Friend) and logic_mail_utils.hasUnRecvAttach(mailInfo) then
    return
  end
  logic_mail.ReadOneMail(mailInfo.my_id)
end
function logic_mail.GetMailInfoById(mailId)
  if not MailInfoList or not mailId then
    return
  end
  return MailInfoList[mailId]
end
function logic_mail.GetMailInfoByCfgId(nCfgId)
  if not MailInfoList or not nCfgId then
    return
  end
  for _, v in pairs(MailInfoList) do
    if v.opt and nCfgId == v.opt.cfg_id then
      return v
    end
  end
end
function logic_mail.GetMailInfoList()
  return MailInfoList
end
function logic_mail.SetOpenMailWithParams(params)
  OpenMailWithParamList = params
end
function logic_mail.GetOpenMailWithParams()
  return OpenMailWithParamList
end
function logic_mail.ResetOpenMailWithParams()
  OpenMailWithParamList = nil
end
function logic_mail.SetSelectMailId(mailId)
  logic_mail.nSelectMailId = mailId
end
function logic_mail.GetSelectMailId()
  return logic_mail.nSelectMailId
end
function logic_mail.SetJumpSystemMailCfgId(cfg_id)
  logic_mail.nJumpSystemMailCfgId = cfg_id
end
function logic_mail.GetJumpSystemMailCfgId()
  return logic_mail.nJumpSystemMailCfgId
end
function logic_mail.SetSecurityMailSubTabIndex(nSubType)
  if MailMacro.Enum_Security_SubTab_Config[nSubType] then
    logic_mail.nSecurityMailSubTabIndex = MailMacro.Enum_Security_SubTab_Config[nSubType].SubIndex
  end
end
function logic_mail.GetSecurityMailSubTabIndex()
  if logic_mail.nSecurityMailSubTabIndex then
    return logic_mail.nSecurityMailSubTabIndex
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local tSubTabCfg = MailMacro.Enum_Security_SubTab_Config
  local tSubTypeCfg = MailMacro.Enum_Security_SubTabType
  local tNotReadMailSubType = {
    [tSubTabCfg[tSubTypeCfg.Report].SubIndex] = 0,
    [tSubTabCfg[tSubTypeCfg.Notice].SubIndex] = 0,
    [tSubTabCfg[tSubTypeCfg.Punish].SubIndex] = 0
  }
  for _, v in pairs(MailInfoList or {}) do
    if v.opt.type == MailMacro.Enum_Mail_Type.Security and not logic_mail_utils.IsHaveRead(v) then
      local nSubIndex = tSubTabCfg[v.opt.subtype] and tSubTabCfg[v.opt.subtype].SubIndex
      if tNotReadMailSubType[nSubIndex] then
        tNotReadMailSubType[nSubIndex] = 1
      end
    end
  end
  for subIndex, val in ipairs(tNotReadMailSubType) do
    if val == 1 then
      return subIndex
    end
  end
  return tSubTabCfg[tSubTypeCfg.Report].SubIndex
end
function logic_mail.CheckShowDetailInfo(mailType)
  local paramsInfo = logic_mail.GetOpenMailWithParams()
  if not paramsInfo or not paramsInfo.selectMailId then
    return
  end
  local mailId = paramsInfo.selectMailId
  local mailInfo = logic_mail.GetMailInfoById(mailId)
  if not mailInfo or mailInfo.opt.type ~= mailType then
    logic_mail.ResetOpenMailWithParams()
    return
  end
  logic_mail.ReadMailInfo(paramsInfo.selectMailId)
  logic_mail.ResetOpenMailWithParams()
end
function logic_mail.OpenMailUI(mailType, subTabType, mailId)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MAIL) then
    return
  end
  logic_mail.ReqAllMailInfo()
  UIManager.ShowUI(UIManager.UI_Config.Mail_UIBP, mailType or MailMacro.Enum_Mail_Type.System, subTabType, nil, mailId)
end
function logic_mail.OpenMailDetailUI(mailInfo)
  local MailItemDetail = UIManager.GetUI(UIManager.UI_Config.mail_item_detail)
  if not MailItemDetail then
    local Mail_UIBP = UIManager.GetUI(UIManager.UI_Config.Mail_UIBP)
    if Mail_UIBP then
      Mail_UIBP:ShowLeftDetailUI(UIManager.UI_Config.mail_item_detail, mailInfo)
    end
  else
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_REFRESH_MAIL_DETAIL, mailInfo)
  end
end
function logic_mail.CloseMailDetailUI()
  UIManager.CloseUI(UIManager.UI_Config.mail_item_detail)
end
function logic_mail.OnJumpByUrl(_, _, param)
  ClientSendBAReport(TLogEventDefine.LobbyMail, 0)
  local tabId, subTabId, mailId
  if param then
    tabId = tonumber(param.tabId)
    subTabId = tonumber(param.subTabId)
    mailId = tonumber(param.mailId)
  end
  logic_mail.OpenMailUI(tabId, subTabId, mailId)
end
function logic_mail.CloseMailUI()
  UIManager.CloseUI(UIManager.UI_Config.Mail_UIBP)
end
function logic_mail.CloseChildUI()
  UIManager.CloseUI(UIManager.UI_Config.mail_item_detail)
end
function logic_mail.FetchSpecialAward()
  if not batchSpecialMailIdList or #batchSpecialMailIdList <= 0 then
    return
  end
  local mailId = table.remove(batchSpecialMailIdList, 1)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  log(bWriteLog and "[v_wllwu] logic_mail.FetchSpecialAward ,mailId is:" .. tostring(mailId))
  logic_mail_proto.fetch_mail_attach(mailId)
end
function logic_mail.ClearBatchAttachData()
  nextGroupAttachItemList = nil
  batchSpecialMailIdList = nil
end
function logic_mail.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, logic_mail.OnGameStateChange)
end
function logic_mail.OnGameStateChange(_, __, vars)
  log(bWriteLog and "logic_mail.OnGameStateChange" .. vars.current .. "  " .. vars.pre)
  if vars.current == GameStatus.Lobby then
    local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
    redpoint_data.InitData()
    logic_mail.ReqAllMailInfo(true)
    local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
    ShopGiftPacketLogic.SendGetGiftMsgList(11)
  elseif vars.current == GameStatus.Login then
    logic_mail.ClearMailCacheData()
  end
end
function logic_mail.ClearMailCacheData()
  MailInfoList = nil
  BlackMailList = nil
  NeedRemoveMailList = nil
  EffectMailIndexList = nil
  NewMailList = nil
  MessageSender = nil
  OpenMailWithParamList = nil
  reqFriendPresentTypeTimeRecord = nil
  logic_mail.ClearBatchAttachData()
  logic_mail.friendPresentTypeList = nil
  UGCMailInfoList = nil
end
return logic_mail
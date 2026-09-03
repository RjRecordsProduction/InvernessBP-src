local giftData = require("client.slua.umg.NewStoreV280.NewStoreMove.handsel.shop_gift_data")
local StoreUtils = require("client.slua.logic.store.utils.store_utils")
local refuseBeg = false
local isPlatformFriend = false
local giftRecvList = {}
local cachePopList = {}
local giftBegList = {}
local giftSendList = {}
local thanks = {}
local giftItemNumber = 0
local refreshItemIndexList = {}
local clickIndex = 1
local GiftSystem = {
  E_STYLE = {ONE = 1, TWO = 2},
  nJumpBackGiftIndex = nil
}
function GiftSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    GiftSystem.Release()
  elseif nextState == GameStatus.Fighting then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.ClosePopTip()
  end
end
local _GiftPopTypeList = {
  6011,
  6012,
  6031,
  961,
  908,
  403,
  401,
  407,
  903,
  108
}
local _IsPopGift = function(itemType)
  for i, v in ipairs(_GiftPopTypeList) do
    if itemType == v then
      return true
    end
  end
  return false
end
function GiftSystem.SetCachePopList(msgInfo)
  if msgInfo then
    table.insert(cachePopList, msgInfo)
  end
end
function GiftSystem.PopCommonTip()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local popCommonList = {}
  if giftRecvList and next(giftRecvList) then
    for i, msginfo in ipairs(giftRecvList) do
      local itemDataCfg = CDataTable.GetTableData("Item", msginfo.item)
      if itemDataCfg and _IsPopGift(itemDataCfg.ItemSubType) and not msginfo.isFetched then
        local hasExist = false
        for k, cachePopMsgInfo in ipairs(cachePopList) do
          if msginfo.index == cachePopMsgInfo.index then
            hasExist = true
            break
          end
        end
        if not hasExist then
          GiftSystem.SetCachePopList(msginfo)
          table.insert(popCommonList, msginfo)
        end
      end
    end
  end
  log(bWriteLog and "GiftSystem.PopCommonTip, " .. tostring(#popCommonList))
  log_tree("GiftSystem.PopCommonTip, popCommonList = ", popCommonList)
  if 0 < #popCommonList then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.PopCommonTip(popCommonList)
  end
end
function GiftSystem.SortGiftRecvList(tmplist)
  local list1 = {}
  local list2 = {}
  for i = 1, #tmplist do
    local tmp = tmplist[i]
    if tmp.isFetched == false then
      table.insert(list1, tmp)
    else
      table.insert(list2, tmp)
    end
  end
  table.sort(list1, function(a, b)
    return a.time > b.time
  end)
  table.sort(list2, function(a, b)
    return a.time > b.time
  end)
  giftRecvList = {}
  for i, v in ipairs(list1) do
    table.insert(giftRecvList, v)
  end
  for i, v in ipairs(list2) do
    table.insert(giftRecvList, v)
  end
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  if logic_mail.bOpenTestData then
    local Gift_Test_Data = RequireBlackList("blacklist.unit_testing.mail.Gift_Test_Data")
    if Gift_Test_Data then
      local TableUtil = require("common.table_util")
      giftRecvList = TableUtil.CopyTable(Gift_Test_Data.giftRecvList)
    end
  end
end
function GiftSystem.SortGiftBegList(tmplist)
  local list = {}
  for _, v in pairs(tmplist) do
    table.insert(list, v)
  end
  local SortFunc = function(a, b)
    if not a.is_refused and b.is_refused then
      return true
    elseif a.is_refused and not b.is_refused then
      return false
    end
    if a.read == 0 and b.read ~= 0 then
      return true
    elseif a.read ~= 0 and b.read == 0 then
      return false
    end
    return a.time > b.time
  end
  table.sort(list, SortFunc)
  giftBegList = list
end
function GiftSystem.SortGiftSendList(tmplist)
  giftSendList = {}
  for i, v in ipairs(tmplist) do
    table.insert(giftSendList, v)
  end
  table.sort(giftSendList, function(a, b)
    return a.time > b.time
  end)
end
function GiftSystem.GetItemCount(itemNum)
  if FuncUtil.IsPlayerJPKR() and tonumber(itemNum) >= 2 then
    return itemNum
  end
  return 1
end
function GiftSystem.RecvGiftList(res, msgtype, msglist)
  if res ~= NetErrorCode_NONE then
    return
  end
  if msgtype == 11 then
    local tmplist = {}
    for i, v in pairs(msglist) do
      giftData.BuildRecv(i, v, tmplist)
    end
    GiftSystem.SortGiftRecvList(tmplist)
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    if NewFaceSlapSystem:IsSlapEnd() then
      GiftSystem.PopCommonTip()
    else
      log(bWriteLog and "GiftSystem.PopCommonTip, FaceSlapSystem.IsSlapDone false")
    end
    local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
    redpoint_data.AddGiftRecvRedDot()
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_TEXT, 11)
  elseif msgtype == 13 then
    local tmplist = {}
    for i, v in pairs(msglist) do
      giftData.BuildSend(i, v, tmplist)
    end
    GiftSystem.SortGiftSendList(tmplist)
  end
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_GIFTCENTER_NEW_MSG)
end
function GiftSystem.GetCadgeList(msglist)
  local AskForSystem = require("client.slua.logic.ask_for.logic_ask_for")
  giftBegList = {}
  if AskForSystem.Cadge_Data.refuse_time then
    refuseBeg = true
  else
    refuseBeg = false
  end
  if not msglist or not next(msglist) then
    log(bWriteLog and "ShopGiftMsgCenter.GetCadgeList == nil")
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
    return
  end
  local tmplist = {}
  for i, v in pairs(msglist) do
    log(bWriteLog and "[chub]GiftSystem.GetCadgeList, v.given = " .. tostring(v.given) .. " v.cadge_time = " .. tostring(v.cadge_time))
    giftData.BuildAsk(i, v, tmplist)
  end
  GiftSystem.SortGiftBegList(tmplist)
  local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
  redpoint_data.AddGiftAskRedDot()
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_GIFTCENTER_NEW_MSG)
end
function GiftSystem.DeleteReadMsg(msglist)
  if next(giftBegList) then
    for i, v in pairs(giftBegList) do
      for ii, vv in pairs(msglist) do
        if v.index == vv then
          local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
          redpoint_data.AddGiftAskRedDot(v.index)
          giftBegList[i] = nil
        end
      end
    end
  end
  GiftSystem.SortGiftBegList(giftBegList)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
end
function GiftSystem.UpdateListData(typeTab, profileList)
  local tmplist = {}
  if typeTab == giftData.MsgCenterTabType.rec_gift then
    tmplist = giftRecvList
  elseif typeTab == giftData.MsgCenterTabType.ask then
    tmplist = giftBegList
  elseif typeTab == giftData.MsgCenterTabType.give_away then
    tmplist = giftSendList
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for k, v in pairs(profileList) do
    for kk, vv in pairs(tmplist) do
      if tonumber(vv.uid) == tonumber(v.uid) then
        vv.name, vv.nickName, vv.platName = giftData.GetName(v)
        vv.level = v.level
        vv.iconUrl = v.picUrl
        vv.vipLevel = v.vipLevel
        vv.gender = v.sex
        vv.avatarBox = v.cur_avatar_box_id
        vv.inited = true
        local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
        local intimacy = LogicFriend.GetInnerFriendIntimacy(vv.uid)
        if intimacy then
          vv.        else
          vv.intimacy = -1
        end
        vv.relation = LogicFriend.GetRelation(tonumber(v.uid))
        local hasKK = false
        for kkk, vvvv in ipairs(refreshItemIndexList) do
          if vvvv == kk then
            hasKK = true
          end
        end
        if hasKK == false then
          table.insert(refreshItemIndexList, kk)
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_UPDATE_LIST)
end
function GiftSystem.OnGetSetRead(msgtype, index)
  GiftSystem.SetRead(msgtype, index)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_READ, msgtype, index)
end
function GiftSystem.SetRead(msgtype, index)
  if msgtype == 11 then
    local mail = giftData.GetIndexDataList(giftRecvList, index)
    if mail then
      mail.read = 1
      local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
      redpoint_data.AddGiftRecvRedDot(index)
    end
  elseif msgtype == 12 then
    local mail = giftData.GetIndexDataList(giftBegList, index)
    if mail then
      mail.read = 1
      local redpoint_data = require("client.slua.logic.mail.logic_mail_redpoint_data")
      redpoint_data.AddGiftAskRedDot(index)
    end
  elseif msgtype == 13 then
    local mail = giftData.GetIndexDataList(giftSendList, index)
    if mail then
      mail.read = 1
    end
  end
end
function GiftSystem.OnDelAllGifts(del_msg_list)
  local del_map = {
    [11] = {
      recordList = {},
      targetList = giftRecvList
    },
    [12] = {
      recordList = {},
      targetList = giftBegList
    },
    [13] = {
      recordList = {},
      targetList = giftSendList
    }
  }
  for i = 1, #del_msg_list do
    local msgtype = del_msg_list[i][1]
    local index = del_msg_list[i][2]
    local recordList = del_map[msgtype].recordList
    recordList[#recordList + 1] = index
  end
  for msgtype, v in pairs(del_map) do
    local del_gifts = {}
    for i = 1, #v.recordList do
      local gift = giftData.GetIndexDataList(v.targetList, v.recordList[i])
      if gift then
        del_gifts[#del_gifts + 1] = gift
      end
    end
    for i = 1, #del_gifts do
      for j = 1, #v.targetList do
        if v.targetList[j] == del_gifts[i] then
          table.remove(v.targetList, j)
          break
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
end
function GiftSystem.GiftReceiveDataCollation(tGiftData, tItemData)
  if not tGiftData or not tItemData then
    return
  end
  tItemData.color_id = tGiftData.colorID
  tItemData.pattern_id = tGiftData.patternID
end
function GiftSystem.GiftReceiveNotice(tItemData, tDecItemList, nIndex)
  if not tItemData then
    return
  end
  if tDecItemList and tDecItemList[nIndex] then
    local tFromItemCfg = CDataTable.GetTableData("Item", tItemData.item)
    local tToItemCfg = CDataTable.GetTableData("Item", tDecItemList[nIndex].resid)
    if tFromItemCfg ~= nil and tToItemCfg ~= nil then
      local sFormatStr = LocUtil.GetLocalizeResStr(6345)
      sFormatStr = LocUtil.GeneralFormat(sFormatStr, tFromItemCfg.ItemName, tDecItemList[nIndex].count, tToItemCfg.ItemName)
      ShowNotice(sFormatStr)
    end
    return
  end
  local sMsg = LocUtil.GetLocalizeResStr(501026)
  sMsg = string.format(sMsg, giftData.GetShopItemName(tItemData.item, tItemData.colorID, tItemData.patternID, tItemData.itemNum))
  ShowNotice(sMsg)
end
function GiftSystem.OnGetGift(index, tItemList, tDecItemList)
  local tmp = giftData.GetIndexDataList(giftRecvList, index)
  if tmp == nil then
    return
  end
  tmp.isFetched = true
  GiftSystem.GiftReceiveNotice(tmp, tDecItemList, 1)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  isPlatformFriend = LogicFriend.IsPlatFriend(tmp.uid)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_UPDATE_GET_GIFT)
  local text = LocUtil.GetLocalizeResStr(501002)
  tmp.message = string.format(text, "", giftData.GetShopItemName(tmp.item, tmp.colorID, tmp.patternID))
  if not StoreUtils.CheckIsChest(tmp.item) then
    GiftSystem.GiftReceiveDataCollation(tmp, tItemList[1])
    log_tree("ShopGiftMsgCenter.OnGetGift  ShowPanel", tItemList)
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    if UnknowPassSystem.IsBuyElite and UnknowPassUtil.GetPassSeasonByItemID(tmp.item) == UnknowPassSystem.Season then
      GiftSystem.ReceiveRPGift(tmp, tItemList)
    elseif GiftSystem.CheckIsSmallCard(tmp.item) then
      GiftSystem.ReceiveSmallRPCardGift(tmp, tItemList)
    else
      local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
      for k, v in pairs(tItemList) do
        if not tDecItemList[k] then
          local period = logic_xsuit_activity:GetPeriodByCardItem(nil, v.resid, nil)
          local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
          local Item = LogicXSuit.GetSuitItemIDByPeriod(period)
          if Item then
            v.resid = Item
          end
        end
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DecomposeStyle(tItemList, tDecItemList)
    end
  end
  EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_SUCCESS_RECEIVE, index)
end
function GiftSystem.ReceiveRPGift(tCurItemData, tItemList)
  local content = LocUtil.GetLocalizeResStr(4584)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local insid = wardrobeLogic:GetWardrobeInsIdByResId(tCurItemData.item)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_TwoBtnStyle(tItemList, content, function()
    local CommonUseItemSystem = require("client.slua.logic.common.logic_common_use_items")
    CommonUseItemSystem.SetItemIsCanPreview(true)
    GlobalData.OpenUseItemsUI(insid)
    local logic_mail = require("client.slua.logic.mail.logic_mail")
    logic_mail.CloseMailUI()
    UIManager.CloseUI(UIManager.UI_Config.New_Shop_gift_All_UIBP)
  end)
end
function GiftSystem.CheckIsSmallCard(nItemId)
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  if Logic_SmallRP:GetSmallRPCardId() == tonumber(nItemId) then
    return true
  end
  return false
end
function GiftSystem.ReceiveSmallRPCardGift(tItemData, tAllItem)
  local sBtnStr = LocUtil.GetLocalizeResStr(54016)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_TwoBtnStyle(tAllItem, sBtnStr, function()
    local logic_mail = require("client.slua.logic.mail.logic_mail")
    logic_mail.CloseMailUI()
    UIManager.CloseUI(UIManager.UI_Config.New_Shop_gift_All_UIBP)
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    if Logic_SmallRP:GetIsUnlock() then
      GlobalData.JumpUrl(string.format("game://?module=%s&itemId=%s", BP_ENUM_MODULE_WARDROBE, tItemData.item))
    else
      local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
      GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_SPECIAL_OFFER .. "&id=" .. special_offer_cfg.SmallRP)
    end
  end)
end
function GiftSystem.OnGetAllGift(indexList, tGetAllItem, tDecItemList)
  local itemList = {}
  for i = 1, #indexList do
    local tmp = giftData.GetIndexDataList(giftRecvList, indexList[i])
    if tmp ~= nil then
      if not StoreUtils.CheckIsChest(tmp.item) then
        table.insert(itemList, tmp)
      end
      tmp.isFetched = true
      local text = LocUtil.GetLocalizeResStr(501002)
      tmp.message = string.format(text, "", giftData.GetShopItemName(tmp.item, tmp.colorID, tmp.patternID))
      tmp.read = 1
    end
  end
  if 0 < #itemList then
    for k, v in ipairs(itemList) do
      GiftSystem.GiftReceiveNotice(v, tDecItemList, k)
      GiftSystem.GiftReceiveDataCollation(v, tGetAllItem[k])
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(tGetAllItem, tDecItemList)
  end
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_UPDATE_GET_ALL_GIFT)
end
function GiftSystem.RequestGetGift(index)
  log(bWriteLog and "EventRequestGetGift")
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.SendMarketGiftTakeReq(index)
end
function GiftSystem.RefreshDelete(cadge_index)
  if cadge_index then
    for i, v in pairs(giftBegList) do
      if v.index == cadge_index then
        v.is_refused = true
      end
    end
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFUSE, cadge_index)
  end
end
function GiftSystem.DeleteAlreadySend(cadge_index)
  log(bWriteLog and "GiftSystem.DeleteAlreadySend cadge_index = " .. tostring(cadge_index))
  if cadge_index then
    for i, v in pairs(giftBegList) do
      if v.index == cadge_index then
        table.remove(giftBegList, i)
      end
    end
    GiftSystem.SortGiftBegList(giftBegList)
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_REFRESH_UI)
  end
end
function GiftSystem.OpenGiftAnimation(index)
  local data = giftData.GetIndexDataList(giftRecvList, index)
  if data == nil then
    return
  end
  if FuncUtil.IsPlayerJPKR() and data.itemNum >= 2 then
    giftItemNumber = tonumber(data.itemNum)
  else
    giftItemNumber = 1
  end
  log(bWriteLog and "check gift item valid" .. data.item)
  local GiftItem = CDataTable.GetTableData("Item", data.item)
  if GiftItem == nil then
    ShowNotice(6311)
    return
  end
  GiftSystem.OpenGiftGetView()
end
function GiftSystem.OpenGiftGetView()
  local data = giftData.GetIndexDataList(giftRecvList, clickIndex)
  if data == nil then
    return
  end
  if FuncUtil.IsPlayerJPKR() and data.itemNum >= 2 then
    giftItemNumber = tonumber(data.itemNum)
  else
    giftItemNumber = 1
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local id = LogicXSuit.GetExchagngeGiftIdOnCfg(data.item)
  if id then
    LogicXSuit.ShowGiftPacketUI(false, data)
    return
  elseif GiftSystem.IsOpenCarGiftSendView(data) then
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  isPlatformFriend = LogicFriend.IsPlatFriend(data.uid)
  UIManager.ShowUI(UIManager.UI_Config.New_Shop_gift_All_UIBP)
  if thanks[data.index] then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_HIDE_SHARE)
  end
end
function GiftSystem.IsOpenCarGiftSendView(tItemData)
  local uObj_vehicleShowCfg = CDataTable.GetTableData("BetterVehicleEffect", tItemData.item)
  if not (uObj_vehicleShowCfg and uObj_vehicleShowCfg.GetQualityImage) or uObj_vehicleShowCfg.GetQualityImage == "" then
    return false
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.IsExistBlueprintPath(uObj_vehicleShowCfg.GetQualityImage) then
    return false
  end
  local LadderDrawSystem = require("client.slua.logic.lobby_activity.logic_ladder_draw")
  local _, sBpPath = LadderDrawSystem.GetGiveCarUIConfig()
  if not sBpPath or not UIUtil.IsExistBlueprintPath(sBpPath) then
    return false
  end
  log(bWriteLog and "GiftSystem.IsOpenCarGiftSendView " .. tostring(tItemData.item) .. "   " .. tostring(uObj_vehicleShowCfg.GetQualityImage))
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if LadderCarDetailConfig.IsPorscheCars(tItemData.item) then
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.common_vehicle_give_panel, tItemData.item, false, tItemData)
  return true
end
function GiftSystem.JumpMarket(index)
  log(bWriteLog and "EventGiftMsgCenterJumpMarket, index = " .. tostring(index))
  local tmpData = giftData.GetIndexDataList(giftBegList, index)
  if tmpData == nil then
    return
  end
  log_tree("[chub]GiftSystem.JumpMarket,tmpData = ", tmpData)
  UIManager.ShowUI(UIManager.UI_Config.ui_ask_for_lookfor, tmpData)
end
function GiftSystem.SetThanks(index)
  thanks[index] = true
end
function GiftSystem.GetGiftListByType(nType)
  if nType == giftData.MsgCenterTabType.rec_gift then
    return GiftSystem.GetGiftRecvList()
  elseif nType == giftData.MsgCenterTabType.ask then
    return GiftSystem.GetGiftBegList()
  elseif nType == giftData.MsgCenterTabType.give_away then
    return GiftSystem.GetGiftSendList()
  end
  return {}
end
function GiftSystem.GetGiftRecvList()
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  if logic_mail.bOpenTestData then
    local Gift_Test_Data = RequireBlackList("blacklist.unit_testing.mail.Gift_Test_Data")
    if Gift_Test_Data then
      local TableUtil = require("common.table_util")
      giftRecvList = TableUtil.CopyTable(Gift_Test_Data.giftRecvList)
    end
  end
  log_tree("[chub]giftSystem.GetGiftRecvList() = ", giftRecvList)
  return giftRecvList
end
function GiftSystem.GetGiftBegList()
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  if logic_mail.bOpenTestData then
    local Gift_Test_Data = RequireBlackList("blacklist.unit_testing.mail.Gift_Test_Data")
    if Gift_Test_Data then
      local TableUtil = require("common.table_util")
      giftBegList = TableUtil.CopyTable(Gift_Test_Data.giftBegList)
    end
  end
  log_tree("[chub]giftSystem.GetGiftSendList() = ", giftBegList)
  return giftBegList
end
function GiftSystem.GetGiftSendList()
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  if logic_mail.bOpenTestData then
    local Gift_Test_Data = RequireBlackList("blacklist.unit_testing.mail.Gift_Test_Data")
    if Gift_Test_Data then
      local TableUtil = require("common.table_util")
      giftSendList = TableUtil.CopyTable(Gift_Test_Data.giftSendList)
    end
  end
  log_tree("[chub]giftSystem.GetGiftSendList() = ", giftSendList)
  return giftSendList
end
function GiftSystem.HandleDefaultSelectInList(giftList)
  local withAttach = {}
  local haveRead = {}
  for _, giftInfo in pairs(giftList) do
    log(bWriteLog and "[chub]GiftSystem.GetGiftListWithDefaultSelect,.nJumpBackGiftIndex = " .. tostring(GiftSystem.nJumpBackGiftIndex))
    if GiftSystem.nJumpBackGiftIndex and giftInfo.index == GiftSystem.nJumpBackGiftIndex then
      GiftSystem.nJumpBackGiftIndex = nil
      giftInfo.IsDefaultSelect = true
      return giftList
    end
    if giftInfo.isFetched ~= nil and giftInfo.isFetched == false then
      table.insert(withAttach, giftInfo)
    end
    if giftInfo.read and giftInfo.read ~= 0 then
      table.insert(haveRead, giftInfo)
    end
  end
  if next(withAttach) then
    table.sort(withAttach, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, giftInfo in pairs(giftList) do
      if withAttach[1] and giftInfo.index == withAttach[1].index then
        giftInfo.IsDefaultSelect = true
        break
      end
    end
    return giftList
  end
  if next(haveRead) then
    table.sort(haveRead, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, giftInfo in pairs(giftList) do
      if haveRead[1] and giftInfo.index == haveRead[1].index then
        giftInfo.IsDefaultSelect = true
        break
      end
    end
    return giftList
  end
  return giftList
end
function GiftSystem.GetGiftListWithDefaultSelect(nType)
  local giftList = GiftSystem.GetGiftListByType(nType)
  return GiftSystem.HandleDefaultSelectInList(giftList)
end
function GiftSystem.SaveThanksRecord(time, uid)
  if time and uid then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.GiftThankRecord)
    cfg = cfg or {}
    cfg[time] = uid
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.GiftThankRecord)
  end
end
function GiftSystem.HasThanks(time, uid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.GiftThankRecord)
  if not cfg then
    return false
  end
  return cfg[time] and cfg[time] == uid
end
function GiftSystem.IsRefuseBeg()
  return refuseBeg
end
function GiftSystem.SetRefuseBeg(res)
  refuseBeg = res
end
function GiftSystem.GetRefreshItemIndexList()
  return refreshItemIndexList
end
function GiftSystem.SetRefreshItemIndexList(list)
  refreshItemIndexList = list or {}
end
function GiftSystem.GetClickIndex()
  return clickIndex
end
function GiftSystem.SetClickIndex(i)
  clickIndex = i or 1
end
function GiftSystem.GetGiftItemNumber()
  return giftItemNumber
end
function GiftSystem.IsPlatformFriend()
  return isPlatformFriend
end
function GiftSystem.Release()
  cachePopList = {}
  giftRecvList = {}
  giftBegList = {}
  giftSendList = {}
  thanks = {}
end
return GiftSystem
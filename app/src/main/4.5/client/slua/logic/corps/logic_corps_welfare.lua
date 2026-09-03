local logic_corps_welfare = {}
local welfareDataList = {}
local welfareReceiveFlag = false
local bRedEnvelopesConfirm = false
local bAnonymousSendFlag = false
local welfareRedEnvelopesItemDataList = {}
function logic_corps_welfare.GetWelfareDataList()
  return welfareDataList
end
function logic_corps_welfare.SetWelfareReceiveFlag(bFlag)
  welfareReceiveFlag = bFlag
end
function logic_corps_welfare.GetWelfareReceiveFlag()
  return welfareReceiveFlag
end
function logic_corps_welfare.SetRedEnvelopesConfirm(bConfirm)
  bRedEnvelopesConfirm = bConfirm
end
function logic_corps_welfare.GetRedEnvelopesConfirm()
  return bRedEnvelopesConfirm
end
function logic_corps_welfare.SetAnonymousSendFlag(bAnonymous)
  bAnonymousSendFlag = bAnonymous
end
function logic_corps_welfare.GetAnonymousSendFlag()
  return bAnonymousSendFlag
end
function logic_corps_welfare.GetWelfareEnvelopesItemDataList()
  return welfareRedEnvelopesItemDataList
end
function logic_corps_welfare.ClearWelfareEnvelopesItemDataList()
  welfareRedEnvelopesItemDataList = {}
end
function logic_corps_welfare.ReceiveCorpsWelfareReq(id)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_receive_corps_share_ticket_request(id)
end
function logic_corps_welfare.ReceiveCorpsWelfareRsp(msg, share_ticket_list, recevie_info, item_list, is_have_can_receive)
  log(bWriteLog and "msg.." .. msg .. ",is_have_can_receive:" .. tostring(is_have_can_receive))
  local logic_oneclick_reward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  local isApply = logic_oneclick_reward.IsApplying()
  if isApply then
    logic_oneclick_reward.HandleCorpsWelfareReward(item_list)
  end
  if msg == NetErrorCode_NONE then
    if false == isApply then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle({
        {
          res_id = item_list[1].res_id,
          count = item_list[1].count,
          valid_hours = 0
        }
      })
    end
    logic_corps_welfare.SetCorpsWelfareList(share_ticket_list, recevie_info)
    welfareReceiveFlag = is_have_can_receive
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.UpdateRedPoint()
  elseif msg == 100150011 or msg == 100150012 then
    local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
    local NoticeMessage = LocUtil.LocalizeResFormat(14252, ChannelName)
    ShowNotice(NoticeMessage)
  elseif msg == 100150013 then
    local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
    local NoticeMessage = LocUtil.LocalizeResFormat(14253, ChannelName, share_ticket_list)
    ShowNotice(NoticeMessage)
  elseif isApply then
  else
    ShowNotice(msg)
  end
end
function logic_corps_welfare.ReceiveAllCorpsWelfareReq(id)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_receive_corps_share_ticket_batch_request(id)
end
function logic_corps_welfare.ReceiveAllCorpsWelfareRsp(msg, share_ticket_list, recevie_info, item_list, is_have_can_receive)
  log(bWriteLog and "msg.." .. msg .. ",is_have_can_receive:" .. tostring(is_have_can_receive))
  local logic_oneclick_reward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  local isApply = logic_oneclick_reward.IsApplying()
  if isApply then
    logic_oneclick_reward.HandleCorpsWelfareReward(item_list)
  end
  if msg == 0 then
    log_tree("share_ticket_list", share_ticket_list)
    log_tree("recevie_info", recevie_info)
    log_tree("item_list..", item_list)
    if false == isApply then
      local all_item_list = {}
      for _, arr in pairs(item_list) do
        for _, v in ipairs(arr) do
          v.valid_hours = v.valid_hours or 0
          all_item_list[#all_item_list + 1] = v
        end
      end
      log_tree("[v_ywuyuan] all_item_list", all_item_list)
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(all_item_list)
    end
    logic_corps_welfare.SetCorpsWelfareList(share_ticket_list, recevie_info)
    welfareReceiveFlag = is_have_can_receive
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.UpdateRedPoint()
  elseif msg == 100150011 or msg == 100150012 then
    local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
    local NoticeMessage = LocUtil.LocalizeResFormat(14252, ChannelName)
    ShowNotice(NoticeMessage)
  elseif msg == 100150013 then
    local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
    local NoticeMessage = LocUtil.LocalizeResFormat(14253, ChannelName, share_ticket_list)
    ShowNotice(NoticeMessage)
  elseif isApply then
  else
    ShowNotice(msg)
  end
end
function logic_corps_welfare.HaveCanReceiveShareTicketReq()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_have_can_recevie_share_ticket_request()
end
function logic_corps_welfare.HaveCanReceiveShareTicketRsp(msg, result, drop_id)
  if msg == NetErrorCode_NONE then
    logic_corps_welfare.SetHaveReceiveShareTicketReddot(result, drop_id)
  else
    ShowNotice(msg)
  end
end
function logic_corps_welfare.GetCorpsWelfareListReq()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_share_ticket_list_request()
end
function logic_corps_welfare.GetCorpsWelfareListRsp(msg, share_ticket_list, recevie_info, is_have_can_receive)
  log(bWriteLog and "CorpsWelfareListRsp:" .. tostring(is_have_can_receive))
  log_tree("share_ticket_list", share_ticket_list)
  log_tree("recevie_info", recevie_info)
  log_tree("DataMgr.corpsInfo.corpsMemberList", DataMgr.corpsInfo.corpsMemberList)
  if msg == NetErrorCode_NONE then
    logic_corps_welfare.SetCorpsWelfareList(share_ticket_list, recevie_info)
    welfareReceiveFlag = is_have_can_receive
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.UpdateRedPoint()
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_WELFARE_UI_REFRESH, 1)
  else
    ShowNotice(msg)
  end
end
function logic_corps_welfare.CorpsWelfareReq(is_confirm, is_anonymous)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_share_ticket_request(is_confirm, is_anonymous)
end
function logic_corps_welfare.CorpsWelfareRsp(msg)
  if msg == NetErrorCode_NONE then
    if bRedEnvelopesConfirm then
      ShowNotice(6464)
    end
  else
    ShowNotice(msg)
  end
end
function logic_corps_welfare.TriggerCorpsShareTicketRsp(corps_share_data)
  if corps_share_data and type(corps_share_data) == "table" and 0 < #corps_share_data then
    for k, v in pairs(corps_share_data) do
      if v and v.res_id and v.res_id ~= 0 then
        local item = {}
        item.res_id = v.res_id
        item.count = v.count or 0
        item.valid_hours = v.valid_hours or 0
        item.expire_ts = v.expire_ts or 0
        table.insert(welfareRedEnvelopesItemDataList, item)
      end
    end
  end
end
function logic_corps_welfare.ShowTabUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_welfare_main)
end
function logic_corps_welfare.CloseTabUI()
  UIManager.CloseUI(UIManager.UI_Config.corps_welfare_main)
end
function logic_corps_welfare.ShowReceiveUI(tickId)
  UIManager.ShowUI(UIManager.UI_Config.corps_welfare_receive, tickId)
end
function logic_corps_welfare.ShowRedEnvelopUI()
  if 0 < #welfareRedEnvelopesItemDataList then
    UIManager.ShowUI(UIManager.UI_Config.corps_welfare_redEnvelop)
  end
end
function logic_corps_welfare.CloseRedEnvelopUI()
  UIManager.CloseUI(UIManager.UI_Config.corps_welfare_redEnvelop)
end
function logic_corps_welfare.SetCorpsWelfareList(share_ticket_list, recevie_info)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  log_tree("share_ticket_list", share_ticket_list)
  log_tree("recevie_info", recevie_info)
  if share_ticket_list and type(share_ticket_list) == "table" and #DataMgr.corpsInfo.corpsMemberList > 0 then
    welfareDataList = {}
    for k, v in pairs(share_ticket_list) do
      local item = v
      item.share_ticket_id = tostring(v.share_ticket_id)
      item.baseinfo = {}
      item.state = recevie_info[k]
      table.insert(welfareDataList, item)
    end
    if welfareDataList and 0 < #welfareDataList then
      log_tree("welfareDataList", welfareDataList)
      table.sort(welfareDataList, function(a, b)
        if a.state == b.state then
          return a.create_time > b.create_time
        else
          return a.state < b.state
        end
      end)
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_WELFARE_UI_REFRESH, 1)
    end
  end
end
function logic_corps_welfare.SetHaveReceiveShareTicketReddot(hasRedPoint)
  log(bWriteLog and "SetHaveReceiveShareTicketReddot:" .. tostring(welfareReceiveFlag))
  welfareReceiveFlag = hasRedPoint or false
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.welfare)
end
function logic_corps_welfare.GetCorpsWelfareReceiveData(tickID)
  local receiveDataList = {}
  log_tree("[v_ywuyuan] logic_corps_welfare.GetCorpsWelfareReceiveData", welfareDataList)
  if welfareDataList and 0 < #welfareDataList then
    for i = 1, #welfareDataList do
      if welfareDataList[i].share_ticket_id == tickID then
        for uid, v in pairs(welfareDataList[i].recevie_table) do
          local item = {}
          item.          item.count = v.item_list[1].count
          item.resId = v.item_list[1].res_id
          item.recevie_time = v.recevie_time
          table.insert(receiveDataList, item)
        end
      end
    end
  end
  log_tree("[v_ywuyuan] logic_corps_welfare.GetCorpsWelfareReceiveData", receiveDataList)
  if receiveDataList and 0 < #receiveDataList then
    table.sort(receiveDataList, function(a, b)
      return a.recevie_time > b.recevie_time
    end)
  end
  return receiveDataList
end
return logic_corps_welfare
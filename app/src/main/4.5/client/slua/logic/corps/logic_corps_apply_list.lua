local CorpsApplyListUILogic = {
  DetailApplyList = {},
  ApplyStatus = {
    no_op = 0,
    approval = 1,
    accept = 2,
    refuse = 3
  },
  HasRedPoint = false,
  ApplyList = {}
}
function CorpsApplyListUILogic.CloseUI()
  UIManager.CloseUI(UIManager.UI_Config.corps_applylist)
end
function CorpsApplyListUILogic.ShowApplyListUI()
  UIManager.ShowUI(UIManager.UI_Config.corps_applylist)
  log(bWriteLog and "CorpsApplyListUILogic.ShowApplyListUI")
  CorpsApplyListUILogic.SendGetCorpsApplyListReq()
end
function CorpsApplyListUILogic.OnUpdateApplyListUI(base_info_List)
  CorpsApplyListUILogic.DetailApplyList = {}
  local infos = {}
  for _, v in ipairs(base_info_List) do
    infos[v.uid] = v
  end
  log_tree("CorpsApplyListUILogic.OnUpdateApplyListUI base_info_List", base_info_List)
  if infos ~= nil then
    for k, v in pairs(CorpsApplyListUILogic.ApplyList) do
      local info = CorpsApplyListUILogic.CreateListItem(v, v.uid, infos[v.uid])
      if info ~= nil then
        table.insert(CorpsApplyListUILogic.DetailApplyList, info)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_APPLY_LIST)
end
function CorpsApplyListUILogic.IsFriendRecomm(applyInfo)
  return applyInfo.recomm_name ~= nil or applyInfo.status ~= nil
end
function CorpsApplyListUILogic.CreateListItem(applyInfo, uid, baseInfo)
  if applyInfo == nil then
    return nil
  end
  local recommName = ""
  if applyInfo.recomm_name ~= nil then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    recommName = LocUtil.LocalizeResFormat("410037", logic_profile:GetNickName(applyInfo.recomm_uid) or applyInfo.recomm_name)
  end
  local info = {
    uid = uid,
    RecommendFriendName = recommName,
    profile = baseInfo
  }
  return info
end
function CorpsApplyListUILogic.RemoveItem(apply_uid)
  local hasChange = false
  for i, v in ipairs(CorpsApplyListUILogic.DetailApplyList) do
    if tonumber(v.uid) == tonumber(apply_uid) then
      table.remove(CorpsApplyListUILogic.DetailApplyList, i)
      hasChange = true
      break
    end
  end
  if hasChange then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_APPLY_LIST)
  end
end
function CorpsApplyListUILogic.FindApplyByID(id)
  id = tonumber(id)
  for i, v in ipairs(CorpsApplyListUILogic.ApplyList) do
    if v.uid == id then
      return v
    end
  end
  return nil
end
function CorpsApplyListUILogic.OnClickAgree(id)
  id = tonumber(id)
  log(bWriteLog and "CorpsApplyListUILogic.OnClickAgree id " .. id)
  local applyInfo = CorpsApplyListUILogic.FindApplyByID(id)
  if applyInfo == nil then
    return
  end
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if CorpsApplyListUILogic.IsFriendRecomm(applyInfo) then
    CorpsMemberSystem.SendInviteReq(id, 1)
  else
    CorpsApplyListUILogic.SendDealPlayerApplyReq(id, true)
  end
end
function CorpsApplyListUILogic.OnClickRefuse(id)
  id = tonumber(id)
  log(bWriteLog and "CorpsApplyListUILogic.OnClickRefuse id " .. id)
  local applyInfo = CorpsApplyListUILogic.FindApplyByID(id)
  if applyInfo == nil then
    return
  end
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if CorpsApplyListUILogic.IsFriendRecomm(applyInfo) then
    CorpsMemberSystem.SendInviteReq(id, 2)
  else
    CorpsApplyListUILogic.SendDealPlayerApplyReq(id, false)
  end
end
function CorpsApplyListUILogic.InitApplyList(apply_list)
  CorpsApplyListUILogic.ApplyList = {}
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if apply_list and CorpsMemberSystem.IsSelfCommanderOrSecCommanderOrAgentLeader() then
    for i, v in ipairs(apply_list) do
      if CorpsApplyListUILogic.IsCanAddToApplyList(v) then
        local TableUtil = require("common.table_util")
        table.insert(CorpsApplyListUILogic.ApplyList, TableUtil.CopyTable(v))
      end
    end
  end
  CorpsApplyListUILogic.SetApplyListRedPoint(#CorpsApplyListUILogic.ApplyList > 0)
end
function CorpsApplyListUILogic.OnApplyListInfoReq()
  local uidList = {}
  for i, v in ipairs(CorpsApplyListUILogic.ApplyList) do
    table.insert(uidList, v.uid)
  end
  if #uidList == 0 then
    CorpsApplyListUILogic.OnUpdateApplyListUI({})
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.CORPS_BASE, uidList, CorpsApplyListUILogic.OnUpdateApplyListUI)
  end
end
function CorpsApplyListUILogic.SendDealPlayerApplyReq(apply_uid, accept)
  log(bWriteLog and "CorpsApplyListUILogic.SendDealPlayerApplyReq apply_uid " .. apply_uid)
  log(bWriteLog and "CorpsApplyListUILogic.SendDealPlayerApplyReq accept " .. tostring(accept))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_deal_player_apply_req(tonumber(apply_uid), accept)
end
function CorpsApplyListUILogic.deal_player_apply_rsp(msg, corps, apply_uid, accept)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "CorpsApplyListUILogic.deal_player_apply_rsp msg " .. tostring(msg))
  if msg == NetErrorCode_NONE then
    if accept then
      CorpsMgr.InitData(corps)
      ShowNotice(410035)
    else
      ShowNotice(410036)
    end
  elseif msg ~= nil then
    if msg == 421041 then
      ShowNotice(64987)
    else
      ShowNotice(msg)
    end
  end
  if apply_uid == nil then
    CorpsApplyListUILogic.SendGetCorpsApplyListReq()
  else
    CorpsApplyListUILogic.RemoveFromApplyList(apply_uid)
  end
end
function CorpsApplyListUILogic.RemoveFromApplyList(apply_uid)
  local removeIdx = -1
  for i, v in ipairs(CorpsApplyListUILogic.ApplyList) do
    if v.uid == apply_uid then
      removeIdx = i
      break
    end
  end
  if removeIdx ~= -1 then
    table.remove(CorpsApplyListUILogic.ApplyList, removeIdx)
    CorpsApplyListUILogic.RemoveItem(apply_uid)
    CorpsApplyListUILogic.SetApplyListRedPoint(#CorpsApplyListUILogic.ApplyList > 0)
  end
end
function CorpsApplyListUILogic.notify_someone_apply_join()
  log(bWriteLog and "CorpsApplyListUILogic.notify_someone_apply_join")
  CorpsApplyListUILogic.SetApplyListRedPoint(true)
end
function CorpsApplyListUILogic.SetApplyListRedPoint(hasRedPoint)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "SetApplyListRedPoint:" .. tostring(hasRedPoint))
  CorpsApplyListUILogic.HasRedPoint = hasRedPoint or false
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.applicaton)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYLIST, hasRedPoint)
end
function CorpsApplyListUILogic.SendGetCorpsApplyListReq()
  if DataMgr.corpsInfo.id ~= 0 then
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_apply_list_req()
  end
end
function CorpsApplyListUILogic.get_corps_apply_list_rsp(msg, apply_list)
  log(bWriteLog and "CorpsApplyListUILogic.get_corps_apply_list_rsp msg " .. tostring(msg))
  if msg == NetErrorCode_NONE then
    CorpsApplyListUILogic.InitApplyList(apply_list)
    CorpsApplyListUILogic.OnApplyListInfoReq()
  elseif msg ~= nil and msg ~= 411006 then
    ShowNotice(msg)
  end
end
function CorpsApplyListUILogic.IsCanAddToApplyList(applyInfo)
  if applyInfo == nil then
    return false
  end
  local isValidStatus = applyInfo.status == CorpsApplyListUILogic.ApplyStatus.approval
  return applyInfo.recomm_name == nil or isValidStatus
end
return CorpsApplyListUILogic
local Logic_Temu_Team = require("client.slua.logic.specialoffer.Temu.Logic_Temu_Team")
local Logic_Temu_Invite = require("client.slua.logic.specialoffer.Temu.Logic_Temu_Invite")
local Logic_Temu_Cfg = require("client.slua.logic.specialoffer.Temu.Logic_Temu_Cfg")
local Logic_Temu_Stage = require("client.slua.logic.specialoffer.Temu.Logic_Temu_Stage")
local Logic_temu = {
  progressLastTimeStamp = {},
  inviteRed = {},
  packageRed = false
}
Logic_temu.Enum_SubStage = {
  Team = 1,
  Task = 2,
  Package = 3
}
Logic_temu.Enum_PkgState = {
  Lock = 0,
  CanBuy = 1,
  IsBuy = 2
}
function Logic_temu:DefineAndResetData()
  Logic_temu.__super.DefineAndResetData(self)
end
function Logic_temu:OnDestroy()
  log(bWriteLog and "[SY]Logic_temu:OnDestroy.")
  Logic_temu.__super.OnDestroy(self)
end
function Logic_temu:OnLogOut()
  log(bWriteLog and "[SY]Logic_temu:OnLogOut.")
  Logic_Temu_Team.ResetData()
  Logic_Temu_Invite.ResetData()
  Logic_Temu_Stage.ResetData()
  Logic_Temu_Cfg.ResetData()
  Logic_temu.__super.OnLogOut(self)
end
function Logic_temu:OnInitialize()
  log(bWriteLog and "[SY]Logic_temu:OnInitialize.")
  Logic_temu.__super.OnInitialize(self)
  self:Init()
end
function Logic_temu:RegistEvents()
  Logic_temu.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.TryGetCfg)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_GET_INFO, self.OnRefreshDircetPriceInfo, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, self.OnLoadPriceDataCallback, self)
end
function Logic_temu:Init()
  self:TryGetCfg()
end
function Logic_temu:OnLogin()
  self:TryGetCfg()
end
function Logic_temu:Login_SetTeamID(id)
  Logic_Temu_Team.Login_SetTeamID(id)
end
function Logic_temu:SendCreateTeam(stageID)
  Logic_Temu_Team.SendCreateTeam(stageID)
end
function Logic_temu:SendDismissTeam()
  Logic_Temu_Team.SendDismissTeam()
end
function Logic_temu:SendJoinTeam(id)
  Logic_Temu_Team.SendJoinTeam(id)
end
function Logic_temu:SendLeaveTeam()
  Logic_Temu_Team.SendLeaveTeam()
end
function Logic_temu:SendKickMember(uid)
  Logic_Temu_Team.SendKickMember(uid)
end
function Logic_temu:SendGetSelfTeamInfo(isForceGet)
  Logic_Temu_Team.SendGetSelfTeamInfo(isForceGet)
end
function Logic_temu:SendGetTeamInfo(id, isForceGet)
  Logic_Temu_Team.SendGetTeamInfo(id, isForceGet)
end
function Logic_temu:SendRemind(uid)
  Logic_Temu_Invite.TaskRemind(uid)
end
function Logic_temu:SendStartTaskStage()
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_start_temu_task_phase_req()
end
function Logic_temu:OnCreateTeam(id)
  Logic_Temu_Team.OnCreateTeam(id)
  Logic_Temu_Invite.ClearGroupInviteData()
  Logic_Temu_Stage.SendGetStageInfo(true)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_JOIN_TEAM)
end
function Logic_temu:OnJoinTeam(id)
  Logic_Temu_Team.OnJoinTeam(id)
  Logic_Temu_Stage.SendGetStageInfo(true)
  Logic_Temu_Invite.ClearGroupInviteData()
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_JOIN_TEAM)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  special_offer_module:OpenOneAct(special_offer_cfg.TEMU)
end
function Logic_temu:OnGetTeamInfo(info)
  Logic_Temu_Team.OnGetTeamInfo(info)
end
function Logic_temu:OnDismissTeam(group_id)
  Logic_Temu_Team.OnDismissTeam(group_id)
  Logic_Temu_Invite.ClearInviteList()
  Logic_Temu_Invite.ClearRemindList()
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_DISSMISS_TEAM)
end
function Logic_temu:OnLeaveTeam(group_id, activity_id, reason)
  Logic_Temu_Team.OnLeaveTeam(group_id)
  Logic_Temu_Invite.ClearInviteList()
  Logic_Temu_Invite.ClearRemindList()
  self:UpdatePackageRedDot(0)
  if activity_id == self:GetCurSeasonID() and reason == "KICK_MEMBER" then
    self.beKicked = true
  end
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_LEAVE_TEAM)
end
function Logic_temu:OnKickMember(member_uid)
  Logic_Temu_Team.OnKickMember(member_uid)
end
function Logic_temu:OnRemindTeamMate(uidList)
  Logic_Temu_Team.OnRemindTeamMate(uidList)
end
function Logic_temu:GetSelfTeamID()
  return Logic_Temu_Team.GetSelfTeamID()
end
function Logic_temu:IsHaveTeam()
  return Logic_Temu_Team.IsHaveTeam()
end
function Logic_temu:IsTeamCanKick(uid)
  return Logic_Temu_Team.IsTeamCanKick(uid)
end
function Logic_temu:IsCanSendTeamInfo(id)
  return Logic_Temu_Team.IsCanSendTeamInfo(id)
end
function Logic_temu:IsLeader(groupId, uid)
  return Logic_Temu_Team.IsLeader(groupId, uid)
end
function Logic_temu:IsSelfLeader()
  return Logic_Temu_Team.IsSelfLeader()
end
function Logic_temu:IsTeamHaveMemberCanGift()
  return Logic_Temu_Team.IsTeamHaveMemberCanGift()
end
function Logic_temu:GetSelfTeamInfo()
  return Logic_Temu_Team.GetSelfTeamInfo()
end
function Logic_temu:GetTeamInfo(id)
  return Logic_Temu_Team.TryGetTeamInfo(id)
end
function Logic_temu:GetCurStageID()
  return Logic_Temu_Team.GetCurStageID()
end
function Logic_temu:GetCurSubStageID()
  return Logic_Temu_Team.GetCurSubStageID()
end
function Logic_temu:GetPackageExpireTime()
  return Logic_Temu_Team.GetPackageExpireTime()
end
function Logic_temu:GetFreeLeaveTime()
  return Logic_Temu_Team.GetFreeLeaveTime()
end
function Logic_temu:GetMemberTaskProgress(uid, stage)
  return Logic_Temu_Team.GetMemberTaskProgress(uid, stage)
end
function Logic_temu:UpdateTeamMemberProgress(memberProgress, stage)
  Logic_Temu_Team.OnSendGetStageTaskProgress(memberProgress, stage)
end
function Logic_temu:CheckPackageStateCanKick()
  return Logic_Temu_Team.CheckPackageStateCanKick()
end
function Logic_temu:IsCurStageNeedAnim(stageID)
  return Logic_Temu_Team.IsCurStageNeedAnim(stageID)
end
function Logic_temu:SetAlreadyPlayStageAnimation(stageID)
  return Logic_Temu_Team.SetAlreadyPlayStageAnimation(stageID)
end
function Logic_temu:GetTeamInfoTotalNum(teamID)
  return Logic_Temu_Team.GetTeamInfoTotalNum(teamID)
end
function Logic_temu:GetStartTaskMemberNum(teamID)
  return Logic_Temu_Team.GetStartTaskMemberNum(teamID)
end
function Logic_temu:ClearTeamData()
  Logic_Temu_Team.ClearTeamData()
end
function Logic_temu:IsCurSeasonNeedShowGuide()
  Logic_Temu_Team.IsCurSeasonNeedShowGuide()
end
function Logic_temu:TodayShowGuide()
  Logic_Temu_Team.TodayShowGuide()
end
function Logic_temu:SendGetStageInfo(isForce)
  Logic_Temu_Stage.SendGetStageInfo(isForce)
end
function Logic_temu:SendCompleteTask(task_id, stageId)
  Logic_Temu_Stage.SendCompleteTask(task_id, stageId)
end
function Logic_temu:SendBuyPackage(stage, packageID)
  Logic_Temu_Stage.SendBuyPackage(stage, packageID)
end
function Logic_temu:SendGivePackage(stage, packageID, uid)
  Logic_Temu_Stage.SendGivePackage(stage, packageID, uid)
end
function Logic_temu:SendGetStageTaskProgress(stageId)
  Logic_Temu_Stage.SendGetStageTaskProgress(stageId)
end
function Logic_temu:OnSendCompleteTask(award_list, stage_id, task_id)
  Logic_Temu_Stage.OnSendCompleteTask(award_list, stage_id, task_id)
end
function Logic_temu:OnSendGetStageInfo(stage_info)
  Logic_Temu_Stage.OnSendGetStageInfo(stage_info)
end
function Logic_temu:OnSendGetStageTaskProgress(stageInfo)
  log(bWriteLog and "[SY]Logic_temu:OnSendGetStageTaskProgress.")
  local lastTime = self.progressLastTimeStamp[stageInfo.stage_id] or 0
  if lastTime > stageInfo.timestamp then
    log(bWriteLog and "[SY]Logic_temu:OnSendGetStageTaskProgress. isLate")
    return
  end
  self.progressLastTimeStamp[stageInfo.stage_id] = stageInfo.timestamp
  Logic_Temu_Stage.OnSendGetStageTaskProgress(stageInfo)
  self:UpdateTeamMemberProgress(stageInfo.member_progress, stageInfo.stage_id)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_STAGE_PROGRESS_INFO)
end
function Logic_temu:MovenNextStage(subStageID)
  Logic_Temu_Stage.ClearLastSendTime()
  Logic_Temu_Team.ClearLastSendTime()
  self:GetRedot()
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDAT_EVENT_STAGE_UP, subStageID)
end
function Logic_temu:OnBuyComplete(stage_id, reward_list)
  Logic_Temu_Stage.OnBuyComplete(stage_id, reward_list)
  self:SendGetSelfTeamInfo(true)
  self:SendGetStageInfo(true)
  self:UpdatePackageRedDot(0)
end
function Logic_temu:IsCanBuyPackage(stage)
  return Logic_Temu_Stage.IsCanBuyPackage(stage)
end
function Logic_temu:IsBuyAllPackage()
  return Logic_Temu_Stage.IsBuyAllPackage()
end
function Logic_temu:IsStageAllPersonalTaskComplete(stageID, number)
  return Logic_Temu_Stage.IsStageAllPersonalTaskComplete(stageID, number)
end
function Logic_temu:GetStageInfo(stageID)
  return Logic_Temu_Stage.GetStageInfo(stageID)
end
function Logic_temu:GetTaskData(stageID, taskID)
  return Logic_Temu_Stage.GetTaskData(stageID, taskID)
end
function Logic_temu:GetTaskProgressState(stageID, taskID)
  return Logic_Temu_Stage.GetTaskProgressState(stageID, taskID)
end
function Logic_temu:GetStageBuyPackageID(stage)
  return Logic_Temu_Stage.GetStageBuyPackageID(stage)
end
function Logic_temu:GetStageValue(stage)
  return Logic_Temu_Stage.stageValue[stage]
end
function Logic_temu:GetStageBuyState(stage)
  return Logic_Temu_Stage.GetStageBuyState(stage)
end
function Logic_temu:GetAllStageData()
  return Logic_Temu_Stage.GetAllStageData()
end
function Logic_temu:SendGetGroupInviteMap(stageId)
  Logic_Temu_Invite.SendGetGroupInviteMap(stageId)
end
function Logic_temu:SendGetRecommendInviteMap(stageId)
  Logic_Temu_Invite.SendGetRecommendInviteMap(stageId)
end
function Logic_temu:OnSendGetGroupInviteMap(inviteList, stage_id)
  Logic_Temu_Invite.OnSendGetGroupInviteMap(inviteList, stage_id)
end
function Logic_temu:OnSendGetRecommendInviteMap(data, stage_id)
  Logic_Temu_Invite.OnSendGetRecommendInviteMap(data, stage_id)
end
function Logic_temu:SendInviteFriendList(uid_list)
  Logic_Temu_Invite.SendInviteFriendList(uid_list)
end
function Logic_temu:OnRefreshDircetPriceInfo(_, _, list)
  Logic_Temu_Cfg.OnRefreshDircetPriceInfo(list)
end
function Logic_temu:OnLoadPriceDataCallback(resultCode)
  Logic_Temu_Cfg.OnLoadPriceDataCallback(resultCode)
end
function Logic_temu:InviteListAdd(uid)
  Logic_Temu_Invite.InviteListAdd(uid)
end
function Logic_temu:RemindListAdd(uid)
  Logic_Temu_Invite.RemindListAdd(uid)
end
function Logic_temu:InviteFriend(uid)
  Logic_Temu_Invite.InviteFriend(uid)
end
function Logic_temu:InviteCrop()
  Logic_Temu_Invite.InviteCrop()
end
function Logic_temu:IsUserCanRemindTask(uid)
  return Logic_Temu_Invite.IsUserCanRemindTask(uid)
end
function Logic_temu:TaskRemind(uid)
  Logic_Temu_Invite.TaskRemind(uid)
end
function Logic_temu:ReqFriendProfile(bShow)
  Logic_Temu_Invite.ReqFriendProfile(bShow)
end
function Logic_temu:IsFriendCanInvite(uid)
  return Logic_Temu_Invite.IsFriendCanInvite(uid)
end
function Logic_temu:IsUserCanRemind(uid)
  return Logic_Temu_Invite.IsUserCanRemind(uid)
end
function Logic_temu:GetGroupInviteList(stageId)
  return Logic_Temu_Invite.GetGroupInviteList(stageId)
end
function Logic_temu:GetRecommendInviteList(stageId)
  return Logic_Temu_Invite.GetRecommendInviteList(stageId)
end
function Logic_temu:TryGetCfg()
  Logic_Temu_Cfg.TryGetCfg()
end
function Logic_temu:GetStageCfg(stage, number)
  return Logic_Temu_Cfg.GetStageCfg(stage, number)
end
function Logic_temu:GetStageAllTask(stage, number)
  return Logic_Temu_Cfg.GetStageAllTask(stage, number)
end
function Logic_temu:GetStagePackageId(stage, number)
  return Logic_Temu_Cfg.GetStagePackageId(stage, number)
end
function Logic_temu:GetStageOriginPackageId(stage, number)
  return Logic_Temu_Cfg.GetStageOriginPackageId(stage, number)
end
function Logic_temu:GetStageAllDisCount(stage)
  return Logic_Temu_Cfg.GetStageAllDisCount(stage)
end
function Logic_temu:GetCurSeasonID()
  return Logic_Temu_Cfg.GetCurSeasonID()
end
function Logic_temu:IsCurSeasonInTime()
  return Logic_Temu_Cfg.IsCurSeasonInTime()
end
function Logic_temu:GetCurEndTime()
  return Logic_Temu_Cfg.GetCurEndTime()
end
function Logic_temu:GetPriceInfo(itemID)
  return Logic_Temu_Cfg.GetPriceInfo(itemID)
end
function Logic_temu:GetMaxStage()
  return Logic_Temu_Cfg.GetMaxStage()
end
function Logic_temu:GetAllStageCfg(seasonID)
  return Logic_Temu_Cfg.GetAllStageCfg(seasonID)
end
function Logic_temu:GetSeasonCfg(seasonID)
  return Logic_Temu_Cfg.GetSeasonCfg(seasonID)
end
function Logic_temu:GetCurActivityTime(seasonID)
  return Logic_Temu_Cfg.GetCurActivityTime(seasonID)
end
function Logic_temu:GetRedot()
  if Logic_temu:IsCurSeasonInTime() then
    log(bWriteLog and "[SY]Logic_temu:GetRedot.")
    local TEMUHandler = require("client.network.Protocol.TEMUHandler")
    TEMUHandler.send_get_temu_red_point_req()
  end
end
function Logic_temu:SendIsCheckInviteRed(stage_id)
  log(bWriteLog and "[SY]Logic_Temu_Stage.IsCheckRed.")
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_remove_temu_invite_red_point_req(stage_id)
end
function Logic_temu:SendIsCheckKickTips()
  log(bWriteLog and "[SY]Logic_temu:SendIsCheckKickTips.")
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_remove_temu_be_kicked_red_point_req()
end
function Logic_temu:OnGetRedot(be_invited_red_point, pkg_red_point, be_kicked_red_point)
  self.inviteRed = be_invited_red_point
  self.packageRed = pkg_red_point == 1
  self.beKicked = be_kicked_red_point == 1
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.TEMU)
end
function Logic_temu:UpdatePackageRedDot(ret)
  self.packageRed = ret == 1
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.TEMU)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_PACKAGE_RED)
end
function Logic_temu:ResetInviteRedDot(stage_id)
  self.inviteRed[stage_id] = 0
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.TEMU)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_INVITE_RED, stage_id)
end
function Logic_temu:OnUpdateInviteRedDot(stage_id)
  self.inviteRed[stage_id] = 1
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.TEMU)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_INVITE_RED, stage_id)
end
function Logic_temu:OnSendIsCheckGetKickTips()
  self.beKicked = false
end
function Logic_temu:IsNeedShowGetKickTip()
  return self.beKicked
end
function Logic_temu:IsNeedShowReddot()
  return self:CheckAllInviteRed() or self.packageRed
end
function Logic_temu:CheckIsHavePackageCanBuy()
  return Logic_Temu_Stage.CheckIsHavePackageCanBuy()
end
function Logic_temu:IsStageHaveInviteRed(stageID)
  if not (not self:IsHaveTeam() and self.inviteRed) or not self.inviteRed[stageID] then
    return false
  end
  return self.inviteRed[stageID] == 1
end
function Logic_temu:CheckAllInviteRed(stageID)
  if not (not self:IsHaveTeam() and self.inviteRed) or self.inviteRed[stageID] then
    return false
  end
  for i, v in pairs(self.inviteRed) do
    if v == 1 then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_Temu = class(CModuleBase, nil, Logic_temu)
return CLogic_Temu
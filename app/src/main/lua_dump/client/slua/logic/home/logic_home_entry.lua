local logic_home_entry = {}
local PlanPH_Mode_Config = require("GameLua.Mod.PlanPH.Gameplay.Config.PlanPH_Mode_Config")
local C_TriggerPurposeSwitchTimeOut = 20
function logic_home_entry:OnInitialize()
  log(bWriteLog and "logic_home_entry:OnInitialize")
  self.res_draft_scene = nil
  self.res_depot_bin = nil
  self.res_using_scene = nil
  self.manor_owner_id = nil
  self.mode = PlanPH_Mode_Config.EModeType.None
  self.inviter = nil
  self.ext_data = nil
  self.bIsFromMusicConsole = false
  self.reqManorInfoType = nil
  self.bReEnterGame = nil
  self.reEnterGameTS = nil
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() and PlanPH_GamePlay_Tools.IsLocalBoot() then
    self.mode = PlanPH_Mode_Config.EModeType.Visit
  end
end
function logic_home_entry:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HOME_Parking, self.EnterManorParking, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HOME_PASS, self.EnterManorPass, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, self.OnEnterGameBegin, self)
end
function logic_home_entry:OnPreSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    self:ClearMode()
  end
end
function logic_home_entry:EntryVisitHome(manor_owner_id, manor_instance_id, ext_data)
  log(bWriteLog and "logic_home_entry:EntryVisitHome manor_owner_id = " .. tostring(manor_owner_id) .. " manor_instance_id = " .. tostring(manor_instance_id))
  log_tree(bWriteLog and "logic_home_entry:EntryVisitHome ext_data", ext_data)
  local gotoFunc = function()
    log(bWriteLog and "logic_home_entry:EntryVisitHome gotoFunc")
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:CheckManorRestrict() then
      log(bWriteLog and "logic_home_entry:EntryVisitHome QRCode limit")
      return
    end
    if RoomSystem.IsShowWaiting() then
      ShowNotice(19810060)
      return
    end
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission(false) then
      ShowNotice(19810133)
      return
    end
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.EntryVisitHome) then
      return
    end
    if GameStatus.IsInFightingStatus() then
      log(bWriteLog and "logic_home_entry:EntryVisitHome in fighting")
      LobbySystem.isWaitToEnterGame = true
    end
    local logic_home_loading = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_loading)
    logic_home_loading:ReadyToCheckLoadingStuck()
    local PHomeVisitHandler = require("client.network.Protocol.PHomeVisitHandler")
    if tonumber(manor_owner_id) == tonumber(DataMgr.roleData.uid) then
      local logic_home_entrance_tips = require("client.slua.logic.home.Lobby.logic_home_entrance_tips")
      local curTipsType = logic_home_entrance_tips.GetTipsInfo(manor_owner_id)
      logic_home_entrance_tips.ProcClickTips(curTipsType)
    end
    local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
    manor_owner_id = tonumber(manor_owner_id)
    logic_home_joint:GetMemberListByUid(manor_owner_id, function(manor_id, memberList)
      if not ext_data then
        ext_data = {}
      end
      ext_data.      PHomeVisitHandler.send_visit_manor_req(manor_id, manor_instance_id, ext_data, memberList)
    end)
    self.tmp_    self.bNeedRecordEntryInfo = true
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeDownloadedDone(manor_owner_id, gotoFunc)
end
function logic_home_entry:proc_visit_manor_rsp(manor_owner_id)
  log(bWriteLog and "logic_home_entry:proc_visit_manor_rsp manor_owner_id = " .. tostring(manor_owner_id))
  self:SetManorOwnerID(manor_owner_id)
  self:SetMode(PlanPH_Mode_Config.EModeType.Visit)
  self:GetAllHomeInfoFromServer()
end
function logic_home_entry:SetManorOwnerID(manor_owner_id)
  log(bWriteLog and "[DeanJYT] logic_home_entry:SetManorOwnerID manor_owner_id = " .. tostring(manor_owner_id))
  self.end
function logic_home_entry:SetManorKeyID(manor_key_id)
  self.end
function logic_home_entry:SetManorEntryUID(entry_uid)
  self.end
function logic_home_entry:GetManorEntryUID()
  if self.entry_uid and self.entry_uid > 0 then
    return self.entry_uid
  end
  if self.tmp_manor_owner_id and 0 < self.tmp_manor_owner_id then
    return self.tmp_manor_owner_id
  end
  return self.manor_owner_id
end
function logic_home_entry:proc_enter_game(manor_data)
  log(bWriteLog and "logic_home_entry:proc_enter_game")
  self.bReEnterGame = false
  self:SetManorKeyID(manor_data.manor_owner_id)
  if not manor_data.joint_members then
    self:SetManorOwnerID(manor_data.manor_owner_id)
  else
    for uid, _ in pairs(manor_data.joint_members) do
      self:SetManorOwnerID(uid)
      break
    end
  end
end
function logic_home_entry:proc_re_enter_game(manor_data)
  log(bWriteLog and "logic_home_entry:proc_re_enter_game")
  if type(manor_data) ~= "table" then
    return
  end
  self.bReEnterGame = true
  local TimeUtil = require("client.common.time_util")
  self.reEnterGameTS = TimeUtil.GetServerTimeInSec()
  self:SetManorKeyID(manor_data.manor_owner_id)
  if not manor_data.joint_members then
    self:SetManorOwnerID(manor_data.manor_owner_id)
  else
    for uid, _ in pairs(manor_data.joint_members) do
      self:SetManorOwnerID(uid)
      break
    end
  end
end
function logic_home_entry:SetMode(mode)
  log(bWriteLog and "logic_home_entry:SetMode mode:" .. tostring(mode))
  if self.mode == mode then
    log(bWriteLog and "logic_home_entry:SetMode same mode")
    return
  end
  self.  if mode == PlanPH_Mode_Config.EModeType.Visit then
    print(bWriteLog and "logic_home_entry:SetMode Visit")
  elseif mode == PlanPH_Mode_Config.EModeType.EditHome then
    print(bWriteLog and "logic_home_entry:SetMode EditHome")
  elseif mode == PlanPH_Mode_Config.EModeType.EditPlan then
    print(bWriteLog and "logic_home_entry:SetMode EditPlan")
  else
    print(bWriteLog and "logic_home_entry:SetMode None")
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_SET_MODE)
end
function logic_home_entry:GetMode()
  return self.mode
end
function logic_home_entry:GetManorOwnerId()
  log(bWriteLog and "logic_home_entry:GetManorOwnerId manor_owner_id = " .. tostring(self.manor_owner_id))
  return self.manor_owner_id
end
function logic_home_entry:IsManorOwner(uid)
  if tonumber(uid) == self.manor_owner_id then
    return true
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, v in pairs(memberList) do
    if tonumber(uid) == tonumber(v) then
      return true
    end
  end
  return false
end
function logic_home_entry:GetMemberUid(uid)
  if tonumber(uid) == self.manor_owner_id then
    return nil
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, v in pairs(memberList) do
    if tonumber(uid) ~= tonumber(v) then
      return v
    end
  end
  return nil
end
function logic_home_entry:GetManorKey()
  log(bWriteLog and "logic_home_entry:GetManorKey manor_key_id = " .. tostring(self.manor_key_id))
  if self.manor_key_id then
    return self.manor_key_id
  elseif self.manor_owner_id then
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local homeProfile = logic_home_profile:GetHomeProfileByUid(self.manor_owner_id)
    if homeProfile and homeProfile.joint_id then
      return homeProfile.joint_id
    else
      return self.manor_owner_id
    end
  end
  return nil
end
function logic_home_entry:IsSelfOwner()
  log(bWriteLog and "logic_home_entry:IsSelfOwner manor_owner_id = " .. tostring(self.manor_owner_id))
  if not self.manor_owner_id or not DataMgr.roleData then
    log(bWriteLog and "[DeanJYT] logic_home_entry:IsSelfOwner not self.manor_owner_id or not DataMgr.roleData")
    return false
  end
  if tonumber(DataMgr.roleData.uid) == self.manor_owner_id then
    log(bWriteLog and "[DeanJYT] logic_home_entry:IsSelfOwner manor_owner_id == myUid")
    return true
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, v in pairs(memberList) do
    if tonumber(DataMgr.roleData.uid) == tonumber(v) then
      if 1 < #memberList and not logic_home_joint:HasJointHome() then
        log(bWriteLog and "logic_home_entry:IsSelfOwner home profile confict with home_joint")
        return false
      end
      log(bWriteLog and "[DeanJYT] logic_home_entry:IsSelfOwner one of the member uid == myUid")
      return true
    end
  end
  log(bWriteLog and "[DeanJYT] logic_home_entry:IsSelfOwner nothing fit")
  return false
end
function logic_home_entry:GetAllHomeInfoFromServer()
end
function logic_home_entry:GetCurHomeBaseData_Standalone()
  return self.manor_base_bindata_standalone
end
function logic_home_entry:IsPlanPHMode()
  log(bWriteLog and "logic_home_entry:IsPlanPHMode")
  if self.mode == PlanPH_Mode_Config.EModeType.Visit or self.mode == PlanPH_Mode_Config.EModeType.EditHome or self.mode == PlanPH_Mode_Config.EModeType.EditPlan then
    log(bWriteLog and "logic_home_entry:IsPlanPHMode true")
    return true
  else
    log(bWriteLog and "logic_home_entry:IsPlanPHMode false")
    return false
  end
end
function logic_home_entry:IsPlanPHVisitOrEditPlanMode()
  log(bWriteLog and "logic_home_entry:IsPlanPHVisitOrEditPlanMode")
  if self.mode == PlanPH_Mode_Config.EModeType.Visit or self.mode == PlanPH_Mode_Config.EModeType.EditPlan then
    log(bWriteLog and "logic_home_entry:IsPlanPHVisitOrEditPlanMode true")
    return true
  else
    log(bWriteLog and "logic_home_entry:IsPlanPHVisitOrEditPlanMode false")
    return false
  end
end
function logic_home_entry:IsPlanPHEditPlanMode()
  log(bWriteLog and "logic_home_entry:IsPlanPHEditPlanMode")
  if self.mode == PlanPH_Mode_Config.EModeType.EditPlan then
    log(bWriteLog and "logic_home_entry:IsPlanPHEditPlanMode true")
    return true
  else
    log(bWriteLog and "logic_home_entry:IsPlanPHEditPlanMode false")
    return false
  end
end
function logic_home_entry:ClearMode()
  log(bWriteLog and "logic_home_entry:ClearMode")
  if self.mode == PlanPH_Mode_Config.EModeType.None then
    log(bWriteLog and "logic_home_entry:ClearMode None")
    return
  end
  self.mode = PlanPH_Mode_Config.EModeType.None
  self.bReEnterGame = nil
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CLEAR_MODE)
end
function logic_home_entry:GetIsFromMusicConsole()
  return self.bIsFromMusicConsole
end
function logic_home_entry:SetIsFromMusicConsole(bIsFromMusicConsole)
  self.end
function logic_home_entry:FollowEnterManor(fri_uid, manor_owner_id, manor_inst_id)
  BattleResult.IgnoreDSError = true
  local PHomeVisitHandler = require("client.network.Protocol.PHomeVisitHandler")
  self:EntryVisitHome(manor_owner_id, manor_inst_id, {follow_friend_uid = fri_uid})
end
function logic_home_entry:ReqGetFriendManorInfo(uid, reqType)
  log(bWriteLog and "logic_home_entry:ReqGetFriendManorInfo uid :" .. uid .. " reqType: " .. reqType)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckManorRestrict() then
    log(bWriteLog and "logic_home_entry:FollowEnterManor QRCode limit")
    return
  end
  self.reqManorInfoType = reqType
  local PHomeVisitHandler = require("client.network.Protocol.PHomeVisitHandler")
  PHomeVisitHandler.send_get_friend_manor_info_req(uid)
end
function logic_home_entry:OnGetFriendManorInfoRsp(manor_owner_id, manor_inst_id)
  if manor_owner_id and manor_inst_id then
    log(bWriteLog and "logic_home_entry:OnGetFriendManorInfoRsp manor_owner_id :" .. manor_owner_id .. " manor_inst_id:" .. manor_inst_id)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_FRIEND_MANOR_INFO_RSP, self.reqManorInfoType, manor_owner_id, manor_inst_id)
  end
end
function logic_home_entry:proc_on_visit_manor_award_notify(resAwardList)
  log(bWriteLog and "logic_home_entry:proc_on_visit_manor_award_notify")
  self.end
function logic_home_entry:MarkTriggerPurposeSwitch()
  self.bHasTriggerPurposeSwitch = true
  self:AddTimerOnce(C_TriggerPurposeSwitchTimeOut, function()
    self.bHasTriggerPurposeSwitch = false
  end)
end
function logic_home_entry:IsManorOwnerFriend()
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, v in pairs(memberList) do
    if FriendSystem.IsMyFriend(tonumber(v)) then
      return true
    end
  end
  return false
end
function logic_home_entry:EnterManorParking()
  log(bWriteLog and "logic_home_entry:EnterManorParking")
  local gotoFUnc = function()
    log(bWriteLog and "logic_home_entry:EnterManorParking gotoFUnc")
    self:EntryVisitHome(DataMgr.roleData.uid)
    local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
    SceneSwitchLatenQueueSystem:EnqueueIngame(function()
      local PlanPH_Teleport_Client_Handler = require("GameLua.Mod.PlanPH.Client.Handler.PlanPH_Teleport_Client_Handler")
      PlanPH_Teleport_Client_Handler.send_teleport_by_tag_req("Parking", 20)
    end)
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, gotoFUnc)
end
function logic_home_entry:EnterManorPass(_, _, params)
  log(bWriteLog and "logic_home_entry:EnterManorPass")
  log_tree("logic_home_entry:EnterManorPass params", params)
  local gotoFunc = function()
    log(bWriteLog and "logic_home_entry:EnterManorPass gotoFunc")
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if PlanPH_GamePlay_Tools.IsPHomeMode() or params and params.from == "HomeStore" then
      local util_home_pass = require("client.slua.logic.home.CraftmanPass.util_home_pass")
      util_home_pass.ShowMainUI(params)
      return
    end
    self:EntryVisitHome(DataMgr.roleData.uid)
    local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
    SceneSwitchLatenQueueSystem:EnqueueIngame(function()
      log(bWriteLog and "logic_home_entry:EnterManorPass in game")
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeEnterSequenceTime) or {}
      local enterSequenceTime = tLocalCache.nLastPlayTime or 0
      local TimeUtil = require("client.common.time_util")
      local curTime = TimeUtil.GetServerTimeInSec()
      if curTime - enterSequenceTime < 5 and -5 < curTime - enterSequenceTime then
        log(bWriteLog and "logic_home_entry:EnterManorPass jump sequence")
        if EVENTTYPE_PLANPH_NORMAL then
          self:AddCommonEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_HOME_SKIP_OR_END_ENTER_SEQUENCE, self.EnterManorPassImpl, self)
        end
        return
      else
        self:EnterManorPassImpl()
      end
    end)
  end
  local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
  logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, gotoFunc)
end
function logic_home_entry:OnEnterGameBegin()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local manor_data = logic_enter_game.manor_data
  if manor_data then
    self:proc_enter_game(manor_data)
  end
end
function logic_home_entry:EnterManorPassImpl()
  log(bWriteLog and "logic_home_entry:EnterManorPassImpl")
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  local bFinishNewbieGuideTask = logic_home_newbieguide:IsFinishNewbieGuideTask()
  if not bFinishNewbieGuideTask then
    log(bWriteLog and "logic_home_entry:EnterManorPassImpl newbie")
    return
  end
  local util_home_pass = require("client.slua.logic.home.CraftmanPass.util_home_pass")
  util_home_pass.ShowMainUI()
  local logic_home_pass = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_pass)
  local TimeUtil = require("client.common.time_util")
  local lastPop = {
    time = TimeUtil.GetServerTimeInSec(),
    reddot = 1
  }
  if logic_home_pass:GetCurSeasonConfig() then
    lastPop.seasonID = logic_home_pass:GetCurSeasonID()
    log(bWriteLog and "logic_home_entry:EnterManorPass seasonID" .. tostring(lastPop.seasonID) .. " time" .. tostring(lastPop.time))
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(lastPop, PlayerPrefsSystem.ePlayerPrefsType.eHomeCraftmanPassPopup)
  if EVENTTYPE_PLANPH_NORMAL then
    self:RemoveCommonEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_HOME_SKIP_OR_END_ENTER_SEQUENCE)
  end
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeEnterSequenceTime) or {}
  tLocalCache.nLastPlayTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_home_entry:EnterManorPassImpl:EnterManorPassImpl tLocalCache.nLastPlayTime = " .. tostring(tLocalCache.nLastPlayTime))
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eHomeEnterSequenceTime)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_home_entry)
return CModuleTemplate
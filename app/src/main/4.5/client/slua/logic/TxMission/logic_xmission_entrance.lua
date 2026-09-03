local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local TimeUtil = require("client.common.time_util")
local logic_xmission_download = require("client.slua.logic.TxMission.logic_xmission_download")
local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
local Xmission_View_Id1 = 20000
local Xmission_View_Id2 = 20010
local logic_xmission_entrance = {}
function logic_xmission_entrance:RegistEvents()
end
function logic_xmission_entrance:OnLogin(bReLogin)
end
function logic_xmission_entrance:OnLogOut()
end
function logic_xmission_entrance:OnPreSwitchGameStatus(preState, nextState)
end
function logic_xmission_entrance:OnPostSwitchGameStatus(preState, nextState)
end
function logic_xmission_entrance:OpenTxMissionByClick()
  log(bWriteLog and "[muidarzhang] logic_xmission_entrance:OpenTxMissionByClick")
  if self:CheckCanEnterTxMission(true) then
    logic_xmission_main.SendEnterXMissionReq("jump")
  end
end
function logic_xmission_entrance:CheckCanEnterTxMission(bIsClick, fromScroll)
  if IsWoWEditor then
    return false
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log(bWriteLog and "[muidarzhang] logic_xmission_entrance:CheckCanEnterTxMission, GameStatus.GetGameStatus() == GameStatus.Fighting. ")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    log(bWriteLog and "[muidarzhang] logic_xmission_entrance:CheckCanEnterTxMission, TeamUpNewSystem.IsInLargeTeam(). ")
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    log(bWriteLog and "[muidarzhang] logic_xmission_entrance:CheckCanEnterTxMission,  logic_mode_selection:IsSelect8PlayersMode(). ")
  end
  if not self:CheckDevice() then
    log(bWriteLog and "[muidarzhang] logic_xmission_entrance:CheckCanEnterTxMission, not self:CheckDevice(). ")
    return false
  end
  if not self:IsTxMissionOpen() then
    log(bWriteLog and "[muidarzhang] LogicTxMissionDownload.CheckCanEnterTPlan, is open = false.")
    if bIsClick then
      self:PreCheckXMissionOnline()
    end
    return false
  end
  local hasDownloaded = logic_xmission_download.CheckResHasDownloaded()
  if hasDownloaded then
    if LobbySystem.isInMatch then
      ShowNotice(LocUtil.LocalizeResFormat(110017))
      log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan LobbySystem.isInMatch is true")
      return false
    end
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.mentor_prematch_state then
      ShowNotice(LocUtil.LocalizeResFormat(110017))
      log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan mentor_prematch_state is true")
      return false
    end
    if bIsClick and TeamUpNewSystem.GetTeamNum() > 1 then
      if TeamUpNewSystem.IsTeamLeader() then
        logic_xmission_main.ChangeTeamType(logic_xmission_main.E_ChangeTeamType.L2X)
        local LogicTxMissionTeam = require("client.slua.logic.TxMission.logic_xmission_team")
        LogicTxMissionTeam.changeTeamTypeFromScroll = fromScroll
      else
        ShowNotice(LocUtil.LocalizeResFormat(500062))
      end
      log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan GetTeamNum > 1")
      return false
    end
    log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan hasDownloaded is true")
    return true
  else
    log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan hasDownloaded is false")
    if logic_xmission_main.bIsReconnect and not bIsClick then
      log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan isReconnecting, exit xmission")
      logic_xmission_main.SendExitXMissionReq()
    else
      log(bWriteLog and "[edward] LogicTxMissionDownload.CheckCanEnterTPlan, open download")
      logic_xmission_download.OpenDownload()
    end
  end
  log(bWriteLog and "LogicTxMissionDownload.CheckCanEnterTPlan return false")
  return false
end
function logic_xmission_entrance:IsTxMissionOpen()
  log(bWriteLog and "logic_xmission_entrance:IsTxMissionOpen")
  local menu = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_TXMISSION, false)
  if not menu then
    log(bWriteLog and "logic_xmission_entrance:IsTxMissionOpen lobby switch not open")
    return false
  end
  local bHasActivity = self:CheckTxMissionOnline()
  if not bHasActivity then
    log(bWriteLog and "logic_xmission_entrance:IsTxMissionOpen no activity")
    return false
  end
  return true
end
function logic_xmission_entrance:GetTxMissionActivityInfo()
  log(bWriteLog and "logic_xmission_entrance:GetTxMissionActivityInfo")
  local ActivityInfoList = ActivityNewSystem.GetActivityListByType(ActivityType.T_PLAN_DOWNLOAD)
  log_tree("ActivityInfoList = ", ActivityInfoList)
  if not ActivityInfoList or not next(ActivityInfoList) then
    if ActivityNewSystem.activityDataTable and next(ActivityNewSystem.activityDataTable) then
      log(bWriteLog and "logic_xmission_entrance:GetTxMissionActivityInfo 1")
      return nil, true
    else
      log(bWriteLog and "logic_xmission_entrance:GetTxMissionActivityInfo 2")
      return nil, false
    end
  end
  local nowSvr = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(ActivityInfoList) do
    log(bWriteLog and string.format("[muidarzhang] logic_xmission_entrance:GetTxMissionActivityInfo, nowSvr:%s", nowSvr))
    if (tonumber(v.EndTime) == 0 or nowSvr < tonumber(v.EndTime) and nowSvr >= tonumber(v.StartTime)) and v.List and v.List[1] and v.List[1].Condition and v.List[1].Condition[1] and tonumber(v.List[1].Condition[1]) ~= 0 then
      log(bWriteLog and "[muidarzhang] logic_xmission_entrance:GetTxMissionActivityInfo, return v, true. ")
      return v, true
    end
  end
  log(bWriteLog and "[muidarzhang] logic_xmission_entrance:GetTxMissionActivityInfo, return nil, true. ")
  return nil, true
end
function logic_xmission_entrance:CheckDevice()
  return true
end
function logic_xmission_entrance:CheckTxMissionOnline()
  log(bWriteLog and "logic_xmission_entrance:CheckTxMissionOnline CheckTxMissionOnline")
  if self.bSkipActivityOnline then
    log(bWriteLog and "logic_xmission_entrance:CheckTxMissionOnline CheckTxMissionOnline skip")
    return true
  end
  local activity, bDataInit = self:GetTxMissionActivityInfo()
  log_tree("activity = ", activity)
  log_tree("bDataInit = ", bDataInit)
  if not bDataInit then
    return true
  end
  if activity then
    return true
  end
  return false
end
function logic_xmission_entrance:SkipActivityInfoConfig()
  self.bSkipActivityOnline = true
end
function logic_xmission_entrance:PreCheckXMissionOnline()
  log(bWriteLog and "[muidarzhang] logic_xmission_entrance:PreCheckXMissionOnline")
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_info_req()
end
function logic_xmission_entrance:PreCheckXMissionOnlineCallback()
  log(bWriteLog and "[muidarzhang] logic_xmission_entrance:PreCheckXMissionOnlineCallback")
  if not self:IsTxMissionOpen() then
    ShowNotice(100250001)
    local ActivityHandler = require("client.network.Protocol.ActivityHandler")
    ActivityHandler.bIsReGetActivityList = true
    ActivityHandler.bIsReGetDisplay = true
    ActivityHandler.send_get_activity_list_req()
  end
end
function logic_xmission_entrance:CheckCanButtonClick()
  if not self:IsTxMissionOpen() then
    ShowNotice(100250001)
    return false
  end
  local logic_xmission_room = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room)
  if logic_xmission_room:IsSelfPrepare() then
    return false
  end
  return true
end
function logic_xmission_entrance:CheckPlayerLevelEnough()
  local level = self:GetXmissionReqLevel()
  if level > DataMgr.roleData.level then
    ShowNotice(LocUtil.LocalizeResFormat(31028, level))
    return false
  end
  return true
end
function logic_xmission_entrance:GetXmissionReqLevel()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local data = logic_mode_selection:GetSubviewInfoBySubviewID(Xmission_View_Id1)
  if data and data.level_limit then
    return data.level_limit
  end
  local data = logic_mode_selection:GetSubviewInfoBySubviewID(Xmission_View_Id2)
  if data and data.level_limit then
    return data.level_limit
  end
  return 5
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_entrance = class(CModuleBase, nil, logic_xmission_entrance)
return Clogic_xmission_entrance
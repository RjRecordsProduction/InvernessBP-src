local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
local logic_main_city_join = {}
function logic_main_city_join:DefineAndResetData()
  self.lastNotifyTeamTime = 0
  self.team_main_city_info = nil
  self.teammate_city_info = {}
end
function logic_main_city_join:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_GO_TO_TEAMMATE_MAIN_CITY_POPUP, self.TryShowInviteTips, self)
end
function logic_main_city_join:GetTeamTarget()
  return self.team_main_city_info
end
function logic_main_city_join:OnPostSwitchGameStatus(preState, nextState)
  if not GameStatus.IsInLobbyOrMainCity(preState, nextState) then
    self.team_main_city_info = nil
  end
end
function logic_main_city_join:SetIgnoreTeamNotify()
  local TimeUtil = require("client.common.time_util")
  self.ignoreTime = TimeUtil.GetServerTimeInSec()
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  LogicPlayerPrefs.SaveDataToFile_N({
    ignoreTime = self.ignoreTime
  }, PlayerPrefsConfig.eMainCityInvite)
end
function logic_main_city_join:OnTeamInfoSync(type, game_info)
  if self._teamSyncTimer then
    self:RemoveTimer(self._teamSyncTimer)
  end
  if not game_info then
    return
  end
  if game_info.uid then
    self.teammate_city_info[game_info.uid] = game_info
  end
  if game_info.cur_main_city_in_3d ~= true then
    return
  end
  if type ~= 29 then
    return
  end
  self._teamSyncTimer = self:AddTimer(5, function()
    self._teamSyncTimer = nil
    self:SetTeamMainCityInfo(game_info)
    local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
    logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_GO_TO_TEAMMATE_MAIN_CITY_POPUP)
  end)
end
function logic_main_city_join:SetTeamMainCityInfo(game_info)
  self.team_main_city_info = game_info
  log_tree("logic_main_city_join:SetTeamMainCityInfo team_main_city_info = ", self.team_main_city_info)
end
function logic_main_city_join:RealDoTeamInfoSync()
  log(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync team_main_city_info = " .. tostring(self.team_main_city_info))
  if IsWoWEditor then
    return
  end
  if not self.team_main_city_info then
    return
  end
  local game_info = self.team_main_city_info
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if serverTime - self.lastNotifyTeamTime < 600 then
    log_warning(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync is in cd time")
    return
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bIsInSocialIsland = PlanPH_GamePlay_Tools and PlanPH_GamePlay_Tools.IsSocialIslandMode()
  if not GameStatus.IsInLobbyOrMainCity() and not bIsInSocialIsland then
    log_warning(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync is not in target lobby type")
    return
  end
  if g_game_id and g_game_id == game_info.room_id then
    log_warning(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync is in target main city")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() < 2 then
    log_warning(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync is single")
    return
  end
  local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
  local clickOKCallback = function()
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    if not main_city_process_util.IsMainCityEntryOpen(true) then
      log_warning(bWriteLog and "logic_main_city_join:RealDoTeamInfoSync clickOKCallback main city entry is closed")
      return
    end
    if GameStatus.IsInMainCity() then
      logic_main_city_enter_report.SetReportData("SwitchIntoMainCity", "EnterMCFromAnotherMC", "TeamGuildIntoMC")
    else
      logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "TeamGuildIntoMC")
    end
    local MainCityMatchConfig = require("GameLua.Mod.MainCity.Client.Config.MainCityMatchConfig")
    local main_city_switch_util = require("GameLua.Mod.MainCity.Client.logic.Process.Transfer.main_city_switch_util")
    main_city_switch_util.ReqEnterMainCityByMainCityInfo(game_info, MainCityMatchConfig.Enum_Match_From.Team_Notify)
  end
  logic_main_city_enter_report.SetPopUpType(logic_main_city_enter_report.PopUpEnterReasonList.TeamGuild)
  UIManager.ShowUI(UIManager.UI_Config.MainCity_Invite_Tips_UIBP, game_info.uid, clickOKCallback, {bIsShowIgnore = true})
  self.lastNotifyTeamTime = serverTime
end
function logic_main_city_join:TryShowInviteTips()
  log(bWriteLog and "logic_main_city_join:TryShowInviteTips")
  self:RealDoTeamInfoSync()
end
function logic_main_city_join:on_main_city_invite_notify(inviter_uid, main_city_info)
  if IsWoWEditor then
    return
  end
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local tb = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eMainCityInvite)
  if tb and tb.ignoreTime then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if curTime - tb.ignoreTime < 604800 then
      return
    end
  end
  local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
  log(bWriteLog and "logic_main_city_join:on_main_city_invite_notify IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
  if not IsInLobbyOrMainCity then
    return
  end
  local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
  local clickOKCallback = function()
    log(bWriteLog and bWritleLog and "logic_main_city_join:on_main_city_invite_notify friend ok ")
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    if not main_city_process_util.IsMainCityEntryOpen(true, true) then
      return false
    end
    if GameStatus.IsInMainCity() then
      logic_main_city_enter_report.SetReportData("SwitchIntoMainCity", "EnterMCFromAnotherMC", "OtherPlayerInviteIntoMC")
    else
      logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "OtherPlayerInviteIntoMC")
    end
    local MainCityMatchConfig = require("GameLua.Mod.MainCity.Client.Config.MainCityMatchConfig")
    local main_city_switch_util = require("GameLua.Mod.MainCity.Client.logic.Process.Transfer.main_city_switch_util")
    main_city_switch_util.ReqEnterMainCityByMainCityInfo(main_city_info, MainCityMatchConfig.Enum_Match_From.Friend)
  end
  logic_main_city_enter_report.SetPopUpType(logic_main_city_enter_report.PopUpEnterReasonList.FriendInvite)
  UIManager.ShowUI(UIManager.UI_Config.MainCity_Invite_Tips_UIBP, inviter_uid, clickOKCallback, {textID = 656115, bIsShowIgnore = true})
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_main_city_join)
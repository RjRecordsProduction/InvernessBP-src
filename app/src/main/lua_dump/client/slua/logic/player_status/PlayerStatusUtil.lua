local PlayerStatusUtil = {}
local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
function PlayerStatusUtil.IsIdle(status)
  if not status then
    log_error("PlayerStatusUtil.IsIdle status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Idle
end
function PlayerStatusUtil.IsFree(status)
  if not status then
    log_error("PlayerStatusUtil.IsFree status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Free
end
function PlayerStatusUtil.IsIdleOrFree(status)
  if not status then
    log_error("PlayerStatusUtil.IsFree status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Free or status.teamState == PlayerStatusEnum.Enum_TeamState.Idle
end
function PlayerStatusUtil.IsTeam(status)
  if not status then
    log_error("PlayerStatusUtil.IsTeam status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Team
end
function PlayerStatusUtil.IsIdleOrTeam(status)
  if not status then
    log_error("PlayerStatusUtil.IsIdleOrTeam status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Team or status.teamState == PlayerStatusEnum.Enum_TeamState.Idle
end
function PlayerStatusUtil.IsBattle(status)
  if not status then
    log_error("PlayerStatusUtil.IsBattle status = nil")
    return false
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Battle
end
function PlayerStatusUtil.IsRoom(status)
  if not status then
    log_error("PlayerStatusUtil.IsRoom status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Room
end
function PlayerStatusUtil.IsWatch(status)
  if not status then
    log_error("PlayerStatusUtil.IsWatch status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Watch
end
function PlayerStatusUtil.IsBusy(status)
  if not status then
    log_error("PlayerStatusUtil.IsBusy status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Busy
end
function PlayerStatusUtil.IsDoNotBother(status)
  if not status then
    log_error("PlayerStatusUtil.IsDoNotBother status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.doNotBother
end
function PlayerStatusUtil.IsStealth(status)
  if not status then
    log_error("PlayerStatusUtil.IsStealth status = nil")
    return
  end
  return status.teamState == PlayerStatusEnum.Enum_TeamState.Stealth
end
function PlayerStatusUtil.HandleCommonStatusInfo(status)
  if PlayerStatusUtil.IsStealth(status) then
    status.online = 0
  end
  local isInbattle = PlayerStatusUtil.IsBattle(status)
  if isInbattle and status.gameBeginTime then
    return
  end
  local timeSinceGameBegin = status.timeSinceGameBegin or 0
  if isInbattle or 0 < timeSinceGameBegin then
    local TimeUtil = require("client.common.time_util")
    status.gameBeginTime = TimeUtil.GetServerTimeInSec() - timeSinceGameBegin
  else
    status.gameBeginTime = nil
  end
end
local _IsIdleStatus = function(status)
  return status and status.currentTeamAmount and status.currentTeamAmount <= 1
end
local _IsTeamStatus = function(status)
  return status and status.currentTeamAmount and status.currentTeamAmount > 1
end
function PlayerStatusUtil.IsCanWatch(status)
  log(bWriteLog and "PlayerStatusUtil.IsCanWatch")
  log_tree(bWriteLog and "PlayerStatusUtil.IsCanWatch status = ", status)
  if not status then
    log(bWriteLog and "PlayerStatusUtil.IsCanWatch status = nil")
    return false
  end
  local game_mode = status.game_mode
  if not game_mode then
    log(bWriteLog and "PlayerStatusUtil.IsCanWatch game_mode = nil")
    return false
  end
  local cfg = CDataTable.GetTableData("MatchModeTable", game_mode)
  log_tree(bWriteLog and "PlayerStatusUtil.IsCanWatch cfg = ", cfg)
  if not cfg then
    log(bWriteLog and "PlayerStatusUtil.IsCanWatch cfg = nil")
    return false
  end
  local MaxWatchNum = cfg.MaxWatchNum
  log(bWriteLog and "PlayerStatusUtil.IsCanWatch MaxWatchNum = ", MaxWatchNum)
  if MaxWatchNum == 0 then
    return false
  end
  return true
end
function PlayerStatusUtil.IsIsland(status)
  return status and status.socialland_type ~= 0
end
function PlayerStatusUtil.ISLANDIdle(status)
  return PlayerStatusUtil.IsIsland(status) and _IsIdleStatus(status)
end
function PlayerStatusUtil.ISLANDInTeam(status)
  return PlayerStatusUtil.IsIsland(status) and _IsTeamStatus(status)
end
function PlayerStatusUtil.IsTPlan(status)
  return status and status.tplan_type and status.tplan_type ~= 0
end
function PlayerStatusUtil.TPlanIdle(status)
  return PlayerStatusUtil.IsTPlan(status)
end
function PlayerStatusUtil.TPlanInTeam(status)
  return PlayerStatusUtil.IsTPlan() and _IsTeamStatus(status)
end
function PlayerStatusUtil.InWoW(status)
  return status and status.cwow_type and status.cwow_type ~= 0
end
function PlayerStatusUtil.WoWIdle(status)
  return PlayerStatusUtil.InWoW(status) and _IsIdleStatus(status)
end
function PlayerStatusUtil.WoWInTeam(status)
  return PlayerStatusUtil.InWoW(status) and _IsTeamStatus(status)
end
function PlayerStatusUtil.InHall(status)
  return status.is_in_hall
end
function PlayerStatusUtil.IsFreeInOut(freeInOutValue)
  return freeInOutValue and 0 < freeInOutValue
end
function PlayerStatusUtil.CheckCanJoinFriendGame(status, callback)
  local FailReason = PlayerStatusEnum.Enum_FreeInOutFailReason
  if not status or not callback then
    if callback then
      callback(false, nil, false, FailReason.NoStatus)
    end
    return
  end
  if not PlayerStatusUtil.IsBattle(status) then
    callback(false, nil, false, FailReason.NotBattle)
    return
  end
  local mod_id = status.mod_id
  if not mod_id or mod_id <= 0 then
    callback(false, nil, false, FailReason.NoMod)
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:GetModInfoById(mod_id, function(pub_mod_meta)
    if not (pub_mod_meta and pub_mod_meta.setting) or not PlayerStatusUtil.IsFreeInOut(pub_mod_meta.setting.free_inout) then
      callback(false, nil, false, FailReason.NotFreeInOut)
      return
    end
    local Logic_UGC_Res_Manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    if Logic_UGC_Res_Manager and next(pub_mod_meta or {}) then
      local bIsComplete = Logic_UGC_Res_Manager:IsCompleteRes(Logic_UGC_Res_Manager.DownloaderType.ModCopy, pub_mod_meta)
      if not bIsComplete then
        callback(true, pub_mod_meta, true)
        return
      end
    end
    callback(true, pub_mod_meta, false)
  end)
end
function PlayerStatusUtil.IsInHome(status)
  if not status then
    return false
  end
  local logic_home_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_status)
  return logic_home_status:IsHomeVisitMode(status.game_sub_mode)
end
function PlayerStatusUtil.IsInHomeIdle(status)
  return PlayerStatusUtil.IsInHome(status) and _IsIdleStatus(status)
end
function PlayerStatusUtil.IsInHomeTeam(status)
  return PlayerStatusUtil.IsInHome(status) and _IsTeamStatus(status)
end
function PlayerStatusUtil.IsMainCity(status)
  return status and status.game_mode == 26000
end
function PlayerStatusUtil.IsMainCityIdle(status)
  return PlayerStatusUtil.IsMainCity(status) and _IsIdleStatus(status)
end
function PlayerStatusUtil.IsMainCityTeam(status)
  return PlayerStatusUtil.IsMainCity(status) and _IsTeamStatus(status)
end
function PlayerStatusUtil.IsSingleTraining(status)
  local result = status and status.game_mode == 501 and status.game_sub_mode == 10080
  return result
end
function PlayerStatusUtil.IsInCollectionHall(status)
  if not status then
    return false
  end
  local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
  local isInCollection = Logic_PlanCHMacros.CollectionHall_SubMode.Visit == status.game_sub_mode
  return isInCollection
end
return PlayerStatusUtil
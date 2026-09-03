GameStatus = GameStatus or {
  Login = "Login",
  Createrole = "CreateRole",
  Lobby = "Lobby",
  Fighting = "Fighting",
  Loading = "Loading",
  None = "None"
}
local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
local local combatActive = false
local _cacheGameStatus = GameStatus.None
local _lastGameStatus = GameStatus.None
local _isSupportDownload = true
local bIsHomeMode = false
local bIsSocialIslandMode = false
local bIsCollectionHallMode = false
function GameStatus.GetGameStatus()
  return _cacheGameStatus or "None"
end
function GameStatus.CacheGameStatus(status, lastStatus)
  _lastGameStatus = lastStatus or _lastGameStatus
  _cacheGameStatus = status or _cacheGameStatus
  MainCity_GamePlay_Tools.InvalidateCurrStateCache()
  print(bWriteLog and string.format("GameStatus.CacheGameStatus curState: %s lastState: %s", _cacheGameStatus, _lastGameStatus))
  GameStatus._UpdateSupportDownload()
  log_format("GameStatus.CacheGameStatus. _isSupportDownload=%s", _isSupportDownload)
end
function GameStatus.GetLastGameStatus()
  return _lastGameStatus
end
function GameStatus.SetCombatActiveState(bCombatActiveState)
  if GameStatus.GetGameStatus() == GameStatus.Fighting then
    combatActive = bCombatActiveState
    local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
    ReportPlatformCrashKit:SwitchLuaErrorTrace()
  end
  log_shipping_client("HUD.SetCombatActiveState:" .. tostring(bCombatActiveState) .. " GameState:" .. GameStatus.GetGameStatus())
end
function GameStatus.InCombatActiveState()
  return combatActive
end
function GameStatus.SwitchToLobbyState()
  log(bWriteLog and "SwitchToLobbyState")
  slua_GameFrontendHUD:SwitchGameStatus("Lobby", "")
end
function GameStatus.SwitchToCreateRoleState()
  log(bWriteLog and "SwitchToCreateRoleState")
  slua_GameFrontendHUD:SwitchGameStatus("CreateRole", "")
end
function GameStatus.SwitchToLoginState()
  log(bWriteLog and "SwitchToLoginState")
  slua_GameFrontendHUD:SwitchGameStatus("Login", "")
end
function GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState)
  local bEnterMainCity = main_city_process_util.CheckEnterMainCityFromFighting()
  local returnToLobby = not bEnterMainCity and preState == GameStatus.Fighting and nextState == GameStatus.Lobby
  if returnToLobby then
    return true
  end
  local returnToMainCity = bEnterMainCity and preState == GameStatus.Lobby and nextState == GameStatus.Fighting and GameStatus.IsInMainCity()
  if returnToMainCity then
    return true
  end
  return false
end
function GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState)
  if nextState ~= GameStatus.Fighting then
    return false
  end
  if preState == GameStatus.Lobby then
    return true
  end
  local inMainCity = GameStatus.IsInMainCity()
  local needReturnToMainCity = main_city_process_util.CheckEnterMainCityFromFighting()
  if needReturnToMainCity and not inMainCity then
    return true
  end
  if not inMainCity then
    return true
  end
  return false
end
function GameStatus.QuitGame()
  log(bWriteLog and "GameStatus.QuitGame")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  uGameInstance:QuitGame()
end
function GameStatus.SetSubMode(sub_mode)
  local home_macros = require("client.slua.logic.home.home_macros")
  bIsHomeMode = sub_mode == home_macros.Home_SubMode.Visit
  local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
  bIsCollectionHallMode = sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit
end
function GameStatus.SetMatchInGameModeID(modeID)
  local BTMode = CDataTable.GetTableData("BTMode", modeID or 0)
  bIsSocialIslandMode = BTMode and BTMode.ModeFightType and BTMode.ModeFightType == MatchModeMgrSystem.E_ModeFightType.Social
end
function GameStatus.IsIn2DLobby()
  if GameStatus.IsInMainCity() then
    return false
  end
  if GameStatus.GetGameStatus() == GameStatus.Lobby then
    return true
  end
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if Lobby_Main_UIBP then
    return true
  end
  return false
end
function GameStatus.IsInMainCity()
  if Client then
    return Lobby_Main_City_Enter.bInMainCity
  else
    return CGameState and CGameState.bMainCityGameMode
  end
end
function GameStatus.IsInLobbyOrMainCity()
  local mcState = MainCity_GamePlay_Tools.GetCurrState()
  if mcState == main_city_config.ESceneType.MainCity then
    return true
  end
  if mcState == main_city_config.ESceneType.Lobby then
    return true
  end
  return false
end
function GameStatus.IsInMainCityConnectDs()
  local mcState = MainCity_GamePlay_Tools.GetCurrState()
  if mcState == main_city_config.ESceneType.MainCity then
    return true
  end
  if mcState == main_city_config.ESceneType.Lobby then
    return Lobby_Main_City_Enter.bConnectDS
  end
  return false
end
function GameStatus.IsPHomeMode(bCheckStatus)
  if bCheckStatus and not GameStatus.IsInFightingStatus() then
    return false
  end
  if IsEditor and slua.isValid(CGameState) and CGameState.bPlanPHGameMode == true then
    return true
  end
  return bIsHomeMode
end
function GameStatus.IsSocialIslandMode()
  if IsEditor and slua.isValid(CGameState) and CGameState.bSocialIslandGameMode == true then
    return true
  end
  return bIsSocialIslandMode
end
function GameStatus.IsCollectionHallMode(bIsGameStatusInFighting)
  if type(bIsGameStatusInFighting) == "nil" then
    if not GameStatus.IsInFightingStatus() then
      return false
    end
  elseif not bIsGameStatusInFighting then
    return false
  end
  if IsEditor and slua.isValid(CGameState) and CGameState.bPlanCHGameMode == true then
    return true
  end
  if GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return bIsCollectionHallMode
end
function GameStatus.IsInLobbyOrSpecialFighting()
  local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
  if not bIsInFightingStatus then
    return true
  end
  if GameStatus.IsInLobbyOrMainCity() then
    return true
  end
  if GameStatus.IsPHomeMode() then
    return true
  end
  if GameStatus.IsCollectionHallMode() then
    return true
  end
  if GameStatus.IsSocialIslandMode() then
    return true
  end
  return false
end
function GameStatus.IsInFightingStatus()
  return GameStatus.GetGameStatus() == GameStatus.Fighting
end
function GameStatus.IsInFightingNotMainCity()
  if GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  return GameStatus.GetGameStatus() == GameStatus.Fighting
end
function GameStatus.IsInFightingNotSocialNotMainCityNotHome()
  local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
  if not bIsInFightingStatus then
    return false
  end
  if GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  if GameStatus.IsPHomeMode() then
    return false
  end
  if GameStatus.IsCollectionHallMode() then
    return false
  end
  if GameStatus.IsSocialIslandMode() then
    return false
  end
  return bIsInFightingStatus
end
function GameStatus.InSupportDownloadState(refresh)
  if refresh then
    GameStatus._UpdateSupportDownload()
    log_format("GameStatus.InSupportDownloadState. _isSupportDownload=%s", _isSupportDownload)
  end
  return _isSupportDownload
end
function GameStatus._UpdateSupportDownload()
  local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
  if not bIsInFightingStatus then
    _isSupportDownload = true
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    _isSupportDownload = true
    return
  end
  if GameStatus.IsPHomeMode() then
    _isSupportDownload = true
    return
  end
  if GameStatus.IsCollectionHallMode() then
    _isSupportDownload = true
    return
  end
  _isSupportDownload = false
end
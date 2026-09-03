local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ASTExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
local FormatLog = FuncUtil.FormatLog
local SecurityClientUtils = {}
function SecurityClientUtils.GetMyPlayerState()
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    FormatLog("invalid uMyController")
    return nil
  end
  return uMyController.PlayerState
end
function SecurityClientUtils.GetMyCharacter()
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    FormatLog("invalid uMyController")
    return nil
  end
  return uMyController:GetPlayerCharacterSafety()
end
function SecurityClientUtils.HasOtherTeammateOffline()
  local uMyPlayerState = SecurityClientUtils.GetMyPlayerState()
  if not Game:IsClassOf(uMyPlayerState, ASTExtraPlayerState) then
    FormatLog("invalid uMyPlayerState")
    return false
  end
  local uTeammatePlayerStateArray = uMyPlayerState:GetTeamMatePlayerStateList({}, false)
  for nInTeamIndex, uTeammatePlaystate in pairs(uTeammatePlayerStateArray) do
    if Game:IsClassOf(uTeammatePlaystate, ASTExtraPlayerState) and uTeammatePlaystate ~= uMyPlayerState then
      local bIsOffline = uTeammatePlaystate.isLostConnection
      if nInTeamIndex < uMyPlayerState.TeamMatesExitState:Num() and uMyPlayerState.TeamMatesExitState:Get(nInTeamIndex) == 1 then
        bIsOffline = true
      end
      if bIsOffline then
        FormatLog("found, sPlayerUID=%s, sPlayerName=%s", uTeammatePlaystate.PlayerUID, uTeammatePlaystate.PlayerName)
        return true
      end
    end
  end
  return false
end
function SecurityClientUtils.HasOtherHealthyOnlineTeammate()
  local uMyPlayerState = SecurityClientUtils.GetMyPlayerState()
  if not Game:IsClassOf(uMyPlayerState, ASTExtraPlayerState) then
    FormatLog("invalid uMyPlayerState")
    return false
  end
  local uTeammatePlayerStateArray = uMyPlayerState:GetTeamMatePlayerStateList({}, false)
  for nInTeamIndex, uTeammatePlaystate in pairs(uTeammatePlayerStateArray) do
    if Game:IsClassOf(uTeammatePlaystate, ASTExtraPlayerState) and uTeammatePlaystate ~= uMyPlayerState then
      local bIsOffline = uTeammatePlaystate.isLostConnection
      if nInTeamIndex < uMyPlayerState.TeamMatesExitState:Num() and uMyPlayerState.TeamMatesExitState:Get(nInTeamIndex) == 1 then
        bIsOffline = true
      end
      if not bIsOffline then
        local uTeammateCharacter = uTeammatePlaystate:GetPlayerCharacter()
        if Game:IsClassOf(uTeammateCharacter, ASTExtraBaseCharacter) and SecurityCommonUtils.IsHealthStatusHealthy(uTeammateCharacter.HealthStatus) then
          FormatLog("found, sPlayerUID=%s, sPlayerName=%s", uTeammatePlaystate.PlayerUID, uTeammatePlaystate.PlayerName)
          return true
        end
      end
    end
  end
  return false
end
function SecurityClientUtils.GetMyHealthStatus()
  local uMyCharacter = SecurityClientUtils.GetMyCharacter()
  if not Game:IsClassOf(uMyCharacter, ASTExtraBaseCharacter) then
    FormatLog("invalid uMyCharacter")
    return -1
  end
  local nMyHealthStatus = uMyCharacter.HealthStatus
  FormatLog("%s", nMyHealthStatus)
  return nMyHealthStatus
end
function SecurityClientUtils.IsMyHealthStatusHealthy()
  return SecurityCommonUtils.IsHealthStatusHealthy(SecurityClientUtils.GetMyHealthStatus())
end
function SecurityClientUtils.IsMyHealthStatusAlive()
  return SecurityCommonUtils.IsHealthStatusAlive(SecurityClientUtils.GetMyHealthStatus())
end
function SecurityClientUtils.GetInBattleSubModeID()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  return tonumber(logic_enter_game:GetSubModeId()) or -1
end
function SecurityClientUtils.GetInBattleMapID()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local game_mode = logic_enter_game:GetSubModeId()
  if tonumber(game_mode) then
    local uBTMode = CDataTable.GetTableData("BTMode", tonumber(game_mode))
    if uBTMode and tonumber(uBTMode.MapID) then
      return tonumber(uBTMode.MapID)
    end
  end
  return -1
end
function SecurityClientUtils.GetInBattleBattleID()
  if not SecurityCommonUtils.IsNumber(g_game_id) then
    return -1
  end
  return g_game_id
end
return SecurityClientUtils
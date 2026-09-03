local MapUIUtils = {}
local EGameModeType = import("EGameModeType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UKismetMathLibrary = import("/Script/Engine.KismetMathLibrary")
local slua_isValid = slua.isValid
function MapUIUtils.CheckIsShowAirLine(StartLoc, EndLoc, IsDraw, bCheckPostion)
  if not IsDraw then
    return false
  elseif UKismetMathLibrary.EqualEqual_VectorVector(StartLoc, EndLoc, 0.001) and bCheckPostion then
    return false
  else
    return true
  end
end
function MapUIUtils.GetTeamMateAreaID(Index)
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) then
    local TeamMatePlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, false)
    if not TeamMatePlayerStateList or Index < 0 or Index >= TeamMatePlayerStateList:Num() then
      return 0
    end
    local TeamMateState = TeamMatePlayerStateList:Get(Index)
    if slua_isValid(TeamMateState) and TeamMateState.GetPlayerCharacter then
      local TeamMateCharacter = TeamMateState:GetPlayerCharacter()
      if slua_isValid(TeamMateCharacter) and TeamMateCharacter.GetAttrValue then
        local TeamMateAreaID = TeamMateCharacter:GetAttrValue("MapID")
        return TeamMateAreaID
      end
    end
  end
  return 0
end
function MapUIUtils.GetCurAreaID()
  local CurAreaID = ""
  local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
  if MapIconSubsystem then
    CurAreaID = MapIconSubsystem:GetAreaID()
  end
  if CurAreaID == "" then
    CurAreaID = 0
  else
    CurAreaID = tonumber(CurAreaID)
  end
  return CurAreaID
end
function MapUIUtils.GetTeamMateListFromPlayerState(bExcludeSelf)
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) and PlayerState.GetTeamMatePlayerStateList then
    local TeamMateList = PlayerState:GetTeamMatePlayerStateList({}, bExcludeSelf)
    return TeamMateList
  end
  return nil
end
function MapUIUtils.IsVehicleWarMode()
  local GameState = GameplayData.GetGameState()
  return slua_isValid(GameState) and (GameState.GameModeType == EGameModeType.EVehicleWar_CAMP or GameState.GameModeType == EGameModeType.EVehicleWar)
end
function MapUIUtils.IsInfectMode()
  local GameState = GameplayData.GetGameState()
  if not slua_isValid(GameState) then
    return false
  end
  if GameState.GameModeType == EGameModeType.EPVEInfectionGameMode then
    return true
  else
    return false
  end
end
function MapUIUtils.IsActivityGameMode()
  local GameState = GameplayData.GetGameState()
  if not slua_isValid(GameState) then
    return false
  end
  if GameState.GameModeType == EGameModeType.EActivityGameMode then
    return true
  else
    return false
  end
end
function MapUIUtils.GetLocalPlayerState()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua_isValid(PlayerController) then
    return
  end
  local PS = PlayerController.PlayerState
  if slua_isValid(PS) and PS.ShowingMapTags then
    return PS
  end
  local CurPlayerState = PlayerController:GetCurPlayerState()
  return CurPlayerState
end
return MapUIUtils
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local EPawnState = import("EPawnState")
local GodTrialGameplayUtil = {}
local DefaultAllowedPawnStates = {
  EPawnState.Stand,
  EPawnState.Crouch,
  EPawnState.Prone
}
local IsAllowedPawnState = function(AllowedPawnStates, PawnState)
  for _, AllowedState in pairs(AllowedPawnStates) do
    if PawnState == AllowedState then
      return true
    end
  end
  return false
end
function GodTrialGameplayUtil.IsPawnStateValid(PlayerCharacter, AllowedPawnStates)
  local AllowedPawnStates = AllowedPawnStates or DefaultAllowedPawnStates
  for PawnState = 0, EPawnState.__MAX do
    if PlayerCharacter:HasState(PawnState) and not IsAllowedPawnState(AllowedPawnStates, PawnState) then
      print(bWriteLog and string.format("GodTrialGameplayUtil:IsPawnStateValid PawnState %s INVALID", PawnState))
      return false
    end
  end
  return true
end
local TrySetMiniMapLockTarget = function(MapUI, LockTargetLocation)
  if MapUI.TrySetMiniMapLockTarget then
    MapUI:TrySetMiniMapLockTarget(LockTargetLocation)
    return
  end
  if MapUI.SetTargetPosition and MapUI.SetMiniMapState then
    if LockTargetLocation ~= nil then
      MapUI:SetTargetPosition(LockTargetLocation)
      MapUI:SetMiniMapState(false, true)
    else
      MapUI:SetMiniMapState(false, false)
    end
  end
end
function GodTrialGameplayUtil.UpdateMapUIPlayerCurLocation(MapUI, CurLoc, uUpdatingPlayerState, Which, bDebug)
  if not (slua.isValid(MapUI.CurrentMapData_BP) and slua.isValid(MapUI.CurrentMapData_BP.CurrentMapData)) or not slua.isValid(uUpdatingPlayerState) then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uCurPlayerState = uPlayerController:GetCurPlayerState()
  if not slua.isValid(uCurPlayerState) then
    return
  end
  if not uUpdatingPlayerState.IsInParkourDungeon or not uUpdatingPlayerState:IsInParkourDungeon() then
    if uCurPlayerState == uUpdatingPlayerState then
      TrySetMiniMapLockTarget(MapUI, nil)
    end
    return
  end
  if uUpdatingPlayerState.LockMapLocation and not uUpdatingPlayerState.LockMapLocation:IsNearlyZero(0.01) then
    local MapData = MapUI.CurrentMapData_BP.CurrentMapData
    if bDebug then
      print(bWriteLog and string.format("GodTrialGameplayUtil.UpdateMapUIPlayerCurLocation %s LockMapLocation = %s, curLoc = %s", Which, uUpdatingPlayerState.LockMapLocation:ToString(), CurLoc:ToString()))
    end
    MapData.PlayerLocOffset = uUpdatingPlayerState.LockMapLocation - CurLoc
    if uCurPlayerState == uUpdatingPlayerState then
      MapUI.CurrentMapUI.bNeedDrawSelfGuideLineC = false
      TrySetMiniMapLockTarget(MapUI, uUpdatingPlayerState.LockMapLocation)
    end
  end
end
return GodTrialGameplayUtil
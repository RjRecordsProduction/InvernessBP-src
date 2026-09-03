local ASTExtraPlayerState = import("/Script/ShadowTrackerExtra.STExtraPlayerState")
local InGameMarkTools = {NavegatorMarkInstID = 0}
local UEmums_EMarkDispatchRange = {
  MAMDT_OWNER_ONLY = 0,
  EMAMDT_TEAMMATE = 1,
  EMAMDT_ENEMIES = 2,
  EMAMDT_TEAMMATE_RANGED = 3,
  EMAMDT_ENEMIES_RANGED = 4,
  EMAMDT_ALL_RANGED = 5,
  EMAMDT_ALL = 6,
  EMAMDT_CAMP = 7,
  EMAMDT_CAMP_EXCLUDE_TEAMMATE = 8
}
local GroupMarkType = {
  [UEmums_EMarkDispatchRange.EMAMDT_TEAMMATE] = true,
  [UEmums_EMarkDispatchRange.EMAMDT_ENEMIES] = true,
  [UEmums_EMarkDispatchRange.EMAMDT_TEAMMATE_RANGED] = true,
  [UEmums_EMarkDispatchRange.EMAMDT_ENEMIES_RANGED] = true,
  [UEmums_EMarkDispatchRange.EMAMDT_CAMP] = true,
  [UEmums_EMarkDispatchRange.EMAMDT_CAMP_EXCLUDE_TEAMMATE] = true
}
local UEnums_EMarkStatus = {
  EMAS_HIDE = 0,
  EMAS_SHOW = 1,
  EMAS_CUSTOMEVENT = 2
}
local MarkDispatchManager_C = import("/Script/ShadowTrackerExtra.MarkDispatchManager")
function InGameMarkTools.ClientAddMapMarkWithRotation(TypeID, MarkPosition, MarkRotation, CustomState, CustomString, MapAdded)
  print(bWriteLog and "InGameMarkTools.ClientAddMapMarkWithRotationNew TypeID" .. TypeID .. " CustomState:" .. tostring(CustomState))
  if MarkPosition == nil then
    return
  end
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) then
    local InstID = uMarkDispatchManager:ClientAddMapMarkWithRotation(TypeID, MarkPosition, MarkRotation, CustomState or 0, CustomString or "", MapAdded or UEnums.EAddMarkFlag.EAMF_Both)
    print(bWriteLog and "InGameMarkTools.ClientAddMapMarkWithRotationNew TypeID Success", TypeID, InstID)
    return InstID
  end
end
function InGameMarkTools.ClientAddMapMark(TypeID, MarkPosition, CustomState, CustomString, MapAdded, Actor, CustomFloat, WeakPlayerState)
  print(bWriteLog and "InGameMarkTools.ClientAddMapMarkNew TypeID" .. tostring(TypeID) .. " CustomState:" .. tostring(CustomState))
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and TypeID then
    local InstID = uMarkDispatchManager:ClientAddMapMark(TypeID, MarkPosition or FVector(0, 0, 0), CustomState or 0, CustomString or "", MapAdded or UEnums.EAddMarkFlag.EAMF_Both, Game:IsValid(Actor) and Actor or nil, CustomFloat or 0, Game:IsValid(WeakPlayerState) and WeakPlayerState or nil, UEnums.EMarkDispatchActionType.EMAMAT_BATCH)
    print(bWriteLog and "InGameMarkTools.ClientAddMapMarkNew TypeID Success", TypeID, InstID, Actor)
    return InstID
  end
end
function InGameMarkTools.ServerAddMapMark(TypeID, MarkPosition, CustomState, MapAdded, CustomFloat, RangeType, WeakPlayerState, Actor)
  print(bWriteLog and "InGameMarkTools.ServerAddMapMarkNew TypeID =" .. TypeID .. " CustomState:" .. tostring(CustomState))
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and TypeID then
    local InstID = uMarkDispatchManager:ServerAddMapMark(TypeID, MarkPosition or FVector(0, 0, 0), CustomState or 0, RangeType or UEmums_EMarkDispatchRange.EMAMDT_ALL, MapAdded or UEnums.EAddMarkFlag.EAMF_Both, Game:IsValid(Actor) and Actor or nil, CustomFloat or 0, Game:IsValid(WeakPlayerState) and WeakPlayerState or nil, UEnums.EMarkDispatchActionType.EMAMAT_BATCH)
    print(bWriteLog and "InGameMarkTools.ServerAddMapMarkNew TypeID Success", TypeID, InstID)
    return InstID
  end
end
function InGameMarkTools.ClientAddMarkToNavigator(UIPath, Position, bAdjustBound, bIsIcon, CustomStatus, InstanceID)
  local NavigatorWidget = UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel)
  if not NavigatorWidget then
    return nil
  end
  return NavigatorWidget:AddCustomMark(UIPath, Position, bAdjustBound, bIsIcon, InstanceID, CustomStatus)
end
function InGameMarkTools.ClientDestroyMarkToNavigator(InstID)
  if not UIManager.UI_Config_InGame.NavigatorPanel then
    return
  end
  local NavigatorWidget = UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel)
  if not NavigatorWidget then
    return
  end
  NavigatorWidget:DestroyCustomMark(InstID)
end
function InGameMarkTools.ShowMapMark(InstID)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID then
    print(bWriteLog and "InGameMarkTools.ShowMapMark InstID", InstID)
    uMarkDispatchManager:ShowOrHideMapMark(InstID, true)
  end
end
function InGameMarkTools.HideMapMark(InstID)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID then
    print(bWriteLog and "InGameMarkTools.HideMapMark InstID", InstID)
    uMarkDispatchManager:ShowOrHideMapMark(InstID, false)
  end
end
function InGameMarkTools.UpdateMapMarkCustomState(InstID, nState, nCountdown)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID and nState then
    if nCountdown and 0 < nCountdown then
      nState = nState + nCountdown * 10000
    end
    print(bWriteLog and "InGameMarkTools.UpdateMapMarkCustomState InstID", InstID, nState)
    uMarkDispatchManager:UpdateMapMarkCustomState(InstID, nState)
  end
end
function InGameMarkTools.UpdateMapMarkCustomFloat(InstID, nVal)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID and nVal then
    print(bWriteLog and "InGameMarkTools.UpdateMapMarkCustomFloat InstID", InstID, nVal)
    uMarkDispatchManager:UpdateMapMarkCustomFloat(InstID, nVal)
  end
end
function InGameMarkTools.UpdateMapMarkLocation(InstID, Location)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID and Location then
    print(bWriteLog and "InGameMarkTools.UpdateMapMarkLocation InstID", InstID, Location.X, Location.Y)
    uMarkDispatchManager:UpdateMapMarkLocation(InstID, Location)
  end
end
function InGameMarkTools.UpdateMapMarkCustomString(InstID, sVal)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID and sVal then
    print(bWriteLog and "InGameMarkTools.UpdateMapMarkCustomString InstID", InstID, sVal)
    uMarkDispatchManager:UpdateMapMarkCustomString(InstID, sVal)
  end
end
function InGameMarkTools.UpdateMapMarkCustomData(InstID, tData)
  local uMarkDispatchManager = InGameMarkTools.GetMarkDispatchManager()
  if slua.isValid(uMarkDispatchManager) and InstID and tData then
    print(bWriteLog and "InGameMarkTools.UpdateMapMarkCustomData InstID", InstID, tData)
    uMarkDispatchManager:UpdateMapMarkCustomData(InstID, tData)
  end
end
function InGameMarkTools.GetMarkDispatchManager()
  if Client then
    local WorldContextObject = slua_GameFrontendHUD:GetWorld()
    return MarkDispatchManager_C.GetMarkDispatchManager(WorldContextObject)
  else
    return MarkDispatchManager_C.GetMarkDispatchManager(CGameWorld)
  end
end
function InGameMarkTools.ShowFastSyncActor(Actor, TypeID, CustomState)
  if Client or not slua.isValid(CGameState) then
    return
  end
  print(bWriteLog and "InGameMarkTools.ShowFastSyncActor TypeID", TypeID, CustomState)
  if CGameState.GetGeneralMapMarkSyncActor then
    local MarkSyncActor = CGameState:GetGeneralMapMarkSyncActor()
    if slua.isValid(MarkSyncActor) then
      MarkSyncActor:RegisterFastSyncActor(Actor, TypeID, CustomState or 0)
    end
  end
end
function InGameMarkTools.ModifyFastSyncActorCustomState(Actor, CustomState, nCountdown)
  if Client or not slua.isValid(CGameState) then
    return
  end
  if nCountdown and 0 < nCountdown then
    CustomState = CustomState + nCountdown * 10000
  end
  print(bWriteLog and "InGameMarkTools.ModifyFastSyncActorCustomState", CustomState)
  if CGameState.GetGeneralMapMarkSyncActor and CustomState then
    local MarkSyncActor = CGameState:GetGeneralMapMarkSyncActor()
    if slua.isValid(MarkSyncActor) then
      MarkSyncActor:ModifyFastSyncActorCustomState(Actor, CustomState)
    end
  end
end
function InGameMarkTools.HideFastSyncActor(Actor, TypeID)
  if Client or not slua.isValid(CGameState) then
    return
  end
  print(bWriteLog and "InGameMarkTools.HideFastSyncActor TypeID", TypeID)
  if CGameState.GetGeneralMapMarkSyncActor then
    local MarkSyncActor = CGameState:GetGeneralMapMarkSyncActor()
    if slua.isValid(MarkSyncActor) then
      MarkSyncActor:UnRegisterFastSyncActor(Actor, TypeID)
    end
  end
end
return InGameMarkTools
local ReportCrashKitFeature = {}
local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UGameplayStatics = import("GameplayStatics")
local ETeamMateDisappearType = import("ETeamMateDisappearType")
local EAttachVehiclErrorType = import("EAttachVehiclErrorType")
local EVehiclVisibleErrorType = import("EVehiclVisibleErrorType")
local CrashKitReportCharacterMoveableExceptionName = "CharacterMoveableException"
local CrashKitReportCharacterMoveSlowExceptionName = "CharacterMoveSlowException"
local CrashKitReportTeammateDisappearException = "TeammateDisappearException"
local CrashKitReportCharacterForbiddenMoveException = "ForbiddenMoveException"
function ReportCrashKitFeature:_PostConstruct()
  ReportCrashKitFeature.__super._PostConstruct(self)
end
function ReportCrashKitFeature:ReceiveBeginPlay()
  ReportCrashKitFeature.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddControlEvent(self.Owner, "OnPlayerEnterFighting", self.HandlePlayerEnterFighting, self)
    self.bIsCheckMoveException = false
    self.bIsReportCharacterMoveableException = false
    self.bIsReportCharacterMoveSlowException = false
    self.nMovableCheckCount = 0
    self.nMoveSlowCheckCount = 0
    self.MoveSlowExceptionStartTime = 0
  end
end
function ReportCrashKitFeature:HandlePlayerEnterFighting()
  if self.bIsCheckMoveException then
    return
  end
  self:RemoveControlEvent(self.Owner, "OnPlayerEnterFighting")
  self.bIsCheckMoveException = true
  local uCharacter = self.Owner:GetPlayerCharacterSafety()
  if not self.Owner:IsSpectator() and slua.isValid(uCharacter) and GameReportUtils.CheckCanBugglyPostException(CrashKitReportCharacterForbiddenMoveException) and uCharacter:IsLocallyControlled() then
    local uMovementComp = uCharacter.STCharacterMovement
    if slua.isValid(uMovementComp) then
      self:AddControlEvent(uMovementComp, "OnForbiddenMoveEvent", self.ReportForbiddenMoveException, self)
    end
  end
end
function ReportCrashKitFeature:ReportCharacterMoveableException()
  if self.bIsReportCharacterMoveableException or self.Owner == nil then
    return
  end
  local uCharacter = self.Owner:GetPlayerCharacterSafety()
  local bSpectatorOrReplay = self.Owner:IsSpectator() or self.Owner:IsPureSpectator() or self.Owner:IsDemoPlayGlobalObserver() or self.Owner:IsDemoPlaySpectator()
  if not bSpectatorOrReplay and slua.isValid(uCharacter) then
    local EParachuteState = import("EParachuteState")
    local EPawnState = import("EPawnState")
    local uCharacterMoveComp = uCharacter.STCharacterMovement
    if not uCharacter.bDead and not uCharacter.bHidden and uCharacter.ParachuteState == EParachuteState.PS_None and slua.isValid(uCharacterMoveComp) and uCharacterMoveComp.bIsActive and CGameState and Client and DataMgr and DataMgr.roleData and slua_GameFrontendHUD then
      local bNeedReport = false
      if bNeedReport and uCharacter:HasState(EPawnState.Stand) and (not (self.Owner:IsMoveable() ~= false and uCharacter:IsActorTickEnabled()) or self.Owner:IsMoveInputIgnored()) and self.Owner.CanMoveCDTime <= 0 and 0 >= self.Owner.MoveableLandHardTime and 0 >= self.Owner.MovealbeSwitchPoseTime and 0 >= uCharacter.MoveableSwitchPoseTime then
        local CrashKitReportString = string.format("uid:%s gameid:%s states: %d %s ", tostring(DataMgr.roleData.uid), tostring(g_game_id), uCharacter.CurrentStates, USTExtraBlueprintFunctionLibrary.GetPlayerStatesString(uCharacter))
        CrashKitReportString = CrashKitReportString .. string.format("pc %d %d %d %d %d - %d %d %d %d ", self:BoolToInt(self.Owner.bMoveable), self.Owner.ClientStateType, uCharacter.FollowState, self:BoolToInt(self.Owner.bIsLandingOnGround), self:BoolToInt(slua.isValid(self.Owner:K2_GetPawn())), self:BoolToInt(self.Owner.bMoveablePickup), self:BoolToInt(self.Owner.bMoveableAirborne), self:BoolToInt(uCharacter:IsActorTickEnabled()), self:BoolToInt(self.Owner:IsMoveInputIgnored()))
        self.bIsReportCharacterMoveableException = GameReportUtils.BugglyPostExceptionFull(CrashKitReportCharacterMoveableExceptionName, CrashKitReportString, Client.IsEditor() or Client.IsDevelopment())
        if self.bIsReportCharacterMoveableException and Client.IsEditor() or Client.IsDevelopment() then
          print(bWriteLog and "ReportCrashKitFeature:ReportCharacterMoveableException CrashKitReportString:" .. CrashKitReportString)
        end
        self:AddGameTimer(2, false, function()
          self:ReportCharacterMoveableException()
        end)
      else
        print(bWriteLog and "ReportCrashKitFeature:ReportCharacterMoveableException None")
      end
    end
  end
end
function ReportCrashKitFeature:CheckCharacterMoveableException()
  if GameReportUtils.CheckCanBugglyPostException(CrashKitReportCharacterMoveableExceptionName) then
    self:ReportCharacterMoveableException()
  end
  if GameReportUtils.CheckCanBugglyPostException(CrashKitReportCharacterMoveSlowExceptionName) then
    local UGameplayStatics = import("GameplayStatics")
    self.MoveSlowExceptionStartTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
    self:ReportCharacterMoveSlowException()
  end
end
function ReportCrashKitFeature:BoolToInt(bValue)
  return bValue and 1 or 0
end
function ReportCrashKitFeature:ReportTeammateDisappear(uReportPlayerState)
  if not GameReportUtils.CheckCanBugglyPostException(CrashKitReportTeammateDisappearException) then
    return
  end
  if slua.isValid(uReportPlayerState) then
    local uInfo = uReportPlayerState.SelfDisappearInfo
    local strDisappearInfo = ""
    local nAliveNum = CGameState:GetAlivePlayerNum()
    if uInfo.bHasPawn then
      local uReportCharacter = uReportPlayerState:GetPlayerCharacter()
      if slua.isValid(uReportCharacter) and uInfo.ReportType == ETeamMateDisappearType.ETMDT_LocError then
        strDisappearInfo = string.format("Disappear Character Type:%d, UID:%s AliveNum:%d  ReportTime:%.2f CreateTime:%.2f, DestroyTime:%.2f, Hide:%d CharHide:%d SLoc:%s  RepLoc:%s CLoc:%s MLoc:%s CMTick:%d, CMActive:%d, bRepM:%d bAbandonM:%d", uInfo.ReportType, uInfo.PlayerUID, nAliveNum, uInfo.ReportTime, uInfo.PawnCreateTime, uInfo.PawnDestroyTime, self:BoolToInt(uInfo.bHide), self:BoolToInt(uInfo.bCharacterHide), uInfo.ServerLocation:ToString(), uReportCharacter.ReplicatedMovement.Location:ToString(), uInfo.Location:ToString(), uInfo.MeshLocation:ToString(), self:BoolToInt(uInfo.bMovementCompTick), self:BoolToInt(uInfo.bMovementActive), self:BoolToInt(uReportCharacter.bReplicateMovement), self:BoolToInt(uReportCharacter.STCharacterMovement.bAbandonReplicatedMovement))
        GameReportUtils.BugglyPostExceptionFull(CrashKitReportTeammateDisappearException, strDisappearInfo, Client.IsEditor() or Client.IsDevelopment())
      end
    else
    end
  end
end
function ReportCrashKitFeature:ReportForbiddenMoveException()
  if not GameReportUtils.CheckCanBugglyPostException(CrashKitReportCharacterForbiddenMoveException) then
    return
  end
  local uCharacter = self.Owner:GetPlayerCharacterSafety()
  local bSpectatorOrReplay = self.Owner:IsSpectator() or self.Owner:IsPureSpectator() or self.Owner:IsDemoPlayGlobalObserver() or self.Owner:IsDemoPlaySpectator()
  if not bSpectatorOrReplay and slua.isValid(uCharacter) then
    local EParachuteState = import("EParachuteState")
    local EPawnState = import("EPawnState")
    local uCharacterMoveComp = uCharacter.STCharacterMovement
    if not uCharacter.bDead and not uCharacter.bHidden and uCharacter.ParachuteState == EParachuteState.PS_None and slua.isValid(uCharacterMoveComp) and uCharacterMoveComp.bIsActive and CGameState and Client and DataMgr and DataMgr.roleData and slua_GameFrontendHUD and self.Owner.CanMoveCDTime <= 0 and 0 >= self.Owner.MoveableLandHardTime and 0 >= self.Owner.MovealbeSwitchPoseTime and 0 >= uCharacter.MoveableSwitchPoseTime then
      local bPawnKown = self.Owner.AcknowledgedPawn ~= uCharacterMoveComp.CharacterOwner
      local CrashKitReportString = string.format("uid:%s gameid:%s states: %d %s ", tostring(DataMgr.roleData.uid), tostring(g_game_id), uCharacter.CurrentStates, USTExtraBlueprintFunctionLibrary.GetPlayerStatesString(uCharacter))
      CrashKitReportString = CrashKitReportString .. string.format("pc %d %d %d %d %d - %d %d %d %d %d - %d %d %s %1.2f %1.2f", self:BoolToInt(self.Owner.bMoveable), self.Owner.ClientStateType, uCharacter.FollowState, self:BoolToInt(self.Owner.bIsLandingOnGround), self:BoolToInt(slua.isValid(self.Owner:K2_GetPawn())), self:BoolToInt(self.Owner.bMoveablePickup), self:BoolToInt(self.Owner.bMoveableAirborne), self:BoolToInt(uCharacter:IsActorTickEnabled()), self:BoolToInt(self.Owner:IsMoveInputIgnored()), uCharacterMoveComp.MovementMode, self:BoolToInt(uCharacter.bReplicateMovement), self:BoolToInt(bPawnKown), uCharacterMoveComp.Velocity:ToString(), uCharacter.SpeedRate, uCharacterMoveComp.MaxWalkSpeed)
      local bException = GameReportUtils.BugglyPostExceptionFull(CrashKitReportCharacterForbiddenMoveException, CrashKitReportString, Client.IsEditor() or Client.IsDevelopment())
      if bException and Client.IsEditor() or Client.IsDevelopment() then
        print(bWriteLog and "ReportCrashKitFeature:CharacterForbiddenMoveException CrashKitReportString:" .. CrashKitReportString)
      end
    end
  end
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, ReportCrashKitFeature)
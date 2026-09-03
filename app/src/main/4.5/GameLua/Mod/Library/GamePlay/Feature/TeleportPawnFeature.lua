local ESTEPoseState = import("ESTEPoseState")
local EPawnState = import("EPawnState")
local ETeleportPawnType = import("ETeleportPawnType")
local GameplayStatics = import("GameplayStatics")
local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TeleportPawnFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local ETestLocationFailedReason = {
  LineTrace = "LineTrace",
  TeleportPawn = "TeleportPawn"
}
local TestLocationNormalizeOffsets = {
  FVector(1, 0, 0),
  FVector(1, 1, 0),
  FVector(0, 1, 0),
  FVector(-1, 1, 0),
  FVector(-1, 0, 0),
  FVector(-1, -1, 0),
  FVector(0, -1, 0),
  FVector(1, -1, 0)
}
local OnClientTeleportLoadingFinishedEvent = "OnClientTeleportLoadingFinished"
local DefaultLoadingTimeout = 40
function TeleportPawnFeature:_PostConstruct()
  TeleportPawnFeature.__super._PostConstruct(self)
  self.LuaDelegate = FeatureUtil.LuaDelegate()
end
function TeleportPawnFeature:ReceiveBeginPlay()
  print(bWriteLog and string.format("TeleportPawnFeature:ReceiveBeginPlay"))
  TeleportPawnFeature.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddControlEvent(self.Owner.Object, "OnPlayerTeleport", self.OnClientTeleportCallback, self)
    self:CheckPreload()
  end
end
function TeleportPawnFeature:CheckPreload()
  if not self.Owner:IsLocallyControlled() and not self.Owner:IsLocalViewed() then
    return
  end
  if self.PreloadAssets then
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:CheckPreload"))
  self.PreloadAssets = {}
  local PreloadUIAsset = function(UIKey)
    local UIConfig = UIManager.UI_Config_InGame[UIKey]
    if not UIConfig then
      return
    end
    local UIBPPath = UIConfig.path .. "_C"
    if self.PreloadAssets[UIBPPath] then
      return
    end
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(UIBPPath, function(Asset)
      if slua.isValid(Asset) and self.PreloadAssets then
        print(bWriteLog and string.format("TeleportPawnFeature:CheckPreload PreloadUIAsset: %s", UIBPPath))
        self.PreloadAssets[UIBPPath] = Asset
      end
    end)
  end
  local TeleportConfig = GamePlayTools.GetCurrentConfig("TeleportConfig")
  if TeleportConfig then
    for _, Config in pairs(TeleportConfig) do
      if Config.LoadingEffect and Config.LoadingEffect.Type == "UI" and Config.LoadingEffect.Param then
        PreloadUIAsset(Config.LoadingEffect.Param)
      end
    end
  end
end
function TeleportPawnFeature:ReceiveEndPlay(EndPlayReason)
  if self.LuaDelegate then
    self.LuaDelegate:Dispose()
  end
  if Client then
    self.PreloadAssets = nil
    self:TryRemoveNamedGameTimer("DelayCloseLoadingEffectUITimer")
  end
  TeleportPawnFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function TeleportPawnFeature:RemoteTeleportPawnByTable(TeleportInfo, TestTime, TeleportPawnType, ParamID)
  if TeleportInfo.BornPos and #TeleportInfo.BornPos > 0 then
    if 10 < TestTime then
      print(bWriteLog and "TeleportPawnFeature:RemoteTeleportPawnByTable, TeleportPawn More Than ten: " .. tostring(self.Owner.PlayerKey))
      return
    end
    local TimeUtil = require("client.common.time_util")
    math.randomseed(TimeUtil.OSTime() + TestTime)
    local Random1 = math.random(1, #TeleportInfo.BornPos)
    local backSuccess = self:RemoteTeleportPawn(TeleportInfo.BornPos[Random1].Location, TeleportInfo.BornPos[Random1].Roatation, TeleportPawnType, ParamID)
    print(bWriteLog and "TeleportPawnFeature:RemoteTeleportPawnByTable, TeleportPawn bSuccess: " .. tostring(self.Owner.PlayerKey) .. tostring(backSuccess) .. TeleportInfo.BornPos[Random1].Location:ToString() .. " TestTime:" .. tostring(TestTime))
    if not backSuccess then
      TestTime = TestTime + 1
      self:RemoteTeleportPawnByTable(TeleportInfo, TestTime, TeleportPawnType, ParamID)
    end
  end
end
function TeleportPawnFeature:RemoteTeleportPawn(uPos, uRot, TeleportPawnType, ParamID)
  if not Client and self.Owner then
    local ETeleportPawnType = import("ETeleportPawnType")
    local bSuccess = Game:TeleportPawn(self.Owner.Object, uPos, uRot, false, true, false, false, TeleportPawnType, ParamID)
    print(bWriteLog and "TeleportPawnFeature:RemoteTeleportPawn, TeleportPawn bSuccess: " .. tostring(self.Owner.PlayerKey) .. tostring(bSuccess) .. uPos:ToString() .. "ParamID:" .. tostring(ParamID))
    if bSuccess then
      if TeleportPawnType == ETeleportPawnType.ParachuteTeleport then
        self:ParachuteJump()
      elseif TeleportPawnType == ETeleportPawnType.RemoteTeleport then
        local uCharacterMovement = self.Owner.STCharacterMovement
        if Game:IsValid(uCharacterMovement) then
          uCharacterMovement:StopMovementImmediately()
        end
        self.Owner:AddBuffBySkill(600409, 1, self.Owner.Object, 1)
      end
      if ParamID then
        local Config = self:GetConfig(ParamID)
        if Config and Config.GameTLogId then
          local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
          if DSCommonTLogSubsystem then
            print(bWriteLog and "TeleportPortal:DSCommonTLogSubsystem 479")
            DSCommonTLogSubsystem:AddCommonTLog(Config.GameTLogId, 1, false)
          end
        end
      end
    end
    return bSuccess
  end
  return false
end
function TeleportPawnFeature:RemoteTeleport(uPos, uRot, TeleportConfigId)
  local Result = self:InternalTeleport(uPos, uRot, TeleportConfigId, ETeleportPawnType.RemoteTeleport)
  if not Result then
    self:RPC_Client_NotifyTeleportFailed()
  end
  return Result
end
function TeleportPawnFeature:InternalTeleport(uPos, uRot, TeleportConfigId, Type)
  print(bWriteLog and "TeleportPawnFeature:InternalTeleport TeleportConfigId " .. tostring(TeleportConfigId))
  local uPawn = self.Owner.Object
  if not self:CheckPawn(uPawn) then
    return false
  end
  print(bWriteLog and string.format("TeleportPawnFeature:InternalTeleport %s Pos = %s, Rot = %s", uPawn:ToString(), uPos:ToString(), uRot:ToString()))
  local LocationBeforeTeleport = self.Owner:K2_GetActorLocation()
  self:OnPreTeleport(TeleportConfigId)
  local LineTraceEnabled = self:GetLineTraceEnabled(self.Config)
  local bSuccess = self:IterateTargetLocation(uPos, function(TestLocation)
    if LineTraceEnabled then
      local bHit, uHitResult = self:LineTraceHit(uPos, TestLocation)
      if bHit then
        return false, ETestLocationFailedReason.LineTrace
      end
    end
    local TeleportPawnResult = Game:TeleportPawn(uPawn, TestLocation, uRot, false, true, false, false, Type, TeleportConfigId)
    if TeleportPawnResult then
      return true
    else
      return false, ETestLocationFailedReason.TeleportPawn
    end
  end)
  if bSuccess then
    self.    if self.Config and self.Config.ParachuteTeleport == true then
      print(bWriteLog and "TeleportPawnFeature:InternalTeleport is ParachuteTeleport")
      self:ParachuteJump()
    else
      local uCharacterMovement = uPawn.STCharacterMovement
      if Game:IsValid(uCharacterMovement) then
        uCharacterMovement:StopMovementImmediately()
      end
      self.Owner:AddBuffBySkill(600409, 1, self.Owner.Object, 1)
    end
    self:OnPostTeleport()
    if uPawn.PlayerUID then
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_POST_TELEPORT, uPawn.PlayerUID)
    end
  else
    print(bWriteLog and string.format("TeleportPawnFeature:InternalTeleport failed"))
  end
  return bSuccess
end
function TeleportPawnFeature:CheckPawn(uPawn)
  if Client then
    return false
  end
  if not slua.isValid(uPawn) then
    print(bWriteLog and string.format("TeleportPawnFeature:CheckPawn uPawn is not valid"))
    return false
  end
  return true
end
function TeleportPawnFeature:GetLineTraceEnabled(Config)
  if not (Config and Config.TestLocation) or Config.TestLocation.LineTraceEnabled == nil then
    return true
  end
  return Config.TestLocation.LineTraceEnabled
end
function TeleportPawnFeature:IterateTargetLocation(Location, TeleportPredicate)
  local MaxHorizontalOffsetRate = 2
  local MaxHeightOffsetRate = 2
  local OffsetValue = 100
  if self.Config and self.Config.TestLocation then
    local TestLocationConfig = self.Config.TestLocation
    MaxHorizontalOffsetRate = TestLocationConfig.MaxHorizontalOffsetRate or MaxHorizontalOffsetRate
    MaxHeightOffsetRate = TestLocationConfig.MaxHeightOffsetRate or MaxHeightOffsetRate
    OffsetValue = TestLocationConfig.OffsetValue or OffsetValue
  end
  local Result, FailedReason = TeleportPredicate(Location)
  print(bWriteLog and string.format("TeleportPawnFeature:IterateTargetLocation Location = %s, FailedReason = %s", Location:ToString(), FailedReason))
  if Result then
    return true
  end
  for HorizontalOffsetRate = 1, MaxHorizontalOffsetRate do
    for HeightOffsetRate = 0, MaxHeightOffsetRate do
      for i = 1, #TestLocationNormalizeOffsets do
        local NormalizeOffset = TestLocationNormalizeOffsets[i]
        local FinalNormalizeOffset = FVector(NormalizeOffset.X * HorizontalOffsetRate, NormalizeOffset.Y * HorizontalOffsetRate, HeightOffsetRate)
        local TestLocation = Location + FinalNormalizeOffset * OffsetValue
        local Result, FailedReason = TeleportPredicate(TestLocation)
        print(bWriteLog and string.format("TeleportPawnFeature:IterateTargetLocation FinalNormalizeOffset = (%d, %d, %d), FailedReason = %s", FinalNormalizeOffset.X, FinalNormalizeOffset.Y, FinalNormalizeOffset.Z, FailedReason))
        if Result then
          return true
        end
      end
    end
  end
  return false
end
function TeleportPawnFeature:LineTraceHit(Start, End)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local EDrawDebugTrace = import("EDrawDebugTrace")
  local uHitResult = import("/Script/Engine.HitResult")()
  local ActorClass = import("/Script/Engine.Actor")
  if not self.TraceActorsToIgnore then
    self.TraceActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
    self.TraceActorsToIgnore:Add(self.Owner.Object)
  end
  local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingle(self.Owner.Object, Start, End, 0, true, self.TraceActorsToIgnore, EDrawDebugTrace.None, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  return bHit, uHitResult
end
function TeleportPawnFeature:ParachuteJump()
  if self.Owner then
    print(bWriteLog and "TeleportPawnFeature:ParachuteJump Start")
    local uPlayerController = self.Owner:GetControllerSafety()
    if slua.isValid(uPlayerController) then
      if not self.Owner:GetEnsure() then
        local EStateType = import("EStateType")
        if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
          local ESTEPoseState = import("ESTEPoseState")
          self.Owner:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
          uPlayerController:ReInitParachuteItem()
          if self.Config and self.Config.OpenParachuteAfterTeleport == true then
            uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteOpen)
          else
            uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
          end
        end
        print(bWriteLog and "TeleportPawnFeature:ParachuteJump over")
      else
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Owner.Object)
        print(bWriteLog and "TeleportPawnFeature:ParachuteJump AI JUMP over, Loc=", tostring(self.Owner:K2_GetActorLocation():ToString()))
        if uPlayerController.SetParachuteType then
          local EParachuteType = import("EParachuteType")
          uPlayerController:SetParachuteType(EParachuteType.SpecialParachuteJump)
          print(bWriteLog and "TeleportPawnFeature:ParachuteJump AI JUMP SetParachuteType")
        end
      end
    end
  end
end
function TeleportPawnFeature:OnPreTeleport(TeleportConfigId)
  if Client then
    return
  end
  self.Config = self:GetConfig(TeleportConfigId)
  local uOwnerPawn = self.Owner
  if uOwnerPawn.PoseState == ESTEPoseState.Crouch or uOwnerPawn.PoseState == ESTEPoseState.Prone then
    uOwnerPawn:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
    print(bWriteLog and "TeleportPawnFeature:OnPreTeleport AdjustPawnState to stand")
  end
  if uOwnerPawn.PoseState == ESTEPoseState.GunADS then
    uOwnerPawn:ScopeInterrupt(ESTEPoseState.Stand)
  end
  uOwnerPawn:OnStateLeave(EPawnState.Sprint)
end
function TeleportPawnFeature:GetConfig(TeleportConfigId)
  local TeleportConfig = GamePlayTools.GetCurrentConfig("TeleportConfig")
  if not TeleportConfig then
    return
  end
  local Config = TeleportConfig[TeleportConfigId]
  if not Config then
    return
  end
  if Config.HideAllUI == nil then
    Config.HideAllUI = true
  end
  return Config
end
function TeleportPawnFeature:OnPostTeleport()
  self:CheckTLog()
  self:StartWaitingClientLoading()
end
function TeleportPawnFeature:CheckTLog()
  if not self.Config or self.Config.GameTLogId == 0 then
    return
  end
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  if DSCommonTLogSubsystem then
    print(bWriteLog and string.format("TeleportPawnFeature:CheckTLog %s", self.Config.GameTLogId))
    DSCommonTLogSubsystem:AddCommonTLog(self.Config.GameTLogId, 1, false)
  end
end
function TeleportPawnFeature:OnClientTeleportStartCallback(bSuccess, DestLocation, DestRotation, TeleportPawnType, ParamID)
  local uPlayerCharacter = self.Owner
  if not (bSuccess and uPlayerCharacter) or not Client then
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:OnClientTeleportStartCallback bSuccess = %s, DestLocation = %s, DestRotation = %s, TeleportPawnType = %s, ParamID = %s", bSuccess, DestLocation:ToString(), DestRotation:ToString(), TeleportPawnType, ParamID))
end
function TeleportPawnFeature:OnClientTeleportCallback(bSuccess, DestLocation, DestRotation, TeleportPawnType, ParamID)
  local uPlayerCharacter = self.Owner
  if not (bSuccess and uPlayerCharacter) or not Client then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_POST_TELEPORT_CLIENT, uPlayerCharacter.PlayerUID, ParamID)
  self.Config = self:GetConfig(ParamID)
  if not self.Config then
    print(bWriteLog and string.format("TeleportPawnFeature:OnClientTeleportCallback ParamID = %s has no config, return", ParamID))
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:OnClientTeleportCallback bSuccess = %s, DestLocation = %s, DestRotation = %s, TeleportPawnType = %s, ParamID = %s", bSuccess, DestLocation:ToString(), DestRotation:ToString(), TeleportPawnType, ParamID))
  uPlayerCharacter:K2_SetActorLocation(DestLocation, false, nil, true)
  uPlayerCharacter:K2_SetActorRotation(DestRotation, true)
  if TeleportPawnType == ETeleportPawnType.RemoteTeleport or TeleportPawnType == ETeleportPawnType.NormalTeleport then
    local uCharacterMovement = uPlayerCharacter.STCharacterMovement
    if slua.isValid(uCharacterMovement) then
      uCharacterMovement:StopMovementImmediately()
    end
  end
  if self:CheckLoading(DestLocation, self.Config) then
  else
    self:AddGameTimer(0.5, false, function()
      self:OnClientLanded(ParamID)
    end)
  end
  if self.Config and self.Config.ParticleOnPreTeleport then
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(self.Config.ParticleOnPreTeleport, function(uPartcileSystem)
      if slua.isValid(uPartcileSystem) and uPlayerCharacter and slua.isValid(uPlayerCharacter.Mesh) then
        local UGameplayStatics = import("GameplayStatics")
        UGameplayStatics.SpawnEmitterAtLocation(uPlayerCharacter.Object, uPartcileSystem, uPlayerCharacter:K2_GetActorLocation() - FVector(0, 0, 100), uPlayerCharacter:K2_GetActorRotation(), FVector(1, 1, 1), true)
      end
    end)
  end
  if self.Config and self.Config.AudioOnPreTeleport then
    local audio_util = require("client.common.audio_util")
    if self.Config.AudioOnPreTeleport2D then
      if self:IsAutonomousProxy() then
        audio_util.PlayAudioAsync(self.Config.AudioOnPreTeleport, nil, nil, function(audioID)
          self.AudioOnPreTeleportID = audioID
        end)
      end
    else
      audio_util.PlayAudioByActorAsync(self.Config.AudioOnPreTeleport, uPlayerCharacter.Object, function(audioID)
        self.AudioOnPreTeleportID = audioID
      end)
    end
  end
end
function TeleportPawnFeature:IsSimulatedAndNotSpectating(uPlayerCharacter)
  local IsSimulated = uPlayerCharacter:IsSimulated()
  local uPlayerController = GameplayData.GetPlayerController()
  local IsInSpectating = slua.isValid(uPlayerController) and uPlayerController:IsInSpectating()
  return IsSimulated and not IsInSpectating
end
function TeleportPawnFeature:SetPlayerCharacterHiddenInGame(uPlayerCharacter, bHidden)
  if bHidden then
    uPlayerCharacter:SetActorHiddenInGame(true)
  elseif not uPlayerCharacter.CharacterHide.bCharacterHideIngame then
    uPlayerCharacter:SetActorHiddenInGame(false)
  end
  print(bWriteLog and string.format("TeleportPawnFeature:SetPlayerCharacterHiddenInGame %s (%s)", bHidden, uPlayerCharacter:ToString()))
end
function TeleportPawnFeature:CheckLoading(DestLocation, Config)
  local CanShowLoading = false
  if self.Owner:IsAutonomousProxy() then
    CanShowLoading = true
  elseif Client then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController:IsSpectator() and slua.isValid(uPlayerController:GetCurPlayerCharacter()) and uPlayerController:GetCurPlayerCharacter().PlayerKey == self.Owner.PlayerKey then
      CanShowLoading = true
    end
  end
  local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
  if not (LevelStreamingMgr and CanShowLoading) or Config.NotShowLoading then
    return false
  end
  print(bWriteLog and string.format("TeleportPawnFeature:CheckLoading DestLocation = %s, LoadingEffectReason = %s", DestLocation:ToString(), self.LoadingEffectReason))
  local bUseDefaultLoadingUI = Config == nil or Config.LoadingEffect == nil
  local FilterLevelKey = Config ~= nil and Config.FilterLevelKey or ""
  if self.LoadingEffectReason == nil then
    self:CheckLoadingEffect(Config, "DSNotifyLoading")
  end
  self:AddCommonEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END, self.OnLevelStreamingLoadEnd, self)
  LevelStreamingMgr:BeginGoto(DestLocation, bUseDefaultLoadingUI, false, nil, FilterLevelKey)
  return true
end
function TeleportPawnFeature:StartWaitingClientLoading()
  print(bWriteLog and string.format("TeleportPawnFeature:StartWaitingClientLoading %s", self.Owner:ToString()))
  self.WaitingClientLoadingTimer = self:AddGameTimer(DefaultLoadingTimeout, false, function()
    print(bWriteLog and string.format("TeleportPawnFeature:StartWaitingClientLoading WaitingClientLoadingTimer timeout %s", self.Owner:ToString()))
    self:OnReceiveClientTeleportLoadingFinish()
  end)
end
function TeleportPawnFeature:OnLevelStreamingLoadEnd(_, __, bSuccess)
  print(bWriteLog and string.format("TeleportPawnFeature:OnLevelStreamingLoadEnd %s", bSuccess))
  self:RemoveCommonEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END)
  if self.Config then
    self:OnClientLanded()
  end
  self:RPC_Server_NotifyTeleportLoadingFinish()
end
TeleportPawnFeature.ServerRPC.RPC_Server_NotifyTeleportLoadingFinish = {
  Reliable = true,
  Params = {}
}
function TeleportPawnFeature:RPC_Server_NotifyTeleportLoadingFinish()
  if Client then
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:RPC_Server_NotifyTeleportLoadingFinish %s", self.Owner:ToString()))
  self:OnReceiveClientTeleportLoadingFinish()
end
function TeleportPawnFeature:OnReceiveClientTeleportLoadingFinish()
  if not self.WaitingClientLoadingTimer then
    print(bWriteLog and string.format("TeleportPawnFeature:OnReceiveClientTeleportLoadingFinish no WaitingClientLoadingTimer, return"))
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:OnReceiveClientTeleportLoadingFinish %s", self.Owner:ToString()))
  self:TryRemoveNamedGameTimer("WaitingClientLoadingTimer")
  self.LuaDelegate:Broadcast(OnClientTeleportLoadingFinishedEvent, self.Owner)
  self.LuaDelegate:Remove(OnClientTeleportLoadingFinishedEvent)
end
function TeleportPawnFeature:ListenOnClientTeleportLoadingFinished(Callback, Caller)
  self.LuaDelegate:Add(OnClientTeleportLoadingFinishedEvent, Callback, Caller)
  return self
end
function TeleportPawnFeature:ClientPreCheckLoadingEffect(TeleportConfigId)
  print(bWriteLog and string.format("TeleportPawnFeature:ClientPreCheckLoadingEffect %s", TeleportConfigId))
  if self.MarkTeleportFailed then
    print(bWriteLog and string.format("TeleportPawnFeature:ClientPreCheckLoadingEffect just MarkTeleportFailed, return"))
    return
  end
  if self.LoadingEffectReason == nil then
    local Config = self:GetConfig(TeleportConfigId)
    self:CheckLoadingEffect(Config, "ClientPreLoading")
  end
end
function TeleportPawnFeature:CheckLoadingEffect(Config, Reason)
  if not self:IsLocal() then
    return
  end
  if not Config or not Config.LoadingEffect then
    return
  end
  local Type = Config.LoadingEffect.Type
  local Param = Config.LoadingEffect.Param
  if not Type or not Param then
    print(bWriteLog and string.format("TeleportPawnFeature:CheckLoadingEffect Type or Param is not valid"))
    return
  end
  self.LoadingEffect  self:TryDestroyLoadingEffect()
  print(bWriteLog and string.format("TeleportPawnFeature:CheckLoadingEffect Type = %s, Param = %s, Reason = %s", Type, Param, Reason))
  if Type == "ScreenEffect" then
    local uScreenEffectClass = slua.loadObject(Param .. "_C")
    if slua.isValid(uScreenEffectClass) then
      local ScreenAppearanceStatics = import("ScreenAppearanceStatics")
      local USTExtraGameplayStatics = import("STExtraGameplayStatics")
      local uOwnerObject = self.Owner.Object
      local uScreenEffectClassCDO = USTExtraGameplayStatics.GetClassDefaultObject(uScreenEffectClass)
      self.LoadingEffectObject = ScreenAppearanceStatics.PlayDynamicScreenAppearance(uOwnerObject, uOwnerObject, uScreenEffectClassCDO.AppearanceName, uScreenEffectClass)
    end
  elseif Type == "UI" and UIManager.UI_Config_InGame[Param] then
    self.LoadingEffectObject = UIManager.ShowUI(UIManager.UI_Config_InGame[Param])
    if self.LoadingEffectObject.SetTimeoutTimer then
      print(bWriteLog and string.format("TeleportPawnFeature:CheckLoadingEffect SetTimeoutTimer"))
      self.LoadingEffectObject:SetTimeoutTimer(Config.LoadingEffect.Timeout or DefaultLoadingTimeout, function()
        self:ClearLoadingEffectObject()
      end)
    end
  end
  if self.LoadingEffectObject then
    self.StartLoadingEffectTime = GameplayStatics.GetRealTimeSeconds(self.Owner.Object)
    print(bWriteLog and string.format("TeleportPawnFeature:CheckLoadingEffect StartLoadingEffectTime = %s", self.StartLoadingEffectTime))
    self.LoadingEffectObjectTimeoutTimer = self:AddGameTimer(DefaultLoadingTimeout, false, function()
      print(bWriteLog and string.format("TeleportPawnFeature:CheckLoadingEffect timeout"))
      self:TryDestroyLoadingEffect()
    end)
    if Config.HideAllUI then
      self:CheckHideAllUI(true)
    end
  end
end
function TeleportPawnFeature:OnClientLanded()
  print(bWriteLog and "TeleportPawnFeature:OnClientLanded")
  if not (self.Config and Client) or not self.Owner then
    return
  end
  local PlayerController = self.Owner:GetControllerSafety()
  if slua.isValid(PlayerController) and not self.Owner.bEnsure then
    PlayerController.bAutoSprint = false
    PlayerController:SetVirtualStickAutoSprintStatus(false)
  end
  self:TryDestroyLoadingEffect()
  if self.Config.ParticleOnPostTeleport then
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(self.Config.ParticleOnPostTeleport, function(uPartcileSystem)
      if slua.isValid(uPartcileSystem) and self.Owner and slua.isValid(self.Owner.Mesh) then
        local UGameplayStatics = import("GameplayStatics")
        UGameplayStatics.SpawnEmitterAtLocation(self.Owner.Object, uPartcileSystem, self.Owner:K2_GetActorLocation() - FVector(0, 0, 100), self.Owner:K2_GetActorRotation(), FVector(1, 1, 1), true)
      end
    end)
  end
  if self.Config and self.Config.AudioOnPostTeleport then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioByActorAsync(self.Config.AudioOnPostTeleport, self.Owner.Object)
  end
end
function TeleportPawnFeature:TryDestroyLoadingEffect()
  if not self:IsLocal() then
    return
  end
  self:TryRemoveNamedGameTimer("LoadingEffectObjectTimeoutTimer")
  if self.Config and self.Config.LoadingEffect and self.Config.LoadingEffect.NoDestroy then
    self:ClearLoadingEffectObject()
  elseif self.LoadingEffectObject then
    local CurrentTime = GameplayStatics.GetRealTimeSeconds(self.Owner.Object)
    print(bWriteLog and string.format("TeleportPawnFeature:TryDestroyLoadingEffect %s CurrentTime = %s", self.LoadingEffectObject, CurrentTime))
    if self.LoadingEffectObject.End and not self.LoadingEffectObject.bHasClosed then
      self.LoadingEffectObject:End(function()
        self:ClearLoadingEffectObject()
      end)
    elseif self.LoadingEffectObject.SetLifeSpan then
      if self.StartLoadingEffectTime and CurrentTime - self.StartLoadingEffectTime < 1 then
        self.LoadingEffectObject:SetLifeSpan(1)
      else
        self.LoadingEffectObject:SetLifeSpan(0)
      end
      self:ClearLoadingEffectObject()
    else
      self:ClearLoadingEffectObject()
    end
  end
  self.LoadingEffectReason = nil
  if self.Config and self.Config.HideAllUI then
    self:TryRemoveNamedGameTimer("HideAllUITimeoutTimer")
    self.HideAllUITimeoutTimer = self:AddGameTimer(2, false, function()
      print(bWriteLog and string.format("TeleportPawnFeature:TryDestroyLoadingEffect HideAllUITimeout"))
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_TEAM_SHOW)
    end)
  end
end
function TeleportPawnFeature:ClearLoadingEffectObject()
  print(bWriteLog and string.format("TeleportPawnFeature:ClearLoadingEffectObject"))
  if self.Config.AudioOnPreTeleportLoop and self.AudioOnPreTeleportID then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.AudioOnPreTeleportID)
    self.AudioOnPreTeleportID = nil
  end
  self.LoadingEffectObject = nil
  self:CheckHideAllUI(false)
end
function TeleportPawnFeature:CheckHideAllUI(bHide)
  if not (Client and self:IsLocal() and self.Config) or not self.Config.HideAllUI then
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:CheckHideAllUI bHide = %s", bHide))
  if bHide then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_TEAM_SHOW)
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_TEAM_SHOW)
  end
end
TeleportPawnFeature.ClientRPC.RPC_Client_NotifyTeleportFailed = {
  Reliable = true,
  Params = {}
}
function TeleportPawnFeature:RPC_Client_NotifyTeleportFailed()
  if not Client then
    return
  end
  print(bWriteLog and string.format("TeleportPawnFeature:RPC_Client_NotifyTeleportFailed, LoadingEffectReason = %s", self.LoadingEffectReason))
  self:TryDestroyLoadingEffect()
  self.MarkTeleportFailed = true
  self:AddGameTimer(0.1, false, function()
    print(bWriteLog and string.format("TeleportPawnFeature:RPC_Client_NotifyTeleportFailed, MarkTeleportFailed = nil"))
    self.MarkTeleportFailed = nil
  end)
end
function TeleportPawnFeature:IsLocal()
  if not self.Owner then
    return false
  end
  return (not self.Owner.IsLocallyControlled or not self.Owner:IsLocallyControlled()) and self.Owner.IsLocalViewed and self.Owner:IsLocalViewed()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CTeleportPawnFeature = class(CFeatureBase, nil, TeleportPawnFeature)
return require("combine_class").SetFeatureDynamic(CTeleportPawnFeature)
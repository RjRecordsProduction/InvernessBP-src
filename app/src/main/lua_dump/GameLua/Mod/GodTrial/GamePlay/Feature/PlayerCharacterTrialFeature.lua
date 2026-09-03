local GameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
local PlayerCharacterTrialFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
function PlayerCharacterTrialFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "uTrialManager",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "bIsInTrialArea",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bFBIsPlaying",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "LeaveAreaWarningEndTime",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Float
    },
    {
      "CheckpointProgress",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    }
  }
end
function PlayerCharacterTrialFeature:_PostConstruct()
  PlayerCharacterTrialFeature.__super._PostConstruct(self)
  if self:HasAuthority() then
    self.bIsInTrialArea = false
    self.bFBIsPlaying = false
    self.LeaveAreaWarningEndTime = -1
    self.CheckpointProgress = 0
  end
  self.PreIsFPPRecords = {}
end
function PlayerCharacterTrialFeature:ReceiveBeginPlay()
  PlayerCharacterTrialFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerCharacterTrialFeature:ReceiveBeginPlay")
  if not self:HasAuthority() then
    self:OnRep_uTrialManager()
    self:OnRep_bFBIsPlaying()
    self:OnRep_LeaveAreaWarningEndTime()
  end
end
function PlayerCharacterTrialFeature:ReceiveEndPlay(EndPlayReason)
  if Client and (self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed()) then
    local uTrialManager = self.uTrialManager or self.uLastTrialManager
    if slua.isValid(uTrialManager) and uTrialManager.OnLocalPlayerLeaveTrial then
      uTrialManager:OnLocalPlayerLeaveTrial()
    end
  end
  self.uLastTrialManager = nil
  PlayerCharacterTrialFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerCharacterTrialFeature:SetTrialManager(uTrialManager)
  if not uTrialManager then
    self:ResetCheckpointProgress()
  end
  self.  self:ForceNetUpdate()
end
function PlayerCharacterTrialFeature:SetIsInTrialArea(bIsInTrialArea)
  self.  self:ForceNetUpdate()
end
function PlayerCharacterTrialFeature:SetCheckpointProgress(Progress)
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:SetCheckpointProgress %s", Progress))
  self.Checkpoint  self:ForceNetUpdate()
end
function PlayerCharacterTrialFeature:ResetCheckpointProgress()
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:ResetCheckpointProgress"))
  self.CheckpointProgress = 0
  self:ForceNetUpdate()
end
function PlayerCharacterTrialFeature:GetSuperData()
  if self._SuperData then
    return self._SuperData
  end
  local SuperData = require("common.super_data")
  self._SuperData = SuperData.CreateSuperData({CheckpointProgress = 0})
  return self._SuperData
end
function PlayerCharacterTrialFeature:OnRep_uTrialManager()
  if self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed() then
    print(bWriteLog and string.format("PlayerCharacterTrialFeature:OnRep_uTrialManager %s", self.uTrialManager))
    if not slua.isValid(self.uTrialManager) and slua.isValid(self.uLastTrialManager) and self.uLastTrialManager.OnLocalPlayerLeaveTrial then
      self.uLastTrialManager:OnLocalPlayerLeaveTrial()
    end
    if slua.isValid(self.uTrialManager) then
      self.uLastTrialManager = self.uTrialManager
      self:OnTrialManagerReady(self.uTrialManager)
    end
    self:CheckShowTrialManagerUI()
  end
end
function PlayerCharacterTrialFeature:OnTrialManagerReady(uTrialManager)
  local TrialType = uTrialManager.TrialType
  if uTrialManager.OnLocalPlayerEnterTrial then
    uTrialManager:OnLocalPlayerEnterTrial()
  end
  if TrialType == Enum.ETrialType.Parkour then
    self:AddGameTimer(0.5, false, function()
      local ThemePropsLogic = SubsystemMgr:Get("ThemePropsWidgetLogic")
      if ThemePropsLogic then
        ThemePropsLogic:HandleThemePropsChosenByID(44060804)
      end
    end)
  end
end
function PlayerCharacterTrialFeature:OnRep_CheckpointProgress()
  if not self.Owner:IsLocallyControlled() and not self.Owner:IsLocalViewed() then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:OnRep_CheckpointProgress CheckpointProgress = %s", self.CheckpointProgress))
  local SuperData = self:GetSuperData()
  SuperData.CheckpointProgress = self.CheckpointProgress
end
function PlayerCharacterTrialFeature:SetLeaveAreaWarningEndTime(EndTime)
  self.LeaveAreaWarning  self:ForceNetUpdate()
end
function PlayerCharacterTrialFeature:OnRep_LeaveAreaWarningEndTime()
  if not self.Owner:IsLocallyControlled() and not self.Owner:IsLocalViewed() then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:OnRep_LeaveAreaWarningEndTime EndTime = %s", self.LeaveAreaWarningEndTime))
  local CommonTrialTipsUIConfig = UIManager.UI_Config_InGame.CommonTrialTipsUI
  if self.LeaveAreaWarningEndTime and self.LeaveAreaWarningEndTime > 0 then
    local TrialTipsUI = UIManager.GetUI(CommonTrialTipsUIConfig)
    TrialTipsUI = TrialTipsUI or UIManager.ShowUI(CommonTrialTipsUIConfig)
    if TrialTipsUI then
      local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
      local uTrialManager = self.uTrialManager or self.uLastTrialManager
      local TrialType = slua.isValid(uTrialManager) and uTrialManager.TrialType or 0
      TrialTipsUI:SetTipsData(Enum.ECommonTrialTipsType.LeaveAreaWarning, {
        TrialType = TrialType,
        EndTime = self.LeaveAreaWarningEndTime
      })
    end
  else
    local TrialTipsUI = UIManager.GetUI(CommonTrialTipsUIConfig)
    if TrialTipsUI then
      TrialTipsUI:HideLeaveAreaWarning()
    end
  end
  self:CheckShowTrialManagerUI()
end
function PlayerCharacterTrialFeature:CheckShowTrialManagerUI()
  local uTargetTrialManager = self.uTrialManager or self.uLastTrialManager
  if slua.isValid(uTargetTrialManager) and uTargetTrialManager.CheckShowUI then
    uTargetTrialManager:CheckShowUI()
  end
end
function PlayerCharacterTrialFeature:SetFBPlayingState(bIsPlaying)
  self.bFBIsPlaying = bIsPlaying
  self:ForceNetUpdate()
  self:CheckForceTPP(bIsPlaying)
end
function PlayerCharacterTrialFeature:OnRep_bFBIsPlaying()
  if self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed() then
    print(bWriteLog and string.format("PlayerCharacterTrialFeature:OnRep_bFBIsPlaying %s", self.bFBIsPlaying))
    local uPlayerController = self.Owner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:SetMovable(not self.bFBIsPlaying)
    end
    self:CheckForceTPP(self.bFBIsPlaying)
  end
end
function PlayerCharacterTrialFeature:CheckForceTPP(bEnter)
  local IsFPPGameMode = CGameState ~= nil and CGameState.IsFPPGameMode
  if IsFPPGameMode then
    if not Client then
      local uCharacter = self.Owner.Object
      local PlayerKey = self.Owner.PlayerKey
      if bEnter then
        self.PreIsFPPRecords[PlayerKey] = uCharacter.IsNetFPP
        uCharacter.IsNetFPP = false
      else
        if self.PreIsFPPRecords[PlayerKey] ~= nil then
          uCharacter.IsNetFPP = self.PreIsFPPRecords[PlayerKey]
        else
          uCharacter.IsNetFPP = IsFPPGameMode
        end
        self.PreIsFPPRecords[PlayerKey] = nil
      end
      uCharacter:ForceNetUpdate()
      print(bWriteLog and string.format("PlayerCharacterTrialFeature:CheckForceTPP PlayerKey = %s, bEnter = %s, IsNetFPP = %s", PlayerKey, bEnter, uCharacter.IsNetFPP))
    end
  elseif Client then
    local uCharacter = self.Owner.Object
    if not uCharacter:IsLocallyControlled() and not uCharacter:IsLocalViewed() then
      return
    end
    print(bWriteLog and string.format("PlayerCharacterTrialFeature:CheckForceTPP bEnter = %s", bEnter))
    if bEnter then
      if uCharacter:GetIsFPP() then
        uCharacter:SetCurrentPersonPerspective(false, true)
        self.bChangedPP = true
      end
    else
      if self.bChangedPP then
        uCharacter:SetCurrentPersonPerspective(true, true)
      end
      self.bChangedPP = false
    end
  end
end
function PlayerCharacterTrialFeature:ShowCommonTrialTips(Type, Params)
  local ParamsContent = slua.LuaArchiverEncode(LuaStateWrapper, Params or {})
  self:ClientRPC_ShowCommonTrialTips(Type, ParamsContent)
end
PlayerCharacterTrialFeature.ServerRPC.ServerRPC_RequestExitTrial = {
  Reliable = true,
  Params = {}
}
function PlayerCharacterTrialFeature:ServerRPC_RequestExitTrial()
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:ServerRPC_RequestExitTrial %s", self.Owner:ToString()))
  if slua.isValid(self.uTrialManager) then
    self.uTrialManager:RequestExitTrial(self.Owner.Object)
  end
end
PlayerCharacterTrialFeature.ClientRPC.ClientRPC_ShowCommonTrialTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Byte
    }
  }
}
function PlayerCharacterTrialFeature:ClientRPC_ShowCommonTrialTips(Type, ParamsContent)
  if not Client then
    return
  end
  local Params = slua.LuaArchiverDecode(LuaStateWrapper, ParamsContent) or {}
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:ClientRPC_ShowCommonTrialTips Type = %s, TrialType = %s", Type, Params.TrialType))
  local CommonTrialTipsUIConfig = UIManager.UI_Config_InGame.CommonTrialTipsUI
  local TrialTipsUI = UIManager.GetUI(CommonTrialTipsUIConfig)
  TrialTipsUI = TrialTipsUI or UIManager.ShowUI(CommonTrialTipsUIConfig)
  if TrialTipsUI then
    TrialTipsUI:SetTipsData(Type, Params)
  end
end
PlayerCharacterTrialFeature.ClientRPC.ClientRPC_RecoverCamera = {
  Reliable = true,
  Params = {}
}
function PlayerCharacterTrialFeature:ClientRPC_RecoverCamera()
  if not Client then
    return
  end
  print(bWriteLog and "PlayerCharacterTrialFeature:ClientRPC_RecoverCamera")
  if slua.isValid(self.uTrialManager) and self.uTrialManager.RecoverCameraToPlayer then
    self.uTrialManager:RecoverCameraToPlayer()
  end
end
PlayerCharacterTrialFeature.ClientRPC.ClientRPC_CameraFollowBall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
function PlayerCharacterTrialFeature:ClientRPC_CameraFollowBall(uBallActor)
  if not Client then
    return
  end
  print(bWriteLog and "PlayerCharacterTrialFeature:ClientRPC_CameraFollowBall")
  if slua.isValid(self.uTrialManager) and self.uTrialManager.StartCameraFollowBall then
    self.uTrialManager:StartCameraFollowBall(uBallActor)
  end
end
PlayerCharacterTrialFeature.MulticastRPC = PlayerCharacterTrialFeature.MulticastRPC or {}
PlayerCharacterTrialFeature.MulticastRPC.MulticastRPC_PKNotifyCheckpoint = {
  Reliable = true,
  Params = {}
}
function PlayerCharacterTrialFeature:MulticastRPC_PKNotifyCheckpoint()
  if not Client then
    return
  end
  print(bWriteLog and "PlayerCharacterTrialFeature:MulticastRPC_PKNotifyCheckpoint")
  self:_PlayPKCheckpointFx()
  local PKTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.PKTrialConfig")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioByActorAsync(PKTrialConfig.MovePlatform.Audio.ReachCheckpoint, self.Owner.Object)
end
function PlayerCharacterTrialFeature:_PlayPKCheckpointFx()
  local PKTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.PKTrialConfig")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(PKTrialConfig.ReachCheckpointFxPath, function(uParticle)
    if slua.isValid(uParticle) and slua.isValid(self.Owner.Object) then
      GameplayStatics.SpawnEmitterAttached(uParticle, self.Owner.Mesh, "root", FVector(0, 0, 100), FRotator.ZeroRotator, FVector.OneVector, 0, true)
    end
  end)
end
PlayerCharacterTrialFeature.MulticastRPC.MulticastRPC_EPNotifyTrialState = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterTrialFeature:MulticastRPC_EPNotifyTrialState(TrialState)
  if not Client then
    return
  end
  local EPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.EPTrialConfig")
  local Enum = require("GameLua.Mod.GodTrial.Gameplay.Config.EnumDefine")
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:MulticastRPC_EPNotifyTrialState TrialState = %s", TrialState))
  self:_PlayTrialStartFxOnCharacter(EPTrialConfig)
  if TrialState == Enum.ETrialState.Preparing then
    self:_PlayTrialStartFxOnStartActor(EPTrialConfig)
    local StatueStartAudio = EPTrialConfig.Audio and EPTrialConfig.Audio.StatueStartAudio
    if StatueStartAudio then
      local audio_util = require("client.common.audio_util")
      audio_util.PlayAudioByActorAsync(StatueStartAudio, self.Owner.Object)
    end
  elseif TrialState == Enum.ETrialState.Ending then
    local VictoryAudio = EPTrialConfig.Audio and EPTrialConfig.Audio.VictoryAudio
    if VictoryAudio then
      local audio_util = require("client.common.audio_util")
      audio_util.PlayAudioByActorAsync(VictoryAudio, self.Owner.Object)
    end
  end
end
function PlayerCharacterTrialFeature:_PlayTrialStartFxOnCharacter(EPTrialConfig)
  local FxPath = EPTrialConfig.TrialStartFxPath
  if not FxPath then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(FxPath, function(uParticle)
    if slua.isValid(uParticle) and slua.isValid(self.Owner.Object) then
      GameplayStatics.SpawnEmitterAttached(uParticle, self.Owner.Mesh, "root", FVector(0, 0, 100), FRotator.ZeroRotator, FVector.OneVector, 0, true)
    end
  end)
end
function PlayerCharacterTrialFeature:_PlayTrialStartFxOnStartActor(EPTrialConfig)
  local FxPath = EPTrialConfig.TrialStartActorFxPath
  if not FxPath then
    return
  end
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local uStartTrialActor = ActorTools.GetOneActor(self.Owner.Object, EPTrialConfig.StartTrialActorBPClass)
  if not slua.isValid(uStartTrialActor) then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(FxPath, function(uParticle)
    if slua.isValid(uParticle) and slua.isValid(uStartTrialActor) then
      GameplayStatics.SpawnEmitterAtLocation(uStartTrialActor, uParticle, uStartTrialActor:K2_GetActorLocation(), FRotator.ZeroRotator, FVector.OneVector, true)
    end
  end)
end
PlayerCharacterTrialFeature.MulticastRPC.MulticastRPC_NotifyEatPoint = {
  Reliable = false,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function PlayerCharacterTrialFeature:MulticastRPC_NotifyEatPoint(ComboLevel, PointType)
  if not Client then
    return
  end
  local EPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.EPTrialConfig")
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:MulticastRPC_NotifyEatPoint ComboLevel = %s, PointType = %s", ComboLevel, PointType))
  self:_PlayAbsorbFx(PointType)
  if self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed() then
    self:_PlayComboAudio(EPTrialConfig, ComboLevel, PointType)
    local FxConfig = EPTrialConfig.PointTypes and EPTrialConfig.PointTypes[PointType]
    self:_PlayEatPointScreenEffect(FxConfig)
  end
  self.LastEat  self:TryRemoveNamedGameTimer("CacheLastEatPointTypeTimer")
  self.CacheLastEatPointTypeTimer = self:AddGameTimer(2, false, function()
    self.LastEatPointType = nil
  end)
end
function PlayerCharacterTrialFeature:ClientNotifySkillEnding()
  if self.LastEatPointType then
    print(bWriteLog and string.format("PlayerCharacterTrialFeature:ClientNotifySkillEnding LastEatPointType = %s", self.LastEatPointType))
    self:_PlayAbsorbFx(self.LastEatPointType)
    self.LastEatPointType = nil
  end
end
function PlayerCharacterTrialFeature:_PlayAbsorbFx(EatPointType)
  local EPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.EPTrialConfig")
  local FxConfig = EPTrialConfig.PointTypes and EPTrialConfig.PointTypes[EatPointType]
  if not FxConfig or not FxConfig.AbsorbFxPath then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(FxConfig.AbsorbFxPath, function(uParticle)
    if slua.isValid(uParticle) then
      GameplayStatics.SpawnEmitterAttached(uParticle, self.Owner.Mesh, FxConfig.AbsorbFxSocketName, FVector(0, 0, 0), FRotator(-90, 0, 0), FVector(1, 1, 1), 0, true)
    end
  end)
  if FxConfig.AbsorbAudio then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioByActorAsync(FxConfig.AbsorbAudio, self.Owner.Object)
  end
end
function PlayerCharacterTrialFeature:_PlayComboAudio(EPTrialConfig, ComboLevel, PointType)
  local PointTypeConfig = EPTrialConfig.PointTypes and EPTrialConfig.PointTypes[PointType]
  local ComboSteps = PointTypeConfig and PointTypeConfig.ComboSteps
  if not ComboSteps or ComboLevel < 1 then
    return
  end
  local AudioPath = ComboSteps[ComboLevel]
  if not AudioPath then
    return
  end
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioByActorAsync(AudioPath, self.Owner.Object)
end
function PlayerCharacterTrialFeature:_PlayEatPointScreenEffect(FxConfig)
  if not FxConfig or not FxConfig.ScreenEffectClass then
    return
  end
  self:TryRemoveNamedGameTimer("EatPointScreenEffectTimer")
  local ScreenAppearanceStatics = import("ScreenAppearanceStatics")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local Name = FxConfig.ScreenEffectName
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(FxConfig.ScreenEffectClass, function(uScreenEffectClass)
    ScreenAppearanceStatics.PlayDynamicScreenAppearance(uPlayerController, uPlayerController, Name, uScreenEffectClass)
  end)
  print(bWriteLog and string.format("PlayerCharacterTrialFeature:_PlayEatPointScreenEffect ScreenEffectClass = %s", FxConfig.ScreenEffectClass))
  self.EatPointScreenEffectTimer = self:AddGameTimer(FxConfig.ScreenEffectDuration, false, function()
    self.EatPointScreenEffectTimer = nil
    if slua.isValid(uPlayerController) then
      ScreenAppearanceStatics.StopScreenAppearanceByName(uPlayerController, uPlayerController, Name)
    end
  end)
end
function PlayerCharacterTrialFeature:RecordFBMaxGoalCount(GoalCount)
  if not self.FBMaxGoalCount then
    self.FBMaxGoalCount = 0
  end
  if GoalCount > self.FBMaxGoalCount then
    self.FBMax    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if DSCommonTLogSubsystem then
      local FBTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.FBTrialConfig")
      print(bWriteLog and string.format("PlayerCharacterTrialFeature:RecordFBMaxGoalCount %s %s", GoalCount, self.Owner:ToString()))
      DSCommonTLogSubsystem:AddPlayerGeneralCount(self.Owner.PlayerKey, FBTrialConfig.TLog.Player.MaxGoalCount, GoalCount, true)
    end
  end
end
function PlayerCharacterTrialFeature:RecordPKMinTime(Time)
  if not self.PKMinTime then
    self.PKMinTime = math.huge
  end
  if Time < self.PKMinTime then
    self.PKMin    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if DSCommonTLogSubsystem then
      local PKTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.PKTrialConfig")
      local intTime = math.floor(Time)
      print(bWriteLog and string.format("PlayerCharacterTrialFeature:RecordPKMinTime %s(%s) %s", intTime, Time, self.Owner:ToString()))
      DSCommonTLogSubsystem:AddPlayerGeneralCount(self.Owner.PlayerKey, PKTrialConfig.TLog.Player.MinTime, intTime, true)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerCharacterTrialFeature)
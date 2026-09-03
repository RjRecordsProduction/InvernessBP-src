local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TransitionableStateMachineFeature = {}
local RETRY_WHEN_SERVER_TIME_NOT_VALID = false
local MAX_RETRY_TIME_WHEN_SERVER_TIME_NOT_VALID = 5
local MAX_RETRY_TIME_WHEN_SEQUENCE_NOT_READY = 10
function TransitionableStateMachineFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "StateChangedTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
end
function TransitionableStateMachineFeature:OnRep_StateChangedTime()
  printf("TransitionableStateMachineFeature:OnRep_StateChangedTime %s", self.StateChangedTime)
end
function TransitionableStateMachineFeature:_PostConstruct()
  TransitionableStateMachineFeature.__super._PostConstruct(self)
  self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds(self.Owner)
  self._IsInCD = false
  self._RetryTimeWhenServerTimeNotValid = 0
  self._CacheAssets = {}
end
function TransitionableStateMachineFeature:ReceiveBeginPlay()
  TransitionableStateMachineFeature.__super.ReceiveBeginPlay(self)
  self:_RetryApplyCacheTransition()
end
function TransitionableStateMachineFeature:ReceiveEndPlay(EndPlayReason)
  self:_ClearRetryApplyTransitionTimer()
  self:_InternalClearTransition()
  if EndPlayReason == import("EEndPlayReason").Destroyed then
    self._TransitionConfigs = nil
  end
  if self._CacheAssets then
    for Name, Asset in pairs(self._CacheAssets) do
      if slua.isValid(Asset) then
        slua.removeRef(Asset)
        FeatureUtil.printf("TransitionableStateMachineFeature:ReceiveEndPlay slua.removeRef %s", Name)
      end
    end
    self._CacheAssets = nil
  end
  TransitionableStateMachineFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function TransitionableStateMachineFeature:Init(Config)
  self._CheckLocal = self:_ParseCheckLocal(Config)
  self.StateMachine:Init(Config.States, Config.InitStateId)
  self.StateMachine:OnStateChanged(self._OnStateChanged, self)
end
function TransitionableStateMachineFeature:SetCacheAsset(Name, Asset)
  if self._CacheAssets then
    slua.addRef(Asset)
    self._CacheAssets[Name] = Asset
    FeatureUtil.printf("TransitionableStateMachineFeature:SetCacheAsset Name = %s, Asset = %s", Name, Asset)
  end
end
function TransitionableStateMachineFeature:_RetryApplyCacheTransition()
  local CacheConfig = self._CacheApplyTransitionConfig
  if CacheConfig ~= nil then
    printf("TransitionableStateMachineFeature:_RetryApplyCacheTransition")
    self:_ClearRetryApplyTransitionTimer()
    self._RetryApplyTransitionTimer = self:AddGameTimer(1, false, function()
      if not self.Owner or not slua.isValid(self.Owner.Object) then
        return
      end
      FeatureUtil.printf("TransitionableStateMachineFeature:_RetryApplyCacheTransition ApplyTransition")
      self:ApplyTransition(CacheConfig.StateId, CacheConfig.ForceJump)
    end)
  end
end
function TransitionableStateMachineFeature:_ParseCheckLocal(Config)
  if Config.CheckLocal == nil then
    return false
  end
  assert(type(Config.CheckLocal) == "boolean", "type(Config.CheckLocal) == \"boolean\"")
  return Config.CheckLocal
end
function TransitionableStateMachineFeature:InitTransitionConfigs(TransitionConfigs)
  TransitionConfigs = TransitionConfigs or {}
  TransitionConfigs.States = TransitionConfigs.States or {}
  TransitionConfigs.TransitionCDTime = TransitionConfigs.TransitionCDTime or 0
  if TransitionConfigs.RefreshTransition == nil then
    TransitionConfigs.RefreshTransition = true
  end
  self._  if TransitionConfigs.RefreshTransition then
    self:ApplyTransition(self.StateMachine:GetState(), true)
  end
end
function TransitionableStateMachineFeature:GetState()
  return self.StateMachine:GetState()
end
function TransitionableStateMachineFeature:SetState(StateId)
  self.StateMachine:SetState(StateId)
end
function TransitionableStateMachineFeature:OnStateChanged(Callback, Caller)
  self.StateMachine:OnStateChanged(Callback, Caller)
end
function TransitionableStateMachineFeature:IsTransitionEnabled()
  if self:HasAuthority() then
    return not self._CheckLocal
  elseif self._CheckLocal then
    local IsLocal = self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed()
    return IsLocal
  else
    return true
  end
end
function TransitionableStateMachineFeature:_OnStateChanged(StateId)
  if self:HasAuthority() then
    self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds()
  elseif not self:IsTransitionEnabled() then
    return
  end
  FeatureUtil.printf("%s TransitionableStateMachineFeature:_OnStateChanged StateId = %s", self.Owner.Object, StateId)
  self:ApplyTransition(StateId)
end
function TransitionableStateMachineFeature:ApplyTransition(StateId, ForceJump)
  local StateConfig = self:_GetTransitionStateConfig(StateId)
  if not StateConfig then
    FeatureUtil.printf("TransitionableStateMachineFeature:ApplyTransition no StateConfig, return")
    return
  end
  if not self:IsTransitionEnabled() then
    FeatureUtil.printf("TransitionableStateMachineFeature:ApplyTransition not self:IsTransitionEnabled() , return")
    return
  end
  FeatureUtil.printf("TransitionableStateMachineFeature:ApplyTransition StateId = %s, ForceJump = %s", StateId, ForceJump)
  local IsTransitionValid = self:_CheckTransitionValid(StateConfig)
  if self:HasAuthority() then
    FeatureUtil.printf("TransitionableStateMachineFeature:ApplyTransition DS _InternalTransitionPlay")
    self:_InternalTransitionPlay(StateConfig)
  elseif IsTransitionValid then
    self:_ClearRetryApplyTransitionTimer()
    self:_ClientApplyTransition(StateConfig, ForceJump)
    if self._CacheApplyTransitionConfig ~= nil then
      FeatureUtil.printf("TransitionableStateMachineFeature:ApplyTransition apply from cache finish")
      self._CacheApplyTransitionConfig = nil
    end
  else
    if not self._RetryTimeWhenSequenceNotReady then
      self._RetryTimeWhenSequenceNotReady = 0
    end
    self._RetryTimeWhenSequenceNotReady = self._RetryTimeWhenSequenceNotReady + 1
    if self._RetryTimeWhenSequenceNotReady <= MAX_RETRY_TIME_WHEN_SEQUENCE_NOT_READY then
      printf("TransitionableStateMachineFeature:_OnStateChanged transition not valid yet, will retry (%s %s) (%s/%s)", StateId, ForceJump, self._RetryTimeWhenSequenceNotReady, MAX_RETRY_TIME_WHEN_SEQUENCE_NOT_READY)
      self._CacheApplyTransitionConfig = {StateId = StateId, ForceJump = ForceJump}
      self:_RetryApplyCacheTransition()
    else
      printf("TransitionableStateMachineFeature:_OnStateChanged transition not valid yet, retry failed!")
    end
  end
end
function TransitionableStateMachineFeature:_GetTransitionStateConfig(StateId)
  if self._TransitionConfigs and self._TransitionConfigs.States then
    return self._TransitionConfigs.States[StateId]
  end
end
function TransitionableStateMachineFeature:_CheckTransitionValid(StateConfig)
  if StateConfig.SequenceActor then
    return self.Transition:InitWithSequenceActor(StateConfig.SequenceActor)
  elseif StateConfig.Sequence then
    return self.Transition:InitWithSequence(StateConfig.Sequence)
  elseif StateConfig.Timeline and StateConfig.TimelineFunc then
    return self.Transition:InitWithTimeline(StateConfig.Timeline, StateConfig.TimelineFunc)
  elseif StateConfig.LevelSequence then
    return self.Transition:InitWithLevelSequence(StateConfig.LevelSequence)
  end
  return false
end
function TransitionableStateMachineFeature:_ClientApplyTransition(StateConfig, ForceJump)
  local CurrentTime = GamePlayTools.GetServerWorldTimeSeconds()
  local IsServerTimeValid = 0 <= CurrentTime
  self:_RefreshTransition(StateConfig)
  local TransitionTime = self.Transition:GetLength()
  local StateChangedTime = self.StateChangedTime
  FeatureUtil.printf("TransitionableStateMachineFeature:_ClientApplyTransition CurrentTime = %s, self.StateChangedTime = %s, TransitionTime = %s", CurrentTime, StateChangedTime, TransitionTime)
  if IsServerTimeValid then
    if CurrentTime > StateChangedTime + TransitionTime or ForceJump then
      self:_InternalTransitionJump(StateConfig)
    else
      self:_InternalTransitionPlay(StateConfig)
    end
  elseif RETRY_WHEN_SERVER_TIME_NOT_VALID and self._RetryTimeWhenServerTimeNotValid < MAX_RETRY_TIME_WHEN_SERVER_TIME_NOT_VALID then
    self._RetryTimeWhenServerTimeNotValid = self._RetryTimeWhenServerTimeNotValid + 1
    FeatureUtil.printf("TransitionableStateMachineFeature:_ClientApplyTransition CurrentTime not valid, will retry %s", self._RetryTimeWhenServerTimeNotValid)
    self:AddGameTimer(0.5, false, function()
      FeatureUtil.printf("TransitionableStateMachineFeature:_ClientApplyTransition retry %s", self._RetryTimeWhenServerTimeNotValid)
      self:_ClientApplyTransition(StateConfig)
    end)
  else
    FeatureUtil.printf("TransitionableStateMachineFeature:_ClientApplyTransition directly jump transition")
    self:_InternalTransitionJump(StateConfig)
  end
end
function TransitionableStateMachineFeature:_InternalTransitionPlay(StateConfig)
  if self._IsInCD then
    FeatureUtil.printf("TransitionableStateMachineFeature:_InternalTransitionPlay in CD, return")
    return
  end
  if self._LastStateIdWhenPlayTransition == self.StateMachine:GetState() then
    FeatureUtil.printf("TransitionableStateMachineFeature:_InternalTransitionPlay same StateId, return")
    return
  end
  self:_RefreshTransition(StateConfig)
  if not StateConfig.PlayReverse then
    self.Transition:Play()
  else
    self.Transition:PlayReverse()
  end
  local StateMachineStateId = self.StateMachine:GetState()
  FeatureUtil.printf("TransitionableStateMachineFeature:_InternalTransitionPlay self._LastStateIdWhenPlayTransition = %s", StateMachineStateId)
  self._LastStateIdWhenPlayTransition = StateMachineStateId
  local TransitionCDTime = self:_GetTransitionCDTime(StateConfig)
  self:_InternalStartTransitionCD(TransitionCDTime)
end
function TransitionableStateMachineFeature:_GetTransitionCDTime(StateConfig)
  if StateConfig and StateConfig.TransitionCDTime then
    return StateConfig.TransitionCDTime
  end
  local ConfigTime = self._TransitionConfigs.TransitionCDTime
  if ConfigTime and 0 < ConfigTime then
    return ConfigTime
  end
  local TransitionTime = self.Transition:GetLength()
  FeatureUtil.printf("TransitionableStateMachineFeature:_GetTransitionCDTime use transition length = %s", TransitionTime)
  return TransitionTime
end
function TransitionableStateMachineFeature:_InternalTransitionJump(StateConfig)
  self:_InternalClearTransition()
  self._IsInCD = false
  self.Transition:Stop()
  self:_RefreshTransition(StateConfig)
  if not StateConfig.PlayReverse then
    self.Transition:Jump(true)
  else
    self.Transition:Jump(false)
  end
  local StateMachineStateId = self.StateMachine:GetState()
  FeatureUtil.printf("TransitionableStateMachineFeature:_InternalTransitionJump self._LastStateIdWhenPlayTransition = %s", StateMachineStateId)
  self._LastStateIdWhenPlayTransition = StateMachineStateId
end
function TransitionableStateMachineFeature:_RefreshTransition(StateConfig)
  if StateConfig.SequenceAssetPath then
    FeatureUtil.printf("TransitionableStateMachineFeature:_RefreshTransition SetAssetPath = %s", StateConfig.SequenceAssetPath)
    if self._CacheAssets and self._CacheAssets[StateConfig.SequenceAssetPath] then
      local Asset = self._CacheAssets[StateConfig.SequenceAssetPath]
      if slua.isValid(Asset) then
        FeatureUtil.printf("TransitionableStateMachineFeature:_RefreshTransition use cache asset")
        self.Transition:SetAssetPath(Asset)
      else
        FeatureUtil.printf("TransitionableStateMachineFeature:_RefreshTransition cache asset is not valid, fallback")
        self.Transition:SetAssetPath(StateConfig.SequenceAssetPath)
      end
    else
      self.Transition:SetAssetPath(StateConfig.SequenceAssetPath)
    end
  end
end
function TransitionableStateMachineFeature:_InternalStartTransitionCD(CDTime)
  FeatureUtil.printf("TransitionableStateMachineFeature:_InternalStartTransitionCD start CD CDTime = %s", CDTime)
  self:_InternalClearTransition()
  self._IsInCD = true
  self._TransitionCDTimer = self:AddGameTimer(CDTime, false, function()
    local StateMachineStateId = self.StateMachine:GetState()
    FeatureUtil.printf("TransitionableStateMachineFeature:_InternalStartTransitionCD end CD %s %s", self._LastStateIdWhenPlayTransition, StateMachineStateId)
    self._IsInCD = false
    if self._LastStateIdWhenPlayTransition ~= StateMachineStateId then
      FeatureUtil.printf("TransitionableStateMachineFeature:_InternalStartTransitionCD _LastStateIdWhenPlayTransition not same, refresh")
      self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds()
      self:ApplyTransition(StateMachineStateId)
    end
  end)
end
function TransitionableStateMachineFeature:_InternalClearTransition()
  if self._TransitionCDTimer then
    self:RemoveGameTimer(self._TransitionCDTimer)
    self._TransitionCDTimer = nil
  end
end
function TransitionableStateMachineFeature:_ClearRetryApplyTransitionTimer()
  if self._RetryApplyTransitionTimer then
    FeatureUtil.printf("TransitionableStateMachineFeature:_ClearRetryApplyTransitionTimer")
    self:RemoveGameTimer(self._RetryApplyTransitionTimer)
    self._RetryApplyTransitionTimer = nil
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CTransitionableStateMachineFeature = class(CFeatureBase, nil, TransitionableStateMachineFeature)
return require("combine_class").DeclareFeature(CTransitionableStateMachineFeature, {
  {
    StateMachine = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.StateMachineFeature"
  },
  {
    Transition = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.TransitionFeature"
  }
}, "TransitionableStateMachineFeature")
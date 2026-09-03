local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local class = require("class")
local object = require("object")
local SequenceActorTransition = {}
function SequenceActorTransition:ctor(_, SequenceActor)
  print(bWriteLog and string.format("SequenceActorTransition:ctor %s", SequenceActor))
  if SequenceActor then
    self.Cache    self:CheckInit()
  end
end
function SequenceActorTransition:CheckInit()
  self.HasInit = self:_CheckSequencePlayer()
  return self.HasInit
end
function SequenceActorTransition:_CheckSequencePlayer()
  print(bWriteLog and string.format("SequenceActorTransition:_CheckSequencePlayer CacheSequenceActor: %s", self.CacheSequenceActor))
  if not slua.isValid(self.CacheSequenceActor) then
    print(bWriteLog and string.format("SequenceActorTransition:_CheckSequencePlayer not slua.isValid(self.CacheSequenceActor)"))
    return false
  end
  print(bWriteLog and string.format("SequenceActorTransition:_CheckSequencePlayer SequencePlayer: %s", self.CacheSequenceActor.SequencePlayer))
  if slua.isValid(self.CacheSequenceActor.SequencePlayer) then
    self.SequencePlayer = self.CacheSequenceActor.SequencePlayer
    return true
  end
  print(bWriteLog and string.format("SequenceActorTransition:_CheckSequencePlayer return false"))
  return false
end
function SequenceActorTransition:Equal(SequenceActor)
  return self.CacheSequenceActor == SequenceActor
end
function SequenceActorTransition:Destroy()
  self.CacheSequenceActor = nil
  self.SequencePlayer = nil
end
function SequenceActorTransition:Play()
  if not self:_CheckSequencePlayer() then
    return
  end
  self:Jump(false)
  self.SequencePlayer:Play()
end
function SequenceActorTransition:PlayReverse()
  if not self:_CheckSequencePlayer() then
    return
  end
  self:Jump(true)
  self.SequencePlayer:PlayReverse()
end
function SequenceActorTransition:Stop()
  if not self:_CheckSequencePlayer() then
    return
  end
  self.SequencePlayer:Stop()
end
function SequenceActorTransition:Jump(bJumpToEnd)
  if not self:_CheckSequencePlayer() then
    return
  end
  if not bJumpToEnd then
    self.SequencePlayer:SetPlaybackPosition(0)
  else
    self.SequencePlayer:SetPlaybackPosition(self:GetLength())
  end
  self:Stop()
end
function SequenceActorTransition:GetLength()
  if not self:_CheckSequencePlayer() then
    return 0
  end
  return self.SequencePlayer:GetLength()
end
function SequenceActorTransition:SetAssetPath(AssetPath)
  self.SequencePlayer = nil
  if type(AssetPath) == "string" then
    local asset_util = require("common.asset_util")
    local Asset = asset_util.GetAssetSync(AssetPath)
    return self.CacheSequenceActor:SetSequence(Asset)
  else
    return self.CacheSequenceActor:SetSequence(AssetPath)
  end
end
local CSequenceActorTransition = class(object, nil, SequenceActorTransition)
local SequenceTransition = {}
function SequenceTransition:ctor(_, Sequence)
  if type(Sequence) == "function" then
    Sequence = Sequence()
  end
  if Sequence then
    self.Cache    self.HasInit = self:_CheckSequencePlayer()
  end
end
function SequenceTransition:_CheckSequencePlayer()
  if self.SequencePlayer == nil then
    if self.CacheSequence ~= nil then
      local Sequence = self.CacheSequence
      if Sequence.SequencePlayer then
        self.SequencePlayer = Sequence.SequencePlayer
        return slua.isValid(self.SequencePlayer)
      elseif Sequence.Play ~= nil then
        self.SequencePlayer = Sequence
        return slua.isValid(self.SequencePlayer)
      end
    end
    return false
  end
  return slua.isValid(self.SequencePlayer)
end
function SequenceTransition:Equal(Sequence)
  return self.CacheSequence and Sequence and self.CacheSequence.Sequence == Sequence.Sequence
end
function SequenceTransition:Destroy()
  self.SequencePlayer = nil
end
function SequenceTransition:Play()
  if not self:_CheckSequencePlayer() then
    return
  end
  self:Jump(false)
  self.SequencePlayer:Play()
end
function SequenceTransition:PlayWithJumpSeconds(nJumpSeconds)
  if not self:_CheckSequencePlayer() then
    return
  end
  if nJumpSeconds > self:GetLength() then
    nJumpSeconds = self:GetLength()
  end
  self.SequencePlayer:SetPlaybackPosition(nJumpSeconds)
  self:Stop()
  self.SequencePlayer:Play()
end
function SequenceTransition:PlayReverse()
  if not self:_CheckSequencePlayer() then
    return
  end
  self:Jump(true)
  self.SequencePlayer:PlayReverse()
end
function SequenceTransition:Stop()
  if not self:_CheckSequencePlayer() then
    return
  end
  self.SequencePlayer:Stop()
end
function SequenceTransition:Jump(bJumpToEnd)
  if not self:_CheckSequencePlayer() then
    return
  end
  if not bJumpToEnd then
    self.SequencePlayer:SetPlaybackPosition(0)
  else
    self.SequencePlayer:SetPlaybackPosition(self:GetLength())
  end
  self:Stop()
end
function SequenceTransition:GetLength()
  if not self:_CheckSequencePlayer() then
    return 0
  end
  return self.SequencePlayer:GetLength()
end
function SequenceTransition:SetAssetPath(AssetPath)
end
local CSequenceTransition = class(object, nil, SequenceTransition)
local TimelineTransition = {}
function TimelineTransition:ctor(_, Owner, Timeline, TimelinePlayFunc, TimelinePlayReverseFunc)
  assert(type(TimelinePlayFunc) == "function", "TimelinePlayFunc param must be a function")
  self.  self.  self.  self.  self.HasInit = true
end
function TimelineTransition:Equal(Timeline)
  return self.Timeline == Timeline
end
function TimelineTransition:Destroy()
  self.Owner = nil
  self.Timeline = nil
  self.TimelinePlayFunc = nil
  self.TimelinePlayReverseFunc = nil
end
function TimelineTransition:Play()
  if self.TimelinePlayFunc then
    self.TimelinePlayFunc(self.Owner)
  end
end
function TimelineTransition:PlayReverse()
  if self.TimelinePlayReverseFunc then
    self.TimelinePlayReverseFunc(self.Owner)
  end
end
function TimelineTransition:Stop()
  self.Timeline:Stop()
end
function TimelineTransition:Jump(bJumpToEnd)
  if not bJumpToEnd then
    self.Timeline:SetNewTime(0)
  else
    self.Timeline:SetNewTime(self:GetLength())
  end
end
function TimelineTransition:GetLength()
  return self.Timeline:GetTimelineLength()
end
function TimelineTransition:SetAssetPath(AssetPath)
end
local CTimelineTransition = class(object, nil, TimelineTransition)
local LevelSequenceTransition = {}
function LevelSequenceTransition:ctor(_, Config)
  self.  self.LevelSequenceActorPath = Config.LevelSequenceActorPath
  self.LevelSequencePath = Config.LevelSequencePath
  self.BindingListFunc = Config.BindingListFunc
  self.TransformFunc = Config.TransformFunc
  self.OwnerObject = Config.OwnerObject
  self.PlayOnServer = Config.PlayOnServer ~= false
  self.HasInit = self.LevelSequencePath ~= nil and self.LevelSequencePath ~= ""
  self._SequencePlayerReady = false
  self._PendingOperation = nil
end
function LevelSequenceTransition:_EnsureLevelSequenceActor()
  if slua.isValid(self.LevelSequenceActor) then
    return true
  end
  if not slua.isValid(self.OwnerObject) then
    return false
  end
  local Transform = FTransform()
  if self.TransformFunc then
    Transform = self.TransformFunc()
  else
    Transform = self.OwnerObject:GetTransform()
  end
  local BindingList
  if self.BindingListFunc then
    BindingList = self.BindingListFunc()
  end
  self.LevelSequenceActor = Game:PlayLevelSequence(self.OwnerObject, self.LevelSequencePath, Transform, self.LevelSequenceActorPath, false, BindingList, self.OwnerObject)
  if not slua.isValid(self.LevelSequenceActor) then
    return false
  end
  self.LevelSequenceActor.bPlayOnServer = self.PlayOnServer
  if slua.isValid(self.LevelSequenceActor.SequencePlayer) then
    self._SequencePlayerReady = true
  else
    self.LevelSequenceActor:SetOnSequencePlayerReceiveInitailizePlayerCallBack(function()
      FeatureUtil.printf("LevelSequenceTransition:_OnSequencePlayerReady %s", self.LevelSequencePath)
      self._SequencePlayerReady = true
      self:_ExecutePendingOperation()
    end, self.OwnerObject)
  end
  return true
end
function LevelSequenceTransition:_IsSequencePlayerReady()
  if self._SequencePlayerReady then
    return true
  end
  if slua.isValid(self.LevelSequenceActor) and slua.isValid(self.LevelSequenceActor.SequencePlayer) then
    self._SequencePlayerReady = true
    return true
  end
  return false
end
function LevelSequenceTransition:_ExecutePendingOperation()
  if not self._PendingOperation then
    return
  end
  local Op = self._PendingOperation
  self._PendingOperation = nil
  FeatureUtil.printf("LevelSequenceTransition:_ExecutePendingOperation type = %s", Op.Type)
  if Op.Type == "Play" then
    self:Play()
  elseif Op.Type == "PlayReverse" then
    self:PlayReverse()
  elseif Op.Type == "Jump" then
    self:Jump(Op.JumpToEnd)
  end
end
function LevelSequenceTransition:_GetSequencePlayer()
  if not self:_EnsureLevelSequenceActor() then
    return nil
  end
  return self.LevelSequenceActor.SequencePlayer
end
function LevelSequenceTransition:Equal(Config)
  if not Config then
    return false
  end
  return self.LevelSequencePath == Config.LevelSequencePath and self.LevelSequenceActorPath == Config.LevelSequenceActorPath
end
function LevelSequenceTransition:Destroy()
  self._PendingOperation = nil
  if slua.isValid(self.LevelSequenceActor) then
    self.LevelSequenceActor:K2_DestroyActor()
  end
  self.LevelSequenceActor = nil
  self.OwnerObject = nil
  self.Config = nil
  self.BindingListFunc = nil
  self.TransformFunc = nil
end
function LevelSequenceTransition:Play()
  self:_EnsureLevelSequenceActor()
  if not self:_IsSequencePlayerReady() then
    FeatureUtil.printf("LevelSequenceTransition:Play SequencePlayer not ready, pending")
    self._PendingOperation = {Type = "Play"}
    return
  end
  local SequencePlayer = self:_GetSequencePlayer()
  if not slua.isValid(SequencePlayer) then
    return
  end
  self:Jump(false)
  SequencePlayer:Play()
end
function LevelSequenceTransition:PlayReverse()
  self:_EnsureLevelSequenceActor()
  if not self:_IsSequencePlayerReady() then
    FeatureUtil.printf("LevelSequenceTransition:PlayReverse SequencePlayer not ready, pending")
    self._PendingOperation = {
      Type = "PlayReverse"
    }
    return
  end
  local SequencePlayer = self:_GetSequencePlayer()
  if not slua.isValid(SequencePlayer) then
    return
  end
  self:Jump(true)
  SequencePlayer:PlayReverse()
end
function LevelSequenceTransition:Stop()
  self._PendingOperation = nil
  local SequencePlayer = self:_GetSequencePlayer()
  if not slua.isValid(SequencePlayer) then
    return
  end
  SequencePlayer:Stop()
end
function LevelSequenceTransition:Jump(bJumpToEnd)
  self:_EnsureLevelSequenceActor()
  if not self:_IsSequencePlayerReady() then
    FeatureUtil.printf("LevelSequenceTransition:Jump SequencePlayer not ready, pending")
    self._PendingOperation = {Type = "Jump", JumpToEnd = bJumpToEnd}
    return
  end
  local SequencePlayer = self:_GetSequencePlayer()
  if not slua.isValid(SequencePlayer) then
    return
  end
  if not bJumpToEnd then
    SequencePlayer:SetPlaybackPosition(0)
  else
    SequencePlayer:SetPlaybackPosition(self:GetLength())
  end
  SequencePlayer:Stop()
end
function LevelSequenceTransition:GetLength()
  if not self:_IsSequencePlayerReady() then
    return 0
  end
  local SequencePlayer = self:_GetSequencePlayer()
  if not slua.isValid(SequencePlayer) then
    return 0
  end
  return SequencePlayer:GetLength()
end
function LevelSequenceTransition:SetAssetPath(AssetPath)
end
local CLevelSequenceTransition = class(object, nil, LevelSequenceTransition)
local TransitionFeature = {}
local ON_PLAY_EVENT = "OnPlay"
local ON_STOP_EVENT = "OnStop"
local ON_JUMP_EVENT = "OnJump"
function TransitionFeature:_PostConstruct()
  TransitionFeature.__super._PostConstruct(self)
  self._TransitionDelegate = FeatureUtil.LuaDelegate()
end
function TransitionFeature:ReceiveEndPlay(EndPlayReason)
  if EndPlayReason == import("EEndPlayReason").Destroyed then
    if self._TransitionObject then
      self._TransitionObject:Destroy()
      self._TransitionObject = nil
    end
    self._TransitionDelegate:Dispose()
  end
  TransitionFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function TransitionFeature:InitWithSequenceActor(SequenceActor)
  FeatureUtil.printf("%s TransitionFeature:InitWithSequenceActor %s", self, SequenceActor)
  if self._TransitionObject then
    if not self._TransitionObject:Equal(SequenceActor) then
      self._TransitionObject:Destroy()
      self._TransitionObject = CSequenceActorTransition(SequenceActor)
      return self._TransitionObject.HasInit
    else
      return self._TransitionObject:CheckInit()
    end
  else
    self._TransitionObject = CSequenceActorTransition(SequenceActor)
    return self._TransitionObject.HasInit
  end
end
function TransitionFeature:InitWithSequence(Sequence)
  FeatureUtil.printf("%s TransitionFeature:InitWithSequence %s", self, Sequence)
  if self._TransitionObject and not self._TransitionObject:Equal(Sequence) then
    self._TransitionObject:Destroy()
  end
  self._TransitionObject = CSequenceTransition(Sequence)
  return self._TransitionObject.HasInit
end
function TransitionFeature:InitWithTimeline(Timeline, TimelinePlayFunc, TimelinePlayReverseFunc)
  FeatureUtil.printf("%s TransitionFeature:InitWithTimeline", self.Owner.Object)
  if self._TransitionObject and not self._TransitionObject:Equal(Timeline) then
    self._TransitionObject:Destroy()
  end
  self._TransitionObject = CTimelineTransition(self.Owner, Timeline, TimelinePlayFunc, TimelinePlayReverseFunc)
  return self._TransitionObject.HasInit
end
function TransitionFeature:InitWithLevelSequence(Config)
  FeatureUtil.printf("%s TransitionFeature:InitWithLevelSequence %s", self.Owner.Object, Config.LevelSequencePath)
  if self._TransitionObject and not self._TransitionObject:Equal(Config) then
    self._TransitionObject:Destroy()
  end
  Config.OwnerObject = self.Owner.Object
  self._TransitionObject = CLevelSequenceTransition(Config)
  return self._TransitionObject.HasInit
end
function TransitionFeature:Play()
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:Play")
  self._TransitionDelegate:Broadcast(ON_PLAY_EVENT, {PlayReverse = false})
  self._TransitionObject:Play()
end
function TransitionFeature:PlayWithJumpSeconds(nJumpSeconds)
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:PlayWithJumpSeconds")
  self._TransitionDelegate:Broadcast(ON_PLAY_EVENT, {PlayReverse = false})
  self._TransitionObject:PlayWithJumpSeconds(nJumpSeconds)
end
function TransitionFeature:PlayReverse()
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:PlayReverse")
  self._TransitionDelegate:Broadcast(ON_PLAY_EVENT, {PlayReverse = true})
  self._TransitionObject:PlayReverse()
end
function TransitionFeature:Stop()
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:Stop")
  self._TransitionDelegate:Broadcast(ON_STOP_EVENT)
  self._TransitionObject:Stop()
end
function TransitionFeature:Jump(bJumpToEnd)
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:Jump %s", bJumpToEnd)
  self._TransitionObject:Jump(bJumpToEnd)
  self._TransitionDelegate:Broadcast(ON_JUMP_EVENT, bJumpToEnd)
end
function TransitionFeature:GetLength()
  self:_CheckInit()
  FeatureUtil.printf("TransitionFeature:GetLength")
  return self._TransitionObject:GetLength()
end
function TransitionFeature:SetAssetPath(AssetPath)
  self:_CheckInit()
  self._TransitionObject:SetAssetPath(AssetPath)
end
function TransitionFeature:OnPlay(Callback, Caller)
  self._TransitionDelegate:Add(ON_PLAY_EVENT, Callback, Caller)
  return self
end
function TransitionFeature:OnStop(Callback, Caller)
  self._TransitionDelegate:Add(ON_STOP_EVENT, Callback, Caller)
  return self
end
function TransitionFeature:OnJump(Callback, Caller)
  self._TransitionDelegate:Add(ON_JUMP_EVENT, Callback, Caller)
  return self
end
function TransitionFeature:_CheckInit()
  assert(self._TransitionObject ~= nil, "Please call TransitionInitWithSequence or TransitionInitWithTimeline first")
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, TransitionFeature)
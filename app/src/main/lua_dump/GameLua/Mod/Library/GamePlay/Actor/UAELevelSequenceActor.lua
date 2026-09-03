local UKismetSystemLibrary = import("KismetSystemLibrary")
local UGameplayStatics = import("GameplayStatics")
local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
local UAELevelSequenceActor = {}
function UAELevelSequenceActor:ctor()
end
function UAELevelSequenceActor:_PostConstruct()
end
function UAELevelSequenceActor:ReceiveBeginPlay()
  sandbox.LogNormal(bWriteLog and "UAELevelSequenceActor:ReceiveBeginPlay")
  self.UAESequenceUtilsInstance = UAESequenceUtils(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SEQUENCE_MSG, self.HandleEvtMsg, self)
  self.bIsDedicatedServer = UKismetSystemLibrary.IsDedicatedServer(self)
  UAELevelSequenceActor.__super.ReceiveBeginPlay(self)
  if self:IsAuthority() and self.DelayStartSinceReadyState >= 0 then
    local CurGameState = CGameState:GetGameModeState()
    if CurGameState == "ReadyState" then
      self:HandleEnterReady()
    else
      self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
        [1] = "ReadyState"
      }, self.HandleEnterReady, self)
    end
  elseif self.bClientCheckReleaseCameraCut then
    self:CheckReleaseCameraCutEvent()
  end
end
function UAELevelSequenceActor:ReceiveEndPlay(_)
  sandbox.LogNormal(bWriteLog and "UAELevelSequenceActor:ReceiveEndPlay")
  self.UAESequenceUtilsInstance = nil
  UAELevelSequenceActor.__super.ReceiveEndPlay(self, _)
end
function UAELevelSequenceActor:HandleEvtMsg(_, __, Player, MsgName, ...)
  if Player ~= self.Object then
    return
  end
  if self.UAESequenceUtilsInstance[MsgName] ~= nil then
    sandbox.LogNormal(bWriteLog and "UAELevelSequenceActor:HandleCommonEvtMsg:", MsgName, ...)
    self.UAESequenceUtilsInstance[MsgName](self.UAESequenceUtilsInstance, ...)
  elseif self[MsgName] ~= nil then
    sandbox.LogNormal(bWriteLog and "UAELevelSequenceActor:HandleSelfEvtMsg:", MsgName, ...)
    self[MsgName](self, ...)
  else
    sandbox.LogWarning("UAELevelSequenceActor Can not Handle Sequence Msg:" .. MsgName)
  end
  print(bWriteLog and "UAELevelSequenceActor:HandleEvtMsg")
  self:TryTriggerEventCallBack("OnSequenceEventMessageCallBack", Player, MsgName, ...)
end
function UAELevelSequenceActor:HandleEnterReady()
  local TimerDelay = 0
  if slua.isValid(CGameMode) and CGameMode.GameModeStateReadyEnterTime ~= nil and 0 < CGameMode.GameModeStateReadyEnterTime then
    TimerDelay = CGameMode.GameModeStateReadyEnterTime + self.DelayStartSinceReadyState - UGameplayStatics.GetRealTimeSeconds(self.Object)
  end
  if 0 < TimerDelay then
    self:AddGameTimer(TimerDelay, false, function()
      self:Play(0)
    end)
  else
    self:Play(-TimerDelay)
  end
end
function UAELevelSequenceActor:CheckReleaseCameraCutEvent()
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_TAKE_DAMAGE_CLIENT, self.HandleClientTakeDamage, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAYERSTATE_CHANGE_CLIENT, self.OnPlayerStateChanged, self)
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(uLocalPlayerCharacter) then
      self:AddControlEvent(uLocalPlayerCharacter, "OnAttachedToVehicle", self.ReceiveReleaseCameraCut, self)
    end
  end
end
function UAELevelSequenceActor:HandleClientTakeDamage(_, _, DamageInfo)
  if slua.isValid(self.SequencePlayer) and self.SequencePlayer:IsPlaying() then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
    if DamageInfo and slua.isValid(DamageInfo.Target) and DamageInfo.Target == uLocalPlayerCharacter then
      if DamageInfo.DamageType == UEnums.DamageType.PoisonDamage or DamageInfo.DamageType == UEnums.DamageType.DotDamage and DamageInfo.Source == nil then
        return
      end
      self:ReceiveReleaseCameraCut()
    end
  end
end
function UAELevelSequenceActor:OnPlayerStateChanged(_, __, InCharacter, nState, bEnterState)
  if slua.isValid(self.SequencePlayer) and self.SequencePlayer:IsPlaying() then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
    if InCharacter == uLocalPlayerCharacter then
      local EPawnState = import("EPawnState")
      if bEnterState and (nState == EPawnState.GunFire or nState == EPawnState.GunADS or nState == EPawnState.Pitch or nState == EPawnState.Prone or nState == EPawnState.HoldGrenade or nState == EPawnState.Dying or nState == EPawnState.Dead or nState == EPawnState.DriveVehicle or nState == EPawnState.InVehicle or nState == EPawnState.Vault or nState == EPawnState.SwitchPP or nState == EPawnState.Skill or nState == EPawnState.Revival or nState == EPawnState.Shoulder or nState == EPawnState.CarryBack or nState == EPawnState.BeCarriedBack or nState == EPawnState.Slide or nState == EPawnState.Move or nState == EPawnState.UseConsumables or nState == EPawnState.InPlane) then
        self:ReceiveReleaseCameraCut()
      end
    end
  end
end
function UAELevelSequenceActor:ReceiveReleaseCameraCut()
  if Client then
    self:ReleaseCameraCutTrack()
  end
end
function UAELevelSequenceActor:OnCameraCutCallBack(uCameraComp)
  if Client and self.bOwnerHideUI then
    local bInSeqCam = false
    if slua.isValid(uCameraComp) and slua.isValid(uCameraComp:GetOwner()) and uCameraComp:GetOwner():ActorHasTag("SequencerActor") then
      bInSeqCam = true
    end
    if bInSeqCam then
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_SEQUENCE_CAM)
    else
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local uLocalPlayerCharacter = GameplayData.GetPlayerController()
      if self.bClientCheckReleaseCameraCut and slua.isValid(uLocalPlayerCharacter) then
        uLocalPlayerCharacter:ServerVerifyViewTarget()
      end
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_SEQUENCE_CAM)
    end
  end
end
function UAELevelSequenceActor:SetOnSequenceFinishedCallBack(CallBackFunction, Owner)
  self:InternalSetEventCallBack("OnSequenceFinishedCallBack", CallBackFunction, Owner)
end
function UAELevelSequenceActor:SetOnSequenceEventMessageCallBack(CallBackFunction, Owner)
  self:InternalSetEventCallBack("OnSequenceEventMessageCallBack", CallBackFunction, Owner)
end
function UAELevelSequenceActor:SetOnSequencePlayerReceiveInitailizePlayerCallBack(CallBackFunction, Owner)
  self:InternalSetEventCallBack("OnSequencePlayerReceiveInitailizePlayerCallBack", CallBackFunction, Owner)
end
function UAELevelSequenceActor:ReceiveInitailizePlayer()
  self:TryTriggerEventCallBack("OnSequencePlayerReceiveInitailizePlayerCallBack", self)
  if slua.isValid(self.SequencePlayer) then
    self:AddControlEvent(self.SequencePlayer, "OnCameraCut", self.OnCameraCutCallBack, self)
  end
end
function UAELevelSequenceActor:InternalSetEventCallBack(EventName, CallBackFunction, Owner)
  if type(CallBackFunction) == "function" then
    self[EventName] = CallBackFunction
    if self.SequenceActorOwner == nil then
      self.SequenceActor    end
  else
    print(bWriteLog and string.format("UAELevelSequenceActor:InternalSetEventCallBack InValid Function EventName = %s", EventName))
  end
end
function UAELevelSequenceActor:TryTriggerEventCallBack(EventName, ...)
  if self[EventName] and (slua.isValid(self.SequenceActorOwner) or self.SequenceActorOwner.ForceEnableSequenceCallBack) then
    self[EventName](self.SequenceActorOwner, ...)
  end
end
function UAELevelSequenceActor:ReceiveOnPlay()
end
function UAELevelSequenceActor:ReceiveOnFinished()
  print(bWriteLog and string.format("UAELevelSequenceActor:ReceiveOnFinished"))
  self:TryTriggerEventCallBack("OnSequenceFinishedCallBack")
end
function UAELevelSequenceActor:ReceiveOnStop()
  if Client and self.bOwnerHideUI then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_SEQUENCE_CAM)
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CUAELevelSequenceActor = class(object, nil, UAELevelSequenceActor)
return CUAELevelSequenceActor
local GhostBalloonMoveObj = {}
local EPawnState = import("EPawnState")
local EAnimLayerType = import("EAnimLayerType")
local EGhostBalloonMoveState = import("EGhostBalloonMoveState")
local ECollisionEnabled = import("ECollisionEnabled")
local UGameplayStatics = import("GameplayStatics")
local GhostBalloonConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.GhostBalloon.GhostBalloonConfig")
local MoveAnimClassPath = "/Game/Library/Res/Skills/GhostBalloon/Arts_PlayerBluePrints/Skill/CH_Base_AnimBP_Movement_GhostBalloon.CH_Base_AnimBP_Movement_GhostBalloon_C"
function GhostBalloonMoveObj:ctor()
  print(bWriteLog and "GhostBalloonMoveObj:ctor")
end
function GhostBalloonMoveObj:OnEnterCustomMove(CustomMode)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not slua.isValid(self.CharacterOwner.STCharacterMovement) then
    return
  end
  print(bWriteLog and "GhostBalloonMoveObj:OnEnterCustomMove")
  self.CharacterOwner.STCharacterMovement.Velocity = FVector.ZeroVector
  if Client then
    self:ShowControlUI(true)
    self.AsyncLoadHandle = self:AsyncLoadAsset(MoveAnimClassPath, function(uClass)
      if slua.isValid(uClass) then
        self.CharacterOwner:SetEnableMoveLayer(true, uClass)
        print(bWriteLog and "GhostBalloonMoveObj:SetEnableMoveLayer true")
        local uCharAnimInstance = self.CharacterOwner:GetCurrentMainLogicAnimInstance(false)
        if slua.isValid(uCharAnimInstance) then
          local LocalSkillIDArray = uCharAnimInstance.DisableHandIKAndObstructedSkillID
          LocalSkillIDArray:AddUnique(GhostBalloonConfig.SkillID)
          uCharAnimInstance.DisableHandIKAndObstructedSkillID = LocalSkillIDArray
          print(bWriteLog and "GhostBalloonMoveObj:OnEnterCustomMove DisableHandIKAndObstructedSkillID Num:" .. tostring(uCharAnimInstance.DisableHandIKAndObstructedSkillID:Num()))
        end
      end
    end)
  else
    self.CharacterOwner:EnterState(EPawnState.GhostBalloon)
    self:AddControlEvent(self.CharacterOwner, "OnShootVerifyScaleDelegate", self.HandleOnOnShootVerifyScaleDelegate, self)
    self:AddControlEventWithCondition(self.CharacterOwner, "StateInterruptedHandlerBP", {
      State = EPawnState.GhostBalloon
    }, self.HandleCharacterStateInterrupted, self)
  end
  self.CharacterOwner:SetAttrValue(self.FuelAttrName, self.InitialFuel, -1)
  local SkillID = GhostBalloonConfig.SkillID
  local SkillLevel = self.CharacterOwner:GetSkillLevel(SkillID)
  if GhostBalloonConfig.LevelConfig[SkillLevel] then
    self.CharacterOwner:SetAttrValue(self.FuelMaxAttrName, GhostBalloonConfig.LevelConfig[SkillLevel].MaxFuel, -1)
    self.ChargeSpeedScale = GhostBalloonConfig.LevelConfig[SkillLevel].ChargeSpeedScale
    self.LaunchSpeedScale = GhostBalloonConfig.LevelConfig[SkillLevel].LaunchSpeedScale
    if slua.isValid(self.CharacterOwner.SkillManager) then
      local uBalloon = self.CharacterOwner.SkillManager:GetValueAsWeakObject(SkillID, "BalloonActor")
      if slua.isValid(uBalloon) then
        uBalloon:SetScale(GhostBalloonConfig.LevelConfig[SkillLevel].BalloonScale)
      end
    end
  end
end
function GhostBalloonMoveObj:OnLeaveCustomMove(CustomMode)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not slua.isValid(self.CharacterOwner.STCharacterMovement) then
    return
  end
  print(bWriteLog and "GhostBalloonMoveObj:OnLeaveCustomMove")
  self.CharacterOwner.STCharacterMovement.Velocity = FVector.ZeroVector
  if Client then
    self:ShowControlUI(false)
    local uAnimParamsComp = self.CharacterOwner:GetAnimParamsComponent()
    if slua.isValid(uAnimParamsComp) then
      uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.MoveLayer", nil, true)
    end
    self.CharacterOwner:SetEnableMoveLayer(false, nil)
    print(bWriteLog and "GhostBalloonMoveObj:SetEnableMoveLayer false")
    if self.AsyncLoadHandle ~= nil then
      self:CancelAsyncLoad(self.AsyncLoadHandle)
      self.AsyncLoadHandle = nil
    end
    local uCharAnimInstance = self.CharacterOwner:GetCurrentMainLogicAnimInstance(false)
    if slua.isValid(uCharAnimInstance) then
      local LocalSkillIDArray = uCharAnimInstance.DisableHandIKAndObstructedSkillID
      for i = LocalSkillIDArray:Num() - 1, 0, -1 do
        local SkillID = LocalSkillIDArray:Get(i)
        if SkillID == GhostBalloonConfig.SkillID then
          LocalSkillIDArray:Remove(i)
        end
      end
      uCharAnimInstance.DisableHandIKAndObstructedSkillID = LocalSkillIDArray
      print(bWriteLog and "GhostBalloonMoveObj:OnLeaveCustomMove DisableHandIKAndObstructedSkillID Num:" .. tostring(uCharAnimInstance.DisableHandIKAndObstructedSkillID:Num()))
    end
  else
    self.CharacterOwner:LeaveState(EPawnState.GhostBalloon)
    self:RemoveControlEvent(self.CharacterOwner, "OnShootVerifyScaleDelegate")
    self:RemoveControlEvent(self.CharacterOwner, "StateInterruptedHandlerBP")
  end
  local SkillID = GhostBalloonConfig.SkillID
  self.CharacterOwner:SetAttrValue(self.FuelAttrName, 0, -1)
  self.CharacterOwner:SetAttrValue(self.FuelMaxAttrName, 100, -1)
  self.ChargeSpeedScale = 1
  self.LaunchSpeedScale = 1
  if slua.isValid(self.CharacterOwner.SkillManager) then
    local uBalloon = self.CharacterOwner.SkillManager:GetValueAsWeakObject(SkillID, "BalloonActor")
    if slua.isValid(uBalloon) then
      uBalloon:SetScale(1)
    end
  end
end
function GhostBalloonMoveObj:HandleCharacterStateInterrupted(State, InterruptBy)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not slua.isValid(self.CharacterOwner.SkillManager) then
    return
  end
  print(bWriteLog and "GhostBalloonMoveObj HandleCharacterStateInterrupted:" .. tostring(InterruptBy))
  if State == EPawnState.GhostBalloon and slua.isValid(self.CharacterOwner.SkillManager) then
    local UTSkillStopReason = import("UTSkillStopReason")
    local SkillID = GhostBalloonConfig.SkillID
    self.CharacterOwner.SkillManager:StopSkill(SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
  end
end
function GhostBalloonMoveObj:HandleOnOnShootVerifyScaleDelegate()
  if not slua.isValid(self.CharacterOwner) then
    print(bWriteLog and "GhostBalloonMoveObj HandleOnOnShootVerifyScaleDelegate uCharacter is nil")
    return
  end
  self.CharacterOwner.FeatureDynamicVertifyHitBoxScale = FVector(5, 5, 3)
end
function GhostBalloonMoveObj:ShowControlUI(bEnable)
  if not Client then
    return
  end
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not self.CharacterOwner:IsLocallyControlled() then
    return
  end
  local ui_manager = require("client.slua_ui_framework.manager")
  if not ui_manager.UI_Config_InGame.GhostBalloonControlUI then
    return
  end
  print(bWriteLog and "GhostBalloonMoveObj:ShowControlUI:" .. tostring(bEnable))
  if bEnable then
    ui_manager.ShowUI(ui_manager.UI_Config_InGame.GhostBalloonControlUI)
  else
    ui_manager.HideUI(ui_manager.UI_Config_InGame.GhostBalloonControlUI)
  end
end
function GhostBalloonMoveObj:HandleMoveStateChange(NewMoveState, OldMoveState)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if OldMoveState == EGhostBalloonMoveState.Rise then
    if self.StartFlyTime then
      local flyTime = UGameplayStatics.GetTimeSeconds(self.CharacterOwner) - self.StartFlyTime
      local uPlayerState = self.CharacterOwner:GetPlayerStateSafety()
      if slua.isValid(uPlayerState) then
        uPlayerState:AddGeneralCount(1782, math.floor(flyTime * 1000), false)
      end
      self.StartFlyTime = nil
    end
  elseif OldMoveState == EGhostBalloonMoveState.Float and self.StartFlyTime then
    local flyTime = UGameplayStatics.GetTimeSeconds(self.CharacterOwner) - self.StartFlyTime
    local uPlayerState = self.CharacterOwner:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1784, math.floor(flyTime * 1000), false)
    end
    self.StartFlyTime = nil
  end
  print(bWriteLog and "GhostBalloonMoveObj:HandleMoveStateChange:" .. tostring(NewMoveState))
  if NewMoveState == EGhostBalloonMoveState.Rise then
    self.StartFlyTime = UGameplayStatics.GetTimeSeconds(self.CharacterOwner)
  elseif NewMoveState == EGhostBalloonMoveState.Float then
    self.StartFlyTime = UGameplayStatics.GetTimeSeconds(self.CharacterOwner)
  elseif NewMoveState == EGhostBalloonMoveState.Burst then
    local MaxFuel = self.CharacterOwner:GetAttrValue(self.FuelMaxAttrName)
    self.CharacterOwner:SetAttrValue(self.FuelAttrName, MaxFuel, -1)
  end
end
local class = require("class")
local object = require("common.delegate_container")
local CGhostBalloonMoveObj = class(object, nil, GhostBalloonMoveObj)
return CGhostBalloonMoveObj
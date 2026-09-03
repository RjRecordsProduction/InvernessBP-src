local HearingTraningAICharacter = {}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
function HearingTraningAICharacter:ctor()
  self.bShowFrame = false
  self.ShootingPose = -1
  self.CheckShowFrameTimer = nil
  self.OwnerPlayerKey = -1
end
function HearingTraningAICharacter:_PostConstruct()
  HearingTraningAICharacter.__super._PostConstruct(self)
end
function HearingTraningAICharacter:ReceiveBeginPlay()
  print(bWriteLog and "HearingTraningAICharacter:ReceiveBeginPlay")
  HearingTraningAICharacter.__super.ReceiveBeginPlay(self)
  if not self:IsAuthority() then
    self:CreateFrameUIBillBoard()
  else
    self:AddControlEvent(self, "OnDeathDelegate", self.HandleOnDeath, self)
  end
end
function HearingTraningAICharacter:ReceiveEndPlay(EndPlayReason)
  HearingTraningAICharacter.__super.ReceiveEndPlay(self, EndPlayReason)
end
function HearingTraningAICharacter:GetLifetimeReplicatedProps()
  print(bWriteLog and "HearingTraningAICharacter:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bShowFrame",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function HearingTraningAICharacter:OnRep_bShowFrame()
  print(bWriteLog and "HearingTraningAICharacter:OnRep_bShowFrame", self.bShowFrame)
  if self.bShowFrame then
    if self.CheckShowFrameTimer then
      self:RemoveGameTimer(self.CheckShowFrameTimer)
      self.CheckShowFrameTimer = nil
    end
    self.CheckShowFrameTimer = self:AddGameTimer(0.5, true, function()
      self:ShowFrameTick()
    end)
  else
    if self.CheckShowFrameTimer then
      self:RemoveGameTimer(self.CheckShowFrameTimer)
      self.CheckShowFrameTimer = nil
    end
    self:ShowFrameUI(false)
  end
end
function HearingTraningAICharacter:ShowFrameTick()
  if Client then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.GetCurPlayerCharacter then
      local uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
      if slua.isValid(uPlayerCharacter) then
        local TargetLocation = self:K2_GetActorLocation()
        if self.GetHeadLocation then
          TargetLocation = self:GetHeadLocation(false)
        end
        local bVisible = Game:IsTargetPosVisible(uPlayerCharacter:GetHeadLocation(false), TargetLocation, {uPlayerCharacter})
        self:ShowFrameUI(not bVisible)
      end
    end
  end
end
function HearingTraningAICharacter:InitHearingTraningAI(InTable)
  if InTable == nil then
    return
  end
  local nTraningMode = InTable.TrainingMode or 0
  local nWeaponType = InTable.WeaponType or 1
  local nWeaponID = InTable.WeaponID or 101001
  local nTeamID = InTable.TeamID or 1
  local nMoveMode = InTable.MovementMode or 0
  local nShootingPose = InTable.ShootingPose or 0
  local nShootingInterval = InTable.ShootingInterval or 2.5
  local nShootingCD = InTable.ShootingCD or 0.1
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "HearingGameMode", nTraningMode)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "CustomWeaponType", nWeaponType)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "CustomWeaponID", nWeaponID)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "CustomTeamID", nTeamID)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "CustomMovementMode", nMoveMode)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Int, "CustomShootingPose", nShootingPose)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Float, "CustomGunFireInterval", nShootingInterval)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Float, "CustomGunFireCD", nShootingCD)
  Game:SetAIBlackboardValue(self.Object, UEnums.EBlackBoardKeyType.Bool, "IsInFightingState", true)
end
function HearingTraningAICharacter:CreateFrameUIBillBoard()
  print(bWriteLog and "HearingTraningAICharacter:CreateFrameUIBillBoard")
  if not self:IsFrameUIBillBoradExist() then
    local MaterialBillboardComp = import("MaterialBillboardComponent")
    self.FrameUIBillboard = Game:AddComponent(MaterialBillboardComp, self, "FrameUIBillBoard")
    if self.FrameUIBillboard then
      self.FrameUIBillboard:SetTranslucentSortPriority(1)
      local Util = require("client.slua_ui_framework.util")
      Util.GetAssetAsync(SingleTrainingConfig.FrameMaterialPath, function(LoadObj)
        if slua.isValid(LoadObj) then
          self.FrameMaterial = LoadObj
          self:AddBillboardElementIfConditionOk()
        end
      end)
      Util.GetAssetAsync(SingleTrainingConfig.FrameDistanceSizeCurve, function(LoadObj)
        if slua.isValid(LoadObj) then
          self.FrameSizeCurve = LoadObj
          self:AddBillboardElementIfConditionOk()
        end
      end)
    end
  end
end
function HearingTraningAICharacter:IsFrameUIBillBoradExist()
  return self.FrameUIBillboard ~= nil
end
function HearingTraningAICharacter:AddBillboardElementIfConditionOk()
  if self.FrameUIBillboard and self.FrameMaterial and self.FrameSizeCurve then
    self.FrameUIBillboard:AddElement(self.FrameMaterial, nil, false, 50, 25, self.FrameSizeCurve)
    local EAttachmentRule = import("EAttachmentRule")
    self.FrameUIBillboard:K2_AttachToComponent(self.CapsuleComponent, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
    self:ShowFrameUI(false)
  end
end
function HearingTraningAICharacter:ShowFrameUI(bShow)
  print(bWriteLog and "HearingTraningAICharacter:ShowFrameUI", bShow)
  if not self:IsFrameUIBillBoradExist() then
    self:CreateFrameUIBillBoard()
  end
  if self.FrameUIBillboard then
    self.FrameUIBillboard:SetVisibility(bShow, false)
  end
end
function HearingTraningAICharacter:SetShowFrame(bShow)
  self.bShowFrame = bShow
end
function HearingTraningAICharacter:SetShootingPose(Pose)
  self.Shootingend
function HearingTraningAICharacter:GetShootingPose()
  return self.ShootingPose
end
function HearingTraningAICharacter:GetOwnerPlayerKey()
  return self.OwnerPlayerKey
end
function HearingTraningAICharacter:SetOwnerPlayerKey(PlayerKey)
  self.Ownerend
function HearingTraningAICharacter:HandleOnDeath()
  print(bWriteLog and "HearingTraningAICharacter:HandleOnDeath")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController(self:GetOwnerPlayerKey())
  if slua.isValid(uPlayerController) and uPlayerController.ChanllengeKillOneAI then
    uPlayerController:ChanllengeKillOneAI(self)
  end
end
local class = require("class")
local CCharacterBase = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerCharacterBase")
local CHearingTraningAICharacter = class(CCharacterBase, nil, HearingTraningAICharacter)
return CHearingTraningAICharacter
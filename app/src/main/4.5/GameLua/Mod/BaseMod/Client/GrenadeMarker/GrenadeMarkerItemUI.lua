local GrenadeMarkerItemUI = {}
local UGameplayStatics = import("GameplayStatics")
local BusinessHelper = import("BusinessHelper")
local GrenadeMarkerConfig = require("GameLua.Mod.BaseMod.Client.GrenadeMarker.GrenadeMarkerConfig")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local Actor_C = import("/Script/Engine.Actor")
function GrenadeMarkerItemUI:Initialize()
  print(bWriteLog and "GrenadeMarkerItemUI:Initialize")
  self.bCanEverTick = true
  self.bHasPlayAnim = false
  self.LeftTime = 0.0
  self.LifeTime = 7.0
  self.SpeedUpAnimLeftTime = 3.0
  self.VisibleRange = 300
  self.InvisibleRange = 1110
  self.AnimSpeed = 1.0
  self.BlockTest = false
end
function GrenadeMarkerItemUI:OnDestroy()
  print(bWriteLog and "GrenadeMarkerItemUI:OnDestroy")
  self.GrenadeTipsSpeedCurve = nil
  self.CacheGrenade = nil
  local utility = require("common.utility")
  utility.DisposeDelegateContainer(self)
end
function GrenadeMarkerItemUI:UnregistControlEvent()
  print(bWriteLog and "GrenadeMarkerItemUI:UnregistControlEvent")
end
function GrenadeMarkerItemUI:InitData(InGrenadeID, GrenadeBrush, Location, uGrenade, SpawnTime)
  print(bWriteLog and "GrenadeMarkerItemUI:InitData:", InGrenadeID, uGrenade, Location:ToString(), SpawnTime)
  if GrenadeMarkerConfig and GrenadeMarkerConfig.GrenadeID2Config then
    GrenadeConfigData = GrenadeMarkerConfig.GrenadeID2Config[InGrenadeID]
    local bBlockMarker = false
    if GrenadeConfigData and GrenadeConfigData.InValidCallback and GrenadeConfigData.InValidCallback() then
      bBlockMarker = true
      self.LifeTime = 0.0
      self.VisibleRange = 0
      self.BlockTest = true
    end
    if GrenadeConfigData and not bBlockMarker then
      print(bWriteLog and "GrenadeMarkerItemUI:InitData GrenadeMarkerConfig")
      self.LifeTime = GrenadeConfigData.LifeTime
      self.VisibleRange = GrenadeConfigData.VisibleRange
      self.InvisibleRange = GrenadeConfigData.InvisibleRange
      self.AnimSpeed = GrenadeConfigData.AnimSpeed
      self.SpeedUpAnimLeftTime = GrenadeConfigData.SpeedUpAnimLeftTime
      self.BlockTest = GrenadeConfigData.BlockTest
    end
  end
  self.bHasPlayAnim = false
  self:StopAnimation(self.FreshAnimation)
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  self.LeftTime = self.LifeTime - (UGameplayStatics.GetRealTimeSeconds(worldContextObject) - SpawnTime)
  self.Target  self.CacheGrenade = uGrenade
  self.Image_Icon:SetBrush(GrenadeBrush)
  self.Image_Icon_HL:SetBrush(GrenadeBrush)
  self.Image_Arrow:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self.Image_Icon:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self.Image_Bg:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  self.Image_Icon_HL:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
end
function GrenadeMarkerItemUI:Tick(Geometry, DeltaTime)
  self:TickGrenadeItem(DeltaTime)
end
function GrenadeMarkerItemUI:TickGrenadeItem(DeltaTime)
  if slua.isValid(self.CacheGrenade) then
    self.TargetLocation = self.CacheGrenade:K2_GetActorLocation()
  end
  local Angle = self:CalWorldToUIShowAngle()
  self.MarkerPanel:SetRenderAngle(Angle)
  self.Image_Icon:SetRenderAngle(-Angle)
  self.Image_Icon_HL:SetRenderAngle(-Angle)
  self:TickAlpha()
  self:TickNearExplode(DeltaTime)
end
function GrenadeMarkerItemUI:TickAlpha()
  local PlayerController = UGameplayStatics.GetPlayerController(self, 0)
  if slua.isValid(PlayerController) and PlayerController.GetCurPawn then
    local Alpha = 0
    if PlayerController:GetCurPawn() then
      local Direction
      local SelfLoc = PlayerController:GetCurPawnLocation()
      local TargetLoc = self.TargetLocation
      if slua.isValid(self.CacheGrenade) then
        Direction = SelfLoc - self.CacheGrenade:K2_GetActorLocation()
        TargetLoc = self.CacheGrenade:K2_GetActorLocation()
      else
        Direction = SelfLoc - self.TargetLocation
      end
      local Dis2Player = math.sqrt(Direction.X * Direction.X + Direction.Y * Direction.Y)
      print(bWriteLog and "GrenadeMarkerItemUI:TickAlpha Dis2Player:", Dis2Player)
      if Dis2Player <= self.VisibleRange then
        Alpha = 1.0
        if self.BlockTest and self:LineTraceBlock(SelfLoc, TargetLoc, PlayerController) then
          Alpha = 0
        end
      elseif 0 >= self.InvisibleRange - self.VisibleRange then
        Alpha = 0.0
      else
        Alpha = 1.0 - (Dis2Player - self.VisibleRange) / (self.InvisibleRange - self.VisibleRange)
        if self.BlockTest and self:LineTraceBlock(SelfLoc, TargetLoc, PlayerController) then
          Alpha = 0
        end
      end
    end
    self.Image_Arrow:SetOpacity(Alpha)
    self.Image_Icon:SetOpacity(Alpha)
    self.Image_Bg:SetOpacity(Alpha)
    self.Image_Icon_HL:SetOpacity(Alpha)
  end
end
function GrenadeMarkerItemUI:TickNearExplode(DeltaTime)
  if self.LeftTime > 0 then
    self.LeftTime = self.LeftTime - DeltaTime
    if self.bHasPlayAnim then
      if slua.isValid(self.GrenadeTipsSpeedCurve) and self.GrenadeTipsSpeedCurve.GetFloatValue and self.LeftTime <= self.SpeedUpAnimLeftTime then
        local floatValue = self.GrenadeTipsSpeedCurve:GetFloatValue(self.SpeedUpAnimLeftTime - self.LeftTime)
        if floatValue ~= self.AnimSpeed then
          print(bWriteLog and "GrenadeMarkerItemUI:TickNearExplode floatValue:", floatValue)
          self.AnimSpeed = floatValue
          self:SetPlaybackSpeed(self.FreshAnimation, self.AnimSpeed)
        end
      end
      return
    end
    if self.LeftTime <= self.SpeedUpAnimLeftTime then
      self.bHasPlayAnim = true
      self:PlayUserWidgetAnimation(self.FreshAnimation, 0, 0, 0, 1)
    end
  else
    print(bWriteLog and "GrenadeMarkerItemUI:TickNearExplode 111")
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function GrenadeMarkerItemUI:LineTraceBlock(Start, End, uWorldContext)
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  local StandHit, proneHit = false
  local ObjectTypes = slua.Array(UEnums.EPropertyClass.Int)
  ObjectTypes:Add(ECollisionChannel.ECC_WorldStatic)
  local bHit, ActorsOut = UKismetSystemLibrary.LineTraceSingleForObjects(uWorldContext, Start, End, ObjectTypes, false, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor(1, 1, 1, 1), FLinearColor(1, 1, 1, 1), 5)
  if bHit then
    StandHit = true
  end
  Start.Z = Start.Z - 68
  bHit, ActorsOut = UKismetSystemLibrary.LineTraceSingleForObjects(uWorldContext, Start, End, ObjectTypes, false, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor(1, 1, 1, 1), FLinearColor(1, 1, 1, 1), 5)
  if bHit then
    proneHit = true
  end
  return StandHit and proneHit
end
local class = require("class")
local object = require("object")
return class(object, nil, GrenadeMarkerItemUI)
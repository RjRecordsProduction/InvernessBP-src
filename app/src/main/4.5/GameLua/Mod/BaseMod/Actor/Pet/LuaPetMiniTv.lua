local LuaPetMiniTv = {}
local EPawnState = import("EPawnState")
local EPetState = import("EPetState")
local UKismetSystemLibrary = import("KismetSystemLibrary")
function LuaPetMiniTv:ctor()
  self.RelativePetID = 0
  self.DisableTickTimer = nil
end
function LuaPetMiniTv:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "RelativePetID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function LuaPetMiniTv:ReceiveBeginPlay()
  print(bWriteLog and "LuaPetMiniTv:ReceiveBeginPlay")
  LuaPetMiniTv.__super.ReceiveBeginPlay(self)
  self.bShowLocal = true
  self.bIsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if not self.bIsDS then
    self:AddControlEvent(self.Object, "OnPetStateChangeDelegate", self.ReceiveStateChanged, self)
    self:CheckAndRegisterVisibilitySwitch()
  end
  self:InitLocalVisibilityConfig()
end
function LuaPetMiniTv:ReceiveEndPlay(EndReason, bClearTable)
  print(bWriteLog and "LuaPetMiniTv:ReceiveEndPlay", tostring(EndReason))
  if not self.bIsDS then
    self:RemoveControlEvent(self.Object, "OnPetStateChangeDelegate")
  end
  LuaPetMiniTv.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function LuaPetMiniTv:PetOwnerCharacterBecomeValid()
  LuaPetMiniTv.__super.PetOwnerCharacterBecomeValid(self)
  self:CheckAndRegisterVisibilitySwitch()
end
function LuaPetMiniTv:InitLocalVisibilityConfig()
  if self.bIsDS then
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
  if bOwnerIsAutonomous then
    self.bShowLocal = SettingModule:GetOptionValue("ShowMiniTvInFighting")
  else
    self.bShowLocal = SettingModule:GetOptionValue("ShowOtherMiniTvInFighting")
  end
  print(bWriteLog and "LuaPetMiniTv:InitLocalVisibilityConfig bShowLocal:", tostring(self.bShowLocal), "bOwnerIsAutonomous:", tostring(bOwnerIsAutonomous))
  if not self.bShowLocal then
    self:SetPetVisibility(false)
    self:SetActorHiddenInGameMask(true, 7)
    self:SetSyncSmoothTickEnabled(false)
  else
    self:SetActorHiddenInGameMask(false, 7)
    self:SetSyncSmoothTickEnabled(true)
  end
end
function LuaPetMiniTv:ReceiveStateChanged(eState, value)
  print(bWriteLog and "LuaPetMiniTv:ReceiveStateChanged", tostring(eState), tostring(value))
  if self.bIsDS then
    return
  end
  if eState == EPetState.PetSwimming then
    self:SetBubbleWater(value)
  end
end
function LuaPetMiniTv:SetBubbleWater(bFilled)
  print(bWriteLog and "LuaPetMiniTv:SetBubbleWater", tostring(bFilled))
  if self.bIsDS then
    return
  end
  if not slua.isValid(self.Bubble) then
    return
  end
  local waterHeight = bFilled and 55 or -60
  for Index = 0, 1 do
    local mat = self.Bubble:GetMaterial(Index)
    if slua.isValid(mat) then
      if not mat.SetScalarParameterValue then
        mat = self.Bubble:CreateDynamicMaterialInstance(Index, mat)
      end
      if mat.SetScalarParameterValue then
        mat:SetScalarParameterValue("Water Surface Height", waterHeight)
      end
    end
  end
end
function LuaPetMiniTv:SelfPetVisibleSettingChanged(bShow)
  print(bWriteLog and "LuaPetMiniTv:SelfPetVisibleSettingChanged", tostring(bShow))
  if self.bIsDS then
    return
  end
  local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
  if not bOwnerIsAutonomous then
    return
  end
  if not self.bShowLocal then
    self:SetPetVisibility(false)
    print(bWriteLog and "LuaPetMiniTv:SelfPetVisibleSettingChanged not self.bShowLocal hide")
    return
  end
  local bPetHasDisappearState = self.PetHasDisappearState and self:PetHasDisappearState()
  local bPetHidden = self.bPetHidden
  print(bWriteLog and "LuaPetMiniTv:SelfPetVisibleSettingChanged", tostring(bShow), tostring(bPetHasDisappearState), tostring(bPetHidden))
  if (bPetHasDisappearState or bPetHidden) and bShow then
    return
  end
  self:SetPetVisibility(bShow)
end
function LuaPetMiniTv:SetupFightPetParams()
end
function LuaPetMiniTv:OtherPetVisibleSettingChanged(bShow)
  print(bWriteLog and "LuaPetMiniTv:OtherPetVisibleSettingChanged", tostring(bShow))
  if self.bIsDS then
    return
  end
  if not slua.isValid(self.Object) then
    return
  end
  local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
  if bOwnerIsAutonomous then
    return
  end
  if not self.bShowLocal then
    self:SetPetVisibility(false)
    return
  end
  local bPetHasDisappearState = self.PetHasDisappearState and self:PetHasDisappearState()
  local bPetHidden = self.bPetHidden
  print(bWriteLog and "LuaPetMiniTv:OtherPetVisibleSettingChanged", tostring(bShow), tostring(bPetHasDisappearState), tostring(bPetHidden))
  if (bPetHasDisappearState or bPetHidden) and bShow then
    return
  end
  self:SetPetVisibility(bShow)
end
function LuaPetMiniTv:MiniTvVisibleSettingChanged(bShow)
  print(bWriteLog and "LuaPetMiniTv:MiniTvVisibleSettingChanged", bShow)
  if self.bIsDS then
    return
  end
  if not slua.isValid(self.Object) then
    return
  end
  self.bShowLocal = bShow
  if not self.bShowLocal then
    self:SetPetVisibility(false)
    self:SetActorHiddenInGameMask(true, 7)
    self:SetSyncSmoothTickEnabled(false)
    return
  end
  self:SetActorHiddenInGameMask(false, 7)
  self:SetSyncSmoothTickEnabled(true)
  local bPetHasDisappearState = self.PetHasDisappearState and self:PetHasDisappearState()
  local bPetHidden = self.bPetHidden
  print(bWriteLog and "LuaPetMiniTv:MiniTvVisibleSettingChanged", tostring(bShow), tostring(bPetHasDisappearState), tostring(bPetHidden))
  if (bPetHasDisappearState or bPetHidden) and bShow then
    return
  end
  self:SetPetVisibility(bShow)
end
function LuaPetMiniTv:OnRep_RelativePetID()
  print("LuaPetMiniTv:OnRep_RelativePetID")
  if not self.bShowLocal then
    self:SetPetVisibility(false)
  end
end
function LuaPetMiniTv:OnPlayerAttachedToVehicle()
  log(bWriteLog and "LuaPetMiniTv:OnPlayerAttachedToVehicle.  ")
  self.Controller.BrainComponent:StopLogic("")
  self.HideOnAttachTimer = self:AddGameTimer(0.3, false, function()
    self:SetActorHiddenInGameMask(true, 6)
  end)
end
function LuaPetMiniTv:OnPlayerOnDetachedFromVehicle()
  log(bWriteLog and "LuaPetMiniTv:OnPlayerOnDetachedFromVehicle.  ")
  if self.HideOnAttachTimer then
    self:RemoveGameTimer(self.HideOnAttachTimer)
    self.HideOnAttachTimer = nil
  end
  self.Controller.BrainComponent:RestartLogic()
  self:SetActorHiddenInGameMask(false, 6)
end
function LuaPetMiniTv:CheckAndRegisterVisibilitySwitch()
  if self._bMiniTvSettingRegistered then
    log(bWriteLog and "LuaPetMiniTv:CheckAndRegisterVisibilitySwitch has already registered")
    return
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    log(bWriteLog and "LuaPetMiniTv:CheckAndRegisterVisibilitySwitch register switch change")
    local bOwnerIsAutonomous = self.PetOwnerIsAutonomous and self:PetOwnerIsAutonomous()
    local settingKey = bOwnerIsAutonomous and "ShowMiniTvInFighting" or "ShowOtherMiniTvInFighting"
    self._bMiniTvSettingRegistered = true
    self:AddSettingOptionEvent(settingKey, function(bMiniTvShowFlag)
      print(bWriteLog and "LuaPetMiniTv bMiniTvShowFlag: " .. tostring(bMiniTvShowFlag) .. " settingKey: " .. settingKey)
      if self.MiniTvVisibleSettingChanged then
        self:MiniTvVisibleSettingChanged(bMiniTvShowFlag)
      end
    end)
  end
end
function LuaPetMiniTv:SetSyncSmoothTickEnabled(bEnabled)
  if self.bIsDS then
    return
  end
  local syncSmoothComp = self.GetSyncSmoothComponent and self:GetSyncSmoothComponent()
  syncSmoothComp = syncSmoothComp or self.PetSimulateSyncSmooth
  if syncSmoothComp and syncSmoothComp.SetComponentTickEnabled then
    print(bWriteLog and "LuaPetMiniTv:SetSyncSmoothTickEnabled " .. tostring(bEnabled))
    syncSmoothComp:SetComponentTickEnabled(bEnabled)
  end
end
function LuaPetMiniTv:SetPetVisibility(bVisible)
  log(bWriteLog and "LuaPetMiniTv:SetPetVisibility bVisible: " .. tostring(bVisible))
  if not slua.isValid(self.Object) then
    return
  end
  if not self.Super.SetPetVisibility then
    log_error("LuaPetMiniTv:SetPetVisibility Super.SetPetVisibility is not valid")
    return
  end
  if Client and not self.bShowLocal then
    log(bWriteLog and "LuaPetMiniTv:SetPetVisibility not show local, just hiding")
    self.Super:SetPetVisibility(false)
    return
  end
  self.Super:SetPetVisibility(bVisible)
end
function LuaPetMiniTv:SetHiddenInParachute(bHidden)
  log(bWriteLog and "LuaPetMiniTv:SetHiddenInParachute bHidden: " .. tostring(bHidden))
  self:SetActorHiddenInGameMask(bHidden, 5)
end
local Class = require("class")
local CLuaPetCommon = require("GameLua.Mod.BaseMod.Actor.Pet.LuaPetCommon")
local CLuaPetMiniTv = Class(CLuaPetCommon, nil, LuaPetMiniTv)
return CLuaPetMiniTv
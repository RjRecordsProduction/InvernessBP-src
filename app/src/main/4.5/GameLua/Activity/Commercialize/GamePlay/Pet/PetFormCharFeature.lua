local UKismetSystemLibrary = import("KismetSystemLibrary")
local PetFormCharFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
PetFormCharFeature.MulticastRPC.RPC_SyncPetEnlargeState = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
local EPawnState = import("EPawnState")
function PetFormCharFeature:ctor()
  self.bEnlarged = false
  self.bInPlane = false
  self.bInParachute = false
end
function PetFormCharFeature:ReceiveBeginPlay()
  print(bWriteLog and "PetFormCharFeature:ReceiveBeginPlay")
  PetFormCharFeature.__super.ReceiveBeginPlay(self)
  if self.Owner and self.Owner.PetComponent_BP then
    self:AddControlEvent(self.Owner.PetComponent_BP, "OnRepPetPawnCalled", self.HandleRepPetPawn, self)
  end
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    self:ClientResetPetVisibleInPlaneAndParachute()
  else
    self:AddControlEventWithCondition(self.Owner, "StateEnterHandler", {
      state = {
        EPawnState.InPlane,
        EPawnState.InParachute,
        EPawnState.Swim,
        EPawnState.Crouch
      }
    }, self.HandleOnEnterState, self)
    self:AddControlEventWithCondition(self.Owner, "StateLeaveHandler", {
      state = {
        EPawnState.InPlane,
        EPawnState.InParachute,
        EPawnState.Swim,
        EPawnState.Crouch
      }
    }, self.HandleOnLeaveState, self)
    self:AddControlEventWithCondition(self.Owner, "StateInterruptedHandlerBP", {
      State = {
        EPawnState.InPlane,
        EPawnState.InParachute
      }
    }, self.HandleOnInterrupted, self)
  end
end
function PetFormCharFeature:HandleRepPetPawn()
  print(bWriteLog and "PetFormCharFeature:HandleRepPetPawn", UKismetSystemLibrary.IsDedicatedServer(self.Owner))
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    local uPlayerController = self.Owner:GetPlayerControllerSafety()
    self.bEnlarged = self:IsCurrentPetEnlarged(uPlayerController)
    log(bWriteLog and "PetFormCharFeature:HandleRepPetPawn. self.bEnlarged: " .. tostring(self.bEnlarged))
    self.bInPlane = self.Owner:HasState(EPawnState.InPlane)
    self:SyncMeshShowScale()
  else
    self:ClientResetPetVisibleInPlaneAndParachute()
    self:ShowPetSwitchEffect()
  end
end
function PetFormCharFeature:RPC_SyncPetEnlargeState(bEnlarged)
  print(bWriteLog and "PetFormCharFeature:RPC_SyncPetEnlargeState", bEnlarged)
  self.end
function PetFormCharFeature:IsCurrentPetEnlarged(uPlayerController)
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    return false
  end
  local CurrentPetID = self:GetCurrentPetID()
  if CurrentPetID == 0 then
    return false
  end
  local ChangeScalePetIDList = uPlayerController.CommerFeature.ChangeScalePetIDList
  for _, PetID in pairs(ChangeScalePetIDList) do
    if PetID == CurrentPetID then
      return true
    end
  end
  return false
end
function PetFormCharFeature:IsCurrentPetEnableChangeScale()
  local PetID = self:GetCurrentPetID()
  if PetID == 0 then
    return false
  end
  local PetCfg = CDataTable.GetTableData("PetTable", PetID)
  return PetCfg and PetCfg.CanEnlarge
end
function PetFormCharFeature:GetPetAdditionalScale(bEnlarged)
  print(bWriteLog and "PetFormCharFeature:GetPetAdditionalScale")
  if not bEnlarged then
    return 1
  end
  local PetID = self:GetCurrentPetID()
  local PetScaleCfg = CDataTable.GetTableData("PetScaleTable", PetID)
  print(bWriteLog and "PetFormCharFeature:GetPetAdditionalScale Result", PetID, PetScaleCfg and PetScaleCfg.EnlargeModeScale_f)
  return PetScaleCfg and PetScaleCfg.EnlargeModeScale_f
end
function PetFormCharFeature:GetCurrentPetID()
  if not (self.Owner and slua.isValid(self.Owner.Object)) or not slua.isValid(self.Owner.PetComponent_BP) then
    return 0
  end
  return self.Owner.PetComponent_BP.PetInfo.PetId
end
function PetFormCharFeature:GetLifetimeReplicatedProps()
  print(bWriteLog and "PetFormCharFeature:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bEnlarged",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bInPlane",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bInParachute",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
end
function PetFormCharFeature:OnRep_bEnlarged()
  print(bWriteLog and "PetFormCharFeature:OnRep_bEnlarged", self.bEnlarged)
end
function PetFormCharFeature:OnRep_bInPlane()
  print(bWriteLog and "PetFormCharFeature:OnRep_bInPlane", self.bInPlane)
  self:ClientResetPetVisibleInPlaneAndParachute()
end
function PetFormCharFeature:OnRep_bInParachute()
  self:ClientResetPetVisibleInPlaneAndParachute()
end
function PetFormCharFeature:HandleOnEnterState(InState)
  if InState == EPawnState.InPlane then
    self.bInPlane = true
  elseif InState == EPawnState.InParachute then
    self.bInParachute = true
  elseif InState == EPawnState.Crouch then
    log(bWriteLog and "PetFormCharFeature:HandleOnEnterState.  Crouch")
    local PetComponent_BP = self.Owner.PetComponent_BP
    if PetUtil.IsBird(self:GetCurrentPetID()) then
      local EPetState = import("EPetState")
      PetComponent_BP:PetEnterState(EPetState.PetDisappear)
    end
  elseif InState == EPawnState.Swim then
    local PetComponent_BP = self.Owner.PetComponent_BP
    if PetComponent_BP then
      local PetPawn = PetComponent_BP:GetPetPawn()
      if not slua.isValid(PetPawn) then
        return
      end
      PetPawn:HandleOnOwnerEnterSwim()
    end
  end
end
function PetFormCharFeature:HandleOnLeaveState(InState)
  if InState == EPawnState.InPlane then
    self.bInPlane = false
  elseif InState == EPawnState.InParachute then
    self.bInParachute = false
  elseif InState == EPawnState.Crouch then
    log(bWriteLog and "PetFormCharFeature:HandleOnLeaveState.  Crouch")
    local PetComponent_BP = self.Owner.PetComponent_BP
    if PetUtil.IsBird(self:GetCurrentPetID()) then
      local EPetState = import("EPetState")
      PetComponent_BP:PetLeaveState(EPetState.PetDisappear)
    end
  elseif InState == EPawnState.Swim then
    if not slua.isValid(self.Owner) then
      return
    end
    if not slua.isValid(self.Owner.PetComponent_BP) then
      return
    end
    local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
    if not slua.isValid(PetPawn) then
      return
    end
    PetPawn:HandleOnOwnerLeaveSwim()
  end
end
function PetFormCharFeature:HandleOnInterrupted(InState, _)
  if InState == EPawnState.InPlane then
    self.bInPlane = false
  elseif InState == EPawnState.InParachute then
    self.bInParachute = false
  end
end
function PetFormCharFeature:ClientResetPetVisibleInPlaneAndParachute()
  print(bWriteLog and "PetFormCharFeature:ClientResetPetVisibleInPlaneAndParachute", self.bInPlane, self.bInParachute)
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not slua.isValid(self.Owner.PetComponent_BP) then
    print(bWriteLog and "PetFormCharFeature:ClientResetPetVisibleInPlaneAndParachute Owner is invalid")
    return
  end
  local bNeedHidePet = false
  local bNeedHideMiniTv = false
  if self.bInPlane then
    bNeedHidePet = true
    bNeedHideMiniTv = true
  elseif self.bInParachute then
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    bNeedHidePet = not SettingModule:GetOptionValue("bShowParachutePet")
    bNeedHideMiniTv = false
  else
    bNeedHidePet = false
    bNeedHideMiniTv = false
  end
  local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
  if slua.isValid(PetPawn) then
    print(bWriteLog and "PetFormCharFeature:ClientResetPetVisibleInPlaneAndParachute bNeedHidePet", tostring(bNeedHidePet))
    PetPawn:SetActorHiddenInGameMask(bNeedHidePet, 4)
  end
  local MiniTvPawn = self.Owner.PetComponent_BP:GetMiniTVPawn()
  if slua.isValid(MiniTvPawn) then
    print(bWriteLog and "PetFormCharFeature:ClientResetPetVisibleInPlaneAndParachute bNeedHideMiniTv", tostring(bNeedHideMiniTv))
    local EPetState = import("EPetState")
    if bNeedHideMiniTv then
      MiniTvPawn:PetEnterState(EPetState.PetDisappear)
    else
      MiniTvPawn:PetLeaveState(EPetState.PetDisappear)
    end
  end
end
function PetFormCharFeature:SyncMeshShowScale()
  if not UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not self:IsCurrentPetEnableChangeScale() then
    return
  end
  if not slua.isValid(self.Owner.PetComponent_BP) then
    print(bWriteLog and "PetFormCharFeature:SyncMeshShowScale Owner is invalid")
    return
  end
  local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
  if not slua.isValid(PetPawn) then
    print(bWriteLog and "PetFormCharFeature:SyncMeshShowScale PetPawn is invalid")
    return
  end
  local MeshShowScale = PetPawn.OriginalMeshScale * self:GetPetAdditionalScale(self.bEnlarged)
  print(bWriteLog and "PetFormCharFeature:SyncMeshShowScale ", MeshShowScale)
  PetPawn.end
function PetFormCharFeature:ShowPetSwitchEffect()
  log(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect")
  if UKismetSystemLibrary.IsDedicatedServer(self.Owner) then
    return
  end
  if not slua.isValid(self.Owner.PetComponent_BP) then
    print(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect Owner is invalid")
    return
  end
  local PetPawn = self.Owner.PetComponent_BP:GetPetPawn()
  if not slua.isValid(PetPawn) then
    print(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect PetPawn is invalid")
    return
  end
  if PetPawn.bHidden then
    print(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect PetPawn is in visible")
    return
  end
  local PetID = self:GetCurrentPetID()
  if not PetID or PetID == 0 or PetID == 50001 then
    return
  end
  local EffectItemID = 0
  local uPlayerController = self.Owner:GetPlayerControllerSafety()
  if slua.isValid(uPlayerController) and uPlayerController.CommerFeature then
    EffectItemID = uPlayerController.CommerFeature and uPlayerController.CommerFeature.PetSwitchEffectID
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local EffectCfg = logic_pet:GetPortalCfgByItemId(EffectItemID)
  local particlePath = EffectCfg.Appear
  local scale = EffectCfg.Scale or 1
  if EffectCfg.Appear then
    log(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect particle path: " .. tostring(particlePath))
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(particlePath, function(uParticle)
      if slua.isValid(uParticle) and slua.isValid(PetPawn) then
        log(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect uParticle is Valid " .. tostring(particlePath))
        local GameplayStatics = import("GameplayStatics")
        GameplayStatics.SpawnEmitterAtLocation(PetPawn, uParticle, PetPawn:K2_GetActorLocation(), FRotator(0, 0, 0), FVector(scale, scale, scale), true)
      end
    end)
  else
    log(bWriteLog and "PetFormCharFeature:ShowPetSwitchEffect no valid particle for item: " .. tostring(EffectItemID))
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPetFormFeature = class(CFeatureBase, nil, PetFormCharFeature)
return CPetFormFeature
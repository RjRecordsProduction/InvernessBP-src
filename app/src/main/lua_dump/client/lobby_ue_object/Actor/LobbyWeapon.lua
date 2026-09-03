local UKismetSystemLibrary = import("KismetSystemLibrary")
local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
local LobbyWeapon = {}
function LobbyWeapon:ctor()
  self.PendingWeaponShowState = nil
  self.bSetOnlyTickPoseWhenRendered = false
end
function LobbyWeapon:ReceiveBeginPlay()
  LobbyWeapon.__super.ReceiveBeginPlay(self)
  log(bWriteLog and "LobbyWeapon:ReceiveBeginPlay")
  self:BPBeginPlay()
  self:AddControlEvent(self.WeaponAvatarComp_BP, "OnAvatarAllMeshLoaded", self.OnAvatarChanged, self)
end
function LobbyWeapon:GetStandbyActionID()
  if not slua.isValid(self.WeaponAvatarComp_BP) then
    return 0
  end
  return self.WeaponAvatarComp_BP:GetLobbyStanbyActionID()
end
function LobbyWeapon:GetPoseReloadActionID()
  local WeaponAvatarComp_BP = self.WeaponAvatarComp_BP
  return not slua.isValid(WeaponAvatarComp_BP) and 0 or WeaponAvatarComp_BP:GetLobbyPoseReloadActionID()
end
function LobbyWeapon:GetHighlightActionID()
  local WeaponAvatarComp_BP = self.WeaponAvatarComp_BP
  return not slua.isValid(WeaponAvatarComp_BP) and 0 or WeaponAvatarComp_BP:GetLobbyHighlightActionID()
end
function LobbyWeapon:OnAvatarChanged()
  self:DoChangeWeaponShowState()
end
function LobbyWeapon:ChangeWeaponShowState(ShowState)
  self.PendingWeapon  if not slua.isValid(self.WeaponAvatarComp_BP) then
    return
  end
  if self.WeaponAvatarComp_BP.EffectManager then
    local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
    if self.WeaponAvatarComp_BP.EffectManager:HasEffectsByType(EWeaponEffectTriggerCondition.LobbyUserTrigger) then
      log(bWriteLog and "LobbyWeapon ChangeWeaponShowState Do Directly")
      self:DoChangeWeaponShowState()
    end
  end
end
function LobbyWeapon:DoChangeWeaponShowState()
  if self.PendingWeaponShowState == nil then
    return
  end
  if not slua.isValid(self.WeaponAvatarComp_BP) then
    return
  end
  if not self.WeaponAvatarComp_BP.EffectManager then
    return
  end
  if self.PendingWeaponShowState == 1 then
    local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
    self.WeaponAvatarComp_BP.EffectManager:RevertAppliedEffectsByConditionType(EWeaponEffectTriggerCondition.LobbyUserTrigger)
  elseif self.PendingWeaponShowState == 2 then
    self.WeaponAvatarComp_BP.EffectManager:OnLobbyUserTrigger()
  end
  self.PendingWeaponShowState = nil
end
function LobbyWeapon:GetWeaponAvatarComponent()
  return self.WeaponAvatarComp_BP
end
function LobbyWeapon:EquipWeaponPandentByPandentId(PendantID, SocketType)
  print(bWriteLog and "LobbyWeapon:EquipWeaponPandentByPandentId PendantID:" .. tostring(PendantID) .. " SocketType:" .. tostring(SocketType))
  self.WeaponAvatarComp_BP:PutOnEquipmentByResID(PendantID)
  self.WeaponAvatarComp_BP:SetPendantSocketType(SocketType)
  self.WeaponAvatarComp_BP.MasterBoneComponent.NeedUpdateEveryFrame = true
end
function LobbyWeapon:SetWeaponTick(bTick, bSetForcedLOD)
  log(bWriteLog and "LobbyWeapon:SetWeaponTick bTick = " .. tostring(bTick) .. " bSetForcedLOD = " .. tostring(bSetForcedLOD))
  local performance_util = require("client.slua.logic.performance.performance_util")
  performance_util:SetActorTickRecursively(self.Object, bTick)
  performance_util:SetComponentTickRecursively(self.RootComponent, bTick)
  if not bTick and not self.bSetOnlyTickPoseWhenRendered then
    self:SetOnlyTickPoseWhenRendered(self.RootComponent)
  end
  if bSetForcedLOD then
    local LODLevel = bTick and 1 or 2
    self:SetForcedLOD(self.RootComponent, LODLevel)
  end
end
function LobbyWeapon:SetOnlyTickPoseWhenRendered(Component)
  log(bWriteLog and "LobbyWeapon:SetOnlyTickPoseWhenRendered")
  if not slua.isValid(Component) then
    return
  end
  local EMeshComponentUpdateFlag = import("EMeshComponentUpdateFlag")
  if Component.MeshComponentUpdateFlag then
    Component.MeshComponentUpdateFlag = EMeshComponentUpdateFlag.OnlyTickPoseWhenRendered
    self.bSetOnlyTickPoseWhenRendered = true
  end
  if Component.GetChildrenComponents then
    local uComponentArray = Component:GetChildrenComponents(false, nil)
    if uComponentArray then
      for _, ChildComponent in pairs(uComponentArray) do
        if ChildComponent and slua.isValid(ChildComponent) then
          self:SetOnlyTickPoseWhenRendered(ChildComponent)
        end
      end
    end
  end
end
function LobbyWeapon:SetForcedLOD(Component, LODLevel)
  if not slua.isValid(Component) then
    return
  end
  if Component.SetForcedLOD then
    Component:SetForcedLOD(LODLevel)
  end
  if Component.GetChildrenComponents then
    local uComponentArray = Component:GetChildrenComponents(false, nil)
    if uComponentArray then
      for _, ChildComponent in pairs(uComponentArray) do
        if ChildComponent and slua.isValid(ChildComponent) then
          self:SetForcedLOD(ChildComponent, LODLevel)
        end
      end
    end
  end
end
function LobbyWeapon:SetShowModelOutline(bIsShow, uOutlineColor, nOutlineThickness)
  if not slua.isValid(self.Object) then
    return
  end
  local MeshComponentClass = import("/Script/Engine.MeshComponent")
  local uComponentArray = self:GetComponentsByClass(MeshComponentClass)
  for _, uObj_mesh in pairs(uComponentArray) do
    if uObj_mesh and slua.isValid(uObj_mesh) then
      uObj_mesh:SetDrawIdeaOutline(bIsShow)
      uObj_mesh:SetIdeaOutlineNew(bIsShow)
      if bIsShow then
        uObj_mesh:OverrideIdeaOutlineColor(true, uOutlineColor)
        uObj_mesh:OverrideIdeaOutlineThickness(true, nOutlineThickness)
      end
    end
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLobbyWeapon = class(object, nil, LobbyWeapon)
return CLobbyWeapon
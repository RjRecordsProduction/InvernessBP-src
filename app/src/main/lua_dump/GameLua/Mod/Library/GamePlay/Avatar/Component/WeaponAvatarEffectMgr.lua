local WeaponAvatarEffectMgr = {}
function WeaponAvatarEffectMgr:ctor(_)
  self.PendingEffectMap = {}
  self.AppliedEffectList = {}
  self.ProcessorMap = {}
  self.OwnerAvatarComp = nil
  self.CurMasterGunHandhle = nil
end
function WeaponAvatarEffectMgr:Init(Handle, WeaponAvatarComp)
  if not slua.isValid(Handle) or not slua.isValid(WeaponAvatarComp) then
    print(bWriteLog and "WeaponAvatarEffectMgr Init Fail Handle or WeaponAvaComp Is not Valid")
    return
  end
  self:AddControlEvent(WeaponAvatarComp, "OnWeaponEffectParticleCreate", self.OnParticlesCreate, self)
  self:AddControlEvent(WeaponAvatarComp, "OnWeaponPartsRender", self.OnWeaponPartsEquiped, self)
  self.OwnerAvatarComp = WeaponAvatarComp
  self.CurMasterGunHandhle = Handle
  self:InitEffects()
  self:InitProcessors()
end
function WeaponAvatarEffectMgr:InitEffects()
  local AvatarEffects = self.CurMasterGunHandhle.AvatarEffects
  if not AvatarEffects then
    return
  end
  local EffectNum = AvatarEffects:Num()
  if EffectNum == 0 then
    return
  end
  local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
  for i = 0, EffectNum - 1 do
    local EffectCfg = AvatarEffects:Get(i)
    if slua.isValid(EffectCfg) then
      local IsInValidScene = self:IsValidScene(EffectCfg.ValidScene)
      if IsInValidScene and self:NeedApply(EffectCfg) then
        EffectCfg:Init()
        if EffectCfg.TriggerCondition == EWeaponEffectTriggerCondition.None then
          print(bWriteLog and "WeaponAvatarEffectMgr Init Apply Effect Directly")
          EffectCfg:ApplyEffect(self.OwnerAvatarComp)
          table.insert(self.AppliedEffectList, EffectCfg)
        else
          if self.PendingEffectMap[EffectCfg.TriggerCondition] == nil then
            self.PendingEffectMap[EffectCfg.TriggerCondition] = {}
          end
          table.insert(self.PendingEffectMap[EffectCfg.TriggerCondition], EffectCfg)
        end
      end
    end
  end
end
function WeaponAvatarEffectMgr:InitProcessors()
  for Type, EffectList in pairs(self.PendingEffectMap) do
    if self.ProcessorMap[Type] == nil then
      local ProcessorFactory = require("GameLua.Mod.Library.GamePlay.Avatar.Component.EffectProc.ConditionProcessorFactory")
      local Processor = ProcessorFactory.GetWeaponProcessor(Type, self)
      if Processor then
        Processor:Init()
        self.ProcessorMap[Type] = Processor
      end
    end
  end
end
function WeaponAvatarEffectMgr:OnParticlesCreate()
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  for _, Effect in pairs(self.AppliedEffectList) do
    local uFxModifyClass = import("WeaponEffect_ModifyFxParam")
    if Game:IsClassOf(Effect, uFxModifyClass) then
      Effect:Init(self.OwnerAvatarComp)
      Effect:ApplyEffect(self.OwnerAvatarComp)
    end
  end
end
function WeaponAvatarEffectMgr:OnWeaponPartsEquiped(WeaponSlotID)
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  local uTranlucencySortCls = import("WeaponEffect_SetPartsTranslucencySort")
  local uFxModifyClass = import("WeaponEffect_ModifyMatParam")
  for _, Effect in pairs(self.AppliedEffectList) do
    if Game:IsClassOf(Effect, uFxModifyClass) or Game:IsClassOf(Effect, uTranlucencySortCls) then
      Effect:Init(self.OwnerAvatarComp)
      Effect:ApplyEffect(self.OwnerAvatarComp)
    end
  end
  self:OnWeaponPartsEffectsTrigger(WeaponSlotID)
end
function WeaponAvatarEffectMgr:OnWeaponPartsEffectsTrigger(WeaponSlotID)
  local UWeaponEffect_CycleSwitchMesh = import("WeaponEffect_CycleSwitchMesh")
  for _, Effect in pairs(self.AppliedEffectList) do
    if Game:IsClassOf(Effect, UWeaponEffect_CycleSwitchMesh) then
      print(bWriteLog and "WeaponAvatarEffectMgr OnWeaponPartsEffectsTrigger Effect: " .. tostring(Effect))
      if WeaponSlotID == Effect.TargetSlotID then
        Effect:Init(self.OwnerAvatarComp)
        Effect:ApplyEffect(self.OwnerAvatarComp)
      end
    end
  end
end
function WeaponAvatarEffectMgr:Clear()
  print(bWriteLog and "WeaponAvatarEffectMgr Clear")
  if self.PendingEffectMap then
    for _, PendingList in pairs(self.PendingEffectMap) do
      for _, EffectCfg in pairs(PendingList) do
        if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
          EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        end
      end
    end
  end
  self.PendingEffectMap = {}
  if self.AppliedEffectList then
    for _, EffectCfg in pairs(self.AppliedEffectList) do
      if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
      end
    end
  end
  self.AppliedEffectList = {}
  if self.ProcessorMap then
    for _, Processor in pairs(self.ProcessorMap) do
      Processor:Destroy()
    end
  end
  self.ProcessorMap = {}
  self.OwnerAvatarComp = nil
  self.CurMasterGunHandhle = nil
  self:Dispose()
end
function WeaponAvatarEffectMgr:Destroy()
  print(bWriteLog and "WeaponAvatarEffectMgr Destroy")
  self:Clear()
end
function WeaponAvatarEffectMgr:IsValidScene(SceneType)
  if not slua.isValid(self.OwnerAvatarComp) then
    return false
  end
  local EWeaponEffectValidSceneType = import("EWeaponEffectValidSceneType")
  local IsInValidScene = false
  if SceneType == EWeaponEffectValidSceneType.All then
    IsInValidScene = true
  elseif SceneType == EWeaponEffectValidSceneType.LobbyOnly and self.OwnerAvatarComp:IsLobbyActor() then
    IsInValidScene = true
  elseif SceneType == EWeaponEffectValidSceneType.InGameOnly and not self.OwnerAvatarComp:IsLobbyActor() then
    IsInValidScene = true
  end
  return IsInValidScene
end
function WeaponAvatarEffectMgr:NeedApply(EffectCfg)
  if not slua.isValid(EffectCfg) then
    return false
  end
  if EffectCfg.EnableLowDeviceOpt then
    if not slua.isValid(self.OwnerAvatarComp) then
      return true
    end
    if self.OwnerAvatarComp:IsLobbyActor() or self.OwnerAvatarComp:IsSelf() then
      return true
    end
    local UIUtil = require("client.common.ui_util")
    local GameInst = UIUtil.GetGameInstance()
    if not slua.isValid(GameInst) then
      return true
    end
    if GameInst:GetExactDeviceLevel() <= 0 then
      return false
    elseif self.OwnerAvatarComp:IsTeammate() then
      return true
    else
      return false
    end
  end
  return true
end
function WeaponAvatarEffectMgr:GetEffectsByType(Type)
  return self.PendingEffectMap[Type]
end
function WeaponAvatarEffectMgr:HasEffectsByType(Type)
  if self.PendingEffectMap[Type] and #self.PendingEffectMap[Type] > 0 then
    return true
  end
  for _, EffectCfgCfg in pairs(self.AppliedEffectList) do
    if slua.isValid(EffectCfgCfg) and EffectCfgCfg.TriggerCondition == Type then
      return true
    end
  end
  return false
end
function WeaponAvatarEffectMgr:GetAppliedEffects()
  return self.AppliedEffectList
end
function WeaponAvatarEffectMgr:ProcessEffectsByConditionType(Type, Param)
  local KillProcessor = self.ProcessorMap[Type]
  if not KillProcessor then
    return
  end
  KillProcessor:TriggerCheck(Param)
end
function WeaponAvatarEffectMgr:OnThisWeaponKilledOther(FatalDamageParameter)
  local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
  self:ProcessEffectsByConditionType(EWeaponEffectTriggerCondition.Kill, FatalDamageParameter)
end
function WeaponAvatarEffectMgr:OnLobbyUserTrigger(Parameter)
  local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
  self:ProcessEffectsByConditionType(EWeaponEffectTriggerCondition.LobbyUserTrigger, Parameter)
end
function WeaponAvatarEffectMgr:RevertAppliedEffectsByConditionType(Type)
  local EWeaponEffectTriggerCondition = import("EWeaponEffectTriggerCondition")
  if Type == EWeaponEffectTriggerCondition.None then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  local Index = 1
  while Index <= #self.AppliedEffectList do
    local EffectCfg = self.AppliedEffectList[Index]
    if not slua.isValid(EffectCfg) then
      print(bWriteLog and "WeaponAvatarEffectMgr RevertAppliedEffectsByConditionType Warning EffectCfg not valid!")
      break
    end
    if EffectCfg.TriggerCondition == Type then
      EffectCfg:RemoveEffect(self.OwnerAvatarComp)
      EffectCfg:Init()
      table.remove(self.AppliedEffectList, Index)
      if self.PendingEffectMap[Type] == nil then
        self.PendingEffectMap[Type] = {}
      end
      table.insert(self.PendingEffectMap[Type], EffectCfg)
    else
      Index = Index + 1
    end
  end
end
function WeaponAvatarEffectMgr:GetOwnerAvatarComponent()
  return self.OwnerAvatarComp
end
function WeaponAvatarEffectMgr:OnReloadAllEquippedAvatar()
  local removed = false
  for _, EffectCfg in pairs(self.AppliedEffectList) do
    if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
      local UWeaponEffect_Particle = import("WeaponEffect_Particle")
      if Game:IsClassOf(EffectCfg, UWeaponEffect_Particle) then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        removed = true
      end
    end
  end
  if removed then
    self:AddTimer(0.0, function()
      for _, EffectCfg in pairs(self.AppliedEffectList) do
        if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
          local UWeaponEffect_Particle = import("WeaponEffect_Particle")
          if Game:IsClassOf(EffectCfg, UWeaponEffect_Particle) then
            EffectCfg:Init(self.OwnerAvatarComp)
            EffectCfg:ApplyEffect(self.OwnerAvatarComp)
          end
        end
      end
    end)
  end
end
local class = require("class")
local object = require("common.delegate_container")
local CWeaponAvatarEffectMgr = class(object, nil, WeaponAvatarEffectMgr)
return CWeaponAvatarEffectMgr
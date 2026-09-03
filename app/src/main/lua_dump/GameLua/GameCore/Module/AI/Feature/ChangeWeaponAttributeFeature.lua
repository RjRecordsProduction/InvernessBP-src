local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local UAIBlueprintHelperLibrary = import("AIBlueprintHelperLibrary")
local WeaponUtils = require("GameLua.Mod.BaseMod.GamePlay.Weapon.WeaponUtils")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local EAttrOperator = import("EAttrOperator")
local ChangeWeaponAttributeFeature = {}
function ChangeWeaponAttributeFeature:ctor()
  self.EnableWeaponAttrModify = true
  self.WeaponAttrModifyList = {}
end
function ChangeWeaponAttributeFeature:ReceiveBeginPlay()
  ChangeWeaponAttributeFeature.__super.ReceiveBeginPlay(self)
  self:HandleWeaponAttribute()
end
function ChangeWeaponAttributeFeature:_PostConstruct()
  ChangeWeaponAttributeFeature.__super._PostConstruct(self)
end
function ChangeWeaponAttributeFeature:SetWeaponAttribute(DataTable)
  if DataTable then
    self.WeaponAttrModifyList = DataTable
  end
end
function ChangeWeaponAttributeFeature:GetWeaponAttribute(AttrName)
  if not Game:IsValid(self.WeaponAttrModifyList) then
    return 0, EAttrOperator.Multiply
  end
  for _, Cfg in pairs(self.WeaponAttrModifyList) do
    if Cfg.AttrName == AttrName then
      return Cfg.Value, Cfg.OP
    end
  end
  return 0, EAttrOperator.Multiply
end
function ChangeWeaponAttributeFeature:SetWeaponAttributeSingle(AttrName, OpType, AttrValue)
  if not Game:IsValid(self.WeaponAttrModifyList) then
    return
  end
  local IsModify = false
  for _, Cfg in pairs(self.WeaponAttrModifyList) do
    if Cfg.AttrName == AttrName then
      Cfg.OP = OpType
      Cfg.Value = AttrValue
      IsModify = true
    end
  end
  if IsModify == false then
    table.insert(self.WeaponAttrModifyList, {
      AttrName = AttrName,
      OP = OpType,
      Value = AttrValue
    })
  end
end
function ChangeWeaponAttributeFeature:HandleWeaponAttribute()
  if not Client and self.EnableWeaponAttrModify then
    self:AddGameTimer(1, false, function()
      self:InitWeaponAttribute()
    end)
  end
end
function ChangeWeaponAttributeFeature:InitWeaponAttribute()
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  local uWeaponManager = self.Owner:GetWeaponManager()
  if not slua.isValid(uWeaponManager) then
    return
  end
  local uWeaponList = uWeaponManager:GetAllInventoryWeaponList(false)
  if not uWeaponList or uWeaponList:Num() <= 0 then
    return
  end
  local IsUGC = false
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    IsUGC = true
  end
  for i = 0, uWeaponList:Num() - 1 do
    local uCurWeapon = uWeaponList:Get(i)
    local uAttrModifierCompoment = slua.isValid(uCurWeapon) and uCurWeapon.AttrModifierCompoment
    local CurMaxBulletNumInOneClip = uCurWeapon.CurMaxBulletNumInOneClip
    if slua.isValid(uAttrModifierCompoment) then
      if IsUGC then
        for _, Cfg in pairs(self.WeaponAttrModifyList) do
          if Cfg.ModifyID ~= nil then
            uAttrModifierCompoment:RemoveModifyItemFromCache(Cfg.ModifyID)
          end
        end
      end
      local Ret = WeaponUtils:AddAttrModifier(uCurWeapon, self.WeaponAttrModifyList)
      local sWeaponName = UKismetSystemLibrary.GetObjectName(self.Owner.Object)
      FeatureUtil.printf("ChangeWeaponAttributeFeature:InitWeaponAttribute %s Ret:%s", tostring(sWeaponName), tostring(Ret))
      if IsUGC and CurMaxBulletNumInOneClip and uCurWeapon.CurMaxBulletNumInOneClip and uCurWeapon.CurBulletInClip.CurBulletNumInClip then
        local AddtionBulletNum = CurMaxBulletNumInOneClip - uCurWeapon.CurMaxBulletNumInOneClip
        if 0 < AddtionBulletNum then
          local CreativeSpawnManager = GetCreativeSpawnManager()
          if CreativeSpawnManager:IsArmedAI(self.Owner) then
            uCurWeapon.CurBulletInClip.CurBulletNumInClip = uCurWeapon.CurMaxBulletNumInOneClip
          end
        end
      end
    end
    if uCurWeapon and uCurWeapon.AfterInitScirptWeapon then
      uCurWeapon:AfterInitScirptWeapon()
    end
  end
  if self.Owner.ReloadCurrentWeapon then
    self.Owner:ReloadCurrentWeapon()
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CChangeWeaponAttributeFeature = class(CFeatureBase, nil, ChangeWeaponAttributeFeature)
return CChangeWeaponAttributeFeature
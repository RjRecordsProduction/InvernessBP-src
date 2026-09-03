local LuaCustomMoveObj = {}
function LuaCustomMoveObj:ctor()
  self.VariantConfig = nil
  self.LoadedVariants = {}
  self.ActiveVariant = nil
  self.ActiveVariantIndex = -1
end
function LuaCustomMoveObj:RegisterParamSetVariants(VariantConfig)
  if not VariantConfig then
    return
  end
  self.  if self.ClearAllParamSets then
    self:ClearAllParamSets()
  end
  self.LoadedVariants = {}
  for i, entry in ipairs(VariantConfig) do
    local Key = entry.Key
    local Path = entry.VariantPath or ""
    local VariantMod
    if Path ~= "" then
      local ok, mod = pcall(require, Path)
      if ok and mod then
        VariantMod = mod
      else
        print(bWriteLog and string.format("LuaCustomMoveObj:RegisterParamSetVariants - Variant require FAILED, Key=%s Path=%s", tostring(Key), tostring(Path)))
      end
    end
    self.LoadedVariants[i - 1] = VariantMod
    local ParamSet = {Key = Key, LuaVariantPath = Path}
    if VariantMod and VariantMod.ParamSet then
      for k, v in pairs(VariantMod.ParamSet) do
        ParamSet[k] = v
      end
    end
    self:RegisterParamSet(ParamSet)
  end
end
function LuaCustomMoveObj:_SwitchVariantTo(Index)
  if Index == self.ActiveVariantIndex then
    return
  end
  if self.ActiveVariant and self.ActiveVariant.OnLeave then
    self.ActiveVariant:OnLeave(self)
  end
  if Index < 0 then
    self.ActiveVariant = nil
    self.ActiveVariantIndex = -1
    return
  end
  self.ActiveVariant = self.LoadedVariants[Index]
  self.ActiveVariant  if self.ActiveVariant and self.ActiveVariant.OnEnter then
    local entry = self.VariantConfig and self.VariantConfig[Index + 1]
    local Key = entry and entry.Key or ""
    self.ActiveVariant:OnEnter(self, Key, Index)
  end
end
function LuaCustomMoveObj:OnLuaCustomEnter(ParamSetKey, ParamSetIndex)
  self.Super:OnLuaCustomEnter(ParamSetKey, ParamSetIndex)
  self:_SwitchVariantTo(ParamSetIndex)
end
function LuaCustomMoveObj:OnLuaCustomLeave()
  self.Super:OnLuaCustomLeave()
  self:_SwitchVariantTo(-1)
end
function LuaCustomMoveObj:OnParamSetChanged(OldIndex, NewIndex)
  self.Super:OnParamSetChanged(OldIndex, NewIndex)
  if NewIndex and 0 <= NewIndex then
    self:_SwitchVariantTo(NewIndex)
  else
    self:_SwitchVariantTo(-1)
  end
end
function LuaCustomMoveObj:OnEnterFlyingMode()
  self.Super:OnEnterFlyingMode()
  if self.ActiveVariant and self.ActiveVariant.OnEnterFlyingMode then
    self.ActiveVariant:OnEnterFlyingMode(self)
  end
end
function LuaCustomMoveObj:OnExitFlyingMode()
  self.Super:OnExitFlyingMode()
  if self.ActiveVariant and self.ActiveVariant.OnExitFlyingMode then
    self.ActiveVariant:OnExitFlyingMode(self)
  end
end
function LuaCustomMoveObj:OnCharacterPerspectiveChanged(bIsFPP)
  self.Super:OnCharacterPerspectiveChanged(bIsFPP)
  if self.ActiveVariant and self.ActiveVariant.OnCharacterPerspectiveChanged then
    self.ActiveVariant:OnCharacterPerspectiveChanged(self, bIsFPP)
  end
end
function LuaCustomMoveObj:OnCharacterAnimInstanceLoadedDone()
  self.Super:OnCharacterAnimInstanceLoadedDone()
  if self.ActiveVariant and self.ActiveVariant.OnCharacterAnimInstanceLoadedDone then
    self.ActiveVariant:OnCharacterAnimInstanceLoadedDone(self)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, LuaCustomMoveObj)
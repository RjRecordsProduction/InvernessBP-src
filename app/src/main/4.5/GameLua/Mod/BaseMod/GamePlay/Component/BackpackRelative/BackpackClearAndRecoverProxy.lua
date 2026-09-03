local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UBackpackUtils = import("BackpackUtils")
local BackpackClearAndRecoverProxy = {}
function BackpackClearAndRecoverProxy:ctor(selfType)
  BackpackClearAndRecoverProxy.__super.ctor(self, selfType)
  self.LuaStrategy = nil
end
function BackpackClearAndRecoverProxy:SetClearAndRecoverStrategyName(InStrategyName, InMethod)
  local BackpackClearAndRecoverConfig = GamePlayTools.GetCurrentConfig("BackpackClearAndRecoverConfig")
  if BackpackClearAndRecoverConfig and BackpackClearAndRecoverConfig[InStrategyName] then
    self.LuaStrategy = BackpackClearAndRecoverConfig[InStrategyName]
    self:SetClearAndRecoverStrategy(self.LuaStrategy, InMethod)
  end
end
function BackpackClearAndRecoverProxy:ClearBackpackDataInSave()
  local dropItemsFliterTypeList = self:GetDropItemsFliterTypeList(self.TempKeepAllItemData)
  local dropItemsFliterItemIDList = self:GetDropItemsFliterItemIDList(self.TempKeepAllItemData)
  self:ClearBackpackData(dropItemsFliterTypeList, dropItemsFliterItemIDList, false, true)
end
function BackpackClearAndRecoverProxy:ClearBackpackDataInRecover()
  local dropItemsFliterTypeList = self:GetDropItemsFliterTypeList(self.TempKeepAllItemData)
  local dropItemsFliterItemIDList = self:GetDropItemsFliterItemIDList(self.TempKeepAllItemData)
  self:ClearBackpackData(dropItemsFliterTypeList, dropItemsFliterItemIDList, self.CurStrategy.bClearAvatarData, true)
end
function BackpackClearAndRecoverProxy:MakeBackpackCapacityInfinite(bEnable)
  local uPlayerCharacter = self:GetPlayerCharacter()
  local uBackpackComponent = self:GetBackpackComponent()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uBackpackComponent) then
    return
  end
  local uAttrModifierComp = uPlayerCharacter.AttrModifyComp
  print(bWriteLog and "BackpackClearAndRecoverProxy:MakeBackpackCapacityInfinite Capacity Begin:", uBackpackComponent.Capacity, Enable)
  if slua.isValid(uAttrModifierComp) then
    if bEnable then
      local VarCapacity = 1000
      local AttrName = "PawnBackpackCapacity"
      self.nModifyItemUID = uAttrModifierComp:AddModifyItemAndCache(AttrName, 2, VarCapacity, true, uPlayerCharacter, false)
    elseif self.nModifyItemUID ~= nil then
      print(bWriteLog and "BackpackClearAndRecoverProxy ChangeCapacity Remove")
      uAttrModifierComp:RemoveModifyItemFromCache(self.nModifyItemUID)
      self.nModifyItemUID = nil
    end
    uBackpackComponent:NotifyCapacityUpdated()
  end
  print(bWriteLog and "BackpackClearAndRecoverProxy:MakeBackpackCapacityInfinite Capacity End:", uBackpackComponent.Capacity)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackClearAndRecoverProxy = class(CDelegateContainer, nil, BackpackClearAndRecoverProxy)
return CBackpackClearAndRecoverProxy
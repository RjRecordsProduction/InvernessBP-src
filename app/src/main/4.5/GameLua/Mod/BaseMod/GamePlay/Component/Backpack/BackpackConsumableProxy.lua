local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local CircleChooseUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseUtil")
local BackpackConsumableProxy = {}
function BackpackConsumableProxy:ctor(selfType)
  BackpackConsumableProxy.__super.ctor(self, selfType)
  print(bWriteLog and "BackpackConsumableProxy:ctor")
  self.CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  self.LuaConsumables = {}
  self.LuaSortedConsumables = {}
  self.LuaGrenadesAndMelees = {}
  self.SortedGrenadesList = {}
  self.LuaRingListData = {}
end
function BackpackConsumableProxy:LuaInitialize()
  print(bWriteLog and "BackpackConsumableProxy:LuaInitialize()")
  CircleChooseUtil.SetBackpackConsumableProxy(self)
  self.CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg") or {}
  if not self.CircleChooseCfg then
    return
  end
  local RelatedSubType = self.CircleChooseCfg.RelatedSubtype or {}
  for SubType, value in pairs(RelatedSubType) do
    self.RelatedSubTypeList:Add(SubType)
  end
  local RelatedID = self.CircleChooseCfg.RelatedID or {}
  for ID, _ in pairs(RelatedID) do
    self.RelatedIDList:Add(ID)
  end
  if self.CircleChooseCfg.IgnoreThrowableID then
    for _, ID in pairs(self.CircleChooseCfg.IgnoreThrowableID) do
      self.IgnoreTypeSpecificIDList:Add(ID)
    end
  end
end
function BackpackConsumableProxy:LuaDeinitialize()
  print(bWriteLog and "BackpackConsumableProxy:LuaDeinitialize()")
  CircleChooseUtil.SetBackpackConsumableProxy(nil)
end
function BackpackConsumableProxy:GetPriority(ItemDefineID)
  local LogicMgrSubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
  if LogicMgrSubsystem then
    return LogicMgrSubsystem:GetPriority(ItemDefineID)
  end
  return 0
end
function BackpackConsumableProxy:IsConsumableItem(TypeSpecificID)
  if CircleChooseUtil.IsAMedicine(TypeSpecificID) or CircleChooseUtil.IsAIceDrink(TypeSpecificID) then
    local LogicThemePropSubsystem = CircleChooseUtil.GetLogicThemePropSubsystem()
    if LogicThemePropSubsystem then
      local IDMap = LogicThemePropSubsystem:GetThemePropsIDMap()
      if IDMap and IDMap[TypeSpecificID] then
        return false
      end
    end
    return true
  end
  return false
end
function BackpackConsumableProxy:IsGrenadeItem(TypeSpecificID)
  if CircleChooseUtil.SimGrenade(TypeSpecificID) then
    local LogicThemePropSubsystem = CircleChooseUtil.GetLogicThemePropSubsystem()
    if LogicThemePropSubsystem then
      local IDMap = LogicThemePropSubsystem:GetThemePropsIDMap()
      if IDMap and IDMap[TypeSpecificID] then
        return false
      end
    end
    return true
  end
  return false
end
function BackpackConsumableProxy:IsMeleeItem(TypeSpecificID)
  if CircleChooseUtil.SimMelee(TypeSpecificID) then
    local LogicThemePropSubsystem = CircleChooseUtil.GetLogicThemePropSubsystem()
    if LogicThemePropSubsystem then
      local IDMap = LogicThemePropSubsystem:GetThemePropsIDMap()
      if IDMap and IDMap[TypeSpecificID] then
        return false
      end
    end
    return true
  end
  return false
end
function BackpackConsumableProxy:IsRingListItem(TypeSpecificID)
  return CircleChooseUtil.IsRingListItem(TypeSpecificID)
end
function BackpackConsumableProxy:GetRingListData()
  return self.RingListData
end
function BackpackConsumableProxy:GetGrenadesAndMeleesData()
  return self.GrenadesAndMelees
end
function BackpackConsumableProxy:GetSortedGrenadesAndMeleesData()
  return self.SortedGrenadesAndMelees
end
function BackpackConsumableProxy:GetConsumablesData()
  return self.Consumables
end
function BackpackConsumableProxy:GetSortedConsumablesData()
  return self.SortedConsumables
end
function BackpackConsumableProxy:UpdateItemDataFinish()
  if self.UpdateItemDataFinishTimer then
    self:RemoveAllGameTimer(self.UpdateItemDataFinishTimer)
    self.UpdateItemDataFinishTimer = nil
  end
  self.UpdateItemDataFinishTimer = self:AddGameTimer(0.05, false, function()
    local LogicMgrSubsystem = CircleChooseUtil.GetLogicMgrSubsystem()
    if LogicMgrSubsystem then
      LogicMgrSubsystem:ForceUpdateList()
    end
  end)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackConsumableProxy = class(CDelegateContainer, nil, BackpackConsumableProxy)
return CBackpackConsumableProxy
local ActivityCenterDataProxy = {}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local E_ActSwitchType = ActivitySwitchType
local E_local TableUtil = require("common.table_util")
function ActivityCenterDataProxy:ctor(_)
  self.IsInit = false
  self.TabInfoMap = {}
  self.GroupByType = {}
  self.SwitchTypeOrderList = {}
end
function ActivityCenterDataProxy:HasInit()
  return self.IsInit
end
function ActivityCenterDataProxy:Init()
  if self.IsInit then
    return
  end
  log(bWriteLog and "ActivityCenterDataProxy:Init. - begin.")
  if bWriteLog then
    local tabInfoCount = 0
    for _ in pairs(self.TabInfoMap) do
      tabInfoCount = tabInfoCount + 1
    end
    log_format("ActivityCenterDataProxy:Init - process. injected TabInfoMap size=%s", tostring(tabInfoCount))
  end
  self:_BuildGroupAndSort()
  self:_BuildSwitchTypeOrderList()
  self.IsInit = true
  log_format("ActivityCenterDataProxy:Init - finished. SwitchTypeOrderList size=%s", tostring(#self.SwitchTypeOrderList))
end
function ActivityCenterDataProxy:Invalidate()
  log(bWriteLog and "ActivityCenterDataProxy:Invalidate - clear all derived data, wait for re-init")
  self.IsInit = false
  self.TabInfoMap = {}
  self.GroupByType = {}
  self.SwitchTypeOrderList = {}
end
function ActivityCenterDataProxy:HasAnyData()
  self:_EnsureInit()
  return next(self.TabInfoMap) ~= nil
end
function ActivityCenterDataProxy:GetSwitchTypeList()
  self:_EnsureInit()
  return self.SwitchTypeOrderList
end
function ActivityCenterDataProxy:GetTabListBySwitchType(switchType)
  self:_EnsureInit()
  return self.GroupByType[switchType] or {}
end
function ActivityCenterDataProxy:GetFirstTabInfoBySwitchType(switchType)
  self:_EnsureInit()
  local list = self.GroupByType[switchType]
  if list and list[1] then
    return list[1]
  end
  return nil
end
function ActivityCenterDataProxy:GetAllGroups()
  self:_EnsureInit()
  return self.GroupByType
end
function ActivityCenterDataProxy:GetActTabInfo(nActID)
  self:_EnsureInit()
  return self.TabInfoMap[nActID]
end
function ActivityCenterDataProxy:GetTabIndexByActID(nActID, switchType)
  self:_EnsureInit()
  local list = self.GroupByType[switchType]
  if not list then
    return 0
  end
  for i = 1, #list do
    if list[i].nActID == nActID then
      return i
    end
  end
  return 0
end
function ActivityCenterDataProxy:_EnsureInit()
  if not self.IsInit then
    self:Init()
  end
end
function ActivityCenterDataProxy:_BuildGroupAndSort()
  local groupByType = {}
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  for _, tabInfo in pairs(self.TabInfoMap) do
    if not ActivityCenterModule:GetMergeBrotherId(tabInfo.nActID) then
      local switchType = tabInfo.nSwitchType or 0
      if not groupByType[switchType] then
        groupByType[switchType] = {}
      end
      table.insert(groupByType[switchType], tabInfo)
    end
  end
  for _, list in pairs(groupByType) do
    table.sort(list, function(a, b)
      local orderA = a.nOrder or 0
      local orderB = b.nOrder or 0
      if orderA ~= orderB then
        return orderA < orderB
      end
      return (a.nStartTime or 0) < (b.nStartTime or 0)
    end)
  end
  self.GroupByType = groupByType
end
function ActivityCenterDataProxy:_BuildSwitchTypeOrderList()
  local allConfigs = {}
  for _, cfg in pairs(ActivityMacros.ActTabConfig) do
    allConfigs[#allConfigs + 1] = cfg
  end
  table.sort(allConfigs, function(a, b)
    return (a.nSort or 0) < (b.nSort or 0)
  end)
  local orderList = {}
  for _, cfg in ipairs(allConfigs) do
    local switchType = cfg.nType
    local list = self.GroupByType[switchType]
    if list and 0 < #list then
      orderList[#orderList + 1] = TableUtil.CopyTable(cfg)
    end
  end
  self.SwitchTypeOrderList = orderList
end
local class = require("class")
local DelegateContainer = require("common.delegate_container")
local CActivityCenterDataProxy = class(DelegateContainer, nil, ActivityCenterDataProxy)
return CActivityCenterDataProxy
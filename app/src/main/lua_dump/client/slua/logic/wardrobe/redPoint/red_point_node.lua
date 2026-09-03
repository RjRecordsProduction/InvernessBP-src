local RedPointNode = {}
function RedPointNode:ctor(_, parent, key)
  self._  self._count = 0
  self._key = key or ""
  self._subGroup = {}
  self._instIds = {}
  self._widget = nil
  self._events = {}
  self._checkHook = nil
  if self._parent then
    self._parent._subGroup[key] = self
  end
end
function RedPointNode:_GetKey()
  return self._key
end
function RedPointNode:_SetParent(parent)
  self._end
function RedPointNode:_SpreadCount(diff)
  if diff then
    log(bWriteLog and string.format("RedPointNode:_SpreadCount self._key = %s, self._count = %s, diff = %s", self._key, self._count, diff))
    self:_PushCount(diff)
  end
end
function RedPointNode:_PushCount(diff)
  if diff and diff ~= 0 then
    self._count = self._count + diff
    local red_point_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.red_point_manager)
    red_point_manager:InsertNode(self, diff)
  end
end
function RedPointNode:_ExecuteRedPointRefresh(diff)
  if self._parent then
    self._parent:_SpreadCount(diff)
  end
  log(bWriteLog and string.format("RedPointNode:_ExecuteRedPointRefresh self._key = %s self._count = %s diff = %s", self._key, self._count, diff))
  for event, v in pairs(self._events) do
    event(self._count)
  end
  local isShow = self._count > 0
  if not self._widget then
    return
  end
  if self._checkHook and isShow then
    isShow = self._checkHook()
  end
  if slua.isValid(self._widget) then
    if isShow then
      log(bWriteLog and string.format("RedPointNode:_ExecuteRedPointRefresh %s", self._key .. "|" .. self._count))
      self._widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self._widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function RedPointNode:GetSubNode(key)
  return self._subGroup[key]
end
function RedPointNode:GetSubNodes()
  return self._subGroup or {}
end
function RedPointNode:SetRedPointCount(count)
  if type(count) == "number" then
    count = math.max(count, 0)
    local diff = count - self._count
    self:_PushCount(diff)
  end
end
function RedPointNode:MergeChildNode(node)
  if type(node) ~= "table" then
    return
  end
  local key = node:_GetKey()
  self._subGroup[key] = node
  node:_SetParent(self)
end
function RedPointNode:GetInstances()
  local TableUtil = require("common.table_util")
  return TableUtil.CopyTable(self._instIds)
end
function RedPointNode:ClearInstances()
  self._instIds = {}
  log(bWriteLog and string.format("RedPointNode:ClearInstances self._count = %s", self._count))
  self:_PushCount(-self._count)
end
function RedPointNode:SetInstance(insID)
  insID = tonumber(insID)
  if not self._instIds[insID] then
    self._instIds[insID] = true
    self:_PushCount(1)
  end
end
function RedPointNode:RemoveInstance(insID)
  insID = tonumber(insID)
  if insID and self._instIds[insID] then
    self._instIds[insID] = nil
    if self._count > 0 then
      self:_PushCount(-1)
    end
  end
end
function RedPointNode:CheckInstance(insID)
  insID = tonumber(insID)
  return self._instIds[insID]
end
function RedPointNode:CheckShow()
  return self._count > 0
end
function RedPointNode:RegisterWidget(widget, hook)
  if widget then
    local isShow = self._count > 0
    if type(hook) == "function" then
      self._checkHook = hook
    end
    if self._checkHook and isShow then
      isShow = self._checkHook()
    end
    if isShow then
      log(bWriteLog and string.format("RedPointNode:RegisterWidget %s", self._key .. "|" .. self._count))
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self._  end
end
function RedPointNode:BindEvent(event)
  if type(event) == "function" then
    self._events[event] = true
    event(self._count)
    return event
  end
  return nil
end
function RedPointNode:RemoveEvent(event)
  if self._events[event] then
    self._events[event] = nil
  end
end
function RedPointNode:RemoveAllWidget()
  self._widget = nil
  for _, node in pairs(self._subGroup) do
    node:RemoveAllWidget()
  end
end
local class = require("class")
local object = require("object")
local CUIBase = class(object, nil, RedPointNode)
return CUIBase
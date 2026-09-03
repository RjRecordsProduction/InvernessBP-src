local multi_items_loop_scroll_grid = {}
local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local table_insert = table.insert
local table_remove = table.remove
local table_pack = table.pack
local local local local local 
function multi_items_loop_scroll_grid:ctor()
  self._itemWidgetIndexMap = {}
  self._itemWidgetEvents = {}
  self._itemWidgetChildEvents = {}
  self._itemWidgetMultilevelChildEvents = {}
  self._itemDelegateArray = {}
  self._OnRefreshItemCallBack = nil
  self._data = {}
  self._selectIndex = 0
  self.subItemEvents = {}
  self.subItemWidgetIndexMap = {}
  self._subItemDelegateArray = {}
  self.OnRefreshSubItemEvent = nil
  self._subData = {}
  self._subSelectIndex = 0
  self.OnViewScrolledEvent = nil
  self.SUB_ITEM_LIMIT = 1000
  self.ScrollTimer = nil
  self._itemTypeScriptPath = nil
  self._subItemScriptPath = nil
end
function multi_items_loop_scroll_grid:RegistEvents()
  multi_items_loop_scroll_grid.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnItemCreated", self._OnItemCreated, self)
  self:AddControlEventByControl(self.UIRoot, "OnRefreshItem", self._OnRefreshItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnSubItemCreated", self._OnSubItemCreated, self)
  self:AddControlEventByControl(self.UIRoot, "OnRefreshSubItem", self._OnRefreshSubItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnViewScrolled", self._OnViewScrolled, self)
  self:AddControlEventByControl(self.UIRoot, "OnBeginScroll", self.UserBeginScroll, self)
  self:AddControlEventByControl(self.UIRoot, "OnEndScroll", self.UserEndScroll, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchStartEvent", self.TouchStart, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEndEvent", self.TouchEnd, self)
end
function multi_items_loop_scroll_grid:_AddItemEvent(eventsMap, controlName, eventName, handleFunc, ...)
  local events = eventsMap[controlName]
  if not events then
    events = {}
    eventsMap[controlName] = events
  end
  local args = table_pack(...)
  local common = require("client.slua_ui_framework.common")
  events[eventName] = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
end
function multi_items_loop_scroll_grid:AddItemWidgetEvent(controlName, eventName, handleFunc, ...)
  if self._itemTypeScriptPath then
    log_error("multi_items_loop_scroll_grid:AddItemWidgetEvent is not allowed when _itemTypeScriptPath is set")
    return
  end
  return self:_AddItemEvent(self._itemWidgetEvents, controlName, eventName, handleFunc, ...)
end
function multi_items_loop_scroll_grid:AddItemWidgetChildEvent(controlName, eventName, handleFunc, ...)
  if self._itemTypeScriptPath then
    log_error("multi_items_loop_scroll_grid:AddItemWidgetChildEvent is not allowed when _itemTypeScriptPath is set")
    return
  end
  return self:_AddItemEvent(self._itemWidgetChildEvents, controlName, eventName, handleFunc, ...)
end
function multi_items_loop_scroll_grid:AddItemWidgetMultilevelChildEvent(controlName, eventName, handleFunc, ...)
  if self._itemTypeScriptPath then
    log_error("multi_items_loop_scroll_grid:AddItemWidgetMultilevelChildEvent is not allowed when _itemTypeScriptPath is set")
    return
  end
  return self:_AddItemEvent(self._itemWidgetMultilevelChildEvents, controlName, eventName, handleFunc, ...)
end
function multi_items_loop_scroll_grid:AddSubItemEvent(type, controlName, eventName, handleFunc, funcSelf)
  if self._subItemScriptPath then
    log_error("multi_items_loop_scroll_grid:AddSubItemEvent is not allowed when _subItemScriptPath is set")
    return
  end
  if not self.subItemEvents[type] then
    self.subItemEvents[type] = {}
  end
  local events = self.subItemEvents[type][controlName]
  if not events then
    events = {}
    self.subItemEvents[type][controlName] = events
  end
  events[eventName] = function(...)
    return handleFunc(funcSelf, ...)
  end
end
function multi_items_loop_scroll_grid:_ItemDelegateBind(widget, eventsMap, func)
  for controlName, events in pairs(eventsMap) do
    local control = func(controlName, widget)
    if control ~= nil then
      for eventName, func in pairs(events) do
        local eventDelegate = control[eventName]
        table_insert(self._itemDelegateArray, eventDelegate)
        if eventDelegate.Add then
          eventDelegate:Add(function(...)
            func(widget, self._itemWidgetIndexMap[widget], ...)
          end)
        else
          eventDelegate:Bind(function(...)
            func(widget, self._itemWidgetIndexMap[widget], ...)
          end)
        end
      end
    end
  end
end
function multi_items_loop_scroll_grid:_OnItemCreated(widget, index)
  index = index + 1
  if self._itemTypeScriptPath then
    local childClass = require(self._itemTypeScriptPath)
    local baseUI = childClass()
    baseUI:InitWithParentWidget(self, widget)
    self._itemWidgetIndexMap[widget] = baseUI
  else
    self._itemWidgetIndexMap[widget] = index
    self:_ItemDelegateBind(widget, self._itemWidgetEvents, function(controlName, widget)
      return widget
    end)
    self:_ItemDelegateBind(widget, self._itemWidgetChildEvents, function(controlName, widget)
      return widget[controlName]
    end)
    self:_ItemDelegateBind(widget, self._itemWidgetMultilevelChildEvents, function(controlName, widget)
      return self:_GetControlByName(controlName, widget)
    end)
  end
end
function multi_items_loop_scroll_grid:_OnSubItemCreated(widget, index, subIndex, type)
  index = index + 1
  subIndex = subIndex + 1
  local tempIndex = index * self.SUB_ITEM_LIMIT + subIndex
  self.subItemWidgetIndexMap[widget] = tempIndex
  if self._subItemScriptPath then
    local childClass = require(self._subItemScriptPath)
    local baseUI = childClass()
    baseUI:InitWithParentWidget(self, widget)
    self.subItemWidgetIndexMap[widget] = baseUI
    return
  end
  if not self.subItemEvents[type] then
    return
  end
  for controlName, events in pairs(self.subItemEvents[type]) do
    local control = self:_GetControlByName(controlName, widget)
    if control ~= nil then
      for eventName, func in pairs(events) do
        local eventDelegate = control[eventName]
        table_insert(self._subItemDelegateArray, eventDelegate)
        if eventDelegate ~= nil then
          if eventDelegate.Add then
            eventDelegate:Add(function(...)
              local curIndex = math.modf(self.subItemWidgetIndexMap[widget] / self.SUB_ITEM_LIMIT)
              local curSubIndex = math.fmod(self.subItemWidgetIndexMap[widget], self.SUB_ITEM_LIMIT)
              func(widget, curIndex, curSubIndex, type, ...)
            end)
          else
            eventDelegate:Bind(function(...)
              local curIndex = math.modf(self.subItemWidgetIndexMap[widget] / self.SUB_ITEM_LIMIT)
              local curSubIndex = math.fmod(self.subItemWidgetIndexMap[widget], self.SUB_ITEM_LIMIT)
              func(widget, curIndex, curSubIndex, type, ...)
            end)
          end
        else
          log_warning(string_format("multi_items_loop_scroll_grid:_OnSubItemCreated eventDelegate is nil! controlName\239\188\154[%s] EventName: [%s]", controlName, eventName))
        end
      end
    else
      log_warning(string_format("multi_items_loop_scroll_grid:_OnSubItemCreated control is nil! controlName\239\188\154[%s] ,widget:[%s]", controlName, tostring(widget)))
    end
  end
end
function multi_items_loop_scroll_grid:_OnRefreshItem(widget, index)
  if not self._itemWidgetIndexMap[widget] then
    self:_OnItemCreated(widget, index)
  end
  index = index + 1
  if self._itemTypeScriptPath then
    local instance = self._itemWidgetIndexMap[widget]
    if instance then
      local data = self._data[index]
      instance.      instance.      instance:_RemoveImageDownloadData()
      instance:_RemoveAllAsyncDiskFile()
      instance:OnRefresh(data, self._selectIndex)
    end
  else
    self._itemWidgetIndexMap[widget] = index
    local func = self._OnRefreshItemCallBack
    if func then
      func(widget, index)
    end
  end
end
function multi_items_loop_scroll_grid:_OnRefreshSubItem(widget, index, subIndex, type)
  if not self.subItemWidgetIndexMap[widget] then
    self:_OnSubItemCreated(widget, index, subIndex, type)
  end
  index = index + 1
  subIndex = subIndex + 1
  if self._subItemScriptPath then
    local instance = self.subItemWidgetIndexMap[widget]
    if instance then
      local data = self._subData[index] and self._subData[index][subIndex]
      instance.      instance.      instance.      instance.      instance:_RemoveImageDownloadData()
      instance:_RemoveAllAsyncDiskFile()
      instance:OnRefresh(data, index, subIndex, type)
    end
  else
    local tempIndex = index * self.SUB_ITEM_LIMIT + subIndex
    self.subItemWidgetIndexMap[widget] = tempIndex
    local func = self.OnRefreshSubItemEvent
    if func then
      func(widget, index, subIndex, type)
    end
  end
end
function multi_items_loop_scroll_grid:_OnViewScrolled(offset)
  local func = self.OnViewScrolledEvent
  if func then
    func(offset)
  end
end
function multi_items_loop_scroll_grid:SetItemSize(x)
  if not assert(#self._data == 0, "Must call SetItemSize before SetData!") then
    return
  end
  self.UIRoot.ItemSize = x
end
function multi_items_loop_scroll_grid:SetPadding(x)
  if not assert(#self._data == 0, "Must call SetPadding before SetData!") then
    return
  end
  self.UIRoot.Padding = x
end
function multi_items_loop_scroll_grid:SetData(arrayData)
  if not assert(self._OnRefreshItemCallBack ~= nil or self._itemTypeScriptPath ~= nil, "Must set call SetRefreshItemCallback or set _itemTypeScriptPath before SetData!") then
    return
  end
  self._data = arrayData
  self._selectIndex = 0
  self.UIRoot:SetItemCount(#arrayData)
end
function multi_items_loop_scroll_grid:RemoveItem(index)
  if not assert(self.OnRefreshSubItemEvent ~= nil, "Must set call SetRefreshItemCallback before RemoveItem!") then
    return
  end
  if self._data[index] and self._subData[index] then
    local temp = table_remove(self._data, index)
    local subTemp = table_remove(self._subData, index)
    local result = self.UIRoot:RemoveItemByIndex(index - 1)
    if result == false then
      table.insert(self._data, index, temp)
      table.insert(self._subData, index, subTemp)
    else
    end
    return result
  end
  return false
end
function multi_items_loop_scroll_grid:SetSubData(index, arrayData, typeIndex)
  if not assert(self.OnRefreshSubItemEvent ~= nil or self._subItemScriptPath ~= nil, "Must set call SetRefreshSubItemCallback or set _subItemScriptPath before SetSubData!") then
    return
  end
  self._subData[index] = arrayData
  self._subSelectIndex = 0
  index = index - 1
  self.UIRoot:SetSubItemCount(index, #arrayData, typeIndex)
end
function multi_items_loop_scroll_grid:SetRefreshItemCallback(callback, ...)
  if self._itemTypeScriptPath then
    log_error("multi_items_loop_scroll_grid:SetRefreshItemCallback is not allowed when _itemTypeScriptPath is set")
    return
  end
  local args = table_pack(...)
  local common = require("client.slua_ui_framework.common")
  function self._OnRefreshItemCallBack(...)
    return common.CallCombinationArgs(callback, args, ...)
  end
end
function multi_items_loop_scroll_grid:SetRefreshSubItemCallback(callback, funcSelf)
  if self._subItemScriptPath then
    log_error("multi_items_loop_scroll_grid:SetRefreshSubItemCallback is not allowed when _subItemScriptPath is set")
    return
  end
  function self.OnRefreshSubItemEvent(...)
    return callback(funcSelf, ...)
  end
end
function multi_items_loop_scroll_grid:SetViewScrolledCallback(callback, funcSelf)
  function self.OnViewScrolledEvent(...)
    return callback(funcSelf, ...)
  end
end
function multi_items_loop_scroll_grid:GetItemCount()
  return #self._data
end
function multi_items_loop_scroll_grid:GetSubItemCount()
  local count = 0
  for k, v in pairs(self._subData) do
    count = count + #v
  end
  return count
end
function multi_items_loop_scroll_grid:GetItemData(index)
  if index <= 0 or index > #self._data then
    log_warning(string_format("multi_items_loop_scroll_grid:GetItemData index[%d] out of range[1..%d]", index, #self._data))
  end
  return self._data[index]
end
function multi_items_loop_scroll_grid:GetSubItemData(index, subIndex)
  if not subIndex or subIndex <= 0 or self._subData[index] == nil or subIndex > #self._subData[index] then
    log_warning(string_format("multi_items_loop_scroll_grid:GetSubItemData index[%d] subIndex[%s]", index, tostring(subIndex)))
  end
  return self._subData[index][subIndex]
end
function multi_items_loop_scroll_grid:GetSubItemList(index)
  return self._subData[index]
end
function multi_items_loop_scroll_grid:RefreshItem(index, itemData)
  if index <= 0 or index > #self._data then
    log_warning(string_format("multi_items_loop_scroll_grid:RefreshItem index[%d] out of range[1..%d]", index, #self._data))
    return
  end
  self._data[index] = itemData
  self.UIRoot:RefreshItem(index - 1)
end
function multi_items_loop_scroll_grid:RefreshSubItem(index, subIndex, itemData)
  if not subIndex or subIndex <= 0 or self._subData[index] == nil or subIndex > #self._subData[index] then
    log_warning(string_format("multi_items_loop_scroll_grid:RefreshSubItem index[%d] subIndex[%s]", index, tostring(subIndex)))
    return
  end
  self._subData[index][subIndex] = itemData
  self.UIRoot:RefreshSubItem(index - 1, subIndex - 1)
end
function multi_items_loop_scroll_grid:RefreshAllItems(newData)
  if newData then
    if #self._data ~= #newData then
      log_warning("multi_items_loop_scroll_grid:RefreshAllItems #self._data == #newData")
    end
    self._data = newData
  end
  self.UIRoot:RefreshAllItems()
end
function multi_items_loop_scroll_grid:RefreshAllSubItems(index, newData)
  if newData then
    if #self._subData[index] ~= #newData then
      log_warning("multi_items_loop_scroll_grid:RefreshAllSubItems #self._subData[index] == #newData")
    end
    self._subData[index] = newData
  end
  self.UIRoot:RefreshAllSubItems()
end
function multi_items_loop_scroll_grid:ScrollToItem(index)
  if index <= 0 then
    log_warning("multi_items_loop_scroll_grid:ScrollToItem index <= 0")
    return
  end
  self.UIRoot:ScrollToItem(index - 1)
end
function multi_items_loop_scroll_grid:ScrollToSubItem(index, subIndex)
  if index <= 0 or subIndex <= 0 then
    log_warning("multi_items_loop_scroll_grid:ScrollToSubItem index <= 0 or subIndex <= 0")
    return
  end
  self.UIRoot:ScrollToSubItemByIndex(index - 1, subIndex - 1)
end
function multi_items_loop_scroll_grid:Select(index)
  if index <= 0 or index > #self._data then
    log_warning(string_format("multi_items_loop_scroll_grid:Select index[%d] out of range[1..%d]", index, #self._data))
    return
  end
  local preSelectIndex = self._selectIndex
  self._selectIndex = index
  if preSelectIndex ~= index and 0 < preSelectIndex then
    self.UIRoot:RefreshItem(preSelectIndex - 1)
  end
  self.UIRoot:RefreshItem(index - 1)
end
function multi_items_loop_scroll_grid:SelectSub(index, subIndex)
  if not subIndex or index <= 0 or subIndex <= 0 or self._subData[index] == nil or subIndex > #self._subData[index] then
    log_warning(string_format("multi_items_loop_scroll_grid:SelectSub index[%d] subIndex[%s]", index, tostring(subIndex)))
    return
  end
  local preSelectIndex = self._selectIndex
  local preSubSelectIndex = self._subSelectIndex
  self._selectIndex = index
  self._subSelectIndex = subIndex
  if (preSelectIndex ~= index or preSubSelectIndex ~= subIndex) and 0 < preSelectIndex and 0 < preSubSelectIndex then
    self.UIRoot:RefreshSubItem(preSelectIndex - 1, preSubSelectIndex - 1)
  end
  self.UIRoot:RefreshSubItem(index - 1, subIndex - 1)
end
function multi_items_loop_scroll_grid:Deselect()
  if self._selectIndex > 0 then
    local preSelectIndex = self._selectIndex
    self._selectIndex = 0
    self.UIRoot:RefreshItem(preSelectIndex - 1)
  end
end
function multi_items_loop_scroll_grid:DeselectSub()
  if self._subSelectIndex > 0 then
    local preSubSelectIndex = self._subSelectIndex
    self._subSelectIndex = 0
    self.UIRoot:RefreshSubItem(self._selectIndex - 1, preSubSelectIndex - 1)
  end
end
function multi_items_loop_scroll_grid:GetSelectIndex()
  return self._selectIndex
end
function multi_items_loop_scroll_grid:GetSubSelectIndex()
  return self._subSelectIndex
end
function multi_items_loop_scroll_grid:_ClearEvents()
  self:ClearItemEvents()
  self:ClearSubItemEvents()
end
function multi_items_loop_scroll_grid:ClearItemEvents()
  if not self._itemDelegateArray then
    return
  end
  for _, eventDelegate in pairs(self._itemDelegateArray) do
    if eventDelegate.Clear then
      eventDelegate:Clear()
    end
  end
end
function multi_items_loop_scroll_grid:ClearSubItemEvents()
  if not self._subItemDelegateArray then
    return
  end
  for _, eventDelegate in pairs(self._subItemDelegateArray) do
    if eventDelegate.Clear then
      eventDelegate:Clear()
    end
  end
end
function multi_items_loop_scroll_grid:OnClose()
  self:_ClearEvents()
end
function multi_items_loop_scroll_grid:GetStartIndex(offset)
  return self.UIRoot:GetStartIndex(offset)
end
function multi_items_loop_scroll_grid:GetEndIndex(offset)
  return self.UIRoot:GetEndIndex(offset)
end
function multi_items_loop_scroll_grid:ClearScrollTimer()
  if self.ScrollTimer then
    self:RemoveTimer(self.ScrollTimer)
    self.ScrollTimer = nil
  end
end
function multi_items_loop_scroll_grid:UserBeginScroll()
  self:ClearScrollTimer()
end
function multi_items_loop_scroll_grid:UserEndScroll()
end
function multi_items_loop_scroll_grid:TouchStart()
  self:ClearScrollTimer()
end
function multi_items_loop_scroll_grid:TouchEnd()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIExtendedLoopScrollGrid = class(ui_base, nil, multi_items_loop_scroll_grid)
return CUIExtendedLoopScrollGrid
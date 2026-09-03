local extended_loop_scroll_grid = {}
local string_format = string.format
local math_modf = math.modf
local table_insert = table.insert
local local local local local local 
function extended_loop_scroll_grid:ctor()
  self.SUB_ITEM_LIMIT = 1000
end
function extended_loop_scroll_grid:SetRefreshSubItemCallback(callback, funcSelf)
  if self:HasItemModuleName() then
    log_error("[UI_LoopScrollBox]extended_loop_scroll_grid:SetRefreshSubItemCallback HasItemModuleName")
    return
  end
  function self._OnRefreshSubItemCallBack(widget, index, subIndex)
    return callback(funcSelf, widget, index, subIndex)
  end
end
function extended_loop_scroll_grid:_OnSubItemCreated(widget, index, subIndex)
  if self._GMLogDebug then
    log(bWriteLog and string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnSubItemCreated UIRoot:%s index:%d subIndex:%d", tostring(self.UIRoot), index, subIndex))
  end
  index = index + 1
  subIndex = subIndex + 1
  local tempIndex = index * self.SUB_ITEM_LIMIT + subIndex
  self._subItemWidgetIndexMap = self._subItemWidgetIndexMap or {}
  if self:HasItemModuleName() then
    local childBase = require(self:GetSubItemModuleName())
    local baseUI = childBase()
    baseUI:InitWithParentWidget(self, widget)
    self._subItemWidgetIndexMap[widget] = baseUI
  else
    self._subItemWidgetIndexMap[widget] = tempIndex
  end
  if not self:HasItemModuleName() then
    self._subItemEvents = self._subItemEvents or {}
    self._subItemDelegateArray = self._subItemDelegateArray or {}
    for controlName, events in pairs(self._subItemEvents) do
      local control = self:_GetControlByName(controlName, widget)
      if control ~= nil then
        for eventName, func in pairs(events) do
          local localIndexFunc = function(...)
            local index = math_modf(self._subItemWidgetIndexMap[widget] / self.SUB_ITEM_LIMIT)
            local subIndex = math.fmod(self._subItemWidgetIndexMap[widget], self.SUB_ITEM_LIMIT)
            if self._GMLogDebug then
              log(bWriteLog and string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnSubItemCreated localIndexFunc UIRoot:%s index:%d subIndex:%d", tostring(self.UIRoot), index, subIndex))
            end
            func(widget, index, subIndex, ...)
          end
          local eventDelegate = control[eventName]
          table_insert(self._subItemDelegateArray, eventDelegate)
          if eventDelegate ~= nil then
            if eventDelegate.Add then
              eventDelegate:Add(localIndexFunc)
            else
              eventDelegate:Bind(localIndexFunc)
            end
          else
            log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnSubItemCreated eventDelegate is nil! controlName\239\188\154[%s] EventName: [%s]", controlName, eventName))
          end
        end
      else
        log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnSubItemCreated control is nil! controlName\239\188\154[%s] ,widget:[%s]", controlName, tostring(widget)))
      end
    end
  end
end
function extended_loop_scroll_grid:_OnRefreshSubItem(widget, index, subIndex)
  if self._GMLogDebug then
    log(bWriteLog and string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnRefreshSubItem UIRoot:%s index:%d subIndex:%d", tostring(self.UIRoot), index, subIndex))
  end
  self._subItemWidgetIndexMap = self._subItemWidgetIndexMap or {}
  if not self._subItemWidgetIndexMap[widget] then
    self:_OnSubItemCreated(widget, index, subIndex)
  end
  index = index + 1
  subIndex = subIndex + 1
  if self:HasItemModuleName() then
    if self._subItemWidgetIndexMap[widget] then
      local data = self:GetSubItemData(index, subIndex)
      local scroll_box_child_base = self._subItemWidgetIndexMap[widget]
      scroll_box_child_base.      scroll_box_child_base.      scroll_box_child_base.      self._subItemWidgetIndexMap[widget]:OnSubRefresh(data, self._selectIndex, self._subSelectIndex)
    end
  else
    local tempIndex = index * self.SUB_ITEM_LIMIT + subIndex
    self._subItemWidgetIndexMap[widget] = tempIndex
    if self._OnRefreshSubItemCallBack then
      self._OnRefreshSubItemCallBack(widget, index, subIndex)
    else
      log_error("[UI_LoopScrollBox]extended_loop_scroll_grid:_OnRefreshSubItem self._OnRefreshSubItemCallBack = nil")
    end
  end
end
function extended_loop_scroll_grid:SetSubData(index, arrayData)
  arrayData = arrayData or {}
  self._subData[index] = arrayData
  self._subSelectIndex = 0
  index = index - 1
  self.UIRoot:SetSubItemCount(index, #arrayData)
end
function extended_loop_scroll_grid:GetSubItemCount()
  local count = 0
  for k, v in pairs(self._subData) do
    count = count + #v
  end
  return count
end
function extended_loop_scroll_grid:GetSubItemData(index, subIndex)
  if not subIndex or subIndex <= 0 or self._subData[index] == nil or subIndex > #self._subData[index] then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:GetSubItemData index[%s] subIndex[%s]", tostring(index), tostring(subIndex)))
    return nil
  end
  return self._subData[index][subIndex]
end
function extended_loop_scroll_grid:GetAllItemData()
  local list = {}
  for k, v in ipairs(self._subData) do
    for kk, vv in pairs(v) do
      table_insert(list, vv)
    end
  end
  return list
end
function extended_loop_scroll_grid:GetSubItemList(index)
  return self._subData[index]
end
function extended_loop_scroll_grid:RefreshSubItem(index, subIndex, itemData)
  if not subIndex or subIndex <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:RefreshSubItem index[%d] subIndex[%s] <= 0", index, tostring(subIndex)))
    return
  end
  if self._subData[index] == nil or subIndex > #self._subData[index] then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:RefreshSubItem index[%d] subIndex[%s]", index, tostring(subIndex)))
  end
  if itemData then
    self._subData[index][subIndex] = itemData
  end
  self.UIRoot:RefreshSubItem(index - 1, subIndex - 1)
end
function extended_loop_scroll_grid:OnResizeLoop()
  local _subData = self._subData
  local _offset = self:GetItemOffset() or 0
  self.UIRoot:SetItemCount(0)
  self:AddTimerOnce(0, function()
    self:SetData(self._data)
    for i, v in ipairs(_subData) do
      self:SetSubData(i, v)
    end
    self:SetItemOffset(_offset)
  end)
end
function extended_loop_scroll_grid:RefreshAllItems(newData)
  if newData then
    if #self._data ~= #newData then
      log_warning("[UI_LoopScrollBox]extended_loop_scroll_grid:RefreshAllItems #self._data == #newData")
    end
    self._data = newData
  end
  self.UIRoot:RefreshAllItems()
end
function extended_loop_scroll_grid:RefreshAllSubItems(index, newData)
  if newData then
    if #self._subData[index] ~= #newData then
      log_warning("[UI_LoopScrollBox]extended_loop_scroll_grid:RefreshAllSubItems #self._subData[index] == #newData")
    end
    self._subData[index] = newData
  end
  self.UIRoot:RefreshAllSubItems()
end
function extended_loop_scroll_grid:SelectSub(index, subIndex)
  if not (not (index <= 0) and subIndex) or subIndex <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:SelectSub index[%d] subIndex[%s] <= 0", index, tostring(subIndex)))
    return
  end
  if self._subData[index] == nil or subIndex > #self._subData[index] then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:SelectSub index[%d] subIndex[%s]", index, tostring(subIndex)))
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
function extended_loop_scroll_grid:DeselectSub()
  if self._subSelectIndex > 0 then
    local preSubSelectIndex = self._subSelectIndex
    self._subSelectIndex = 0
    self.UIRoot:RefreshSubItem(self._selectIndex - 1, preSubSelectIndex - 1)
  end
end
function extended_loop_scroll_grid:ScrollToSubItem(index, subIndex)
  if not (not (index <= 0) and subIndex) or subIndex <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_grid:ScrollToSubItem index[%d] subIndex[%s]", index, tostring(subIndex)))
    return
  end
  self.UIRoot:ScrollToSubItemByIndex(index - 1, subIndex - 1)
end
function extended_loop_scroll_grid:GetStartIndex(offset)
  return self.UIRoot:GetStartIndex(offset)
end
function extended_loop_scroll_grid:GetEndIndex(offset)
  return self.UIRoot:GetEndIndex(offset)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.extended_loop_scroll_box")
local CUIExtendedLoopScrollGrid = class(ui_base, nil, extended_loop_scroll_grid)
return CUIExtendedLoopScrollGrid
local extended_loop_scroll_box = {}
local string_format = string.format
local table_insert = table.insert
local local local local local local local 
function extended_loop_scroll_box:ctor()
  self._subItemWidgetIndexMap = nil
  self._subItemEvents = nil
  self._subItemDelegateArray = nil
  self._OnRefreshSubItemCallBack = nil
  self._subData = {}
  self._subSelectIndex = 0
  self.OnViewScrolledEvent = nil
  self._curUnfoldParentIndex = 0
  self._subTabUnfoldState = false
end
function extended_loop_scroll_box:RegistEvents()
  extended_loop_scroll_box.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnRefreshSubItem", self._OnRefreshSubItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnSubItemCreated", self._OnSubItemCreated, self)
  self:AddControlEventByControl(self.UIRoot, "OnViewScrolled", self._OnViewScrolled, self)
end
function extended_loop_scroll_box:AddSubItemEvent(controlName, eventName, handleFunc, funcSelf)
  if self:HasItemModuleName() then
    log_error("[UI_LoopScrollBox]extended_loop_scroll_box:AddSubItemEvent HasItemModuleName")
    return
  end
  self._subItemEvents = self._subItemEvents or {}
  local events = self._subItemEvents[controlName]
  if not events then
    events = {}
    self._subItemEvents[controlName] = events
  end
  events[eventName] = function(...)
    return handleFunc(funcSelf, ...)
  end
end
function extended_loop_scroll_box:SetRefreshSubItemCallback(callback, funcSelf)
  if self:HasItemModuleName() then
    log_error("[UI_LoopScrollBox]extended_loop_scroll_box:SetRefreshSubItemCallback HasItemModuleName")
    return
  end
  function self._OnRefreshSubItemCallBack(widget, index)
    return callback(funcSelf, widget, index)
  end
end
function extended_loop_scroll_box:SetViewScrolledCallback(callback, funcSelf)
  function self.OnViewScrolledEvent(offset)
    return callback(funcSelf, offset)
  end
end
function extended_loop_scroll_box:_OnRefreshSubItem(widget, index)
  if self._GMLogDebug then
    log(bWriteLog and string_format("[UI_LoopScrollBox]extended_loop_scroll_box:_OnRefreshSubItem UIRoot:%s index:%d", tostring(self.UIRoot), index))
  end
  self._subItemWidgetIndexMap = self._subItemWidgetIndexMap or {}
  if not self._subItemWidgetIndexMap[widget] then
    self:_OnSubItemCreated(widget, index)
  end
  index = index + 1
  if self:HasItemModuleName() then
    if self._subItemWidgetIndexMap[widget] then
      local data = self:GetSubItemData(index)
      local scroll_box_child_base = self._subItemWidgetIndexMap[widget]
      scroll_box_child_base.      scroll_box_child_base.      self._subItemWidgetIndexMap[widget]:OnSubRefresh(data, self._subSelectIndex)
    end
  else
    self._subItemWidgetIndexMap[widget] = index
    if self._OnRefreshSubItemCallBack then
      self._OnRefreshSubItemCallBack(widget, index)
    else
      log_error("[UI_LoopScrollBox]extended_loop_scroll_box:_OnRefreshSubItem self._OnRefreshSubItemCallBack = nil")
    end
  end
end
function extended_loop_scroll_box:_OnSubItemCreated(widget, widgetIndex)
  if self._GMLogDebug then
    log(bWriteLog and string_format("[UI_LoopScrollBox]extended_loop_scroll_box:_OnSubItemCreated UIRoot:%s widgetIndex:%d", tostring(self.UIRoot), widgetIndex))
  end
  widgetIndex = widgetIndex + 1
  self._subItemWidgetIndexMap = self._subItemWidgetIndexMap or {}
  if self:HasItemModuleName() then
    local childBase = require(self:GetSubItemModuleName())
    local baseUI = childBase()
    baseUI:InitWithParentWidget(self, widget)
    self._subItemWidgetIndexMap[widget] = baseUI
  else
    self._subItemWidgetIndexMap[widget] = widgetIndex
  end
  if not self:HasItemModuleName() then
    self._subItemEvents = self._subItemEvents or {}
    self._subItemDelegateArray = self._subItemDelegateArray or {}
    for controlName, events in pairs(self._subItemEvents) do
      local control = self:_GetControlByName(controlName, widget)
      if control ~= nil then
        for eventName, func in pairs(events) do
          local localIndexFunc = function(...)
            func(widget, self._subItemWidgetIndexMap[widget], ...)
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
            log_warning(string_format("extended_loop_scroll_box:_OnSubItemCreated  eventDelegate is nil! controlName\239\188\154[%s] EventName: [%s]", controlName, eventName))
          end
        end
      else
        log_warning(string_format("extended_loop_scroll_box:_OnSubItemCreated  control is nil! controlName\239\188\154[%s] ,widget:[%s]", controlName, tostring(widget)))
      end
    end
  end
  self:InvalidateLayoutCache()
end
function extended_loop_scroll_box:_OnViewScrolled(offset)
  local func = self.OnViewScrolledEvent
  if func then
    func(offset)
  end
end
function extended_loop_scroll_box:_ClearEvents()
  extended_loop_scroll_box.__super._ClearEvents(self)
  self:_ClearSubItemEvents()
end
function extended_loop_scroll_box:_ClearSubItemEvents()
  if self:HasItemModuleName() then
    return
  end
  if not self._subItemDelegateArray then
    return
  end
  for _, eventDelegate in pairs(self._subItemDelegateArray) do
    if eventDelegate.Clear then
      eventDelegate:Clear()
    end
  end
end
function extended_loop_scroll_box:_GetIndexBySubWidget(widget)
  local index = self.UIRoot:GetSubWidgetIndex(widget)
  if index < 0 then
    log_warning("extended_loop_scroll_box:_GetIndexBySubWidget index >= 0")
    return nil
  end
  return index + 1
end
function extended_loop_scroll_box:_GetIndexOfSubWidget(index)
  local count = self:GetSubItemCount()
  if index <= 0 or index > self:GetSubItemCount() then
    log_warning(string_format("extended_loop_scroll_box:_GetIndexOfSubWidget index > 0 and index <= self:GetSubItemCount(), index:[%s]", tostring(index)))
  end
  return self.UIRoot:GetIndexOfSubWidget(index - 1)
end
function extended_loop_scroll_box:SetData(arrayData)
  self._curUnfoldParentIndex = 0
  self._subTabUnfoldState = false
  self._subData = {}
  self._subSelectIndex = 0
  extended_loop_scroll_box.__super.SetData(self, arrayData)
end
function extended_loop_scroll_box:SetSubData(index, arrayData)
  if not self.UIRoot then
    return
  end
  self._subData = arrayData or {}
  self:_UpdateUnfoldState(index, #self._subData)
  self._curUnfoldParentIndex = index
  index = index - 1
  self._subSelectIndex = 0
  self.UIRoot:SetSubItemCount(index, #self._subData)
  self:InvalidateLayoutCache()
end
function extended_loop_scroll_box:GetSubItemData(index)
  if index <= 0 or index > #self._subData then
    log_warning(string_format("extended_loop_scroll_box:GetSubItemData index[%d] out of range[1..%d]", index, #self._subData))
    return nil
  end
  return self._subData[index]
end
function extended_loop_scroll_box:GetSubItemCount()
  return #self._subData
end
function extended_loop_scroll_box:GetAllItemData()
  return self:GetSetData()
end
function extended_loop_scroll_box:GetSubAllItemData()
  return self._subData
end
function extended_loop_scroll_box:RefreshAllItems()
  self.UIRoot:RefreshAllItems()
  self:InvalidateLayoutCache()
end
function extended_loop_scroll_box:OnResizeLoop()
  local _selectIndex = self._selectIndex
  local _curUnfoldParentIndex = self._curUnfoldParentIndex
  local _subData = self._subData
  local _subSelectIndex = self._subSelectIndex
  self.UIRoot:SetItemCount(0)
  self:AddTimerOnce(0, function()
    self:SetData(self._data)
    if _selectIndex then
      self:Select(_selectIndex)
    end
    if _curUnfoldParentIndex then
      self:SetSubData(_curUnfoldParentIndex, _subData)
      if _subSelectIndex ~= 0 then
        self:SelectSub(_subSelectIndex)
      end
    end
  end)
end
function extended_loop_scroll_box:RefreshSubItem(index, itemData)
  if index <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:RefreshSubItem index[%d] <= 0", index))
    return
  end
  if index > #self._subData then
    log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:RefreshSubItem index[%d] out of range[1..%d]", index, #self._data))
  end
  if itemData then
    self._subData[index] = itemData
  end
  self.UIRoot:RefreshSubItem(index - 1)
end
function extended_loop_scroll_box:RefreshAllSubItems(newData)
  if newData then
    if #self._subData ~= #newData then
      log_warning("extended_loop_scroll_box:RefreshAllSubItems #self._subData == #newData")
    end
    self._subData = newData
  end
  self.UIRoot:RefreshAllSubItems()
  self:InvalidateLayoutCache()
end
function extended_loop_scroll_box:SetSubItemSize(x, y)
  if self._data and #self._data ~= 0 then
    log_error("[UI_LoopScrollBox]extended_loop_scroll_box:SetSubItemSize Must call before SetData!")
  end
  self.UIRoot.SubItemSize = FVector2D(x, y)
end
function extended_loop_scroll_box:SetSubPadding(x, y)
  if self._data and #self._data ~= 0 then
    log_error("[UI_LoopScrollBox]extended_loop_scroll_box:SetSubPadding Must call before SetData!")
  end
  self.UIRoot.SubPadding = FVector2D(x, y)
end
function extended_loop_scroll_box:SelectSub(index)
  if index <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:SelectSub index[%d] <= 0", index))
    return
  end
  if index > #self._subData then
    log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:SelectSub index[%d] out of range[1..%d]", index, #self._subData))
  end
  if self._subSelectIndex ~= index then
    local preSelectIndex = self._subSelectIndex
    self._subSelectIndex = index
    if 0 < preSelectIndex then
      self.UIRoot:RefreshSubItem(preSelectIndex - 1)
    end
    self.UIRoot:RefreshSubItem(index - 1)
  end
end
function extended_loop_scroll_box:DeselectSub()
  if self._subSelectIndex > 0 then
    local preSelectIndex = self._subSelectIndex
    self._subSelectIndex = 0
    self.UIRoot:RefreshSubItem(preSelectIndex - 1)
  end
end
function extended_loop_scroll_box:GetSubSelectIndex()
  return self._subSelectIndex
end
function extended_loop_scroll_box:GetItemModuleName()
  return self._itemModuleName[1]
end
function extended_loop_scroll_box:GetSubItemModuleName()
  return self._itemModuleName[2]
end
function extended_loop_scroll_box:ScrollItemToFirstPosition(index)
  if index <= 0 then
    log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:ScrollItemToFirstPosition index[%d] <= 0", index))
    return
  end
  self.UIRoot:ScrollItemToFirstPositionByIndex(index - 1)
end
function extended_loop_scroll_box:ScrollToSubItem(index)
  if index <= 0 then
    log_error(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:ScrollToSubItem index[%d] <= 0", index))
    return
  end
  if index > #self._subData then
    log_warning(string_format("[UI_LoopScrollBox]extended_loop_scroll_box:ScrollToSubItem index[%d] out of range[1..%d]", index, #self._subData))
  end
  self.UIRoot:ScrollToSubItemByIndex(index - 1)
end
function extended_loop_scroll_box:AutoSize(bAutoSize)
  log_error("extended_loop_scroll_box:AutoSize() deprecated!")
end
function extended_loop_scroll_box:RemoveItem(index)
  log_error("extended_loop_scroll_box:RemoveItem() deprecated!")
end
function extended_loop_scroll_box:InsertItem(index, itemData)
  log_error("extended_loop_scroll_box:InsertItem() deprecated!")
end
function extended_loop_scroll_box:FoldingSubTab()
  if self._curUnfoldParentIndex > 0 and 0 < #self._subData then
    self.UIRoot:SetSubItemCount(self._curUnfoldParentIndex - 1, #self._subData)
    self:InvalidateLayoutCache()
    self._subTabUnfoldState = not self._subTabUnfoldState
  else
    log_warning(string_format("extended_loop_scroll_box:FoldingSubTab There is currently no sub tab data set."))
  end
end
function extended_loop_scroll_box:_UpdateUnfoldState(index, subTabCount)
  if subTabCount <= 0 then
    self._subTabUnfoldState = false
  elseif self._curUnfoldParentIndex ~= index then
    self._subTabUnfoldState = true
  else
    self._subTabUnfoldState = not self._subTabUnfoldState
  end
  if self._GMLogDebug then
    log(bWriteLog and string_format("extended_loop_scroll_box:UpdateUnfoldState index = %s, subTabCount = %s, self._subTabExpandedState = %s", index, subTabCount, self._subTabUnfoldState))
  end
end
function extended_loop_scroll_box:GetSubTabUnfoldState()
  if self._GMLogDebug then
    log(bWriteLog and string_format("extended_loop_scroll_box:GetSubTabUnfoldState self._subTabExpandedState = %s", self._subTabUnfoldState))
  end
  return self._subTabUnfoldState
end
function extended_loop_scroll_box:GetCurrentUnfoldParentIndex()
  if self._GMLogDebug then
    log(bWriteLog and string_format("extended_loop_scroll_box:GetCurrentUnfoldParentIndex self._curParentIndex = %s", self._curUnfoldParentIndex))
  end
  return self._curUnfoldParentIndex
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.loop_scroll_box")
local CUIExtendedLoopScrollBox = class(ui_base, nil, extended_loop_scroll_box)
return CUIExtendedLoopScrollBox
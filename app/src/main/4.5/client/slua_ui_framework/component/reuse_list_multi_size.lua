local reuse_list_multi_size = {}
local string_format = string.format
local FuncUtil_Clamp = FuncUtil.Clamp
local local local 
function reuse_list_multi_size:ctor()
  self.GetItemSizeEvent = nil
  self.OnNotScrollToEndEvent = nil
  self.IndexAfterSetData = 1
  self.stickToEnd = false
end
function reuse_list_multi_size:RegistEvents()
  reuse_list_multi_size.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnScrollToBegin", self._OnScrollToBegin, self)
  self:AddControlEventByControl(self.UIRoot, "OnScrollToEnd", self._OnScrollToEnd, self)
  self:AddControlEventByControl(self.UIRoot, "GetItemSize", self._GetItemSize, self)
end
function reuse_list_multi_size:_OnScrollToBegin()
  local func = self.OnScrollToBeginEvent
  if func then
    func()
  end
end
function reuse_list_multi_size:_OnScrollToEnd()
  local func = self.OnScrollToEndEvent
  if func then
    func()
  end
end
function reuse_list_multi_size:_GetItemSize(index)
  index = index + 1
  local func = self.GetItemSizeEvent
  if func then
    return func(index)
  end
end
function reuse_list_multi_size:SetGetItemSizeCallback(callback, funcSelf)
  function self.GetItemSizeEvent(...)
    return callback(funcSelf, ...)
  end
end
function reuse_list_multi_size:SetScrollToBeginCallback(callback, funcSelf)
  function self.OnScrollToBeginEvent()
    return callback(funcSelf)
  end
end
function reuse_list_multi_size:SetScrollToEndCallback(callback, funcSelf)
  function self.OnScrollToEndEvent()
    return callback(funcSelf)
  end
end
function reuse_list_multi_size:SetNotScrollToEndCallback(callback, funcSelf)
  function self.OnNotScrollToEndEvent(index)
    return callback(funcSelf, index)
  end
end
function reuse_list_multi_size:SetData(arrayData)
  self._data = arrayData
  self._selectIndex = 0
  self:SetItemCount(#arrayData, self.IndexAfterSetData)
  self.IndexAfterSetData = 1
end
function reuse_list_multi_size:SetItemCount(num, bgItemIndex)
  if not self.UIRoot then
    return
  end
  bgItemIndex = bgItemIndex or 1
  bgItemIndex = FuncUtil_Clamp(bgItemIndex, 1, #self._data)
  self.UIRoot:SetItemCount(num, bgItemIndex - 1)
end
function reuse_list_multi_size:InsertItem(index, itemData)
  local isScrollToEnd = self:IsScrollToEnd()
  reuse_list_multi_size.__super.InsertItem(self, index, itemData)
  if isScrollToEnd then
    if self.stickToEnd then
      self:ScrollToEnd()
    end
  elseif self.OnNotScrollToEndEvent then
    self.OnNotScrollToEndEvent(index)
  end
end
function reuse_list_multi_size:AppendItem(itemData)
  local isScrollToEnd = self:IsScrollToEnd()
  reuse_list_multi_size.__super.AppendItem(self, itemData)
  if isScrollToEnd then
    if self.stickToEnd then
      self:ScrollToEnd()
    end
  else
    local index = #self._data
    if self.OnNotScrollToEndEvent then
      self.OnNotScrollToEndEvent(index)
    end
  end
end
function reuse_list_multi_size:InitObjectPool(Count)
  if self._data and #self._data ~= 0 then
    log_error("[UI_LoopScrollBox]reuse_list_multi_size:InitObjectPool Must call before SetData!")
  end
  self.UIRoot:InitObjectPool(Count)
end
function reuse_list_multi_size:SetItemSize(x, y)
  self.UIRoot.ItemSize = FVector2(x, y)
end
function reuse_list_multi_size:SetPadding(x)
  self.UIRoot.Padding = x
end
function reuse_list_multi_size:SetIndexAfterSetData(Index)
  self.IndexAfterSetData = Index
end
function reuse_list_multi_size:SetStickToEnd(bStick)
  self.stickToEnd = bStick
end
function reuse_list_multi_size:ScrollToItem(index, bScrollThisFrame)
  if index <= 0 then
    log_error(string_format("[UI_LoopScrollBox]reuse_list_multi_size:ScrollToItem index[%d] <= 0", index))
    return
  end
  self.UIRoot:ScrollToItem(index - 1, bScrollThisFrame)
end
function reuse_list_multi_size:IsScrollToBegin()
  return self.UIRoot:IsScrollToBegin()
end
function reuse_list_multi_size:IsScrollToEnd()
  return self.UIRoot:IsScrollToEnd()
end
function reuse_list_multi_size:ScrollToEnd()
  self.UIRoot:ScrollToItem(#self._data, true)
end
function reuse_list_multi_size:GetContentSize()
  return self.UIRoot:GetContentSize()
end
function reuse_list_multi_size:GetViewSize()
  return self.UIRoot:GetViewSize()
end
function reuse_list_multi_size:GetItemStartIndex()
  return self.UIRoot:GetItemStartIndex()
end
function reuse_list_multi_size:GetItemEndIndex()
  return self.UIRoot:GetItemEndIndex()
end
function reuse_list_multi_size:RefreshAllItems(newData)
  if newData ~= nil and self._superListInfo ~= nil then
    log_warning("reuse_list_multi_size:RefreshAllItems Can't use RefreshAllItems with super list!")
    return
  end
  if newData then
    if #self._data ~= #newData then
      log_warning("reuse_list_multi_size:RefreshAllItems #self._data == #newData")
    end
    self._data = newData
  end
  self.UIRoot:RefreshAllItems()
  self:InvalidateLayoutCache()
end
function reuse_list_multi_size:AutoSize(bAutoSize)
  log_error("reuse_list_multi_size:AutoSize() deprecated!")
end
function reuse_list_multi_size:OnResizeLoop()
  log(bWriteLog and "reuse_list_multi_size:OnResizeLoop.  Not implemented")
end
local class = require("class")
local loop_scroll_box = require("client.slua_ui_framework.component.loop_scroll_box")
local CUI_ReuseListMultiSize = class(loop_scroll_box, nil, reuse_list_multi_size)
return CUI_ReuseListMultiSize
local reuse_fall_multi_size = {}
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local local local math_ceil = math.ceil
local local local 
function reuse_fall_multi_size:ctor()
  self.OnBeforeNewItemEvent = nil
  self.OnAfterNewItemEvent = nil
  self.OnOverscrollStateEvent = nil
  self.OnTouchFinishEvent = nil
end
function reuse_fall_multi_size:RegistEvents()
  reuse_fall_multi_size.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot, "OnBeforeNewItem", self._OnBeforeNewItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnAfterNewItem", self._OnAfterNewItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnOverscrollState", self._OnOverscrollState, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchFinish", self._OnTouchFinish, self)
  self:AddControlEventByControl(self.UIRoot, "OnItemHide", self._OnItemHide, self)
end
function reuse_fall_multi_size:RefreshAllItems(newData)
  if newData then
    if #self._data ~= #newData then
      log_warning("[UI_LoopScrollBox]reuse_fall_multi_size:RefreshAllItems #self._data == #newData")
    end
    self._data = newData
  end
  self.UIRoot:Refresh()
end
function reuse_fall_multi_size:SetItemSize(x, y)
  self.UIRoot.ItemSize = FVector2(x, y)
end
function reuse_fall_multi_size:SetPadding(x)
  self.UIRoot.Padding = x
end
function reuse_fall_multi_size:SetItemCount(num)
  self.UIRoot:Reload(num)
end
function reuse_fall_multi_size:GetItemCount()
  return self._data and #self._data or 0
end
function reuse_fall_multi_size:_OnBeforeNewItem(index)
  index = index + 1
  local func = self.OnBeforeNewItemEvent
  if func then
    func(index)
  end
end
function reuse_fall_multi_size:_OnAfterNewItem(Widget, index)
  index = index + 1
  local func = self.OnAfterNewItemEvent
  if func then
    func(Widget, index)
  end
end
function reuse_fall_multi_size:_OnItemHide(Widget, index)
  index = index + 1
  print(bWriteLog and "reuse_fall_multi_size:_OnItemHide")
  if self._itemWidgetIndexMap[Widget] and self._itemWidgetIndexMap[Widget].OnReuseFallHide then
    self._itemWidgetIndexMap[Widget]:OnReuseFallHide()
  end
end
function reuse_fall_multi_size:_OnOverscrollState(OverscrollState)
  local func = self.OnOverscrollStateEvent
  if func then
    func(OverscrollState)
  end
end
function reuse_fall_multi_size:_OnTouchFinish()
  local func = self.OnTouchFinishEvent
  if func then
    func()
  end
end
function reuse_fall_multi_size:SetItemFullStyle(indexList)
  self.UIRoot:ClearItemFullStyle()
  for _, index in pairs(indexList) do
    self.UIRoot:SetItemFullStyle(index - 1)
  end
end
function reuse_fall_multi_size:SetBeforeNewItemCallback(callback, funcSelf)
  function self.OnBeforeNewItemEvent(...)
    return callback(funcSelf, ...)
  end
end
function reuse_fall_multi_size:SetAfterNewItemCallback(callback, funcSelf)
  function self.OnAfterNewItemEvent(...)
    return callback(funcSelf, ...)
  end
end
function reuse_fall_multi_size:SetOverscrollStateCallback(callback, funcSelf)
  function self.OnOverscrollStateEvent(...)
    return callback(funcSelf, ...)
  end
end
function reuse_fall_multi_size:SetTouchFinishCallback(callback, funcSelf)
  function self.OnTouchFinishEvent(...)
    return callback(funcSelf, ...)
  end
end
function reuse_fall_multi_size:InsertItem(index, itemData)
  if index <= 0 then
    log_error("[UI_LoopScrollBox]reuse_fall_multi_size:InsertItem index <= 0")
    return
  end
  if not self._superListInfo then
    table_insert(self._data, index, itemData)
  end
  if self._selectIndex ~= 0 and index <= self._selectIndex then
    self._selectIndex = self._selectIndex + 1
  end
  self.UIRoot:Reload(#self._data)
end
function reuse_fall_multi_size:AppendItem(itemData, itemSize)
  if not self._superListInfo then
    table_insert(self._data, itemData)
  end
  if itemSize ~= nil then
    self.UIRoot:SetItemSize(#self._data - 1, itemSize)
  end
  self.UIRoot:Reload(#self._data)
end
function reuse_fall_multi_size:SoftAppendItem(itemData, itemSize)
  if not self._superListInfo then
    table_insert(self._data, itemData)
  end
  if itemSize ~= nil then
    self.UIRoot:SetItemSize(#self._data - 1, itemSize)
  end
  self:SoftReload()
end
function reuse_fall_multi_size:SoftReload()
  if self.UIRoot and self.UIRoot.SoftReload then
    self.UIRoot:SoftReload(#self._data)
  end
end
function reuse_fall_multi_size:SoftRefreshAllItems(...)
  if self:HasItemModuleName() and self._itemWidgetIndexMap then
    for widget, uictrl in pairs(self._itemWidgetIndexMap) do
      local index = uictrl.index
      local data = self:GetItemData(index)
      if data then
        uictrl:OnRefresh(data, index, ...)
      end
    end
  end
end
function reuse_fall_multi_size:SetCurItemClass(itemClassKey)
  if itemClassKey then
    self.UIRoot:SetCurItemClass(itemClassKey)
  else
    self.UIRoot:ResetCurItemClassToDefault()
  end
end
function reuse_fall_multi_size:RemoveItem(index)
  if not self._superListInfo then
    if index <= 0 or index > #self._data then
      log_error(string_format("[UI_LoopScrollBox]reuse_fall_multi_size:RemoveItem index[%d] out of range[1..%d]", index, #self._data))
      return
    end
    table_remove(self._data, index)
  end
  if self._selectIndex == index then
    self._selectIndex = 0
  end
  if self._selectIndex ~= 0 and index < self._selectIndex then
    self._selectIndex = self._selectIndex - 1
  end
  self.UIRoot:Reload(#self._data)
end
function reuse_fall_multi_size:RefreshItem(index, itemData)
  if index <= 0 or index > #self._data then
    log_error(string_format("[UI_LoopScrollBox]reuse_fall_multi_size:RefreshItem index[%d] out of range[1..%d]", index, #self._data))
    return
  end
  if itemData and not self._superListInfo then
    self._data[index] = itemData
  end
  self.UIRoot:RefreshOne(index - 1)
end
function reuse_fall_multi_size:ScrollToItem(index, bImmedia)
  if index <= 0 then
    log_error("[UI_LoopScrollBox]reuse_fall_multi_size:ScrollToItem index <= 0")
  end
  self.UIRoot:JumpByIdx(index - 1, bImmedia)
end
function reuse_fall_multi_size:ScrollToStart()
  return self.UIRoot:ScrollToStart()
end
function reuse_fall_multi_size:ScrollToEnd()
  self.UIRoot:ScrollToEnd()
end
function reuse_fall_multi_size:GetContentSize()
  return self.UIRoot:GetContentSize()
end
function reuse_fall_multi_size:GetViewSize()
  return self.UIRoot:GetViewSize()
end
function reuse_fall_multi_size:GetOverscrollState()
  return self.UIRoot:GetOverscrollState()
end
function reuse_fall_multi_size:AutoSize(bAutoSize)
  log_error("reuse_fall_multi_size:AutoSize() deprecated!")
end
function reuse_fall_multi_size:SetItemOffset(offset)
  self.UIRoot:SetScrollOffset(offset)
end
function reuse_fall_multi_size:Select(index)
  if index <= 0 then
    log_error(string_format("reuse_fall_multi_size:Select index[%d] <= 0", index))
    return
  end
  if index > #self._data then
    log_warning(string_format("reuse_fall_multi_size:Select index[%d] out of range[1..%d]", index, #self._data))
  end
  if self._selectIndex ~= index then
    local preSelectIndex = self._selectIndex
    self._selectIndex = index
    if 0 < preSelectIndex then
      self:RefreshItem(preSelectIndex)
    end
    self:RefreshItem(index)
  end
end
function reuse_fall_multi_size:Deselect()
  if self._selectIndex > 0 then
    local preSelectIndex = self._selectIndex
    self._selectIndex = 0
    self:RefreshItem(preSelectIndex)
  end
end
function reuse_fall_multi_size:PlayAnimToTargetReuseFall(target, time, direction, deltaTime, finishFunc)
  local delTime = deltaTime or 0.05
  if time == 0 then
    time = 1
  end
  local startOffset = self:GetItemOffset()
  local loop = math_ceil(time / delTime)
  local deltaSize = (target - startOffset) / loop
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
  self.animTimer = self:AddTimerLoop(0, function()
    if 0 < loop then
      local curTarget = startOffset + deltaSize
      self:SetItemOffset(curTarget)
      startOffset = curTarget
      loop = loop - 1
      local bbreak = false
      if 0 < deltaSize then
        if curTarget >= target then
          bbreak = true
        end
      elseif curTarget <= target then
        bbreak = true
      end
      if bbreak then
        loop = 0
      end
    else
      self:RemoveTimer(self.animTimer)
      self.animTimer = nil
      self:SetItemOffset(target)
      if finishFunc then
        finishFunc()
      end
    end
  end, TIMER_INFINITE, delTime)
end
function reuse_fall_multi_size:SetMaxInertiaSpeed(speed)
  if self.UIRoot.ScrollBoxList and self.UIRoot.ScrollBoxList.SetMaxScrollSpd and speed and tonumber(speed) and tonumber(speed) > 0 then
    self.UIRoot.ScrollBoxList:SetMaxScrollSpd(speed)
  else
    print(bWriteLog and "SetMaxInertiaSpeed: speed must be a number and greater than 0")
  end
end
local class = require("class")
local loop_scroll_box = require("client.slua_ui_framework.component.loop_scroll_box")
local CUILoopScrollBox = class(loop_scroll_box, nil, reuse_fall_multi_size)
return CUILoopScrollBox
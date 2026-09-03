local loop_scroll_box = {}
local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local math_ceil = math.ceil
local table_insert = table.insert
local table_remove = table.remove
local table_pack = table.pack
local table_unpack = table.unpack
local local local local local local local local local local local local common = require("client.slua_ui_framework.common")
function loop_scroll_box:ctor(_, itemModuleName, ...)
  self._  self._args = table_pack(...)
  self._itemWidgetIndexMap = {}
  self._itemWidgetEvents = {}
  self._itemWidgetChildEvents = {}
  self._itemWidgetMultilevelChildEvents = {}
  self._itemDelegateArray = {}
  self._OnRefreshItemCallBack = nil
  self._OnCreateItemCallBack = nil
  self._data = {}
  self._selectIndex = 0
  self._superListInfo = nil
  self._playEnterAnimationTimeGap = 0
  self._playEnterAnimationCallBack = nil
  self._fnAllItemsRefreshedCallback = nil
  self._allItemsRefreshedTimer = nil
end
function loop_scroll_box:RegistEvents()
  loop_scroll_box.__super.RegistEvents(self)
  local bAutoPlayItemAnim = self.UIRoot.bAutoPlayItemAnim
  self:SetNeedPlayAnim(bAutoPlayItemAnim)
  self:AddControlEventByControl(self.UIRoot, "OnRefreshItem", self._OnRefreshItem, self)
  self:AddControlEventByControl(self.UIRoot, "OnItemCreated", self._OnItemCreated, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.OnScreenRatioChanged, self)
end
function loop_scroll_box:OnClose()
  self:UnBindSuperList()
  self:_ClearEvents()
  self:_ClearRedBind()
  local func = self.UIRoot.SetNeedPlayAnim
  if func then
    self.UIRoot:SetNeedPlayAnim(false)
  end
end
function loop_scroll_box:_AddItemEvent(eventsMap, controlName, eventName, handleFunc, ...)
  if self:HasItemModuleName() then
    log_error("loop_scroll_box:_AddItemEvent HasItemModuleName")
    return
  end
  local events = eventsMap[controlName]
  if not events then
    events = {}
    eventsMap[controlName] = events
  end
  local args = table_pack(...)
  events[eventName] = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
end
function loop_scroll_box:AddItemWidgetEvent(controlName, eventName, handleFunc, ...)
  return self:_AddItemEvent(self._itemWidgetEvents, controlName, eventName, handleFunc, ...)
end
function loop_scroll_box:AddItemWidgetChildEvent(controlName, eventName, handleFunc, ...)
  return self:_AddItemEvent(self._itemWidgetChildEvents, controlName, eventName, handleFunc, ...)
end
function loop_scroll_box:AddItemWidgetMultilevelChildEvent(controlName, eventName, handleFunc, ...)
  return self:_AddItemEvent(self._itemWidgetMultilevelChildEvents, controlName, eventName, handleFunc, ...)
end
function loop_scroll_box:SetRefreshItemCallback(callback, ...)
  if self:HasItemModuleName() then
    log_error("loop_scroll_box:SetRefreshItemCallback HasItemModuleName")
    return
  end
  local args = table_pack(...)
  function self._OnRefreshItemCallBack(widget, index)
    return common.CallCombinationArgs(callback, args, widget, index)
  end
end
function loop_scroll_box:SetCreateItemCallback(callback, ...)
  if self:HasItemModuleName() then
    log_error("loop_scroll_box:SetCreateItemCallback HasItemModuleName")
    return
  end
  local args = table_pack(...)
  function self._OnCreateItemCallBack(widget, index)
    return common.CallCombinationArgs(callback, args, widget, index)
  end
end
function loop_scroll_box:_OnRefreshItem(widget, index)
  if self._GMLogDebug then
    log(bWriteLog and string_format("loop_scroll_box:_OnRefreshItem UIRoot:%s index:%d", tostring(self.UIRoot), index))
  end
  if not self._itemWidgetIndexMap[widget] then
    self:_OnItemCreated(widget, index)
  end
  index = index + 1
  if index <= 0 or index > #self._data then
    log_error(string_format("loop_scroll_box:_OnRefreshItem index[%d] out of range[1..%d]", index, #self._data))
    return
  end
  if self:HasItemModuleName() then
    if self._itemWidgetIndexMap[widget] then
      local data = self:GetItemData(index)
      local scroll_box_child_base = self._itemWidgetIndexMap[widget]
      scroll_box_child_base.      scroll_box_child_base.      if self._itemWidgetIndexMap[widget].NeedResetIndex then
        self._itemWidgetIndexMap[widget].      end
      scroll_box_child_base:_RemoveImageDownloadData()
      scroll_box_child_base:_RemoveAllAsyncDiskFile()
      scroll_box_child_base:OnRefresh(data, self._selectIndex)
    end
  else
    self._itemWidgetIndexMap[widget] = index
    if self._OnRefreshItemCallBack then
      self._OnRefreshItemCallBack(widget, index)
    else
      log_error("loop_scroll_box:_OnRefreshItem self._OnRefreshItemCallBack = nil")
    end
  end
  if self._fnAllItemsRefreshedCallback then
    self:_ResetAllItemsRefreshedTimer()
  end
end
function loop_scroll_box:_ItemDelegateBind(widget, eventsMap, func)
  for controlName, events in pairs(eventsMap) do
    local control = func(controlName, widget)
    if control ~= nil then
      for eventName, func in pairs(events) do
        local localIndexFunc = function(...)
          local index = self:_GetIndexByWidget(widget)
          self._itemWidgetIndexMap[widget] = index
          func(widget, index, ...)
        end
        local eventDelegate = control[eventName]
        table_insert(self._itemDelegateArray, eventDelegate)
        if eventDelegate ~= nil then
          if eventDelegate.Add then
            eventDelegate:Add(localIndexFunc)
          else
            eventDelegate:Bind(localIndexFunc)
          end
        else
          log_warning(string_format("loop_scroll_box:_OnItemCreated eventDelegate is nil! controlName\239\188\154[%s] EventName: [%s]", controlName, eventName))
        end
      end
    else
      log_warning(string_format("loop_scroll_box:_OnItemCreated control is nil! controlName\239\188\154[%s] ,widget:[%s]", controlName, tostring(widget)))
    end
  end
end
function loop_scroll_box:_OnItemCreated(widget, widgetIndex)
  if self._GMLogDebug then
    log(bWriteLog and string_format("loop_scroll_box:_OnItemCreated UIRoot:%s widgetIndex:%d", tostring(self.UIRoot), widgetIndex))
  end
  widgetIndex = widgetIndex + 1
  if self:HasItemModuleName() then
    local childBase = require(self:GetItemModuleName())
    local baseUI = childBase(table_unpack(self._args))
    baseUI:InitWithParentWidget(self, widget)
    self._itemWidgetIndexMap[widget] = baseUI
  else
    self._itemWidgetIndexMap[widget] = widgetIndex
    if self._OnCreateItemCallBack then
      self._OnCreateItemCallBack(widget, widgetIndex)
    end
  end
  if not self:HasItemModuleName() then
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
  if self._playEnterAnimationTimeGap > 0 then
    if self._playEnterAnimationCallBack then
      self:AddTimerOnce(self._playEnterAnimationTimeGap * (widgetIndex - 1), function()
        self._playEnterAnimationCallBack(widget, widgetIndex)
      end)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self:AddTimerOnce(self._playEnterAnimationTimeGap * (widgetIndex - 1), function()
        if widget then
          widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end)
    end
  end
end
function loop_scroll_box:_ClearEvents()
  if self:HasItemModuleName() then
    return
  end
  if not self._itemDelegateArray then
    return
  end
  for _, eventDelegate in pairs(self._itemDelegateArray) do
    if eventDelegate.Clear then
      eventDelegate:Clear()
    end
  end
end
function loop_scroll_box:_ClearRedBind()
  if self:HasItemModuleName() then
    return
  end
  if not self._itemWidgetIndexMap then
    return
  end
  for widget, _ in pairs(self._itemWidgetIndexMap) do
    if slua.isValid(widget) and widget.Reddot_Anchor then
      widget.Reddot_Anchor:UnBind()
    end
  end
end
function loop_scroll_box:SetAllItemsRefreshedCallback(fnCallback)
  self:_CancelAllItemsRefreshedTimer()
  self._fnAllItemsRefreshedCallback = fnCallback
  if fnCallback and self._data and #self._data > 0 then
    self:_StartWaitLayoutTimer()
  end
end
function loop_scroll_box:_ResetAllItemsRefreshedTimer()
  self:_CancelAllItemsRefreshedTimer()
  self:_StartWaitLayoutTimer()
end
local WAIT_LAYOUT_TIME = 0.35
function loop_scroll_box:_StartWaitLayoutTimer()
  self:_CancelAllItemsRefreshedTimer()
  self._allItemsRefreshedTimer = self:AddTimerOnce(WAIT_LAYOUT_TIME, function()
    self._allItemsRefreshedTimer = nil
    if self._fnAllItemsRefreshedCallback then
      local fnCallback = self._fnAllItemsRefreshedCallback
      self._fnAllItemsRefreshedCallback = nil
      fnCallback()
    end
  end)
end
function loop_scroll_box:_CancelAllItemsRefreshedTimer()
  if self._allItemsRefreshedTimer then
    self:RemoveTimer(self._allItemsRefreshedTimer)
    self._allItemsRefreshedTimer = nil
  end
end
function loop_scroll_box:_GetIndexByWidget(widget)
  local index = self.UIRoot:GetWidgetIndex(widget)
  if index < 0 then
    log_warning("loop_scroll_box:_GetIndexByWidget index >= 0")
    return nil
  end
  return index + 1
end
function loop_scroll_box:GetIndexOfWidget(index)
  if index <= 0 or index > self:GetItemCount() then
    log_warning(string_format("loop_scroll_box:GetIndexOfWidget index > 0 and index <= self:GetItemCount(), index:[%s]", tostring(index)))
  end
  return self.UIRoot:GetIndexOfWidget(index - 1)
end
function loop_scroll_box:GetIndexOfItem(index)
  if index <= 0 or index > self:GetItemCount() then
    log_warning(string_format("loop_scroll_box:GetIndexOfItem index > 0 and index <= self:GetItemCount(), index:[%s]", tostring(index)))
  end
  local widget = self:GetIndexOfWidget(index)
  if widget and self._itemWidgetIndexMap then
    return self._itemWidgetIndexMap[widget]
  end
end
function loop_scroll_box:SetData(arrayData)
  self._data = arrayData or {}
  self._selectIndex = 0
  self:_CancelAllItemsRefreshedTimer()
  self:SetItemCount(#self._data)
end
function loop_scroll_box:SetNeedPlayAnim(playAnim)
  local DisableUIItemAnim = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableUIItemAnim", false)
  if DisableUIItemAnim then
    log_warning(bWriteLog and "  loop_scroll_box:SetNeedPlayAnim. :DisableUIItemAnim " .. tostring(DisableUIItemAnim))
    return
  end
  local func = self.UIRoot.SetNeedPlayAnim
  if func then
    self.UIRoot:SetNeedPlayAnim(playAnim or false)
  end
end
function loop_scroll_box:SetDataWithoutSelect(arrayData)
  self._data = arrayData or {}
  self:SetItemCount(#self._data)
end
function loop_scroll_box:GetSetData()
  return self._data
end
function loop_scroll_box:_OnDataModified(operator, ...)
  local super_list = require("common.super_list")
  local Operation = super_list.Operation
  if operator == Operation.RefreshAll then
    self:SetData(...)
  elseif operator == Operation.RefreshItem then
    self:RefreshItem(...)
  elseif operator == Operation.InsertItem then
    self:InsertItem(...)
  elseif operator == Operation.RemoveItem then
    self:RemoveItem(...)
  elseif operator == Operation.ChangeData then
    self:ChangeData(...)
  end
end
function loop_scroll_box:BindSuperList(superList)
  self:UnBindSuperList()
  local callback = function(...)
    self:_OnDataModified(...)
  end
  self._superListInfo = {callback = callback, superList = superList}
  superList:AddListener(callback)
end
function loop_scroll_box:UnBindSuperList()
  local superListInfo = self._superListInfo
  if superListInfo then
    superListInfo.superList:RemoveListener(superListInfo.callback)
    self._superListInfo = nil
  end
  self._selectIndex = 0
  self:SetItemCount(0)
end
function loop_scroll_box:GetBindingSuperList()
  return self._superListInfo and self._superListInfo.superList
end
function loop_scroll_box:SetItemCount(num)
  if not self.UIRoot then
    return
  end
  self.UIRoot:SetItemCount(num)
end
function loop_scroll_box:GetItemCount()
  return #self._data
end
function loop_scroll_box:GetItemData(index)
  if index == nil then
    log_warning(string_format("loop_scroll_box:GetItemData index is nil"))
    return nil
  end
  if index <= 0 or index > #self._data then
    log_warning(string_format("loop_scroll_box:GetItemData index[%d] out of range[1..%d]", index, #self._data))
    return nil
  end
  return self._data[index]
end
function loop_scroll_box:AppendItem(itemData)
  if not self._superListInfo then
    self._data[#self._data + 1] = itemData
  end
  local index = #self._data
  self.UIRoot:InsertItem(index - 1)
end
function loop_scroll_box:InsertItem(index, itemData)
  if index <= 0 then
    log_warning("loop_scroll_box:InsertItem index > 0")
    return
  end
  if not self._superListInfo then
    table_insert(self._data, index, itemData)
  end
  if self._selectIndex ~= 0 and index <= self._selectIndex then
    self._selectIndex = self._selectIndex + 1
  end
  self.UIRoot:InsertItem(index - 1)
end
function loop_scroll_box:RemoveItem(index)
  if index <= 0 then
    log_error(string_format("loop_scroll_box:RemoveItem  index[%d] <= 0", index))
    return
  end
  if index > #self._data then
    log_warning(string_format("loop_scroll_box:RemoveItem index[%d] out of range[1..%d]", index, #self._data))
  end
  if not self._superListInfo then
    table_remove(self._data, index)
  end
  if self._selectIndex == index then
    self._selectIndex = 0
  end
  if self._selectIndex ~= 0 and index < self._selectIndex then
    self._selectIndex = self._selectIndex - 1
  end
  self.UIRoot:RemoveItem(index - 1)
end
function loop_scroll_box:RefreshItem(index, itemData)
  if index <= 0 then
    log_error(string_format("loop_scroll_box:RefreshItem  index[%d] <= 0", index))
    return
  end
  if index > #self._data then
    log_warning(string_format("loop_scroll_box:RefreshItem index[%d] out of range[1..%d]", index, #self._data))
  end
  if itemData and not self._superListInfo then
    self._data[index] = itemData
  end
  self.UIRoot:RefreshItem(index - 1)
end
function loop_scroll_box:ChangeData(index, itemData, key)
  if index <= 0 then
    log_warning(string_format("loop_scroll_box:ChangeData index[%d] <= 0", index))
    return
  end
  if index > #self._data then
    log_warning(string_format("loop_scroll_box:ChangeData index[%d] out of range[1..%d]", index, #self._data))
  end
  if itemData and not self._superListInfo then
    self._data[index] = itemData
  end
  self.UIRoot:ChangeData(index - 1, key)
end
function loop_scroll_box:RefreshAllItems(newData)
  if newData ~= nil and self._superListInfo ~= nil then
    log_warning("loop_scroll_box:RefreshAllItems Can't use RefreshAllItems with super list!")
    return
  end
  if newData then
    self._data = newData
  end
  if self.UIRoot then
    self.UIRoot:SetItemCount(#self._data)
  end
end
function loop_scroll_box:OnResizeLoop()
  if self.SetSubData then
    return
  end
  if not self.UIRoot then
    return
  end
  if not self.UIRoot.SetItemCount then
    return
  end
  self.UIRoot:SetItemCount(0)
  self:AddTimerOnce(0, function()
    self:RefreshAllItems()
  end)
end
function loop_scroll_box:SetItemTypeByPath(classPath)
  if self._data and #self._data ~= 0 then
    log_error("loop_scroll_box:SetItemTypeByPath Must call before SetData!")
  end
  local itemType = import(classPath)
  self.UIRoot:SetItemType(itemType)
end
function loop_scroll_box:SetItemSize(x, y)
  if self._data and #self._data ~= 0 then
    log_error("loop_scroll_box:SetItemSize Must call before SetData!")
  end
  if type(self.UIRoot.ItemSize) == "number" then
    self.UIRoot.ItemSize = x
  else
    self.UIRoot.ItemSize = FVector2D(x, y)
  end
end
function loop_scroll_box:SetPadding(x, y)
  if self._data and #self._data ~= 0 then
    log_error("loop_scroll_box:SetPadding Must call before SetData!")
  end
  if type(self.UIRoot.ItemSize) == "number" then
    self.UIRoot.Padding = x
  else
    self.UIRoot.Padding = FVector2D(x, y)
  end
end
function loop_scroll_box:SetHorizontalPadding(x, y)
  if self._data and #self._data ~= 0 then
    log_error("loop_scroll_box:SetHorizontalPadding Must call before SetData!")
  end
  if slua.isValid(self.UIRoot.HorizontalPadding) then
    self.UIRoot.HorizontalPadding = FVector2D(x, y)
  end
end
function loop_scroll_box:Select(index)
  if not index or index <= 0 then
    log_error(string_format("loop_scroll_box:Select index[%s] <= 0", tostring(index)))
    return
  end
  if index > #self._data then
    log_warning(string_format("loop_scroll_box:Select index[%d] out of range[1..%d]", index, #self._data))
  end
  if self._selectIndex ~= index then
    local preSelectIndex = self._selectIndex
    self._selectIndex = index
    if 0 < preSelectIndex then
      self.UIRoot:RefreshItem(preSelectIndex - 1)
    end
    self.UIRoot:RefreshItem(index - 1)
  end
end
function loop_scroll_box:Deselect()
  if self._selectIndex > 0 then
    local preSelectIndex = self._selectIndex
    self._selectIndex = 0
    self.UIRoot:RefreshItem(preSelectIndex - 1)
  end
end
function loop_scroll_box:AutoSize(bAutoSize)
  local old = self.UIRoot.RenderTransform.Translation
  local bigOffsetx = -1000000
  self.UIRoot:SetRenderTranslation(FVector2D(bigOffsetx, 0))
  self:AddTimerOnce(0, function()
    self.UIRoot:AutoSize(bAutoSize)
    self:SetAutoSize(bAutoSize)
    self.UIRoot:SetRenderTranslation(old)
  end)
end
function loop_scroll_box:GetSelectIndex()
  return self._selectIndex
end
function loop_scroll_box:HasItemModuleName()
  return self._itemModuleName
end
function loop_scroll_box:GetItemModuleName()
  return self._itemModuleName
end
function loop_scroll_box:ScrollToItem(index)
  if index <= 0 then
    log_error(string_format("loop_scroll_box:ScrollToItem index[%d] <= 0", index))
    return
  end
  if index > #self._data then
    log_warning(string_format("loop_scroll_box:ScrollToItem index[%d] out of range[1..%d]", index, #self._data))
  end
  if self.UIRoot then
    self.UIRoot:ScrollToItem(index - 1)
  end
end
function loop_scroll_box:SetEnterAnimationGap(gap)
  self._playEnterAnimationTimeGap = gap
end
function loop_scroll_box:SetEnterAnimationCallback(callback, ...)
  local args = table_pack(...)
  local common = require("client.slua_ui_framework.common")
  function self._playEnterAnimationCallBack(widget, widgetIndex)
    return common.CallCombinationArgs(callback, args, widget, widgetIndex)
  end
end
function loop_scroll_box:GetItemOffset()
  return self.UIRoot:GetScrollOffset()
end
function loop_scroll_box:SetItemOffset(offset)
  self.UIRoot:SetScrollOffset(offset)
  self.UIRoot:UserScrolled(offset)
end
function loop_scroll_box:GetBeginItemIndex()
  local offset = self:GetItemOffset()
  local UIRoot = self.UIRoot
  local ScrollOffset = offset - UIRoot.NavigationScrollPadding
  if ScrollOffset < 0 then
    ScrollOffset = 0
  end
  local Index = 0
  if ScrollOffset >= UIRoot.ItemSize then
    ScrollOffset = ScrollOffset - UIRoot.ItemSize
    Index = math.floor(ScrollOffset / (UIRoot.ItemSize + UIRoot.Padding) + 0.5) + 1
  end
  local ItemCount = UIRoot:GetItemCount()
  Index = math.min(Index, ItemCount - 1)
  return Index + 1
end
function loop_scroll_box:ScrollToCenter(index)
  local slateBlueprintLibrary = import("SlateBlueprintLibrary")
  local root = self.UIRoot
  local Geometry = root:GetCachedGeometry()
  local Size = slateBlueprintLibrary.GetLocalSize(Geometry)
  log(bWriteLog and "  : Size.Y: " .. tostring(Size.Y))
  log(bWriteLog and "  : self.UIRoot.ItemSize: " .. tostring(root.ItemSize))
  local half = 0
  local axis = self.UIRoot.Orientation
  if axis and axis == UEnums.EOrientation.Orient_Horizontal then
    half = Size.X * 0.5
  else
    half = Size.Y * 0.5
  end
  local count = math.floor(half / (root.ItemSize + root.Padding))
  log(bWriteLog and "  : count: " .. tostring(count))
  local result = index - count
  if result < 1 then
    result = 1
  end
  log(bWriteLog and "  : result: " .. tostring(result))
  self:ScrollToItem(result)
end
function loop_scroll_box:GetViewSize()
  local UIRoot = self.UIRoot
  if not UIRoot then
    return 0
  end
  return UIRoot:GetViewSize()
end
function loop_scroll_box:PlayAnimToTarget(target, time, direction, deltaTime, finishFunc)
  local delTime = deltaTime or 0.05
  local size = 1
  if type(self.UIRoot.ItemSize) == "number" then
    size = self.UIRoot.ItemSize
  elseif direction == 1 then
    size = self.UIRoot.ItemSize.X
  else
    size = self.UIRoot.ItemSize.Y
  end
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
      local endOffset = self.UIRoot:GetScrollEndOffset()
      if curTarget >= endOffset then
        curTarget = endOffset
      end
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
function loop_scroll_box:ClearAnimationPlayTimer()
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
end
function loop_scroll_box:IsAnmationPlaying()
  return self.animTimer ~= nil
end
function loop_scroll_box:OnScreenRatioChanged()
  if not slua.isValid(self.UIRoot) then
    return
  end
  self:OnResizeLoop()
end
function loop_scroll_box:RearrangeItems()
  if self.UIRoot.RearrangeItems then
    self.UIRoot:RearrangeItems()
  end
end
function loop_scroll_box:SetMaxInertiaSpeed(speed)
  if self.UIRoot.SetMaxScrollSpd and speed and tonumber(speed) and tonumber(speed) > 0 then
    self.UIRoot:SetMaxScrollSpd(speed)
  else
    print(bWriteLog and "SetMaxInertiaSpeed: speed must be a number and greater than 0")
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUILoopScrollBox = class(ui_base, nil, loop_scroll_box)
return CUILoopScrollBox
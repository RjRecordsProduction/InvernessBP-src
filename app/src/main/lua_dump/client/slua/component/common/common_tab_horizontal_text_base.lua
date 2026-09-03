local common_tab_horizontal_text_base = {}
local C_TabMinWidth = 200
local C_TabMaxWidth = 256
local C_TabHeight = 40
function common_tab_horizontal_text_base:ctor(_, config)
  self.onSelectTabEvent = nil
  self.tabSelectedHandleFunc = nil
  self.tabRefreshHandleFunc = nil
  self.itemClickCDCfg = nil
  self.selectedTab = 0
  self.lastSelectedWidget = nil
  self.childItemList = nil
  self.itemFixedWidth = nil
  self.itemFixedHeight = nil
  self.aniItemToCenter = nil
  self.bInGame = false
  self.selectColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  self.unselectColor = FSlateColor(FLinearColor(0, 0, 0, 0.7))
  self:LoadConfig(config)
end
function common_tab_horizontal_text_base:LoadConfig(config)
  if config then
    for k, v in pairs(config) do
      self[k] = v
    end
  end
end
function common_tab_horizontal_text_base:_SetStyle(Style)
  if Style then
    self.selectColor = FSlateColor(Style.SelectedColor)
    self.unselectColor = FSlateColor(Style.UnselectedColor)
    self.lineColor = Style.DividerColor
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    self.tabImage = UKismetSystemLibrary.BreakSoftObjectPath(Style.SelectBGImage, "")
  end
end
function common_tab_horizontal_text_base:OnInitialize()
  common_tab_horizontal_text_base.__super.OnInitialize(self)
  self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
  if self.UIRoot.ScrollBox_Mount and self.UIRoot.ScrollBox_Mount.SetScrollOffset then
    self.UIRoot.ScrollBox_Mount:SetScrollOffset(0)
  end
end
function common_tab_horizontal_text_base:SetTabs(tabs, index)
  if not tabs or not next(tabs) then
    return
  end
  if not self.UIRoot then
    return
  end
  self.lastSelectedWidget = nil
  if self.childItemList then
    for k, v in ipairs(self.childItemList) do
      v:Close()
    end
  end
  self.childItemList = {}
  local UIUtil = require("client.common.ui_util")
  self.tabData = tabs
  local initialIndex = index or 1
  for k, v in ipairs(tabs) do
    local item = self:CreateChildWindow("ScrollBox_Mount", self:_GetTextItemConfig(), self, k)
    local itemUIRoot = item.UIRoot
    table.insert(self.childItemList, item)
    local isSelected = k == initialIndex
    if isSelected then
      self.lastSelectedWidget = itemUIRoot
    end
    self:_UpdateTabItem(itemUIRoot, k, isSelected)
  end
  self:Select(initialIndex, false)
  if self.aniItemToCenter then
    self:AddTimerOnce(0.05, function()
      self.UIRoot.ScrollBox_Mount:SetScrollOffset(self.UIRoot.ScrollBox_Mount:GetScrollEndOffset())
      self.bNeedSetOffset = true
      self:_MoveSelectItemToCenter(self.selectedTab)
    end)
  end
end
function common_tab_horizontal_text_base:_UpdateTabItem(itemUIRoot, index, isSelected)
  self:SetWidgetVisible(itemUIRoot.Button_Tab, true, true)
  self:SetWidgetVisible(itemUIRoot.Image_BG, true)
  if itemUIRoot.Image_CustomSelectBG then
    self:SetWidgetVisible(itemUIRoot.Image_CustomSelectBG, false)
  end
  if itemUIRoot.Image_CustomUnSelectBG then
    self:SetWidgetVisible(itemUIRoot.Image_CustomUnSelectBG, false)
  end
  if itemUIRoot.TextBlock_Select then
    itemUIRoot.TextBlock_Select:SetColorAndOpacity(self.selectColor)
  end
  if itemUIRoot.TextBlock_Unselect then
    itemUIRoot.TextBlock_Unselect:SetColorAndOpacity(self.unselectColor)
  end
  if itemUIRoot.Image_Line_LastCollapsed and self.lineColor then
    itemUIRoot.Image_Line_LastCollapsed:SetColorAndOpacity(self.lineColor)
  end
  if self.tabImage and itemUIRoot.Image_BG then
    itemUIRoot.Image_BG:SetBrushFromPathAsync(self.tabImage, false)
  end
  if isSelected then
    itemUIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  else
    itemUIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  local TabHeight = self:GetTabHeight()
  local UIUtil = require("client.common.ui_util")
  if self.itemFixedWidth then
    UIUtil.SetSize(itemUIRoot.Button_Tab, self.itemFixedWidth, TabHeight)
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  elseif self.bEqualWidth then
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
    self:AddTimerOnce(0, function()
      local totalWidth = UIUtil.GetLocalSize(self.UIRoot).X
      local count = self.tabData and #self.tabData > 0 and #self.tabData or 1
      local equalWidth = totalWidth / count
      UIUtil.SetSize(itemUIRoot.Button_Tab, equalWidth, TabHeight)
      self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    end)
  else
    self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 0))
    self:AddTimerOnce(0, function()
      local textSize
      if isSelected then
        textSize = UIUtil.GetLocalSize(itemUIRoot.TextBlock_Select)
      else
        textSize = UIUtil.GetLocalSize(itemUIRoot.TextBlock_Unselect)
      end
      local TabMinWidth = self:GetTabMinWidth()
      local TabMaxWidth = self:GetTabMaxWidth()
      if TabMinWidth > textSize.X then
        UIUtil.SetSize(itemUIRoot.Button_Tab, TabMinWidth, TabHeight)
      elseif TabMaxWidth < textSize.X then
        UIUtil.SetSize(itemUIRoot.Button_Tab, TabMaxWidth, TabHeight)
      else
        UIUtil.SetSize(itemUIRoot.Button_Tab, textSize.X, TabHeight)
      end
      self.UIRoot:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    end)
  end
end
function common_tab_horizontal_text_base:GetTabMinWidth()
  return self.UIRoot.TabMinWidth or C_TabMinWidth
end
function common_tab_horizontal_text_base:GetTabMaxWidth()
  return self.UIRoot.TabMaxWidth or C_TabMaxWidth
end
function common_tab_horizontal_text_base:GetTabHeight()
  return self.itemFixedHeight or self.UIRoot.TabHeight or C_TabHeight
end
function common_tab_horizontal_text_base:SetItemClickCDCfg(config)
  self.itemClickCDCfg = config
end
function common_tab_horizontal_text_base:GetSelectedIndex()
  return self.selectedTab
end
function common_tab_horizontal_text_base:Select(index, bIsFromClick)
  if self.lastSelectedWidget and slua.isValid(self.lastSelectedWidget) then
    self.lastSelectedWidget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  if not self.childItemList then
    log_warning("common_tab_horizontal_text_base:Select self.childItemList destroyed")
    return
  end
  local selectIndex = index or 1
  if not self.childItemList[selectIndex] then
    log_warning("common_tab_horizontal_text_base:Select invalid index")
    return
  end
  local widget = self.childItemList[selectIndex].UIRoot
  widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  self.lastSelectedWidget = widget
  local lastIndex = self.selectedTab
  self.selectedTab = selectIndex
  if self.tabSelectedHandleFunc then
    self.tabSelectedHandleFunc(lastIndex, selectIndex, bIsFromClick or false)
  end
end
function common_tab_horizontal_text_base:AddOnClickedCallback(callback, funcSelf)
  if not callback then
    return
  end
  function self.onSelectTabEvent(widget, index)
    if self.aniItemToCenter then
      self:_MoveSelectItemToCenter(index)
    end
    return callback(funcSelf, widget, index)
  end
end
function common_tab_horizontal_text_base:AddOnTabRefreshCallback(callback, funcSelf)
  if not callback then
    self.tabRefreshHandleFunc = nil
    return
  end
  function self.tabRefreshHandleFunc(widget, index)
    return callback(funcSelf, widget, index)
  end
end
function common_tab_horizontal_text_base:AddOnSelectedCallback(callback, funcSelf)
  if not callback then
    return
  end
  function self.tabSelectedHandleFunc(lastIndex, index, bIsFromClick)
    return callback(funcSelf, lastIndex, index, bIsFromClick)
  end
end
function common_tab_horizontal_text_base:SetSelectItemAniCenter(bAniToCenter, moveToCenterAniTime)
  self.aniItemToCenter = bAniToCenter
  local Common_Tab_Config = require("client.slua.component.common.config.Common_Tab_Config")
  self.moveToCenterAniTime = moveToCenterAniTime or Common_Tab_Config.Horizontal_MoveAniTime
end
function common_tab_horizontal_text_base:GetItemReddotAnchor(index)
  if not self.tabData or index > #self.tabData then
    log(bWriteLog and "common_tab_horizontal_text_base:GetItemReddotAnchor invalid index")
    return nil
  end
  if self.childItemList and self.childItemList[index] and self.childItemList[index].UIRoot then
    local widget = self.childItemList[index].UIRoot
    return widget.Reddot_Anchor, widget
  end
  return nil
end
function common_tab_horizontal_text_base:GetItemReddotAnchorComponent(index)
  if not self.tabData or index > #self.tabData then
    log(bWriteLog and "common_tab_horizontal_text_base:GetItemReddotAnchorComponent invalid index")
    return nil
  end
  local widget = self.childItemList[index].UIRoot
  return widget.Reddot_Anchor_Component, widget
end
function common_tab_horizontal_text_base:SetChildShow(index, bShow)
  index = index or 1
  if index > #self.tabData or index <= 0 then
    log(bWriteLog and "common_tab_horizontal_text_base:SetChildShow invalid index")
    return
  end
  local widget = self.childItemList[index].UIRoot
  if widget then
    if bShow then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self:_RefreshLastLine()
  end
end
function common_tab_horizontal_text_base:SetChildLock(index, bLock, bCantClick)
  index = index or 1
  if index > #self.tabData or index <= 0 then
    log(bWriteLog and "common_tab_horizontal_text_base:SetChildLock invalid index")
    return
  end
  local widget = self.childItemList[index].UIRoot
  if widget and widget.Image_Lock then
    if bLock then
      widget.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if bCantClick then
      self:SetWidgetVisible(widget.Button_Tab, true)
    end
  end
end
function common_tab_horizontal_text_base:SetTabFixedWidth(width)
  if width and type(width) == "number" then
    self.itemFixedWidth = width
  end
end
function common_tab_horizontal_text_base:SetTabFixedHeight(height)
  if height and type(height) == "number" then
    self.itemFixedHeight = height
  end
end
function common_tab_horizontal_text_base:SetInGameStyle(bool)
  self.bInGame = bool
end
function common_tab_horizontal_text_base:SetEqualWidth(bEqual)
  self.bEqualWidth = bEqual
end
function common_tab_horizontal_text_base:SetTextColor(selectColor, unselectColor)
  if selectColor then
    self.  end
  if unselectColor then
    self.  end
  if self.childItemList then
    for _, item in ipairs(self.childItemList) do
      if item.UIRoot then
        if item.UIRoot.TextBlock_Select then
          item.UIRoot.TextBlock_Select:SetColorAndOpacity(self.selectColor)
        end
        if item.UIRoot.TextBlock_Unselect then
          item.UIRoot.TextBlock_Unselect:SetColorAndOpacity(self.unselectColor)
        end
      end
    end
  end
end
function common_tab_horizontal_text_base:SetTabText(index, text)
  if not index or not text then
    log(bWriteLog and "common_tab_horizontal_text_base:SetTabText invalid params")
    return
  end
  if not self.tabData or index < 1 or index > #self.tabData then
    log(bWriteLog and "common_tab_horizontal_text_base:SetTabText invalid index")
    return
  end
  self.tabData[index] = text
  if self.childItemList and self.childItemList[index] then
    local itemWidget = self.childItemList[index].UIRoot
    if itemWidget.TextBlock_Select then
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetVietnamAutoCapitalizeText(itemWidget.TextBlock_Select)
      itemWidget.TextBlock_Select:SetText(text)
    end
    if itemWidget.TextBlock_Unselect then
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetVietnamAutoCapitalizeText(itemWidget.TextBlock_Unselect)
      itemWidget.TextBlock_Unselect:SetText(text)
    end
  end
end
function common_tab_horizontal_text_base:_GetTextItemConfig()
end
function common_tab_horizontal_text_base:_RefreshLastLine()
  local isLastVisibleItem = true
  if self.tabData then
    for index = #self.tabData, 1, -1 do
      local widget = self.childItemList[index].UIRoot
      if widget then
        local currentVisibility = widget:GetVisibility()
        if currentVisibility ~= UEnums.ESlateVisibility.Collapsed then
          if isLastVisibleItem then
            widget.Image_Line_LastCollapsed:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            isLastVisibleItem = false
          else
            widget.Image_Line_LastCollapsed:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  end
end
function common_tab_horizontal_text_base:_MoveSelectItemToCenter(index)
  local UIUtil = require("client.common.ui_util")
  local tabRoot = self.UIRoot.ScrollBox_Mount
  local targetOffset = 0
  local childSize = 0
  local calcItemSize = 0
  local calcIndex = math.min(index, #self.childItemList)
  for i = 1, calcIndex do
    local item = self.childItemList[i]
    local itemSize = UIUtil.GetLocalSize(item.UIRoot.Button_Tab)
    calcItemSize = 0 < itemSize.X and itemSize.X or calcItemSize
    if index == i then
      targetOffset = childSize + calcItemSize / 2
    end
    childSize = childSize + calcItemSize
  end
  local boxViewX = UIUtil.GetLocalSize(tabRoot).X
  targetOffset = targetOffset - boxViewX / 2
  local maxOffset = tabRoot:GetScrollEndOffset()
  if targetOffset < 0 then
    targetOffset = 0
  elseif maxOffset < targetOffset then
    targetOffset = maxOffset
  end
  log(bWriteLog and "common_tab_horizontal_text_base :_MoveToCenter index = " .. tostring(index) .. " targetOffset = " .. tostring(targetOffset) .. "  boxViewX = " .. tostring(boxViewX))
  if self.bNeedSetOffset then
    tabRoot:SetScrollOffset(targetOffset)
  else
    local Common_Tab_Config = require("client.slua.component.common.config.Common_Tab_Config")
    self:PlayAnimToTarget(targetOffset, Common_Tab_Config.Horizontal_MoveAniTime)
  end
  self.bNeedSetOffset = false
end
function common_tab_horizontal_text_base:PlayAnimToTarget(target, time, deltaTime, finishFunc)
  local delTime = deltaTime or 0.05
  if time == 0 then
    time = 1
  end
  local boxRoot = self.UIRoot.ScrollBox_Mount
  local startOffset = boxRoot:GetScrollOffset()
  local math_ceil = math.ceil
  local loop = math_ceil(time / delTime)
  local deltaSize = (target - startOffset) / loop
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
  self.animTimer = self:AddTimerLoop(0, function()
    if 0 < loop then
      local curTarget = startOffset + deltaSize
      local endOffset = boxRoot:GetScrollEndOffset()
      if curTarget >= endOffset then
        curTarget = endOffset
      end
      boxRoot:SetScrollOffset(curTarget)
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
      boxRoot:SetScrollOffset(target)
      if finishFunc then
        finishFunc()
      end
    end
  end, TIMER_INFINITE, delTime)
end
function common_tab_horizontal_text_base:OnClose(...)
  self.lastSelectedWidget = nil
  if self.childItemList then
    for k, v in ipairs(self.childItemList) do
      v:Close()
    end
  end
  self.childItemList = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Tab_Horizontal_Text_Base = class(ui_base, nil, common_tab_horizontal_text_base)
return CCommon_Tab_Horizontal_Text_Base
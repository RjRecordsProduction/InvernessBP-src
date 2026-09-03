local common_popup_box_with_tab = {}
local TableUtil = require("common.table_util")
function common_popup_box_with_tab:OnInitialize()
  common_popup_box_with_tab.__super.OnInitialize(self)
  self.locklist = {}
  self.LoopScrollBox_Tab = self:InitScrollBox(self.UIRoot.LoopScrollBox_Tab)
  if self.UIRoot.LoopScrollBox_Jump then
    self.LoopScrollBox_Jump = self:InitScrollBox(self.UIRoot.LoopScrollBox_Jump)
  end
end
function common_popup_box_with_tab:RegistEvents()
  common_popup_box_with_tab.__super.RegistEvents(self)
  self.LoopScrollBox_Tab:SetRefreshItemCallback(self._OnRefreshItem, self)
  self.LoopScrollBox_Tab:AddItemWidgetChildEvent("Button_Tab", "OnClicked", self._OnClickItem, self)
  if self.LoopScrollBox_Jump then
    self.LoopScrollBox_Jump:SetRefreshItemCallback(self._OnRefreshJumpItem, self)
    self.LoopScrollBox_Jump:AddItemWidgetChildEvent("Button_Jump", "OnClicked", self._OnClickJumpItem, self)
  end
end
function common_popup_box_with_tab:SetData(mainUI, titleText, extraData)
  self:_InitUI(mainUI, titleText, extraData)
end
function common_popup_box_with_tab:SetTabsData(tabsData, initSelect)
  if not assert(tabsData ~= nil and type(tabsData) == "table", "common_popup_box_with_tab:SetTabsData tabsData illegal") then
    return
  end
  if not (self.UIRoot and self.UIRoot.Border_Tabs) or not self.LoopScrollBox_Tab then
    log_error("common_popup_box_with_tab:SetTabsData UIRoot or widgets not ready")
    return
  end
  self:SetWidgetVisible(self.UIRoot.Border_Tabs, true)
  self.LoopScrollBox_Tab:SetData(tabsData)
  self.LoopScrollBox_Tab:Select(initSelect or 1)
end
function common_popup_box_with_tab:UpdateTabData(tabIndex, tabData)
  local itemData = self.LoopScrollBox_Tab:GetItemData(tabIndex)
  if not itemData then
    return
  end
  self:_MergeData(itemData, tabData)
  self.LoopScrollBox_Tab:RefreshItem(tabIndex, itemData)
end
function common_popup_box_with_tab:GetTabData(tabIndex)
  local itemData = self.LoopScrollBox_Tab:GetItemData(tabIndex)
  if not itemData then
    return
  end
  return itemData
end
function common_popup_box_with_tab:AddSelectTabEvent(callback, funcSelf)
  if not callback then
    return
  end
  function self.onSelectTabEvent(widget, index)
    return callback(funcSelf, widget, index)
  end
end
function common_popup_box_with_tab:AddCanClickNowEvent(callback, funcSelf)
  if not callback then
    return
  end
  function self.CanClickNowEvent(widget, index)
    return callback(funcSelf, widget, index)
  end
end
function common_popup_box_with_tab:SetJumpTabs(jumps)
  self.jumpData = jumps
  if self.LoopScrollBox_Jump then
    self.LoopScrollBox_Jump:SetData(self.jumpData)
  end
end
function common_popup_box_with_tab:AddOnJumpTabRefreshCallback(func, funcSelf)
  function self.jumpTabRefreshHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function common_popup_box_with_tab:AddOnJumpTabClickedCallback(func, funcSelf)
  function self.jumpClickedHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function common_popup_box_with_tab:ClosePopup()
  self:_PlayFadeOut()
end
function common_popup_box_with_tab:_OnRefreshItem(widget, index)
  local itemData = self.LoopScrollBox_Tab:GetItemData(index)
  if not itemData then
    return
  end
  widget.TabName1:SetText(itemData.txt or itemData.tab)
  widget.TabName2:SetText(itemData.txt or itemData.tab)
  if index == self.LoopScrollBox_Tab:GetSelectIndex() then
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  else
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  end
  self:SetWidgetVisible(widget.SizeBox_Lock, 0 <= TableUtil.Find(self.locklist, index))
  widget.Reddot_Anchor:UnBind()
  if itemData.reddotSuperData then
    widget.Reddot_Anchor:Bind(itemData.reddotSuperData)
  end
  self:SetWidgetVisible(widget.Image_Reddot, itemData.showImageReddot)
  self:SetWidgetVisible(widget.ScaleBox_New, itemData.showNew)
  if slua.isValid(widget.Reddot_Anchor_Item02) then
    self:SetWidgetVisible(widget.Reddot_Anchor_Item02, false)
    if itemData.reddotCount and 0 < itemData.reddotCount then
      self:SetWidgetVisible(widget.Reddot_Anchor_Item02, true)
      widget.Reddot_Anchor_Item02.TextBlock_Num:SetText(itemData.reddotCount)
    end
  end
end
function common_popup_box_with_tab:_OnClickItem(widget, index)
  if TableUtil.Find(self.locklist, index) >= 0 then
    ShowNotice(86813)
    return
  end
  if not self:CanClickNow() then
    return
  end
  self.LoopScrollBox_Tab:Select(index)
  if self.onSelectTabEvent then
    self.onSelectTabEvent(widget, index)
  end
end
function common_popup_box_with_tab:CanClickNow(widget, index)
  if self.CanClickNowEvent then
    return self.CanClickNowEvent(widget, index)
  end
  return true
end
function common_popup_box_with_tab:_MergeData(originData, newData)
  for k, v in pairs(newData) do
    originData[k] = v
  end
end
function common_popup_box_with_tab:_OnRefreshJumpItem(widget, index)
  if self.jumpTabRefreshHandleFunc then
    self.jumpTabRefreshHandleFunc(widget, index)
  end
  local data = self.jumpData[index]
  if not data then
    log(bWriteLog and "common_popup_box_with_tab:_OnRefreshJumpItem invalid jump on index = " .. tostring(index))
    return
  end
  widget.TextBlock_Name_1:SetText(data.text or "")
end
function common_popup_box_with_tab:_OnClickJumpItem(widget, index)
  log(bWriteLog and "common_popup_box_with_tab:_OnClickJumpItem index = " .. tostring(index))
  if self.jumpClickedHandleFunc then
    self.jumpClickedHandleFunc(widget, index)
  else
    log(bWriteLog and "common_popup_box_with_tab:_OnClickJumpItem jumpClickedHandleFunc not set")
  end
end
local class = require("class")
local ui_base = require("client.slua.component.common.common_popup_box_base")
local CCommon_popup_box_with_tab = class(ui_base, nil, common_popup_box_with_tab)
return CCommon_popup_box_with_tab
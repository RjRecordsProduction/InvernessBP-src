local Common_Tab_Vertical_LevelOne_Text_UIBP = {}
local C_ShowFadeThreshold = 0.5
function Common_Tab_Vertical_LevelOne_Text_UIBP:ctor(_, bAutoSelect, bAutoSelectSub)
  self.tabClickedHandleFunc = nil
  self.tabSelectedHandleFunc = nil
  self.tabRefreshHandleFunc = nil
  self.subTabClickedHandleFunc = nil
  self.subTabSelectedHandleFunc = nil
  self.subTabRefreshHandleFunc = nil
  self.jumpClickedHandleFunc = nil
  self.jumpTabRefreshHandleFunc = nil
  self.tabData = nil
  self.jumpData = nil
  self.bAutoSelect = bAutoSelect ~= false
  self.bAutoSelectSub = bAutoSelectSub ~= false
  self.itemClickCDType = nil
  self.subItemClickCDType = nil
  self.bSubItemStartAnimPlayed = false
  self.tabStyle = 0
  self.bIsExpanded = false
  self.lastSelectedIndex = 0
  self.lastSelectedSubIndex = 0
  self.downloadDelLabelWidgets = {}
  self.subItemCDWidgets = {}
  self.bPlaySelectAnim = false
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:OnInitialize()
  Common_Tab_Vertical_LevelOne_Text_UIBP.__super.OnInitialize(self)
  local itemPaths = {
    itemLuaPath = "client.slua.component.common.item.Common_Tab_Vertical_LevelOne_Text_Item_UIBP",
    subItemLuaPath = "client.slua.component.common.item.Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP",
    jumpItemLuaPath = "client.slua.component.common.item.Common_Tab_Vertical_LevelOne_Text_JumpItem_UIBP"
  }
  self.ExtendedLoopScrollBox_Tab = self:InitExtendedScrollBox(self.UIRoot.ExtendedLoopScrollBox_Tab, {
    itemPaths.itemLuaPath,
    itemPaths.subItemLuaPath
  })
  self.LoopScrollBox_Jump = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Jump, itemPaths.jumpItemLuaPath)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:RegistEvents()
  Common_Tab_Vertical_LevelOne_Text_UIBP.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.ExtendedLoopScrollBox_Tab, "OnUserScrolled", self.OnUserScrolled, self)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:OnPostInitialize()
  Common_Tab_Vertical_LevelOne_Text_UIBP.__super.OnPostInitialize(self)
  if self.UIRoot.Anim_in then
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_in, 0, 1, 0, 1)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:OnUserScrolled()
  self:RefreshFade()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:RefreshFade()
  local widget = self.UIRoot.ExtendedLoopScrollBox_Tab
  local maxScrollOffset = widget:GetScrollEndOffset()
  local curScrollOffset = widget:GetScrollOffset()
  if maxScrollOffset - curScrollOffset > C_ShowFadeThreshold then
    self:SetWidgetVisible(self.UIRoot.Image_Fade, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Fade, false)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:OnClose()
  if self.UIRoot.Anim_in then
    self.UIRoot:PlayAnimationTo(self.UIRoot.Anim_in, 0, 0.01, 1, 0, 1)
  end
  self:CleanTabReddot(true)
  Common_Tab_Vertical_LevelOne_Text_UIBP.__super.OnClose(self)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:CleanTabReddot(isCleanCollect)
  local TableUtil = require("common.table_util")
  local subData = TableUtil.GetTableValue(self.tabData, self.lastSelectedIndex, "subData")
  if subData and next(subData) then
    local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
    local CollectTab = reddot_node_collect_manager:GetCollectTab()
    reddot_node_collect_manager:HideNodeAllChildNewReddot(CollectTab.collect_main, isCleanCollect)
    reddot_node_collect_manager:HideNodeAllChildBoxReddot(CollectTab.collect_main, isCleanCollect)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:RefreshTabItemShow(nIndex)
  if not nIndex then
    return
  end
  self.ExtendedLoopScrollBox_Tab:RefreshItem(nIndex)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:RefreshAllItems()
  self.ExtendedLoopScrollBox_Tab:RefreshAllItems()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetTabs(tabs, initialIndex, initialSubIndex, style)
  self.tabData = tabs
  self.lastSelectedIndex = 0
  self.bSubItemStartAnimPlayed = false
  self:SetTabStyle(style)
  self.ExtendedLoopScrollBox_Tab:SetData(self.tabData)
  self:SelectTab(initialIndex or 1, initialSubIndex, false)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetJumpTabs(jumps)
  self.jumpData = jumps
  self.LoopScrollBox_Jump:SetData(self.jumpData)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SelectTab(index, subIndex, bIsFromClick)
  index = index or 1
  self.bPlaySelectAnim = false
  self.ExtendedLoopScrollBox_Tab:ScrollToItem(index)
  local item = self.ExtendedLoopScrollBox_Tab:GetIndexOfItem(index)
  if item then
    item:OnSelectTab(subIndex, bIsFromClick)
    return
  end
  if self.selectTabTimer then
    self:RemoveTimer(self.selectTabTimer)
  end
  self.selectTabTimer = self:AddTimerLoop(0, function()
    local item = self.ExtendedLoopScrollBox_Tab:GetIndexOfItem(index)
    if item then
      item:OnSelectTab(subIndex, bIsFromClick)
      self:RemoveTimer(self.selectTabTimer)
    end
  end, 0, 0.05)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SelectSubTab(subIndex, bIsFromClick)
  self.ExtendedLoopScrollBox_Tab:SelectSub(subIndex)
  if self.subTabSelectedHandleFunc then
    self.subTabSelectedHandleFunc(self.lastSelectedSubIndex, subIndex, bIsFromClick)
  end
  self.lastSelectedSubIndex = subIndex
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabClickedCallback(func, funcSelf)
  function self.tabClickedHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabDoubleClickedCallback(func, index, funcSelf)
  local item = self.ExtendedLoopScrollBox_Tab:GetIndexOfItem(index)
  if not item then
    log_warning("Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabDoubleClickedCallback: item is nil")
    return
  end
  item:AddOnTabDoubleClickedCallback(func, funcSelf)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:ClearTabDoubleClickCallback(index)
  local item = self.ExtendedLoopScrollBox_Tab:GetIndexOfItem(index)
  if not item then
    log_warning("Common_Tab_Vertical_LevelOne_Text_UIBP:ClearTabDoubleClickCallback: item is nil")
    return
  end
  item:ClearTabDoubleClickCallback()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddIsCanClickTabCallback(func, ...)
  local args = table.pack(...)
  local common = require("client.slua_ui_framework.common")
  function self.isCanClickTabHandleFunc(widget, index)
    return common.CallCombinationArgs(func, args, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabSelectedCallback(func, funcSelf)
  function self.tabSelectedHandleFunc(lastIndex, index, bIsFromClick)
    return func(funcSelf, lastIndex, index, bIsFromClick)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnTabRefreshCallback(func, funcSelf)
  function self.tabRefreshHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddTabNumberCallback(func, funcSelf)
  if not func then
    self.updateTabNumberFunc = nil
    return
  end
  function self.updateTabNumberFunc(widget, index, subIndex)
    return func(funcSelf, widget, index, subIndex)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnSubTabClickedCallback(func, funcSelf)
  function self.subTabClickedHandleFunc(widget, subIndex)
    return func(funcSelf, widget, subIndex)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnSubTabSelectedCallback(func, funcSelf)
  function self.subTabSelectedHandleFunc(lastSubIndex, subIndex, bIsFromClick)
    return func(funcSelf, lastSubIndex, subIndex, bIsFromClick)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnSubTabRefreshCallback(func, funcSelf)
  function self.subTabRefreshHandleFunc(widget, subIndex)
    return func(funcSelf, widget, subIndex)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnJumpTabClickedCallback(func, funcSelf)
  function self.jumpClickedHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:AddOnJumpTabRefreshCallback(func, funcSelf)
  function self.jumpTabRefreshHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetItemClickCDType(type)
  self.itemClickCDType = type
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetSubItemClickCDType(type)
  self.subItemClickCDType = type
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetTabStyle(style)
  self.tabStyle = style or 0
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetTabData(index)
  if not self.tabData then
    log_warning("Common_Tab_Vertical_LevelOne_Text_UIBP:GetTabData not self.tabData")
    return nil
  end
  return self.tabData[index]
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetJumpTabData(index)
  return self.jumpData[index]
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetSelectedTabIndex()
  return self.ExtendedLoopScrollBox_Tab:GetSelectIndex()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetSelectedSubTabIndex()
  return self.ExtendedLoopScrollBox_Tab:GetSubSelectIndex()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetTabCount()
  return self.ExtendedLoopScrollBox_Tab:GetItemCount()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetSubTabCount()
  return self.ExtendedLoopScrollBox_Tab:GetSubTabCount()
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetAllTabData()
  return self.tabData
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:GetIndexOfWidget(nIndex)
  if not nIndex then
    return
  end
  return self.ExtendedLoopScrollBox_Tab:GetIndexOfWidget(nIndex)
end
function Common_Tab_Vertical_LevelOne_Text_UIBP:SetImageLineShow(isShow)
  self:SetWidgetVisible(self.UIRoot.Image_Line, isShow)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Tab_Vertical_LevelOne_Text_UIBP = class(ui_base, nil, Common_Tab_Vertical_LevelOne_Text_UIBP)
return CCommon_Tab_Vertical_LevelOne_Text_UIBP
local Common_Tab_Horizontal_Text_Item_Base = {}
function Common_Tab_Horizontal_Text_Item_Base:ctor(_, parent, index)
  self.  self.end
function Common_Tab_Horizontal_Text_Item_Base:OnInitialize()
  Common_Tab_Horizontal_Text_Item_Base.__super.OnInitialize(self)
end
function Common_Tab_Horizontal_Text_Item_Base:RegistEvents()
  Common_Tab_Horizontal_Text_Item_Base.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tab, self.OnClickItem, self)
end
function Common_Tab_Horizontal_Text_Item_Base:OnPostInitialize()
  Common_Tab_Horizontal_Text_Item_Base.__super.OnPostInitialize(self)
  self:_InitReddotShow()
  self:_InitLockShow()
  self:UpdateUI()
end
function Common_Tab_Horizontal_Text_Item_Base:OnClickItem()
  if self.parent.itemClickCDCfg ~= nil then
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(self.parent.itemClickCDCfg) then
      return
    end
  end
  local lastSelectedIndex = self.parent.selectedTab
  if self.parent.lastSelectedWidget and slua.isValid(self.parent.lastSelectedWidget) then
    self.parent.lastSelectedWidget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  self.UIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  self.parent.lastSelectedWidget = self.UIRoot
  self.parent.selectedTab = self.index
  if self.parent.onSelectTabEvent then
    self.parent.onSelectTabEvent(self.UIRoot, self.index)
  end
  if self.parent.tabSelectedHandleFunc and lastSelectedIndex ~= self.index then
    self.parent.tabSelectedHandleFunc(lastSelectedIndex, self.index, true)
  end
end
function Common_Tab_Horizontal_Text_Item_Base:UpdateUI()
  if self.index == self.parent.selectedTab then
    self.UIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
  end
  if self.index == #self.parent.tabData then
    self:SetWidgetVisible(self.UIRoot.Image_Line_LastCollapsed, false)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Line_LastCollapsed, true)
  end
  local curText = self.parent.tabData[self.index]
  self.UIRoot.TextBlock_Select:SetText(curText)
  self.UIRoot.TextBlock_Unselect:SetText(curText)
  if self.parent.tabRefreshHandleFunc then
    self.parent.tabRefreshHandleFunc(self.UIRoot, self.index)
  end
end
function Common_Tab_Horizontal_Text_Item_Base:_InitReddotShow()
end
function Common_Tab_Horizontal_Text_Item_Base:_InitLockShow()
end
function Common_Tab_Horizontal_Text_Item_Base:OnClose()
  if self.UIRoot.Reddot_Anchor and self.UIRoot.Reddot_Anchor.UnBind then
    self.UIRoot.Reddot_Anchor:UnBind()
  end
  if self.UIRoot.Reddot_Anchor_Component and self.UIRoot.Reddot_Anchor_Component.UnBind then
    self.UIRoot.Reddot_Anchor_Component:UnBind()
  end
  if self.UIRoot.Reddot_Anchor_Item05 and self.UIRoot.Reddot_Anchor_Item05.UnBind then
    self.UIRoot.Reddot_Anchor_Item05:UnBind()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Tab_Horizontal_LevelOne_Text_Item_UIBP = class(ui_base, nil, Common_Tab_Horizontal_Text_Item_Base)
return CCommon_Tab_Horizontal_LevelOne_Text_Item_UIBP
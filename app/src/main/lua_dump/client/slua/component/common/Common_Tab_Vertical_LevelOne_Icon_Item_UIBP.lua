local Common_Tab_Vertical_LevelOne_Icon_Item_UIBP = {}
local C_AnimPlayDelayTime = 0.1
local defaultRedImageSize = FVector2D(10, 10)
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:ctor()
  self.data = nil
  self.index = 0
  self.parentUI = nil
  self.animTimer = nil
end
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:OnInitialize()
end
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tab, self.OnClicked, self)
end
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:OnClose()
  self.UIRoot.Reddot_Anchor:UnBind()
  Common_Tab_Vertical_LevelOne_Icon_Item_UIBP.__super.OnClose(self)
end
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:OnClicked()
  log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:OnClicked index = " .. tostring(self.index))
  if self.parentUI and self.parentUI.itemClickCDType then
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(self.parentUI.itemClickCDType) then
      return
    end
  end
  if self.parentUI and self.parentUI.OnLoopScrollBox_TabItemClicked then
    self.parentUI:OnLoopScrollBox_TabItemClicked(self.UIRoot, self.index)
  end
end
function Common_Tab_Vertical_LevelOne_Icon_Item_UIBP:OnRefresh()
  self.parentUI = self:GetLoopScrollBoxParentUI()
  local widget = self.UIRoot
  local parent = self.parentUI
  local tabData = self.data
  self:SetWidgetVisible(widget.Border_Anim, true)
  self:SetWidgetVisible(widget.Image_Reddot, false)
  if widget.Image_Line_LastCollapsed then
    self:SetWidgetVisible(widget.Image_Line_LastCollapsed, true)
  end
  if widget.CanvasPanel_SelectText then
    self:SetWidgetVisible(widget.CanvasPanel_SelectText, false)
  end
  if widget.CanvasPanel_UnSelectText then
    self:SetWidgetVisible(widget.CanvasPanel_UnSelectText, false)
  end
  if parent.tabRefreshHandleFunc then
    parent.tabRefreshHandleFunc(widget, self.index)
  end
  local curSelectIndex = parent:GetSelectedTabIndex()
  if curSelectIndex == self.index then
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(1)
    self:SetTexture(widget.Image_SelectIcon, tabData.activePath, {
      bMatchSize = tabData.bMatchSize
    })
    if not parent.bNoAnim and widget.Anim_Select and parent.lastSelectedIndex ~= self.index then
      self:PlayWidgetAnimation(widget, widget.Anim_Select, 0.167, 1, 0, 1)
    end
  else
    widget.WidgetSwitcher_Tab:SetActiveWidgetIndex(0)
    self:SetTexture(widget.Image_UnSelectIcon, tabData.inactivePath, {
      bMatchSize = tabData.bMatchSize
    })
  end
  if tabData.showNormalRed then
    self:SetWidgetVisible(widget.Image_Reddot, true)
    self:SetTexture(widget.Image_Reddot, tabData.redImagePath, {
      bMatchSize = tabData.bMatchSize
    })
    if tabData.redImageSize then
      widget.Image_Reddot.Slot:SetSize(tabData.redImageSize)
    else
      widget.Image_Reddot.Slot:SetSize(defaultRedImageSize)
    end
  end
  local bShouldShowBaseLine = self.index ~= parent:GetTabCount()
  if widget.Image_Line_LastCollapsed then
    self:SetWidgetVisible(widget.Image_Line_LastCollapsed, bShouldShowBaseLine)
  end
  if not widget.Anim_in then
    return
  end
  if self.animTimer then
    self:RemoveTimer(self.animTimer)
    self.animTimer = nil
  end
end
local class = require("class")
local ScrollBoxChildBase = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(ScrollBoxChildBase, nil, Common_Tab_Vertical_LevelOne_Icon_Item_UIBP)
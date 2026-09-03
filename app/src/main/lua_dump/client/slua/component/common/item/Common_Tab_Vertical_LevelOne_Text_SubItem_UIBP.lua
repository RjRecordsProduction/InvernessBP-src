local StyleConfig = require("client.slua.component.common.config.Common_Tab_Vertical_Text_Style_Config")
local Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP = {}
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:ctor()
  self.animDelayTimer = nil
end
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:OnSubRefresh(data, selectIndex)
  self:OnRefresh(data, selectIndex)
end
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tab, self.OnClickTab, self)
end
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:OnRefresh(data, subIndex)
  local parentUI = self:GetLoopScrollBoxParentUI()
  local styleCfg = StyleConfig.GetConfig(parentUI.tabStyle)
  local textStyle = styleCfg.SubItemStyleConfig
  local animationStyle = styleCfg.AnimationConfig
  self:SetWidgetVisible(self.UIRoot.Border_Anim, true)
  self:SetWidgetVisible(self.UIRoot.Image_Reddot_01, false)
  if parentUI.subTabRefreshHandleFunc then
    parentUI.subTabRefreshHandleFunc(self.UIRoot, self.index)
  end
  local curSelectSubIndex = parentUI.ExtendedLoopScrollBox_Tab:GetSubSelectIndex()
  local curSelectIndex = parentUI.ExtendedLoopScrollBox_Tab:GetSelectIndex()
  local bIsSelected = curSelectSubIndex == self.index
  local textColorCfg = bIsSelected and textStyle.TextColorSelected or textStyle.TextColorUnselected
  local textColor = FSlateColor(FLinearColor(textColorCfg[1], textColorCfg[2], textColorCfg[3], textColorCfg[4]))
  local displayText = data.text or ""
  if bIsSelected and self.UIRoot.Fadein_Select and parentUI.lastSelectedSubIndex ~= self.index then
    parentUI:PlayWidgetAnimation(self.UIRoot, self.UIRoot.Fadein_Select, 0, 1, 0, 1)
  end
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetVietnamAutoCapitalizeText(self.UIRoot.TextBlock_Name)
  self.UIRoot.TextBlock_Name:SetColorAndOpacity(textColor)
  self.UIRoot.TextBlock_Name:SetText(displayText)
  self:SetWidgetVisible(self.UIRoot.Image_Selected_Bg, bIsSelected)
  local cdWidget = parentUI.subItemCDWidgets[tostring(self.UIRoot)]
  local hasTimingData = data.timing ~= nil
  if hasTimingData then
    if cdWidget then
      cdWidget:RefreshSelect(bIsSelected)
    else
      local countdownBpPath = UIManager.UI_Config.Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP
      parentUI.subItemCDWidgets[tostring(self.UIRoot)] = parentUI:CreateChildWindow(self.UIRoot.VerticalBox_Tab, countdownBpPath, data, bIsSelected)
    end
  elseif cdWidget then
    cdWidget:CloseSelf()
    parentUI.subItemCDWidgets[tostring(self.UIRoot)] = nil
  end
  local bShouldShowBaseLine = curSelectIndex ~= #data or self.index ~= #data[curSelectIndex].subData
  self:SetWidgetVisible(self.UIRoot.Image_Line_LastCollapsed, bShouldShowBaseLine)
  local animDelayTime = data.animDelayTime or (self.index - 1) * animationStyle.AnimationPlayDelayTime
  self:PlayEnterAnimation(animDelayTime)
end
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:OnClickTab()
  local parentUI = self:GetLoopScrollBoxParentUI()
  log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:OnExtendedLoopScrollBox_TabSubItemClicked subIndex = " .. tostring(self.index))
  if parentUI.subItemClickCDType then
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(parentUI.subItemClickCDType) then
      return
    end
  end
  if parentUI.subTabClickedHandleFunc then
    parentUI.subTabClickedHandleFunc(self.UIRoot, self.index)
  else
    log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:OnExtendedLoopScrollBox_TabItemClicked subTabClickedHandleFunc not set")
  end
  if parentUI.bAutoSelectSub then
    parentUI:SelectSubTab(self.index, true)
  end
end
function Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:PlayEnterAnimation(delayTime)
  local parentUI = self:GetLoopScrollBoxParentUI()
  if not self.UIRoot.Fadein then
    return
  end
  if parentUI and parentUI.bSubItemStartAnimPlayed then
    return
  end
  if self.animDelayTimer then
    self:RemoveTimer(self.animDelayTimer)
    self.animDelayTimer = nil
  end
  delayTime = delayTime or 0
  if delayTime < 0 then
    delayTime = 0
  end
  self:SetWidgetVisible(self.UIRoot.Border_Anim, false)
  self.animDelayTimer = self:AddTimerOnce(delayTime, function()
    if slua.isValid(self.UIRoot) then
      self:SetWidgetVisible(self.UIRoot.Border_Anim, true)
      self.UIRoot:PlayAnimationTo(self.UIRoot.Fadein, 0.01, self.UIRoot.Fadein:GetEndTime(), 1, 0, 1)
      log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP:PlayEnterAnimation played for index = " .. tostring(self.index))
    end
    self.animDelayTimer = nil
  end)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.extended_loop_scroll_box_subItem_base")
return class(ui_base, nil, Common_Tab_Vertical_LevelOne_Text_SubItem_UIBP)
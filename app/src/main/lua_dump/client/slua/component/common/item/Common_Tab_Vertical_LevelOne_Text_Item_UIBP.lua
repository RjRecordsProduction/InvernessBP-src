local StyleConfig = require("client.slua.component.common.config.Common_Tab_Vertical_Text_Style_Config")
local Common_Tab_Vertical_LevelOne_Text_Item_UIBP = {}
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:ctor()
  self.animDelayTimer = nil
  self.bAnimPlayed = false
  self.tabDoubleClickedHandleFunc = nil
  self.tabClickCount = 0
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:CheckNeedPlaySelectAnim(bIsFromClick)
  local parentUI = self:GetLoopScrollBoxParentUI()
  local curSelectIndex = parentUI.ExtendedLoopScrollBox_Tab:GetSelectIndex()
  local bIsSelected = curSelectIndex == self.index
  if bIsSelected and parentUI.lastSelectedIndex ~= self.index then
    if not parentUI.bHasPlayDefaultSelectAnim then
      log(bWriteLog and " Common_Tab_Vertical_LevelOne_Text_Item_UIBP11:CheckNeedPlaySelectAnim Select_Fadein")
      if not self:IsAnimationPlaying("Select_Fadein") then
        self:PlayWidgetAnimation(self.UIRoot, self.UIRoot.Select_Fadein, 0, 1, 0, 1)
      end
      parentUI.bHasPlayDefaultSelectAnim = true
    elseif bIsFromClick then
      log(bWriteLog and " Common_Tab_Vertical_LevelOne_Text_Item_UIBP11:CheckNeedPlaySelectAnim Anim_Select")
      if not self:IsAnimationPlaying("Anim_Select") then
        self:PlayWidgetAnimation(self.UIRoot, self.UIRoot.Anim_Select, 0, 1, 0, 1)
      end
    else
      log(bWriteLog and " Common_Tab_Vertical_LevelOne_Text_Item_UIBP11:CheckNeedPlaySelectAnim not bIsFromClick Select_Fadein")
      if not self:IsAnimationPlaying("Select_Fadein") then
        self:PlayWidgetAnimation(self.UIRoot, self.UIRoot.Select_Fadein, 0, 1, 0, 1)
      end
    end
  end
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnSubRefresh(data, selectIndex)
  self:OnRefresh(data, selectIndex)
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tab, self.OnClickTab, self)
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnHide()
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnClickTab()
  log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:OnExtendedLoopScrollBox_TabItemClicked index = " .. tostring(self.index))
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.ActivityGetBtn) then
    return
  end
  local parentUI = self:GetParentUI()._parentUI
  if self.tabDoubleClickedHandleFunc then
    self.tabClickCount = self.tabClickCount + 1
    log(bWriteLog and "Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnClickTab tabClickCount = " .. tostring(self.tabClickCount))
    self:AddTimerOnce(0.6, function()
      self.tabClickCount = 0
    end)
    if self.tabClickCount >= 2 then
      log(bWriteLog and "Common_Tab_Vertical_LevelOne_Text_Item_UIBP:DoubleClickTab")
      self.tabClickCount = 0
      self.tabDoubleClickedHandleFunc(self.UIRoot, self.index)
      return
    end
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
  if parentUI.lastClickItemTime and parentUI.itemClickCD and currentTime < parentUI.lastClickItemTime + parentUI.itemClickCD then
    ShowNotice(7108)
    return
  end
  if parentUI.itemClickCDType and parentUI.itemClickCDType ~= "" then
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(parentUI.itemClickCDType) then
      return
    end
  end
  if parentUI.isCanClickTabHandleFunc and not parentUI.isCanClickTabHandleFunc(self.UIRoot, self.index) then
    log_warning("Common_Tab_Vertical_LevelOne_Text_UIBP:OnExtendedLoopScrollBox_TabItemClicked, tab can't click")
    return
  end
  if parentUI.tabClickedHandleFunc then
    parentUI.tabClickedHandleFunc(self.UIRoot, self.index)
  else
    log_warning("[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:OnExtendedLoopScrollBox_TabItemClicked tabClickedHandleFunc not set")
  end
  parentUI.lastClickItemTime = currentTime
  for _, widget in pairs(parentUI.subItemCDWidgets) do
    widget:CloseSelf()
  end
  parentUI.subItemCDWidgets = {}
  if parentUI.bAutoSelect then
    self:OnSelectTab(parentUI.bAutoSelectSub and 1 or nil, true)
  end
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnSelectTab(subIndex, bIsFromClick)
  local parentUI = self:GetParentUI()._parentUI
  local preIsExpanded = parentUI.bIsExpanded
  if parentUI.lastSelectedIndex == self.index then
    parentUI.bIsExpanded = not parentUI.bIsExpanded
  else
    parentUI.bIsExpanded = true
    parentUI.ExtendedLoopScrollBox_Tab:SetSubData(parentUI.lastSelectedIndex)
  end
  parentUI:CleanTabReddot(false)
  parentUI.ExtendedLoopScrollBox_Tab:Select(self.index)
  if parentUI.tabSelectedHandleFunc then
    parentUI.tabSelectedHandleFunc(parentUI.lastSelectedIndex, self.index, bIsFromClick)
  end
  local TableUtil = require("common.table_util")
  local subData = TableUtil.GetTableValue(parentUI.tabData, self.index, "subData")
  if not subData or not next(subData) then
    parentUI.bIsExpanded = false
  end
  log_tree("[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:SelectTab subData = ", subData)
  if parentUI.bIsExpanded then
    parentUI.bSubItemStartAnimPlayed = false
    parentUI.ExtendedLoopScrollBox_Tab:SetSubData(self.index, subData)
    if parentUI.lastSelectedIndex ~= self.index then
      parentUI.lastSelectedSubIndex = 0
    end
    if parentUI.bAutoSelectSub and subIndex then
      parentUI:SelectSubTab(math.max(parentUI.lastSelectedSubIndex, subIndex), false)
    end
    parentUI.bSubItemStartAnimPlayed = true
  else
    parentUI.ExtendedLoopScrollBox_Tab:FoldingSubTab()
    parentUI.bSubItemStartAnimPlayed = false
  end
  if preIsExpanded ~= parentUI.bIsExpanded and self.UIRoot then
    local data = TableUtil.GetTableValue(parentUI.tabData, self.index)
    if not data or not next(data) then
      log_error_format("[DeanJYT] Common_Tab_Vertical_LevelOne_Text_UIBP:OnRefreshExtendedLoopScrollBox_TabItem invalid data on index = %s", tostring(self.index))
      return
    end
    local item = parentUI.ExtendedLoopScrollBox_Tab:GetIndexOfItem(self.index)
    item:OnRefresh(data, self.index)
  end
  local timer_ticker = require("common.time_ticker")
  local NEXT_FRAME = timer_ticker.NEXT_FRAME
  local count = 2
  local timerID
  timerID = parentUI:AddTimerLoop(0, function()
    count = count - 1
    if count <= 0 then
      parentUI:RefreshFade()
      parentUI:RemoveTimer(timerID)
    end
  end, TIMER_INFINITE, NEXT_FRAME)
  self:CheckNeedPlaySelectAnim(bIsFromClick)
  parentUI.lastSelectedIndex = self.index
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:OnRefresh(data, index)
  local parentUI = self:GetLoopScrollBoxParentUI()
  local styleCfg = StyleConfig.GetConfig(parentUI.tabStyle)
  local textStyle = styleCfg.ItemTextStyleConfig
  local backgroundStyle = styleCfg.BackGroundStyleConfig
  local arrowStyle = styleCfg.ArrowStyleConfig
  local animationStyle = styleCfg.AnimationConfig
  self:SetWidgetVisible(self.UIRoot.Border_Anim, true)
  self:SetWidgetVisible(self.UIRoot.Image_Reddot_01, false)
  local curSelectIndex = parentUI.ExtendedLoopScrollBox_Tab:GetSelectIndex()
  local bIsSelected = curSelectIndex == self.index
  local bCanExpand = data.subData and next(data.subData)
  local arrowTexture = arrowStyle.ArrowIconPath
  local arrowAngle = arrowStyle.ArrowAngleUnexpanded
  local arrowColor = FLinearColor(arrowStyle.ArrowColorUnselected[1], arrowStyle.ArrowColorUnselected[2], arrowStyle.ArrowColorUnselected[3], arrowStyle.ArrowColorUnselected[4])
  local textColor = FSlateColor(FLinearColor(textStyle.TextColorUnselected[1], textStyle.TextColorUnselected[2], textStyle.TextColorUnselected[3], textStyle.TextColorUnselected[4]))
  local backgroundColor = FLinearColor(backgroundStyle.BackgroundColorUnselected[1], backgroundStyle.BackgroundColorUnselected[2], backgroundStyle.BackgroundColorUnselected[3], backgroundStyle.BackgroundColorUnselected[4])
  local outlineColor = FLinearColor(textStyle.TextOutlineColorUnselected[1], textStyle.TextOutlineColorUnselected[2], textStyle.TextOutlineColorUnselected[3], textStyle.TextOutlineColorUnselected[4])
  local shadowColor = FLinearColor(textStyle.TextShadowUnselected[1], textStyle.TextShadowUnselected[2], textStyle.TextShadowUnselected[3], textStyle.TextShadowUnselected[4])
  local selectedBackgroundImage = backgroundStyle.BackgroundImageSelected
  if bIsSelected then
    arrowAngle = parentUI.bIsExpanded and arrowStyle.ArrowAngleExpanded or arrowStyle.ArrowAngleUnexpanded
    textColor = FSlateColor(FLinearColor(textStyle.TextColorSelected[1], textStyle.TextColorSelected[2], textStyle.TextColorSelected[3], textStyle.TextColorSelected[4]))
    arrowColor = FLinearColor(arrowStyle.ArrowColorSelected[1], arrowStyle.ArrowColorSelected[2], arrowStyle.ArrowColorSelected[3], arrowStyle.ArrowColorSelected[4])
    backgroundColor = FLinearColor(backgroundStyle.BackgroundColorSelected[1], backgroundStyle.BackgroundColorSelected[2], backgroundStyle.BackgroundColorSelected[3], backgroundStyle.BackgroundColorSelected[4])
    outlineColor = FLinearColor(textStyle.TextOutlineColorSelected[1], textStyle.TextOutlineColorSelected[2], textStyle.TextOutlineColorSelected[3], textStyle.TextOutlineColorSelected[4])
    shadowColor = FLinearColor(textStyle.TextShadowSelected[1], textStyle.TextShadowSelected[2], textStyle.TextShadowSelected[3], textStyle.TextShadowSelected[4])
  end
  self.UIRoot.TextBlock_Name:SetShadowColorAndOpacity(shadowColor)
  self:StopAnimation("Anim_Select")
  self:StopAnimation("Select_Fadein")
  self:SetTexture(self.UIRoot.Image_Arrow, arrowTexture)
  self.UIRoot.Image_Arrow:SetColorAndOpacity(arrowColor)
  self.UIRoot.Image_Arrow:SetRenderAngle(arrowAngle)
  self:SetTexture(self.UIRoot.Image_Selected_Bg, selectedBackgroundImage)
  self.UIRoot.Image_Selected_Bg:SetColorAndOpacity(backgroundColor)
  self.UIRoot.TextBlock_Name:SetColorAndOpacity(textColor)
  local fontInfo = self.UIRoot.TextBlock_Name.Font
  local outlineSettings = slua.IndexReference(fontInfo, "OutlineSettings")
  outlineSettings.OutlineColor = outlineColor
  self.UIRoot.TextBlock_Name:SetFont(fontInfo)
  local textblock_name = data.text or data.loc and LocUtil.GetLocalizeResStr(data.loc) or ""
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetVietnamAutoCapitalizeText(self.UIRoot.TextBlock_Name)
  self.UIRoot.TextBlock_Name:SetText(textblock_name)
  self:SetWidgetVisible(self.UIRoot.Image_Arrow, bCanExpand)
  local animDelayTime = data.animDelayTime or (self.index - 1) * animationStyle.AnimationPlayDelayTime
  self:PlayEnterAnimation(animDelayTime)
  if parentUI.tabRefreshHandleFunc then
    parentUI.tabRefreshHandleFunc(self.UIRoot, self.index)
  end
  local tabNumber = parentUI.updateTabNumberFunc and parentUI.updateTabNumberFunc(self.UIRoot, self.index, nil) or nil
  local shouldShowNumber = tabNumber and 0 < tabNumber
  if shouldShowNumber then
    local labelWidget = parentUI.downloadDelLabelWidgets[tostring(self.UIRoot)]
    if not labelWidget then
      local labelBpPath = "/Game/UMG/UI_BP/Download/Item/DownLoad_Delete_Label_Item_UIBP.DownLoad_Delete_Label_Item_UIBP"
      labelWidget = parentUI:CreateChildWindowWithBpPath(self.UIRoot.CanvasPanel_Lable, nil, labelBpPath)
      if labelWidget then
        labelWidget:SetAutoSize(true)
        parentUI.downloadDelLabelWidgets[tostring(self.UIRoot)] = labelWidget
      end
    end
    if labelWidget and labelWidget.UIRoot and labelWidget.UIRoot.TextBlock_0 then
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetVietnamAutoCapitalizeText(labelWidget.UIRoot.TextBlock_0)
      labelWidget.UIRoot.TextBlock_0:SetText(tostring(tabNumber))
    end
  else
    local labelWidget = parentUI.downloadDelLabelWidgets[tostring(self.UIRoot)]
    if labelWidget then
      labelWidget:CloseSelf()
      parentUI.downloadDelLabelWidgets[tostring(self.UIRoot)] = nil
    end
  end
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:PlayEnterAnimation(delayTime)
  if not self.UIRoot.Anim_in then
    return
  end
  if self.bAnimPlayed then
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
      self.bAnimPlayed = true
      self.UIRoot:PlayAnimationTo(self.UIRoot.Anim_in, 0.01, self.UIRoot.Anim_in:GetEndTime(), 1, 0, 1)
      log(bWriteLog and "[DeanJYT] Common_Tab_Vertical_LevelOne_Text_Item_UIBP:PlayEnterAnimation played for index = " .. tostring(self.index))
    end
    self.animDelayTimer = nil
  end)
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:AddOnTabDoubleClickedCallback(func, funcSelf)
  function self.tabDoubleClickedHandleFunc(widget, index)
    return func(funcSelf, widget, index)
  end
end
function Common_Tab_Vertical_LevelOne_Text_Item_UIBP:ClearTabDoubleClickCallback()
  self.tabDoubleClickedHandleFunc = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.extended_loop_scroll_box_subItem_base")
return class(ui_base, nil, Common_Tab_Vertical_LevelOne_Text_Item_UIBP)
local Setting_Item_Base = {}
local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local GeneralMargin = SettingStyleLibrary.GeneralMargin
local ExpandedMargin = SettingStyleLibrary.ExpandedMargin
local GeneralBGColor = SettingStyleLibrary.GeneralBGColor
local ExpandedBGColor = SettingStyleLibrary.ExpandedBGColor
function Setting_Item_Base:ctor(_, Data)
  self.end
function Setting_Item_Base:OnInitialize()
  print(bWriteLog and "Setting_Item_Base:OnInitialize " .. (self.Data.Key or "Untitled"))
  if self.UIRoot.Slot and self.UIRoot.Slot.SetPadding then
    if self.Data.ExpandHandle then
      self.UIRoot.Slot:SetPadding(ExpandedMargin)
      if self.UIRoot.Setting_Option_Base and self.UIRoot.Setting_Option_Base.Border_BG then
        self.UIRoot.Setting_Option_Base.Border_BG:SetBrushColor(ExpandedBGColor)
      end
    else
      self.UIRoot.Slot:SetPadding(GeneralMargin)
      if self.UIRoot.Setting_Option_Base and self.UIRoot.Setting_Option_Base.Border_BG then
        self.UIRoot.Setting_Option_Base.Border_BG:SetBrushColor(GeneralBGColor)
      end
    end
  end
  self:SelfHitTestInvisible()
  if self.Data.Decoration then
    if self.Data.Decoration.moduleName then
      self:Decorate(self.Data.Decoration)
    else
      for _, Decoration in ipairs(self.Data.Decoration) do
        self:Decorate(Decoration)
      end
    end
  end
end
function Setting_Item_Base:RegistEvents()
  if self.Data.ExpandHandle then
    self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SWITCHER_EXPAND, self.OnSwitcherExpanded, self)
    self:_RefreshExpandState()
  end
  if self.Data.EventType and self.Data.EventID then
    self:AddCommonEvent(self.Data.EventType, self.Data.EventID, self.OnRefreshOption, self)
  end
  if self.Data.EventType_1 and self.Data.EventID_1 then
    self:AddCommonEvent(self.Data.EventType_1, self.Data.EventID_1, self.OnRefreshOption, self)
  end
end
function Setting_Item_Base:SetData(NewData)
  self:UnRegistEvents()
  self.Data = NewData
  self:OnInitialize()
  self:RegistEvents()
end
function Setting_Item_Base:OnRefreshOption()
end
function Setting_Item_Base:Decorate(Decoration)
  if self.UIRoot.Setting_Option_Base and self.UIRoot.Setting_Option_Base.HorizontalBox_Decoration then
    self:CreateChildWindow(self.UIRoot.Setting_Option_Base.HorizontalBox_Decoration, Decoration, self.Data.Key)
  end
end
function Setting_Item_Base:OnSwitcherExpanded(_, __, ExpandHandle, bExpanded)
  if self.Data.ExpandHandle == ExpandHandle then
    if bExpanded then
      self:SelfHitTestInvisible()
    else
      self:Collapsed()
    end
  else
  end
end
function Setting_Item_Base:SetupHelpButton(HelpButton)
  if self.Data.Help then
    self:SetWidgetVisible(HelpButton, true, true)
    if type(self.Data.Help) == "number" or type(self.Data.Help) == "string" then
      self:_BindOnClickHelp(HelpButton, self.Data.Help)
    elseif type(self.Data.Help) == "function" then
      self:AddOnClickedEventByControl(HelpButton, self.Data.Help)
    end
  else
    self:SetWidgetVisible(HelpButton, false)
  end
end
function Setting_Item_Base:_BindOnClickHelp(HelpButton, HelpTipsLocID)
  self:AddOnClickedEventByControl(HelpButton, self._ShowHelpTips, HelpButton, HelpTipsLocID)
end
function Setting_Item_Base._ShowHelpTips(HelpButton, HelpTipsLocID)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(HelpTipsLocID), HelpButton)
end
function Setting_Item_Base:_RefreshExpandState()
  local StackContainer = self:GetParentUI()
  if StackContainer and StackContainer.GetItemUI then
    local ExpandHandleUI = StackContainer:GetItemUI(self.Data.ExpandHandle)
    if ExpandHandleUI and ExpandHandleUI.GetExpandState and not ExpandHandleUI:GetExpandState() then
      self:Collapsed()
    end
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, Setting_Item_Base)
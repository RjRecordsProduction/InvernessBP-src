local Setting_Option_Switcher = {}
local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
local TableUtil = require("common.table_util")
local DefaultSwitcherText = SettingStyleLibrary.DefaultSwitcherText
local ESelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local ECollapsed = UEnums.ESlateVisibility.Collapsed
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
function Setting_Option_Switcher:OnInitialize()
  Setting_Option_Switcher.__super.OnInitialize(self)
  if not self.Data.SetFunc then
    self.Data.SetFunc = FuncLib.SetValue
  end
  if not self.Data.GetFunc then
    self.Data.GetFunc = FuncLib.GetValue
  end
  if self.UIRoot.Setting_Option_Base then
    if type(self.Data.Text) == "number" then
      self.UIRoot.Setting_Option_Base.Text:SetText(LocUtil.GetLocalizeResStr(self.Data.Text))
    elseif type(self.Data.Text) == "string" then
      self.UIRoot.Setting_Option_Base.Text:SetText(self.Data.Text)
    end
    self:SetupHelpButton(self.UIRoot.Setting_Option_Base.Button_Help)
  end
  self:SetupOptionItemWidget()
  if self.Data.ExpandIndex ~= nil then
    self.ExpandableMap = {}
    if type(self.Data.ExpandIndex) == "table" then
      for _, _Index in ipairs(self.Data.ExpandIndex) do
        self.ExpandableMap[_Index] = true
      end
    else
      self.ExpandableMap[self.Data.ExpandIndex] = true
    end
  end
  if self.ExpandableMap then
    for idx, _ in pairs(self.ExpandableMap) do
      local SwitcherItemUI = self.UIRoot.Switcher:GetOption(idx)
      if slua.isValid(SwitcherItemUI) then
        SwitcherItemUI.Image_Arrow:SetWidgetVisibility(ESelfHitTestInvisible)
        SwitcherItemUI.Image_Arrow:SetRenderAngle(-90)
      end
    end
  end
  if self.Data.FixedFunc then
    self.FixedValue, self.bFixedNotifText = self.Data.FixedFunc(self.Data.Key)
  end
  if self.FixedValue then
    self.UIRoot.Switcher:SetIsEnabled(false)
  else
    self.UIRoot.Switcher:SetIsEnabled(true)
  end
  self:RefreshSelection()
  if self.ExpandableMap then
    local CurrentSelect = self:GetSelectedIndex()
    if self.ExpandableMap[CurrentSelect] then
      self:_ToggleExpand(CurrentSelect, true)
    end
  end
end
function Setting_Option_Switcher:RegistEvents()
  Setting_Option_Switcher.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Switcher, "OnSelected", self.OnSelected, self)
end
function Setting_Option_Switcher:SetupOptionItemWidget()
  local SwitcherText = self.Data.SwitcherText or DefaultSwitcherText
  if SwitcherText then
    local OptionCount = #SwitcherText
    self.UIRoot.Switcher:CreateOptions(OptionCount)
    for Idx = 0, OptionCount - 1 do
      local SwitcherItemUI = self.UIRoot.Switcher:GetOption(Idx)
      if slua.isValid(SwitcherItemUI) then
        SwitcherItemUI.Text:SetText(LocUtil.GetLocalizeResStr(SwitcherText[Idx + 1]))
        if SwitcherItemUI.Image_Appendix then
          SwitcherItemUI.Image_Appendix:SetWidgetVisibility(ECollapsed)
        end
        if SwitcherItemUI.Image_Arrow then
          SwitcherItemUI.Image_Arrow:SetWidgetVisibility(ECollapsed)
        end
        self:SetupRecommendItems(SwitcherItemUI, Idx)
      end
    end
  end
end
function Setting_Option_Switcher:SetupRecommendItems(SwitcherItemUI, Index)
  local RecommendedIndex = self.Data.RecommendedIndex or -1
  if Index == RecommendedIndex and SwitcherItemUI and SwitcherItemUI.Overlay_Widget then
    local NewRecommendUI = UIManager.ShowUI(UIManager.UI_Config.Setting_Item_Recommend)
    if NewRecommendUI and NewRecommendUI.UIRoot then
      SwitcherItemUI.Overlay_Widget:AddChild(NewRecommendUI.UIRoot)
      if not self.RecommendItems then
        self.RecommendItems = {}
      end
      self.RecommendItems[#self.RecommendItems + 1] = NewRecommendUI
    end
  end
end
function Setting_Option_Switcher:OnRefreshOption()
  Setting_Option_Switcher.__super.OnRefreshOption(self)
  self:RefreshSelection()
end
function Setting_Option_Switcher:RefreshSelection()
  local Value = self.Data.GetFunc(self.Data.Key)
  local Idx = self:_ValueToIndex(Value)
  local LastIdx = self.UIRoot.Switcher:RefreshSelection(Idx)
  if LastIdx ~= Idx then
    self:_SwitchExpand(LastIdx, Idx)
  end
end
function Setting_Option_Switcher:ForceSelect(Value)
  local Idx = self:_ValueToIndex(Value)
  local LastIdx = self.UIRoot.Switcher:RefreshSelection(Idx)
  if LastIdx == Idx then
    LastIdx = -1
  end
  self:OnSelected(LastIdx, Idx)
end
function Setting_Option_Switcher:OnSelected(LastIdx, Idx)
  self:PlayAudio(sound_config.click_v1)
  if self._ValueBefore == nil then
    self._ValueBefore = self.Data.GetFunc(self.Data.Key)
  end
  if LastIdx ~= Idx then
    local Value = self:_IndexToValue(Idx)
    if self.Data.SetFunc(self.Data.Key, Value) then
      self.UIRoot.Switcher:RefreshSelection(Idx)
      self:_SwitchExpand(LastIdx, Idx)
    end
  else
    self:_SwitchExpand(LastIdx, Idx)
  end
end
function Setting_Option_Switcher:OnClose()
  if self.RecommendItems then
    for _, RecommendItem in ipairs(self.RecommendItems) do
      RecommendItem:Close()
    end
  end
  if self._ValueBefore ~= nil then
    local ValueNow = self.Data.GetFunc(self.Data.Key)
    if self._ValueBefore ~= ValueNow then
      self:ReportTLOG(ValueNow)
    end
  end
end
function Setting_Option_Switcher:_SwitchExpand(LastIdx, Idx)
  if self.ExpandableMap then
    if LastIdx ~= Idx and self.ExpandableMap[LastIdx] then
      self:_ToggleExpand(LastIdx, false, false)
    end
    self:_ToggleExpand(Idx, nil, true)
  end
end
function Setting_Option_Switcher:_ValueToIndex(Value)
  if self.Data.SwitcherValue then
    local Index = TableUtil.Find(self.Data.SwitcherValue, Value)
    if Index == -1 then
      return 0
    end
    return Index - 1
  elseif type(Value) == "boolean" then
    return Value and 0 or 1
  elseif type(Value) == "number" then
    return Value - 1
  else
    return Value or 0
  end
end
function Setting_Option_Switcher:_IndexToValue(Idx)
  if self.Data.SwitcherValue then
    return self.Data.SwitcherValue[Idx + 1]
  else
    local CurrentValue = self.Data.GetFunc(self.Data.Key)
    if type(CurrentValue) == "boolean" then
      return Idx == 0
    else
      return Idx + 1
    end
  end
end
function Setting_Option_Switcher:_ToggleExpand(Index, bToExpand, bPostEvent)
  local SwitcherItemUI = self.UIRoot.Switcher:GetOption(Index)
  if not slua.isValid(SwitcherItemUI) then
    return
  end
  if SwitcherItemUI.Image_Arrow:GetVisibility() == ECollapsed then
    bToExpand = false
  end
  if bToExpand == nil then
    bToExpand = not (SwitcherItemUI.Image_Arrow.RenderTransform.Angle > 0)
  end
  SwitcherItemUI.Image_Arrow:SetRenderAngle(bToExpand and 90 or -90)
  if bPostEvent then
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SWITCHER_EXPAND, self.Data.Key, bToExpand)
  end
end
function Setting_Option_Switcher:GetSelectedIndex()
  return self.UIRoot.Switcher.SelectedIndex
end
function Setting_Option_Switcher:GetExpandState()
  if self.ExpandableMap then
    for idx, _ in pairs(self.ExpandableMap) do
      local SwitcherItemUI = self.UIRoot.Switcher:GetOption(idx)
      if slua.isValid(SwitcherItemUI) and SwitcherItemUI.Image_Arrow.RenderTransform.Angle > 0 then
        return true
      end
    end
    return false
  else
    return false
  end
end
function Setting_Option_Switcher:ReportTLOG(Value)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local LogStr = string.format("Option=%s,Value=%s", self.Data.Key, tostring(Value))
  print(bWriteLog and "Setting_Option_Switcher:ReportTLOG " .. LogStr)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.OptionSwitch, 0, LogStr)
end
local class = require("class")
local Setting_Item_Base = require("client.slua.umg.NewSetting.Item.Setting_Item_Base")
return class(Setting_Item_Base, nil, Setting_Option_Switcher)
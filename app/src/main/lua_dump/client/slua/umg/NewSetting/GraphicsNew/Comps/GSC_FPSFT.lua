local GSC_FPSFT = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
local ERenderQuality = import("ERenderQuality")
local KismetMathLibrary = import("KismetMathLibrary")
local FPSLevels120 = {
  90,
  95,
  100,
  105,
  110,
  115,
  120
}
local FPSLevels144 = {
  90,
  95,
  100,
  105,
  110,
  115,
  120,
  125,
  130,
  135,
  140,
  144
}
local FPSLevels165 = {
  90,
  95,
  100,
  105,
  110,
  115,
  120,
  125,
  130,
  135,
  140,
  144,
  150,
  155,
  160,
  165
}
local findNearestIndex = function(levels, value)
  local bestIdx = 1
  local bestDist = math.abs(levels[1] - value)
  for i = 2, #levels do
    local dist = math.abs(levels[i] - value)
    if bestDist > dist then
      bestDist = dist
      bestIdx = i
    end
  end
  return bestIdx
end
local interpolationState = false
local lerp = function(a, b, t)
  return a + (b - a) * t
end
local clamp = function(value, min, max)
  if value < min then
    return min
  end
  if max < value then
    return max
  end
  return value
end
local _getColorByPercent = function(start, finish, percent)
  local r = lerp(start.R, finish.R, percent)
  local g = lerp(start.G, finish.G, percent)
  local b = lerp(start.B, finish.B, percent)
  local a = lerp(start.A, finish.A, percent)
  return FLinearColor(r, g, b, a)
end
function GSC_FPSFT:ctor(_, name)
  self.end
function GSC_FPSFT:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.UTRichTextBlock_Full_Title:SetText(LocUtil.GetLocalizeResStr(200000251))
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(200000249))
  itemRoot.TextBlock_Title2:SetText(LocUtil.GetLocalizeResStr(200000249))
  itemRoot.TextBlock_Title3:SetText(LocUtil.GetLocalizeResStr(200000249))
  itemRoot.Setting_Switch.TextBlock_38:SetText(LocUtil.GetLocalizeResStr(200000291))
  itemRoot.Setting_Switch.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(200000291))
  itemRoot.Setting_Switch.TextBlock_27:SetText(LocUtil.GetLocalizeResStr(200000290))
  itemRoot.Setting_Switch.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(200000290))
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local bFrameInterpolation = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("t.EnableFrameInterpolation")
    interpolationState = 0 < bFrameInterpolation
    if interpolationState then
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_38:SetText(LocUtil.GetLocalizeResStr(200000291))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(200000291))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(200000291))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_27:SetText(LocUtil.GetLocalizeResStr(200000290))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(200000290))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_6:SetText(LocUtil.GetLocalizeResStr(200000290))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(200000593))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(200000593))
      itemRoot.Setting_ThreeSwitch_Item_UIBP.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(200000593))
      local TApmHelper = import("TApmHelper")
      local extraTable = {action = "isSupport"}
      local param = json.encode(extraTable)
      local s_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", param)
      log(bWriteLog and "GSC_FPSFT:GetDataFromTGPAFrameInterpolation isSupport return: " .. s_result)
      local isSupport = false
      if s_result ~= nil then
        local d_result = json.decode(s_result)
        if d_result ~= nil and type(d_result) == "table" and d_result.body ~= nil then
          for k, v in pairs(d_result.body) do
            if tonumber(k) == tonumber(d_result.code) then
              local t = json.decode(v)
              isSupport = t.isSupport == "true"
            end
          end
        end
      end
      log(bWriteLog and "GSC_FPSFT:GetDataFromTGPAFrameInterpolation isSupport state: " .. tostring(isSupport))
      self:SetWidgetVisible(itemRoot.Setting_Switch, not isSupport)
      self:SetWidgetVisible(itemRoot.Button_Switch, not isSupport, true)
      self:SetWidgetVisible(itemRoot.Setting_ThreeSwitch_Item_UIBP, isSupport)
      if isSupport then
        itemRoot.Setting_ThreeSwitch_Item_UIBP.Btn_AimAssist:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        itemRoot.Setting_ThreeSwitch_Item_UIBP.Button_0:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        itemRoot.Setting_ThreeSwitch_Item_UIBP.Button_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        log(bWriteLog and "GSC_FPSFT: FrameInterpolation Begin")
        local switchState = false
        local g_param = {
          action = "getSwitchState"
        }
        local g_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", json.encode(g_param))
        log(bWriteLog and "GSC_FPSFT: Get FrameInterpolation" .. tostring(g_result))
        local g_decoder = json.decode(g_result)
        if g_decoder ~= nil and g_decoder.body ~= nil then
          for k, v in pairs(g_decoder.body) do
            if tonumber(k) == tonumber(g_decoder.code) then
              local t = json.decode(v)
              switchState = t.switchState == "true"
            end
          end
        end
        if switchState then
          GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 2)
        else
          local Switch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
          if Switch then
            GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 0)
          else
            GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 1)
          end
        end
      end
    end
  end
end
function GSC_FPSFT:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_screen_add, "OnClicked", self.OnFPSFTAdd, self)
  self:AddControlEventByControl(itemRoot.Button_screen_minus, "OnClicked", self.OnFPSFTMinus, self)
  self:AddControlEventByControl(itemRoot.Button_screen_add2, "OnClicked", self.OnFPSFTAdd2, self)
  self:AddControlEventByControl(itemRoot.Button_screen_minus2, "OnClicked", self.OnFPSFTMinus2, self)
  self:AddControlEventByControl(itemRoot.Button_screen_add3, "OnClicked", self.OnFPSFTAdd3, self)
  self:AddControlEventByControl(itemRoot.Button_screen_minus3, "OnClicked", self.OnFPSFTMinus3, self)
  self:AddControlEventByControl(itemRoot.Slider_screen, "OnValueChanged", self.OnFPSFTSliderValueChange, self)
  self:AddControlEventByControl(itemRoot.Slider_screen2, "OnValueChanged", self.OnFPSFTSliderValueChange2, self)
  self:AddControlEventByControl(itemRoot.Slider_screen3, "OnValueChanged", self.OnFPSFTSliderValueChange3, self)
  self:AddControlEventByControl(itemRoot.Button_Switch, "OnClicked", self.OnClickFPSFTSwitch, self)
  self:AddControlEventByControl(itemRoot.Setting_ThreeSwitch_Item_UIBP.Btn_AimAssist, "OnClicked", self.OnButtonManual, self)
  self:AddControlEventByControl(itemRoot.Setting_ThreeSwitch_Item_UIBP.Button_0, "OnClicked", self.OnButtonSmart, self)
  self:AddControlEventByControl(itemRoot.Setting_ThreeSwitch_Item_UIBP.Button_1, "OnClicked", self.OnButtonAuto, self)
end
function GSC_FPSFT:OnAfterAllComponentsInitialized()
  if self.name == "FPSFT" then
    self:SubscribeNotFirstCallBack(GraphicSettingDB.GraphicFavor, function(old, value)
      self:ShowOrHide()
    end)
  end
  self:SubscribeNotFirstCallBack(GraphicSettingDB.SelectedFPS, function(old, value)
    self:ShowOrHide()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.FPSFineTuneSwitch, function(old, value)
    printf("GSC_FPSFT:Subscribe  FPSFineTuneSwitch = %s", value)
    self:ShowOrHide()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.CustomTab, function(old, value)
    self:ShowOrHide()
  end)
  self:ShowOrHide()
  if interpolationState then
    self:Subscribe(GraphicSettingDB.FPSAutoInterpolation, function(old, value)
      printf("GSC_FPSFT:Subscribe  FPSAutoInterpolation = %s", value)
      self:UpdateUI(value)
    end)
    local FPSAutoInterpolation = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSAutoInterpolation)
    if FPSAutoInterpolation ~= nil then
      self:UpdateUI(FPSAutoInterpolation)
    end
  end
end
function GSC_FPSFT:OnClickFPSFTSwitch()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.FPSFineTuneSwitch)
  self:GetParentUI():SetDirty(true)
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch)
end
function GSC_FPSFT:OnFPSFTAdd()
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneSwitch then
    self:PlayAudio(sound_config.click_v1)
    local idx = findNearestIndex(FPSLevels120, FPSFineTuneNum)
    idx = math.min(#FPSLevels120, idx + 1)
    self:OnFPSFTValueChange(FPSLevels120[idx])
  end
end
function GSC_FPSFT:OnFPSFTMinus()
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneSwitch then
    self:PlayAudio(sound_config.click_v1)
    local idx = findNearestIndex(FPSLevels120, FPSFineTuneNum)
    idx = math.max(1, idx - 1)
    self:OnFPSFTValueChange(FPSLevels120[idx])
  end
end
function GSC_FPSFT:OnFPSFTSliderValueChange(value)
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  if FPSFineTuneSwitch then
    local idx = math.max(1, math.min(#FPSLevels120, KismetMathLibrary.Round(value * (#FPSLevels120 - 1)) + 1))
    self:OnFPSFTValueChange(FPSLevels120[idx])
  end
end
function GSC_FPSFT:OnFPSFTValueChange(FPSFineTuneNum)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
  self:InitFPSFTValue()
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:OnFPSFTAdd2()
  self:PlayAudio(sound_config.click_v1)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneNum then
    local idx = findNearestIndex(FPSLevels144, FPSFineTuneNum)
    idx = math.min(#FPSLevels144, idx + 1)
    self:OnFPSFTValueChange2(FPSLevels144[idx])
  end
end
function GSC_FPSFT:OnFPSFTMinus2()
  self:PlayAudio(sound_config.click_v1)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneNum then
    local idx = findNearestIndex(FPSLevels144, FPSFineTuneNum)
    idx = math.max(1, idx - 1)
    self:OnFPSFTValueChange2(FPSLevels144[idx])
  end
end
function GSC_FPSFT:OnFPSFTSliderValueChange2(value)
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  if FPSFineTuneSwitch then
    local idx = math.max(1, math.min(#FPSLevels144, KismetMathLibrary.Round(value * (#FPSLevels144 - 1)) + 1))
    self:OnFPSFTValueChange2(FPSLevels144[idx])
  end
end
function GSC_FPSFT:OnFPSFTValueChange2(FPSFineTuneNum)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
  self:InitFPSFTValue144()
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:OnFPSFTAdd3()
  self:PlayAudio(sound_config.click_v1)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneNum then
    local idx = findNearestIndex(FPSLevels165, FPSFineTuneNum)
    idx = math.min(#FPSLevels165, idx + 1)
    self:OnFPSFTValueChange3(FPSLevels165[idx])
  end
end
function GSC_FPSFT:OnFPSFTMinus3()
  self:PlayAudio(sound_config.click_v1)
  local FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
  if FPSFineTuneNum then
    local idx = findNearestIndex(FPSLevels165, FPSFineTuneNum)
    idx = math.max(1, idx - 1)
    self:OnFPSFTValueChange3(FPSLevels165[idx])
  end
end
function GSC_FPSFT:OnFPSFTSliderValueChange3(value)
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  if FPSFineTuneSwitch then
    local idx = math.max(1, math.min(#FPSLevels165, KismetMathLibrary.Round(value * (#FPSLevels165 - 1)) + 1))
    self:OnFPSFTValueChange3(FPSLevels165[idx])
  end
end
function GSC_FPSFT:OnFPSFTValueChange3(FPSFineTuneNum)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
  self:InitFPSFTValue165()
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:ShowOrHide()
  local SelectedFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  printf("GSC_FPSFT:ShowOrHide SelectedFPS = %s, CustomTab = %s, SelectedQuality = %s, name = %s", SelectedFPS, CustomTab, SelectedQuality, self.name)
  if self.name == "FPSFT" then
    local GraphicFavor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
    local bShow = false
    if GraphicFavor == GraphicConst.FavorDef.FrameRate then
      local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicFavor)
      local BattleFPS = favorSetting.BattleFPS
      printf("GSC_FPSFT:ShowOrHide BattleFPS = %s", BattleFPS)
      if BattleFPS == GraphicConst.FPSLevelDef.FPS120 then
        bShow = true
      end
    end
    if bShow then
      self:SelfHitTestInvisible()
      self:InitFPSFTSwitch()
    else
      self:Collapsed()
    end
  elseif self.name == "FPSFT2" then
    if SelectedFPS == GraphicConst.FPSLevelDef.FPS120 and CustomTab == GraphicConst.CustomTabDef.Battle and (SelectedQuality == ERenderQuality.SMOOTH or SelectedQuality == ERenderQuality.VERYSMOOTH) then
      self:SelfHitTestInvisible()
      self:InitFPSFTSwitch()
    else
      self:Collapsed()
    end
  end
end
function GSC_FPSFT:InitFPSFTValue()
  local FPSFineTuneNum
  local itemRoot = self.UIRoot
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  local widgetSlider_screen = itemRoot.Slider_screen
  local widgetProgressBar_screen = itemRoot.ProgressBar_screen
  local widgetCurrentFPSValue = itemRoot.Veihclescreen
  if FPSFineTuneSwitch then
    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
    widgetSlider_screen:SetLocked(false)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
  else
    local gameInstance = slua_GameFrontendHUD:GetGameInstance()
    FPSFineTuneNum = gameInstance:GetDeviceRecommendFPS()
    widgetSlider_screen:SetLocked(true)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
  end
  local FPSFineTunePer = (FPSFineTuneNum - FPSLevels120[1]) / (FPSLevels120[#FPSLevels120] - FPSLevels120[1])
  widgetCurrentFPSValue:SetText(LocUtil.LocalizeResFormat(10567, FPSFineTuneNum))
  widgetSlider_screen:SetValue(FPSFineTunePer)
  widgetProgressBar_screen:SetPercent(FPSFineTunePer)
end
function GSC_FPSFT:InitFPSFTValue144()
  local FPSFineTuneNum
  local itemRoot = self.UIRoot
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  local widgetSlider_screen = itemRoot.Slider_screen2
  local widgetProgressBar_screen = itemRoot.ProgressBar_screen2
  local widgetCurrentFPSValue = itemRoot.Veihclescreen2
  if FPSFineTuneSwitch then
    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
    widgetSlider_screen:SetLocked(false)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
  else
    local gameInstance = slua_GameFrontendHUD:GetGameInstance()
    FPSFineTuneNum = gameInstance:GetDeviceRecommendFPS()
    widgetSlider_screen:SetLocked(true)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
  end
  local FPSFineTunePer = (FPSFineTuneNum - FPSLevels144[1]) / (FPSLevels144[#FPSLevels144] - FPSLevels144[1])
  widgetCurrentFPSValue:SetText(LocUtil.LocalizeResFormat(10567, FPSFineTuneNum))
  widgetSlider_screen:SetValue(FPSFineTunePer)
  widgetProgressBar_screen:SetPercent(FPSFineTunePer)
  local curPercent = FPSFineTunePer
  local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
  local endColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
  local sliderColor
  if curPercent < 0.55 then
    sliderColor = startColor
  else
    sliderColor = _getColorByPercent(startColor, endColor, (curPercent - 0.55) / 0.45)
  end
  widgetSlider_screen:SetSliderHandleColor(sliderColor)
end
function GSC_FPSFT:InitFPSFTValue165()
  local FPSFineTuneNum
  local itemRoot = self.UIRoot
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  local widgetSlider_screen = itemRoot.Slider_screen3
  local widgetProgressBar_screen = itemRoot.ProgressBar_screen3
  local widgetCurrentFPSValue = itemRoot.Veihclescreen3
  if FPSFineTuneSwitch then
    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
    widgetSlider_screen:SetLocked(false)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
  else
    local gameInstance = slua_GameFrontendHUD:GetGameInstance()
    FPSFineTuneNum = gameInstance:GetDeviceRecommendFPS()
    widgetSlider_screen:SetLocked(true)
    widgetProgressBar_screen:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
    widgetSlider_screen:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
  end
  local FPSFineTunePer = (FPSFineTuneNum - FPSLevels165[1]) / (FPSLevels165[#FPSLevels165] - FPSLevels165[1])
  widgetCurrentFPSValue:SetText(LocUtil.LocalizeResFormat(10567, FPSFineTuneNum))
  widgetSlider_screen:SetValue(FPSFineTunePer)
  widgetProgressBar_screen:SetPercent(FPSFineTunePer)
  local curPercent = FPSFineTunePer
  local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
  local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
  local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
  local sliderColor
  if curPercent < 0.4 then
    sliderColor = startColor
  else
    sliderColor = _getColorByPercent(midColor, endColor, (curPercent - 0.4) / 0.6)
  end
  widgetSlider_screen:SetSliderHandleColor(sliderColor)
end
function GSC_FPSFT:UpdateUI(frameVal)
  log(bWriteLog and "GSC_FPSFT:UpdateUI: " .. frameVal)
  local itemRoot = self.UIRoot
  if frameVal == 0 then
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.WidgetSwitcher_Bg:SetActiveWidgetIndex(0)
  elseif frameVal == 1 then
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_6:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.WidgetSwitcher_Bg:SetActiveWidgetIndex(1)
  elseif frameVal == 2 then
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_6:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.CanvasPanel_4:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemRoot.Setting_ThreeSwitch_Item_UIBP.WidgetSwitcher_Bg:SetActiveWidgetIndex(2)
  end
end
function GSC_FPSFT:InitFPSFTSwitch()
  local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local maxSupportFPS = gameInstance:GetDeviceMaxFPSByDeviceLevel(ERenderQuality.SMOOTH)
  printf("GSC_FPSFT:InitFPSFTValue maxSupportFPS: %s", maxSupportFPS)
  if maxSupportFPS == 144 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self:InitFPSFTValue144()
  elseif maxSupportFPS == 165 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    self:InitFPSFTValue165()
  elseif maxSupportFPS <= 120 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self:InitFPSFTValue()
  end
end
function GSC_FPSFT:OnButtonManual()
  log(bWriteLog and "GSC_FPSFT:OnButtonManual")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 0)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneSwitch, true)
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:OnButtonSmart()
  log(bWriteLog and "GSC_FPSFT:OnButtonSmart")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneSwitch, false)
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:OnButtonAuto()
  log(bWriteLog and "GSC_FPSFT:OnButtonAuto")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSAutoInterpolation, 2)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneSwitch, false)
  self:GetParentUI():SetDirty(true)
end
function GSC_FPSFT:GetAutoInterpolation()
  local state = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSAutoInterpolation)
  return state == 3
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_FPSFT)
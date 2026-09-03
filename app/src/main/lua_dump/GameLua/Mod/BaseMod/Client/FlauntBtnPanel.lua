local FlauntBtnPanel = {}
local UIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local KismetMathLibrary = import("KismetMathLibrary")
local Config = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig")
function FlauntBtnPanel:ctor()
  print(bWriteLog and "FlauntBtnPanel:ctor")
  self.nShinningTime = 5
  self.nBrightTime = 120
  self.nShowingTime = 300
end
function FlauntBtnPanel:OnInitialize()
  print(bWriteLog and "FlauntBtnPanel:OnInitialize")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    self:AttachToPanel(MainControlBaseUI.Emote_SpectatingControl)
  end
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0.0, 0, 0, 0)
  self:SetAlignment(0, 0)
  self:SetZOrder(-10)
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  FlauntBtnPanel.__super.OnInitialize(self)
end
function FlauntBtnPanel:RegistEvents()
  print(bWriteLog and "FlauntBtnPanel:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_FLAUNTBTN_OUT_FORCE_CLOSE, self.OnOutClose, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_FLAUNTBTN_OUT_FORCE_CLOSE_OVER, self.OnOutCloseOver, self)
  self:AddControlEventByControl(self.UIRoot.Button_Flaunt, "OnClicked", self.OnButtonFlaunt, self)
  self:AddControlEventByControl(self.UIRoot.Button_Flaunt_02, "OnClicked", self.OnWeaponFlauntButtonClicked, self)
end
function FlauntBtnPanel:OnOutClose()
  print(bWriteLog and "FlauntBtnPanel:OnOutClose")
  if slua.isValid(self.UIRoot) then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function FlauntBtnPanel:OnOutCloseOver()
  print(bWriteLog and "FlauntBtnPanel:OnOutCloseOver")
  if slua.isValid(self.UIRoot) then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function FlauntBtnPanel:OnButtonFlaunt()
  print(bWriteLog and "FlauntBtnPanel:OnButtonFlaunt")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAY_HIGHLIGHT_MOMENT)
end
function FlauntBtnPanel:OnWeaponFlauntButtonClicked()
  print(bWriteLog and "FlauntBtnPanel:OnWeaponFlauntButtonClicked")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLAY_WEAPON_HIGHLIGHT_MOMENT)
end
function FlauntBtnPanel:RefreshUI(Num)
  print(bWriteLog and "FlauntBtnPanel:RefreshUI", Num)
  if not slua.isValid(self.UIRoot) then
    return
  end
  if Num == 0 then
    self.UIRoot:StopAnimation(self.UIRoot.loop)
    self.UIRoot.Border_Flaunt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif Num == 1 then
    self.UIRoot.Border_Flaunt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Flaunt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Border_Flaunt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Flaunt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Flaunt:SetText("x" .. Num)
  end
  self:RemoveTimers()
end
function FlauntBtnPanel:RefreshWeaponUI(bVisible)
  print(bWriteLog and "FlauntBtnPanel:RefreshWeaponUI")
  if not slua.isValid(self.UIRoot) then
    print(bWriteLog and "FlauntBtnPanel:RefreshWeaponUI not valid")
    return
  end
  if not bVisible then
    self.UIRoot.Border_Flaunt_02:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Border_Flaunt_02:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Flaunt_02:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:RemoveWeaponTimers()
end
function FlauntBtnPanel:ReleaseWeaponUIHint()
  print(bWriteLog and "FlauntBtnPanel:FadeWeaponUI")
  if not slua.isValid(self.UIRoot) then
    return
  end
  if self.UIRoot.Border_Flaunt_02:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
    return
  end
  if self.WeaponStartLoopTimer then
    self:RemoveGameTimer(self.WeaponStartLoopTimer)
    self.WeaponStartLoopTimer = nil
  end
  if self.WeaponBrightTimer then
    self:RemoveGameTimer(self.WeaponBrightTimer)
    self.WeaponBrightTimer = nil
  end
  self.UIRoot.WidgetSwitcher_Icon_02:SetActiveWidgetIndex(1)
end
function FlauntBtnPanel:RemoveTimers()
  if self.ShinningTimer then
    self:RemoveGameTimer(self.ShinningTimer)
    self.ShinningTimer = nil
  end
  if self.BrightTimer then
    self:RemoveGameTimer(self.BrightTimer)
    self.BrightTimer = nil
  end
  if self.ShowingTimer then
    self:RemoveGameTimer(self.ShowingTimer)
    self.ShowingTimer = nil
  end
  if self.StartLoopTimer then
    self:RemoveGameTimer(self.StartLoopTimer)
    self.StartLoopTimer = nil
  end
end
function FlauntBtnPanel:RemoveWeaponTimers()
  if self.WeaponStartLoopTimer then
    self:RemoveGameTimer(self.WeaponStartLoopTimer)
    self.WeaponStartLoopTimer = nil
  end
  if self.WeaponBrightTimer then
    self:RemoveGameTimer(self.WeaponBrightTimer)
    self.WeaponBrightTimer = nil
  end
  if self.WeaponShowingTimer then
    self:RemoveGameTimer(self.WeaponShowingTimer)
    self.WeaponShowingTimer = nil
  end
end
function FlauntBtnPanel:ResetShinningTime(Type)
  print(bWriteLog and "FlauntBtnPanel:ResetShinningTime", Type)
  if not slua.isValid(self.UIRoot) then
    return
  end
  self:RemoveTimers()
  self.UIRoot.WidgetSwitcher_Icon:SetActiveWidgetIndex(0)
  local delayTime = 3
  local IconPath, TipsText
  local bShowTips = true
  if Config[Type] then
    IconPath = Config[Type].IconPath or Config[Type].BadgePath
    TipsText = Config[Type].TipsText or Config[Type].NameID
    bShowTips = Config[Type].bShowTips ~= false
  end
  if IconPath and TipsText and bShowTips then
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    print(bWriteLog and "FlauntBtnPanel:ResetShinningTime", TipsText, bShowTips)
    self:SetTexture(self.UIRoot.Image_icon, IconPath)
    self.UIRoot.TextBlock_KillInfo:SetText(LocUtil.GetLocalizeResStr(TipsText))
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Tips_In, 0, 1, 0, 1)
  else
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    delayTime = 1
    self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
  end
  self.StartLoopTimer = self:AddGameTimer(delayTime, false, function()
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:PlayUserWidgetAnimation(self.UIRoot.loop, 0, 30, 0, 1)
  end)
  self.ShinningTimer = self:AddGameTimer(self.nShinningTime, false, function()
    self.UIRoot:StopAnimation(self.UIRoot.loop)
  end)
  self.BrightTimer = self:AddGameTimer(self.nBrightTime, false, function()
    self.UIRoot.WidgetSwitcher_Icon:SetActiveWidgetIndex(1)
  end)
  self.ShowingTimer = self:AddGameTimer(self.nShowingTime, false, function()
    self:RefreshUI(0)
  end)
end
function FlauntBtnPanel:ResetWeaponShinningTime()
  print(bWriteLog and "FlauntBtnPanel:ResetWeaponShinningTime")
  if not slua.isValid(self.UIRoot) then
    print(bWriteLog and "FlauntBtnPanel:ResetWeaponShinningTime not valid")
    return
  end
  self:RemoveWeaponTimers()
  self.UIRoot.WidgetSwitcher_Icon_02:SetActiveWidgetIndex(0)
  if Config[7] and Config[7].IconPath and Config[7].TipsText then
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self:SetTexture(self.UIRoot.Image_icon, Config[7].IconPath)
    self.UIRoot.TextBlock_KillInfo:SetText(LocUtil.GetLocalizeResStr(Config[7].TipsText))
    self.WeaponStartLoopTimer = self:AddGameTimer(3, false, function()
      self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
  end
  self.WeaponBrightTimer = self:AddGameTimer(self.nBrightTime, false, function()
    self.UIRoot.WidgetSwitcher_Icon_02:SetActiveWidgetIndex(1)
  end)
  self.WeaponShowingTimer = self:AddGameTimer(self.nShowingTime, false, function()
    self:RefreshWeaponUI(false)
  end)
end
function FlauntBtnPanel:OnConsumeHighlightMoment(_, _, Type)
  print(bWriteLog and "FlauntBtnPanel:OnConsumeHighlightMoment", Type)
  if Type then
    self.CurHighlightList[Type] = nil
  end
  self:RefreshUI()
end
function FlauntBtnPanel:OnConsumeWeaponHighlightMoment(_, _, Type)
  print(bWriteLog and "FlauntBtnPanel:OnConsumeWeaponHighlightMoment", Type)
  self:RefreshWeaponUI(false)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, FlauntBtnPanel)
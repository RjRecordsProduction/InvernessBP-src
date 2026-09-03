local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CommonLogoUI = {}
function CommonLogoUI:ctor()
  self.HideUITimerHandler = nil
end
function CommonLogoUI:RegistEvents()
  CommonLogoUI.__super.RegistEvents(self)
  self:AddUIMessageEvent("MainControlPanel_ShowWinnerTimePanel", self.OnShowWinnerTimePanel, self)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_42 then
    self:AttachToPanel(MainControlBaseUI.CanvasPanel_42)
    self:SetZOrder(-1)
    self:SetAnchors(0, 0, 0, 0)
    local PlayerController = GameplayData.GetPlayerController()
    local PosX = self:GetPosXConfig()
    if PosX == nil then
      PosX = 222.753616
    end
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if DevicePlatformNameMacros.IsPC() then
      PosX = 340
    end
    print(bWriteLog and string.format("CommonLogoUI:RegistEvents DevicePlatformName=%s, PosX=%s, self.PosXConfig=%s", Client.GetDevicePlatformName(), tostring(PosX), tostring(self:GetPosXConfig())))
    self:SetPosition(PosX, 3)
    self:SetAutoSize(true)
    self.UIRoot:UpdateUI(false)
  end
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.LogoBtn_UIBP then
    self:AddControlEventByControl(MainControlPanelTochButton.LogoBtn_UIBP, "ED_CrouchBtnTouchStart", self.OnLogoBtnPress, self)
    self:AddControlEventByControl(MainControlPanelTochButton.LogoBtn_UIBP, "ED_CrouchBtnTouchEnd", self.OnLogoBtnRelease, self)
  end
  if Client.IsWindowOB() then
    self.UIRoot:SetRenderTranslation(FVector2D(20, 0))
  end
end
function CommonLogoUI:GetPosXConfig()
  return 222.753616
end
function CommonLogoUI:OnShowWinnerTimePanel()
  self.UIRoot:UpdateUI(false)
end
function CommonLogoUI:OnLogoBtnPress()
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if TransparentUIModeSubsystem and not TransparentUIModeSubsystem:GetIsHideUIFunctionOpen() then
    TransparentUIModeSubsystem:ForceShowUI()
    return
  end
  if self.HideUITimerHandler then
    self:RemoveGameTimer(self.HideUITimerHandler)
    self.HideUITimerHandler = nil
  end
  self.HideUITimerHandler = self:AddGameTimer(2, false, function()
    self.HideUITimerHandler = nil
    self:ShowCountDown()
  end)
end
function CommonLogoUI:OnLogoBtnRelease()
  if self.HideUITimerHandler then
    self:RemoveGameTimer(self.HideUITimerHandler)
    self.HideUITimerHandler = nil
  end
  local LogoGuideUI = self:TryGetOrCreateLogoGuideUI(false)
  if not LogoGuideUI then
    return
  end
  LogoGuideUI:OnLogoBtnRelease()
end
function CommonLogoUI:ShowCountDown()
  local LogoGuideUI = self:TryGetOrCreateLogoGuideUI(true)
  if not LogoGuideUI then
    return
  end
  LogoGuideUI:ShowCountDown()
end
function CommonLogoUI:TryGetOrCreateLogoGuideUI(bCreate)
  local LogoGuideUI = UIManager.GetUI(UIManager.UI_Config_InGame.LogoGuideUI)
  if not LogoGuideUI and bCreate then
    LogoGuideUI = UIManager.ShowUI(UIManager.UI_Config_InGame.LogoGuideUI)
  end
  return LogoGuideUI
end
function CommonLogoUI:OnPressedLogoButton()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PRESSED_LOGO_BUTTON)
end
function CommonLogoUI:OnReleasedLogoButton()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_RELEASED_LOGO_BUTTON)
end
function CommonLogoUI:SetLogoImageVisibility(bShow)
  print(bWriteLog and "CommonLogoUI:SetLogoImageVisibility " .. tostring(bShow))
  if self.UIRoot.ImageLogo then
    if bShow then
      self.UIRoot.ImageLogo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.ImageLogo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    print(bWriteLog and "CommonLogoUI:SetLogoImageVisibility ImageLogo Not Exists. Is this UI overriden?")
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, CommonLogoUI)
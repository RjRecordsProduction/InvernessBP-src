local Lobby_Main_Wifi_UIBP = {}
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local PandoraSystem = require("client.slua.logic.Pandora.pandora_system")
local TimeUtil = require("client.common.time_util")
function Lobby_Main_Wifi_UIBP:ctor(selfType, isSimpleUI)
  self.isSimpleUI = isSimpleUI or false
  self.bLastBatteryStateCharging = false
  self.GreenColor = FLinearColor(0.15, 0.52, 0.076, 1.0)
  self.OrangeColor = FLinearColor(1.0, 0.6, 0.0, 1.0)
  self.RedColor = FLinearColor(1.0, 0.0, 0.0, 1.0)
end
function Lobby_Main_Wifi_UIBP:OnInitialize()
  Lobby_Main_Wifi_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.ProgressBar_Battery = self.UIRoot.ProgressBar_Battery
  self.Image_Charge = self.UIRoot.Image_Charge
  self.WidgetSwitcher_Network = self.UIRoot.WidgetSwitcher_Network
  self.WidgetSwitcher_WIFI = self.UIRoot.WidgetSwitcher_WIFI
  self.WidgetSwitcher_Signal = self.UIRoot.WidgetSwitcher_Signal
  self.Image_xunyou = self.UIRoot.Image_xunyou
  self.CanvasPanel_BanMatch = self.UIRoot.CanvasPanel_BanMatch
end
function Lobby_Main_Wifi_UIBP:RegistEvents()
  Lobby_Main_Wifi_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_ZONE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PHONE_STATE, EVENTID_INGAME_PHONE_STATE_ART_QUALITY, self.UpdateQuality, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_CHANGE_TIME_DISPLAY, self.UpdateCurGameTime, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_RISK_READED, self.HideAccountRisk, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_RISK_RSP, self.UpdateAccountRisk, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BanMatch, self.OnClickBanMatch, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AccountRisk, self.OnClickAccountRisk, self)
end
function Lobby_Main_Wifi_UIBP:OnPostInitialize()
  Lobby_Main_Wifi_UIBP.__super.OnPostInitialize(self)
  local OMobileFBPL = import("OMobileFBPL")
  self.bLastBatteryStateCharging = OMobileFBPL.IsBatteryStateCharging()
  self.batteryTimerHandle = self:AddTimerLoop(0, function()
    self:UpdateBatteryLevel()
  end, TIMER_INFINITE, 15)
  self.batteryChargeTimerHandle = self:AddTimerLoop(0, function()
    if slua.isValid(self.UIRoot) then
      self:UpdateBatteryCharge()
    end
  end, TIMER_INFINITE, 3)
  self.networkTimerHandle = self:AddTimerLoop(0, function()
    if slua.isValid(self.UIRoot) then
      self:UpdateConnectionStatus()
    end
  end, TIMER_INFINITE, 5)
  self.curGameTimeTimerHandler = self:AddTimerLoop(0, function()
    if slua.isValid(self.UIRoot) then
      self:UpdateCurGameTime()
    end
  end, TIMER_INFINITE, 60)
  self:AddReportSelfPingTimer()
  self:UpdateUI()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self.cameraAdapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  self:AddTimerLoop(0, function()
    if self.cameraAdapt ~= Lobby_camera_manager_module:GetCurrentCameraRatio() then
      self.cameraAdapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
      local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
      Lobby_Main_Control.ComputeCameraInfo_Once()
    end
  end, TIMER_INFINITE, 2)
end
function Lobby_Main_Wifi_UIBP:UpdateUI()
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Quality, self.isSimpleUI ~= true)
  self:SetWidgetVisible(self.UIRoot.TextBlock_CurTime, self.isSimpleUI ~= true)
  self:SetWidgetVisible(self.UIRoot.TextBlock_Zone, self.isSimpleUI ~= true)
  self:UpdateBatteryLevel()
  self:UpdateBatteryCharge()
  self:UpdateConnectionStatus()
  self:UpdateXunyouStatus()
  self:UpdateBanMatch()
  self:UpdateQuality()
  self:UpdateAccountRisk()
end
function Lobby_Main_Wifi_UIBP:UpdateQuality()
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local ERenderQuality = import("ERenderQuality")
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local renderQuality = userSettings.LobbyRenderQuality
  printf("Lobby_Main_Wifi_UIBP:UpdateQuality debugRenderQuality renderQuality: %d", renderQuality)
  if userSettings.GraphicFavor == 0 then
    local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
    logic_setting_graphics.GenerateSeparatedGraphicsSettings()
    local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
    local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicConst.FavorDef.Balance)
    renderQuality = favorSetting.LobbyRenderQuality
    printf("Lobby_Main_Wifi_UIBP:UpdateQuality  change to favor default setting renderQuality: %d", renderQuality)
  end
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  if not gameInstance:IsSupportSwitchRenderLevelRuntime() then
    renderQuality = userSettings.BattleRenderQuality
    local logic_setting = require("client.logic.setting.logic_setting")
    local lastSettingLocalCache = logic_setting.GetQualitySetting() or 1
    if lastSettingLocalCache == ERenderQuality.VERYSMOOTH then
      renderQuality = ERenderQuality.VERYSMOOTH
    end
  end
  self.UIRoot.WidgetSwitcher_Quality:SetActiveWidgetIndex(0)
  self.UIRoot.TextBlock_High:SetText(GraphicHelperUtil.GetQualityText(renderQuality))
end
function Lobby_Main_Wifi_UIBP:UpdateBatteryLevel()
  if not self.ProgressBar_Battery then
    return
  end
  local OMobileFBPL = import("OMobileFBPL")
  if OMobileFBPL.GetBatteryLevel == nil then
    return
  end
  local BatteryLevel = OMobileFBPL.GetBatteryLevel()
  self.ProgressBar_Battery:SetPercent(BatteryLevel / 100)
  if self.ProgressBar_Battery.SetFillColorAndOpacity then
    if 60 <= BatteryLevel then
      self.ProgressBar_Battery:SetFillColorAndOpacity(self.GreenColor)
    elseif 20 <= BatteryLevel then
      self.ProgressBar_Battery:SetFillColorAndOpacity(self.OrangeColor)
    else
      self.ProgressBar_Battery:SetFillColorAndOpacity(self.RedColor)
    end
  end
end
function Lobby_Main_Wifi_UIBP:UpdateBatteryCharge()
  if not self.Image_Charge then
    return
  end
  local OMobileFBPL = import("OMobileFBPL")
  local bBatteryStateCharging = OMobileFBPL.IsBatteryStateCharging()
  if bBatteryStateCharging then
    self.Image_Charge:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Charge:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if bBatteryStateCharging ~= self.bLastBatteryStateCharging then
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_BATTERY_CHARGING_STATE_CHANGE, bBatteryStateCharging)
    self.bLastBatteryStateCharging = bBatteryStateCharging
  end
end
function Lobby_Main_Wifi_UIBP:UpdateConnectionStatus()
  if not self.UIRoot then
    return
  end
  local delay = logic_zone_delay.GetChoosenZoneDelay(10000, 10000)
  local hasNetwork = delay < 10000 and delay ~= 0
  if hasNetwork then
    local connectSpeedLevel = 0
    if delay <= 200 then
      connectSpeedLevel = 2
    elseif delay <= 500 then
      connectSpeedLevel = 1
    else
      connectSpeedLevel = 0
    end
    if Client.HasActiveWifi() then
      self.WidgetSwitcher_Network:SetActiveWidgetIndex(0)
      self.WidgetSwitcher_WIFI:SetActiveWidgetIndex(connectSpeedLevel)
    else
      self.WidgetSwitcher_Network:SetActiveWidgetIndex(1)
      self.WidgetSwitcher_Signal:SetActiveWidgetIndex(connectSpeedLevel)
    end
  else
    local isConnecting = delay == 0
    if isConnecting then
      self.WidgetSwitcher_Network:SetActiveWidgetIndex(3)
    else
      self.WidgetSwitcher_Network:SetActiveWidgetIndex(2)
    end
  end
  local zoneID = ZoneSystem.nChooseZoneID
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  self.UIRoot.TextBlock_Zone:SetText(logic_multiple_area:GetDisplayNameByZoneID(zoneID))
end
function Lobby_Main_Wifi_UIBP:AddReportSelfPingTimer()
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  local cd = logic_team_zone_ping:GetPingSycnCD()
  self:AddTimerLoop(0, function()
    logic_team_zone_ping:ReportSelfPing()
  end, 0, cd)
end
function Lobby_Main_Wifi_UIBP:UpdateCurGameTime()
  local sGameTimeStr = ""
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    sGameTimeStr = TimeUtil.FormatTime_YMDHM(TimeUtil.GetServerTimeInSec(), true, false)
  else
    sGameTimeStr = TimeUtil.FormatTime_YMDHM(TimeUtil.GetServerTimeInSec(), false, true)
  end
  local version = Client.GetAppVersion()
  self.UIRoot.TextBlock_CurTime:SetText(version .. " " .. sGameTimeStr)
end
function Lobby_Main_Wifi_UIBP:UpdateXunyouStatus()
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  local isXunYouOpen = AccelSystem.IsServerEnableAccel() and AccelSystem.IsLocalEnableAccel()
  if isXunYouOpen then
    self.Image_xunyou:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_xunyou:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_Wifi_UIBP:UpdateBanMatch()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.IsMatchInBanList() then
    self.CanvasPanel_BanMatch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:HideBanMatch()
  end
end
function Lobby_Main_Wifi_UIBP:HideBanMatch()
  self.CanvasPanel_BanMatch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Main_Wifi_UIBP:OnClickBanMatch()
  self:PlayAudio(sound_config.click)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local content = MatchSystem.GetMatchBanTip()
  local UIUtil = require("client.common.ui_util")
  local tipPos = UIUtil.GetWidgetViewportPos(self.CanvasPanel_BanMatch)
  local helpTipsUI = UIManager.ShowUI(UIManager.UI_Config.Common_HelpTips_UIBP)
  if helpTipsUI then
    helpTipsUI:ShowPanelStrWithPos(content, tipPos.X + 50, tipPos.Y, true, true)
  end
end
function Lobby_Main_Wifi_UIBP:UpdateAccountRisk()
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  local noticeInfo = logic_account_protect_setting:GetNoticeInfo()
  local isGray = logic_account_protect_setting:GetIsGray()
  local isClickGo = logic_account_protect_setting:GetIsClickGo()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_AccountRisk, not isClickGo and isGray and noticeInfo.iNoticeType and noticeInfo.iNoticeType ~= 0)
end
function Lobby_Main_Wifi_UIBP:HideAccountRisk()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_AccountRisk, false)
end
function Lobby_Main_Wifi_UIBP:OnClickAccountRisk()
  self:PlayAudio(sound_config.click_v1)
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  logic_account_protect_setting:SetIsClickGo(true, 1)
  local common_config = require("client.slua.common.common_config")
  if not common_config:IsBlockingPopupTip() then
    UIManager.ShowUI(UIManager.UI_Config.Setting_AccountSecurityTips_Popup_UIBP)
  end
end
function Lobby_Main_Wifi_UIBP:UpdateFuncHint()
  local zoneStr = ZoneSystem.FormatZonePrintString()
  if zoneStr ~= "" then
    self:SetWidgetVisible(self.UIRoot.TextBlock_2, true)
    self.UIRoot.TextBlock_2:SetText(string.format("%s", zoneStr))
  else
    self:SetWidgetVisible(self.UIRoot.TextBlock_2, false)
    self.UIRoot.TextBlock_2:SetText("")
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Main_Wifi_UIBP = class(ui_base, nil, Lobby_Main_Wifi_UIBP)
return CLobby_Main_Wifi_UIBP
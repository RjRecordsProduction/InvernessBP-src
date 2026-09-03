local IngamePhoneStateUI = {
  ConfigTickTime = 3,
  NetUnstableConfigs = {
    Enabled = false,
    SupportSubMods = {},
    SupportMainMods = {},
    PingUnstableAbsThreshold = 300,
    PingUnstableJumpThreshold = 200,
    PingUnstableJumpTimesThreshold = 1,
    RecentPingBucketSize = 5,
    PingBucketThreshold = 3,
    NetLostPickSeconds = 2,
    NetLostConfigs = {
      [9999] = {InLostRateFactor = 10, OutLostRateFactor = 10}
    },
    UnstableFlagKeepCycles = 2
  },
  NetUnstableData = {
    HasInitialized = false,
    CurPingBucketIndex = 1,
    RecentPingBucket = {},
    RecentPingBucketTimeStamp = {},
    CurCycle = 0,
    LastUnstableCycle = -1000
  }
}
function IngamePhoneStateUI:ctor()
  self.curTickCountDownTime = IngamePhoneStateUI.ConfigTickTime
  self.lastUpdateArtQuality = nil
  self.curRecordPingTimes = 0
  self.lastRecordPing = 20
  self.BatteryState = -1
  self.bIsCharging = false
  self.playerPingSignal = -1
  self.bHasActiveWiFiConnection = -1
  self.bIsNetUnstable = false
  self.CurrentRound = 0
end
function IngamePhoneStateUI:OnInitialize()
  IngamePhoneStateUI.__super.OnInitialize(self)
  self:InitUI()
end
function IngamePhoneStateUI:RegistEvents()
  IngamePhoneStateUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PHONE_STATE, EVENTID_INGAME_PHONE_STATE_ART_QUALITY, self.UpdateArtQualityUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_ALL_UI, self.ShowSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.HideSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_ON_EXIT_SELFIE, self.SelfHitTestInvisible, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_CAMERA_OPEN, self.Collapsed, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE, self.Collapsed, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE, self.SelfHitTestInvisible, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_SPECTATING_UI, self.ShowSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_LEAVE_SPECTATING_STATUS, self.ShowSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_WINNER_TIME_PANEL, self.ShowSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_WINNER_TIME_PANEL, self.HideSelfUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_COMPLETE_PLAYBACK_UI, self.ShowSelfUI, self)
  self:AddGameTimer(0.2, true, function()
    self:TickInternal(0.2)
  end)
  self:InitNetUnstableConfigs()
end
function IngamePhoneStateUI:InitNetUnstableConfigs()
  local BattlePingExUnstableConfig = HDmpveRemote.HDmpveRemoteConfigGetString("BattlePingExUnstableConfig", "")
  if BattlePingExUnstableConfig ~= nil and 0 < #BattlePingExUnstableConfig then
    log(bWriteLog and "InitNetUnstableConfigs, CfgString:" .. BattlePingExUnstableConfig)
    IngamePhoneStateUI.NetUnstableConfigs.SupportSubMods = {}
    IngamePhoneStateUI.NetUnstableConfigs.SupportMainMods = {}
    local StringUtil = require("common.string_util")
    local MainParams = StringUtil.Split(BattlePingExUnstableConfig, ";")
    local MainParamLen = #MainParams
    if 0 < MainParamLen then
      local UnstableFlagKeepCyclesCfg = tonumber(MainParams[1])
      IngamePhoneStateUI.NetUnstableConfigs.UnstableFlagKeepCycles = UnstableFlagKeepCyclesCfg
      if 0 < UnstableFlagKeepCyclesCfg then
        IngamePhoneStateUI.NetUnstableConfigs.Enabled = true
      else
        IngamePhoneStateUI.NetUnstableConfigs.Enabled = false
      end
      log(bWriteLog and "InitNetUnstableConfigs, Enabled:" .. tostring(IngamePhoneStateUI.NetUnstableConfigs.Enabled))
      log(bWriteLog and "InitNetUnstableConfigs, UnstableFlagKeepCycles:" .. tostring(UnstableFlagKeepCyclesCfg))
    end
    if 2 < MainParamLen then
      local SubParamPing = StringUtil.Split(MainParams[2], ",")
      if #SubParamPing == 4 then
        local PingUnstableAbsThresholdCfg = tonumber(SubParamPing[1])
        local PingUnstableJumpThresholdCfg = tonumber(SubParamPing[2])
        local PingUnstableJumpTimesThresholdCfg = tonumber(SubParamPing[3])
        local RecentPingBucketSizeCfg = tonumber(SubParamPing[4])
        if 0 < PingUnstableAbsThresholdCfg and 0 < PingUnstableJumpThresholdCfg and 0 < PingUnstableJumpTimesThresholdCfg and 0 < RecentPingBucketSizeCfg then
          IngamePhoneStateUI.NetUnstableConfigs.PingUnstableAbsThreshold = PingUnstableAbsThresholdCfg
          IngamePhoneStateUI.NetUnstableConfigs.PingUnstableJumpThreshold = PingUnstableJumpThresholdCfg
          IngamePhoneStateUI.NetUnstableConfigs.PingUnstableJumpTimesThreshold = PingUnstableJumpTimesThresholdCfg
          IngamePhoneStateUI.NetUnstableConfigs.RecentPingBucketSize = RecentPingBucketSizeCfg
          log(bWriteLog and "InitNetUnstableConfigs, PingUnstableAbsThreshold:" .. tostring(PingUnstableAbsThresholdCfg) .. ", PingUnstableJumpThreshold:" .. tostring(PingUnstableJumpThresholdCfg) .. ", PingUnstableJumpTimesThreshold:" .. tostring(PingUnstableJumpTimesThresholdCfg) .. ", RecentPingBucketSize:" .. tostring(RecentPingBucketSizeCfg))
        end
      end
      local SubParamLostRate = StringUtil.Split(MainParams[3], ",")
      if #SubParamLostRate == 3 then
        local NetLostPickSecondsCfg = tonumber(SubParamLostRate[1])
        local InLostRateFactorCfg = tonumber(SubParamLostRate[2])
        local OutLostRateFactorCfg = tonumber(SubParamLostRate[3])
        if 0 < NetLostPickSecondsCfg and 0 < InLostRateFactorCfg and 0 < OutLostRateFactorCfg then
          IngamePhoneStateUI.NetUnstableConfigs.NetLostPickSeconds = NetLostPickSecondsCfg
          IngamePhoneStateUI.NetUnstableConfigs.NetLostConfigs[9999].InLostRateFactor = InLostRateFactorCfg
          IngamePhoneStateUI.NetUnstableConfigs.NetLostConfigs[9999].OutLostRateFactor = OutLostRateFactorCfg
          log(bWriteLog and "InitNetUnstableConfigs, NetLostPickSeconds:" .. tostring(NetLostPickSecondsCfg) .. ", InLostRateFactor:" .. tostring(InLostRateFactorCfg) .. ", OutLostRateFactor:" .. tostring(OutLostRateFactorCfg))
        end
      end
      if 3 < MainParamLen then
        local SubParamSubMods = StringUtil.Split(MainParams[4], ",")
        for i = 1, #SubParamSubMods do
          local SubModIDCfg = tonumber(SubParamSubMods[i])
          if SubModIDCfg ~= nil and 0 < SubModIDCfg then
            log(bWriteLog and "InitNetUnstableConfigs, OpenSubMod:" .. tostring(SubModIDCfg))
            IngamePhoneStateUI.NetUnstableConfigs.SupportSubMods[SubModIDCfg] = true
          end
        end
      end
      if 4 < MainParamLen then
        local SubParamMainMods = StringUtil.Split(MainParams[5], ",")
        for i = 1, #SubParamMainMods do
          local MainModeIDCfg = tonumber(SubParamMainMods[i])
          if MainModeIDCfg ~= nil and 0 < MainModeIDCfg then
            log(bWriteLog and "InitNetUnstableConfigs, OpenMainMod:" .. tostring(MainModeIDCfg))
            IngamePhoneStateUI.NetUnstableConfigs.SupportMainMods[MainModeIDCfg] = true
          end
        end
      end
    end
    if IngamePhoneStateUI.NetUnstableConfigs.Enabled and (next(IngamePhoneStateUI.NetUnstableConfigs.SupportSubMods) ~= nil or next(IngamePhoneStateUI.NetUnstableConfigs.SupportMainMods) ~= nil) then
      local UIUtil = require("client.common.ui_util")
      local GameInstance = UIUtil.GetGameInstance()
      local MainModeID = GameInstance and GameInstance:GetMainModeID() or 0
      local SubModeID = GameInstance and GameInstance:GetModeID() or 0
      local MainModeMatch = 0 < MainModeID and IngamePhoneStateUI.NetUnstableConfigs.SupportMainMods[MainModeID]
      local SubModeMatch = 0 < SubModeID and IngamePhoneStateUI.NetUnstableConfigs.SupportSubMods[SubModeID]
      if not MainModeMatch and not SubModeMatch then
        IngamePhoneStateUI.NetUnstableConfigs.Enabled = false
        log(bWriteLog and "InitNetUnstableConfigs, MainMode or SubMode NOT Match, Disabled")
      end
    end
  end
  if IngamePhoneStateUI.NetUnstableConfigs.Enabled then
    self:AddGameTimer(1, true, function()
      self:UpdateRencentImmePing()
    end)
  end
end
function IngamePhoneStateUI:OnPostInitialize()
  IngamePhoneStateUI.__super.OnPostInitialize(self)
end
function IngamePhoneStateUI:TickInternal(deltaTime)
  self.curTickCountDownTime = self.curTickCountDownTime - deltaTime
  if self.curTickCountDownTime > 0 then
    return
  end
  self.CurrentRound = 1 - self.CurrentRound
  if self.CurrentRound == 1 then
    self:TickRefreshBatteryInfo()
  else
    self:TickRefreshSignalUI()
  end
  self.curTickCountDownTime = IngamePhoneStateUI.ConfigTickTime * 0.5
end
function IngamePhoneStateUI:Close()
  IngamePhoneStateUI.__super.Close(self)
end
function IngamePhoneStateUI:InitUI()
  self:UpdateArtQualityUI()
  local UpdateSignalUICallBack = function()
    self:UpdateSignalUI(Client.HasActiveWifi())
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local aPlayerState = uPlayerController.GetCurPlayerState and uPlayerController:GetCurPlayerState()
    if aPlayerState then
      UpdateSignalUICallBack()
    elseif uPlayerController.OnRepPlayerState then
      self:AddControlEventByControl(uPlayerController, "OnRepPlayerState", UpdateSignalUICallBack)
    end
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneId = ZoneSystem.nChooseZoneID
  if zoneId ~= nil then
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    local lobby_ping = logic_zone_delay.GetZoneDelay(zoneId, 999, 10000)
    if lobby_ping ~= nil and 0 < lobby_ping then
      print("IngamePhoneStateUI InitialPing " .. tostring(lobby_ping))
      self:SetPingText(lobby_ping, false)
    else
      self:SetPingText(20, false)
    end
  else
    self:SetPingText(20, false)
  end
  self.UIRoot.WifiSignalWidgetSwitcher:SetActiveWidgetIndex(2)
  self.UIRoot.MobileSignalWidgetSwitcher:SetActiveWidgetIndex(2)
  self.UIRoot.Image_Charge:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngamePhoneStateUI:TickRefreshBatteryInfo()
  local OMobileFBPL = import("OMobileFBPL")
  local batteryLevel = OMobileFBPL.GetBatteryLevel()
  self.UIRoot.ProgressBar_Battery:SetPercent(batteryLevel / 100)
  if 60 <= batteryLevel then
    if self.BatteryState ~= 0 then
      self.BatteryState = 0
      self.UIRoot.ProgressBar_Battery:SetFillColorAndOpacity(FLinearColor(0.15, 0.52, 0.076, 1.0))
    end
  elseif 20 <= batteryLevel then
    if self.BatteryState ~= 1 then
      self.BatteryState = 1
      self.UIRoot.ProgressBar_Battery:SetFillColorAndOpacity(FLinearColor(1.0, 0.6, 0.0, 1.0))
    end
  elseif self.BatteryState ~= 2 then
    self.BatteryState = 2
    self.UIRoot.ProgressBar_Battery:SetFillColorAndOpacity(FLinearColor(1.0, 0.0, 0.0, 1.0))
  end
  local bIsChanging = OMobileFBPL.IsBatteryStateCharging()
  if self.bIsCharging ~= bIsChanging then
    self.bIsCharging = bIsChanging
    if self.bIsCharging then
      self.UIRoot.Image_Charge:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.Image_Charge:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function IngamePhoneStateUI:TickRefreshSignalUI()
  local BusinessHelper = import("BusinessHelper")
  local networkState = BusinessHelper.GetCurrentNetworkState()
  if networkState == 0 then
    self.UIRoot.signalWidgetSwitcher:SetActiveWidgetIndex(2)
    self:SetPingText(0, true)
    self.bHasActiveWiFiConnection = -1
  elseif networkState == 1 or networkState == 2 then
    self:UpdateSignalUI(true)
  else
    self:UpdateSignalUI(false)
  end
end
function IngamePhoneStateUI:UpdateArtQualityUI(_, _)
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local GraphicsNewData = require("client.slua.umg.NewSetting.GraphicsNew.GraphicsNewData")
  local state = GraphicsNewData.NORMAL
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local bIsPlanPHMode = logic_home_entry:IsPlanPHMode()
  if bIsPlanPHMode then
    state = GraphicsNewData.MANOR
  else
    state = GraphicsNewData.BATTLE
  end
  local _, __, renderQuality = logicSettingGraphics.GetSettingByState(state)
  printf("IngamePhoneStateUI:UpdateArtQualityUI renderQuality:%s, lastUpdateArtQuality:%s", renderQuality, self.lastUpdateArtQuality)
  if renderQuality == self.lastUpdateArtQuality then
    return
  end
  local ERenderQuality = import("ERenderQuality")
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  if not gameInstance:IsSupportSwitchRenderLevelRuntime() then
    local logic_setting = require("client.logic.setting.logic_setting")
    local lastSettingLocalCache = logic_setting.GetQualitySetting() or 1
    if lastSettingLocalCache == ERenderQuality.VERYSMOOTH then
      renderQuality = ERenderQuality.VERYSMOOTH
    end
  end
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local iRendQuality = GraphicHelperUtil.GetCollectRendQualityAndFPS()
  if iRendQuality ~= -1 then
    renderQuality = iRendQuality
  end
  self.lastUpdateArtQuality = renderQuality
  local text = GraphicHelperUtil.GetQualityText(renderQuality)
  local LogicGRomelink = require("client.slua.logic.gromelink.logic_grome_link")
  local isEnterBattleUsingGRomeLink = LogicGRomelink:IsEnterBattleUsingGRomeLink()
  print(bWriteLog and "IngamePhoneStateUI:UpdateArtQualityUI isEnterBattleUsingGRomeLink:" .. tostring(isEnterBattleUsingGRomeLink))
  if isEnterBattleUsingGRomeLink then
    local newText = text .. "."
    self.UIRoot.TextBlock_quality:SetText(newText)
  else
    self.UIRoot.TextBlock_quality:SetText(text)
  end
end
function IngamePhoneStateUI:UpdateSignalUI(hasActiveWiFiConnection)
  local playerPing = -1
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if slua.isValid(uPlayerController) then
    playerPing = STExtraBlueprintFunctionLibrary.GetPlayerPing(uPlayerController)
  end
  if playerPing < 0 then
    return
  end
  local finalPing
  if 428 <= playerPing and self.curRecordPingTimes < 1 then
    self.curRecordPingTimes = self.curRecordPingTimes + 1
    finalPing = self.lastRecordPing
  else
    self.curRecordPingTimes = 0
    self.lastRecordPing = playerPing
    finalPing = playerPing
  end
  self:SetPingText(finalPing, false)
  local bNeedRefresh = false
  local playerPingSignal = STExtraBlueprintFunctionLibrary.GetPlayerPingSignal(finalPing)
  local bNetUnstable = self:IsNetUnstable()
  if self.bHasActiveWiFiConnection ~= hasActiveWiFiConnection or self.playerPingSignal ~= playerPingSignal or self.bIsNetUnstable ~= bNetUnstable then
    bNeedRefresh = true
    self.    self.bHasActiveWiFiConnection = hasActiveWiFiConnection
    self.bIsNetUnstable = bNetUnstable
  end
  if not bNeedRefresh then
    return
  end
  local widgetSwitcher
  if bNetUnstable then
    self.UIRoot.SignalWidgetSwitcher:SetActiveWidgetIndex(3)
    return
  elseif hasActiveWiFiConnection then
    self.UIRoot.SignalWidgetSwitcher:SetActiveWidgetIndex(1)
    widgetSwitcher = self.UIRoot.WifiSignalWidgetSwitcher
  else
    self.UIRoot.SignalWidgetSwitcher:SetActiveWidgetIndex(0)
    widgetSwitcher = self.UIRoot.MobileSignalWidgetSwitcher
  end
  if playerPingSignal == 0 then
    widgetSwitcher:SetActiveWidgetIndex(2)
  elseif playerPingSignal == 1 then
    widgetSwitcher:SetActiveWidgetIndex(2)
  elseif playerPingSignal == 2 then
    widgetSwitcher:SetActiveWidgetIndex(0)
  elseif playerPingSignal == 3 then
    widgetSwitcher:SetActiveWidgetIndex(0)
  end
end
function IngamePhoneStateUI:SetPingText(ping, bLostNet)
  if bLostNet then
    self.UIRoot.TextBlock_Ping:SetText("460")
  else
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    local newPing = logic_zone_delay.AdjustPing(ping, 1000, 1000)
    local GameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(GameState) and GameState.RoomType == "match" then
      newPing = ping
    end
    self.UIRoot.TextBlock_Ping:SetText(tostring(newPing))
  end
end
function IngamePhoneStateUI:UpdateRencentImmePing()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if slua.isValid(uPlayerController) then
    local ImmePing = STExtraBlueprintFunctionLibrary.GetCurrentImmePing(uPlayerController, IngamePhoneStateUI.NetUnstableConfigs.PingBucketThreshold)
    if 0 < ImmePing then
      IngamePhoneStateUI.NetUnstableData.RecentPingBucket[IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex] = ImmePing
      IngamePhoneStateUI.NetUnstableData.RecentPingBucketTimeStamp[IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex] = os.time()
      if IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex < IngamePhoneStateUI.NetUnstableConfigs.RecentPingBucketSize then
        IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex = IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex + 1
      else
        IngamePhoneStateUI.NetUnstableData.CurPingBucketIndex = 1
      end
    end
  end
end
function IngamePhoneStateUI:IsNetUnstable()
  if not IngamePhoneStateUI.NetUnstableConfigs.Enabled then
    return false
  end
  local result = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if slua.isValid(uPlayerController) then
    local playerPing = STExtraBlueprintFunctionLibrary.GetPlayerPing(uPlayerController)
    local netInLostRate = STExtraBlueprintFunctionLibrary.GetCurrentNetInLostRate(uPlayerController, IngamePhoneStateUI.NetUnstableConfigs.NetLostPickSeconds)
    local netOutLostRate = STExtraBlueprintFunctionLibrary.GetCurrentNetOutLostRate(uPlayerController, IngamePhoneStateUI.NetUnstableConfigs.NetLostPickSeconds)
    for key, value in pairs(IngamePhoneStateUI.NetUnstableConfigs.NetLostConfigs) do
      if key >= playerPing then
        if netInLostRate >= value.InLostRateFactor or netOutLostRate >= value.OutLostRateFactor then
          result = true
        end
        break
      end
    end
    if not result then
      local pingJumpTimes = 0
      local pingCompareIndex = 1
      for i = 1, IngamePhoneStateUI.NetUnstableConfigs.RecentPingBucketSize do
        if IngamePhoneStateUI.NetUnstableData.RecentPingBucket[i] ~= nil then
          if i == 1 then
            pingCompareIndex = IngamePhoneStateUI.NetUnstableConfigs.RecentPingBucketSize
          else
            pingCompareIndex = i - 1
          end
          if IngamePhoneStateUI.NetUnstableData.RecentPingBucket[pingCompareIndex] ~= nil and IngamePhoneStateUI.NetUnstableData.RecentPingBucketTimeStamp[i] ~= nil and IngamePhoneStateUI.NetUnstableData.RecentPingBucketTimeStamp[pingCompareIndex] ~= nil and IngamePhoneStateUI.NetUnstableData.RecentPingBucketTimeStamp[i] > IngamePhoneStateUI.NetUnstableData.RecentPingBucketTimeStamp[pingCompareIndex] and IngamePhoneStateUI.NetUnstableData.RecentPingBucket[i] >= IngamePhoneStateUI.NetUnstableConfigs.PingUnstableAbsThreshold and IngamePhoneStateUI.NetUnstableData.RecentPingBucket[i] - IngamePhoneStateUI.NetUnstableData.RecentPingBucket[pingCompareIndex] >= IngamePhoneStateUI.NetUnstableConfigs.PingUnstableJumpThreshold then
            pingJumpTimes = pingJumpTimes + 1
          end
        end
      end
      if pingJumpTimes >= IngamePhoneStateUI.NetUnstableConfigs.PingUnstableJumpTimesThreshold then
        result = true
      end
    end
  end
  IngamePhoneStateUI.NetUnstableData.CurCycle = IngamePhoneStateUI.NetUnstableData.CurCycle + 1
  if result then
    IngamePhoneStateUI.NetUnstableData.LastUnstableCycle = IngamePhoneStateUI.NetUnstableData.CurCycle
  elseif IngamePhoneStateUI.NetUnstableData.CurCycle - IngamePhoneStateUI.NetUnstableData.LastUnstableCycle < IngamePhoneStateUI.NetUnstableConfigs.UnstableFlagKeepCycles then
    return true
  end
  return result
end
function IngamePhoneStateUI:HandleSwitchShowSpecialUI(_, __)
  if self.UIRoot.CanvasPanel_1:IsVisible() then
    self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function IngamePhoneStateUI:HideSelfUI(_, __)
  self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function IngamePhoneStateUI:ShowSelfUI(_, __)
  self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CIngamePhoneStateUI = class(ui_base, nil, IngamePhoneStateUI)
return CIngamePhoneStateUI
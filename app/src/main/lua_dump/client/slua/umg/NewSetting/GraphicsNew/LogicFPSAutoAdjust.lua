local LogicFPSAutoAdjust = {
  SHOW_CD_TIMES = {
    [1] = 1800,
    [2] = 5400,
    [3] = 39600
  },
  SHOW_CD_TIMES_EDITOR = {
    [1] = 3,
    [2] = 10,
    [3] = 15
  },
  MIN_SHOW_FPS_LEVEL = 6,
  RESULT_ADJUST_FPS_LEVEL_60FPS = 6,
  RESULT_ADJUST_FPS_LEVEL_40FPS = 5
}
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
function LogicFPSAutoAdjust:Initialize()
  printf("LogicFPSAutoAdjust:Initialize")
end
function LogicFPSAutoAdjust:DefineAndResetData()
  self.hasTriggeredChargePopupThisSession = false
end
function LogicFPSAutoAdjust:OnInitialize()
end
function LogicFPSAutoAdjust:OnDestroy()
end
function LogicFPSAutoAdjust:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_BATTERY_CHARGING_STATE_CHANGE, self.OnBatteryChargingStateChanged, self)
  self:AddCommonEventWithConditions(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, {
    [1] = "ResultRankingProtectLogic"
  }, self.ProcessBattleResultOnEndPhase, self)
end
function LogicFPSAutoAdjust:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    local UIUtil = require("client.common.ui_util")
    local GameInstance = UIUtil.GetGameInstance()
    GameInstance:ExecuteCMD("t.OverrideMaxFPS", 0)
    self:CheckAndShowFPSPanelWhenEnterLobby()
  end
end
function LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby()
  printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby start checking")
  if IsEditor then
  else
    local Client = import("ScriptHelperClient")
    if not Client.IsDeviceOverheat() then
      printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby device is not over heat, block")
      return
    end
  end
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  if GraphicHelperUtil.IsCurrentGraphicFavorBalance() then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby balance config, record fps fluctuation")
    self:RecordFPSFluctuationForBalance()
    ClientEVOConfig.ReportDeviceOverHeatInfo(779, 4)
    return
  end
  if not self:CheckCanShowByInterval() then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby in CD, block")
    ClientEVOConfig.ReportDeviceOverHeatInfo(779, 5)
    return
  end
  if GameStatus.GetGameStatus() == GameStatus.Createrole then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenEnterLobby in login, block")
    return
  end
  ClientEVOConfig.ReportDeviceOverHeatInfo(779, 3)
  self:ShowFPSSlapPanelDirectly()
end
function LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenCharging(bCharging)
  printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenCharging bCharging=%s", tostring(bCharging))
  if not bCharging then
    return
  end
  if GraphicHelperUtil.IsCurrentGraphicFavorBalance() then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenCharging balance config, block")
    return
  end
  if self.hasTriggeredChargePopupThisSession then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenCharging already triggered, block")
    return
  end
  if self:CheckIsNotRemind() then
    printf("LogicFPSAutoAdjust:CheckAndShowFPSPanelWhenCharging not remind, block")
    return
  end
  self.hasTriggeredChargePopupThisSession = true
  self:ShowChargingTipPanel()
end
function LogicFPSAutoAdjust:CheckCanShowByInterval()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust) or {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local currentDate = os.date("%Y%m%d", serverTime)
  if not record.lastResetDate or record.lastResetDate ~= currentDate then
    record.dailyTriggerCount = 0
    record.lastResetDate = currentDate
    record.lastTriggerTime = nil
    PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust)
    printf("LogicFPSAutoAdjust:CheckCanShowByInterval daily reset triggered")
  end
  if not record.lastTriggerTime then
    printf("LogicFPSAutoAdjust:CheckCanShowByInterval no previous trigger, allow show")
    return true
  end
  local triggerCount = record.dailyTriggerCount or 0
  local cdIndex = math.min(triggerCount + 1, #LogicFPSAutoAdjust.SHOW_CD_TIMES)
  local cdTime = LogicFPSAutoAdjust.SHOW_CD_TIMES[cdIndex]
  if IsEditor then
    cdTime = LogicFPSAutoAdjust.SHOW_CD_TIMES_EDITOR[cdIndex]
  end
  local timeSinceLastTrigger = serverTime - record.lastTriggerTime
  if cdTime > timeSinceLastTrigger then
    printf("LogicFPSAutoAdjust:CheckCanShowByInterval still in CD, remaining: %d seconds", cdTime - timeSinceLastTrigger)
    return false
  end
  printf("LogicFPSAutoAdjust:CheckCanShowByInterval CD passed, allow show")
  return true
end
function LogicFPSAutoAdjust:CheckCanShowByLobbyFPSLevel()
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local UserSettings = SettingUtil.GetSettingConfig()
  if UserSettings.LobbyFPS <= LogicFPSAutoAdjust.MIN_SHOW_FPS_LEVEL then
    printf("LogicFPSAutoAdjust:CheckCanShowByLobbyFPSLevel FPS is not greater then MIN_SHOW_FPS_LEVEL, block")
    return false
  end
  printf("LogicFPSAutoAdjust:CheckCanShowByLobbyFPSLevel pass")
  return true
end
function LogicFPSAutoAdjust:ShowFPSSlapPanelDirectly()
  printf("LogicFPSAutoAdjust:ShowFPSSlapPanelDirectly")
  self:RecordTriggerTime()
  UIManager.ShowUI(UIManager.UI_Config.Hall_Picture_Popup_UIBP, 1)
end
function LogicFPSAutoAdjust:RecordTriggerTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust) or {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  record.lastTriggerTime = serverTime
  record.dailyTriggerCount = (record.dailyTriggerCount or 0) + 1
  PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust)
  printf("LogicFPSAutoAdjust:RecordTriggerTime trigger count: %d", record.dailyTriggerCount)
end
function LogicFPSAutoAdjust:RecordFPSFluctuationForBalance()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust) or {}
  record.balanceFluctuationCount = (record.balanceFluctuationCount or 0) + 1
  PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust)
  printf("LogicFPSAutoAdjust:RecordFPSFluctuationForBalance balance fluctuation count: %d", record.balanceFluctuationCount)
end
function LogicFPSAutoAdjust:OnBatteryChargingStateChanged(_, __, bCharging)
  self:CheckAndShowFPSPanelWhenCharging(bCharging)
end
function LogicFPSAutoAdjust:TempLimitBattleResult()
  printf("LogicFPSAutoAdjust:TempLimitBattleResult")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local SettingConfig = LogicSettingGraphics.GetSettingConfig()
  if SettingConfig.BattleFPS > LogicFPSAutoAdjust.RESULT_ADJUST_FPS_LEVEL_60FPS then
    GameInstance:ExecuteCMD("t.OverrideMaxFPS", 60)
  end
end
function LogicFPSAutoAdjust:ProcessBattleResultOnEndPhase()
  self:TempLimitBattleResult()
end
function LogicFPSAutoAdjust:CheckIsNotRemind()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust) or {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local lastRemindTime_ChargeToBalance = record.lastRemindTime_ChargeToBalance or 0
  local remindInterval = 604800
  if remindInterval > serverTime - lastRemindTime_ChargeToBalance then
    return true
  end
  return false
end
function LogicFPSAutoAdjust:ShowChargingTipPanel()
  if UIManager.GetUI(UIManager.UI_Config.Hall_Picture_Popup_UIBP) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Hall_Picture_Popup_UIBP, 2)
end
function LogicFPSAutoAdjust:UpdateSaveData(key, value)
  printf("LogicFPSAutoAdjust:UpdateSaveData key: %s, value: %s", key, value)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust) or {}
  record[key] = value
  PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eFPSAdjust)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicFPSAutoAdjust = class(CModuleBase, nil, LogicFPSAutoAdjust)
return CLogicFPSAutoAdjust
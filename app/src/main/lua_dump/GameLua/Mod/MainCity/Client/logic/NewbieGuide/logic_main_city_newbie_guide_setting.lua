local logic_main_city_newbie_guide_setting = {}
function logic_main_city_newbie_guide_setting:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS, self.OnMainCityConnectedToDs, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_UI, self.OnEnterMainCity, self)
end
function logic_main_city_newbie_guide_setting:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  self:ClearSettingTimer()
  self:ClearDelayTimer()
end
function logic_main_city_newbie_guide_setting:StartNewBieGuide_Setting()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:StartNewBieGuide_Setting")
  self:ClearDelayTimer()
  self.delayGuideTimer = self:AddTimerOnce(30, function()
    log(bWriteLog and "logic_main_city_newbie_guide_setting:StartNewBieGuide_Setting timer delay")
    self:ClearDelayTimer()
    self:DelayShowGuide()
  end)
end
function logic_main_city_newbie_guide_setting:DelayShowGuide()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:DelayShowGuide")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local foldFlag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_FOLD_GUIDE_ID)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:DelayShowGuide foldFlag = " .. tostring(foldFlag))
  if foldFlag ~= 1 then
    return false
  end
  local selfFlag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_SETTING_GUIDE_ID)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:DelayShowGuide selfFlag = " .. tostring(selfFlag))
  if selfFlag then
    return
  end
  DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_SETTING_GUIDE_ID)
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(1)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:DelayShowGuide switch = " .. tostring(switch))
  if switch then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.MainCity_Tab_DefaultEntrance_UIBP)
end
function logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs")
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(1)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs switch = " .. tostring(switch))
  if switch then
    return
  end
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local flag = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_SETTING_GUIDE_ID)
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs flag = " .. tostring(flag))
  if not flag then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMainCitySettingTimeGuide) or {}
  local lastGuideTimeStamp = saveData.lastGuideTimeStamp or 0
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs lastGuideTimeStamp = " .. tostring(lastGuideTimeStamp))
  local days_config = CDataTable.GetTableData("MainCitySettingCfg", "MAIN_CITY_COOLDOWN_DAYS")
  local MAIN_CITY_COOLDOWN_DAYS
  if days_config and days_config.value then
    MAIN_CITY_COOLDOWN_DAYS = days_config.value
  end
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs MAIN_CITY_COOLDOWN_DAYS = " .. tostring(MAIN_CITY_COOLDOWN_DAYS))
  MAIN_CITY_COOLDOWN_DAYS = MAIN_CITY_COOLDOWN_DAYS or 7
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs nowTime = " .. tostring(nowTime))
  local bCanTrigger = nowTime - lastGuideTimeStamp > MAIN_CITY_COOLDOWN_DAYS * 24 * 60 * 60
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs bCanTrigger = " .. tostring(bCanTrigger))
  if not bCanTrigger then
    return
  end
  local minutes_config = CDataTable.GetTableData("MainCitySettingCfg", "MAIN_CITY_TRIGGER_MINUTES")
  local MAIN_CITY_TRIGGER_MINUTES
  if minutes_config and minutes_config.value then
    MAIN_CITY_TRIGGER_MINUTES = minutes_config.value
  end
  log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs MAIN_CITY_TRIGGER_MINUTES = " .. tostring(MAIN_CITY_TRIGGER_MINUTES))
  MAIN_CITY_TRIGGER_MINUTES = MAIN_CITY_TRIGGER_MINUTES or 3
  self:ClearSettingTimer()
  self.settingGuideTimer = self:AddTimerOnce(MAIN_CITY_TRIGGER_MINUTES * 60, function()
    self:ClearSettingTimer()
    local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
    local switch = logic_main_city_privacy:GetUserSwitch(1)
    log(bWriteLog and "logic_main_city_newbie_guide_setting:OnMainCityConnectedToDs timer switch = " .. tostring(switch))
    if switch then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.MainCity_Tab_DefaultEntrance_UIBP)
  end)
end
function logic_main_city_newbie_guide_setting:ClearSettingTimer()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:ClearSettingTimer")
  if self.settingGuideTimer then
    self:RemoveTimer(self.settingGuideTimer)
    self.settingGuideTimer = nil
  end
end
function logic_main_city_newbie_guide_setting:ClearDelayTimer()
  log(bWriteLog and "logic_main_city_newbie_guide_setting:ClearDelayTimer")
  if self.delayGuideTimer then
    self:RemoveTimer(self.delayGuideTimer)
    self.delayGuideTimer = nil
  end
end
function logic_main_city_newbie_guide_setting:OnEnterMainCity()
  if self.delayGuideTimer ~= nil or self.settingGuideTimer ~= nil then
    return
  end
  self:DelayShowGuide()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_main_city_newbie_guide_setting)
return CModuleTemplate
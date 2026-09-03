local logic_time_cost_report = {}
local DeviceUtils = require("common.DeviceUtils")
local time_step_macros = require("client.slua.logic.performance.time_step_macros")
function logic_time_cost_report:DefineAndResetData()
  self.curStep = nil
  self.startTime = nil
  self.stepMarkStarted = {}
  self.stepMarkFinished = {}
  self.roleType = time_step_macros.ENUM_ROLE_TYPE.RoleType_Unknown
end
function logic_time_cost_report:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
end
function logic_time_cost_report:ReportTimeCostBeForeEngineInit()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastLoginOpenID) or {}
  if cfg.openid then
    log(bWriteLog and "logic_time_cost_report:ReportTimeCostBeForeEngineInit SetLastLoginOpenID openid = " .. tostring(cfg.openid))
    Client.CrashSetUserId(cfg.openid)
  end
  local app_start_time = Client.GetAppStartupStageTime("app_start") or 0
  local cp_so_end = Client.GetAppStartupStageTime("cp_so_end") or 0
  if cp_so_end == 0 then
    cp_so_end = app_start_time
  elseif app_start_time > cp_so_end then
    log_warning(bWriteLog and "logic_time_cost_report:ReportTimeCostBeForeEngineInit cp_so_end < app_start_time, cp_so_end = " .. tostring(cp_so_end) .. ", app_start_time = " .. tostring(app_start_time))
    app_start_time = cp_so_end
  end
  local splash_start = Client.GetAppStartupStageTime("splash_start") or 0
  local splash_end = Client.GetAppStartupStageTime("splash_end") or 0
  log(bWriteLog and "logic_time_cost_report:ReportTimeCostBeForeEngineInit app_start_time = " .. tostring(app_start_time) .. ", cp_so_end = " .. tostring(cp_so_end) .. ", splash_start = " .. tostring(splash_start) .. ", splash_end = " .. tostring(splash_end))
  if 0 < app_start_time and 0 < cp_so_end then
    local reportInfo = self:GenerateReportInfo(time_step_macros.ENUM_TIME_STEP.AppStartToCopySoEnd, cp_so_end - app_start_time)
    if Client.CrashReportLogInfo then
      Client.CrashReportLogInfo(time_step_macros.ENUM_MSG_TYPE, reportInfo)
    end
  end
  if 0 < cp_so_end and 0 < splash_start then
    local reportInfo = self:GenerateReportInfo(time_step_macros.ENUM_TIME_STEP.CopySoToSplashStart, splash_start - cp_so_end)
    if Client.CrashReportLogInfo then
      Client.CrashReportLogInfo(time_step_macros.ENUM_MSG_TYPE, reportInfo)
    end
  end
  if 0 < splash_start and 0 < splash_end then
    local reportInfo = self:GenerateReportInfo(time_step_macros.ENUM_TIME_STEP.SplashStartToSplashEnd, splash_end - splash_start)
    if Client.CrashReportLogInfo then
      Client.CrashReportLogInfo(time_step_macros.ENUM_MSG_TYPE, reportInfo)
    end
  end
  self:SetStepStart(time_step_macros.ENUM_TIME_STEP.SplashEndToSplashAniStart, splash_end)
end
function logic_time_cost_report:SetStepStart(step, startTime)
  if self.stepMarkStarted[step] then
    log("logic_time_cost_report:SetStepStart failed, step = " .. tostring(step) .. ", startTime = " .. tostring(startTime))
    return
  end
  self.stepMarkStarted[step] = true
  if startTime == 0 then
    log("logic_time_cost_report:SetCurrentStepAndStartTime failed, step = " .. tostring(step) .. ", startTime = " .. tostring(startTime))
    self.curStep = nil
    self.startTime = nil
    return
  end
  self.curStep = step
  if not startTime then
    self.startTime = slua.getMiliseconds()
  else
    self.  end
end
function logic_time_cost_report:ReportTimeCost(step, endTime)
  if self.stepMarkFinished[step] then
    log("logic_time_cost_report:ReportTimeCost has finished, step = " .. tostring(step) .. ", endTime = " .. tostring(endTime))
    return
  end
  self.stepMarkFinished[step] = true
  if not step or endTime == 0 then
    log("logic_time_cost_report:ReportTimeCost param not valid, step = " .. tostring(step) .. ", endTime = " .. tostring(endTime))
    self.curStep = nil
    self.startTime = nil
    return false
  end
  if self.curStep ~= step then
    log("logic_time_cost_report:ReportTimeCost step not match, curStep = " .. tostring(self.curStep) .. ", step = " .. tostring(step) .. ", endTime = " .. tostring(endTime))
    self.curStep = nil
    self.startTime = nil
    return false
  end
  endTime = endTime or slua.getMiliseconds()
  local timeDuration = endTime - self.startTime
  local reportInfo = self:GenerateReportInfo(step, timeDuration)
  if Client.CrashReportLogInfo then
    Client.CrashReportLogInfo(time_step_macros.ENUM_MSG_TYPE, reportInfo)
  end
  self.curStep = nil
  self.startTime = nil
  return true
end
function logic_time_cost_report:GenerateReportInfo(step, timeDuration)
  if not self.firstStartup then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eStartupVersion) or {}
    local version_util = require("client.common.version_util")
    local curVersion = version_util.GetCurVersionNumber()
    if not cfg.version then
      cfg.version = curVersion
      PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eStartupVersion)
      self.firstStartup = 1
    elseif cfg.version ~= curVersion then
      cfg.version = curVersion
      PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eStartupVersion)
      self.firstStartup = 1
    else
      self.firstStartup = 0
    end
  end
  if not self.deviceLevel then
    self.deviceLevel = DeviceUtils.GetDeviceLevel()
  end
  if not self.tcDeviceLevel then
    self.tcDeviceLevel = DeviceUtils.GetTCDeviceLevel()
  end
  local reportInfo = string.format("{\"step_id\":%d, \"step_duration\":%d, \"device_level\":%d, \"tc_device_level\":%d, \"is_first_startup\":%d, \"role_type\":%d}", step, timeDuration, self.deviceLevel, self.tcDeviceLevel, self.firstStartup, self.roleType)
  log(bWriteLog and "logic_time_cost_report:GenerateReportInfo reportInfo = " .. tostring(reportInfo))
  return reportInfo
end
function logic_time_cost_report:SetRoleData(roleData)
  if not roleData or not roleData.openid then
    log_warning(bWriteLog and "logic_time_cost_report:SetRoleData SetRoleData invalid roleData")
    return
  end
  log(bWriteLog and "logic_time_cost_report:SetRoleData SetRoleData openid = " .. tostring(roleData.openid))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastLoginOpenID) or {}
  if cfg.openid ~= roleData.openid then
    cfg.openid = roleData.openid
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eLastLoginOpenID)
  end
  self.roleType = time_step_macros.ENUM_ROLE_TYPE.RoleType_Normal
  if roleData.is_first_login == LobbySystem.NewbieRoleState.Init then
    self.roleType = time_step_macros.ENUM_ROLE_TYPE.RoleType_Newbie_Init
  elseif roleData.popui_type then
    local config_user = require("client.slua.logic.user.config_user")
    if roleData.popui_type == config_user.E_UserCtrl.Enum_Rookie then
      self.roleType = time_step_macros.ENUM_ROLE_TYPE.RoleType_Newbie
    elseif roleData.popui_type == config_user.E_UserCtrl.Enum_LongReturn or roleData.popui_type == config_user.E_UserCtrl.Enum_ShortReturn then
      self.roleType = time_step_macros.ENUM_ROLE_TYPE.RoleType_Return
    end
  end
  log(bWriteLog and "logic_time_cost_report:SetRoleData SetRoleData roleType = " .. tostring(self.roleType))
end
function logic_time_cost_report:OnApplicationDeactivated()
  log(bWriteLog and "logic_time_cost_report:OnApplicationDeactivated")
  self.curStep = nil
  self.startTime = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_time_cost_report = class(CModuleBase, nil, logic_time_cost_report)
return Clogic_time_cost_report
local device_module = {}
function device_module:DefineAndResetData()
  self.sDeviceName = nil
  self.nDeviceLimit = 0
  self.isFromBgBgGameCenter = false
  self.isFromWXGameCenter = false
  self.wakeupInfo = nil
  self.extendInfo = nil
  self.facebookSDKInited = nil
  self:LoadDeviceName()
  self:LoadDeviceLimit()
end
function device_module:LoadDeviceName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local deviceName = DevicePlatformNameMacros.GetDeviceName()
  self.sDeviceName = deviceName
  log(bWriteLog and "login_module:LoadDeviceName, deviceName = " .. tostring(deviceName))
end
function device_module:LoadDeviceLimit()
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  local deviceLimit
  if GameInstance ~= nil then
    deviceLimit = GameInstance:GetDeviceLimit()
  end
  self.nDeviceLimit = deviceLimit
  log(bWriteLog and "NewLoginUI:GetDeviceLimit, deviceLimit = " .. tostring(deviceLimit))
end
local iOS12DeviceList = {
  ipodtouch7 = 1,
  iphonexsmax = 1,
  iphonexs = 1,
  iphonexr = 1,
  iphonex = 1,
  iphone8plus = 1,
  iphone8 = 1,
  iphone7plus = 1,
  iphone6splus = 1,
  iphone6s = 1,
  ipad2018 = 1,
  ipadpro2_129 = 1,
  ipadpro3_129 = 1,
  ipadpro = 1,
  ipadpro11 = 1,
  ipadpro105 = 1,
  ipadpro129 = 1
}
local iOS13DeviceList = {
  iphonexsmax = 1,
  iphonexs = 1,
  iphonexr = 1,
  iphonex = 1,
  iphone11 = 1,
  iphone11pro = 1,
  iphone11promax = 1,
  ipadpro129 = 1,
  ipadpro3_129 = 1
}
local iOS14DeviceList = {
  ipad7 = 1,
  ipadair4 = 1,
  ipadpro2_11 = 1,
  ipadpro3_11 = 1,
  ipadpro2_129 = 1,
  iphone11 = 1,
  iphone11pro = 1,
  iphone11promax = 1,
  iphone12mini = 1,
  iphone12pro = 1,
  iphone12promax = 1,
  iphone8plus = 1,
  iphonexs = 1,
  iphonex = 1,
  iphonexsmax = 1,
  iphone7plus = 1,
  ipad8 = 1,
  ipadair5 = 1,
  ipadmini5 = 1,
  ipadpro5_129 = 1,
  ipadpro129 = 1,
  ipadpro_97 = 1,
  ipad6 = 1
}
local iOS15DeviceList = {
  iphone8plus = 1,
  ipadmini6 = 1,
  iphone11 = 1,
  iphone11pro = 1,
  iphone11promax = 1,
  iphone12 = 1,
  iphone12mini = 1,
  iphone12pro = 1,
  iphone12promax = 1,
  iphonex = 1,
  iphonexs = 1,
  iphonexr = 1,
  iphonexsmax = 1,
  iphone13mini = 1,
  iphone13 = 1,
  iphone13pro = 1,
  iphone13promax = 1,
  ipadpro2_129 = 1,
  ipad8 = 1,
  ipadair5 = 1,
  ipadmini5 = 1,
  ipadpro5_129 = 1,
  ipadpro129 = 1,
  ipadpro_97 = 1,
  ipad6 = 1
}
local autoEnablePlanarTb = {
  ["12"] = iOS12DeviceList,
  ["13"] = iOS13DeviceList,
  ["14"] = iOS14DeviceList,
  ["15"] = iOS15DeviceList
}
function device_module:EnablePlanarReflection()
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local deviceLevel = gameInstance:GetDeviceLevel()
  log(bWriteLog and "device_module:EnablePlanarReflection, deviceLevel = " .. tostring(deviceLevel))
  if 0 < deviceLevel then
    local profileName = Client.GetActiveProfileName()
    local osVersion = Client.GetOSVersion()
    log(bWriteLog and "device_module:EnablePlanarReflection, osVersion = " .. tostring(osVersion))
    local StringUtil = require("common.string_util")
    local array = StringUtil.Split(osVersion, ".")
    osVersion = array[1]
    local ExecuteConsoleCommand = function()
      local UIUtil = require("client.common.ui_util")
      local worldContextObject = UIUtil.GetGameInstance()
      local KismetSystemLibrary = import("KismetSystemLibrary")
      log_warning(bWriteLog and "  : ExecuteConsoleCommand")
      KismetSystemLibrary.ExecuteConsoleCommand(worldContextObject, "r.EnablePlanarReflection 1", nil)
    end
    if osVersion == "16" then
      ExecuteConsoleCommand()
    else
      local deviceTb = autoEnablePlanarTb[osVersion]
      if deviceTb and deviceTb[string.lower(profileName)] then
        ExecuteConsoleCommand()
      end
    end
  end
end
function device_module:GetCurEquipment()
  local EmulatorSystem = require("client.logic.login.logic_emulator")
  local emulatorName = Client.GetEmulatorName()
  local isEmulator = EmulatorSystem.IsEmulator(emulatorName)
  if isEmulator then
    return "Emulator"
  end
  return "NoEmulator"
end
function device_module:SetisFromWXGameCenter(flag)
  self.isFromWXGameCenter = flag
  log_warning(bWriteLog and "  : self.isFromWXGameCenter: " .. tostring(self.isFromWXGameCenter))
end
function device_module:SetisFromBgBgGameCenter(flag)
  self.isFromBgBgGameCenter = flag
  log_warning(bWriteLog and "  : self.isFromBgBgGameCenter: " .. tostring(self.isFromBgBgGameCenter))
end
function device_module:SetWakeupInfo(info)
  self.wakeupInfo = info
end
function device_module:CheckWakeupInfo()
  local wakeupinfo = self.wakeupinfo
  self.isFromBgBgGameCenter = false
  if wakeupinfo.launchfrom == "sq_gamecenter" then
    self.isFromBgBgGameCenter = true
  end
  self.isFromWXGameCenter = false
  if wakeupinfo.Base_MessageExt == "WX_GameCenter" then
    self.isFromWXGameCenter = true
  end
  local platform = math.floor(tonumber(wakeupinfo.Base_Platform))
  local extinfo
  if platform == BP_ENUM_PLAYFORM_WX then
    log(bWriteLog and "CheckWakeupInfo:BP_ENUM_PLAYFORM_WX")
    if wakeupinfo.Base_MessageExt and wakeupinfo.Base_MessageExt ~= "" then
      log(bWriteLog and "MessageExt" .. tostring(wakeupinfo.Base_MessageExt))
      extinfo = wakeupinfo.Base_MessageExt
    end
  elseif platform == BP_ENUM_PLAYFORM_BGBG then
    log(bWriteLog and "CheckWakeupInfo:BP_ENUM_PLAYFORM_BGBG")
    if wakeupinfo.gamedata and wakeupinfo.gamedata ~= "" then
      log(bWriteLog and "gamedata" .. tostring(wakeupinfo.gamedata))
      extinfo = wakeupinfo.gamedata
    end
  end
  local StringUtil = require("common.string_util")
  if extinfo then
    local decodedstr = StringUtil.DecodeURI(extinfo)
    local decodedXML = StringUtil.DecodeXML(decodedstr)
    local gamedata = json.decode(decodedXML)
    self.extendInfo = gamedata
    self:CheckWakeupDataForTeamup()
  else
    self.extendInfo = {}
  end
  self.wakeupinfo = nil
end
function device_module:getStartUpType()
  local startup_type = BP_ENUM_STARTUPTYPE_COMM
  if self.isFromBgBgGameCenter then
    startup_type = BP_ENUM_STARTUPTYPE_BGBGGAME
  elseif self.isFromWXGameCenter then
    startup_type = BP_ENUM_STARTUPTYPE_WXGAME
  end
  return startup_type
end
function device_module:CheckWakeupDataForTeamup()
  local gamedata = self.extendInfo
  if GameStatus.IsInLobbyOrMainCity() and type(gamedata) == "table" then
    if gamedata.team_roleid and gamedata.team_teamid then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      TeamUpNewSystem.JoinTeamByChat(tonumber(gamedata.team_roleid), tonumber(gamedata.team_teamid), "plat-invite")
    end
    self.extendInfo = {}
  end
end
function device_module:ClearExtendInfo()
  self.extendInfo = {}
end
function device_module:EnablePreFetchPaks()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ClientBasicCfg = login_module.ClientBasicCfg
  log(bWriteLog and "PreFetch Start")
  PreFetchPakEnable = ClientBasicCfg.PreFetchPakEnable or false
  PreFetchFileClearEnable = ClientBasicCfg.PreFetchFileClearEnable or false
  PreFetchConvertEnable = ClientBasicCfg.PreFetchConvertEnable or false
  PreFetchReserveredDiskSpace = ClientBasicCfg.PreFetchReserveredDiskSpace or 2048
  PreFetchODPakEnable = ClientBasicCfg.PreFetchODPakEnable or false
  PreFetchODPaksMaxNum = ClientBasicCfg.PreFetchODPaksMaxNum or 400
  PreFetchODPaksBatchSize = ClientBasicCfg.PreFetchODPaksBatchSize or 10
  PreFetchODPaksClear = ClientBasicCfg.PreFetchODPaksClear or false
  PrefetchFileList = ClientBasicCfg.PrefetchFileList or ""
  PrefetchDelay = ClientBasicCfg.PrefetchDelay or 60
  GCPufferDownloader.SetPrefetchConfig(Puffer, PreFetchPakEnable, PreFetchFileClearEnable, PreFetchConvertEnable, PreFetchReserveredDiskSpace, PrefetchFileList, PreFetchODPaksMaxNum, PreFetchODPaksBatchSize)
  if self.PrefetchTimer then
    self:RemoveTimer(self.PrefetchTimer)
    self.PrefetchTimer = nil
  end
  self.PrefetchTimer = self:AddTimerOnce(PrefetchDelay, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "ODPaks PreFetch skip in fighting")
      return
    end
    GCPufferDownloader.ClearPreFetchFiles(Puffer)
    GCPufferDownloader.PreFetchPakFiles(Puffer)
    log(bWriteLog and "ODPaks PreFetch " .. tostring(Puffer))
    GCPufferDownloader.PreFetchODPakFiles(Puffer, PreFetchODPakEnable)
    if PreFetchODPaksClear then
      GCPufferDownloader.ClearPreFetchODPaksFiles(Puffer)
    end
  end)
  GCPufferDownloader.ConvertPreFetchFiles(Puffer)
end
function device_module:EnableReportAntsVoiceEvent(configTbl)
  AntsVoiceInitAntsVoiceComponentReportEnable = configTbl.AntsVoiceInitAntsVoiceComponentReportEnable or false
  AntsVoiceJoinRoomReportEnable = configTbl.AntsVoiceJoinRoomReportEnable or false
  AntsVoiceQuitRoomReportEnable = configTbl.AntsVoiceQuitRoomReportEnable or false
  AntsVoiceJoinLbsRoomReportEnable = configTbl.AntsVoiceJoinLbsRoomReportEnable or false
  AntsVoiceQuitLbsRoomReportEnable = configTbl.AntsVoiceQuitLbsRoomReportEnable or false
  AntsVoiceOnJoinTeamRoomReportEnable = configTbl.AntsVoiceOnJoinTeamRoomReportEnable or false
  AntsVoiceOnJoinLbsRoomReportEnable = configTbl.AntsVoiceOnJoinLbsRoomReportEnable or false
  Client.EnableReportVoiceSdkEvent(GameFrontendHUD, AntsVoiceInitAntsVoiceComponentReportEnable, AntsVoiceJoinRoomReportEnable, AntsVoiceQuitRoomReportEnable, AntsVoiceJoinLbsRoomReportEnable, AntsVoiceQuitLbsRoomReportEnable, AntsVoiceOnJoinTeamRoomReportEnable, AntsVoiceOnJoinLbsRoomReportEnable)
end
function device_module:DelayToInitFacebookSDK()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("IMSDK_DisableFacebookInit", false) == false and not self.facebookSDKInited then
    local FBHelper = import("FBHelper")
    if FBHelper ~= nil then
      FBHelper.DelayToInitFacebookSDK(false, true)
      FBHelper.DelayToSetAutoInitFacebookLog(true)
    end
    self.facebookSDKInited = true
  else
    log(bWriteLog and "device_module.DelayToInitFacebookSDK do nothing")
  end
end
function device_module:CanShowPhoneMailLogin()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE then
    return false
  else
    local showButton = false
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local save_table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailPhoneLogin)
    if save_table and save_table.show_login_btn then
      showButton = save_table.show_login_btn
    else
      showButton = true
    end
    if showButton then
      if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.FIT then
        return true
      else
        return false
      end
    else
      return false
    end
  end
end
function device_module:CheckIfCanUseGyrSensor()
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platformName ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "device_module:CheckIfCanUseGyrSensor return by PLATFORM not match")
    return
  end
  local bDisableGyrSensor = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableAndroidSensor", false)
  if not bDisableGyrSensor then
    log(bWriteLog and "device_module:CheckIfCanUseGyrSensor return by bDisableGyrSensor == false")
    return
  end
  local os_ver = Client.GetOSVersion()
  local DisableGyrSensorOSVers = HDmpveRemote.HDmpveRemoteConfigGetString("DisableAndroidSensorOSVersion", "6.0.1")
  if DisableGyrSensorOSVers and 1 < #DisableGyrSensorOSVers then
    local StringUtil = require("common.string_util")
    local OSVerList = StringUtil.Split(DisableGyrSensorOSVers, ",")
    local HasFound = false
    for i, v in ipairs(OSVerList) do
      if v == os_ver then
        HasFound = true
        break
      end
    end
    if HasFound == true then
      Client.SetDisableGyrSensor(true)
      local STExtraGameInstance = import("STExtraGameInstance")
      if STExtraGameInstance then
        local gameInstance = STExtraGameInstance.GetInstance()
        gameInstance:ExecuteCMD("Android.InputEventEnableSensor", 0)
        log(bWriteLog and bwriteLog and "Disable Android InputEventEnableSensor")
      end
    end
  end
end
function device_module:GetOSMajorVersion()
  local OSVersionName = Client.GetOSVersion()
  local OSMajorVersion = 0
  local endPos = string.find(OSVersionName, "%.")
  if endPos == nil and 0 < #OSVersionName then
    OSMajorVersion = tonumber(OSVersionName)
  else
    OSMajorVersion = tonumber(string.sub(OSVersionName, 1, endPos - 1))
  end
  if OSMajorVersion == nil then
    OSMajorVersion = 99
  end
  log(bWriteLog and "device_module:GetMajorVersion return: " .. tostring(OSMajorVersion))
  return OSMajorVersion
end
function device_module:GetOSArch()
  local Abi = "64"
  local deviceAbiJson = Client.GetDeviceABIInfoJson()
  local deviceAbiObj = json.decode(deviceAbiJson)
  if deviceAbiObj ~= nil then
    local OSArch = deviceAbiObj.OSArch or ""
    if not string.find(OSArch, "64") then
      Abi = "32"
    end
  end
  return Abi
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CDevice_module = class(CModuleBase, nil, device_module)
return CDevice_module
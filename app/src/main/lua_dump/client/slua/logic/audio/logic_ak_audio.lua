AkAudioSystem = AkAudioSystem or {
  isOptimization = false,
  bluetoothOption = 0,
  delayTime = 80
}
function AkAudioSystem.OnDownloadFinish()
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.RefreshModDirectories()
end
function AkAudioSystem.OnClientBaseConfigRsp(bluetoothOption, delayTime)
  log(bWriteLog and "[AkAudioSystem.OnClientBaseConfigRsp] Called. bluetoothOption:" .. tostring(bluetoothOption) .. " delayTime:" .. tostring(delayTime))
  GlobalData.SaveBluetoothOpt(bluetoothOption)
  AkAudioSystem.  AkAudioSystem.RefreshDolbyAudioActivation()
  AkAudioSystem.OptimizationBluetooth()
  AkAudioSystem.StartBluetoothMonitor()
end
function AkAudioSystem.RefreshDolbyAudioActivation()
  local IsDolbyAudio = AkAudioSystem.SupportDolbyAudio()
  Client.AddCrashContextData(1007, tostring(IsDolbyAudio), false, 100)
  if not IsDolbyAudio then
    log(bWriteLog and "AkAudioSystem.RefreshDolbyAudioActivation not support dolby audio")
    return
  end
  local useDeathModeSwitch = false
  local mode = Client.GetGameModeID(GameFrontendHUD)
  if GameStatus.IsInFightingStatus() and (mode == "26001" or LobbySystem.is_DeathMatchMode == true) then
    useDeathModeSwitch = true
  end
  if useDeathModeSwitch then
    if not AkAudioSystem.DolbyAudioDMSwitch() then
      log(bWriteLog and "AkAudioSystem.RefreshDolbyAudioActivation dm switch close")
      AkAudioSystem.ToggleDolbyAudioActivation(false)
    else
      local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
      log(bWriteLog and "AkAudioSystem.RefreshDolbyAudioActivation dm setting: " .. tostring(SettingConfig.DoblySwitch1))
      AkAudioSystem.ToggleDolbyAudioActivation(SettingConfig.DoblySwitch1)
    end
  elseif not AkAudioSystem.DolbyAudioFullOpenSwitch() then
    log(bWriteLog and "AkAudioSystem.RefreshDolbyAudioActivation other switch close")
    AkAudioSystem.ToggleDolbyAudioActivation(false)
  else
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    log(bWriteLog and "AkAudioSystem.RefreshDolbyAudioActivation other setting: " .. tostring(SettingConfig.DoblySwitch2))
    AkAudioSystem.ToggleDolbyAudioActivation(SettingConfig.DoblySwitch2)
  end
end
function AkAudioSystem.SupportDolbyAudio()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableDolby", false) ~= false then
    log(bWriteLog and "AkAudioSystem.SupportDolbyAudio main control disabled")
    return false
  end
  if not Client.IsDolbyAtmosSupported() then
    log(bWriteLog and "AkAudioSystem.SupportDolbyAudio dolby not supported")
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_DOLBY_AUDIO_SWITCH) then
    log(bWriteLog and "AkAudioSystem.SupportDolbyAudio BP_ENUM_DOLBY_AUDIO_SWITCH disabled")
    return false
  end
  if not AkAudioSystem.DolbyAudioFullOpenSwitch() and not AkAudioSystem.DolbyAudioDMSwitch() then
    log(bWriteLog and "AkAudioSystem.SupportDolbyAudio DolbyAudioFullOpenSwitch DolbyAudioDMSwitch disabled")
    return false
  end
  return true
end
function AkAudioSystem.DolbyAudioFullOpenSwitch()
  return LobbySystem.CheckOpen(BP_ENUM_DOLBY_AUDIO_FULL_OPEN_SWITCH)
end
function AkAudioSystem.DolbyAudioDMSwitch()
  return LobbySystem.CheckOpen(BP_ENUM_DOLBY_AUDIO_DEATHMATCH_OPEN_SWITCH)
end
function AkAudioSystem.ToggleDolbyAudioActivation(bDoActive)
  log(bWriteLog and "[DeanJYT] AkAudioSystem.ToggleDolbyAudioActivation bDoActive = " .. tostring(bDoActive))
  local audio_util = require("client.common.audio_util")
  if bDoActive then
    audio_util.AKSetRTPCValue("DolbyAtmosVolume", 100, false)
  else
    audio_util.AKSetRTPCValue("DolbyAtmosVolume", 0, false)
  end
end
function AkAudioSystem.OnModePostSwitch(preState, nextState)
  AkAudioSystem.RefreshDolbyAudioActivation()
end
function AkAudioSystem.HasGotBluetoothOptimizationSwitcher()
  return GlobalData.BluetoothOption >= 0
end
function AkAudioSystem.IsUsingBluetoothWithOptimization()
  return AkAudioSystem.isOptimization and Client.IsUsingBluetooth()
end
function AkAudioSystem.OptimizationBluetooth()
  log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] Called")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] return with OS not android")
    return
  end
  local OSVersionName = Client.GetOSVersion()
  log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] OSVersionName:" .. tostring(OSVersionName))
  local OSMajorVersion = 0
  local endPos = string.find(OSVersionName, "%.")
  if endPos == nil and 0 < #OSVersionName then
    OSMajorVersion = tonumber(OSVersionName)
  else
    OSMajorVersion = tonumber(string.sub(OSVersionName, 1, endPos - 1))
  end
  if OSMajorVersion == nil or OSMajorVersion < 9 then
    log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] return with OSMajorVersion < 9")
    return
  end
  local delayTime = 0
  local foundInWhitelist = false
  local deviceModel = string.lower(Client.GetDeviceModel())
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if GlobalData.BluetoothOption == 1 then
    AkAudioSystem.bluetoothOption = 1
  elseif GlobalData.BluetoothOption == 2 or 0 > GlobalData.BluetoothOption and PublishRegionMacros.IsCEVersion() then
    AkAudioSystem.bluetoothOption = 2
    delayTime = AkAudioSystem.delayTime
  else
    AkAudioSystem.bluetoothOption = 0
  end
  if AkAudioSystem.bluetoothOption == 1 or AkAudioSystem.bluetoothOption == 2 then
    local deviceModelList = CDataTable.GetTable("BluetoothDelayConfig")
    if deviceModelList ~= nil then
      for i, v in pairs(deviceModelList) do
        if 0 < #deviceModel and string.lower(v.DeviceMode) == string.lower(deviceModel) and 0 < v.Delay then
          delayTime = v.Delay
          foundInWhitelist = true
          break
        end
      end
    end
  end
  log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] Server bluetoothOption:" .. tostring(AkAudioSystem.bluetoothOption))
  log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] WhiteList:" .. tostring(foundInWhitelist))
  local localDisableBluetoothOptimization = false
  if AkAudioSystem.bluetoothOption == 2 or AkAudioSystem.bluetoothOption == 1 and foundInWhitelist then
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    local localStoreDic = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.eDefault)
    if localStoreDic ~= nil and localStoreDic.BTDelay ~= nil then
      if 0 >= localStoreDic.BTDelay then
        log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] localDataNoAllowBluetoothOptimization = true")
        localDisableBluetoothOptimization = true
      else
        delayTime = localStoreDic.BTDelay
      end
    end
  end
  AkAudioSystem.isOptimization = not localDisableBluetoothOptimization and (AkAudioSystem.bluetoothOption == 2 or AkAudioSystem.bluetoothOption == 1 and foundInWhitelist)
  if AkAudioSystem.isOptimization then
    Client.SetupAkAudioDeviceListener()
    Client.UpdateAkAudioDeviceBluetoothDelay(delayTime)
    log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] Open bluetooth optimization:" .. tostring(delayTime))
  else
    Client.UpdateAkAudioDeviceBluetoothDelay(-1)
    log(bWriteLog and "[AkAudioSystem.OptimizationBluetooth] Do nothing!")
  end
  local flag = 0
  if AkAudioSystem.bluetoothOption == 1 and foundInWhitelist then
    flag = flag | 1
  end
  if AkAudioSystem.bluetoothOption == 2 then
    flag = flag | 2
  end
  if localDisableBluetoothOptimization then
    flag = flag | 4
  end
  if AkAudioSystem.bluetoothOption == 0 then
    flag = flag | 8
  end
  local isUsingBluetooth = 0
  if Client.IsUsingBluetooth() == true then
    isUsingBluetooth = 1
  end
  local param = {}
  table.insert(param, tostring(deviceModel))
  table.insert(param, tostring(flag))
  table.insert(param, tostring(delayTime))
  table.insert(param, tostring(isUsingBluetooth))
  log(bWriteLog and "AkAudioSystem.OptimizationBluetooth ReportGEM event: BluetoothEvent, subEvent: BluetoothOptimization" .. ", Model:" .. deviceModel .. ", Flag:" .. tostring(flag) .. ", DelayTime:" .. tostring(delayTime) .. ", UsingBluetooth:" .. tostring(isUsingBluetooth))
  Client.GEMReportSubEvent(GameFrontendHUD, "BluetoothEvent", "BluetoothOptimization", param)
end
function AkAudioSystem.OnBluetoothHitLag()
  log(bWriteLog and "[AkAudioSystem.OnBluetoothHitLag] called")
  if AkAudioSystem.isOptimization == false then
    log(bWriteLog and "[AkAudioSystem.OnBluetoothHitLag] return by not use optimization")
    return
  end
  AkAudioSystem.isOptimization = false
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local localStoreDic = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eDefault)
  if localStoreDic == nil then
    localStoreDic = {}
  end
  localStoreDic.BTDelay = 0
  LogicPlayerPrefs.SaveDataToFile_N(localStoreDic, PlayerPrefsConfig.eDefault)
  local deviceModel = string.lower(Client.GetDeviceModel())
  local param = {}
  table.insert(param, tostring(deviceModel))
  table.insert(param, tostring(1))
  log(bWriteLog and "AkAudioSystem.OnBluetoothHitLag ReportGEM event: BluetoothEvent, subEvent: HitLap" .. ", Model:" .. deviceModel)
  Client.GEMReportSubEvent(GameFrontendHUD, "BluetoothEvent", "HitLap", param)
end
function AkAudioSystem.StartBluetoothMonitor()
  local interval = HDmpveRemote.HDmpveRemoteConfigGetInt("BluetoothMonitorInterval", 0)
  log(bWriteLog and "AkAudioSystem:StartBluetoothMonitor - interval:" .. tostring(interval))
  if interval <= 0 then
    log(bWriteLog and "AkAudioSystem:StartBluetoothMonitor - skip, interval <= 0")
    return
  end
  Client.StartBluetoothMonitor(interval)
end
function AkAudioSystem.SetupWWiseSilenceMode()
  local enableSilenceMode = false
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local silenceModeRemoteConfig = HDmpveRemote.HDmpveRemoteConfigGetBool("WWiseSilenceMode", false)
    enableSilenceMode = silenceModeRemoteConfig
  end
  Client.EnableAkAudioSilenceMode(enableSilenceMode)
end
return AkAudioSystem
local LogicGlobalSensitivity = {}
LogicGlobalSensitivity.FreeCamKeyList = {
  "VehicleEye",
  "ParachuteEye",
  "CamFpFreeEye"
}
LogicGlobalSensitivity.SensKeyList = {
  "CamLensSenNoneSniper",
  "CamLensSenNoneSniperFp",
  "CamLensSenShoulderTPP",
  "CamLensSenShoulderFPP",
  "CamLensSenRedDotSniper",
  "CamLensSen2XSniper",
  "CamLensSen3XSniper",
  "CamLensSen4XSniper",
  "CamLensSen6XSniper",
  "CamLensSen8XSniper"
}
LogicGlobalSensitivity.FireSensKeyList = {
  "FireCamLensSenNoneSniper",
  "FireCamLensSenNoneSniperFp",
  "FireCamLensSenShoulderTPP",
  "FireCamLensSenShoulderFPP",
  "FireCamLensSenRedDotSniper",
  "FireCamLensSen2XSniper",
  "FireCamLensSen3XSniper",
  "FireCamLensSen4XSniper",
  "FireCamLensSen6XSniper",
  "FireCamLensSen8XSniper"
}
LogicGlobalSensitivity.GyroSensKeyList = {
  "GyroscopeSenNoneSniper",
  "GyroscopeSenNoneSniperFp",
  "GyroscopeSenShoulderTPP",
  "GyroscopeSenShoulderFPP",
  "GyroscopeSenRedDotSniper",
  "GyroscopeSen2XSniper",
  "GyroscopeSen3XSniper",
  "GyroscopeSen4XSniper",
  "GyroscopeSen6XSniper",
  "GyroscopeSen8XSniper"
}
LogicGlobalSensitivity.GyroFireSensKeyList = {
  "FireGyroscopeSenNoneSniper",
  "FireGyroscopeSenNoneSniperFp",
  "FireGyroscopeSenShoulderTPP",
  "FireGyroscopeSenShoulderFPP",
  "FireGyroscopeSenRedDotSniper",
  "FireGyroscopeSen2XSniper",
  "FireGyroscopeSen3XSniper",
  "FireGyroscopeSen4XSniper",
  "FireGyroscopeSen6XSniper",
  "FireGyroscopeSen8XSniper"
}
LogicGlobalSensitivity.SensKeyToResID = {
  VehicleEye = 11458,
  ParachuteEye = 11459,
  CamFpFreeEye = 11460,
  CamLensSenNoneSniper = 11461,
  CamLensSenNoneSniperFp = 11462,
  CamLensSenShoulderTPP = 210044,
  CamLensSenShoulderFPP = 210045,
  CamLensSenRedDotSniper = 11463,
  CamLensSen2XSniper = 11464,
  CamLensSen3XSniper = 11465,
  CamLensSen4XSniper = 11466,
  CamLensSen6XSniper = 11467,
  CamLensSen8XSniper = 11468,
  FireCamLensSenNoneSniper = 11461,
  FireCamLensSenNoneSniperFp = 11462,
  FireCamLensSenShoulderTPP = 210044,
  FireCamLensSenShoulderFPP = 210045,
  FireCamLensSenRedDotSniper = 11463,
  FireCamLensSen2XSniper = 11464,
  FireCamLensSen3XSniper = 11465,
  FireCamLensSen4XSniper = 11466,
  FireCamLensSen6XSniper = 11467,
  FireCamLensSen8XSniper = 11468,
  GyroscopeSenNoneSniper = 11461,
  GyroscopeSenNoneSniperFp = 11462,
  GyroscopeSenShoulderTPP = 210044,
  GyroscopeSenShoulderFPP = 210045,
  GyroscopeSenRedDotSniper = 11463,
  GyroscopeSen2XSniper = 11464,
  GyroscopeSen3XSniper = 11465,
  GyroscopeSen4XSniper = 11466,
  GyroscopeSen6XSniper = 11467,
  GyroscopeSen8XSniper = 11468,
  FireGyroscopeSenNoneSniper = 11461,
  FireGyroscopeSenNoneSniperFp = 11462,
  FireGyroscopeSenShoulderTPP = 210044,
  FireGyroscopeSenShoulderFPP = 210045,
  FireGyroscopeSenRedDotSniper = 11463,
  FireGyroscopeSen2XSniper = 11464,
  FireGyroscopeSen3XSniper = 11465,
  FireGyroscopeSen4XSniper = 11466,
  FireGyroscopeSen6XSniper = 11467,
  FireGyroscopeSen8XSniper = 11468
}
LogicGlobalSensitivity.ShoulderKeys = {
  CamLensSenShoulderTPP = true,
  CamLensSenShoulderFPP = true,
  FireCamLensSenShoulderTPP = true,
  FireCamLensSenShoulderFPP = true,
  GyroscopeSenShoulderTPP = true,
  GyroscopeSenShoulderFPP = true,
  FireGyroscopeSenShoulderTPP = true,
  FireGyroscopeSenShoulderFPP = true
}
LogicGlobalSensitivity.NoMirrorKeys = {
  GyroscopeSenNoneSniper = true,
  GyroscopeSenNoneSniperFp = true,
  GyroscopeSenShoulderTPP = true,
  GyroscopeSenShoulderFPP = true,
  FireGyroscopeSenNoneSniper = true,
  FireGyroscopeSenNoneSniperFp = true,
  FireGyroscopeSenShoulderTPP = true,
  FireGyroscopeSenShoulderFPP = true
}
LogicGlobalSensitivity.PresetColumns = {
  "Low_f",
  "Middle_f",
  "High_f",
  "",
  "Official_f",
  "Master_f"
}
LogicGlobalSensitivity.CustomKeySuffix = "_0"
LogicGlobalSensitivity.CustomPresetIndex = 4
local CachedAllSensitivityKeys
function LogicGlobalSensitivity.GetAllSensitivityKeys()
  if CachedAllSensitivityKeys then
    return CachedAllSensitivityKeys
  end
  local AllKeys = {}
  for _, Key in ipairs(LogicGlobalSensitivity.FreeCamKeyList) do
    table.insert(AllKeys, Key)
  end
  for _, Key in ipairs(LogicGlobalSensitivity.SensKeyList) do
    table.insert(AllKeys, Key)
  end
  for _, Key in ipairs(LogicGlobalSensitivity.FireSensKeyList) do
    table.insert(AllKeys, Key)
  end
  for _, Key in ipairs(LogicGlobalSensitivity.GyroSensKeyList) do
    table.insert(AllKeys, Key)
  end
  for _, Key in ipairs(LogicGlobalSensitivity.GyroFireSensKeyList) do
    table.insert(AllKeys, Key)
  end
  CachedAllSensitivityKeys = AllKeys
  return CachedAllSensitivityKeys
end
function LogicGlobalSensitivity.IsGyroKey(SettingKey)
  if not SettingKey or type(SettingKey) ~= "string" then
    return false
  end
  return string.find(SettingKey, "Gyroscope") ~= nil or string.find(SettingKey, "Gyro") ~= nil
end
function LogicGlobalSensitivity.GetMaxValue(SettingKey)
  if LogicGlobalSensitivity.IsGyroKey(SettingKey) then
    return 4
  end
  return 3
end
function LogicGlobalSensitivity.GetMinValue(SettingKey)
  if LogicGlobalSensitivity.IsGyroKey(SettingKey) then
    return 0
  end
  return 0.01
end
function LogicGlobalSensitivity.GetResID(SettingKey)
  return LogicGlobalSensitivity.SensKeyToResID[SettingKey]
end
function LogicGlobalSensitivity._FilterShoulderKeys(KeyList)
  for i = #KeyList, 1, -1 do
    local Key = KeyList[i]
    if LogicGlobalSensitivity.ShoulderKeys[Key] then
      table.remove(KeyList, i)
    end
  end
  return KeyList
end
function LogicGlobalSensitivity._FilterNoMirrorKeys(KeyList)
  for i = #KeyList, 1, -1 do
    local Key = KeyList[i]
    if LogicGlobalSensitivity.NoMirrorKeys[Key] then
      table.remove(KeyList, i)
    end
  end
  return KeyList
end
function LogicGlobalSensitivity.GetFilteredKeyList(ListName)
  local SourceList = LogicGlobalSensitivity[ListName]
  if not SourceList then
    return {}
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local ShoulderEnable = SettingConfig.ShoulderEnable
  local GyroOnScope = SettingConfig.Gyroscope == 2
  local TableUtil = require("common.table_util")
  local Result = TableUtil.FastCopyTable(SourceList)
  if ShoulderEnable == false then
    Result = LogicGlobalSensitivity._FilterShoulderKeys(Result)
  end
  if GyroOnScope and (ListName == "GyroSensKeyList" or ListName == "GyroFireSensKeyList") then
    Result = LogicGlobalSensitivity._FilterNoMirrorKeys(Result)
  end
  return Result
end
function LogicGlobalSensitivity.GetFilteredAllKeys()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local ShoulderEnable = SettingConfig.ShoulderEnable
  local GyroOnScope = SettingConfig.Gyroscope == 2
  if ShoulderEnable == nil and GyroOnScope == nil then
    return LogicGlobalSensitivity.GetAllSensitivityKeys()
  end
  local TableUtil = require("common.table_util")
  local Result = TableUtil.FastCopyTable(LogicGlobalSensitivity.GetAllSensitivityKeys())
  if ShoulderEnable == false then
    Result = LogicGlobalSensitivity._FilterShoulderKeys(Result)
  end
  if GyroOnScope then
    Result = LogicGlobalSensitivity._FilterNoMirrorKeys(Result)
  end
  return Result
end
function LogicGlobalSensitivity.ApplyPresetToConfig(PresetIndex)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local PresetColumns = LogicGlobalSensitivity.PresetColumns
  local CustomKeySuffix = LogicGlobalSensitivity.CustomKeySuffix
  local CustomPresetIndex = LogicGlobalSensitivity.CustomPresetIndex
  local Gyroscope = SettingConfig.Gyroscope
  local TableName
  if Gyroscope == 0 then
    TableName = "DefaultSensitivity_GyroClose"
  elseif Gyroscope == 1 then
    TableName = "DefaultSensitivity_GyroAlwaysOpen"
  elseif Gyroscope == 2 then
    TableName = "DefaultSensitivity_GyroOnMirrorOpen"
  else
    TableName = "DefaultSensitivity_GyroClose"
  end
  print(bWriteLog and "LogicGlobalSensitivity.ApplyPresetToConfig PresetIndex=" .. tostring(PresetIndex) .. " Gyroscope=" .. tostring(Gyroscope))
  local AllKeys = LogicGlobalSensitivity.GetAllSensitivityKeys()
  for _, SettingKey in ipairs(AllKeys) do
    local curNum
    if PresetIndex == CustomPresetIndex then
      curNum = SettingConfig[SettingKey .. CustomKeySuffix]
    else
      local TableRow = CDataTable.GetTableDataByFilter(TableName, "SettingKey", SettingKey)
      if TableRow then
        local ColumnName = PresetColumns[PresetIndex]
        if ColumnName and ColumnName ~= "" then
          curNum = TableRow[ColumnName]
        end
      end
    end
    if curNum then
      SettingConfig[SettingKey] = curNum
    end
  end
end
function LogicGlobalSensitivity.SyncSensToFireSens(bGyro)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local bChanged = false
  local FireSensKeyList = bGyro and LogicGlobalSensitivity.GyroFireSensKeyList or LogicGlobalSensitivity.FireSensKeyList
  local SensKeyList = bGyro and LogicGlobalSensitivity.GyroSensKeyList or LogicGlobalSensitivity.SensKeyList
  if not assert(#SensKeyList == #FireSensKeyList, "LogicGlobalSensitivity.SyncSensToFireSens SensKeyList FireSensKeyList is not aligned") then
    return false
  end
  local Count = #SensKeyList
  for Index = 1, Count do
    local CamSettingKey = SensKeyList[Index]
    local FireSettingKey = FireSensKeyList[Index]
    if SettingConfig[FireSettingKey] ~= SettingConfig[CamSettingKey] then
      bChanged = true
    end
    SettingConfig[FireSettingKey] = SettingConfig[CamSettingKey]
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
  return bChanged
end
function LogicGlobalSensitivity.BackupToCustomKeys()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local AllKeys = LogicGlobalSensitivity.GetAllSensitivityKeys()
  local CustomKeySuffix = LogicGlobalSensitivity.CustomKeySuffix
  for _, SettingKey in ipairs(AllKeys) do
    SettingConfig[SettingKey .. CustomKeySuffix] = SettingConfig[SettingKey]
  end
  print(bWriteLog and "LogicGlobalSensitivity.BackupToCustomKeys - Backed up all sensitivity keys to custom suffix")
end
function LogicGlobalSensitivity.PreprocessCloudSetting(sen_info)
  if not sen_info then
    return nil
  end
  local SensitivityTable
  if type(sen_info.sensitivity) == "table" then
    SensitivityTable = sen_info.sensitivity
  elseif type(sen_info) == "table" then
    SensitivityTable = sen_info
  end
  if not SensitivityTable or not next(SensitivityTable) then
    return nil
  end
  local KeysToRename = {}
  for Key, _ in pairs(SensitivityTable) do
    if type(Key) == "string" and string.sub(Key, -2) == "_f" then
      table.insert(KeysToRename, Key)
    end
  end
  for _, OldKey in ipairs(KeysToRename) do
    local NewKey = string.sub(OldKey, 1, -3)
    SensitivityTable[NewKey] = SensitivityTable[OldKey]
    SensitivityTable[OldKey] = nil
  end
  SensitivityTable.FireGyroscopeSenNoneSniper = SensitivityTable.FireGyroscopeSenNoneSniper or SensitivityTable.GyroscopeSenNoneSniper
  SensitivityTable.FireGyroscopeSenRedDotSniper = SensitivityTable.FireGyroscopeSenRedDotSniper or SensitivityTable.GyroscopeSenRedDotSniper
  SensitivityTable.FireGyroscopeSen2XSniper = SensitivityTable.FireGyroscopeSen2XSniper or SensitivityTable.GyroscopeSen2XSniper
  SensitivityTable.FireGyroscopeSen4XSniper = SensitivityTable.FireGyroscopeSen4XSniper or SensitivityTable.GyroscopeSen4XSniper
  SensitivityTable.FireGyroscopeSen8XSniper = SensitivityTable.FireGyroscopeSen8XSniper or SensitivityTable.GyroscopeSen8XSniper
  SensitivityTable.FireGyroscopeSen3XSniper = SensitivityTable.FireGyroscopeSen3XSniper or SensitivityTable.GyroscopeSen3XSniper
  SensitivityTable.FireGyroscopeSen6XSniper = SensitivityTable.FireGyroscopeSen6XSniper or SensitivityTable.GyroscopeSen6XSniper
  SensitivityTable.FireGyroscopeSenNoneSniperFp = SensitivityTable.FireGyroscopeSenNoneSniperFp or SensitivityTable.GyroscopeSenNoneSniperFp
  SensitivityTable.FireGyroscopeSenShoulderTPP = SensitivityTable.FireGyroscopeSenShoulderTPP or SensitivityTable.GyroscopeSenShoulderTPP
  SensitivityTable.FireGyroscopeSenShoulderFPP = SensitivityTable.FireGyroscopeSenShoulderFPP or SensitivityTable.GyroscopeSenShoulderFPP
  return SensitivityTable
end
function LogicGlobalSensitivity.CompareGlobalSensitivityWithLocal(InData)
  if not InData then
    return false
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local AllKeys = LogicGlobalSensitivity.GetAllSensitivityKeys()
  for _, SettingKey in ipairs(AllKeys) do
    if InData[SettingKey] ~= nil and SettingConfig[SettingKey] ~= nil and InData[SettingKey] ~= SettingConfig[SettingKey] then
      return false
    elseif InData[SettingKey] == nil then
      return false
    end
  end
  return true
end
function LogicGlobalSensitivity.UseCloudSetting(CloudSetting)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local AllKeys = LogicGlobalSensitivity.GetAllSensitivityKeys()
  local bCustom = CloudSetting.CameraLensSensibility == 4
  for _, SettingKey in ipairs(AllKeys) do
    local Value = CloudSetting[SettingKey]
    if Value then
      SettingConfig[SettingKey] = Value
      if bCustom then
        SettingConfig[SettingKey .. "_0"] = Value
      end
    end
  end
  SettingConfig.CameraLensSensibility = CloudSetting.CameraLensSensibility
  SettingConfig.FireCameraLensSensibility = CloudSetting.FireCameraLensSensibility
  SettingConfig.GyroscopeSensibility = CloudSetting.GyroscopeSensibility
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function LogicGlobalSensitivity.UploadCloudSetting()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.bFireCamSenUseCam then
    LogicGlobalSensitivity.SyncSensToFireSens()
  end
  if SettingConfig.bFireGyroSenUseGryo then
    LogicGlobalSensitivity.SyncSensToFireSens(true)
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  local AllKeys = LogicGlobalSensitivity.GetAllSensitivityKeys()
  local SensibilityData = {}
  for _, SettingKey in ipairs(AllKeys) do
    SensibilityData[SettingKey] = SettingConfig[SettingKey]
  end
  SensibilityData.CameraLensSensibility = SettingConfig.CameraLensSensibility
  SensibilityData.FireCameraLensSensibility = SettingConfig.FireCameraLensSensibility
  SensibilityData.GyroscopeSensibility = SettingConfig.GyroscopeSensibility
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local temp = {sensitivity = SensibilityData}
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_save_custom_sensitive(temp)
end
function LogicGlobalSensitivity.OnUploadCloud(error_code)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "***OnSaveSensitivityResponse " .. tostring(error_code))
  if tostring(error_code) == "0" then
    ShowNotice(9644)
    LogicGlobalSensitivity.last_save_custom_sensitive_tm = TimeUtil.GetTodayStartTimestamp()
  else
    ShowNotice(9645)
  end
end
return LogicGlobalSensitivity
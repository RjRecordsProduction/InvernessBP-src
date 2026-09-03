local SettingSystem = require("client.logic.setting.logic_setting")
local local local local LogicCustomSensitivity = {
  BoolFalseValue = 10000,
  BoolTrueValue = 10001,
  GunSensitivityData = {},
  UploadTask = 0
}
local AttrTypeToSettingConfigKey = {
  camlens_nonecam_value = "CamLensSenNoneSniper",
  camlens_reddot_value = "CamLensSenRedDotSniper",
  camlens_2X_value = "CamLensSen2XSniper",
  camlens_4X_value = "CamLensSen4XSniper",
  camlens_8X_value = "CamLensSen8XSniper",
  Text_LensSensitivityFp = "CamLensSenNoneSniperFp",
  camlens_3X_value = "CamLensSen3XSniper",
  camlens_6X_value = "CamLensSen6XSniper",
  TextBlock_CTPP = "CamLensSenShoulderTPP",
  TextBlock_CFPP = "CamLensSenShoulderFPP",
  fire_nonecam_value = "FireCamLensSenNoneSniper",
  fire_reddot_value = "FireCamLensSenRedDotSniper",
  fire_2X_value = "FireCamLensSen2XSniper",
  fire_4x_value = "FireCamLensSen4XSniper",
  fire_8X_value = "FireCamLensSen8XSniper",
  TextBlock_firelensFp = "FireCamLensSenNoneSniperFp",
  fire_3X_value = "FireCamLensSen3XSniper",
  fire_6X_value = "FireCamLensSen6XSniper",
  TextBlock_FTPP = "FireCamLensSenShoulderTPP",
  Text_FFPP = "FireCamLensSenShoulderFPP",
  gyro_nonecam_value = "GyroscopeSenNoneSniper",
  gyro_reddot_value = "GyroscopeSenRedDotSniper",
  gyro_2X_value = "GyroscopeSen2XSniper",
  gyro_4X_value = "GyroscopeSen4XSniper",
  gyro_8X_value = "GyroscopeSen8XSniper",
  TextBlock_Gyro_FP = "GyroscopeSenNoneSniperFp",
  gyro_3X_value = "GyroscopeSen3XSniper",
  gyro_6X_value = "GyroscopeSen6XSniper",
  Text_GSTPP = "GyroscopeSenShoulderTPP",
  Text_GSFPP = "GyroscopeSenShoulderFPP",
  bFireGyroSenUseGryo = "bFireGyroSenUseGryo",
  TextFireGyroscopeSenNoneSniper = "FireGyroscopeSenNoneSniper",
  TextFireGyroscopeSenNoneSniperFp = "FireGyroscopeSenNoneSniperFp",
  TextFireGyroscopeSenRedDotSniper = "FireGyroscopeSenRedDotSniper",
  TextFireGyroscopeSen2XSniper = "FireGyroscopeSen2XSniper",
  TextFireGyroscopeSen3XSniper = "FireGyroscopeSen3XSniper",
  TextFireGyroscopeSen4XSniper = "FireGyroscopeSen4XSniper",
  TextFireGyroscopeSen6XSniper = "FireGyroscopeSen6XSniper",
  TextFireGyroscopeSen8XSniper = "FireGyroscopeSen8XSniper",
  TextFireGyroscopeSenShoulderTPP = "FireGyroscopeSenShoulderTPP",
  TextFireGyroscopeSenShoulderFPP = "FireGyroscopeSenShoulderFPP"
}
local SettingConfigKeyToAttrType
local AttrTypeIndexs = {
  camlens_nonecam_value = 1,
  camlens_reddot_value = 2,
  camlens_2X_value = 3,
  camlens_4X_value = 4,
  camlens_8X_value = 5,
  Text_LensSensitivityFp = 6,
  camlens_3X_value = 7,
  camlens_6X_value = 8,
  TextBlock_CTPP = 9,
  TextBlock_CFPP = 10,
  fire_nonecam_value = 11,
  fire_reddot_value = 12,
  fire_2X_value = 13,
  fire_4x_value = 14,
  fire_8X_value = 15,
  TextBlock_firelensFp = 16,
  fire_3X_value = 17,
  fire_6X_value = 18,
  TextBlock_FTPP = 19,
  Text_FFPP = 20,
  gyro_nonecam_value = 21,
  gyro_reddot_value = 22,
  gyro_2X_value = 23,
  gyro_4X_value = 24,
  gyro_8X_value = 25,
  TextBlock_Gyro_FP = 26,
  gyro_3X_value = 27,
  gyro_6X_value = 28,
  Text_GSTPP = 29,
  Text_GSFPP = 30,
  TextFireGyroscopeSenNoneSniper = 31,
  TextFireGyroscopeSenRedDotSniper = 32,
  TextFireGyroscopeSen2XSniper = 33,
  TextFireGyroscopeSen4XSniper = 34,
  TextFireGyroscopeSen8XSniper = 35,
  TextFireGyroscopeSenNoneSniperFp = 36,
  TextFireGyroscopeSen3XSniper = 37,
  TextFireGyroscopeSen6XSniper = 38,
  TextFireGyroscopeSenShoulderTPP = 39,
  TextFireGyroscopeSenShoulderFPP = 40
}
local FilterSuffixBit = {
  RedDot = 2,
  ["2X"] = 4,
  ["3X"] = 8,
  ["4X"] = 16,
  ["6X"] = 32,
  ["8X"] = 64
}
local WeaponFilterBitFlagCache = {}
function LogicCustomSensitivity.Read()
  log(bWriteLog and "LogicCustomSensitivity.Read")
  local FilePath = Client.ProjectSavedDir() .. "/SaveGames/GS.json"
  local FileStr = Client.LoadFileToStringByFullPath(FilePath)
  if FileStr ~= nil and FileStr ~= "" then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    FileStr = base64.dec(FileStr)
    LogicCustomSensitivity.GunSensitivityData = json.decode(FileStr) or {}
    table.sort(LogicCustomSensitivity.GunSensitivityData, function(a, b)
      return (a.ID or 0) < (b.ID or 0)
    end)
  else
    LogicCustomSensitivity.GunSensitivityData = {}
  end
  LogicCustomSensitivity.SetPlayerSensitivity(LogicCustomSensitivity.GunSensitivityData)
  if Client and not Client.IsShipping() then
    local MachineMirror = {
      [203006] = 1,
      [203008] = 1,
      [203009] = 1,
      [203016] = 1,
      [203010] = 1,
      [203022] = 1,
      [203100] = 1,
      [203101] = 1,
      [203017] = 1,
      [203013] = 1,
      [203023] = 1,
      [203106] = 1
    }
    local ArmoryTable = CDataTable.GetTable("ArmoryConfig")
    for k, v in pairs(ArmoryTable) do
      local WeaponID = v.WeaponID
      local bCheck = false
      local ItemCfg = CDataTable.GetTableData("Item", WeaponID)
      if ItemCfg then
        local BPID = ItemCfg.BPID
        local Cfg = CDataTable.GetTableData("WeaponAttrBPTable", BPID)
        if Cfg and Cfg.AttachmentIDList_a then
          for i, ItemID in pairs(Cfg.AttachmentIDList_a) do
            local ScopeCfg = CDataTable.GetTableData("WeaponScopeFov", ItemID .. "_" .. WeaponID)
            if ScopeCfg and not MachineMirror[tonumber(ItemID)] then
              Attach              bCheck = true
              break
            end
          end
        end
      end
      if bCheck then
        local ExistMirrorGunConfig = CDataTable.GetTableData("ExistMirrorGunConfig", WeaponID)
        if not ExistMirrorGunConfig then
          print(bWriteLog and "Config Error ExistMirrorGunConfig WeaponID = " .. tostring(WeaponID))
        end
      end
    end
  end
end
function LogicCustomSensitivity.Save(bIgnoreSetPlayer)
  log(bWriteLog and "LogicCustomSensitivity.Save")
  local Str = json.encode(LogicCustomSensitivity.GunSensitivityData)
  if Str == "" then
    return
  end
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  Str = base64.enc(Str)
  Client.SaveStringToFile(Str, "SaveGames/GS.json")
  if bIgnoreSetPlayer then
    return
  end
  LogicCustomSensitivity.SetPlayerSensitivity(LogicCustomSensitivity.GunSensitivityData)
end
function LogicCustomSensitivity.SetPlayerSensitivity(GunSensitivityData)
  log(bWriteLog and "LogicCustomSensitivity.SetPlayerSensitivity")
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.SetCustomSensibility then
    return
  end
  if GunSensitivityData then
    for Index, Data in pairs(GunSensitivityData) do
      if Data.ID and Data.Attrs then
        for Attr, Value in pairs(Data.Attrs) do
          if Value then
            local AttrIndex = AttrTypeIndexs[Attr]
            if AttrIndex ~= nil then
              PlayerController:SetCustomSensibility(Data.ID, AttrIndex, tonumber(Value))
            end
          end
        end
      end
    end
  end
end
function LogicCustomSensitivity.SetPlayerSensitivityByWeapon(WeaponID, SettingKey)
  log(bWriteLog and "LogicCustomSensitivity.SetPlayerSensitivityByWeapon WeaponID=" .. tostring(WeaponID) .. " SettingKey=" .. tostring(SettingKey))
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.SetCustomSensibility then
    return
  end
  local Data = LogicCustomSensitivity.GetWeaponData(WeaponID)
  if Data and Data.ID and Data.Attrs then
    if SettingKey then
      local Attr = LogicCustomSensitivity.GetAttrFromSettingKey(SettingKey)
      if Attr then
        local Value = Data.Attrs[Attr]
        if Value then
          local AttrIndex = AttrTypeIndexs[Attr]
          if AttrIndex ~= nil then
            PlayerController:SetCustomSensibility(Data.ID, AttrIndex, tonumber(Value))
          end
        end
      end
      return
    end
    for Attr, Value in pairs(Data.Attrs) do
      if Value then
        local AttrIndex = AttrTypeIndexs[Attr]
        if AttrIndex ~= nil then
          PlayerController:SetCustomSensibility(Data.ID, AttrIndex, tonumber(Value))
        end
      end
    end
  end
end
function LogicCustomSensitivity.RemovePlayerSensitivity(WeaponID)
  log(bWriteLog and "LogicCustomSensitivity.RemovePlayerSensitivity WeaponID=" .. WeaponID)
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.RemoveCustomSensibility then
    return
  end
  PlayerController:RemoveCustomSensibility(WeaponID)
end
function LogicCustomSensitivity.GetSensitivityData()
  log(bWriteLog and "LogicCustomSensitivity.GetSensitivityData")
  return LogicCustomSensitivity.GunSensitivityData
end
function LogicCustomSensitivity.UseCloudData(CloudGunSensitivityData)
  if not CloudGunSensitivityData then
    print(bWriteLog and "LogicCustomSensitivity.UseCloudData not CloudGunSensitivityData")
    return
  end
  local OnlyLocalWeaponIDs
  for IndexInOrigin, OriginData in pairs(LogicCustomSensitivity.GunSensitivityData) do
    local bCloudExist = false
    for IndexInCloud, CloudData in pairs(CloudGunSensitivityData) do
      if OriginData.ID == CloudData.ID then
        bCloudExist = true
        break
      end
    end
    if not bCloudExist then
      OnlyLocalWeaponIDs = OnlyLocalWeaponIDs or {}
      table.insert(OnlyLocalWeaponIDs, OriginData.ID)
    end
  end
  if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.SingleTraining_Sensitivity_List then
    local SingleTrainingSensitivityList = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sensitivity_List)
    if SingleTrainingSensitivityList then
      local CurWeaponID = SingleTrainingSensitivityList:GetCurWeaponID()
      if CurWeaponID then
        local bCloudExist = false
        for IndexInCloud, CloudData in pairs(CloudGunSensitivityData) do
          if CurWeaponID == CloudData.ID then
            bCloudExist = true
            break
          end
        end
        if bCloudExist then
          OnlyLocalWeaponIDs = nil
        else
          OnlyLocalWeaponIDs = {}
          table.insert(OnlyLocalWeaponIDs, CurWeaponID)
        end
      end
    end
  end
  if OnlyLocalWeaponIDs then
    local WeaponStr = ""
    for _, WeaponID in pairs(OnlyLocalWeaponIDs) do
      local WeaponConfig = CDataTable.GetTableData("ArmoryDescConfig", WeaponID)
      if WeaponConfig then
        WeaponStr = WeaponStr .. WeaponConfig.ArmorySimpleDesc .. " "
      end
    end
    local Msg = LocUtil.LocalizeResFormat("21145", WeaponStr)
    ShowNotice(Msg)
  end
  for IndexInCloud, CloudData in pairs(CloudGunSensitivityData) do
    local bLocalExist = false
    for IndexInOrigin, OriginData in pairs(LogicCustomSensitivity.GunSensitivityData) do
      if OriginData.ID == CloudData.ID then
        bLocalExist = true
        OriginData.Attrs = CloudData.Attrs
        break
      end
    end
    if not bLocalExist then
      table.insert(LogicCustomSensitivity.GunSensitivityData, CloudData)
    end
  end
  LogicCustomSensitivity.Save()
end
function LogicCustomSensitivity._GetFilterBitFlag(WeaponID)
  if WeaponFilterBitFlagCache[WeaponID] then
    return WeaponFilterBitFlagCache[WeaponID]
  end
  local bMelee = false
  local WeaponConfig = CDataTable.GetTableData("ArmoryConfig", WeaponID)
  if WeaponConfig then
    bMelee = WeaponConfig.WeaponType == 8
  end
  if bMelee then
    return 0
  end
  local WeaponAttCfg = CDataTable.GetTableData("WeaponAttachments", WeaponID)
  if not WeaponAttCfg then
    return nil
  end
  local SupportIDs = {}
  if WeaponAttCfg then
    local ItemIDStr = WeaponAttCfg.Uppers_a
    if ItemIDStr then
      for Index = 0, ItemIDStr:Num() - 1 do
        local ItemID = tonumber(ItemIDStr:Get(Index))
        if ItemID and ItemID ~= 0 then
          SupportIDs[ItemID] = true
        end
      end
    end
  end
  local BitFlag = 0
  if SupportIDs[203001] or SupportIDs[203002] then
    BitFlag = BitFlag | FilterSuffixBit.RedDot
  end
  if SupportIDs[203003] then
    BitFlag = BitFlag | FilterSuffixBit["2X"]
  end
  if SupportIDs[203014] then
    BitFlag = BitFlag | FilterSuffixBit["3X"]
  end
  if SupportIDs[203004] then
    BitFlag = BitFlag | FilterSuffixBit["4X"]
  end
  if SupportIDs[203015] then
    BitFlag = BitFlag | FilterSuffixBit["6X"]
  end
  if SupportIDs[203005] then
    BitFlag = BitFlag | FilterSuffixBit["8X"]
  end
  if BitFlag == 0 then
    local SpecialSuffix = LogicCustomSensitivity._GetSpecialSupportSuffix(WeaponID)
    if SpecialSuffix and FilterSuffixBit[SpecialSuffix] then
      BitFlag = BitFlag | FilterSuffixBit[SpecialSuffix]
    end
  end
  WeaponFilterBitFlagCache[WeaponID] = BitFlag
  return BitFlag
end
function LogicCustomSensitivity.FilterWeaponData(WeaponData)
  local WeaponID = WeaponData.ID
  local BitFlag = LogicCustomSensitivity._GetFilterBitFlag(WeaponID)
  if WeaponData.Attrs then
    for Attr, Value in pairs(WeaponData.Attrs) do
      for Suffix, Bit in pairs(FilterSuffixBit) do
        if BitFlag & Bit == 0 and string.find(Attr:lower(), Suffix:lower(), 1, true) then
          WeaponData.Attrs[Attr] = nil
        end
      end
    end
  end
end
function LogicCustomSensitivity.GetFilteredKeyList(ListName, WeaponID)
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  local Result = LogicGlobalSensitivity.GetFilteredKeyList(ListName)
  if not WeaponID then
    return Result
  end
  local BitFlag = LogicCustomSensitivity._GetFilterBitFlag(WeaponID)
  for i = #Result, 1, -1 do
    local Key = Result[i]
    for Suffix, Bit in pairs(FilterSuffixBit) do
      if BitFlag & Bit == 0 and string.find(Key, Suffix, 1, true) then
        table.remove(Result, i)
        break
      end
    end
  end
  return Result
end
function LogicCustomSensitivity.GetFilteredAllKeys(WeaponID)
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  local Result = LogicGlobalSensitivity.GetFilteredAllKeys()
  if not WeaponID then
    return Result
  end
  local BitFlag = LogicCustomSensitivity._GetFilterBitFlag(WeaponID)
  for i = #Result, 1, -1 do
    local Key = Result[i]
    for Suffix, Bit in pairs(FilterSuffixBit) do
      if BitFlag & Bit == 0 and string.find(Key, Suffix, 1, true) then
        table.remove(Result, i)
        break
      end
    end
  end
  return Result
end
local MirrorScaleToSuffix = {
  [1] = "RedDot",
  [2] = "2X",
  [3] = "3X",
  [4] = "4X",
  [6] = "6X",
  [8] = "8X"
}
function LogicCustomSensitivity._GetSpecialSupportSuffix(WeaponID)
  local UBackpackUtils = import("BackpackUtils")
  WeaponID = UBackpackUtils.GetWeaponIDBySkinID(slua_GameFrontendHUD:GetWorld(), WeaponID)
  local ExistMirrorGunConfig = CDataTable.GetTableData("ExistMirrorGunConfig", WeaponID)
  if ExistMirrorGunConfig then
    return MirrorScaleToSuffix[ExistMirrorGunConfig.MirrorScale]
  end
  return "RedDot"
end
function LogicCustomSensitivity.GetWeaponTypeData(WeaponType)
  log(bWriteLog and "LogicCustomSensitivity.GetWeaponTypeData WeaponType=" .. WeaponType)
  local CurWeaponTypeData = {}
  for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    local WeaponConfig = CDataTable.GetTableData("ArmoryConfig", Data.ID)
    if WeaponConfig and WeaponConfig.WeaponType == WeaponType then
      table.insert(CurWeaponTypeData, Data)
    end
  end
  return CurWeaponTypeData
end
function LogicCustomSensitivity.GetWeaponSensitivityData(WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      return Data
    end
  end
end
function LogicCustomSensitivity.GetAttrFromSettingKey(SettingKey)
  if not SettingConfigKeyToAttrType then
    SettingConfigKeyToAttrType = {}
    for k, v in pairs(AttrTypeToSettingConfigKey) do
      SettingConfigKeyToAttrType[v] = k
    end
  end
  return SettingConfigKeyToAttrType[SettingKey]
end
function LogicCustomSensitivity.GetSettingKeyFromAttr(Attr)
  return AttrTypeToSettingConfigKey[Attr]
end
function LogicCustomSensitivity.GetAttrTypeByAttrTypeIndex(AttrTypeIndex)
  for Key, Value in pairs(AttrTypeIndexs) do
    if Value == AttrTypeIndex then
      return Key
    end
  end
end
function LogicCustomSensitivity.GetWeaponData(WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return nil
  end
  local Count = #LogicCustomSensitivity.GunSensitivityData
  for Index = 1, Count do
    local Data = LogicCustomSensitivity.GunSensitivityData[Index]
    if Data.ID == WeaponID then
      return Data
    end
  end
  return nil
end
function LogicCustomSensitivity.IsWeaponHasFireSens(WeaponID)
  local Data = LogicCustomSensitivity.GetWeaponData(WeaponID)
  if Data then
    return Data.Attrs.bFireGyroSenUseGryo == LogicCustomSensitivity.BoolFalseValue
  end
end
function LogicCustomSensitivity.SetWeaponHasFireSens(WeaponID, bValue)
  local Data = LogicCustomSensitivity.GetWeaponData(WeaponID)
  if Data then
    Data.Attrs.bFireGyroSenUseGryo = bValue and LogicCustomSensitivity.BoolFalseValue or LogicCustomSensitivity.BoolTrueValue
  end
end
function LogicCustomSensitivity.GetWeaponSens(WeaponID, SettingKey)
  local Data = LogicCustomSensitivity.GetWeaponData(WeaponID)
  if Data then
    local Attr = LogicCustomSensitivity.GetAttrFromSettingKey(SettingKey)
    return Data.Attrs[Attr]
  end
end
function LogicCustomSensitivity.SetWeaponSens(WeaponID, SettingKey, Value)
  local Data = LogicCustomSensitivity.GetWeaponData(WeaponID)
  if Data then
    local Attr = LogicCustomSensitivity.GetAttrFromSettingKey(SettingKey)
    Data.Attrs[Attr] = Value
    LogicCustomSensitivity.TLogRecordAddCount(WeaponID, Attr)
  end
end
function LogicCustomSensitivity.AddWeaponSensitivity(WeaponID)
  log(bWriteLog and "LogicCustomSensitivity.AddWeaponSensitivity WeaponID=" .. WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  for _, Data in ipairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      print(bWriteLog and "LogicCustomSensitivity.AddWeaponSensitivity Add Existed Weapon")
      return false
    end
  end
  local NewGunData = {ID = WeaponID}
  table.insert(LogicCustomSensitivity.GunSensitivityData, NewGunData)
  table.sort(LogicCustomSensitivity.GunSensitivityData, function(a, b)
    return (a.ID or 0) < (b.ID or 0)
  end)
  LogicCustomSensitivity.ResetWeaponSensitivity(WeaponID)
end
function LogicCustomSensitivity.ResetWeaponSensitivity(WeaponID)
  if not WeaponID then
    print(bWriteLog and "LogicCustomSensitivity.ResetWeaponSensitivity not WeaponID")
    return
  end
  log(bWriteLog and "LogicCustomSensitivity.ResetWeaponSensitivity WeaponID=" .. WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  local BitFlag = LogicCustomSensitivity._GetFilterBitFlag(WeaponID)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      if not Data.Attrs then
        Data.Attrs = {}
      end
      for Attr, SettingKey in pairs(AttrTypeToSettingConfigKey) do
        for Suffix, Bit in pairs(FilterSuffixBit) do
          if BitFlag & Bit == 0 and string.find(SettingKey, Suffix, 1, true) then
          else
            Data.Attrs[Attr] = SettingConfig[SettingKey]
          end
        end
      end
      break
    end
  end
  LogicCustomSensitivity.Save()
end
function LogicCustomSensitivity.RemoveWeaponSensitivity(WeaponID)
  log(bWriteLog and "LogicCustomSensitivity.RemoveWeaponSensitivity WeaponID=" .. WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      table.remove(LogicCustomSensitivity.GunSensitivityData, Index)
      break
    end
  end
  LogicCustomSensitivity.Save(true)
  LogicCustomSensitivity.RemovePlayerSensitivity(WeaponID)
end
function LogicCustomSensitivity.CopyWeaponSensitivity(WeaponID, CopyWhichWeaponID)
  log(bWriteLog and "LogicCustomSensitivity.CopyWeaponSensitivity WeaponID=" .. WeaponID .. " CopyWhichWeaponID=" .. CopyWhichWeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  local CurWeaponAttrs, CopySrcAttrs
  for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      CurWeaponAttrs = Data.Attrs
    elseif Data.ID == CopyWhichWeaponID then
      CopySrcAttrs = Data.Attrs
    end
  end
  if not CurWeaponAttrs or not CopySrcAttrs then
    return
  end
  local BitFlag = LogicCustomSensitivity._GetFilterBitFlag(CopyWhichWeaponID)
  for Attr, Value in pairs(CopySrcAttrs) do
    local bRemoved = false
    for Suffix, Bit in pairs(FilterSuffixBit) do
      if BitFlag & Bit == 0 and string.find(Attr:lower(), Suffix:lower(), 1, true) then
        CopySrcAttrs[Attr] = nil
        bRemoved = true
        break
      end
    end
    if not bRemoved then
      CurWeaponAttrs[Attr] = Value
    end
  end
  LogicCustomSensitivity.Save()
end
function LogicCustomSensitivity.SetWeaponSens_Playground(WeaponID, SettingKey, Value)
  if not LogicCustomSensitivity.HasCurWeaponConfig(WeaponID) then
    LogicCustomSensitivity.AddWeaponSensitivity(WeaponID)
    LogicCustomSensitivity.AddSingleTrainingAddWeapons(WeaponID)
  end
  LogicCustomSensitivity.SetWeaponSens(WeaponID, SettingKey, Value)
end
function LogicCustomSensitivity.AddSingleTrainingAddWeapons(WeaponID)
  if not WeaponID then
    return
  end
  log(bWriteLog and "LogicCustomSensitivity.AddSingleTrainingAddWeapons WeaponID=" .. WeaponID)
  if not LogicCustomSensitivity.SingleTrainingAddWeaponIDs then
    LogicCustomSensitivity.SingleTrainingAddWeaponIDs = {}
  end
  LogicCustomSensitivity.SingleTrainingAddWeaponIDs[WeaponID] = 1
end
function LogicCustomSensitivity.IsCopyAvailable(WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData or not WeaponID then
    print(bWriteLog and "LogicCustomSensitivity.IsCopyAvailable Fail not LogicCustomSensitivity.GunSensitivityData or not WeaponID")
    return false
  end
  log(bWriteLog and "LogicCustomSensitivity.IsCopyAvailable WeaponID=" .. WeaponID)
  local WeaponCount = 0
  for _, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID and Data.ID ~= WeaponID then
      WeaponCount = WeaponCount + 1
      if 1 <= WeaponCount then
        break
      end
    end
  end
  if 1 <= WeaponCount then
    return true
  end
  return false
end
function LogicCustomSensitivity.HasCurWeaponConfig(WeaponID)
  if not WeaponID then
    return false
  end
  log(bWriteLog and "LogicCustomSensitivity.HasCurWeaponConfig WeaponID=" .. WeaponID)
  if not LogicCustomSensitivity.GunSensitivityData then
    return false
  end
  for _, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
    if Data.ID == WeaponID then
      return true
    end
  end
  return false
end
function LogicCustomSensitivity.IsCloudAvailable()
  return true
end
function LogicCustomSensitivity.FireGyroSensitivityUseFireGyro(WeaponID)
  if not WeaponID then
    print(bWriteLog and "LogicCustomSensitivity.FireGyroSensitivityUseFireGyro - WeaponID is nil")
    return false
  end
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  for Index, GyroKey in ipairs(LogicGlobalSensitivity.GyroSensKeyList) do
    local FireGyroKey = LogicGlobalSensitivity.GyroFireSensKeyList[Index]
    if GyroKey and FireGyroKey then
      local Value = LogicCustomSensitivity.GetWeaponSens(WeaponID, GyroKey)
      if Value then
        LogicCustomSensitivity.SetWeaponSens(WeaponID, FireGyroKey, Value)
      end
    end
  end
  return true
end
local FLOAT_EPSILON = 1.0E-8
local _CompareFloatValue = function(Val1, Val2)
  if type(Val1) == "number" and type(Val2) == "number" then
    return math.abs(Val1 - Val2) < 0.01 - FLOAT_EPSILON
  else
    return Val1 == Val2
  end
end
function LogicCustomSensitivity.CompareGunDataWithLocal(GunDataList)
  local LocalData = LogicCustomSensitivity.GunSensitivityData
  if not LocalData or not GunDataList then
    return false
  end
  if #LocalData ~= #GunDataList then
    print(bWriteLog and string.format("LogicCustomSensitivity.CompareGunDataWithLocal local has fewer items, local=%d, remote=%d", #LocalData, #GunDataList))
    return false
  end
  local RemoteDataMap = {}
  for _, RemoteItem in ipairs(GunDataList) do
    if RemoteItem.ID then
      RemoteDataMap[RemoteItem.ID] = RemoteItem
    end
  end
  for _, LocalItem in ipairs(LocalData) do
    local LocalID = LocalItem.ID
    local RemoteItem = RemoteDataMap[LocalID]
    if not RemoteItem then
      print(bWriteLog and string.format("LogicCustomSensitivity.CompareGunDataWithLocal ID=%s not found in remote", tostring(LocalID)))
      return false
    end
    local LocalAttrs = LocalItem.Attrs
    local RemoteAttrs = RemoteItem.Attrs
    if not LocalAttrs or not RemoteAttrs then
      if LocalAttrs ~= RemoteAttrs then
        print(bWriteLog and string.format("LogicCustomSensitivity.CompareGunDataWithLocal ID=%s Attrs nil mismatch", tostring(LocalID)))
        return false
      end
    else
      for AttrKey, LocalVal in pairs(LocalAttrs) do
        local RemoteVal = RemoteAttrs[AttrKey]
        if not _CompareFloatValue(LocalVal, RemoteVal) then
          print(bWriteLog and string.format("LogicCustomSensitivity.CompareGunDataWithLocal ID=%s Key=%s local=%s remote=%s", tostring(LocalID), tostring(AttrKey), tostring(LocalVal), tostring(RemoteVal)))
          return false
        end
      end
    end
  end
  return true
end
function LogicCustomSensitivity.UploadCloudSettingForEachWeapon()
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimer(0, function()
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    LogicCustomSensitivity.UploadTask = 10
    for WeaponType = 1, 10 do
      local CurWeaponTypeData = LogicCustomSensitivity.GetWeaponTypeData(WeaponType)
      if CurWeaponTypeData then
        local Data = json.encode(CurWeaponTypeData)
        if Data ~= "" then
          Data = base64.enc(Data)
          SettingHandler.send_save_weapon_settings_req(Data, 1, WeaponType)
          print(bWriteLog and "LogGunSens Upload", WeaponType, #CurWeaponTypeData, #Data)
        end
      end
      coroutine.yield(0.15)
    end
  end)
end
function LogicCustomSensitivity.OnUploadCloud()
  LogicCustomSensitivity.UploadTask = LogicCustomSensitivity.UploadTask - 1
  if LogicCustomSensitivity.UploadTask == 0 then
    ShowNotice(9644)
    local TimeUtil = require("client.common.time_util")
    LogicCustomSensitivity.last_save_weapon_settings_tm = TimeUtil.GetTodayStartTimestamp()
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPLOAD_SUCCESS)
  end
end
function LogicCustomSensitivity.IsUploading()
  return LogicCustomSensitivity.UploadTask > 1
end
function LogicCustomSensitivity.ShowTextDialog(WeaponID, FuncOnSure, Text, Title, FuncOnCancel)
  log(bWriteLog and "LogicCustomSensitivity.ShowTextDialog WeaponID=" .. WeaponID)
  if UIManager and UIManager.UI_Config and UIManager.UI_Config.setting_gun_sensitivity_popup then
    local PopUp = UIManager.ShowUI(UIManager.UI_Config.setting_gun_sensitivity_popup)
    PopUp:SetType(LogicCustomSensitivity.GetSensitivityData(), WeaponID, FuncOnSure, Text, Title, FuncOnCancel)
  end
end
function LogicCustomSensitivity.ShowChooseWeaponDialog(WeaponType, FuncOnSure, ParentUIBP, bShowAll, bShowMelee, bShowOther, WantCopyWeaponID, FuncOnCancel)
  log(bWriteLog and "LogicCustomSensitivity.ShowChooseWeaponDialog WeaponType=" .. WeaponType)
  if UIManager and UIManager.UI_Config and UIManager.UI_Config.setting_gun_accessories_popup then
    local PopUp = UIManager.ShowUI(UIManager.UI_Config.setting_gun_accessories_popup)
    PopUp:RefreshUI(WeaponType, LogicCustomSensitivity.GetSensitivityData(), FuncOnSure, ParentUIBP, bShowAll, bShowMelee, bShowOther, WantCopyWeaponID, FuncOnCancel)
  end
end
function LogicCustomSensitivity.TLogRecordAddCount(WeaponID, AttrType)
  if not WeaponID then
    return
  end
  log(bWriteLog and "LogicCustomSensitivity.TLogRecordAddCount WeaponID=" .. WeaponID .. " AttrType=" .. AttrType)
  if not BP_Setting_Sensitivity_CountInfo then
    BP_Setting_Sensitivity_CountInfo = {}
    BP_Setting_Sensitivity_CountInfo_Attr = {}
  end
  if not BP_Setting_Sensitivity_CountInfo[WeaponID] then
    BP_Setting_Sensitivity_CountInfo[WeaponID] = 0
    if not BP_Setting_Sensitivity_CountInfo_Attr then
      BP_Setting_Sensitivity_CountInfo_Attr = {}
    end
    BP_Setting_Sensitivity_CountInfo_Attr[WeaponID] = {}
  end
  if BP_Setting_Sensitivity_CountInfo_Attr and BP_Setting_Sensitivity_CountInfo_Attr[WeaponID] and not BP_Setting_Sensitivity_CountInfo_Attr[WeaponID][AttrType] then
    BP_Setting_Sensitivity_CountInfo[WeaponID] = BP_Setting_Sensitivity_CountInfo[WeaponID] + 1
    BP_Setting_Sensitivity_CountInfo_Attr[WeaponID][AttrType] = true
  end
end
function LogicCustomSensitivity.NewbieGuidedEnterStart(UIRoot)
  log(bWriteLog and "LogicCustomSensitivity.GuidedEnter")
  if not LogicCustomSensitivity.GunSensitivityData then
    return
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.bGunSensitivityGuidedEnter then
  else
    local bExistWeaponConfig = false
    for Index, Data in pairs(LogicCustomSensitivity.GunSensitivityData) do
      if Data.ID then
        bExistWeaponConfig = true
        break
      end
    end
    if not bExistWeaponConfig then
    end
  end
end
function LogicCustomSensitivity.NewbieGuidedEnterEnd(UIRoot)
  log(bWriteLog and "LogicCustomSensitivity.NewbieGuidedEnterEnd")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bGunSensitivityGuidedEnter = true
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function LogicCustomSensitivity.NewbieGuidedAddStart(UIRoot, CurWeaponCount)
  log(bWriteLog and "LogicCustomSensitivity.NewbieGuidedAddStart")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.bGunSensitivityGuidedAdd then
    UIRoot.CanvasPanel_8:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    UIRoot.CanvasPanel_8:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if UIRoot.TextBlock_4 then
      UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(21137))
    end
  end
end
function LogicCustomSensitivity.NewbieGuidedAddEnd(UIRoot)
  log(bWriteLog and "LogicCustomSensitivity.NewbieGuidedAddEnd")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bGunSensitivityGuidedAdd = true
  slua_GameFrontendHUD:FinishModifyUserSettings()
  UIRoot.CanvasPanel_8:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function LogicCustomSensitivity.NewbieGuidedCopyStart(UIRoot, WeaponID)
  log(bWriteLog and "LogicCustomSensitivity.NewbieGuidedCopyStart")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.bGunSensitivityGuidedCopy then
    UIRoot.CanvasPanel_11:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif LogicCustomSensitivity.IsCopyAvailable(WeaponID) then
    UIRoot.CanvasPanel_11:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.TextBlock_9:SetText(LocUtil.GetLocalizeResStr(21138))
  end
end
function LogicCustomSensitivity.NewbieGuidedCopyEnd(UIRoot)
  log(bWriteLog and "LogicCustomSensitivity.NewbieGuidedCopyEnd")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bGunSensitivityGuidedCopy = true
  slua_GameFrontendHUD:FinishModifyUserSettings()
  UIRoot.CanvasPanel_11:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
return LogicCustomSensitivity
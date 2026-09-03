local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local UIUtil = require("client.common.ui_util")
local CustomType = require("client.logic.setting.CustomType")
local SavEncodeSystem = require("client.logic.setting.SavEncodeSystem")
local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
local SettingSystem = {
  CheckNameReason = "",
  CheckNameReasonRenameItem1 = "RenameItem1",
  CheckNameReasonRenameItem2 = "RenameItem2",
  setRegion = nil,
  NBindChannel = 0,
  NBindExtType = 0,
  NBindRetCode = 0,
  NBindThirdRetCode = 0,
  NIMSDKNotifyEvent = 0,
  NUnbindChannel = 0,
  SUnbindDays = "",
  UnbindIsShow = false,
  NIMSDKTipMsgBtnOKEvent = 0,
  BUseCfg = false,
  nPushResId = 4982,
  BInDebugMode = false,
  SettingSwitchOpVersion = "Setting_SwitchOpVersion",
  SettingPopVersion = "Setting_PopVersion",
  DebugSuggestion = require("client.logic.setting.logic_setting_debug_suggestion"),
  ShareCodePrefix = {ReleaseVersion = 1, CEVersion = 2}
}
local local BP_Setting_UploadType = 0
local TempBlackList = {
  NCL_CL_L0 = true,
  NCL_CL_L1 = true,
  NCL_CL_L2 = true,
  NCL_CLF_L0 = true,
  NCL_CLF_L1 = true,
  NCL_CLF_L2 = true,
  NCL_TD = true,
  NCL_TDF = true,
  NCL_VH = true,
  NCL_WC = true
}
function SettingSystem.GetLayoutFileDataConfig(nIndex)
  print(bWriteLog and "SettingSystem.GetLayoutFileDataConfig")
  local bSuccessful = false
  local config, sFileName
  if nIndex then
    sFileName = Setting_UIElemLayout_Interface.GetSlotNameByIndex_Legacy(nIndex)
    bSuccessful, config = SavEncodeSystem.LoadFile(sFileName, SavEncodeSystem.PreferredEncodeType)
    if bSuccessful and config then
      local TryAgainCount = 0
      for i = 1, SavEncodeSystem.TryAgainCount do
        SavEncodeSystem.SaveFile("UIElemLayout_Slot_Temp", config, SavEncodeSystem.PreferredEncodeType)
        if SavEncodeSystem.ValidateSaveFile(sFileName) then
          bSuccessful = true
          break
        else
          TryAgainCount = TryAgainCount + 1
          bSuccessful = false
          bSuccessful, config = SavEncodeSystem.LoadFile(sFileName, SavEncodeSystem.PreferredEncodeType)
        end
      end
      Client.DeleteFile(Client.ProjectSavedDir() .. "/SaveGames/UIElemLayout_Slot_Temp.sav")
      if 0 < TryAgainCount then
        local DeviceOSInfo = require("client.logic.data.data_device_os")
        local ReportEvent = HDmpveRemote.HDmpveRemoteConfigGetInt("ValidateSaveFileReportEvent", 1)
        if 0 < ReportEvent then
          local param = {
            slot_index = tostring(nIndex + 100),
            i_case = tostring(3),
            try_again = tostring(TryAgainCount)
          }
          log(bWriteLog and "  report openid = " .. tostring(param.openid))
          log_tree("param", param)
          Client.GEMReportSubEvent(GameFrontendHUD, "UDPPingEvent", "SavFailedReport", param)
        end
      end
    end
    print(bWriteLog and "  nIndex = ", nIndex, " FileName = ", sFileName)
  end
  if not bSuccessful or config == nil then
    print(bWriteLog and "  Load sav file failed")
    return false
  end
  if Client.IsDevelopment() then
    log_tree("  Config", config)
  end
  return config
end
function SettingSystem.query_custom_setting(slotType)
  if TempBlackList[slotType] then
    print(bWriteLog and "SettingSystem.query_custom_setting hit blacklist")
    return
  end
  print(bWriteLog and "SettingSystem.query_custom_setting: " .. slotType)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_query_custom_setting(slotType)
end
function SettingSystem.IsNeedQueryCustomSetting(SlotType, CloudVer)
  print(bWriteLog and string.format("SettingSystem.IsNeedQueryCustomSetting SlotType=%s, CloudVer=%d", tostring(SlotType), CloudVer))
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not SettingConfig then
    print(bWriteLog and "SettingSystem.IsNeedQueryCustomSetting not SettingConfig")
    return true
  end
  local VersionsMap
  if type(SlotType) == "number" then
    VersionsMap = SettingConfig.setting_ver_info
  elseif type(SlotType) == "string" then
    VersionsMap = SettingConfig.LayoutSlotVersions
  end
  if not VersionsMap then
    print(bWriteLog and "SettingSystem.IsNeedQueryCustomSetting not VersionsMap")
    return true
  end
  local CurVer = VersionsMap:Get(SlotType)
  if not CurVer then
    VersionsMap:Add(SlotType, CloudVer)
    slua_GameFrontendHUD:FinishModifyUserSettings()
    print(bWriteLog and "SettingSystem.IsNeedQueryCustomSetting not CurVer")
    return true
  end
  print(bWriteLog and string.format("SettingSystem.IsNeedQueryCustomSetting CurVer=%d, CloudVer=%d", CurVer, CloudVer))
  if CloudVer < CurVer then
    VersionsMap:Add(SlotType, CloudVer)
    slua_GameFrontendHUD:FinishModifyUserSettings()
    return false
  end
  return CloudVer > CurVer
end
function SettingSystem.dirty_name_check_req(newName, reason)
  SettingSystem.CheckNameReason = reason
  log(bWriteLog and "dirty_name_check_req newName = " .. tostring(newName) .. ", reason = " .. tostring(reason))
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_dirty_name_check_req(newName, reason)
end
function SettingSystem.save_custom_setting(setting_info, _, operType, SlotType)
  local SlotTypeVersion = 0
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    local VersionsMap
    if type(SlotType) == "number" then
      VersionsMap = SettingConfig.setting_ver_info
    elseif type(SlotType) == "string" then
      VersionsMap = SettingConfig.LayoutSlotVersions
    end
    if VersionsMap then
      SlotTypeVersion = VersionsMap:Get(SlotType) or 0
      VersionsMap:Add(SlotType, SlotTypeVersion + 1)
      slua_GameFrontendHUD:FinishModifyUserSettings()
    end
  end
  log(bWriteLog and string.format("save_custom_setting SlotType=%s, SlotTypeVersion=%d", tostring(SlotType), SlotTypeVersion))
  if type(setting_info) == "string" then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LayoutSaveSizeStat, 0, string.format("Type=%s,Size=%d", SlotType, #setting_info))
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_save_custom_setting(setting_info, operType, SlotType)
end
function SettingSystem.dirty_name_check_rsp(result)
  log(bWriteLog and "dirty_name_check_rsp result = " .. tostring(result))
  if tostring(result) == NetErrorCode_NONE then
  else
    ShowNotice(411019)
  end
  if tostring(result) ~= NetErrorCode_NONE then
  end
end
function SettingSystem.sync_custom_setting(setting_info, slotType, setting_ver_info)
  print(bWriteLog and string.format("SettingSystem.sync_custom_setting slotType=%s, setting_ver_info=%s", tostring(slotType), tostring(setting_ver_info)))
  log_tree("SettingSystem.sync_custom_setting\n", setting_info)
  if not setting_info then
    print(bWriteLog and "setting_info is nil")
    return
  end
  if TempBlackList[slotType] then
    print(bWriteLog and "SettingSystem.sync_custom_setting hit blacklist")
    return
  end
  if setting_ver_info then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if SettingConfig then
      local VersionsMap
      if type(slotType) == "number" then
        VersionsMap = SettingConfig.setting_ver_info
      elseif type(slotType) == "string" then
        VersionsMap = SettingConfig.LayoutSlotVersions
      end
      if VersionsMap then
        VersionsMap:Add(slotType, setting_ver_info)
        slua_GameFrontendHUD:FinishModifyUserSettings()
      end
    end
  end
  if slotType == 1 then
    if setting_info.Config ~= nil then
      local config = setting_info.Config
      SettingSystem.UseSettingConfig(config)
    else
      LuaClassObj.HandleUIMessage(bp_global, "LoadSettingConfigFromSlot")
    end
  elseif slotType == 2 then
    local singleLogic = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
    singleLogic.InitCustomizeSetting(setting_info)
  elseif type(slotType) == "number" and 100 <= slotType and slotType <= 111 then
    if setting_info.Config and setting_info.Index then
      SettingSystem.SyncCustomConfig_Legacy(setting_info)
    elseif setting_info.UseIndex and setting_info.DataMap then
      local Data = setting_info.DataMap[setting_info.UseIndex]
      if Data and Data.Config then
        SettingSystem.SyncCustomConfig_Legacy({
          Index = setting_info.UseIndex,
          Config = Data.Config
        })
      end
    end
  elseif type(slotType) == "string" and string.find(slotType, "NCL_") and type(setting_info) == "string" then
    SettingSystem.SyncCustomConfig_New(setting_info)
  end
  SettingSystem.CheckCustomSettingGameVersion()
end
function SettingSystem.SyncCustomConfig_New(setting_info)
  print(bWriteLog and "SettingSystem.SyncCustomConfig_New")
  local CustomLayoutArchiver = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutArchiver")
  local decodedData = slua.LuaArchiverDecode(LuaStateWrapper, setting_info)
  local SaveGame = CustomLayoutArchiver.LoadSaveGameFromTable(decodedData)
  if slua.isValid(SaveGame) then
    local OldSaveGame = CustomLayoutArchiver.LoadFile(SaveGame.SaveSlotName)
    if OldSaveGame then
      print(bWriteLog and string.format("SettingSystem.SyncCustomConfig_New old file name:%s, last_save_time:%s", OldSaveGame.SaveSlotName, OldSaveGame:GetNewTimeTagAsString()))
    end
    print(bWriteLog and string.format("SettingSystem.SyncCustomConfig_New new file name:%s, last_save_time:%s", SaveGame.SaveSlotName, SaveGame:GetNewTimeTagAsString()))
    CustomLayoutArchiver.SaveFile(SaveGame)
  else
    print(bWriteLog and "  Load setting_info failed")
  end
end
function SettingSystem.SyncCustomConfig_Legacy(setting_info)
  print(bWriteLog and "SettingSystem.SyncCustomConfig_Legacy")
  local useIndex = setting_info.Index
  local config = setting_info.Config
  if config and useIndex then
    local fileName = Setting_UIElemLayout_Interface.GetSlotNameByIndex_Legacy(useIndex)
    local InEncodeType = config.EncodeType or 1
    local bPassed, ActualEncodeType = SavEncodeSystem.VerifySavFile(config, InEncodeType)
    local TryAgainCount = 0
    if bPassed then
      for i = 1, SavEncodeSystem.TryAgainCount do
        SavEncodeSystem.SaveFile(fileName, config, ActualEncodeType)
        if SavEncodeSystem.ValidateSaveFile(fileName) then
          break
        end
        TryAgainCount = TryAgainCount + 1
        local invalidSavFileName = Client.ProjectSavedDir() .. "/SaveGames/" .. fileName .. ".sav"
        Client.DeleteFile(invalidSavFileName)
      end
    end
    if 0 < TryAgainCount then
      local DeviceOSInfo = require("client.logic.data.data_device_os")
      local ReportEvent = HDmpveRemote.HDmpveRemoteConfigGetInt("ValidateSaveFileReportEvent", 1)
      if 0 < ReportEvent then
        local param = {
          slot_index = tostring(useIndex + 100),
          i_case = tostring(2),
          try_again = tostring(TryAgainCount)
        }
        log(bWriteLog and "SyncCustomConfig, report openid = " .. tostring(param.openid))
        log_tree("param", param)
        Client.GEMReportSubEvent(GameFrontendHUD, "UDPPingEvent", "SavFailedReport", param)
      end
    end
    if not bPassed then
      local invalidSavFileName = Client.ProjectSavedDir() .. "/SaveGames/" .. fileName .. ".sav"
      Client.DeleteFile(invalidSavFileName)
      print(bWriteLog and "  isValidSavFile false")
      local slot_type = 100 + useIndex
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_delete_custom_setting(100 + useIndex)
      SettingHandler.send_log_status_flow("CloudSavCorrupt_CustomLayout", slot_type)
    end
  else
    print(bWriteLog and "  no config")
  end
end
function SettingSystem.CheckCustomSettingGameVersion(DelayTime)
  print(bWriteLog and "SettingSystem.CheckCustomSettingGameVersion " .. (DelayTime or "nil"))
  local DelayTime = DelayTime or 2
  if SettingSystem.CheckCustomSettingGameVersionTimer then
    Game:ClearTimer(SettingSystem.CheckCustomSettingGameVersionTimer)
    SettingSystem.CheckCustomSettingGameVersionTimer = nil
  end
  SettingSystem.CheckCustomSettingGameVersionTimer = Game:SetTimer(DelayTime, false, function()
    print(bWriteLog and "SettingSystem.CheckCustomSettingGameVersion Timer Up")
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if SettingConfig and SettingConfig.GameVersion then
      local version_util = require("client.common.version_util")
      local CurrentMainVersion = version_util.GetMainFormat(Client.GetAppVersion())
      print(bWriteLog and string.format("SettingSystem.CheckCustomSettingGameVersion SavedVersion:%s RuntimeVersion%s", SettingConfig.GameVersion, CurrentMainVersion))
      if SettingConfig.GameVersion ~= CurrentMainVersion then
        SettingConfig.GameVersion = CurrentMainVersion
        slua_GameFrontendHUD:FinishModifyUserSettings()
        local GameplayStatics = import("GamePlayStatics")
        local SettingConfigName = "SettingConfig_Slot"
        local bIsSuccess = GameplayStatics.SaveGameToSlot(SettingConfig, SettingConfigName, 0)
        print(bWriteLog and "SettingSystem.CheckCustomSettingGameVersion SaveGame " .. tostring(bIsSuccess))
        if bIsSuccess then
          local bLoaded, settingInfo = SavEncodeSystem.LoadFile(SettingConfigName, SavEncodeSystem.PreferredEncodeType)
          if bLoaded then
            local slotType = 1
            SettingSystem.save_custom_setting(settingInfo, SettingConfigName, 1, slotType)
          end
        end
        SettingSystem.OnMainVersionUpdated()
      end
    else
      print(bWriteLog and "SettingSystem.CheckCustomSettingGameVersion SettingConfig nil")
    end
    local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
    Setting_UIElemLayout_Interface.RemoveBuggyFile()
    SettingSystem.CheckCustomSettingGameVersionTimer = nil
    if LobbySystem.roleData.notify_screen_resolution then
    end
  end)
end
function SettingSystem.OnMainVersionUpdated()
  local GameplayStatics = import("GamePlayStatics")
  local CheckList = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
  }
  local CustomTypeList = {
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88
  }
  local DeprecatedList = require("client.logic.setting.CustomTypeDeprecatedList")
  local TableUtil = require("common.table_util")
  CustomTypeList = TableUtil.TableConcat(CustomTypeList, DeprecatedList)
  local FindAndRemove = function(i, SaveGame)
    local LayoutDetailDict = SaveGame["LayoutDetailDict" .. tostring(i)]
    local bModified = false
    if LayoutDetailDict then
      for _, TempCustomType in ipairs(CustomTypeList) do
        local LayoutDetail = LayoutDetailDict:Get(TempCustomType)
        if LayoutDetail then
          bModified = true
          LayoutDetailDict:Remove(TempCustomType)
          print(bWriteLog and string.format("Remove %d, in Dict %d", TempCustomType, i))
        end
      end
    end
    return bModified
  end
  for Index, _ in ipairs(CheckList) do
    SettingSystem.ModifyLayoutDataSave(Index, function(i, SaveGame)
      local bModified = false.FindAndRemove(i, SaveGame) or bModified
      bModified = Setting_UIElemLayout_Interface.Relocate(i, SaveGame, 0, 20) or bModified
      bModified = Setting_UIElemLayout_Interface.Reform410(i, SaveGame) or bModified
      return bModified
    end)
  end
  local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
  Setting_UIElemLayout_Interface.ConvertAllSaveGame()
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  if SettingSubsystem_CPP then
    SettingSubsystem_CPP:ClearCustomSetting()
  end
end
function SettingSystem.UploadSettingConfigToCloud()
  local GameplayStatics = import("GameplayStatics")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local bSuccessful = GameplayStatics.SaveGameToSlot(SettingConfig, "SettingConfig_Slot", 0)
  if bSuccessful then
    log(bWriteLog and "[Setting] UploadSettingConfigToCloud")
    local SavEncodeSystem = require("client.logic.setting.SavEncodeSystem")
    local newName = "SettingConfig_Slot"
    local bLoaded, config = SavEncodeSystem.LoadFile(newName, SavEncodeSystem.PreferredEncodeType)
    if not bLoaded then
      log(bWriteLog and "[Setting] Can not load SettingConfig_Slot!")
      return
    end
    local slotType = 1
    local settingInfo = {Config = config}
    SettingSystem.save_custom_setting(settingInfo, newName, 1, slotType)
  end
end
function SettingSystem.save_custom_setting_rsp(result, operType, slotType)
  log(bWriteLog and "save_custom_setting_rsp result = " .. tostring(result) .. " operType = " .. tostring(operType) .. " slotType = " .. tostring(slotType))
  if slotType ~= 1 then
    if not UIManager.GetUI(UIManager.UI_Config.setting_main) then
      return
    end
    if tostring(result) == "0" or tostring(result) == NetErrorCode_NONE then
      if operType == 1 then
        ShowNotice(110412)
      end
    elseif tostring(result) == "411019" then
      ShowNotice(411019)
    else
      ShowNotice(110413)
    end
  elseif slotType == 1 then
    if tostring(result) == "0" or tostring(result) == NetErrorCode_NONE then
      log(bWriteLog and "upload settingconfig success!")
    else
      log(bWriteLog and "upload settingconfig failed!")
    end
  end
end
function SettingSystem.UseSettingConfig(config)
  if config ~= nil then
    local InEncodeType = config.EncodeType
    local bPassed, ActualEncodeType = SavEncodeSystem.VerifySavFile(config, InEncodeType)
    if bPassed then
      local TryAgainCount = 0
      for i = 1, SavEncodeSystem.TryAgainCount do
        SavEncodeSystem.SaveFile("SettingConfig_Slot", config, ActualEncodeType)
        if SavEncodeSystem.ValidateSaveFile("SettingConfig_Slot") then
          break
        end
        TryAgainCount = TryAgainCount + 1
        Client.DeleteFile(Client.ProjectSavedDir() .. "/SaveGames/SettingConfig_Slot.sav")
      end
      if 0 < TryAgainCount then
        local DeviceOSInfo = require("client.logic.data.data_device_os")
        local ReportEvent = HDmpveRemote.HDmpveRemoteConfigGetInt("ValidateSaveFileReportEvent", 1)
        if 0 < ReportEvent then
          local param = {
            slot_index = tostring(1),
            i_case = tostring(2),
            try_again = tostring(TryAgainCount)
          }
          log(bWriteLog and "UseSettingConfig, report openid = " .. tostring(param.openid))
          log_tree("param", param)
          Client.GEMReportSubEvent(GameFrontendHUD, "UDPPingEvent", "SavFailedReport", param)
        end
      end
      if TryAgainCount == SavEncodeSystem.TryAgainCount then
        return
      end
    end
    if not bPassed then
      local invalidSavFileName = Client.ProjectSavedDir() .. "/SaveGames/SettingConfig_Slot.sav"
      print(bWriteLog and "qwe---SettingSystem.UseSettingConfig delete invalidSavFileName : " .. invalidSavFileName)
      Client.DeleteFile(invalidSavFileName)
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_log_status_flow("CloudSavCorrupt_SettingConfig", 1)
      return
    end
    print(bWriteLog and "qwe---SettingSystem.UseSettingConfig OnDownloadSuccess")
    SettingSystem.SynAutoSaveSettingValue()
    LuaClassObj.HandleUIMessage(bp_global, "LoadSettingConfigFromSlot")
    slua_GameFrontendHUD:FinishModifyUserSettings()
  else
    print(bWriteLog and "SettingSystem.UseSettingConfig. config is nil")
  end
end
function SettingSystem.SynAutoSaveSettingValue()
  local GameplayStatics = import("GamePlayStatics")
  local ServerSettingConfig = GameplayStatics.LoadGameFromSlot("SettingConfig_Slot", 0)
  if ServerSettingConfig then
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    local LocalSettingConfig = SettingUtil.GetSettingConfig()
    if LocalSettingConfig then
      LocalSettingConfig.GameVersion = ServerSettingConfig.GameVersion
      LocalSettingConfig.OldMarkStyle = ServerSettingConfig.OldMarkStyle
      LocalSettingConfig.SoundVisualizationType = ServerSettingConfig.SoundVisualizationType
      LocalSettingConfig.AutoPickMeleeType = ServerSettingConfig.AutoPickMeleeType
      LocalSettingConfig.isCloudSettingBasicUsed = false
      LocalSettingConfig.UseIngameLike = ServerSettingConfig.UseIngameLike
      LocalSettingConfig.TeammateTakeOver = ServerSettingConfig.TeammateTakeOver
      LocalSettingConfig.DefaultMeleeWeaponType = ServerSettingConfig.DefaultMeleeWeaponType
    end
  end
end
function SettingSystem.ModifyLayoutDataSave(_UseIndex, Function, ...)
  local _SlotType = 100 + _UseIndex
  local _SlotName = Setting_UIElemLayout_Interface.GetSlotNameByIndex_Legacy(_UseIndex)
  if not SavEncodeSystem.ValidateSaveFile(_SlotName) then
    print(bWriteLog and "SettingSystem.ModifyLayoutDataSave [%s] PreValidate failed" .. _SlotName)
    Client.DeleteFile(Client.ProjectSavedDir() .. "SaveGames/" .. _SlotName .. ".sav")
    return
  end
  local GameplayStatics = import("GamePlayStatics")
  local SaveGame = GameplayStatics.LoadGameFromSlot(_SlotName, 0)
  if not slua.isValid(SaveGame) then
    print(bWriteLog and "SettingSystem.ModifyLayoutDataSave [%s] Fail to Load" .. _SlotName)
    return
  end
  local bModified = false
  for i = 1, 3 do
    bModified = Function(i, SaveGame, ...) or bModified
  end
  if not bModified then
    print(bWriteLog and string.format("SettingSystem.ModifyLayoutDataSave [%s] Nothing Modified", _SlotName))
    return
  end
  local bIsSuccess = GameplayStatics.SaveGameToSlot(SaveGame, _SlotName, 0)
  if not bIsSuccess then
    print(bWriteLog and string.format("SettingSystem.ModifyLayoutDataSave [%s] SaveGameToSlot Failed", _SlotName))
    return
  end
  local bSuccessful, SavFile = SavEncodeSystem.LoadFile(_SlotName, SavEncodeSystem.PreferredEncodeType)
  if not bSuccessful then
    print(bWriteLog and string.format("SettingSystem.ModifyLayoutDataSave [%s] LoadFile error", _SlotName))
    return
  end
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local DeviceName = "None"
  if not (DeviceOSInfo and DeviceOSInfo.InfoList) or DeviceOSInfo.InfoList.DeviceName then
  end
  local UploadData = {Config = SavFile, Index = _UseIndex}
  SettingSystem.save_custom_setting(UploadData, nil, 1, _SlotType)
end
local handleScreenParam = function(value)
  return tostring(value) .. ",0," .. tostring(value) .. ",0"
end
function SettingSystem.GetShapedScreenParam()
  log(bWriteLog and "  :  SettingSystem.GetShapedScreenParam")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saved = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.SpecialScreen)
  log_tree("  : saved", saved)
  local value = saved and saved.screenValue
  if value then
    log(bWriteLog and "  :GetShapedScreenParam value" .. tostring(value))
    return handleScreenParam(value)
  end
  return nil
end
local IsUseRecommendQuality = function()
  local game_frontend_hud = require("game_frontend_hud")
  local userSettings = game_frontend_hud.GetUserSettings()
  return userSettings.UseRecommendQualityInLobby
end
function SettingSystem.get_guide_pic_cfg()
  log(bWriteLog and "SettingSystem.get_guide_pic_cfg")
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_guide_pic_cfg()
end
function SettingSystem.get_guide_pic_cfg_rsp(_)
  local settingconfig = slua_GameFrontendHUD:GetUserSettings()
  settingconfig.PubgPlusGuideConfig:Clear()
  settingconfig.PubgPlusGuideRecord:Clear()
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function SettingSystem.unbind_social_acc_req(channel)
  local platform = 1
  local deviceName = ScriptHelperClient.GetDevicePlatformName()
  local gameid = Client.GetITopGameId()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if deviceName == DevicePlatformNameMacros.Android then
    platform = 2
  end
  log(bWriteLog and "SettingSystem.unbind_social_acc_req gameid = " .. tostring(gameid) .. " || channel = " .. tostring(channel) .. " || platform = " .. tostring(platform))
  NetUtil.SendPkg("unbind_social_acc_req", gameid, channel, platform)
end
function SettingSystem.NeedShowSettingRed()
  if DataMgr.roleData.level < 6 then
    return false
  end
  local SettingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
  return SettingRedManager.HasReddot()
end
function SettingSystem.gen_csetting_share_req(slotType)
  log(bWriteLog and "gen_csetting_share_req slotType = " .. tostring(slotType))
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_gen_csetting_share_req(slotType)
end
function SettingSystem.gen_csetting_share_rsp(result, code)
  log(bWriteLog and "customshare gen_csetting_share_rsp result = " .. tostring(result))
  log(bWriteLog and "customshare gen_csetting_share_rsp code = " .. tostring(code))
  local settingShareCodeSystem = require("client.slua.logic.setting.logic_setting_layout_share")
  settingShareCodeSystem.gen_csetting_share_rsp(result, code)
end
function SettingSystem.confirm_csetting_share_req(share_code, firemode, finger, slotType, setting_info)
  log(bWriteLog and "SettingSystem.confirm_csetting_share_req ShareCode = " .. tostring(share_code))
  log(bWriteLog and "SettingSystem.confirm_csetting_share_req FireMode = " .. tostring(firemode))
  log(bWriteLog and "SettingSystem.confirm_csetting_share_req Finger = " .. tostring(finger))
  log(bWriteLog and "SettingSystem.confirm_csetting_share_req slotType = " .. tostring(slotType))
  log_tree("SettingSystem.confirm_csetting_share_req ShareLayout", setting_info)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_confirm_csetting_share_req(share_code, firemode, finger, slotType, setting_info)
end
function SettingSystem.confirm_csetting_share_rsp(result, setting_info)
  log(bWriteLog and "SettingSystem.confirm_csetting_share_rsp = " .. tostring(result))
  log_tree("SettingSystem.confirm_csetting_share_rsp = ", setting_info)
  local settingShareCodeSystem = require("client.slua.logic.setting.logic_setting_layout_share")
  settingShareCodeSystem.confirm_csetting_share_rsp(result, extra)
end
function SettingSystem.query_other_csetting_req(firemode, share_code)
  log(bWriteLog and "query_other_csetting_req")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ShareCodePatternWithPrefix = "^%d%-%d+-%d+-%d+-%d+-%d+$"
  local is_cross_req
  local parsedCode = share_code
  log(bWriteLog and string.format("SettingSystem.query_other_csetting_req, parsedCode: %s", parsedCode))
  if string.find(parsedCode, ShareCodePatternWithPrefix) ~= nil then
    if PublishRegionMacros.IsCEVersion() then
      if tonumber(string.sub(parsedCode, 1, 1)) == SettingSystem.ShareCodePrefix.ReleaseVersion then
        is_cross_req = true
        log(bWriteLog and string.format("SettingSystem.query_other_csetting_req, has prefix, self version IsCEVersion, code version IsReleaseVersion"))
      elseif tonumber(string.sub(parsedCode, 1, 1)) == SettingSystem.ShareCodePrefix.CEVersion then
        log(bWriteLog and string.format("SettingSystem.query_other_csetting_req, has prefix, IsCEVersion, code version IsCEVersion"))
      end
    else
      log(bWriteLog and string.format("SettingSystem.query_other_csetting_req, has prefix, self version IsReleaseVersion or IsTestVersion"))
    end
    parsedCode = string.sub(parsedCode, 3)
    log(bWriteLog and string.format("SettingSystem.query_other_csetting_req, has prefix, parsedCode after parsing: %s", parsedCode))
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_query_other_csetting_req(firemode, parsedCode, is_cross_req)
end
function SettingSystem.query_other_csetting_rsp(result, setting_info)
  log(bWriteLog and "SettingSystem.query_other_csetting_rsp = " .. tostring(result))
  if tostring(result) == "0" and setting_info ~= nil then
    log_tree("shared_info", setting_info)
    if setting_info.share_info ~= nil and setting_info.Index and setting_info.Config then
      UIManager.ShowUI(UIManager.UI_Config.setting_layout_search_result, setting_info.Config, setting_info.Index, setting_info.share_info.fireMode, setting_info.share_info.owner_name)
    elseif setting_info.UseIndex and setting_info.DataMap then
      local Data = setting_info.DataMap[setting_info.UseIndex]
      if Data and Data.Config then
        SettingSystem.SyncCustomConfig_Legacy({
          Index = setting_info.UseIndex,
          Config = Data.Config
        })
        UIManager.ShowUI(UIManager.UI_Config.setting_layout_search_result, Data.Config, setting_info.UseIndex, setting_info.share_info.fireMode, setting_info.share_info.owner_name)
      end
    end
  elseif tostring(result) == "504005" then
    ShowNotice(LocUtil.GetLocalizeResStr(120164))
  elseif tostring(result) == "504007" then
    ShowNotice(LocUtil.GetLocalizeResStr(11474))
  elseif tostring(result) == "504008" then
    ShowNotice(LocUtil.GetLocalizeResStr(11474))
  else
    ShowNotice(LocUtil.GetLocalizeResStr(11452))
  end
end
function SettingSystem.confirm_sensitive_share_req(share_code, finger, device, setting_info)
  log(bWriteLog and "confirm_sensitive_share_req")
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_confirm_sensitive_share_req(share_code, finger, device, setting_info)
end
function SettingSystem.confirm_sensitive_share_rsp(result)
  log(bWriteLog and "confirm_sensitive_share_rsp")
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.ConfirmSensitiveShareRsp(result)
end
function SettingSystem.query_other_sensitive_rsp(result, sensitivity_setting)
  log(bWriteLog and "query_other_sensitive_rsp")
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.QuerySensitiveShareInfoRsp(result, sensitivity_setting)
end
function SettingSystem.HasTLogSettingInfoToday()
  local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
  local fileTb = logic_lobby_home_entry_item_File.LoadFile()
  local date = fileTb and fileTb.tlog_setting_info_date
  if not date then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local old = TimeUtil.OSDate("!*t", date)
  local new = TimeUtil.OSDate("!*t", TimeUtil.GetServerTimeInSec())
  if old.year ~= new.year then
    return false
  end
  if old.month ~= new.month then
    return false
  end
  if old.day ~= new.day then
    return false
  end
  return true
end
function SettingSystem.TLogSettingInfo()
  if SettingSystem.HasTLogSettingInfoToday() then
    log(bWriteLog and "SettingSystem.TLogSettingInfo: already reported today, skip")
    return
  end
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  local gyroscopeValue = settingConfig.Gyroscope ~= 0 and 1 or 0
  log(bWriteLog and "SettingSystem.TLogSettingInfo: original=" .. tostring(settingConfig.Gyroscope) .. " reported=" .. tostring(gyroscopeValue))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.GyroscopeSettingsOnLogin, gyroscopeValue)
  local logic_lobby_home_entry_item_File = require("client.slua.logic.home.Lobby.logic_lobby_home_entry_item_File")
  local TimeUtil = require("client.common.time_util")
  local fileTb = logic_lobby_home_entry_item_File.LoadFile() or {}
  fileTb.tlog_setting_info_date = TimeUtil.GetServerTimeInSec()
  logic_lobby_home_entry_item_File.SaveFile(fileTb)
end
function SettingSystem.OnLogin()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(15, function()
    SettingSystem.TLogSettingInfo()
    SettingSystem.InitBackgroundChat()
    SettingSystem.InitPreTeamupChat()
  end)
end
function SettingSystem.GetQualitySetting()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Quality = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRenderQuality)
  printf("SettingSystem.GetQualitySetting Quality:%s", Quality)
  return Quality
end
function SettingSystem.SetQualityToVerySmooth(quality)
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local ERenderQuality = import("ERenderQuality")
  local bInFighting = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
  local deviceLevel = gameInstance:GetExactDeviceLevel() or 0
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local ContenScaleFactor = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("r.MobileContentScaleFactor")
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local bGNeedScaleResolutionInVerySmooth = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.GNeedScaleResolutionInVerySmooth")
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  if quality and quality == ERenderQuality.VERYSMOOTH and bInFighting then
    log(bWriteLog and "[ZH] Set to verysmooth")
    if not logic_setting_graphics.SetToVerySmoothThisBattle and deviceLevel < 0 then
      gameInstance:ExecuteCMD("r.SuperFrame.LandScape", 1)
    else
    end
    if 0 < bGNeedScaleResolutionInVerySmooth then
      gameInstance:ExecuteCMD("r.ScreenPercentage", 80)
    end
    if 6 < TCDeviceLevel then
      gameInstance:ExecuteCMD("r.MipLODBiasLowClampSize", 1024)
    else
      gameInstance:ExecuteCMD("r.MipLODBiasLowClampSize", 512)
    end
    gameInstance:ExecuteCMD("r.ForceMipFilterToPoint", 1)
    gameInstance:ExecuteCMD("a.URO.GlobalOverrideControlledMinURO", 2)
    gameInstance:ExecuteCMD("r.DisableLensFlareWhenBeginPlay", 1)
    gameInstance:ExecuteCMD("r.StaticMeshForceLODMaterialBias", 2)
    gameInstance:ExecuteCMD("s.EnableOverrideVerySmoothMaterial", 1)
    gameInstance:ExecuteCMD("mv.SimulateMoveLODOptimize", 1)
    gameInstance:ExecuteCMD("mv.SimulateIgnorePhysicsQuery", 1)
    gameInstance:ExecuteCMD("mv.SimulateOptWithOccluder", 1)
    gameInstance:ExecuteCMD("mv.SimulateFindFloorInternal", 0.03)
    local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  else
    log(bWriteLog and "[ZH] not verysmooth")
    if not logic_setting_graphics.SetToVerySmoothThisBattle and deviceLevel < 0 then
      gameInstance:ExecuteCMD("r.SuperFrame.LandScape", 0)
    else
    end
    if 0 < bGNeedScaleResolutionInVerySmooth then
      gameInstance:ExecuteCMD("r.ScreenPercentage", 100)
    end
    gameInstance:ExecuteCMD("r.MipLODBiasLowClampSize", 0)
    gameInstance:ExecuteCMD("r.ForceMipFilterToPoint", 0)
    gameInstance:ExecuteCMD("a.URO.GlobalOverrideControlledMinURO", -1)
    gameInstance:ExecuteCMD("r.StaticMeshForceLODMaterialBias", 0)
    gameInstance:ExecuteCMD("s.EnableOverrideVerySmoothMaterial", 0)
    local EnableSimulateMoveOpt = Client.HDmpveRemoteConfigGetInt("EnableSimulateMoveOpt", 0)
    if EnableSimulateMoveOpt < 2 then
      gameInstance:ExecuteCMD("mv.SimulateMoveLODOptimize", 0)
      gameInstance:ExecuteCMD("mv.SimulateIgnorePhysicsQuery", 0)
      gameInstance:ExecuteCMD("mv.SimulateOptWithOccluder", 0)
      gameInstance:ExecuteCMD("mv.SimulateFindFloorInternal", 0)
    else
      gameInstance:ExecuteCMD("mv.SimulateMoveLODOptimize", 1)
      gameInstance:ExecuteCMD("mv.SimulateIgnorePhysicsQuery", 1)
      gameInstance:ExecuteCMD("mv.SimulateOptWithOccluder", 1)
      gameInstance:ExecuteCMD("mv.SimulateFindFloorInternal", 0.03)
    end
  end
  logic_setting_graphics.SetToVerySmoothThisBattle = true
  printf("SettingSystem.SetQualityToVerySmooth debugVerysmooth SetToVerySmoothThisBattle to true")
  log(bWriteLog and "[ZH] quality: " .. tostring(quality))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(quality, PlayerPrefsSystem.ePlayerPrefsType.eRenderQuality)
end
function SettingSystem.SetQuality_ExtraParam(quality)
  if quality == nil then
    log(bWriteLog and "SettingSystem.SetQuality_ExtraParam quality is nil")
    return
  end
  log(bWriteLog and "SettingSystem.SetQuality_ExtraParam quality = " .. quality)
  local gameInstance = UIUtil.GetGameInstance()
  local ERenderQuality = import("ERenderQuality")
  local status = LuaClassObj.GetGameStatus(bp_global)
  if status == GameStatus.Lobby and quality == ERenderQuality.ULTRAHIGHDEFINITION then
    gameInstance:ExecuteCMD("r.MaterialQualityLevel", 1)
  else
  end
end
function SettingSystem.TryEnterTrain()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local OkCallback = function(isCheck)
    log(bWriteLog and "  : isCheck" .. tostring(isCheck))
    if isCheck then
      PlayerPrefsSystem.SaveTableToFile_N({isCheck = true}, PlayerPrefsSystem.ePlayerPrefsType.eSettingTrain)
    end
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.EnterSingleTraining()
    local settingconfig = slua_GameFrontendHUD:GetUserSettings()
    settingconfig.SettingSensibilityEnterTrainRedPoint = false
    slua_GameFrontendHUD:FinishModifyUserSettings()
  end
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSettingTrain)
  if data and data.isCheck then
    OkCallback()
  else
    local strTile = LocUtil.GetLocalizeResStr(34795)
    local strMsg = LocUtil.GetLocalizeResStr(27296)
    local checkBoxText = LocUtil.GetLocalizeResStr(508474)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strTile, strMsg, OkCallback, nil, nil, nil, {isShowCheckBox = true, checkBoxText = checkBoxText})
  end
end
function SettingSystem.OpenService(scene)
  local CustomerHandler = require("client.network.Protocol.CustomerHandler")
  CustomerHandler.send_customer_service_clear_reddot_req()
  local IntlHelper = import("IntlHelper")
  IntlHelper.HelpshiftClearUnreadMessgesCount()
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  LogicCustomerService.Open(scene)
end
function SettingSystem.SetUnknowPassSwitch(switch)
  if switch == nil then
    switch = {}
  end
  log_tree("  :SetUnknowPassSwitch switch", switch)
  local Basic = require("client.slua.logic.setting.logic_setting_basic")
  Basic.bCanShowUnknownPass = switch.ui or false
  Basic.bUnknownPassBattleShow = switch.battle_show or false
  Basic.bUnknownPassRecordShow = switch.record_privacy or false
end
function SettingSystem.SETTING_ACCOUNT_IMSDKOK()
  SettingSystem.NIMSDKTipMsgBtnOKEvent = 1
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_IMSDKOK)
end
function SettingSystem.GetNoticeByThirdCode(toBindChannel, imsdkRetCode, imsdkThirdRetCode)
  log(bWriteLog and "SettingSystem.GetNoticeByThirdCode")
  local notice = LocUtil.GetLocalizeResStr("4048")
  if imsdkRetCode == 9999 then
    if imsdkThirdRetCode == 16 then
      notice = LocUtil.GetLocalizeResStr(4178)
    elseif imsdkThirdRetCode == 1500 then
      notice = LocUtil.GetLocalizeResStr(4179)
    elseif imsdkThirdRetCode == 5 then
      notice = LocUtil.GetLocalizeResStr(4180)
    elseif imsdkThirdRetCode == 20 then
      notice = LocUtil.GetLocalizeResStr(4181)
    elseif imsdkThirdRetCode == 3 or imsdkThirdRetCode == 9 then
      notice = LocUtil.GetLocalizeResStr(4182)
    elseif imsdkThirdRetCode == 1 then
      notice = LocUtil.GetLocalizeResStr(4183)
    elseif imsdkThirdRetCode == 2 then
      notice = LocUtil.GetLocalizeResStr(4184)
    end
  elseif imsdkRetCode == 2 and toBindChannel == "GameCenter" then
    log(bWriteLog and "SettingSystem.GetNoticeByThirdCode 701")
    notice = LocUtil.GetLocalizeResStr(4188)
  elseif imsdkRetCode == 5 and imsdkThirdRetCode == -205 then
    notice = LocUtil.GetLocalizeResStr(32452)
  end
  return notice
end
function SettingSystem.GetNameByImsdkChannel(channel, extType)
  local strName = "Guest"
  if channel == BP_ENUM_IMSDK_CHANNEL_FACEBOOK then
    strName = "Facebook"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_GAMECENTER then
    strName = "GameCenter"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY then
    strName = "GooglePlay"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_NOSCHAT then
    strName = LocUtil.GetLocalizeResStr(27916)
  elseif channel == BP_ENUM_IMSDK_CHANNEL_GUEST then
    strName = "Guest"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_VK then
    strName = "VK"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_TWITTER then
    strName = "Twitter"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_LINE then
    strName = "Line"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_BGBG then
    strName = LocUtil.GetLocalizeResStr(27921)
  elseif channel == BP_ENUM_IMSDK_CHANNEL_APPLE then
    strName = "Apple"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_DISCORD then
    strName = "Discord"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT_MAIL then
    strName = "Mail"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT_PHONE then
    strName = "Phone"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_WHATS then
    strName = "WhatsApp"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_TIKTOK then
    strName = "TikTok"
  elseif channel == BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT then
    if extType and extType == 1 then
      strName = "Mail"
    else
      strName = "Phone"
    end
  elseif tostring(channel) == "FF" then
    strName = LocUtil.GetLocalizeResStr(200000118)
  end
  return strName
end
function SettingSystem.GetNameByHDmpveChannel(channel)
  local strName = "Guest"
  if channel == BP_ENUM_PLAYFORM_BGBG then
    strName = "Facebook"
  elseif channel == BP_ENUM_PLAYFORM_GAMECENTER then
    strName = "GameCenter"
  elseif channel == BP_ENUM_PLAYFORM_GOOGLEPLAY then
    strName = "GooglePlay"
  elseif channel == BP_ENUM_PLAYFORM_WX then
    strName = LocUtil.GetLocalizeResStr(27916)
  elseif channel == BP_ENUM_PLAYFORM_TOURIST then
    strName = "Guest"
  elseif channel == BP_ENUM_PLAYFORM_VK then
    strName = "VK"
  elseif channel == BP_ENUM_PLAYFORM_TWITTER then
    strName = "Twitter"
  elseif channel == BP_ENUM_PLAYFORM_LINE then
    strName = "Line"
  elseif channel == BP_ENUM_PLAYFORM_BGBGByiTOP then
    strName = LocUtil.GetLocalizeResStr(27921)
  elseif channel == BP_ENUM_PLAYFORM_AppleByiTOP then
    strName = "Apple"
  elseif channel == BP_ENUM_PLAYFORM_UnifiedAccountByiTOP then
    strName = "PhoneMail"
  end
  return strName
end
function SettingSystem.ShowXGPushOpenTip()
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "  : ShowXGPushOpenTip")
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local resId = SettingSystem.nPushResId
  local msgConfig = LocUtil.GetLocalizeResStr(resId)
  log(bWriteLog and "EventShowXGPushOpenTip strRegion: " .. strRegion .. " BP_XGPUSH_OFF_TIP_CODE:" .. resId .. " msgConfig:" .. msgConfig)
  if resId == 116009 then
    ShowNotice(msgConfig)
  elseif strRegion == PublishRegionMacros.KOREA or strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.TW or strRegion == PublishRegionMacros.FIT then
    local strTime = TimeUtil.FormatTime_YMD(TimeUtil.GetServerTimeInSec(), true)
    ShowNotice(string.format(msgConfig, strTime))
  end
end
function SettingSystem.RefreshFCMSwitchState()
  local FCMPushSystem = require("client.slua.logic.push.logic_fcm_push")
  if FCMPushSystem.isOpen then
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() or strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE then
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_PRIVACY_FCM)
    end
  end
end
function SettingSystem.IsOpenLBSNear()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bLabel = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_NEAR_ID)
  log(bWriteLog and "[qintong] EventIsOpenLBSNear" .. tostring(bLabel))
  local bOpen = LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_NEAR_ID)
  return bLabel and bOpen
end
function SettingSystem.IsOpenLBSWarZone()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bLabel = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_WWARZONE)
  local bOpenNew = LbsMgr.IsOpenNewVersionRank()
  log(bWriteLog and "[qintong] EventIsOpenWarZone" .. tostring(bLabel) .. tostring(bOpenNew))
  local bOpen = LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_WARZONE_ID)
  return bLabel and bOpenNew and bOpen
end
function SettingSystem.IsOpenLBSChat()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bLabel = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_CHAT_ID)
  local bOpen = LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_CHAT_ID)
  log(bWriteLog and "[qintong] EventIsOpenChat" .. tostring(bLabel))
  return bLabel and bOpen
end
function SettingSystem.IsHideLBSPanel()
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  local bTourist = AccessRestrictionSystem.IsTourist()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bOpen = LbsMgr.IsLbsAllSwitchOpen()
  log(bWriteLog and "[qintong] EventIsHideLBSPanel" .. tostring(not bTourist) .. tostring(bOpen))
  if not bTourist and bOpen then
    return false
  else
    return true
  end
end
function SettingSystem.NewRefreshBindInfo()
  local TimeUtil = require("client.common.time_util")
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  SettingSystem.NUnbindChannel = Unbind_Mgr.unbind_channel == Unbind_Mgr.login_channel and 0 or Unbind_Mgr.unbind_channel
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  local unbindCDDay = logic_account_sensitive_aciton:GetUnbindCDDay()
  local remain_time = 86400 * unbindCDDay - (TimeUtil.GetServerTimeInSec() - Unbind_Mgr.unbind_time)
  SettingSystem.SUnbindDays = TimeUtil.FormatCountDownTime_D_or_HMS(remain_time, 1)
  local bind_list, appendix = Unbind_Mgr.GetBindList()
  local isInUnbind = SettingSystem.NUnbindChannel == 0 and 0 or 1
  log_tree("SettingSystem.NewRefreshBindInfo bind_list", bind_list)
  log(bWriteLog and "SettingSystem.NewRefreshBindInfo isInUnbind" .. tostring(SettingSystem.NUnbindChannel))
  log(bWriteLog and "  :Unbind_Mgr.is_open" .. tostring(Unbind_Mgr.is_open))
  local is_unbind_valid = 1 < #bind_list - isInUnbind + appendix
  if logic_account_sensitive_aciton:IsGrayNew() then
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local accountData = SettingAccount.GetSettingAccountData()
    if accountData.account_type == 1 or accountData.account_type == 2 then
      is_unbind_valid = 0 < #bind_list and isInUnbind == 0
    end
  end
  SettingSystem.UnbindIsShow = LobbySystem.CheckOpen(BP_ENUM_IS_UNBIND_ENTRY_SHOW) and is_unbind_valid and Unbind_Mgr.is_open
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_UNBINDINFO)
end
function SettingSystem.OnSettingPanelIMSDKNotify(_, __, vars)
  log(bWriteLog and "SettingSystem.OnSettingPanelIMSDKNotify")
  log_tree("vars = ", vars)
  logic_connection_waiting:Hide(1)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.NotifySettingPanelIMSDK()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_NOTIFYIMSDK)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    SettingSystem.NewRefreshBindInfo()
  end)
end
EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_BIND_NOTIFY, SettingSystem.OnSettingPanelIMSDKNotify)
function SettingSystem.ConfirmBackLobby()
  log(bWriteLog and "--\230\184\184\230\136\143\229\134\133,\233\128\128\229\135\186\229\155\158\229\136\176\229\164\167\229\142\133 ---")
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  ClientEVOConfig.OnBeforeConfirmBackToLobby()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_RETURN_TO_LOBBY)
  local wonderful_play_lua_interface = require("client.slua.logic.replay.wonderful_play_lua_interface")
  wonderful_play_lua_interface.StopReplay()
  local setting_util = require("client.slua.logic.setting.setting_util")
  local nMapId = setting_util.GetThemeModeMapId()
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true, nMapId)
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  SettingUtil:CloseSetting()
  local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
  local bIsDuringBattle = GameStatus.IsInFightingStatus()
  ClientEntryHandler.send_giveup_enter_game(bIsDuringBattle)
  FuncUtil.FormatLog("user pressed return to lobby button, bIsDuringBattle=%s", tostring(bIsDuringBattle))
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine and ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  Client.ReturnToLobby(GameFrontendHUD)
  local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  tournamentsManager.TryQuitTournamentTeam()
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if not PlanPH_GamePlay_Tools.IsPHomeMode() then
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    log(bWriteLog and "Login_BtnItemUIBP:OnClickLogin SendMessageToCloudGame MatchOver")
    logic_cloud_game:SendMessageToCloudGame(logic_cloud_game.ProtocolName.MatchOver, "SettingSystem.ConfirmBackLobby_MatchOver")
  end
end
local CanShowNoticeFlag = function()
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local GameState = SettingUtil.GetGameState()
  local PlayerController = SettingUtil.GetPlayerController()
  if not PlayerController.IsRoomMode then
    log_shipping_client(string.format(" CanShowNoticeFlag PlayerController:%s", PlayerController))
    log_shipping_client(string.format(" CanShowNoticeFlag GameState:%s", GameState))
    log_shipping_client(string.format(" CanShowNoticeFlag game_status:%s", GameStatus.GetGameStatus()))
    log_shipping_client(string.format(" CanShowNoticeFlag PlayerController.RoomMode :%s", PlayerController.RoomMode))
    log(bWriteLog and string.format(" CanShowNoticeFlag PlayerControllerName:%s___GameStateName:%s___game_status :%s___IsRoomMode :%s", PlayerController, GameState, GameStatus.GetGameStatus(), PlayerController.RoomMode))
    return
  end
  if not slua.isValid(PlayerController) or PlayerController:IsRoomMode() or PlayerController.bIsTeammateEscaped then
    log(bWriteLog and "  : not slua.isValid(PlayerController) or PlayerController:IsRoomMode()")
    return
  end
  if not slua.isValid(GameState) then
    log(bWriteLog and "  : not slua.isValid(GameState)")
    return
  end
  local EGameModeType = import("EGameModeType")
  local GameModeState = GameState:GetGameModeState() or ""
  local GameModeType = GameState.GameModeType or 0
  local PlayerNumPerTeam = GameState.PlayerNumPerTeam or 0
  return GameModeState == "ReadyState" and GameModeType == EGameModeType.ETypicalGameMode and 1 < PlayerNumPerTeam
end
function SettingSystem.ShowBackLobbyNotice(bPeakGame)
  log(bWriteLog and "  : SettingSystem.ShowBackLobbyNotice, bPeakGame = " .. tostring(bPeakGame))
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local GameState = SettingUtil.GetGameState()
  local gameInstance = SettingUtil.GetGameInstance()
  local gameReplay = gameInstance:GetObservingReplay()
  gameReplay:StopPlay()
  local CanShowEscapeNotice
  if slua.isValid(GameState) and not GameState.bIsTrainingMode then
    CanShowEscapeNotice = CanShowNoticeFlag()
  end
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local PlayerController = SettingUtil.GetPlayerController()
  local IsObserver = PlayerController and PlayerController.IsObserver and PlayerController:IsObserver()
  local bIsRoomMode = true
  print(bWriteLog and "  : SettingSystem.ShowBackLobbyNotice IsObserver--", IsObserver, bIsRoomMode)
  if bPeakGame == true then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(77004), SettingSystem.ConfirmBackLobby)
    return
  end
  log(bWriteLog and "EventShowBackToLobbyNotice Gamemode ID: " .. Client.GetGameModeID(GameFrontendHUD))
  local ClientInGameCreditLogic = require("GameLua.Mod.BaseMod.Client.Security.Credit.ClientInGameCreditLogic")
  if ClientInGameCreditLogic.ShowReturnLobbyIfFirstExitTeamBeforeBoarding(SettingSystem.ConfirmBackLobby) then
    log(bWriteLog and "  : ShowReturnLobbyIfFirstExitTeamBeforeBoarding")
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  log(bWriteLog and "SettingSystem.ShowBackLobbyNotice CurGameModeID: " .. tostring(CurGameModeID))
  if CurGameModeID == "13703" then
    CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(7663), SettingSystem.ConfirmBackLobby, SettingSystem.ShowReportBugUi, LocUtil.GetLocalizeResStr(36668), LocUtil.GetLocalizeResStr(44467))
    return
  end
  local TPlanGameModeIDList = {
    "23001",
    "23004",
    "23005",
    "23006",
    "23007",
    "23008",
    "23009",
    "23010"
  }
  local TableUtil = require("common.table_util")
  if TableUtil.Find(TPlanGameModeIDList, CurGameModeID) ~= -1 and not IsObserver and not bIsRoomMode then
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(12060), SettingSystem.ConfirmBackLobby)
    return
  end
  if CurGameModeID == "723" or CurGameModeID == "733" then
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(8005), SettingSystem.ConfirmBackLobby)
    return
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
  if tostring(CurGameModeID) == tostring(home_macros.Home_SubMode.Visit) then
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(65264), SettingSystem.ConfirmBackLobby)
    return
  elseif tostring(CurGameModeID) == tostring(Logic_PlanCHMacros.CollectionHall_SubMode.Visit) then
    CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(880060103), SettingSystem.ConfirmBackLobby)
    return
  end
  local ECreativeModeGameType = import("ECreativeModeGameType")
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    if CGameState.bIsCreativeWoW then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(77101), function()
        SettingSystem.ConfirmBackLobby()
      end, nil, LocUtil.GetLocalizeResStr(77103), LocUtil.GetLocalizeResStr(77102))
      return
    end
    local ChallengeMissionSubsystem = SubsystemMgr:Get("CreativeChallengeMissionSubsystem")
    if ChallengeMissionSubsystem and ChallengeMissionSubsystem:GetChallengeMissionEnable() then
      ChallengeMissionSubsystem:CheckAndQuitChallengeMission(true)
      return
    end
    local NewbieGuieSubsystem = SubsystemMgr:Get("CreativeModeNewbieGuideSubsystem")
    local IsTutorialOn = false
    if NewbieGuieSubsystem then
      IsTutorialOn = NewbieGuieSubsystem:IsTutorialOn()
    end
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local bIsStandalone = Util_UGC.IsStandalone()
    local EditorShowSaveCheck = not IsTutorialOn and not bIsStandalone
    if CGameState:GetInitializeGameType() == ECreativeModeGameType.CreativeModeGameType_Editor and EditorShowSaveCheck then
      log(bWriteLog and "EventShowBackToLobbyNotice UGC Savemap double check")
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local isLeader = TeamUpNewSystem.IsTeamLeader()
      if isLeader then
        local confirmClick = function()
          print(bWriteLog and "CreativeModeEditMainUICtrl confirmClick")
          local EditMainSubsystem = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
          if EditMainSubsystem then
            EditMainSubsystem:SaveMod(function(SaveSuc, bIsTimeout)
              print(bWriteLog and "SaveModCallback SaveSuc:" .. tostring(SaveSuc))
              if SaveSuc or bIsTimeout then
                SettingSystem.ConfirmBackLobby()
              end
            end)
          end
        end
        local giveUpClick = function()
          print(bWriteLog and "CreativeModeEditMainUICtrl giveUpClick")
          SettingSystem.ConfirmBackLobby()
          local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
          if CommonMsgBoxMgr and CommonMsgBoxMgr.HideAllPanel then
            CommonMsgBoxMgr.HideAllPanel()
          end
        end
        local MainUISubsys = SubsystemMgr:Get("CreativeModeEditMainCtrlSubSystem")
        local CDTime = -1
        if MainUISubsys then
          CDTime = MainUISubsys:GetSaveCDTime()
        end
        if 0.5 < CDTime then
          CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(82024083), confirmClick, giveUpClick, LocUtil.GetLocalizeResStr(82024085), LocUtil.GetLocalizeResStr(82024084), {cntDown = CDTime})
        else
          CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(82024083), confirmClick, giveUpClick, LocUtil.GetLocalizeResStr(82024085), LocUtil.GetLocalizeResStr(82024084))
        end
        return
      end
      local ActionsConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.EditActionTypesConfig")
      local ActionsType = ActionsConfig.Actions
      local CreativeEditTLogSubsystem = SubsystemMgr:Get("CreativeEditTLogSubsystem")
      if CreativeEditTLogSubsystem then
        CreativeEditTLogSubsystem:MarkAnEditAction(ActionsType.MainUIToLobby)
        CreativeEditTLogSubsystem:ReqMarkEditActions()
      end
    elseif CGameState:GetInitializeGameType() == ECreativeModeGameType.CreativeModeGameType_Game then
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local MyPlayerState = GameplayData.GetPlayerState()
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local uGameState = SettingUtil.GetGameState()
      local bCanFreelyQuit = slua.isValid(uGameState) and uGameState:GetCanFreelyQuit()
      local ConfirmFunc = function()
        local CommentUtility = require("GameLua.Mod.CreativeBase.Client.Comment.CreativeModeCommentUtility")
        if CommentUtility and CommentUtility.GiveUpGamePopup and CommentUtility.GiveUpGamePopup() then
          log(bWriteLog and "[dom] CommentUtility.GiveUpGamePopup")
          return
        end
        if CommentUtility and CommentUtility.CheckLeaveGamePopup and CommentUtility.CheckLeaveGamePopup() then
          log(bWriteLog and "[dom] CommentUtility.CheckLeaveGamePopup")
          return
        end
        SettingSystem.ConfirmBackLobby()
      end
      if SettingSystem.CheckPlayerIsEscapeByUGC(MyPlayerState) then
        CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(46094), ConfirmFunc, SettingSystem.ShowReportBugUi, LocUtil.GetLocalizeResStr(36668), LocUtil.GetLocalizeResStr(44467))
        return
      elseif bCanFreelyQuit then
        local CommentUtility = require("GameLua.Mod.CreativeBase.Client.Comment.CreativeModeCommentUtility")
        if CommentUtility and CommentUtility.ShowShortPlayTimeCheckThenQuit then
          CommentUtility.ShowShortPlayTimeCheckThenQuit(function()
            SettingSystem.ConfirmBackLobby()
          end, ConfirmFunc)
          return
        end
      end
    end
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if not ClientGameMain.IsStandalone() and slua.isValid(GameState) and GameState.GetGameModeState then
    local GameModeState = GameState:GetGameModeState() or ""
    if not CanShowEscapeNotice and GameModeState ~= "ReadyState" then
      local CurMainModeID = uGameInstance:GetMainModeID()
      local TypicalGameModeIDList = {
        102,
        103,
        402,
        403,
        112,
        113,
        412,
        413,
        723,
        733,
        11201
      }
      local TableUtil = require("common.table_util")
      local IsSpecialTip = false
      print(bWriteLog and "SettingSystem.ShowBackLobbyNotice  not CanShowEscapeNotice CurMainModeID:", CurMainModeID)
      if TableUtil.Find(TypicalGameModeIDList, CurMainModeID) ~= -1 then
        local SettingUtil = require("client.slua.logic.setting.setting_util")
        local PlayerController = SettingUtil.GetPlayerController()
        if slua.isValid(PlayerController) and PlayerController.IsInNormalPlane then
          if PlayerController:IsInNormalPlane() and PlayerController:IsTeammateExitTeamBeforeBoarding() then
            IsSpecialTip = false
          elseif not PlayerController:IsRoomMode() then
            IsSpecialTip = true
          end
        end
        print(bWriteLog and "SettingSystem.ShowBackLobbyNotice  not CanShowEscapeNotice IsSpecialTip:", IsSpecialTip)
      end
      if IsSpecialTip then
        CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(77004), SettingSystem.ConfirmBackLobby)
        return
      end
    end
  end
  local ExitTips = 110140
  local TypicalGameModeIDList = {
    101,
    102,
    103,
    401,
    402,
    403
  }
  local CurMainModeID = uGameInstance:GetMainModeID()
  print(bWriteLog and "SettingSystem.ShowBackLobbyNotice MainModID", CurMainModeID, bIsRoomMode)
  if TableUtil.Find(TypicalGameModeIDList, CurMainModeID) ~= -1 and not bIsRoomMode then
    ExitTips = 77001
  end
  if CanShowEscapeNotice and LobbySystem then
    local timeN = tonumber(DataMgr.GetSystemConfig("EscapeTipChangeNum"))
    log(bWriteLog and "*********EscapeTipChangeNum = " .. tostring(timeN))
    log(bWriteLog and "*********current_escape_time = " .. tostring(LobbySystem.forcedExitGameTimes))
    local ModID = Client.GetGameModeID(GameFrontendHUD)
    print(bWriteLog and "SettingSystem.ShowBackLobbyNotice ModID", ModID, LobbySystem.forcedExitGameTimes, timeN)
    if timeN <= LobbySystem.forcedExitGameTimes then
      CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(77005), SettingSystem.ConfirmBackLobby)
    else
      CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(ExitTips), SettingSystem.ConfirmBackLobby)
    end
  else
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(ExitTips), SettingSystem.ConfirmBackLobby)
  end
  if BP_Setting_Sensitivity_CountInfo then
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_gun_sensitivity_setting(2, BP_Setting_Sensitivity_CountInfo)
    BP_Setting_Sensitivity_CountInfo = nil
    BP_Setting_Sensitivity_CountInfo_Attr = nil
  end
end
function SettingSystem.CheckPlayerIsEscapeByUGC(uMyPlayerState)
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local uGameState = SettingUtil.GetGameState()
  if slua.isValid(uGameState) and uGameState:GetCanFreelyQuit() then
    print(bWriteLog and "SettingSystem.CheckPlayerIsEscapeByUGC CanFreelyQuit")
    return false
  end
  if slua.isValid(uMyPlayerState) and uMyPlayerState.IsTeamGameOver ~= nil and not uMyPlayerState:IsTeamGameOver() then
    return true
  end
  return false
end
function SettingSystem.SetCfgSwitch(flag)
  SettingSystem.BUseCfg = flag
  LobbySystem.LobbyMenuOpenStatus[BP_ENUM_SWITCH_SETTING_PRIVACY] = {}
  if flag then
    LobbySystem.LobbyMenuOpenStatus[BP_ENUM_SWITCH_SETTING_PRIVACY].is_open = 1
  else
    LobbySystem.LobbyMenuOpenStatus[BP_ENUM_SWITCH_SETTING_PRIVACY].is_open = 0
  end
  log(bWriteLog and "  :LobbySystem.LobbyMenuOpenStatus[80032].is_open" .. tostring(LobbySystem.LobbyMenuOpenStatus[BP_ENUM_SWITCH_SETTING_PRIVACY].is_open))
  log(bWriteLog and "  : flag" .. tostring(flag))
end
local ItemPaths = {
  "/Game/UMG/UI_BP/Setting/item/Setting_Title_Item_UIBP.Setting_Title_Item_UIBP",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleV_Item.Setting_DoubleV_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_Treble_Item.Setting_Treble_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_Slider2Btn_Item.Setting_Slider2Btn_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_OverLay.Setting_OverLay",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleParent_Item.Setting_DoubleParent_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleH_Item.Setting_DoubleH_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleParentWithChoose_Item.Setting_DoubleParentWithChoose_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleVWord_Item.Setting_DoubleVWord_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_TrebleParent_Item.Setting_TrebleParent_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_DoubleHWord_Item.Setting_DoubleHWord_Item",
  "/Game/UMG/UI_BP/NewSetting/Item/Setting_OneChoose_Item.Setting_OneChoose_Item",
  "/Game/UMG/UI_BP/Setting/item/Setting_Operate_Switch.Setting_Operate_Switch"
}
local OverLays = {}
local Key2OverlayIndex = {}
local OverLaysShow = {}
local SettingMacro = require("client.slua.logic.setting.setting_macro")
local SettingCfg = require("client.logic.setting.setting_config")
local Refresh = require("client.logic.setting.refresh.setting_refresh")
local NItemHeight = SettingMacro.NDoubleVHeight
local NBtnStartIndex = 2
local NBtnEndIndex = 4
local NOverLayWidth = SettingMacro.NOverLayWidth
local NSlice = SettingMacro.NSlice
local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
local GetOneSettingValue = LogicSettingBasic.GetOneSettingValue
local SetOneSettingValue = LogicSettingBasic.SetOneSettingValue
local OverLaySize = FVector2D(NOverLayWidth, 50)
local PlaySound = function()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
end
local local CheckSettingBShow = function(key)
  local BShowFunc = Refresh["BShow" .. key]
  if BShowFunc then
    local bShow = BShowFunc()
    print(bWriteLog and "CheckSettingBShow " .. key .. " " .. tostring(bShow))
    return bShow
  end
  print(bWriteLog and "CheckSettingBShow " .. key .. " true default")
  return true
end
function SettingSystem.RefreshOneOverLayHeight(curKey, calculating, findKey)
  local overLayCfg = SettingCfg[curKey].overLayCfg
  if not overLayCfg then
    log(bWriteLog and "  :RefreshOneOverLayHeight  not overLayCfg")
    return
  end
  local overLay
  local NRowNum = 0
  local overLayHeight = 0
  local bFound
  local tempTable = {}
  for _, key in pairs(overLayCfg) do
    if key == findKey then
      bFound = true
      break
    end
    local curCfg = SettingCfg[key]
    if not overLay then
      log(bWriteLog and "  : overLay \231\154\132  key " .. tostring(key))
      overLay = OverLays[curCfg.overLayIndex]
    end
    if not overLay then
      log(bWriteLog and "  :RefreshOneOverLayHeight overLay is nil")
      return
    end
    if CheckSettingBShow(key) then
      OverLaysShow[overLay] = true
      UIUtil.SetWidgetVisible(overLay, true)
      if curCfg.height then
        overLayHeight = overLayHeight + curCfg.height
      else
        NRowNum = NRowNum + 0.5
        if curCfg.subItems then
          NRowNum = NRowNum + 0.5
          tempTable[key] = Refresh.GetbShowSub(key)
        end
        if curCfg.parentKey then
          if tempTable[curCfg.parentKey] == nil then
            tempTable[curCfg.parentKey] = Refresh.GetbShowSub(curCfg.parentKey)
          end
          if tempTable[curCfg.parentKey] == false then
            NRowNum = NRowNum - 0.5
          end
        end
      end
    end
  end
  log(bWriteLog and "  :NRowNum" .. tostring(NRowNum))
  if findKey and bFound then
    NRowNum = math.floor(NRowNum + FLOAT_NUMBER_TRAIL)
    log(bWriteLog and "  :down NRowNum" .. tostring(NRowNum))
  else
    NRowNum = math.ceil(NRowNum - FLOAT_NUMBER_TRAIL)
    log(bWriteLog and "  :up NRowNum" .. tostring(NRowNum))
  end
  overLayHeight = NRowNum * NItemHeight + math.max(NRowNum - 1, 0) * NSlice + overLayHeight
  log(bWriteLog and "  :RefreshOneOverLayHeight overLay.WrapBox_Layer.Slot:SetSize" .. tostring(overLayHeight))
  if calculating then
    return overLayHeight
  end
  if overLayHeight ~= 0 then
    OverLaySize.Y = overLayHeight
    if overLay then
      overLay.WrapBox_Layer.Slot:SetSize(OverLaySize)
    end
  else
    UIUtil.SetWidgetVisible(overLay, false)
  end
end
function SettingSystem.CheckSettingCfgFail(DataTable, Config)
  local StringUtil = require("common.string_util")
  for i, v in pairs(DataTable) do
    if v.BTitle == 1 then
      table.insert(Config, v.Cfg)
    else
      local curTable = StringUtil.Split(v.Cfg, ";")
      for index, name in pairs(curTable) do
        if not SettingCfg[name] then
          log_error(string.format("\232\174\190\231\189\174\231\149\140\233\157\162\233\133\141\231\189\174.xls \228\184\141\230\173\163\231\161\174 : \231\172\172%s\232\161\140, %s item\231\188\186\229\164\177", i, name))
          table.remove(curTable, index)
        end
      end
      table.insert(Config, curTable)
    end
  end
  return false
end
function SettingSystem.PlayRedAnim(findKey, isRed, bForceRedAnim)
  if not slua.isValid(SettingCfg[findKey].widget) then
    return
  end
  local widget = SettingCfg[findKey].widget
  if widget.Red then
    UIUtil.SetWidgetVisible(widget.Red, true)
    if not isRed then
      UIUtil.SetWidgetVisible(widget.Red.Image_Red, false)
    end
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSettingRedAnim) or {}
    log_tree("  : eSettingRedAnimcfg", cfg)
    if bForceRedAnim or not cfg[findKey] then
      log(bWriteLog and "  : \230\178\161\230\146\173\232\191\135\230\137\171\229\133\137")
      UIUtil.SetWidgetVisible(widget.Red.CanvasPanel_RedAnim, true)
      widget.Red:PlayUserWidgetAnimation(widget.Red.Animn_1, 0, 1, 0, 1)
      cfg[findKey] = true
      PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eSettingRedAnim)
    else
      UIUtil.SetWidgetVisible(widget.Red.CanvasPanel_RedAnim, false)
    end
  else
    log_error("PlayRedAnim no Red " .. tostring(findKey))
  end
end
function SettingSystem._ShowItemDoubleV(curItem, key, ui)
  local cfg = SettingCfg[key]
  if type(cfg.localRes) == "number" then
    if key == "RelationLove" then
      local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
      local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
      if bIsBondingSystem then
        curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(cfg.localRes))
      else
        curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(33145))
      end
    else
      curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(cfg.localRes))
    end
  elseif type(cfg.localRes) == "table" then
    curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(cfg.localRes[1]))
    local leftWord = LocUtil.GetLocalizeResStr(cfg.localRes[2])
    curItem.TextBlock_Left:SetText(leftWord)
    if curItem.TextBlock_Left1 then
      curItem.TextBlock_Left1:SetText(leftWord)
    end
    local rightWord = LocUtil.GetLocalizeResStr(cfg.localRes[3])
    curItem.TextBlock_Right:SetText(rightWord)
    if curItem.TextBlock_Right1 then
      curItem.TextBlock_Right1:SetText(rightWord)
    end
  end
  ui:AddControlEventByControl(curItem.Button_Item, "OnClicked", Refresh.OnClickItem, key)
end
function SettingSystem._ShowItemTreble(TargetItem, Key, ui)
  local logicBasic = require("client.logic.setting.refresh.setting_refresh")
  local CurrentSettingCfg = SettingCfg[Key]
  log(bWriteLog and "  :CurrentSettingCfg.localRes[1]" .. tostring(CurrentSettingCfg.localRes[1]))
  TargetItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(CurrentSettingCfg.localRes[1]))
  for i = NBtnStartIndex, NBtnEndIndex do
    ui:AddControlEventByControl(TargetItem["Btn_" .. i], "OnClicked", Refresh.OnClickItem, Key, i - 1, TargetItem, ui)
    TargetItem["TextBlock_Off" .. i]:SetText(LocUtil.GetLocalizeResStr(CurrentSettingCfg.localRes[i]))
    TargetItem["TextBlock_On" .. i]:SetText(LocUtil.GetLocalizeResStr(CurrentSettingCfg.localRes[i]))
  end
  if CurrentSettingCfg.SuggestionLocalizationID then
    SettingSystem.DebugSuggestion.ShowSuggest("Gyroscope", TargetItem, TargetItem.LeftRightShoot_help, TargetItem.Horizontal_Notice, TargetItem.TextBlock_0, CurrentSettingCfg.SuggestionLocalizationID, TargetItem.Fadein_Tips)
  end
end
local OnSliderChanged = function(key, nValue)
  local cfg = SettingCfg[key]
  local value = (cfg.max - cfg.min) * nValue + cfg.min
  log(bWriteLog and "  :nValue" .. tostring(nValue))
  log(bWriteLog and "   OnViewSliderChange:value" .. tostring(value))
  SetOneSettingValue(key, math.floor(value))
  if not cfg.widget then
    return
  end
  Refresh["Refresh" .. key](key)
end
local OnClickAdd = function(key)
  PlaySound()
  local curValue = GetOneSettingValue(key)
  if curValue < SettingCfg[key].max then
    SetOneSettingValue(key, curValue + 1)
    if not SettingCfg[key].widget then
      return
    end
    Refresh["Refresh" .. key](key)
  end
end
local OnClickSub = function(key)
  PlaySound()
  local curValue = GetOneSettingValue(key)
  if curValue > SettingCfg[key].min then
    SetOneSettingValue(key, curValue - 1)
    if not SettingCfg[key].widget then
      return
    end
    Refresh["Refresh" .. key](key)
  end
end
function SettingSystem._ShowItemSlider2Btn(curItem, key, ui)
  curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(SettingCfg[key].localRes))
  local InitValue = GetOneSettingValue(key)
  if key == "TpViewValue" or key == "JoystickSprintSensitity" or key == "FpViewValue" then
    local Min = SettingCfg[key].min or 0
    local Max = SettingCfg[key].max or 100
    InitValue = FuncUtil.Clamp(GetOneSettingValue(key), Min, Max)
  end
  print(bWriteLog and "SettingSystem: InitValue key = " .. key .. " Value = " .. tostring(InitValue))
  SettingCfg[key].widget.NumDelta:InitValue(InitValue)
  ui:AddControlEventByControl(curItem.Button_Sub, "OnClicked", OnClickSub, key)
  ui:AddControlEventByControl(curItem.Button_Add, "OnClicked", OnClickAdd, key)
  local sliderChangeFunc = Refresh["OnValueChangedSlider" .. key]
  sliderChangeFunc = sliderChangeFunc or OnSliderChanged
  ui:AddControlEventByControl(curItem.CommonSlider, "OnValueChanged", sliderChangeFunc, key)
end
function SettingSystem._ShowItemDoubleVWord(curItem, key, ui)
  local cfg = SettingCfg[key]
  curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(cfg.localRes[1]))
  local leftWord = LocUtil.GetLocalizeResStr(cfg.localRes[2])
  curItem.TextBlock_Left:SetText(leftWord)
  curItem.TextBlock_Left1:SetText(leftWord)
  local rightWord = LocUtil.GetLocalizeResStr(cfg.localRes[3])
  curItem.TextBlock_Right:SetText(rightWord)
  curItem.TextBlock_Right1:SetText(rightWord)
  ui:AddControlEventByControl(curItem.Button_Item, "OnClicked", Refresh.OnClickItem, key)
end
function SettingSystem._ShowItemOneChoose(curItem, key, ui)
  local setting_refresh_RelationShowOrder = require("client.logic.setting.refresh.setting_refresh_RelationShowOrder")
  setting_refresh_RelationShowOrder._ShowItemOneChoose(curItem, key, ui)
end
local _AttachParentKeyForChild = function(parentKey)
  local cfg = SettingCfg[parentKey]
  if cfg.subItems then
    cfg.RedInSub = nil
    for _, subName in pairs(cfg.subItems) do
      SettingCfg[subName].    end
  end
end
local GetItemFromPool = function(ItemType)
  if not ItemPaths[ItemType] then
    return
  end
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.other_pool)
  local item = pool:Get(ItemPaths[ItemType])
  local TableUtil = require("common.table_util")
  local Btn_AimAssist = TableUtil.GetTableValue(item, "Setting_Switch", "Btn_AimAssist")
  if Btn_AimAssist then
    UIUtil.SetWidgetVisible(Btn_AimAssist, false)
  end
  UIUtil.SetWidgetVisible(item, true)
  local switcher = item.Setting_Switch
  if switcher then
    switcher:SetSwitcherEnable(true)
  end
  local red = item.Red
  if red then
    UIUtil.SetWidgetVisible(red, false)
  end
  return item
end
SettingSystem.local LoadOneItem = function(curItem, key, ui, bSkipRefresh)
  local curLocCfg = SettingCfg[key]
  if not curLocCfg.widget then
    curLocCfg.widget = curItem
  end
  if curItem.Button_Help then
    UIUtil.SetWidgetVisible(curItem.Button_Help, curLocCfg.needHelp, true)
    if curLocCfg.needHelp then
      local helpFunc
      if type(curLocCfg.needHelp) == "number" then
        helpFunc = Refresh.OnClickHelpNormal
      else
        helpFunc = Refresh["OnClickHelp" .. key]
      end
      if helpFunc then
        log(bWriteLog and "  :AddControlEventByControl     OnClickHelp" .. tostring(curLocCfg.needHelp))
        ui:AddControlEventByControl(curItem.Button_Help, "OnClicked", helpFunc, key)
      end
    end
  end
  local Node = curItem
  if slua.isValid(curItem.Setting_Switch) then
    Node = curItem.Setting_Switch
  end
  for i = 1, 3 do
    local sRecommendWidgetName = "Image_RecommendBG_" .. i
    if slua.isValid(Node[sRecommendWidgetName]) then
      UIUtil.SetWidgetVisible(Node[sRecommendWidgetName], curLocCfg.nRecommendIndex == i)
    end
  end
  local EItemType = SettingMacro.EItemType
  local curType = SettingCfg[key].itemType
  if curType == EItemType.DoubleV or curType == EItemType.DoubleSlim then
    SettingSystem._ShowItemDoubleV(curItem, key, ui)
  elseif curType == EItemType.DoubleVWord then
    SettingSystem._ShowItemDoubleVWord(curItem, key, ui)
  elseif curType == EItemType.Treble then
    SettingSystem._ShowItemTreble(curItem, key, ui)
  elseif curType == EItemType.Slider2Btn then
    SettingSystem._ShowItemSlider2Btn(curItem, key, ui)
  elseif curType == EItemType.DoubleParent then
    SettingSystem._ShowItemDoubleV(curItem, key, ui)
    _AttachParentKeyForChild(key)
  elseif curType == EItemType.TrebleParent then
    SettingSystem._ShowItemTreble(curItem, key, ui)
    _AttachParentKeyForChild(key)
  elseif curType == EItemType.DoubleParentWithChoose then
    SettingSystem._ShowItemDoubleV(curItem, key, ui)
    _AttachParentKeyForChild(key)
    if Refresh["OnClickChoose" .. key] then
      ui:AddControlEventByControl(curItem.Button_Choose, "OnClicked", Refresh["OnClickChoose" .. key], key)
    end
  elseif curType == EItemType.DoubleHWord then
    SettingSystem._ShowItemDoubleV(curItem, key, ui)
    local wordRes = SettingCfg[key].wordRes
    if wordRes then
      curItem.TextBlock_Word:SetText(LocUtil.GetLocalizeResStr(wordRes))
    end
  elseif curType == EItemType.DoubleH then
    SettingSystem._ShowItemDoubleV(curItem, key, ui)
    local wordRes = SettingCfg[key].localRes
    if wordRes then
      curItem.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(wordRes))
    end
  elseif curType == EItemType.OneChoose then
    SettingSystem._ShowItemOneChoose(curItem, key, ui)
  end
  if not bSkipRefresh then
    Refresh.RefreshItem(key)
  end
end
SettingSystem.local _
function SettingSystem.OnShowUI(container, curCfg, ui)
  container:ClearChildren()
  local curType, curItem, overLay, lastOverLayKey
  log_tree("  : cfg", curCfg)
  local ShowOrHideItem = function(key, item)
    log(bWriteLog and "  :ShowOrHideItem", tostring(key), tostring(item))
    local show = true
    local bShowFunc = Refresh["BShow" .. key]
    if type(bShowFunc) == "function" and not bShowFunc() then
      show = false
    end
    if item then
      ui:SetWidgetVisible(item, show)
    end
  end
  local overlayIndex = 0
  local titleIndex = 0
  for index, cfg in pairs(curCfg) do
    if type(cfg) == "string" then
      local titleItem = GetItemFromPool(SettingCfg[cfg].itemType)
      local curLocCfg = SettingCfg[cfg]
      if not curLocCfg.widget then
        curLocCfg.widget = titleItem
      end
      container:AddChild(titleItem)
      titleItem.Title:SetText(LocUtil.GetLocalizeResStr(SettingCfg[cfg].localRes))
      ShowOrHideItem(cfg, titleItem)
      if titleItem.PlayDelayEnterAnim then
        titleItem.index = titleIndex
        titleIndex = titleIndex + 1
        titleItem:PlayDelayEnterAnim()
      end
    else
      if _coroutine.isyieldable() then
        _coroutine.yield(0.001)
      end
      overLay = GetItemFromPool(SettingMacro.EItemType.OverLay)
      UIUtil.SetWidgetVisible(overLay.Image_Downline, true)
      OverLays[index] = overLay
      container:AddChild(overLay)
      UIUtil.SetWidgetVisible(overLay.Image_Line, false)
      for _, key in pairs(cfg) do
        log(bWriteLog and "  :key" .. tostring(key))
        log_tree("  : SettingCfg[key]", SettingCfg[key])
        if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and SettingCfg.SettingOnlfFrinedConfig[key] then
          log(bWriteLog and "[v_yunjxing]:key" .. tostring(key))
          SettingCfg[key] = SettingCfg.SettingOnlfFrinedConfig[key]
        end
        curType = SettingCfg[key].itemType
        curItem = GetItemFromPool(curType)
        if not NItemHeight then
          NItemHeight = curItem.CanvasPanel_Root.Slot:GetSize().Y
          log(bWriteLog and "  :NItemHeight" .. tostring(NItemHeight))
        end
        Key2OverlayIndex[key] = index
        overLay.WrapBox_Layer:AddChild(curItem)
        LoadOneItem(curItem, key, ui, true)
        ShowOrHideItem(key, curItem)
        lastOverLayKey = key
        SettingCfg[lastOverLayKey].overLayIndex = index
        SettingCfg[lastOverLayKey].overLayCfg = cfg
      end
      for _, key in pairs(cfg) do
        Refresh.RefreshItem(key)
      end
      OverLaysShow[overLay] = false
      if lastOverLayKey then
        SettingSystem.RefreshOneOverLayHeight(lastOverLayKey)
        lastOverLayKey = nil
      end
      if OverLaysShow[overLay] and overLay.PlayDelayAnimation then
        overLay.index = overlayIndex
        overlayIndex = overlayIndex + 1
        overLay:PlayDelayAnimation()
      end
    end
  end
  for i = #curCfg, 1, -1 do
    local _overLay = OverLays[i]
    if _overLay and _overLay:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      UIUtil.SetWidgetVisible(_overLay.Image_Downline, false)
      break
    end
  end
end
function SettingSystem.Key2Overlay(key)
  return OverLays[Key2OverlayIndex[key]]
end
function SettingSystem.CloseBefore()
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.other_pool)
  for _, v in pairs(SettingCfg) do
    if v.widget then
      pool:Release(v.widget)
      v.widget = nil
    end
    v.overLayCfg = nil
  end
  for index, v in pairs(OverLays) do
    pool:Release(v)
    OverLays[index] = nil
  end
end
function SettingSystem.CloneTableForSetting(org)
  local function copy(org, res)
    for k, v in pairs(org) do
      if type(v) ~= "table" then
        res[k] = v
      else
        res[k] = {}
        copy(v, res[k])
      end
    end
  end
  local res = {}
  copy(org, res)
  return res
end
function SettingSystem.InitBackgroundChat()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  log(bWriteLog and "SettingSystem.InitBackgroundChat backgroundChat:" .. tostring(SettingConfig.backgroundChat))
  logic_antsvoice_interface:SetVoiceSDKSupportBackgroundChat(SettingConfig.backgroundChat)
end
function SettingSystem.InitPreTeamupChat()
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[4] then
    return
  end
  local value = LobbySystem.roleData.social_private_data[4]
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.preTeamUpChat = value
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function EventShowInturrptGameNotice()
  local confirmClick = function()
    Client.RoomOwnerInterruptGame(GameFrontendHUD)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(6924), confirmClick)
end
function EventHideAllNoticeFromObserveToLobby()
  log(bWriteLog and "--\232\167\130\230\136\152,\233\128\128\229\135\186\229\155\158\229\136\176\229\164\167\229\142\133 \229\133\179\233\151\173\229\188\185\231\170\151---")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.HideAllPanel()
end
function EventOpenHawkEyeReportWindow()
  SubsystemMgr:Get("ClientHawkEyePatrolSubsystem"):OnClickBottomRightOpenReportWindow()
end
function EventOnShowHawkEyeWatchEndedTips()
  SubsystemMgr:Get("ClientHawkEyePatrolSubsystem"):OnShowWatchEndedTips()
end
function EventShowBackToLobbyFromTrainingNotice()
  local   local ModID = Client.GetGameModeID(GameFrontendHUD)
  log(bWriteLog and string.format(" EventShowBackToLobbyFromTrainingNotice ModID:%s", ModID))
  local IsTraining = ModID == "1007" or ModID == "1008" or ModID == "1009" or ModID == "10071" or ModID == "10080"
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local IsSocialIslandMode = MatchModeMgrSystem.IsSocialIslandModeID(ModID)
  local ExitToLobby = function()
    log(bWriteLog and "--\232\174\173\231\187\131\229\156\186,\233\128\128\229\135\186\229\155\158\229\136\176\229\164\167\229\142\133 ---")
    FuncUtil.ShowLoadingToLobby()
    local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
    ClientEntryHandler.send_giveup_enter_game()
    LobbySystem.ReturnToLobby()
  end
  local ExitToSocialIsland = function()
    log(bWriteLog and "--\232\174\173\231\187\131\229\156\186,\233\128\128\229\135\186\229\155\158\229\136\176\228\186\164\229\143\139\229\178\155 ---")
    local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
    local ret = SocialIslandHandler.ReqEnterSystemIsland()
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
  local strTitle = LocUtil.GetLocalizeResStr(101001)
  if IsTraining then
    local strText = LocUtil.GetLocalizeResStr(34797)
    local strOK = LocUtil.GetLocalizeResStr(34798)
    local strCancel = LocUtil.GetLocalizeResStr(34799)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(4, strTitle, strText, ExitToSocialIsland, ExitToLobby, strOK, strCancel)
  elseif IsSocialIslandMode then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SocialIsland_MsgBox_Slua_UIBP, ExitToLobby)
  elseif tonumber(ModID) == home_macros.Home_SubMode.Visit then
    local strText = LocUtil.GetLocalizeResStr(9909)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strTitle, strText, ExitToLobby)
  elseif tonumber(ModID) == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
    local strText = LocUtil.GetLocalizeResStr(880060103)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(4, strTitle, strText, ExitToLobby)
  else
    local strText = LocUtil.GetLocalizeResStr(110140)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strTitle, strText, ExitToLobby)
  end
end
function EventShowBackToLobbyNotice()
  SettingSystem.ShowBackLobbyNotice()
end
function SettingSystem.send_set_grome_link_open_req(value)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_grome_link_open_req(value)
end
function SettingSystem.send_get_grome_link_open_req()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_grome_link_open_req()
end
function SettingSystem.on_sync_grome_link_open_stat(value)
  LogicSettingBasic.nGromeLinkOpenValue = value
  log(bWriteLog and "SettingSystem.on_sync_grome_link_open_stat value is " .. tostring(value))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_GROME_LINK_SUCCESS)
end
function SettingSystem.on_get_grome_link_open_rsp(value)
  LogicSettingBasic.nGromeLinkOpenValue = value
  log(bWriteLog and "SettingSystem.on_get_grome_link_open_rsp value is " .. tostring(value))
end
function SettingSystem.ShowReportBugUi()
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local bIsPlanPHMode = logic_home_entry:IsPlanPHMode()
  if not bIsPlanPHMode then
    UIManager.ShowUI(UIManager.UI_Config_InGame.BattleReportBug)
  end
end
function SettingSystem.send_set_grome_link_fec_req(value)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_grome_link_fec_req(value)
end
function SettingSystem.send_get_grome_link_fec_req()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_grome_link_fec_req()
end
function SettingSystem.on_sync_grome_link_fec_stat(set_val)
  LogicSettingBasic.nGromeLinkFECSwitcher = set_val
  log(bWriteLog and "SettingSystem.on_sync_grome_link_fec_stat value is " .. tostring(set_val))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_NET_FEC_SWITCHER_SUCCESS)
end
function SettingSystem.on_get_grome_link_fec_rsp(set_val)
  LogicSettingBasic.nGromeLinkFECSwitcher = set_val
  log(bWriteLog and "SettingSystem.on_get_grome_link_fec_rsp value is " .. tostring(set_val))
end
return SettingSystem
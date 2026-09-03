local version_up_module = {}
local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
local GEnableShaderGroupAsyncCache
local DolphinErrorTb = {
  [154140709] = 1,
  [888888888] = 1
}
local NSTAT_EVENT_PATCH_CHECK = 20
local NSTAT_EVENT_PATCH_START = 21
local NSTAT_EVENT_PATCH_COMPLETED = 22
local SavedFileUtil = import("SavedFileUtil")
function version_up_module:DefineAndResetData()
  self.bAlreadyGrayUpdate = nil
  self.nDownloadTimesWithoutWiFi = 0
  self.nUpdateFinishedTimes = 0
  self.bShownWiFiTo4GTips = nil
end
function version_up_module:SetbShownWiFiTo4GTips(shown)
  log_warning(bWriteLog and "  :SetbShownWiFiTo4GTips shown: " .. tostring(shown))
  self.bShownWiFiTo4GTips = shown
end
function version_up_module:OnDolphinError(errorCode)
  log_warning(bWriteLog and "  : login_module:errorCode: " .. tostring(errorCode))
  if DolphinErrorTb[errorCode] then
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(NSTAT_EVENT_PATCH_CHECK, true)
    StatManager.GetInstance():ReportEventWithNoParam(NSTAT_EVENT_PATCH_START, true)
    StatManager.GetInstance():ReportEventWithNoParam(NSTAT_EVENT_PATCH_COMPLETED, true)
  end
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    updateUI:OnDolphinError(errorCode)
  else
    log(bWriteLog and "login_module.OnDolphinError, version_update is not showing?")
  end
end
function version_up_module:OnUpdateFinished()
  self.forcedUpdateTips = nil
  self.nUpdateFinishedTimes = self.nUpdateFinishedTimes + 1
  log(bWriteLog and "login_module.OnUpdateFinished, nUpdateFinishedTimes = " .. tostring(self.nUpdateFinishedTimes))
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    if Client.IsSplitMiniPakVersion() == true and self.nUpdateFinishedTimes <= 1 then
      log(bWriteLog and "version_up_module.OnUpdateFinished, Call Client.OpenShaderCodeLibrary")
      Client.OpenShaderCodeLibrary("../../../ShadowTrackerExtra/Content/", "")
    end
    local sProjectSavedDir = Client.ProjectSavedDir()
    local targetDir = sProjectSavedDir .. "Paks/"
    local file_util = require("client.common.file_util")
    local paklist = file_util.FindFiles(targetDir, "pak", false, true)
    self:ProcessDownloadedShader(paklist)
    self:CheckFitLobbyResPakExist(paklist)
    updateUI:OnUpdateFinished()
  else
    log(bWriteLog and "version_up_module.OnUpdateFinished, version_update is not showing?")
  end
  local LobbyAssetPreloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LobbyAssetPreloader)
  LobbyAssetPreloader:PreloadLobbyUIAsset()
  if Client.GetDevicePlatformName() == "Android" then
    local CanSetGameThreadName = HDmpveRemote.HDmpveRemoteConfigGetInt("AnrSetGameThreadName", 1)
    if CanSetGameThreadName == 1 then
      Client.SetGameThreadName("UEGameThread")
    end
  end
end
function version_up_module:GetGEnableShaderGroupAsync()
  log_format("version_up_module:GetGEnableShaderGroupAsync.")
  if GEnableShaderGroupAsyncCache ~= nil then
    return GEnableShaderGroupAsyncCache
  end
  GEnableShaderGroupAsyncCache = HDmpveRemote.HDmpveRemoteConfigGetInt("GEnableShaderGroupAsync_New", 1)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = LogicPlayerPrefs.LoadFileToTable_N(LogicPlayerPrefs.ePlayerPrefsType.eShaderDecompressingVersion) or {}
  log_tree("version_up_module:GetGEnableShaderGroupAsync. data = ", data)
  if data.version == Client.GetAppVersion() and HDmpveRemote.HDmpveRemoteConfigGetInt("GDisableShaderAsyncWhenSameVersion", 0) == 1 then
    GEnableShaderGroupAsyncCache = 0
    local gameInstance = slua_GameFrontendHUD:GetGameInstance()
    gameInstance:ExecuteCMD("r.SkipShaderLibraryCRCCheck", 1)
  end
  log_format("version_up_module:GetGEnableShaderGroupAsync. GEnableShaderGroupAsync=%s", GEnableShaderGroupAsyncCache)
  return GEnableShaderGroupAsyncCache
end
function version_up_module:ProcessDownloadedShader(paklist)
  log(bWriteLog and "version_up_module.ProcessDownloadedShader")
  local sProjectSavedDir = Client.ProjectSavedDir()
  local IsNeedClearFile = function(filename, filelist)
    log(bWriteLog and "IsNeedClearFile, filename = " .. tostring(filename) .. ", filelist = " .. tostring(filelist))
    local bFlag = true
    for _, file in pairs(filelist) do
      if string.find(filename, file) ~= nil then
        bFlag = false
        break
      end
    end
    return bFlag
  end
  local ClearShaderFile = function(filetype, paklist)
    log(bWriteLog and "ClearShaderFile, filetype = " .. tostring(filetype) .. ", paklist = " .. tostring(paklist))
    local targetDir = sProjectSavedDir .. "Paks/"
    local filelist = SavedFileUtil.FindFiles(targetDir, filetype, false)
    for _, filename in pairs(filelist) do
      if IsNeedClearFile(filename, paklist) then
        local filepath = targetDir .. filename
        log(bWriteLog and "ClearShaderFile, delete file = " .. tostring(filepath))
        Client.DeleteFile(filepath)
      end
    end
  end
  local targetDir = sProjectSavedDir .. "Paks/"
  for idx, filename in pairs(paklist) do
    log(bWriteLog and "version_up_module.ProcessDownloadedShader, before filename = " .. tostring(filename))
    local extIndex = string.find(string.lower(filename), "%.pak")
    if extIndex then
      filename = string.sub(filename, 1, extIndex - 1)
      log(bWriteLog and "version_up_module.ProcessDownloadedShader,  after filename = " .. tostring(filename))
      paklist[idx] = filename
      Client.OpenShaderCodeLibrary(targetDir, filename)
    end
  end
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  log_format("ProcessDownloadedShader r.DeferSplitShaderLibraryLoaded: %s", 0)
  gameInstance:ExecuteCMD("r.DeferSplitShaderLibraryLoaded", 0)
  local GEnableShaderGroupAsync = self:GetGEnableShaderGroupAsync()
  log_format("ProcessDownloadedShader GEnableShaderGroupAsync: %s", GEnableShaderGroupAsync)
  gameInstance:ExecuteCMD("r.EnableShaderGroupAsync", GEnableShaderGroupAsync)
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if 1 <= GEnableShaderGroupAsync and platformName == DevicePlatformNameMacros.IOS then
    if GEnableShaderGroupAsync == 2 then
      Client.EnableShaderGroupAsync_New("map_lobby,map_lobby_CSM")
    else
      Client.EnableShaderGroupAsync("map_lobby,map_lobby_CSM")
    end
  else
    Client.EnableShaderGroup("map_lobby")
    Client.EnableShaderGroup("map_lobby_CSM")
  end
  ClearShaderFile("ushaderbytecode", paklist)
  ClearShaderFile("metallib", paklist)
  ClearShaderFile("metalmap", paklist)
  self:DeleteOldNeedUpdateFiles()
end
function version_up_module:DeleteOldNeedUpdateFiles()
  log(bWriteLog and "version_up_module:DeleteOldNeedUpdateFiles.")
  local PufferODPakDelList = require("client.slua.logic.download.puffer.odpak.puffer_odpak_del_once")
  PufferODPakDelList.DeleteFileList()
end
function version_up_module:SetbAlreadyGrayUpdate(update)
  log_warning(bWriteLog and "  :SetbAlreadyGrayUpdate update: " .. tostring(update))
  self.bAlreadyGrayUpdate = update
end
function version_up_module:ShowSystemNotifyEntry(isEnabled)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    return
  end
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    updateUI:ShowSystemNotifyEntry(isEnabled)
  end
end
function version_up_module:UpdateProgressBar(progress, isPrecompile)
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI ~= nil then
    updateUI:UpdateProgressBar(progress, isPrecompile)
  else
    log(bWriteLog and "version_up_module.UpdateStageText, version_update is not showing?")
  end
end
function version_up_module:UpdateStageText(tips, nowSize, totalSize, curStage)
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI ~= nil then
    updateUI:UpdateStageText(tips)
    updateUI:UpdateDownloadSpeedSizeInfo(nowSize, totalSize, curStage)
  else
    log(bWriteLog and "version_up_module.UpdateStageText, version_update is not showing?")
  end
end
function version_up_module:StartShaderPreCompile()
  log(bWriteLog and "version_up_module.StartShaderPreCompile")
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    self:StopShaderPreCompile()
    updateUI:ShowRichTextLoadingTip(true)
    local delay = 0.2
    self.nShareTimer = self:AddTimerLoop(delay, function()
      local ShaderPreCompileSystem = require("client.logic.ver_update.logic_shader_precompile")
      ShaderPreCompileSystem.HandleTimer(delay)
    end, TIMER_INFINITE, delay)
  else
    log_warning(bWriteLog and "  : version_up_module.StartShaderPreCompileTimer, version_update is not showing?")
  end
end
function version_up_module:StopShaderPreCompile()
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    updateUI:ShowRichTextLoadingTip(false)
  end
  if self.nShareTimer then
    self:RemoveTimer(self.nShareTimer)
    self.nShareTimer = nil
  end
end
function version_up_module:OnFinishedShaderPreCompile()
  local Logic_Mini_Pak_Gem = require("client.slua.logic.download.report.logic_mini_pak_gem")
  Logic_Mini_Pak_Gem.ReportGemLog("ShaderEnd")
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI ~= nil then
    updateUI:AfterFinishedUpdate()
  else
    log(bWriteLog and "version_up_module.OnFinishedShaderPreCompile, version_update is not showing?")
  end
end
function version_up_module:StartGrayUpdate(callback)
  log(bWriteLog and "version_up_module.StartGrayUpdate, callback = " .. tostring(callback))
  PufferDownloader.UpdateGrayStep = 1
  local bSkipUpdating = self:NeedSkipGrayUpdatingInBlueHole()
  log(bWriteLog and "version_up_module.StartGrayUpdate NeedSkipGrayUpdatingInBlueHole return " .. tostring(bSkipUpdating))
  if not bSkipUpdating and Client.StartGrayUpdate(GameFrontendHUD) then
    UIManager.CloseUI(UIManager.UI_Config.Login_UIBP)
    UIManager.ShowUI(UIManager.UI_Config.version_update, true, callback)
    PufferDownloader.UpdateGrayStep = 2
  else
    log(bWriteLog and "version_up_module.StartGrayUpdate, skip gray update.")
    if callback ~= nil then
      callback()
    end
    PufferDownloader.UpdateGrayStep = 3
  end
  self.bAlreadyGrayUpdate = true
end
function version_up_module:ShowTipsWhenWiFi4GSwitched()
  log(bWriteLog and "version_up_module.ShowTipsWhenWiFi4GSwitched")
  if not Client.HasActiveWifi() then
    if self.nDownloadTimesWithoutWiFi >= 3 then
      if not self.bShownWiFiTo4GTips and Client.IsNetworkReachable() and not Client.HasDownloadedBasePak() then
        self.bShownWiFiTo4GTips = true
        local title = LocUtil.GetLocalizeResStr(301137)
        local content = LocUtil.GetLocalizeResStr(7423)
        local confirmLabel = LocUtil.GetLocalizeResStr(110036)
        local exitLabel = LocUtil.GetLocalizeResStr(110035)
        CommonMsgBoxMgr.Show(2, title, content, nil, GameStatus.QuitGame, confirmLabel, exitLabel, {
          showUIKey = "com_msg_box_5s"
        })
      end
    elseif Client.IsNetworkReachable() then
      self.nDownloadTimesWithoutWiFi = self.nDownloadTimesWithoutWiFi + 1
    end
  else
    self.nDownloadTimesWithoutWiFi = 0
  end
end
function version_up_module:InitializePuffer(useLobbyINTF)
  log(bWriteLog and "version_up_module.InitializePuffer, useLobbyINTF = " .. tostring(useLobbyINTF))
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI and updateUI:IsShow() then
    updateUI:OnPufferInitialize()
  end
  local result = Client.GetPufferInitResult(GameFrontendHUD)
  printf("version_up_module:InitializePuffer. result=%s", tostring(result))
  if Client.IsSplitMiniPakVersion() and result then
    log(bWriteLog and "version_up_module.InitializePuffer, already Inited")
    PufferDownloader.ReInitializePuffer(true)
    return
  end
  local flagFileName = "Paks/ODPaks/ClearFlagNew"
  local bShouldBeClear = true
  if Client.IsIPhoneFiveS() then
    local clearFlagContains15 = true
    local clearFlagExist = Client.IsFileExistsWithPakCheck(Client.ProjectSavedDir() .. flagFileName)
    if clearFlagExist then
      local clearVersion = Client.LoadFileToString(flagFileName)
      clearFlagContains15 = string.find(clearVersion, "0%.15%.")
      log(bWriteLog and "version_up_module.InitializePuffer, 5S and ClearFlag exist, find 0.15. = " .. tostring(clearFlagContains15))
    else
      log(bWriteLog and "version_up_module.InitializePuffer, 5S and ClearFlag not exist")
    end
    if not clearFlagContains15 then
      bShouldBeClear = false
      log(bWriteLog and "version_up_module.InitializePuffer, 5S not contains 015, do not clear by MD5")
    else
      log(bWriteLog and "version_up_module.InitializePuffer, 5S, clear by MD5")
    end
  else
    log(bWriteLog and "version_up_module.InitializePuffer, Android or not 5S, do not clear by MD5")
    bShouldBeClear = false
  end
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local PufferConfig = PufferConfigSys:GetDefaultConfig(PufferConfigSys.DOWNLOAD_PHASE.BASE)
  local maxDowloadTask = PufferConfig.MaxDownTask
  if not useLobbyINTF then
    maxDowloadTask = 1
  end
  if IsEditor and result then
    return
  end
  local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
  logic_puffer_common.ProcessDownloadEifsInBase()
  log(bWriteLog and "version_up_module:InitializePuffer. ReInitializePuffer")
  PufferDownloader.bHaveRetriedInit = false
  Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, maxDowloadTask, PufferConfig.MaxDownloadSpeed, useLobbyINTF, bShouldBeClear, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
end
function version_up_module:ShowConfirmPanelWhenLowMemory(tips)
  log(bWriteLog and "version_up_module.ShowConfirmPanelWhenLowMemory, tips = " .. tostring(tips))
  local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
  if Logic_Download_Delete.IsShowCleanResource() then
    return
  end
  local title = LocUtil.GetLocalizeResStr(201001)
  local warning = LocUtil.GetLocalizeResStr(201022)
  local cancelLabel = LocUtil.GetLocalizeResStr(110035)
  CommonMsgBoxMgr.Show(1, title, tips .. warning, GameStatus.QuitGame, nil, cancelLabel, nil, {
    showUIKey = "com_msg_box_5s"
  })
end
function version_up_module:GetTssVersion()
  local tssVersion = ""
  log_shipping_client("SendPkg login 1 patch_tss:" .. tostring(global_patch_tss) .. ", package_tss:" .. tostring(global_package_tss))
  if global_patch_tss and global_patch_tss ~= "" and global_patch_tss ~= " " then
    tssVersion = global_patch_tss
  elseif global_package_tss and global_package_tss ~= "" and global_package_tss ~= " " then
    tssVersion = global_package_tss
  end
  log_shipping_client("SendPkg login 2 tssVersion:" .. tostring(tssVersion))
  return tssVersion
end
function version_up_module:IsInLoginForceUpdateProgress()
  local isInLoginForceUpdateProgress = false
  if self.forcedUpdateTips ~= nil then
    isInLoginForceUpdateProgress = true
  end
  return isInLoginForceUpdateProgress
end
function version_up_module:IsShowUpdatePrompt()
  local bShowIOSUpdatePrompt = false
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platformName == DevicePlatformNameMacros.IOS then
    if GlobalData.IsIOSCheck() then
      bShowIOSUpdatePrompt = true
    elseif Client.IsDevelopment() or not globalConfig.IsDirectConnect() then
      bShowIOSUpdatePrompt = false
    else
      bShowIOSUpdatePrompt = HDmpveRemote.HDmpveRemoteConfigGetBool("bShowIOSUpdatePrompt", false)
    end
  end
  log(bWriteLog and "VersionUpdateUI:IsShowUpdatePrompt, result = " .. tostring(bShowIOSUpdatePrompt))
  return bShowIOSUpdatePrompt
end
function version_up_module:TemporarilySwitchToLoginScreen(tips)
  self.forcedUpdateTips = tips
end
function version_up_module:CheckContinueUpdate()
  local blockLoginFlow = false
  if self:IsInLoginForceUpdateProgress() then
    blockLoginFlow = true
    local continueUpdateFunc = function()
      if slua_GameFrontendHUD:StartUpdate() then
        UIManager.CloseUI(UIManager.UI_Config.Login_UIBP)
        UIManager.ShowUI(UIManager.UI_Config.version_update, true, function()
        end)
        local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
        if updateUI then
          updateUI:OnDolphinProgress(71)
        end
      end
    end
    local title = LocUtil.GetLocalizeResStr(201001)
    CommonMsgBoxMgr.Show(2, title, self.forcedUpdateTips, continueUpdateFunc)
  end
  log(bWriteLog and "version_up_module.CheckContinueUpdate return " .. tostring(blockLoginFlow))
  return blockLoginFlow
end
function version_up_module:NeedSkipAppUpdatingInBlueHole()
  log(bWriteLog and "[BH_Update][App] version_up_module:NeedSkipAppUpdatingInBlueHole")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE or Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "[BH_Update][App] version_up_module:NeedSkipAppUpdatingInBlueHole not bluehole ios version, can not skip")
    return false
  end
  local LocalSrcVersion = Client.GetSrcVersion()
  local version_util = require("client.common.version_util")
  local VersionTb = version_util.GetSplitVersionTb(LocalSrcVersion)
  local VersionLastNum = VersionTb and tonumber(VersionTb[4]) or 0
  local SkipUpdateVersionBH = HDmpveRemote.HDmpveRemoteConfigGetInt("SkipUpdateVersionBH", 0)
  log(bWriteLog and string.format("[BH_Update][App] version_up_module:NeedSkipAppUpdatingInBlueHole local ver:%s, last:%s, remote:%s", tostring(LocalSrcVersion), tostring(VersionLastNum), tostring(SkipUpdateVersionBH)))
  if SkipUpdateVersionBH ~= 0 and VersionLastNum >= SkipUpdateVersionBH then
    log(bWriteLog and "[BH_Update][App] version_up_module:NeedSkipAppUpdatingInBlueHole SkipUpdateVersionBH == VersionLastNum, return true")
    return true
  end
  log(bWriteLog and "[BH_Update][App] version_up_module:NeedSkipAppUpdatingInBlueHole return false")
  return false
end
function version_up_module:NeedSkipGrayUpdatingInBlueHole()
  log(bWriteLog and "[BH_Update][Gray] version_up_module:NeedSkipGrayUpdatingInBlueHole")
  if IsWoWEditor then
    return true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE or Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "[BH_Update][Gray] version_up_module:NeedSkipGrayUpdatingInBlueHole not bluehole ios version, can not skip")
    return false
  end
  local bGrayCheckUpdateBH = HDmpveRemote.HDmpveRemoteConfigGetBool("bGrayCheckUpdateBH", false)
  log(bWriteLog and string.format("[BH_Update][Gray] version_up_module:NeedSkipGrayUpdatingInBlueHole remote config gray:%s", bGrayCheckUpdateBH))
  if bGrayCheckUpdateBH then
    return false
  end
  return true
end
function version_up_module:CheckFitLobbyResPakExist(paklist)
  log_format("version_up_module:CheckFitLobbyResPakExist.")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local key = PufferConst.FIT_LOBBY_RES_KEY
  local StringUtil = require("common.string_util")
  local pakCfg = CDataTable.GetTableData("DownloaderPakCfg", key)
  local mixDownloadData = {}
  if pakCfg then
    mixDownloadData = StringUtil.Split(pakCfg.PakContent, "|")
  end
  if not mixDownloadData or not next(mixDownloadData) then
    log(bWriteLog and "version_up_module:CheckFitLobbyResPakExist mixDownloadData is nil")
    return
  end
  local fullVersion = Client.GetApplicationVersion()
  local curVersion = string.match(fullVersion, "^(%d+%.%d+%.%d+)")
  log_format("version_up_module:CheckFitLobbyResPakExist. curVersion=%s", curVersion)
  local pakInfoMap = {}
  for _, pakFile in pairs(paklist) do
    log_format("version_up_module:CheckFitLobbyResPakExist. pakFile=%s", pakFile)
    local prefix, version = string.match(pakFile, "^(.+)_(%d+%.%d+%.%d+).*")
    if prefix and version then
      pakInfoMap[prefix] = version
    end
  end
  local bAllExist = true
  for _, resKey in pairs(mixDownloadData) do
    local sResKey = tostring(resKey)
    local pakVersion = pakInfoMap[sResKey]
    log_format("version_up_module:CheckFitLobbyResPakExist. sResKey=%s, pakVersion=%s, curVersion=%s", sResKey, pakVersion, curVersion)
    if pakVersion ~= curVersion then
      bAllExist = false
      break
    end
  end
  log(bWriteLog and "version_up_module:CheckFitLobbyResPakExist bAllExist: " .. tostring(bAllExist))
  if bAllExist then
    LogicPufferBundle.bFitLobbyResExist = true
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cversion_up_module = class(CModuleBase, nil, version_up_module)
return Cversion_up_module
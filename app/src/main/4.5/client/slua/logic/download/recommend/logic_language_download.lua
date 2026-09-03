local LanguageDownload = {bInitCompleted = false}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
LanguageDownload.E_SetLanguageOptions = {
  Interface = 0,
  ChatFirst = 1,
  ChatSecond = 2,
  MatchFirst = 3,
  MatchSecond = 4
}
function LanguageDownload.AutoDownloadCurrentLanguage()
  local DownLoadLanguageName = Client.GetDownLoadLanguageName()
  log(bWriteLog and string.format("LanguageDownload.AutoDownloadCurrentLanguage DownLoadLanguageName:" .. tostring(DownLoadLanguageName)))
  if not DownLoadLanguageName or DownLoadLanguageName == "" then
    return
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {
    "res_localization"
  })
  if state == PufferConst.ENUM_DownloadState.Done then
    return
  end
  PufferManager.Download(PufferConst.ENUM_DownloadType.RES, {
    "res_localization"
  })
end
function LanguageDownload.MountResLocalizationPak()
  if not Client.IsJaguar() then
    return
  end
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local state = PufferResManager:GetState("res_localization")
  if state ~= PufferConst.ENUM_DownloadState.Done then
    printf("LanguageDownload.MountResLocalizationPak. res not downloaded")
    return
  end
  local ResPakName = PufferResManager:GetPakName("res_localization") or ""
  local ResPakPath = Client.ProjectSavedDir() .. "Paks/" .. ResPakName
  local bHasMounted = Client.IsMounted(ResPakPath)
  log(bWriteLog and string.format("LanguageDownload.MountResLocalizationPak ResPakPath:[%s], bHasMounted:[%s], ", ResPakPath, tostring(bHasMounted)))
  if not bHasMounted then
    local bMountRet = Client.MountPakFile(ResPakPath, "")
    if bMountRet then
      Client.SetDownLoadLanguageName("")
    end
    log(bWriteLog and string.format("LanguageDownload.MountResLocalizationPak MountPakFile bMountRet:[%s], ", tostring(bMountRet)))
  end
end
function LanguageDownload.IsNeedDownload(language, type)
  if not language or language == "" then
    return false
  end
  if language == "en" or type ~= LanguageDownload.E_SetLanguageOptions.Interface then
    return false
  end
  return true
end
function LanguageDownload.GetLocalizationResPath(language)
  language = string.gsub(language, "-", "")
  return string.format("/Game/CSV/LocalizationText_%s", language)
end
function LanguageDownload.GetResState(language)
  local resPath = LanguageDownload.GetLocalizationResPath(language)
  return PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {resPath})
end
function LanguageDownload.GetResExist(language)
  local resPath = LanguageDownload.GetLocalizationResPath(language)
  local isExist = Client.IsGameFileExistsWithPakCheck(resPath)
  log_format("LanguageDownload.GetResExist. resPath=%s, isExist=%s", resPath, isExist)
  return isExist
end
function LanguageDownload.GetSystemDefaultLanguage()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local lang = KismetSystemLibrary.GetDefaultLanguage()
  local UELanguageUtilityMethods = import("UELanguageUtilityMethods")
  if UELanguageUtilityMethods.ConvertLanguageName then
    lang = UELanguageUtilityMethods.ConvertLanguageName(lang)
  end
  log_format("LanguageDownload.GetSystemDefaultLanguage. lang=%s", lang)
  return lang
end
function LanguageDownload.IsCurrentLanguageResExist()
  local UELanguageUtilityMethods = import("UELanguageUtilityMethods")
  local currentLang = UELanguageUtilityMethods.GetCurrentLanguageName()
  if UELanguageUtilityMethods.ConvertLanguageName then
    currentLang = UELanguageUtilityMethods.ConvertLanguageName(currentLang)
  end
  log_format("LanguageDownload.IsCurrentLanguageResExist. currentLang=%s", currentLang)
  return LanguageDownload.GetResExist(currentLang)
end
function LanguageDownload.SetCurrentLanguageAndLocale(new_language)
  log_format("LanguageDownload:SetCurrentLanguageAndLocale. new_language=%s", new_language)
  Client.SetDownLoadLanguageName("")
  local KismetInternationalizationLibrary = import("KismetInternationalizationLibrary")
  if KismetInternationalizationLibrary ~= nil then
    KismetInternationalizationLibrary.SetCurrentLanguageAndLocale(new_language, true)
  end
  local GameBackendHUD = import("GameBackendHUD")
  local backendHudObject = GameBackendHUD.GetInstance()
  local frontHudObject = backendHudObject:GetFirstGameFrontendHUD()
  local settingConfig = frontHudObject:GetUserSettings()
  if settingConfig ~= nil then
    frontHudObject:BeginModifyUserSettings()
    settingConfig.currentLanguage = new_language
    frontHudObject:FinishModifyUserSettings()
  end
  local gameplayStatics = import("GamePlayStatics")
  local classLanguageSaveGame = import("/Game/Blueprints/Config/LanguageSaveGame.LanguageSaveGame_C")
  local saveGameObject = gameplayStatics.LoadGameFromSlot("LanguageSaveGame", 0)
  saveGameObject = saveGameObject or gameplayStatics.CreateSaveGameObject(classLanguageSaveGame)
  if saveGameObject == nil then
    log(bWriteLog and "saveGameObject == nil nil nil ")
    return
  end
  saveGameObject.currentLanguage = new_language
  gameplayStatics.SaveGameToSlot(saveGameObject, "LanguageSaveGame", 0)
  local IntlHelper = import("IntlHelper")
  IntlHelper.OnSwitchLanguage()
  _G.__DataTable = {}
end
function LanguageDownload.GetSaveGameObjectLanguage()
  local gameplayStatics = import("GamePlayStatics")
  local saveGameObject = gameplayStatics.LoadGameFromSlot("LanguageSaveGame", 0)
  local currentLanguage = saveGameObject and saveGameObject.currentLanguage
  log_format("LanguageDownload.GetSaveGameObjectLanguage. currentLanguage=%s", currentLanguage)
  return currentLanguage
end
return LanguageDownload
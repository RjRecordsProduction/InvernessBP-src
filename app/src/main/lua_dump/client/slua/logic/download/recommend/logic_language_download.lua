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
  if language == "en" or type ~= LanguageDownload.E_SetLanguageOptions.Interface and (language == "ja" or language == "ko" or language == "vi" or language == "my" or language == "ms") then
    return false
  end
  return true
end
return LanguageDownload
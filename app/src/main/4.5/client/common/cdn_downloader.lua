local cdn_downloader = {}
cdn_downloader.CDN_DIR = FuncUtil.GetDomainByID(3366005) .. "/pubg/"
cdn_downloader.CDN_DIR_BLUEHOLE = FuncUtil.GetDomainByID(3366041) .. "/pubg/"
cdn_downloader.arrDownload = {}
local GetDownloadInfo = function(cdnUrl)
  for i, v in pairs(cdn_downloader.arrDownload) do
    if v.cdnUrl == cdnUrl then
      return v
    end
  end
  return nil
end
local RemoveDownloadInfo = function(cdnUrl)
  for i, v in pairs(cdn_downloader.arrDownload) do
    if v.cdnUrl == cdnUrl then
      v.callFunList = nil
      table.remove(cdn_downloader.arrDownload, i)
      break
    end
  end
end
local addDownloadInfo = function(cdnUrl, savePath, callBack, reTryNum, ExpiredUnixTime)
  local retInfo
  reTryNum = reTryNum or 0
  local savePara = GetDownloadInfo(cdnUrl)
  if savePara then
    savePara.callBack = savePara.callBack or {}
    table.insert(savePara.callBack, callBack)
    retInfo = savePara
  else
    local callFunList = {}
    table.insert(callFunList, callBack)
    retInfo = {
      cdnUrl = cdnUrl,
      savePath = savePath,
      callFunList = callFunList,
      downloadNum = 0,
      reTryNum = reTryNum,
          }
    table.insert(cdn_downloader.arrDownload, retInfo)
  end
  return retInfo
end
local GetFileNameNoDir = function(fullPath)
  if not fullPath or fullPath == "" then
    return fullPath
  end
  local StringUtil = require("common.string_util")
  local SaveDir = Client.ProjectSavedDir()
  local fileName = fullPath
  if string.find(fullPath, SaveDir) then
    fileName = StringUtil.SubString(fullPath, string.len(SaveDir) + 1, string.len(fullPath))
  end
  return fileName
end
local StartDownload = function(retInfo)
  if not retInfo or not retInfo.cdnUrl then
    return
  end
  retInfo.downloadNum = retInfo.downloadNum + 1
  log(bWriteLog and "cdn_downloader.download StartDownload cdnUrl:" .. tostring(retInfo.cdnUrl) .. "\239\188\140savePath:" .. tostring(retInfo.savePath))
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.SetImmDLMaxSpeed(PufferNetManager.FullSpeed * 0.5)
  PufferNetManager.MeasureFullSpeedTime = 0
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Get(retInfo.cdnUrl, {}, "", nil, function(success, data, content)
    if success and content then
      local ScriptHelperClient = import("ScriptHelperClient")
      ScriptHelperClient.SaveArrayToFile(content, GetFileNameNoDir(retInfo.savePath))
    end
    cdn_downloader.CallBackDownload(retInfo.cdnUrl, retInfo.savePath, success, 0)
  end, nil, 30, 0, retInfo.savePath)
end
local SaveExpiredInfo = function(cdnUrl)
  local info = GetDownloadInfo(cdnUrl)
  if info and info.ExpiredUnixTime and tonumber(info.ExpiredUnixTime) > 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local preSave = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCDNDownload)
    preSave = preSave or {}
    preSave[cdnUrl] = {
      time = tonumber(info.ExpiredUnixTime),
      path = info.savePath
    }
    PlayerPrefsSystem.SaveTableToFile_N(preSave, PlayerPrefsSystem.ePlayerPrefsType.eCDNDownload)
  end
end
function cdn_downloader.GetCDNFileDir(subDir, noRelease, noPlatform)
  subDir = subDir or "AFD"
  local strCDNDir = ""
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE then
    strCDNDir = cdn_downloader.CDN_DIR_BLUEHOLE .. subDir .. "/"
  else
    strCDNDir = cdn_downloader.CDN_DIR .. subDir .. "/"
  end
  noRelease = noRelease or false
  if not noRelease then
    local BusinessHelper = import("BusinessHelper")
    if not Client.IsEditor() and (globalConfig.IsDirectConnect() or BusinessHelper.GetIMSDKEnv() == 1) then
      strCDNDir = strCDNDir .. "Released/"
    else
      strCDNDir = strCDNDir .. "Beta/"
    end
  end
  noPlatform = noPlatform or false
  if not noPlatform then
    local strPlatform = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if strPlatform == DevicePlatformNameMacros.IOS then
      local is5sDevices = Client.IsIPhoneFiveS(GameFrontendHUD)
      if is5sDevices == true then
        strCDNDir = strCDNDir .. "PVRTC/"
      else
        strCDNDir = strCDNDir .. "iOS/"
      end
    else
      strCDNDir = strCDNDir .. "Android/"
    end
  end
  return strCDNDir
end
function cdn_downloader.download(cdnUrl, savePath, callBack, reTryNum, ExpiredUnixTime)
  reTryNum = reTryNum or 0
  if Client.IsFileExistsWithPakCheck(savePath) and reTryNum <= 0 then
    callBack(cdnUrl, savePath, true)
    return
  end
  local savePara = GetDownloadInfo(cdnUrl)
  if savePara then
    if savePara.downloadNum >= savePara.reTryNum + 1 then
      log(bWriteLog and "cdn_downloader.download callBack cdnUrl:" .. tostring(cdnUrl) .. "\239\188\140savePath:" .. tostring(savePath))
      callBack(cdnUrl, savePath, true)
      RemoveDownloadInfo(cdnUrl)
    else
      log(bWriteLog and "cdn_downloader.download addDownloadInfo cdnUrl:" .. tostring(cdnUrl) .. "\239\188\140savePath:" .. tostring(savePath))
      addDownloadInfo(cdnUrl, savePath, callBack, reTryNum)
    end
  else
    local retInfo = addDownloadInfo(cdnUrl, savePath, callBack, reTryNum, ExpiredUnixTime)
    StartDownload(retInfo)
  end
end
function cdn_downloader.CallBackDownload(cdnUrl, savePath, isSuc, retCode)
  if cdn_downloader.arrDownload and next(cdn_downloader.arrDownload) then
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    for i, v in pairs(cdn_downloader.arrDownload) do
      if v.cdnUrl == cdnUrl then
        if isSuc then
          for j, u in pairs(v.callFunList) do
            u(cdnUrl, savePath, true)
          end
          SaveExpiredInfo(cdnUrl)
          RemoveDownloadInfo(cdnUrl)
          break
        end
        if v.downloadNum >= v.reTryNum + 1 then
          do
            local isSave = false
            if v.savePath and Client.IsFileExistsWithPakCheck(v.savePath) then
              isSave = true
            end
            log(bWriteLog and "cdn_downloader.CallBackDownload cdnUrl:" .. tostring(cdnUrl) .. " savePath:" .. tostring(savePath) .. " isSuc:" .. tostring(isSuc) .. " isSave:" .. tostring(isSave))
            for k, x in pairs(v.callFunList) do
              x(cdnUrl, savePath, isSave)
            end
            LogExceptionAndReport(string.format("cdn_downloader Failed cdnUrl[%s] errCode[%s]", tostring(cdnUrl), tostring(retCode)), ClientToolsReport.Enum_CrashKit_Type.Enum_JS)
            RemoveDownloadInfo(cdnUrl)
          end
          break
        end
        if v.reTryNum > 0 then
          StartDownload(v)
        end
        break
      end
    end
  end
end
function cdn_downloader.MountPakFile(filePath)
  if filePath and Client.IsFileExistsWithPakCheck(filePath) then
    log(bWriteLog and "MountPakFile Start to mount " .. tostring(filePath))
    local success = Client.MountPakFile(filePath, "")
    local param = {
      tostring(success),
      tostring(false),
      tostring(filePath)
    }
    if Client.IsEditor() then
      return true
    end
    PufferDownloader.GEMReportSubEvent("PufferMountPak", param)
    return success
  end
  return false
end
function cdn_downloader.DownloadPak(pakUrl, pakSavePath, callback, noMount, ExpiredUnixTime)
  if not pakUrl or pakSavePath == "" then
    log(bWriteLog and "cdn_downloader.DownloadPak pakFileName:" .. tostring(pakUrl) .. " is nil")
    return
  end
  local isExist = Client.IsFileExistsWithPakCheck(pakSavePath)
  local isMountSuc = false
  if isExist then
    if noMount then
      isMountSuc = true
    else
      isMountSuc = cdn_downloader.MountPakFile(pakSavePath)
    end
    if callback then
      callback(isMountSuc)
    end
  else
    cdn_downloader.download(pakUrl, pakSavePath, function(isSuc)
      if isSuc then
        if noMount then
          isMountSuc = true
        else
          isMountSuc = cdn_downloader.MountPakFile(pakSavePath)
        end
        if callback then
          callback(isMountSuc)
        end
      end
    end, 0, ExpiredUnixTime)
  end
end
function cdn_downloader.ForceDownloadPak(pakUrl, pakSavePath, callback, noMount, ExpiredUnixTime)
  if not pakUrl or pakSavePath == "" then
    log(bWriteLog and "cdn_downloader.DownloadPak pakFileName:" .. tostring(pakUrl) .. " is nil")
    return
  end
  local isExist = Client.IsFileExistsWithPakCheck(pakSavePath)
  local isMountSuc = false
  log(bWriteLog and "cdn_downloader.ForceDownloadPak pakFileName:" .. tostring(pakUrl) .. ", savePath:" .. tostring(pakSavePath) .. ", isExist:" .. tostring(isExist))
  cdn_downloader.download(pakUrl, pakSavePath, function(isSuc)
    if isSuc then
      if noMount then
        isMountSuc = true
      else
        isMountSuc = cdn_downloader.MountPakFile(pakSavePath)
      end
      if callback then
        callback(isMountSuc)
      end
    end
  end, 1, ExpiredUnixTime)
end
function cdn_downloader.DeleteExpiredFiLe()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local preSave = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCDNDownload)
  if preSave and next(preSave) then
    local TimeUtil = require("client.common.time_util")
    local nowSvr = TimeUtil.GetServerTimeInSec()
    for k, v in pairs(preSave) do
      if v and v.time and tonumber(v.time) > 0 and nowSvr > tonumber(v.time) and v.path and v.path ~= "" then
        local isExist = Client.IsFileExistsWithPakCheck(v.path)
        if isExist then
          log(bWriteLog and "cdn_downloader.DeleteExpiredFiLe path: " .. tostring(v.path))
          Client.DeleteFile(v.path)
          preSave[k] = nil
        end
      end
    end
    PlayerPrefsSystem.SaveTableToFile_N(preSave, PlayerPrefsSystem.ePlayerPrefsType.eCDNDownload)
  end
end
return cdn_downloader
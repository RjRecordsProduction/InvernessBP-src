local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
local PufferConst = require("client.slua.logic.download.puffer_const")
local Main_City_Download_Tool = {}
local MainCityMapKey = main_city_config.MainCityMapKey
local MainCityKeyList = {MainCityMapKey}
function Main_City_Download_Tool.GetMainCityMapState()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  if not isFitVersion then
    return PufferConst.ENUM_DownloadState.Done
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.bHaveInitMapPaks then
    return PufferConst.ENUM_DownloadState.Error
  end
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, MainCityKeyList)
  log(bWriteLog and "Main_City_Download_Tool.GetMainCityMapState. state = " .. tostring(state))
  return state
end
function Main_City_Download_Tool.IsMainCityMapDownloaded(showDownloadUI)
  local state = Main_City_Download_Tool.GetMainCityMapState()
  if state == PufferConst.ENUM_DownloadState.Error then
    if showDownloadUI then
      ShowNotice(7421)
    end
    return false
  end
  local downloaded = state == PufferConst.ENUM_DownloadState.Done
  if not downloaded and showDownloadUI then
    log(bWriteLog and "Main_City_Download_Tool.IsMainCityMapDownloaded. show downloadUI")
    UIManager.ShowUI(UIManager.UI_Config.MainCity_DownloadGuide_Popup_UIBP)
  end
  return downloaded
end
function Main_City_Download_Tool.GetMainCityMapSize()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  if not isFitVersion then
    return 0, 0
  end
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, MainCityKeyList)
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  if cSize < 0 then
    cSize = 0
  end
  if tSize < 0.1 then
    tSize = 0.1
  end
  return cSize, tSize
end
function Main_City_Download_Tool.GetMainCityMapSizeTextAndPct()
  local cSize, tSize = Main_City_Download_Tool.GetMainCityMapSize()
  local pct = 1
  if tSize ~= 0 then
    pct = cSize / tSize
  end
  return Main_City_Download_Tool.GetMainCityMapSizeTextBySize(cSize, tSize), pct
end
function Main_City_Download_Tool.GetMainCityMapSizeTextBySize(cSize, tSize)
  local cSizeStr = string.format("%.1f", cSize)
  local tSizeStr = string.format("%.1f", tSize)
  return LocUtil.LocalizeResFormat(512021, cSizeStr, tSizeStr)
end
function Main_City_Download_Tool.ToggleDownloadMainCityMap()
  local state = Main_City_Download_Tool.GetMainCityMapState()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloadType = PufferConst.ENUM_DownloadType.MAP
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  if state == ENUM_DownloadState.Done then
    log(bWriteLog and "Main_City_Download_Tool.ToggleDownloadMainCityMap. downloaded")
    return
  elseif state == ENUM_DownloadState.Download or state == ENUM_DownloadState.Wait then
    PufferManager.Pause(downloadType, MainCityKeyList)
  else
    local MainCityUITriggertLog = require("GameLua.Mod.MainCity.Client.Config.MainCityUITriggertLog")
    local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
    local port = logic_main_city_enter_report.GetDownloadPort()
    MainCityUITriggertLog.ReportDownload(port, 1)
    PufferManager.Download(downloadType, MainCityKeyList)
  end
end
function Main_City_Download_Tool.DownloadMainCityMap()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, MainCityKeyList)
end
function Main_City_Download_Tool.MountMainCityMap()
  log(bWriteLog and "Main_City_Download_Tool.MountMainCityMap.")
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local mapList = PufferMapManager:GetDependMapFiles(MainCityMapKey)
  for k, v in pairs(mapList) do
    printf("Main_City_Download_Tool.MountMainCityMap. v=%s", tostring(v))
    PufferMapManager:MountMapPak(v)
  end
  PufferMapManager:MountMapPak("map_planph_3")
end
return Main_City_Download_Tool
local LogicKillInfo = {}
function LogicKillInfo.GetWeaponKillInfoAssetList(WeaponID)
  local WeaponCfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", WeaponID)
  if not WeaponCfg then
    return {}
  end
  local PathList = {
    WeaponCfg.BgPath or "",
    WeaponCfg.EffectPath or ""
  }
  return PathList
end
function LogicKillInfo.GetXSuitKillInfoAssetList(XSuitResID)
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", XSuitResID)
  if not XSuitCfg then
    return {}
  end
  local PathList = {
    XSuitCfg.KillEffect or ""
  }
  return PathList
end
function LogicKillInfo.IsWeaponKillInfoAssetDownload(WeaponID)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PathList = LogicKillInfo.GetWeaponKillInfoAssetList(WeaponID)
  local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, PathList)
  log(bWriteLog and string.format("LogicKillInfo.IsWeaponKillInfoAssetDownload BgPath:%s, EffectPath:%s, State:%s", tostring(PathList[1]), tostring(PathList[2]), DownloadState))
  return DownloadState == PufferConst.ENUM_DownloadState.Done
end
function LogicKillInfo.IsXSuitKillInfoAssetDownload(XSuitResID)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PathList = LogicKillInfo.GetXSuitKillInfoAssetList(XSuitResID)
  local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, PathList)
  log(bWriteLog and string.format("LogicKillInfo.IsXSuitKillInfoAssetDownload EffectPath:%s, State:%s", tostring(PathList[1]), DownloadState))
  return DownloadState == PufferConst.ENUM_DownloadState.Done
end
function LogicKillInfo.CheckKillPassiveDownloadByWeaponID(WeaponID)
  local PathList = LogicKillInfo.GetWeaponKillInfoAssetList(WeaponID)
  local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
  local bDownloaded = passive_resource_downloader:CheckResourceHasBeenDownloaded(PathList)
  log(bWriteLog and string.format("LogicKillInfo.CheckKillPassiveDownloadByWeaponID State:%s", bDownloaded))
  return bDownloaded
end
function LogicKillInfo.CheckKillPassiveDownloadByXSuitID(XSuitResID)
  local PathList = LogicKillInfo.GetXSuitKillInfoAssetList(XSuitResID)
  local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
  local bDownloaded = passive_resource_downloader:CheckResourceHasBeenDownloaded(PathList)
  log(bWriteLog and string.format("LogicKillInfo.CheckKillPassiveDownloadByXSuitID State:%s", bDownloaded))
  return bDownloaded
end
return LogicKillInfo
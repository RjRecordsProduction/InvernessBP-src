local PufferPrefetchManager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function PufferPrefetchManager:DefineAndResetData()
  self.PrefetchPaks = {}
  self.BigAppVersion = ""
end
function PufferPrefetchManager:OnPostSwitchGameStatus(preState, nextState)
end
function PufferPrefetchManager:InitReserve()
  log(bWriteLog and string.format("PufferPrefetchManager:InitReserve"))
  self.BigAppVersion = string.match(Client.GetAppVersion(), "%d.%d.%d")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  LogicPufferBundle.InitBundle()
  self:AutoDownloadPrefetch()
end
function PufferPrefetchManager:CheckVersionValid(appVersion, prefetchVersion)
  log(bWriteLog and string.format("PufferPrefetchManager:CheckVersionValid. appVersion=%s, prefetchVersion=%s", tostring(appVersion), tostring(prefetchVersion)))
  if not appVersion or not prefetchVersion then
    return false
  end
  local StringUtil = require("common.string_util")
  local appVersions = StringUtil.Split(appVersion, ".")
  local prefetchVersions = StringUtil.Split(prefetchVersion, ".")
  local diff1 = tonumber(prefetchVersions[1]) - tonumber(appVersions[1])
  if 0 < diff1 then
    return true
  end
  if diff1 < 0 then
    return false
  end
  return tonumber(prefetchVersions[2]) > tonumber(appVersions[2])
end
function PufferPrefetchManager:InitPretechPaks(existPaks)
  log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks"))
  if next(self.PrefetchPaks) then
    return
  end
  local prefetchJson = GCPufferDownloader.ReadFile(Puffer, PufferDownloader.FILE_LIST_PREFETCH_NAME)
  local prefetchTable = json.decode(prefetchJson) or {}
  if not prefetchTable or not next(prefetchTable) then
    return
  end
  local appVersion = Client.GetAppVersion()
  local checkVersion = prefetchTable.version
  if not self:CheckVersionValid(appVersion, checkVersion) then
    log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks not prefetch version. appVersion %s, checkVersion %s", tostring(appVersion), tostring(checkVersion)))
    return
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  PufferODPakManager:InitPretechODPaks(prefetchTable.ODPaks, existPaks)
  local basetexldPakName, basetexmdPakName
  for _, pakName in pairs(prefetchTable.version_mapping) do
    pakName = pakName .. ".pak"
    local skip = false
    local totalSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, pakName)
    if totalSize <= 0 then
      log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks totalSize = 0 pakName: %s", pakName))
      skip = true
    end
    if not PufferUpdater.IsDeviceNeedShaderPak(pakName) then
      skip = true
    end
    if string.find(pakName, "res_basetexld", nil, true) then
      basetexldPakName = pakName
    end
    if string.find(pakName, "res_basetexmd", nil, true) then
      basetexmdPakName = pakName
    end
    if not skip then
      self.PrefetchPaks[pakName] = {}
      self.PrefetchPaks[pakName].      self.PrefetchPaks[pakName].percent = 0
      self.PrefetchPaks[pakName].      if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName) then
        self.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Done
        self.PrefetchPaks[pakName].percent = 1000
        self.PrefetchPaks[pakName].curSize = self.PrefetchPaks[pakName].totalSize
      else
        self.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Not
        self.PrefetchPaks[pakName].percent = 0
        self.PrefetchPaks[pakName].curSize = 0
      end
      log(bWriteLog and string.format("InitPretechPaks. pakName = %s, state = %s", pakName, tostring(self.PrefetchPaks[pakName].state)))
    end
  end
  if basetexldPakName and basetexmdPakName then
    local havebasetexld = false
    local havebasetexmd = false
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
    for _, filename in pairs(ret) do
      if string.find(filename, "res_basetexld") then
        havebasetexld = true
        log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks havebasetexld:%s", tostring(havebasetexld)))
        break
      end
      if string.find(filename, "res_basetexmd") then
        havebasetexmd = true
        log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks havebasetexmd:%s", tostring(havebasetexmd)))
        break
      end
    end
    local isLowLevel = PufferUpdater.IsLowLevel()
    log(bWriteLog and string.format("PufferPrefetchManager:InitPretechPaks isLowLevel:%s", tostring(isLowLevel)))
    if isLowLevel then
      if havebasetexmd then
        self.PrefetchPaks[basetexldPakName] = nil
      else
        self.PrefetchPaks[basetexmdPakName] = nil
      end
    elseif havebasetexld then
      self.PrefetchPaks[basetexmdPakName] = nil
    else
      self.PrefetchPaks[basetexldPakName] = nil
    end
  end
  self:AutoDownloadPrefetch()
end
function PufferPrefetchManager:AutoDownloadPrefetch(autoDownload)
  log(bWriteLog and string.format("PufferPrefetchManager:AutoDownloadPrefetch"))
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if not PufferSwitch.AutoDownloadPrefetchSwitch then
    log(bWriteLog and string.format("PufferPrefetchManager:AutoDownloadPrefetch AutoDownloadPrefetchSwitch = false"))
    return
  end
  if autoDownload == nil then
    autoDownload = true
  end
  local extraData = {bAutoDownload = autoDownload, bSkipPopUp = true}
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.PREFETCH, {
    PufferConst.PREFETCH
  }, nil, nil, extraData)
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.PREFETCH_ODPACKID
  }, nil, nil, extraData)
end
function PufferPrefetchManager:StopDownloadPrefetch()
  log(bWriteLog and "PufferPrefetchManager:StopDownloadPrefetch.")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local downloadState = PufferPrefetchManager:GetState()
  LogicPufferBundle.ChooseStopDownloadByType(PufferConst.PREFETCH)
end
function PufferPrefetchManager:GetReserveState()
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if not PufferSwitch.GetPrefetchSwitch() then
    return PufferConst.ENUM_ReserveState.Not
  end
  if next(self.PrefetchPaks) then
    return PufferConst.ENUM_ReserveState.CanDownload
  end
  return PufferConst.ENUM_ReserveState.Reserved
end
function PufferPrefetchManager:GetState()
  local result = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if self.PrefetchPaks then
    for _, v in pairs(self.PrefetchPaks) do
      local state = v.state
      result = PufferManager.GetMixDownloadState(result, state)
    end
  end
  local odpackState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.PREFETCH_ODPACKID
  })
  result = PufferManager.GetMixDownloadState(result, odpackState)
  return result
end
function PufferPrefetchManager:HasNewResources()
  if self.PrefetchPaks and next(self.PrefetchPaks) then
    return true
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local pakNames = PufferODPakManager:GetPakNamesByODPakID(PufferConst.EODPackID.PREFETCH_ODPACKID)
  if pakNames and next(pakNames) then
    return true
  end
  return false
end
function PufferPrefetchManager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends)
  return self:GetState()
end
function PufferPrefetchManager:GetSize()
  local curSize = 0
  local totalSize = 0
  for _, v in pairs(self.PrefetchPaks) do
    curSize = curSize + v.curSize
    totalSize = totalSize + v.totalSize
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local odpackCurSize, odpackTotalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.PREFETCH_ODPACKID
  })
  odpackCurSize = odpackCurSize * PufferConst.MB
  odpackTotalSize = odpackTotalSize * PufferConst.MB
  curSize = curSize + odpackCurSize
  totalSize = totalSize + odpackTotalSize
  log(bWriteLog and "PufferPrefetchManager:GetSize curSize = " .. tostring(curSize) .. " totalSize = " .. tostring(totalSize))
  return curSize, totalSize
end
function PufferPrefetchManager:GetSizeByKeyList(downloadType, keyList, bSkipDepends)
  return self:GetSize()
end
function PufferPrefetchManager:IsPrefetch(key)
  return key == PufferConst.PREFETCH
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferPrefetchManager = class(CModuleBase, nil, PufferPrefetchManager)
return CPufferPrefetchManager
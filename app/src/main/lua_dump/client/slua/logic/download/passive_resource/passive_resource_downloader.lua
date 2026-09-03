local passive_resource_downloader = {}
local OPENLOG = true
function passive_resource_downloader:DefineAndResetData()
  self.UnDownloadedMark = {}
end
function passive_resource_downloader:OnLogOut()
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:OnLogOut"))
  end
  self.UnDownloadedMark = {}
end
function passive_resource_downloader:OnPreSwitchGameStatus(preState, nextState)
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:OnPreSwitchGameStatus pre = %s, nextState = %s", preState, nextState))
  end
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    self:StopPolling()
  end
end
function passive_resource_downloader:OnPostSwitchGameStatus(preState, nextState)
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:OnPostSwitchGameStatus pre = %s, nextState = %s", preState, nextState))
  end
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self:StartPolling()
  elseif preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:StartPolling()
  end
end
function passive_resource_downloader:CheckResourceHasBeenDownloaded(keyList)
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:CheckResourceHasBeenDownloaded"))
  end
  if type(keyList) ~= "table" then
    log_warning(bWriteLog and string.format("passive_resource_downloader:CheckResourceHasBeenDownloaded PathList is not table"))
    return false
  end
  if OPENLOG then
    log_tree("passive_resource_downloader:CheckResourceHasBeenDownloaded", keyList)
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, keyList)
  if DownloadState == PufferConst.ENUM_DownloadState.Done then
    return true
  end
  for i, key in pairs(keyList) do
    self.UnDownloadedMark[key] = true
  end
  self:DownloadTrigger()
  return false
end
function passive_resource_downloader:CheckTextureHasBeenDownloaded(path)
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:CheckOneResourceHasBeenDownloaded path:%s", tostring(path)))
  end
  if not path or path == "" then
    log_warning(bWriteLog and string.format("passive_resource_downloader:CheckOneResourceHasBeenDownloaded path is nil"))
    return false
  end
  local pak_util = require("client.common.pak_util")
  if pak_util.IsPufferDownloaded(path) then
    return true
  end
  if pak_util.IsFileExist(path) then
    return true
  end
  if GameStatus.InSupportDownloadState() then
    return false
  end
  self.UnDownloadedMark[path] = true
  self:DownloadTrigger()
  return false
end
function passive_resource_downloader:MergePendingDownloadedList(keyList)
  if type(keyList) ~= "table" then
    log_warning(bWriteLog and string.format("passive_resource_downloader:MergePendingDownloadedList PathList is not table"))
    return false
  end
  for i, key in pairs(keyList) do
    self.UnDownloadedMark[key] = true
  end
end
function passive_resource_downloader:DownloadTrigger()
  if not Client then
    log(bWriteLog and string.format("passive_resource_downloader:DownloadTrigger not in client"))
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and string.format("passive_resource_downloader:DownloadTrigger not in lobby or main city"))
    return
  end
  log(bWriteLog and string.format("passive_resource_downloader:DownloadTrigger in lobby or main city"))
  local keyList = {}
  local UEPathUtilityMethods = import("UEPathUtilityMethods")
  local unloadPaths = UEPathUtilityMethods.GetPassiveDownloadResourcePaths()
  for _, path in pairs(unloadPaths) do
    if OPENLOG then
      log(bWriteLog and string.format("passive_resource_downloader:DownloadTrigger unloadPaths path = %s", path))
    end
    keyList[#keyList + 1] = tostring(path)
  end
  UEPathUtilityMethods.ClearPassiveDownloadResourcePaths()
  local unloadIDList = UEPathUtilityMethods:GetPassiveDownloadResourceIDList()
  for _, id in pairs(unloadIDList) do
    if OPENLOG then
      log(bWriteLog and string.format("passive_resource_downloader:DownloadTrigger unloadIDList id = %s", id))
    end
    keyList[#keyList + 1] = tonumber(id)
  end
  UEPathUtilityMethods.ClearPassiveDownloadResourceIDList()
  for key, v in pairs(self.UnDownloadedMark) do
    keyList[#keyList + 1] = key
  end
  self.UnDownloadedMark = {}
  if OPENLOG then
    log_tree("passive_resource_downloader:DownloadTrigger", keyList)
  end
  if #keyList <= 0 then
    return
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, keyList, PufferTlog.Enum_TLog_From.Passive, nil, {bAutoDownload = true})
end
function passive_resource_downloader:StartPolling()
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:StartPolling"))
  end
  if self.PassiveResourceTTimer then
    self:RemoveTimer(self.PassiveResourceTTimer)
  end
  self.PassiveResourceTTimer = self:AddTimerLoop(0, function()
    self:DownloadTrigger()
  end, TIMER_INFINITE, 30)
end
function passive_resource_downloader:StopPolling()
  if OPENLOG then
    log(bWriteLog and string.format("passive_resource_downloader:StopPolling"))
  end
  if self.PassiveResourceTTimer then
    self:RemoveTimer(self.PassiveResourceTTimer)
  end
  self.PassiveResourceTTimer = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, passive_resource_downloader)
return CModuleTemplate
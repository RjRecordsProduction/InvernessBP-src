local puffer_odpak_downloader = {}
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
local StringUtil = require("common.string_util")
function puffer_odpak_downloader:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFERQUEUE_CLEAR, self.OnQueueClear, self)
end
function puffer_odpak_downloader:OnDownloadProgress(task, nowSize, totalSize, curStage)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if 100 < totalSize then
    task.totalSize = totalSize / 1024
    local pakData = PufferODPakManager:GetPakDataByPakName(task.pakName)
    if pakData then
      pakData.cSize = pakData.cSize + pakData.tSize / 30
      if pakData.cSize > pakData.tSize * 0.7 then
        pakData.cSize = pakData.tSize * 0.7
      end
    end
  end
  if task.packID and PufferODPakManager.ODPaks[task.packID] then
    PufferODPakManager.ODPaks[task.packID].state = PufferConst.ENUM_DownloadState.Download
  end
  puffer_odpak_downloader.__super.OnDownloadProgress(self, task, nowSize, totalSize, curStage)
end
function puffer_odpak_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  if isSuccess then
    local isPakFileExist = Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. task.pakName)
    if not isPakFileExist then
      log(bWriteLog and "PufferManager.SyncFinishToCallback pak is corrupt pakName = " .. tostring(task.pakName))
      isSuccess = false
      errorCode = PufferDownloader.ERR_PAK_CORRUPTED
      PufferDownloader.filestateList[outterTaskID].lastErrno = PufferDownloader.ERR_PAK_CORRUPTED
    end
    PufferDownloader.SetPakExist(task.pakName, isPakFileExist)
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if errorCode == 1 or errorCode == -1 then
    PufferODPakManager.BlackListPaks[task.pakName] = true
    if task.path then
      PufferODPakManager.BlackListPaks[task.path] = true
    end
  end
  PufferODPakManager:OnDownloadFinish(task, isSuccess, errorCode, false)
  puffer_odpak_downloader.__super.OnDownloadFinish(self, task, errorCode)
  if isSuccess then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferMapManager:UploadClientMapState(task.pakName)
    if task.path then
      PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, task.path)
    elseif task.itemID and task.itemID > 0 then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local upgradeCfgList = ItemUpgradeMgr:GetUpgradeGroupByItemID(task.itemID)
      local cfg = CDataTable.GetTableData("Item", task.itemID)
      if next(upgradeCfgList) or cfg and cfg.ItemQuality >= 6 then
        PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, task.itemID)
      end
    end
    if task.from == PufferTlog.Enum_TLog_From.Battle then
      PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Battle, PufferTlog.Enum_TLog_Optype.Finish, task.itemID)
    end
  end
end
function puffer_odpak_downloader:OnQueueClear()
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for i, v in pairs(PufferODPakManager.ODPaks) do
    if v.state == PufferConst.ENUM_DownloadState.Download or v.state == PufferConst.ENUM_DownloadState.Wait then
      v.state = PufferConst.ENUM_DownloadState.Pause
    end
  end
  EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_PAUSEALLDOWNLOAD)
end
function puffer_odpak_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.ODPAK then
      if type(v) == "number" then
        self:DownloadByItemID(v, from, callback, extraData)
      elseif StringUtil.Starts(v, PufferConst.PUFFERPATCH) then
        self:Download(v, from, callback, extraData)
      elseif string.sub(v, 1, 7) == PufferConst.ODPAKS_RELATIVE_DIR then
        self:Download(v, from, callback, extraData)
      elseif PufferODPakManager:GetPakNamesByFeatureID(v) then
        local pakName = next(PufferODPakManager:GetPakNamesByFeatureID(v))
        if pakName then
          self:Download(pakName, nil, nil, from, callback, extraData, v)
        end
        if PufferUGCPakManager.AllFeatureIDMap[v] then
          log(bWriteLog and "[DebugUGC] puffer_odpak_downloader:DownloadByKeyList featureKey = " .. tostring(v) .. ",pakName = " .. tostring(pakName))
        end
      else
        self:DownloadByPath(v, from, callback, extraData)
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.ODPACK then
      self:DownloadByPackID(v, from, callback, extraData)
    end
  end
end
function puffer_odpak_downloader:DownloadByItemID(itemID, from, callback, extraData)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager:GetStateByItemID(itemID) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  log(bWriteLog and "puffer_odpak_downloader:DownloadByItemID itemID = " .. tostring(itemID))
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  if FBI.IsIllegalTime(itemID) then
    return
  end
  local paks = PufferODPakManager:GetPakNamesByItemID(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg then
    local ItemBigIconPakName = PufferManager.GetPakName(itemCfg.ItemBigIcon)
    if ItemBigIconPakName ~= "" then
      self:Download(ItemBigIconPakName, itemID, nil, from, callback, extraData)
    end
    local PreviewPakName = PufferManager.GetPakName(itemCfg.Preview)
    if PreviewPakName ~= "" then
      self:Download(PreviewPakName, itemID, nil, from, callback, extraData)
    end
  end
  for pakName, _ in pairs(paks) do
    self:Download(pakName, itemID, nil, from, callback, extraData)
  end
end
function puffer_odpak_downloader:DownloadByPath(path, from, callback, extraData)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager:GetStateByPath(path) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  if FBI.IsIllegalTime(path) then
    return
  end
  local pakName = PufferManager.GetPakName(path)
  if pakName ~= "" then
    self:Download(pakName, nil, path, from, callback, extraData)
  end
end
function puffer_odpak_downloader:DownloadByPackID(packID, from, callback, extraData)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager:GetStateByPackID(packID) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local pack = PufferODPakManager.ODPaks[packID]
  if not pack then
    return
  end
  extraData = extraData or {}
  local okCallback = function()
    local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
    for pakName, v in pairs(pack.paks) do
      if v.state ~= PufferConst.ENUM_DownloadState.Done then
        local task = {}
        task.        task.        task.        task.downloadType = PufferConst.ENUM_DownloadType.ODPAK
        task.        puffer_queue:Push(task)
      end
    end
    pack.state = PufferConst.ENUM_DownloadState.Download
    puffer_queue:StartDownload()
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_STARTDOWNLOAD_ODPACK, packID)
    if packID == PufferConst.EODPackID.DIY then
      local weapon_diy_system = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      weapon_diy_system.DownloadDIY(from)
    elseif packID == PufferConst.EODPackID.Notice then
      local NoticesUtil = require("client.logic.Notice.NoticesUtil")
      NoticesUtil.DownloadNoticeDependency()
    end
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    local StringUtil = require("common.string_util")
    local packCfg = CDataTable.GetTableData("PakInfoTable", packID)
    if packCfg and packCfg.DependActorIDs and packCfg.DependActorIDs ~= "" then
      for i, v in pairs(StringUtil.Split(packCfg.DependActorIDs, "|")) do
        local actorID = tonumber(v)
        local bankPath = ActorVoiceSystem.GetBankPathByActorID(actorID)
        log(bWriteLog and string.format("puffer_odpak_downloader:DownloadByPackID bankPath:%s", bankPath))
        self:DownloadByPath(bankPath)
      end
    end
    PufferTlog.SendTLog(from, PufferTlog.Enum_TLog_Optype.Start, packID, nil, packID == PufferConst.EODPackID.PREFETCH_ODPACKID)
  end
  if extraData.bSkipPopUp or PufferSwitch.CanAutoDownload() then
    okCallback()
  else
    log(bWriteLog and "puffer_odpak_downloader:DownloadByPackID packID = " .. tostring(packID))
    local title = LocUtil.GetLocalizeResStr(5077)
    local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPACK, {packID})
    local strSize = string.format("%.2f MB", totalSize)
    local askTips = LocUtil.LocalizeResFormat(7921, strSize)
    local cfg = CDataTable.GetTableData("PakInfoTable", packID)
    if cfg and cfg.DownloadTipsID > 0 then
      strSize = string.format("%.2f", totalSize)
      askTips = LocUtil.LocalizeResFormat(cfg.DownloadTipsID, strSize)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, askTips, okCallback)
  end
end
function puffer_odpak_downloader:Download(pakName, itemID, path, from, callback, extraData, featureKey)
  if StringUtil.Starts(pakName, PufferConst.PUFFERPATCH) then
    local PufferResDownloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_downloader)
    PufferResDownloader:Download(pakName, from, callback)
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager.BlackListPaks[pakName] then
    local PufferErrorHandler = require("client.slua.logic.download.puffer.puffer_error_handler")
    PufferErrorHandler.ShowErrorTips(1)
    return
  end
  if PufferODPakManager:GetStateByPakName(pakName) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  extraData = extraData or {}
  local task = {}
  task.  task.  task.  task.  task.  task.  task.bFirst = extraData.bFirst
  task.bAutoDownload = extraData.bAutoDownload
  task.downloadType = PufferConst.ENUM_DownloadType.ODPAK
  local packID, packData = PufferODPakManager:GetPackDataByPakName(pakName)
  if packID and packData and packData.paks[pakName] then
    if extraData.bAutoDownload and packData.paks[pakName].haveDeleted then
      return
    end
    if packData.paks[pakName].cSize == 0 then
      packData.paks[pakName].cSize = packData.paks[pakName].cSize + packData.paks[pakName].tSize / 15
    end
    packData.state = PufferConst.ENUM_DownloadState.Download
    task.  end
  if pakName == PufferConst.LOCK_PAKNAME then
    log(bWriteLog and string.format("puffer_odpak_downloader:Download pakName:%s, itemID:%s, path:%s", pakName, tostring(itemID), tostring(path)))
  end
  puffer_odpak_downloader.__super.Download(self, task)
end
function puffer_odpak_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.ODPAK then
      if type(v) == "number" then
        self:PauseByItemID(v, bWait, bNotStartDownload)
      elseif StringUtil.Starts(v, PufferConst.PUFFERPATCH) then
        local PufferResDownloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_downloader)
        PufferResDownloader:Pause(v, bWait, bNotStartDownload)
      elseif string.sub(v, 1, 7) == PufferConst.ODPAKS_RELATIVE_DIR then
        self:Pause(v, bWait, bNotStartDownload)
      elseif PufferODPakManager:GetPakNamesByFeatureID(v) then
        local pakName = next(PufferODPakManager:GetPakNamesByFeatureID(v))
        self:Pause(pakName, bWait, bNotStartDownload)
      else
        local PakNames = PufferODPakManager:GetPakNameByTableKey(v)
        if PakNames then
          for PakName, _ in pairs(PakNames) do
            self:Pause(PakName, bWait, bNotStartDownload)
          end
        else
          self:PauseByPath(v, bWait, bNotStartDownload)
        end
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.ODPACK then
      self:PauseByPackID(v)
    end
  end
end
function puffer_odpak_downloader:PauseByPath(path, bWait, bNotStartDownload)
  local pakName = PufferManager.GetPakName(path)
  self:Pause(pakName, bWait, bNotStartDownload)
end
function puffer_odpak_downloader:PauseByItemID(itemID, bWait, bNotStartDownload)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager.itemToPaks[itemID] then
    for pakName, _ in pairs(PufferODPakManager.itemToPaks[itemID].paks) do
      self:Pause(pakName, bWait, bNotStartDownload)
    end
  end
end
function puffer_odpak_downloader:PauseByPackID(packID)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if PufferODPakManager:GetStateByPackID(packID) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local pack = PufferODPakManager.ODPaks[packID]
  if not pack then
    return
  end
  for pakName, v in pairs(pack.paks) do
    PufferODPakManager.PauseDontAutoDownloadPaks[pakName] = true
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:EraseByPaks(pack.paks)
  pack.state = PufferConst.ENUM_DownloadState.Pause
end
function puffer_odpak_downloader:Pause(pakName, bWait, bNotStartDownload)
  if pakName == "" or pakName == nil then
    return
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local pakData = PufferODPakManager:GetPakDataByPakName(pakName)
  if pakData then
    if pakData.state == PufferConst.ENUM_DownloadState.Done then
      return
    end
    pakData.state = PufferConst.ENUM_DownloadState.Pause
  end
  PufferODPakManager.PauseDontAutoDownloadPaks[pakName] = true
  puffer_odpak_downloader.__super.Pause(self, pakName, bWait, bNotStartDownload)
end
function puffer_odpak_downloader:PauseAllDownloadTasks()
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  if not PufferODPakManager.ODPaks then
    return
  end
  for i, v in pairs(PufferODPakManager.ODPaks) do
    if v.state == PufferConst.ENUM_DownloadState.Download or v.state == PufferConst.ENUM_DownloadState.Wait then
      v.state = PufferConst.ENUM_DownloadState.Pause
    end
  end
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferODPak = class(CPufferBase, nil, puffer_odpak_downloader)
return CPufferODPak
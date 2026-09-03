local puffer_map_downloader = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local _GetDownloadType = function(keyName)
  local downloadType = PufferConst.ENUM_DownloadType.ODPAK
  if keyName == PufferConst.FIT_SHADER_KEY then
    downloadType = PufferConst.ENUM_DownloadType.RES
  end
  return downloadType
end
function puffer_map_downloader:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    self:ResumeDownload()
  end
end
function puffer_map_downloader:OnDownloadProgress(task, curSize, totalSize, curStage)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local mapKeyList = PufferMapManager.pakNameToMapKey[task.pakName]
  if not mapKeyList then
    return
  end
  for _, mapKey in pairs(mapKeyList) do
    local map = PufferMapManager.MapPaks[mapKey]
    if map then
      map.state = PufferConst.ENUM_DownloadState.Download
      map.canPause = PufferMapManager:CanPauseByStage(curStage)
      local proportion = PufferDownloader.StageTimeProportion[curStage]
      if map.percent < 50 or 100 < curSize then
        map.percent = curSize / totalSize * proportion[1] * 1000 + proportion[2] * 1000
      end
      if map.percent >= 740 then
        map.canPause = false
      end
      if map.canPause and (map.percent < 50 or 100 < curSize) then
        map.curSize = curSize * 1024
        map.totalSize = totalSize * 1024
      end
    end
  end
  puffer_map_downloader.__super.OnDownloadProgress(self, task, curSize, totalSize, curStage, false)
end
function puffer_map_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local pakName = task.pakName
  local mapKeyList = PufferMapManager.pakNameToMapKey[pakName]
  if not mapKeyList then
    return
  end
  local needMount = false
  local newSize = 0
  if isSuccess then
    newSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName)
  end
  for _, mapKey in pairs(mapKeyList) do
    local map = PufferMapManager.MapPaks[mapKey]
    if map and not map.notInPuffer then
      log(bWriteLog and string.format("puffer_map_downloader.OnDownloadFinish mapKey:%s isSuccess:%s", mapKey, isSuccess))
      if isSuccess then
        map.state = PufferConst.ENUM_DownloadState.Done
        map.percent = 1000
        log(bWriteLog and string.format("puffer_map_downloader.OnDownloadFinish oldSize:%s newSize:%s", map.totalSize, newSize))
        map.totalSize = newSize
        map.curSize = map.totalSize
        PufferDownloader.SetDownloadKeyRecord(mapKey, true)
        local cfg = CDataTable.GetTableData("MapPakTable", mapKey)
        if cfg and cfg.defaultMount == 1 then
          needMount = true
        end
        PufferMapManager:ReportMapEvent(mapKey, PufferConst.ENUM_ReportMapEventType.Done)
      else
        map.state = PufferConst.ENUM_DownloadState.Error
        if errorCode == 1 then
          ShowNotice(32543)
        end
        PufferMapManager:ReportMapEvent(mapKey, PufferConst.ENUM_ReportMapEventType.Error)
      end
      map.canPause = true
    end
  end
  if isSuccess then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, pakName)
    PufferMapManager:UploadClientMapState()
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    PufferDeleteManager.UpdateDeviceFreeSpace(true)
    if needMount then
      local path = Client.ProjectSavedDir() .. "Paks/" .. pakName
      Client.MountPakFile(path, "")
    end
  end
  puffer_map_downloader.__super.OnDownloadFinish(self, task, errorCode, false)
end
local DEFAULT_MAP_DEPENDENCE_PARAMS = {bFirst = true}
function puffer_map_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  extraData = extraData or {}
  extraData.excludeMapKey = extraData.excludeMapKey or {}
  for _, mapKey in pairs(keyList) do
    local mapInfo = PufferMapManager.MapPaks[mapKey]
    if mapInfo then
      if mapInfo.depends then
        for i, v in pairs(mapInfo.depends) do
          log(bWriteLog and "puffer_map_downloader:DownloadByKeyList depend:" .. tostring(i))
          if PufferMapManager.MapPaks[i] then
            local bIsExcludeMapKey = false
            if extraData and extraData.excludeMapKey and extraData.excludeMapKey[i] then
              bIsExcludeMapKey = true
            end
            if not bIsExcludeMapKey then
              extraData.excludeMapKey[i] = true
              self:DownloadByKeyList(PufferConst.ENUM_DownloadType.MAP, {i}, from, nil, extraData)
            end
          else
            PufferManager.Download(_GetDownloadType(i), {i}, from, nil, DEFAULT_MAP_DEPENDENCE_PARAMS)
          end
        end
      end
      log(bWriteLog and string.format("puffer_map_downloader:DownloadByKeyList mapKey:%s map.state:%s", tostring(mapKey), tostring(mapInfo.state)))
      if mapInfo.state ~= PufferConst.ENUM_DownloadState.Done then
        self:Download(mapKey, from)
      end
    end
  end
  if Client.IsJaguar() then
    local extraData = {bSkipPopUp = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPACK, {
      PufferConst.EODPackID.ModeSelect
    }, nil, nil, extraData)
  end
end
function puffer_map_downloader:Download(mapKey, from)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local map = PufferMapManager.MapPaks[mapKey]
  if not map or map.notInPuffer then
    return
  end
  if map.state == PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "puffer_map_downloader:Download map is done mapKey = " .. mapKey)
    return
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local downloadTask = puffer_queue:GetDownloadingMapOrResTask()
  if downloadTask then
    if downloadTask.downloadType == PufferConst.ENUM_DownloadType.MAP then
      log(bWriteLog and string.format("puffer_map_downloader:Download pause:%s", downloadTask.mapKey))
      self:Pause(downloadTask.mapKey, true, true)
    elseif downloadTask.downloadType == PufferConst.ENUM_DownloadType.RES then
      log(bWriteLog and string.format("puffer_map_downloader:Download pause:%s", downloadTask.resKey))
      PufferManager.Pause(PufferConst.ENUM_DownloadType.RES, {
        downloadTask.resKey
      }, true, true)
    end
  end
  local task = {}
  task.  task.pakName = map.pakName
  task.  task.downloadType = PufferConst.ENUM_DownloadType.MAP
  local mapKeyList = PufferMapManager.pakNameToMapKey[task.pakName]
  if mapKeyList then
    for _, v in pairs(mapKeyList) do
      local map = PufferMapManager.MapPaks[v]
      if map then
        map.        map.state = PufferConst.ENUM_DownloadState.Download
      end
    end
  end
  log(bWriteLog and "puffer_map_downloader:Download mapKey = " .. mapKey)
  puffer_map_downloader.__super.Download(self, task, false)
  PufferMapManager:ReportMapEvent(mapKey, PufferConst.ENUM_ReportMapEventType.Start)
  if PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey}) ~= PufferConst.ENUM_DownloadState.Done then
    PufferManager.Download(PufferConst.ENUM_DownloadType.SHADER, {mapKey})
  end
end
function puffer_map_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  for _, mapKey in pairs(keyList) do
    local map = PufferMapManager.MapPaks[mapKey]
    if map then
      for dependKey, _ in pairs(map.depends) do
        if PufferMapManager.MapPaks[dependKey] then
          self:Pause(dependKey, bWait, true)
        else
          PufferManager.Pause(_GetDownloadType(dependKey), {dependKey})
        end
      end
      if map.state ~= PufferConst.ENUM_DownloadState.Done then
        self:Pause(mapKey, bWait, true)
      end
    end
  end
  if not bNotStartDownload then
    local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
    puffer_queue:StartDownload()
  end
end
function puffer_map_downloader:Pause(mapKey, bWait, bNotStartDownload, _visitingKeys)
  _visitingKeys = _visitingKeys or {}
  if _visitingKeys[mapKey] then
    log_warning_format("puffer_map_downloader:Pause check dependency loop, skip mapKey = %s", mapKey)
    return
  end
  _visitingKeys[mapKey] = true
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.MapPaks[mapKey] then
    return
  end
  if PufferMapManager:CanPause(mapKey) then
    local pakName = PufferMapManager.MapPaks[mapKey].pakName
    local mapKeyList = PufferMapManager.pakNameToMapKey[pakName]
    if mapKeyList then
      for _, v in pairs(mapKeyList) do
        local map = PufferMapManager.MapPaks[v]
        if map then
          for dependKey, vv in pairs(map.depends) do
            if PufferMapManager.MapPaks[dependKey] then
              log(bWriteLog and "puffer_map_downloader:Pause dependKey = " .. dependKey)
              self:Pause(dependKey, bWait, bNotStartDownload, _visitingKeys)
            elseif not bWait then
              PufferManager.Pause(_GetDownloadType(dependKey), {dependKey}, bWait, bNotStartDownload)
            end
          end
          if map.state == PufferConst.ENUM_DownloadState.Download or map.state == PufferConst.ENUM_DownloadState.Wait then
            if bWait then
              map.state = PufferConst.ENUM_DownloadState.Wait
            else
              map.state = PufferConst.ENUM_DownloadState.Pause
            end
            map.canPause = true
          end
        end
      end
      log(bWriteLog and "puffer_map_downloader:Pause pakName = " .. pakName)
      puffer_map_downloader.__super.Pause(self, pakName, bWait, bNotStartDownload, false)
    end
  else
    log(bWriteLog and "puffer_map_downloader:Pause. Map Can't Pause " .. mapKey)
    local notice = LocUtil.GetLocalizeResStr(201025)
    ShowNotice(notice)
  end
end
function puffer_map_downloader:PauseAllDownloadTasks()
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.MapPaks then
    return
  end
  for mapKey, map in pairs(PufferMapManager.MapPaks) do
    if map.state == PufferConst.ENUM_DownloadState.Wait or map.state == PufferConst.ENUM_DownloadState.Download then
      self:Pause(mapKey, false, true)
    end
  end
end
function puffer_map_downloader:ResumeDownload()
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.MapPaks then
    return
  end
  for mapKey, v in pairs(PufferMapManager.MapPaks) do
    if v.showInDownloader and v.lastState then
      if v.lastState == PufferConst.ENUM_DownloadState.Download then
        self:Download(mapKey, v.from)
      elseif v.lastState == PufferConst.ENUM_DownloadState.Wait then
        v.state = PufferConst.ENUM_DownloadState.Wait
      end
    end
  end
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferMap = class(CPufferBase, nil, puffer_map_downloader)
return CPufferMap
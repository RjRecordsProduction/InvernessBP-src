local PufferMapManager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local StringUtil = require("common.string_util")
local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local MAIN_CITY_MAP_KEY = "map_maincity"
local _GetDownloadType = function(keyName)
  local downloadType = PufferConst.ENUM_DownloadType.ODPAK
  if keyName == PufferConst.FIT_SHADER_KEY then
    downloadType = PufferConst.ENUM_DownloadType.RES
  end
  return downloadType
end
function PufferMapManager:DefineAndResetData()
  log_format("PufferMapManager:DefineAndResetData.")
  self.bHaveInitMapPaks = false
  self.bReEnterGame = false
  self.MapPaks = {}
  self.antiDepends = {}
  self.pakNameToMapKey = {}
  self.cacheState = {}
  self.mapReportState = {}
  self.ResDeleteKey = {}
  self.DynamicPaks = {}
  self.useDynamic = false
  self.defaultMapKey = "Baltic_Main"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  self.isFitVersion = PublishRegionMacros.IsFITVersion()
  self.fromLogin = false
  self.MapPakDownloadDiffFile = HDmpveRemote.HDmpveRemoteConfigGetBool("MapPakDownloadDiffFile", true)
end
function PufferMapManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, self.OnLoadingPreFinish, self)
end
function PufferMapManager:OnLoadingPreFinish()
  printf("PufferMapManager:OnLoadingPreFinish.")
  if self.fromLogin then
    printf("PufferMapManager:OnLoadingPreFinish. self.bHaveInitMapPaks=%s", tostring(self.bHaveInitMapPaks))
    if IsEditor and not slua_GameFrontendHUD.bEnableEditorPufferDownload then
      return
    end
    if not self.bHaveInitMapPaks then
      self:InitMapPaks()
    end
  end
end
function PufferMapManager:OnPostSwitchGameStatus(preState, nextState)
  self.fromLogin = false
  if nextState == GameStatus.Login then
    self.bHaveInitMapPaks = false
  elseif nextState == GameStatus.Lobby then
    if preState == GameStatus.Fighting then
      if self.bHaveInitMapPaks then
        self:UploadMapStateByDeleteNotify()
      end
      if self.DynamicPaks and Client and Client.DynamicUpdatePakOrderBackUp then
        local mapKeys = self.DynamicPaks
        self.DynamicPaks = nil
        for k, v in pairs(mapKeys) do
          log(bWriteLog and "PufferMapManager:OnPostSwitchGameStatus. DynamicUpdatePakOrderBackUp:" .. tostring(k))
          Client.DynamicUpdatePakOrderBackUp(k)
        end
      end
    elseif preState == GameStatus.Login then
      self.fromLogin = true
    end
  end
end
function PufferMapManager:InitDefaultMapKey()
  self.defaultMapKey = "Baltic_Main"
  log(bWriteLog and "PufferMapManager:InitDefaultMapKey. self.defaultMapKey = " .. tostring(self.defaultMapKey))
end
function PufferMapManager:InitMapPaks()
  Client.AddAttachFileString("InitMapPaks", true, "start")
  log(bWriteLog and "PufferMapManager:InitMapPaks")
  self:InitDefaultMapKey()
  local ProjectSavedDir = Client.ProjectSavedDir()
  local downloadDirPath = ProjectSavedDir .. PufferDownloader.DOWNLOAD_DIR_RELATIVE
  local defaultDownloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  local isSamePath = downloadDirPath == defaultDownloadPath
  log(bWriteLog and "PufferMapManager:InitMapPaks. isSamePath = " .. tostring(isSamePath))
  local SavedFileUtil = import("SavedFileUtil")
  local files = SavedFileUtil.FindFiles(downloadDirPath, "", false)
  local PakDirExistFiles = {}
  for _, fileName in pairs(files) do
    PakDirExistFiles[fileName] = true
  end
  self:CheckCorrupted(PakDirExistFiles, downloadDirPath)
  self.pakNameToMapKey = {}
  self.antiDepends = {}
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local appVersion = Client.GetApplicationVersion()
  local isSplitMapPakVersion = Client.IsSplitMapPakVersion()
  local isJaguar = Client.IsJaguar()
  local ProjectContentDir = Client.ProjectContentDir()
  local contentFiles = SavedFileUtil.FindFiles(ProjectContentDir .. "paks/", ".pak", false)
  local ContentExistFiles = {}
  for _, fileName in pairs(contentFiles) do
    ContentExistFiles[fileName] = true
  end
  local fileListJson
  local versionMap = {}
  local PufferMapInitOptimize = HDmpveRemote.HDmpveRemoteConfigGetBool("PufferMapInitOptimize", true)
  if PufferMapInitOptimize or PufferDownloader.IsFileListExist() then
    fileListJson = PufferDownloader.GetPufferFileListJson() or {}
  end
  local dependsNum = 0
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local defaultComplete = not isSplitMapPakVersion or PufferSwitch.BanDownload
  log(bWriteLog and "PufferMapManager:InitMapPaks. defaultComplete = " .. tostring(defaultComplete))
  local version_mapping = fileListJson and fileListJson.version_mapping or nil
  local isFitVersion = self.isFitVersion
  local mapCfg = CDataTable.GetTable("MapPakTable")
  for _, v in pairs(mapCfg) do
    local mapKey = v.MapKey
    local data = {}
    local preMapData = self.MapPaks[mapKey]
    if preMapData then
      data.lastState = preMapData.lastState
      data.showInDownloader = preMapData.showInDownloader
      data.filepre = preMapData.filepre
      data.mapName = preMapData.mapName
      data.mapInApp = preMapData.mapInApp
    else
      if isJaguar then
        data.showInDownloader = v.showInDownloader == 10 or v.showInDownloader == 11 or false
      else
        data.showInDownloader = v.showInDownloader == 1 or v.showInDownloader == 11 or false
      end
      data.filepre = v.filepre
      data.mapName = v.name
    end
    data.canPause = true
    local pakName = data.filepre .. appVersion .. ".pak"
    local defaultMapKey = data.filepre .. "default"
    data.pakName = self:GetRealFilename(pakName, defaultMapKey, PakDirExistFiles, version_mapping)
    if not self.pakNameToMapKey[data.pakName] then
      self.pakNameToMapKey[data.pakName] = {}
    end
    table.insert(self.pakNameToMapKey[data.pakName], mapKey)
    if version_mapping and not version_mapping[defaultMapKey] then
      log(bWriteLog and "PufferMapManager:InitMapPaks. not in fileListJson. name = " .. mapKey)
      data.notInPuffer = true
      data.state = PufferConst.ENUM_DownloadState.Done
    elseif preMapData and preMapData.state == ENUM_DownloadState.Done then
      data.state = preMapData.state
      if preMapData.mapInApp then
        data.notInPuffer = true
      end
    elseif PakDirExistFiles[data.pakName] then
      data.state = ENUM_DownloadState.Done
    else
      data.percent = preMapData and preMapData.percent or 0
      data.curSize = preMapData and preMapData.curSize or 0
      data.state = preMapData and preMapData.state or ENUM_DownloadState.Not
      if data.state ~= ENUM_DownloadState.Wait or data.state ~= ENUM_DownloadState.Download then
        data.state = ENUM_DownloadState.Not
      end
    end
    if defaultComplete then
      data.state = ENUM_DownloadState.Done
    end
    if not data.notInPuffer and not data.mapInApp then
      local bExist = false
      local mapInApp = false
      if mapKey == "map_pakfilebindiff" then
        if HDmpveRemote.HDmpveRemoteConfigGetBool("MapPakFileBinDiffCheck", false) then
          bExist = Client.IsFileExistInCSCWithCheckRaw("PakFileBinDiff")
        else
          bExist = true
        end
        mapInApp = bExist
      else
        if not isSamePath then
          bExist = Client.IsFileExistsWithOutPakCheck(downloadDirPath .. data.pakName)
        end
        local preStr = data.filepre
        if not bExist then
          mapInApp = ContentExistFiles[preStr .. "obb.pak"] or ContentExistFiles[preStr .. "obb2.pak"]
        end
      end
      if mapInApp or bExist then
        data.state = ENUM_DownloadState.Done
        data.        data.notInPuffer = mapInApp
      end
    end
    if data.notInPuffer then
      data.totalSize = 0
    else
      local totalSize, isDiff = self:GetMapSizeCompressed(data.pakName, fileListJson, versionMap, PakDirExistFiles)
      data.      data.    end
    if data.state == ENUM_DownloadState.Done then
      data.percent = 1000
      data.curSize = data.totalSize
    end
    log_format("PufferMapManager:InitMapPaks mapKey:%s pakName:%s state:%s, totalSize:%s, mapInApp=%s, notInPuffer=%s,isDiff=%s", mapKey, data.pakName, data.state, data.totalSize, data.mapInApp, data.notInPuffer, data.isDiff)
    data.depends = {}
    local dependPak = StringUtil.Split(v.depends, ";")
    for _, vv in pairs(dependPak) do
      dependsNum = dependsNum + 1
      if vv ~= "" then
        local dependKey = ""
        if tonumber(vv) then
          local paks = PufferManager.GetPakNamesByItemID(tonumber(vv))
          for itemPakName, _ in pairs(paks) do
            data.depends[itemPakName] = tonumber(vv)
            self:AddAntiDependKey(itemPakName, mapKey)
          end
        elseif StringUtil.Starts(vv, "pack_") then
          local packID = tonumber(string.sub(vv, 6))
          if packID then
            local pakNames = PufferODPakManager:GetPakNamesByODPakID(packID)
            for packPakName, _ in pairs(pakNames) do
              data.depends[packPakName] = vv
              self:AddAntiDependKey(packPakName, mapKey)
            end
          end
        elseif StringUtil.Ends(vv, ".mp4") then
          if strRegion ~= PublishRegionMacros.CE and strRegion ~= PublishRegionMacros.FITCE then
            local videoPakName = PufferManager.GetPakNameByVideoPath(vv)
            if videoPakName ~= "" then
              data.depends[videoPakName] = vv
              dependKey = videoPakName
            end
          end
        elseif PufferManager.GetPakNamesByFeatureID(vv) then
          local paks = PufferManager.GetPakNamesByFeatureID(vv)
          local featruePakName = next(paks)
          if featruePakName ~= nil then
            data.depends[featruePakName] = vv
            dependKey = featruePakName
          else
            log(bWriteLog and "featruePakName is nil. vv = " .. vv)
          end
        else
          data.depends[vv] = vv
          dependKey = vv
        end
        self:AddAntiDependKey(dependKey, mapKey)
      end
    end
    if isFitVersion and not self:IsDefaultMapKey(mapKey) then
      data.depends[PufferConst.FIT_SHADER_KEY] = PufferConst.FIT_SHADER_KEY
    else
      data.depends[PufferConst.FIT_SHADER_KEY] = nil
    end
    if not isFitVersion and mapKey == MAIN_CITY_MAP_KEY then
      data.depends = {}
    end
    self.MapPaks[mapKey] = data
  end
  self.cacheState = {}
  self.bHaveInitMapPaks = true
  self:UploadClientMapState(nil, true)
  Client.AddAttachFileString("InitMapPaks", false, "end dependsNum:" .. tostring(dependsNum))
  EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_REFRESH_MAP)
end
function PufferMapManager:GetRealFilename(filename, defaultMapKey, existFiles, version_map)
  if not filename then
    return ""
  end
  if existFiles[filename] then
    return filename
  end
  if not version_map then
    log_warning("PufferMapManager:GetRealFilename parse json KEY version_mapping NOT found " .. filename)
    return filename
  end
  if not version_map[defaultMapKey] then
    return filename
  else
    return version_map[defaultMapKey] .. ".pak"
  end
end
function PufferMapManager:AddAntiDependKey(dependKey, mapKey)
  if dependKey ~= "" then
    if not self.isFitVersion and mapKey == MAIN_CITY_MAP_KEY then
      return
    end
    if not self.antiDepends[dependKey] then
      self.antiDepends[dependKey] = {}
    end
    table.insert(self.antiDepends[dependKey], mapKey)
  end
end
function PufferMapManager:GetMapSizeCompressed(mapName, fileListJson, versionMap, existFiles)
  if not fileListJson or not mapName then
    log(bWriteLog and "PufferMapManager:GetMapSizeCompressed. file list not exist, mapName = " .. tostring(mapName))
    return 0, false
  end
  local downloadFilename, isDiff = self:GetMapFilename(mapName, fileListJson, versionMap, existFiles)
  log(bWriteLog and "PufferMapManager:GetMapSizeCompressed. downloadFilename = " .. tostring(mapName))
  if not downloadFilename then
    return 0, false
  end
  local fileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, downloadFilename)
  log(bWriteLog and "PufferMapManager:GetMapSizeCompressed. fileSize = " .. tostring(fileSize))
  if 0 < fileSize and fileSize < 0.1 * PufferConst.MB then
    fileSize = 0.1 * PufferConst.MB
  end
  return fileSize, isDiff
end
function PufferMapManager:GetMapFilename(mapName, fileListJson, versionMap, existFiles)
  local diffList = fileListJson.diff_list or {}
  local downloadFilename = mapName
  if not self.MapPakDownloadDiffFile then
    return downloadFilename, false
  end
  local targetFilePrefix, targetFileVersionNo = PufferDownloader.ParsePakName(mapName)
  if targetFilePrefix == nil or targetFileVersionNo == nil then
    return nil, false
  end
  if not versionMap.init then
    for filename, _ in pairs(existFiles) do
      local prefix, versionNo = PufferDownloader.ParsePakName(filename)
      if prefix ~= nil and versionNo ~= nil then
        if versionMap[prefix] ~= nil then
          if PufferDownloader.CompareVersion(versionNo, versionMap[prefix]) > 0 then
            versionMap[prefix] = versionNo
          end
        else
          versionMap[prefix] = versionNo
        end
      end
    end
    versionMap.init = true
  end
  local oldVersion = versionMap[targetFilePrefix]
  local bNeedDownloadDiff = false
  if oldVersion then
    if diffList[oldVersion] then
      downloadFilename = diffList[oldVersion][mapName]
      bNeedDownloadDiff = true
    end
    if downloadFilename == nil then
      downloadFilename = mapName
    end
  end
  return downloadFilename, bNeedDownloadDiff
end
function PufferMapManager:CheckCorrupted(existFiles, dirPath)
  log(bWriteLog and "PufferMapManager:CheckCorrupted")
  if not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "PufferMapManager:CheckCorrupted PufferJsonDownloadReturn = false")
    return
  end
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  for fileName, _ in pairs(existFiles) do
    if StringUtil.Ends(fileName, ".corrupted") then
      PufferDeleteManager.DeletePak(dirPath .. fileName)
    end
  end
end
function PufferMapManager:IsMap(key)
  return self.MapPaks[key] ~= nil
end
function PufferMapManager:IsUGCMap(key)
  if self:IsMap(key) and (StringUtil.Starts(key, PufferConst.UGC_MAP_PREFIX1) or StringUtil.Starts(key, PufferConst.UGC_MAP_PREFIX2)) then
    return true
  end
  return false
end
function PufferMapManager:CanPause(mapKey)
  if not self.MapPaks[mapKey] then
    return true
  end
  return self.MapPaks[mapKey].canPause
end
function PufferMapManager:CanPauseByStage(stage)
  if stage >= PufferDownloader.STAGE_FILE_MERGING then
    return false
  else
    return true
  end
end
function PufferMapManager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends, excludeMapKey)
  local result = PufferConst.ENUM_DownloadState.Done
  if not keyList then
    return PufferConst.ENUM_DownloadState.Done
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for i, v in pairs(keyList) do
    local state = self:GetState(v, bSkipDepends, bSkipVidepDepends, excludeMapKey)
    result = PufferManager.GetMixDownloadState(result, state)
  end
  return result
end
function PufferMapManager:IsDefaultMapKey(mapKey)
  return mapKey == self.defaultMapKey
end
function PufferMapManager:GetState(mapKey, bSkipDepends, bSkipVidepDepends, excludeMapKey)
  if PufferSwitch.BanDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  if Client.bEditorSkipDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  local mapData = self.MapPaks[mapKey]
  if not mapData then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = mapData.state
  if self:IsDefaultMapKey(mapKey) or mapData.notInPuffer then
    state = PufferConst.ENUM_DownloadState.Done
  elseif state ~= PufferConst.ENUM_DownloadState.Done then
    if not _G.IsEditor and not PufferDownloader.PufferJsonDownloadReturn then
      return PufferConst.ENUM_DownloadState.Error
    end
    return state
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local dependState = PufferConst.ENUM_DownloadState.Done
  if not bSkipDepends then
    local depends = mapData.depends
    if depends then
      for k, v in pairs(depends) do
        local tempState = PufferConst.ENUM_DownloadState.Done
        if self.MapPaks[k] then
          if not excludeMapKey or not excludeMapKey[k] then
            tempState = self:GetState(k)
          end
        elseif bSkipVidepDepends and type(v) == "string" and StringUtil.Ends(v, ".mp4") then
          tempState = PufferConst.ENUM_DownloadState.Done
        else
          tempState = PufferManager.GetState(_GetDownloadType(k), {k})
        end
        if PufferConst.DownloadStatePriority[tempState] > PufferConst.DownloadStatePriority[dependState] then
          dependState = tempState
        end
      end
    end
  end
  if dependState == PufferConst.ENUM_DownloadState.Done then
    dependState = PufferManager.GetState(PufferConst.ENUM_DownloadType.SHADER, {mapKey})
  end
  if PufferConst.DownloadStatePriority[dependState] > PufferConst.DownloadStatePriority[state] then
    return dependState
  end
  return state
end
function PufferMapManager:GetSizeByKeyList(downloadType, keyList, bSkipDepends, excludeKeys)
  local curSize = 0
  local totalSize = 0
  local dependCurSize = 0
  local dependTotalSize = 0
  for _, v in pairs(keyList) do
    local cSize, tSize, dcSize, dtSize = self:GetSize(v, bSkipDepends, nil, excludeKeys)
    curSize = curSize + cSize
    totalSize = totalSize + tSize
    dependCurSize = dependCurSize + dcSize
    dependTotalSize = dependTotalSize + dtSize
  end
  return curSize, totalSize, dependCurSize, dependTotalSize
end
function PufferMapManager:GetSize(mapKey, bSkipDepends, checkList, excludeKeys)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local curSize = 0
  local totalSize = 0
  local dependCurSize = 0
  local dependTotalSize = 0
  local map = self.MapPaks[mapKey]
  local MinSize = PufferConst.MB * 0.1
  if map then
    checkList = checkList or {}
    checkList[mapKey] = true
    if not bSkipDepends and map.depends then
      for dependKey, _ in pairs(map.depends) do
        local cSize = 0
        local tSize = 0
        if self.MapPaks[dependKey] and self.MapPaks[dependKey].showInDownloader then
          if not checkList[dependKey] and (not excludeKeys or not excludeKeys[dependKey]) then
            cSize, tSize = self:GetSize(dependKey, nil, checkList)
          end
        else
          local curSize, totalSize = PufferManager.GetSize(_GetDownloadType(dependKey), {dependKey})
          if MinSize > curSize then
            curSize = MinSize
          end
          if MinSize > totalSize then
            totalSize = MinSize
          end
          cSize, tSize = curSize, totalSize
        end
        dependCurSize = dependCurSize + cSize
        dependTotalSize = dependTotalSize + tSize
      end
    end
    curSize = dependCurSize + map.curSize
    totalSize = dependTotalSize + map.totalSize
  end
  return curSize, totalSize, dependCurSize, dependTotalSize
end
function PufferMapManager:GetAllDependPakByMapKey(mapKey, dependPakMap)
  dependPakMap = dependPakMap or {}
  local map = self.MapPaks[mapKey]
  if not map then
    return dependPakMap
  end
  for k, v in pairs(map.depends) do
    if k == v then
      self:GetAllDependPakByMapKey(k, dependPakMap)
    else
      dependPakMap[k] = true
    end
  end
  return dependPakMap
end
function PufferMapManager:GetMapName(mapKey)
  if not self.MapPaks[mapKey] then
    return ""
  end
  return self.MapPaks[mapKey].mapName
end
function PufferMapManager:GetMapPakName(mapKey)
  if not self.MapPaks[mapKey] then
    return ""
  end
  return self.MapPaks[mapKey].pakName
end
function PufferMapManager:GetMapKeysByPakName(pakName)
  if not pakName then
    return
  end
  return self.pakNameToMapKey[pakName]
end
function PufferMapManager:UploadClientMapState(dependKey, force)
  if dependKey and not self.antiDepends[dependKey] then
    return
  end
  local StateParam = {}
  local allUpdate = force == true or next(self.cacheState) == nil
  local checkState
  self.ResDeleteKey = {}
  if allUpdate then
    self.cacheState = {}
  else
    checkState = PufferConst.ENUM_DownloadState.Done
  end
  local changeMapKeys
  if not allUpdate and dependKey then
    changeMapKeys = {}
    for _, v in ipairs(self.antiDepends[dependKey]) do
      changeMapKeys[v] = true
    end
  end
  local LogicUGCCreativeWow = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_creativewow)
  local mapCfg = CDataTable.GetTable("Map")
  for mapID, v in pairs(mapCfg) do
    local mapKey = v.MapKey
    if changeMapKeys == nil or changeMapKeys[mapKey] then
      local map_ID = tonumber(mapID)
      if allUpdate or self.cacheState[map_ID] ~= checkState then
        local state = PufferConst.ENUM_DownloadState.Done
        if not PufferSwitch.BanDownload then
          if mapID == 77 then
            state = PufferConst.ENUM_DownloadState.Done
          elseif mapKey == "map_creativewow" then
            state = LogicUGCCreativeWow:GetResState()
          elseif v and v.IsSingleValid == 1011 then
            local excludeMapKey = {map_creativedestructible = true, map_dinosaurcore = true}
            state = self:GetState(mapKey, nil, nil, excludeMapKey)
          elseif mapID == 20000 then
            local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
            state = Main_City_Download_Tool.GetMainCityMapState()
          else
            state = self:GetState(mapKey)
          end
          if state ~= PufferConst.ENUM_DownloadState.Done then
            state = PufferConst.ENUM_DownloadState.Not
          end
        end
        if allUpdate or self.cacheState[map_ID] ~= state then
          StateParam[map_ID] = state
        end
      end
    end
  end
  if not PufferSwitch.BanDownload then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    LogicTxMissionDownload.GetTPlanSubMapStat(StateParam, allUpdate)
  end
  if next(StateParam) then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    log(bWriteLog and "PufferMapManager:UploadClientMapState. allUpdate " .. tostring(allUpdate))
    if allUpdate then
      for k, v in pairs(StateParam) do
        self.cacheState[k] = v
        if v == PufferConst.ENUM_DownloadState.Not then
          StateParam[k] = nil
        end
      end
      TeamupHandler.send_update_client_map_info(StateParam)
    else
      self:SendUserFinishDownloadMap(StateParam)
    end
    log_tree("StateParam", StateParam)
  end
end
function PufferMapManager:UploadMapStateByDeleteNotify()
  if not next(self.ResDeleteKey) then
    return
  end
  log(bWriteLog and "PufferMapManager:UploadMapStateByDeleteNotify.")
  log_tree("self.ResDeleteKey = ", self.ResDeleteKey)
  local changeMapKeys = {}
  for key, _ in pairs(self.ResDeleteKey) do
    if self.MapPaks[key] then
      changeMapKeys[key] = true
    end
    if self.antiDepends[key] then
      for _, v in ipairs(self.antiDepends[key]) do
        changeMapKeys[v] = true
      end
    end
  end
  self.ResDeleteKey = {}
  log_tree("changeMapKeys = ", changeMapKeys)
  local stateParams = {}
  local mapCfg = CDataTable.GetTable("Map")
  for mapID, v in pairs(mapCfg) do
    local map_ID = tonumber(mapID)
    if changeMapKeys[v.MapKey] and self.cacheState[map_ID] == PufferConst.ENUM_DownloadState.Done then
      stateParams[map_ID] = PufferConst.ENUM_DownloadState.Not
    end
  end
  if not PufferSwitch.BanDownload then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    LogicTxMissionDownload.GetTPlanSubMapStat(stateParams, false)
  end
  log_tree("stateParams = ", stateParams)
  self:SendUserFinishDownloadMap(stateParams)
end
function PufferMapManager:SendUserFinishDownloadMap(StateParam)
  local mapStateChanged = false
  for k, v in pairs(StateParam) do
    if self.cacheState[k] ~= v then
      self.cacheState[k] = v
      mapStateChanged = true
    end
  end
  log(bWriteLog and "PufferMapManager:SendUserFinishDownloadMap. " .. tostring(mapStateChanged))
  if mapStateChanged then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_user_finish_download_map(StateParam)
  end
end
function PufferMapManager:ReportMapEvent(mapKey, eventType)
  local map = self.MapPaks[mapKey]
  if not (map and map.pakName) or map.pakName == "" then
    return
  end
  local network_status = Client.HasActiveWifi() and PufferConst.ENUM_ReportMapNetworkStatus.Wifi or PufferConst.ENUM_ReportMapNetworkStatus["4g"]
  local cacheKey = network_status * 100 + eventType
  if self.mapReportState[mapKey] == cacheKey then
    return
  end
  self.mapReportState[mapKey] = cacheKey
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_new_report_map_download_log(network_status, nil, mapKey, eventType)
end
function PufferMapManager:GetVersion()
  if self.mapVersion then
    return self.mapVersion
  end
  local version = Client.GetApplicationVersion()
  if Client.GetAndroidSOVersion() == 64 then
    local StringUtil = require("common.string_util")
    local splitRet = StringUtil.Split(version, ".")
    local last = tostring(tonumber(splitRet[4]) - 5)
    local version64 = splitRet[1] .. "." .. splitRet[2] .. "." .. splitRet[3] .. "." .. last
    self.mapVersion = version64
  else
    self.mapVersion = version
  end
  return self.mapVersion
end
function PufferMapManager:GetDependMapFilesByMapKey(mapKey, version, list, handleList)
  list = list or {}
  handleList = handleList or {}
  if handleList[mapKey] then
    return list
  end
  handleList[mapKey] = true
  local cfg = CDataTable.GetTableData("MapPakTable", mapKey)
  if not cfg then
    return list
  end
  if cfg.MapKey and cfg.MapKey ~= "" then
    local mapFileName = cfg.filepre .. version .. ".pak"
    mapFileName = PufferDownloader.GetRealFilename(mapFileName)
    list[mapFileName] = cfg.MapKey
    log(bWriteLog and string.format("PufferMapManager:GetDependMapFiles mapFileName1:%s", mapFileName))
  end
  if cfg.depends and cfg.depends ~= "" then
    local dependPak = StringUtil.Split(cfg.depends, ";")
    for i, v in pairs(dependPak) do
      if v ~= "" and StringUtil.Starts(v, PufferConst.MAP_PREFIX) then
        self:GetDependMapFilesByMapKey(v, version, list, handleList)
      end
    end
  end
  return list
end
function PufferMapManager:GetDependMapFiles(mapKey, subMode, map_id, mapList)
  log(bWriteLog and string.format("PufferMapManager:GetDependMapFiles mapKey:%s subMode:%s map_id:%s", tostring(mapKey), tostring(subMode), tostring(map_id)))
  Client.AddAttachFileString("GetDependMapFiles", true, "start mapKey:" .. tostring(mapKey))
  mapList = mapList or {}
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not PufferDownloader.PufferJsonDownloadReturn or not self.MapPaks[mapKey] then
    Client.AddAttachFileString("GetDependMapFiles", false, "Return:" .. tostring(PufferDownloader.PufferJsonDownloadReturn))
    local mapID = map_id
    local version = self:GetVersion()
    if mapID == nil then
      local modCfg = CDataTable.GetTableData("BTMode", subMode)
      if modCfg then
        mapID = modCfg.MapID
      end
    end
    if mapID then
      local mapCfg = CDataTable.GetTableData("Map", mapID)
      if mapCfg then
        self:GetDependMapFilesByMapKey(mapCfg.MapKey, version, mapList)
      end
    end
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.MissingPak, PufferTlog.Enum_TLog_Optype.Finish, "puffer Error")
  else
    local fileName = self.MapPaks[mapKey].pakName
    local realName = PufferDownloader.GetRealFilename(fileName)
    mapList[realName] = mapKey
    log(bWriteLog and string.format("PufferMapManager:GetDependMapFiles realName:%s", realName))
    local depends = self.MapPaks[mapKey].depends
    if depends then
      Client.AddAttachFileString("GetDependMapFiles", false, "depends")
      for i, v in pairs(depends) do
        if self.MapPaks[i] then
          self:GetDependMapFiles(i, nil, nil, mapList)
        else
          local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
          local strRegion = Client.GetPublishRegion()
          if strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE or not Client.IsReleaseVersion(NetInterface) then
            if PufferManager.GetState(_GetDownloadType(i), {i}) == PufferConst.ENUM_DownloadState.Done then
              log(bWriteLog and string.format("PufferMapManager:GetDependMapFiles mapKey:%s, ODPak:%s exist", mapKey, i))
            else
              log(bWriteLog and string.format("PufferMapManager:GetDependMapFiles mapKey:%s, ODPak:%s not exist", mapKey, i))
              local fileInfo = string.format("mapKey:%s, ODPak:%s not exist", mapKey, i)
              Client.AddAttachFileString("PufferResState", false, fileInfo)
            end
          end
        end
      end
    end
  end
  if mapKey == MAIN_CITY_MAP_KEY and not self.isFitVersion and mapList then
    for key, _mapKey in pairs(mapList) do
      if _mapKey ~= MAIN_CITY_MAP_KEY then
        log_format("PufferMapManager:GetDependMapFiles. remove _mapKey=%s", _mapKey)
        mapList[key] = nil
      end
    end
  end
  return mapList
end
function PufferMapManager:GetDependFeatures(mapKey, subMode, map_id)
  log(bWriteLog and string.format("PufferMapManager:GetDependFeatures mapKey:%s subMode:%s map_id:%s", tostring(mapKey), tostring(subMode), tostring(map_id)))
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local list = {}
  local mapID = map_id
  if mapID == nil then
    local modCfg = CDataTable.GetTableData("BTMode", subMode)
    if modCfg then
      mapID = modCfg.MapID
    end
  end
  if not mapID then
    return list
  end
  local mapCfg = CDataTable.GetTableData("Map", mapID)
  if not mapCfg then
    return list
  end
  local mapPakCfg = CDataTable.GetTableData("MapPakTable", mapCfg.MapKey)
  if not mapPakCfg then
    return list
  end
  local StringUtil = require("common.string_util")
  local recursiveStack = {
    mapCfg.MapKey
  }
  while 0 < #recursiveStack do
    local dep = recursiveStack[#recursiveStack]
    table.remove(recursiveStack)
    local depcfg = CDataTable.GetTableData("MapPakTable", dep)
    if depcfg and depcfg.depends and depcfg.depends ~= "" then
      local dependPaks = StringUtil.Split(depcfg.depends, ";")
      for i, v in pairs(dependPaks) do
        if v ~= "" then
          local paks = {}
          if tonumber(v) then
            paks = PufferManager.GetPakNamesByItemID(tonumber(v))
          elseif v ~= "" and StringUtil.Starts(v, PufferConst.MAP_PREFIX) then
            table.insert(recursiveStack, v)
          else
            paks = PufferManager.GetPakNamesByFeatureID()
          end
          for itemPakName, _ in pairs(paks) do
            table.insert(list, itemPakName)
          end
        end
      end
    end
  end
  return list
end
function PufferMapManager:MountMapPak(mapKey)
  log(bWriteLog and string.format(" mapKey:%s", mapKey))
  if PufferSwitch.BanDownload then
    return true
  end
  local mapData = self.MapPaks[mapKey]
  if not mapData then
    log(bWriteLog and "PufferMapManager:MountMapPak not in mapPaks mapKey = " .. mapKey)
    local cfg = CDataTable.GetTableData("MapPakTable", mapKey)
    if not cfg then
      return true
    end
    local filePre = cfg.filepre
    local filePath = ""
    local json = PufferDownloader.GetPufferFileListJson()
    local pakDirPath = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR
    if json and json.version_mapping then
      printf("PufferMapManager:MountMapPak.from json")
      if json.version_mapping[filePre .. "default"] then
        filePath = pakDirPath .. json.version_mapping[filePre .. "default"] .. ".pak"
      else
        return true
      end
    else
      local version = self:GetVersion()
      local mapFileName = filePre .. version .. ".pak"
      filePath = pakDirPath .. mapFileName
    end
    printf("PufferMapManager:MountMapPak. filePath=%s", tostring(filePath))
    if not Client.IsFileExistsWithOutPakCheck(filePath) then
      return false
    end
    if Client.MountPakFile(filePath, "") then
      return true
    end
    return false
  end
  if mapData.notInPuffer then
    log(bWriteLog and "PufferMapManager:MountMapPak map notInPuffer. mapKey = " .. mapKey)
    return true
  end
  if self:IsDefaultMapKey(mapKey) then
    return true
  end
  local pakName = mapData.pakName
  if not PufferDownloader.IsFileExist(GameFrontendHUD, pakName) then
    log(bWriteLog and "PufferMapManager:MountMapPak not found pakName = " .. pakName)
    return false
  end
  local path = Client.ProjectSavedDir() .. "Paks/" .. pakName
  if Client.IsMounted(path) then
    return true
  end
  if Client.MountPakFile(path, "") then
    return true
  end
  return false
end
function PufferMapManager:MountFeaturesODPak(mapKey, sub_mode)
  log(bWriteLog and string.format("PufferMapManager:MountFeaturesODPak mapKey:%s sub_mode%s", mapKey, tostring(sub_mode)))
  do return end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local featureFiles = self:GetDependFeatures(mapKey, sub_mode)
  for _, filename in pairs(featureFiles) do
    local path = Client.ProjectSavedDir() .. "Paks/" .. filename
    if not Client.IsFileExistsWithOutPakCheck(path) then
      PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.MissingPak, PufferTlog.Enum_TLog_Optype.Finish, filename)
      local mountResult = "DependFeature Path:" .. path .. " not exist!"
      Client.AddAttachFileString("mountmodpaks", false, mountResult)
    else
      local mountResult = "DependFeature Path:" .. path
      if not Client.IsMounted(path) then
        local success = Client.MountPakFile(path, "")
        log(bWriteLog and "DependFeature Start to mount " .. tostring(path) .. tostring(success))
        mountResult = mountResult .. " mounted " .. tostring(success)
        Client.AddAttachFileString("mountmodpaks", false, mountResult)
      else
        log(bWriteLog and "DependFeature Already mounted " .. tostring(path))
        mountResult = mountResult .. " Already mounted."
        Client.AddAttachFileString("mountmodpaks", false, mountResult)
      end
    end
  end
end
function PufferMapManager:MountCurMaps()
  if _G.IsEditor then
    return true
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewID = logic_mode_selection:GetCurSelectInfo()
  if not viewID then
    return true
  end
  log(bWriteLog and "PufferMapManager:MountCurMaps viewID = " .. tostring(viewID))
  local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  if not viewData then
    return true
  end
  log_tree("PufferMapManager:MountCurMaps viewData = ", viewData)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local mapKeyList = logic_mode_map_download:GetMapKeyListByViewData(viewData)
  if not mapKeyList then
    return true
  end
  log(bWriteLog and "PufferMapManager:MountCurMaps mapKeyList = " .. tostring(mapKeyList))
  local corruptedMaps = ""
  for _, mapKey in pairs(mapKeyList) do
    if not self:MountMapPak(mapKey) then
      local mapName = self:GetMapName(mapKey)
      corruptedMaps = corruptedMaps .. mapName .. " "
    end
  end
  if corruptedMaps ~= "" then
    log(bWriteLog and "PufferMapManager:MountCurMaps corruptedMaps = " .. corruptedMaps)
    local str = LocUtil.LocalizeResFormat(33633, corruptedMaps)
    ShowNotice(str)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.01, function()
      self:InitMapPaks()
    end)
    return false
  end
  return true
end
function PufferMapManager:MountPakBySubMode(subMode, map_id, excludeMapKey)
  printf("PufferMapManager:MountPakBySubMode. subMode=%s, map_id=%s", tostring(subMode), tostring(map_id))
  log_tree("PufferMapManager:MountPakBySubMode. excludeMapKey = ", excludeMapKey)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local mapKey = MatchModeMgrSystem.GetMapKeyBySubMode(subMode)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  Client.AddAttachFileString("mountsubmodpaks", true, "sub_mode:" .. tostring(subMode) .. " mapKey:" .. tostring(mapKey))
  local corruptedMaps = ""
  if not mapKey or PufferSwitch.BanDownload then
    return ""
  end
  local mapFiles = self:GetDependMapFiles(mapKey, subMode, map_id)
  log_tree("PufferMapManager:MountPakBySubMode. mapFiles = ", mapFiles)
  local pakList = {}
  local mapKeys = {}
  local corruptedMapKeys = {}
  local localFiles
  if mapFiles and next(mapFiles) then
    for filename, mapKey in pairs(mapFiles) do
      mapKeys[mapKey] = true
      log(bWriteLog and string.format("NetUtil.MountPakOfMode mapFileName:%s", filename))
      local mapData = self.MapPaks[mapKey]
      local err = false
      local path = Client.ProjectSavedDir() .. "Paks/" .. filename
      if excludeMapKey and excludeMapKey[mapKey] then
        printf("PufferMapManager:MountPakBySubMode. exclude mapKey=%s", tostring(mapKey))
        path = nil
      elseif self:IsDefaultMapKey(mapKey) or mapData and mapData.notInPuffer then
        log(bWriteLog and "PufferMapManager:MountPakBySubMode. map not in puffer")
        path = nil
      elseif not Client.IsFileExistsWithOutPakCheck(path) then
        PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.MissingPak, PufferTlog.Enum_TLog_Optype.Finish, filename)
        local mountResult = " Path:" .. path .. " not exist!"
        Client.AddAttachFileString("mountsubmodpaks", false, mountResult)
        local splits = StringUtil.Split(filename, ".")
        local pre = splits[1] .. "." .. splits[2] .. "." .. splits[3]
        local replaceFileName = ""
        if localFiles == nil then
          localFiles = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
        end
        for _, localFileName in pairs(localFiles) do
          if StringUtil.Starts(localFileName, pre) and (replaceFileName == "" or localFileName > replaceFileName) then
            replaceFileName = localFileName
          end
        end
        log(bWriteLog and "PufferMapManager:MountPakBySubMode. replaceFileName = " .. tostring(replaceFileName))
        if replaceFileName ~= "" then
          path = Client.ProjectSavedDir() .. "Paks/" .. replaceFileName
        else
          printf("PufferMapManager:MountPakBySubMode. not replace")
          if _G.IsEditor then
            if slua_GameFrontendHUD.bEnableEditorPufferDownload then
              err = true
            end
          else
            err = true
          end
          path = nil
        end
      end
      if path then
        local mountResult = " Path:" .. path
        if not Client.IsMounted(path) then
          if not Client.MountPakFile(path, "") then
            log(bWriteLog and "PufferMapManager:MountPakBySubMode. add 2")
            err = true
            mountResult = mountResult .. " mounted fail"
            Client.AddAttachFileString("mountsubmodpaks", false, mountResult)
          end
        else
          log(bWriteLog and "Already mounted " .. tostring(path))
          mountResult = mountResult .. " Already mounted."
          Client.AddAttachFileString("mountsubmodpaks", false, mountResult)
        end
      end
      if err then
        corruptedMapKeys[mapKey] = true
      end
      if mapData and mapData.depends then
        if mapKey == MAIN_CITY_MAP_KEY and mapData.notInPuffer then
          printf("PufferMapManager:MountPakBySubMode. skip maincity")
        else
          for pakName, key in pairs(mapData.depends) do
            pakList[pakName] = key
          end
        end
      end
    end
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    log_tree("pakList = ", pakList)
    if next(pakList) then
      local dependsNum = 0
      local err = false
      local ForcedKeepODPaks = {}
      for pakName, v in pairs(pakList) do
        dependsNum = dependsNum + 1
        if StringUtil.Starts(pakName, "ODPaks/") and pakName ~= PufferConst.LOCK_PAKNAME and pakName ~= PufferConst.CE_LOCK_PAKNAME then
          if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName) then
            ForcedKeepODPaks[#ForcedKeepODPaks + 1] = pakName
            local fileInfo = string.format("PufferMapManager:MountPakBySubMode mapKey:%s, ODPak:%s Key:%s exist", mapKey, pakName, v)
            log(bWriteLog and fileInfo)
            Client.AddAttachFileString("mountsubmodpaks", false, fileInfo)
          else
            local fileInfo = string.format("PufferMapManager:MountPakBySubMode mapKey:%s, ODPak:%s Key:%s not exist", mapKey, pakName, v)
            log(bWriteLog and fileInfo)
            Client.AddAttachFileString("mountsubmodpaks", false, fileInfo)
            err = true
            local pakData = PufferODPakManager:GetPakDataByPakName(pakName)
            if pakData then
              pakData.state = PufferConst.ENUM_DownloadState.Not
            end
          end
        end
      end
      if err then
        log(bWriteLog and "PufferMapManager:MountPakBySubMode. add 3")
        corruptedMapKeys[mapKey] = true
      else
        local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
        local ScriptHelperEngine = import("ScriptHelperEngine")
        if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and ScriptHelperEngine.IsLowMemoryDevice() then
          Client.AppendForcedKeepODPaks(ForcedKeepODPaks)
        end
      end
      Client.AddAttachFileString("dependsNum", true, tostring(dependsNum))
    end
  end
  PufferMapManager:MountFeaturesODPak(mapKey, subMode)
  log_tree("PufferMapManager:MountPakBySubMode. corruptedMapKeys = ", corruptedMapKeys)
  if next(corruptedMapKeys) then
    for k, v in pairs(corruptedMapKeys) do
      local mapName = self:GetMapName(k)
      corruptedMaps = corruptedMaps .. mapName .. " "
    end
  end
  log(bWriteLog and string.format("PufferMapManager:MountPakBySubMode corruptedMaps:%s", corruptedMaps))
  if corruptedMaps ~= "" then
    local str = LocUtil.LocalizeResFormat(33633, corruptedMaps)
    ShowNotice(str)
    self:InitMapPaks()
  else
    self:RecordDynamicPaks(mapKeys)
  end
  return corruptedMaps
end
function PufferMapManager:RecordDynamicPaks(mapKeys)
  if not self.useDynamic then
    log(bWriteLog and "PufferMapManager:RecordDynamicPaks. return")
    return
  end
  if Client and Client.DynamicUpdatePakOrder and mapKeys and next(mapKeys) then
    self.DynamicPaks = mapKeys
    for key, v in pairs(mapKeys) do
      log(bWriteLog and "PufferMapManager:RecordDynamicPaks. DynamicUpdatePakOrder:" .. tostring(key))
      Client.DynamicUpdatePakOrder(key)
    end
  end
end
function PufferMapManager:IsDepend(mapKey, pakName, needMapCheck)
  local map = self.MapPaks[mapKey]
  if not map then
    return false
  end
  if map.pakName == pakName then
    return true
  end
  if map.depends[pakName] then
    return true
  end
  if needMapCheck then
    for k, v in pairs(map.depends) do
      if k == v and self:IsDepend(k, pakName, true) then
        return true
      end
    end
  end
  return false
end
function PufferMapManager:CheckIsRoomSpecialMap(mapID)
  log(bWriteLog and "SpecialMap===" .. tostring(mapID))
  if not mapID or mapID == 0 then
    return false
  end
  local mapInfo = CDataTable.GetTableData("Map", mapID)
  if not mapInfo then
    return false
  end
  local tKeyName = "SpecialRoomMapConfig"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    tKeyName = tKeyName .. "_KJ"
  end
  local config = CDataTable.GetTableData(tKeyName, mapID)
  if not (config and config.BundleID) or config.BundleID == 0 then
    return false
  end
  local cfg = CDataTable.GetTableData("DownloaderNewTable", config.BundleID)
  if not cfg then
    return false
  end
  local StringUtil = require("common.string_util")
  local content = StringUtil.Split(cfg.BundleContent, "|")
  for _, v in pairs(content) do
    if tostring(v) == mapInfo.MapKey then
      return true
    end
  end
  return false
end
function PufferMapManager:CheckClassicMapNotDownload(mapKey)
  mapKey = mapKey or "Baltic_Main"
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local title = LocUtil.LocalizeResFormat("101001")
    local tip = LocUtil.LocalizeResFormat("29746")
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tip, function()
      PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {mapKey}, PufferTlog.Enum_TLog_From.Click)
      local menuPath = logic_mode_selection:GetMenuPathStrByMapKey(mapKey)
      local url = "game://?module=1008403&menuList=210|200"
      if menuPath and menuPath ~= "" then
        url = "game://?module=1008403&menuList=" .. tostring(menuPath)
      end
      GlobalData.JumpUrl(url)
    end)
    return true
  end
  return false
end
function PufferMapManager:GetAllMapCurSize()
  local curSize = 0
  for _, v in pairs(self.MapPaks) do
    if v.curSize then
      curSize = curSize + v.curSize
    end
  end
  curSize = curSize / PufferConst.MB
  log(bWriteLog and string.format("PufferMapManager:GetAllMapCurSize :%s", curSize))
  return curSize
end
function PufferMapManager:HaveDeleted(mapKey)
  if not self.MapPaks[mapKey] then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local history = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
  if history and history[self.MapPaks[mapKey].filepre] then
    return true
  end
  return false
end
function PufferMapManager:ResetMapDataByPath(filePath, callback)
  for i, v in pairs(self.MapPaks) do
    if filePath == v.pakName then
      if callback then
        callback(i, v)
      end
      self:ResetMapData(i)
    end
  end
end
function PufferMapManager:ResetMapData(mapKey)
  if not (mapKey and self.MapPaks) or not self.MapPaks[mapKey] then
    return
  end
  local mapData = self.MapPaks[mapKey]
  mapData.state = PufferConst.ENUM_DownloadState.Not
  mapData.percent = 0
  mapData.curSize = 0
end
function PufferMapManager:GetMapDepends(mapkey)
  local map = self.MapPaks[mapkey]
  if not map then
    return {}
  end
  return map.depends or {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferMapManager = class(CModuleBase, nil, PufferMapManager)
return CPufferMapManager
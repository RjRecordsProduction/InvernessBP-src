local LogicPufferBundle = {
  bundles = {},
  needCheckSlap = false,
  UGCFeatureKeys = "UGC_FeatureKeys",
  PackResListCache = {},
  bFitLobbyResExist = false
}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local ENUM_DownloadType = PufferConst.ENUM_DownloadType
local ENUM_DownloadState = PufferConst.ENUM_DownloadState
local downloaderTableData
function LogicPufferBundle.GetDownloaderNewTable()
  if downloaderTableData ~= nil then
    return downloaderTableData
  end
  local result
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  if isFitVersion then
    result = CDataTable.GetTableByFilter("DownloaderNewTable", "IsFitVersion", true)
  elseif IsWoWEditor then
    result = CDataTable.GetTableByFilter("DownloaderNewTable", "IsWoWEditorBundle", true)
  else
    result = CDataTable.GetTableByFilter("DownloaderNewTable", "IsFitVersion", false)
  end
  log_tree("LogicPufferBundle.GetDownloaderNewTable. result = ", result)
  downloaderTableData = result
  return result
end
function LogicPufferBundle.InitBundle()
  log(bWriteLog and string.format("LogicPufferBundle.InitBundle"))
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local list = {}
  local StringUtil = require("common.string_util")
  local tableList = LogicPufferBundle.GetDownloaderNewTable()
  local   local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  for i, v in pairs(tableList) do
    local data = {}
    if v.BundleContent ~= "" then
      local skip = false
      local content = StringUtil.Split(v.BundleContent, "|")
      for _, vv in pairs(content) do
        skip = false
        local ODPackID = tonumber(vv)
        if ODPackID then
          if ODPackID == PufferConst.EODPackID.BuJiKaiXiang and not GlobalData.IsJapanOrKorea() then
            skip = true
          end
        elseif StringUtil.Ends(vv, ".mp4") or StringUtil.Starts(vv, PufferConst.PACK_SET_PREFIX) then
        else
          local downloadType = PufferManager.GetDownloadType(vv)
          printf("LogicPufferBundle.InitBundle. vv=%s, downloadType=%s", tostring(vv), tostring(downloadType))
          if downloadType == ENUM_DownloadType.MAP then
            if PufferMapManager:IsUGCMap(vv) then
            elseif vv == "map_maincity" and PublishRegionMacros.IsFITVersion() then
            elseif logic_mode_selection:GetViewDictionary() and not logic_mode_selection:CheckMapKeyNeedDownload(vv) then
              log(bWriteLog and string.format("LogicPufferBundle.skip:%s", vv))
              skip = true
            end
          elseif downloadType == ENUM_DownloadType.PREFETCH then
            if not PufferSwitch.GetPrefetchSwitch() then
              skip = true
            end
          elseif downloadType ~= ENUM_DownloadType.RES then
            log(bWriteLog and string.format("LogicPufferBundle.skip:%s", vv))
            skip = true
          end
        end
        if not skip then
          table.insert(data, vv)
        end
      end
    end
    if next(data) then
      list[v.BundleID] = data
    end
  end
  LogicPufferBundle.bundles = list
  if LogicPufferBundle.bundles[PufferConst.UGC_BUNDLE_ID] then
    local list = LogicPufferBundle.bundles[PufferConst.UGC_BUNDLE_ID]
    if IsWoWEditor then
      for i, v in ipairs(list) do
        if v == "map_creativeerangel" then
          table.remove(list, i)
          printf(bWriteLog and "LogicPufferBundle.skip:map_creativeerangel")
          break
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON)
end
function LogicPufferBundle.GetDownloadingPercent()
  local curSize = 0
  local totalSize = 0
  local percent = 1
  for i, v in pairs(LogicPufferBundle.GetDownloaderNewTable()) do
    local state = LogicPufferBundle.GetBundleState(v.BundleID)
    if state == ENUM_DownloadState.Download or state == ENUM_DownloadState.Wait then
      local cSize, tSize = LogicPufferBundle.GetBundleSize(v.BundleID)
      curSize = curSize + cSize
      totalSize = totalSize + tSize
    end
  end
  if totalSize ~= 0 then
    percent = curSize / totalSize
  end
  return percent
end
function LogicPufferBundle.GetBundleState(bundleID)
  if not next(LogicPufferBundle.bundles) then
    return ENUM_DownloadState.Not
  end
  local resultState = ENUM_DownloadState.Done
  if not LogicPufferBundle.bundles[bundleID] then
    return resultState
  end
  resultState = LogicPufferBundle.GetPackListState(LogicPufferBundle.bundles[bundleID])
  return resultState
end
function LogicPufferBundle.GetBundleSize(bundleID)
  local curSize = 0
  local totalSize = 0
  if not LogicPufferBundle.bundles[bundleID] then
    return curSize, totalSize
  end
  curSize, totalSize = LogicPufferBundle.GetPackListSize(LogicPufferBundle.bundles[bundleID])
  return curSize, totalSize
end
function LogicPufferBundle.DownloadBundle(bundleID, bSkipDownloadDeleteHistory)
  if not LogicPufferBundle.bundles[bundleID] then
    return
  end
  LogicPufferBundle.DownloadPackList(LogicPufferBundle.bundles[bundleID], bSkipDownloadDeleteHistory)
end
function LogicPufferBundle.GetMixPackDownloadContent(key)
  if LogicPufferBundle.PackResListCache[key] then
    return LogicPufferBundle.PackResListCache[key]
  end
  local StringUtil = require("common.string_util")
  local pakCfg = CDataTable.GetTableData("DownloaderPakCfg", key)
  local mixDownloadData = {}
  if pakCfg then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    local puffer_res_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    local stringArr = StringUtil.Split(pakCfg.PakContent, "|")
    for _, key in ipairs(stringArr) do
      local packId = tonumber(key)
      local subType = ENUM_DownloadType.ODPACK
      local subKey = packId or key
      if packId then
        local cfg = CDataTable.GetTableData("PakInfoTable", packId)
        if cfg and cfg.IsUGC == 1 then
          subType = ENUM_DownloadType.UGCPACK
        end
      else
        subType = PufferManager.GetDownloadType(key)
      end
      if not subType then
        if not PufferMapManager.bHaveInitMapPaks and StringUtil.Starts(key, "map_") then
          subType = ENUM_DownloadType.MAP
        end
        if not puffer_res_manager.bResPakInitCalled and StringUtil.Starts(key, "res_") then
          subType = ENUM_DownloadType.RES
        end
      end
      if subType then
        if not mixDownloadData[subType] then
          mixDownloadData[subType] = {}
        end
        table.insert(mixDownloadData[subType], subKey)
      end
    end
  end
  log_format("LogicPufferBundle.GetMixPackDownloadContent. key=%s", key)
  log_tree("LogicPufferBundle.GetMixPackDownloadContent. mixDownloadData = ", mixDownloadData)
  LogicPufferBundle.PackResListCache[key] = mixDownloadData
  return mixDownloadData
end
function LogicPufferBundle.ChooseDownloadByType(key, bSkipDownloadDeleteHistory, keyList)
  local StringUtil = require("common.string_util")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local history = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
  local extraData = {bSkipPopUp = true}
  local packID = tonumber(key)
  if packID and not keyList then
    local bSkip = false
    if bSkipDownloadDeleteHistory and history and history[packID] then
      log(bWriteLog and "LogicPufferBundle.DownloadBundle packID: " .. key .. " have deleted history")
      bSkip = true
    end
    if not bSkip then
      local pufferType = ENUM_DownloadType.ODPACK
      local cfg = CDataTable.GetTableData("PakInfoTable", packID)
      if cfg and cfg.IsUGC == 1 then
        pufferType = ENUM_DownloadType.UGCPACK
      end
      PufferManager.Download(pufferType, {packID}, nil, nil, extraData)
    end
  else
    if not keyList and StringUtil.Starts(key, PufferConst.MIX_PACK_SET_PREFIX) then
      keyList = LogicPufferBundle.GetMixPackDownloadContent(key)
    end
    if keyList then
      local downloadType = ENUM_DownloadType.ODPAK
      if StringUtil.Starts(key, PufferConst.PACK_SET_PREFIX) then
        if key == PufferConst.LOBBY_MAPKEY then
          downloadType = ENUM_DownloadType.RES
        elseif StringUtil.Starts(key, PufferConst.MAP_PACK_SET_PREFIX) then
          downloadType = ENUM_DownloadType.MAP
        elseif StringUtil.Starts(key, PufferConst.MIX_PACK_SET_PREFIX) then
          for subType, subKeys in pairs(keyList) do
            PufferManager.Download(subType, subKeys, PufferTlog.Enum_TLog_From.LobbyDownloader, nil, extraData)
          end
          return
        else
          local cfg = CDataTable.GetTableData("PakInfoTable", packID)
          if cfg and cfg.IsUGC == 1 then
            downloadType = ENUM_DownloadType.UGCPACK
          else
            downloadType = ENUM_DownloadType.ODPACK
          end
        end
      end
      PufferManager.Download(downloadType, keyList, PufferTlog.Enum_TLog_From.LobbyDownloader, nil, extraData)
      return
    end
    local dType = PufferManager.GetDownloadType(key)
    if dType == ENUM_DownloadType.MAP then
      local bSkip = false
      if bSkipDownloadDeleteHistory then
        local MapPakTableCfg = CDataTable.GetTableData("MapPakTable", key)
        if MapPakTableCfg and history and history[MapPakTableCfg.filepre] then
          log(bWriteLog and "LogicPufferBundle.DownloadBundle mapKey: " .. key .. " have deleted history")
          bSkip = true
        end
      end
      if not bSkip then
        PufferManager.Download(ENUM_DownloadType.MAP, {key}, PufferTlog.Enum_TLog_From.LobbyDownloader)
      end
    elseif dType == ENUM_DownloadType.RES then
      PufferManager.Download(ENUM_DownloadType.RES, {key}, PufferTlog.Enum_TLog_From.LobbyDownloader)
    elseif dType == ENUM_DownloadType.PREFETCH then
      PufferManager.Download(ENUM_DownloadType.PREFETCH, {key}, PufferTlog.Enum_TLog_From.LobbyDownloader)
      PufferManager.Download(ENUM_DownloadType.ODPACK, {
        PufferConst.EODPackID.PREFETCH_ODPACKID
      }, nil, nil, extraData)
    elseif type(key) == "string" and StringUtil.Ends(key, ".mp4") then
      local videoDownloadPath = DataMgr.GetVideoDownloadPath(key)
      PufferManager.Download(ENUM_DownloadType.ODPAK, {videoDownloadPath}, PufferTlog.Enum_TLog_From.LobbyDownloader)
    elseif key == LogicPufferBundle.UGCFeatureKeys then
      local KeyList = LogicPufferBundle.GetUGCFeatureKeyList()
      PufferManager.Download(ENUM_DownloadType.ODPAK, KeyList)
    end
  end
end
function LogicPufferBundle.ChooseStopDownloadByType(key, bNotStartDownload, keyList)
  local StringUtil = require("common.string_util")
  local packID = tonumber(key)
  if packID and not keyList then
    local pufferType = ENUM_DownloadType.ODPACK
    local cfg = CDataTable.GetTableData("PakInfoTable", packID)
    if cfg and cfg.IsUGC == 1 then
      pufferType = ENUM_DownloadType.UGCPACK
    end
    PufferManager.Pause(pufferType, {packID})
  else
    if not keyList and StringUtil.Starts(key, PufferConst.MIX_PACK_SET_PREFIX) then
      keyList = LogicPufferBundle.GetMixPackDownloadContent(key)
    end
    if keyList then
      local downloadType = ENUM_DownloadType.ODPAK
      if StringUtil.Starts(key, PufferConst.PACK_SET_PREFIX) then
        if key == PufferConst.LOBBY_MAPKEY then
          downloadType = ENUM_DownloadType.RES
        elseif StringUtil.Starts(key, PufferConst.MAP_PACK_SET_PREFIX) then
          downloadType = ENUM_DownloadType.MAP
        elseif StringUtil.Starts(key, PufferConst.MIX_PACK_SET_PREFIX) then
          for subType, subKeys in pairs(keyList) do
            PufferManager.Pause(subType, subKeys)
          end
          return
        else
          local cfg = CDataTable.GetTableData("PakInfoTable", packID)
          if cfg and cfg.IsUGC == 1 then
            downloadType = ENUM_DownloadType.UGCPACK
          else
            downloadType = ENUM_DownloadType.ODPACK
          end
        end
      end
      PufferManager.Pause(downloadType, keyList)
      return
    end
    local dType = PufferManager.GetDownloadType(key)
    if dType == ENUM_DownloadType.MAP then
      PufferManager.Pause(ENUM_DownloadType.MAP, {key}, false, bNotStartDownload)
    elseif dType == ENUM_DownloadType.RES then
      PufferManager.Pause(ENUM_DownloadType.RES, {key})
    elseif dType == ENUM_DownloadType.PREFETCH then
      PufferManager.Pause(ENUM_DownloadType.PREFETCH, {key})
      PufferManager.Pause(ENUM_DownloadType.ODPACK, {
        PufferConst.EODPackID.PREFETCH_ODPACKID
      })
    elseif type(key) == "string" and StringUtil.Ends(key, ".mp4") then
      local videoDownloadPath = DataMgr.GetVideoDownloadPath(key)
      PufferManager.Pause(ENUM_DownloadType.ODPAK, {videoDownloadPath})
    elseif key == LogicPufferBundle.UGCFeatureKeys then
      local KeyList = LogicPufferBundle.GetUGCFeatureKeyList()
      PufferManager.Pause(ENUM_DownloadType.ODPAK, KeyList)
    end
  end
end
function LogicPufferBundle.StopDownloadBundle(bundleID)
  log(bWriteLog and "LogicPufferBundle.StopDownloadBundle bundleID = " .. tostring(bundleID))
  local list = LogicPufferBundle.bundles[bundleID]
  if not list then
    return
  end
  LogicPufferBundle.StopDownloadPacks(list)
end
function LogicPufferBundle.StopDownloadPacks(list)
  LogicPufferBundle.StopDownloadPackList(list)
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:StartDownload()
end
function LogicPufferBundle.GetPackListState(packList, bSkipDepends)
  if not packList then
    return ENUM_DownloadState.Done
  end
  if bSkipDepends == nil then
    bSkipDepends = true
  end
  local StringUtil = require("common.string_util")
  local resultState = ENUM_DownloadState.Done
  for _, vv in pairs(packList) do
    local state = ENUM_DownloadState.Done
    if tonumber(vv) then
      local pufferType = ENUM_DownloadType.ODPACK
      local packID = tonumber(vv)
      local cfg = CDataTable.GetTableData("PakInfoTable", packID)
      if cfg and cfg.IsUGC == 1 then
        pufferType = ENUM_DownloadType.UGCPACK
      end
      state = PufferManager.GetState(pufferType, {packID}, bSkipDepends)
    elseif PufferManager.GetDownloadType(vv) == ENUM_DownloadType.MAP then
      state = PufferManager.GetState(ENUM_DownloadType.MAP, {vv}, bSkipDepends)
    elseif PufferManager.GetDownloadType(vv) == ENUM_DownloadType.RES then
      state = PufferManager.GetState(ENUM_DownloadType.RES, {vv})
    elseif PufferManager.GetDownloadType(vv) == ENUM_DownloadType.PREFETCH then
      state = PufferManager.GetState(ENUM_DownloadType.PREFETCH, {vv})
    elseif StringUtil.Ends(vv, ".mp4") then
      local videoDownloadPath = DataMgr.GetVideoDownloadPath(vv)
      state = PufferManager.GetState(ENUM_DownloadType.ODPAK, {videoDownloadPath})
    elseif vv == LogicPufferBundle.UGCFeatureKeys then
      local KeyList = LogicPufferBundle.GetUGCFeatureKeyList()
      state = PufferManager.GetState(ENUM_DownloadType.ODPAK, KeyList)
    elseif StringUtil.Starts(vv, PufferConst.PACK_SET_PREFIX) then
      if StringUtil.Starts(vv, PufferConst.MIX_PACK_SET_PREFIX) then
        local mixDownloadData = LogicPufferBundle.GetMixPackDownloadContent(vv)
        for subType, subKeys in pairs(mixDownloadData) do
          local subState = PufferManager.GetState(subType, subKeys, bSkipDepends)
          state = PufferManager.GetMixDownloadState(state, subState)
        end
      else
        local DownloadType, KeyList = LogicPufferBundle.GetPackDownloadTypeAndResList(vv)
        state = PufferManager.GetState(DownloadType, KeyList)
      end
    end
    resultState = PufferManager.GetMixDownloadState(resultState, state)
  end
  return resultState
end
local SizeConvertTypes = {
  [ENUM_DownloadType.ODPACK] = true,
  [ENUM_DownloadType.UGCPACK] = true
}
function LogicPufferBundle.GetPackListSize(packList, ifGetODPackSizeList)
  local curSize = 0
  local totalSize = 0
  local odPackSizeList = ifGetODPackSizeList and {} or nil
  local StringUtil = require("common.string_util")
  for _, vv in pairs(packList) do
    local packID = tonumber(vv)
    local cSize = 0
    local tSize = 0
    if packID then
      local pufferType = ENUM_DownloadType.ODPACK
      local cfg = CDataTable.GetTableData("PakInfoTable", packID)
      if cfg and cfg.IsUGC == 1 then
        pufferType = ENUM_DownloadType.UGCPACK
      end
      cSize, tSize = PufferManager.GetSize(pufferType, {packID}, true)
      if odPackSizeList then
        odPackSizeList[packID] = {cSize = cSize, tSize = tSize}
      end
      curSize = curSize + cSize
      totalSize = totalSize + tSize
    else
      local bNeedConvert = true
      local type = PufferManager.GetDownloadType(vv)
      if type == ENUM_DownloadType.MAP then
        local skip = false
        if not skip then
          cSize, tSize = PufferManager.GetSize(ENUM_DownloadType.MAP, {vv}, true)
        end
      elseif type == ENUM_DownloadType.RES then
        cSize, tSize = PufferManager.GetSize(ENUM_DownloadType.RES, {vv})
      elseif type == ENUM_DownloadType.PREFETCH then
        cSize, tSize = PufferManager.GetSize(ENUM_DownloadType.PREFETCH, {vv})
      elseif StringUtil.Ends(vv, ".mp4") then
        local videoDownloadPath = DataMgr.GetVideoDownloadPath(vv)
        cSize, tSize = PufferManager.GetSize(ENUM_DownloadType.ODPAK, {videoDownloadPath})
      elseif vv == LogicPufferBundle.UGCFeatureKeys then
        local KeyList = LogicPufferBundle.GetUGCFeatureKeyList()
        cSize, tSize = PufferManager.GetSize(ENUM_DownloadType.ODPAK, KeyList)
      elseif StringUtil.Starts(vv, PufferConst.PACK_SET_PREFIX) then
        if StringUtil.Starts(vv, PufferConst.MIX_PACK_SET_PREFIX) then
          local mixDownloadData = LogicPufferBundle.GetMixPackDownloadContent(vv)
          local subCSize = 0
          local subTSize = 0
          for subType, subKeys in pairs(mixDownloadData) do
            subCSize, subTSize = PufferManager.GetSize(subType, subKeys)
            if not SizeConvertTypes[subType] then
              subCSize = subCSize / PufferConst.MB
              subTSize = subTSize / PufferConst.MB
            end
            cSize = cSize + subCSize
            tSize = tSize + subTSize
          end
          bNeedConvert = false
        else
          local DownloadType, KeyList = LogicPufferBundle.GetPackDownloadTypeAndResList(vv)
          cSize, tSize = PufferManager.GetSize(DownloadType, KeyList)
        end
      end
      if bNeedConvert then
        cSize = cSize / PufferConst.MB
        tSize = tSize / PufferConst.MB
      end
      curSize = curSize + cSize
      totalSize = totalSize + tSize
    end
  end
  return curSize, totalSize, odPackSizeList
end
function LogicPufferBundle.DownloadPackList(packList, bSkipDownloadDeleteHistory)
  for _, vv in pairs(packList) do
    LogicPufferBundle.ChooseDownloadByType(vv, bSkipDownloadDeleteHistory)
  end
end
function LogicPufferBundle.StopDownloadPackList(packList)
  for _, vv in pairs(packList) do
    LogicPufferBundle.ChooseStopDownloadByType(vv, true)
  end
end
function LogicPufferBundle.GetPackDownloadTypeAndResList(Pack)
  local StringUtil = require("common.string_util")
  local DownloadType, KeyList
  if Pack == PufferConst.LOBBY_MAPKEY then
    DownloadType = ENUM_DownloadType.RES
    local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    KeyList = PufferResManager.LobbyResKeyList
  elseif StringUtil.Starts(Pack, PufferConst.MAP_PACK_SET_PREFIX) then
    DownloadType = ENUM_DownloadType.MAP
    if not LogicPufferBundle.PackResListCache[Pack] then
      local pakCfg = CDataTable.GetTableData("DownloaderPakCfg", Pack)
      if pakCfg then
        local stringArr = StringUtil.Split(pakCfg.PakContent, "|")
        local keyList = {}
        for i, v in ipairs(stringArr) do
          if StringUtil.Starts(v, PufferConst.MAP_PREFIX) then
            table.insert(keyList, v)
          end
        end
        LogicPufferBundle.PackResListCache[Pack] = keyList
      else
        LogicPufferBundle.PackResListCache[Pack] = {}
      end
    end
    KeyList = LogicPufferBundle.PackResListCache[Pack]
  else
    DownloadType = ENUM_DownloadType.ODPACK
    KeyList = {Pack}
  end
  return DownloadType, KeyList
end
function LogicPufferBundle.CheckRecommendReddot()
  if PufferDownloader.RecommendReddot then
    return true
  end
  local bundleID = PufferConst.RecommendBundleIDs[PufferSwitch.AutoDownloadCfg.RecommendType]
  log(bWriteLog and "LogicPufferBundle.CheckRecommendReddot. bundleID = " .. tostring(bundleID))
  if bundleID and LogicPufferBundle.GetBundleState(bundleID) == ENUM_DownloadState.Done then
    log(bWriteLog and "LogicPufferBundle.CheckRecommendReddot. return true")
    PufferDownloader.RecommendReddot = true
    return true
  end
  return false
end
function LogicPufferBundle.CanShowFitRecommendPopup()
  if not LogicPufferBundle.needCheckSlap then
    printf("LogicPufferBundle.CanShowFitRecommendPopup. no need check")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. is not fitversion")
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. puffer invalid")
    return false
  end
  if not next(LogicPufferBundle.bundles) then
    printf("LogicPufferBundle.CanShowFitRecommendPopup. bundles is empty")
    return false
  end
  LogicPufferBundle.needCheckSlap = false
  local bundleID = PufferConst.Enum_BundleID.FIT
  if not LogicPufferBundle.bundles[bundleID] then
    printf("LogicPufferBundle.CanShowFitRecommendPopup. bunle data is empty")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eDownloadFitVersionInfo
  local data = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  local showFitPopupDay = data.showFitPopupDay
  printf("LogicPufferBundle.CanShowFitRecommendPopup. data.showFitPopupDay=%s", tostring(data.showFitPopupDay))
  local TimeUtil = require("client.common.time_util")
  local dayNum = TimeUtil.GetServerTimeInSec() // 86400
  log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. dayNum = " .. tostring(dayNum))
  if showFitPopupDay == dayNum then
    log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. same day")
    return false
  end
  log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. save")
  data.showFitPopupDay = dayNum
  PlayerPrefsSystem.SaveTableToFile_N(data, fileType)
  local state = LogicPufferBundle.GetBundleState(bundleID)
  log(bWriteLog and "LogicPufferBundle.CanShowFitRecommendPopup. state = " .. tostring(state))
  return state ~= ENUM_DownloadState.Done
end
function LogicPufferBundle.ShowFitRecommendDownloadPopup()
  log(bWriteLog and "LogicPufferBundle.ShowFitRecommendDownloadPopup.")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Download_Recommend_Popup_UIBP)
end
function LogicPufferBundle.GetUGCFeatureKeyList()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  return PufferUGCPakManager.AllFeatureIDList
end
function LogicPufferBundle.IsFitLobbyResDownloaded()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    return true
  end
  if LogicPufferBundle.bFitLobbyResExist then
    return true
  end
  local key = PufferConst.FIT_LOBBY_RES_KEY
  local downloadData = LogicPufferBundle.GetMixPackDownloadContent(key)
  if downloadData[ENUM_DownloadType.MAP] then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    if not PufferMapManager.bHaveInitMapPaks then
      log_format("LogicPufferBundle.IsFitLobbyResDownloaded. not have init map paks")
      return false
    end
  elseif downloadData[ENUM_DownloadType.RES] then
    local puffer_res_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    if not puffer_res_manager.bResPakInitCalled then
      log_format("LogicPufferBundle.IsFitLobbyResDownloaded. not have init res paks")
      return false
    end
  end
  local state = LogicPufferBundle.GetPackListState({key})
  log(bWriteLog and "LogicPufferBundle.IsFitLobbyResDownloaded state: " .. tostring(state))
  LogicPufferBundle.bFitLobbyResExist = state == ENUM_DownloadState.Done
  return LogicPufferBundle.bFitLobbyResExist
end
function LogicPufferBundle.ShowFitLobbyResDownloadPopup()
  log(bWriteLog and "LogicPufferBundle.ShowFitLobbyResDownloadPopup")
  local key = PufferConst.FIT_LOBBY_RES_KEY
  local mixDownloadData = LogicPufferBundle.GetMixPackDownloadContent(key)
  local tDownloadResList = {}
  for _, subKeys in pairs(mixDownloadData) do
    for _, v in pairs(subKeys) do
      table.insert(tDownloadResList, v)
    end
  end
  local tShowData = {
    tDownloadResList = tDownloadResList,
    nDownloadType = nil,
    sDownloadTip = LocUtil.GetLocalizeResStr(78234),
    fCheckDownloadFinish = LogicPufferBundle.IsFitLobbyResDownloaded
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_DownloadPopup_UIBP, tShowData)
end
function LogicPufferBundle.OnFitLobbyResDownloadFinish()
  log(bWriteLog and "LogicPufferBundle.OnFitLobbyResDownloadFinish")
  UIManager.CloseUI(UIManager.UI_Config.Common_DownloadPopup_UIBP)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:OnRestartGame()
  LogicPufferBundle.bFitLobbyResExist = true
end
return LogicPufferBundle
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
local PufferConst = require("client.slua.logic.download.puffer_const")
local ITEM_WHITELIST_CHECK_NUM_PER_STEP = 20
local DownloadDelSystem = {
  curDelList = {},
  bIsLobby = false,
  loginFlag = nil,
  lobbyAutoConfig = nil,
  bIsAuto = false,
  bRecommendAutoDeleLobby = false,
  saveHasMountODPakSize = {},
  curDelListCache = {},
  curMainListCache = {},
  updateItemWhitelistTimer = nil,
  itemWhitelist = {},
  odpakNum = 0
}
local _IsRecentUseRessource = function(fileName)
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local pakMountTimes = PufferDeleteManager.GetPakMountTime()
  if not pakMountTimes or not pakMountTimes[fileName] then
    return false
  end
  if (nowTime - pakMountTimes[fileName]) / 2592000 > 1 then
    return true
  end
  return false
end
function DownloadDelSystem.AsyCheckResource(callback)
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local pakMountTimes = PufferDeleteManager.GetPakMountTime()
  if not pakMountTimes or not next(pakMountTimes) then
    return
  end
  local temp = {}
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local odPakData = PufferODPakManager.ODPaks[10002] and PufferODPakManager.ODPaks[10002].paks or {}
  for k, v in pairs(odPakData) do
    if not temp[k] and v.state == PufferConst.ENUM_DownloadState.Done and not DownloadDelSystem.saveHasMountODPakSize[k] then
      temp[k] = v.tSize
    end
  end
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  local finalSubData = {}
  local useContent = {
    file = {},
    downloadName = LocUtil.GetLocalizeResStr(33617),
    bSelect = false,
    subCurSize = 0,
    style = Logic_Lobby_DownLoad.E_DownLoadType.SubStyleOne
  }
  local useLessContent = {
    file = {},
    downloadName = LocUtil.GetLocalizeResStr(33618),
    bSelect = true,
    subCurSize = 0,
    bAutoChoose = true,
    style = Logic_Lobby_DownLoad.E_DownLoadType.SubStyleOne
  }
  local time_ticker = require("common.time_ticker")
  if not DownloadDelSystem.TimerDeletePak then
    DownloadDelSystem.TimerDeletePak = time_ticker.AddTimerLoop(0, function()
      if next(temp) then
        local cnt = 0
        while cnt < 300 do
          local ii, vv = next(temp)
          if ii and vv then
            if _IsRecentUseRessource(ii) then
              table.insert(useLessContent.file, ii)
              useLessContent.subCurSize = vv + useLessContent.subCurSize
              DownloadDelSystem.bIsAuto = true
            else
              table.insert(useContent.file, ii)
              useContent.subCurSize = vv + useContent.subCurSize
            end
          else
            break
          end
          temp[ii] = nil
          cnt = cnt + 1
        end
      else
        if useContent.subCurSize ~= 0 then
          if DownloadDelSystem.lobbyAutoConfig and DownloadDelSystem.lobbyAutoConfig.bDeleAll then
            useContent.bSelect = true
            useContent.bAutoChoose = true
            DownloadDelSystem.bIsAuto = true
          end
          table.insert(finalSubData, useContent)
        end
        if useLessContent.subCurSize ~= 0 then
          table.insert(finalSubData, useLessContent)
        end
        if callback then
          callback(finalSubData)
        end
        time_ticker.RemoveTimer(DownloadDelSystem.TimerDeletePak)
        DownloadDelSystem.TimerDeletePak = nil
      end
    end, TIMER_INFINITE, 0.1)
  end
end
local _SortSubData = function(subData)
  if subData and next(subData) then
    table.sort(subData, function(a, b)
      if a.state and b.state and a.state ~= b.state then
        return a.state < b.state
      elseif a.timeRecord and b.timeRecord and a.timeRecord ~= b.timeRecord then
        return a.timeRecord < b.timeRecord
      else
        return a.subCurSize > b.subCurSize
      end
    end)
  end
  return subData
end
function DownloadDelSystem.GetMainSwitchData(itemWhitelist, targetSize)
  local Logic_Lobby_Download = require("client.slua.logic.download.logic_lobby_downloader")
  local tList = Logic_Lobby_Download.GetLobbyDownloadInfo(nil, nil, itemWhitelist)
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local cacheSize = PufferDeleteManager.GetSavedCacheSize()
  local bShowCacheDelete = PufferDeleteManager.NeedShowCacheDelete()
  local bRecommendDelete = 0 <= targetSize
  if bShowCacheDelete or bRecommendDelete then
    local totalDelSize = 0
    local data = {}
    data.key = PufferDeleteManager.RECOMMEND_RES_KEY
    data.bundleName = LocUtil.GetLocalizeResStr(33697)
    data.bundleID = 99999999999
    data.bSelect = true
    data.bAutoChoose = true
    DownloadDelSystem.bIsAuto = true
    data.style = Logic_Lobby_Download.E_DownLoadType.MainItem
    data.bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Recommend_png.DL_Icon_Recommend_png"
    data.subData = {
      [1] = {
        downloadType = PufferDeleteManager.SAVED_CACHE_KEY,
        downloadName = LocUtil.GetLocalizeResStr(33697),
        bSelect = true,
        subCurSize = cacheSize / PufferConst.MB,
        sDesc = LocUtil.GetLocalizeResStr(33698),
        bAutoChoose = true,
        style = Logic_Lobby_Download.E_DownLoadType.SubStyleOne
      }
    }
    totalDelSize = totalDelSize + cacheSize / PufferConst.MB
    log(bWriteLog and "totalDelSize before HandleRecommendDeleteData " .. tostring(totalDelSize))
    if bRecommendDelete then
      totalDelSize = DownloadDelSystem.HandleRecommendDeleteData(tList, data, targetSize, totalDelSize)
    end
    data.curSize = totalDelSize
    table.insert(tList, data)
  end
  local appData = {}
  appData.bundleID = 1
  appData.bundleName = LocUtil.GetLocalizeResStr(39194)
  appData.bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Core_png.DL_Icon_Core_png"
  appData.hideCheck = true
  appData.mainTitle = LocUtil.GetLocalizeResStr(39197)
  appData.style = Logic_Lobby_Download.E_DownLoadType.MainItem
  local appSize = PufferDeleteManager.GetAppsize()
  local otherPaksSize = PufferDeleteManager.GetOtherPaksSize()
  appData.curSize = appSize + otherPaksSize
  table.insert(tList, appData)
  table.sort(tList, function(a, b)
    return a.bundleID > b.bundleID
  end)
  for i = #tList, 1, -1 do
    local data = tList[i]
    if data.bundleID and DownloadDelSystem.curMainListCache[data.bundleID] and 0 < DownloadDelSystem.curMainListCache[data.bundleID].size then
      data.curSize = data.curSize - DownloadDelSystem.curMainListCache[data.bundleID].size
    end
    if 0 >= data.curSize then
      table.remove(tList, i)
    elseif data.subData then
      for ii = #data.subData, 1, -1 do
        local curKey = data.subData[ii].key
        if curKey and DownloadDelSystem.curDelListCache[tonumber(curKey)] and 0 < DownloadDelSystem.curDelListCache[tonumber(curKey)].size then
          data.subData[ii].subCurSize = data.subData[ii].subCurSize - DownloadDelSystem.curDelListCache[tonumber(curKey)].size
        end
        if 0 >= data.subData[ii].subCurSize then
          table.remove(data.subData, ii)
        end
      end
    end
  end
  local bNeedAsy = false
  for i, v in ipairs(tList) do
    if tList.subData then
      tList.subData = _SortSubData(tList.subData)
    end
    v.tabClickIndex = i
    if v.bundleID and v.bundleID == 100006 then
      bNeedAsy = true
    end
  end
  DownloadDelSystem.curDelList = tList
  if tList[1] and tList[1].bundleID and tList[1].bundleID ~= 1 then
    tList[1].mainTitle = LocUtil.GetLocalizeResStr(39196)
    tList[1].style = Logic_Lobby_Download.E_DownLoadType.MainItem
  end
  return tList, bNeedAsy
end
function DownloadDelSystem.GetDeleteList(allList)
  local tDelData = {}
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  for i, v in ipairs(allList) do
    if v.style == Logic_Lobby_DownLoad.E_DownLoadType.MainItem then
      if v.bundleID == PufferConst.PREFETCH_BUNDLE_ID and v.bSelect then
        local data = {
          downloadType = PufferConst.ENUM_DownloadType.PREFETCH,
          key = "PREFETCH"
        }
        table.insert(tDelData, data)
      end
      if v.subData then
        for ii, vv in ipairs(v.subData) do
          if vv.bSelect then
            if vv.file then
              for iii, vvvv in ipairs(vv.file) do
                table.insert(tDelData, vvvv)
              end
            else
              table.insert(tDelData, vv)
            end
          end
        end
      elseif v.bSelect and v.file then
        for ii, vv in ipairs(v.file) do
          table.insert(tDelData, vv)
        end
      end
    end
  end
  return tDelData
end
function DownloadDelSystem.HandleDeleteFunc(tDelList, itemWhitelist, showNotice, blockInput, finishCallback)
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local bLogin = GameStatus.GetGameStatus() == GameStatus.Login
  local deletePaks = {}
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local wowBundleId = PufferConst.UGC_BUNDLE_ID
  local checkList = {}
  for k, v in pairs(tDelList) do
    if v.key == wowBundleId then
      LogicUGCResManager:SendTLogUGCResCenterOperate(LogicUGCResManager.TLogKey.SureDeleteWoWRes)
    end
    if v.downloadType == PufferDeleteManager.SAVED_CACHE_KEY then
      deletePaks[v.downloadType] = PufferDeleteManager.SAVED_CACHE_KEY
    elseif bLogin then
      if v.content then
        deletePaks[v.content] = PufferDeleteManager.LOGIN_DELETE_KEY
      else
        deletePaks[v] = PufferDeleteManager.LOGIN_DELETE_KEY
      end
    elseif v.downloadType == PufferConst.ENUM_DownloadType.ODPACK then
      local packID = tonumber(v.key)
      if PufferODPakManager.ODPaks[packID] then
        if not checkList[packID] then
          checkList[packID] = {}
        end
        local whiteListData
        if itemWhitelist and itemWhitelist[packID] then
          whiteListData = itemWhitelist[packID]
        end
        for ii, vv in pairs(PufferODPakManager.ODPaks[packID].paks) do
          if vv.state == PufferConst.ENUM_DownloadState.Done and (not whiteListData or not whiteListData.paks[ii]) then
            deletePaks[ii] = PufferConst.ENUM_DownloadType.ODPAK
            table.insert(checkList[packID], ii)
          end
        end
      end
      local history = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
      history = history or {}
      history[packID] = true
      PlayerPrefsSystem.SaveTableToFile_N(history, PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
    elseif v.downloadType == PufferConst.ENUM_DownloadType.UGCPACK then
      local packID = tonumber(v.key)
      if PufferUGCPakManager.paks[packID] then
        if not checkList[packID] then
          checkList[packID] = {}
        end
        for ii, vv in pairs(PufferUGCPakManager.paks[packID].paks) do
          if vv.state == PufferConst.ENUM_DownloadState.Done then
            deletePaks[ii] = PufferConst.ENUM_DownloadType.UGCPAK
            table.insert(checkList[packID], ii)
          end
        end
      end
    elseif v.downloadType == PufferConst.ENUM_DownloadType.MAP and v.key then
      local skip = false
      if PufferMapManager:IsDefaultMapKey(v.key) then
        skip = true
      end
      if not skip then
        deletePaks[v.key] = PufferConst.ENUM_DownloadType.MAP
      end
    elseif v.downloadType == PufferConst.ENUM_DownloadType.RES then
      deletePaks[v.key] = PufferConst.ENUM_DownloadType.RES
    elseif v.downloadType == PufferConst.ENUM_DownloadType.PREFETCH then
      deletePaks[v.key] = PufferConst.ENUM_DownloadType.PREFETCH
      if PufferODPakManager.ODPaks[PufferConst.EODPackID.PREFETCH_ODPACKID] then
        if not checkList[PufferConst.EODPackID.PREFETCH_ODPACKID] then
          checkList[PufferConst.EODPackID.PREFETCH_ODPACKID] = {}
        end
        for ii, vv in pairs(PufferODPakManager.ODPaks[PufferConst.EODPackID.PREFETCH_ODPACKID].paks) do
          if vv.state == PufferConst.ENUM_DownloadState.Done then
            deletePaks[ii] = PufferConst.ENUM_DownloadType.ODPAK
            table.insert(checkList[PufferConst.EODPackID.PREFETCH_ODPACKID], ii)
          end
        end
      end
    elseif tostring(v) and string.find(v, "ODPaks") then
      deletePaks[v] = PufferConst.ENUM_DownloadType.ODPAK
      if not checkList[10002] then
        checkList[10002] = {}
      end
      table.insert(checkList[10002], v)
    end
  end
  if not next(deletePaks) then
    if showNotice then
      ShowNotice(33625)
    end
    return
  end
  PufferDeleteManager.AsynDeletePaks(deletePaks, finishCallback, blockInput, checkList)
end
function DownloadDelSystem.HandleRecommendDeleteData(tList, data, targetSize, totalDelSize)
  local needDelSize = targetSize
  if needDelSize <= 0 then
    return totalDelSize
  end
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local deleteCfg = PufferSwitch.SmartDownloadCfg.DeleteCfg
  local handleResItems = {}
  local Logic_Lobby_Download = require("client.slua.logic.download.logic_lobby_downloader")
  local deleteOrderMap = {}
  if deleteCfg and deleteCfg.orderList then
    local maxValue = 2000000
    for i, v in ipairs(deleteCfg.orderList) do
      deleteOrderMap[v] = maxValue - i
    end
  end
  for _, topItem in pairs(tList) do
    if topItem.subData then
      for _, subItem in pairs(topItem.subData) do
        local key = subItem.key
        local deleteOrder = 0
        if deleteOrderMap[key] then
          deleteOrder = deleteOrderMap[key]
        else
          deleteOrder = Logic_Lobby_Download.GetItemDeleteOrder(key, subItem.downloadType)
        end
        subItem.        table.insert(handleResItems, subItem)
      end
    end
  end
  local orderFunc = function(a, b)
    return a.deleteOrder < b.deleteOrder
  end
  if 0 < targetSize then
    table.sort(handleResItems, orderFunc)
  end
  for _, v in ipairs(handleResItems) do
    if totalDelSize >= needDelSize then
      break
    end
    local key = tonumber(v.key)
    local size = v.subCurSize
    if key and DownloadDelSystem.curDelListCache and DownloadDelSystem.curDelListCache[key] then
      size = size - DownloadDelSystem.curDelListCache[key].size
    end
    if 0.1 < size then
      v.bSelect = true
      v.bAutoChoose = true
      table.insert(data.subData, v)
      totalDelSize = totalDelSize + v.subCurSize
      log(bWriteLog and string.format("[teddy]Add to recommend. v.key %s, v.size %s", v.key, v.subCurSize))
      v.needDelSubItem = true
    end
  end
  for i = #tList, 1, -1 do
    local topItem = tList[i]
    if topItem and topItem.subData then
      for ii = #topItem.subData, 1, -1 do
        local subItem = topItem.subData[ii]
        if subItem and subItem.needDelSubItem then
          topItem.curSize = topItem.curSize - subItem.subCurSize
          table.remove(topItem.subData, ii)
        end
      end
      if 0 >= topItem.curSize then
        table.remove(tList, i)
      end
    end
  end
  return totalDelSize
end
function DownloadDelSystem.GetRemakeMainDeleData(tDownLoadList, nClickIndex, needShowNew)
  local Logic_Lobby_Download = require("client.slua.logic.download.logic_lobby_downloader")
  for i = #tDownLoadList, 1, -1 do
    if tDownLoadList[i].style ~= Logic_Lobby_Download.E_DownLoadType.MainItem then
      table.remove(tDownLoadList, i)
    end
  end
  if needShowNew and nClickIndex and tDownLoadList[nClickIndex] and tDownLoadList[nClickIndex].subData then
    local index = nClickIndex + 1
    for i, v in ipairs(tDownLoadList[nClickIndex].subData) do
      table.insert(tDownLoadList, index, v)
      index = index + 1
    end
    return tDownLoadList
  end
  return tDownLoadList
end
local SetDelSubData = function(sub_size, sub_name, sub_content)
  if sub_size <= 0 then
    return false
  end
  local subData = {}
  subData.subCurSize = sub_size / PufferConst.MB
  subData.downloadName = sub_name
  subData.bSelect = false
  subData.bAutoChoose = false
  subData.content = sub_content
  return true, subData
end
function DownloadDelSystem.SendTlogEvent(TlogEvent)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local recordData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAutoShowDelete) or {}
  if TlogEvent then
    local space = Client.GetDeviceFreeSpace()
    local data = {event = TlogEvent, space = space}
    table.insert(recordData, data)
    PlayerPrefsSystem.SaveTableToFile_N(recordData, PlayerPrefsSystem.ePlayerPrefsType.eAutoShowDelete)
  end
  local nUid = DataMgr.roleData.uid
  if nUid and nUid ~= "" and nUid ~= 0 and next(recordData) then
    for i, v in ipairs(recordData) do
      log(bWriteLog and "v_VYZHANG\228\186\139\228\187\182" .. tostring(TlogEvent))
      tlog_report_utils.ReportTLogEvent(v.event, tonumber(nUid), v.space, true)
    end
    PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eAutoShowDelete)
  end
end
local IsNotRecentUsePak = function(fileContent)
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local pakMountTimes = PufferDeleteManager.GetPakMountTime()
  if next(pakMountTimes) then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    if pakMountTimes[fileContent] then
      local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. fileContent
      local cSize = Client.GetFileSizeOnDiskBytes(filePathPak) / PufferConst.MB
      if (nowTime - pakMountTimes[fileContent]) / 2592000 > 1 and 0 < cSize then
        return true, cSize
      end
    end
  end
  return false
end
function DownloadDelSystem.GetLocalFileODPack()
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE .. PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE, "")
  local data = {}
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  for k, v in pairs(ret) do
    local bNotRecent, cSize = IsNotRecentUsePak(v)
    if bNotRecent then
      if not data.notRecent then
        data.notRecent = {}
        data.notRecent.curSize = 0
        data.notRecent.file = {}
        data.notRecent.bSelect = true
        data.notRecent.bundleName = LocUtil.GetLocalizeResStr(33618)
        data.notRecent.sDesc = LocUtil.LocalizeResFormat(33203, 1)
        data.notRecent.sort = 999999
        data.notRecent.bAutoChoose = true
        data.notRecent.style = Logic_Lobby_DownLoad.E_DownLoadType.MainItem
        data.notRecent.bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Resource_png.DL_Icon_Resource_png"
      end
      data.notRecent.curSize = data.notRecent.curSize + cSize
      table.insert(data.notRecent.file, "ODPaks/" .. v)
      DownloadDelSystem.bIsAuto = true
    else
      local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. "ODPaks/" .. v
      cSize = Client.GetFileSizeOnDiskBytes(filePathPak) / PufferConst.MB
      if 0 < cSize then
        if not data.Recent then
          data.Recent = {}
          data.Recent.curSize = 0
          data.Recent.file = {}
          data.Recent.bSelect = false
          data.Recent.bundleName = LocUtil.GetLocalizeResStr(33617)
          data.Recent.style = Logic_Lobby_DownLoad.E_DownLoadType.MainItem
          data.Recent.bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Resource_png.DL_Icon_Resource_png"
        end
        data.Recent.curSize = data.Recent.curSize + cSize
        data.Recent.sort = 999998
        table.insert(data.Recent.file, "ODPaks/" .. v)
      end
    end
  end
  local finlData = {}
  for i, v in pairs(data) do
    table.insert(finlData, v)
  end
  return finlData
end
local GetMapResKeyByStr = function(str, sType)
  local pos = string.find(str, "_")
  str = string.sub(str, pos + 1)
  pos = string.find(str, "_")
  local name = string.sub(str, 1, pos - 1)
  local key = sType .. name
  return key
end
function DownloadDelSystem.IsIncludeBasePak(name)
  local needDownLoadFileList = PufferInterface.ReturnSplitMiniPakFilelist() or {}
  for i, v in pairs(needDownLoadFileList) do
    if string.find(v, name) then
      return true
    end
  end
  return false
end
function DownloadDelSystem.GetLocalFilePaks()
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  local TimeUtil = require("client.common.time_util")
  local nowtime = TimeUtil.GetServerTimeInSec()
  local data = {}
  local nTimeLimit = DownloadDelSystem.lobbyAutoConfig and DownloadDelSystem.lobbyAutoConfig.nTimeLimit or 2592000
  local StringUtil = require("common.string_util")
  for k, v in pairs(ret) do
    if StringUtil.Starts(v, PufferConst.MAP_PREFIX) and not StringUtil.Starts(v, "map_planag") and not StringUtil.Starts(v, "map_notbasic") then
      local key = GetMapResKeyByStr(v, PufferConst.MAP_PREFIX)
      local cfg = CDataTable.GetTableData("MapPakTable", key)
      if cfg and not DownloadDelSystem.IsIncludeBasePak(key) then
        local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. v
        local cSize = Client.GetFileSizeOnDiskBytes(filePathPak)
        local bAdd, subdata = SetDelSubData(cSize, cfg.name, v)
        if bAdd then
          subdata.          local recordData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDownload) or {}
          subdata.timeRecord = recordData.lastPlayMap and recordData.lastPlayMap[subdata.key] or nowtime
          if (nowtime - tonumber(subdata.timeRecord)) / nTimeLimit >= 1 then
            subdata.bSelect = true
            subdata.bAutoChoose = true
            DownloadDelSystem.bIsAuto = true
          end
          table.insert(data, subdata)
        end
      end
    elseif string.find(v, "res_") then
      local key = GetMapResKeyByStr(v, "res_")
      local cfg = CDataTable.GetTableData("ResPakTable", key)
      if cfg and cfg.Key ~= PufferConst.PUFFERPATCH and not DownloadDelSystem.IsIncludeBasePak(key) then
        local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. v
        local cSize = Client.GetFileSizeOnDiskBytes(filePathPak)
        local bAdd, subdata = SetDelSubData(cSize, cfg.ResName, v)
        if bAdd then
          table.insert(data, subdata)
        end
      end
    end
  end
  return data
end
local Enum_BundleID = PufferConst.Enum_BundleID
local _isMapHasClass = function(key)
  for k, v in pairs(CDataTable.GetTableByFilter("DownloaderNewTable", "IsWoWEditorBundle", false)) do
    if string.find(v.BundleContent, key) and v.BundleID ~= Enum_BundleID.Recommend and v.BundleID ~= Enum_BundleID.HighQuality then
      return v.BundleName, v.BundleID
    end
  end
  return ""
end
function DownloadDelSystem.GetRecommonedDelData()
  local pakData = DownloadDelSystem.GetLocalFilePaks()
  local odPackDAta = DownloadDelSystem.GetLocalFileODPack()
  local resData = {}
  resData.curSize = 0
  resData.bundleName = LocUtil.GetLocalizeResStr(27672)
  resData.subData = {}
  local mapData = {}
  local bHasRes = false
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  for i, v in ipairs(pakData) do
    local str = ""
    local id = 0
    if v.key then
      str, id = _isMapHasClass(v.key)
    end
    if str ~= "" then
      if not mapData[id] then
        mapData[id] = {}
        mapData[id].curSize = 0
        mapData[id].bundleName = str
        mapData[id].subData = {}
        mapData[id].sort = id
        mapData[id].style = Logic_Lobby_DownLoad.E_DownLoadType.MainItem
        mapData[id].bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Classic_png.DL_Icon_Classic_png"
      end
      v.style = Logic_Lobby_DownLoad.E_DownLoadType.SubStyleOne
      mapData[id].curSize = mapData[id].curSize + v.subCurSize
      table.insert(mapData[id].subData, v)
    else
      bHasRes = true
      resData.curSize = resData.curSize + v.subCurSize
      resData.sort = 1
      resData.style = Logic_Lobby_DownLoad.E_DownLoadType.MainItem
      resData.bundleIcon = "/Game/UMG/Texture_200/Atlas/Download/Frames/DL_Icon_Recommend_png.DL_Icon_Recommend_png"
      v.style = Logic_Lobby_DownLoad.E_DownLoadType.SubStyleOne
      table.insert(resData.subData, v)
    end
  end
  if bHasRes then
    table.insert(mapData, resData)
  end
  local temp = {}
  for k, v in pairs(mapData) do
    table.insert(temp, v)
  end
  for i, v in ipairs(odPackDAta) do
    table.insert(temp, v)
  end
  for i, v in ipairs(temp) do
    if v.subData then
      table.sort(v.subData, function(a, b)
        if a.downLoadState and b.downLoadState and a.downLoadState ~= b.downLoadState then
          return a.downLoadState < b.downLoadState
        elseif a.timeRecord and b.timeRecord and a.timeRecord ~= b.timeRecord then
          return a.timeRecord < b.timeRecord
        else
          return a.subCurSize > b.subCurSize
        end
      end)
    end
  end
  table.sort(temp, function(a, b)
    return a.sort > b.sort
  end)
  for i, v in ipairs(temp) do
    v.tabClickIndex = i
  end
  return temp
end
local GetFinalNeedSize = function(size)
  size = size * 2.5
  return size
end
function DownloadDelSystem.GetBaseRealSize(fileName, size)
  local bNeedNewSize = false
  local needDownLoadFileList = PufferInterface.ReturnSplitMiniPakFilelist() or {}
  fileName = PufferInterface.GetRealFilename(fileName)
  for i, v in pairs(needDownLoadFileList) do
    if string.find(v, fileName) then
      bNeedNewSize = true
      break
    end
  end
  if not bNeedNewSize then
    size = GetFinalNeedSize(size)
    return size
  end
  local lowSize = 0
  local highSize = 0
  local lowRealSize = 0
  local highRealSize = 0
  local base = 0
  local baseRealSize = 0
  for i, v in pairs(needDownLoadFileList) do
    local path = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. v
    if not Client.IsFileExistsWithOutPakCheck(path) then
      if string.find(v, "res_basetexld") then
        lowSize = PufferInterface.GetFileSizeCompressed(v, true) / PufferConst.MB
        lowRealSize = PufferInterface.GetFileSizeCompressed(v) / PufferConst.MB
        lowRealSize = lowSize - lowRealSize
        if lowSize <= 0 then
          lowSize = 177
        end
      elseif string.find(v, "res_basetexmd") then
        highSize = PufferInterface.GetFileSizeCompressed(v, true) / PufferConst.MB
        highRealSize = PufferInterface.GetFileSizeCompressed(v) / PufferConst.MB
        highRealSize = highSize - highRealSize
        if highSize <= 0 then
          highSize = 400
        end
      else
        base = base + PufferInterface.GetFileSizeCompressed(v, true) / PufferConst.MB
        local tempbase = PufferInterface.GetFileSizeCompressed(v) / PufferConst.MB
        local tempfullbase = PufferInterface.GetFileSizeCompressed(v, true) / PufferConst.MB
        baseRealSize = tempfullbase - tempbase + baseRealSize
      end
    end
  end
  if string.find(fileName, "res_basetexld") or not PufferUpdater.bDownloadHighQuality then
    lowSize = lowSize + base
    lowSize = GetFinalNeedSize(lowSize) - lowRealSize - baseRealSize
    log(bWriteLog and string.format("[v_vyzhang] DownloadDelSystem.GetBaseRealSizeLow size:%s", tostring(lowSize)))
    return lowSize
  else
    highSize = highSize + base
    highSize = GetFinalNeedSize(highSize) - highRealSize - baseRealSize
    log(bWriteLog and string.format("[v_vyzhang] DownloadDelSystem.GetBaseRealSizeHigh size:%s", tostring(highSize)))
    return highSize
  end
end
function DownloadDelSystem.IsShowCleanResource()
  local pufferSize = 20
  local space = Client.GetDeviceFreeSpace() - 100
  if space < 0 then
    pufferSize = pufferSize - space
  end
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  PufferDeleteManager.ShowDeleteHintMsgBox(pufferSize)
  log_format("DownloadDelSystem.IsShowCleanResource. report")
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(109, true)
  return true
end
function DownloadDelSystem.UploadGemDeleteCrashFile()
  log_format("DownloadDelSystem.UploadGemDeleteCrashFile.")
  local nUid = DataMgr.roleData.uid
  if nUid and nUid ~= "" and nUid ~= 0 then
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    local fileList = PufferDeleteManager.uploadDeleteCrashFileList
    log_tree("DownloadDelSystem.UploadGemDeleteCrashFile. fileList = ", fileList)
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    if fileList == nil or not next(fileList) then
      return
    end
    local deleteFiles = ""
    for i, fileName in ipairs(fileList) do
      if i ~= 1 then
        deleteFiles = deleteFiles .. "|"
      end
      local pakName = PufferManager.GetPakName(fileName)
      deleteFiles = deleteFiles .. fileName .. "_" .. pakName
    end
    PufferDeleteManager.uploadDeleteCrashFileList = {}
    log_format("DownloadDelSystem.UploadGemDeleteCrashFile. deleteFiles=%s", deleteFiles)
    local enableUploadStatInfo = HDmpveRemote.HDmpveRemoteConfigGetBool("GEnableUploadStatInfo", true)
    local info = ""
    local param = {
      tostring(deleteFiles),
      tostring(info)
    }
    Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "DeleteCrashFileInfo", param)
  end
end
function DownloadDelSystem.UploadGemPufferSizeInfo(status, force, needCheckDelete)
  local nUid = DataMgr.roleData.uid
  if nUid and nUid ~= "" and nUid ~= 0 then
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    if not force and PufferDownloader.uploadDownloadSize == 0 and PufferDownloader.uploadDeleteSize == 0 then
      return
    end
    local pakSize, mapSize, odPakSize, resSize, ugcPakSize, prefetchSize = PufferDeleteManager.GetCurPaksSize()
    local pakDetailStr = string.format("mapSize_%.2f,odPakSize_%.2f,resSize_%.2f,ugcPakSize_%.2f,prefetchSize_%.2f,", mapSize, odPakSize, resSize, ugcPakSize, prefetchSize)
    local appSize = PufferDeleteManager.GetAppsize()
    local otherPaksSize = PufferDeleteManager.GetOtherPaksSize()
    PufferDeleteManager.GetSavedCacheSizeAsync(function()
      local cacheSize = PufferDeleteManager.savedCacheSize / PufferConst.MB
      for i, v in ipairs(PufferDeleteManager.CacheDirs) do
        local dir = string.match(v, "[^/]+/$")
        local dirSize = PufferDeleteManager.savedCacheDirSize[v] or 0
        pakDetailStr = pakDetailStr .. string.format("%s_%.2f,", dir, dirSize / PufferConst.MB)
      end
      local gameSize = appSize + pakSize + otherPaksSize + cacheSize
      local enableUploadStatInfo = HDmpveRemote.HDmpveRemoteConfigGetBool("GEnableUploadStatInfo", true)
      local info = ""
      if enableUploadStatInfo then
        local CacheSysContextStartSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysContextStart", 1)
        info = Client.CSCGetStatInfo()
        info = string.gsub(info, ":", "_")
        info = info .. "|odpakNmu_" .. tostring(DownloadDelSystem.odpakNum)
        info = info .. "|Start_" .. tostring(CacheSysContextStartSwitch) .. "_" .. tostring(Client.GetAndroidSOVersion()) .. "_" .. tostring(Client.GetMemorySize())
        info = info .. "|Puffer_" .. tostring(PufferDownloader.PufferJsonDownloadReturn)
        info = info .. "|GrayStep_" .. tostring(PufferDownloader.UpdateGrayStep)
        info = info .. "|autoDelete_" .. tostring(PufferDeleteManager.spaceAlertAutoDelete)
      end
      local param = {
        tostring(pakSize),
        tostring(otherPaksSize),
        tostring(cacheSize),
        tostring(gameSize),
        tostring(status),
        tostring(PufferDownloader.uploadDownloadSize),
        tostring(PufferDownloader.uploadDeleteSize),
        tostring(pakDetailStr),
        tostring(info),
        tostring(PufferDeleteManager.GetDeviceFreeSpace())
      }
      PufferDownloader.uploadDownloadSize = 0
      PufferDownloader.uploadDeleteSize = 0
      PufferDownloader.SaveDownloadSizeInfo()
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.UploadSize, PufferTlog.Enum_TLog_Optype.Finish, 0, tostring(gameSize), true)
      Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "PufferDownloaderSizeInfo", param)
      if needCheckDelete then
        DownloadDelSystem.CheckRecommendDelete()
      end
    end)
  end
end
function DownloadDelSystem.OnModePostSwitch(_, __, status)
  if status.current == GameStatus.Lobby then
    DownloadDelSystem.bIsLobby = true
    DownloadDelSystem.SendTlogEvent()
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(15, function()
      if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableDownloadPakSizeTest", true) and status.pre == GameStatus.Login then
        DownloadDelSystem.UploadGemDeleteCrashFile()
        local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
        local pakSize = PufferDeleteManager.GetCurPaksSize()
        local PufferSwitch = require("client.slua.logic.download.puffer_switch")
        local uploadDownloadSuccess = false
        local diff = 0
        local sizeInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloadSizeInfo) or {}
        log_tree("DownloadDelSystem.OnModePostSwitch. sizeInfo = ", sizeInfo)
        if type(sizeInfo.pakSize) == "number" and PufferDownloader.uploadDeleteSize == 0 then
          diff = sizeInfo.pakSize - pakSize
          if diff < 3000 and 1500 < diff then
            uploadDownloadSuccess = true
          end
        end
        PufferSwitch.        PufferDownloader.UploadGemReport(0, "PakDiffSize", tostring(diff))
        sizeInfo.        PlayerPrefsSystem.SaveTableToFile_N(sizeInfo, PlayerPrefsSystem.ePlayerPrefsType.eDownloadSizeInfo)
        if uploadDownloadSuccess then
        end
        local logic_lobby_downloader_tlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
        logic_lobby_downloader_tlog.ReportResourceSnapShot(pakSize)
      end
      DownloadDelSystem.UploadGemPufferSizeInfo(status.pre .. "->" .. status.current, true, true)
    end)
    if DownloadDelSystem.loginFlag == GameStatus.Login then
      DownloadDelSystem.SetAutoDeleteInLobbyCycle()
      DownloadDelSystem.IsNeedLobbyAutoShowDel()
    end
    DownloadDelSystem.CheckRecommendDelete()
  else
    DownloadDelSystem.StopWhitelistTimer()
    DownloadDelSystem.bIsLobby = false
    DownloadDelSystem.loginFlag = status.current
  end
end
function DownloadDelSystem.CheckRecommendDelete()
  log(bWriteLog and "[teddysjwu]DownloadDelSystem.CheckRecommendDelete")
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "[teddysjwu]return not in lobby!")
    return
  end
  if DownloadDelSystem.updateItemWhitelistTimer ~= nil then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP) then
    return
  end
  local curTime = FuncUtil.GetServerTimeInSec()
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  if PufferDeleteManager.spaceAlertSwitch == false or curTime < PufferDeleteManager.spaceAlertTime + 86400 then
    log(bWriteLog and "[teddysjwu]return spaceAlertSwitch = " .. tostring(PufferDeleteManager.spaceAlertSwitch) .. " spaceAlertTime =" .. tostring(PufferDeleteManager.spaceAlertTime))
    return
  end
  local alertSize = PufferDeleteManager.GetSpaceAlertSize()
  log(bWriteLog and "[teddysjwu] alertSize " .. tostring(alertSize))
  if alertSize == 0 then
    return
  end
  if PufferDeleteManager.IsGameSizeNeedAlert() then
    DownloadDelSystem.StartWhitelistTimer()
  end
end
function DownloadDelSystem.SetAutoDeleteInLobbyCycle()
  local TimeUtil = require("client.common.time_util")
  local tAutoShowDeldata = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDelete) or {}
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not tAutoShowDeldata.autoCycle then
    tAutoShowDeldata.autoCycle = {}
  end
  if not tAutoShowDeldata.autoCycle.startDay then
    tAutoShowDeldata.autoCycle.startDay = nowTime
    tAutoShowDeldata.autoCycle.recordDay = 0
  end
  if not tAutoShowDeldata.autoCycle.activeDay then
    tAutoShowDeldata.autoCycle.activeDay = 1
    tAutoShowDeldata.autoCycle.recordActiveDay = nowTime
  end
  if not TimeUtil.IsSameDay(tAutoShowDeldata.autoCycle.startDay, nowTime) and 1 <= math.floor((nowTime - tAutoShowDeldata.autoCycle.startDay) / 86400) then
    tAutoShowDeldata.autoCycle.recordDay = math.floor((nowTime - tAutoShowDeldata.autoCycle.startDay) / 86400)
  end
  if not TimeUtil.IsSameDay(tAutoShowDeldata.autoCycle.recordActiveDay, nowTime) then
    tAutoShowDeldata.autoCycle.activeDay = tAutoShowDeldata.autoCycle.activeDay + 1
    tAutoShowDeldata.autoCycle.recordActiveDay = nowTime
  end
  PlayerPrefsSystem.SaveTableToFile_N(tAutoShowDeldata, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDelete)
end
local GetAutoDeleData = function(tdata)
  local data = {}
  if tdata.nDeleteAll == 1 then
    data.bDeleAll = true
    return data
  else
    data.bDeleAll = false
    local StringUtil = require("common.string_util")
    data.tDeleData = StringUtil.Split(tdata.SDeleteData, "|")
    data.nTimeLimit = tdata.nMapTimeLimte
    return data
  end
end
local _JudgeCanClear = function(data)
  log(bWriteLog and "_JudgeCanClear")
  local deleteData = GetAutoDeleData(data)
  for i, v in pairs(LogicPufferBundle.GetDownloaderNewTable()) do
    local curSize = LogicPufferBundle.GetBundleSize(v.BundleID)
    if 0 < curSize then
      DownloadDelSystem.lobbyAutoConfig = deleteData
      DownloadDelSystem.bRecommendAutoDeleLobby = true
      if UIManager.IsAndroidStackEmpty() then
        local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
        PufferDeleteManager.ShowDeleteUI()
      end
      return
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDelete)
end
function DownloadDelSystem.IsNeedLobbyAutoShowDel()
  local space = Client.GetDeviceFreeSpace() / 1000
  local tAutoShowDeldata = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecommendDelete) or {}
  local nSaveRecordDay = tAutoShowDeldata.autoCycle.recordDay or 0
  local nSaveActiveDay = tAutoShowDeldata.autoCycle.activeDay or 0
  log_tree("v_vyhhzhang tAutoShowDeldata.autoCycle", tAutoShowDeldata.autoCycle)
  for i, v in pairs(CDataTable.GetTable("RecommendDelete")) do
    local bSpaceCondition = space > v.nCondition1 and space <= v.nCondition2 and nSaveActiveDay >= v.nActDay
    if nSaveRecordDay <= v.nCycleDay and bSpaceCondition then
      _JudgeCanClear(v)
      break
    elseif nSaveRecordDay >= v.nCycleDay and bSpaceCondition then
      _JudgeCanClear(v)
      break
    end
    if tAutoShowDeldata.autoCycle.AutoShow then
      DownloadDelSystem.lobbyAutoConfig = GetAutoDeleData(v)
      DownloadDelSystem.bRecommendAutoDeleLobby = true
      if UIManager.IsAndroidStackEmpty() then
        log(bWriteLog and "DownloadDelSystem.IsNeedLobbyAutoShowDel AutoShow")
        local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
        PufferDeleteManager.ShowDeleteUI()
      end
      tAutoShowDeldata.autoCycle = {}
      PlayerPrefsSystem.SaveTableToFile_N(tAutoShowDeldata, PlayerPrefsSystem.ePlayerPrefsType.eRecommendDelete)
      return
    end
  end
end
function DownloadDelSystem.SaveHasMountODPak(sPakName)
  DownloadDelSystem.saveHasMountODPakSize[sPakName] = 1
end
function DownloadDelSystem.CheckHasMountPaks(checkList)
  for k, v in pairs(checkList) do
    for ii, vv in ipairs(v) do
      if DownloadDelSystem.saveHasMountODPakSize[vv] then
        if not DownloadDelSystem.curDelListCache[k] then
          DownloadDelSystem.curDelListCache[k] = {}
          DownloadDelSystem.curDelListCache[k].size = 0
        end
        local curSize = 0
        local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. vv
        curSize = Client.GetFileSizeOnDiskBytes(filePathPak) / PufferConst.MB
        DownloadDelSystem.curDelListCache[k].size = DownloadDelSystem.curDelListCache[k].size + curSize
      end
    end
  end
  local data = {}
  for k, v in pairs(LogicPufferBundle.bundles) do
    for _, vv in pairs(v) do
      if tonumber(vv) and DownloadDelSystem.curDelListCache[tonumber(vv)] then
        if not data[k] then
          data[k] = {}
          data[k].size = 0
        end
        data[k].size = DownloadDelSystem.curDelListCache[tonumber(vv)].size + data[k].size
      end
    end
  end
  DownloadDelSystem.curMainListCache = data
end
function DownloadDelSystem.GetWardrobeItemList()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local resTable = wardrobe_data:GetTableForResIdSearch()
  local resIDs = {}
  local totalItemCount = 0
  if resTable then
    for k, _ in pairs(resTable) do
      resIDs[totalItemCount] = k
      totalItemCount = totalItemCount + 1
    end
  end
  local Logic_WardrobeGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local weaponIDList = Logic_WardrobeGun:GetSubTabItemCountList()
  for weaponID, v in pairs(weaponIDList) do
    if not resIDs[weaponID] then
      resIDs[totalItemCount] = weaponID
      totalItemCount = totalItemCount + 1
    end
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local infoList = ActorVoiceSystem.GetActorInfoList()
  if not infoList or not next(infoList) then
    ActorVoiceSystem.InitActorInfoFromTable(true)
    infoList = ActorVoiceSystem.GetActorInfoList()
  end
  for k, actorInfo in pairs(infoList) do
    local itemID = actorInfo.ActorItemID
    if not resIDs[itemID] then
      resIDs[totalItemCount] = itemID
      totalItemCount = totalItemCount + 1
    end
  end
  return resIDs
end
function DownloadDelSystem.StartWhitelistTimer()
  log(bWriteLog and "[teddysjwu]DownloadDelSystem.StartWhitelistTimer")
  local time_ticker = require("common.time_ticker")
  local resIDs = DownloadDelSystem.GetWardrobeItemList()
  local totalItemCount = #resIDs
  local checkCountPerStep = ITEM_WHITELIST_CHECK_NUM_PER_STEP
  local totalCount = math.ceil(totalItemCount / checkCountPerStep)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local handleItemCount = 1
  DownloadDelSystem.StopWhitelistTimer()
  DownloadDelSystem.itemWhitelist = {}
  DownloadDelSystem.updateItemWhitelistTime = FuncUtil.GetServerTimeInSec()
  local startTime = slua.getMiliseconds()
  local costTotalTime = 0
  DownloadDelSystem.updateItemWhitelistTimer = time_ticker.AddTimerLoop(0, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      DownloadDelSystem.itemWhitelist = nil
      DownloadDelSystem.StopWhitelistTimer()
      return
    end
    local loopStartTime = slua.getMiliseconds()
    for _ = 1, checkCountPerStep do
      local itemID = resIDs[handleItemCount]
      local state = PufferODPakManager:GetStateByItemID(itemID)
      if state == PufferConst.ENUM_DownloadState.Done then
        local paks = PufferODPakManager:GetPakNamesByItemID(itemID)
        for pakName, _ in pairs(paks) do
          local pakID, pakSize = PufferODPakManager:GetPakIDAndSizeByPakName(pakName)
          if pakID then
            local whitelistData = DownloadDelSystem.itemWhitelist[pakID]
            if whitelistData and not whitelistData.paks[pakName] then
              whitelistData.totalSize = whitelistData.totalSize + pakSize
              whitelistData.paks[pakName] = pakSize
            elseif not whitelistData then
              whitelistData = {}
              whitelistData.totalSize = pakSize
              whitelistData.paks = {}
              whitelistData.paks[pakName] = pakSize
              DownloadDelSystem.itemWhitelist[pakID] = whitelistData
            end
          end
        end
      end
      handleItemCount = handleItemCount + 1
      if handleItemCount >= totalItemCount then
        break
      end
    end
    local loopEndTime = slua.getMiliseconds()
    local loopCostTime = loopEndTime - loopStartTime
    costTotalTime = costTotalTime + loopCostTime
    if handleItemCount >= totalItemCount then
      log(bWriteLog and "[teddysjwu]WhiteListTimer, checkCount = " .. totalItemCount .. " LoopCostTime = " .. loopEndTime - startTime .. " HandleCostTime " .. costTotalTime)
      log_tree(DownloadDelSystem.itemWhitelist)
      DownloadDelSystem.StopWhitelistTimer()
      local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
      PufferDeleteManager.ShowSizeAlertUI(DownloadDelSystem.itemWhitelist)
    end
  end, totalCount, 0.03)
end
function DownloadDelSystem.StopWhitelistTimer()
  if DownloadDelSystem.updateItemWhitelistTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(DownloadDelSystem.updateItemWhitelistTimer)
    DownloadDelSystem.updateItemWhitelistTimer = nil
  end
end
return DownloadDelSystem
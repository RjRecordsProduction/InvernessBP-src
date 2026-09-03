local DownloadSystem = {
  E_DownLoadType = {
    MainItem = 1,
    SubStyleOne = 2,
    SubStyleTwo = 3
  }
}
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
function DownloadSystem.GetLobbyDownloadInfo(specialMapID, isNotLobbyBtnClick, skipItemPaks)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local tDownLoadList = {}
  for i, v in pairs(LogicPufferBundle.bundles) do
    local bundleCfg = CDataTable.GetTableData("DownloaderTable", i)
    if bundleCfg ~= nil then
      local data = {}
      data.bundleID = bundleCfg.BundleID
      data.bundleName = bundleCfg.BundleName
      data.bundleIcon = bundleCfg.BundleIcon
      data.bundleBGPath = bundleCfg.bundleBGPath
      data.isHot = bundleCfg.IsHot
      data.isHighLight = bundleCfg.IsHighLight
      data.IsFold = bundleCfg.IsFold
      local curSize = 0
      local totalSize = 0
      data.state = PufferConst.ENUM_DownloadState.Not
      for _, vv in pairs(v) do
        local tSubData, curSizeInBytes, totalSizeInBytes = DownloadSystem.GetItemData(vv, skipItemPaks)
        curSize = curSize + curSizeInBytes
        totalSize = totalSize + totalSizeInBytes
        if tSubData.state == PufferConst.ENUM_DownloadState.Download and tSubData.downloadName ~= "" and (not data.subCurSize or tSubData.tSize - tSubData.cSize < data.subTotalSize - data.subCurSize) then
          data.downloadName = tSubData.downloadName
          data.subCurSize = tSubData.cSize
          data.subTotalSize = tSubData.tSize
        end
        if not data.subData then
          data.subData = {}
        end
        if tSubData.downloadName ~= "" and 0 < tSubData.subTotalSize then
          table.insert(data.subData, tSubData)
        else
        end
      end
      data.percent = curSize / totalSize
      data.curSize = curSize / PufferConst.MB
      if totalSize < PufferConst.MB then
        totalSize = PufferConst.MB
      end
      data.totalSize = totalSize / PufferConst.MB
      data.style = DownloadSystem.E_DownLoadType.MainItem
      if specialMapID and 0 < specialMapID then
        local tKeyName = "SpecialRoomMapConfig"
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if PublishRegionMacros.IsJapanOrKorea() then
          tKeyName = tKeyName .. "_KJ"
        end
        local config = CDataTable.GetTableData(tKeyName, specialMapID)
        if not (config and config.BundleID) or config.BundleID == 0 then
          break
        end
        if data.bundleID == config.BundleID then
          table.insert(tDownLoadList, data)
          break
        end
      elseif CreateRoomSystem.IsAsiaGamesWhite() then
        if isNotLobbyBtnClick and data.bundleID == 100007 then
          table.insert(tDownLoadList, data)
          break
        elseif not isNotLobbyBtnClick and data.bundleID ~= 100007 then
          table.insert(tDownLoadList, data)
        end
      else
        table.insert(tDownLoadList, data)
      end
    end
  end
  DownloadSystem.FixDownloadStateAndSort(tDownLoadList)
  if tDownLoadList[1] and tDownLoadList[1].bundleID == PufferConst.PREFETCH_BUNDLE_ID then
    local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
    if PufferPrefetchManager:GetReserveState() ~= PufferConst.ENUM_ReserveState.CanDownload or PufferPrefetchManager:GetState() == PufferConst.ENUM_DownloadState.Done then
      table.insert(tDownLoadList, tDownLoadList[1])
      table.remove(tDownLoadList, 1)
    end
  end
  for i, v in ipairs(tDownLoadList) do
    v.tabClickIndex = i
  end
  return tDownLoadList
end
function DownloadSystem.FixDownloadStateAndSort(tDownloadData)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  for i, v in ipairs(tDownloadData) do
    if next(v.subData) then
      local hasDone = 0
      local hasWait = 0
      for ii, vv in ipairs(v.subData) do
        if vv.state == PufferConst.ENUM_DownloadState.Done then
          hasDone = hasDone + 1
        end
        if vv.state == PufferConst.ENUM_DownloadState.Wait then
          hasWait = hasWait + 1
        end
        if vv.state == PufferConst.ENUM_DownloadState.Download then
          v.state = PufferConst.ENUM_DownloadState.Download
          break
        elseif vv.state == PufferConst.ENUM_DownloadState.Pause then
          v.state = PufferConst.ENUM_DownloadState.Pause
        elseif hasDone == #v.subData then
          v.state = PufferConst.ENUM_DownloadState.Done
        elseif hasWait == ii - hasDone then
          v.state = PufferConst.ENUM_DownloadState.Wait
        else
          v.state = PufferConst.ENUM_DownloadState.Pause
        end
        if v.curSize == 0 and v.state ~= PufferConst.ENUM_DownloadState.Wait then
          v.state = PufferConst.ENUM_DownloadState.Not
        end
      end
    end
  end
  table.sort(tDownloadData, function(a, b)
    return a.bundleID < b.bundleID
  end)
end
function DownloadSystem.GetRemakeDownLoadData(tDownLoadList, nClickIndex)
  local data = tDownLoadList
  local tabScrollIndex = data and nClickIndex and data[nClickIndex] and data[nClickIndex].tabClickIndex or 1
  if data and nClickIndex and data[nClickIndex] and data[nClickIndex].subData then
    local index = nClickIndex + 1
    for i, v in ipairs(data[nClickIndex].subData) do
      table.insert(data, index, v)
      index = index + 1
    end
  end
  return data, tabScrollIndex
end
function DownloadSystem.GetStateImagePathByDownloadState(nDownloadState)
  if nDownloadState == PufferConst.ENUM_DownloadState.Done then
    return "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Yes_png.Common_Icon_Yes_png"
  elseif nDownloadState == PufferConst.ENUM_DownloadState.Wait then
    return "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Wait_png.Common_Icon_Wait_png"
  elseif nDownloadState == PufferConst.ENUM_DownloadState.Download then
    return "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Pause_png.Common_Icon_Pause_png"
  elseif nDownloadState == PufferConst.ENUM_DownloadState.Pause then
    return "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Begin_png.Common_Icon_Begin_png"
  else
    return "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png"
  end
end
function DownloadSystem.GetFormatSizeContent(nCurSize, nTotalSize, state, bRichText)
  local strCur = ""
  local strTotal = ""
  local str = ""
  nCurSize = nCurSize or 0
  nTotalSize = nTotalSize or 0
  if state == PufferConst.ENUM_DownloadState.Not and nCurSize == 0 then
    if nTotalSize < 1000 then
      local strTotal = string.format("%.1f", nTotalSize)
      if 0 < nTotalSize and strTotal == "0.0" then
        strTotal = "0.1"
      end
      str = LocUtil.LocalizeResFormat(32712, strTotal)
    else
      str = LocUtil.LocalizeResFormat(37454, string.format("%.2f", nTotalSize / 1000))
    end
    return str
  end
  if bRichText then
    if 1000 <= nCurSize then
      strCur = LocUtil.LocalizeResFormat(37454, string.format("%.2f", nCurSize / 1000))
      strTotal = LocUtil.LocalizeResFormat(37454, string.format("%.2f", nTotalSize / 1000))
    elseif 1000 <= nTotalSize then
      strCur = LocUtil.LocalizeResFormat(32712, string.format("%.2f", nCurSize))
      strTotal = LocUtil.LocalizeResFormat(37454, string.format("%.2f", nTotalSize / 1000))
    else
      strCur = string.format("%.1f", nCurSize)
      strTotal = string.format("%.1f", nTotalSize)
      if 0 < nCurSize and strCur == "0.0" then
        strCur = "0.1"
      end
      if strTotal == "0.0" then
        strTotal = "0.1"
      end
      strCur = LocUtil.LocalizeResFormat(32712, strCur)
      strTotal = LocUtil.LocalizeResFormat(32712, strTotal)
    end
    str = LocUtil.LocalizeResFormat(38933, strCur, strTotal)
  elseif 1000 <= nCurSize then
    strCur = string.format("%.2f", nCurSize / 1000)
    strTotal = string.format("%.2f", nTotalSize / 1000)
    str = LocUtil.LocalizeResFormat(37444, strCur, strTotal)
  elseif 1000 <= nTotalSize then
    strCur = string.format("%.2f", nCurSize)
    strTotal = string.format("%.2f", nTotalSize / 1000)
    str = LocUtil.LocalizeResFormat(37443, strCur, strTotal)
  else
    strCur = string.format("%.1f", nCurSize)
    strTotal = string.format("%.1f", nTotalSize)
    if 0 < nCurSize and strCur == "0.0" then
      strCur = "0.1"
    end
    if strTotal == "0.0" then
      strTotal = "0.1"
    end
    str = LocUtil.LocalizeResFormat(37442, strCur, strTotal)
  end
  return str
end
function DownloadSystem.GetMapImageByKey(sMapKey)
  if not sMapKey then
    return ""
  end
  local showImage = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Small/Lobby_match_MapEntrance_S004.Lobby_match_MapEntrance_S004"
  local cfg = CDataTable.GetTableData("MapPakTable", sMapKey)
  if cfg and cfg.showImage ~= "" then
    showImage = cfg.showImage
  end
  return showImage
end
function DownloadSystem.GetMapDescByKey(sMapKey)
  if not sMapKey then
    return ""
  end
  local data = CDataTable.GetTableData("MapPakTable", sMapKey)
  if data then
    return data.MapDesc
  end
  return ""
end
function DownloadSystem.GetMapDownLoadReward(sMapKey)
  if not sMapKey then
    return false
  end
  local data = CDataTable.GetTableData("MapDownLoadReward", sMapKey)
  if data then
    return data.ID
  end
  return false
end
function DownloadSystem.GetMapHasCanReward(rewardID)
  local data = CDataTable.GetTable("MapDownLoadReward")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if data then
    for k, v in pairs(data) do
      if v.ID == rewardID and PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
        v.MapKey
      }, true) == PufferConst.ENUM_DownloadState.Done then
        if logic_mode_selection:GetViewDictionary() and not logic_mode_selection:CheckMapKeyNeedDownload(v.MapKey) then
          return false
        end
        return true
      end
    end
  end
  return false
end
function DownloadSystem.IsModeSwitchDownLoadReward(mapKeyList)
  for k, v in pairs(mapKeyList) do
    local rewardID = DownloadSystem.GetMapDownLoadReward(v)
    if rewardID and PufferDownloader.DownloadRewardCfg[rewardID] and not PufferDownloader.DownloadRewardCfg[rewardID].is_got then
      return true
    end
  end
  return false
end
function DownloadSystem.IsModeSwitchDownLoadRewardCanGet(mapKeyList)
  if not mapKeyList then
    return false
  end
  for k, v in pairs(mapKeyList) do
    local rewardID = DownloadSystem.GetMapDownLoadReward(v)
    if rewardID and PufferDownloader.DownloadRewardCfg[rewardID] and not PufferDownloader.DownloadRewardCfg[rewardID].is_got and DownloadSystem.GetMapHasCanReward(rewardID) then
      return true
    end
  end
  return false
end
local MAP_ADD_ORDER_NUM = 1000000
local ORDER_MIN_NUM = 1000
local MAX_ORDER_NUM = 9000000
function DownloadSystem._InitSmartDownloadCfg(srcTable, cfgOrderKey, itemData, selectFunc)
  local orderMap = {}
  local keyList = {}
  local mergeKeyOrderMap = {}
  local mergeKeySizeInfo = {}
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local handleAddKey = function(downloadUIData, key, order)
    if downloadUIData.bundleID then
      local bundleKey = PufferConst.PACK_SET_PREFIX .. tostring(downloadUIData.bundleID)
      local preOrder = mergeKeyOrderMap[bundleKey]
      if not preOrder or order < preOrder then
        mergeKeyOrderMap[bundleKey] = order
      end
      local sizeData = mergeKeySizeInfo[bundleKey]
      if sizeData == nil then
        sizeData = {cSize = 0, tSize = 0}
      end
      sizeData.cSize = sizeData.cSize + downloadUIData.cSize
      sizeData.tSize = sizeData.tSize + downloadUIData.tSize
    else
      orderMap[key] = order
      table.insert(keyList, key)
    end
  end
  local PakInfoTableArr = CDataTable.GetTable("PakInfoTable")
  for k, v in pairs(PakInfoTableArr) do
    if k ~= PufferConst.EODPackID.UserCurEquipment and k ~= PufferConst.EODPackID.UserWardrobe then
      local order = v[cfgOrderKey]
      local downloadUIData = itemData[k]
      if downloadUIData and type(order) == "number" then
        local finalOder = order + ORDER_MIN_NUM
        handleAddKey(downloadUIData, k, finalOder)
      end
    end
  end
  local MapArr = CDataTable.GetTable("MapPakTable")
  for k, v in pairs(MapArr) do
    local order = v[cfgOrderKey]
    local downloadUIData = itemData[k]
    if downloadUIData and type(order) == "number" then
      if 0 < order then
        order = order + MAP_ADD_ORDER_NUM
      end
      orderMap[k] = order + ORDER_MIN_NUM
      handleAddKey(downloadUIData, k, order)
    end
  end
  for k, v in pairs(mergeKeyOrderMap) do
    orderMap[k] = v
    table.insert(keyList, k)
  end
  local orderFunc = function(a, b)
    return orderMap[a] > orderMap[b]
  end
  table.sort(keyList, orderFunc)
  srcTable.orderList = keyList
  if selectFunc then
    selectFunc(srcTable, keyList, itemData, mergeKeySizeInfo)
  end
  log_tree("DownloadSystem._InitSmartDownloadCfg. srcTable = ", srcTable)
end
function DownloadSystem._InitSmartDownloadDownloadSelect(srcTable, keyList, itemData, mergeKeyMap)
  log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect.")
  local space = Client.GetDeviceFreeSpace()
  log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect. space = " .. tostring(space))
  local cfgList = CDataTable.GetTable("RecommendDownloadTable")
  local matchCfg
  local freeSpaceGB = space / 1000
  for k, v in pairs(cfgList) do
    if k >= freeSpaceGB then
      matchCfg = v
      break
    end
  end
  matchCfg = matchCfg or CDataTable.GetTableData("RecommendDownloadTable", 9999)
  if not matchCfg then
    log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect. no cfg")
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect. nDeviceLevel = " .. tostring(nDeviceLevel))
  local maxDownloadSize = matchCfg["DeviceTier" .. tostring(nDeviceLevel + 1)] * 1000
  log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect.  maxDownloadSize = " .. tostring(maxDownloadSize))
  if space < maxDownloadSize then
    maxDownloadSize = space
  end
  local selectSize = 0
  srcTable.selectMap = {}
  for i, v in ipairs(keyList) do
    log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect. v = " .. tostring(v))
    local DownloadItemUIData = mergeKeyMap[v] or itemData[v]
    if DownloadItemUIData then
      local tSize = DownloadItemUIData.tSize
      if tSize and maxDownloadSize >= selectSize + tSize then
        selectSize = selectSize + tSize
        srcTable.selectMap[v] = true
        printf("_InitSmartDownloadDownloadSelect. key = %s, selectSize = %.2f, totalSize = %.2f", v, tSize, selectSize)
      else
        break
      end
    end
  end
end
function DownloadSystem._InitSmartDownloadDeleteSelect(srcTable, keyList, itemData, mergeKeyMap)
  log(bWriteLog and "DownloadSystem._InitSmartDownloadDeleteSelect.")
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local targetSize = PufferDeleteManager.GetDeleteTargetSize({})
  local selectSize = 0
  srcTable.selectMap = {}
  if targetSize == 0 then
    srcTable = keyList
  else
    for i, v in ipairs(keyList) do
      local DownloadItemUIData = mergeKeyMap[v] or itemData[v]
      if DownloadItemUIData then
        local tSize = DownloadItemUIData.tSize
        if tSize and targetSize > selectSize then
          selectSize = selectSize + tSize
          srcTable.selectMap[v] = true
          printf("_InitSmartDownloadDeleteSelect. key = %s, selectSize = %.2f, totalSize = %.2f", v, tSize, selectSize)
        else
          break
        end
      end
    end
  end
end
function DownloadSystem.HandleSmartDownloadCfgOrderList(defaultData, saveData)
  local TableUtil = require("common.table_util")
  local changed = false
  if not next(saveData) and next(defaultData) then
    for k, v in pairs(defaultData) do
      saveData[k] = TableUtil.CopyTable(v)
    end
    changed = true
  end
  return changed
end
function DownloadSystem.InitSmartDownloadInfo(itemData, mergeBundleDataMap)
  log(bWriteLog and "DownloadSystem.InitSmartDownloadInfo.")
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local SmartDownloadCfg = PufferSwitch.SmartDownloadCfg
  local changed = false
  if not next(PufferSwitch.DownloadDefaultCfg) then
    DownloadSystem._InitSmartDownloadCfg(PufferSwitch.DownloadDefaultCfg, "downloadOrder", itemData, DownloadSystem._InitSmartDownloadDownloadSelect)
  end
  if DownloadSystem.HandleSmartDownloadCfgOrderList(PufferSwitch.DownloadDefaultCfg, SmartDownloadCfg.DownloadCfg) then
    SmartDownloadCfg.DownloadCfgFromDefault = true
    changed = true
  end
  if not next(PufferSwitch.DeleteDefaultCfg) then
    DownloadSystem._InitSmartDownloadCfg(PufferSwitch.DeleteDefaultCfg, "deleteOrder", itemData, DownloadSystem._InitSmartDownloadDeleteSelect)
  end
  if DownloadSystem.HandleSmartDownloadCfgOrderList(PufferSwitch.DeleteDefaultCfg, SmartDownloadCfg.DeleteCfg) then
    SmartDownloadCfg.DeleteCfgFromDefault = true
    changed = true
  end
  DownloadSystem.UpdateNeedKeyMap()
  DownloadSystem.UpdateSmartDownloadSelectSize(itemData, mergeBundleDataMap)
  if changed then
    PufferSwitch.SaveSmartDownloadSetting()
  end
end
function DownloadSystem.UpdateSmartDownloadSelectSize(itemData, mergeBundleDataMap)
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local SmartDownloadCfg = PufferSwitch.SmartDownloadCfg
  PufferSwitch.SmartDownloadSelectSize = DownloadSystem._GetSelectSize(SmartDownloadCfg.DownloadCfg, itemData, mergeBundleDataMap, true)
  PufferSwitch.SmartDeleteSelectSize = DownloadSystem._GetSelectSize(SmartDownloadCfg.DeleteCfg, itemData, mergeBundleDataMap, false)
  log(bWriteLog and "DownloadSystem.UpdateSmartDownloadSelectSize. SmartDownloadSelectSize = " .. tostring(PufferSwitch.SmartDownloadSelectSize))
  log(bWriteLog and "DownloadSystem.UpdateSmartDownloadSelectSize. SmartDeleteSelectSize = " .. tostring(PufferSwitch.SmartDeleteSelectSize))
end
function DownloadSystem.UpdateNeedKeyMap()
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if next(PufferSwitch.DeleteNeedKeys) then
    log(bWriteLog and "DownloadSystem.UpdateNeedKeyMap. inited")
    return
  end
  local PakInfoTableArr = CDataTable.GetTable("PakInfoTable")
  for k, v in pairs(PakInfoTableArr) do
    local order = v.deleteOrder
    if type(order) ~= "number" or order == 0 then
      PufferSwitch.DeleteNeedKeys[k] = true
    end
  end
  local MapArr = CDataTable.GetTable("MapPakTable")
  for k, v in pairs(MapArr) do
    local order = v.deleteOrder
    if type(order) ~= "number" or order == 0 then
      PufferSwitch.DeleteNeedKeys[k] = true
    end
  end
  log_tree("DownloadSystem.UpdateNeedKeyMap. PufferSwitch.DeleteNeedKeys = ", PufferSwitch.DeleteNeedKeys)
end
function DownloadSystem._GetSelectSize(srcTable, itemData, isDownload)
  if not srcTable or not srcTable.selectMap then
    return
  end
  local selectSize = 0
  local StringUtil = require("common.string_util")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  for k, v in pairs(srcTable.selectMap) do
    if StringUtil.Starts(k, PufferConst.PACK_SET_PREFIX) then
    else
      local DownloadItemUIData = itemData[k]
      if v and DownloadItemUIData then
        local size = DownloadItemUIData.tSize
        if not isDownload then
          size = DownloadItemUIData.cSize
        end
        selectSize = selectSize + size
      end
    end
  end
  return selectSize
end
function DownloadSystem.GetItemData(itemKey, skipItemPaks)
  local state = PufferConst.ENUM_DownloadState.Done
  local cSize, tSize = 0, 0
  local downloadName = ""
  local tSubData = {}
  tSubData.style = DownloadSystem.E_DownLoadType.SubStyleOne
  tSubData.iconPath = ""
  if tonumber(itemKey) then
    local packID = tonumber(itemKey)
    tSubData.downloadType = PufferConst.ENUM_DownloadType.ODPACK
    local cfg = CDataTable.GetTableData("PakInfoTable", packID)
    if cfg then
      downloadName = cfg.PakName
      tSubData.iconPath = cfg.IconPath
      if cfg.IsUGC == 1 then
        tSubData.downloadType = PufferConst.ENUM_DownloadType.UGCPACK
      end
    end
    state = PufferManager.GetState(tSubData.downloadType, {packID})
    cSize, tSize = PufferManager.GetSize(tSubData.downloadType, {packID}, true)
    if skipItemPaks and skipItemPaks[packID] then
      local subSize = skipItemPaks[packID].totalSize
      cSize = cSize - subSize
      if cSize < 0 then
        cSize = 0
      end
    end
    cSize = cSize * PufferConst.MB
    tSize = tSize * PufferConst.MB
  else
    local downloadType = PufferManager.GetDownloadType(itemKey)
    if downloadType == PufferConst.ENUM_DownloadType.MAP then
      state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {itemKey}, true)
      cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {itemKey}, true)
      local mapCfg = CDataTable.GetTableData("MapPakTable", itemKey)
      if mapCfg then
        if itemKey == "map_singletraining" then
          tSubData.style = DownloadSystem.E_DownLoadType.SubStyleOne
          tSubData.iconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Range_png.Common_Icon_Range_png"
        elseif itemKey == "map_socialisland" then
          tSubData.style = DownloadSystem.E_DownLoadType.SubStyleOne
          tSubData.iconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_SocialIsland_png.Common_Icon_SocialIsland_png"
        else
          tSubData.style = DownloadSystem.E_DownLoadType.SubStyleTwo
          tSubData.iconPath = DownloadSystem.GetMapImageByKey(itemKey)
        end
        downloadName = mapCfg.name
        tSubData.downloadType = PufferConst.ENUM_DownloadType.MAP
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.RES then
      state = PufferManager.GetState(PufferConst.ENUM_DownloadType.RES, {itemKey})
      cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.RES, {itemKey})
      local cfg = CDataTable.GetTableData("ResPakTable", itemKey)
      if cfg then
        downloadName = cfg.ResName
        tSubData.downloadType = PufferConst.ENUM_DownloadType.RES
        tSubData.iconPath = cfg.ResIcon
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.PREFETCH then
      state = PufferManager.GetState(PufferConst.ENUM_DownloadType.PREFETCH, {itemKey})
      tSubData.      cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.PREFETCH, {itemKey})
      tSubData.style = DownloadSystem.E_DownLoadType.SubStyleTwo
      local cfg = CDataTable.GetTableData("PakInfoTable", PufferConst.PREFETCH_BUNDLE_ID)
      if cfg then
        downloadName = cfg.PakName
        tSubData.iconPath = cfg.IconPath
        tSubData.hideProgress = true
        tSubData.desc = cfg.PakDesc
        tSubData.downloadType = PufferConst.ENUM_DownloadType.PREFETCH
      end
    end
  end
  local curSizeInBytes = cSize
  local totalSizeInBytes = tSize
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  tSubData.  tSubData.subCurSize = cSize
  tSubData.subTotalSize = tSize
  tSubData.  if cSize == 0 and state == PufferConst.ENUM_DownloadState.Pause then
    tSubData.state = PufferConst.ENUM_DownloadState.Not
  end
  tSubData.key = itemKey
  return tSubData, curSizeInBytes, totalSizeInBytes
end
function DownloadSystem.IsAppearancePak(pakName)
  if not (pakName ~= "" and pakName) or pakName == PufferConst.CE_LOCK_PAKNAME or pakName == PufferConst.LOCK_PAKNAME then
    return false
  end
  return true
end
function DownloadSystem.GetUserEquipmentPaks()
  local userEquipmentPaks = {}
  local userEquipmentItems
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetAvatarByUid(tonumber(DataMgr.roleData.uid))
  if myAvatar then
    userEquipmentItems = {}
    local equipments = myAvatar:GetEquipments()
    if equipments then
      for _, vv in pairs(equipments) do
        local itemID = vv.itemID
        local pakNames = PufferManager.GetPakNamesByItemID(itemID)
        for pakName, _ in pairs(pakNames) do
          if DownloadSystem.IsAppearancePak(pakName) then
            log(bWriteLog and string.format("Download_Main_UIBP:InitBundleData. itemID:%s, pakName=%s", tostring(itemID), tostring(pakName)))
            userEquipmentPaks[pakName] = true
          end
        end
      end
      for pakName, _ in pairs(userEquipmentPaks) do
        if Client.IsDevelopment() then
          local newFileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, pakName)
          log(bWriteLog and string.format("Download_Main_UIBP:InitBundleData. pakName=%s,size=%s", tostring(pakName), tostring(newFileSize)))
        end
        table.insert(userEquipmentItems, pakName)
      end
      DownloadSystem.      DownloadSystem.      return userEquipmentPaks, userEquipmentItems
    end
  end
  return userEquipmentPaks, userEquipmentItems
end
function DownloadSystem.CacheUserWardrobePaks(userWardrobePaks, userWardrobeItems)
  DownloadSystem.  DownloadSystem.end
function DownloadSystem.GetUserWardrobePaks()
  local DownloadDelSystem = require("client.slua.logic.download.delete.logic_download_delete")
  local userWardrobeItems = DownloadDelSystem.GetWardrobeItemList()
  local userWardrobePaks = {}
  for _, item in ipairs(userWardrobeItems) do
    local pakNames = PufferManager.GetPakNamesByItemID(item)
    for pakName, _ in pairs(pakNames) do
      if DownloadSystem.IsAppearancePak(pakName) then
        userWardrobePaks[pakName] = true
      end
    end
  end
  DownloadSystem.  DownloadSystem.  return userWardrobePaks, userWardrobeItems
end
return DownloadSystem
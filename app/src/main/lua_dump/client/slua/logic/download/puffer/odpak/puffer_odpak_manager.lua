local PufferODPakManager = {}
local StringUtil = require("common.string_util")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local local local puffer_queue
function PufferODPakManager:DefineAndResetData()
  self.ODPaks = {}
  self.PakDatas = {}
  self.TableKeyToPaks = {}
  self.itemToPaks = {}
  self.itemToItems = {}
  self.itemToPaths = {}
  self.BlackListPaks = {}
  self.PauseDontAutoDownloadPaks = {}
  self.ODPaksNameToConHash = {}
  self.needRecoverBattleData = false
  self.battleDeleteFiles = {}
  self._attachmentSkinIDInited = false
  self._attachmentSkinIDMap = nil
  puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  self.isLowMemoryDevice = ScriptHelperEngine.IsLowMemoryDevice()
  self.isLowMemoryDevice = true
  self.battleDownloadHashMap = {}
  self.battleDownloadPaks = {}
  self.IsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  self.TCDeviceLevel = Client.GetTCDeviceLevel()
  self.isInitODPakData = false
end
function PufferODPakManager:InitODPaks(existPaks, callback, async)
  log_format("PufferODPakManager:InitODPaks. existPaks = %s, callback = %s, async = %s", existPaks, callback, async)
  if type(callback) == "function" then
    if self.callbackList == nil then
      self.callbackList = {}
    end
    table.insert(self.callbackList, callback)
    log_format("PufferODPakManager:InitODPaks. add callback")
  end
  if self.isInitODPakData then
    log_format("PufferODPakManager:InitODPaks. already in init")
    return
  end
  local val = HDmpveRemote.HDmpveRemoteConfigGetInt("GEnableBackpackPakCache", 0)
  local minMemorySize = HDmpveRemote.HDmpveRemoteConfigGetInt("GForceDisableBackpackPakCacheMem", 0)
  local ScriptHelperClient = import("ScriptHelperClient")
  local curMemorySize = ScriptHelperClient.GetMemorySize()
  log_format("PufferODPakManager:InitODPaks. size = %s, minMemory = %s", curMemorySize, minMemorySize)
  if 0 < minMemorySize and minMemorySize > curMemorySize then
    val = 0
  end
  PufferDownloader.SetEnableBackpackCache(val)
  log_format("PufferODPakManager:InitODPaks start")
  self:DefineAndResetData()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  PufferUGCPakManager:InitUGCDependsODPak(existPaks)
  local IsDevelopment = Client.IsDevelopment()
  self.enableSaveODPakDataToFile = HDmpveRemote.HDmpveRemoteConfigGetBool("GSaveODPakDataToFile", false)
  local pufferFileList = PufferDownloader.GetPufferFileListJson()
  self:MapContentHashPro(pufferFileList.conhash_list)
  if pufferFileList.ODPaks == nil or next(pufferFileList.ODPaks) == nil then
    log_format("PufferODPakManager:InitODPaks PufferFileList.json error")
    return
  end
  self:InitUGCExpiredDepends()
  local pakInfoTableList = CDataTable.GetTable("PakInfoTable")
  local startTime = slua.getMiliseconds()
  local needHandleIDs = {}
  for k, _ in pairs(pufferFileList.ODPaks) do
    local key = tonumber(k)
    if key then
      needHandleIDs[key] = true
    end
  end
  self.isInitODPakData = true
  if self.handleInitODPackTimer then
    self:RemoveTimer(self.handleInitODPackTimer)
  end
  local HandleInitODPackStep = function(async)
    local handleStartTime = slua.getMiliseconds()
    for id, _ in pairs(needHandleIDs) do
      local needHandle = true
      local infoTable = pakInfoTableList[id]
      if infoTable and infoTable.IsUGC ~= 0 then
        log_format("PufferODPakManager:InitODPaks. handleInitODPack id = %s is UGC", id)
        needHandle = false
      end
      if needHandle then
        local dataCfg = pufferFileList.ODPaks[tostring(id)]
        if dataCfg then
          self:InitODPack(dataCfg.fileList, id)
        end
      end
      needHandleIDs[id] = nil
      log_format("PufferODPakManager:InitODPaks. handleInitODPack id = %s", id)
      local costTime = slua.getMiliseconds() - handleStartTime
      if async and 30 < costTime then
        log_format("PufferODPakManager:InitODPaks. handleInitODPack costTime = %s", costTime)
        return
      end
    end
    local costTime = slua.getMiliseconds() - startTime
    log_format("PufferODPakManager:InitODPaks. handleInitODPack total costTime = %s", costTime)
    if not next(needHandleIDs) then
      if self.handleInitODPackTimer then
        self:RemoveTimer(self.handleInitODPackTimer)
      end
      self.handleInitODPackTimer = nil
      self:UpdatePkgCheckInfo(existPaks)
      self:UpdateExistPaks(existPaks)
      self.isInitODPakData = false
      log_format("PufferODPakManager:InitODPaks. end")
      local callbacks = self.callbackList
      self.callbackList = {}
      log_tree("PufferODPakManager:InitODPaks. callbacks = ", callbacks)
      for k, cb in ipairs(callbacks) do
        log_format("PufferODPakManager:InitODPaks. invoke callback")
        cb(existPaks)
      end
    end
  end
  if async then
    self.handleInitODPackTimer = self:AddTimerLoop(0, function()
      HandleInitODPackStep(true)
    end, TIMER_INFINITE, 0.01)
  else
    HandleInitODPackStep(false)
  end
end
function PufferODPakManager:InitODPack(fileList, id, existPaks)
  if not next(fileList) or not id then
    return
  end
  log_format("PufferODPakManager:InitODPack. id=%s", id)
  local data = {}
  self.ODPaks[id] = data
  data.paks = {}
  data.curCnt = 0
  data.totalCnt = #fileList
  data.curSize = 0
  data.totalSize = 0
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  data.state = ENUM_DownloadState.Not
  local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
  logic_puffer_common.InitPakList(id, fileList, function(pakName, size, hash)
    if not pakName then
      return
    end
    local pakNameData = {
      tSize = 0,
      cSize = 0,
      state = ENUM_DownloadState.Not
    }
    data.paks[pakName] = pakNameData
    pakNameData.tSize = size
    if hash then
      self.ODPaksNameToConHash[pakName] = hash
    end
    if self.PakDatas[pakName] then
      log_format("PufferODPakManager:InitODPack. Error! exist pakName: %s, prePackID = %s", pakName, self.PakDatas[pakName].packID)
    else
      self.PakDatas[pakName] = {packID = id, data = pakNameData}
    end
    if existPaks and existPaks[pakName] then
      pakNameData.cSize = pakNameData.tSize
      pakNameData.state = ENUM_DownloadState.Done
      data.curCnt = data.curCnt + 1
    end
    data.totalSize = data.totalSize + pakNameData.tSize
  end)
  if existPaks then
    self:_UpdatePackDataState(data)
  end
end
function PufferODPakManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self.CheckBattleDownload, self)
end
function PufferODPakManager:MapContentHashPro(conhash_list)
  local USFEnableUpdatePkgMapType = HDmpveRemote.HDmpveRemoteConfigGetInt("USFEnableUpdatePkgMapType", 0)
  if USFEnableUpdatePkgMapType == 0 then
    log(bWriteLog and "PufferODPakManager:MapContentHashPro return for USFEnableUpdatePkgMapType = " .. tostring(USFEnableUpdatePkgMapType))
    return
  end
  if conhash_list == nil then
    log(bWriteLog and "PufferODPakManager:MapContentHashPro  return for conhash_list == nil")
    return
  end
  log_tree("PufferODPakManager:MapContentHashPro conhash_list = ", conhash_list)
  for PkgName, ContentHash in pairs(conhash_list) do
    self.ODPaksNameToConHash[PkgName] = ContentHash
  end
end
function PufferODPakManager:UFSSUpdatePkgMapType(filestate)
  local USFEnableUpdatePkgMapType = HDmpveRemote.HDmpveRemoteConfigGetInt("USFEnableUpdatePkgMapType", 0)
  if USFEnableUpdatePkgMapType == 0 then
    log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType return for UFSSUpdatePkgMapType = " .. tostring(USFEnableUpdatePkgMapType))
    return
  end
  local IsDiffPkg = false
  local pakName = filestate.filename
  if filestate.diffFilename ~= nil then
    pakName = filestate.diffFilename
    local TmpPath = Client.ProjectSavedDir() .. "Paks/" .. pakName
    log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType TmpPath = " .. tostring(TmpPath))
    local TmpArrayData = {}
    table.insert(TmpArrayData, TmpPath)
    Client.USFSCacheSysContextUpdatePkgBinDiff(TmpArrayData)
  else
    pakName = filestate.filename
    log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType pakName = " .. tostring(pakName))
    if not Client.IsFileExistInCSCWithCheck(pakName) then
      local TmpPath = Client.ProjectSavedDir() .. "Paks/" .. pakName
      log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType TmpPath = " .. tostring(TmpPath))
      local TmpArrayData = {}
      table.insert(TmpArrayData, TmpPath)
      log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType TmpArrayData: " .. tostring(#TmpArrayData))
      Client.USFSCacheSysContextUpdatePkg(TmpArrayData)
    else
      log(bWriteLog and "PufferODPakManager:UFSSUpdatePkgMapType skip for Client.IsFileExistInCSCWithCheck pakName: " .. tostring(pakName))
    end
  end
end
function PufferODPakManager:UpdateExistPaks(existPaks)
  existPaks = existPaks or {}
  local ArrayData = Client.GetPkgsFromDir(true, "ODPaks")
  local isUFSNeedDelete = false
  local version = HDmpveRemote.HDmpveRemoteConfigGetString("PufferODPakVersion", "")
  if version ~= "" then
    local playerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
    local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
    local historyVersionData = playerPrefs.LoadFileToData_N(PlayerPrefsConfig.eODPakVersion) or {}
    log_format("PufferODPakManager:UpdateExistPaks. curVersion = %s, historyVersionData.version = %s", tostring(version), tostring(historyVersionData.version))
    if historyVersionData.version ~= version then
      historyVersionData.      playerPrefs.SaveDataToFile_N(historyVersionData, PlayerPrefsConfig.eODPakVersion)
      isUFSNeedDelete = true
      log(bWriteLog and "PufferODPakManager:UpdateExistPaks. isUFSNeedDelete = true")
    end
  end
  log_tree("UpdateExistPaks ArrayData = ", ArrayData)
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  PufferDeleteManager.ignoreFileDeleteNotify = true
  local deleteSize = PufferDownloader.uploadDeleteSize
  local uploadGemEvent = false
  if ArrayData then
    for i, v in ipairs(ArrayData) do
      if isUFSNeedDelete and existPaks[v] then
        PufferDeleteManager.DeletePak(v)
        log_format("PufferODPakManager:UpdateExistPaks. delete local file: %s", tostring(v))
        uploadGemEvent = true
      end
      existPaks[v] = true
    end
  end
  if uploadGemEvent then
    local diffSize = PufferDownloader.uploadDeleteSize - deleteSize
    PufferDownloader.uploadDeleteSize = deleteSize
    local param = {
      tostring(diffSize)
    }
    Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "DeleteODPakAlsoInCacheFile", param)
  end
  PufferDeleteManager.ignoreFileDeleteNotify = false
  if PufferDownloader.EnableBackpackCache then
    local UBackpackUtils = import("BackpackUtils")
    local startTime = slua.getMiliseconds()
    if UBackpackUtils.SetPaKExistMap then
      UBackpackUtils.SetPaKExistMap(existPaks)
    else
      PufferDownloader.ClearPakPathMap()
      for pakName, _ in pairs(existPaks) do
        log(bWriteLog and "PufferODPakManager:UpdateExistPaks. pakName = " .. tostring(pakName))
        PufferDownloader.SetPakExist(pakName, true)
      end
    end
    local costTimeInSet = slua.getMiliseconds() - startTime
    log(bWriteLog and "PufferODPakManager:UpdateExistPaks. SetPaKExistMap costTime = " .. tostring(costTimeInSet))
  end
  for packID, data in pairs(self.ODPaks) do
    for pakName, pakNameData in pairs(data.paks) do
      if existPaks[pakName] then
        pakNameData.state = PufferConst.ENUM_DownloadState.Done
        pakNameData.cSize = pakNameData.tSize
        data.curSize = data.curSize + pakNameData.tSize
        data.curCnt = data.curCnt + 1
      end
    end
    self:_UpdatePackDataState(data)
  end
  log(bWriteLog and "PufferODPakManager:UpdateExistPaks. End")
end
function PufferODPakManager:InitPretechODPaks(jsonODPaks, existPaks)
  log(bWriteLog and "PufferODPakManager:InitPretechODPaks start")
  if not jsonODPaks then
    return
  end
  for ODPackID, v in pairs(jsonODPaks) do
    self:InitODPack(v.fileList, tonumber(ODPackID), existPaks)
  end
  log(bWriteLog and "PufferODPakManager:InitPretechODPaks end")
end
function PufferODPakManager:InitUGCExpiredDepends()
  log(bWriteLog and "PufferODPakManager:InitUGCExpiredDepends start")
  local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
  local StringUtil = require("common.string_util")
  self.UGCExpiredDepends = {}
  local CurVersionExpiredAssetSet = CreativeExpiredAssetConfig.GetCurVersionExpiredAssetSet()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local Cfg
  if PublishRegionMacros.IsBLUEHOLE() then
    Cfg = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
  else
    Cfg = CDataTable.GetTable("UGCDelayPublishConfig")
  end
  for _, assetInfo in pairs(Cfg) do
    local assetId = assetInfo.AssetId
    if CurVersionExpiredAssetSet[assetId] and assetInfo and assetInfo.ExpiredFeatureKeys ~= "" then
      local ExpiredFeatureKeysItems = StringUtil.Split(assetInfo.ExpiredFeatureKeys, ";")
      for i, v in ipairs(ExpiredFeatureKeysItems) do
        local FeatureKey = tonumber(v)
        if FeatureKey then
          self.UGCExpiredDepends[FeatureKey] = true
        else
          self.UGCExpiredDepends[v] = true
        end
        log(bWriteLog and "PufferODPakManager:InitUGCExpiredDepends  Expired FeatureKey = " .. v)
      end
    end
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  for k, v in pairs(Config_UGC.ExpiredFeatureKeys) do
    self.UGCExpiredDepends[v] = true
    print(bWriteLog and "PufferODPakManager:InitUGCExpiredDepends CEVersion Expired FeatureKey = " .. v)
  end
end
function PufferODPakManager:InitVirtualODPack(id, paks, existPaks)
  for pakName, featureKey in pairs(paks) do
    local _, packData = self:GetPackDataByPakName(pakName)
    if packData then
      local data = packData.paks[pakName]
      packData.paks[pakName] = nil
      packData.totalCnt = packData.totalCnt - 1
      packData.totalSize = packData.totalSize - data.tSize
      if existPaks and existPaks[pakName] or data.state == PufferConst.ENUM_DownloadState.Done then
        packData.curCnt = packData.curCnt - 1
        packData.curSize = packData.curSize - data.cSize
        if packData.curSize <= 0 then
          packData.curSize = 0
        end
      end
    end
  end
  id = tonumber(id)
  local packData = {}
  self.ODPaks[id] = packData
  packData.paks = {}
  packData.curCnt = 0
  packData.totalCnt = 0
  packData.curSize = 0
  packData.totalSize = 0
  packData.state = PufferConst.ENUM_DownloadState.Not
  packData.isVirtual = true
  log(bWriteLog and "PufferODPakManager:InitVirtualODPack. id = " .. tostring(id))
  for pakName, featureKey in pairs(paks) do
    packData.totalCnt = packData.totalCnt + 1
    local pakData = self.PakDatas[pakName]
    if pakData then
      pakData.packID = id
      if existPaks and existPaks[pakName] then
        pakData.data.cSize = pakData.data.tSize
        pakData.data.state = PufferConst.ENUM_DownloadState.Done
        packData.curCnt = packData.curCnt + 1
      end
    else
      local tSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true) / PufferConst.MB
      pakData = {
        data = {
          tSize = tSize,
          state = PufferConst.ENUM_DownloadState.Not,
          cSize = 0
        },
        packID = id
      }
      if existPaks and existPaks[pakName] then
        pakData.data.cSize = pakData.data.tSize
        pakData.data.state = PufferConst.ENUM_DownloadState.Done
        packData.curCnt = packData.curCnt + 1
      end
      self.PakDatas[pakName] = pakData
    end
    log(bWriteLog and "PufferODPakManager:InitVirtualODPack. pakName = " .. tostring(pakName) .. ",featureKey = " .. tostring(featureKey))
    pakData.data.    packData.curSize = packData.curSize + pakData.data.cSize
    packData.totalSize = packData.totalSize + pakData.data.tSize
    packData.paks[pakName] = pakData.data
  end
end
function PufferODPakManager:_UpdatePackDataState(packData)
  if not packData then
    return
  end
  if packData.curCnt == packData.totalCnt then
    packData.state = PufferConst.ENUM_DownloadState.Done
  elseif packData.curCnt > 0 then
    packData.state = PufferConst.ENUM_DownloadState.Pause
  else
    packData.state = PufferConst.ENUM_DownloadState.Not
  end
end
function PufferODPakManager:IsIllegalTimeByODPackID(ODPackID)
  local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
  if not RecommendHandler.PaksDownloadTime or not next(RecommendHandler.PaksDownloadTime) then
    return true
  end
  if not self.ODPaks[ODPackID] then
    return false
  end
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  for pakName, v in pairs(self.ODPaks[ODPackID].paks) do
    if FBI.IsIllegalTime(pakName) then
      return true
    end
  end
  return false
end
function PufferODPakManager:JumpODPack(ODPackID)
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if UIManager.IsAndroidStackEmpty() and PufferSwitch.ODPackDownloadFinishPopUpSwitch then
    local canPop = true
    if not GameStatus.IsInLobbyOrMainCity() then
      canPop = false
    end
    local ODPackCfg = CDataTable.GetTableData("PakInfoTable", ODPackID)
    if ODPackCfg and ODPackCfg.DownloadFinishTipsID > 0 and canPop then
      do
        local jumpInfo = {}
        jumpInfo.texturePath = "/Game/UMG/Texture/Lobby_NoAtlas/UnknowPass/Koi/Koi_Tips_icon_Chicken.Koi_Tips_icon_Chicken"
        function jumpInfo.callback()
          if ODPackID == PufferConst.EODPackID.SocialLobby then
            local logic_lobby_social_scene = require("client.slua.logic.lobby.Left.logic_lobby_social_scene")
            logic_lobby_social_scene.MoveToPage(ENUM_LobbyPageType.Left)
          else
            GlobalData.JumpUrl(ODPackCfg.JumpURL)
          end
        end
        local cancelCallback = function()
          PufferSwitch.ODPackDownloadFinishPopUpSwitch = false
        end
        jumpInfo.        local content = LocUtil.LocalizeResFormat(ODPackCfg.DownloadFinishTipsID)
        local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
        RightPopSystem.ShowPopupTip(content, true, false, jumpInfo, 10)
      end
    end
  end
end
function PufferODPakManager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends)
  local resultState = PufferConst.ENUM_DownloadState.Done
  if Client.bEditorSkipDownload then
    return resultState
  end
  if not keyList then
    return resultState
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for i, v in pairs(keyList) do
    local state = PufferConst.ENUM_DownloadState.Done
    if downloadType == PufferConst.ENUM_DownloadType.ODPAK then
      local typeV = type(v)
      if typeV == "number" then
        state = self:GetStateByItemID(v)
      elseif typeV == "string" then
        if StringUtil.Starts(v, PufferConst.ODPAKS_RELATIVE_DIR) then
          state = self:GetStateByPakName(v)
        elseif StringUtil.Starts(v, PufferConst.PUFFERPATCH) then
          local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
          state = PufferResManager:GetState(v)
        elseif self:GetPakNamesByFeatureID(v) then
          local pakName = next(self:GetPakNamesByFeatureID(v))
          state = self:GetStateByPakName(pakName)
        else
          local PakNames = self:GetPakNameByTableKey(v)
          if PakNames then
            local PakList = {}
            for PakName, _ in pairs(PakNames) do
              table.insert(PakList, PakName)
            end
            state = self:GetStateByKeyList(downloadType, PakList, bSkipDepends, bSkipVidepDepends)
          else
            state = self:GetStateByPath(v)
          end
        end
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.ODPACK then
      state = self:GetStateByPackID(v)
    end
    resultState = PufferManager.GetMixDownloadState(resultState, state)
    if self.DebugPrintUGC and state ~= PufferConst.ENUM_DownloadState.Done then
      printf(bWriteLog and "[DebugPrintUGCRes] featureID or ItemID = %s , not done", v)
    end
  end
  return resultState
end
function PufferODPakManager:GetStateByPakName(pakName, skipCache)
  if Client.bEditorSkipDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  if pakName == nil or pakName == "" then
    return PufferConst.ENUM_DownloadState.Done
  end
  if pakName == PufferConst.CE_LOCK_PAKNAME then
    return PufferConst.ENUM_DownloadState.Done
  end
  if pakName == PufferConst.LOCK_PAKNAME then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = PufferConst.ENUM_DownloadState.Done
  if not skipCache then
    local pakNameData = self:GetPakDataByPakName(pakName)
    if pakNameData then
      state = pakNameData.state
      if state == PufferConst.ENUM_DownloadState.Done then
        return PufferConst.ENUM_DownloadState.Done
      end
    end
  end
  if puffer_queue:GetDownloadingTask(pakName) then
    return PufferConst.ENUM_DownloadState.Download
  end
  if puffer_queue:GetWaitTask(pakName) then
    return PufferConst.ENUM_DownloadState.Wait
  end
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return state
  end
  local isPakExist = PufferDownloader.GetPakExist(pakName, skipCache)
  if isPakExist then
    return PufferConst.ENUM_DownloadState.Done
  end
  return PufferConst.ENUM_DownloadState.Not
end
function PufferODPakManager:GetStateByPath(path)
  if Client.bEditorSkipDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  if path == nil or path == "" then
    return PufferConst.ENUM_DownloadState.Done
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local pakName = PufferManager.GetPakName(path)
  return self:GetStateByPakName(pakName)
end
function PufferODPakManager:GetStateByItemID(itemID)
  if Client.bEditorSkipDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return PufferConst.ENUM_DownloadState.Done
  end
  if self.itemToPaks[itemID] and self.itemToPaks[itemID].state == PufferConst.ENUM_DownloadState.Done then
    return PufferConst.ENUM_DownloadState.Done
  end
  local paks = self:GetPakNamesByItemID(itemID)
  local state = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for pakName, _ in pairs(paks) do
    local tempState = self:GetStateByPakName(pakName)
    state = PufferManager.GetMixDownloadState(state, tempState)
    if state == PufferConst.ENUM_DownloadState.Download then
      break
    end
  end
  self.itemToPaks[itemID].  return state
end
function PufferODPakManager:RestStateByItemID(itemID)
  log(bWriteLog and string.format("PufferODPakManager:RestStateByItemID. itemID=%s", tostring(itemID)))
  if not itemID then
    return
  end
  local state = PufferConst.ENUM_DownloadState.Done
  local paks = self:GetPakNamesByItemID(itemID)
  for pakName, _ in pairs(paks) do
    local pakState = self:GetStateByPakName(pakName, true)
    if pakState ~= PufferConst.ENUM_DownloadState.Done then
      state = PufferConst.ENUM_DownloadState.Not
    end
    local pufferPakData = self:GetPakDataByPakName(pakName)
    if pufferPakData then
      pufferPakData.state = pakState
    end
  end
  log(bWriteLog and "PufferODPakManager:RestStateByItemID. fix state = " .. tostring(state))
  local data = self.itemToPaks[itemID]
  if data then
    data.  end
end
function PufferODPakManager:GetStateByPackID(packID)
  if Client.bEditorSkipDownload then
    return PufferConst.ENUM_DownloadState.Done
  end
  local pack = self.ODPaks[packID]
  if not pack then
    if not PufferDownloader.PufferJsonDownloadReturn and not _G.IsEditor then
      return PufferConst.ENUM_DownloadState.Not
    end
    return PufferConst.ENUM_DownloadState.Done
  end
  if pack.curCnt == pack.totalCnt then
    pack.state = PufferConst.ENUM_DownloadState.Done
  end
  return pack.state
end
function PufferODPakManager:GetPakNamesByItemID(itemID)
  if Client.bEditorSkipDownload then
    return {}
  end
  if not itemID or itemID == 0 then
    return {}
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if self.itemToPaks[itemID] and self.itemToPaks[itemID].paks then
    return self.itemToPaks[itemID].paks
  end
  self.itemToPaks[itemID] = {}
  self.itemToPaks[itemID].paks = {}
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local list = self:GetBPPathsByItemID(itemID, itemCfg)
  for _, v in pairs(list) do
    local pakName = PufferManager.GetPakName(v)
    if pakName ~= "" then
      self.itemToPaks[itemID].paks[pakName] = true
    end
  end
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon and CDataTable.GetTableData("WeaponDIYList", itemID) and self.ODPaks[PufferConst.EODPackID.DIY] then
    for i, v in pairs(self.ODPaks[PufferConst.EODPackID.DIY].paks) do
      self.itemToPaks[itemID].paks[i] = true
      log(bWriteLog and string.format("PufferODPakManager:GetPakNamesByItemID diy pak:%s", i))
    end
  end
  PufferManager.InitResourcePatchCfg()
  local version = PufferManager.resourcePatchCfg[itemID]
  if version then
    self.itemToPaks[itemID].paks[PufferConst.PUFFERPATCH .. "_" .. version .. ".pak"] = true
    log_format("PufferODPakManager:GetPakNamesByItemID. itemID=%s, version=%s", itemID, version)
  end
  return self.itemToPaks[itemID].paks
end
function PufferODPakManager:GetPakNamesByFeatureID(featureID)
  if not featureID or featureID == "" then
    return nil
  end
  if self.UGCExpiredDepends and self.UGCExpiredDepends[featureID] then
    print(bWriteLog and "PufferODPakManager:GetPakNamesByFeatureID featureID:%s is expired " .. tostring(featureID))
    return nil
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if self.itemToPaks[featureID] and self.itemToPaks[featureID].paks then
    return self.itemToPaks[featureID].paks
  end
  local FeatureAssetPathTable = CDataTable.GetTableData("FeatureAssetPathTable", featureID)
  if not FeatureAssetPathTable then
    return nil
  end
  local BPPath = FeatureAssetPathTable.Path
  if not BPPath or BPPath == "" then
    return nil
  end
  self.itemToPaks[featureID] = {}
  self.itemToPaks[featureID].paks = {}
  local pakName = ""
  local StringUtil = require("common.string_util")
  if StringUtil.Ends(BPPath, ".mp4") then
    pakName = PufferManager.GetPakNameByVideoPath(BPPath)
  else
    pakName = PufferManager.GetPakName(BPPath)
  end
  if pakName ~= "" then
    self.itemToPaks[featureID].paks[pakName] = true
  else
    log(bWriteLog and "pakName is nil, BPPath = " .. BPPath)
  end
  return self.itemToPaks[featureID].paks
end
function PufferODPakManager:GetPakNamesByODPakID(ODPackD)
  if self.isInitODPakData then
    log_error("PufferODPakManager:GetPakNamesByODPakID isInitODPaks = true")
    return {}
  end
  if not ODPackD or ODPackD == 0 then
    return {}
  end
  if self.ODPaks[ODPackD] and self.ODPaks[ODPackD].paks then
    return self.ODPaks[ODPackD].paks
  end
  return {}
end
function PufferODPakManager:GetPakNameByTableKey(Key)
  if not Key or Key == "" then
    return nil
  end
  local Array = StringUtil.Split(Key, ".")
  if #Array < 3 then
    return nil
  end
  local SheetName = Array[1]
  local ColName = Array[2]
  local Type = Array[3]
  if not (SheetName and ColName) or not Type then
    printf(bWriteLog and "PufferODPakManager:GetPakNameByTableKey Key:%s is invalid", Key)
    return nil
  end
  if self.TableKeyToPaks and self.TableKeyToPaks[Key] then
    return self.TableKeyToPaks[Key]
  end
  local tableConfig = CDataTable.GetTable(SheetName)
  if not tableConfig then
    printf(bWriteLog and "PufferODPakManager:GetPakNameByTableKey SheetName:%s is invalid", SheetName)
    return nil
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local AllPakNames
  local TypeEnumDefine = {
    Path = 1,
    AssetID = 2,
    ItemID = 3
  }
  local TypeEnum = TypeEnumDefine[Type]
  if not TypeEnum then
    printf(bWriteLog and "PufferODPakManager:GetPakNameByTableKey Type:%s is invalid", Type)
    return nil
  end
  for index, value in pairs(tableConfig) do
    local Item = value[ColName]
    if Item then
      if TypeEnum == TypeEnumDefine.Path then
        local PakName = PufferManager.GetPakName(Item)
        if PakName and PakName ~= "" then
          AllPakNames = AllPakNames or {}
          AllPakNames[PakName] = true
        end
      elseif TypeEnum == TypeEnumDefine.AssetID then
        local PakNames = PufferUGCPakManager:GetPakNamesByAssetID(tonumber(Item))
        for PakName, v in pairs(PakNames) do
          if PakName and PakName ~= "" then
            AllPakNames = AllPakNames or {}
            AllPakNames[PakName] = true
          end
        end
      elseif TypeEnum == TypeEnumDefine.ItemID then
        local PakNames = self:GetPakNamesByItemID(tonumber(Item))
        for PakName, v in pairs(PakNames) do
          if PakName and PakName ~= "" then
            AllPakNames = AllPakNames or {}
            AllPakNames[PakName] = true
          end
        end
      end
    end
  end
  if AllPakNames then
    self.TableKeyToPaks = self.TableKeyPaks or {}
    self.TableKeyToPaks[Key] = AllPakNames
  end
  return AllPakNames
end
function PufferODPakManager:GetIconPathsByItemID(itemID, pathList, itemCfg)
  pathList = pathList or {}
  if not (itemID and tonumber(itemID)) or tonumber(itemID) <= 0 then
    return pathList
  end
  if itemCfg then
    if itemCfg.ItemSmallIcon and itemCfg.ItemSmallIcon ~= "" then
      table.insert(pathList, itemCfg.ItemSmallIcon)
    end
    if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Bubble_Emote then
      local cfg = CDataTable.GetTableData("IngameBubbleCfg", itemID)
      if cfg and cfg.BubbleEffectIcon and cfg.BubbleEffectIcon ~= "" then
        table.insert(pathList, cfg.BubbleEffectIcon)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Weapon then
      local posterCfg = CDataTable.GetTableData("RareItemSharePosterList", itemID)
      if posterCfg and posterCfg.Poster and posterCfg.Poster ~= "" then
        table.insert(pathList, posterCfg.Poster)
      end
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local UpgradeCfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
      if UpgradeCfg and UpgradeCfg.GroupID and 0 < UpgradeCfg.GroupID then
        local groupId = UpgradeCfg.GroupID
        local UpgradeTableCfg = ItemUpgradeMgr:GetUpgradeGroupByID(groupId)
        for _, cfg in pairs(UpgradeTableCfg) do
          if cfg.EffectBg ~= "" then
            table.insert(pathList, cfg.EffectBg)
          end
        end
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.VehicleApplique then
      local vehicleAppliqueCfg = CDataTable.GetTableData("VehicleAppliqueCfg", itemID)
      if vehicleAppliqueCfg and vehicleAppliqueCfg.AppliquePath and vehicleAppliqueCfg.AppliquePath ~= "" then
        table.insert(pathList, vehicleAppliqueCfg.AppliquePath)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Spray_Pattern or itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Home_Spray_Pattern then
      local decalConfig = CDataTable.GetTableData("DecalBPTable", itemID)
      if decalConfig ~= nil then
        table.insert(pathList, decalConfig.DefaultTexturePath)
      end
    end
  end
  local rareCfg = CDataTable.GetTableData("RareItemCfg", itemID)
  if rareCfg then
    if rareCfg.Path and rareCfg.Path ~= "" then
      table.insert(pathList, rareCfg.Path)
    end
    if rareCfg.PathIcon and rareCfg.PathIcon ~= "" then
      table.insert(pathList, rareCfg.PathIcon)
    end
    if rareCfg.CornerPath and rareCfg.CornerPath ~= "" then
      table.insert(pathList, rareCfg.CornerPath)
    end
  end
  return pathList
end
function PufferODPakManager:GetBPPathsByItemID(itemID, itemCfg)
  local BPMapping = self:_GetRelatedItems(itemID, itemCfg, nil)
  local list = {}
  local containSelf = false
  for _, v in pairs(BPMapping) do
    local id = tonumber(v)
    if id == itemID then
      containSelf = true
    end
    local cfg = CDataTable.GetTableData("Item", id)
    local bpID, jkbpID = self:_GetItemBPID(id, cfg)
    local path = self:GetItemBPPathByItemID(id, cfg, bpID)
    if path and path ~= "" then
      table.insert(list, path)
    end
    if jkbpID ~= 0 then
      local path = self:GetItemBPPathByItemID(id, cfg, jkbpID)
      if path and path ~= "" then
        table.insert(list, path)
      end
    end
    local lobbyPath = self:_GetItemLobbyPathByBPID(id, cfg, bpID, list)
    if lobbyPath and lobbyPath ~= "" then
      table.insert(list, lobbyPath)
    end
    local mapCfg = CDataTable.GetTableData("BPMappingTable", id)
    if mapCfg and mapCfg.ActorMapping and mapCfg.ActorMapping ~= "" then
      local actorIDMap = StringUtil.Split(mapCfg.ActorMapping, "|")
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      for i, actorIDStr in pairs(actorIDMap) do
        local actorID = tonumber(actorIDStr)
        if actorID and 0 < actorID then
          local bankPath = ActorVoiceSystem.GetBankPathByActorID(actorID)
          if bankPath and bankPath ~= "" then
            table.insert(list, bankPath)
          end
        end
      end
    end
    local ItemType = cfg and cfg.ItemType
    local ItemSubType = cfg and cfg.ItemSubType
    if ItemType == ENUM_ITEM_TYPE.Vehicle or ItemType == ENUM_ITEM_TYPE.Extra then
      local vehicleAnimData = CDataTable.GetTableData("InGameAnimDataTable", id)
      if vehicleAnimData and vehicleAnimData.ID and vehicleAnimData.ID ~= "" then
        table.insert(list, vehicleAnimData.DataAssetPath)
      end
    end
    if ItemType == ENUM_ITEM_TYPE.Weapon then
      local fxData = CDataTable.GetTableData("AvatarWeaponHitFXData", id)
      if fxData and fxData.EffectPath ~= "" then
        table.insert(list, fxData.EffectPath)
      end
      local UpgradeEffectUtil = require("client.slua.umg.upgrade.UpgradeEffectUtil")
      local UpgradeEffectPathList = UpgradeEffectUtil:GetAllRelatedResPathByWeaponID(id)
      for _, v in pairs(UpgradeEffectPathList) do
        table.insert(list, v)
      end
    end
    if ItemType == ENUM_ITEM_TYPE.Weapon or ItemSubType == ENUM_ITEM_SUBTYPE.Grenade_612 or ItemSubType == ENUM_ITEM_SUBTYPE.Grenade_614 or ItemType == ENUM_ITEM_TYPE.Extra or ItemType == ENUM_ITEM_TYPE.Vehicle then
      local LogicKillInfo = require("client.slua.logic.kill_info.logic_killinfo")
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      local KillBroadcastData = {}
      if LogicXSuit.IsXSuit(itemID) then
        KillBroadcastData = LogicKillInfo.GetXSuitKillInfoAssetList(itemID)
      else
        KillBroadcastData = LogicKillInfo.GetWeaponKillInfoAssetList(itemID)
      end
      if KillBroadcastData and next(KillBroadcastData) then
        for _, v in pairs(KillBroadcastData) do
          if v and v ~= "" then
            table.insert(list, v)
          end
        end
      end
    end
    list = self:GetIconPathsByItemID(id, list, cfg)
  end
  local BPMappingTable = CDataTable.GetTableData("BPMappingTable", itemID)
  if BPMappingTable and BPMappingTable.DependPath and BPMappingTable.DependPath ~= "" then
    local arrDependPaths = StringUtil.Split(BPMappingTable.DependPath, "|")
    for _, v in pairs(arrDependPaths) do
      if v and v ~= "" then
        table.insert(list, v)
      end
    end
  end
  if not containSelf then
    list = self:GetIconPathsByItemID(itemID, list, itemCfg)
  end
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Partner_Stance and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.PartnerStance then
    local intimacyPoseMapping = CDataTable.GetTableData("IntimacyPoseMapping", itemID)
    if intimacyPoseMapping and intimacyPoseMapping.PoseType then
      local IntimacyPoseConfig = CDataTable.GetTableData("IntimacyPose", intimacyPoseMapping.PoseType)
      if IntimacyPoseConfig then
        if IntimacyPoseConfig.MeshPath ~= "" then
          table.insert(list, IntimacyPoseConfig.MeshPath)
        end
        if IntimacyPoseConfig.MeshAnimPath ~= "" then
          table.insert(list, IntimacyPoseConfig.MeshAnimPath)
        end
        table.insert(list, IntimacyPoseConfig.LeftPose)
        table.insert(list, IntimacyPoseConfig.RightPose)
        table.insert(list, IntimacyPoseConfig.LeftAnimation)
        table.insert(list, IntimacyPoseConfig.RightAnimation)
      end
    end
  end
  if itemCfg then
    if itemCfg.ItemType == ENUM_ITEM_TYPE.Home then
      local cfg = CDataTable.GetTableData("PlanPH_StructureItemCfg", itemID)
      if cfg and cfg.BPPath then
        table.insert(list, cfg.BPPath)
      end
      cfg = CDataTable.GetTableData("PlanPH_DecorateItemCfg", itemID)
      if cfg and cfg.BPPath then
        table.insert(list, cfg.BPPath)
        if cfg.DependBPPath and cfg.DependBPPath ~= "" then
          table.insert(list, cfg.DependBPPath)
        end
      end
      cfg = CDataTable.GetTableData("PlanPH_WallpaperItemCfg", itemID)
      if cfg and cfg.MatPath then
        table.insert(list, cfg.MatPath)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Aid_Gift then
      local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
      local giftData = logic_send_gift.GetGiftDataByResID(itemID)
      if giftData then
        table.insert(list, giftData.GiftAni)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Vehicle then
      local LogicVehicleResDependencyUtil = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleResDependencyUtil)
      local parachutePropertyBPPath = LogicVehicleResDependencyUtil:GetVehicleParachutePropertyBPPath(itemID)
      if parachutePropertyBPPath and parachutePropertyBPPath ~= "" then
        table.insert(list, parachutePropertyBPPath)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.Buddy then
      local cfg = CDataTable.GetTableData("PetLevelTable", itemID * 10000 + 1)
      if cfg then
        if cfg.LobbyPetBP ~= "" then
          table.insert(list, cfg.LobbyPetBP)
        end
        if cfg.PetCharacter ~= "" then
          table.insert(list, cfg.PetCharacter)
        end
        if cfg.PetFPPCharacter ~= "" then
          table.insert(list, cfg.PetFPPCharacter)
        end
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.MVPEmotion and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.MVPIcon then
      local cfg = CDataTable.GetTableData("MVPImprintTable", itemID)
      if cfg and cfg.PreviewPath then
        table.insert(list, cfg.PreviewPath)
        table.insert(list, cfg.Path)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.MVPEmotion and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.MVPAction then
      local cfg = CDataTable.GetTableData("MVPActionInfo", itemID)
      if cfg and cfg.LevelPath ~= "" then
        table.insert(list, cfg.LevelPath)
      end
    elseif itemCfg.ItemType == ENUM_ITEM_TYPE.ClickEffect and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.ClickEffect then
      local cfg = CDataTable.GetTableData("ClickEffectConfig", itemID)
      if cfg and cfg.EffectPath and cfg.EffectPath ~= "" then
        table.insert(list, cfg.EffectPath)
      end
    end
  end
  return list
end
function PufferODPakManager:CheckAutoDownloadByItemID(itemID)
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return false
  end
  local paks = self:GetPakNamesByItemID(itemID)
  local isAuto = false
  for pakName, _ in pairs(paks) do
    if self:CheckAutoDownloadByPakName(pakName) then
      isAuto = true
      break
    end
  end
  return isAuto
end
function PufferODPakManager:CheckAutoDownloadByPakName(pakName)
  if pakName == "" then
    return false
  end
  if pakName == PufferConst.CE_LOCK_PAKNAME then
    return false
  end
  if pakName == PufferConst.LOCK_PAKNAME then
    return false
  end
  return puffer_queue:CheckAutoDownloadTask(pakName)
end
function PufferODPakManager:GetSizeByKeyList(downloadType, keyList, bSkipDepends)
  local curSize = 0
  local totalSize = 0
  if not keyList then
    return curSize, totalSize
  end
  if downloadType == PufferConst.ENUM_DownloadType.ODPAK and 1 < #keyList then
    local bAllItemID = true
    for i, v in pairs(keyList) do
      if type(v) ~= "number" then
        bAllItemID = false
        break
      end
    end
    if bAllItemID then
      return self:GetSizeByItemIDList(keyList)
    end
  end
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.ODPAK then
      local valType = type(v)
      if valType == "number" then
        local cSize, tSize = self:GetSizeByItemID(v)
        curSize = curSize + cSize
        totalSize = totalSize + tSize
      elseif valType == "string" then
        if StringUtil.Starts(v, PufferConst.ODPAKS_RELATIVE_DIR) then
          local cSize, tSize = self:GetSizeByPakName(v)
          curSize = curSize + cSize
          totalSize = totalSize + tSize
        elseif StringUtil.Starts(v, PufferConst.PUFFERPATCH) then
          local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
          local cSize, tSize = PufferResManager:GetSize(v)
          curSize = curSize + cSize
          totalSize = totalSize + tSize
        elseif self:GetPakNamesByFeatureID(v) then
          local pakName = next(self:GetPakNamesByFeatureID(v))
          local cSize, tSize = self:GetSizeByPakName(pakName)
          curSize = curSize + cSize
          totalSize = totalSize + tSize
        else
          local PakNames = self:GetPakNameByTableKey(v)
          if PakNames then
            for pakName, _ in pairs(PakNames) do
              local cSize, tSize = self:GetSizeByPakName(pakName)
              curSize = curSize + cSize
              totalSize = totalSize + tSize
            end
          else
            local cSize, tSize = self:GetSizeByPath(v)
            curSize = curSize + cSize
            totalSize = totalSize + tSize
          end
        end
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.ODPACK then
      local cSize, tSize = self:GetSizeByPackID(v)
      curSize = curSize + cSize
      totalSize = totalSize + tSize
    end
  end
  return curSize, totalSize
end
function PufferODPakManager:GetSizeByItemIDList(itemIDList)
  local cSize = 0
  local tSize = 0
  local allPaks = {}
  for i, v in pairs(itemIDList) do
    local paks = self:GetPakNamesByItemID(v)
    for pakName, _ in pairs(paks) do
      allPaks[pakName] = true
    end
  end
  for pakName, _ in pairs(allPaks) do
    local flag = false
    local pakData = self:GetPakDataByPakName(pakName)
    if pakData then
      flag = true
      cSize = cSize + pakData.cSize * PufferConst.MB
      tSize = tSize + pakData.tSize * PufferConst.MB
    end
    if not flag then
      tSize = tSize + PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
    end
  end
  return cSize, tSize
end
function PufferODPakManager:GetSizeByItemID(itemID)
  local cSize = 0
  local tSize = 0
  local paks = self:GetPakNamesByItemID(itemID)
  for pakName, _ in pairs(paks) do
    local flag = false
    local pakData = self:GetPakDataByPakName(pakName)
    if pakData then
      flag = true
      cSize = cSize + pakData.cSize * PufferConst.MB
      tSize = tSize + pakData.tSize * PufferConst.MB
    end
    if not flag then
      tSize = tSize + PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
    end
  end
  if self:GetStateByItemID(itemID) == PufferConst.ENUM_DownloadState.Done then
    cSize = tSize
  end
  return cSize, tSize
end
function PufferODPakManager:GetSizeByPath(path)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local cSize, tSize = 0, 0
  local pakName = PufferManager.GetPakName(path)
  cSize, tSize = self:GetSizeByPakName(pakName)
  return cSize, tSize
end
function PufferODPakManager:GetSizeByPakName(pakName)
  local cSize, tSize = 0, 0
  if pakName == nil or pakName == "" then
    return 0, 0
  end
  local pakNameData = self:GetPakDataByPakName(pakName)
  if pakNameData then
    cSize = pakNameData.cSize * PufferConst.MB
    tSize = pakNameData.tSize * PufferConst.MB
  end
  if tSize == 0 then
    tSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
    local MinSize = PufferConst.MB * 0.1
    if tSize == 0 then
      tSize = MinSize
    end
  end
  if self:GetStateByPakName(pakName) == PufferConst.ENUM_DownloadState.Done then
    cSize = tSize
  end
  return cSize, tSize
end
function PufferODPakManager:GetSizeByPackID(packID)
  local pack = self.ODPaks[packID]
  if not pack then
    return 0, 0
  end
  if pack.isVirtual and 0 >= pack.totalSize then
    for pakName, _ in pairs(pack.paks) do
      local tSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
      pack.totalSize = pack.totalSize + tSize / PufferConst.MB
    end
  end
  return pack.curSize, pack.totalSize
end
function PufferODPakManager:GetAllODPakCurSize(skipIDs)
  local curSize = 0
  local totalSize = 0
  local state = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for packID, v in pairs(self.ODPaks) do
    if not skipIDs or not skipIDs[packID] then
      curSize = curSize + v.curSize
      totalSize = totalSize + v.totalSize
      if v.curSize > v.totalSize then
        log(bWriteLog and "PufferODPakManager:GetAllODPakCurSize. packID = " .. tostring(packID))
      end
      state = PufferManager.GetMixDownloadState(state, v.state)
    end
  end
  log(bWriteLog and string.format("PufferODPakManager:GetAllODPakCurSize. curSize=%s, totalSize=%s, state=%s", tostring(curSize), tostring(totalSize), tostring(state)))
  return curSize, totalSize, state
end
function PufferODPakManager:ResetPakData(pakName)
  local deleteSize = 0
  PufferDownloader.ClearPakCache(pakName)
  if self.needRecoverBattleData then
    self.battleDeleteFiles[pakName] = true
  else
    local ENUM_DownloadState = PufferConst.ENUM_DownloadState
    local packID, packData = self:GetPackDataByPakName(pakName)
    if packID and packData then
      local pakData = packData.paks[pakName]
      if pakData then
        if pakData.state == ENUM_DownloadState.Done then
          if 0 < packData.curCnt then
            packData.curCnt = packData.curCnt - 1
            packData.curSize = packData.curSize - pakData.tSize
            deleteSize = deleteSize + pakData.tSize
          end
          if packData.curCnt == 0 then
            packData.curSize = 0
            packData.state = ENUM_DownloadState.Not
          elseif packData.curCnt < packData.totalCnt then
            packData.state = ENUM_DownloadState.Pause
          end
          pakData.state = ENUM_DownloadState.Not
        end
        pakData.cSize = 0
        pakData.haveDeleted = true
      end
    end
  end
  return deleteSize
end
function PufferODPakManager:RemovePakData(pakName)
  log(bWriteLog and string.format("PufferODPakManager:RemovePakData. pakName=%s", tostring(pakName)))
  local packID, packData = self:GetPackDataByPakName(pakName)
  if packID and packData then
    local pakData = packData.paks[pakName]
    if pakData then
      local subFinishCnt = 0
      if pakData.state == PufferConst.ENUM_DownloadState.Done then
        subFinishCnt = 1
      end
      packData.curCnt = packData.curCnt - subFinishCnt
      packData.totalCnt = packData.totalCnt - 1
      packData.curSize = packData.curSize - pakData.cSize
      packData.totalSize = packData.totalSize - pakData.tSize
      log(bWriteLog and "PufferODPakManager:RemovePakData. packData.curCnt = " .. tostring(packData.curCnt))
      log(bWriteLog and "PufferODPakManager:RemovePakData. packData.totalCnt = " .. tostring(packData.totalCnt))
      if packData.curCnt == packData.totalCnt then
        packData.state = PufferConst.ENUM_DownloadState.Done
      end
      self.PakDatas[pakName] = nil
    end
  end
end
function PufferODPakManager:_GetItemBPID(itemID, itemCfg)
  local BPID = itemID
  local JKBPID = 0
  if itemCfg then
    if 0 < itemCfg.BPID and itemCfg.BPID ~= itemID then
      BPID = itemCfg.BPID
    end
    if self.IsJapanOrKorea and itemCfg.JKBPID and 0 < itemCfg.JKBPID and itemCfg.JKBPID ~= BPID then
      JKBPID = itemCfg.JKBPID
    end
  end
  return BPID, JKBPID
end
function PufferODPakManager:GetItemBPPathByItemID(itemID, itemCfg, bpID)
  if self.itemToPaths[itemID] and self.itemToPaths[itemID] ~= "" then
    return self.itemToPaths[itemID]
  end
  if not itemCfg then
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    local bankPath = ActorVoiceSystem.GetBankPathByActorID(itemID)
    if bankPath then
      self.itemToPaths[itemID] = bankPath
      return bankPath
    end
    return nil
  end
  local itemType = itemCfg.ItemType
  local bpCfg = CDataTable.GetTableData("AvatarBPTable", bpID)
  if bpCfg ~= nil then
    self.itemToPaths[itemID] = bpCfg.AvatarBPPath
    return bpCfg.AvatarBPPath
  end
  if itemType == ENUM_ITEM_TYPE.Weapon then
    bpCfg = CDataTable.GetTableData("WeaponDIYList", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.MeshPath
      return bpCfg.MeshPath
    end
    bpCfg = CDataTable.GetTableData("WeaponBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.Aircraft_Skin or itemType == ENUM_ITEM_TYPE.Wingman_Skin then
    bpCfg = CDataTable.GetTableData("PlaneBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.Vehicle then
    bpCfg = CDataTable.GetTableData("VehicleBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.Buddy or itemType == ENUM_ITEM_TYPE.Buddy_New then
    bpCfg = CDataTable.GetTableData("PetDressBlueprintTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.Career then
    bpCfg = CDataTable.GetTableData("CareerBPTable", bpID)
    if bpCfg then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item then
    bpCfg = CDataTable.GetTableData("GiftBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.GiftAniPath
      return bpCfg.GiftAniPath
    end
  elseif itemType == ENUM_ITEM_TYPE.Hall_Theme then
    bpCfg = CDataTable.GetTableData("HallThemeItem", bpID)
    if bpCfg then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.CasualShop or itemType == ENUM_ITEM_TYPE.WowEffect then
    bpCfg = CDataTable.GetTableData("EffectItemBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  elseif itemType == ENUM_ITEM_TYPE.PetSwitchEffect then
    bpCfg = CDataTable.GetTableData("PetSwitchEffectBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  end
  if itemType == ENUM_ITEM_TYPE.Spray_Pattern or itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Home_Spray_Pattern then
    bpCfg = CDataTable.GetTableData("DecalBPTable", bpID)
    if bpCfg ~= nil then
      self.itemToPaths[itemID] = bpCfg.Path
      return bpCfg.Path
    end
  end
  bpCfg = CDataTable.GetTableData("ConsumableBPTable", bpID)
  if bpCfg ~= nil then
    self.itemToPaths[itemID] = bpCfg.Path
    return bpCfg.Path
  end
  bpCfg = CDataTable.GetTableData("EmoteBPTable", bpID)
  if bpCfg ~= nil then
    self.itemToPaths[itemID] = bpCfg.Path
    return bpCfg.Path
  end
  bpCfg = CDataTable.GetTableData("3DIconBPTable", bpID)
  if bpCfg ~= nil then
    self.itemToPaths[itemID] = bpCfg.Path
    return bpCfg.Path
  end
  if itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Voice_Pack or itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Electronic_Eecord then
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    local path = ActorVoiceSystem.GetBankPath(itemID)
    self.itemToPaths[itemID] = path
    return path
  end
  return nil
end
function PufferODPakManager:_InitAttachmentSkinIDListCache()
  if self._attachmentSkinIDInited then
    return
  end
  log(bWriteLog and "PufferODPakManager:_InitAttachmentSkinIDListCache.")
  self._attachmentSkinIDMap = {}
  self._attachmentSkinIDInited = true
  local cfgs = CDataTable.GetTable("WeaponAttrBPTable")
  for BPID, cfg in pairs(cfgs) do
    local list = self:_GetAttachmentSkinIDListByConfig(cfg)
    self._attachmentSkinIDMap[BPID] = list
  end
end
function PufferODPakManager:_GetAttachmentSkinIDListByConfig(cfg)
  if cfg == nil then
    return nil
  end
  local idList = {}
  if cfg.AttachmentSkinIDList and cfg.AttachmentSkinIDList ~= "" then
    for i, v in pairs(StringUtil.Split(cfg.AttachmentSkinIDList, "|")) do
      local attachmentSkinID = StringUtil.Split(v, "-")[2]
      table.insert(idList, tonumber(attachmentSkinID))
    end
  end
  if cfg.PendantID > 0 then
    table.insert(idList, cfg.PendantID)
  end
  if cfg.DeadInventoryBoxIDs and cfg.DeadInventoryBoxIDs ~= "" then
    for i, v in pairs(StringUtil.Split(cfg.DeadInventoryBoxIDs, "|")) do
      table.insert(idList, tonumber(v))
    end
  end
  if not next(idList) then
    idList = nil
  end
  return idList
end
function PufferODPakManager:_GetAttachmentSkinIDList(BPID)
  if self.isLowMemoryDevice then
    local cfg = CDataTable.GetTableData("WeaponAttrBPTable", BPID)
    return cfg and self:_GetAttachmentSkinIDListByConfig(cfg)
  else
    self:_InitAttachmentSkinIDListCache()
    return self._attachmentSkinIDMap and self._attachmentSkinIDMap[BPID]
  end
end
function PufferODPakManager:_GetRelatedItems(itemID, itemCfg, bNotMapping)
  if self.itemToItems[itemID] then
    return self.itemToItems[itemID]
  end
  local depend = {}
  if not itemCfg then
    if CDataTable.GetTableData("VoiceActorCfg", itemID) then
      self.itemToItems[itemID] = {itemID}
      return {itemID}
    end
    return depend
  end
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  local attachmentSkinIDList = self:_GetAttachmentSkinIDList(itemCfg.BPID)
  local BackpackMappingCfg = CDataTable.GetTableData("BackpackMapping", itemID)
  local ItemType = itemCfg.ItemType
  if BackpackMappingCfg then
    depend[BackpackMappingCfg.SkinItemIDLv1] = true
    depend[BackpackMappingCfg.SkinItemIDLv2] = true
    depend[BackpackMappingCfg.SkinItemIDLv3] = true
    depend[BackpackMappingCfg.LobbyShowItemID] = true
  elseif ModelDisplayTypeHelper.IsWeapon(ItemType) then
    local upgradeCfgList = ItemUpgradeMgr:GetUpgradeGroupByItemID(itemID)
    if upgradeCfgList and next(upgradeCfgList) then
      local upgradeItemID = 0
      for _, v in pairs(upgradeCfgList) do
        if upgradeItemID == 0 then
          upgradeItemID = v.itemID
        end
        depend[v.ItemID] = true
        local list = self:_GetAttachmentSkinIDList(v.ItemID)
        if list then
          for _, vv in pairs(list) do
            depend[vv] = true
          end
        end
      end
      local groupID = ItemUpgradeMgr:GetUpgradeCfg(upgradeItemID).GroupID
      groupID = ItemUpgradeMgr:GetNormalGroupID(groupID)
      log(bWriteLog and string.format("PufferODPakManager:_GetRelatedItems groupdId=%s", tostring(groupID)))
      local partIDList = ItemUpgradeMgr:GetPartIDList(groupID)
      local isCanSetRefitCfg = ItemUpgradeMgr:IsCanSetRefitCfgTableInfo(groupID)
      for _, partID in pairs(partIDList) do
        if isCanSetRefitCfg then
          local diffColorPartID = ItemUpgradeMgr:PartIDSwitch(partID, true)
          if diffColorPartID ~= partID and diffColorPartID then
            depend[diffColorPartID] = true
          end
        end
        depend[partID] = true
      end
      if isCanSetRefitCfg then
        local refitCfg = ItemUpgradeMgr:GetRefitCfgData(groupID)
        if refitCfg and refitCfg.refitGroupID then
          local refitUpgradeCfgList = ItemUpgradeMgr:GetUpgradeGroupByID(refitCfg.refitGroupID)
          if refitUpgradeCfgList then
            for _, v in pairs(refitUpgradeCfgList) do
              depend[v.ItemID] = true
              local list = self:_GetAttachmentSkinIDList(v.ItemID)
              if list then
                for _, vv in pairs(list) do
                  depend[vv] = true
                end
              end
            end
          end
        end
      end
    elseif attachmentSkinIDList then
      for i, v in pairs(attachmentSkinIDList) do
        depend[v] = true
      end
    end
  elseif attachmentSkinIDList then
    for i, v in pairs(attachmentSkinIDList) do
      depend[v] = true
    end
  end
  local cfg
  if ItemType == ENUM_ITEM_TYPE.Weapon then
    cfg = CDataTable.GetTableData("WeaponSkinMapping", itemID)
    if cfg then
      depend[cfg.WeaponID] = true
    end
  end
  cfg = CDataTable.GetTableData("VehiclePlaneSkinMapping", itemID)
  if cfg then
    depend[cfg.OrginalID] = true
  end
  if ItemType == ENUM_ITEM_TYPE.Extra then
    cfg = CDataTable.GetTableData("AvatarSuitsTable", itemID)
    if cfg then
      for _, v in pairs(StringUtil.Split(cfg.MaleSuits, "|")) do
        local id = tonumber(v)
        if id and 0 < id then
          depend[id] = true
        end
      end
      for _, v in pairs(StringUtil.Split(cfg.FemaleSuits, "|")) do
        local id = tonumber(v)
        if id and 0 < id then
          depend[id] = true
        end
      end
    end
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    local period = LogicXSuit.GetPeriodByItemId(itemID)
    if period then
      local goldList = LogicXSuit.GetItemIDListByPeriod(period)
      for _, v in pairs(goldList) do
        depend[v] = true
      end
      local CallStatueActionIDMap = {
        [3] = 12219840,
        [4] = 12219841,
        [5] = 12219842
      }
      local actionID = CallStatueActionIDMap[period]
      if actionID then
        depend[actionID] = true
      end
    end
  end
  local featuresItem = CDataTable.GetTableData("FeaturesItems", itemID)
  if featuresItem then
    local version_util = require("client.common.version_util")
    local versionNum = version_util.GetCurVersionNumber()
    local features = StringUtil.Split(featuresItem.Features, ";")
    for _, v in ipairs(features) do
      if v then
        local featureCfg = CDataTable.GetTableData("FeaturesConfig", tonumber(v))
        if featureCfg then
          if featureCfg.ExpressionID and 0 < featureCfg.ExpressionID then
            depend[featureCfg.ExpressionID] = true
          end
          if featureCfg.EnterExpressionID and 0 < featureCfg.EnterExpressionID and featureCfg.EnterExpressionID ~= featureCfg.ExpressionID then
            depend[featureCfg.EnterExpressionID] = true
          end
          if featureCfg.FightExpressionID and 0 < featureCfg.FightExpressionID and featureCfg.FightExpressionID ~= featureCfg.EnterExpressionID then
            depend[featureCfg.FightExpressionID] = true
          end
        end
      end
    end
  end
  cfg = CDataTable.GetTableData("EmoteBPTable", itemID)
  if cfg and cfg.LobbyEmoteAdapt ~= "" then
    for _, v in pairs(StringUtil.Split(cfg.LobbyEmoteAdapt, "|")) do
      local id = tonumber(v)
      if id and 0 < id then
        depend[id] = true
      end
    end
  end
  if ModelDisplayTypeHelper.IsGlide(itemCfg.ItemSubType) then
    local GlideBattleID, isGlideLobbyID = GlideSystem:ConvertToBattleID(itemID)
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if isGlideLobbyID then
      depend[GlideBattleID] = true
    end
    local SpecialGlideID = LogicXSuit.GetSpecialGlideID(itemID)
    depend[SpecialGlideID] = true
    local SpecialGlideLobbyID = GlideSystem:ConvertToLobbyID(SpecialGlideID)
    depend[SpecialGlideLobbyID] = true
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet:NeedProcessPetDependentResource(itemID, ItemType, itemCfg.ItemSubType) then
    local PetID = logic_pet:GetAssociatedPetID(itemID)
    if PetID then
      depend[PetID] = true
      local petDependRes = logic_pet:GetPetDependResource(PetID)
      if petDependRes then
        for _, v in pairs(petDependRes) do
          depend[v] = true
        end
      end
    end
  end
  if ItemType == ENUM_ITEM_TYPE.Vehicle then
    local upgradeVehicle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.upgradeVehicle)
    local carItemIDS = upgradeVehicle:GetAssociatedCars(itemID)
    if carItemIDS then
      for _, v in pairs(carItemIDS) do
        depend[v] = true
      end
    end
    local LogicVehicleResDependencyUtil = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleResDependencyUtil)
    local vehicleRelatedItemList = LogicVehicleResDependencyUtil:GetRelatedItemIDList(itemID)
    if vehicleRelatedItemList and next(vehicleRelatedItemList) then
      for _, v in pairs(vehicleRelatedItemList) do
        depend[v] = true
      end
    end
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local MultiList = LogicMultiItemModule:GetMultiListByItemID(itemID)
  for key, value in pairs(MultiList) do
    if value then
      depend[value.ItemID] = true
    end
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  local MileStoneDownloadList, actionList = logic_emote.GetMileStoneDownloadList(itemID, itemCfg)
  if MileStoneDownloadList then
    for ItemID, MilestoneConfig in pairs(MileStoneDownloadList) do
      if ItemID and 0 < ItemID then
        depend[ItemID] = true
      end
    end
    for actionId, _ in pairs(actionList or {}) do
      if actionId and 0 < actionId then
        depend[actionId] = true
      end
    end
  end
  if ItemType == ENUM_ITEM_TYPE.Emote or ItemType == ENUM_ITEM_TYPE.MVPEmotion then
    local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
    if LogicParticleEmote:IsParticleEmote(itemID) then
      local HighLevelEmoteID = LogicParticleEmote:GetParticleEmoteID(itemID)
      depend[HighLevelEmoteID] = true
    elseif LogicParticleEmote:Is2LevelParticleEmote(itemID) then
      local BaseEmoteID = LogicParticleEmote:GetBaseID(itemID)
      depend[BaseEmoteID] = true
    end
    if ItemType == ENUM_ITEM_TYPE.MVPEmotion and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.MVPAction then
      local motionCfg = CDataTable.GetTableData("MVPActionInfo", itemID)
      if motionCfg and motionCfg.EmotionID and 0 < motionCfg.EmotionID then
        depend[motionCfg.EmotionID] = true
      end
    end
  end
  if not bNotMapping then
    cfg = CDataTable.GetTableData("BPMappingTable", itemID)
    if cfg and cfg.BPMapping and cfg.BPMapping ~= "" then
      local MapList = StringUtil.Split(cfg.BPMapping, "|")
      for i, v in pairs(MapList) do
        local id = tonumber(v)
        if id and 0 < id then
          depend[id] = true
          local item = CDataTable.GetTableData("Item", id)
          local tmpList = self:_GetRelatedItems(id, item, true)
          for _, vTmp in pairs(tmpList) do
            local idTmp = tonumber(vTmp)
            if idTmp and 0 < idTmp then
              depend[idTmp] = true
            end
          end
        end
      end
    end
  end
  depend[itemID] = true
  local list = {}
  for i, _ in pairs(depend) do
    table.insert(list, i)
  end
  if not bNotMapping then
    self.itemToItems[itemID] = list
  end
  return list
end
function PufferODPakManager:_GetItemLobbyPathByBPID(itemID, itemCfg, bpID, list)
  if not itemCfg then
    return nil
  end
  local itemType = itemCfg.ItemType
  local bpCfg = CDataTable.GetTableData("AvatarBPTable", bpID)
  if bpCfg ~= nil then
    if bpCfg.DeviceLevel > 0 and self.TCDeviceLevel >= bpCfg.DeviceLevel then
      if bpCfg.AvatarBPPathHigh ~= "" then
        table.insert(list, bpCfg.AvatarBPPathHigh)
      end
      if bpCfg.LobbyPathHigh ~= "" then
        table.insert(list, bpCfg.LobbyPathHigh)
      end
    end
    return bpCfg.LobbyPath
  end
  if itemType == ENUM_ITEM_TYPE.Weapon then
    bpCfg = CDataTable.GetTableData("WeaponBPTable", bpID)
    if bpCfg ~= nil then
      return bpCfg.LobbyPath
    end
  elseif itemType == ENUM_ITEM_TYPE.Aircraft_Skin or itemType == ENUM_ITEM_TYPE.Wingman_Skin then
    bpCfg = CDataTable.GetTableData("PlaneBPTable", bpID)
    if bpCfg ~= nil then
      return bpCfg.LobbyPath
    end
  elseif itemType == ENUM_ITEM_TYPE.Vehicle then
    bpCfg = CDataTable.GetTableData("VehicleBPTable", bpID)
    if bpCfg ~= nil then
      return bpCfg.LobbyPath
    end
  elseif itemType == ENUM_ITEM_TYPE.CasualShop or itemType == ENUM_ITEM_TYPE.WowEffect then
    bpCfg = CDataTable.GetTableData("EffectItemBPTable", bpID)
    if bpCfg ~= nil then
      return bpCfg.LobbyPath
    end
  end
  bpCfg = CDataTable.GetTableData("ConsumableBPTable", bpID)
  if bpCfg ~= nil then
    return bpCfg.LobbyPath
  end
  bpCfg = CDataTable.GetTableData("EmoteBPTable", bpID)
  if bpCfg ~= nil then
    if bpCfg.PathHigh ~= "" then
      table.insert(list, bpCfg.PathHigh)
    end
    return bpCfg.LobbyPath
  end
  return nil
end
function PufferODPakManager:GetPakIDAndSizeByPakName(pakName)
  if pakName == nil or pakName == "" then
    return nil, 0
  end
  for k, v in pairs(self.ODPaks) do
    if v.paks[pakName] then
      return k, v.paks[pakName].tSize
    end
  end
  return nil, 0
end
function PufferODPakManager:DumpUGCDebugInfo()
  if not bWriteLog then
    return
  end
  local str = ""
  for packID, v1 in pairs(self.ODPaks) do
    if v1.isVirtual then
      str = str .. string.format("PufferODPakManager:DumpUGCDebugInfo begin ---------------- packID:%s,curSize:%.2f,totalSize:%.2f,done:%s\n", tostring(packID), v1.curSize, v1.totalSize, tostring(v1.state == 3))
      for pakName, v2 in pairs(v1.paks) do
        str = str .. string.format("PufferODPakManager:DumpUGCDebugInfo packID:%s,pakName:%s,curSize:%.2f,totalSize:%.2f,done:%s\n", tostring(packID), pakName, v2.cSize, v2.tSize, tostring(v2.state == 3))
      end
    end
  end
  log(bWriteLog and str)
  str = ""
  for itemID, Paks in pairs(self.itemToPaks) do
    str = str .. "UGCPAKInfo,ItemID:" .. tostring(itemID) .. " , Paks : {"
    for pakName, _ in pairs(Paks.paks) do
      str = str .. pakName .. ","
    end
    str = str .. "}\n"
  end
  log(bWriteLog and str)
  return str
end
function PufferODPakManager:UpdateLocalPkgIntoCSC(existPaks)
  if not Client.USFSIsNewestVersion() then
    log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC return for not Client.USFSIsNewestVersion()")
    return
  end
  local UpdateLocalPkgOnceCount = HDmpveRemote.HDmpveRemoteConfigGetInt("UpdateLocalPkgOnceCount", 10)
  if UpdateLocalPkgOnceCount <= 0 then
    log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC return for UpdateLocalPkgOnceCount <= 0")
    return
  end
  log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC beg UpdateLocalPkgOnceCount: " .. UpdateLocalPkgOnceCount)
  existPaks = existPaks or {}
  local TmpArrayData = {}
  for pakName, _ in pairs(existPaks) do
    if string.find(pakName, ".pak") then
      local FilePath = Client.ProjectSavedDir() .. "Paks/" .. pakName
      if not Client.IsFileExistInCSCWithCheck(pakName) then
        log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC collect local FilePath: " .. FilePath)
        table.insert(TmpArrayData, FilePath)
      else
        log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC existPaks pakName: " .. pakName)
      end
      if UpdateLocalPkgOnceCount <= #TmpArrayData then
        break
      end
    end
  end
  if #TmpArrayData then
    log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC USFSCacheSysContextUpdatePkg TmpArrayData: " .. tostring(#TmpArrayData))
    Client.USFSCacheSysContextUpdatePkg(TmpArrayData)
  end
  log(bWriteLog and "PufferODPakManager:UpdateLocalPkgIntoCSC end")
end
function PufferODPakManager:UpdatePkgCheckInfo(existPaks)
  local CacheSysContextStartSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysContextStart", 1)
  if CacheSysContextStartSwitch == 0 or Client.GetAndroidSOVersion() == 32 or Client.GetMemorySize() < 4 then
    return
  end
  local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
  logic_puffer_common.HandleKickOutList(self.ODPaksNameToConHash)
  local USFSCacheSysContexInit = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSCacheSysContexInit", 1)
  if USFSCacheSysContexInit == 1 then
    log(bWriteLog and "PufferODPakManager:UpdatePkgCheckInfo Client.USFSCacheSysContexInit")
    Client.USFSCacheSysContexInit(self.ODPaksNameToConHash)
  end
  self.ODPaksNameToConHash = nil
  local ArrayData = {}
  ArrayData[1] = "ShadowTrackerExtra/Content/Paks/res_cachesyspkgdiffmini_obb.pak"
  Client.USFSCacheSysContextUpdatePkgDiff(ArrayData)
  self:UpdateLocalPkgIntoCSC(existPaks)
  log(bWriteLog and "PufferODPakManager:UpdatePkgCheckInfo end")
end
function PufferODPakManager:GetPakDataByPakName(pakName)
  local pakData = self.PakDatas and self.PakDatas[pakName]
  if pakData then
    return pakData.data
  end
  return nil
end
function PufferODPakManager:GetPackDataByPakName(pakName)
  if not pakName then
    return
  end
  local pakData = self.PakDatas[pakName]
  if pakData then
    return pakData.packID, self.ODPaks[pakData.packID]
  end
  return nil, nil
end
function PufferODPakManager:OnDownloadFinish(task, isSuccess, errorCode, IsUGC)
  local pakName = task.pakName
  local needSyncUgc = false
  local ODPackID, packData = self:GetPackDataByPakName(pakName)
  if ODPackID and packData then
    local pakData = packData.paks[pakName]
    if pakData then
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      if not (not isSuccess and (errorCode ~= 1 or Client.IsDevelopment())) or IsWoWEditor then
        pakData.cSize = pakData.tSize
        packData.curSize = packData.curSize + pakData.tSize
        packData.curCnt = packData.curCnt + 1
        pakData.state = PufferConst.ENUM_DownloadState.Done
        if pakData.tSize >= 5 then
          PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, pakName)
        end
        if packData.curCnt >= packData.totalCnt then
          packData.curCnt = packData.totalCnt
          packData.curSize = packData.totalSize
          packData.state = PufferConst.ENUM_DownloadState.Done
          if not IsUGC then
            PufferDownloader.SetDownloadKeyRecord(ODPackID, true)
            PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, ODPackID, nil, ODPackID == PufferConst.EODPackID.PREFETCH_ODPACKID)
            local PufferSwitch = require("client.slua.logic.download.puffer_switch")
            log(bWriteLog and string.format("puffer_odpak_downloader:OnDownloadFinish pakName:%s ODPackID:%s", pakName, ODPackID))
            local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
            local keyName = ui_navigation_manager:GetTopUIName()
            log(bWriteLog and string.format("puffer_odpak_downloader:OnDownloadFinish keyName:%s ODPackDownloadFinishPopUpSwitch:%s", keyName, tostring(PufferSwitch.ODPackDownloadFinishPopUpSwitch)))
            self:JumpODPack(ODPackID)
            log(bWriteLog and string.format("puffer_odpak_downloader:OnDownloadFinish ODPack:%s", ODPackID))
          end
        end
      else
        pakData.state = PufferConst.ENUM_DownloadState.Error
      end
    end
    if not IsUGC then
      needSyncUgc = packData.isVirtual
    end
  end
  if needSyncUgc then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferUGCPakManager = PufferManager.GetDownloadManager(PufferConst.ENUM_DownloadType.UGCPAK)
    printf("PufferODPakManager:OnDownloadFinish. sync ugc finish")
    PufferUGCPakManager:OnDownloadFinish(task, isSuccess, errorCode)
  end
  if pakName and self.battleDownloadPaks[pakName] then
    printf("PufferODPakManager:OnDownloadFinish. battleDownloadPaks")
    self.battleDownloadPaks[pakName] = nil
    for hash, names in pairs(self.battleDownloadHashMap) do
      if names[pakName] ~= nil then
        names[pakName] = nil
        if not next(names) then
          printf("PufferODPakManager:OnDownloadFinish. callback hash=%s", tostring(hash))
          local itemList = GCPufferDownloader.GetBatchODPaksDownloadList(Puffer, hash)
          local errorCodeList = {}
          for i, itemID in ipairs(itemList) do
            local state = self:GetStateByItemID(itemID)
            local err_code = 0
            if state ~= ENUM_DownloadState.Done then
              err_code = 1
            end
            table.insert(errorCodeList, err_code)
          end
          local finalErrCode = table.concat(errorCodeList, "|")
          printf("PufferODPakManager:OnDownloadFinish. finalErrCode=%s", tostring(finalErrCode))
          GCPufferDownloader.OnItemDownloadedInFighting(Puffer, hash, finalErrCode)
        end
      end
    end
  end
end
function PufferODPakManager:HandleEnterFight()
  log(bWriteLog and "PufferODPakManager:HandleEnterFight. self.enableSaveODPakDataToFile = " .. tostring(self.enableSaveODPakDataToFile))
  if not self.enableSaveODPakDataToFile then
    return
  end
  self.needRecoverBattleData = true
  self.battleDeleteFiles = {}
  xpcall(self.SaveODPakDataToFile, function()
    log(bWriteLog and "PufferODPakManager:HandleEnterFight. save error")
    self.needRecoverBattleData = false
  end, self)
  if self.needRecoverBattleData then
    self:ClearBattleMemory()
    log_format("PufferODPakManager:HandleEnterFight. clear puffer file list data")
    local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
    logic_puffer_common.PufferFileListJson = {}
  end
end
function PufferODPakManager:HandleExitFight()
  log(bWriteLog and "PufferODPakManager:HandleExitFight. self.enableSaveODPakDataToFile = " .. tostring(self.enableSaveODPakDataToFile))
  log(bWriteLog and "PufferODPakManager:HandleExitFight. self.needRecoverData = " .. tostring(self.needRecoverBattleData))
  if not self.enableSaveODPakDataToFile or not self.needRecoverBattleData then
    return
  end
  self.needRecoverBattleData = false
  local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
  logic_puffer_common.ReadPufferFileListJson()
  local loadComplete = true
  xpcall(self.LoadODPakDataFromFile, function()
    log(bWriteLog and "PufferODPakManager:HandleExitFight. load error")
    loadComplete = false
  end, self)
  if loadComplete and next(self.ODPaks) then
    self:RecoverBattleMemory()
  else
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE .. PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE, "")
    local existPaks = {}
    for _, filename in pairs(ret) do
      existPaks[PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE .. filename] = true
    end
    self:InitODPaks(existPaks, nil, false)
  end
end
function PufferODPakManager:GetSaveFilePath()
  return "ODPakData.txt"
end
function PufferODPakManager:SaveODPakDataToFile()
  log(bWriteLog and "PufferODPakManager:SaveODPakDataToFile.")
  local json = require("common.json_util")
  local encode = json.encode(self.ODPaks)
  Client.SaveStringToFile(encode, self:GetSaveFilePath())
  self:ClearBattleMemory()
end
function PufferODPakManager:LoadODPakDataFromFile()
  log(bWriteLog and "PufferODPakManager:LoadODPakDataFromFile.")
  local path = self:GetSaveFilePath()
  local dataStr = Client.LoadFileToString(path)
  local json = require("common.json_util")
  local data = json.decode(dataStr)
  if not data then
    log(bWriteLog and "PufferODPakManager:LoadODPakDataFromFile. data is nil")
    return
  end
  for k, v in pairs(data) do
    self.ODPaks[tonumber(k)] = v
  end
  Client.DeleteFile(path)
end
function PufferODPakManager:ClearBattleMemory()
  log(bWriteLog and "PufferODPakManager:ClearBattleMemory.")
  self.ODPaks = {}
  self.PakDatas = {}
  self.itemToPaks = {}
  self.itemToItems = {}
  self.itemToPaths = {}
  self.TableKeyToPaks = {}
end
function PufferODPakManager:RecoverBattleMemory()
  log(bWriteLog and "PufferODPakManager:RecoverBattleMemory.")
  local begintime = slua.getMiliseconds()
  self.PakDatas = {}
  for packID, v in pairs(self.ODPaks) do
    for pakName, data in pairs(v.paks) do
      self.PakDatas[pakName] = {packID = packID, data = data}
    end
  end
  local deleteFiles = self.battleDeleteFiles
  self.battleDeleteFiles = {}
  for pakName, v in pairs(deleteFiles) do
    self:ResetPakData(pakName)
  end
  local costTime = slua.getMiliseconds() - begintime
  log(bWriteLog and "PufferODPakManager:RecoverBattleMemory. costTime = " .. tostring(costTime))
end
function PufferODPakManager:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("PufferODPakManager:OnPostSwitchGameStatus. pre=%s, nextState=%s", tostring(preState), tostring(nextState)))
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() and not Logic_UGC:IsUGCEditMod() then
    self:HandleEnterFight()
  elseif preState == GameStatus.Fighting and GameStatus.InSupportDownloadState() and self.needRecoverBattleData then
    self:HandleExitFight()
  end
end
function PufferODPakManager:AddBattleDownloadItem(hash, itemList)
  printf("PufferODPakManager:AddBattleDownloadItem. hash=%s", tostring(hash))
  if not hash or not itemList then
    return
  end
  local pakNames = {}
  for k, itemID in pairs(itemList) do
    local paks = self:GetPakNamesByItemID(itemID)
    for name, _ in pairs(paks) do
      local state = self:GetStateByPakName(name)
      printf("PufferODPakManager:AddBattleDownloadItem. state=%s", tostring(state))
      if state ~= PufferConst.ENUM_DownloadState.Done then
        pakNames[name] = true
        self.battleDownloadPaks[name] = true
      end
    end
  end
  log_tree("PufferODPakManager:AddBattleDownloadItem. pakNames = ", pakNames)
  self.battleDownloadHashMap[hash] = pakNames
end
function PufferODPakManager:CheckBattleDownload()
  printf("PufferODPakManager:CheckBattleDownload.")
  if GameStatus.IsInMainCity() then
    printf("PufferODPakManager:CheckBattleDownload.not in maincity")
    return
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) or not uGameState.bAvatarDownloadInMainCity then
    printf("PufferODPakManager:CheckBattleDownload. uGameState.bAvatarDownloadInMainCity return")
    return
  end
  log_tree("PufferODPakManager:CheckBattleDownload. self.battleDownloadPaks = ", self.battleDownloadPaks)
  if next(self.battleDownloadPaks) then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    local pakList = {}
    for pakName, _ in pairs(self.battleDownloadPaks) do
      table.insert(pakList, pakName)
    end
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, pakList, PufferTlog.Enum_TLog_From.Battle, nil, {bFirst = true, bAutoDownload = true})
  end
end
function PufferODPakManager:ClearBattleDownloadItems()
  printf("PufferODPakManager:ClearBattleDownloadItems.")
  self.battleDownloadHashMap = {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferODPakManager = class(CModuleBase, nil, PufferODPakManager)
return CPufferODPakManager
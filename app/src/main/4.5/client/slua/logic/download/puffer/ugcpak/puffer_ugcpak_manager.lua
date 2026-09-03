local PufferUGCPakManager = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local LOCK_PAKNAME = PufferConst.LOCK_PAKNAME
function PufferUGCPakManager:DefineAndResetData()
  self.paks = {}
  self.assetToPaks = {}
  self.assetToPaths = {}
  self.blackListPaks = {}
  self.assetIdToFeatureKeys = {}
  self.assetIdToDependAssetIDs = {}
  self.assetIdToNecessaryFeatureKeys = {}
  self.AllResTypeFeatureMap = {}
  self.AllResTypeAssetIDMap = {}
  self.AllAssetParamsMap = {}
  self.AllFeatureIDList = {}
  self.AllFeatureIDMap = {}
  self.bStepCollect = true
  self.StepCollectTimer = nil
  self.PostProcessTimer = nil
end
function PufferUGCPakManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self.OnPufferJsonPostProcess, self)
end
function PufferUGCPakManager:InitPaks(existPaks)
  log(bWriteLog and "PufferUGCPakManager:InitPaks")
  local list = PufferDownloader.GetPufferFileListJson()
  if not list.ODPaks or not next(list.ODPaks) then
    log(bWriteLog and "PufferUGCPakManager:InitODPaks PufferFileList.json error")
    return
  end
  for i, packCfg in pairs(CDataTable.GetTable("PakInfoTable")) do
    if packCfg.IsUGC == 1 then
      local id = packCfg.PakID
      local strID = tostring(id)
      local pakList = list.ODPaks[strID] and list.ODPaks[strID].fileList
      if pakList and next(pakList) then
        local packData = {}
        self.paks[id] = packData
        packData.paks = {}
        packData.curCnt = 0
        packData.totalCnt = 0
        packData.curSize = 0
        packData.totalSize = 0
        packData.state = PufferConst.ENUM_DownloadState.Not
        local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
        logic_puffer_common.InitPakList(id, pakList, function(pakName, size, hash)
          packData.totalCnt = packData.totalCnt + 1
          packData.paks[pakName] = {}
          local pakData = packData.paks[pakName]
          pakData.tSize = size
          if existPaks[pakName] then
            pakData.state = PufferConst.ENUM_DownloadState.Done
            pakData.cSize = pakData.tSize
            packData.curSize = packData.curSize + pakData.tSize
            packData.curCnt = packData.curCnt + 1
          else
            pakData.state = PufferConst.ENUM_DownloadState.Not
            pakData.cSize = 0
          end
          packData.totalSize = packData.totalSize + pakData.tSize
        end)
        if packData.curCnt == packData.totalCnt then
          packData.curSize = packData.totalSize
          packData.state = PufferConst.ENUM_DownloadState.Done
        elseif packData.curCnt > 0 then
          packData.state = PufferConst.ENUM_DownloadState.Pause
        end
      end
    end
  end
  local Start = slua.getMiliseconds()
  if self.bStepCollect then
    self:StepCollectUGCPakData(existPaks)
  else
    self:CollectUGCPakData(existPaks)
  end
  local End = slua.getMiliseconds()
  print(bWriteLog and "PufferUGCPakManager:InitPaks, CollectUGCPakData Cost Time = ", End - Start)
end
function PufferUGCPakManager:CollectUGCPakData(existPaks)
  print(bWriteLog and "PufferUGCPakManager:CollectUGCPakData")
  local assetCfg = CDataTable.GetTable("UGCAssetConfig")
  local UsefulPaks = {}
  for _, v in pairs(assetCfg) do
    self:CollectOneUGCPakData(existPaks, v, UsefulPaks)
  end
end
function PufferUGCPakManager:CollectOneUGCPakData(existPaks, AssetConfig, UsefulPaks)
  local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
  local IsExpired = CreativeExpiredAssetConfig.IsCurVersionExpired(AssetConfig.AssetID, true)
  if IsExpired then
    if bWriteLog then
      print("PufferUGCPakManager:CollectOneUGCPakData AssetID = " .. AssetConfig.AssetID .. " is expired")
    end
  else
    local PackID = AssetConfig.ResSeprateType
    local packData = self.paks[PackID]
    if packData then
      local paks = self:_GetPakNamesByAssetConfig(AssetConfig)
      for pakName, _ in pairs(paks) do
        if pakName and pakName ~= LOCK_PAKNAME and not self:IsPakExistInPack(pakName) then
          if not UsefulPaks[pakName] then
            UsefulPaks[pakName] = 1
          else
            UsefulPaks[pakName] = UsefulPaks[pakName] + 1
          end
          if not packData.paks[pakName] then
            packData.paks[pakName] = {}
            local pakData = packData.paks[pakName]
            pakData.tSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true) / PufferConst.MB
            packData.totalCnt = packData.totalCnt + 1
            if existPaks[pakName] then
              pakData.state = PufferConst.ENUM_DownloadState.Done
              pakData.cSize = pakData.tSize
              packData.curSize = packData.curSize + pakData.tSize
              packData.curCnt = packData.curCnt + 1
            else
              pakData.state = PufferConst.ENUM_DownloadState.Not
              pakData.cSize = 0
            end
            packData.totalSize = packData.totalSize + pakData.tSize
            if packData.curCnt == packData.totalCnt then
              packData.curSize = packData.totalSize
              packData.state = PufferConst.ENUM_DownloadState.Done
            elseif packData.curCnt > 0 then
              packData.state = PufferConst.ENUM_DownloadState.Pause
            end
            if bWriteLog then
              print("PufferUGCPakManager:CollectOneUGCPakData insert to " .. PackID .. ", pakName: " .. pakName .. "  state = " .. pakData.state .. " AssetId = " .. AssetConfig.AssetID)
            end
          end
        end
      end
    end
  end
end
function PufferUGCPakManager:IsPakExistInPack(pakName)
  for _, packData in pairs(self.paks) do
    if packData.paks[pakName] then
      return true
    end
  end
  return false
end
function PufferUGCPakManager:StepCollectUGCPakData(ExistPaks)
  if self.StepCollectTimer then
    self:RemoveTimer(self.StepCollectTimer)
    self.StepCollectTimer = nil
  end
  local UsefulPaks = {}
  local Assets = {}
  local AssetCfg = CDataTable.GetTable("UGCAssetConfig")
  for _, v in pairs(AssetCfg) do
    table.insert(Assets, v)
  end
  local time_ticker = require("common.time_ticker")
  self.StepCollectTimer = self:AddTimer(0, function()
    local StepStartTime = slua.getMiliseconds()
    for _, v in ipairs(Assets) do
      self:CollectOneUGCPakData(ExistPaks, v, UsefulPaks)
      local StepEndTime = slua.getMiliseconds()
      if 30 < StepEndTime - StepStartTime then
        StepStartTime = StepEndTime
        coroutine.yield(time_ticker.MINIMUM_STEP_TIME)
      end
    end
    if self.StepCollectTimer then
      self:RemoveTimer(self.StepCollectTimer)
      self.StepCollectTimer = nil
    end
  end)
end
function PufferUGCPakManager:OnPufferJsonPostProcess()
  if not self.PackFeatureList then
    return
  end
  if self.PostProcessTimer then
    self:RemoveTimer(self.PostProcessTimer)
    self.PostProcessTimer = nil
  end
  local existPaks = PufferDownloader.RecordExistPaks
  log_format("PufferUGCPakManager:OnPufferJsonPostProcess. existPaks=%s", existPaks)
  local PackList = {}
  for PackID, v in pairs(self.PackFeatureList) do
    table.insert(PackList, {PackID = PackID, FeatureList = v})
  end
  local time_ticker = require("common.time_ticker")
  self.PostProcessTimer = self:AddTimer(0, function()
    local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    local StepStartTime = slua.getMiliseconds()
    for _, PackInfo in ipairs(PackList) do
      local PakNameMap = {}
      for _, k in pairs(PackInfo.FeatureList) do
        local itemID = tonumber(k)
        local pakList
        if itemID then
          pakList = puffer_odpak_manager:GetPakNamesByItemID(itemID)
        else
          pakList = puffer_odpak_manager:GetPakNamesByFeatureID(k)
        end
        if pakList then
          for pakName, _ in pairs(pakList) do
            PakNameMap[pakName] = k
          end
        end
        local StepEndTime = slua.getMiliseconds()
        if 30 < StepEndTime - StepStartTime then
          StepStartTime = StepEndTime
          coroutine.yield(time_ticker.MINIMUM_STEP_TIME)
        end
      end
      puffer_odpak_manager:InitVirtualODPack(PackInfo.PackID, PakNameMap, existPaks)
    end
    if self.PostProcessTimer then
      self:RemoveTimer(self.PostProcessTimer)
      self.PostProcessTimer = nil
    end
  end)
end
function PufferUGCPakManager:ResetPakData(pakName)
  local deleteSize = 0
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  for _, v in pairs(self.paks) do
    local pakData = v.paks and v.paks[pakName]
    if pakData then
      if pakData.state == ENUM_DownloadState.Done then
        if 0 < v.curCnt then
          v.curCnt = v.curCnt - 1
          v.curSize = v.curSize - pakData.tSize
          deleteSize = deleteSize + pakData.tSize
        end
        if v.curCnt == 0 then
          v.curSize = 0
          v.state = ENUM_DownloadState.Not
        elseif v.curCnt < v.totalCnt then
          v.state = ENUM_DownloadState.Pause
        end
      end
      pakData.state = ENUM_DownloadState.Not
      pakData.cSize = 0
      break
    end
  end
  return deleteSize
end
function PufferUGCPakManager:GetStateByKeyList(downloadType, keyList, bMinDepends)
  local resultState = PufferConst.ENUM_DownloadState.Done
  if Client.bEditorSkipDownload then
    return resultState
  end
  if not keyList then
    return resultState
  end
  for i, v in pairs(keyList) do
    local state = PufferConst.ENUM_DownloadState.Done
    if downloadType == PufferConst.ENUM_DownloadType.UGCPAK then
      if type(v) == "number" then
        state = self:GetStateByAssetID(v, bMinDepends)
      elseif string.sub(v, 1, 7) == PufferConst.UGCPAKS_RELATIVE_DIR then
        state = self:GetStateByPakName(v)
      else
        state = self:GetStateByPath(v)
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.UGCPACK then
      state = self:GetStateByPackID(v)
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    resultState = PufferManager.GetMixDownloadState(resultState, state)
  end
  return resultState
end
function PufferUGCPakManager:GetStateByAssetID(assetID, bMinDepends)
  assetID = tonumber(assetID)
  if not assetID or assetID <= 0 then
    return PufferConst.ENUM_DownloadState.Done
  end
  local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
  if CreativeExpiredAssetConfig.IsCurVersionExpired(assetID) then
    printf(bWriteLog and " PufferUGCPakManager:GetStateByAssetID assetID = %s  IsExpired", assetID)
    return PufferConst.ENUM_DownloadState.Done
  end
  if self.assetToPaks[assetID] and self.assetToPaks[assetID].state == PufferConst.ENUM_DownloadState.Done then
    return PufferConst.ENUM_DownloadState.Done
  end
  local paks = self:GetPakNamesByAssetID(assetID)
  local state = PufferConst.ENUM_DownloadState.Done
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  for pakName, _ in pairs(paks) do
    local tempState = self:GetStateByPakName(pakName)
    state = PufferManager.GetMixDownloadState(state, tempState)
    if state == PufferConst.ENUM_DownloadState.Download then
      self.assetToPaks[assetID].      return state
    end
  end
  local NecessaryFeatureKeys = self:GetNecessaryFeatureDepends(assetID)
  local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local tempState = puffer_odpak_manager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, NecessaryFeatureKeys)
  state = PufferManager.GetMixDownloadState(state, tempState)
  if state == PufferConst.ENUM_DownloadState.Download then
    self.assetToPaks[assetID].    return state
  end
  if bMinDepends then
  else
    local DependFeatureKeys, DependAssetIDs = self:GetDepends(assetID)
    tempState = puffer_odpak_manager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, DependFeatureKeys)
    state = PufferManager.GetMixDownloadState(state, tempState)
    if state == PufferConst.ENUM_DownloadState.Download then
      self.assetToPaks[assetID].      return state
    end
    tempState = self:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, DependAssetIDs, true)
    state = PufferManager.GetMixDownloadState(state, tempState)
    self.assetToPaks[assetID].  end
  return state
end
function PufferUGCPakManager:GetStateByPath(path)
  if path == nil or path == "" then
    return PufferConst.ENUM_DownloadState.Done
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local pakName = PufferManager.GetPakName(path)
  return self:GetStateByPakName(pakName)
end
function PufferUGCPakManager:GetStateByPakName(pakName)
  if pakName == "" then
    return PufferConst.ENUM_DownloadState.Done
  end
  if pakName == PufferConst.CE_LOCK_PAKNAME then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = PufferConst.ENUM_DownloadState.Done
  for _, v in pairs(self.paks) do
    if v.paks and v.paks[pakName] then
      state = v.paks[pakName].state
      if state == PufferConst.ENUM_DownloadState.Done then
        return PufferConst.ENUM_DownloadState.Done
      end
      break
    end
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  if puffer_queue:GetDownloadingTask(pakName) then
    return PufferConst.ENUM_DownloadState.Download
  end
  if puffer_queue:GetWaitTask(pakName) then
    return PufferConst.ENUM_DownloadState.Wait
  end
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return state
  end
  local isPakExist = PufferDownloader.GetPakExist(pakName)
  if isPakExist then
    return PufferConst.ENUM_DownloadState.Done
  end
  return PufferConst.ENUM_DownloadState.Not
end
function PufferUGCPakManager:GetStateByPackID(packID)
  if not PufferDownloader.PufferJsonDownloadReturn and not _G.IsEditor then
    return PufferConst.ENUM_DownloadState.Not
  end
  local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local virtualPackState = puffer_odpak_manager:GetStateByPackID(packID)
  if virtualPackState ~= PufferConst.ENUM_DownloadState.Done then
    printf(bWriteLog and "PufferUGCPakManager:GetStateByPackID virtualPackState PackID:%s not done", packID)
    return virtualPackState
  end
  local pack = self.paks[packID]
  if not pack then
    return PufferConst.ENUM_DownloadState.Done
  end
  if pack.curCnt == pack.totalCnt then
    pack.state = PufferConst.ENUM_DownloadState.Done
  end
  local state = pack.state
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return state
  end
  return state
end
function PufferUGCPakManager:GetSizeByKeyList(downloadType, keyList, ifGetPakSizeList_UGCPAK, bMinDepends)
  local curSize = 0
  local totalSize = 0
  if downloadType == PufferConst.ENUM_DownloadType.UGCPAK and 1 < #keyList then
    local bAllItemID = true
    for i, v in pairs(keyList) do
      if type(v) ~= "number" then
        bAllItemID = false
        break
      end
    end
    if bAllItemID then
      return self:GetSizeByAssetIDList(keyList, ifGetPakSizeList_UGCPAK, bMinDepends)
    end
  end
  local skilDependBundle = {}
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.UGCPAK then
      if type(v) == "number" then
        local cSize, tSize = self:GetSizeByAssetID(v, skilDependBundle, bMinDepends)
        curSize = curSize + cSize
        totalSize = totalSize + tSize
      elseif string.sub(v, 1, 7) == PufferConst.UGCPAKS_RELATIVE_DIR then
        local cSize, tSize = self:GetSizeByPakName(v)
        curSize = curSize + cSize
        totalSize = totalSize + tSize
      else
        local cSize, tSize = self:GetSizeByPath(v)
        curSize = curSize + cSize
        totalSize = totalSize + tSize
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.UGCPACK then
      local cSize, tSize = self:GetSizeByPackID(v)
      curSize = curSize + cSize
      totalSize = totalSize + tSize
    end
  end
  return curSize, totalSize
end
function PufferUGCPakManager:GetSizeByAssetIDList(assetIDList, ifGetPakSizeList, bMinDepends)
  local cSize = 0
  local tSize = 0
  local allPaks = {}
  local DependsFeatureKeysMap = {}
  local DependsAssetIDsMap = {}
  local pakSizeList = ifGetPakSizeList and {} or nil
  for i, AssetID in pairs(assetIDList) do
    local paks = self:GetPakNamesByAssetID(AssetID)
    for pakName, _ in pairs(paks) do
      allPaks[pakName] = true
    end
    local NecessaryFeatureKeys = self:GetNecessaryFeatureDepends(AssetID)
    for _, v in pairs(NecessaryFeatureKeys) do
      DependsFeatureKeysMap[v] = true
    end
    local DependFeatureKeys, DependAssetIDs = self:GetDepends(AssetID)
    for _, v in pairs(DependFeatureKeys) do
      DependsFeatureKeysMap[v] = true
    end
    for _, v in pairs(DependAssetIDs) do
      DependsAssetIDsMap[v] = true
    end
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  for pakName, _ in pairs(allPaks) do
    local pakId
    if pakSizeList then
      pakId = PufferODPakManager:GetPakIDAndSizeByPakName(pakName)
    end
    local flag = false
    for _, v in pairs(self.paks) do
      if v.paks and v.paks[pakName] then
        local PakCSize = v.paks[pakName].cSize * PufferConst.MB
        local PakTSize = v.paks[pakName].tSize * PufferConst.MB
        flag = true
        cSize = cSize + PakCSize
        tSize = tSize + PakTSize
        if pakSizeList and pakId then
          pakSizeList[pakId] = pakSizeList[pakId] or {}
          local tempCSize = pakSizeList[pakId].cSize or 0
          local tempTSize = pakSizeList[pakId].tSize or 0
          pakSizeList[pakId].cSize = tempCSize + PakCSize
          pakSizeList[pakId].tSize = tempTSize + PakTSize
        end
        break
      end
    end
    if not flag then
      local pakSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
      tSize = tSize + pakSize
      if pakSizeList and pakId then
        pakSizeList[pakId] = pakSizeList[pakId] or {}
        local tempCSize = pakSizeList[pakId].cSize or 0
        local tempTSize = pakSizeList[pakId].tSize or 0
        pakSizeList[pakId].cSize = tempCSize
        pakSizeList[pakId].tSize = tempTSize + pakSize
      end
    end
  end
  if bMinDepends then
  else
    local FeatureKeyList = {}
    for featureKey, v in pairs(DependsFeatureKeysMap) do
      table.insert(FeatureKeyList, featureKey)
    end
    local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    local tempcSize, temptSize = puffer_odpak_manager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, FeatureKeyList)
    cSize = cSize + tempcSize
    tSize = tSize + temptSize
    local AssetIDList = {}
    for assetID, v in pairs(DependsAssetIDsMap) do
      table.insert(AssetIDList, assetID)
    end
    tempcSize, temptSize = self:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AssetIDList, nil, true)
    cSize = cSize + tempcSize
    tSize = tSize + temptSize
  end
  return cSize, tSize, pakSizeList
end
function PufferUGCPakManager:GetSizeByAssetID(assetID, skipDependBundle, bMinDepends)
  local cSize = 0
  local tSize = 0
  local paks = self:GetPakNamesByAssetID(assetID)
  for pakName, _ in pairs(paks) do
    local flag = false
    for _, v in pairs(self.paks) do
      if v.paks and v.paks[pakName] then
        flag = true
        cSize = cSize + v.paks[pakName].cSize * PufferConst.MB
        tSize = tSize + v.paks[pakName].tSize * PufferConst.MB
        break
      end
    end
    if not flag then
      tSize = tSize + PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
    end
  end
  local NecessaryFeatureKeys = self:GetNecessaryFeatureDepends(assetID)
  local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local tempcSize, temptSize = puffer_odpak_manager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, NecessaryFeatureKeys)
  cSize = cSize + tempcSize
  tSize = tSize + temptSize
  if bMinDepends then
  else
    local DependFeatureKeys, DependAssetIDs = self:GetDepends(assetID)
    for i = #DependFeatureKeys, 1, -1 do
      local FeatureKey = DependFeatureKeys[i]
      for _, NecessaryFeatureKey in pairs(NecessaryFeatureKeys) do
        if FeatureKey == NecessaryFeatureKey then
          table.remove(DependFeatureKeys, i)
          break
        end
      end
    end
    tempcSize, temptSize = puffer_odpak_manager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, DependFeatureKeys)
    cSize = cSize + tempcSize
    tSize = tSize + temptSize
    tempcSize, temptSize = self:GetSizeByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, DependAssetIDs, nil, true)
    cSize = cSize + tempcSize
    tSize = tSize + temptSize
  end
  if self:GetStateByAssetID(assetID, bMinDepends) == PufferConst.ENUM_DownloadState.Done then
    cSize = tSize
  end
  return cSize, tSize
end
function PufferUGCPakManager:GetSizeByPath(path)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local cSize, tSize = 0, 0
  local pakName = PufferManager.GetPakName(path)
  cSize, tSize = self:GetSizeByPakName(pakName)
  return cSize, tSize
end
function PufferUGCPakManager:GetSizeByPakName(pakName)
  local cSize, tSize = 0, 0
  if pakName == "" then
    return 0, 0
  end
  for _, v in pairs(self.paks) do
    if v.paks and v.paks[pakName] then
      cSize = v.paks[pakName].cSize * PufferConst.MB
      tSize = v.paks[pakName].tSize * PufferConst.MB
      break
    end
  end
  if tSize == 0 then
    tSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true)
  end
  if self:GetStateByPakName(pakName) == PufferConst.ENUM_DownloadState.Done then
    cSize = tSize
  end
  return cSize, tSize
end
function PufferUGCPakManager:GetSizeByPackID(packID)
  local puffer_odpak_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local tempcSize, temptSize = puffer_odpak_manager:GetSizeByPackID(packID)
  local pack = self.paks[packID]
  if not pack then
    return tempcSize, temptSize
  end
  local cSize = pack.curSize
  local tSize = pack.totalSize
  cSize = (cSize or 0) + (tempcSize or 0)
  tSize = (tSize or 0) + (temptSize or 0)
  return cSize or 0, tSize or 0
end
function PufferUGCPakManager:GetAllUGCPakCurSize()
  local curSize = 0
  for _, v in pairs(self.paks) do
    curSize = curSize + (v.curSize or 0)
  end
  log(bWriteLog and string.format("PufferUGCPakManager:GetAllUGCPakCurSize :%s", curSize))
  return curSize
end
function PufferUGCPakManager:GetPakNamesByAssetID(assetID)
  if not assetID or assetID == 0 then
    return {}
  end
  local CreativeExpiredAssetConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.CreativeExpiredAssetConfig")
  local IsExpired = CreativeExpiredAssetConfig.IsCurVersionExpired(assetID)
  if IsExpired then
    return {}
  end
  if self.assetToPaks[assetID] and self.assetToPaks[assetID].paks then
    return self.assetToPaks[assetID].paks
  end
  self.assetToPaks[assetID] = {
    paks = {}
  }
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local list = self:_GetResourcesPath(assetID)
  for _, v in pairs(list) do
    local pakName = PufferManager.GetPakName(v)
    if pakName ~= "" then
      self.assetToPaks[assetID].paks[pakName] = true
    end
  end
  return self.assetToPaks[assetID].paks
end
function PufferUGCPakManager:GetPakNamesByPackID(packID, bSkipVirtualPack)
  if not packID or not self.paks[packID] then
    return nil
  end
  return self.paks[packID].paks
end
function PufferUGCPakManager:GetDepends(assetID)
  local StringUtil = require("common.string_util")
  local assetCfg = CDataTable.GetTableData("UGCAssetConfig", assetID)
  if not assetCfg then
    return {}, {}
  end
  if not self.assetIdToFeatureKeys then
    self.assetIdToFeatureKeys = {}
  end
  if not self.assetIdToDependAssetIDs then
    self.assetIdToDependAssetIDs = {}
  end
  local DependFeatureKeys = self.assetIdToFeatureKeys[assetID]
  if not DependFeatureKeys then
    local DependResTypeItems = StringUtil.Split(assetCfg.DependResType, ";")
    DependFeatureKeys = {}
    if DependResTypeItems and type(DependResTypeItems) == "table" then
      for _, v in pairs(DependResTypeItems) do
        if v ~= "" then
          local DependResType = tonumber(v)
          if DependResType then
            local AllDependRes = self.AllResTypeFeatureMap[DependResType]
            if AllDependRes and type(AllDependRes) == "table" then
              for FeatureID, v in pairs(AllDependRes) do
                table.insert(DependFeatureKeys, FeatureID)
              end
            end
          end
        end
      end
    end
    self.assetIdToFeatureKeys[assetID] = DependFeatureKeys
  end
  local DependAssetIDs = self.assetIdToDependAssetIDs[assetID]
  if not DependAssetIDs then
    DependAssetIDs = {}
    local DependResTypeItems = StringUtil.Split(assetCfg.DependResType, ";")
    if DependResTypeItems and type(DependResTypeItems) == "table" then
      for _, v in pairs(DependResTypeItems) do
        if v ~= "" then
          local DependResType = tonumber(v)
          if DependResType then
            local AllDependAssetID = self.AllResTypeAssetIDMap[DependResType]
            if AllDependAssetID and type(AllDependAssetID) == "table" then
              for AssetID, v in pairs(AllDependAssetID) do
                table.insert(DependAssetIDs, AssetID)
              end
            end
          end
        end
      end
    end
    self.assetIdToDependAssetIDs[assetID] = DependAssetIDs
  end
  return DependFeatureKeys, DependAssetIDs
end
function PufferUGCPakManager:GetNecessaryFeatureDepends(AssetID)
  local assetCfg = CDataTable.GetTableData("UGCAssetConfig", AssetID)
  if not assetCfg then
    return {}
  end
  if not self.assetIdToNecessaryFeatureKeys then
    self.assetIdToNecessaryFeatureKeys = {}
  end
  local DependFeatureKeys = self.assetIdToNecessaryFeatureKeys[AssetID]
  if not DependFeatureKeys then
    DependFeatureKeys = {}
    if assetCfg.DependFeatures_as then
      for _, FeatureKey in pairs(assetCfg.DependFeatures_as) do
        local ItemID = tonumber(FeatureKey)
        if ItemID then
          table.insert(DependFeatureKeys, ItemID)
        else
          table.insert(DependFeatureKeys, FeatureKey)
        end
      end
    end
    self.assetIdToNecessaryFeatureKeys[AssetID] = DependFeatureKeys
  end
  return DependFeatureKeys
end
function PufferUGCPakManager:_GetResources(assetID)
  local res = {}
  local assetCfg = CDataTable.GetTableData("UGCAssetConfig", assetID)
  if not assetCfg then
    return res
  end
  return assetCfg.ResArray_a
end
function PufferUGCPakManager:_GetResourcesPath(assetID)
  local res = self:_GetResources(assetID)
  local paths = {}
  for i, v in pairs(res) do
    local resCfg = CDataTable.GetTableData("UGCResConfig", v)
    if resCfg then
      table.insert(paths, resCfg.ResPath)
    end
  end
  return paths
end
function PufferUGCPakManager:_GetResourcesPathByAssetConfig(AssetConfig)
  local res = AssetConfig.ResArray_a
  local paths = {}
  for i, v in pairs(res) do
    local resCfg = CDataTable.GetTableData("UGCResConfig", v)
    if resCfg then
      table.insert(paths, resCfg.ResPath)
    end
  end
  return paths
end
function PufferUGCPakManager:_GetPakNamesByAssetConfig(AssetConfig)
  if not AssetConfig then
    return {}
  end
  local assetID = AssetConfig.AssetID
  if self.assetToPaks[assetID] and self.assetToPaks[assetID].paks then
    return self.assetToPaks[assetID].paks
  end
  self.assetToPaks[assetID] = {
    paks = {}
  }
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local list = self:_GetResourcesPathByAssetConfig(AssetConfig)
  for _, v in pairs(list) do
    local pakName = PufferManager.GetPakName(v)
    if pakName ~= "" then
      self.assetToPaks[assetID].paks[pakName] = true
    end
    if bWriteLog then
      printf("[DebugUGC] PufferUGCPakManager:_GetPakNamesByAssetConfig assetID = %s,v = %s, pakName = %s", assetID, v, pakName)
    end
  end
  return self.assetToPaks[assetID].paks
end
function PufferUGCPakManager:DumpUGCDebugInfo()
  if not bWriteLog then
    return
  end
  if IsWoWEditor then
    return
  end
  local str = ""
  for packID, v1 in pairs(self.paks) do
    str = str .. string.format("PufferUGCPakManager:DumpUGCDebugInfo begin ---------------- packID:%s,curSize:%.2f,totalSize:%.2f,done:%s\n", tostring(packID), v1.curSize or 0, v1.totalSize or 0, tostring(v1.state == 3))
    for pakName, v2 in pairs(v1.paks) do
      str = str .. string.format("PufferUGCPakManager:DumpUGCDebugInfo packID:%s,pakName:%s,curSize:%.2f,totalSize:%.2f,done:%s\n", tostring(packID), pakName, v2.cSize or 0, v2.tSize or 0, tostring(v2.state == 3))
    end
  end
  log(bWriteLog and str)
  return str
end
function PufferUGCPakManager:OnDownloadFinish(task, isSuccess, errorCode)
  if errorCode == 1 or errorCode == -1 then
    self.blackListPaks[task.pakName] = true
  end
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  for i, v in pairs(self.paks) do
    if v.paks and v.paks[task.pakName] then
      if not (not isSuccess and (errorCode ~= 1 or Client.IsDevelopment())) or IsWoWEditor then
        v.paks[task.pakName].cSize = v.paks[task.pakName].tSize
        v.curSize = v.curSize + v.paks[task.pakName].tSize
        v.curCnt = v.curCnt + 1
        v.paks[task.pakName].state = PufferConst.ENUM_DownloadState.Done
        if v.curCnt >= v.totalCnt then
          v.curCnt = v.totalCnt
          v.curSize = v.totalSize
          v.state = PufferConst.ENUM_DownloadState.Done
          PufferTlog.SendTLog(task.from, PufferTlog.Enum_TLog_Optype.Finish, i)
          if bWriteLog then
            log(string.format("puffer_ugcpak_downloader:OnDownloadFinish ODPack:%s", i))
          end
        end
      else
        v.paks[task.pakName].state = PufferConst.ENUM_DownloadState.Error
      end
    end
  end
end
function PufferUGCPakManager:InitUGCDependsODPak()
  printf("PufferUGCPakManager:InitUGCDependsODPak.")
  self:WOWEditorAutoDownload()
  local StringUtil = require("common.string_util")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local AssetParamCfg = CDataTable.GetTable("UGCAssetParamCfg")
  self.AllFeatureIDMap = {}
  local PackFeatureMap = {}
  local   local AlreadyInPack = {}
  for _, Cfg in pairs(AssetParamCfg) do
    local AssetParamID = Cfg.ID
    local ResType = Cfg.ResType
    local DependFeatureID = Cfg.DependFeatureKeys
    local DependAssetIDs = Cfg.DependAssetIDs
    local PackID = Cfg.PackID or 0
    if PackID == 0 then
      PackID = PufferConst.EODPackID.WOW_20W
    end
    if not PackFeatureMap[PackID] then
      PackFeatureMap[PackID] = {}
    end
    local CurPackFeatureMap = PackFeatureMap[PackID]
    if not self.AllResTypeFeatureMap[ResType] then
      self.AllResTypeFeatureMap[ResType] = {}
    end
    if not self.AllResTypeAssetIDMap[ResType] then
      self.AllResTypeAssetIDMap[ResType] = {}
    end
    local ResTypeFeatureMap = self.AllResTypeFeatureMap[ResType]
    local ResTypeAssetIDMap = self.AllResTypeAssetIDMap[ResType]
    local AssetParam = {
      DependFeatureIDList = {},
      DependAssetIDList = {},
          }
    self.AllAssetParamsMap[AssetParamID] = AssetParam
    if DependFeatureID ~= "" then
      local DependFeatureIDItems = StringUtil.Split(DependFeatureID, ";")
      local featureCount = 0
      for _, v in pairs(DependFeatureIDItems) do
        if v ~= "" then
          local FeatureID = tonumber(v)
          local key = FeatureID or v
          self.AllFeatureIDMap[key] = true
          ResTypeFeatureMap[key] = true
          featureCount = featureCount + 1
          AssetParam.DependFeatureIDList[featureCount] = key
          if not AlreadyInPack[key] then
            AlreadyInPack[key] = true
            CurPackFeatureMap[key] = true
          end
        end
      end
    end
    if DependAssetIDs ~= "" then
      local DependAssetIDsItems = StringUtil.Split(DependAssetIDs, ";")
      local assetCount = 0
      for _, v in pairs(DependAssetIDsItems) do
        if v ~= "" then
          local AssetID = tonumber(v)
          if AssetID then
            ResTypeAssetIDMap[AssetID] = true
            assetCount = assetCount + 1
            AssetParam.DependAssetIDList[assetCount] = AssetID
          end
        end
      end
    end
  end
  local b  local FurnitureAvailabilityUtil
  if bIsWoWEditor then
    FurnitureAvailabilityUtil = require("GameLua.Mod.CreativeBase.Gameplay.Utility.CreativeFurnitureAvailabilityUtil")
  end
  local AssetConfig = CDataTable.GetTable("UGCAssetConfig")
  for _, Cfg in pairs(AssetConfig) do
    if Cfg.DependFeatures_as then
      local PackID = Cfg.ResSeprateType
      if not PackID or PackID == 0 then
        PackID = PufferConst.EODPackID.WOW_20W
      end
      if not PackFeatureMap[PackID] then
        PackFeatureMap[PackID] = {}
      end
      local CurPackFeatureMap = PackFeatureMap[PackID]
      for _, v in pairs(Cfg.DependFeatures_as) do
        local FeatureID = tonumber(v)
        local FeatureKey = FeatureID or v
        if FeatureKey then
          if not AlreadyInPack[FeatureKey] then
            CurPackFeatureMap[FeatureKey] = true
          end
          self.AllFeatureIDMap[FeatureKey] = true
        end
      end
    end
    if bIsWoWEditor and FurnitureAvailabilityUtil and FurnitureAvailabilityUtil.IsFurnitureAsset(Cfg.AssetID) then
      print("PufferUGCPakManager:InitUGCDependsODPak, Add To ForceDependAssetIDList", Cfg.AssetID)
      table.insert(Config_UGC.ForceDependAssetIDList, Cfg.AssetID)
    end
  end
  self.AllFeatureIDList = {}
  local featureListCount = 0
  for k, _ in pairs(self.AllFeatureIDMap) do
    featureListCount = featureListCount + 1
    self.AllFeatureIDList[featureListCount] = k
    printf(bWriteLog and "PufferUGCPakManager:Init, AllFeatureIDList: %s", k)
  end
  self.PackFeatureList = {}
  for PackID, v in pairs(PackFeatureMap) do
    local FeatureList = {}
    for k, _ in pairs(v) do
      table.insert(FeatureList, k)
    end
    self.PackFeatureList[PackID] = FeatureList
  end
end
function PufferUGCPakManager:WOWEditorAutoDownload()
  if not IsWoWEditor then
    return
  end
  printf("PufferUGCPakManager:WOWEditorAutoDownload")
  if self.AutoDownloadTimer then
    return
  end
  self.WOWEditorAutoDownloadFinished = false
  self.AutoDownloadTimer = self:AddTimerLoop(0, function()
    if not PufferDownloader.BattleDownloadSwitch then
      PufferDownloader.SetBattleDownloadSwitch(true)
    end
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    if PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, self.AllFeatureIDList) == PufferConst.ENUM_DownloadState.Done then
      printf(bWriteLog and "PufferUGCPakManager:WOWEditorAutoDownload, Auto Download Finished")
      self.WOWEditorAutoDownloadFinished = true
      return
    end
    local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
    puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, self.AllFeatureIDList)
    printf(bWriteLog and "PufferUGCPakManager:WOWEditorAutoDownload, Auto Downloading")
  end, TIMER_INFINITE, 1)
end
function PufferUGCPakManager:DebugPrintUGCRes()
  if not bWriteLog then
    return
  end
  self.DebugPrintUGC = true
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  PufferODPakManager.DebugPrintUGC = true
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {
    "map_creativebasic"
  })
  cSize = cSize / PufferConst.MB
  tSize = tSize / PufferConst.MB
  printf("[DebugPrintUGCRes] MapKey :map_creativebasic,tSize:%.2f", tSize)
  for packID, v1 in pairs(self.paks) do
    for pakName, v2 in pairs(v1.paks) do
      print(string.format("[DebugPrintUGCRes] UGC packID:%s,pakName:%s,State:%s,Size:%.2f\n", tostring(packID), pakName, v2.state, v2.tSize))
    end
    local virtualPackSize = 0
    local PackData = PufferODPakManager.ODPaks[packID]
    if PackData then
      for pakName, v2 in pairs(PackData.paks) do
        local pakTSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true) / PufferConst.MB
        virtualPackSize = virtualPackSize + pakTSize
        print(string.format("[DebugPrintUGCRes] UGC Virtual packID:%s,pakName:%s, state:%s, Size:%.2f,featurekey:%s\n", tostring(packID), pakName, v2.state, pakTSize, tostring(v2.featureKey)))
      end
    end
    print(string.format("[DebugPrintUGCRes] packID:%s,state:%s,curCnt:%s,totalCnt:%s,totalSize:%.2f", tostring(packID), v1.state, v1.curCnt, v1.totalCnt, v1.totalSize + virtualPackSize))
  end
  local assetCfg = CDataTable.GetTable("UGCAssetConfig")
  for _, v in pairs(assetCfg) do
    local AssetID = v.AssetID
    local cAssetSize, tAssetSize = self:GetSizeByAssetID(AssetID, nil, true)
    print(string.format("[DebugPrintUGCRes] AssetID:%s,Size:%.2f", tostring(AssetID), tAssetSize / PufferConst.MB))
  end
  local resCfg = CDataTable.GetTable("UGCResConfig")
  for _, v in pairs(resCfg) do
    local ResPath = v.ResPath
    local pakName = PufferManager.GetPakName(ResPath)
    local cResSize, tResSize = 0, 0
    local flag = false
    for _, PackData in pairs(self.paks) do
      if PackData and PackData.paks[pakName] then
        cResSize = PackData.paks[pakName].cSize
        tResSize = PackData.paks[pakName].tSize
        flag = true
      end
    end
    if not flag then
      tResSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, pakName, true) / PufferConst.MB
    end
    print(string.format("[DebugPrintUGCRes] ResID:%s, ResPath:%s,PakName:%s,Size:%.2f", v.ResID, ResPath, pakName, tResSize))
  end
  local TotalSize = 0
  local AllInfo = {}
  local infoCount = 0
  for k, _ in pairs(self.AllFeatureIDMap) do
    local state = PufferODPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {k})
    local cSize, tSize = PufferODPakManager:GetSizeByKeyList(PufferConst.ENUM_DownloadType.ODPAK, {k})
    tSize = tSize / PufferConst.MB
    infoCount = infoCount + 1
    AllInfo[infoCount] = {
      Key = k,
      Size = tSize,
      State = state
    }
    TotalSize = TotalSize + tSize
  end
  table.sort(AllInfo, function(a, b)
    return a.Size > b.Size
  end)
  for i, v in ipairs(AllInfo) do
    print(string.format("[DebugPrintUGCRes] FeatureKey :%s,tSize:%.2f", tostring(v.Key), v.Size))
  end
  print(string.format("[DebugPrintUGCRes] FeatureKey TotalSize:%.2f", TotalSize))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferUGCPakManager = class(CModuleBase, nil, PufferUGCPakManager)
return CPufferUGCPakManager
local CustomAssetCacheManager = {}
local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local Utility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
local PBUtility = require("GameLua.Mod.CreativeBase.BinaryData.CreativeModePbUtility")
local CustomAssetCacheInfoDefine = {
  AssetKey = "",
  SuffixType = "",
  AssetMD5 = "",
  AssetSize = 0,
  LoadCount = 0,
  CacheTimestamp = 0,
  LoadTimestamp = 0,
  Content = nil,
  CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.NotChecked
}
local CustomAssetSuffixTypeCacheMetaInfoDefine = {
  CustomAssetSuffixTypeMetaMap = {}
}
local CustomAssetCacheMetaInfoDefine = {
  CustomAssetMetaMap = {}
}
function CustomAssetCacheManager:ctor()
  self.CustomAssetBytesMap = {}
  self.CustomAssetCacheMetaInfo = Utility:DeepCopy(CustomAssetCacheMetaInfoDefine)
end
function CustomAssetCacheManager:ReceiveBeginPlay()
  CustomAssetCacheManager.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:ReceiveBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self:InitCustomAssetCacheMetaInfo()
end
function CustomAssetCacheManager:ReceivePostBeginPlay()
  CustomAssetCacheManager.__super.ReceivePostBeginPlay(self)
  print(bWriteLog and "CustomAssetCacheManager:ReceivePostBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
end
function CustomAssetCacheManager:ReceiveEndPlay()
  print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:ReceiveEndPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self.CustomAssetBytesMap = {}
  self.CustomAssetCacheMetaInfo = Utility:DeepCopy(CustomAssetCacheMetaInfoDefine)
  CustomAssetCacheManager.__super.ReceiveEndPlay(self)
end
function CustomAssetCacheManager:OnFightingStatusPreExit()
  print(bWriteLog and "CustomAssetCacheManager:OnFightingStatusExit")
  self.CustomAssetBytesMap = {}
end
function CustomAssetCacheManager:NeedCacheSourceFile()
  local bIsShipping = true
  local Utility = require("common.utility")
  if not Utility.IsReleaseVersion() then
    bIsShipping = false
  end
  return bIsShipping ~= true
end
function CustomAssetCacheManager:GetCacheRelativePath(AssetKey, SuffixType)
  local SimpleAssetKey = self:GetCustomAssetMgr():CustomAssetKeyToSimple(AssetKey)
  return CustomAssetDefine.GetCustomAssetCacheRelativePath(SimpleAssetKey, SuffixType)
end
function CustomAssetCacheManager:GetCacheAbsolutePath(AssetKey, SuffixType)
  local SimpleAssetKey = self:GetCustomAssetMgr():CustomAssetKeyToSimple(AssetKey)
  return CustomAssetDefine.GetCustomAssetCacheAbsolutePath(SimpleAssetKey, SuffixType)
end
function CustomAssetCacheManager:InitCustomAssetCacheMetaInfo()
  print(bWriteLog and "CustomAssetCacheManager:InitCustomAssetCacheMetaInfo")
  if self:IsDedicatedServer() then
    return
  end
  local bMetaChanged = false
  local metaInfoBuffer = self:LoadFileToArray(CustomAssetDefine.CustomAssetCacheMetaInfoPath)
  local cacheMetaInfo
  local bNeedRebuildMeta = false
  if metaInfoBuffer ~= nil and 0 < #metaInfoBuffer then
    local tryParse = true
    local metaResult = PBUtility.UnPackToTableByMsg(metaInfoBuffer, PBUtility.ProtoMessageMap.CustomAssetCacheMetaInfo)
    if metaResult ~= nil then
      local metaMap = metaResult.CustomAssetMetaMap
      if metaMap ~= nil then
        cacheMetaInfo = metaResult
      else
        print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:InitCustomAssetCacheMetaInfo ERROR: meta file is damaged or modified. Try rebuild.")
        bNeedRebuildMeta = true
      end
    else
      print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:InitCustomAssetCacheMetaInfo ERROR: meta file is damaged or modified. Try rebuild.")
      bNeedRebuildMeta = true
    end
  else
    bNeedRebuildMeta = true
  end
  if not bNeedRebuildMeta then
    local fileList = {}
    local keyTypeList = {}
    local metaMap = cacheMetaInfo.CustomAssetMetaMap
    for AssetKey, SuffixMap in pairs(metaMap) do
      for SuffixType, cacheInfo in pairs(SuffixMap.CustomAssetSuffixTypeMetaMap or {}) do
        local relPath = self:GetCacheRelativePath(AssetKey, SuffixType)
        table.insert(fileList, relPath)
        table.insert(keyTypeList, {
          AssetKey = AssetKey,
          SuffixType = SuffixType,
                  })
      end
    end
    local existList = self:AreFilesExistInSaved(fileList)
    for i, pathInfo in ipairs(keyTypeList) do
      local isExist = existList:Get(i - 1)
      local AssetKey = pathInfo.AssetKey
      local SuffixType = pathInfo.SuffixType
      local SuffixMap = pathInfo.SuffixMap
      if not isExist then
        SuffixMap.CustomAssetSuffixTypeMetaMap[SuffixType] = nil
        bMetaChanged = true
        print(bWriteLog and string.format("[CustomAsset]CustomAssetCacheManager:InitCustomAssetCacheMetaInfo Remove nonexist asset, AssetKey:%s, SuffixType:%s", tostring(AssetKey), tostring(SuffixType)))
      else
        local cacheInfo = SuffixMap.CustomAssetSuffixTypeMetaMap[SuffixType]
        if cacheInfo ~= nil then
          cacheInfo.CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.NotChecked
        end
      end
    end
    for AssetKey, SuffixMap in pairs(metaMap) do
      local hasAny = false
      for _, _ in pairs(SuffixMap.CustomAssetSuffixTypeMetaMap) do
        hasAny = true
        break
      end
      if not hasAny then
        metaMap[AssetKey] = nil
      end
    end
    self.CustomAssetCacheMetaInfo = cacheMetaInfo
  else
    print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:InitCustomAssetCacheMetaInfo Need to rebuild meta info due to parse failed or missing.")
    local UScriptGameplayStatics = import("ScriptGameplayStatics")
    local CacheRootDir = UScriptGameplayStatics.ProjectSavedDir() .. CustomAssetDefine.CustomAssetCacheFolder
    local allFiles = self:GetAllFilesInDirectoryRelative(CacheRootDir)
    cacheMetaInfo = Utility:DeepCopy(CustomAssetCacheMetaInfoDefine)
    for _, FilePath in pairs(allFiles) do
      if not string.find(FilePath, CustomAssetDefine.CustomAssetCacheMetaInfoFilePath, 1) then
        local FileRelativePath = CustomAssetDefine.CustomAssetCacheFolder .. FilePath
        local CacheInfoBuffer = self:LoadFileToArray(FileRelativePath)
        local cacheInfo
        local bNeedDelete = true
        if CacheInfoBuffer ~= nil and 0 < #CacheInfoBuffer then
          cacheInfo = PBUtility.UnPackToTableByMsg(CacheInfoBuffer, PBUtility.ProtoMessageMap.CustomAssetCacheInfo)
          if cacheInfo ~= nil then
            local CurMD5 = UScriptGameplayStatics.MD5HashByteArray(cacheInfo.Content)
            if CurMD5 == cacheInfo.AssetMD5 then
              bNeedDelete = false
              cacheInfo.CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
              cacheInfo.Content = nil
              local CustomAssetSuffixTypeMetaMap = cacheMetaInfo.CustomAssetMetaMap[cacheInfo.AssetKey]
              if CustomAssetSuffixTypeMetaMap == nil then
                CustomAssetSuffixTypeMetaMap = Utility:DeepCopy(CustomAssetSuffixTypeCacheMetaInfoDefine)
                cacheMetaInfo.CustomAssetMetaMap[cacheInfo.AssetKey] = CustomAssetSuffixTypeMetaMap
              end
              CustomAssetSuffixTypeMetaMap.CustomAssetSuffixTypeMetaMap[cacheInfo.SuffixType] = cacheInfo
            end
          end
        end
        if bNeedDelete then
          self:DeleteFileInSaved(FileRelativePath)
        end
      end
    end
    bMetaChanged = true
    self.CustomAssetCacheMetaInfo = cacheMetaInfo
  end
  if bMetaChanged or bNeedRebuildMeta then
    print(bWriteLog and "InitCustomAssetCacheMetaInfo: meta changed or rebuilt, saving.")
    self:SaveCustomAssetCacheMetaInfo()
  end
end
function CustomAssetCacheManager:SaveCustomAssetCacheMetaInfo()
  if self:IsDedicatedServer() then
    return
  end
  print(bWriteLog and "CustomAssetCacheManager:InitCustomAssetCacheMetaInfo")
  if self.CustomAssetCacheMetaInfo == nil then
    print(bWriteLog and "CustomAssetCacheManager:SaveCustomAssetCacheMetaInfo CustomAssetCacheMetaInfo == nil")
    return false
  end
  local pbBuffer = PBUtility.TablePackToPbBufferByMsg(self.CustomAssetCacheMetaInfo, PBUtility.ProtoMessageMap.CustomAssetCacheMetaInfo, nil, true)
  if pbBuffer == nil then
    print(bWriteLog and "CustomAssetCacheManager:SaveCustomAssetCacheMetaInfo pbBuffer == nil")
    return false
  end
  local bSuccess = self:SaveArrayToFile(pbBuffer, CustomAssetDefine.CustomAssetCacheMetaInfoPath)
  print(bWriteLog and "CustomAssetCacheManager:SaveCustomAssetCacheMetaInfo saveResult = " .. tostring(bSuccess))
  return bSuccess
end
function CustomAssetCacheManager:_SaveCustomAssetCacheInfo(CacheMetaInfo, AssetBytes)
  if self:IsDedicatedServer() then
    return
  end
  if CacheMetaInfo == nil then
    print(bWriteLog and "CustomAssetCacheManager:_SaveCustomAssetCacheInfo CacheMetaInfo == nil")
    return
  end
  print(bWriteLog and "CustomAssetCacheManager:_SaveCustomAssetCacheInfo AssetKey:" .. tostring(CacheMetaInfo.AssetKey) .. " SuffixType:" .. tostring(CacheMetaInfo.SuffixType))
  CacheMetaInfo.Content = AssetBytes
  local pbBuffer = PBUtility.TablePackToPbBufferByMsg(CacheMetaInfo, PBUtility.ProtoMessageMap.CustomAssetCacheInfo, nil, true)
  if pbBuffer == nil then
    print(bWriteLog and "CustomAssetCacheManager:_SaveCustomAssetCacheInfo pbBuffer == nil")
    return false
  end
  CacheMetaInfo.Content = nil
  local SavePath = self:GetCacheRelativePath(CacheMetaInfo.AssetKey, CacheMetaInfo.SuffixType)
  local bSuccess = self:SaveArrayToFile(pbBuffer, SavePath)
  if bSuccess == true and self:NeedCacheSourceFile() then
    local SourceSavePath = CustomAssetDefine.GetCustomAssetSourceCacheRelativePath(CacheMetaInfo.AssetKey, CacheMetaInfo.SuffixType)
    self:SaveArrayToFile(AssetBytes, SourceSavePath)
  end
  print(bWriteLog and "CustomAssetCacheManager:_SaveCustomAssetCacheInfo bSuccess:" .. tostring(bSuccess) .. " SavePath:" .. tostring(SavePath))
  return bSuccess
end
function CustomAssetCacheManager:_DeleteCustomAssetCacheInfo(AssetKey, SuffixType)
  if self:IsDedicatedServer() then
    return
  end
  local SavePath = self:GetCacheRelativePath(AssetKey, SuffixType)
  local DeleteSuc = self:DeleteFileInSaved(SavePath)
  print(bWriteLog and "CustomAssetCacheManager:_DeleteCustomAssetCacheInfo DeleteSuc:" .. tostring(DeleteSuc) .. " SavePath:" .. tostring(SavePath))
  return DeleteSuc
end
function CustomAssetCacheManager:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  if self.CustomAssetCacheMetaInfo == nil or self.CustomAssetCacheMetaInfo.CustomAssetMetaMap == nil then
    return nil
  end
  local CustomAssetMetaMap = self.CustomAssetCacheMetaInfo.CustomAssetMetaMap[AssetKey]
  if SuffixType == nil then
    if CustomAssetMetaMap == nil then
      return nil
    else
      return CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap
    end
  end
  if CustomAssetMetaMap == nil or CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap[SuffixType] == nil then
    return nil
  end
  return CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap[SuffixType]
end
function CustomAssetCacheManager:SetCustomAssetCacheMetaInfo(CacheMetaInfo)
  if CacheMetaInfo == nil then
    return
  end
  if self.CustomAssetCacheMetaInfo == nil then
    self.CustomAssetCacheMetaInfo = Utility:DeepCopy(CustomAssetCacheMetaInfoDefine)
  end
  local CustomAssetMetaMap = self.CustomAssetCacheMetaInfo.CustomAssetMetaMap
  if CustomAssetMetaMap == nil then
    CustomAssetMetaMap = {}
    self.CustomAssetCacheMetaInfo.  end
  local CustomAssetMetaMap_Asset = CustomAssetMetaMap[CacheMetaInfo.AssetKey]
  if CustomAssetMetaMap_Asset == nil then
    CustomAssetMetaMap_Asset = Utility:DeepCopy(CustomAssetSuffixTypeCacheMetaInfoDefine)
    self.CustomAssetCacheMetaInfo.CustomAssetMetaMap[CacheMetaInfo.AssetKey] = CustomAssetMetaMap_Asset
  end
  CustomAssetMetaMap_Asset.CustomAssetSuffixTypeMetaMap[CacheMetaInfo.SuffixType] = CacheMetaInfo
end
function CustomAssetCacheManager:GetCustomAssetCacheMetaList()
  local CacheMetaList = {}
  local CustomAssetMetaMap = self.CustomAssetCacheMetaInfo.CustomAssetMetaMap
  if CustomAssetMetaMap ~= nil then
    for AssetKey, CustomAssetMetaMap_Asset in pairs(CustomAssetMetaMap) do
      for k, CacheMetaInfo in pairs(CustomAssetMetaMap_Asset.CustomAssetSuffixTypeMetaMap) do
        table.insert(CacheMetaList, Utility:DeepCopy(CacheMetaInfo))
      end
    end
  end
  return CacheMetaList
end
function CustomAssetCacheManager:RemoveCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  if self.CustomAssetCacheMetaInfo == nil or self.CustomAssetCacheMetaInfo.CustomAssetMetaMap == nil then
    return false
  end
  local CustomAssetMetaMap = self.CustomAssetCacheMetaInfo.CustomAssetMetaMap[AssetKey]
  if CustomAssetMetaMap == nil or CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap[SuffixType] == nil then
    return false
  end
  CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap[SuffixType] = nil
  if not next(CustomAssetMetaMap.CustomAssetSuffixTypeMetaMap) then
    self.CustomAssetCacheMetaInfo.CustomAssetMetaMap[AssetKey] = nil
  end
  return true
end
function CustomAssetCacheManager:IsAssetCached(AssetKey, SuffixType)
  local CacheMetaInfo = self:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  if CacheMetaInfo == nil then
    return false
  end
  if CacheMetaInfo.CacheVerifyStatus ~= CustomAssetDefine.CustomAssetCacheVerifyStatus.NotChecked then
    return CacheMetaInfo.CacheVerifyStatus == CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
  end
  self:_UpdateAssetCacheState(AssetKey, SuffixType)
  return CacheMetaInfo.CacheVerifyStatus == CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
end
function CustomAssetCacheManager:_UpdateAssetCacheState(AssetKey, SuffixType)
  local CacheMetaInfo = self:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  if CacheMetaInfo == nil then
    return
  end
  if CacheMetaInfo.CacheVerifyStatus ~= CustomAssetDefine.CustomAssetCacheVerifyStatus.NotChecked then
    return
  end
  local CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Invalid
  if self.CustomAssetBytesMap[AssetKey] ~= nil and self.CustomAssetBytesMap[AssetKey][SuffixType] ~= nil then
    CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
  elseif not self:IsDedicatedServer() then
    local SavePath = self:GetCacheRelativePath(AssetKey, SuffixType)
    local CacheInfoBuffer = self:LoadFileToArray(SavePath)
    local CacheInfo
    local bNeedDelete = true
    if CacheInfoBuffer ~= nil and 0 < #CacheInfoBuffer then
      CacheInfo = PBUtility.UnPackToTableByMsg(CacheInfoBuffer, PBUtility.ProtoMessageMap.CustomAssetCacheInfo)
      if CacheInfo ~= nil then
        local UScriptGameplayStatics = import("ScriptGameplayStatics")
        local CurMD5 = UScriptGameplayStatics.MD5HashByteArray(CacheInfo.Content)
        if CurMD5 == CacheInfo.AssetMD5 then
          CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
          bNeedDelete = false
        end
      end
    end
    if bNeedDelete then
      self:DeleteFileInSaved(SavePath)
    end
  end
  CacheMetaInfo.end
function CustomAssetCacheManager:LoadCustomAssetFromFile(AssetKey, SuffixType, DownloaderPriority)
  if self.CustomAssetBytesMap[AssetKey] ~= nil and self.CustomAssetBytesMap[AssetKey][SuffixType] then
    return self.CustomAssetBytesMap[AssetKey][SuffixType]
  end
  if not self:IsAssetCached(AssetKey, SuffixType) then
    print(bWriteLog and "CustomAssetCacheManager:LoadCustomAssetFromFile not IsAssetCached")
    return nil
  end
  local CacheMetaInfo = self:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  if CacheMetaInfo == nil then
    return nil
  end
  local SavePath = self:GetCacheRelativePath(AssetKey, SuffixType)
  local CacheInfoBuffer = self:LoadFileToArray(SavePath)
  local CacheInfo, LoadedBytes
  local bLoaded = false
  if CacheInfoBuffer ~= nil and 0 < #CacheInfoBuffer then
    CacheInfo = PBUtility.UnPackToTableByMsg(CacheInfoBuffer, PBUtility.ProtoMessageMap.CustomAssetCacheInfo)
    if CacheInfo ~= nil then
      local UScriptGameplayStatics = import("ScriptGameplayStatics")
      local CurMD5 = UScriptGameplayStatics.MD5HashByteArray(CacheInfo.Content)
      if CurMD5 == CacheInfo.AssetMD5 then
        bLoaded = true
        LoadedBytes = CacheInfo.Content
      end
    end
  end
  if not bLoaded then
    self:_DeleteCustomAssetCacheInfo(AssetKey, SuffixType)
    if self:RemoveCustomAssetCacheMetaInfo(AssetKey, SuffixType) then
      self:SaveCustomAssetCacheMetaInfo()
    end
  else
    local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
    CacheMetaInfo.LoadCount = CacheMetaInfo.LoadCount + 1
    CacheMetaInfo.LoadTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
    self:SetCustomAssetCacheMetaInfo(CacheMetaInfo)
    self:_SaveCustomAssetCacheInfo(CacheMetaInfo, LoadedBytes)
    self:SaveCustomAssetCacheMetaInfo()
    self:_CacheAssetToMemory(AssetKey, SuffixType, LoadedBytes, DownloaderPriority)
  end
  return LoadedBytes
end
function CustomAssetCacheManager:_CacheAssetToMemory(AssetKey, SuffixType, AssetBytes, DownloaderPriority)
  if AssetBytes == nil then
    return
  end
  local bNeedCache = false
  if self:IsDedicatedServer() then
    bNeedCache = true
  elseif DownloaderPriority > CustomAssetDefine.CustomAssetDownloadPriority.VERY_HIGH then
    bNeedCache = true
  end
  if not bNeedCache then
    print(bWriteLog and "CustomAssetCacheManager:_CacheAssetToMemory not bNeedCache")
    return
  end
  local AssetBytesCache = self.CustomAssetBytesMap[AssetKey]
  if AssetBytesCache == nil then
    AssetBytesCache = {}
    self.CustomAssetBytesMap[AssetKey] = AssetBytesCache
  end
  AssetBytesCache[SuffixType] = AssetBytes
end
function CustomAssetCacheManager:_RemoveCacheAssetFormMemory(AssetKey, SuffixType)
  local AssetBytesCache = self.CustomAssetBytesMap[AssetKey]
  if AssetBytesCache == nil then
    return
  end
  if SuffixType == nil then
    self.CustomAssetBytesMap[AssetKey] = nil
  else
    AssetBytesCache[SuffixType] = nil
    if not next(AssetBytesCache) then
      self.CustomAssetBytesMap[AssetKey] = nil
    end
  end
end
function CustomAssetCacheManager:CacheAssetToFile(AssetKey, SuffixType, AssetBytes, DownloaderPriority)
  print(bWriteLog and "CustomAssetCacheManager:CacheAssetToFile AssetKey:" .. tostring(AssetKey) .. " SuffixType:" .. tostring(SuffixType) .. " AssetBytes is nil:" .. tostring(AssetBytes == nil) .. " DownloaderPriority:" .. tostring(DownloaderPriority))
  if AssetBytes == nil or AssetBytes == "" then
    return
  end
  local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
  local UScriptGameplayStatics = import("ScriptGameplayStatics")
  local CacheMetaInfo = self:GetCustomAssetCacheMetaInfo(AssetKey, SuffixType)
  local CurTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
  if CacheMetaInfo == nil then
    CacheMetaInfo = Utility:DeepCopy(CustomAssetCacheInfoDefine)
    CacheMetaInfo.    CacheMetaInfo.    CacheMetaInfo.CacheTimestamp = CurTimestamp
    CacheMetaInfo.LoadTimestamp = CurTimestamp
    CacheMetaInfo.AssetMD5 = UScriptGameplayStatics.MD5HashByteArray(AssetBytes)
    CacheMetaInfo.AssetSize = #AssetBytes
    CacheMetaInfo.LoadCount = 1
    CacheMetaInfo.CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
    self:SetCustomAssetCacheMetaInfo(CacheMetaInfo)
    self:_SaveCustomAssetCacheInfo(CacheMetaInfo, AssetBytes)
    self:SaveCustomAssetCacheMetaInfo()
  else
    self:_UpdateAssetCacheState(AssetKey, SuffixType)
    if CacheMetaInfo.CacheVerifyStatus == CustomAssetDefine.CustomAssetCacheVerifyStatus.Invalid then
      CacheMetaInfo.CacheTimestamp = CurTimestamp
      CacheMetaInfo.LoadTimestamp = CurTimestamp
      CacheMetaInfo.AssetMD5 = UScriptGameplayStatics.MD5HashByteArray(AssetBytes)
      CacheMetaInfo.AssetSize = #AssetBytes
      CacheMetaInfo.LoadCount = 1
      CacheMetaInfo.CacheVerifyStatus = CustomAssetDefine.CustomAssetCacheVerifyStatus.Valid
      self:SetCustomAssetCacheMetaInfo(CacheMetaInfo)
      self:_SaveCustomAssetCacheInfo(CacheMetaInfo, AssetBytes)
      self:SaveCustomAssetCacheMetaInfo()
    end
  end
  self:_CacheAssetToMemory(AssetKey, SuffixType, AssetBytes, DownloaderPriority)
  self:_UpdateAssetCacheState(AssetKey, SuffixType)
end
function CustomAssetCacheManager:DeleteCacheAsset(AssetKey, SuffixType)
  if AssetKey == nil or AssetKey == "" then
    print(bWriteLog and "[CustomAsset]CustomAssetCacheManager:DeleteCacheAsset invalid AssetKey")
    return
  end
  print(bWriteLog and string.format("[CustomAsset]CustomAssetCacheManager:DeleteCacheAsset AssetKey:%s SuffixType:%s", tostring(AssetKey), tostring(SuffixType)))
  self:_RemoveCacheAssetFormMemory(AssetKey, SuffixType)
  local bNeedChangeMetaInfo = false
  if SuffixType == nil then
    local CustomAssetSuffixTypeMetaMap = self:GetCustomAssetCacheMetaInfo(AssetKey)
    if CustomAssetSuffixTypeMetaMap then
      for _SuffixType, v in pairs(CustomAssetSuffixTypeMetaMap) do
        if self:RemoveCustomAssetCacheMetaInfo(AssetKey, _SuffixType) then
          bNeedChangeMetaInfo = true
        end
        self:_DeleteCustomAssetCacheInfo(AssetKey, _SuffixType)
      end
    end
  else
    if self:RemoveCustomAssetCacheMetaInfo(AssetKey, SuffixType) then
      bNeedChangeMetaInfo = true
    end
    self:_DeleteCustomAssetCacheInfo(AssetKey, SuffixType)
  end
  if bNeedChangeMetaInfo then
    self:SaveCustomAssetCacheMetaInfo()
  end
end
local class = require("class")
local CustomAssetUtilityObject = require("common.CustomAsset.CustomAssetUtilityObject")
local CCustomAssetCacheManager = class(CustomAssetUtilityObject, nil, CustomAssetCacheManager)
return CCustomAssetCacheManager
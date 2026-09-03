local CustomAssetManager = {}
local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local Utility = require("GameLua.Mod.CreativeBase.Gameplay.Meta.CreativeModeUtility")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EMountStatus = import("EMountStatus")
local CustomAssetConfigs = CustomAssetDefine.CustomAssetConfigs
local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
local CustomAssetDownloadPriority = CustomAssetDefine.CustomAssetDownloadPriority
local UScriptGameplayStatics = import("ScriptGameplayStatics")
local HashIDMinValue = CustomAssetDefine.HashIDMinValue
local CustomAssetInfoDefine = {
  AssetKey = "",
  SimpleAssetKey = "",
  SHA256Arr = nil,
  AssetSize = 0,
  AssetType = -1,
  IsCustomAssetKey = false
}
local CustomAssetDownloadCompletedInfo = {
  DownloadType = CustomAssetDefine.CustomAssetDownloadType.DownloadOnly,
  LoadSeq = 0,
  DownloadSeq = 0,
  Callback = nil
}
local CustomAssetBatchDownloadCompletedInfoDefine = {
  BatchDownloadSeq = 0,
  DownloadMap = {},
  Callback = nil
}
local CustomAssetBatchMountWaitInfoDefine = {
  BatchMountSeq = 0,
  MountMap = {},
  Callback = nil
}
local CustomAssetUploaderInfoDefine = {
  UploaderSeq = 0,
  SourceBytes = "",
  AssetKey = "",
  CustomAssetType = CustomAssetDefine.Enum_CustomAssetType.AIAnim,
  PlatformCustomAssetInfoList = nil,
  UploaderCallback = nil
}
local WaitCustomAssetHashIDInfoDefine = {
  StartWaitTimestamp = 0,
  CallbackList = {}
}
function CustomAssetManager:ctor()
  self.CustomAssetTypeMap = {}
  for Key, Value in pairs(CustomAssetDefine.Enum_CustomAssetType) do
    self.CustomAssetTypeMap[Value] = Key
  end
  self._CustomAssetManagerSeq = 1
  self.CustomAssetInfoMap = {}
  self.DeserializerMap = {}
  self.PlatformBuilderMap = {}
  self.uCustomAssetUploader = nil
  self.uCustomAssetDownloader = nil
  self.uCustomAssetCacheManager = nil
  self.LoadSeqToDownloadCompletedInfo = {}
  self.BatchDownloadWaitMap = {}
  self.DeserializeCallbackMap = {}
  self.CustomAssetKeyHashIDCheckMap = {}
  self.CurCustomAssetUploaderInfo = nil
  self.WaitCustomAssetHashIDInfoMap = {}
  self.WaitMappingTimer = nil
  self.UnmountCallBackMap = {}
  self.CurPlatformSuffixType = nil
  self.MapDependencySizeLimit = nil
  self.BatchMountWaitMap = {}
  self.BatchAssetKeyMap = {}
end
function CustomAssetManager:ReceiveBeginPlay()
  print(bWriteLog and "[CustomAsset]CustomAssetManager:ReceiveBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self.uCustomAssetUploader = self:CreateUtilityObject("CustomAssetUploader", "CustomAssetUploader")
  self.uCustomAssetDownloader = self:CreateUtilityObject("CustomAssetDownloader", "CustomAssetDownloader")
  self.uCustomAssetCacheManager = self:CreateUtilityObject("CustomAssetCacheManager", "CustomAssetCacheManager")
  self.uCustomAssetImageManager = self:CreateUtilityObject("CustomAssetImageManager", "CustomAssetImageManager")
end
function CustomAssetManager:ReceivePostBeginPlay()
  print(bWriteLog and "CustomAssetManager:PostBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
end
function CustomAssetManager:ReceiveEndPlay()
  print(bWriteLog and "[CustomAsset]CustomAssetManager:ReceiveEndPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self:DestroyUtilityObject(self.uCustomAssetUploader)
  self.uCustomAssetUploader = nil
  self:DestroyUtilityObject(self.uCustomAssetDownloader)
  self.uCustomAssetDownloader = nil
  self:DestroyUtilityObject(self.uCustomAssetCacheManager)
  self.uCustomAssetCacheManager = nil
  self:DestroyUtilityObject(self.uCustomAssetImageManager)
  self.uCustomAssetImageManager = nil
  self:DestroyPlatformBuilder()
  self:DestroyAllDeserializer()
  self.MapDependencySizeLimit = nil
end
function CustomAssetManager:IsDedicatedServer()
  if self.CacheIsDedicatedServer == nil then
    self.CacheIsDedicatedServer = self:ReceiveIsDedicatedServer()
  end
  return self.CacheIsDedicatedServer
end
function CustomAssetManager:OnFightingStatusEnter()
  print(bWriteLog and "CustomAssetManager:OnFightingStatusEnter")
  self.uCustomAssetUploader:OnFightingStatusEnter()
  self.uCustomAssetDownloader:OnFightingStatusEnter()
  self.uCustomAssetCacheManager:OnFightingStatusEnter()
  self.uCustomAssetImageManager:OnFightingStatusEnter()
  self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_HASHID_MAPPING_CHANGE, self.OnCustomAssetHashIDMappingChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_MOUNT_STATE_CHANGE, self.OnMountStateChange, self)
end
function CustomAssetManager:OnFightingStatusPreExit()
  print(bWriteLog and "CustomAssetManager:OnFightingStatusPreExit")
  if slua.isValid(self.uCustomAssetUploader) then
    self.uCustomAssetUploader:OnFightingStatusPreExit()
  end
  if slua.isValid(self.uCustomAssetImageManager) then
    self.uCustomAssetImageManager:OnFightingStatusPreExit()
  end
  self.uCustomAssetDownloader:OnFightingStatusPreExit()
  self.uCustomAssetCacheManager:OnFightingStatusPreExit()
  self:DestroyPlatformBuilder()
  self:DestroyAllDeserializer()
  self.WaitCustomAssetHashIDInfoMap = {}
  self.UnmountCallBackMap = {}
  self.BatchAssetKeyMap = {}
  self.BatchMountWaitMap = {}
  self:CheckAndEndWaitCustomAssetHashIDMapping()
  self:RemoveCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_HASHID_MAPPING_CHANGE)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_MOUNT_STATE_CHANGE)
end
function CustomAssetManager:OnFightingStatusPostExit()
  print(bWriteLog and "CustomAssetManager:OnFightingStatusPostExit")
  if slua.isValid(self.uCustomAssetUploader) then
    self.uCustomAssetUploader:OnFightingStatusPostExit()
  end
  if slua.isValid(self.uCustomAssetImageManager) then
    self.uCustomAssetImageManager:OnFightingStatusPostExit()
  end
  self.uCustomAssetDownloader:OnFightingStatusPostExit()
  self.uCustomAssetCacheManager:OnFightingStatusPostExit()
  self:PrintAliveCustomAssets()
  self:CleanupAliveCustomAssetObjects()
end
function CustomAssetManager:IsReleaseVersion()
  if self._bIsReleaseVersion == nil then
    self._bIsReleaseVersion = false
    if self:IsDedicatedServer() then
      local bIsShipping = true
      local STExtraGameplayStatics = import("STExtraGameplayStatics")
      if STExtraGameplayStatics then
        bIsShipping = STExtraGameplayStatics.IsShipping()
      end
      if bIsShipping then
        print(bWriteLog and "CustomAssetManager:IsReleaseVersion is True")
        self._bIsReleaseVersion = true
      end
    else
      local Utility = require("common.utility")
      if Utility.IsReleaseVersion() then
        print(bWriteLog and "CustomAssetManager:IsReleaseVersion is True")
        self._bIsReleaseVersion = true
      end
    end
  end
  return self._bIsReleaseVersion == true
end
function CustomAssetManager:CreateUtilityObject(ClassPath, Name)
  local uObject
  if ClassPath ~= nil and ClassPath ~= "" then
    local uDeserializerClassClass = import(ClassPath)
    uObject = CGame:NewObjectFromClass(self.Object, uDeserializerClassClass, Name)
    if slua.isValid(uObject) then
      uObject:InitUtilityObject(self)
    end
  end
  return uObject
end
function CustomAssetManager:DestroyUtilityObject(uObject)
  if slua.isValid(uObject) and uObject.LuaConditionalBeginDestroy ~= nil then
    uObject:LuaConditionalBeginDestroy()
  end
end
function CustomAssetManager:GetAssetDeserializer(CustomAssetType)
  local CustomAssetConfig = CustomAssetConfigs[CustomAssetType]
  if CustomAssetConfig == nil then
    return nil
  end
  local uDeserializer = self.DeserializerMap[CustomAssetType]
  if not slua.isValid(uDeserializer) and CustomAssetConfig.DeserializerClass ~= nil then
    local DeserializerClassPath = CustomAssetConfig.DeserializerClass
    uDeserializer = self:CreateUtilityObject(DeserializerClassPath, "CustomAssetDeserializer_" .. tostring(CustomAssetType))
    uDeserializer.DeserializeTimeout = 15.0
    self:AddControlEvent(uDeserializer, "DeserializeCompletedDelegate", self.OnDeserializeCompletedHandle, self)
    self.DeserializerMap[CustomAssetType] = uDeserializer
  end
  return uDeserializer
end
function CustomAssetManager:DestroyAllDeserializer()
  for CustomAssetType, uDeserializer in pairs(self.DeserializerMap) do
    self:DestroyUtilityObject(uDeserializer)
  end
  self.DeserializerMap = {}
end
function CustomAssetManager:GetCustomAssetDefaultBytes(CustomAssetType)
  local CustomAssetConfig = CustomAssetConfigs[CustomAssetType]
  if CustomAssetConfig == nil then
    return nil
  end
  if CustomAssetConfig.DefaultAsset ~= nil then
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    local TemplateDataFolderPath = CreativeModeBlueprintLibrary.ProjectContentDir() .. CustomAssetDefine.DefaultAssetDataDirectory .. CustomAssetConfig.DefaultAsset
    return CreativeModeBlueprintLibrary.LoadFileToArrayByFullPath(TemplateDataFolderPath)
  end
  return nil
end
function CustomAssetManager:GetAssetPlatformBuilder(CustomAssetType)
  local CustomAssetConfig = CustomAssetConfigs[CustomAssetType]
  if CustomAssetConfig == nil then
    return nil
  end
  local uPlatformBuilder = self.PlatformBuilderMap[CustomAssetType]
  if not slua.isValid(uPlatformBuilder) and CustomAssetConfig.PlatformBuilderClass ~= nil then
    local PlatformBuilderClassPath = CustomAssetConfig.PlatformBuilderClass
    uPlatformBuilder = self:CreateUtilityObject(PlatformBuilderClassPath, "CustomAssetPlatformBuilder_" .. tostring(CustomAssetType))
    self:AddControlEvent(uPlatformBuilder, "PlatformBuilderCompletedDelegate", self.OnPlatformBuilderCompletedHandle, self)
    self.PlatformBuilderMap[CustomAssetType] = uPlatformBuilder
  end
  return uPlatformBuilder
end
function CustomAssetManager:DestroyPlatformBuilder()
  for CustomAssetType, uPlatformBuilder in pairs(self.PlatformBuilderMap) do
    self:DestroyUtilityObject(uPlatformBuilder)
  end
  self.PlatformBuilderMap = {}
end
function CustomAssetManager:PrintDeserializeError(uDeserializer)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:PrintDeserializeError uDeserializer:" .. tostring(uDeserializer) .. " ErrorMsg:" .. tostring(uDeserializer:GetLastError()))
end
function CustomAssetManager:CustomAssetKeyToSimple(CustomAssetKey)
  local CustomAssetInfo = self:GetCustomAssetInfo(CustomAssetKey)
  if CustomAssetInfo ~= nil and CustomAssetInfo.IsCustomAssetKey == true then
    return CustomAssetInfo.SimpleAssetKey
  end
  return CustomAssetKey
end
function CustomAssetManager:GetCustomAssetInfo(InAssetKey)
  local AssetKey = InAssetKey
  if type(InAssetKey) == "number" then
    AssetKey = self:GetCustomAssetKeyByHashID(InAssetKey)
  end
  if AssetKey == nil or type(AssetKey) ~= "string" or AssetKey == "" then
    return nil
  end
  local CustomAssetInfo = self.CustomAssetInfoMap[AssetKey]
  if CustomAssetInfo == nil then
    CustomAssetInfo = Utility:DeepCopy(CustomAssetInfoDefine)
    local AssetType, Size, SHA256Arr = self:ParseCustomAssetKey(AssetKey)
    CustomAssetInfo.    CustomAssetInfo.Asset    CustomAssetInfo.    CustomAssetInfo.    local bIsCustonAssetKey = true
    if CustomAssetInfo.AssetType <= 0 or self.CustomAssetTypeMap[CustomAssetInfo.AssetType] == nil then
      bIsCustonAssetKey = false
    end
    if CustomAssetInfo.AssetSize <= 0 then
      bIsCustonAssetKey = false
    end
    if CustomAssetInfo.SHA256Arr == nil or #CustomAssetInfo.SHA256Arr == 0 then
      bIsCustonAssetKey = false
    else
      for i = 1, #CustomAssetInfo.SHA256Arr do
        local SHA256 = CustomAssetInfo.SHA256Arr[i]
        if string.len(SHA256) ~= 64 then
          bIsCustonAssetKey = false
          break
        end
      end
    end
    CustomAssetInfo.IsCustomAssetKey = bIsCustonAssetKey
    if bIsCustonAssetKey == true then
      if 1 < #SHA256Arr then
        local Sha256s = ""
        for i = 2, #SHA256Arr do
          Sha256s = Sha256s .. SHA256Arr[i]
        end
        local HashID = self:GetHashByString(Sha256s)
        CustomAssetInfo.SimpleAssetKey = CustomAssetDefine.SpliceCustomAssetKey(AssetType, Size, {
          SHA256Arr[1],
          tostring(HashID)
        })
      else
        CustomAssetInfo.Simple      end
    end
    self.CustomAssetInfoMap[AssetKey] = CustomAssetInfo
  end
  return CustomAssetInfo
end
function CustomAssetManager:_GetCustomAssetUseSuffixType(AssetKey)
  local AssetInfo = self:GetCustomAssetInfo(AssetKey)
  local OutSuffixType = CustomAssetDefine.Enum_CustomAssetSuffixType.Source
  if AssetInfo ~= nil then
    local CustomAssetConfig = CustomAssetConfigs[AssetInfo.AssetType]
    if CustomAssetConfig ~= nil and CustomAssetConfig.PlatformAsset ~= nil then
      if self.CurPlatformSuffixType == nil then
        self.CurPlatformSuffixType = self:GetCurPlatformSuffixType()
      end
      if CustomAssetConfig.PlatformAsset[self.CurPlatformSuffixType] == true then
        print(bWriteLog and "[CustomAsset]CustomAssetManager:_GetCustomAssetUseSuffixType Use Platform Asset CurPlatformSuffixType:" .. tostring(self.CurPlatformSuffixType))
        OutSuffixType = self.CurPlatformSuffixType
      end
    end
  end
  return OutSuffixType
end
function CustomAssetManager:_NewCustomAssetDownloadCompletedInfo()
  return Utility:DeepCopy(CustomAssetDownloadCompletedInfo)
end
function CustomAssetManager:_NewCustomAssetBatchDownloadCompletedInfo()
  return Utility:DeepCopy(CustomAssetBatchDownloadCompletedInfoDefine)
end
function CustomAssetManager:_NewCustomAssetUploaderInfo()
  return Utility:DeepCopy(CustomAssetUploaderInfoDefine)
end
function CustomAssetManager:_CustomAssetDownloadHandle(AsyncLoadSeqOrDownloadCompletedInfo, DownloadSuc, AssetKey, SuffixType, AssetBytes)
  print(bWriteLog and "CustomAssetManager:_CustomAssetDownloadHandle AssetKey:" .. tostring(AssetKey) .. " DownloadSuc:" .. tostring(DownloadSuc))
  local DownloadCompletedInfo
  if type(AsyncLoadSeqOrDownloadCompletedInfo) == "number" then
    DownloadCompletedInfo = self.LoadSeqToDownloadCompletedInfo[AsyncLoadSeqOrDownloadCompletedInfo]
    self.LoadSeqToDownloadCompletedInfo[AsyncLoadSeqOrDownloadCompletedInfo] = nil
  else
    DownloadCompletedInfo = AsyncLoadSeqOrDownloadCompletedInfo
  end
  if DownloadCompletedInfo ~= nil then
    self.LoadSeqToDownloadCompletedInfo[DownloadCompletedInfo.LoadSeq] = nil
    if DownloadCompletedInfo.DownloadType == CustomAssetDefine.CustomAssetDownloadType.DownloadAndLoad then
      if DownloadCompletedInfo.Callback ~= nil then
        DownloadCompletedInfo.Callback(AssetBytes)
      end
    elseif DownloadCompletedInfo.DownloadType == CustomAssetDefine.CustomAssetDownloadType.DownloadAndDeserialize then
      local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
      self:DeserializeCustomAsset(AssetBytes, CustomAssetInfo.AssetType, SuffixType, DownloadCompletedInfo.Callback)
    elseif DownloadCompletedInfo.DownloadType == CustomAssetDefine.CustomAssetDownloadType.DownloadOnly and DownloadCompletedInfo.Callback ~= nil then
      DownloadCompletedInfo.Callback(DownloadSuc, AssetKey)
    end
  end
end
function CustomAssetManager:_CustomAssetBatchDownloadHandle(BatchDownloadSeq, DownloadSuc, AssetKey)
  print(bWriteLog and "CustomAssetManager:_CustomAssetBatchDownloadHandle BatchDownloadSeq:" .. tostring(BatchDownloadSeq) .. " AssetKey:" .. tostring(AssetKey) .. " DownloadSuc:" .. tostring(DownloadSuc))
  local BatchDownloadWaitInfo = self.BatchDownloadWaitMap[BatchDownloadSeq]
  if BatchDownloadWaitInfo ~= nil then
    BatchDownloadWaitInfo.DownloadMap[AssetKey] = DownloadSuc
    local bAllDownloadCb = true
    local bAllDownloadSuc = true
    for AssetKey, Flag in pairs(BatchDownloadWaitInfo.DownloadMap) do
      if type(Flag) == "number" and 0 < Flag then
        bAllDownloadCb = false
        break
      elseif Flag ~= true then
        bAllDownloadSuc = false
      end
    end
    if bAllDownloadCb == true then
      self.BatchDownloadWaitMap[BatchDownloadSeq] = nil
      if BatchDownloadWaitInfo.Callback ~= nil then
        BatchDownloadWaitInfo.Callback(bAllDownloadSuc, BatchDownloadWaitInfo.DownloadMap)
      end
    end
  end
end
function CustomAssetManager:OnDeserializeCompletedHandle(uDeserializer, uObject, DeserializeSeq)
  print(bWriteLog and "CustomAssetManager:OnDeserializeCompletedHandle DeserializeSeq:" .. tostring(DeserializeSeq) .. "uObject:" .. tostring(uObject))
  local CallBackInfo = self.DeserializeCallbackMap[DeserializeSeq]
  if CallBackInfo == nil then
    return
  end
  self.DeserializeCallbackMap[DeserializeSeq] = nil
  if not slua.isValid(uObject) then
    self:PrintDeserializeError(uDeserializer)
  end
  if slua.isValid(uObject) then
    self:AddCustomAssetObjectToTrackedMap(CallBackInfo.BytesMD5, uObject, CallBackInfo.AsyncLoadStack)
  end
  CallBackInfo.Callback(uObject)
end
function CustomAssetManager:OnPlatformBuilderCompletedHandle(uPlatformBuilder, PlatformCustomAssetInfoList, BuilderSeq)
  print(bWriteLog and "CustomAssetManager:OnPlatformBuilderCompletedHandle BuilderSeq:" .. tostring(BuilderSeq))
  if self.CurCustomAssetUploaderInfo ~= nil and BuilderSeq == self.CurCustomAssetUploaderInfo.UploaderSeq then
    local _PlatformCustomAssetInfoList = {}
    self.CurCustomAssetUploaderInfo.PlatformCustomAssetInfoList = _PlatformCustomAssetInfoList
    for i = 1, PlatformCustomAssetInfoList:Num() do
      table.insert(_PlatformCustomAssetInfoList, PlatformCustomAssetInfoList:Get(i - 1))
    end
    self:RequestUploadAsset()
  end
end
function CustomAssetManager:OnUploadCompletedHandle(UploaderSeq, UploadSuc, AssetKey)
  print(bWriteLog and "CustomAssetManager:OnUploadCompletedHandle UploaderSeq:" .. tostring(UploaderSeq) .. " AssetKey:" .. tostring(AssetKey) .. " UploadSuc:" .. tostring(UploadSuc))
  if self.CurCustomAssetUploaderInfo ~= nil and UploaderSeq == self.CurCustomAssetUploaderInfo.UploaderSeq then
    local _CurCustomAssetUploaderInfo = self.CurCustomAssetUploaderInfo
    self.CurCustomAssetUploaderInfo = nil
    if _CurCustomAssetUploaderInfo.UploaderCallback ~= nil then
      if UploadSuc then
        _CurCustomAssetUploaderInfo.UploaderCallback(UploadSuc, AssetKey)
      else
        _CurCustomAssetUploaderInfo.UploaderCallback(UploadSuc)
      end
    end
  end
end
function CustomAssetManager:GetMapDependencySizeLimit()
  if self.MapDependencySizeLimit then
    return self.MapDependencySizeLimit
  end
  if slua.isValid(CGameState) then
    local AuthorLevel = CGameState.GetAuthorLevel and CGameState:GetAuthorLevel() or 0
    if not AuthorLevel or AuthorLevel == 0 then
      print(bWriteLog and "CustomAssetManager:GetMapDependencySizeLimit level still not sync = ", AuthorLevel)
      return CustomAssetDefine.MapDependencySizeLimit
    end
    local UGCAuthorLevelConfig = CDataTable.GetTableData("UGCAuthorLevelConfig", AuthorLevel)
    if UGCAuthorLevelConfig then
      self.MapDependencySizeLimit = UGCAuthorLevelConfig.AssetCapacityLimit * CustomAssetDefine.MB
      print(bWriteLog and "CustomAssetManager:GetMapDependencySizeLimit level, Size = ", AuthorLevel, UGCAuthorLevelConfig.AssetCapacityLimit)
      return self.MapDependencySizeLimit
    end
  end
  return CustomAssetDefine.MapDependencySizeLimit
end
function CustomAssetManager:IsCustomAssetKey(AssetKey, bAdaptive)
  if type(AssetKey) == "number" then
    if bAdaptive ~= false then
      return self:IsCustomAssetKeyHashID(AssetKey)
    else
      return false
    end
  end
  local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
  if CustomAssetInfo ~= nil then
    return CustomAssetInfo.IsCustomAssetKey == true
  end
  return false
end
function CustomAssetManager:GetCustomAssetSize(AssetKey)
  if not self:IsCustomAssetKey(AssetKey) then
    return 0
  end
  local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
  if CustomAssetInfo == nil then
    return 0
  end
  return CustomAssetInfo.AssetSize
end
function CustomAssetManager:GetCustomAssetType(AssetKey, bAdaptive)
  if not self:IsCustomAssetKey(AssetKey, bAdaptive) then
    return CustomAssetDefine.Enum_CustomAssetType.None
  end
  local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
  if CustomAssetInfo == nil then
    return CustomAssetDefine.Enum_CustomAssetType.None
  end
  return CustomAssetInfo.AssetType
end
function CustomAssetManager:IsCustomAssetMountNeeded(AssetKey, bAdaptive)
  local AssetType = self:GetCustomAssetType(AssetKey, bAdaptive)
  if AssetType then
    return CustomAssetDefine.MountNeededType[AssetType]
  end
  return false
end
function CustomAssetManager:GenerateSeq()
  local OutSeq = self._CustomAssetManagerSeq
  self._CustomAssetManagerSeq = self._CustomAssetManagerSeq + 1
  return OutSeq
end
function CustomAssetManager:GetCustomAssetDownloadState(AssetKey)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if not self:IsCustomAssetKey(AssetKey, false) then
    return PufferConst.ENUM_DownloadState.Not
  end
  if self:CustomAssetIsCacheed(AssetKey) then
    return PufferConst.ENUM_DownloadState.Done
  end
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  local CustomAssetInfo = self.uCustomAssetDownloader:GetDownloadInfo(AssetKey, UseSuffixType)
  if CustomAssetInfo ~= nil then
    if CustomAssetInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.SUCCESS then
      return PufferConst.ENUM_DownloadState.Done
    elseif CustomAssetInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.FAILED then
      if CustomAssetInfo.IsTimeoutFailed == true then
        return PufferConst.ENUM_DownloadState.Done
      else
        return PufferConst.ENUM_DownloadState.Error
      end
    elseif CustomAssetInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.DOWNLOADING then
      return PufferConst.ENUM_DownloadState.Download
    elseif CustomAssetInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING then
      return PufferConst.ENUM_DownloadState.Wait
    end
  end
  return PufferConst.ENUM_DownloadState.Not
end
function CustomAssetManager:AsyncLoadCustomAssetToBytes(InAssetKey, OutHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:AsyncLoadCustomAssetToBytes InAssetKey:" .. tostring(InAssetKey) .. " OutHandleFunc:" .. tostring(OutHandleFunc))
  if OutHandleFunc == nil then
    return
  end
  local args = table.pack(...)
  self:AdaptiveCustomAssetKeyAsync(InAssetKey, function(AssetKey)
    self:AsyncLoadCustomAssetToBytesImplementation(AssetKey, OutHandleFunc, table.unpack(args))
  end)
end
function CustomAssetManager:AsyncLoadCustomAssetToBytesImplementation(AssetKey, OutHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:AsyncLoadCustomAssetToBytesImplementation AssetKey:" .. tostring(AssetKey) .. " OutHandleFunc:" .. tostring(OutHandleFunc))
  if OutHandleFunc == nil then
    return
  end
  if AssetKey == nil then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    handle(nil)
    return
  end
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  print(bWriteLog and "CustomAssetManager:AsyncLoadCustomAssetToBytesImplementation UseSuffixType:" .. tostring(UseSuffixType))
  if not self.uCustomAssetCacheManager:IsAssetCached(AssetKey, UseSuffixType) then
    local AsyncLoadSeq = self:GenerateSeq()
    print(bWriteLog and "CustomAssetManager:AsyncLoadCustomAssetToBytesImplementation not IsAssetCached AsyncLoadSeq:" .. tostring(AsyncLoadSeq))
    local DownloadWaitInfo = self:_NewCustomAssetDownloadCompletedInfo()
    DownloadWaitInfo.LoadSeq = AsyncLoadSeq
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    DownloadWaitInfo.Callback = handle
    DownloadWaitInfo.DownloadType = CustomAssetDefine.CustomAssetDownloadType.DownloadAndLoad
    self.LoadSeqToDownloadCompletedInfo[AsyncLoadSeq] = DownloadWaitInfo
    DownloadWaitInfo.DownloadSeq = self.uCustomAssetDownloader:RequestDownloadAsset(AssetKey, UseSuffixType, CustomAssetDownloadPriority.LOW, self._CustomAssetDownloadHandle, self, AsyncLoadSeq)
    return AsyncLoadSeq
  else
    local AssetBytes = self.uCustomAssetCacheManager:LoadCustomAssetFromFile(AssetKey, UseSuffixType, CustomAssetDownloadPriority.LOW)
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    handle(AssetBytes)
    return 0
  end
end
function CustomAssetManager:AsyncLoadCustomAsset(InAssetKey, OutHandleFunc, OutDefaultAssetHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:AsyncLoadCustomAsset InAssetKey:" .. tostring(InAssetKey) .. " OutHandleFunc:" .. tostring(OutHandleFunc))
  if OutHandleFunc == nil then
    return
  end
  local args = table.pack(...)
  self:AdaptiveCustomAssetKeyAsync(InAssetKey, function(AssetKey)
    self:AsyncLoadCustomAssetImplementation(AssetKey, OutHandleFunc, OutDefaultAssetHandleFunc, table.unpack(args))
  end)
end
function CustomAssetManager:AsyncLoadCustomAssetImplementation(AssetKey, OutHandleFunc, OutDefaultAssetHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:AsyncLoadCustomAssetImplementation AssetKey:" .. tostring(AssetKey) .. " OutHandleFunc:" .. tostring(OutHandleFunc))
  if OutHandleFunc == nil then
    return
  end
  if AssetKey == nil then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    handle(nil)
    return
  end
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
  print(bWriteLog and "CustomAssetManager:AsyncLoadCustomAssetImplementation UseSuffixType:" .. tostring(UseSuffixType))
  if not self.uCustomAssetCacheManager:IsAssetCached(AssetKey, UseSuffixType) then
    local DefaultAssetBytes = self:GetCustomAssetDefaultBytes(CustomAssetInfo.AssetType)
    if DefaultAssetBytes ~= nil then
      self:DeserializeCustomAsset(DefaultAssetBytes, CustomAssetInfo.AssetType, CustomAssetDefine.Enum_CustomAssetSuffixType.Source, OutDefaultAssetHandleFunc, ...)
    end
    local AsyncLoadSeq = self:GenerateSeq()
    print(bWriteLog and "CustomAssetManager:AsyncLoadCustomAssetImplementation not IsAssetCached AsyncLoadSeq:" .. tostring(AsyncLoadSeq))
    local DownloadWaitInfo = self:_NewCustomAssetDownloadCompletedInfo()
    DownloadWaitInfo.LoadSeq = AsyncLoadSeq
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    DownloadWaitInfo.Callback = handle
    DownloadWaitInfo.DownloadType = CustomAssetDefine.CustomAssetDownloadType.DownloadAndDeserialize
    self.LoadSeqToDownloadCompletedInfo[AsyncLoadSeq] = DownloadWaitInfo
    DownloadWaitInfo.DownloadSeq = self.uCustomAssetDownloader:RequestDownloadAsset(AssetKey, UseSuffixType, CustomAssetDownloadPriority.VERY_HIGH, self._CustomAssetDownloadHandle, self, AsyncLoadSeq)
    return AsyncLoadSeq
  else
    local AssetBytes = self.uCustomAssetCacheManager:LoadCustomAssetFromFile(AssetKey, UseSuffixType, CustomAssetDownloadPriority.VERY_HIGH)
    self:DeserializeCustomAsset(AssetBytes, CustomAssetInfo.AssetType, UseSuffixType, OutHandleFunc, ...)
    return 0
  end
end
function CustomAssetManager:CancelLoadCustomAsset(LoadSeq)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:CancelLoadCustomAsset LoadSeq:" .. tostring(LoadSeq))
  local DownloadCompletedInfo = self.LoadSeqToDownloadCompletedInfo[LoadSeq]
  if DownloadCompletedInfo ~= nil then
    self.LoadSeqToDownloadCompletedInfo[LoadSeq] = nil
    self.uCustomAssetDownloader:CancelDownloadAsset(DownloadCompletedInfo.DownloadSeq)
    return true
  end
  return false
end
function CustomAssetManager:DeserializeCustomAsset(AssetBytes, CustomAssetType, SuffixType, OutHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:DeserializeCustomAsset CustomAssetType:" .. tostring(CustomAssetType))
  if OutHandleFunc == nil or type(OutHandleFunc) ~= "function" then
    return
  end
  if AssetBytes == nil then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:DeserializeCustomAsset AssetBytes is nil")
    OutHandleFunc((...), nil)
    return
  end
  local BytesMD5 = UScriptGameplayStatics.MD5HashByteArray(AssetBytes)
  local CacheAssetObj = self:GetCustomAssetObjectFromTrackedMap(BytesMD5)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:DeserializeCustomAsset BytesMD5:" .. tostring(BytesMD5) .. " CacheAssetObj:" .. tostring(CacheAssetObj))
  if slua.isValid(CacheAssetObj) then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    common.CallCombinationArgs(OutHandleFunc, args, CacheAssetObj)
    return
  end
  local uDeserializer = self:GetAssetDeserializer(CustomAssetType)
  if slua.isValid(uDeserializer) then
    local DeserializeSeq = self:GenerateSeq()
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    local DeserializeCallbackInfo = {
      Callback = handle,
      BytesMD5 = BytesMD5,
      AsyncLoadStack = ""
    }
    if not self:IsReleaseVersion() then
      DeserializeCallbackInfo.AsyncLoadStack = debug.traceback()
    end
    self.DeserializeCallbackMap[DeserializeSeq] = DeserializeCallbackInfo
    if not uDeserializer:Deserialize(AssetBytes, SuffixType, DeserializeSeq, self:GetCustomAssetOuter()) then
      print(bWriteLog and "[CustomAsset]CustomAssetManager:DeserializeCustomAsset Deserialize failed")
      self:PrintDeserializeError(uDeserializer)
      OutHandleFunc((...), nil)
      return
    end
  else
    print(bWriteLog and "CustomAssetManager:DeserializeCustomAsset uDeserializer not isValid")
    OutHandleFunc((...), nil)
    return
  end
end
function CustomAssetManager:UploadCustomAsset(SourceBytes, CustomAssetType, PlatformCustomAssetInfoList, IsTempUpload, AssetSuffixType, OutHandleFunc, ...)
  if not self:CheckSourceBytesIsValid(SourceBytes, CustomAssetType) then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:UploadCustomAsset SourceBytes Not IsValid")
    return 0
  end
  if not slua.isValid(self.uCustomAssetUploader) then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:UploadCustomAsset uCustomAssetUploader Not isValid")
    return 0
  end
  if self.uCustomAssetUploader:CustomAssetUploading() or self.CurCustomAssetUploaderInfo ~= nil then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:UploadCustomAsset CustomAssetUploading")
    return 0
  end
  local NewAssetKey = self:GenerateCustomAssetKey(SourceBytes, CustomAssetType)
  if NewAssetKey == nil then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:UploadCustomAsset NewAssetKey is nil")
    return 0
  end
  self.CurCustomAssetUploaderInfo = self:_NewCustomAssetUploaderInfo()
  self.CurCustomAssetUploaderInfo.UploaderSeq = self:GenerateSeq()
  self.CurCustomAssetUploaderInfo.  self.CurCustomAssetUploaderInfo.  self.CurCustomAssetUploaderInfo.AssetKey = NewAssetKey
  self.CurCustomAssetUploaderInfo.  self.CurCustomAssetUploaderInfo.  self.CurCustomAssetUploaderInfo.AssetSuffixType = AssetSuffixType or CustomAssetDefine.Enum_CustomAssetSuffixType.Source
  if OutHandleFunc ~= nil then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    self.CurCustomAssetUploaderInfo.UploaderCallback = handle
  end
  local bNeedBuildPlatformAsset = false
  if PlatformCustomAssetInfoList == nil then
    local uPlatformBuilder = self:GetAssetPlatformBuilder(CustomAssetType)
    if slua.isValid(uPlatformBuilder) then
      bNeedBuildPlatformAsset = true
    end
  end
  if bNeedBuildPlatformAsset then
    self:DeserializeCustomAsset(SourceBytes, CustomAssetType, CustomAssetDefine.Enum_CustomAssetSuffixType.Source, self._OnSourceObjectDeserializeCompletedHandle, self, self.CurCustomAssetUploaderInfo.UploaderSeq)
  else
    self:RequestUploadAsset()
  end
  return self.CurCustomAssetUploaderInfo.UploaderSeq
end
function CustomAssetManager:CheckSourceBytesIsValid(SourceBytes, CustomAssetType)
  if SourceBytes == nil or SourceBytes == "" then
    return false
  end
  local CustomAssetConfig = CustomAssetConfigs[CustomAssetType]
  if CustomAssetConfig == nil then
    return false
  end
  return true
end
function CustomAssetManager:_OnSourceObjectDeserializeCompletedHandle(UploaderSeq, uAssetObject)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:_OnSourceObjectDeserializeCompletedHandle UploaderSeq:" .. tostring(UploaderSeq) .. " uAssetObject:" .. tostring(uAssetObject))
  if self.CurCustomAssetUploaderInfo ~= nil and UploaderSeq == self.CurCustomAssetUploaderInfo.UploaderSeq then
    local uPlatformBuilder = self:GetAssetPlatformBuilder(self.CurCustomAssetUploaderInfo.CustomAssetType)
    if slua.isValid(uPlatformBuilder) then
      if not uPlatformBuilder:StartBuild(self.CurCustomAssetUploaderInfo.SourceBytes, self.CurCustomAssetUploaderInfo.UploaderSeq, uAssetObject) then
        print(bWriteLog and "[CustomAsset]CustomAssetManager:_OnSourceObjectDeserializeCompletedHandle StartBuild failed")
        self:PrintDeserializeError(uPlatformBuilder)
        self:RequestUploadAsset()
      end
    else
      self:RequestUploadAsset()
    end
  end
end
function CustomAssetManager:RequestUploadAsset()
  if self.CurCustomAssetUploaderInfo ~= nil then
    self.uCustomAssetUploader:RequestUploadAsset(self.CurCustomAssetUploaderInfo.AssetKey, self.CurCustomAssetUploaderInfo.SourceBytes, self.CurCustomAssetUploaderInfo.PlatformCustomAssetInfoList, self.CurCustomAssetUploaderInfo.IsTempUpload, self.CurCustomAssetUploaderInfo.AssetSuffixType, self.OnUploadCompletedHandle, self, self.CurCustomAssetUploaderInfo.UploaderSeq)
  end
end
function CustomAssetManager:CustomAssetIsCacheed(InAssetKey)
  local AssetKey = self:AdaptiveCustomAssetKey(InAssetKey)
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  return self.uCustomAssetCacheManager:IsAssetCached(AssetKey, UseSuffixType)
end
function CustomAssetManager:GetCustomAssetCacheMetaList()
  return self.uCustomAssetCacheManager:GetCustomAssetCacheMetaList()
end
function CustomAssetManager:GetCustomAssetCacheMetaInfo(AssetKey)
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  return self.uCustomAssetCacheManager:GetCustomAssetCacheMetaInfo(AssetKey, UseSuffixType)
end
function CustomAssetManager:DownloadCustomAsset(InAssetKey, OutHandleFunc, ...)
  local AssetKey = InAssetKey
  print(bWriteLog and "[CustomAsset]CustomAssetManager:DownloadCustomAsset InAssetKey:" .. tostring(InAssetKey) .. " AssetKey:" .. tostring(AssetKey))
  if not self:IsCustomAssetKey(AssetKey, false) then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:DownloadCustomAsset InAssetKey not IsCustomAssetKey")
    if OutHandleFunc ~= nil then
      local common = require("client.slua_ui_framework.common")
      local args = table.pack(...)
      local handle = function(...)
        return common.CallCombinationArgs(OutHandleFunc, args, ...)
      end
      handle(false, AssetKey)
    end
    return 0
  end
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:DownloadCustomAsset UseSuffixType:" .. tostring(UseSuffixType))
  if not self.uCustomAssetCacheManager:IsAssetCached(AssetKey, UseSuffixType) then
    local DownloadWaitInfo = self:_NewCustomAssetDownloadCompletedInfo()
    if OutHandleFunc ~= nil then
      local common = require("client.slua_ui_framework.common")
      local args = table.pack(...)
      local handle = function(...)
        return common.CallCombinationArgs(OutHandleFunc, args, ...)
      end
      DownloadWaitInfo.Callback = handle
    end
    DownloadWaitInfo.DownloadType = CustomAssetDefine.CustomAssetDownloadType.DownloadOnly
    DownloadWaitInfo.DownloadSeq = self.uCustomAssetDownloader:RequestDownloadAsset(AssetKey, UseSuffixType, CustomAssetDownloadPriority.LOW, self._CustomAssetDownloadHandle, self, DownloadWaitInfo)
    print(bWriteLog and "[CustomAsset]CustomAssetManager:DownloadCustomAsset not IsAssetCached DownloadSeq:" .. tostring(DownloadWaitInfo.DownloadSeq))
    return DownloadWaitInfo.DownloadSeq
  else
    if OutHandleFunc ~= nil then
      local common = require("client.slua_ui_framework.common")
      local args = table.pack(...)
      local handle = function(...)
        return common.CallCombinationArgs(OutHandleFunc, args, ...)
      end
      handle(true, AssetKey)
    end
    return 0
  end
end
function CustomAssetManager:DownloadCustomAssetList(AssetKeyList, OutHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetManager:DownloadCustomAssetList AssetKeyList:" .. tostring(AssetKeyList))
  local NeedDownloadAssetKeyList = {}
  if AssetKeyList ~= nil then
    for i = 1, #AssetKeyList do
      local AssetKey = AssetKeyList[i]
      if self:IsCustomAssetKey(AssetKey, false) then
        local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
        if not self.uCustomAssetCacheManager:IsAssetCached(AssetKey, UseSuffixType) then
          table.insert(NeedDownloadAssetKeyList, AssetKey)
        end
      end
    end
  end
  if 0 < #NeedDownloadAssetKeyList then
    local BatchDownloadSeq = self:GenerateSeq()
    print(bWriteLog and "CustomAssetManager:DownloadCustomAssetList BatchDownloadSeq:" .. tostring(BatchDownloadSeq))
    local BatchDownloadWaitInfo = self:_NewCustomAssetBatchDownloadCompletedInfo()
    BatchDownloadWaitInfo.    if OutHandleFunc ~= nil then
      local common = require("client.slua_ui_framework.common")
      local args = table.pack(...)
      local handle = function(...)
        return common.CallCombinationArgs(OutHandleFunc, args, ...)
      end
      BatchDownloadWaitInfo.Callback = handle
    end
    self.BatchDownloadWaitMap[BatchDownloadSeq] = BatchDownloadWaitInfo
    for i = 1, #NeedDownloadAssetKeyList do
      local AssetKey = NeedDownloadAssetKeyList[i]
      BatchDownloadWaitInfo.DownloadMap[AssetKey] = self:DownloadCustomAsset(AssetKey, self._CustomAssetBatchDownloadHandle, self, BatchDownloadSeq)
    end
    return BatchDownloadSeq
  else
    if OutHandleFunc ~= nil then
      local common = require("client.slua_ui_framework.common")
      local args = table.pack(...)
      local handle = function(...)
        return common.CallCombinationArgs(OutHandleFunc, args, ...)
      end
      handle(true)
    end
    return 0
  end
end
function CustomAssetManager:CancelDownloadAsset(DownloadSeq)
  local bCancelSuc = false
  if self.BatchDownloadWaitMap[DownloadSeq] ~= nil then
    local BatchDownloadWaitInfo = self.BatchDownloadWaitMap[DownloadSeq]
    self.BatchDownloadWaitMap[DownloadSeq] = nil
    for AssetKey, Flag in pairs(BatchDownloadWaitInfo.DownloadMap) do
      if type(Flag) == "number" and 0 < Flag then
        self.uCustomAssetDownloader:CancelDownloadAsset(Flag)
      end
    end
    bCancelSuc = true
    print(bWriteLog and "[CustomAsset]CustomAssetManager:CancelDownloadAsset DownloadSeq:" .. tostring(DownloadSeq) .. ", Batch")
    return bCancelSuc, BatchDownloadWaitInfo.DownloadMap
  else
    bCancelSuc = self.uCustomAssetDownloader:CancelDownloadAsset(DownloadSeq)
    print(bWriteLog and "[CustomAsset]CustomAssetManager:CancelDownloadAsset DownloadSeq:" .. tostring(DownloadSeq) .. " bCancelSuc:" .. tostring(bCancelSuc))
    return bCancelSuc
  end
end
function CustomAssetManager:ForceCancelAllDownload()
  self.uCustomAssetDownloader:ForceCancelAllDownload()
end
function CustomAssetManager:CacheCustomAssetBytes(AssetKey, SuffixType, AssetBytes, DownloaderPriority)
  self.uCustomAssetCacheManager:CacheAssetToFile(AssetKey, SuffixType, AssetBytes, DownloaderPriority)
end
function CustomAssetManager:DeleteCacheCustomAsset(AssetKey, SuffixType)
  if not self:IsCustomAssetKey(AssetKey) then
    return
  end
  if GameStatus.IsInFightingNotMainCity() and _G.IsEditor ~= true then
    print(bWriteLog and "CustomAssetManager:DeleteCacheCustomAsset In Fighting")
    return
  end
  self.uCustomAssetCacheManager:DeleteCacheAsset(AssetKey, SuffixType)
  self.uCustomAssetDownloader:DeleteCacheAsset(AssetKey, SuffixType)
end
function CustomAssetManager:DeleteCacheCustomAssetList(AssetKeyList)
  if AssetKeyList == nil then
    return
  end
  local TLogInfoMap = {}
  for i = 1, CustomAssetDefine.ENUM_PREFAB_TYPE.CUSTOMUI do
    TLogInfoMap[i] = {TotalCount = 0, TotalSize = 0}
  end
  for i = 1, #AssetKeyList do
    local AssetKey = AssetKeyList[i]
    local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
    if CustomAssetInfo then
      local CustomAssetConfig = CustomAssetConfigs[CustomAssetInfo.AssetType]
      local Info = TLogInfoMap[CustomAssetConfig.ToPrefabType]
      if Info then
        Info.TotalCount = Info.TotalCount + 1
        Info.TotalSize = Info.TotalSize + CustomAssetInfo.AssetSize
      end
    end
    self:DeleteCacheCustomAsset(AssetKey)
  end
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  local str = string.format("PREFAB=%d&CODE=%d&ANIM=%d&SOUND=%d&STATICMESH=%d&IMAGE=%d&CUSTOMUI=%d", TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.PREFAB].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.CODE].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.SOUND].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.STATICMESH].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.IMAGE].TotalCount, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.CUSTOMUI].TotalCount)
  UGCTLogReport:ReportDelay(TLogEventDefine.CustomAssetCacheClearCount, 0, str)
  str = string.format("PREFAB=%d&CODE=%d&ANIM=%d&SOUND=%d&STATICMESH=%d&IMAGE=%d&CUSTOMUI=%d", TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.PREFAB].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.CODE].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.SOUND].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.STATICMESH].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.IMAGE].TotalSize, TLogInfoMap[CustomAssetDefine.ENUM_PREFAB_TYPE.CUSTOMUI].TotalSize)
  UGCTLogReport:ReportDelay(TLogEventDefine.CustomAssetCacheClearSize, 0, str)
end
function CustomAssetManager:OnRepUnmountCustomAssetHandle(CustomAssetKey, bUnmountSuc, ErrorCode)
  print(bWriteLog and "CustomAssetManager:OnRepUnmountCustomAssetHandle CustomAssetKey:" .. tostring(CustomAssetKey) .. " ErrorCode:" .. tostring(ErrorCode))
  if bUnmountSuc == true then
    self:_CallUnmountCallBack(CustomAssetKey, CustomAssetDefine.Enum_CustomAssetErrorCode.None)
  else
    self:_CallUnmountCallBack(CustomAssetKey, ErrorCode)
  end
end
function CustomAssetManager:_CallUnmountCallBack(CustomAssetKey, ErrorCode)
  local AssetUnmountCallBackList = self.UnmountCallBackMap[CustomAssetKey]
  self.UnmountCallBackMap[CustomAssetKey] = nil
  if AssetUnmountCallBackList ~= nil then
    for i = 1, #AssetUnmountCallBackList do
      local bUnmountSuc = ErrorCode == CustomAssetDefine.Enum_CustomAssetErrorCode.None
      AssetUnmountCallBackList[i](bUnmountSuc, ErrorCode)
    end
  end
end
function CustomAssetManager:_GetMountPlayerKey()
  local MountPlayerKey = 0
  if not self:IsDedicatedServer() and GameStatus.IsInFightingNotMainCity() then
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      MountPlayerKey = uPlayerState:GetPlayerKey()
    end
  end
  return MountPlayerKey
end
function CustomAssetManager:MountCustomAsset(AssetKey, bIsAutoMount, MappingInfo)
  print(bWriteLog and "CustomAssetManager:MountCustomAsset AssetKey:" .. tostring(AssetKey) .. " bIsAutoMount:" .. tostring(bIsAutoMount) .. " MappingInfo:" .. tostring(MappingInfo))
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:MountCustomAsset(AssetKey, bIsAutoMount, self:_GetMountPlayerKey(), MappingInfo)
    end
  end
  return CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal
end
function CustomAssetManager:_CustomAssetBatchMountHandle(BatchMountSeq, AssetKey, bMountSuc)
  print(bWriteLog and "CustomAssetManager:_CustomAssetBatchMountHandle BatchMountSeq:" .. tostring(BatchMountSeq) .. " AssetKey:" .. tostring(AssetKey) .. " bMountSuc:" .. tostring(bMountSuc))
  local BatchMountWaitInfo = self.BatchMountWaitMap[BatchMountSeq]
  if BatchMountWaitInfo ~= nil then
    BatchMountWaitInfo.MountMap[AssetKey] = bMountSuc
    local bAllMountCb = true
    local bAllMountSuc = true
    for AssetKey, Flag in pairs(BatchMountWaitInfo.MountMap) do
      if type(Flag) == "number" and 0 < Flag then
        bAllMountCb = false
        break
      elseif Flag ~= true then
        bAllMountSuc = false
      end
    end
    if bAllMountCb == true then
      self.BatchMountWaitMap[BatchMountSeq] = nil
      EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_MOUNT_STATE_CHANGE_LIST, bAllMountSuc, BatchMountWaitInfo.MountMap)
      if BatchMountWaitInfo.Callback ~= nil then
        BatchMountWaitInfo.Callback(bAllMountSuc, BatchMountWaitInfo.MountMap)
      end
    end
  end
end
function CustomAssetManager:MountCustomAssetList(AssetKeyList, IsAutoMount, Callback)
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal
  end
  if AssetKeyList == nil or #AssetKeyList == 0 then
    return CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal
  end
  print(bWriteLog and "CustomAssetManager:MountCustomAssetList AssetKeyList count:" .. tostring(#AssetKeyList))
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      local CheckErrCode = uMountStateComponent:CheckCanMountCustomAsset(AssetKeyList, IsAutoMount)
      if CheckErrCode ~= CustomAssetDefine.Enum_CustomAssetErrorCode.None then
        print(bWriteLog and "CustomAssetManager:MountCustomAssetList CheckCanMountCustomAsset failed CheckErrCode:" .. tostring(CheckErrCode))
        return CheckErrCode
      end
      self.BatchMountSeq = (self.BatchMountSeq or 0) + 1
      local BatchMountSeq = self.BatchMountSeq
      local BatchMountWaitInfo = {
        BatchMountSeq = BatchMountSeq,
        MountMap = {},
              }
      for i = 1, #AssetKeyList do
        BatchMountWaitInfo.MountMap[AssetKeyList[i]] = 1
      end
      self.BatchMountWaitMap[BatchMountSeq] = BatchMountWaitInfo
      local MountPlayerKey = self:_GetMountPlayerKey()
      for i = 1, #AssetKeyList do
        local AssetKey = AssetKeyList[i]
        if self:CustomAssetIsMounted(AssetKey) then
          self:_CustomAssetBatchMountHandle(BatchMountSeq, AssetKey, true)
        else
          if self.BatchAssetKeyMap[AssetKey] == nil then
            self.BatchAssetKeyMap[AssetKey] = {}
          end
          table.insert(self.BatchAssetKeyMap[AssetKey], BatchMountSeq)
          uMountStateComponent:MountCustomAsset(AssetKey, IsAutoMount, MountPlayerKey, nil)
        end
      end
      return CustomAssetDefine.Enum_CustomAssetErrorCode.None
    end
  end
  return CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal
end
function CustomAssetManager:UnmountCustomAsset(AssetKey, UnmountCallBack, ...)
  print(bWriteLog and "CustomAssetManager:UnmountCustomAsset AssetKey:" .. tostring(AssetKey))
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return false
  end
  if UnmountCallBack ~= nil then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(UnmountCallBack, args, ...)
    end
    local AssetUnmountCallBackList = self.UnmountCallBackMap[AssetKey]
    if AssetUnmountCallBackList == nil then
      AssetUnmountCallBackList = {}
      self.UnmountCallBackMap[AssetKey] = AssetUnmountCallBackList
    end
    table.insert(AssetUnmountCallBackList, handle)
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      local CallErrorCode = uMountStateComponent:UnmountCustomAsset(AssetKey, self:_GetMountPlayerKey())
      if CallErrorCode ~= CustomAssetDefine.Enum_CustomAssetErrorCode.None then
        self:_CallUnmountCallBack(AssetKey, CallErrorCode)
        return false
      else
        return true
      end
    end
  end
  self:_CallUnmountCallBack(AssetKey, CustomAssetDefine.Enum_CustomAssetErrorCode.UnmountCustomAssetError_Normal)
  return false
end
function CustomAssetManager:CustomAssetIsMounted(AssetKey)
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return false
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:CustomAssetIsMounted(AssetKey)
    end
  end
  return false
end
function CustomAssetManager:GetMountedCustomAssetMap()
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return {}
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:GetMountedCustomAssetMap()
    end
  end
  return {}
end
function CustomAssetManager:GetMountedCustomSize()
  local CurSize = 0
  local LoadedAssetMap = self:GetMountedCustomAssetMap()
  if LoadedAssetMap then
    for _, AssetMountStatusInfo in pairs(LoadedAssetMap) do
      if AssetMountStatusInfo then
        local AssetInfo = AssetMountStatusInfo.CustomAssetInfo
        if AssetInfo then
          CurSize = CurSize + AssetInfo.AssetSize
        end
      end
    end
  end
  return CurSize
end
function CustomAssetManager:GetCustomAssetMountedInfo(AssetKey)
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return nil
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:GetCustomAssetMountedInfo(AssetKey)
    end
  end
  return nil
end
function CustomAssetManager:OnMountStateChange(_, _, AssetKey)
  if not Client then
    return
  end
  local MountInfo = self:GetCustomAssetMountedInfo(AssetKey)
  if MountInfo == nil then
    return
  end
  if MountInfo ~= nil and MountInfo.MountStatus == EMountStatus.Mounting then
    return
  end
  local BatchMountSeqs = self.BatchAssetKeyMap[AssetKey]
  if BatchMountSeqs then
    for _, Seq in ipairs(BatchMountSeqs) do
      local bMountSuc = false
      if MountInfo ~= nil and MountInfo.MountStatus == EMountStatus.Mounted then
        bMountSuc = true
      end
      self:_CustomAssetBatchMountHandle(Seq, AssetKey, bMountSuc)
    end
    self.BatchAssetKeyMap[AssetKey] = nil
  end
end
function CustomAssetManager:OnCustomAssetHashIDMappingChange(_, __)
  for HashID, WaitCustomAssetHashIDInfo in pairs(self.WaitCustomAssetHashIDInfoMap) do
    local CustomAssetKey = self:GetCustomAssetKeyByHashID(HashID)
    if CustomAssetKey ~= nil then
      self.WaitCustomAssetHashIDInfoMap[HashID] = nil
      for i = 1, #WaitCustomAssetHashIDInfo.CallbackList do
        WaitCustomAssetHashIDInfo.CallbackList[i](CustomAssetKey)
      end
    end
  end
  self:CheckAndEndWaitCustomAssetHashIDMapping()
end
function CustomAssetManager:AdaptiveCustomAssetKeyAsync(AssetKeyOrHashID, OutHandleFunc, ...)
  if OutHandleFunc == nil then
    return
  end
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(OutHandleFunc, args, ...)
  end
  if self:IsCustomAssetKeyHashID(AssetKeyOrHashID) then
    local CustomAssetKey = self:GetCustomAssetKeyByHashID(AssetKeyOrHashID)
    if CustomAssetKey ~= nil then
      handle(CustomAssetKey)
    else
      local WaitCustomAssetHashIDInfo = self.WaitCustomAssetHashIDInfoMap[AssetKeyOrHashID]
      if WaitCustomAssetHashIDInfo == nil then
        WaitCustomAssetHashIDInfo = Utility:DeepCopy(WaitCustomAssetHashIDInfoDefine)
        WaitCustomAssetHashIDInfo.StartWaitTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
        self.WaitCustomAssetHashIDInfoMap[AssetKeyOrHashID] = WaitCustomAssetHashIDInfo
      end
      table.insert(WaitCustomAssetHashIDInfo.CallbackList, handle)
      self:StartWaitCustomAssetHashIDMapping()
    end
  else
    handle(AssetKeyOrHashID)
  end
end
function CustomAssetManager:StartWaitCustomAssetHashIDMapping()
  if self.WaitMappingTimer ~= nil then
    return
  end
  local bCanStart = false
  if next(self.WaitCustomAssetHashIDInfoMap) ~= nil then
    bCanStart = true
  end
  if bCanStart then
    self.WaitMappingTimer = self:AddGameTimer(1, true, function()
      self:_TickWaitCustomAssetHashIDMapping()
    end)
  end
end
function CustomAssetManager:_TickWaitCustomAssetHashIDMapping()
  print(bWriteLog and "CustomAssetManager:_TickWaitCustomAssetHashIDMapping")
  local CurTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
  for HashID, WaitCustomAssetHashIDInfo in pairs(self.WaitCustomAssetHashIDInfoMap) do
    if CurTimestamp - WaitCustomAssetHashIDInfo.StartWaitTimestamp >= CustomAssetDefine.WaitMappingTime then
      self.WaitCustomAssetHashIDInfoMap[HashID] = nil
      for i = 1, #WaitCustomAssetHashIDInfo.CallbackList do
        WaitCustomAssetHashIDInfo.CallbackList[i](nil)
      end
    end
  end
  self:CheckAndEndWaitCustomAssetHashIDMapping()
end
function CustomAssetManager:CheckAndEndWaitCustomAssetHashIDMapping()
  if self.WaitMappingTimer == nil then
    return
  end
  local bCanEnd = true
  if next(self.WaitCustomAssetHashIDInfoMap) ~= nil then
    bCanEnd = false
  end
  if bCanEnd and self.WaitMappingTimer ~= nil then
    self:RemoveGameTimer(self.WaitMappingTimer)
    self.WaitMappingTimer = nil
  end
end
function CustomAssetManager:AdaptiveCustomAssetKey(AssetKeyOrHashID)
  if self:IsCustomAssetKeyHashID(AssetKeyOrHashID) then
    return self:GetCustomAssetKeyByHashID(AssetKeyOrHashID)
  end
  return AssetKeyOrHashID
end
local _CacheSha256Arr = {}
function CustomAssetManager:GenerateCustomAssetKey(AssetBytes, CustomAssetType, PlatformAssetBytesArr)
  if AssetBytes == nil then
    print(bWriteLog and "[CustomAsset]CustomAssetManager:GenerateCustomAssetKey AssetBytes is nil")
    return nil
  end
  local SizeBytes = #AssetBytes
  local ScriptHelperClient = import("ScriptHelperClient")
  local Sha256 = ScriptHelperClient.SHA256Bytes(AssetBytes)
  table.insert(_CacheSha256Arr, Sha256)
  if PlatformAssetBytesArr ~= nil then
    for i = 1, #PlatformAssetBytesArr do
      local PlatformAssetBytes = PlatformAssetBytesArr[i]
      table.insert(_CacheSha256Arr, ScriptHelperClient.SHA256Bytes(PlatformAssetBytes))
    end
  end
  local AssetKey = CustomAssetDefine.SpliceCustomAssetKey(CustomAssetType, SizeBytes, _CacheSha256Arr)
  for Key, _ in pairs(_CacheSha256Arr) do
    _CacheSha256Arr[Key] = nil
  end
  print(bWriteLog and "[CustomAsset]CustomAssetManager:GenerateCustomAssetKey assetKey:" .. tostring(AssetKey))
  return AssetKey
end
function CustomAssetManager:ParseCustomAssetKey(AssetKey)
  local SHA256Arr = {}
  local SizeBytes = 0
  local AssetType = -1
  if AssetKey == nil then
    return AssetType, SizeBytes, SHA256Arr
  end
  if type(AssetKey) == "string" then
    local a, b, c = string.match(AssetKey, "^" .. CustomAssetDefine.CustomAssetKeyTag .. "%-([^%-]+)%-(%d+)%-(.+)$")
    if a and b and c then
      AssetType = tonumber(a) or -1
      SizeBytes = tonumber(b) or 0
      for sha in string.gmatch(c, "[^_]+") do
        table.insert(SHA256Arr, sha)
      end
      return AssetType, SizeBytes, SHA256Arr
    end
  end
  print(bWriteLog and "[CustomAsset]CustomAssetManager:ParseCustomAssetKey Unable to parse key, fallback to zeros.")
  return AssetType, SizeBytes, SHA256Arr
end
function CustomAssetManager:GenerateCustomAssetKeyHashID(AssetKey)
  if type(AssetKey) ~= "string" then
    return 0
  end
  if self:IsCustomAssetKey(AssetKey) then
    local CustomAssetInfo = self:GetCustomAssetInfo(AssetKey)
    if CustomAssetInfo then
      local GenerateHashID = self:GenerateHashIDByCustomAssetKey(AssetKey, CustomAssetInfo.AssetType, CustomAssetDefine.CustomAssetKeyHashIDTag)
      return GenerateHashID
    end
  end
  return 0
end
function CustomAssetManager:IsCustomAssetKeyHashID(HashID)
  if type(HashID) ~= "number" then
    return false
  end
  if HashID <= HashIDMinValue then
    return false
  end
  if self.CustomAssetKeyHashIDCheckMap[HashID] == nil then
    local CustomAssetType = 0
    local UniqueId = 0
    local bParseSuc = false
    local bIsHashID = false
    bParseSuc, CustomAssetType, UniqueId = self:ParseCustomAssetKeyHashID(HashID, CustomAssetDefine.CustomAssetKeyHashIDTag, CustomAssetType, UniqueId)
    if bParseSuc and 0 < CustomAssetType and self.CustomAssetTypeMap[CustomAssetType] ~= nil then
      bIsHashID = true
    end
    self.CustomAssetKeyHashIDCheckMap[HashID] = bIsHashID
  end
  return self.CustomAssetKeyHashIDCheckMap[HashID] == true
end
function CustomAssetManager:GetCustomAssetKeyByHashID(HashID)
  if not self:IsCustomAssetKeyHashID(HashID) then
    return nil
  end
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return nil
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:GetCustomAssetKeyByHashID(HashID)
    end
  end
  return nil
end
function CustomAssetManager:GetHashIDByCustomAssetKey(AssetKey)
  if not self:IsCustomAssetKey(AssetKey) then
    return 0
  end
  if not self:IsDedicatedServer() and not GameStatus.IsInFightingNotMainCity() then
    return 0
  end
  if slua.isValid(CGameState) and CGameState.GetCustomAssetMountStateComponent ~= nil then
    local uMountStateComponent = CGameState:GetCustomAssetMountStateComponent()
    if slua.isValid(uMountStateComponent) then
      return uMountStateComponent:GetHashIDByCustomAssetKey(AssetKey)
    end
  end
  return 0
end
function CustomAssetManager:ClearUnusedCustomAssetKeyHashIDs(custom_asset_key_list, binData)
  local KeepMap = {}
  if custom_asset_key_list ~= nil then
    for i = 1, #custom_asset_key_list do
      KeepMap[custom_asset_key_list[i]] = true
    end
  end
  local GameParameterData = binData.GameParameterData
  if GameParameterData then
    local GameParameterDataMap = GameParameterData["1"]
    if GameParameterDataMap ~= nil then
      local InGameCustomAssetKeyMappingInfo = GameParameterDataMap.InGameCustomAssetKeyMapping
      if InGameCustomAssetKeyMappingInfo ~= nil then
        local InGameCustomAssetKeyMapping = InGameCustomAssetKeyMappingInfo.Value
        if InGameCustomAssetKeyMapping ~= nil then
          for AssetKey, HashID in pairs(InGameCustomAssetKeyMapping) do
            if not KeepMap[AssetKey] then
              InGameCustomAssetKeyMapping[AssetKey] = nil
            end
          end
        end
      end
    end
  end
end
function CustomAssetManager:GetCustomAssetObjectKey(AssetKey)
  local UseSuffixType = self:_GetCustomAssetUseSuffixType(AssetKey)
  return CustomAssetDefine.GetCustomAssetObjectKey(AssetKey, UseSuffixType)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CCustomAssetManager = class(CDelegateContainer, nil, CustomAssetManager)
return CCustomAssetManager
local CustomAssetDownloader = {}
local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local CustomAssetUtil = require("common.CustomAsset.CustomAssetUtil")
local TableUtil = require("common.table_util")
local CustomAssetDownloadCallbackInfoDefine = {DownloadSeq = 0, CallbackHandle = nil}
local CustomAssetDownloadInfoDefine = {
  AssetKey = 0,
  SuffixType = "",
  FirstDownloadSeq = 0,
  DownloaderPriority = CustomAssetDefine.CustomAssetDownloadPriority.VERY_LOW,
  RequestCount = 0,
  DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.NONE,
  IsTimeoutFailed = false,
  StartDownLoadTimestamp = 0,
  TimeoutCount = 0,
  DownloadCallbackMap = {}
}
function CustomAssetDownloader:ctor()
  self.DownloadInfoQueue = {}
  self.DownloadSeqToDownloadInfoMap = {}
  self.WaitDownloadCallbackTimer = nil
end
function CustomAssetDownloader:ReceiveBeginPlay()
  CustomAssetDownloader.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "[CustomAsset]CustomAssetDownloader:ReceiveBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_DS_CUSTOM_ASSET_GET_RSP, self.CustomAssetUGCProxyGetRsp, self)
end
function CustomAssetDownloader:ReceivePostBeginPlay()
  CustomAssetDownloader.__super.ReceivePostBeginPlay(self)
  print(bWriteLog and "CustomAssetDownloader:PostBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
end
function CustomAssetDownloader:ReceiveEndPlay()
  print(bWriteLog and "[CustomAsset]CustomAssetDownloader:ReceiveEndPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self.DownloadInfoQueue = {}
  self:CheckAndEndWaitDownloadCallbackTimer()
  CustomAssetDownloader.__super.ReceiveEndPlay(self)
end
function CustomAssetDownloader:OnFightingStatusEnter()
  print(bWriteLog and "CustomAssetDownloader:OnFightingStatusEnter")
  self:ClearTimeoutDownloadInfo()
end
function CustomAssetDownloader:OnFightingStatusPreExit()
  print(bWriteLog and "CustomAssetDownloader:OnFightingStatusExit")
  self:ClearTimeoutDownloadInfo()
end
function CustomAssetDownloader:ClearTimeoutDownloadInfo()
  print(bWriteLog and "CustomAssetDownloader:ClearTimeoutDownloadInfo")
  for i = #self.DownloadInfoQueue, 1, -1 do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.FAILED and DownloadInfo.IsTimeoutFailed == true then
      table.remove(self.DownloadInfoQueue, i)
    end
  end
end
function CustomAssetDownloader:CustomAssetUGCProxyGetRsp(_, __, err_code, object_name, object_data)
  local UScriptGameplayStatics = import("ScriptGameplayStatics")
  local ObjectDataMD5 = UScriptGameplayStatics.MD5HashByteArray(object_data)
  print(bWriteLog and "CustomAssetDownloader:CustomAssetUGCProxyGetRsp err_code:" .. tostring(err_code) .. " object_name:" .. tostring(object_name) .. " ObjectDataMD5:" .. tostring(ObjectDataMD5))
  local AssetKey, SuffixType = CustomAssetDefine.ParseObjectKeyToAssetKeyAndSuffixType(object_name)
  print(bWriteLog and "CustomAssetDownloader:CustomAssetUGCProxyGetRsp AssetKey:" .. tostring(AssetKey) .. " SuffixType:" .. tostring(SuffixType))
  if AssetKey ~= nil and SuffixType ~= nil then
    self:DownloadAssetCompleted(AssetKey, SuffixType, false, object_data)
  end
end
function CustomAssetDownloader:_GetDownloadUrlByDownloadInfo(DownloadInfo, bIsTemp)
  local CosType
  if bIsTemp then
    CosType = CustomAssetDefine.CustomAssetCosTypeDefine.TransferForRes
  else
    CosType = CustomAssetDefine.CustomAssetCosTypeDefine.PlayerDefRes
  end
  local DownloadDomain = CustomAssetDefine.GetCustomAssetCosDownloadUrl(CosType)
  local CustomAssetObjectKey = CustomAssetDefine.GetCustomAssetObjectKey(DownloadInfo.AssetKey, DownloadInfo.SuffixType)
  print(bWriteLog and "CustomAssetDownloader:_GetDownloadUrlByDownloadInfo DownloadDomain:" .. tostring(DownloadDomain) .. " CustomAssetObjectKey:" .. tostring(CustomAssetObjectKey))
  return DownloadDomain .. CustomAssetObjectKey
end
function CustomAssetDownloader:_StartPrivateBucketDownload(DownloadInfo)
  local ObjectKey = CustomAssetDefine.GetCustomAssetObjectKey(DownloadInfo.AssetKey, DownloadInfo.SuffixType)
  log_format("[CustomAsset]CustomAssetDownloader:_StartPrivateBucketDownload ObjectKey:" .. tostring(ObjectKey))
  local LogicResBucket = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  if not LogicResBucket then
    log_format("[CustomAsset]CustomAssetDownloader:_StartPrivateBucketDownload logic_resbucket not available")
    self:DownloadAssetCompleted(DownloadInfo.AssetKey, DownloadInfo.SuffixType, false, nil)
    return
  end
  LogicResBucket:GetDownloadUrl(CustomAssetDefine.CustomAssetCosTypeDefine.StagingResTransfer, {ObjectKey}, function(URLs, bSuccess, Session)
    if not self or self.bHasEndPlay then
      return
    end
    local SignedURL = bSuccess and URLs and URLs[ObjectKey]
    if not SignedURL or SignedURL == "" then
      log_format("[CustomAsset]CustomAssetDownloader:_StartPrivateBucketDownload GetDownloadUrl failed, bSuccess:" .. tostring(bSuccess))
      self:DownloadAssetCompleted(DownloadInfo.AssetKey, DownloadInfo.SuffixType, false, nil)
      return
    end
    log_format("[CustomAsset]CustomAssetDownloader:_StartPrivateBucketDownload SignedURL acquired, start download")
    self:_DoDownloadBinary(SignedURL, DownloadInfo)
  end)
end
function CustomAssetDownloader:GetDownloadInfo(AssetKey, SuffixType)
  for i = 1, #self.DownloadInfoQueue do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.AssetKey == AssetKey and DownloadInfo.SuffixType == SuffixType then
      return DownloadInfo
    end
  end
  return nil
end
function CustomAssetDownloader:AddDownloadInfo(AssetKey, SuffixType)
  local NewDownloadInfo = TableUtil.FastCopyTable(CustomAssetDownloadInfoDefine)
  NewDownloadInfo.  NewDownloadInfo.  NewDownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING
  NewDownloadInfo.IsTimeoutFailed = false
  table.insert(self.DownloadInfoQueue, NewDownloadInfo)
  return NewDownloadInfo
end
function CustomAssetDownloader:RemoveDownloadInfo(AssetKey, SuffixType)
  for i = 1, #self.DownloadInfoQueue do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.AssetKey == AssetKey and (SuffixType == nil or DownloadInfo.SuffixType == SuffixType) then
      table.remove(self.DownloadInfoQueue, i)
      return
    end
  end
end
function CustomAssetDownloader:PostDownloadStateChange(DownloadInfo)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_CUSTOM_ASSET_DOWNLOAD_STATE_CHANGE, DownloadInfo.AssetKey)
end
function CustomAssetDownloader:RequestDownloadAsset(AssetKey, bIsTemp, SuffixType, DownloaderPriority, OutHandleFunc, ...)
  local DownloadInfo = self:GetDownloadInfo(AssetKey, SuffixType)
  local DownloadSeq = self:GetCustomAssetMgr():GenerateSeq()
  local bNeedPostDownloadStateChange = false
  if DownloadInfo == nil then
    DownloadInfo = self:AddDownloadInfo(AssetKey, SuffixType)
    DownloadInfo.First    bNeedPostDownloadStateChange = true
    DownloadInfo.  else
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.FAILED then
      if self:IsDedicatedServer() then
        local common = require("client.slua_ui_framework.common")
        local args = table.pack(...)
        local handle = function(...)
          return common.CallCombinationArgs(OutHandleFunc, args, ...)
        end
        handle(false, AssetKey, SuffixType, nil)
        return 0
      else
        DownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING
        DownloadInfo.IsTimeoutFailed = false
        DownloadInfo.RequestCount = 0
        DownloadInfo.TimeoutCount = 0
        DownloadInfo.First        bNeedPostDownloadStateChange = true
      end
    end
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.SUCCESS then
      DownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING
      DownloadInfo.IsTimeoutFailed = false
      DownloadInfo.RequestCount = 0
      DownloadInfo.TimeoutCount = 0
      DownloadInfo.First      bNeedPostDownloadStateChange = true
    end
  end
  if DownloaderPriority > DownloadInfo.DownloaderPriority then
    DownloadInfo.  end
  DownloadInfo.RequestCount = DownloadInfo.RequestCount + 1
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(OutHandleFunc, args, ...)
  end
  DownloadInfo.DownloadCallbackMap[DownloadSeq] = handle
  self.DownloadSeqToDownloadInfoMap[DownloadSeq] = DownloadInfo
  if bNeedPostDownloadStateChange then
    self:PostDownloadStateChange(DownloadInfo)
  end
  self:DownloadQueueReorder()
  self:CheckAndStartDownloadAsset()
  return DownloadSeq
end
function CustomAssetDownloader:CancelDownloadAsset(DownloadSeq)
  local DownloadInfo = self.DownloadSeqToDownloadInfoMap[DownloadSeq]
  if DownloadInfo == nil then
    return false
  end
  self.DownloadSeqToDownloadInfoMap[DownloadSeq] = nil
  if DownloadInfo.DownloadCallbackMap[DownloadSeq] == nil then
    return false
  end
  DownloadInfo.DownloadCallbackMap[DownloadSeq] = nil
  local bNeedRemove = true
  for DownloadSeq, Callback in pairs(DownloadInfo.DownloadCallbackMap) do
    bNeedRemove = false
    break
  end
  if bNeedRemove and DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING then
    self:RemoveDownloadInfo(DownloadInfo.AssetKey, DownloadInfo.SuffixType)
  end
  return true
end
function CustomAssetDownloader:ForceCancelAllDownload()
  print(bWriteLog and "[CustomAsset]CustomAssetDownloader:ForceCancelAllDownload")
  for i = #self.DownloadInfoQueue, 1, -1 do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING then
      table.remove(self.DownloadInfoQueue, i)
      for DownloadSeq, Callback in pairs(DownloadInfo.DownloadCallbackMap) do
        self.DownloadSeqToDownloadInfoMap[DownloadSeq] = nil
        Callback(false, DownloadInfo.AssetKey, DownloadInfo.SuffixType, nil)
      end
    end
  end
end
function CustomAssetDownloader:DeleteCacheAsset(AssetKey, SuffixType)
  if AssetKey == nil or AssetKey == "" then
    print(bWriteLog and "[CustomAsset]CustomAssetDownloader:DeleteCacheAsset invalid AssetKey")
    return
  end
  print(bWriteLog and string.format("[CustomAsset]CustomAssetDownloader:DeleteCacheAsset AssetKey:%s SuffixType:%s", tostring(AssetKey), tostring(SuffixType)))
  self:RemoveDownloadInfo(AssetKey, SuffixType)
end
function CustomAssetDownloader:DownloadQueueReorder()
  table.sort(self.DownloadInfoQueue, function(a, b)
    if a.DownloadStatus ~= b.DownloadStatus then
      return a.DownloadStatus > b.DownloadStatus
    end
    if a.DownloaderPriority ~= b.DownloaderPriority then
      return a.DownloaderPriority > b.DownloaderPriority
    end
    if a.RequestCount ~= b.RequestCount then
      return a.RequestCount > b.RequestCount
    end
    return a.FirstDownloadSeq < b.FirstDownloadSeq
  end)
end
function CustomAssetDownloader:CheckAndStartDownloadAsset()
  local DownloadingCount = 0
  for i = 1, #self.DownloadInfoQueue do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.DOWNLOADING then
      DownloadingCount = DownloadingCount + 1
    elseif DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.WAITING then
      DownloadingCount = DownloadingCount + 1
      self:StartDownloadAsset(DownloadInfo)
      self:PostDownloadStateChange(DownloadInfo)
    end
    if self:IsDedicatedServer() then
      if DownloadingCount >= CustomAssetDefine.CustomAssetParallelDownloadCount_DS then
        break
      end
    elseif not GameStatus.IsInFightingStatus() then
      if DownloadingCount >= CustomAssetDefine.CustomAssetParallelDownloadCount_Client then
        break
      end
    elseif DownloadingCount >= CustomAssetDefine.CustomAssetParallelDownloadCount_ClientIngame then
      break
    end
  end
end
function CustomAssetDownloader:StartDownloadAsset(DownloadInfo)
  print(bWriteLog and "[CustomAsset]CustomAssetDownloader:StartDownloadAsset AssetKey:" .. tostring(DownloadInfo.AssetKey))
  DownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.DOWNLOADING
  DownloadInfo.StartDownLoadTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
  if self:IsDedicatedServer() and not self:IsEditor() then
    local ObjectKey = CustomAssetDefine.GetCustomAssetObjectKey(DownloadInfo.AssetKey, DownloadInfo.SuffixType)
    print(bWriteLog and "CustomAssetDownloader:StartDownloadAsset ObjectKey:" .. tostring(ObjectKey))
    NetUtil.SendUGCProxyPacket("get_player_def_res_req", ObjectKey)
  elseif DownloadInfo.bIsTemp then
    self:_StartPrivateBucketDownload(DownloadInfo)
  else
    local DownloadURL = self:_GetDownloadUrlByDownloadInfo(DownloadInfo, DownloadInfo.bIsTemp)
    print(bWriteLog and "[CustomAsset]DownloadURL:" .. DownloadURL)
    self:_DoDownloadBinary(DownloadURL, DownloadInfo)
  end
  self:StartWaitDownloadCallbackTimer()
end
function CustomAssetDownloader:_DoDownloadBinary(DownloadURL, DownloadInfo)
  local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
  AWSHelper:DownloadBinary(DownloadURL, function(AWSRsp)
    if self.bHasEndPlay then
      return
    end
    local bOK = AWSRsp:IsOK()
    local rspCode = AWSRsp:GetResponseCode()
    local url = AWSRsp:GetRequestURL()
    log_format("[CustomAsset]CustomAssetDownloader:_DoDownloadBinary bOK = %s,Code = %s,URL = %s", tostring(bOK), tostring(rspCode), url)
    if bOK == true then
      if IsEditor == true and not self:IsDedicatedServer() then
        local ScriptHelperClient = import("ScriptHelperClient")
        ScriptHelperClient.SaveArrayToFile(AWSRsp:GetContent(), "DownloadTest.bin")
      end
      self:DownloadAssetCompleted(DownloadInfo.AssetKey, DownloadInfo.SuffixType, false, AWSRsp:GetContent())
    else
      self:DownloadAssetCompleted(DownloadInfo.AssetKey, DownloadInfo.SuffixType, false, nil)
    end
  end, function(CurrentBytes, TotalBytes)
    if self.bHasEndPlay then
      return
    end
    log_format("[CustomAsset]CustomAssetDownloader:_DoDownloadBinary Progress = %s/%s", tostring(CurrentBytes), tostring(TotalBytes))
  end)
end
function CustomAssetDownloader:DownloadAssetCompleted(AssetKey, SuffixType, IsTimeout, AssetBytes)
  print(bWriteLog and "[CustomAsset]CustomAssetDownloader:DownloadAssetCompleted AssetKey:" .. tostring(AssetKey) .. " SuffixType:" .. tostring(SuffixType) .. " IsTimeout:" .. tostring(IsTimeout) .. " AssetBytes IsNil:" .. tostring(AssetBytes == nil))
  local DownloadInfo = self:GetDownloadInfo(AssetKey, SuffixType)
  if DownloadInfo ~= nil then
    for DownloadSeq, _ in pairs(DownloadInfo.DownloadCallbackMap) do
      self.DownloadSeqToDownloadInfoMap[DownloadSeq] = nil
    end
    local bDownloadSuc = false
    if AssetBytes ~= nil then
      bDownloadSuc = true
    end
    if bDownloadSuc then
      self:GetCustomAssetMgr():CacheCustomAssetBytes(AssetKey, SuffixType, AssetBytes, DownloadInfo.DownloaderPriority)
      DownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.SUCCESS
      DownloadInfo.IsTimeoutFailed = false
    else
      DownloadInfo.DownloadStatus = CustomAssetDefine.Enum_CustomAssetDownloadState.FAILED
      DownloadInfo.IsTimeoutFailed = IsTimeout
    end
    self:PostDownloadStateChange(DownloadInfo)
    local TempDownloadCallbackMap = DownloadInfo.DownloadCallbackMap
    DownloadInfo.DownloadCallbackMap = {}
    for DownloadSeq, Callback in pairs(TempDownloadCallbackMap) do
      Callback(bDownloadSuc, AssetKey, SuffixType, AssetBytes)
    end
  end
  self:CheckAndStartDownloadAsset()
  self:CheckAndEndWaitDownloadCallbackTimer()
end
function CustomAssetDownloader:CheckIsDownloading()
  for i = 1, #self.DownloadInfoQueue do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.DOWNLOADING then
      return true
    end
  end
  return false
end
function CustomAssetDownloader:StartWaitDownloadCallbackTimer()
  if self.WaitDownloadCallbackTimer ~= nil then
    return
  end
  if not self:CheckIsDownloading() then
    return
  end
  self.WaitDownloadCallbackTimer = self:AddGameTimer(1, true, function()
    self:_TickWaitDownloadCallback()
  end)
end
function CustomAssetDownloader:_TickWaitDownloadCallback()
  print(bWriteLog and "CustomAssetDownloader:_TickWaitDownloadCallback")
  local CurTimestamp = CustomAssetUtil.GetServerTimeInSeconds()
  for i = #self.DownloadInfoQueue, 1, -1 do
    local DownloadInfo = self.DownloadInfoQueue[i]
    if DownloadInfo.DownloadStatus == CustomAssetDefine.Enum_CustomAssetDownloadState.DOWNLOADING and CurTimestamp - DownloadInfo.StartDownLoadTimestamp >= CustomAssetDefine.DownloadTimeOut then
      DownloadInfo.TimeoutCount = DownloadInfo.TimeoutCount + 1
      if DownloadInfo.TimeoutCount >= CustomAssetDefine.DownloadTimeoutCountLimit or self:IsDedicatedServer() then
        self:DownloadAssetCompleted(DownloadInfo.AssetKey, DownloadInfo.SuffixType, true, nil)
      else
        print(bWriteLog and "CustomAssetDownloader:_TickWaitDownloadCallback Timeout Retry TimeoutCount:" .. tostring(DownloadInfo.TimeoutCount))
        self:StartDownloadAsset(DownloadInfo)
      end
    end
  end
end
function CustomAssetDownloader:CheckAndEndWaitDownloadCallbackTimer()
  if self.WaitDownloadCallbackTimer == nil then
    return
  end
  if self:CheckIsDownloading() then
    return
  end
  if self.WaitDownloadCallbackTimer ~= nil then
    self:RemoveGameTimer(self.WaitDownloadCallbackTimer)
    self.WaitDownloadCallbackTimer = nil
  end
end
local class = require("class")
local CustomAssetUtilityObject = require("common.CustomAsset.CustomAssetUtilityObject")
local CCustomAssetDownloader = class(CustomAssetUtilityObject, nil, CustomAssetDownloader)
return CCustomAssetDownloader
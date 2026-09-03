local CustomAssetUploader = {}
local TableUtil = require("common.table_util")
local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local CustomAssetLoadInfoDefine = {
  UploadSeq = 0,
  UploadBytes = nil,
  SuffixType = "",
  UploadUrl = nil
}
function CustomAssetUploader:ctor()
  self.bUploading = false
  self.CurUploadAssetKey = ""
  self.CurUploadSeq = 0
  self.bUploadUrlRsp = false
  self.CurUploadInfoList = {}
  self.CurUploadCallback = nil
  self.WaitUploadCallbackTimer = nil
  self.ReqUploadUrlCallbackTimer = nil
  function self.GetUploadUrlCallback(URLMap, Succeed, Session)
    local _CurUploadSeq = Session.CurUploadSeq
    print(bWriteLog and "CustomAssetUploader:GetUploadUrlCallback Succeed:" .. tostring(Succeed) .. " _CurUploadSeq:" .. tostring(_CurUploadSeq))
    if self.bHasEndPlay then
      return
    end
    if self.CurUploadSeq ~= _CurUploadSeq then
      return
    end
    if Succeed == true then
      for i = 1, #self.CurUploadInfoList do
        local UploadInfo = self.CurUploadInfoList[i]
        local ObjectKey = CustomAssetDefine.GetCustomAssetObjectKey(self.CurUploadAssetKey, UploadInfo.SuffixType)
        local RspUrl = URLMap[ObjectKey]
        print(bWriteLog and "GetUploadUrlCallback UploadUrl:" .. tostring(RspUrl))
        UploadInfo.UploadUrl = RspUrl
      end
      self.bUploadUrlRsp = true
      self:ReqUploadUrlCompleted(false)
    else
      self:ReqUploadUrlCompleted(false)
    end
  end
end
function CustomAssetUploader:ReceiveBeginPlay()
  CustomAssetUploader.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:ReceiveBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
end
function CustomAssetUploader:ReceivePostBeginPlay()
  CustomAssetUploader.__super.ReceivePostBeginPlay(self)
  print(bWriteLog and "CustomAssetUploader:ReceivePostBeginPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
end
function CustomAssetUploader:ReceiveEndPlay()
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:ReceiveEndPlay IsDedicatedServer:" .. tostring(self:IsDedicatedServer()))
  self:RemoveWaitUploadCallbackTimer()
  self:RemoveReqUploadUrlCallbackTimer()
  CustomAssetUploader.__super.ReceiveEndPlay(self)
end
function CustomAssetUploader:IsLocalBoot()
  return false
end
function CustomAssetUploader:CustomAssetUploading()
  return self.bUploading == true
end
function CustomAssetUploader:RequestUploadAsset(AssetKey, SourceBytes, PlatformCustomAssetInfoList, IsTempUpload, AssetSuffixType, OutHandleFunc, ...)
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:RequestUploadAsset AssetKey:" .. tostring(AssetKey))
  if self:CustomAssetUploading() or self:IsDedicatedServer() then
    if OutHandleFunc ~= nil then
      OutHandleFunc((...), false, AssetKey)
    end
    return
  end
  if SourceBytes == nil or type(SourceBytes) ~= "string" then
    print(bWriteLog and "[CustomAsset]CustomAssetUploader:RequestUploadAsset SourceBytes is nil or not string")
    if OutHandleFunc ~= nil then
      OutHandleFunc((...), false, AssetKey)
    end
    return
  end
  self.bUploading = true
  self.CurUpload  self.CurUploadSeq = self:GetCustomAssetMgr():GenerateSeq()
  self.bUploadUrlRsp = false
  local UploadInfo = TableUtil.FastCopyTable(CustomAssetLoadInfoDefine)
  UploadInfo.UploadSeq = self:GetCustomAssetMgr():GenerateSeq()
  UploadInfo.UploadBytes = SourceBytes
  UploadInfo.SuffixType = AssetSuffixType
  UploadInfo.  table.insert(self.CurUploadInfoList, UploadInfo)
  if PlatformCustomAssetInfoList ~= nil then
    for i = 1, #PlatformCustomAssetInfoList do
      local PlatformCustomAssetInfo = PlatformCustomAssetInfoList[i]
      local UploadInfo1 = TableUtil.FastCopyTable(CustomAssetLoadInfoDefine)
      UploadInfo1.UploadSeq = self:GetCustomAssetMgr():GenerateSeq()
      UploadInfo1.UploadBytes = PlatformCustomAssetInfo.PlatformContent
      UploadInfo1.SuffixType = PlatformCustomAssetInfo.AssetSuffixType
      table.insert(self.CurUploadInfoList, UploadInfo1)
    end
  end
  if OutHandleFunc ~= nil then
    local common = require("client.slua_ui_framework.common")
    local args = table.pack(...)
    local handle = function(...)
      return common.CallCombinationArgs(OutHandleFunc, args, ...)
    end
    self.CurUploadCallback = handle
  end
  self:StartReqUploadUrl()
end
function CustomAssetUploader:StartReqUploadUrl()
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:StartReqUploadUrl bUploadUrlRsp:" .. tostring(self.bUploadUrlRsp))
  if self:IsLocalBoot() then
    self:AddGameTimer(0.5, false, function()
      self.bUploadUrlRsp = true
      self:ReqUploadUrlCompleted(false)
    end)
  else
    local ObjectKeys = {}
    local IsTemp = false
    for i = 1, #self.CurUploadInfoList do
      local UploadInfo = self.CurUploadInfoList[i]
      local ObjectKey = CustomAssetDefine.GetCustomAssetObjectKey(self.CurUploadAssetKey, UploadInfo.SuffixType)
      print(bWriteLog and "CustomAssetUploader:StartReqUploadUrl ObjectKey:" .. tostring(ObjectKey))
      table.insert(ObjectKeys, ObjectKey)
      if IsTemp == false and UploadInfo.IsTempUpload == true then
        IsTemp = true
      end
    end
    local SessionTable = {
      CurUploadSeq = self.CurUploadSeq
    }
    local logic_resbucket = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
    local ResBucketType
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    if IsTemp then
      ResBucketType = CustomAssetDefine.CustomAssetCosTypeDefine.TransferForRes
    else
      ResBucketType = CustomAssetDefine.CustomAssetCosTypeDefine.PlayerDefRes
      if GamePlayTools.IsBlueHoleVersion() then
        ResBucketType = CustomAssetDefine.CustomAssetCosTypeDefine.IndiaPlayerDefRes
      end
    end
    logic_resbucket:GetUploadUrl(ResBucketType, ObjectKeys, self.GetUploadUrlCallback, SessionTable)
  end
  self.ReqUploadUrlCallbackTimer = self:AddGameTimer(CustomAssetDefine.UploadTimeOut, false, function()
    self.ReqUploadUrlCallbackTimer = nil
    self:ReqUploadUrlCompleted(true)
  end)
end
function CustomAssetUploader:RemoveReqUploadUrlCallbackTimer()
  if self.ReqUploadUrlCallbackTimer ~= nil then
    self:RemoveGameTimer(self.ReqUploadUrlCallbackTimer)
    self.ReqUploadUrlCallbackTimer = nil
  end
end
function CustomAssetUploader:ReqUploadUrlCompleted(IsTimeout)
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:ReqUploadUrlCompleted IsTimeout:" .. tostring(IsTimeout))
  self:RemoveReqUploadUrlCallbackTimer()
  self:CheckAndStartUploadAsset()
end
function CustomAssetUploader:CheckAndStartUploadAsset()
  local PendingUploadCount = #self.CurUploadInfoList
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:CheckAndStartUploadAsset PendingUploadCount:" .. tostring(PendingUploadCount) .. " bUploadUrlRsp:" .. tostring(self.bUploadUrlRsp))
  if 0 < PendingUploadCount then
    if self.bUploadUrlRsp ~= true then
      self:_CurUploadCompleted(false)
    else
      local UploadInfo = self.CurUploadInfoList[1]
      self:_StartUploadAsset(UploadInfo)
    end
  else
    self:_CurUploadCompleted(true)
  end
end
function CustomAssetUploader:_StartUploadAsset(UploadInfo)
  if self:IsLocalBoot() then
    self:AddGameTimer(2, false, function()
      self:UploadAssetCompleted(UploadInfo, true, false, "")
    end)
  else
    local AWSHelper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AWSHelper)
    print(bWriteLog and "[CustomAsset]CustomAssetUploader:_StartUploadAsset UploadUrl:" .. UploadInfo.UploadUrl)
    AWSHelper:UploadBinaryExtra(UploadInfo.UploadBytes, UploadInfo.UploadUrl, "*", function(AWSRsp)
      if self.bHasEndPlay then
        return
      end
      local bOK = AWSRsp:IsOK()
      local rspCode = AWSRsp:GetResponseCode()
      local url = AWSRsp:GetRequestURL()
      printf(bWriteLog and "CustomAssetUploader:UploadBinary bOK = %s,Code = %s,URL = %s", tostring(bOK), tostring(rspCode), url)
      if bOK == true then
        self:UploadAssetCompleted(UploadInfo, true, false, url)
      elseif rspCode == CustomAssetDefine.DuplicateUploadErrCode then
        self:UploadAssetCompleted(UploadInfo, true, false, url)
      else
        self:UploadAssetCompleted(UploadInfo, false, false, "")
      end
    end, function(CurrentBytes, TotalBytes)
      if self.bHasEndPlay then
        return
      end
      printf(bWriteLog and "CustomAssetUploader:UploadBinary Progress = %s/%s", tostring(CurrentBytes), tostring(TotalBytes))
    end)
  end
  self.WaitUploadCallbackTimer = self:AddGameTimer(CustomAssetDefine.UploadTimeOut, false, function()
    self.WaitUploadCallbackTimer = nil
    self:UploadAssetTimeOut(UploadInfo)
  end)
end
function CustomAssetUploader:RemoveWaitUploadCallbackTimer()
  if self.WaitUploadCallbackTimer ~= nil then
    self:RemoveGameTimer(self.WaitUploadCallbackTimer)
    self.WaitUploadCallbackTimer = nil
  end
end
function CustomAssetUploader:UploadAssetTimeOut(UploadInfo)
  print(bWriteLog and "CustomAssetUploader:UploadAssetTimeOut UploadSeq:" .. tostring(UploadInfo.UploadSeq))
  self:UploadAssetCompleted(UploadInfo, false, true, "")
end
function CustomAssetUploader:UploadAssetCompleted(UploadInfo, UploadSuc, IsTimeout, Url)
  print(bWriteLog and "CustomAssetUploader:UploadAssetCompleted UploadSeq:" .. tostring(UploadInfo.UploadSeq) .. " UploadSuc:" .. tostring(UploadSuc) .. " IsTimeout:" .. tostring(IsTimeout))
  self:RemoveWaitUploadCallbackTimer()
  if UploadSuc == true then
    if not self:IsEditor() then
      self:GetCustomAssetMgr():CacheCustomAssetBytes(self.CurUploadAssetKey, UploadInfo.SuffixType, UploadInfo.UploadBytes, CustomAssetDefine.CustomAssetDownloadPriority.VERY_LOW)
    end
    local RemoveIndex = -1
    for i = 1, #self.CurUploadInfoList do
      local UploadInfo = self.CurUploadInfoList[i]
      if UploadInfo.UploadSeq == UploadInfo.UploadSeq then
        RemoveIndex = i
        break
      end
    end
    if 0 < RemoveIndex then
      table.remove(self.CurUploadInfoList, RemoveIndex)
    end
    self:CheckAndStartUploadAsset()
  else
    self:_CurUploadCompleted(false)
  end
end
function CustomAssetUploader:_CurUploadCompleted(AllUploadSuc)
  print(bWriteLog and "[CustomAsset]CustomAssetUploader:_CurUploadCompleted AllUploadSuc:" .. tostring(AllUploadSuc))
  local _CurUploadCallback = self.CurUploadCallback
  local _CurCurUploadAssetKey = self.CurUploadAssetKey
  self.CurUploadCallback = nil
  self.CurUploadAssetKey = ""
  self.CurUploadSeq = 0
  self.bUploadUrlRsp = false
  self.CurUploadInfoList = {}
  self.bUploading = false
  if _CurUploadCallback then
    _CurUploadCallback(AllUploadSuc, _CurCurUploadAssetKey)
  end
end
local class = require("class")
local CustomAssetUtilityObject = require("common.CustomAsset.CustomAssetUtilityObject")
local CCustomAssetUploader = class(CustomAssetUtilityObject, nil, CustomAssetUploader)
return CCustomAssetUploader
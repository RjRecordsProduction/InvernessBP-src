local image_download_mgr = {}
local imageDownloadUtil = import("ImageDownloadUtil")
local SetTextureConst = require("client.slua.logic.image_download.SetTextureConst")
function image_download_mgr:OnInitialize()
  image_download_mgr.__super.OnInitialize(self)
  self:_InitData()
  self:_InitWebP()
end
function image_download_mgr:Destory()
  log(bWriteLog and "image_download_mgr Destory")
  self:ClearData()
end
function image_download_mgr:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "image_download_mgr OnPreSwitchGameStatus")
  if nextState == GameStatus.Fighting then
    if not GameStatus.IsInMainCity() then
      self:ClearData()
    end
  else
    self:_CancelAllDownloadingReq(self.Config.bCheckModeSwitchDownload)
  end
end
function image_download_mgr:OnLogOut()
  log(bWriteLog and "image_download_mgr OnLogOut")
  self:_CancelAllDownloadingReq(true)
end
function image_download_mgr:_InitData()
  self.downloadingNum = 0
  self.downloadStack = nil
  self.downloadReqData = nil
  self.urlStatusInfo = nil
  self.memoryCacheArray = nil
  self.isSaveDiskCache = true
  self.hasCheckDiskFile = false
  self.Config = require("client.slua.logic.image_download.image_download_config")
  self.HttpHeader = nil
  self.downloadIndex = 0
  self.downloadIndexToInfo = nil
  self.diskLoadIndexTb = nil
  self.bDiskLoadStackOpen = self.Config.bOpenDiskLoadStack
  self.DiskLoadStack = nil
  self.DiskLoadTimer = nil
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr InitData")
  end
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  self.IsReleaseVersion = ToolReportUtil:IsReleaseVersion()
  self.Error403ImageList = nil
  self.token = nil
  if not self.IsReleaseVersion then
    local cfg = CDataTable.GetTableData("SystemConfig", "CDNToken")
    self.token = cfg and cfg.ConfigValue
    self.token = string.gsub(self.token, "^\"(.-)\"$", "%1")
    self.forbiddenPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Common_Checking_Dafualt.Common_Checking_Dafualt"
    self.Error403ImageList = {}
    self.devDomain = FuncUtil.GetDomainByID(3366251)
    self.devDomainReplaceString = string.format("//%s/", self.devDomain)
  end
end
function image_download_mgr:_TryGetLocalCache(imgUrl, OnDownloadSuccess, extendedParams, enableCDNCompress, compressImgUrl, cacheType, bAsyncDiskLoad, thumbScale)
  log(bWriteLog and "[SY]image_download_mgr:_TryGetLocalCache.imgUrl:" .. tostring(imgUrl))
  local thumbFilePath, savePath
  if enableCDNCompress and compressImgUrl then
    savePath = self:_GetFullFilePath(compressImgUrl, cacheType, thumbScale)
  else
    savePath = self:_GetFullFilePath(imgUrl, cacheType, thumbScale)
  end
  local isForceUpdate = extendedParams and extendedParams.isForceUpdate
  if isForceUpdate then
    return nil
  end
  if bAsyncDiskLoad then
    local texture = self:_GetTextureCacheFromMemory(imgUrl, compressImgUrl, extendedParams and extendedParams.ThumbImageScale)
    if slua.isValid(texture) then
      if OnDownloadSuccess then
        OnDownloadSuccess(texture, imgUrl)
      end
      return SetTextureConst.Done
    else
      local asset_util = require("common.asset_util")
      local diskId
      local onLoadSavedCb = function(texture)
        if OnDownloadSuccess then
          OnDownloadSuccess(texture, imgUrl)
        end
        self:_SaveTextureToMemory(imgUrl, texture)
        if self.diskLoadIndexTb then
          self.diskLoadIndexTb[diskId] = nil
        end
      end
      diskId = asset_util.GetSavedTextureAsync(savePath, enableCDNCompress, onLoadSavedCb)
      if enableCDNCompress and diskId == 0 then
        savePath = self:_GetFullFilePath(imgUrl, cacheType, thumbScale)
        log(bWriteLog and "  image_download_mgr:_TryGetLocalCache. forget to upload CDNCompress Image!!" .. tostring(imgUrl))
        diskId = asset_util.GetSavedTextureAsync(savePath, false, onLoadSavedCb)
      end
      if diskId and diskId ~= 0 then
        diskId = diskId + self.Config.DiskStartIndex
        self.diskLoadIndexTb[diskId] = 1
        return diskId
      end
    end
  else
    if enableCDNCompress and compressImgUrl and compressImgUrl ~= "" then
      local compressSavePath = self:_GetFullFilePath(compressImgUrl, cacheType)
      local compressTexture = self:_GetLocalCacheAndFile(compressImgUrl, compressSavePath, true)
      if slua.isValid(compressTexture) and OnDownloadSuccess then
        OnDownloadSuccess(compressTexture, imgUrl)
        return SetTextureConst.Done
      end
    end
    savePath = self:_GetFullFilePath(imgUrl, cacheType)
    local texture = self:_GetLocalCacheAndFile(imgUrl, savePath, false, thumbScale, thumbFilePath)
    if slua.isValid(texture) and OnDownloadSuccess then
      OnDownloadSuccess(texture, imgUrl)
      return SetTextureConst.Done
    end
  end
  return nil
end
function image_download_mgr:DownloadImageByHttpWrapper(imgUrl, OnDownloadSuccess, OnDownloadFail, extendedParams)
  log(bWriteLog and "  image_download_mgr:DownloadImageByHttpWrapper. imgUrl is " .. tostring(imgUrl))
  if not self.diskLoadIndexTb then
    self.diskLoadIndexTb = {}
  end
  extendedParams = extendedParams or {}
  if not self.IsReleaseVersion then
    local devURL = self:_ConvertToDevUrl(imgUrl)
    if self.Error403ImageList[devURL] or self.Error403ImageList[imgUrl] then
      local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
      local texture = LogicLoadTexture.LoadTextureOrSprite(self.forbiddenPath)
      if slua.isValid(texture) then
        log(bWriteLog and "[SY]image_download_mgr:DownloadImageByHttpWrapper.403")
        if OnDownloadSuccess then
          OnDownloadSuccess(texture, imgUrl)
        end
        return
      end
    end
  end
  if not extendedParams.bIsIgnoreCheck then
    self:_CheckLocalDiskFile()
  end
  if not assert(imgUrl ~= nil and imgUrl ~= "", "image_download_mgr:DownloadImageByHttpWrapper Invalid Url!") then
    return SetTextureConst.Error
  end
  if string.find(imgUrl, " ") ~= nil then
    log_warning(bWriteLog and "image_download_mgr:DownloadImageByHttpWrapper imgUrl has empty")
    imgUrl = string.gsub(imgUrl, " ", "")
  end
  local enableCDNCompress = false
  local compressImgUrl
  if extendedParams and extendedParams.enableCDNCompress then
    enableCDNCompress, compressImgUrl = self:_GetCompressImageUrl(imgUrl)
    extendedParams.ThumbImageScale = nil
  end
  local cacheType = extendedParams and extendedParams.diskCacheType or self.Config.EnumDiskCacheType.DailyUpdate
  if not self.Config.CacheTypeDirName[cacheType] or not self.Config.CacheTypeSeconds[cacheType] then
    log_warning(bWriteLog and "image_download_mgr:GetLocalImageCache diskCacheType is invalid")
    cacheType = self.Config.EnumDiskCacheType.DailyUpdate
  end
  local bForceSync = extendedParams and extendedParams.isSyncDiskLoad or false
  local bAsyncDiskLoad = self.bDiskLoadStackOpen and not bForceSync
  local thumbScale = extendedParams and extendedParams.ThumbImageScale
  local cacheResult = self:_TryGetLocalCache(imgUrl, OnDownloadSuccess, extendedParams, enableCDNCompress, compressImgUrl, cacheType, bAsyncDiskLoad, thumbScale)
  if cacheResult then
    return cacheResult
  end
  if not self.IsReleaseVersion and not self:_IsDevUrl(imgUrl) then
    local devURL = self:_ConvertToDevUrl(imgUrl)
    local enableDevCompress = false
    local devCompressImgUrl
    if extendedParams and extendedParams.enableCDNCompress then
      enableDevCompress, devCompressImgUrl = self:_GetCompressImageUrl(devURL)
      extendedParams.ThumbImageScale = nil
    end
    local devResult = self:_TryGetLocalCache(devURL, OnDownloadSuccess, extendedParams, enableDevCompress, devCompressImgUrl, cacheType, bAsyncDiskLoad, thumbScale)
    if devResult then
      log(bWriteLog and "[SY]image_download_mgr:DownloadImageByHttpWrapper.devResult" .. devURL)
      return devResult
    end
  end
  local dlIndex = self.downloadIndex + 1
  self.downloadIndex = dlIndex
  if not self.downloadIndexToInfo then
    self.downloadIndexToInfo = {}
  end
  self.downloadIndexToInfo[dlIndex] = {url = imgUrl, compressImgUrl = compressImgUrl}
  local reqDownloadTime
  if self.Config.bShowDetailLog then
    local TimeUtil = require("client.common.time_util")
    reqDownloadTime = TimeUtil.GetServerTimeInSec()
  end
  local currentReqData = {
    url = imgUrl,
    successCallback = OnDownloadSuccess,
    failCallback = OnDownloadFail,
    otherParams = extendedParams,
    index = dlIndex,
    compressImgUrl = compressImgUrl,
    cacheType = cacheType,
    bDownloadOnModeSwitch = extendedParams and extendedParams.bDownloadOnModeSwitch,
    ReqDownloadTime = reqDownloadTime
  }
  local isNewUrl = self:_RecordImageInfo(imgUrl, compressImgUrl, currentReqData)
  self:_AddOneHttpDownload(imgUrl, compressImgUrl, isNewUrl)
  return dlIndex
end
function image_download_mgr:CancelDownloadByIndex(downloadIndex)
  if not assert(downloadIndex ~= nil and 0 < downloadIndex, "image_download_mgr:CancelDownloadByIndex Invalid Url or index!") then
    return
  end
  if not self.diskLoadIndexTb then
    self.diskLoadIndexTb = {}
  end
  local tempIndex = downloadIndex - self.Config.DiskStartIndex
  if self.diskLoadIndexTb[downloadIndex] then
    local asset_util = require("common.asset_util")
    local success = asset_util.CancelSavedTextureAsync(tempIndex)
    self.diskLoadIndexTb[downloadIndex] = nil
    if success then
      return
    end
  end
  if not self.downloadReqData or not self.urlStatusInfo then
    log(bWriteLog and "image_download_mgr:CancelDownloadByIndex downloadReqData is nil, no need to cancel")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:CancelDownloadByIndex downloadIndex is " .. tostring(downloadIndex))
  end
  if not self.downloadIndexToInfo or not self.downloadIndexToInfo[downloadIndex] then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:CancelDownloadByIndex downloadIndexToInfo is bad, or download is finished")
    end
    return
  end
  local imgUrl = self.downloadIndexToInfo[downloadIndex].url
  local compressImgUrl = self.downloadIndexToInfo[downloadIndex].compressImgUrl
  local isDel = false
  local realReqUrl = imgUrl
  if compressImgUrl and compressImgUrl ~= "" then
    realReqUrl = compressImgUrl
  end
  self.downloadIndexToInfo[downloadIndex] = nil
  log(bWriteLog and "image_download_mgr:CancelDownloadByIndex imgUrl is " .. tostring(realReqUrl))
  local reqDataList = self.downloadReqData[realReqUrl]
  if type(reqDataList) == "table" and next(reqDataList) then
    for i, reqData in ipairs(reqDataList) do
      if reqData and reqData.index == downloadIndex then
        isDel = true
        table.remove(reqDataList, i)
        break
      end
    end
  end
  if not isDel then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:CancelDownloadByIndex no need to cancel")
    end
    return
  end
  if reqDataList and next(reqDataList) then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:CancelDownloadByIndex url still need to download")
    end
    return
  end
  if self.downloadStack then
    for index, url in ipairs(self.downloadStack) do
      if url == realReqUrl then
        if self.Config.bShowDetailLog then
          log(bWriteLog and "image_download_mgr:CancelDownloadByIndex remove index:" .. tostring(index))
        end
        table.remove(self.downloadStack, index)
        break
      end
    end
  end
  local urlStatus = self.urlStatusInfo[realReqUrl]
  if urlStatus and urlStatus.status == self.Config.EnumImageDownloadStatus.Downloading then
    local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
    http_manager:Cancel(urlStatus.reqIndex, self.Config.EnumHttpQueueType_ImageDownload)
    if 0 < self.downloadingNum then
      self.downloadingNum = self.downloadingNum - 1
    end
    self:_TryStartDownloadImage()
    log(bWriteLog and "image_download_mgr:CancelDownloadByIndex cancel downloadUrl reqindex:" .. tostring(urlStatus.reqIndex))
  end
  self.downloadReqData[realReqUrl] = nil
  self.urlStatusInfo[realReqUrl] = nil
end
function image_download_mgr:GetLocalImageCache(imgUrl, ifCDNCompress, diskCacheType, ThumbImageScale)
  if not imgUrl or imgUrl == "" then
    assert(false, "image_download_mgr:GetLocalImageCache Invalid Url!")
    return
  end
  local tConfig = self.Config
  if diskCacheType ~= nil and (not tConfig.CacheTypeDirName[diskCacheType] or not tConfig.CacheTypeSeconds[diskCacheType]) then
    log_warning(bWriteLog and "image_download_mgr:GetLocalImageCache diskCacheType is invalid")
    diskCacheType = nil
  end
  self:_CheckLocalDiskFile()
  if string.find(imgUrl, " ") ~= nil then
    log_warning(bWriteLog and "image_download_mgr:GetLocalImageCache imgUrl has empty")
    imgUrl = string.gsub(imgUrl, " ", "")
  end
  local enableCDNCompress = false
  local compressImgUrl
  if ifCDNCompress then
    enableCDNCompress, compressImgUrl = self:_GetCompressImageUrl(imgUrl)
  end
  if enableCDNCompress and compressImgUrl and compressImgUrl ~= "" then
    local compressSavePath = self:_GetFullFilePath(compressImgUrl, diskCacheType)
    local compressTexture = self:_GetLocalCacheAndFile(compressImgUrl, compressSavePath, true)
    if slua.isValid(compressTexture) then
      return compressTexture
    end
    if not self.IsReleaseVersion and not self:_IsDevUrl(compressImgUrl) then
      local compressDevUrl = self:_ConvertToDevUrl(compressImgUrl)
      if compressDevUrl ~= compressImgUrl then
        local compressDevSavePath = self:_GetFullFilePath(compressDevUrl, diskCacheType)
        local compressDevTexture = self:_GetLocalCacheAndFile(compressDevUrl, compressDevSavePath, true)
        if slua.isValid(compressDevTexture) then
          log(bWriteLog and "[SY]image_download_mgr:GetLocalImageCache found compressDevUrl cache for _GetLocalCacheAndFile:" .. tostring(compressImgUrl))
          return compressDevTexture
        end
      end
    end
  end
  local savePath = self:_GetFullFilePath(imgUrl, diskCacheType)
  local thumbFilePath
  if ThumbImageScale and 0 < ThumbImageScale and ThumbImageScale < 1 then
    thumbFilePath = self:_GetFullFilePath(imgUrl, diskCacheType, ThumbImageScale)
  end
  local texture = self:_GetLocalCacheAndFile(imgUrl, savePath, false, ThumbImageScale, thumbFilePath)
  if slua.isValid(texture) then
    return texture
  end
  if not self.IsReleaseVersion and not self:_IsDevUrl(imgUrl) then
    local devUrl = self:_ConvertToDevUrl(imgUrl)
    if devUrl ~= imgUrl then
      local devSavePath = self:_GetFullFilePath(devUrl, diskCacheType)
      local devThumbFilePath
      if ThumbImageScale and 0 < ThumbImageScale and ThumbImageScale < 1 then
        devThumbFilePath = self:_GetFullFilePath(devUrl, diskCacheType, ThumbImageScale)
      end
      local devTexture = self:_GetLocalCacheAndFile(devUrl, devSavePath, false, ThumbImageScale, devThumbFilePath)
      if slua.isValid(devTexture) then
        log(bWriteLog and "[SY]image_download_mgr:GetLocalImageCache found devUrl cache for Compress _GetLocalCacheAndFile:" .. tostring(imgUrl))
        return devTexture
      end
    end
  end
  log(bWriteLog and "image_download_mgr:GetLocalImageCache no cache")
  return nil
end
function image_download_mgr:GetDiskCacheTypeEnum()
  return self.Config.EnumDiskCacheType
end
function image_download_mgr:SetHttpHeader(header)
  self.HttpHeader = header
end
function image_download_mgr:_InitWebP()
  local switch = HDmpveRemote.HDmpveRemoteConfigGetBool("bEnableWebp", true)
  log(bWriteLog and "image_download_mgr:_InitWebP switch = " .. tostring(switch))
  if switch then
    self:SetHttpHeader({
      Accept = "image/webp, image/png; q=0.8, image/*; q=0.5, */*; q=0.0"
    })
  end
end
function image_download_mgr:ClearData()
  log(bWriteLog and "image_download_mgr:ClearData")
  self:_RemoveDiskloadTimer()
  self.downloadingNum = 0
  self.downloadStack = nil
  self.downloadReqData = nil
  self.memoryCacheArray = nil
  self.urlStatusInfo = nil
  self.downloadIndexToInfo = nil
  self.diskLoadIndexTb = nil
  self.DiskLoadStack = nil
end
function image_download_mgr:_CancelAllDownloadingReq(bCheckSwitchDownload)
  if not self.urlStatusInfo or not next(self.urlStatusInfo) then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_CancelAllDownloadingReq urlStatusInfo is nil")
    end
    return
  end
  for imgUrl, urlStatus in pairs(self.urlStatusInfo) do
    if bCheckSwitchDownload then
      self:_CheckAndCancelDownloadOnPreSwitchMode(imgUrl)
    elseif urlStatus.status == self.Config.EnumImageDownloadStatus.Downloading and urlStatus.reqIndex > 0 then
      local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
      http_manager:Cancel(urlStatus.reqIndex, self.Config.EnumHttpQueueType_ImageDownload)
      log(bWriteLog and "image_download_mgr:_CancelAllDownloadingReq Cancel imgUrl: " .. imgUrl)
    end
  end
  if self.diskLoadIndexTb then
    for index, _ in pairs(self.diskLoadIndexTb) do
      local asset_util = require("common.asset_util")
      asset_util.CancelSavedTextureAsync(index - self.Config.DiskStartIndex)
    end
  end
  self.diskLoadIndexTb = nil
  if bCheckSwitchDownload then
    self:_ClearDownloadStack()
  else
    self:ClearData()
  end
end
function image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode(realReqUrl)
  if not realReqUrl then
    log(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode realReqUrl is nil")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode realReqUrl is " .. tostring(realReqUrl))
  end
  local reqDataList = self.downloadReqData and self.downloadReqData[realReqUrl]
  if self.Config.bShowDetailLog then
    log_tree(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode reqDataList", reqDataList)
  end
  local bDownloadOnModeSwitch = false
  local newReqDataList = {}
  if type(reqDataList) == "table" and next(reqDataList) then
    for i, reqData in ipairs(reqDataList) do
      if reqData.bDownloadOnModeSwitch then
        bDownloadOnModeSwitch = true
        table.insert(newReqDataList, reqData)
      else
        self:_ClearIndexToInfoData(reqData.index)
      end
    end
  end
  if bDownloadOnModeSwitch then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode bDownloadOnModeSwitch true")
      log_tree(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode newReqDataList", newReqDataList)
    end
    if self.downloadReqData and next(newReqDataList) then
      self.downloadReqData[realReqUrl] = newReqDataList
    end
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckAndCancelDownloadOnPreSwitchMode cancel all")
  end
  local urlStatus = self.urlStatusInfo and self.urlStatusInfo[realReqUrl]
  if urlStatus and urlStatus.reqIndex and urlStatus.status == self.Config.EnumImageDownloadStatus.Downloading then
    local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
    http_manager:Cancel(urlStatus.reqIndex, self.Config.EnumHttpQueueType_ImageDownload)
    if self.downloadingNum > 0 then
      self.downloadingNum = self.downloadingNum - 1
    end
  end
  if self.downloadReqData then
    self.downloadReqData[realReqUrl] = nil
  end
  if self.urlStatusInfo then
    self.urlStatusInfo[realReqUrl] = nil
  end
end
function image_download_mgr:_ClearDownloadStack()
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_ClearDownloadStack")
  end
  if not self.downloadStack or not next(self.downloadStack) then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_ClearDownloadStack no downloadStack")
    end
    return
  end
  local newDownloadStack = {}
  for _, imgUrl in ipairs(self.downloadStack) do
    local reqDataList = self.downloadReqData and self.downloadReqData[imgUrl]
    if reqDataList then
      local shouldHold = false
      local newReqDataList = {}
      for _, reqData in ipairs(reqDataList) do
        if reqData.bDownloadOnModeSwitch then
          shouldHold = true
          table.insert(newReqDataList, reqData)
        end
      end
      if shouldHold then
        table.insert(newDownloadStack, imgUrl)
        self.downloadReqData[imgUrl] = newReqDataList
      else
        self.downloadReqData[imgUrl] = nil
      end
    end
  end
  log_tree(bWriteLog and "image_download_mgr:_ClearDownloadStack oldDownloadStack: ", self.downloadStack)
  log_tree(bWriteLog and "image_download_mgr:_ClearDownloadStack newDownloadStack: ", newDownloadStack)
  if next(newDownloadStack) then
    self.downloadStack = newDownloadStack
    log(bWriteLog and "image_download_mgr:_ClearDownloadStack has waiting _TryStartDownloadImage")
    self:_TryStartDownloadImage(self.Config.MaxDownloadNum)
  else
    self.downloadStack = nil
  end
end
function image_download_mgr:_TryStartDownloadImage(downloadNum)
  downloadNum = downloadNum or 1
  if not self.downloadStack or not self.downloadReqData then
    log(bWriteLog and "image_download_mgr:_TryStartDownloadImage No Waiting Download or downloadReqData!")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_TryStartDownloadImage current downloading number is " .. tostring(self.downloadingNum))
  end
  if self.Config.MaxDownloadNum <= self.downloadingNum then
    log(bWriteLog and "image_download_mgr:_TryStartDownloadImage no download seats!")
    return
  end
  local waitingNumber = #self.downloadStack
  local imgUrl
  for i = waitingNumber, 1, -1 do
    local url = self.downloadStack[i]
    self.downloadStack[i] = nil
    if url and self.downloadReqData[url] then
      imgUrl = url
      break
    end
  end
  if imgUrl then
    self:_SendImageDownloadRequest(imgUrl)
  else
    log(bWriteLog and "image_download_mgr:_TryStartDownloadImage no valid request!")
  end
  if 1 < downloadNum and #self.downloadStack > 0 then
    self:_TryStartDownloadImage(downloadNum - 1)
  end
end
function image_download_mgr:_HttpDownloadCallBack(isSuccess, respData, imgUrl, reqDataList, result)
  if not (imgUrl and reqDataList) or type(reqDataList) ~= "table" or not next(reqDataList) then
    log(bWriteLog and "image_download_mgr:_HttpDownloadCallBack no imgUrl or no reqDataList")
    return
  end
  local originImgUrl = reqDataList[1].url or imgUrl
  local compressImgUrl = reqDataList[1].compressImgUrl
  local enableCDNCompress = false
  if compressImgUrl and compressImgUrl ~= "" then
    enableCDNCompress = true
  end
  if not isSuccess or not respData then
    if enableCDNCompress then
      log(bWriteLog and "image_download_mgr _HttpDownloadCallBack _RetryUncompressImgDownload")
      self:_RetryUncompressImgDownload(originImgUrl, reqDataList)
      return
    end
    if not self.IsReleaseVersion then
      local isDev = self:_IsDevUrl(imgUrl)
      if not isDev then
        log(bWriteLog and "[SY]image_download_mgr _HttpDownloadCallBack _RetryDevUrlDownload")
        self:_RetryDevUrlDownload(originImgUrl, reqDataList)
        return
      elseif isDev and result == 403 then
        log(bWriteLog and "image_download_mgr 403 Callback")
        local LogicLoadTexture = require("client.slua.logic.texture.logic_load_texture")
        local texture = LogicLoadTexture.LoadTextureOrSprite(self.forbiddenPath)
        self.Error403ImageList[originImgUrl] = true
        for _, reqData in ipairs(reqDataList) do
          self:_ClearIndexToInfoData(reqData.index)
          log_tree(reqData)
          if reqData.failCallback and type(reqData.failCallback) == "function" then
            reqData.successCallback(texture, reqData.url or imgUrl)
          end
        end
        return
      end
    end
    for _, reqData in ipairs(reqDataList) do
      self:_ClearIndexToInfoData(reqData.index)
      if reqData.failCallback and type(reqData.failCallback) == "function" then
        log(bWriteLog and "image_download_mgr failCallback")
        reqData.failCallback(originImgUrl)
      end
    end
    return
  end
  Client.AddCrashContextData(2505, originImgUrl, false, 1000)
  local thumbImageScale
  if not enableCDNCompress then
    thumbImageScale = self:_GetThumbImageScale(reqDataList)
  end
  local texture
  local bSuccessGetThumb = false
  if thumbImageScale then
    bSuccessGetThumb, texture = self:_GetAndSaveThumbTexture(respData, imgUrl, reqDataList, thumbImageScale)
  end
  if not bSuccessGetThumb then
    texture = imageDownloadUtil.GetTexture2DFromArray(respData, enableCDNCompress)
  end
  if not slua.isValid(texture) then
    if enableCDNCompress then
      log(bWriteLog and "image_download_mgr _HttpDownloadCallBack _RetryUncompressImgDownload")
      self:_RetryUncompressImgDownload(originImgUrl, reqDataList)
      return
    end
    for _, reqData in ipairs(reqDataList) do
      self:_ClearIndexToInfoData(reqData.index)
      if reqData.failCallback and type(reqData.failCallback) == "function" then
        log(bWriteLog and "image_download_mgr failCallback texture is invalid")
        reqData.failCallback(originImgUrl)
      end
    end
    return
  end
  log(bWriteLog and "image_download_mgr http callback isSuccess:" .. tostring(isSuccess) .. " imgUrl:" .. tostring(imgUrl))
  if not bSuccessGetThumb then
    self:_SaveLocalCacheAndFile(respData, texture, imgUrl, reqDataList)
  end
  self:_TriggerSuccessCallback(originImgUrl, reqDataList, texture, respData)
end
function image_download_mgr:_TriggerSuccessCallback(imgUrl, reqDataList, texture, respData, bFromDiskLoad)
  if not slua.isValid(texture) then
    log(bWriteLog and "image_download_mgr _TriggerSuccessCallback texture is invalid")
    return
  end
  if reqDataList and type(reqDataList) == "table" then
    for _, reqData in ipairs(reqDataList) do
      self:_ClearIndexToInfoData(reqData.index)
      if not bFromDiskLoad and reqData.otherParams and reqData.otherParams.AvatarIconOriginUrl and reqData.otherParams.AvatarIconOriginUrl ~= "" then
        local avatarIconOriginUrl = reqData.otherParams.AvatarIconOriginUrl
        log(bWriteLog and "image_download_mgr http callback AvatarIconOriginUrl extraSave:" .. tostring(avatarIconOriginUrl))
        self:_SaveLocalCacheAndFile(respData, texture, avatarIconOriginUrl, reqDataList)
      end
      if reqData.successCallback and type(reqData.successCallback) == "function" then
        self:_ShowDetailFormatLog("_TriggerSuccessCallback", imgUrl, bFromDiskLoad, reqData.ReqDownloadTime)
        reqData.successCallback(texture, reqData.url or imgUrl)
      end
    end
  end
end
function image_download_mgr:_SendImageDownloadRequest(imgUrl)
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_SendImageDownloadRequest imgUrl is " .. tostring(imgUrl))
  end
  if not imgUrl or not self.downloadReqData then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_SendImageDownloadRequest invalid imgUrl or invalid downloadReq!")
    end
    return
  end
  local reqDataList = self.downloadReqData[imgUrl]
  if not reqDataList or type(reqDataList) ~= "table" or not next(reqDataList) then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_SendImageDownloadRequest invalid imgUrl ReqDats!")
    end
    return
  end
  self.downloadingNum = self.downloadingNum + 1
  local HttpHeader = {}
  if self:IsURLSupportWebp(imgUrl) and self.HttpHeader then
    HttpHeader = self.HttpHeader
  end
  local reqIndex = 0
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  reqIndex = http_manager:ImageDownloadRequest(imgUrl, HttpHeader, "", nil, function(isSuccess, respData, content, result)
    if self.downloadingNum > 0 then
      self.downloadingNum = self.downloadingNum - 1
    end
    local curReqDataList
    if self.downloadReqData then
      curReqDataList = self.downloadReqData[imgUrl]
      self.downloadReqData[imgUrl] = nil
    end
    if self.urlStatusInfo then
      self.urlStatusInfo[imgUrl] = nil
    end
    self:_HttpDownloadCallBack(isSuccess, respData, imgUrl, curReqDataList, result)
    self:_TryStartDownloadImage()
  end, nil, 0)
  if not self.urlStatusInfo[imgUrl] then
    self.urlStatusInfo[imgUrl] = {}
  end
  self.urlStatusInfo[imgUrl].  self.urlStatusInfo[imgUrl].status = self.Config.EnumImageDownloadStatus.Downloading
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_SendImageDownloadRequest -- reqIndex is " .. tostring(reqIndex))
  end
end
function image_download_mgr:_CheckLocalDiskFile()
  if self.hasCheckDiskFile then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_CheckLocalDiskFile has checked")
    end
    return
  end
  self.hasCheckDiskFile = true
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckLocalDiskFile CheckDiskFile")
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eImageDownloadMgrCache) or {}
  if not cacheData.saveVersion or cacheData.saveVersion ~= ClientVersion then
    log(bWriteLog and "image_download_mgr:_CheckLocalDiskFile old version")
    Client.DeleteDirectory(self:_GetShortTermCacheDir())
    cacheData.saveVersion = ClientVersion
    PlayerPrefsSystem.SaveTableToFile_N(cacheData, PlayerPrefsSystem.ePlayerPrefsType.eImageDownloadMgrCache)
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckLocalDiskFile version match")
  end
  local EnumDiskCacheType = self.Config.EnumDiskCacheType
  imageDownloadUtil.CheckDiskFile(self:_GetCacheTypeDir(EnumDiskCacheType.WeeklyUpdate), self:_GetSubFilePath(EnumDiskCacheType.WeeklyUpdate))
  imageDownloadUtil.CheckDiskFile(self:_GetCacheTypeDir(EnumDiskCacheType.DailyUpdate), self:_GetSubFilePath(EnumDiskCacheType.DailyUpdate))
end
function image_download_mgr:_GetCacheDir()
  return Client.ProjectSavedDir() .. self.Config.strRootDir
end
function image_download_mgr:_GetShortTermCacheDir()
  return Client.ProjectSavedDir() .. self.Config.strShortTermRootDir
end
function image_download_mgr:_GetFullFilePath(imgUrl, cacheType, thumbScale, noRoot)
  if not imgUrl or type(imgUrl) ~= "string" or imgUrl == "" then
    log(bWriteLog and "image_download_mgr:_GetFullFilePath imgUrl is invalid")
    return ""
  end
  cacheType = cacheType or self.Config.EnumDiskCacheType.DailyUpdate
  local rootDirpath
  if noRoot then
    rootDirpath = self:_GetCacheTypeDir(cacheType)
  else
    rootDirpath = Client.ProjectSavedDir() .. self:_GetCacheTypeDir(cacheType)
  end
  local cacheTypeDir = self:_GetSubFilePath(cacheType)
  local fullDir
  if cacheTypeDir and cacheTypeDir ~= "" then
    fullDir = rootDirpath .. "/" .. cacheTypeDir .. "/"
  else
    fullDir = rootDirpath .. "/"
  end
  local urlHash = Client.MD5HashAnsiString(imgUrl)
  local fullLocalPath = fullDir .. urlHash
  if thumbScale then
    local fileExtend = ".jpg"
    if IsEditor then
      fileExtend = ".png"
    end
    local thumbStr = string.format("%.0f", thumbScale * 100)
    fullLocalPath = fullLocalPath .. "_" .. thumbStr .. fileExtend
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_GetFullFilePath fullLocalPath:" .. fullLocalPath)
  end
  return fullLocalPath
end
function image_download_mgr:_GetSubFilePath(cacheType)
  cacheType = cacheType or self.Config.EnumDiskCacheType.DailyUpdate
  local TimeUtil = require("client.common.time_util")
  local cacheTypeSubDir
  local cacheSeconds = self.Config.CacheTypeSeconds[cacheType]
  if cacheSeconds and 0 < cacheSeconds then
    local days = TimeUtil.GetServerTimeInSec() // cacheSeconds
    cacheTypeSubDir = self.Config.strSubDir .. tostring(days)
  end
  return cacheTypeSubDir
end
function image_download_mgr:_GetCacheTypeDir(cacheType)
  if not cacheType or not self.Config.CacheTypeDirName[cacheType] then
    cacheType = self.Config.EnumDiskCacheType.DailyUpdate
  end
  if cacheType == self.Config.EnumDiskCacheType.NeverDelete then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetCacheTypeDir NeverDelete")
    end
    return self.Config.strRootDir
  end
  local CacheTypeDirName = self.Config.CacheTypeDirName
  local cacheTypeDir = self.Config.strShortTermRootDir .. "/" .. CacheTypeDirName[cacheType]
  return cacheTypeDir
end
function image_download_mgr:_GetCacheTypeListFromReqDataList(reqDataList)
  if not reqDataList or type(reqDataList) ~= "table" then
    log(bWriteLog and "image_download_mgr._GetCacheTypeListFromReqDataList respData is invalid!")
    return {}
  end
  local cacheTypeList = {}
  for _, reqData in ipairs(reqDataList) do
    local cacheType = reqData.cacheType or self.Config.EnumDiskCacheType.DailyUpdate
    if not cacheTypeList[cacheType] then
      cacheTypeList[cacheType] = 1
    end
  end
  if self.Config.bShowDetailLog then
    log_tree(bWriteLog and "image_download_mgr:_GetCacheTypeListFromReqDataList", cacheTypeList)
  end
  return cacheTypeList
end
function image_download_mgr:_SaveLocalCacheAndFile(respData, texture, url, reqDataList)
  log(bWriteLog and "  image_download_mgr:_SaveLocalCacheAndFile. url: " .. tostring(url))
  if not (respData and slua.isValid(texture)) or not url then
    log(bWriteLog and "image_download_mgr._SaveLocalCacheAndFile respData or texture is invalid!")
    return
  end
  local StartExeTime
  if self.Config.bShowDetailLog then
    local TimeUtil = require("client.common.time_util")
    StartExeTime = TimeUtil.GetMicroseconds()
  end
  local TableUtil = require("common.table_util")
  if self.isSaveDiskCache then
    local cacheTypeList = self:_GetCacheTypeListFromReqDataList(reqDataList)
    local compressImgUrl = TableUtil.GetTableValue(reqDataList, 1, "compressImgUrl")
    for cacheType, _ in pairs(cacheTypeList) do
      local filePath
      if compressImgUrl and compressImgUrl ~= "" then
        filePath = self:_GetFullFilePath(compressImgUrl, cacheType)
      else
        filePath = self:_GetFullFilePath(url, cacheType)
      end
      if filePath and filePath ~= "" then
        imageDownloadUtil.SaveImageDownloadDiskFile(respData, filePath)
      end
    end
  end
  if not self.memoryCacheArray then
    self.memoryCacheArray = {}
  end
  self:_SaveTextureToMemory(url, texture)
  self:_ShowDetailFormatLog("_SaveLocalCacheAndFile", url, false, nil, StartExeTime)
end
function image_download_mgr:_GetLocalCacheAndFile(url, savePath, enableCDNCompress, thumbScale, thumbFilePath)
  if not url then
    log(bWriteLog and "image_download_mgr:_GetLocalCacheAndFile url is invalid!")
    return nil
  end
  Client.AddCrashContextData(2504, url, false, 1000)
  local isCompressed = enableCDNCompress or false
  if isCompressed then
    thumbScale = nil
    thumbFilePath = nil
  end
  if thumbScale and thumbScale < 1 then
    url = url .. self.Config.thumbImageName
  end
  local TimeUtil = require("client.common.time_util")
  local loadStartTime = TimeUtil.GetMicroseconds()
  local texture = self:_GetTextureByMemoryUrl(url)
  if texture then
    self:_ShowDetailFormatLog("_GetLocalCacheAndFile", url, false, nil, loadStartTime, texture, nil, "memory1")
    return texture
  end
  if thumbScale and thumbFilePath and thumbFilePath ~= "" then
    texture = imageDownloadUtil.GetTexture2DFromDisk(thumbFilePath, isCompressed)
    if not slua.isValid(texture) and savePath and savePath ~= "" and Client.FullPathFileExist(savePath) then
      local ScreenshotMaker = import("ScreenshotMaker")
      ScreenshotMaker.ResizePicture(savePath, thumbScale, thumbFilePath)
      texture = imageDownloadUtil.GetTexture2DFromDisk(thumbFilePath, isCompressed)
    end
    if not slua.isValid(texture) then
      log(bWriteLog and "image_download_mgr:_GetLocalCacheAndFile thumbScale texture is invalid")
      return nil
    end
  end
  if not slua.isValid(texture) and savePath and type(savePath) == "string" and savePath ~= "" then
    texture = imageDownloadUtil.GetTexture2DFromDisk(savePath, isCompressed)
  end
  if texture then
    self:_SaveTextureToMemory(url, texture)
  end
  self:_ShowDetailFormatLog("_GetLocalCacheAndFile", url, true, nil, loadStartTime, texture, savePath)
  return texture
end
function image_download_mgr:_SaveTextureToMemory(url, texture)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local texturePath = UKismetSystemLibrary.GetPathName(texture)
  if not self.memoryCacheArray then
    self.memoryCacheArray = {}
  end
  self.memoryCacheArray[url] = texturePath
end
function image_download_mgr:_CheckAndInsertUrlToDownloadStack(url, compressImgUrl, isNewUrl)
  if not url then
    log(bWriteLog and "image_download_mgr:_CheckAndInsertUrlToDownloadStack url is invalid!")
    return nil
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckAndInsertUrlToDownloadStack url is " .. tostring(url) .. " isNewUrl is " .. tostring(isNewUrl))
  end
  if not self.downloadStack then
    self.downloadStack = {}
  end
  local downloadUrl = url
  if compressImgUrl and compressImgUrl ~= "" then
    downloadUrl = compressImgUrl
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckAndInsertUrlToDownloadStack downloadUrl is " .. tostring(downloadUrl))
  end
  if isNewUrl then
    table.insert(self.downloadStack, downloadUrl)
    return
  end
  for index, imgUrl in ipairs(self.downloadStack) do
    if imgUrl == downloadUrl then
      table.remove(self.downloadStack, index)
      table.insert(self.downloadStack, downloadUrl)
      return
    end
  end
end
function image_download_mgr:_RecordImageInfo(imgUrl, compressImgUrl, imgReqData)
  if not imgUrl or type(imgReqData) ~= "table" then
    log(bWriteLog and "image_download_mgr:_RecordImageInfo imgUrl or currentReqData is invalid!")
    return nil
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_RecordImageInfo imgUrl is " .. tostring(imgUrl))
  end
  if not self.downloadReqData then
    self.downloadReqData = {}
  end
  local isNewUrl = true
  local realReqUrl = imgUrl
  local bIsCompressed = false
  if compressImgUrl and compressImgUrl ~= "" then
    realReqUrl = compressImgUrl
    bIsCompressed = true
  end
  if not self.urlStatusInfo then
    self.urlStatusInfo = {}
  end
  if self.downloadReqData[realReqUrl] then
    isNewUrl = false
  else
    self.downloadReqData[realReqUrl] = {}
    self.urlStatusInfo[realReqUrl] = {
      url = realReqUrl,
      isCompressed = bIsCompressed,
      reqIndex = 0,
      status = self.Config.EnumImageDownloadStatus.Waiting
    }
  end
  table.insert(self.downloadReqData[realReqUrl], imgReqData)
  return isNewUrl
end
function image_download_mgr:_ClearIndexToInfoData(downloadIndex)
  if not (downloadIndex and self.downloadIndexToInfo) or not self.downloadIndexToInfo[downloadIndex] then
    log(bWriteLog and "image_download_mgr:_ClearIndexToInfoData downloadIndexToInfo is invalid!")
    return nil
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_ClearIndexToInfoData downloadIndex is " .. tostring(downloadIndex))
  end
  self.downloadIndexToInfo[downloadIndex] = nil
end
function image_download_mgr:IsURLSupportWebp(imgUrl)
  for _, prefix in pairs(self.Config.DisableWebpURLPrefixes) do
    if string.find(imgUrl, prefix) then
      return false
    end
  end
  return true
end
function image_download_mgr:_AddOneHttpDownload(imgUrl, compressImgUrl, isNewUrl)
  self:_CheckAndInsertUrlToDownloadStack(imgUrl, compressImgUrl, isNewUrl)
  self:_TryStartDownloadImage()
end
function image_download_mgr:_GetTextureCacheFromMemory(imgUrl, compressImgUrl, thumbScale)
  if not imgUrl or not self.memoryCacheArray then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local loadStartTime = TimeUtil.GetMicroseconds()
  local texture = self:_GetTextureByMemoryUrl(compressImgUrl)
  if slua.isValid(texture) then
    self:_ShowDetailFormatLog("_GetTextureCacheFromMemory", compressImgUrl, true, nil, loadStartTime, texture, nil, "Memory1")
    return texture
  end
  if thumbScale and thumbScale < 1 and 0 < thumbScale then
    local thumbImageUrl
    thumbImageUrl = imgUrl .. self.Config.thumbImageName
    texture = self:_GetTextureByMemoryUrl(thumbImageUrl)
    if slua.isValid(texture) then
      self:_ShowDetailFormatLog("_GetTextureCacheFromMemory", compressImgUrl, true, nil, loadStartTime, texture, nil, "Memory2")
      return texture
    end
    return nil
  end
  local texture = self:_GetTextureByMemoryUrl(imgUrl)
  if slua.isValid(texture) then
    self:_ShowDetailFormatLog("_GetTextureCacheFromMemory", compressImgUrl, true, nil, loadStartTime, texture, nil, "Memory1")
    return texture
  end
  return nil
end
function image_download_mgr:_GetTextureByMemoryUrl(cachedUrl)
  if not (cachedUrl and self.memoryCacheArray) or not self.memoryCacheArray[cachedUrl] then
    return nil
  end
  local texturePath = self.memoryCacheArray[cachedUrl]
  local texture = imageDownloadUtil.GetTextureFromMemory(texturePath)
  if slua.isValid(texture) then
    return texture
  end
  self.memoryCacheArray[cachedUrl] = nil
  return nil
end
function image_download_mgr:_GetCompressImageUrl(imgUrl)
  if not imgUrl or imgUrl == "" then
    log(bWriteLog and "image_download_mgr:_GetCompressImageUrl imgUrl is invalid")
    return false, nil
  end
  if not string.find(imgUrl, "%.png") then
    log(bWriteLog and "image_download_mgr:_GetCompressImageUrl imgUrl is not png")
    return false, nil
  end
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platformName == DevicePlatformNameMacros.Android then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetCompressImageUrl Android Use Compress etc")
    end
    local compressImgUrl = string.gsub(imgUrl, "%.png", ".etc")
    return true, compressImgUrl
  elseif Client.IsIPhoneFiveS(GameFrontendHUD) then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetCompressImageUrl 5s Use Compress pvrtc")
    end
    local compressImgUrl = string.gsub(imgUrl, "%.png", ".pvrtc")
    return true, compressImgUrl
  elseif platformName == DevicePlatformNameMacros.IOS then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetCompressImageUrl Ios Use Compress astc")
    end
    local compressImgUrl = string.gsub(imgUrl, "%.png", ".astc")
    return true, compressImgUrl
  else
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetCompressImageUrl no need to compress")
    end
    return false, nil
  end
end
function image_download_mgr:_RetryUncompressImgDownload(imgUrl, reqDataList)
  if not (imgUrl and imgUrl ~= "" and reqDataList) or not next(reqDataList) then
    log(bWriteLog and "image_download_mgr:_RetryUncompressImgDownload imgUrl or reqDataList is invalid")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_RetryUncompressImgDownload imgUrl is " .. tostring(imgUrl))
    log_tree(bWriteLog and "image_download_mgr:_RetryUncompressImgDownload reqDataList:", reqDataList)
  end
  if not self.downloadReqData then
    self.downloadReqData = {}
  end
  local isNewUrl = true
  if self.downloadReqData[imgUrl] then
    isNewUrl = false
  else
    self.downloadReqData[imgUrl] = {}
    self.urlStatusInfo[imgUrl] = {
      url = imgUrl,
      isCompressed = false,
      reqIndex = 0,
      status = self.Config.EnumImageDownloadStatus.Waiting
    }
  end
  for _, reqData in ipairs(reqDataList) do
    reqData.compressImgUrl = nil
    local dlIndex = reqData.index
    if dlIndex and self.downloadIndexToInfo and self.downloadIndexToInfo[dlIndex] then
      self.downloadIndexToInfo[dlIndex].compressImgUrl = nil
    end
    table.insert(self.downloadReqData[imgUrl], reqData)
  end
  self:_CheckAndInsertUrlToDownloadStack(imgUrl, nil, isNewUrl)
end
function image_download_mgr:_RetryDevUrlDownload(imgUrl, reqDataList)
  if not (imgUrl and imgUrl ~= "" and reqDataList) or not next(reqDataList) then
    log(bWriteLog and "image_download_mgr:_RetryDevUrlDownload imgUrl or reqDataList is invalid")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_RetryDevUrlDownload imgUrl is " .. tostring(imgUrl))
    log_tree(bWriteLog and "image_download_mgr:_RetryDevUrlDownload reqDataList:", reqDataList)
  end
  local devUrl = self:_ConvertToDevUrl(imgUrl)
  if not self.downloadReqData then
    self.downloadReqData = {}
  end
  local isNewUrl = true
  if self.downloadReqData[devUrl] then
    isNewUrl = false
  else
    self.downloadReqData[devUrl] = {}
    self.urlStatusInfo[devUrl] = {
      url = devUrl,
      isCompressed = false,
      reqIndex = 0,
      status = self.Config.EnumImageDownloadStatus.Waiting,
      isDevUrl = true,
      originUrl = imgUrl
    }
  end
  for _, reqData in ipairs(reqDataList) do
    local newReqData = {}
    for k, v in pairs(reqData) do
      newReqData[k] = v
    end
    newReqData.url = devUrl
    newReqData.originUrl = imgUrl
    newReqData.isDevUrl = true
    local dlIndex = reqData.index
    if dlIndex and self.downloadIndexToInfo and self.downloadIndexToInfo[dlIndex] then
      self.downloadIndexToInfo[dlIndex].url = devUrl
      self.downloadIndexToInfo[dlIndex].originUrl = imgUrl
      self.downloadIndexToInfo[dlIndex].isDevUrl = true
    end
    table.insert(self.downloadReqData[devUrl], newReqData)
  end
  self:_CheckAndInsertUrlToDownloadStack(devUrl, nil, isNewUrl)
end
function image_download_mgr:_ConvertToDevUrl(imgUrl)
  if not imgUrl or imgUrl == "" then
    return imgUrl
  end
  if self:_IsDevUrl(imgUrl) then
    return imgUrl
  end
  local devURL = string.gsub(imgUrl, "//(.-)/", self.devDomainReplaceString, 1)
  if self.token then
    devURL = devURL .. "?_tde_token=" .. self.token
  end
  return devURL
end
function image_download_mgr:_IsDevUrl(imgUrl)
  if not imgUrl or imgUrl == "" then
    return false
  end
  return string.find(imgUrl, self.devDomain) ~= nil
end
function image_download_mgr:DownloadImageForBase(imgUrl, downloadImageMgrData, OnDownloadSuccess, OnDownloadFail, extendedParams, isDevUrl)
  if not assert(imgUrl ~= nil and imgUrl ~= "", "image_download_mgr:DownloadImageForBase: Invalid Url!") then
    return SetTextureConst.Error
  end
  if not assert(type(downloadImageMgrData) == "table", "image_download_mgr:DownloadImageForBase: Invalid downloadImageMgrData!") then
    return SetTextureConst.Error
  end
  local cdnDownloadStrongCache = downloadImageMgrData._cdnDownloadStrongCache or {}
  local downloadingImages = downloadImageMgrData._downloadingImages or {}
  downloadImageMgrData._  downloadImageMgrData._  if string.find(imgUrl, " ") ~= nil then
    log(bWriteLog and "image_download_mgr:DownloadImageForBase:imgUrl has empty")
    imgUrl = string.gsub(imgUrl, " ", "")
  end
  local ifAddRef = extendedParams and extendedParams.ifAddRef or false
  local texture_cache_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.texture_cache_mgr)
  local cacheTexture = texture_cache_mgr:GetTextureCache(imgUrl)
  if slua.isValid(cacheTexture) then
    if OnDownloadSuccess then
      OnDownloadSuccess(cacheTexture, imgUrl)
    end
    return SetTextureConst.Done
  end
  if not self.IsReleaseVersion and not isDevUrl then
    local devURL = self:_ConvertToDevUrl(imgUrl)
    local texture = texture_cache_mgr:GetTextureCache(devURL)
    if slua.isValid(texture) then
      log(bWriteLog and "[SY]image_download_mgr:DownloadImageForBase found devUrl cache for " .. tostring(imgUrl))
      if OnDownloadSuccess then
        OnDownloadSuccess(texture, imgUrl)
      end
      return SetTextureConst.Done
    end
  end
  local failedTimes = 0
  local tryTimes = extendedParams and extendedParams.tryTimes or 1
  local onSuccess = function(texture, url)
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:DownloadImageForBase Download texture success")
    end
    if not slua.isValid(texture) then
      log_error(bWriteLog and "image_download_mgr:DownloadImageForBase Download texture is invalid")
      return
    end
    downloadingImages[imgUrl] = nil
    if ifAddRef then
      texture_cache_mgr:SetTextureCache(texture, imgUrl, true)
      cdnDownloadStrongCache[imgUrl] = 1
    else
      texture_cache_mgr:SetTextureCache(texture, imgUrl, false)
    end
    if OnDownloadSuccess then
      OnDownloadSuccess(texture, imgUrl)
    end
  end
  local function onFail(_)
    failedTimes = failedTimes + 1
    log(bWriteLog and string.format("image_download_mgr:DownloadImageForBase:Download texture[%s] failed, failed times = %d", imgUrl, failedTimes))
    if failedTimes < tryTimes then
      self:DownloadImageByHttpWrapper(imgUrl, onSuccess, onFail, extendedParams)
      return
    end
    downloadingImages[imgUrl] = nil
    if OnDownloadFail then
      OnDownloadFail(imgUrl)
    end
  end
  downloadingImages[imgUrl] = downloadingImages[imgUrl] or {}
  local downloadIndex = self:DownloadImageByHttpWrapper(imgUrl, onSuccess, onFail, extendedParams)
  if downloadingImages[imgUrl] and downloadIndex and 0 < downloadIndex then
    table.insert(downloadingImages[imgUrl], downloadIndex)
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:DownloadImageForBase downloadIndex:" .. tostring(downloadIndex))
  end
  return downloadIndex
end
function image_download_mgr:_TryDownloadTestImage(imgUrl, downloadImageMgrData, OnDownloadSuccess, OnDownloadFail, extendedParams)
  if not assert(imgUrl ~= nil and imgUrl ~= "", "image_download_mgr:_TryDownloadTestImage: Invalid Url!") then
    return nil
  end
  if not assert(type(downloadImageMgrData) == "table", "image_download_mgr:_TryDownloadTestImage: Invalid downloadImageMgrData!") then
    return nil
  end
  if self.DevCDNReplace and not self.IsReleaseVersion then
    imgUrl = self:_ConvertToDevUrl(imgUrl)
    log(bWriteLog and "[SY]image_download_mgr:DownloadImageForBase.DevUrl" .. tostring(imgUrl))
  end
end
function image_download_mgr:RemoveImageDownloadDataForBase(downloadImageMgrData)
  if type(downloadImageMgrData) ~= "table" or not next(downloadImageMgrData) then
    log(bWriteLog and "image_download_mgr:RemoveImageDownloadDataForBase _downloadImageMgrData is nil")
    return
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:RemoveImageDownloadDataForBase")
  end
  local downloadingImages = downloadImageMgrData._downloadingImages
  if type(downloadingImages) == "table" then
    for imgUrl, dlIndexList in pairs(downloadingImages) do
      for _, dlIndex in ipairs(dlIndexList) do
        if 0 < dlIndex then
          self:CancelDownloadByIndex(dlIndex)
        end
      end
    end
  end
  downloadImageMgrData._downloadingImages = nil
  if type(downloadImageMgrData._cdnDownloadStrongCache) ~= "table" then
    downloadImageMgrData._cdnDownloadStrongCache = nil
    return
  end
  for url, _ in pairs(downloadImageMgrData._cdnDownloadStrongCache) do
    local texture_cache_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.texture_cache_mgr)
    texture_cache_mgr:RemoveStrongTextureCache(url)
  end
  downloadImageMgrData._cdnDownloadStrongCache = nil
end
function image_download_mgr:_GetThumbImageScale(reqDataList)
  if type(reqDataList) ~= "table" or not next(reqDataList) then
    log(bWriteLog and "image_download_mgr:_GetThumbImageScale reqDataList is nil")
    return nil
  end
  local ThumbImageScale
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_GetThumbImageScale")
  end
  for _, reqData in ipairs(reqDataList) do
    if not reqData.otherParams or not reqData.otherParams.ThumbImageScale then
      log(bWriteLog and "image_download_mgr:_GetThumbImageScale reqData.otherParams.ThumbImageScale is nil")
      return nil
    end
    if not ThumbImageScale or ThumbImageScale < reqData.otherParams.ThumbImageScale then
      ThumbImageScale = reqData.otherParams.ThumbImageScale
    end
  end
  if ThumbImageScale and 1 <= ThumbImageScale then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetThumbImageScale ThumbImageScale >= 1")
    end
    return nil
  end
  return ThumbImageScale
end
function image_download_mgr:_GetAndSaveThumbTexture(respData, imgUrl, reqDataList, thumbScale)
  if not (imgUrl and reqDataList) or type(reqDataList) ~= "table" or not next(reqDataList) then
    log(bWriteLog and "image_download_mgr:_GetAndSaveThumbTexture no imgUrl or no reqDataList")
    return false, nil
  end
  if not respData then
    log(bWriteLog and "image_download_mgr:_GetAndSaveThumbTexture invalid respData")
    return false, nil
  end
  if not thumbScale or 1 <= thumbScale then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_GetAndSaveThumbTexture invalid thumbScale")
    end
    return false, nil
  end
  local ScreenshotMaker = import("ScreenshotMaker")
  local texture
  local cacheTypeList = {}
  local firstFilePath
  for _, reqData in ipairs(reqDataList) do
    local cacheType = reqData.cacheType or self.Config.EnumDiskCacheType.DailyUpdate
    if not cacheTypeList[cacheType] then
      local filePath = self:_GetFullFilePath(imgUrl, cacheType)
      if filePath and filePath ~= "" then
        imageDownloadUtil.SaveImageDownloadDiskFile(respData, filePath)
        firstFilePath = firstFilePath or filePath
        cacheTypeList[cacheType] = {}
      end
    end
    local ThumbImageScale = reqData.otherParams.ThumbImageScale or 1
    local ThumbStr = string.format("%.0f", ThumbImageScale * 100)
    if ThumbImageScale < 1 and firstFilePath and cacheTypeList[cacheType] and not cacheTypeList[cacheType][ThumbStr] then
      local thumbFilePath = self:_GetFullFilePath(imgUrl, cacheType, ThumbImageScale)
      ScreenshotMaker.ResizePicture(firstFilePath, ThumbImageScale, thumbFilePath)
      if ThumbImageScale == thumbScale and not texture then
        texture = self:_GetLocalCacheAndFile(imgUrl, thumbFilePath, false, thumbScale)
        if not slua.isValid(texture) then
          log(bWriteLog and "image_download_mgr _GetAndSaveThumbTexture slua.isValid(texture) false")
          return false, nil
        end
      end
      cacheTypeList[cacheType][ThumbStr] = 1
    end
  end
  if not slua.isValid(texture) then
    log(bWriteLog and "image_download_mgr _GetAndSaveThumbTexture slua.isValid(texture) false 2")
    return false, nil
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr _GetAndSaveThumbTexture true")
  end
  return true, texture
end
function image_download_mgr:_CheckAndAddToDiskLoadStack(imgUrl, compressImgUrl, isNewUrl, reqData)
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_CheckAndAddToDiskLoadStack realReqUrl is " .. tostring(imgUrl))
  end
  if not self.DiskLoadStack then
    self.DiskLoadStack = {}
  end
  if not isNewUrl then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_CheckAndAddToDiskLoadStack isNewUrl is false")
    end
    return
  end
  local time_ticker = require("common.time_ticker")
  table.insert(self.DiskLoadStack, {
    imgUrl = imgUrl,
    compressImgUrl = compressImgUrl,
    cacheType = reqData and reqData.cacheType
  })
  if not self.DiskLoadTimer then
    self.DiskLoadTimer = self:AddTimerLoop(0, function()
      self:_RealDoDiskLoadTexture()
    end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  end
end
function image_download_mgr:_RemoveDiskloadTimer()
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_RemoveDiskloadTimer")
  end
  if not self.DiskLoadTimer then
    return
  end
  self:RemoveTimer(self.DiskLoadTimer)
  self.DiskLoadTimer = nil
end
function image_download_mgr:_RealDoDiskLoadTexture()
  if not (self.downloadReqData and self.DiskLoadStack) or #self.DiskLoadStack <= 0 or not self.downloadIndexToInfo then
    if self.Config.bShowDetailLog then
      log(bWriteLog and "image_download_mgr:_RealDoDiskLoadTexture remove diskloadtimer")
    end
    self:_RemoveDiskloadTimer()
    return
  end
  local loadStartTime
  if self.Config.bShowDetailLog then
    local TimeUtil = require("client.common.time_util")
    loadStartTime = TimeUtil.GetMicroseconds()
  end
  local loadNum = 0
  local diskStackNum = #self.DiskLoadStack and #self.DiskLoadStack or 0
  for i = diskStackNum, 1, -1 do
    local compressImgUrl = self.DiskLoadStack[i] and self.DiskLoadStack[i].compressImgUrl
    local imgUrl = self.DiskLoadStack[i] and self.DiskLoadStack[i].imgUrl
    local cacheType = self.DiskLoadStack[i] and self.DiskLoadStack[i].cacheType
    local realReqUrl
    if compressImgUrl and compressImgUrl ~= "" then
      realReqUrl = compressImgUrl
    else
      realReqUrl = imgUrl
    end
    if realReqUrl and self.downloadReqData[realReqUrl] and next(self.downloadReqData[realReqUrl]) then
      local reqDataList = self.downloadReqData[realReqUrl]
      local thumbImageScale = self:_GetThumbImageScale(reqDataList)
      local texture = self:GetLocalImageCache(realReqUrl, compressImgUrl ~= nil, cacheType, thumbImageScale)
      if slua.isValid(texture) then
        self:_TriggerSuccessCallback(imgUrl, reqDataList, texture, nil, true)
        self.downloadReqData[realReqUrl] = nil
        self.urlStatusInfo[realReqUrl] = nil
      else
        self:_AddOneHttpDownload(imgUrl, compressImgUrl, true)
      end
      loadNum = loadNum + 1
    end
    table.remove(self.DiskLoadStack, i)
    if loadNum >= self.Config.DiskLoadNumOneFrame then
      break
    end
  end
  if #self.DiskLoadStack <= 0 or not next(self.downloadReqData) then
    self:_RemoveDiskloadTimer()
  end
  if self.Config.bShowDetailLog then
    log(bWriteLog and "image_download_mgr:_RealDoDiskLoadTexture loadNum:" .. tostring(loadNum))
  end
  self:_ShowDetailFormatLog("_RealDoDiskLoadTexture", "", true, nil, loadStartTime)
end
function image_download_mgr:_ShowDetailFormatLog(FunctionName, imgUrl, bFromDiskLoad, secStartTime, microStartTime, texture, DiskPath, extraStr)
  if not self.Config.bShowDetailLog then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local logStr = "DetailFormatLog image_download_mgr::%s imgUrl:%s, bFromDiskLoad:%s"
  if secStartTime then
    local curSecTime = TimeUtil.GetServerTimeInSec()
    logStr = logStr .. ", TotalTime(Sec): " .. curSecTime - secStartTime
  end
  if microStartTime then
    local curMicroTime = TimeUtil.GetMicroseconds()
    logStr = logStr .. string.format(", TotalTime(MicroSec):[%.3fms] ", (curMicroTime - microStartTime) / 1000)
  end
  if slua.isValid(texture) then
    logStr = logStr .. ", TextureSizeX:" .. tostring(texture:Blueprint_GetSizeX() or -1) .. ", TextureSizeY:" .. tostring(texture:Blueprint_GetSizeY() or -1)
  end
  if DiskPath then
    logStr = logStr .. ", DiskPath: " .. tostring(DiskPath)
  end
  if extraStr then
    logStr = logStr .. ", extraStr: " .. tostring(extraStr)
  end
  log(bWriteLog and string.format(logStr, tostring(FunctionName), tostring(imgUrl), tostring(bFromDiskLoad)))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CImageDownloadMgr = class(CModuleBase, nil, image_download_mgr)
return CImageDownloadMgr
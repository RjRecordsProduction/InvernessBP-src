local asset_util = {loadFromCacheHandleID = 0}
local table_pack = table.pack
local local local getMicroseconds = slua.getMicroseconds
local string_find = string.find
local local local local AsyncLoadAssetInfoMap = {}
local AsyncLoadDiskAssetMap = {}
local USavedFileUtil, imageDownloadUtil
function asset_util.GetAssetAsyncOneParam(AssetPath, Callback, self)
  if not assert(type(AssetPath) == "string", "asset_util.GetAssetAsyncOneParam AssetsPath must be string") then
    return nil
  end
  if not assert(type(Callback) == "function", "asset_util.GetAssetAsyncOneParam Callback must be function") then
    return nil
  end
  local _beginTime = getMicroseconds()
  local HandleID = asset_util.loadFromCacheHandleID
  HandleID = slua.AsyncLoadAsset(AssetPath, function(Asset)
    AsyncLoadAssetInfoMap[HandleID] = nil
    local _useTime = (getMicroseconds() - _beginTime) / 1000
    log(bWriteLog and string.format("TimeTracer asset_util.GetAssetAsyncOneParam AssetPath:%s time: [%.3fms] HandleID:%d", AssetPath, _useTime, HandleID))
    if self then
      return Callback(self, Asset, HandleID)
    else
      return Callback(Asset, HandleID)
    end
  end)
  if HandleID ~= asset_util.loadFromCacheHandleID then
    AsyncLoadAssetInfoMap[HandleID] = true
  end
  return HandleID
end
function asset_util.GetAssetAsync(AssetPath, Callback, ...)
  if not AssetPath then
    log_error("asset_util.GetAssetAsync AssetPath is nil")
    return nil
  end
  if not assert(type(AssetPath) == "string", "asset_util.GetAssetAsync AssetsPath must be string") then
    return nil
  end
  if not assert(type(Callback) == "function", "asset_util.GetAssetAsync Callback must be function") then
    return nil
  end
  local _beginTime = getMicroseconds()
  local args = table_pack(...)
  local HandleID = asset_util.loadFromCacheHandleID
  HandleID = slua.AsyncLoadAsset(AssetPath, function(Asset)
    AsyncLoadAssetInfoMap[HandleID] = nil
    local _useTime = (getMicroseconds() - _beginTime) / 1000
    log(bWriteLog and string.format("TimeTracer asset_util.GetAssetAsync AssetPath:%s time: [%.3fms] HandleID:%d", AssetPath, _useTime, HandleID))
    local common = require("client.slua_ui_framework.common")
    return common.CallCombinationArgs(Callback, args, Asset, HandleID)
  end)
  if HandleID ~= asset_util.loadFromCacheHandleID then
    AsyncLoadAssetInfoMap[HandleID] = true
  end
  return HandleID
end
function asset_util.GetSavedTextureAsync(path, isCompressed, callback)
  if not assert(type(path) == "string", "asset_util.GetSavedTextureAsync AssetsPath must be string") then
    return nil
  end
  if not assert(type(callback) == "function", "asset_util.GetSavedTextureAsync Callback must be function") then
    return nil
  end
  local _beginTime = getMicroseconds()
  local HandleID
  log(bWriteLog and "  asset_util.GetSavedTextureAsync.  " .. tostring(path) .. ", isCompressed:" .. tostring(isCompressed))
  if not USavedFileUtil then
    USavedFileUtil = import("SavedFileUtil")
  end
  if not imageDownloadUtil then
    imageDownloadUtil = import("ImageDownloadUtil")
  end
  HandleID = USavedFileUtil.LoadFileToArrayAsync(path, function(buffer)
    local texture = imageDownloadUtil.GetTexture2DFromArray(buffer, isCompressed)
    if not AsyncLoadDiskAssetMap[HandleID] then
      return
    end
    AsyncLoadDiskAssetMap[HandleID] = nil
    local _useTime = (getMicroseconds() - _beginTime) / 1000
    log(bWriteLog and string.format("TimeTracer asset_util.GetSavedTextureAsync AssetPath:%s time: [%.3fms] HandleID:%d", path, _useTime, HandleID))
    local utility = require("common.utility")
    return xpcall(callback, utility.ErrorMessageHandler, texture)
  end)
  if HandleID ~= 0 then
    AsyncLoadDiskAssetMap[HandleID] = true
  end
  return HandleID
end
function asset_util.GetSavedTextureSync(path)
  if not path or path == "" or not string_find(path, "/Saved/") then
    return
  end
  local BusinessHelper = import("BusinessHelper")
  local path = BusinessHelper.GetMobileBasePath(path)
  local LoadTexture = import("LoadTexture")
  return LoadTexture.GetTexture2DFromDiskFile(path)
end
function asset_util.CancelSavedTextureAsync(HandleID)
  if not assert(type(HandleID) == "number", "asset_util.CancelSavedTextureAsync HandleID must be number ") then
    return false
  end
  if AsyncLoadDiskAssetMap[HandleID] then
    log(bWriteLog and "  asset_util.CancelSavedTextureAsync.  :" .. tostring(HandleID))
    if not USavedFileUtil then
      USavedFileUtil = import("SavedFileUtil")
    end
    if USavedFileUtil.CancelLoadSavedFile then
      USavedFileUtil.CancelLoadSavedFile(HandleID)
    else
      USavedFileUtil.CancelLoadSavedImage(HandleID)
    end
    AsyncLoadDiskAssetMap[HandleID] = nil
    return true
  elseif asset_util.loadFromCacheHandleID ~= HandleID then
    log_error(bWriteLog and string.format("asset_util.CancelSavedTextureAsync. already canceled HandleID=%s", tostring(HandleID)))
  end
  return false
end
function asset_util.GetAssetsArrayAsyncParallel(AssetPathArray, Callback, self)
  if not assert(type(AssetPathArray) == "table", "asset_util.GetAssetsArrayAsyncParallel AssetPathArray must be table ") then
    return nil
  end
  if not assert(type(Callback) == "function", "asset_util.GetAssetAsyncArray Callback must be function") then
    return nil
  end
  local _beginTime = getMicroseconds()
  local HandleID = asset_util.loadFromCacheHandleID
  HandleID = slua.AsyncLoadAssetArray(AssetPathArray, function(cbHandleID)
    AsyncLoadAssetInfoMap[HandleID] = nil
    local _useTime = (getMicroseconds() - _beginTime) / 1000
    log(bWriteLog and string.format("TimeTracer asset_util.GetAssetAsyncArray time: [%.3fms] HandleID:%d", _useTime, HandleID))
    if self then
      return Callback(self, HandleID)
    else
      return Callback(HandleID)
    end
  end)
  if HandleID ~= asset_util.loadFromCacheHandleID then
    AsyncLoadAssetInfoMap[HandleID] = true
  end
  return HandleID
end
function asset_util.GetAssetsArrayAsyncSerial(AssetPathArray, Callback, self)
  if not assert(type(AssetPathArray) == "table", "asset_util.GetAssetsArrayAsyncSerial AssetPathArray must be table ") then
    return nil
  end
  if not assert(type(Callback) == "function", "asset_util.GetAssetsArrayAsyncSerial Callback must be function") then
    return nil
  end
  local GetAssetAsyncOneParamStartTime = getMicroseconds()
  local GetAssetAsyncOneParamEndTime
  local function GetAssetAsync(i)
    local HandleID = asset_util.loadFromCacheHandleID
    HandleID = asset_util.GetAssetAsyncOneParam(AssetPathArray[i], function(Asset)
      if self then
        return Callback(self, Asset, HandleID)
      else
        return Callback(Asset, HandleID)
      end
      if i >= #AssetPathArray then
        GetAssetAsyncOneParamEndTime = getMicroseconds()
        log(bWriteLog and string.format("TimeTracer GetAssetsArrayAsyncSerial: %f ms. ", (GetAssetAsyncOneParamEndTime - GetAssetAsyncOneParamStartTime) / 1000))
      else
        GetAssetAsync(i + 1)
      end
    end)
  end
  GetAssetAsync(1)
end
function asset_util.CancelAssetAsync(HandleID)
  if not assert(type(HandleID) == "number", "asset_util.CancelAssetAsync HandleID must be number ") then
    return
  end
  if AsyncLoadAssetInfoMap[HandleID] then
    slua.CancelLoadAsset(HandleID)
    AsyncLoadAssetInfoMap[HandleID] = nil
  elseif asset_util.loadFromCacheHandleID ~= HandleID then
    log_error(bWriteLog and string.format("asset_util.CancelAssetAsync. HandleID=%s", tostring(HandleID)))
  end
end
function asset_util.GetAssetSync(AssetPath)
  if not assert(type(AssetPath) == "string", "asset_util.GetAssetSync AssetsPath must be string") then
    return nil
  end
  local asset
  if string_find(AssetPath, "/Game/") then
    asset = slua.loadObject(AssetPath)
  end
  asset = asset or asset_util.GetSavedTextureSync(AssetPath)
  return asset
end
return asset_util
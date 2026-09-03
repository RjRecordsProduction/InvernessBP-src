HDmpveRemote = {}
local cache = {
  HDmpveRemoteConfigGetBool_bCache = {},
  HDmpveRemoteConfigGetBool_Value = {},
  HDmpveRemoteConfigGetInt = {},
  HDmpveRemoteConfigGetString = {}
}
function HDmpveRemote.HDmpveRemoteConfigGetBool(key, default)
  local extraPatchValue = HDmpveRemote.GetPatchValue(key)
  if extraPatchValue ~= nil then
    return extraPatchValue
  end
  local bCache = cache.HDmpveRemoteConfigGetBool_bCache[key]
  if bCache then
    log(bWriteLog and "HDmpveRemoteConfigGetBool hit cache key:" .. key .. " value:" .. tostring(cache.HDmpveRemoteConfigGetBool_Value[key]))
    return cache.HDmpveRemoteConfigGetBool_Value[key]
  end
  local ret = Client and Client.HDmpveRemoteConfigGetBool(key, default)
  cache.HDmpveRemoteConfigGetBool_bCache[key] = true
  cache.HDmpveRemoteConfigGetBool_Value[key] = ret
  return ret
end
function HDmpveRemote.HDmpveRemoteConfigGetInt(key, default)
  local extraPatchValue = HDmpveRemote.GetPatchValue(key)
  if extraPatchValue ~= nil then
    return extraPatchValue
  end
  local cacheValue = cache.HDmpveRemoteConfigGetInt[key]
  if cacheValue then
    return cacheValue
  end
  local ret = Client and Client.HDmpveRemoteConfigGetInt(key, default)
  cache.HDmpveRemoteConfigGetInt[key] = ret
  return ret
end
function HDmpveRemote.HDmpveRemoteConfigGetString(key, default)
  local extraPatchValue = HDmpveRemote.GetPatchValue(key)
  if extraPatchValue ~= nil then
    return extraPatchValue
  end
  local cacheValue = cache.HDmpveRemoteConfigGetString[key]
  if cacheValue then
    return cacheValue
  end
  local ret = Client and Client.HDmpveRemoteConfigGetString(key, default)
  cache.HDmpveRemoteConfigGetString[key] = ret
  return ret
end
local BlueholeIOSRemoteConfigExtraPatch = {
  EnbaleBGDownloadNotification = true,
  ForceMediaChannelOutpuOSVersion = "17,18,26",
  EnableWWiseVoicePluginOSVers = "999999",
  CheckRoomNameForReEnter = false,
  DisableDolby = true,
  WWiseSilenceMode = true
}
function HDmpveRemote.GetPatchValue(key)
  local ret
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if PublishRegionMacros.IsBLUEHOLE() and Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local mapValue = BlueholeIOSRemoteConfigExtraPatch[key]
    if mapValue ~= nil then
      ret = mapValue
    end
  end
  log(bWriteLog and "HDmpveRemoteExtraPatch.GetPatchValue return:" .. tostring(ret) .. " by key:" .. key)
  return ret
end
function TableToSortedContent(dict)
  local ret
  local keys = {}
  local vals = {}
  for key in pairs(dict) do
    table.insert(keys, key)
  end
  table.sort(keys)
  for _, k in ipairs(keys) do
    table.insert(vals, k .. " : " .. tostring(dict[k]))
  end
  ret = table.concat(vals, "\n")
  return ret
end
function HDmpveRemote.DumpCacheToFile()
  local content = ""
  content = content .. "Bool Val:\n"
  content = content .. TableToSortedContent(cache.HDmpveRemoteConfigGetBool_Value)
  content = content .. [[
]]
  content = content .. "Int Val:\n"
  content = content .. TableToSortedContent(cache.HDmpveRemoteConfigGetInt)
  content = content .. [[
]]
  content = content .. "String Val:\n"
  content = content .. TableToSortedContent(cache.HDmpveRemoteConfigGetString)
  local dirPath = Client.ProjectSavedDir() .. "/Profiling/RunConfig/"
  local timeStr = os.date("%Y%m%d_%H%M%S")
  local filePath = dirPath .. "HDmpveRemote_" .. timeStr .. ".txt"
  require("GameLua.Mod.PlanPH.Tools.PlanPH_BinFileHelper")
  LuaBinFileHelper.SaveToFile(content, filePath)
end
return HDmpveRemote
local NFullVersionLen = 4
local NStandardVersionLen = 3
local NMainVersionLen = 2
local version_util = {sClientVersion = "0"}
local _sNormalVersion = "0.0.0"
local _cacheMatchVersionTb = {}
local _cacheVersion2Tb = {}
local _cacheVersion2Format = {}
local _cacheVersion2Number = {
  [1] = {},
  [NMainVersionLen] = {},
  [NStandardVersionLen] = {},
  [NFullVersionLen] = {}
}
local _cacheVersion2MainVersion = {}
local local local local local table_concat = table.concat
local string_format = string.format
local StringUtil = require("common.string_util")
function version_util.IsMatchVersion(sVersion)
  if _cacheMatchVersionTb[sVersion] ~= nil then
    return _cacheMatchVersionTb[sVersion]
  end
  if version_util.sClientVersion == "0" then
    version_util.sClientVersion = Client.GetAppVersion()
  end
  local clientVersion = version_util.GetClientFormat(version_util.sClientVersion)
  local serverVersion = version_util.GetClientFormat(sVersion)
  local serverStrArray = version_util.GetSplitVersionTb(serverVersion)
  local clientStrArray = version_util.GetSplitVersionTb(clientVersion)
  local bRet = true
  for i = 1, #serverStrArray do
    if tonumber(serverStrArray[i]) ~= tonumber(clientStrArray[i]) then
      bRet = false
      break
    end
  end
  _cacheMatchVersionTb[sVersion] = bRet
  return bRet
end
function version_util.GetSplitVersionTb(version)
  local tb = _cacheVersion2Tb[version]
  if not tb then
    tb = StringUtil.SplitToNum(version, ".")
    _cacheVersion2Tb[version] = tb
  end
  return tb
end
function version_util.GetClientFormat(version)
  local result = _cacheVersion2Format[version]
  if result then
    return result
  end
  local tb = version_util.GetSplitVersionTb(version)
  if not next(tb) or #tb < NStandardVersionLen then
    return _sNormalVersion
  end
  result = table_concat(tb, ".", 1, NStandardVersionLen)
  _cacheVersion2Format[version] = result
  return result
end
function version_util.GetMainFormat(version)
  if _cacheVersion2MainVersion[version] then
    return _cacheVersion2MainVersion[version]
  end
  local tb = version_util.GetSplitVersionTb(version)
  if not next(tb) or #tb < NStandardVersionLen - 1 then
    return _sNormalVersion
  end
  local result = table_concat(tb, ".", 1, NStandardVersionLen - 1)
  _cacheVersion2MainVersion[version] = result .. ".0"
  return _cacheVersion2MainVersion[version]
end
function version_util.ExcludeTheBuildNumber(version)
  return version_util.GetClientFormat(version)
end
function version_util.GetAppVersion()
  local version = Client.GetAppVersion()
  local app_version = global_package_make_time_map["App Version"]
  local patch_version = global_patch_make_time_map["Patch Version"]
  if patch_version and not StringUtil.StrFind(patch_version, "N/A") and version_util.CompareVersionStandard(patch_version, version) >= 0 then
    log(bWriteLog and string_format("FuncUtil.GetAppVersion fix version by Patch Version:%s", patch_version))
    version = patch_version
  elseif app_version and not StringUtil.StrFind(app_version, "N/A") and version_util.CompareVersionStandard(app_version, version) >= 0 then
    log(bWriteLog and string_format("FuncUtil.GetAppVersion fix version by App Version:%s", app_version))
    version = app_version
  end
  return version
end
local CompareNum = function(num1, num2)
  if num1 == num2 then
    return 0
  elseif num2 < num1 then
    return 1
  else
    return -1
  end
end
function version_util.CompareVersionFull(_ver1, _ver2)
  local num1 = version_util.ConvertVersionToNumber(_ver1, NFullVersionLen)
  local num2 = version_util.ConvertVersionToNumber(_ver2, NFullVersionLen)
  return CompareNum(num1, num2)
end
function version_util.CompareVersionStandard(_ver1, _ver2)
  local num1 = version_util.ConvertVersionToNumber(_ver1, NStandardVersionLen)
  local num2 = version_util.ConvertVersionToNumber(_ver2, NStandardVersionLen)
  return CompareNum(num1, num2)
end
function version_util.CompareVersionMain(_ver1, _ver2)
  local num1 = version_util.ConvertVersionToNumber(_ver1, NMainVersionLen)
  local num2 = version_util.ConvertVersionToNumber(_ver2, NMainVersionLen)
  return CompareNum(num1, num2)
end
function version_util.GetVersionNumCache(version, segments)
  if not segments or segments <= 0 then
    segments = NFullVersionLen
  end
  return _cacheVersion2Number[segments][version]
end
function version_util.SaveVersionNumCache(version, segments, num)
  if not segments or segments <= 0 then
    segments = NFullVersionLen
  end
  _cacheVersion2Number[segments][version] = num
end
local power = {
  1.0E9,
  1.0E7,
  100000.0,
  1.0
}
function version_util.ConvertVersionToNumber(version, segments)
  if not version or version == "" then
    return 0
  end
  local result = version_util.GetVersionNumCache(version, segments)
  if result then
    return result
  end
  local arrVersion = version_util.GetSplitVersionTb(version)
  result = 0
  local len = NFullVersionLen
  if arrVersion and next(arrVersion) then
    if segments and 0 < segments and segments <= #arrVersion then
      len = segments
    else
      len = #arrVersion
    end
    for i = 1, len do
      result = result + arrVersion[i] * power[i]
    end
  end
  version_util.SaveVersionNumCache(version, len, result)
  return result
end
function version_util.HigherVersion(_current, _specify)
  local current = version_util.ConvertVersionToNumber(_current)
  local specify = version_util.ConvertVersionToNumber(_specify)
  return current > specify
end
function version_util.LowerVersion(_current, _specify)
  local current = version_util.ConvertVersionToNumber(_current)
  local specify = version_util.ConvertVersionToNumber(_specify)
  return current < specify
end
function version_util.GetCurVersionNumber()
  local version = Client.GetAppVersion()
  local strs = version_util.GetSplitVersionTb(version)
  if not (strs and strs[1]) or not strs[2] then
    log(bWriteLog and "version_util:GetCurVersionNumber. str is invalid")
    return 1000
  end
  local versionNum = tonumber(strs[1]) * 1000 + tonumber(strs[2]) * 100
  return versionNum
end
return version_util
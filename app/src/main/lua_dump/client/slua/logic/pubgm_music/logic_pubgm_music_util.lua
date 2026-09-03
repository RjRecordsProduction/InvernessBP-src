local logic_music_const = require("client.slua.logic.pubgm_music.logic_music_const")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local C_ServerConfigName = logic_music_const.C_ServerConfigName
local logic_pubgm_music_util = {newMusicData = nil}
function logic_pubgm_music_util.GetPakNameConcatVersion(url)
  return string.format("%s.pak", url)
end
function logic_pubgm_music_util.GetFormatExpireTimeStr(expireTime)
  local TimeUtil = require("client.common.time_util")
  if string.len(expireTime) > 1 then
    local extTimeStamp = TimeUtil.TimeStringToUnixstamp(expireTime)
    local extTime = TimeUtil.FormatTime_YMD(extTimeStamp)
    return LocUtil.LocalizeResFormat(19217, extTime)
  end
  return ""
end
function logic_pubgm_music_util.GetRandomIndex(curIndex, length)
  local newIndex = curIndex
  if 1 < length then
    newIndex = math.random(length)
  end
  return newIndex
end
function logic_pubgm_music_util.GetConfig()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  return BasicDataServerTable:GetCacheData(C_ServerConfigName) or {}
end
function logic_pubgm_music_util.FilterData(list, data)
  if not list or not data then
    return nil
  end
  log(bWriteLog and "[muidarzhang] FilterData(list, data)")
  local dest = {}
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  for _, id in ipairs(list) do
    for _, v in pairs(data) do
      if id == v.nID and not musicManager:IsBlackWithRegionAndPath(nil, v.cfg.play_event) then
        table.insert(dest, v)
        break
      end
    end
  end
  return dest
end
function logic_pubgm_music_util.SortMusicList(a, b)
  local dataA = a.data
  local dataB = b.data
  if not dataA and dataB then
    return false
  elseif dataA and not dataB then
    return true
  else
    return a.nID > b.nID
  end
end
function logic_pubgm_music_util.IsMusicValidByTime(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local valid = true
  if 0 < startTime and startTime > now then
    valid = false
  elseif 0 < endTime and endTime < now then
    valid = false
  end
  return valid
end
function logic_pubgm_music_util.IsMusicValidByVersion(version, appVersion)
  if not version or version == "" then
    return true
  end
  local version_util = require("client.common.version_util")
  if version_util.CompareVersionStandard(appVersion, version) >= 0 then
    return true
  end
  return false
end
function logic_pubgm_music_util.IsMusicValidByCounrty(curCountry, musicCountry)
  if musicCountry == "" or not musicCountry then
    return true
  end
  local StringUtil = require("common.string_util")
  local countryList = StringUtil.Split(musicCountry, "|")
  for _, v in ipairs(countryList) do
    if v == curCountry then
      return true
    end
  end
  return false
end
function logic_pubgm_music_util.GetMusicRandomInfo(randomMusicList)
  local length = #randomMusicList
  if length == 1 then
    return randomMusicList[1]
  end
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  local curMusicId = musicManager:GetCurMusicId(true)
  local cur_index = 0
  for index, value in pairs(randomMusicList) do
    if value.nID == curMusicId then
      cur_      break
    end
  end
  local newIndex = 1
  if cur_index == 0 then
    newIndex = math.random(length)
  else
    newIndex = (cur_index + math.random(length - 1) - 1) % length + 1
  end
  return randomMusicList[newIndex]
end
return logic_pubgm_music_util
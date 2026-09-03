local pandora_slap_system = {}
local priority = {
  [BP_ENUM_MODULE_KNIGHT_WARP_UP] = 97,
  [BP_ENUM_MODULE_GOLDEN_SUIT_PREVIEW] = 98,
  [BP_ENUM_MODULE_PANDORA_ACTIVITY_NAVIGATOR] = 100,
  [BP_ENUM_MODULE_PANDORA_ACTIVITY_NAVIGATOR_2] = 101,
  [BP_ENUM_MODULE_PANDORA_ACTIVITY_NAVIGATOR_SUBWAY] = 102,
  [BP_ENUM_MODULE_PANDORA_SEVEN] = 104,
  [BP_ENUM_MODULE_PANDORA_SEVEN_IN] = 103,
  [BP_ENUM_MODULE_PANDORA_MIDDLEEAST_LUCK] = 105
}
local slapCountMax = 10
local jumpUrl
local specialSlapCount = {
  [BP_ENUM_MODULE_KNIGHT_WARP_UP] = 3
}
function pandora_slap_system.ShouldSlap()
  local JumpUtils = require("client.logic.store.jump_utils")
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  if not pandoraSystem.CheckSysOpen() then
    log(bWriteLog and "pandora_slap_system.ShouldSlap BP_ENUM_PANDORA_OPEN close")
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_PANDORA_SLAP_OPEN) then
    log(bWriteLog and "pandora_slap_system.ShouldSlap BP_ENUM_PANDORA_SLAP_OPEN close")
    return false
  end
  if DataMgr and DataMgr.roleData and DataMgr.roleData.level and DataMgr.roleData.level < 5 then
    log(bWriteLog and "[jonahwei]FaceSlapLimit: roleData.level = " .. DataMgr.roleData.level)
    return false
  end
  local jumpInfo = {}
  for _, v in pairs(LobbySystem.activityDisplayDataList) do
    if JumpUtils.IsPanDoraJumpUrl(v.JumpUrl) then
      local StringUtil = require("common.string_util")
      local params = StringUtil.ParseURLParams(v.JumpUrl)
      local actid = tonumber(params.actid)
      if pandora_slap_system.IsInSlapTable(actid) and pandora_slap_system.CheckPriority(jumpInfo.actid, actid) and pandora_slap_system.CheckTime(v.StartTimeUTC, v.EndTimeUTC) and pandora_slap_system.CheckPandoraReady(actid) and pandora_slap_system.CheckSlapCount(actid) and pandora_slap_system.CheckSlapInterval(actid) then
        jumpInfo.JumpUrl = v.JumpUrl
        jumpInfo.      end
    end
  end
  if jumpInfo.JumpUrl ~= nil then
    jumpUrl = jumpInfo.JumpUrl
    return true
  end
  return false
end
function pandora_slap_system.IsInSlapTable(actid)
  return priority[actid] ~= nil
end
function pandora_slap_system.CheckPriority(actid_1, actid_2)
  if actid_1 == nil or actid_1 == 0 or priority[actid_1] == nil then
    return true
  end
  return priority[actid_2] > priority[actid_1]
end
function pandora_slap_system.CheckTime(startTimeUTC, endTimeUTC)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  return startTimeUTC <= serverTime and endTimeUTC >= serverTime
end
function pandora_slap_system.CheckPandoraReady(actid)
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  log(bWriteLog and string.format("pandora_slap_system.CheckPandoraReady actid:%s actIsReady:%s actPakIsReady:%s", tostring(actid), tostring(pandoraSystem.ActIsReady(actid)), tostring(pandoraSystem.ActPakIsReady(actid))))
  return pandoraSystem.CheckActIsShowByUrl(actid)
end
function pandora_slap_system.CheckSlapCount(actid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ePandoraRecord .. "/" .. tostring(actid)
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or saveData.slapCount == nil then
    return true
  end
  if specialSlapCount[actid] then
    return saveData.slapCount < tonumber(specialSlapCount[actid])
  end
  return saveData.slapCount < slapCountMax
end
function pandora_slap_system.CheckSlapInterval(actid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ePandoraRecord .. "/" .. tostring(actid)
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or saveData.slapTime == nil then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local lastSlapDay = TimeUtil.OSDate("%d", saveData.slapTime)
  local curDay = TimeUtil.OSDate("%d", TimeUtil.GetServerTimeInSec())
  return curDay ~= lastSlapDay
end
function pandora_slap_system.SaveSlapInfo(actid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ePandoraRecord .. "/" .. tostring(actid)
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  local TimeUtil = require("client.common.time_util")
  saveData.slapTime = TimeUtil.GetServerTimeInSec()
  local slapCount = saveData.slapCount or 0
  saveData.slapCount = slapCount + 1
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function pandora_slap_system.GetJumpUrl()
  return jumpUrl
end
return pandora_slap_system
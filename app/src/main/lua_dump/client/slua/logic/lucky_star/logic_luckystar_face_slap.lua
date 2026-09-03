local logic_luckystar_face_slap = {}
function logic_luckystar_face_slap.ShouldSlap()
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_luckystar_face_slap.ShouldSlap UI responsiveness testing")
    return false
  end
  local logic_luckystar = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_luckystar)
  if not logic_luckystar:IsLuckyStarValid() then
    log(bWriteLog and "[logic_luckystar_face_slap] lucky star not valid")
    return false
  end
  local lucky_star_map = logic_luckystar:GetLuckyStarMap()
  if not lucky_star_map then
    log(bWriteLog and "[logic_luckystar_face_slap] nil lucky star list")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLuckyStarRecord) or {}
  local last_slap_ts = saveData.last_slap_ts or 0
  local TimeUtil = require("client.common.time_util")
  local cur_ts = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameWeek(last_slap_ts, cur_ts) then
    log(bWriteLog and "[logic_luckystar_face_slap] same week")
    return false
  end
  saveData.last_slap_ts = cur_ts
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eLuckyStarRecord)
  log(bWriteLog and "[logic_luckystar_face_slap] pop up lucky star slap")
  return true
end
return logic_luckystar_face_slap
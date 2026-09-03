local RoleInfoCombatSystem = {}
local GradeImagePathList = {
  [0] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_B.JS_icon_B",
  [1] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_B+.JS_icon_B+",
  [2] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_A.JS_icon_A",
  [3] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_A+.JS_icon_A+",
  [4] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_S.JS_icon_S",
  [5] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_S+.JS_icon_S+",
  [6] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SS.JS_icon_SS",
  [7] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SS+.JS_icon_SS+",
  [8] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SSS.JS_icon_SSS"
}
local IsInitZoneList = false
local ZoneMap = {}
function RoleInfoCombatSystem.GetGradeImgPathByIndex(index)
  return GradeImagePathList[tonumber(index)] or ""
end
function RoleInfoCombatSystem.SetIsInitZoneList(is_init)
  IsInitZoneList = is_init or false
end
function RoleInfoCombatSystem.GetIsInitZoneList()
  return IsInitZoneList or false
end
function RoleInfoCombatSystem.GetZoneMapData()
  return ZoneMap or {}
end
function RoleInfoCombatSystem.AddZoneMapData(key, value)
  if not ZoneMap then
    ZoneMap = {}
  end
  ZoneMap[key] = value
end
function RoleInfoCombatSystem.SaveLocalJsonZoneID(zone_id)
  local actJson = RoleInfoCombatSystem.LoadPlayerprefsZoneID()
  actJson.RoleInfoChooseZoneId = tostring(zone_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoZoneID)
end
function RoleInfoCombatSystem.LoadPlayerprefsZoneID()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  return PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRoleInfoZoneID) or {}
end
return RoleInfoCombatSystem
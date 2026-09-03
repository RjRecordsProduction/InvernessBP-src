local logic_config_mission_select_mode = {
  missionSelectModeConfig = {
    [3900] = "client.slua.umg.TxMission.xMission.zombie.logic.logic_zombie_mission_select_mode"
  }
}
function logic_config_mission_select_mode.getLogic()
  local version_util = require("client.common.version_util")
  local AppVersion = version_util.GetCurVersionNumber()
  log(bWriteLog and "logic_config_mission_select_mode.getLogic() AppVersion = " .. AppVersion)
  local logicClassName = logic_config_mission_select_mode.missionSelectModeConfig[AppVersion]
  if not logicClassName then
    return {}
  end
  printf("logic_config_mission_select_mode.getLogic. logicClassName=%s", tostring(logicClassName))
  return require(logicClassName) or {}
end
return logic_config_mission_select_mode
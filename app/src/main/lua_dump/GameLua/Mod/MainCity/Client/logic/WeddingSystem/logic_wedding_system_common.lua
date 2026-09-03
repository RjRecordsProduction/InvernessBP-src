local logic_wedding_system_common = {
  Status = {
    NotOpen = 0,
    Open = 1,
    Close = 2
  },
  NoticeLocID = 81158
}
function logic_wedding_system_common.CheckGuinnessTime()
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetMainFormat(Client.GetAppVersion())
  log("logic_wedding_system_common.CheckGuinnessTime curVersion: " .. curVersion)
  local actCfgList = CDataTable.GetTableByFilter("GuinnessActivityCfg", "version", curVersion)
  if not actCfgList then
    log("logic_wedding_system_common.CheckGuinnessTime curVersion has no actCfgList", curVersion)
    return logic_wedding_system_common.Status.NotOpen, 0, 0
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local actCfg = {}
  for actID, uConfig in pairs(actCfgList) do
    actCfg = uConfig
  end
  log_tree("logic_wedding_system_common.CheckGuinnessTime actCfg: ", actCfg)
  local start_time_str = actCfg.beginTime
  local end_time_str = actCfg.endTime
  log("logic_wedding_system_common.CheckGuinnessTime start_time_str and end_time_str", start_time_str, end_time_str)
  if start_time_str and end_time_str then
    local start_time = TimeUtil.TimeStringToUnixstamp(start_time_str, false)
    local end_time = TimeUtil.TimeStringToUnixstamp(end_time_str, false)
    if nowTime < start_time then
      log("logic_wedding_system_common.CheckGuinnessTime not open")
      return logic_wedding_system_common.Status.NotOpen, start_time, end_time
    end
    if nowTime > end_time then
      log("logic_wedding_system_common.CheckGuinnessTime close")
      return logic_wedding_system_common.Status.Close, start_time, end_time
    end
    if nowTime > start_time and nowTime < end_time then
      log("logic_wedding_system_common.CheckGuinnessTime open")
      return logic_wedding_system_common.Status.Open, start_time, end_time
    end
  end
  return logic_wedding_system_common.Status.NotOpen, 0, 0
end
function logic_wedding_system_common.CheckWeddingSystemIsOpen()
  local is_open = false
  local TimeUtil = require("client.common.time_util")
  local PlanPH_Common_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Common_Tools")
  local curServerTime = math.floor(PlanPH_Common_Tools.GetDSCurTime())
  local start_time_str = CDataTable.GetTableData("WeddingTableCfg", "soulmate_open_time")
  log("logic_wedding_system_common.CheckWeddingSystemIsOpen start_time_str: " .. start_time_str.ParamValue)
  local startTime = TimeUtil.TimeStringToUnixstamp(start_time_str.ParamValue)
  if curServerTime > startTime then
    is_open = true
  end
  return is_open
end
return logic_wedding_system_common
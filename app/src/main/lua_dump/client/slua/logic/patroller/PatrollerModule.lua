local PatrollerModule = {}
local PatrollerConfig = require("client.slua.logic.patroller.PatrollerConfig")
function PatrollerModule:DefineAndResetData()
  self.privilegeLevel = nil
  self.PatrollerStat = nil
  self.lastUpdateTime = 0
  self.lastQueryTime = 0
  self.bTest = false
  self.testData = {
    privilegeLevel = 1,
    PatrollerStat = {
      level = 11,
      total_cnt = 33,
      punish_cnt = 22
    }
  }
end
function PatrollerModule:IsPatroller()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if serverTime - self.lastUpdateTime > 86400 or self.lastUpdateTime > serverTime + 10 then
    self:send_query_patroller_privilege_level_req()
    return false
  else
    return self.privilegeLevel == 1
  end
end
function PatrollerModule:GetPatrollerLevel()
  local level = self.PatrollerStat and self.PatrollerStat.level
  log(bWriteLog and "PatrollerModule:GetPatrollerLevel " .. tostring(level))
  return level
end
function PatrollerModule:GetPatrollerIconPath(level)
  if not level then
    return nil
  end
  if 1 <= level and level <= 4 then
    return PatrollerConfig.Icon[1]
  elseif 5 <= level and level <= 9 then
    return PatrollerConfig.Icon[2]
  elseif 10 <= level and level <= 14 then
    return PatrollerConfig.Icon[3]
  elseif 15 <= level and level <= 19 then
    return PatrollerConfig.Icon[4]
  elseif 20 <= level and level <= 24 then
    return PatrollerConfig.Icon[5]
  elseif level == 25 then
    return PatrollerConfig.Icon[6]
  end
  return nil
end
function PatrollerModule:GetPatrollerStatData(type)
  if not type then
    return 0
  end
  if not self.PatrollerStat then
    return 0
  end
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if type == ShowBrandConst.ShowType.BanLevel then
    return self.PatrollerStat.level
  elseif type == ShowBrandConst.ShowType.BanTotalCount then
    return self.PatrollerStat.total_cnt
  elseif type == ShowBrandConst.ShowType.BanRealCount then
    return self.PatrollerStat.punish_cnt
  end
  return 0
end
function PatrollerModule:send_query_patroller_privilege_level_req()
  if self.bTest then
    self:AddTimerOnce(0.1, function()
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      self:on_query_patroller_privilege_level_rsp(self.testData.privilegeLevel, serverTime)
    end)
    return
  end
  local PatrollerHandler = require("client.network.Protocol.PatrollerHandler")
  PatrollerHandler.send_query_patroller_privilege_level_req()
end
function PatrollerModule:on_query_patroller_privilege_level_rsp(privilege_level, last_query_time)
  self.privilegeLevel = privilege_level
  self.lastQueryTime = last_query_time
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  self.lastUpdateTime = serverTime
  log(bWriteLog and "PatrollerModule:on_query_patroller_privilege_level_rsp serverTime = " .. tostring(serverTime))
  if not self:IsPatroller() then
    log(bWriteLog and "PatrollerModule:on_query_patroller_privilege_level_rsp not Patroller")
    self.PatrollerStat = nil
  else
    self:send_query_patroller_stat_info_req()
  end
  EventSystem:postEvent(EVENTTYPE_PATROLLER, EVENTID_PATROLLER_UPDATE)
end
function PatrollerModule:send_query_patroller_stat_info_req()
  if self.bTest then
    self:AddTimerOnce(0.1, function()
      self:on_query_patroller_stat_info_rsp(self.testData.PatrollerStat)
    end)
    return
  end
  local ticket = Client.GetWebViewTicket(NetInterface)
  log(bWriteLog and "PatrollerModule:send_query_patroller_stat_info_req ticket = " .. tostring(ticket))
  local PatrollerHandler = require("client.network.Protocol.PatrollerHandler")
  PatrollerHandler.send_query_patroller_stat_info_req(ticket)
end
function PatrollerModule:on_query_patroller_stat_info_rsp(stat_info)
  if not stat_info then
    self.PatrollerStat = nil
    log(bWriteLog and "PatrollerModule:on_query_patroller_stat_info_rsp not stat_info")
  else
    log_tree("PatrollerModule:on_query_patroller_stat_info_rsp", stat_info)
    self.PatrollerStat = stat_info
  end
  EventSystem:postEvent(EVENTTYPE_PATROLLER, EVENTID_PATROLLER_STAT_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPatrollerModule = class(CModuleBase, nil, PatrollerModule)
return CPatrollerModule
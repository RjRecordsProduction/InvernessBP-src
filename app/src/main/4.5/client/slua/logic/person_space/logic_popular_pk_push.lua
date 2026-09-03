local logic_popular_pk_push = {}
function logic_popular_pk_push:DefineAndResetData()
  self.pushConfig1v1 = nil
  self.pushConfig4v4 = nil
  self.CONST_ROUND_ENDING_NOTIFY_HOURS = 12
end
function logic_popular_pk_push:OnLogOut()
  self:DefineAndResetData()
end
function logic_popular_pk_push:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:CheckRequestPushConfigData()
  end
end
function logic_popular_pk_push:CheckRequestPushConfigData()
  local singlePkEnrollTime = LobbySystem.roleData.psmatch_enroll_time or 0
  local teamPkEnrollTime = LobbySystem.roleData.psmatch_team_enroll_time or 0
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:CheckRequestPushConfigData, singlePkEnrollTime is " .. tostring(singlePkEnrollTime) .. "; teamPkEnrollTime is " .. tostring(teamPkEnrollTime))
  if singlePkEnrollTime <= 0 and teamPkEnrollTime <= 0 then
    return
  end
  self:AddTimerOnce(60, function()
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:CheckRequestPushConfigData send request")
    self:get_psmatch_system_push_info_req(0 < teamPkEnrollTime, 0 < singlePkEnrollTime)
  end)
end
function logic_popular_pk_push:UpdatePopularPkMsgWhenEnrolled()
  if not self.pushConfig1v1 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdatePopularPkMsgWhenEnrolled return, request pushConfig1v1")
    self:get_psmatch_system_push_info_req(false, true)
    return
  end
  self:UpdatePopularPkPushMsg()
end
function logic_popular_pk_push:UpdateTeamPkMsgWhenEnrolled()
  if not self.pushConfig4v4 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdateTeamPkMsgWhenEnrolled return, request pushConfig1v1")
    self:get_psmatch_system_push_info_req(true, false)
    return
  end
  self:UpdateTeamPkPushMsg()
end
function logic_popular_pk_push:get_psmatch_system_push_info_req(is_for_4v4, is_for_1v1)
  local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
  PopularityPKHandler.send_get_psmatch_system_push_info_req(is_for_4v4, is_for_1v1)
end
function logic_popular_pk_push:on_get_psmatch_system_push_info_rsp(push_cfg_4v4, push_cfg_1v1)
  if push_cfg_4v4 then
    self.pushConfig4v4 = push_cfg_4v4
    self:UpdateTeamPkPushMsg()
  end
  if push_cfg_1v1 then
    self.pushConfig1v1 = push_cfg_1v1
    self:UpdatePopularPkPushMsg()
  end
end
function logic_popular_pk_push:UpdatePopularPkPushMsg()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdatePopularPkPushMsg")
  if not self.pushConfig1v1 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdateTeamPkPushMsg return, no pushConfig1v1")
    return
  end
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  local startPushID = self.pushConfig1v1.start_push_id
  if startPushID and 0 < startPushID then
    LocalPushSystem:SetLocalPushByCfgID(startPushID)
  end
  local endPushID = self.pushConfig1v1.end_push_id
  if endPushID and 0 < endPushID then
    LocalPushSystem:SetLocalPushByCfgID(endPushID)
  end
end
function logic_popular_pk_push:GetPopularPkStartPushTime()
  local enrollTime = self:GetPopularPkEnrollTime()
  if not enrollTime or enrollTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkStartPushTime return false, no enrollTime")
    return
  end
  if not self.pushConfig1v1 or not self.pushConfig1v1.round_list then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkStartPushTime return false, no roundList")
    return
  end
  local roundList = self.pushConfig1v1.round_list
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkStartPushTime, curTime is:" .. tostring(curTime) .. " enrollTime is " .. tostring(enrollTime))
  for _, data in ipairs(roundList) do
    if enrollTime < data.start_matching_ts and curTime < data.start_duel_ts then
      log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkStartPushTime, notifyTime is:" .. tostring(data.start_duel_ts))
      return data.start_duel_ts
    end
  end
  return nil
end
function logic_popular_pk_push:GetPopularPkEndingPushTime()
  local enrollTime = self:GetPopularPkEnrollTime()
  if not enrollTime or enrollTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkEndingPushTime return false, no enrollTime")
    return
  end
  if not self.pushConfig1v1 or not self.pushConfig1v1.round_list then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkEndingPushTime return false, no roundList")
    return
  end
  local roundList = self.pushConfig1v1.round_list
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkEndingPushTime, curTime is:" .. tostring(curTime) .. " enrollTime is " .. tostring(enrollTime))
  local oneHourTime = 3600
  local prePushTime = oneHourTime * self.CONST_ROUND_ENDING_NOTIFY_HOURS
  for _, data in ipairs(roundList) do
    local endPkTime = data.end_duel_ts or 0
    if 0 < endPkTime and enrollTime < data.start_matching_ts and curTime < endPkTime - prePushTime then
      local notifyTime = endPkTime - prePushTime
      log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkEndingPushTime, notifyTime is:" .. tostring(notifyTime))
      return notifyTime
    end
  end
  return nil
end
function logic_popular_pk_push:GetPopularPkEnrollTime()
  local enrollTime = LobbySystem.roleData.psmatch_enroll_time or 0
  local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
  if 0 < logic_popular_gift_pk.enroll_time then
    enrollTime = logic_popular_gift_pk.enroll_time
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetPopularPkEnrollTime, enrollTime is:" .. tostring(enrollTime))
  end
  return enrollTime
end
function logic_popular_pk_push:UpdateTeamPkPushMsg()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdateTeamPkPushMsg")
  if not self.pushConfig4v4 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:UpdateTeamPkPushMsg return, no pushConfig4v4")
    return
  end
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  local startPushID = self.pushConfig4v4.start_push_id
  if startPushID and 0 < startPushID then
    LocalPushSystem:SetLocalPushByCfgID(startPushID)
  end
  local endPushID = self.pushConfig4v4.end_push_id
  if endPushID and 0 < endPushID then
    LocalPushSystem:SetLocalPushByCfgID(endPushID)
  end
end
function logic_popular_pk_push:GetTeamPkStartPushTime()
  local enrollTime = self:GetTeamPkEnrollTime()
  if not enrollTime or enrollTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkStartPushTime return false, no enrollTime")
    return
  end
  if not self.pushConfig4v4 or not self.pushConfig4v4.round_list then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkStartPushTime return false, no roundList")
    return
  end
  local roundList = self.pushConfig4v4.round_list
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkStartPushTime, curTime is:" .. tostring(curTime) .. " enrollTime is " .. tostring(enrollTime))
  for _, data in ipairs(roundList) do
    if enrollTime < data.start_matching_ts and curTime < data.start_duel_ts then
      log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkStartPushTime, notifyTime is:" .. tostring(data.start_duel_ts))
      return data.start_duel_ts
    end
  end
  return nil
end
function logic_popular_pk_push:GetTeamPkEndingPushTime()
  local enrollTime = self:GetTeamPkEnrollTime()
  if not enrollTime or enrollTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkEndingPushTime return false, no enrollTime")
    return
  end
  if not self.pushConfig4v4 or not self.pushConfig4v4.round_list then
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkEndingPushTime return false, no roundList")
    return
  end
  local roundList = self.pushConfig4v4.round_list
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkEndingPushTime, curTime is:" .. tostring(curTime) .. " enrollTime is " .. tostring(enrollTime))
  local oneHourTime = 3600
  local prePushTime = oneHourTime * self.CONST_ROUND_ENDING_NOTIFY_HOURS
  for _, data in ipairs(roundList) do
    local endPkTime = data.end_duel_ts or 0
    if 0 < endPkTime and enrollTime < data.start_matching_ts and curTime < endPkTime - prePushTime then
      local notifyTime = endPkTime - prePushTime
      log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkEndingPushTime, notifyTime is:" .. tostring(notifyTime))
      return notifyTime
    end
  end
  return nil
end
function logic_popular_pk_push:GetTeamPkEnrollTime()
  local enrollTime = LobbySystem.roleData.psmatch_team_enroll_time or 0
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  local myTeamPKData = logic_popular_team_pk:GetMyTeamPkData()
  if myTeamPKData then
    enrollTime = myTeamPKData.enroll_time
    log(bWriteLog and "[v_wllwu] logic_popular_pk_push:GetTeamPkEnrollTime, enrollTime is:" .. tostring(enrollTime))
  end
  return enrollTime
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_pk_push = class(CModuleBase, nil, logic_popular_pk_push)
return Clogic_popular_pk_push
local logic_housekeeper_dialog_base = {}
function logic_housekeeper_dialog_base:ctor()
  self.memory = nil
end
function logic_housekeeper_dialog_base:GetNodeInfoByID(housekeeperId, nodeId)
  local sheetName = self:GetNodeSheetName(housekeeperId)
  return CDataTable.GetTableData(sheetName, nodeId)
end
function logic_housekeeper_dialog_base:GetNodeTextByID(housekeeperId, nodeId)
  local cfg = self:GetNodeInfoByID(housekeeperId, nodeId)
  if not cfg then
    return ""
  end
  local dataList = self:GetDataList(cfg.TextParam, housekeeperId, nodeId)
  if dataList then
    local txt = LocUtil.LocalizeResFormatByStr(cfg.Text, table.unpack(dataList))
    return txt
  else
    return cfg.Text
  end
end
function logic_housekeeper_dialog_base:GetOptionListByID(housekeeperId, nodeId)
  local cfg = self:GetNodeInfoByID(housekeeperId, nodeId)
  if not cfg then
    log_error(string.format("logic_housekeeper_dialog_base:GetOptionListByID cannot get config by node = %s, housekeeperId = %s", nodeId, housekeeperId))
    return nil
  end
  local nodeList = {}
  for i = 1, self.C_MAX_NODE_NUM do
    local SelectText = string.format("SelectText%s", i)
    if cfg[SelectText] and cfg[SelectText] ~= "" then
      local conditionStr = cfg[string.format("SelectCondition%s", i)]
      local conditionNode = self:JudgeCondition(housekeeperId, conditionStr)
      if conditionNode then
        conditionNode.SelectID = cfg[string.format("SelectID%s", i)]
        table.insert(nodeList, conditionNode)
      else
        local nextString = cfg[string.format("SelectNext%s", i)]
        local node = {
          Text = cfg[string.format("SelectText%s", i)],
          Next = nextString,
          SelectID = cfg[string.format("SelectID%s", i)]
        }
        local nextNodeCfg = self:GetNodeInfoByID(housekeeperId, node.SelectID)
        if nextNodeCfg and nextNodeCfg.IsKeyColor and nextNodeCfg.IsKeyColor == 1 then
          node.IsKeyColor = true
        end
        table.insert(nodeList, node)
      end
    end
  end
  return nodeList
end
function logic_housekeeper_dialog_base:ParseJumpParam(selectNext)
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsGameJumpUrl(selectNext) then
    return PlanPH_Housekeeper_Config.JumpType.GameUrl, selectNext
  else
    local StringUtil = require("common.string_util")
    local nexts = StringUtil.Split(selectNext, "|")
    local dialogId = 0
    if #nexts == 1 then
      dialogId = tonumber(selectNext)
    else
      local randomIdx = math.random(1, #nexts)
      log(bWriteLog and "logic_housekeeper_dialog_base:ParseJumpParam randomIdx:" .. randomIdx)
      dialogId = tonumber(nexts[randomIdx])
    end
    return PlanPH_Housekeeper_Config.JumpType.DialogID, dialogId
  end
end
function logic_housekeeper_dialog_base:SetMemory(memory)
  if not memory then
    log(bWriteLog and "logic_housekeeper_dialog_base:SetMemory data error")
    return
  end
  log_tree(bWriteLog and "logic_housekeeper_dialog_base:SetMemory memory:", memory)
  self.  self:TryRequestProfile()
end
function logic_housekeeper_dialog_base:HaveMemory()
  return self.memory ~= nil
end
function logic_housekeeper_dialog_base:GetMemory()
  return self.memory
end
function logic_housekeeper_dialog_base:send_manor_butler_dialogue_report_req(butler_id, id, in_lobby)
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_dialogue_report_req(butler_id, id, in_lobby)
end
function logic_housekeeper_dialog_base:on_manor_butler_dialogue_report_rsp()
end
function logic_housekeeper_dialog_base:send_manor_butler_save_dialogue_req(butler_id, in_lobby, bin_info)
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_save_dialogue_req(butler_id, in_lobby, bin_info)
end
function logic_housekeeper_dialog_base:on_manor_butler_save_dialogue_rsp()
end
function logic_housekeeper_dialog_base:send_manor_butler_init_action_id_req(in_lobby)
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_init_action_id_req(in_lobby)
end
function logic_housekeeper_dialog_base:on_manor_butler_init_action_id_rsp(butler_id, act_id, act_type)
end
function logic_housekeeper_dialog_base:send_manor_butler_memmory_req(in_lobby)
  local PHomeHousekeeperHandler = require("client.network.Protocol.PHomeHousekeeperHandler")
  PHomeHousekeeperHandler.send_manor_butler_memmory_req(in_lobby)
end
function logic_housekeeper_dialog_base:on_manor_butler_memmory_rsp(context)
  self:SetMemory(context)
end
function logic_housekeeper_dialog_base:JudgeCondition(housekeeperId, conditionStr)
  if not conditionStr or conditionStr == "" then
    log(bWriteLog and "logic_housekeeper_dialog_base:JudgeCondition no conditionStr")
    return nil
  end
  local StringUtil = require("common.string_util")
  local conditions = StringUtil.Split(conditionStr, "|")
  local sheetName = self:GetConditionSheetName(housekeeperId)
  for _, conditionId in ipairs(conditions) do
    local cfg = CDataTable.GetTableData(sheetName, tonumber(conditionId))
    if not cfg then
      log_error(string.format("logic_housekeeper_dialog_base:JudgeCondition cannot get config by housekeeperId = %s, conditionStr = %s", housekeeperId, conditionStr))
      return nil
    end
    local funcName = cfg.Type
    if self[funcName] and self[funcName](self, cfg.Param) then
      log(bWriteLog and string.format("logic_housekeeper_dialog_base:JudgeCondition get function by type = %s", funcName))
      return {
        Text = cfg.Text,
        Next = cfg.Next
      }
    end
    if self:ConditionJudge(cfg.Type, cfg.Param, housekeeperId) then
      return {
        Text = cfg.Text,
        Next = cfg.Next
      }
    end
  end
  return nil
end
function logic_housekeeper_dialog_base:ConditionJudge(conType, conParam, housekeeperId)
  log(bWriteLog and string.format("logic_housekeeper_dialog_base:ConditionJudge %s %s %s ", conType, conParam, housekeeperId))
  local dataList = self:GetDataList(conType, housekeeperId)
  if not dataList or not dataList[1] then
    log_error(string.format("logic_housekeeper_dialog_base:JudgeCondition cannot get memory Param = %s", conType))
    return false
  end
  local StringUtil = require("common.string_util")
  local gaps = StringUtil.Split(conParam, "|")
  local minNum = tonumber(gaps[1])
  local maxNum = tonumber(gaps[2])
  local memoryNum = tonumber(dataList[1]) or 0
  if not minNum or not maxNum then
    log_error(string.format("logic_housekeeper_dialog_base:JudgeCondition error config type = %s, param = %s", conType, conParam))
    return false
  end
  log(bWriteLog and string.format("logic_housekeeper_dialog_base:ConditionJudge memoryNum %s ", memoryNum))
  if minNum <= memoryNum and maxNum >= memoryNum then
    return true
  else
    return false
  end
end
function logic_housekeeper_dialog_base:GetDataList(textParam, hkpId, nodeId)
  if textParam == "" then
    return nil
  end
  if not self.memory then
    log(bWriteLog and "logic_housekeeper_dialog_base:GetDataList no memory")
    return nil
  end
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  local StringUtil = require("common.string_util")
  local paramList = StringUtil.Split(textParam, "|")
  local dataList = {}
  for _, param in ipairs(paramList) do
    if self.memory[param] then
      log(bWriteLog and "logic_housekeeper_dialog_base:GetDataList use memory")
      local value = self.memory[param]
      local realValue = self:GetMemoryRealValue(param, value, hkpId)
      if (param == "comment_friend_uidnum" or param == "comment_friend_num") and realValue == 0 then
        log(bWriteLog and "logic_housekeeper_dialog_base:GetDataList memory error")
        local reason_str = tostring(nodeId) .. "_" .. param .. "_" .. tostring(realValue)
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.HouseKeeper_Memory_Param_Error, nil, reason_str)
      end
      table.insert(dataList, realValue)
    elseif param == PlanPH_Housekeeper_Config.MemoryParam.player_name then
      local name = DataMgr.roleData.nickName
      table.insert(dataList, name)
    elseif param == PlanPH_Housekeeper_Config.MemoryParam.house_owner_name then
      local name = self:GetHouseOwnerName()
      table.insert(dataList, name)
    elseif param == PlanPH_Housekeeper_Config.MemoryParam.housekeeper_name then
      local name = self:GetHousekeeperName()
      table.insert(dataList, name)
    else
      log(bWriteLog and "logic_housekeeper_dialog_base:GetDataList invalid param " .. tostring(param))
      table.insert(dataList, param)
    end
  end
  return dataList
end
function logic_housekeeper_dialog_base:GetMemoryRealValue(paramType, paramValue, hkpId)
  log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue paramType:" .. tostring(paramType) .. ", paramValue:" .. tostring(paramValue))
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  if paramType == PlanPH_Housekeeper_Config.MemoryParam.recent_title_id then
    local aliasConfig = CDataTable.GetTableData("AliasCfg", paramValue)
    if aliasConfig then
      if string.find(aliasConfig.AliasName, "{0}") then
        return ""
      else
        return aliasConfig.AliasName
      end
    else
      log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue no aliasConfig")
    end
  elseif paramType == PlanPH_Housekeeper_Config.MemoryParam.recent_achievement_id then
    local achCfg = CDataTable.GetTableData("AchievementCfg", paramValue)
    if achCfg then
      return achCfg.Name
    else
      log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue no achCfg")
    end
  elseif paramType == PlanPH_Housekeeper_Config.MemoryParam.gift_highest_gift_id then
    local giftInfo = CDataTable.GetTableData("PopularityGift", paramValue)
    if giftInfo then
      return giftInfo.ItemName
    else
      log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue no giftInfo")
    end
  elseif paramType == PlanPH_Housekeeper_Config.MemoryParam.visitor_intimacy_uid or paramType == PlanPH_Housekeeper_Config.MemoryParam.comment_intimacy_uid or paramType == PlanPH_Housekeeper_Config.MemoryParam.gift_highest_uid then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(paramValue)
    if profile then
      return profile.nickName
    else
      log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue no profile")
    end
  elseif PlanPH_Housekeeper_Config.MemoryParam.time_stamp_values[paramType] then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    return math.ceil((now - paramValue) / 86400)
  elseif paramType == PlanPH_Housekeeper_Config.MemoryParam.first_gift_num or paramType == PlanPH_Housekeeper_Config.MemoryParam.second_gift_num or paramType == PlanPH_Housekeeper_Config.MemoryParam.third_gift_num then
    local logic_home_housekeeper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_housekeeper)
    local hkpInfo = logic_home_housekeeper and logic_home_housekeeper:GetHousekeeperInfo(hkpId)
    local giftId = PlanPH_Housekeeper_Config.GiftMap[paramType]
    if giftId and hkpInfo and hkpInfo.send_gift_items and hkpInfo.send_gift_items[giftId] then
      return hkpInfo.send_gift_items[giftId]
    end
  end
  log(bWriteLog and "logic_housekeeper_dialog_base:GetMemoryRealValue default")
  return paramValue
end
function logic_housekeeper_dialog_base:TryRequestProfile()
  log(bWriteLog and "logic_housekeeper_dialog_base:TryRequestProfile")
  if self.memory == nil then
    log(bWriteLog and "logic_housekeeper_dialog_base:TryRequestProfile no memory")
    return
  end
  local profile_req_list = {}
  local PlanPH_Housekeeper_Config = require("client.slua.logic.home.housekeeper.PlanPH_Housekeeper_Config")
  for _, uidKey in ipairs(PlanPH_Housekeeper_Config.MemoryParamUidKeys) do
    local uid = self.memory[uidKey]
    if uid and 0 < uid then
      table.insert(profile_req_list, uid)
    end
  end
  if next(profile_req_list) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(profile_req_list, nil, Enum_PROFILE_REPORT_CFG.PLANPH_HOUSEKEEPER_CHAT)
  else
    log(bWriteLog and "logic_housekeeper_dialog_base:TryRequestProfile no req")
  end
end
function logic_housekeeper_dialog_base:GetNodeSheetName(housekeeperId)
end
function logic_housekeeper_dialog_base:GetConditionSheetName(housekeeperId)
end
function logic_housekeeper_dialog_base:GetHouseOwnerName()
end
function logic_housekeeper_dialog_base:GetHousekeeperName()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_housekeeper_dialog_base)
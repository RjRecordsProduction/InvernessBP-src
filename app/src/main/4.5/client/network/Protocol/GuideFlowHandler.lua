local NetManager = require("client.network.comm.NetManager")
local GuideFlowHandler = {
  all_tree = nil,
  bUseServerCfg = true,
  GuideFlowTreeAttrTb = nil,
  GuideFlowEventTb = nil,
  GuideFlowActionTb = nil,
  GuideFlowTreeTb = nil,
  bGetRspAllTree = false,
  bGetRspCfg = false,
  bGetRspBlockRule = false,
  MissionClickState = {}
}
function GuideFlowHandler.send_guide_flow_get_all_tree_req()
  NetManager.SendPkg(1698240935)
end
function GuideFlowHandler.on_guide_flow_get_all_tree_rsp(ok, all_tree)
  log_tree("GuideFlowHandler.on_guide_flow_get_all_tree_rsp ok = ", ok)
  log_tree("all_tree = ", all_tree)
  if ok ~= 0 then
    return
  end
  GuideFlowHandler.bGetRspAllTree = true
  GuideFlowHandler.  GuideFlowHandler.CheckAndLoadAllTree()
end
function GuideFlowHandler.send_guide_flow_change_tree_req(tree_id, tree)
  log_tree("GuideFlowHandler.send_guide_flow_change_tree_req tree_id = ", tree_id)
  log_tree("GuideFlowHandler.send_guide_flow_change_tree_req tree = ", tree)
  NetManager.SendPkg(1624932711, tree_id, tree)
end
function GuideFlowHandler.on_guide_flow_change_tree_rsp(ok, tree_id, tree)
  log(bWriteLog and "GuideFlowHandler.on_guide_flow_change_tree_rsp ok = " .. ok)
  log(bWriteLog and "GuideFlowHandler.on_guide_flow_change_tree_rsp tree_id = " .. tree_id)
  log_tree("tree = ", tree)
end
function GuideFlowHandler.send_report_grow_up_tlog(tlog_table)
  NetManager.SendPkg(916195697, tlog_table)
end
function GuideFlowHandler.send_get_guide_flow_cfg_req(last_timestamp)
  log(bWriteLog and "GuideFlowHandler.send_get_guide_flow_cfg_req last_timestamp = " .. tostring(last_timestamp))
  NetManager.SendPkg(1366368999, last_timestamp)
end
function GuideFlowHandler.on_get_guide_flow_cfg_rsp(ok, GuideFlowTreeAttrTb, GuideFlowEventTb, GuideFlowConditionTb, GuideFlowActionTb, GuideFlowTreeTb, GuideFlowModeAliveTb, DefaultGuideFlowModeAliveTb, file_timestamp)
  log(bWriteLog and "GuideFlowHandler.on_get_guide_flow_cfg_rsp ok = " .. ok .. ", file_timestamp = " .. tostring(file_timestamp))
  if ok ~= 0 then
    return
  end
  local logic_guide_flow_config = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_guide_flow_config)
  logic_guide_flow_config:proc_get_guide_flow_cfg_req(GuideFlowEventTb, GuideFlowConditionTb, GuideFlowActionTb, GuideFlowModeAliveTb, DefaultGuideFlowModeAliveTb, file_timestamp)
  GuideFlowHandler.bGetRspCfg = true
  if GuideFlowHandler.bUseServerCfg then
    GuideFlowHandler.    if logic_guide_flow_config.configFileInfo then
      GuideFlowHandler.GuideFlowEventTb = logic_guide_flow_config.configFileInfo.GuideFlowEventTb
      GuideFlowHandler.GuideFlowConditionTb = logic_guide_flow_config.configFileInfo.GuideFlowConditionTb
      GuideFlowHandler.GuideFlowActionTb = logic_guide_flow_config.configFileInfo.GuideFlowActionTb
      GuideFlowHandler.GuideFlowModeAliveTb = logic_guide_flow_config.configFileInfo.GuideFlowModeAliveTb
      GuideFlowHandler.DefaultGuideFlowModeAliveTb = logic_guide_flow_config.configFileInfo.DefaultGuideFlowModeAliveTb
    end
    GuideFlowHandler.  end
  GuideFlowHandler.CheckAndLoadAllTree()
end
function GuideFlowHandler.send_get_guide_flow_block_rule_req()
  log(bWriteLog and "GuideFlowHandler.send_get_guide_flow_block_rule_req")
  NetManager.SendPkg(2057671559)
end
function GuideFlowHandler.on_get_guide_flow_block_rule_rsp(ok, guide_flow_block_rule)
  log(bWriteLog and "GuideFlowHandler.on_get_guide_flow_block_rule_rsp ok = " .. ok)
  log_tree("guide_flow_block_rule = ", guide_flow_block_rule)
  if ok ~= 0 then
    return
  end
  GuideFlowHandler.bGetRspBlockRule = true
  GuideFlowHandler.  local GuideFlowNodeBlockRule = require("client.slua.logic.GuideFlow.GuideFlowNodeBlockRule")
  GuideFlowNodeBlockRule.OnRecvServerData(guide_flow_block_rule)
  GuideFlowHandler.CheckAndLoadAllTree()
end
function GuideFlowHandler.send_set_guide_flow_block_rule_req(node_id, node_table)
  log(bWriteLog and "GuideFlowHandler.send_set_guide_flow_block_rule_req node_id = " .. node_id)
  log_tree("node_table = ", node_table)
  NetManager.SendPkg(320985399, node_id, node_table)
end
function GuideFlowHandler.on_set_guide_flow_block_rule_rsp(ok, node_id, node_table)
  log(bWriteLog and "GuideFlowHandler.on_set_guide_flow_block_rule_rsp ok = " .. ok)
  log(bWriteLog and "node_id = " .. node_id)
  log_tree("node_table = ", node_table)
  if ok ~= 0 then
    return
  end
end
function GuideFlowHandler.CheckAndLoadAllTree()
  if GuideFlowHandler.bGetRspAllTree and GuideFlowHandler.bGetRspCfg and GuideFlowHandler.bGetRspBlockRule then
    local logic_guide_flow = require("client.slua.logic.GuideFlow.logic_guide_flow")
    logic_guide_flow.OnRecvAllTree(GuideFlowHandler.all_tree or {})
  else
    log(bWriteLog and "GuideFlowHandler.CheckAndLoadAllTree wait")
  end
end
function GuideFlowHandler.on_get_all_care_task_date_rsp(data)
  local GuideFlowCareData = require("client.slua.logic.GuideFlow.GuideFlowCareData")
  GuideFlowCareData.SetFullData(data)
end
function GuideFlowHandler.send_set_click_task_req(taskType)
  if GuideFlowHandler.MissionClickState and not GuideFlowHandler.MissionClickState[taskType] then
    log(bWriteLog and "[GuideFlowHandler] send click : " .. tostring(taskType))
    NetManager.SendPkg(292657148, taskType)
    GuideFlowHandler.MissionClickState[taskType] = true
  end
end
function GuideFlowHandler.send_get_care_task_date_req(careType)
  NetManager.SendPkg(848139239, careType)
end
function GuideFlowHandler.on_get_care_task_date_rsp(careType, data)
  local GuideFlowCareData = require("client.slua.logic.GuideFlow.GuideFlowCareData")
  GuideFlowCareData.UpdateCareTypeData(careType, data)
end
function GuideFlowHandler.send_update_node_count_req(node_id)
  log(bWriteLog and string.format("martinhtma GuideFlowHandler.send_update_node_count_req node_id: %s", node_id))
  NetManager.SendPkg(618341891, node_id)
end
function GuideFlowHandler.on_update_node_count_rsp(growup_node_count_data)
  local GuideFlowNodeCounter = require("client.slua.logic.GuideFlow.GuideFlowNodeCounter")
  GuideFlowNodeCounter.UpdateNodeCounter(growup_node_count_data)
end
function GuideFlowHandler.send_get_node_count_req(node_id)
  NetManager.SendPkg(774982247, node_id)
end
function GuideFlowHandler.on_get_node_count_rsp(growup_node_count_data, nodeId)
  local GuideFlowNodeCounter = require("client.slua.logic.GuideFlow.GuideFlowNodeCounter")
  if nodeId == nil then
    GuideFlowNodeCounter.nodeCounter = {}
  end
  GuideFlowNodeCounter.UpdateNodeCounter(growup_node_count_data)
end
function GuideFlowHandler.send_get_bin_guide_flow_cfg_req()
  log(bWriteLog and "GuideFlowHandler.send_get_bin_guide_flow_cfg_req")
  NetManager.SendPkg(123456789)
end
function GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp(ok, binGuideFlowTreeAttrTb, binGuideFlowEventTb, binGuideFlowConditionTb, binGuideFlowActionTb, binGuideFlowTreeTb)
  if ok ~= 0 then
    return
  end
  local GuideFlowTreeAttrTb = slua.LuaArchiverDecode(LuaStateWrapper, binGuideFlowTreeAttrTb) or {}
  local GuideFlowEventTb = slua.LuaArchiverDecode(LuaStateWrapper, binGuideFlowEventTb) or {}
  local GuideFlowConditionTb = slua.LuaArchiverDecode(LuaStateWrapper, binGuideFlowConditionTb) or {}
  local GuideFlowActionTb = slua.LuaArchiverDecode(LuaStateWrapper, binGuideFlowActionTb) or {}
  local GuideFlowTreeTb = slua.LuaArchiverDecode(LuaStateWrapper, binGuideFlowTreeTb) or {}
  log_tree("GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp GuideFlowTreeAttrTb =", GuideFlowTreeAttrTb)
  log_tree("GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp GuideFlowEventTb =", GuideFlowEventTb)
  log_tree("GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp GuideFlowConditionTb =", GuideFlowConditionTb)
  log_tree("GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp GuideFlowActionTb =", GuideFlowActionTb)
  log_tree("GuideFlowHandler.on_get_bin_guide_flow_cfg_rsp GuideFlowTreeTb =", GuideFlowTreeTb)
  GuideFlowHandler.bGetRspCfg = true
  if GuideFlowHandler.bUseServerCfg then
    GuideFlowHandler.    GuideFlowHandler.    GuideFlowHandler.    GuideFlowHandler.    GuideFlowHandler.  end
  GuideFlowHandler.CheckAndLoadAllTree()
end
return GuideFlowHandler
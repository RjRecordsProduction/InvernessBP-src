local logic_guide_flow_config = {}
function logic_guide_flow_config:OnInitialize()
  log(bWriteLog and "logic_guide_flow_config:OnInitialize")
  self.configFileInfo = nil
end
function logic_guide_flow_config:send_get_guide_flow_cfg_req()
  log(bWriteLog and "logic_guide_flow_config:send_get_guide_flow_cfg_req")
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  if self.configFileInfo == nil then
    if self:load_config_file() then
      log(bWriteLog and "logic_guide_flow_config:send_get_guide_flow_cfg_req 1")
      GuideFlowHandler.send_get_guide_flow_cfg_req(self.configFileInfo.file_timestamp)
    else
      log(bWriteLog and "logic_guide_flow_config:send_get_guide_flow_cfg_req 2")
      GuideFlowHandler.send_get_guide_flow_cfg_req(nil)
    end
  else
    log(bWriteLog and "logic_guide_flow_config:send_get_guide_flow_cfg_req 3")
    GuideFlowHandler.send_get_guide_flow_cfg_req(self.configFileInfo.file_timestamp)
  end
end
function logic_guide_flow_config:proc_get_guide_flow_cfg_req(GuideFlowEventTb, GuideFlowConditionTb, GuideFlowActionTb, GuideFlowModeAliveTb, DefaultGuideFlowModeAliveTb, file_timestamp)
  log(bWriteLog and "logic_guide_flow_config:proc_get_guide_flow_cfg_req")
  self:save_config_file(GuideFlowEventTb, GuideFlowConditionTb, GuideFlowActionTb, GuideFlowModeAliveTb, DefaultGuideFlowModeAliveTb, file_timestamp)
end
function logic_guide_flow_config:load_config_file()
  log(bWriteLog and "logic_guide_flow_config:load_config_file")
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tb = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eGuideFlowConfig)
  if tb == nil then
    return false
  end
  self.configFileInfo = tb
  return true
end
function logic_guide_flow_config:save_config_file(GuideFlowEventTb, GuideFlowConditionTb, GuideFlowActionTb, GuideFlowModeAliveTb, DefaultGuideFlowModeAliveTb, file_timestamp)
  log(bWriteLog and "logic_guide_flow_config:save_config_file")
  if GuideFlowEventTb == nil then
    log(bWriteLog and "logic_guide_flow_config:save_config_file no save")
    return
  end
  if self.configFileInfo == nil then
    self.configFileInfo = {}
  end
  self.configFileInfo.  self.configFileInfo.  self.configFileInfo.  self.configFileInfo.  self.configFileInfo.  self.configFileInfo.  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerprefs.SaveTableToFile_N(self.configFileInfo, playerprefs.ePlayerPrefsType.eGuideFlowConfig)
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_guide_flow_config)
return CModuleTemplate
local LogicSmartAssistantCfg = {}
function LogicSmartAssistantCfg:send_assistant_get_cfg_req()
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  return SmartAssistantHandler.send_assistant_get_cfg_req()
end
function LogicSmartAssistantCfg:on_assistant_get_cfg_rsp(main_page_cfg, extend_page_cfgs, reward_switch_cfg, club_page_cfgs)
  self.  self.  self.  local textList = {}
  if club_page_cfgs then
    for i, v in ipairs(club_page_cfgs) do
      if v.is_open == 1 then
      elseif v.is_open == 2 then
        table.insert(textList, v.pic_url)
      end
    end
  end
  self.extend_page_text_list = textList
  EventSystem:postEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SMARTASSISTANT_CFG_RSP)
end
function LogicSmartAssistantCfg:GetMainPageCfg()
  return self.main_page_cfg
end
function LogicSmartAssistantCfg:GetExtendPageCfgs()
  return self.extend_page_cfgs
end
function LogicSmartAssistantCfg:GetExtendPageTextList()
  return self.extend_page_text_list
end
function LogicSmartAssistantCfg:GetRewardSwitchCfg()
  return self.reward_switch_cfg
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSmartAssistantCfg = class(CModuleBase, nil, LogicSmartAssistantCfg)
return CLogicSmartAssistantCfg
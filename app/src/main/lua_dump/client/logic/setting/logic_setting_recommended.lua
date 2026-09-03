local logic_setting_recommended = {}
local switchList
function logic_setting_recommended:OnInitialize()
  logic_setting_recommended.__super.OnInitialize(self)
  switchList = {}
end
function logic_setting_recommended:UpdateSwitchWithType(type, is_open)
  switchList[type] = is_open
end
function logic_setting_recommended:UpdateSwitchList(pSwitchList)
  switchList = pSwitchList
end
function logic_setting_recommended:GetSwitchByType(type)
  local switch = switchList[type]
  if switch ~= nil then
    return switch
  end
  return 1
end
function logic_setting_recommended:send_get_recommend_open_req()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_recommend_open_req()
end
function logic_setting_recommended:send_set_recommend_open_req(type, is_open)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_recommend_open_req(type, is_open)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_setting_recommended)
return CModuleTemplate
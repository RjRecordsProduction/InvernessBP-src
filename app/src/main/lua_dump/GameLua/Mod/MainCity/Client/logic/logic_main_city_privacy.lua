local logic_main_city_privacy = {}
function logic_main_city_privacy:GetUserSwitch(switch_idx)
  local mc_common_switch = LobbySystem.roleData.mc_common_switch
  if not mc_common_switch then
    printf("logic_main_city_privacy:GetUserSwitch mc_common_switch is nil")
    return false
  end
  local switch = mc_common_switch[switch_idx]
  if switch == nil then
    printf("logic_main_city_privacy:GetUserSwitch switch_idx:%s is nil", switch_idx)
    return false
  end
  return switch
end
function logic_main_city_privacy:SetUserSwitch(switch_idx, switch)
  local MainCityHandler = require("client.network.Protocol.MainCityHandler")
  return MainCityHandler.send_mc_common_set_switch_req(switch_idx, switch)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_privacy = class(CModuleBase, nil, logic_main_city_privacy)
return Clogic_main_city_privacy
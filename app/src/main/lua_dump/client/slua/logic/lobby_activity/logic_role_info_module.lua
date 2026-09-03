local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
local logic_role_info_manager = {}
function logic_role_info_manager.OnPreSwitchGameStatus(_, next)
  log_tree("LadderOnPreSwitchGame", next)
  if next ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE)
  else
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, RoleInfoAliasSystem.OnGetItemDone)
  end
end
function logic_role_info_manager:RegistEvents()
  log(bWriteLog and "LadderOnLogin")
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE, RoleInfoAliasSystem.OnGetItemDone)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_role_info_manager = class(CModuleBase, nil, logic_role_info_manager)
return Clogic_role_info_manager
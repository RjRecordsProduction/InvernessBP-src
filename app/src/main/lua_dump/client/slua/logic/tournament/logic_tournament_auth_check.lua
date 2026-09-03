local logic_tournament_auth_check = {}
function logic_tournament_auth_check:RegistEvents()
  EventSystem:registEvent(EVENTTYPE_ALLIANCE, EVENTID_TOURNAMENT_AUTHENTICATION_CHECK_SUCCESS, self.OnEnterMatchOrRoomByAuth, self)
end
function logic_tournament_auth_check:OnEnterMatchOrRoomByAuth()
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  TournamentsManager.OnEnterMatchOrRoomByAuth()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_tournament_auth_check = class(CModuleBase, nil, logic_tournament_auth_check)
return Clogic_tournament_auth_check
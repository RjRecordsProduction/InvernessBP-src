local logic_team_maincity = {}
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
function logic_team_maincity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.BackToLobby, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self.EnterMainCity, self)
end
function logic_team_maincity:BackToLobby()
  TeamUpNewSystem.SendInMainCity(false)
end
function logic_team_maincity:EnterMainCity()
  TeamUpNewSystem.SendInMainCity(true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_team_maincity = class(CModuleBase, nil, logic_team_maincity)
return Clogic_team_maincity
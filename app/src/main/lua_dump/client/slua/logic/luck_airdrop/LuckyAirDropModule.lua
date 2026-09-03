local LuckyAirDropModule = {}
function LuckyAirDropModule:DefineAndResetData()
end
function LuckyAirDropModule:OnPreSwitchGameStatus()
  local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
  if AirDropMesh.IsInit() then
    AirDropMesh.ClearStatusCache()
  end
end
function LuckyAirDropModule:OnPostSwitchGameStatus(preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    local AirDropMesh = require("client.slua.umg.LuckyAirDrop.ui_airdrop_mesh")
    AirDropMesh.ShowBox()
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLuckyAirDropModule = class(CModuleBase, nil, LuckyAirDropModule)
return CLuckyAirDropModule
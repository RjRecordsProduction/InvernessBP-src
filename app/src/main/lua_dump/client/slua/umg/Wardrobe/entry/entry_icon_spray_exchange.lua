local entry_icon_spray_exchange = {}
function entry_icon_spray_exchange:OnEntryButtonClick()
  self:PlayAudio(sound_config.click_v1)
  local LogicVehicleDecalExchange = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleDecalExchange)
  LogicVehicleDecalExchange:OpenDecalExchangeList()
  LogicVehicleDecalExchange:SetDecalGuideShowFlag()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECAL_EXCHANGE_CLEAR_TIPS)
end
local class = require("class")
local ui_EntryIconBase = require("client.slua.umg.Wardrobe.entry.entry_icon_base")
local Centry_icon_spray_exchange = class(ui_EntryIconBase, nil, entry_icon_spray_exchange)
return Centry_icon_spray_exchange
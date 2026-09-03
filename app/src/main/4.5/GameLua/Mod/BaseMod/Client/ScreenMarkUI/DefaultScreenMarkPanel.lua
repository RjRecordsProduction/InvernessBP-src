local DefaultScreenMarkPanel = {}
function DefaultScreenMarkPanel:ctor()
  print(bWriteLog and "DefaultScreenMarkPanel:ctor")
end
function DefaultScreenMarkPanel:RegistEvents()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.AddToPanel)
end
function DefaultScreenMarkPanel:OnClose()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.AddToPanel)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, DefaultScreenMarkPanel)
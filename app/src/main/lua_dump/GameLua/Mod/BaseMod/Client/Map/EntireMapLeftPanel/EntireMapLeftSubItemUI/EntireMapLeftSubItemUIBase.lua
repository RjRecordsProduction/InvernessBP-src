local EntireMapLeftSubItemUIBase = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function EntireMapLeftSubItemUIBase:ctor()
  self.TitleAndIcon = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig").TitleConfig
end
function EntireMapLeftSubItemUIBase:RegistEvents()
end
function EntireMapLeftSubItemUIBase:RefreshUI(subValue, index)
end
function EntireMapLeftSubItemUIBase:OnClose()
  EntireMapLeftSubItemUIBase.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, EntireMapLeftSubItemUIBase)
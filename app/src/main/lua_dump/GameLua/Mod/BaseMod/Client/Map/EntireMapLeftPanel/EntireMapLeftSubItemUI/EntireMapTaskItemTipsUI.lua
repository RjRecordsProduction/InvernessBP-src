local EntireMapTaskItemTipsUI = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function EntireMapTaskItemTipsUI:ctor()
  self.TitleAndIcon = GamePlayTools.GetCurrentConfig("EntireMapTaskConfig").TitleConfig
end
function EntireMapTaskItemTipsUI:RegistEvents()
end
function EntireMapTaskItemTipsUI:RefreshUI(subValue, index)
  self.UIRoot.TextBlock_Tips:SetText(LocUtil.GetLocalizeResStr(37180))
end
function EntireMapTaskItemTipsUI:OnClose()
  EntireMapTaskItemTipsUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapLeftSubItemUIBase")
return class(UIBase, nil, EntireMapTaskItemTipsUI)
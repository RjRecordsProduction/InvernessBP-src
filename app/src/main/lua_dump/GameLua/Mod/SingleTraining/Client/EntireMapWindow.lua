local EntireMapWindow = {}
function EntireMapWindow:OnPostInitialize()
  EntireMapWindow.__super.OnPostInitialize(self)
  if self.UIRoot.CanvasPanel_AutoLock then
    self.UIRoot.CanvasPanel_AutoLock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local ui_base = require("GameLua.Mod.BaseMod.Client.Map.MapWindow.EntireMapWindow")
local CEntireMapWindow = class(ui_base, nil, EntireMapWindow)
return CEntireMapWindow
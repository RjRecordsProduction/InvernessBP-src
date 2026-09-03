local MicrophoneGuideOverride = {}
function MicrophoneGuideOverride:AdjustTextPosition()
  self.Image_Arrow:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.Overlay_Tips:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:AddGameTimer(0, false, function()
    if not slua.isValid(self.Overlay_Tips) or not slua.isValid(self.Image_Arrow) then
      return
    end
    local UIUtil = require("client.common.ui_util")
    UIUtil.SetAdaptiveLayout(self.Overlay_Tips, UEnums.EAdaptiveLayout.Outside, UEnums.EAdaptiveLayout.Middle, -20)
    local bExpandToRight = UIUtil.SetAdaptiveLayout(self.Image_Arrow, UEnums.EAdaptiveLayout.Outside, UEnums.EAdaptiveLayout.Middle, 10)
    self.Image_Arrow:SetRenderAngle(bExpandToRight and -90 or 90)
    self.Image_Arrow:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Overlay_Tips:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
end
function MicrophoneGuideOverride:OnDestroy()
  self:Dispose()
end
local class = require("class")
local UILuaUserWidget = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
return class(UILuaUserWidget, nil, MicrophoneGuideOverride)
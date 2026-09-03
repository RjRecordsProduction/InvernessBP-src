local EntireMapPlayerMarkItem = {}
local ESlateVisibility = import("ESlateVisibility")
function EntireMapPlayerMarkItem:ctor()
end
function EntireMapPlayerMarkItem:OnInitialize()
end
function EntireMapPlayerMarkItem:UpdateMark(bIsShow, MarkRenderTranslation, Opacity)
  if bIsShow then
    self.PlayerMarkInMap:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self:SetRenderTranslation(MarkRenderTranslation)
    self.Image_PlayerMarkInMap:SetOpacity(Opacity)
  else
    self.PlayerMarkInMap:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return true
end
function EntireMapPlayerMarkItem:SetMarkDist(Dist, bIsShow)
  if bIsShow then
    self.TextBlock_PlayerMarkDistance:SetText(FuncUtil.GetFormatText("{0}m", Dist))
    self.TextBlock_PlayerMarkDistance:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.TextBlock_PlayerMarkDistance:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  return Dist
end
function EntireMapPlayerMarkItem:SetMarkColor(Color)
  self.Image_PlayerMarkInMap:SetColorAndOpacity(Color)
  return Color
end
function EntireMapPlayerMarkItem:GetIconDisplayWidget()
  return nil
end
local class = require("class")
local UILuaUserWidget = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
return class(UILuaUserWidget, nil, EntireMapPlayerMarkItem)
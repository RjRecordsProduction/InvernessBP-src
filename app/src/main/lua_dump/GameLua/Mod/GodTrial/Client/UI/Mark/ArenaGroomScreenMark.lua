local FlameChariotScreenMark = {}
function FlameChariotScreenMark:Initialize()
  print(bWriteLog and "FlameChariotScreenMark:Initialize")
end
function FlameChariotScreenMark:OnDestroy()
  print(bWriteLog and "FlameChariotScreenMark:OnDestroy")
  self:Dispose()
end
function FlameChariotScreenMark:OnUpdateState(CustomInt, CustomFloat, CustomString)
  print(bWriteLog and "FlameChariotScreenMark:OnUpdateState CustomInt:" .. tostring(CustomInt) .. " CustomFloat:" .. tostring(CustomFloat) .. " CustomString:" .. tostring(CustomString))
  if CustomInt ~= 1 then
    if self.CanvasPanel_0 then
      self.CanvasPanel_0:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  elseif self.CanvasPanel_0 then
    self.CanvasPanel_0:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local CommonActorScreenMarkUI = require("GameLua.Mod.BaseMod.Client.ScreenMarkUI.CommonActorScreenMarkUI")
return class(CommonActorScreenMarkUI, nil, FlameChariotScreenMark)
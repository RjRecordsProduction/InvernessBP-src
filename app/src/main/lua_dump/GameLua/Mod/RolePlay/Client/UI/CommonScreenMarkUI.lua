local CommonScreenMarkUI = {}
local AnimLoopTime = 3
function CommonScreenMarkUI:OnDestroy()
  self:Dispose()
end
function CommonScreenMarkUI:SwitchIfOutOfScreen(bIsOutScreen)
  if bIsOutScreen then
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CommonScreenMarkUI:OnActorBindUI(uActor)
  self:ShowAnim()
end
function CommonScreenMarkUI:OnLocationBindUI(Loc)
  self:ShowAnim()
end
function CommonScreenMarkUI:ShowAnim()
  if self.Anim_Enter then
    self:PlayUserWidgetAnimation(self.Anim_Enter, 0, 1, 0, 1)
    if self.Anim_Loop then
      self.Anim_Enter.OnAnimationFinished:Add(function()
        self:PlayUserWidgetAnimation(self.Anim_Loop, 0, AnimLoopTime, 0, 1)
      end)
    end
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, CommonScreenMarkUI)
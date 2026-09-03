local ReviveTowerScreenMarkUI = {}
function ReviveTowerScreenMarkUI:Initialize()
  print(bWriteLog and "ReviveTowerScreenMarkUI:Initialize")
  self.MinDistance = 2
  self.MaxDistance = 800
  self:AddCommonEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_SHOW_REVIVE_TOWER_ANIM, self.ShowAnims, self)
end
function ReviveTowerScreenMarkUI:OnDestroy()
  print(bWriteLog and "ReviveTowerScreenMarkUI:OnDestroy")
  self:Dispose()
end
function ReviveTowerScreenMarkUI:SwitchIfOutOfScreen(bIsOutScreen)
  self.  if bIsOutScreen and (self.LastShow or self.LastShow == nil) then
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ReviveTowerScreenMarkUI:OnUpdateDistance(distance)
  if self:CheckDisatanceShouldHide(distance) and (self.LastShow or self.LastShow == nil) then
    self.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.LastShow = false
  elseif not self:CheckDisatanceShouldHide(distance) and not self.LastShow then
    self.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.bIsOutScreen then
      self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Image_Arrow:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.LastShow = true
  end
end
function ReviveTowerScreenMarkUI:CheckDisatanceShouldHide(distance)
  return distance < self.MinDistance or distance > self.MaxDistance
end
function ReviveTowerScreenMarkUI:OnLocationBindUI(Loc)
  if Loc == nil then
    return
  end
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.TextBlock_Revive
  end
  print(bWriteLog and "ReviveTowerScreenMarkUI:OnLocationBindUI")
  self.Slot:SetSize(FVector2D(30, 30))
  self.LastShow = nil
  self.bIsUpdateDistanceToLua = true
end
function ReviveTowerScreenMarkUI:ShowAnims()
  self:PlayUserWidgetAnimation(self.Anim_Loop, 0, 1, 0, 1)
end
function ReviveTowerScreenMarkUI:OnLocationUnbindUI(Loc)
  self.bIsUpdateDistanceToLua = false
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, ReviveTowerScreenMarkUI)
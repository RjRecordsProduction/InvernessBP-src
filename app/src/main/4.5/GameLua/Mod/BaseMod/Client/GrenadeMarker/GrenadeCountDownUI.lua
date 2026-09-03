local GrenadeCountDownUI = {UpdateInterval = 0.1}
function GrenadeCountDownUI:Initialize()
end
function GrenadeCountDownUI:OnDestroy()
  print(bWriteLog and "GrenadeCountDownUI:OnDestroy")
  self:Dispose()
end
function GrenadeCountDownUI:OnActorBindUI(BindActor)
  print(bWriteLog and "GrenadeCountDownUI:OnActorBindUI")
  if not slua.isValid(BindActor) then
    self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
  self:UpdateCountDown()
  self.UpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
    self:UpdateCountDown()
  end)
  self:SetCachedActor(BindActor, "")
end
function GrenadeCountDownUI:OnActorUnbindUI()
  print(bWriteLog and "GrenadeCountDownUI:OnActorUnBindUI")
  self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
end
function GrenadeCountDownUI:UpdateCountDown()
  self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not (slua.isValid(self.SaveActor) and self.SaveActor.EffectDelay) or not self.SaveActor.GetGrenadeRemainingTime then
    print(bWriteLog and "GrenadeCountDownUI:UpdateCountDown-1 SaveActor", self.SaveActor)
    return
  end
  local nLifeTime = self.SaveActor.EffectDelay
  local nRemainTime = self.SaveActor:GetGrenadeRemainingTime()
  if nRemainTime == 0 or nLifeTime == 0 then
    print(bWriteLog and "GrenadeCountDownUI:UpdateCountDown-2")
    return
  end
  self.TextBlock_Time:SetText(string.format("%.1f s", nRemainTime))
  self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local CDMaterial = self.Image_CD:GetDynamicMaterial()
  if slua.isValid(CDMaterial) then
    CDMaterial:SetScalarParameterValue("Mask_Percent", 1 - nRemainTime / nLifeTime)
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, GrenadeCountDownUI)
local FramePlatformScreenMark = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FPTrialConfig = require("GameLua.Mod.GodTrial.Gameplay.Config.FPTrialConfig")
function FramePlatformScreenMark:Initialize()
  print(bWriteLog and "FramePlatformScreenMark:Initialize")
  self.ImageProcessMaterial = nil
end
function FramePlatformScreenMark:OnDestroy()
  print(bWriteLog and "FramePlatformScreenMark:OnDestroy")
  self.TextBlock_Distance = nil
  self:Dispose()
end
function FramePlatformScreenMark:OnLocationBindUI(Loc)
  self.ImageProcessMaterial = self.Image_Pbr:GetDynamicMaterial()
end
function FramePlatformScreenMark:OnLocationUnbindUI(Loc)
end
function FramePlatformScreenMark:ShowDistance()
  if not self.TextBlock_Distance then
    self.TextBlock_Distance = self.TextBlock_Dis
  end
end
function FramePlatformScreenMark:HideDistance()
  if self.TextBlock_Distance then
    self.TextBlock_Distance = nil
  end
end
function FramePlatformScreenMark:OnUpdateState(CustomInt, CustomFloat, CustomString)
  local State, TimeLeft, TimeString = CustomInt, 0
  if 10000 <= CustomInt then
    State = CustomInt % 10000
    TimeLeft = CustomInt // 10000
    TimeString = 0 < TimeLeft and string.format("%02d:%02d", math.floor(TimeLeft / 60), TimeLeft % 60)
  end
  if TimeString then
    self.TextBlock_Time:SetText(TimeString)
  else
    self.TextBlock_Time:SetText("")
  end
  if State == 1 and TimeLeft <= 0 then
    State = 0
  end
  if State == 0 then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Notice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.TextBlock_Dis:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Occupying:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Pbr:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:HideDistance()
  elseif State == 1 then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Notice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if 0 < TimeLeft then
      self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    self.TextBlock_Dis:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Occupying:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Pbr:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.ImageProcessMaterial then
      self.ImageProcessMaterial:SetScalarParameterValue("Mask_Percent", 0)
    end
    self:ShowDistance()
  elseif State == 2 then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Notice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.TextBlock_Dis:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Occupying:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Pbr:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:ShowDistance()
  elseif State == 3 then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Notice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Dis:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Occupying:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Pbr:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(0.09, 0.65, 0.93, 1.0)))
    self.Image_Pbr:SetColorAndOpacity(FLinearColor(0.09, 0.65, 0.93, 1.0))
    if self.ImageProcessMaterial then
      local Percent = (FPTrialConfig.OccupyDuration - TimeLeft) / FPTrialConfig.OccupyDuration
      self.ImageProcessMaterial:SetScalarParameterValue("Mask_Percent", Percent)
    end
    self:ShowDistance()
  elseif State == 4 then
    self.Image_BG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Notice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ImageBG_Distance:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ImageBG_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Dis:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Occupying:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Pbr:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.TextBlock_Time:SetColorAndOpacity(FSlateColor(FLinearColor(0.83, 0.03, 0.09, 1.0)))
    self.Image_Pbr:SetColorAndOpacity(FLinearColor(0.83, 0.03, 0.09, 1.0))
    if self.ImageProcessMaterial then
      local Percent = (FPTrialConfig.OccupyDuration - TimeLeft) / FPTrialConfig.OccupyDuration
      self.ImageProcessMaterial:SetScalarParameterValue("Mask_Percent", Percent)
    end
    self:ShowDistance()
  end
end
local class = require("class")
local CommonActorScreenMarkUI = require("GameLua.Mod.BaseMod.Client.ScreenMarkUI.CommonActorScreenMarkUI")
return class(CommonActorScreenMarkUI, nil, FramePlatformScreenMark)
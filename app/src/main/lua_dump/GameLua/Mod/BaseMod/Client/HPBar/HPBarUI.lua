local HPBarUI = {
  UpdateInterval = 0.1,
  FallVelocity = 1.5,
  DamageWhiteWidth = 0.02,
  DeadHideTime = 0.5
}
function HPBarUI:Initialize()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.VNG or strRegion == PublishRegionMacros.BLUEHOLE then
    self.bIsVNG = true
    if slua.isValid(self.ProgressBar_Health_Green) then
      self.ProgressBar_Health_Green:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.ProgressBar_Health_Hero_Green:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.ProgressBar_Health:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.ProgressBar_Health_Hero:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.bIsVNG = false
    if slua.isValid(self.ProgressBar_Health_Green) then
      self.ProgressBar_Health_Green:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.ProgressBar_Health_Hero_Green:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.ProgressBar_Health:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.ProgressBar_Health_Hero:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  self:SwitchIsHero(false)
end
function HPBarUI:SetName(BindActor)
  local sName = BindActor.GetHPBarShowName and BindActor:GetHPBarShowName() or ""
  print(bWriteLog and "HPBarUI:SetName", BindActor, BindActor.ResId, sName)
  if sName ~= nil and sName ~= "" and slua.isValid(self.TextBlock_HPName) then
    self.TextBlock_HPName:SetText(sName)
  end
end
function HPBarUI:OnActorBindUI(BindActor)
  if not slua.isValid(BindActor) then
    self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:SetName(BindActor)
  print(bWriteLog and "HPBarUI:OnActorBindUI", BindActor, self:GetHealth(BindActor), self:GetHealthMax(BindActor), self.LocOffset.Z)
  if self:GetHealthMax(BindActor) and self:GetHealth(BindActor) and self:GetHealthMax(BindActor) > 0 and self:GetHealth(BindActor) > 0 then
    self.HPPercentage = self:GetHealth(BindActor) / self:GetHealthMax(BindActor)
    self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.curVirtualPercentage = self.HPPercentage
  local ClientHitDamageLogic = SubsystemMgr:Get("ClientHPBarSubSystem")
  if ClientHitDamageLogic and ClientHitDamageLogic.CharacterHPDataMap then
    local data = ClientHitDamageLogic.CharacterHPDataMap[BindActor]
    if data and data.BeforeDamageHP then
      self.curVirtualPercentage = data.BeforeDamageHP / self:GetHealthMax(BindActor)
    end
  end
  self.VirtualStartPercentage = self.curVirtualPercentage
  if self.curVirtualPercentage <= self.HPPercentage then
    self.ProgressBarHealth:SetPercent(self.HPPercentage)
  else
    self.ProgressBarHealth:SetPercent(self.HPPercentage - self.DamageWhiteWidth)
  end
  if slua.isValid(self.ProgressBarWhite) then
    self.ProgressBarWhite:SetPercent(self.HPPercentage)
  end
  if slua.isValid(self.ProgressBarVirtualHealth) then
    self.ProgressBarVirtualHealth:SetPercent(self.curVirtualPercentage)
  end
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
  if self.DeadHideTimer then
    self:RemoveGameTimer(self.DeadHideTimer)
    self.DeadHideTimer = nil
  end
  self.UpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
    self:UpdateHP()
  end)
  self:SetCachedActor(BindActor, "")
end
function HPBarUI:UpdateHP()
  if slua.isValid(self.SaveActor) and self:GetHealth(self.SaveActor) and self.curVirtualPercentage then
    if self:GetHealthMax(self.SaveActor) > 0 then
      self.HPPercentage = self:GetHealth(self.SaveActor) / self:GetHealthMax(self.SaveActor)
    else
      self.HPPercentage = 0
    end
    if slua.isValid(self.ProgressBarWhite) then
      self.ProgressBarWhite:SetPercent(self.HPPercentage)
    end
    if self.curVirtualPercentage > self.HPPercentage then
      self.curVirtualPercentage = self.curVirtualPercentage - self.UpdateInterval * self.FallVelocity * (self.VirtualStartPercentage - self.HPPercentage)
      if slua.isValid(self.ProgressBarVirtualHealth) then
        self.ProgressBarVirtualHealth:SetPercent(self.curVirtualPercentage)
      end
      self.ProgressBarHealth:SetPercent(self.HPPercentage - self.DamageWhiteWidth)
    else
      self.ProgressBarHealth:SetPercent(self.HPPercentage)
      self.curVirtualPercentage = self.HPPercentage
      self.VirtualStartPercentage = self.curVirtualPercentage
    end
    if self:GetHealth(self.SaveActor) <= 0 and self.DeadHideTimer == nil then
      self.DeadHideTimer = self:AddGameTimer(self.DeadHideTime, false, function()
        self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end)
    end
  end
end
function HPBarUI:OnActorUnbindUI(BindActor)
  self.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
end
function HPBarUI:GetHealth(Actor)
  if Actor and Actor.GetHPBarHealth then
    return Actor:GetHPBarHealth()
  end
  return 0
end
function HPBarUI:GetHealthMax(Actor)
  if Actor and Actor.GetHPBarHealthMax then
    return Actor:GetHPBarHealthMax()
  end
  return 100
end
function HPBarUI:SwitchIsHero(IsHero)
  self.b  if IsHero then
    if slua.isValid(self.Border_Monster) then
      self.Border_Monster:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.Border_Hero:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.bIsVNG then
        self.ProgressBarHealth = self.ProgressBar_Health_Hero_Green
      else
        self.ProgressBarHealth = self.ProgressBar_Health_Hero
      end
      self.ProgressBarVirtualHealth = self.ProgressBar_VirtualHealth_Hero
      self.ProgressBarWhite = self.ProgressBar_White_Hero
    end
  elseif slua.isValid(self.Border_Monster) then
    self.Border_Hero:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Border_Monster:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.bIsVNG then
      self.ProgressBarHealth = self.ProgressBar_Health_Green
    else
      self.ProgressBarHealth = self.ProgressBar_Health
    end
    self.ProgressBarVirtualHealth = self.ProgressBar_VirtualHealth
    self.ProgressBarWhite = self.ProgressBar_White
  end
end
function HPBarUI:OnDestroy()
  self:Dispose()
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, HPBarUI)
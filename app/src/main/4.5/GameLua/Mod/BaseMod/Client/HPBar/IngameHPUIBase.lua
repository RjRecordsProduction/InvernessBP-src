local IngameHPUIBase = {}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local UBusinessHelper = import("BusinessHelper")
local tGreenColorRegion = {BLUEHOLE = true, VNG = true}
function IngameHPUIBase:ctor(selfType)
  self.UpdateInterval = 0.4
  self.CurFocusActor = nil
  print(bWriteLog and "IngameHPUIBase ctor")
end
function IngameHPUIBase:OnInitialize()
  print(bWriteLog and "IngameHPUIBase OnInitialize")
  self.bIsInResult = false
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_REMOVE_HPBAR, self.ShowNoneHP, self)
  self:InitHealthColor()
end
function IngameHPUIBase:InitHealthColor()
  local strRegion = Client.GetPublishRegion()
  if tGreenColorRegion[strRegion] then
    self.UIRoot.WidgetSwitcher_BarFrame:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_ProgressBar:SetActiveWidgetIndex(1)
    self.ProgressBar = self.UIRoot.ProgressBar_Health_Green
  else
    self.UIRoot.WidgetSwitcher_BarFrame:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_ProgressBar:SetActiveWidgetIndex(0)
    self.ProgressBar = self.UIRoot.ProgressBar_Health_Red
  end
end
function IngameHPUIBase:OnBattleResult(_, _)
  print(bWriteLog and "IngameHPUIBase OnBattleResult", self.UIRoot, self.ProgressBar)
  self.bIsInResult = true
  if self.UIRoot and self.UIRoot.CanvasPanel_Health and self.ProgressBar then
    self.UIRoot.CanvasPanel_Health:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.ProgressBar:SetPercent(0)
  end
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
  self.CurFocusActor = nil
end
function IngameHPUIBase:OnShowHP(ShowHPActor)
  if not (slua.isValid(ShowHPActor) and ShowHPActor.GetHPBarType) or ShowHPActor:GetHPBarType() ~= 1 then
    self:ShowNoneHP()
    return
  end
  if slua.isValid(ShowHPActor.VehicleCommon) then
    self:ShowVehicleHP(ShowHPActor)
  else
    self:ShowActorHP(ShowHPActor)
  end
end
function IngameHPUIBase:ShowActorHP(uActor)
  local Health = self:GetHealth(uActor)
  print(bWriteLog and "IngameHPUIBase:ShowActorHP", uActor, uActor.ResId, Health, self:GetHealthMax(uActor), uActor.MonsterName)
  if Health and 0 < Health then
    if uActor.MonsterName and uActor.IsShowHealthbar == false then
      self:ShowNoneHP()
      return
    end
    if slua.isValid(self.UIRoot.TextBlock_HPName) and self.CurFocusActor ~= uActor then
      self.CurFocusActor = uActor
      local ActorName = uActor.GetHPBarShowName and uActor:GetHPBarShowName() or ""
      self.UIRoot.TextBlock_HPName:SetText(ActorName)
    end
    if self:IsCreativeMode() and uActor.UGCLevelFeature then
      if self.bShowMonsterLevel == nil then
        local GameParameterMgr = GetGameParameterManager()
        if GameParameterMgr then
          local Parameter = GameParameterMgr:GetGameParameter("HUDShowMonsterLevel")
          if Parameter and Parameter.Value ~= nil then
            self.bShowMonsterLevel = Parameter.Value
          end
        end
      end
      if self.bShowMonsterLevel then
        local Level = uActor.UGCLevelFeature.UGCLevel
        if Level and 0 < Level then
          self.UIRoot.TextBlock_LV:SetText(string.format("Lv.%d", Level))
        else
          self.UIRoot.TextBlock_LV:SetText("")
        end
      else
        self.UIRoot.TextBlock_LV:SetText("")
      end
    end
    self.UIRoot.CanvasPanel_Health:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.UpdateTimer then
      self:RemoveGameTimer(self.UpdateTimer)
      self.UpdateTimer = nil
    end
    local HealthMax = self:GetHealthMax(uActor)
    self.ProgressBar:SetPercent(Health / HealthMax)
    self.UpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
      if slua.isValid(uActor) and uActor:CheckIsRecycled() == false then
        local NewHealth = self:GetHealth(uActor)
        local NewHealthMax = self:GetHealthMax(uActor)
        self.ProgressBar:SetPercent(NewHealth / NewHealthMax)
        if NewHealth <= 0 then
          self:ShowNoneHP()
        end
      else
        self:ShowNoneHP()
      end
    end)
  else
    self:ShowNoneHP()
  end
end
function IngameHPUIBase:GetHealthMax(Actor)
  if slua.isValid(Actor) and Actor.GetHPBarHealthMax then
    return Actor:GetHPBarHealthMax()
  end
  return 100
end
function IngameHPUIBase:GetHealth(Actor)
  if not slua.isValid(Actor) then
    return 0
  end
  if self:IsCreativeMode() and Actor.DSHealth then
    return Actor.DSHealth
  end
  if Actor and Actor.GetHPBarHealth then
    return Actor:GetHPBarHealth()
  end
  return 0
end
function IngameHPUIBase:ShowVehicleHP(uVehicle)
  local Health = self:GetHealth(uVehicle)
  if Health and 0 < Health then
    if self.CurFocusActor ~= uVehicle then
      self.CurFocusActor = uVehicle
      local VehicleName = uVehicle.GetHPBarShowName and uVehicle:GetHPBarShowName() or ""
      print(bWriteLog and "IngameHPUIBase:ShowVehicleHP", VehicleName)
      if slua.isValid(self.UIRoot.TextBlock_HPName) then
        self.UIRoot.TextBlock_HPName:SetText(VehicleName)
      end
    end
    self.UIRoot.CanvasPanel_Health:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    if self.UpdateTimer then
      self:RemoveGameTimer(self.UpdateTimer)
      self.UpdateTimer = nil
    end
    self.ProgressBar:SetPercent(Health / self:GetHealthMax(uVehicle))
    self.UpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
      self:UpdateVehicleHP()
    end)
  else
    self:ShowNoneHP()
  end
end
function IngameHPUIBase:UpdateVehicleHP()
  local Health = self:GetHealth(self.CurFocusActor)
  if Health and 0 < Health then
    self.ProgressBar:SetPercent(Health / self:GetHealthMax(self.CurFocusActor))
  else
    self:ShowNoneHP()
  end
end
function IngameHPUIBase:ShowNoneHP()
  print(bWriteLog and "IngameHPUIBase:ShowNoneHP")
  self.UIRoot.CanvasPanel_Health:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ProgressBar:SetPercent(0)
  self.CurFocusActor = nil
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
end
function IngameHPUIBase:OnClose()
  print(bWriteLog and "IngameHPUIBase:OnClose")
  self.CurFocusActor = nil
  if self.UpdateTimer then
    self:RemoveGameTimer(self.UpdateTimer)
    self.UpdateTimer = nil
  end
  IngameHPUIBase.__super.OnClose(self)
end
function IngameHPUIBase:IsCreativeMode()
  if self.bIsCreativeMode == nil then
    self.bIsCreativeMode = CGameState and CGameState.IsCreativeMode and CGameState:IsCreativeMode()
  end
  return self.bIsCreativeMode
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CIngameHPUIBase = class(ui_base, nil, IngameHPUIBase)
return CIngameHPUIBase
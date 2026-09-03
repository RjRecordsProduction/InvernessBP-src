local GameplayStatics = import("GameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local PlayerInfoPanelMain = {}
function PlayerInfoPanelMain:ctor()
  self.CurEnergy = 0
  self.bLoaded = false
  self.RecoverCount = 0
  self.LaestestEnergy = 0
  self.TotalPieceTime = 0
  self.AntidoteExeTime = 0
  self.AntidoteMaxTime = 0
  self.PrePredictValue = 0
  self.SumAddHealth = 0
  self.SumReducePredictHealth = 0
  self.CurPredictHealth = 0
  self.TotalAddToHealth = 0
  self.PredictStepValue = 0
  self.lastHPTimeSecond = 0
  self.RecoverStartHealth = 0
  self.WaitAddPredictTime = 0
  self.DurationEveryPiece = 0.08
  self.LastTimeRatioHealth = 1
  self.PredictHideBaseHealth = 0
  self.IsMultAddHealth = false
  self.bAntidoteReducible = false
  self.bNeedUpdateHealth = false
  self.bAnimationIsPlaying = false
  self.bShowEnergyAddition = false
  self.bHasOpenMiniGameOnce = false
  self.bHidePredictNextFrame = false
  self.NeedPredictWaitForHide = false
  self.HealthHistory = nil
  self.PredictStayOverLogicTimer = nil
  self.NewHpBarColor_Value = {
    [0] = FLinearColor(1, 1, 1, 0.5),
    [1] = FLinearColor(1, 1, 1, 0.8),
    [2] = FLinearColor(0.693872, 0.376262, 0.366253, 1),
    [3] = FLinearColor(0.64448, 0.057805, 0, 1)
  }
  self.StateIconList = {}
  self.CachedPlayerCharacter = nil
end
function PlayerInfoPanelMain:OnInitialize()
  self.NewSelfHPDynamicMaterial = self.UIRoot.Image_NewSelfHP_Status:GetDynamicMaterial()
  self:WidgetCollapse(self.UIRoot.ProgressBar_LessBloodVFX)
end
function PlayerInfoPanelMain:OnPostInitialize()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    return
  end
  self:AttachToPanel(MainControlBaseUI.CanvasPanelForPlayerInfo)
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
  self:InitStateIcons()
end
function PlayerInfoPanelMain:RegistEvents()
  self.bLoaded = true
  GameplayData.AddSelfPlayerControllerEvent(self, "OnTeammateHPChangeDelegate", self.OnTeammateHPChangeDelegate_Handle, self)
  self.UIRoot.Image_NewSelfHP_Status:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddUIMessageEvent("UIMsg_PlayHealthEffect", self.UIMsg_PlayHealthEffect, self)
  self:AddUIMessageEvent("PlayerInfo_UpdateEnergy", self.PlayerInfo_UpdateEnergy, self)
  self:AddUIMessageEvent("UIMsg_AdaptFBTipsWithIPX", self.UIMsg_AdaptFBTipsWithIPX, self)
  self:AddUIMessageEvent("UIMsg_ForceUpdate_Health", self.UIMsg_ForceUpdate_Health, self)
  self:AddUIMessageEvent("PlayerInfo_UpdatePredictHealth", self.PlayerInfo_UpdatePredictHealth, self)
  self:AddUIMessageEvent("PlayerInfo_UpdatePredictEnergy", self.PlayerInfo_UpdatePredictEnergy, self)
  self:AddUIMessageEvent("PlayerInfo_SpectatorChangeUpdateEnergy", self.PlayerInfo_SpectatorChangeUpdateEnergy, self)
  self:AddUIMessageEvent("UIMsg_HideSomeUIForMiniGameMachine", self.UIMsg_HideSomeUIForMiniGameMachine, self)
  self:AddUIMessageEvent("UIMsg_ShowSomeUIAfterMiniGameMachine", self.UIMsg_ShowSomeUIAfterMiniGameMachine, self)
  self:AddControlEventByControl(self.UIRoot.Image_HpBG, "OnMouseButtonDownEvent", self.Image_HpBG_OnMouseButtonDown, self)
  self:AddControlEventByControl(self.UIRoot.EnergyChangeAnim, "OnAnimationStarted", function()
    self.bAnimationIsPlaying = true
  end)
  self:AddControlEventByControl(self.UIRoot.EnergyChangeAnim, "OnAnimationFinished", function()
    self.bAnimationIsPlaying = false
  end)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerNameChange", self.OnPlayerNameChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnCharacterBreathChange", self.OnUpdateBreath, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStateChange", self.UpdateThermometerOffset, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.UIMsg_ForceUpdate_Health, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "RunOnNextFrameDelegate", self.HidePredictNextFrame, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnCharacterAntidoteChange", self.UpdateAntidoteData, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnCharacterRecoveryHealth", self.OnCharacterRecoveryHealth, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnCharacterReceiveHealthChangeHistory", self.UpdateHealthChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnViewTargetChange", self.PlayerInfo_SpectatorChangeUpdateEnergy, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnectResetUIByPlayerControllerStateDelegate, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_REVIVAL, self.OnQuitSpectating, self)
  self.LastTickTime = GameplayStatics.GetTimeSeconds(CGameWorld)
  self:AddGameTimer(0.1, true, function()
    if not slua.isValid(CGameWorld) or not slua.isValid(self.UIRoot) then
      return
    end
    local CurrentTime = GameplayStatics.GetTimeSeconds(CGameWorld)
    if CurrentTime then
      self:TickInternal(CurrentTime - self.LastTickTime)
      self.LastTickTime = CurrentTime
    end
  end)
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    self:OnPlayerNameChange(PlayerState.PlayerName)
  end
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.GridPanel_Self, self, "MainControlBaseUI_PlayerInfoPanel")
end
function PlayerInfoPanelMain:OnTeammateHPChangeDelegate_Handle()
  self:UIMsg_ForceUpdate_Health()
end
function PlayerInfoPanelMain:OnPlayerCharacterChange(_, PlayerCharacter)
  self.Cached  self:PlayerInfo_UpdateEnergy()
end
function PlayerInfoPanelMain:OnReconnectResetUIByPlayerControllerStateDelegate()
  self:UIMsg_ForceUpdate_Health()
end
function PlayerInfoPanelMain:SetRenderScale(Scale)
  self.UIRoot:SetRenderScale(Scale)
end
function PlayerInfoPanelMain:OnQuitSpectating(_, _, InPlayerKey)
  print(bWriteLog and "MainControlBaseUI_Debug_Msg: OnQuitSpectating InPlayerKey", InPlayerKey)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local SelfPlayerKey = PlayerCharacter.PlayerKey
  if SelfPlayerKey ~= InPlayerKey then
    return
  end
  print(bWriteLog and "MainControlBaseUI_Debug_Msg: OnQuitSpectating SelfPlayerKey", SelfPlayerKey)
  self:ResetUIStateAfterRespawn()
end
function PlayerInfoPanelMain:UIMsg_PlayHealthEffect()
  self:PlayUserWidgetAnimation(self.UIRoot.HealthFull, 0, 1, 0, 1)
end
function PlayerInfoPanelMain:UIMsg_ShowSomeUIAfterMiniGameMachine()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  local CachedPlayerInfoLayout = self.UIRoot.Slot:GetLayout()
  self:AttachToPanel(MainControlBaseUI.CanvasPanel_42)
  self.UIRoot.Slot:SetLayout(CachedPlayerInfoLayout)
  self:SetZOrder(0)
end
function PlayerInfoPanelMain:UIMsg_HideSomeUIForMiniGameMachine()
  if self.bHasOpenMiniGameOnce then
    return
  end
  self.bHasOpenMiniGameOnce = true
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not slua.isValid(MainControlBaseUI) then
    return
  end
  local CachedPlayerInfoLayout = self.UIRoot.Slot:GetLayout()
  self:AttachToPanel(MainControlBaseUI.CanvasPanel_0)
  self.UIRoot.Slot:SetLayout(CachedPlayerInfoLayout)
  self:SetZOrder(400)
end
function PlayerInfoPanelMain:UIMsg_AdaptFBTipsWithIPX()
  self.UIRoot:SetRenderTranslation(FVector2D(0, -20))
end
function PlayerInfoPanelMain:UpdateInspectatTargetHealth()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController:IsInSpectating() then
    return
  end
  local CurrentPlayerState = PlayerController:GetCurPlayerState()
  if not slua.isValid(CurrentPlayerState) then
    return
  end
  local CurrentPawn = PlayerController:GetCurPawn()
  if not slua.isValid(CurrentPawn) or CurrentPawn.HealthStatus == nil then
    return
  end
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  if CurrentPlayerState:GetPlayerMaxHealth() > 0 and CurrentPawn.HealthStatus == ECharacterHealthStatus.HealthyAlive then
    self:OnUpdateHP(0, CurrentPlayerState:GetPlayerHealth() / CurrentPlayerState:GetPlayerMaxHealth())
  end
end
function PlayerInfoPanelMain:UIMsg_ForceUpdate_Health()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerState = PlayerController.PlayerState
  if not slua.isValid(PlayerState) then
    return
  end
  local PlayerCharacter = PlayerController.STExtraBaseCharacter
  if not slua.isValid(PlayerCharacter) or PlayerCharacter.Health == nil or PlayerCharacter.HealthMax == nil then
    return
  end
  local EPlayerLiveState = import("ExtraPlayerLiveState")
  if PlayerState.LiveState == EPlayerLiveState.InDying then
    return
  end
  local UIRoot = self.UIRoot
  local CurHealthRatio = FuncUtil.Clamp(PlayerCharacter.Health / PlayerCharacter.HealthMax, 0, 1)
  local PercentSegement = STExtraGameplayStatics.GetPercentSegement(CurHealthRatio)
  local Image_LowHPWaringBGVisibility = UEnums.ESlateVisibility.Collapsed
  local NewSelfHPDynamicMaterial = UIRoot.Image_NewSelfHP_Status:GetDynamicMaterial()
  if not NewSelfHPDynamicMaterial then
    return
  end
  if PercentSegement == 1 or PercentSegement == 2 then
    Image_LowHPWaringBGVisibility = UEnums.ESlateVisibility.HitTestInvisible
  end
  local ColorIndex = 4 - PercentSegement
  if PercentSegement <= 1 then
    ColorIndex = 3 - PercentSegement
  end
  if PercentSegement == 4 then
    CurHealthRatio = 1
  end
  UIRoot.Image_LowHPWaringBG:SetWidgetVisibility(Image_LowHPWaringBGVisibility)
  NewSelfHPDynamicMaterial:SetScalarParameterValue("PlayerHPBarpercent", CurHealthRatio)
  UIRoot.Image_NewSelfHP_Status:SetColorAndOpacity(self.NewHpBarColor_Value[ColorIndex])
end
function PlayerInfoPanelMain:PlayerInfo_UpdatePredictEnergy()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self.bShowEnergyAddition = false
    self:WidgetCollapse(self.UIRoot.HorizontalBox_2)
    return
  end
  local EnergyData = PlayerCharacter:GetCharacterEnergy()
  self.bShowEnergyAddition = EnergyData.EnergyPredict > 0
end
function PlayerInfoPanelMain:PlayerInfo_SpectatorChangeUpdateEnergy()
  self.CurEnergy = 0
  local UIRoot = self.UIRoot
  self:SetEnergyProgressBar(self.CurEnergy, UIRoot.ProgressBar_Power1, UIRoot.ProgressBar_Power2, UIRoot.ProgressBar_Power3, UIRoot.ProgressBar_Power4, UIRoot.HorizontalBox_1)
  self:UpdatePlayerBuff(self.CurEnergy, false)
end
function PlayerInfoPanelMain:HidePredictNextFrame()
  self:WidgetCollapse(self.UIRoot.ProgressBar_Addition)
  printf(bWriteLog and "PlayerInfo_UpdatePredictHealth HidePredictNextFrame")
  if not self.bHidePredictNextFrame then
    return
  end
  self.bHidePredictNextFrame = false
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  PlayerCharacter:ResetValueLimitForHealthPredict()
end
function PlayerInfoPanelMain:OnPlayerNameChange(PlayerName)
  if not PlayerName then
    return
  end
  if 1 < #PlayerName then
    self.UIRoot.Self_Name:SetText(string.sub(PlayerName, 1, 11))
  else
    self.UIRoot.Self_Name:SetText(PlayerName)
  end
end
function PlayerInfoPanelMain:TickInternal(DeltaTime)
  if self.NeedPredictWaitForHide then
    self.WaitAddPredictTime = self.WaitAddPredictTime - DeltaTime
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and (PlayerCharacter.Health >= self.TotalAddToHealth - 1.0E-5 or self.WaitAddPredictTime <= 0 or self.PredictHideBaseHealth > PlayerCharacter.Health) then
      self.NeedPredictWaitForHide = false
      PlayerCharacter:ResetValueLimitForHealthPredict()
      self:WidgetHidden(self.UIRoot.ProgressBar_Addition)
      printf(bWriteLog and "PlayerInfo_UpdatePredictHealth TickInternal ResetValueLimitForHealthPredict")
    end
  end
  if self.bAntidoteReducible then
    self:UpdateAntidoteProgressBar(DeltaTime)
  end
  self:UpdatePredictEnergyPredictProgress()
  if self.bNeedUpdateHealth then
    self:TickUpdateHealth()
  end
end
function PlayerInfoPanelMain:IsZombieMode()
  return false
end
function PlayerInfoPanelMain:UpdateAntidoteProgressBar(DeltaTime)
  self.AntidoteExeTime = self.AntidoteExeTime - DeltaTime
  if self.AntidoteExeTime > 0 then
    local Percent = FuncUtil.Clamp(self.AntidoteExeTime, 0, self.AntidoteMaxTime) / self.AntidoteMaxTime
    self.UIRoot.ProgressBar_PoisonFog:SetPercent(Percent)
  else
    self.AntidoteExeTime = 0
    self.bAntidoteReducible = false
    self:WidgetHidden(self.UIRoot.ProgressBar_PoisonFog)
  end
end
function PlayerInfoPanelMain:UpdatePredictEnergyPredictProgress()
  if not self.bShowEnergyAddition and not self.bAnimationIsPlaying then
    self:WidgetCollapse(self.UIRoot.HorizontalBox_2)
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local UIRoot = self.UIRoot
  local EnergyData = PlayerCharacter:GetCharacterEnergy()
  self:SetEnergyProgressBar(EnergyData.EnergyCurrent + EnergyData.EnergyPredict, UIRoot.ProgressBar_0, UIRoot.ProgressBar_1, UIRoot.ProgressBar_2, UIRoot.ProgressBar_3, UIRoot.HorizontalBox_2)
end
function PlayerInfoPanelMain:TickUpdateHealth()
  local CurrentHPTimeSecond = GameplayStatics.GetTimeSeconds(CGameWorld)
  self.TotalPieceTime = self.TotalPieceTime + (CurrentHPTimeSecond - self.lastHPTimeSecond)
  self.lastHPTimeSecond = CurrentHPTimeSecond
  if self.TotalPieceTime >= self.DurationEveryPiece then
    self:WidgetCollapse(self.UIRoot.ProgressBar_LessBloodVFX)
    self:OnUpdateHealthChange()
  end
end
function PlayerInfoPanelMain:GetMultiCauserBaseHealth(uPlayerCharacter)
  if not slua.isValid(uPlayerCharacter) then
    return 0
  end
  local CurrentHealth = uPlayerCharacter.Health
  if self.PreHealth == nil then
    return CurrentHealth
  end
  local PredictAddHealth = self.PrePredictValue - uPlayerCharacter.HealthPredict
  local RealAddHealth = CurrentHealth - self.PreHealth
  if PredictAddHealth < 0 then
    self.SumAddHealth = 0
    self.SumReducePredictHealth = 0
    printf(bWriteLog and "GetMultiCauserBaseHealth 0  Health:%f ", CurrentHealth)
    return CurrentHealth
  end
  if RealAddHealth < 0 then
    self.SumAddHealth = 0
    self.SumReducePredictHealth = 0
    printf(bWriteLog and "GetMultiCauserBaseHealth 1  Health:%f ", CurrentHealth)
    return CurrentHealth
  end
  self.SumAddHealth = self.SumAddHealth + RealAddHealth
  self.SumReducePredictHealth = self.SumReducePredictHealth + PredictAddHealth
  if math.abs(self.SumReducePredictHealth - self.SumAddHealth) <= 1.0E-4 then
    printf(bWriteLog and "GetMultiCauserBaseHealth 3 Health:%f SumAddHealth:%f SumReducePredictHealth:%f", CurrentHealth, self.SumAddHealth, self.SumReducePredictHealth)
    return CurrentHealth
  end
  if self.SumAddHealth < self.SumReducePredictHealth then
    local CurrentAddSimulateHealth = self.SumReducePredictHealth - self.SumAddHealth
    local SimulateHealth = CurrentHealth + CurrentAddSimulateHealth
    printf(bWriteLog and "GetMultiCauserBaseHealth 4 Health:%f CurrentAddSimulateHealth:%f  SimulateHealth:%f SumAddHealth:%f SumReducePredictHealth:%f", CurrentHealth, CurrentAddSimulateHealth, SimulateHealth, self.SumAddHealth, self.SumReducePredictHealth)
    return SimulateHealth
  else
    local CurrentAddSimulateHealth = self.SumReducePredictHealth - self.SumAddHealth
    local SimulateHealth = CurrentHealth + CurrentAddSimulateHealth
    printf(bWriteLog and "GetMultiCauserBaseHealth 5 Health:%f CurrentAddSimulateHealth:%f  SimulateHealth:%f SumAddHealth:%f SumReducePredictHealth:%f", CurrentHealth, CurrentAddSimulateHealth, SimulateHealth, self.SumAddHealth, self.SumReducePredictHealth)
    return SimulateHealth
  end
end
function PlayerInfoPanelMain:IsMultiCauserPredictHealth(uPlayerCharacter)
  if not uPlayerCharacter then
    return false
  end
  local DataList = uPlayerCharacter.HealthPredictShowDataList
  for i = 1, DataList:Num() do
    local Item = DataList:Get(i - 1)
    if Item and Item.CauserPlayerKey ~= 0 then
      return true
    end
  end
  return false
end
function PlayerInfoPanelMain:PlayerInfo_UpdatePredictHealth()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local PlayerHealth = 0
  if not self:IsMultiCauserPredictHealth(PlayerCharacter) then
    if 0 < self.SumReducePredictHealth then
      local FinishAddPredictHealth = self.PrePredictValue - PlayerCharacter.HealthPredict
      self.SumReducePredictHealth = self.SumReducePredictHealth + FinishAddPredictHealth
      local CurrentHealth = PlayerCharacter.Health
      local RealAddHealth = CurrentHealth - self.PreHealth
      self.SumAddHealth = self.SumAddHealth + RealAddHealth
      PlayerHealth = CurrentHealth
      local CurrentAddSimulateHealth = 0
      if self.SumAddHealth < self.SumReducePredictHealth then
        CurrentAddSimulateHealth = self.SumReducePredictHealth - self.SumAddHealth
        PlayerHealth = CurrentHealth + CurrentAddSimulateHealth
      end
      printf(bWriteLog and "PlayerInfo_UpdatePredictHealth bMultiCauserAddPredictHealth=false CurrentHealth:%f CurrentAddSimulateHealth:%f PlayerHealth:%f", CurrentHealth, CurrentAddSimulateHealth, PlayerHealth)
    else
      PlayerHealth = self:GetPlayerHealth()
      printf(bWriteLog and "PlayerInfo_UpdatePredictHealth bMultiCauserAddPredictHealth=false CurrentHealth:%f PlayerHealth:%f", PlayerCharacter.Health, PlayerHealth)
    end
    self.SumAddHealth = 0
    self.SumReducePredictHealth = 0
    printf(bWriteLog and "PlayerInfo_UpdatePredictHealth bMultiCauserAddPredictHealth false SumAddHealth = 0 ")
  else
    PlayerHealth = self:GetMultiCauserBaseHealth(PlayerCharacter)
    printf(bWriteLog and "PlayerInfo_UpdatePredictHealth bMultiCauserAddPredictHealth=true CurrentHealth:%f PlayerHealth:%f", PlayerCharacter.Health, PlayerHealth)
  end
  local ValueLimitForHealthPredict = PlayerCharacter:GetValueLimitForHealthPredict()
  self.CurPredictHealth = PlayerCharacter.HealthPredict
  self:SetPreditTimerFunc(self.CurPredictHealth)
  self.TotalAddToHealth = math.min(ValueLimitForHealthPredict, PlayerHealth + PlayerCharacter.HealthPredict)
  self.PrePredictValue = PlayerCharacter.HealthPredict
  self.PreHealth = PlayerCharacter.Health
  self:WidgetSelfHit(self.UIRoot.ProgressBar_Addition)
  printf(bWriteLog and "PlayerInfo_UpdatePredictHealth TotalAddToHealth:%f ValueLimitForHealthPredict:%f PrePredictValue:%f CurPredictHealth:%f PlayerHealth:%f", self.TotalAddToHealth, ValueLimitForHealthPredict, self.PrePredictValue, self.CurPredictHealth, PlayerHealth)
  self.UIRoot.ProgressBar_Addition:SetPercent(FuncUtil.Clamp(self.TotalAddToHealth / PlayerCharacter.HealthMax, 0, 1))
  local bNeedShow = 0 < self.CurPredictHealth
  EventSystem:postEvent(EVENTTYPE_SINK_NORMAL, EVENTID_SINK_ON_UPDATE_HEALTH_PREDICT, self.TotalAddToHealth, bNeedShow)
  if bNeedShow then
    return
  end
  self.RecoverCount = 0
  self.RecoverStartHealth = 0
  self.SumAddHealth = 0
  self.SumReducePredictHealth = 0
  if self.IsMultAddHealth then
    self.WaitAddPredictTime = 6.9
    self.IsMultAddHealth = false
    self.NeedPredictWaitForHide = true
    printf(bWriteLog and "PlayerInfo_UpdatePredictHealth WaitAddPredictTime =6.9 hide")
  else
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      self.bHidePredictNextFrame = true
      printf(bWriteLog and "PlayerInfo_UpdatePredictHealth RunOnNextFrameEvent CurrentHealth:%f PlayerHealth:%f CurPredictHealth:%f", PlayerCharacter.Health, PlayerHealth, self.CurPredictHealth)
      PlayerController:RunOnNextFrameEvent()
    end
  end
end
function PlayerInfoPanelMain:SetPreditTimerFunc(PredictValue)
  if self.PredictStayOverLogicTimer then
    self:RemoveGameTimer(self.PredictStayOverLogicTimer)
    self.PredictStayOverLogicTimer = nil
  end
  if PredictValue <= 0 then
    return
  end
  self.PredictStayOverLogicTimer = self:AddGameTimer(7.9, false, function()
    self:PredictStayOverLogic()
  end)
end
function PlayerInfoPanelMain:PredictStayOverLogic()
  if self.PredictStayOverLogic then
    self:RemoveGameTimer(self.PredictStayOverLogicTimer)
    self.PredictStayOverLogicTimer = nil
  end
  self.UIRoot.ProgressBar_Addition:SetPercent(0)
  printf(bWriteLog and "PlayerInfo_UpdatePredictHealth PredictStayOverLogic")
  self:WidgetCollapse(self.UIRoot.ProgressBar_Addition)
end
function PlayerInfoPanelMain:GetPlayerHealth()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  self.PredictHideBaseHealth = PlayerCharacter.Health
  if self.RecoverStartHealth <= 1.0E-5 then
    return self.PredictHideBaseHealth
  end
  if self.RecoverStartHealth > self.PredictHideBaseHealth then
    self.RecoverCount = 0
    self.RecoverStartHealth = self.PredictHideBaseHealth
    return self.PredictHideBaseHealth
  end
  if self.PrePredictValue < PlayerCharacter.HealthPredict then
    self.RecoverCount = 0
    self.RecoverStartHealth = self.PredictHideBaseHealth
    return self.PredictHideBaseHealth
  end
  self.PredictStepValue = self.PrePredictValue - PlayerCharacter.HealthPredict
  if self.PredictStepValue < 10 then
    self.RecoverCount = self.RecoverCount + 1
  end
  local PredictValue = self.RecoverStartHealth + self.PredictStepValue * self.RecoverCount
  if PredictValue >= self.PredictHideBaseHealth then
    return PredictValue
  end
  self.RecoverCount = 0
  self.RecoverStartHealth = self.PredictHideBaseHealth
  return self.PredictHideBaseHealth
end
function PlayerInfoPanelMain:UpdateHealthChange(InHealthHistory)
  self.HealthHistory = InHealthHistory
  self:OnUpdateHealthChange()
end
function PlayerInfoPanelMain:OnUpdateHealthChange()
  if not self.HealthHistory or self.HealthHistory:Num() <= 0 then
    self.bNeedUpdateHealth = true
    return
  end
  local PlayerCharacter = self.CachedPlayerCharacter
  if not slua.isValid(PlayerCharacter) or 0 >= PlayerCharacter.HealthMax then
    return
  end
  local CurrentHP = self.HealthHistory:Get(0)
  local HealthMax = PlayerCharacter.HealthMax
  self:OnUpdateHP(CurrentHP, CurrentHP / HealthMax)
  self.HealthHistory:Remove(0)
  self.TotalPieceTime = 0
  self.lastHPTimeSecond = GameplayStatics.GetTimeSeconds(CGameWorld)
end
function PlayerInfoPanelMain:OnUpdateHP(CurrentHP, RatioHP)
  self.UIRoot.Image_NewSelfHP_Status:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  RatioHP = FuncUtil.Clamp(RatioHP, 0, 1)
  local AdjustRationHP = RatioHP
  local ColorIndex = 0
  local UIRoot = self.UIRoot
  local Image_LowHPWaringBGVisibility = UEnums.ESlateVisibility.Collapsed
  if 0.9999 <= RatioHP then
    ColorIndex = 0
    AdjustRationHP = 1
  elseif 0.7499 <= RatioHP then
    ColorIndex = 0
  elseif 0.2499 <= RatioHP then
    ColorIndex = 2
    Image_LowHPWaringBGVisibility = UEnums.ESlateVisibility.HitTestInvisible
  else
    ColorIndex = 3
    if RatioHP ~= 0 then
      AdjustRationHP = FuncUtil.Clamp(RatioHP, 0.005, 0.2499)
    end
  end
  UIRoot.Image_LowHPWaringBG:SetWidgetVisibility(Image_LowHPWaringBGVisibility)
  if self.NewSelfHPDynamicMaterial then
    self.NewSelfHPDynamicMaterial:SetScalarParameterValue("PlayerHPBarpercent", AdjustRationHP)
  end
  UIRoot.Image_NewSelfHP_Status:SetColorAndOpacity(self.NewHpBarColor_Value[ColorIndex])
  if RatioHP < self.LastTimeRatioHealth then
    UIRoot.ProgressBar_LessBloodVFX:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local BloodLessenRightOffset = 0
    local BloodLessenLeftOffset = UIRoot.SizeBox_6.WidthOverride * RatioHP
    if UIRoot:IsAnimationPlaying(UIRoot.LessBlood_Anim) then
      BloodLessenRightOffset = UIRoot.ProgressBar_LessBloodVFX.Slot:GetOffsets().Right
    else
      BloodLessenRightOffset = UIRoot.SizeBox_6.WidthOverride - UIRoot.SizeBox_6.WidthOverride * self.LastTimeRatioHealth
      UIRoot:PlayUserWidgetAnimation(UIRoot.LessBlood_Anim, self.TotalPieceTime * 0.3, 1, 0, 1.0)
    end
    UIRoot.ProgressBar_LessBloodVFX.Slot:SetOffsets(FMargin(BloodLessenLeftOffset, 0.0, BloodLessenRightOffset, 0.0))
    self.bNeedUpdateHealth = true
  end
  self.LastTimeRatioHealth = RatioHP
  UIRoot.Self_HPEffectBar:SetPercent(self.LastTimeRatioHealth)
  if RatioHP == 0 then
    print(bWriteLog and "PlayerInfoPanel OnUpdateHP, PlayerInfo_UpdatePredictHealth")
    self:PlayerInfo_UpdatePredictHealth()
  end
end
function PlayerInfoPanelMain:UpdateThermometerOffset(GameState)
  if GameState == "ActiveState" or GameState == "FightingState" or GameState == "FinishedState" then
    self.UIRoot.GridPanel_Thermometer.Slot:SetPosition(FVector2D(-268.5, -98))
  elseif GameState == "ReadyState" then
    self.UIRoot.GridPanel_Thermometer.Slot:SetPosition(FVector2D(-200, -98))
  end
end
function PlayerInfoPanelMain:UpdateAntidoteData(ExeTime, MaxTime)
  if 0 <= ExeTime and 0 <= MaxTime then
    self.bAntidoteReducible = true
  else
    self.bAntidoteReducible = false
  end
  if self.bAntidoteReducible then
    self.Antidote    self.Antidote    self:WidgetSelfHit(self.UIRoot.HorizontalBox_PoisonFog)
  else
    self:WidgetHidden(self.UIRoot.HorizontalBox_PoisonFog)
  end
end
function PlayerInfoPanelMain:OnCharacterRecoveryHealth()
  self.IsMultAddHealth = self.RecoverCount > 0
  self.RecoverCount = 0
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not slua.isValid(PlayerController.STExtraBaseCharacter) then
    return
  end
  self.RecoverStartHealth = PlayerController.STExtraBaseCharacter.Health
end
function PlayerInfoPanelMain:OnUpdateBreath(Breath, Ratio, Who, HealthStatus)
  if not slua.isValid(Who) or Who.ShouldUpdateHPOnUI == nil then
    return
  end
  if HealthStatus == 0 then
    return
  end
  local HpStatusMaterial = self.UIRoot.Image_NewSelfHP_Status:GetDynamicMaterial()
  if slua.isValid(HpStatusMaterial) then
    HpStatusMaterial:SetScalarParameterValue("PlayerHPBarpercent", FuncUtil.Clamp(Ratio, 0, 1))
  end
  self:WidgetCollapse(self.UIRoot.Image_LowHPWaringBG)
  self.UIRoot.Image_NewSelfHP_Status:SetColorAndOpacity(self.NewHpBarColor_Value[3])
end
function PlayerInfoPanelMain:ResetUIStateAfterRespawn()
  local HpStatusMaterial = self.UIRoot.Image_NewSelfHP_Status:GetDynamicMaterial()
  if slua.isValid(HpStatusMaterial) then
    HpStatusMaterial:SetScalarParameterValue("PlayerHPBarpercent", 1)
  end
  self.CurEnergy = 0
  self:WidgetCollapse(self.UIRoot.Image_LowHPWaringBG)
  self.UIRoot.Image_NewSelfHP_Status:SetColorAndOpacity(self.NewHpBarColor_Value[0])
  self:PlayerInfo_UpdateEnergy()
  self:WidgetCollapse(self.UIRoot.HorizontalBox_1)
end
function PlayerInfoPanelMain:Image_HpBG_OnMouseButtonDown()
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI:BuffDisplayListBtnClickEvent()
  end
  return WidgetBlueprintLibrary.Handled()
end
function PlayerInfoPanelMain:PlayerInfo_UpdateEnergy()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local EnergyData = PlayerCharacter:GetCharacterEnergy()
  self.LaestestEnergy = EnergyData.EnergyCurrent
  if self.LaestestEnergy > self.CurEnergy then
    self:WidgetSelfHit(self.UIRoot.HorizontalBox_1)
    self.UIRoot:PlayAnimationTo(self.UIRoot.EnergyChangeAnim, self.CurEnergy * 0.01, self.LaestestEnergy * 0.01, 1, 0, 1)
  else
    self:SetEnergyProgressBar(self.LaestestEnergy, self.UIRoot.ProgressBar_Power1, self.UIRoot.ProgressBar_Power2, self.UIRoot.ProgressBar_Power3, self.UIRoot.ProgressBar_Power4, self.UIRoot.HorizontalBox_1)
  end
  self.CurEnergy = self.LaestestEnergy
  self:UpdatePlayerBuff(self.CurEnergy, false)
end
function PlayerInfoPanelMain:SetEnergyProgressBar(Energy, ProgressBar1, ProgressBar2, ProgressBar3, ProgressBar4, ProgressBarRoot)
  if Energy <= 0 then
    self:WidgetHidden(ProgressBarRoot)
    return
  end
  self:WidgetSelfHit(ProgressBarRoot)
  ProgressBar1:SetPercent(FuncUtil.Clamp(Energy / 20, 0, 1))
  ProgressBar2:SetPercent(FuncUtil.Clamp((Energy - 20) / 40, 0, 1))
  ProgressBar3:SetPercent(FuncUtil.Clamp((Energy - 60) / 30, 0, 1))
  ProgressBar4:SetPercent(FuncUtil.Clamp((Energy - 90) / 10, 0, 1))
end
function PlayerInfoPanelMain:UpdatePlayerBuff(Energy, bSInk)
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if slua.isValid(MainControlBaseUI) and slua.isValid(MainControlBaseUI.DynamicBattleFBTipsWidget) then
    if KismetMathLibrary.InRange_FloatFloat(Energy, 0, 100, false, true) then
      MainControlBaseUI:ShowHelpIcon()
    else
      MainControlBaseUI:HideHelpIcon()
    end
  end
  if bSInk then
    return
  end
  if slua.isValid(MainControlBaseUI) and slua.isValid(MainControlBaseUI.DynamicBattleFBTipsWidget) then
    if KismetMathLibrary.InRange_FloatFloat(Energy, 60, 100, true, true) then
      MainControlBaseUI:ShowPowerIcon()
    else
      MainControlBaseUI:HidePowerIcon()
    end
  end
end
function PlayerInfoPanelMain:ClearHPUI()
  local UIRoot = self.UIRoot
  local NewSelfHPDynamicMaterial = UIRoot.Image_NewSelfHP_Status:GetDynamicMaterial()
  UIRoot.Image_LowHPWaringBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  NewSelfHPDynamicMaterial:SetScalarParameterValue("PlayerHPBarpercent", 0)
  UIRoot.Image_NewSelfHP_Status:SetColorAndOpacity(self.NewHpBarColor_Value[3])
end
function PlayerInfoPanelMain:OnClose()
  self.CachedPlayerCharacter = nil
  if self.bLoaded then
    HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.GridPanel_Self)
  end
  local StateIconList = self.StateIconList
  for _, UI in pairs(StateIconList) do
    if UI then
      UI:Close()
    end
  end
  self.StateIconList = {}
end
function PlayerInfoPanelMain:InitStateIcons()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local PlayerInfoPanelStateConfig = GamePlayTools.GetCurrentConfig("PlayerInfoPanelStateConfig")
  if not PlayerInfoPanelStateConfig then
    return
  end
  for Index, Config in pairs(PlayerInfoPanelStateConfig) do
    if Config.UIConfig and UIManager.UI_Config_InGame[Config.UIConfig] then
      local StateIconUI = UIManager.ShowUI(UIManager.UI_Config_InGame[Config.UIConfig])
      self.UIRoot.VerticalBox_Status:AddChildAt(0, StateIconUI.UIRoot)
      StateIconUI:SetPadding(0, 5, 0, 0)
      StateIconUI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.StateIconList[Index] = StateIconUI
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PlayerInfoPanelMain)
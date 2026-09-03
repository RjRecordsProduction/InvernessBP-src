local SingleShootingTrainBattleUI = {nLastLeftTime = nil, bPauseUpdateCountDownPb = false}
local UGameplayStatics = import("GameplayStatics")
function SingleShootingTrainBattleUI:ctor()
end
function SingleShootingTrainBattleUI:OnInitialize()
  SingleShootingTrainBattleUI.__super.OnInitialize(self)
  self.ClientLogic = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
  self.util = require("client.slua_ui_framework.util")
  self:UpdateUI()
end
function SingleShootingTrainBattleUI:RegistEvents()
  SingleShootingTrainBattleUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_BEGIN, self.HandleShootingTrainBegin, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_UPDATE_WAVE, self.HandleUpdateWave, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_UPDATE_SCORE, self.HandleUpdateTarget, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_TARGET_MISS, self.HandleMissingTarget, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_SHOOTING_END, self.HandleShootingResult, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_UPDATE_INAREA_STAT, self.HandleUpdateInAreaWarning, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.HandleCloseBtn, self)
end
function SingleShootingTrainBattleUI:UpdateUI()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_Tips:SetText(DataMgr.GetMsgByID(20101))
end
function SingleShootingTrainBattleUI:SetWidgetVisibility(visible)
  self.UIRoot:SetWidgetVisibility(visible)
end
function SingleShootingTrainBattleUI:HandleShootingTrainBegin()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TrainSwitch:SetActiveWidgetIndex(0)
  local ClientLogic = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
  if self.ClientLogic then
    self:AddTimer(0, function()
      local leftTime = self.ClientLogic.GetBeginLeftTime()
      if 0 <= leftTime then
        self.UIRoot.TimeCountDownText:SetText(tostring(leftTime))
        if leftTime ~= self.nLastLeftTime then
          local sSound = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Count.Play_Target_Count"
          local audio_util = require("client.common.audio_util")
          audio_util.PlayAudio(sSound)
          self.nLastLeftTime = leftTime
        end
        coroutine.yield(0.2)
        self:HandleShootingTrainBegin()
      else
        self:HandleShootingTrainning()
      end
    end)
  end
end
function SingleShootingTrainBattleUI:HandleShootingTrainning()
  self.UIRoot.TrainSwitch:SetActiveWidgetIndex(1)
  self:Update()
  local sSound = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Count_Go.Play_Target_Count_Go"
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sSound)
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if slua.isValid(uPlayerController) then
    uPlayerController:CastUIMsg("UIMsg_ShowPointsRankDirectionMark", "ingame")
    local uTargetTrain = uPlayerController.TargetTrain
    if self.ClientLogic and uTargetTrain and slua.isValid(uTargetTrain) then
      uTargetTrain.CurrentCanDamagePart = self.ClientLogic.CurrentShootingScoreConfig.nCanDamagePart
      self:HandleUpdateInAreaWarning(nil, nil, uTargetTrain.InAreaID)
    end
  end
  log(bWriteLog and "UIMsg_ShowPointsRankDirectionMark")
end
function SingleShootingTrainBattleUI:Update()
  if self.ClientLogic == nil then
    log(bWriteLog and "ClientLogic is nil")
    return
  end
  local nUseTime = self.ClientLogic.GetHasUseTime()
  if nUseTime < 0 then
    return
  end
  if self.UIRoot.TrainSwitch:GetActiveWidgetIndex() ~= 1 then
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.UIRoot.UseTimeText:SetText(TimeUtil.FormatCountDownTime_MS(nUseTime))
  if self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.ReactionMode and self.bPauseUpdateCountDownPb == false then
    self.UIRoot.CountDownProgressBar:SetPercent(self.ClientLogic.GetTargetMissLeftTimeRate())
  end
  self:AddTimer(0.1, function()
    self:Update()
  end)
end
function SingleShootingTrainBattleUI:HandleUpdateTarget()
  log(bWriteLog and "SingleShootingTrainBattleUI HandleUpdateTarget")
  if self.ClientLogic == nil then
    return
  end
  log(bWriteLog and "SingleShootingTrainBattleUI HandleUpdateTarget" .. self.ClientLogic.GetCurrentSelectTrainMode())
  if self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.NormalMode then
    local nCurrentWave, nTotalWave = self.ClientLogic.GetWaveProcess()
    self.UIRoot.TotalTargetText:SetText(tostring(nCurrentWave) .. "/" .. tostring(nTotalWave))
    self.UIRoot.ModeSwitch:SetActiveWidgetIndex(0)
  elseif self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.ReactionMode then
    self.UIRoot.ModeSwitch:SetActiveWidgetIndex(1)
    self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.HitStateSwitch:SetActiveWidgetIndex(0)
    self:RefreshReactionData()
  end
end
function SingleShootingTrainBattleUI:HandleUpdateWave(EventType, EventID, TargetLocation)
  log(bWriteLog and "SingleShootingTrainBattleUI HandleUpdateWave x:" .. tostring(TargetLocation.X) .. "y:" .. tostring(TargetLocation.Y) .. "z:" .. tostring(TargetLocation.Z))
  if self.ClientLogic == nil then
    return
  end
  log(bWriteLog and "SingleShootingTrainBattleUI HandleUpdateTarget" .. self.ClientLogic.GetCurrentSelectTrainMode())
  self.UIRoot.CircleArrowUIBP.TargetLoc = TargetLocation
  if self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.NormalMode then
    self:HandleUpdateTarget()
  elseif self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.ReactionMode then
    self.UIRoot.ModeSwitch:SetActiveWidgetIndex(1)
    self.UIRoot.CountDownProgressBar:SetPercent(self.ClientLogic.GetTargetMissLeftTimeRate())
    self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TotalTargetText:SetText(tostring(self.ClientLogic.GetCurrentScore()))
    self.UIRoot.LeftTargetCount:SetText(DataMgr.GetFormatMsgByIDForBattleText(34807, self.ClientLogic.GetLeftTargetsNumber()))
    self.UIRoot.ContinuousKnockText:SetText(DataMgr.GetFormatMsgByIDForBattleText(34806, self.ClientLogic.nContinuousKnock))
    self.bPauseUpdateCountDownPb = false
  end
end
function SingleShootingTrainBattleUI:HandleMissingTarget()
  log(bWriteLog and "SingleShootingTrainBattleUI HandleMissingTarget")
  if self.ClientLogic == nil then
    return
  end
  log(bWriteLog and "SingleShootingTrainBattleUI HandleUpdateTarget" .. self.ClientLogic.GetCurrentSelectTrainMode())
  if self.ClientLogic.GetCurrentSelectTrainMode() == self.ClientLogic.ModeType.ReactionMode then
    self.UIRoot.ModeSwitch:SetActiveWidgetIndex(1)
    self.UIRoot.HitStateSwitch:SetActiveWidgetIndex(1)
    self.UIRoot.CountDownProgressBar:SetPercent(0)
    self:RefreshReactionData()
  end
end
function SingleShootingTrainBattleUI:RefreshReactionData()
  self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TotalTargetText:SetText(tostring(self.ClientLogic.GetCurrentScore()))
  self.UIRoot.ContinuousKnockText:SetText(DataMgr.GetFormatMsgByIDForBattleText(34806, self.ClientLogic.nContinuousKnock))
  self.bPauseUpdateCountDownPb = true
end
function SingleShootingTrainBattleUI:HandleShootingResult()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SingleShootingTrainBattleUI:HandleCloseBtn()
  self:PlayAudio(sound_config.click_v1)
  if self.ClientLogic and self.ClientLogic.GetCurrentSelectTrainMode() ~= 0 and UIManager then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI, 34915, function()
      self.ClientLogic.ReqCancel()
    end)
  end
end
function SingleShootingTrainBattleUI:HandleUpdateInAreaWarning(eventType, eventid, InAreaID)
  log(bWriteLog and "HandleUpdateInAreaWarning:" .. tostring(InAreaID))
  if InAreaID then
    if InAreaID == self.ClientLogic.nInAreaID then
      self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSingleShootingTrainBattleUI = class(ui_base, nil, SingleShootingTrainBattleUI)
return CSingleShootingTrainBattleUI
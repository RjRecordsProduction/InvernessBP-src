local SingleTrainThrowBombHudUI = {
  waveStartTime = 0,
  currentWave = nil,
  waveSoundManager = nil
}
local UGameplayStatics = import("GameplayStatics")
local SoundUtils = require("GameLua.Mod.SingleTraining.Client.SoundUtils")
function SingleTrainThrowBombHudUI:ctor()
end
function SingleTrainThrowBombHudUI:OnInitialize()
  SingleTrainThrowBombHudUI.__super.OnInitialize(self)
  print(bWriteLog and "SingleTrainThrowBombHudUI-OnInitialize")
  self.util = require("client.slua_ui_framework.util")
  self:UpdateUI()
  if self.UIRoot.Panel_Tips_01 ~= nil then
    self.UIRoot.Panel_Tips_01:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self.isEnd = false
  self.isPlaySound = false
  self.lastWaveSoundPlayed = false
  self.waveSoundManager = {}
end
function SingleTrainThrowBombHudUI:RegistEvents()
  SingleTrainThrowBombHudUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_ThrowBCountDown, self.HandleThrowBombCountDown, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_ThrowBProgress, self.PlayingUpdateProcess, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_ThrowBombResult, self.HandleShootingResult, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_UPDATE_INAREA_STAT, self.HandleUpdateInAreaWarning, self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_ThrowBombKillOne, self.HandleKillOne, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.ConfirmCloseButton, self)
  self:SetZOrder(600)
end
function SingleTrainThrowBombHudUI:UpdateUI()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_Tips:SetText(DataMgr.GetMsgByID(34630))
end
function SingleTrainThrowBombHudUI:SetWidgetVisibility(visible)
  self.UIRoot:SetWidgetVisibility(visible)
end
function SingleTrainThrowBombHudUI:Close()
  SoundUtils.PlayCloseAudio()
  SingleTrainThrowBombHudUI.__super.Close(self)
end
function SingleTrainThrowBombHudUI:HandleThrowBombCountDown(eventType, eventid, tEventData)
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TrainSwitch:SetActiveWidgetIndex(0)
  if tEventData.countDownTime == nil then
    print(bWriteLog and "tEventData.countDownTime  == nil")
  end
  self.isEnd = false
  self.isPlaySound = false
  self.lastWaveSoundPlayed = false
  self.lastKillWaveTimeStamp = 0
  self:ReadyToPlayCountDown(tEventData.countDownTime, tEventData.maxWaves)
  self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.waveSoundManager = {}
  for i = 1, tEventData.maxWaves do
    self.waveSoundManager[i] = 0
  end
  log_tree("self.waveSoundManager", self.waveSoundManager)
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  uPlayerController:CastUIMsg("UIMsg_ShowPointsRankDirectionMark", "ingame")
  local uTargetTrain = uPlayerController.TargetTrain
  if uTargetTrain and slua.isValid(uTargetTrain) then
    self:HandleUpdateInAreaWarning(nil, nil, uTargetTrain.InAreaID)
  end
end
function SingleTrainThrowBombHudUI:ReadyToPlayCountDown(leftTime, maxWaves)
  if leftTime <= 0 then
    self.UIRoot.TextBlock_CountDown:SetText("0")
    self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:PlayingUpdateProcess(nil, nil, {
      currentWave = 1,
      maxWaves = maxWaves,
      score = 0,
      leftTime = 0
    })
    return
  end
  SoundUtils.PlayCountDown()
  self.UIRoot.TextBlock_CountDown:SetText(tostring(math.floor(leftTime)))
  self:AddTimer(1, function()
    self:ReadyToPlayCountDown(leftTime - 1, maxWaves)
  end)
end
function SingleTrainThrowBombHudUI:HandleKillOne(eventType, eventid, targetIdx)
  print(bWriteLog and "==============~~~~~~~~~~~~SoundMiss0000 kill one~~~~~~~~=======================")
  self.lastWaveSoundPlayed = true
  self.isEnd = true
  self:RemoveAllTimer()
  self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.HitStateSwitch:SetActiveWidgetIndex(0)
  self.waveSoundManager[self.currentWave] = self.waveSoundManager[self.currentWave] + 10
  SoundUtils.PlayAddScore()
  self.lastKillWaveTimeStamp = os.time()
end
function SingleTrainThrowBombHudUI:PlayingUpdateProcess(eventType, eventid, tEventData)
  self.isEnd = false
  self:RemoveAllTimer()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TrainSwitch:SetActiveWidgetIndex(1)
  if tEventData.currentWave ~= nil and tEventData.maxWaves ~= nil then
    self.UIRoot.TotalTargetText:SetText(LocUtil.LocalizeResFormat(34607, tEventData.currentWave, tEventData.maxWaves))
  end
  self.currentWave = tEventData.currentWave
  if tEventData.currentWave == 1 and self.isPlaySound == false then
    SoundUtils.PlayStartAudio()
    self.isPlaySound = true
  end
  self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if tEventData.currentWave ~= 1 and self.waveSoundManager[tEventData.currentWave - 1] == 0 and os.time() - self.lastKillWaveTimeStamp > 3 then
    self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.HitStateSwitch:SetActiveWidgetIndex(1)
    SoundUtils.SoundMiss()
    self:AddTimer(0.2, function()
      self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
  else
    self.lastWaveSoundPlayed = false
  end
  if tEventData.score ~= nil and self.UIRoot.UseTimeText ~= nil then
    self.UIRoot.UseTimeText:SetText(LocUtil.LocalizeResFormat(34654, math.ceil(tEventData.score)))
  end
  if tEventData.leftTime ~= nil then
    local UIUtil = require("client.common.ui_util")
    local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
    self.waveStartTime = uGameState:GetServerWorldTimeSeconds()
    self.UIRoot.CountDownProgressBar:SetPercent(1.0)
    self:UpdateProcessBar(tEventData.currentWave, tEventData.leftTime, 0)
  end
end
function SingleTrainThrowBombHudUI:UpdateProcessBar(currentWave, TotalTime, sumTime)
  local ProgressPercent = 0.0
  if 0 < TotalTime - sumTime then
    ProgressPercent = math.max((TotalTime - sumTime) / TotalTime, 0)
    self.UIRoot.CountDownProgressBar:SetPercent(ProgressPercent)
    local starTime = self.waveStartTime
    self:AddTimer(0.5, function()
      local UIUtil = require("client.common.ui_util")
      local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
      sumTime = uGameState:GetServerWorldTimeSeconds() - starTime
      self:UpdateProcessBar(currentWave, TotalTime, sumTime)
    end)
  else
    ProgressPercent = 1.0
    self.UIRoot.CountDownProgressBar:SetPercent(ProgressPercent)
  end
end
function SingleTrainThrowBombHudUI:HandleShootingResult()
  if self.lastWaveSoundPlayed == false then
    print(bWriteLog and "SoundMiss004 end")
    self.lastWaveSoundPlayed = true
    self.UIRoot.HitStateSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.HitStateSwitch:SetActiveWidgetIndex(1)
    SoundUtils.SoundMiss()
  end
  self.isEnd = true
  self:RemoveAllTimer()
  self.UIRoot.TrainSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  log_tree("final self.waveSoundManager", self.waveSoundManager)
end
function SingleTrainThrowBombHudUI:HandleUpdateInAreaWarning(eventType, eventid, InAreaID)
  log(bWriteLog and "HandleUpdateInAreaWarning:" .. tostring(InAreaID))
  if InAreaID then
    local ShootingLogic = require("GameLua.Mod.SingleTraining.Client.Bomb.singleTrainingThrowBombLogicClient")
    if ShootingLogic and ShootingLogic.InAreaID == InAreaID then
      self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self.UIRoot.Panel_Caveat_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SingleTrainThrowBombHudUI:ConfirmCloseButton()
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI, 34915, function()
      self:OnClickClose()
    end)
  end
end
function SingleTrainThrowBombHudUI:OnClickClose()
  SoundUtils.PlayCloseAudio()
  local ShootingLogic = require("GameLua.Mod.SingleTraining.Client.Bomb.singleTrainingThrowBombLogicClient")
  ShootingLogic:ReqTrainingEnd()
  self.lastWaveSoundPlayed = true
  self:HandleShootingResult()
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_END)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSingleTrainThrowBombHudUI = class(ui_base, nil, SingleTrainThrowBombHudUI)
return CSingleTrainThrowBombHudUI
local SingleTrainingShootClientLogic = {
  ModeType = {NormalMode = 1, ReactionMode = 2},
  NormalDiffiCultyToConfig = {
    [1] = 2,
    [2] = 3,
    [3] = 4
  },
  ReactionDiffiCultyToConfig = {
    [1] = 5,
    [2] = 6,
    [3] = 7
  },
  uPlayer = nil,
  tNormalDefaultSetting = nil,
  tReactionDefaultSetting = nil,
  tCustomSetting = {},
  TargetHasDown = {},
  TimerTable = {},
  CurrentSelectNormalDifficulty = 1,
  CurrentShootingScoreConfig = nil,
  TargetArray = {},
  CurrentWave = 0,
  nCurrentModeSelect = 0,
  nStartTrainTime = 0,
  nShootCountdown = 5,
  TotalKnockDown = 0,
  nTotalNeedKnockDownTargets = 0,
  nContinuousKnock = 0,
  nMissNumber = 0,
  nTargetMissTime = 0,
  nInAreaID = 2
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
function SingleTrainingShootClientLogic.SelectTrainMode(nInMode)
  SingleTrainingShootClientLogic.nCurrentModeSelect = nInMode
end
function SingleTrainingShootClientLogic.GetCurrentSelectTrainMode()
  return SingleTrainingShootClientLogic.nCurrentModeSelect
end
function SingleTrainingShootClientLogic.GetWaveProcess()
  return SingleTrainingShootClientLogic.CurrentWave, #SingleTrainingShootClientLogic.CurrentShootingScoreConfig.WaveInfoMap
end
function SingleTrainingShootClientLogic.GetCurrentGameStateTime()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance()) or CGameState
  if slua.isValid(uGameState) then
    local nCurrentTime = uGameState:GetServerWorldTimeSeconds()
    return nCurrentTime
  end
  return 0
end
function SingleTrainingShootClientLogic.GetTargetMissLeftTimeRate()
  local nCurrentTime = SingleTrainingShootClientLogic.GetCurrentGameStateTime()
  local nLeft = SingleTrainingShootClientLogic.nTargetMissTime - nCurrentTime
  return nLeft / SingleTrainingShootClientLogic.CurrentShootingScoreConfig.nWaveLifeTime
end
function SingleTrainingShootClientLogic.InitDefaulCustomSetting(nTableID)
  local TableInfo = CDataTable.GetTableData("ShootingScoreTargetConfigTable", nTableID)
  if TableInfo == nil then
    return nil
  end
  local tDefaultSetting = {}
  tDefaultSetting.nTotalWaveNum = 0
  tDefaultSetting.tUseTargets = nil
  tDefaultSetting.nHp = nil
  tDefaultSetting.nMoveSpeed = nil
  for nWaveIndex = 1, 10 do
    local nWaveID = TableInfo["WaveIndex" .. tostring(nWaveIndex)]
    if nWaveID and 0 < nWaveID then
      tDefaultSetting.nTotalWaveNum = tDefaultSetting.nTotalWaveNum + 1
      if tDefaultSetting.tUseTargets == nil then
        local tWaveInfo = CDataTable.GetTableData("ShootingScoreWaveConfigTable", nWaveID)
        if tWaveInfo then
          tDefaultSetting.tUseTargets = {}
          for nTargetIndex = 1, 7 do
            local strTargetIndex = tostring(nTargetIndex)
            if tWaveInfo["TargetOpenState" .. strTargetIndex] and tWaveInfo["TargetOpenState" .. strTargetIndex] == 1 then
              tDefaultSetting.tUseTargets[nTargetIndex] = true
              if tDefaultSetting.nHP == nil then
                tDefaultSetting.nHP = tWaveInfo["TargetHp" .. strTargetIndex]
              end
              if tDefaultSetting.nMoveSpeed == nil then
                tDefaultSetting.nMoveSpeed = tWaveInfo["TargetMoveSpeed" .. strTargetIndex]
              end
              if tDefaultSetting.nHelmetValue == nil then
                tDefaultSetting.nHelmetValue = tWaveInfo["TargetHelmetValue" .. strTargetIndex]
              end
              if tDefaultSetting.nArmorValue == nil then
                tDefaultSetting.nArmorValue = tWaveInfo["TargetArmorValue" .. strTargetIndex]
              end
            end
          end
        end
      end
    end
  end
  tDefaultSetting.nCanDamagePart = TableInfo.CanDamagePart
  tDefaultSetting.nTotalTargetsNum = TableInfo.TotaleShootingNumber
  tDefaultSetting.nWaveLiftTime = TableInfo.WaveLiftTime
  log_tree("InitDefaulCustomSetting", tDefaultSetting)
  return tDefaultSetting
end
function SingleTrainingShootClientLogic.InitCustomizeSetting(inSetting)
  if inSetting == nil then
    return
  end
  SingleTrainingShootClientLogic.tCustomSetting = inSetting
end
function SingleTrainingShootClientLogic.GetParamValue(nID)
  local tTableInfo = CDataTable.GetTableData("TrainingBaseInfoCFG", nID)
  if tTableInfo == nil then
    return 0
  else
    return tTableInfo.value
  end
end
function SingleTrainingShootClientLogic.GetCustomSettingConfig(nCaseID)
  local nModeType = SingleTrainingShootClientLogic.nCurrentModeSelect
  log(bWriteLog and "GetCustomSettingConfig ModeType:" .. tostring(nModeType) .. ", case id:" .. tostring(nCaseID))
  if SingleTrainingShootClientLogic.tCustomSetting[nModeType] and SingleTrainingShootClientLogic.tCustomSetting[nModeType][nCaseID] then
    local TableUtil = require("common.table_util")
    return TableUtil.CopyTable(SingleTrainingShootClientLogic.tCustomSetting[nModeType][nCaseID])
  elseif nModeType == SingleTrainingShootClientLogic.ModeType.NormalMode then
    if SingleTrainingShootClientLogic.tNormalDefaultSetting == nil then
      SingleTrainingShootClientLogic.tNormalDefaultSetting = SingleTrainingShootClientLogic.InitDefaulCustomSetting(SingleTrainingShootClientLogic.NormalDiffiCultyToConfig[2])
    end
    local TableUtil = require("common.table_util")
    return TableUtil.CopyTable(SingleTrainingShootClientLogic.tNormalDefaultSetting)
  elseif nModeType == SingleTrainingShootClientLogic.ModeType.ReactionMode then
    if SingleTrainingShootClientLogic.tReactionDefaultSetting == nil then
      SingleTrainingShootClientLogic.tReactionDefaultSetting = SingleTrainingShootClientLogic.InitDefaulCustomSetting(SingleTrainingShootClientLogic.ReactionDiffiCultyToConfig[2])
    end
    local TableUtil = require("common.table_util")
    return TableUtil.CopyTable(SingleTrainingShootClientLogic.tReactionDefaultSetting)
  end
end
function SingleTrainingShootClientLogic.StoreCustomSettingConfig(nModeType, nCaseID, tCase)
  if SingleTrainingShootClientLogic.tCustomSetting[nModeType] == nil then
    SingleTrainingShootClientLogic.tCustomSetting[nModeType] = {}
  end
  SingleTrainingShootClientLogic.tCustomSetting[nModeType][nCaseID] = tCase
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.save_custom_setting(SingleTrainingShootClientLogic.tCustomSetting, "", 1, 2)
end
function SingleTrainingShootClientLogic.GetCurrentScore()
  return SingleTrainingShootClientLogic.TotalKnockDown * 5
end
function SingleTrainingShootClientLogic.GetLeftTargetsNumber()
  return SingleTrainingShootClientLogic.nTotalNeedKnockDownTargets - SingleTrainingShootClientLogic.TotalKnockDown - SingleTrainingShootClientLogic.nMissNumber
end
function SingleTrainingShootClientLogic.InitStartTime()
  local nCurrentTime = SingleTrainingShootClientLogic.GetCurrentGameStateTime()
  SingleTrainingShootClientLogic.nStartTrainTime = nCurrentTime + SingleTrainingShootClientLogic.nShootCountdown
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  ShootingTrainTool.SetActorsStatByTag(SingleTrainingShootClientLogic.uPlayer, false, "ShootingHidden")
end
function SingleTrainingShootClientLogic.CaculateTotalNeedKnockDownTargets()
  SingleTrainingShootClientLogic.nTotalNeedKnockDownTargets = 0
  for index, value in ipairs(SingleTrainingShootClientLogic.CurrentShootingScoreConfig.WaveInfoMap) do
    SingleTrainingShootClientLogic.nTotalNeedKnockDownTargets = SingleTrainingShootClientLogic.nTotalNeedKnockDownTargets + #value
  end
end
function SingleTrainingShootClientLogic.GetCurrentDifficultyInfo(nDifficulty)
  local TableID
  if SingleTrainingShootClientLogic.nCurrentModeSelect == SingleTrainingShootClientLogic.ModeType.NormalMode then
    TableID = SingleTrainingShootClientLogic.NormalDiffiCultyToConfig[nDifficulty]
  elseif SingleTrainingShootClientLogic.nCurrentModeSelect == SingleTrainingShootClientLogic.ModeType.ReactionMode then
    TableID = SingleTrainingShootClientLogic.ReactionDiffiCultyToConfig[nDifficulty]
  end
  if TableID == nil then
    return ""
  end
  local TableInfo = CDataTable.GetTableData("ShootingScoreTargetConfigTable", TableID)
  if TableInfo == nil then
    return ""
  end
  if TableInfo.DefaultDescID == nil or TableInfo.DefaultDescID == 0 then
    return ""
  end
  return LocUtil.LocalizeResFormat(TableInfo.DefaultDescID, TableInfo.DefaultDescParam1, TableInfo.DefaultDescParam2, TableInfo.DefaultDescParam3, TableInfo.DefaultDescParam4, TableInfo.DefaultDescParam5)
end
function SingleTrainingShootClientLogic.InitTargetArray()
  SingleTrainingShootClientLogic.TargetArray = {}
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if SingleTrainingShootClientLogic.uPlayer then
    SingleTrainingShootClientLogic.TargetArray = ShootingTrainTool.GetTargetArrayByContainer(SingleTrainingShootClientLogic.uPlayer)
    log(bWriteLog and "target length:" .. tostring(#SingleTrainingShootClientLogic.TargetArray))
  else
    log(bWriteLog and "Player is nil")
  end
end
function SingleTrainingShootClientLogic.CheckValid()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if uPlayerController == nil then
    log(bWriteLog and "uPlayerController is nil")
    return nil
  end
  local uPlayer
  if uPlayerController and slua.isValid(uPlayerController) then
    local uBaseCharacter = uPlayerController:GetPlayerCharacterSafety()
    if uBaseCharacter then
      uPlayer = uBaseCharacter
    end
  end
  if uPlayer == nil then
    log(bWriteLog and "BeginTrain player is nil")
    return nil
  end
  SingleTrainingShootClientLogic.SucessEnd = false
  SingleTrainingShootClientLogic.Clear()
  SingleTrainingShootClientLogic.  return tonumber(uPlayer:GetPlayerKey())
end
function SingleTrainingShootClientLogic.GetBeginLeftTime()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  local nCurrentTime = uGameState:GetServerWorldTimeSeconds()
  return math.floor(SingleTrainingShootClientLogic.nStartTrainTime - nCurrentTime + 0.5)
end
function SingleTrainingShootClientLogic.GetHasUseTime()
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  local nCurrentTime = uGameState:GetServerWorldTimeSeconds()
  return math.floor(nCurrentTime - SingleTrainingShootClientLogic.nStartTrainTime)
end
function SingleTrainingShootClientLogic.HandleCustomizeBegin(tInSetting)
  if tInSetting == nil then
    return
  end
  local tOpenTargets = {}
  for key, value in pairs(tInSetting.tUseTargets) do
    if value then
      table.insert(tOpenTargets, #tOpenTargets + 1, key)
    end
  end
  log_tree("HandleCustomizeBegin", tInSetting)
  if SingleTrainingShootClientLogic.nCurrentModeSelect == SingleTrainingShootClientLogic.ModeType.NormalMode then
    SingleTrainingShootClientLogic.NormalCustomShootingBegin(tOpenTargets, tInSetting.nMoveSpeed, tInSetting.nHP, tInSetting.nHelmetValue, tInSetting.nArmorValue, tInSetting.nCanDamagePart, tInSetting.nTotalWaveNum, 600)
  elseif SingleTrainingShootClientLogic.nCurrentModeSelect == SingleTrainingShootClientLogic.ModeType.ReactionMode then
    SingleTrainingShootClientLogic.ReactionCustomShootingBegin(tOpenTargets, tInSetting.nHP, tInSetting.nHelmetValue, tInSetting.nArmorValue, tInSetting.nCanDamagePart, tInSetting.nWaveLiftTime, tInSetting.nTotalTargetsNum)
  end
end
function SingleTrainingShootClientLogic.NormalDefaultShootingBegin(Difficulty)
  log(bWriteLog and "NormalDefaultShootingBegin")
  local nPlayerKey = SingleTrainingShootClientLogic.CheckValid()
  if nPlayerKey == nil then
    return
  end
  if SingleTrainingShootClientLogic.NormalDiffiCultyToConfig[Difficulty] == nil then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not uPlayerController:CheckCanStartBasicTraining(SingleTrainingConfig.AITrainingMode.ShootTraining) then
    print(bWriteLog and "SingleTrainingShootClientLogic.NormalDefaultShootingBegin CheckCanStartBasicTraining is False")
    return
  end
  SingleTrainingShootClientLogic.IsReactionMode = false
  SingleTrainingShootClientLogic.CurrentSelectNormal  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = nil
  local ShootingScoreClass = require("GameLua.Mod.Library.GamePlay.Shooting.ShootingScoreTargetConfig")
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = ShootingScoreClass()
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig:InitByTable(SingleTrainingShootClientLogic.NormalDiffiCultyToConfig[Difficulty])
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_normal_shooting_train_default", {
    Difficulty = SingleTrainingShootClientLogic.CurrentSelectNormalDifficulty,
    PlayerKey = nPlayerKey
  })
end
function SingleTrainingShootClientLogic.NormalCustomShootingBegin(tOpenTarges, nMoveSpeed, nHP, nHemletValue, nArmorValue, nCanDamagePart, nWaveNum, nTrainTime)
  log(bWriteLog and "NormalCustomShootingBegin")
  local nPlayerKey = SingleTrainingShootClientLogic.CheckValid()
  if nPlayerKey == nil then
    return
  end
  if nWaveNum <= 0 or nTrainTime <= 0 then
    return
  end
  if tOpenTarges == nil or #tOpenTarges <= 0 then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not uPlayerController:CheckCanStartBasicTraining(SingleTrainingConfig.AITrainingMode.ShootTraining) then
    print(bWriteLog and "SingleTrainingShootClientLogic.NormalCustomShootingBegin CheckCanStartBasicTraining is False")
    return
  end
  SingleTrainingShootClientLogic.IsReactionMode = false
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = nil
  local ShootingScoreClass = require("GameLua.Mod.Library.GamePlay.Shooting.ShootingScoreTargetConfig")
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = ShootingScoreClass()
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig:InitNormalByUserSetting(tOpenTarges, nMoveSpeed, nHP, nHemletValue, nArmorValue, nCanDamagePart, nWaveNum, nTrainTime)
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_normal_shooting_train_custom", {
    PlayerKey = nPlayerKey,
    UseTargetArray = tOpenTarges,
    MoveSpeed = nMoveSpeed,
    Hp = nHP,
    TargetHelmetValue = nHemletValue,
    TargetArmorValue = nArmorValue,
    CanDamagePart = nCanDamagePart,
    WaveNum = nWaveNum,
    TotalTime = nTrainTime
  })
end
function SingleTrainingShootClientLogic.ReactionDefaultShootingBegin(Difficulty)
  log(bWriteLog and "ReactionDefaultShootingBegin")
  local nPlayerKey = SingleTrainingShootClientLogic.CheckValid()
  if nPlayerKey == nil then
    return
  end
  if SingleTrainingShootClientLogic.ReactionDiffiCultyToConfig[Difficulty] == nil then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not uPlayerController:CheckCanStartBasicTraining(SingleTrainingConfig.AITrainingMode.ShootTraining) then
    print(bWriteLog and "SingleTrainingShootClientLogic.ReactionDefaultShootingBegin CheckCanStartBasicTraining is False")
    return
  end
  SingleTrainingShootClientLogic.IsReactionMode = true
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = nil
  local ShootingScoreClass = require("GameLua.Mod.Library.GamePlay.Shooting.ShootingScoreTargetConfig")
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = ShootingScoreClass()
  local tRandomTargets = SingleTrainingShootClientLogic.CurrentShootingScoreConfig:InitReactionByTable(SingleTrainingShootClientLogic.ReactionDiffiCultyToConfig[Difficulty])
  log_tree("client ShootingScoreConfig", SingleTrainingShootClientLogic.CurrentShootingScoreConfig.WaveInfoMap)
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_reaction_shooting_train_default", {
    Difficulty = Difficulty,
    PlayerKey = nPlayerKey,
    RandomTarget = tRandomTargets
  })
end
function SingleTrainingShootClientLogic.ReactionCustomShootingBegin(tOpenTarges, nHP, nHemletValue, nArmorValue, nCanDamagePart, nWaveLifeTime, nTotalTargetNum)
  log(bWriteLog and "ReactionCustomShootingBegin")
  local nPlayerKey = SingleTrainingShootClientLogic.CheckValid()
  if nPlayerKey == nil then
    return
  end
  if nWaveLifeTime <= 0 or nTotalTargetNum <= 0 then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not uPlayerController:CheckCanStartBasicTraining(SingleTrainingConfig.AITrainingMode.ShootTraining) then
    print(bWriteLog and "SingleTrainingShootClientLogic.ReactionCustomShootingBegin CheckCanStartBasicTraining is False")
    return
  end
  SingleTrainingShootClientLogic.IsReactionMode = true
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = nil
  local ShootingScoreClass = require("GameLua.Mod.Library.GamePlay.Shooting.ShootingScoreTargetConfig")
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig = ShootingScoreClass()
  local tRandomTargets = SingleTrainingShootClientLogic.CurrentShootingScoreConfig:GetRandomTargets(tOpenTarges, nTotalTargetNum)
  log_tree("tRandomTargets", tRandomTargets)
  SingleTrainingShootClientLogic.CurrentShootingScoreConfig:InitReactionByUserSetting(tRandomTargets, nHP, nHemletValue, nArmorValue, nCanDamagePart, nWaveLifeTime)
  log_tree("client ShootingScoreConfig", SingleTrainingShootClientLogic.CurrentShootingScoreConfig.WaveInfoMap)
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_reaction_shooting_train_custom", {
    PlayerKey = nPlayerKey,
    Hp = nHP,
    TargetHelmetValue = nHemletValue,
    TargetArmorValue = nArmorValue,
    CanDamagePart = nCanDamagePart,
    WaveLifeTime = nWaveLifeTime,
    RandomTarget = tRandomTargets
  })
end
function SingleTrainingShootClientLogic.OnDSEnterThrowShootTraining()
  SingleTrainingShootClientLogic.InitStartTime()
  SingleTrainingShootClientLogic.InitTargetArray()
  if SingleTrainingShootClientLogic.IsReactionMode then
    SingleTrainingShootClientLogic.CaculateTotalNeedKnockDownTargets()
  end
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_START)
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_BEGIN)
  SingleTrainingShootClientLogic.StartCheckWaveTick(10)
end
function SingleTrainingShootClientLogic.UpdateWave(message)
  log_tree("single train UpdateWave:", message)
  SingleTrainingShootClientLogic.CurrentWave = message.WaveIndex
  SingleTrainingShootClientLogic.nMissNumber = message.MissNumber or 0
  if not SingleTrainingShootClientLogic.CurrentShootingScoreConfig then
    return
  end
  local CurrentWaveInfo = SingleTrainingShootClientLogic.CurrentShootingScoreConfig:GetWaveData(message.WaveIndex)
  if CurrentWaveInfo == nil then
    return
  end
  log_tree("UpdateMave CurrentWave", CurrentWaveInfo)
  for index = 1, #SingleTrainingShootClientLogic.TargetArray do
    local ScoreTarget = SingleTrainingShootClientLogic.TargetArray[index]
    if slua.isValid(ScoreTarget) then
      ScoreTarget:SetActorHiddenInGame(true)
    end
  end
  local TotalVector = FVector(0, 0, 0)
  local nNum = 0
  for index = 1, #CurrentWaveInfo do
    local TargetInfo = CurrentWaveInfo[index]
    local ScoreTarget = SingleTrainingShootClientLogic.TargetArray[TargetInfo.Index]
    if slua.isValid(ScoreTarget) then
      ScoreTarget:ShowUp(TargetInfo.MoveSpeed)
      nNum = nNum + 1
      TotalVector = TotalVector + ScoreTarget:K2_GetActorLocation()
    end
  end
  local AverateLocation = TotalVector / nNum
  SingleTrainingShootClientLogic.nTargetMissTime = SingleTrainingShootClientLogic.GetCurrentGameStateTime() + SingleTrainingShootClientLogic.CurrentShootingScoreConfig.nWaveLifeTime
  SingleTrainingShootClientLogic.TargetHasDown = {}
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_UPDATE_WAVE, AverateLocation)
end
function SingleTrainingShootClientLogic.StartCheckWaveTick(nDelayTime)
  local time_ticker = require("common.time_ticker")
  local ReqWaveHandle
  ReqWaveHandle = time_ticker.AddTimer(nDelayTime, function()
    if SingleTrainingShootClientLogic.CurrentWave == 0 then
      SingleTrainingShootClientLogic.ReqWave()
      SingleTrainingShootClientLogic.TimerTable[ReqWaveHandle] = nil
    else
      SingleTrainingShootClientLogic.TimerTable[ReqWaveHandle] = nil
    end
  end)
  SingleTrainingShootClientLogic.TimerTable[ReqWaveHandle] = true
end
function SingleTrainingShootClientLogic.ReqWave()
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_shooting_train_req_wave", {WaveIndex = 1})
  SingleTrainingShootClientLogic.StartCheckWaveTick(5)
end
function SingleTrainingShootClientLogic.HandleTargetDead(message)
  log_tree("single train HandleTargetDead:", message)
  SingleTrainingShootClientLogic.TotalKnockDown = message.TotalKnockDown
  SingleTrainingShootClientLogic.nContinuousKnock = message.ContinuousKnock
  SingleTrainingShootClientLogic.nMissNumber = message.MissingNum or 0
  local ScoreTarget = SingleTrainingShootClientLogic.TargetArray[message.DeadTargetIndex]
  if ScoreTarget then
    ScoreTarget:SetUpOrDown(false)
    ScoreTarget:SetActorHiddenInGame(true)
  end
  if SingleTrainingShootClientLogic.ShootingScoreConfig and SingleTrainingShootClientLogic.ShootingScoreConfig:GetWaveData(SingleTrainingShootClientLogic.CurrentWave + 1) == nil then
    local AllDown = true
    for key, value in pairs(SingleTrainingShootClientLogic.TargetArray) do
      if value.bIsUp then
        AllDown = false
      end
    end
    if AllDown then
      local time_ticker = require("common.time_ticker")
      local ReqEndHandle
      ReqEndHandle = time_ticker.AddTimer(5, function()
        if SingleTrainingShootClientLogic.SucessEnd == false then
          SingleTrainingShootClientLogic.ReqShootingEnd()
          SingleTrainingShootClientLogic.TimerTable[ReqEndHandle] = nil
        else
          SingleTrainingShootClientLogic.TimerTable[ReqEndHandle] = nil
        end
      end)
      log(bWriteLog and "UpdateScore handle:" .. ReqEndHandle)
    end
  end
  if SingleTrainingShootClientLogic.TargetHasDown[message.DeadTargetIndex] == nil then
    local sSound = "/Game/Mod/EvoBase/WwiseEvent/Play_Target_Score_1.Play_Target_Score_1"
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(sSound)
    SingleTrainingShootClientLogic.TargetHasDown[message.DeadTargetIndex] = true
  end
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_UPDATE_SCORE)
end
function SingleTrainingShootClientLogic.HandleKnockAllTargets(message)
  log_tree("HandleKnockAllTargets", message)
  for index = 1, #SingleTrainingShootClientLogic.TargetArray do
    local ScoreTarget = SingleTrainingShootClientLogic.TargetArray[index]
    if slua.isValid(ScoreTarget) then
      ScoreTarget:SetUpOrDown(false)
    end
  end
  if message.MissingNum and message.MissingNum > SingleTrainingShootClientLogic.nMissNumber then
    local sSound = "/Game/Mod/SocialIsland/WwiseEvent/Play_Target_Alarm.Play_Target_Alarm"
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(sSound)
  end
  SingleTrainingShootClientLogic.nMissNumber = message.MissingNum or 0
  SingleTrainingShootClientLogic.nContinuousKnock = 0
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_SHOOTING_TARGET_MISS)
end
function SingleTrainingShootClientLogic.HandleNormalResult(message)
  log_tree("single train HandleNormalResult:", message)
  SingleTrainingShootClientLogic.HandleEnd(message)
end
function SingleTrainingShootClientLogic.HandleReactionResult(message)
  log_tree("single train HandleReactionResult:", message)
  SingleTrainingShootClientLogic.HandleEnd(message)
end
function SingleTrainingShootClientLogic.HandleCancelSuccess(message)
  log_tree("single train HandleReactionResult:", message)
  SingleTrainingShootClientLogic.HandleEnd(nil)
end
function SingleTrainingShootClientLogic.ReqCancel()
  local nPlayerKey = SingleTrainingShootClientLogic.CheckValid()
  if nPlayerKey == nil then
    return
  end
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_shooting_req_cancel", {PlayerKey = nPlayerKey})
end
function SingleTrainingShootClientLogic.HandleEnd(resultData)
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  ShootingTrainTool.SetActorsStatByTag(SingleTrainingShootClientLogic.uPlayer, true, "ShootingHidden")
  SingleTrainingShootClientLogic.SucessEnd = true
  SingleTrainingShootClientLogic.tResultData = resultData
  SingleTrainingShootClientLogic.HandleKnockAllTargets({
    MissingNum = SingleTrainingShootClientLogic.nMissNumber
  })
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_SHOOTING_END, resultData)
  SingleTrainingShootClientLogic.nCurrentModeSelect = 0
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_END)
  SingleTrainingShootClientLogic.Clear()
end
function SingleTrainingShootClientLogic.ReqShootingEnd()
  local ds_net = require("ds_net")
  ds_net.SendMessage("single_shooting_req_end", {
    UID = SingleTrainingShootClientLogic.UID
  })
  local time_ticker = require("common.time_ticker")
  local ReqEndHandle
  ReqEndHandle = time_ticker.AddTimer(5, function()
    if SingleTrainingShootClientLogic.SucessEnd == false then
      SingleTrainingShootClientLogic.ReqShootingEnd()
      SingleTrainingShootClientLogic.TimerTable[ReqEndHandle] = nil
    else
      SingleTrainingShootClientLogic.TimerTable[ReqEndHandle] = nil
    end
  end)
  SingleTrainingShootClientLogic.TimerTable[ReqEndHandle] = true
end
function SingleTrainingShootClientLogic.Clear()
  local time_ticker = require("common.time_ticker")
  for key, value in pairs(SingleTrainingShootClientLogic.TimerTable) do
    time_ticker.RemoveTimer(key)
  end
  SingleTrainingShootClientLogic.TimerTable = {}
  SingleTrainingShootClientLogic.TotalKnockDown = 0
  SingleTrainingShootClientLogic.nMissNumber = 0
  SingleTrainingShootClientLogic.nContinuousKnock = 0
  SingleTrainingShootClientLogic.uPlayer = nil
end
return SingleTrainingShootClientLogic
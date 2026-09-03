local WonderfulPeriodSystem = {}
local EWonderfulType = UEnums.EWonderfulType
local UIUtil = require("client.common.ui_util")
local utility = require("common.utility")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local FWonderfulPeriodSubTypeInfo = import("/Script/ShadowTrackerExtra.WonderfulPeriodSubTypeInfo")
local EDamageType = import("EDamageType")
local ASTExtraShootWeapon = import("STExtraShootWeapon")
local BackpackUtils = import("BackpackUtils")
local USTExtraVehicleUtils = import("STExtraVehicleUtils")
local GrenadeBaseClass = import("STExtraGrenadeBase")
local ASSIST_SHORT_TIME = 3
local ASSIST_SHORT_DAMAGE = 30
local ASSIST_LONG_TIME = 10
local ASSIST_LONG_DAMAGE = 60
local LongPeriodTime = 120
local MaxPeriodTime = 180
local bDebugLog = true
local bEnableAssist = true
local DelayRecordTime = 2
function WonderfulPeriodSystem:OnInit()
  print(bWriteLog and "WonderfulPeriodSystem:OnInit", self.bHasRegist)
  if not self.bHasRegist then
    if Client then
      self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PERIOD_UPDATE, self.OnPeriodUpdate, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_FETCH_WONDERFULPERIOD, self.OnFetchWonderfulInfo, self)
      self:RegistStartRecordingEvent()
    else
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PAWN_GO_TO_NEAR_DEATH, self.OnNearDeath, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CHARACTER_DIED, self.OnCharacterDied, self)
      self:AddCommonEvent(EVENTTYPE_PLAYER, EVENTID_BEGIN_SEND_BATTLE_RESULT, self.OnHandleBeginSendBattleResult, self)
    end
    self.bHasRegist = true
  end
  if Client then
    self.PeriodInfo = {}
  else
    self.ValidKillRecord = {}
    self.ValidAssistRecord = {}
    self.WonderfulPeriodRecord = {}
    self.TlogRecord = {}
  end
  self.MaxPeriodStoreNum = 3
  if Client then
    self.bUseDetailTLog = true
    self.DetailTLogInfo = {}
    for i = 1, 15 do
      self.DetailTLogInfo[i] = {}
    end
    self.TLogID = {
      [1] = {
        [1] = 11043,
        [2] = 11044
      },
      [2] = {
        [1] = 11045,
        [2] = 11046
      },
      [3] = {
        [1] = 11047,
        [2] = 11048
      },
      [4] = {
        [1] = 11049,
        [2] = 11050
      },
      [5] = {
        [1] = 11051,
        [2] = 11052
      },
      [6] = {
        [1] = 11053,
        [2] = 11054
      },
      [7] = {
        [1] = 11055,
        [2] = 11056
      },
      [8] = {
        [1] = 11057,
        [2] = 11058
      },
      [9] = {
        [1] = 11059,
        [2] = 11060
      },
      [10] = {
        [1] = 11061,
        [2] = 11062
      }
    }
  end
end
function WonderfulPeriodSystem:RegistStartRecordingEvent()
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_ON_REP_PARACHUTE_STATE, self.OnRepParachuteState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PARACHUTING, EVENTID_CLIENT_PARACHUTE_STATE_CHANGE, self.OnClientParachuteStateChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_CLIENT_REPLAY_START_RECORDING, self.ClientInGameReplayStartRecording, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_CLIENT_REPLAY_STOP_RECORDING, self.ClientInGameReplayStopRecording, self)
end
function WonderfulPeriodSystem:OnRepParachuteState(_, _, ParachuteState)
  print(bWriteLog and "WonderfulPeriodSystem:OnRepParachuteState", ParachuteState)
  local EParachuteState = import("EParachuteState")
  if EParachuteState.PS_None == ParachuteState then
    self:ClientInGameReplayStartRecording()
  end
  if EParachuteState.PS_Opening == ParachuteState then
    if self.DelayRecordTimer then
      self:RemoveGameTimer(self.DelayRecordTimer)
      self.DelayRecordTimer = nil
      print(bWriteLog and "WonderfulPeriodSystem:OnRepParachuteState RemoveGameTimer")
    end
    self.DelayRecordTimer = self:AddGameTimer(DelayRecordTime, false, function()
      self.DelayRecordTimer = nil
      self:ClientInGameReplayStartRecording()
    end)
    print(bWriteLog and "WonderfulPeriodSystem:OnRepParachuteState AddGameTimer")
  end
end
function WonderfulPeriodSystem:OnClientParachuteStateChange(_, _, LastParachuteState, NewParachuteState)
  print(bWriteLog and "WonderfulPeriodSystem:OnClientParachuteStateChange", LastParachuteState, NewParachuteState)
  local EParachuteState = import("EParachuteState")
  if EParachuteState.PS_None == NewParachuteState then
    self:ClientInGameReplayStartRecording()
  end
  if EParachuteState.PS_Opening == NewParachuteState then
    if self.DelayRecordTimer then
      self:RemoveGameTimer(self.DelayRecordTimer)
      self.DelayRecordTimer = nil
      print(bWriteLog and "WonderfulPeriodSystem:OnClientParachuteStateChange RemoveGameTimer")
    end
    self.DelayRecordTimer = self:AddGameTimer(DelayRecordTime, false, function()
      self.DelayRecordTimer = nil
      self:ClientInGameReplayStartRecording()
    end)
    print(bWriteLog and "WonderfulPeriodSystem:OnClientParachuteStateChange AddGameTimer")
  end
end
function WonderfulPeriodSystem:ClientInGameReplayStartRecording()
  print(bWriteLog and "WonderfulPeriodSystem:ClientInGameReplayStartRecording")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uLocalPlayerState = GameplayData.GetPlayerState()
  local uClientInGameReplay = self:GetClientInGameReplay()
  if slua.isValid(uClientInGameReplay) and slua.isValid(uLocalPlayerState) and not uLocalPlayerState.PlayerGameOver then
    uClientInGameReplay:StartRecordingReplay()
  end
end
function WonderfulPeriodSystem:ClientInGameReplayStopRecording()
  print(bWriteLog and "WonderfulPeriodSystem:ClientInGameReplayStopRecording")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uClientInGameReplay = self:GetClientInGameReplay()
  if slua.isValid(uClientInGameReplay) then
    uClientInGameReplay:StopRecordingReplay()
  end
end
function WonderfulPeriodSystem:OnRelease()
  self.ValidKillRecord = {}
  self.ValidAssistRecord = {}
  self.WonderfulPeriodRecord = {}
  self.PeriodInfo = {}
  self.bHasRegist = nil
  if self.DelayRecordTimer then
    self:RemoveGameTimer(self.DelayRecordTimer)
    self.DelayRecordTimer = nil
    print(bWriteLog and "WonderfulPeriodSystem:OnRelease RemoveGameTimer")
  end
  WonderfulPeriodSystem.__super.OnRelease(self)
end
function WonderfulPeriodSystem:OnNearDeath(_, _, uVictim, uCauser, nTypeID, uKillerCharacter, DamageItemID, DamageEvent)
  print(bWriteLog and "WonderfulPeriodSystem:OnNearDeath", uVictim, uCauser, nTypeID, uKillerCharacter, DamageItemID)
  self:OnValidKill(uVictim, uCauser, uKillerCharacter, nTypeID, DamageEvent, DamageItemID)
end
function WonderfulPeriodSystem:OnCharacterDied(_, _, uVictim, uCauser, nTypeID, uKillerCharacter, AdditionalValue, DamageEvent)
  print(bWriteLog and "WonderfulPeriodSystem:OnCharacterDied", uVictim, uCauser, nTypeID, uKillerCharacter, AdditionalValue)
  local ESTEPoseState = import("ESTEPoseState")
  if slua.isValid(uVictim) and uVictim.PoseState ~= ESTEPoseState.Dying and uVictim.PoseState ~= ESTEPoseState.DyingBeCarried and uVictim.PoseState ~= ESTEPoseState.DyingSwim then
    self:OnValidKill(uVictim, uCauser, uKillerCharacter, nTypeID, DamageEvent, AdditionalValue)
  end
end
function WonderfulPeriodSystem:OnValidKill(uVictim, uCauser, uKillerPawn, nTypeID, DamageEvent, DamageItemID)
  print(bWriteLog and "WonderfulPeriodSystem:OnValidKill", nTypeID, uVictim, uCauser, uKillerPawn, DamageEvent, DamageItemID)
  if not (Game:IsHuman(uVictim) and Game:IsPlayer(uKillerPawn)) or Game:IsMonster(uVictim) then
    return
  end
  local uKillerController = uKillerPawn:GetPlayerControllerSafety()
  local victimController = uVictim:GetControllerSafety()
  if not (Game:GetTeamID(uVictim) ~= Game:GetTeamID(uKillerPawn) and uVictim ~= uKillerPawn and slua.isValid(uKillerController)) or not slua.isValid(victimController) then
    return
  end
  local bIsAI = Game:IsAI(uVictim)
  if not Game:IsPlayer(uVictim) and not bIsAI then
    return
  end
  self.nCurTime = CGameState:GetServerWorldTimeSeconds()
  print(bWriteLog and "WonderfulPeriodSystem:OnValidKill AI-", uVictim.bEnsure, victimController.FakePlayerBornType, victimController.bForceRecordKillNum)
  if uVictim.bEnsure and victimController.FakePlayerBornType == 1 and not victimController.bForceRecordKillNum then
    return
  end
  local nVictimUID = Game:GetPlayerUID(uVictim)
  local nAIType = bIsAI and 1 or 0
  xpcall(function()
    self:HandleOnAssist(uVictim, uKillerPawn)
  end, utility.ErrorMessageHandler)
  local nUID = uKillerController.UID
  self.ValidKillRecord[nUID] = self.ValidKillRecord[nUID] or {}
  local tKillRecord = {
    nTime = self.nCurTime,
    nPeriodIndex = -1,
    bAI = bIsAI,
    nScore = 0,
    WonderfulDataList = {}
  }
  if slua.isValid(uCauser) and Game:IsClassOf(uCauser, ASTExtraShootWeapon) and uCauser.GetCurrentBulletNumInClip then
    tKillRecord.CauserGUID = slua.GetNetGUID(uCauser.Object)
    tKillRecord.CurBulletNumInClip = uCauser:GetCurrentBulletNumInClip(0)
  end
  table.insert(self.ValidKillRecord[nUID], tKillRecord)
  local bTriggerMultiKill = false
  print(bWriteLog and "WonderfulPeriodSystem:OnValidKill1", nUID, nAIType, uCauser)
  local WonderfulPeriodConfig = GamePlayTools.GetCurrentConfig("WonderfulPeriodConfig")
  local WonderfulCheckerConfig = WonderfulPeriodConfig.WonderfulCheckerConfig
  local nHighestWonderfulScore = 0
  for _, tConfig in ipairs(WonderfulCheckerConfig) do
    local fChecker = self[tConfig.fChecker]
    if fChecker then
      xpcall(function()
        local tWonderfulData = fChecker(self, tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI, DamageItemID)
        if tWonderfulData and tWonderfulData.nScore and tWonderfulData.nScore > 0 then
          tWonderfulData.nScore = bIsAI and tWonderfulData.nScore * WonderfulPeriodConfig.AIRate or tWonderfulData.nScore
          table.insert(tKillRecord.WonderfulDataList, tWonderfulData)
          if tWonderfulData.nScore > nHighestWonderfulScore then
            nHighestWonderfulScore = tWonderfulData.nScore
          end
        end
      end, utility.ErrorMessageHandler)
    end
  end
  for _, WonderfulData in ipairs(tKillRecord.WonderfulDataList) do
    local WonderfulFinalScore = nHighestWonderfulScore == WonderfulData.nScore and WonderfulData.nScore or WonderfulData.nScore * WonderfulPeriodConfig.SubTypeRate
    tKillRecord.nScore = tKillRecord.nScore + WonderfulFinalScore
  end
  local nKillCnt = #self.ValidKillRecord[nUID]
  self.WonderfulPeriodRecord[nUID] = self.WonderfulPeriodRecord[nUID] or {}
  if 1 < nKillCnt then
    local lastKillRecord = self.ValidKillRecord[nUID][nKillCnt - 1]
    if lastKillRecord and tKillRecord.nTime - lastKillRecord.nTime < WonderfulPeriodConfig.nMaxMultiKillInterval then
      if lastKillRecord.nPeriodIndex >= 0 then
        tKillRecord.nPeriodIndex = lastKillRecord.nPeriodIndex
        self.WonderfulPeriodRecord[nUID][tKillRecord.nPeriodIndex].LastKillIdx = nKillCnt
        print(bWriteLog and "WonderfulPeriodSystem:OnValidKill trigger A ", nUID, tKillRecord.nPeriodIndex)
      else
        table.insert(self.WonderfulPeriodRecord[nUID], {
          FirstKillIdx = nKillCnt - 1,
          LastKillIdx = nKillCnt
        })
        tKillRecord.nPeriodIndex = #self.WonderfulPeriodRecord[nUID]
        lastKillRecord.nPeriodIndex = tKillRecord.nPeriodIndex
        print(bWriteLog and "WonderfulPeriodSystem:OnValidKill trigger B ", nUID, tKillRecord.nPeriodIndex)
      end
    end
  end
  if tKillRecord.nScore > 0 and tKillRecord.nPeriodIndex < 0 then
    table.insert(self.WonderfulPeriodRecord[nUID], {FirstKillIdx = nKillCnt, LastKillIdx = nKillCnt})
    tKillRecord.nPeriodIndex = #self.WonderfulPeriodRecord[nUID]
    print(bWriteLog and "WonderfulPeriodSystem:OnValidKill trigger C ", nUID, tKillRecord.nPeriodIndex, nKillCnt)
  end
  log_tree(bDebugLog and bWriteLog and "bDebugLogWonderfulPeriodSystem ValidKillRecord ValidKillRecord" .. nUID, self.ValidKillRecord[nUID])
  log_tree(bDebugLog and bWriteLog and "bDebugLogWonderfulPeriodSystem ValidKillRecord WonderfulPeriodRecord" .. nUID, self.WonderfulPeriodRecord[nUID])
  if tKillRecord.nPeriodIndex >= 0 and self.WonderfulPeriodRecord[nUID][tKillRecord.nPeriodIndex] then
    local tWonderfulPeriodInfo = self.WonderfulPeriodRecord[nUID][tKillRecord.nPeriodIndex]
    local tAdditionalData = {}
    local SubTypeInfoList = {}
    local nMainType = -1
    local nTypeHighestScore = 0
    local nMultiKillScore = 0
    local nPeriodScore = 0
    local bIsPureAI = true
    local nMultiKillNum = 0
    local nMultiKillIntervalIdx = 0
    for i = tWonderfulPeriodInfo.FirstKillIdx, tWonderfulPeriodInfo.LastKillIdx do
      local CurKillRecord = self.ValidKillRecord[nUID][i]
      if CurKillRecord then
        nPeriodScore = nPeriodScore + CurKillRecord.nScore
        bIsPureAI = CurKillRecord.bAI and bIsPureAI
        table.insert(tAdditionalData, CurKillRecord.nTime)
        for _, WonderfulData in ipairs(CurKillRecord.WonderfulDataList) do
          table.insert(SubTypeInfoList, {
            WonderfulType = WonderfulData.nTypeID,
            Time = CurKillRecord.nTime
          })
          if nTypeHighestScore < WonderfulData.nScore then
            nTypeHighestScore = WonderfulData.nScore
            nMainType = WonderfulData.nTypeID
          end
        end
        if i > tWonderfulPeriodInfo.FirstKillIdx and self.ValidKillRecord[nUID][i - 1] then
          local timeInterval = CurKillRecord.nTime - self.ValidKillRecord[nUID][i - 1].nTime
          local nCurKillRecordMultiKillScore = 0
          for IntervalIdx, tConfig in ipairs(WonderfulPeriodConfig.MultiKillConfig) do
            if timeInterval < tConfig.Interval then
              nMultiKillNum = i - tWonderfulPeriodInfo.FirstKillIdx
              nMultiKill              nCurKillRecordMultiKillScore = tConfig.Score[math.min(#tConfig.Score, nMultiKillNum)] * (CurKillRecord.bAI and WonderfulPeriodConfig.AIMultiKillScoreRate or 1)
            end
          end
          nMultiKillScore = nMultiKillScore + nCurKillRecordMultiKillScore
          print(bWriteLog and "bDebugLogWonderfulPeriodSystem nMultiKillScore", timeInterval, nMultiKillScore, nCurKillRecordMultiKillScore, CurKillRecord.bAI)
        end
      end
    end
    print(bWriteLog and "bDebugLogWonderfulPeriodSystem nMainType", nMainType, nPeriodScore, nMultiKillScore, nTypeHighestScore, nPeriodScore)
    nMainType = nTypeHighestScore < nMultiKillScore and 1 or nMainType
    nPeriodScore = nMultiKillScore + nPeriodScore
    local nStartTime = self.ValidKillRecord[nUID][tWonderfulPeriodInfo.FirstKillIdx].nTime - WonderfulPeriodConfig.nLookBackTime
    local nEndTime = self.ValidKillRecord[nUID][tWonderfulPeriodInfo.LastKillIdx].nTime + WonderfulPeriodConfig.nExtraTime
    log_tree(bWriteLog and "bDebugLogWonderfulPeriodSystem--" .. nMainType .. "|" .. nStartTime .. "|" .. nEndTime .. "|" .. tKillRecord.nPeriodIndex .. "|" .. nPeriodScore, SubTypeInfoList)
    if uKillerController and uKillerController.RPC_Client_WonderfulPeriod then
      uKillerController:RPC_Client_WonderfulPeriod(nMainType, nStartTime, nEndTime, tAdditionalData, tKillRecord.nPeriodIndex, nPeriodScore, bIsPureAI, SubTypeInfoList)
    end
    xpcall(function()
      print(bWriteLog and "bDebugLogWonderfulPeriodSystem TGPA MultiKill", nMultiKillIntervalIdx, nMultiKillNum)
      if 0 < nMultiKillNum and 0 < nMultiKillIntervalIdx then
        local TGPAMultiKillConfig = WonderfulPeriodConfig.TGPAConfig.MultiKillConfig
        if TGPAMultiKillConfig[nMultiKillIntervalIdx] then
          local nTriggerKillNum = math.min(#TGPAMultiKillConfig[nMultiKillIntervalIdx], nMultiKillNum)
          if TGPAMultiKillConfig[nMultiKillIntervalIdx][nTriggerKillNum] then
            uKillerController:RPC_Client_PostTGPAIS(WonderfulPeriodConfig.TGPAConfig.TriggerKey, tostring(TGPAMultiKillConfig[nMultiKillIntervalIdx][nTriggerKillNum]))
            bTriggerMultiKill = true
          end
        end
      end
      self:RealtimeMotivation(uKillerPawn, tWonderfulPeriodInfo)
      local uVictimLoc = Game:GetActorLocation(uVictim)
      local uKillerLoc = Game:GetActorLocation(uKillerPawn)
      local uWeapon = uKillerPawn:GetCurrentWeapon()
      local nWeaponID = 0
      local nDemoTime = 0
      if slua.isValid(uWeapon) then
        nWeaponID = uWeapon:GetWeaponID()
      end
      local USTExtraGameInstance = import("STExtraGameInstance")
      local uGameInstance = USTExtraGameInstance.GetInstance()
      if slua.isValid(uGameInstance) then
        local uCompletePlayback = uGameInstance:GetCompletePlayback()
        if slua.isValid(uCompletePlayback) then
          nDemoTime = math.floor(uCompletePlayback:GetCurrentReplayCurTimeInSeconds())
        end
      end
      if slua.isValid(uVictimLoc) and slua.isValid(uKillerLoc) and nVictimUID then
        local uDiff = uVictimLoc - uKillerLoc
        local nKillDistance = uDiff:Size()
        local tTLogData = {
          UID = nUID,
          VictimUID = nVictimUID,
          TypeID = tWonderfulPeriodInfo.nTypeID,
          Time = self.nCurTime,
          Distance = math.floor(nKillDistance),
          PlayerLoc = {
            pos_x = math.floor(uKillerLoc.X),
            pos_y = math.floor(uKillerLoc.Y),
            pos_z = math.floor(uKillerLoc.Z)
          },
          VictimLoc = {
            pos_x = math.floor(uVictimLoc.X),
            pos_y = math.floor(uVictimLoc.Y),
            pos_z = math.floor(uVictimLoc.Z)
          },
          DemoTime = nDemoTime,
          DamageType = nTypeID,
          WeaponID = nWeaponID
        }
        log_tree("ReportWonderfulPeriod", tTLogData)
        if NetUtil then
          local ReportType = 1
          NetUtil.SendPacket("report_highlight_flow", tTLogData, ReportType, nUID)
        end
        if 0 < nDemoTime then
          if not self.TlogRecord[nUID] then
            self.TlogRecord[nUID] = {}
          end
          table.insert(self.TlogRecord[nUID], nDemoTime)
        end
      end
    end, utility.ErrorMessageHandler)
  end
  if not bTriggerMultiKill then
    local Val = #self.ValidKillRecord[nUID] == 1 and WonderfulPeriodConfig.TGPAConfig.FirstKill or WonderfulPeriodConfig.TGPAConfig.NormalKill
    uKillerController:RPC_Client_PostTGPAIS(WonderfulPeriodConfig.TGPAConfig.TriggerKey, tostring(Val))
  end
end
function WonderfulPeriodSystem:OnHandleBeginSendBattleResult(_, __, nUID)
  if Client then
    return
  end
  print(bWriteLog and "WonderfulPeriodSystem:OnHandleBeginSendBattleResult nUID = " .. tostring(nUID))
  if nUID and self.TlogRecord[nUID] then
    log_tree("ReportWPFinalData", self.TlogRecord[nUID])
    if NetUtil then
      local ReportType = 2
      NetUtil.SendPacket("report_highlight_flow", self.TlogRecord[nUID], ReportType, nUID)
    end
  end
end
function WonderfulPeriodSystem:HandleOnAssist(uVictim, uKillerPawn)
  if not (bEnableAssist and slua.isValid(uVictim)) or not slua.isValid(uKillerPawn) then
    return
  end
  local DamageCauserRecords = uVictim.DamageCauserRecords
  if DamageCauserRecords == nil or DamageCauserRecords:Num() <= 0 then
    print(bWriteLog and bDebugLog and "WonderfulPeriodSystem:HandleOnAssist no DamageCauserRecords")
    return
  end
  local uKillerPS = uKillerPawn:GetPlayerStateSafety()
  local PlayerStateList
  if slua.isValid(uKillerPS) and uKillerPS.GetTeamMatePlayerStateList then
    PlayerStateList = uKillerPS:GetTeamMatePlayerStateList({}, true)
  end
  if PlayerStateList == nil or PlayerStateList:Num() <= 0 then
    print(bWriteLog and bDebugLog and "WonderfulPeriodSystem:HandleOnAssist no teammates")
    return
  end
  local TeammatePSAssistInfo = {}
  for _, uPS in pairs(PlayerStateList) do
    if slua.isValid(uPS) then
      print(bWriteLog and bDebugLog and "WonderfulPeriodSystem:HandleOnAssist TeammatePSAssistInfo", uPS.PlayerName)
      TeammatePSAssistInfo[uPS] = {DamageSumInShort = 0, DamageSumInLong = 0}
    end
  end
  local nRecordNum = DamageCauserRecords:Num()
  local UGameplayStatics = import("GameplayStatics")
  local CurTime = UGameplayStatics.GetRealTimeSeconds(uKillerPawn)
  for i = nRecordNum - 1, 0, -1 do
    local CurRecord = DamageCauserRecords:Get(i)
    if not CurRecord then
      break
    end
    local IntervalTime = CurTime - CurRecord.Time
    local Damage = CurRecord.Damage
    if slua.isValid(CurRecord.Causer) and slua.isValid(CurRecord.Causer.PlayerState) then
      local AssistInfo = TeammatePSAssistInfo[CurRecord.Causer.PlayerState]
      print(bWriteLog and bDebugLog and "WonderfulPeriodSystem:HandleOnAssist time:" .. IntervalTime, "idx:" .. i .. "/" .. nRecordNum - 1, "Damage:" .. Damage, CurRecord.Causer.PlayerState.PlayerName, AssistInfo)
      if AssistInfo then
        if IntervalTime <= ASSIST_SHORT_TIME then
          AssistInfo.DamageSumInShort = AssistInfo.DamageSumInShort + Damage
          AssistInfo.DamageSumInLong = AssistInfo.DamageSumInLong + Damage
        elseif IntervalTime <= ASSIST_LONG_TIME then
          AssistInfo.DamageSumInLong = AssistInfo.DamageSumInLong + Damage
        else
          break
        end
      end
    end
  end
  log_tree(bDebugLog and "WonderfulPeriodSystem:HandleOnAssist damage", TeammatePSAssistInfo)
  local WonderfulPeriodConfig = GamePlayTools.GetCurrentConfig("WonderfulPeriodConfig")
  for uAssistPS, AssistInfo in pairs(TeammatePSAssistInfo) do
    if AssistInfo.DamageSumInShort > ASSIST_SHORT_DAMAGE and AssistInfo.DamageSumInLong > ASSIST_LONG_DAMAGE then
      local uAssistPC = uAssistPS:GetOwner()
      print(bWriteLog and "tAssistRecord uAssistPC", uAssistPC)
      if not slua.isValid(uAssistPC) or uAssistPC.UID == nil then
        return
      end
      local nUID = uAssistPC.UID
      self.ValidKillRecord[nUID] = self.ValidKillRecord[nUID] or {}
      local tKillRecord = {
        nTime = self.nCurTime,
        nPeriodIndex = -1,
        bAI = Game:IsAI(uVictim),
        bIsAssist = true,
        nScore = 0,
        WonderfulDataList = {}
      }
      local nKillCnt = #self.ValidKillRecord[nUID]
      self.WonderfulPeriodRecord[nUID] = self.WonderfulPeriodRecord[nUID] or {}
      if 1 < nKillCnt then
        local lastKillRecord = self.ValidKillRecord[nUID][nKillCnt - 1]
        if lastKillRecord and tKillRecord.nTime - lastKillRecord.nTime < WonderfulPeriodConfig.nMaxMultiKillInterval then
          if 0 <= lastKillRecord.nPeriodIndex then
            tKillRecord.nPeriodIndex = lastKillRecord.nPeriodIndex
            self.WonderfulPeriodRecord[nUID][tKillRecord.nPeriodIndex].LastKillIdx = nKillCnt
          else
            table.insert(self.WonderfulPeriodRecord[nUID], {
              FirstKillIdx = nKillCnt - 1,
              LastKillIdx = nKillCnt
            })
            tKillRecord.nPeriodIndex = #self.WonderfulPeriodRecord[nUID]
            lastKillRecord.nPeriodIndex = tKillRecord.nPeriodIndex
          end
        end
      end
      table.insert(self.ValidKillRecord[nUID], tKillRecord)
    end
  end
end
function WonderfulPeriodSystem:GetPeriodCountByUID(nUID)
  local Cnt = self.WonderfulPeriodRecord[nUID] and #self.WonderfulPeriodRecord[nUID] or 0
  print(bWriteLog and "WonderfulPeriodSystem:GetPeriodCountByUID", nUID, Cnt)
  return Cnt
end
function WonderfulPeriodSystem:RealtimeMotivation(uKillerPawn, tWonderfulPeriodInfo)
  local DSTeamMotivationSubsystem = SubsystemMgr:Get("DSTeamMotivationSubsystem")
  if DSTeamMotivationSubsystem then
    DSTeamMotivationSubsystem:OnHandleGoodJob(uKillerPawn, 0, tWonderfulPeriodInfo.nTypeID)
  else
    print(bWriteLog and "WonderfulPeriodSystem:RealtimeMotivation, DSTeamMotivationSubsystem = nil")
  end
end
function WonderfulPeriodSystem:OnPeriodUpdate(_, __, tNewPeriodInfo)
  local nInType = tNewPeriodInfo.nType
  local nInStartTime = tNewPeriodInfo.nStartTime
  local nInEndTime = tNewPeriodInfo.nEndTime
  local uInAdditionalData = tNewPeriodInfo.uAdditionalData
  local nInPeriodIndex = tNewPeriodInfo.nPeriodIndex
  local uServerTime = CGameState:GetServerWorldTimeSeconds()
  printf(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate nInType[%d] nInStartTime[%f] nInEndTime[%f] uInAdditionalData.num[%d] nInPeriodIndex[%d] uServerTime[%f] nPeriodScore[%f]", nInType, nInStartTime, nInEndTime, uInAdditionalData:Num(), nInPeriodIndex, uServerTime, tNewPeriodInfo.nPeriodScore)
  local DirtyTypeList = {}
  if self:IsSwitchOpen() then
    local uClientInGameReplay = self:GetClientInGameReplay()
    if not slua.isValid(uClientInGameReplay) then
      print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate uClientInGameReplay nullptr")
      return
    end
    if not uClientInGameReplay:IsInRecordState() then
      print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate uClientInGameReplay not in record state")
      return
    end
    local WonderfulPeriodSubTypeInfo = FWonderfulPeriodSubTypeInfo()
    WonderfulPeriodSubTypeInfo.WonderfulSubTypeInfoList = tNewPeriodInfo.SubTypeInfoList
    for _, info in pairs(tNewPeriodInfo.SubTypeInfoList) do
      print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate nInPeriodIndex", nInPeriodIndex, info.Time, info.WonderfulType)
    end
    local nPeriodTime = nInEndTime - nInStartTime
    printf(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate nPeriodTime[%f] LongPeriodTime[%f]", nPeriodTime, LongPeriodTime)
    if nPeriodTime > LongPeriodTime then
      for idx, oldPeriod in pairs(self.PeriodInfo) do
        if oldPeriod and self:ComparePeriodInfo(tNewPeriodInfo, oldPeriod) then
          print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate give up long", oldPeriod.bIsPureAI, oldPeriod.nType)
          return
        end
      end
      if self.bUseDetailTLog then
        for idx, Info in pairs(self.PeriodInfo) do
          xpcall(function()
            if Info and Info.nType and self.DetailTLogInfo[Info.nType] then
              for idx, TLogInfo in pairs(self.DetailTLogInfo[Info.nType]) do
                if TLogInfo and TLogInfo.nPeriodIndex == nInPeriodIndex then
                  TLogInfo.nKeepType = 2
                  TLogInfo.bIsPureAI = tNewPeriodInfo.bIsPureAI
                  DirtyTypeList[Info.nType] = true
                elseif TLogInfo and Info.nPeriodIndex == TLogInfo.nPeriodIndex then
                  TLogInfo.nKeepType = 4
                  DirtyTypeList[Info.nType] = true
                end
              end
            end
          end, utility.ErrorMessageHandler)
        end
      end
      self.PeriodInfo = {}
      uClientInGameReplay:ClearWonderfulPeriod()
      if nPeriodTime > MaxPeriodTime then
        local nNewStartTime = nInEndTime - MaxPeriodTime
        tNewPeriodInfo.nStartTime = nNewStartTime
        local uNewAdditonalData = slua.Array(UEnums.EPropertyClass.Float)
        for i = 0, uInAdditionalData:Num() - 1 do
          local nTimeStamp = uInAdditionalData:Get(i)
          if nNewStartTime <= nTimeStamp then
            uNewAdditonalData:Add(nTimeStamp)
          end
        end
        tNewPeriodInfo.uAdditionalData = uNewAdditonalData
      end
      self.PeriodInfo[nInPeriodIndex] = tNewPeriodInfo
      uClientInGameReplay:AddWonderfulPeriod(tNewPeriodInfo.nType, tNewPeriodInfo.nStartTime, tNewPeriodInfo.nEndTime, tNewPeriodInfo.uAdditionalData, tNewPeriodInfo.nPeriodIndex, WonderfulPeriodSubTypeInfo)
      print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate clear all periods and add a long period")
      if self.bUseDetailTLog then
        xpcall(function()
          self:ReportDetailTLog(DirtyTypeList)
        end, utility.ErrorMessageHandler)
      end
      return
    end
    if self.PeriodInfo[nInPeriodIndex] == nil then
      if self:GetPeriodNum() < self.MaxPeriodStoreNum then
        if self.bUseDetailTLog then
          xpcall(function()
            table.insert(self.DetailTLogInfo[tNewPeriodInfo.nType], {
              nPeriodIndex = nInPeriodIndex,
              bIsPureAI = tNewPeriodInfo.bIsPureAI,
              nKeepType = 1
            })
            DirtyTypeList[tNewPeriodInfo.nType] = true
          end, utility.ErrorMessageHandler)
        end
        self.PeriodInfo[nInPeriodIndex] = tNewPeriodInfo
        uClientInGameReplay:AddWonderfulPeriod(tNewPeriodInfo.nType, tNewPeriodInfo.nStartTime, tNewPeriodInfo.nEndTime, tNewPeriodInfo.uAdditionalData, tNewPeriodInfo.nPeriodIndex, WonderfulPeriodSubTypeInfo)
        print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate add one period directly")
      else
        local nLowestIndex = self:FindLowestPeriodInfoIndex()
        local tLowestPeriodInfo = self.PeriodInfo[nLowestIndex]
        if self:ComparePeriodInfo(tLowestPeriodInfo, tNewPeriodInfo) then
          if self.bUseDetailTLog then
            xpcall(function()
              if self.DetailTLogInfo[tLowestPeriodInfo.nType] then
                for _, TLogInfo in pairs(self.DetailTLogInfo[tLowestPeriodInfo.nType]) do
                  if TLogInfo.nPeriodIndex == nLowestIndex then
                    TLogInfo.nPeriodIndex = -1
                    TLogInfo.nKeepType = 3
                    DirtyTypeList[tLowestPeriodInfo.nType] = true
                    break
                  end
                end
              end
              table.insert(self.DetailTLogInfo[tNewPeriodInfo.nType], {
                nPeriodIndex = nInPeriodIndex,
                bIsPureAI = tNewPeriodInfo.bIsPureAI,
                nKeepType = 1
              })
              DirtyTypeList[tNewPeriodInfo.nType] = true
            end, utility.ErrorMessageHandler)
          end
          self.PeriodInfo[nLowestIndex] = nil
          self.PeriodInfo[nInPeriodIndex] = tNewPeriodInfo
          print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate switch NewPeriodInfo clear index[%d] and new index[%d]", nLowestIndex, nInPeriodIndex)
          uClientInGameReplay:DeleteWonderfulPeriod(nLowestIndex)
          uClientInGameReplay:AddWonderfulPeriod(tNewPeriodInfo.nType, tNewPeriodInfo.nStartTime, tNewPeriodInfo.nEndTime, tNewPeriodInfo.uAdditionalData, tNewPeriodInfo.nPeriodIndex, WonderfulPeriodSubTypeInfo)
        else
          if self.bUseDetailTLog then
            xpcall(function()
              table.insert(self.DetailTLogInfo[tNewPeriodInfo.nType], {
                nPeriodIndex = -1,
                bIsPureAI = tNewPeriodInfo.bIsPureAI,
                nKeepType = 3
              })
              DirtyTypeList[tNewPeriodInfo.nType] = true
            end, utility.ErrorMessageHandler)
          end
          print(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate ignore NewPeriodInfo")
        end
      end
    else
      local tOldPeriodInfo = self.PeriodInfo[nInPeriodIndex]
      if self:ComparePeriodInfo(tOldPeriodInfo, tNewPeriodInfo) then
        if self.bUseDetailTLog then
          xpcall(function()
            if self.DetailTLogInfo[tOldPeriodInfo.nType] then
              for idx, TLogInfo in pairs(self.DetailTLogInfo[tOldPeriodInfo.nType]) do
                if TLogInfo and TLogInfo.nPeriodIndex == nInPeriodIndex then
                  table.remove(self.DetailTLogInfo[tOldPeriodInfo.nType], idx)
                  DirtyTypeList[tOldPeriodInfo.nType] = true
                  break
                end
              end
            end
            table.insert(self.DetailTLogInfo[tNewPeriodInfo.nType], {
              nPeriodIndex = nInPeriodIndex,
              bIsPureAI = tNewPeriodInfo.bIsPureAI,
              nKeepType = 1
            })
            DirtyTypeList[tNewPeriodInfo.nType] = true
          end, utility.ErrorMessageHandler)
        end
        self.PeriodInfo[nInPeriodIndex] = tNewPeriodInfo
        uClientInGameReplay:AddWonderfulPeriod(tNewPeriodInfo.nType, tNewPeriodInfo.nStartTime, tNewPeriodInfo.nEndTime, tNewPeriodInfo.uAdditionalData, tNewPeriodInfo.nPeriodIndex, WonderfulPeriodSubTypeInfo)
        printf(bWriteLog and "WonderfulPeriodSystem:OnPeriodUpdate replace one period[%d]", nInPeriodIndex)
      end
    end
  end
  if self.bUseDetailTLog then
    xpcall(function()
      self:ReportDetailTLog(DirtyTypeList)
    end, utility.ErrorMessageHandler)
  end
end
function WonderfulPeriodSystem:ReportDetailTLog(DirtyTypeList)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.RPC_ServerAddGeneralCount then
    return
  end
  log_tree(bWriteLog and "WonderfulPeriodSystem:ReportDetailTLog DirtyTypeList", DirtyTypeList)
  log_tree(bWriteLog and "WonderfulPeriodSystem:ReportDetailTLog self.DetailTLogInfo", self.DetailTLogInfo)
  log_tree(bWriteLog and "WonderfulPeriodSystem:ReportDetailTLog self.PeriodInfo", self.PeriodInfo)
  for dirtyType, _ in pairs(DirtyTypeList) do
    if self.DetailTLogInfo[dirtyType] and #self.DetailTLogInfo[dirtyType] > 0 and self.TLogID[dirtyType] then
      local Str = ""
      local Str1 = ""
      for idx, TLogInfo in ipairs(self.DetailTLogInfo[dirtyType]) do
        if TLogInfo then
          local TLogNum = TLogInfo.nKeepType
          if TLogInfo.bIsPureAI then
            TLogNum = TLogNum + 4
          end
          if idx < 10 then
            Str = Str .. TLogNum
          else
            Str1 = Str1 .. TLogNum
          end
        end
      end
      print(bWriteLog and "WonderfulPeriodSystem:ReportDetailTLog ", dirtyType, "Str", Str, Str1)
      if 0 < string.len(Str) and string.len(Str1) < 11 and tonumber(Str) and 0 < tonumber(Str) then
        uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][1], math.floor(tonumber(Str)), true)
        if 0 < string.len(Str1) and string.len(Str1) < 11 and tonumber(Str1) and 0 < tonumber(Str1) then
          uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][2], math.floor(tonumber(Str1)), true)
        else
          uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][2], 0, true)
        end
      else
        uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][1], 0, true)
        uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][2], 0, true)
      end
    elseif self.TLogID[dirtyType] then
      uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][1], 0, true)
      uPlayerState:RPC_ServerAddGeneralCount(self.TLogID[dirtyType][2], 0, true)
    end
  end
end
function WonderfulPeriodSystem:IsSwitchOpen()
  local uClientInGameReplay = self:GetClientInGameReplay()
  if slua.isValid(uClientInGameReplay) then
    print(bWriteLog and "WonderfulPeriodSystem:IsSwitchOpen bWonderfulPlaybackEnable")
    return uClientInGameReplay.bWonderfulPlaybackEnable and uClientInGameReplay.bGWonderfulPlaybackSwitch
  end
  print(bWriteLog and "WonderfulPeriodSystem:IsSwitchOpen false")
  return false
end
function WonderfulPeriodSystem:ComparePeriodInfo(tPeriodInfoA, tPeriodInfoB)
  if tPeriodInfoA == nil then
    return true
  end
  if tPeriodInfoB == nil then
    return false
  end
  if tPeriodInfoA.nPeriodScore > tPeriodInfoB.nPeriodScore then
    return false
  elseif tPeriodInfoB.nPeriodScore > tPeriodInfoA.nPeriodScore then
    return true
  end
  if tPeriodInfoA.nType == 1 and tPeriodInfoB.nType ~= 1 then
    return true
  else
    return false
  end
  return tPeriodInfoA.nPeriodIndex < tPeriodInfoB.nPeriodIndex
end
function WonderfulPeriodSystem:FindLowestPeriodInfoIndex()
  local nLowestIndex = -1
  if self.PeriodInfo == nil or self:GetPeriodNum() <= 0 then
    printf(bWriteLog and "WonderfulPeriodSystem:FindLowestPeriodInfoIndex empty table nLowestIndex[%d]", nLowestIndex)
    return nLowestIndex
  end
  for index, value in pairs(self.PeriodInfo) do
    if nLowestIndex == -1 then
      nLowestIndex = value.nPeriodIndex
    else
      local tLowestPeriodInfo = self.PeriodInfo[nLowestIndex]
      if self:ComparePeriodInfo(value, tLowestPeriodInfo) then
        nLowestIndex = value.nPeriodIndex
      end
    end
  end
  printf(bWriteLog and "WonderfulPeriodSystem:FindLowestPeriodInfoIndex find lowest nLowestIndex[%d]", nLowestIndex)
  return nLowestIndex
end
function WonderfulPeriodSystem:GetPeriodNum()
  local nPeriodNum = 0
  for key, value in pairs(self.PeriodInfo) do
    nPeriodNum = nPeriodNum + 1
  end
  print(bWriteLog and "WonderfulPeriodSystem:GetPeriodNum %d", nPeriodNum)
  return nPeriodNum
end
function WonderfulPeriodSystem:GetClientInGameReplay()
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uClientInGameReplay = uGameInstance:GetClientInGameReplay()
    if slua.isValid(uClientInGameReplay) then
      return uClientInGameReplay
    end
  end
  return nil
end
function WonderfulPeriodSystem:OnFetchWonderfulInfo(_, __)
  print(bWriteLog and "WonderfulPeriodSystem:OnFetchWonderfulInfo")
  local uClientInGameReplay = self:GetClientInGameReplay()
  if slua.isValid(uClientInGameReplay) then
    for index, value in pairs(self.PeriodInfo) do
      local WonderfulPeriodSubTypeInfo = FWonderfulPeriodSubTypeInfo()
      WonderfulPeriodSubTypeInfo.WonderfulSubTypeInfoList = self.PeriodInfo.SubTypeInfoList
      uClientInGameReplay:AddWonderfulPeriod(value.nType, value.nStartTime, value.nEndTime, value.uAdditionalData, value.nPeriodIndex, WonderfulPeriodSubTypeInfo)
    end
  end
end
function WonderfulPeriodSystem:AntiKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  print(bWriteLog and "WonderfulPeriodSystem AntiKillChecker uKillerPawn.Health:", uKillerPawn.Health)
  if uKillerPawn.Health > tConfig.nMaxSelfHealth then
    return
  end
  local WonderfulPeriodConfig = GamePlayTools.GetCurrentConfig("WonderfulPeriodConfig")
  local nStartTime = self.nCurTime - WonderfulPeriodConfig.nLookBackTime
  local nTakeDamage = 0
  local nTotalDamage = 0
  for _, uRecord in pairs(uKillerPawn.DamageRecords) do
    if nStartTime < uRecord.Time and slua.isValid(uRecord.Causer) then
      local uVictimPlayerState = uVictim:GetPlayerStateSafety()
      if slua.isValid(uVictimPlayerState) and uRecord.Causer.PlayerKey == uVictimPlayerState.Playerkey then
        nTakeDamage = nTakeDamage + uRecord.Damage
      end
      nTotalDamage = nTotalDamage + uRecord.Damage
    end
  end
  local nScore = 0
  for _, tAntiKillConfig in ipairs(tConfig.AntiKillConfig) do
    if uKillerPawn.Health <= tAntiKillConfig.nSelfHealth and nTakeDamage >= tAntiKillConfig.nTakeDamage and nTotalDamage >= tAntiKillConfig.nTotalDamage then
      nScore = tAntiKillConfig.nScore
    end
  end
  print(bWriteLog and "WonderfulPeriodSystem AntiKillChecker nTakeDamage:", nTakeDamage, nTotalDamage, bIsAI, nScore)
  return {
    nTypeID = EWonderfulType.EWonderfulType_AntiKill,
      }
end
function WonderfulPeriodSystem:MovingVehicleKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  if not Game:IsVehicle(uCauser) then
    print(bWriteLog and "WonderfulPeriodSystem MovingVehicleKillChecker uCauser is not vehicle")
    return
  end
  if nTypeID ~= EDamageType.VehicleExplodeRadiusDamage then
    print(bWriteLog and "WonderfulPeriodSystem MovingVehicleKillChecker nTypeID is not VehicleExplodeRadiusDamage")
    return
  end
  local nSpeed = uCauser:GetForwardSpeed()
  print(bWriteLog and "WonderfulPeriodSystem MovingVehicleKillChecker nSpeed:", nSpeed)
  if nSpeed < tConfig.nSpeed then
    return
  end
  local uVehicleCommon = uCauser:GetVehicleCommon()
  if not slua.isValid(uVehicleCommon) then
    return
  end
  local WonderfulPeriodConfig = GamePlayTools.GetCurrentConfig("WonderfulPeriodConfig")
  local nStartTime = self.nCurTime - WonderfulPeriodConfig.nLookBackTime
  local nCauseDamage = 0
  for _, uRecord in pairs(uVehicleCommon.DamageRecords) do
    if nStartTime < uRecord.Time and slua.isValid(uRecord.Instigator) then
      local uKillerPlayerState = uKillerPawn:GetPlayerStateSafety()
      if slua.isValid(uKillerPlayerState) and uRecord.Instigator.PlayerKey == uKillerPlayerState.Playerkey then
        nCauseDamage = nCauseDamage + uRecord.Damage
      end
    end
  end
  print(bWriteLog and "WonderfulPeriodSystem MovingVehicleKillChecker nCauseDamage:", nCauseDamage, bIsAI)
  if nCauseDamage < tConfig.nCauseDamage then
    return
  end
  return {
    nTypeID = EWonderfulType.EWonderfulType_MovingVehicleKill,
    nScore = tConfig.nScore
  }
end
function WonderfulPeriodSystem:MovingKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  local uVictimMovement = uVictim.CharacterMovement
  if not slua.isValid(uVictimMovement) then
    return
  end
  local nSpeed = uVictimMovement.LastUpdateVelocity:Size()
  print(bWriteLog and "WonderfulPeriodSystem MovingKillChecker nSpeed:", nSpeed)
  if nSpeed < tConfig.nSpeed then
    local uLastVehicle = uVictim.LastAttachedVehicle
    if slua.isValid(uLastVehicle) and uLastVehicle:IsAlive() then
      nSpeed = uLastVehicle:GetForwardSpeed()
      print(bWriteLog and "WonderfulPeriodSystem MovingKillChecker vehicle nSpeed:", nSpeed, uVictim.LastLeaveVehicleTime)
      if math.abs(uVictim.LastLeaveVehicleTime - self.nCurTime) > 0.001 then
        return
      end
      if nSpeed < tConfig.nSpeed then
        return
      end
    else
      return
    end
  end
  local WonderfulPeriodConfig = GamePlayTools.GetCurrentConfig("WonderfulPeriodConfig")
  local nStartTime = self.nCurTime - WonderfulPeriodConfig.nLookBackTime
  local uDiff = Game:GetActorLocation(uVictim) - Game:GetActorLocation(uKillerPawn)
  local nDistance = uDiff:Size()
  print(bWriteLog and "WonderfulPeriodSystem MovingKillChecker nDistance:", nDistance)
  if nDistance < tConfig.nDistance then
    return
  end
  local nCauseDamage = 0
  for _, uRecord in pairs(uVictim.DamageRecords) do
    if nStartTime < uRecord.Time and slua.isValid(uRecord.Causer) then
      local uKillerPlayerState = uKillerPawn:GetPlayerStateSafety()
      if slua.isValid(uKillerPlayerState) and uRecord.Causer.PlayerKey == uKillerPlayerState.Playerkey then
        nCauseDamage = nCauseDamage + uRecord.Damage
      end
    end
  end
  print(bWriteLog and "WonderfulPeriodSystem MovingKillChecker nCauseDamage:", nCauseDamage, bIsAI)
  if nCauseDamage < tConfig.nCauseDamage then
    return
  end
  return {
    nTypeID = EWonderfulType.EWonderfulType_MovingKill,
    nScore = tConfig.nScore
  }
end
function WonderfulPeriodSystem:LongDistanceKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  local uDiff = Game:GetActorLocation(uVictim) - Game:GetActorLocation(uKillerPawn)
  local nDistance = uDiff:Size()
  local nScore = 0
  for i, DistConfig in ipairs(tConfig.DistScoreTable) do
    if nDistance > DistConfig.Dist then
      nScore = DistConfig.nScore
    end
  end
  print(bWriteLog and "WonderfulPeriodSystem LongDistanceKillChecker nDistance:", nDistance, nScore)
  if nScore == 0 then
    return
  end
  return {
    nTypeID = EWonderfulType.EWonderfulType_LongDistance,
    nScore = nScore,
      }
end
function WonderfulPeriodSystem:MeleeWeaponKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  local bMeleeAttacking = uKillerPawn and uKillerPawn.HasState and uKillerPawn:HasState(UEnums.EPawnState.MeleeAttack)
  print(bWriteLog and "WonderfulPeriodSystem MeleeWeaponKillChecker", nTypeID, bMeleeAttacking)
  if nTypeID ~= EDamageType.MeleeDamage then
    return
  end
  local nScore = tConfig.nHighScore
  if bMeleeAttacking then
    nScore = tConfig.nScore
  end
  print(bWriteLog and "WonderfulPeriodSystem MeleeWeaponKillChecker success", nScore)
  return {
    nTypeID = EWonderfulType.EWonderfulType_MeleeWeaponKill,
      }
end
function WonderfulPeriodSystem:OnVehicleKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  local bEnableRecord = false
  if nTypeID == EDamageType.VehicleDamage then
    bEnableRecord = true
    print(bWriteLog and "WonderfulPeriodSystem OnVehicleKillChecker DamageType is VehicleDamage")
  end
  if uKillerPawn:IsOnVehicle() then
    bEnableRecord = true
    print(bWriteLog and "WonderfulPeriodSystem OnVehicleKillChecker kill IsOnVehicle")
  end
  local Vehicle = uKillerPawn:GetCurrentVehicle()
  if not bEnableRecord or not slua.isValid(Vehicle) then
    return
  end
  local nScore = 0
  local Velocity = USTExtraVehicleUtils.GetVehicleVelocity(Vehicle)
  local nSpeed = Velocity:Size()
  if USTExtraVehicleUtils.IsDriver(uKillerPawn) then
    nScore = tConfig.nDriverScore
    print(bWriteLog and "WonderfulPeriodSystem OnVehicleKillChecker driver", nSpeed)
  elseif USTExtraVehicleUtils.IsPassenger(uKillerPawn) then
    print(bWriteLog and "WonderfulPeriodSystem OnVehicleKillChecker nSpeed", nSpeed)
    if nSpeed > tConfig.nSpeed then
      nScore = tConfig.nPassengerScore
    end
  end
  if nScore == 0 then
    return
  end
  return {
    nTypeID = EWonderfulType.EWonderfulType_OnVehicleKill,
      }
end
function WonderfulPeriodSystem:GrenadeKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI, DamageItemID)
  local bEnableRecord = false
  if nTypeID == EDamageType.BurningDamage then
    local bIsCauserGrenade = slua.isValid(uCauser) and slua.isValid(GrenadeBaseClass) and Game:IsClassOf(uCauser, GrenadeBaseClass)
    if bIsCauserGrenade or DamageItemID == 602003 then
      bEnableRecord = true
    end
    print(bWriteLog and "WonderfulPeriodSystem GrenadeKillChecker BurningDamage uCauser", uCauser, bEnableRecord)
  elseif nTypeID == EDamageType.CustomRadiusDamage or nTypeID == EDamageType.RadialDamage or nTypeID == EDamageType.GrenadeRadiusDamage then
    local bIsCauserGrenade = slua.isValid(uCauser) and slua.isValid(GrenadeBaseClass) and Game:IsClassOf(uCauser, GrenadeBaseClass)
    if bIsCauserGrenade or DamageItemID == 602004 then
      bEnableRecord = true
      print(bWriteLog and "WonderfulPeriodSystem GrenadeKillChecker Grenade Class")
    end
  end
  if not bEnableRecord then
    return
  end
  local nScore = tConfig.nScore
  if slua.isValid(uCauser) and uCauser.ThrowTime and self.nCurTime - uCauser.ThrowTime <= tConfig.nHighScoreTime then
    nScore = tConfig.nHighScore
  end
  print(bWriteLog and "WonderfulPeriodSystem GrenadeKillChecker success", bIsAI, self.nCurTime)
  return {
    nTypeID = EWonderfulType.EWonderfulType_GrenadeKill,
      }
end
function WonderfulPeriodSystem:HeadshotKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI)
  local bEnableRecord = false
  local WonderfulData = 0
  if nTypeID == EDamageType.ShootDamage then
    local nRecordNum = uVictim.DamageCauserRecords:Num()
    if 0 < nRecordNum then
      local LastRecord = uVictim.DamageCauserRecords:Get(nRecordNum - 1)
      if LastRecord.bIsHeadshot == true then
        bEnableRecord = true
        WonderfulData = LastRecord.Damage
        print(bWriteLog and "WonderfulPeriodSystem HeadShotDamage", WonderfulData)
      end
    end
  end
  if not bEnableRecord then
    return
  end
  print(bWriteLog and "WonderfulPeriodSystem HeadshotKillChecker success", bIsAI)
  return {
    nTypeID = EWonderfulType.EWonderfulType_HeadshotKill,
    nScore = tConfig.nScore
  }
end
function WonderfulPeriodSystem:OneHitMultiKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI, DamageEvent)
  local uKillerController = uKillerPawn:GetPlayerControllerSafety()
  if not slua.isValid(uKillerController) then
    return
  end
  local nUID = uKillerController.UID
  local tKillRecords = self.ValidKillRecord[nUID] or {}
  local KillRecCnt = #tKillRecords
  if KillRecCnt < 2 then
    print(bWriteLog and "WonderfulPeriodSystem:OneHitMultiKillChecker not enough kill records")
    return
  end
  local CurKillRecord = tKillRecords[KillRecCnt]
  local LastKillRecord = tKillRecords[KillRecCnt - 1]
  if not CurKillRecord or not LastKillRecord then
    print(bWriteLog and "WonderfulPeriodSystem:OneHitMultiKillChecker not enough kill records.")
    return
  end
  if math.abs(CurKillRecord.nTime - LastKillRecord.nTime) < 0.1 and CurKillRecord.CauserGUID and CurKillRecord.CauserGUID > 0 and CurKillRecord.CauserGUID == LastKillRecord.CauserGUID and CurKillRecord.CurBulletNumInClip == LastKillRecord.CurBulletNumInClip then
    print(bWriteLog and "WonderfulPeriodSystem:OneHitMultiKillChecker Success shot")
    return {
      nTypeID = EWonderfulType.EWonderfulType_OneShotMultiKill,
      nScore = tConfig.nShotScore
    }
  end
end
function WonderfulPeriodSystem:CrossBowKillChecker(tConfig, uVictim, uCauser, uKillerPawn, nTypeID, bIsAI, DamageEvent)
  if slua.isValid(uCauser) and uCauser.GetWeaponID then
    local itemID = uCauser:GetWeaponID()
    if itemID and BackpackUtils.GetItemSubType(itemID) == 107 then
      return {
        nTypeID = EWonderfulType.EWonderfulType_CrossBowKill,
        nScore = tConfig.nScore
      }
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, WonderfulPeriodSystem)
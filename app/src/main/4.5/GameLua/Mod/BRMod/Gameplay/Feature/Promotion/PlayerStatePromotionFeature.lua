local PlayerStatePromotionFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
local logic_season_util = require("client.logic.season.logic_season_util")
local MaxRank = 801
local UIUtil = require("client.common.ui_util")
local TableUtil = require("common.table_util")
PlayerStatePromotionFeature.ClientRPC.ClientRPC_PromotionRoundPassed = {
  Reliable = true,
  Params = {}
}
PlayerStatePromotionFeature.ClientRPC.ClientRPC_PromotionParachute = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
PlayerStatePromotionFeature.MulticastRPC.MulticastRPC_PromotionSeriesComplete = {
  Reliable = true,
  Params = {}
}
function PlayerStatePromotionFeature:ctor()
  self.bPromotionChecked = false
  self.bHasTriggeredParachutePromotion = false
end
function PlayerStatePromotionFeature:ReceiveBeginPlay()
  PlayerStatePromotionFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    local uGameState = GameplayData.GetGameState()
    if uGameState then
      self:AddControlEvent(uGameState, "OnPlayerNumChange", self.OnHandlePlayerNumChanged, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_REVIVE_TOWER_CLOSE, self.OnReviveTowerClose, self)
    end
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnStartFightingState, self)
  else
    self:RefreshPromotionState()
  end
end
function PlayerStatePromotionFeature:ReceiveEndPlay(EndPlayReason)
  PlayerStatePromotionFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerStatePromotionFeature:OnStartFightingState()
  local uOwnerPS = self.Owner
  if not (uOwnerPS and uOwnerPS.PromotionLayer) or uOwnerPS.PromotionLayer <= 0 then
    print(bWriteLog and "PlayerStatePromotionFeature:OnStartFightingState - Owner PlayerState invalid")
    return
  end
  if slua.isValid(uOwnerPS.Object) and uOwnerPS.GetPlayerCharacter then
    local uPlayerCharacter = uOwnerPS:GetPlayerCharacter()
    if slua.isValid(uPlayerCharacter) and not uPlayerCharacter.bEnsure then
      self:AddControlEvent(uPlayerCharacter, "OnParachuteStateChanged", function(LastParachuteState, NewParachuteState)
        print(bWriteLog and string.format("PlayerStatePromotionFeature:OnStartFightingState - OnParachuteStateChanged, Last:%d New:%d", LastParachuteState, NewParachuteState))
        local EParachuteState = import("EParachuteState")
        if NewParachuteState == EParachuteState.PS_FreeFall and not self.bHasTriggeredParachutePromotion then
          self:ClientRPC_PromotionParachute(uOwnerPS.PromotionProgressCount or 0, uOwnerPS.PromotionContinueWinCount or 0)
          self.bHasTriggeredParachutePromotion = true
        end
      end)
    end
  end
end
function PlayerStatePromotionFeature:OnHandlePlayerNumChanged()
  self:_CheckAndNotifyPromotion(self.Owner.UID)
end
function PlayerStatePromotionFeature:OnReviveTowerClose()
  self:_CheckAndNotifyPromotion(self.Owner.UID)
end
function PlayerStatePromotionFeature:_CheckAndNotifyPromotion()
  local uOwnerPS = self.Owner
  if not uOwnerPS then
    print(bWriteLog and "PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Owner PlayerState invalid")
    return
  end
  if slua.isValid(CGameState) and CGameState:GetGameModeState() ~= "FightingState" then
    return false
  end
  if self.bPromotionChecked then
    return
  end
  local DSReviveSubsystem = SubsystemMgr:Get("DSReviveSubsystem")
  if DSReviveSubsystem and not DSReviveSubsystem:GetRevivalClosedResult() then
    return
  end
  local nUID = uOwnerPS.UID
  if not uOwnerPS.PromotionLayer or uOwnerPS.PromotionLayer <= 0 then
    return
  end
  local NeedPersonRank = uOwnerPS.PromotionNeedPersonRank
  local ProgressCount = uOwnerPS.PromotionProgressCount
  local ContinueWinCount = uOwnerPS.PromotionContinueWinCount
  if not NeedPersonRank or NeedPersonRank <= 0 then
    return
  end
  local RealPlayerCount = 0
  if _G.IsEditor then
    RealPlayerCount = self:GetRealPlayerCountByUID(nUID)
  else
    RealPlayerCount = GameplayCallbacks.GetRealPlayerCountByUID(nUID)
  end
  print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - UID:%d RealPlayerCount:%d NeedPersonRank:%d ProgressCount:%d ContinueWinCount:%d", nUID, RealPlayerCount, NeedPersonRank, ProgressCount or 0, ContinueWinCount or 0))
  if NeedPersonRank < RealPlayerCount then
    return
  end
  self.bPromotionChecked = true
  ProgressCount = ProgressCount or 0
  ContinueWinCount = ContinueWinCount or 0
  local ReportInfo = {
    TriggerType = 1,
    UID = nUID,
    PlayerRank = RealPlayerCount,
    NeedPersonRank = NeedPersonRank,
    TriggerTime = GamePlayTools.GetServerWorldTimeSeconds(),
    Progress = ProgressCount,
    ContinueWinCnt = ContinueWinCount
  }
  if 0 < ContinueWinCount and ContinueWinCount <= ProgressCount + 1 then
    print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Series complete! progress:%d+1 >= continueWin:%d, send MulticastRPC_PromotionSeriesComplete", ProgressCount, ContinueWinCount))
    self:MulticastRPC_PromotionSeriesComplete()
    if GameplayCallbacks then
      ReportInfo.TriggerType = 2
      GameplayCallbacks.ReportPromotionAchieve(ReportInfo)
    end
  else
    print(bWriteLog and string.format("PlayerStatePromotionFeature:_CheckAndNotifyPromotion - Round passed! progress:%d+1 < continueWin:%d, send ClientRPC_PromotionRoundPassed", ProgressCount, ContinueWinCount))
    self:ClientRPC_PromotionRoundPassed()
    if GameplayCallbacks then
      GameplayCallbacks.ReportPromotionAchieve(ReportInfo)
    end
  end
end
function PlayerStatePromotionFeature:GetRealPlayerCountByUID(nUID)
  local RealPlayerCount = 0
  if CGameState and CGameState.GetPlayerStateByUID then
    local uPlayerState = CGameState:GetPlayerStateByUID(nUID)
    if uPlayerState and slua.isValid(uPlayerState) and uPlayerState.GetDiedPlayerCount and 0 < uPlayerState:GetDiedPlayerCount() then
      RealPlayerCount = uPlayerState:GetDiedPlayerCount()
    end
  end
  if RealPlayerCount == 0 and CGameState then
    RealPlayerCount = CGameState:GetAlivePlayerNum() + 1
    print(bWriteLog and "GameplayCallbacks.GetRealPlayerCountByUID, no DiedPlayerCount, use GetAlivePlayerNum")
  end
  RealPlayerCount = math.max(0, math.min(100, RealPlayerCount))
  print(bWriteLog and "GameplayCallbacks.GetRealPlayerCountByUID, nUID = " .. tostring(nUID) .. ", RealPlayerCount = " .. tostring(RealPlayerCount))
  return RealPlayerCount
end
function PlayerStatePromotionFeature:ClientRPC_PromotionParachute(CurRound, NeedRound)
  print(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionParachute", CurRound, NeedRound)
  if not self.Owner then
    return
  end
  if not self:IsRankMode() then
    print(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionParachute, IsRankMode, return")
    return
  end
  local callback = function(table_data)
    log(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionParachute ReqPromotionBaseConfig callback table_data = " .. tostring(table_data))
    if not (table_data and self.Owner) or not self.Owner.PromotionLayer then
      return
    end
    local cur_segment_config = table_data[self.Owner.PromotionLayer]
    if not cur_segment_config then
      return
    end
    local SegmentLevel = cur_segment_config.segment_level or self.SegmentLevel
    local PromotionContinueWinCount = cur_segment_config.continue_win_cnt
    local zoneSegmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
    print(bWriteLog and "PromotionMissionAdvancementTipsUI:ClientRPC_PromotionParachute segmentLevel = ", zoneSegmentLevel, maxMode, zoneId, SegmentLevel)
    if zoneSegmentLevel == 801 then
      SegmentLevel = 801
    end
    print(bWriteLog and string.format("PlayerStatePromotionFeature:ClientRPC_PromotionParachute callback - SegmentLevel:%s, CurRound:%s, NeedRound:%s", tostring(SegmentLevel), tostring(CurRound), tostring(PromotionContinueWinCount)))
    IngameTipsTools.BattleGeneralTipWithExternTable(12413, {
      SegmentLevel = SegmentLevel,
      CurRound = CurRound,
      NeedRound = PromotionContinueWinCount
    })
  end
  promotion_match_util.ReqPromotionBaseConfig(callback)
end
function PlayerStatePromotionFeature:ClientRPC_PromotionRoundPassed()
  print(bWriteLog and "PlayerStatePromotionFeature: - Show round passed hint")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not self.Owner then
    return
  end
  if not self:IsRankMode() then
    print(bWriteLog and "PlayerStatePromotionFeature Is not RankMode, return")
    return
  end
  local callback = function(table_data)
    log(bWriteLog and "PlayerStatePromotionFeature:ClientRPC_PromotionRoundPassed ReqPromotionBaseConfig callback table_data = " .. tostring(table_data))
    if not (table_data and self.Owner) or not self.Owner.PromotionLayer then
      return
    end
    local cur_segment_config = table_data[self.Owner.PromotionLayer]
    if not cur_segment_config then
      return
    end
    local SegmentLevel = cur_segment_config.segment_level or self.SegmentLevel
    local PromotionContinueWinCount = cur_segment_config.continue_win_cnt
    print(bWriteLog and string.format("PlayerStatePromotionFeature:ClientRPC_PromotionRoundPassed callback - SegmentLevel:%s, CurRound:%s, NeedRound:%s", tostring(SegmentLevel), tostring(CurRound), tostring(PromotionContinueWinCount)))
    local zoneSegmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
    print(bWriteLog and "PromotionMissionAdvancementTipsUI:ClientRPC_PromotionRoundPassed segmentLevel = ", zoneSegmentLevel, maxMode, zoneId, SegmentLevel)
    if zoneSegmentLevel == 801 then
      SegmentLevel = 801
    end
    IngameTipsTools.BattleGeneralTipWithExternTable(12411, {
      SegmentLevel = SegmentLevel,
      SegmentTitle = self.SegmentTitle
    })
  end
  promotion_match_util.ReqPromotionBaseConfig(callback)
end
function PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete()
  if not Client then
    return
  end
  if not self:IsRankMode() then
    print(bWriteLog and "PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete, IsRankMode, return")
    return
  end
  print(bWriteLog and "PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete - Show series complete hint")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not self.Owner then
    return
  end
  local callback = function(table_data)
    print(bWriteLog and "PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete ReqPromotionBaseConfig callback table_data = " .. tostring(table_data))
    if not (table_data and self.Owner) or not self.Owner.PromotionLayer then
      return
    end
    local cur_segment_config = table_data[self.Owner.PromotionLayer]
    if not cur_segment_config then
      return
    end
    local LocalPlayerState = uPlayerController.PlayerState
    local PlayerKey = uPlayerController.PlayerKey
    local SegmentLevel = cur_segment_config.segment_level or self.SegmentLevel
    local zoneSegmentLevel, maxMode, zoneId = logic_season_util:GetCurrZoneMaxSegment(DataMgr.roleData.allzoneSegment)
    print(bWriteLog and "PromotionMissionAdvancementTipsUI:MulticastRPC_PromotionSeriesComplete segmentLevel = ", zoneSegmentLevel, maxMode, zoneId, SegmentLevel)
    if zoneSegmentLevel == 801 then
      SegmentLevel = 801
    end
    local PlayerName = self.Owner.PlayerName
    print(bWriteLog and "PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete - PlayerKey = " .. tostring(PlayerKey) .. ", OwnerPlayerKey = " .. tostring(self.Owner.PlayerKey))
    print(bWriteLog and string.format("PlayerStatePromotionFeature:MulticastRPC_PromotionSeriesComplete callback - SegmentLevel:%s, PromotionLayer:%s, PlayerName:%s", tostring(SegmentLevel), tostring(self.Owner.PromotionLayer), tostring(PlayerName)))
    if PlayerKey == self.Owner.PlayerKey then
      IngameTipsTools.BattleGeneralTipWithExternTable(12410, {SegmentLevel = SegmentLevel, PlayerName = PlayerName})
    elseif slua.isValid(LocalPlayerState) and LocalPlayerState.IsTeammate and LocalPlayerState:IsTeammate(self.Owner.PlayerKey) then
      IngameTipsTools.BattleGeneralTipWithExternTable(12412, {SegmentLevel = SegmentLevel, PlayerName = PlayerName})
      local rankCfg = CDataTable.GetTableData("RankIntegralLevel_MODE_47", SegmentLevel)
      local msg = LocUtil.LocalizeResFormat(85465, PlayerName, rankCfg and rankCfg.Name or "")
      local MsgItem = {
        playerName = PlayerName,
        playerIdentifier = self.Owner.PlayerKey,
        msgContent = msg,
        msgID = 0,
        itemID = 0,
        PlayerKeyString = tostring(self.Owner.PlayerKey)
      }
      uPlayerController.ChatComponent:ShowTeamMsg(MsgItem, false, true, false, false)
    end
  end
  promotion_match_util.ReqPromotionBaseConfig(callback)
end
function PlayerStatePromotionFeature:RefreshPromotionState()
  print(bWriteLog and "PlayerStatePromotionFeature:RefreshPromotionState")
  if not self:IsRankMode() then
    print(bWriteLog and "PlayerStatePromotionFeature:RefreshPromotionState, IsRankMode, return")
    return
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local callback = function(table_data)
    if not self.Owner or not self.Owner.PromotionLayer then
      print(bWriteLog and "PlayerStatePromotionFeature:RefreshPromotionState callback - self.Owner is invalid")
      return
    end
    local bIsMaxRank = self.Owner.UnlockSegLevel == MaxRank
    print(bWriteLog and string.format("PlayerStatePromotionFeature:RefreshPromotionState callback - UnlockSegLevel:%s, bIsMaxRank:%s", tostring(self.Owner.UnlockSegLevel), tostring(bIsMaxRank)))
    local cur_segment_config = table_data[self.Owner.PromotionLayer]
    if not cur_segment_config then
      print(bWriteLog and "PlayerStatePromotionFeature:RefreshPromotionState callback - cur_segment_config is nil")
      return
    end
    local semgent_level = cur_segment_config.semgent_level
    self.SegmentLevel = semgent_level
    print(bWriteLog and string.format("PlayerStatePromotionFeature:RefreshPromotionState callback - semgent_level:%s", tostring(semgent_level)))
    if bIsMaxRank then
      self.SegmentTitle = LocUtil.GetLocalizeResStr(85327)
    elseif segment_level then
      local segCfg = FuncUtil.GetRankTableData(segment_level)
      self.SegmentTitle = segCfg and segCfg.Name or ""
    else
      self.SegmentTitle = ""
      print(bWriteLog and "PlayerStatePromotionFeature:RefreshPromotionState callback - segment_level is nil")
    end
    print(bWriteLog and string.format("PlayerStatePromotionFeature:RefreshPromotionState callback - SegmentTitle:%s title_id:%s", tostring(self.SegmentTitle), tostring(cur_segment_config.title_id)))
  end
  promotion_match_util.ReqPromotionBaseConfig(callback)
end
function PlayerStatePromotionFeature:IsRankMode()
  local uGameState = GameplayData.GetGameState()
  local IsRankMode = slua.isValid(uGameState) and uGameState:IsRankMode() or false
  print(bWriteLog and "PlayerStatePromotionFeature:IsRankMode, uGameState = " .. tostring(uGameState), IsRankMode)
  return IsRankMode
end
function PlayerStatePromotionFeature:PromotionRoundPassedTest()
  self:ClientRPC_PromotionRoundPassed()
end
function PlayerStatePromotionFeature:PromotionSeriesCompleteTest()
  self:MulticastRPC_PromotionSeriesComplete()
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStatePromotionFeature)
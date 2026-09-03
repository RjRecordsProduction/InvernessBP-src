local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EGameModeCPPType = import("EGameModeType")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local FormatLog = FuncUtil.FormatLog
local FriendlyBehavior = {}
local CachedData = {}
function FriendlyBehavior.CacheFriendlyPointsDayMaxValue(nValue)
  CachedData.FriendlyPointsDayMaxValue = nValue
  FormatLog("Cache FriendlyPointsDayMaxValue[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsTotalMaxValue(nValue)
  CachedData.FriendlyPointsTotalMaxValue = nValue
  FormatLog("Cache FriendlyPointsTotalMaxValue[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsMaxGainingPerGame(nValue)
  CachedData.FriendlyPointsMaxGainingPerGame = nValue
  FormatLog("Cache FriendlyPointsMaxGainingPerGame[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsHealTeammate(nValue)
  CachedData.FriendlyPointsHealTeammate = nValue
  FormatLog("Cache FriendlyPointsHealTeammate[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsRescueTeammate(nValue)
  CachedData.FriendlyPointsRescueTeammate = nValue
  FormatLog("Cache FriendlyPointsRescueTeammate[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsRecallTeammate(nValue)
  CachedData.FriendlyPointsRecallTeammate = nValue
  FormatLog("Cache FriendlyPointsRecallTeammate[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyGiftBoxPrice(nValue)
  CachedData.FriendlyGiftBoxPrice = nValue
  FormatLog("Cache FriendlyGiftBoxPrice[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyGiftBoxBuyMaxCount(nValue)
  CachedData.FriendlyGiftBoxBuyMaxCount = nValue
  FormatLog("Cache FriendlyGiftBoxBuyMaxCount[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsCurrValue(nValue)
  CachedData.FriendlyPointsCurrValue = nValue
  FormatLog("Cache FriendlyPointsCurrValue[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsTodayValue(nValue)
  CachedData.FriendlyPointsTodayValue = nValue
  FormatLog("Cache FriendlyPointsTodayValue[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyUsesCountThisGame(nValue)
  CachedData.FriendlyUsesCountThisGame = nValue
  FormatLog("Cache FriendlyUsesCountThisGame[%d]", nValue)
end
function FriendlyBehavior.CacheFriendlyPointsGainedThisGame(nValue)
  CachedData.FriendlyPointsGainedThisGame = nValue
  FormatLog("Cache FriendlyPointsGainedThisGame[%d]", nValue)
end
function FriendlyBehavior.ResetCacheDataFromGameState()
  FormatLog("ResetCacheDataFromGameState")
  CachedData.FriendlyPointsDayMaxValue = 100
  CachedData.FriendlyPointsTotalMaxValue = 200
  CachedData.FriendlyPointsMaxGainingPerGame = 20
  CachedData.FriendlyPointsHealTeammate = 1
  CachedData.FriendlyPointsRescueTeammate = 10
  CachedData.FriendlyPointsRecallTeammate = 10
  CachedData.FriendlyGiftBoxPrice = 100
  CachedData.FriendlyGiftBoxBuyMaxCount = 1
end
function FriendlyBehavior.ResetCacheDataFromPlayerState()
  FormatLog("ResetCacheDataFromPlayerState")
  CachedData.FriendlyPointsCurrValue = 0
  CachedData.FriendlyPointsTodayValue = 0
  CachedData.FriendlyUsesCountThisGame = 0
  CachedData.FriendlyPointsGainedThisGame = 0
end
local tRankMainModeID = {
  [101] = true,
  [102] = true,
  [103] = true,
  [401] = true,
  [402] = true,
  [403] = true
}
function FriendlyBehavior.IsRankMode()
  if CGame:IsEditor() then
    return true
  end
  if Client then
    local USTExtraGameInstance = import("STExtraGameInstance")
    local uGameInstance = USTExtraGameInstance.GetInstance()
    if not slua.isValid(uGameInstance) then
      FormatLog("uGameInstance is nil")
      return false
    end
    local MainModeID = uGameInstance:GetMainModeID()
    if tRankMainModeID[MainModeID] then
      return true
    end
    FormatLog("MainModeID[%d] is not rank", MainModeID)
    return false
  else
    if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.battle_type then
      local MainModeID = ServerDataMgr.SyncGameParams.battle_type
      if tRankMainModeID[MainModeID] then
        return true
      end
      FormatLog("Server MainModeID[%d] is not rank", MainModeID)
    end
    return false
  end
  return false
end
function FriendlyBehavior.IsEnableFriendlyGiftBox()
  local bIsRankMode = FriendlyBehavior.IsRankMode()
  if not bIsRankMode then
    FormatLog("MainModeID is not rank")
    return false
  end
  local uGameState = GameplayData.GetGameState()
  local bIsRoomType = CGameState and CGameState.RoomType and CGameState.RoomType ~= ""
  if bIsRoomType then
    FormatLog("bIsRoomType is true, RoomType[%s]", CGameState.RoomType)
    return false
  end
  local bIsTypicalGameMode = false
  local bIsFourInOneGameMode = false
  if uGameState and uGameState.GameModeType == EGameModeCPPType.ETypicalGameMode then
    bIsTypicalGameMode = true
  end
  if uGameState and uGameState.GameModeType == EGameModeCPPType.EFourInOneGameMode then
    bIsFourInOneGameMode = true
  end
  if bIsTypicalGameMode or bIsFourInOneGameMode then
    local SubModeID = GameMainConfig.GetModeID()
    if SubModeID == 12001 or SubModeID == 12002 or SubModeID == 12004 then
      FormatLog("SubModeID is not 12001, 12002, 12004")
      return false
    end
    return true
  end
  return false
end
function FriendlyBehavior.GetFriendlyDataClient()
  if Client then
    local tData = {
      FriendlyPointsCurrValue = CachedData.FriendlyPointsCurrValue or 0,
      FriendlyPointsTodayValue = CachedData.FriendlyPointsTodayValue or 0,
      FriendlyUsesCountThisGame = CachedData.FriendlyUsesCountThisGame or 0,
      FriendlyPointsGainedThisGame = CachedData.FriendlyPointsGainedThisGame or 0,
      FriendlyPointsDayMaxValue = CachedData.FriendlyPointsDayMaxValue or 100,
      FriendlyPointsTotalMaxValue = CachedData.FriendlyPointsTotalMaxValue or 200,
      FriendlyPointsMaxGainingPerGame = CachedData.FriendlyPointsMaxGainingPerGame or 20,
      FriendlyPointsHealTeammate = CachedData.FriendlyPointsHealTeammate or 1,
      FriendlyPointsRescueTeammate = CachedData.FriendlyPointsRescueTeammate or 10,
      FriendlyPointsRecallTeammate = CachedData.FriendlyPointsRecallTeammate or 10,
      FriendlyGiftBoxPrice = CachedData.FriendlyGiftBoxPrice or 100,
      FriendlyGiftBoxBuyMaxCount = CachedData.FriendlyGiftBoxBuyMaxCount or 1
    }
    return tData
  end
end
function FriendlyBehavior.GetStockCountClient()
  if Client then
    local tData = FriendlyBehavior.GetFriendlyDataClient()
    if not tData then
      return 0
    end
    local nStockCount = math.floor(tData.FriendlyPointsCurrValue / tData.FriendlyGiftBoxPrice)
    return nStockCount
  end
end
function FriendlyBehavior.IsHalloWeen5()
  local SubModeID = GameMainConfig.GetModeID()
  if 64902 <= SubModeID and SubModeID <= 64937 then
    return true
  end
  return false
end
return FriendlyBehavior
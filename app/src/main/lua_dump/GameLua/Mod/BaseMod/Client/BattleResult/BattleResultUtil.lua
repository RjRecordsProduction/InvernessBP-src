local BattleResultUtil = {}
local DEFAULT_HEAD_ID = 401993
BattleResultUtil.SwitchKey = {
  RankingSettlementSwitch = "RankingSettlementSwitch",
  RankingTaskSwitch = "RankingTaskSwitch",
  ResultRewardSwitch = "ResultRewardSwitch"
}
function BattleResultUtil.CheckResultProSwitch(modId, SwitchKey)
  local proSwitchCfg = CDataTable.GetTableData("ResultProSwitchConfig", modId)
  if proSwitchCfg and proSwitchCfg[SwitchKey] == 0 then
    return false
  end
  return true
end
function BattleResultUtil.IsPVEMode(modId)
  for k, v in pairs({
    12003,
    12011,
    12012
  }) do
    if v == modId then
      return true
    end
  end
  return false
end
function BattleResultUtil.CheckUseTypicalResultFlowMode(testMode)
  if testMode then
    return true
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(uGameState) then
    local GameModeType = uGameState.GameModeType
    return GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode or GameModeType == EGameModeType.EBattleRoyal_SuperCold or GameModeType == EGameModeType.EFourInOneGameMode
  end
  return false
end
function BattleResultUtil.NeedShowMVP()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(uGameState) then
    local GameModeType = uGameState.GameModeType
    return GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode or GameModeType == EGameModeType.EEntertainmentGameMode or GameModeType == EGameModeType.EBattleRoyal_SuperCold or GameModeType == EGameModeType.EFourInOneGameMode
  end
end
function BattleResultUtil.CanHidInvalidRewardItem()
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.CanHidInvalidRewardItem then
    local bCanHidInvalidRewardItem = IngameEntry.CurrentModeLogic:CanHidInvalidRewardItem()
    log(bWriteLog and "BattleResultUtil.CanHidInvalidRewardItem " .. tostring(bCanHidInvalidRewardItem))
    return bCanHidInvalidRewardItem
  end
  return false
end
function BattleResultUtil.SkipWinFreeStage()
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.SkipWinFreeStage then
    local skip = IngameEntry.CurrentModeLogic:SkipWinFreeStage()
    print(bWriteLog and "BattleResultUtil.SkipWinFreeStage skip:" .. tostring(skip))
    return skip
  end
  return false
end
function BattleResultUtil.SkipShowMVPScene()
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.SkipShowMVPScene then
    local skip = IngameEntry.CurrentModeLogic:SkipShowMVPScene()
    log(bWriteLog and "BattleResultUtil.SkipShowMVPScene " .. tostring(skip))
    return skip
  end
  return false
end
function BattleResultUtil.CheckHasSegment(battle_owner, sub_mode, new_segment)
  if battle_owner ~= 0 then
    log(bWriteLog and "[v_ywuyuan] BP_STRUCT_BattleResultData.battle_owner is 0")
    return false
  end
  if sub_mode and not BattleResultUtil.CheckResultProSwitch(sub_mode, BattleResultUtil.SwitchKey.RankingSettlementSwitch) then
    log(bWriteLog and "[v_ywuyuan] BP_STRUCT_BattleResultData.CheckResultProSwitch is false")
    return false
  end
  return new_segment ~= 0
end
function BattleResultUtil.SimplifiedWinnerTime(subMode)
  local OpenWinnerTime = LobbySystem.CheckOpen(BP_ENUM_BATTLE_WINNER_TIME)
  local BattleResultForbidWinnerTimeSubMode = {
    1070,
    1071,
    1072,
    1094,
    1095,
    1096
  }
  for i, v in ipairs(BattleResultForbidWinnerTimeSubMode) do
    if v == subMode then
      OpenWinnerTime = false
      break
    end
  end
  if BattleResultUtil.CheckUseTypicalResultFlowMode(false) then
    OpenWinnerTime = false
  end
  return OpenWinnerTime
end
function BattleResultUtil.GetMapCfg(subMode)
  log(bWriteLog and "BattleResultUtil:GetMapCfg subMode:" .. tostring(subMode))
  if subMode == nil then
    return nil
  end
  local BTMode = CDataTable.GetTableData("BTMode", subMode)
  if BTMode == nil or BTMode.MapID == nil then
    log(bWriteLog and "BattleResultUtil:GetMapCfg BTMode or MapID nil")
    return nil
  end
  log(bWriteLog and "BattleResultUtil:GetMapCfg MapID " .. BTMode.MapID)
  local MapConfig = CDataTable.GetTableData("Map", BTMode.MapID)
  if MapConfig == nil then
    log(bWriteLog and "BattleResultUtil:GetMapCfg MapConfig nil")
  end
  return MapConfig
end
function BattleResultUtil.CreateItemPool(Obj, ClassPath, ItemNum, ItemCallback)
  local UUIDuplicatedItemPool = import("UIDuplicatedItemPool")
  local ItemPool = UUIDuplicatedItemPool(Obj)
  ItemPool.bActiveItemListHold = true
  ItemPool:InitItemPool(ClassPath, ItemNum, false)
  for i = 1, ItemNum do
    local Item = ItemPool:GetOneItem()
    if ItemCallback ~= nil then
      ItemCallback(i, Item)
    end
  end
  return ItemPool
end
function BattleResultUtil.DestroyItemPoolAndList(ItemPool)
  if Game:IsValid(ItemPool) then
    print(bWriteLog and string.format("BattleResultUtil.DestroyItemPool %s", ItemPool))
    ItemPool:RecycleUnusedItem()
    ItemPool:ConditionalBeginDestroy()
  end
end
function BattleResultUtil.GetTeamModeName(battle_type, sub_mode)
  print(bWriteLog and string.format("BattleResultUtil.GetTeamModeName battle_type:%s sub_mode:%s", battle_type, sub_mode))
  local msg1 = ""
  local msg2 = ""
  local msg3 = ""
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  msg1 = MatchModeMgrSystem.GetClassicModeWord(battle_type, sub_mode)
  if sub_mode then
    local localStringMode = CDataTable.GetTableData("BTMode", tostring(sub_mode))
    if localStringMode then
      msg2 = LocUtil.GetLocalizeResStr(localStringMode.ModeName)
    end
    local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
    if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.GetAdditionalTeamModeNameMsg then
      msg3 = IngameEntry.CurrentModeLogic:GetAdditionalTeamModeNameMsg(sub_mode)
      log(bWriteLog and "GetTeamModeName Additional Msg:" .. msg3)
    end
  end
  print(bWriteLog and string.format("BattleResultUtil.GetTeamModeName msg1:%s msg3:%s msg2:%s", msg1, msg3, msg2))
  return msg1 .. msg3 .. " " .. msg2
end
function BattleResultUtil.IsMatchingMode(battle_type)
  print(bWriteLog and string.format("BattleResultUtil.IsMatchingMode battle_type:%s", battle_type))
  return battle_type == 111 or battle_type == 112 or battle_type == 113 or battle_type == 411 or battle_type == 412 or battle_type == 413
end
function BattleResultUtil.GetZoneName()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if ZoneSystem == nil then
    return ""
  end
  local zoneConfig = CDataTable.GetTableData("ZoneConfig", ZoneSystem.nChooseZoneID)
  if zoneConfig then
    return zoneConfig.NameInChinese
  else
    return ""
  end
end
function BattleResultUtil.CheckAvatarExist(AvatarID)
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = FItemDefineID(ENUM_ITEM_TYPE.Extra, AvatarID)
  local exist = UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, false, false, false)
  print(bWriteLog and "BattleResultUtil.CheckAvatarExist", AvatarID, exist)
  if exist then
    return AvatarID
  else
    return DEFAULT_HEAD_ID
  end
end
function BattleResultUtil.GetPersonalResultData(ResultData)
  if ResultData == nil or ResultData.LuaPassThrough == nil then
    return nil
  end
  return ResultData.LuaPassThrough.PersonalResultData
end
function BattleResultUtil.GetGeneralResultData(ResultData)
  if ResultData == nil or ResultData.LuaPassThrough == nil then
    return nil
  end
  return ResultData.LuaPassThrough.GeneralResultData
end
function BattleResultUtil.CanApplyAvatarShowType(nShowType)
  if nShowType ~= 11 and nShowType ~= 13 and nShowType ~= 14 and nShowType ~= 15 and nShowType <= 100 then
    return true
  end
  return false
end
function BattleResultUtil.CheckIsPromotion(BattleResultData)
  print(bWriteLog and "BattleResultUtil.CheckIsPromotion")
  log_tree(bWriteLog and "BattleResultUtil.CheckIsPromotion", BattleResultData)
  if not BattleResultData then
    return false
  end
  if not BattleResultData.promotion_layer then
    return false
  end
  if not BattleResultData.promotion_result_info then
    return false
  end
  local is_promotion_win = BattleResultData.promotion_result_info.is_promotion_win
  if is_promotion_win == nil then
    return false
  end
  return true
end
function BattleResultUtil.GetResultShowRankData(BattleResultData)
  print(bWriteLog and "BattleResultUtil.GetResultShowRankData")
  log_tree(bWriteLog and "BattleResultUtil.GetResultShowRankData", BattleResultData)
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(BattleResultData.battle_type) then
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isPeakGame")
    local finalRank = 0
    if BattleResultData.is_team_result then
      finalRank = BattleResultData.peakgame_team_rank
    else
      finalRank = BattleResultData.team_rank
    end
    local totalTeamCount = BattleResultData.TotalTeamCount
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isPeakGame finalRank:" .. tostring(finalRank) .. " totalTeamCount:" .. tostring(totalTeamCount))
    return finalRank, totalTeamCount
  end
  local isPromotion = BattleResultUtil.CheckIsPromotion(BattleResultData)
  if isPromotion then
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isPromotion")
    local finalRank = BattleResultData.person_rank or 0
    local totalPlayerCount = BattleResultData.TotalPlayerCount
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isPromotion finalRank:" .. tostring(finalRank) .. " totalPlayerCount:" .. tostring(totalPlayerCount))
    return finalRank, totalPlayerCount
  end
  print(bWriteLog and "BattleResultUtil.GetResultShowRankData isRegular")
  if BattleResultData.is_team_result then
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isTeamResult")
    local finalRank = BattleResultData.team_rank or 0
    local totalTeamCount = BattleResultData.TotalTeamCount
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isTeamResult finalRank:" .. tostring(finalRank) .. " totalTeamCount:" .. tostring(totalTeamCount))
    return finalRank, totalTeamCount
  else
    local finalRank = BattleResultData.person_rank or 0
    local totalPlayerCount = BattleResultData.TotalPlayerCount
    print(bWriteLog and "BattleResultUtil.GetResultShowRankData isRegular finalRank:" .. tostring(finalRank) .. " totalPlayerCount:" .. tostring(totalPlayerCount))
    return finalRank, totalPlayerCount
  end
end
function BattleResultUtil.GetResultTitle(BattleResultData)
  local isWin = BattleResultData.Reason == "win"
  local finalRank = BattleResultUtil.GetResultShowRankData(BattleResultData)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  local bIsTypicalGameMode = true
  local EGameModeCPPType = import("EGameModeType")
  if uGameState and uGameState.GameModeType ~= EGameModeCPPType.ETypicalGameMode then
    bIsTypicalGameMode = false
  end
  log(bWriteLog and "isWin:" .. tostring(isWin) .. " finalRank:" .. tostring(finalRank) .. " bIsTypicalGameMode:" .. tostring(bIsTypicalGameMode))
  local titleStr = ""
  if bIsTypicalGameMode and finalRank ~= 0 and finalRank ~= 1 then
    if finalRank == 2 then
      titleStr = LocUtil.LocalizeResFormat(7303)
    elseif finalRank == 3 then
      titleStr = LocUtil.LocalizeResFormat(7304)
    elseif 4 <= finalRank and finalRank <= 10 then
      titleStr = LocUtil.LocalizeResFormat(7305)
    else
      titleStr = LocUtil.LocalizeResFormat(301335)
    end
  elseif isWin then
    titleStr = LocUtil.LocalizeResFormat(301334)
  else
    titleStr = LocUtil.LocalizeResFormat(301335)
  end
  return titleStr
end
function BattleResultUtil.GetResultDataByKey(resultData, key)
  if not key or key == "" then
    return nil
  end
  if key == "Otherteam" then
    local all = 0
    for i, value in ipairs(resultData.flash_squad_rapport_changes or {}) do
      if i ~= 1 and i ~= 2 then
        all = all + value.delta
      end
    end
    return all
  end
  return nil
end
return BattleResultUtil
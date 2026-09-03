local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
UnknowPassSystem = UnknowPassSystem or {
  Data = {},
  Level = 0,
  Score = 0,
  Season = 0,
  SeasonInfo = {},
  nPreBuyType = UnknowPassMacro.Enum_PreBuyType.None,
  IsBuyElite = false,
  IsBuyEliteSeg2 = false,
  PassType = 0,
  switch = {},
  MaxLevel = 0,
  KeepBuyCount = 0,
  LastBuyEliteSeason = 0,
  single_month_award_flag = {},
  continuous_buy = nil,
  prebuy_data = nil,
  privilege_exchange_list = nil,
  upass_newuser_state = 0,
  rp_plus_upvote_cnt = 0,
  IsInCurSession = false,
  BuyBeforeLevel = 0,
  bSendBuyReq = false,
  HasUnclaimedReward = false,
  bTaskRedpotAfterBuyPass = false,
  gameEndShowFinishTasksList = {},
  SelectAwards = {},
  bExchangeRsp = false,
  Avatar = nil,
  reqBuyId = 0,
  bShowAwatar = false,
  bShowUpgradeUI = false,
  bShowIcon = false,
  Bonus = nil,
  isNeedGetAllAward = false,
  task_group = {},
  hasCoupon = false,
  hasVoucher = false,
  CouponType = false,
  UpgradeTipsType = 4,
  UpgradeExtraLabel = 0,
  labels = {},
  voucherItemNum = 0,
  VersionNum_1_2_0 = "1_2_0",
  nDiscount = 0.9,
  record_callback_map = {},
  VersionSeasonNum = 3,
  NewestSeason = 21,
  EmtionData = {},
  regain_value = 0,
  upgrade_buy_opentime = nil,
  upgrade_buy_endtime = nil,
  LEVEL_CHANGE_SEASON_ID = 42,
  ESeries = {
    S = 1,
    M = 2,
    A = 3
  },
  SeriesStartSeasonMap = {
    [1] = 1,
    [2] = 20,
    [3] = 42
  },
  SCORE_ITEM_ID = 1099
}
UnknowPass_ObTainToyGetTypeConfig = {
  NeedExec = false,
  param = 0,
  queue = {}
}
function UnknowPassSystem.GetKeeyBuy()
  if UnknowPassSystem.Data and UnknowPassSystem.Data.base then
    return UnknowPassSystem.Data.base.keep_buy or 0
  end
  return 0
end
function UnknowPassSystem.GetCurValue()
  if UnknowPassSystem.Data and UnknowPassSystem.Data.base then
    return UnknowPassSystem.Data.base.cur_value or 0
  end
  return 0
end
function UnknowPassSystem.GetSeasonId()
  return UnknowPassSystem.Season
end
function UnknowPassSystem.GetContinuousImageForBP(value, keep, hasBuy)
  local UnknowPassRecordSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_record")
  local path = UnknowPassRecordSystem.GetContinuousImage(value, keep, hasBuy)
  log(bWriteLog and "[unknowpass] getimage for bp path" .. tostring(path))
  return path
end
function UnknowPassSystem.IsBeyondASeries(seasonId)
  local seasonId = tonumber(seasonId)
  if seasonId >= UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A] then
    return true
  end
  return false
end
function UnknowPassSystem.GetSeriesBySeason(seasonId)
  seasonId = tonumber(seasonId)
  if seasonId < UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.M] then
    return UnknowPassSystem.ESeries.S
  elseif seasonId < UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A] then
    return UnknowPassSystem.ESeries.M
  else
    return UnknowPassSystem.ESeries.A
  end
end
function UnknowPassSystem.GetPreviewTabIndexBySeason(seasonId)
  seasonId = tonumber(seasonId)
  if seasonId < UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.M] then
    return UnknowPassSystem.ESeries.A
  elseif seasonId < UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A] then
    return UnknowPassSystem.ESeries.M
  else
    return UnknowPassSystem.ESeries.S
  end
end
function UnknowPassSystem.GetSeasonListBySeries(seriesId)
  if not seriesId or type(seriesId) ~= "number" then
    print(bWriteLog and "UnknowPassSystem:GetSeasonListBySeries - Invalid seriesId parameter")
    return {}
  end
  local seasonList = {}
  local startSeasonId, endSeasonId
  if seriesId == UnknowPassSystem.ESeries.A then
    startSeasonId = 2
    endSeasonId = UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.M] - 1
  elseif seriesId == UnknowPassSystem.ESeries.M then
    startSeasonId = UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.M]
    endSeasonId = UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A] - 1
  else
    startSeasonId = UnknowPassSystem.SeriesStartSeasonMap[UnknowPassSystem.ESeries.A]
    endSeasonId = UnknowPassSystem.Season or startSeasonId
  end
  if startSeasonId > endSeasonId then
    endSeasonId = startSeasonId
  end
  for i = startSeasonId, endSeasonId do
    seasonList[i] = true
  end
  return seasonList
end
function UnknowPassSystem.GetSeasonAudioPath()
  local season = UnknowPassMacro.UnKnowPass_NextSeason - 1
  local tCfg = CDataTable.GetTableData("UnknowPassSeasonResource", season)
  local sAudioPath = tCfg and tCfg.AwardAudio
  return sAudioPath
end
function UnknowPassSystem.CheckToysOutFit(tAllItem)
  local tOutFitList = {}
  local tCfgTable = CDataTable.GetTable("UnknowPassToysAwardsItemCfg")
  for _, v in pairs(tCfgTable) do
    if UnknowPassSystem.Season == v.SeasonId and v.GroupId == 0 then
      tOutFitList[v.ItemId] = v.Level
    end
  end
  local tQueue = UnknowPass_ObTainToyGetTypeConfig.queue
  local tRepeatFlag = {}
  for _, v in ipairs(tQueue) do
    tRepeatFlag[v] = true
  end
  for _, v in pairs(tAllItem) do
    if tOutFitList[v.res_id] then
      if tRepeatFlag[v.res_id] ~= true then
        table.insert(tQueue, v.res_id)
        tRepeatFlag[v.res_id] = true
      end
      UnknowPass_ObTainToyGetTypeConfig.NeedExec = true
    end
  end
end
function UnknowPassSystem.CanShowChangeColorTips(itemID)
  if not itemID then
    return false
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  if not logic_suit_dye:IsDyeSuit(itemID) then
    return false
  end
  local period = logic_suit_dye:GetPeriodBySuitId(itemID)
  if period ~= 18 then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local guildData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassChangeColorGuide) or {}
  local bHasShown = guildData[itemID]
  return not bHasShown
end
function UnknowPassSystem.OnChangeColorClicked(itemID)
  log(bWriteLog and "UnknowPassSystem.OnChangeColorClicked " .. tostring(itemID))
  if not itemID then
    return
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  if not logic_suit_dye:IsDyeSuit(itemID) then
    return
  end
  local period = logic_suit_dye:GetPeriodBySuitId(itemID)
  if period ~= 18 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local guildData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassChangeColorGuide) or {}
  guildData[itemID] = true
  PlayerPrefsSystem.SaveTableToFile_N(guildData, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassChangeColorGuide)
end
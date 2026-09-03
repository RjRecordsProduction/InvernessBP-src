local logic_season_lookback = {}
local LogicSeasonLookBackConfig = require("client.logic.season.lookback.logic_season_lookback_config")
function logic_season_lookback:OnInitialize()
  logic_season_lookback.__super.OnInitialize(self)
  log(bWriteLog and "logic_season_lookback:OnInitialize")
  self.lookback_data = nil
  self.cache_uid = 0
  self.data_season_id = nil
  self.gift_total_count = 0
  self.visitor_count = 0
  self.sortRatingLog = nil
  self.reqProfileList = nil
  self.recentGifts = nil
  self.entrancePrivacy = false
  self.entranceSwitch = false
  self.lookbackSeason = nil
end
function logic_season_lookback:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_season_lookback OnPreSwitchGameStatus")
  self:ClearData()
end
function logic_season_lookback:OnLogOut()
  log(bWriteLog and "logic_season_lookback OnLogOut")
  self:ClearData()
end
function logic_season_lookback:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NEW_SEASON_LOOKBACK, self.JumpSeasonLookBack, self)
end
function logic_season_lookback:JumpSeasonLookBack()
  log_format("logic_season_lookback:JumpSeasonLookBack.")
  if not self:GetEntranceSwitch() then
    ShowNotice(512138)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Season_Looback_Main_UIBP, DataMgr.roleData.uid, "season")
end
function logic_season_lookback:GetSeasonLookBackAllData(uid, seasonId)
  if not (uid and self.cache_uid == uid and seasonId) or self.data_season_id ~= seasonId then
    log(bWriteLog and "logic_season_lookback:GetSeasonLookBackAllData uid is nil")
    return nil
  end
  return self.lookback_data
end
function logic_season_lookback:ReqSeasonLookBackData(targetUid, seasonId, ifClearReddot)
  log(bWriteLog and "logic_season_lookback:ReqSeasonLookBackData")
  if not targetUid or not seasonId then
    log(bWriteLog and "logic_season_lookback:ReqSeasonLookBackData targetUid or seasonId is nil")
    return
  end
  local reqUid = tonumber(targetUid)
  if targetUid == self.cache_uid and seasonId == self.data_season_id and self.lookback_data and next(self.lookback_data) then
    log(bWriteLog and "logic_season_lookback:ReqSeasonLookBackData has get data")
    if ifClearReddot then
      self:ClearLookBackReddot(targetUid, seasonId)
    end
    return
  end
  self:ClearData()
  self:send_get_season_lookback_data_req(targetUid, seasonId)
end
function logic_season_lookback:GetDataSeasonId()
  return self.data_season_id or self.lookbackSeason
end
function logic_season_lookback:ClearLookBackReddot(uid, seasonId)
  log(bWriteLog and "logic_season_lookback:ClearLookBackReddot")
  if not (seasonId and uid) or tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  log(bWriteLog and "logic_season_lookback:ClearLookBackReddot clear reddot")
  local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
  SeasonLookBackHandler.send_set_season_lookback_reddot_status_req(seasonId)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.SetLookbackEntryRedData(false)
end
function logic_season_lookback:GetDataByKey(key, bIfGetString, bIfGetInteger)
  local EnumKeyToIndex = LogicSeasonLookBackConfig.EnumDataKeyToIndex
  if not key or not EnumKeyToIndex[key] then
    log(bWriteLog and "logic_season_lookback:GetDataByKey key is invalid")
    return nil
  end
  if not self.lookback_data then
    log(bWriteLog and "logic_season_lookback:GetDataByKey lookback_data is invalid")
    return nil
  end
  local originData = self.lookback_data[EnumKeyToIndex[key]]
  if type(originData) ~= "string" or originData == "" then
    log_warning(bWriteLog and "logic_season_lookback:GetDataByKey lookback_data is not string, key:" .. tostring(key))
    return nil
  end
  local res
  local ifSplit = false
  if string.find(originData, "+") ~= nil then
    local StringUtil = require("common.string_util")
    res = StringUtil.Split(originData, "+")
    ifSplit = true
  else
    res = originData
  end
  if bIfGetString then
    return res
  end
  if not ifSplit then
    res = tonumber(res)
    if bIfGetInteger then
      res = math.floor(res)
    end
    return res
  end
  for i, value in ipairs(res) do
    res[i] = tonumber(value)
    if bIfGetInteger then
      res[i] = math.floor(res[i])
    end
  end
  return res
end
function logic_season_lookback:ClearReqProfileList()
  log(bWriteLog and "logic_season_lookback:ClearReqProfileList")
  self.reqProfileList = nil
end
function logic_season_lookback:AddReqProfileUid(uid)
  log(bWriteLog and "logic_season_lookback:AddReqProfileUid")
  if not uid then
    return
  end
  if not self.reqProfileList then
    self.reqProfileList = {}
  end
  self.reqProfileList[uid] = 1
end
function logic_season_lookback:ReqProfileData()
  if not self.reqProfileList or not next(self.reqProfileList) then
    log(bWriteLog and "logic_season_lookback:ReqProfileData no need to req")
    return
  end
  log_tree(bWriteLog and "logic_season_lookback:ReqProfileData uidlist:", self.reqProfileList)
  local reqList = {}
  for uid, _ in pairs(self.reqProfileList) do
    table.insert(reqList, uid)
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqList, function(listInfo)
    if listInfo and 0 < #listInfo then
      EventSystem:postEvent(EVENTTYPE_SEASONLOOKBACK, EVENTID_SEASONLOOKBACK_UPDATEFRIENDS, listInfo)
    end
  end, Enum_PROFILE_REPORT_CFG.SEASON_LOOKBACK)
  self.reqProfileList = nil
end
function logic_season_lookback:SharePhoto(pageIndex)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  local ScreenshotMaker = import("ScreenshotMaker")
  local sSharePath = ScreenshotMaker.MakePicture(true)
  local timer_ticker = require("common.time_ticker")
  local timer
  timer = timer_ticker.AddTimerLoop(0, function()
    if ScreenshotMaker.HasCaptured(sSharePath) then
      local cfg = {
        capturePath = sSharePath,
        campaign = "season_lookback",
        share_type = ShareBtnTLogShareTypeDefine.SeasonReview,
        reasonStr = json.encode({
          uid = DataMgr.roleData.uid,
          pageIndex = pageIndex or 0
        }),
        otherTLog = TLogEventDefine.NewSeasonLookback_PhotoShare
      }
      local Util = require("client.slua_ui_framework.util")
      Util.ShowShare(cfg)
      ShareMgr.ReportClickShare("NewSeasonLookBack")
      EventSystem:postEvent(EVENTTYPE_SEASONLOOKBACK, EVENTID_SEASONLOOKBACK_NEW_SHARE)
      timer_ticker.RemoveTimer(timer)
    else
      log(bWriteLog and "logic_season_lookback:SharePhoto not captured")
    end
  end, TIMER_INFINITE, 0.1)
end
function logic_season_lookback:GetRecentGifts(uid)
  if not uid or not self.recentGifts then
    log(bWriteLog and "logic_season_lookback:GetRecentGifts uid is nil")
    return
  end
  return self.recentGifts[uid]
end
function logic_season_lookback:GetGiftAndVisitorCount()
  return self.gift_total_count or 0, self.visitor_count or 0
end
function logic_season_lookback:ClearPageCacheData()
  log(bWriteLog and "logic_season_lookback:ClearPageCacheData")
  self.gift_total_count = 0
  self.visitor_count = 0
  self.recentGifts = nil
  self.sortRatingLog = nil
end
function logic_season_lookback:SetLookBackSwitchInfo(switchInfo)
  log(bWriteLog and "logic_season_lookback:SetLookBackSwitchInfo")
  if not switchInfo then
    log(bWriteLog and "logic_season_lookback:SetLookBackSwitchInfo no switchInfo")
    self.entranceSwitch = false
    return
  end
  log(bWriteLog and "logic_season_lookback:SetLookBackSwitchInfo switch:" .. tostring(switchInfo.entrance_switch))
  log(bWriteLog and "logic_season_lookback:SetLookBackSwitchInfo season:" .. tostring(switchInfo.season_id))
  self.lookbackSeason = switchInfo.season_id
  self.entranceSwitch = switchInfo.entrance_switch or false
end
function logic_season_lookback:GetEntranceSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.sIpRegion == "US" then
    log(bWriteLog and "logic_season_lookback:GetEntranceSwitch not open 1")
    return false
  end
  if FuncUtil.GetAccountRegionForBP() == "US" then
    log(bWriteLog and "logic_season_lookback:GetEntranceSwitch not open 2")
    return false
  end
  log(bWriteLog and "logic_season_lookback:GetEntranceSwitch switch:" .. tostring(self.entranceSwitch))
  return self.entranceSwitch
end
function logic_season_lookback:GetLookBackSeasonId()
  log(bWriteLog and "logic_season_lookback:GetLookBackSeasonId seasonId:" .. tostring(self.lookbackSeason))
  return self.lookbackSeason
end
function logic_season_lookback:GetPageTitleLQAId(page)
  local PageTitleLQA = LogicSeasonLookBackConfig.PageTitleLQA
  if not page or not PageTitleLQA[page] then
    log(bWriteLog and "logic_season_lookback:GetPageTitleLQAId page is nil")
    return 0
  end
  if page == 5 then
    local gameWithFriCnt = self:GetPlayWithFriendData()
    local gameNotWithFriCnt = self:GetNotPlayWithFriendData()
    if gameWithFriCnt >= gameNotWithFriCnt and 0 < gameNotWithFriCnt then
      return PageTitleLQA[page]
    else
      log(bWriteLog and "logic_season_lookback:GetPageTitleLQAId combat comparison")
      return 512101
    end
  end
  return PageTitleLQA[page]
end
function logic_season_lookback:GetTitleId()
  return self:GetDataByKey("TitleID")
end
function logic_season_lookback:GetCurRaderData()
  local radar_info = self:GetDataByKey("RadarInfo")
  if not radar_info or type(radar_info) ~= "table" or #radar_info < 5 then
    log(bWriteLog and "logic_season_lookback:GetCurRaderData radar_info is invalid")
    return {
      survive_score = 0,
      top1_score = 0,
      rating_score = 0,
      fight_score = 0,
      assist_score = 0
    }
  end
  local res = {
    survive_score = radar_info[1] / 100,
    top1_score = radar_info[2] / 100,
    rating_score = radar_info[3] / 100,
    fight_score = radar_info[4] / 100,
    assist_score = radar_info[5] / 100
  }
  return res
end
function logic_season_lookback:GetCompareRaderData()
  local last_radar_info = self:GetDataByKey("LastRadarInfo")
  if not last_radar_info or type(last_radar_info) ~= "table" or #last_radar_info < 5 then
    log(bWriteLog and "logic_season_lookback:GetCompareRaderData last_radar_info is invalid")
    return nil
  end
  local res = {
    survive_score = last_radar_info[1] / 100,
    top1_score = last_radar_info[2] / 100,
    rating_score = last_radar_info[3] / 100,
    fight_score = last_radar_info[4] / 100,
    assist_score = last_radar_info[5] / 100
  }
  return res
end
function logic_season_lookback:GetRatingChangeArray()
  if self.sortRatingLog then
    log(bWriteLog and "logic_season_lookback:GetRatingChangeArray use cache")
    return self.sortRatingLog
  end
  local ratingLogData = {}
  local begin_rating = self:GetDataByKey("SeasonBeginRating")
  if begin_rating then
    table.insert(ratingLogData, {rating = begin_rating, time = 0})
  end
  local rating_log = self:GetDataByKey("RatingList", true)
  if not rating_log or rating_log == "" then
    log(bWriteLog and "logic_season_lookback:GetRatingChangeArray no data")
    return ratingLogData
  end
  if type(rating_log) == "string" then
    rating_log = {rating_log}
  end
  if #rating_log < 1 then
    log(bWriteLog and "logic_season_lookback:GetRatingChangeArray no data 2")
    return ratingLogData
  end
  local StringUtil = require("common.string_util")
  for _, oneLog in ipairs(rating_log) do
    local logArray = StringUtil.Split(oneLog, ":")
    if logArray and #logArray == 2 then
      table.insert(ratingLogData, {
        time = tonumber(logArray[1]),
        rating = tonumber(logArray[2])
      })
    end
  end
  table.sort(ratingLogData, function(a, b)
    return a.time < b.time
  end)
  log_tree("logic_season_lookback:GetRatingChangeArray sortRatingLog ", ratingLogData)
  self.sortRatingLog = ratingLogData
  return ratingLogData
end
function logic_season_lookback:GetSeasonMinRatingAndMaxRating()
  local ratingChangeList = self:GetRatingChangeArray()
  if not ratingChangeList or not ratingChangeList[1] then
    log(bWriteLog and "logic_season_lookback:GetSeasonMinRatingAndMaxRating ratingChangeList is invalid")
    return nil, nil
  end
  local minRating = ratingChangeList[1].rating or 0
  local maxRating = ratingChangeList[1].rating or 0
  for _, ratingLog in ipairs(ratingChangeList) do
    if ratingLog.rating and maxRating < ratingLog.rating then
      maxRating = ratingLog.rating
    end
    if ratingLog.rating and minRating > ratingLog.rating then
      minRating = ratingLog.rating
    end
  end
  return minRating, maxRating
end
function logic_season_lookback:GetStartAndFinalSegmentId()
  local ratingChangeList = self:GetRatingChangeArray()
  if not ratingChangeList or not ratingChangeList[1] then
    log(bWriteLog and "logic_season_lookback:GetStartAndFinalSegmentId ratingChangeList is invalid")
    return 101, 101
  end
  local startRating = ratingChangeList[1].rating
  local finalRating = ratingChangeList[#ratingChangeList].rating
  local startSeg = self:ConvertRatingToSegment(startRating) or 101
  local finalSeg = self:ConvertRatingToSegment(finalRating) or 101
  return startSeg, finalSeg
end
function logic_season_lookback:GetSeasonChangeRatingValue()
  local ratingLog = self:GetRatingChangeArray()
  if not ratingLog or #ratingLog < 2 then
    return 0
  end
  local logNum = #ratingLog
  local startRating = ratingLog[1].rating or 0
  local endRating = ratingLog[logNum].rating or 0
  return endRating - startRating
end
function logic_season_lookback:GetMaxRatinigDayData()
  local max_positive_day = self:GetDataByKey("MaxPositiveDay", true)
  if not max_positive_day or type(max_positive_day) ~= "table" or #max_positive_day < 3 then
    log(bWriteLog and "logic_season_lookback:GetMaxRatinigDayData max_positive_day is invalid")
    return 0, 0, 0
  end
  local timestamp = self:ConvertDataTimeStrToTimeStamp(max_positive_day[1]) or 0
  local dayMaxRating = tonumber(max_positive_day[2]) or 0
  local dayGameTime = tonumber(max_positive_day[3]) or 0
  return timestamp, dayMaxRating, dayGameTime / 3600
end
function logic_season_lookback:GetAverageRatinigPerGame()
  local SumAllPositiveRating = self:GetDataByKey("SumAllPositiveRating") or 0
  local SumAllPositiveGameCount = self:GetDataByKey("SumAllPositiveGameCount") or 0
  local avg_positive_rating = 0
  if 0 < SumAllPositiveGameCount then
    avg_positive_rating = SumAllPositiveRating / SumAllPositiveGameCount
  end
  local SumAllSurvivalTime = self:GetDataByKey("SumAllSurvivalTime") or 0
  local SumGameCount = self:GetDataByKey("SumGameCount") or 0
  local avg_gametime = 0
  if 0 < SumGameCount then
    avg_gametime = SumAllSurvivalTime / SumGameCount
  end
  return avg_positive_rating, avg_gametime / 60
end
function logic_season_lookback:GetSeasonMaxSegmentAndTime()
  local MaxSegmentDay = self:GetDataByKey("MaxSegmentDay", true)
  if not MaxSegmentDay or type(MaxSegmentDay) ~= "table" or #MaxSegmentDay < 2 then
    log(bWriteLog and "logic_season_lookback:GetSeasonMaxSegmentAndTime MaxSegmentDay is invalid")
    return nil, nil
  end
  local timestamp = self:ConvertDataTimeStrToTimeStamp(MaxSegmentDay[1]) or 0
  local maxSegment = tonumber(MaxSegmentDay[2]) or 101
  return maxSegment, timestamp
end
function logic_season_lookback:GetMaxRatingWithFriend()
  local rating_with_fri = self:GetDataByKey("MaxRatingFri")
  if not rating_with_fri or type(rating_with_fri) ~= "table" or #rating_with_fri < 2 then
    log(bWriteLog and "logic_season_lookback:GetMaxRatingWithFriend rating_with_fri is invalid")
    return nil, nil
  end
  local uid = rating_with_fri[1]
  local rating = rating_with_fri[2]
  return uid, rating
end
function logic_season_lookback:ConvertRatingToSegment(rating)
  if not rating then
    log(bWriteLog and "logic_season_lookback:ConvertRatingToSegment rating is invalid")
    return nil
  end
  local seasonId = self:GetDataSeasonId()
  local SeasonSystem = require("client.logic.season.logic_season")
  local segment = SeasonSystem.CurLevel(rating, seasonId) or 101
  return tonumber(segment)
end
function logic_season_lookback:GetLikeMapId()
  local max_map_id = self:GetDataByKey("MaxMapId")
  return max_map_id
end
function logic_season_lookback:GetBestWeaponData()
  local WeaponID = self:GetDataByKey("WeaponID")
  if not WeaponID or WeaponID == 0 then
    log(bWriteLog and "logic_season_lookback:GetBestWeaponData WeaponID is invalid")
    return nil
  end
  local critRateValue
  local SumTotalFireCount = self:GetDataByKey("SumTotalFireCount")
  local SumTotalHitCount = self:GetDataByKey("SumTotalHitCount")
  local SumTotalHeadShootCount = self:GetDataByKey("SumTotalHeadShootCount")
  if SumTotalFireCount and SumTotalHeadShootCount and 0 <= SumTotalHeadShootCount and 0 < SumTotalFireCount then
    critRateValue = SumTotalHeadShootCount / SumTotalFireCount
  end
  local hitRateValue
  if SumTotalFireCount and SumTotalHitCount and 0 <= SumTotalHitCount and 0 < SumTotalFireCount then
    hitRateValue = SumTotalHitCount / SumTotalFireCount
  end
  local res = {
    weaponId = WeaponID,
    critRate = critRateValue,
    hitRate = hitRateValue
  }
  return res
end
function logic_season_lookback:GetMostHitParts()
  local hitPartData = self:GetHitPartsData()
  if not hitPartData then
    log(bWriteLog and "logic_season_lookback:GetMostHitParts hitPartData is invalid")
    return nil
  end
  local index
  local hitCount = 0
  for i, hitCnt in ipairs(hitPartData) do
    if hitCnt > hitCount then
      index = i
      hitCount = hitCnt
    end
  end
  return index
end
function logic_season_lookback:GetHitPartsData()
  return {
    self:GetDataByKey("SumTotalHitPosHead", false, true) or 0,
    self:GetDataByKey("SumTotalHitPosBody", false, true) or 0,
    self:GetDataByKey("SumTotalHitPosArm", false, true) or 0,
    self:GetDataByKey("SumTotalHitPosHand", false, true) or 0,
    self:GetDataByKey("SumTotalHitPosFeet", false, true) or 0
  }
end
function logic_season_lookback:GetBestKDDayValue()
  local best_kd_day = self:GetDataByKey("MaxKDDay", true)
  if not best_kd_day or type(best_kd_day) ~= "table" or #best_kd_day < 3 then
    log(bWriteLog and "logic_season_lookback:GetBestKDDayValue best_kd_day is invalid")
    return 0, nil, 0
  end
  local timestamp = self:ConvertDataTimeStrToTimeStamp(best_kd_day[1])
  local kd = (tonumber(best_kd_day[2]) or 0) / 10
  local gameNum = tonumber(best_kd_day[3]) or 0
  return kd, timestamp, math.floor(gameNum)
end
function logic_season_lookback:GetOneGameMaxDamage()
  local max_damage = self:GetDataByKey("MaxDamageDay", true)
  if not max_damage or type(max_damage) ~= "table" or #max_damage < 3 then
    log(bWriteLog and "logic_season_lookback:GetOneGameMaxDamage max_damage is invalid")
    return 0, nil, nil
  end
  local damage = (tonumber(max_damage[2]) or 0) / 100
  return damage, self:ConvertDataTimeStrToTimeStamp(max_damage[1]), tonumber(max_damage[3])
end
function logic_season_lookback:GetOneGameMaxKill()
  local max_kill = self:GetDataByKey("MaxKillingDay", true)
  if not max_kill or type(max_kill) ~= "table" or #max_kill < 3 then
    log(bWriteLog and "logic_season_lookback:GetOneGameMaxKill max_kill is invalid")
    return 0, nil, nil
  end
  return math.floor(tonumber(max_kill[2]) or 0), self:ConvertDataTimeStrToTimeStamp(max_kill[1]), tonumber(max_kill[3])
end
function logic_season_lookback:GetOneGameMaxAssist()
  local max_assist = self:GetDataByKey("MaxAssistDay", true)
  if not max_assist or type(max_assist) ~= "table" or #max_assist < 3 then
    log(bWriteLog and "logic_season_lookback:GetOneGameMaxAssist max_assist is invalid")
    return 0, nil, nil
  end
  return math.floor(tonumber(max_assist[2]) or 0), self:ConvertDataTimeStrToTimeStamp(max_assist[1]), tonumber(max_assist[3])
end
function logic_season_lookback:GetAverageDataPerGame()
  local game_cnt = self:GetDataByKey("SumGameCount") or 0
  if game_cnt == 0 then
    return 0, 0, 0
  end
  local kill_cnt = self:GetDataByKey("SumAllKill") or 0
  local total_damage = (self:GetDataByKey("SumAllDamage") or 0) / 100
  local assist_cnt = self:GetDataByKey("SumAllAssist") or 0
  return kill_cnt / game_cnt, total_damage / game_cnt, assist_cnt / game_cnt
end
function logic_season_lookback:GetFriendListWhenMvp()
  local uids = self:GetDataByKey("TopMvpWithFri")
  if type(uids) == "number" then
    return {uids}
  else
    return uids
  end
end
function logic_season_lookback:GetPlayWithFriendData()
  return self:GetDataByKey("SumKHCount", false, true) or 0, self:GetDataByKey("SumKHTop10Count", false, true) or 0, self:GetDataByKey("SumKHBeHealed", false, true) or 0
end
function logic_season_lookback:GetNotPlayWithFriendData()
  return self:GetDataByKey("SumNKHCount", false, true) or 0, self:GetDataByKey("SumNKHTop10Count", false, true) or 0, self:GetDataByKey("SumNKHBeHealed", false, true) or 0
end
function logic_season_lookback:GetAvgPlayWithFriendData()
  local AvgKHGameStatic = self:GetDataByKey("AvgKHGameStatic", false, true)
  if not AvgKHGameStatic or type(AvgKHGameStatic) ~= "table" or #AvgKHGameStatic < 3 then
    log(bWriteLog and "logic_season_lookback:GetAvgPlayWithFriendData AvgKHGameStatic  is invalid")
    return 0, 0, 0
  end
  return AvgKHGameStatic[1], AvgKHGameStatic[2], AvgKHGameStatic[3]
end
function logic_season_lookback:GetCurSegAvgGameData()
  local AvgGameStatic = self:GetDataByKey("AvgGameStatic", false, true)
  if not AvgGameStatic or type(AvgGameStatic) ~= "table" or #AvgGameStatic < 3 then
    log(bWriteLog and "logic_season_lookback:GetCurSegAvgGameData AvgGameStatic is invalid")
    return 0, 0, 0
  end
  return AvgGameStatic[1], AvgGameStatic[2], AvgGameStatic[3]
end
function logic_season_lookback:GetFriendUidPlayMostGames()
  local kh_max_fri = self:GetDataByKey("MaxGameFri")
  if not kh_max_fri or type(kh_max_fri) ~= "table" or #kh_max_fri < 2 or kh_max_fri[1] == 0 or kh_max_fri[2] <= 0 then
    log(bWriteLog and "logic_season_lookback:GetFriendUidPlayMostGames MaxGameFri is invalid")
    return nil, nil
  end
  return kh_max_fri[1], math.floor(kh_max_fri[2])
end
function logic_season_lookback:GetFriendUidMostAssistance()
  local kh_fri_heal = self:GetDataByKey("FriMaxHeal")
  if not kh_fri_heal or type(kh_fri_heal) ~= "table" or #kh_fri_heal < 2 or kh_fri_heal[1] == 0 or kh_fri_heal[2] <= 0 then
    log(bWriteLog and "logic_season_lookback:GetFriendUidMostAssistance FriMaxHeal is invalid")
    return nil, nil
  end
  return kh_fri_heal[1], math.floor(kh_fri_heal[2])
end
function logic_season_lookback:GetFriendUidBestWinRate()
  local kh_win_ratio = self:GetDataByKey("MaxWinRatioFri")
  if not kh_win_ratio or type(kh_win_ratio) ~= "table" or #kh_win_ratio < 2 or kh_win_ratio[1] == 0 or kh_win_ratio[2] <= 0 then
    log(bWriteLog and "logic_season_lookback:GetFriendUidBestWinRate MaxWinRatioFri is invalid")
    return nil, 0
  end
  return kh_win_ratio[1], kh_win_ratio[2]
end
function logic_season_lookback:GetFriendUidMostTop1()
  local kh_top1_cnt = self:GetDataByKey("MaxWinWithFri")
  if not kh_top1_cnt or type(kh_top1_cnt) ~= "table" or #kh_top1_cnt < 2 or kh_top1_cnt[1] == 0 or kh_top1_cnt[2] <= 0 then
    log(bWriteLog and "logic_season_lookback:GetFriendUidMostTop1 MaxWinWithFri is invalid")
    return nil, nil
  end
  return kh_top1_cnt[1], math.floor(kh_top1_cnt[2])
end
function logic_season_lookback:GetFriendUidFastOut()
  local kh_fri_fast_dead = self:GetDataByKey("MaxFastDeadFri")
  if not kh_fri_fast_dead or type(kh_fri_fast_dead) ~= "table" or #kh_fri_fast_dead < 2 or kh_fri_fast_dead[1] == 0 or kh_fri_fast_dead[2] <= 0 then
    log(bWriteLog and "logic_season_lookback:GetFriendUidFastOut MaxFastDeadFri is invalid")
    return nil, nil
  end
  return kh_fri_fast_dead[1], math.floor(kh_fri_fast_dead[2])
end
function logic_season_lookback:CheckShowGuideInSeason(seasonId)
  if not seasonId then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInSeason no seasonid")
    return false
  end
  if not self:GetEntranceSwitch() then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInSeason not open")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lookbackTipsData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips) or {}
  if lookbackTipsData.seasonid and seasonId <= lookbackTipsData.seasonid then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInSeason hasShow")
    return false
  end
  log(bWriteLog and "logic_season_lookback:CheckShowGuideInSeason Show seasonId:" .. tostring(seasonId))
  return true
end
function logic_season_lookback:CheckShowGuideInCombat(targetUid)
  if not targetUid or tonumber(targetUid) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInCombat not self")
    return false
  end
  if not self:GetEntranceSwitch() then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInCombat not open")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lookbackTipsData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips) or {}
  if lookbackTipsData.combatShow then
    log(bWriteLog and "logic_season_lookback:CheckShowGuideInCombat hasShow")
    return false
  end
  log(bWriteLog and "logic_season_lookback:CheckShowGuideInCombat show")
  return true
end
function logic_season_lookback:SaveSeasonGuideFlag(seasonId)
  if not seasonId then
    log(bWriteLog and "logic_season_lookback:SaveGuideFlag param is nil")
    return
  end
  log(bWriteLog and "logic_season_lookback.SaveGuideFlag seasonid:" .. tostring(seasonId))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lookbackTipsData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips) or {}
  lookbackTipsData.seasonid = seasonId
  PlayerPrefsSystem.SaveTableToFile_N(lookbackTipsData, PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips)
end
function logic_season_lookback:SaveCombatGuideFlag()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lookbackTipsData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips) or {}
  lookbackTipsData.combatShow = 1
  PlayerPrefsSystem.SaveTableToFile_N(lookbackTipsData, PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookbackTips)
end
function logic_season_lookback:GetEntrancePrivacy()
  if self.entrancePrivacy == nil then
    self.entrancePrivacy = false
  end
  return self.entrancePrivacy
end
function logic_season_lookback:send_get_season_lookback_data_req(other_uid, season_id)
  if not other_uid or not season_id then
    log(bWriteLog and "logic_season_lookback:send_get_season_lookback_data_req not param")
    return
  end
  if not self:GetEntranceSwitch() then
    log(bWriteLog and "logic_season_lookback:send_get_season_lookback_data_req not open")
    return
  end
  log(bWriteLog and "logic_season_lookback:send_get_season_lookback_data_req seasonid:" .. tostring(season_id))
  log(bWriteLog and "logic_season_lookback:send_get_season_lookback_data_req other_uid:" .. tostring(other_uid))
  local uid = tonumber(other_uid)
  local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
  SeasonLookBackHandler.send_get_season_lookback_data_req(season_id, uid)
end
function logic_season_lookback:on_get_season_lookback_data_rsp(review_data, season_id, other_uid, reddot_status)
  if not season_id or not other_uid then
    log(bWriteLog and "logic_season_lookback:on_get_season_lookback_data_rsp params is nil")
    return
  end
  self.cache_uid = other_uid
  self.data_  self.lookback_data = review_data
  if DataMgr and DataMgr.roleData and other_uid == tonumber(DataMgr.roleData.uid) then
    local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
    season_redpoint_data.SetLookbackEntryRedData(reddot_status and reddot_status == 1)
    if not review_data or not next(review_data) then
      self:SaveSeasonGuideFlag(season_id)
    end
  end
  EventSystem:postEvent(EVENTTYPE_SEASONLOOKBACK, EVENTID_SEASONLOOKBACK_NEW_GET_DATA_RSP, season_id, reddot_status and reddot_status == 1)
end
function logic_season_lookback:send_get_season_lookback_privacy_req()
  if not self:GetEntranceSwitch() then
    log(bWriteLog and "logic_season_lookback:send_get_season_lookback_privacy_req not open")
    return
  end
  local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
  SeasonLookBackHandler.send_get_season_lookback_privacy_req()
end
function logic_season_lookback:SetEntrancePrivacy(privacy)
  if privacy == nil then
    privacy = false
  end
  self.entrancePrivacy = privacy
end
function logic_season_lookback:send_get_season_lookback_gift_info_req(uid)
  if not uid then
    log(bWriteLog and "logic_season_lookback:send_get_season_lookback_gift_info_req uid is nil")
    return
  end
  if not self:GetEntranceSwitch() then
    log(bWriteLog and "logic_season_lookback:send_get_season_lookback_gift_info_req not open")
    return
  end
  log(bWriteLog and "logic_season_lookback:send_get_season_lookback_gift_info_req")
  local SeasonLookBackHandler = require("client.network.Protocol.SeasonLookBackHandler")
  SeasonLookBackHandler.send_get_season_lookback_gift_info_req(tonumber(uid))
end
function logic_season_lookback:on_get_season_lookback_gift_info_rsp(uid, total_count, last_trend, msg_trend, visitor_count)
  if not uid then
    log(bWriteLog and "logic_season_lookback:on_get_season_lookback_gift_info_rsp uid is nil")
    return
  end
  self.recentGifts = {}
  self.gift_total_count = total_count or 0
  self.visitor_count = visitor_count or 0
  self.recentGifts[uid] = last_trend or {}
  if msg_trend and 0 < #msg_trend then
    for _, gift in ipairs(msg_trend) do
      table.insert(self.recentGifts[uid], gift)
    end
  end
  EventSystem:postEvent(EVENTTYPE_SEASONLOOKBACK, EVENTID_SEASONLOOKBACK_GIFT_DATA_RSP)
end
function logic_season_lookback:ClearData()
  log(bWriteLog and "logic_season_lookback:ClearData")
  self.lookback_data = nil
  self.cache_uid = 0
  self.data_season_id = nil
  self.sortRatingLog = nil
  self.reqProfileList = nil
  self.recentGifts = nil
  self.gift_total_count = 0
  self.visitor_count = 0
end
function logic_season_lookback:ConvertDataTimeStrToTimeStamp(timeStr)
  if not timeStr or timeStr == "" or string.len(timeStr) ~= 8 then
    log(bWriteLog and "logic_season_lookback:ConvertDataTimeStrToTimestamp timeStr is invalid")
    return
  end
  log(bWriteLog and "logic_season_lookback:ConvertDataTimeStrToTimestamp timeStr:" .. timeStr)
  local year = string.sub(timeStr, 1, 4)
  local month = string.sub(timeStr, 5, 6)
  local day = string.sub(timeStr, 7, 8)
  if not (year and month) or not day then
    log(bWriteLog and "logic_season_lookback:ConvertDataTimeStrToTimestamp timeStr is invalid")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local timeStamp = TimeUtil.UnixTimeToUnixstamp(tonumber(year), tonumber(month), tonumber(day), 0, 0, 0, false)
  return timeStamp
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSeasonLookBack = class(CModuleBase, nil, logic_season_lookback)
return CLogicSeasonLookBack
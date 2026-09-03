local gift_const = require("client.slua.logic.gift.gift_const")
local RoleInfoPopularitySystem = {
  TotalPopularity = 0,
  LastWeekDevote = 0,
  PopularityLevel = 0,
  PopularityContriList = {},
  PopularityWeekContriList = {},
  PopularityGuardList = {},
  PopularityWeekGuardList = {},
  PopularityWowList = {},
  PopularityWeekWowList = {},
  PopularityVisitorList = {},
  PopularityRecentList = {},
  PopularityMessageList = {},
  MyGuardList = {},
  RecentListShowCount = 50,
  PopularityContriCount = 20,
  PopularityGuardCount = 20,
  PopularityWowCount = 20,
  RecentVisitorCount = 20,
  GiftSenderCount = 5,
  MyGuardCount = 100,
  PopularityReplyList = {},
  ProudInfo = {},
  GuardInfo = {},
  TitleInfo = {},
  LastEnterTime = 0,
  IsShowDetail = false,
  IsShowReddot = false,
  IsShowMsgReddot = false,
  IsShowMyGuardReddot = false,
  IsShowUCGiftReddot = false,
  AddDevote = 0,
  bHideVisitRecord = false,
  bHasSendGift = false,
  bHideHeatInfomation = false,
  CachedUid = {get_popularity = 0},
  CurrUid = 0,
  _nCurGetDataUId = 0,
  CurPopularityDataUID = 0,
  DevoteGiftType = {Gift1 = 1},
  DevoteRank = {},
  DevoteWeeklyRank = {},
  DevoteTotalCount = 0,
  DevoteMonthlyCount = 0,
  GuardRank = {},
  GuardWeeklyRank = {},
  GuardTotalCount = 0,
  GuardMonthlyCount = 0,
  WowRank = {},
  WowWeeklyRank = {},
  WowTotalCount = 0,
  WowMonthlyCount = 0,
  VisitorInfo = {},
  TodayVisitedCount = 0,
  HistoryVisitedCount = 0,
  LastTrend = {},
  MsgTrend = {},
  LastHighValue = {},
  GiftRecordSummaryRegular = {},
  gift_record_summary = {},
  ReplyList = {},
  GiftSenderList = {},
  Gifts = nil,
  GiftType = 0,
  GiftCount = 0,
  SendGiftMsg = 1,
  ReceiveGiftReply = 2,
  PopularitySimpleCache = {},
  GiftSourceType = gift_const.GiftSourceType,
  RankInfoSelf = {
    popularity_total = -1,
    popularity_week = -1,
    proud_total = -1,
    proud_week = -1
  },
  HighVersionGiftIcon = "/Game/UMG/Texture/Lobby_NoAtlas/RoleInfo/Gift_common.Gift_common",
  PopularityEffectType = gift_const.PopularityEffectType,
  MyTabLocIDList = {
    [1] = {textID = 43199},
    [2] = {textID = 43200},
    [3] = {textID = 43201},
    [4] = {textID = 43202},
    [5] = {textID = 43203},
    [6] = {textID = 34496},
    [7] = {textID = 45955},
    [8] = {textID = 62147}
  },
  HisTabLocIDList = {
    [1] = {textID = 43199},
    [2] = {textID = 43200},
    [3] = {textID = 43201},
    [4] = {textID = 43202},
    [7] = {textID = 45955},
    [8] = {textID = 62147}
  },
  RecentGiftBoxLocID = {
    [1] = 43226,
    [2] = 43227,
    [3] = 43228,
    [4] = 43229,
    [5] = 68724
  },
  TextGreyColor = FSlateColor(FLinearColor(0, 0, 0, 0.4)),
  TextLightColor = FSlateColor(FLinearColor(0, 0, 0, 0.7)),
  ImageGreyColor = FLinearColor(1, 1, 1, 0.5),
  ImageLightColor = FLinearColor(1, 1, 1, 1),
  TextNotEnoughColor = FSlateColor(FLinearColor(0.761, 0.008, 0.044, 1)),
  TextEnoughColor = FSlateColor(FLinearColor(0, 0, 0, 1)),
  EPopularityScene = {
    LeftLobby = 1,
    PersonSpace = 2,
    RoleInfoPopularity = 3,
    SendGift = 4,
    GiftRsp = 5,
    SettingMain = 6,
    AddBlackListRsp = 7,
    Personize = 8
  },
  EDeleteRankType = {
    PopularityTotal = 1,
    PopularityWeek = 2,
    GuardTotal = 3,
    GuardWeek = 4,
    WowTotal = 5,
    WowWeek = 6
  },
  EDeleteMsgScene = {
    Recent = 1,
    Message = 2,
    Reply = 3
  },
  jumpBackUIData = nil,
  autoDeleteHeadCount = 0
}
local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
local SubTabList = {
  [PopularityMacros.ENUM_TAB_TYPE.PopularityPK] = {
    {
      textID = 45953,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK,
      showFuncName = "IsShowPkSubTab"
    },
    {
      textID = 68450,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK_Introduction,
      showFuncName = "IsShowCelebrationIntro"
    },
    {
      textID = 46000,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK_Award,
      showFuncName = "IsShowPKAwardSubTab"
    },
    {
      textID = 68451,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK_TreasureBox,
      showFuncName = "IsShowPkTreasureBoxSubTab"
    },
    {
      textID = 62277,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK_Celebration,
      showFuncName = "IsShowPKCelebrationSubTab"
    },
    {
      textID = 85067,
      subTabID = PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_PK_FunAward,
      showFuncName = "IsShowPKFunAwardSubTab"
    }
  }
}
local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
function RoleInfoPopularitySystem.enter(uid)
  if RoleInfoPopularitySystem.CurrUid ~= tonumber(uid) then
    RoleInfoPopularitySystem.leave()
  end
  RoleInfoPopularitySystem.CurrUid = tonumber(uid)
  log(bWriteLog and "RoleInfoPopularitySystem.enter:" .. tostring(uid))
end
function RoleInfoPopularitySystem.leave()
  RoleInfoPopularitySystem.PopularityContriList = {}
  RoleInfoPopularitySystem.PopularityWeekContriList = {}
  RoleInfoPopularitySystem.PopularityGuardList = {}
  RoleInfoPopularitySystem.PopularityWeekGuardList = {}
  RoleInfoPopularitySystem.PopularityWowList = {}
  RoleInfoPopularitySystem.PopularityWeekWowList = {}
  RoleInfoPopularitySystem.PopularityRecentList = {}
  RoleInfoPopularitySystem.PopularityMessageList = {}
  RoleInfoPopularitySystem.PopularityVisitorList = {}
  RoleInfoPopularitySystem.MyGuardList = {}
  RoleInfoPopularitySystem.TotalPopularity = 0
  RoleInfoPopularitySystem.CachedUid.get_popularity = 0
  RoleInfoPopularitySystem.DevoteRank = {}
  RoleInfoPopularitySystem.DevoteWeeklyRank = {}
  RoleInfoPopularitySystem.GuardRank = {}
  RoleInfoPopularitySystem.GuardWeeklyRank = {}
  RoleInfoPopularitySystem.VisitorInfo = {}
  RoleInfoPopularitySystem.GuardInfo = {}
  RoleInfoPopularitySystem.LastTrend = {}
  RoleInfoPopularitySystem.MsgTrend = {}
  RoleInfoPopularitySystem.IsShowReddot = false
  RoleInfoPopularitySystem.IsShowMsgReddot = false
  RoleInfoPopularitySystem.LastHighValue = {}
  RoleInfoPopularitySystem.Gifts = nil
  RoleInfoPopularitySystem.RankInfoSelf = {
    popularity_total = -1,
    popularity_week = -1,
    proud_total = -1,
    proud_week = -1
  }
end
function RoleInfoPopularitySystem.send_get_pspace_hidden_visitor_track()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_get_pspace_hidden_visitor_track()
end
function RoleInfoPopularitySystem.on_get_pspace_hidden_visitor_track(switch)
  log(bWriteLog and "RoleInfoPopularitySystem.on_get_pspace_hidden_visitor_track switch = " .. tostring(switch))
  RoleInfoPopularitySystem.bHideVisitRecord = switch
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_HIDE_VISIT_RECORD)
end
function RoleInfoPopularitySystem.send_set_pspace_hidden_visitor_track(switch)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_pspace_hidden_visitor_track(switch)
end
function RoleInfoPopularitySystem.on_set_pspace_hidden_visitor_track(switch)
  log(bWriteLog and "RoleInfoPopularitySystem.on_set_pspace_hidden_visitor_track switch = " .. tostring(switch))
  RoleInfoPopularitySystem.bHideVisitRecord = switch
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_HIDE_VISIT_RECORD)
end
function RoleInfoPopularitySystem.get_popularity_req(uid, eScene)
  log(bWriteLog and "get_popularity_req:" .. tostring(uid) .. " with scene enum: " .. tostring(eScene))
  RoleInfoPopularitySystem._nCurGetDataUId = uid
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_popularity_req(tonumber(uid), eScene)
end
function RoleInfoPopularitySystem.get_popularity_rsp(ok, uid, total_devote, gift_record, is_show_detail, is_show_reddot, devote_rank, last_trend, reply_list, gift_record_summary, last_enter_pspace_time, last_week_devote, msg_trend, last_high_value, is_show_msg_reddot, pround_info, guardian_info, visitor_info, devote_level, guardian_rank, pspace_collect, summary_render_info, is_show_guardian_reddot, is_having_gift_record, ret_creative_rank)
  log(bWriteLog and "get_popularity_rsp - ok:" .. tostring(ok) .. ",uid:" .. tostring(uid) .. ",total_devote:" .. tostring(total_devote) .. ",is_show_detail:" .. tostring(is_show_detail) .. ",is_show_reddot:" .. tostring(is_show_reddot) .. ".last_enter_pspace_time:" .. tostring(last_enter_pspace_time) .. ",last_week_devote:" .. tostring(last_week_devote) .. ",is_show_msg_reddot:" .. tostring(is_show_msg_reddot) .. ",devote_level:" .. tostring(devote_level) .. ",is_show_guardian_reddot:" .. tostring(is_show_guardian_reddot) .. ",is_having_gift_record:" .. tostring(is_having_gift_record) .. ",ret_creative_rank:" .. tostring(ret_creative_rank))
  if ok ~= 0 then
    if ok == 540016 then
      ShowNotice(44236)
      RoleInfoPopularitySystem.bHideHeatInfomation = true
    end
    return
  end
  if tostring(uid) ~= tostring(RoleInfoPopularitySystem._nCurGetDataUId) then
    return
  end
  RoleInfoPopularitySystem.bHideHeatInfomation = false
  RoleInfoPopularitySystem.CurPopularityDataUID = uid
  log_tree("gift_record", gift_record)
  log_tree("devote_rank", devote_rank)
  log_tree("last_trend", last_trend)
  log_tree("reply_list", reply_list)
  log_tree("gift_record_summary", gift_record_summary)
  log_tree("msg_trend", msg_trend)
  log_tree("last_high_value", last_high_value)
  log_tree("pround_info", pround_info)
  log_tree("guardian_info", guardian_info)
  log_tree("guardian_rank", guardian_rank)
  log_tree("visitor_info", visitor_info)
  log_tree("pspace_collect", pspace_collect)
  log_tree("summary_render_info", summary_render_info)
  RoleInfoPopularitySystem.TotalPopularity = total_devote
  RoleInfoPopularitySystem.PopularityLevel = devote_level or 0
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if is_show_detail == true then
      RoleInfoPopularitySystem.IsShowDetail = 1
    elseif is_show_detail == false then
      RoleInfoPopularitySystem.IsShowDetail = 0
    elseif is_show_detail == nil then
      RoleInfoPopularitySystem.IsShowDetail = 0
    else
      RoleInfoPopularitySystem.IsShowDetail = is_show_detail
    end
  else
    RoleInfoPopularitySystem.IsShowDetail = is_show_detail
  end
  RoleInfoPopularitySystem.bHasSendGift = is_having_gift_record
  logic_send_gift.get_pop_gift_record_rsp(ok, gift_record, uid, gift_record_summary, pspace_collect)
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    RoleInfoPopularitySystem.IsShowReddot = is_show_reddot or false
    RoleInfoPopularitySystem.IsShowMsgReddot = is_show_msg_reddot or false
    RoleInfoPopularitySystem.IsShowMyGuardReddot = is_show_guardian_reddot or false
  end
  RoleInfoPopularitySystem.LastTrend = last_trend
  RoleInfoPopularitySystem.MsgTrend = msg_trend
  RoleInfoPopularitySystem.LastWeekDevote = last_week_devote or 0
  RoleInfoPopularitySystem.LastHighValue = last_high_value or {}
  RoleInfoPopularitySystem.RecentVisitorList = {}
  if visitor_info and visitor_info.visitor_list then
    RoleInfoPopularitySystem.RecentVisitorList = visitor_info.visitor_list
  end
  if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
    local cur_pround_level = 0
    if DataMgr.roleData.pround_info then
      cur_pround_level = DataMgr.roleData.pround_info.level or 0
    end
    local TimeUtil = require("client.common.time_util")
    RoleInfoPopularitySystem.RecentVisitorList[tonumber(DataMgr.roleData.uid)] = {
      pround_level = cur_pround_level,
      nickname = DataMgr.roleData.nickName,
      last_visited_ts = TimeUtil.GetServerTimeInSec()
    }
  end
  if devote_rank then
    RoleInfoPopularitySystem.DevoteRank = devote_rank.overall_rank or {}
    RoleInfoPopularitySystem.DevoteWeeklyRank = devote_rank.weekly_rank or {}
    RoleInfoPopularitySystem.DevoteTotalCount = devote_rank.total_count or 0
    RoleInfoPopularitySystem.DevoteMonthlyCount = devote_rank.monthly_count or 0
  end
  if guardian_rank then
    RoleInfoPopularitySystem.GuardRank = guardian_rank.overall_rank or {}
    RoleInfoPopularitySystem.GuardWeeklyRank = guardian_rank.weekly_rank or {}
    RoleInfoPopularitySystem.GuardTotalCount = guardian_rank.total_count or {}
    RoleInfoPopularitySystem.GuardMonthlyCount = guardian_rank.monthly_count or {}
  end
  if ret_creative_rank then
    RoleInfoPopularitySystem.WowRank = ret_creative_rank.creative_rank or {}
    RoleInfoPopularitySystem.WowWeeklyRank = ret_creative_rank.weekly_creative_rank or {}
  end
  RoleInfoPopularitySystem.ProudInfo = pround_info or {}
  RoleInfoPopularitySystem.GuardInfo = guardian_info or {}
  RoleInfoPopularitySystem.TitleInfo = summary_render_info or {}
  RoleInfoPopularitySystem.VisitorInfo = {}
  RoleInfoPopularitySystem.TodayVisitedCount = 0
  RoleInfoPopularitySystem.HistoryVisitedCount = 0
  if visitor_info then
    RoleInfoPopularitySystem.VisitorInfo = visitor_info.visitor_list or {}
    RoleInfoPopularitySystem.TodayVisitedCount = visitor_info.today_visited_count or 0
    RoleInfoPopularitySystem.HistoryVisitedCount = visitor_info.history_visitor_count or 0
  end
  RoleInfoPopularitySystem.LastEnterTime = last_enter_pspace_time or 0
  RoleInfoPopularitySystem.ParseGiftRecordSummary(gift_record_summary, pspace_collect)
  RoleInfoPopularitySystem.ReplyList = reply_list or {}
  if tostring(uid) == tostring(DataMgr.roleData.uid) then
    local logic_pround = require("client.slua.logic.pround.logic_pround")
    logic_pround.UpdateSelfProundInfo(pround_info)
  end
  RoleInfoPopularitySystem.CachedUid.get_popularity = tostring(uid)
  local prev_popularity
  local cached_data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)]
  if cached_data and cached_data.total_devote then
    prev_popularity = cached_data.total_devote
  end
  local data = {total_devote = total_devote, is_show_detail = is_show_detail}
  RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)] = data
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_SIMPLE_RSP, uid, data)
  RoleInfoPopularitySystem.update_self_popularity(uid, prev_popularity)
  logic_send_gift.ClearUpvoteGiftRecord(uid)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, uid)
end
function RoleInfoPopularitySystem.ParseGiftRecordSummary(gift_record_summary, pspace_collect)
  RoleInfoPopularitySystem.gift_record_summary = gift_record_summary or {}
  for k, v in pairs(RoleInfoPopularitySystem.gift_record_summary) do
    if pspace_collect and pspace_collect[k] and pspace_collect[k].provide_uid then
      v.provide_uid = pspace_collect[k].provide_uid
    end
  end
end
function RoleInfoPopularitySystem.get_popularity_simple_req(uid)
  log(bWriteLog and "get_popularity_simple_req:" .. tostring(uid))
  if uid == nil then
    return
  end
  local data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)]
  if data then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_SIMPLE_RSP, uid, data)
    return
  end
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_popularity_simple_req(tonumber(uid))
end
function RoleInfoPopularitySystem.get_popularity_simple_rsp(res, uid, total_devote, is_show_detail)
  log(bWriteLog and "get_popularity_simple_rsp:" .. tostring(res) .. ",uid:" .. tostring(uid) .. ",total_devote:" .. tostring(total_devote) .. ",is_show_detail:" .. tostring(is_show_detail))
  if res ~= 0 then
    return
  end
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if is_show_detail == 0 then
      is_show_detail = false
    elseif is_show_detail == 1 then
      is_show_detail = true
    elseif is_show_detail == 2 then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if not LogicFriend.IsMyFriend(uid) then
        is_show_detail = false
      else
        is_show_detail = true
      end
    end
  end
  local data = {total_devote = total_devote, is_show_detail = is_show_detail}
  RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)] = data
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_SIMPLE_RSP, uid, data)
end
function RoleInfoPopularitySystem.CheckNeedGuidePopup()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local playerSlapData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemGuide) or {}
  return not playerSlapData.bHasSlap
end
function RoleInfoPopularitySystem.SaveGuidePopupData()
  log(bWriteLog and "RoleInfoPopularitySystem.SaveGuidePopupData")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local playerSlapData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemGuide) or {}
  playerSlapData.bHasSlap = true
  PlayerPrefsSystem.SaveTableToFile_N(playerSlapData, PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemGuide)
end
function RoleInfoPopularitySystem.GetFormatGuardTimeStr(day)
  local formatTimeStr = ""
  if not day then
    log(bWriteLog and "RoleInfoPopularitySystem.GetFormatGuardTimeStr day = nil")
    return formatTimeStr
  end
  if day < 365 then
    formatTimeStr = LocUtil.LocalizeResFormat(43242, day)
  else
    local year = string.format("%.2f", day / 365)
    formatTimeStr = LocUtil.LocalizeResFormat(654, year)
  end
  return formatTimeStr
end
function RoleInfoPopularitySystem.GetPopularityTop3Rank(uid)
  local rank
  local totalTop3UIDList = RoleInfoPopularitySystem.TitleInfo.devote_top3_rank
  if totalTop3UIDList then
    for k, v in ipairs(totalTop3UIDList) do
      if tostring(uid) == tostring(v) then
        ran        break
      end
    end
  end
  if rank then
    log(bWriteLog and "RoleInfoPopularitySystem.GetPopularityTop3Rank total rank = " .. tostring(rank))
    rank = FuncUtil.Clamp(rank, 1, 3)
    return rank, true
  end
  local weekTop3UIDList = RoleInfoPopularitySystem.TitleInfo.weekly_devote_top3_rank
  if weekTop3UIDList then
    for k, v in ipairs(weekTop3UIDList) do
      if tostring(uid) == tostring(v) then
        ran        break
      end
    end
  end
  if rank then
    log(bWriteLog and "RoleInfoPopularitySystem.GetPopularityTop3Rank weekly rank = " .. tostring(rank))
    rank = FuncUtil.Clamp(rank, 1, 3)
    return rank, false
  end
  return nil, nil
end
function RoleInfoPopularitySystem.GetGuardTop3Rank(uid)
  local rank
  local totalTop3UIDList = RoleInfoPopularitySystem.TitleInfo.guardian_top3_rank
  if totalTop3UIDList then
    for k, v in ipairs(totalTop3UIDList) do
      if tostring(uid) == tostring(v) then
        ran        break
      end
    end
  end
  if rank then
    log(bWriteLog and "RoleInfoPopularitySystem.GetGuardTop3Rank total rank = " .. tostring(rank))
    rank = FuncUtil.Clamp(rank, 1, 3)
    return rank, true
  end
  local weekTop3UIDList = RoleInfoPopularitySystem.TitleInfo.weekly_guardian_top3_rank
  if weekTop3UIDList then
    for k, v in ipairs(weekTop3UIDList) do
      if tostring(uid) == tostring(v) then
        ran        break
      end
    end
  end
  if rank then
    log(bWriteLog and "RoleInfoPopularitySystem.GetGuardTop3Rank weekly rank = " .. tostring(rank))
    rank = FuncUtil.Clamp(rank, 1, 3)
    return rank, false
  end
  return nil, nil
end
function RoleInfoPopularitySystem.CheckIsGuardian(uid)
  local guardUIDList = RoleInfoPopularitySystem.TitleInfo.being_guardian_list
  if guardUIDList and guardUIDList[tonumber(uid)] then
    log(bWriteLog and "RoleInfoPopularitySystem.CheckIsGuardian is guardian uid = " .. tostring(uid))
    return true
  end
  return false
end
function RoleInfoPopularitySystem.GetGuardGiftTime(giftID)
  local GuardGiftConfig = CDataTable.GetTableData("GuardGiftConfig", giftID)
  local guardTime = 0
  if GuardGiftConfig then
    guardTime = GuardGiftConfig.GuardTime
  end
  return guardTime
end
function RoleInfoPopularitySystem.InitGiftRecordSummary()
  RoleInfoPopularitySystem.GiftRecordSummaryRegular = {}
  for i, v in ipairs(RoleInfoPopularitySystem.GetSummaryGifts()) do
    local record = RoleInfoPopularitySystem.gift_record_summary[v.GiftId] or {}
    local count = record.count or 0
    if v.GiftType ~= 3 then
      table.insert(RoleInfoPopularitySystem.GiftRecordSummaryRegular, {
        GiftId = v.GiftId,
        TotalCount = count,
        GiftInfo = v,
        provide_uid = record.provide_uid,
        GiftOrder = v.GiftOrder
      })
    end
    if v.GiftType == 3 and 0 < count then
      table.insert(RoleInfoPopularitySystem.GiftRecordSummaryRegular, {
        GiftId = v.GiftId,
        TotalCount = count,
        GiftInfo = v,
        provide_uid = record.provide_uid,
        GiftOrder = v.GiftOrder
      })
    end
  end
end
function RoleInfoPopularitySystem.GetSummaryGifts()
  local giftTable = logic_send_gift.GetAllGiftsConfig()
  if giftTable == nil then
    return nil
  end
  local gifts = {}
  for i, v in pairs(giftTable) do
    table.insert(gifts, v)
  end
  table.sort(gifts, function(gift1, gift2)
    return gift1.GiftOrder < gift2.GiftOrder
  end)
  return gifts
end
function RoleInfoPopularitySystem.GetSortedGiftList()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  local sortedTable = {}
  for k, v in ipairs(RoleInfoPopularitySystem.GiftRecordSummaryRegular) do
    if not v.GiftInfo then
      log(bWriteLog and "RoleInfoPopularitySystem.GetSortedGiftList v.GiftInfo = nil")
      break
    end
    if bIsBLUEHOLE then
      if v.GiftInfo.GiftType == gift_const.EGiftType.Normal or v.GiftInfo.GiftType == gift_const.EGiftType.Guard or v.GiftInfo.GiftType == gift_const.EGiftType.Activity then
        table.insert(sortedTable, v)
      end
    elseif v.GiftInfo.GiftType == gift_const.EGiftType.Normal or v.GiftInfo.GiftType == gift_const.EGiftType.Guard or v.GiftInfo.GiftType == gift_const.EGiftType.Activity or v.GiftInfo.GiftType == gift_const.EGiftType.Home then
      table.insert(sortedTable, v)
    end
  end
  if next(sortedTable) ~= nil then
    table.sort(sortedTable, function(a, b)
      if a.TotalCount == b.TotalCount then
        return a.GiftOrder < b.GiftOrder
      end
      return a.TotalCount > b.TotalCount
    end)
  end
  return sortedTable
end
function RoleInfoPopularitySystem.IsSelf()
  return tonumber(RoleInfoPopularitySystem.CurrUid) == tonumber(DataMgr.roleData.uid)
end
function RoleInfoPopularitySystem.get_popularity_devote_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_devote_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_devote_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  RoleInfoPopularitySystem.PopularityContriList = {}
  local gids = {}
  if RoleInfoPopularitySystem.DevoteRank then
    for _, devoteInfo in pairs(RoleInfoPopularitySystem.DevoteRank) do
      if not devoteInfo.uid then
        log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_devote_rank_profile not uid")
        return
      end
      local devoteUid = devoteInfo.uid
      if not logic_friend_blacklist:IsBlacklist(devoteUid) then
        table.insert(gids, tonumber(devoteUid))
        if type(devoteInfo) == "number" then
          table.insert(RoleInfoPopularitySystem.PopularityContriList, {
            gid = tostring(devoteUid),
            devote = devoteInfo
          })
        else
          table.insert(RoleInfoPopularitySystem.PopularityContriList, {
            gid = tostring(devoteUid),
            devote = devoteInfo.value,
            last_devote_time = devoteInfo.last_devote_time
          })
        end
      end
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityContriList", RoleInfoPopularitySystem.PopularityContriList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityContriList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityContriList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityContriList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityContriList, function(a, b)
          return a and b and a.devote == b.devote and (a.last_devote_time or 0) < (b.last_devote_time or 0) or (a.devote or 0) > (b.devote or 0)
        end)
        while #RoleInfoPopularitySystem.PopularityContriList > RoleInfoPopularitySystem.PopularityContriCount do
          table.remove(RoleInfoPopularitySystem.PopularityContriList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityContriList profile", RoleInfoPopularitySystem.PopularityContriList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_devote_weekly_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_devote_weekly_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_devote_weekly_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  RoleInfoPopularitySystem.PopularityWeekContriList = {}
  local gids = {}
  for _, devoteInfo in pairs(RoleInfoPopularitySystem.DevoteWeeklyRank) do
    if not devoteInfo.uid then
      log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_devote_weekly_rank_profile not uid")
      return
    end
    local devoteUid = devoteInfo.uid
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    if not logic_friend_blacklist:IsBlacklist(devoteUid) then
      table.insert(gids, tonumber(devoteUid))
      if type(devoteInfo) == "number" then
        table.insert(RoleInfoPopularitySystem.PopularityWeekContriList, {
          gid = tostring(devoteUid),
          devote = devoteInfo
        })
      else
        table.insert(RoleInfoPopularitySystem.PopularityWeekContriList, {
          gid = tostring(devoteUid),
          devote = devoteInfo.value,
          last_devote_time = devoteInfo.last_devote_time
        })
      end
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityWeekContriList", RoleInfoPopularitySystem.PopularityWeekContriList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityWeekContriList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityWeekContriList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityWeekContriList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityWeekContriList, function(a, b)
          return a and b and a.devote == b.devote and (a.last_devote_time or 0) < (b.last_devote_time or 0) or (a.devote or 0) > (b.devote or 0)
        end)
        while #RoleInfoPopularitySystem.PopularityWeekContriList > RoleInfoPopularitySystem.PopularityContriCount do
          table.remove(RoleInfoPopularitySystem.PopularityWeekContriList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityWeekContriList profile", RoleInfoPopularitySystem.PopularityWeekContriList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_guard_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_guard_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_guard_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  RoleInfoPopularitySystem.PopularityGuardList = {}
  local gids = {}
  for _, guardInfo in pairs(RoleInfoPopularitySystem.GuardRank) do
    if not guardInfo.uid then
      log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_guard_rank_profile not uid")
      return
    end
    local devoteUid = guardInfo.uid
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    if not logic_friend_blacklist:IsBlacklist(devoteUid) then
      table.insert(gids, tonumber(devoteUid))
      table.insert(RoleInfoPopularitySystem.PopularityGuardList, {
        gid = tostring(devoteUid),
        total_guardian = guardInfo.total_guardian,
        remain_guardian = guardInfo.remain_guardian,
        remain_gift_level = guardInfo.remain_gift_level,
        last_guardian_ts = guardInfo.last_guardian_ts,
        is_guard = true
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityGuardList", RoleInfoPopularitySystem.PopularityGuardList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityGuardList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityGuardList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityGuardList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityGuardList, function(a, b)
          if a and b then
            if a.remain_gift_level == b.remain_gift_level then
              if a.total_guardian == b.total_guardian then
                if a.remain_guardian == b.remain_guardian then
                  return (a.last_guardian_ts or 0) > (b.last_guardian_ts or 0)
                else
                  return (a.remain_guardian or 0) > (b.remain_guardian or 0)
                end
              else
                return (a.total_guardian or 0) > (b.total_guardian or 0)
              end
            else
              return (a.remain_gift_level or 0) > (b.remain_gift_level or 0)
            end
          end
        end)
        while #RoleInfoPopularitySystem.PopularityGuardList > RoleInfoPopularitySystem.PopularityGuardCount do
          table.remove(RoleInfoPopularitySystem.PopularityGuardList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityGuardList profile", RoleInfoPopularitySystem.PopularityGuardList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_guard_weekly_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_guard_weekly_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_guard_weekly_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  RoleInfoPopularitySystem.PopularityWeekGuardList = {}
  local gids = {}
  for _, guardInfo in pairs(RoleInfoPopularitySystem.GuardWeeklyRank) do
    if not guardInfo.uid then
      log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_guard_weekly_rank_profile not uid")
      return
    end
    local devoteUid = guardInfo.uid
    if not logic_friend_blacklist:IsBlacklist(devoteUid) then
      table.insert(gids, tonumber(devoteUid))
      table.insert(RoleInfoPopularitySystem.PopularityWeekGuardList, {
        gid = tostring(devoteUid),
        total_guardian = guardInfo.total_guardian,
        remain_guardian = guardInfo.remain_guardian,
        remain_gift_level = guardInfo.remain_gift_level,
        last_guardian_ts = guardInfo.last_guardian_ts,
        is_guard = true
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityWeekGuardList", RoleInfoPopularitySystem.PopularityWeekGuardList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityWeekGuardList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityWeekGuardList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityWeekGuardList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityWeekGuardList, function(a, b)
          if a and b then
            if a.remain_gift_level == b.remain_gift_level then
              if a.total_guardian == b.total_guardian then
                if a.remain_guardian == b.remain_guardian then
                  return (a.last_guardian_ts or 0) > (b.last_guardian_ts or 0)
                else
                  return (a.remain_guardian or 0) > (b.remain_guardian or 0)
                end
              else
                return (a.total_guardian or 0) > (b.total_guardian or 0)
              end
            else
              return (a.remain_gift_level or 0) > (b.remain_gift_level or 0)
            end
          end
        end)
        while #RoleInfoPopularitySystem.PopularityWeekGuardList > RoleInfoPopularitySystem.PopularityGuardCount do
          table.remove(RoleInfoPopularitySystem.PopularityWeekGuardList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityWeekGuardList profile", RoleInfoPopularitySystem.PopularityWeekGuardList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_visitor_list_profile(CurrUid)
  log(bWriteLog and "get_visitor_list_profile:" .. tostring(CurrUid))
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_visitor_list_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  RoleInfoPopularitySystem.PopularityVisitorList = {}
  local gids = {}
  for uid, visitorInfo in pairs(RoleInfoPopularitySystem.VisitorInfo) do
    if not logic_friend_blacklist:IsBlacklist(uid) then
      table.insert(gids, tonumber(uid))
      table.insert(RoleInfoPopularitySystem.PopularityVisitorList, {
        gid = tostring(uid),
        last_visited_ts = visitorInfo.last_visited_ts
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityVisitorList", RoleInfoPopularitySystem.PopularityVisitorList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityVisitorList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityVisitorList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityVisitorList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityVisitorList, function(a, b)
          return (a.last_visited_ts or 0) > (b.last_visited_ts or 0)
        end)
        while #RoleInfoPopularitySystem.PopularityVisitorList > RoleInfoPopularitySystem.RecentVisitorCount do
          table.remove(RoleInfoPopularitySystem.PopularityVisitorList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityVisitorList profile", RoleInfoPopularitySystem.PopularityVisitorList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_my_guard_profile(CurrUid)
  log(bWriteLog and "get_my_guard_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_my_guard_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  RoleInfoPopularitySystem.MyGuardList = {}
  local gids = {}
  for uid, guardInfo in pairs(RoleInfoPopularitySystem.GuardInfo) do
    if not logic_friend_blacklist:IsBlacklist(uid) then
      table.insert(gids, tonumber(uid))
      table.insert(RoleInfoPopularitySystem.MyGuardList, {
        gid = tostring(uid),
        total_guardian = guardInfo.total_guardian,
        remain_guardian = guardInfo.remain_guardian,
        remain_gift_level = guardInfo.remain_gift_level,
        last_guardian_ts = guardInfo.last_guardian_ts or 0
      })
    end
  end
  log_tree("RoleInfoPopularitySystem MyGuardList", RoleInfoPopularitySystem.MyGuardList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.MyGuardList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.MyGuardList = listAfterDelete
      if next(RoleInfoPopularitySystem.MyGuardList) ~= nil then
        table.sort(RoleInfoPopularitySystem.MyGuardList, function(a, b)
          if a.remain_gift_level == b.remain_gift_level then
            if a.total_guardian == b.total_guardian then
              if a.remain_guardian == b.remain_guardian then
                return a.last_guardian_ts > b.last_guardian_ts
              end
              return a.remain_guardian > b.remain_guardian
            end
            return a.total_guardian > b.total_guardian
          end
          return a.remain_gift_level > b.remain_gift_level
        end)
      end
      if next(RoleInfoPopularitySystem.MyGuardList) ~= nil then
        while #RoleInfoPopularitySystem.MyGuardList > RoleInfoPopularitySystem.MyGuardCount do
          table.remove(RoleInfoPopularitySystem.MyGuardList)
        end
      end
      log_tree("RoleInfoPopularitySystem MyGuardList profile", RoleInfoPopularitySystem.MyGuardList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_last_trend_profile(CurrUid)
  log(bWriteLog and "get_popularity_last_trend_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_last_trend_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  RoleInfoPopularitySystem.PopularityRecentList = {}
  local gids = {}
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  for k, v in pairs(RoleInfoPopularitySystem.LastTrend) do
    if not logic_friend_blacklist:IsBlacklist(v.uid) then
      table.insert(gids, tonumber(v.uid))
      local msg = logic_chat_main.ReplaceEmoji(v.msg or "")
      local reply = logic_chat_main.ReplaceEmoji(v.reply or "")
      local is_top = false
      local topTime = logic_send_gift.GetGiftEffectParam(v.gift_type, v.gift_count, RoleInfoPopularitySystem.PopularityEffectType.RecentGiftTop)
      if topTime and curTime < v.devote_time + topTime then
        is_top = true
      end
      local effectID = logic_send_gift.GetGiftEffectParam(v.gift_type, v.gift_count, RoleInfoPopularitySystem.PopularityEffectType.RecentGiftImage)
      table.insert(RoleInfoPopularitySystem.PopularityRecentList, {
        index = k,
        id = v.id,
        gid = tostring(v.uid),
        datetime = v.devote_time,
        gift_type = v.gift_type,
        gift_count = v.gift_count or 1,
        msg = msg,
        reply = reply,
        reply_time = v.reply_time or 0,
        top_time = v.top_time or 0,
        source = tonumber(v.source) or nil,
        is_gift = true,
        is_top = is_top,
        effect_id = effectID,
        add_devote_value = v.add_devote_value,
        bIsLastTrend = true,
        add_creative_score = v.add_creative_score
      })
    end
  end
  for k, v in pairs(RoleInfoPopularitySystem.MsgTrend) do
    if not logic_friend_blacklist:IsBlacklist(v.uid) then
      table.insert(gids, tonumber(v.uid))
      local msg = logic_chat_main.ReplaceEmoji(v.msg or "")
      local reply = logic_chat_main.ReplaceEmoji(v.reply or "")
      local bIsTop = false
      local topTime = logic_send_gift.GetGiftEffectParam(v.gift_type, v.gift_count, RoleInfoPopularitySystem.PopularityEffectType.RecentGiftTop)
      if topTime and curTime < v.devote_time + topTime then
        bIsTop = true
      end
      local effectID = logic_send_gift.GetGiftEffectParam(v.gift_type, v.gift_count, RoleInfoPopularitySystem.PopularityEffectType.RecentGiftImage)
      table.insert(RoleInfoPopularitySystem.PopularityRecentList, {
        index = k,
        id = v.id,
        gid = tostring(v.uid),
        datetime = v.devote_time,
        gift_type = v.gift_type,
        gift_count = v.gift_count or 1,
        msg = msg,
        reply = reply,
        reply_time = v.reply_time or 0,
        top_time = v.top_time or 0,
        source = tonumber(v.source) or nil,
        is_gift = true,
        is_top = bIsTop,
        effect_id = effectID,
        add_devote_value = v.add_devote_value,
        bIsLastTrend = false
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityRecentList", RoleInfoPopularitySystem.PopularityRecentList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityRecentList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityRecentList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityRecentList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityRecentList, function(a, b)
          if a.is_top and not b.is_top then
            return true
          elseif not a.is_top and b.is_top then
            return false
          end
          return a.datetime > b.datetime
        end)
        while #RoleInfoPopularitySystem.PopularityRecentList > RoleInfoPopularitySystem.RecentListShowCount do
          table.remove(RoleInfoPopularitySystem.PopularityRecentList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityRecentList profile", RoleInfoPopularitySystem.PopularityRecentList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_LAST)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_LAST_TREND_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_msg_trend_profile_when_delete_others_reply(msg_trend)
  log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_msg_trend_profile_when_delete_others_reply")
  RoleInfoPopularitySystem.get_popularity_req(DataMgr.roleData.uid, RoleInfoPopularitySystem.EPopularityScene.RoleInfoPopularity)
end
function RoleInfoPopularitySystem.get_popularity_msg_trend_profile(CurrUid)
  log(bWriteLog and "get_popularity_msg_trend_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_msg_trend_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity) .. ", isSelf = " .. tostring(isSelf))
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  RoleInfoPopularitySystem.PopularityMessageList = {}
  local gids = {}
  local table_try_delete = {}
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  for k, v in pairs(RoleInfoPopularitySystem.MsgTrend) do
    if not logic_friend_blacklist:IsBlacklist(v.uid) then
      table_try_delete[tonumber(v.uid)] = true
      table.insert(gids, tonumber(v.uid))
      local msg = logic_chat_main.ReplaceEmoji(v.msg or "")
      local reply = logic_chat_main.ReplaceEmoji(v.reply or "")
      table.insert(RoleInfoPopularitySystem.PopularityMessageList, {
        index = k,
        id = v.id,
        gid = tostring(v.uid),
        datetime = v.devote_time,
        gift_type = v.gift_type,
        gift_count = v.gift_count or 1,
        msg = msg,
        reply = reply,
        reply_time = v.reply_time or 0,
        top_time = v.top_time or 0
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityMessageList", RoleInfoPopularitySystem.PopularityMessageList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local profile_uid_table = {}
      log_tree("PersonSpaceSystem GetProfileList list", list)
      for j, currProfile in pairs(list) do
        if not logic_profile:IsPlayerBanned(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) then
          log(bWriteLog and string.format("RoleInfoPopularitySystem.get_popularity_msg_trend_profile uid %s is normal", currProfile.uid))
          table_try_delete[tonumber(currProfile.uid)] = nil
          profile_uid_table[tonumber(currProfile.uid)] = currProfile
        end
      end
      for i, data in ipairs(RoleInfoPopularitySystem.PopularityMessageList) do
        if table_try_delete[tonumber(data.gid)] then
          log(bWriteLog and string.format("RoleInfoPopularitySystem.get_popularity_msg_trend_profile uid is delete, uid = %s index = %s id = %s", data.gid, data.index, data.id))
          local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
          RoleInfoPopularitySystem.delete_gift_record_req(data.index, data.id, RoleInfoPopularitySystem.EDeleteMsgScene.Message)
          RoleInfoPopularitySystem.autoDeleteHeadCount = RoleInfoPopularitySystem.autoDeleteHeadCount + 1
        else
          PersonSpaceSystem.AddProfileData(data, profile_uid_table[tonumber(data.gid)])
          table.insert(listAfterDelete, data)
        end
      end
      RoleInfoPopularitySystem.PopularityMessageList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityMessageList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityMessageList, function(a, b)
          if a.top_time ~= b.top_time then
            return a.top_time > b.top_time
          end
          return a.datetime > b.datetime
        end)
      end
      log_tree("RoleInfoPopularitySystem PopularityMessageList profile", RoleInfoPopularitySystem.PopularityMessageList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_MSG_TREND_PROFILE)
    end, 1017)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_MSG_TREND_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_reply_list_profile(CurrUid)
  log(bWriteLog and "get_popularity_reply_list_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_reply_list_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  RoleInfoPopularitySystem.PopularityReplyList = {}
  local gids = {}
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  for k, v in pairs(RoleInfoPopularitySystem.ReplyList) do
    if not logic_friend_blacklist:IsBlacklist(v.uid) and not logic_friend_blacklist:IsByBlacklist(v.uid) then
      table.insert(gids, tonumber(v.uid))
      local msg = logic_chat_main.ReplaceEmoji(v.msg or "")
      local reply = logic_chat_main.ReplaceEmoji(v.reply or "")
      table.insert(RoleInfoPopularitySystem.PopularityReplyList, {
        index = k,
        id = v.id or 0,
        gid = tostring(v.uid),
        datetime = v.devote_time,
        gift_type = v.gift_type,
        gift_count = v.gift_count,
        msg = msg,
        reply = reply,
        reply_time = v.reply_time,
        top_time = v.top_time or 0,
        reply_id = v.reply_id,
        msg_id = v.msg_id
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityReplyList", RoleInfoPopularitySystem.PopularityReplyList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityReplyList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityReplyList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityReplyList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityReplyList, function(a, b)
          if a.reply_time ~= b.reply_time then
            return a.reply_time > b.reply_time
          end
          return a.datetime > b.datetime
        end)
      end
      log_tree("RoleInfoPopularitySystem PopularityReplyList profile", RoleInfoPopularitySystem.PopularityReplyList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_REPLY_LIST_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_REPLY)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_REPLY_LIST_PROFILE)
  end
end
function RoleInfoPopularitySystem.show_popularity_detail_req(is_show)
  log(bWriteLog and "show_popularity_detail_req:" .. tostring(is_show))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_show_popularity_detail_req(is_show)
end
function RoleInfoPopularitySystem.show_popularity_detail_rsp(ok, is_show)
  log(bWriteLog and "show_popularity_detail_rsp:" .. tostring(is_show))
  RoleInfoPopularitySystem.IsShowDetail = is_show
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_RSP, RoleInfoPopularitySystem.CurrUid)
end
function RoleInfoPopularitySystem.set_popularity_pround_visable_req(is_show)
  log(bWriteLog and "set_popularity_pround_visable_req:" .. tostring(is_show))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_set_popularity_pround_visable_req(is_show)
end
function RoleInfoPopularitySystem.set_popularity_pround_visable_rsp(errcode, is_show)
  log(bWriteLog and "set_popularity_pround_visable_rsp:" .. tostring(is_show))
  if DataMgr.roleData.pround_info then
    DataMgr.roleData.pround_info.is_visable = is_show
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if myProfile and myProfile.pround_info then
    myProfile.pround_info.is_visable = is_show
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_SET_PROUND_SWITCH_RSP)
end
function RoleInfoPopularitySystem.close_popularity_reddot_req(is_msg_reddot, is_guardian)
  log(bWriteLog and "close_popularity_reddot_req")
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_close_popularity_reddot_req(is_msg_reddot, is_guardian)
end
function RoleInfoPopularitySystem.close_popularity_reddot_rsp(ok, is_msg_reddot, is_guardian)
  log(bWriteLog and "close_popularity_reddot_rsp:")
  if ok == 0 then
    if is_msg_reddot then
      RoleInfoPopularitySystem.IsShowMsgReddot = false
    elseif is_guardian then
      RoleInfoPopularitySystem.IsShowMyGuardReddot = false
    else
      RoleInfoPopularitySystem.IsShowReddot = false
      RoleInfoPopularitySystem.IsShowUCGiftReddot = false
    end
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
  end
end
function RoleInfoPopularitySystem.send_get_pspace_colletc_rank_req(target_uid, gift_id)
  log(bWriteLog and "RoleInfoPopularitySystem.send_get_pspace_colletc_rank_req target_uid:" .. tostring(target_uid) .. ", gift_id:" .. tostring(gift_id))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_pspace_colletc_rank_req(target_uid, gift_id)
end
function RoleInfoPopularitySystem.on_get_pspace_colletc_rank_rsp(target_uid, gift_id, pspace_colletc_rank)
  log(bWriteLog and "RoleInfoPopularitySystem.on_get_pspace_colletc_rank_rsp target_uid:" .. tostring(target_uid) .. ", gift_id:" .. tostring(gift_id))
  log_tree("pspace_colletc_rank", pspace_colletc_rank)
  RoleInfoPopularitySystem.GiftSenderList = pspace_colletc_rank or {}
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_COLLECT_RANK_RSP)
end
function RoleInfoPopularitySystem.set_last_trend_top_req(index, id, set_top)
  log(bWriteLog and "set_last_trend_top_req:" .. tostring(id) .. ",index:" .. tostring(index) .. ",set_top:" .. tostring(set_top))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_set_last_trend_top_req(index, tonumber(id), set_top)
end
function RoleInfoPopularitySystem.set_last_trend_top_rsp(ok, msg_trend)
  log(bWriteLog and "set_last_trend_top_rsp:" .. tostring(ok))
  log_tree("set_last_trend_top_rsp", msg_trend)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  RoleInfoPopularitySystem.MsgTrend = msg_trend
  RoleInfoPopularitySystem.get_popularity_msg_trend_profile(RoleInfoPopularitySystem.CurrUid)
end
function RoleInfoPopularitySystem.delete_gift_record_req(index, id, scene)
  log(bWriteLog and "delete_gift_record_req:" .. tostring(id) .. ",index:" .. tostring(index))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_delete_gift_record_req(index, tonumber(id), scene)
end
function RoleInfoPopularitySystem.delete_gift_record_rsp(ok, msg_trend, scene)
  log(bWriteLog and "delete_gift_record_rsp: ok = " .. tostring(ok) .. ", scene = " .. tostring(scene))
  if ok ~= 0 then
    ShowNotice(ok)
    return
  elseif RoleInfoPopularitySystem.autoDeleteHeadCount and 0 < RoleInfoPopularitySystem.autoDeleteHeadCount and scene == 2 then
    RoleInfoPopularitySystem.autoDeleteHeadCount = RoleInfoPopularitySystem.autoDeleteHeadCount - 1
  else
    ShowNotice(46099)
  end
  log_tree("delete_gift_record_rsp msg_trend", msg_trend)
  RoleInfoPopularitySystem.MsgTrend = msg_trend
  if scene == RoleInfoPopularitySystem.EDeleteMsgScene.Message then
    RoleInfoPopularitySystem.get_popularity_msg_trend_profile(RoleInfoPopularitySystem.CurrUid)
  else
    RoleInfoPopularitySystem.get_popularity_last_trend_profile(RoleInfoPopularitySystem.CurrUid)
  end
end
function RoleInfoPopularitySystem.reply_gift_msg_req(index, id, reply)
  log(bWriteLog and "reply_gift_msg_req index:" .. tostring(index) .. ", id:" .. tostring(id) .. ", reply:" .. tostring(reply))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_reply_gift_msg_req(index, tonumber(id), reply)
end
function RoleInfoPopularitySystem.reply_gift_msg_rsp(ok, msg_trend)
  log(bWriteLog and "reply_gift_msg_rsp:" .. tostring(ok))
  log_tree("last_trend", msg_trend)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  RoleInfoPopularitySystem.MsgTrend = msg_trend
  RoleInfoPopularitySystem.get_popularity_msg_trend_profile(RoleInfoPopularitySystem.CurrUid)
end
function RoleInfoPopularitySystem.delete_gift_reply_req(index, id, recipient_uid)
  log(bWriteLog and "delete_gift_reply_req index:" .. tostring(index) .. ", id:" .. tostring(id) .. ", recipient_uid:" .. tostring(recipient_uid))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_delete_gift_reply_req(index, tonumber(id), tonumber(recipient_uid))
end
function RoleInfoPopularitySystem.delete_gift_reply_rsp(ok, msg_trend)
  log(bWriteLog and "delete_gift_reply_rsp:" .. tostring(ok))
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  if RoleInfoPopularitySystem.IsSelf() then
    RoleInfoPopularitySystem.get_popularity_msg_trend_profile_when_delete_others_reply(msg_trend)
  end
  RoleInfoPopularitySystem.MsgTrend = msg_trend
  RoleInfoPopularitySystem.get_popularity_msg_trend_profile(RoleInfoPopularitySystem.CurrUid)
end
function RoleInfoPopularitySystem.show_msg_reddot(ok, is_show_msg_reddot, is_pay_uc)
  log(bWriteLog and "show_msg_reddot:" .. tostring(ok) .. ",is_show_msg_reddot:" .. tostring(is_show_msg_reddot) .. ",is_pay_uc:" .. tostring(is_pay_uc))
  RoleInfoPopularitySystem.IsShowMsgReddot = is_show_msg_reddot
  RoleInfoPopularitySystem.IsShowUCGiftReddot = RoleInfoPopularitySystem.IsShowUCGiftReddot or is_pay_uc
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
end
function RoleInfoPopularitySystem.Handle_LogOut()
  logic_send_gift.Handle_LogOut()
  RoleInfoPopularitySystem.PopularitySimpleCache = {}
  RoleInfoPopularitySystem.IsShowUCGiftReddot = false
end
function RoleInfoPopularitySystem.get_one_user_rank(period_type)
  log(bWriteLog and "RoleInfoPopularitySystem.get_one_user_rank:" .. tostring(period_type))
  local bIsJPKR = FuncUtil.IsPlayerJPKR()
  local popularity_total_rating = bIsJPKR and 72003 or 72001
  local popularity_weekly_rating = bIsJPKR and 72004 or 72002
  local scoreType = period_type == "total" and popularity_total_rating or popularity_weekly_rating
  local client_data = period_type == "total" and "popularity_total" or "popularity_week"
  if RoleInfoPopularitySystem.RankInfoSelf[client_data] ~= -1 then
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF)
    return
  end
  local zoneId = 0
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank(client_data, zoneId, tonumber(RoleInfoPopularitySystem.CurrUid), scoreType)
end
function RoleInfoPopularitySystem.get_one_user_proud_rank(period_type)
  log(bWriteLog and "RoleInfoPopularitySystem.get_one_user_proud_rank:" .. tostring(period_type))
  local bIsJPKR = FuncUtil.IsPlayerJPKR()
  local proud_total_rating = bIsJPKR and 72007 or 72005
  local proud_week_rating = bIsJPKR and 72008 or 72006
  local scoreType = period_type == "total" and proud_total_rating or proud_week_rating
  local client_data = period_type == "total" and "proud_total" or "proud_week"
  if RoleInfoPopularitySystem.RankInfoSelf[client_data] ~= -1 then
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF_PROUD)
    return
  end
  local zoneId = 0
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank(client_data, zoneId, tonumber(RoleInfoPopularitySystem.CurrUid), scoreType)
end
function RoleInfoPopularitySystem.get_one_user_rank_rsp(client_data, ok, zoneId, rank_info)
  if client_data == "popularity_total" then
    log(bWriteLog and "get_one_user_rank_rsp client_data = " .. client_data .. ", ok=" .. ok .. ", zoneId = " .. tostring(zoneId))
    if ok == 0 then
      if rank_info.rank_no == nil then
        RoleInfoPopularitySystem.RankInfoSelf.popularity_total = 0
      else
        RoleInfoPopularitySystem.RankInfoSelf.popularity_total = rank_info.rank_no
      end
      log(bWriteLog and "RoleInfoPopularitySystem.RankInfoSelf.popularity_total " .. tostring(RoleInfoPopularitySystem.RankInfoSelf.popularity_total))
    else
      RoleInfoPopularitySystem.RankInfoSelf.popularity_total = 0
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF)
  elseif client_data == "popularity_week" then
    log(bWriteLog and "get_one_user_rank_rsp client_data = " .. client_data .. ", ok=" .. ok .. ", zoneId = " .. tostring(zoneId))
    if ok == 0 then
      if rank_info.rank_no == nil then
        RoleInfoPopularitySystem.RankInfoSelf.popularity_week = 0
      else
        RoleInfoPopularitySystem.RankInfoSelf.popularity_week = rank_info.rank_no
      end
      log(bWriteLog and "RoleInfoPopularitySystem.RankInfoSelf.popularity_week " .. tostring(RoleInfoPopularitySystem.RankInfoSelf.popularity_week))
    else
      RoleInfoPopularitySystem.RankInfoSelf.popularity_week = 0
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF)
  elseif client_data == "proud_total" then
    log(bWriteLog and "get_one_user_rank_rsp client_data = " .. client_data .. ", ok=" .. ok .. ", zoneId = " .. tostring(zoneId))
    if ok == 0 then
      if rank_info.rank_no == nil then
        RoleInfoPopularitySystem.RankInfoSelf.proud_total = 0
      else
        RoleInfoPopularitySystem.RankInfoSelf.proud_total = rank_info.rank_no
      end
      log(bWriteLog and "RoleInfoPopularitySystem.RankInfoSelf.proud_total " .. tostring(RoleInfoPopularitySystem.RankInfoSelf.proud_total))
    else
      RoleInfoPopularitySystem.RankInfoSelf.proud_total = 0
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF_PROUD)
  elseif client_data == "proud_week" then
    log(bWriteLog and "get_one_user_rank_rsp client_data = " .. client_data .. ", ok=" .. ok .. ", zoneId = " .. tostring(zoneId))
    if ok == 0 then
      if rank_info.rank_no == nil then
        RoleInfoPopularitySystem.RankInfoSelf.proud_week = 0
      else
        RoleInfoPopularitySystem.RankInfoSelf.proud_week = rank_info.rank_no
      end
      log(bWriteLog and "RoleInfoPopularitySystem.RankInfoSelf.proud_week " .. tostring(RoleInfoPopularitySystem.RankInfoSelf.proud_week))
    else
      RoleInfoPopularitySystem.RankInfoSelf.proud_week = 0
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_POPULARITY_UPDATE_SELF_PROUD)
  end
end
function RoleInfoPopularitySystem.proc_delete_pspace_rank_record_rsp(rank_type, rank)
  if rank_type == RoleInfoPopularitySystem.EDeleteRankType.PopularityTotal then
    RoleInfoPopularitySystem.DevoteRank = rank
    RoleInfoPopularitySystem.get_popularity_devote_rank_profile(RoleInfoPopularitySystem.CurrUid)
  elseif rank_type == RoleInfoPopularitySystem.EDeleteRankType.PopularityWeek then
    RoleInfoPopularitySystem.DevoteWeeklyRank = rank
    RoleInfoPopularitySystem.get_popularity_devote_weekly_rank_profile(RoleInfoPopularitySystem.CurrUid)
  elseif rank_type == RoleInfoPopularitySystem.EDeleteRankType.GuardTotal then
    RoleInfoPopularitySystem.GuardRank = rank
    RoleInfoPopularitySystem.get_popularity_guard_rank_profile(RoleInfoPopularitySystem.CurrUid)
  elseif rank_type == RoleInfoPopularitySystem.EDeleteRankType.GuardWeek then
    RoleInfoPopularitySystem.GuardWeeklyRank = rank
    RoleInfoPopularitySystem.get_popularity_guard_weekly_rank_profile(RoleInfoPopularitySystem.CurrUid)
  elseif rank_type == RoleInfoPopularitySystem.EDeleteRankType.WowTotal then
    RoleInfoPopularitySystem.WowRank = rank
    RoleInfoPopularitySystem.get_popularity_wow_rank_profile(RoleInfoPopularitySystem.CurrUid)
  elseif rank_type == RoleInfoPopularitySystem.EDeleteRankType.WowWeek then
    RoleInfoPopularitySystem.WowWeeklyRank = rank
    RoleInfoPopularitySystem.get_popularity_wow_weekly_rank_profile(RoleInfoPopularitySystem.CurrUid)
  end
end
function RoleInfoPopularitySystem.proc_delete_last_trend_record_rsp(last_trend)
  RoleInfoPopularitySystem.LastTrend = last_trend
  RoleInfoPopularitySystem.get_popularity_last_trend_profile(RoleInfoPopularitySystem.CurrUid)
end
function RoleInfoPopularitySystem.get_popularity_last_high_value_rsp(last_high_value, source)
  if last_high_value and next(last_high_value) then
    RoleInfoPopularitySystem.LastHighValue = last_high_value
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_HIGHVALUE_GIFT_RSP, source)
end
function RoleInfoPopularitySystem.GetBestGift()
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local TimeUtil = require("client.common.time_util")
  local bestGift
  for gift_type, gift_info in pairs(RoleInfoPopularitySystem.LastHighValue) do
    local bInSevenDays = TimeUtil.GetServerTimeInSec() - gift_info.time <= 604800
    if bInSevenDays then
      if bestGift == nil then
        gift_info.        bestGift = gift_info
      else
        local curGiftInfo = logic_send_gift.GetGiftData(gift_type)
        local bestGiftInfo = logic_send_gift.GetGiftData(bestGift.gift_type)
        if curGiftInfo and bestGiftInfo and curGiftInfo.Price > bestGiftInfo.Price then
          gift_info.          bestGift = gift_info
        end
      end
    else
      log(bWriteLog and "RoleInfoPopularitySystem.GetBestGift out of time gift_type = " .. tostring(gift_type))
    end
  end
  if bestGift then
    bestGift.is_best_gift = true
    bestGift.gift_count = bestGift.count
    return bestGift
  end
  return nil
end
function RoleInfoPopularitySystem.OpenPopularityUI(currUID, TabType, subTabType)
  RoleInfoPopularitySystem.enter(currUID)
  local jumpInfo = {CurrPageType = TabType, TabIndex = subTabType}
  UIManager.ShowUI(UIManager.UI_Config.roleinfo_popularity, jumpInfo)
end
function RoleInfoPopularitySystem.IsPopularityWeekRankEmpty()
  if RoleInfoPopularitySystem.DevoteWeeklyRank and next(RoleInfoPopularitySystem.DevoteWeeklyRank) then
    return false
  else
    return true
  end
end
function RoleInfoPopularitySystem.GetProundIconPath(level)
  local proudInfo = CDataTable.GetTableData("ProundLevelCfg", level)
  if not proudInfo then
    log(bWriteLog and "RoleInfoPopularitySystem.GetProundIconPath not proudInfo level = " .. tostring(level))
    return
  end
  return proudInfo.LevelIconPath, proudInfo.IconBgColor
end
function RoleInfoPopularitySystem.IsProundHornMsgLevel(level)
  local proudInfo = CDataTable.GetTableData("ProundLevelCfg", level)
  if not proudInfo then
    log(bWriteLog and "RoleInfoPopularitySystem.IsProundHornMsgLevel not proudInfo level = " .. tostring(level))
    return false
  end
  return proudInfo.EffectType == 3
end
function RoleInfoPopularitySystem.GetPopularityTop3Textue(rank)
  if type(rank) ~= "number" or rank < 1 or 3 < rank then
    return
  end
  local top3Imgs = {
    "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/Rank_Index_1_png.Rank_Index_1_png",
    "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/Rank_Index_2_png.Rank_Index_2_png",
    "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/Rank_Index_3_png.Rank_Index_3_png"
  }
  return top3Imgs[rank]
end
function RoleInfoPopularitySystem.GetPopularityLevelByExp(exp)
  local popularityLevel = 0
  local GiftIconColor = CDataTable.GetTable("GiftIconColor")
  local MaxLevel = RoleInfoPopularitySystem.GetMaxPopularityLevel()
  if exp > tonumber(GiftIconColor[MaxLevel].Max_f) then
    return MaxLevel
  end
  for level = 0, MaxLevel do
    local levelCfg = GiftIconColor[level]
    if exp >= tonumber(levelCfg.Min_f) and exp <= tonumber(levelCfg.Max_f) then
      popularityLevel = levelCfg.RangeID
      break
    end
  end
  return popularityLevel
end
function RoleInfoPopularitySystem.GetPopularityTexture(exp, is_show_detail, is_small_icon)
  local GiftIconColor = CDataTable.GetTable("GiftIconColor")
  if not is_show_detail or exp == 0 then
    return GiftIconColor[0].RangeIcon
  end
  local MaxLevel = RoleInfoPopularitySystem.GetMaxPopularityLevel()
  if exp >= tonumber(GiftIconColor[MaxLevel].Max_f) then
    return GiftIconColor[MaxLevel].RangeIcon
  end
  for level = 0, MaxLevel do
    local levelCfg = GiftIconColor[level]
    if exp >= tonumber(levelCfg.Min_f) and exp <= tonumber(levelCfg.Max_f) then
      return is_small_icon and levelCfg.RangeRoundIcon or levelCfg.RangeIcon
    end
  end
end
function RoleInfoPopularitySystem.GetMaxPopularityLevel()
  local MaxLevel = 0
  local GiftIconColor = CDataTable.GetTable("GiftIconColor")
  for _, LevelCfg in pairs(GiftIconColor) do
    if LevelCfg.RangeID and MaxLevel < LevelCfg.RangeID then
      MaxLevel = LevelCfg.RangeID
    end
  end
  return MaxLevel
end
function RoleInfoPopularitySystem.update_self_popularity(uid, prev_popularity)
  log(bWriteLog and "[RoleInfoPopularitySystem] update_self_popularity: " .. tostring(uid))
  if not prev_popularity then
    log(bWriteLog and "[RoleInfoPopularitySystem] nil prev_popularity")
    return
  end
  if not uid then
    return
  end
  if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "[RoleInfoPopularitySystem] not self uid")
    return
  end
  local data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)]
  if not data or not data.total_devote then
    log(bWriteLog and "[RoleInfoPopularitySystem] no cached popularity data")
    return
  end
  local prev_popularity_level = RoleInfoPopularitySystem.GetPopularityLevelByExp(prev_popularity)
  local cur_popularity_level = RoleInfoPopularitySystem.GetPopularityLevelByExp(data.total_devote)
  if prev_popularity_level < cur_popularity_level then
    RoleInfoPopularitySystem.ShowPopularityLevelUpNotice(cur_popularity_level)
  end
end
function RoleInfoPopularitySystem.ShowPopularityLevelUpNotice(new_popularity_level)
  log(bWriteLog and "[RoleInfoPopularitySystem] ShowPopularityLevelUpNotice: " .. tostring(new_popularity_level))
  local patternLevel = new_popularity_level + 1
  if patternLevel > RoleInfoPopularitySystem.GetMaxPopularityLevel() then
    patternLevel = RoleInfoPopularitySystem.GetMaxPopularityLevel()
  end
  local levelUpTips = LocUtil.LocalizeResFormat(44240, new_popularity_level)
  local patternIcon = "Popularity"
  levelUpTips = string.gsub(levelUpTips, patternIcon, patternIcon .. tostring(patternLevel))
  ShowNotice(levelUpTips)
end
function RoleInfoPopularitySystem.JumpFriendSendGift(_, _, vars)
  log_tree(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.JumpFriendSendGift, vars is:", vars)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() and PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.SocialLobby
  }) then
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friends = LogicFriend.GetFriendList(true)
  local jumpUid = vars and vars.uid
  if not jumpUid and 0 < #friends then
    jumpUid = friends[1].uid
  end
  if jumpUid then
    local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
    SocialPersonSpaceSystem.EnterPersonSpace(jumpUid, true)
    RoleInfoPopularitySystem.enter(jumpUid)
    UIManager.ShowUI(UIManager.UI_Config.roleinfo_send_gift, RoleInfoPopularitySystem.GiftSourceType.PersonSpace, nil, nil, jumpUid)
  else
    GlobalData.JumpUrl("game://?module=1000401")
  end
end
local _IsPopularityTabShow = function(isRefreshByProto)
  local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
  if PopularityPKHandler.bGMTest then
    return true
  end
  if isRefreshByProto then
    local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
    local resData = logic_popular_gift_pk.resPSMatchStatusMap[RoleInfoPopularitySystem.CurrUid]
    if not resData then
      return
    end
    local PopularPkMacros = require("client.slua.logic.person_space.popular_pk_macros")
    log(bWriteLog and "[v_wllwu] RoleInfoPopularityUI:OnGetPopularPkInfo, CurrUid is:" .. tostring(RoleInfoPopularitySystem.CurrUid) .. "; resData.status = " .. tostring(resData.status))
    if RoleInfoPopularitySystem.IsSelf() then
      if resData.status == PopularPkMacros.ENUM_STATE.CLOSE then
        return
      end
    elseif resData.status ~= PopularPkMacros.ENUM_STATE.PK then
      return
    end
  end
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  if not logic_popular_gift_util.IsPopularPkActOpen() then
    log(bWriteLog and "[v_wllwu] logic_popular_gift_util.IsPopularPkActOpen is false")
    return
  end
  if not RoleInfoPopularitySystem.IsSelf() then
    log(bWriteLog and "[v_wllwu] logic_popular_gift_util.IsPopularPkActOpen, viewOtherPopularPkInfo is false")
    local logic_popular_pk_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_reddot)
    return logic_popular_pk_reddot:CanViewOtherPopularPkInfo(RoleInfoPopularitySystem.CurrUid, isRefreshByProto)
  end
  return true
end
function RoleInfoPopularitySystem.GetTabNameList(isRefreshByProto)
  local configTabIDList
  local TableUtil = require("common.table_util")
  if RoleInfoPopularitySystem.IsSelf() then
    configTabIDList = TableUtil.CopyTable(RoleInfoPopularitySystem.MyTabLocIDList)
  else
    configTabIDList = TableUtil.CopyTable(RoleInfoPopularitySystem.HisTabLocIDList)
  end
  if not _IsPopularityTabShow(isRefreshByProto) then
    log(bWriteLog and "RoleInfoPopularitySystem.GetTabNameList configTabIDList[PopularityMacros.ENUM_TAB_TYPE.PopularityPK] = nil")
    configTabIDList[PopularityMacros.ENUM_TAB_TYPE.PopularityPK] = nil
  elseif RoleInfoPopularitySystem.IsInCelebration() then
    log(bWriteLog and "RoleInfoPopularitySystem.GetTabNameList IsInCelebration")
    configTabIDList[PopularityMacros.ENUM_TAB_TYPE.PopularityPK].textID = 62277
  end
  local logic_popular_team_pk_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk_tab)
  if not logic_popular_team_pk_tab:IsShowTab(RoleInfoPopularitySystem.CurrUid) then
    log(bWriteLog and "RoleInfoPopularitySystem.GetTabNameList configTabIDList[PopularityMacros.ENUM_TAB_TYPE.PopularityTeamPK] = nil")
    configTabIDList[PopularityMacros.ENUM_TAB_TYPE.PopularityTeamPK] = nil
  end
  local count = TableUtil.CountTable(configTabIDList)
  local tabNameList = prealloctable(count, 0)
  for id, cfg in pairs(configTabIDList) do
    local subTabNameList = {}
    if SubTabList and SubTabList[id] then
      for _, v in ipairs(SubTabList[id]) do
        if v.showFuncName == nil or RoleInfoPopularitySystem[v.showFuncName](isRefreshByProto) then
          local subText = LocUtil.GetLocalizeResStr(v.textID)
          table.insert(subTabNameList, {
            text = subText,
            subTabID = v.subTabID
          })
        end
      end
    end
    if id == PopularityMacros.ENUM_TAB_TYPE.PopularityTeamPK then
      subTabNameList = logic_popular_team_pk_tab:GetSubTabList(RoleInfoPopularitySystem.CurrUid)
    end
    local text = LocUtil.GetLocalizeResStr(cfg.textID)
    table.insert(tabNameList, {
      tabID = id,
      text = text,
      subData = subTabNameList
    })
  end
  log(bWriteLog and "RoleInfoPopularitySystem.GetTabNameList tabNameList count is " .. tostring(tabNameList))
  return tabNameList
end
function RoleInfoPopularitySystem.IsNeedRequestCurPlayerPkInfo()
  if RoleInfoPopularitySystem.IsSelf() then
    return false
  end
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  if not logic_popular_gift_util.IsPopularPkActOpen() or not logic_popular_gift_util.IsViewPkSwitchOpen(RoleInfoPopularitySystem.CurrUid) then
    return false
  end
  return true
end
function RoleInfoPopularitySystem.IsShowPkSubTab(isRefreshByProto)
  local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
  if PopularityPKHandler.bGMTest then
    return true
  end
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  local seasonId = logic_popular_gift_util.GetCurActSeasonID()
  if not seasonId then
    log(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.IsShowPkSubTab, return false because no seasonId")
    return false
  end
  local bCelebrationSwitch = RoleInfoPopularitySystem.IsInCelebration()
  if not bCelebrationSwitch and not RoleInfoPopularitySystem.IsSelf() then
    return false
  end
  if isRefreshByProto then
    local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
    local resData = logic_popular_gift_pk.resPSMatchStatusMap[RoleInfoPopularitySystem.CurrUid]
    if not resData then
      return
    end
    local PopularPkMacros = require("client.slua.logic.person_space.popular_pk_macros")
    if resData.status == PopularPkMacros.ENUM_STATE.COMINGEND or resData.status == PopularPkMacros.ENUM_STATE.CLOSE then
      return
    end
    if bCelebrationSwitch and resData.status ~= PopularPkMacros.ENUM_STATE.RESULT and resData.status ~= PopularPkMacros.ENUM_STATE.PK then
      log(bWriteLog and "RoleInfoPopularitySystem.IsShowPkSubTab, resData.status not in result or pk, resData.status: " .. tostring(resData.status))
      return
    end
  end
  local cfg = CDataTable.GetTableData("PopularPKTimeConfig", seasonId)
  if cfg and cfg.LastRoundID then
    log(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.IsShowPkSubTab, LastRoundID is: " .. tostring(cfg.LastRoundID))
    local roundCfg = CDataTable.GetTableData("PopularPKRoundConfig", cfg.LastRoundID)
    if roundCfg then
      local TimeUtil = require("client.common.time_util")
      local curTime = TimeUtil.GetServerTimeInSec()
      local endTime = TimeUtil.TimeStringToUnixstamp(roundCfg.EndTime)
      log(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.IsShowPkSubTab, curTime is: " .. tostring(curTime) .. "; endTime is: " .. tostring(endTime))
      if curTime >= endTime then
        return false
      end
    end
  end
  log(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.IsShowPkSubTab return true")
  return true
end
function RoleInfoPopularitySystem.IsShowCelebrationIntro()
  return RoleInfoPopularitySystem.IsInCelebration()
end
function RoleInfoPopularitySystem.IsShowPKAwardSubTab()
  return RoleInfoPopularitySystem.IsSelf()
end
function RoleInfoPopularitySystem.IsShowPkTreasureBoxSubTab()
  if not RoleInfoPopularitySystem.IsInCelebration() then
    log(bWriteLog and "RoleInfoPopularitySystem.IsShowPkTreasureBoxSubTab not in celebration")
    return false
  end
  if not RoleInfoPopularitySystem.IsSelf() then
    log(bWriteLog and "RoleInfoPopularitySystem.IsShowPkTreasureBoxSubTab not self")
    return false
  end
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  local seasonId = logic_popular_gift_util.GetCurActSeasonID()
  local PopularPKTimeConfig = CDataTable.GetTableData("PopularPKTimeConfig", seasonId)
  local TimeUtil = require("client.common.time_util")
  local nStartTime = TimeUtil.TimeStringToUnixstamp(PopularPKTimeConfig.PKStartTime)
  local nEndTime = TimeUtil.TimeStringToUnixstamp(PopularPKTimeConfig.ActEndTime)
  local nCurrTime = TimeUtil.GetServerTimeInSec()
  local res = nStartTime <= nCurrTime and nEndTime >= nCurrTime
  log(bWriteLog and "RoleInfoPopularitySystem.IsShowPkTreasureBoxSubTab, res: " .. tostring(res))
  return res
end
function RoleInfoPopularitySystem.IsShowPKCelebrationSubTab()
  return RoleInfoPopularitySystem.IsInCelebration()
end
function RoleInfoPopularitySystem.IsShowPKFunAwardSubTab()
  if not RoleInfoPopularitySystem.IsInCelebration() then
    log(bWriteLog and "RoleInfoPopularitySystem.IsShowPKFunAwardSubTab not in celebration")
    return false
  end
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  local seasonId = logic_popular_gift_util.GetCurActSeasonID()
  local PopularPKTimeConfig = CDataTable.GetTableData("PopularPKTimeConfig", seasonId)
  local TimeUtil = require("client.common.time_util")
  local nStartTime = TimeUtil.TimeStringToUnixstamp(PopularPKTimeConfig.PKStartTime)
  local nCurrTime = TimeUtil.GetServerTimeInSec()
  if nStartTime > nCurrTime then
    log(bWriteLog and "RoleInfoPopularitySystem.IsShowPKFunAwardSubTab nCurrTime < nStartTime")
    return false
  end
  return true
end
function RoleInfoPopularitySystem.IsInCelebration()
  local logic_popular_gift_util = require("client.slua.logic.person_space.logic_popular_gift_util")
  local seasonId = logic_popular_gift_util.GetCurActSeasonID()
  if not seasonId then
    log(bWriteLog and "RoleInfoPopularitySystem.IsInCelebration not seasonId")
    return false
  end
  local cfg = CDataTable.GetTableData("PopularPKTimeConfig", seasonId)
  if not cfg then
    log(bWriteLog and "RoleInfoPopularitySystem.IsInCelebration not cfg, seasonId = " .. tostring(seasonId))
    return false
  end
  return cfg.CelebrationSwitch
end
function RoleInfoPopularitySystem.UpdateJumpBackData(data)
  log_tree(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.jumpBackUIData, data is:", data)
  RoleInfoPopularitySystem.jumpBackUIData = data
end
function RoleInfoPopularitySystem.ClearJumpBackData()
  log(bWriteLog and "[v_wllwu] RoleInfoPopularitySystem.ClearJumpBackData:")
  RoleInfoPopularitySystem.jumpBackUIData = nil
end
function RoleInfoPopularitySystem.GetPopularityLevel(uid)
  local data = RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)]
  if not data or not data.total_devote then
    return 0
  end
  return RoleInfoPopularitySystem.GetPopularityLevelByExp(data.total_devote)
end
function RoleInfoPopularitySystem.GetPopularityValue(uid)
  return RoleInfoPopularitySystem.PopularitySimpleCache[tostring(uid)]
end
function RoleInfoPopularitySystem.get_popularity_wow_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_wow_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_wow_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  RoleInfoPopularitySystem.PopularityWowList = {}
  local gids = {}
  for _, guardInfo in pairs(RoleInfoPopularitySystem.WowRank) do
    if not guardInfo.uid then
      log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_wow_rank_profile not uid")
      return
    end
    local devoteUid = guardInfo.uid
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    if not logic_friend_blacklist:IsBlacklist(devoteUid) then
      table.insert(gids, tonumber(devoteUid))
      table.insert(RoleInfoPopularitySystem.PopularityWowList, {
        gid = tostring(devoteUid),
        total_Wow = guardInfo.value,
        last_Wow_time = guardInfo.record_ts
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularitywowList", RoleInfoPopularitySystem.PopularityWowList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityWowList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityWowList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityWowList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityWowList, function(a, b)
          return a and b and a.total_Wow == b.total_Wow and (a.last_Wow_time or 0) < (b.last_Wow_time or 0) or (a.total_Wow or 0) > (b.total_Wow or 0)
        end)
        while #RoleInfoPopularitySystem.PopularityWowList > RoleInfoPopularitySystem.PopularityWowCount do
          table.remove(RoleInfoPopularitySystem.PopularityWowList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityWowList profile", RoleInfoPopularitySystem.PopularityWowList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.get_popularity_wow_weekly_rank_profile(CurrUid)
  log(bWriteLog and "get_popularity_wow_weekly_rank_profile:" .. tostring(CurrUid))
  if tonumber(CurrUid) ~= tonumber(RoleInfoPopularitySystem.CachedUid.get_popularity) then
    log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_wow_weekly_rank_profile uid not match, CurrUid = " .. tostring(CurrUid) .. ", CachedUid = " .. tostring(RoleInfoPopularitySystem.CachedUid.get_popularity))
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  RoleInfoPopularitySystem.PopularityWeekWowList = {}
  local gids = {}
  for _, guardInfo in pairs(RoleInfoPopularitySystem.WowWeeklyRank) do
    if not guardInfo.uid then
      log(bWriteLog and "RoleInfoPopularitySystem.get_popularity_wow_weekly_rank_profile not uid")
      return
    end
    local devoteUid = guardInfo.uid
    if not logic_friend_blacklist:IsBlacklist(devoteUid) then
      table.insert(gids, tonumber(devoteUid))
      table.insert(RoleInfoPopularitySystem.PopularityWeekWowList, {
        gid = tostring(devoteUid),
        total_Wow = guardInfo.value,
        last_Wow_time = guardInfo.record_ts
      })
    end
  end
  log_tree("RoleInfoPopularitySystem PopularityWeekWowList", RoleInfoPopularitySystem.PopularityWeekWowList)
  if 0 < #gids then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(list)
      local listAfterDelete = {}
      local hasInsertID = {}
      for j, currProfile in pairs(list) do
        for i, data in ipairs(RoleInfoPopularitySystem.PopularityWeekWowList) do
          if tonumber(data.gid) == tonumber(currProfile.uid) and not logic_profile:IsPlayerDelete(currProfile) and not logic_profile:IsPlayerBanned(currProfile.uid) and not hasInsertID[i] then
            PersonSpaceSystem.AddProfileData(data, currProfile)
            table.insert(listAfterDelete, data)
            hasInsertID[i] = true
          end
        end
      end
      RoleInfoPopularitySystem.PopularityWeekWowList = listAfterDelete
      if next(RoleInfoPopularitySystem.PopularityWeekWowList) ~= nil then
        table.sort(RoleInfoPopularitySystem.PopularityWeekWowList, function(a, b)
          return a and b and a.total_Wow == b.total_Wow and (a.last_Wow_time or 0) < (b.last_Wow_time or 0) or (a.total_Wow or 0) > (b.total_Wow or 0)
        end)
        while #RoleInfoPopularitySystem.PopularityWeekWowList > RoleInfoPopularitySystem.PopularityWowCount do
          table.remove(RoleInfoPopularitySystem.PopularityWeekWowList)
        end
      end
      log_tree("RoleInfoPopularitySystem PopularityWeekWowList profile", RoleInfoPopularitySystem.PopularityWeekWowList)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
    end, Enum_PROFILE_REPORT_CFG.POP_DEVOTE)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_GET_POPULARITY_DEVOTE_RANK_PROFILE)
  end
end
function RoleInfoPopularitySystem.CheckPopularityLevelButtonReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemLevelBtn) or {}
  return not data.bHasClick
end
function RoleInfoPopularitySystem.SavePopularityLevelButtonReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemLevelBtn) or {}
  data.bHasClick = true
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eNewPopularitySystemLevelBtn)
end
function RoleInfoPopularitySystem.IsGuardianVisible()
  if RoleInfoPopularitySystem.IsSelf() then
    log(bWriteLog and "RoleInfoPopularitySystem.IsGuardianVisible IsSelf")
    return true
  end
  if not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    log(bWriteLog and "RoleInfoPopularitySystem.IsGuardianVisible CheckOpen")
    return true
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profileInfo = logic_profile:GetLocalProfile(RoleInfoPopularitySystem.CurrUid)
  local guardianVisable = profileInfo and profileInfo.guardian_visable
  if guardianVisable == 0 then
    log(bWriteLog and "RoleInfoPopularitySystem.IsGuardianVisible guardian_visable == 0")
    return false
  elseif guardianVisable == 2 then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    log(bWriteLog and "RoleInfoPopularitySystem.IsGuardianVisible guardian_visable == 2")
    return LogicFriend.IsMyFriend(RoleInfoPopularitySystem.CurrUid)
  end
  log(bWriteLog and "RoleInfoPopularitySystem.IsGuardianVisible Default visible")
  return true
end
function RoleInfoPopularitySystem.changeGuardianSwitch(switch)
  log(bWriteLog and "changeGuardianSwitch:", tostring(switch))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_set_guardian_visable_req(switch)
end
function RoleInfoPopularitySystem.set_guardian_visable_rsp(errcode, switch)
  log(bWriteLog and "set_guardian_visable_rsp:" .. tostring(switch))
  if errcode == 0 then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    if myProfile then
      log(bWriteLog and "RoleInfoPopularitySystem.set_guardian_visable_rsp:", tostring(myProfile.guardian_visable), tostring(switch))
      myProfile.guardian_visable = switch
    end
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_GUARDIAN_RANK_SWITCH_UPDATE)
  else
    ShowNotice(errcode)
  end
end
return RoleInfoPopularitySystem
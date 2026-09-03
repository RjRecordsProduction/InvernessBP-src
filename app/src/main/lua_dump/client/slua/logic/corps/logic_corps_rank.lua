local EStrWeekDayID = 410047
local EStrPreWeekDayID = 410048
local CropsTrainingRankSystem = {
  tTabDataList = {},
  tRankDataList = {},
  tRankItemInfoSelf = {},
  nSelfRankNo = 0,
  nSelfRankScore = 0,
  tWeekRankList = nil,
  tSeasonRankList = nil,
  tRankInfoList = {},
  MyWeekRankInfo = nil,
  MySeasonRankInfo = nil,
  tRankAwardInfo = {},
  tRankAwardShowList = {},
  nLastSendAwardType = 0
}
function CropsTrainingRankSystem.UpdateRankListData()
  for _, v in ipairs(CropsTrainingRankSystem.tRankDataList) do
    CropsTrainingRankSystem.UpdateItemRoleInfo(v)
  end
end
function CropsTrainingRankSystem.UpdateItemRoleInfo(tItemData)
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local roleInfo = CorpsTrainingSystem.GetTrainRoleInfo(tItemData.uid)
  if not roleInfo then
    return
  end
  tItemData.url = roleInfo.url
  tItemData.name = roleInfo.name
  tItemData.city = roleInfo.city
  tItemData.level = roleInfo.level
  tItemData.gender = roleInfo.gender
  tItemData.bgbg_vip = roleInfo.bgbg_vip
  tItemData.startup_type = roleInfo.startup_type
  tItemData.cur_avatar_box_id = roleInfo.cur_avatar_box_id
end
function CropsTrainingRankSystem.UpdateTabListData()
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local curWeedDay = CorpsTrainingSystem.TodayWeekDay
  local StringUtil = require("common.string_util")
  local arrWeekDay = StringUtil.Split(LocUtil.LocalizeResFormat(EStrWeekDayID), "|")
  local arrPreWeekDay = StringUtil.Split(LocUtil.LocalizeResFormat(EStrPreWeekDayID), "|")
  CropsTrainingRankSystem.tTabDataList = {}
  for k, v in pairs(CorpsTrainingSystem.TrainHisRankInfo) do
    local tabData = {}
    tabData.week_day = k
    tabData.train_id = v.train_id
    tabData.isToday = k == curWeedDay
    tabData.txt = k > curWeedDay and arrPreWeekDay[k] or arrWeekDay[k]
    table.insert(CropsTrainingRankSystem.tTabDataList, tabData)
  end
  table.sort(CropsTrainingRankSystem.tTabDataList, function(a, b)
    if a.week_day == curWeedDay then
      return true
    elseif a.week_day < curWeedDay and b.week_day > curWeedDay then
      return true
    elseif a.week_day < curWeedDay and b.week_day < curWeedDay or a.week_day > curWeedDay and b.week_day > curWeedDay then
      return a.week_day > b.week_day
    else
      return false
    end
  end)
end
function CropsTrainingRankSystem.UpdateRankDataListInfo(rankInfo)
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local uidList = {}
  local tRawDataList = {}
  for k, v in pairs(rankInfo.members) do
    if 0 < v then
      local st = {
        uid = k,
        score = v,
        time = rankInfo.last_train_time and rankInfo.last_train_time[k] or 0
      }
      table.insert(tRawDataList, st)
      if CorpsTrainingSystem.IsNeedReqRoleInfo(k) then
        table.insert(uidList, k)
        CorpsTrainingSystem.RecordRoleInfoReq(k)
      end
    end
  end
  table.sort(tRawDataList, function(a, b)
    return a.score > b.score or a.score == b.score and a.time < b.time
  end)
  CropsTrainingRankSystem.nSelfRankNo = 0
  CropsTrainingRankSystem.nSelfRankScore = 0
  CropsTrainingRankSystem.tRankDataList = {}
  for i, v in ipairs(tRawDataList) do
    local tRoleInfo = CorpsTrainingSystem.GetTrainRoleInfo(v.uid) or {}
    local itm = {
      no = i,
      uid = v.uid,
      score = v.score,
      nItemType = 0,
      url = tRoleInfo.url or "",
      name = tRoleInfo.name or "",
      city = tRoleInfo.city or "",
      level = tRoleInfo.level or 0,
      bgbg_vip = tRoleInfo.bgbg_vip or 0,
      gender = tRoleInfo.gender or 0,
      startup_type = tRoleInfo.startup_type or 0,
      cur_avatar_box_id = tRoleInfo.cur_avatar_box_id or 0
    }
    if tostring(v.uid) == tostring(DataMgr.roleData.uid) then
      itm.nItemType = 1
      CropsTrainingRankSystem.nSelfRankNo = i
      CropsTrainingRankSystem.nSelfRankScore = v.score
    end
    table.insert(CropsTrainingRankSystem.tRankDataList, itm)
  end
  if 0 < #uidList then
    CorpsTrainingSystem.GetRankRoleProfile(uidList)
  end
end
function CropsTrainingRankSystem.UpdateRankDataSelf()
  CropsTrainingRankSystem.tRankItemInfoSelf = {
    city = "",
    nItemType = 2,
    no = CropsTrainingRankSystem.nSelfRankNo,
    score = CropsTrainingRankSystem.nSelfRankScore,
    uid = DataMgr.roleData.uid,
    name = DataMgr.roleData.nickName,
    url = DataMgr.roleData.headIconUrl,
    level = DataMgr.roleData.level,
    gender = DataMgr.roleData.gender,
    bgbg_vip = DataMgr.roleData.bgbg_vip,
    startup_type = BP_StartUpType,
    cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  }
end
function CropsTrainingRankSystem.UpdateCurRankData(nIndex)
  local curTabData = CropsTrainingRankSystem.tTabDataList[nIndex]
  if not curTabData then
    log_error("CorpsTrainingRankUI.UpdateUI not tab " .. nIndex)
    return
  end
  log(bWriteLog and "[chub]curTabData.week_day = " .. curTabData.week_day)
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local tCurRankListData = CorpsTrainingSystem.TrainHisRankInfo[curTabData.week_day]
  if not tCurRankListData then
    return
  end
  CropsTrainingRankSystem.UpdateRankDataListInfo(tCurRankListData)
  CropsTrainingRankSystem.UpdateRankDataSelf()
end
local NetReqMgr = {
  LastReqTable = {}
}
function NetReqMgr.ClearData()
  NetReqMgr.LastReqTable = {}
end
function NetReqMgr.CreateReqKey(...)
  local ret = ""
  for index = 1, select("#", ...) do
    ret = ret .. tostring(select(index, ...))
  end
  return ret
end
function NetReqMgr.InserReq(reqKey)
  NetReqMgr.LastReqTable[reqKey] = slua.getMiliseconds()
end
function NetReqMgr.IsValidReq(reqKey, time)
  time = time or 15
  if NetReqMgr.LastReqTable[reqKey] then
    return slua.getMiliseconds() - NetReqMgr.LastReqTable[reqKey] > time * 1000
  end
  return true
end
function CropsTrainingRankSystem.SendGetRankData(type, noRestrict)
  CropsTrainingRankSystem.tRankInfoList = {}
  local NewCorpsRankSystem = require("client.slua.logic.corps.logic_corps_rank")
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  NewCorpsRankSystem.SendGetRankAward(LogicCorps.GetLastWeekRankIndex())
  if noRestrict or NetReqMgr.IsValidReq(NetReqMgr.CreateReqKey("send_get_topn_rank", type)) then
    local RankHandler = require("client.network.Protocol.RankHandler")
    local nPersonZoneId = GlobalData.IsJapanOrKorea() and 6 or 1
    RankHandler.send_get_topn_rank(nPersonZoneId, type)
  else
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN)
  end
end
function CropsTrainingRankSystem.OnGetRankData(ok, score_type, list)
  log(bWriteLog and "\232\175\183\230\177\130\229\134\155\229\155\162\230\142\146\232\161\140\230\166\156uin\228\191\161\230\129\175\229\155\158\229\140\133 score_type = " .. score_type)
  log_tree("CropsTrainingRankSystem.OnGetRankData ret = ", list)
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  local rankType = CorpsMacro.RankIndexToType[score_type]
  CropsTrainingRankSystem.tWeekRankList = rankType == CorpsMacro.WeekRank and list or CropsTrainingRankSystem.tWeekRankList
  CropsTrainingRankSystem.tSeasonRankList = rankType == CorpsMacro.SeasonRank and list or CropsTrainingRankSystem.tSeasonRankList
  NetReqMgr.InserReq(NetReqMgr.CreateReqKey("send_get_topn_rank", score_type))
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_UIN)
end
function CropsTrainingRankSystem.SendGetRankInfoData(begin_index, end_index, is_week)
  log(bWriteLog and "CropsTrainingRankSystem.SendGetRankInfoData(begin_index, end_index, is_week)")
  log(bWriteLog and "begin_index = " .. begin_index)
  log(bWriteLog and "end_index = " .. end_index)
  log(bWriteLog and "is_week = " .. tostring(is_week))
  local corps_list = {}
  if is_week and CropsTrainingRankSystem.tWeekRankList then
    for i = begin_index, end_index do
      local data = CropsTrainingRankSystem.tWeekRankList[i]
      if data and not CropsTrainingRankSystem.tRankInfoList[tonumber(data.uid)] then
        table.insert(corps_list, tonumber(data.uid))
      end
    end
  else
    log(bWriteLog and "\229\173\163\229\186\166\229\165\150\229\138\177")
    if CropsTrainingRankSystem.tSeasonRankList then
      for i = begin_index, end_index do
        local data = CropsTrainingRankSystem.tSeasonRankList[i]
        if data and not CropsTrainingRankSystem.tRankInfoList[tonumber(data.uid)] then
          table.insert(corps_list, tonumber(data.uid))
        end
      end
    end
  end
  log_tree("\232\175\183\230\177\130\229\134\155\229\155\162\230\142\146\232\161\140\230\166\156\232\175\166\230\131\133\228\191\161\230\129\175 corps_list = ", corps_list)
  if next(corps_list) then
    local CorpsHander = require("client.network.Protocol.CorpsHandler")
    CorpsHander.send_query_corps_info_for_rank_req(corps_list)
  else
    log(bWriteLog and "\229\133\168\233\131\168\233\131\189\229\156\168\231\188\147\229\173\152\233\135\140\233\157\162\239\188\140\230\151\160\233\156\128\229\143\145\233\128\129\230\149\176\230\141\174")
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO)
  end
end
function CropsTrainingRankSystem.OnGetRankInfoData(ok, ret_list)
  log_tree("CropsTrainingRankSystem.OnGetRankInfoData ret_list=", ret_list)
  log(bWriteLog and "\232\175\183\230\177\130\229\134\155\229\155\162\230\142\146\232\161\140\230\166\156\232\175\166\230\131\133\228\191\161\230\129\175\229\155\158\229\140\133")
  for k, v in pairs(ret_list) do
    if v and v.corps_id then
      CropsTrainingRankSystem.tRankInfoList[tonumber(v.corps_id)] = v
    end
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_INFO)
end
function CropsTrainingRankSystem.SendGetMyRankData(rank_type)
  log(bWriteLog and "\232\175\183\230\177\130\232\135\170\229\183\177\231\154\132\230\142\146\232\161\140\228\191\161\230\129\175 rank_type =" .. rank_type)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    log(bWriteLog and "\232\135\170\229\183\177\230\178\161\230\156\137\229\138\160\229\133\165\228\187\187\228\189\149\229\134\155\229\155\162")
    return
  end
  log(bWriteLog and "\232\135\170\229\183\177\231\154\132\229\134\155\229\155\162id = " .. DataMgr.corpsInfo.id)
  if not NetReqMgr.IsValidReq(NetReqMgr.CreateReqKey("send_get_one_user_rank", "corps_rank_info", rank_type)) then
    return
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local nPersonZoneId = GlobalData.IsJapanOrKorea() and 6 or 1
  RankHandler.send_get_one_user_rank("corps_rank_info", nPersonZoneId, DataMgr.corpsInfo.id, rank_type)
  log(bWriteLog and "lancetest ---\232\175\183\230\177\130\232\135\170\229\183\177\229\134\155\229\155\162\230\142\146\232\161\140\230\166\156\228\191\161\230\129\175\229\155\158\229\140\133" .. tostring(rank_type))
end
function CropsTrainingRankSystem.OnGetMyRankInfoData(client_data, ret, zone_id, rank_info)
  log(bWriteLog and "CropsTrainingRankSystem.OnGetMyRankInfoData ret = " .. tostring(ret))
  log_tree("CropsTrainingRankSystem.OnGetMyRankInfoData rank_info=", rank_info)
  if ret ~= 0 then
    return
  end
  if client_data ~= "corps_rank_info" then
    return
  end
  log(bWriteLog and "\230\142\146\232\161\140\230\166\156\228\191\161\230\129\175")
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  local rankType = CorpsMacro.RankIndexToType[rank_info.score_type]
  if rankType == CorpsMacro.WeekRank then
    local energyType = CorpsMacro.RanIndexToEnergyType[rank_info.score_type]
    CropsTrainingRankSystem.MyWeekRankInfo = rank_info
    CropsTrainingRankSystem.SendGetMyRankData(CorpsMacro.RankTypeToIndex[energyType][CorpsMacro.SeasonRank])
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_HOMEPAGE_REFRESH)
  elseif rankType == CorpsMacro.SeasonRank then
    CropsTrainingRankSystem.MySeasonRankInfo = rank_info
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_MY_INFO)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_HOMEPAGE_REFRESH)
  end
  NetReqMgr.InserReq(NetReqMgr.CreateReqKey("send_get_one_user_rank", "corps_rank_info", rank_info.score_type))
end
function CropsTrainingRankSystem.GetMyRankInfo()
  return CropsTrainingRankSystem.MyWeekRankInfo, CropsTrainingRankSystem.MySeasonRankInfo
end
function CropsTrainingRankSystem.SendGetRankAward(rank_type)
  log(bWriteLog and "\233\162\134\229\143\150\230\142\146\232\161\140\229\165\150\229\138\177 rank_type =" .. rank_type)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if not CorpsMgr.IsInCorps() then
    log(bWriteLog and "\232\135\170\229\183\177\230\178\161\230\156\137\229\138\160\229\133\165\228\187\187\228\189\149\229\134\155\229\155\162")
    return
  end
  CropsTrainingRankSystem.nLastSendAwardType = rank_type
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  local nPersonZoneId = GlobalData.IsJapanOrKorea() and 6 or 1
  CorpsHander.send_query_corps_rank_award(nPersonZoneId, rank_type)
end
function CropsTrainingRankSystem.OnGetMyRankAwardData(ret, score_type, rank_info, other_info, award, err_cnt)
  log(bWriteLog and "\233\162\134\229\143\150\230\142\146\232\161\140\229\165\150\229\138\177\229\155\158\229\140\133")
  log(bWriteLog and "ret = " .. ret)
  log(bWriteLog and "err_cnt = " .. tostring(err_cnt))
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  if ret == 0 or ret == 111324 and err_cnt and err_cnt < 2 then
    log(bWriteLog and "score_type =" .. score_type)
    log_tree("CropsTrainingRankSystem.OnGetMyRankAwardData award =", award)
    log_tree("CropsTrainingRankSystem.OnGetMyRankAwardData rank_info = ", rank_info)
    log_tree("CropsTrainingRankSystem.OnGetMyRankAwardData other_info = ", other_info)
    local rankType = CorpsMacro.RankIndexToType[score_type]
    local award_info = {}
    award_info.icon = DataMgr.corpsInfo.icon
    award_info.is_week = rankType == CorpsMacro.WeekRank
    award_info.last_rank = rank_info.rank_no
    award_info.coprs_name = DataMgr.corpsInfo.name
    award_info.my_activity = other_info.self_active
    award_info.is_get_award = ret == 0
    award_info.last_rank_per = rank_info.rank_rate
    award_info.last_activity = rank_info.score
    award_info.award_id = 0
    award_info.award_num = 0
    for k, v in pairs(award) do
      if v and 0 < v then
        award_info.award_id = k
        award_info.award_num = v
      end
    end
    if rankType == CorpsMacro.WeekRank then
      award_info.need_activity = CorpsMgr.GetConfigToNumber("CorpWeekAwardActiveMin")
    elseif rankType == CorpsMacro.SeasonRank then
      award_info.need_activity = CorpsMgr.GetConfigToNumber("CorpSeasonAwardActiveMin")
    end
    CropsTrainingRankSystem.tRankAwardInfo = award_info
    log_tree("CropsTrainingRankSystem.OnGetMyRankAwardData award_info=", award_info)
    CropsTrainingRankSystem.tRankAwardShowList = {}
    if ret == 0 then
      for k, v in pairs(award) do
        if v and 0 < v then
          table.insert(CropsTrainingRankSystem.tRankAwardShowList, {res_id = k, count = v})
        end
      end
    end
    CropsTrainingRankSystem.SendGetTopMemberInfo(other_info.top_active_list)
    if UIManager.IsUIShow(UIManager.UI_Config.corps_rank_new) then
      log(bWriteLog and "[v_ywuyuan] CropsTrainingRankSystem.OnGetMyRankAwardData !!!")
      local common_config = require("client.slua.common.common_config")
      if not common_config:IsBlockingPopupTip() then
        UIManager.ShowUI(UIManager.UI_Config.Corps_RankAward_UIBP)
      else
        log(bWriteLog and "Don't ShowUI Corps_RankAward_UIBP : UI responsiveness testing")
      end
    end
  elseif CorpsMacro.RankIndexToType[CropsTrainingRankSystem.nLastSendAwardType] == CorpsMacro.WeekRank then
    CropsTrainingRankSystem.SendGetRankAward(LogicCorps.GetLastSeasonRankIndex())
  end
end
local topMemberInfo
function CropsTrainingRankSystem.SetTopMemberInfo(memberInfo)
  topMemberInfo = memberInfo
end
function CropsTrainingRankSystem.GetTopMemberInfo()
  return topMemberInfo
end
function CropsTrainingRankSystem.SendGetTopMemberInfo(top_active_list)
  if #top_active_list < 1 then
    return
  end
  local uid_list = {}
  local uid_to_key = {}
  for k, v in ipairs(top_active_list) do
    uid_list[k] = tonumber(v)
    uid_to_key[uid_list[k]] = k
  end
  log(bWriteLog and "\229\142\187\232\142\183\229\143\150\231\142\169\229\174\182\231\154\132\232\175\166\231\187\134\230\149\176\230\141\174")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  CorpsMgr.GetAvatarBaseInfo(uid_list, function(profileList)
    log(bWriteLog and "\232\142\183\229\143\150\232\175\166\231\187\134\230\149\176\230\141\174\229\155\158\229\140\133")
    log_tree("profileList =", profileList)
    local memberlist = {}
    for _, memberInfo in pairs(profileList) do
      if uid_to_key[tonumber(memberInfo.strUid)] == 1 then
        memberlist[1] = memberInfo
      elseif uid_to_key[tonumber(memberInfo.strUid)] == 2 then
        memberlist[2] = memberInfo
      elseif uid_to_key[tonumber(memberInfo.strUid)] == 3 then
        memberlist[3] = memberInfo
      end
    end
    CropsTrainingRankSystem.SetTopMemberInfo(memberlist)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_TOP_MEMBERINFO)
  end)
end
function CropsTrainingRankSystem.OpenTrainingRankUI()
  if not UIManager.IsUIShow(UIManager.UI_Config.CropsTraining_Rank_UIBP) then
    UIManager.ShowUI(UIManager.UI_Config.CropsTraining_Rank_UIBP)
  end
end
function CropsTrainingRankSystem.ClearFrequencyRestriction()
  NetReqMgr.ClearData()
end
return CropsTrainingRankSystem
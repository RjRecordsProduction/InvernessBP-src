local WarZoneRankSystem = {
  IsOpendWarZone = "IsOpendWarZone",
  recodeInfoList = {},
  recodeCacheMark = {},
  recodeCurSeq = 0,
  recodeWaitSeq = {},
  reqReocdeTimer = nil,
  RankInfoListItem = {
    no = 0,
    uid = "",
    score = 0,
    name = "",
    url = "",
    level = 0,
    gender = 0,
    segment = 0,
    cur_avatar_box_id = 0,
    startup_type = 0,
    showWarZone = true,
    content1 = "",
    content2 = "",
    content3 = "",
    warzone_id = 0,
    roleNation = "",
    collect_data = {}
  },
  RankInfoList = {},
  MyRankInfo = {
    no = 0,
    uid = "",
    score = 0,
    name = "",
    url = "",
    level = 0,
    gender = 0,
    segment = 0,
    cur_avatar_box_id = 0,
    startup_type = 0,
    showWarZone = true,
    content1 = "",
    content2 = "",
    content3 = "",
    warzone_id = 0
  },
  FriendRankInfoList = {},
  client_data = {
    rank_type = 1,
    rank_id = 440305,
    from_index = 1,
    count = 100,
    req_type = 0,
    callback = nil
  },
  RankInfoListCount = 0,
  RankRoleInfoItem = {
    uid = "",
    name = "",
    url = "",
    level = 0,
    gender = 0,
    startup_type = 0,
    segment = 0,
    cur_avatar_box_id = 0,
    warzone_id = 0
  },
  RankRoleInfo = {},
  RankRoleInfoSending = {},
  RankRoleAvatarInfo = {},
  QueryRoleInfoStart = 1,
  QueryRoleInfoCount = 5,
  CallbackList = {},
  CallbackIndex = 1,
  StreetZoneRankInfoList = {},
  StreetZoneLocationInfo = {
    selected_index = 0,
    around_info = {}
  },
  StreetZoneGainTitleList = {},
  WarzoneNewbieStatus = {},
  cachedRankInfo = {},
  cachedRankRecord = {},
  maxCacheCount = 10,
  cached_client_data = {req_type = 0},
  RspUidDir = nil,
  ReqUidDir = nil
}
local ReqRankTimeGap = 150
local REQ_LBS_TOPN_RANK_OK = 0
local REQ_LBS_TOPN_RANK_ERR_WAIT = 4
local GetProvinceList = function()
end
local GetCityList = function(province_id)
end
local GetDistrictList = function(city_id)
end
function WarZoneRankSystem.ClearRankInfoList()
  WarZoneRankSystem.RankInfoList = {}
end
function WarZoneRankSystem.OpenWarZoneRank()
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_WARZONE_MAIN) then
    return
  end
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LbsMgr.OpenUI()
end
function WarZoneRankSystem.OnModePostSwitch(gamestatus)
  BP_WarZoneStreetPkIndex = -1
  WarZoneRankSystem.ClearStreetZoneInfo()
end
function WarZoneRankSystem.Enter()
  log(bWriteLog and "WarZoneRankSystem Enter")
  WarZoneRankSystem.RankInfoList = {}
  WarZoneRankSystem.RankRoleInfo = {}
  WarZoneRankSystem.RankRoleInfoSending = {}
  WarZoneRankSystem.RankRoleAvatarInfo = {}
  local roleId = tonumber(DataMgr.roleData.uid)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({roleId}, function(profileList)
    local list = {}
    for i, v in ipairs(profileList) do
      list[tonumber(v.uid)] = v
    end
    WarZoneRankSystem.ProcessRoleInfoList(list)
    WarZoneRankSystem.UpdateRankSelf()
  end, Enum_PROFILE_REPORT_CFG.WARZONE_ENTER, 10)
  WarZoneRankSystem.FriendRankInfoList = {}
  if DataMgr.lbs_warzone_info ~= nil then
    WarZoneRankSystem.client_data.rank_id = DataMgr.lbs_warzone_info.warzone_id
  else
    WarZoneRankSystem.client_data.rank_id = 440305
  end
  log(bWriteLog and "WarZoneRankSystem Enter rank_id=" .. tostring(WarZoneRankSystem.client_data.rank_id))
end
function WarZoneRankSystem.UpdateRankSelf()
  WarZoneRankSystem.UpdateFriendRole(WarZoneRankSystem.MyRankInfo, tostring(DataMgr.roleData.uid))
  WarZoneRankSystem.MyRankInfo.uid = tostring(DataMgr.roleData.uid)
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_SELF)
end
function WarZoneRankSystem.Release()
  log(bWriteLog and "WarZoneRankSystem Release")
end
WarZoneRankSystem.ModifyWarZoneIgnoreError = false
function WarZoneRankSystem.ModifyWarZoneReq(warZoneId, ignoreError)
end
function WarZoneRankSystem.ModifyWarZoneRes(ret_code, warzone_id)
  log(bWriteLog and string.format("WarZoneRankSystem.ModifyWarZoneRes ret_code=%s, warzone_id=%s", tostring(ret_code), tostring(warzone_id)))
  if not WarZoneRankSystem.ModifyWarZoneIgnoreError or ret_code == 0 then
  end
end
function WarZoneRankSystem.GetWarZoneRankListCountReq(rank_id)
  log(bWriteLog and "WarZoneRankSystem GetWarZoneRankListCountReq: id=" .. tostring(WarZoneRankSystem.client_data.rank_id))
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  if rank_id ~= nil then
    WarzoneHandle.send_query_lbs_warzone_playernum_req(rank_id)
  else
    WarzoneHandle.send_query_lbs_warzone_playernum_req(WarZoneRankSystem.client_data.rank_id)
  end
end
function WarZoneRankSystem.GetWarZoneRankListCountRes(id, count)
  log(bWriteLog and "WarZoneRankSystem GetWarZoneRankListCountRes id=" .. tostring(id) .. " count=" .. tostring(count))
  WarZoneRankSystem.RankInfoListCount = count
  local bundle = {id = id, count = count}
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, bundle)
end
function WarZoneRankSystem.ReqWarzoneRecodeInfo(uidList)
  log_tree("WarZoneRankSystem.ReqWarzoneRecodeInfo = ", uidList)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local invalidList = {}
  for _, uid in pairs(uidList) do
    uid = tonumber(uid)
    local markTime = WarZoneRankSystem.recodeCacheMark[uid] or 0
    if curTime - markTime > ReqRankTimeGap then
      table.insert(invalidList, uid)
    end
  end
  log_tree("invalidList = ", invalidList)
  if 0 < #invalidList then
    local startIndex = 1
    local reqList = {}
    while startIndex <= #invalidList do
      reqList = {}
      for k = startIndex, startIndex + 100 - 1 do
        if invalidList[k] ~= nil then
          table.insert(reqList, invalidList[k])
        end
      end
      WarZoneRankSystem.recodeCurSeq = WarZoneRankSystem.recodeCurSeq + 1
      table.insert(WarZoneRankSystem.recodeWaitSeq, WarZoneRankSystem.recodeCurSeq)
      log_tree(bWriteLog and "reqList = " .. WarZoneRankSystem.recodeCurSeq, reqList)
      local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
      WarzoneHandle.send_batch_get_profile_lbs_warzone_req(reqList, WarZoneRankSystem.recodeCurSeq)
      startIndex = startIndex + 100
    end
    local time_ticker = require("common.time_ticker")
    if WarZoneRankSystem.reqRecordTimer ~= nil then
      time_ticker.RemoveTimer(WarZoneRankSystem.reqRecordTimer)
    end
    WarZoneRankSystem.reqRecordTimer = time_ticker.AddTimerOnce(5, function()
      WarZoneRankSystem.recodeWaitSeq = {}
      log(bWriteLog and "=======================EVENTID_WARZONE_GET_RECODE_INFO timer out")
      EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
    end)
  else
    log(bWriteLog and "=======================EVENTID_WARZONE_GET_RECODE_INFO invalid list is empty")
    EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
  end
end
function WarZoneRankSystem.RspWarzoneRecodeInfo(ret, recodeInfoList, seq)
  if ret == NetErrorCode_NONE then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    for uid, recodeInfo in pairs(recodeInfoList) do
      uid = tonumber(uid)
      WarZoneRankSystem.recodeCacheMark[uid] = curTime
      WarZoneRankSystem.recodeInfoList[uid] = recodeInfo
    end
    if recodeInfoList[tonumber(DataMgr.roleData.uid)] ~= nil then
      WarZoneRankSystem.UpdateRankSelf()
    end
  end
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_FRIEND_RANK_LIST)
  for i, seqCache in ipairs(WarZoneRankSystem.recodeWaitSeq) do
    if seqCache == seq then
      table.remove(WarZoneRankSystem.recodeWaitSeq, i)
      break
    end
  end
  if #WarZoneRankSystem.recodeWaitSeq == 0 then
    if WarZoneRankSystem.reqRecordTimer ~= nil then
      local time_ticker = require("common.time_ticker")
      time_ticker.RemoveTimer(WarZoneRankSystem.reqRecordTimer)
    end
    EventSystem:postEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO)
  end
  local myRecord = recodeInfoList[tonumber(DataMgr.roleData.uid)]
  log_tree("WarZoneRankSystem.RspWarzoneRecodeInfo myRecord = ", myRecord)
  if myRecord and myRecord.lbs_warzone_record then
    log(bWriteLog and "WarZoneRankSystem.RspWarzoneRecodeInfo Post EVENTID_LBS_UPDATE_MY_WARZONE_RECORD")
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_MY_WARZONE_RECORD, myRecord.lbs_warzone_record)
  end
end
function WarZoneRankSystem.GetCurRankTypeScore(uid)
end
function WarZoneRankSystem.GetWarZoneMedalChooseType()
end
function WarZoneRankSystem.GetValidFriendList()
  return {}
end
function WarZoneRankSystem.GetWarZoneFriendListReq()
  logic_connection_waiting:Show(1)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(3, function(...)
    logic_connection_waiting:Hide(1)
  end)
  local function UpdateFriendList()
    EventSystem:unregistEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO, UpdateFriendList)
    local showFriendList = WarZoneRankSystem.GetValidFriendList()
    local bundle = {
      id = WarZoneRankSystem.client_data.rank_id,
      count = #showFriendList
    }
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_LIST_COUNT, bundle)
    local listUid = {}
    for _, uid in ipairs(showFriendList) do
      local uidStr = tostring(uid)
      local role = WarZoneRankSystem.RankRoleInfo[uidStr]
      if role == nil then
        table.insert(listUid, uid)
      end
    end
    if 0 < #listUid then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(listUid, function(profileList)
        local list = {}
        for i, v in ipairs(profileList) do
          list[tonumber(v.uid)] = v
        end
        WarZoneRankSystem.ProcessRoleInfoList(list)
        WarZoneRankSystem.InitFriendList(showFriendList)
        logic_connection_waiting:Hide(1)
        EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
        WarZoneRankSystem.UpdateRankSelf()
      end, Enum_PROFILE_REPORT_CFG.WARZONE_FRIEND, 10)
    else
      logic_connection_waiting:Hide(1)
      WarZoneRankSystem.InitFriendList(showFriendList)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
      WarZoneRankSystem.UpdateRankSelf()
    end
  end
  EventSystem:registEvent(EVENTTYPE_WARZONE, EVENTID_WARZONE_GET_RECODE_INFO, UpdateFriendList)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = LogicFriend.GetAllFriendList()
  table.insert(friendList, DataMgr.roleData.uid)
  WarZoneRankSystem.ReqWarzoneRecodeInfo(friendList)
end
function WarZoneRankSystem.InitFriendList(showFriendList)
  WarZoneRankSystem.FriendRankInfoList = {}
  for _, uid in ipairs(showFriendList) do
    local roleInfo = WarZoneRankSystem.RankRoleInfo[tostring(uid)]
    if roleInfo ~= nil then
      local TableUtil = require("common.table_util")
      local item = TableUtil.CopyTable(WarZoneRankSystem.RankInfoListItem)
      item.uid = tostring(uid)
      if item.score > 0 then
        table.insert(WarZoneRankSystem.FriendRankInfoList, item)
      end
    end
  end
  table.sort(WarZoneRankSystem.FriendRankInfoList, function(a, b)
    return a.score > b.score or a.score == b.score and a.uid > b.uid
  end)
  for index, rankInfo in ipairs(WarZoneRankSystem.FriendRankInfoList) do
    local prevRankInfo = WarZoneRankSystem.FriendRankInfoList[index - 1]
    if prevRankInfo ~= nil and prevRankInfo.score == rankInfo.score then
      rankInfo.no = prevRankInfo.no
    else
      rankInfo.no = index
    end
    if tostring(rankInfo.uid) == tostring(WarZoneRankSystem.MyRankInfo.uid) then
      WarZoneRankSystem.MyRankInfo.no = rankInfo.no
    end
  end
end
function WarZoneRankSystem.GetMyFriendRankNo()
  table.sort(WarZoneRankSystem.FriendRankInfoList, function(a, b)
    return a.score > b.score or a.score == b.score and a.uid > b.uid
  end)
  for index, rankInfo in ipairs(WarZoneRankSystem.FriendRankInfoList) do
    if tostring(rankInfo.uid) == tostring(WarZoneRankSystem.MyRankInfo.uid) then
      return index
    end
  end
  return 0
end
function WarZoneRankSystem.GetWarZoneRankListReq()
  log(bWriteLog and "WarZoneRankSystem GetWarZoneRankListReq: type=" .. tostring(WarZoneRankSystem.client_data.rank_type) .. " id=" .. tostring(WarZoneRankSystem.client_data.rank_id) .. " from_index=" .. tostring(WarZoneRankSystem.client_data.from_index))
  WarZoneRankSystem.client_data.req_type = 0
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  WarzoneHandle.send_get_lbs_topn_rank(WarZoneRankSystem.client_data)
end
function WarZoneRankSystem.GetWarZoneRankListRes(ret_code, client_data, rank_list)
  if rank_list ~= nil then
    log_tree("WarZoneRankSystem GetWarZoneRankListRes ret=" .. ret_code .. " list=", rank_list)
  else
    log(bWriteLog and "WarZoneRankSystem GetWarZoneRankListRes ret=" .. ret_code)
  end
  if ret_code == REQ_LBS_TOPN_RANK_OK then
    if client_data.req_type == 0 then
      WarZoneRankSystem.RankInfoList = {}
      local selfScore = false
      if rank_list ~= nil then
        for i, v in ipairs(rank_list) do
          local TableUtil = require("common.table_util")
          local item = TableUtil.CopyTable(WarZoneRankSystem.RankInfoListItem)
          item.no = v.rank_no
          item.uid = tostring(v.uid)
          item.score = math.floor(v.score + 0.5)
          item.ext_data = v.ext_data
          WarZoneRankSystem.UpdateRankRole(item, v.uid)
          table.insert(WarZoneRankSystem.RankInfoList, item)
          if item.uid == tostring(DataMgr.roleData.uid) then
            WarZoneRankSystem.MyRankInfo.score = item.score
            WarZoneRankSystem.MyRankInfo.no = item.no
            selfScore = true
          end
        end
      end
      if selfScore == false then
        WarZoneRankSystem.MyRankInfo.no = 0
      end
      WarZoneRankSystem.UpdateRankSelf()
    end
  elseif ret_code == REQ_LBS_TOPN_RANK_ERR_WAIT then
    DataMgr.ShowMessageBoxByID(ret_code)
    WarZoneRankSystem.RankInfoList = {}
    log(bWriteLog and "WarZoneRankSystem need wait. retry")
    logic_connection_waiting:Show(1)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, function(...)
      logic_connection_waiting:Hide(1)
      local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
      WarzoneHandle.send_get_lbs_topn_rank(WarZoneRankSystem.client_data)
    end)
  else
    WarZoneRankSystem.RankInfoList = {}
    ShowNotice(ret_code)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST, client_data)
  if ret_code == 0 and client_data.req_type == 0 then
    WarZoneRankSystem.CacheRankResult(client_data.rank_id, client_data.rank_type, rank_list)
  end
end
function WarZoneRankSystem.TryUseCachedRank(rank_id, rank_type, client_data)
  local cachedRankInfo = WarZoneRankSystem.cachedRankInfo
  local rankTypeTable = cachedRankInfo[rank_type]
  if rankTypeTable then
    local rankInfo = rankTypeTable[rank_id]
    if rankInfo then
      local data = rankInfo.data
      if data then
        WarZoneRankSystem.GetWarZoneRankListRes(0, client_data, data)
        return true
      end
    end
  end
  return false
end
function WarZoneRankSystem.CacheRankResult(rank_id, rank_type, rank_list)
  if rank_type and rank_id then
    local cachedRankInfo = WarZoneRankSystem.cachedRankInfo
    local cachedRankRecord = WarZoneRankSystem.cachedRankRecord
    if #cachedRankRecord >= WarZoneRankSystem.maxCacheCount then
      local first = cachedRankRecord[1]
      local removeCacheRankID = first.rank_id
      local removeCacheRankType = first.rank_type
      if removeCacheRankID and removeCacheRankType then
        cachedRankInfo[removeCacheRankType][removeCacheRankID] = nil
      end
      table.remove(cachedRankRecord, 1)
    end
    local rankTypeTable = cachedRankInfo[rank_type]
    if not rankTypeTable then
      rankTypeTable = {}
      cachedRankInfo[rank_type] = rankTypeTable
    end
    local rankCacheTable = rankTypeTable[rank_id]
    if not rankCacheTable then
      cachedRankRecord[#cachedRankRecord + 1] = {rank_id = rank_id, rank_type = rank_type}
      rankCacheTable = {}
      rankTypeTable[rank_id] = rankCacheTable
    end
    rankCacheTable.data = rank_list
  end
end
function WarZoneRankSystem.OnGameStateChange(eventType, eventID, gameState)
  if gameState.current == GameStatus.Login or gameState.current == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    log(bWriteLog and "===================> WarZoneRankSystem.OnGameStateChange")
    WarZoneRankSystem.cachedRankInfo = {}
    WarZoneRankSystem.cachedRankRecord = {}
  end
end
local RankSorceInt = function(score)
  return math.floor(score + 0.5)
end
function WarZoneRankSystem.UpdateRankRole(itm, uid)
  local role = WarZoneRankSystem.RankRoleInfo[uid]
  if role == nil then
    return false
  end
  log_tree("update record:" .. uid .. " ", role)
  itm.name = role.name
  itm.url = role.url
  itm.level = role.level
  itm.city = role.city
  itm.gender = role.gender
  itm.startup_type = role.startup_type
  itm.cur_avatar_box_id = role.cur_avatar_box_id
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local roleInfo = logic_profile:GetLocalProfile(uid)
  if nil ~= roleInfo then
    role.lbs_warzone_info = roleInfo.lbs_warzone_info
    itm.collect_data = roleInfo.collect_data or {}
  end
  itm.showWarZone = role.showWarZone
  if itm.score ~= nil then
    itm.score = RankSorceInt(itm.score)
  else
    itm.score = 0
  end
  itm.warzone_id = role.warzone_id
end
function WarZoneRankSystem.UpdateFriendRole(itm, uid)
  local role = WarZoneRankSystem.RankRoleInfo[uid]
  if role == nil then
    return false
  end
  log_tree("update record:" .. uid .. " ", role.segment)
  itm.name = role.name
  itm.url = role.url
  itm.level = role.level
  itm.city = role.city
  itm.gender = role.gender
  itm.startup_type = role.startup_type
  itm.cur_avatar_box_id = role.cur_avatar_box_id
  itm.showWarZone = role.showWarZone
  itm.warzone_id = role.warzone_id
  itm.roleNation = role.nation
end
function WarZoneRankSystem.GetTableMax(tb)
  local maxVal = 0
  if tb == nil then
    log_error("WarZoneRankSystem.GetTableMax tb is nil")
    return maxVal
  end
  for k, v in pairs(tb) do
    if v > maxVal then
      maxVal = v
    end
  end
  return maxVal
end
local GetRankListByTab = function(tab)
  if tab == 1 then
    return WarZoneRankSystem.RankInfoList
  elseif tab == 2 then
    return WarZoneRankSystem.FriendRankInfoList
  end
end
function WarZoneRankSystem.QueryRankRoleInfoByScroll(tab)
  local listUid = {}
  local onePageCount = WarZoneRankSystem.QueryRoleInfoCount
  local startIndex = WarZoneRankSystem.QueryRoleInfoStart
  local pageidx = math.modf(startIndex / onePageCount)
  for i = pageidx - 1, pageidx + 2 do
    for j = 1, onePageCount do
      local idx = i * onePageCount + j
      local itm = GetRankListByTab(tab)[idx]
      if itm then
        local role = WarZoneRankSystem.RankRoleInfo[itm.uid]
        if role == nil then
          local TimeUtil = require("client.common.time_util")
          local curtm = TimeUtil.OSTime()
          local tm = WarZoneRankSystem.RankRoleInfoSending[itm.uid]
          if tm == nil or 30 < curtm - tm then
            WarZoneRankSystem.RankRoleInfoSending[itm.uid] = curtm
            table.insert(listUid, tonumber(itm.uid))
          end
        end
      end
    end
  end
  if 0 < #listUid then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(listUid, WarZoneRankSystem.RspRankRoleInfo, Enum_PROFILE_REPORT_CFG.WARZONE_SCROLL, 10)
  else
    WarZoneRankSystem.RspRankRoleInfo({})
    WarZoneRankSystem.UpdateRankSelf()
  end
end
function WarZoneRankSystem.ProcessRoleInfoList(list)
  for k, v in pairs(list) do
    local TableUtil = require("common.table_util")
    local role = TableUtil.CopyTable(WarZoneRankSystem.RankRoleInfoItem)
    role.uid = tostring(k)
    role.name = v.nickName
    role.url = v.picUrl
    role.level = v.level
    role.gender = v.sex
    role.showWarZone = v.showWarZone
    if v.startup_type ~= nil then
      role.startup_type = v.startup_type
    end
    role.segment = v.segment_info
    if type(v.cur_avatar_box_id) == "number" then
      role.cur_avatar_box_id = v.cur_avatar_box_id
    end
    if v.warZoneID ~= 0 then
      role.warzone_id = v.warZoneID
    end
    WarZoneRankSystem.RankRoleInfo[role.uid] = role
    WarZoneRankSystem.RankRoleInfoSending[role.uid] = nil
  end
end
function WarZoneRankSystem.RspRankRoleInfo(profileList)
  if type(profileList) ~= "table" then
    return
  end
  local list = {}
  for i, v in ipairs(profileList) do
    list[tonumber(v.uid)] = v
  end
  WarZoneRankSystem.ProcessRoleInfoList(list)
  for i, v in ipairs(WarZoneRankSystem.RankInfoList) do
    if list[tonumber(v.uid)] ~= nil then
      WarZoneRankSystem.UpdateRankRole(v, v.uid)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_ITEM, {1, v})
    end
  end
  for k, v in pairs(list) do
    if tostring(DataMgr.roleData.uid) == tostring(k) then
      WarZoneRankSystem.UpdateRankSelf()
      break
    end
  end
end
function WarZoneRankSystem.GetStreetListInfo(vars)
  local around_info = {}
  if vars ~= nil then
    local index = 1
    for k, v in pairs(vars) do
      if string.len(v.title) <= 24 then
        around_info[index] = {
          longitude = tonumber(v.location.lng),
          latitude = tonumber(v.location.lat),
          name = v.title
        }
        index = index + 1
        if 11 <= index then
          break
        end
      end
    end
  end
  return around_info
end
function WarZoneRankSystem.RequestLocatizeCurStreetZone()
  logic_connection_waiting:Show(1)
  local function GetLocationCallback()
    EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_WARZONE_GET_CITYCODE, GetLocationCallback)
    logic_connection_waiting:Hide(1)
  end
  local LocationFail = function(_, _, vars)
    if vars.errorCode ~= 0 then
      logic_connection_waiting:Hide(1)
    end
  end
  local PermissionFail = function()
    logic_connection_waiting:Hide(1)
  end
  EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_WARZONE_GET_CITYCODE, GetLocationCallback)
  EventSystem:registEvent(EVENTTYPE_PLATFORM, EVENT_PLATFORM_REQUEST_LOCATION_FINISH, LocationFail)
end
function WarZoneRankSystem.ClearStreetZoneInfo()
  WarZoneRankSystem.StreetZoneLocationInfo = {
    selected_index = 0,
    around_info = {}
  }
  WarZoneRankSystem.StreetZoneRankInfoList = {}
  BP_WarZoneStreetPkIndex = -1
end
function WarZoneRankSystem.query_lbs_streetzone_my_rank_req(latitude, longitude, rankList)
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  WarzoneHandle.send_query_lbs_streetzone_my_rank_req(latitude, longitude, rankList)
end
function WarZoneRankSystem.query_lbs_streetzone_my_rank_rsp(ret, rankList, rank_no_list)
  if ret == 0 then
    for index, rank in ipairs(rankList) do
      if rank_no_list[index] ~= 0 then
        WarZoneRankSystem.StreetZoneGainTitleList[rank] = rank_no_list[index]
      end
    end
  else
    ShowNotice(ret)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_CUR_STREET_TITLE_LIST, WarZoneRankSystem.StreetZoneGainTitleList)
end
function WarZoneRankSystem.query_lbs_streetzone_rank_req(latitude, longitude, rank)
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  WarzoneHandle.send_query_lbs_streetzone_rank_req(latitude, longitude, rank)
end
function WarZoneRankSystem.query_lbs_streetzone_rank_rsp(ret_code, rank, data)
  WarZoneRankSystem.StreetZoneRankInfoList = {}
  WarZoneRankSystem.MyRankInfo.no = 0
  if ret_code == 0 then
    if rank ~= WarZoneRankSystem.client_data.rank_type then
      return
    end
    if data ~= nil then
      for i, v in pairs(data) do
        local TableUtil = require("common.table_util")
        local item = TableUtil.CopyTable(WarZoneRankSystem.RankInfoListItem)
        item.no = v.rank_no
        item.uid = tostring(i)
        item.score = math.floor(v.score + 0.5)
        WarZoneRankSystem.UpdateRankRole(item, tostring(i))
        table.insert(WarZoneRankSystem.StreetZoneRankInfoList, item)
        if item.uid == tostring(DataMgr.roleData.uid) then
          WarZoneRankSystem.MyRankInfo.no = item.no
        end
      end
    else
    end
    table.sort(WarZoneRankSystem.StreetZoneRankInfoList, function(a, b)
      return a.no < b.no
    end)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
  else
    DataMgr.ShowMessageBoxByID(ret_code)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_RANK_UPDATE_LIST)
  WarZoneRankSystem.UpdateRankSelf()
end
function WarZoneRankSystem.pk_lbs_streetzone_rank_req(latitude, longitude, rank)
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  WarzoneHandle.send_pk_lbs_streetzone_rank_req(latitude, longitude, rank)
  WarzoneHandle.send_query_lbs_streetzone_rank_req(latitude, longitude, rank)
end
function WarZoneRankSystem.pk_lbs_streetzone_rank_rsp(ret_code, rank, rank_list)
  if ret_code == 0 then
  else
    DataMgr.ShowMessageBoxByID(ret_code)
  end
end
function WarZoneRankSystem.GetRoleAvatarWearRsp(ret_code, uid, callback, avatar_wear_info)
  log(bWriteLog and "===========GetRoleAvatarWearRsp=============")
  if ret_code == 0 then
    WarZoneRankSystem.RankRoleAvatarInfo[uid] = avatar_wear_info
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, uid)
    return
  elseif ret_code == 1 then
    ShowDevNotice("###avatar\229\143\130\230\149\176\233\148\153\232\175\175, uid=" .. tostring(uid))
  elseif ret_code == 2 then
    ShowDevNotice("###avatar\230\159\165\232\175\162\229\164\177\232\180\165, uid=" .. tostring(uid))
  end
  WarZoneRankSystem.RankRoleAvatarInfo[uid] = {
    avatar = {
      gamegender = 2,
      headid = 401999,
      hairid = 40601001
    },
    wear = {},
    avatar_feature_list = {},
    weapon_wear = {res_id = 101004001}
  }
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, uid)
end
function WarZoneRankSystem.GetFirstMedal()
  local arr = {}
  for k, v in pairs(CDataTable.GetTable("lbsranktypetable")) do
    local TableUtil = require("common.table_util")
    local item = TableUtil.CopyTable(v)
    table.insert(arr, item)
  end
  table.sort(arr, function(a, b)
    return a.order < b.order
  end)
  return arr[1].id
end
local ShowWarzoneCache = true
function WarZoneRankSystem.ChangeShowWarzoneState(isShow)
  ShowWarzoneCache = isShow
  log(bWriteLog and "==============changeShow " .. tostring(isShow))
end
function WarZoneRankSystem.ChangeShowWarzoneState_Rsp(ret)
  if ret ~= NetErrorCode_NONE then
    ShowNotice(ret)
  else
    log(bWriteLog and "============================ChangeShowWarzoneState_Rsp " .. tostring(ShowWarzoneCache))
    DataMgr.roleData.showWarZone = ShowWarzoneCache
  end
end
function WarZoneRankSystem.GetAreaCfg(areaId)
  for k, v in pairs(CDataTable.GetTable("GlobalCountryCfg")) do
    if v.Level == 3 and v.ID == areaId then
      return v
    end
  end
  return nil
end
function WarZoneRankSystem.SaveRankProfileInfo(profileList, UidList)
  if not WarZoneRankSystem.RspUidDir then
    WarZoneRankSystem.RspUidDir = {}
  end
  local TableUtil = require("common.table_util")
  local reqUidList = TableUtil.CopyTable(UidList) or {}
  for i = #reqUidList, 1, -1 do
    local uid = tonumber(reqUidList[i])
    local bGet = false
    for _, profileinfo in pairs(profileList) do
      if profileinfo.uid == uid then
        bGet = true
        break
      end
    end
    if bGet then
      WarZoneRankSystem.RspUidDir[uid] = 3
      table.remove(reqUidList, i)
      WarZoneRankSystem.ReqUidDir[uid] = nil
    end
  end
  for i, uid in pairs(reqUidList or {}) do
    uid = tonumber(uid)
    WarZoneRankSystem.RspUidDir[uid] = 2
  end
  for uid, _ in pairs(WarZoneRankSystem.ReqUidDir or {}) do
    uid = tonumber(uid)
    local flag = WarZoneRankSystem.RspUidDir[uid]
    if not flag then
      WarZoneRankSystem.RspUidDir[uid] = 1
    end
  end
end
function WarZoneRankSystem.SaveReqUidList(uidlist)
  if not WarZoneRankSystem.ReqUidDir then
    WarZoneRankSystem.ReqUidDir = {}
  end
  for i, uid in ipairs(uidlist) do
    uid = tonumber(uid)
    WarZoneRankSystem.ReqUidDir[uid] = true
  end
end
function WarZoneRankSystem.GetProfileoStatusFlag(uid)
  uid = tonumber(uid)
  return WarZoneRankSystem.RspUidDir[uid]
end
function WarZoneRankSystem.ClearProfile()
  WarZoneRankSystem.ReqUidDir = nil
  WarZoneRankSystem.RspUidDir = nil
end
return WarZoneRankSystem
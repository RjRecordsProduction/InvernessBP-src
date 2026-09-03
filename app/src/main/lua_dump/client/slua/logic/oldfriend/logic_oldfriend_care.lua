local logic_oldfriend_care = {
  itemList = {},
  toggle = false,
  para = {},
  scoreList = {},
  defaultScoreID = 1603002
}
local C_DaySeconds = 86400
function logic_oldfriend_care.GetScoreID()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local scoreConfig = AssemblyActivitySystem.GetScoreConfig()
  return scoreConfig and scoreConfig.Assemb_consum_item_id or logic_oldfriend_care.defaultScoreID
end
function logic_oldfriend_care.OnLogin()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  if not AssemblyActivitySystem.GetActivityData() then
    return
  end
  local OldfriendCareHandle = require("client.network.Protocol.OldfriendCareHandle")
  OldfriendCareHandle.send_get_rejoiner_assemb_info_req()
  AssemblyActivitySystem.ReqGrowthCfgData()
end
function logic_oldfriend_care.InitData(data, para)
  logic_oldfriend_care.itemList = {}
  for exchange_Id, info in pairs(data.exchange_list) do
    logic_oldfriend_care.itemList[exchange_Id] = {}
    local count = info.total_count or 0
    logic_oldfriend_care.itemList[exchange_Id].total_  end
  logic_oldfriend_care.toggle = data.rejoin_status_switch
  logic_oldfriend_care.  logic_oldfriend_care.scoreList = data.score_flow
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  AssemblyActivitySystem.rejoin_care_count = data.rejoin_care_count or 0
  AssemblyActivitySystem.battle_score_count = data.battle_score_count or 0
  AssemblyActivitySystem.score_flow = data.score_flow or {}
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLF_FRIEND_CARE_REWARD_UPDATE)
end
function logic_oldfriend_care.UpdateScoreList(scoreList, scoreDelList)
  logic_oldfriend_care.  logic_oldfriend_care.  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLD_FRIEND_CARE_SCORE_FLOW_UPDATE)
end
function logic_oldfriend_care.IsValidTimestampByFrData(friendData)
  if not friendData or not friendData.rejoin_user_status then
    return false
  end
  local days = logic_oldfriend_care.para.back_user_life_time
  if friendData.dynamic_life_time then
    days = friendData.dynamic_life_time
    log(bWriteLog and "[v_wllwu] logic_oldfriend_care.IsValidTimestampByFrData days = " .. tostring(days) .. " uid = " .. tostring(friendData.uid))
  end
  if not days then
    log(bWriteLog and "[v_wllwu] logic_oldfriend_care.IsValidTimestampByFrData days error")
    return false
  end
  local friendStamp = friendData.rejoin_user_status
  local second = days * C_DaySeconds
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if now >= friendStamp + second then
    return false
  end
  return true
end
function logic_oldfriend_care.IsRejoinPlayer(profile)
  if profile and profile.rejoin_start_time and profile.dynamic_life_time then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local rejoin_start_time = profile.rejoin_start_time
    local rejoin_end_time = rejoin_start_time + profile.dynamic_life_time * C_DaySeconds
    if serverTime < rejoin_end_time then
      return true
    end
    log(bWriteLog and string.format("logic_oldfriend_care.IsRejoinPlayer, uid:%s", profile.uid))
    log(bWriteLog and "logic_oldfriend_care.IsRejoinPlayer, rejoin_start_time is: " .. tostring(rejoin_start_time) .. "; rejoin_end_time is: " .. tostring(rejoin_end_time) .. "; serverTime is: " .. tostring(serverTime))
  end
  return false
end
function logic_oldfriend_care.GetRejoinFriendList()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local dList = LogicFriend.GetAllFriendList()
  local list = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, uid in pairs(dList) do
    local uData = logic_profile:GetLocalProfile(uid)
    if logic_oldfriend_care.IsRejoinPlayer(uData) then
      table.insert(list, uid)
    end
  end
  return list
end
function logic_oldfriend_care.UpdateExchangeInfo(id, exchange_info)
  if id then
    if not logic_oldfriend_care.itemList[id] then
      logic_oldfriend_care.itemList[id] = {}
    end
    logic_oldfriend_care.itemList[id].total_count = exchange_info.total_count
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_OLF_FRIEND_CARE_REWARD_UPDATE)
end
function logic_oldfriend_care.GetExchangeRewardData()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local cfgData = AssemblyActivitySystem.GetGrowthCfgData()
  local exchangeData = logic_oldfriend_care.itemList
  local Data = {}
  for exchangeId, dInfo in pairs(cfgData) do
    if type(dInfo) == "table" then
      local info = {
        item_id = dInfo.item_id,
        consum_num = dInfo.assemb_consum_num,
        total_limit = dInfo.total_limit,
        item_num = dInfo.item_num,
        item_expire_hour = dInfo.item_expire_hour,
        total_count = exchangeData[exchangeId] and exchangeData[exchangeId].total_count or 0
      }
      table.insert(Data, {exchangeId = exchangeId, info = info})
    end
  end
  return Data
end
function logic_oldfriend_care.ChangeToggle(toggle)
  logic_oldfriend_care.end
function logic_oldfriend_care.GetScoreList()
  return logic_oldfriend_care.scoreList
end
function logic_oldfriend_care.GetScoreDelList()
  return logic_oldfriend_care.scoreDelList
end
function logic_oldfriend_care.JumpToSpace(uid)
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(uid)
end
function logic_oldfriend_care.GetOldFriendUidList()
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.FetchFriends()
  local friends = LogicTeamUpSideBar.GetFriends()
  local oldFriendList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, info in pairs(friends) do
    local profile = logic_profile:GetLocalProfile(info.uid)
    if profile and logic_oldfriend_care.IsRejoinPlayer(profile) then
      table.insert(oldFriendList, info.uid)
    end
  end
  return oldFriendList
end
return logic_oldfriend_care
local logic_match_blacklist = {}
function logic_match_blacklist:DefineAndResetData()
  self.matchBlackMap = {}
  self.Enum_Add_Match_Black_Scene = {
    Chat_Menu_BP = 2,
    Popularity_Contri_Menu = 3,
    Popularity_Recent_Menu = 4,
    Lobby_RoleInfo_Combat = 5,
    Lobby_RoleInfo_Segment = 6,
    Featured_Comment_Menu = 7,
    Comment_Manage_Menu = 8,
    Home_Message_Board = 9,
    Home_Pigeon = 10
  }
  self.toplimit = 10
  self.MatchBlackMapTopUID = 0
end
function logic_match_blacklist:OnInitialize()
end
function logic_match_blacklist:RegistEvents()
end
function logic_match_blacklist:OnLogin(bReLogin)
end
function logic_match_blacklist:OnLogOut()
end
function logic_match_blacklist:OnPreSwitchGameStatus(preState, nextState)
end
function logic_match_blacklist:OnPostSwitchGameStatus(preState, nextState)
end
function logic_match_blacklist:GetMatchBlackMap()
  return self.matchBlackMap
end
function logic_match_blacklist:GetMatchBlackMapID(uid)
  if self.matchBlackMap[tonumber(uid)] then
    return true
  end
  return false
end
function logic_match_blacklist:GetMatchBlackMapSize()
  local count = 0
  for _ in pairs(self.matchBlackMap) do
    count = count + 1
  end
  return count
end
function logic_match_blacklist:GetMatchBlackMapLestNum()
  log(bWriteLog and "logic_match_blacklist:GetMatchBlackMapLestNum")
  local count = self:GetMatchBlackMapSize()
  return self.toplimit - count
end
function logic_match_blacklist:RefreshBlackMap(uids)
  log(bWriteLog and "logic_match_blacklist:RefreshBlackMap")
  log_tree("logic_match_blacklist:RefreshBlackMap", uids)
  self.matchBlackMap = {}
  self.MatchBlackMapTopUID = uids[1]
  for _, v in pairs(uids or {}) do
    self.matchBlackMap[tonumber(v)] = true
  end
end
function logic_match_blacklist:send_get_match_black_list_req()
  log(bWriteLog and "logic_match_blacklist:send_get_match_black_list_req")
  local FriendBlacklistHandler = require("client.network.Protocol.FriendBlacklistHandler")
  FriendBlacklistHandler.send_get_match_black_list_req()
end
function logic_match_blacklist:on_get_match_black_list_rsp(res, black_list)
  log(bWriteLog and "logic_match_blacklist:on_get_match_black_list_rsp res = " .. res)
  log_tree("logic_match_blacklist:on_get_match_black_list_rsp black_list =", black_list)
  if res == 0 then
    self:RefreshBlackMap(black_list)
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_MATCHBLACKLIST_UPDATE)
  end
end
function logic_match_blacklist:send_add_match_black_list_req(black_uid, scene_id)
  local FriendBlacklistHandler = require("client.network.Protocol.FriendBlacklistHandler")
  FriendBlacklistHandler.send_add_match_black_list_req(tonumber(black_uid), scene_id)
end
function logic_match_blacklist:on_add_match_black_list_rsp(res, black_uid, black_list)
  if res == 0 then
    self:RefreshBlackMap(black_list)
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_MATCHBLACKLIST_ADD)
  end
end
function logic_match_blacklist:send_del_match_black_list_req(black_uid)
  local FriendBlacklistHandler = require("client.network.Protocol.FriendBlacklistHandler")
  FriendBlacklistHandler.send_del_match_black_list_req(black_uid)
end
function logic_match_blacklist:on_del_match_black_list_rsp(res, black_uid, black_list)
  if res == 0 then
    self:RefreshBlackMap(black_list)
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_MATCHBLACKLIST_REMOVE)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local logic_match_blacklist = class(CModuleBase, nil, logic_match_blacklist)
return logic_match_blacklist
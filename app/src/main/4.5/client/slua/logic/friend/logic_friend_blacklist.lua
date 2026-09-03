local logic_friend_blacklist = {}
function logic_friend_blacklist:DefineAndResetData()
  self.blackMap = {}
  self.byblackMap = {}
  self.Enum_Add_Black_Scene = {
    Chat_Menu_BP = 2,
    Popularity_Contri_Menu = 3,
    Popularity_Recent_Menu = 4,
    Lobby_RoleInfo_Combat = 5,
    Lobby_RoleInfo_Segment = 6,
    Featured_Comment_Menu = 7,
    Comment_Manage_Menu = 8,
    Home_Message_Board = 9,
    Home_Pigeon = 10,
    MainCity_Info_Card = 11,
    Popularity_Guest_Menu = 12
  }
  self.topLimit = 300
end
function logic_friend_blacklist:IsBlacklist(uid)
  if self.blackMap[tonumber(uid)] then
    return true
  end
  return false
end
function logic_friend_blacklist:RemoveBlacklist(uid)
  if not self.blackMap[uid] then
    return
  end
  self.blackMap[uid] = nil
end
function logic_friend_blacklist:GetBlacklist()
  local list = {}
  for uid, _ in pairs(self.blackMap) do
    table.insert(list, uid)
  end
  return list
end
function logic_friend_blacklist:GetBlackMap()
  return self.blackMap
end
function logic_friend_blacklist:proc_get_black_list_rsp(uids)
  self.blackMap = {}
  for _, v in pairs(uids) do
    self.blackMap[tonumber(v)] = true
  end
  if next(self.blackMap) then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_BLACK, uids, LogicFriend.on_batch_get_profile_rsp)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BLACKLIST_UPDATE)
end
function logic_friend_blacklist:proc_get_byblack_list_rsp(uids)
  self.byblackMap = {}
  for _, v in pairs(uids or {}) do
    self.byblackMap[tonumber(v)] = true
  end
end
function logic_friend_blacklist:IsByBlacklist(uid)
  if not uid then
    return false
  end
  if self.byblackMap[tonumber(uid)] then
    return true
  end
  return false
end
function logic_friend_blacklist:RemoveByBlacklist(uid)
  if not uid then
    log_warning(bWriteLog and "logic_friend_blacklist:RemoveByBlacklist failed due to invalid uid")
    return
  end
  if not self.byblackMap[tonumber(uid)] then
    return
  end
  self.byblackMap[tonumber(uid)] = nil
end
function logic_friend_blacklist:proc_add_black_list_req(friUid, add_black_scene, extend_info)
  log(bWriteLog and "logic_friend_blacklist.add_black_list_req uid: " .. friUid)
  friUid = tonumber(friUid)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return false
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local mateUID = logic_home_joint:GetMyJointMate()
  if friUid == tonumber(mateUID) then
    ShowNotice(655887)
    return false
  end
  if self:IsBlacklist(friUid) then
    ShowNotice(200009)
    return false
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:DelApplyList(friUid)
  if GameStatus.IsInMainCity() then
    extend_info = extend_info or {}
    extend_info.sceneType = "MainCity"
  end
  local FriendBlacklistHandler = require("client.network.Protocol.FriendBlacklistHandler")
  FriendBlacklistHandler.send_add_black_list_req(friUid, add_black_scene, extend_info)
  return true
end
function logic_friend_blacklist:proc_add_black_list_rsp(friUid)
  log(bWriteLog and string.format("logic_friend_blacklist:proc_add_black_list_rsp friUid:" .. friUid))
  if self:IsBlacklist(friUid) then
    log(bWriteLog and string.format("logic_friend_blacklist:proc_add_black_list_rsp IsBlacklist"))
    return
  end
  self.blackMap[friUid] = true
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.DeleteInnerFriend(friUid)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  logic_friend_gang_up:DeleteInnerFriend(friUid)
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  FriendApplyHandler.send_get_addfriend_reqlist_req()
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BLACKLIST_ADD, friUid)
end
function logic_friend_blacklist:proc_del_black_list_rsp(uid)
  log(bWriteLog and string.format("logic_friend_blacklist:RemoveBlacklist uid:%s ", uid))
  self:RemoveBlacklist(uid)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BLACKLIST_REMOVE)
end
function logic_friend_blacklist:proc_add_black_change_notify(friUid, bIsAdd)
  log(bWriteLog and "logic_friend_blacklist:proc_add_black_change_notify friUid" .. tostring(friUid) .. " bIsAdd" .. tostring(bIsAdd))
  if bIsAdd then
  else
    if self.byblackMap[friUid] then
      self.byblackMap[friUid] = nil
    else
      self.byblackMap[friUid] = true
    end
    log(bWriteLog and "logic_friend_blacklist:proc_add_black_change_notify byBlackList change to " .. tostring(self.byblackMap[friUid]))
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BYBLACKLIST_UPDATE)
  end
end
function logic_friend_blacklist:IsLimit()
  log(bWriteLog and "logic_friend_blacklist:IsLimit")
  local bislimit = false
  if self:GetBlackMapSize() >= self.topLimit then
    bislimit = true
  else
    bislimit = false
  end
  log(bWriteLog and "logic_friend_blacklist:IsLimit =" .. tostring(bislimit) .. " blackMap length:" .. tostring(#self.blackMap))
  return bislimit
end
function logic_friend_blacklist:GetBlackMapSize()
  local count = 0
  for _ in pairs(self.blackMap) do
    count = count + 1
  end
  return count
end
function logic_friend_blacklist:SetTopLimit(limit)
  log(bWriteLog and "logic_friend_blacklist:SetTopLimit limit:" .. tostring(limit))
  local numberLimit = tonumber(limit)
  self.topLimit = numberLimit
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicFriendBlacklist = class(CModuleBase, nil, logic_friend_blacklist)
return CLogicFriendBlacklist
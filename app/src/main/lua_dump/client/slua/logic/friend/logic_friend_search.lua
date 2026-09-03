local logic_friend_search = {}
function logic_friend_search:DefineAndResetData()
  self.searchList = {}
  self.bFromRecommand = false
  self.bFriendLimitSearch = false
  self.lastFriendSearchCondition = nil
  self.lastSearchUID = 0
  self.friendSearchDataBeforeJump = {
    searchNameOrUID = nil,
    searchList = nil,
    nation = nil,
    comboboxIndex = nil,
    bFriendLimitSearch = false,
    bSearchFromQRCode = false
  }
  self.IsOpenGMTest = false
end
function logic_friend_search:find_uid_by_name_req(name)
  log(bWriteLog and "logic_friend_search:find_uid_by_name_req: " .. name)
  self.lastFriendSearchCondition = nil
  local FriendSearchHandler = require("client.network.Protocol.FriendSearchHandler")
  FriendSearchHandler.send_find_uid_by_name_req(name)
end
function logic_friend_search:proc_find_uid_by_name_rsp(res, name, uids)
  log(bWriteLog and "logic_friend_search.:proc_find_uid_by_name_rsp: " .. res .. " name: " .. name)
  self.bFromRecommand = false
  self.bFriendLimitSearch = true
  self.searchList = {}
  if res == "have-dirty-in-name" then
    ShowNotice(990004)
    return
  end
  if res ~= NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
    return
  end
  for i = 1, #uids do
    table.insert(self.searchList, uids[i])
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uids, function(profileList)
    self:GetProfileCallback(profileList)
  end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST, nil, true)
end
function logic_friend_search:social_search_role_req(condition, from)
  log(bWriteLog and "logic_friend_search:social_search_role_req")
  if not condition then
    return
  end
  if self:CheckSearchConditionChange(condition) then
    self.searchList = {}
  end
  self.lastFriendSearchCondition = condition
  local FriendSearchHandler = require("client.network.Protocol.FriendSearchHandler")
  log(bWriteLog and "logic_friend_search:social_search_role_req lastSearchUID = " .. self.lastSearchUID)
  FriendSearchHandler.send_social_search_role_req(condition, 20, self.lastSearchUID, from)
end
function logic_friend_search:proc_social_search_role_rsp(res, uidlist, unlimitFlag, recommendedData, lastUid)
  log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp: " .. res)
  log_tree("logic_friend_search:proc_social_search_role_rsp uidlist =", uidlist)
  self.bFromRecommand = true
  if res == "server_busy" then
    ShowNotice(120164)
    return
  end
  if unlimitFlag then
    self.bFriendLimitSearch = not unlimitFlag
  else
    self.bFriendLimitSearch = false
  end
  log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp unlimitFlag = " .. tostring(unlimitFlag))
  log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp lastUid = " .. tostring(lastUid))
  if lastUid == nil then
    if uidlist ~= nil and type(uidlist) == "table" and next(uidlist) then
      self.lastSearchUID = uidlist[#uidlist]
    else
      log_error("proc_social_search_role_rsp: uidlist is not a table, type: " .. type(uidlist))
    end
  else
    self.lastSearchUID = lastUid
  end
  log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp lastSearchUID = " .. self.lastSearchUID)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if res == NetErrorCode_NONE then
    self.searchList = {}
    self.recommendedDataList = {}
    if not uidlist or not next(uidlist) then
      log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp uidlist is nil with res is ok")
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
      return
    end
    log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp = " .. tostring(#uidlist))
    for i = 1, #uidlist do
      if not LogicFriend.IsMyFriend(uidlist[i]) then
        if recommendedData and recommendedData[uidlist[i]] then
          self.recommendedDataList[uidlist[i]] = recommendedData[uidlist[i]]
        end
        table.insert(self.searchList, uidlist[i])
      end
    end
    log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp #searchList = " .. tostring(#self.searchList))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidlist, function(profileList)
      self:GetProfileCallback(profileList)
    end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
    return
  end
  if res == "not_more_data" then
    if uidlist == nil or not next(uidlist) then
      self.searchList = {}
      self.recommendedDataList = {}
      log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp uidlist is nil with res is not_more_data")
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
      return
    end
    local newSearchList = {}
    local newRecommendedDataList = {}
    log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp #uidlist = " .. tostring(#uidlist))
    for i = 1, #uidlist do
      if not LogicFriend.IsMyFriend(uidlist[i]) then
        if recommendedData and recommendedData[uidlist[i]] then
          newRecommendedDataList[uidlist[i]] = recommendedData[uidlist[i]]
        end
        table.insert(newSearchList, uidlist[i])
      end
    end
    log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp #newSearchList = " .. tostring(#newSearchList))
    local map = {}
    for _, v in pairs(newSearchList) do
      map[v] = true
    end
    log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp #searchList = " .. tostring(#self.searchList))
    for i = 1, #self.searchList do
      if 20 <= #newSearchList then
        break
      end
      if not map[self.searchList[i]] and not LogicFriend.IsMyFriend(self.searchList[i]) then
        log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp insert cache uid to new data, uid = " .. tostring(self.searchList[i]))
        table.insert(newSearchList, self.searchList[i])
        if self.recommendedDataList and self.recommendedDataList[self.searchList[i]] then
          newRecommendedDataList[self.searchList[i]] = self.recommendedDataList[self.searchList[i]]
        end
      end
    end
    self.searchList = newSearchList
    self.recommendedDataList = newRecommendedDataList or {}
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidlist, function(profileList)
      self:GetProfileCallback(profileList)
    end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
    return
  end
  log(bWriteLog and "logic_friend_search:proc_social_search_role_rsp res is not_data")
  self.searchList = {}
  self.recommendedDataList = {}
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
end
function logic_friend_search:GetSearchList()
  return self.searchList
end
function logic_friend_search:RemoveSearchList(uid)
  for i, v in pairs(self.searchList) do
    if v == uid then
      table.remove(self.searchList, i)
      return true
    end
  end
  return false
end
function logic_friend_search:GetProfileCallback(profileList)
  log(bWriteLog and "logic_friend_search:GetProfileCallback")
  if not next(profileList) and not self.IsOpenGMTest then
    log(bWriteLog and "logic_friend_search:GetProfileCallback search empty")
    self.searchList = {}
    self.recommendedDataList = {}
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
    return
  end
  local newSearchList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for index = 1, #self.searchList do
    local profile_data = logic_profile:GetLocalProfile(self.searchList[index])
    if not profile_data or profile_data.migrate_status then
      log(bWriteLog and "logic_friend_search:GetProfileCallback profile is invalid with uid = " .. tostring(self.searchList[index]))
      if self.IsOpenGMTest then
        table.insert(newSearchList, self.searchList[index])
      end
    else
      table.insert(newSearchList, self.searchList[index])
    end
  end
  self.searchList = newSearchList
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INFO_UPDATE)
end
function logic_friend_search:GetRecommendedDataByUid(uid)
  if self.recommendedDataList == nil then
    log(bWriteLog and "logic_friend_search:GetRecommendedDataByUid. recommendedDataList is nil")
    return nil
  end
  local recommendedData = self.recommendedDataList[uid]
  if not recommendedData then
    log(bWriteLog and "logic_friend_search:GetRecommendedDataByUid recommendedData is nil")
    return nil
  end
  return recommendedData
end
function logic_friend_search:CheckSearchConditionChange(cond)
  if self.lastFriendSearchCondition == nil or not cond then
    return true
  end
  if not next(self.lastFriendSearchCondition) then
    if not next(cond) then
      return false
    else
      return true
    end
  end
  if not next(cond) then
    return true
  end
  local bIfUniform = cond.nation == self.lastFriendSearchCondition.nation and cond.segment == self.lastFriendSearchCondition.segment and cond.pre_server == self.lastFriendSearchCondition.pre_server and cond.play_date == self.lastFriendSearchCondition.play_date and cond.play_time == self.lastFriendSearchCondition.play_time and cond.language == self.lastFriendSearchCondition.language and cond.gender == self.lastFriendSearchCondition.gender
  return not bIfUniform
end
function logic_friend_search:IsFromRecommand()
  return self.bFromRecommand
end
function logic_friend_search:IsLimitSearch()
  return self.bFriendLimitSearch
end
function logic_friend_search:ResetSearchDataBeforeJump()
  log(bWriteLog and "logic_friend_search:ResetSearchDataBeforeJump")
  self.friendSearchDataBeforeJump.searchNameOrUID = nil
  self.friendSearchDataBeforeJump.searchList = nil
  self.friendSearchDataBeforeJump.nation = nil
  self.friendSearchDataBeforeJump.bFriendLimitSearch = false
  self.friendSearchDataBeforeJump.comboboxIndex = nil
  self.friendSearchDataBeforeJump.bSearchFromQRCode = false
end
function logic_friend_search:SaveSearchDataBeforeJump(searchNameOrUID, curSearchList, curNation, comboboxIndex, bSearchFromQRCode)
  log(bWriteLog and "logic_friend_search:SaveSearchDataBeforeJump")
  self.friendSearchDataBeforeJump.  self.friendSearchDataBeforeJump.searchList = curSearchList
  self.friendSearchDataBeforeJump.nation = curNation
  self.friendSearchDataBeforeJump.bFriendLimitSearch = self.bFriendLimitSearch
  self.friendSearchDataBeforeJump.  self.friendSearchDataBeforeJump.end
function logic_friend_search:GetNameOrUIDBeforeJump()
  return self.friendSearchDataBeforeJump.searchNameOrUID
end
function logic_friend_search:GetSearchListBeforeJump()
  return self.friendSearchDataBeforeJump.searchList
end
function logic_friend_search:GetSearchConditionBeforeJump()
  return self.friendSearchDataBeforeJump.nation, self.friendSearchDataBeforeJump.comboboxIndex
end
function logic_friend_search:GetLimitSearchFlagBeforeJump()
  return self.friendSearchDataBeforeJump.bFriendLimitSearch
end
function logic_friend_search:GetQRCodeFlagBeforeJump()
  return self.friendSearchDataBeforeJump.bSearchFromQRCode
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicFriendBlacklist = class(CModuleBase, nil, logic_friend_search)
return CLogicFriendBlacklist
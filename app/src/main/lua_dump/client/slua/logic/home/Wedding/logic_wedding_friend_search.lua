local logic_wedding_friend_search = {}
local C_ListNumPerPage = 20
local C_MaxPage = 3
function logic_wedding_friend_search:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEDDING_ACTIVITY, self.OnJumpWeddingActivityMainUI, self)
end
function logic_wedding_friend_search:OnJumpWeddingActivityMainUI(eventType, eventID, params)
  log(bWriteLog and "logic_wedding_friend_search:OnJumpWeddingActivityMainUI")
  UIManager.ShowUI(UIManager.UI_Config.Matchmaking_RightTab_UIBP, params)
end
function logic_wedding_friend_search:send_soulmate_corner_search_by_uid_name_req(name)
  self.lastFriendSearchCondition = nil
  local WeddingActivityHandler = require("client.network.Protocol.WeddingActivityHandler")
  WeddingActivityHandler.send_soulmate_corner_search_by_uid_name_req(name)
end
function logic_wedding_friend_search:proc_soulmate_corner_search_by_uid_name_rsp(err_code, name, results)
  self.bFriendLimitSearch = true
  self.searchList = {}
  if err_code == 20150029 then
    ShowNotice(990004)
    return
  end
  if not (err_code == 0 and results) or not next(results) then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
    return
  end
  for i = 1, #results do
    table.insert(self.searchList, results[i])
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(results, function(profileList)
    self:GetProfileCallback(profileList)
  end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST, nil, true)
end
function logic_wedding_friend_search:send_soulmate_corner_search_req(condition)
  log(bWriteLog and "logic_wedding_friend_search:send_soulmate_corner_search_req")
  if not condition then
    return
  end
  if not self.page or self.page >= C_MaxPage or self:CheckSearchConditionChange(condition) then
    local currentDisplayUIDList = self:GetSearchList()
    self.currentDisplayUIDMap = {}
    for _, uid in pairs(currentDisplayUIDList) do
      self.currentDisplayUIDMap[uid] = true
    end
    self.searchList = {}
    self.lastFriendSearchCondition = condition
  else
    self.page = self.page + 1
    local endIndex = self.page * C_ListNumPerPage
    if endIndex <= #self.searchList then
      log(bWriteLog and "logic_wedding_friend_search:send_soulmate_corner_search_req searchList cache is enough, page = " .. tostring(self.page) .. ", #self.searchList = " .. tostring(#self.searchList))
      local startIndex = (self.page - 1) * C_ListNumPerPage + 1
      local uidList = {}
      for i = startIndex, endIndex do
        if self.searchList[i] then
          table.insert(uidList, self.searchList[i])
        end
      end
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(uidList, function(profileList)
        self:GetProfileCallback(profileList)
      end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
      return
    end
  end
  local WeddingActivityHandler = require("client.network.Protocol.WeddingActivityHandler")
  WeddingActivityHandler.send_soulmate_corner_search_req(condition)
end
function logic_wedding_friend_search:proc_soulmate_corner_search_rsp(err_code, is_publish, is_limit, results)
  log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_search_rsp")
  self.bIsPublished = is_publish
  EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_GET_PUBLISH_STATE)
  if err_code == 20150028 then
    ShowNotice(120164)
    return
  end
  if is_limit then
    self.bFriendLimitSearch = not is_limit
  else
    self.bFriendLimitSearch = false
  end
  if err_code == 0 then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    self.searchList = {}
    self.page = 1
    if not results or not next(results) then
      log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_search_rsp results is nil with err_code = 0")
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
      return
    end
    if #results > C_ListNumPerPage then
      local filterUIDList = {}
      local filterUIDMap = {}
      for _, uid in pairs(results) do
        if not self.currentDisplayUIDMap[uid] then
          table.insert(filterUIDList, uid)
          filterUIDMap[uid] = true
        end
      end
      if #filterUIDList < C_ListNumPerPage then
        for _, uid in pairs(results) do
          if not filterUIDMap[uid] then
            table.insert(filterUIDList, uid)
            if #filterUIDList >= C_ListNumPerPage then
              break
            end
          end
        end
      end
      results = filterUIDList
    end
    log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_search_rsp = " .. tostring(#results))
    for i = 1, #results do
      if not LogicFriend.IsMyFriend(results[i]) then
        table.insert(self.searchList, results[i])
      end
    end
    log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_search_rsp #searchList = " .. tostring(#self.searchList))
    local uidList = {}
    for i = 1, C_ListNumPerPage do
      if results[i] then
        table.insert(uidList, results[i])
      end
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, function(profileList)
      self:GetProfileCallback(profileList)
    end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
    return
  end
  ShowNotice(err_code)
  log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_search_rsp err_code ~= 0")
  self.searchList = {}
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
end
function logic_wedding_friend_search:proc_soulmate_corner_publish_rsp()
  log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_publish_rsp")
  self.bIsPublished = true
  EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_UPDATE_PUBLISH_STATE)
end
function logic_wedding_friend_search:proc_soulmate_corner_unpublish_rsp()
  log(bWriteLog and "logic_wedding_friend_search:proc_soulmate_corner_unpublish_rsp")
  self.bIsPublished = false
  EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_UPDATE_PUBLISH_STATE)
end
function logic_wedding_friend_search:GetPublishState()
  return self.bIsPublished
end
function logic_wedding_friend_search:GetSearchList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local list = {}
  self.page = self.page or 1
  log(bWriteLog and "logic_wedding_friend_search:GetSearchList page = " .. tostring(self.page))
  local startIndex = (self.page - 1) * C_ListNumPerPage + 1
  local endIndex = self.page * C_ListNumPerPage
  for i = startIndex, endIndex do
    if not self.searchList[i] then
      log(bWriteLog and "logic_wedding_friend_search:GetSearchList searchList is nil with i = " .. tostring(i))
      break
    end
    local profile_data = logic_profile:GetLocalProfile(self.searchList[i])
    if not self.IsOpenGMTest and (not profile_data or profile_data.migrate_status) then
      log(bWriteLog and "logic_wedding_friend_search:GetSearchList profile is invalid with uid = " .. tostring(self.searchList[i]))
    else
      table.insert(list, self.searchList[i])
    end
  end
  return list
end
function logic_wedding_friend_search:RemoveSearchList(uid)
  for i, v in pairs(self.searchList) do
    if v == uid then
      table.remove(self.searchList, i)
      return true
    end
  end
end
function logic_wedding_friend_search:GetProfileCallback(profileList)
  log(bWriteLog and "logic_wedding_friend_search:GetProfileCallback")
  if not next(profileList) and not self.IsOpenGMTest then
    log(bWriteLog and "logic_wedding_friend_search:GetProfileCallback search empty")
    self.searchList = {}
    self.recommendedDataList = {}
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_FRIEND_SEARCH_FAILED)
    return
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INFO_UPDATE)
end
local class = require("class")
local logic_friend_search = require("client.slua.logic.friend.logic_friend_search")
local Clogic_wedding_friend_search = class(logic_friend_search, nil, logic_wedding_friend_search)
return Clogic_wedding_friend_search
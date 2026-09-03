local CorpsSuggestionSystem = {
  FriendUIDSet = {},
  SuggestionList = {},
  PriorList = {},
  ApplicationList = {},
  ApplicationTempIDList = {},
  SearchList = {},
  InvitedCorpsArray = {},
  hasNewIvitedCorps = false,
  isInListTab = true,
  suggestionType = 1,
  searchIndex = 1,
  SearchIDList = {},
  eachSearchNum = 10,
  SearchedIndexList = {},
  RetryIndex = 0,
  SearchedIDList = {},
  RefreshIndexList = {}
}
function CorpsSuggestionSystem.Init()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = LogicFriend.GetAllFriendList()
  for k, v in pairs(friendIDList) do
    CorpsSuggestionSystem.FriendUIDSet[v] = true
  end
end
function CorpsSuggestionSystem.Release()
  CorpsSuggestionSystem.SuggestionList = {}
  CorpsSuggestionSystem.PriorList = {}
  CorpsSuggestionSystem.InvitedCorpsArray = {}
end
function CorpsSuggestionSystem.HandleErrorCode(msg)
  if msg == 411013 then
    CorpsSuggestionSystem.ApplicationList = {}
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYJOINLIST)
    return
  elseif msg == 411024 then
    CorpsSuggestionSystem.SearchList = {}
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIND_CORPS_BY_NAME)
    return
  elseif msg == 411012 then
    ShowNotice(msg)
  end
  ShowNotice(msg)
end
function CorpsSuggestionSystem.FilterSuggestionList(need_approval, accord_requirement)
  local ret = {}
  local segment = math.max(DataMgr.roleData.segment.solo, DataMgr.roleData.segment.double, DataMgr.roleData.segment.team)
  local IsCorpsAccordRequirement = function(corps_item)
    return DataMgr.roleData.level >= corps_item.join_level and segment >= corps_item.join_segment
  end
  if CorpsSuggestionSystem.SuggestionList ~= nil then
    for k, v in pairs(CorpsSuggestionSystem.SuggestionList) do
      local needAdd = true
      if need_approval == false and v.need_approval == true then
        needAdd = false
      elseif accord_requirement == true then
        local acc = IsCorpsAccordRequirement(v)
        if not acc then
          needAdd = false
        end
      end
      if needAdd then
        ret[k] = v
      end
    end
  end
  return ret
end
function CorpsSuggestionSystem.UpdateTempApplyIDList(corps_id)
  table.insert(CorpsSuggestionSystem.ApplicationTempIDList, tostring(corps_id))
  local corps_suggestion = UIManager.GetUI(UIManager.UI_Config.corps_suggestion)
  if corps_suggestion then
    corps_suggestion:RefreshSelectApplyState()
  end
end
function CorpsSuggestionSystem.CompareItem(a, b)
  local prior_a = 100
  local prior_b = 100
  if CorpsSuggestionSystem.PriorList ~= nil then
    for k, v in pairs(CorpsSuggestionSystem.PriorList) do
      if tonumber(a.corps_id) == v then
        prior_a = k
      end
      if tonumber(b.corps_id) == v then
        prior_b = k
      end
    end
  end
  if (a.friend_num > 0 or b.friend_num > 0) and b.friend_num ~= a.friend_num then
    return b.friend_num < a.friend_num
  end
  if prior_a < 100 or prior_b < 100 then
    return prior_a < prior_b
  end
  if a.city == DataMgr.roleData.nation or b.city == DataMgr.roleData.nation then
    if a.city == DataMgr.roleData.nation and b.city ~= DataMgr.roleData.nation then
      return true
    elseif a.city ~= DataMgr.roleData.nation and b.city == DataMgr.roleData.nation then
      return false
    end
  end
  if 0 < a.activeness or 0 < b.activeness then
    return b.activeness < a.activeness
  end
  return tonumber(b.corps_id) < tonumber(a.corps_id)
end
function CorpsSuggestionSystem.SendReqSuggestionList(need_approval, accord_requirement, is_active_period_match, check_energy_types)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = LogicFriend.GetAllFriendList()
  local TableUtil = require("common.table_util")
  friendIDList = TableUtil.TableSlice(friendIDList, 1, 200)
  local energy_types = {}
  for energy_type, enable in pairs(check_energy_types) do
    if enable then
      energy_types[energy_type] = 1
    end
  end
  log_tree("CorpsSuggestionSystem.SendReqSuggestionList ", {
    need_approval = need_approval,
    accord_requirement = accord_requirement,
    friendIDList = friendIDList,
    is_active_period_match = is_active_period_match,
      })
  local frd_corps_ids = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, id in ipairs(friendIDList) do
    local profile = logic_profile:GetLocalProfile(id)
    if profile.corps_id and profile.corps_id ~= 0 then
      TableUtil.UniqueInsert(frd_corps_ids, profile.corps_id)
    end
  end
  log_tree("frd_corps_ids", frd_corps_ids)
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_suggestion_list_req_v2(frd_corps_ids, need_approval, accord_requirement, is_active_period_match, energy_types)
end
local GetFriendNumCount = function(memIDlist, friendList)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = friendList or LogicFriend.GetAllFriendList()
  local count = 0
  for k, v in ipairs(memIDlist) do
    for k1, v1 in ipairs(friendIDList) do
      if v == v1 then
        count = count + 1
        break
      end
    end
  end
  return count
end
function CorpsSuggestionSystem.SendReqApplicationList(isInListTab)
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_apply_join_list_req()
  CorpsSuggestionSystem.end
function CorpsSuggestionSystem.SendReqSearch(corps_name)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = LogicFriend.GetAllFriendList()
  local TableUtil = require("common.table_util")
  friendIDList = TableUtil.TableSlice(friendIDList, 1, 200)
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_fuzzy_query_corps_by_name_req(corps_name, friendIDList, 0)
end
function CorpsSuggestionSystem.OnGetSearch(fuzzy_name, exact_corps_id, fuzzy_match_corps)
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  CorpsSuggestionSystem.suggestionType = CorpsMacro.SearchType.Fuzzy
  CorpsSuggestionSystem.searchIndex = 1
  CorpsSuggestionSystem.SuggestionList = {}
  CorpsSuggestionSystem.PriorList = {}
  CorpsSuggestionSystem.SearchedIndexList = {}
  CorpsSuggestionSystem.RetryIndex = 0
  CorpsSuggestionSystem.RefreshIndexList = {}
  CorpsSuggestionSystem.CorpsListSort(fuzzy_name, exact_corps_id, fuzzy_match_corps)
  local idList = CorpsSuggestionSystem.GetNeedSearchList(1, CorpsSuggestionSystem.eachSearchNum - 1)
  CorpsSuggestionSystem.SearchedIDList = idList
  local client_data = {}
  client_data.index = 1
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_batch_get_bin_corps_summary_req(CorpsMacro.SearchType.Fuzzy, idList, client_data)
end
function CorpsSuggestionSystem.GetCorpsSummary(res, opt_type, corps_info, client_data)
  if res == NetErrorCode_NONE then
    local corps_info_number = 0
    for k, v in pairs(corps_info) do
      corps_info_number = corps_info_number + 1
    end
    CorpsSuggestionSystem.searchIndex = CorpsSuggestionSystem.searchIndex + corps_info_number
    local idList = CorpsSuggestionSystem.SearchIDList
    local corps_info_talbe = {}
    for _, v in pairs(idList) do
      corps_info_talbe[v] = corps_info[v]
    end
    CorpsSuggestionSystem.corps_search_list_rsp(res, corps_info)
  elseif res ~= nil and res ~= 411040 then
    ShowNotice(res)
  end
end
function CorpsSuggestionSystem.corps_suggestion_list_rsp(msg, suggestion_list, rsp)
  log_tree("CorpsSuggestionSystem.corps_suggestion_list_rsp " .. tostring(msg), suggestion_list)
  if msg ~= NetErrorCode_NONE then
    CorpsSuggestionSystem.HandleErrorCode(msg)
    return
  end
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  CorpsSuggestionSystem.suggestionType = CorpsMacro.SearchType.Normal
  CorpsSuggestionSystem.SuggestionList = {}
  if LobbySystem.roleData.is_low_corps then
    for k, v in pairs(suggestion_list) do
      if v.corps_id ~= DataMgr.corpsInfo.id then
        CorpsSuggestionSystem.SuggestionList[k] = v
      end
    end
  else
    for k, v in pairs(suggestion_list) do
      CorpsSuggestionSystem.SuggestionList[k] = v
    end
  end
  CorpsSuggestionSystem.PriorList = rsp
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST)
end
function CorpsSuggestionSystem.corps_search_list_rsp(err_code, corps_summary_infos)
  log_tree("CorpsSuggestionSystem.corps_search_list_rsp " .. tostring(err_code), corps_summary_infos)
  if err_code ~= NetErrorCode_NONE then
    CorpsSuggestionSystem.HandleErrorCode(err_code)
    return
  end
  for k, v in pairs(corps_summary_infos) do
    CorpsSuggestionSystem.SuggestionList[k] = v
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SEARCHLIST)
end
function CorpsSuggestionSystem.GetSuggestListNum()
  local num = 0
  for k, v in pairs(CorpsSuggestionSystem.SuggestionList) do
    num = num + 1
  end
  return num
end
function CorpsSuggestionSystem.SearchIDListNum()
  local num = 0
  for k, v in pairs(CorpsSuggestionSystem.SearchIDList) do
    num = num + 1
  end
  return num
end
function CorpsSuggestionSystem.CorpsListSort(fuzzy_name, exact_corps_id, fuzzy_match_corps)
  CorpsSuggestionSystem.  if exact_corps_id == nil and fuzzy_match_corps == nil then
    CorpsSuggestionSystem.SuggestionList = nil
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SEARCHLIST)
    return
  end
  if exact_corps_id and 0 < exact_corps_id and fuzzy_match_corps ~= nil then
    for idx, info in pairs(fuzzy_match_corps) do
      if info.corps_id == exact_corps_id then
        table.remove(fuzzy_match_corps, idx)
      end
    end
  end
  local idList = {}
  local TableUtil = require("common.table_util")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = LogicFriend.GetAllFriendList()
  friendIDList = TableUtil.TableSlice(friendIDList, 1, 200)
  local frd_corps_ids = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, id in ipairs(friendIDList) do
    local profile = logic_profile:GetLocalProfile(id)
    if profile.corps_id and profile.corps_id ~= 0 then
      TableUtil.UniqueInsert(frd_corps_ids, profile.corps_id)
    end
  end
  if fuzzy_match_corps ~= nil then
    for k, v in pairs(fuzzy_match_corps) do
      v.hasFrd = false
      for _, frd_corps_id in pairs(frd_corps_ids) do
        if v.corps_id == frd_corps_id then
          v.hasFrd = true
        end
      end
    end
    local comp = function(corp1, corp2)
      if corp1 and corp2 and string.find(corp1.corps_name, fuzzy_name) and string.find(corp2.corps_name, fuzzy_name) then
        if not corp1.hasFrd and corp2.hasFrd then
          return false
        elseif corp1.hasFrd and not corp2.hasFrd then
          return true
        elseif corp1.corps_nation ~= DataMgr.roleData.nation and corp2.corps_nation == DataMgr.roleData.nation then
          return false
        elseif corp1.corps_nation == DataMgr.roleData.nation and corp2.corps_nation ~= DataMgr.roleData.nation then
          return true
        elseif corp1.active_value < corp2.active_value then
          return false
        elseif corp1.active_value > corp2.active_value then
          return true
        elseif string.find(corp1.corps_name, fuzzy_name) > string.find(corp2.corps_name, fuzzy_name) then
          return false
        elseif string.find(corp1.corps_name, fuzzy_name) < string.find(corp2.corps_name, fuzzy_name) then
          return true
        elseif #corp1.corps_name > #corp2.corps_name then
          return false
        elseif #corp1.corps_name < #corp2.corps_name then
          return true
        elseif corp1.corps_name < corp2.corps_name then
          return false
        elseif corp1.corps_name > corp2.corps_name then
          return true
        end
      end
      return false
    end
    table.sort(fuzzy_match_corps, comp)
    for _, v in pairs(fuzzy_match_corps) do
      table.insert(idList, v.corps_id)
    end
  end
  if exact_corps_id and 0 < exact_corps_id then
    table.insert(idList, 1, exact_corps_id)
  end
  CorpsSuggestionSystem.SearchIDList = idList
end
function CorpsSuggestionSystem.GetNeedSearchList(index, number)
  local NeedSearchTable = {}
  if index > #CorpsSuggestionSystem.SearchIDList then
    return NeedSearchTable
  end
  for i = index, index + number do
    if index <= #CorpsSuggestionSystem.SearchIDList then
      table.insert(NeedSearchTable, CorpsSuggestionSystem.SearchIDList[i])
    else
      break
    end
  end
  return NeedSearchTable
end
function CorpsSuggestionSystem.UpdateListGender(tar_list, call_back)
  local uidList = {}
  for k, v in pairs(tar_list) do
    table.insert(uidList, tonumber(tar_list[k].commander_id))
  end
  local getProfileCallback = function(profileList)
    log_tree("suggestion_list gender", profileList)
    for k, v in pairs(profileList) do
      for _, info in pairs(tar_list) do
        if tonumber(info.commander_id) == tonumber(v.uid) then
          info.commander_gender = v.sex
        end
      end
    end
    if call_back ~= nil then
      call_back()
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, getProfileCallback, Enum_PROFILE_REPORT_CFG.CORPS_SUGES)
end
function CorpsSuggestionSystem.CreateSuggestItem(svrInfo)
  local corpsInfo = {}
  CorpsSuggestionSystem.InitSuggestItem(corpsInfo, svrInfo)
  return corpsInfo
end
function CorpsSuggestionSystem.InitSuggestItem(corpsInfo, svrInfo, friendIDList)
  corpsInfo.commander_id = tostring(svrInfo.commander)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  corpsInfo.commander_name = logic_profile:GetNickName(svrInfo.commander) or svrInfo.commander_name
  corpsInfo.level = svrInfo.level
  corpsInfo.icon = svrInfo.icon
  corpsInfo.corps_id = tostring(svrInfo.corps_id)
  corpsInfo.name = svrInfo.name or ""
  corpsInfo.friend_num = GetFriendNumCount(svrInfo.members, friendIDList)
  corpsInfo.city = svrInfo.city
  corpsInfo.province = svrInfo.province
  corpsInfo.activeness = svrInfo.activeness
  corpsInfo.activeness_tag = false
  corpsInfo.join_segment = svrInfo.join_segment
  corpsInfo.join_level = svrInfo.join_level
  corpsInfo.need_approval = svrInfo.need_approval
  corpsInfo.announcement = svrInfo.announcement or ""
  corpsInfo.icon_text = svrInfo.icon_text or ""
  corpsInfo.icon_text_colour = svrInfo.icon_text_colour or 0
  corpsInfo.active_type = svrInfo.active_type
  corpsInfo.MemberList = {}
  for k, v in ipairs(svrInfo.members) do
    table.insert(corpsInfo.MemberList, tostring(v))
  end
  corpsInfo.apply_index = svrInfo.index or 0
end
function CorpsSuggestionSystem.corps_apply_join_list_rsp(msg, apply_list)
  if msg ~= NetErrorCode_NONE then
    if CorpsSuggestionSystem.isInListTab then
      CorpsSuggestionSystem.HandleErrorCode(msg)
    end
    return
  end
  CorpsSuggestionSystem.ApplicationList = {}
  CorpsSuggestionSystem.ApplicationTempIDList = {}
  for k, v in pairs(apply_list) do
    local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(v)
    table.insert(CorpsSuggestionSystem.ApplicationList, corpsInfo)
    table.insert(CorpsSuggestionSystem.ApplicationTempIDList, tostring(v.corps_id))
  end
  table.sort(CorpsSuggestionSystem.ApplicationList, function(a, b)
    return a.apply_index < b.apply_index
  end)
  local afterSetGenderCallback = function()
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_APPLYJOINLIST)
  end
  CorpsSuggestionSystem.UpdateListGender(CorpsSuggestionSystem.ApplicationList, afterSetGenderCallback)
end
function CorpsSuggestionSystem.find_corps_by_name_rsp(res, corps_name, corps_info)
  if res ~= NetErrorCode_NONE then
    CorpsSuggestionSystem.HandleErrorCode(res)
    return
  end
  if corps_info ~= nil then
    CorpsSuggestionSystem.SearchList = {}
    local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(corps_info)
    table.insert(CorpsSuggestionSystem.SearchList, corpsInfo)
    local afterSetGenderCallback = function()
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIND_CORPS_BY_NAME)
    end
    CorpsSuggestionSystem.UpdateListGender(CorpsSuggestionSystem.SearchList, afterSetGenderCallback)
  end
end
function CorpsSuggestionSystem.batch_get_bin_corps_summary_rsp(res, opt_type, bin_corps_list, client_data)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsMacro = require("client.slua.logic.corps.corps_macro")
  if res == 0 then
    if opt_type == CorpsMacro.SearchType.Normal then
      CorpsMgr.batch_get_corps_summary_rsp(NetErrorCode_NONE, opt_type, bin_corps_list, client_data)
    elseif opt_type == CorpsMacro.SearchType.Fuzzy then
      CorpsSuggestionSystem.GetCorpsSummary(NetErrorCode_NONE, opt_type, bin_corps_list, client_data)
    end
  elseif res == 411040 and type(CorpsSuggestionSystem.RetryIndex) == "number" and type(client_data.index) == "number" and CorpsSuggestionSystem.RetryIndex >= client_data.index then
    local time_ticker = require("common.time_ticker")
    local funcCall = function()
      CorpsSuggestionSystem.RetryIndex = client_data.index
      CorpsHandler.send_batch_get_bin_corps_summary_req(CorpsMacro.SearchType.Fuzzy, CorpsSuggestionSystem.SearchedIDList, client_data)
    end
    local timer
    timer = time_ticker.AddTimerOnce(client_data.left_ms / 1000, function()
      funcCall()
      if timer ~= nil then
        time_ticker.RemoveTimer(timer)
        timer = nil
      end
    end)
  end
end
function CorpsSuggestionSystem.InitInvitedCorpsArray(invited_corps_list)
  log(bWriteLog and "CorpsSuggestionSystem.InitInvitedCorpsArray #invited_corps_list " .. #invited_corps_list)
  CorpsSuggestionSystem.InvitedCorpsArray = {}
  for i, v in ipairs(invited_corps_list) do
    table.insert(CorpsSuggestionSystem.InvitedCorpsArray, {
      invite_uid = v.invite_uid,
      invite_name = v.invite_name,
      invite_status = v.status,
      corps_id = tostring(v.corps_id),
      time = v.time or 0
    })
  end
  CorpsSuggestionSystem.UpdateInvitedCorpsRedDot()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INVITED_CORPS_LIST)
end
function CorpsSuggestionSystem.UpdateInvitedCorpsRedDot()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local hasNew = false
  for i, v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
    if v.invite_status == 0 then
      hasNew = true
      break
    end
  end
  CorpsSuggestionSystem.hasNewIvitedCorps = hasNew
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.invite)
  log(bWriteLog and "CorpsSuggestionSystem.UpdateInvitedCorpsRedDot CorpsSuggestionSystem.hasNewIvitedCorps " .. tostring(CorpsSuggestionSystem.hasNewIvitedCorps))
end
function CorpsSuggestionSystem.GetInvitedCorpsDataByID(corps_id)
  corps_id = tostring(corps_id)
  for i, v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
    if v.corps_id == corps_id then
      return v
    end
  end
  return nil
end
function CorpsSuggestionSystem.get_corps_invitee_list_req()
  log(bWriteLog and "CorpsSuggestionSystem.get_corps_invitee_list_req")
  local CorpsGiftExchangeHandler = require("client.network.Protocol.CorpsGiftExchangeHandler")
  CorpsGiftExchangeHandler.send_get_corps_invitee_list_req()
end
function CorpsSuggestionSystem.sync_corps_invitee_list(res, corps_list)
  log(bWriteLog and string.format("sync_corps_invitee_list, res:%s", res))
  log_tree(bWriteLog and "sync_corps_invitee_list corps_list", corps_list)
  if res == NetErrorCode_NONE then
    CorpsSuggestionSystem.InitInvitedCorpsArray(corps_list)
  end
end
function CorpsSuggestionSystem.CurrentInvitedCorpsSummaryReq()
  local idList = {}
  for i, v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
    table.insert(idList, tonumber(v.corps_id))
  end
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  CorpsMgr.batch_get_corps_summary_req(CorpsSuggestionSystem.UpdateInvitedCorpsSummary, idList)
end
function CorpsSuggestionSystem.UpdateInvitedCorpsSummary(invited_corps_summary_list)
  log(bWriteLog and "CorpsSuggestionSystem.UpdateInvitedCorpsSummary")
  if invited_corps_summary_list then
    log(bWriteLog and "CorpsSuggestionSystem.UpdateInvitedCorpsSummary invited_corps_summary_list")
    local ValidInvitedCorps = {}
    for i, invitedCorps in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
      for k, corps_summary in pairs(invited_corps_summary_list) do
        if tonumber(invitedCorps.corps_id) == tonumber(corps_summary.corps_id) then
          CorpsSuggestionSystem.InitSuggestItem(invitedCorps, corps_summary)
          table.insert(ValidInvitedCorps, invitedCorps)
        end
      end
    end
    CorpsSuggestionSystem.InvitedCorpsArray = ValidInvitedCorps
  else
    CorpsSuggestionSystem.InvitedCorpsArray = {}
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INVITED_CORPS_SUMMARY)
end
function CorpsSuggestionSystem.change_invitee_status_req(index)
  local v = CorpsSuggestionSystem.InvitedCorpsArray[index]
  if v ~= nil then
    if v.invite_status == 0 then
      local CorpsHander = require("client.network.Protocol.CorpsHandler")
      CorpsHander.send_change_invitee_status_req(index)
    end
    v.invite_status = 1
    CorpsSuggestionSystem.UpdateInvitedCorpsRedDot()
  end
end
function CorpsSuggestionSystem.change_invitee_status_rsp(res, index)
end
function CorpsSuggestionSystem.GetInvitedCorpsKvpByID(corps_id)
  corps_id = tostring(corps_id)
  for i, v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
    if v.corps_id == corps_id then
      return i, v
    end
  end
  return 0, nil
end
function CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
  corps_id = tostring(corps_id)
  local isRemoved = false
  for i = #CorpsSuggestionSystem.InvitedCorpsArray, 1, -1 do
    local info = CorpsSuggestionSystem.InvitedCorpsArray[i]
    if info.corps_id == corps_id then
      table.remove(CorpsSuggestionSystem.InvitedCorpsArray, i)
      isRemoved = true
    end
  end
  if not isRemoved then
    log(bWriteLog and "CorpsSuggestionSystem.RemoveInvitedCorpsByID remove failed : id " .. tostring(corps_id))
  end
end
function CorpsSuggestionSystem.easy_apply_join_corps_req()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_easy_apply_join_corps_req()
end
function CorpsSuggestionSystem.easy_apply_join_corps_rsp(res, join_time, aoto_join_corpsid)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if res == NetErrorCode_NONE then
    if aoto_join_corpsid ~= nil then
      CorpsMgr.InitID(aoto_join_corpsid)
      local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
      logic_corps_tab_mgr.OpenCorpsUIWithForceReq()
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      logic_chat_main.CloseChatWin()
      ShowNotice(410031)
    else
      ShowNotice(410079)
    end
  elseif res == 411039 then
    local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
    local msg = CorpsMemberSystem.GetRemainTimeStr(res, join_time)
    ShowNotice(msg)
  elseif res == 411038 then
    CorpsMgr.ShowCorpsLimitError()
  else
    ShowNotice(res)
  end
end
return CorpsSuggestionSystem
local ChatMenuSystem = {
  CacheCorpsSummary = {},
  EShowLocationType = {
    Chat = 1,
    Friend = 2,
    Teammate = 3,
    TeamPlatform = 4,
    TPlanTeamPlatform = 5,
    PlanZMember = 6,
    ReturnTaskRecall = 7,
    FriendApply = 8,
    IntimacyList = 9,
    LuckyStar = 9,
    Assembly = 10,
    UgcComment = 11,
    PlanPHMessageBoard = 12,
    PlanPHPigeon = 13,
    PlanPHDrawing = 14,
    PlanPHPlayerList = 15,
    SocialislandPlayerInteract = 16,
    PlanPHPlayerInteract = 17,
    UgcCollectionList = 18,
    PlanPHCarParking = 19,
    UGCPlayHallRoom = 20,
    MainCity = 21,
    ChatPlayerRecommandSidebar = 22
  },
  ReqKey = "",
  CacheCropsCardSummary = {}
}
function ChatMenuSystem.get_corps_summary_req(corps_id, uid)
  log(bWriteLog and "ChatMenuSystem.get_corps_summary_req corps_id:" .. tostring(corps_id) .. ",uid:" .. tostring(uid))
  if corps_id ~= nil then
    local key = "corps_id:" .. tostring(corps_id) .. ",uid:" .. tostring(uid)
    ChatMenuSystem.ReqKey = key
    local CorpsSummary = ChatMenuSystem.CacheCorpsSummary[key]
    if CorpsSummary then
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_SUMMARY, CorpsSummary)
      ChatMenuSystem.ReqKey = ""
      return
    end
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_summary_req(tonumber(corps_id), tonumber(uid), nil)
  end
end
function ChatMenuSystem.get_corps_summary_rsp(res, corps_id, corps_summary, req_type)
  log(bWriteLog and "ChatMenuSystem.get_corps_summary_rsp:" .. tostring(res) .. ",corps_id:" .. tostring(corps_id))
  if res == NetErrorCode_NONE and corps_summary ~= nil and string.find(ChatMenuSystem.ReqKey, corps_id) then
    corps_summary.    ChatMenuSystem.CacheCorpsSummary[ChatMenuSystem.ReqKey] = corps_summary
  end
  ChatMenuSystem.ReqKey = ""
end
function ChatMenuSystem.GetCorpsSummaryIcon(corps_summary)
  local str_icon_path = ""
  if corps_summary and corps_summary.icon ~= nil and corps_summary.icon > 0 then
    local corpIDConf = CDataTable.GetTableData("CorpsBadge", tonumber(corps_summary.icon))
    if corpIDConf ~= nil then
      str_icon_path = corpIDConf.IconPath
    end
  end
  return str_icon_path
end
function ChatMenuSystem.GetCorpsName(corp_alias_id, corps_name)
  local corpsAliasName = ""
  local corpsAliasCfg = CDataTable.GetTableData("corps_alias_table", tostring(corp_alias_id))
  if corpsAliasCfg then
    if corpsAliasCfg.Default == 1 then
      corpsAliasName = corps_name
    else
      corpsAliasName = string.format(corpsAliasCfg.CorpsAliasNameSmall, corps_name)
    end
  end
  return corpsAliasName
end
function ChatMenuSystem.GetProfileList(uid, bRequestRank)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if bRequestRank and (not profile or not profile.rankdata) then
    if profile then
      log(bWriteLog and "ChatMenuSystem.GetProfileList request rank has profile")
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_MENU_PROFILE, uid)
    end
    log(bWriteLog and "ChatMenuSystem.GetProfileList request rank uid = " .. tostring(uid))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.CHAT_MENU, {uid}, function(listInfo)
      log(bWriteLog and "ChatMenuSystem.GetProfileList get rank profile")
      if listInfo and listInfo[1] then
        EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_MENU_PROFILE, uid)
      end
    end)
    return
  end
  if profile then
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_MENU_PROFILE, uid)
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
      local _, profile_info = next(list)
      if profile_info then
        EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_MENU_PROFILE, uid)
      end
    end, Enum_PROFILE_REPORT_CFG.CHAT_MENU)
  end
end
function ChatMenuSystem.Handle_LogOut()
  ChatMenuSystem.CacheCorpsSummary = {}
end
function ChatMenuSystem.on_report_req(uid, name, content, voice, origin_chat_type, CliSourceId)
  local fmtMsg = LocUtil.GetLocalizeResStr(106069)
  local str = string.format(fmtMsg, name)
  log(bWriteLog and "ChatMenuSystem.on_report_req uid : " .. tostring(uid) .. ", name : " .. tostring(name) .. ", content : " .. tostring(content) .. ", voice : " .. tostring(voice) .. ", origin_chat_type : " .. tostring(origin_chat_type) .. ", CliSourceId : " .. tostring(CliSourceId))
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  local temp = {
    chatUID = uid,
    chatName = name,
    chatContent = content,
    isVoice = voice,
    ChatType = origin_chat_type,
      }
  LogicComplaint.ShowComplaint(LogicComplaint.EComplaintFrom.Chat, temp)
end
function ChatMenuSystem.on_report_rsp(res)
  log(bWriteLog and "on_report_rsp")
  if res == 510001 then
    ShowNotice(LocUtil.GetLocalizeResStr(4715))
  else
    ShowNotice(LocUtil.GetLocalizeResStr(97000024))
  end
end
function ChatMenuSystem.GetCorpsCardSummary(corps_id)
  corps_id = tonumber(corps_id)
  if corps_id then
    return ChatMenuSystem.CacheCorpsSummary[corps_id]
  else
    return nil
  end
end
function ChatMenuSystem.AddCorpsCardSummary(corps_id, corpsInfo)
  corps_id = tonumber(corps_id)
  if corps_id and not ChatMenuSystem.CacheCorpsSummary[corps_id] then
    ChatMenuSystem.CacheCorpsSummary[corps_id] = corpsInfo
  end
end
function ChatMenuSystem.ClearCorpsCardSummary()
  ChatMenuSystem.CacheCorpsSummary = {}
end
return ChatMenuSystem
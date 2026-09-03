local RoleInfoCorpsSystem = {
  corps_id = nil,
  corp_alias_id = nil,
  season_high_active_uids = {},
  corps_summary = nil,
  b_CanJoin = false,
  MyCorpsID = "",
  RoleInfoCorpsData = {
    str_corps_id = "",
    str_city = "",
    n_activeness = 0,
    n_level = 0,
    n_leader = 0,
    n_icon = 0,
    n_join_level = 0,
    str_announcement = "",
    n_member_num = 0,
    n_member_max = 0,
    n_join_segment = 0,
    str_name = "",
    n_position = 0,
    b_IsOwnApply = false,
    str_icon_text = "",
    n_icon_text_colour = 0
  },
  avatarInfoMap = {},
  RoleInfoCorpsAvatar = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID = 1,
    LastOnlineTimeStr = ""
  },
  CorpsInfo = {
    str_corps_id = "",
    str_city = "",
    n_activeness = 0,
    n_level = 0,
    n_leader = 0,
    n_icon = 0,
    str_icon_path = "",
    n_join_level = 0,
    str_announcement = "",
    n_member_num = 0,
    n_member_max = 0,
    n_join_segment = 0,
    str_name = "",
    n_position = 0,
    b_IsOwnApply = false,
    b_IsInvited = false,
    str_icon_text = "",
    n_icon_text_colour = 0,
    corpsAliasName = ""
  }
}
function RoleInfoCorpsSystem.ShowUI()
  UIManager.ShowUI(UIManager.UI_Config.CorpsInvitation_New_UIBP_2, RoleInfoCorpsSystem.corps_summary)
end
function RoleInfoCorpsSystem.Open(corps_id, uid, corp_alias_id)
  RoleInfoCorpsSystem.RefreshCorpsSummary(corps_id)
  RoleInfoCorpsSystem.Init()
end
function RoleInfoCorpsSystem.SetCanJoin(can_join)
  RoleInfoCorpsSystem.b_CanJoin = can_join
end
function RoleInfoCorpsSystem.SetCorpsInfo(corpsInfo, corps_summary)
  log_tree("SetCorpsInfo", {corpsInfo = corpsInfo, corps_summary = corps_summary})
  local RoleInfoCorpsData = RoleInfoCorpsSystem.RoleInfoCorpsData
  for k, v in pairs(corpsInfo) do
    RoleInfoCorpsData[k] = v
  end
  RoleInfoCorpsSystem.season_high_active_uids = corps_summary.season_high_active_uids or {}
  RoleInfoCorpsSystem.MyCorpsID = "0"
  if DataMgr.corpsInfo.id ~= nil then
    RoleInfoCorpsSystem.MyCorpsID = tostring(DataMgr.corpsInfo.id)
  end
  RoleInfoCorpsSystem.end
function RoleInfoCorpsSystem.GetAvatarInfo()
  local uids = {
    RoleInfoCorpsSystem.RoleInfoCorpsData.n_leader
  }
  for _, v in ipairs(RoleInfoCorpsSystem.season_high_active_uids) do
    table.insert(uids, v.uid)
  end
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  CorpsMgr.GetAvatarBaseInfo(uids, RoleInfoCorpsSystem.OnGetAvatarInfo, false)
end
function RoleInfoCorpsSystem.OnGetAvatarInfo(avatarInfoMap)
  RoleInfoCorpsSystem.RoleInfoCorpsAvatar = avatarInfoMap[RoleInfoCorpsSystem.RoleInfoCorpsData.n_leader] or RoleInfoCorpsSystem.RoleInfoCorpsAvatar
  RoleInfoCorpsSystem.  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CORPS_UPDATE_AVATAR)
end
function RoleInfoCorpsSystem.OnGetAvatarInfoForReport(avatarInfoMap)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local RoleInfoCorpsData = RoleInfoCorpsSystem.RoleInfoCorpsData
  local avatarInfo = avatarInfoMap[RoleInfoCorpsData.n_leader]
  if avatarInfo then
    local leaderName = avatarInfo.Name or ""
    local corpsId = RoleInfoCorpsData.str_corps_id
    local corpsName = RoleInfoCorpsData.str_name
    local corpsAnnoun = RoleInfoCorpsData.str_announcement
    CorpsMgr.SendReportInfo(leaderName, corpsId, corpsName, corpsAnnoun)
  end
end
function RoleInfoCorpsSystem.RoleInfoCorpsReport()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, DataMgr.GetMsgByID(101001), DataMgr.GetMsgByID(411043), function()
    local params = {
      RoleInfoCorpsSystem.RoleInfoCorpsData.n_leader
    }
    local cb = RoleInfoCorpsSystem.OnGetAvatarInfoForReport
    CorpsMgr.GetAvatarBaseInfo(params, cb, false)
  end)
end
function RoleInfoCorpsSystem.RoleInfoCorpsApplyJoinCorps()
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.SendApplyJoinCorps(tonumber(RoleInfoCorpsSystem.RoleInfoCorpsData.str_corps_id))
end
function RoleInfoCorpsSystem.RefreshCorpsSummary(corps_id, uid, corp_alias_id)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local corps_summary_cache = LobbySocialSystem.CacheCorpsSummary[corps_id] or {}
  local corps_info = RoleInfoCorpsSystem.CorpsInfo
  corps_info.b_IsOwnApply = LobbySocialSystem.HasApplyed(corps_id) or false
  corps_info.b_IsInvited = LobbySocialSystem.HasInvited(uid)
  if tonumber(corps_id) == 0 then
    corps_info.str_corps_id = "0"
    RoleInfoCorpsSystem.SetCorpsInfo(corps_info, corps_summary_cache)
    log(bWriteLog and "RoleInfoCorpsSystem.RefreshCorpsSummary corps_id ==0")
    return
  end
  corps_info.str_corps_id = tostring(corps_summary_cache.corps_id)
  corps_info.str_city = corps_summary_cache.city
  corps_info.n_activeness = corps_summary_cache.activeness
  corps_info.n_level = corps_summary_cache.level
  corps_info.n_leader = corps_summary_cache.leader
  corps_info.n_icon = corps_summary_cache.icon
  corps_info.str_icon_path = ""
  if corps_summary_cache.icon ~= nil and 0 < corps_summary_cache.icon then
    local corpIDConf = CDataTable.GetTableData("CorpsBadge", tonumber(corps_summary_cache.icon))
    if corpIDConf ~= nil then
      corps_info.str_icon_path = corpIDConf.IconPath
    end
  end
  corps_info.str_icon_text = corps_summary_cache.icon_text or ""
  corps_info.n_icon_text_colour = corps_summary_cache.icon_text_colour or 0
  corps_info.n_join_level = corps_summary_cache.join_level
  corps_info.str_announcement = corps_summary_cache.announcement
  corps_info.n_member_num = corps_summary_cache.member_num
  local levelCfg = CDataTable.GetTableData("CorpsLevel", corps_summary_cache.level)
  if levelCfg ~= nil then
    corps_info.n_member_max = levelCfg.MemberLimit
  else
    corps_info.n_member_max = 0
  end
  corps_info.n_join_segment = corps_summary_cache.join_segment
  corps_info.str_name = corps_summary_cache.name
  local corpsAliasCfg = CDataTable.GetTableData("corps_alias_table", corp_alias_id)
  if corpsAliasCfg then
    corps_info.corpsAliasName = string.format(corpsAliasCfg.CorpsAliasNameSmall, corps_info.str_name)
  end
  if corps_summary_cache.position == nil then
    corps_info.n_position = 0
  else
    local pos = corps_summary_cache.position
    corps_info.n_position = pos
  end
  RoleInfoCorpsSystem.SetCanJoin(DataMgr.corpsInfo.id == 0)
  RoleInfoCorpsSystem.SetCorpsInfo(corps_info, corps_summary_cache)
end
function RoleInfoCorpsSystem.Init()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  RoleInfoCorpsSystem.ShowUI()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CORPS_INIT_UIINFO)
  local uids = {
    RoleInfoCorpsSystem.RoleInfoCorpsData.n_leader
  }
  for _, v in ipairs(RoleInfoCorpsSystem.season_high_active_uids) do
    table.insert(uids, v.uid)
  end
  CorpsMgr.GetAvatarBaseInfo(uids, RoleInfoCorpsSystem.OnGetAvatarInfo, false)
end
return RoleInfoCorpsSystem
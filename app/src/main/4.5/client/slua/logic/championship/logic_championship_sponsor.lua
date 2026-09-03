local ChampionshipSponsorSystem = {
  MatchStatus = {
    ReadyStart = 0,
    InMatch = 1,
    FinishedMatch = 2
  },
  Whitelist = {},
  MatchCategory = {},
  ProfilerList = {},
  pub_id = 0,
  CacheRefreshTime = {
    send_get_personal_pug_rank = 0,
    send_get_pug_rank = 0,
    send_get_pug_teaminfo = 0
  },
  CacheRefreshInterval = 5,
  is_open = false,
  customInfo = {},
  IsGACPass = false,
  EnterFrom = 1,
  Is_Enrolled = false,
  signedUpRegion = "",
  regionList = nil,
  firstLoginTimer = nil,
  IsPopupPromote = false,
  promote_RankNo = nil,
  promote_total_pug_id = nil
}
local myTeamData
local minSegment = 201
local C_PopupDelayTime = 4
local EMatchType = {PMCO = 1, PMNC = 2}
ChampionshipSponsorSystem.local E_MapKeyConfig = {
  [1] = "map_desert",
  [2] = "Baltic_Main",
  [3] = "map_savagemain"
}
ChampionshipSponsorSystem.local HandleErrorCode = function(res)
  if res ~= 0 then
    if res == 13020030 then
      ShowNotice(100310006)
    elseif res == 13020031 then
      ShowNotice(505006)
    elseif res == 13020032 then
      ShowNotice(520037)
    elseif res == 13020033 then
    elseif res == 13020034 then
      ShowNotice(12649)
    elseif res == 13020035 then
      ShowNotice(102100014)
    elseif res == 13020036 then
      ShowNotice(501116)
    elseif res == 13020037 then
      ShowNotice(39231)
    elseif res == 13020038 then
      ShowNotice(13020038)
    elseif res == 13020039 then
      ShowNotice(110007)
    elseif res == 13020041 then
      ShowNotice(500062)
    elseif res == 13020042 then
      ShowNotice(500062)
    elseif res == 13020043 then
      local noticeId = LocUtil.LocalizeResFormat(38574, 4)
      ShowNotice(noticeId)
    elseif res == 13020044 then
      ShowNotice(39223)
    elseif res == 13020045 then
      ShowNotice(39224)
    elseif res == 13020046 then
      ShowNotice(505025)
    elseif res == 13020047 then
      ShowNotice(39225)
    elseif res == 13020048 then
      ShowNotice(42726)
    elseif res == 13020049 then
      ShowNotice(42727)
    elseif res == 13020050 then
      ShowNotice(117013)
    elseif res == 13020051 then
      ShowNotice(13020051)
    else
      ShowNotice(res)
    end
  end
end
function ChampionshipSponsorSystem.GetEntryInfo()
  local info = {
    nNameID = 12587,
    nDescID = 12587,
    sIcon_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_05.Esport_Game_bg_05",
    sIcon_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_04.Esport_Game_bg_04",
    logo_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/ESport_Sponsored_Match_logo_1.ESport_Sponsored_Match_logo_1",
    logo_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/ESport_Sponsored_Match_logo.ESport_Sponsored_Match_logo",
    color_open = FLinearColor(0.346704, 0.617207, 0.686686, 1),
    color_close = FLinearColor(0.814847, 0.814847, 0.814847, 1),
    stateFunc = ChampionshipSponsorSystem.GetState,
    clickFunc = ChampionshipSponsorSystem.ShowUI
  }
  return info
end
function ChampionshipSponsorSystem.GetState()
  if ChampionshipSponsorSystem.is_open then
    return ENUM_GameProgress.On
  else
    return ENUM_GameProgress.Off
  end
end
function ChampionshipSponsorSystem.IsSignUpState()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    log(bWriteLog and "[YY]\230\151\165\233\159\169\230\136\150\229\141\176\229\186\166\231\137\136\230\156\172\228\184\141\229\188\128\230\148\190")
    return false
  end
  local customInfo = ChampionshipSponsorSystem.customInfo
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if customInfo and customInfo.signup_start_time and customInfo.signup_end_time then
    return now >= customInfo.signup_start_time and now <= customInfo.signup_end_time and customInfo.switch_open
  end
  return false
end
function ChampionshipSponsorSystem.GetEnrollState()
  return ChampionshipSponsorSystem.Is_Enrolled
end
function ChampionshipSponsorSystem.IsMinLevel()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  local maxSegmentLevel = 0
  if profile then
    for _, tZoneSegment in pairs(profile.segment_info) do
      for _, nSegmentLevel in pairs(tZoneSegment) do
        maxSegmentLevel = math.max(maxSegmentLevel, nSegmentLevel)
      end
    end
    log_tree("segment_info==", profile.segment_info)
  end
  log(bWriteLog and "[YY]maxSegment===" .. tostring(maxSegmentLevel))
  if maxSegmentLevel >= minSegment then
    return true
  end
  return false
end
function ChampionshipSponsorSystem.GetMinSegmentLevel()
  return minSegment
end
function ChampionshipSponsorSystem.ShowErrorTips(res)
  HandleErrorCode(res)
end
function ChampionshipSponsorSystem.ShowEnrollUI()
  UIManager.ShowUI(UIManager.UI_Config.Championship_Entrance_SignUp)
end
function ChampionshipSponsorSystem.LockEnrollUI()
  if UIManager.IsUIShow(UIManager.UI_Config.Championship_Entrance_SignUp) then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_LOCK_TEAM)
  end
end
function ChampionshipSponsorSystem.ShowFirstLoginBeginPopup()
  if IsWoWEditor then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.SponsorSignUp)
  if not cfg or not cfg.startTime then
    UIManager.ShowUI(UIManager.UI_Config.Championship_Begin_Popup)
  else
    local start_time = ChampionshipSponsorSystem.customInfo.signup_start_time or 0
    if cfg and cfg.startTime and cfg.startTime ~= start_time then
      UIManager.ShowUI(UIManager.UI_Config.Championship_Begin_Popup)
    end
  end
end
function ChampionshipSponsorSystem.ShowSponsorWelcomePopup()
  if ChampionshipSponsorSystem.IsSignUpState() then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.SponsorSignUp)
    if not cfg or not cfg.startTime then
      ChampionshipSponsorSystem.ShowWelcomePopupAndSavaData()
    else
      local start_time = ChampionshipSponsorSystem.customInfo.signup_start_time or 0
      if cfg and cfg.startTime and cfg.startTime ~= start_time then
        ChampionshipSponsorSystem.ShowWelcomePopupAndSavaData()
      end
    end
  end
end
function ChampionshipSponsorSystem.ShowWelcomePopupAndSavaData()
  UIManager.ShowUI(UIManager.UI_Config.Championship_Popup_SignUp)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local start_time = ChampionshipSponsorSystem.customInfo.signup_start_time or 0
  local cfg = {startTime = start_time}
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.SponsorSignUp)
end
function ChampionshipSponsorSystem.ShowUI()
  if ChampionshipSponsorSystem.GetState() == ENUM_GameProgress.Off then
    if ChampionshipSponsorSystem.IsSignUpState() then
      if ChampionshipSponsorSystem.GetEnrollState() then
        UIManager.ShowUI(UIManager.UI_Config.Championship_Entrance_SignUp)
      else
        UIManager.ShowUI(UIManager.UI_Config.Championship_Popup_SignUp)
      end
      return
    end
    ShowNotice(7132)
    return false
  end
  local isDownloadMap = true
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  for _, v in ipairs(E_MapKeyConfig) do
    if PufferMapManager:CheckClassicMapNotDownload(v) then
      isDownloadMap = false
      break
    end
  end
  if not isDownloadMap then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Championship_Popup_Select)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyChampionSponsor)
  return false
end
function ChampionshipSponsorSystem.ClearTeamData()
  ChampionshipSponsorSystem.ProfilerList = {}
  myTeamData = nil
end
function ChampionshipSponsorSystem.InitTeamData(team)
  ChampionshipSponsorSystem.ProfilerList = {}
  local ids = {}
  for uid, v in pairs(team.members) do
    table.insert(ids, uid)
    local profile = {
      gid = tostring(uid),
      name = v.name or "",
      zone_id = v.zone_id or 1,
      svr = v.svr or 0,
      openid = v.openid or "",
      is_online = v.is_online or false,
      region = v.region or "G1"
    }
    table.insert(ChampionshipSponsorSystem.ProfilerList, profile)
  end
  log(bWriteLog and "[YY]InitTeamData==" .. tostring(#ChampionshipSponsorSystem.ProfilerList))
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ids, ChampionshipSponsorSystem.on_batch_get_near_by_profile_rsp, Enum_PROFILE_REPORT_CFG.SPONSOR)
end
function ChampionshipSponsorSystem.AddOneMember(uid, memberInfo)
  if not myTeamData.members then
    myTeamData.members = {}
  end
  myTeamData.members[uid] = memberInfo
  local ids = {}
  for id, v in pairs(myTeamData.members) do
    table.insert(ids, id)
  end
  myTeamData.member_cnt = #ids
  for i, v in pairs(ChampionshipSponsorSystem.ProfilerList) do
    if v and v.gid and (uid == tonumber(v.gid) or tonumber(v.gid) == 0) then
      local profile = memberInfo
      profile.gid = tostring(uid) or 0
      ChampionshipSponsorSystem.ProfilerList[i] = profile
      break
    end
  end
  log(bWriteLog and "[YY]AddOneMember==uid==" .. tostring(uid))
  log(bWriteLog and "[YY]AddOneMember==" .. tostring(myTeamData.member_cnt))
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ids, ChampionshipSponsorSystem.on_batch_get_near_by_profile_rsp, Enum_PROFILE_REPORT_CFG.SPONSOR)
end
function ChampionshipSponsorSystem.RemoveOneMember(uid)
  if myTeamData.members[uid] then
    myTeamData.members[uid] = nil
  end
  if myTeamData.member_cnt then
    myTeamData.member_cnt = myTeamData.member_cnt - 1
    if myTeamData.member_cnt < 0 then
      myTeamData.member_cnt = 0
    end
  end
  for i, v in pairs(ChampionshipSponsorSystem.ProfilerList) do
    if v and v.gid and tonumber(v.gid) == uid then
      table.remove(ChampionshipSponsorSystem.ProfilerList, i)
    end
  end
  log(bWriteLog and "[YY]RemoveOneMember==" .. tostring(myTeamData.member_cnt))
  log(bWriteLog and "[YY]RemoveOneMember==uid==" .. tostring(uid))
end
function ChampionshipSponsorSystem.UpdateOneMember(uid, memberInfo)
  if not myTeamData.members then
    myTeamData.members = {}
  end
  myTeamData.members[uid] = memberInfo
  local ids = {}
  for i, v in pairs(ChampionshipSponsorSystem.ProfilerList) do
    table.insert(ids, tonumber(v.gid))
    if tonumber(v.gid) == uid then
      local profile = memberInfo
      profile.gid = tostring(uid)
      ChampionshipSponsorSystem.ProfilerList[i] = profile
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ids, ChampionshipSponsorSystem.on_batch_get_near_by_profile_rsp, Enum_PROFILE_REPORT_CFG.SPONSOR)
end
function ChampionshipSponsorSystem.GetTeamData()
  return myTeamData
end
function ChampionshipSponsorSystem.GetMembers()
  if myTeamData then
    return myTeamData.members
  end
  return {}
end
function ChampionshipSponsorSystem.GetMemberNum()
  if myTeamData then
    return myTeamData.member_cnt
  end
  return 0
end
function ChampionshipSponsorSystem.GetMaxSameRegionNum()
  local max = 0
  local list = {}
  if myTeamData.members then
    for _, v in pairs(myTeamData.members) do
      if not list[v.region] then
        list[v.region] = 1
      else
        list[v.region] = list[v.region] + 1
      end
    end
    for _, v in pairs(list) do
      if v > max then
        max = v
      end
    end
  end
  log(bWriteLog and "[YY]max==" .. tostring(max))
  return max
end
function ChampionshipSponsorSystem.GetMemberInfo(uid)
  if not uid or not myTeamData then
    return nil
  end
  uid = tonumber(uid)
  return myTeamData.members[uid]
end
function ChampionshipSponsorSystem.IsTeamLeader(uid)
  if not uid or not myTeamData then
    return false
  end
  uid = tonumber(uid)
  return uid == myTeamData.leader
end
function ChampionshipSponsorSystem.GetLeaderInfo()
  if not (myTeamData and myTeamData.leader) or not myTeamData.members then
    return nil
  end
  local leader_uid = tonumber(myTeamData.leader)
  if myTeamData.members[leader_uid] then
    return myTeamData.members[leader_uid]
  end
  return nil
end
function ChampionshipSponsorSystem.GetTeamID()
  if myTeamData then
    return myTeamData.team_id
  end
  return 0
end
function ChampionshipSponsorSystem.on_notify_pug_white_list(whitelist)
  ChampionshipSponsorSystem.Whitelist = whitelist
  ChampionshipSponsorSystem.MatchCategory = {}
  log_tree("on_notify_pug_white_list whitelist", whitelist)
  local ids = {}
  ChampionshipSponsorSystem.is_open = false
  for id, v in pairs(whitelist) do
    if id and v.pugteam_id then
      ChampionshipSponsorSystem.is_open = true
      ChampionshipSponsorSystem.Is_Enrolled = true
    end
    table.insert(ids, id)
  end
  ChampionshipSponsorSystem.send_get_pug_info_req(ids)
  ChampionshipSponsorSystem.LockEnrollUI()
end
function ChampionshipSponsorSystem.send_get_pug_system_info_req()
  if not ChampionshipSponsorSystem.customInfo or not next(ChampionshipSponsorSystem.customInfo) then
    local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
    ChampionshipSponsorHandler.send_get_pug_system_info_req()
  end
end
function ChampionshipSponsorSystem.send_get_pug_info_req(pug_ids)
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_get_pug_info_req(pug_ids)
end
function ChampionshipSponsorSystem.send_get_one_pug_info_req(pug_id)
  log(bWriteLog and "send_get_one_pug_info_req pug_id" .. tostring(pug_id))
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if info and info.detail then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_get_one_pug_info_req(pug_id)
end
function ChampionshipSponsorSystem.Handle_LogOut()
  log(bWriteLog and "ChampionshipSponsorSystem.Handle_LogOut")
  ChampionshipSponsorSystem.Whitelist = {}
  ChampionshipSponsorSystem.MatchCategory = {}
  ChampionshipSponsorSystem.is_open = false
  ChampionshipSponsorSystem.customInfo = {}
  ChampionshipSponsorSystem.TeamData = {}
  ChampionshipSponsorSystem.SetPromoteInfo(nil, nil)
  if ChampionshipSponsorSystem.firstLoginTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ChampionshipSponsorSystem.firstLoginTimer)
    ChampionshipSponsorSystem.firstLoginTimer = nil
  end
end
function ChampionshipSponsorSystem.IsMyPub(pug_id)
  return ChampionshipSponsorSystem.Whitelist[pug_id]
end
function ChampionshipSponsorSystem.GetPubByModeRegion(parentPugId, mode, region)
  local pubs = ChampionshipSponsorSystem.MatchCategory[parentPugId]
  if not pubs then
    return 0
  end
  for id, pub in pairs(pubs) do
    if pub.battle_mode_name == mode and pub.region_name == region then
      return id
    end
  end
  log(bWriteLog and "GetPubByModeRegion:" .. tostring(mode) .. ",region:" .. tostring(region))
  return 0
end
function ChampionshipSponsorSystem.GetPubInfo(pug_id)
  for parentId, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    local info = v[pug_id]
    if info then
      return info
    end
  end
  return nil
end
function ChampionshipSponsorSystem.GetTournamentType(pug_id)
  local pubInfo = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if not pubInfo then
    return nil
  end
  if pubInfo and pubInfo.detail and pubInfo.detail.league_id then
    ChampionshipSponsorSystem.EnterFrom = pubInfo.detail.league_id
  end
end
function ChampionshipSponsorSystem.GetTotalRankPugId(pug_id)
  pug_id = pug_id or 0
  local pubInfo = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if not pubInfo then
    return nil
  end
  if pubInfo.detail and pubInfo.detail.total_pug_id then
    return pubInfo.detail.total_pug_id
  end
  return nil
end
function ChampionshipSponsorSystem.IsTotalRankPugId(pug_id)
  local PMCOCfg, PMNCCfg = ChampionshipSponsorSystem.GetSponsorCfg()
  if ChampionshipSponsorSystem.EnterFrom == ChampionshipSponsorSystem.EMatchType.PMCO then
    if PMCOCfg and next(PMCOCfg) then
      return PMCOCfg[1].total_pug_id == pug_id
    end
  elseif ChampionshipSponsorSystem.EnterFrom == ChampionshipSponsorSystem.EMatchType.PMNC and PMNCCfg and next(PMNCCfg) then
    return PMNCCfg[1].total_pug_id == pug_id
  end
  return false
end
function ChampionshipSponsorSystem.GetPubStatus(pug_id)
  local pubInfo = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if not pubInfo then
    return nil
  end
  local MatchStatus
  local Round = 1
  local TimeUtil = require("client.common.time_util")
  local CurrTime = TimeUtil.GetServerTimeInSec()
  for i, v in ipairs(pubInfo.detail.round_schedule) do
    Round = i
    if CurrTime < v.beg_time then
      MatchStatus = ChampionshipSponsorSystem.MatchStatus.ReadyStart
      break
    elseif CurrTime >= v.beg_time and CurrTime <= v.end_time then
      MatchStatus = ChampionshipSponsorSystem.MatchStatus.InMatch
      break
    else
      MatchStatus = ChampionshipSponsorSystem.MatchStatus.FinishedMatch
    end
  end
  return {
    Status = MatchStatus,
    Round = Round,
    TimeInfo = pubInfo.detail.round_schedule[Round]
  }
end
function ChampionshipSponsorSystem.GetPubModes(parent_pub_id)
  local pubs = ChampionshipSponsorSystem.MatchCategory[parent_pub_id]
  if not pubs then
    return {}
  end
  local TableUtil = require("common.table_util")
  local Modes = {}
  for i, v in pairs(pubs) do
    TableUtil.UniqueInsert(Modes, v.battle_mode_name)
  end
  table.sort(Modes)
  return Modes
end
function ChampionshipSponsorSystem.GetPubRegions(parent_pub_id)
  local pubs = ChampionshipSponsorSystem.MatchCategory[parent_pub_id]
  if not pubs then
    return {}
  end
  local TableUtil = require("common.table_util")
  local Regions = {}
  for i, v in pairs(pubs) do
    TableUtil.UniqueInsert(Regions, v.region_name)
  end
  table.sort(Regions)
  return Regions
end
function ChampionshipSponsorSystem.GetPubModeToRegions(parent_pub_id)
  local pubs = ChampionshipSponsorSystem.MatchCategory[parent_pub_id]
  if not pubs then
    log(bWriteLog and "ChampionshipSponsorSystem.GetPubModeToRegions:" .. tostring(parent_pub_id))
    return {}
  end
  local TableUtil = require("common.table_util")
  local ModeToRegions = {}
  for i, v in pairs(pubs) do
    local ModeName = v.battle_mode_name
    ModeToRegions[ModeName] = ModeToRegions[ModeName] or {}
    TableUtil.UniqueInsert(ModeToRegions[ModeName], v.region_name)
  end
  return ModeToRegions
end
function ChampionshipSponsorSystem.GetMyPubId(parent_pub_id)
  local pubs = ChampionshipSponsorSystem.MatchCategory[parent_pub_id]
  if not pubs then
    log(bWriteLog and "ChampionshipSponsorSystem.GetMyPubId1:" .. tostring(parent_pub_id))
    return 0
  end
  for id, v in pairs(pubs) do
    local info = ChampionshipSponsorSystem.Whitelist[id]
    if info then
      return id
    end
  end
  log(bWriteLog and "ChampionshipSponsorSystem.GetMyPubId2:" .. tostring(parent_pub_id))
  return 0
end
function ChampionshipSponsorSystem.GetAllParentPubIds()
  local ids = {}
  for i, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    table.insert(ids, i)
  end
  table.sort(ids)
  return ids
end
function ChampionshipSponsorSystem.GetAllParentPubIdsByType(typeId)
  local ids = {}
  for i, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    table.insert(ids, i)
  end
  local Ids_Type = {}
  local PMCOCfg, PMNCCfg = ChampionshipSponsorSystem.GetSponsorCfg()
  if typeId == ChampionshipSponsorSystem.EMatchType.PMCO then
    if not PMCOCfg then
      return Ids_Type
    end
    for _, parentId in pairs(ids) do
      for _, v in pairs(PMCOCfg) do
        if v and parentId == v.parentId then
          table.insert(Ids_Type, parentId)
        end
      end
    end
  elseif typeId == ChampionshipSponsorSystem.EMatchType.PMNC then
    if not PMNCCfg then
      return Ids_Type
    end
    for _, parentId in pairs(ids) do
      for _, v in pairs(PMNCCfg) do
        if v and parentId == v.parentId then
          table.insert(Ids_Type, parentId)
        end
      end
    end
  end
  table.sort(Ids_Type)
  return Ids_Type
end
function ChampionshipSponsorSystem.GetSponsorCfg()
  local ids = ChampionshipSponsorSystem.GetAllParentPubIds()
  if not ids or not next(ids) then
    return
  end
  local PMCOCfg = {}
  local PMNCCfg = {}
  for _, v in pairs(ids) do
    local pugId = ChampionshipSponsorSystem.GetMyPubId(v)
    if pugId then
      local pubInfo = ChampionshipSponsorSystem.GetPubInfo(pugId)
      if not pubInfo then
        return nil
      end
      if pubInfo and pubInfo.detail then
        if pubInfo.detail.league_id and pubInfo.detail.league_id == 1 then
          local cfg1 = {
            total_pug_id = pubInfo.detail.total_pug_id or 0,
            pub_Id = pugId or 0,
            league_id = 1,
            parentId = v or 0,
            beg_time = pubInfo.detail.beg_time or 0,
            end_time = pubInfo.detail.end_time or 0
          }
          table.insert(PMCOCfg, cfg1)
        elseif pubInfo.detail.league_id and pubInfo.detail.league_id == 2 then
          local cfg2 = {
            total_pug_id = pubInfo.detail.total_pug_id or 0,
            pub_Id = pugId or 0,
            league_id = 2,
            parentId = v or 0,
            beg_time = pubInfo.detail.beg_time or 0,
            end_time = pubInfo.detail.end_time or 0
          }
          table.insert(PMNCCfg, cfg2)
        else
          log_error("[YY]\232\181\155\228\186\139\231\177\187\229\158\139\229\173\151\230\174\181league_id\228\184\141\229\173\152\229\156\168")
        end
      end
    end
  end
  return PMCOCfg, PMNCCfg
end
function ChampionshipSponsorSystem.UpdateSponsorRedDotData()
  local ids = ChampionshipSponsorSystem.GetAllParentPubIds()
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  if not ids or not next(ids) then
    return
  end
  for _, v in pairs(ids) do
    local pugId = ChampionshipSponsorSystem.GetMyPubId(v)
    if pugId then
      log(bWriteLog and "[YY]pugId======" .. tostring(pugId))
      local statusInfo = ChampionshipSponsorSystem.GetPubStatus(pugId)
      local isMy = ChampionshipSponsorSystem.IsMyPub(pugId)
      if statusInfo and statusInfo.Status == ChampionshipSponsorSystem.MatchStatus.InMatch and isMy then
        esport_reddot_data.UpdateSponsorItemCount(pugId, 1)
      else
        esport_reddot_data.SendRemoveSponsorTlog()
        esport_reddot_data.UpdateSponsorItemCount(pugId, 0)
      end
    end
  end
end
function ChampionshipSponsorSystem.HasInMatchByTypeId(typeId)
  local PMCOCfg, PMNCCfg = ChampionshipSponsorSystem.GetSponsorCfg()
  if typeId == ChampionshipSponsorSystem.EMatchType.PMCO then
    if not PMCOCfg then
      return false
    end
    for _, v in pairs(PMCOCfg) do
      if v and v.pub_Id then
        local statusInfo = ChampionshipSponsorSystem.GetPubStatus(v.pub_Id)
        local isMy = ChampionshipSponsorSystem.IsMyPub(v.pub_Id)
        if statusInfo and statusInfo.Status == ChampionshipSponsorSystem.MatchStatus.InMatch and isMy then
          return true
        end
      end
    end
  elseif typeId == ChampionshipSponsorSystem.EMatchType.PMNC then
    if not PMNCCfg then
      return false
    end
    for _, v in pairs(PMNCCfg) do
      if v and v.pub_Id then
        local statusInfo = ChampionshipSponsorSystem.GetPubStatus(v.pub_Id)
        local isMy = ChampionshipSponsorSystem.IsMyPub(v.pub_Id)
        if statusInfo and statusInfo.Status == ChampionshipSponsorSystem.MatchStatus.InMatch and isMy then
          return true
        end
      end
    end
  end
  return false
end
function ChampionshipSponsorSystem.on_get_one_pug_info_rsp(res, pug_id, game_info)
  log(bWriteLog and "on_get_one_pug_info_rsp:" .. tostring(res) .. ",pug_id:" .. tostring(pug_id))
  log_tree("game_info", game_info)
  if res ~= 0 then
    return
  end
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if info then
    info.detail = game_info
  else
    log(bWriteLog and "on_get_one_pug_info_rsp no Pub")
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_ONE_PUG_INFO)
end
function ChampionshipSponsorSystem.on_get_pug_info_rsp(pug_ids, pug_info, relate_games)
  log_tree("on_get_pug_info_rsp", {
    pug_ids = pug_ids,
    pug_info = pug_info,
      })
  for parentId, v in pairs(relate_games) do
    ChampionshipSponsorSystem.MatchCategory[parentId] = ChampionshipSponsorSystem.MatchCategory[parentId] or {}
    local match = ChampionshipSponsorSystem.MatchCategory[parentId]
    for id, simpleInfo in pairs(v) do
      local mode_group_info = CDataTable.GetTableData("ModeTeamTable", simpleInfo.mode_group_id)
      local subModeIDTable = {}
      for w in string.gmatch(mode_group_info.SubModeIDs, "%d+") do
        table.insert(subModeIDTable, w)
      end
      if 0 <= #subModeIDTable then
        local modeId = subModeIDTable[1]
        local modeInfo = CDataTable.GetTableData("BTMode", modeId)
        if modeInfo then
          match[id] = match[id] or {}
          local info = match[id]
          info.battle_mode = simpleInfo.battle_mode
          info.mode_group_id = simpleInfo.mode_group_id
          info.          info.mode_id = modeId
          local IsFpp = modeInfo.IsFpp
          info.battle_mode_name = IsFpp and LocUtil.LocalizeResFormat(100053) or LocUtil.LocalizeResFormat(100054)
          info.region_name = simpleInfo.region_name
          local detail = pug_info[id]
          if detail then
            info.          end
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_GET_PUG_INFO)
  log_tree("on_get_pug_info_rsp==MatchCategory=====", ChampionshipSponsorSystem.MatchCategory)
  ChampionshipSponsorSystem.UpdateSponsorRedDotData()
end
function ChampionshipSponsorSystem.send_get_personal_pug_rank_req(pug_id)
  log(bWriteLog and "send_get_personal_pug_rank_req:" .. tostring(pug_id))
  if not ChampionshipSponsorSystem.IsMyPub(pug_id) then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PERSONAL_PUG_RANK)
    return
  end
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if info and info.myrank then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PERSONAL_PUG_RANK)
    local CacheRefreshTime = ChampionshipSponsorSystem.CacheRefreshTime.send_get_personal_pug_rank
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - CacheRefreshTime <= ChampionshipSponsorSystem.CacheRefreshInterval then
      return
    end
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_get_personal_pug_rank_req(pug_id)
end
function ChampionshipSponsorSystem.on_get_personal_pug_rank_rsp(res, pug_id, rank_no, score, sum_kill_num)
  log_tree("on_get_personal_pug_rank_rsp", {
    res = res,
    pug_id = pug_id,
    rank_no = rank_no,
    score = score,
      })
  if res ~= 0 then
    log_shipping_client("on_get_personal_pug_rank_rsp res:" .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PERSONAL_PUG_RANK)
    return
  end
  local TimeUtil = require("client.common.time_util")
  ChampionshipSponsorSystem.CacheRefreshTime.send_get_personal_pug_rank = TimeUtil.GetServerTimeInSec()
  for parentId, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    local info = v[pug_id]
    if info then
      info.myrank = rank_no
      info.my      info.my    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PERSONAL_PUG_RANK)
end
function ChampionshipSponsorSystem.send_get_pug_rank_req(pug_id, from_index)
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  local bTotalRank = ChampionshipSponsorSystem.IsTotalRankPugId(pug_id)
  if bTotalRank then
    log(bWriteLog and "[YY]\232\175\183\230\177\130\231\154\132\230\152\175\230\128\187\230\166\156==pug_id===" .. tostring(pug_id))
    ChampionshipSponsorHandler.send_get_pug_rank_req(pug_id, from_index)
    return
  end
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if info and info.rank_info then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_RANK)
    local CacheRefreshTime = ChampionshipSponsorSystem.CacheRefreshTime.send_get_pug_rank
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - CacheRefreshTime <= ChampionshipSponsorSystem.CacheRefreshInterval then
      return
    end
  end
  log(bWriteLog and "send_get_pug_rank_req pug_id:" .. tostring(pug_id) .. ",from_index:" .. tostring(from_index))
  ChampionshipSponsorHandler.send_get_pug_rank_req(pug_id, from_index)
end
function ChampionshipSponsorSystem.on_get_pug_rank_rsp(res, pug_id, from_index, rank_info)
  log_tree("on_get_pug_rank_rsp", {
    res = res,
    pug_id = pug_id,
    from_index = from_index,
      })
  local bTotalRank = ChampionshipSponsorSystem.IsTotalRankPugId(pug_id)
  if bTotalRank and res == 0 then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_TOTALRANK, rank_info)
    return
  end
  if res ~= 0 then
    log_shipping_client("on_get_pug_rank_rsp res:" .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_RANK)
    return
  end
  local TimeUtil = require("client.common.time_util")
  ChampionshipSponsorSystem.CacheRefreshTime.send_get_pug_rank = TimeUtil.GetServerTimeInSec()
  for parentId, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    local info = v[pug_id]
    if info then
      info.    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_RANK)
end
function ChampionshipSponsorSystem.send_get_pug_teaminfo_req(pug_id)
  log(bWriteLog and "send_get_pug_teaminfo_req pug_id:" .. tostring(pug_id))
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if info and info.team_info then
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_TEAMINFO)
    local CacheRefreshTime = ChampionshipSponsorSystem.CacheRefreshTime.send_get_pug_teaminfo
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - CacheRefreshTime <= ChampionshipSponsorSystem.CacheRefreshInterval then
      return
    end
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_get_pug_teaminfo_req(pug_id)
end
function ChampionshipSponsorSystem.HasFinishRound(pug_id, round)
  local info = ChampionshipSponsorSystem.GetPubInfo(pug_id)
  if not info or not info.team_info then
    log(bWriteLog and "ChampionshipSponsorSystem.HasFinishRound:" .. tostring(pug_id) .. ",round:" .. tostring(round))
    return false
  end
  for i, v in ipairs(info.team_info.game_result) do
    if v.round == round then
      return true
    end
  end
  if info.team_info.escape_record and next(info.team_info.escape_record[round] or {}) then
    return true
  end
  return false
end
function ChampionshipSponsorSystem.on_get_pug_teaminfo_rsp(res, pug_id, team_info)
  log_tree("on_get_pug_teaminfo_rsp", {
    res = res,
    pug_id = pug_id,
      })
  if res ~= 0 then
    log_shipping_client("on_get_pug_teaminfo_rsp res:" .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_TEAMINFO)
    return
  end
  local TimeUtil = require("client.common.time_util")
  ChampionshipSponsorSystem.CacheRefreshTime.send_get_pug_teaminfo = TimeUtil.GetServerTimeInSec()
  for parentId, v in pairs(ChampionshipSponsorSystem.MatchCategory) do
    local info = v[pug_id]
    if info then
      info.      local game_result = {}
      for round, v in pairs(team_info.game_result) do
        v.        table.insert(game_result, v)
      end
      info.team_info.    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_PUG_TEAMINFO)
  ChampionshipSponsorSystem.ProfilerList = {}
  local ids = {}
  for id, v in pairs(team_info.members) do
    if tonumber(v) ~= tonumber(DataMgr.roleData.uid) then
      table.insert(ids, v)
      local profile = {
        gid = tostring(v)
      }
      table.insert(ChampionshipSponsorSystem.ProfilerList, profile)
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ids, ChampionshipSponsorSystem.on_batch_get_near_by_profile_rsp, Enum_PROFILE_REPORT_CFG.SPONSOR)
end
function ChampionshipSponsorSystem.on_batch_get_near_by_profile_rsp(profileList)
  log_tree("on_batch_get_near_by_profile_rsp ", profileList)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ids = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for k, v in pairs(profileList) do
    table.insert(ids, v.uid)
    for kk, vv in pairs(ChampionshipSponsorSystem.ProfilerList) do
      if tonumber(vv.gid) == tonumber(v.uid) then
        vv.nickName = v.nickName
        vv.level = v.level
        vv.picUrl = v.picUrl
        vv.vipLevel = v.vipLevel
        vv.platName = v.platName
        vv.sex = v.sex
        vv.lastOnlineTime = v.lastOnlineTime
        vv.lastLoginTime = v.lastLoginTime
        vv.exp = v.exp
        vv.AllSegment_Info = v.segment_info
        vv.segment_info_solo, vv.segment_info_duo, vv.segment_info_squad = FuncUtil.GetMaxSegement(vv.AllSegment_Info)
        vv.history_max_segment_level = v.history_max_segment_level
        vv.startup_type = GetSafeNumber(v.startup_type)
        vv.cur_avatar_box_id = v.cur_avatar_box_id
        vv.upass_is_buy, vv.upass_is_show, vv.upass_keep_buy, vv.upass_cur_value, vv.pass_type = UnknowPassUtil.ParseUpassInfo(v.upass)
        vv.aliasId = v.alias.id
        vv.aliasTitle = v.alias.title
        vv.aliasNation = v.alias.nation
        vv.aliasRankId = v.alias.rank_id
        vv.roleNation = logic_profile:GetPlayerNation(v.uid)
      end
    end
  end
  if ids and next(ids) then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.ChampionshipSponsorSystem, ids, function(infos)
      ChampionshipSponsorSystem.Handle_batch_get_group_and_online_rsp(infos)
    end)
    EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_FRIEND_GROUP_STATE_CHANGE)
  end
end
function ChampionshipSponsorSystem.Handle_batch_get_group_and_online_rsp(infos)
  for k, v in pairs(infos) do
    for ka, va in pairs(ChampionshipSponsorSystem.ProfilerList) do
      if tonumber(va.gid) == tonumber(k) then
        va.online = v.online
        va.teamState = v.teamState
        va.currentTeamAmount = v.currentTeamAmount
        va.maxTeamAmount = v.maxTeamAmount
        va.timeSinceGameBegin = v.timeSinceGameBegin
        local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
        if LogicFriend.IsMyFriend(v.uid) then
          va.enableWatch = v.enableWatch
        else
          va.enableWatch = 0
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_FRIEND_GROUP_STATE_CHANGE)
end
function ChampionshipSponsorSystem.on_notify_pugteam_member_group_status_chg(memberid, status)
  for ka, va in pairs(ChampionshipSponsorSystem.ProfilerList) do
    if tonumber(va.gid) == tonumber(memberid) then
      va.online = status.online
      va.teamState = status.teamState
      va.currentTeamAmount = status.currentTeamAmount
      va.maxTeamAmount = status.maxTeamAmount
      va.timeSinceGameBegin = status.timeSinceGameBegin
      va.game_mode = status.game_mode
      va.game_sub_mode = status.game_sub_mode
      va.watch_uid = status.watch_uid
      va.teamStateNew = status.teamStateNew
      va.room_state = status.room_state
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if LogicFriend.IsMyFriend(memberid) then
        va.enableWatch = status.enableWatch
      else
        va.enableWatch = 0
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_FRIEND_GROUP_STATE_CHANGE)
end
function ChampionshipSponsorSystem.get_pug_system_info_rsp(url_open, url_close, content, name, event_name, signup_start_time, signup_end_time, switch_open, min_segment)
  ChampionshipSponsorSystem.customInfo = {
    url_open = url_open or "",
    url_close = url_close or "",
    content = content or "",
    name = name or "",
    event_name = event_name or "",
    signup_start_time = signup_start_time,
    signup_end_time = signup_end_time,
    switch_open = switch_open or false,
    min_segment = min_segment or 201
  }
  minSegment = min_segment
  log_tree("customInfo", ChampionshipSponsorSystem.customInfo)
  log(bWriteLog and "[YY]customInfo==switch_open" .. tostring(switch_open))
  local time_ticker = require("common.time_ticker")
  if not ChampionshipSponsorSystem.firstLoginTimer and ChampionshipSponsorSystem.IsSignUpState() then
    ChampionshipSponsorSystem.firstLoginTimer = time_ticker.AddTimerOnce(C_PopupDelayTime, function()
      ChampionshipSponsorSystem.ShowFirstLoginBeginPopup()
    end)
  end
end
function ChampionshipSponsorSystem.on_get_my_gac_info_rsp(err_code, room_id, is_invited)
  if err_code == 0 then
    ChampionshipSponsorSystem.IsGACPass = true
  elseif err_code == 740020 then
    ChampionshipSponsorSystem.IsGACPass = false
    if is_invited then
      local title = LocUtil.GetLocalizeResStr(5077)
      local msg = LocUtil.LocalizeResFormat(19118, DataMgr.roleData.uid)
      local strRegion = Client.GetPublishRegion()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if strRegion == PublishRegionMacros.BLUEHOLE then
        msg = LocUtil.GetLocalizeResStr(37480)
      end
      local txtBtnOk = LocUtil.GetLocalizeResStr(8134)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local url = string.format(FuncUtil.GetDomainByID(3366060) .. "/uid?=%s", DataMgr.roleData.uid)
      CommonMsgBoxMgr.Show(3, title, msg, function()
        Client.ClipBoardCopy(url)
        ShowNotice(8135)
      end, nil, txtBtnOk, nil)
    end
  else
    ChampionshipSponsorSystem.IsGACPass = false
  end
  if ChampionshipSponsorSystem.IsNeedPopupPromote(room_id) then
    UIManager.ShowUI(UIManager.UI_Config.Championship_Result_Popup)
  end
end
function ChampionshipSponsorSystem.InitTest()
  local TimeUtil = require("client.common.time_util")
  ChampionshipSponsorSystem.MatchCategory = {
    {
      [6166810] = {
        [6166811] = {
          pug_id = 6166816,
          battle_mode = 13100,
          region_name = "G1",
          detail_info = {
            pug_title = "\232\153\142\231\137\153\229\164\169\229\145\189\230\157\175",
            pug_desc = "\232\153\142\231\137\153\229\164\169\229\145\189\230\157\175",
            open_version = "0.14.0",
            beg_time = TimeUtil.OSTime(),
            end_time = TimeUtil.OSTime() + 4555555,
            open_gameid = {1320, 1321},
            battle_zoneid = 1,
            round_schedule = {
              {
                beg_time = TimeUtil.OSTime(),
                end_time = TimeUtil.OSTime() + 4555555
              },
              {
                beg_time = TimeUtil.OSTime(),
                end_time = TimeUtil.OSTime() + 4555555
              },
              {
                beg_time = TimeUtil.OSTime(),
                end_time = TimeUtil.OSTime() + 4555555
              }
            },
            main_title = "main_test",
            max_team_count = 20000,
            max_team_size = 5
          },
          rank_info = {
            {
              team_id = 5123456789111031243,
              sum_score = 1916,
              sum_dead_num = 1,
              team_summary = {
                team_flag = 10,
                name = "gm_5123456789111031243"
              },
              sum_final_win = 1
            },
            {
              team_id = 5123456789111031243,
              sum_score = 1916,
              sum_dead_num = 1,
              team_summary = {
                team_flag = 10,
                name = "gm_5123456789111031243"
              },
              sum_final_win = 1
            }
          },
          myrank = 1,
          team_info = {
            game_result = {
              {
                round = 1,
                team_rank = 2,
                dead_num = 4,
                kill_num = {
                  [54300000826] = 1,
                  [54300000825] = 5
                },
                game_mode = 11103,
                time_stamp = 1561366507,
                score = 500
              },
              {
                round = 3,
                team_rank = 2,
                dead_num = 4,
                kill_num = {
                  [54300000826] = 1,
                  [54300000825] = 5
                },
                game_mode = 11103,
                time_stamp = 1561366507,
                score = 500
              }
            },
            team_name = "test",
            team_flag = 1,
            pug_id = 6166816,
            leader_id = 54300000825,
            sum_score = 1000,
            sum_kill = 1000,
            members = {
              54300000825,
              54300000826,
              54300000827
            }
          }
        }
      }
    }
  }
end
function ChampionshipSponsorSystem.send_query_compete_team_req()
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_query_compete_team_req(1)
end
function ChampionshipSponsorSystem.on_query_compete_team_rsp(err_code, team)
  log_tree("on_query_compete_team_rsp==team", team)
  ChampionshipSponsorSystem.ClearTeamData()
  if err_code ~= 0 then
    HandleErrorCode(err_code)
    return
  end
  myTeamData = team
  ChampionshipSponsorSystem.InitTeamData(team)
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_UPDATE_TEAM_MEMBER_INFO)
end
function ChampionshipSponsorSystem.send_compete_create_team_req()
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_compete_create_team_req(1)
end
function ChampionshipSponsorSystem.on_compete_create_team_rsp(err, team)
  log_tree(bWriteLog and "[YY]on_compete_create_team_rsp==team", team)
  if err ~= 0 then
    HandleErrorCode(err)
    return
  end
  myTeamData = team
  ChampionshipSponsorSystem.InitTeamData(team)
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_UPDATE_TEAM_MEMBER_INFO)
end
function ChampionshipSponsorSystem.send_compete_team_invite_req(invitee_uid)
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_compete_team_invite_req(1, invitee_uid)
end
function ChampionshipSponsorSystem.on_compete_team_invite_ntfy(inviter_uid, invite_info)
  log(bWriteLog and "[YY]compete_team_invite_ntfy==inviterUid=" .. tostring(inviter_uid))
  log_tree("compete_team_invite_ntfy==invite_info=", invite_info)
  if IsWoWEditor then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Championship_Invite_Tip, inviter_uid, invite_info)
end
function ChampionshipSponsorSystem.send_compete_team_invite_reply_req(res, inviter, team_id)
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_compete_team_invite_reply_req(res, inviter, team_id, 1)
end
function ChampionshipSponsorSystem.on_compete_team_join_rsp(err, team)
  log_tree("on_compete_team_join_rsp==team==", team)
  if err ~= 0 then
    HandleErrorCode(err)
    return
  end
  myTeamData = team
  ChampionshipSponsorSystem.InitTeamData(team)
  ChampionshipSponsorSystem.ShowEnrollUI()
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_UPDATE_TEAM_MEMBER_INFO)
end
function ChampionshipSponsorSystem.send_compete_team_enroll_req(region_name)
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_compete_team_enroll_req(1, region_name)
end
function ChampionshipSponsorSystem.on_compete_team_enroll_rsp(err, team_info, region_name)
  if err ~= 0 then
    HandleErrorCode(err)
    return
  end
  log_tree("on_compete_team_enroll_rsp==team_info", team_info)
  local noticeId = LocUtil.LocalizeResFormat(39233, region_name or "")
  ShowNotice(noticeId)
  ChampionshipSponsorSystem.Is_Enrolled = true
  ChampionshipSponsorSystem.signedUpRegion = region_name or ""
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_SELECT_AREA)
  ChampionshipSponsorSystem.LockEnrollUI()
end
function ChampionshipSponsorSystem.send_compete_team_quit_req()
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_compete_team_quit_req(1)
end
function ChampionshipSponsorSystem.on_compete_team_quit_rsp(err, team_id, team_type)
  log(bWriteLog and "[YY]on_compete_team_quit_rsp==err==" .. tostring(err))
  log(bWriteLog and "[YY]on_compete_team_quit_rsp==team_id==" .. tostring(team_id))
  log(bWriteLog and "[YY]on_compete_team_quit_rsp==team_type==" .. tostring(team_type))
  if err ~= 0 then
    HandleErrorCode(err)
  end
  if ChampionshipSponsorSystem.GetTeamID() ~= tonumber(team_id) then
    log(bWriteLog and "[YY]on_compete_team_quit_rsp==GetTeamID==" .. tostring(ChampionshipSponsorSystem.GetTeamID()))
    return
  end
  ChampionshipSponsorSystem.ClearTeamData()
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_UPDATE_TEAM_MEMBER_INFO)
end
function ChampionshipSponsorSystem.on_notify_update_team_member(team_id, team_type, op_type, update_uid, member)
  log(bWriteLog and "[YY]on_notify_update_team_member==team_id=" .. tostring(team_id))
  log(bWriteLog and "[YY]on_notify_update_team_member==team_type=" .. tostring(team_type))
  log(bWriteLog and "[YY]on_notify_update_team_member==op_type=" .. tostring(op_type))
  log(bWriteLog and "[YY]on_notify_update_team_member==update_uid=" .. tostring(update_uid))
  log_tree("[YY]on_notify_update_team_member==member=", member)
  if ChampionshipSponsorSystem.GetTeamID() ~= tonumber(team_id) then
    return
  end
  if op_type == 1 then
    ChampionshipSponsorSystem.AddOneMember(update_uid, member)
  elseif op_type == 2 then
    if update_uid == tonumber(DataMgr.roleData.uid) then
      ShowNotice(LocUtil.LocalizeResFormat(39230))
      ChampionshipSponsorSystem.ClearTeamData()
      EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_EXIT_TEAM)
    else
      ChampionshipSponsorSystem.RemoveOneMember(update_uid)
    end
  elseif op_type == 3 then
    ChampionshipSponsorSystem.UpdateOneMember(update_uid, member)
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_UPDATE_TEAM_MEMBER_INFO)
end
function ChampionshipSponsorSystem.send_kickout_team_member_req(kick_uid)
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_kickout_team_member_req(1, kick_uid)
end
function ChampionshipSponsorSystem.on_kickout_team_member_rsp(err, kick_uid)
  if err ~= 0 then
    HandleErrorCode(err)
    return
  end
  log(bWriteLog and "[YY]on_kickout_team_member_rsp==uid=" .. tostring(kick_uid))
end
function ChampionshipSponsorSystem.send_get_pug_signup_cfg_req()
  if not ChampionshipSponsorSystem.IsSignUpState() then
    return
  end
  ChampionshipSponsorSystem.regionList = nil
  local ChampionshipSponsorHandler = require("client.network.Protocol.ChampionshipSponsorHandler")
  ChampionshipSponsorHandler.send_get_pug_signup_cfg_req()
end
function ChampionshipSponsorSystem.on_get_pug_signup_cfg_rsp(regionList)
  log_tree("regionList====", regionList)
  ChampionshipSponsorSystem.regionList = {}
  for k, _ in pairs(regionList) do
    table.insert(ChampionshipSponsorSystem.regionList, k)
  end
  EventSystem:postEvent(EVENTTYPE_LEAGUEGAME, EVENTID_CHAMPIONSHIP_GET_SELECT_AREA_INFO)
end
function ChampionshipSponsorSystem.SetPromoteInfo(total_pug_id, rank_no)
  ChampionshipSponsorSystem.promote_  ChampionshipSponsorSystem.promote_RankNo = rank_no
end
function ChampionshipSponsorSystem.GetPromoteInfo()
  return ChampionshipSponsorSystem.promote_total_pug_id, ChampionshipSponsorSystem.promote_RankNo
end
function ChampionshipSponsorSystem.IsNeedPopupPromote(pug_id)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    log(bWriteLog and "[YY]\230\151\165\233\159\169\230\136\150\229\141\176\229\186\166\231\137\136\230\156\172\228\184\141\229\188\128\230\148\190")
    return false
  end
  local total_pug_id, rank_no = ChampionshipSponsorSystem.GetPromoteInfo()
  if total_pug_id and rank_no and not ChampionshipSponsorSystem.IsPopupPromote then
    local total_id = ChampionshipSponsorSystem.GetTotalRankPugId(pug_id)
    log(bWriteLog and "[YY]pug_id===" .. tostring(pug_id))
    log(bWriteLog and "[YY]total_id===" .. tostring(total_id))
    if rank_no <= 100 then
      return true
    end
  end
  return false
end
return ChampionshipSponsorSystem
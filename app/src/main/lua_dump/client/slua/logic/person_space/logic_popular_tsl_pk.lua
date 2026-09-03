local logic_popular_tsl_pk = {}
function logic_popular_tsl_pk:ctor()
  self.C_TSL_PHASE = {
    NONE = 0,
    PREHEAT = 1,
    PKING = 2,
    WAIT_RESULT = 3,
    RESULT = 4,
    END = 5
  }
  self.C_EACH_PAGE_USER_NUM = 10
  self.C_RANK_REQ_LIMIT_TIME = 3
end
function logic_popular_tsl_pk:DefineAndResetData()
  self.match_cfgs = nil
  self.rank_cfgs = nil
  self.lottery_cfgs = nil
  self.fail_rank_cfgs = nil
  self.match_ids = nil
  self.match_info = nil
  self.lottery_data = nil
  self.pk_data = nil
  self.top_3_rank = nil
  self.rank_data = nil
  self.virtual_devote = nil
  self.mini_psmatch_get_rank_page_info = nil
  self.lottery_uid_page_info = nil
  self.gift_type = nil
  self.gift_count = nil
  self.last_rank_req_time = nil
  self.bReddot = false
  self.tsl_result_uibp_players_display_state = nil
end
function logic_popular_tsl_pk:IsOpen()
  if not self.match_ids then
    return false
  end
  local cur_match_id = self:GetCurMatchID()
  if not (cur_match_id and self.match_cfgs) or not self.match_cfgs[cur_match_id] then
    return false
  end
  local appid_limit = self.match_cfgs[cur_match_id].appid_limit
  local gameId = Client.GetITopGameId()
  local bAppid = false
  for appID, bValid in pairs(appid_limit) do
    if bValid and tonumber(gameId) == tonumber(appID) then
      bAppid = true
      break
    end
  end
  local version_limit = self.match_cfgs[cur_match_id].version_limit
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local bVersion = version_util.CompareVersionStandard(curVersion, version_limit) >= 0
  local mini_popularity_pk_cfg = self:GetCurMiniPopularityPKCfgFromServer()
  if mini_popularity_pk_cfg == nil then
    log(bWriteLog and "logic_popular_tsl_pk:IsOpen mini_popularity_pk_cfg is nil")
    return false
  end
  local pk_display_begin_time = mini_popularity_pk_cfg.pk_display_begin_time
  local pk_display_end_time = mini_popularity_pk_cfg.pk_display_end_time
  local TimeUtil = require("client.common.time_util")
  local svr_time = TimeUtil.GetServerTimeInSec()
  local bTime = pk_display_begin_time <= svr_time and pk_display_end_time >= svr_time
  log_format(bWriteLog and "logic_popular_tsl_pk:IsOpen bAppid: %s, bVersion: %s, bTime:%s", bAppid, bVersion, bTime)
  return bAppid and bVersion and bTime
end
function logic_popular_tsl_pk:GetTSLPhase()
  if not self:IsOpen() then
    return self.C_TSL_PHASE.NONE
  end
  local mini_popularity_pk_cfg = self:GetCurMiniPopularityPKCfgFromServer()
  if mini_popularity_pk_cfg == nil then
    return self.C_TSL_PHASE.NONE
  end
  local TimeUtil = require("client.common.time_util")
  local svr_time = TimeUtil.GetServerTimeInSec()
  local pk_start_time = mini_popularity_pk_cfg.pk_start_time
  local pk_end_time = mini_popularity_pk_cfg.pk_end_time
  local lottery_show_time = mini_popularity_pk_cfg.lottery_show_time
  local pk_display_end_time = mini_popularity_pk_cfg.pk_display_end_time
  log_format(bWriteLog and "logic_popular_tsl_pk:GetTSLPhase svr_time: %s", svr_time)
  if svr_time < pk_start_time then
    return self.C_TSL_PHASE.PREHEAT
  elseif svr_time >= pk_start_time and svr_time <= pk_end_time then
    return self.C_TSL_PHASE.PKING
  elseif svr_time > pk_end_time and svr_time < lottery_show_time then
    return self.C_TSL_PHASE.WAIT_RESULT
  elseif svr_time >= lottery_show_time and svr_time <= pk_display_end_time then
    return self.C_TSL_PHASE.RESULT
  elseif svr_time > pk_display_end_time then
    return self.C_TSL_PHASE.END
  end
end
function logic_popular_tsl_pk:IsShowTabRedDot()
  if not self:IsOpen() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTSLPkTabReddot) or {}
  log_tree(bWriteLog and "logic_popular_tsl_pk:IsShowTabRedDot data", data)
  local match_id = self:GetCurMatchID()
  if data[match_id] and data[match_id].tab then
    if self.bReddot == true then
      self:AddTimerOnce(0, function()
        local changes = {
          idList = {
            [ActivityFixedID.MiniPopularPK] = true
          },
          typeList = {}
        }
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
      end)
    end
    self.bReddot = false
    return false
  else
    if self.bReddot == nil or self.bReddot == false then
      self:AddTimerOnce(0, function()
        local changes = {
          idList = {
            [ActivityFixedID.MiniPopularPK] = true
          },
          typeList = {}
        }
        EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
      end)
    end
    self.bReddot = true
    return true
  end
end
function logic_popular_tsl_pk:ClearTabRedDot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTSLPkTabReddot) or {}
  log_tree(bWriteLog and "logic_popular_tsl_pk:ClearTabRedDot data", data)
  local match_id = self:GetCurMatchID()
  if not data[match_id] or not data[match_id].tab then
    data[match_id] = {}
    data[match_id].tab = 1
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eTSLPkTabReddot)
    EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_ACTIVITY_CHANGE)
  end
end
function logic_popular_tsl_pk:GetCurMatchID()
  if self.match_ids == nil then
    return nil
  end
  local match_id
  for id, bValid in pairs(self.match_ids) do
    if bValid then
      match_      break
    end
  end
  return match_id
end
function logic_popular_tsl_pk:GetCurMiniPopularityPKCfgFromServer()
  local match_id = self:GetCurMatchID()
  if match_id == nil then
    return nil
  end
  if self.match_cfgs == nil then
    return nil
  end
  local cfg = self.match_cfgs[match_id]
  return cfg
end
function logic_popular_tsl_pk:GetCurMiniPopularityPKCfgFromClient()
  if self.match_ids == nil then
    return nil
  end
  local cfg = CDataTable.GetTableData("MiniPopularityPK", self:GetCurMatchID())
  return cfg
end
function logic_popular_tsl_pk:GetMiniPopularityRankRewards(match_id, virtual_id)
  if self.match_cfgs == nil then
    return nil
  end
  if self.rank_cfgs == nil then
    return nil
  end
  return self.rank_cfgs[match_id][virtual_id]
end
function logic_popular_tsl_pk:GetMiniPopularityFailRankRewards(match_id, virtual_id)
  if self.match_cfgs == nil then
    return nil
  end
  if self.fail_rank_cfgs == nil or not next(self.fail_rank_cfgs) then
    return nil
  end
  return self.fail_rank_cfgs[match_id][virtual_id]
end
function logic_popular_tsl_pk:GetMiniPopularityVirtuals(match_id)
  if self.match_cfgs == nil then
    return nil
  end
  local match_cfg = self.match_cfgs[match_id]
  local virtual_left_cfg = CDataTable.GetTableData("MiniPopularityPKVirtual", match_cfg.pk_virtua_id_A)
  local virtual_right_cfg = CDataTable.GetTableData("MiniPopularityPKVirtual", match_cfg.pk_virtua_id_B)
  local cfgs = {
    [virtual_left_cfg.ID] = {
      ID = virtual_left_cfg.ID,
      PKVirtualPath = virtual_left_cfg.PKVirtualPath,
      PreheatVirtualPath = virtual_left_cfg.PreheatVirtualPath,
      ResultVirtualPath = virtual_left_cfg.ResultVirtualPath,
      ThemeColor = virtual_left_cfg.ThemeColor
    },
    [virtual_right_cfg.ID] = {
      ID = virtual_right_cfg.ID,
      PKVirtualPath = virtual_right_cfg.PKVirtualPath,
      PreheatVirtualPath = virtual_right_cfg.PreheatVirtualPath,
      ResultVirtualPath = virtual_right_cfg.ResultVirtualPath,
      ThemeColor = virtual_right_cfg.ThemeColor
    }
  }
  return cfgs
end
function logic_popular_tsl_pk:GetMiniPopularityLotteryRewards(match_id)
  if self.match_cfgs == nil then
    return nil
  end
  if self.lottery_cfgs == nil then
    return nil
  end
  return self.lottery_cfgs[match_id]
end
function logic_popular_tsl_pk:GetMiniPopularityDevote(match_id)
  if self.virtual_devote == nil then
    return nil
  end
  if self.virtual_devote[match_id] == nil then
    return nil
  end
  return self.virtual_devote[match_id]
end
function logic_popular_tsl_pk:SetMiniPopularityDevote(match_id, virtual_id, self_total_devote, virtual_total_devote)
  log_format(bWriteLog and "logic_popular_tsl_pk:SetMiniPopularityDevote match_id: %s, virtual_id: %s, self_total_devote: %s, virtual_total_devote: %s", match_id, virtual_id, self_total_devote, virtual_total_devote)
  if match_id == nil or virtual_id == nil then
    return
  end
  if self.virtual_devote == nil then
    self.virtual_devote = {}
  end
  if self.virtual_devote[match_id] == nil then
    self.virtual_devote[match_id] = {}
  end
  if self.virtual_devote[match_id][virtual_id] == nil then
    self.virtual_devote[match_id][virtual_id] = {}
  end
  self.virtual_devote[match_id][virtual_id].self_total_devote = self_total_devote or self.virtual_devote[match_id][virtual_id].self_total_devote
  self.virtual_devote[match_id][virtual_id].virtual_total_devote = virtual_total_devote or self.virtual_devote[match_id][virtual_id].virtual_total_devote
end
function logic_popular_tsl_pk:GetRankData(match_id, virtual_id)
  if not match_id and not virtual_id then
    return {}
  end
  local data = self.rank_data and self.rank_data[match_id] and self.rank_data[match_id][virtual_id] or {}
  return data
end
function logic_popular_tsl_pk:GetForbiddenMap()
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local gifts_config = logic_send_gift.GetGiftsConfig()
  local forbidden_map = {}
  for _, gift in pairs(gifts_config) do
    if not gift.EnableVirtualPK then
      forbidden_map[gift.GiftId] = true
    end
  end
  return forbidden_map
end
function logic_popular_tsl_pk:EncodeName(name)
  if not name or name == "" then
    log("logic_popular_tsl_pk:EncodeName. name is empty")
    return "******"
  end
  local chars = {}
  local len = 0
  for uchar in string.gmatch(name, "[%z\001-\127\194-\244][\128-\191]*") do
    len = len + 1
    chars[len] = uchar
  end
  local result = ""
  if len == 0 then
    result = "******"
  elseif len == 2 then
    result = chars[1] .. "****" .. chars[2]
  else
    result = chars[1] .. "****" .. chars[len]
  end
  log("logic_popular_tsl_pk:EncodeName. original:" .. tostring(name) .. " encoded:" .. result)
  return result
end
function logic_popular_tsl_pk:FormatNumberWithUnit(num)
  num = math.floor(num)
  if num < 1000 then
    return tostring(num)
  elseif num < 1000000 then
    return string.format("%.2fK", num / 1000)
  elseif num < 1000000000 then
    return string.format("%.2fM", num / 1000000)
  else
    return string.format("%.2fB", num / 1000000000)
  end
end
function logic_popular_tsl_pk.GetActivitySubData()
  local logic_popular_tsl_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_tsl_pk)
  if not logic_popular_tsl_pk:IsOpen() then
    return nil
  end
  local cli_cfg = logic_popular_tsl_pk:GetCurMiniPopularityPKCfgFromClient()
  if cli_cfg == nil then
    return nil
  end
  local svr_cfg = logic_popular_tsl_pk:GetCurMiniPopularityPKCfgFromServer()
  if svr_cfg == nil then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local svr_time = TimeUtil.GetServerTimeInSec()
  if svr_time < svr_cfg.pk_display_begin_time or svr_time > svr_cfg.pk_display_end_time then
    return nil
  end
  return {
    nActID = ActivityFixedID.MiniPopularPK,
    sName = LocUtil.GetLocalizeResStr(cli_cfg.ActivityNameLocID),
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    bRedDot = logic_popular_tsl_pk.GetReddotData
  }
end
function logic_popular_tsl_pk.GetReddotData(actID)
  local logic_popular_tsl_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_tsl_pk)
  local hasRedDot = logic_popular_tsl_pk:IsShowTabRedDot()
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  if hasRedDot then
    RedDotType = ActivityMacros.RedDotType.New
  end
  log_format(bWriteLog and "logic_popular_tsl_pk.GetReddotData hasRedDot: %s, RedDotType: %s", hasRedDot, RedDotType)
  return hasRedDot, RedDotType
end
function logic_popular_tsl_pk:proc_notify_mini_pspatch_valid_match(match_ids)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_notify_mini_pspatch_valid_match", match_ids)
  self.  if match_ids and next(match_ids) then
    self:send_mini_psmatch_get_match_cfg_req(self:GetCurMatchID())
  end
end
function logic_popular_tsl_pk:send_mini_psmatch_get_match_cfg_req(match_id)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_match_cfg_req match_id:%s", match_id)
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  PopularTSLHandler.send_mini_psmatch_get_match_cfg_req(match_id)
end
function logic_popular_tsl_pk:proc_mini_psmatch_get_match_cfg_rsp(err_code, match_id, match_cfg, rank_cfg, lottery_cfg, fail_rank_cfg)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_match_cfg_rsp", {
    err_code,
    match_id,
    match_cfg,
    rank_cfg,
    lottery_cfg
  })
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_match_cfg_rsp fail_rank_cfg", fail_rank_cfg)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  if self.match_cfgs == nil then
    self.match_cfgs = {}
  end
  self.match_cfgs[match_id] = match_cfg
  if self.rank_cfgs == nil then
    self.rank_cfgs = {}
  end
  self.rank_cfgs[match_id] = rank_cfg
  if self.lottery_cfgs == nil then
    self.lottery_cfgs = {}
  end
  if self.fail_rank_cfgs == nil then
    self.fail_rank_cfgs = {}
  end
  self.fail_rank_cfgs[match_id] = fail_rank_cfg
  self.lottery_cfgs[match_id] = lottery_cfg
end
function logic_popular_tsl_pk:send_mini_psmatch_get_devote_data_req()
  log(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_devote_data_req")
  if not self:IsOpen() then
    return
  end
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  PopularTSLHandler.send_mini_psmatch_get_devote_data_req()
end
function logic_popular_tsl_pk:proc_mini_psmatch_get_devote_data_rsp(err_code, match_info)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_devote_data_rsp", {err_code, match_info})
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  self.  for match_id, info in pairs(match_info) do
    for virtual_id, total_devote in pairs(info.virtual_devote) do
      self:SetMiniPopularityDevote(match_id, virtual_id, total_devote, nil)
    end
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_DEVOTE_DATA)
end
function logic_popular_tsl_pk:send_mini_psmatch_get_lottery_result_req(match_id)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_lottery_result_req match_id:%s", match_id)
  if not self:IsOpen() then
    return
  end
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  PopularTSLHandler.send_mini_psmatch_get_lottery_result_req(match_id)
end
function logic_popular_tsl_pk:proc_mini_psmatch_get_lottery_result_rsp(err_code, match_id, lottery_data)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_lottery_result_rsp", {
    err_code,
    match_id,
    lottery_data
  })
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  self.  if not lottery_data then
    return
  end
  local uid_list = {}
  for _, pool in pairs(lottery_data) do
    for _, ids in pairs(pool) do
      for _, uid in pairs(ids) do
        table.insert(uid_list, uid)
      end
    end
  end
  local rank_profile_page_tool = require("client.slua.logic.rank.rank_profile_page_tool")
  self.lottery_uid_page_info = rank_profile_page_tool.GetRankPageInfo(uid_list, 10)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_lottery_result_rsp lottery_uid_page_info", self.lottery_uid_page_info)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_LOTTERY_DATA)
end
function logic_popular_tsl_pk:send_mini_psmatch_send_gift_req(match_id, virtual_id, gift_type, gift_count)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_send_gift_req match_id:%s, virtual_id:%s, gift_type:%s, gift_count:%s", match_id, virtual_id, gift_type, gift_count)
  local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
  if not AccountAnchorModule:CanSendPopularity() then
    ShowNotice(500173)
    return
  end
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  if logic_send_gift.GetHallDepotGiftCount(gift_type) == 0 and logic_send_gift.IsUcGift(gift_type) then
    log(bWriteLog and "logic_send_gift.pspace_send_gift_req isUCGift")
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:CheckUCRestrict() then
      return
    end
  end
  if not self:IsOpen() then
    return
  end
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  self.  self.  PopularTSLHandler.send_mini_psmatch_send_gift_req(match_id, virtual_id, gift_type, gift_count)
end
function logic_popular_tsl_pk:proc_mini_psmatch_send_gift_rsp(err_code, match_id, virtual_id, self_total_devote)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_send_gift_rsp", {
    err_code,
    match_id,
    virtual_id,
    self_total_devote
  })
  if err_code ~= 0 then
    local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
    logic_send_gift.HandleGiftErrorCode(err_code, self.gift_type)
    return
  end
  self:SetMiniPopularityDevote(match_id, virtual_id, self_total_devote, nil)
  local gift_const = require("client.slua.logic.gift.gift_const")
  local tb = {
    gift_source = gift_const.GiftSourceType.PopularTSLPK,
    gift_type = self.gift_type,
    gift_count = self.gift_count
  }
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_PSPACE_SEND_GIFT_RSP, tb)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_SEND_GIFT_RSP)
end
function logic_popular_tsl_pk:proc_notify_mini_psmatch_total_devote(match_id, virtual_id, virtual_total_devote)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_notify_mini_psmatch_total_devote", {
    match_id,
    virtual_id,
    virtual_total_devote
  })
  self:SetMiniPopularityDevote(match_id, virtual_id, nil, virtual_total_devote)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_TOTAL_DEVOTE_NOTIFY)
end
function logic_popular_tsl_pk:send_mini_psmatch_get_pk_info_req(match_id)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_pk_info_req match_id:%s", match_id)
  if match_id == nil then
    log(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_pk_info_req match_id is nil")
    return
  end
  if not self:IsOpen() then
    return
  end
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  PopularTSLHandler.send_mini_psmatch_get_pk_info_req(match_id)
end
function logic_popular_tsl_pk:proc_mini_psmatch_get_pk_info_rsp(err_code, match_id, pk_data, top_3_rank)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_pk_info_rsp", {
    err_code,
    match_id,
    pk_data,
    top_3_rank
  })
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  self.pk_data = pk_data or {}
  for virtual_id, data in pairs(self.pk_data) do
    self:SetMiniPopularityDevote(match_id, virtual_id, nil, data.total_devote)
  end
  self.top_3_rank = top_3_rank or {}
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_INFO_RSP)
  local callback = function(profiles)
    EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_INFO_PROFILE)
  end
  local uids = {}
  for _, virtual_top3 in pairs(top_3_rank) do
    for _, data in pairs(virtual_top3) do
      table.insert(uids, data.uid)
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uids, callback, Enum_PROFILE_REPORT_CFG.ROLEINFO_POPULARITY_TSL, 0, true)
end
function logic_popular_tsl_pk:send_mini_psmatch_get_rank_req(match_id, virtual_id)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_rank_req match_id:%s, virtual_id:%s", match_id, virtual_id)
  if not self:IsOpen() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local server_time = TimeUtil.GetServerTimeInSec()
  if self.last_rank_req_time == nil then
    self.last_rank_req_time = {}
  end
  if self.last_rank_req_time[match_id] == nil then
    self.last_rank_req_time[match_id] = {}
  end
  if self.last_rank_req_time[match_id][virtual_id] == nil then
    self.last_rank_req_time[match_id][virtual_id] = server_time
  elseif math.abs(server_time - self.last_rank_req_time[match_id][virtual_id]) < self.C_RANK_REQ_LIMIT_TIME then
    log(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_rank_req is limit")
    return
  end
  self.last_rank_req_time[match_id][virtual_id] = server_time
  local PopularTSLHandler = require("client.network.Protocol.PopularTSLHandler")
  PopularTSLHandler.send_mini_psmatch_get_rank_req(match_id, virtual_id)
end
function logic_popular_tsl_pk:proc_mini_psmatch_get_rank_rsp(err_code, match_id, virtual_id, rank_data)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_rank_rsp", {
    err_code,
    match_id,
    virtual_id,
    rank_data
  })
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local TableUtil = require("common.table_util")
  if self.rank_data == nil then
    self.rank_data = {}
  end
  if match_id and self.rank_data[match_id] == nil then
    self.rank_data[match_id] = {}
  end
  if virtual_id and self.rank_data[match_id][virtual_id] == nil then
    self.rank_data[match_id][virtual_id] = {}
  end
  self.rank_data[match_id][virtual_id] = TableUtil.slice(rank_data, 1, math.min(#rank_data, 100))
  local uid_list = {}
  for _, data in pairs(rank_data) do
    table.insert(uid_list, data.uid)
  end
  local rank_profile_page_tool = require("client.slua.logic.rank.rank_profile_page_tool")
  self.mini_psmatch_get_rank_page_info = rank_profile_page_tool.GetRankPageInfo(uid_list, 10)
  log_tree(bWriteLog and "logic_popular_tsl_pk:proc_mini_psmatch_get_rank_rsp mini_psmatch_get_rank_page_info", self.mini_psmatch_get_rank_page_info)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_RANK_UPDATE)
end
function logic_popular_tsl_pk:send_mini_psmatch_get_rank_profile_req(uid)
  log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_rank_profile_req uid:%s", uid)
  local callback = function(profiles)
    log_format(bWriteLog and "logic_popular_tsl_pk:send_mini_psmatch_get_rank_profile_req callback profiles_count:%s", profiles and #profiles or 0)
    EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_RANK_PROFILE)
  end
  if self.mini_psmatch_get_rank_page_info == nil then
    return
  end
  local rank_profile_page_tool = require("client.slua.logic.rank.rank_profile_page_tool")
  rank_profile_page_tool.FetchRankProfileByUid(self.mini_psmatch_get_rank_page_info, uid, callback, Enum_PROFILE_REPORT_CFG.ROLEINFO_POPULARITY_TSL, true)
end
function logic_popular_tsl_pk:send_mini_psmatch_get_lottery_result_profile_req(uid)
  local callback = function(profiles)
    log_format(bWriteLog and "send_mini_psmatch_get_lottery_result_profile_req callback profiles_count:%s", profiles and #profiles or 0)
    EventSystem:postEvent(EVENTTYPE_POPULAR_TSL_PK, EVENTID_POPULAR_TSL_PK_LOTTERY_PROFILE)
  end
  if self.lottery_uid_page_info == nil then
    return
  end
  local rank_profile_page_tool = require("client.slua.logic.rank.rank_profile_page_tool")
  rank_profile_page_tool.FetchRankProfileByUid(self.lottery_uid_page_info, uid, callback, Enum_PROFILE_REPORT_CFG.ROLEINFO_POPULARITY_TSL, false)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_tsl_pk = class(CModuleBase, nil, logic_popular_tsl_pk)
return Clogic_popular_tsl_pk
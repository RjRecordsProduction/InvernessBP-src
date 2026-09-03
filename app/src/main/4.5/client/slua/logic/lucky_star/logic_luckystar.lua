local logic_luckystar = {}
function logic_luckystar:DefineAndResetData()
  self.checkTimerID = nil
  self.checkTimerInterval = 2
  self.lastCheckTime = nil
  self.checkCD = 0
  self.luckyOnlineUIds = {}
end
function logic_luckystar:OnInitialize()
  log(bWriteLog and "[logic_luckystar] OnInitialize")
  logic_luckystar.__super.OnInitialize(self)
end
function logic_luckystar:RegistEvents()
  log(bWriteLog and "[logic_luckystar] RegistEvents")
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_NOTIFY_LUCKY_STAR, self.OnNotifyLuckyStarMap, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.OnLevelChange, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_PRE_MATCH_SUCCESS, self.OnPreMatchSuccess, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTWEEK_ZERO, self.OnNextWeekZeroCome, self)
end
function logic_luckystar:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[logic_luckystar] OnPostSwitchGameStatus: " .. tostring(preState) .. tostring(nextState))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    self:OnLevelChange(nil, nil, DataMgr.roleData.level)
  end
  if nextState == GameStatus.Lobby then
    self:StartDetectingFree()
  end
end
function logic_luckystar:OnPreMatchSuccess(_, _, sub_mode)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode = logic_mode_selection:GetCurSelectInfo()
  local IsClassicRank = logic_mode_selection:IsClassicRankMode(matchMode)
  if IsClassicRank then
    self:CheckLuckyStarUpdate()
  end
end
function logic_luckystar:OnNextWeekZeroCome()
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and string.format("logic_luckystar:OnNextWeekZeroCome, time:%s", tostring(TimeUtil.FormatTime_YMDHMS(TimeUtil.GetServerTimeInSec()))))
  if self:IsLuckyStarValid() then
    self.lucky_star_map = {}
  end
end
function logic_luckystar:CheckLuckyStarUpdate()
  if self.lucky_star_map and next(self.lucky_star_map) then
    log(bWriteLog and "logic_luckystar:CheckLuckyStarUpdate already have data")
    return
  end
  if self:IsLuckyStarValid() then
    self:GetLuckyStarMapReq()
  end
end
function logic_luckystar:OnLevelChange(_, __, new_level)
  log(bWriteLog and "[logic_luckystar] OnLevelChange: " .. tostring(new_level))
  self:CheckLuckyStarUpdate()
end
function logic_luckystar:OnLogin(bReLogin)
  log(bWriteLog and "[logic_luckystar] OnLogin")
  logic_luckystar.__super.OnLogin(self, bReLogin)
  if not self:IsLuckyStarValid() then
    log(bWriteLog and "[logic_luckystar] lucky star not valid")
    return
  end
  self:GetLuckyStarMapReq()
end
function logic_luckystar:IsTimeValid()
  local begin_time_cfg = CDataTable.GetTableData("RecommendedSystemStringCfg", "fu_xing_begin_time")
  local end_time_cfg = CDataTable.GetTableData("RecommendedSystemStringCfg", "fu_xing_end_time")
  local time_util = require("client.common.time_util")
  return begin_time_cfg and end_time_cfg and time_util.UnixTimeStrBetween(begin_time_cfg.ValueStr, end_time_cfg.ValueStr) == 0
end
function logic_luckystar:IsLevelValid()
  if not DataMgr.roleData or not DataMgr.roleData.level then
    return false
  end
  local unlock_level = CDataTable.GetTableData("RecommendedSystemCfg", "fu_xing_min_level").Value
  if not unlock_level then
    log(bWriteLog and "[logic_luckystar] nil unlock level config")
    return true
  end
  return tonumber(DataMgr.roleData.level) >= tonumber(unlock_level)
end
function logic_luckystar:IsLuckyStarValid()
  return self:IsTimeValid() and self:IsLevelValid()
end
function logic_luckystar:IsLuckyTeammate(uid)
  return self.lucky_star_map and self.lucky_star_map[tonumber(uid)]
end
function logic_luckystar:IsTeammateTriggered(uid)
  if not self.lucky_star_map or not self.lucky_star_map[tonumber(uid)] then
    return
  end
  return self.lucky_star_map[tonumber(uid)].cnt > 0
end
function logic_luckystar:GetLuckyStarMap()
  return self.lucky_star_map
end
function logic_luckystar:GetLuckyStarList()
  if not self.lucky_star_map then
    return
  end
  local lucky_star_list = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for uid, lucky_star_status in pairs(self.lucky_star_map) do
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      local lucky_star_item = {
        uid = uid,
        cnt = lucky_star_status.cnt
      }
      table.insert(lucky_star_list, lucky_star_item)
    end
  end
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  table.sort(lucky_star_list, function(a, b)
    if b.cnt > 0 and a.cnt <= 0 then
      return true
    elseif b.cnt <= 0 and a.cnt > 0 then
      return false
    else
      local profile_a = logic_profile:GetLocalProfile(a.uid)
      local profile_b = logic_profile:GetLocalProfile(b.uid)
      if profile_a and profile_b then
        if tonumber(profile_a.online) ~= tonumber(profile_b.online) then
          return profile_a.online > profile_b.online
        elseif logic_new_friend.IsMyFriend(a.uid) ~= logic_new_friend.IsMyFriend(b.uid) then
          return logic_new_friend.IsMyFriend(a.uid)
        else
          return tonumber(a.uid) < tonumber(b.uid)
        end
      else
        return tonumber(a.uid) < tonumber(b.uid)
      end
    end
  end)
  return lucky_star_list
end
function logic_luckystar:GetLuckyStarMapReq()
  log(bWriteLog and "[logic_luckystar] GetLuckyStarMapReq")
  local WorldCupHandler = require("client.network.Protocol.WorldCupHandler")
  WorldCupHandler.send_get_fu_xing_info_req()
end
function logic_luckystar:GetLuckyStarMapRsp(err_code, lucky_star_map)
  log(bWriteLog and "[logic_luckystar] GetLuckyStarMapRsp: " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  self.  local req_profile_uid_list = {}
  for uid, _ in pairs(self.lucky_star_map) do
    table.insert(req_profile_uid_list, uid)
  end
  if #req_profile_uid_list <= 0 then
    log(bWriteLog and "[logic_luckystar] empty lucky star list")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(req_profile_uid_list, function(profile_list)
    self:OnGetLuckyStarProfileRsp(profile_list)
  end, Enum_PROFILE_REPORT_CFG.LUCKY_STAR)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.LuckyStar, req_profile_uid_list)
end
function logic_luckystar:OnNotifyLuckyStarMap(_, _, lucky_star_map)
  log(bWriteLog and "[logic_luckystar] OnNotifyLuckyStarMap")
  self.  local req_profile_uid_list = {}
  for uid, _ in pairs(self.lucky_star_map) do
    table.insert(req_profile_uid_list, uid)
  end
  if #req_profile_uid_list <= 0 then
    log(bWriteLog and "[logic_luckystar] empty lucky star list")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(req_profile_uid_list, function(profile_list)
    self:OnGetLuckyStarProfileRsp(profile_list)
  end, Enum_PROFILE_REPORT_CFG.LUCKY_STAR)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.LuckyStar, req_profile_uid_list, function()
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LUCKY_STAR_UPDATE)
  end)
end
function logic_luckystar:OnGetLuckyStarProfileRsp()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LUCKY_STAR_UPDATE)
end
function logic_luckystar:NeedCompareLuckyStar(uidA, uidB)
  if not self:IsLuckyStarValid() then
    return false
  end
  local needCompare = false
  if self:IsLuckyTeammate(uidA) and not self:IsTeammateTriggered(uidA) and (not self:IsLuckyTeammate(uidB) or self:IsTeammateTriggered(uidB)) then
    needCompare = true
  end
  if self:IsLuckyTeammate(uidB) and not self:IsTeammateTriggered(uidB) and (not self:IsLuckyTeammate(uidA) or self:IsTeammateTriggered(uidA)) then
    needCompare = true
  end
  return needCompare
end
function logic_luckystar:CompareFriendStatus(uidA, uidB)
  if self:IsLuckyTeammate(uidA) and not self:IsTeammateTriggered(uidA) and (not self:IsLuckyTeammate(uidB) or self:IsTeammateTriggered(uidB)) then
    return true
  end
  if self:IsLuckyTeammate(uidB) and not self:IsTeammateTriggered(uidB) and (not self:IsLuckyTeammate(uidA) or self:IsTeammateTriggered(uidA)) then
    return false
  end
  return tonumber(uidA) < tonumber(uidB)
end
function logic_luckystar:CanTeamRecommend()
  if not self:CheckSelfStatus(self.luckyOnlineUIds[1]) then
    log(bWriteLog and "logic_luckystar:on_fu_xing_online_notify, set Busy or Stealth status")
    return
  end
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend UI responsiveness testing")
    return false
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend bEnterMainCityLoading")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSingleMode() then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend IsSingleMode")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend InTeam")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  if not TeamUpNewSystem.CanTeamUp(false) then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend Cannot TeamUp")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right or Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left or Social_Person_Space_UIBP and Social_Person_Space_UIBP:IsShow() then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend Lobby showing")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local isAndroidStackEmpty = UIManager.IsAndroidStackEmpty()
  if not isAndroidStackEmpty then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend UI showing ")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  if self.lastCheckTime and FuncUtil.GetServerTimeInSec() - self.lastCheckTime < self.checkCD then
    log(bWriteLog and "logic_luckystar:CanTeamRecommend checkCD")
    return false
  end
  log(bWriteLog and "logic_luckystar:CanTeamRecommend OK")
  self.lastCheckTime = FuncUtil.GetServerTimeInSec()
  return true
end
function logic_luckystar:StartDetectingFree()
  log(bWriteLog and "logic_luckystar:StartDetectingFree ")
  self:RemoveCheckTimer()
  if not next(self.luckyOnlineUIds) then
    log(bWriteLog and "logic_luckystar:StartDetectingFree not luckyOnlineUIds")
    return
  end
  self.checkCD = CDataTable.GetTableData("RecommendedSystemCfg", "recommend_team_cd").Value
  self.checkTimerID = self:AddTimerLoop(0, function()
    if not next(self.luckyOnlineUIds) then
      self:RemoveCheckTimer()
      return
    end
    if self:CanTeamRecommend() then
      self:ShowRecommend()
    end
  end, TIMER_INFINITE, self.checkTimerInterval)
end
function logic_luckystar:ShowRecommend()
  if IsWoWEditor then
    return
  end
  local ShowTargetUI = function(profile)
    local logic_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_recommend)
    if logic_team_recommend:CheckValidStatus(profile) then
      local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
      PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.LuckStarRecommendTeamUp, {
        profile.uid
      }, function()
        local status = PlayerStatusMgr:GetStatusData(profile.uid)
        if status then
          if status.online == 1 then
            local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
            UIManager.ShowUI(UIManager.UI_Config.team_recommend, profile.uid, TeamUpNewSystem.E_InviteFromType.RecommendTeamLuckyStar, profile.all_show_labels)
            self:send_team_fu_xing_req(profile.uid)
          end
          log(bWriteLog and string.format("logic_luckystar:ShowRecommend ShowTargetUI, status.online:%s", status.online))
        end
        table.remove(self.luckyOnlineUIds, 1)
        self:StartDetectingFree()
      end)
    else
      log(bWriteLog and "logic_luckystar:ShowRecommend ShowTargetUI, not CheckValidStatus")
      table.remove(self.luckyOnlineUIds, 1)
      self:StartDetectingFree()
    end
  end
  local uid = self.luckyOnlineUIds[1]
  if uid then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({uid}, function()
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(uid)
      if profile then
        ShowTargetUI(profile)
      end
    end, Enum_PROFILE_REPORT_CFG.TEAMUP_INVITE, 0, true)
  end
end
function logic_luckystar:send_team_fu_xing_req(uid)
  local LuckyStarHandler = require("client.network.Protocol.LuckyStarHandler")
  LuckyStarHandler.send_team_fu_xing_req(uid)
end
function logic_luckystar:CheckSelfStatus(fu_xing_uid)
  if not fu_xing_uid then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  if FriendHandler.friend_status_data then
    local selfStatusID = FriendHandler.friend_status_data.sub_status_id or 0
    local cfg = CDataTable.GetTableData("FriendStatusCfg", selfStatusID)
    if cfg and (cfg.type == 7 or cfg.type == 6) then
      self:send_team_fu_xing_req(fu_xing_uid)
      table.remove(self.luckyOnlineUIds, 1)
      log(bWriteLog and string.format("logic_luckystar:CheckSelfStatus, set Busy or Stealth status:%s", cfg.type))
      return false
    end
  end
  return true
end
function logic_luckystar:CheckBlack(fu_xing_uid)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  if logic_friend_blacklist:IsByBlacklist(fu_xing_uid) then
    self:send_team_fu_xing_req(fu_xing_uid)
    table.remove(self.luckyOnlineUIds, 1)
    return true
  end
  return false
end
function logic_luckystar:on_fu_xing_online_notify(fu_xing_uid)
  if not self:CheckSelfStatus(fu_xing_uid) then
    log(bWriteLog and "logic_luckystar:on_fu_xing_online_notify, set Busy or Stealth status")
    return
  end
  if self:CheckBlack(fu_xing_uid) then
    log(bWriteLog and "logic_luckystar:CheckBlack is black uid")
    return
  end
  local TableUtil = require("common.table_util")
  if not TableUtil.IsInTable(self.luckyOnlineUIds, fu_xing_uid) then
    table.insert(self.luckyOnlineUIds, fu_xing_uid)
  end
  self:StartDetectingFree()
end
function logic_luckystar:RemoveCheckTimer()
  log(bWriteLog and "logic_luckystar:RemoveCheckTimer")
  if self.checkTimerID then
    self:RemoveTimer(self.checkTimerID)
    self.checkTimerID = nil
    self.lastCheckTime = 0
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_luckystar = class(CModuleBase, nil, logic_luckystar)
return Clogic_luckystar
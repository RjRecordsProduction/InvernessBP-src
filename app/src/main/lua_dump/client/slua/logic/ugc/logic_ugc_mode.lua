local logic_ugc_mode = {
  CONST_REQ_GET_PLAYERNUM_INTERVAL = 30,
  C_FriendShowMaxNum = 3,
  CONST_GC_PLAYERNUM = 300,
  INTERACTION_TYPES = {
    NONE = 0,
    PLAYING = 1,
    RANKING = 2,
    RECOMMENDED = 3,
    COLLECTED = 4,
    JUST_PLAYED = 5,
    PLAYED = 6,
    JUST_PLAYWOW = 7,
    PLAYWOW = 8
  }
}
function logic_ugc_mode:DefineAndResetData()
  self.modePlayerNumMap = nil
  self.reqGetPlayerNumTimer = nil
  self.reqDataTimeRecord = nil
  self.mode_id_list = nil
  self.displayFriendData = {}
  self.bReqDisplayFriendData = false
  self.bannerEnterPageIndex = 1
  self.ModPlayerData = {}
  self.MatchStatReqList = {}
  self.MatchStatReqTimer = nil
  self.LoopReqTime = 2
  self.DeleteModPlayerTime = nil
  self.FriendPlayingList = {}
end
function logic_ugc_mode:_ClearData()
  if self.DeleteModPlayerTime then
    self:RemoveTimer(self.DeleteModPlayerTime)
  end
  self:EndMatchStatReqTimer()
  self:DefineAndResetData()
end
function logic_ugc_mode:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_ZONE, self.OnMatchZoneChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_SELECTED_TAB, self.OnChangeSelectTab, self)
end
function logic_ugc_mode:OnLogOut()
  self:_ClearData()
end
function logic_ugc_mode:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() and slua_GameFrontendHUD then
    local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
    if CreativeModeBlueprintLibrary.IsCreativeMode(slua_GameFrontendHUD:GetWorld()) then
      self:StopReqPlayerNumTimer()
      self.reqDataTimeRecord = nil
      self.mode_id_list = nil
      self.bReqDisplayFriendData = false
      self.bannerEnterPageIndex = 1
    else
      self:_ClearData()
    end
  end
end
function logic_ugc_mode:OnMatchZoneChange()
  log(bWriteLog and "[v_wllwu] logic_ugc_mode:OnMatchZoneChange")
  self.mode_id_list = nil
  self.modePlayerNumMap = nil
  self.ModPlayerData = {}
end
function logic_ugc_mode:OnChangeSelectTab()
  log(bWriteLog and "[v_wllwu] logic_ugc_mode:OnChangeSelectTab:")
  self.mode_id_list = nil
end
function logic_ugc_mode:GetRequestModeIdList(mode_list, bForceCheckTabID)
  if not bForceCheckTabID and not self:IsCanRequestData(mode_list) then
    return
  end
  local mod_id_list = {}
  for _, v in ipairs(mode_list) do
    local mod_id = self:GetModIdByData(v)
    table.insert(mod_id_list, mod_id)
  end
  return mod_id_list
end
function logic_ugc_mode:IsCanRequestData(mode_list, dontCheckNewData)
  if not mode_list or #mode_list <= 0 then
    return false
  end
  if not self:IsOverInterval(self.CONST_REQ_GET_PLAYERNUM_INTERVAL) and (dontCheckNewData or not self:IsExistNewModId(mode_list)) then
    return false
  end
  return true
end
function logic_ugc_mode:IsExistNewModId(mode_list)
  if not mode_list then
    return false
  end
  for _, v in ipairs(mode_list) do
    local mod_id = self:GetModIdByData(v)
    if not self:GetModePlayerNum(mod_id) then
      return true
    end
  end
  return false
end
function logic_ugc_mode:GetModIdByData(metaData)
  if metaData.pub_mod_meta then
    return metaData.pub_mod_meta.mod_id
  end
  return metaData.mod_id
end
function logic_ugc_mode:StopReqPlayerNumTimer()
  if self.reqGetPlayerNumTimer == nil then
    return
  end
  self:RemoveTimer(self.reqGetPlayerNumTimer)
  self.reqGetPlayerNumTimer = nil
end
function logic_ugc_mode:IsSelectUgcMode()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local mode = logic_mode_selection:GetCurSelectInfo()
  local MatchModeTable = CDataTable.GetTableData("MatchModeTable", mode)
  log(bWriteLog and "[v_wllwu] logic_ugc_mode:IsSelectUgcMode, mode is:" .. tostring(mode))
  if MatchModeTable and MatchModeTable.Mode == "UG" then
    return true
  end
  return false
end
function logic_ugc_mode:ShowCurSelectUGCModDownloadNotice()
  log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice")
  local title = LocUtil.GetLocalizeResStr(5077)
  local downloadBtn = LocUtil.GetLocalizeResStr(7420)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local room_info = RoomSystem.CurrentRoomInfo
  local ugcMatchModInfo
  local Is_owner = RoomSystem.isRoomOwner()
  log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice, Is_owner  = " .. tostring(Is_owner))
  if not Is_owner and room_info and next(room_info) and room_info.room_type == "ugc" then
    local ModID = room_info.ugc_room_param.mod_id
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local modCache = LogicUGC:GetModByAllCache(ModID)
    if not modCache then
      log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice modCache is nil")
    end
    ugcMatchModInfo = modCache and modCache.pub_mod_meta
  else
    ugcMatchModInfo = LogicUGCMatch:GetUgcMatchModInfo()
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if ugcMatchModInfo then
    local state
    local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    if ugcMatchModInfo.mod_id and ugcMatchModInfo.mod_id > 0 then
      state = resManager:GetResState(resManager.DownloaderType.ModCopy, ugcMatchModInfo)
    else
      state = resManager:GetResState(resManager.DownloaderType.MyWork, ugcMatchModInfo)
    end
    if state == PufferConst.ENUM_DownloadState.Done then
      resManager:CheckReportCurUGCModState()
      log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice done")
      return
    end
    local cSize, tSize = resManager:GetResSize(resManager.DownloaderType.ModCopy, ugcMatchModInfo)
    local content = LocUtil.LocalizeResFormat(63000, string.format("%.1f", math.max(tSize - cSize, 0.1)))
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, content, function()
      if ugcMatchModInfo.mod_id and ugcMatchModInfo.mod_id > 0 then
        resManager:DownloadRes(resManager.DownloaderType.ModCopy, ugcMatchModInfo)
      else
        resManager:DownloadRes(resManager.DownloaderType.MyWork, ugcMatchModInfo)
      end
    end, function()
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local bInTeam = TeamUpNewSystem.IsInTeam()
      local bTeamLeader = TeamUpNewSystem.IsTeamLeader()
      log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice, bInTeam  = " .. tostring(bInTeam) .. " bTeamLeader = " .. tostring(bTeamLeader))
      if bInTeam and not bTeamLeader then
        local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
        local team_leader_uid = TeamUpNewSystem.GetTeamLeader()
        UGCMatchHandler.send_ugc_member_reply_download_asset_req(false, tonumber(team_leader_uid), 2)
        return
      end
      log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice RoomSystem.CurrentRoomInfo = " .. tostring(RoomSystem.CurrentRoomInfo))
      local room_id = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.id
      if room_id and not RoomSystem.isRoomOwner() then
        local RoomHandler = require("client.network.Protocol.RoomHandler")
        RoomHandler.send_ugc_room_member_reject_download(tonumber(room_id))
        return
      end
    end, downloadBtn)
  elseif LogicUGCMulti.bIsBundleMatch then
    local state, cSize, tSize = LogicUGCMulti:GetResState()
    if state == PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "logic_ugc_mode:ShowCurSelectUGCModDownloadNotice done")
      return
    end
    local content = LocUtil.LocalizeResFormat(63000, string.format("%.1f", math.max(tSize - cSize, 0.1)))
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, content, function()
      LogicUGCMulti:DownloadMultiModList()
    end, nil, downloadBtn)
  else
    ShowNotice(62615)
  end
end
function logic_ugc_mode:ReqGetModePlayerNum(list)
  self.mode_id_list = self:GetRequestModeIdList(list)
  if self.mode_id_list and #self.mode_id_list > 0 then
    self:ugc_match_stat_req(self.mode_id_list)
    return
  end
  self:StartReqPlayerNumTimer()
end
function logic_ugc_mode:StartReqPlayerNumTimer()
  if self.reqGetPlayerNumTimer ~= nil then
    return
  end
  self.reqGetPlayerNumTimer = self:AddTimerLoop(0, function()
    self:CheckRequestGetNewestPlayerNumInfo()
  end, TIMER_INFINITE, 10)
end
function logic_ugc_mode:CheckRequestGetNewestPlayerNumInfo()
  if not self:IsCanRequestData(self.mode_id_list, true) then
    return
  end
  self:ugc_match_stat_req(self.mode_id_list)
end
function logic_ugc_mode:IsOverInterval(interval)
  if not self.reqDataTimeRecord then
    return true
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local tab_id = LogicUGC:GetSelectedTabId()
  if not self.reqDataTimeRecord[tab_id] then
    return true
  end
  local sub_tab_id = LogicUGC:GetSelectedSubTabId()
  local time = self.reqDataTimeRecord[tab_id][sub_tab_id]
  if not time then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return interval <= curTime - time
end
function logic_ugc_mode:GetBannerEnterPagerIndex()
  return self.bannerEnterPageIndex
end
function logic_ugc_mode:SetBannerEnterPagerIndex(index)
  self.bannerEnterPageIndex = index
end
function logic_ugc_mode:BatchModPlayerReq(modlist, bNotReq, bCut)
  if not modlist or #modlist <= 0 then
    return
  end
  local ModPlayerList = {}
  if self.ModPlayerData then
    for k, modid in pairs(modlist) do
      if self.ModPlayerData[modid] and not ModPlayerList[modid] then
        table.insert(ModPlayerList, self.ModPlayerData[modid])
      end
    end
  end
  if not bNotReq then
    self:RemoveDuplicateModlist(modlist)
    if bCut then
      table.insert(self.MatchStatReqList, 1, modlist)
    else
      table.insert(self.MatchStatReqList, modlist)
    end
    if not self.MatchStatReqTimer then
      self:OpenMatchStatReqTimer()
    end
  end
  return ModPlayerList
end
function logic_ugc_mode:OpenMatchStatReqTimer()
  log(bWriteLog and "logic_ugc_mode:OpenMatchStatReqTimer")
  self.MatchStatReqTimer = self:AddTimerLoop(self.LoopReqTime, function()
    if self.MatchStatReqList and #self.MatchStatReqList >= 1 then
      local modlist = self.MatchStatReqList[1]
      table.remove(self.MatchStatReqList, 1)
      self:ugc_match_stat_req(modlist)
    end
  end, TIMER_INFINITE, self.LoopReqTime)
end
function logic_ugc_mode:EndMatchStatReqTimer()
  if self.MatchStatReqTimer then
    self:RemoveTimer(self.MatchStatReqTimer)
    self.MatchStatReqTimer = nil
    log(bWriteLog and "logic_ugc_mode:EndMatchStatReqTimer")
  end
end
function logic_ugc_mode:RemoveDuplicateModlist(modlist)
  if not self.MatchStatReqList or #self.MatchStatReqList <= 0 then
    return
  end
  local lookup = {}
  for _, modid in ipairs(modlist) do
    lookup[modid] = true
  end
  for i = #self.MatchStatReqList, 1, -1 do
    local current = self.MatchStatReqList[i]
    if self:IsModlistEqual(current, lookup) then
      table.remove(self.MatchStatReqList, i)
    end
  end
end
function logic_ugc_mode:IsModlistEqual(modlist, lookup)
  for _, modid in ipairs(modlist) do
    if not lookup[modid] then
      return false
    end
  end
  return true
end
function logic_ugc_mode:GetModePlayerNum(mode_id)
  if not self.ModPlayerData then
    return
  end
  return self.ModPlayerData[mode_id]
end
function logic_ugc_mode:ugc_match_stat_req(mode_id_list, bIgnoreTabID)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zone_id = ZoneSystem.GetChooseZone()
  if not zone_id or zone_id <= 0 then
    log(bWriteLog and "[v_wllwu] logic_ugc_mode:ugc_match_stat_req, return because of zone_id is:" .. tostring(zone_id))
    return
  end
  if mode_id_list and 1 <= #mode_id_list then
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    UGCModHandler.send_ugc_match_stat_req(zone_id, mode_id_list)
    log_tree(" logic_ugc_mode:ugc_match_stat_req ", mode_id_list)
    if not self.MatchStatReqList or 0 >= #self.MatchStatReqList then
      self:EndMatchStatReqTimer()
    end
  else
    log(bWriteLog and "logic_ugc_mode:ugc_match_stat_req mode_id_list is nil")
  end
end
function logic_ugc_mode:on_ugc_match_stat_rsp(zone_id, match_stat_map)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local self_zone_id = ZoneSystem.GetChooseZone()
  if not self_zone_id or self_zone_id <= 0 or self_zone_id ~= zone_id then
    return
  end
  log_tree(" logic_ugc_mode:on_ugc_match_stat_rsp ", match_stat_map)
  if IsEditor and false then
    for modId, playerNum in pairs(match_stat_map) do
      match_stat_map[modId] = modId
    end
  end
  for mod_id, num in pairs(match_stat_map) do
    self.ModPlayerData[mod_id] = num
  end
  if not self.DeleteModPlayerTime then
    self.DeleteModPlayerTime = self:AddTimerLoop(self.CONST_GC_PLAYERNUM, function()
      print(bWriteLog and "ModPlayerData GC")
      if self.ModPlayerData and #self.ModPlayerData >= 1 then
        self.ModPlayerData = {}
      end
    end, TIMER_INFINITE, 300)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_MODE_PLAYERNUM)
end
function logic_ugc_mode:send_ugc_display_friend_req()
  if self.bReqDisplayFriendData then
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  return UGCAuthorHandler.send_ugc_display_friend_req()
end
function logic_ugc_mode:proc_ugc_display_friend_rsp(display_friend)
  self.bReqDisplayFriendData = true
  if not display_friend then
    return
  end
  for k, v in pairs(display_friend) do
    self.displayFriendData[k] = v
  end
end
function logic_ugc_mode:GetDisplayFriendData(mod_id)
  if not mod_id then
    return nil
  end
  return self.displayFriendData[mod_id]
end
local C_FRIEND_MANY_PREFIX_NUM_THRESHOLD = 3
function logic_ugc_mode:GetDisplayFriendLabel(mod_id, uid, modInfo)
  local bPlayed = false
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local _historyKeyList = LogicUGC:GetHistoryKeyInfoList() or {}
  if _historyKeyList[mod_id] then
    bPlayed = true
  end
  local tlogStr = ""
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if uid then
    local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if not logic_friend_blacklist:IsBlacklist(uid) and LogicFriend.IsMyFriend(uid) then
      log(bWriteLog and "logic_ugc_mode:GetDisplayFriendLabel mod_id:" .. tostring(mod_id) .. " is Friend's works uid:" .. tostring(uid))
    end
  end
  local data = self:GetDisplayFriendData(mod_id)
  local label = ""
  if data ~= nil then
    if data.type == Config_UGC.E_DisplayFriendState.Friend then
      if data.num > C_FRIEND_MANY_PREFIX_NUM_THRESHOLD then
        label = LocUtil.LocalizeResFormat(69347, data.num)
      else
        label = LocUtil.LocalizeResFormat(77866, data.num)
      end
    elseif data.type == Config_UGC.E_DisplayFriendState.Collection then
      if data.num > C_FRIEND_MANY_PREFIX_NUM_THRESHOLD then
        label = LocUtil.LocalizeResFormat(69348, data.num)
      else
        label = LocUtil.LocalizeResFormat(77867, data.num)
      end
    elseif data.type == Config_UGC.E_DisplayFriendState.Recommend then
      if data.num > C_FRIEND_MANY_PREFIX_NUM_THRESHOLD then
        label = LocUtil.LocalizeResFormat(69349, data.num)
      else
        label = LocUtil.LocalizeResFormat(77868, data.num)
      end
    end
    tlogStr = string.format("%s_%s", data.type, data.num)
  end
  return label, bPlayed, false, tlogStr
end
function logic_ugc_mode:GetUpdateInfoLabel(modInfo, checkTab)
  if not modInfo then
    return ""
  end
  local time = 0
  local publish_date = modInfo.publish_date or 0
  local update_date = modInfo.update_date or 0
  local newTime = math.max(publish_date, update_date)
  if newTime == 0 then
    return ""
  end
  local isUpdate = newTime ~= publish_date
  if checkTab ~= false then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local nTab = LogicUGC:GetSelectedTabId()
    local nSubTabId = LogicUGC:GetSelectedSubTabId()
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    if nTab == Config_UGC.Config_UGC_TabID.Play and nSubTabId == Config_UGC.Config_UGC_TabID.Collect then
      local LogicUGCSocial = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCSocial)
      local collectInfo = LogicUGCSocial:GetCollectInfo(modInfo.mod_id)
      if collectInfo ~= nil and collectInfo.lately_look_time ~= nil and newTime > collectInfo.lately_look_time then
        time = newTime
      end
    end
  end
  if time == 0 and self:IsTodayUpdate(newTime) then
    time = newTime
  end
  if 0 < time then
    local TimeUtil = require("client.common.time_util")
    local timeStr = TimeUtil.GetTimeAgoStr(time, false)
    local key
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local tlogStr
    if isUpdate then
      key = 77870
      tlogStr = tostring(Config_UGC.TlogStrState.Update)
    else
      key = 77869
      tlogStr = tostring(Config_UGC.TlogStrState.Publish)
    end
    return LocUtil.LocalizeResFormat(key, timeStr), tlogStr
  end
  return ""
end
function logic_ugc_mode:GetShowLabelInfo(modInfo)
  local mod_id = 0
  local uid = 0
  if modInfo then
    if modInfo.mod_id then
      mod_id = modInfo.mod_id
    end
    if modInfo.base and modInfo.base.uid then
      uid = modInfo.base.uid
    end
  end
  local Label, bPlayed, bIsFriendMod, tlogStr = self:GetDisplayFriendLabel(mod_id, uid, modInfo)
  if Label ~= "" and bIsFriendMod then
    return {Label = Label, TlogStr = tlogStr}
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendMap = LogicFriend.GetAllFriendData()
  if Label ~= "" then
    local UserInfos = {}
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local FriendMap = LogicFriend.GetAllFriendData()
    local displayFriendData = self.displayFriendData
    if FriendMap and displayFriendData and displayFriendData[mod_id] then
      local displayMsr = displayFriendData[mod_id]
      if displayMsr.uids then
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        for index, value in pairs(displayMsr.uids) do
          local info = logic_profile:GetLocalProfile(displayMsr.uids[index])
          if info ~= nil and (info.ugc_privacy_setting == nil or info.ugc_privacy_setting.rec_display == nil) then
            local FriendInfo = FriendMap[displayMsr.uids[index]]
            if FriendInfo then
              table.insert(UserInfos, {
                uid = displayMsr.uids[index],
                intimacy = FriendInfo.intimacy
              })
            end
          end
        end
      end
      if 0 < #UserInfos then
        table.sort(UserInfos, function(a, b)
          local KeyA = a.intimacy or 0
          local KeyB = b.intimacy or 0
          if KeyA == KeyB then
            return tonumber(a.uid) < tonumber(b.uid)
          else
            return KeyA > KeyB
          end
        end)
        return {
          Label = Label,
          FriendList = UserInfos,
          TlogStr = tlogStr
        }
      end
    end
  end
  if bPlayed then
    local UpdateLabel, updateTlogStr = self:GetUpdateInfoLabel(modInfo)
    if UpdateLabel ~= "" then
      return {
        Label = UpdateLabel,
        TlogStr = updateTlogStr,
        LabelState = true
      }
    end
  end
  return nil
end
function logic_ugc_mode:IsTodayUpdate(time)
  time = time or 0
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local durTime = nowTime - time
  local showNewIconHours = 24
  local cfg = CDataTable.GetTableData("UGCParamConfig", "New_Show_Time")
  if cfg then
    local hours = tonumber(cfg.Value)
    if hours then
      showNewIconHours = hours
    end
  end
  return 0 < durTime and durTime <= showNewIconHours * 3600
end
function logic_ugc_mode:FriendPlayingReq()
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  log(bWriteLog and "logic_ugc_mode:FriendPlayingReq")
  UGCAuthorHandler.send_ugc_friend_v2_realtime_req()
end
function logic_ugc_mode:FriendPlayingRsp(FriendPlayingList)
  log_tree("logic_ugc_mode:FriendPlayingRsp FriendPlayingList = ", FriendPlayingList)
  local FriendPlayingData = FriendPlayingList or {}
  self.FriendPlayingList = {}
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for from_uid, mod_data in pairs(FriendPlayingData) do
    if not self:FriendIsHidden(from_uid) and not self:CheckFriendPrivacy(from_uid) then
      self.FriendPlayingList[from_uid] = {}
      for mod_id, time_data in pairs(mod_data) do
        if not time_data.collect_time and not time_data.comment_recommend_time then
          if time_data.start_time and time_data.end_time and time_data.end_time <= time_data.start_time then
            time_data.end_time = nil
          end
          local FriendData = {
            mod_id = mod_id,
            start_time = time_data.start_time or nil,
            end_time = time_data.end_time or nil,
            from_uid = from_uid,
            IsPlaying = time_data.start_time and not time_data.end_time,
            outcome = time_data.outcome
          }
          if not time_data.end_time then
            FriendData.start_time = nowTime
            FriendData.IsPlaying = true
            log(bWriteLog and string.format("Fix invalid playing data for mod_id %d from uid %d, use current time as start_time", mod_id, from_uid))
          end
          self.FriendPlayingList[from_uid][mod_id] = FriendData
        end
      end
    end
  end
end
function logic_ugc_mode:FriendWinRsp(from_uid, mod_id, outcome)
  if not self.FriendPlayingList or not next(self.FriendPlayingList) then
    log(bWriteLog and "logic_ugc_mode:FriendWinRsp FriendPlayingList is not FriendPlayingList")
    return
  end
  log(bWriteLog and "logic_ugc_mode:FriendWinRsp from_uid = %d, mod_id = %d, outcome = %d", from_uid, mod_id, outcome)
  if self.FriendPlayingList[from_uid] and self.FriendPlayingList[from_uid][mod_id] then
    self.FriendPlayingList[from_uid][mod_id].  end
end
function logic_ugc_mode:GetFriendPlayingModList()
  log_tree("logic_ugc_mode:GetFriendPlayingModList FriendPlayingList", self.FriendPlayingList)
  local FriendPlayingModList = {}
  if self.FriendPlayingList then
    for k, v in pairs(self.FriendPlayingList) do
      for mod_id, FriendData in pairs(v) do
        if FriendData.IsPlaying then
          FriendPlayingModList[mod_id] = true
        end
      end
    end
  end
  return FriendPlayingModList
end
function logic_ugc_mode:GetFriendJustNowModList()
  local FriendJustNowModList = {}
  if self.FriendPlayingList then
    for _, v in pairs(self.FriendPlayingList) do
      for mod_id, FriendData in pairs(v) do
        if not FriendData.IsPlaying and FriendData.end_time then
          FriendJustNowModList[mod_id] = true
        end
      end
    end
  end
  return FriendJustNowModList
end
function logic_ugc_mode:on_notify_group_status_chg(uid, status)
  if not self.FriendPlayingList then
    return
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  if self:FriendIsHidden(uid) or self:CheckFriendPrivacy(uid) then
    return
  end
  if PlayerStatusUtil.IsBattle(status) and status.mod_id then
    if not self.FriendPlayingList[uid] then
      self.FriendPlayingList[uid] = {}
    end
    self.FriendPlayingList[uid][status.mod_id] = {
      start_time = nNowTime,
      end_time = nil,
      from_uid = uid,
      IsPlaying = true,
      mod_id = status.mod_id
    }
  elseif not PlayerStatusUtil.IsBattle(status) and self.FriendPlayingList[uid] then
    for mod_id, data in pairs(self.FriendPlayingList[uid]) do
      if data.IsPlaying then
        data.end_time = nNowTime
        data.IsPlaying = false
      end
    end
    log(bWriteLog and "logic_ugc_mode:on_notify_group_status_chg GameOver uid = " .. uid .. ",mod_id = " .. status.mod_id)
  end
end
function logic_ugc_mode:IsModPlayedByFriend(mod_id)
  if not mod_id then
    return {type = 6}
  end
  local playingList = self:GetFriendPlayingModList()
  local justNowList = self:GetFriendJustNowModList()
  local result = {type = 6}
  if playingList[mod_id] then
    for uid, v in pairs(self.FriendPlayingList) do
      if v[mod_id] and v[mod_id].IsPlaying and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) then
        result.type = 1
        break
      end
    end
  elseif justNowList[mod_id] then
    local end_time = 0
    for uid, v in pairs(self.FriendPlayingList) do
      if v[mod_id] and v[mod_id].end_time and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) then
        end_time = v[mod_id].end_time
        result.type = 2
        result.        break
      end
    end
  else
    local displayData = self.displayFriendData[mod_id]
    if displayData then
      local validFriends = {}
      if displayData.uids then
        for _, uid in ipairs(displayData.uids) do
          if not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) then
            table.insert(validFriends, uid)
          end
        end
      end
      if 0 < #validFriends then
        if displayData.type == 1 then
          result.type = 3
        elseif displayData.type == 2 then
          result.type = 4
        elseif displayData.type == 3 then
          result.type = 5
        end
        result.display_num = #validFriends
      end
    end
  end
  return result
end
function logic_ugc_mode:GetClosestFriendByModId(mod_id, type)
  if not mod_id then
    return nil
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendMap = LogicFriend.GetAllFriendData()
  local closestFriend
  local maxIntimacy = -1
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local _GetFriendIntimacy = function(uid)
    local info = self:CheckFriendPrivacy(uid)
    if info then
      return nil
    end
    local friendInfo = FriendMap[uid]
    return friendInfo and friendInfo.intimacy
  end
  if self.FriendPlayingList then
    for from_uid, mod_data in pairs(self.FriendPlayingList) do
      if mod_data[mod_id] and (not type or type == 1 and mod_data[mod_id].IsPlaying or type == 2 and not mod_data[mod_id].IsPlaying and mod_data[mod_id].end_time) then
        local intimacy = _GetFriendIntimacy(from_uid)
        if intimacy and maxIntimacy < intimacy then
          maxIntimacy = intimacy
          closestFriend = from_uid
        end
      end
    end
  end
  local displayData = self.displayFriendData[mod_id]
  if displayData and displayData.uids and (not type or type == 4 and displayData.type == 2 or type == 5 and displayData.type == 3) then
    for _, uid in ipairs(displayData.uids) do
      local intimacy = _GetFriendIntimacy(uid)
      if intimacy and maxIntimacy < intimacy then
        maxIntimacy = intimacy
        closestFriend = uid
      end
    end
  end
  return closestFriend
end
function logic_ugc_mode:GetFriendsByType(type, modid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendMap = LogicFriend.GetAllFriendData()
  local result = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if type == 1 then
    if self.FriendPlayingList then
      for uid, mod_data in pairs(self.FriendPlayingList) do
        for mod_id, data in pairs(mod_data) do
          if data.IsPlaying and not self:CheckFriendPrivacy(uid) and not self:FriendIsHidden(data.from_uid) and mod_id == modid then
            table.insert(result, {
              uid = uid,
              intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
            })
          end
        end
      end
    end
  elseif type == 2 then
    if self.FriendPlayingList then
      for uid, mod_data in pairs(self.FriendPlayingList) do
        for mod_id, data in pairs(mod_data) do
          if not data.IsPlaying and data.end_time and not self:CheckFriendPrivacy(uid) and not self:FriendIsHidden(data.from_uid) and mod_id == modid then
            table.insert(result, {
              uid = uid,
              intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
            })
          end
        end
      end
    end
  elseif type == 3 then
    if self.displayFriendData then
      for mod_id, data in pairs(self.displayFriendData) do
        if data.type == 1 and data.uids and mod_id == modid then
          for _, uid in ipairs(data.uids) do
            if not self:CheckFriendPrivacy(uid) then
              table.insert(result, {
                uid = uid,
                intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
              })
            end
          end
        end
      end
    end
  elseif type == 4 then
    if self.displayFriendData then
      for mod_id, data in pairs(self.displayFriendData) do
        if data.type == 2 and data.uids and mod_id == modid then
          for _, uid in ipairs(data.uids) do
            if not self:CheckFriendPrivacy(uid) then
              table.insert(result, {
                uid = uid,
                intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
              })
            end
          end
        end
      end
    end
  elseif type == 5 and self.displayFriendData then
    for mod_id, data in pairs(self.displayFriendData) do
      if data.type == 3 and data.uids and mod_id == modid then
        for _, uid in ipairs(data.uids) do
          if not self:CheckFriendPrivacy(uid) then
            table.insert(result, {
              uid = uid,
              intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
            })
          end
        end
      end
    end
  end
  local uniqueResult = {}
  local seen = {}
  for _, friend in ipairs(result) do
    if not seen[friend.uid] then
      seen[friend.uid] = true
      table.insert(uniqueResult, friend)
    end
  end
  table.sort(uniqueResult, function(a, b)
    return a.intimacy > b.intimacy
  end)
  return uniqueResult
end
function logic_ugc_mode:CheckFriendPrivacy(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local info = logic_profile:GetLocalProfile(uid)
  if info and info.ugc_privacy_setting and info.ugc_privacy_setting.rec_display then
    log(bWriteLog and "logic_ugc_mode:CheckFriendPrivacy uid =  " .. uid .. "; privacy setting: true")
    return true
  end
  log(bWriteLog and "logic_ugc_mode:CheckFriendPrivacy uid =  " .. uid .. "; privacy setting: false")
  return false
end
function logic_ugc_mode:FriendIsHidden(uid)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local status = PlayerStatusMgr:GetStatusData(uid)
  local Stealth = PlayerStatusUtil.IsStealth(status)
  return Stealth
end
function logic_ugc_mode:GetWOWFriendList(mod_id, FriendList, IsOpen)
  local WOWFriendList = {}
  if not mod_id or not FriendList then
    log(bWriteLog and "logic_ugc_mode:GetWOWFriendList mod_id and FriendList is nil")
    return WOWFriendList
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendMap = LogicFriend.GetAllFriendData()
  if not FriendMap then
    return WOWFriendList
  end
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  local rank_list = LogicUGCModRank.rank_list or {}
  local interactedFriends = {}
  if self.FriendPlayingList then
    for uid, mod_data in pairs(self.FriendPlayingList) do
      if mod_data[mod_id] and mod_data[mod_id].IsPlaying and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) then
        interactedFriends[uid] = self.INTERACTION_TYPES.PLAYING
      end
    end
  end
  if self.FriendPlayingList then
    for uid, mod_data in pairs(self.FriendPlayingList) do
      if mod_data[mod_id] and not mod_data[mod_id].IsPlaying and mod_data[mod_id].end_time and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.JUST_PLAYED) then
        interactedFriends[uid] = self.INTERACTION_TYPES.JUST_PLAYED
      end
    end
  end
  local displayData = self.displayFriendData[mod_id]
  if displayData and displayData.type == 1 and displayData.uids then
    for _, uid in ipairs(displayData.uids) do
      if not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.PLAYED) then
        interactedFriends[uid] = self.INTERACTION_TYPES.PLAYED
      end
    end
  end
  if displayData and displayData.type == 2 and displayData.uids then
    for _, uid in ipairs(displayData.uids) do
      if not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.COLLECTED) then
        interactedFriends[uid] = self.INTERACTION_TYPES.COLLECTED
      end
    end
  end
  if displayData and displayData.type == 3 and displayData.uids then
    for _, uid in ipairs(displayData.uids) do
      if not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.RECOMMENDED) then
        interactedFriends[uid] = self.INTERACTION_TYPES.RECOMMENDED
      end
    end
  end
  for k, v in pairs(rank_list) do
    local uid = tonumber(v.uid)
    if uid and FriendMap[uid] and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.RANKING) then
      interactedFriends[uid] = self.INTERACTION_TYPES.RANKING
    end
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for uid, v in pairs(FriendMap) do
    local profile = logic_profile:GetLocalProfile(uid)
    if profile and profile.ugc_play_mod_data and profile.ugc_play_mod_data.play_mod_time and profile.ugc_play_mod_data.play_mod_time ~= 0 and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.PLAYWOW) then
      interactedFriends[uid] = self.INTERACTION_TYPES.PLAYWOW
    end
  end
  if self.FriendPlayingList then
    for uid, mod_data in pairs(self.FriendPlayingList) do
      if not mod_data[mod_id] and not self:FriendIsHidden(uid) and not self:CheckFriendPrivacy(uid) and (not interactedFriends[uid] or interactedFriends[uid] > self.INTERACTION_TYPES.JUST_PLAYWOW) then
        interactedFriends[uid] = self.INTERACTION_TYPES.JUST_PLAYWOW
      end
    end
  end
  local sortedFriends = {}
  for uid, type in pairs(interactedFriends) do
    table.insert(sortedFriends, {
      uid = uid,
      type = type,
      intimacy = FriendMap[uid] and FriendMap[uid].intimacy or 0
    })
  end
  table.sort(sortedFriends, function(a, b)
    return a.intimacy > b.intimacy
  end)
  for i, friend in ipairs(sortedFriends) do
    for k, v in pairs(FriendList) do
      if friend.uid == v.uid then
        WOWFriendList[i] = v
        WOWFriendList[i].type = friend.type
        WOWFriendList[i].      end
    end
  end
  local ReturnList = {}
  for k, v in pairs(WOWFriendList) do
    table.insert(ReturnList, v)
  end
  return ReturnList
end
function logic_ugc_mode:GetOnlinFriendIndex(Data)
  if not Data then
    return 0
  end
  local Index = 0
  for k, v in pairs(Data) do
    if v.online and v.online ~= 0 then
      Index = Index + 1
    end
  end
  return Index
end
function logic_ugc_mode:CheckOnLineList(Data)
  if not Data then
    return
  end
  local OnlineList = {}
  local OfflineList = {}
  local AnatherList = {}
  for k, v in pairs(Data) do
    if v.online and v.online == 0 and v.type ~= self.INTERACTION_TYPES.PLAYWOW and v.type ~= self.INTERACTION_TYPES.NONE and v.type ~= self.INTERACTION_TYPES.JUST_PLAYWOW then
      table.insert(OfflineList, v)
    elseif v.online and v.online ~= 0 and v.type ~= self.INTERACTION_TYPES.PLAYWOW and v.type ~= self.INTERACTION_TYPES.NONE and v.type ~= self.INTERACTION_TYPES.JUST_PLAYWOW then
      table.insert(OnlineList, v)
    end
  end
  local OfflineAnatherList = {}
  for k, v in pairs(Data) do
    if v.type == self.INTERACTION_TYPES.PLAYWOW or v.type == self.INTERACTION_TYPES.JUST_PLAYWOW then
      if v.online and v.online ~= 0 then
        table.insert(AnatherList, v)
      else
        table.insert(OfflineAnatherList, v)
      end
    end
  end
  for k, v in pairs(OfflineAnatherList) do
    table.insert(AnatherList, v)
  end
  return OnlineList, OfflineList, AnatherList
end
function logic_ugc_mode:GetFriendEndTimeByType(uid, mod_id, type, prifile)
  if not uid or not type then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  if type == self.INTERACTION_TYPES.PLAYING then
    if self.FriendPlayingList and self.FriendPlayingList[uid] and mod_id then
      local mod_data = self.FriendPlayingList[uid][mod_id]
      if mod_data then
        local Time = TimeUtil.GetServerTimeInSec()
        local startTimeStr = TimeUtil.GetTimeAgoStr(Time)
        return LocUtil.LocalizeResFormat(655654, startTimeStr)
      end
    end
    return nil
  end
  if type == self.INTERACTION_TYPES.JUST_PLAYED then
    if self.FriendPlayingList and self.FriendPlayingList[uid] and mod_id then
      local mod_data = self.FriendPlayingList[uid][mod_id]
      if mod_data and not mod_data.IsPlaying and mod_data.end_time then
        local endTimeStr = TimeUtil.GetTimeAgoStr(mod_data.end_time)
        if mod_data.outcome and mod_data.outcome == 0 then
          return LocUtil.LocalizeResFormat(655655, endTimeStr)
        else
          return LocUtil.LocalizeResFormat(655654, endTimeStr)
        end
      end
    end
    return nil
  end
  if (type == self.INTERACTION_TYPES.PLAYED or type == self.INTERACTION_TYPES.RECOMMENDED or type == self.INTERACTION_TYPES.COLLECTED or type == self.INTERACTION_TYPES.RANKING or type == self.INTERACTION_TYPES.PLAYWOW) and prifile and prifile.ugc_play_mod_data and prifile.ugc_play_mod_data.play_mod_time then
    local TimeUtil = require("client.common.time_util")
    local str = TimeUtil.GetTimeLengthStr(prifile.ugc_play_mod_data.play_mod_time)
    if str then
      return LocUtil.LocalizeResFormat(655656, str)
    end
  end
  if type == self.INTERACTION_TYPES.JUST_PLAYWOW and self.FriendPlayingList and self.FriendPlayingList[uid] then
    local latestEndTime = 0
    for _, mod_data in pairs(self.FriendPlayingList[uid]) do
      if mod_data.end_time and latestEndTime < mod_data.end_time then
        latestEndTime = mod_data.end_time
      elseif mod_data.start_time then
        latestEndTime = mod_data.start_time
      end
    end
    if 0 < latestEndTime then
      local endTimeStr = TimeUtil.GetTimeAgoStr(latestEndTime)
      return LocUtil.LocalizeResFormat(86354, endTimeStr)
    end
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_mode = class(CModuleBase, nil, logic_ugc_mode)
return Clogic_ugc_mode
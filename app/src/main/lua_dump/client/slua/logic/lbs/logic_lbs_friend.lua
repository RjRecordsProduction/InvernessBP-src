local LBSFriendMgr = {
  player_list = {},
  requestPlayerListTime = 0,
  Near_List = {},
  ResetOnLineStatusDir = {},
  ResetGroupStatusDir = {}
}
function LBSFriendMgr:OnLogin()
end
function LBSFriendMgr:Init()
end
function LBSFriendMgr:UpdatePlayerList(player_list)
  LBSFriendMgr.player_list = player_list or {}
  LBSFriendMgr.Near_List = {}
  LBSFriendMgr.requestPlayerListTime = FuncUtil.GetServerTimeInSec()
  local cb = function()
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    for i, uid in pairs(player_list) do
      LBSFriendMgr.Near_List[i] = logic_profile:GetLocalProfile(uid)
      local isOnline = LBSFriendMgr.ResetOnLineStatusDir[uid]
      if isOnline then
        LBSFriendMgr:UpdateFriendOnLineData(uid, isOnline, true)
      end
      local newStatus = LBSFriendMgr.ResetGroupStatusDir[uid]
      if newStatus then
        LBSFriendMgr:UpdateFriendGroupData(uid, newStatus, true)
      end
    end
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_LIST)
  end
  log_tree("[qintong] on_lbs_nearly_player_rsp player_list = ", LBSFriendMgr.Near_List)
  if player_list and 0 < #player_list then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(1200, player_list, cb, true)
  else
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_LIST)
  end
end
function LBSFriendMgr:IsNearsFriend(uid)
  for _, data in pairs(LBSFriendMgr.player_list) do
    if uid == data then
      return true
    end
  end
  return false
end
function LBSFriendMgr:GetNearPlayer(uid)
  local player
  for i, v in pairs(LBSFriendMgr.Near_List) do
    if v.uid == uid then
      player = v
      break
    end
  end
  return player
end
function LBSFriendMgr:UpdateFriendGroupData(uid, newStatus, delete)
  local bHave = false
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  for i, data in pairs(LBSFriendMgr.Near_List) do
    if uid == data.uid then
      bHave = true
      LBSFriendMgr.Near_List[i].      LBSFriendMgr.Near_List[i].teamState = newStatus.teamStateNew
      if PlayerStatusUtil.IsStealth(LBSFriendMgr.Near_List[i]) then
        LBSFriendMgr.Near_List[i].online = 0
      end
      LBSFriendMgr.Near_List[i].currentTeamAmount = newStatus.currentTeamAmount
      LBSFriendMgr.Near_List[i].maxTeamAmount = newStatus.maxTeamAmount
      LBSFriendMgr.Near_List[i].timeSinceGameBegin = newStatus.timeSinceGameBegin
      local TimeUtil = require("client.common.time_util")
      LBSFriendMgr.Near_List[i].timeSinceGameBeginStamp = newStatus.timeSinceGameBegin
      LBSFriendMgr.Near_List[i].game_mode = newStatus.game_mode
      LBSFriendMgr.Near_List[i].game_sub_mode = newStatus.game_sub_mode
      LBSFriendMgr.Near_List[i].enable_watch = newStatus.enable_watch
      LBSFriendMgr.Near_List[i].socialland_type = newStatus.socialland_type
      LBSFriendMgr.Near_List[i].game_id = newStatus.game_id
      LBSFriendMgr.Near_List[i].land_id = newStatus.land_id
      LBSFriendMgr.Near_List[i].tplan_type = newStatus.tplan_type
      LBSFriendMgr.Near_List[i].cwow_type = newStatus.cwow_type
      break
    end
  end
  if delete then
    LBSFriendMgr.ResetGroupStatusDir[uid] = nil
  elseif not bHave then
    LBSFriendMgr.ResetGroupStatusDir[uid] = newStatus
  end
end
function LBSFriendMgr:GetNearFriendList()
  return LBSFriendMgr.Near_List or {}
end
function LBSFriendMgr:ClearCache()
  if FuncUtil.GetServerTimeInSec() - LBSFriendMgr.requestPlayerListTime < 5 then
    return
  end
  LBSFriendMgr.Near_List = {}
end
function LBSFriendMgr:CanOpenNearFriend()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bCanSet = LbsMgr.CanSelectProvinceMyCountry(LbsMgr.SETTING_CFG_NEAR_ID)
  local bLabel = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_NEAR_ID)
  local bPower = LbsMgr.IsLbsSettingOpen(LbsMgr.SETTING_CFG_NEAR_ID)
  log(bWriteLog and "[qintong] CanOpenNearFriend" .. tostring(bCanSet) .. tostring(bLabel) .. tostring(bPower))
  return bCanSet and bLabel and bPower
end
function LBSFriendMgr:CanGetNearFriendList()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  if not LbsMgr.IsReady() then
    return false
  end
  return LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_NEAR_ID)
end
function LBSFriendMgr:UpdateFriendOnLineData(uid, isOnline, delete)
  local bHave = false
  for i, data in pairs(LBSFriendMgr.Near_List) do
    if uid == data.uid then
      bHave = true
      LBSFriendMgr.Near_List[i].      LBSFriendMgr.Near_List[i].online = isOnline
      if isOnline == 0 then
        LBSFriendMgr.Near_List[i].tplan_type = 0
        break
      end
      LBSFriendMgr.Near_List[i].teamState = 0
      break
    end
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if status and status.online ~= isOnline then
    status.online = isOnline
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_STATUS)
  end
  if delete then
    LBSFriendMgr.ResetOnLineStatusDir[uid] = nil
  elseif not bHave then
    LBSFriendMgr.ResetOnLineStatusDir[uid] = isOnline
  end
end
return LBSFriendMgr
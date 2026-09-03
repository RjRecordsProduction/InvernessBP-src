local AssemblyActivitySystem_JK = {}
function AssemblyActivitySystem_JK:DefineAndResetData()
  AssemblyActivitySystem_JK.__super.DefineAndResetData(self)
  self.activityData = {}
  self.cacheInviteCode = nil
end
function AssemblyActivitySystem_JK:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_ASSEMBLY_SHARE_JK, self.OnReturnToSendBind, self)
end
function AssemblyActivitySystem_JK:OnLogOut()
end
function AssemblyActivitySystem_JK:OnReturnToSendBind(_, _, vars)
  log_tree("OnReturnToSendBind", vars)
  if not vars or not GlobalData.IsJapanOrKorea() then
    return
  end
  if vars and vars.invitecode and tostring(vars.invitecode) ~= "" then
    self.cacheInviteCode = vars.invitecode
    log(bWriteLog and "[YY]SendAssemblyReply====" .. tostring(555555555))
    self:SendAssemblyReply()
  end
end
function AssemblyActivitySystem_JK:SendAssemblyReply()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if ActivityNewSystem.bIsInit and GameStatus.IsInLobbyOrMainCity() and self.cacheInviteCode then
    local AssemblyHandler = require("client.network.Protocol.AssemblyHandler")
    AssemblyHandler.send_on_jpkr_assemb_reply(tostring(self.cacheInviteCode))
    self.cacheInviteCode = nil
    log(bWriteLog and "[YY]SendAssemblyReply====" .. tostring(666666666666))
    local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
    AdjustSystem:ClearAdjustDeepLink()
  end
end
function AssemblyActivitySystem_JK:ShowShare(shareCfg, childUiCfg, ...)
  local shareUI = UIManager.ShowUI(UIManager.UI_Config.assembly_share_component_jk, shareCfg)
  if childUiCfg then
    childUiCfg.isMainUI = false
    shareUI:CreateChildWindow("NamedSlot_Holder", childUiCfg, ...)
  end
end
function AssemblyActivitySystem_JK:GetPlayerData()
  local data = self:GetActivityData()
  log_tree("AssemblyActivitySystem_JK:GetPlayerData", data)
  local invite_list = self:GetInviteList()
  local my_invite = self:GetMyInviteData()
  local total_list = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if 0 < #invite_list then
    for _, uid in ipairs(invite_list) do
      local isFriend = LogicFriend.IsMyFriend(uid)
      if not isFriend and uid ~= my_invite then
        table.insert(total_list, uid)
      end
    end
  end
  if not LogicFriend.IsMyFriend(my_invite) and my_invite and 0 < my_invite then
    table.insert(total_list, my_invite)
  end
  if total_list and next(total_list) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(total_list, nil, Enum_PROFILE_REPORT_CFG.COMEBACK_JK)
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.AssemblyActivitySystem_JK, total_list, function()
      EventSystem:postEvent(EVENTTYPE_ASSEMBLY, EVENTID_ASSEMBLY_ACTIVITY_REFRESH_ONLINE_STATE)
    end)
  end
end
function AssemblyActivitySystem_JK:GetInviteList()
  local data = self:GetActivityData()
  local invite_list = data and data.other and data.other.invite_list or {}
  return invite_list
end
function AssemblyActivitySystem_JK:GetMyInviteData()
  local data = self:GetActivityData()
  local my_invite = data and data.other and data.other.my_inviter or 0
  return my_invite
end
function AssemblyActivitySystem_JK:GetActivityData()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = logic_activity_mgr.GetActivityByType(ActivityType.ASSEMBLY_FRIEND_JK)
  return activityData
end
function AssemblyActivitySystem_JK:GetActivitySubData_Assembly()
  local activityData = self:GetActivityData()
  if not activityData or not GlobalData.IsJapanOrKorea() then
    log(bWriteLog and "AssemblyActivitySystem_JK:GetActivitySubData_Assembly. has not activityData or isn't in jk!")
    return
  end
  local TimeUtil = require("client.common.time_util")
  if type(activityData.EndTime) == "number" and activityData.EndTime < TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and string.format("AssemblyActivitySystem_JK:GetActivitySubData_Assembly. Time is invalid! EndTime:%s", activityData.EndTime))
    return
  end
  return {
    nActID = activityData.ID,
    sName = activityData.Title or LocUtil.GetLocalizeResStr(6992),
    bRedDot = self.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = activityData.StartTime or 0
  }
end
function AssemblyActivitySystem_JK:GetShareUrl(channelType)
  local ShareMgr = require("client.logic.share.share_logic")
  local imgUrl = self:GetImagUrl()
  local shareTitle = self:GetShareTitle()
  local shareContent = self:GetShareContent()
  local acceptor = self:GetModuleParams()
  return ShareMgr.GetDefaultShareUrl(imgUrl, shareTitle, shareContent, nil, acceptor, nil, channelType)
end
function AssemblyActivitySystem_JK:GetShareTitle()
  local inviteCode = self:GetInviteCode()
  local shareTitle = LocUtil.LocalizeResFormat(8451, inviteCode)
  local activityData = self:GetActivityData()
  if activityData and activityData.ExParam and activityData.ExParam ~= "" then
    shareTitle = activityData.ExParam
  end
  return shareTitle
end
function AssemblyActivitySystem_JK:GetShareContent()
  local inviteCode = self:GetInviteCode()
  local shareContent = LocUtil.LocalizeResFormat(8451, inviteCode)
  local activityData = self:GetActivityData()
  if activityData and activityData.ExParam and activityData.ExParam ~= "" then
    shareContent = activityData.ExParam
  end
  return shareContent
end
function AssemblyActivitySystem_JK:GetImagUrl()
  local imgUrl = FuncUtil.GetDomainByID(3366028) .. "/images%2F20191119%2Figshare677190177928081574183076.jpg"
  local activityData = self:GetActivityData()
  local util = require("client.slua_ui_framework.util")
  if activityData and activityData.EntryImageUrl and activityData.EntryImageUrl ~= "" and util.IsOnlineImageUrl(activityData.EntryImageUrl) then
    imgUrl = activityData.EntryImageUrl
  end
  return imgUrl
end
function AssemblyActivitySystem_JK:GetModuleParams()
  local acceptor = "module=20046&uid=%s&invitecode=%s"
  local inviteCode = self:GetInviteCode()
  acceptor = string.format(acceptor, tostring(DataMgr.roleData.uid), tostring(inviteCode))
  return acceptor
end
function AssemblyActivitySystem_JK:GetInviteCode()
  local StringUtil = require("common.string_util")
  local uid = tonumber(DataMgr.roleData.uid) or 0
  return StringUtil.uid_to_short_code(uid)
end
function AssemblyActivitySystem_JK:HasRedDot()
  return true
end
function AssemblyActivitySystem_JK:on_jpkr_assemb_rsp(err_code, inviter_id)
  self:ShowTips(err_code, inviter_id)
end
function AssemblyActivitySystem_JK:on_jpkr_assemb_award_notify(inviter_id)
  self:ShowTips(48694, inviter_id)
end
function AssemblyActivitySystem_JK:on_jpkr_assemb_bind_notify(invitee_id)
  self:ShowTips(48698, invitee_id)
end
function AssemblyActivitySystem_JK:ShowTips(err_code, player_uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if player_uid and tonumber(player_uid) > 0 then
    local profile = logic_profile:GetLocalProfile(tonumber(player_uid))
    if profile and profile.nickName then
      self:HandleErrorCode(err_code, profile.nickName, player_uid)
    else
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles({
        tonumber(player_uid)
      }, function(list)
        if 1 <= #list then
          self:HandleErrorCode(err_code, list[1].nickName, player_uid)
        end
      end, Enum_PROFILE_REPORT_CFG.COMEBACK_JK)
    end
  end
end
function AssemblyActivitySystem_JK:HandleErrorCode(err_code, playerName, player_uid)
  if err_code == 0 then
    local noticeId = LocUtil.LocalizeResFormat(48690, playerName)
    ShowNotice(noticeId)
  elseif err_code == 18060001 then
    local noticeId = LocUtil.LocalizeResFormat(48690, playerName)
    ShowNotice(noticeId)
  elseif err_code == 18060002 then
    local noticeId = LocUtil.LocalizeResFormat(48692, playerName)
    ShowNotice(noticeId)
  elseif err_code == 18060003 then
    local noticeId = LocUtil.LocalizeResFormat(48693, playerName)
    ShowNotice(noticeId)
  elseif err_code == 18060004 then
    ShowNotice(48695)
  elseif err_code == 18060005 then
    ShowNotice(48696)
  elseif err_code == 18060006 then
    if player_uid == DataMgr.roleData.uid then
      ShowNotice(120111)
    else
      ShowNotice(13011)
    end
  elseif err_code == 48694 or err_code == 48698 then
    local noticeId = LocUtil.LocalizeResFormat(err_code, playerName)
    ShowNotice(noticeId)
  else
    ShowNotice(err_code)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CAssemblyActivitySystem_JK = class(CModuleBase, nil, AssemblyActivitySystem_JK)
return CAssemblyActivitySystem_JK
local SocialIslandHandler = {
  createIslandCardItemId = 2112001,
  inviter_uid = 0,
  socialland_info = nil,
  socialland_id = nil,
  pvt_socialland_info = nil,
  cur_pvt_socialland_info = nil,
  apply_list = nil,
  invitee_list = nil,
  authority_type = nil,
  is_apply_on_info = {
    [0] = 0,
    [1] = 0
  },
  socialIslandSubMode = {
    [21001] = true,
    [21003] = true
  },
  socialIslandPrivateSubMode = {
    [21002] = true,
    [21004] = true
  },
  NEWBIE_GUIDE_MATCH = 1,
  NEWBIE_GUIDE_EVERYDAY_MISSION = 2,
  NEWBIE_GUIDE_TECH = 3,
  NEWBIE_GUIDE_HOME_TIPS = 4,
  NEWBIE_PSO = 101,
  NEWBIE_STORE_310 = 102,
  ignoreInviteMap = {},
  ignoreMaxTime = 300,
  maxMemberNum = 40,
  hallNewbieTipLevelLimit = 5,
  FACE_SLAP_MAGIC_WISH = 1,
  CurReqRacingVehicleId = nil
}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local NetManager = require("client.network.comm.NetManager")
function SocialIslandHandler.Init()
end
function SocialIslandHandler.send_socialland_invite_req(invitee_uid)
  log_tree("SocialIslandHandler.send_socialland_invite_req invitee_uid = ", invitee_uid)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.SocialIsland) then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    ShowNotice(27572)
    return false
  end
  NetManager.SendPkg(165014355, invitee_uid)
end
function SocialIslandHandler.on_socialland_invite_rsp(ok, inviter_uid, invitee_uid)
  log_tree("SocialIslandHandler.on_socialland_invite_rsp ok = ", ok)
  log_tree("SocialIslandHandler.on_socialland_invite_rsp inviter_uid = ", inviter_uid)
  log_tree("SocialIslandHandler.on_socialland_invite_rsp invitee_uid = ", invitee_uid)
  SocialIslandHandler.  if ok ~= 0 then
    if ok == 100110131 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.SocialIsland)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.SocialIsland)
      end
    elseif ok == 100110132 then
      ShowNotice(22007)
    else
      ShowNotice(ok)
    end
    return
  end
  ShowNotice(301265)
end
function SocialIslandHandler.on_socialland_invite_notify(inviter_uid, socialland_info)
  log_tree("SocialIslandHandler.on_socialland_invite_notify socialland_info = ", socialland_info)
  SocialIslandHandler.  SocialIslandHandler.  if IsWoWEditor then
    return
  end
  local ignoreTime = SocialIslandHandler.ignoreInviteMap[inviter_uid]
  if ignoreTime then
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.GetServerTimeInSec()
    if tNow - ignoreTime <= SocialIslandHandler.ignoreMaxTime then
      log(bWriteLog and "SocialIslandHandler ignore invite " .. tostring(inviter_uid))
      return
    end
  end
  if not SocialIslandHandler.HaveDownloadSocialIsland(inviter_uid) then
    log(bWriteLog and "SocialIslandHandler.on_socialland_invite_notify not download")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.SocialIsland_Invite_Notify_UIBP, socialland_info, inviter_uid)
end
function SocialIslandHandler.send_socialland_invitee_confirm_req(inviter_uid, is_confuse, pvt_island_id)
  log(bWriteLog and "SocialIslandHandler.send_socialland_invitee_confirm_req")
  if not is_confuse then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:IsRestrictBatlleAll() then
      QRcodeRestrictManager:ShowRestrictTips()
      return
    end
  end
  NetManager.SendPkg(1215265863, inviter_uid, is_confuse, pvt_island_id)
end
function SocialIslandHandler.on_socialland_invitee_confirm_rsp(ok, inviter_uid, invitee_uid, is_confuse, is_same_shadow)
  print(bWriteLog and string.format("SocialIslandHandler.on_socialland_invitee_confirm_rsp ok:%s, inviter_uid:%s, invitee_uid:%s, is_confuse:%s, is_same_shadow:%s", ok, inviter_uid, invitee_uid, is_confuse, is_same_shadow))
  if ok ~= 0 then
    if ok == 100110131 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.SocialIsland)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.SocialIsland)
      end
    elseif ok == 100110132 then
      ShowNotice(22007)
    else
      ShowNotice(ok)
    end
    return
  end
  if inviter_uid == 0 and SocialIslandHandler.cur_pvt_socialland_info and not is_confuse then
    SocialIslandHandler.send_socialland_enter_req(SocialIslandHandler.cur_pvt_socialland_info)
  else
    EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_NEW_INVITE_CONFIRM, invitee_uid)
  end
  if false == is_same_shadow then
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if PlanPH_GamePlay_Tools.IsPHomeMode() then
      BattleResult.IgnoreDSError = true
    else
      ShowNotice(47313)
    end
  end
  log(bWriteLog and "SocialIslandHandler.on_socialland_invitee_confirm_rsp myuid = " .. DataMgr.roleData.uid .. " " .. inviter_uid)
  local myUid = DataMgr.roleData.uid
  if tostring(myUid) == tostring(inviter_uid) then
    if is_confuse then
      local func = function()
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        local playerInfo = logic_profile:GetLocalProfile(invitee_uid)
        local tips = LocUtil.LocalizeResFormat(9724, playerInfo.nickName)
        ShowNotice(tips)
      end
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles({invitee_uid}, function(listInfo)
        func()
      end, Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_PAK)
    else
      local func = function()
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        local playerInfo = logic_profile:GetLocalProfile(invitee_uid)
        local tips = LocUtil.LocalizeResFormat(100110023, playerInfo.nickName)
        ShowNotice(tips)
      end
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles({invitee_uid}, function(listInfo)
        func()
      end, Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_PAK)
    end
  end
end
function SocialIslandHandler.send_socialland_enter_req(socialland_info)
  if LobbySystem.isInMatch then
    ShowNotice(9938)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.SocialIsland) then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local home_macros = require("client.slua.logic.home.home_macros")
  if LogicUGCMatch:GetMatchModID() > 0 and LogicUGCMatch:GetMatchModID() ~= 26000 and LogicUGCMatch:GetMatchModID() == home_macros.Home_SubMode.Visit then
    ShowNotice(48409)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    ShowNotice(27572)
    return
  end
  log_tree("SocialIslandHandler.send_socialland_enter_req", socialland_info)
  if socialland_info then
    NetManager.SendPkg(1667434087, socialland_info)
  end
  if socialland_info.owner and socialland_info.owner ~= 0 then
    SocialIslandHandler.IsEnteringPvt = true
  else
    SocialIslandHandler.IsEnteringPvt = false
  end
  SocialIslandHandler.TmpCurPvtModeID = socialland_info.sub_mode or 21001
end
function SocialIslandHandler.on_socialland_enter_rsp(ok, fromType)
  log(bWriteLog and "SocialIslandHandler.on_socialland_enter_rsp ok = " .. tostring(ok))
  if ok ~= 0 then
    if SocialIslandHandler.CheckStartMatch(ok, fromType) then
      return
    end
    if ok == 100110131 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.SocialIsland)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.SocialIsland)
      end
    elseif ok == 100110132 then
      ShowNotice(22007)
    elseif ok == 100110026 then
      ShowNotice(75229)
    else
      ShowNotice(ok)
    end
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SetInGameModeID(SocialIslandHandler.TmpCurPvtModeID)
end
function SocialIslandHandler.send_socialland_apply_req(respondent_uid, followParam, fromType)
  if LobbySystem.isInMatch then
    printf("SocialIslandHandler.send_socialland_apply_req return, LobbySystem.isInMatch")
    ShowNotice(9938)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    printf("SocialIslandHandler.send_socialland_apply_req return, not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland)")
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    printf("SocialIslandHandler.send_socialland_apply_req return, LogicTxMissionMain.IsInXMission()")
    ShowNotice(33631)
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    printf("SocialIslandHandler.send_socialland_apply_req return, QRcodeRestrictManager:IsRestrictBatlleAll()")
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if not SocialIslandHandler.HaveDownloadSocialIsland() then
    printf("SocialIslandHandler.send_socialland_apply_req return, not SocialIslandHandler.HaveDownloadSocialIsland()")
    return
  end
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.SocialIsland) then
    printf("SocialIslandHandler.send_socialland_apply_req return, not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.SocialIsland)")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    printf("SocialIslandHandler.send_socialland_apply_req return, TeamUpNewSystem.IsInLargeTeam()")
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    printf("SocialIslandHandler.send_socialland_apply_req return, logic_mode_selection:IsSelect8PlayersMode()")
    ShowNotice(27572)
    return false
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    BattleResult.IgnoreDSError = true
  end
  NetManager.SendPkg(250873767, respondent_uid, followParam, fromType)
end
function SocialIslandHandler.on_socialland_apply_rsp(ok, respondent_uid, fromType, sub_mode)
  log(bWriteLog and "SocialIslandHandler.on_socialland_apply_rsp ok = " .. tostring(ok))
  log(bWriteLog and "SocialIslandHandler.on_socialland_apply_rsp respondent_uid = " .. tostring(respondent_uid))
  log(bWriteLog and "SocialIslandHandler.on_socialland_apply_rsp sub_mode = " .. tostring(sub_mode))
  if ok ~= 0 then
    BattleResult.IgnoreDSError = false
    if SocialIslandHandler.CheckStartMatch(ok, fromType) then
      return
    end
    if ok == 100110131 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.SocialIsland)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.SocialIsland)
      end
    elseif ok == 100110132 then
      ShowNotice(22007)
    elseif ok == 100210135 then
      ShowNotice(47313)
    elseif ok == 100110026 then
      ShowNotice(75229)
    else
      ShowNotice(ok)
    end
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SetInGameModeID(sub_mode)
end
function SocialIslandHandler.HaveDownloadSocialIsland(friendUid, bDontShowTips)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    "map_socialisland"
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "SocialIslandHandler.HaveDownloadSocialIsland map_socialisland state = " .. tostring(state))
    if not bDontShowTips then
      local content = LocUtil.LocalizeResFormat(11431)
      if friendUid then
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        local profile = logic_profile:GetLocalProfile(friendUid)
        if profile then
          content = LocUtil.LocalizeResFormat(11430, profile.nickName)
        end
      end
      local clickOkCallback = function()
        local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
        PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
          "map_socialisland"
        }, PufferTlog.Enum_TLog_From.Click)
      end
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, nil, content, clickOkCallback, nil, nil, nil, {
        showUIKey = "com_msg_small_box_slua"
      })
    end
    return false
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  PufferMapManager:UploadClientMapState()
  return true
end
function SocialIslandHandler.HaveDownloadSingleTraining(bDontShowTips)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    "map_singletraining"
  })
  if state ~= ENUM_DownloadState.Done then
    log(bWriteLog and "SocialIslandHandler.HaveDownloadSocialIsland map_singletraining state = " .. tostring(state))
    if not bDontShowTips then
      local clickOkCallback = function()
        local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
        PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {
          "map_singletraining"
        }, PufferTlog.Enum_TLog_From.Click)
      end
      local content = LocUtil.LocalizeResFormat(33085)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, nil, content, clickOkCallback, nil, nil, nil, {
        showUIKey = "com_msg_small_box_slua"
      })
    end
    return false
  end
  return true
end
function SocialIslandHandler.TryEnterSystemIsland()
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SOCIAL_ISLAND_SWITCH, true) then
    return false
  end
  if LobbySystem.isInMatch then
    ShowNotice(9938)
    return false
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return false
  end
  if not SocialIslandHandler.HaveDownloadSocialIsland() then
    return false
  end
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.SocialIsland) then
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    ShowNotice(27572)
    return false
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:GetMatchModID() > 0 then
    ShowNotice(48409)
    return false
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
    return false
  end
  return true
end
function SocialIslandHandler.ReqEnterSystemIsland(reason, enter_from)
  if false == SocialIslandHandler.TryEnterSystemIsland() then
    return false
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.bIsMatchingSocialIsland = true
  MatchModeMgrSystem.EnterSocialIslandReason = reason
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_on_match_req(321, 0, {21001}, DeviceOSInfo.InfoList, enter_from)
  return true
end
function SocialIslandHandler.TestJoinFriend()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local list = logic_new_friend.GetFriendList(false)
  local uid = list[1].uid
  if uid then
    SocialIslandHandler.send_socialland_apply_req(uid)
  end
end
function SocialIslandHandler.TestInviteFriend()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local list = logic_new_friend.GetFriendList(false)
  log_tree("SocialIslandHandler.TestInviteFriend list = ", list)
  local uid = list[1].uid
  if uid then
    SocialIslandHandler.send_socialland_invite_req(uid)
  end
end
function SocialIslandHandler.send_get_socialland_status_req(target_uid)
  NetManager.SendPkg(612547011, target_uid)
end
function SocialIslandHandler.on_get_socialland_status_rsp(res, target_uid, result)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  logic_island_status:on_get_socialland_status_rsp(res, target_uid, result)
end
function SocialIslandHandler.send_create_pvt_socialland_req(param_tb)
  log_tree("SocialIslandHandler.send_create_pvt_socialland_req param_tb = ", param_tb)
  if LobbySystem.isInMatch then
    ShowNotice(9938)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if not SocialIslandHandler.HaveDownloadSocialIsland() then
    return
  end
  NetManager.SendPkg(1314850099, param_tb)
end
function SocialIslandHandler.on_create_pvt_socialland_rsp(res, pvt_socialland_info)
  log_tree("SocialIslandHandler.on_create_pvt_socialland_rsp res = ", res)
  log_tree("SocialIslandHandler.on_create_pvt_socialland_rsp pvt_socialland_info = ", pvt_socialland_info)
  if res ~= 0 then
    if res == 100110131 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.SocialIsland)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.SocialIsland)
      end
    elseif res == 100110132 then
      ShowNotice(22007)
    else
      ShowNotice(res)
    end
    return
  end
  SocialIslandHandler.  SocialIslandHandler.cur_  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SetInGameModeID(pvt_socialland_info.sub_mode)
end
function SocialIslandHandler.on_notify_socialland_loading(uid, socialland_id)
  log_tree("SocialIslandHandler.on_notify_socialland_loading uid = ", uid)
  log_tree("SocialIslandHandler.on_notify_socialland_loading socialland_id = ", socialland_id)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
end
function SocialIslandHandler.on_notify_pvt_socialland_data(socialland_id, pvt_socialland)
  log_tree("SocialIslandHandler.on_notify_pvt_socialland_data socialland_id = ", socialland_id)
  log_tree("SocialIslandHandler.on_notify_pvt_socialland_data pvt_socialland = ", pvt_socialland)
  SocialIslandHandler.  SocialIslandHandler.pvt_socialland_info = pvt_socialland
  if not SocialIslandHandler.pvt_socialland_info and SocialIslandHandler.cur_pvt_socialland_info then
    log(bWriteLog and "SocialIslandHandler.on_notify_pvt_socialland_data1")
    if SocialIslandHandler.cur_pvt_socialland_info.owner == DataMgr.roleData.uid then
      log(bWriteLog and "SocialIslandHandler.on_notify_pvt_socialland_data2")
      SocialIslandHandler.cur_pvt_socialland_info = nil
    end
  elseif SocialIslandHandler.pvt_socialland_info and not SocialIslandHandler.cur_pvt_socialland_info then
    log(bWriteLog and "SocialIslandHandler.on_notify_pvt_socialland_data3")
    SocialIslandHandler.cur_pvt_socialland_info = SocialIslandHandler.pvt_socialland_info
  end
end
function SocialIslandHandler.on_pvt_socialland_apply_rsp(res, respondent_uid)
  log_tree("SocialIslandHandler.on_pvt_socialland_apply_rsp res = ", res)
  log_tree("SocialIslandHandler.on_pvt_socialland_apply_rsp respondent_uid = ", respondent_uid)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  ShowNotice(9836)
end
function SocialIslandHandler.on_notify_socialland_owner_apply(socialland_id, applicant_uid)
  log_tree("SocialIslandHandler.on_notify_socialland_owner_apply socialland_id = ", socialland_id)
  log_tree("SocialIslandHandler.on_notify_socialland_owner_apply applicant_uid = ", applicant_uid)
  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_NEW_ENTER_APPLICATION)
end
function SocialIslandHandler.send_pvt_socialland_process_applyer_req(apply_uid, opt)
  log_tree("SocialIslandHandler.send_pvt_socialland_process_applyer_req apply_uid = ", apply_uid)
  log_tree("SocialIslandHandler.send_pvt_socialland_process_applyer_req opt = ", opt)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(336249575, apply_uid, opt)
end
function SocialIslandHandler.on_pvt_socialland_process_applyer_rsp(res, apply_uid, opt)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_applyer_rsp res = ", res)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_applyer_rsp apply_uid = ", apply_uid)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_applyer_rsp opt = ", opt)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  SocialIslandHandler.apply_list[apply_uid] = nil
  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_PVT_INFO_LIST)
end
function SocialIslandHandler.on_pvt_socialland_invite_rsp(res, invitee_uid)
  log_tree("SocialIslandHandler.on_pvt_socialland_invite_rsp res = ", res)
  log_tree("SocialIslandHandler.on_pvt_socialland_invite_rsp invitee_uid = ", invitee_uid)
  if res ~= 0 then
    if res == 100210135 then
      ShowNotice(47313)
    else
      ShowNotice(res)
    end
    return
  end
  ShowNotice(301265)
end
function SocialIslandHandler.send_pvt_socialland_process_invitee_req(invitee_uid, opt)
  log_tree("SocialIslandHandler.send_pvt_socialland_process_invitee_req invitee_uid = ", invitee_uid)
  log_tree("SocialIslandHandler.send_pvt_socialland_process_invitee_req opt = ", opt)
  if LobbySystem.isInMatch then
    ShowNotice(9938)
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(1702022727, invitee_uid, opt)
end
function SocialIslandHandler.on_pvt_socialland_process_invitee_rsp(res, invitee_uid, opt)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_invitee_rsp res = ", res)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_invitee_rsp invitee_uid = ", invitee_uid)
  log_tree("SocialIslandHandler.on_pvt_socialland_process_invitee_rsp opt = ", opt)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  if opt == 0 then
  else
    local func = function()
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local playerInfo = logic_profile:GetLocalProfile(invitee_uid)
      local tips = LocUtil.LocalizeResFormat(100110023, playerInfo.nickName)
      ShowNotice(tips)
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({invitee_uid}, function(listInfo)
      func()
    end, Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_PAK)
  end
  SocialIslandHandler.invitee_list[invitee_uid] = nil
  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_PVT_INFO_LIST)
end
function SocialIslandHandler.on_pvt_socialland_info_notify(intivee_uid, socialland_info, socialland_owner_id, is_no_res)
  log_tree("SocialIslandHandler.on_pvt_socialland_info_notify intivee_uid = ", intivee_uid)
  log_tree("SocialIslandHandler.on_pvt_socialland_info_notify socialland_info = ", socialland_info)
  log_tree("SocialIslandHandler.on_pvt_socialland_info_notify socialland_owner_id = ", socialland_owner_id)
  if not SocialIslandHandler.HaveDownloadSocialIsland() then
    return
  end
  SocialIslandHandler.inviter_uid = intivee_uid
  SocialIslandHandler.NotifyInfo = socialland_info
  SocialIslandHandler.cur_pvt_  SocialIslandHandler.  local func = function()
    if is_no_res then
      return
    end
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local playerInfo = logic_profile:GetLocalProfile(socialland_owner_id)
    if playerInfo == nil then
      return
    end
    local info = {
      onCancel = function()
        log(bWriteLog and "SocialIslandHandler pvt invite disagree " .. SocialIslandHandler.inviter_uid .. " " .. socialland_info.custom_room_id)
        SocialIslandHandler.send_socialland_invitee_confirm_req(SocialIslandHandler.inviter_uid, true, socialland_info.custom_room_id)
      end,
      onConfirm = function()
        log(bWriteLog and "SocialIslandHandler pvt invite agree")
        if LobbySystem.isInMatch then
          ShowNotice(9938)
          return
        end
        local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
        if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
          ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
          return
        end
        SocialIslandHandler.send_socialland_invitee_confirm_req(SocialIslandHandler.inviter_uid, false, socialland_info.custom_room_id)
      end,
      strCancel = LocUtil.GetLocalizeResStr(110035),
      strConfirm = LocUtil.GetLocalizeResStr(117035),
      strTipFormat = LocUtil.LocalizeResFormat(9939, playerInfo.nickName),
      nTotoalSec = 10
    }
    UIManager.ShowUI(UIManager.UI_Config.Common_MsgBox_With_TimeOut_UIBP, info)
  end
  if tonumber(intivee_uid) == 0 then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({socialland_owner_id}, function(listInfo)
      func()
    end, Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_PAK)
  else
    if IsWoWEditor then
      return
    end
    local ignoreTime = SocialIslandHandler.ignoreInviteMap[intivee_uid]
    if ignoreTime then
      local TimeUtil = require("client.common.time_util")
      local tNow = TimeUtil.GetServerTimeInSec()
      if tNow - ignoreTime <= SocialIslandHandler.ignoreMaxTime then
        log(bWriteLog and "SocialIslandHandler ignore invite " .. tostring(intivee_uid))
        return
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.SocialIsland_Invite_Notify_UIBP, socialland_info, intivee_uid)
  end
end
function SocialIslandHandler.send_get_pvt_socialland_list_info_req()
  NetManager.SendPkg(1077760103)
end
function SocialIslandHandler.on_get_pvt_socialland_list_info_rsp(res, apply_list, invitee_list, authority_type)
  log_tree("SocialIslandHandler.on_get_pvt_socialland_list_info_rsp res = ", res)
  log_tree("SocialIslandHandler.on_get_pvt_socialland_list_info_rsp apply_list = ", apply_list)
  log_tree("SocialIslandHandler.on_get_pvt_socialland_list_info_rsp invitee_list = ", invitee_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  SocialIslandHandler.  SocialIslandHandler.  SocialIslandHandler.  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_PVT_INFO_LIST)
end
function SocialIslandHandler.send_get_target_history_record_req(uid)
  log_tree("SocialIslandHandler.send_get_target_history_record_req uid", uid)
  uid = tonumber(uid)
  NetManager.SendPkg(934296399, uid)
end
function SocialIslandHandler.on_get_target_history_record_rsp(ok, history_record)
  log_tree("SocialIslandHandler.on_get_target_history_record_rsp ok", ok)
  log_tree("SocialIslandHandler.on_get_target_history_record_rsp history_record", history_record)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  if history_record then
    table.sort(history_record, function(Data1, Data2)
      return Data1.record.id < Data2.record.id
    end)
    SocialIslandHandler.my_  end
end
function SocialIslandHandler.send_sociallland_kickout_player_req(kickout_uid)
  log(bWriteLog and "SocialIslandHandler.send_sociallland_kickout_player_req")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(1068349863, kickout_uid)
end
function SocialIslandHandler.on_sociallland_kickout_player_rsp(res, socialland_id, kickout_uid)
  if res ~= 0 then
    ShowNotice(res)
    return
  else
    log(bWriteLog and "SocialIslandHandler.on_sociallland_kickout_player_rsp socialland_id = " .. tostring(socialland_id))
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(kickout_uid)
    if profile then
      ShowNotice(LocUtil.LocalizeResFormat(9862, profile.nickName))
    end
  end
end
function SocialIslandHandler.send_get_apply_onoff_req()
  NetManager.SendPkg(2140041147)
end
function SocialIslandHandler.on_get_apply_onoff_rsp(ok, is_apply_on)
  log_tree("SocialIslandHandler.on_get_apply_onoff_rsp is_apply_on = ", is_apply_on)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  SocialIslandHandler.is_apply_on_info = is_apply_on
  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_GET_APPLY_ONOFF)
end
function SocialIslandHandler.send_set_apply_onoff_req(is_friend, is_on)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(246980235, is_friend, is_on)
end
function SocialIslandHandler.on_set_apply_onoff_rsp(ok, is_friend, is_on)
  log_tree("SocialIslandHandler.on_set_apply_onoff_rsp ok = ", ok)
  log_tree("SocialIslandHandler.on_set_apply_onoff_rsp is_friend = ", is_friend)
  log_tree("SocialIslandHandler.on_set_apply_onoff_rsp is_on = ", is_on)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  SocialIslandHandler.is_apply_on_info[is_friend] = is_on
  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_SET_APPLY_ONOFF, is_friend)
end
function SocialIslandHandler.send_set_pvt_socialland_authority_req(authority_type)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(850730727, authority_type)
end
function SocialIslandHandler.on_set_pvt_socialland_authority_rsp(res, authority_type)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  SocialIslandHandler.  EventSystem:postEvent(EVENTID_SOCIAL_EVENT, EVENTID_SOCIAL_EVENT_PVT_INFO_LIST)
end
function SocialIslandHandler.send_get_duel_history_record_req(uid)
  log_tree("SocialIslandHandler.send_get_duel_history_record_req uid", uid)
  uid = tonumber(uid)
  NetManager.SendPkg(551737091, uid)
end
function SocialIslandHandler.on_get_duel_history_record_rsp(ok, history_record)
  log_tree("SocialIslandHandler.on_get_duel_history_record_rsp ok", ok)
  log_tree("SocialIslandHandler.on_get_duel_history_record_rsp history_record", history_record)
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  if history_record then
    SocialIslandHandler.my_duel_  end
end
function SocialIslandHandler.GetPvtOwnerUid()
  if SocialIslandHandler.IsOnPrivateIsLandByMode() and SocialIslandHandler.cur_pvt_socialland_info then
    return SocialIslandHandler.cur_pvt_socialland_info.owner
  else
    return 0
  end
end
function SocialIslandHandler.GetMaxPlayer()
  if not LobbySystem.roleData then
    return SocialIslandHandler.maxMemberNum
  end
  local socialland_param_tb = LobbySystem.roleData.socialland_param_tb
  if not socialland_param_tb then
    return SocialIslandHandler.maxMemberNum
  end
  local maxPlayer = 0
  if SocialIslandHandler.IsOnPrivateIsLandByMode() then
    maxPlayer = socialland_param_tb.pvt_socialland_max_player or SocialIslandHandler.maxMemberNum
  else
    maxPlayer = socialland_param_tb.socialland_max_player or SocialIslandHandler.maxMemberNum
  end
  return maxPlayer
end
function SocialIslandHandler.TryEnterSocialIslandFromChat(owner_id, respondent_uid, fromType, followParam)
  log(bWriteLog and "TryEnterSocialIslandFromChat owner_id:" .. tostring(owner_id))
  log(bWriteLog and "TryEnterSocialIslandFromChat respondent_uid:" .. tostring(respondent_uid))
  log(bWriteLog and "TryEnterSocialIslandFromChat fromType:" .. tostring(fromType))
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local island_macro = require("GameLua.Mod.SocialIsland.Client.IslandMacro")
  local SocialIslandLogic = SubsystemMgr:Get("SocialIslandLogic")
  local myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
  if myselfOnIsland then
    if followParam and tonumber(followParam) == 0 then
      log(bWriteLog and "TryEnterSocialIslandFromChat Tips")
      ShowNotice(34987)
      return
    end
    log(bWriteLog and "TryEnterSocialIslandFromChat MoveFollowTarget")
    SocialIslandLogic:MoveToTarget(island_macro.ENUM_FollowType.FollowShootingTarget)
    return
  end
  local _followParam = followParam or island_macro.ENUM_FollowType.FollowShootingTarget
  if tonumber(_followParam) == 0 then
    owner_id = 0
  end
  if tonumber(owner_id) == 0 then
    SocialIslandHandler.send_socialland_apply_req(respondent_uid, _followParam, fromType)
  elseif tonumber(owner_id) > 0 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.LocalizeResFormat("101001"), LocUtil.LocalizeResFormat("9821"), function()
      SocialIslandHandler.ReqEnterSystemIsland()
    end)
  end
end
function SocialIslandHandler.CheckStartMatch(errorCode, fromType)
  log(bWriteLog and "SocialIslandHandler.CheckStartMatch errorCode:" .. tostring(errorCode))
  log(bWriteLog and "SocialIslandHandler.CheckStartMatch fromType:" .. tostring(fromType))
  local island_macro = require("GameLua.Mod.SocialIsland.Client.IslandMacro")
  if (errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Not_Socialland_Mode or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Enter_Cant_Subjoin or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Enter_Game_Over or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Enter_Not_Socialland or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_To_Socialland_Limit or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Respondent_Not_Online or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Respondent_Not_Apply or errorCode == island_macro.ENUM_Error_Code.Err_Socialland_Apply_Self) and fromType and fromType == island_macro.ENUM_ApplyFromType.FromChatChannel then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.LocalizeResFormat("101001"), LocUtil.LocalizeResFormat("9822"), function()
      SocialIslandHandler.ReqEnterSystemIsland()
    end)
    return true
  end
  return false
end
function SocialIslandHandler.IsOnPrivateIsLandByMode()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if SocialIslandHandler.socialIslandPrivateSubMode[MatchModeMgrSystem.nInGameModeID] then
    return true
  end
  return false
end
function SocialIslandHandler.OnJumpSocialIsLand()
  log(bWriteLog and "SocialIslandHandler.OnJumpSocialIsLand")
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:SkipAllSlap()
  SocialIslandHandler.ReqEnterSystemIsland()
end
function SocialIslandHandler.send_get_socialland_banner_req()
  NetManager.SendPkg(987100419)
end
function SocialIslandHandler.on_get_socialland_banner_rsp(errcode, config)
  local GatheringParadiseSlapSystem = require("client.slua.logic.social_island.logic_socialisland_timelimited_slap")
  GatheringParadiseSlapSystem.OnReceiveConfigInfo(errcode, config)
end
function SocialIslandHandler.send_get_racing_history_record_req()
  NetManager.SendPkg(331390867)
end
function SocialIslandHandler.on_get_racing_history_record_rsp(res, racing_history_record)
  log_tree("SocialIslandHandler.on_get_racing_history_record_rsp ok", res)
  log_tree("SocialIslandHandler.on_get_racing_history_record_rsp history_record", racing_history_record)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  if racing_history_record then
    SocialIslandHandler.my_  end
end
function SocialIslandHandler.send_get_socialland_weaponry_plan_req()
  log(bWriteLog and "[DeanJYT] SocialIslandHandler.send_get_socialland_weaponry_plan_req")
  NetManager.SendPkg(11681703)
end
function SocialIslandHandler.on_get_socialland_weaponry_plan_rsp(res, weaponry_plans)
  log_tree("[DeanJYT] SocialIslandHandler.on_get_socialland_weaponry_plan_rsp", weaponry_plans)
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  local myselfOnIsland = logic_mode_mgr.IsSocialIslandMode(true)
  if not myselfOnIsland then
    return
  end
  local SocialIslandArmorySubsystem = SubsystemMgr:Get("SocialIslandArmorySubsystem")
  if SocialIslandArmorySubsystem then
    SocialIslandArmorySubsystem:SetPlayerWeaponPlans(weaponry_plans)
  end
end
function SocialIslandHandler.send_set_socialland_weaponry_plan_req(plan_info)
  log_tree(bWriteLog and "[DeanJYT] SocialIslandHandler.send_set_socialland_weaponry_plan_req plan_info = ", plan_info)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(517515175, plan_info)
end
function SocialIslandHandler.on_set_socialland_weaponry_plan_rsp(res, plan_id, real_plan_info)
  log_tree(bWriteLog and "[DeanJYT] SocialIslandHandler.on_set_socialland_weaponry_plan_rsp res = " .. tostring(res) .. ", plan_id = " .. tostring(plan_id) .. ", real_plan_info = ", real_plan_info)
  if res == 100110144 then
    ShowNotice(33332)
    return
  elseif res ~= 0 then
    local str = LocUtil.LocalizeResFormat(540001, tostring(res))
    ShowNotice(str)
    return
  end
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  local myselfOnIsland = logic_mode_mgr.IsSocialIslandMode(true)
  if not myselfOnIsland then
    return
  end
  local SocialIslandArmorySubsystem = SubsystemMgr:Get("SocialIslandArmorySubsystem")
  if SocialIslandArmorySubsystem then
    SocialIslandArmorySubsystem:ChangePlayerPlan(plan_id, real_plan_info)
  end
end
function SocialIslandHandler.send_del_socialland_weaponry_plan_req(plan_ids)
  log_tree(bWriteLog and "[DeanJYT] SocialIslandHandler.send_del_socialland_weaponry_plan_req plan_info = ", plan_ids)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(1416341031, plan_ids)
end
function SocialIslandHandler.on_del_socialland_weaponry_plan_rsp(res, plan_ids)
  log_tree(bWriteLog and "[DeanJYT] SocialIslandHandler.on_del_socialland_weaponry_plan_rsp plan_ids = ", plan_ids)
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  local myselfOnIsland = logic_mode_mgr.IsSocialIslandMode(true)
  if not myselfOnIsland then
    return
  end
  local SocialIslandArmorySubsystem = SubsystemMgr:Get("SocialIslandArmorySubsystem")
  if SocialIslandArmorySubsystem then
    SocialIslandArmorySubsystem:DeletePlayerPlans(plan_ids)
  end
end
function SocialIslandHandler.send_get_racing_best_record_req(vehicle_id)
  NetManager.SendPkg(687045191, vehicle_id)
  SocialIslandHandler.CurReqRacingVehicleId = vehicle_id
end
function SocialIslandHandler.on_get_racing_best_record_rsp(res, record)
  print(bWriteLog and string.format(" SocialIslandHandler.on_get_racing_best_record_rsp res:%s, record:%s", res, record))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local RacingClientLogic = SubsystemMgr:Get("RacingClientLogic")
  if RacingClientLogic then
    RacingClientLogic:UpdateBestSingleLapRecord(SocialIslandHandler.CurReqRacingVehicleId, record)
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_RACING_BEST_RECORD_RESP, record)
end
return SocialIslandHandler
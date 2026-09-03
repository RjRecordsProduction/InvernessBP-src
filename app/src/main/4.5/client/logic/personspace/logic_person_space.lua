local PersonSpaceSystem = {
  CacheUid = 0,
  IntimacyPartnerData = {partner_uid = 0},
  IntimacyReddot = {},
  VisibleSwitchs = {},
  otherIntimacySwitchList = nil,
  FriendIntimacyDatas = {},
  FriendDetailsDatas = {},
  CacheSwitchUid = 0,
  CancelApplyList = {},
  AgainApplyTimeInterval = 10,
  PartnerIntimacyLimit = 400,
  list = {},
  relationPrior = nil
}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
PersonSpaceErrorCode = {
  intimacy_pnr_err_intimacy_not_enough = 509001,
  intimacy_pnr_err_not_intimacy_relation = 509002,
  intimacy_pnr_err_has_sent_req = 509003,
  intimacy_pnr_err_already_have_partner = 509004,
  intimacy_pnr_err_wrong_param = 509005,
  intimacy_pnr_err_partner_apply_reach_limit = 509006,
  intimacy_pnr_err_request_reach_limit = 509007,
  intimacy_pnr_err_not_in_confirm_list = 509008,
  intimacy_pnr_err_not_in_req_list = 509009,
  intimacy_pnr_err_perr_have_partner = 509010,
  intimacy_pnr_err_not_have_partner = 509011,
  intimacy_pnr_err_not_inner_fri = 509012
}
PersonSpaceReddotType = {
  REDOT_NEW_INTIMACY_RELATION_AVAILABLE = 1,
  REDOT_NEW_INTIMACY_PARTNER_AVAILABLE = 2,
  REDOT_NEW_INTIMACY_PARTNER_APPLY = 3,
  REDOT_INTIMACY_PARTNER_CHG = 4
}
PersonSpaceGuideType = {PartnerSetting = 1, SecrecySetting = 2}
PersonSpacePartnerSettingProgress = {Setting = 1, Apply = 2}
PersonSpaceSecrecySettingProgress = {Setting = 1, Switch = 2}
function PersonSpaceSystem.Enter()
end
function PersonSpaceSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    PersonSpaceSystem.otherIntimacySwitchList = nil
  end
end
function PersonSpaceSystem.get_intimacy_relation_req()
  log(bWriteLog and "PersonSpaceSystem.get_intimacy_relation_req")
  local IsNeedRedpoint = true
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_intimacy_relation_req(IsNeedRedpoint)
end
function PersonSpaceSystem.get_other_intimacy_relation_req(other_uid)
  log(bWriteLog and "PersonSpaceSystem.get_other_intimacy_relation_req:" .. tostring(other_uid))
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_get_other_intimacy_relation_req(other_uid)
end
function PersonSpaceSystem.remove_intimacy_reddot(reddot_type)
  log(bWriteLog and "PersonSpaceSystem.remove_intimacy_reddot:" .. tostring(reddot_type))
  PersonSpaceSystem.IntimacyReddot[reddot_type] = nil
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_remove_intimacy_reddot(reddot_type)
end
function PersonSpaceSystem.HasIntimacyReddot(reddot_type)
  return PersonSpaceSystem.IntimacyReddot[reddot_type] or false
end
function PersonSpaceSystem.HasIntimacyCanGetRewardReddot()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local IntimacyLevel = CDataTable.GetTable("IntimacyLevel")
  for _, info in pairs(PersonSpaceSystem.list) do
    if info.award_level then
      for __, levelData in pairs(IntimacyLevel) do
        local bIsLover = false
        if info.param and info.param == IntimacyConst.EIntimacyType.Lover then
          bIsLover = true
        end
        local bNeedCheckReddot = true
        if bIsLover and levelData.LoverAwardType ~= 0 or levelData.AwardType ~= 0 then
          bNeedCheckReddot = false
        end
        if bNeedCheckReddot and 0 < levelData.ID and info.award_level < levelData.Level and info.intimacy and info.intimacy >= levelData.MinExp then
          return true
        end
      end
    end
  end
  return false
end
function PersonSpaceSystem.HasCohabitReddot()
  log(bWriteLog and "[DeanJYT] PersonSpaceSystem.HasCohabitReddot")
  if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointEntryUsed) or {}
  if saveData.bHasUsedCohabit then
    return false
  end
  return true
end
function PersonSpaceSystem.HasRelationshipInviteRedpoint()
  local wait_confirm_list = PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list
  local hasWait = false
  if wait_confirm_list and next(wait_confirm_list) ~= nil then
    hasWait = true
  end
  local apply = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY)
  return hasWait or apply
end
function PersonSpaceSystem.HasPartnerSettingReddotAll()
  if not LobbySystem.CheckOpen(BP_ENUM_PERSONSPACE_PARTNERSETTING) then
    return false
  end
  local change = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG)
  local hasPartnerAvailableTip = PersonSpaceSystem.HasPartnerAvailableTip()
  local hasInvite = PersonSpaceSystem.HasRelationshipInviteRedpoint()
  return hasPartnerAvailableTip or change or hasInvite
end
function PersonSpaceSystem.HasRelationReddotAll()
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  return PersonSpaceSystem.HasPartnerSettingReddotAll() or IntimacyAwardSystem.HasIntimacyRewardReddot() or RoleInfoPopularitySystem.IsShowMsgReddot
end
function PersonSpaceSystem.HasPartnerAvailableTip()
  local hasPartner = PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.partner_uid ~= 0
  local available = PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE)
  return not hasPartner and available
end
function PersonSpaceSystem.make_intimacy_partner_req(target_uid)
  log(bWriteLog and "PersonSpaceSystem.make_intimacy_partner_req:" .. tostring(target_uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_make_intimacy_partner_req(target_uid)
end
function PersonSpaceSystem.agree_make_intimacy_partner_req(target_uid)
  log(bWriteLog and "PersonSpaceSystem.agree_make_intimacy_partner_req:" .. tostring(target_uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_agree_make_intimacy_partner_req(target_uid)
end
function PersonSpaceSystem.refuse_make_intimacy_partner_req(target_uid)
  log(bWriteLog and "PersonSpaceSystem.refuse_make_intimacy_partner_req:" .. tostring(target_uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_refuse_make_intimacy_partner_req(target_uid)
end
function PersonSpaceSystem.release_intimacy_partner_req(target_uid)
  log(bWriteLog and "PersonSpaceSystem.release_intimacy_partner_req:" .. tostring(target_uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_release_intimacy_partner_req(target_uid)
end
function PersonSpaceSystem.cancle_make_intimacy_partner_req(target_uid)
  log(bWriteLog and "PersonSpaceSystem.cancle_make_intimacy_partner_req:" .. tostring(target_uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  PersonSpaceSystem.CancelApplyList[target_uid] = TimeUtil.GetServerTimeInSec()
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_cancle_make_intimacy_partner_req(target_uid)
end
function PersonSpaceSystem.get_intimacy_relation_visible_req()
  log(bWriteLog and "get_intimacy_relation_visible_req")
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_get_intimacy_relation_visible_req()
end
function PersonSpaceSystem.AddProfileData(item, profile, intimacy)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local upass_is_buy, upass_is_show, upass_keep_buy, upass_cur_value, pass_type = UnknowPassUtil.ParseUpassInfo(profile.upass)
  item.nickName = profile.nickName
  item.level = profile.level
  item.picUrl = profile.picUrl
  item.vipLevel = profile.vipLevel
  item.sex = profile.sex
  item.signature = profile.signature
  item.intimacy = intimacy or profile.intimacy
  item.segment_info_max = FuncUtil.GetCurMaxSegementLevel(profile.segment_info, profile.metro_summary and profile.metro_summary.military_level)
  item.cur_avatar_box_id = profile.cur_avatar_box_id
  item.  item.  item.  item.  item.  item.aliasId = profile.aliasId
  item.aliasTitle = profile.aliasTitle
  item.aliasNation = profile.aliasNation
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  item.roleNation = logic_profile:GetPlayerNation(profile.uid)
  item.pround_info = profile.pround_info
  item.total_devote = profile.total_devote
  item.social_card = profile.social_card
end
function PersonSpaceSystem.get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot, visible_switchs)
  log(bWriteLog and "PersonSpaceSystem.get_intimacy_relation_rsp")
  PersonSpaceSystem.  PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data or {partner_uid = 0}
  if not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and visible_switchs and next(visible_switchs) then
    if visible_switchs[0] == 1 then
      visible_switchs[0] = true
    elseif visible_switchs[0] == 2 then
      visible_switchs[0] = false
    elseif visible_switchs[0] == 0 then
      visible_switchs[0] = false
    end
  end
  PersonSpaceSystem.VisibleSwitchs = visible_switchs or {}
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  SecrecySystemData.OnServerData(visible_switchs)
  if intimacy_reddot then
    PersonSpaceSystem.IntimacyReddot = intimacy_reddot
  end
  PersonSpaceSystem.FriendIntimacyDatas = {}
  local gids = {}
  for k, v in pairs(list) do
    if v.state == 4 then
      local data = {}
      data.gid = tostring(k)
      data.relation = v.param
      table.insert(gids, tonumber(data.gid))
      if v.intimacy then
        data.intimacy = v.intimacy
      end
      table.insert(PersonSpaceSystem.FriendIntimacyDatas, data)
      log(bWriteLog and "uid:" .. tostring(k) .. ",picUrl:" .. tostring(data.picUrl))
    end
  end
  if 0 < #gids then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.PERSON_RELATION, gids, function(listPram)
      for j, currProfile in pairs(listPram) do
        for i, data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
          if tonumber(data.gid) == tonumber(currProfile.uid) then
            PersonSpaceSystem.AddProfileData(data, currProfile, data.intimacy)
          end
        end
      end
      if next(PersonSpaceSystem.FriendIntimacyDatas) ~= nil then
        table.sort(PersonSpaceSystem.FriendIntimacyDatas, function(a, b)
          return a.intimacy > b.intimacy
        end)
      end
      log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
    end, false, false)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
end
function PersonSpaceSystem.GetFriendIntimacyDataByUID(uid)
  for k, data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
    if tonumber(data.gid) == tonumber(uid) then
      return data
    end
  end
  return nil
end
function PersonSpaceSystem.get_other_intimacy_relation_rsp(other_uid, list, visible_switchs, partner_uid)
  log(bWriteLog and "PersonSpaceSystem.get_other_intimacy_relation_rsp:" .. tostring(other_uid) .. ",partner_uid:" .. tostring(partner_uid))
  log_tree("PersonSpaceSystem list", list)
  log_tree("PersonSpaceSystem visible_switchs", visible_switchs)
  PersonSpaceSystem.IntimacyFriend = {}
  if not PersonSpaceSystem.otherIntimacySwitchList then
    PersonSpaceSystem.otherIntimacySwitchList = {}
  end
  if not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and visible_switchs and next(visible_switchs) then
    if visible_switchs[0] == 1 then
      visible_switchs[0] = true
    elseif visible_switchs[0] == 2 then
      visible_switchs[0] = false
    elseif visible_switchs[0] == 0 then
      visible_switchs[0] = false
    end
  end
  PersonSpaceSystem.otherIntimacySwitchList[other_uid] = visible_switchs
  PersonSpaceSystem.IntimacyPartnerData = {partner_uid = partner_uid}
  PersonSpaceSystem.  PersonSpaceSystem.FriendIntimacyDatas = {}
  PersonSpaceSystem.FriendDetailsDatas = {}
  log_tree("PersonSpaceSystem visible_switchs", visible_switchs)
  local gids = {}
  for k, v in pairs(list) do
    table.insert(gids, tonumber(k))
    table.insert(PersonSpaceSystem.FriendIntimacyDatas, {
      gid = tostring(k),
      relation = v.relation,
      intimacy = v.intimacy,
      custom_name = v.custom_name
    })
    table.insert(PersonSpaceSystem.FriendDetailsDatas, {
      gid = tostring(k),
      relation = v.relation,
      intimacy = v.intimacy,
      custom_name = v.custom_name
    })
  end
  log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)
  if 0 < #gids then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(gids, function(listP)
      for j, currProfile in pairs(listP) do
        for i, data in ipairs(PersonSpaceSystem.FriendIntimacyDatas) do
          if tonumber(data.gid) == tonumber(currProfile.uid) then
            PersonSpaceSystem.AddProfileData(data, currProfile)
          end
        end
      end
      if next(PersonSpaceSystem.FriendIntimacyDatas) ~= nil then
        table.sort(PersonSpaceSystem.FriendIntimacyDatas, function(a, b)
          return a.intimacy > b.intimacy
        end)
      end
      log_tree("PersonSpaceSystem BP_ARRAY_PersonSpace_Intimacy_Data", PersonSpaceSystem.FriendIntimacyDatas)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_OTHER_INTIMACY_DATA_UPDATE, other_uid)
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACYLIST_UPDATE)
    end, Enum_PROFILE_REPORT_CFG.PERSON_SPACE_INTIMACY)
  else
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE)
end
function PersonSpaceSystem.make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  log(bWriteLog and "PersonSpaceSystem.get_other_intimacy_relation_rsp:" .. tostring(res) .. ",target_uid:" .. tostring(target_uid))
  if res ~= 0 then
    ShowNotice(res)
  else
    ShowNotice(6706)
  end
  if intimacy_partner_data then
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
    log_tree("PersonSpaceSystem make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
end
function PersonSpaceSystem.agree_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  log(bWriteLog and "PersonSpaceSystem.agree_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. tostring(target_uid))
  if res ~= 0 then
    ShowNotice(res)
  elseif intimacy_partner_data and 0 < intimacy_partner_data.partner_uid then
    local uid = intimacy_partner_data.partner_uid
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    local nickname = profile and profile.nickName or ""
    local tip = LocUtil.LocalizeResFormat("6609", nickname)
    ShowNotice(tip)
  end
  if intimacy_partner_data then
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    IntimacyAwardSystem.get_intimacy_reward_info_req(true)
    log_tree("PersonSpaceSystem agree_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
end
function PersonSpaceSystem.release_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  log(bWriteLog and "PersonSpaceSystem.release_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. tostring(target_uid))
  if res ~= 0 then
    ShowNotice(res)
  end
  if intimacy_partner_data then
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    IntimacyAwardSystem.get_intimacy_reward_info_req(true)
    IntimacyAwardSystem.has_intimacy_reward = false
    log_tree("PersonSpaceSystem release_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_RELEASE)
  end
end
function PersonSpaceSystem.cancle_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  log(bWriteLog and "PersonSpaceSystem.cancle_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. tostring(target_uid))
  if res ~= 0 then
    ShowNotice(res)
  end
  if intimacy_partner_data then
    log_tree("PersonSpaceSystem cancle_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
end
function PersonSpaceSystem.refuse_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  log(bWriteLog and "PersonSpaceSystem.refuse_make_intimacy_partner_rsp:" .. tostring(res) .. ",target_uid:" .. tostring(target_uid))
  if res ~= 0 then
    ShowNotice(res)
  end
  if intimacy_partner_data then
    log_tree("PersonSpaceSystem refuse_make_intimacy_partner_rsp intimacy_partner_data", intimacy_partner_data)
    PersonSpaceSystem.IntimacyPartnerData = intimacy_partner_data
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_INTIMACY_DATA_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
end
function PersonSpaceSystem.proc_set_intimacy_relation_visible_rsp(switch_list)
  log(bWriteLog and "PersonSpaceSystem.proc_set_intimacy_relation_visible_rsp")
  if switch_list then
    PersonSpaceSystem.VisibleSwitchs = switch_list or {}
    local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
    local oldTotalSwitch = SecrecySystemData.GetOneSwitch(0)
    SecrecySystemData.OnServerData(switch_list)
    log_tree("  : PersonSpaceSystem.VisibleSwitchs", PersonSpaceSystem.VisibleSwitchs)
    if oldTotalSwitch ~= switch_list[0] then
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE_TOTAL)
    end
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE)
  end
end
function PersonSpaceSystem.notify_client_intimacy_data_chg(reddot_type)
  log(bWriteLog and "PersonSpaceSystem.notify_intimacy_data_chg:" .. tostring(reddot_type))
  PersonSpaceSystem.IntimacyReddot[reddot_type] = true
  if reddot_type == PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PARTNER_CHANGE)
  end
  if reddot_type == PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_APPLY or reddot_type == PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG then
    PersonSpaceSystem.get_intimacy_relation_req()
  end
  if reddot_type == PersonSpaceReddotType.REDOT_INTIMACY_PARTNER_CHG then
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    IntimacyAwardSystem.get_intimacy_reward_info_req(true)
  end
  if reddot_type == PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    LogicFriend.get_intimacy_relation_req()
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE)
end
function PersonSpaceSystem.get_intimacy_relation_visible_rsp(switch_list)
  log_tree("PersonSpaceSystem.switch_list:", switch_list)
  if not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if switch_list[0] == 1 then
      switch_list[0] = true
    elseif switch_list[0] == 2 then
      switch_list[0] = false
    elseif switch_list[0] == 0 then
      switch_list[0] = false
    end
  end
  PersonSpaceSystem.VisibleSwitchs = switch_list or {}
  local SecrecySystemData = require("client.slua.logic.roleInfo.secrecy_data")
  SecrecySystemData.OnServerData(switch_list)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_SWITCH_UPDATE)
end
function PersonSpaceSystem.proc_set_intimacy_relation_prior_show_rsp(prior_type)
  if PersonSpaceSystem.relationPrior == nil then
    log(bWriteLog and "PersonSpaceSystem.proc_set_intimacy_relation_prior_show_rsp no relationPrior")
    return
  end
  PersonSpaceSystem.relationPrior.  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PRIOR_RELATION)
end
function PersonSpaceSystem.proc_get_intimacy_relation_prior_show_rsp(relationPrior)
  PersonSpaceSystem.  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_PRIOR_RELATION)
end
function PersonSpaceSystem.GetSwitchVisible(uid, relation)
  local switchInfo
  uid = tonumber(uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    switchInfo = PersonSpaceSystem.VisibleSwitchs
  else
    switchInfo = PersonSpaceSystem.otherIntimacySwitchList and PersonSpaceSystem.otherIntimacySwitchList[uid]
  end
  local currVisible = switchInfo and switchInfo[relation]
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and relation == 0 then
    if currVisible == nil then
      if relation == 0 then
        return false
      else
        return true
      end
    else
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      SettingUtil.OnlyFriend(uid, currVisible or false, 1)
      return currVisible
    end
  elseif currVisible == nil then
    if relation == 0 then
      return false
    else
      return true
    end
  end
  return currVisible
end
function PersonSpaceSystem.ShouldShowPartnerReddot()
end
return PersonSpaceSystem
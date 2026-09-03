local logic_return_team_recommend = {}
function logic_return_team_recommend:DefineAndResetData()
  self.alreadyShowUIDs = {}
end
function logic_return_team_recommend:_StartDetectingFree()
  log(bWriteLog and "logic_return_team_recommend:_StartDetectingFree start detecting free")
  log_tree(bWriteLog and "logic_return_team_recommend:_StartDetectingFree share_card_info", LobbySystem.roleData.share_card_info)
  self.dayShowTime, self.weekShowTime = self:GetShowCnt()
  self.alreadyShowUIDs = self:GetAlreadyShowUIDs()
  self:SetDailyResetTimer()
end
function logic_return_team_recommend:GetShowCnt()
  if self.dayShowTime and self.weekShowTime then
    return self.dayShowTime, self.weekShowTime
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local allSaveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  if not allSaveData.TeamUp then
    return 0, 0
  end
  local saveData = allSaveData.TeamUp
  local dayCnt = 0
  local weekCnt = 0
  local needRemoveData = {}
  local TimeUtil = require("client.common.time_util")
  for uid, data in pairs(saveData) do
    for time, _ in pairs(data) do
      local bIsSameDay = TimeUtil.IsSameDay(time, TimeUtil.GetServerTimeInSec())
      local bIsSameWeek = TimeUtil.IsSameWeek(time, TimeUtil.GetServerTimeInSec())
      if bIsSameDay then
        dayCnt = dayCnt + 1
      end
      if bIsSameWeek then
        weekCnt = weekCnt + 1
      else
        if not needRemoveData[uid] then
          needRemoveData[uid] = {}
        end
        needRemoveData[uid][time] = true
      end
    end
  end
  if next(needRemoveData) then
    for uid, data in pairs(needRemoveData) do
      for time, _ in pairs(data) do
        saveData[uid][time] = nil
      end
      if not next(saveData[uid]) then
        saveData[uid] = nil
      end
    end
    allSaveData.TeamUp = saveData
    PlayerPrefsSystem.SaveTableToFile_N(allSaveData, PlayerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew)
  end
  return dayCnt, weekCnt
end
function logic_return_team_recommend:GetAlreadyShowUIDs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local allSaveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRecBackUserGuidanceShowTimeNew) or {}
  local saveData = allSaveData.TeamUp
  if not saveData then
    return {}
  end
  local uids = {}
  local TimeUtil = require("client.common.time_util")
  for uid, data in pairs(saveData) do
    for time, _ in pairs(data) do
      local bIsSameDay = TimeUtil.IsSameDay(time, TimeUtil.GetServerTimeInSec())
      if bIsSameDay then
        uids[uid] = true
      end
    end
  end
  return uids
end
function logic_return_team_recommend:SetDailyResetTimer()
  if not DataMgr.roleData.back_user_data then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  local return_date = TimeUtil.OSDate("*t", DataMgr.roleData.back_user_data.rejoin_start_time)
  log_format("logic_return_team_recommend:SetDailyResetTimer rejoin_start_time:%s", tostring(TimeUtil.FormatTime_YMDHMS(DataMgr.roleData.back_user_data.rejoin_start_time)))
  local GetNextResetUnixTime = function(current_time, ref_time)
    local time = os.date("*t", current_time)
    local target_time = TimeUtil.OSTime({
      year = time.year,
      month = time.month,
      day = time.day,
      hour = ref_time.hour,
      min = ref_time.min,
      sec = ref_time.sec
    })
    if current_time >= target_time then
      target_time = target_time + 86400
    end
    return target_time
  end
  local next_reset_UnixTime = GetNextResetUnixTime(cur_time, return_date)
  log_format("logic_return_team_recommend:SetDailyResetTimer next_reset_time:%s", tostring(TimeUtil.FormatTime_YMDHMS(next_reset_UnixTime)))
  local gapTime = next_reset_UnixTime - cur_time
  if gapTime <= 0 then
    log_format("logic_return_team_recommend:SetDailyResetTimer gapTime=%s, use 1s as fallback", tostring(gapTime))
    gapTime = 1
  end
  self:AddTimerOnce(gapTime, function()
    self:ResetShareCardSent()
  end)
end
function logic_return_team_recommend:OnNextDayZeroCome()
  if not LobbySystem.roleData.share_card_info then
    return
  end
  LobbySystem.roleData.share_card_info.daily_recv_cnt = 0
  LobbySystem.roleData.share_card_info.daily_share_cnt = 0
  LobbySystem.roleData.share_card_info.share_frd_uids = {}
end
function logic_return_team_recommend:ResetShareCardSent()
  if not LobbySystem.roleData.share_card_info then
    return
  end
  LobbySystem.roleData.share_card_info.is_share_card_sent = false
end
function logic_return_team_recommend:_OnAddNewMail(_, _, mailInfo)
  if IsWoWEditor then
    return
  end
  if not mailInfo then
    log(bWriteLog and "logic_return_team_recommend:_OnAddNewMail return of not mailInfo")
    return
  end
  if not mailInfo.params then
    log(bWriteLog and "logic_return_team_recommend:_OnAddNewMail return of not mailInfo.params")
    return
  end
  if not mailInfo.params[1] then
    log(bWriteLog and "logic_return_team_recommend:_OnAddNewMail return of not mailInfo.params[1]")
    return
  end
  local mail_macro = require("client.slua.logic.mail.mail_macro")
  if mailInfo and mailInfo.attachList and mailInfo.opt.cfg_id == mail_macro.returnShareCardMailCfgID then
    local itemCfg = CDataTable.GetTableData("Item", mailInfo.attachList[1].attachId)
    if not itemCfg then
      return
    end
    local ui_util = require("client.common.ui_util")
    local params = {
      icon = ui_util.GetItemSmallIcon(2195002),
      desc = LocUtil.LocalizeResFormat(86266, mailInfo.params[1], itemCfg.ItemName, mailInfo.attachList[1].attachCount),
      callback = function()
        local MailMacro = require("client.slua.logic.mail.mail_macro")
        local jumpToMail = string.format("game://?module=%s&tabId=%s&mailId=%s", BP_ENUM_MODULE_MAIL, MailMacro.Enum_Mail_Type.System, mail_macro.returnShareCardMailCfgID)
        GlobalData.JumpGameUrl(jumpToMail)
      end
    }
    UIManager.ShowUI(UIManager.UI_Config.Common_InviteInteraction_Tips_UIBP, params)
  end
end
function logic_return_team_recommend:OnInitialize()
end
function logic_return_team_recommend:RegistEvents()
  self:AddAdvanceCommonEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ON_RECV_NEW_MAIL, self._OnAddNewMail, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_return_team_recommend:OnLogin(bReLogin)
end
function logic_return_team_recommend:OnLogOut()
end
function logic_return_team_recommend:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity() then
    self:RemoveAllTimer()
  end
end
function logic_return_team_recommend:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:_StartDetectingFree()
    self:SetDailyResetTimer()
  end
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting() then
    self:_StartDetectingFree()
    self:SetDailyResetTimer()
  end
end
function logic_return_team_recommend:OpenShareCardUI(from, itemData)
  if not itemData then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    itemData = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(2155001, true)
  end
  UIManager.ShowUI(UIManager.UI_Config.Common_Popup_ShareCard_UIBP, from, itemData)
end
function logic_return_team_recommend:IsShowFriendBarEntry()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_return_team_recommend:IsShowFriendBarEntry return of not backuser")
    return false
  end
  local isHitABTest = self:CheckShareCardABTest()
  if not isHitABTest then
    return false
  end
  local logic_assembly_activity = require("client.slua.logic.come_back.logic_assembly_activity")
  if not logic_assembly_activity.HasActivity() and not self:CheckShareCardExist() then
    log(bWriteLog and "logic_return_team_recommend:IsShowFriendBarEntry return of not activity")
    return false
  end
  return true
end
function logic_return_team_recommend:IsShowShareCardEntry()
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo or not shareCardInfo.share_card_info then
    log(bWriteLog and "logic_return_team_recommend:IsShowShareCardEntry return of not share_card_info")
    return false
  end
  if shareCardInfo.share_card_info.daily_share_cnt >= shareCardInfo.BackUserShareCardDailyLimit then
    log(bWriteLog and "logic_return_team_recommend:IsShowShareCardEntry return of daily share cnt >= 3")
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemNum = wardrobe_data:GetHallDepotItemCountByResID(2155001)
  if itemNum == 0 then
    log(bWriteLog and "logic_return_team_recommend:IsShowShareCardEntry return of itemNum == 0")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local bIsInTeam = TeamUpNewSystem.GetTeamNum() > 1
  if not bIsInTeam then
    log(bWriteLog and "logic_return_team_recommend:IsShowShareCardEntry return of not in team")
    return false
  end
  return true
end
function logic_return_team_recommend:GetRecommendText(uid)
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  if not logic_new_friend.IsMyFriend(uid) then
    return LocUtil.GetLocalizeResStr(86349), LocUtil.GetLocalizeResStr(86349)
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local bIsRejoinPlayer = logic_return_activity_utils.IsActInProgress()
  local config = CDataTable.GetTable("ReturnTeamUpTextCfg")
  local cfgList = {}
  for k, v in pairs(config) do
    table.insert(cfgList, v)
  end
  table.sort(cfgList, function(a, b)
    return a.Priority < b.Priority
  end)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and string.format("logic_return_team_recommend:GetRecommendText, not profile uid:%s", uid))
    return LocUtil.GetLocalizeResStr(86349), LocUtil.GetLocalizeResStr(86349)
  end
  for i, v in ipairs(cfgList) do
    local normalDataStr = v.NormalDataStr
    if normalDataStr and normalDataStr ~= "" and profile[normalDataStr] and (profile[normalDataStr] > v.Threshold or v.Threshold == 0) then
      if bIsRejoinPlayer then
        return LocUtil.LocalizeResFormat(v.RecommendedText, profile.nickName, profile[normalDataStr]), LocUtil.LocalizeResFormat(v.InvitedText, profile.nickName, profile[normalDataStr])
      else
        return LocUtil.LocalizeResFormat(v.NormalRecommendedText, profile.nickName, profile[normalDataStr]), LocUtil.LocalizeResFormat(v.InvitedText, profile.nickName, profile[normalDataStr])
      end
    end
    local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
    local data = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(uid)
    if not data then
      return LocUtil.GetLocalizeResStr(86349), LocUtil.GetLocalizeResStr(86349)
    end
    local interactiveDataStr = v.InteractiveDataStr
    if interactiveDataStr and interactiveDataStr ~= "" and data[interactiveDataStr] and (data[interactiveDataStr] > v.Threshold or v.Threshold == 0) then
      if bIsRejoinPlayer then
        return LocUtil.LocalizeResFormat(v.RecommendedText, profile.nickName, data[interactiveDataStr]), LocUtil.LocalizeResFormat(v.InvitedText, profile.nickName, data[interactiveDataStr])
      else
        return LocUtil.LocalizeResFormat(v.NormalRecommendedText, profile.nickName, data[interactiveDataStr]), LocUtil.LocalizeResFormat(v.InvitedText, profile.nickName, data[interactiveDataStr])
      end
    end
  end
  return LocUtil.GetLocalizeResStr(86349), LocUtil.GetLocalizeResStr(86349)
end
function logic_return_team_recommend:GetRecommendFriendUidList()
  local logic_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_recommend)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local uidList = {}
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local freeFriendList = LogicFriend.GetAllFriendList(true, nil, PlayerStatusEnum.Enum_TeamState.Free)
  local idleFriendList = LogicFriend.GetAllFriendList(true, nil, PlayerStatusEnum.Enum_TeamState.Idle)
  local mainCityFreeFriendList = LogicFriend.GetInMainCityFreeFriendList()
  local onlineFriendsList = {}
  for i, v in ipairs(freeFriendList) do
    table.insert(onlineFriendsList, v)
  end
  for i, v in ipairs(idleFriendList) do
    table.insert(onlineFriendsList, v)
  end
  for i, v in ipairs(mainCityFreeFriendList) do
    table.insert(onlineFriendsList, v)
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if 0 < #onlineFriendsList then
    for index, uid in ipairs(onlineFriendsList) do
      local profile = logic_profile:GetLocalProfile(uid)
      if self.alreadyShowUIDs[uid] == nil and logic_team_recommend:CheckValidStatus(profile) and TeamUpNewSystem.CanInviteFriend(uid, true) then
        table.insert(uidList, uid)
      end
    end
  end
  return uidList
end
function logic_return_team_recommend:GetRecommendUID()
  local friends = self:GetRecommendFriendUidList()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  table.sort(friends, function(uidA, uidB)
    return logic_new_friend.GetInnerFriendIntimacy(uidA) > logic_new_friend.GetInnerFriendIntimacy(uidB)
  end)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local intimacyLimit = CDataTable.GetTableData("RecommendedSystemCfg", "return_teamup_rec_intimacy_limit").Value
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    if not next(friends) then
      return
    end
    for i, uid in ipairs(friends) do
      if intimacyLimit <= logic_new_friend.GetInnerFriendIntimacy(uid) then
        local profile = logic_profile:GetLocalProfile(uid)
        local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
        if self:IsVaildRejoinPlayer(profile) then
          return uid
        end
      end
    end
  else
    if not next(friends) then
      local logic_friend_search = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_search)
      local list = logic_friend_search:GetSearchList()
      if not next(list) then
        local friend_const = require("client.slua.logic.friend.friend_const")
        logic_friend_search:social_search_role_req({}, friend_const.ENUM_SEARCH_TYPE.ReturnTeamUp)
        return 0
      end
      local tempList = {}
      for i, v in ipairs(list) do
        if self.alreadyShowUIDs[v] == nil then
          table.insert(tempList, v)
        end
      end
      if not next(tempList) then
        local friend_const = require("client.slua.logic.friend.friend_const")
        logic_friend_search:social_search_role_req({}, friend_const.ENUM_SEARCH_TYPE.ReturnTeamUp)
        return 0
      end
      local index = math.random(1, #tempList)
      return tempList[index]
    end
    for i, uid in ipairs(friends) do
      if intimacyLimit <= logic_new_friend.GetInnerFriendIntimacy(uid) then
        return uid
      end
    end
  end
end
function logic_return_team_recommend:IsVaildRejoinPlayer(profile)
  if not (profile and profile.rejoin_start_time) or not profile.dynamic_life_time then
    log(bWriteLog and "logic_return_team_recommend:IsVaildRejoinPlayer invalid profile data")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local rejoinStartTime = profile.rejoin_start_time
  local rejoinEndTime = rejoinStartTime + profile.dynamic_life_time * 86400
  local rejoinDays = math.ceil((serverTime - rejoinStartTime) / 86400)
  if serverTime >= rejoinEndTime or 7 < rejoinDays then
    log_format("logic_return_team_recommend:IsVaildRejoinPlayer not in valid period, uid:%s days:%s", tostring(profile.uid), tostring(rejoinDays))
    return false
  end
  if not self:CheckProfileABTest(profile) then
    return false
  end
  log_format("logic_return_team_recommend:IsVaildRejoinPlayer valid rejoin player, uid:%s days:%s", tostring(profile.uid), tostring(rejoinDays))
  return true
end
function logic_return_team_recommend:CheckHaveReturnPlayer(members)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, v in ipairs(members) do
    local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
    if logic_oldfriend_care.IsRejoinPlayer(v) then
      return true
    end
  end
  return false
end
function logic_return_team_recommend:CheckTeamUpReward(uid)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local logic_assembly_activity = require("client.slua.logic.come_back.logic_assembly_activity")
  if logic_return_activity_utils.IsActInProgress() then
    local isHitABTest = self:CheckShareCardABTest()
    if not isHitABTest then
      return false
    end
    if LobbySystem.roleData.share_card_info and not LobbySystem.roleData.share_card_info.is_share_card_sent then
      return true
    end
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
    if not logic_oldfriend_care.IsRejoinPlayer(profile) then
      return false
    end
  end
  return not logic_assembly_activity.IsBackCornReachLimit() and not logic_assembly_activity.IsBackCornReachTodayLimit()
end
function logic_return_team_recommend:CheckShareCardExist()
  local isHitABTest = self:CheckShareCardABTest()
  if not isHitABTest then
    return false
  end
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo then
    log(bWriteLog and "logic_return_team_recommend:CheckShareCardExist return of not share_card_info")
    return false
  end
  local back_user_data = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not back_user_data or not back_user_data.rejoin_start_time then
    log(bWriteLog and "logic_return_team_recommend:CheckShareCardExist back_user_data or rejoin_start_time is nil")
    return false
  end
  local startTime = tonumber(back_user_data.rejoin_start_time)
  local TimeUtil = require("client.common.time_util")
  local days = math.ceil((TimeUtil.GetServerTimeInSec() - startTime) / 86400)
  if days > shareCardInfo.CardGotValidDaysAfterBack then
    return false
  end
  return true
end
function logic_return_team_recommend:GetShareCardDynamicData()
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo or not shareCardInfo.share_card_info then
    log(bWriteLog and "logic_return_team_recommend:GetShareCardDynamicData return of not share_card_info")
    return nil
  end
  return shareCardInfo.share_card_info
end
function logic_return_team_recommend:IsCanShareCard(uid)
  local targetUid = tonumber(uid)
  if not targetUid then
    log(bWriteLog and "logic_return_team_recommend:IsCanShareCard invalid uid parameter")
    return false, 100600036
  end
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo then
    log(bWriteLog and "logic_return_team_recommend:IsCanShareCard return of not share_card_info")
    return false, 100600039
  end
  local dynamicData = self:GetShareCardDynamicData()
  if not dynamicData then
    log(bWriteLog and "logic_return_team_recommend:IsCanShareCard return of not dynamic data")
    return false, 100600039
  end
  if dynamicData.daily_share_cnt >= shareCardInfo.BackUserShareCardDailyLimit then
    log(bWriteLog and "logic_return_team_recommend:IsCanShareCard return of daily_share_cnt >= BackUserShareCardDailyLimit")
    return false, 100600037
  end
  local friendShareCount = dynamicData.share_frd_uids[targetUid] or 0
  if friendShareCount >= shareCardInfo.ShareCardToFrdLimitPerDay then
    log_format("logic_return_team_recommend:IsCanShareCard return of frd daily share count limit, uid:%s count:%s", tostring(targetUid), tostring(friendShareCount))
    return false, 100600042
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  if TimeUtil.IsSameDay(currentTime, dynamicData.last_share_tm) and dynamicData.daily_share_cnt >= shareCardInfo.BackUserShareCardDailyLimit then
    log(bWriteLog and "logic_return_team_recommend:IsCanShareCard return of daily_share_cnt >= BackUserShareCardDailyLimit and last share time is same day")
    return false, 100600037
  end
  return true, nil
end
function logic_return_team_recommend:IsCanReceiveShareCard()
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo then
    log(bWriteLog and "logic_return_team_recommend:IsCanReceiveShareCard return of not share_card_info")
    return false, 411015
  end
  local dynamicData = self:GetShareCardDynamicData()
  if not dynamicData then
    log(bWriteLog and "logic_return_team_recommend:IsCanReceiveShareCard return of not dynamic data")
    return false, 411015
  end
  local dailyReceiveCount = dynamicData.daily_recv_cnt or 0
  if dailyReceiveCount >= shareCardInfo.ShareCardMailGotDailyLimit then
    log_format("logic_return_team_recommend:IsCanReceiveShareCard return of daily receive limit, count:%s limit:%s", tostring(dailyReceiveCount), tostring(shareCardInfo.ShareCardMailGotDailyLimit))
    return false, 100600041
  end
  local seasonReceiveCount = dynamicData.season_recv_cnt or 0
  if seasonReceiveCount >= shareCardInfo.ShareCardMailGotSeasonLimit then
    log_format("logic_return_team_recommend:IsCanReceiveShareCard return of season receive limit, count:%s limit:%s", tostring(seasonReceiveCount), tostring(shareCardInfo.ShareCardMailGotSeasonLimit))
    return false, 100600040
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local lastReceiveTime = dynamicData.last_recv_tm or 0
  if 0 < lastReceiveTime and TimeUtil.IsSameDay(currentTime, lastReceiveTime) and dailyReceiveCount >= shareCardInfo.ShareCardMailGotDailyLimit then
    log(bWriteLog and "logic_return_team_recommend:IsCanReceiveShareCard return of same day daily limit reached")
    return false, 100600041
  end
  log(bWriteLog and "logic_return_team_recommend:IsCanReceiveShareCard all checks passed, can receive share card")
  return true, nil
end
function logic_return_team_recommend:ShowRBGuideTeamUpPopup(recUID)
  if IsWoWEditor then
    return
  end
  local desc = self:GetRecommendText(recUID)
  return UIManager.ShowUI(UIManager.UI_Config.Return_Team_Recommend_UIBP, 1, recUID, desc)
end
function logic_return_team_recommend:SetAlreadyShowUIDs(recUID)
  if not self.dayShowTime or not self.weekShowTime then
    self.dayShowTime, self.weekShowTime = self:GetShowCnt()
  end
  if not self.alreadyShowUIDs then
    self.alreadyShowUIDs = self:GetAlreadyShowUIDs()
  end
  self.dayShowTime = self.dayShowTime + 1
  self.weekShowTime = self.weekShowTime + 1
  self.alreadyShowUIDs[recUID] = true
end
function logic_return_team_recommend:CheckShareCardABTest()
  local shareCardInfo = LobbySystem.roleData.share_card_info
  if not shareCardInfo then
    log(bWriteLog and "logic_return_team_recommend:CheckShareCardABTest return of not share_card_info")
    return false
  end
  if not shareCardInfo.is_share_card_abtest then
    log(bWriteLog and "logic_return_team_recommend:CheckShareCardABTest return of not hit abtest")
    return false
  end
  return true
end
function logic_return_team_recommend:CheckProfileABTest(profile)
  if not profile then
    log(bWriteLog and "logic_return_team_recommend:CheckProfileABTest profile is nil")
    return false
  end
  if not profile.backuser_social_recommend_abtest then
    log_format("logic_return_team_recommend:CheckProfileABTest not hit abtest, uid:%s", tostring(profile.uid))
    return false
  end
  return true
end
function logic_return_team_recommend:on_share_card_info_notity(frd_uid, share_card_info)
  LobbySystem.roleData.  if frd_uid ~= 0 then
    local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
    if logic_new_friend.IsMyFriend(frd_uid) then
      local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
      logic_chat_channel_friend.SendNotifyFriendShareCard(frd_uid)
    end
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_SHARE_CARD_RSP)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_team_recommend = class(CModuleBase, nil, logic_return_team_recommend)
return Clogic_return_team_recommend
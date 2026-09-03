local LogicUGCAuthor = {}
function LogicUGCAuthor:DefineAndResetData()
  self.AuthorInfoCache = {}
  self.AuthorExtInfoCache = {}
  self.AuthorCacheCD = 300
  self.AuthorFollowStatus = {}
  self.max_follow_num = 0
  self.follow_list = {}
  self.MyAuthorSummaryData = nil
  self.ExAwardInfo = nil
  self.ExAwardStates = nil
  self.ExAwardCondition = nil
  self.CreativerInfo = {}
  self.SelfCreativerInfo = {}
  self.AuthorizedAssetMap = {}
  self.AuthorizedParameterMap = {}
  local UGC_Assistant_Define = require("client.slua.umg.ugc.creator.center.UGC_Assistant_Define")
  self._CacheAssistantTabType = UGC_Assistant_Define.AssistantTabType.None
  self.Copilot_GM_SET_CHECK = false
  self.AuthorizedAssetList = nil
  self.AuthorizedParameterList = nil
  self.ugc_author_info_ext = nil
  self.AuthorPrefabInfoCache = {}
  self.AuthorPrefabInfoDataTimeStamp = nil
  self.AuthorPrefabInfoDataReqCD = 300
end
function LogicUGCAuthor:OnInitialize()
  print(bWriteLog and "LogicUGCAuthor:OnInitialize")
  self:InitAuthorizedAssetMap()
  self.BShowBecomeAuthorSlap = false
end
function LogicUGCAuthor:RegistEvents()
  log(bWriteLog and "[edward] LogicUGCAuthor:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_MINE, self.OnJumpToMine, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_CREATE_MAIN, self.OnJumpToCreate, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_BEGINNER_LEVEL, self.OnJumpToBeginnerLevel, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_CREATE_MOD, self.OnJumpToCreateMod, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_DATAMGR_BECOME_CREATOR_NEW, self.OnBecomeCreator, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATOR_CARE_CHANGE, self.OnNotifyAuthorInfo, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_REFRESH_TUTORIAL_TAB, self.OnUpdateTutorialData, self)
end
function LogicUGCAuthor:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "LogicUGCAuthor:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    self:RequestAuthorInfo(DataMgr.roleData.uid)
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:GetGalleryParamConfig()
  end
end
function LogicUGCAuthor:IsBanned(bIsShowTips)
  local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
  local banInfo = DataMgr.ban[BanMacro.PLAYER_BAN_UGC_AUTHOR]
  if not banInfo then
    return false
  end
  local endTime = banInfo.end_time
  local TimeUtil = require("client.common.time_util")
  if endTime < TimeUtil.GetServerTimeInSec() then
    return false
  end
  if bIsShowTips then
    ShowNotice(LocUtil.LocalizeResFormat(8502062, TimeUtil.FormatCountDownTime_D_or_HMS(endTime - TimeUtil.GetServerTimeInSec(), 1)))
  end
  return true
end
function LogicUGCAuthor:RequestAuthorInfo(uid, bNeedRefresh)
  uid = tonumber(uid)
  if not uid then
    log(bWriteLog and "LogicUGCAuthor:RequestAuthorInfo uid is nil")
    return
  end
  if not bNeedRefresh and uid ~= tonumber(DataMgr.roleData.uid) and self:CheckValidAuthorInfo(uid) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, uid)
    return
  end
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_get_author_req(uid)
end
function LogicUGCAuthor:CheckValidAuthorInfo(uid)
  if not self.AuthorInfoCache or not self.AuthorInfoCache[uid] then
    log(bWriteLog and "LogicUGCAuthor:CheckValidAuthorInfo self.AuthorInfoCache[uid] is nil uid = " .. tostring(uid))
    return false
  end
  local author_info_get_timestamp = self.AuthorInfoCache[uid].author_info_get_timestamp
  if not author_info_get_timestamp then
    log(bWriteLog and "LogicUGCAuthor:CheckValidAuthorInfo author_info_get_timestamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= author_info_get_timestamp + self.AuthorCacheCD
end
function LogicUGCAuthor:SetAuthorInfo(author_uid, author_data, tb, ugc_author_info_ext)
  author_uid = tonumber(author_uid)
  if not author_uid then
    return
  end
  if tonumber(DataMgr.roleData.uid) == author_uid then
    self:UpdateMineAuthorInfo(author_data)
    local rank_data = require("client.slua.logic.rank.rank_data")
    local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
    local MineAuthorInfo = self:GetMineAuthorInfo()
    rank_data.SetSelfRankData({
      uid = author_uid,
      new_level = MineAuthorInfo and MineAuthorInfo.new_level,
      new_level_exp = MineAuthorInfo and MineAuthorInfo.new_level_exp
    }, rank_data_converter.ConvertWoWAuthorProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF)
    self.  else
    local TimeUtil = require("client.common.time_util")
    self.AuthorInfoCache[author_uid] = {
      author_data = author_data,
      author_info_get_timestamp = TimeUtil.GetServerTimeInSec()
    }
    self.AuthorExtInfoCache[author_uid] = ugc_author_info_ext
  end
  if tb and tb.follow_status then
    self:SetAuthorFollowStatus(author_uid, tb.follow_status)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, author_uid)
end
function LogicUGCAuthor:ReqAuthorAwardInfo()
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_author_level_get_award_info_req()
end
function LogicUGCAuthor:RspAuthorAwardInfo(AwardInfo, AwardStates, AwardCondition)
  self.  self.  self.  local RedDotCount = 0
  local E_  for Lv, AwardState in pairs(AwardStates) do
    if 0 < Lv and AwardState == E_ActivityProgressStatus.Done then
      RedDotCount = RedDotCount + 1
    end
  end
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateLevelCount(RedDotCount)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR_LEVEL_AWARD, AwardInfo, AwardStates, AwardCondition)
end
function LogicUGCAuthor:ReqAuthorExAwardInfo()
  print(bWriteLog and "LogicUGCAuthor:ReqAuthorExAwardInfo")
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_author_level_get_ex_award_info_req()
  self:RefreshCreateGuideRedDotData()
end
function LogicUGCAuthor:RspAuthorExAwardInfo(AwardInfo, AwardStates, AwardCondition)
  print(bWriteLog and "LogicUGCAuthor:RspAuthorExAwardInfo")
  log_tree("AwardInfo:", AwardInfo)
  log_tree("AwardStates:", AwardStates)
  log_tree("AwardCondition:", AwardCondition)
  self.Ex  self.Ex  self.Ex  self:RefreshCreateGuideRedDotData()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR_LEVEL_EX_AWARD)
end
function LogicUGCAuthor:AwardInfoIsValid(AwardInfo)
  return AwardInfo.res_id > 0 and (0 < AwardInfo.count or 0 < AwardInfo.valid_hours)
end
function LogicUGCAuthor:RefreshCreateGuideRedDotData()
  local RedDotCount = 0
  if self.ExAwardInfo ~= nil and self.ExAwardStates ~= nil then
    local E_    for Level, AwardInfos in pairs(self.ExAwardInfo) do
      local bAwardContains = false
      for _, AwardInfo in pairs(AwardInfos) do
        if self:AwardInfoIsValid(AwardInfo) then
          bAwardContains = true
          break
        end
      end
      if bAwardContains then
        local AwardState = self.ExAwardStates[Level]
        if 0 < Level and AwardState ~= nil and AwardState == E_ActivityProgressStatus.Done then
          RedDotCount = RedDotCount + 1
        end
      end
    end
  end
  if RedDotCount == 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local fileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCCreateGuideRedDot
    local savedData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
    print(bWriteLog and "LogicUGCAuthor:RefreshCreateGuideRedDotData FirstRedDot:" .. tostring(savedData.FirstRedDot))
    if savedData.FirstRedDot ~= true then
      RedDotCount = 1
    end
  end
  print(bWriteLog and "LogicUGCAuthor:RefreshCreateGuideRedDotData RedDotCount:" .. tostring(RedDotCount))
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateCreateGuideCount(RedDotCount)
end
function LogicUGCAuthor:SaveCreateGuideFirstRedDot()
  print(bWriteLog and "LogicUGCAuthor:SaveCreateGuideFirstRedDot")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCCreateGuideRedDot
  local saveData = {FirstRedDot = true}
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
  self:RefreshCreateGuideRedDotData()
end
function LogicUGCAuthor:RefreshAiCopilotRedDotData()
  local RedDotCount = 0
  if RedDotCount == 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local fileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCAICopilotRedDot
    local savedData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
    print(bWriteLog and "LogicUGCAuthor:RefreshAiCopilotRedDotData FirstRedDot:" .. tostring(savedData.FirstRedDot))
    if savedData.FirstRedDot ~= true then
      RedDotCount = 1
    end
  end
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateAiCopilotCount(RedDotCount)
  return RedDotCount
end
function LogicUGCAuthor:SaveAiCopilotFirstRedDot()
  print(bWriteLog and "LogicUGCAuthor:SaveAiCopilotFirstRedDot")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eUGCAICopilotRedDot
  local saveData = {FirstRedDot = true}
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
end
function LogicUGCAuthor:GetAuthorExAwardInfo(bNeedReq)
  if bNeedReq == true and self.ExAwardInfo == nil then
    self:ReqAuthorExAwardInfo()
  end
  return self.ExAwardInfo, self.ExAwardStates, self.ExAwardCondition
end
function LogicUGCAuthor:CacheAssistantTabType(AssistantTabType)
  print(bWriteLog and "LogicUGCAuthor:SetCacheAssistantTabType AssistantTabType:" .. tostring(AssistantTabType))
  self._Cacheend
function LogicUGCAuthor:GetCacheAssistantTabType(AssistantTabType)
  print(bWriteLog and "LogicUGCAuthor:GetCacheAssistantTabType AssistantTabType:" .. tostring(AssistantTabType))
  return self._CacheAssistantTabType
end
function LogicUGCAuthor:ReqGetAuthorAward()
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_author_level_award_req()
end
function LogicUGCAuthor:RspGetAuthorAward(Level, AwardStates, AwardItems)
  if DataMgr.ugc_author_info then
    DataMgr.ugc_author_info.new_level = Level
  end
  self.  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateLevelCount(0)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR_LEVEL_GET_AWARD, AwardStates)
  local UIUtil = require("client.common.ui_util")
  local MergedAwards = UIUtil.MergeItemList(AwardItems)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(MergedAwards)
end
function LogicUGCAuthor:ReqGetExAuthorAward()
  local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
  UGCAuthorHandler.send_ugc_author_level_ex_award_req()
end
function LogicUGCAuthor:RspGetExAuthorAward(Level, AwardStates, AwardItems)
  self.Ex  self:RefreshCreateGuideRedDotData()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR_LEVEL_GET_EX_AWARD, AwardStates)
  local UIUtil = require("client.common.ui_util")
  local MergedAwards = UIUtil.MergeItemList(AwardItems)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(MergedAwards)
end
function LogicUGCAuthor:GetAuthorLevel(uid)
  local AuthorInfo = self:GetAuthorInfo(uid)
  if AuthorInfo and AuthorInfo.new_level then
    return AuthorInfo.new_level
  end
  return 0
end
function LogicUGCAuthor:GetMineAuthorLevel()
  local AuthorInfo = self:GetMineAuthorInfo()
  if AuthorInfo and AuthorInfo.new_level then
    return AuthorInfo.new_level
  end
  return 0
end
function LogicUGCAuthor:GetMineAuthorExp()
  local AuthorInfo = self:GetMineAuthorInfo()
  if AuthorInfo and AuthorInfo.new_level_exp then
    return AuthorInfo.new_level_exp
  end
  return 0
end
function LogicUGCAuthor:GetMaxFollowNum()
  return self.max_follow_num
end
function LogicUGCAuthor:GetSortedFollowList()
  local sortedList = {}
  for uid, v in pairs(self.follow_list) do
    local info = {
      uid = uid,
      total_follower_cnt = v.total_follower_cnt,
      follow_time = v.follow_time
    }
    table.insert(sortedList, info)
  end
  table.sort(sortedList, function(a, b)
    return a.follow_time > b.follow_time
  end)
  return sortedList
end
function LogicUGCAuthor:GetAuthorFollowStatus(uid)
  return self.AuthorFollowStatus[uid]
end
function LogicUGCAuthor:SetAuthorFollowStatus(uid, status)
  self.AuthorFollowStatus[uid] = status
end
function LogicUGCAuthor:SetAuthorState(author_state)
  log(bWriteLog and "LogicUGCAuthor:SetAuthorState, author_state: " .. author_state)
  local AuthorInfo = self:GetMineAuthorInfo()
  if AuthorInfo then
    AuthorInfo.state = tonumber(author_state) or 0
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, tonumber(DataMgr.roleData.uid))
end
function LogicUGCAuthor:CheckInGame()
  return not GameStatus.IsInLobbyOrMainCity()
end
function LogicUGCAuthor:ShowExceedFollowLimitUI()
  local title = LocUtil.GetLocalizeResStr(101001)
  local msg = LocUtil.GetLocalizeResStr(49652)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if self:CheckInGame() then
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_THREE, title, msg)
  else
    local btnOkStr = LocUtil.GetLocalizeResStr(49631)
    local clickOkCallback = function()
      UIManager.ShowUI(UIManager.UI_Config.UGC_ConcernManage_Popup_UIBP)
    end
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, msg, clickOkCallback, nil, btnOkStr, nil, {
      showUIKey = "com_msg_small_box_slua"
    })
  end
end
function LogicUGCAuthor:ProcPlayerUpdateFollowListRsp(operate_type, author_uid)
  if operate_type == 0 then
    ShowNotice(49628)
  else
    ShowNotice(49627)
  end
  self:SetAuthorFollowStatus(author_uid, operate_type)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR_FOLLOW_STATUS, author_uid)
end
function LogicUGCAuthor:ProcGetFollowListRsp(max_follow_num, follow_list)
  self.max_follow_num = max_follow_num or 0
  self.follow_list = follow_list or {}
  for uid, v in pairs(follow_list) do
    self:SetAuthorFollowStatus(uid, 1)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_FOLLOW_AUTHOR_LIST, follow_list)
end
function LogicUGCAuthor:GetMyAuthorSummaryData()
  return self.MyAuthorSummaryData
end
function LogicUGCAuthor:SetMyAuthorSummaryData(summaryData)
  self.MyAuthorSummaryData = summaryData
  log_tree(bWriteLog and "LogicUGCAuthor:SetMyAuthorSummaryData, summaryData: ", summaryData)
  if self.MyAuthorSummaryData and next(self.MyAuthorSummaryData) then
    local TotalTime = math.floor(self.MyAuthorSummaryData.total_play_total_time and self.MyAuthorSummaryData.total_play_total_time / 3600 or 0)
    local rank_data = require("client.slua.logic.rank.rank_data")
    local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
    rank_data.SetSelfRankData({
      uid = tonumber(DataMgr.roleData.uid),
      total_play_total_time = TotalTime
    }, rank_data_converter.ConvertWoWModProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF)
  end
end
function LogicUGCAuthor:CheckPlayerIsAuthorByProfile(uid)
  local AuthorInfo = self:GetAuthorSummaryInfo(uid)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if AuthorInfo and AuthorInfo.state and AuthorInfo.state == UGCMacros.ENUM_AUTHOR_STATE.Verified then
    return true
  end
  return false
end
function LogicUGCAuthor:CheckPlayerIsBanned(uid)
  if not uid then
    log(bWriteLog and "[v_yibxu] LogicUGCAuthor:CheckPlayerIsBanned uid = nil")
    return false
  end
  local AuthorInfo = self:GetAuthorInfo(uid)
  if AuthorInfo then
    return AuthorInfo.is_ban or false
  else
    log(bWriteLog and "[v_yibxu] LogicUGCAuthor:CheckPlayerIsBanned AuthorInfo = nil)")
    return false
  end
end
function LogicUGCAuthor:CheckPlayerIsAuthor(uid)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not uid then
    log(bWriteLog and "[v_yibxu] LogicUGCAuthor:CheckPlayerIsAuthor uid = nil")
    return false
  end
  local AuthorInfo = self:GetAuthorInfo(uid)
  if AuthorInfo then
    return AuthorInfo.state and AuthorInfo.state == UGCMacros.ENUM_AUTHOR_STATE.Verified
  else
    log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor CheckPlayerIsAuthor AuthorInfo = nil")
    return false
  end
end
function LogicUGCAuthor:CheckPlayerIsBannedByProfile(uid)
  uid = tonumber(uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    return self:IsBanned(false)
  end
  local AuthorInfo = self:GetAuthorSummaryInfo(uid)
  return AuthorInfo and AuthorInfo.is_ban or false
end
function LogicUGCAuthor:GetAuthorSummaryInfo(uid)
  uid = tonumber(uid)
  if not uid then
    return nil
  end
  if uid == tonumber(DataMgr.roleData.uid) then
    log_tree(bWriteLog and "LogicUGCAuthor:GetAuthorSummaryInfo ugc_author_info DataMgr", DataMgr.ugc_author_info)
    return DataMgr.ugc_author_info
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "LogicUGCAuthor:GetAuthorSummaryInfo profile = nil uid = " .. tostring(uid))
    return nil
  end
  log_tree(bWriteLog and "LogicUGCAuthor:GetAuthorSummaryInfo ugc_author_info profile", profile.ugc_author_info)
  return profile.ugc_author_info
end
function LogicUGCAuthor:GetAuthorLevelByProfile(uid)
  local AuthorInfo = self:GetAuthorSummaryInfo(uid)
  return AuthorInfo and AuthorInfo.new_level or 0
end
function LogicUGCAuthor:GetAuthorExp(callback)
  if not callback then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if self.experience and self.expReqTime and now - self.expReqTime < 60 then
    log(bWriteLog and "LogicUGCAuthor:GetAuthorExp. use Cache")
    callback(true, self.experience)
    return
  end
  self.expReqTime = now
  local url = "/ugc/author_level_info"
  local post_content = {}
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.DoPostUGCCommunityUrl(url, post_content, function(success, data)
    log(bWriteLog and string.format("LogicUGCAuthor:GetAuthorExp. success=%s, data=%s", tostring(success), tostring(data)))
    if not success then
      callback(false, nil)
      return
    end
    if data.level then
      data = data.level
    end
    self.experience = tonumber(data.experience) or 0
    callback(true, self.experience)
  end, true)
end
function LogicUGCAuthor:UpdateAuthorizedAssetList(AuthorizedAssetList, AuthorizedParameterList)
  print(bWriteLog and "LogicUGCAuthor:UpdateAuthorizedAssetList", AuthorizedParameterList)
  log_tree("AuthorizedAssetList:", AuthorizedAssetList)
  self.  self.end
function LogicUGCAuthor:InitAuthorizedAssetMap()
  print(bWriteLog and "LogicUGCAuthor:InitAuthorizedAssetMap")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    local delayPublish = CDataTable.GetTable("UGCDelayPublishConfigBluehole")
    for _, assetInfo in pairs(delayPublish) do
      local assetId = assetInfo.AssetId
      if assetId and assetInfo.AuthorizedAsset == 1 then
        self.AuthorizedAssetMap[assetId] = true
      end
    end
  else
    local delayPublish = CDataTable.GetTable("UGCDelayPublishConfig")
    if delayPublish ~= nil then
      for _, assetInfo in pairs(delayPublish) do
        local assetId = assetInfo.AssetId
        if assetId and assetInfo.AuthorizedAsset == 1 then
          self.AuthorizedAssetMap[assetId] = true
        end
      end
    end
  end
  local Cfg = CDataTable.GetTable("UGCAssetParamPublishCfg")
  for ID, ResInfo in pairs(Cfg) do
    if ResInfo.AuthorizedAssetParam == 1 then
      self.AuthorizedParameterMap[ResInfo.ID] = true
    end
  end
end
function LogicUGCAuthor:IsUnAuthorizedAsset(AssetID)
  if self.AuthorizedAssetMap[AssetID] == true then
    if self.AuthorizedAssetList ~= nil then
      for _, WhiteAssetID in pairs(self.AuthorizedAssetList) do
        if WhiteAssetID == AssetID then
          return false
        end
      end
    end
    return true
  end
  return false
end
function LogicUGCAuthor:IsUnAuthorizedParameter(ParameterID)
  if self.AuthorizedParameterMap[ParameterID] == true then
    if self.AuthorizedParameterList ~= nil then
      for _, WhiteParameterID in pairs(self.AuthorizedParameterList) do
        if WhiteParameterID == ParameterID then
          return false
        end
      end
    end
    return true
  end
  return false
end
function LogicUGCAuthor:GetUnAuthorizedAssetIDList()
  local UnAuthorizedAssetIDs = {}
  for AssetID, v in pairs(self.AuthorizedAssetMap) do
    if v == true and self:IsUnAuthorizedAsset(AssetID) then
      table.insert(UnAuthorizedAssetIDs, AssetID)
    end
  end
  return UnAuthorizedAssetIDs
end
function LogicUGCAuthor:ShowAuthorCustomBanTips(BanInfo)
  if not BanInfo then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if BanInfo.ban_type == Config_UGC.Enum_UGCCustomPic_BanType.Temporary then
    local TimeUtil = require("client.common.time_util")
    local UnBanTime = TimeUtil.FormatTime_YMDHMS(BanInfo.unban_time_stamp or 0)
    ShowNotice(LocUtil.LocalizeResFormat(8801031, UnBanTime))
  else
    ShowNotice(LocUtil.LocalizeResFormat(8801033))
  end
end
function LogicUGCAuthor:GetMineAuthorInfo()
  return DataMgr.ugc_author_info
end
function LogicUGCAuthor:UpdateMineAuthorInfo(AuthorInfo)
  if not AuthorInfo then
    log(bWriteLog and "LogicUGCAuthor:UpdateMineAuthorInfo AuthorInfo is nil")
    return
  end
  log_tree(bWriteLog and "LogicUGCAuthor:UpdateMineAuthorInfo ugc_author_info 1:", DataMgr.ugc_author_info)
  log_tree(bWriteLog and "LogicUGCAuthor:UpdateMineAuthorInfo ugc_author_info 2:", AuthorInfo)
  DataMgr.ugc_author_info = AuthorInfo
end
function LogicUGCAuthor:GetAuthorInfo(uid)
  uid = tonumber(uid)
  if not uid then
    return nil
  end
  if uid == tonumber(DataMgr.roleData.uid) then
    return self:GetMineAuthorInfo()
  else
    return self.AuthorInfoCache and self.AuthorInfoCache[uid] and self.AuthorInfoCache[uid].author_data or nil
  end
end
function LogicUGCAuthor:GetAuthorExtInfo(uid, bGuestUGCAuthorInfo)
  uid = tonumber(uid)
  if not uid then
    return nil
  end
  if uid == tonumber(DataMgr.roleData.uid) then
    return self.ugc_author_info_ext
  elseif bGuestUGCAuthorInfo then
    return self.AuthorExtInfoCache and self.AuthorExtInfoCache[uid]
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      log(bWriteLog and "LogicUGCAuthor:GetAuthorExtInfo get by profile.ugc_creator_newbie_progress = " .. tostring(profile.ugc_creator_newbie_progress))
      return profile
    else
      log(bWriteLog and "LogicUGCAuthor:GetAuthorExtInfo not profile uid = " .. tostring(uid))
      return nil
    end
  end
end
function LogicUGCAuthor:OnJumpToMine(_, _, Params)
  local JumpCheck = function()
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      ShowNotice(38768)
      return false
    end
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    if not Config_UGC.IsUGCReleased() then
      ShowNotice(116009)
      return false
    end
    if not Config_UGC.IsUGCUnlock() then
      local ugcEntry = Config_UGC.GetEntryData()
      ShowNotice(LocUtil.LocalizeResFormat(31028, ugcEntry.level_limit))
      return false
    end
    return true
  end
  if not JumpCheck() then
    return
  end
  local TabID = tonumber(Params.tabId) or 1
  local SubID = tonumber(Params.subid) or 1
  if Params.mod_rel_id then
    local OpenDetailCtx
    OpenDetailCtx = {
      type = "pending_open_rel_id",
      mod_id_rela = tonumber(Params.mod_rel_id)
    }
    if IsWoWEditor then
      UIManager.AndroidBackToLobby()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_WOW_EDITOR_TAB_LOCATION, nil, nil, OpenDetailCtx)
    else
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main, nil, nil, OpenDetailCtx)
    end
  else
    if IsWoWEditor then
      UIManager.AndroidBackToLobby()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_WOW_EDITOR_TAB_LOCATION, TabID, SubID)
    else
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main, TabID, nil, nil, SubID)
    end
    log(bWriteLog and "[v_yibxu] LogicUGCAuthor:OnJumpToMine TabID = " .. TabID .. " SubID = " .. SubID)
  end
end
function LogicUGCAuthor:OnJumpToCreate(_, _, Params)
  local TabID = tonumber(Params.tabId)
  UIManager.ShowUI(UIManager.UI_Config.ugc_create_main, TabID)
end
function LogicUGCAuthor:OnJumpToBeginnerLevel(_, _, Params)
  log(bWriteLog and "LogicUGCAuthor:OnJumpToBeginnerLevel")
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  UGCPublishHandler.send_ugc_get_tutorial_level_data_req(config_ugc_center.Config_UGC_Center_TutorialSource.club)
end
function LogicUGCAuthor:OnJumpToCreateMod(_, _, Params)
  local tabID = tonumber(Params.tabId)
  local subTabId = tonumber(Params.subTabId)
  local mapid = tonumber(Params.mapid)
  UIManager.ShowUI(UIManager.UI_Config.ugc_create_mod, tabID, subTabId, mapid)
end
function LogicUGCAuthor:OnBecomeCreator(_, _, Params)
  log(bWriteLog and "LogicUGCAuthor:OnBecomeCreator")
  if self.CheckShowBecomeAuthorSlap() then
    self.ShowBecomeAuthorSlap()
  end
end
function LogicUGCAuthor:NotifyAuthorInfoChange(ugc_author_info)
  log_tree("LogicUGCAuthor:NotifyAuthorInfoChange ugc_author_info = ", ugc_author_info)
  DataMgr.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_AUTHORINFO_CHANGE)
  self:OnNotifyAuthorInfo(nil, nil, ugc_author_info)
end
function LogicUGCAuthor.CheckShowBecomeAuthorSlap()
  if IsWoWEditor then
    return false
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if logic_return_activity_utils.IsActInProgressDay(1) and not NewFaceSlapSystem:IsInSlap() then
    log(bWriteLog and "LogicUGCAuthor.CheckShowBecomeAuthorSlap return of return player first day and is slaping")
    return false
  end
  local new_born_notify = 0
  if DataMgr.ugc_author_info then
    new_born_notify = DataMgr.ugc_author_info.new_born_notify or 0
  end
  local bFristBecomeAuthor = new_born_notify == 1
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC.  log_tree("LogicUGCAuthor.CheckShowBecomeAuthorSlap bFristBecomeAuthor = ", tostring(bFristBecomeAuthor))
  return bFristBecomeAuthor
end
function LogicUGCAuthor.ShowBecomeAuthorSlap()
  log(bWriteLog and "LogicUGCAuthor:ShowBecomeAuthorSlap")
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  if config_ugc_center.Config_UGC_Center_TutorialSource then
    UGCPublishHandler.send_ugc_get_tutorial_level_data_req(config_ugc_center.Config_UGC_Center_TutorialSource.center)
  end
  LogicUGCAuthor.BShowBecomeAuthorSlap = true
end
function LogicUGCAuthor:OnUpdateTutorialData(_, _, tutorialVersion)
  if not LogicUGCAuthor.BShowBecomeAuthorSlap then
    return
  end
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  local Config = require("client.slua.logic.creator.ugc_first_become_creator_cfg")
  local bShowStudyBtn = false
  if tutorialVersion and tutorialVersion == config_ugc_center.Config_UGC_Center_TutorialVersion.New then
    local ugc_creator_open_pass = LogicUGCCenter:GetUGCCreatorOpenPassCfgLevel()
    if ugc_creator_open_pass ~= 106 then
      bShowStudyBtn = true
    end
  end
  local extra = {bShowStudyBtn = bShowStudyBtn, bShowSlideBar = true}
  UIManager.ShowUI(UIManager.UI_Config.UGC_FirstBecomeCreator_Guide, LocUtil.GetLocalizeResStr(8973001), Config, nil, true, true, extra)
  LogicUGCAuthor.BShowBecomeAuthorSlap = false
end
function LogicUGCAuthor:RequestCreativerInfo(uid)
  log(bWriteLog and "LogicUGCAuthor:RequestCreativerInfo")
  uid = tonumber(uid)
  if not uid then
    log(bWriteLog and "LogicUGCAuthor:RequestAuthorInfo uid is nil")
    return
  end
  if self.CreativerInfo and self.CreativerInfo[uid] then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_CREATIVE_INFO, self.CreativerInfo[uid])
    return
  end
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.UGCAuthorFollow) == false then
    log(bWriteLog and "LogicUGCAuthor:RequestAuthorInfo CanClickNow")
    ShowNotice(76254)
    return
  end
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_other_creative_info_req(uid)
  if self.Modtimer then
    self:RemoveTimer(self.Modtimer)
  end
  self.Modtimer = self:AddTimerOnce(60, function()
    self:ClearCreativerCache()
  end)
end
function LogicUGCAuthor:OnCreativerInfoRsp(target_uid, sync_info)
  log(bWriteLog and "LogicUGCAuthor:OnCreativerInfoRsp")
  self.CreativerInfo[target_uid] = sync_info
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_CREATIVE_INFO, self.CreativerInfo[target_uid])
end
function LogicUGCAuthor:RequestSelfCreativerInfo()
  log(bWriteLog and "LogicUGCAuthor:RequestSelfCreativerInfo")
  if self.SelfCreativerInfo and next(self.SelfCreativerInfo) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_SELF_CREATIVE_INFO, self.SelfCreativerInfo)
    return
  end
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.UGCAuthorFollow) == false then
    log(bWriteLog and "LogicUGCAuthor:RequestSelfCreativerInfo CanClickNow")
    ShowNotice(76254)
    return
  end
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_self_creative_info_req()
  if self.Modtimer then
    self:RemoveTimer(self.Modtimer)
  end
  self.Modtimer = self:AddTimerOnce(60, function()
    self:ClearCreativerCache()
  end)
end
function LogicUGCAuthor:OnSelfCreativerInfoRsp(sync_info)
  log(bWriteLog and "LogicUGCAuthor:OnSelfCreativerInfoRsp")
  self.SelfCreativerInfo = sync_info
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_SELF_CREATIVE_INFO, self.SelfCreativerInfo)
end
function LogicUGCAuthor:ClearCreativerCache()
  self.CreativerInfo = {}
  self.SelfCreativerInfo = {}
end
function LogicUGCAuthor:GetCopilotState()
  if self.Copilot_GM_SET_CHECK or _G.IsEditor then
    local ModuleManager = require("client.module_framework.ModuleManager")
    local Logic_UGC_Copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
    if not Logic_UGC_Copilot:CheckWoWCopilotDisplay() then
      return false
    end
    return true
  else
    return false
  end
end
function LogicUGCAuthor:NewCheckPlayerIsAuthor(uid, bGuestUGCAuthorInfo)
  log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor uid = " .. tostring(uid) .. " bGuestUGCAuthorInfo = " .. tostring(bGuestUGCAuthorInfo))
  local checkAuthorState = function(authorInfo, bGuestUGCAuthorInfo)
    if not authorInfo then
      log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor GetAuthorInfo not AuthorInfo")
      return false
    end
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local state = authorInfo.verify_source
    if not state then
      log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor no state, assuming old author")
      return true, Config_UGC.Enum_Author_Type.Old
    end
    log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor verify_source = " .. tostring(state))
    local Enum = Config_UGC.Enum_Become_Creator_Type
    if state == Enum.AnswerExemptReview then
      local ugc_ext_info = self:GetAuthorExtInfo(uid, bGuestUGCAuthorInfo)
      local ugc_creator_newbie_progress = ugc_ext_info and ugc_ext_info.ugc_creator_newbie_progress or 0
      log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor ugc_creator_newbie_progress = " .. tostring(ugc_creator_newbie_progress))
      local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      local ugc_creator_open_pass = LogicUGCCenter:GetUGCCreatorOpenPass(ugc_creator_newbie_progress)
      return ugc_creator_newbie_progress >= ugc_creator_open_pass, Config_UGC.Enum_Author_Type.New
    else
      return true, Config_UGC.Enum_Author_Type.New
    end
  end
  if bGuestUGCAuthorInfo then
    if not self:CheckPlayerIsAuthor(uid) then
      log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor CheckPlayerIsAuthor not Author")
      return false
    end
    return checkAuthorState(self:GetAuthorInfo(uid), bGuestUGCAuthorInfo)
  else
    if not self:CheckPlayerIsAuthorByProfile(uid) then
      log(bWriteLog and "LogicUGCAuthor:NewCheckPlayerIsAuthor CheckPlayerIsAuthorByProfile not Author")
      return false
    end
    return checkAuthorState(self:GetAuthorSummaryInfo(uid), bGuestUGCAuthorInfo)
  end
end
function LogicUGCAuthor:CheckBecomeCreatorState(uid)
  if not self:CheckPlayerIsAuthorByProfile(uid) then
    log(bWriteLog and "LogicUGCAuthor:CheckBecomeCreatorState not author")
    return false
  end
  local AuthorInfo = self:GetAuthorSummaryInfo(uid)
  if not AuthorInfo then
    log(bWriteLog and "LogicUGCAuthor:CheckBecomeCreatorState not AuthorInfo")
    return false
  end
  local state = AuthorInfo.verify_source
  if not state then
    log(bWriteLog and "LogicUGCAuthor:CheckBecomeCreatorState not state")
    return false
  end
  return state
end
function LogicUGCAuthor:OnNotifyAuthorInfo(_, _, attriValue)
  if not attriValue then
    log(bWriteLog and "LogicUGCAuthor:OnNotifyAuthorInfo attriValue is nil")
    return
  end
  log_tree("LogicUGCAuthor:OnNotifyAuthorInfo attriValue = ", attriValue)
  self:UpdateMineAuthorInfo(attriValue)
  if self.CheckShowBecomeAuthorSlap() then
    self.ShowBecomeAuthorSlap()
  end
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if attriValue.caring_notify_bitmap and Logic_UGC:CheckShowTips(attriValue.caring_notify_bitmap[1], Logic_UGC.PubModSucceed) then
    Logic_UGC:CheckShowPubSuccess(Logic_UGC.PubModSucceed, attriValue.caring_last_publish_mod)
  end
  self:UpdateAITips(attriValue)
  local new_born_notify = 0
  if DataMgr.ugc_author_info then
    new_born_notify = DataMgr.ugc_author_info.new_born_notify or 0
  end
  local bFristBecomeAuthor = new_born_notify == 1
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_Mine)
  if bFristBecomeAuthor then
    logic_ugc_mine:SetBecomeCreator()
  end
end
function LogicUGCAuthor:UpdateAITips(attriValue)
  if not attriValue or not attriValue.caring_notify_bitmap then
    log(bWriteLog and "LogicUGCAuthor:UpdateAITips attriValue or caring_notify_bitmap is nil")
    return
  end
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if Logic_UGC:CheckShowTips(attriValue.caring_notify_bitmap[1], Logic_UGC.AICoverResults_Succeed) then
    local data = attriValue.caring_notify_value and attriValue.caring_notify_value[Logic_UGC.AICoverResults_Succeed]
    if not data then
      log(bWriteLog and "LogicUGCAuthor:UpdateAITips succeed data is nil")
      return
    end
    local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
    logic_ugc_ai_cover_image.result_associate_ids_succeed = {}
    local StringUtil = require("common.string_util")
    logic_ugc_ai_cover_image.result_associate_ids_succeed = StringUtil.Split(data, ",")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_AICOVER_RESULT, logic_ugc_ai_cover_image.result_associate_ids_succeed)
  end
  if Logic_UGC:CheckShowTips(attriValue.caring_notify_bitmap[1], Logic_UGC.AICoverResults_Fail) then
    local data = attriValue.caring_notify_value and attriValue.caring_notify_value[Logic_UGC.AICoverResults_Fail]
    if not data then
      log(bWriteLog and "LogicUGCAuthor:UpdateAITips fail data is nil")
      return
    end
    local logic_ugc_ai_cover_image = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_ai_cover_image)
    logic_ugc_ai_cover_image.result_associate_ids_fail = {}
    local StringUtil = require("common.string_util")
    logic_ugc_ai_cover_image.result_associate_ids_fail = StringUtil.Split(data, ",")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_AICOVER_RESULT, logic_ugc_ai_cover_image.result_associate_ids_fail)
  end
end
function LogicUGCAuthor:RequestAuthorPrefabInfo(target_author_uid)
  target_author_uid = tonumber(target_author_uid)
  if not target_author_uid then
    log(bWriteLog and "LogicUGCAuthor:RequestAuthorPrefabInfo uid is nil")
    return
  end
  if self:CheckValidAuthorPrefabInfo(target_author_uid) then
    log(bWriteLog and "LogicUGCAuthor:RequestAuthorPrefabInfo have cache")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_PREFAB_AUTHOR, target_author_uid)
    return
  end
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_wow_get_user_prefab_summary_data_req(target_author_uid)
end
function LogicUGCAuthor:on_wow_get_user_prefab_summary_data_rsp(target_author_uid, prefab_summary_data)
  target_author_uid = tonumber(target_author_uid)
  if not target_author_uid then
    log(bWriteLog and "LogicUGCAuthor:on_wow_get_user_prefab_summary_data_rsp target_author_uid is nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.AuthorPrefabInfoDataTimeStamp = TimeUtil.GetServerTimeInSec()
  log_tree("LogicUGCAuthor:on_wow_get_user_prefab_summary_data_rsp prefab_summary_data ", prefab_summary_data)
  self.AuthorPrefabInfoCache[target_author_uid] = prefab_summary_data
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_PREFAB_AUTHOR, target_author_uid)
end
function LogicUGCAuthor:GetAuthorPrefabInfo(uid)
  uid = tonumber(uid)
  if not uid then
    return nil
  end
  return self.AuthorPrefabInfoCache and self.AuthorPrefabInfoCache[uid] or nil
end
function LogicUGCAuthor:CheckValidAuthorPrefabInfo(target_author_uid)
  if not target_author_uid then
    log(bWriteLog and "LogicUGCAuthor:CheckValidAuthorPrefabInfo target_author_uid is nil")
    return false
  end
  if not self.AuthorPrefabInfoCache or not self.AuthorPrefabInfoCache[target_author_uid] then
    log(bWriteLog and "LogicUGCAuthor:CheckValidAuthorPrefabInfo AuthorPrefabInfoCache is nil or not self.AuthorPrefabInfoCache[target_author_uid]")
    return false
  end
  if not self.AuthorPrefabInfoDataTimeStamp then
    log(bWriteLog and "LogicUGCAuthor:CheckValidAuthorPrefabInfo AuthorPrefabInfoDataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.AuthorPrefabInfoDataTimeStamp + self.AuthorPrefabInfoDataReqCD
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCAuthor = class(CModuleBase, nil, LogicUGCAuthor)
return CLogicUGCAuthor
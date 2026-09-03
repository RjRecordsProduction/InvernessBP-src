local LogicUGCCenter = {
  EventRedDotRecord = nil,
  bIsUGCCenter = false,
  bIsShowUGCCenterMainUI = false,
  LearnData = {},
  StoreItemList = nil,
  StoreLimitInfos = nil,
  ClearDataTimer = nil,
  bReqMission = false,
  MissionList = nil,
  MissionGlobalData = nil,
  MissionGlobalStatus = 0,
  MaxLimitBuyCount = 99,
  NoviceTeachingList = nil,
  VideoReuseFallData = {},
  bShowLv6Guide = nil,
  bOpenLvSixState = nil,
  CreatorForumSwitch = nil,
  CreatorForumSwitchOfPandora = false,
  SubTabs = {}
}
local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
function LogicUGCCenter:ctor()
  self.tutorial_version = Config_UGC_Center.Config_UGC_Center_TutorialVersion.Old
  self.UGCCreatorOpenPass = nil
  self.tutorial_extra_award_status = nil
  self.newBieLevelId = nil
end
function LogicUGCCenter:RegistEvents()
  log(bWriteLog and "[edward] LogicUGCCenter:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UGC_CENTER, self.OnJumpUrl, self)
end
function LogicUGCCenter:OnLogin(bReLogin)
  log(bWriteLog and "[edward] LogicUGCCenter:OnLogin")
end
function LogicUGCCenter:OnLogOut()
  self.bIsUGCCenter = false
  self.bIsShowUGCCenterMainUI = false
  self.VideoReuseFallData = nil
  if self.ClearDataTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.ClearDataTimer)
    self.ClearDataTimer = nil
  end
  self.bReqMission = nil
  self.bShowLv6Guide = nil
  self.bOpenLvSixState = nil
end
function LogicUGCCenter:OnPostSwitchGameStatus(preState, nextState)
  self:BackToChallenge(preState, nextState)
end
function LogicUGCCenter:OnNextDayZeroCome()
  self:ResetStoreItemList()
end
function LogicUGCCenter:OnJumpUrl(_, _, Params)
  local TabID = tonumber(Params.tabId) or 0
  local SubTabID = tonumber(Params.subtabId)
  local bCanJump = true
  if 0 < TabID then
    local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
    local TabList = Config_UGC_Center.Config_UGC_Center_Tabs
    local SubTabList = Config_UGC_Center.Config_UGC_Center_SecondTabs
    for i, v in ipairs(TabList) do
      if v.ID == TabID then
        if v.Open and not v:Open() then
          log(bWriteLog and "[edward] LogicUGCCenter:OnJumpUrl tabID id not open, = " .. TabID)
          bCanJump = false
        elseif SubTabID ~= nil and 0 < SubTabID then
          local SubTabs = SubTabList[TabID]
          if SubTabs then
            for k, SubValue in pairs(SubTabs) do
              if SubValue.ID == SubTabID and SubValue.Open and not SubValue:Open() then
                log(bWriteLog and "[edward] LogicUGCCenter:OnJumpUrl SubTabID id not open, = " .. tostring(SubTabID))
                bCanJump = false
              end
            end
          end
        end
      end
    end
  end
  if bCanJump then
    self:OpenUGCCenterMainUI(TabID, SubTabID)
  end
end
function LogicUGCCenter:OpenUGCCenterMainUI(TabID, SubTabID, extraData)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:NewCheckPlayerIsAuthor(tonumber(DataMgr.roleData.uid)) then
    UIManager.ShowUI(UIManager.UI_Config.UGC_Center_Main, TabID, SubTabID, extraData)
  else
    ShowNotice(511023)
  end
end
function LogicUGCCenter:PreEnter()
  print(bWriteLog and "[edward] LogicUGCCenter:PreEnter")
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:ReqAuthorAwardInfo()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if LobbySystem.CheckOpen(95015) and not PublishRegionMacros.IsBLUEHOLE() and not next(self.LearnData) then
    self:ReqLearnVideoList()
  end
  if LobbySystem.CheckOpen(95013) and not self.bReqMission then
    log(bWriteLog and "[v_yibxu] ReqGetMissionData")
    self:ReqGetMissionData()
  end
  self:ReqGetActiveMotivationData()
  if LobbySystem.CheckOpen(92069) and LobbySystem.CheckOpen(92072) then
    self:ReqGetCreativeSeasonCfg()
  end
  local time_ticker = require("common.time_ticker")
  if self.ClearDataTimer then
    time_ticker.RemoveTimer(self.ClearDataTimer)
    self.ClearDataTimer = nil
  end
  self.ClearDataTimer = time_ticker.AddTimerOnce(60, function()
    if not self or not self.bReqMission then
      return
    end
    self.bReqMission = false
    log(bWriteLog and "[v_yibxu] self.bReqMission = " .. tostring(self.bReqMission))
  end)
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  LogicUGCTemplate:AddTemplateTabRedDot()
  LogicUGCTemplate:UpdateTemplateTabRedDot()
end
function LogicUGCCenter:BackToChallenge(pre, next)
  if pre == GameStatus.Fighting and next == GameStatus.Lobby then
    if self.bIsShowUGCCenterMainUI then
      self.bIsShowUGCCenterMainUI = false
      local Config_UGC_Center_TabID = Config_UGC_Center.Config_UGC_Center_TabID
      log(bWriteLog and "[v_chenxxue]LogicUGCCenter:BackToChallenge")
      self:OpenUGCCenterMainUI(Config_UGC_Center_TabID.School, Config_UGC_Center_TabID.Challenge, {
        bBackFromFight = true,
        tabid = Config_UGC_Center.Config_UGC_Center_TeachingRoadNewTabsID.ChallengeLevel
      })
    end
    local TeachingLevelConfig = require("GameLua.Mod.CreativeBase.Client.NewbieGuide.Config.TeachingLevelConfig")
    local newBieLevelId1 = self:GetNewbieLevelGuideInLobby()
    if TeachingLevelConfig and newBieLevelId1 then
      local EditCfg = TeachingLevelConfig.GetLevelConfig(newBieLevelId1)
      self:CreateModTeaching(EditCfg)
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      LogicUGCCRUD.CreateNewbieLevelId = newBieLevelId1
      self:SetNewbieLevelGuideInLobby(nil)
    end
  elseif next == GameStatus.Login then
    self.bIsShowUGCCenterMainUI = false
    self.newBieLevelId = nil
  end
end
function LogicUGCCenter:SetIsUGCCenter(bIsUGCCenter)
  self.end
function LogicUGCCenter:ReqLearnVideoList()
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler:send_ugc_learn_video_list_req()
end
function LogicUGCCenter:RspLearnVideoList(Data)
  self.Learn  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  local Map = {}
  for VideoID, VideoData in pairs(self.LearnData) do
    local VideoConfig = CDataTable.GetTableData("UGCTeachVideoCfg", VideoID)
    if VideoConfig then
      if not Map[VideoConfig.Type] then
        Map[VideoConfig.Type] = {}
      end
      table.insert(Map[VideoConfig.Type], VideoConfig)
    end
  end
  local data = {}
  for key, value in pairs(Map) do
    local subTabMap = {}
    for k, v in pairs(value) do
      if not subTabMap[v.SecType] then
        subTabMap[v.SecType] = {}
      end
      table.insert(subTabMap[v.SecType], v)
    end
    data[key] = subTabMap
  end
  for key, value in pairs(data) do
    local UGCTeachVideoTypeConfig = CDataTable.GetTableData("UGCTeachVideoTypeCfg", key)
    local Desc = UGCTeachVideoTypeConfig.Name
    for k, v in pairs(value) do
      local UGCTeachVideoSubTypeConfig = CDataTable.GetTableData("UGCTeachVideoSubTypeCfg", k)
      local SubTabID
      if UGCTeachVideoSubTypeConfig then
        SubTabID = UGCTeachVideoSubTypeConfig.ID
        Desc = UGCTeachVideoSubTypeConfig.Name
      end
      UGCCenterRedDotData.AddVideoTabRedDotData(UGCTeachVideoTypeConfig.ID, SubTabID, Desc)
    end
  end
  local E_  for VideoID, VideoData in pairs(self.LearnData) do
    local VideoConfig = CDataTable.GetTableData("UGCTeachVideoCfg", VideoID)
    if VideoConfig then
      UGCCenterRedDotData.UpdateVideoSubRedDotData(VideoConfig.Type, VideoConfig.SecType, VideoID, VideoData.state == E_ActivityProgressStatus.Done and true or nil)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_LEARN_VIDEO_LIST)
end
function LogicUGCCenter:ReqWatchLearnVideo(VideoID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_watch_learn_video_req(VideoID)
end
function LogicUGCCenter:RspWatchLearnVideo(VideoID, WatchCount)
  if not self.LearnData then
    return
  end
  if self.LearnData[VideoID] then
    self.LearnData[VideoID].watch_count = WatchCount
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_LEARN_VIDEO, VideoID)
end
function LogicUGCCenter:ReqFinishLearnVideo(VideoID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_finish_learn_video_req(VideoID)
end
function LogicUGCCenter:RspFinishLearnVideo(VideoID, State)
  if not self.LearnData then
    return
  end
  if self.LearnData[VideoID] then
    self.LearnData[VideoID].state = State
    local VideoConfig = CDataTable.GetTableData("UGCTeachVideoCfg", VideoID)
    if VideoConfig then
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      UGCCenterRedDotData.UpdateVideoSubRedDotData(VideoConfig.Type, VideoConfig.SecType, VideoID, State == ActivityProgressStatus.Done and true or nil)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_LEARN_VIDEO, VideoID)
end
function LogicUGCCenter:ReqGetLearnVideoAward(VideoID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_get_learn_video_award_req(VideoID)
end
function LogicUGCCenter:RspGetLearnVideoAward(VideoID, State, Awards)
  if not self.LearnData then
    return
  end
  if self.LearnData[VideoID] then
    self.LearnData[VideoID].state = State
    local VideoConfig = CDataTable.GetTableData("UGCTeachVideoCfg", VideoID)
    if VideoConfig then
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      UGCCenterRedDotData.UpdateVideoSubRedDotData(VideoConfig.Type, VideoConfig.SecType, VideoID, self.LearnData[VideoID].state == ActivityProgressStatus.Done and true or nil)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_LEARN_AWARD, VideoID)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(Awards)
end
function LogicUGCCenter:GetTagDataByConfig(Config)
  local VideoTagMap = {}
  local tempVideoTagMap = {}
  local TagCfg = {}
  for k, v in pairs(Config) do
    if not tempVideoTagMap[v.SecType] then
      tempVideoTagMap[v.SecType] = {}
    end
    table.insert(tempVideoTagMap[v.SecType], v)
  end
  local TableUtil = require("common.table_util")
  for k, v in TableUtil.SortedPairs(tempVideoTagMap) do
    log(bWriteLog and "[v_yibxu] TableUtil.SortedPairs key = " .. k .. " value count = " .. #v)
    local UGCTeachVideoSubTypeCfg = CDataTable.GetTableData("UGCTeachVideoSubTypeCfg", k)
    if UGCTeachVideoSubTypeCfg then
      table.insert(TagCfg, UGCTeachVideoSubTypeCfg)
      log_tree("[v_yibxu] LogicUGCCenter:GetTagDataByConfig self.TagCfg = ", UGCTeachVideoSubTypeCfg)
    else
      log(bWriteLog and "[v_yibxu] LogicUGCCenter:GetTagDataByConfig UGCTeachVideoSubTypeCfg = nil !")
    end
  end
  return tempVideoTagMap, TagCfg
end
function LogicUGCCenter:GetReuseFallData(VideoTagMap, TagID)
  self.VideoReuseFallData = {}
  local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
  local TableUtil = require("common.table_util")
  local SelectSubTabID = 1
  local TempIndex = 0
  for k, v in TableUtil.SortedPairs(VideoTagMap) do
    log(bWriteLog and "[v_yibxu] TableUtil.SortedPairs  VideoTagMap key = " .. k .. " value count = " .. #v)
    TempIndex = TempIndex + 1
    if TempIndex == TagID then
      SelectSubTabID = k
    end
    local showList = {}
    local ThirdList = {}
    for k1, v1 in pairs(v) do
      if not ThirdList[v1.ThirdType] then
        ThirdList[v1.ThirdType] = {}
      end
      table.insert(ThirdList[v1.ThirdType], v1)
    end
    for key, value in TableUtil.SortedPairs(ThirdList) do
      log(bWriteLog and "[v_yibxu] TableUtil.SortedPairs  ThirdList key = " .. k .. " value count = " .. #v)
      local Spacer = {}
      Spacer.SubType = Config_UGC_Center.ItemDataType.Spacer
      table.insert(showList, Spacer)
      local TitleData = {}
      local UGCTeachVideoThirdTypeCfg = CDataTable.GetTableData("UGCTeachVideoThirdTypeCfg", key)
      if UGCTeachVideoThirdTypeCfg then
        TitleData.TitleName = UGCTeachVideoThirdTypeCfg.Name
      else
        TitleData.TitleName = ""
      end
      TitleData.SubType = Config_UGC_Center.ItemDataType.Title
      table.insert(showList, TitleData)
      local ContentDataList = {}
      ContentDataList.Data = value
      table.sort(ContentDataList.Data, function(a, b)
        if a.Sort == b.Sort then
          return a.ID < b.ID
        else
          return a.Sort < b.Sort
        end
      end)
      for i = 1, #ContentDataList.Data do
        local ContentData = {}
        ContentData.SubType = Config_UGC_Center.ItemDataType.Content
        ContentData.data = ContentDataList.Data[i]
        table.insert(showList, ContentData)
      end
    end
    table.remove(showList, 1)
    if not self.VideoReuseFallData[k] then
      self.VideoReuseFallData[k] = {}
    end
    self.VideoReuseFallData[k] = {ShowList = showList}
  end
  return self.VideoReuseFallData[SelectSubTabID]
end
function LogicUGCCenter:GetMissionConfig()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  return BasicDataServerTable:GetCacheData(data_config_marco.ugc_creator_task_table) or {}
end
function LogicUGCCenter:GetMissionDesc(MissionID)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    return "", 0
  end
  local Config = general_task_cond_cfg_simple[MissionID]
  if not Config then
    return "", 0
  end
  local RPTaskDesc = CDataTable.GetTableData("RPTaskDesc", MissionID)
  if not RPTaskDesc then
    return "", 0
  end
  local OgriDescID = RPTaskDesc.Desc
  local Desc = ""
  if RPTaskDesc then
    local FinishCnt
    local Finish = Config.finish_value
    FinishCnt = Finish
    if RPTaskDesc.Content == "" and RPTaskDesc.LocalizeContent == 0 then
      Desc = LocUtil.LocalizeResFormat(OgriDescID, FinishCnt)
    elseif RPTaskDesc.Content ~= "" then
      Desc = LocUtil.LocalizeResFormat(OgriDescID, RPTaskDesc.Content, FinishCnt)
    elseif RPTaskDesc.LocalizeContent ~= 0 then
      local Content = LocUtil.LocalizeResFormat(RPTaskDesc.LocalizeContent)
      Desc = LocUtil.LocalizeResFormat(OgriDescID, Content, FinishCnt)
    end
  end
  return Desc, Config.finish_value
end
function LogicUGCCenter:GetMissionAwardList(AwardID, JKAwardID)
  local AwardConfig
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() and JKAwardID and 0 < JKAwardID then
    AwardConfig = CDataTable.GetTableData("general_task_reward_cfg", JKAwardID)
  else
    AwardConfig = CDataTable.GetTableData("general_task_reward_cfg", AwardID)
  end
  local Awards = {}
  if AwardConfig then
    for i = 1, Config_UGC_Center.MissionAwardMaxNum do
      local ResID = AwardConfig["res_id" .. i]
      if ResID == 0 then
        break
      end
      table.insert(Awards, {
        res_id = ResID,
        count = AwardConfig["res_num" .. i] or 1,
        valid_hours = AwardConfig["res_time_limit" .. i] or 0
      })
    end
  else
    log(bWriteLog and "[edward] LogicUGCCenter:GetMissionAwardList, AwardConfig is nil, AwardID = " .. AwardID)
  end
  return Awards
end
function LogicUGCCenter:GetShowMissionList(TabID, SubTabID)
  local MissionMap = {}
  local MissionList = {}
  local MissionConfig = self:GetMissionConfig()
  for MissionID, MissionData in pairs(self.MissionList) do
    local Config = MissionConfig[MissionID]
    if Config and Config.tab_type == TabID and (TabID == Config_UGC_Center.Config_UGC_Center_MissionTabID.NewbieMission or Config.tab_subtype == SubTabID) then
      local GroupMissionID = Config.task_group_id
      if not MissionMap[GroupMissionID] then
        MissionMap[GroupMissionID] = {}
        table.insert(MissionList, Config)
      end
      local UGCAuthorMissionConfig = CDataTable.GetTableData("UGCAuthorMissionConfig", MissionID)
      table.insert(MissionMap[GroupMissionID], {
        MissionID = MissionID,
        Config = Config,
        Data = MissionData,
        Sort = UGCAuthorMissionConfig and UGCAuthorMissionConfig.SortOrder or 0,
        JumpUrl = UGCAuthorMissionConfig and UGCAuthorMissionConfig.JumpUrl or ""
      })
    end
  end
  for _, SubMissionList in pairs(MissionMap) do
    table.sort(SubMissionList, function(a, b)
      if a.Sort == b.Sort then
        return a.MissionID < b.MissionID
      else
        return a.Sort < b.Sort
      end
    end)
  end
  local E_  table.sort(MissionList, function(a, b)
    local SubMissionListA = MissionMap[a.task_group_id]
    local SubMissionListB = MissionMap[b.task_group_id]
    if SubMissionListA and SubMissionListB and #SubMissionListA == 1 and #SubMissionListB == 1 then
      local FirstSubMissionA = SubMissionListA[1]
      local FirstSubMissionB = SubMissionListB[1]
      if FirstSubMissionA.Data.task_status == FirstSubMissionB.Data.task_status then
        if a.tab_subtype_order == b.tab_subtype_order then
          return a.task_group_id < b.task_group_id
        else
          return a.tab_subtype_order < b.tab_subtype_order
        end
      elseif FirstSubMissionA.Data.task_status == E_ActivityProgressStatus.Done then
        return true
      elseif FirstSubMissionB.Data.task_status == E_ActivityProgressStatus.Done then
        return false
      else
        return FirstSubMissionA.Data.task_status < FirstSubMissionB.Data.task_status
      end
    elseif a.tab_subtype_order == b.tab_subtype_order then
      return a.task_group_id < b.task_group_id
    else
      return a.tab_subtype_order < b.tab_subtype_order
    end
  end)
  return MissionList, MissionMap
end
function LogicUGCCenter:ReqGetMissionData()
  self.bReqMission = true
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local TableList = {
    data_config_marco.ugc_creator_task_table,
    data_config_marco.general_task_cond_cfg_simple
  }
  BasicDataServerTable:BatchGetOrReqData(TableList, function()
    local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
    UGCPublishHandler.send_ugc_creator_get_task_list_req()
  end)
end
function LogicUGCCenter:RspGetMissionData(MissionList, MissionGlobalData, MissionGlobalStatus)
  self.  self.  self.MissionGlobalStatus = MissionGlobalStatus or 0
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_GET_MISSION_LIST)
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  local E_  local MissionConfig = self:GetMissionConfig()
  for MissionID, MissionData in pairs(self.MissionList) do
    local Config = MissionConfig[MissionID]
    if Config then
      if Config.tab_type == Config_UGC_Center.Config_UGC_Center_MissionTabID.NewbieMission then
        UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, 0, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
      else
        UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, Config.tab_subtype, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
      end
    end
  end
  self.bGetRewardState = true
  if self.get_season_segment_prize_req_callback then
    local rewardList = self:get_available_reward_list()
    self.get_season_segment_prize_req_callback(rewardList)
    self.get_season_segment_prize_req_callback = nil
    self.bGetRewardState = false
  end
end
function LogicUGCCenter:ReqGetMissionAward(MissionID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_creator_receive_task_award_req(MissionID)
end
function LogicUGCCenter:RspGetMissionAward(MissionID, MissionList, Awards)
  if self.MissionList then
    self.MissionList[MissionID] = MissionList[MissionID]
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_GET_MISSION_AWARD)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(Awards)
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  local E_  local MissionConfig = self:GetMissionConfig()
  local Config = MissionConfig[MissionID]
  local MissionData = self.MissionList[MissionID]
  if Config then
    if Config.tab_type == Config_UGC_Center.Config_UGC_Center_MissionTabID.NewbieMission then
      UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, 0, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
    else
      UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, Config.tab_subtype, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
    end
  end
end
function LogicUGCCenter:ReqGetTabMissionsAward(TabID, SubTabID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_creator_receive_tab_task_award_req(TabID, SubTabID)
end
function LogicUGCCenter:RspGetTabMissionsAward(TabID, SubTabID, MissionList, Awards)
  self.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_GET_MISSION_AWARD)
  local UIUtil = require("client.common.ui_util")
  local MergedAwards = UIUtil.MergeItemList(Awards)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(MergedAwards)
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  local E_  local MissionConfig = self:GetMissionConfig()
  for MissionID, MissionData in pairs(self.MissionList) do
    local Config = MissionConfig[MissionID]
    if Config then
      if Config.tab_type == Config_UGC_Center.Config_UGC_Center_MissionTabID.NewbieMission then
        UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, 0, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
      else
        UGCCenterRedDotData.UpdateMissionRedDotData(Config.tab_type, Config.tab_subtype, MissionID, MissionData.task_status == E_ActivityProgressStatus.Done and true or nil)
      end
    end
  end
end
function LogicUGCCenter:ReqRefreshMission(MissionID)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_creator_refresh_task_req(MissionID or 0)
end
function LogicUGCCenter:RspRefreshMission(MissionID, NewMissionID, MissionList, MissionGlobalData)
  if self.MissionList then
    self.MissionList[MissionID] = nil
    if MissionList[NewMissionID] then
      self.MissionList[NewMissionID] = MissionList[NewMissionID]
    end
  end
  self.  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_REFRESH_MISSION, NewMissionID)
end
function LogicUGCCenter:AsyncGetMissionAwards(callback)
  local rewardList = {}
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if not LogicUGCAuthor:NewCheckPlayerIsAuthor(DataMgr.roleData.uid) then
    callback(rewardList)
    return
  end
  if self.bGetRewardState then
    rewardList = self:get_available_reward_list()
    callback(rewardList)
    self.bGetRewardState = false
    return
  end
  self:ReqGetMissionData()
  self.get_season_segment_prize_req_end
function LogicUGCCenter:get_available_reward_list()
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  if not LobbySystem.CheckOpen(95013) then
    return {}
  end
  local ugc_task_reward_dict = {}
  for index, value in pairs(self.MissionList) do
    if value.task_status == 1 then
      local MissionConfig = self:GetMissionConfig()
      if MissionConfig[index] then
        local AwardID = MissionConfig[index].award_id
        local level, Awards = NewDayTaskSystem.GetTaskRewardCfg(AwardID)
        for _, reward in ipairs(Awards) do
          if ugc_task_reward_dict[reward.res_id] then
            ugc_task_reward_dict[reward.res_id] = ugc_task_reward_dict[reward.res_id] + reward.res_num
          else
            ugc_task_reward_dict[reward.res_id] = reward.res_num
          end
        end
      end
    end
  end
  return ugc_task_reward_dict
end
function LogicUGCCenter:GetStoreItemList()
  if self.StoreItemList then
    return self.StoreItemList
  end
  self:ReqGetStoreItemList()
  return nil
end
function LogicUGCCenter:ResetStoreItemList()
  self.StoreItemList = nil
  self.StoreLimitInfos = nil
  if UIManager.IsUIShow(UIManager.UI_Config.UGC_Center_Store) then
    self:ReqGetStoreItemList()
  end
end
function LogicUGCCenter:ReqGetStoreItemList()
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_exchange_mall_get_item_req()
end
function LogicUGCCenter:RspGetStoreItemList(ItemList, LimitInfos)
  self.StoreItemList = ItemList or {}
  self.StoreLimitInfos = LimitInfos or {}
  table.sort(self.StoreItemList, function(a, b)
    if a.product_sort == b.product_sort then
      return a.id < b.id
    else
      return a.product_sort < b.product_sort
    end
  end)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_CENTER_STORE_LIST)
end
function LogicUGCCenter:ShowBuyPanel(ShopData, LimitInfo, bIsCreativePoints)
  local TotalLimit = self.MaxLimitBuyCount
  if ShopData.limit_buy_count > 0 then
    TotalLimit = ShopData.limit_buy_count
  elseif 0 < ShopData.limit_buy_week_count then
    TotalLimit = ShopData.limit_buy_week_count
  elseif 0 < ShopData.limit_buy_day_count then
    TotalLimit = ShopData.limit_buy_day_count
  end
  local HasBuyNum = 0
  if LimitInfo then
    HasBuyNum = LimitInfo.has_buy_num or 0
  end
  local Price = bIsCreativePoints and ShopData.consume_creative_points or ShopData.consume_wow_coin
  local Data = {
    itemId = ShopData.resid,
    itemNum = ShopData.count,
    validTime = ShopData.valid_hours,
    timeLimits = TotalLimit,
    hasExchangeCount = HasBuyNum,
    needItemId = bIsCreativePoints and 1081 or 1129,
    needItemNum = Price,
    shopId = ShopData.id
  }
  local Extra = {
    sTitle = LocUtil.GetLocalizeResStr(43327),
    bIsHideAddMaxBtn = true,
    bIsHideUpperLimitText = TotalLimit == self.MaxLimitBuyCount,
    fExchangeCallback = function(Exchange, SelectCount)
      local TotalPrice = SelectCount * Exchange.needItemNum
      local CurrentMoney = bIsCreativePoints and DataMgr.wow_creation_score or DataMgr.ugc_advanced_crystal
      if TotalPrice > CurrentMoney then
        local Tips = bIsCreativePoints and 8600082 or 540007
        ShowNotice(Tips)
        if not bIsCreativePoints then
          local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
          CommonPayBoxMgr.ShowWOWRechargeMsg(TotalPrice, CommonPayBoxMgr.E_UGCWOWCoinFrom.CenterStore)
        end
        return
      end
      self:ReqBuyStoreItem(Exchange.shopId, SelectCount)
    end,
    nShowAddCount = 10
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP, Data, Extra)
end
function LogicUGCCenter:ReqBuyStoreItem(ShopID, Count)
  log(bWriteLog and "[edward] LogicUGCCenter:ReqBuyStoreItem ,ShopID, Count = " .. string.format("%d %d", ShopID, Count))
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_exchange_mall_exchange_item_req(ShopID, Count)
end
function LogicUGCCenter:RspBuyStoreItem(LimitInfos, Items)
  self.StoreLimitInfos = LimitInfos or {}
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_BUY_CENTER_STORE_ITEM)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(Items)
end
function LogicUGCCenter:OnUGCTutorialLevelDataRsp(levelList, tutorial_version, need_version_select, extra_award_status, source)
  log_tree("LogicUGCCenter:OnUGCTutorialLevelDataRsp levelList", levelList)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if need_version_select and not LogicUGCAuthor:NewCheckPlayerIsAuthor(DataMgr.roleData.uid) then
    local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
    local extraData = {
      littleTips = LocUtil.GetLocalizeResStr(2026032165)
    }
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, LocUtil.GetLocalizeResStr(5077), LocUtil.GetLocalizeResStr(2026032164), function()
      local str = string.format("uid=%s&version=%d", DataMgr.roleData.uid, 2)
      local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Tutorial_VersionSelect, 0, str)
      UGCPublishHandler.send_ugc_tutorial_version_select_req(2)
    end, function()
      local str = string.format("uid=%s&version=%d", DataMgr.roleData.uid, 1)
      local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
      UGCTLogReport:ReportDelay(TLogEventDefine.UGC_Tutorial_VersionSelect, 0, str)
      UGCPublishHandler.send_ugc_tutorial_version_select_req(1)
    end, nil, nil, extraData)
  else
    local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
    if source == config_ugc_center.Config_UGC_Center_TutorialSource.club then
      if tutorial_version == 1 then
        UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_UIBP)
      elseif tutorial_version == 2 then
        UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_NEW_UIBP)
      end
    end
  end
  self:SetTutorialVersion(tutorial_version)
  self:SetTutorialExtraAwardStatus(extra_award_status)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_REFRESH_TUTORIAL_TAB, tutorial_version)
  self:RefreshNoviceTeachingData(1, levelList)
end
function LogicUGCCenter:SetTutorialVersion(tutorial_version)
  self.tutorial_version = tutorial_version or Config_UGC_Center.Config_UGC_Center_TutorialVersion.Old
end
function LogicUGCCenter:GetTutorialVersion()
  return self.tutorial_version
end
function LogicUGCCenter:SetTutorialExtraAwardStatus(extra_award_status)
  log_tree(bWriteLog and " LogicUGCCenter:SetTutorialExtraAwardStatus extra_award_status = ", extra_award_status)
  self.tutorial_end
function LogicUGCCenter:GetTutorialExtraAwardStatus()
  return self.tutorial_extra_award_status
end
function LogicUGCCenter:SetUGCCreatorOpenPass(level)
  log(bWriteLog and "LogicUGCCenter:SetUGCCreatorOpenPass level = " .. tostring(level))
  self.UGCCreatorOpenPass = level
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_GET_CREATOROPENPASS)
end
function LogicUGCCenter:GetUGCCreatorOpenPass(ugc_creator_newbie_progress)
  if 101 <= ugc_creator_newbie_progress and ugc_creator_newbie_progress <= 106 or ugc_creator_newbie_progress == 0 then
    return self:GetUGCCreatorOpenPassCfgLevel()
  end
  if 1 <= ugc_creator_newbie_progress and ugc_creator_newbie_progress <= 6 then
    return 6
  end
  return 0
end
function LogicUGCCenter:CheckIsNewLevel(level_id)
  log(bWriteLog and "LogicUGCCenter:CheckIsNewLevel level_id = " .. tostring(level_id))
  if not level_id then
    log(bWriteLog and "LogicUGCCenter:CheckIsNewLevel level_id is nil")
    return false
  end
  if level_id == 0 then
    return true
  end
  if 101 <= level_id and level_id <= 106 then
    return true
  end
  return false
end
function LogicUGCCenter:GetUGCCreatorOpenPassCfgLevel()
  return tonumber(self.UGCCreatorOpenPass) or 0
end
function LogicUGCCenter:OnGetTutorialExtraAwardRsp(award_list_client_format, extra_award_granted)
  local UIUtil = require("client.common.ui_util")
  local MergedAwards = UIUtil.MergeItemList(award_list_client_format)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(MergedAwards)
  local extra_awards_status = self:GetTutorialExtraAwardStatus()
  extra_awards_status.extra_award_status = extra_award_granted
  self:SetTutorialExtraAwardStatus(extra_awards_status)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_GET_TUTORIAL_EXTRA_AWARD)
end
function LogicUGCCenter:CheckTutorialDone()
  if not self.NoviceTeachingList or not next(self.NoviceTeachingList) then
    return false
  end
  local done_cnt = 0
  for k, v in pairs(self.NoviceTeachingList) do
    if v.MissionProgress ~= 0 then
      done_cnt = done_cnt + 1
    end
  end
  local TableUtil = require("common.table_util")
  if done_cnt == TableUtil.CountTable(self.NoviceTeachingList) then
    return true
  end
  return false
end
function LogicUGCCenter:GetIncubationAreaData(tabID)
  local LogicUGCCreativeWoW = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_creativewow)
  local ItemDatas = CDataTable.GetTable("UGCCreativeWoWTaskConfig")
  local listData = {}
  local AllData = {}
  for k, v in pairs(ItemDatas) do
    local missionInfo = LogicUGCCreativeWoW.AllMisionInfo[v.ID]
    local data = {
      ID = v.ID,
      TemplateID = v.TemplateID,
      MissionName = v.TaskName,
      MissionDesc = v.TaskDesc,
      MissionReward = v.TaskReward,
      JKReward = v.JKReward,
      MissionAGReward = v.AGReward,
      LuaConfigPath = v.LuaConfigPath,
      MissionNum = v.TaskNum,
      MissionBgPath = v.BgPath,
      PreMissionID = v.PreTaskID or 0,
      Difficulty = v.Difficulty,
      MissionProgress = missionInfo and missionInfo.MissionProgress or 0,
      bIsUGCCenter = true,
      tabIndex = tabID
    }
    if v.ResourceList_a then
      data.ResourceList = {}
      for id, value in pairs(v.ResourceList_a) do
        table.insert(data.ResourceList, value)
      end
    end
    if data.MissionProgress >= data.MissionNum then
      data.MissionCompleted = true
    else
      data.MissionCompleted = false
    end
    table.insert(listData, data)
    AllData[v.ID] = data
  end
  for k, v in pairs(listData) do
    if v.PreMissionID <= 0 then
      v.bPreMissionCompleted = true
    else
      local preMissionInfo = AllData[v.PreMissionID]
      if not preMissionInfo then
        v.bPreMissionCompleted = true
      else
        v.bPreMissionCompleted = preMissionInfo.MissionCompleted
      end
    end
  end
  return listData
end
function LogicUGCCenter:GetNoviceTeachingData(BelongTabID)
  local NoviceTeachingList
  if BelongTabID then
    NoviceTeachingList = {}
    for _, value in pairs(self.NoviceTeachingList or {}) do
      if value.BelongTabID == BelongTabID then
        table.insert(NoviceTeachingList, value)
      end
    end
  else
    NoviceTeachingList = self.NoviceTeachingList
  end
  return NoviceTeachingList
end
function LogicUGCCenter:GetBeginnerLevelNewData(ugc_creator_open_pass)
  local data = {}
  for _, value in pairs(self.NoviceTeachingList or {}) do
    if ugc_creator_open_pass >= value.ID then
      table.insert(data, value)
    end
  end
  return data
end
function LogicUGCCenter:CheckNoviceTeachingFinish()
  if self.NoviceTeachingList then
    for _, value in pairs(self.NoviceTeachingList) do
      if value.MissionProgress ~= 1 and value.MissionProgress ~= 2 then
        return false
      end
    end
    return true
  end
  return false
end
function LogicUGCCenter:CheckNoviceTeachingState(listData)
  if not listData or not next(listData) then
    log(bWriteLog and "[v_chenxxue]LogicUGCCenter:CheckNoviceTeachingState() listData is nil")
    return 1
  end
  local IsReceiveAward = self:CheckNoviceTeachingAwardStatus(listData)
  for index, levelData in pairs(listData) do
    if levelData.ID ~= 1 and levelData.MissionProgress == 0 then
      log(bWriteLog and "[v_chenxxue]LogicUGCCenter:CheckNoviceTeachingState() index " .. index - 1)
      return index - 1
    end
  end
  log(bWriteLog and "[v_chenxxue]LogicUGCCenter:CheckNoviceTeachingState() self.NoviceTeachingList MissionProgress is all finish")
  if IsReceiveAward then
    log(bWriteLog and "[v_chenxxue]LogicUGCCenter:CheckNoviceTeachingState() IsReceiveAward is true")
    return 1
  else
    log(bWriteLog and "[v_chenxxue]LogicUGCCenter:CheckNoviceTeachingState() IsReceiveAward is false")
    return #listData
  end
end
function LogicUGCCenter:CheckNoviceTeachingAwardStatus(listData)
  if listData then
    for _, value in pairs(listData) do
      if value.MissionProgress ~= 2 then
        return false
      end
    end
    return true
  end
  return false
end
function LogicUGCCenter:GetTeachingLevelId()
  local levelID = 0
  for _, value in pairs(self.NoviceTeachingList or {}) do
    if value.MissionProgress == 1 and levelID < value.ID then
      levelID = value.ID
    end
  end
  return levelID
end
function LogicUGCCenter:RefreshNoviceTeachingData(tabID, levelList)
  local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local tutorial_version = self:GetTutorialVersion()
  local toturial_cfg = CDataTable.GetTable("UGCNoviceTeachingConfig")
  local ItemDatas = {}
  for _, v in pairs(toturial_cfg) do
    if v.LevelVersion == tutorial_version then
      table.insert(ItemDatas, v)
    end
  end
  self.NoviceTeachingList = {}
  local AllData = {}
  local ResourceDic = {}
  for k, v in pairs(ItemDatas) do
    local missionInfo = levelList[v.ID]
    local award_list = missionInfo and missionInfo.award_list
    local data = {
      ID = v.ID,
      TemplateID = v.TemplateID,
      MissionName = v.LevelName,
      MissionDesc = v.LevelDesc,
      AwardlID = award_list and award_list[1] and award_list[1].resid,
      AwardlCount = award_list and award_list[1] and award_list[1].count,
      MissionBgPath = v.BgPath,
      MissionProgress = missionInfo and missionInfo.award_status or 0,
      tabIndex = tabID,
      BelongTabID = v.BelongTabID,
      bTeaching = true
    }
    table.insert(self.NoviceTeachingList, data)
    AllData[v.ID] = data
    ResourceDic[v.TemplateID] = true
  end
  local first_level_id = 1
  if tutorial_version == Config_UGC_Center.Config_UGC_Center_TutorialVersion.Old then
    first_level_id = 1
  elseif tutorial_version == Config_UGC_Center.Config_UGC_Center_TutorialVersion.New then
    first_level_id = 101
  end
  local TableUtil = require("common.table_util")
  local ResourceList = TableUtil.GetKeys(ResourceDic)
  for k, v in pairs(self.NoviceTeachingList) do
    v.    if first_level_id >= v.ID then
      v.bPreMissionCompleted = true
    else
      local preMissionInfo = AllData[v.ID - 1]
      if not preMissionInfo then
        v.bPreMissionCompleted = false
      else
        v.bPreMissionCompleted = preMissionInfo.MissionProgress
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CENTER_CHALLENGE_REFRESH)
  return self.NoviceTeachingList
end
function LogicUGCCenter:ReqGetTeachingLevelAward(level_id, only_report_finish, receive_all_rewards)
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_get_tutorial_level_award_req(level_id, only_report_finish, receive_all_rewards)
end
function LogicUGCCenter:RspGetTeachingLevelAward(level_id, the_award_list, tutorial_award_info)
  if not the_award_list or not next(the_award_list) then
    log(bWriteLog and "[v_chenxxue]LogicUGCCenter:RspGetTeachingLevelAward the_award_list is nil")
    return
  end
  if not tutorial_award_info then
    log(bWriteLog and "[v_chenxxue]LogicUGCCenter:RspGetTeachingLevelAward tutorial_award_info is nil")
    return
  end
  self:RefreshNoviceTeachingData(1, tutorial_award_info)
  log_tree("LogicUGCCenter:RspGetTeachingLevelAward the_award_list ", the_award_list)
  log_tree("LogicUGCCenter:RspGetTeachingLevelAward tutorial_award_info ", tutorial_award_info)
  local previewAwards = {}
  local preview_award_cfg = CDataTable.GetTable("PreviewRewards")
  local preview_ids = {}
  local preview_cnts = {}
  for _, v in ipairs(preview_award_cfg) do
    if v.RewardIDList_a then
      for id, value in pairs(v.RewardIDList_a) do
        table.insert(preview_ids, value)
      end
    end
    if v.RewardCntList_a then
      for id, value in pairs(v.RewardCntList_a) do
        table.insert(preview_cnts, value)
      end
    end
  end
  for k, v in ipairs(preview_ids) do
    table.insert(previewAwards, {
      res_id = v,
      count = preview_cnts[k]
    })
  end
  local UIUtil = require("client.common.ui_util")
  local MergedAwards = UIUtil.MergeItemList(the_award_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
  local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
  local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
  local Enum_ItemListStyle = CommonItemGet_Const.Enum_ItemListStyle
  local cur_level_id = 0
  local bGetPermission = function()
    cur_level_id = 0
    for k, v in pairs(tutorial_award_info) do
      if v.award_status ~= 0 and k > cur_level_id then
        cur_level_id = k
      end
    end
    local open_level_id = self:GetUGCCreatorOpenPass(cur_level_id)
    log(bWriteLog and "LogicUGCCenter:ReqGetTeachingLevelAward  cur_level_id = " .. tostring(cur_level_id) .. " open_level_id = " .. tostring(open_level_id))
    return open_level_id <= cur_level_id
  end
  local tAllBtnShowData_1 = {
    CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(2026032191), Enum_BtnStyle.Blue, function()
      if not bGetPermission() then
        log(bWriteLog and " not is author!")
        return
      end
      local JumpUrl = "game://?module=" .. BP_ENUM_MODULE_UGC_MINE
      GlobalData.JumpUrl(JumpUrl)
    end)
  }
  if bGetPermission() then
    tAllBtnShowData_1 = {
      CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(2026032191), Enum_BtnStyle.Blue, function()
        if not bGetPermission() then
          log(bWriteLog and " not is author!")
          return
        end
        local JumpUrl = "game://?module=" .. BP_ENUM_MODULE_UGC_MINE
        GlobalData.JumpUrl(JumpUrl)
      end),
      CommonItemGet_BtnCfgUtils.CustomNormalBtnData(LocUtil.GetLocalizeResStr(2026032190), Enum_BtnStyle.Orange, function()
        local Logic_UGC_Center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
        local tab = Config_UGC_Center.Config_UGC_Center_TabID.Store
        Logic_UGC_Center:OpenUGCCenterMainUI(tab)
      end)
    }
  end
  local tShowConfig = {
    nItemListStyle = Enum_ItemListStyle.TwoScroll,
    sMiddleTip = LocUtil.GetLocalizeResStr(2026032189),
    sTipStr = LocUtil.GetLocalizeResStr(2026032188),
    tTopTipPos = {x = 50, y = -70},
    tAllBtnShowData = tAllBtnShowData_1,
    fCloseCallback = function()
      if not bGetPermission() then
        local isNewVersion = self:CheckIsNewLevel(cur_level_id)
        log(bWriteLog and "LogicUGCCenter:RspGetTeachingLevelAward  isNewVersion = " .. tostring(isNewVersion))
        if isNewVersion then
          if not UIManager.IsUIShow(UIManager.UI_Config.UGC_Beginner_Level_NEW_UIBP) then
            UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_NEW_UIBP)
          end
        elseif not UIManager.IsUIShow(UIManager.UI_Config.UGC_Beginner_Level_UIBP) then
          UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_UIBP)
        end
      end
    end
  }
  local tAllItemData = {MergedAwards, previewAwards}
  Logic_CommonItemGet.ShowPanel_FullCustom(tAllItemData, tShowConfig)
end
function LogicUGCCenter:GetTutorialAward(level_id)
  self:ReqGetTeachingLevelAward(level_id, false, true)
  self:SetNewbieLevelId(nil)
end
function LogicUGCCenter:CreateModTeaching(TemplateData)
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
  local modifyMeta = LogicUGCCRUD:NewModifyMeta()
  modifyMeta.name = Util_UGC.NewModName(TemplateData.TemplateID)
  local templateName = modifyMeta.name
  self.showEditWorksList = Util_UGC.ModListToArray(LogicUGCCRUD:GetModeList()) or {}
  local index = 0
  for i = #self.showEditWorksList, 1, -1 do
    if modifyMeta.name == self.showEditWorksList[i].setting.name then
      index = index + 1
      modifyMeta.name = LocUtil.LocalizeResFormat(8600051, templateName, index)
    end
  end
  LogicUGCCRUD:ReqCreateMod(TemplateData.TemplateID, modifyMeta, TemplateData.ID)
end
function LogicUGCCenter:SetShowLv6Guide(bShow)
  self.bShowLv6Guide = bShow
end
function LogicUGCCenter:GetShowLv6Guide()
  return self.bShowLv6Guide
end
function LogicUGCCenter:SetOpenLv6State(bIsOpen)
  self.bOpenLvSixState = bIsOpen
end
function LogicUGCCenter:GetOpenLv6State()
  return self.bOpenLvSixState
end
function LogicUGCCenter:OnTutorialVersionSelectRsp(select_version)
  if select_version == 1 then
    UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_UIBP)
  elseif select_version == 2 then
    UIManager.ShowUI(UIManager.UI_Config.UGC_Beginner_Level_NEW_UIBP)
  end
end
function LogicUGCCenter:GetCreatorForumState()
  log(bWriteLog and "LogicUGCCenter:GetCreatorForumState--" .. tostring(self.CreatorForumSwitch))
  if self.CreatorForumSwitch ~= nil then
    self:PostCreatorForumEvent()
  else
    local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
    UGCAuthorHandler.send_ugc_get_general_button_switch_req()
    log(bWriteLog and "LogicUGCCenter:GetCreatorForumState--send_ugc_get_general_button_switch_req")
  end
end
function LogicUGCCenter:OnCreatorForumStateRsp(button_data)
  self.CreatorForumSwitch = button_data[1001] or false
  self:PostCreatorForumEvent()
end
function LogicUGCCenter:OnCreatorForumStatePandora(data)
  log_tree("LogicUGCCenter:OnCreatorForumStatePandora", data)
  if data.content == "1" and data.appId == "3156" then
    self.CreatorForumSwitchOfPandora = true
    log(bWriteLog and "LogicUGCCenter:OnCreatorForumStatePandora--true")
  end
end
function LogicUGCCenter:PostCreatorForumEvent()
  local canShow = self.CreatorForumSwitch or false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() or PublishRegionMacros.IsJapanOrKorea() then
    log(bWriteLog and "LogicUGCCenter:PostCreatorForumEvent-.IsBLUEHOLE():IsJapanOrKorea()")
    canShow = false
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CREATOR_FORUM_STATE, canShow)
  log(bWriteLog and "LogicUGCCenter:PostCreatorForumEvent-CreatorForumSwitch:" .. tostring(self.CreatorForumSwitch))
  log(bWriteLog and "LogicUGCCenter:PostCreatorForumEvent-CreatorForumOfPandora:" .. tostring(self.CreatorForumSwitchOfPandora))
end
function LogicUGCCenter:OnPandoraShowRedpoint(data)
  print(bWriteLog and "LogicUGCCenter:OnPandoraShowRedpoint")
  log_tree("LogicUGCCenter:OnPandoraShowRedpoint", data)
  if data.content == "1" then
    if data.appId == "3156" then
      if self.CreatorForumSwitch then
        local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
        UGCCenterRedDotData.AddCreatorForumRedDotData()
      end
    elseif data.appId == "3177" then
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      UGCCenterRedDotData.UpdateCenterVideoRedDotData(1)
    elseif data.appId == "3178" then
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      UGCCenterRedDotData.UpdateOfficialStoryCount(1)
    elseif data.appId == "3175" then
      local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
      UGCCenterRedDotData.UpdateBenchmarkAuthorCount(1)
    end
  elseif data.appId == "3156" then
  elseif data.appId == "3177" then
    local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
    UGCCenterRedDotData.UpdateCenterVideoRedDotData(0)
  elseif data.appId == "3178" then
    local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
    UGCCenterRedDotData.UpdateOfficialStoryCount(0)
  elseif data.appId == "3175" then
    local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
    UGCCenterRedDotData.UpdateBenchmarkAuthorCount(0)
  end
end
function LogicUGCCenter:GetCreatorForumPandoraState()
  log(bWriteLog and "LogicUGCCenter:GetCreatorForumPandoraState--" .. tostring(self.CreatorForumSwitchOfPandora))
  if self.CreatorForumSwitchOfPandora then
    return self.CreatorForumSwitchOfPandora
  else
    return false
  end
end
function LogicUGCCenter:ReqGetActiveMotivationData()
  log(bWriteLog and "LogicUGCCenter:ReqGetActiveMotivationData")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.wow_incentive_program_param_cfg, function(_, data)
    local LogicUGCWallet = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_wallet)
    LogicUGCWallet:SetMinAmount(data)
    local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
    logic_ugc_active_motivation:SetIncentiveProgramOpenLimit(data)
    local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
    LogicUGCCrystalIncentive:SetCrystalIncentiveProgramOpenLimit(data)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WALLET_SERVER_DATA_CALLBACK)
  end)
end
function LogicUGCCenter:ClearCreatorForumRedDotAndGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = {}
  PlayerPrefsSystem.SaveTableToFile_N(Record, PlayerPrefsSystem.ePlayerPrefsType.eUGCCreatorForumRedDot)
end
function LogicUGCCenter:ReqGetCreativeSeasonCfg()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local AllTaskConfig = {
    data_config_marco.wow_creative_season_cfg
  }
  BasicDataServerTable:BatchGetOrReqData(AllTaskConfig)
end
function LogicUGCCenter:AddIncentiveSubTab(activities)
  local TableUtil = require("common.table_util")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local config_ugc_season_template = require("client.slua.umg.ugc.SeasonTemplate.config_ugc_season_template")
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  local SubTabList = TableUtil.FastCopyTable(config_ugc_center.Config_UGC_Center_SecondTabs)
  local IncentivePlan_SubTabs = SubTabList[config_ugc_center.Config_UGC_Center_TabID.IncentivePlan]
  for i, v in pairs(activities) do
    local _ActivityTab = {
      ID = v.nActID,
      NameID = v.sName,
      Module = "UGC_Event_CollectionPage_UIBP",
      GemReport = gem_report_utils.SubEventName_UGC_Center_Activity,
      Tlog = TLogEventDefine.UGC_Center_Activity,
      Type = config_ugc_season_template.C_RequestType.match_hub
    }
    log(bwriteLog and "LogicUGCCenter:AddIncentiveSubTab v.sName = " .. tostring(v.sName))
    table.insert(IncentivePlan_SubTabs, _ActivityTab)
    local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
    UGCCenterRedDotData.AddEventSubRedDotData(v.nActID, v.sName)
    local nActID = tonumber(v.nActID)
    local count = self:GetActivityRedCnt(nActID)
    UGCCenterRedDotData.UpdateEventSubActCount(nActID, count)
  end
  self.SubTabs = SubTabList
end
function LogicUGCCenter:GetSubTab()
  if self.SubTabs and next(self.SubTabs) then
    return self.SubTabs
  else
    local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
    return config_ugc_center.Config_UGC_Center_SecondTabs
  end
end
function LogicUGCCenter:GetActivityRedCnt(nActID)
  local count = 1
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCenterMatchHubRedDot) or {}
  for i, v in pairs(Record) do
    if v == nActID then
      count = 0
      break
    end
  end
  return count
end
function LogicUGCCenter:UpdateActivityRedDotData(ActID)
  log(bWriteLog and "LogicUGCCenter:UpdateActivityRedDotData = ActID" .. tostring(ActID))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCCenterMatchHubRedDot) or {}
  for i, v in pairs(Record) do
    if v == ActID then
      return
    end
  end
  table.insert(Record, ActID)
  PlayerPrefsSystem.SaveTableToFile_N(Record, PlayerPrefsSystem.ePlayerPrefsType.eUGCCenterMatchHubRedDot)
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateEventSubActCount(ActID, 0)
end
function LogicUGCCenter:SetNewbieLevelId(LevelId)
  log(bwriteLog and "LogicUGCCenter:SetNewbieLevelId = LevelId" .. tostring(LevelId))
  self.newBieend
function LogicUGCCenter:GetNewbieLevelId()
  return self.newBieLevelId
end
function LogicUGCCenter:SetNewbieLevelGuideInLobby(LevelId)
  log(bwriteLog and "LogicUGCCenter:SetNewbieLevelGuideInLobby = LevelId" .. tostring(LevelId))
  self.newBieGuideInLobbyend
function LogicUGCCenter:GetNewbieLevelGuideInLobby()
  return self.newBieGuideInLobbyLevelId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCCenter = class(CModuleBase, nil, LogicUGCCenter)
return CLogicUGCCenter
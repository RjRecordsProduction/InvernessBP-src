local LogicSmartAssistant = {}
local utils = require("client.slua.logic.sa.SAUtils")
local Promise = require("common.Promise")
local LogicSmartAssistantToolCardCfg = require("client.slua.logic.sa.toolcard.LogicSmartAssistantToolCardCfg")
local OneClickPreviewState = {
  Empty = 0,
  InProgress = 1,
  Complete = 2
}
local NoticeLevel = {
  Shrink = 0,
  HaveReward = 1,
  BigNotice = 2
}
LogicSmartAssistant.
function LogicSmartAssistant:DefineAndResetData()
  self.LastPreviewReward = nil
  self.PreviewReward = {}
  self.ActivityReceiveReward = nil
  self.rewardEntry = {}
  self.fetchState = OneClickPreviewState.Empty
  self.MiniTVActor = nil
  self.achieveScore = 0
  self.noticeLevel = 0
  self.noticeMsg = ""
  self.noticeLevelMap = {}
  self.oneclick_reward_data = {
    clientKey = "oneclick_reward",
    cfg = LogicSmartAssistantToolCardCfg.ToolCardCfgV2.oneclick_reward,
    item_list = {},
    label_type = "reward",
    sort_weight = 999999999
  }
end
function LogicSmartAssistant:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SMARTASSISTANT_SETTING_UPDATE, self.OnSettingUpdate, self)
  self:AddCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SMARTASSISTANT_CFG_RSP, self.OnceOnCfgRsp, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.HideLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.ShowLobby, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON, self.BeginAnyCollect, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.BeginAnyCollect, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActivityChange, self)
  self:AddCommonEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_BAN_FLAG_UPDATE, self.OnBanFlagUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_OPEN, self.OnWardrobeOpen, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE, self.OnWardrobeClose, self)
  local PandoraOneclickRewardComp = require("client.slua.logic.sa.PandoraOneclickRewardComp")
  PandoraOneclickRewardComp:Init(self)
end
function LogicSmartAssistant:UpdateOneClickRewardPreviewData(bReset)
  if bReset then
    self.oneclick_reward_data.item_list = {}
    self.oneclick_reward_data.remaining_count = 0
  else
    local awardList, remainingCount = self:GetOneClickRewardList()
    self.oneclick_reward_data.item_list = awardList
    self.oneclick_reward_data.remaining_count = remainingCount
  end
  EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_TV_UPDATE_REWARD_PREVIEW)
end
function LogicSmartAssistant:_Reg(systemName, asyncGetFunc, open)
  if open and open == 1 then
    self.rewardEntry[systemName] = {
      asyncGetFunc = asyncGetFunc,
      status = OneClickPreviewState.Empty
    }
    printf("x LogicSmartAssistant:Reg %s", systemName)
  end
end
function LogicSmartAssistant:Reset()
  printf("LogicSmartAssistant:Reset")
  self.rewardEntry = {}
  self:RemoveAllTimer()
end
function LogicSmartAssistant:OnDestroy()
  printf("LogicSmartAssistant:OnDestroy")
end
function LogicSmartAssistant:_RegSystems(switchCfg)
  if next(self.rewardEntry) then
    return
  end
  log_tree("LogicSmartAssistant:_RegSystems switchCfg", switchCfg)
  local SARewardPreviewComp = require("client.slua.logic.sa.SARewardPreviewComp")
  local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
  local MapNumToSystem = OneClickMacro.MapNumToSystem
  self:_Reg("RP_TASK", SARewardPreviewComp.AsyncGetRPTaskRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_RP_TASK])
  self:_Reg("LEVEL_TASK", SARewardPreviewComp.AsyncGetLevelTaskRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_LEVEL_TASK])
  self:_Reg("ACHIEVE", SARewardPreviewComp.AsyncGetAchievementRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_ACHIEVE])
  self:_Reg("SEASON", SARewardPreviewComp.AsyncGetSeasonRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_SEASON])
  self:_Reg("DOWNLOAD", SARewardPreviewComp.AsyncGetDownloadRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_DOWNLOAD])
  self:_Reg("CORPS_TRAIN", SARewardPreviewComp.AsyncGetCorpsTrainRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_CORPS_TRAIN])
  self:_Reg("CORPS_ACTIVE_GOAL", SARewardPreviewComp.AsyncGetCorpsActiveGoalRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_CORPS_ACTIVE_GOAL])
  self:_Reg("WEEK_SIGNUP", SARewardPreviewComp.AsyncGetWeekSignRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_WEEK_SIGNUP])
  self:_Reg("RECALL_TASK", SARewardPreviewComp.AsyncGetRecallTaskRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_RECALL_TASK])
  self:_Reg("MANOR_TASK", SARewardPreviewComp.AsyncGetManorTaskRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_MANOR_TASK])
  self:_Reg("UGCCENTER_TASK", SARewardPreviewComp.AsyncGetUGCCenterRewards, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_UGC_CENTER_TASK])
  self:_Reg("ACTIVITY", SARewardPreviewComp.AsyncGetActivityRewardList, switchCfg[MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY])
end
function LogicSmartAssistant:_OnSingleComplete(systemName, rewardDic, extraData, promise)
  if rewardDic and next(rewardDic) then
    printf("x LogicSmartAssistant:_OnSingleComplete %s ids:%s", systemName, require("common.Linq").FromTable(rewardDic):Select(function(k, v)
      return k
    end):SortConcat(","))
    self.PreviewReward[systemName] = rewardDic
  else
    printf("x LogicSmartAssistant:_OnSingleComplete %s is nil or empty", systemName)
  end
  if systemName == "ACHIEVE" then
    self.achieveScore = extraData
    printf(" LogicSmartAssistant:OnComplete achieveScore:%s", self.achieveScore)
  end
  if self:_IsAllSystemReady() then
    self.fetchState = OneClickPreviewState.Complete
    self:_OnAllCompleted()
    promise:Resolve(self.PreviewReward)
  end
end
local AppendOrAccu = function(tb, id, count)
  if tb[id] then
    tb[id] = tb[id] + count
  else
    tb[id] = count
  end
end
function LogicSmartAssistant:AppendPandoraPreviewRewardList()
  local PandoraOneclickRewardComp = require("client.slua.logic.sa.PandoraOneclickRewardComp")
  local previewResult = PandoraOneclickRewardComp.previewResult
  self.PreviewReward.PANDORA_ACTIVITY = {}
  local dic = self.PreviewReward.PANDORA_ACTIVITY
  for actid, rewardList in pairs(previewResult) do
    for _, reward in pairs(rewardList) do
      AppendOrAccu(dic, reward.res_id, reward.count)
    end
  end
end
function LogicSmartAssistant:_HasAnyReward()
  local passFilter = {}
  local allowTypes = {
    1,
    2,
    3,
    4,
    5,
    6,
    8,
    9,
    10,
    11,
    12,
    13,
    15,
    16,
    21,
    26,
    27,
    30,
    33,
    66,
    100
  }
  for i = 1, #allowTypes do
    passFilter[allowTypes[i]] = true
  end
  for systemName, rewardDic in pairs(self.PreviewReward) do
    for itemId, count in pairs(rewardDic) do
      local itemConfig = CDataTable.GetTableData("Item", itemId)
      if itemConfig and passFilter[itemConfig.ItemType] then
        return true
      end
    end
  end
  return false
end
function LogicSmartAssistant:_GetTopFiveQualityRewardID()
  local passFilter = {}
  local allowTypes = {
    1,
    2,
    3,
    4,
    5,
    6,
    8,
    9,
    10,
    11,
    12,
    13,
    15,
    16,
    21,
    26,
    27,
    30,
    33,
    66,
    100
  }
  for i = 1, #allowTypes do
    passFilter[allowTypes[i]] = true
  end
  log_tree("LogicSmartAssistant:_GetTopFiveQualityRewardID PreviewReward", self.PreviewReward)
  local itemConfigSequence = {}
  for _, rewardDic in pairs(self.PreviewReward) do
    for itemId, _ in pairs(rewardDic) do
      local itemConfig = CDataTable.GetTableData("Item", itemId)
      if itemConfig and passFilter[itemConfig.ItemType] then
        itemConfigSequence[#itemConfigSequence + 1] = itemConfig
      else
        log(bWriteLog and " LogicSmartAssistant:_GetTopFiveQualityRewardID item_config is nil or ignored. id:" .. itemId)
      end
    end
  end
  table.sort(itemConfigSequence, function(a, b)
    return a.ItemQuality > b.ItemQuality
  end)
  local topFiveQualityRewardId = {}
  local take = math.min(5, #itemConfigSequence)
  for i = 1, take do
    topFiveQualityRewardId[#topFiveQualityRewardId + 1] = itemConfigSequence[i].ItemID
  end
  if bWriteLog then
    local parts = {}
    for i = 1, #topFiveQualityRewardId do
      parts[i] = tostring(topFiveQualityRewardId[i])
    end
    printf(" LogicSmartAssistant:_GetTopFiveQualityRewardID data:%s", table.concat(parts, ","))
  end
  return topFiveQualityRewardId
end
function LogicSmartAssistant:BeginAnyCollect()
  printf("LogicSmartAssistant:BeginAnyCollect")
  return self:BeginCollectRewards(false, true)
end
function LogicSmartAssistant:BeginFullCollect()
  printf("LogicSmartAssistant:BeginFullCollect")
  return self:BeginCollectRewards(true, false)
end
function LogicSmartAssistant:BeginCollectRewards(bForceStopInprogress, bAny)
  local p = Promise.new()
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV_SMART_ASSISTANT) then
    printf("LogicSmartAssistant:BeginCollectRewards not open")
    return
  end
  if not next(self.rewardEntry) then
    printf("LogicSmartAssistant:BeginCollectRewards rewardEntry is empty.")
    return
  end
  if not bForceStopInprogress and self.fetchState == OneClickPreviewState.InProgress then
    printf("LogicSmartAssistant:BeginCollectRewards fetchState is InProgress.")
    return
  end
  printf("LogicSmartAssistant:BeginCollectRewards real begin.")
  self:RemoveAllTimer()
  self.LastPreviewReward = self.PreviewReward
  self.PreviewReward = {}
  self.fetchState = OneClickPreviewState.InProgress
  for k, entry in pairs(self.rewardEntry) do
    entry.status = OneClickPreviewState.Empty
  end
  self:MarkRead(NoticeLevel.HaveReward)
  if bAny then
    local i, interval = 0, 0.2
    local bShouldBreak = false
    for k, entry in pairs(self.rewardEntry) do
      if bShouldBreak then
        goto lbl_74
      end
      i = i + 1
      self:AddTimerOnce(interval * i, function()
        entry.status = OneClickPreviewState.InProgress
        entry.asyncGetFunc(function(rewardDic, extraData)
          entry.status = OneClickPreviewState.Complete
          if rewardDic and next(rewardDic) then
            printf("x LogicSmartAssistant:BeginCollectRewards any Mode system %s has reward", k)
            self:SetNoticeLevel(NoticeLevel.HaveReward)
            p:Resolve(true)
            self:RemoveAllTimer()
            bShouldBreak = true
          end
        end)
      end)
    end
    ::lbl_74::
  else
    for k, entry in pairs(self.rewardEntry) do
      entry.status = OneClickPreviewState.InProgress
      entry.asyncGetFunc(function(rewardDic, extraData)
        entry.status = OneClickPreviewState.Complete
        self:_OnSingleComplete(k, rewardDic, extraData, p)
      end)
    end
  end
  return p
end
function LogicSmartAssistant:_IsAllSystemReady()
  for _, entry in pairs(self.rewardEntry) do
    if entry.status ~= OneClickPreviewState.Complete then
      return false
    end
  end
  return true
end
function LogicSmartAssistant:_OnAllCompleted()
  log(bWriteLog and "x LogicSmartAssistant:OnAllCompleted")
  if self:_HasAnyReward() then
    self:SetNoticeLevel(NoticeLevel.HaveReward)
  end
end
function LogicSmartAssistant:OnOneClickRewardReceiveComplete()
  log(bWriteLog and " LogicSmartAssistant:OnOneClickRewardComplete")
  self.fetchState = OneClickPreviewState.Empty
  self:MarkRead(NoticeLevel.HaveReward)
end
function LogicSmartAssistant:GetOneClickRewardIDs()
  log(bWriteLog and " LogicSmartAssistant:GetOneClickRewardIDs self.fetchState:" .. self.fetchState)
  if self.fetchState ~= OneClickPreviewState.Complete then
    return
  end
  local top_five_quality_reward_id = self:_GetTopFiveQualityRewardID()
  if next(top_five_quality_reward_id) then
    return top_five_quality_reward_id
  end
end
function LogicSmartAssistant:GetOneClickRewardList()
  if self.fetchState ~= OneClickPreviewState.Complete then
    return nil, 0
  end
  local passFilter = {}
  local allowTypes = {
    1,
    2,
    3,
    4,
    5,
    6,
    8,
    9,
    10,
    11,
    12,
    13,
    15,
    16,
    21,
    26,
    27,
    30,
    33,
    66,
    100
  }
  for i = 1, #allowTypes do
    passFilter[allowTypes[i]] = true
  end
  local itemMap = {}
  for systemName, rewardDic in pairs(self.PreviewReward) do
    for itemId, count in pairs(rewardDic) do
      local itemConfig = CDataTable.GetTableData("Item", itemId)
      if itemConfig and passFilter[itemConfig.ItemType] then
        if not itemMap[itemId] then
          itemMap[itemId] = {
            itemId = itemId,
            count = count,
                      }
        else
          itemMap[itemId].count = itemMap[itemId].count + count
        end
      end
    end
  end
  log_tree("LogicSmartAssistant:GetOneClickRerewardMap self.PreviewReward", self.PreviewReward)
  local sortedList = {}
  for itemId, itemData in pairs(itemMap) do
    table.insert(sortedList, itemData)
  end
  table.sort(sortedList, function(a, b)
    return a.itemConfig.ItemQuality > b.itemConfig.ItemQuality
  end)
  local resultList = {}
  local maxCount = 3
  for i = 1, maxCount do
    if i <= #sortedList then
      local v = {
        resid = sortedList[i].itemId
      }
      table.insert(resultList, v)
    else
      break
    end
  end
  local remainingCount = #sortedList - #resultList
  if bWriteLog then
    local Linq = require("common.Linq")
    log(bWriteLog and string.format(" LogicSmartAssistant:GetOneClickRewardList resultList:%s", Linq.FromTable(resultList):SelectV(function(v, k)
      return v.resid
    end):Concat(",")))
  end
  return resultList, remainingCount
end
function LogicSmartAssistant:GetAchieveScore()
  return self.achieveScore
end
function LogicSmartAssistant:SetNoticeLevel(level, msg)
  log(bWriteLog and " LogicSmartAssistant.SetNoticeLevel " .. level .. "  " .. tostring(msg))
  self.noticeLevelMap[level] = true
  if level >= self.noticeLevel then
    self.noticeLevel = level
    self.noticeMsg = msg
    local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
    proxy.OnNoticeLevelChanged(level, msg)
  end
  if level == NoticeLevel.HaveReward then
    local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
    local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
    SmartAssistantHandler.send_report_minitv_raw_event_req(MiniTVConst.RAW_EVENT_TYPE.HAS_AVAIL_AWARD)
  end
end
function LogicSmartAssistant:MarkRead(level)
  log(bWriteLog and " LogicSmartAssistant.MarkReaded " .. level)
  self.noticeLevelMap[level] = nil
  if self.noticeLevel == level then
    local maxLevel = 0
    for k, _ in pairs(self.noticeLevelMap) do
      if k > maxLevel then
        maxLevel = k
      end
    end
    self.noticeLevel = maxLevel
    local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
    proxy.OnNoticeLevelChanged(maxLevel, self.noticeMsg)
  end
end
function LogicSmartAssistant:GetNoticeLevel()
  local options = utils.LoadSettingOptions()
  local silent = false
  if options.silent ~= nil then
    silent = options.silent == 1
  end
  if silent then
    return 0
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if 1 < TeamUpNewSystem.GetTeamNum() then
    return 0
  end
  return self.noticeLevel
end
function LogicSmartAssistant:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and " LogicSmartAssistant.OnPreSwitchGameStatus " .. nextState .. "  " .. preState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:CancelLobbyRecommendTimer()
    self:Reset()
    self:DefineAndResetData()
  end
end
function LogicSmartAssistant:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and " LogicSmartAssistant.OnPostSwitchGameStatus " .. nextState .. "  " .. preState)
  if nextState == GameStatus.Lobby then
    self:AddTimerOnce(2, function()
      local LogicSmartAssistantCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicSmartAssistantCfg)
      local switchCfg = LogicSmartAssistantCfg:GetRewardSwitchCfg()
      if not switchCfg then
        LogicSmartAssistantCfg:send_assistant_get_cfg_req()
      else
        self:_RegSystems(switchCfg)
        self:BeginAnyCollect()
      end
      if nil == self.sd_ban_id then
        local BattleHander = require("client.network.Protocol.BattleHander")
        BattleHander.send_get_ban_id_req(240)
      end
      local logic_AIChat_Adult = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Adult)
      logic_AIChat_Adult:CallAgegateSDK()
    end)
    self:StartLobbyRecommendTimer()
  end
end
function LogicSmartAssistant:OnSettingUpdate(_, _, key, value)
  if key == "showType" then
    local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
    proxy.OnSettingSwitchTypeChanged(value)
  end
end
function LogicSmartAssistant:OnceOnCfgRsp()
  self:RemoveCommonEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_SMARTASSISTANT_CFG_RSP)
  local LogicSmartAssistantCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicSmartAssistantCfg)
  local switchCfg = LogicSmartAssistantCfg:GetRewardSwitchCfg()
  self:_RegSystems(switchCfg)
  self:BeginAnyCollect()
  local mainPageCfg = LogicSmartAssistantCfg:GetMainPageCfg()
  log_tree(" LogicSmartAssistant:OnceOnCfgRsp mainPageCfg", mainPageCfg)
  if mainPageCfg and mainPageCfg.tips and mainPageCfg.tips ~= "" then
    local id = mainPageCfg.id
    local key = "tips_" .. id
    local options = utils.LoadSettingOptions()
    log(bWriteLog and " LogicSmartAssistant:OnceOnCfgRsp options[key]", options[key])
    if options[key] == nil then
      self:SetNoticeLevel(NoticeLevel.BigNotice, LocUtil.LocalizeResFormatByStr(mainPageCfg.tips))
      options[key] = 1
      utils.SaveSettingOptions(options)
    end
  end
end
function LogicSmartAssistant:OnActivityChange(_, _, changeList)
  if changeList == nil then
    printf("LogicSmartAssistant:OnActivityChange changeList is nil")
    return
  end
  local PandoraOneclickRewardComp = require("client.slua.logic.sa.PandoraOneclickRewardComp")
  PandoraOneclickRewardComp:OnActivityListChange(changeList)
end
function LogicSmartAssistant:OnBanFlagUpdate(_, _, ban_id, flg, end_time)
  printf("LogicSmartAssistant:OnBanFlagUpdate ban_id:%s flg:%s end_time:%s", ban_id, flg, end_time)
  if ban_id == 240 then
    self.sd_ban_    self.sd_ban_    EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_BAN_FLAG_UPDATE_FOR_UI, flg, end_time)
  end
end
function LogicSmartAssistant:HideLobby()
  local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
  proxy.HideSmartAssistant()
end
function LogicSmartAssistant:ShowLobby()
  local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
  proxy.TryShowSmartAssistant()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local MergePatialTool = require("GameLua.Mod.SocialIsland.GamePlay.MergePatialTool")
local LogicSmartAssistant_V2Partial = require("client.slua.logic.sa.LogicSmartAssistant_V2Partial")
local LogicSmartAssistant_SettingPartial = require("client.slua.logic.sa.LogicSmartAssistant_SettingPartial")
MergePatialTool.MixinMany(CModuleBase, LogicSmartAssistant, {LogicSmartAssistant_V2Partial, LogicSmartAssistant_SettingPartial})
return class(CModuleBase, nil, LogicSmartAssistant)
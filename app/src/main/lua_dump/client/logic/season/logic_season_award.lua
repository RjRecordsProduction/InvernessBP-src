local logic_season_award = {}
local big_rank_award_state, small_rank_award_state, big_rank_award_item_data
function logic_season_award:OnInitialize()
  log(bWriteLog and "logic_season_award:OnInitialize")
  self:InitData()
  self:InitBigRankAwardItemData()
end
function logic_season_award:RegistEvents()
  log(bWriteLog and "logic_season_award:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.InitBigRankAwardItemData, self)
end
function logic_season_award:OnLogOut()
  big_rank_award_state = nil
  small_rank_award_state = nil
  big_rank_award_item_data = nil
end
function logic_season_award:GetRankAwardItemList(rankId)
  local itemList = {}
  self:InitBigRankAwardItemList(itemList, rankId)
  self:InitSmallRankAwardItemList(itemList, rankId)
  log_tree(bWriteLog and "logic_season_award:GetRankAwardItemList itemList:", itemList)
  return itemList
end
function logic_season_award:GetSeasonEndAwardItemList(rankId)
  local seasonEndRewardCfg = CDataTable.GetTableByFilter("SeasonEndRewardS24", "SeasonID", DataMgr.season_id)
  local cfgFind
  for _, cfg in pairs(seasonEndRewardCfg) do
    if tonumber(cfg.Condition_Param) == tonumber(rankId) then
      cfgFind = cfg
      break
    end
  end
  local awardList = {}
  if cfgFind then
    for index = 1, 4 do
      if cfgFind["RewardItemID" .. tostring(index)] > 0 then
        local itemInfo = {
          itemId = cfgFind["RewardItemID" .. tostring(index)],
          itemCount = cfgFind["RewardItem_Num" .. tostring(index)],
          itemTime = cfgFind["RewardItem_Time" .. tostring(index)],
          Condition_Desc = cfgFind.Condition_Desc
        }
        table.insert(awardList, itemInfo)
      end
    end
  end
  return awardList
end
function logic_season_award:GetSuitableBigAwardConfig()
  local awardList = {}
  for _, v in pairs(big_rank_award_state) do
    local cfg = CDataTable.GetTableData("SeasonInReward", v.id)
    if cfg then
      local award = {
        ID = cfg.ID,
        Level = cfg.Condition1_Param,
        Condition = cfg.Condition1_Desc,
        ImageUrl = self:ConvertImageUrl(cfg, 1),
        prizeStatus = v.prize_status,
        Condition2 = cfg.Condition2_Desc,
        RewardId = cfg.RewardID,
        RewardCnt = cfg.RewardNum,
        RewardShowType = cfg.RewardShowType or 0,
        DropId = cfg.RewardItemID
      }
      if GlobalData.IsJapanOrKorea() then
        award.RewardId = cfg.JKRewardID
        award.RewardCnt = cfg.JKRewardNum
        award.RewardShowType = cfg.JKRewardShowType or 0
        award.DropId = cfg.JKRewardItemID
      end
      table.insert(awardList, award)
    end
  end
  if not next(awardList) then
    log(bWriteLog and "GetSuitableBigAwardConfig awardList empty")
    return nil
  end
  table.sort(awardList, function(a, b)
    return a.Level < b.Level
  end)
  for i = 1, #awardList do
    if awardList[i] and awardList[i].prizeStatus ~= 2 then
      return awardList[i]
    end
  end
  local len = #awardList
  return awardList[len]
end
function logic_season_award:CanTakeAward()
  return self:CanTakeBigAward() or self:CanTakeSmallAward()
end
function logic_season_award:GetBigRankAwardState(id)
  return big_rank_award_state[id]
end
function logic_season_award:GetSmallRankAwardState(id)
  return small_rank_award_state[id] and small_rank_award_state[id].prize_status or 0
end
function logic_season_award:GetBigAwardConfigByRankId(rankId)
  local seasonInReward = CDataTable.GetTableByFilter("SeasonInReward", "SeasonID", DataMgr.season_id)
  for _, bigAwardCfg in pairs(seasonInReward) do
    if rankId == tonumber(bigAwardCfg.Condition1_Param) then
      return bigAwardCfg
    end
  end
  return nil
end
function logic_season_award:AsyncGetRewards(callback)
  if self.bGetRewardState then
    local rewardList = self:get_available_reward_list()
    callback(rewardList)
    self.bGetRewardState = false
    return
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_task_state_list()
  self.get_season_segment_prize_req_end
function logic_season_award:IsHonorRoadOpen()
  local SeasonSystem = require("client.logic.season.logic_season")
  local bestSegment = SeasonSystem.GetBestSegment()
  local logic_season_const = require("client.logic.season.logic_season_const")
  return bestSegment >= logic_season_const.ClassicSeason_HonorRoad_ID and self:CheckCanShowHonorRoad()
end
function logic_season_award:OpenHonorRoadPanel()
  local allInfo = {
    [1] = {
      tab = LocUtil.GetLocalizeResStr(12601),
      title = LocUtil.GetLocalizeResStr(85701),
      textInfo = {
        [1] = {
          type = 4,
          content1 = "Lobby_Season_Honor_Road_Reward_UIBP",
          handleParent = "Border_Parent"
        }
      }
    },
    [2] = {
      tab = LocUtil.GetLocalizeResStr(68588),
      title = LocUtil.GetLocalizeResStr(85701),
      textInfo = {
        [1] = {
          type = 4,
          content1 = "Lobby_Season_Honor_Road_Mark_UIBP",
          handleParent = "Border_Parent"
        }
      }
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_two, allInfo)
end
function logic_season_award:GetSeasonAwardShowList()
  local seasonInReward = CDataTable.GetTableByFilter("SeasonInReward", "SeasonID", DataMgr.season_id)
  local showList = {}
  for _, v in pairs(seasonInReward) do
    table.insert(showList, v)
  end
  table.sort(showList, function(a, b)
    return a.SortID < b.SortID
  end)
  if #showList == 0 then
    log_error(bWriteLog and "logic_season_award:GetSeasonAwardShowList showList empty. season_id = " .. tostring(DataMgr.season_id))
  end
  return showList
end
function logic_season_award:CheckCanShowHonorRoad()
  log(bWriteLog and "logic_season_award:CheckCanShowHonorRoad season_id: " .. tostring(DataMgr.season_id))
  if DataMgr.season_id and DataMgr.season_id >= 45 then
    return true
  end
  return false
end
function logic_season_award:CheckIsReachCondition1(bigAwardID)
  local cfg = CDataTable.GetTableData("SeasonInReward", bigAwardID)
  if not cfg then
    return false
  end
  local cfgCondition1 = cfg.Condition1_Param
  if not cfgCondition1 or cfgCondition1 == 0 then
    return true
  end
  local SeasonSystem = require("client.logic.season.logic_season")
  local targetSegment = cfgCondition1
  local bestSegment = SeasonSystem.GetBestSegment()
  local isReachTargetSegment = targetSegment <= bestSegment
  local targetScore = cfg.Condition1_Param2 or 0
  local bestRating = SeasonSystem.GetRankRating()
  local isReachTargetScore = targetScore <= bestRating
  local isReachPromotion = true
  local cfgCondition3 = cfg.Condition1_Param3
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bSwitch = promotion_match_util.GetPromotionSwitch()
  if bSwitch and cfgCondition3 and 0 < cfgCondition3 and cfgCondition3 <= 3 then
    local promotion_data = promotion_match_util.GetPromotionData()
    isReachPromotion = false
    if promotion_data and type(promotion_data) == "table" and promotion_data.locked_info then
      isReachPromotion = promotion_data.locked_info[cfgCondition3] and promotion_data.locked_info[cfgCondition3].status == 5 or false
    end
  end
  log_format("logic_season_award:CheckIsReachCondition1 bigAwardID=%d, targetSegment=%d, bestSegment=%d, targetScore=%d, bestRating=%d", bigAwardID, targetSegment, bestSegment, targetScore, bestRating)
  return isReachTargetSegment and isReachTargetScore and isReachPromotion
end
function logic_season_award:TakeBigRankAward(id)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_take_season_task_prize(id)
end
function logic_season_award:take_season_task_prize_rsp(ok, awards)
  if ok ~= 0 then
    ShowNotice(ok)
    if ok == 108301 then
      local SeasonHandler = require("client.network.Protocol.SeasonHandler")
      SeasonHandler.send_get_task_state_list()
    end
    return
  end
  if DataMgr.season_id > 23 then
    local decomposeList = {}
    for i, v in pairs(awards) do
      if v.season_ex_item_id then
        decomposeList[i] = {
          itemid = v.resid,
          count = v.count
        }
      end
    end
    for _, v in pairs(awards) do
      if v.season_ex_item_id then
        v.resid = v.season_ex_item_id
        v.count = v.season_ex_item_num
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(awards, decomposeList)
  else
    ShowNotice(301289)
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_task_state_list()
end
function logic_season_award:TakeSmallRankAward(task_id, index)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_task_season_segment_prize(task_id, index)
end
function logic_season_award:on_task_season_segment_prize_res(task_id)
  local award = CDataTable.GetTableData("SeasonSegmentReward", task_id)
  if not award then
    return
  end
  if small_rank_award_state[task_id] then
    small_rank_award_state[task_id].prize_status = 2
  end
  EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_UPDATE_AWARD)
end
function logic_season_award:TakeAllSeasonAwards()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_task_season_segment_prize_all_req()
end
function logic_season_award:on_task_season_segment_prize_all_rsp(awards, invoke_type)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  if invoke_type == 1 then
    SeasonHandler.send_get_task_state_list()
    return
  end
  local exAwardList = {}
  local item_map = {}
  for _, v in pairs(awards) do
    if v.season_ex_item_id then
      local exAward = {
        res_id = v.season_ex_item_id,
        count = v.season_ex_item_num,
        valid_hours = v.valid_hours,
        real_res_id = v.resid,
        real_count = v.count
      }
      table.insert(exAwardList, exAward)
    else
      self:AddOneItem(item_map, {
        res_id = v.resid,
        count = v.count,
        valid_hours = v.valid_hours
      })
    end
  end
  local awards_list = exAwardList
  for _, value in pairs(item_map) do
    if not value.valid_hours or value.valid_hours <= 0 then
      local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
      value.valid_hours = SeasonCardUtil.GetItemValidHours(value.res_id, true) or 0
    end
    table.insert(awards_list, value)
  end
  table.sort(awards_list, function(itemA, itemB)
    local itemCfgA = CDataTable.GetTableData("Item", itemA.res_id)
    local itemCfgB = CDataTable.GetTableData("Item", itemB.res_id)
    if not itemCfgA or not itemCfgB then
      return false
    end
    if itemCfgA.ItemQuality ~= itemCfgB.ItemQuality then
      return itemCfgA.ItemQuality > itemCfgB.ItemQuality
    end
    return false
  end)
  local decomposeList = {}
  for k, v in ipairs(awards_list) do
    if v.real_res_id then
      decomposeList[k] = {
        itemid = v.real_res_id,
        count = v.real_count
      }
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DecomposeStyle(awards_list, decomposeList)
  SeasonHandler.send_get_task_state_list()
end
function logic_season_award:get_task_state_list_rsp(season)
  self:InitData()
  self:UpdateBigRankAwardState(season.task_list)
  self:UpdateSmallRankAwardState(season.segment_tasks)
  EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_UPDATE_AWARD)
  self.bGetRewardState = true
  if self.get_season_segment_prize_req_callback then
    local rewardList = self:get_available_reward_list()
    self.get_season_segment_prize_req_callback(rewardList)
    self.get_season_segment_prize_req_callback = nil
    self.bGetRewardState = false
  end
end
function logic_season_award:send_season_task_dropid_content_req(dropList)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_season_task_dropid_content_req(dropList, "season_task")
end
function logic_season_award:on_season_task_dropid_content_rsp(dropList)
  big_rank_award_item_data = {}
  if dropList and next(dropList) then
    for dropId, dropCfg in pairs(dropList) do
      big_rank_award_item_data[dropId] = dropCfg
    end
  end
  EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_GET_BIG_AWARD_ITEMS)
end
function logic_season_award:get_available_reward_list()
  local rewardList = {}
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.season) then
    log(bWriteLog and "logic_season_award:get_available_reward_list not level_unlock_manager:IsFeatureUnlocked")
    return rewardList
  end
  for _, value in pairs(big_rank_award_state) do
    if value and value.prize_status and value.prize_status == 1 and value.RewardId and value.RewardCnt then
      if rewardList[value.RewardId] then
        rewardList[value.RewardId] = rewardList[value.RewardId] + value.RewardCnt
      else
        rewardList[value.RewardId] = value.RewardCnt
      end
    end
  end
  for _, value in pairs(small_rank_award_state) do
    if value and value.prize_status and value.prize_status == 1 then
      if value.RewardId1 and value.RewardCnt1 then
        if rewardList[value.RewardId1] then
          rewardList[value.RewardId1] = rewardList[value.RewardId1] + value.RewardCnt1
        else
          rewardList[value.RewardId1] = value.RewardCnt1
        end
      end
      if value.RewardId2 and value.RewardCnt2 then
        if rewardList[value.RewardId2] then
          rewardList[value.RewardId2] = rewardList[value.RewardId2] + value.RewardCnt2
        else
          rewardList[value.RewardId2] = value.RewardCnt2
        end
      end
    end
  end
  log_tree("rewardList", rewardList)
  return rewardList
end
function logic_season_award:InitBigRankAwardItemData()
  local onGetDropRsp = function(dropList)
    big_rank_award_item_data = {}
    if dropList and next(dropList) then
      for dropId, dropCfg in pairs(dropList) do
        big_rank_award_item_data[dropId] = dropCfg
      end
    end
    EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_GET_BIG_AWARD_ITEMS)
  end
  local seasonInReward = CDataTable.GetTableByFilter("SeasonInReward", "SeasonID", DataMgr.season_id)
  local dropIDList = {}
  for _, v in pairs(seasonInReward) do
    if GlobalData.IsJapanOrKorea() then
      table.insert(dropIDList, v.JKRewardItemID)
    else
      table.insert(dropIDList, v.RewardItemID)
    end
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.CE then
    self:send_season_task_dropid_content_req(dropIDList)
  else
    local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
    BasicDataDropTable:BatchGetOrReqData(dropIDList, onGetDropRsp)
  end
end
function logic_season_award:send_take_season_transition_reward_req()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_take_season_transition_reward_req()
end
function logic_season_award:on_take_season_transition_reward_rsp(err_code, itemlist)
  if err_code and 0 < err_code then
    ShowNotice(err_code)
    EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_TAKE_TRANSITION_REWARD_RSP)
    return
  end
  if itemlist and 0 < #itemlist then
    local list = {}
    for i, v in ipairs(itemlist) do
      table.insert(list, {
        res_id = v.res_id,
        count = v.res_num,
        valid_hours = v.valid_hours
      })
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(list, nil, nil, {
      fCloseCallback = function()
        EventSystem:postEvent(EVENTTYPE_SEASON_AWARD, EVENTID_SEASON_TAKE_TRANSITION_REWARD_RSP)
      end
    })
  end
end
function logic_season_award:UpdateBigRankAwardState(task_list)
  if not task_list then
    return
  end
  log_tree(bWriteLog and "UpdateBigRankAwardState task_list:", task_list)
  for k, v in pairs(task_list) do
    local cfg = CDataTable.GetTableData("SeasonInReward", k)
    if cfg ~= nil then
      local bigAwardState = 0
      if v.prize_status == 2 then
        bigAwardState = 2
      elseif v.prize_status == 1 and self:CheckIsReachCondition1(k) and v.condition2 >= cfg.Condition2_Param2 then
        bigAwardState = 1
      end
      local record = {
        id = k,
        condition2 = v.condition2,
        prize_status = bigAwardState,
        RewardId = cfg.RewardID,
        RewardCnt = cfg.RewardNum
      }
      if GlobalData.IsJapanOrKorea() then
        record.RewardId = cfg.JKRewardID
        record.RewardCnt = cfg.JKRewardNum
      end
      big_rank_award_state[k] = record
    end
  end
  local can_take_big_award = self:CanTakeBigAward()
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local reddotFlag = 0
  log(bWriteLog and string.format("UpdateBigRankAwardState DataMgr.season_id:%s, can_take_big_award:%s", DataMgr.season_id, can_take_big_award))
  if DataMgr.season_id > 23 and can_take_big_award then
    reddotFlag = 1
  end
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicNormalSegmentReward, reddotFlag)
end
function logic_season_award:UpdateSmallRankAwardState(segment_tasks)
  if not segment_tasks then
    return
  end
  local logic_season = require("client.logic.season.logic_season")
  local smallRankRewardConfig = CDataTable.GetTableByFilter(self:GetSmallRankRewardConfigName(), "SeasonID", DataMgr.season_id)
  local is_jk = GlobalData.IsJapanOrKorea() and 1 or 0
  for _, cfg in pairs(smallRankRewardConfig) do
    if cfg.IsJK == is_jk then
      local rankId = tonumber(cfg.Condition1_Param)
      local isGetReward = segment_tasks[cfg.ID]
      local smallAwardState = 0
      if isGetReward and isGetReward == 2 then
        smallAwardState = 2
      elseif rankId <= logic_season.GetBestSegment() then
        smallAwardState = 1
      end
      local record = {
        prize_status = smallAwardState,
        RewardId1 = cfg.RewardItemID1,
        RewardCnt1 = cfg.RewardItem_Num1,
        RewardId2 = cfg.RewardItemID2,
        RewardCnt2 = cfg.RewardItem_Num2
      }
      small_rank_award_state[cfg.ID] = record
    end
  end
end
function logic_season_award:InitBigRankAwardItemList(itemList, rankId)
  if not itemList then
    return
  end
  local seasonInReward = CDataTable.GetTableByFilter("SeasonInReward", "SeasonID", DataMgr.season_id)
  for _, v in pairs(seasonInReward) do
    if rankId == tonumber(v.Condition1_Param) then
      local awardItems
      if GlobalData.IsJapanOrKorea() then
        awardItems = self:GetBigRankAwardItems(v.JKRewardItemID)
      else
        awardItems = self:GetBigRankAwardItems(v.RewardItemID)
      end
      if awardItems and next(awardItems) then
        for _, itemCfg in pairs(awardItems) do
          local bigAwardState = self:GetBigRankAwardState(v.ID)
          local itemInfo = {
            itemId = itemCfg.DropItemID,
            itemCount = itemCfg.DropItemNum,
            itemTime = itemCfg.DropItemTime,
            prize_status = bigAwardState and bigAwardState.prize_status or 0,
            is_big_award = true,
            award_id = v.ID,
            sort_id = v.SortID
          }
          table.insert(itemList, itemInfo)
        end
      end
      break
    end
  end
end
function logic_season_award:InitSmallRankAwardItemList(itemList, rankId)
  local smallRankRewardConfig = CDataTable.GetTableByFilter(self:GetSmallRankRewardConfigName(), "SeasonID", DataMgr.season_id)
  local is_jk = GlobalData.IsJapanOrKorea() and 1 or 0
  for _, cfg in pairs(smallRankRewardConfig) do
    if cfg.IsJK == is_jk and rankId == tonumber(cfg.Condition1_Param) then
      local smallAwardState = self:GetSmallRankAwardState(cfg.ID)
      if cfg.RewardItemID1 and cfg.RewardItemID1 ~= 0 then
        local itemInfo = {
          itemId = cfg.RewardItemID1,
          itemCount = cfg.RewardItem_Num1,
          itemTime = cfg.RewardItem_Time1,
          prize_status = smallAwardState,
          is_big_award = false,
          award_id = cfg.ID,
          sort_id = cfg.SortID
        }
        table.insert(itemList, itemInfo)
      end
      if cfg.RewardItemID2 and cfg.RewardItemID2 ~= 0 then
        local itemInfo = {
          itemId = cfg.RewardItemID2,
          itemCount = cfg.RewardItem_Num2,
          itemTime = cfg.RewardItem_Time2,
          prize_status = smallAwardState,
          is_big_award = false,
          award_id = cfg.ID,
          sort_id = cfg.SortID
        }
        table.insert(itemList, itemInfo)
      end
      break
    end
  end
end
function logic_season_award:ConvertImageUrl(rewardData, rewardIndex)
  rewardIndex = rewardIndex or 1
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local version = "global"
  if GlobalData.IsJapanOrKorea() then
    version = "JK"
  elseif Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    version = "blue"
  end
  local url = rewardData["ImageUrl_" .. version .. "_" .. rewardIndex]
  if not url or url == "" then
    log(bWriteLog and "url is nil")
    url = rewardData["ImageUrl_global_" .. rewardIndex]
  end
  log(bWriteLog and "SeasonAwardUtil:ConvertImageUrl url = " .. tostring(url))
  return url
end
function logic_season_award:GetSmallRankRewardConfigName()
  local logic_season = require("client.logic.season.logic_season")
  local isNewSeason = logic_season.IsNewSeason()
  log(bWriteLog and "SeasonAwardUtil:GetSmallRankRewardConfigName isNewSeason:" .. tostring(isNewSeason))
  if isNewSeason then
    return "NewbieSmallRankReward"
  else
    return "SeasonSegmentReward"
  end
end
function logic_season_award:CanTakeBigAward()
  for _, state in pairs(big_rank_award_state) do
    if state.prize_status == 1 then
      return true
    end
  end
  return false
end
function logic_season_award:CanTakeSmallAward()
  for _, state in pairs(small_rank_award_state) do
    if state and state.prize_status == 1 then
      return true
    end
  end
  return false
end
function logic_season_award:GetBigRankAwardItems(dropId)
  if not big_rank_award_item_data then
    log(bWriteLog and "logic_season_award:GetBigRankAwardItems big_rank_award_item_data nil")
    return nil
  end
  return big_rank_award_item_data[dropId]
end
function logic_season_award:InitData()
  big_rank_award_state = {}
  small_rank_award_state = {}
end
function logic_season_award:AddOneItem(mapItemData, itemData)
  if not mapItemData or not itemData then
    return
  end
  itemData.valid_hours = itemData.valid_hours or 0
  local has = mapItemData[itemData.res_id]
  if has and has.valid_hours == itemData.valid_hours then
    has.count = has.count + itemData.count
  else
    mapItemData[itemData.res_id] = itemData
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSeasonAward = class(CModuleBase, nil, logic_season_award)
return CLogicSeasonAward
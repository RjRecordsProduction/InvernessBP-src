local SARewardPreviewComp = {}
local logic_oneclick_macro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
local AppendOrAccu = function(tb, id, count)
  if tb[id] then
    tb[id] = tb[id] + count
  else
    tb[id] = count
  end
end
function SARewardPreviewComp.AsyncGetDaliyTaskRewards(callback)
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  local rewardDic = {}
  if NewDayTaskSystem.DailyTasks then
    for index, value in pairs(NewDayTaskSystem.DailyTasks) do
      if value.status == 1 and value.rewards and 1 <= #value.rewards then
        for _, reward in ipairs(value.rewards) do
          printf("SARewardPreviewComp.  daily task reward.res_id:%s reward.res_num:%s", reward.res_id, reward.res_num)
          AppendOrAccu(rewardDic, reward.res_id, reward.res_num)
        end
      end
    end
  end
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.CurrentMissionTabType = 999
  UnknowPassMissionSystem.UpdateWeekMissionList()
  if UnknowPassMissionSystem.Week_Mission_List then
    for index, value in pairs(UnknowPassMissionSystem.Week_Mission_List) do
      local bIsShowReward
      if value.isEliteMission then
        bIsShowReward = UnknowPassSystem.IsBuyElite
      else
        bIsShowReward = true
      end
      if bIsShowReward and value.status == 1 and value.reward_list and 1 <= #value.reward_list then
        for _, reward in ipairs(value.reward_list) do
          printf("SARewardPreviewComp.AsyncGetDaliyTaskRewards unknown pass mission reward.res_id:%s reward.res_num:%s", reward.res_id, reward.res_num)
          AppendOrAccu(rewardDic, reward.res_id, reward.res_num)
        end
      end
    end
  end
  callback(rewardDic)
end
function SARewardPreviewComp.AsyncGetLevelTaskRewards(callback)
  if not DataMgr.levelTask or not DataMgr.levelTask.list then
    callback()
    return
  end
  log_tree("SARewardPreviewComp.AsyncGetLevelTaskRewards DataMgr.levelTask.list", DataMgr.levelTask.list)
  local LevelTaskSystem = require("client.slua.logic.task.logic_level_task")
  local done = LevelTaskSystem.TaskState.DONE
  local drop_id_list = {}
  for level, info in pairs(DataMgr.levelTask.list) do
    local levelTaskInfo = LevelTaskSystem.GetLevelTaskData(level)
    if levelTaskInfo then
      if info.level_status == done and levelTaskInfo.Award > 0 then
        table.insert(drop_id_list, levelTaskInfo.Award)
      end
      if info.task1_status == done and 0 < levelTaskInfo.Task1Award then
        table.insert(drop_id_list, levelTaskInfo.Task1Award)
      end
      if info.task2_status == done and 0 < levelTaskInfo.Task2Award then
        table.insert(drop_id_list, levelTaskInfo.Task2Award)
      end
    end
  end
  if 0 < #drop_id_list then
    local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
    BasicDataDropTable:BatchGetOrReqData(drop_id_list, function(dropList)
      local rewardDict = {}
      if dropList and next(dropList) then
        log_tree("SARewardPreviewComp.AsyncGetLevelTaskRewards", dropList)
        for dropId, dropCfg in pairs(dropList) do
          local _, cfg = next(dropCfg)
          if cfg then
            AppendOrAccu(rewardDict, cfg.DropItemID, cfg.DropItemNum)
          end
        end
      end
      callback(rewardDict)
    end)
  else
    callback()
  end
end
function SARewardPreviewComp.AsyncGetAchievementRewards(callback)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement) then
    callback()
    return
  end
  local rewardDic = {}
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local groupIdListMap = achievement_cfg_helper.CreatedMultiLvGroupIdAchiveMap()
  if not groupIdListMap then
    printf("SARewardPreviewComp.AsyncGetAchievementRewards groupIdListMap is nil")
    callback()
    return
  end
  local currVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  local achievementScore = 0
  for _, Lists in pairs(groupIdListMap) do
    for _, idList in pairs(Lists) do
      for _, id in pairs(idList) do
        local cfg = CDataTable.GetTableData("AchievementCfg", id)
        if not cfg then
          printf("SARewardPreviewComp.AsyncGetAchievementRewards AchievementCfg is nil id:%s", id)
        elseif version_util.HigherVersion(currVersion, cfg.Version) then
          local bGeted = AchieveHandler.IsGetAchRewardByID(id)
          local bCanFinish = AchieveHandler.CheckAchiveCanFinishWithCfg(id, cfg)
          if bCanFinish == true and bGeted == false then
            if cfg.AwardID ~= 0 then
              printf("SARewardPreviewComp.AsyncGetAchievementRewards id:%s,AwardID:%s,AwardNum:%s", id, cfg.AwardID, cfg.AwardNum)
              AppendOrAccu(rewardDic, cfg.AwardID, cfg.AwardNum)
            end
            if cfg.Score then
              achievementScore = achievementScore + cfg.Score
            end
          end
        end
      end
    end
  end
  callback(rewardDic, achievementScore)
end
function SARewardPreviewComp.AsyncGetSeasonRewards(callback)
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:AsyncGetRewards(callback)
end
function SARewardPreviewComp.AsyncGetActivityRewardList(callback)
  local activity_reward_dict = {}
  local SAUtils = require("client.slua.logic.sa.SAUtils")
  if SAUtils.GetIsInOneClickUI() then
    local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
    ActivityRedDot.BuildAllSystemAllRedDotOnce()
  end
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local logic_oneclick_reward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  local reddotData = logic_oneclick_reward.GetRedSystemData()
  log_tree("SARewardPreviewComp.GetActivityRewardList. reddotData ", reddotData)
  local _activity_list
  for key, value in pairs(reddotData) do
    if value.systemName == reddot_macro.SystemName.ActivityCenter then
      _activity_list = value.itemList
      break
    end
  end
  if not _activity_list or not next(_activity_list) then
    printf("SARewardPreviewComp.AsyncGetActivityRewardList activity_list is nil")
    callback(activity_reward_dict)
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityNewCenter = require("client.slua.logic.activity.logic_activity_center")
  local HandleOneAct = function(subActivity)
    if subActivity and subActivity.List and #subActivity.List > 0 and (not subActivity.EndTime or subActivity.EndTime > serverTime) then
      for key, value in pairs(subActivity.List) do
        if value.Status == 1 then
          local subType = ActivityNewCenter.GetSubActPageType(value)
          if subType ~= 1 and subType ~= 4 or value.canAwardVersion ~= "" and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), value.canAwardVersion) then
          else
            for k, v in pairs(value.Drop) do
              local SAExpireTimeUtil = require("client.slua.logic.sa.SAExpireTimeUtil")
              SAExpireTimeUtil.UpdateTimeMap(v)
              AppendOrAccu(activity_reward_dict, v.itemId, v.count)
            end
          end
        end
      end
    end
  end
  for _, values in pairs(_activity_list) do
    local subActivity = ActivityNewSystem.GetActivityByID(values.instanceID)
    if subActivity and subActivity.Type == ActivityType.ACTIVITY_TYPE_AREA_GROUP then
      local string_util = require("common.string_util")
      if subActivity.Condition then
        local conditions = string_util.SplitToNum(subActivity.Condition, ",")
        for _, id in ipairs(conditions) do
          if id ~= 0 then
            local condAct = ActivityNewSystem.GetActivityByID(id)
            HandleOneAct(condAct)
          end
        end
      end
    else
      HandleOneAct(subActivity)
    end
  end
  callback(activity_reward_dict)
end
function SARewardPreviewComp.AsyncGetDownloadRewards(callback)
  local download_reward_dict = {}
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  log_tree("SARewardPreviewComp.GetDownloadRewardList ", PufferDownloader.DownloadRewardCfg)
  for i, v in pairs(PufferDownloader.DownloadRewardCfg) do
    if not v.is_got and v.itemid1 > 0 then
      local cfg = CDataTable.GetTableDataByFilter("DownloaderNewTable", "BundleID", i)
      if cfg then
        if i == PufferConst.Enum_BundleID.Recommend then
          if PufferDownloader.RecommendReddot then
            log(bWriteLog and "OneClickRewardSystem.GetDownloadList. recommend")
            AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
          end
        else
          local state = LogicPufferBundle.GetBundleState(i)
          log(bWriteLog and "SARewardPreviewComp.AsyncGetDownloadRewards. state = " .. tostring(state))
          if state == PufferConst.ENUM_DownloadState.Done then
            local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
            if i == PufferConst.PREFETCH_BUNDLE_ID and PufferPrefetchManager:GetReserveState() ~= PufferConst.ENUM_ReserveState.CanDownload then
            else
              print(bWriteLog and string.format("SARewardPreviewComp.GetDownloadRewardList 11  i:%s v.itemid1:%s", i, v.itemid1))
              AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
            end
          end
        end
      elseif i == logic_oneclick_macro.TPlayDownloadId then
        local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
        local hasDownloaded = LogicTxMissionDownload.CheckResHasDownloaded()
        if hasDownloaded then
          print(bWriteLog and string.format("SARewardPreviewComp.GetDownloadRewardList 22  i:%s v.itemid1:%s", i, v.itemid1))
          AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
        end
      elseif i == logic_oneclick_macro.MapDinosaurTempId then
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
          v.name
        })
        if state == PufferConst.ENUM_DownloadState.Done then
          print(bWriteLog and string.format("SARewardPreviewComp.GetDownloadRewardList 33  i:%s v.itemid1:%s", i, v.itemid1))
          AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
        end
      end
    end
  end
  log_tree("SARewardPreviewComp.GetDownloadRewardList download_reward_dict", download_reward_dict)
  callback(download_reward_dict)
end
function SARewardPreviewComp.AsyncGetCorpsTrainRewards(callback)
  local rewardDict = {}
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if false == CorpsMgr.IsInCorps() then
    callback(rewardDict)
    return
  end
  local p = require("common.Promise").new(function()
    callback(rewardDict)
  end)
  local CorpsTrainingSystem = require("client.slua.logic.corps.logic_corps_training")
  local inner = function()
    local __count = 3
    local stepCounter = function()
      __count = __count - 1
      if __count == 0 then
        p:Resolve()
      end
    end
    local tb = CorpsTrainingSystem.TodayCorpsTaskList
    local dropIdList = {}
    for _, info in pairs(tb) do
      if info.status == 2 then
        local drop_id = info.drop_id
        dropIdList[#dropIdList + 1] = drop_id
      end
    end
    local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
    if next(dropIdList) then
      BasicDataDropTable:BatchGetOrReqData(dropIdList, function(dropList)
        log_tree("zxq SARewardPreviewComp.AsyncGetCorpsTrainRewards dropList", dropList)
        for dropId, dropArray in pairs(dropList) do
          for i, dropTable in pairs(dropArray) do
            if dropTable.DropItemWeight >= 1000000 then
              AppendOrAccu(rewardDict, dropTable.DropItemID, dropTable.DropItemNum)
            end
          end
        end
        stepCounter()
      end)
    else
      stepCounter()
    end
    if CorpsTrainingSystem.TodaySelfStatus == CorpsTrainingSystem.ETodaySelfStatus.Finished then
      for i, v in pairs(CorpsTrainingSystem.TodaySelfAwards) do
        AppendOrAccu(rewardDict, v.res_id, v.num)
      end
    end
    stepCounter()
    if CorpsTrainingSystem.TeamTaskStatus == 1 then
      local awardNumber = 0
      local strArry = {}
      if GlobalData.IsJapanOrKorea() then
        local StringUtil = require("common.string_util")
        strArry = StringUtil.Split(CorpsTrainingSystem.TeamTraining.JKAwardList, ";")
      else
        local StringUtil = require("common.string_util")
        strArry = StringUtil.Split(CorpsTrainingSystem.TeamTraining.AwardList, ";")
      end
      awardNumber = #strArry / 2
      for i = 1, awardNumber do
        local itemId = tonumber(strArry[i * 2 - 1])
        local count = tonumber(strArry[i * 2])
        if itemId and count then
          AppendOrAccu(rewardDict, itemId, count)
        end
      end
    end
    stepCounter()
  end
  local tb = CorpsTrainingSystem.TodayCorpsTaskList
  if not tb or next(tb) == nil then
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_training_req():Then(inner)
  else
    inner()
  end
end
function SARewardPreviewComp.AsyncGetCorpsActiveGoalRewards(callback)
  local rewardDict = {}
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if false == CorpsMgr.IsInCorps() then
    callback(rewardDict)
    return
  end
  local p = require("common.Promise").new(function()
    callback(rewardDict)
  end)
  local logic_corps_energy_mission = require("client.slua.logic.corps.logic_corps_energy_mission")
  logic_corps_energy_mission.FillAvailableEnergyReward(rewardDict, AppendOrAccu, p)
end
function SARewardPreviewComp.AsyncGetWeekSignRewards(callback)
  local rewardDict = {}
  local WeekSignMgr = require("client.slua.logic.week_sign.logic_weeksign")
  local reward = WeekSignMgr.GetCanReceiveAwards()
  if reward and next(reward) then
    for k, v in pairs(reward) do
      AppendOrAccu(rewardDict, v.id, v.count)
    end
  end
  callback(rewardDict)
end
function SARewardPreviewComp.AsyncGetRecallTaskRewards(callback)
  local rewardDict = {}
  local p = require("common.Promise").new(function()
    callback(rewardDict)
  end)
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  AssemblyActivitySystem.GetAllReceiveAward(rewardDict, AppendOrAccu, p)
end
function SARewardPreviewComp.AsyncGetManorTaskRewards(callback)
  local rewardDict = {}
  local logic_home_collection_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_task)
  if false == logic_home_collection_task:GetIsRun() then
    callback(rewardDict)
    return
  end
  local p = require("common.Promise").new(function()
    callback(rewardDict)
  end)
  logic_home_collection_task:FillFinishTaskRewardList(rewardDict, AppendOrAccu, p)
end
function SARewardPreviewComp.AsyncGetRPLevelRewards(callback)
  local rewardDict = {}
  local p = require("common.Promise").new(function()
    callback(rewardDict)
  end)
  local inner = function()
    if UnknowPassSystem.IsBuyElite == true then
      local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
      local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(true)
      if awardLevelList then
        for level, awardInfo in pairs(awardLevelList) do
          local OrdinaryAwardList = awardInfo.OrdinaryAwardList
          local EliteAwardList = awardInfo.EliteAwardList
          for _, award in pairs(OrdinaryAwardList) do
            if award.status == 1 then
              AppendOrAccu(rewardDict, award.resId, award.number)
            end
          end
          for _, award in pairs(EliteAwardList) do
            if award.status == 1 then
              AppendOrAccu(rewardDict, award.resId, award.number)
            end
          end
        end
      end
    end
    p:Resolve()
  end
  if nil == UnknowPassSystem.IsBuyElite then
    local logic_unknowpass_buy = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
    logic_unknowpass_buy.upass_buy_pass_list_req():Then(inner)
  else
    inner()
  end
end
function SARewardPreviewComp.AsyncGetUGCDaliyTaskRewards(callback)
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  if not LogicUGCTask.DailyTasks and not LogicUGCTask.WeeklyActive.received then
    callback()
    return
  end
  local rewardDic = {}
  for index, value in pairs(LogicUGCTask.DailyTasks) do
    if value.status == 1 and value.rewards and 1 <= #value.rewards then
      for _, reward in ipairs(value.rewards) do
        AppendOrAccu(rewardDic, reward.res_id, reward.res_num)
      end
    end
  end
  for index, value in pairs(LogicUGCTask.WeeklyActive.received) do
    if value.status == 1 and value.rewards and 1 <= #value.rewards then
      for _, reward in ipairs(value.rewards) do
        AppendOrAccu(rewardDic, reward.res_id, reward.res_num)
      end
    end
  end
  callback(rewardDic)
end
function SARewardPreviewComp.AsyncGetUGCCenterRewards(callback)
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  LogicUGCCenter:AsyncGetMissionAwards(callback)
end
return SARewardPreviewComp
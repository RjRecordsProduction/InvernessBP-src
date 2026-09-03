local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
local time_ticker = require("common.time_ticker")
local local MiniTvRewardHandler = require("client.network.Protocol.MiniTvRewardHandler")
local reddotMessageCenter = require("client.slua.logic.reddot.reddot_message_center")
local delegate_container = require("common.delegate_container")
delegate_container = delegate_container()
local logic_mail = require("client.slua.logic.mail.logic_mail")
local MailMacro = require("client.slua.logic.mail.mail_macro")
local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
local OneClickDataHandle = require("client.slua.logic.mini_tv.oneclick_data_handle")
local OneClickRewardSystem = {}
local LOGIN_DELTA_TIME = 3
local Messages, systemCategoryList
local AllItemsdata = {}
local AppendOrAccu = function(tb, id, count)
  if tb[id] then
    tb[id] = tb[id] + count
  else
    tb[id] = count
  end
end
local debugActivity = false
function OneClickRewardSystem.Init()
  OneClickRewardSystem.bNormalRewardFinish = false
  OneClickRewardSystem.failReason = nil
  OneClickRewardSystem.bIsApplying = false
  OneClickRewardSystem._lastSystenNum = 0
  OneClickRewardSystem.SpecicalMail = {}
  OneClickRewardSystem.SpecicalMailReason = {}
  OneClickRewardSystem.InitRedData()
end
function OneClickRewardSystem.InitRedData()
  if OneClickRewardSystem.loginTimer == nil then
    OneClickRewardSystem.loginTimer = time_ticker.AddTimerOnce(LOGIN_DELTA_TIME, function()
      Messages = reddotMessageCenter.GetMessages()
      systemCategoryList = reddotMessageCenter.GetSystemCategoryList()
      OneClickRewardSystem.loginTimer = nil
      OneClickRewardSystem.AddSystemDataListencer(systemCategoryList)
    end)
  end
end
function OneClickRewardSystem.AddSystemDataListencer(systemCategoryList)
  log_tree("zxq AddSystemDataListencer systemCategoryList ", systemCategoryList[2].map)
  for category, _ in pairs(systemCategoryList) do
    if category ~= 1 then
      return
    end
    delegate_container:AddLeafDataNewIndexListener(systemCategoryList[category].map, OneClickRewardSystem.OnHavaNewSystemName, category)
  end
end
function OneClickRewardSystem.OnHavaNewSystemName(category, key, oldValue, value)
  log(bWriteLog and "miraclerhe OneClickRewardSystem.OnHavaNewSystemName category:" .. tostring(category) .. " key:" .. tostring(key) .. " oldValue:" .. tostring(oldValue) .. " value:" .. tostring(value))
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant:BeginAnyCollect()
end
function OneClickRewardSystem.Release()
  OneClickRewardSystem.SpecicalMailReason = {}
  OneClickRewardSystem._lastSystenNum = 0
  OneClickRewardSystem.ReSet()
  if OneClickRewardSystem.loginTimer then
    time_ticker.RemoveTimer(OneClickRewardSystem.loginTimer)
    OneClickRewardSystem.loginTimer = nil
  end
end
function OneClickRewardSystem.IsApplying()
  return OneClickRewardSystem.bIsApplying
end
function OneClickRewardSystem.ReSet()
  AllItemsdata = {}
  OneClickRewardSystem.bNormalRewardFinish = false
  OneClickRewardSystem.failReason = nil
  OneClickRewardSystem.bIsApplying = false
end
function OneClickRewardSystem.GetRedSystemData()
  local UIData = {}
  local Messages = reddotMessageCenter.GetMessages()
  for _systemName, systemData in pairs(Messages or {}) do
    OneClickRewardSystem.AppendRewards(UIData, _systemName, systemData)
  end
  log_tree("[RedDotUIData] GetAvailableRewards", UIData)
  return UIData
end
function OneClickRewardSystem.AppendRewards(UIData, systemName, systemData)
  local RedDotMacro = require("client.slua.logic.reddot.reddot_macro")
  local list = {}
  for category, data in pairs(systemData) do
    if category == RedDotMacro.Category.Receive then
      for instanceID, subID in pairs(data) do
        table.insert(list, {
          category = category,
          subID = subID,
                  })
      end
    end
  end
  if next(list) then
    table.insert(UIData, {systemName = systemName, itemList = list})
  end
end
function OneClickRewardSystem.GetActivityList()
  local activity_id_list = {}
  local reddotData = OneClickRewardSystem.GetRedSystemData()
  if reddotData == nil then
    log(bWriteLog and "zxq OneClickRewardSystem.GetActivityList ActivityList is nil ")
    return
  end
  local _activity_list
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  for _, value in pairs(reddotData) do
    if value.systemName == reddot_macro.SystemName.ActivityCenter then
      _activity_list = value.itemList
    end
  end
  if _activity_list == nil or next(_activity_list) == nil then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local CollectActId = function(subActivity)
    if subActivity and subActivity.List and #subActivity.List > 0 and (not subActivity.EndTime or subActivity.EndTime > serverTime) then
      for key, value in pairs(subActivity.List) do
        if value.Status == 1 then
          local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
          local subType = ActivityUtil.GetSubActPageType(value)
          if subType ~= 1 and subType ~= 4 or value.canAwardVersion ~= "" and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), value.canAwardVersion) then
          else
            activity_id_list[value.ID] = true
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
            CollectActId(condAct)
          end
        end
      end
    else
      CollectActId(subActivity)
    end
  end
  local _activity_id_list = {}
  log_tree("zxq OneClickRewardSystem.GetActivityList _activity_id_list", activity_id_list)
  for key, value in pairs(activity_id_list) do
    if not OneClickRewardSystem.isSpecialActivity(key) then
      table.insert(_activity_id_list, key)
    end
  end
  log_tree("zxq OneClickRewardSystem.GetActivityList ActivityList", _activity_id_list)
  return _activity_id_list
end
function OneClickRewardSystem.GetActivityRewardList()
  local activity_reward_dict = {}
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local reddotData = OneClickRewardSystem.GetRedSystemData()
  log_tree("  OneClickRewardSystem.GetActivityRewardList. reddotData ", reddotData)
  local _activity_list
  for key, value in pairs(reddotData) do
    if value.systemName == reddot_macro.SystemName.ActivityCenter then
      log_warning(bWriteLog and "  OneClickRewardSystem.GetActivityRewardList.  find activity")
      _activity_list = value.itemList
      break
    end
  end
  if not _activity_list or not next(_activity_list) then
    return activity_reward_dict
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local HandleOneAct = function(subActivity)
    if subActivity and subActivity.List and #subActivity.List > 0 and (not subActivity.EndTime or subActivity.EndTime > serverTime) then
      for key, value in pairs(subActivity.List) do
        if value.Status == 1 then
          local subType = ActivityUtil.GetSubActPageType(value)
          if subType ~= 1 and subType ~= 4 or value.canAwardVersion ~= "" and not FuncUtil.CompareVersion(Client.GetApplicationVersion(), value.canAwardVersion) then
          else
            for k, v in pairs(value.Drop) do
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
  return activity_reward_dict
end
function OneClickRewardSystem.GetMailList()
  local mail_id_list = {}
  local reddotData = OneClickRewardSystem.GetRedSystemData()
  if reddotData == nil then
    log(bWriteLog and "zxq OneClickRewardSystem.GetMailList MailList is nil ")
    return
  end
  local _mailData
  for key, value in pairs(reddotData) do
    if value.systemName == "mail" then
      _mailData = value.itemList
    end
  end
  if _mailData == nil or next(_mailData) == nil then
    return
  end
  for _, datas in pairs(_mailData) do
    local length = #datas
    if datas.instanceID then
      table.insert(mail_id_list, datas.instanceID)
    elseif datas.list then
      for _, data in pairs(datas.list) do
        table.insert(mail_id_list, data.instanceID)
      end
    end
  end
  log_tree("OneClickReward mail_id_list", mail_id_list)
  return mail_id_list
end
function OneClickRewardSystem.GetSendMailList()
  local mailIdList = OneClickRewardSystem.GetMailList()
  if mailIdList == nil or next(mailIdList) == nil then
    return
  end
  local nowMailIdList = {}
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  for key, value in pairs(mailIdList) do
    local mail_info = logic_mail.GetMailInfoById(value)
    if mail_info and mail_info.opt.type ~= MailMacro.Enum_Mail_Type.Security then
      table.insert(nowMailIdList, value)
    end
  end
  return nowMailIdList
end
function OneClickRewardSystem.GetDownloadList()
  local DownLoadIdList = {}
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  log_tree("zxq OneClickRewardSystem.GetDownloadList ", PufferDownloader.DownloadRewardCfg)
  for i, v in pairs(PufferDownloader.DownloadRewardCfg) do
    if not v.is_got and v.itemid1 > 0 then
      local cfg = CDataTable.GetTableDataByFilter("DownloaderNewTable", "BundleID", i)
      if cfg then
        if i == PufferConst.Enum_BundleID.Recommend then
          log(bWriteLog and "OneClickRewardSystem.GetDownloadList. recommend")
          table.insert(DownLoadIdList, i)
        elseif LogicPufferBundle.GetBundleState(i) == PufferConst.ENUM_DownloadState.Done then
          local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
          if i == PufferConst.PREFETCH_BUNDLE_ID and PufferPrefetchManager:GetReserveState() ~= PufferConst.ENUM_ReserveState.CanDownload then
          elseif i == PufferConst.BIND_PHONE_MAIL_REWARD_ID then
            log(bWriteLog and "OneClickRewardSystem.GetDownloadList. bind phone mail ignored")
          else
            print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadList 11  i:%s v.itemid1:%s", i, v.itemid1))
            table.insert(DownLoadIdList, i)
          end
        end
      elseif i == OneClickMacro.TPlayDownloadId then
        local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
        local hasDownloaded = LogicTxMissionDownload.CheckResHasDownloaded()
        if hasDownloaded then
          print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadList 22  i:%s v.itemid1:%s", i, v.itemid1))
          table.insert(DownLoadIdList, i)
        end
      elseif i == OneClickMacro.MapDinosaurTempId then
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
          v.name
        })
        if state == PufferConst.ENUM_DownloadState.Done then
          print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadList 33  i:%s v.itemid1:%s", i, v.itemid1))
          table.insert(DownLoadIdList, i)
        end
      end
    end
  end
  log_tree("zxq OneClickRewardSystem.DownLoadIdList ", DownLoadIdList)
  return DownLoadIdList
end
function OneClickRewardSystem.GetDownloadRewardList()
  local download_reward_dict = {}
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  log_tree("zxq OneClickRewardSystem.GetDownloadRewardList ", PufferDownloader.DownloadRewardCfg)
  for i, v in pairs(PufferDownloader.DownloadRewardCfg) do
    if not v.is_got and v.itemid1 > 0 then
      local cfg = CDataTable.GetTableDataByFilter("DownloaderNewTable", "BundleID", i)
      if cfg then
        if LogicPufferBundle.GetBundleState(i) == PufferConst.ENUM_DownloadState.Done then
          local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
          if i == PufferConst.PREFETCH_BUNDLE_ID and PufferPrefetchManager:GetReserveState() ~= PufferConst.ENUM_ReserveState.CanDownload then
          else
            print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadRewardList 11  i:%s v.itemid1:%s", i, v.itemid1))
            AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
          end
        end
      elseif i == OneClickMacro.TPlayDownloadId then
        local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
        local hasDownloaded = LogicTxMissionDownload.CheckResHasDownloaded()
        if hasDownloaded then
          print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadRewardList 22  i:%s v.itemid1:%s", i, v.itemid1))
          AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
        end
      elseif i == OneClickMacro.MapDinosaurTempId then
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
          v.name
        })
        if state == PufferConst.ENUM_DownloadState.Done then
          print(bWriteLog and string.format(" OneClickRewardSystem.GetDownloadRewardList 33  i:%s v.itemid1:%s", i, v.itemid1))
          AppendOrAccu(download_reward_dict, v.itemid1, v.itemcnt1)
        end
      end
    end
  end
  log_tree("zxq OneClickRewardSystem.GetDownloadRewardList download_reward_dict", download_reward_dict)
  return download_reward_dict
end
function OneClickRewardSystem.GetAchievementList()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement) then
    return nil
  end
  local AchievementList = {}
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local groupIdListMap = achievement_cfg_helper.CreatedMultiLvGroupIdAchiveMap()
  local currVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  if groupIdListMap then
    for _, Lists in pairs(groupIdListMap) do
      for _, idList in pairs(Lists) do
        for _, id in pairs(idList) do
          local cfg = CDataTable.GetTableData("AchievementCfg", id)
          if cfg and version_util.HigherVersion(currVersion, cfg.Version) then
            local bGeted = AchieveHandler.IsGetAchRewardByID(id)
            local bCanFinish = AchieveHandler.CheckAchiveCanFinishWithCfg(id, cfg)
            if bCanFinish == true and bGeted == false then
              table.insert(AchievementList, id)
            end
          end
        end
      end
    end
  end
  log_tree("zxq OneClickRewardSystem.AchievementList ", AchievementList)
  return AchievementList
end
function OneClickRewardSystem.ApplyGetAllReward()
  log(bWriteLog and "[zxq]OneClickRewardSystem  Hey we go one click reward")
  if OneClickRewardSystem.bIsApplying == true then
    log(bWriteLog and "[zxq] OneClickRewardSystem.bIsApplying is true")
    return
  end
  OneClickRewardSystem.ReSet()
  OneClickRewardSystem.bIsApplying = true
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant.ActivityReceiveReward = nil
  local PandoraOneclickRewardComp = require("client.slua.logic.sa.PandoraOneclickRewardComp")
  PandoraOneclickRewardComp:Request_GetGift()
  OneClickRewardSystem.SendNormalGetReward()
end
function OneClickRewardSystem.SendNormalGetReward()
  local activity_list = OneClickRewardSystem.GetActivityList()
  local mail_list = OneClickRewardSystem.GetSendMailList()
  local download_list = OneClickRewardSystem.GetDownloadList()
  local achieve_list = OneClickRewardSystem.GetAchievementList()
  if bWriteLog then
    local Linq = require("common.Linq")
    log(bWriteLog and activity_list and string.format(" OneClickRewardSystem.SendNormalGetReward activity_list:%s", Linq.FromTable(activity_list):Concat(",")))
    log(bWriteLog and mail_list and string.format(" OneClickRewardSystem.SendNormalGetReward mail_list:%s", Linq.FromTable(mail_list):Concat(",")))
    log(bWriteLog and download_list and string.format(" OneClickRewardSystem.SendNormalGetReward download_list:%s", Linq.FromTable(download_list):Concat(",")))
    log(bWriteLog and achieve_list and string.format(" OneClickRewardSystem.SendNormalGetReward achieve_list:%s", Linq.FromTable(achieve_list):Concat(",")))
  end
  if debugActivity then
    local rewardList = OneClickRewardSystem.GetActivityRewardList()
    MiniTvRewardHandler.    log_tree("OneClickRewardSystem.SendNormalGetReward() rewardList", rewardList)
  end
  MiniTvRewardHandler.send_mini_tv_get_all_reward_req(activity_list, mail_list, download_list, achieve_list)
end
function OneClickRewardSystem.AppendPandoraRewardList(rewardResult)
  log_tree("OneClickRewardSystem AppendPandoraRewardList rewardResult", rewardResult)
  local rewardList = {}
  for actid, v in pairs(rewardResult) do
    if v.result then
      for _, reward in pairs(v.result) do
        rewardList[#rewardList + 1] = reward
      end
    end
  end
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY)
end
function OneClickRewardSystem.HandleNormalReward(reason, result)
  log(bWriteLog and string.format(" OneClickRewardSystem.HandleNormalReward reason:%s result:%s", reason, result and #result))
  log_tree("zxq OneClickRewardSystem.HandleNormalReward result:", result)
  if reason == 1 then
    OneClickRewardSystem.bNormalRewardFinish = true
  end
  if result == nil or next(result) == nil then
    OneClickRewardSystem.TryToShowReward()
    return
  end
  local MapNumToSystem = OneClickMacro.MapNumToSystem
  OneClickDataHandle.HandleRPTask(result[MapNumToSystem.MODE_AWARD_TYPE_RP_TASK])
  OneClickDataHandle.HandleLevelTask(result[MapNumToSystem.MODE_AWARD_TYPE_LEVEL_TASK])
  OneClickDataHandle.HandleAchieve(result[MapNumToSystem.MODE_AWARD_TYPE_ACHIEVE])
  OneClickDataHandle.HandleAchieveRecord(result[MapNumToSystem.MODE_AWARD_TYPE_ACHIEVE_RECORD])
  OneClickDataHandle.HandleBackUser(result[MapNumToSystem.MODE_AWARD_TYPE_BACKUSER])
  OneClickDataHandle.HandleSeason(result[MapNumToSystem.MODE_AWARD_TYPE_SEASON])
  OneClickDataHandle.HandleActivity(result[MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY])
  OneClickDataHandle.HandleDownLoad(result[MapNumToSystem.MODE_AWARD_TYPE_DOWNLOAD])
  OneClickDataHandle.HandleWeekSignup(result[MapNumToSystem.MODE_AWARD_TYPE_WEEK_SIGNUP])
  OneClickDataHandle.HandlePlot(result[MapNumToSystem.MODE_AWARD_TYPE_PLOT])
  OneClickDataHandle.HandleUGCTask(result[MapNumToSystem.MODE_AWARD_TYPE_UGCTASK])
  OneClickDataHandle.HandleUGCCenterTask(result[MapNumToSystem.MODE_AWARD_TYPE_UGC_CENTER_TASK])
  OneClickDataHandle.HandleRPLevel(result[MapNumToSystem.MODE_AWARD_TYPE_RP_LEVEL_REWARD])
  OneClickDataHandle.RefreshRedPoint(result)
  if result[MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY] and next(result[MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY]) then
    local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
    LogicSmartAssistant.ActivityReceiveReward = result[MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY]
    log_tree("OneClickRewardSystem.HandleNormalReward ", LogicSmartAssistant.ActivityReceiveReward)
  end
  OneClickRewardSystem.TryToShowReward()
end
function OneClickRewardSystem.HandleCorpsActiveGoalReward(all_award_list)
  if not all_award_list or not next(all_award_list) then
    return
  end
  log_tree(" OneClickRewardSystem.HandleCorpsActiveGoalReward all_award_list", all_award_list)
  local rewardList = {}
  for k, v in pairs(all_award_list) do
    for kk, vv in pairs(v.award_list) do
      table.insert(rewardList, {
        res_id = kk,
        count = vv,
        valid_hours = 0
      })
    end
  end
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_CORPS_ACTIVE_GOAL)
end
function OneClickRewardSystem.HandleMailReward(result_reward_id_list)
  if result_reward_id_list == nil or next(result_reward_id_list) == nil then
    return
  end
  log_tree("zxq OneClickRewardSystem.HandleMailReward: result_reward_id_list", result_reward_id_list)
  local _mailReward = {}
  OneClickRewardSystem.SpecicalMail = {}
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local isPresentCoin
  for _, reward in pairs(result_reward_id_list) do
    if reward.award_list and next(reward.award_list) then
      for _, value in pairs(reward.award_list) do
        table.insert(_mailReward, value)
      end
      local mailInfo = logic_mail.GetMailInfoById(reward.id)
      if mailInfo and logic_mail.receiveCoinMailLeftCount > 0 and logic_mail_utils.IsCanPresentCoin(mailInfo) then
        local msg = {
          op = MailMacro.Enum_FriendPresentFromType.MiniTVOneClick
        }
        local FriendGiftHandler = require("client.network.Protocol.FriendGiftHandler")
        FriendGiftHandler.send_present_friend_gold_req(tonumber(mailInfo.opt.sender_uid), msg)
        isPresentCoin = true
      end
    end
    if reward.res ~= NetErrorCode_NONE then
      OneClickRewardSystem.SpecicalMail[reward.id] = true
      if not OneClickRewardSystem.SpecicalMailReason[reward.id] then
        OneClickRewardSystem.SpecicalMailReason[reward.id] = reward.res
        OneClickRewardSystem.failReason = reward.res
      end
    end
  end
  OneClickRewardSystem.AddListToAllRewardData(_mailReward, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_MAIL)
  if isPresentCoin then
    local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
    logic_mail_proto.get_friend_misc_info_req()
  end
end
function OneClickRewardSystem.HandleCorpsSpecailTrainReward(award_item_list)
  log_tree(" OneClickRewardSystem.HandleCorpsSpecailTrainReward award_item_list", award_item_list)
  if award_item_list and next(award_item_list) then
    local _mentorreward = {}
    for task_id, reward_list in pairs(award_item_list) do
      for i, v in pairs(reward_list) do
        table.insert(_mentorreward, {
          res_id = v.res_id,
          count = v.count or v.num
        })
      end
    end
    OneClickRewardSystem.AddListToAllRewardData(_mentorreward, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_CORPS_TRAIN)
  end
end
function OneClickRewardSystem.HandleCorpsWelfareReward(itemlist)
  log_tree(" OneClickRewardSystem.HandleCorpsWelfareReward itemlist", itemlist)
  if itemlist and next(itemlist) then
    local _itemRewardList = {}
    for k, v in pairs(itemlist) do
      for kk, vv in pairs(v) do
        table.insert(_itemRewardList, vv)
      end
    end
    OneClickRewardSystem.AddListToAllRewardData(_itemRewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_CORPS)
  end
end
function OneClickRewardSystem.TryToShowReward()
  log(bWriteLog and "OneClickRewardSystem.TryToShowReward NormalRewardFinish " .. tostring(OneClickRewardSystem.bNormalRewardFinish))
  if OneClickRewardSystem.bNormalRewardFinish then
    local PandoraOneclickRewardComp = require("client.slua.logic.sa.PandoraOneclickRewardComp")
    local promise = PandoraOneclickRewardComp.promsie_GetGift
    if promise == nil then
      printf("OneClickRewardSystem.TryToShowReward pandora promsie_GetGift done ")
      local result = PandoraOneclickRewardComp.rewardResult
      OneClickRewardSystem.AppendPandoraRewardList(result)
      OneClickRewardSystem.SortRewardList()
      log_tree("zxq OneClickRewardSystem postEvent REWARDFINISH", AllItemsdata)
      EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_TV_GETREWARDFINISH, AllItemsdata, OneClickRewardSystem.failReason)
      OneClickRewardSystem.ReSet()
    else
      printf("OneClickRewardSystem.TryToShowReward pandora promsie_GetGift wait ")
      promise:Then(function(rewardResult, reasonStr)
        printf("OneClickRewardSystem.TryToShowReward promise resolve")
        OneClickRewardSystem.AppendPandoraRewardList(rewardResult)
        if reasonStr == "timeout" then
          ShowNotice(100320008)
        end
        OneClickRewardSystem.SortRewardList()
        log_tree("zxq OneClickRewardSystem postEvent REWARDFINISH", AllItemsdata)
        EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_TV_GETREWARDFINISH, AllItemsdata, OneClickRewardSystem.failReason)
        OneClickRewardSystem.ReSet()
      end):Catch(function(reason)
        printf("OneClickRewardSystem.TryToShowReward promise reject reason:%s", reason)
      end)
    end
  end
end
function OneClickRewardSystem.AddListToAllRewardData(rewardList, systemId)
  printf("OneClickRewardSystem.AddListToAllRewardData systemId:%s", systemId)
  log_tree("OneClickRewardSystem.AddListToAllRewardData rewardList", rewardList)
  if rewardList == nil or next(rewardList) == nil then
    return
  end
  local cfg = CDataTable.GetTableData("SmartAssistantRewardConfig", systemId)
  if not cfg then
    printf("OneClickRewardSystem.AddListToAllRewardData can`t find systemId:%s", systemId)
    return
  end
  local systemName = cfg.NameKey
  if systemName == "" then
    printf("OneClickRewardSystem.AddListToAllRewardData systemName is empty systemId:%s", systemId)
    return
  end
  printf("OneClickRewardSystem.AddListToAllRewardData systemName:%s", systemName)
  local tb = AllItemsdata[systemName]
  if not tb then
    AllItemsdata[systemName] = rewardList
  else
    for _, v in pairs(rewardList) do
      if nil ~= v then
        table.insert(tb, v)
      end
    end
  end
end
local _SortReward = function(a, b)
  return a.quality > b.quality
end
local _SortSystem = function(a, b)
  return a.rewardList[1].quality > b.rewardList[1].quality
end
function OneClickRewardSystem.SortRewardList()
  log_tree("zxq OneClickRewardSystem.SortRewardList AllItemsdata 11", AllItemsdata)
  local _sysData = {}
  for SystemID, rewardList in pairs(AllItemsdata) do
    for key, value in pairs(rewardList) do
      value.      local resid = value.res_id or value.resid
      local item_config = CDataTable.GetTableData("Item", resid)
      if item_config then
        value.quality = item_config.ItemQuality
      else
        value.quality = -1
        log_error("zxq OneClickRewardSystem.SortRewardList can`t find it in itemTable resid:", resid)
      end
    end
    table.sort(rewardList, _SortReward)
    table.insert(_sysData, {systemId = SystemID, rewardList = rewardList})
  end
  table.sort(_sysData, _SortSystem)
  AllItemsdata = _sysData
  log_tree("zxq SortRewardList AllItemsdata", AllItemsdata)
end
function OneClickRewardSystem.isSpecialActivity(id)
  if OneClickMacro.SpecialActivityIdList[id] then
    return true
  end
  return false
end
function OneClickRewardSystem.IsSafeMail(id)
  local mail_info = logic_mail.GetMailInfoById(id)
  if mail_info then
    return mail_info.opt.type == MailMacro.Enum_Mail_Type.Security
  end
  return false
end
function OneClickRewardSystem.IsSpecialMail(id)
  return OneClickRewardSystem.SpecicalMail[id]
end
return OneClickRewardSystem
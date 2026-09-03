local NewbieActivitySystem = {activity_data = nil}
local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
local ModName_NewbieActivity = LobbyModUtils.Enum_Mod_Name.EName_NewbieActivity
function NewbieActivitySystem.IsModReady()
  return LobbyModUtils.IsModDownloaded(ModName_NewbieActivity)
end
function NewbieActivitySystem.ShowUIWithModCheck(uiConfig, ...)
  local args = table.pack(...)
  if LobbyModUtils.IsModDownloaded(ModName_NewbieActivity) then
    UIManager.ShowUI(uiConfig, table.unpack(args, 1, args.n))
  else
    LobbyModUtils.DownloadMod(ModName_NewbieActivity, function()
      UIManager.ShowUI(uiConfig, table.unpack(args, 1, args.n))
    end)
  end
end
function NewbieActivitySystem.PreDownloadMod(callback)
  if not LobbyModUtils.IsModDownloaded(ModName_NewbieActivity) then
    LobbyModUtils.DownloadMod(ModName_NewbieActivity, callback)
  elseif callback then
    callback()
  end
end
function NewbieActivitySystem.CreateDownloadPanel(downloadPanel)
  local ResList = LobbyModUtils.GetModResList(ModName_NewbieActivity)
  if not ResList or next(ResList) == nil then
    log_warning(bWriteLog and "NewbieActivitySystem.CreateDownloadPanel - ResList is empty")
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, ResList)
  if state == PufferConst.ENUM_DownloadState.Done then
    log_warning(bWriteLog and "NewbieActivitySystem.CreateDownloadPanel - state is Done")
    return
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, ResList, downloadPanel)
end
function NewbieActivitySystem.Init()
end
function NewbieActivitySystem.OnBackLogin()
  NewbieActivitySystem.activity_data = nil
end
function NewbieActivitySystem.on_newbie_activity_init(activity_data)
  local TimeUtil = require("client.common.time_util")
  log_tree("newbie_activity_data_init", {
    activity_data,
    TimeUtil.GetServerTimeInSec()
  })
  local newFriendsGathering = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.module_newbie_friends_gathering)
  newFriendsGathering:OnActivityDataInit(activity_data.newbie_social_task)
  NewbieActivitySystem.  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function NewbieActivitySystem.on_newbie_activity_get_sign_reward_rsp(day, reward_index)
  log(bWriteLog and "on_newbie_activity_get_sign_reward_rsp:" .. tostring(day) .. ",reward_index:" .. tostring(reward_index))
  local award = NewbieActivitySystem.activity_data.newbie_sign.cfg[day][reward_index]
  log_tree("award", award)
  local arrayItemData = {}
  table.insert(arrayItemData, {
    res_id = award.itemid,
    count = award.cnt,
    valid_hours = award.valid_hours
  })
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData = {
    fCloseCallback = function()
      local EightDaySystem = require("client.slua.logic.activity.newbie.logic_newbie_eight_day")
      if EightDaySystem.IsClickButtonEightDay == true and UIManager.IsUIShow(UIManager.UI_Config.Flap_Newbie_EightDays) then
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.EightDaysAwardOK, 0)
        EightDaySystem.IsClickButtonEightDay = false
      end
    end
  }
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData, true, true, tExtendData)
end
function NewbieActivitySystem.on_newbie_activity_get_rank_reward_rsp(task_id)
  log(bWriteLog and "on_newbie_activity_get_rank_reward_rsp:" .. tostring(task_id))
  local award = NewbieActivitySystem.activity_data.newbie_rank_reward.cfg[task_id]
  local arrayItemData = {}
  table.insert(arrayItemData, {
    res_id = award.itemid,
    count = award.cnt,
    valid_hours = award.valid_hours
  })
  if award.itemid2 and award.itemid2 ~= 0 then
    table.insert(arrayItemData, {
      res_id = award.itemid2,
      count = award.cnt2,
      valid_hours = award.valid_hours2
    })
  end
  if award.itemid3 and award.itemid3 ~= 0 then
    table.insert(arrayItemData, {
      res_id = award.itemid3,
      count = award.cnt3,
      valid_hours = award.valid_hours3
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
end
function NewbieActivitySystem.on_newbie_activity_get_gift_reward_rsp(task_id)
  log(bWriteLog and "on_newbie_activity_get_gift_reward_rsp:" .. tostring(task_id))
  local award = NewbieActivitySystem.activity_data.newbie_gift.cfg[task_id]
  local arrayItemData = {}
  table.insert(arrayItemData, {
    res_id = award.itemid,
    count = award.cnt,
    valid_hours = award.valid_hours
  })
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
end
function NewbieActivitySystem.on_newbie_activity_sync_status(activity_data)
  log_tree("on_newbie_activity_sync_status", activity_data)
  if NewbieActivitySystem.activity_data then
    if activity_data.sign_status then
      NewbieActivitySystem.activity_data.newbie_sign.status = activity_data.sign_status
    end
    if activity_data.rank_status then
      NewbieActivitySystem.activity_data.newbie_rank_reward.status = activity_data.rank_status
    end
    if activity_data.gift_status then
      NewbieActivitySystem.activity_data.newbie_gift.status = activity_data.gift_status
    end
    if activity_data.level_unlock_status then
      local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
      level_unlock_award_manager:on_newbie_activity_sync_status(activity_data.level_unlock_status)
    end
  end
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function NewbieActivitySystem.HasRedDot_NewbieAward()
  if not NewbieActivitySystem.HasNewbieActivity() then
    return false
  end
  for _, v in ipairs(NewbieActivitySystem.activity_data.newbie_rank_reward.status) do
    if v == 1 then
      return true
    end
  end
  return false
end
function NewbieActivitySystem.HasRedDot_NewbieGift()
  if not NewbieActivitySystem.HasNewbieActivity() then
    return false
  end
  return false
end
function NewbieActivitySystem.HasNewbieActivity()
  if not NewbieActivitySystem.activity_data or NewbieActivitySystem.activity_data.day <= 0 then
    log_warning(bWriteLog and "NewbieActivitySystem.HasNewbieActivity day <= 0")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime < NewbieActivitySystem.activity_data.open_time then
    log_warning_format("NewbieActivitySystem.HasNewbieActivity not start. nowTime: %s, open_time: %s", nowTime, NewbieActivitySystem.activity_data.open_time)
    return false
  end
  if nowTime > NewbieActivitySystem.activity_data.end_time then
    log_warning_format("NewbieActivitySystem.HasNewbieActivity is end. nowTime: %s, end_time: %s", nowTime, NewbieActivitySystem.activity_data.end_time)
    return false
  end
  return true
end
function NewbieActivitySystem.HasNewbieBanner()
  if not NewbieActivitySystem.activity_data or NewbieActivitySystem.activity_data.day <= 0 then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() < NewbieActivitySystem.activity_data.open_time then
    return false
  end
  local endTime = NewbieActivitySystem.GetNewbieBannerEndTime()
  if endTime < TimeUtil.GetServerTimeInSec() then
    return false
  end
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  if not level_unlock_award_manager:CheckHasActiveBanner(DataMgr.roleData.level) then
    log_warning(bWriteLog and "NewbieActivitySystem.HasNewbieBanner return not all Award is Got")
    return false
  end
  return true
end
function NewbieActivitySystem.GetNewbieBannerEndTime()
  local duration = 604799
  return NewbieActivitySystem.activity_data.open_time + duration
end
function NewbieActivitySystem.GetActivitySubData_Newbie_Award()
  if not NewbieActivitySystem.HasNewbieActivity() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Award,
    sName = LocUtil.GetLocalizeResStr(12206),
    bRedDot = NewbieActivitySystem.HasRedDot_NewbieAward,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function NewbieActivitySystem.GetActivitySubData_Newbie_Gift()
  if not LobbySystem.CheckOpen(BP_ENUM_NEWBIE_GIFT_SWITCH) then
    return
  end
  if not NewbieActivitySystem.HasNewbieActivity() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Gift,
    sName = LocUtil.GetLocalizeResStr(12207),
    bRedDot = NewbieActivitySystem.HasRedDot_NewbieGift,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function NewbieActivitySystem.ReceiveOne(index, instanceKey)
  if instanceKey == ActivityFixedID.Newbie_Award then
    local NewbieActivityHandle = require("client.network.Protocol.NewbieActivityHandle")
    NewbieActivityHandle.send_newbie_activity_get_rank_reward_req(index)
  elseif instanceKey == ActivityFixedID.Newbie_Gift then
    local NewbieActivityHandle = require("client.network.Protocol.NewbieActivityHandle")
    NewbieActivityHandle.send_newbie_activity_get_gift_reward_req(index)
  end
end
function NewbieActivitySystem.ReceiveFromRedHot(instanceKey)
  if not instanceKey or instanceKey == "" then
    return
  end
  if instanceKey == ActivityFixedID.Newbie_Award or instanceKey == ActivityFixedID.Newbie_Gift then
    local time_ticker = require("common.time_ticker")
    local taskList = {}
    local statusList = {}
    if instanceKey == ActivityFixedID.Newbie_Award then
      taskList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_rank_reward and NewbieActivitySystem.activity_data.newbie_rank_reward.cfg or {}
      statusList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_rank_reward and NewbieActivitySystem.activity_data.newbie_rank_reward.status or {}
    elseif instanceKey == ActivityFixedID.Newbie_Gift then
      taskList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_gift and NewbieActivitySystem.activity_data.newbie_gift.cfg or {}
      statusList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_gift and NewbieActivitySystem.activity_data.newbie_gift.status or {}
    end
    for index, v in ipairs(taskList) do
      if statusList[index] and statusList[index] == 1 then
        time_ticker.AddTimerOnce(0.2, function()
          NewbieActivitySystem.ReceiveOne(index, instanceKey)
        end)
      end
    end
  end
end
function NewbieActivitySystem.GetCanReceiveAwards(instanceKey)
  if not instanceKey or instanceKey == "" then
    return nil
  end
  local awardList = {}
  local taskList = {}
  local statusList = {}
  if instanceKey == ActivityFixedID.Newbie_Award then
    taskList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_rank_reward and NewbieActivitySystem.activity_data.newbie_rank_reward.cfg or {}
    statusList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_rank_reward and NewbieActivitySystem.activity_data.newbie_rank_reward.status or {}
  elseif instanceKey == ActivityFixedID.Newbie_Gift then
    taskList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_gift and NewbieActivitySystem.activity_data.newbie_gift.cfg or {}
    statusList = NewbieActivitySystem.activity_data and NewbieActivitySystem.activity_data.newbie_gift and NewbieActivitySystem.activity_data.newbie_gift.status or {}
  end
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  for index, v in ipairs(taskList) do
    if statusList[index] and statusList[index] == 1 then
      table.insert(awardList, reddotUtil.CreateItem(v.itemid, v.cnt))
    end
  end
  return awardList
end
function NewbieActivitySystem.IsRankAwardOpen()
  return true
end
return NewbieActivitySystem
local TaskMgrSystem = {}
local PanelType = {
  None = 0,
  LevelTask = 1,
  WeekTask = 2,
  AchievementTask = 3,
  RPTask = 4,
  Assembly = 5,
  ManorDrawReward = 6,
  ManorTask = 7,
  UGCTask = 8,
  UGCWOWPassTask = 9
}
function TaskMgrSystem.GetAllAwardsOfTask()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_general_task_batch_reward_req()
end
function TaskMgrSystem.on_general_task_batch_reward_rsp(rewards, isUGC)
  TaskMgrSystem.show_all_awards_of_task(rewards, isUGC)
end
function TaskMgrSystem.show_all_awards_of_task(all_awards, isUGC)
  log_tree("TaskMgrSystem.take_all_awards_of_task_rsp", all_awards)
  local award_table = {}
  local AddAward = function(new)
    new.valid_hours = new.valid_hours or 0
    new.expire_ts = new.expire_ts or 0
    new.isTreasureBox = new.isTreasureBox or false
    for i, v in ipairs(award_table) do
      if v.res_id == new.res_id and v.valid_hours == new.valid_hours and v.expire_ts == new.expire_ts and v.isTreasureBox == new.isTreasureBox then
        v.count = v.count + new.count
        return
      end
    end
    if new.isTreasureBox then
      table.insert(award_table, 1, new)
    else
      table.insert(award_table, new)
    end
  end
  if all_awards.daily_task then
    for index, itemlist in pairs(all_awards.daily_task) do
      for i, v in pairs(itemlist) do
        AddAward(v)
      end
    end
  end
  if all_awards.weekly_task then
    local WeekTaskSystem = require("client.slua.logic.task.logic_week_task")
    for taskId, onetask in pairs(all_awards.weekly_task) do
      for stageIndex, itemList in pairs(onetask) do
        for i, v in pairs(itemList) do
          AddAward(v)
        end
        local taskData = WeekTaskSystem.week_list[taskId]
        if not taskData then
          taskData = {}
          WeekTaskSystem.week_list[taskId] = taskData
        end
        if not taskData.status then
          taskData.status = {}
        end
        taskData.status[stageIndex] = 2
      end
    end
    WeekTaskSystem.RefreshWeekTaskInfo()
    local assembly_reddot_data = require("client.slua.logic.task.assembly_reddot_data")
    assembly_reddot_data.UpdateJKWeekTaskRedDot()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_WEEK_TASK_CHANGE)
  end
  if all_awards.level_task then
    local LevelTaskSystem = require("client.slua.logic.task.logic_level_task")
    for _, onetask in pairs(all_awards.level_task) do
      for _, v in pairs(onetask[3]) do
        AddAward(v)
      end
      local taskInfo = DataMgr.levelTask.list[onetask[1]]
      if taskInfo then
        taskInfo[LevelTaskSystem.LevelTaskId[onetask[2]]] = 2
      end
    end
  end
  local achievementScore = 0
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local ScoreCfg = achievement_cfg_helper.Load_AchievementScoreCfg()
  local AchieveRed = require("client.logic.achievement.achievement_red")
  if all_awards.achieve then
    for index, onetask in pairs(all_awards.achieve) do
      for i, v in pairs(onetask.itemlist) do
        AddAward(v)
      end
      local CfgData = CDataTable.GetTableData("AchievementCfg", onetask.id)
      if onetask.id and CfgData and CfgData.Score then
        achievementScore = achievementScore + CfgData.Score
      end
      if onetask.id and CfgData then
        local data = CfgData
        AchieveRed.ClearRed(data.GroupID, AchieveRed.Receive, onetask.id)
      end
    end
  end
  if all_awards.achieve_record then
    for index, onetask in pairs(all_awards.achieve_record) do
      for i, v in pairs(onetask.itemlist) do
        AddAward(v)
      end
      AchieveRed.ClearRed(AchieveRed.SCORE, AchieveRed.Receive, onetask.record_id)
    end
  end
  if all_awards.activeness_daily then
    for index, onetask in pairs(all_awards.activeness_daily) do
      for i, v in pairs(onetask.itemlist) do
        AddAward(v)
      end
    end
  end
  if all_awards.activeness_weekly then
    for index, onetask in pairs(all_awards.activeness_weekly) do
      for i, v in pairs(onetask.itemlist) do
        AddAward(v)
      end
    end
  end
  if all_awards.daily_login_ext_itemlist ~= nil then
    for k, v in pairs(all_awards.daily_login_ext_itemlist) do
      AddAward({
        res_id = v.res_id,
        count = v.count,
        valid_hours = v.valid_hours,
        expire_ts = v.expire_ts,
        isTreasureBox = true
      })
    end
  elseif all_awards.daily_login_ext_res_map then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    local callback = function(drop_id, dropList)
      if NewDayTaskSystem.drop_id == drop_id then
        for _, reward in pairs(dropList) do
          if all_awards.daily_login_ext_res_map[reward.DropItemID] and all_awards.daily_login_ext_res_map[reward.DropItemID] then
            AddAward({
              res_id = reward.DropItemID,
              count = reward.DropItemNum,
              valid_hours = reward.DropItemTime,
              isTreasureBox = true
            })
          end
        end
      end
    end
    local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
    BasicDataDropTable:GetOrReqData(NewDayTaskSystem.drop_id, callback)
  end
  if all_awards.reward_id_list and 1 <= #all_awards.reward_id_list then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    for _, reward_id in ipairs(all_awards.reward_id_list) do
      local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
      for _, reward in ipairs(rewards) do
        AddAward({
          res_id = reward.res_id,
          count = reward.res_num,
          valid_hours = reward.res_time_limit
        })
      end
    end
    NewDayTaskSystem.send_general_task_sync_all_req()
  end
  if isUGC and all_awards and 0 < #all_awards then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    for _, reward_id in ipairs(all_awards) do
      local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
      for _, reward in ipairs(rewards) do
        AddAward({
          res_id = reward.res_id,
          count = reward.res_num,
          valid_hours = reward.res_time_limit
        })
      end
    end
    NewDayTaskSystem.send_general_task_sync_all_req()
  end
  log_tree("award_table", award_table)
  if award_table and next(award_table) ~= nil then
    local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
    logic_achievement.OnLogin()
    local LevelTaskRedPointData = require("client.slua.logic.task.level_task_reddot_data")
    LevelTaskRedPointData.UpdateRedDot()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE)
    local time_ticker = require("common.time_ticker")
    local timerID
    timerID = time_ticker.AddTimerLoop(0, function()
      if UIManager.GetUI(UIManager.UI_Config.levelup_panel) then
      else
        local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
        Logic_CommonItemGet.ShowPanel_AchievementStyle(award_table, achievementScore)
        time_ticker.RemoveTimer(timerID)
      end
    end, TIMER_INFINITE, 1)
  else
    ShowNotice(108002)
  end
end
function TaskMgrSystem.take_all_awards_of_task_rsp(all_awards)
  TaskMgrSystem.show_all_awards_of_task(all_awards)
end
function TaskMgrSystem.GetTaskRedDot()
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  if NewDayTaskSystem.HasRedpoint() then
    return true
  end
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  local hasRPReddot = UnknowPassMissionSystem.RefreshWeekTabRedDot()
  if hasRPReddot then
    return true
  end
  local WeekTaskSystem = require("client.slua.logic.task.logic_week_task")
  if WeekTaskSystem.GetWeekTaskRedDot() then
    return true
  end
  return false
end
function TaskMgrSystem.RefreshLobbyTaskRedDot()
  if GameStatus.IsInLobbyOrMainCity() then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if not LogicNewbie.IsNewbie() or LogicNewbie.NeedShowNewbieGuide(BP_ENUM_LOBBY_MENU_TASK) then
      LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_TASK, TaskMgrSystem.GetTaskRedDot())
    end
  end
end
function TaskMgrSystem.TryShowAdvertise()
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  if AdvertiseSdk:IsAdvertiseLoaded() then
    log(bWriteLog and "EventGlobalUseItem play advertise success")
    GlobalData.PlayAdvertise()
  else
    log(bWriteLog and "EventGlobalUseItem play advertise failed")
    GlobalData.TryLoadAdvertise()
    ShowNotice(6506)
  end
end
function TaskMgrSystem.JumpTo(eventType, eventID, vars)
  if vars and vars.idx then
    local type = tonumber(vars.idx)
    if type == PanelType.DailyTask then
      local logic_assembly_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_system)
      logic_assembly_system:ShowMainUI()
    elseif type == PanelType.Assembly then
      local assembly_macro = require("client.slua.logic.come_back.assembly_macro")
      local logic_assembly_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_system)
      logic_assembly_system:ShowMainUI(assembly_macro.ENUM_TAB_TYPE.Friend)
    elseif type == PanelType.AchievementTask then
      local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
      local showIndex = RoleInfoMainSystem.Honor
      local openFrom = RoleInfoMainSystem.RoleInfoOpenFromType.Lobby
      local uid = DataMgr.roleData.uid
      RoleInfoMainSystem.Show(showIndex, openFrom, uid)
    elseif type == PanelType.RPTask then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_AWARD_TRIGGER)
      local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
      UnknowPassTunnelSystem.ShowRP({Tab1 = 4})
    elseif type == PanelType.ManorTask then
      local home_macros = require("client.slua.logic.home.home_macros")
      local tabType = home_macros.ENUM_LOBBY_HOME_MAIN_TAB_TYPE.Task
      local logic_lobby_home_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_home_main)
      logic_lobby_home_main:ShowMainUI(tabType)
    elseif type == PanelType.UGCWOWPassTask then
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      local SelectEnum = Config_UGC.Enum_WOWPass_Select
      local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
      if logic_ugc_WOWPass:IsSeasonActive() then
        logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_MainUI, {
          TabID = SelectEnum.Task
        })
      end
    end
  end
end
function TaskMgrSystem.FailOverAchievementJump(index)
  if index == PanelType.AchievementTask then
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local showIndex = RoleInfoMainSystem.Honor
    local openFrom = RoleInfoMainSystem.RoleInfoOpenFromType.Lobby
    local uid = DataMgr.roleData.uid
    RoleInfoMainSystem.Show(showIndex, openFrom, uid)
    return true
  else
    return false
  end
end
return TaskMgrSystem
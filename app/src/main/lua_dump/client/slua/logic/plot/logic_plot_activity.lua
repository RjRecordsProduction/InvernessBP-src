local logic_plot_activity = {
  ActivityStartTime = 0,
  ActivityEndTime = 0,
  AllPlotInfo = {},
  ENUM_AWARD_STATE = {
    NOT_ACHIEVE = 0,
    CAN_RECEIVE = 1,
    HAS_RECEIVED = 2
  }
}
local SetActivityData = function(plotData, plotCfg)
  logic_plot_activity.AllPlotInfo = {}
  if not (plotData and plotCfg) or not plotData.chapter then
    return
  end
  for chapIndex, data in pairs(plotData.chapter) do
    local cfg = plotCfg[chapIndex]
    if cfg then
      local info = {
        nIndex = chapIndex,
        nProcess = data.process or 0,
        bIsUnlock = data.isunlock or false,
        nAwardState = data.task_status or 0,
        sImgUrl = cfg.pic or "",
        sTitle = cfg.title or "",
        sJumpUrl = cfg.jump or "",
        sDepend = cfg.depend or "",
        nEndTime = cfg.end_time_ts or 0,
        sPlotRule = cfg.plot_rules or "",
        nStartTime = cfg.begin_time_ts or 0,
        sPlotDescribe = cfg.description or "",
        nTaskCond = cfg.task and cfg.task.cond or 0,
        awardList = cfg.task and cfg.task.award or {},
        sTaskDescribe = cfg.task and cfg.task.task_dec or ""
      }
      table.insert(logic_plot_activity.AllPlotInfo, info)
    end
  end
end
local SetActivityTime = function(act_cfg)
  if not act_cfg then
    return
  end
  logic_plot_activity.ActivityStartTime = tonumber(act_cfg.begin_time_ts or 0)
  logic_plot_activity.ActivityEndTime = tonumber(act_cfg.end_time_ts or 0)
end
local CheckIsNeverOpen = function()
  log(bWriteLog and "[chub] logic_plot_activity.CheckIsNeverOpen()")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.plotHasOpen) or {}
  log(bWriteLog and tostring(cfg.hasOpen == nil))
  return cfg.hasOpen == nil
end
local SaveOpenRecord = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({hasOpen = true}, PlayerPrefsSystem.ePlayerPrefsType.plotHasOpen)
end
function logic_plot_activity.get_plot_info()
  log(bWriteLog and "[chub] logic_plot_activity.send_get_plot_info()")
  local PlotHandler = require("client.network.Protocol.PlotHandler")
  PlotHandler.send_get_plot_info()
end
function logic_plot_activity.on_get_plot_info_rsp(error_code, plot_cfg, plot_data, act_cfg)
  log_tree("[chub]OnGetPlotInfoRsp : error_code = ", error_code)
  log_tree("[chub]OnGetPlotInfoRsp : act_cfg = ", act_cfg)
  log_tree("[chub]OnGetPlotInfoRsp : plot_cfg = ", plot_cfg)
  log_tree("[chub]OnGetPlotInfoRsp : plot_data = ", plot_data)
  if error_code == 1 then
    SetActivityData(plot_data, plot_cfg)
    SetActivityTime(act_cfg)
    local Logic_Gradually_activity = require("client.slua.logic.activity.commom_activity_center.logic_activity_gradually")
    Logic_Gradually_activity.actCfg = plot_cfg
    Logic_Gradually_activity.actData = plot_data
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_PLOT, EVENTID_PLOT_DATA_CHANGE)
  end
end
function logic_plot_activity.on_notify_plot_info(plot_data)
  log_tree("[chub]on_notify_plot_info : plot_data = ", plot_data)
  local Logic_Gradually_activity = require("client.slua.logic.activity.commom_activity_center.logic_activity_gradually")
  Logic_Gradually_activity.actData = plot_data
  if not (plot_data and plot_data.chapter) or not logic_plot_activity.AllPlotInfo then
    return log_error("plot_data or plot_data.chapter is nil ")
  end
  for chapIndex, data in pairs(plot_data.chapter) do
    local plotInfo = logic_plot_activity.AllPlotInfo[chapIndex]
    if plotInfo then
      plotInfo.bIsUnlock = data.isunlock
      plotInfo.nAwardState = data.task_status
    end
  end
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_PLOT, EVENTID_PLOT_UNLOCK_OR_TASK_CHANGE)
  end
  logic_plot_activity.RefreshBannerRedDot()
end
function logic_plot_activity.take_chapter_award(plotId, task_id)
  log(bWriteLog and "[chub] logic_plot_activity.send_take_chapter_award() plotId = " .. plotId)
  local PlotHandler = require("client.network.Protocol.PlotHandler")
  PlotHandler.send_take_chapter_award(plotId, task_id)
end
function logic_plot_activity.on_take_chapter_award_rsp(error_code, index, award, invoke_type)
  log_tree("[chub]on_take_chapter_award_rsp : error_code = ", error_code)
  log_tree("[chub]on_take_chapter_award_rsp : award = ", award)
  if error_code == 1 then
    if not invoke_type or invoke_type ~= 1 then
      local Result = {}
      for _, itemData in pairs(award) do
        table.insert(Result, {
          res_id = itemData.item_id,
          count = itemData.item_num,
          valid_hours = itemData.item_expire_time
        })
      end
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
    end
    logic_plot_activity.RefreshBannerRedDot()
    if GameStatus.IsInLobbyOrMainCity() then
      EventSystem:postEvent(EVENTTYPE_ACTIVITY_PLOT, EVENTID_PLOT_AWARD_STATUS_CHANGE, index)
    end
  end
end
function logic_plot_activity.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    local time_ticker = require("common.time_ticker")
    if logic_plot_activity.timeTicker then
      time_ticker.RemoveTimer(logic_plot_activity.timeTicker)
      logic_plot_activity.timeTicker = nil
    end
    logic_plot_activity.timeTicker = time_ticker.AddTimerOnce(3, function()
      logic_plot_activity.RefreshBannerRedDot()
    end)
  end
end
function logic_plot_activity.OpenPlotActivity()
  if not logic_plot_activity.IsInActivityTime() then
    ShowNotice(4002)
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.plot_activity_main) then
    UIManager.ShowUI(UIManager.UI_Config.plot_activity_main)
    if CheckIsNeverOpen() then
      SaveOpenRecord()
      logic_plot_activity.RefreshBannerRedDot()
    end
  end
end
function logic_plot_activity.RefreshBannerRedDot()
  local bIsNew = CheckIsNeverOpen()
  local awardList = logic_plot_activity.GetCanReceiveAwards() or {}
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_PLOT_ACTIVITY, bIsNew or next(awardList))
end
function logic_plot_activity.GetCanReceiveAwards()
  local awardList = {}
  local plotInfoList = logic_plot_activity.AllPlotInfo
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  if plotInfoList and next(plotInfoList) then
    for _, info in pairs(plotInfoList) do
      if info.nAwardState == logic_plot_activity.ENUM_AWARD_STATE.CAN_RECEIVE then
        for _, v in pairs(info.awardList) do
          table.insert(awardList, reddotUtil.CreateItem(v.item_id, v.item_num, v.item_expire_time))
        end
      end
    end
  end
  return awardList
end
function logic_plot_activity.IsInActivityTime()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  return ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_PLOT_ACTIVITY)
end
function logic_plot_activity.GetMaxPlotUnlocked()
  local maxPlotUnlocked = 1
  for _, info in ipairs(logic_plot_activity.AllPlotInfo) do
    if info.bIsUnlock == true then
      maxPlotUnlocked = math.max(maxPlotUnlocked, info.nIndex)
    end
  end
  return maxPlotUnlocked
end
return logic_plot_activity
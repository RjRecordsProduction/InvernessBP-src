local logic_act_module = {}
local NRefreshRedNum = 10
local _exchangeTLog = function(act, itemId, num)
  local reason_str = string.format("id:%s_num:%s", itemId, num)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ExchangeExecution, act, reason_str)
end
function logic_act_module:InsertCommonEvent(cfg, data)
  if not self:IsCommonEventExists(cfg.updateEventType, cfg.updateEventID) then
    self:AddCommonEvent(cfg.updateEventType, cfg.updateEventID, self.OnUpdateTabExtra, self, data.nActID, cfg)
    log(bWriteLog and "logic_act_module:InsertCommonEvent. insert commont event! type" .. tostring(cfg.updateEventType) .. "id" .. tostring(cfg.updateEventID))
  end
end
function logic_act_module:RegistEvents()
  logic_act_module.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActChange, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PANDORA_EXCHANGE, self.JumpExchangeStore, self)
  local activityConfig = require("client.slua.logic.activity.activity_config")
  activityConfig.StartCache()
  local _InitExtraData = function(cfg, data)
    if cfg.updateEventType and cfg.updateEventID then
      self:InsertCommonEvent(cfg, data)
    end
  end
  for i, cfg in ipairs(activityConfig) do
    local actData = activityConfig.DoAction(i, cfg)
    if actData then
      if 0 < #actData then
        for _, subData in ipairs(actData) do
          _InitExtraData(cfg, subData)
        end
      else
        _InitExtraData(cfg, actData)
      end
    end
  end
end
function logic_act_module:OnPostSwitchGameStatus(preState, nextState)
  log_warning(bWriteLog and string.format("logic_act_module:OnPostSwitchGameStatus. pre=%s, nextState=%s", tostring(preState), tostring(nextState)))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    self:UpdateActivityCenterRedPoint(reddot_macro.SystemName.ActivityCenterWOW, ActivityDisplayScene.WOW)
    self:UpdateActivityCenterRedPoint(reddot_macro.SystemName.ActivityCenterSport, ActivityDisplayScene.Sport)
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      self:UpdateActivityCenterRedPoint(reddot_macro.SystemName.ActivityCenterTxMission, ActivityDisplayScene.TxMission)
    end
    self:UpdateActivityCenterRedPoint(reddot_macro.SystemName.ActivityCenter, ActivityDisplayScene.Default)
  end
end
function logic_act_module:OnUpdateTabExtra(nActId, cfg)
  log_warning(bWriteLog and string.format("logic_act_module:OnUpdateTabExtra. nActId=%s, cfg=%s", tostring(nActId), tostring(cfg)))
  local Activity_UIBP = UIManager.GetUI(UIManager.UI_Config.new_activity_center)
  if Activity_UIBP then
    Activity_UIBP:OnUpdateTabExtra(nActId, cfg)
  end
  if nActId then
    local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
    if Activity_UIBP then
      local uiScene = Activity_UIBP:GetDisplayScene()
      if uiScene then
        Logic_Activity_Center.InitCenterData(uiScene)
        Logic_Activity_Center.SortCenterData()
      end
    end
    if not Logic_Activity_Center.RefreshActRedById(nActId) then
      log_warning(bWriteLog and string.format("logic_act_module:OnUpdateTabExtra. nActId=%s, can't find", tostring(nActId)))
      local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
      ActivityRedDot.UpdateAllRedDotAdaptively()
    end
  end
end
function logic_act_module:OnActChange(_, _, changes)
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TableUtil = require("common.table_util")
  local RefreshOneRed = function(id)
    local originalId = id
    local act = ActivityNewSystem.GetActivityByID(id)
    if Logic_Activity_Center.IsHideInActivityCenter(act) then
      act = ActivityNewSystem.GetServerDataByID(id)
      id = TableUtil.GetTableValue(act, "data", "father_activity_id")
      if not id then
        Logic_Activity_Center.RefreshActRedById(originalId)
        return false
      end
      act = ActivityNewSystem.GetActivityByID(id)
      if not act or Logic_Activity_Center.IsHideInActivityCenter(act) then
        Logic_Activity_Center.RefreshActRedById(originalId)
        return false
      else
        Logic_Activity_Center.RefreshActRedById(id)
      end
    end
    if not Logic_Activity_Center.RefreshActRedById(id) then
      local activityDataTable = ActivityNewSystem.GetActivityByID(id)
      log_tree("  logic_act_module:OnActChange. activityDataTable ", activityDataTable)
      ActivityRedDot.UpdateAllRedDotAdaptively()
      return true
    end
  end
  local idTb = changes and changes.idList
  if idTb and TableUtil.CountTable(idTb) < NRefreshRedNum then
    for id, _ in pairs(idTb) do
      if id == -1 then
        log_warning(bWriteLog and "    logic_act_module:OnActChange id error -1.  ")
        ActivityRedDot.UpdateAllRedDotAdaptively()
        break
      end
      if RefreshOneRed(id) then
        break
      end
    end
    self:RefreshNeedActs()
  else
    log_warning(bWriteLog and "    logic_act_module:OnActChange So many acts.  ")
    ActivityRedDot.UpdateAllRedDotAdaptively()
  end
  local Activity_UIBP = UIManager.GetUI(UIManager.UI_Config.new_activity_center)
  if Activity_UIBP then
    local uiScene = Activity_UIBP:GetDisplayScene()
    if uiScene then
      Logic_Activity_Center.InitCenterData(uiScene)
      Logic_Activity_Center.SortCenterData()
    end
    Activity_UIBP:OnUpdateUI(changes)
  end
end
function logic_act_module:RefreshNeedActs()
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  local act_red_cfg = require("client.slua.logic.activity.RedPoint.act_red_cfg")
  for _, v in ipairs(act_red_cfg.NeedRefreshActs) do
    local module = require(v.moduleName)
    local data = module[v.funcName]()
    if data then
      Logic_Activity_Center.RefreshActRedById(data.nActID)
    end
  end
end
function logic_act_module:JumpExchangeStore(_, _, vars)
  log_tree("ActModule:JumpExchangeStore vars", vars)
  local HostedCommonProtocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedCommonProtocol)
  HostedCommonProtocol:ShowExchange({
    exchangeId = vars.id
  })
end
function logic_act_module:SendExchange(act, itemId, num, posId)
  log(bWriteLog and "  : SendExchange act:" .. tostring(act))
  log(bWriteLog and "  : SendExchange itemId:" .. tostring(itemId))
  log(bWriteLog and "  : SendExchange num:" .. tostring(num))
  log(bWriteLog and "  : SendExchange posId:" .. tostring(posId))
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_exchange_by_activity_id_req(act, itemId, num, {pos_id = posId})
  _exchangeTLog(act, itemId, num)
end
function logic_act_module:SendExchangeWithSource(act, itemId, num, exchangeData)
  log(bWriteLog and "  : sendWith source")
  log(bWriteLog and "  : SendExchange act:" .. tostring(act))
  log(bWriteLog and "  : SendExchange itemId:" .. tostring(itemId))
  log(bWriteLog and "  : SendExchange num:" .. tostring(num))
  log_tree("exchangeData", exchangeData)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_do_exchange_by_activity_id_req(act, itemId, num, {
    pos_id = exchangeData.pos,
    source = exchangeData.source
  })
  _exchangeTLog(act, itemId, num)
end
local _UpdateActivityCenterRedPoint = function(systemName, displayScene)
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  ActivityRedDot.SetForceUpdateAllDone(systemName, false)
  Logic_Activity_Center.InitCenterData(displayScene)
  Logic_Activity_Center.SortCenterData()
  ActivityRedDot.BuildAllRedDotOnce(displayScene)
end
function logic_act_module:UpdateActivityCenterRedPoint(systemName, displayScene)
  local utility = require("common.utility")
  xpcall(_UpdateActivityCenterRedPoint, utility.ErrorMessageHandler, systemName, displayScene)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_act_module = class(CModuleBase, nil, logic_act_module)
return Clogic_act_module
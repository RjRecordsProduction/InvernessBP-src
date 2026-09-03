local logic_history_combat = {}
function logic_history_combat:DefineAndResetData()
  self.allGame = {}
  self.new_effect_table = {}
  self.hvh_pop_data = {}
end
function logic_history_combat:OnInitialize()
end
function logic_history_combat:RegistEvents()
end
function logic_history_combat:OnLogin(bReLogin)
end
function logic_history_combat:OnLogOut()
end
function logic_history_combat:OnPreSwitchGameStatus(preState, nextState)
end
function logic_history_combat:OnPostSwitchGameStatus(preState, nextState)
end
function logic_history_combat:GetModeList()
  log(bWriteLog and "logic_history_combat:GetModeList")
  local modeList
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch() then
    modeList = {
      {
        type = history_combat_cfg.EBattleType.All,
        text = LocUtil.GetLocalizeResStr(642)
      },
      {
        type = history_combat_cfg.EBattleType.Rank,
        text = LocUtil.GetLocalizeResStr(602)
      },
      {
        type = history_combat_cfg.EBattleType.PeakGame,
        text = LocUtil.GetLocalizeResStr(46063)
      },
      {
        type = history_combat_cfg.EBattleType.Match,
        text = LocUtil.GetLocalizeResStr(603)
      },
      {
        type = history_combat_cfg.EBattleType.Team,
        text = LocUtil.GetLocalizeResStr(643)
      },
      {
        type = history_combat_cfg.EBattleType.Escape,
        text = LocUtil.GetLocalizeResStr(40010001)
      },
      {
        type = history_combat_cfg.EBattleType.Others,
        text = LocUtil.GetLocalizeResStr(644)
      }
    }
  else
    modeList = {
      {
        type = history_combat_cfg.EBattleType.All,
        text = LocUtil.GetLocalizeResStr(642)
      },
      {
        type = history_combat_cfg.EBattleType.Rank,
        text = LocUtil.GetLocalizeResStr(602)
      },
      {
        type = history_combat_cfg.EBattleType.Match,
        text = LocUtil.GetLocalizeResStr(603)
      },
      {
        type = history_combat_cfg.EBattleType.Team,
        text = LocUtil.GetLocalizeResStr(643)
      },
      {
        type = history_combat_cfg.EBattleType.Escape,
        text = LocUtil.GetLocalizeResStr(40010001)
      },
      {
        type = history_combat_cfg.EBattleType.Others,
        text = LocUtil.GetLocalizeResStr(644)
      }
    }
  end
  return modeList
end
function logic_history_combat:ReportTlog(type)
  log(bWriteLog and "logic_history_combat:GetModeList type = " .. tostring(type))
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  local tlog = history_combat_cfg.ETypeToTLog[type]
  if tlog then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(tlog)
  end
end
function logic_history_combat:GetHistoryList(type)
  log(bWriteLog and "logic_history_combat:GetHistoryList type = " .. tostring(type))
  if not type then
    return nil
  end
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  if type == history_combat_cfg.EBattleType.All then
    return self.allGame
  end
  local historyList = {}
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  for key, value in pairs(self.allGame) do
    local battle_type = history_combat_util.GetBattleType(value.raw_battle_type)
    if battle_type and battle_type == type then
      table.insert(historyList, value)
    end
  end
  return historyList
end
function logic_history_combat:AddHistoryItem(combat_data)
  log(bWriteLog and "logic_history_combat:AddHistoryItem")
  if combat_data == nil or not next(combat_data) then
    log(bWriteLog and "logic_history_combat:AddHistoryItem combat_data is invalid")
    return
  end
  if self:IsNewRecord(combat_data) and not self.new_effect_table[tonumber(combat_data.battle_id)] then
    self.new_effect_table[tonumber(combat_data.battle_id)] = true
  end
  table.insert(self.allGame, combat_data)
end
function logic_history_combat:ClearHunterVsHuntedRecord()
  log(bWriteLog and "logic_history_combat:ClearHunterVsHuntedRecord")
  self.hvh_pop_data = {}
  local TimeUtil = require("client.common.time_util")
  self.last_clear_time = TimeUtil.GetServerTimeInSec()
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_set_hunter_vs_hunted_clear_time_req()
end
function logic_history_combat:CheckShowHunterVsHuntedPop()
  log_tree("logic_history_combat:CheckShowHunterVsHuntedPop hvh_pop_data = ", self.hvh_pop_data)
  if #self.hvh_pop_data == 0 then
    return
  end
  self.last_clear_time = self.last_clear_time or 0
  log(bWriteLog and "logic_history_combat:TriggerHunterVsHunted last_clear_time = " .. self.last_clear_time)
  UIManager.CloseUI(UIManager.UI_Config.Butcher_Settlement_Popup_UIBP)
  UIManager.ShowUI(UIManager.UI_Config.Butcher_Settlement_Popup_UIBP, self.hvh_pop_data)
end
function logic_history_combat:ReqHistoryDataForHvHPop(battle_result)
  log_tree("logic_history_combat:ReqHistoryDataForHvHPop battle_result = ", battle_result)
  if battle_result.camp_type then
    local TimeUtil = require("client.common.time_util")
    local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
    local isHunter = battle_result.camp_type == history_combat_cfg.EHvHCampType.Hunter
    local person_state = 0
    if isHunter then
      person_state = battle_result.hunter_kill_num
    else
      person_state = battle_result.is_survivor_escaped and -1 or -2
    end
    table.insert(self.hvh_pop_data, {
      timestamp = TimeUtil.GetServerTimeInSec(),
      rating = isHunter and battle_result.hunter_rating or battle_result.hunted_rating,
      camp_type = battle_result.camp_type,
      change_rating_num = isHunter and battle_result.hunter_rating_change or battle_result.hunted_rating_change,
          })
  end
  self:CheckShowHunterVsHuntedPop()
end
function logic_history_combat:on_get_hunter_vs_hunted_clear_time_rsp(time)
  self.last_clear_end
function logic_history_combat:IsNewRecord(data)
  local time = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_HISTORY_NEWBIE, 1) or 0
  log(bWriteLog and "logic_history_combat:IsNewRecord time = " .. time)
  log(bWriteLog and "logic_history_combat:IsNewRecord data.timestamp = " .. data.timestamp)
  return data.timestamp > 1758852000 and time < data.timestamp
end
function logic_history_combat:ClearNewRecordEffectTag()
  local TimeUtil = require("client.common.time_util")
  local current_time = TimeUtil.GetServerTimeInSec()
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_HISTORY_NEWBIE, 1, current_time)
end
function logic_history_combat:IsShowEffect(battle_id)
  local get = self.new_effect_table[tonumber(battle_id)]
  if get then
    self.new_effect_table[tonumber(battle_id)] = false
    log(bWriteLog and "logic_history_combat:IsShowEffect true battle_id = " .. battle_id)
    return true
  end
  log(bWriteLog and "logic_history_combat:IsShowEffect false battle_id = " .. battle_id)
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_history_combat = class(CModuleBase, nil, logic_history_combat)
return Clogic_history_combat
local logic_xmission_history_record = {}
local CONST_MAX_SAVE_OTHER_DETAIL_COUNT = 30
function logic_xmission_history_record:DefineAndResetData()
  self.summary_record_list = nil
  self.detail_list = nil
end
function logic_xmission_history_record:OnLogOut()
  self:DefineAndResetData()
end
function logic_xmission_history_record:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
end
function logic_xmission_history_record:GetHistoryRecordDetailInfo(uid, battle_id)
  if not self.detail_list or not self.detail_list[uid] then
    return
  end
  return self.detail_list[uid][battle_id]
end
function logic_xmission_history_record:ClearDetailRecordData(uid)
  local roleUid = tonumber(uid)
  local selfUID = tonumber(DataMgr.roleData.uid)
  if roleUid == 0 or roleUid == selfUID then
    return
  end
  if not self.detail_list or not next(self.detail_list) then
    return
  end
  local totalCount = 0
  local TableUtil = require("common.table_util")
  for uid, detailList in pairs(self.detail_list) do
    if uid ~= selfUID then
      local num = TableUtil.CountTable(detailList)
      if num >= CONST_MAX_SAVE_OTHER_DETAIL_COUNT or num + totalCount > CONST_MAX_SAVE_OTHER_DETAIL_COUNT then
        self.detail_list[uid] = nil
      else
        totalCount = totalCount + num
      end
    end
  end
end
function logic_xmission_history_record:GetSummaryRecordList()
  return self.summary_record_list or {}
end
function logic_xmission_history_record:SaveShowGlowData()
  local recordList = self:GetSummaryRecordList()
  if #recordList <= 0 then
    log(bWriteLog and "logic_xmission_history_record:SaveShowGlowData no record")
    return
  end
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  for _, v in pairs(recordList) do
    if not RoleInfoHistorySystem.CheckIsShowGlowEffect(v.battle_id, v.time) then
      local has_replay = logic_share_replay.CheckHasBattleReplay(v.battle_id)
      if has_replay then
        RoleInfoHistorySystem.UpdateShowGlowSaveData(v.battle_id, v.time)
      end
    end
  end
  if not RoleInfoHistorySystem.showReplayGlowEffect then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(RoleInfoHistorySystem.showReplayGlowEffect, PlayerPrefsSystem.ePlayerPrefsType.eHistoryReplayEffect)
end
function logic_xmission_history_record:GetZombieScoreInfo(PlayerKillAIScoreTotal)
  log_tree(bWriteLog and "logic_xmission_history_record:GetZombieScoreInfo PlayerKillAIScoreTotal", PlayerKillAIScoreTotal)
  local StringUtil = require("common.string_util")
  local temp = StringUtil.Split(PlayerKillAIScoreTotal, ",")
  log_tree(bWriteLog and "logic_xmission_history_record:GetZombieScoreInfo temp", temp)
  local res = {}
  local sum = 0
  for i = 1, 3 do
    local str = StringUtil.Split(temp[i], ":")
    if tonumber(str[1]) == 1 then
      res.kill_normal_monster_score = tonumber(str[2])
    elseif tonumber(str[1]) == 2 then
      res.kill_elite_monster_score = tonumber(str[2])
    elseif tonumber(str[1]) == 3 then
      res.kill_boss_monster_score = tonumber(str[2])
    end
    sum = sum + tonumber(str[2])
  end
  res.kill_monster_score = sum
  log_tree(bWriteLog and "logic_xmission_history_record:GetZombieScoreInfo res", res)
  return res
end
function logic_xmission_history_record:on_get_t_mode_history_record_summary_rsp(uid, summary_list)
  log(bWriteLog and "[v_wllwu] logic_xmission_history_record:on_get_t_mode_history_record_summary_rsp, uid is:" .. tostring(uid))
  local tmpList = {}
  if summary_list then
    for _, v in ipairs(summary_list) do
      v.time = v.time or 0
      if v and v.time then
        table.insert(tmpList, v)
      end
    end
  end
  self.summary_record_list = tmpList
  if self.summary_record_list and #self.summary_record_list > 1 then
    table.sort(self.summary_record_list, function(a, b)
      return a.time > b.time
    end)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_UPDATE_HISTORY_SUMMARY)
end
function logic_xmission_history_record:on_batch_get_t_mode_history_record_rsp(uid, detail_list)
  log_tree(bWriteLog and "logic_xmission_history_record:on_batch_get_t_mode_history_record_rsp detail_list", detail_list)
  if not self.detail_list then
    self.detail_list = {}
  end
  if not self.detail_list[uid] then
    self.detail_list[uid] = {}
  end
  if detail_list and 0 < #detail_list then
    for _, v in ipairs(detail_list) do
      self.detail_list[uid][v.battle_id] = v
    end
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_UPDATE_HISTORY_DETAIL_INFO)
end
function logic_xmission_history_record:ShowXMissionDetailPage(battle_result)
  local battle_id = battle_result.battle_id or 0
  log(bWriteLog and "logic_xmission_history_record:ShowXMissionDetailPage battle_id" .. tostring(battle_id))
  local logic_roleinfo_history = require("client.logic.roleinfo.logic_roleinfo_history")
  logic_roleinfo_history.SetRecordBattleId(tonumber(battle_id))
  local tData = logic_roleinfo_history.role_history_record[tonumber(battle_id)]
  if tData and tData.uid and tonumber(tData.uid) ~= tonumber(self.uid) then
    logic_roleinfo_history.role_history_record[tonumber(battle_id)] = nil
    tData = nil
  end
  if tData then
    logic_roleinfo_history.ShowRecord(tData)
  else
    local CharacterHandler = require("client.network.Protocol.CharacterHandler")
    CharacterHandler.send_bath_get_history_record(tonumber(DataMgr.roleData.uid), {
      tonumber(battle_id)
    })
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_history_record = class(CModuleBase, nil, logic_xmission_history_record)
return Clogic_xmission_history_record
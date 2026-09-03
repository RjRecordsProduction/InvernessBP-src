local logic_mentor_record = {
  listProfile = {},
  recordData = {},
  limitAwardCount = 0,
  getAwardCount = 0,
  ENUM_HISTORY_RECORD_STAT = {
    HISTORY_STAT_NO_EVALUATE_ESCAPE = 1,
    HISTORY_STAT_NO_EVALUATE = 2,
    HISTORY_STAT_ESCAPE = 3,
    HISTORY_STAT_NOT_REWARD = 4,
    HISTORY_STAT_REWARDED = 5,
    HISTORY_STAT_OVER_TIMES = 6,
    HISTORY_STAT_OVER_TIMES_NO_EVALUATE = 7
  }
}
function logic_mentor_record.GetProfile(listUid)
  log_tree("god test profile", listUid)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(listUid, logic_mentor_record.GetProfileCallBack, 1095)
end
function logic_mentor_record.GetProfileCallBack(profiles)
  local listUid = {}
  if profiles then
    for _, v in pairs(profiles) do
      if not logic_mentor_record.listProfile[v.uid] then
        logic_mentor_record.listProfile[v.uid] = v
        table.insert(listUid, v.uid)
      end
    end
  end
  log_tree("god test GetProfileCallBack ", profiles)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECORD_PROFILE, listUid)
end
function logic_mentor_record.ExistProfile(uid)
  if logic_mentor_record.listProfile[uid] then
    return true
  end
  return false
end
function logic_mentor_record.mentor_history_req()
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_history_req()
end
function logic_mentor_record.mentor_evaluate_req(evaluate, labels)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  local labels_new = {}
  if labels then
    for _, v in pairs(labels) do
      if type(v) == "number" then
        labels_new[tonumber(v)] = true
      end
    end
  end
  log_tree("mentor_evaluate_req", {evaluate = evaluate, labels_new = labels_new})
  MentorHandler.send_mentor_evaluate_req(evaluate, labels_new)
end
function logic_mentor_record.mentee_evaluate_req(evaluate, labels)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  local labels_new = {}
  if labels then
    for _, v in pairs(labels) do
      if type(v) == "number" then
        labels_new[tonumber(v)] = true
      end
    end
  end
  log_tree("mentee_evaluate_req", {evaluate = evaluate, labels_new = labels_new})
  MentorHandler.send_mentee_evaluate_req(evaluate, labels_new)
end
function logic_mentor_record.send_mentor_reward_req(battle_id)
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  log(bWriteLog and "god test send battle id " .. battle_id)
  MentorHandler.send_mentor_reward_req(battle_id)
end
function logic_mentor_record.send_mentor_batch_reward_req()
  local MentorHandler = require("client.network.Protocol.MentorHandler")
  MentorHandler.send_mentor_batch_reward_req()
end
function logic_mentor_record.on_mentor_reward_rsp(res, battle_id, awards)
  log(bWriteLog and "god test on_mentor_reward_rsp " .. tostring(res))
  log(bWriteLog and "god test battle_id " .. tostring(battle_id))
  log_tree("god test on_mentor_reward_rsp", awards)
  if res == 0 then
    local battleIdList = {battle_id}
    for _, v in pairs(logic_mentor_record.recordData) do
      if v.battle_id == battle_id then
        v.stat = logic_mentor_record.ENUM_HISTORY_RECORD_STAT.HISTORY_STAT_REWARDED
      end
    end
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECORD_GET_REWARD, battleIdList)
    local arrayItemData = {}
    for k, v in pairs(awards) do
      if arrayItemData[v.resid] then
        arrayItemData[v.resid].count = v.count + arrayItemData[v.resid].count
      else
        arrayItemData[v.resid] = {
          res_id = v.resid,
          count = v.count
        }
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
  else
    ShowNotice(res)
  end
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_award_stat_req()
end
function logic_mentor_record.on_mentor_batch_reward_rsp(res, awards)
  log(bWriteLog and "god test on_mentor_reward_rsp " .. res)
  log_tree("god test on_mentor_reward_rsp", awards)
  if res == 0 then
    local arrayItemData = {}
    local battleIdList = {}
    for k, v in pairs(awards) do
      table.insert(battleIdList, k)
      for _, vv in pairs(v) do
        if arrayItemData[vv.resid] then
          arrayItemData[vv.resid].count = vv.count + arrayItemData[vv.resid].count
        else
          arrayItemData[vv.resid] = {
            res_id = vv.resid,
            count = vv.count
          }
        end
      end
      for _, data in pairs(logic_mentor_record.recordData) do
        if data.battle_id == k then
          data.stat = logic_mentor_record.ENUM_HISTORY_RECORD_STAT.HISTORY_STAT_REWARDED
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECORD_GET_REWARD, battleIdList)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
  end
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_award_stat_req()
end
function logic_mentor_record.on_mentor_evaluate_rsp(res)
  if res == 0 then
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_EVALUATE_SUC)
  else
    ShowNotice(res)
  end
end
function logic_mentor_record.on_mentee_evaluate_rsp(res)
  if res == 0 then
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTEE_EVALUATE_SUC)
  else
    ShowNotice(res)
  end
end
function logic_mentor_record.mentory_history_rsp(res, today_mentor_count, mentor_award_datly_limit, mentor_data_historys)
  log(bWriteLog and "god test res " .. res .. " today_mentror_count " .. today_mentor_count .. " mentor_award_datly_limit " .. mentor_award_datly_limit)
  log_tree("god test mentor_data_historys", mentor_data_historys)
  logic_mentor_record.recordData = mentor_data_historys
  table.sort(logic_mentor_record.recordData, function(l, r)
    return l.game_time > r.game_time
  end)
  logic_mentor_record.limitAwardCount = mentor_award_datly_limit
  logic_mentor_record.getAwardCount = math.min(mentor_award_datly_limit, today_mentor_count or 0)
  EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_RECORD_GET_RECORD_DATA)
end
function logic_mentor_record.GetRewardCount()
  local RewardCount = 0
  for k, v in ipairs(logic_mentor_record.recordData) do
    if v.stat == logic_mentor_record.ENUM_HISTORY_RECORD_STAT.HISTORY_STAT_NOT_REWARD then
      RewardCount = RewardCount + 1
    end
  end
  return RewardCount
end
function logic_mentor_record.GetRewardItem()
  for i, v in ipairs(logic_mentor_record.recordData) do
    if v.stat == logic_mentor_record.ENUM_HISTORY_RECORD_STAT.HISTORY_STAT_NOT_REWARD then
      return v
    end
  end
  if #logic_mentor_record.recordData >= 1 then
    return logic_mentor_record.recordData[1]
  end
  return nil
end
function logic_mentor_record.OpenMentorRecord()
  UIManager.ShowUI(UIManager.UI_Config.mentor_record)
end
return logic_mentor_record
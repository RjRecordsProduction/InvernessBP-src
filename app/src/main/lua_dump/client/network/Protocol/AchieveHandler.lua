local NetManager = require("client.network.comm.NetManager")
local AchieveHandler = {
  resRecordRewardsList = nil,
  resSummaryTb = {},
  resGetedAchieveRewardList = nil,
  resAchiveData = nil,
  bGetExtinctRsp = false
}
local StringUtil = require("common.string_util")
function AchieveHandler.send_get_achievement_summary_req(uid)
  log(bWriteLog and "AchieveHandler.send_get_achievement_summary_req uid = " .. tostring(uid))
  if uid == nil then
    return
  end
  NetManager.SendPkg(1009908272, uid)
end
local EnumUpdateType = {Complete = 1, Part = 2}
function AchieveHandler.on_get_achievement_summary_res(update_Type, res)
  log(bWriteLog and "AchieveHandler.on_get_achievement_summary_res update_Type = " .. update_Type)
  if update_Type == EnumUpdateType.Complete then
    local uid1 = tonumber(res.uid)
    if uid1 then
      AchieveHandler.resSummaryTb[uid1] = res
    end
  else
    local uid2 = tonumber(DataMgr.roleData.uid)
    if AchieveHandler.resSummaryTb[uid2] then
      AchieveHandler.MergeToCompleteSummaryInfo(uid2, res)
    end
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local uid = res.uid or DataMgr.roleData.uid
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rankID = RankDataMgr.GetAchieveRequireID()
  RankHandler.send_get_one_user_rank("AchievementPK", 0, tonumber(uid), rankID)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.AchievementSummaryGet = res.uid or 0
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  if LobbySocialSystem.IsSelf(res.uid) then
    LobbySocialSystem.self_achievement_summary = AchieveHandler.GetSummaryInfoByUid(res.uid)
  end
  local achievement_red = require("client.logic.achievement.achievement_red")
  achievement_red.UpdateScoreRedDot()
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_Summary)
end
function AchieveHandler.MergeToCompleteSummaryInfo(uid, partInfo)
  if partInfo.achieve_score ~= nil then
    AchieveHandler.resSummaryTb[uid].achieve_score = partInfo.achieve_score
  end
  if partInfo.show ~= nil then
    for id, _ in pairs(partInfo.show) do
      AchieveHandler.resSummaryTb[uid].show[id] = partInfo.show[id]
    end
  end
  if partInfo.time ~= nil then
    for id, _ in pairs(partInfo.time) do
      AchieveHandler.resSummaryTb[uid].time[id] = partInfo.time[id]
    end
  end
  if partInfo.progress ~= nil then
    for k, v in pairs(partInfo.progress) do
      AchieveHandler.resSummaryTb[uid].progress[k] = v
    end
  end
end
function AchieveHandler.IsSummaryShowAchID(id)
  local myInfo = AchieveHandler.GetMyAchieveInfo()
  if myInfo == nil then
    return false
  end
  for k, v in pairs(myInfo.show) do
    if v == id then
      return true
    end
  end
  return false
end
function AchieveHandler.GetMyAchieveScore()
  local myUid = tonumber(DataMgr.roleData.uid)
  local myAchInfo = AchieveHandler.resSummaryTb[myUid]
  if myAchInfo then
    return myAchInfo.achieve_score or 0
  else
    return 0
  end
end
function AchieveHandler.GetMyAchieveInfo()
  local myUid = tonumber(DataMgr.roleData.uid)
  return AchieveHandler.resSummaryTb[myUid]
end
function AchieveHandler.GetSummaryInfoByUid(uid)
  return AchieveHandler.resSummaryTb[uid]
end
function AchieveHandler.send_get_achieve_rewards_list_req()
  log(bWriteLog and "AchieveHandler.send_get_achieve_rewards_list_req")
  NetManager.SendPkg(226995336)
end
function AchieveHandler.on_get_achieve_rewards_list_res(res)
  AchieveHandler.resGetedAchieveRewardList = res
  local SocialBottomAliasSystem = require("client.slua.logic.lobby.Left.logic_social_bottom_alias")
  SocialBottomAliasSystem.InitAchievement(res)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_GOT_SOCIAL_ACHIEVEMENT_DATA)
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_GetedAchiveRewardList)
end
function AchieveHandler.GetResGotAchieveRewardList()
  return AchieveHandler.resGetedAchieveRewardList
end
function AchieveHandler.IsGetAchRewardByID(achid)
  if AchieveHandler.resGetedAchieveRewardList == nil then
    return false
  end
  local bGet = AchieveHandler.resGetedAchieveRewardList[achid]
  if bGet == nil then
    return false
  end
  return true
end
function AchieveHandler.send_get_achievement_rewards_req(id)
  log(bWriteLog and "AchieveHandler.send_get_achievement_rewards_req id = " .. id)
  NetManager.SendPkg(841720992, id)
end
function AchieveHandler.on_get_achievement_rewards_res(id, result, timestamps, isRewardClick)
  log(bWriteLog and "AchieveHandler.on_get_achievement_rewards_res id = " .. id .. ", result = " .. result .. ", timestamps = " .. timestamps)
  if result ~= 0 then
    local localID = result
    if result == 1 then
      localID = 655702
    elseif result == 2 then
      localID = 655703
    end
    ShowNotice(localID)
    return
  end
  if isRewardClick ~= 1 then
    local RankHandler = require("client.network.Protocol.RankHandler")
    local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
    local rankID = RankDataMgr.GetAchieveRequireID()
    RankHandler.send_get_topn_rank(0, rankID)
    RankHandler.send_get_one_user_rank("AchievementPK", 0, 0, rankID)
  end
  if AchieveHandler.resGetedAchieveRewardList == nil then
    return
  end
  AchieveHandler.resGetedAchieveRewardList[id] = timestamps
  local achievement_red = require("client.logic.achievement.achievement_red")
  achievement_red.UpdateAchieveRedDotByAchID(id)
  local allData = {}
  if isRewardClick == 1 then
    EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_GetOneAchiveReward)
    return
  end
  local Cfg = CDataTable.GetTableData("AchievementCfg", id)
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  local IsMapping, AwardID, AwardNum, AwardID2, AwardNum2 = logic_achievement.GetAward(id)
  if Cfg.AwardID and 0 < Cfg.AwardID then
    local award1 = {}
    if IsMapping then
      award1.res_id = AwardID
      award1.count = AwardNum
    else
      award1.res_id = Cfg.AwardID
      award1.count = Cfg.AwardNum
    end
    award1.valid_hours = 0
    table.insert(allData, award1)
  end
  if Cfg.AwardID2 and 0 < Cfg.AwardID2 then
    local award2 = {}
    if IsMapping then
      award2.res_id = AwardID2
      award2.count = AwardNum2
    else
      award2.res_id = Cfg.AwardID2
      award2.count = Cfg.AwardNum2
    end
    award2.valid_hours = 0
    table.insert(allData, award2)
  end
  local cb = function()
    if Cfg.ShareFlag > 0 then
      logic_achievement.OpenShareUI(id)
    end
  end
  if 0 < #allData then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_AchievementStyle(allData, Cfg.Score, cb)
  end
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_GetOneAchiveReward)
end
function AchieveHandler.send_get_achieve_hit_list_req()
  log(bWriteLog and "AchieveHandler.send_get_achieve_hit_list_req")
  NetManager.SendPkg(1781076488)
end
function AchieveHandler.on_get_achieve_hit_list_res(res)
end
function AchieveHandler.send_get_achievement_data_req()
  log(bWriteLog and "AchieveHandler.send_get_achievement_data_req")
  NetManager.SendPkg(1523407560)
end
function AchieveHandler.on_get_achievement_data_res(type, res)
  log_tree("AchieveHandler.on_get_achievement_data_res type = " .. type, res)
  local idList
  if type == EnumUpdateType.Complete then
    AchieveHandler.resAchiveData = res
  elseif AchieveHandler.resAchiveData then
    AchieveHandler.MergeToCompleteAchiveData(AchieveHandler.resAchiveData, res)
    local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
    idList = achievement_cfg_helper.GetAchieveIdListFromConditionProcess(res)
  else
    return
  end
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UpdateDataOnRsp(idList)
  log_tree("[PXY]on_get_achievement_data_res", idList)
  local achievement_red = require("client.logic.achievement.achievement_red")
  achievement_red.UpdateAchieveRedDotByList(idList)
  achievement_red.UpdateScoreRedDot()
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_achievement_data)
end
function AchieveHandler.MergeToCompleteAchiveData(resAchiveData, res)
  if resAchiveData == nil or res == nil then
    return
  end
  for k, v in pairs(res) do
    local info = resAchiveData[k]
    if info == nil then
      info = {}
      resAchiveData[k] = info
    end
    for kk, vv in pairs(v) do
      info[kk] = vv
    end
  end
end
function AchieveHandler.GetConditionProcess(ConditionID, Param2TypeID)
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  if logic_achievement.IsRankConditionByConditionID(ConditionID) then
    Param2TypeID = 0
  end
  if AchieveHandler.resAchiveData and AchieveHandler.resAchiveData[ConditionID] and AchieveHandler.resAchiveData[ConditionID][Param2TypeID] then
    return AchieveHandler.resAchiveData[ConditionID][Param2TypeID]
  end
  return nil
end
function AchieveHandler.CheckAchiveCanFinishWithCfg(id, cfg)
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", id)
  end
  if cfg == nil then
    return false, -1
  end
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  if not logic_achievement.GetIsClientShowByNetDataAward(id) then
    return false, -1
  end
  local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
  local _, canFinish, lastFinishTimeStamp = achievement_cfg_tool.GetAchievementProcessInfo(cfg.Conditions, true)
  return canFinish, lastFinishTimeStamp
end
function AchieveHandler.CheckAchiveFinishTimeStampWithCfg(id, cfg)
  local TimeStamp = -1
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", id)
  end
  if cfg == nil then
    return TimeStamp
  end
  local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
  local _, _, LastFinishTime = achievement_cfg_tool.GetAchievementProcessInfo(cfg.Conditions, true)
  return LastFinishTime
end
function AchieveHandler.send_get_achieve_assist_req()
  log(bWriteLog and "AchieveHandler.send_get_achieve_assist_req")
  NetManager.SendPkg(1834431495)
end
function AchieveHandler.on_get_achieve_assist_rsp(res)
end
function AchieveHandler.on_achievement_event_limit_rsp(event_id, sub_id, curr_count, limit_type, limit_count)
  log_tree("on_achievement_event_limit_rsp event_id=" .. tostring(event_id) .. " sub_id= " .. tostring(sub_id) .. " curr_count=" .. tostring(curr_count) .. " limit_type=" .. tostring(limit_type), limit_count)
  local text = ""
  if limit_type == 1 then
    text = LocUtil.GetLocalizeResStr(7725)
  elseif limit_type == 2 then
    text = LocUtil.GetLocalizeResStr(7726)
  end
  local textMap = {}
  local achievementList = ""
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local tb = achievement_cfg_helper.CreateCondID2CfgID()
  if not tb then
    log(bWriteLog and "AchieveHandler.on_achievement_event_limit_rsp not CreateCondID2CfgID table")
    return
  end
  local idList = tb[event_id]
  for k, id in pairs(idList) do
    local v = CDataTable.GetTableData("AchievementCfg", id)
    local condition = v.Conditions
    local arry = StringUtil.Split(condition, "-")
    local arry_3 = StringUtil.Split(arry[3], ";")
    if tonumber(arry_3[1]) == sub_id and curr_count < tonumber(arry[2]) then
      local _name = ""
      if v.ShowType == 2 then
        _name = v.MultiLvGroupTitle
      else
        _name = v.Name
      end
      if not textMap[_name] then
        if achievementList == "" then
          achievementList = _name
        else
          achievementList = achievementList .. "\227\128\129" .. _name
        end
        textMap[_name] = true
      end
    end
  end
  if achievementList ~= "" then
    text = LocUtil.GeneralFormat(text, achievementList)
    ShowNotice(text)
  end
end
function AchieveHandler.on_achievement_event_limit_notify(event_limit_list)
  local text = LocUtil.GetLocalizeResStr(7727)
  local textMap = {}
  local achievementList = ""
  for k, v in pairs(CDataTable.GetTable("AchievementCfg")) do
    for kkk, vvv in pairs(event_limit_list) do
      for kk, vv in pairs(vvv) do
        local event_id = kkk
        local sub_id = kk
        local condition = v.Conditions
        local arry = StringUtil.Split(condition, "-")
        local arry_3 = StringUtil.Split(arry[3], ";")
        if tonumber(arry[1]) == event_id and tonumber(arry_3[1]) == sub_id then
          local _name = ""
          if v.ShowType == 2 then
            _name = v.MultiLvGroupTitle
          else
            _name = v.Name
          end
          if not textMap[_name] then
            if achievementList == "" then
              achievementList = _name
            else
              achievementList = achievementList .. "\227\128\129" .. _name
            end
            textMap[_name] = true
          end
        end
      end
    end
  end
  if achievementList ~= "" then
    text = LocUtil.GeneralFormat(text, achievementList)
    ShowNotice(text)
  end
end
function AchieveHandler.send_report_achievement_condition_complete(event_id, sub_id, count)
  NetManager.SendPkg(943513800, event_id, sub_id, count)
end
function AchieveHandler.send_get_achieve_record_rewards_list_req()
  log(bWriteLog and "AchieveHandler.send_get_achieve_record_rewards_list_req")
  NetManager.SendPkg(709298722)
end
function AchieveHandler.on_get_achieve_record_rewards_list_res(res)
  AchieveHandler.resRecordRewardsList = res
  local achievement_red = require("client.logic.achievement.achievement_red")
  achievement_red.UpdateScoreRedDot()
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_RecordRewardList)
end
function AchieveHandler.send_get_achieve_record_rewards_req(id)
  log(bWriteLog and "AchieveHandler.send_get_achieve_record_rewards_req id = " .. id)
  NetManager.SendPkg(1683340488, id)
end
function AchieveHandler.on_get_achieve_record_rewards_res(id, errCode, timestamp)
  log(bWriteLog and "AchieveHandler.on_get_achieve_record_rewards_res id = " .. id .. ", errCode = " .. errCode .. ", timestamp = " .. timestamp)
  if errCode ~= 0 then
    if errCode == 1 then
      ShowNotice(108104)
    else
      ShowNotice(108106)
    end
    return
  end
  if AchieveHandler.resRecordRewardsList == nil then
    return
  end
  AchieveHandler.resRecordRewardsList[id] = timestamp
  local achievement_red = require("client.logic.achievement.achievement_red")
  achievement_red.UpdateScoreRedDot()
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  local AllData = achievement_cfg_helper.Load_AchievementScoreCfg()
  local data = AllData[id]
  if data == nil then
    return
  end
  local arrayItemData = {}
  table.insert(arrayItemData, {
    res_id = data.res_id,
    count = data.cnt,
    valid_hours = 0
  })
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
  local roleinfo_main = UIManager.GetUI(UIManager.UI_Config.roleinfo_main)
  local Achievement_Task_UIBP = UIManager.GetUI(UIManager.UI_Config.Achievement_Task_UIBP)
  if roleinfo_main then
    roleinfo_main:_UpdateRedPoint(5)
  end
  if Achievement_Task_UIBP then
    Achievement_Task_UIBP:UpDataRed()
  end
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT_NEW, EVENTID_ACHIEVEMENT_UPDATE_RECORD_REWARDS)
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_UPDATE_AWARD)
end
function AchieveHandler.GetRecordRewardTimeStampByID(id)
  if not AchieveHandler.resRecordRewardsList then
    log(bWriteLog and "AchieveHandler GetRecordRewardTimeStampByID has no data but awardid is", id)
    return false
  end
  return AchieveHandler.resRecordRewardsList[id]
end
function AchieveHandler.send_get_achieve_hit_req(id)
  NetManager.SendPkg(608884203, id)
end
function AchieveHandler.send_report_achievement_finish(id)
  log(bWriteLog and "send_report_achievement_finish " .. id)
  NetManager.SendPkg(861501402, id)
end
function AchieveHandler.send_set_achievement_show_req(req)
  NetManager.SendPkg(2136020587, req)
end
function AchieveHandler.send_batch_get_achieve_hit_req(achieveList)
  NetManager.SendPkg(2058966464, achieveList)
end
function AchieveHandler.on_batch_get_achieve_hit_res(res)
end
function AchieveHandler.send_get_achieve_extinct_req()
  NetManager.SendPkg(1906194579)
end
function AchieveHandler.on_get_achieve_extinct_rsp(err_code, extinct_achieve_ids, notified_extinct_ids)
  if err_code ~= 0 then
    return
  end
  AchieveHandler.bGetExtinctRsp = true
  AchieveHandler.resOutPrintInfo = extinct_achieve_ids
  AchieveHandler.resExtinctInfo = notified_extinct_ids
end
function AchieveHandler.IsExtinctByID(AchID)
  if not AchID then
    return nil
  end
  local outTime = AchieveHandler.GetExtinctTimeStampWithCfg(AchID)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if outTime then
    if AchieveHandler.bGetExtinctRsp then
      if outTime <= now then
        return true
      else
        return false
      end
    elseif outTime < now then
      return true
    else
      return false
    end
  else
    return false
  end
end
function AchieveHandler.GetExtinctTimeStampWithCfg(AchID, cfg)
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", AchID)
  end
  if not cfg or cfg.AchType ~= 1 then
    return nil
  end
  if AchieveHandler.bGetExtinctRsp then
    return AchieveHandler.resOutPrintInfo[AchID]
  else
    local TimeUtil = require("client.common.time_util")
    local versionTime = TimeUtil.TimeStringToUnixstamp(cfg.OutPrintTime)
    return versionTime
  end
end
function AchieveHandler.on_gamecenter_achiev_notify(event_id, sub_id, achieve_data, gamecenter_achievement_cfg)
  log(bWriteLog and string.format("AchieveHandler.on_gamecenter_achiev_notify, event_id:%s", event_id))
  log(bWriteLog and string.format("AchieveHandler.on_gamecenter_achiev_notify, sub_id:%s", sub_id))
  log_tree(bWriteLog and "AchieveHandler.on_gamecenter_achiev_notify achieve_data", achieve_data)
  log_tree(bWriteLog and "AchieveHandler.on_gamecenter_achiev_notify gamecenter_achievement_cfg", gamecenter_achievement_cfg)
  local logic_apple_gamecenter_achievement = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_apple_gamecenter_achievement)
  logic_apple_gamecenter_achievement:on_gamecenter_achiev_notify(event_id, sub_id, achieve_data, gamecenter_achievement_cfg)
end
function AchieveHandler.on_googleplay_achiev_notify(event_id, sub_id, achieve_data, gamecenter_achievement_cfg)
  log(bWriteLog and string.format("AchieveHandler.on_googleplay_achiev_notify, event_id:%s", event_id))
  log(bWriteLog and string.format("AchieveHandler.on_googleplay_achiev_notify, sub_id:%s", sub_id))
  log_tree(bWriteLog and "AchieveHandler.on_googleplay_achiev_notify achieve_data", achieve_data)
  log_tree(bWriteLog and "AchieveHandler.on_googleplay_achiev_notify gamecenter_achievement_cfg", gamecenter_achievement_cfg)
  local logic_google_play_achievement = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_google_play_achievement)
  logic_google_play_achievement:on_googleplay_achiev_notify(event_id, sub_id, achieve_data, gamecenter_achievement_cfg)
end
local reqRsp = {
  send_get_achieve_hit_list_req = "on_get_achieve_hit_list_res",
  send_get_achieve_record_rewards_list_req = "on_get_achieve_record_rewards_list_res",
  send_get_achieve_rewards_list_req = "on_get_achieve_rewards_list_res",
  send_get_achievement_data_req = "on_get_achievement_data_res",
  send_get_achievement_summary_req = "on_get_achievement_summary_res",
  send_get_achieve_assist_req = "on_get_achieve_assist_rsp",
  send_get_achievement_rewards_req = "on_get_achievement_rewards_res",
  send_get_achieve_record_rewards_req = "on_get_achieve_record_rewards_res",
  send_batch_get_achieve_hit_req = "on_batch_get_achieve_hit_res",
  send_get_achieve_extinct_req = "on_get_achieve_extinct_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, AchieveHandler)
return AchieveHandler
local CorpsTrainingSystem = {
  TodayTrainID = 0,
  TodaySelfTaskID = 0,
  TodaySelfTotal = 0,
  TodaySelfScore = 0,
  TodaySelfStatus = 1,
  TodaySelfAwards = {},
  TodayCorpsScore = 0,
  TodayCorpsTaskList = {},
  TodayRankList = {},
  TrainHisRankInfo = {},
  reqTrainInfoCallBack = nil,
  reqRoleInfoTimeList = {},
  TrainRoleInfo = {},
  TrainRedPointIsShow = false,
  TodayWeekDay = 0,
  nProgress = 0,
  nSelfRankNo = 0,
  tRankItemInfoSelf = {},
  ETodaySelfStatus = {
    NotFinish = 1,
    Finished = 2,
    HasGet = 3
  },
  TeamTraining = nil,
  TeamTaskProgress = 0,
  TeamTaskStatus = 0
}
function CorpsTrainingSystem.ResetData()
  CorpsTrainingSystem.TodayTrainID = 0
  CorpsTrainingSystem.TodaySelfTaskID = 0
  CorpsTrainingSystem.TodaySelfTotal = 0
  CorpsTrainingSystem.TodaySelfScore = 0
  CorpsTrainingSystem.TodaySelfStatus = CorpsTrainingSystem.ETodaySelfStatus.NotFinish
  CorpsTrainingSystem.TodaySelfAwards = {}
  CorpsTrainingSystem.TodayCorpsScore = 0
  CorpsTrainingSystem.TodayCorpsTaskList = {}
  CorpsTrainingSystem.TodayRankList = {}
  CorpsTrainingSystem.TrainHisRankInfo = {}
  CorpsTrainingSystem.reqTrainInfoCallBack = nil
  CorpsTrainingSystem.reqRoleInfoTimeList = {}
  CorpsTrainingSystem.TrainRoleInfo = {}
  CorpsTrainingSystem.TrainRedPointIsShow = false
  CorpsTrainingSystem.TeamTraining = {}
  CorpsTrainingSystem.TeamTaskProgress = 0
  CorpsTrainingSystem.TeamTaskStatus = 0
end
function CorpsTrainingSystem.GenRoleInfoData(info)
  local fixWord = FuncUtil.GetKeywordByID(3377006) .. "_vip"
  local data = {
    uid = info.uid,
    name = info.nickName,
    plat_name = info.platName,
    url = info.picUrl,
    level = info.level,
    city = info.city,
    gender = info.sex,
    cur_avatar_box_id = info.cur_avatar_box_id,
    startup_type = info.startup_type,
    bgbg_vip = GetSafeNumber(info[fixWord])
  }
  return data
end
function CorpsTrainingSystem.IsNeedReqRoleInfo(uid)
  local tm = CorpsTrainingSystem.reqRoleInfoTimeList[tostring(uid)]
  local TimeUtil = require("client.common.time_util")
  local now_tm = TimeUtil.GetServerTimeInSec()
  if tm == nil or 60 <= now_tm - tm then
    return true
  end
  return false
end
function CorpsTrainingSystem.RecordRoleInfoReq(uid)
  local TimeUtil = require("client.common.time_util")
  CorpsTrainingSystem.reqRoleInfoTimeList[tostring(uid)] = TimeUtil.GetServerTimeInSec()
end
function CorpsTrainingSystem.GetTrainRoleInfo(uid)
  local info = CorpsTrainingSystem.TrainRoleInfo[tostring(uid)]
  return info
end
function CorpsTrainingSystem.GetTodayTrainCfg()
  local cfg = CDataTable.GetTableData("CorpsTrainingConfig", CorpsTrainingSystem.TodayTrainID)
  return cfg
end
function CorpsTrainingSystem.JumpToTodayTrain()
  local cfg = CDataTable.GetTableData("CorpsTrainingConfig", CorpsTrainingSystem.TodayTrainID)
  if nil == cfg then
    return
  end
  if _G[cfg.JumpID] == nil then
    return
  end
  GlobalData.JumpUrl("game://?module=" .. _G[cfg.JumpID])
end
function CorpsTrainingSystem.OpenTrainingUI()
  CorpsTrainingSystem.ResetData()
  if not LobbySystem.CheckOpen(BP_ENUM_CORPS_UI_TRAINING) then
    ShowNotice(116009)
    return
  end
  ClientSendBAReport(TLogEventDefine.CorpsTraining, 0)
  if not UIManager.IsUIShow(UIManager.UI_Config.CropsTraining_UIBP) then
    UIManager.ShowUI(UIManager.UI_Config.CropsTraining_UIBP)
  end
end
function CorpsTrainingSystem.ReqCorpsTrainingInfo(isWaitting, callback)
  CorpsTrainingSystem.reqTrainInfoCallBack = callback
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  if isWaitting then
    CorpsHandler.send_get_corps_training_req()
  else
    CorpsHandler.send_get_corps_training_req()
  end
end
function CorpsTrainingSystem.ReqCorpsTrainingAward(task_id)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_corps_training_award_req(task_id)
end
function CorpsTrainingSystem.ReqTeamTrainingAward(task_id)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_task_award_req(task_id)
end
function CorpsTrainingSystem.corps_training_award_res(res, task_id, reward_list)
  log(bWriteLog and "CorpsTrainingSystem.corps_training_award_res res=" .. tostring(res))
  if tonumber(res) ~= 0 then
    ShowNotice(res)
    return
  end
  log(bWriteLog and "CorpsTrainingSystem.corps_training_award_res task_id=" .. tostring(task_id))
  local arrItemData = {}
  for k, v in pairs(reward_list) do
    local logic_corps = require("client.slua.logic.corps.logic_corps")
    if v.res_id == 1008 and not logic_corps.IsNewCorpsEnabled() then
      v.res_id = 1204
    end
    table.insert(arrItemData, {
      res_id = v.res_id,
      count = v.num
    })
  end
  if 0 < #arrItemData then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrItemData)
  end
  if task_id == CorpsTrainingSystem.TodaySelfTaskID then
    CorpsTrainingSystem.TodaySelfStatus = CorpsTrainingSystem.ETodaySelfStatus.HasGet
  else
    for i, v in pairs(CorpsTrainingSystem.TodayCorpsTaskList) do
      if v.task_id == task_id then
        v.status = 3
        break
      end
    end
  end
  CorpsTrainingSystem.CheckRedPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_training_req()
end
function CorpsTrainingSystem.on_corps_training_all_award_res()
  CorpsTrainingSystem.TrainRedPointIsShow = false
  CorpsTrainingSystem.CheckRedPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_training_req()
end
function CorpsTrainingSystem.get_corps_training_res(res, train_info)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "CorpsTrainingSystem.get_corps_training_res res=" .. tostring(res))
  if tonumber(res) ~= 0 then
    ShowNotice(res)
    return
  end
  log_tree("CorpsTrainingSystem.get_corps_training_res train_info=", train_info)
  if nil ~= train_info.today_train.today_date then
    CorpsTrainingSystem.TodayWeekDay = train_info.today_train.today_date
  else
    CorpsTrainingSystem.TodayWeekDay = TimeUtil.GetServerWeekDay()
  end
  CorpsTrainingSystem.TodayTrainID = train_info.today_train.train_id
  CorpsTrainingSystem.TodaySelfTaskID = train_info.today_train.person_task.task_id
  CorpsTrainingSystem.TodaySelfTotal = train_info.today_train.person_task.target
  CorpsTrainingSystem.TodaySelfScore = 0
  CorpsTrainingSystem.TodaySelfStatus = train_info.today_train.person_task.status
  CorpsTrainingSystem.TodaySelfAwards = train_info.today_train.person_task.award_list
  CorpsTrainingSystem.TodayCorpsTaskList = train_info.today_train.corps_task
  local bHasCorpsTaskFinished = false
  for _, v in pairs(CorpsTrainingSystem.TodayCorpsTaskList or {}) do
    if v.status == CorpsTrainingSystem.ETodaySelfStatus.Finished then
      bHasCorpsTaskFinished = true
      break
    end
  end
  CorpsTrainingSystem.TrainRedPointIsShow = CorpsTrainingSystem.TodaySelfStatus == CorpsTrainingSystem.ETodaySelfStatus.Finished or bHasCorpsTaskFinished
  local CorpGiftExchangeSystem = require("client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange")
  if CorpGiftExchangeSystem.IsStart() and CorpGiftExchangeSystem.valid_corps_exchange_conf then
    CorpsTrainingSystem.TodayCorpsTaskList[1].drop_id = CorpGiftExchangeSystem.valid_corps_exchange_conf.corps_award_dropid1
    CorpsTrainingSystem.TodayCorpsTaskList[2].drop_id = CorpGiftExchangeSystem.valid_corps_exchange_conf.corps_award_dropid2
    CorpsTrainingSystem.TodayCorpsTaskList[3].drop_id = CorpGiftExchangeSystem.valid_corps_exchange_conf.corps_award_dropid3
  end
  CorpsTrainingSystem.TodayCorpsScore = 0
  CorpsTrainingSystem.TrainHisRankInfo = train_info.train_rank
  CorpsTrainingSystem.TodayRankList = {}
  local curWeek = CorpsTrainingSystem.TodayWeekDay
  local curRankData = train_info.train_rank[curWeek]
  local uidList = {}
  if nil ~= curRankData then
    CorpsTrainingSystem.TodayCorpsScore = curRankData.new_corps_score or 0
    for k, v in pairs(curRankData.members) do
      if tostring(k) == tostring(DataMgr.roleData.uid) then
        CorpsTrainingSystem.TodaySelfScore = v
      end
      if 0 < v then
        local rankItem = {}
        rankItem.no = 0
        rankItem.itemType = 0
        rankItem.name = ""
        rankItem.url = ""
        rankItem.level = 0
        rankItem.city = ""
        rankItem.gender = 0
        rankItem.cur_avatar_box_id = 0
        rankItem.startup_type = 0
        rankItem.bgbg_vip = 0
        rankItem.uid = k
        rankItem.score = v
        rankItem.time = 0
        if curRankData.last_train_time ~= nil then
          rankItem.time = GetSafeNumber(curRankData.last_train_time[k])
        end
        table.insert(CorpsTrainingSystem.TodayRankList, rankItem)
        if CorpsTrainingSystem.IsNeedReqRoleInfo(k) then
          table.insert(uidList, k)
          CorpsTrainingSystem.RecordRoleInfoReq(k)
        end
      end
    end
    table.sort(CorpsTrainingSystem.TodayRankList, function(a, b)
      return a.score > b.score or a.score == b.score and a.time < b.time
    end)
    if 0 < #uidList then
      CorpsTrainingSystem.GetRankRoleProfile(uidList)
    end
  end
  CorpsTrainingSystem.CheckRedPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GOAL_TRAINING_UPDATE_INFO)
  if CorpsTrainingSystem.reqTrainInfoCallBack ~= nil then
    CorpsTrainingSystem.reqTrainInfoCallBack()
  end
end
function CorpsTrainingSystem.get_corps_task_res(ret, task)
  if ret ~= "ok" then
    ShowNotice(ret)
    return
  end
  for k, v in pairs(task.task_list) do
    local cfg = CDataTable.GetTableData("CorpsTask", k)
    if cfg and cfg.TaskType == 4 then
      CorpsTrainingSystem.TeamTaskProgress = v.progress
      CorpsTrainingSystem.TeamTaskStatus = v.status
      CorpsTrainingSystem.TeamTraining = cfg
    end
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_UPDATE_INFO)
end
function CorpsTrainingSystem.GetRankRoleProfile(uidList)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, CorpsTrainingSystem.on_get_role_info_rsp, Enum_PROFILE_REPORT_CFG.CORPS_TRAIN, 0, true)
end
function CorpsTrainingSystem.on_get_role_info_rsp(profileList)
  for _, v in pairs(profileList) do
    CorpsTrainingSystem.TrainRoleInfo[tostring(v.uid)] = CorpsTrainingSystem.GenRoleInfoData(v)
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_ROLE_INFO)
end
function CorpsTrainingSystem.sync_corps_trainning_red_point(status, award_list)
  log(bWriteLog and "CorpsTrainingSystem.sync_corps_trainning_red_point status=" .. tostring(status))
  CorpsTrainingSystem.TrainRedPointIsShow = status == 1
  log_tree("sync_corps_trainning_red_point", award_list)
  CorpsTrainingSystem.  local all_DropId = {}
  for id, award in pairs(award_list) do
    if award.drop_id and award.drop_id > 0 then
      table.insert(all_DropId, award.drop_id)
    end
  end
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  BasicDataDropTable:BatchGetOrReqData(all_DropId)
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.UpdateRedPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS)
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_training_req()
end
function CorpsTrainingSystem.NextDay()
  log(bWriteLog and "CorpsTrainingSystem.NextDay")
  CorpsTrainingSystem.TrainRedPointIsShow = false
  local CorpsRedPointData = require("client.slua.logic.corps.corps_reddot_data")
  CorpsRedPointData.UpdateRedDot(CorpsRedPointData.reddot_id.corps_training)
end
function CorpsTrainingSystem.GetAllAwards()
  local awards = {}
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  local drop_id_list = {}
  if CorpsTrainingSystem.award_list then
    for _, award in pairs(CorpsTrainingSystem.award_list) do
      if award.drop_id and award.drop_id > 0 then
        table.insert(drop_id_list, award.drop_id)
      elseif award.ids then
        for _, v in ipairs(award.ids) do
          table.insert(awards, reddotUtil.CreateItem(v.res_id, v.num))
        end
      end
    end
  end
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  local dataList = BasicDataDropTable:BatchGetOrReqData(drop_id_list)
  if not dataList then
    return nil
  end
  for k, chestList in pairs(dataList) do
    for kk, vv in pairs(chestList) do
      table.insert(awards, reddotUtil.CreateItem(vv.DropItemID, vv.DropItemNum))
    end
  end
  if not next(awards) then
    return nil
  end
  return awards
end
function CorpsTrainingSystem.CheckRedPoint()
  if CorpsTrainingSystem.TodaySelfStatus == CorpsTrainingSystem.ETodaySelfStatus.Finished then
    return
  end
  for i, v in pairs(CorpsTrainingSystem.TodayCorpsTaskList) do
    if v.status == CorpsTrainingSystem.ETodaySelfStatus.Finished then
    end
  end
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.UpdateRedPoint()
end
function CorpsTrainingSystem.UpdateSelfAwardData()
  log_tree("CorpsTrainingSystem.TodaySelfAwards = ", CorpsTrainingSystem.TodaySelfAwards)
  for _, v in ipairs(CorpsTrainingSystem.TodaySelfAwards) do
    local logic_corps = require("client.slua.logic.corps.logic_corps")
    if v.res_id == 1008 and not logic_corps.IsNewCorpsEnabled() then
      v.res_id = 1204
    end
  end
  log_tree("CorpsTrainingSystem.TodaySelfAwards = ", CorpsTrainingSystem.TodaySelfAwards)
end
function CorpsTrainingSystem.UpdateCorpsTrainTaskData()
  local corps_max_score = 0
  local progress = {
    {len = 0, count = 0},
    {len = 112, count = 1},
    {len = 118, count = 1},
    {len = 118, count = 1}
  }
  for i, v in ipairs(CorpsTrainingSystem.TodayCorpsTaskList) do
    if progress[i + 1] then
      progress[i + 1].count = v.target
    end
    if corps_max_score < v.target then
      corps_max_score = v.target
    end
  end
  log_tree("CorpsTrainingSystem.TodayCorpsTaskList = ", CorpsTrainingSystem.TodayCorpsTaskList)
  local UIUtil = require("client.common.ui_util")
  CorpsTrainingSystem.nProgress = UIUtil.GetProgress(progress, CorpsTrainingSystem.TodayCorpsScore, corps_max_score)
end
function CorpsTrainingSystem.UpdateRankData()
  CorpsTrainingSystem.tRankItemInfoSelf = {
    no = 0,
    score = 0,
    itemType = 2,
    city = "",
    uid = tostring(DataMgr.roleData.uid),
    name = DataMgr.roleData.nickName,
    url = DataMgr.roleData.headIconUrl,
    level = DataMgr.roleData.level,
    gender = DataMgr.roleData.gender,
    cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id,
    startup_type = BP_StartUpType,
    bgbg_vip = DataMgr.roleData.bgbg_vip
  }
  for i, v in ipairs(CorpsTrainingSystem.TodayRankList) do
    v.no = i
    if tostring(v.uid) == tostring(DataMgr.roleData.uid) then
      v.itemType = 1
      CorpsTrainingSystem.tRankItemInfoSelf.no = i
      CorpsTrainingSystem.tRankItemInfoSelf.score = v.score
    end
    CorpsTrainingSystem.UpdateItemRoleInfo(v, v.uid)
  end
  log_tree("CorpsTrainingSystem.TodayRankList = ", CorpsTrainingSystem.TodayRankList)
  BP_Train_isReLoadRankList = true
end
function CorpsTrainingSystem.UpdateItemRoleInfo(itm, uid)
  local roleInfo = CorpsTrainingSystem.GetTrainRoleInfo(uid)
  if not roleInfo then
    return
  end
  itm.name = roleInfo.name
  itm.url = roleInfo.url
  itm.level = roleInfo.level
  itm.city = roleInfo.city
  itm.gender = roleInfo.gender
  itm.cur_avatar_box_id = roleInfo.cur_avatar_box_id
  itm.startup_type = roleInfo.startup_type
  itm.bgbg_vip = roleInfo.bgbg_vip
end
function CorpsTrainingSystem.OpenRoleInfo(nUid)
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(nUid, true)
end
function CorpsTrainingSystem.AddFriend(nUid)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:add_inner_friend_req(nUid, "", BP_ENUM_ADD_FRIEND_FROM_CORPS)
end
function CorpsTrainingSystem.Chat(nUid)
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.CloseCorps()
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.OpenChatMainByFriendId(nUid)
end
return CorpsTrainingSystem
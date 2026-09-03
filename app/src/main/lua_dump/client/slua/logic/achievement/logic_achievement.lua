local logic_achievement = {
  TotalUpdate = false,
  bInitData = false,
  bReqData = false,
  Enum_AchievementType = {
    Normal = 0,
    Extinct = 1,
    Hidden = 2
  }
}
local NetDataAwardAndPublishRegionOpen
local TimeUtil = require("client.common.time_util")
local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
local achievement_newflag_helper = require("client.slua.logic.achievement.achievement_newflag_helper")
local AchieveHandler = require("client.network.Protocol.AchieveHandler")
local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
function logic_achievement.Init()
end
function logic_achievement.ClearCache()
  log(bWriteLog and "[mxiliu]: ClearCache")
  logic_achievement.bInitData = false
  logic_achievement.bReqData = false
  NetDataAwardAndPublishRegionOpen = nil
end
function logic_achievement.__Init()
  achievement_cfg_helper.Init()
  logic_achievement.PKMap = {}
end
function logic_achievement.OnLogin()
  log(bWriteLog and "[qintong] logic_achievement.OnLogin")
  achievement_cfg_tool.ResetCache()
end
function logic_achievement.OnModePostSwitch()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if logic_achievement.TotalUpdate then
    AchieveHandler.send_get_achievement_summary_req(DataMgr.roleData.uid)
    AchieveHandler.send_get_achieve_rewards_list_req()
    AchieveHandler.send_get_achievement_data_req()
    AchieveHandler.send_get_achieve_record_rewards_list_req()
    logic_achievement.TotalUpdate = false
  end
  log(bWriteLog and "[qintong] logic_achievement.OnModePostSwitch")
  if not logic_achievement.bInitData then
    logic_achievement.__Init()
    logic_achievement.bInitData = true
  end
end
function logic_achievement.ReqData()
  if logic_achievement.bReqData then
    return
  end
  local p = require("common.Promise").new()
  printf("logic_achievement.ReqData start")
  local count = 7
  local stepCounter = function()
    count = count - 1
    if count == 0 then
      printf("logic_achievement.ReqData end")
      p:Resolve()
    end
  end
  AchieveHandler.send_get_achieve_rewards_list_req():Then(stepCounter)
  AchieveHandler.send_get_achieve_extinct_req():Then(stepCounter)
  AchieveHandler.send_get_achievement_data_req():Then(stepCounter)
  AchieveHandler.send_get_achievement_summary_req(DataMgr.roleData.uid):Then(stepCounter)
  AchieveHandler.send_get_achieve_record_rewards_list_req():Then(stepCounter)
  AchieveHandler.send_get_achieve_hit_list_req():Then(stepCounter)
  if NetDataAwardAndPublishRegionOpen then
    stepCounter()
  else
    logic_achievement.ReqNetDataAward():Then(stepCounter)
  end
  logic_achievement.bReqData = true
  return p
end
function logic_achievement.ReturnToLobbySendMsg(result)
  if result and result.achieve and next(result.achieve) then
    logic_achievement.TotalUpdate = true
  end
end
function logic_achievement.SavePKInfo(client_data, ok, rank_info)
  log_tree("[qintong] SavePKInfo " .. client_data .. " ok=" .. tostring(ok), rank_info)
  if client_data ~= "AchievementPK" then
    return
  end
  if ok ~= 0 then
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankInfoSelfBelow1wDisplay
  local uid = RankHandler.SendUID
  if not logic_achievement.PKMap then
    logic_achievement.PKMap = {}
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  if rank_info and next(rank_info) and RankDataMgr.FilterDifferentPlatforms(uid) then
    if rank_info.rank_no and rank_info.rank_no <= 10000 then
      RankInfoSelfBelow1wDisplay = rank_info.rank_no
    else
      RankInfoSelfBelow1wDisplay = logic_achievement.GetDisplayTextForTop1w(rank_info)
    end
  else
    RankInfoSelfBelow1wDisplay = LocUtil.GetLocalizeResStr(102127)
  end
  if uid then
    logic_achievement.PKMap[tonumber(uid)] = {rank_info = rank_info, RankInfoSelfBelow1wDisplay = RankInfoSelfBelow1wDisplay}
  end
  EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT_NEW, EVENTID_ACHIEVEMENT_RANK_INFO_UPDATE)
  log_shipping_client("[qintong] logic_achievement.SavePKInfo" .. tostring(RankInfoSelfBelow1wDisplay) .. "SendUID =" .. tostring(RankHandler.SendUID))
  for k, v in pairs(rank_info or {}) do
    log_shipping_client("[qintong] logic_achievement.SavePKInfo  k=" .. tostring(k) .. " v=" .. tostring(v))
  end
end
function logic_achievement.GetDisplayTextForTop1w(rank_info)
  local rank_no = rank_info.rank_no or 0
  local RankInfoSelfBelow1wDisplay
  if rank_info.top1w then
    local score
    if tostring(rank_info.uid) == tostring(DataMgr.roleData.uid) then
      score = AchieveHandler.GetMyAchieveScore()
    else
      score = rank_info.score
    end
    local rank_util = require("client.slua.logic.rank.rank_util")
    RankInfoSelfBelow1wDisplay = rank_util.calc_topn_percentage(score, rank_info.top1w, "achievement", rank_no)
  else
    RankInfoSelfBelow1wDisplay = LocUtil.GetLocalizeResStr(102127)
  end
  return RankInfoSelfBelow1wDisplay
end
function logic_achievement.DeleteShowAchivement(index)
  local myAchInfo = AchieveHandler.GetMyAchieveInfo()
  local show = myAchInfo.show
  show[index] = 0
  AchieveHandler.send_set_achievement_show_req(show)
end
function logic_achievement.CanGetScoreReward()
  local resRecordRewardsList = AchieveHandler.resRecordRewardsList
  if resRecordRewardsList == nil then
    return false
  end
  local myScore = AchieveHandler.GetMyAchieveScore()
  local cfgDataList = achievement_cfg_helper.Load_AchievementScoreCfg()
  if cfgDataList == nil then
    return false
  end
  for k, v in pairs(cfgDataList) do
    if myScore >= v.Score and resRecordRewardsList[k] == nil then
      return true
    end
  end
  return false
end
function logic_achievement.ReqNetDataAward()
  log(bWriteLog and "[mxiliu] logic_achievement:ReqNetDataAward start")
  if NetDataAwardAndPublishRegionOpen then
    return
  end
  local p = require("common.Promise").new()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.achievement_award_for_client, function(key, value)
    logic_achievement.SetAwardAndPublishRegionOpen(key, value)
    p:Resolve()
  end)
  return p
end
function logic_achievement.SetAwardAndPublishRegionOpen(_, data)
  if data then
    NetDataAwardAndPublishRegionOpen = data
    local achievement_red = require("client.logic.achievement.achievement_red")
    achievement_red.InitAchieveRedDot()
    EventSystem:postEvent(EVENTTYPE_ACHIEVEMENT, EVENTID_ACHIEVEMENT_NETREGION_DATA)
  end
end
function logic_achievement.GetIsClientShowByNetDataAward(AchId)
  if not NetDataAwardAndPublishRegionOpen then
    return false
  end
  local AchCfg = NetDataAwardAndPublishRegionOpen[AchId]
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bToShow
  if not AchCfg then
    log_error(bWriteLog and "[mxiliu] logic_achievement:GetIsClientShowByNetDataAward AchCfg no have AchId:" .. AchId)
    return true
  end
  if PublishRegionMacros.IsBLUEHOLE() then
    bToShow = AchCfg.bh_open ~= 0
  elseif PublishRegionMacros.IsJapanOrKorea() then
    bToShow = AchCfg.krjp_open ~= 0
  else
    bToShow = AchCfg.world_open ~= 0
  end
  return bToShow
end
function logic_achievement.GetIsClientShowWithCfg(AchId, AchCfg)
  AchCfg = AchCfg or CDataTable.GetTableData("AchievementCfg", AchId)
  local now = TimeUtil.GetServerTimeInSec()
  local bToShow = true
  if AchCfg and AchCfg.ClientShowTime and AchCfg.ClientShowTime ~= "" then
    local showTime = TimeUtil.TimeStringToUnixstamp(AchCfg.ClientShowTime)
    if now < showTime then
      return false
    end
  end
  bToShow = logic_achievement.GetIsClientShowByNetDataAward(AchId)
  return bToShow
end
function logic_achievement.OpenAchieveDetailUI(id)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil then
    return
  end
  if cfg.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_MULTI_LV or cfg.ShowType == BP_ENUM_ACHIEVEMENT_SHOW_TYPE_RANK then
    UIManager.ShowUI(UIManager.UI_Config.Achievement_Detail_1_UIBP, id)
  else
    UIManager.ShowUI(UIManager.UI_Config.Achievement_Detail_2_UIBP, id)
  end
end
function logic_achievement.OpenShareUI(id)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil then
    return
  end
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    sceneType = 2,
    isOld = true,
    campaign = "achievement",
    share_type = ShareBtnTLogShareTypeDefine.AchievementSystem,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      achievementId = id
    })
  }
  if AchieveHandler.resGetedAchieveRewardList then
    local getTime = AchieveHandler.resGetedAchieveRewardList[id]
    Util.ShowShare(shareCfg, UIManager.UI_Config.Achievement_Share, cfg.Name, cfg.Name, cfg.GroupID, cfg.MultiLvGroupNum, cfg.BigImgUrl, TimeUtil.FormatTime_YMD(getTime), cfg.AchType, cfg.ShareContions, cfg.PickupRate, cfg.Conditions)
    local ShareMgr = require("client.logic.share.share_logic")
    ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.AchievementSystem, nil, nil)
  end
end
function logic_achievement.JumpUrl()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local index = RoleInfoMainSystem.Honor
  local openFrom = RoleInfoMainSystem.RoleInfoOpenFromType.Lobby
  local uid = DataMgr.roleData.uid
  RoleInfoMainSystem.Show(index, openFrom, uid)
end
function logic_achievement.CheckMenuOpen(id)
  return LobbySystem.CheckOpen(id)
end
function logic_achievement.GetOneAchiveProgressDesc(id, desMap)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil then
    return ""
  end
  local conditionList = achievement_cfg_tool.ParserCondition(cfg.Conditions)
  local ProgressDescList = achievement_cfg_tool.GetAchievementProgressDesc(cfg.Conditions)
  if conditionList == nil or #conditionList <= 0 then
    return ""
  end
  desMap[conditionList[1].Param2TypeID] = ProgressDescList[1]
end
function logic_achievement.GetProgressText(AchievementID)
  local cfg = CDataTable.GetTableData("AchievementCfg", AchievementID)
  if cfg == nil then
    return ""
  end
  local idList
  local groupIdListMap = achievement_cfg_helper.CreatedMultiLvGroupIdAchiveMap()
  local groupIdList = groupIdListMap[cfg.GroupID][cfg.MultiLvGroupID]
  if groupIdList == nil then
    idList = {AchievementID}
  else
    idList = groupIdList
  end
  local desMap = {}
  for k, v in pairs(idList) do
    logic_achievement.GetOneAchiveProgressDesc(v, desMap)
  end
  local des = ""
  for k, v in pairs(desMap) do
    des = des .. v .. "      "
  end
  local slen = string.len(des)
  if 0 < slen then
    des = string.sub(des, 1, slen - 6)
  end
  return des
end
function logic_achievement.GetOutDateSec(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local id = idList[1]
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil or cfg.AchType ~= 1 or cfg.OutPrintTime == "" then
    return nil
  end
  local outdateSec = TimeUtil.TimeStringToUnixstamp(cfg.OutPrintTime)
  if outdateSec == 0 then
    return nil
  end
  local tNow = TimeUtil.GetServerTimeInSec()
  return outdateSec - tNow
end
function logic_achievement.GetMultiLvGroupCanGetRewardId(idList)
  local finishTimeStamp = -1
  for k, v in ipairs(idList) do
    local bGeted = AchieveHandler.IsGetAchRewardByID(v)
    local bCanGet, CurFinishTimeStamp = AchieveHandler.CheckAchiveCanFinishWithCfg(v)
    if finishTimeStamp < CurFinishTimeStamp then
      finishTimeStamp = CurFinishTimeStamp
    end
    if bGeted == false and bCanGet == true then
      log(bWriteLog and "logic_achievement:GetMultiLvGroupCanGetRewardId. Found claimable achievement id:" .. tostring(v) .. " timestamp:" .. tostring(finishTimeStamp))
      return v, bCanGet, finishTimeStamp
    end
  end
  log(bWriteLog and "logic_achievement:GetMultiLvGroupCanGetRewardId. No claimable achievement found, final timestamp:" .. tostring(finishTimeStamp))
  return nil, false, finishTimeStamp
end
function logic_achievement.GetMultiLvGroupIsNew(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local id = idList[1]
  return achievement_newflag_helper.GetIsNewWithCfg(id)
end
function logic_achievement.GetMultiLvGroupsShowId(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local GetAwardId = logic_achievement.GetMultiLvGroupCanGetRewardId(idList)
  if GetAwardId then
    return GetAwardId
  else
    local FinishID = -1
    for _, AchID in ipairs(idList) do
      local bGetAward = AchieveHandler.IsGetAchRewardByID(AchID)
      if bGetAward and AchID > FinishID then
        FinishID = AchID
      end
    end
    if 0 < FinishID then
      for _, AchID in ipairs(idList) do
        local bGetAward = AchieveHandler.IsGetAchRewardByID(AchID)
        if not bGetAward and AchID > FinishID then
          return AchID
        end
      end
      return FinishID
    else
      return idList[1]
    end
  end
end
function logic_achievement.GetMultiLvGroupsSortShowId(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local GetAwardId = logic_achievement.GetMultiLvGroupCanGetRewardId(idList)
  if GetAwardId then
    return GetAwardId
  else
    local FinishID = -1
    for _, AchID in ipairs(idList) do
      local bGetAward = AchieveHandler.IsGetAchRewardByID(AchID)
      if bGetAward and AchID > FinishID then
        FinishID = AchID
      end
    end
    if 0 < FinishID then
      return FinishID
    else
      return idList[1]
    end
  end
end
function logic_achievement.GetMultiLvGroupsShowIds(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local ShowId = idList[1]
  local Sort  local GetAwardId, canGet, finishTimeStamp = logic_achievement.GetMultiLvGroupCanGetRewardId(idList)
  if GetAwardId then
    return GetAwardId, GetAwardId, canGet, finishTimeStamp
  else
    local FinishID = -1
    local IDsNotGet = {}
    for _, AchID in ipairs(idList) do
      local bGetAward = AchieveHandler.IsGetAchRewardByID(AchID)
      if bGetAward then
        if AchID > FinishID then
          FinishID = AchID
        end
      else
        table.insert(IDsNotGet, AchID)
      end
    end
    if 0 < FinishID then
      for _, AchID in ipairs(IDsNotGet) do
        if AchID > FinishID then
          ShowId = AchID
          SortShowId = FinishID
          return ShowId, SortShowId, false, finishTimeStamp
        end
      end
      ShowId = FinishID
      SortShowId = FinishID
      return ShowId, SortShowId, false, finishTimeStamp
    end
    return ShowId, SortShowId, false, finishTimeStamp
  end
end
function logic_achievement.GetMultiLvGroupsAllNotFinish(idList)
  if idList == nil or #idList <= 0 then
    return nil
  end
  local AllNotFinish = true
  for _, AchID in ipairs(idList) do
    local bProgressFinish = AchieveHandler.CheckAchiveCanFinishWithCfg(AchID)
    if bProgressFinish then
      AllNotFinish = false
      break
    end
  end
  return AllNotFinish
end
function logic_achievement.IsRankConditions(AchID, cfg)
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", AchID)
  end
  local conditionList = achievement_cfg_tool.ParserCondition(cfg.Conditions)
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  for i, info in ipairs(conditionList) do
    if logic_achievement.IsRankConditionByConditionID(info.ConditionID) then
      return true
    end
  end
  return false
end
function logic_achievement.IsRankConditionByConditionID(conditionID)
  return conditionID == 37 or conditionID == 204 or conditionID == 702
end
function logic_achievement.MakeSingleDetailData(id)
  local ret = {}
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg then
    ret.id = cfg.ID
    ret.img_url = cfg.ImgUrl
    ret.big_img_url = cfg.BigImgUrl
    ret.des = cfg.Desc
    ret.title = cfg.Name
    local time = AchieveHandler.resGetedAchieveRewardList and AchieveHandler.resGetedAchieveRewardList[id] or 0
    ret.finish_time = TimeUtil.FormatTime_YMD(time)
    ret.award_id = cfg.AwardID
    ret.award_num = cfg.AwardNum
    ret.award2_id = cfg.AwardID2
    ret.award2_num = cfg.AwardNum2
    ret.group_id = cfg.GroupID
    local achievement_cfg_tool = require("client.slua.logic.achievement.achievement_cfg_tool")
    local info = achievement_cfg_tool.GetAchiveInfo(id)
    ret.cur_process = FuncUtil.FloatToShow(info.proc, 1)
    ret.total_process = info.total
    ret.param_des = info.des
    ret.score = cfg.Score
    ret.share_flag = 0 < cfg.ShareFlag and true or false
    ret.group_title = cfg.MultiLvGroupTitle
    ret.group_num = cfg.MultiLvGroupNum
    ret.version = cfg.Version
  end
  return ret
end
function logic_achievement.FromChatShareAchievement(id, groupId)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg then
    local bGet = AchieveHandler.IsGetAchRewardByID(id)
    local bFinish = AchieveHandler.CheckAchiveCanFinishWithCfg(id, cfg)
    local bOut = AchieveHandler.IsExtinctByID(id)
    local bSkip = false
    if cfg.AchType == 1 then
      if bOut and not bFinish then
        bSkip = true
      end
    elseif cfg.AchType ~= 2 or bGet or bFinish then
    else
      bSkip = true
      goto lbl_38
    end
    ::lbl_38::
    if bSkip then
      ShowNotice(LocUtil.GetLocalizeResStr(19256))
    else
      logic_achievement.OpenAchieveDetailUI(id)
    end
  end
end
function logic_achievement.HasRedpoint()
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  return roleinfo_red_data.GetSuperData().achievementRed
end
function logic_achievement.GetAward(AchID)
  if NetDataAwardAndPublishRegionOpen and NetDataAwardAndPublishRegionOpen[AchID] then
    return true, NetDataAwardAndPublishRegionOpen[AchID].item1_id, NetDataAwardAndPublishRegionOpen[AchID].item1_count, NetDataAwardAndPublishRegionOpen[AchID].item2_id, NetDataAwardAndPublishRegionOpen[AchID].item2_count
  end
  return false
end
function logic_achievement:AchievementSpecialHandler(tp, CfgInfoID, Dec)
  local achievement_macro = require("client.slua.logic.achievement.achievement_macro")
  local table = achievement_macro.AchievementSeqCfg_SpecialHandler
  if not CfgInfoID or not table[CfgInfoID] then
    return Dec
  end
  local number = table[CfgInfoID]
  local texts = CDataTable.GetTableData("AchievementCondCfg", number.textNumber)
  if not texts or not texts.Desc then
    return Dec
  end
  local result = LocUtil.GeneralFormat(texts.Desc, tp)
  return result
end
return logic_achievement
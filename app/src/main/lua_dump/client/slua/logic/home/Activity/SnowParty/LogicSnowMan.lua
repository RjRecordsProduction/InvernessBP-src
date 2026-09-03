local LogicSnowMan = {}
local SnowPartyConst = require("client.slua.logic.home.Activity.SnowParty.SnowPartyConst")
function LogicSnowMan:DefineAndResetData()
  log(bWriteLog and "LogicSnowMan:DefineAndResetData")
  self.snowShopTable = {}
  self.snowShopItemCfg = {}
  self.snowManCfg = {}
  self.snowManData = {}
  self.snowManRankData = {}
  self.selfSnowManRankData = {}
  self.snowManRankRewards = {}
  self.assistSnowManData = {}
  self.snowManActors = {}
end
function LogicSnowMan:OnInitialize()
  self:InitSnowManData()
  self:InitSnowManCfg()
  if Client then
    self:RequestManorSnowShopTable()
    self:InitShopItemCfg()
    self:InitSnowManRankRewardsData()
  end
end
function LogicSnowMan:OnPreSwitchGameStatus()
  self.snowManActors = {}
end
function LogicSnowMan:RegistEvents()
  if Client then
    self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON, self.HandleActivityRewardGetEvent, self)
  end
end
function LogicSnowMan:GetSnowShopCfg()
  if not next(self.snowShopTable) then
    self:RequestManorSnowShopTable()
  end
  return self.snowShopTable
end
function LogicSnowMan:GetItemCfg(itemID)
  return self.snowShopItemCfg[itemID]
end
function LogicSnowMan:GetSnowManCfg(showLevel)
  return self.snowManCfg[showLevel]
end
function LogicSnowMan:ProcessSnowManDataUpdate(homeIndex, snowManData)
  log(bWriteLog and "LogicSnowMan:ProcessSnowManDataUpdate homeIndex=" .. tostring(homeIndex))
  log_tree("LogicSnowMan:ProcessSnowManDataUpdate snowManData=", snowManData)
  if not homeIndex or not snowManData then
    return
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsEditHomeIndex(homeIndex) then
    homeIndex = PlanPH_GamePlay_Tools.GetVisitHomeIndex(homeIndex)
  end
  for key, value in pairs(snowManData) do
    self.snowManData[homeIndex][key] = value
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_DATA_UPDATE, homeIndex)
  if not Client then
    local PlanPHNetTool = require("GameLua.Mod.PlanPH.DS.PlanPHNetTool")
    PlanPHNetTool.BroadcastMsgByHomeIndex("PlanPH.snowman_data_update_notify", self.snowManData[homeIndex], homeIndex)
  end
end
function LogicSnowMan:GetSnowManData(homeIndex)
  if not homeIndex then
    if Client then
      local PlanPH_HomeArea_Manager = require("GameLua.Mod.PlanPH.Gameplay.HomeArea.PlanPH_HomeArea_Manager")
      local curHomeIndex = PlanPH_HomeArea_Manager.curHomeIndex
      return self.snowManData[curHomeIndex]
    end
    return nil
  end
  return self.snowManData[homeIndex]
end
function LogicSnowMan:GetAssistSnowManData(bSelf, forceUpdate)
  if not self.assistSnowManData[bSelf] or forceUpdate then
    self:RequestMakeSnowManRecords(bSelf)
  end
  return self.assistSnowManData[bSelf]
end
function LogicSnowMan:OnAssistSnowManDataRsp(bSelf, records)
  log(bWriteLog and string.format("LogicSnowMan:OnAssistSnowManDataRsp bSelf=%s records=%s", tostring(bSelf), tostring(records)))
  if not bSelf or not records then
    log(bWriteLog and "LogicSnowMan:OnAssistSnowManDataRsp bSelf or records is nil")
    return
  end
  table.sort(records, function(a, b)
    return a.time > b.time
  end)
  self.assistSnowManData[bSelf] = records
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_ASSIST_DATA_UPDATE)
end
function LogicSnowMan:RequestSnowManRankData()
  self:RequestSnowManRankList()
  self:RequestSelfSnowManRank()
end
function LogicSnowMan:RequestSnowManRankList()
  log(bWriteLog and "LogicSnowMan:RequestSnowManRankList")
  local rankID = SnowPartyConst.snowManRankID
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, rankID, 1)
end
function LogicSnowMan:ProcSnowManRankRsp(res, rankID, randDataList)
  log(bWriteLog and string.format("LogicSnowMan:ProcSnowManRankRsp res=%s", tostring(res)))
  log_tree(bWriteLog and "LogicSnowMan:ProcSnowManRankRsp randDataList", randDataList)
  if res ~= 0 or not next(randDataList) then
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_RANK_UPDATE)
    return
  end
  self.snowManRankData = randDataList
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_RANK_UPDATE)
end
function LogicSnowMan:RequestSelfSnowManRank()
  log(bWriteLog and "LogicSnowMan:RequestSelfSnowManRank")
  local rankType = SnowPartyConst.snowManRankType
  local rankID = SnowPartyConst.snowManRankID
  local RankHandler = require("client.network.Protocol.RankHandler")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manorKeyId = logic_home_entry:GetManorKey()
  RankHandler.send_get_one_user_rank(rankType, 0, manorKeyId, rankID)
end
function LogicSnowMan:ProcSelfSnowManRankRsp(rankType, res, rankInfo)
  if rankType ~= SnowPartyConst.snowManRankType then
    return
  end
  log(bWriteLog and string.format("LogicSnowMan:ProcSelfSnowManRankRsp rankType=%s res=%s", tostring(rankType), tostring(res)))
  log_tree(bWriteLog and "LogicSnowMan:ProcSelfSnowManRankRsp selfRankInfo1=", rankInfo)
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_SELF_RANK_UPDATE)
    return
  end
  local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
  rank_data_converter.ConvertJointRankData(rankInfo)
  log_tree(bWriteLog and "LogicSnowMan:ProcSelfSnowManRankRsp selfRankInfo2=", rankInfo)
  local logicSnowParty = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSnowParty)
  local activityCfg = logicSnowParty:GetActivityCfg()
  local defaultScore = activityCfg.snowman_initial_height or 100
  if not rankInfo or not next(rankInfo) then
    log(bWriteLog and "LogicSnowMan:ProcSelfSnowManRankRsp selfRankInfo is nil, use default data..")
    self.selfSnowManRankData = {
      uid = tonumber(DataMgr.roleData.uid),
      rank_no = -1,
      score = defaultScore
    }
  else
    self.selfSnowManRankData = rankInfo
    self.selfSnowManRankData.uid = self.selfSnowManRankData.uid or tonumber(DataMgr.roleData.uid)
    self.selfSnowManRankData.rank_no = self.selfSnowManRankData.rank_no or -1
    self.selfSnowManRankData.score = self.selfSnowManRankData.score or defaultScore
  end
  log_tree(bWriteLog and "LogicSnowMan:ProcSelfSnowManRankRsp selfRankInfo3=", self.selfSnowManRankData)
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_SELF_RANK_UPDATE)
end
function LogicSnowMan:IsSnowManRankData(rankID)
  return rankID == SnowPartyConst.snowManRankID
end
function LogicSnowMan:GetSnowManRankData()
  return self.snowManRankData
end
function LogicSnowMan:GetSelfSnowManRankData()
  return self.selfSnowManRankData
end
function LogicSnowMan:GetSnowManRankRewardInfo(rank)
  local rankRewardDataList = {}
  if not rank or rank <= 0 then
    return rankRewardDataList
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  for _, v in pairs(self.snowManRankRewards) do
    if rank >= v.RankCeilling and rank <= v.RankFloor then
      for rewardIndex = 1, 3 do
        local rewardID = v["RewardItemID" .. rewardIndex]
        if not rewardID or rewardID == 0 then
          goto lbl_58
        end
        local rewardNum = v["RewardItemCnt" .. rewardIndex]
        local limitTime = RankDataMgr.GetRankRewardItemTime(v["RewardItemLimitType" .. rewardIndex], v["RewardItemTimeLimit" .. rewardIndex])
        table.insert(rankRewardDataList, {
          rewardID = rewardID,
          num = rewardNum,
                  })
      end
      break
    end
  end
  ::lbl_58::
  return rankRewardDataList
end
function LogicSnowMan:GetSnowManActor(homeIndex)
  if not homeIndex then
    return nil
  end
  if not self.snowManActors[homeIndex] then
    self:InitSnowManActors()
  end
  return self.snowManActors[homeIndex]
end
function LogicSnowMan:GetSnowManAwardState()
  if not Client then
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actID = self:GetSnowManActivityID()
  local actData = ActivityNewSystem.GetActivityByID(actID)
  log_tree("LogicSnowMan:GetSnowManAwardState actData=", actData)
  if not actData then
    return nil
  end
  return actData.List[1].Status
end
function LogicSnowMan:ReqGetSnowManAward()
  log(bWriteLog and "LogicSnowMan:ReqGetSnowManAward")
  if not Client then
    return
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if not PlanPH_GamePlay_Tools:IsManorOwner() and not PlanPH_GamePlay_Tools:IsLocalBoot() then
    log(bWriteLog and "LogicSnowMan:ReqGetSnowManAward not self owner")
    return
  end
  local rewardState = self:GetSnowManAwardState()
  log(bWriteLog and string.format("LogicSnowMan:ReqGetSnowManAward rewardState=%s", tostring(rewardState)))
  if rewardState ~= ActivityProgressStatus.Done then
    log(bWriteLog and "LogicSnowMan:ReqGetSnowManAward rewardState not done")
    return
  end
  local activityID = self:GetSnowManActivityID()
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(activityID, 1)
end
function LogicSnowMan:RequestManorSnowShopTable()
  log(bWriteLog and "LogicSnowMan:RequestManorSnowShopTable")
  local NetManager = require("client.network.comm.NetManager")
  if not NetManager.bConnected then
    log(bWriteLog and "LogicSnowMan:RequestManorSnowShopTable bConnected=false")
    return
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_snowman_shop_table, function(key, data)
    log_tree("LogicSnowMan:RequestManorSnowShopTable data=", data)
    self.snowShopTable = data
    for shopID, shopData in pairs(self.snowShopTable) do
      shopData.shop_id = shopID
    end
    log_tree("LogicSnowMan:RequestManorSnowShopTable self.snowShopTable=", self.snowShopTable)
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOW_SHOP_TABLE_GET)
  end)
end
function LogicSnowMan:InitShopItemCfg()
  self.snowShopItemCfg = CDataTable.GetTable("PHomeSnowParty_SnowShopCfg")
end
function LogicSnowMan:InitSnowManCfg()
  self.snowManCfg = CDataTable.GetTable("PHomeSnowParty_SnowManCfg")
end
function LogicSnowMan:InitSnowManRankRewardsData()
  self.snowManRankRewards = CDataTable.GetTableByFilter("RankRewardTable", "RankType", SnowPartyConst.snowManRankID)
end
function LogicSnowMan:InitSnowManData()
  local PlanPH_MultiHome_Config = require("GameLua.Mod.PlanPH.Gameplay.Config.PlanPH_MultiHome_Config")
  for i = 1, PlanPH_MultiHome_Config.C_MaxHomeCopy do
    self.snowManData[i] = {
      make_cnt = 0,
      height = 100,
      scale = 1,
      show_level = 1
    }
  end
end
function LogicSnowMan:InitSnowManActors()
  local snowManClass = "/Game/Library/Res/HomeLandRes/Snow350/BluePrints/Actor/BP_PlanPH_SnowMan.BP_PlanPH_SnowMan"
  local snowManActors = Game:GetActorsByClass(slua.loadClass(snowManClass))
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  for _, snowManActor in pairs(snowManActors) do
    local homeIndex = PlanPH_GamePlay_Tools.GetLandIDByLocation(snowManActor:K2_GetActorLocation())
    log(bWriteLog and string.format("LogicSnowMan:InitSnowManData homeIndex=%d snowManActor=%s", homeIndex, tostring(snowManActor)))
    self.snowManActors[homeIndex] = snowManActor
  end
end
function LogicSnowMan:RequestMakeSnowManRecords(bSelf)
  local PHomeSnowPartyHandler = require("client.network.Protocol.PHomeSnowPartyHandler")
  PHomeSnowPartyHandler.send_get_snowman_make_records_req(bSelf)
end
function LogicSnowMan:GetSnowManActivityID()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return SnowPartyConst.snowManAcitivityID_JK
  end
  return SnowPartyConst.snowManAcitivityID
end
function LogicSnowMan:HandleActivityRewardGetEvent(_, _, activityId)
  log(bWriteLog and string.format("LogicSnowMan:HandleActivityRewardGetEvent activityId=%d", activityId))
  if not activityId == self:GetSnowManActivityID() then
    return
  end
  log(bWriteLog and "LogicSnowMan:HandleActivityRewardGetEvent snow man reward get!")
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_SNOWPARTY_SNOWMAN_REWARD_GET)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, LogicSnowMan)
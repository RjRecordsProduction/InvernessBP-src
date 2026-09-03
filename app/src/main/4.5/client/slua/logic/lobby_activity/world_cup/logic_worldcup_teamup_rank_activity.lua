local logic_worldcup_teamup_rank_activity = {}
local ScrollBgPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/AirdropCarnival/AirdropCarnival_Tips_Bg_02.AirdropCarnival_Tips_Bg_02"
local IconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/AirdropCarnival/AirdropCarnival_Icon_Ball.AirdropCarnival_Icon_Ball"
function logic_worldcup_teamup_rank_activity:OnInitialize()
  logic_worldcup_teamup_rank_activity.__super.OnInitialize(self)
  self:InitData()
end
function logic_worldcup_teamup_rank_activity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WORLDCUP_SEGMENT_ACTIVITY, self.OnSegmentActivityJump, self)
end
function logic_worldcup_teamup_rank_activity:Destory()
  log(bWriteLog and "logic_worldcup_teamup_rank_activity Destory")
end
function logic_worldcup_teamup_rank_activity:GetActivityCfgToTypeList()
  return self.cfgToTypeList
end
function logic_worldcup_teamup_rank_activity:GetValidActivityCount()
  self.validActTypeList = {}
  local sortHelper = {
    17,
    16,
    18,
    19,
    20
  }
  local activityCfgToTypeList = self:GetActivityCfgToTypeList()
  local firstValidActCfgId
  local count = 0
  for _, cfgId in pairs(sortHelper) do
    local activityType = activityCfgToTypeList[cfgId]
    if activityType then
      local bShow, totalNum, progressNum = self:CheckAndGetActivityData(activityType)
      if bShow then
        local data = {
          protect_id = cfgId,
          totalNum = totalNum,
                  }
        table.insert(self.validActTypeList, data)
        count = count + 1
        firstValidActCfgId = firstValidActCfgId or cfgId
      end
    end
  end
  log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetValidActivityCount count:" .. tostring(count) .. " firstValidActCfgId:" .. tostring(firstValidActCfgId))
  return count, firstValidActCfgId
end
function logic_worldcup_teamup_rank_activity:GetValidTypeList()
  self:GetValidActivityCount()
  return self.validActTypeList or {}
end
function logic_worldcup_teamup_rank_activity:CheckAndGetActivityData(activityType)
  if not activityType then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:CheckAndGetAddRatingData activityType is nil")
    return false, nil, nil
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(activityType)
  if not (activityData and activityData.List) or not activityData.List[1] then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:CheckAndGetActivityData activity data is nil")
    return false, nil, nil
  end
  local startTime = activityData.StartTime
  local endTime = activityData.EndTime
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec() or 0
  if startTime == nil or endTime == nil or startTime > serverTime or endTime < serverTime then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity.CheckAndGetActivityData activity not in open time")
    return false, nil, nil
  end
  local dataList = activityData.List[1]
  local totalNum = dataList.Total or 0
  local progressNum
  if activityData.other and activityData.other.day_count then
    progressNum = activityData.other.day_count
  end
  if dataList.Status ~= ActivityProgressStatus.Not then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity.CheckAndGetActivityData activity has done")
    return false, nil, nil
  end
  if not progressNum or totalNum - progressNum <= 0 then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity.CheckAndGetActivityData activity no times")
    return false, nil, nil
  end
  return true, totalNum, progressNum
end
function logic_worldcup_teamup_rank_activity:GetActivityData(activityType)
  if not activityType then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetActivityData activityType is nil")
    return nil
  end
  if not self:IsOpen() then
    return nil
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(activityType)
  if not (activityData and activityData.List) or not activityData.List[1] then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetActivityData activity data is nil")
    return nil
  end
  return activityData
end
function logic_worldcup_teamup_rank_activity:GetProgressByType(activityType)
  if not activityType then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetProgressByType activityType is nil")
    return nil, nil
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(activityType)
  if not (activityData and activityData.List) or not activityData.List[1] then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetProgressByType activity data is nil")
    return nil, nil
  end
  local dataList = activityData.List[1]
  local totalNum = dataList.Total
  local progressNum
  if activityData.other and activityData.other.day_count then
    progressNum = activityData.other.day_count
  end
  log(bWriteLog and "logic_worldcup_teamup_rank_activity:GetProgressByType totalNum:" .. tostring(totalNum) .. " progressNum:" .. tostring(progressNum))
  return totalNum, progressNum
end
function logic_worldcup_teamup_rank_activity:IsOpen()
  local logic_airdrop_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_airdrop_entry)
  if not logic_airdrop_entry:IsInTime() then
    return false
  end
  local logic_airdrop_collection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_airdrop_collection)
  local actInfo = logic_airdrop_collection:GetActInfo(self.parentActivityId)
  if not actInfo then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:IsOpen not actInfo")
    logic_airdrop_collection:send_get_make_festival_activity_list_req()
    return false
  end
  log(bWriteLog and "logic_worldcup_teamup_rank_activity:IsOpen is_open:" .. tostring(actInfo.is_open))
  return actInfo.is_open or false
end
function logic_worldcup_teamup_rank_activity:CheckHasWorldCupRankActivity(typeList)
  if not typeList or not type(typeList) == "table" then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:CheckHasWorldCupRankActivity typeList is nil")
    return false
  end
  if not self:IsOpen() then
    return false
  end
  local activityCfgToTypeList = self:GetActivityCfgToTypeList()
  for _, activityType in pairs(activityCfgToTypeList) do
    if typeList[activityType] then
      log(bWriteLog and "logic_worldcup_teamup_rank_activity:CheckHasWorldCupRankActivity true")
      return true
    end
  end
  log(bWriteLog and "logic_worldcup_teamup_rank_activity:CheckHasWorldCupRankActivity false")
  return false
end
function logic_worldcup_teamup_rank_activity:OnSegmentActivityJump()
  log(bWriteLog and "logic_worldcup_teamup_rank_activity:OnSegmentActivityJump")
  local gameStatus = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:OnSegmentActivityJump not Lobby")
    return
  end
  if not self:IsOpen() then
    log(bWriteLog and "logic_worldcup_teamup_rank_activity:OnSegmentActivityJump not open")
    return
  end
end
function logic_worldcup_teamup_rank_activity:GoToActMainUI()
end
function logic_worldcup_teamup_rank_activity:CheckValidActTypeInAct()
  local isOpen = self:IsOpen()
  if not isOpen then
    return false
  end
  local actList = self:GetValidTypeList()
  return true, actList
end
function logic_worldcup_teamup_rank_activity:IsActScoreProtectFirst()
  log(bWriteLog and "logic_rating_protect_for_world_cup.IsActScoreProtectFirst_worldCup")
  local isShow, totalNum, progressNum = self:CheckAndGetActivityData(ActivityType.WORLDCUP_SCORE_PROTECT)
  if isShow and totalNum and progressNum and progressNum < totalNum then
    return true
  end
  return false
end
function logic_worldcup_teamup_rank_activity.GetSegmentEntranceIconInfo()
  return ScrollBgPath, IconPath
end
function logic_worldcup_teamup_rank_activity:InitData()
  log(bWriteLog and "LogicWorldCupTeamUpRank:InitData")
  local actType = ActivityType
  self.cfgToTypeList = {
    [16] = actType.WORLDCUP_SCORE_PROTECT,
    [17] = actType.WORLDCUP_TEAMUP_ADD_RATING,
    [18] = actType.WORLDCUP_DOUBLE_CHALLENGE,
    [19] = actType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY,
    [20] = actType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY
  }
  self.parentActivityId = 5
end
function logic_worldcup_teamup_rank_activity:ClearData()
  log(bWriteLog and "LogicWorldCupTeamUpRank:ClearData")
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_worldcup_teamup_rank_activity = class(CModuleBase, nil, logic_worldcup_teamup_rank_activity)
return Clogic_worldcup_teamup_rank_activity
local achievement_red = {
  ACHIEVE_AWARD = 1,
  ACHIEVE_SCORE = 2,
  ACHIEVE_NEW = 3,
  SCORE = 0,
  NewArrivals = 1,
  Receive = 2
}
local AchieveHandler = require("client.network.Protocol.AchieveHandler")
local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
local achievement_newflag_helper = require("client.slua.logic.achievement.achievement_newflag_helper")
local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
local SCORE = 0
local redData
local bInit = false
function achievement_red.OnLogin()
  log(bWriteLog and "achievement_red.OnLogin")
  achievement_red.CreateRedData()
end
function achievement_red.OnLogout()
  log(bWriteLog and "achievement_red.OnLogout")
  redData = nil
  bInit = false
end
local _CreateLeafData = function(subID, category)
  local data = {
    newCount = 0,
    subID = subID,
    category = category,
    instanceID = {_isLeaf = true}
  }
  return data
end
function achievement_red.CreateRedData()
  log(bWriteLog and "achievement_red.CreateRedData")
  if redData ~= nil then
    return
  end
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  if reddot_manager:IsRegist(reddot_macro.SystemName.Achievement) then
    return
  end
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.Achievement
  }
  for i = 1, 7 do
    data[i] = {
      newCount = 0,
      _CreateLeafData(achievement_red.ACHIEVE_NEW, reddot_macro.Category.NewArrivals),
      _CreateLeafData(achievement_red.ACHIEVE_AWARD, reddot_macro.Category.Receive)
    }
  end
  data[SCORE] = _CreateLeafData(achievement_red.ACHIEVE_SCORE, reddot_macro.Category.Receive)
  local super_data = require("common.super_data")
  redData = super_data.CreateSuperData(data)
  reddot_manager:Regist(redData)
end
function achievement_red.SetRed(GroupID, redType, achieveID)
  if redData == nil then
    return
  end
  local redData_type = redData[GroupID]
  if redData_type == nil then
    return
  end
  if GroupID == SCORE then
    if redData_type.instanceID[achieveID] == true then
      return
    end
    redData_type.instanceID[achieveID] = true
  else
    if redData_type[redType].instanceID[achieveID] == true then
      return
    end
    redData_type[redType].instanceID[achieveID] = true
  end
  log(bWriteLog and string.format("achievement_red.SetRed. GroupID=%s, redType=%s, achieveID=%s newCount=%s", tostring(GroupID), tostring(redType), tostring(achieveID), tostring(redData.newCount)))
end
function achievement_red.ClearRed(GroupID, redType, achieveID)
  if redData == nil then
    return
  end
  local redData_type = redData[GroupID]
  if redData_type == nil then
    return
  end
  if GroupID == SCORE then
    if redData_type.instanceID[achieveID] == nil then
      return
    end
    redData_type.instanceID[achieveID] = nil
  else
    if redData_type[redType].instanceID[achieveID] == nil then
      return
    end
    redData_type[redType].instanceID[achieveID] = nil
  end
  log(bWriteLog and string.format("achievement_red.ClearRed. GroupID=%s, redType=%s, achieveID=%s newCount=%s", tostring(GroupID), tostring(redType), tostring(achieveID), tostring(redData.newCount)))
end
function achievement_red.GetRedData()
  if not redData then
    achievement_red.CreateRedData()
  end
  return redData
end
function achievement_red.GetAchievTypeRedData(achieveType)
  if redData == nil then
    return nil
  end
  return redData[achieveType]
end
function achievement_red.UpdateScoreRedDot()
  local resRecordRewardsList = AchieveHandler.resRecordRewardsList
  if resRecordRewardsList == nil then
    return
  end
  local myScore = AchieveHandler.GetMyAchieveScore()
  local cfgDataList = achievement_cfg_helper.Load_AchievementScoreCfg()
  if cfgDataList == nil then
    return
  end
  for k, v in pairs(cfgDataList) do
    if myScore >= v.Score and resRecordRewardsList[k] == nil then
      achievement_red.SetRed(achievement_red.SCORE, achievement_red.Receive, v.ID)
    else
      achievement_red.ClearRed(achievement_red.SCORE, achievement_red.Receive, v.ID)
    end
  end
end
local _InnerUpdateAchieveRedDot = function(id, cfg)
  if achievement_cfg_helper.IsValidAchievementID(id, cfg) and logic_achievement.GetIsClientShowWithCfg(id, cfg) then
    local GroupID = cfg.GroupID
    local MultiLvGroupID = cfg.MultiLvGroupID ~= 0 and cfg.MultiLvGroupID or cfg.ID
    local bIsNew = achievement_newflag_helper.GetIsNewWithCfg(MultiLvGroupID)
    if bIsNew then
      achievement_red.SetRed(GroupID, achievement_red.NewArrivals, MultiLvGroupID)
    end
    local bGeted = AchieveHandler.IsGetAchRewardByID(id)
    local bCanGet = AchieveHandler.CheckAchiveCanFinishWithCfg(id, cfg)
    if bCanGet == true and bGeted == false then
      achievement_red.SetRed(GroupID, achievement_red.Receive, id)
    end
  end
end
function achievement_red.UpdateAchieveRedDotByList(idList)
  if not idList then
    return
  end
  log(bWriteLog and string.format("achievement_red.UpdateAchieveRedDotByList. #tb=%d", #idList))
  for _, id in pairs(idList) do
    local cfg = CDataTable.GetTableData("AchievementCfg", id)
    _InnerUpdateAchieveRedDot(id, cfg)
  end
end
function achievement_red.UpdateAchieveRedDotByAchID(AchID)
  log(bWriteLog and string.format("achievement_red.UpdateAchieveRedDotByAchID. AchID=%s", tostring(AchID)))
  local cfg = CDataTable.GetTableData("AchievementCfg", AchID)
  if achievement_cfg_helper.IsValidAchievementID(AchID, cfg) then
    local GroupID = cfg.GroupID
    local bGeted = AchieveHandler.IsGetAchRewardByID(AchID)
    local bCanGet = AchieveHandler.CheckAchiveCanFinishWithCfg(AchID, cfg)
    if bCanGet == true and bGeted == false then
      log_error(bWriteLog and string.format("achievement_red.UpdateAchieveRedDotByAchID. AchID=%s", tostring(AchID)))
    else
      achievement_red.ClearRed(GroupID, achievement_red.Receive, AchID)
    end
  end
end
function achievement_red.UpdateAchieveNewRedDotByAchID(AchID)
  log(bWriteLog and string.format("achievement_red.UpdateAchieveNewRedDotByAchID. AchID=%s", tostring(AchID)))
  local cfg = CDataTable.GetTableData("AchievementCfg", AchID)
  if achievement_cfg_helper.IsValidAchievementID(AchID, cfg) then
    local GroupID = cfg.GroupID
    achievement_red.ClearRed(GroupID, achievement_red.NewArrivals, AchID)
  end
end
function achievement_red.InitAchieveRedDot()
  if bInit then
    return
  end
  bInit = true
  log(bWriteLog and string.format("achievement_red.UpdateAchieveRedDot."))
  local AchievementCfg = CDataTable.GetTable("AchievementCfg")
  for _, cfg in pairs(AchievementCfg) do
    _InnerUpdateAchieveRedDot(cfg.ID, cfg)
  end
end
return achievement_red
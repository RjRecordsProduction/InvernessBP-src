local Logic_BonusPass = {}
local Enum_LevelUpType = {UnlockBranch = 1, LevelUp = 2}
local Enum_Core_Reward_Pos = {
  FirstPart = 1,
  SecondPart = 2,
  BothPath = 3
}
local specialLevel1 = 30
local specialLevel2 = 60
local reward_id = 1121
local numberPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI_0_16_5/Frames/RP_%d_png.RP_%d_png"
local numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI_0_16_5/Frames/RP_%d_normal_png.RP_%d_normal_png"
function Logic_BonusPass:DefineAndResetData()
  Logic_BonusPass.__super.DefineAndResetData(self)
  self.tSeasonCfg = nil
  self.tDailyTaskCfg = nil
  self.tWeekTaskCfg = nil
  self.tTaskGroupCfg = nil
  self.tLevelAwardData = nil
  self.tDailyTaskData = nil
  self.tWeekTaskData = nil
  self.tTaskProgress = nil
  self.tCoreRwardCfg = nil
  self.tFullLevelExtraRewardCfg = nil
  self.tActData = nil
  self.nTotalScore = 0
  self.bDelayShow = false
  self.tDelayPopData = nil
  self.tPreviewList = nil
  self.nCurSeasonID = nil
  self.nBeforeLevel = nil
  self.bUpdateLevel = true
  self.bIsBuyScore = false
  self.nCurTaskDays = nil
  self.nCurTaskWeeks = nil
  self.nCoreIndex = nil
  self.bShowUnlockUp = nil
  self.bIsHadBuyElite = nil
  self.nCurShowTaskType = -1
end
function Logic_BonusPass:OnInitialize()
  Logic_BonusPass.__super.OnInitialize(self)
end
function Logic_BonusPass:RegistEvents()
  Logic_BonusPass.__super.OnInitialize(self)
  self:AddCommonEvent(EVENTTYPE_STORE, EVENTID_STORE_CHEST_OPEN, self.OnOpenBonusPassChest, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnUpdateTaskData, self)
end
function Logic_BonusPass:OnLogin(bReLogin)
  Logic_BonusPass.__super.OnLogin(self, bReLogin)
end
function Logic_BonusPass:InitBonusPassConfig()
  if not self.nCurSeasonID or self.nCurSeasonID ~= UnknowPassSystem.Season then
    self:InitSeasonControlCfg()
    self:InitLevelAwardCfg()
    self:InitFullLevelExtraRewardCfg()
    self:InitDailyTaskCfg()
    self:InitWeekTaskCfg()
    self.nCurSeasonID = UnknowPassSystem.Season
  end
end
function Logic_BonusPass:OnOpenBonusPassChest(_, _, items)
  log(bWriteLog and "Logic_BonusPass:OnOpenBonusPassChest()")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local panelType = PassDataSystem.GetPanelType()
  local curType = PassDataSystem.GetCurRpPanelType()
  if curType == panelType.BranchRp then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  end
end
function Logic_BonusPass:OnUpdateTaskData()
  self:send_sync_rp_branch_task_data_req()
end
function Logic_BonusPass:InitSeasonControlCfg()
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tSeasonCfg = Logic_Bonus_ReadFrontCfg:GetBPSeasonControlCfg()
end
function Logic_BonusPass:InitLevelAwardCfg()
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tLevelAwardData = Logic_Bonus_ReadFrontCfg:GetBPLevelAwardCfg()
end
function Logic_BonusPass:InitFullLevelExtraRewardCfg()
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tFullLevelExtraRewardCfg = Logic_Bonus_ReadFrontCfg:GetBPFullLevelExtraRewardCfg()
end
function Logic_BonusPass:InitDailyTaskCfg()
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tDailyTaskCfg = Logic_Bonus_ReadFrontCfg:GetBPDailyTaskCfg()
end
function Logic_BonusPass:InitWeekTaskCfg()
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tWeekTaskCfg = Logic_Bonus_ReadFrontCfg:GetBPWeekTaskCfg()
end
function Logic_BonusPass:GetTaskCfgByIndexAndGroupID(taskGroupId)
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  local tTaskCfg = Logic_Bonus_ReadFrontCfg:GetBPTaskCfgByIndexAndGroupID(taskGroupId)
  return tTaskCfg
end
function Logic_BonusPass:GetTaskCfgByTaskIdandGroupID(taskId, taskGroupId)
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  local tTaskCfg = Logic_Bonus_ReadFrontCfg:GetBPTaskCfgByTaskIdandGroupID(taskId, taskGroupId)
  return tTaskCfg
end
function Logic_BonusPass:GetCoreRewardCfg()
  if self.tCoreRwardCfg and self.nCoreIndex and self.nCoreIndex == UnknowPassSystem.Season then
    return self.tCoreRwardCfg
  end
  local Logic_Bonus_ReadFrontCfg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Bonus_ReadFrontCfg)
  self.tCoreRwardCfg = Logic_Bonus_ReadFrontCfg:GetBPCoreRewardCfg()
  self.nCoreIndex = UnknowPassSystem.Season
  return self.tCoreRwardCfg
end
function Logic_BonusPass:send_rp_branch_player_data_req()
  if not self.tSeasonCfg then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local realStartTime = TimeUtil.TimeStringToUnixstamp(self.tSeasonCfg.realStartTime)
  local realEndTime = TimeUtil.TimeStringToUnixstamp(self.tSeasonCfg.endTime)
  local curTime = TimeUtil.GetServerTimeInSec()
  if realStartTime <= curTime and realEndTime >= curTime then
    local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
    UpassBranchHandler.send_rp_branch_player_data_req()
  end
end
function Logic_BonusPass:on_rp_branch_player_data_rsp(rp_branch)
  self.tActData = rp_branch
  self.nTotalScore = rp_branch.score
  self:UpdateLevelAwardState()
  if self.bShowUnlockUp then
    self.bShowUnlockUp = false
    self:OpenLevelUpPopup(Enum_LevelUpType.UnlockBranch)
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_INFO_UPDATE)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_BUY_BUTTON)
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.UpdateUnknowPassReddot(false)
end
function Logic_BonusPass:send_rp_branch_buy_score_req(diff_score)
  self.bIsBuyScore = true
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_rp_branch_buy_score_req(diff_score, self.nTotalScore)
end
function Logic_BonusPass:on_rp_branch_buy_score_rsp(diff_score, cur_score)
  if UIManager.GetUI(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
    local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
    UnknowPassAwardSystem.SwitchToBranchAwardPanel()
    self:send_rp_branch_player_data_req()
  end
end
function Logic_BonusPass:send_rp_branch_get_level_award_req(level, index)
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_rp_branch_get_level_award_req(level, index)
end
function Logic_BonusPass:on_rp_branch_get_level_award_rsp(level, items)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  self:send_rp_branch_player_data_req()
end
function Logic_BonusPass:send_rp_branch_batch_get_level_award_req()
  self:GetAllRewardMultiChooseOne()
end
function Logic_BonusPass:on_rp_branch_batch_get_level_award_rsp(items)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  self:send_rp_branch_player_data_req()
end
function Logic_BonusPass:send_sync_rp_branch_task_data_req()
  if not self.tSeasonCfg then
    return
  end
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_sync_rp_branch_task_data_req()
end
function Logic_BonusPass:on_sync_rp_branch_task_data_info(rp_branch_task, task_type)
  log_tree("on_sync_rp_branch_task_data_info:", rp_branch_task)
  if not rp_branch_task then
    return
  end
  if not self.tTaskProgress then
    if task_type == nil then
      self.tTaskProgress = rp_branch_task
    else
      self:send_sync_rp_branch_task_data_req()
      return
    end
  elseif task_type == 1 then
    self.tTaskProgress.daily = rp_branch_task
  elseif task_type == 2 then
    self.tTaskProgress.weekly = rp_branch_task
  else
    self.tTaskProgress = rp_branch_task
  end
  local taskData = self.tTaskProgress
  local day = taskData.daily.time_id
  local week = taskData.weekly.time_id
  if not (self.nCurTaskDays and self.nCurTaskWeeks) or self.nCurTaskDays ~= day or self.nCurTaskWeeks ~= week then
    self:UpdateDailyTaskData()
    self:UpdateWeekTaskData()
  end
  self:UpdateTaskList()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_UPDATE_TASK_INFO)
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.UpdateUnknowPassReddot(false)
end
function Logic_BonusPass:send_rp_branch_get_task_award_req(task_id, task_type)
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_rp_branch_get_task_award_req(task_id, task_type)
end
function Logic_BonusPass:on_rp_branch_get_task_award_rsp(task_id, task_data, reward_score, task_type)
  local rewards = {
    [1] = {
      resid = reward_id,
      count = reward_score,
      valid_hours = 0
    }
  }
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards)
  if task_type == 1 then
    local data = self.tTaskProgress.daily.tasks
    for id, v in pairs(data) do
      if id == task_id then
        v.status = task_data.status
        v.value = task_data.value
      end
    end
  elseif task_type == 2 then
    local data = self.tTaskProgress.weekly.tasks
    for id, v in pairs(data) do
      if id == task_id then
        v.status = task_data.status
        v.value = task_data.value
      end
    end
  end
  self:UpdateTaskList()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_UPDATE_TASK_INFO)
end
function Logic_BonusPass:send_rp_branch_batch_get_task_award_req()
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_rp_branch_batch_get_task_award_req()
end
function Logic_BonusPass:on_rp_branch_batch_get_task_award_rsp(reward_score)
  if reward_score == 0 then
    ShowNotice(100320001)
    return
  end
  local rewards = {
    [1] = {
      resid = reward_id,
      count = reward_score,
      valid_hours = 0
    }
  }
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards)
  self:send_sync_rp_branch_task_data_req()
end
function Logic_BonusPass:on_rp_branch_score_notify_change(diff_score, new_score)
  if not self:IsShowBranchTask() then
    return
  end
  if not self.bIsBuyScore and GameStatus.IsInLobbyOrMainCity() then
    ShowNotice(LocUtil.LocalizeResFormat(66973, diff_score))
    self.bIsBuyScore = false
  end
  if self.bUpdateLevel then
    self.nBeforeLevel = math.floor((new_score - diff_score) / self.tSeasonCfg.levelScore)
    self.bUpdateLevel = false
  end
  self.nTotalScore = new_score
  self:UpdateLevelAwardState()
  self:CheckIsShowLevelUp(self.nTotalScore, self.nBeforeLevel)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_INFO_UPDATE)
end
function Logic_BonusPass:on_rp_branch_get_special_reward_rsp(awards)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(awards)
  self:send_rp_branch_player_data_req()
end
function Logic_BonusPass:on_rp_branch_get_extra_chest_rsp(chest_id, item_list, decompose_list, score_idx)
  for _, v in pairs(score_idx) do
    table.insert(self.tActData.special_chest_records, v)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if decompose_list then
    Logic_CommonItemGet.ShowPanel_DecomposeStyle(item_list, decompose_list)
  else
    Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list, false, false)
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_INFO_UPDATE)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_BUY_BUTTON)
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.UpdateUnknowPassReddot(false)
end
function Logic_BonusPass:on_unknown_pass_type_rsp(pass_type)
  log(bWriteLog and "Logic_BonusPass:on_unknown_pass_type_rsp  " .. tostring(pass_type))
  if pass_type and 0 < pass_type then
    self.bIsHadBuyElite = true
  else
    self.bIsHadBuyElite = false
  end
  if self.bIsHadBuyElite ~= UnknowPassSystem.IsBuyElite then
    UnknowPassSystem.IsBuyElite = self.bIsHadBuyElite
    UnknowPassSystem.PassType = pass_type
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_BONUS_PASS_UPDATE_BUYPOPUP)
  end
end
function Logic_BonusPass:SetIsShowUnlockUp(bShowUnlockUp)
  self.end
function Logic_BonusPass:GetBranchSeasonData()
  return self.tSeasonCfg
end
function Logic_BonusPass:GetBranchLevelAward()
  return self.tLevelAwardData
end
function Logic_BonusPass:GetFullLevelExtraRewardCfg()
  if self.tFullLevelExtraRewardCfg then
    return self.tFullLevelExtraRewardCfg
  end
  return
end
function Logic_BonusPass:GetDailyTaskData()
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_TASK_TYPE = Logic_BonusPass_Const_Config.ENUM_BP_TASK_TYPE
  if not self.tDailyTaskData then
    return
  end
  if self.nCurShowTaskType == ENUM_BP_TASK_TYPE.AllTask then
    return self.tDailyTaskData
  end
  local tCurShowTaskData = {}
  for _, v in ipairs(self.tDailyTaskData) do
    if v.taskType == self.nCurShowTaskType then
      local index = #tCurShowTaskData + 1
      tCurShowTaskData[index] = v
    end
  end
  return tCurShowTaskData
end
function Logic_BonusPass:GetWeekTaskData()
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_TASK_TYPE = Logic_BonusPass_Const_Config.ENUM_BP_TASK_TYPE
  if not self.tWeekTaskData then
    return
  end
  if self.nCurShowTaskType == ENUM_BP_TASK_TYPE.AllTask then
    return self.tWeekTaskData
  end
  local tCurShowTaskData = {}
  for _, v in ipairs(self.tWeekTaskData) do
    if v.taskType == self.nCurShowTaskType then
      local index = #tCurShowTaskData + 1
      tCurShowTaskData[index] = v
    end
  end
  return tCurShowTaskData
end
function Logic_BonusPass:GetCurShowTaskType()
  return self.nCurShowTaskType
end
function Logic_BonusPass:SetCurShowTaskType(nCurShowTaskType)
  self.end
function Logic_BonusPass:Encode_task_id(task_id, time_id)
  if time_id & -256 ~= 0 then
    log(bWriteLog and "Logic_BonusPass:Encode_task_id task_id  " .. time_id)
    return
  end
  if task_id >> 56 ~= 0 then
    log(bWriteLog and "Logic_BonusPass:Encode_task_id time_id  " .. time_id)
    return
  end
  return time_id << 56 | task_id
end
function Logic_BonusPass:Decode_task_id(encode_id)
  if encode_id >> 56 == 0 then
    log(bWriteLog and "Logic_BonusPass:Decode_task_id: " .. encode_id)
    return
  end
  return encode_id & 72057594037927935, encode_id >> 56
end
function Logic_BonusPass:GetReceiveRecord()
  if self.tActData and self.tActData.level_select_items then
    return self.tActData.level_select_items
  end
  return
end
function Logic_BonusPass:GetRpBranchActData()
  return self.tActData
end
function Logic_BonusPass:GetRpBranchScore()
  if not self.tSeasonCfg then
    return 0
  end
  local score = self.nTotalScore % self.tSeasonCfg.levelScore
  return score
end
function Logic_BonusPass:GetRpBranchLevel()
  if not self.tSeasonCfg then
    return 0
  end
  local level = math.floor(self.nTotalScore / self.tSeasonCfg.levelScore)
  if level >= self.tSeasonCfg.maxLevel then
    return self.tSeasonCfg.maxLevel
  end
  return level
end
function Logic_BonusPass:GetNotLimitBPLevel()
  if not self.tSeasonCfg then
    return 0
  end
  local level = math.floor(self.nTotalScore / self.tSeasonCfg.levelScore)
  return level
end
function Logic_BonusPass:GetRpBranchMaxLevel()
  if self.tSeasonCfg and self.tSeasonCfg.maxLevel then
    return self.tSeasonCfg.maxLevel
  end
  return 60
end
function Logic_BonusPass:GetCurBpScore()
  return self.nTotalScore
end
function Logic_BonusPass:GetFullLevelBpScore()
  local nDeafultMaxScore = 6000
  local tBpSeasonCfg = self.tSeasonCfg
  if not tBpSeasonCfg then
    return nDeafultMaxScore
  end
  return tBpSeasonCfg.maxLevel * tBpSeasonCfg.levelScore
end
function Logic_BonusPass:GetCanReceiveExtraChestCount()
  local nCurChestCount = 0
  if self:GetRpBranchLevel() < self:GetRpBranchMaxLevel() then
    return nCurChestCount
  else
    local nCurAllChestCount = math.floor((self.nTotalScore - self:GetFullLevelBpScore()) / self.tFullLevelExtraRewardCfg.SingleChestNeedScore)
    local nMaxChestCount = self.tFullLevelExtraRewardCfg.ChestMaxCount
    if nCurAllChestCount >= nMaxChestCount then
      nCurAllChestCount = nMaxChestCount
    end
    local tChestReceiveRecords = self.tActData and self.tActData.special_chest_records
    if tChestReceiveRecords then
      local nHasReceiveChestCount = #tChestReceiveRecords
      nCurChestCount = nCurAllChestCount - nHasReceiveChestCount
    else
      nCurChestCount = nCurAllChestCount
    end
    return nCurChestCount
  end
end
function Logic_BonusPass:GetIsReceiveAllExtraChest()
  if not self:IsHasUnlockRpBranch() then
    return false
  elseif self:GetRpBranchLevel() < self:GetRpBranchMaxLevel() then
    return false
  else
    local nHasReceiveChestCount = 0
    local tChestReceiveRecords = self.tActData and self.tActData.special_chest_records
    if tChestReceiveRecords then
      nHasReceiveChestCount = #tChestReceiveRecords
    end
    return nHasReceiveChestCount >= self.tFullLevelExtraRewardCfg.ChestMaxCount
  end
end
function Logic_BonusPass:GetCurReceiveChestCount()
  local tChestReceiveRecords = self.tActData and self.tActData.special_chest_records
  local nHasReceiveChestCount = 0
  if tChestReceiveRecords then
    nHasReceiveChestCount = #tChestReceiveRecords
  end
  return nHasReceiveChestCount
end
function Logic_BonusPass:GetCurChestScore()
  local nCurShowScore = 0
  if self:GetRpBranchLevel() < self:GetRpBranchMaxLevel() then
    return nCurShowScore
  else
    local tExtraRewardCfg = self.tFullLevelExtraRewardCfg
    local nMaxScoreCount = self:GetFullLevelBpScore() + tExtraRewardCfg.ChestMaxCount * tExtraRewardCfg.SingleChestNeedScore
    if nMaxScoreCount <= self.nTotalScore then
      return nCurShowScore
    end
    nCurShowScore = (self.nTotalScore - self:GetFullLevelBpScore()) % self.tFullLevelExtraRewardCfg.SingleChestNeedScore
    return nCurShowScore
  end
end
function Logic_BonusPass:GetCurSpecialRewardScore()
  local nCurShowScore = 0
  if self:GetRpBranchLevel() < self:GetRpBranchMaxLevel() then
    return nCurShowScore
  else
    nCurShowScore = self.nTotalScore - self:GetFullLevelBpScore()
    if nCurShowScore >= self.tFullLevelExtraRewardCfg.ExtraRewardNeedScore then
      nCurShowScore = self.tFullLevelExtraRewardCfg.ExtraRewardNeedScore
    end
    return nCurShowScore
  end
end
function Logic_BonusPass:GetSpecialRewardReceiveState()
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_SPECIAL_REWARD_STATE = Logic_BonusPass_Const_Config.ENUM_BP_SPECIAL_REWARD_STATE
  if self.tActData and self.tActData.got_special_reward then
    return ENUM_BP_SPECIAL_REWARD_STATE.Receive
  end
  if self.nTotalScore < self:GetFullLevelBpScore() + self.tFullLevelExtraRewardCfg.ExtraRewardNeedScore then
    return ENUM_BP_SPECIAL_REWARD_STATE.NotEnough
  else
    return ENUM_BP_SPECIAL_REWARD_STATE.NotReceive
  end
end
function Logic_BonusPass:GetBeforeLevel()
  return self.nBeforeLevel or 0
end
function Logic_BonusPass:IsHasUnlockRpBranch()
  if self:IsUnlockExperienceBP() then
    return true
  end
  if self:IsUnlockFullBP() then
    return true
  end
  if self.tActData and self.tActData.is_unlock then
    return self.tActData.is_unlock == 1
  end
  return false
end
function Logic_BonusPass:IsUnlockExperienceBP()
  if not self.tActData then
    return false
  end
  if not self.tActData.bp_experience_unlock then
    return false
  end
  if self.tActData.bp_experience_unlock == 0 then
    return false
  end
  return true
end
function Logic_BonusPass:IsUnlockFullBP()
  if not self.tActData then
    return false
  end
  if not self.tActData.bp_all_unlock then
    return false
  end
  if self.tActData.bp_all_unlock == 0 then
    return false
  end
  return true
end
function Logic_BonusPass:IsUnlockLastBPSeason()
  if not self.tActData then
    return false
  end
  if not self.tActData.last_unlock then
    return false
  end
  if self.tActData.last_unlock == 0 then
    return false
  end
  return true
end
function Logic_BonusPass:IsUseNewSideBarShow()
  return UnknowPassSystem.Season >= 54
end
function Logic_BonusPass:GetBranchBuyAwards(buyLevel)
  local tAwardList = {}
  local nCurLevel = self:GetRpBranchLevel()
  local nMaxLevel = self:GetRpBranchMaxLevel()
  if nCurLevel >= nMaxLevel then
    return
  end
  for nTempLevel = nCurLevel + 1, nMaxLevel do
    local tLevelAwardOriData = self.tLevelAwardData[nTempLevel]
    if nTempLevel > nCurLevel and nTempLevel <= nCurLevel + buyLevel then
      local bIsTwoSelectOne = tLevelAwardOriData.twoItemSelect > 0
      local tLevelAllReward = {}
      for i = 1, 2 do
        local tRewardItem = self:ConvertLevelAwardData(tLevelAwardOriData, i)
        if not tRewardItem then
          break
        end
        tLevelAllReward[i] = tRewardItem
      end
      if bIsTwoSelectOne and (nTempLevel == specialLevel1 or nTempLevel == specialLevel2) then
        local tReceiveRecord = self:GetReceiveRecord()
        local nSpecialSelected1 = tReceiveRecord and tReceiveRecord[specialLevel1]
        if nSpecialSelected1 then
          if nSpecialSelected1 == tLevelAwardOriData.awardItemID1 then
            tLevelAllReward[1] = tLevelAllReward[2]
          end
          tLevelAllReward[2] = nil
        end
      end
      tAwardList[nTempLevel] = tLevelAllReward
    end
  end
  return tAwardList
end
function Logic_BonusPass:GetNewBranchBuyAwards(buyLevel)
  local tAwardList = {}
  local nCurLevel = math.floor(self.nTotalScore / self.tSeasonCfg.levelScore)
  local nMaxLevel = self:GetRpBranchMaxLevel()
  local nBuyMaxLevel = nMaxLevel + self.tFullLevelExtraRewardCfg.ChestMaxCount
  local nChangeColorLevel = nMaxLevel + self.tFullLevelExtraRewardCfg.ExtraRewardNeedScore / self.tSeasonCfg.levelScore
  if nCurLevel >= nBuyMaxLevel then
    return
  end
  for nTempLevel = nCurLevel + 1, nBuyMaxLevel do
    local tLevelAwardOriData = self.tLevelAwardData[nTempLevel]
    if nTempLevel > nCurLevel and nTempLevel <= nCurLevel + buyLevel then
      if nTempLevel > nMaxLevel then
        local tLevelAllReward = {
          {
            resId = self.tFullLevelExtraRewardCfg.ChestID,
            count = 1,
            valid_hours = 0,
            awardLevel = nTempLevel,
            bSelectOne = false
          }
        }
        if nTempLevel == nChangeColorLevel then
          table.insert(tLevelAllReward, {
            resId = self.tFullLevelExtraRewardCfg.ExtraRewardItemId,
            count = 1,
            valid_hours = 0,
            awardLevel = nTempLevel,
            bSelectOne = false
          })
        end
        tAwardList[nTempLevel] = tLevelAllReward
      else
        local bIsTwoSelectOne = 0 < tLevelAwardOriData.twoItemSelect
        local tLevelAllReward = {}
        for i = 1, 2 do
          local tRewardItem = self:ConvertLevelAwardData(tLevelAwardOriData, i)
          if not tRewardItem then
            break
          end
          tLevelAllReward[i] = tRewardItem
        end
        if bIsTwoSelectOne and (nTempLevel == specialLevel1 or nTempLevel == specialLevel2) then
          local tReceiveRecord = self:GetReceiveRecord()
          local nSpecialSelected1 = tReceiveRecord and tReceiveRecord[specialLevel1]
          if nSpecialSelected1 then
            if nSpecialSelected1 == tLevelAwardOriData.awardItemID1 then
              tLevelAllReward[1] = tLevelAllReward[2]
            end
            tLevelAllReward[2] = nil
          end
        end
        tAwardList[nTempLevel] = tLevelAllReward
      end
    end
  end
  return tAwardList
end
function Logic_BonusPass:ConvertLevelAwardData(tLevelAward, nRewardIndex)
  local nItemId = tLevelAward["awardItemID" .. nRewardIndex]
  if not nItemId or nItemId == 0 then
    return
  end
  return {
    resId = tLevelAward["awardItemID" .. nRewardIndex],
    count = tLevelAward["awardItemCount" .. nRewardIndex],
    valid_hours = tLevelAward["awardItemValidHours" .. nRewardIndex],
    awardLevel = tLevelAward.awardLevel,
    bSelectOne = 0 < tLevelAward.twoItemSelect
  }
end
function Logic_BonusPass:GetLevelAwardPreviewList()
  if self.tPreviewList then
    return self.tPreviewList
  end
  local LevelList = {}
  for _, v in pairs(self.tLevelAwardData) do
    v.specialPreview = false
    if v.awardLevel % 10 == 0 then
      v.specialPreview = true
      LevelList[#LevelList + 1] = v
    end
  end
  self.tPreviewList = LevelList
  return LevelList
end
function Logic_BonusPass:GetCoreRewardData()
  local tRewardCfg = self:GetCoreRewardCfg()
  local tFirtPartReward = {}
  local tSecondPartReward = {}
  local tTwoSelectOneReward = {}
  tTwoSelectOneReward[1] = {}
  for _, v in pairs(tRewardCfg) do
    if v.AwardPos == Enum_Core_Reward_Pos.FirstPart then
      tFirtPartReward[#tFirtPartReward + 1] = v
    elseif v.AwardPos == Enum_Core_Reward_Pos.SecondPart then
      tSecondPartReward[#tSecondPartReward + 1] = v
    else
      tTwoSelectOneReward[1][#tTwoSelectOneReward[1] + 1] = v
    end
  end
  return tTwoSelectOneReward, tFirtPartReward, tSecondPartReward
end
function Logic_BonusPass:UpdateDailyTaskData()
  if not self.tTaskProgress or not self.tDailyTaskCfg then
    return
  end
  local taskData = self.tTaskProgress
  local day = taskData.daily.time_id
  self.nCurTaskDays = taskData.daily.time_id
  local taskGroupId = 0
  for _, v in pairs(self.tDailyTaskCfg) do
    if day == v.days then
      taskGroupId = v.taskGroupID
      break
    end
  end
  local dailyTaskData = self:GetTaskCfgByIndexAndGroupID(taskGroupId)
  self.tDailyTaskData = dailyTaskData
  self.tDailyTaskData = self:GetFinalTaskData(self.tDailyTaskData, self.tTaskProgress.daily.tasks, self.tDailyTaskCfg, true)
end
function Logic_BonusPass:UpdateWeekTaskData()
  if not self.tTaskProgress or not self.tWeekTaskCfg then
    return
  end
  local taskData = self.tTaskProgress
  local week = taskData.weekly.time_id
  self.nCurTaskWeeks = taskData.weekly.time_id
  local taskGroupId = 0
  for _, v in pairs(self.tWeekTaskCfg) do
    if week == v.weeks then
      taskGroupId = v.taskGroupID
      break
    end
  end
  local weekTaskData = self:GetTaskCfgByIndexAndGroupID(taskGroupId)
  self.tWeekTaskData = weekTaskData
  self.tWeekTaskData = self:GetFinalTaskData(self.tWeekTaskData, self.tTaskProgress.weekly.tasks, self.tWeekTaskCfg, false)
end
function Logic_BonusPass:GetFinalTaskData(taskData, taskProgress, taskCfg, bIsDailyTask)
  local tRecoveryTaskId = {}
  for encode_id, v in pairs(taskProgress) do
    local task_id, time_id = self:Decode_task_id(encode_id)
    if task_id and time_id then
      table.insert(tRecoveryTaskId, v)
    end
  end
  local tRecoveryTaskData = {}
  for _, v in pairs(tRecoveryTaskId) do
    local nGroupId = 0
    for _, vv in pairs(taskCfg) do
      if bIsDailyTask then
        if v.time_id == vv.days then
          nGroupId = vv.taskGroupID
          break
        end
      elseif v.time_id == vv.weeks then
        nGroupId = vv.taskGroupID
        break
      end
    end
    local tDailyTaskData = self:GetTaskCfgByTaskIdandGroupID(v.task_id, nGroupId)
    table.insert(tRecoveryTaskData, tDailyTaskData[1])
  end
  for _, v in pairs(tRecoveryTaskData) do
    v.recoveryTaskCount = 1
  end
  for _, v in pairs(taskData) do
    v.recoveryTaskCount = 0
  end
  local taskMap = {}
  for _, task in pairs(tRecoveryTaskData) do
    local taskID = task.taskID
    if not taskMap[taskID] then
      taskMap[taskID] = {
        taskGroupID = task.taskGroupID,
        index = task.index,
        recoveryTaskCount = task.recoveryTaskCount,
        taskID = task.taskID,
        showSortOrder = task.showSortOrder,
        awardScores = task.awardScores,
        taskType = task.taskType
      }
    else
      local existingTask = taskMap[taskID]
      existingTask.recoveryTaskCount = existingTask.recoveryTaskCount + task.recoveryTaskCount
    end
  end
  local result = {}
  for _, mergedTask in pairs(taskMap) do
    table.insert(result, mergedTask)
  end
  for _, v in pairs(result) do
    table.insert(taskData, v)
  end
  local taskCount = {}
  for _, task in ipairs(taskData) do
    taskCount[task.taskID] = (taskCount[task.taskID] or 0) + 1
  end
  local tTaskTemp = {}
  for _, task in ipairs(taskData) do
    local taskID = task.taskID
    if taskCount[taskID] == 1 then
      table.insert(tTaskTemp, {
        index = task.index,
        showSortOrder = task.showSortOrder,
        taskGroupID = task.taskGroupID,
        awardScores = task.awardScores,
        taskType = task.taskType,
        recoveryTaskCount = task.recoveryTaskCount,
              })
    elseif not tTaskTemp[taskID] then
      tTaskTemp[taskID] = {
        index = task.index,
        showSortOrder = task.showSortOrder,
        taskGroupID = task.taskGroupID,
        awardScores = task.awardScores,
        taskType = task.taskType,
        recoveryTaskCount = task.recoveryTaskCount == 0 and 1 or task.recoveryTaskCount,
              }
    else
      local currentRecoveryCount = task.recoveryTaskCount == 0 and 1 or task.recoveryTaskCount
      tTaskTemp[taskID].recoveryTaskCount = tTaskTemp[taskID].recoveryTaskCount + currentRecoveryCount
    end
  end
  local mergedTable = {}
  for _, task in pairs(tTaskTemp) do
    table.insert(mergedTable, task)
  end
  return mergedTable
end
function Logic_BonusPass:HandleGetLevelAward(itemInfo)
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumAwardState = UnknowPassMacro.Enum_BranchAwardState
  if itemInfo.awardState ~= EnumAwardState.CanGet then
    return
  end
  local bIsTwoItemSelect = itemInfo.twoItemSelect > 1
  if bIsTwoItemSelect then
    if itemInfo.awardLevel == specialLevel1 or itemInfo.awardLevel == specialLevel2 then
      if self:GetSpecialLevelIsReceivedLeastOne() then
        local tRecord = self:GetReceiveRecord()
        local nSelectedItemId = tRecord and tRecord[specialLevel1] or tRecord[specialLevel2]
        local nCurSelectIndex = nSelectedItemId == itemInfo.awardItemID1 and 2 or 1
        self:send_rp_branch_get_level_award_req(itemInfo.awardLevel, nCurSelectIndex)
      else
        self:ShowBranchMultiChooseOneUI(itemInfo, function(nSelectIndex)
          self:send_rp_branch_get_level_award_req(itemInfo.awardLevel, nSelectIndex)
        end)
        return
      end
    else
      self:ShowBranchMultiChooseOneUI(itemInfo, function(nSelectIndex)
        self:send_rp_branch_get_level_award_req(itemInfo.awardLevel, nSelectIndex)
      end)
      return
    end
    return
  end
  self:send_rp_branch_get_level_award_req(itemInfo.awardLevel)
end
function Logic_BonusPass:ShowBranchMultiChooseOneUI(tAllItem, fCallback)
  local tAllItemId = {}
  for i = 1, 2 do
    tAllItemId[i] = tAllItem["awardItemID" .. i]
  end
  local tips = ""
  if tAllItem.awardLevel == specialLevel1 then
    tips = LocUtil.LocalizeResFormat(66807, specialLevel1, specialLevel2)
  elseif tAllItem.awardLevel == specialLevel2 then
    tips = LocUtil.LocalizeResFormat(66807, specialLevel2, specialLevel1)
  end
  local tShowData = {
    tAllItemId = tAllItemId,
    nShowGroupId = tAllItem.twoItemSelect,
    fSelectedCallback = fCallback,
    sTipsContent = tips,
    bMatchSize = true
  }
  local Logic_MultiChooseOne = require("client.slua.logic.common.Logic_MultiChooseOne")
  Logic_MultiChooseOne.ShowUI(#tAllItemId, tShowData)
end
function Logic_BonusPass:UpdateLevelAwardState()
  if not self.tActData or not self.tLevelAwardData then
    return
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumAwardState = UnknowPassMacro.Enum_BranchAwardState
  local level_award = self.tActData.level_award
  for _, v in pairs(self.tLevelAwardData) do
    local curLevel = self:GetRpBranchLevel()
    if v.awardLevel <= specialLevel1 then
      if (self:IsUnlockExperienceBP() or self:IsUnlockFullBP()) and curLevel >= v.awardLevel then
        v.awardState = level_award[v.awardLevel] or 0
      else
        v.awardState = EnumAwardState.Lock
      end
    elseif self:IsUnlockFullBP() and curLevel >= v.awardLevel then
      v.awardState = level_award[v.awardLevel] or 0
    else
      v.awardState = EnumAwardState.Lock
    end
  end
end
function Logic_BonusPass:GetLevelRewardIsReceive(nLevel)
  if not self.tLevelAwardData or not self.tLevelAwardData[nLevel] then
    return false
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumAwardState = UnknowPassMacro.Enum_BranchAwardState
  local bCanGet = self.tLevelAwardData[nLevel].awardState == EnumAwardState.CanGet
  return bCanGet
end
function Logic_BonusPass:GetAllRewardMultiChooseOne(nCheckStartLevel, tAllSelect)
  nCheckStartLevel = nCheckStartLevel or 1
  tAllSelect = tAllSelect or {}
  local nCurLevel = self:GetRpBranchLevel()
  local tAllReward = self.tLevelAwardData
  if not tAllReward then
    return
  end
  for i = nCheckStartLevel, nCurLevel do
    if tAllReward[i].twoItemSelect > 0 then
      local bCanGet = self:GetLevelRewardIsReceive(i)
      if bCanGet then
        local bIsShowMultiChooseOne = true
        if i == specialLevel1 or i == specialLevel2 then
          if tAllSelect[i] then
            bIsShowMultiChooseOne = false
          else
            local nNotSelectIndex = self:GetLeftTwoSelectOneItemIndex()
            if not nNotSelectIndex or nNotSelectIndex == 0 then
              local bIsCanReceiveAll = self:CheckIsCanReceiveAllSpecialLevel()
              if bIsCanReceiveAll then
                bIsShowMultiChooseOne = false
                tAllSelect[specialLevel1] = 1
                tAllSelect[specialLevel2] = 2
              end
            else
              bIsShowMultiChooseOne = false
              tAllSelect[i] = nNotSelectIndex
            end
          end
        end
        if bIsShowMultiChooseOne then
          local tLevelReward = tAllReward[i]
          self:ShowBranchMultiChooseOneUI(tLevelReward, function(nSelectIndex)
            tAllSelect[i] = nSelectIndex
            nCheckStartLevel = i + 1
            self:AddTimerOnce(0, function()
              self:GetAllRewardMultiChooseOne(nCheckStartLevel, tAllSelect)
            end)
          end)
          return
        end
      end
    end
  end
  local UpassBranchHandler = require("client.network.Protocol.UpassBranchHandler")
  UpassBranchHandler.send_rp_branch_batch_get_level_award_req(tAllSelect)
  local nExtraBoxCount = self:GetCanReceiveExtraChestCount()
  if 0 < nExtraBoxCount and self:IsUnlockFullBP() and self:IsInActivityTimes() then
    UpassBranchHandler.send_rp_branch_get_extra_chest_req(nExtraBoxCount)
  end
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_BP_SPECIAL_REWARD_STATE = Logic_BonusPass_Const_Config.ENUM_BP_SPECIAL_REWARD_STATE
  local nSpecialRewardState = self:GetSpecialRewardReceiveState()
  if self:IsUnlockFullBP() and nSpecialRewardState == ENUM_BP_SPECIAL_REWARD_STATE.NotReceive and self:IsInActivityTimes() then
    UpassBranchHandler.send_rp_branch_get_special_reward_req()
  end
end
function Logic_BonusPass:CheckIsCanReceiveAllSpecialLevel()
  local nCurLevel = self:GetRpBranchLevel()
  if nCurLevel >= specialLevel1 and nCurLevel >= specialLevel2 and self:GetLevelRewardIsReceive(specialLevel1) and self:GetLevelRewardIsReceive(specialLevel2) then
    return true
  end
  return false
end
function Logic_BonusPass:GetLeftTwoSelectOneItemIndex()
  local nNotSelectIndex = 0
  local tRecord = self:GetReceiveRecord()
  if not tRecord or tRecord[specialLevel1] and tRecord[specialLevel2] then
    return nNotSelectIndex
  end
  if tRecord[specialLevel1] or tRecord[specialLevel2] then
    local nSelectedLevel = tRecord[specialLevel1] and specialLevel1 or specialLevel2
    local nSelectedItemId = tRecord[nSelectedLevel]
    local nNotSelectLevel = nSelectedLevel == specialLevel1 and specialLevel2 or specialLevel1
    local tNotSelectLevelRewardData = self.tLevelAwardData[nNotSelectLevel]
    if nSelectedItemId == tNotSelectLevelRewardData.awardItemID1 then
      nNotSelectIndex = 2
    elseif nSelectedItemId == tNotSelectLevelRewardData.awardItemID2 then
      nNotSelectIndex = 1
    end
  end
  return nNotSelectIndex
end
function Logic_BonusPass:GetSpecialLevelIsReceivedLeastOne()
  local tRecord = self:GetReceiveRecord()
  local bIsReceivedSpecialLevel = tRecord and (tRecord[specialLevel1] or tRecord[specialLevel2])
  return bIsReceivedSpecialLevel
end
function Logic_BonusPass:GetSpecialLevelShowItem(nLevel, tLevelRewardData)
  if nLevel ~= specialLevel1 and nLevel ~= specialLevel2 then
    return
  end
  tLevelRewardData = tLevelRewardData or self.tLevelAwardData[nLevel]
  if not tLevelRewardData then
    return
  end
  local nSelectItemId = tLevelRewardData.awardItemID1
  local nSelectIndex = 1
  local tRecord = self:GetReceiveRecord()
  local bIsReceivedSpecialLevel = self:GetSpecialLevelIsReceivedLeastOne()
  if bIsReceivedSpecialLevel then
    local nGotItemId = tRecord[nLevel]
    nSelectItemId = nGotItemId
    if not nGotItemId then
      local nGotLevel = nLevel == specialLevel1 and specialLevel2 or specialLevel1
      nGotItemId = tRecord[nGotLevel]
      nSelectItemId = nGotItemId == tLevelRewardData.awardItemID1 and tLevelRewardData.awardItemID2 or tLevelRewardData.awardItemID1
    end
    nSelectIndex = nSelectItemId == tLevelRewardData.awardItemID1 and 1 or 2
  end
  return nSelectItemId, nSelectIndex, bIsReceivedSpecialLevel
end
function Logic_BonusPass:CheckIsShowLevelUp(new_score, beforLevel)
  local nLevel = math.floor(new_score / self.tSeasonCfg.levelScore)
  if nLevel > self:GetRpBranchMaxLevel() then
    return
  end
  local curLevel = math.floor(new_score / self.tSeasonCfg.levelScore)
  if GameStatus.IsInLobbyOrMainCity() then
    local uiConfig = {
      UIManager.UI_Config.UnknowPass_Award_Branch_BP,
      UIManager.UI_Config.BranchRP_Task_UIBP,
      UIManager.UI_Config.unknowpass_branch_award_buyscore
    }
    local bIsInRpBranch = false
    for _, v in pairs(uiConfig) do
      if UIManager.IsUIShow(v) then
        bIsInRpBranch = true
        break
      end
    end
    self.nTotalScore = new_score
    if beforLevel < curLevel then
      if bIsInRpBranch and self:IsHasUnlockRpBranch() then
        self.bDelayShow = false
        self:OpenLevelUpPopup(Enum_LevelUpType.LevelUp)
      else
        self.bDelayShow = true
        self:SaveDelayShowLevelUpData(Enum_LevelUpType.LevelUp)
      end
    end
  elseif GameStatus.IsInFightingNotSocialNotMainCityNotHome() and beforLevel < curLevel then
    self.bDelayShow = true
    self:SaveDelayShowLevelUpData(Enum_LevelUpType.LevelUp)
  end
end
function Logic_BonusPass:SaveDelayShowLevelUpData(LevelUpType, curLevel)
  self.tDelayPopData = {type = LevelUpType, level = curLevel}
end
function Logic_BonusPass:OpenLevelUpPopup(LevelUpType)
  if self.tDelayPopData and self.bDelayShow and LevelUpType == Enum_LevelUpType.LevelUp then
    LevelUpType = self.tDelayPopData.type
  end
  UIManager.ShowUI(UIManager.UI_Config.bonuspass_levelup, LevelUpType)
  self.bUpdateLevel = true
  if self:IsDelayShowLevelUp() then
    self.tDelayPopData = nil
    self.bDelayShow = false
  end
end
function Logic_BonusPass:IsDelayShowLevelUp()
  return self.tDelayPopData and self.bDelayShow
end
function Logic_BonusPass:GetTaskDesc(task_id)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    return ""
  else
    local cfg = general_task_cond_cfg_simple[task_id]
    if not cfg then
      return ""
    end
    local RPTaskDesc = CDataTable.GetTableData("RPTaskDesc", task_id)
    if not RPTaskDesc then
      return ""
    end
    local OgriDescID = RPTaskDesc.Desc
    local desc = ""
    if RPTaskDesc then
      local sFinishCnt
      local finish = cfg.finish_value
      sFinishCnt = finish
      if RPTaskDesc.Content == "" and RPTaskDesc.LocalizeContent == 0 then
        desc = LocUtil.LocalizeResFormat(OgriDescID, sFinishCnt)
      elseif RPTaskDesc.Content ~= "" then
        desc = LocUtil.LocalizeResFormat(OgriDescID, RPTaskDesc.Content, sFinishCnt)
      elseif RPTaskDesc.LocalizeContent ~= 0 then
        local content = LocUtil.LocalizeResFormat(RPTaskDesc.LocalizeContent)
        desc = LocUtil.LocalizeResFormat(OgriDescID, content, sFinishCnt)
      end
    end
    return desc
  end
end
function Logic_BonusPass:UpdateTaskList()
  if not (self.tTaskProgress and self.tDailyTaskData) or not self.tWeekTaskData then
    return
  end
  local taskInfo = self.tTaskProgress
  local dailyTaskProgress = taskInfo.daily.tasks
  local weekTaskProgress = taskInfo.weekly.tasks
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local taskCfgs = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple) or {}
  if not next(taskCfgs) then
    BasicDataServerTable:GetOrReqData(data_config_marco.general_task_cond_cfg_simple, function()
      self:UpdateTaskList()
    end)
    return
  end
  self:HandleTaskInfo(self.tDailyTaskData, taskCfgs, dailyTaskProgress, 1)
  self:HandleTaskInfo(self.tWeekTaskData, taskCfgs, weekTaskProgress, 2)
end
function Logic_BonusPass:HandleTaskInfo(taskData, taskCfgs, taskProgress, task_type)
  for _, data in pairs(taskData) do
    local id = data.taskID
    data.finish_value = taskCfgs[id] and taskCfgs[id].finish_value or 0
    data.    data.status, data.value, data.finish_count, data.task_count, data.recoveryId = self:GetCurTaskIdShowProgressAndStatus(id, taskProgress, data.finish_value)
    data.  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumTaskState = UnknowPassMacro.Enum_BranchTaskState
  table.sort(taskData, function(a, b)
    if a.status == b.status then
      if a.recoveryTaskCount == 0 and b.recoveryTaskCount == 0 then
        return a.showSortOrder < b.showSortOrder
      elseif a.recoveryTaskCount > 0 and b.recoveryTaskCount > 0 then
        if a.recoveryTaskCount == b.recoveryTaskCount then
          return a.taskID < b.taskID
        else
          return a.recoveryTaskCount > b.recoveryTaskCount
        end
      else
        return b.recoveryTaskCount > 0
      end
    elseif a.status == EnumTaskState.HasFinish or b.status == EnumTaskState.HasFinish then
      return a.status == EnumTaskState.HasFinish
    else
      return a.status < b.status
    end
  end)
end
function Logic_BonusPass:GetCurTaskIdShowProgressAndStatus(taskId, taskProgress, finish_value)
  if not taskProgress then
    return
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumTaskState = UnknowPassMacro.Enum_BranchTaskState
  local tCurTaskInfo = taskProgress[taskId]
  if tCurTaskInfo then
    if tCurTaskInfo.status == EnumTaskState.NotFinish then
      local nAllTaskCount = 0
      for _, v in pairs(taskProgress) do
        if v.task_id == taskId then
          nAllTaskCount = nAllTaskCount + 1
        end
      end
      return tCurTaskInfo.status, taskProgress[taskId].value, 0, nAllTaskCount
    elseif tCurTaskInfo.status == EnumTaskState.HasFinish then
      local nAllTaskCount = 0
      for _, v in pairs(taskProgress) do
        if v.task_id == taskId then
          nAllTaskCount = nAllTaskCount + 1
        end
      end
      return tCurTaskInfo.status, taskProgress[taskId].value, 1, nAllTaskCount
    else
      local nAllTaskCount = 0
      local nFinishCount = 0
      local nHasReceiveTaskCount = 0
      local bHasTaskProgress = false
      local tCurTaskStatus = EnumTaskState.NotFinish
      local nFinishValue = 0
      local tCurProgressTaskInfo
      for _, v in pairs(taskProgress) do
        if v.task_id == taskId then
          nAllTaskCount = nAllTaskCount + 1
          if v.status == EnumTaskState.HasReceive then
            nHasReceiveTaskCount = nHasReceiveTaskCount + 1
            nFinishCount = nFinishCount + 1
          elseif v.status == EnumTaskState.NotFinish and 0 < v.value or v.status == EnumTaskState.HasFinish then
            bHasTaskProgress = true
            tCurTaskStatus = v.status
            nFinishValue = v.value
            tCurProgressTaskInfo = v
            if v.status == EnumTaskState.HasFinish then
              nFinishCount = nFinishCount + 1
            end
          end
        end
      end
      if nAllTaskCount == 1 then
        return tCurTaskInfo.status, taskProgress[taskId].value, nFinishCount, nAllTaskCount
      end
      if bHasTaskProgress then
        local recoveryId
        if tCurProgressTaskInfo then
          recoveryId = self:Encode_task_id(tCurProgressTaskInfo.task_id, tCurProgressTaskInfo.time_id)
        end
        return tCurTaskStatus, nFinishValue, nFinishCount, nAllTaskCount, recoveryId
      end
      if nHasReceiveTaskCount == nAllTaskCount then
        return EnumTaskState.HasReceive, finish_value, nAllTaskCount, nAllTaskCount
      end
      if 0 < nFinishCount then
        return EnumTaskState.NotFinish, nFinishValue, nFinishCount, nAllTaskCount
      end
      return EnumTaskState.NotFinish, 0, 0, nAllTaskCount
    end
  else
    local tRecoveryTaskList = {}
    local tCurProgressTaskInfo
    for _, v in pairs(taskProgress) do
      if taskId == v.task_id then
        tCurProgressTaskInfo = v
        table.insert(tRecoveryTaskList, v)
      end
    end
    if #tRecoveryTaskList == 1 then
      local recoveryId
      local nFinishCount = 0
      if tCurProgressTaskInfo then
        recoveryId = self:Encode_task_id(tCurProgressTaskInfo.task_id, tCurProgressTaskInfo.time_id)
      end
      if tRecoveryTaskList[1].status == EnumTaskState.HasFinish or tRecoveryTaskList[1].status == EnumTaskState.HasReceive then
        nFinishCount = 1
      end
      return tRecoveryTaskList[1].status, tRecoveryTaskList[1].value, nFinishCount, 1, recoveryId
    end
    local nFinishCount = 0
    local bHasTaskProgress = false
    local nHasReceiveTaskCount = 0
    local tCurTaskStatus = EnumTaskState.NotFinish
    local nFinishValue = 0
    for _, v in pairs(tRecoveryTaskList) do
      if v.task_id == taskId then
        if v.status == EnumTaskState.HasReceive then
          nHasReceiveTaskCount = nHasReceiveTaskCount + 1
          nFinishCount = nFinishCount + 1
        elseif v.status == EnumTaskState.NotFinish and 0 < v.value or v.status == EnumTaskState.HasFinish then
          bHasTaskProgress = true
          tCurTaskStatus = v.status
          nFinishValue = v.value
          tCurProgressTaskInfo = v
          if v.status == EnumTaskState.HasFinish then
            nFinishCount = nFinishCount + 1
          end
        end
      end
    end
    if bHasTaskProgress then
      local recoveryId = self:Encode_task_id(tCurProgressTaskInfo.task_id, tCurProgressTaskInfo.time_id)
      return tCurTaskStatus, nFinishValue, nFinishCount, #tRecoveryTaskList, recoveryId
    end
    if nHasReceiveTaskCount == #tRecoveryTaskList then
      return EnumTaskState.HasReceive, finish_value, #tRecoveryTaskList, #tRecoveryTaskList
    end
    if 0 < nFinishCount then
      return EnumTaskState.NotFinish, nFinishValue, nFinishCount, #tRecoveryTaskList
    end
    return EnumTaskState.NotFinish, 0, 0, #tRecoveryTaskList
  end
end
function Logic_BonusPass:IsHasRewardCanReceive()
  if not self.tLevelAwardData then
    return false
  end
  if UnknowPassSystem.Season >= 54 and self:IsUnlockFullBP() then
    local nExtraBoxCount = self:GetCanReceiveExtraChestCount()
    if 0 < nExtraBoxCount then
      return true
    end
    local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
    local ENUM_BP_SPECIAL_REWARD_STATE = Logic_BonusPass_Const_Config.ENUM_BP_SPECIAL_REWARD_STATE
    local nSpecialRewardState = self:GetSpecialRewardReceiveState()
    if nSpecialRewardState == ENUM_BP_SPECIAL_REWARD_STATE.NotReceive then
      return true
    end
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumAwardState = UnknowPassMacro.Enum_BranchAwardState
  for _, v in pairs(self.tLevelAwardData) do
    if v.awardState == EnumAwardState.CanGet then
      return true
    end
  end
  return false
end
function Logic_BonusPass:IsCanReceiveTaskReward()
  if not self.tTaskProgress then
    return false
  end
  if self:IsShowDailyTaskReddot() then
    return true
  end
  if self:IsShowWeeklyTaskReddot() then
    return true
  end
  return false
end
function Logic_BonusPass:IsShowDailyTaskReddot()
  if not self.tTaskProgress then
    return false
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumTaskState = UnknowPassMacro.Enum_BranchTaskState
  local dailyTask = self.tTaskProgress.daily.tasks
  if dailyTask then
    for _, v in pairs(dailyTask) do
      if v.status == EnumTaskState.HasFinish then
        return true
      end
    end
  end
end
function Logic_BonusPass:IsShowWeeklyTaskReddot()
  if not self.tTaskProgress then
    return false
  end
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local EnumTaskState = UnknowPassMacro.Enum_BranchTaskState
  local weekTask = self.tTaskProgress.weekly.tasks
  if weekTask then
    for _, v in pairs(weekTask) do
      if v.status == EnumTaskState.HasFinish then
        return true
      end
    end
  end
  return false
end
function Logic_BonusPass:SetBranchSeasonInfo(timeTextObj)
  local TimeUtil = require("client.common.time_util")
  local seasonData = self.tSeasonCfg or {}
  if timeTextObj and seasonData.realStartTime and seasonData.endTime then
    local realStartTime = TimeUtil.TimeStringToUnixstamp(seasonData.realStartTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(seasonData.endTime)
    local seasonTime = TimeUtil.FormatTime_timeFrame(realStartTime, endTime, false, true)
    timeTextObj:SetText(seasonTime)
  end
end
function Logic_BonusPass:JumpToAward(itemId)
  if not itemId then
    return false
  end
  local toLevel = self:GetAwardLevelByItemId(itemId)
  if not toLevel then
    if UnknowPassSystem.Season >= 54 and itemId == self.tFullLevelExtraRewardCfg.ExtraRewardItemId then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_BONUS_PASS_SUIT_UNLOCK_ITEM_JUMP, itemId)
    end
    return
  end
  local tLevelRewardData = self.tLevelAwardData[toLevel]
  if not tLevelRewardData then
    return
  end
  if tLevelRewardData.twoItemSelect and (toLevel == specialLevel1 or toLevel == specialLevel2) then
    local tReceiveRecord = self:GetReceiveRecord() or {}
    local nSpecialLevel1ItemId = tReceiveRecord[specialLevel1]
    local nSpecialLevel2ItemId = tReceiveRecord[specialLevel2]
    if nSpecialLevel1ItemId then
      toLevel = nSpecialLevel1ItemId == itemId and specialLevel1 or specialLevel2
    elseif nSpecialLevel2ItemId then
      toLevel = nSpecialLevel2ItemId == itemId and specialLevel2 or specialLevel1
    end
  end
  self:JumpToBPLevel(toLevel, itemId)
end
function Logic_BonusPass:JumpToBPLevel(nLevel, nItemId)
  if not (self.tLevelAwardData and nLevel) or not nItemId then
    return
  end
  local tLevelRewardData = self.tLevelAwardData[nLevel]
  if not tLevelRewardData then
    return
  end
  local tSelectLevelData = {
    itemLevel = nLevel,
    itemId = nItemId,
    twoItemSelect = tLevelRewardData.twoItemSelect
  }
  if tLevelRewardData.awardItemID1 == nItemId then
    tSelectLevelData.gridIndex = 1
  elseif tLevelRewardData.awardItemID2 == nItemId then
    tSelectLevelData.gridIndex = 2
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_JUMPTO_LEVEL, nLevel)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BRANCH_JUMP_SELECT, tSelectLevelData)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Bonus_Pass_Jump_Enter, 2)
end
function Logic_BonusPass:GetAwardLevelByItemId(nItemId)
  if not nItemId then
    return
  end
  for _, v in pairs(self.tLevelAwardData) do
    if v.awardItemID1 == nItemId or v.awardItemID2 == nItemId then
      return v.awardLevel
    end
  end
end
function Logic_BonusPass:GetIsCanReceiveAwardByItemId(nItemId)
  if not nItemId then
    return
  end
  if self.tFullLevelExtraRewardCfg and nItemId == self.tFullLevelExtraRewardCfg.ExtraRewardItemId then
    local nSpecialRewardState = self:GetSpecialRewardReceiveState()
    local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
    local ENUM_BP_SPECIAL_REWARD_STATE = Logic_BonusPass_Const_Config.ENUM_BP_SPECIAL_REWARD_STATE
    if self:IsUnlockFullBP() and nSpecialRewardState == ENUM_BP_SPECIAL_REWARD_STATE.NotReceive then
      return true
    end
    return false
  end
  return false
end
function Logic_BonusPass:ShowLevelForThreeImage(widget1, widget2, widget3, level, ver)
  local vRenderScale1 = FVector2D(1.2, 1.2)
  local vRenderScale2 = FVector2D(1, 1)
  if widget1 and widget2 and widget3 then
    local UIUtil = require("client.common.ui_util")
    widget2:SetWidgetVisibility(UIUtil.BoolToVisible(10 <= level))
    widget1:SetWidgetVisibility(UIUtil.BoolToVisible(100 <= level))
    if level < 10 then
      self:LoadImage(level, widget3, ver)
      widget3:SetRenderScale(vRenderScale1)
    elseif level < 100 then
      local ten = math.floor(level / 10)
      local sNumber = level % 10
      self:LoadImage(sNumber, widget3, ver)
      self:LoadImage(ten, widget2, ver)
      widget2:SetRenderScale(vRenderScale1)
      widget3:SetRenderScale(vRenderScale1)
    else
      local ten = math.floor(level / 10)
      local sTen = ten % 10
      local sNumber = level % 10
      self:LoadImage(sNumber, widget3, ver)
      self:LoadImage(sTen, widget2, ver)
      self:LoadImage(1, widget1, ver)
      widget1:SetRenderScale(vRenderScale2)
      widget2:SetRenderScale(vRenderScale2)
      widget3:SetRenderScale(vRenderScale2)
    end
  end
end
function Logic_BonusPass:LoadImage(number, Image, version)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ver = version or UnknowPassUtil.GetVersionNumber()
  numberPath = string.format("%s%s%s", "/Game/Arts_UI/UnknowPass/Common/", ver, "/Atlas/Frames/RP_%d_png.RP_%d_png")
  local StringUtil = require("common.string_util")
  local numList = StringUtil.Split(ver, "_")
  local res = 0
  for _, v in ipairs(numList) do
    res = res * 100 + tonumber(v)
  end
  if res <= 10400 then
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_normal_png.RP_%d_normal_png"
  elseif res < 20600 then
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_png.RP_%d_png"
  else
    numberPathNormal = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RPA_%d_normal_png.RPA_%d_normal_png"
  end
  local texturePath = ""
  texturePath = string.format(numberPathNormal, number, number)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(Image, texturePath)
  if number == 1 and res <= 10400 then
    Image:SetRenderScale(FVector2D(0.6, 1))
  else
    Image:SetRenderScale(FVector2D(1, 1))
  end
end
function Logic_BonusPass:IsShowBranchTask()
  if not self.tSeasonCfg or not self.tSeasonCfg.realStartTime then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local realStartTime = math.floor(TimeUtil.TimeStringToUnixstamp(self.tSeasonCfg.realStartTime))
  if realStartTime > TimeUtil.GetServerTimeInSec() then
    local deltaTime = realStartTime - TimeUtil.GetServerTimeInSec()
    local countTime = 259200
    if deltaTime > countTime then
      return false
    else
      return true
    end
  else
    return true
  end
end
function Logic_BonusPass:IsShowBonusPassNewReddot()
  if not self.tSeasonCfg or not self.tSeasonCfg.realStartTime then
    self:InitSeasonControlCfg()
  end
  if not self.tSeasonCfg or not self.tSeasonCfg.realStartTime then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local realStartTime = math.floor(TimeUtil.TimeStringToUnixstamp(self.tSeasonCfg.realStartTime))
  local deltaTime = realStartTime - TimeUtil.GetServerTimeInSec()
  local countTime = 259200
  if deltaTime > countTime then
    return false
  else
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local newGuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBonusPassNewReddot) or {}
    if not newGuideData[UnknowPassSystem.Season] then
      return true
    end
  end
  return false
end
function Logic_BonusPass:IsInActivityTimes()
  local TimeUtil = require("client.common.time_util")
  local tSeasonCfg = self.tSeasonCfg
  if not (tSeasonCfg and tSeasonCfg.realStartTime) or not tSeasonCfg.endTime then
    return false
  end
  local realStartTime = TimeUtil.TimeStringToUnixstamp(tSeasonCfg.realStartTime)
  local realEndTime = TimeUtil.TimeStringToUnixstamp(tSeasonCfg.endTime)
  local curTime = TimeUtil.GetServerTimeInSec()
  if realStartTime <= curTime and realEndTime >= curTime then
    return true
  end
  return false
end
function Logic_BonusPass:ShowNewGuide()
  local Logic_BonusPass_Const_Config = require("client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Const_Config")
  local ENUM_NEWGUIDE_KEY = Logic_BonusPass_Const_Config.ENUM_NEWGUIDE_KEY
  log(bWriteLog and "  Logic_BonusPass:ShowNewGuide. UnknowPassSystem.Season: " .. tostring(UnknowPassSystem.Season))
  if UIManager.IsUIShow(UIManager.UI_Config.UnknowPass_Award_Branch_BP) then
    local guideQueue = {
      {
        trigger = function()
          return DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.MainNewGuide)
        end,
        execute = function()
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_MAIN_NEWGUIDE)
          DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.MainNewGuide)
        end
      },
      {
        trigger = function()
          return UnknowPassSystem.Season > 51 and DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.ColorfulGuide)
        end,
        execute = function()
          local tAllShow = {
            Logic_BonusPass_Const_Config.colorful_guide_cfg
          }
          local _fCloseCallback = function()
            self:ShowNewGuide()
          end
          local common_config = require("client.slua.common.common_config")
          if not common_config:IsBlockingPopupTip() then
            UIManager.ShowUI(UIManager.UI_Config.Common_Popup_Reward_Base, nil, tAllShow, _fCloseCallback)
          end
          DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.ColorfulGuide)
        end
      },
      {
        trigger = function()
          local bIsTaskShow = UIManager.IsUIShow(UIManager.UI_Config.BranchRP_Task_UIBP)
          local bIsNewGuideShow = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.ExtraReward)
          return bIsNewGuideShow and not bIsTaskShow
        end,
        execute = function()
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_EXTRA_REWARD_NEWGUIDE)
          DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_RP_BRANCH, ENUM_NEWGUIDE_KEY.ExtraReward)
        end
      }
    }
    for _, guide in ipairs(guideQueue) do
      if guide.trigger() then
        guide.execute()
        break
      end
    end
  end
end
function Logic_BonusPass:GetColorfulClothLevel()
  local nMaxLevel = self:GetRpBranchMaxLevel()
  local nChangeColorLevel = nMaxLevel + self.tFullLevelExtraRewardCfg.ExtraRewardNeedScore / self.tSeasonCfg.levelScore
  return nChangeColorLevel
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_BonusPass = class(CModuleBase, nil, Logic_BonusPass)
return CLogic_BonusPass
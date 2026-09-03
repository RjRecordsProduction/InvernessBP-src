local module_newbie_friends_gathering = {}
local FIX_TASK_TYPE = 23
local friend_recommend_popup_info
local TaskSort = function(a, b)
  if a.task_type == FIX_TASK_TYPE and b.task_type ~= FIX_TASK_TYPE then
    return true
  elseif a.task_type == FIX_TASK_TYPE and b.task_type == FIX_TASK_TYPE then
    return false
  elseif a.task_type ~= FIX_TASK_TYPE and b.task_type == FIX_TASK_TYPE then
    return false
  else
    return a.task_type < b.task_type
  end
end
function module_newbie_friends_gathering:OnInitialize()
  module_newbie_friends_gathering.__super.OnInitialize(self)
end
function module_newbie_friends_gathering:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NEWBIE_FRIENDS_RECOMMEND, self.OnModuleNewbieFriendsRecommend, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NEWBIE_RECOMMEND_PANEL, self.ShowRecommendPanel, self)
end
function module_newbie_friends_gathering:OnLogin(bReLogin)
end
function module_newbie_friends_gathering:OnLogOut()
  log(bWriteLog and "[FriendsGathering] module_newbie_friends_gathering:OnLogOut")
  self.task_cfg = nil
  self.all_task_award = nil
  self.task_status = nil
  self.task_status_hash = nil
  friend_recommend_popup_info = nil
end
function module_newbie_friends_gathering:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("[FriendsRecommend] OnPreSwitchGameStatus preState[%s] nextState[%s]", preState, nextState))
end
function module_newbie_friends_gathering:OnPostSwitchGameStatus(preState, nextState)
end
function module_newbie_friends_gathering:ShowRecommendPanel()
  log(bWriteLog and "module_newbie_friends_gathering ShowRecommendPanel")
  if not self:ShouldSlapFriendsRecommend() then
    log(bWriteLog and "module_newbie_friends_gathering:ShowRecommendPanel not need slap")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Newbie_Friends_Recommend, true, {send_is_show_today = true})
end
function module_newbie_friends_gathering:GetFixTaskType()
  return FIX_TASK_TYPE
end
function module_newbie_friends_gathering:OnActivityDataInit(inActData)
  if inActData == nil then
    log(bWriteLog and "[FriendsGathering] OnActivityDataInit inActData is nil")
    return
  end
  if inActData.status == nil then
    log(bWriteLog and "[FriendsGathering] OnActivityDataInit newbie_social_task.status is nil")
  end
  log(bWriteLog and "[FriendsGathering] module_newbie_friends_gathering:OnActivityDataInit")
  log_tree(bWriteLog and "inActData.task_cfg", inActData.task_cfg)
  log_tree(bWriteLog and "inActData.all_task_award", inActData.all_task_award)
  log_tree(bWriteLog and "inActData.status", inActData.status)
  self.task_cfg = inActData.cfg
  self.all_task_award = inActData.all_task_award
  self.task_status = nil
  self.task_status_hash = nil
  local TableUtil = require("common.table_util")
  local num = TableUtil.CountTable(inActData.status)
  if 0 < num then
    self.task_status = prealloctable(num)
    self.task_status_hash = prealloctable(0, num)
    local i = 1
    for k, task_status in pairs(inActData.status) do
      self.task_status[i] = {
        task_id = k,
        task_type = task_status.task_type or 0,
        daily_count = task_status.daily_count or 0
      }
      self.task_status_hash[tostring(k)] = self.task_status[i]
      i = i + 1
    end
    table.sort(self.task_status, TaskSort)
  end
end
function module_newbie_friends_gathering:IsOpen()
  return self.task_status and next(self.task_status)
end
function module_newbie_friends_gathering:ShouldSlapFriendsRecommend()
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "module_newbie_friends_gathering:ShouldSlapFriendsRecommend UI responsiveness testing")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "[FriendsRecommend] ShouldSlapFriendsRecommend")
    return false
  end
  if not friend_recommend_popup_info then
    return false
  end
  log(bWriteLog and string.format("[FriendsRecommend] ShouldSlapFriendsRecommend is_dont_show_all[%s] is_show_today[%s]", tostring(friend_recommend_popup_info.is_dont_show_all), tostring(friend_recommend_popup_info.is_show_today)))
  if friend_recommend_popup_info.is_dont_show_all == false and friend_recommend_popup_info.is_show_today == false then
    return true
  else
    return false
  end
end
function module_newbie_friends_gathering:UpdateTaskStatus(in_task_status)
  if in_task_status == nil then
    return
  end
  local task_id = in_task_status.id
  if self.task_status_hash and self.task_status_hash[tostring(task_id)] then
    local task_status = self.task_status_hash[tostring(task_id)]
    task_status.task_type = in_task_status.task_type or 0
    task_status.daily_count = in_task_status.daily_count or 0
  end
end
function module_newbie_friends_gathering:UpdateAllTaskAward(in_all_task_award)
  self.all_task_award = in_all_task_award
end
function module_newbie_friends_gathering:GetAllTaskAward()
  return self.all_task_award
end
function module_newbie_friends_gathering:GetTaskStatusList()
  return self.task_status
end
function module_newbie_friends_gathering:GetTaskCfg(task_id, task_type)
  if self.task_cfg and self.task_cfg[task_type] then
    return self.task_cfg[task_type][task_id]
  end
  return nil
end
function module_newbie_friends_gathering:GetTaskAward(task_id, task_type)
  local task_cfg = self:GetTaskCfg(task_id, task_type)
  if task_cfg then
    return task_cfg.award
  end
  return nil
end
function module_newbie_friends_gathering:GetTaskTarget(task_id, task_type)
  local task_cfg = self:GetTaskCfg(task_id, task_type)
  if task_cfg then
    return task_cfg.target
  end
  return nil
end
function module_newbie_friends_gathering:GetTaskDailyLimit(task_id, task_type)
  local task_cfg = self:GetTaskCfg(task_id, task_type)
  if task_cfg then
    return task_cfg.task_daily_limit
  end
  return 0
end
function module_newbie_friends_gathering:OnModuleNewbieFriendsRecommend(_, __, params)
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "module_newbie_friends_gathering:OnModuleNewbieFriendsRecommend UI responsiveness testing")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Newbie_Friends_Recommend)
end
function module_newbie_friends_gathering:OnDontShowFriendRecommendRsp(res, result)
  if res == 0 then
    log_tree(bWriteLog and "[FriendsRecommend]OnDontShowFriendRecommendRsp", result)
    friend_recommend_popup_info = result
  else
    log(bWriteLog and "[FriendsRecommend]module_newbie_friends_gathering:OnDontShowFriendRecommendRsp res " .. tostring(res))
    if res == 880224 then
      friend_recommend_popup_info = nil
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleNewbieFriendsGathering = class(CModuleBase, nil, module_newbie_friends_gathering)
return CModuleNewbieFriendsGathering
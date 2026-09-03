local logic_return_activity_level_reward = {}
local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
function logic_return_activity_level_reward:DefineAndResetData()
end
function logic_return_activity_level_reward:_CompareSelectItems(a, b)
  if not a or not b then
    return false
  end
  local itemCfgA = CDataTable.GetTableData("Item", a.itemId)
  local itemCfgB = CDataTable.GetTableData("Item", b.itemId)
  if not itemCfgA or not itemCfgB then
    return a.index < b.index
  end
  local isPackageSlotA = itemCfgA.ItemType == ENUM_ITEM_TYPE.Extra and itemCfgA.ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot
  local isPackageSlotB = itemCfgB.ItemType == ENUM_ITEM_TYPE.Extra and itemCfgB.ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot
  if isPackageSlotA and not isPackageSlotB then
    return true
  elseif not isPackageSlotA and isPackageSlotB then
    return false
  end
  return a.index < b.index
end
function logic_return_activity_level_reward:OnInitialize()
end
function logic_return_activity_level_reward:RegistEvents()
end
function logic_return_activity_level_reward:OnLogin(bReLogin)
end
function logic_return_activity_level_reward:OnLogOut()
end
function logic_return_activity_level_reward:OnPreSwitchGameStatus(preState, nextState)
end
function logic_return_activity_level_reward:OnPostSwitchGameStatus(preState, nextState)
end
function logic_return_activity_level_reward:GetMultChoose1Data(level)
  log_format(bWriteLog and "logic_return_activity_level_reward:GetMultChoose1Data, level:%s", level)
  if not level then
    log_error(bWriteLog and "logic_return_activity_level_reward:GetMultChoose1Data, level is nil")
    return nil
  end
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task or not logic_longline_task.rewardList then
    log_error(bWriteLog and "logic_return_activity_level_reward:GetMultChoose1Data, logic_longline_task or rewardList is nil")
    return nil
  end
  local rewards = logic_longline_task.rewardList[level]
  if not rewards then
    log_warning_format("logic_return_activity_level_reward:GetMultChoose1Data, rewards not found for level:%s", level)
    return nil
  end
  if not rewards.select_items then
    return nil
  end
  if not next(rewards.select_items) then
    return nil
  end
  local allItems = {}
  for k, v in pairs(rewards.select_items) do
    v.itemId = k
    table.insert(allItems, v)
  end
  local selectItems = {}
  for k, v in pairs(allItems) do
    if not selectItems[v.index] then
      selectItems[v.index] = {}
    end
    table.insert(selectItems[v.index], v)
  end
  for i, v in ipairs(selectItems) do
    table.sort(v, function(a, b)
      return self:_CompareSelectItems(a, b)
    end)
  end
  return selectItems
end
function logic_return_activity_level_reward:GetAllMultChoose1Data()
  log_format(bWriteLog and "logic_return_activity_level_reward:GetAllMultChoose1Data")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task or not logic_longline_task.rewardList then
    log_error(bWriteLog and "logic_return_activity_level_reward:GetAllMultChoose1Data, logic_longline_task or rewardList is nil")
    return {}
  end
  local allData = {}
  for level, v in pairs(logic_longline_task.rewardList) do
    local selectItems = self:GetMultChoose1Data(level)
    if selectItems then
      for i, v in ipairs(selectItems) do
        if v[1] and v[1].itemId then
          table.insert(allData, {
            itemId = v[1].itemId,
            level = level,
            valid_hours = v[1].valid_hours
          })
        end
      end
    end
  end
  table.sort(allData, function(a, b)
    local itemCfgA = CDataTable.GetTableData("Item", a.itemId)
    local itemCfgB = CDataTable.GetTableData("Item", b.itemId)
    if not itemCfgA or not itemCfgB then
      return false
    end
    return itemCfgA.ItemType > itemCfgB.ItemType
  end)
  local teamRewardData = self:GetNextTeamReward()
  if teamRewardData then
    for itemId, v in pairs(teamRewardData.team_reward) do
      table.insert(allData, {
        itemId = itemId,
        level = teamRewardData.level,
        valid_hours = v.valid_hours
      })
    end
  end
  log_format(bWriteLog and "logic_return_activity_level_reward:GetAllMultChoose1Data, total count:%s", #allData)
  return allData
end
function logic_return_activity_level_reward:GetRewardStatusByLevel(level)
  log_format(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, level:%s", level)
  local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
  if not level then
    log_error(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, level is nil")
    return CommonItem_Const.Enum_ItemStatus.Not
  end
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local CurrentScore = logic_longline_task.GetTotalScore() or 0
  log_format(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, current score:%s", CurrentScore)
  local RewardStatus
  if logic_longline_task.totalSummaryData and logic_longline_task.totalSummaryData.reward_status and logic_longline_task.totalSummaryData.reward_status[level] then
    RewardStatus = logic_longline_task.totalSummaryData.reward_status[level]
  end
  if not RewardStatus and DataMgr.roleData.back_user_data.level_reward_status and DataMgr.roleData.back_user_data.level_reward_status[level] then
    RewardStatus = DataMgr.roleData.back_user_data.level_reward_status[level]
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local rewardList = logic_return_activity:Get400ARewardItemList()
  local levelData = rewardList[FuncUtil.Clamp(level + 1, 1, #rewardList)]
  if RewardStatus then
    log_format(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, level:%s status:HasGot", level)
    return CommonItem_Const.Enum_ItemStatus.Got
  elseif levelData and CurrentScore >= levelData.start_score then
    log_format(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, level:%s status:CanGet", level)
    return CommonItem_Const.Enum_ItemStatus.Done
  else
    log_format(bWriteLog and "logic_return_activity_level_reward:GetRewardStatusByLevel, level:%s status:Not", level)
    return CommonItem_Const.Enum_ItemStatus.Not
  end
end
function logic_return_activity_level_reward:SelectLevelReward(index, level)
  local makeChoiceList = {}
  makeChoiceList[level] = index
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_select_all_index_req(makeChoiceList):Then(function(err_code, selects)
    if err_code == 0 then
      local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
      logic_longline_task.send_backuser_longline_task_reward_req(logic_longline_task.Enum_Reward.Level, level)
    end
  end)
end
function logic_return_activity_level_reward:GetRewardUIType()
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if not DataMgr.roleData.back_user_data then
    log(bWriteLog and "logic_return_activity_level_reward:GetRewardUIType back_user_data is nil")
    return return_activity_macro.Enum_Reward_UI_Show_Type.NewVersionAGroup
  end
  local returnClientVersion = DataMgr.roleData.back_user_data.back_cli_ver or "4.1.0"
  local version_util = require("client.common.version_util")
  local ClientVersion = "4.2.0"
  if version_util.CompareVersionStandard(returnClientVersion, ClientVersion) == -1 then
    if logic_return_activity:ReturnActivityABTest() then
      return return_activity_macro.Enum_Reward_UI_Show_Type.OldVersionAGroup
    else
      return return_activity_macro.Enum_Reward_UI_Show_Type.OldVersionBGroup
    end
  elseif logic_return_activity:IsMultipleChoicePlan() then
    return return_activity_macro.Enum_Reward_UI_Show_Type.NewVersionAGroup
  else
    return return_activity_macro.Enum_Reward_UI_Show_Type.NewVersionBGroup
  end
end
function logic_return_activity_level_reward:GetAllNormalRewardData()
  log_format(bWriteLog and "logic_return_activity_level_reward:GetAllNormalRewardData")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task or not logic_longline_task.rewardList then
    log_error(bWriteLog and "logic_return_activity_level_reward:GetAllNormalRewardData, logic_longline_task or rewardList is nil")
    return {}
  end
  local allData = {}
  for level, v in pairs(logic_longline_task.rewardList) do
    for itemId, v in pairs(v.items) do
      local itemCfg = CDataTable.GetTableData("Item", itemId)
      if itemCfg and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot then
        table.insert(allData, {
          itemId = itemId,
          level = level,
          valid_hours = v.valid_hours
        })
      end
    end
  end
  local teamRewardData = self:GetNextTeamReward()
  if teamRewardData then
    for itemId, v in pairs(teamRewardData.team_reward) do
      table.insert(allData, {
        itemId = itemId,
        level = teamRewardData.level,
        valid_hours = v.valid_hours
      })
    end
  end
  return allData
end
function logic_return_activity_level_reward:GetNextTeamReward()
  log(bWriteLog and "logic_return_activity_level_reward:GetNextTeamReward. start getting team reward")
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  local rewardList = logic_return_activity:Get400ARewardItemList()
  if not rewardList or #rewardList == 0 then
    return nil
  end
  local foundTeamReward, lastTeamReward
  for _, rewardItem in ipairs(rewardList) do
    if next(rewardItem.team_reward) then
      lastTeamReward = rewardItem
      local bIReceived = logic_longline_task.totalSummaryData and logic_longline_task.totalSummaryData.team_battle_reward_status and logic_longline_task.totalSummaryData.team_battle_reward_status[rewardItem.level]
      if not foundTeamReward and not bIReceived then
        foundTeamReward = rewardItem
      end
    end
  end
  return foundTeamReward or lastTeamReward
end
function logic_return_activity_level_reward:GetNextCanGetSelectLevel()
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task.rewardList then
    return nil
  end
  for level = 1, #logic_longline_task.rewardList do
    if self:IsSelectReward(level) and self:GetRewardStatusByLevel(level) == CommonItem_Const.Enum_ItemStatus.Done then
      return level
    end
  end
  return nil
end
function logic_return_activity_level_reward:GetNextSelectRewardLevel(currentLevel)
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task.rewardList or not currentLevel then
    return nil
  end
  for level = currentLevel + 1, #logic_longline_task.rewardList do
    if self:IsSelectReward(level) and self:GetRewardStatusByLevel(level) == CommonItem_Const.Enum_ItemStatus.Done then
      return level
    end
  end
  return nil
end
function logic_return_activity_level_reward:IsSelectReward(level)
  local selectReward = self:GetMultChoose1Data(level)
  if selectReward and next(selectReward) then
    return true
  end
  return false
end
function logic_return_activity_level_reward:GetLastSelectRewardLevel()
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  if not logic_longline_task.rewardList then
    return nil
  end
  for level = #logic_longline_task.rewardList, 1, -1 do
    if self:IsSelectReward(level) and self:GetRewardStatusByLevel(level) == CommonItem_Const.Enum_ItemStatus.Done then
      return level
    end
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_activity_level_reward = class(CModuleBase, nil, logic_return_activity_level_reward)
return Clogic_return_activity_level_reward
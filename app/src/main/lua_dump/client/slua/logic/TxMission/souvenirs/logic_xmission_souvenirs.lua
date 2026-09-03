local logic_xmission_souvenirs = {}
local logic_newbieguide_config = require("client.slua.logic.home.NewbieGuide.logic_newbieguide_config")
local guideConfig = {
  [1] = {
    step = 1,
    text = 791128,
    dir = logic_newbieguide_config.EDirection.Left,
    widgetName = "LoopScrollBox_1"
  },
  [2] = {
    step = 2,
    text = 791129,
    dir = logic_newbieguide_config.EDirection.Right,
    widgetName = "LoopScrollBox_Souvenirs"
  }
}
local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
function logic_xmission_souvenirs:ctor()
  self.achievementData = nil
  self.reqProfileCDList = nil
  self.fisrtEnterSeasonId = nil
end
function logic_xmission_souvenirs:GetAllSeasonTasks()
  if not self.achievementConfig then
    return {}
  end
  local allSeasonTaskMap = {}
  for seasonId, seasonTaskMap in pairs(self.achievementConfig) do
    if not allSeasonTaskMap[seasonId] then
      allSeasonTaskMap[seasonId] = {}
    end
    for _, taskList in pairs(seasonTaskMap) do
      local showTaskId = self:GetTaskCanShow(taskList)
      if 0 < showTaskId then
        table.insert(allSeasonTaskMap[seasonId], showTaskId)
      end
    end
  end
  local allSeasonTaskList = self:ConvertSeasonTaskMapToList(allSeasonTaskMap)
  return allSeasonTaskList
end
function logic_xmission_souvenirs:GetTaskListForDetail()
  if not self.achievementConfig then
    return {}
  end
  local allSeasonTaskList = {}
  for _, seasonTaskMap in pairs(self.achievementConfig) do
    for _, taskList in pairs(seasonTaskMap) do
      local showTaskId = self:GetTaskCanShow(taskList)
      if 0 < showTaskId then
        table.insert(allSeasonTaskList, showTaskId)
      end
    end
  end
  table.sort(allSeasonTaskList, function(taskIdA, taskIdB)
    local XMAchievementConfigA = CDataTable.GetTableData("XMAchievement", taskIdA)
    local XMAchievementConfigB = CDataTable.GetTableData("XMAchievement", taskIdB)
    if XMAchievementConfigA.start_season_id ~= XMAchievementConfigB.start_season_id then
      return XMAchievementConfigA.start_season_id > XMAchievementConfigB.start_season_id
    else
      return XMAchievementConfigA.position < XMAchievementConfigB.position
    end
  end)
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetTaskListForDetail allSeasonTaskList:", allSeasonTaskList)
  return allSeasonTaskList
end
function logic_xmission_souvenirs:GetRewardedTaskList()
  if not self.achievementConfig then
    return {}
  end
  local seasonRewardedTaskMap = {}
  for seasonId, seasonTaskMap in pairs(self.achievementConfig) do
    if not seasonRewardedTaskMap[seasonId] then
      seasonRewardedTaskMap[seasonId] = {}
    end
    for _, taskList in pairs(seasonTaskMap) do
      local rewardedTaskId = self:GetRewardedTaskCanShow(taskList)
      if 0 < rewardedTaskId then
        table.insert(seasonRewardedTaskMap[seasonId], rewardedTaskId)
      end
    end
  end
  local seasonRewardedTaskList = self:ConvertSeasonTaskMapToList(seasonRewardedTaskMap)
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetRewardedTaskList seasonRewardedTaskList:", seasonRewardedTaskList)
  return seasonRewardedTaskList
end
function logic_xmission_souvenirs:GetFinishedTaskList()
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetFinishedTaskList achievement:", self.achievementData)
  local finishedTaskList = {}
  if not self.achievementData or not self.achievementData.tasks then
    log(bWriteLog and "logic_xmission_souvenirs:GetFinishedTaskList no achievement")
    return finishedTaskList
  end
  for taskId, taskData in pairs(self.achievementData.tasks) do
    if taskData.status == souvenirs_macro.TaskStatus.Finished then
      table.insert(finishedTaskList, taskId)
    end
  end
  table.sort(finishedTaskList, function(taskIdA, taskIdB)
    local XMAchievementConfigA = CDataTable.GetTableData("XMAchievement", taskIdA)
    local XMAchievementConfigB = CDataTable.GetTableData("XMAchievement", taskIdB)
    return XMAchievementConfigA.Id < XMAchievementConfigB.Id
  end)
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetFinishedTaskList finishedTaskList:", finishedTaskList)
  return finishedTaskList
end
function logic_xmission_souvenirs:GetCurFinishValue(taskId)
  log(bWriteLog and "logic_xmission_souvenirs:GetCurFinishValue taskId:" .. tostring(taskId))
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetCurFinishValue achievement:", self.achievementData)
  if not (self.achievementData and self.achievementData.tasks) or not self.achievementData.tasks[taskId] then
    log(bWriteLog and "logic_xmission_souvenirs:GetCurFinishValue no achievement")
    return 0
  end
  local taskData = self.achievementData.tasks[taskId]
  if not taskData.finish_values or not taskData.finish_values[1] then
    log(bWriteLog and "logic_xmission_souvenirs:GetCurFinishValue no finish_value")
    return 0
  end
  local curFinishValue = taskData.finish_values[1]
  log(bWriteLog and "logic_xmission_souvenirs:GetCurFinishValue curFinishValue:" .. tostring(curFinishValue))
  return curFinishValue
end
function logic_xmission_souvenirs:GetTaskStatus(taskId)
  log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus taskId:" .. tostring(taskId))
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus achievement:", self.achievementData)
  if not self.achievementData then
    log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus no achievement, NotFinish")
    return souvenirs_macro.TaskStatus.NotFinish
  end
  if self.achievementData.souvenirs then
    local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
    if not XMAchievementConfig then
      log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus no XMAchievementConfig, NotFinish")
      return souvenirs_macro.TaskStatus.NotFinish
    end
    local award_item_id_1 = XMAchievementConfig.award_item_id_1
    if self.achievementData.souvenirs[award_item_id_1] and self.achievementData.souvenirs[award_item_id_1] > 0 then
      log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus Rewarded")
      return souvenirs_macro.TaskStatus.Rewarded
    end
  end
  if self.achievementData.tasks and self.achievementData.tasks[taskId] then
    log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus server status:" .. tostring(self.achievementData.tasks[taskId].status))
    return self.achievementData.tasks[taskId].status
  end
  log(bWriteLog and "logic_xmission_souvenirs:GetTaskStatus default, NotFinish")
  return souvenirs_macro.TaskStatus.NotFinish
end
function logic_xmission_souvenirs:GetTotalGoldSouvenirCount()
  local totalCount = 0
  if not self.achievementData or not self.achievementData.souvenirs then
    log(bWriteLog and "logic_xmission_souvenirs:GetTotalGoldSouvenirCount no souvenirs")
    return totalCount
  end
  for itemId, itemNum in pairs(self.achievementData.souvenirs) do
    local itemCfg = CDataTable.GetTableData("Item", itemId)
    if itemCfg and itemCfg.ItemQuality == 10 then
      totalCount = totalCount + itemNum
    end
  end
  log(bWriteLog and "logic_xmission_souvenirs:GetTotalGoldSouvenirCount totalCount:" .. tostring(totalCount))
  return totalCount
end
function logic_xmission_souvenirs:GetSouvenirCountByItemID(itemID)
  local totalCount = 0
  if not self.achievementData or not self.achievementData.souvenirs then
    log(bWriteLog and "logic_xmission_souvenirs:GetSouvenirCountByItemID no souvenirs")
    return totalCount
  end
  for itemId, itemNum in pairs(self.achievementData.souvenirs) do
    if itemId == itemID then
      totalCount = totalCount + itemNum
    end
  end
  log(bWriteLog and "logic_xmission_souvenirs:GetSouvenirCountByItemID totalCount:" .. tostring(totalCount))
  return totalCount
end
function logic_xmission_souvenirs:GetPrivacySwitchState()
  if self.achievementData and self.achievementData.souvenir_invisible == true then
    return false
  end
  return true
end
function logic_xmission_souvenirs:ShareItem(itemId)
  if not itemId then
    return
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  local shareCfg = {
    sceneType = 1,
    nItemId = itemId,
    actId = itemId,
    isOld = true,
    campaign = "getItem",
    share_type = ShareBtnTLogShareTypeDefine.Congratulations,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
          }),
    clubShareParams = {
      bShowShareClub = logic_community.CheckItemCanShare(itemId),
      publishFeedType = logic_community.PublishFeedType.GotItem,
      gameScene = logic_community.GameScene.GotItemShare,
          }
  }
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.Congratulations, nil, nil)
  local Util = require("client.slua_ui_framework.util")
  Util.ShowShare(shareCfg, UIManager.UI_Config.XMission_Souvenirs_Share_BG_UIBP, {res_id = itemId})
end
function logic_xmission_souvenirs:IsSouvenirsItem(itemID)
  local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemID)
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Souvenirs then
    return true
  end
  return false
end
function logic_xmission_souvenirs:GetSouvenirsDefaultIcon(itemID)
  local XMAchievementConfig = CDataTable.GetTableDataByFilter("XMAchievement", "award_item_id_1", itemID)
  local preTaskId = self:GetPreTaskID(XMAchievementConfig.id)
  XMAchievementConfig = CDataTable.GetTableData("XMAchievement", preTaskId)
  local ui_util = require("client.common.ui_util")
  if not XMAchievementConfig then
    return ui_util.DefaultCommonIcon
  end
  local defaultIcon = ui_util.GetItemSmallIcon(XMAchievementConfig.award_item_id_1)
  return defaultIcon or ui_util.DefaultCommonIcon
end
function logic_xmission_souvenirs:IsSouvenirsDropItem(itemID)
  local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemID)
  if itemCfg and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Souvenirs_Drop then
    return true
  end
  return false
end
function logic_xmission_souvenirs:GetReqProfileCDList()
  if not self.reqProfileCDList then
    self.reqProfileCDList = {}
  end
  return self.reqProfileCDList
end
function logic_xmission_souvenirs:SetReqProfileCDList(uid)
  if not uid then
    return
  end
  if not self.reqProfileCDList then
    self.reqProfileCDList = {}
  end
  local TimeUtil = require("client.common.time_util")
  self.reqProfileCDList[uid] = TimeUtil.GetServerTimeInSec()
end
function logic_xmission_souvenirs:GetInitialSeasonID()
  local logic_xmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local curSeasonId = logic_xmission_season.GetCurTXSeasonID()
  local souvenirs = self.achievementData and self.achievementData.souvenirs
  if not souvenirs then
    log(bWriteLog and "logic_xmission_souvenirs:GetInitialSeasonID no souvenirs")
    return curSeasonId + 1
  end
  local firstGetSouvenirSeasonId = 99
  local XMAchievement = CDataTable.GetTable("XMAchievement")
  for itemId, _ in pairs(souvenirs) do
    for _, cfg in ipairs(XMAchievement or {}) do
      if cfg.award_item_id_1 == itemId then
        firstGetSouvenirSeasonId = math.min(cfg.start_season_id, firstGetSouvenirSeasonId)
        break
      end
    end
  end
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetInitialSeasonID self.achievementData.souvenirs", souvenirs)
  log(bWriteLog and string.format("logic_xmission_souvenirs:GetInitialSeasonID, firstGetSouvenirSeasonId:%s", firstGetSouvenirSeasonId))
  log(bWriteLog and string.format("logic_xmission_souvenirs:GetInitialSeasonID, self.fisrtEnterSeasonId:%s", self.fisrtEnterSeasonId))
  if not self.fisrtEnterSeasonId then
    return firstGetSouvenirSeasonId
  end
  return math.min(self.fisrtEnterSeasonId, firstGetSouvenirSeasonId)
end
function logic_xmission_souvenirs:GetDropIdsByTaskId(taskId)
  local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
  if not XMAchievementConfig then
    return
  end
  local conds = XMAchievementConfig.conds_1
  if conds == "" then
    return nil
  end
  local StringUtil = require("common.string_util")
  local itemIDs = StringUtil.SplitToNum(conds, ";")
  return itemIDs
end
function logic_xmission_souvenirs:IsHaveDropItemToHandIn(taskId)
  local itemIDs = self:GetDropIdsByTaskId(taskId)
  if not itemIDs then
    return false
  end
  local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  for _, itemID in ipairs(itemIDs) do
    local itemInfo = xMission_Wardrobe_Data.GetItemByItemID(itemID)
    if itemInfo and itemInfo.item_num >= 1 then
      return true
    end
  end
  return false
end
function logic_xmission_souvenirs:HandInDropItem(taskId)
  if not self:IsHaveDropItemToHandIn(taskId) then
    return
  end
  local itemIDs = self:GetDropIdsByTaskId(taskId)
  local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  for _, itemID in ipairs(itemIDs) do
    local itemInfo = xMission_Wardrobe_Data.GetItemByItemID(itemID)
    if itemInfo and itemInfo.item_num >= 1 then
      UIManager.ShowUI(UIManager.UI_Config.xmission_select_quantity, itemInfo, function(count)
        logic_xmission_warpre.SellItem(itemInfo.inst_id, count)
      end, xMission_macro.ENUM_SELECT_UI_TYPE.EnumType_Sell)
    end
  end
end
function logic_xmission_souvenirs:IsTaskHaveHomeRights(taskId)
  local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
  if not XMAchievementConfig then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", XMAchievementConfig.award_item_id_1)
  if not itemCfg then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsHomeStatue(itemCfg.ItemType, itemCfg.ItemSubType) then
    return true
  end
  return false
end
function logic_xmission_souvenirs:GetTaskDataById(taskId)
  return self.achievementData.tasks[taskId]
end
function logic_xmission_souvenirs:GetSouvenirs(uid)
  if uid and uid ~= tonumber(DataMgr.roleData.uid) then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile and profile.metro_souvenirs then
      return profile.metro_souvenirs
    end
    return nil
  end
  if self.achievementData and self.achievementData.souvenirs then
    return self.achievementData.souvenirs
  end
  return DataMgr.roleData.metro_souvenirs
end
function logic_xmission_souvenirs:GetSouvenirsOnlyMaxLevel()
  local tTargetSouvenirs = {}
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  local allSeasonTaskList = logic_xmission_souvenirs:GetAllSeasonTasks()
  for idx, task in ipairs(allSeasonTaskList) do
    for i, taskId in ipairs(task.taskList) do
      local tempTaskId = taskId
      if logic_xmission_souvenirs:IsTaskHaveHomeRights(taskId) then
        tempTaskId = logic_xmission_souvenirs:GetPreTaskID(taskId)
      end
      local curTaskStatus = logic_xmission_souvenirs:GetTaskStatus(tempTaskId)
      local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", tempTaskId)
      if curTaskStatus == souvenirs_macro.TaskStatus.Rewarded then
        table.insert(tTargetSouvenirs, XMAchievementConfig.award_item_id_1)
      end
    end
  end
  return tTargetSouvenirs
end
function logic_xmission_souvenirs:GetSouvenirsByType(uid, type)
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local tSouvenirs
  if uid == tonumber(DataMgr.roleData.uid) then
    tSouvenirs = self:GetSouvenirsOnlyMaxLevel()
  else
    tSouvenirs = self:GetSouvenirs(uid)
  end
  local tTargetSouvenirs = {}
  for _, id in pairs(tSouvenirs) do
    local XMAchievementConfig = CDataTable.GetTableDataByFilter("XMAchievement", "award_item_id_1", id)
    if type == souvenirs_macro.ETSouvenirsType.All or XMAchievementConfig and XMAchievementConfig.ach_type == type then
      table.insert(tTargetSouvenirs, id)
    end
  end
  table.sort(tTargetSouvenirs, function(a, b)
    return b < a
  end)
  return tTargetSouvenirs
end
function logic_xmission_souvenirs:GetSouvenirsTasks(taskId)
  if self.achievementData and self.achievementData.tasks then
    return self.achievementData.tasks
  end
  return nil
end
function logic_xmission_souvenirs:GetOtherSouvenirsOrderMap(uid)
  log(bWriteLog and "logic_xmission_souvenirs:GetOtherSouvenirsOrderMap uid:" .. tostring(uid) .. ", taskId:" .. tostring(taskId))
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "logic_xmission_souvenirs:GetOtherSouvenirsOrderMap no profile")
    return {}
  end
  if not profile.metro_souvenir_display_order then
    log(bWriteLog and "logic_xmission_souvenirs:GetOtherSouvenirsOrderMap no metro_souvenir_display_order")
    return {}
  end
  local TableUtil = require("common.table_util")
  local orderMap = TableUtil.LiteCopy(profile.metro_souvenir_display_order)
  for k, v in pairs(orderMap) do
    local itemId = self:GetSouvenirMaxLevelByItemId(v, uid)
    orderMap[k] = itemId
  end
  return orderMap
end
function logic_xmission_souvenirs:GetSouvenirsOrderMap(uid)
  if uid ~= tonumber(DataMgr.roleData.uid) then
    return self:GetOtherSouvenirsOrderMap(uid)
  end
  local orderMap = {}
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local achievement = logic_xmission_info:GetMetroValueByKey("achievement")
  if achievement and achievement.souvenir_display_order then
    log_tree(bWriteLog and "logic_xmission_souvenirs:GetSouvenirsOrderMap souvenir_display_order", achievement.souvenir_display_order)
    local table_util = require("common.table_util")
    orderMap = table_util.LiteCopy(achievement.souvenir_display_order)
    for k, v in pairs(orderMap) do
      local itemId = self:GetSouvenirMaxLevelByItemId(v, uid)
      orderMap[k] = itemId
    end
  end
  return orderMap
end
function logic_xmission_souvenirs:SetSouvenirsOrderMap(orderMap)
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local achievement = logic_xmission_info:GetMetroValueByKey("achievement")
  if achievement then
    achievement.souvenir_display_order = orderMap
    logic_xmission_info:SetMetroValueByKey("achievement", achievement)
  end
end
function logic_xmission_souvenirs:GetPagesAndSlots(uid)
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  local souvenirs
  if uid == tonumber(DataMgr.roleData.uid) then
    souvenirs = self:GetSouvenirsOnlyMaxLevel()
  else
    souvenirs = self:GetSouvenirsOrderMap(uid)
  end
  if not souvenirs then
    return souvenirs_macro.TCabinetDefaultLimit
  end
  local TableUtil = require("common.table_util")
  local nums = TableUtil.CountTable(souvenirs)
  local x = math.ceil(nums / souvenirs_macro.TCabinetOnePageNum)
  local pages = x + 2
  local slots = pages * souvenirs_macro.TCabinetOnePageNum
  return pages, slots
end
function logic_xmission_souvenirs:GetCabinetSouvenirs(uid, bIsAutoSort, orderMap)
  orderMap = orderMap or self:GetSouvenirsOrderMap(uid)
  if not orderMap then
    return {}
  end
  local pageNum, slotNum = self:GetPagesAndSlots(uid)
  local orderList = {}
  for i = 1, slotNum do
    table.insert(orderList, orderMap[i] or 0)
  end
  if bIsAutoSort then
    local autoOrderList = {}
    for _, v in ipairs(orderList) do
      if v ~= 0 then
        table.insert(autoOrderList, v)
      end
    end
    for i = #autoOrderList + 1, slotNum do
      table.insert(autoOrderList, 0)
    end
    orderList = autoOrderList
  end
  local cabinetList = {}
  for row = 1, slotNum / 3 do
    local rowItems = {}
    for col = 1, 3 do
      table.insert(rowItems, orderList[(row - 1) * 3 + col])
    end
    table.insert(cabinetList, rowItems)
  end
  return cabinetList
end
function logic_xmission_souvenirs:GetCurSeasonSouvenirs()
  local logic_xmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local curSeasonId = logic_xmission_season.GetCurTXSeasonID()
  local configs = CDataTable.GetTableByFilter("XMAchievement", "start_season_id", curSeasonId, "ach_level", 3)
  if configs then
    local souvenirs = {}
    for k, v in pairs(configs) do
      table.insert(souvenirs, {
        itemId = v.award_item_id_1,
        seasonId = v.start_season_id
      })
    end
    return souvenirs
  end
end
function logic_xmission_souvenirs:GetBuffStatus(itemId, uid)
  local souvenirs = self:GetSouvenirs(uid)
  if not souvenirs[itemId] then
    return souvenirs_macro.ETBuffStatus.Lock
  end
  local buffDescCfg = CDataTable.GetTableData("TBuffDescConfig", itemId)
  if buffDescCfg then
    local buffCfg = CDataTable.GetTableData("TBuffConfig", buffDescCfg.BuffId)
    if buffCfg then
      local TimeUtil = require("client.common.time_util")
      if TimeUtil.UnixTimeStrBetween(buffCfg.ValidTime, buffCfg.InvalidTime) == 0 then
        return souvenirs_macro.ETBuffStatus.Vaild
      elseif TimeUtil.UnixTimeStrBetween(buffCfg.ValidTime, buffCfg.InvalidTime) == -1 then
        return souvenirs_macro.ETBuffStatus.Unlock
      else
        return souvenirs_macro.ETBuffStatus.Expired
      end
    end
  end
  return souvenirs_macro.ETBuffStatus.Lock
end
function logic_xmission_souvenirs:GetSouvenirMaxLevelByItemId(itemId, uid)
  local XMAchievementConfig = CDataTable.GetTableDataByFilter("XMAchievement", "award_item_id_1", itemId)
  if not XMAchievementConfig then
    return itemId
  end
  local taskId = XMAchievementConfig.Id
  local taskChain = self:GetTaskChain(taskId)
  if taskChain then
    for level = #taskChain, 1, -1 do
      if level <= 3 then
        if uid == tonumber(DataMgr.roleData.uid) then
          local status = self:GetTaskStatus(taskChain[level])
          if status == souvenirs_macro.TaskStatus.Rewarded then
            return CDataTable.GetTableData("XMAchievement", taskChain[level]).award_item_id_1
          end
        else
          local logic_xmission_friend_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_friend_souvenirs)
          local status = logic_xmission_friend_souvenirs:GetTaskStatus(uid, taskChain[level])
          if status == souvenirs_macro.TaskStatus.Rewarded then
            return CDataTable.GetTableData("XMAchievement", taskChain[level]).award_item_id_1
          end
        end
      end
    end
  else
    return itemId
  end
end
function logic_xmission_souvenirs:IsNeedShowGuide()
  local souvenirs = self:GetSouvenirs()
  if not souvenirs then
    return false
  end
  if not next(souvenirs) then
    return false
  end
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local step = DataMgr.GetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_XMISSION_SOUVENIRS_EDIT, 1)
  if not step then
    return true
  end
  if step <= #guideConfig then
    return true
  end
  return false
end
function logic_xmission_souvenirs:GetGuideStep()
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  local step = DataMgr.GetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_XMISSION_SOUVENIRS_EDIT, 1) or 1
  return step
end
function logic_xmission_souvenirs:GetGuideConfig(step)
  return guideConfig[step]
end
function logic_xmission_souvenirs:SetGuideStep(step)
  local logic_newbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuideValue(logic_newbie.NEWBIE_GUIDE_XMISSION_SOUVENIRS_EDIT, 1, step)
end
function logic_xmission_souvenirs:CheckEditRedDot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew) or {}
  if not next(saveData) then
    return false
  end
  return true
end
function logic_xmission_souvenirs:CheckEditRedDotByType(type)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew) or {}
  if not next(saveData) then
    return false
  end
  return saveData[type]
end
function logic_xmission_souvenirs:AddRedDotByType(type)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew) or {}
  saveData[type] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew)
  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_EDIT_REDDOT_UPDATE)
end
function logic_xmission_souvenirs:RemoveRedDotByType(type)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew) or {}
  if not next(saveData) then
    return
  end
  saveData[type] = nil
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eTCollectGetNew)
  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_EDIT_REDDOT_UPDATE)
end
function logic_xmission_souvenirs:GetTaskIdByItemId(itemId)
  local XMAchievementConfig = CDataTable.GetTableDataByFilter("XMAchievement", "award_item_id_1", itemId)
  if not XMAchievementConfig then
    return
  end
  return XMAchievementConfig.Id
end
function logic_xmission_souvenirs:GetHomeTaskId(taskId)
  local taskChain = self:GetTaskChain(taskId)
  for _, v in ipairs(taskChain) do
    if self:IsTaskHaveHomeRights(v) then
      return v
    end
  end
end
function logic_xmission_souvenirs:GetNextLevelNum(taskId)
  local taskChain = self:GetTaskChain(taskId)
  local curProgressValue = self:GetCurFinishValue(taskChain[#taskChain])
  local XMAchievementConfig = CDataTable.GetTableDataByFilter("XMAchievement", "Id", taskId)
  if XMAchievementConfig then
    local diff = XMAchievementConfig.finish_1 - curProgressValue
    return diff
  end
  return 0
end
function logic_xmission_souvenirs:GetGoldItemIdByTaskId(taskId)
  local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
  if XMAchievementConfig then
    if XMAchievementConfig.ach_level == 1 then
      return CDataTable.GetTableData("XMAchievement", taskId + 2).award_item_id_1
    elseif XMAchievementConfig.ach_level == 2 then
      return CDataTable.GetTableData("XMAchievement", taskId + 1).award_item_id_1
    else
      return CDataTable.GetTableData("XMAchievement", taskId).award_item_id_1
    end
  end
end
function logic_xmission_souvenirs:GetBuffList()
  local config = CDataTable.GetTable("TBuffDescConfig")
  local buffList = {}
  for _, data in pairs(config) do
    local buffStatus = self:GetBuffStatus(data.ItemId)
    if buffStatus == souvenirs_macro.ETBuffStatus.Vaild then
      table.insert(buffList, data)
    end
  end
  return buffList
end
function logic_xmission_souvenirs:InitAchievementData(achievement, first_enter_season_index)
  log_tree(bWriteLog and "logic_xmission_souvenirs:InitAchievementData achievement:", achievement)
  self.achievementData = achievement
  self.fisrtEnterSeasonId = first_enter_season_index
  self:InitAchievementConfig()
end
function logic_xmission_souvenirs:on_metro_achi_task_change_ntfy(ntf_info, reward_list)
  if not ntf_info then
    log(bWriteLog and "logic_xmission_souvenirs:on_metro_achi_task_change_ntfy not ntf_info")
    return
  end
  log_tree(bWriteLog and "logic_xmission_souvenirs:on_metro_achi_task_change_ntfy achievement:", self.achievementData)
  if not self.achievementData or not self.achievementData.tasks then
    log(bWriteLog and "logic_xmission_souvenirs:on_metro_achi_task_change_ntfy not achievement")
    return
  end
  for task_id, v in pairs(ntf_info) do
    local dropItemIds = logic_xmission_souvenirs:GetDropIdsByTaskId(task_id)
    if dropItemIds then
      UIManager.ShowUI(UIManager.UI_Config.Xmission_Souvenirs_Task_Progress_UIBP, ntf_info, reward_list)
      break
    end
  end
  for task_id, task in pairs(ntf_info) do
    local curXMAchievementConfig = CDataTable.GetTableData("XMAchievement", task_id)
    if curXMAchievementConfig and curXMAchievementConfig.ach_level ~= 5 then
      self.achievementData.tasks[task_id] = task
    end
  end
  local logic_xmission_buff = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_buff)
  local buff_sys = logic_xmission_buff:GetBuffData() or {}
  if not buff_sys.buffs then
    buff_sys.buffs = {}
  end
  for resID, _ in pairs(reward_list) do
    local buffDescCfg = CDataTable.GetTableData("TBuffDescConfig", resID)
    if buffDescCfg and not buff_sys.buffs[buffDescCfg.BuffId] then
      buff_sys.buffs[buffDescCfg.BuffId] = 1
    end
  end
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:SetMetroValueByKey("buff_sys", buff_sys)
  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_TASK_CHANGE_NOTIFY)
end
function logic_xmission_souvenirs:on_gm_metro_achi_task_change_ntfy(ntf_info)
  if not ntf_info then
    log(bWriteLog and "logic_xmission_souvenirs:on_gm_metro_achi_task_change_ntfy not ntf_info")
    return
  end
  log_tree(bWriteLog and "logic_xmission_souvenirs:on_gm_metro_achi_task_change_ntfy achievement:", self.achievementData)
  if not self.achievementData or not self.achievementData.tasks then
    log(bWriteLog and "logic_xmission_souvenirs:on_gm_metro_achi_task_change_ntfy not achievement")
    return
  end
  self.achievementData.tasks = {}
  for task_id, task in pairs(ntf_info) do
    self.achievementData.tasks[task_id] = task
  end
  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_TASK_CHANGE_NOTIFY)
end
function logic_xmission_souvenirs:send_metro_ach_reward_req(task_id)
  local TxMissionSouvenirsHandler = require("client.network.Protocol.TxMissionSouvenirsHandler")
  TxMissionSouvenirsHandler.send_metro_ach_reward_req(task_id)
end
function logic_xmission_souvenirs:on_metro_ach_reward_rsp(task_id, awards)
  if self.achievementData and self.achievementData.tasks and self.achievementData.tasks[task_id] then
    self.achievementData.tasks[task_id].status = souvenirs_macro.TaskStatus.Rewarded
  end
  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_ACH_REWARD_RSP, task_id)
  local itemList = {}
  for k, v in pairs(awards) do
    table.insert(itemList, {res_id = k, count = v})
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList)
end
function logic_xmission_souvenirs:on_metro_ach_souvenirs_ntfy(item_id, item_num_after)
  log_tree(bWriteLog and "logic_xmission_souvenirs:on_metro_ach_souvenirs_ntfy achievement:", self.achievementData)
  if not self.achievementData or not self.achievementData.souvenirs then
    log(bWriteLog and "logic_xmission_souvenirs:on_metro_ach_souvenirs_ntfy not achievement")
    return
  end
  self.achievementData.souvenirs[item_id] = item_num_after
end
function logic_xmission_souvenirs:send_metro_set_souvenir_invisible_req()
  local TxMissionSouvenirsHandler = require("client.network.Protocol.TxMissionSouvenirsHandler")
  TxMissionSouvenirsHandler.send_metro_set_souvenir_invisible_req()
end
function logic_xmission_souvenirs:on_metro_set_souvenir_invisible_rsp(invisible)
  if not self.achievementData or not self.achievementData.souvenirs then
    log(bWriteLog and "logic_xmission_souvenirs:on_metro_set_souvenir_invisible_rsp not achievement")
    return
  end
  self.achievementData.souvenir_  EventSystem:postEvent(EVENTTYPE_SOUVENIRS, EVENTID_SOUVENIRS_INVISIBLE_UPDATE)
end
function logic_xmission_souvenirs:GetTaskCanShow(taskList)
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetTaskCanShow taskList:", taskList)
  local showTaskId = 0
  for _, taskId in ipairs(taskList) do
    local curTaskStatus = self:GetTaskStatus(taskId)
    if curTaskStatus == souvenirs_macro.TaskStatus.Finished then
      showTaskId = taskId
      break
    elseif curTaskStatus == souvenirs_macro.TaskStatus.Rewarded then
      if #taskList < 3 then
        return taskList[1]
      else
        showTaskId = taskId
      end
    end
  end
  if showTaskId ~= 0 then
    log(bWriteLog and "logic_xmission_souvenirs:GetTaskCanShow showTaskId:" .. tostring(showTaskId))
    return showTaskId
  elseif self:IsCurSeasonTask(taskList[1]) then
    log(bWriteLog and "logic_xmission_souvenirs:GetTaskCanShow default TaskId:" .. tostring(taskList[1]))
    return taskList[1]
  else
    log(bWriteLog and "logic_xmission_souvenirs:GetTaskCanShow Cannot Show")
    return 0
  end
end
function logic_xmission_souvenirs:GetRewardedTaskCanShow(taskList)
  log_tree(bWriteLog and "logic_xmission_souvenirs:GetRewardedTaskCanShow taskList:", taskList)
  local rewardedTaskId = 0
  for _, taskId in ipairs(taskList) do
    local curTaskStatus = self:GetTaskStatus(taskId)
    if curTaskStatus == souvenirs_macro.TaskStatus.Rewarded then
      rewardedTaskId = taskId
    end
  end
  log(bWriteLog and "logic_xmission_souvenirs:GetRewardedTaskCanShow rewardedTaskId:" .. tostring(rewardedTaskId))
  return rewardedTaskId
end
function logic_xmission_souvenirs:IsCurSeasonTask(taskId)
  log(bWriteLog and "logic_xmission_souvenirs:IsCurSeasonTask taskId:" .. tostring(taskId))
  local logic_xmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local curSeasonId = logic_xmission_season.GetCurTXSeasonID()
  local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
  return XMAchievementConfig.start_season_id == curSeasonId
end
local class = require("class")
local CModuleBase = require("client.slua.logic.TxMission.souvenirs.logic_xmission_souvenirs_base")
local Clogic_xmission_souvenirs = class(CModuleBase, nil, logic_xmission_souvenirs)
return Clogic_xmission_souvenirs
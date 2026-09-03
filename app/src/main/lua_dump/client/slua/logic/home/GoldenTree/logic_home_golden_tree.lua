local data_config_marco = require("client.logic.data.data_config_marco")
local logic_home_golden_tree = {}
local C_ManorTreeConfigName = data_config_marco.manor_tree_table
local C_ManroTreeLevelConfigName = data_config_marco.manor_tree_level_table
local OneHourSeconds = 3600
function logic_home_golden_tree:DefineAndResetData()
  self.manor_tree_config = nil
  self.manor_tree_level_table = nil
  self.planting_plat_data_list = nil
  self.manor_tree_collect_limit = nil
  self.manor_tree_water_limit = nil
  self.manor_tree_feed_limit = nil
  self.tree_list = nil
end
function logic_home_golden_tree:OnInitialize()
end
function logic_home_golden_tree:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_home_golden_tree:OnPreSwitchGameStatus(_, next)
  if next == GameStatus.Lobby then
    self:ClearGoldenTreeData()
  end
end
function logic_home_golden_tree:GetPlantingPlatData(manor_key_id)
  if not manor_key_id or not self.planting_plat_data_list then
    log(bWriteLog and "logic_home_golden_tree:GetPlantingPlatData manor_key_id or self.planting_plat_data_list is nil")
    return nil
  end
  return self.planting_plat_data_list[manor_key_id]
end
function logic_home_golden_tree:SetPlantingPlatData(manor_key_id, planting_plat_data)
  log(bWriteLog and "logic_home_golden_tree:SetPlantingPlatData manor_key_id = " .. tostring(manor_key_id))
  if not manor_key_id or not planting_plat_data then
    log(bWriteLog and "logic_home_golden_tree:SetPlantingPlatData manor_key_id or planting_plat_data is nil")
    return
  end
  self.planting_plat_data_list = self.planting_plat_data_list or {}
  self.planting_plat_data_list[manor_key_id] = planting_plat_data
end
function logic_home_golden_tree:SetPlantingCollectInfo(manor_tree_collect_limit)
  log_tree("logic_home_golden_tree:SetPlantingCollectInfo manor_tree_collect_limit", manor_tree_collect_limit)
  if not manor_tree_collect_limit then
    log(bWriteLog and "logic_home_golden_tree:SetPlantingCollectInfo manor_tree_collect_limit is nil")
    return
  end
  self.end
function logic_home_golden_tree:SetPlantingWaterInfo(manor_tree_water_limit)
  log_tree("logic_home_golden_tree:SetPlantingWaterInfo manor_tree_water_limit", manor_tree_water_limit)
  if not manor_tree_water_limit then
    log(bWriteLog and "logic_home_golden_tree:SetPlantingWaterInfo manor_tree_water_limit is nil")
    return
  end
  self.end
function logic_home_golden_tree:UpdateWaterInfo(manor_key_id)
  if not self.manor_tree_water_limit then
    log_warning("logic_home_golden_tree:UpdateWaterInfo not self.manor_tree_water_limit")
    return
  end
  if not self.manor_tree_water_limit.water_daily_cnt then
    self.manor_tree_water_limit.water_daily_cnt = 0
  end
  self.manor_tree_water_limit.water_daily_cnt = self.manor_tree_water_limit.water_daily_cnt + 1
  if not self.manor_tree_water_limit.daily_ulist then
    self.manor_tree_water_limit.daily_ulist = {}
  end
  self.manor_tree_water_limit.daily_ulist[manor_key_id] = true
end
function logic_home_golden_tree:UpdateFeedInfo(manor_key_id)
  if not self.manor_tree_feed_limit then
    log_warning("logic_home_golden_tree:UpdateWaterInfo not self.manor_tree_feed_limit")
    return
  end
  if not self.manor_tree_feed_limit.feed_daily_cnt then
    self.manor_tree_feed_limit.feed_daily_cnt = 0
  end
  self.manor_tree_feed_limit.feed_daily_cnt = self.manor_tree_feed_limit.feed_daily_cnt + 1
  if not self.manor_tree_feed_limit.daily_ulist then
    self.manor_tree_feed_limit.daily_ulist = {}
  end
  self.manor_tree_feed_limit.daily_ulist[manor_key_id] = true
end
function logic_home_golden_tree:UpdateCurTreeExpAndLevel(plat_idx, tree_id, new_exp, new_level, bIsSelfTree)
  log(bWriteLog and "logic_home_golden_tree:UpdateCurTreeExpAndLevel new_level = " .. tostring(new_level) .. ", new_exp = " .. tostring(new_exp) .. ", bIsSelfTree = " .. tostring(bIsSelfTree))
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  if not manor_key_id or not self.planting_plat_data_list then
    log(bWriteLog and "logic_home_golden_tree:UpdateCurTreeExpAndLevel manor_key_id or self.planting_plat_data_list is nil")
    return nil
  end
  self.planting_plat_data_list[manor_key_id] = self.planting_plat_data_list[manor_key_id] or {}
  if not self.planting_plat_data_list[manor_key_id].planting_plat_list or not self.planting_plat_data_list[manor_key_id].planting_plat_list[plat_idx] then
    log(bWriteLog and "logic_home_golden_tree:UpdateCurTreeExpAndLevel invalid planting_plat_data")
  else
    self.planting_plat_data_list[manor_key_id].planting_plat_list[plat_idx].exp = new_exp
    self.planting_plat_data_list[manor_key_id].planting_plat_list[plat_idx].level = new_level
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local bIsJointHome = logic_home_joint.IsManorJointUID(manor_key_id)
  if not bIsJointHome or bIsSelfTree then
    self.planting_plat_data_list[manor_key_id].tree_level_infos = self.planting_plat_data_list[manor_key_id].tree_level_infos or {}
    self.planting_plat_data_list[manor_key_id].tree_level_infos[tree_id] = {exp = new_exp, level = new_level}
  end
end
function logic_home_golden_tree:SetPlantingFeedInfo(manor_tree_feed_limit)
  log_tree("logic_home_golden_tree:SetPlantingFeedInfo manor_tree_feed_limit", manor_tree_feed_limit)
  if not manor_tree_feed_limit then
    log(bWriteLog and "logic_home_golden_tree:SetPlantingFeedInfo manor_tree_feed_limit is nil")
    return
  end
  self.end
function logic_home_golden_tree:GetFeedPrice()
  if not self.manor_tree_feed_limit then
    log_warning("logic_home_golden_tree:GetFeedPrice manor_tree_feed_limit not self.manor_tree_feed_limit")
    return 0
  end
  return self.manor_tree_feed_limit.feed_price or 0
end
function logic_home_golden_tree:OnNextDayZeroCome()
  log(bWriteLog and "logic_home_golden_tree:OnNextDayZeroCome")
  if self.manor_tree_collect_limit then
    self.manor_tree_collect_limit.daily_collect_cnt = 0
    self.manor_tree_collect_limit.daily_collect_total = 0
  end
  if self.manor_tree_water_limit then
    self.manor_tree_water_limit.water_daily_cnt = 0
    self.manor_tree_water_limit.daily_ulist = {}
  end
  if self.manor_tree_feed_limit then
    self.manor_tree_feed_limit.feed_daily_cnt = 0
    self.manor_tree_feed_limit.daily_ulist = {}
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_GOLDENTREE_REFRESH_NEXT_DAY)
end
function logic_home_golden_tree:AddCollectTime(err_code, uid, item_list)
  if err_code ~= 0 then
    return
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_home_golden_tree:AddCollectTime is self")
    return
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local jointInfo = logic_home_joint:GetHomeJointInfo()
  if jointInfo and jointInfo.joint_id and jointInfo.joint_id == uid then
    log(bWriteLog and "logic_home_golden_tree:AddCollectTime is self joint home")
    return
  end
  if not self.manor_tree_collect_limit or not self.manor_tree_collect_limit.daily_collect_cnt then
    return
  end
  if not self.manor_tree_collect_limit.daily_collect_cnt then
    self.manor_tree_collect_limit.daily_collect_cnt = 0
  end
  self.manor_tree_collect_limit.daily_collect_cnt = self.manor_tree_collect_limit.daily_collect_cnt + 1
  if not item_list then
    return
  end
  local item_list_data = slua.LuaArchiverDecode(LuaStateWrapper, item_list)
  if not item_list_data or not item_list_data.count then
    return
  end
  if not self.manor_tree_collect_limit.daily_collect_total then
    self.manor_tree_collect_limit.daily_collect_total = 0
  end
  self.manor_tree_collect_limit.daily_collect_total = self.manor_tree_collect_limit.daily_collect_total + item_list_data.count
end
function logic_home_golden_tree:GetCollectCntAndLimitCnt()
  if not self.manor_tree_collect_limit then
    log_warning("logic_home_golden_tree:GetWaterCntAndLimitCnt not self.manor_tree_collect_limit")
    return 0, 0
  end
  return self.manor_tree_collect_limit.daily_collect_cnt or 0, self.manor_tree_collect_limit.daily_limit_cnt or 0
end
function logic_home_golden_tree:GetCollectState(planting_plat_list, isSelf)
  local home_collection_macro = require("client.slua.logic.home.Collection.home_collection_macro")
  if not home_collection_macro or not home_collection_macro.Enum_GoldenTree_State then
    return -1
  end
  local enums = home_collection_macro.Enum_GoldenTree_State
  local limitData = self.manor_tree_collect_limit
  if not (limitData and limitData.daily_collect_cnt and limitData.daily_limit_cnt and limitData.daily_limit_total) or not limitData.daily_collect_total then
    return enums.ERR
  end
  local canCollect = self:CheckTreeCanCollectCoin(planting_plat_list, isSelf)
  if not canCollect then
    return enums.NOT
  elseif isSelf then
    return enums.VALID
  elseif limitData.daily_collect_total < limitData.daily_limit_total and limitData.daily_collect_cnt < limitData.daily_limit_cnt then
    return enums.VALID
  else
    return enums.LIMIT
  end
end
function logic_home_golden_tree:GetWaterCntAndLimitCnt()
  if not self.manor_tree_water_limit then
    log_warning("logic_home_golden_tree:GetWaterCntAndLimitCnt not self.manor_tree_water_limit")
    return 0, 0
  end
  return self.manor_tree_water_limit.water_daily_cnt or 0, self.manor_tree_water_limit.daily_limit_cnt or 0
end
function logic_home_golden_tree:CheckHasWatered()
  if not self.manor_tree_water_limit or not self.manor_tree_water_limit.daily_ulist then
    return false
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manorUID = logic_home_entry:GetManorKey()
  if self.manor_tree_water_limit.daily_ulist[manorUID] then
    return true
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, uid in pairs(memberList) do
    if self.manor_tree_water_limit.daily_ulist[uid] then
      return true
    end
  end
  return false
end
function logic_home_golden_tree:GetWaterStatus()
  local golden_tree_macro = require("client.slua.logic.home.GoldenTree.golden_tree_macro")
  if not self.manor_tree_water_limit then
    log_warning("logic_home_golden_tree:GetWaterStatus not self.manor_tree_water_limit")
    return golden_tree_macro.ENUM_HELP_STATUS.Forbid
  end
  if self.manor_tree_water_limit.water_daily_cnt >= self.manor_tree_water_limit.daily_limit_cnt then
    log(bWriteLog and "logic_home_golden_tree:GetWaterStatus return Forbid")
    return golden_tree_macro.ENUM_HELP_STATUS.Forbid
  elseif self:CheckHasWatered() then
    log(bWriteLog and "logic_home_golden_tree:GetWaterStatus return Limit")
    return golden_tree_macro.ENUM_HELP_STATUS.Limit
  else
    log(bWriteLog and "logic_home_golden_tree:GetWaterStatus return Valid")
    return golden_tree_macro.ENUM_HELP_STATUS.Valid
  end
end
function logic_home_golden_tree:GetFeedCntAndLimitCnt()
  if not self.manor_tree_feed_limit then
    log_warning("logic_home_golden_tree:GetFeedCntAndLimitCnt not self.manor_tree_feed_limit")
    return 0, 0
  end
  return self.manor_tree_feed_limit.feed_daily_cnt or 0, self.manor_tree_feed_limit.daily_limit_cnt or 0
end
function logic_home_golden_tree:CheckHasFed()
  if not self.manor_tree_feed_limit or not self.manor_tree_feed_limit.daily_ulist then
    return false
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manorUID = logic_home_entry:GetManorKey()
  if self.manor_tree_feed_limit.daily_ulist[manorUID] then
    return true
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  for _, uid in pairs(memberList) do
    if self.manor_tree_feed_limit.daily_ulist[uid] then
      return true
    end
  end
  return false
end
function logic_home_golden_tree:GetFeedStatus()
  local golden_tree_macro = require("client.slua.logic.home.GoldenTree.golden_tree_macro")
  if not self.manor_tree_feed_limit then
    log_warning("logic_home_golden_tree:GetFeedStatus not self.manor_tree_feed_limit")
    return golden_tree_macro.ENUM_HELP_STATUS.Forbid
  end
  if self.manor_tree_feed_limit.feed_daily_cnt >= self.manor_tree_feed_limit.daily_limit_cnt then
    log(bWriteLog and "logic_home_golden_tree:GetFeedStatus return Forbid")
    return golden_tree_macro.ENUM_HELP_STATUS.Forbid
  elseif self:CheckHasFed() then
    log(bWriteLog and "logic_home_golden_tree:GetFeedStatus return Limit")
    return golden_tree_macro.ENUM_HELP_STATUS.Limit
  else
    log(bWriteLog and "logic_home_golden_tree:GetFeedStatus return Valid")
    return golden_tree_macro.ENUM_HELP_STATUS.Valid
  end
end
function logic_home_golden_tree:SetWaterAndFeedExp(waterExp, feedExp)
  self.  self.end
function logic_home_golden_tree:GetWaterAndFeedExp()
  return self.waterExp or 0, self.feedExp or 0
end
function logic_home_golden_tree:ClearPlantingPlatData(manor_key_id)
  if not manor_key_id then
    log(bWriteLog and "logic_home_golden_tree:ClearPlantingPlatData manor_key_id is nil")
    return
  end
  if self.planting_plat_data_list and self.planting_plat_data_list[manor_key_id] then
    self.planting_plat_data_list[manor_key_id] = nil
  end
end
function logic_home_golden_tree:GetOneGoldenTreeConfig(treeItemId)
  if not treeItemId then
    log(bWriteLog and "logic_home_golden_tree:GetOneGoldenTreeConfig no treeItemId")
    return
  end
  if not self.manor_tree_config then
    log(bWriteLog and "logic_home_golden_tree:GetOneGoldenTreeConfig no manor_tree_config")
    return
  end
  return self.manor_tree_config[treeItemId]
end
function logic_home_golden_tree:GetCurPlantingTreeLevel(plat_idx)
  log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeLevel")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local treeData = self:GetPlantingPlatData(manor_key_id)
  if not treeData then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeLevel not treeData")
    return 1
  end
  local plantingData = treeData.planting_plat_list and treeData.planting_plat_list[plat_idx]
  if not plantingData or not plantingData.tree_id then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeLevel no planting tree")
    return 1
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  if 1 < #memberList then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeLevel joint home plantingData.level = " .. tostring(plantingData.level))
    return plantingData.level or 1
  else
    return self:GetMyTreeLevelByItemID(plantingData.tree_id)
  end
end
function logic_home_golden_tree:GetCurPlantingTreeExp(plat_idx)
  log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeExp")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local treeData = self:GetPlantingPlatData(manor_key_id)
  if not treeData then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeExp not treeData")
    return 0
  end
  local plantingData = treeData.planting_plat_list and treeData.planting_plat_list[plat_idx]
  if not plantingData or not plantingData.tree_id then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeExp no planting tree")
    return 0
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local memberList = logic_home_joint:GetMemberList()
  if 1 < #memberList then
    log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeExp joint home plantingData.exp = " .. tostring(plantingData.exp))
    return plantingData.exp or 0
  else
    if not treeData.tree_level_infos or not treeData.tree_level_infos[plantingData.tree_id] then
      log(bWriteLog and "logic_home_golden_tree:GetCurPlantingTreeExp not tree_level_infos, plantingData.tree_id = " .. tostring(plantingData.tree_id))
      return 0
    end
    return treeData.tree_level_infos[plantingData.tree_id].exp or 0
  end
end
function logic_home_golden_tree:GetMyTreeLevelByItemID(treeItemId)
  log(bWriteLog and "logic_home_golden_tree:GetMyTreeLevelByItemID treeItemId = " .. tostring(treeItemId))
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local manor_key_id = logic_home_entry:GetManorKey()
  local treeData = self:GetPlantingPlatData(manor_key_id)
  if not (treeData and treeData.tree_level_infos) or not treeData.tree_level_infos[treeItemId] then
    log(bWriteLog and "logic_home_golden_tree:GetMyTreeLevelByItemID not tree_level_infos, treeItemId = " .. tostring(treeItemId))
    return 1
  else
    return treeData.tree_level_infos[treeItemId].level or 1
  end
end
function logic_home_golden_tree:GetTreeLevelConfig(level)
  if not level or level <= 0 then
    log(bWriteLog and "logic_home_golden_tree:GetTreeLevelConfig invalid level")
    return 0, 0, 0
  end
  if not self.manor_tree_level_table or not self.manor_tree_level_table[level] then
    log(bWriteLog and "logic_home_golden_tree:GetTreeLevelConfig not self.manor_tree_level_table[level], level = " .. tostring(level))
    return 0, 0, 0
  end
  local levelConfig = self.manor_tree_level_table[level]
  return levelConfig.addition_hour_ratio, levelConfig.addition_total_ratio, levelConfig.addition_collect_ratio
end
function logic_home_golden_tree:CheckIsHighestLevel(level)
  if not self.manor_tree_level_table or not self.manor_tree_level_table[level + 1] then
    log(bWriteLog and "logic_home_golden_tree:CheckIsHighestLevel not self.manor_tree_level_table[level + 1], level = " .. tostring(level))
    return true
  end
  return false
end
function logic_home_golden_tree:CheckAndGetTimeToCollectCoin(plantingPlatInfo)
  if not plantingPlatInfo then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin no platIndex")
    return false, -1
  end
  if not plantingPlatInfo.fri_available_time then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin 2")
    return false, -1
  end
  local timeToCollect = plantingPlatInfo.fri_available_time
  local serverTime = FuncUtil.GetServerTimeInSec()
  if timeToCollect > serverTime then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin 3")
    return false, timeToCollect - serverTime
  end
  return true, 0
end
function logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self(plantingPlatInfo)
  if not plantingPlatInfo then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self no platIndex")
    return false, -1
  end
  if plantingPlatInfo.profit_val and plantingPlatInfo.profit_val > 0 then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self 1")
    return true, 0
  end
  if not plantingPlatInfo.update_time or not plantingPlatInfo.surplus_interval then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self 2")
    return false, -1
  end
  local timeToCollect = plantingPlatInfo.update_time + (OneHourSeconds - plantingPlatInfo.surplus_interval)
  local serverTime = FuncUtil.GetServerTimeInSec()
  if timeToCollect <= serverTime then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self 3")
    return true, 0
  end
  log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Self 4")
  return false, timeToCollect - serverTime
end
function logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Friend(plantingPlatInfo)
  if not plantingPlatInfo or not plantingPlatInfo.fri_available_time then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Friend no platIndex")
    return false, -1
  end
  local serverTime = FuncUtil.GetServerTimeInSec()
  if serverTime >= plantingPlatInfo.fri_available_time then
    log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Friend 1")
    return true, 0
  end
  log(bWriteLog and "logic_home_golden_tree:CheckAndGetTimeToCollectCoin_Friend 2")
  return false, plantingPlatInfo.fri_available_time - serverTime
end
function logic_home_golden_tree:IsFriendOrSelf(uid)
  if not uid then
    return false
  end
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  return uid == tonumber(DataMgr.roleData.uid) or FriendSystem.IsMyFriend(uid)
end
function logic_home_golden_tree:CheckTreeCanCollectCoin(planting_plat_list)
  if not planting_plat_list then
    log(bWriteLog and "logic_home_golden_tree:CheckTreeCanCollectCoin invalid profile")
    return false
  end
  for _, plantingPlatInfo in ipairs(planting_plat_list) do
    if self:CheckAndGetTimeToCollectCoin(plantingPlatInfo) then
      log(bWriteLog and "logic_home_golden_tree:CheckTreeCanCollectCoin true")
      return true
    end
  end
  log(bWriteLog and "logic_home_golden_tree:CheckTreeCanCollectCoin false")
  return false
end
function logic_home_golden_tree:GetShowTabConfig()
  local golden_tree_macro = require("client.slua.logic.home.GoldenTree.golden_tree_macro")
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  if not logic_home_entry:IsSelfOwner() then
    return {
      [1] = {
        activePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_HelpingHand_XuanZhong_png.Home_Tab_Icon_HelpingHand_XuanZhong_png",
        inactivePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_HelpingHand_png.Home_Tab_Icon_HelpingHand_png",
        type = golden_tree_macro.ENUM_TAB_TYPE.Help
      }
    }
  else
    return {
      [1] = {
        activePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_Pluck_XuanZhong_png.Home_Tab_Icon_Pluck_XuanZhong_png",
        inactivePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_Pluck_png.Home_Tab_Icon_Pluck_png",
        type = golden_tree_macro.ENUM_TAB_TYPE.Collect
      },
      [2] = {
        activePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_HelpingHand_XuanZhong_png.Home_Tab_Icon_HelpingHand_XuanZhong_png",
        inactivePath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/Home_Tab_Icon_HelpingHand_png.Home_Tab_Icon_HelpingHand_png",
        type = golden_tree_macro.ENUM_TAB_TYPE.Help
      }
    }
  end
end
function logic_home_golden_tree:GetGoldenTreeConfig()
  return self.manor_tree_config
end
function logic_home_golden_tree:GetGoldenTreeLevelConfig()
  return self.manor_tree_level_table
end
function logic_home_golden_tree:ReqGoldenTreeConfig()
  if self.manor_tree_config and self.manor_tree_level_table then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GOLDENTREE_CONFIG_RSP)
    return
  end
  local on_req = function(table_name, table_data)
    if table_name ~= C_ManorTreeConfigName or not table_data then
      return
    end
    log_tree("logic_home_golden_tree:ReqGoldenTreeConfig manor_tree_config", table_data)
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    BasicDataServerTable:GetOrReqData(C_ManroTreeLevelConfigName, function(tableName, tableData)
      log_tree("logic_home_golden_tree:ReqGoldenTreeConfig manor_tree_level_table", tableData)
      self.manor_tree_config = table_data
      self.manor_tree_level_table = tableData
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GOLDENTREE_CONFIG_RSP)
    end)
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(C_ManorTreeConfigName, on_req)
end
function logic_home_golden_tree:ClearGoldenTreeData()
  self.planting_plat_data_list = nil
end
function logic_home_golden_tree:ShowGoldenTreeProfitTips(planting_plat_list, widget)
  if not planting_plat_list then
    log(bWriteLog and "logic_home_golden_tree:ShowGoldenTreeProfitTips invalid profile")
    return
  end
  if not slua.isValid(widget) then
    log(bWriteLog and "logic_home_golden_tree:ShowGoldenTreeProfitTips invalid widget")
    return
  end
  local manor_tree_config = self:GetGoldenTreeConfig()
  if not manor_tree_config then
    log(bWriteLog and "logic_home_golden_tree:ShowGoldenTreeProfitTips invalid manor_tree_config")
    return
  end
  local totalProfit, totalMaxProfit, totalProfitPerHour = self:CalculateTotalProfitData(planting_plat_list)
  UIManager.ShowUI(UIManager.UI_Config.Home_GoldenTree_Tips_UIBP, widget, totalProfit, totalMaxProfit, totalProfitPerHour)
end
function logic_home_golden_tree:GetTreeItemCount(itemId)
  if not self.tree_list then
    log(bWriteLog and "logic_home_golden_tree:GetTreeItemCount not self.tree_list")
    return 0
  end
  return self.tree_list[itemId] or 0
end
function logic_home_golden_tree:GetTreeList()
  log(bWriteLog and "logic_home_golden_tree:GetTreeList")
  return self.tree_list
end
function logic_home_golden_tree:ProcTreeListRsp(tree_list)
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_GOLDENTREE_TREE_LIST_RSP)
end
function logic_home_golden_tree:ProcNewTreeNotify(resid, cnt)
  if not resid or not cnt then
    return
  end
  self.tree_list = self.tree_list or {}
  self.tree_list[resid] = cnt
  EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_PLANPH_GOLDENTREE_COUNT_NOTIFY, resid, cnt)
end
function logic_home_golden_tree:CalculateTotalProfitData(planting_plat_list)
  if not planting_plat_list then
    return 0, 0, 0
  end
  local manor_tree_config = self:GetGoldenTreeConfig()
  if not manor_tree_config then
    return 0, 0, 0
  end
  local totalProfit = 0
  local totalMaxProfit = 0
  local totalProfitPerHour = 0
  for _, plantingPlatInfo in ipairs(planting_plat_list) do
    local profit, maxProfit, profitPerHour, fri_collect_commission = self:CalculateOneTreeProfitData(plantingPlatInfo)
    totalProfit = totalProfit + profit
    totalMaxProfit = totalMaxProfit + maxProfit
    totalProfitPerHour = totalProfitPerHour + profitPerHour
  end
  log(bWriteLog and "logic_home_golden_tree:CalculateTotalProfitData totalProfit:" .. tostring(totalProfit) .. " totalMaxProfit:" .. tostring(totalMaxProfit) .. " totalProfitPerHour:" .. tostring(totalProfitPerHour))
  return totalProfit, totalMaxProfit, totalProfitPerHour
end
function logic_home_golden_tree:CalculateOneTreeProfitData(onePlantingPlatData)
  if not (onePlantingPlatData and onePlantingPlatData.tree_id) or not onePlantingPlatData.update_time then
    log(bWriteLog and "logic_home_golden_tree:CalculateOneTreeProfitData invalid onePlantingPlatData")
    return 0, 0, 0, 0
  end
  local manor_tree_config = self:GetGoldenTreeConfig()
  if not manor_tree_config or not manor_tree_config[onePlantingPlatData.tree_id] then
    log(bWriteLog and "logic_home_golden_tree:CalculateOneTreeProfitData invalid manor_tree_config")
    return 0, 0, 0, 0
  end
  local curTreeLevel
  if onePlantingPlatData.level then
    curTreeLevel = onePlantingPlatData.level
    log(bWriteLog and "logic_home_golden_tree:CalculateOneTreeProfitData onePlantingPlatData.level = " .. tostring(onePlantingPlatData.level))
  else
    curTreeLevel = self:GetMyTreeLevelByItemID(onePlantingPlatData.tree_id)
    log(bWriteLog and "logic_home_golden_tree:CalculateOneTreeProfitData curTreeLevel = " .. tostring(curTreeLevel))
  end
  local hourRatio, totalRatio, collectRatio = self:GetTreeLevelConfig(curTreeLevel)
  local treeCfg = manor_tree_config[onePlantingPlatData.tree_id]
  local profit_per_hour = treeCfg.profit_per_hour or 0
  profit_per_hour = math.ceil(profit_per_hour * (100 + hourRatio) / 100)
  local profit_max_val = treeCfg.profit_max_val or 0
  profit_max_val = math.ceil(profit_max_val * (100 + totalRatio) / 100)
  local fri_collect_commission = treeCfg.fri_collect_commission or 0
  fri_collect_commission = fri_collect_commission * (100 + collectRatio) / 100
  local profit = onePlantingPlatData.profit_val or 0
  local update_time = onePlantingPlatData.update_time
  local surplus_interval = onePlantingPlatData.surplus_interval or 0
  local serverTime = FuncUtil.GetServerTimeInSec()
  local timeToCollect = onePlantingPlatData.fri_available_time or 0
  if serverTime >= timeToCollect then
    local extraProfit = math.floor((serverTime - update_time + surplus_interval) / OneHourSeconds) * profit_per_hour
    profit = profit + extraProfit
  end
  if profit_max_val < profit then
    profit = profit_max_val
  end
  log(bWriteLog and "logic_home_golden_tree:CalculateOneTreeProfitData profit:" .. tostring(profit))
  return profit, profit_max_val, profit_per_hour, fri_collect_commission
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_home_golden_tree)
return CModuleTemplate
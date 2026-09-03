local collect_module = {}
local TableUtil = require("common.table_util")
local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
local tabId2awardName = collect_cfg.Index2AwardName
local local local local local NMaxScore = math.huge
local NMaxLevel = 100
local NMaxDan = 100
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local bJk = PublishRegionMacros.IsJapanOrKorea()
local bBlue = PublishRegionMacros.IsBLUEHOLE()
local SplitCollectTableName = {
  CollectThemeAwardCfg = true,
  CollectThemeAwardCfgJK = true,
  CollectSeasonLevel = true,
  CollectSeasonLevelJK = true,
  CollectBadge = true,
  CollectGunTypeCfg = true,
  CollectValitTimeCfg = true,
  CareerPointsInstructions = true,
  CareerPointsInstructionsJP = true,
  CareerPointsInstructionsKR = true,
  PointsInstructionsJumpConfig = true,
  PointsInstructionsJumpConfigJP = true,
  PointsInstructionsJumpConfigKR = true,
  RankPointsInstructions = true,
  RankPointsInstructionsJP = true,
  RankPointsInstructionsKR = true
}
local E_ColCfgMode = {
  Def = 1,
  JK = 2,
  DifJK = 3
}
function collect_module:CanShowCollect(profile)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    log(bWriteLog and string.format("collect_module:CanShowCollect.  false"))
    return false
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not PufferManager.CheckDownloadEnvironment(RoleInfoMainSystem.C_Check_Asset_Path) then
    return false
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  return collect_privacy_module:CheckCollectPrivacy(profile)
end
function collect_module:DefineAndResetData()
  self.  self.OPEN_COLLECT_DOWNLOAD_MARK = true
  self.curSeason_id = nil
  log_warning(bWriteLog and "  collect_module:DefineAndResetData.  ")
  self.ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  self.is_idle_time = false
  self.collect_data = nil
  self.rankUrl = nil
  self.nUid = 0
  self.curLevels = {1, 0}
  self.itemTb = {}
  self.item2Score = {}
  self.  self._nLikeCount = 0
  self:InitCollectItemData()
end
function collect_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.OnSeasonChangeEvent, self)
end
function collect_module:DataHasBeenRequested()
  return self.collect_data ~= nil
end
function collect_module:OnPreSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting then
    if not GameStatus.IsInMainCity() and not GameStatus.IsCollectionHallMode() then
      self.is_idle_time = false
      self.collect_data = nil
      self.rankUrl = nil
      self.nUid = 0
      self.curLevels = {1, 0}
      self.itemTb = {}
      self.item2Score = {}
    end
    if self.updateTimer then
      self:RemoveTimer(self.updateTimer)
      self.updateTimer = nil
    end
  end
end
function collect_module:OnSeasonChangeEvent()
  if not self.collect_data or not next(self.collect_data) then
    return
  end
  if self.curSeason_id == nil then
    self.curSeason_id = DataMgr.season_id
    return
  end
  if self.curSeason_id == DataMgr.season_id then
    return
  end
  log_warning(bWriteLog and "  collect_module:OnSeasonChangeEvent.  ")
  local logic_season_config = require("client.logic.season.logic_season_config")
  logic_season_config.SendSeasonConfigReq()
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_sys_main_data_req()
end
function collect_module:OnGetMainData(err_code, collect_data, param)
  log_tree("  collect_module:OnGetMainData. param ", param)
  self.rankUrl = param and param.rank_url
  if not collect_data.weapon_score then
    collect_module.weapon_score = {}
  end
  self.  self.is_idle_time = param and param.is_idle_time
  local totalScore = self.collect_data.total_score
  local totalLevel = self:GetLevelByScore(totalScore) or 0
  self:SetOneLevel(collect_cfg.Sys2Index.Level, totalLevel)
  local score = TableUtil.GetTableValue(self.collect_data.season_score, DataMgr.season_id) or 0
  local curLevel = self:GetSeasonLevelByScore(score) or 0
  self:SetOneLevel(collect_cfg.Sys2Index.Season, curLevel)
  local collect_pavilions_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pavilions_module)
  collect_pavilions_module:SetMyMilestoneDisplayData(collect_data.show_milestone_list)
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:SetBadgeData(collect_data.badge_list)
  self:NotifyCollectData(collect_data)
  self:UpdateCollectDetailData(true, true)
  log_warning(bWriteLog and "  collect_module:OnGetMainData. self.is_idle_time: " .. tostring(self.is_idle_time))
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_MAIN_DATA)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_COLLECT_AVAILABLE_REWARD_POPUP)
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  collect_reddot_module:RefreshRedPoint()
end
function collect_module:GetSeasonId()
  local collect_data = self.collect_data
  if collect_data then
    local nCurSeason = collect_data.cur_season_idx or 1
    return nCurSeason
  end
  log_warning(bWriteLog and "  collect_module:GetSeasonId.  self.nCurSeason:1 ")
  return 1
end
function collect_module:SetLikeCount(nLikeCount)
  self._end
function collect_module:GetLikeCount()
  return self._nLikeCount
end
function collect_module:OnGetItemData(uid, data)
  log_warning(bWriteLog and "  collect_module:OnGetItemData. uid: " .. tostring(uid))
  if not data then
    return
  end
  self.nUid = uid
  self.itemTb = data.item_detail
  log_tree("  collect_module:OnGetItemData. data.item_detail ", data.item_detail)
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:OnChangeBadgeData(data.badge_detail)
  local collect_pavilions_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pavilions_module)
  collect_pavilions_module:SetVisitorMilestoneDisplayData(data.show_milestone_list)
  local bEnable = Client.HDmpveRemoteConfigGetBool("EnableGetTableRowFields", false)
  log(bWriteLog and "collect_module:OnGetItemData HDmpveRemoteConfigGetBool bEnable: " .. tostring(bEnable))
  if bEnable then
    self:SetCollectItemData(self.itemTb)
  else
    local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
    collect_theme_module:AddedAlreadyOwnedProps(self.itemTb)
    local collect_vehicle_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_vehicle_module)
    collect_vehicle_module:SetCarSubType(self.itemTb)
    local collect_pet_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pet_module)
    collect_pet_module:SetOwnedData(self.itemTb)
  end
end
function collect_module:SetCollectItemData(itemTb)
  if not itemTb then
    log_warning(bWriteLog and "collect_module:SetCollectItemData itemTb is nil")
    return
  end
  local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
  collect_theme_module.Quality2ItemTb = {}
  collect_theme_module.Item2Quality = collect_theme_module.Item2Quality or prealloctable(0, 3700)
  local item2Quality = collect_theme_module.Item2Quality
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  for quality = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    collect_theme_module.Quality2ItemTb[quality] = {}
  end
  local collect_vehicle_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_vehicle_module)
  collect_vehicle_module.car2SubCar = {}
  local car2SubCar = collect_vehicle_module.car2SubCar
  local collect_pet_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pet_module)
  collect_pet_module.petTb = {}
  collect_pet_module.petClothesTb = {}
  local petTb = collect_pet_module.petTb
  local petClothesTb = collect_pet_module.petClothesTb
  local getTableData = CDataTable.GetTableData
  local quality2ItemTb = collect_theme_module.Quality2ItemTb
  local VehicleType = ENUM_ITEM_TYPE.Vehicle
  local BUDDY_TYPE = ENUM_ITEM_TYPE.Buddy
  local BUDDY_NEW_TYPE = ENUM_ITEM_TYPE.Buddy_New
  local fieldMap = CDataTable.GetTableRowFieldsByKeyMap("Item", itemTb, {
    "ItemType",
    "ItemSubType",
    "ItemQuality"
  })
  for itemId, v in pairs(itemTb) do
    local itemData = fieldMap[itemId]
    if itemData then
      local itemType = itemData.ItemType
      local itemSubType = itemData.ItemSubType
      local curQuality = item2Quality[itemId]
      if not curQuality then
        curQuality = itemData.ItemQuality
        item2Quality[itemId] = curQuality
      end
      if curQuality and quality2ItemTb[curQuality] then
        quality2ItemTb[curQuality][itemId] = v
      end
      if itemType == VehicleType then
        car2SubCar[itemId] = itemSubType
      end
      if itemType == BUDDY_TYPE then
        petTb[itemId] = itemSubType
      elseif itemType == BUDDY_NEW_TYPE then
        petClothesTb[itemId] = itemSubType
      end
    end
  end
  log(bWriteLog and "collect_module:SetCollectItemData completed")
end
function collect_module:GetLevelByScore(score)
  if not score then
    return 1, 1, NMaxLevel, 0, 0
  end
  local result
  if score > NMaxScore then
    return NMaxLevel, NMaxDan, NMaxLevel, 0, 0
  end
  local nextLevel, findLevel, dan
  local lowerScore, nextScore = 0, 0
  for level, v in pairs(self:GetSplitTable("CollectLevel", E_ColCfgMode.JK)) do
    nextLevel = level
    nextScore = tonumber(v.Score)
    dan = v.Dan
    lowerScore = tonumber(v.MinScore)
    if score < nextScore then
      findLevel = true
      result = tonumber(level)
      log_warning(bWriteLog and "  collect_module:GetLevelByScore. level: " .. tostring(level))
      break
    end
  end
  if not findLevel then
    NMaxScore = nextScore
    NMaxLevel = tonumber(nextLevel)
    NMaxDan = dan
    result = NMaxLevel
    log_warning(bWriteLog and "  collect_module:RefreshLevel. maxLevel: " .. tostring(NMaxLevel))
  end
  return result, dan, NMaxLevel, lowerScore, nextScore
end
function collect_module:GetSeasonLevelByScore(score, seasonId)
  if type(score) ~= "number" then
    score = 0
  end
  seasonId = seasonId or DataMgr.season_id
  log(bWriteLog and string.format("collect_module:GetSeasonLevelByScore seasonId = %s score = %s", seasonId, score))
  local result, highlight, desc = 0, false, ""
  local CollectLevelCfg = self:GetSplitTableByFilter("NewCollectSeasonLevel", E_ColCfgMode.JK, "SeasonID", tonumber(seasonId))
  if not CollectLevelCfg then
    log(bWriteLog and string.format("collect_module:GetSeasonLevelByScore NewCollectSeasonLevel config is nil, season id = %s", seasonId))
    return result, highlight, desc
  end
  for _, v in pairs(CollectLevelCfg) do
    if v.MinScore and score < v.MinScore then
      break
    end
    result = v.Level
    highlight = v.ShowSpecial
    desc = v.DanDesc
    if score < v.Score then
      break
    end
  end
  return result, highlight, desc
end
function collect_module:GetCollectScoreByCollectData(collect_data)
  local collectScore, curSeasonScore = 0, 0
  log_tree("collect_module:GetCollectScoreByCollectData collect_data", collect_data)
  if collect_data then
    collectScore = collect_data.total_score or 0
    curSeasonScore = collect_data.cur_season_collect_score or 0
  end
  return collectScore, curSeasonScore
end
function collect_module:GetCollectScoreByProfile(profile)
  local collectScore, curSeasonScore = 0, 0
  if profile and profile.collect_data then
    log_tree("profile.collect_data", profile.collect_data)
    return self:GetCollectScoreByCollectData(profile.collect_data)
  end
  return collectScore, curSeasonScore
end
function collect_module:GetSelfCollectScoreByBriefData()
  local collectScore, curSeasonScore = 0, 0
  local data = DataMgr.roleData.brief_collect_data
  if data then
    return self:GetCollectScoreByCollectData(data)
  end
  return collectScore, curSeasonScore
end
function collect_module:SetOneLevel(tabId, level)
  log_warning(bWriteLog and string.format("collect_module:SetOneLevel. tabId%s, level%s", tabId, level))
  self.curLevels[tabId] = level
end
function collect_module:GetAwardStatus(tabId, index, subIndex)
  if not self.collect_data then
    return ActivityProgressStatus.Done
  end
  local awardTb = self.collect_data[tabId2awardName[tabId]]
  local get = TableUtil.GetTableValue(awardTb, index, subIndex)
  if get then
    return ActivityProgressStatus.Get
  end
  local curLevel = self.curLevels[tabId]
  local status = ActivityProgressStatus.Done
  if index > curLevel then
    status = ActivityProgressStatus.Not
  end
  return status
end
function collect_module:GetAllGunBoxData()
  local ArmorySystem = require("client.logic.armory.logic_armory")
  local itemTb = self.itemTb
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local gunTypeArray = logic_wardrobe_gun:GetGunTypeArray()
  local allGun = {}
  for _, v in ipairs(gunTypeArray) do
    local gunList
    local typeId = v.TypeID
    local gunArray = logic_wardrobe_gun:GetGunArrayByGunType(typeId)
    gunArray = gunArray or {}
    for _, weapon in pairs(gunArray) do
      local skinList = ArmorySystem.GetSkinListByWeaponID(weapon.WeaponID)
      local subList
      for skin, _ in pairs(skinList) do
        local itemData = CDataTable.GetTableData("Item", skin)
        if itemData and itemTb[skin] then
          subList = subList or {}
          gunList = gunList or {}
          subList[#subList + 1] = skin
        end
      end
      if subList then
        gunList = gunList or {}
        gunList[#gunList + 1] = {
          subList = subList,
          subId = weapon.WeaponID
        }
      end
    end
    if gunList then
      local armoryTypeCfg = CDataTable.GetTableData("ArmoryTypeConfig", typeId)
      allGun[#allGun + 1] = {
        List = gunList,
        id = typeId,
        text = armoryTypeCfg.TypeName
      }
    end
  end
  return allGun
end
function collect_module:GetItemTb()
  return self.itemTb or {}
end
function collect_module:CheckAndGetItemTb(uid)
  if not uid or uid ~= self.nUid then
    return nil
  end
  return self.itemTb
end
local carILevel = {
  1,
  1,
  1,
  2,
  2,
  3,
  4,
  5
}
function collect_module:GetScoreByItemId(itemId)
  if not itemId or itemId == 0 then
    return 0
  end
  local item2Score = self.item2Score
  local score = item2Score[itemId]
  if score then
    return score
  end
  local CollectSpecialCfg = self:GetSplitTableData("CollectSpecialCfg", E_ColCfgMode.Def, itemId)
  if CollectSpecialCfg then
    score = CollectSpecialCfg.Score or 0
    item2Score[itemId] = score
    return score
  end
  local itemData = CDataTable.GetTableData("Item", itemId)
  if not itemData then
    return 0
  end
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local ItemUpgradeMgr = self.ItemUpgradeMgr
  local level = ItemUpgradeMgr:GetItemEffectLevel(itemId)
  local isUpCar
  if level == 0 and itemData.ItemType == ENUM_ITEM_TYPE.Vehicle then
    local cfg = CDataTable.GetTableData("VehicleRefitInfo", itemId)
    if cfg then
      level = cfg.level
      isUpCar = true
    end
  end
  if level == 0 then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    level = LogicXSuit.GetLevelByItemId(itemId) or 0
  end
  if level == 0 then
    local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
    level = logic_suit_dye:GetSuitLevelBySuitId(itemId)
  end
  if 0 < level then
    local iLevel = 1
    local maxItem, maxLevel
    if isUpCar then
      local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
      local cars = VehicleRefitHandler.GetLevelUpCfgList(itemId)
      maxLevel = #cars
      log_warning(bWriteLog and "  collect_module:GetScoreByItemId. car maxLevel: " .. tostring(maxLevel))
    else
      maxItem = ItemUpgradeMgr:GetMaxLevelItem(itemId)
      maxLevel = ItemUpgradeMgr:GetItemEffectLevel(maxItem)
    end
    local iType = 4
    if AvatarCommon.IsXSuit(itemId) then
      iType = 3
      iLevel = 3
    elseif itemData.ItemType == ENUM_ITEM_TYPE.Vehicle then
      iType = 2
      iLevel = carILevel[maxLevel]
    elseif itemData.ItemType == ENUM_ITEM_TYPE.Weapon then
      iType = 1
      iLevel = self:GetGunLevel(maxLevel)
    end
    log_warning(bWriteLog and "  collect_module:GetScoreByItemId. iLevel: " .. tostring(iLevel))
    log_warning(bWriteLog and "  collect_module:GetScoreByItemId. iType: " .. tostring(iType))
    log_warning(bWriteLog and "  collect_module:GetScoreByItemId. level: " .. tostring(level))
    local CollectUpgradeCfg = self:GetSplitTableByFilter("CollectUpgradeCfg", E_ColCfgMode.Def, "itemQuality", iLevel, "itemType", iType, "level", level)
    if CollectUpgradeCfg then
      for _, v in pairs(CollectUpgradeCfg) do
        score = v.Score
        item2Score[itemId] = score
        return score
      end
    end
  end
  local ScoreCfg = self:GetSplitTableByFilter("CollectScoreCfg", E_ColCfgMode.Def, "Quality", itemData.ItemQuality, "Type", itemData.ItemType, "SubType", itemData.ItemSubType)
  if ScoreCfg then
    for _, v in pairs(ScoreCfg) do
      score = v.Score
      item2Score[itemId] = score
      return score
    end
  end
  ScoreCfg = self:GetSplitTableByFilter("CollectScoreCfg", E_ColCfgMode.Def, "Quality", itemData.ItemQuality, "Type", itemData.ItemType, "SubType", 0)
  if ScoreCfg then
    for _, v in pairs(ScoreCfg) do
      score = v.Score
      item2Score[itemId] = score
      return score
    end
  end
  log_warning(bWriteLog and "  collect_module:GetScoreByItemId. itemId: " .. tostring(itemId))
  log_warning(bWriteLog and "  collect_module:GetScoreByItemId. itemData.ItemQuality: " .. tostring(itemData.ItemQuality))
  log_warning(bWriteLog and "  collect_module:GetScoreByItemId. itemData.ItemType: " .. tostring(itemData.ItemType))
  log_warning(bWriteLog and "  collect_module:GetScoreByItemId. itemData.ItemSubType: " .. tostring(itemData.ItemSubType))
  log_warning(bWriteLog and "  collect_module:GetScoreByItemId.  no data")
  item2Score[itemId] = 0
  return 0
end
function collect_module:GetGunLevel(maxLevel)
  if maxLevel <= 3 then
    return 1
  elseif 6 <= maxLevel then
    return 3
  else
    return 2
  end
end
function collect_module:NotifyCollectData(collect_data)
  self.  local roleData = DataMgr.roleData
  if not roleData.brief_collect_data then
    roleData.brief_collect_data = {}
  end
  if collect_data.season_score then
    local season = self:GetSeasonId()
    local seasonScore = TableUtil.GetTableValue(collect_data.season_score, season) or 0
    roleData.brief_collect_data.cur_season_collect_score = seasonScore
  else
    roleData.brief_collect_data.cur_season_collect_score = 0
  end
  local oldTotal = roleData.brief_collect_data.total_score or 0
  local newTotal = collect_data.total_score or 0
  log(bWriteLog and string.format("collect_module:NotifyCollectData oldTotal = %s, newTotal = %s", oldTotal, newTotal))
  local configs = self:GetSplitTable("CollectLevel", E_ColCfgMode.JK)
  for _, v in pairs(configs) do
    if oldTotal >= v.MinScore and oldTotal < v.Score then
      if newTotal >= v.Score then
        local collect_up_level = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_up_level)
        collect_up_level:MarkPopUpLevel(oldTotal, newTotal)
        local newLevel = self:GetLevelByScore(newTotal)
        if newLevel > v.Level then
          self:SetOneLevel(self.collect_cfg.Sys2Index.Level, newLevel)
          EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_ROAD_LEVEL_UP)
        end
      end
      break
    end
  end
  roleData.brief_collect_data.total_score = newTotal
  roleData.brief_collect_data.privacy = collect_data.privacy or 0
end
function collect_module:HasDependence(itemId)
  if not itemId or itemId == 0 then
    return true
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
  return StoreUtils.HasItem(itemId)
end
function collect_module:GetTBName(name)
  if not bJk then
    return name
  else
    return name .. "JK"
  end
end
function collect_module:GetTBNameDiffJK(name)
  if not bJk then
    return name
  else
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
      name = name .. "JP"
    elseif FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.KR then
      name = name .. "KR"
    end
    log(bWriteLog and string.format("collect_module:GetTBNameDiffJK. name=%s", tostring(name)))
    return name
  end
end
function collect_module:GetSplitTable(name, mode)
  if mode == E_ColCfgMode.JK then
    name = self:GetTBName(name)
  elseif mode == E_ColCfgMode.DifJK then
    name = self:GetTBNameDiffJK(name)
  end
  if SplitCollectTableName[name] then
    return CDataTable.GetSplitTable("Lobby", "Collect", name) or {}
  end
  return CDataTable.GetTable(name)
end
function collect_module:GetSplitTableData(name, mode, key)
  if mode == E_ColCfgMode.JK then
    name = self:GetTBName(name)
  elseif mode == E_ColCfgMode.DifJK then
    name = self:GetTBNameDiffJK(name)
  end
  if SplitCollectTableName[name] then
    return CDataTable.GetSplitTableData("Lobby", "Collect", name, key) or {}
  end
  return CDataTable.GetTableData(name, key)
end
function collect_module:GetSplitTableByFilter(name, mode, ...)
  if mode == E_ColCfgMode.JK then
    name = self:GetTBName(name)
  elseif mode == E_ColCfgMode.DifJK then
    name = self:GetTBNameDiffJK(name)
  end
  if SplitCollectTableName[name] then
    return CDataTable.GetSplitTableByFilter("Lobby", "Collect", name, ...) or {}
  end
  return CDataTable.GetTableByFilter(name, ...)
end
function collect_module:GetSplitTableDataByFilter(name, mode, ...)
  if mode == E_ColCfgMode.JK then
    name = self:GetTBName(name)
  elseif mode == E_ColCfgMode.DifJK then
    name = self:GetTBNameDiffJK(name)
  end
  if SplitCollectTableName[name] then
    return CDataTable.GetSplitTableDataByFilter("Lobby", "Collect", name, ...) or {}
  end
  return CDataTable.GetTableDataByFilter(name, ...)
end
function collect_module:CheckSeasonConfig()
  local configs = self:GetSplitTableByFilter("NewCollectSeasonLevel", E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
  if not configs then
    log(bWriteLog and string.format("collect_module:CheckSeasonConfig NewCollectSeasonLevel config is nil, season id = %s.", DataMgr.season_id))
    return false
  end
  for _, v in pairs(configs) do
    return true
  end
  return false
end
function collect_module:SeasonIsHide()
  if self.is_idle_time then
    return true
  end
  if not self:CheckSeasonConfig() then
    return true
  end
  local seasonId = 37
  if bBlue then
    seasonId = 36
  end
  local logic_season_config = require("client.logic.season.logic_season_config")
  local SeasonCfg = logic_season_config.GetSeasonConfig(seasonId)
  local needTime = SeasonCfg and SeasonCfg.begin_timestamp
  local TimeUtil = require("client.common.time_util")
  if not needTime then
    return false
  end
  local now = TimeUtil.GetServerTimeInSec()
  return needTime > now
end
function collect_module:GetSeasonScoreAndLevelBySeasonID(season)
  if not self.collect_data then
    log(bWriteLog and string.format("collect_module:GetSeasonScoreAndLevelBySeasonID collect_data is nil."))
    return 0, 0
  end
  local curSeason = self:GetSeasonId()
  season = season or curSeason
  local score = TableUtil.GetTableValue(self.collect_data.season_score, season) or 0
  local curLevel = self.curLevels[collect_cfg.Sys2Index.Season]
  if curSeason ~= season then
    curLevel = self:GetSeasonLevelByScore(score, season) or 0
  end
  return score, curLevel
end
function collect_module:GetCollectTotalScore()
  if not self.collect_data then
    log(bWriteLog and string.format("collect_module:GetCollectTotalScore. collect_data is nil."))
    return 0, 0
  end
  local score = self.collect_data.total_score
  return score, self.curLevels[collect_cfg.Sys2Index.Level]
end
function collect_module:GetCollectSeasonScore()
  if not self.collect_data then
    log(bWriteLog and string.format("collect_module:GetCollectTotalScore. collect_data is nil."))
    return 0, 0
  end
  local score = self.collect_data.season_score
  return score, self.curLevels[collect_cfg.Sys2Index.Season]
end
function collect_module:GetLastTotalLevelBySeasonID(season)
  local total = self.collect_data.total_score
  if self.collect_data.season_score then
    for id, num in pairs(self.collect_data.season_score) do
      if season < id and type(num) == "number" then
        total = total - num
      end
    end
  end
  total = math.max(total, 0)
  local curLevel = self:GetLevelByScore(total)
  return total, curLevel
end
function collect_module:GetCollectData()
  return self.collect_data
end
function collect_module:CanShowTheme()
  return not PublishRegionMacros.IsJapanOrKorea()
end
function collect_module:GetLevelDataByScore(score, isSeason)
  local curLevel, curLevelName, rank = 0, "", 1
  if type(score) ~= "number" then
    log(bWriteLog and string.format("Collect_Level_Medal_Tips_UIBP:GetLevelDataByScore score type is not number, score = %s", score))
    return curLevel, curLevelName, rank
  end
  local configs = {}
  if isSeason then
    configs = self:GetSplitTableByFilter("NewCollectSeasonLevel", E_ColCfgMode.JK, "SeasonID", tonumber(DataMgr.season_id))
    if not configs then
      log(bWriteLog and string.format("Collect_Level_Medal_Tips_UIBP:GetLevelDataByScore NewCollectSeasonLevel config is nil, season id = %s", DataMgr.season_id))
      return curLevel, curLevelName, rank
    end
  else
    configs = self:GetSplitTable("CollectLevel", E_ColCfgMode.JK)
  end
  for _, v in pairs(configs) do
    curLevel = v.Level
    curLevelName = v.DanDesc
    rank = v.Dan
    if score < v.Score then
      break
    end
  end
  return curLevel, curLevelName, rank
end
function collect_module:GetCurStickerBgId()
  if not self.collect_data then
    return
  end
  return self.collect_data.cur_sticker_bg
end
function collect_module:UpdateCollectDetailData(bReq, bCollectMain, other_uid)
  other_uid = other_uid or DataMgr.roleData.uid
  if tonumber(other_uid) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and string.format("collect_module:UpdateCollectDetailData other_uid is not self"))
    return
  end
  if bCollectMain then
    if self.bCollectMainOnce then
      return
    end
    self.bCollectMainOnce = true
  end
  if self.detailTimer then
    if bReq then
      self:RemoveTimer(self.detailTimer)
      self.detailTimer = nil
    else
      return
    end
  end
  self.detailTimer = self:AddTimerOnce(1, function()
    if bReq then
      local CollectHandler = require("client.network.Protocol.CollectHandler")
      CollectHandler.send_get_collect_detail_req(DataMgr.roleData.uid, 1)
    else
      self:UpdateCollectStatsData()
    end
    self.detailTimer = nil
  end)
end
function collect_module:GetCollectItemData()
  return self.collect_stats_data
end
function collect_module:InitCollectItemData()
  self.collect_stats_data = {
    SeasonID = 0,
    CollectScore = 0,
    NextLevelScore = 0,
    Level = 0,
    NextLevel = 0,
    SeasonCollectScore = 0,
    SeasonNextLevelScore = 0,
    SeasonLevel = 0,
    SeasonNextLevel = 0,
    QualityCount1 = 0,
    QualityCount2 = 0,
    QualityCount3 = 0,
    QualityCount4 = 0,
    CollectTypeCount1 = 0,
    CollectTypeCount2 = 0,
    CollectTypeCount3 = 0,
    CollectTypeCount4 = 0
  }
end
function collect_module:UpdateCollectStatsData()
  if self.updateTimer then
    self:RemoveTimer(self.updateTimer)
    self.updateTimer = nil
  end
  if not GameStatus.IsInLobbyOrSpecialFighting() then
    return
  end
  local totalScore = self.collect_data and self.collect_data.total_score or 0
  local level, rank, maxLevel, curMinScore, curMaxScore = self:GetLevelByScore(totalScore)
  local bMaxLevel = level == maxLevel
  self.collect_stats_data.Level = level
  self.collect_stats_data.NextLevel = bMaxLevel and level or level + 1
  self.collect_stats_data.CollectScore = bMaxLevel and totalScore or totalScore - curMinScore
  self.collect_stats_data.NextLevelScore = bMaxLevel and totalScore or curMaxScore - totalScore
  self.collect_stats_data.SeasonID = self:GetSeasonId()
  self.collect_stats_data.SeasonCollectScore, self.collect_stats_data.SeasonLevel = self:GetSeasonScoreAndLevelBySeasonID(self.collect_stats_data.SeasonID)
  local CollectLevelCfg = self:GetSplitTableDataByFilter("NewCollectSeasonLevel", E_ColCfgMode.JK, "SeasonID", tonumber(self.collect_stats_data.SeasonID), "Level", self.collect_stats_data.SeasonLevel)
  if CollectLevelCfg then
    local NextCollectLevelCfg = self:GetSplitTableDataByFilter("NewCollectSeasonLevel", E_ColCfgMode.JK, "SeasonID", tonumber(self.collect_stats_data.SeasonID), "Level", self.collect_stats_data.SeasonLevel + 1)
    self.collect_stats_data.SeasonNextLevel = NextCollectLevelCfg and NextCollectLevelCfg.Level or self.collect_stats_data.SeasonLevel
    self.collect_stats_data.SeasonNextLevelScore = CollectLevelCfg.Score
    self.collect_stats_data.SeasonCollectScore = self.collect_stats_data.SeasonCollectScore - CollectLevelCfg.MinScore
  end
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local collect_theme_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_theme_module)
  for i = ItemMacros.QUALITY_PURPLE, ItemMacros.QUALITY_GOLDEN do
    local num = TableUtil.CountTable(collect_theme_module.Quality2ItemTb[i])
    self.collect_stats_data["QualityCount" .. i - 4] = num
  end
  self.updateTimer = self:AddTimer(1, function()
    local collect_season_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_season_module)
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
    local time_ticker = require("common.time_ticker")
    local counters = 0
    self.collect_stats_data.CollectTypeCount1 = 0
    self.collect_stats_data.CollectTypeCount2 = 0
    self.collect_stats_data.CollectTypeCount3 = 0
    self.collect_stats_data.CollectTypeCount4 = 0
    for itemId, _ in pairs(self.itemTb) do
      local ItemConfig = CDataTable.GetTableData("Item", itemId)
      if AvatarCommon.IsXSuit(itemId) then
        self.collect_stats_data.CollectTypeCount1 = self.collect_stats_data.CollectTypeCount1 + 1
      elseif ItemConfig and ItemConfig.ItemQuality == 8 and ItemConfig.ItemSubType == 403 then
        self.collect_stats_data.CollectTypeCount2 = self.collect_stats_data.CollectTypeCount2 + 1
      elseif ItemUpgradeMgr:IsUpdateGun(itemId) then
        self.collect_stats_data.CollectTypeCount3 = self.collect_stats_data.CollectTypeCount3 + 1
      elseif collect_season_module:IsBetterCar(itemId) then
        self.collect_stats_data.CollectTypeCount4 = self.collect_stats_data.CollectTypeCount4 + 1
      end
      counters = counters + 1
      if 80 < counters then
        counters = 0
        coroutine.yield(time_ticker.NEXT_FRAME)
      end
    end
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_report_collect_detail_tlog(self.collect_stats_data)
  end)
end
local _CheckItemIsGold = function(itemID)
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local ItemConfig = CDataTable.GetTableData("Item", itemID)
  if ItemConfig and ItemConfig.ItemQuality == ItemMacros.QUALITY_GOLDEN and ItemConfig.ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot then
    return true
  end
end
function collect_module:GetCalSpecialItemCountTimer(fCalFinishCallback)
  local itemTb = self.itemTb
  local time_ticker = require("common.time_ticker")
  local AvatarCommon = require("client.slua.logic.avatar.avatar_common")
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local collect_season_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_season_module)
  local nTimer = self:AddTimer(0.1, function()
    local counters = 0
    local xSuit, golden, upgrade, tarot = 0, 0, 0, 0
    for itemId, _ in pairs(itemTb) do
      if AvatarCommon.IsXSuit(itemId) then
        xSuit = xSuit + 1
      elseif _CheckItemIsGold(itemId) then
        golden = golden + 1
      elseif ItemUpgradeMgr:IsUpdateGun(itemId) then
        upgrade = upgrade + 1
      elseif collect_season_module:IsBetterCar(itemId) then
        tarot = tarot + 1
      end
      counters = counters + 1
      if 200 < counters then
        counters = 0
        coroutine.yield(time_ticker.NEXT_FRAME)
      end
    end
    fCalFinishCallback(xSuit, golden, upgrade, tarot)
  end)
  return nTimer
end
function collect_module:ClearCalSpecialItemCountTimer(nTimer)
  if not nTimer then
    return
  end
  self:RemoveTimer(nTimer)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Ccollect_module = class(CModuleBase, nil, collect_module)
return Ccollect_module
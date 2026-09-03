local ENUM_MATCH_TAB_SORT_TYPE = {
  QUALITY = 1,
  LATEST = 2,
  TIMES = 3
}
local logic_outfit_combination = {}
local partNum = 6
function logic_outfit_combination:DefineAndResetData()
  self.CombinationsUseTimesData = {}
  self.bIsOpenDailyRandom = false
  self.bIsPopDailyRandomTips = false
  self.tRandomFilterInfo = {}
  self.bOpenRandom = false
end
function logic_outfit_combination:SendCurrentOutfitCombinationID(nCombinationID)
  local OutfitCombinationHandler = require("client.network.Protocol.OutfitCombinationHandler")
  OutfitCombinationHandler.send_put_on_outfit_combinations_req(nCombinationID)
  local times = self.CombinationsUseTimesData[nCombinationID] or 0
  self.CombinationsUseTimesData[nCombinationID] = times + 1
end
function logic_outfit_combination:RequireOutfitCombinationsUseTimes()
  local OutfitCombinationHandler = require("client.network.Protocol.OutfitCombinationHandler")
  OutfitCombinationHandler.send_get_outfit_combinations_use_times_req()
  OutfitCombinationHandler.send_get_outfit_filter_tags_req()
end
function logic_outfit_combination:GetProperSuitItemInsId(nResId, bIgnoreGroup)
  if not nResId or nResId == 0 then
    return 0, nil
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if not bIgnoreGroup and ModelDisplayTypeHelper.IsWeaponById(nResId) then
    local ItemUpgradeModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local bHasItem, CurID = ItemUpgradeModule:CheckHasSameGroupItemAndRefitItem(nResId)
    if bHasItem then
      nResId = CurID
    end
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  nResId = LogicMultiItemModule:GetMultiItemGroupCurSelectItemId(nResId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemList = wardrobe_data:GetHallDepotItemListByResID(nResId)
  for _, v in ipairs(itemList) do
    if v.expireTS == 0 and v.validHours == 0 then
      log(bWriteLog and string.format("logic_outfit_combination:GetProperSuitItemInsId resId = %d, insID = %d", nResId, v.insID))
      return v.insID, v
    end
  end
  return 0, nil
end
function logic_outfit_combination:OnOutfitCombinationsUseTimes(combinationsUseTimes)
  self.CombinationsUseTimesData = combinationsUseTimes or {}
end
function logic_outfit_combination:GetOutfitCombinationsUseTimes(nID)
  local suitConfig = CDataTable.GetTableData("SuitMatchConfig", nID)
  local groupID = suitConfig.PairingGroupID
  if not groupID or groupID <= 0 then
    return self.CombinationsUseTimesData[nID] or 0
  end
  local configs = CDataTable.GetTableByFilter("SuitMatchConfig", "PairingGroupID", groupID)
  if not configs then
    return self.CombinationsUseTimesData[nID] or 0
  end
  local num = 0
  for _, cfg in pairs(configs) do
    local times = self.CombinationsUseTimesData[cfg.ID] or 0
    num = num + times
  end
  return num
end
function logic_outfit_combination:SetDailyRandomOutfitCombination(bIsOpen)
  local OutfitCombinationHandler = require("client.network.Protocol.OutfitCombinationHandler")
  OutfitCombinationHandler.send_open_combinations_daily_random_req(bIsOpen)
  self.bIsPopDailyRandomTips = bIsOpen
end
function logic_outfit_combination:GetDailyRandomOutfitCombination()
  return self.bIsOpenDailyRandom
end
function logic_outfit_combination:OnDailyRandomOutfitCombination(bIsOpen)
  log(bWriteLog and string.format("logic_outfit_combination:OnDailyRandomOutfitCombination bIsOpen = %s", tostring(bIsOpen)))
  self.bIsOpenDailyRandom = bIsOpen
end
function logic_outfit_combination:IsPopDailyRandomTips()
  return self.bIsPopDailyRandomTips
end
function logic_outfit_combination:PopDailyRandomTips()
  if not self.bIsPopDailyRandomTips then
    return
  end
  self.bIsPopDailyRandomTips = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bJumpTips = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOutfitCombinationTips)
  if bJumpTips and bJumpTips == 1 then
    log(bWriteLog and string.format("logic_outfit_combination:PopDailyRandomTips bJumpTips = %s", tostring(bJumpTips)))
    UIManager.CloseUI(UIManager.UI_Config.wardrobe)
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local sTitle = LocUtil.GetLocalizeResStr(5077)
  local sMsg = LocUtil.GetLocalizeResStr(86231)
  local sBtnOK = LocUtil.GetLocalizeResStr(86233)
  local sBtnCancel = LocUtil.GetLocalizeResStr(86232)
  local fClickOkCallback = function(bIsCheck)
    if bIsCheck then
      PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eOutfitCombinationTips)
    end
    UIManager.CloseUI(UIManager.UI_Config.wardrobe)
  end
  local fClickCancelCallback = function(bIsCheck)
    if bIsCheck then
      PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eOutfitCombinationTips)
    end
    self:SetDailyRandomOutfitCombination(false)
    UIManager.CloseUI(UIManager.UI_Config.wardrobe)
  end
  local tExtraData = {
    isShowCheckBox = true,
    checkBoxText = LocUtil.LocalizeResFormat(86234),
    closeOnSwitch = false
  }
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback, fClickCancelCallback, sBtnOK, sBtnCancel, tExtraData)
end
function logic_outfit_combination:OnOutfitFilterTags(RandomFilterInfo)
  self.tRandomFilterInfo = RandomFilterInfo or {}
end
function logic_outfit_combination:GetOutfitFilterTagsTime()
  local data = {}
  if self.tRandomFilterInfo and self.tRandomFilterInfo.obtain_ts_info then
    local startTime = self.tRandomFilterInfo.obtain_ts_info.start_ts or 0
    local endtTime = self.tRandomFilterInfo.obtain_ts_info.end_ts or 0
    local TimeUtil = require("client.common.time_util")
    if 0 < startTime then
      local startTable = TimeUtil.OSDate("!*t", startTime)
      data.StartYear = startTable.year
      data.StartMonth = startTable.month
    end
    if 0 < endtTime then
      local endTable = TimeUtil.OSDate("!*t", endtTime)
      data.EndYear = endTable.year
      data.EndMonth = endTable.month
    end
  end
  return data
end
function logic_outfit_combination:GetCurrentOutfitFilterCornerTags()
  local data = {}
  if self.tRandomFilterInfo and self.tRandomFilterInfo.item_tags then
    local tags = self.tRandomFilterInfo.item_tags
    for _, v in ipairs(tags) do
      local cfg = CDataTable.GetTableData("NewSuitMatchIDToTypeName", v)
      if cfg then
        data[v] = true
      end
    end
  end
  return data
end
function logic_outfit_combination:SuitMatchIDToTypeName(typeID)
  local cfg = CDataTable.GetTableData("NewSuitMatchIDToTypeName", typeID)
  if cfg then
    return cfg.Name
  end
  log(bWriteLog and string.format("logic_outfit_combination:SuitMatchIDToTypeName typeID = %s The configuration is empty.", typeID))
  return ""
end
function logic_outfit_combination:GetCurrentOutfitFilterCustomTags()
  local data = {}
  if self.tRandomFilterInfo and self.tRandomFilterInfo.depot_tags then
    local tags = self.tRandomFilterInfo.depot_tags
    for _, v in ipairs(tags) do
      data[v] = true
    end
  end
  return data
end
function logic_outfit_combination:IsItemMatchCustomTag(resID)
  if not resID then
    return false
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local MappedItemID = logic_wardrobe_tag_mgr:_GetMappedItemIDForCustomTag(resID)
  local selectCustomTag = self:GetCurrentOutfitFilterCustomTags()
  if not selectCustomTag or not next(selectCustomTag) then
    return true
  end
  local CustomTagMap = logic_wardrobe_tag_mgr:GetCustomTagMap()
  if CustomTagMap then
    for tagKey, status in pairs(selectCustomTag) do
      if status and CustomTagMap[tagKey] and CustomTagMap[tagKey][MappedItemID] then
        return true
      end
    end
  end
  return false
end
function logic_outfit_combination:ObtainLastSecond(endYear, endMonth)
  if 12 <= endMonth then
    endYear = endYear + 1
    endMonth = 1
  else
    endMonth = endMonth + 1
  end
  local TimeUtil = require("client.common.time_util")
  local endTime = TimeUtil.UnixTimeToUnixstamp(tonumber(endYear), tonumber(endMonth), 1, 0, 0, 0, false)
  endTime = math.tointeger(endTime - 1)
  log(bWriteLog and string.format("logic_outfit_combination:ObtainLastSecond endTime = %s", endTime))
  return endTime
end
function logic_outfit_combination:ObtainFirstSecond(startYear, startMonth)
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.UnixTimeToUnixstamp(tonumber(startYear), tonumber(startMonth), 1, 0, 0, 1, false)
  log(bWriteLog and string.format("logic_outfit_combination:ObtainFirstSecond startTime = %s, startYear = %s, startMonth = %s", startTime, startYear, startMonth))
  return math.tointeger(startTime)
end
function logic_outfit_combination:SendOutfitFilterInfo(selectCornerTagList, selectCustomTagList, startYear, startMonth, endYear, endMonth)
  self.tRandomFilterInfo.obtain_ts_info = {}
  self.tRandomFilterInfo.obtain_ts_info.start_ts = 0
  self.tRandomFilterInfo.obtain_ts_info.end_ts = 0
  if startYear and startMonth then
    self.tRandomFilterInfo.obtain_ts_info.start_ts = self:ObtainFirstSecond(startYear, startMonth)
  end
  if endYear and endMonth then
    self.tRandomFilterInfo.obtain_ts_info.end_ts = self:ObtainLastSecond(endYear, endMonth)
  end
  self.tRandomFilterInfo.item_tags = {}
  selectCornerTagList = selectCornerTagList or {}
  for i, v in pairs(selectCornerTagList) do
    table.insert(self.tRandomFilterInfo.item_tags, i)
  end
  self.tRandomFilterInfo.depot_tags = {}
  selectCustomTagList = selectCustomTagList or {}
  for i, v in pairs(selectCustomTagList) do
    table.insert(self.tRandomFilterInfo.depot_tags, i)
  end
  local OutfitCombinationHandler = require("client.network.Protocol.OutfitCombinationHandler")
  OutfitCombinationHandler.send_set_outfit_filter_tags_req(self.tRandomFilterInfo)
end
function logic_outfit_combination:GetCornerTagIDByTypeName(typeName)
  local cfg = CDataTable.GetTableDataByFilter("NewSuitMatchIDToTypeName", "Name", typeName)
  if cfg then
    return cfg.ID
  end
  return 0
end
function logic_outfit_combination:OnOutfitCombinationSettlementReport(LocalAvatar)
  if not LocalAvatar then
    return
  end
  if not LocalAvatar.uid then
    return
  end
  if tostring(LocalAvatar.uid) ~= DataMgr.roleData.uid then
    return
  end
  if not LocalAvatar.BP_ARRAY_AvatarList then
    return
  end
  local PlayerHasItems = {}
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local AddToPlayerItems = function(itemId)
    if itemId and 0 < itemId then
      PlayerHasItems[itemId] = true
      local tMultiList = LogicMultiItemModule:GetMultiListByItemID(itemId)
      if tMultiList then
        for _, tMulti in pairs(tMultiList) do
          PlayerHasItems[tMulti.ItemID] = true
        end
      end
    end
  end
  for _, tAvatarCustom in pairs(LocalAvatar.BP_ARRAY_AvatarList) do
    local itemId = tAvatarCustom.ItemID
    local uObj_baseCfg = CDataTable.GetTableData("ClothingStateConfig", itemId)
    if uObj_baseCfg then
      itemId = uObj_baseCfg.OriginClothID
    end
    AddToPlayerItems(itemId)
  end
  AddToPlayerItems(LocalAvatar.weaponSkinId)
  AddToPlayerItems(LocalAvatar.secondWeaponSkinId)
  log_tree("logic_outfit_combination.OnOutfitCombinationSettlementReport PlayerHasItems:", PlayerHasItems)
  local suitConfig = CDataTable.GetTable("SuitMatchConfig")
  for _, v in pairs(suitConfig) do
    local satisfy = true
    for i = 1, partNum do
      local resId = v["part" .. i]
      if not resId or resId <= 0 then
        break
      end
      if not PlayerHasItems[resId] then
        satisfy = false
        break
      end
    end
    if satisfy then
      self:SendCurrentOutfitCombinationID(v.ID)
      break
    end
  end
end
function logic_outfit_combination:GetAdditionalSuit(tData, cfg)
  local suitConfig = CDataTable.GetTableData("SuitMatchConfig", cfg.ID)
  tData.additionalPart = {}
  local insertAdditionalPart = function(str)
    local resID = tonumber(str) or 0
    if 0 < resID then
      table.insert(tData.additionalPart, resID)
    end
  end
  if suitConfig then
    local StringUtil = require("common.string_util")
    local idStr = StringUtil.Split(suitConfig.additionalPart, "|")
    if #idStr <= 0 then
      return
    end
    local bHave, nResID
    for _, v in pairs(idStr) do
      if v ~= "" then
        local group = StringUtil.Split(v, ";")
        if 1 < #group then
          bHave = false
          for i = #group, 1, -1 do
            nResID = tonumber(group[i]) or 0
            local insId, itemInfo = self:GetProperSuitItemInsId(nResID)
            if insId ~= 0 then
              table.insert(tData.additionalPart, itemInfo.resID)
              bHave = true
              break
            end
          end
          if not bHave then
            insertAdditionalPart(group[1])
          end
        elseif #group == 1 then
          insertAdditionalPart(group[1])
        end
      end
    end
  end
  log_tree("logic_outfit_combination:GetAdditionalSuit", tData)
end
function logic_outfit_combination:GetOutfitCombinationList()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local suitList = {}
  local have, isEmpty, mainItem = true, false, false
  local suitConfig = CDataTable.GetTable("SuitMatchConfig")
  for _, v in pairs(suitConfig) do
    have = true
    isEmpty = true
    local t = {}
    local high32Bits, low19Bits
    mainItem = nil
    for i = 1, partNum do
      local resId = v["part" .. tostring(i)]
      if 0 < resId then
        isEmpty = false
        local insId, itemData = self:GetProperSuitItemInsId(resId)
        if insId == 0 then
          have = false
          break
        end
        t["part" .. tostring(i)] = insId
        if not mainItem then
          high32Bits = WardrobeLogicManager:ExtractHigh32Bits(insId)
          low19Bits = WardrobeLogicManager:ExtractLow19Bits(insId)
          mainItem = WardrobeLogicManager:ArrayHallDepotToCommonItem(itemData)
        end
      end
    end
    if have and not isEmpty then
      t.ID = v.ID
      t.quality = v.quality
      t.      t.      t.name = v.name
      t.      t.times = self:GetOutfitCombinationsUseTimes(v.ID)
      self:GetAdditionalSuit(t, v)
      table.insert(suitList, t)
    end
  end
  return suitList
end
function logic_outfit_combination:GetItemListForFilter(list)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemList = {}
  for i, v in ipairs(list or {}) do
    local insId = v.part1
    if insId ~= nil then
      local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      table.insert(itemList, itemData)
    end
  end
  return itemList
end
function logic_outfit_combination:DoFilterTagsMatchTabList(itemListTable, bIsRandom)
  itemListTable = self:DoFilterByCornerTagMatchTabList(itemListTable, bIsRandom)
  itemListTable = self:DoFilterByCustomTagMatchTabList(itemListTable, bIsRandom)
  itemListTable = self:DoFilterByGetTimeMatchTabList(itemListTable, bIsRandom)
  return itemListTable
end
function logic_outfit_combination:DoFilterByFusionRecordMatchTabList(itemListTable)
  if not itemListTable or #itemListTable == 0 then
    return itemListTable or {}
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  if not LogicFusionModule then
    return itemListTable
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local result = {}
  for _, combination in ipairs(itemListTable) do
    local bKeep = true
    local insId = combination.part1
    if insId and 0 < insId then
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      local resId = itemInfo and itemInfo.resID
      local fusionConfig = resId and LogicFusionModule:GetFusionConfig(resId)
      if fusionConfig then
        local record = LogicFusionModule:GetFusionRecord(fusionConfig.period)
        local bExpectTarget = record and record.current_item_id == fusionConfig.targetItem
        local bIsTarget = resId == fusionConfig.targetItem
        if bExpectTarget ~= bIsTarget then
          bKeep = false
        end
      end
    end
    if bKeep then
      table.insert(result, combination)
    end
  end
  return result
end
function logic_outfit_combination:DoFilterByCornerTagMatchTabList(itemListTable, bIsRandom)
  local result = {}
  if not itemListTable then
    return result
  end
  local tSelectedCornerTagList
  if not bIsRandom then
    local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
    if not logic_wardrobe_tag_mgr:HasEnabledCornerTag() then
      return itemListTable
    end
    tSelectedCornerTagList = logic_wardrobe_tag_mgr:GetSelectedCornerTagList()
  else
    tSelectedCornerTagList = self:GetCurrentOutfitFilterCornerTags()
    if not next(tSelectedCornerTagList) then
      return itemListTable
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local   for _, v in pairs(itemListTable) do
    local insId = v.part1
    if insId and 0 < insId then
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      local resID = itemInfo.resID
      local itemData = CDataTable.GetTableData("Item", resID)
      local SpecialIcon = itemData.SpecialIcon
      if SpecialIcon then
        local CornerTag = CDataTable.GetTableData("NewCornerIconTypeConfig", SpecialIcon)
        if CornerTag and tSelectedCornerTagList and tSelectedCornerTagList[CornerTag.TypeID] then
          result[#result + 1] = v
        end
      end
    end
  end
  return result
end
function logic_outfit_combination:DoFilterByCustomTagMatchTabList(itemListTable, bIsRandom)
  local result = {}
  if not itemListTable then
    return result
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  if not bIsRandom then
    if not logic_wardrobe_tag_mgr:HasEnabledCustomTag() then
      return itemListTable
    end
  else
    local tags = self:GetCurrentOutfitFilterCustomTags()
    if not next(tags) then
      return itemListTable
    end
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(itemListTable) do
    local insId = v.part1
    if insId and 0 < insId then
      local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(insId)
      local resID = itemInfo.resID
      if not bIsRandom then
        if logic_wardrobe_tag_mgr:IsItemMatchCustomTag(resID) then
          result[#result + 1] = v
        end
      elseif self:IsItemMatchCustomTag(resID) then
        result[#result + 1] = v
      end
    end
  end
  return result
end
function logic_outfit_combination:DoFilterByGetTimeMatchTabList(itemListTable, bIsRandom)
  local result = {}
  if not itemListTable then
    return result
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  local StartTime, EndTime = 0, 0
  if not bIsRandom then
    if not logic_wardrobe_tag_mgr:IsTimeFilterEnabled() then
      return itemListTable
    end
    local StartTimeInfo, EndTimeInfo = logic_wardrobe_tag_mgr:GetSelectedTimeInfo()
    if StartTimeInfo and StartTimeInfo.Year and StartTimeInfo.Month then
      StartTime = self:ObtainFirstSecond(StartTimeInfo.Year, StartTimeInfo.Month)
    end
    if EndTimeInfo and EndTimeInfo.Year and EndTimeInfo.Month then
      EndTime = self:ObtainLastSecond(EndTimeInfo.Year, EndTimeInfo.Month)
    end
  elseif self.tRandomFilterInfo and self.tRandomFilterInfo.obtain_ts_info then
    StartTime = self.tRandomFilterInfo.obtain_ts_info.start_ts or 0
    EndTime = self.tRandomFilterInfo.obtain_ts_info.end_ts or 0
  end
  if not StartTime and not EndTime then
    return itemListTable
  end
  if StartTime == 0 and EndTime == 0 then
    return itemListTable
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for _, v in pairs(itemListTable) do
    local insId = v.part1
    if insId and 0 < insId then
      local GetTime = logic_wardrobe_new:ExtractHigh32Bits(insId)
      if (StartTime == 0 or StartTime < GetTime) and (EndTime == 0 or EndTime > GetTime) then
        result[#result + 1] = v
      end
    end
  end
  return result
end
function logic_outfit_combination:GetMatchTypeSortTypeList()
  return {
    [ENUM_MATCH_TAB_SORT_TYPE.QUALITY] = {
      type = ENUM_MATCH_TAB_SORT_TYPE.QUALITY,
      text = LocUtil.GetLocalizeResStr(48884)
    },
    [ENUM_MATCH_TAB_SORT_TYPE.LATEST] = {
      type = ENUM_MATCH_TAB_SORT_TYPE.LATEST,
      text = LocUtil.GetLocalizeResStr(48883)
    },
    [ENUM_MATCH_TAB_SORT_TYPE.TIMES] = {
      type = ENUM_MATCH_TAB_SORT_TYPE.TIMES,
      text = LocUtil.GetLocalizeResStr(86225)
    }
  }
end
function logic_outfit_combination:SortMatchTabList(suitList)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local SortPreference = WardrobeLogicManager:GetMatchTabSortPreference()
  table.sort(suitList, WardrobeLogicManager:GetSortCmpFunction(SortPreference == ENUM_MATCH_TAB_SORT_TYPE.LATEST, nil, true, SortPreference == ENUM_MATCH_TAB_SORT_TYPE.TIMES))
end
function logic_outfit_combination:IsSuitWearing(suitData)
  for i = 1, partNum do
    local insId = suitData["part" .. tostring(i)]
    if insId ~= nil and not AvatarData.CheckWearItem(insId) then
      return false
    end
  end
  return true
end
function logic_outfit_combination:IsOpenRandom()
  if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_RANDOM_SUIT) then
    log(bWriteLog and string.format("logic_outfit_combination:IsOpenRandom BP_ENUM_WARDROBE_RANDOM_SUIT is false"))
    return false
  end
  log(bWriteLog and string.format("logic_outfit_combination:IsOpenRandom self.bOpenRandom = %s", self.bOpenRandom))
  return self.bOpenRandom
end
function logic_outfit_combination:SetOpenRandomByServer(isOpen)
  log(bWriteLog and string.format("logic_outfit_combination:SetOpenRandomByServer isOpen: %s", isOpen))
  self.bOpenRandom = isOpen
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_outfit_combination)
return CModuleTemplate
local logic_wardrobe_tag_mgr = {
  EnumTagType_Corner = 1,
  EnumTagType_Custom = 2,
  EnumTagType_Time = 3,
  CUSTOM_TAG_COUNT = 6,
  TAG_COLOR_MAP = {
    FLinearColor(0.137, 0.137, 0.137, 1),
    FLinearColor(0.823, 0.027, 0.082, 1),
    FLinearColor(0.101, 0.643, 0.254, 1),
    FLinearColor(0.086, 0.172, 0.929, 1),
    FLinearColor(0.011, 0.011, 0.474, 1),
    FLinearColor(0.975, 0.958, 0.003, 1)
  },
  CONST_MIN_YEAR_GLOBAL = 2018,
  CONST_MIN_YEAR_BLUEHOLE = 2021
}
function logic_wardrobe_tag_mgr:ctor()
end
function logic_wardrobe_tag_mgr:DefineAndResetData()
  self:ClearData()
end
function logic_wardrobe_tag_mgr:OnLogOut()
  self:ClearData()
end
function logic_wardrobe_tag_mgr:ClearData()
  self._CustomTagList = nil
  self._SelectedData = {}
  self._CornerTagList = nil
  self._ItemID2CustomTagList = nil
  self._TempOriginalResID = nil
  self._TempResID = nil
  self._TempItemTagList = nil
  self._AllSelectTagList = nil
  self._bSelectTimeEnable = false
  self._CurrentItemList = nil
  self._CornerTag2Count = nil
  self._CustomTag2Count = nil
end
function logic_wardrobe_tag_mgr:ClearSelectedData()
  self._SelectedData = {}
  self:UpdateAllFilterList()
end
function logic_wardrobe_tag_mgr:RegistEvents()
  logic_wardrobe_tag_mgr.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE, self.OnWardrobeClose, self)
end
function logic_wardrobe_tag_mgr:GetCornerTagList()
  if self._CornerTagList then
    return self._CornerTagList
  end
  local CornerTagList = {}
  local CornerTagToIndex = {}
  local TempFlag = {}
  local CornerCfg = CDataTable.GetTable("NewCornerIconTypeConfig")
  for _, TypeCfg in pairs(CornerCfg) do
    if not TempFlag[TypeCfg.TypeID] then
      TempFlag[TypeCfg.TypeID] = true
      local index = #CornerTagList + 1
      CornerTagList[index] = {
        tag_key = TypeCfg.TypeID,
        tag_type = logic_wardrobe_tag_mgr.EnumTagType_Corner
      }
      CornerTagToIndex[TypeCfg.TypeID] = index
    end
  end
  self._  self._  return self._CornerTagList
end
function logic_wardrobe_tag_mgr:GetCustomTagList()
  if not self._CustomTagList then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_query_depot_tag_req()
    return
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE, self._CustomTagList)
end
function logic_wardrobe_tag_mgr:SetTagNames(tagList)
  if not tagList then
    return
  end
  local realChangeTagList
  if self._CustomTagList then
    realChangeTagList = {}
    for i = 1, logic_wardrobe_tag_mgr.CUSTOM_TAG_COUNT do
      local newTag = tagList[i]
      local oldTag = self._CustomTagList[i] and self._CustomTagList[i].tag_name
      if newTag ~= oldTag then
        realChangeTagList[i] = newTag
      end
    end
  else
    realChangeTagList = tagList
  end
  if realChangeTagList and next(realChangeTagList) then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_change_depot_tag_name_req(realChangeTagList)
  end
end
function logic_wardrobe_tag_mgr:SetFilterEnabled(index, bEnable)
  if not index then
    return
  end
  if not self._AllSelectTagList or not self._AllSelectTagList[index] then
    return
  end
  local data = self._AllSelectTagList[index]
  data.status = bEnable
  local tagType = data.tagData and data.tagData.tag_type
  local tagKey = data.tagData and data.tagData.tag_key
  if tagType == logic_wardrobe_tag_mgr.EnumTagType_Corner then
    if tagKey then
      local selectCornerTag = self:GetSelectedCornerTagList()
      selectCornerTag[tagKey] = bEnable
    end
  elseif tagType == logic_wardrobe_tag_mgr.EnumTagType_Custom then
    if tagKey then
      local selectCustomTag = self:GetSelectedCustomTagList()
      selectCustomTag[tagKey] = bEnable
    end
  elseif tagType == logic_wardrobe_tag_mgr.EnumTagType_Time then
    self._bSelectTimeEnable = bEnable
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_FILTER_UPDATE)
end
function logic_wardrobe_tag_mgr:UpdateAllFilterList()
  self._AllSelectTagList = {}
  local AllSelectTagList = self._AllSelectTagList
  local selectCustomTag = self:GetSelectedCustomTagList()
  local selectCornerTag = self:GetSelectedCornerTagList()
  local CornerTagList = self:GetCornerTagList()
  if selectCornerTag and next(selectCornerTag) then
    for tagKey, bSelected in pairs(selectCornerTag) do
      if bSelected then
        local tagIndex = self._CornerTagToIndex and self._CornerTagToIndex[tagKey]
        if tagIndex then
          AllSelectTagList[#AllSelectTagList + 1] = {
            tagData = CornerTagList[tagIndex],
            status = true
          }
        end
      end
    end
  end
  if self._CustomTagList and selectCustomTag and next(selectCustomTag) then
    for tagKey, bSelected in pairs(selectCustomTag) do
      if bSelected then
        AllSelectTagList[#AllSelectTagList + 1] = {
          tagData = self._CustomTagList[tagKey] or {},
          status = true
        }
      end
    end
  end
  local startTime, endTime = self:GetSelectedTimeInfo()
  if startTime or endTime then
    self._bSelectTimeEnable = true
    AllSelectTagList[#AllSelectTagList + 1] = {
      tagData = {
        tag_type = logic_wardrobe_tag_mgr.EnumTagType_Time,
        StartTime = startTime,
        EndTime = endTime
      },
      status = true
    }
  else
    self._bSelectTimeEnable = false
  end
end
function logic_wardrobe_tag_mgr:GetAllFilterList()
  return self._AllSelectTagList
end
function logic_wardrobe_tag_mgr:GetTagListByItemID(itemID)
  if not itemID then
    return nil
  end
  local MappedItemID = self:_GetMappedItemIDForCustomTag(itemID)
  if MappedItemID == self._TempResID and self._TempItemTagList then
    return self._TempItemTagList
  end
  return self._ItemID2CustomTagList and self._ItemID2CustomTagList[MappedItemID]
end
function logic_wardrobe_tag_mgr:ConfirmSelection(CornerTagList, CustomTagList, DateInfo, bRefresh)
  self:SetSelectedCornerTagList(CornerTagList)
  self:SetSelectedCustomTagList(CustomTagList)
  DateInfo = DateInfo or {}
  local StartYear = DateInfo.StartYear
  local StartMonth = DateInfo.StartMonth
  local startTime = StartYear and StartMonth and {Year = StartYear, Month = StartMonth}
  local EndYear = DateInfo.EndYear
  local EndMonth = DateInfo.EndMonth
  local endTime = EndYear and EndMonth and {Year = EndYear, Month = EndMonth}
  self:SetSelectedTimeInfo(startTime, endTime)
  self:UpdateAllFilterList()
  if bRefresh ~= false then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_FILTER_UPDATE)
  else
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE)
  end
end
function logic_wardrobe_tag_mgr:AddOrRemoveItemToTag(OriginalResID, tagKey)
  if not OriginalResID or not tagKey then
    return
  end
  local MappedItemID = self:_GetMappedItemIDForCustomTag(OriginalResID)
  if self._TempOriginalResID ~= OriginalResID or not self._TempItemTagList then
    local tagList = self:GetTagListByItemID(MappedItemID) or {}
    self._Temp    self._TempResID = MappedItemID
    local TableUtil = require("common.table_util")
    self._TempItemTagList = TableUtil.CopyTable(tagList)
  end
  if self._TempItemTagList[tagKey] then
    self._TempItemTagList[tagKey] = nil
  else
    self._TempItemTagList[tagKey] = true
  end
end
function logic_wardrobe_tag_mgr:ConfirmEditItemTags()
  if not self._TempOriginalResID then
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  local originalResID = self._TempOriginalResID
  local nMappedItemID = self._TempResID
  self._TempResID = nil
  self._TempOriginalResID = nil
  local OriginTagList = self:GetTagListByItemID(originalResID) or {}
  local TempTagList = self._TempItemTagList or {}
  local AddTagList = {}
  local DelTagList = {}
  for tagKey, _ in pairs(TempTagList) do
    if not OriginTagList[tagKey] then
      AddTagList[tagKey] = 1
    end
  end
  for tagKey, _ in pairs(OriginTagList) do
    if not TempTagList[tagKey] then
      DelTagList[tagKey] = 1
    end
  end
  if next(AddTagList) or next(DelTagList) then
    local BaseItemID = self:_GetLevelOnlyBaseItemID(originalResID)
    WardRobeHandler.send_set_res_tag_req(BaseItemID, AddTagList, DelTagList)
  end
  self._TempItemTagList = nil
end
function logic_wardrobe_tag_mgr:CancelEditItemTags()
  self._TempItemTagList = nil
  self._TempResID = nil
  self._TempOriginalResID = nil
end
function logic_wardrobe_tag_mgr:AddItemToDefaultTagDirect(ItemID)
  if not ItemID then
    log_warning(bWriteLog and "logic_wardrobe_tag_mgr:AddItemToDefaultTagDirect ItemID is invlid, ignore.")
    return
  end
  local BaseItemID = self:_GetLevelOnlyBaseItemID(ItemID)
  local MappedItemID = self:_GetMappedItemIDForCustomTag(ItemID)
  local CurrentTagList = self:GetTagListByItemID(MappedItemID)
  if CurrentTagList and next(CurrentTagList) then
    log_warning(bWriteLog and "logic_wardrobe_tag_mgr:AddItemToDefaultTagDirect tag is already exists for item: " .. tostring(ItemID))
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_set_res_tag_req(BaseItemID, {1}, {})
end
function logic_wardrobe_tag_mgr:RemoveAllTagDirect(ItemID)
  if not ItemID then
    log_warning(bWriteLog and "logic_wardrobe_tag_mgr:RemoveAllTagDirect ItemID is invlid, ignore.")
    return
  end
  local BaseItemID = self:_GetLevelOnlyBaseItemID(ItemID)
  local MappedItemID = self:_GetMappedItemIDForCustomTag(ItemID)
  local CurrentTagList = self:GetTagListByItemID(MappedItemID)
  if not CurrentTagList or not next(CurrentTagList) then
    log_warning(bWriteLog and "logic_wardrobe_tag_mgr:RemoveAllTagDirect no tag exists for item: " .. tostring(ItemID) .. " mappitemid: " .. tostring(MappedItemID))
    return
  end
  local RemoveKeys = {}
  for k, v in pairs(CurrentTagList) do
    if v then
      RemoveKeys[k] = 1
    end
  end
  if next(RemoveKeys) then
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_set_res_tag_req(BaseItemID, {}, RemoveKeys)
  end
end
function logic_wardrobe_tag_mgr:HasEnabledCornerTag()
  local selectCornerTag = self:GetSelectedCornerTagList()
  if not selectCornerTag or not next(selectCornerTag) then
    return false
  end
  for _, status in pairs(selectCornerTag) do
    if status then
      return true
    end
  end
  return false
end
function logic_wardrobe_tag_mgr:IsItemMatchCornerTag(resID)
  if not resID then
    return false
  end
  local selectCornerTag = self:GetSelectedCornerTagList()
  if not selectCornerTag or not next(selectCornerTag) then
    return true
  end
  for tagKey, status in pairs(selectCornerTag) do
    if status then
      return true
    end
  end
  return false
end
function logic_wardrobe_tag_mgr:HasEnabledCustomTag()
  local selectCustomTag = self:GetSelectedCustomTagList()
  if not selectCustomTag or not next(selectCustomTag) then
    return false
  end
  for _, status in pairs(selectCustomTag) do
    if status then
      return true
    end
  end
  return false
end
function logic_wardrobe_tag_mgr:IsItemMatchCustomTag(resID)
  if not resID then
    return false
  end
  local MappedItemID = self:_GetMappedItemIDForCustomTag(resID)
  local selectCustomTag = self:GetSelectedCustomTagList()
  if not selectCustomTag or not next(selectCustomTag) then
    return true
  end
  if self._CustomTagMap then
    for tagKey, status in pairs(selectCustomTag) do
      if status and self._CustomTagMap[tagKey] and self._CustomTagMap[tagKey][MappedItemID] then
        return true
      end
    end
  end
  return false
end
function logic_wardrobe_tag_mgr:IsTimeFilterEnabled()
  return self._bSelectTimeEnable
end
function logic_wardrobe_tag_mgr:RspQueryDepotTag(depot_tag_list)
  depot_tag_list = depot_tag_list or {}
  self._CustomTagList = {}
  self._ItemID2CustomTagList = {}
  self._CustomTagMap = {}
  for tagKey = 1, logic_wardrobe_tag_mgr.CUSTOM_TAG_COUNT do
    local tagCfg = depot_tag_list[tagKey]
    self._CustomTagList[tagKey] = {
      tag_key = tagKey,
      tag_type = logic_wardrobe_tag_mgr.EnumTagType_Custom,
      tag_name = tagCfg and tagCfg.tag_name
    }
    self._CustomTagMap[tagKey] = tagCfg and tagCfg.res_data or {}
    local res_data = self._CustomTagMap[tagKey]
    if res_data and next(res_data) then
      for resID, _ in pairs(res_data) do
        local MappedItemID = self:_GetMappedItemIDForCustomTag(resID)
        if MappedItemID then
          if not self._ItemID2CustomTagList[MappedItemID] then
            self._ItemID2CustomTagList[MappedItemID] = {}
          end
          self._ItemID2CustomTagList[MappedItemID][tagKey] = true
        end
      end
    end
  end
  self:_RecountCustomTagItems()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE, self._CustomTagList)
end
function logic_wardrobe_tag_mgr:RspSetItemTag(res_id, add_tag_list, remove_tag_list)
  if not res_id then
    return
  end
  if not self._ItemID2CustomTagList or not self._CustomTagMap then
    return
  end
  local MappedItemID = self:_GetMappedItemIDForCustomTag(res_id)
  if not self._ItemID2CustomTagList[MappedItemID] then
    self._ItemID2CustomTagList[MappedItemID] = {}
  end
  if add_tag_list and next(add_tag_list) then
    for tagKey, _ in pairs(add_tag_list) do
      if not self._CustomTagMap[tagKey] then
        self._CustomTagMap[tagKey] = {}
      end
      self._CustomTagMap[tagKey][MappedItemID] = true
      self._ItemID2CustomTagList[MappedItemID][tagKey] = true
    end
  end
  if remove_tag_list and next(remove_tag_list) then
    for tagKey, _ in pairs(remove_tag_list) do
      if self._CustomTagMap[tagKey] then
        self._CustomTagMap[tagKey][MappedItemID] = nil
      end
      self._ItemID2CustomTagList[MappedItemID][tagKey] = nil
    end
  end
  self:_RecountCustomTagItems()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_TAG_CHANGE)
end
function logic_wardrobe_tag_mgr:RspSetItemName(tag_list)
  if not tag_list then
    return
  end
  if not self._CustomTagList then
    return
  end
  for tag_key, tag_name in pairs(tag_list) do
    if self._CustomTagList[tag_key] then
      self._CustomTagList[tag_key].    end
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_TAG_DATA_UPDATE, self._CustomTagList)
end
function logic_wardrobe_tag_mgr:_GetMappedItemIDForCustomTag(ItemID)
  if not ItemID then
    return nil
  end
  local Cfg = CDataTable.GetTableData("ShareTagItemMap", ItemID)
  return Cfg and Cfg.MappedItemID or ItemID
end
function logic_wardrobe_tag_mgr:GetMinYear()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return self.CONST_MIN_YEAR_BLUEHOLE
  end
  return self.CONST_MIN_YEAR_GLOBAL
end
function logic_wardrobe_tag_mgr:UpdateItemList(ItemList)
  if self._CurrentItemList == ItemList then
    return
  end
  self._Current  self:RecountTagItems()
end
function logic_wardrobe_tag_mgr:ClearItemList()
  log(bWriteLog and "[tag] logic_wardrobe_tag_mgr:ClearItemList")
  self._CurrentItemList = nil
  self._CornerTag2Count = nil
  self._CustomTag2Count = nil
end
function logic_wardrobe_tag_mgr:RecountTagItems()
  self:_RecountCornerTagItems()
  self:_RecountCustomTagItems()
end
function logic_wardrobe_tag_mgr:_RecountCornerTagItems()
  self._CornerTag2Count = {}
  if not self._CurrentItemList or not next(self._CurrentItemList) then
    return
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  local countedItemID = {}
  for _, v in pairs(self._CurrentItemList) do
    local ItemID = v.res_id or v.resID
    if (not LogicFusionModule or not LogicFusionModule:IsFusionTargetItem(ItemID)) and not countedItemID[ItemID] then
      if self._CornerTagList then
        local itemData = CDataTable.GetTableData("Item", ItemID)
        if itemData then
          local SpecialIcon = itemData.SpecialIcon
          if SpecialIcon then
            local CornerTag = CDataTable.GetTableData("NewCornerIconTypeConfig", SpecialIcon)
            if CornerTag and CornerTag.TypeID then
              for __, vv in pairs(self._CornerTagList) do
                if CornerTag.TypeID == vv.tag_key then
                  if not self._CornerTag2Count[vv.tag_key] then
                    self._CornerTag2Count[vv.tag_key] = 1
                  else
                    self._CornerTag2Count[vv.tag_key] = self._CornerTag2Count[vv.tag_key] + 1
                  end
                end
              end
            end
          end
        end
      end
      countedItemID[ItemID] = true
      local CartoonStyleCfg = CDataTable.GetTableData("CartoonStyleCfg", ItemID)
      if CartoonStyleCfg and CartoonStyleCfg.CartoonStyleID and CartoonStyleCfg.CartoonStyleID ~= 0 then
        countedItemID[CartoonStyleCfg.CartoonStyleID] = true
      end
      CartoonStyleCfg = CDataTable.GetTableDataByFilter("CartoonStyleCfg", "CartoonStyleID", ItemID)
      if CartoonStyleCfg and CartoonStyleCfg.BaseID and CartoonStyleCfg.BaseID ~= 0 then
        countedItemID[CartoonStyleCfg.BaseID] = true
      end
      local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", ItemID)
      if MultiLevelItemCfg and MultiLevelItemCfg.GroupID ~= 0 and MultiLevelItemCfg.ShowType ~= LogicMultiItemModule.ENUM_SHOWTYPE.None then
        local MultiLevelItemGroupData = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", MultiLevelItemCfg.GroupID)
        if MultiLevelItemGroupData then
          for __, GroupItemCfg in pairs(MultiLevelItemGroupData) do
            if GroupItemCfg and GroupItemCfg.ItemID ~= 0 and GroupItemCfg.ItemID ~= ItemID then
              countedItemID[GroupItemCfg.ItemID] = true
            end
          end
        end
      end
    end
  end
end
function logic_wardrobe_tag_mgr:_RecountCustomTagItems()
  self._CustomTag2Count = {}
  if not self._CurrentItemList or not next(self._CurrentItemList) then
    return
  end
  if not self._ItemID2CustomTagList then
    return
  end
  local tTagRecord = {}
  for _, v in pairs(self._CurrentItemList) do
    local ItemID = v.res_id or v.resID
    local MappedItemID = self:_GetMappedItemIDForCustomTag(ItemID)
    if self._ItemID2CustomTagList[MappedItemID] then
      for tagKey, status in pairs(self._ItemID2CustomTagList[MappedItemID]) do
        if status and (not tTagRecord[tagKey] or not tTagRecord[tagKey][MappedItemID]) then
          if not self._CustomTag2Count[tagKey] then
            self._CustomTag2Count[tagKey] = 1
          else
            self._CustomTag2Count[tagKey] = self._CustomTag2Count[tagKey] + 1
          end
          if not tTagRecord[tagKey] then
            tTagRecord[tagKey] = {}
          end
          tTagRecord[tagKey][MappedItemID] = true
        end
      end
    end
  end
end
function logic_wardrobe_tag_mgr:GetTagItemCount(TagType, TagKey)
  if not TagType or not TagKey then
    return 0
  end
  if TagType == logic_wardrobe_tag_mgr.EnumTagType_Corner then
    return self._CornerTag2Count and self._CornerTag2Count[TagKey] or 0
  elseif TagType == logic_wardrobe_tag_mgr.EnumTagType_Custom then
    return self._CustomTag2Count and self._CustomTag2Count[TagKey] or 0
  end
  return 0
end
function logic_wardrobe_tag_mgr:OnWardrobeClose()
  self:ClearItemList()
end
function logic_wardrobe_tag_mgr:GetDefaultTagName(index)
  index = index or ""
  local tagName = LocUtil.LocalizeResFormat(65490, index)
  local StringUtil = require("common.string_util")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  tagName = StringUtil.CheckNameRetrunName(tagName, true, wardrobe_macro.MAX_TAG_NAME_LENGTH)
  return tagName
end
function logic_wardrobe_tag_mgr:_GetLevelOnlyBaseItemID(ItemID)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:Is2LevelParticleEmote(ItemID) then
    return LogicParticleEmote:GetBaseID(ItemID)
  end
  return ItemID
end
function logic_wardrobe_tag_mgr:IsCurrentPageTagPreserved()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local tabId = logic_wardrobe:GetCurrentPageId()
  local operationData = self:GetLocalOperationData()
  local bResult = false
  if tabId and operationData and operationData[tabId] then
    bResult = operationData[tabId].SelectCheckSaveOperation == 1
  end
  log(bWriteLog and string.format("logic_wardrobe_tag_mgr:IsCurrentPageTagPreserved. tabId=%s, result=%s", tostring(tabId), tostring(bResult)))
  return bResult
end
function logic_wardrobe_tag_mgr:SaveLocalOperationData(operationData)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local pType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSaveOperation
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogic:IsInInheritMode() then
    pType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSaveOperation_Inherit
  end
  PlayerPrefsSystem.SaveTableToFile_N(operationData, pType)
end
function logic_wardrobe_tag_mgr:GetLocalOperationData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local pType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSaveOperation
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogic:IsInInheritMode() then
    pType = PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSaveOperation_Inherit
  end
  local operationData = PlayerPrefsSystem.LoadFileToTable_N(pType) or {}
  return operationData
end
function logic_wardrobe_tag_mgr:GetSelectedData()
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local mode = WardrobeMacro.EWardrobeEditMode.None
  if WardrobeLogic:IsInInheritMode() then
    mode = WardrobeMacro.EWardrobeEditMode.Inherit
  end
  if not self._SelectedData[mode] then
    self._SelectedData[mode] = {}
  end
  return self._SelectedData[mode]
end
function logic_wardrobe_tag_mgr:GetSelectedCornerTagList()
  local data = self:GetSelectedData()
  return data._SelectedCornerTagList or {}
end
function logic_wardrobe_tag_mgr:SetSelectedCornerTagList(CornerTagList)
  local TableUtil = require("common.table_util")
  local data = self:GetSelectedData()
  data._SelectedCornerTagList = TableUtil.CopyTable(CornerTagList) or {}
end
function logic_wardrobe_tag_mgr:GetSelectedCustomTagList()
  local data = self:GetSelectedData()
  return data._SelectedCustomTagList or {}
end
function logic_wardrobe_tag_mgr:SetSelectedCustomTagList(CustomTagList)
  local TableUtil = require("common.table_util")
  local data = self:GetSelectedData()
  data._SelectedCustomTagList = TableUtil.CopyTable(CustomTagList) or {}
end
function logic_wardrobe_tag_mgr:GetSelectedTimeInfo()
  local data = self:GetSelectedData()
  return data._SelectStartTime, data._SelectEndTime
end
function logic_wardrobe_tag_mgr:SetSelectedTimeInfo(startTime, endTime)
  local data = self:GetSelectedData()
  data._SelectStartTime = startTime
  data._SelectEndTime = endTime
end
function logic_wardrobe_tag_mgr:GetCustomTagMap()
  return self._CustomTagMap
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_wardrobe_tag_mgr = class(CModuleBase, nil, logic_wardrobe_tag_mgr)
return Clogic_wardrobe_tag_mgr
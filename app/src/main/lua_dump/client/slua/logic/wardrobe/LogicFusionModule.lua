local LogicFusionModule = {}
function LogicFusionModule:DefineAndResetData()
  self.FusionConfig = {}
  self.ItemToFusionConfigMap = {}
  self.FusionRecord = nil
  self.FusionPreviewRecord = {}
  self.DisplayItemMap = {}
  self.FashionBagFusionRecord = {}
end
function LogicFusionModule:OnInitialize()
  self:Init()
end
function LogicFusionModule:RegistEvents()
end
function LogicFusionModule:Init()
  log(bWriteLog and "LogicFusionModule:Init")
  local FusionFeatureConfig = CDataTable.GetTable("FusionFeatureConfig")
  if FusionFeatureConfig then
    for _, config in pairs(FusionFeatureConfig) do
      local period = config.Period
      local originItem = config.OriginItem
      local targetItem = config.TargetItem
      if not self.FusionConfig[period] then
        self.FusionConfig[period] = {
          period = period,
          originItems = {},
                  }
        self.ItemToFusionConfigMap[targetItem] = self.FusionConfig[period]
      end
      table.insert(self.FusionConfig[period].originItems, originItem)
      self.ItemToFusionConfigMap[originItem] = self.FusionConfig[period]
      if config.DisplayItem and config.DisplayItem ~= 0 then
        self.DisplayItemMap[originItem] = config.DisplayItem
      end
    end
  end
  local ClothFusionHandler = require("client.network.Protocol.ClothFusionHandler")
  ClothFusionHandler.send_get_taluo_change_wear_info_req()
end
function LogicFusionModule:IsFusionItem(itemID)
  return self.ItemToFusionConfigMap[itemID] ~= nil
end
function LogicFusionModule:IsFusionTargetItem(itemID)
  if self.ItemToFusionConfigMap[itemID] then
    return self.ItemToFusionConfigMap[itemID].targetItem == itemID
  end
  return false
end
function LogicFusionModule:GetDisplayItem(itemID)
  return self.DisplayItemMap[itemID]
end
function LogicFusionModule:GetFusionIconPath(originItem, isBase)
  if not originItem or originItem == 0 then
    return nil
  end
  local rows = CDataTable.GetTableByFilter("FusionFeatureConfig", "OriginItem", originItem)
  local config
  if rows then
    for _, row in pairs(rows) do
      config = row
      break
    end
  end
  if not config then
    return nil
  end
  if isBase then
    return {
      usingIconPath = config.BaseIconPathSelect ~= "" and config.BaseIconPathSelect or config.BaseIconPath,
      notUsingIconPath = config.BaseIconPath
    }
  else
    return {
      usingIconPath = config.FusionIconPathSelect ~= "" and config.FusionIconPathSelect or config.FusionIconPath,
      notUsingIconPath = config.FusionIconPath
    }
  end
end
function LogicFusionModule:GetFusionConfig(itemID)
  return self.ItemToFusionConfigMap[itemID]
end
function LogicFusionModule:SetFusionPreviewPre(period, preItemId)
  if not period or period <= 0 then
    return
  end
  self.FusionPreviewRecord[period] = preItemId
end
function LogicFusionModule:GetFusionPreviewPre(period)
  if not period or period <= 0 then
    return 0
  end
  return self.FusionPreviewRecord[period] or 0
end
function LogicFusionModule:ClearFusionPreviewPre(period)
  if period then
    self.FusionPreviewRecord[period] = nil
  else
    self.FusionPreviewRecord = {}
  end
end
function LogicFusionModule:SetFusionRecord(info)
  info = info or {}
  local changedPeriods = {}
  local bFirstLoad = not self.FusionRecord
  if not bFirstLoad then
    for period, newRecord in pairs(info) do
      local oldRecord = self.FusionRecord[period]
      if not oldRecord or oldRecord.pre_item_id ~= newRecord.pre_item_id or oldRecord.current_item_id ~= newRecord.current_item_id then
        changedPeriods[period] = true
      end
    end
    for period in pairs(self.FusionRecord) do
      if not info[period] then
        changedPeriods[period] = true
      end
    end
  end
  self.FusionRecord = info
  log_tree("LogicFusionModule:SetFusionRecord", self.FusionRecord)
  if bFirstLoad or next(changedPeriods) then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOTH_FUSION_UPDATE, changedPeriods)
  end
end
local IsInFashionBagEditMode = function()
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  return logic_wardrobe:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.FashionBag
end
local NormalizeFashionBagIndex = function(index)
  if index == 6 then
    return 5
  end
  return index
end
local GetCurrentEditingFashionBagIndex = function()
  if not IsInFashionBagEditMode() then
    return nil
  end
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  if not FashionBagEditUtils then
    return nil
  end
  local index = FashionBagEditUtils:GetCurrentEditIndex()
  return NormalizeFashionBagIndex(index)
end
function LogicFusionModule:GetEditingFashionBagFusionRecord(period)
  local index = GetCurrentEditingFashionBagIndex()
  if not index or not period then
    return nil
  end
  local record = self.FashionBagFusionRecord and self.FashionBagFusionRecord[index]
  return record and record[period] or nil
end
function LogicFusionModule:_SetEditingFashionBagFusionRecord(period, pre_item_id, current_item_id)
  local index = GetCurrentEditingFashionBagIndex()
  if not index or not period then
    return
  end
  self.FashionBagFusionRecord = self.FashionBagFusionRecord or {}
  self.FashionBagFusionRecord[index] = self.FashionBagFusionRecord[index] or {}
  if pre_item_id == nil and current_item_id == nil then
    self.FashionBagFusionRecord[index][period] = nil
  else
    self.FashionBagFusionRecord[index][period] = {pre_item_id = pre_item_id, current_item_id = current_item_id}
  end
end
function LogicFusionModule:GetFusionRecord(period)
  if IsInFashionBagEditMode() then
    return self:GetEditingFashionBagFusionRecord(period)
  end
  if not self.FusionRecord then
    local ClothFusionHandler = require("client.network.Protocol.ClothFusionHandler")
    ClothFusionHandler.send_get_taluo_change_wear_info_req()
    return nil
  end
  return self.FusionRecord[period]
end
function LogicFusionModule:TryUpdateFusionRecord(pre_item_id, current_item_id)
  log(bWriteLog and "LogicFusionModule:TryUpdateFusionRecord pre_item_id:" .. tostring(pre_item_id) .. " current_item_id:" .. tostring(current_item_id))
  local preItemConfig = self:GetFusionConfig(pre_item_id)
  local currentItemConfig = self:GetFusionConfig(current_item_id)
  if not preItemConfig or not currentItemConfig then
    log(bWriteLog and "LogicFusionModule:TryUpdateFusionRecord preItemConfig or currentItemConfig is nil")
    return
  end
  if preItemConfig.period ~= currentItemConfig.period then
    log(bWriteLog and "LogicFusionModule:TryUpdateFusionRecord preItemConfig.period ~= currentItemConfig.period")
    return
  end
  local period = preItemConfig.period
  if IsInFashionBagEditMode() then
    if self:IsFusionTargetItem(current_item_id) then
      local editingRecord = self:GetEditingFashionBagFusionRecord(period)
      if editingRecord and editingRecord.pre_item_id == pre_item_id and editingRecord.current_item_id == current_item_id then
        log(bWriteLog and "LogicFusionModule:TryUpdateFusionRecord editing record is the same")
        return
      end
      self:_SetEditingFashionBagFusionRecord(period, pre_item_id, current_item_id)
    else
      self:_SetEditingFashionBagFusionRecord(period, nil, nil)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_UPDATE)
    return
  end
  local record = self:GetFusionRecord(period)
  if record and record.pre_item_id == pre_item_id and record.current_item_id == current_item_id then
    log(bWriteLog and "LogicFusionModule:TryUpdateFusionRecord record is the same")
    return
  end
  local ClothFusionHandler = require("client.network.Protocol.ClothFusionHandler")
  ClothFusionHandler.send_set_taluo_change_wear_info_req(period, pre_item_id, current_item_id)
end
function LogicFusionModule:BuildFashionBagEditingFusionRecord(currentWearList)
  local snapshot = {}
  if not self.FusionConfig or not next(self.FusionConfig) then
    return snapshot
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local periodToWornResId = {}
  if currentWearList then
    for _, insID in pairs(currentWearList) do
      local itemData = insID and wardrobe_data:GetHallDepotItemDataByInsID(insID)
      local resID = itemData and itemData.resID
      local config = resID and self.ItemToFusionConfigMap[resID]
      if config then
        periodToWornResId[config.period] = resID
      end
    end
  end
  for period, config in pairs(self.FusionConfig) do
    local wornResId = periodToWornResId[period]
    if wornResId == config.targetItem then
      local backendRecord = self.FusionRecord and self.FusionRecord[period]
      local preItemId
      if backendRecord and backendRecord.pre_item_id then
        for _, originItem in ipairs(config.originItems) do
          if originItem == backendRecord.pre_item_id then
            preItemId = backendRecord.pre_item_id
            break
          end
        end
      end
      preItemId = preItemId or config.originItems[1]
      snapshot[period] = {
        pre_item_id = preItemId,
        current_item_id = config.targetItem
      }
    end
  end
  log_tree("LogicFusionModule:BuildFashionBagEditingFusionRecord", snapshot)
  return snapshot
end
function LogicFusionModule:BeginFashionBagEdit(Index, currentWearList)
  if not Index then
    return
  end
  local key = NormalizeFashionBagIndex(Index)
  self.FashionBagFusionRecord = self.FashionBagFusionRecord or {}
  self.FashionBagFusionRecord[key] = self:BuildFashionBagEditingFusionRecord(currentWearList)
  log(bWriteLog and string.format("LogicFusionModule:BeginFashionBagEdit Index=%s key=%s", tostring(Index), tostring(key)))
end
function LogicFusionModule:CommitFashionBagFusionRecord(Index)
  if not Index then
    return
  end
  local key = NormalizeFashionBagIndex(Index)
  local record = self.FashionBagFusionRecord and self.FashionBagFusionRecord[key]
  if not record or not next(record) then
    log(bWriteLog and string.format("LogicFusionModule:CommitFashionBagFusionRecord no record for Index=%s key=%s", tostring(Index), tostring(key)))
    return
  end
  local ClothFusionHandler = require("client.network.Protocol.ClothFusionHandler")
  local backend = self.FusionRecord or {}
  for period, r in pairs(record) do
    local oldRecord = backend[period]
    if not oldRecord or oldRecord.pre_item_id ~= r.pre_item_id or oldRecord.current_item_id ~= r.current_item_id then
      log(bWriteLog and string.format("LogicFusionModule:CommitFashionBagFusionRecord Index=%s period=%s pre=%s cur=%s", tostring(Index), tostring(period), tostring(r.pre_item_id), tostring(r.current_item_id)))
      ClothFusionHandler.send_set_taluo_change_wear_info_req(period, r.pre_item_id, r.current_item_id)
    end
  end
end
function LogicFusionModule:SyncFashionBagEditingOnWear(oldResId, newResId)
  if not IsInFashionBagEditMode() then
    return
  end
  if newResId and newResId ~= 0 then
    local newCfg = self.ItemToFusionConfigMap[newResId]
    if newCfg and newResId ~= newCfg.targetItem then
      self:_SetEditingFashionBagFusionRecord(newCfg.period, nil, nil)
      return
    end
  end
  if (not newResId or newResId == 0) and oldResId and oldResId ~= 0 then
    local oldCfg = self.ItemToFusionConfigMap[oldResId]
    if oldCfg then
      self:_SetEditingFashionBagFusionRecord(oldCfg.period, nil, nil)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicFusionModule = class(CModuleBase, nil, LogicFusionModule)
return CLogicFusionModule
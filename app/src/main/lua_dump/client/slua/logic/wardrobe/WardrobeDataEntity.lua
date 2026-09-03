local WardrobeDataEntity = {}
local bOpenLog = false
local ITEM_CONFIG_FIELDS = {
  "ItemType",
  "ItemSubType",
  "WardrobeMainTab",
  "WardrobeTab",
  "ItemQuality"
}
function WardrobeDataEntity:ctor(_, _DataSource)
  self.DataSource = _DataSource
  self:Construct()
end
function WardrobeDataEntity:Construct()
  self._data = {}
  self._DataCount = 0
  self.nBatchSize = 50
  self.InsIDToIndexMap = {}
  self.ResIDToIndexArrayMap = {}
  self.bInit = false
  self.loadConfigTimer = nil
  self.loadConfigCurrentIndex = 1
  self.fLoadBatch = nil
end
function WardrobeDataEntity:LoadConfigForData(data, getTableData)
  if not data or data.bConfigLoaded then
    return false
  end
  local itemDataCfg = getTableData("Item", data.resID)
  if itemDataCfg then
    data.itemType = itemDataCfg.ItemType
    data.itemSubType = itemDataCfg.ItemSubType
    data.mainTabType = itemDataCfg.WardrobeMainTab
    data.subTabType = itemDataCfg.WardrobeTab
    data.itemQuality = itemDataCfg.ItemQuality
    data.bConfigLoaded = true
    return true
  else
    log(bWriteLog and string.format("WardrobeDataEntity:LoadConfigForData - itemDataCfg == nil resID: %s", data.resID))
  end
  return false
end
function WardrobeDataEntity:GetData(bIgnoreItemConfig)
  if not bIgnoreItemConfig then
    self:EnsureAllConfigLoaded()
  end
  return self._data
end
function WardrobeDataEntity:EnsureAllConfigLoaded()
  log(bWriteLog and string.format("WardrobeDataEntity:GetData - EnsureAllConfigLoaded  self.loadConfigCurrentIndex: %s, self._DataCount %s", self.loadConfigCurrentIndex, self._DataCount))
  if self.loadConfigCurrentIndex > self._DataCount then
    log(bWriteLog and string.format("WardrobeDataEntity:GetData - all configs are already loaded"))
    return
  end
  if self.loadConfigTimer then
    self:RemoveTimer(self.loadConfigTimer)
    self.loadConfigTimer = nil
  end
  local getTableData = CDataTable.GetTableData
  for i = self.loadConfigCurrentIndex, self._DataCount do
    self:LoadConfigForData(self._data[i], getTableData)
  end
  self.loadConfigCurrentIndex = self._DataCount + 1
  log(bWriteLog and string.format("WardrobeDataEntity:GetData - force load remaining configs  self.loadConfigCurrentIndex : %s, self._DataCount %s", self.loadConfigCurrentIndex, self._DataCount))
end
function WardrobeDataEntity:LoadItemConfigLazily(batchSize)
  self.loadConfigCurrentIndex = 1
  batchSize = batchSize or 50
  self.nBatchSize = batchSize
  local currentIndex = self.loadConfigCurrentIndex
  local totalCount = self._DataCount
  local getTableData = CDataTable.GetTableData
  if self.loadConfigTimer then
    self:RemoveTimer(self.loadConfigTimer)
    self.loadConfigTimer = nil
  end
  local loadBatch = function()
    local endIndex = math.min(currentIndex + batchSize - 1, totalCount)
    for i = currentIndex, endIndex do
      if self:LoadConfigForData(self._data[i], getTableData) then
      end
    end
    currentIndex = endIndex + 1
    self.loadConfigCurrentIndex = currentIndex
    if currentIndex > totalCount then
      if self.loadConfigTimer then
        self:RemoveTimer(self.loadConfigTimer)
        self.loadConfigTimer = nil
      end
      log(bWriteLog and string.format("WardrobeDataEntity:LoadItemConfigLazily - completed. Total loaded: %d", totalCount))
    end
  end
  self.fLoadBatch = loadBatch
  if 0 < totalCount then
    log(bWriteLog and string.format("WardrobeDataEntity:LoadItemConfigLazily - start. Total count: %d, Batch size: %d", totalCount, batchSize))
    self.loadConfigTimer = self:AddTimerLoop(0, loadBatch, TIMER_INFINITE, 0.5)
  end
end
function WardrobeDataEntity:CheckDataConfigLoaded(Index)
  local data = self._data[Index]
  if data and not data.bConfigLoaded then
    local getTableData = CDataTable.GetTableData
    if not self:LoadConfigForData(data, getTableData) then
      log_error(bWriteLog and string.format("WardrobeDataEntity:CheckDataConfigLoaded - itemDataCfg == nil resID: %s", data.resID))
      return
    end
  end
  return data
end
function WardrobeDataEntity:AccelerateLoadBatchConfig(startIndex, batchSize, totalCount)
  log(bWriteLog and string.format("WardrobeDataEntity:AccelerateLoadBatchConfig - startIndex: %s, batchSize: %s, totalCount: %s", startIndex, batchSize, totalCount))
  local endIndex = math.min(startIndex + batchSize - 1, totalCount)
  local keys = {}
  local pendingData = {}
  local GetTableRowFieldsByKeys = CDataTable.GetTableRowFieldsByKeys
  for i = startIndex, endIndex do
    local data = self._data[i]
    if data and not data.bConfigLoaded then
      keys[#keys + 1] = data.resID
      pendingData[#pendingData + 1] = data
    end
  end
  if 0 < #keys then
    local configMap = GetTableRowFieldsByKeys("Item", keys, ITEM_CONFIG_FIELDS)
    if configMap then
      for _, data in ipairs(pendingData) do
        local config = configMap[data.resID]
        if config then
          data.itemType = config.ItemType
          data.itemSubType = config.ItemSubType
          data.mainTabType = config.WardrobeMainTab
          data.subTabType = config.WardrobeTab
          data.itemQuality = config.ItemQuality
          data.bConfigLoaded = true
        else
          log(bWriteLog and string.format("WardrobeDataEntity:AccelerateLoadBatchConfig - failed to load resID: %s", data.resID))
        end
      end
    end
  end
  return endIndex + 1
end
function WardrobeDataEntity:AccelerateLoadItemConfigLazily(batchSize)
  self.loadConfigCurrentIndex = 1
  batchSize = batchSize or 50
  self.nBatchSize = batchSize
  local totalCount = self._DataCount
  if self.loadConfigTimer then
    self:RemoveTimer(self.loadConfigTimer)
    self.loadConfigTimer = nil
  end
  if 0 < totalCount then
    log(bWriteLog and string.format("WardrobeDataEntity:LoadItemConfigLazily - start. Total count: %d, Batch size: %d", totalCount, batchSize))
    local loadBatch = function()
      local nextIndex = self:AccelerateLoadBatchConfig(self.loadConfigCurrentIndex, batchSize, totalCount)
      self.loadConfigCurrentIndex = nextIndex
      if nextIndex > totalCount then
        if self.loadConfigTimer then
          self:RemoveTimer(self.loadConfigTimer)
          self.loadConfigTimer = nil
        end
        log(bWriteLog and string.format("WardrobeDataEntity:LoadItemConfigLazily - completed. Total loaded: %d", totalCount))
      end
    end
    self.fLoadBatch = loadBatch
    self.loadConfigTimer = self:AddTimerLoop(0, loadBatch, TIMER_INFINITE, 0.5)
  end
end
function WardrobeDataEntity:InitData(arrayItemDataPackage)
  if bOpenLog then
    log_tree("WardrobeDataEntity:InitData arrayItemDataPackage", arrayItemDataPackage)
  end
  self.bInit = true
  self.InsIDToIndexMap = {}
  self._DataCount = 0
  self._data = {}
  self.ResIDToIndexArrayMap = {}
  local dataMgr = DataMgr
  local wardrobeDataSource = EWardrobeDataSource.Wardrobe
  local defaultParachuteResID = dataMgr.defaultParachuteResID
  local defaultPlaneSkinResID = dataMgr.defaultPlaneSkinResID
  local defaultWingmanSkinResID = dataMgr.defaultWingmanSkinResID
  local defaultVehicleSkinInsIDTable = dataMgr.defaultVehicleSkinInsIDTable
  local TimeUtil = require("client.common.time_util")
  local time_now = TimeUtil.GetServerTimeInSec()
  local MAX_REDPOINT_DURATION = 604800
  for _, arrayItemData in pairs(arrayItemDataPackage) do
    for k, v in pairs(arrayItemData) do
      v.instid = k
      local timestamp = v.instid >> 32 & 4294967295
      if MAX_REDPOINT_DURATION < time_now - timestamp then
        v.isnew = 0
      end
      local itemInfo = self:AddData(v)
      local resID = itemInfo.resID
      local insID = itemInfo.insID
      if self.DataSource == wardrobeDataSource then
        if resID == defaultParachuteResID then
          dataMgr.defaultParachuteInsID = insID
        elseif resID == defaultPlaneSkinResID then
          dataMgr.defaultPlaneSkinInsID = insID
        elseif resID == defaultWingmanSkinResID then
          dataMgr.defaultWingmanSkinInsID = insID
        elseif defaultVehicleSkinInsIDTable[resID] ~= nil then
          defaultVehicleSkinInsIDTable[resID] = insID
        end
      end
    end
  end
  local bEnable = Client.HDmpveRemoteConfigGetBool("EnableGetTableRowFields", false)
  log(bWriteLog and "WardrobeDataEntity:InitData HDmpveRemoteConfigGetBool bEnable: " .. tostring(bEnable))
  if bEnable then
    self:AccelerateLoadItemConfigLazily()
  else
    self:LoadItemConfigLazily()
  end
end
function WardrobeDataEntity:ChangeData(ItemData)
  local _data = self:GetDataByInsID(ItemData.instid)
  _data.resID = ItemData.res_id
  if _data.lock_cnt and _data.lock_cnt > 0 then
    _data.lock_cnt = ItemData.lock_cnt or _data.lock_cnt
  else
    _data.lock_cnt = ItemData.lock_cnt or 0
  end
  _data.count = ItemData.count
  _data.isNew = ItemData.isnew == 1
  _data.validHours = ItemData.valid_hours or _data.validHours or 0
  _data.expireTS = ItemData.expire_ts or _data.expireTS or 0
  _data.colorID = ItemData.color
  _data.patternID = ItemData.pattern
end
function WardrobeDataEntity:RemoveData(InsID)
  if type(InsID) == "string" then
    self:ReportTypeErrorMessage(InsID)
    InsID = tonumber(InsID)
  end
  local Index = self.InsIDToIndexMap[InsID]
  local val = self._data[Index]
  if not val then
    return
  end
  self.InsIDToIndexMap[InsID] = nil
  self:RemoveItemFormResIDToIndexArrayMap(Index, val.resID)
  self._data[Index] = nil
end
function WardrobeDataEntity:ClearData()
  if self.loadConfigTimer then
    self:RemoveTimer(self.loadConfigTimer)
    self.loadConfigTimer = nil
  end
  self:Construct()
end
function WardrobeDataEntity:PauseFrameLoading()
  log(bWriteLog and string.format("WardrobeDataEntity:PauseFrameLoading - pause frame loading"))
  if self.loadConfigTimer then
    self:RemoveTimer(self.loadConfigTimer)
    self.loadConfigTimer = nil
  end
end
function WardrobeDataEntity:RestoreFrameLoading()
  if not self.fLoadBatch then
    log(bWriteLog and "WardrobeDataEntity:RestoreFrameLoading - fLoadBatch is nil")
    return
  end
  if self.loadConfigTimer then
    log(bWriteLog and "WardrobeDataEntity:RestoreFrameLoading - loadConfigTimer already exists, no need to restore")
    return
  end
  local totalCount = self._DataCount or 0
  local batchSize = self.nBatchSize or 50
  local currentIndex = self.loadConfigCurrentIndex or 1
  if totalCount < currentIndex then
    log(bWriteLog and "WardrobeDataEntity:RestoreFrameLoading - all configs are already loaded")
    return
  end
  log(bWriteLog and string.format("WardrobeDataEntity:RestoreFrameLoading - Restore. Total count: %d, Batch size: %d, Current index: %d", totalCount, batchSize, currentIndex))
  if 0 < totalCount then
    self.loadConfigTimer = self:AddTimerLoop(0, self.fLoadBatch, TIMER_INFINITE, 0.5)
  end
end
function WardrobeDataEntity:RemoveItemFormResIDToIndexArrayMap(Index, ResID)
  local IndexArray = self.ResIDToIndexArrayMap[ResID]
  local recordindex = -1
  if IndexArray ~= nil then
    for k, v in pairs(IndexArray) do
      if v == Index then
        recordindex = k
        break
      end
    end
  end
  if 0 <= recordindex then
    table.remove(IndexArray, recordindex)
    if #IndexArray <= 0 then
      self.ResIDToIndexArrayMap[ResID] = nil
    end
  end
end
function WardrobeDataEntity:ChangeHallDepotItemResID(ins_id, res_id)
  local val = self:GetDataByInsID(ins_id)
  if val and tonumber(val.resID) ~= tonumber(res_id) then
    local oldItemID = val.resID
    self.ResIDToIndexArrayMap[res_id] = self.ResIDToIndexArrayMap[oldItemID]
    self.ResIDToIndexArrayMap[oldItemID] = nil
  end
end
function WardrobeDataEntity:AddData(itemData)
  local itemInfo = {
    insID = itemData.instid,
    resID = itemData.res_id,
    count = itemData.count,
    lock_cnt = itemData.lock_cnt or 0,
    isNew = itemData.isnew == 1,
    validHours = itemData.valid_hours or 0,
    expireTS = itemData.expire_ts or 0,
    colorID = itemData.color,
    patternID = itemData.pattern,
    notified3Days = itemData.notified_3day,
    notified1Week = itemData.notified_1week,
    bConfigLoaded = false
  }
  self._DataCount = self._DataCount + 1
  local index = self._DataCount
  self._data[index] = itemInfo
  self.InsIDToIndexMap[itemInfo.insID] = index
  self:AddResIDToIndexMap(itemInfo.resID, index)
  if bOpenLog then
    log_tree("WardrobeDataEntity:AddData itemInfo", {index, itemInfo})
    log_tree("WardrobeDataEntity:AddData InsIDToIndexMap", self.InsIDToIndexMap)
    log_tree("WardrobeDataEntity:AddData ResIDToIndexArrayMap", self.ResIDToIndexArrayMap)
  end
  return itemInfo
end
function WardrobeDataEntity:GetDataByInsID(InsID)
  if type(InsID) == "string" then
    self:ReportTypeErrorMessage(InsID)
    InsID = tonumber(InsID)
  end
  local Index = self.InsIDToIndexMap[InsID]
  if not Index then
    return
  end
  return self:CheckDataConfigLoaded(Index)
end
function WardrobeDataEntity:GetDataByResID(ResID, bCheckTimeValid)
  ResID = tonumber(ResID)
  local IndexArray = self.ResIDToIndexArrayMap[ResID]
  if not IndexArray then
    return
  end
  for key, Index in pairs(IndexArray) do
    if bCheckTimeValid then
      local data = self:CheckDataConfigLoaded(Index)
      assert_format(data ~= nil, "WardrobeDataEntity:GetDataByResID item == nil resID:%s Index:%s", tostring(ResID), tostring(Index))
      if DataMgr.IsValidTime(data.expireTS) then
        return data
      end
    else
      return self:CheckDataConfigLoaded(Index)
    end
  end
  return nil
end
function WardrobeDataEntity:GetDataListByResID(ResID, bCheckTimeValid)
  ResID = tonumber(ResID)
  local DataList = {}
  local IndexArray = self.ResIDToIndexArrayMap[ResID]
  if not IndexArray then
    return {}
  end
  for _, Index in pairs(IndexArray) do
    local data = self:CheckDataConfigLoaded(Index)
    if bCheckTimeValid then
      if DataMgr.IsValidTime(data.expireTS) then
        table.insert(DataList, data)
      end
    else
      table.insert(DataList, data)
    end
  end
  return DataList
end
function WardrobeDataEntity:GetDataByResIDAndTimeliness(ResID, bIsTimeliness)
  ResID = tonumber(ResID)
  local IndexArray = self.ResIDToIndexArrayMap[ResID]
  if not IndexArray then
    return nil
  end
  for _, Index in pairs(IndexArray) do
    if Index ~= nil and 0 <= Index then
      local tItemData = self:CheckDataConfigLoaded(Index)
      if not tItemData then
        log(bWriteLog and string.format("WardrobeDataEntity.GetDataByResIDAndTimeliness tItemData is nil, ResID:%s", ResID))
        return nil
      end
      if not bIsTimeliness and tItemData.expireTS == 0 or bIsTimeliness and tItemData.expireTS ~= 0 and DataMgr.IsValidTime(tItemData.expireTS) then
        return tItemData
      end
    end
  end
  return nil
end
function WardrobeDataEntity:AddResIDToIndexMap(ItemID, Index)
  local IndexArray = self.ResIDToIndexArrayMap[ItemID]
  if IndexArray ~= nil then
    local repeatindex = -1
    for k, v in pairs(IndexArray) do
      if v == Index then
        repeatindex = k
        break
      end
    end
    if repeatindex == -1 then
      table.insert(IndexArray, Index)
    end
  else
    IndexArray = {}
    table.insert(IndexArray, Index)
  end
  self.ResIDToIndexArrayMap[ItemID] = IndexArray
end
function WardrobeDataEntity:GetItemCountByResID(resID, bCheckValidTime)
  local count = 0
  local IndexArray = self.ResIDToIndexArrayMap[resID]
  if IndexArray ~= nil then
    for k, v in pairs(IndexArray) do
      if v ~= nil and 0 <= v then
        local item = self:CheckDataConfigLoaded(v)
        if item then
          if bCheckValidTime then
            if DataMgr.IsValidTime(item.expireTS) then
              count = count + item.count
            end
          else
            count = count + item.count
          end
        end
      end
    end
  end
  return count
end
function WardrobeDataEntity:GetItemCountByItemType(itemType, bCheckValidTime)
  local count = 0
  self:EnsureAllConfigLoaded()
  for key, item in pairs(self._data) do
    if item.itemType == itemType then
      if bCheckValidTime then
        if DataMgr.IsValidTime(item.expireTS) then
          count = count + item.count
        end
      else
        count = count + item.count
      end
    end
  end
  return count
end
function WardrobeDataEntity:GetItemCountListByItemType(itemType, bCheckValidTime)
  local ItemCountList = {}
  self:EnsureAllConfigLoaded()
  for key, item in pairs(self._data) do
    if item.itemType == itemType then
      if bCheckValidTime then
        if DataMgr.IsValidTime(item.expireTS) then
          ItemCountList[item.resID] = ItemCountList[item.resID] or 0
          ItemCountList[item.resID] = ItemCountList[item.resID] + item.count
        end
      else
        ItemCountList[item.resID] = ItemCountList[item.resID] or 0
        ItemCountList[item.resID] = ItemCountList[item.resID] + item.count
      end
    end
  end
  return ItemCountList
end
function WardrobeDataEntity:ChangeItemNewState(InsID, IsNew)
  local data = self:GetDataByInsID(InsID)
  if data then
    data.isNew = IsNew
  end
end
function WardrobeDataEntity:ReportTypeErrorMessage(insID)
  if Client.IsDevelopment() then
    local msg = string.format([[
WardrobeDataEntity:GetDataByInsID - InsID is string 
 %s 
 InsID = %s]], debug.traceback(), insID)
    local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
    ReportPlatformCrashKit:ForceSend(msg)
    log(bWriteLog and msg)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CWardrobeDataEntity = class(CDelegateContainer, nil, WardrobeDataEntity)
return CWardrobeDataEntity
local Logic_SocialLobbyConst = require("client.slua.logic.lobby.Left.SocialHallConst.Logic_SocialLobbyConst")
local SocialBottomVehicleSystem = {
  hasInit = false,
  vehicleCategory = {},
  TypeStringToID = {},
  TypeIDToString = {},
  skinItemList = {},
  DefaultItemFilter = {
    [915] = 1914001,
    [908] = 1909001
  },
  ENUM_VEHICLE_CATEGORY_TYPE = {
    Motor = 4,
    Buggy = 5,
    Boat = 6,
    Wingman = 7,
    Other = 8
  }
}
local Enum_SocialLobbySlotType = Logic_SocialLobbyConst.Enum_SocialLobbySlotType
function SocialBottomVehicleSystem.GetTabStringByID(vehicleTypeID)
  return LocUtil.GetLocalizeResStr(SocialBottomVehicleSystem.TypeIDToString[tonumber(vehicleTypeID)])
end
function SocialBottomVehicleSystem.GetIDByTabString(vehicleTypeTabString)
  return SocialBottomVehicleSystem.TypeStringToID[vehicleTypeTabString]
end
function SocialBottomVehicleSystem.GetVehicles(vehicleTypeID)
  return SocialBottomVehicleSystem.vehicleCategory[tonumber(vehicleTypeID)]
end
function SocialBottomVehicleSystem.SortVehicleTab()
  local sortFunc = function(a, b)
    if a.CategoryID ~= b.CategoryID then
      return a.CategoryID < b.CategoryID
    end
    return a.ItemSubType < b.ItemSubType
  end
  for _, v in pairs(SocialBottomVehicleSystem.vehicleCategory) do
    table.sort(v, sortFunc)
  end
end
function SocialBottomVehicleSystem.SetVehicles(vehicleTypeID, vehicleTypeName, vehicleData)
  local vehicleList = SocialBottomVehicleSystem.GetVehicles(vehicleTypeID)
  if vehicleList == nil then
    vehicleList = {}
    SocialBottomVehicleSystem.vehicleCategory[vehicleTypeID] = vehicleList
    SocialBottomVehicleSystem.TypeStringToID[vehicleTypeName] = vehicleTypeID
    SocialBottomVehicleSystem.TypeIDToString[vehicleTypeID] = vehicleTypeName
  end
  table.insert(vehicleList, vehicleData)
end
function SocialBottomVehicleSystem.InitVehicleList()
  if SocialBottomVehicleSystem.hasInit then
    return
  end
  log(bWriteLog and "InitVehicleList")
  SocialBottomVehicleSystem.vehicleCategory = {}
  SocialBottomVehicleSystem.TypeStringToID = {}
  SocialBottomVehicleSystem.TypeIDToString = {}
  local VehicleTable = CDataTable.GetTable("WardrobeVehiclesTaxonomy")
  for k, v in pairs(VehicleTable) do
    SocialBottomVehicleSystem.SetVehicles(v.CategoryID, v.VehicleCategory, v)
  end
  SocialBottomVehicleSystem.SortVehicleTab()
  SocialBottomVehicleSystem.hasInit = true
end
function SocialBottomVehicleSystem.GetTabStringByID(vehicleTypeID)
  return LocUtil.GetLocalizeResStr(SocialBottomVehicleSystem.TypeIDToString[tonumber(vehicleTypeID)])
end
function SocialBottomVehicleSystem.GetVehicleSkin(selectVehicleType, isSort, bNeedFilterLimitTimeItem)
  log(bWriteLog and "WardrobeVehicle:GetVehicleSkin:" .. tostring(selectVehicleType))
  local skinItemList = {}
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local vehicleList = SocialBottomVehicleSystem.GetVehicles(selectVehicleType)
  if not vehicleList then
    return skinItemList
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, vehicleData in pairs(vehicleList) do
    local pageID = vehicleData.WardrobePage
    local tabID = vehicleData.WardrobeTab
    local isUsing, itemInfo
    local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
    local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
    for _, v in pairs(depotItemList) do
      if WardrobeLogicManager:IsValidCurrentPageItem(pageID, tabID, v, serverTime) and v.resID ~= SocialBottomVehicleSystem.DefaultItemFilter[v.itemSubType] then
        itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #skinItemList, isUsing, false, false, false, false)
        if (not itemInfo.lock_cnt or itemInfo.lock_cnt == 0) and (not bNeedFilterLimitTimeItem or not itemInfo.hasLimitTime) then
          table.insert(skinItemList, itemInfo)
        end
      end
    end
  end
  skinItemList = SocialBottomVehicleSystem.FilterMultiItem(skinItemList)
  if isSort then
    WardrobeLogicManager:SortItemTable(skinItemList, false)
  end
  return skinItemList
end
function SocialBottomVehicleSystem.GetAllVehicleSkin(isSort, bNeedFilterLimitTimeItem)
  log(bWriteLog and "WardrobeVehicle:GetAllVehicleSkin")
  local skinItemList = {}
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if not SocialBottomVehicleSystem.vehicleCategory or not next(SocialBottomVehicleSystem.vehicleCategory) then
    SocialBottomVehicleSystem.InitVehicleList()
  end
  for _, vehicleList in pairs(SocialBottomVehicleSystem.vehicleCategory) do
    if vehicleList then
      for _, vehicleData in pairs(vehicleList) do
        local pageID = vehicleData.WardrobePage
        local tabID = vehicleData.WardrobeTab
        local isUsing, itemInfo
        local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
        local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
        for _, v in pairs(depotItemList) do
          if WardrobeLogicManager:IsValidCurrentPageItem(pageID, tabID, v, serverTime) and v.resID ~= SocialBottomVehicleSystem.DefaultItemFilter[v.itemSubType] then
            itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #skinItemList, isUsing, false, false, false, false)
            if (not itemInfo.lock_cnt or itemInfo.lock_cnt == 0) and (not bNeedFilterLimitTimeItem or not itemInfo.hasLimitTime) then
              table.insert(skinItemList, itemInfo)
            end
          end
        end
      end
      skinItemList = SocialBottomVehicleSystem.FilterMultiItem(skinItemList)
    end
  end
  if isSort then
    WardrobeLogicManager:SortItemTable(skinItemList, false)
  end
  return skinItemList
end
function SocialBottomVehicleSystem.IsVehicleUsing(ItemID)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local bIsUse = Logic_SocialLobbyModule:CheckSlotTypeIsUseItemId(DataMgr.roleData.uid, Enum_SocialLobbySlotType.Vehicle, ItemID)
  if bIsUse then
    return true
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if HallThemeUtils.GetThemeVehicleItemId() == ItemID then
    return true
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if ItemCfg and DataMgr.VehicleSlotList and DataMgr.VehicleSlotList[ItemCfg.ItemSubType] then
    for key, _insid in pairs(DataMgr.VehicleSlotList[ItemCfg.ItemSubType]) do
      local ItemData = WardrobeData:GetHallDepotItemDataByInsID(_insid)
      if ItemData and ItemData.resID == ItemID then
        return true
      end
    end
  end
  return false
end
function SocialBottomVehicleSystem.FilterMultiItem(itemListTable)
  local result = {}
  local MultiLevelResult = {}
  if not itemListTable then
    return result
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  for _, v in pairs(itemListTable) do
    if LogicMultiItemModule:IsWardRobeMultiLevelItem(v.res_id) then
      local GroupID = LogicMultiItemModule:GetMultiItemGroup(v.res_id)
      if not LogicMultiItemModule:CheckLowLevelHasOwn(v.res_id) then
        log(bWriteLog and "LogicMultiItemModule CheckLowLevelHasOwn " .. tostring(v.res_id))
      elseif SocialBottomVehicleSystem.IsVehicleUsing(v.res_id) then
        MultiLevelResult[GroupID] = v
      elseif LogicMultiItemModule:IsLastSelectMultiLevel(v.res_id) then
        MultiLevelResult[GroupID] = v
      end
    else
      table.insert(result, v)
    end
  end
  for _, v in pairs(MultiLevelResult) do
    table.insert(result, v)
  end
  return result
end
function SocialBottomVehicleSystem.IsSkinUsingByItemData(itemSubType, ins_id)
  if DataMgr.VehicleSlotList and DataMgr.VehicleSlotList[itemSubType] then
    for _, insId in pairs(DataMgr.VehicleSlotList[itemSubType]) do
      if insId == tonumber(ins_id) then
        return true
      end
    end
  end
  return false
end
return SocialBottomVehicleSystem
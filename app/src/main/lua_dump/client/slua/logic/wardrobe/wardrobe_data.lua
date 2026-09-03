local WardrobeData = {}
local wardrobe_data_util = require("client.slua.logic.wardrobe.wardrobe_data_util")
function WardrobeData:InitHallDepotData(arrayItemDataPackage)
  log(bWriteLog and "WardrobeData:InitHallDepotData:")
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessWardrobeData)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  DataEntity:InitData(arrayItemDataPackage)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, arrayItemDataPackage)
  local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
  Logic_Download_Delete.CheckRecommendDelete()
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessWardrobeData)
end
function WardrobeData:ChangeHallDepotItemNewStatus(insID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  DataEntity:ChangeItemNewState(insID, false)
end
function WardrobeData:GetHallDepotItemDataByInsID(insID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetDataByInsID(insID)
  if not data or not next(data) then
    local InheritDataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
    data = InheritDataEntity:GetDataByInsID(insID)
  end
  return data
end
function WardrobeData:GetValidHallDepotItemDataByInsID(insID)
  local itemData = self:GetHallDepotItemDataByInsID(insID)
  if itemData and DataMgr.IsValidTime(itemData.expireTS) then
    return itemData
  end
  return nil
end
function WardrobeData:GetHallDepotItemDataByResID(resID, source)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
  return DataEntity:GetDataByResID(resID, false)
end
function WardrobeData:GetHallDepotItemDataByResIDAndSource(resID, source)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
  return DataEntity:GetDataByResID(resID, false)
end
function WardrobeData:GetAllHallDepotItemDataByResID(resID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetDataByResID(resID)
  if not data or not next(data) then
    local InheritDataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
    data = InheritDataEntity:GetDataByResID(resID)
  end
  return data
end
function WardrobeData:GetHallDepotItemDataByResIDAndValidExpireTime(resID, source)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
  return DataEntity:GetDataByResID(resID, true)
end
function WardrobeData:GetHallDepotItemDataByResIDAndTimeliness(nItemId, bIsTimeliness, DataSource)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(DataSource)
  return DataEntity:GetDataByResIDAndTimeliness(nItemId, bIsTimeliness)
end
function WardrobeData:GetHallDepotItemListByResIDValidExpireTime(resID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  return DataEntity:GetDataListByResID(resID, true)
end
function WardrobeData:GetHallDepotItemListByResID(resID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  return DataEntity:GetDataListByResID(resID, false)
end
function WardrobeData:GetHallDepotItemCountByResID(resID, valid, DataSource)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(DataSource)
  return DataEntity:GetItemCountByResID(resID, valid)
end
function WardrobeData:GetHallDepotItemCountByItemType(itemType, valid)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  return DataEntity:GetItemCountByItemType(itemType, valid)
end
function WardrobeData:GetHallDepotItemListByItemType(itemType, valid)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  return DataEntity:GetItemCountListByItemType(itemType, valid)
end
function WardrobeData:GetHallDepotItemCountByItemSubType(itemSubType, bPermanentOnly)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData()
  local Count = 0
  for key, item in pairs(data) do
    if item.itemSubType == itemSubType then
      if bPermanentOnly then
        if item.expireTS == 0 then
          Count = Count + item.count
        end
      elseif DataMgr.IsValidTime(item.expireTS) then
        Count = Count + item.count
      end
    end
  end
  return Count
end
function WardrobeData:GetHallDepotItemCountByItemSubTypeAndQuality(itemSubType, bPermanentOnly, itemQuality)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData()
  local Count = 0
  for key, item in pairs(data) do
    if item.itemSubType == itemSubType then
      local bTimeStampMatched = false
      if bPermanentOnly then
        if item.expireTS == 0 then
          bTimeStampMatched = true
        end
      elseif DataMgr.IsValidTime(item.expireTS) then
        bTimeStampMatched = true
      end
      local bQualityMatched = item.itemQuality == itemQuality
      if bTimeStampMatched and bQualityMatched then
        Count = Count + item.count
      end
    end
  end
  return Count
end
function WardrobeData:GetHallDepotItemListByItemSubType(itemSubType, bPermanentOnly)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData()
  local itemList = {}
  for key, item in pairs(data) do
    if item.itemSubType == itemSubType and item.count > 0 then
      if bPermanentOnly then
        if item.expireTS == 0 then
          itemList[item.insID] = {
            InsID = item.insID,
            ResID = item.resID,
            Count = item.count
          }
        end
      elseif DataMgr.IsValidTime(item.expireTS) then
        itemList[item.insID] = {
          InsID = item.insID,
          ResID = item.resID,
          Count = item.count
        }
      end
    end
  end
  return itemList
end
function WardrobeData:GetHallDepotItemListByItemSubTypeAndQuality(itemSubType, bPermanentOnly, itemQuality)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetData()
  local itemList = {}
  for key, item in pairs(data) do
    if item.itemSubType == itemSubType and item.count > 0 then
      local bTimeStampMatched = false
      if bPermanentOnly then
        if item.expireTS == 0 then
          bTimeStampMatched = true
        end
      elseif DataMgr.IsValidTime(item.expireTS) then
        bTimeStampMatched = true
      end
      local bQualityMatched = item.itemQuality == itemQuality
      if bTimeStampMatched and bQualityMatched then
        itemList[item.insID] = {
          InsID = item.insID,
          ResID = item.resID,
          Count = item.count
        }
      end
    end
  end
  return itemList
end
function WardrobeData:RemoveItemFromHallDepot(itemData)
  log_tree("WardrobeData:RemoveItemFromHallDepot itemData", itemData)
  local LogicWardrobeAvatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  LogicWardrobeAvatar:PutOffExpireItem(itemData)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  DataEntity:RemoveData(itemData.insID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  LogicMultiItemModule:ClearMultiItemSelectShapeCache(itemData.resID)
end
function WardrobeData:OnHallDepotDataNotify(changelist)
  local bOnlyHaveInheritData = true
  local NormalWardrobeChangeList = {}
  local InheritWardrobeChangeList = {}
  for k, v in pairs(changelist) do
    if v and v.source == EWardrobeDataSource.InheritWardrobe then
      InheritWardrobeChangeList[k] = v
    else
      NormalWardrobeChangeList[k] = v
      bOnlyHaveInheritData = false
    end
  end
  local hasNewItem = false
  local isFind = false
  local tempChangeInsMap = {}
  local tempChangeExpireTSItemMap = {}
  local tempMaxExpireTSItemMap = {}
  local deleteSocialCardBg = false
  local deleteSocialCardBgList = {}
  local addSocialCardBg = false
  local deletePersonalItemList = {}
  local delete3206TimeLimitGoldSuitList = {}
  local bAddStealBrainrotCard = false
  local bAddPersonalItem = false
  local bonus_pass_util = require("client.slua.logic.unknow_pass.BonusPass.bonus_pass_util")
  local insertNewItem = {}
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local InheritDataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  local HandleChangeList = function(changelist, _DataEntity)
    for k, v in pairs(changelist) do
      v.instid = k
      isFind = false
      local NewValue = self:_IsItemNew(v)
      if NewValue ~= nil then
        v.isnew = NewValue
      end
      if v.reason and v.reason == 3206 then
        table.insert(delete3206TimeLimitGoldSuitList, v)
      end
      if v.isnew == 1 then
        local _, originalItemId = bonus_pass_util.IsHigherItem(v.res_id)
        if originalItemId then
          insertNewItem[#insertNewItem + 1] = originalItemId
          v.new = 0
          log(bWriteLog and "  WardrobeData:InitHallDepotData.  insertNewItem " .. tostring(originalItemId))
        end
      end
      local lastItemCount = _DataEntity:GetItemCountByResID(v.res_id)
      hasNewItem = hasNewItem or lastItemCount <= 0 and 0 < v.count
      hasNewItem = hasNewItem or v.isnew == 1 and 0 < v.count
      local _data = _DataEntity:GetDataByInsID(v.instid)
      if _data then
        isFind = true
        if 0 < v.count or v.lock_cnt and 0 < v.lock_cnt then
          if _data.resID ~= v.res_id then
            _DataEntity:ChangeHallDepotItemResID(v.instid, v.res_id)
          end
          _DataEntity:ChangeData(v)
          if v.reach_max_expire_ts ~= nil then
            tempMaxExpireTSItemMap[v.res_id] = v.reach_max_expire_ts
          else
            local changeExpireTSValue = DataMgr.GetExpireTSAddValue(_data, v)
            if 0 < changeExpireTSValue then
              tempChangeExpireTSItemMap[v.res_id] = changeExpireTSValue
            end
          end
          if _data.lock_cnt and 0 < _data.lock_cnt then
            self:HandLockItemWear(v)
            local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
            CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, nil, LocUtil.GetLocalizeResStr(3000016))
          end
        else
          self:RemoveItemFromHallDepot(_data)
          v.isRemoved = true
          if _data.itemType == 612 then
            log(bWriteLog and "WardrobeData:OnHallDepotDataNotify deleteSocialCardBg id:" .. tostring(_data.resID))
            deleteSocialCardBg = true
            table.insert(deleteSocialCardBgList, _data.resID)
          elseif _data.itemType == ENUM_ITEM_TYPE.Personalization then
            log(bWriteLog and "WardrobeData:OnHallDepotDataNotify delete personal item id:" .. tostring(_data.resID))
            table.insert(deletePersonalItemList, _data.resID)
          end
        end
      end
      if isFind == false then
        if 0 < v.count then
          local itemDataCfg = CDataTable.GetTableData("Item", v.res_id)
          if itemDataCfg ~= nil then
            local itemData = _DataEntity:AddData(v, itemDataCfg)
            tempChangeInsMap[itemData.insID] = itemData
            if itemDataCfg.ItemType == 612 then
              log(bWriteLog and "WardrobeData:OnHallDepotDataNotify addSocialCardBg id:" .. tostring(v.res_id))
              addSocialCardBg = true
            elseif itemDataCfg.ItemType == ENUM_ITEM_TYPE.Personalization then
              log(bWriteLog and "WardrobeData:OnHallDepotDataNotify add personal item id:" .. tostring(v.res_id))
              bAddPersonalItem = true
            end
          end
        end
      elseif isFind == true then
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_DATA, v)
      end
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      for _, itemId in pairs(PassDataSystem.GetAllCouponByThrow()) do
        if v.res_id == itemId then
          EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_NOTIFY_COUPON_THROW)
          break
        end
      end
      if v.res_id == 4402914 and 0 < v.count then
        bAddStealBrainrotCard = true
      end
    end
  end
  HandleChangeList(NormalWardrobeChangeList, DataEntity)
  HandleChangeList(InheritWardrobeChangeList, InheritDataEntity)
  if bOnlyHaveInheritData then
    return
  end
  local motionList = {}
  local motionListLen = math.max(0, DataMgr.MotionSlotMax - #DataMgr.MotionSlotList)
  if 0 < motionListLen then
    for k, v in pairs(tempChangeInsMap) do
      if v.itemType == 22 and (v.itemSubType == 2201 or v.itemSubType == 2206) then
        local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
        if LogicXSuit.IsBattleEmotion(v.resID) then
        else
          table.insert(motionList, v.insID)
          if motionListLen <= #motionList then
            break
          end
        end
      end
    end
    if 0 < #motionList then
      local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      WardrobeLogicManager:equip_motion_list_req(motionList)
    end
  end
  log(bWriteLog and "OnHallDepotDataNotify " .. tostring(hasNewItem))
  if next(insertNewItem) then
    for _, id in ipairs(insertNewItem) do
      local ItemList = self:GetHallDepotItemListByResID(id)
      if next(ItemList) then
        local oneItem = ItemList[1]
        local insID = tonumber(oneItem.insID)
        NormalWardrobeChangeList[insID] = {
          isnew = 1,
          instid = insID,
          res_id = id,
          count = oneItem.count
        }
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_CHANGE, NormalWardrobeChangeList)
  if hasNewItem then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_ADD_NEW, NormalWardrobeChangeList)
  end
  if next(tempChangeInsMap) then
    log(bWriteLog and "EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA FIRST_GET_MYTHIC_FASHION")
    EventSystem:postEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA, ENUM_TRIGGER_COND.FIRST_GET_MYTHIC_FASHION, tempChangeInsMap)
  end
  if next(tempMaxExpireTSItemMap) ~= nil then
    DataMgr.ShowExpireTSMaxTips(tempMaxExpireTSItemMap)
  end
  if next(tempChangeExpireTSItemMap) ~= nil then
    DataMgr.ShowExpireTSChangeTips(tempChangeExpireTSItemMap)
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, NormalWardrobeChangeList)
  if deleteSocialCardBg then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_SOCIAL_CARD_BG, deleteSocialCardBgList)
  end
  if addSocialCardBg then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_SOCIAL_CARD_BG)
  end
  if next(deletePersonalItemList) then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_PERSONAL_ITEM, deletePersonalItemList)
  end
  if bAddPersonalItem then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_PERSONAL_ITEM)
  end
  if next(delete3206TimeLimitGoldSuitList) then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_3206_TIME_LIMIT_GOLD_SUIT, delete3206TimeLimitGoldSuitList)
  end
  if bAddStealBrainrotCard then
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_STEAL_BRAINROT_CARD)
  end
  local logic_gm_wear = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_wear")
  if logic_gm_wear then
    logic_gm_wear.ExecuteEquipItem(changelist)
  end
end
function WardrobeData:_IsItemNew(v)
  if v.res_id == 1914001 or v.res_id == 1909001 then
    return 0
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local itemCfg = CDataTable.GetTableData("Item", v.res_id) or {}
  if not WardrobeLogicManager:IsWardrobeShow(itemCfg) then
    return 0
  end
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local lastItemCount = DataEntity:GetItemCountByResID(v.res_id)
  if wardrobe_data_util.IsNewWhenCountChange(v.res_id) and lastItemCount < v.count then
    return 1
  end
  return nil
end
function WardrobeData:HandLockItemWear(itemInfo)
  if itemInfo.count == 0 then
    local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
    if LadderCarDetailConfig.IsRareCar(itemInfo.res_id) then
      if itemInfo.instid == tonumber(DataMgr.vst_skin) then
        local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
        local itemCfg = CDataTable.GetTableData("Item", itemInfo.res_id)
        local nDefaultCardId = WardrobeMacro.DefaultVehiclesId[itemCfg.itemSubType]
        local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        local nDefalutCarInsId = wardrobeLogic:GetWardrobeInsIdByResId(nDefaultCardId)
        local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
        WardRobeHandler.send_depot_put_on_req(tonumber(nDefalutCarInsId))
        local WardrobeNewHandler = require("client.network.Protocol.WardrobeNewHandler")
        WardrobeNewHandler.send_depot_modify_combat_vehicle_req(tonumber(nDefalutCarInsId), 1, false)
      end
    else
      local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      WardrobeLogic:wardrobe_put_down_req(itemInfo.instid)
    end
  end
end
function WardrobeData:GetItemCountOnlyForever(itemId, bForever, source)
  bForever = bForever or false
  if bForever then
    local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
    local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
    local ItemList = DataEntity:GetDataListByResID(itemId)
    local itemCount = 0
    for _, item in pairs(ItemList) do
      if item.expireTS == 0 and item.validHours == 0 then
        itemCount = itemCount + item.count
      end
    end
    return itemCount
  else
    local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
    local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
    return DataEntity:GetItemCountByResID(itemId, true)
  end
end
function WardrobeData:HasItem(itemId, foreverItem, source)
  foreverItem = foreverItem or false
  if foreverItem then
    return self:CheckHasPermanentItem(itemId, source)
  else
    return self:GetHallDepotItemDataByResID(itemId) ~= nil
  end
end
function WardrobeData:GetItemExpireTime(itemId)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local ItemList = DataEntity:GetDataListByResID(itemId)
  local expireTs = -1
  for _, item in pairs(ItemList) do
    if item.expireTS == 0 and item.validHours == 0 then
      expireTs = 0
      break
    else
      expireTs = item.expireTs
    end
  end
  return expireTs
end
function WardrobeData:HasValidItem(itemId, foreverItem, source)
  foreverItem = foreverItem or false
  if foreverItem then
    return self:CheckHasPermanentItem(itemId, source)
  else
    return self:GetHallDepotItemDataByResIDAndValidExpireTime(itemId, source) ~= nil
  end
end
function WardrobeData:GetArrayHallDepotItemInfo(DataSource)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(DataSource)
  return DataEntity:GetData()
end
function WardrobeData:GetArrayHallDepotItemInfo_Emote()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeConfig = require("client.slua.umg.Wardrobe.wardrobe_config")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local Parachute = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute
  local subTabList = WardrobeConfig:GetSubTabListByPageId(Parachute)
  local CurPage = subTabList[1].pageId
  local SubPage = subTabList[1].subTabId
  local items = {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(self:GetArrayHallDepotItemInfo()) do
    if WardrobeLogicManager:IsValidCurrentPageItem(CurPage, SubPage, v, serverTime) then
      items[#items + 1] = v
    end
  end
  return items
end
function WardrobeData:GetTableForResIdSearch()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  return DataEntity.ResIDToIndexArrayMap
end
function WardrobeData:GetUseCount(insID)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local use_count_local = 0
  local itemInfo = self:GetHallDepotItemDataByInsID(insID)
  if itemInfo == nil then
    return 0
  end
  local cfg = CDataTable.GetTableData("Item", itemInfo.resID)
  if cfg == nil then
    return 0
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if cfg.ItemType == ENUM_ITEM_TYPE.Hall_Theme then
    use_count_local = HallThemeUtils.GetUsedItemCount(insID, HallThemeUtils.knapsack_ext_background)
  elseif cfg.ItemType == ENUM_ITEM_TYPE.Vehicle then
    use_count_local = 0
  elseif ModelDisplayTypeHelper.IsWeapon(cfg.ItemType) then
    use_count_local = 0
  elseif DataMgr.equipmentSkinInsIDTable[cfg.ItemSubType] then
    if DataMgr.equipmentSkinInsIDTable[cfg.ItemSubType] == itemInfo.insID then
      use_count_local = 1
    end
  else
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    use_count_local = fashionbag_data:GetUseCountInFashionBags(insID)
  end
  return use_count_local
end
function WardrobeData:GetItemCountByInsID(insID)
  local itemInfo = self:GetHallDepotItemDataByInsID(insID)
  return itemInfo ~= nil and itemInfo.count or 0
end
function WardrobeData:GetItemIDByInsID(InsID)
  local itemInfo = WardrobeData:GetHallDepotItemDataByInsID(InsID)
  return itemInfo ~= nil and itemInfo.resID or 0
end
function WardrobeData:IsBagItem(itemResId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local itemData = CDataTable.GetTableData("Item", itemResId)
  if itemData and itemData.itemSubType then
    return itemData.itemSubType == ENUM_ITEM_SUBTYPE.Backpack or itemData.itemSubType == ENUM_ITEM_SUBTYPE.Upgrade_Backpack
  end
  return false
end
function WardrobeData:IsGlovesItem(itemResId)
  local itemData = CDataTable.GetTableData("Item", itemResId)
  if itemData then
    return itemData.itemSubType == ENUM_ITEM_SUBTYPE.Gloves
  end
end
function WardrobeData:IsHelmetItem(itemResId)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local itemData = CDataTable.GetTableData("Item", itemResId)
  if itemData then
    return itemData.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel or itemData.itemSubType == ENUM_ITEM_SUBTYPE.Helmet
  end
end
function WardrobeData:GetHallDepotItemCountByResIDAndValidInfo(resID, isValidTime)
  local count = 0
  local cacheTable = self:GetTableForResIdSearch()[resID]
  local cfg = CDataTable.GetTableData("Item", resID)
  if cacheTable ~= nil then
    if isValidTime or cfg.valid_hours and cfg.valid_hours ~= 0 or cfg.ExTime and cfg.ExTime ~= "" then
      for k, v in pairs(cacheTable) do
        if v ~= nil and 0 <= v then
          local item = self:GetArrayHallDepotItemInfo()[v]
          count = count + item.count
        end
      end
    else
      for k, v in pairs(cacheTable) do
        if v ~= nil and 0 <= v then
          local item = self:GetArrayHallDepotItemInfo()[v]
          if not item.expireTS or not (0 < item.expireTS) then
            count = count + item.count
          end
        end
      end
    end
  end
  return count
end
function WardrobeData:CheckHaveForSupply(itemId)
  if not LobbySystem.CheckOpen(BP_ENUM_ALREADY_HAVE_SWITCH_FOR_SUPPLY) then
    return false
  end
  return self:CheckHaveForSpecialItem(itemId)
end
function WardrobeData:CheckHaveForSpecialItem(itemId, skipCheck)
  if GlobalData.IsJapanOrKorea() and not skipCheck then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg == nil then
    return false
  end
  if itemCfg.ItemType ~= 1 and itemCfg.ItemType ~= 4 and itemCfg.ItemType ~= 5 and itemCfg.ItemType ~= 6 and itemCfg.ItemType ~= 8 and itemCfg.ItemType ~= 9 and itemCfg.ItemType ~= 22 then
    return false
  end
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Extra and itemCfg.ItemSubType == 415 then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(itemCfg.ItemType) then
    return self:CheckHasPermanentGun(itemId)
  else
    return self:CheckHasPermanentItem(itemId)
  end
end
function WardrobeData:CheckHavePermanentItemForCollect(itemId)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg == nil then
    return false
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(itemCfg.ItemType) then
    return self:CheckHasPermanentGun(itemId)
  elseif ModelDisplayTypeHelper.IsVehicle(itemCfg.ItemType) then
    return self:CheckHasPermanentCar(itemId)
  else
    return self:CheckHasPermanentItem(itemId)
  end
end
function WardrobeData:CheckHasPermanentItem(itemId, source)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData(source)
  local ItemList = DataEntity:GetDataListByResID(itemId)
  for key, item in pairs(ItemList) do
    if item.expireTS == 0 and item.validHours == 0 then
      return true
    end
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if logic_pet:HasPetPermanently(itemId) or logic_pet:HasPetDressPermanently(itemId) then
    return true
  end
  return false
end
function WardrobeData:CheckHasPermanentGun(resID)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local groupList = ItemUpgradeMgr:GetUpgradeGroupByItemID(resID)
  if 0 < #groupList then
    for _, cfg in ipairs(groupList) do
      if self:CheckHasPermanentItem(cfg.ItemID) then
        return true, 1
      end
    end
    local bHasItem = ItemUpgradeMgr:CheckHasSameGroupItemAndRefitItem(resID)
    if bHasItem then
      return true, 1
    end
    return false
  else
    return self:CheckHasPermanentItem(resID)
  end
end
function WardrobeData:CheckHasPermanentCar(resID)
  log(bWriteLog and "[YY]Num=====1111111111======" .. tostring(resID))
  local upgradeVehicle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.upgradeVehicle)
  local carItemIDS = upgradeVehicle:GetAssociatedCars(resID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  if carItemIDS and 0 < #carItemIDS then
    for _, v in pairs(carItemIDS) do
      if self:CheckHasPermanentItem(v) then
        return true, 1
      end
    end
    return false
  elseif LogicMultiItemModule:IsUpgradeItem(resID) then
    local Num = LogicMultiItemModule:GetMultiItemNumForever(resID)
    log(bWriteLog and "[YY]Num====2222=======" .. tostring(Num))
    return 0 < Num, Num
  else
    return self:CheckHasPermanentItem(resID)
  end
end
function WardrobeData:CheckHaveForUnknowPass(itemId)
  if not LobbySystem.CheckOpen(BP_ENUM_ALREADY_HAVE_SWITCH_FOR_UNKNOW_PASS) then
    return false
  end
  return self:CheckHaveForSpecialItem(itemId)
end
function WardrobeData:IsItemTypePlating(resId)
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Spray_Pattern then
    return true
  end
  return false
end
function WardrobeData:IsEmojiBubble(resId)
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg then
    log(bWriteLog and "WardrobeData:IsEmojiBubble " .. itemCfg.ItemSubType)
  end
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Emote and itemCfg.ItemSubType == 2204 then
    return true
  end
  return false
end
function WardrobeData:IsActionEmotion(resId)
  local itemCfg = CDataTable.GetTableData("Item", resId)
  if itemCfg and itemCfg.ItemType == ENUM_ITEM_TYPE.Emote and itemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Action then
    return true
  end
  return false
end
function WardrobeData:CanPutDownItem(insID)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local throwSkin = fashionbag_data:IsThrowObjectWearing(tonumber(insID))
  if throwSkin then
    return true
  end
  local gliding = fashionbag_data:GetAircraftOrGliding()
  local   if gliding == insID then
    return true
  end
  local footEffectInsID = DataMgr.foot_special_effect_id
  if footEffectInsID == insID then
    return true
  end
  local themeId = HallThemeUtils.GetThemeInstId()
  if themeId == insID then
    return true
  end
  if AvatarData.CheckWearItem(insID) then
    return true
  end
  if DataMgr.equipmentSkinInsIDTable ~= nil then
    for _, v in pairs(DataMgr.equipmentSkinInsIDTable) do
      if v == insID then
        return true
      end
    end
  end
  local isWear = fashionbag_data:IsBagPendantWearing(insID)
  return isWear
end
function WardrobeData:IsEquitItem(insID)
  if not insID or insID == 0 then
    log(bWriteLog and string.format("WardrobeData:IsEquitItem insID is nil or 0."))
    return
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local parachute = fashionbag_data:GetParachute()
  if parachute == insID then
    return true
  end
  local planSkin = fashionbag_data:GetPlanSkin()
  if planSkin == insID then
    return true
  end
  local throwSkin = fashionbag_data:IsThrowObjectWearing(tonumber(insID))
  if throwSkin then
    return true
  end
  local gliding = fashionbag_data:GetAircraftOrGliding()
  local   if gliding == insID then
    return true
  end
  local footEffectInsID = DataMgr.foot_special_effect_id
  if footEffectInsID == insID then
    return true
  end
  local themeId = HallThemeUtils.GetThemeInstId()
  if themeId == insID then
    return true
  end
  if AvatarData.CheckWearItem(insID) then
    return true
  end
  if DataMgr.equipmentSkinInsIDTable ~= nil then
    for _, v in pairs(DataMgr.equipmentSkinInsIDTable) do
      if v == insID then
        return true
      end
    end
  end
  local isWear = fashionbag_data:IsBagPendantWearing(insID)
  return isWear
end
function WardrobeData:HasParaEffectCar()
  for _, value in pairs(self:GetArrayHallDepotItemInfo()) do
    if value.itemType == 9 then
      local BetterVehicleEffect = CDataTable.GetTableData("BetterVehicleEffect", value.resID)
      if BetterVehicleEffect and BetterVehicleEffect.Parachute == 1 then
        return true
      end
    end
  end
  return false
end
function WardrobeData:GetMileStoneEmoteList()
  local Data = {}
  for _, value in pairs(self:GetArrayHallDepotItemInfo()) do
    if value.itemSubType == ENUM_ITEM_SUBTYPE.MileStoneAction then
      table.insert(Data, value.resID)
    end
  end
  return Data
end
function WardrobeData:HasGlide()
  for _, value in pairs(self:GetArrayHallDepotItemInfo()) do
    if self.IsGlideType(value.itemSubType) then
      return true
    end
  end
  return false
end
function WardrobeData:GetMaxAircastInsID()
  local MaxAircast = {
    itemQuality = 0,
    resID = 0,
    insID = "0"
  }
  for _, value in pairs(self:GetArrayHallDepotItemInfo()) do
    if self.IsGlideType(value.itemSubType) then
      if value.itemQuality > MaxAircast.itemQuality then
        MaxAircast = value
      elseif value.itemQuality == MaxAircast.itemQuality and value.resID > MaxAircast.resID then
        MaxAircast = value
      end
    end
  end
  return MaxAircast.insID
end
function WardrobeData.IsAirCastType(SubType)
  if SubType == ENUM_ITEM_SUBTYPE.Glider_Slot_414 or SubType == ENUM_ITEM_SUBTYPE.Glider_Slot_413 then
    return true
  end
  return false
end
function WardrobeData.IsGlideType(SubType)
  if SubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 or WardrobeData.IsAirCastType(SubType) then
    return true
  end
  return false
end
function WardrobeData:PutOnXsuitAircast()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXsuitMotionCoast) or {}
  local AircastID = self:GetSuitIsXsuit()
  if Record[AircastID] then
    return Record[AircastID], AircastID
  end
  return false
end
function WardrobeData:GetSuitIsXsuit()
  local tRoleData = AvatarData.GetRoleWear()
  for _, value in pairs(tRoleData) do
    local data = self:GetValidHallDepotItemDataByInsID(value)
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXsuitMotionCoast)
    if Record and Record[data.resID] then
      return Record[data.resID]
    end
  end
  return false
end
function WardrobeData.IsSuitType(SubType)
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if SubType == ENUM_ITEM_SUBTYPE.Package_Slot then
    return true
  end
  return false
end
function WardrobeData:HasItemByInsID(InsID)
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetDataByInsID(InsID)
  if data then
    return true
  end
  return false
end
function WardrobeData:GetItemSource(InsID)
  if not InsID then
    return nil
  end
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  local data = DataEntity:GetDataByInsID(InsID)
  if data then
    return EWardrobeDataSource.Wardrobe
  end
  local InheritDataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
  local data = InheritDataEntity:GetDataByInsID(InsID)
  if data then
    return EWardrobeDataSource.InheritWardrobe
  end
  return nil
end
function WardrobeData:TLogReportExIdle()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGoldenSuit_Ex_Idle_1)
  local TodayNeedReport = false
  local TimeUtil = require("client.common.time_util")
  if not cache or not TimeUtil.IsToday(cache.time) then
    TodayNeedReport = true
  end
  if not TodayNeedReport then
    log_format("WardrobeData:TLogReportExIdle. Today has report:%s", tostring(cache.time))
    return
  end
  PlayerPrefsSystem.SaveTableToFile_N({
    time = TimeUtil.GetServerTimeInSec()
  }, PlayerPrefsSystem.ePlayerPrefsType.eGoldenSuit_Ex_Idle_1)
  local tb = CDataTable.GetTableByFilter("IdleCollectNew", "IdleType", 1)
  local Reach = function(cfg)
    local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
    local SuitData = LobbyIdleUnlock:IsDepotContainsClothes(cfg.ID)
    if not SuitData or SuitData.count <= 0 then
      return false
    end
    if cfg.DependenceID == 0 then
      return SuitData ~= nil and SuitData.count > 0
    end
    local DependData = LobbyIdleUnlock:GetDependenceItemDepotData(cfg.DependenceID)
    return DependData ~= nil and DependData.count > 0
  end
  local NeedReport = false
  for _, cfg in pairs(tb) do
    if Reach(cfg) then
      NeedReport = true
      break
    end
  end
  if not NeedReport then
    return
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  local switch = logic_display_setting.ShowIdle() or false
  local TLogReasonStrTable = {switch = switch}
  local TLogReasonStr = cjson.encode(TLogReasonStrTable)
  ClientSendTLogReport(TLogEventDefine.GoldenSuit_Ex_Idle_1, 0, TLogReasonStr)
  log_format("WardrobeData:TLogReportExIdle. TLogReasonStr=%s", TLogReasonStr)
end
function WardrobeData:PauseFrameLoading()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  DataEntity:PauseFrameLoading()
end
function WardrobeData:RestoreFrameLoading()
  local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
  local DataEntity = logic_wardrobe_data_center.GetWardrobeData()
  DataEntity:RestoreFrameLoading()
end
return WardrobeData
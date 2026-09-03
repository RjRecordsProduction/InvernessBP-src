local DecomposeSystem = {
  decomposeConfigMap = {},
  decomposeList = {},
  needDelay = false,
  warehouseDrive = false,
  tDecCurrencyInfo = {}
}
local UI_SWITCH_ID = 70001
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local mapWardrobeTabType = {
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head] = 1,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_face] = 2,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_clothes] = 3,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_trousers] = 4,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_shoes] = 5
}
local GetWardrobeTabType = function(WardrobeTab)
  local tabType = mapWardrobeTabType[WardrobeTab]
  if nil == tabType then
    return 0
  end
  return tabType
end
local CheckFuncSwitch = function(funcID)
  if nil == funcID then
    return false
  end
  return LobbySystem.CheckOpen(funcID)
end
function DecomposeSystem.OnBackLogin()
  log(bWriteLog and "[YY]logic_decompose.OnBackLogin===" .. tostring(11111))
  DecomposeSystem.decomposeConfigMap = {}
  DecomposeSystem.decomposeList = {}
  DecomposeSystem.needDelay = false
  DecomposeSystem.warehouseDrive = false
end
function DecomposeSystem.HasGetDecomposeInfo(itemId)
  if DecomposeSystem.decomposeConfigMap[itemId] and DecomposeSystem.decomposeConfigMap[itemId].hasGet == true then
    return true
  end
  return false
end
function DecomposeSystem.GetItemDecomposeInfo(itemId)
  if DecomposeSystem.decomposeConfigMap[itemId] ~= nil then
    if DecomposeSystem.decomposeConfigMap[itemId].info ~= nil then
      return DecomposeSystem.decomposeConfigMap[itemId].info, true
    elseif DecomposeSystem.decomposeConfigMap[itemId].hasGet then
      return nil, true
    end
  end
  DecomposeSystem.BatchGetListDecomposeInfo({itemId})
  return nil, false
end
function DecomposeSystem.BatchGetListDecomposeInfo(list)
  if 0 < #list then
    for i, v in ipairs(list) do
      if DecomposeSystem.decomposeConfigMap[v] == nil then
        DecomposeSystem.decomposeConfigMap[v] = {}
      end
      DecomposeSystem.decomposeConfigMap[v].hasGet = true
    end
    local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
    WardRobeHandler.send_get_item_decompose_info(list)
  end
end
function DecomposeSystem.BatchCheckListDecomposeInfo(itemTab)
  local list = {}
  local maxSendIds = 0
  for k, v in pairs(itemTab) do
    if maxSendIds < 100 and not DecomposeSystem.decomposeConfigMap[v.resID] then
      maxSendIds = maxSendIds + 1
      table.insert(list, v.resID)
    end
  end
  DecomposeSystem.warehouseDrive = true
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  if next(list) then
    log_tree("[ljw]BatchCheckListDecomposeInfo list", list)
    WardRobeHandler.send_get_item_decompose_info(list)
  end
end
function DecomposeSystem.ClearInfoCache()
  DecomposeSystem.decomposeConfigMap = {}
end
function DecomposeSystem.get_item_decompose_info_rsp(res, list)
  log(bWriteLog and "get_item_decompose_info_rsp res:" .. tostring(res))
  if res == NetErrorCode_NONE then
    if list then
      for k, v in pairs(list) do
        if DecomposeSystem.decomposeConfigMap[k] == nil then
          DecomposeSystem.decomposeConfigMap[k] = {info = v, hasGet = true}
        else
          DecomposeSystem.decomposeConfigMap[k].info = v
        end
      end
    end
    local CommonUseItemSystem = require("client.slua.logic.common.logic_common_use_items")
    CommonUseItemSystem.OnDecomposeCfgRsp()
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE)
    if DecomposeSystem.warehouseDrive then
      DecomposeSystem.warehouseDrive = false
      local logic_wardrobe_Index_new = require("client.slua.logic.wardrobe.logic_wardrobe_Index_new")
      logic_wardrobe_Index_new:CheckJudgeToShowDecompose()
    end
  elseif res ~= nil then
    ShowNotice(res)
  end
end
function DecomposeSystem.notify_item_decompose_table_changed(changeTime)
  log(bWriteLog and "DecomposeSystem.notify_item_decompose_table_changed changeTime = " .. tostring(changeTime))
  DecomposeSystem.ClearInfoCache()
end
DecomposeSystem._isGoldenSuit = false
function DecomposeSystem.SendDecomposeMsg(insID, count, isGoldenSuit)
  DecomposeSystem._  if isGoldenSuit then
    local DecomposeHandler = require("client.network.Protocol.DecomposeHandler")
    DecomposeHandler.send_on_item_decompose(tonumber(insID), count, true, 1)
  else
    local DecomposeHandler = require("client.network.Protocol.DecomposeHandler")
    DecomposeHandler.send_on_item_decompose(tonumber(insID), count, true)
  end
end
function DecomposeSystem.SendBatchDecompose(decompose_items)
  local DecomposeHandler = require("client.network.Protocol.DecomposeHandler")
  DecomposeHandler.send_on_batch_item_decompose_req(decompose_items)
end
function DecomposeSystem.item_decompose_notice(dropList)
  local fromItemCfg = CDataTable.GetTableData("Item", dropList[1].from_id)
  local toItemCfg = CDataTable.GetTableData("Item", dropList[1].res_id)
  local toCnt = tostring(dropList[1].count)
  if fromItemCfg ~= nil and toItemCfg ~= nil then
    local formatStr = LocUtil.GetLocalizeResStr(6345)
    formatStr = LocUtil.GeneralFormat(formatStr, fromItemCfg.ItemName, toCnt, toItemCfg.ItemName)
    ShowNotice(formatStr)
  end
end
function DecomposeSystem.delay_item_decompose_notice()
  if DecomposeSystem.decomposeList and #DecomposeSystem.decomposeList > 0 then
    DecomposeSystem.item_decompose_notice(DecomposeSystem.decomposeList)
    DecomposeSystem.decomposeList = {}
  end
end
function DecomposeSystem.on_item_decompose_rsp(res, dropList)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if DecomposeSystem._isGoldenSuit then
    DecomposeSystem._isGoldenSuit = false
    if dropList then
      Logic_CommonItemGet.ShowPanel_DefaultStyle(dropList)
    end
    return
  end
  if res == NetErrorCode_NONE or res == "ok-auto" then
    if dropList and 0 < #dropList then
      if res == "ok-auto" then
        if DecomposeSystem.needDelay then
          DecomposeSystem.decomposeList = dropList
        else
          DecomposeSystem.item_decompose_notice(dropList)
        end
      else
        DecomposeSystem.ShowCommonItemGetUI(dropList)
      end
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB)
      EventSystem:postEvent(EVENTTYPE_RARE_ITEM_GET, EVENTTYPE_RARE_SUPPLY_HIDE_OPEN)
    end
  elseif res ~= nil then
    ShowNotice(res)
  end
end
function DecomposeSystem.on_batch_item_decompose_rsp(res, item_list)
  if res == NetErrorCode_NONE then
    if item_list and 0 < #item_list then
      DecomposeSystem.ShowCommonItemGetUI(item_list)
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECOMPOSE_OK)
  elseif res ~= nil then
    ShowNotice(res)
  end
end
function DecomposeSystem.ShowCommonItemGetUI(tAllItemData)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData
  for _, v in pairs(tAllItemData) do
    if v.res_id and v.res_id == 1001 and v.count and v.count > 100 then
      local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
      local CommonItemGet_BtnCfgUtils = require("client.slua.logic.common.CommonItemGet.CommonItemGet_BtnCfgUtils")
      local sBtnStr = LocUtil.GetLocalizeResStr(6947)
      local Enum_BtnStyle = CommonItemGet_Const.Enum_BtnStyle
      tExtendData = {
        tAllBtnShowData = {
          CommonItemGet_BtnCfgUtils.GetConfirmBtnData(),
          CommonItemGet_BtnCfgUtils.CustomNormalBtnData(sBtnStr, Enum_BtnStyle.Orange, DecomposeSystem.WardrobeGoToSupply)
        }
      }
      break
    end
  end
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllItemData, false, true, tExtendData)
end
function DecomposeSystem.WardrobeGoToSupply()
  UIManager.CloseUI(UIManager.UI_Config.wardrobe)
  UIManager.CloseUI(UIManager.UI_Config.Wardrobe_New_DecomposePopups_UIBP)
  local params = {}
  params.itemId = 0
  params.Tab1 = GlobalData.IsJapanOrKorea() and StoreConst.Page_ID_Exchange or StoreConst.Page_New_ID_Exchange
  params.Tab2 = 0
  params.bValid = true
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
end
function DecomposeSystem.CanBatchDecompose(resId)
  local decomposeInfo = DecomposeSystem.GetItemDecomposeInfo(resId)
  if decomposeInfo == nil then
    return false
  end
  return decomposeInfo.in_batch_decompose == 0
end
function DecomposeSystem.CheckItemCanDecompose(itemInfo, itemCfg, bTimeLimit, keepCount)
  if nil == itemInfo or nil == itemCfg then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if bTimeLimit then
    if itemInfo.resID == 1107098001 then
      return false
    end
    if itemInfo.expireTS <= 0 or itemInfo.count <= wardrobe_data:GetUseCount(itemInfo.insID) then
      return false
    end
  else
    if itemInfo.count == 0 then
      return false
    end
    if itemInfo.lock_cnt and 0 < itemInfo.lock_cnt and not AvatarData.CheckWearItem(itemInfo.insID) then
      local nKeepCount = math.max(keepCount or 1, wardrobe_data:GetUseCount(itemInfo.insID))
      if nKeepCount <= itemInfo.lock_cnt then
        return true
      end
    end
    if itemInfo.count <= math.max(keepCount or 1, wardrobe_data:GetUseCount(itemInfo.insID)) then
      return false
    end
  end
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  local decomposeInfo = logic_decompose.GetItemDecomposeInfo(itemInfo.resID)
  if bTimeLimit and (decomposeInfo == nil or decomposeInfo.timing_dst_item_id == nil or decomposeInfo.timing_item_ratio == nil or decomposeInfo.timing_dst_item_id == 0) then
    return false
  end
  if decomposeInfo == nil or decomposeInfo.new_dst_item_id == nil or decomposeInfo.new_dst_item_id == 0 then
    return false
  end
  local TableUtil = require("common.table_util")
  local itemSubType = TableUtil.GetTableValue(itemCfg, "itemSubType")
  if itemSubType == 1604 or itemSubType == 1612 then
    local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", itemInfo.resID)
    local jumpExchangeUrl = jumpConfig and jumpConfig.JumpExchangeUrl or ""
    if FuncUtil.IsActivityUrlValid(jumpExchangeUrl) then
      return false
    end
  end
  return true
end
function DecomposeSystem.GetRemainTimeDays(expireTS)
  local result = ""
  local TimeUtil = require("client.common.time_util")
  local remainTime = expireTS - TimeUtil.GetServerTimeInSec()
  if remainTime <= 0 then
    remainTime = 1
  end
  local day = math.ceil(remainTime * SecToHour * HourToDay)
  local dayStr = ""
  if day ~= 0 then
    dayStr = LocUtil.LocalizeResFormat(9910108, tostring(day))
  end
  if dayStr ~= "" then
    return "(" .. dayStr .. ")"
  end
  return dayStr
end
function DecomposeSystem.LoadDecomposeItem()
  local itemTable = {}
  local arrayHallDepotItemInfo = {}
  local needBatchGetDecomposeInfoList = {}
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  for k, v in pairs(arrayHallDepotItemInfo) do
    local bIsTimeLimit = DecomposeSystem.CheckTimeLimit(v)
    if v.expireTS == 0 or bIsTimeLimit then
      if DecomposeSystem.HasGetDecomposeInfo(v.resID) == true then
        local itemCfg = CDataTable.GetTableData("Item", v.resID)
        if DecomposeSystem.CheckItemCanDecompose(v, itemCfg, bIsTimeLimit) and DecomposeSystem.CanBatchDecompose(v.resID) then
          local item = {
            ins_id = 0,
            res_id = 0,
            total = 0,
            WardrobeTabType = nil,
            itemName = "",
            itemImage = "",
            itemQuality = 0,
            expireTS = nil,
            isTimeLimit = false
          }
          item.ins_id = v.insID
          item.res_id = v.resID
          item.lock_cnt = v.lock_cnt
          if bIsTimeLimit then
            item.total = v.count - wardrobe_data:GetUseCount(v.insID)
          else
            item.total = v.count - math.max(1, wardrobe_data:GetUseCount(v.insID))
          end
          if item.lock_cnt and 0 < item.lock_cnt and not AvatarData.CheckWearItem(item.ins_id) then
            item.total = v.count
          end
          item.WardrobeTabType = GetWardrobeTabType(itemCfg.WardrobeTab)
          item.itemName = itemCfg.ItemName
          item.itemImage = itemCfg.ItemSmallIcon
          item.itemQuality = itemCfg.ItemQuality
          item.wardrobeTab = itemCfg.WardrobeTab
          item.wardrobeMainTab = itemCfg.WardrobeMainTab
          item.high32Bits = WardrobeLogicManager:ExtractHigh32Bits(item.ins_id)
          item.low19Bits = WardrobeLogicManager:ExtractLow19Bits(item.ins_id)
          item.count = 0
          item.expireTS = v.expireTS
          item.isTimeLimit = bIsTimeLimit
          item.limitTimeStr = bIsTimeLimit and DecomposeSystem.GetRemainTimeDays(v.expireTS) or ""
          itemTable[v.insID] = item
        end
      else
        needBatchGetDecomposeInfoList[#needBatchGetDecomposeInfoList + 1] = v.resID
      end
    end
  end
  if 0 < #needBatchGetDecomposeInfoList then
    DecomposeSystem.BatchGetListDecomposeInfo(needBatchGetDecomposeInfoList)
  end
  return itemTable
end
function DecomposeSystem.CheckTimeLimit(itemInfo)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local bIsTimeLimit = itemInfo.expireTS > 0 and serverTime < itemInfo.expireTS
  if bIsTimeLimit then
    if wardrobe_data:IsEquitItem(itemInfo.insID) then
      bIsTimeLimit = false
    elseif HallThemeUtils.IsWeaponWearBothSlots(itemInfo.insID) then
      bIsTimeLimit = false
    end
  end
  return bIsTimeLimit
end
function DecomposeSystem.GetRemainTimeHours(expireTS)
  local TimeUtil = require("client.common.time_util")
  local remainTime = expireTS - TimeUtil.GetServerTimeInSec()
  if remainTime <= 0 then
    remainTime = 1
  end
  local hour = math.ceil(remainTime * SecToHour)
  return hour
end
function DecomposeSystem.UpdateChooseInfo(itemList)
  local goldCoins = 0
  local allInNum = 0
  local isAllIn, isCanDec = false, false
  for _, info in pairs(DecomposeSystem.tDecCurrencyInfo) do
    info.currencyNum = 0
  end
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  for i, v in ipairs(itemList) do
    if v.isSelect then
      isCanDec = true
      if 0 < v.total and v.count >= v.total then
        allInNum = allInNum + 1
      end
      local decomposeInfo = logic_decompose.GetItemDecomposeInfo(v.res_id)
      log_tree("[ljw] decomposeInfo", decomposeInfo)
      if decomposeInfo then
        if v.isTimeLimit then
          local remainTime = DecomposeSystem.GetRemainTimeHours(v.expireTS)
          if decomposeInfo.timing_item_ratio ~= nil then
            goldCoins = math.ceil(decomposeInfo.timing_item_ratio / 1000 * v.count * remainTime) + goldCoins
          end
        else
          for _, info in pairs(DecomposeSystem.tDecCurrencyInfo) do
            if decomposeInfo.new_dst_item_id == info.currencyId then
              info.currencyNum = info.currencyNum + decomposeInfo.new_max_count * v.count
            end
          end
        end
      else
        return
      end
    end
  end
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  for _, info in pairs(DecomposeSystem.tDecCurrencyInfo) do
    if CoinMacro.Bp == info.currencyId then
      info.currencyNum = goldCoins
    end
  end
  if 0 < allInNum and allInNum == #itemList then
    isAllIn = true
  end
  return isAllIn, isCanDec
end
function DecomposeSystem.Show(mainTabType)
  if not CheckFuncSwitch(UI_SWITCH_ID) then
    ShowNotice(116009)
    return
  end
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.Wardrobe_New_DecomposePopups_UIBP, mainTabType)
  end
end
return DecomposeSystem
local collect_award_module = {}
local GetSeasonEndTime = function()
  local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
  local seasonID = DataMgr.season_id
  local seasonEndTime = SeasonCardUtil.GetSeasonEndTime(seasonID)
  if not seasonEndTime then
    log(bWriteLog and "GetSeasonEndTime no seasonEndTime")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if seasonEndTime <= curTime then
    seasonEndTime = SeasonCardUtil.GetSeasonEndTime(seasonID + 1)
    log(bWriteLog and "GetSeasonEndTime, is in nextSeason blank time")
  end
  log(bWriteLog and "GetSeasonEndTime, curSeasonEndTime:" .. tostring(seasonEndTime))
  local remainTime = seasonEndTime - curTime
  local validHours = math.modf(remainTime / 3600)
  if validHours < 1 then
    validHours = 1
  end
  return validHours
end
function collect_award_module:DefineAndResetData()
  self.LimitCache = {}
end
function collect_award_module:BuyAward(data)
  local itemId = data.itemId
  local nSysId = data.nSysId
  local index = data.index
  local subIndex = data.subIndex
  local priceType = data.priceType
  local price = data.price
  local callback = data.callback
  if priceType == StoreConst.label_price_type_uc and price > DataMgr.ticket then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(price)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = CDataTable.GetTableData("Item", itemId)
  local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
  local tShowCfg = {
    nCouponPopupType = CouponSystem._Enum_CouponPopupType._FixedDiscount,
    sTitle = LocUtil.LocalizeResFormat(301185),
    sTipContent = LocUtil.LocalizeResFormat(7622, itemData.ItemName),
    nCurPrice = price,
    fConfirmCallback = function()
      local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
      ModCollectHandler.send_take_collect_level_award_req(nSysId, index, subIndex):Then(function(_, _, _)
        log_warning(bWriteLog and "  Collect_Award_Preview_UIBP:OnClickBuy. res_list: ")
        callback()
        UIManager.CloseUI(UIManager.UI_Config.Common_Material_Popup_UIBP)
      end)
    end,
    fNotEnoughCallback = function(confirmData)
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(confirmData.nShowNewPrice)
    end,
    tExtraData = {nFixedPrice = price}
  }
  if itemData.itemType == ENUM_ITEM_TYPE.Starter_Pack then
    UIManager.ShowUI(UIManager.UI_Config.Common_Material_Popup_UIBP, {
      itemId = itemId,
      price = price,
      callback = function()
        UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
      end
    })
    return
  end
  local strMsg = LocUtil.LocalizeResFormat(12276, price, data.num, itemData and itemData.ItemName or "")
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(2, LocUtil.GetLocalizeResStr(102012), strMsg, function()
    local ModCollectHandler = RequireMod("GameLua.Mod.Lobby.Split.Collect.ModCollectHandler")
    ModCollectHandler.send_take_collect_level_award_req(nSysId, index, subIndex):Then(function(_, _, _)
      log_warning(bWriteLog and "  Collect_Award_Preview_UIBP:OnClickBuy. res_list: ")
      callback()
    end)
  end)
end
function collect_award_module:OnGetDrop(tabId, index, subIndex, gunId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  log_warning(bWriteLog and string.format("collect_module:OnGetDrop. tabId %s, index %s, subIndex %s, gunId %s", tabId, index, subIndex, gunId))
  local tabId2awardName = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg").Index2AwardName
  local awardTb = collect_module.collect_data[tabId2awardName[tabId]]
  local subAwardTb
  if gunId then
    subAwardTb = awardTb[gunId]
    if not subAwardTb then
      subAwardTb = {}
      awardTb[gunId] = subAwardTb
    end
  else
    subAwardTb = awardTb
  end
  local levelTb = subAwardTb[index]
  if not levelTb then
    levelTb = {}
    subAwardTb[index] = levelTb
  end
  levelTb[subIndex] = 1
  log_tree("  collect_module:OnGetDrop. self.collect_data ", collect_module.collect_data)
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  if gunId then
    local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
    collect_reddot_module:RefreshLibrarySubTabRed(collect_cfg.Sys2Index.Vehicle)
    collect_reddot_module:RefreshLibrarySubTabRed(collect_cfg.Sys2Index.Guns)
  else
    collect_reddot_module:RefreshRoadRedPoint()
  end
end
function collect_award_module:OnGetDropBatch(tabId, awards)
  local tabId2awardName = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg").Index2AwardName
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  collect_module.collect_data[tabId2awardName[tabId]] = awards
  local collect_reddot_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_reddot_module)
  collect_reddot_module:RefreshRoadRedPoint()
end
function collect_award_module:ShowGet(res_list, fCloseCallback)
  log_warning(bWriteLog and "  collect_module:ShowGet.  ")
  if not res_list or not next(res_list) then
    log_warning(bWriteLog and "  collect_module:ShowGet.  not res_list or not next(res_list)")
    return
  end
  for _, v in pairs(res_list) do
    if self:IsLimitSubType(nil, v.res_id or v.resid) then
      v.valid_hours = GetSeasonEndTime()
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(res_list, nil, nil, {fCloseCallback = fCloseCallback})
end
function collect_award_module:IsLimitSubType(subType, itemId)
  local limitCache = self.LimitCache
  local limit = limitCache[itemId]
  if nil ~= limit then
    return limit
  end
  if not subType then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = CDataTable.GetTableData("Item", itemId)
    subType = itemData.ItemSubType
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local CollectValitTimeCfg = collect_module:GetSplitTableData("CollectValitTimeCfg", collect_module.E_ColCfgMode.Def, subType)
  log_warning(bWriteLog and "  collect_module:IsLimitSubType. subType: " .. tostring(subType))
  if CollectValitTimeCfg then
    limit = CollectValitTimeCfg.hasValid == 1
  else
    limit = false
  end
  limitCache[itemId] = limit
  return limit
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_award_module)
return CModuleTemplate
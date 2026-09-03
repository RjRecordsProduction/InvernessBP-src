local CommonUseItemSystem = {UseItemsPreview = true}
function CommonUseItemSystem.ShowUseItem(itemData, itemCfg)
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.common_use_items, 1, itemData, itemCfg)
  end
end
function CommonUseItemSystem.ShowDecomposeItem(itemCfg, itemCount, bIsLimitTimeItem)
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.common_use_items, 2, itemCfg, itemCount, bIsLimitTimeItem)
  end
end
function CommonUseItemSystem.ShowBuyCorpsShopItem(costItemId, costNum, maxCount, has_buy_num, limitType, itemCfg, func, corpPosition_limit, time_cd, limit_buy_cd_num_by_day)
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.common_use_items, 3, costItemId, costNum, maxCount, has_buy_num, limitType, itemCfg, func, corpPosition_limit, time_cd, limit_buy_cd_num_by_day)
  end
end
function CommonUseItemSystem.CloseUI()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.common_use_items)
  end
end
function CommonUseItemSystem.OnDecomposeCfgRsp()
  if CommonUseItemSystem.decomposeRspCallBack then
    CommonUseItemSystem.decomposeRspCallBack()
    CommonUseItemSystem.decomposeRspCallBack = nil
  end
end
function CommonUseItemSystem.SetItemIsCanPreview(isTrue)
  CommonUseItemSystem.UseItemsPreview = isTrue
end
function CommonUseItemSystem.GetItemIsCanPreview()
  return CommonUseItemSystem.UseItemsPreview
end
function CommonUseItemSystem.SetDecomposeRspCallBack(callback)
  CommonUseItemSystem.decomposeRspCallBack = callback
end
function CommonUseItemSystem.GetTitle(dlgType)
  local key
  if dlgType == 1 then
    key = 9910117
  elseif dlgType == 2 then
    key = 9910118
  elseif dlgType == 3 then
    key = 9910123
  end
  if key then
    return LocUtil.LocalizeResFormat(key)
  end
end
function CommonUseItemSystem.GetRemainTimeHours(expireTS)
  local TimeUtil = require("client.common.time_util")
  local remainTime = expireTS - TimeUtil.GetServerTimeInSec()
  if remainTime <= 0 then
    remainTime = 1
  end
  local hour = math.ceil(remainTime * SecToHour)
  return hour
end
function CommonUseItemSystem.CalcuTimeLimitItemCost(itemDecomposeCfg, count, itemData)
  if itemDecomposeCfg == nil then
    return
  end
  if itemData == nil then
    return
  end
  local remainTime = CommonUseItemSystem.GetRemainTimeHours(itemData.expireTS)
  if itemDecomposeCfg.timing_item_ratio ~= nil and itemDecomposeCfg.timing_item_ratio > 0 then
    return string.format("%d", math.ceil(itemDecomposeCfg.timing_item_ratio / 1000 * count * remainTime))
  end
  local min = itemDecomposeCfg.new_min_count or 0
  local max = itemDecomposeCfg.new_max_count or 0
  if min == max then
    return max * count
  else
    return string.format("%d~%d", min * count, max * count)
  end
end
function CommonUseItemSystem.CalcuNormalItemCost(itemDecomposeCfg, count)
  if itemDecomposeCfg == nil then
    return
  end
  local dropCount
  if itemDecomposeCfg.new_dst_item_id ~= 0 then
    dropCount = string.format("%d", itemDecomposeCfg.new_max_count * count)
  else
    dropCount = string.format("%d", itemDecomposeCfg.max_count * count)
  end
  return dropCount
end
function CommonUseItemSystem.GetDropCount(itemData, itemDecomposeCfg, count)
  local dropCount
  if itemData.expireTS > 0 then
    dropCount = CommonUseItemSystem.CalcuTimeLimitItemCost(itemDecomposeCfg, count, itemData)
  else
    dropCount = CommonUseItemSystem.CalcuNormalItemCost(itemDecomposeCfg, count)
  end
  return dropCount
end
function CommonUseItemSystem.GetPositionName(corpPosition_limit)
  local positionId = 410008
  if corpPosition_limit == 1 then
    positionId = 410005
  elseif corpPosition_limit == 2 then
    positionId = 410006
  elseif corpPosition_limit == 3 then
    positionId = 410007
  end
  local positionName = LocUtil.GetLocalizeResStr(positionId)
  return LocUtil.LocalizeResFormat(6435, positionName)
end
function CommonUseItemSystem.CheckUpdateDropCount(count, resID)
  local callback = function()
    local ui = UIManager.GetUI(UIManager.UI_Config.common_use_items)
    if ui then
      ui:RefreshAmountChgButton()
    end
  end
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  local itemDecomposeCfg = logic_decompose.GetItemDecomposeInfo(resID)
  if not itemDecomposeCfg then
    CommonUseItemSystem.SetDecomposeRspCallBack(callback)
    return
  end
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ins_id = logic_wardrobe_new:GetClickItemInsId()
  if ins_id == nil then
    return
  end
  local itemData = wardrobe_data:GetHallDepotItemDataByInsID(ins_id)
  if not itemData then
    return
  end
  return CommonUseItemSystem.GetDropCount(itemData, itemDecomposeCfg, count)
end
return CommonUseItemSystem
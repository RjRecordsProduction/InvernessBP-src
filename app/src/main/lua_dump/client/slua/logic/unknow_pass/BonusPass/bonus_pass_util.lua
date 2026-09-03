local bonus_pass_util = {}
local 
function bonus_pass_util.ShowBpClothes(itemId)
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  if not Logic_BonusPass:IsInActivityTimes() then
    log(bWriteLog and "  bonus_pass_util.ShowBpClothes.  not in bp time")
    return false
  end
  local BranchColorfulCfg = CDataTable.GetTableData("BranchColorfulCfg", itemId)
  if not BranchColorfulCfg then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemList = wardrobe_data:GetHallDepotItemListByResID(BranchColorfulCfg.otherId)
  if next(ItemList) then
    log(bWriteLog and "  bonus_pass_util.ShowBpClothes.  already have clothes" .. tostring(BranchColorfulCfg.otherId))
    return false, BranchColorfulCfg.otherId
  end
  return true
end
function bonus_pass_util.IsHigherItem(itemId)
  for _, v in pairs(CDataTable.GetTable("BranchColorfulCfg")) do
    if v.otherId == itemId then
      return true, v.itemId
    end
  end
  return false
end
function bonus_pass_util.GetColorfulItemId(itemId)
  local BranchColorfulCfg = CDataTable.GetTableData("BranchColorfulCfg", itemId)
  if BranchColorfulCfg then
    return BranchColorfulCfg.otherId
  end
end
function bonus_pass_util.IsTheSameItem(itemId1, itemId2)
  local BranchColorfulCfg = CDataTable.GetTableData("BranchColorfulCfg", itemId1)
  if BranchColorfulCfg and BranchColorfulCfg.otherId == itemId2 then
    return true
  end
  BranchColorfulCfg = CDataTable.GetTableData("BranchColorfulCfg", itemId2)
  if BranchColorfulCfg and BranchColorfulCfg.otherId == itemId1 then
    return true
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local CartoonStyleCfg = LogicMultiItemModule:GetCartoonStyleCfg(itemId1)
  if CartoonStyleCfg and (CartoonStyleCfg.BaseID == itemId2 or CartoonStyleCfg.CartoonStyleID == itemId2) then
    return true
  end
  return false
end
function bonus_pass_util.IsBPBaseItem(itemId)
  local BranchColorfulCfg = CDataTable.GetTableData("BranchColorfulCfg", itemId)
  if BranchColorfulCfg then
    return true, BranchColorfulCfg.otherId
  end
  return false
end
function bonus_pass_util.IsColorShapeItemTwoSelectOneLevel(bIsTwoSelectOne, nRewardItemId1, nRewardItemId2)
  local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
  if bIsTwoSelectOne and Logic_ColorShapeUtils.CheckIsColorShapeItemId(nRewardItemId1) and Logic_ColorShapeUtils.CheckIsColorShapeItemId(nRewardItemId2) then
    return true
  end
  return false
end
return bonus_pass_util
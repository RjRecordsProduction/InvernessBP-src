local LogicGlider = {}
function LogicGlider.IsMultiStateGliderBaseState(GliderID)
  local Cfg = CDataTable.GetTableData("MultiStateGlider", GliderID)
  if Cfg then
    return true
  end
  return false
end
function LogicGlider.GetSpecialGliderID(BaseID)
  local Cfg = CDataTable.GetTableData("MultiStateGlider", BaseID)
  if Cfg and Cfg.SpecialID then
    return Cfg.SpecialID
  end
  return BaseID
end
function LogicGlider.GetSlotIDByItemID(ItemID)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if not itemCfg then
    return 0
  end
  local bpCfg = CDataTable.GetTableData("AvatarBPTable", itemCfg.BPID)
  if not bpCfg then
    return 0
  end
  if 0 < bpCfg.TemplateID then
    return math.floor(bpCfg.TemplateID / 1000)
  else
    return 0
  end
end
function LogicGlider.IsWearDependentItem(BaseID, SlotDesc)
  if not slua.isValid(SlotDesc) then
    return false
  end
  local Cfg = CDataTable.GetTableData("MultiStateGlider", BaseID)
  if not Cfg and not Cfg.DependentWear then
    return false
  end
  local StringUtil = require("common.string_util")
  local DependentItems = StringUtil.Split(Cfg.DependentWear, "|")
  for _, sItemID in ipairs(DependentItems) do
    local ItemID = tonumber(sItemID) or 0
    local SlotID = LogicGlider.GetSlotIDByItemID(ItemID)
    if ItemID ~= 0 then
      local WearingItemID = SlotDesc:Get(SlotID)
      if WearingItemID.ItemDefineID.TypeSpecificID == ItemID then
        return true
      end
    end
  end
  return false
end
return LogicGlider
local EUIConfigPoolType = {
  None = 0,
  ui_pool = 1,
  item_pool = 2,
  avatar_pool = 3,
  chat_pool = 4,
  reddot_pool = 5,
  downloadui_pool = 6,
  rank_integral_pool = 7,
  other_pool = 8
}
function EUIConfigPoolType.InitMudule()
  EUIConfigPoolType._poolConfig = {
    [EUIConfigPoolType.ui_pool] = ModuleManager.CommonModuleConfig.ui_pool,
    [EUIConfigPoolType.item_pool] = ModuleManager.CommonModuleConfig.item_pool,
    [EUIConfigPoolType.avatar_pool] = ModuleManager.CommonModuleConfig.avatar_pool,
    [EUIConfigPoolType.chat_pool] = ModuleManager.CommonModuleConfig.chat_pool,
    [EUIConfigPoolType.reddot_pool] = ModuleManager.CommonModuleConfig.reddot_pool,
    [EUIConfigPoolType.downloadui_pool] = ModuleManager.CommonModuleConfig.downloadui_pool,
    [EUIConfigPoolType.rank_integral_pool] = ModuleManager.CommonModuleConfig.rank_integral_pool,
    [EUIConfigPoolType.other_pool] = ModuleManager.CommonModuleConfig.other_pool
  }
end
function EUIConfigPoolType.GetModuleByType(type)
  if not EUIConfigPoolType._poolConfig then
    EUIConfigPoolType.InitMudule()
  end
  if not type or not EUIConfigPoolType._poolConfig[type] then
    return nil
  end
  return ModuleManager.GetModule(EUIConfigPoolType._poolConfig[type])
end
function EUIConfigPoolType.GetModuleList()
  if not EUIConfigPoolType._poolConfig then
    EUIConfigPoolType.InitMudule()
  end
  local retTable = {}
  for i, v in pairs(EUIConfigPoolType._poolConfig) do
    table.insert(retTable, ModuleManager.GetModule(v))
  end
  return retTable
end
return EUIConfigPoolType
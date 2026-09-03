local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local StringUtil = require("common.string_util")
local ui_show_queue_table_query = {}
ui_show_queue_table_query.Config_BigTypeOrder = nil
ui_show_queue_table_query.Config_SmallTypeOrder = nil
ui_show_queue_table_query.Config_LobbyType = nil
ui_show_queue_table_query.Config_UIKeyCache = nil
function ui_show_queue_table_query.GetConfigParam(uiConfig, paramTable)
  local isConfig = false
  if paramTable ~= nil and type(paramTable) == "table" then
    isConfig = paramTable.IsConfig
  end
  local param1 = isConfig and paramTable.Param1 or uiConfig.queueParam
  local queueUIKey = isConfig and paramTable.QueueUIKey or uiConfig.queueUIKey
  local ignorePlayerType = isConfig and paramTable.IgnorePlayerType
  return queueUIKey, param1, ignorePlayerType
end
function ui_show_queue_table_query.GetBigTypeOrder(BigTypeID)
  if not ui_show_queue_table_query.Config_BigTypeOrder then
    ui_show_queue_table_query.Config_BigTypeOrder = {}
    local config = CDataTable.GetTable("LobbyQueueControl_BigTypeConfig")
    for _, v in pairs(config) do
      ui_show_queue_table_query.Config_BigTypeOrder[v.BigTypeID] = v.Order
    end
  end
  return ui_show_queue_table_query.Config_BigTypeOrder[BigTypeID] or ui_show_queue_config.DefaultOrder
end
function ui_show_queue_table_query.GetSmallTypeOrder(BigTypeID, SmallTypeID)
  if not ui_show_queue_table_query.Config_SmallTypeOrder then
    ui_show_queue_table_query.Config_SmallTypeOrder = {}
    local config = CDataTable.GetTable("LobbyQueueControl_SmallTypeConfig")
    for _, v in pairs(config) do
      local configBigType = v.BigTypeID
      if not ui_show_queue_table_query.Config_SmallTypeOrder[configBigType] then
        ui_show_queue_table_query.Config_SmallTypeOrder[configBigType] = {
          count = 0,
          order = {}
        }
      end
      local count = ui_show_queue_table_query.Config_SmallTypeOrder[configBigType].count + 1
      ui_show_queue_table_query.Config_SmallTypeOrder[configBigType].      ui_show_queue_table_query.Config_SmallTypeOrder[configBigType].order[v.SmallTypeID] = v.Order
    end
  end
  local bigTypeData = ui_show_queue_table_query.Config_SmallTypeOrder[BigTypeID]
  if not SmallTypeID then
    return bigTypeData
  end
  return bigTypeData and bigTypeData.order[SmallTypeID] or ui_show_queue_config.DefaultOrder
end
function ui_show_queue_table_query.GetLobbyTypeConfig(LobbyTypeID)
  if not ui_show_queue_table_query.Config_LobbyType then
    local temp = {}
    local config = CDataTable.GetTable("LobbyQueueControl_LobbyConfig")
    for _, v in pairs(config) do
      if not temp[v.LobbyTypeID] then
        temp[v.LobbyTypeID] = {
          filterMap = {}
        }
      end
      local filterUIKeyArr = StringUtil.Split(v.UIStackFilterList, "|")
      for _, keyName in ipairs(filterUIKeyArr) do
        temp[v.LobbyTypeID].filterMap[keyName] = true
      end
    end
    ui_show_queue_table_query.Config_LobbyType = temp
  end
  return ui_show_queue_table_query.Config_LobbyType[LobbyTypeID]
end
function ui_show_queue_table_query._InitUIKeyCache()
  if ui_show_queue_table_query.Config_UIKeyCache then
    return
  end
  ui_show_queue_table_query.Config_UIKeyCache = {
    byUIKey = {},
    byKeyNameParam = {}
  }
  local config = CDataTable.GetTable("LobbyQueueControl_UIConfig")
  for _, v in pairs(config) do
    if v and v.UIKey and v.UIKey > 0 then
      local uiKey = v.UIKey
      ui_show_queue_table_query.Config_UIKeyCache.byUIKey[uiKey] = true
      local cacheKey = v.KeyName .. "_" .. (v.Param or "")
      ui_show_queue_table_query.Config_UIKeyCache.byKeyNameParam[cacheKey] = uiKey
    end
  end
  log_tree("ui_show_queue_table_query._InitUIKeyCache completed Config_UIKeyCache = ", ui_show_queue_table_query.Config_UIKeyCache)
end
function ui_show_queue_table_query.GetTargetLobbyQueueControl_UIKey(keyName, param, uiKey)
  if not keyName then
    return nil
  end
  ui_show_queue_table_query._InitUIKeyCache()
  local targetUIKey
  if uiKey then
    targetUIKey = tonumber(uiKey)
    if not ui_show_queue_table_query.Config_UIKeyCache.byUIKey[targetUIKey] then
      return nil
    end
  elseif keyName then
    param = param or ""
    local cacheKey = keyName .. "_" .. param
    targetUIKey = ui_show_queue_table_query.Config_UIKeyCache.byKeyNameParam[cacheKey]
    if not targetUIKey then
      return nil
    end
  end
  return targetUIKey
end
function ui_show_queue_table_query.GetTargetLobbyQueueControl_UIConfig(keyName, param, uiKey)
  local targetUIKey = ui_show_queue_table_query.GetTargetLobbyQueueControl_UIKey(keyName, param, uiKey)
  if targetUIKey then
    local result = CDataTable.GetTableData("LobbyQueueControl_UIConfig", targetUIKey)
    return result
  end
  return nil
end
function ui_show_queue_table_query.GetTargetLobbyQueueControl_UIPlayerTypeConfig(uiKey, playerType)
  log(bWriteLog and "ui_show_queue_table_query.GetTargetLobbyQueueControl_UIPlayerTypeConfig uiKey = " .. tostring(uiKey) .. " playerType = " .. tostring(playerType))
  if not uiKey then
    return nil
  end
  uiKey = tonumber(uiKey)
  playerType = playerType or LobbySystem.roleData.popui_type
  local result = CDataTable.GetTableByFilter("LobbyQueueControl_UIPlayerTypeConfig", "UIKey", uiKey, "PlayerType", playerType)
  for k, v in pairs(result or {}) do
    return v
  end
  return nil
end
return ui_show_queue_table_query
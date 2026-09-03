local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local ui_show_queue_table_query = require("client.common.uibase.ui_show_queue_table_query")
local ui_show_queue_element_builder = {}
function ui_show_queue_element_builder.ConvertLqcUIConfigToTable(lqcUIConfigUserdata)
  if not lqcUIConfigUserdata then
    log_warning(bWriteLog and "ui_show_queue_element_builder.ConvertLqcUIConfigToTable lqcUIConfigUserdata is nil")
    return nil
  end
  local TableUtil = require("common.table_util")
  local lqcUIConfigTable = TableUtil.FastCopyTable(ui_show_queue_config.LqcUIConfigTemplate)
  local safeGet = function(field, defaultValue)
    local success, value = pcall(function()
      return lqcUIConfigUserdata[field]
    end)
    if success and value ~= nil then
      return value
    end
    return defaultValue
  end
  for fieldName, defaultValue in pairs(ui_show_queue_config.LqcUIConfigTemplate) do
    lqcUIConfigTable[fieldName] = safeGet(fieldName, defaultValue)
  end
  return lqcUIConfigTable
end
function ui_show_queue_element_builder.GetQueueElement(lqcUIConfig, uiConfig, ...)
  local TableUtil = require("common.table_util")
  local element = TableUtil.FastCopyTable(ui_show_queue_config.QueueElementStruct)
  local TimeUtil = require("client.common.time_util")
  local addQueueTime = TimeUtil.GetMicroseconds()
  element.  element.addQueueServerTime = TimeUtil.GetServerTimeInSec()
  element.lqcUIConfig = ui_show_queue_element_builder.ConvertLqcUIConfigToTable(lqcUIConfig)
  local args = table.pack(uiConfig, ...)
  element.  element.sortWeight = ui_show_queue_element_builder._GetSortWeight(element.lqcUIConfig, addQueueTime)
  return element
end
function ui_show_queue_element_builder._GetSortWeight(lqcUIConfig)
  log(bWriteLog and "-----------ui_show_queue_element_builder._GetSortWeight UIKey = " .. lqcUIConfig.UIKey .. "-----------")
  local bigTypeOrder = ui_show_queue_table_query.GetBigTypeOrder(lqcUIConfig.BigType)
  local bigTypeWeight = bigTypeOrder * 1000
  log(bWriteLog and "ui_show_queue_element_builder._GetSortWeight bigType = " .. lqcUIConfig.BigType .. ", bigTypeOrder = " .. bigTypeOrder .. ", bigTypeWeight = " .. bigTypeWeight)
  local smallTypeOrder = ui_show_queue_table_query.GetSmallTypeOrder(lqcUIConfig.BigType, lqcUIConfig.SmallType)
  local smallTypeWeight = smallTypeOrder
  log(bWriteLog and "ui_show_queue_element_builder._GetSortWeight smallType = " .. lqcUIConfig.SmallType .. ", smallTypeOrder = " .. smallTypeOrder .. ", smallTypeWeight = " .. smallTypeWeight)
  local sortWeight = bigTypeWeight + smallTypeWeight
  log(bWriteLog and "ui_show_queue_element_builder._GetSortWeight sortWeight = " .. sortWeight)
  return sortWeight
end
return ui_show_queue_element_builder
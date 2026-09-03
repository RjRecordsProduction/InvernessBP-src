local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.CheckIsHot(data)
  local startTime = data[StoreConst.label_item_index_hot_begin] or 0
  if startTime == 0 then
    startTime = data[StoreConst.label_item_index_start_time]
  end
  local endTime = data[StoreConst.label_item_index_hot_end] or 0
  if endTime == 0 then
    endTime = data[StoreConst.label_item_index_time_limit]
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  return data[StoreConst.label_item_index_hot_or_new] ~= 0 and startTime <= serverTime and endTime > serverTime
end
function StoreUtils.CanShowHotIcon(data)
  local startTime = data[StoreConst.label_item_index_hot_begin] or 0
  if startTime == 0 then
    startTime = data[StoreConst.label_item_index_start_time] or 0
  end
  local endTime = data[StoreConst.label_item_index_hot_end] or 0
  if endTime == 0 then
    endTime = data[StoreConst.label_item_index_time_limit] or 0
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  return data[StoreConst.label_item_index_hot_or_new] == 1 and startTime <= serverTime and endTime > serverTime
end
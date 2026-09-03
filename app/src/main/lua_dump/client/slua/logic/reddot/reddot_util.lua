local reddot_util = {}
local TimeUtil = require("client.common.time_util")
function reddot_util.CreateLeafData(subID)
  local data = {
    newCount = 0,
    subID = subID,
    instanceID = {_isLeaf = true}
  }
  return data
end
function reddot_util.CreateItem(id, count, validHour)
  local itemData = {}
  itemData.isItem = true
  itemData.  itemData.  itemData.  return itemData
end
function reddot_util:GetTimestamp()
  return math.floor(TimeUtil.GetServerTimeInSec())
end
return reddot_util
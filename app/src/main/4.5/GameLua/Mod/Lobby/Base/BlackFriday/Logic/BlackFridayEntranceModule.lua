local BlackFridayEntranceModule = {}
function BlackFridayEntranceModule:DefineAndResetData()
  self.EntranceInfo = nil
end
function BlackFridayEntranceModule:HandleExtraData(extraData)
  self.EntranceInfo = extraData.main_interface_picture_info
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_LOBBY_ENTRANCE_INFO_UPDATED)
end
function BlackFridayEntranceModule:HasBubble()
  if not self.EntranceInfo then
    return false
  end
  return true
end
function BlackFridayEntranceModule:GetBubbleData()
  local bubbleData
  if not self.EntranceInfo then
    return bubbleData
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, item in ipairs(self.EntranceInfo) do
    if curTime >= item.start_time and curTime <= item.end_time then
      bubbleData = item
      break
    end
  end
  return bubbleData
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayEntranceModule = class(CModuleBase, nil, BlackFridayEntranceModule)
return CBlackFridayEntranceModule
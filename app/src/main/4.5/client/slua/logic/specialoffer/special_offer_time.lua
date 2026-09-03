local special_offer_time = {}
local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local GetActTime = function(actType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByTypeAndLabel(actType, ActivitySwitchType.SpecialOffer)
  if actData then
    log_warning(bWriteLog and "  : GetActTime acdId: " .. tostring(actData.ID))
    log_warning(bWriteLog and "  : GetActTime: actData.StartTime" .. tostring(actData.StartTime))
    log_warning(bWriteLog and "  : : actData.EndTime" .. tostring(actData.EndTime))
    return actData.StartTime, actData.EndTime
  end
end
special_offer_time[cfg.ACTIVITY_TYPE_CONSUME_UC] = function()
  return GetActTime(ActivityType.ACTIVITY_TYPE_CONSUME_UC)
end
special_offer_time[cfg.CONSUME_UC] = function()
  return GetActTime(ActivityType.CONSUME_UC)
end
special_offer_time[cfg.OPTIONAL_RECHARGE] = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByType(ActivityType.OPTIONAL_RECHARGE)
  if actData then
    return actData.StartTime, actData.EndTime
  end
end
special_offer_time[cfg.golden] = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actId = cfg.id2ActId[cfg.golden]
  local actData = ActivityNewSystem.GetActivityByID(actId)
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  local ext_info = logic_scrapgold_draw.GetExtInfo()
  local nextTime = ext_info and ext_info.next_version_update_time
  local last_update_time = ext_info and ext_info.last_update_time
  if actData then
    return last_update_time or actData.StartTime, nextTime or actData.EndTime
  end
end
return special_offer_time
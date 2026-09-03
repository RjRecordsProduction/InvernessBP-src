local regist_events = {}
function regist_events.Init(event_config)
  require("client.common.event.EventProxy")
  for _, config in pairs(event_config) do
    local FuncWrap = function(eventType, eventID, ...)
      assert(config.moduleName ~= nil, "Event config module name is nil")
      local m = require(config.moduleName)
      assert(type(m) == "table", "Module not return as table")
      local func = m[config.funcName]
      assert(func ~= nil, "Function not found in module")
      func(eventType, eventID, ...)
    end
    if config.eventID and config.moduleName and config.funcName then
      EventSystem:registEvent(config.eventType, config.eventID, FuncWrap)
    else
      log_error(bWriteLog and "[register_events] EventID is " .. tostring(config.eventID) .. " moduleName " .. tostring(config.moduleName) .. " funcName " .. tostring(config.funcName))
    end
  end
end
return regist_events
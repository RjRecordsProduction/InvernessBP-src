local traceback_util = {OriginalTraceBack = nil}
traceback_util.OriginalTraceBack = debug.traceback
local Init = function()
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if not USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    local IsThread = function(thread)
      if type(thread) == "thread" then
        return true
      else
        return false
      end
    end
    function debug.traceback(thread, message, level)
      if IsThread(thread) then
        if not message then
          return "Override debug.traceback message"
        else
          return "Override debug.traceback message:" .. tostring(message)
        end
      elseif not thread then
        return "Override debug.traceback thread"
      else
        return "Override debug.traceback thread:" .. tostring(thread)
      end
    end
  end
end
Init()
return traceback_util
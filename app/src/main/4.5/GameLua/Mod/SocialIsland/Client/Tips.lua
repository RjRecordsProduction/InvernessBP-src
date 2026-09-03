local Tips = {
  Priority = {
    Invalid = 0,
    Tips = 1,
    Alert = 2,
    Max = 3
  }
}
local priorityUIConfig = {
  [Tips.Priority.Tips] = "socialisland_countdown_tips",
  [Tips.Priority.Alert] = "socialisland_countdown_alert"
}
local tipsHandle = 0
local timers = {}
local tipsQueue = {
  {
    priority = Tips.Priority.Invalid
  }
}
local GetPriorityUIConfig = function(Priority)
  return UIManager.UI_Config_InGame[priorityUIConfig[Priority]]
end
local ShowUI = function(tipUnit)
  local callback = tipUnit.callback
  local priority = tipUnit.priority
  local leftSeconds = tipUnit.countdown
  UIManager.ShowUI(GetPriorityUIConfig(priority), callback, leftSeconds)
end
function Tips.ShowTips(callback, priority, countdown)
  assert(priority >= Tips.Priority.Tips, "Tips.ShowTips  priority >= Tips.Priority.Tips")
  assert(0 <= countdown, "Tips.ShowTips countdown >= 0")
  tipsHandle = tipsHandle + 1
  local tip = {
    callback = callback,
    priority = priority,
    handle = tipsHandle,
      }
  for k, v in pairs(tipsQueue) do
    if priority >= v.priority then
      table.insert(tipsQueue, k, tip)
      if k == 1 then
        ShowUI(tip)
      end
      break
    end
  end
  if 0 < countdown then
    local time_ticker = require("common.time_ticker")
    local timeHandle = time_ticker.AddTimer(0, function()
      for i = countdown, 0, -1 do
        tip.countdown = i
        coroutine.yield(1)
      end
      Tips.HideTips(tipsHandle)
    end)
    timers[tipsHandle] = timeHandle
  end
  return tipsHandle
end
function Tips.HideTips(handle)
  local time_ticker = require("common.time_ticker")
  if timers[handle] then
    time_ticker.RemoveTimer(timers[handle])
    timers[handle] = nil
  end
  local renew = false
  for k, v in pairs(tipsQueue) do
    if v.handle == handle then
      table.remove(tipsQueue, k)
      if k == 1 then
        renew = true
        UIManager.CloseUI(GetPriorityUIConfig(v.priority))
      end
      break
    end
  end
  if renew and 1 < #tipsQueue then
    ShowUI(tipsQueue[1])
  end
end
function Tips.OnGameStateChange(_, _, status)
  local time_ticker = require("common.time_ticker")
  for _, timeHandle in pairs(timers) do
    if timeHandle then
      time_ticker.RemoveTimer(timeHandle)
    end
  end
  timers = {}
  tipsQueue = {
    {
      priority = Tips.Priority.Invalid
    }
  }
end
return Tips
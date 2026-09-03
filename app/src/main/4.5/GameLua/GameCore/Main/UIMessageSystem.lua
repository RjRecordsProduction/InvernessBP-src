local UIMessageSystem = {
  MapEvents = {},
  DelegateContainer = nil
}
function UIMessageSystem.InitInagmeEntry()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, UIMessageSystem.OnPostSwitch)
end
function UIMessageSystem.OnPostSwitch(_, _, status)
  print(bWriteLog and "UIMessageSystem.OnPostSwitch")
  if status.current == GameStatus.Fighting then
    UIMessageSystem.InitData()
  else
    UIMessageSystem.ClearData()
  end
end
function UIMessageSystem.InitData()
  if UIMessageSystem.DelegateContainer == nil then
    local DelegateContainer = require("common.delegate_container")
    UIMessageSystem.DelegateContainer = DelegateContainer()
  end
end
function UIMessageSystem.ClearData()
  if UIMessageSystem.DelegateContainer then
    UIMessageSystem.MapEvents = {}
    UIMessageSystem.DelegateContainer:Dispose()
    UIMessageSystem.DelegateContainer = nil
  end
end
function UIMessageSystem.AddUIMessageEvent(MessageName, Func, ...)
  local ListEvent = UIMessageSystem.MapEvents[MessageName]
  if nil == ListEvent then
    UIMessageSystem.MapEvents[MessageName] = {}
    ListEvent = UIMessageSystem.MapEvents[MessageName]
  end
  for _, CallBackInfo in pairs(ListEvent) do
    if CallBackInfo and CallBackInfo.Func == Func then
      return false
    end
  end
  local CallBackInfo = {}
  CallBackInfo.  CallBackInfo.Args = table.pack(...)
  table.insert(ListEvent, CallBackInfo)
  return true, CallBackInfo
end
function UIMessageSystem.RemoveUIMessageEvent(MessageName, Func)
  local ListEvent = UIMessageSystem.MapEvents[MessageName]
  if nil == ListEvent then
    return false
  end
  for Key, CallBackInfo in pairs(ListEvent) do
    if CallBackInfo and CallBackInfo.Func == Func then
      table.remove(ListEvent, Key)
      return true
    end
  end
  return false
end
function UIMessageSystem.OnReceiveUIMessage(MessageName, TipsIDOrType, Param1, Param2)
  local ListEvent = UIMessageSystem.MapEvents[MessageName]
  if nil == ListEvent then
    return
  end
  for _, CallBackInfo in pairs(ListEvent) do
    if CallBackInfo then
      local common = require("client.slua_ui_framework.common")
      common.CallCombinationArgs(CallBackInfo.Func, CallBackInfo.Args, TipsIDOrType, Param1, Param2)
    end
  end
end
function UIMessageSystem.BindPlayerController(PC)
  if UIMessageSystem.DelegateContainer == nil then
    local DelegateContainer = require("common.delegate_container")
    UIMessageSystem.DelegateContainer = DelegateContainer()
  end
  if slua.isValid(PC) and UIMessageSystem.DelegateContainer then
    UIMessageSystem.DelegateContainer:AddControlEvent(PC, "OnReceiveUIMessage", UIMessageSystem.OnReceiveUIMessage)
  end
end
return UIMessageSystem
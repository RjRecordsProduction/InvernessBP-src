local bUseNewEventSystem = true
local gameInstance = slua.getGameInstance()
gameInstance:ExecuteCMD("r.UseNewEventSystem", bUseNewEventSystem and 1 or 0)
local EventBridge = require("client.common.event.EventBridge")
EventBridge.Init()
return bUseNewEventSystem
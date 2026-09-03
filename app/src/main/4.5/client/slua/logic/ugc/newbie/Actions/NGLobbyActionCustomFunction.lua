local NGLobbyActionCustomFunction = {}
function NGLobbyActionCustomFunction:ctor(selfType, Params)
  self.Function = Params.Function
end
function NGLobbyActionCustomFunction:RunAction(InGuideID, ...)
  log(bWriteLog and "Debug NGLobbyActionCustomFunction RunAction")
  if self.Function then
    self.Function()
  end
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_CUSTOMFUNCTION_FINISHED)
  return true
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGLobbyActionCustomFunction = class(CObject, nil, NGLobbyActionCustomFunction)
return CNGLobbyActionCustomFunction
local NGLobbyActionPlayUGCVideo = {}
function NGLobbyActionPlayUGCVideo:ctor(_, Params)
  self.  self.videoPath = Params.videoPath
  self.extra = Params.extra
  self.bMask = Params.bMask
end
function NGLobbyActionPlayUGCVideo:RunAction(InGuideID)
  NGLobbyActionPlayUGCVideo.__super.RunAction(self, InGuideID)
  log(bWriteLog and "NGLobbyActionPlayUGCVideo RunAction InGuideID = " .. tostring(InGuideID))
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  local result = VideoLibrary.PlayUGCVideo(self.videoPath, self.extra, self.bMask)
  log(bWriteLog and "NGLobbyActionPlayUGCVideo PlayVideo result = " .. tostring(result))
  if not result then
    log(bWriteLog and "NGLobbyActionPlayUGCVideo:RunAction result is false")
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_UI_CLOSE, Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo)
  end
  return result
end
function NGLobbyActionPlayUGCVideo:EndAction(InGuideID, EndType)
  NGLobbyActionPlayUGCVideo.__super.EndAction(self)
  log(bWriteLog and "NGLobbyActionPlayUGCVideo EndAction InGuideID = " .. tostring(InGuideID) .. " EndType = " .. tostring(EndType))
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionPopTips = class(CObject, nil, NGLobbyActionPlayUGCVideo)
return CNewbieGuideActionPopTips
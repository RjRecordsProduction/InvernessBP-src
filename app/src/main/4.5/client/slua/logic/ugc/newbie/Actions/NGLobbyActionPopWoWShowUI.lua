local NGLobbyActionPopWoWShowUI = {}
function NGLobbyActionPopWoWShowUI:ctor(selfType, Params)
  self.ShowUI = Params.UIConfig or ""
end
function NGLobbyActionPopWoWShowUI:RunAction(InGuideID, ...)
  self.GuideID = InGuideID
  log(bWriteLog and "NGLobbyActionPopWoWShowUI:RunAction InGuideID = " .. tostring(self.GuideID))
  UIManager.ShowUI(self.ShowUI)
  return true
end
function NGLobbyActionPopWoWShowUI:EndAction(InGuideID)
  log(bWriteLog and "NGLobbyActionPopWoWShowUI:EndAction InGuideID = " .. InGuideID)
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionShowUI = class(CObject, nil, NGLobbyActionPopWoWShowUI)
return CNewbieGuideActionShowUI
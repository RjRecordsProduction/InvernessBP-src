local NGLobbyActionPopWoWTips = {}
function NGLobbyActionPopWoWTips:ctor(selfType, Params)
  self.TextID = Params.TextID or ""
end
function NGLobbyActionPopWoWTips:RunAction(InGuideID, ...)
  self.GuideID = InGuideID
  self.ui = UIManager.ShowUI(UIManager.UI_Config.Newbie_WoWTips_UIBP, self.TextID, self.GuideID)
  return true
end
function NGLobbyActionPopWoWTips:EndAction(InGuideID)
  if self.ui and slua.isValid(self.ui.UIRoot) then
    self.ui:Hide()
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNewbieGuideActionShowUI = class(CObject, nil, NGLobbyActionPopWoWTips)
return CNewbieGuideActionShowUI
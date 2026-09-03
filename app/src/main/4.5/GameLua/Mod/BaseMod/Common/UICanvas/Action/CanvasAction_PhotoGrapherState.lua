local CanvasAction_PhotoGrapherState = {
  sActionName = "CanvasAction_PhotoGrapherState"
}
function CanvasAction_PhotoGrapherState:ctor()
end
function CanvasAction_PhotoGrapherState:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PHOTOGRAPHER_STATE, self.OnPhotoGrapherStateChange, self)
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    return
  end
  if PhotoGrapherSubSystem.bIsPhotoGrapherMode ~= nil then
    self.bIsShow = not PhotoGrapherSubSystem.bIsPhotoGrapherMode
    self:UpdateCanvasShow()
  end
end
function CanvasAction_PhotoGrapherState:UnbindEvent()
  self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG)
end
function CanvasAction_PhotoGrapherState:OnPhotoGrapherStateChange(_, __, bState)
  if self.Config.Show then
    self.bIsShow = self.Config.Show == bState
  elseif self.Config.Hide then
    self.bIsShow = not self.Config.Hide == bState
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_PhotoGrapherState = class(CanvasActionBase, nil, CanvasAction_PhotoGrapherState)
return CCanvasAction_PhotoGrapherState
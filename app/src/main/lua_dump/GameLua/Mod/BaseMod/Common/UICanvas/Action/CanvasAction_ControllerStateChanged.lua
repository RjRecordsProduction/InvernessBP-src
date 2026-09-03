local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local delegate_container = require("common.delegate_container")
local CanvasAction_ControllerStateChanged = {
  sActionName = "CanvasAction_ControllerStateChanged"
}
function CanvasAction_ControllerStateChanged:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  self.DelegateContainer = delegate_container()
  self.DelegateContainer:AddDataListener(GameplayData.GetSuperData(), "PlayerController", function(_, PlayerController)
    if slua.isValid(PlayerController) and self.DelegateContainer then
      self:OnPlayerControllerStateChangedDelegate(PlayerController:GetCurrentStateType())
      self.DelegateContainer:AddControlEvent(PlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChangedDelegate, self)
    end
  end)
end
function CanvasAction_ControllerStateChanged:UnbindEvent()
  if self.DelegateContainer then
    self.DelegateContainer:Dispose()
  end
  self.DelegateContainer = nil
end
function CanvasAction_ControllerStateChanged:OnPlayerControllerStateChangedDelegate(InStateType)
  print(bWriteLog and "CanvasAction_ControllerStateChanged:OnPlayerControllerStateChangedDelegate", InStateType)
  if self.Config.Show then
    self.bIsShow = self:HasValue(self.Config.Show, InStateType)
  elseif self.Config.Hide then
    self.bIsShow = not self:HasValue(self.Config.Hide, InStateType)
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_ControllerStateChanged = class(CanvasActionBase, nil, CanvasAction_ControllerStateChanged)
return CCanvasAction_ControllerStateChanged
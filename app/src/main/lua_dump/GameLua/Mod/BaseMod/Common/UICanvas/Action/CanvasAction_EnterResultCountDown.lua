local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CanvasAction_EnterResultCountDown = {
  sActionName = "CanvasAction_EnterResultCountDown"
}
function CanvasAction_EnterResultCountDown:ctor()
end
function CanvasAction_EnterResultCountDown:BindEvent()
  if self.Config.Show == nil then
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_START, self.OnEnterResultCountDown, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END, self.OnExitResultCountDown, self)
end
function CanvasAction_EnterResultCountDown:UnbindEvent()
  self:RemoveCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_START)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END)
end
function CanvasAction_EnterResultCountDown:OnEnterResultCountDown()
  self.bIsShow = self.Config.Show == true
  self:UpdateCanvasShow()
end
function CanvasAction_EnterResultCountDown:OnExitResultCountDown()
  self.bIsShow = self.Config.Show == false
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
return class(CanvasActionBase, nil, CanvasAction_EnterResultCountDown)
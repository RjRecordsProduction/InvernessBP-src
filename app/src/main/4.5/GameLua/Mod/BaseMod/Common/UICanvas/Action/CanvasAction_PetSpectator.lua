local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CanvasAction_PetSpectator = {
  sActionName = "CanvasAction_PetSpectator"
}
function CanvasAction_PetSpectator:ctor()
end
function CanvasAction_PetSpectator:BindEvent()
  if self.Config.Show == nil then
    return
  end
  self:OnPetSpectatorChange()
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET, self.OnPetSpectatorChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET, self.OnPetSpectatorChange, self)
end
function CanvasAction_PetSpectator:UnbindEvent()
  self:RemoveCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_POSSESSONPET)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_PETTRANSFORM, EVENTID_REINIT_UI_UNPOSSESSONPET)
end
function CanvasAction_PetSpectator:OnPetSpectatorChange()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController.IsInPetSpectator == nil then
    return
  end
  self.bIsShow = self.Config.Show == PlayerController:IsInPetSpectator()
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
return class(CanvasActionBase, nil, CanvasAction_PetSpectator)
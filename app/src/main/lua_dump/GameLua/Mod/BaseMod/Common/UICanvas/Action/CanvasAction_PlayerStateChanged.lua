local CanvasAction_PlayerStateChanged = {
  sActionName = "CanvasAction_PlayerStateChanged"
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local delegate_container = require("common.delegate_container")
function CanvasAction_PlayerStateChanged:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  if not slua.isValid(CGameState) then
    return
  end
  self.DelegateContainer = delegate_container()
  self.ConcernPawnStates = self.Config.Show or self.Config.Hide
  local GameplayStatics = import("GameplayStatics")
  local PlayerController = GameplayStatics.GetPlayerController(CGameState, 0)
  if slua.isValid(PlayerController) then
    self:OnCharacterStatesChange()
    self.DelegateContainer:AddControlEventWithCondition(PlayerController, "OnCharacterStatesChangeWithFilterState", {
      State = self.ConcernPawnStates
    }, self.OnCharacterStatesChange, self)
  end
end
function CanvasAction_PlayerStateChanged:UnbindEvent()
  if self.DelegateContainer then
    self.DelegateContainer:Dispose()
  end
  self.DelegateContainer = nil
end
function CanvasAction_PlayerStateChanged:OnCharacterStatesChange()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if self.Config.Show then
    self.bIsShow = PlayerCharacter:HasAnyStates(self.Config.Show)
  elseif self.Config.Hide then
    self.bIsShow = not PlayerCharacter:HasAnyStates(self.Config.Hide)
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_PlayerStateChanged = class(CanvasActionBase, nil, CanvasAction_PlayerStateChanged)
return CCanvasAction_PlayerStateChanged
local CanvasAction_SwimStateChanged = {
  sActionName = "CanvasAction_SwimStateChanged"
}
function CanvasAction_SwimStateChanged:BindEvent()
  if self.Config.Show == nil then
    return
  end
  if not slua.isValid(CGameState) then
    return
  end
  local bShowSwim = false
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(CGameState, 0)
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    local EPawnState = import("EPawnState")
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter:HasState(EPawnState.Swim) then
      bShowSwim = true
    end
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter:HasState(EPawnState.Diving) then
      bShowSwim = true
    end
  end
  self:OnSwimStateChanged(EVENTTYPE_INGAME, EVENTID_SHOOTINGUI_SHOWORHIDE_SWIMUI, bShowSwim)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOOTINGUI_SHOWORHIDE_SWIMUI, self.OnSwimStateChanged, self)
end
function CanvasAction_SwimStateChanged:UnbindEvent()
  self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_SHOOTINGUI_SHOWORHIDE_SWIMUI)
end
function CanvasAction_SwimStateChanged:OnSwimStateChanged(_1, _2, bShow)
  if self.Config.Show ~= nil then
    self.bIsShow = self.Config.Show == bShow
  end
  self:UpdateCanvasShow()
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_SwimStateChanged = class(CanvasActionBase, nil, CanvasAction_SwimStateChanged)
return CCanvasAction_SwimStateChanged
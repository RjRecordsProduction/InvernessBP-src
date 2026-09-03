local CanvasAction_SpectatorReplay = {
  sActionName = "CanvasAction_SpectatorReplay"
}
function CanvasAction_SpectatorReplay:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  if not slua.isValid(Bridge) then
    return
  end
  self:AddControlEvent(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
  self:AddControlEvent(Bridge, "OnPlayReplayEnd", self.OnSpectatorReplayChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
  self:OnSpectatorReplayChanged()
end
function CanvasAction_SpectatorReplay:OnSpectatorReplayChanged()
  if not slua.isValid(CGameWorld) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) or not PlayerController.HasAnySpectatorReplayFlag then
    return
  end
  if self.Config.Show then
    self.bIsShow = PlayerController:HasAnySpectatorReplayFlag(self.Config.Show)
  elseif self.Config.Hide then
    self.bIsShow = not PlayerController:HasAnySpectatorReplayFlag(self.Config.Hide)
  end
  self:UpdateCanvasShow()
end
function CanvasAction_SpectatorReplay:UnbindEvent()
  if not slua.isValid(CGameWorld) then
    return
  end
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  if not slua.isValid(Bridge) then
    return
  end
  self:RemoveControlEvent(Bridge, "OnPlayReplayBegin")
  self:RemoveControlEvent(Bridge, "OnPlayReplayEnd")
  self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE)
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
return class(CanvasActionBase, nil, CanvasAction_SpectatorReplay)
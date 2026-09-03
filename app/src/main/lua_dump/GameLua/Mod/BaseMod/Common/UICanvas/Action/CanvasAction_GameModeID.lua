local CanvasAction_GameModeID = {
  sActionName = "CanvasAction_GameModeID"
}
function CanvasAction_GameModeID:OnInit()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local GameModeID = tonumber(uGameState.GameModeID)
    if GameModeID ~= nil then
      if self.Config.Show then
        self.bIsInitShow = self:HasValue(self.Config.Show, GameModeID)
      elseif self.Config.Hide then
        self.bIsInitShow = not self:HasValue(self.Config.Hide, GameModeID)
      end
    end
  end
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_GameModeID = class(CanvasActionBase, nil, CanvasAction_GameModeID)
return CCanvasAction_GameModeID
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local IslandSurviveCountPanel = {}
function IslandSurviveCountPanel:OnInitialize()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  self:AttachToPanel(MainControlBaseUI.CanvasPanelSurviveKill)
  self:SetAnchors(0, 0, 0, 0)
  self:SetPosition(5, 4)
  self:SetAutoSize(true)
end
function IslandSurviveCountPanel:RegistEvents()
  self:OnPlayerNumChange()
  GameplayData.AddGameStateEvent(self, "OnPlayerNumChange", self.OnPlayerNumChange, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot, self, "IslandSurviveCountPanel")
end
function IslandSurviveCountPanel:OnPlayerNumChange()
  if not self.UIRoot then
    return
  end
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.AlivePlayerNum == nil then
    return
  end
  self.UIRoot.IslandSurviveCountText:SetText(GameState.AlivePlayerNum)
end
function IslandSurviveCountPanel:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, IslandSurviveCountPanel)
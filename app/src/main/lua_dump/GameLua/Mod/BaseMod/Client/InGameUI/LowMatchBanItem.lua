local LowMatchBanItem = {}
function LowMatchBanItem:OnInitialize()
  LowMatchBanItem.__super.OnInitialize(self)
  self:Collapsed()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_42 then
    self:AttachToPanel(MainControlBaseUI.CanvasPanel_42)
    self:SetZOrder(-1)
    self:SetAnchors(1, 0, 1, 0)
    self:SetPosition(-270, 6)
    self:SetAutoSize(true)
    self:SetAlignment(1, 0)
  end
end
function LowMatchBanItem:OnPostInitialize()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.HideForReplayUI, self)
end
function LowMatchBanItem:PostShowUIEnd(statUIInfo, showVisibility)
  LowMatchBanItem.__super.PostShowUIEnd(self, statUIInfo, showVisibility)
  self:AddGameTimer(0.1, false, function()
    self:CheckShowLowMatch()
  end)
end
function LowMatchBanItem:CheckShowLowMatch()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) or GameState.CheckIsLowMatch == nil or not GameState:CheckIsLowMatch() then
    self:CloseSelf()
    return
  end
  local PlayerController = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerController) then
    self:CloseSelf()
    return
  end
  if PlayerController.IsObserver == nil or PlayerController.IsDemoPlayGlobalObserver == nil then
    self:CloseSelf()
    return
  end
  if PlayerController:IsObserver() or PlayerController:IsDemoPlayGlobalObserver() then
    self:CloseSelf()
    return
  end
  self:HitTestInvisible()
end
function LowMatchBanItem:HideForReplayUI()
  self:CloseSelf()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, LowMatchBanItem)
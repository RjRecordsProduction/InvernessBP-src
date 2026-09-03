local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local PlayerInfoPanelStateIcon_BuffDisplayIcon = {}
function PlayerInfoPanelStateIcon_BuffDisplayIcon:OnShow()
  print(bWriteLog and "PlayerInfoPanelStateIcon_BuffDisplayIcon_Debug_Msg:OnShow")
  self:RefreshUI()
end
function PlayerInfoPanelStateIcon_BuffDisplayIcon:RegistEvents()
  print(bWriteLog and "PlayerInfoPanelStateIcon_BuffDisplayIcon_Debug_Msg: RegistEvents")
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerController", self.RefreshUI, self)
end
function PlayerInfoPanelStateIcon_BuffDisplayIcon:RefreshUI()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI or not MainControlBaseUI:IsEvoGroundGameMode() then
    return
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PlayerInfoPanelStateIcon_BuffDisplayIcon)
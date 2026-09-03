local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local KismetMathLibrary = import("KismetMathLibrary")
local PlayerInfoPanelStateIcon_Power = {}
function PlayerInfoPanelStateIcon_Power:OnShow()
  print(bWriteLog and "PlayerInfoPanelStateIcon_Power_Debug_Msg:OnShow")
  self:RefreshUI()
end
function PlayerInfoPanelStateIcon_Power:RegistEvents()
  print(bWriteLog and "PlayerInfoPanelStateIcon_Power_Debug_Msg: RegistEvents")
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_REVIVAL, self.RefreshUI, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.RefreshUI, self)
  self:AddUIMessageEvent("PlayerInfo_UpdateEnergy", self.RefreshUI, self)
  self:AddUIMessageEvent("PlayerInfo_SpectatorChangeUpdateEnergy", self.RefreshUI, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnViewTargetChange", self.RefreshUI, self)
end
function PlayerInfoPanelStateIcon_Power:RefreshUI()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local EnergyData = PlayerCharacter:GetCharacterEnergy()
  local EnergyCurrent = EnergyData.EnergyCurrent or 0
  if KismetMathLibrary.InRange_FloatFloat(EnergyCurrent, 60, 100, true, true) then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PlayerInfoPanelStateIcon_Power)
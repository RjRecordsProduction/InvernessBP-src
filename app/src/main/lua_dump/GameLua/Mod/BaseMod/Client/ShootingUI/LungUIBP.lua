local LungUIBP = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function LungUIBP:OnInitialize()
  print(bWriteLog and "LungUIBP:OnInitialize")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    self:AttachToPanel(MainControlPanelTochButton.CanvasPanel_IPX)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
    self:SetZOrder(-1)
  end
end
function LungUIBP:RegistEvents()
  print(bWriteLog and "LungUIBP:RegistEvents")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LungCanvas, self, "ShootingUIPanel_MultiLayer_LungCanvas")
  self:AddUIMessageEvent("PlayerInfo_UpdatePlayerBreathAmmount", self.PlayerInfo_UpdatePlayerBreathAmmount, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
end
function LungUIBP:OnPostInitialize()
  print(bWriteLog and "LungUIBP:OnPostInitialize")
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_REGIST_ATTACH_PANEL, self.UIRoot.LungIcon_GuideCanvas)
end
function LungUIBP:OnClose()
  print(bWriteLog and "LungUIBP:OnClose")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LungCanvas)
end
function LungUIBP:OnEnterVehicle()
  print(bWriteLog and "LungUIBP:OnEnterVehicle")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function LungUIBP:OnExitVehicle()
  print(bWriteLog and "LungUIBP:OnExitVehicle")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function LungUIBP:CanShowLungIcon()
  return true
end
function LungUIBP:PlayerInfo_UpdatePlayerBreathAmmount()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "LungUIBP:PlayerInfo_UpdatePlayerBreathAmmount not uPlayerCharacter")
    return
  end
  if not self.UIRoot.ProgressBar_Lung then
    return
  end
  local Percent = 1 - PlayerCharacter.BreathAmount / 100.0
  Percent = FuncUtil.Clamp(Percent, 0, 1)
  self.UIRoot.ProgressBar_Lung:SetPercent(Percent)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_UPDATE_BREATH_AMOUNT, Percent)
  if 0 < Percent and self:CanShowLungIcon() then
    self.UIRoot.LungIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.ProgressBar_Lung:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.LungIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    print(bWriteLog and "LungUIBP:PlayerInfo_UpdatePlayerBreathAmmount breath full hide lung")
  end
end
function LungUIBP:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "LungUIBP:Reconnect_ResetUIByPlayerControllerState")
  self:PlayerInfo_UpdatePlayerBreathAmmount()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLungUIBP = class(ui_base, nil, LungUIBP)
return CLungUIBP
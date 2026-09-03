local NewParachutingPanel2UI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UKismetMaterialLibrary = import("KismetMaterialLibrary")
function NewParachutingPanel2UI:ctor()
end
function NewParachutingPanel2UI:OnInitialize()
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
end
function NewParachutingPanel2UI:RegistEvents()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and not uPlayerController:IsSpectator() then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterJumping", self.PlayerOutofPlane, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFinished", self.PlayerEnterFinished, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnFreeViewChangedDelegate", self.OnFreeViewChanged, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.PlayerEnterFlying, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.UIMsg_Reconnect_ResetUIByPlayerControllerState, self)
  end
end
function NewParachutingPanel2UI:OnPostInitialize()
  self:DoInitWidget()
  self:InitTips()
end
function NewParachutingPanel2UI:InitSpeedWidget()
  local asset_util = require("common.asset_util")
  local SpeedBarMaterial = asset_util.GetAssetSync("/Game/Arts/UI/BattleInfo/SpeedBarMaterial.SpeedBarMaterial")
  if not SpeedBarMaterial then
    log(bWriteLog and bwritelog("NewParachutingPanel2UI:InitSpeedWidget", "SpeedBarMaterial is nil"))
    return
  end
  local UIUtil = require("client.common.ui_util")
  local DynamicMaterial = UKismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), SpeedBarMaterial)
  if not slua.isValid(DynamicMaterial) then
    log(bWriteLog and bwritelog("NewParachutingPanel2UI:InitSpeedWidget", "DynamicMaterial is nil"))
    return
  end
  self.UIRoot:InitSpeedMat(DynamicMaterial)
  self.UIRoot.SpeedBar:SetBrushFromMaterial(DynamicMaterial)
  self.UIRoot.SpeedText = self.UIRoot.SpeedT
end
function NewParachutingPanel2UI:OnClose()
end
function NewParachutingPanel2UI:InitTips()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE then
    self.UIRoot.Tips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function NewParachutingPanel2UI:ShrinkLeft()
  if not self.UIRoot then
    log(bWriteLog and bwritelog("NewParachutingPanel2UI:ShrinkLeft", "UIRoot is nil"))
    return
  end
  local uCanvasPanel_SpeedSlot = self.UIRoot.CanvasPanel_Speed.Slot
  if slua.isValid(uCanvasPanel_SpeedSlot) then
    uCanvasPanel_SpeedSlot:SetAnchors(FAnchors(0.24, 0.5, 0.24, 0.5))
  end
  local uCanvasPanel_AltitudeBarSlot = self.UIRoot.CanvasPanel_AltitudeBar.Slot
  if slua.isValid(uCanvasPanel_AltitudeBarSlot) then
    uCanvasPanel_AltitudeBarSlot:SetAnchors(FAnchors(-0.07, 0.5, -0.07, 0.5))
  end
end
function NewParachutingPanel2UI:ShrinkBack()
  if not self.UIRoot then
    log(bWriteLog and bwritelog("NewParachutingPanel2UI:ShrinkBack", "UIRoot is nil"))
    return
  end
  local uCanvasPanel_SpeedSlot = self.UIRoot.CanvasPanel_Speed.Slot
  if slua.isValid(uCanvasPanel_SpeedSlot) then
    uCanvasPanel_SpeedSlot:SetAnchors(FAnchors(1.0, 0.5, 1.0, 0.5))
  end
  local uCanvasPanel_AltitudeBarSlot = self.UIRoot.CanvasPanel_AltitudeBar.Slot
  if slua.isValid(uCanvasPanel_AltitudeBarSlot) then
    uCanvasPanel_AltitudeBarSlot:SetAnchors(FAnchors(0.0, 0.5, 0.0, 0.5))
  end
end
function NewParachutingPanel2UI:PlayerOutofPlane()
  self:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  log(bWriteLog and "NewParachutingPanel2UI:PLayerOutOfPlane ShowParachuteUI")
end
function NewParachutingPanel2UI:PlayerEnterFighting()
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  log(bWriteLog and "NewParachutingPanel2UI:PLayerEnterFighting HideParachuteUI")
end
function NewParachutingPanel2UI:PlayerEnterFinished()
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  log(bWriteLog and "NewParachutingPanel2UI:PlayerEnterFinished HideParachuteUI")
end
function NewParachutingPanel2UI:OnFreeViewChanged(IsChanged)
  if IsChanged then
    self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    log(bWriteLog and "NewParachutingPanel2UI:OnFreeViewChanged HideParachuteUI")
  end
end
function NewParachutingPanel2UI:UIMsg_Reconnect_ResetUIByPlayerControllerState()
  local uPlayerController = GameplayData.GetPlayerController()
  log(bWriteLog and "NewParachutingPanel2UI:UIMsg_Reconnect_ResetUIByPlayerControllerState")
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "NewParachutingPanel2UI:UIMsg_Reconnect_ResetUIByPlayerControllerState uPlayerController is nil")
    return
  end
  if uPlayerController.IsInFight then
    self.UIRoot.Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif uPlayerController.IsInParachuteJump then
    self:PlayerOutofPlane()
  elseif uPlayerController.IsInParachuteOpen then
    self:PlayerOutofPlane()
  else
    self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function NewParachutingPanel2UI:PlayerEnterFlying()
  self:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  log(bWriteLog and "NewParachutingPanel2UI:PLayerEnterFlying HideParachuteUI")
end
function NewParachutingPanel2UI:DoInitWidget()
  self:InitSpeedWidget()
  if self.UIRoot.PrepareParachuteUI then
    self.UIRoot:PrepareParachuteUI()
  end
  self:UIMsg_Reconnect_ResetUIByPlayerControllerState()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNewParachutingPanel2UI = class(ui_base, nil, NewParachutingPanel2UI)
return CNewParachutingPanel2UI
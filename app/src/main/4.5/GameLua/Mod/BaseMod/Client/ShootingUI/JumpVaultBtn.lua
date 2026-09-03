local slua_isValid = slua.isValid
local EPawnState = import("EPawnState")
local ESTEPoseState = import("ESTEPoseState")
local ESlateVisibility = UEnums.ESlateVisibility
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local JumpVault = {}
local IconPath = {
  vault_normal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_fanqiang_png.ZD_icon_fanqiang_png",
  vault_highlight = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_fanqiang1_png.ZD_icon_fanqiang1_png",
  jump_normal = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_tiaoyue_png.ZD_icon_tiaoyue_png",
  jump_highlight = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_tiaoyue_2_png.ZD_icon_tiaoyue_2_png"
}
function JumpVault:ctor()
  self.IsButtonPressing = false
  self.IsShowVaultBtn = false
  self.IsPressingJumpingBtn = false
  self.LastCanVault = false
  self.QuickTimerForVault = nil
  self.IsPressingVaultBtn = false
end
function JumpVault:RegistEvents()
  self:RegistEvents_Jump()
  self:RegistEvents_Vault()
end
function JumpVault:RegistEvents_Jump()
  self:AddControlEventByControl(self.UIRoot.JumpVaultBtn, "OnPressedParam", self.OnPressdJump, self)
  self:AddControlEventByControl(self.UIRoot.JumpVaultBtn, "OnReleased", self.OnReleasedJump, self)
  self:AddControlEventByControl(self.UIRoot.JumpVaultBtn, "OnHoldStarted", self.OnHoldStartedJump, self)
  self:AddControlEventByControl(self.UIRoot.JumpVaultBtn, "OnHoldEnded", self.OnHoldEndedJump, self)
  self:AddControlEventByControl(self.UIRoot.JumpVaultBtn, "OnQuickClick", self.OnQuickClickJump, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  self:AddUIMessageEvent("Sjump", self.Sjump, self)
  self:AddUIMessageEvent("Sjump_Release", self.Sjump_Release, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.JumpVault_Canvas, self, "ShootingUIPanel_JumpVault_Canvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.JumpVault_Canvas, self, "ShootingUIPanel_MultiLayer_JumpCanvas")
end
function JumpVault:RegistEvents_Vault()
  print(bWriteLog and "ShootingUIPanelIMP:RegistEvents_Vault")
  self:AddControlEventByControl(self.UIRoot.VaultBtn, "OnPressed", self.OnPressdVault, self)
  self:AddControlEventByControl(self.UIRoot.VaultBtn, "OnReleased", self.OnReleasedVault, self)
  self:AddControlEventByControl(self.UIRoot.VaultBtn, "OnHoldStarted", self.OnHoldStartedVault, self)
  self:AddControlEventByControl(self.UIRoot.VaultBtn, "OnHoldEnded", self.OnHoldEndedVault, self)
  self:AddControlEventByControl(self.UIRoot.VaultBtn, "OnQuickClick", self.OnQuickClickVault, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_JUMP_UIVISIBILITY_CHANGED, self.OnUGCJumpVisbilityChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_VAULT_UIVISIBILITY_CHANGED, self.OnUGCVaultVisbilityChanged, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_VaultCanvas, self, "ShootingUIPanel_MultiLayer_VaultCanvas")
end
function JumpVault:OnInitialize()
  JumpVault.__super.OnInitialize(self)
  self.ImageCircle = self.UIRoot.ImageCircle
  self.Image_JumpVault = self.UIRoot.Image_JumpVault
end
function JumpVault:OnPostInitialize()
  self:HandleVaultVisibility()
end
function JumpVault:OnShow()
  print("JumpVault:OnShow")
end
function JumpVault:OnClose()
  print("JumpVault:OnClose")
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.JumpVault_Canvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_VaultCanvas)
  JumpVault.__super.OnClose(self)
end
function JumpVault:OnCanVaultFlagChange(bCanVault)
  if self.IsShowVaultBtn then
    self:SetVaultHighLightImgVisible()
  else
    self:RefreshJumpBtnIcon(bCanVault)
  end
end
function JumpVault:OnUGCJumpVisbilityChanged(_, _, bHide)
  if not self.UIRoot then
    print(bWriteLog and "JumpVault:OnUGCJumpVisbilityChanged self.UIRoot is nil")
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  self.UIRoot.Border_JumpVault:SetRenderScale(Scale)
end
function JumpVault:OnUGCVaultVisbilityChanged(_, _, bHide)
  if not self.UIRoot then
    print(bWriteLog and "JumpVault:OnUGCVaultVisbilityChanged self.UIRoot is nil")
    return
  end
  local Scale = FVector2D(1, 1)
  if bHide then
    Scale = FVector2D(0, 0)
  end
  self.UIRoot.Border_VaultBtn:SetRenderScale(Scale)
end
function JumpVault:OnPlayerCharacterChange(_, PlayerCharacter)
  GameComponentData.AddSelfVaultControllerComponentEvent(self, "OnVaultCheckFlagChange", self.OnCanVaultFlagChange, self)
  if slua_isValid(PlayerCharacter) and PlayerCharacter.GetVaultComponent then
    local VaultComponent = PlayerCharacter:GetVaultComponent()
    if slua_isValid(VaultComponent) then
      self:OnCanVaultFlagChange(VaultComponent:VaultCheckCPP())
    end
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:EndVault()
  end
end
function JumpVault:HandleVaultVisibility()
  print(bWriteLog and "JumpVault:HandleVaultVisibility")
  local RefreshVaultBtnSwitch = function(VaultBtnSwitch)
    print(bWriteLog and "JumpVault:HandleVaultVisibility RefreshVaultBtnSwitch " .. tostring(VaultBtnSwitch))
    self.IsShowVaultBtn = VaultBtnSwitch
    if not self.UIRoot then
      return
    end
    if VaultBtnSwitch then
      self.UIRoot.Vault_SettingControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.Vault_SettingControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
    self:RefreshJumpBtnIcon(false)
  end
  self:AddSettingOptionEvent("VaultBtnSwitch", RefreshVaultBtnSwitch, true)
end
function JumpVault:RefreshJumpBtnIcon(bCanVault)
  print(bWriteLog and "JumpVault:RefreshJumpBtnIcon bCanVault=" .. tostring(bCanVault))
  local SetVault = function()
    if self.IsPressingJumpingBtn then
      self.UIRoot.Image_JumpVault:SetBrushFromPathAsync(IconPath.vault_highlight, false)
    else
      self.UIRoot.Image_JumpVault:SetBrushFromPathAsync(IconPath.vault_normal, false)
    end
    self.ImageCircle:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  local SetJump = function()
    if self.IsPressingJumpingBtn then
      self.UIRoot.Image_JumpVault:SetBrushFromPathAsync(IconPath.jump_highlight, false)
    else
      self.UIRoot.Image_JumpVault:SetBrushFromPathAsync(IconPath.jump_normal, false)
    end
    if self.LastCanVault then
      self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      self.ImageCircle:SetWidgetVisibility(ESlateVisibility.Collapsed)
    else
      self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.Collapsed)
      self.ImageCircle:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
    local parent = self.UIRoot:GetParent()
    if parent and parent.Slot then
      parent.Slot:SetZOrder(0)
    end
  end
  if slua.isValid(self.UIRoot) then
    if self.IsShowVaultBtn then
      SetJump()
    else
      self.LastCanVault = bCanVault
      if bCanVault then
        SetVault()
      else
        SetJump()
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_REFRESH_JUMPBTN)
end
function JumpVault:OnHoldStartedJump()
  print(bWriteLog and "JumpVault:OnHoldStartedJump")
  if self.IsShowVaultBtn then
    print(bWriteLog and "JumpVault:OnHoldStartedJump self.IsShowVaultBtn")
    return
  end
  self:OnHoldStartedVault()
end
function JumpVault:OnHoldEndedJump()
  print(bWriteLog and "JumpVault:OnHoldEndedJump")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:EndVault()
  end
end
function JumpVault:OnHoldEndedVault()
  print(bWriteLog and "JumpVault:OnHoldEndedJump")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:EndVault()
  end
end
function JumpVault:OnQuickClickJump()
  print(bWriteLog and "JumpVault:OnQuickClickJump")
  if self.IsShowVaultBtn then
    print(bWriteLog and "JumpVault:OnQuickClickJump self.IsShowVaultBtn")
    return
  end
  self:OnQuickClickVault()
end
function JumpVault:OnPressdVault()
  print(bWriteLog and "JumpVault:OnPressdVault")
  self.IsPressingVaultBtn = true
  self:RefreshVaultBtnIcon()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:JumpDetailForCharacter()
  end
end
function JumpVault:OnReleasedVault()
  print(bWriteLog and "JumpVault:OnReleasedVault")
  self.IsPressingVaultBtn = false
  self:RefreshVaultBtnIcon()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "JumpVault:OnReleasedVault not slua.isValid(uPlayerCharacter)")
    return
  end
  if PlayerCharacter.PoseState == ESTEPoseState.Stand then
    PlayerCharacter:StopJumping()
    PlayerCharacter.Jumped = false
  end
end
function JumpVault:RefreshVaultBtnIcon()
  print(bWriteLog and "JumpVault:RefreshVaultBtnIcon")
  if self.IsPressingVaultBtn then
    self.UIRoot.Image_VaultIcon:SetBrushFromPathAsync(IconPath.vault_highlight, false)
  else
    self.UIRoot.Image_VaultIcon:SetBrushFromPathAsync(IconPath.vault_normal, false)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_REFRESH_VAULTBTN)
end
function JumpVault:OnHoldStartedVault()
  print(bWriteLog and "JumpVault:OnHoldStartedVault")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "JumpVault:OnHoldStartedVault not slua.isValid(uPlayerCharacter)")
    return
  end
  local VaultComponent = PlayerCharacter:GetVaultComponent()
  if not slua.isValid(VaultComponent) then
    print(bWriteLog and "JumpVault:OnHoldStartedVault not VaultComponent")
    return
  end
  VaultComponent.bHoldingVaultButton = true
end
function JumpVault:OnQuickClickVault()
  print(bWriteLog and "JumpVault:OnQuickClickVault")
  self.UIRoot.VaultBtn:OnHoldStartedBroadcast()
  if self.QuickTimerForVault then
    self:RemoveGameTimer(self.QuickTimerForVault)
    self.QuickTimerForVault = nil
  end
  self.QuickTimerForVault = self:AddGameTimer(0.4, false, function()
    self:EndQuickClick()
  end)
end
function JumpVault:EndQuickClick()
  self.QuickTimerForVault = nil
  self.UIRoot.VaultBtn:OnHoldEndedBroadcast()
end
function JumpVault:Sjump()
  self:OnPressdJump()
end
function JumpVault:Sjump_Release()
  self:OnReleasedJump()
end
function JumpVault:OnPressdJump(MyGeometry, MouseEvent)
  print(bWriteLog and "JumpVault:OnPressdJump")
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_PRESSED, "Jump")
  self.IsPressingJumpingBtn = true
  self:RefreshJumpBtnIcon(false)
  self.IsPressingVaultBtn = false
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:Jump()
  end
end
function JumpVault:OnReleasedJump()
  print(bWriteLog and "JumpVault:OnReleasedJump")
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_RELEASED, "Jump")
  self.IsPressingJumpingBtn = false
  self:RefreshJumpBtnIcon(false)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:UnJump()
  end
end
function JumpVault:OnCharacterCheckVault(bTryEnter)
  print(bWriteLog and "JumpVault:OnCharacterCheckVault bTryEnter=" .. tostring(bTryEnter))
  self.IsPressingVaultBtn = bTryEnter
  self:RefreshVaultBtnIcon()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem and bTryEnter then
    OperateSubsystem:JumpDetailForCharacter()
  end
end
function JumpVault:RefreshVaultBtnSwitch(VaultBtnSwitch)
  print(bWriteLog and "JumpVault:HandleVaultVisibility RefreshVaultBtnSwitch " .. tostring(VaultBtnSwitch))
  self.IsShowVaultBtn = VaultBtnSwitch
  if VaultBtnSwitch then
    self.UIRoot.Vault_SettingControl:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Vault_SettingControl:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function JumpVault:SetVaultHighLightImgVisible()
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  if OperateSubsystem:CheckCanVault() then
    if self.LastCanVault and self.UIRoot.LastIsShowVault ~= nil and self.UIRoot.LastIsShowVault == self.IsShowVaultBtn then
      return
    end
    self.LastCanVault = true
    if self.IsShowVaultBtn then
      if self.UIRoot.lightcircle_Img then
        self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.ImageCircle then
        self.UIRoot.ImageCircle:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    else
      if self.UIRoot.lightcircle_Img then
        self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
      if self.UIRoot.ImageCircle then
        self.UIRoot.ImageCircle:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      end
    end
  else
    if self.LastCanVault ~= nil and self.LastCanVault == false then
      return
    end
    self.LastCanVault = false
    if self.UIRoot.lightcircle_Img then
      self.UIRoot.lightcircle_Img:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
    if self.UIRoot.ImageCircle then
      self.UIRoot.ImageCircle:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end
function JumpVault:AddChildForJump(ChildWidget, NodeName)
  if not ChildWidget then
    return nil
  end
  if self.UIRoot[NodeName] then
    return self.UIRoot[NodeName]:AddChild(ChildWidget)
  end
  return nil
end
function JumpVault:SetJumpVaultCanvasVisibility(bShow)
  if bShow then
    self.UIRoot.Border_JumpVault:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_JumpVault:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, IconPath, JumpVault)
local LeanUIBP = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
local ESTEPoseState = import("ESTEPoseState")
function LeanUIBP:OnInitialize()
  self.PressPeekLeft = false
  self.SidewaysModeHandle = nil
end
function LeanUIBP:RegistEvents()
  self:HandlePeekVisibility()
  self:AddControlEventByControl(self.UIRoot.MultiButton_LeftSideOfTheBody, "OnMouseButtonDownEvent", self.OnLeftSidePressDown, self)
  self:AddControlEventByControl(self.UIRoot.MultiButton_LeftSideOfTheBody, "OnHoldEnded", self.OnLeftSideHoldEnded, self)
  self:AddControlEventByControl(self.UIRoot.MultiButton_RightSideOfTheBody, "OnMouseButtonDownEvent", self.OnRightSidePressDown, self)
  self:AddControlEventByControl(self.UIRoot.MultiButton_RightSideOfTheBody, "OnHoldEnded", self.OnRightSideHoldEnded, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeanCanvas_Rside, self, "ShootingUIPanel_MultiLayer_LeanCanvas_Rside")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeanCanvas_Lside, self, "ShootingUIPanel_MultiLayer_LeanCanvas_Lside")
  self:AddUIMessageEvent("ShowLeanIcon", self.ShowLeanIcon, self)
  self:AddUIMessageEvent("HideLeanIcon", self.HideLeanIcon, self)
  self:AddUIMessageEvent("EnterNearDeathStatus", self.HideLeanIcon, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerController", self.OnPlayerControllerChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    local PeekMode = SettingSubsystem:GetUserSettings_Int("SidewaysMode")
    self.UIRoot.MultiButton_LeftSideOfTheBody.ButtonType = PeekMode
    self.UIRoot.MultiButton_RightSideOfTheBody.ButtonType = PeekMode
    self.SidewaysModeHandle = SettingSubsystem:RegisterUserSettingsDelegate_Int("SidewaysMode", function(PeekMode)
      self.UIRoot.MultiButton_LeftSideOfTheBody.ButtonType = PeekMode
      self.UIRoot.MultiButton_RightSideOfTheBody.ButtonType = PeekMode
    end)
  end
end
function LeanUIBP:OnPostInitialize()
end
function LeanUIBP:OnClose()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeanCanvas_Lside)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeanCanvas_Rside)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if self.SidewaysModeHandle and SettingSubsystem then
    SettingSubsystem:UnregisterUserSettingDelegate(self.SidewaysModeHandle)
    self.SidewaysModeHandle = nil
  end
end
function LeanUIBP:SetWidgetVisibilityByName(WidgetName, Visibility)
  if self.UIRoot and self.UIRoot[WidgetName] and slua.isValid(self.UIRoot[WidgetName]) then
    self.UIRoot[WidgetName]:SetWidgetVisibility(Visibility)
  end
end
function LeanUIBP:ResetUIStateAfterRespawn()
  print(bWriteLog and "LeanUIBP:ResetUIStateAfterRespawn")
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Lside", UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Rside", UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function LeanUIBP:WeaponChange(TargetChangeSlot)
  print(bWriteLog and "LeanUIBP:WeaponChange")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if slua.isValid(CurWeapon) and CurWeapon.GetShootWeaponEntityComponent then
    local WeaponComponent = CurWeapon:GetShootWeaponEntityComponent()
    if slua.isValid(WeaponComponent) and not WeaponComponent.bEnableLeanOutHolding then
      Visibility = UEnums.ESlateVisibility.Collapsed
    end
  end
  self:SetWidgetVisibilityByName("GunHoldingControl_Lean_Lside", Visibility)
  self:SetWidgetVisibilityByName("GunHoldingControl_Lean_Rside", Visibility)
end
function LeanUIBP:HandlePlayerPoseChange(LastPoseState, NewPoseState)
  print(bWriteLog and "LeanUIBP:HandlePlayerPoseChange LastPoseState: " .. tostring(LastPoseState) .. " NewPoseState: " .. tostring(NewPoseState))
  if LastPoseState == NewPoseState then
    return
  end
  if NewPoseState == ESTEPoseState.Prone or NewPoseState == ESTEPoseState.Crawl then
    self:SetWidgetVisibilityByName("Lean_Lside_ProneCrouchControl", UEnums.ESlateVisibility.Collapsed)
    self:SetWidgetVisibilityByName("Lean_Rside_ProneCrouchControl", UEnums.ESlateVisibility.Collapsed)
  elseif NewPoseState == ESTEPoseState.Stand or NewPoseState == ESTEPoseState.Sprint or NewPoseState == ESTEPoseState.Crouch or NewPoseState == ESTEPoseState.CrouchSprint then
    self:SetWidgetVisibilityByName("Lean_Lside_ProneCrouchControl", UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetWidgetVisibilityByName("Lean_Rside_ProneCrouchControl", UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function LeanUIBP:HandlePeekVisibility()
  print(bWriteLog and "LeanUIBP:HandlePeekVisibility")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    self:AddGameTimer(1, false, function()
      self:HandlePeekVisibility()
    end)
    return
  end
  local RefreshLeftRightShoot = function(LeftRightShoot)
    print(bWriteLog and "LeanUIBP:HandlePeekVisibility RefreshLeftRightShoot " .. tostring(LeftRightShoot))
    if not self.UIRoot or not slua.isValid(self.UIRoot) then
      return
    end
    self.UIRoot.bIsShowPeek = LeftRightShoot
    if LeftRightShoot then
      self:SetWidgetVisibilityByName("Lean_SettingControl_Lside", UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetWidgetVisibilityByName("Lean_SettingControl_Rside", UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self:SetWidgetVisibilityByName("Lean_SettingControl_Lside", UEnums.ESlateVisibility.Collapsed)
      self:SetWidgetVisibilityByName("Lean_SettingControl_Rside", UEnums.ESlateVisibility.Collapsed)
    end
  end
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("LeftRightShoot", RefreshLeftRightShoot)
  RefreshLeftRightShoot(SettingSubsystem:GetUserSettings_Bool("LeftRightShoot"))
end
function LeanUIBP:OnLeftSidePressDown(MyGeometry, MouseEvent)
  self.PressPeekLeft = true
  local UKismetInputLibrary = import("KismetInputLibrary")
  local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:PressedLeftLean(PointerIndex)
  end
end
function LeanUIBP:OnLeftSideHoldEnded()
  if self.PressPeekLeft == nil then
    self.PressPeekLeft = true
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ReleasedLeftLean()
  end
end
function LeanUIBP:OnRightSidePressDown(MyGeometry, MouseEvent)
  self.PressPeekLeft = false
  local UKismetInputLibrary = import("KismetInputLibrary")
  local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(MouseEvent)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:PressedRightLean(PointerIndex)
  end
end
function LeanUIBP:OnRightSideHoldEnded()
  if self.PressPeekLeft == nil then
    self.PressPeekLeft = false
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ReleasedRightLean()
  end
end
function LeanUIBP:OnPlayerCharacterChange(_, PlayerCharacter)
  if slua.isValid(PlayerCharacter) then
    GameplayData.AddSelfPlayerCharacterEvent(self, "CharacterAnimEventDelegate", self.CharacterAnimEventDelegate, self)
    self:AddControlEventByControl(PlayerCharacter, "OnPlayerPoseChange", self.HandlePlayerPoseChange, self)
    self:HandlePlayerPoseChange(-1, PlayerCharacter.PoseState)
    local WeaponManager = PlayerCharacter:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      self:AddControlEventByControl(WeaponManager, "ChangeCurrentUsingWeaponDelegate", self.WeaponChange, self)
      local CurrentUsingSlot = WeaponManager:GetCurrentUsingPropSlot()
      self:WeaponChange(CurrentUsingSlot)
    end
  end
end
function LeanUIBP:OnPlayerControllerChange(_, PlayerController)
  if slua.isValid(PlayerController) then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType, _ = GameMainConfig.GetModType()
    if ModType == "BRTDM" then
      GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.OnRepPlayerState, self)
      self:OnRepPlayerState()
    end
    if ModType == "TDM" then
      GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStartCountDownDelegate", self.UpdateCountDown, self)
    end
  end
end
function LeanUIBP:OnReconnect()
  print(bWriteLog and "LeanUIBP:OnReconnect")
  self:HandlePeekVisibility()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    self:OnPlayerCharacterChange(nil, PlayerCharacter)
    if PlayerCharacter.IsNearDeath and PlayerCharacter:IsNearDeath() then
      print(bWriteLog and "LeanUIBP:OnReconnect Neardeath hide")
      self:HideLeanIcon()
    end
  end
end
function LeanUIBP:OnRepPlayerState()
  GameplayData.AddSelfPlayerStateEvent(self, "DeathMatchPersonalDieNotifyDelegate", function()
    print(bWriteLog and "LeanUIBP:OnRepPlayerState")
    self:OnDisablePeek()
  end)
end
function LeanUIBP:UpdateCountDown(CountDownTime)
  if CountDownTime < 0 then
    self:OnDisablePeek()
  end
end
function LeanUIBP:CharacterAnimEventDelegate(EventName)
  print(bWriteLog and "LeanUIBP:CharacterAnimEventDelegate EventName: " .. tostring(EventName))
  if EventName == "PeekState" then
    self:OnPeekStateChange()
  end
end
function LeanUIBP:OnPeekStateChange()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if not PlayerCharacter:IsLocallyControlled() then
    return
  end
  if not slua.isValid(PlayerCharacter.SpringArmComp) then
    return
  end
  if PlayerCharacter:HasState(UEnums.EPawnState.Picth) then
    if PlayerCharacter.IsPeekLeft then
      self:OnPeekLeft()
    else
      self:OnPeekRight()
    end
  else
    self:OnDisablePeek()
  end
end
function LeanUIBP:OnPeekLeft()
  print(bWriteLog and "LeanUIBP:OnPeekLeft")
  self:SetWidgetVisibilityByName("Image_ClickLeftSideOfTheBody", UEnums.ESlateVisibility.HitTestInvisible)
  self:SetWidgetVisibilityByName("Image_ClickRightSideOfTheBody", UEnums.ESlateVisibility.Collapsed)
end
function LeanUIBP:OnPeekRight()
  print(bWriteLog and "LeanUIBP:OnPeekRight")
  self:SetWidgetVisibilityByName("Image_ClickRightSideOfTheBody", UEnums.ESlateVisibility.HitTestInvisible)
  self:SetWidgetVisibilityByName("Image_ClickLeftSideOfTheBody", UEnums.ESlateVisibility.Collapsed)
end
function LeanUIBP:OnDisablePeek()
  print(bWriteLog and "LeanUIBP:OnDisablePeek")
  self:SetWidgetVisibilityByName("Image_ClickRightSideOfTheBody", UEnums.ESlateVisibility.Collapsed)
  self:SetWidgetVisibilityByName("Image_ClickLeftSideOfTheBody", UEnums.ESlateVisibility.Collapsed)
end
function LeanUIBP:ShowLeanIcon()
  print(bWriteLog and "LeanUIBP:ShowLeanIcon")
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Lside", UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Rside", UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function LeanUIBP:HideLeanIcon()
  print(bWriteLog and "LeanUIBP:HideLeanIcon")
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Lside", UEnums.ESlateVisibility.Collapsed)
  self:SetWidgetVisibilityByName("NearDeathControl_Lean_Rside", UEnums.ESlateVisibility.Collapsed)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLeanUIBP = class(ui_base, nil, LeanUIBP)
return CLeanUIBP
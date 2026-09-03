local ShoulderBtnPanel = {}
function ShoulderBtnPanel:ctor(selfType)
  self.bShoulderEnable = true
  self.bShoulderClicked = false
  self.bRotateViewWithShoulderSwitch = false
end
function ShoulderBtnPanel:Initialize()
  self:AddControlEvent(self.HandleStateCanvasPanel, "OnCanvasPanelPlayerWeaponChanged", self.OnCanvasPanelPlayerWeaponChanged, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.ResetUIStateAfterRespawn, self)
  self:AddControlEvent(self.MultiShoulderButton, "OnPressDown", self.OnMultiBtnPressDown, self)
  self:AddControlEvent(self.MultiShoulderButton, "OnHoldEnded", self.OnMultiBtnHoldEnded, self)
  self:RefreshState()
  self:BindPlayerEvent()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    self.DelegateHandle_RotateSwitch = SettingSubsystem:RegisterUserSettingsDelegate_Bool("RotateViewWithShoulderSwitch", function(bRotateViewWithShoulderSwitch)
      print(bWriteLog and "ShoulderBtnPanel:EventRotateViewWithShoulderSwitch11", bRotateViewWithShoulderSwitch)
      self:EventRotateViewWithShoulderSwitch(bRotateViewWithShoulderSwitch)
    end)
    self.DelegateHandle_Switch = SettingSubsystem:RegisterUserSettingsDelegate_Bool("ShoulderEnable", function(bShoulderEnable)
      self:RefreshShoulderBtnShow(bShoulderEnable)
    end)
  end
  local uSettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if slua.isValid(uSettingConfig) then
    local bShoulderEnable = uSettingConfig.ShoulderEnable or false
    self:RefreshShoulderBtnShow(bShoulderEnable)
    local bRotateViewWithShoulderSwitch = uSettingConfig.RotateViewWithShoulderSwitch or false
    self:EventRotateViewWithShoulderSwitch(bRotateViewWithShoulderSwitch)
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReConnectGameStateInfoNotify, self)
end
function ShoulderBtnPanel:BindPlayerEvent()
  print(bWriteLog and "ShoulderBtnPanel:BindPlayerEvent")
  local uPlayerController = self:GetOwningPlayer()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(uPlayerCharacter) then
      uPlayerCharacter = self:GetOwningPlayerPawn()
    end
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.CharacterCommonEventDelegate then
      print(bWriteLog and "ShoulderBtnPanel:BindPlayerEvent Bind CharacterCommonEventDelegate Success")
      self:AddControlEvent(uPlayerCharacter, "CharacterCommonEventDelegate", self.HandleCharacterCommonEventDelegate, self)
    else
      print(bWriteLog and "ShoulderBtnPanel:BindPlayerEvent Bind failed, uPlayerCharacter is nill")
    end
  else
    print(bWriteLog and "ShoulderBtnPanel:BindPlayerEvent Bind failed, uPlayerController is nill")
  end
end
function ShoulderBtnPanel:OnReConnectGameStateInfoNotify()
  print(bWriteLog and "ShoulderBtnPanel:OnReConnectGameStateInfoNotify")
  local uPlayerController = self:GetOwningPlayer()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      uPlayerCharacter:SwitchShoulderStateLocal(false)
    end
  end
end
function ShoulderBtnPanel:OnClicked()
  if not self.bShoulderEnable then
    print(bWriteLog and "ShoulderBtnPanel:OnClicked failed", self.bShoulderEnable)
    return
  end
  self.bShoulderClicked = not self.bShoulderClicked
  local uPlayerController = self:GetOwningPlayer()
  local uPlayerCharacter = self:GetOwningPlayerPawn()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerCharacter) then
    uPlayerCharacter:SwitchShoulderState(self.bShoulderClicked)
  end
  self:RefreshState()
end
function ShoulderBtnPanel:OnMultiBtnPressDown(PointerIndex)
  local UWidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  if not self.bShoulderEnable then
    print(bWriteLog and "ShoulderBtnPanel:OnShoulderBtnMouseButtonDownEvent failed", self.bShoulderEnable, self.bShoulderClicked)
    return
  end
  print(bWriteLog and "ShoulderBtnPanel:OnShoulderBtnMouseButtonDownEvent", self.bShoulderEnable, self.bShoulderClicked)
  local uPlayerController = self:GetOwningPlayer()
  local uPlayerCharacter = self:GetOwningPlayerPawn()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerCharacter) then
    local EPawnState = import("EPawnState")
    if not self.bShoulderClicked then
      if not uPlayerCharacter.AllowState then
        return
      end
      if not uPlayerCharacter:AllowState(EPawnState.Shoulder, true) then
        print(bWriteLog and "ShoulderBtnPanel:OnShoulderBtnMouseButtonDownEvent not allow enter shoulder", self.bShoulderEnable, self.bShoulderClicked)
        return
      end
    end
    self.bShoulderClicked = not self.bShoulderClicked
    uPlayerCharacter:SwitchShoulderState(self.bShoulderClicked)
    uPlayerController:SetTouchFingerIndex(true, PointerIndex)
    self.MultiShoulderButton.ButtonType = uPlayerController.ShoulderMode
    if not self.bRotateViewWithShoulderSwitch then
      uPlayerController:AddIgnoreCameraMoveIndex(PointerIndex)
    end
    self:RefreshState()
  end
end
function ShoulderBtnPanel:OnMultiBtnHoldEnded()
  local USTExtraUIUtils = import("STExtraUIUtils")
  local uCharacter = USTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self)
  if slua.isValid(uCharacter) then
    self.bShoulderClicked = false
    uCharacter:SwitchShoulderState(false)
    self:RefreshState()
  end
end
function ShoulderBtnPanel:OnCanvasPanelPlayerWeaponChanged(TargetSlot, uWeaponManagerComp)
  print(bWriteLog and "ShoulderBtnPanel:OnCanvasPanelPlayerWeaponChanged", TargetSlot, uWeaponManagerComp)
  if slua.isValid(uWeaponManagerComp) then
    local uShootWeapon = uWeaponManagerComp:GetCurrentUsingWeapon()
    if slua.isValid(uShootWeapon) and uShootWeapon.GetShootWeaponEntityComponent then
      local uShootWeaponEntity = uShootWeapon:GetShootWeaponEntityComponent()
      if slua.isValid(uShootWeaponEntity) and uShootWeaponEntity.bEnableShoulder then
        return true
      end
    end
  end
  return false
end
function ShoulderBtnPanel:RefreshState()
  if self.bShoulderClicked then
    self.Image_Shoulder_Open:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Shoulder_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.Image_Shoulder_Open:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.Image_Shoulder_Close:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ShoulderBtnPanel:ResetUIStateAfterRespawn()
  print(bWriteLog and "ShoulderBtnPanel:ResetUIStateAfterRespawn", self.bShoulderClicked)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local CurGameState = uGameState:GetGameModeState()
    if CurGameState ~= "ReadyState" or CurGameState ~= "ActiveState" then
      self.bShoulderClicked = false
      self:RefreshState()
    end
  end
  self:BindPlayerEvent()
end
function ShoulderBtnPanel:HandleCharacterCommonEventDelegate(sEventMsg)
  print(bWriteLog and "ShoulderBtnPanel:HandleCharacterCommonEventDelegate", sEventMsg)
  if sEventMsg == "ShoulderState" then
    local uController = self:GetOwningPlayer()
    if slua.isValid(uController) then
      local uCharacter = uController:GetPlayerCharacterSafety()
      local EPawnState = import("EPawnState")
      if slua.isValid(uCharacter) and uCharacter:HasState(EPawnState.Shoulder) then
        self.bShoulderClicked = true
      else
        self.bShoulderClicked = false
      end
      self:RefreshState()
    end
  end
end
function ShoulderBtnPanel:RefreshShoulderBtnShow(bShoulderEnable)
  print(bWriteLog and "ShoulderBtnPanel:RefreshShoulderBtnShow", bShoulderEnable)
  self.  if bShoulderEnable then
    self.VisibleControlOverlay:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.VisibleControlOverlay:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if not bShoulderEnable then
    local uController = self:GetOwningPlayer()
    if slua.isValid(uController) then
      local uCharacter = uController:GetPlayerCharacterSafety()
      local EPawnState = import("EPawnState")
      if slua.isValid(uCharacter) and uCharacter:HasState(EPawnState.Shoulder) then
        self.bShoulderClicked = false
        uCharacter:SwitchShoulderState(false)
        self:RefreshState()
      end
    end
  end
end
function ShoulderBtnPanel:EventRotateViewWithShoulderSwitch(bRotateViewWithShoulderSwitch)
  print(bWriteLog and "ShoulderBtnPanel:EventRotateViewWithShoulderSwitch", bRotateViewWithShoulderSwitch)
  self.end
function ShoulderBtnPanel:OnReleaseShoulder(FingerIndex)
  print(bWriteLog and "ShoulderBtnPanel:OnReleaseShoulder", FingerIndex)
  local USTExtraUIUtils = import("STExtraUIUtils")
  local uCharacter = USTExtraUIUtils.GetOwningPlayerPawnOrVehicleDriver(self)
  if slua.isValid(uCharacter) then
    self.bShoulderClicked = false
    uCharacter:SwitchShoulderState(false)
    self:RefreshState()
  end
end
function ShoulderBtnPanel:OnDestroy()
  print(bWriteLog and "ShoulderBtnPanel:OnDestroy")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:UnregisterUserSettingDelegate(self.DelegateHandle_RotateSwitch)
    SettingSubsystem:UnregisterUserSettingDelegate(self.DelegateHandle_Switch)
  end
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CShoulderBtnPanel = class(CDelegateContainer, nil, ShoulderBtnPanel)
return CShoulderBtnPanel
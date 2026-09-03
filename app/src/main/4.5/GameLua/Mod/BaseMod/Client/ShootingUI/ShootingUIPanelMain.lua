local EPawnState = import("EPawnState")
local ETouchIndex = import("ETouchIndex")
local ESTEPoseState = import("ESTEPoseState")
local ETouchFireType = import("ETouchFireType")
local EPlayerCameraMode = import("EPlayerCameraMode")
local EWeaponOperationMode = import("EWeaponOperationMode")
local ECurPlayerHandStatus = UEnums.ECurPlayerHandStatus
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
local HandleStateCanvasUtils = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasUtils")
require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanel_Fire")
require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanel_Guide")
require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanel_Skill")
require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanel_Grenade")
require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanel_WeaponSlot")
function ShootingUIPanelIMP:ctor()
  self.bHaveRegistEvents = false
  self:Grenade_ctor()
  self:WeaponSlot_ctor()
  self:Skill_ctor()
  self.bRegist3DTouchEvents = false
  self.CrouchImageIndex = 1
  self.IsEmulator = false
  self.Settings_LeftHandFire = 0
  self.FingerIndex3DTouch = ETouchIndex.Touch10
  self.BareHandHideTipsArray = {}
  self.AutoCollapsedScoping = false
  self.ShotGunReleaseFireType = 0
  self.SniperReleaseFireType = 0
  self.ReleaseFireWeaponCache = nil
  self.ScopeAfterPrefire = false
  self.ScopeAfterReload = false
  self.WeaponManager = nil
  self.FireFingerIndex_Right = ETouchIndex.Touch1
  self.FireFingerIndex_Left = ETouchIndex.Touch1
  self.NewbieTips_ConsumeTips = nil
  self.NewbieTips_SearchBuild = nil
  self.NewbieTips_JumpingMoveCam = nil
  self.NewbieTips_Joystick = nil
  self.NewbieTips_GrenadeList = nil
  self.NewbieTips_LeftFire = nil
  self.NewbieTips_RightFire = nil
  self.NewbieTips_Reload = nil
  self.CurGrenadeID = 0
end
function ShootingUIPanelIMP:OnInitialize()
  ShootingUIPanelIMP.__super.OnInitialize(self)
  self.FingerIndex3DTouch = ETouchIndex.Touch10
  print(bWriteLog and "ShootingUIPanelIMP:OnInitialize")
end
function ShootingUIPanelIMP:OnInitializeDelay()
  print(bWriteLog and "ShootingUIPanelIMP:OnInitializeDelay")
  self.IsEmulator = Client.IsEmulatorWhenInit()
  self:InitCppWidget()
  self:InitWeaponSlotData()
  self:InitLeanUIBP()
  self:InitMultiLayerPModePanel()
  self:InitScopeZoomUIBP()
  self:InitProneUIBP()
  self:InitCrouchUIBP()
  self:InitJumpVaultUI()
  self:InitShootAimUI()
  self:InitRedSightUI()
  self:InitReloadUI()
  self:InitSwitchThrowUI()
  self:InitMedicineChooseWidgetNew()
  self:BindWeaponChangeDelegate()
  self:BindPickupUpdateBullet()
  self:InitLocalize()
  self:InitBareHandHideArray()
  self:InitAimAndPeekHold()
  self:InitPlayerControllerVariables()
  self:UpdateWeaponBulletCount()
  self:UpdateGunImage()
  self:InitMSSwitchUI()
  self:InitThrowUI()
  self:InitShootingAutoSprintUI()
end
function ShootingUIPanelIMP:RegistEventsDelay()
  if self.bHaveRegistEvents then
    print(bWriteLog and "ShootingUIPanelIMP:RegistEventsDelay bHaveRegistEvents true")
    return
  end
  self.bHaveRegistEvents = true
  print(bWriteLog and "ShootingUIPanelIMP:RegistEventsDelay")
  self:RegistEvents_Fire()
  self:RegistEvents_Grenade()
  self:RegistEvents_WeaponSlot()
  self:RegistEvents_Guide()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.HandleUIWhenPlayerOnPlane, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.HandleUIWhenPlayerLand, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSwitchCameraModeStart", self.CameraModeChange, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root, self, "ShootingUIPanel_CanvasPanel_Root")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BtnGroup, self, "ShootingUIPanelCanvasPanelBtnGroup")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.ShoulderBtnPanel, self, "ShootingUIPanel_ShoulderBtnPanel")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.SkillLayer, self, "ShootingUIPanel_SkillLayer")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_CustomWeaponUI, self, "ShootingUIPanel_CustomWeaponUI")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_Pistol, self, "ShootingUIPanel_MultiLayer_Pistol")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeftWeaponSlot, self, "ShootingUIPanel_MultiLayer_LeftWeaponSlot")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_RightWeaponSlot, self, "ShootingUIPanel_MultiLayer_RightWeaponSlot")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ChatCanvas, self, "ShootingUIPanel_MultiLayer_ChatCanvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ConsumableCanvas, self, "ShootingUIPanel_MultiLayer_ConsumableCanvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_GrenadeCanvas, self, "ShootingUIPanel_MultiLayer_GrenadeCanvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ThemePropCanvas, self, "ShootingUIPanel_MultiLayer_ThemePropCanvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_PMode, self, "ShootingUIPanel_MultiLayer_PMode")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_AICommand, self, "ShootingUIPanel_AICommand_Canvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeftFireCanvas, self, "ShootingUIPanel_MultiLayer_LeftFireCanvas")
  HandleStateCanvasUtils.RegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_RightFireCanvas, self, "ShootingUIPanel_MultiLayer_RightFireCanvas")
  self:AddUIMessageEvent("UIMsg_FadeIn", self.UIMsg_FadeIn, self)
  self:AddUIMessageEvent("UIMsg_StopFade", self.UIMsg_StopFade, self)
  self:AddUIMessageEvent("EnterNearDeathStatus", self.OnEnterNearDeathStatus, self)
  self:AddUIMessageEvent("UIMsg_ResetCancelFireBtn", self.UIMsg_ResetCancelFireBtn, self)
  self:AddUIMessageEvent("UIMsg_RespawnSetUI", self.ResetUIStateAfterRespawn, self)
  self:AddUIMessageEvent("UIMsg_UpdateWeaponFuntion", self.UIMsg_UpdateWeaponFuntion, self)
  self:AddUIMessageEvent("UIMsg_ScopeChanged", self.UIMsg_ScopeChanged, self)
  self:AddUIMessageEvent("ShowOrHideForReplayUI", self.ShowOrHideForReplayUI, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
  self:SetSettingControlUI()
  local Bridge
  if slua.isValid(CGameWorld) then
    local STExtraGameplayStatics = import("STExtraGameplayStatics")
    Bridge = STExtraGameplayStatics.GetGameBridge(CGameWorld)
  end
  if slua.isValid(Bridge) then
    self:AddControlEventByControl(Bridge, "OnPlayReplayBegin", self.OnSpectatorReplayChanged, self)
    self:AddControlEventByControl(Bridge, "OnPlayReplayEnd", self.OnSpectatorReplayChanged, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTER_OBSERVE, self.OnSpectatorReplayChanged, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.OnSpectatorReplayChanged, self)
    self:OnSpectatorReplayChanged()
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self.bSeperateShootMBtn = SettingModule:GetOptionValue("bSeperateShootMBtn")
  if self.FirWeaponSlot and self.SecWeaponSlot then
    self.FirWeaponSlot:ShowHideEmbeddedMSwitch(not self.bSeperateShootMBtn)
    self.SecWeaponSlot:ShowHideEmbeddedMSwitch(not self.bSeperateShootMBtn)
  end
  self:AddSettingOptionEvent("bSeperateShootMBtn", function(bSeperateShootMBtn)
    print(bWriteLog and "ShootingUIPanelIMP:RegistEventsDelay bSeperateShootMBtn:" .. tostring(bSeperateShootMBtn))
    if bSeperateShootMBtn ~= self.bSeperateShootMBtn then
      self.      if self.FirWeaponSlot and self.SecWeaponSlot then
        self.FirWeaponSlot:ShowHideEmbeddedMSwitch(not self.bSeperateShootMBtn)
        self.SecWeaponSlot:ShowHideEmbeddedMSwitch(not self.bSeperateShootMBtn)
      end
    end
  end)
end
function ShootingUIPanelIMP:OnPlayerCharacterChange(_, PlayerCharacter)
  print(bWriteLog and "ShootingUIPanelIMP:OnPlayerCharacterChange")
  self:BindWeaponChangeDelegate()
  GameplayData.AddSelfPlayerCharacterEventWithCondition(self, "StateEnterHandler", {
    state = {
      EPawnState.DriveVehicle,
      EPawnState.Swim,
      EPawnState.Diving,
      EPawnState.InVehicle
    }
  }, self.StateEnterHandler, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnHandleSkillStartDelegate", self.HandleSkillStartEvent, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnHandleSkillEndDelegate", self.HandleSkillEndEvent, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnSkillFinishedDelegate", self.SkillFinishedEvent_Grenade, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnWeaponFireModeChangeDelegate", self.HandleCurWeaponFireModeChange, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnWeaponShootIntervalModeChangeDelegate", self.OnWeaponShootIntervalModeChange, self)
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  if slua.isValid(PlayerCharacter) and PlayerCharacter.HealthStatus == ECharacterHealthStatus.HasLastBreath then
    self:OnEnterNearDeathStatus()
  end
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  logicSettingGraphics.DowngradeFpsLevelTemporarily(false)
end
function ShootingUIPanelIMP:OnSpectatorReplayChanged()
  self.UIRoot.NewbieGuideCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not slua.isValid(CGameWorld) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(CGameWorld, 0)
  if not slua.isValid(PlayerController) or not PlayerController.HasAnySpectatorReplayFlag then
    return
  end
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  if PlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay) then
    self.UIRoot.NewbieGuideCanvas:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ShootingUIPanelIMP:OnEnterNearDeathStatus()
end
function ShootingUIPanelIMP:IsDriving()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return false
  end
  local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_AsDriver then
    return false
  end
  return true
end
function ShootingUIPanelIMP:IsPassenger()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return false
  end
  local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
  if VehicleUserComponent.VehicleUserState ~= ESTExtraVehicleUserState.EVUS_ASPassenger then
    return false
  end
  return true
end
function ShootingUIPanelIMP:GetVehicleUserComponent()
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    return nil
  end
  return VehicleUserComponent
end
function ShootingUIPanelIMP:Regist3DTouchEvents()
  if self.bRegist3DTouchEvents then
    return
  end
  self.bRegist3DTouchEvents = true
  self:AddControlEventByControl(GameplayData.GetPlayerController(), "On3DTouchForceChange", function()
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      if PlayerController.bDisableFireAction then
        return
      end
      self:Do3DTouch(PlayerController)
    end
  end)
  self:AddControlEventByControl(GameplayData.GetPlayerController(), "OnDoubleClickCheck", function(FingerIndex)
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and PlayerController.bDisableFireAction then
      return
    end
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if slua.isValid(PlayerCharacter) and not PlayerCharacter.bIsGunADS then
      self:OnPressFireBtn(FingerIndex, 0, ETouchFireType.DoubleClickFire, false)
    end
  end)
end
function ShootingUIPanelIMP:InitCppWidget()
  self.UIRoot.FireBtn = self.UIRoot.OnFireBtn_Rside
end
function ShootingUIPanelIMP:InitWeaponSlotData()
  if not self.FirWeaponSlot then
    self.FirWeaponSlot = self:CreateChildWindow("MultiLayer_LeftWeaponSlot", UIManager.UI_Config_InGame.SwitchWeaponSlot, ESurviveWeaponPropSlot.SWPS_MainShootWeapon1)
  end
  self.FirWeaponSlot:ClearWeaponSlotData()
  if not self.SecWeaponSlot then
    self.SecWeaponSlot = self:CreateChildWindow("MultiLayer_RightWeaponSlot", UIManager.UI_Config_InGame.SwitchWeaponSlot, ESurviveWeaponPropSlot.SWPS_MainShootWeapon2)
  end
  self.SecWeaponSlot:ClearWeaponSlotData()
  if not self.PistolModeUI or not UIManager.GetUI(UIManager.UI_Config_InGame.PistolMode) then
    local PistolUI = UIManager.ShowUI(UIManager.UI_Config_InGame.PistolMode)
    self:AttachChildWindow("MultiLayer_Pistol", PistolUI)
    PistolUI:SetAnchors(0, 0, 0, 0)
    PistolUI:SetOffsets(0, 0, 148, 32)
    PistolUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.PistolModeUI = PistolUI
  end
  self:OnJaguarBlockTransaction()
end
function ShootingUIPanelIMP:ShowOrHideForReplayUI(State)
  if 1 < State then
    self.UIRoot.HistoricalNewsCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.HistoricalNewsCanvasPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ShootingUIPanelIMP:UIMsg_ScopeChanged()
  print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_ScopeChanged")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_ScopeChanged not uPlayerCharacter")
    return
  end
  if PlayerCharacter.bIsGunADS then
    self:OnJaguarBlockTransaction()
  end
end
function ShootingUIPanelIMP:OnJaguarBlockTransaction()
  print(bWriteLog and "ShootingUIPanelUIBase:OnJaguarBlockTransaction")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnJaguarBlockTransaction not uGameState")
    return false
  end
  self.JaguarBlockTransaction = false
  return not GameState.IsCanSwitchFPP
end
function ShootingUIPanelIMP:InitBareHandHideArray()
  print(bWriteLog and "ShootingUIPanelUIBase:InitBareHandHideArray")
  self.BareHandHideTipsArray = {
    self.UIRoot.TipsLeftFire_BareHandControl,
    self.UIRoot.TipsReload_BareHandControl,
    self.UIRoot.TipsRightFire_BareHandControl
  }
end
function ShootingUIPanelIMP:InitLeanUIBP()
  self:CreateChildWindow("LeanBtnPanel", UIManager.UI_Config_InGame.LeanUIBP)
end
function ShootingUIPanelIMP:InitMultiLayerPModePanel()
  print(bWriteLog and "ShootingUIPanelUIBase:InitMultiLayerPModePanel")
  self:CreateChildWindow("MultiLayer_PMode", UIManager.UI_Config_InGame.MultiLayer_PMode_UIBP)
end
function ShootingUIPanelIMP:InitShootAimUI()
  self:CreateChildWindow("ShootAimBtnPanel", UIManager.UI_Config_InGame.ShootAimBtnUI)
end
function ShootingUIPanelIMP:InitMSSwitchUI()
  self:CreateChildWindow("CanvasPanel_Weapon", UIManager.UI_Config_InGame.MSSwitchUI)
end
function ShootingUIPanelIMP:InitThrowUI()
  self:CreateChildWindow("CanvasPanelLowRate", UIManager.UI_Config_InGame.AttackThrowSwitchBtn)
  self:CreateChildWindow("CanvasPanelMediumRate", UIManager.UI_Config_InGame.CancelThrowBtn)
end
function ShootingUIPanelIMP:InitShootingAutoSprintUI()
  self:CreateChildWindow("ShootingUI_AutoSprint", UIManager.UI_Config_InGame.ShootingUI_AutoSprintBtn)
end
function ShootingUIPanelIMP:InitScopeZoomUIBP()
  self:CreateChildWindow("ScopeZoomPanel", UIManager.UI_Config_InGame.ScopeZoomUIBP)
end
function ShootingUIPanelIMP:InitProneUIBP()
  print(bWriteLog and "ShootingUIPanelIMP:InitProneUIBP")
  self:CreateChildWindow("Prone", UIManager.UI_Config_InGame.ProneUIBP)
end
function ShootingUIPanelIMP:InitCrouchUIBP()
  print(bWriteLog and "ShootingUIPanelIMP:InitCrouchUIBP")
  self:CreateChildWindow("Crouch", UIManager.UI_Config_InGame.CrouchUIBP)
end
function ShootingUIPanelIMP:InitJumpVaultUI()
  print(bWriteLog and "ShootingUIPanelIMP:InitCrouchUIBP")
  self:CreateChildWindow("JumpVaultPanel", UIManager.UI_Config_InGame.JumpVaultBtn)
end
function ShootingUIPanelIMP:InitRedSightUI()
  print(bWriteLog and "ShootingUIPanelIMP:InitRedSightUI")
  self:CreateChildWindow("CustomShootRed", UIManager.UI_Config_InGame.RedSightUIBP)
end
function ShootingUIPanelIMP:InitReloadUI()
  print(bWriteLog and "ShootingUIPanelIMP:InitReloadUI")
  self:CreateChildWindow("ReloadPanel", UIManager.UI_Config_InGame.ReloadUI)
end
function ShootingUIPanelIMP:InitSwitchThrowUI()
  print(bWriteLog and "ShootingUIPanelIMP:InitSwitchThrowUI")
  self:CreateChildWindow("SwitchThrowBtnPanel", UIManager.UI_Config_InGame.SwitchThrowUI)
end
function ShootingUIPanelIMP:InitMedicineChooseWidgetNew()
  print(bWriteLog and "ShootingUIPanelIMP:InitMedicineChooseWidgetNew")
  self:CreateChildWindow("ConsumableSocket", UIManager.UI_Config_InGame.MedicineChooseWidgetNew)
end
function ShootingUIPanelIMP:InitAimAndPeekHold()
  print(bWriteLog and "ShootingUIPanelUIBase:InitAimAndPeekHold")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:InitAimAndPeekHold not slua.isValid(PlayerCharacter)")
    self:AddGameTimer(0.5, false, function()
      self:InitAimAndPeekHold()
    end)
    return
  end
end
function ShootingUIPanelIMP:InitPlayerControllerVariables()
  print(bWriteLog and "ShootingUIPanelUIBase:InitPlayerControllerVariables")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:InitPlayerControllerVariables not slua.isValid(uPlayerController)")
    return
  end
  self:AddDataListener(PlayerController:GetSuperData(), "IsUse3DTouch", function(_, IsUse3DTouch)
    self:Init3DTouch(IsUse3DTouch)
  end)
end
function ShootingUIPanelIMP:Init3DTouch(IsUse3DTouch)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if IsUse3DTouch then
    self:SetFireBtnVisible(UEnums.ESlateVisibility.Hidden)
    self:Regist3DTouchEvents()
  else
    self:SetFireBtnVisible(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.FingerIndex3DTouch = ETouchIndex.Touch10
    if self.bRegist3DTouchEvents then
      self:RemoveControlEventByControl(PlayerController, "On3DTouchForceChange")
      self:RemoveControlEventByControl(PlayerController, "OnDoubleClickCheck")
      self.bRegist3DTouchEvents = false
    end
  end
end
function ShootingUIPanelIMP:ResetUIStateAfterRespawn()
  print(bWriteLog and "ShootingUIPanelUIBase:ResetUIStateAfterRespawn")
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(GameState) then
    print(bWriteLog and "ShootingUIPanelUIBase:ResetUIStateAfterRespawn not slua.isValid(uGameState)")
    return
  end
  local EGameModeType = import("EGameModeType")
  local bIsInfectGameMode = GameState.GameModeType == EGameModeType.EPVEInfectionGameMode
  if bIsInfectGameMode then
    GameplayData.AddSelfPlayerCharacterEvent(self, "OnWeaponFireModeChangeDelegate", function()
      self:HandleCurWeaponFireModeChange()
    end)
  end
  if GameState.GameModeType == EGameModeType.EWarGameMode then
    self:BindWeaponChangeDelegate()
  end
  if GameState.bReInitUIAfterReCreatePawn then
    print(bWriteLog and "ShootingUIPanelUIBase:ResetUIStateAfterRespawn uGameState.bReInitUIAfterReCreatePawn")
    return
  end
  self:BindWeaponChangeDelegate()
end
function ShootingUIPanelIMP:On3DTouchForceChange()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    self:Do3DTouch(PlayerController)
  end
end
function ShootingUIPanelIMP:OnDoubleClickCheck(FingerIndex)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and not PlayerCharacter.bIsGunADS then
    self:OnPressFireBtn(FingerIndex, 0, ETouchFireType.DoubleClickFire, false)
  end
end
function ShootingUIPanelIMP:StateEnterHandler(State)
  if State == EPawnState.DriveVehicle or State == EPawnState.InVehicle or State == EPawnState.Swim then
    print(bWriteLog and "ShootingUIPanelUIBase:StateEnterHandler ResetCancelFireBtn")
    self:ResetCancelFireBtn()
  end
end
function ShootingUIPanelIMP:SetSettingControlUI()
  print(bWriteLog and "ShootingUIPanelUIBase:SetSettingControlUI")
  self:AddSettingOptionEvent("LeftHandFire", function(LeftHandFire)
    print(bWriteLog and "ShootingUIPanelUIBase:SetSettingControlUI On LeftHandFire Change, LeftHandFire = " .. LeftHandFire)
    self:LeftHandFireEvent(LeftHandFire)
  end, true)
end
function ShootingUIPanelIMP:LeftHandFireEvent(LeftHandFire)
  if bWriteLog then
    print(bWriteLog and "ShootingUIPanelUIBase:RefreshLeftHandFire LeftHandFire = ", LeftHandFire)
  end
  self.Settings_  if self.IsEmulator then
    self.Settings_LeftHandFire = 1
  end
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  if self.Settings_LeftHandFire == 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideLeftHandFire, true)
  elseif self.Settings_LeftHandFire == 1 then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideLeftHandFire, false)
  elseif self.Settings_LeftHandFire == 2 then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideLeftHandFire, true)
  end
end
function ShootingUIPanelIMP:CameraModeChange(CameraMode)
  if self.Settings_LeftHandFire ~= 2 then
    return
  end
  if CameraMode == EPlayerCameraMode.PCM_None then
    return
  end
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  if CameraMode == EPlayerCameraMode.PCM_Aim or CameraMode == EPlayerCameraMode.PCM_Near then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideLeftHandFire, false)
  else
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bHideLeftHandFire, true)
  end
end
function ShootingUIPanelIMP:HandleUIWhenPlayerLand()
  local EWeaponChangeInvenroryDataType = import("EWeaponChangeInvenroryDataType")
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon1, EWeaponChangeInvenroryDataType.EWCIDT_Init)
  self:HandleChangeInventoryData(ESurviveWeaponPropSlot.SWPS_MainShootWeapon2, EWeaponChangeInvenroryDataType.EWCIDT_Init)
end
function ShootingUIPanelIMP:OnAddCustomWeaponUIWrapper(_, _, CustomUI)
  self:OnAddCustomWeaponUI(CustomUI)
end
function ShootingUIPanelIMP:OnAddCustomWeaponUI(CustomUI)
  print(bWriteLog and "ShootingUIPanelUIBase:OnAddCustomWeaponUI")
  if not slua.isValid(CustomUI) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnAddCustomWeaponUI not CustomUI")
    return
  end
  local CanvasSlot = self.UIRoot.CanvasPanel_CustomWeaponUI:AddChildToCanvas(CustomUI)
  CanvasSlot:SetZOrder(-1)
  CanvasSlot:SetAnchors(FAnchors(0, 0, 1, 1))
  CanvasSlot:SetOffsets(FMargin(0, 0, 0, 0))
end
function ShootingUIPanelIMP:OnWeaponDurabilityChangedWrapper(_, _, WeaponSlot)
  self:OnWeaponDurabilityChanged(WeaponSlot)
end
function ShootingUIPanelIMP:HandleUIWhenPlayerOnPlane()
  self:ResetUIOnPlane()
end
function ShootingUIPanelIMP:OnWeaponDurabilityChanged(WeaponSlot)
  print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponDurabilityChanged")
  local USTExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  if not USTExtraModLogicSwitchLibrary.IsEnableWeaponDurability() then
    print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponDurabilityChanged not USTExtraModLogicSwitchLibrary.IsEnableWeaponDurability")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponDurabilityChanged not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponDurabilityChanged not WeaponManager")
    return
  end
  self.  local ASTExtraShootWeapon = import("STExtraShootWeapon")
  local ShootWeapon = WeaponManager:GetInventoryWeaponByPropSlot(WeaponSlot)
  if slua.isValid(ShootWeapon) and Game:IsClassOf(ShootWeapon, ASTExtraShootWeapon) then
    if WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      self.FirWeaponSlot:UpdateWeaponDurability(ShootWeapon)
    elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      self.SecWeaponSlot:UpdateWeaponDurability(ShootWeapon)
    elseif WeaponSlot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
      self.PistolModeUI:UpdateWeaponDurability(ShootWeapon)
    end
  end
end
function ShootingUIPanelIMP:InitLocalize()
  print(bWriteLog and "ShootingUIPanelUIBase:InitLocalize")
  self.UIRoot.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(4596))
  self.UIRoot.TextBlock_10:SetText(LocUtil.GetLocalizeResStr(4596))
end
function ShootingUIPanelIMP:AdaptFBTipsWithIPX()
  print(bWriteLog and "ShootingUIPanelUIBase:AdaptFBTipsWithIPX")
  self:SetWeaponPanelOffset(FVector2D(0, -20))
end
function ShootingUIPanelIMP:SetWeaponPanelOffset(Offset)
  print(bWriteLog and "ShootingUIPanelUIBase:SetWeaponPanelOffset")
  self.UIRoot.MultiLayer_Pistol:SetRenderTranslation(Offset)
  self.UIRoot.MultiLayer_LeftWeaponSlot:SetRenderTranslation(Offset)
  self.UIRoot.MultiLayer_RightWeaponSlot:SetRenderTranslation(Offset)
end
function ShootingUIPanelIMP:Print(...)
  print(bWriteLog and (...))
end
function ShootingUIPanelIMP:ShowTips(TipsID)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowTips TipsID=" .. tostring(TipsID))
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:ShowTips Fail not slua.isValid(uPlayerController)")
  end
  PlayerController:DisplayGameTipWithMsgID(TipsID)
end
function ShootingUIPanelIMP:HandleCurWeaponFireModeChange()
  print(bWriteLog and "ShootingUIPanelUIBase:HandleCurWeaponFireModeChange")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleCurWeaponFireModeChange not slua.isValid(PlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleCurWeaponFireModeChange not slua.isValid(self.WeaponManager)")
    return
  end
  self.  local CurWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 == CurWeaponSlot then
    if slua.isValid(self.CurUsingShootWeapon) then
      self.FirWeaponSlot:ShowHideFireMode(true, self.CurUsingShootWeapon)
      self.FirWeaponSlot:UpdateFireModeShape(true)
    end
    self.FirWeaponSlot:SetFireModeText()
  elseif ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 == CurWeaponSlot then
    if slua.isValid(self.CurUsingShootWeapon) then
      self.SecWeaponSlot:ShowHideFireMode(true, self.CurUsingShootWeapon)
      self.SecWeaponSlot:UpdateFireModeShape(true)
    end
    self.SecWeaponSlot:SetFireModeText()
  elseif ESurviveWeaponPropSlot.SWPS_SubShootWeapon == CurWeaponSlot then
    self.PistolModeUI:ShowOrHideFireMode(true)
  end
end
function ShootingUIPanelIMP:HandleWeaponChange(Slot)
  print(bWriteLog and "ShootingUIPanelUIBase:HandleWeaponChange Slot=" .. tostring(Slot))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleWeaponChange not slua.isValid(uPlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:HandleWeaponChange not uWeaponManager")
    return
  end
  self.  self.PistolModeUI:UpdatePistol()
  local RefreshUI = function(HandStatus, MainWeaponAlpha1, MainWeaponAlpha2, PistolSlotAlpha, bShowSwitchThrow, bShowShootRed, bSameAsShootAim)
    self:ChangeFireBtnByWeaponPlotSlot(HandStatus)
    self.FirWeaponSlot:SetBorderOpacity(MainWeaponAlpha2)
    self.SecWeaponSlot:SetBorderOpacity(MainWeaponAlpha1)
    self.PistolModeUI:SetBorderOpacity(PistolSlotAlpha)
    if bShowShootRed then
      self.UIRoot.CustomShootRed:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.CustomShootRed:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local RefreshBulletCountEvent = function(bSubWeapon, bVehicleWeapon)
    local CurUsingShootWeapon = self.CurUsingShootWeapon
    if slua.isValid(CurUsingShootWeapon) then
      self:RemoveControlEventByControl(CurUsingShootWeapon, "OnWeaponShootDelegate")
      self:RemoveControlEventByControl(CurUsingShootWeapon, "OnCurBulletChange")
      self:RemoveControlEventByControl(CurUsingShootWeapon, "OnCurBarrelBulletChangeDelegate")
    end
    local ShootWeapon = WeaponManager:GetInventoryWeaponByPropSlot(Slot)
    if not bVehicleWeapon then
      self.CurUsing    end
    CurUsingShootWeapon = self.CurUsingShootWeapon
    if slua.isValid(CurUsingShootWeapon) then
      self:AddControlEventByControl(CurUsingShootWeapon, "OnWeaponShootDelegate", self.UpdateWeaponBulletOnShoot, self)
      self:AddControlEventByControl(CurUsingShootWeapon, "OnCurBulletChange", self.UpdateWeaponBulletCount, self)
      if not bSubWeapon then
        self:AddControlEventByControl(CurUsingShootWeapon, "OnCurBarrelBulletChangeDelegate", self.UpdateWeaponBulletCount, self)
      else
        self:AddControlEventByControl(CurUsingShootWeapon, "OnCurBarrelBulletChangeDelegate", self.UpdateWeaponBulletOnShoot, self)
      end
    end
  end
  local RefreshMeleeOrHandProp = function(bMelee)
    local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
    if slua.isValid(CurWeapon) then
      local CurGrenadeDefineID = CurWeapon:GetItemDefineID()
      self.CurGrenadeID = CurGrenadeDefineID.TypeSpecificID
      self:OnUseGrenadeChangeUI(self.CurGrenadeID)
    end
  end
  local RefreshFireMode = function(bMainWeapon1, bMainWeapon2, bSubWeapon, BareHandUIType)
    if bMainWeapon1 then
      self.FirWeaponSlot:ShowHideFireMode(true, self.CurUsingShootWeapon)
      self.FirWeaponSlot:UpdateFireModeShape(true)
      self.FirWeaponSlot:SelectedUnSelected(true)
    else
      self.FirWeaponSlot:ShowHideFireMode(false, nil)
      self.FirWeaponSlot:SelectedUnSelected(false)
    end
    if bMainWeapon2 then
      self.SecWeaponSlot:ShowHideFireMode(true, self.CurUsingShootWeapon)
      self.SecWeaponSlot:UpdateFireModeShape(true)
      self.SecWeaponSlot:SelectedUnSelected(true)
    else
      self.SecWeaponSlot:ShowHideFireMode(false, nil)
      self.SecWeaponSlot:SelectedUnSelected(false)
    end
    self.PistolModeUI:ShowOrHideFireMode(bSubWeapon)
    if BareHandUIType == 1 then
      self:ShowOrHideBareHandUI(false)
    elseif BareHandUIType == 2 then
      self:ShowOrHideBareHandUI(true)
    end
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if Slot == ESurviveWeaponPropSlot.SWPS_None then
    RefreshUI(ECurPlayerHandStatus.Fist or 0, 0.5, 0.5, 0.5, false, false, true)
    RefreshFireMode(false, false, false, 1)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
    RefreshUI(ECurPlayerHandStatus.Gun, 0.5, 1.0, 0.5, false, true, true)
    RefreshBulletCountEvent(false)
    RefreshFireMode(true, false, false, 2)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
    RefreshUI(ECurPlayerHandStatus.Gun, 1.0, 0.5, 0.5, false, true, true)
    RefreshBulletCountEvent(false)
    RefreshFireMode(false, true, false, 2)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
    RefreshUI(ECurPlayerHandStatus.Gun, 0.5, 0.5, 1.0, false, true, true)
    self.PistolModeUI.UIRoot.Weapon_select:SetOpacity(1)
    RefreshBulletCountEvent(true)
    RefreshFireMode(false, false, true, 0)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_MeleeWeapon then
    RefreshFireMode(false, false, false, 1)
    RefreshUI(ECurPlayerHandStatus.Melee, 0.5, 0.5, 0.5, false, false, true)
    RefreshMeleeOrHandProp(true)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_HandProp then
    RefreshFireMode(false, false, false, 1)
    RefreshUI(ECurPlayerHandStatus.Greanade, 0.5, 0.5, 0.5, true, false, true)
    RefreshMeleeOrHandProp(false)
  elseif Slot == ESurviveWeaponPropSlot.SWPS_VehicleWeapon then
    RefreshUI(ECurPlayerHandStatus.Gun, 0.5, 1.0, 0.5, false, true, false)
    if slua.isValid(CurWeapon) and CurWeapon.GetShootWeaponEntityComponent then
      self.CurUsingShootWeapon = CurWeapon
      RefreshBulletCountEvent(false, true)
      RefreshFireMode(true, false, false, 2)
    end
  end
  self.FirWeaponSlot:UpdateShield()
  self.SecWeaponSlot:UpdateShield()
  self:UIMsg_UpdateWeaponFuntion()
  self:NextUseWeaponChangedDelegate_Handle()
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTTYPE_PLAYEREVENT_WEAPONSTATE_CHANGE)
end
function ShootingUIPanelIMP:Reconnect_ResetUIByPlayerControllerState()
  print(bWriteLog and "ShootingUIPanelUIBase:Reconnect_ResetUIByPlayerControllerState")
  self:BindWeaponChangeDelegate()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and (PlayerController:IsInPlane() or PlayerController:IsInParachute()) then
    self:ResetUIOnPlane()
  end
end
function ShootingUIPanelIMP:UIMsg_UpdateWeaponFuntion()
  print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponFuntion")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if not OperateSubsystem then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelUIBase:UpdateWeaponFuntion Fail not slua.isValid(uPlayerController)")
    return
  end
  local CurrentWeaponFunction = PlayerController.CurrentWeaponFunction
  if CurrentWeaponFunction == EWeaponOperationMode.None or CurrentWeaponFunction == EWeaponOperationMode.Shoot or CurrentWeaponFunction == EWeaponOperationMode.Skill then
  elseif PlayerController.CurrentWeaponFunction == EWeaponOperationMode.Throw then
    self:OnUseGrenadeChangeUI(0)
  end
  self:VehicleShootingCheckShootingState()
end
function ShootingUIPanelIMP:VehicleShootingCheckShootingState()
  print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState")
  local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bEnterVehicleShooting, false)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState Fail not slua.isValid(uPlayerController)")
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState not slua.isValid(uPlayerCharacter)")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState not slua.isValid(WeaponManager)")
    return
  end
  local CurWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if ESurviveWeaponPropSlot.SWPS_TempSpecialWeapon == CurWeaponSlot or ESurviveWeaponPropSlot.SWPS_ShiftGrenadeWeapon == CurWeaponSlot then
    return
  end
  if not PlayerCharacter:HasState(EPawnState.AttachToOther) and not self:IsPassenger() then
    return
  end
  if ESurviveWeaponPropSlot.SWPS_None == CurWeaponSlot then
    print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState---1---" .. tostring(CurWeaponSlot))
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bEnterVehicleShooting, true)
  elseif ESurviveWeaponPropSlot.SWPS_MeleeWeapon == CurWeaponSlot then
    local VehicleUserComponent = PlayerController:GetVehicleUserComp()
    if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Character) and slua.isValid(VehicleUserComponent.Vehicle) and PlayerController.CurrentWeaponFunction ~= EWeaponOperationMode.Throw then
      print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState---2---" .. tostring(VehicleUserComponent.VehicleUserState))
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bEnterVehicleShooting, true)
    end
    if PlayerCharacter:HasState(EPawnState.AttachToOther) and PlayerController.CurrentWeaponFunction ~= EWeaponOperationMode.Throw then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bEnterVehicleShooting, true)
    end
  else
    local ShootWeapon = PlayerCharacter:GetCurrentShootWeapon()
    if slua.isValid(ShootWeapon) and not ShootWeapon:CanVehicleShoot() then
      print(bWriteLog and "ShootingUIPanelIMP:VehicleShootingCheckShootingState---3---" .. tostring(CurWeaponSlot))
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bEnterVehicleShooting, true)
    end
  end
end
function ShootingUIPanelIMP:ResetUIOnPlane()
  print(bWriteLog and "ShootingUIPanelUIBase:ResetUIOnPlane")
  self.FirWeaponSlot:ClearWeaponSlotData()
  self.SecWeaponSlot:ClearWeaponSlotData()
  self.UIRoot.CustomShootRed:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:ChangeFireStatusAndUpdateFireBtn(ECurPlayerHandStatus.Fist)
  self.SecWeaponSlot:SetBorderOpacity(0.5)
  self.FirWeaponSlot:SetBorderOpacity(0.5)
end
function ShootingUIPanelIMP:ShowUIByOperation(Operation)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowUIByOperation Operation=" .. tostring(Operation))
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_SHOOTINGUI_OPERATION_CHANGE, Operation)
  if Operation == UEnums.UIOperation.Parachute then
  elseif Operation == UEnums.UIOperation.Shoot then
    self:ShowOrHideAllNewbieGuide(true)
  elseif Operation == UEnums.UIOperation.Drive then
    self:ShowOrHideAllNewbieGuide(false)
  elseif Operation == UEnums.UIOperation.DriveAsPassenger then
    self:ShowOrHideAllNewbieGuide(true)
  end
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if DataLayerSubsystem then
    DataLayerSubsystem:UpdateSuperDataValue("UIOperation", Operation)
  end
end
function ShootingUIPanelIMP:ShowWeaponEquipAttachmentAnim(Slot, DefineID, bIsEquip)
  print(bWriteLog and "ShootingUIPanelUIBase:ShowWeaponEquipAttachmentAnim")
  local Config = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
  if Config and Config.ItemSubType ~= 418 then
    if Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 then
      self.FirWeaponSlot:AddAttachmentAnimationToQuere(DefineID)
    elseif Slot == ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 then
      self.SecWeaponSlot:AddAttachmentAnimationToQuere(DefineID)
    elseif Slot == ESurviveWeaponPropSlot.SWPS_SubShootWeapon then
      self.PistolModeUI:AddAttachmentAnimationToQuere(DefineID)
    end
  end
  self:ResetCancelFireBtn()
end
function ShootingUIPanelIMP:Do3DTouch(PlayerController)
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "ShootingUIPanelUIBase:Do3DTouch")
  if self.FingerIndex3DTouch == ETouchIndex.Touch10 then
    local MaxTouchIndex = PlayerController:GetMaxTouchForceFinger()
    local MaxTouchForce = PlayerController.TouchForceMap:Get(MaxTouchIndex)
    if MaxTouchIndex == nil or MaxTouchForce == nil or PlayerController.TouchForceFireThreshold == nil then
      return
    end
    if MaxTouchForce >= PlayerController.TouchForceFireThreshold and self.FingerIndex3DTouch ~= MaxTouchIndex then
      local PlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(PlayerCharacter) then
        if not PlayerCharacter:IsUsingGrenade() then
          self:OnPressFireBtn(MaxTouchIndex, MaxTouchForce, ETouchFireType.TouchForceFire, true)
        else
          self:GrenadePrepareToThrow(ETouchIndex.Touch1)
        end
      end
      self.FingerIndex3DTouch = MaxTouchIndex
      PlayerController.TouchIndexSet:Add(MaxTouchIndex)
    end
  else
    local MaxTouchIndex = self.FingerIndex3DTouch
    local MaxTouchForce = PlayerController.TouchForceMap:Get(MaxTouchIndex)
    if MaxTouchForce == nil then
      return
    end
    if not (MaxTouchForce >= PlayerController.TouchForceFireThreshold) then
      self.FingerIndex3DTouch = ETouchIndex.Touch10
      local PlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(PlayerCharacter) and PlayerCharacter:IsUsingGrenade() then
        self:GrenadeThrow()
      end
    end
  end
end
function ShootingUIPanelIMP:OnWeaponShootIntervalModeChange(_)
  print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponShootIntervalModeChange")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponShootIntervalModeChange not uPlayerCharacter")
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    print(bWriteLog and "ShootingUIPanelUIBase:OnWeaponShootIntervalModeChange not WeaponManager")
    return
  end
  self.  local CurWeaponSlot = WeaponManager:GetCurrentUsingPropSlot()
  if ESurviveWeaponPropSlot.SWPS_MainShootWeapon1 == CurWeaponSlot then
    self.FirWeaponSlot:SetFireModeText()
  elseif ESurviveWeaponPropSlot.SWPS_MainShootWeapon2 == CurWeaponSlot then
    self.SecWeaponSlot:SetFireModeText()
  end
end
function ShootingUIPanelIMP:UIMsg_FadeIn()
  print(bWriteLog and "ShootingUIPanelIMP:UIMsg_FadeIn")
  self.UIRoot.Fade:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self.UIRoot.Fade:PlayUserWidgetAnimation(self.UIRoot.Fade.Fade_anima, 0, 1, 0, 1)
end
function ShootingUIPanelIMP:UIMsg_StopFade()
  print(bWriteLog and "ShootingUIPanelIMP:UIMsg_StopFade")
  self.UIRoot.Fade:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Fade:PlayUserWidgetAnimation(self.UIRoot.Fade.StopFade, 0, 1, 0, 1)
end
function ShootingUIPanelIMP:ShowShootingControlPanel()
  self.UIRoot.InvalidationBox_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ShootingUIPanelIMP:HideShootingControlPanel()
  self.UIRoot.InvalidationBox_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ShootingUIPanelIMP:DealSwimForce(UpOffset, PlayerCharacter)
  print(bWriteLog and "ShootingUIPanelUIBase:DealSwimForce")
  local Unswing = true
  if PlayerCharacter and PlayerCharacter.GetPlayerAnimParam then
    local AnimParamList = PlayerCharacter:GetPlayerAnimParam(0.01)
    local EMovementMode = import("EMovementMode")
    if AnimParamList.MovementMode == EMovementMode.MOVE_Swimming then
      Unswing = false
      local OffSet = FVector(0, 0, UpOffset * 100)
      PlayerCharacter.CharacterMovement:AddImpulse(OffSet, true)
    end
  end
  return Unswing
end
function ShootingUIPanelIMP:OnDestruct()
  print(bWriteLog and "ShootingUIPanelIMP:OnDestruct")
end
function ShootingUIPanelIMP:OnClose()
  print(bWriteLog and "ShootingUIPanelIMP:OnClose")
  self.bHaveRegistEvents = false
  if self.FirWeaponSlot and self.FirWeaponSlot.UIRoot then
    self.FirWeaponSlot.UIRoot:RemoveFromParent()
  end
  if self.SecWeaponSlot and self.SecWeaponSlot.UIRoot then
    self.SecWeaponSlot.UIRoot:RemoveFromParent()
  end
  if self.PistolModeUI and self.PistolModeUI.UIRoot then
    self.PistolModeUI.UIRoot:RemoveFromParent()
  end
  self.FirWeaponSlot = nil
  self.SecWeaponSlot = nil
  self.PistolModeUI = nil
  self:Close_Fire()
  self:Close_Grenada()
  self:Close_WeaponSlot()
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_Root)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_BtnGroup)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.SkillLayer)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_CustomWeaponUI)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_Pistol)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeftWeaponSlot)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_RightWeaponSlot)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ChatCanvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_ConsumableCanvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_GrenadeCanvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_PMode)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_LeftFireCanvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.MultiLayer_RightFireCanvas)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.ShoulderBtnPanel)
  HandleStateCanvasUtils.UnRegisterCanvasVisibleEvent(self.UIRoot.CanvasPanel_AICommand)
  self.WeaponManager = nil
  self.NewbieTips_ConsumeTips = nil
  self.NewbieTips_SearchBuild = nil
  self.NewbieTips_JumpingMoveCam = nil
  self.NewbieTips_Joystick = nil
  self.NewbieTips_GrenadeList = nil
  self.NewbieTips_LeftFire = nil
  self.NewbieTips_RightFire = nil
  self.NewbieTips_Reload = nil
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, ShootingUIPanelIMP)
local PlayerControllerBase = {
  ClientRPC = {},
  ServerRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {
    "DefaultLuaEventPlaceholder"
  }
}
PlayerControllerBase.ClientRPC.RPC_Client_MaliciousTeammateReceiveWarningTips = {Reliable = true}
PlayerControllerBase.ClientRPC.RPC_Client_MaliciousTeammateVictimReceiveTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Int
  }
}
PlayerControllerBase.ClientRPC.RPC_Client_PopupAFKWindow = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
PlayerControllerBase.ServerRPC.RPC_Server_PlaySpecifiedPetAnimation = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
PlayerControllerBase.ServerRPC.RPC_Server_SetGameReadyCountDown = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerControllerBase.ServerRPC.RPC_Server_SetAutoUseMelee = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
PlayerControllerBase.ClientRPC.RPC_ClientHUDDisplayHitDamage = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
PlayerControllerBase.MulticastRPC.RPC_Multicast_OnCreateDecal = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
local CDamageEvent = import("/Script/Engine.DamageEvent")
local PlaneCls = import("/Script/ShadowTrackerExtra.PlaneCharacter")
local InputStateControl
function PlayerControllerBase:ctor(selfType)
  self.LastestViewPlayerKey = 0
  self.bEnterpriseGMMod = false
  self.bAvatarErrReport = false
  self._bIsTeammateExitTeamBeforeBoarding = false
  self.ZiplineUI = nil
  self._SuperData = nil
  self.IsPreparingEnterZipline = false
  self.CanModPlayActorVoiceFeature = true
  self.nInLeftSharedSkinTimes = 0
  self.nOutLeftSharedSkinTimes = 0
  self.nFriendLeftSharedSkinTimes = -1
  self.bPCInputSwitcher = true
  self.bIsShowingFollowEmoteUI = false
  self.bIsShowingMovableEmoteUI = false
  self.PetAnimationTimer = nil
  self.bForbidCustomChat = false
  self.bHasBeginPlay = false
  local SuperData = self:GetSuperData()
  SuperData.IsUse3DTouch = false
  SuperData.bTurnOnDrift = true
  self.bIsJoyStickShow = false
  self.bModWeaponSkinCooldowning = false
  self.SettingHandleList = {}
end
function PlayerControllerBase:_PostConstruct()
  PlayerControllerBase.__super._PostConstruct(self)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.BindPlayerController(self.Object)
  local UIMessageSystem = require("GameLua.GameCore.Main.UIMessageSystem")
  UIMessageSystem.BindPlayerController(self.Object)
  if Client then
    self.bWatchTeammateIgnoreDying = true
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, function()
      self.bHasEnterBattleResult = true
    end, self)
    self:AddControlEvent(self, "OnAvatarInfoRep", self.ReportAvatarFlow, self)
    self:AddControlEvent(self, "OnPlayerControllerBattleBeginPlay", self.HandleBattleBeginPlay, self)
  end
end
function PlayerControllerBase:OnDestroyed()
  self:Dispose()
  PlayerControllerBase.__super.OnDestroyed(self)
end
function PlayerControllerBase:HandleBattleBeginPlay()
  self.bHasBeginPlay = true
end
function PlayerControllerBase:CheckBattleHasBeginPlay()
  return self.bHasBeginPlay
end
function PlayerControllerBase:ReportAvatarFlow(ItemIDList, sObjectName, sAvatarType)
  if not Client then
    return
  end
  if self == nil or not slua.isValid(self.Object) then
    return
  end
  local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
  print(bWriteLog and "[YY-D] PlayerControllerBase:ReportAvatarFlow sObjectName = " .. sObjectName)
  print(bWriteLog and "[YY-D] PlayerControllerBase:ReportAvatarFlow sAvatarType = " .. sAvatarType)
  if slua.isValid(ItemIDList) and RecommendHandler then
    for _, ItemID in pairs(ItemIDList) do
      print(bWriteLog and "[YY-D] PlayerControllerBase:ReportAvatarFlow ItemID = " .. tostring(ItemID))
      RecommendHandler.AddBattleItem(ItemID)
    end
  end
end
function PlayerControllerBase:OnLuaRep_Pawn()
  print(bWriteLog and "PlayerControllerBase:OnLuaRep_Pawn", self.Pawn)
  local UCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  if slua.isValid(self.Pawn) and Game:IsClassOf(self.Pawn, UCharacterClass) then
    GameplayData.BindPlayerCharacter(self.Pawn, true)
  else
  end
end
function PlayerControllerBase:OnLuaRep_PlayerState()
  print(bWriteLog and "PlayerControllerBase:OnLuaRep_PlayerState", self.PlayerState)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local UPlayerStateClass = import("/Script/Gameplay.UAEPlayerState")
  if slua.isValid(self.PlayerState) then
    if Game:IsClassOf(self.PlayerState, UPlayerStateClass) then
      GameplayData.BindPlayerState(self.PlayerState, true)
    end
  else
    GameplayData.BindPlayerState(nil, true)
  end
end
function PlayerControllerBase:OnLuaRep_STExtraBaseCharacter()
  print(bWriteLog and "PlayerControllerBase:OnLuaRep_STExtraBaseCharacter", self.STExtraBaseCharacter)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.BindPlayerCharacter(self.STExtraBaseCharacter, true)
  if not Client then
    return
  end
  if self.RescureTimer then
    self:RemoveGameTimer(self.RescureTimer)
    self.RescureTimer = nil
  end
  if not slua.isValid(self.STExtraBaseCharacter) then
    return
  end
  local uSearchOtherComp = self.STExtraBaseCharacter.SearchOtherComponent
  if not slua.isValid(uSearchOtherComp) then
    self.RescureTimer = self:AddGameTimer(1, true, function()
      local uSearchOtherComp = self.STExtraBaseCharacter.SearchOtherComponent
      if slua.isValid(uSearchOtherComp) then
        print(bWriteLog and "PlayerControllerBase:OnLuaRep_STExtraBaseCharacter Has Created")
        self:RemoveGameTimer(self.RescureTimer)
        self.RescureTimer = nil
        return
      end
      local uRescueComp = self.STExtraBaseCharacter.RescueOtherComponent
      local uNearDeathComp = self.STExtraBaseCharacter.NearDeatchComponent
      if slua.isValid(uRescueComp) and slua.isValid(uNearDeathComp) then
        print(bWriteLog and "PlayerControllerBase:OnLuaRep_STExtraBaseCharacter InitializeOwner")
        uRescueComp:InitializeOwner(self.STExtraBaseCharacter, uNearDeathComp)
      end
      local uSearchOtherComp = self.STExtraBaseCharacter.SearchOtherComponent
      if slua.isValid(uSearchOtherComp) then
        print(bWriteLog and "PlayerControllerBase:OnLuaRep_STExtraBaseCharacter InitializeOwner Create SearchOtherComp")
        self:RemoveGameTimer(self.RescureTimer)
        self.RescureTimer = nil
      end
    end)
  end
end
function PlayerControllerBase:ReceiveBeginPlay()
  PlayerControllerBase.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerControllerBase:ReceiveBeginPlay", self.PlayerKey)
  if self:IsLocalPlayerController() then
    self:SetAlwaysHideTouchInterface(false)
    self:ShowTouchInterface(true)
    self.IsShowInputControl = true
    self:CastUIMsg("UIMsg_Show/HideSelf", "ingame")
    self.bCanGetTouchInput = true
    local SurviveHUD = self:GetHUD()
    if slua.isValid(SurviveHUD) then
      SurviveHUD.bShowCrosshair = true
    end
  end
  if Client then
    self.bDeviceSupportGyrSensor = Client.IsDeviceSupportGyrSensor()
    self:BindMotionEvent()
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local SettingHandle
      self.fireMode = SettingSubsystem:GetUserSettings_Int("FireMode")
      SettingHandle = SettingSubsystem:RegisterUserSettingsDelegate_Int("FireMode", function(FireMode)
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.CharacterControlMode, 2, string.format("ControlMode=%d", FireMode))
        self.fireMode = FireMode
        self:MakeFireModeEffect()
      end)
      table.insert(self.SettingHandleList, SettingHandle)
      self:MakeFireModeEffect()
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.CharacterControlMode, 1, string.format("ControlMode=%d", self.fireMode))
      self.WallFeedBack = SettingSubsystem:GetUserSettings_Bool("WallFeedBack")
      SettingSubsystem:RegisterUserSettingsDelegate_Bool("WallFeedBack", function(WallFeedBack)
        self.      end)
      table.insert(self.SettingHandleList, SettingHandle)
      self.bLowAmmoSound = SettingSubsystem:GetUserSettings_Bool("Weapon_LowAmmo")
      SettingHandle = SettingSubsystem:RegisterUserSettingsDelegate_Bool("Weapon_LowAmmo", function(Weapon_LowAmmo)
        self.bLowAmmoSound = Weapon_LowAmmo
      end)
      table.insert(self.SettingHandleList, SettingHandle)
      self.JoystickSprintSensitity = SettingSubsystem:GetUserSettings_Int("JoystickSprintSensitity")
      SettingHandle = SettingSubsystem:RegisterUserSettingsDelegate_Int("JoystickSprintSensitity", function(Value)
        self.JoystickSprintSensitity = Value
      end)
      table.insert(self.SettingHandleList, SettingHandle)
      SettingHandle = SettingSubsystem:RegisterUserSettingsDelegate_Int("DriftMode", function()
        self:OnDriftModeChanged()
      end)
      table.insert(self.SettingHandleList, SettingHandle)
    end
    self:AddGameTimer(0.1, false, function()
      if slua.isValid(self.Object) then
        local LogicCustomSensitivity = require("client.logic.setting.logic_setting_custom_sensitivity")
        LogicCustomSensitivity.Read()
        local LogicCustomAccessories = require("client.logic.setting.logic_setting_custom_accessiores")
        LogicCustomAccessories.Read()
        LogicCustomAccessories.SetPlayer()
      end
    end)
    self:ReadCustomDrawHairType()
    self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_CROSSHAIR, self.ReadCustomDrawHairType, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_CLICKED, self.UseModSkin, self)
  end
  self:LuaReceiveBeginPlay()
  if not self:HasAuthority() then
    self.bWatchTeammateIgnoreDying = true
    local UGameplayStatics = import("GameplayStatics")
    local uGameInstance = UGameplayStatics.GetGameInstance(self)
    if slua.isValid(uGameInstance) then
      self:AddControlEvent(uGameInstance, "OnPreBattleResult", self.OnPreBattleResult, self)
    end
    self:AddControlEvent(self, "OnPlayerEnterFighting", self.HandlePlayerEnterFighting, self)
    self:AddControlEvent(self, "OnPlayerKilledOthersPlayer", self.HandleOnPlayerKilledOthersPlayer, self)
    self:AddControlEvent(self, "OnPlayerControllerStateChangedDelegate", self.HandlePlayerControllerStateChanged, self)
    self:AddControlEvent(self, "OnPlayerEnterFlying", self.OnPlayerEnterFlyingInLua, self)
    log(bWriteLog and "  PlayerControllerBase:ReceiveBeginPlay.  OnShowFollowEmoteDelegate")
    self:AddControlEvent(self, "OnShowFollowEmoteDelegate", self.HandleShowFollowEmoteUI, self)
    self:AddControlEvent(self, "OnTouchInterfaceChangedDelegate", self.HandleTouchInterfaceChanged, self)
    self:RegistSetting()
    self:HandleTouchInterfaceChanged()
    if IsEditor then
      self.bPCInputSwitcher = true
    end
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local bDisableTouchOverEvent = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("pc.DisableTouchOverEvent")
    if bDisableTouchOverEvent == 1 then
      self.bEnableTouchOverEvents = false
      self.bEnableTouchEvents = false
      print(bWriteLog and "PlayerControllerBase:ReceiveBeginPlay, bDisableTouchOverEvent!!")
    end
  else
    self:AddControlEvent(self, "OnPlayerExitGameDelegate", self.HandlePlayerExitGame, self)
    local QuickSignComp = self:GetQuickSignComponent()
    if QuickSignComp and slua.isValid(QuickSignComp) then
      self:AddControlEvent(QuickSignComp, "OnDangerousQuickSignDelegate", self.OnDangerousQuickSignDelegate, self)
    else
      print(bWriteLog and "PlayerControllerBase:ReceiveBeginPlay, QuickSignComp = nil")
    end
    self:CheckCanCustomChat()
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_CHECK_CAN_CUSTOM_CHAT, self.CheckCanCustomChat, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CREATE_NEW_DECAL, self.OnCreateDecal, self)
    self:AddControlEvent(self, "OnSetObserveCharacter", self.HandleServerSpectatorChange, self)
    self:AddControlEvent(self, "OnPlayerRotationChanged", self.HandleOnPlayerRotationChanged, self)
    self:AddControlEvent(self, "OnPlayerCameraChanged", self.HandleOnPlayerCameraChanged, self)
  end
  self:AddControlEvent(self, "OnSpectatorChange", self.HandleSpectatorChange, self)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bStandalone = UKismetSystemLibrary.IsStandalone(self)
  if self.bPCInputSwitcher and (bStandalone or not self:HasAuthority()) and not self:IsSpectator() and not self:IsObserver() then
    InputStateControl = require("GameLua.GameCore.Module.Input.InputStateControl")
    InputStateControl.Init()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY_FINISH)
  self.bUseNewMotionInput = true
  if Client then
    self:InitCameraData()
    self:OnDriftModeChanged()
    self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, self.OnDriftModeChanged, self)
  end
  self.bUseOldMethodForJoystickTriggerSprint = false
end
function PlayerControllerBase:CanChangeStatePC(StateType)
  local CurrentState = self:GetCurrentStateType()
  print(bWriteLog and "PlayerControllerBase:CanChangeStatePC CurrentState: " .. tostring(CurrentState) .. " TargetState: " .. tostring(StateType))
  if CurrentState ~= StateType or self:IsSpectator() then
    return true
  end
  return false
end
function PlayerControllerBase:OnDriftModeChanged()
  local SuperData = self:GetSuperData()
  if not SuperData then
    return
  end
  local Settingconfig = slua_GameFrontendHUD:GetUserSettings()
  SuperData.bTurnOnDrift = Settingconfig.DriftMode > 0
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if SuperData.bTurnOnDrift then
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "Drift.Enable 1")
  else
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "Drift.Enable 0")
  end
end
function PlayerControllerBase:OldJoystickTriggerSprint(bIsSprint)
  self.IsJoystickTriggerSprint = bIsSprint
  self:BroadcastUIMessage("UIMsg_JoyStickTriggerSprint", 0, "", "")
end
function PlayerControllerBase:ReadCustomDrawHairType()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    self.CustomCrossHairStype = SettingSubsystem:GetUserSettings_Int("CrossHairType")
    print(bWriteLog and string.format("PlayerControllerBase:ReadCustomDrawHairType %s", tostring(self.CustomCrossHairStype)))
  end
end
function PlayerControllerBase:HandleChangeRolewearDone()
  if not Client then
    local uCurPawn = self:GetCurPawn()
    if uCurPawn then
      if uCurPawn.RefreshFollowState then
        uCurPawn:RefreshFollowState()
      end
      if slua.isValid(uCurPawn) and uCurPawn.IsCastingSkillIDFix and uCurPawn:IsCastingSkillIDFix(1014405) then
        print(bWriteLog and "PlayerControllerBase:HandleChangeRolewearDone Stop GunCheck Skill")
        uCurPawn:StopSkill(1014405)
      end
    end
  end
  log(bWriteLog and "  PlayerControllerBase:HandleChangeRolewearDone.  ")
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_CHANGE_ROLE_WEAR_DONE, self.Object)
end
function PlayerControllerBase:HandleOnPlayerRotationChanged()
  log(bWriteLog and "PlayerControllerBase:HandleOnPlayerRotationChanged, UID = " .. tostring(self.UID))
  local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
  if AFKReportorSubsystem then
    local Rotation = self:GetControlRotation()
    log(bWriteLog and "PlayerControllerBase:HandleOnPlayerRotationChanged, Rotation = ", Rotation:ToString())
    if Rotation.Pitch == 0.0 and Rotation.Yaw == 90.0 and Rotation.Roll == 0.0 or Rotation:IsNearlyZero(0.001) then
      log(bWriteLog and "PlayerControllerBase:HandleOnPlayerRotationChanged, Invalid Rotation From Player, Maybe From Init/Reset/Auto Action of Game System!")
    else
      AFKReportorSubsystem:PlayerHaveAction(self.UID)
    end
  else
    log(bWriteLog and "PlayerControllerBase:HandleOnPlayerRotationChanged, AFKReportorSubsystem = nil")
  end
end
function PlayerControllerBase:HandleOnPlayerCameraChanged()
  print(bWriteLog and "PlayerControllerBase:HandleOnPlayerCameraChanged, UID = " .. tostring(self.UID))
  local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
  if AFKReportorSubsystem then
    AFKReportorSubsystem:PlayerHaveAction(self.UID)
  else
    print(bWriteLog and "CharacterBase:HandleOnPlayerCameraChanged, AFKReportorSubsystem = nil")
  end
end
function PlayerControllerBase:OnPlayerEnterFlyingInLua()
  local ThePlane = self:GetThePlane()
  if ThePlane and slua.isValid(ThePlane) then
    local ViewTarget = self:GetViewTarget()
    if ViewTarget ~= ThePlane then
      self:SetViewTargetTest(ThePlane)
      print(bWriteLog and "PlayerControllerBase:OnPlayerEnterFlyingInLua, SetViewTarget " .. tostring(ThePlane))
    end
  end
  local PlayerCharacter = self:GetPlayerCharacterSafety()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter.MoveableSwitchPoseTime = 0
  end
end
function PlayerControllerBase:OnDangerousQuickSignDelegate(PlayerKey, SignLocation)
  print(bWriteLog and "PlayerControllerBase:OnDangerousQuickSignDelegate, UID = " .. tostring(self.UID))
  local AFKReportorSubsystem = SubsystemMgr:Get("AFKReportorSubsystem")
  if AFKReportorSubsystem then
    AFKReportorSubsystem:PlayerHaveAction(self.UID)
  else
    print(bWriteLog and "CharacterBase:OnDangerousQuickSignDelegate, AFKReportorSubsystem = nil")
  end
end
function PlayerControllerBase:HandlePlayerControllerStateChanged(ClientStateType)
  print(bWriteLog and "PlayerControllerBase:HandlePlayerControllerStateChange", ClientStateType, self.bHasEnterBattleResult)
  if self.bHasEnterBattleResult then
    return
  end
  local EStateType = import("EStateType")
  if ClientStateType == EStateType.State_InExPlane or ClientStateType == EStateType.State_InPlane then
    local LightCrossMgr = SubsystemMgr:Get("MapMarkLightCrossMgr")
    if LightCrossMgr then
      LightCrossMgr:ReviveInit()
    else
      print(bWriteLog and "PlayerControllerBase:HandlePlayerControllerStateChanged, LightCrossMgr = nil")
    end
    if ClientStateType == EStateType.State_InExPlane then
      local ENetRole = import("ENetRole")
      if self.Role == ENetRole.ROLE_AutonomousProxy and not self:IsSpectator() and not self:IsObserver() then
        local uPlayerCharacter = self:GetPlayerCharacterSafety()
        if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
          uPlayerCharacter.MoveableSwitchPoseTime = 0
          print(bWriteLog and "PlayerControllerBase:HandlePlayerControllerStateChanged, Reset MoveableSwitchPoseTime")
        end
      end
    end
    if ClientStateType == EStateType.State_InPlane then
      print(bWriteLog and "PlayerControllerBase:HandlePlayerControllerStateChanged, State_InPlane, force ResetFollowEmoteUI")
      self:HandleShowFollowEmoteUI(false)
    end
  end
end
function PlayerControllerBase:ReceivePostLoginInit()
  print(bWriteLog and "STExtraLuaPlayerControllerBase.ReceivePostLoginInit")
  if not self.bReconnecting then
    local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
    AvatarDataUtil.GeneratePlayerAvatarData(self)
    self:InitWeaponAvatarItems()
    self:OnWeaponAvatarUpdate()
    self:InitGrenadeAvatarList(true)
    self:InitVehicleAvatarList()
    self:InitVehicleAdvanceAvatarList()
    self:InitVehicleMusicIDs()
  end
  if CGame and CGame:IsEditor() then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local SecurtyEditorConfig = GamePlayTools.GetCurrentConfig("SecurtyEditorConfig")
    if SecurtyEditorConfig and SecurtyEditorConfig.GameSafeCallbacks then
      require(SecurtyEditorConfig.GameSafeCallbacks)
      if GameSafeCallbacks then
        print(bWriteLog and "PlayerControllerBase:ReceivePostLoginInit IsEditor OnDSGlueHiaInit")
        GameSafeCallbacks.OnDSGlueHiaInit()
      end
    end
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if UKismetSystemLibrary.IsDedicatedServer(self) and GameSafeCallbacks then
    GameSafeCallbacks.PostPlayerControllerLoginInit(self)
  end
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
    local PlayerInfo = PlayerDataMgr.GetPlayerInfo(self.UID)
    if PlayerInfo then
      self.bEnterpriseGMMod = PlayerInfo.bEnterpriseGMMod or false
      print(bWriteLog and "PlayerControllerBase:bEnterpriseGMMod " .. tostring(self.bEnterpriseGMMod))
      self.bAvatarErrReport = PlayerInfo.avatar_err_report or false
      print(bWriteLog and "PlayerControllerBase:bAvatarErrReport " .. tostring(self.bAvatarErrReport))
      if self.SecurityNotifyPCFeature then
        self.SecurityNotifyPCFeature:SyncBanInfo(PlayerInfo.ban)
      end
    end
    if slua.isValid(self.PlayerState) and self.PlayerState.InitTeamShowData then
      self.PlayerState:InitTeamShowData()
    end
    if slua.isValid(self.PlayerState) and self.PlayerState.ThemeTaskFeature then
      self.PlayerState.ThemeTaskFeature:InitTaskIDIPSwitch()
    end
    if slua.isValid(self.NetworkReportActor) then
      self.NetworkReportActor:ForceNetUpdate()
    end
  end
  self:CacheSyncParams()
  if slua.isValid(self.PlayerState) and self.PlayerState.StoreFeature and self.PlayerState.StoreFeature.ReceivePostLoginInit then
    self.PlayerState.StoreFeature:ReceivePostLoginInit()
  end
end
function PlayerControllerBase:GenerateKillBroadcastItemID(ClothAvatarID, PlayerUID)
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  return XSuitAvatarDataUtil:GenerateKillBroadcastItemID(ClothAvatarID, PlayerUID)
end
function PlayerControllerBase:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerControllerBase.ReceiveEndPlay")
  self.ZiplineUI = nil
  self._SuperData = nil
  if not self:HasAuthority() then
    local VibrateUtilitySubsystem = SubsystemMgr:Get("VibrateUtilitySubsystem")
    if VibrateUtilitySubsystem and VibrateUtilitySubsystem.ResetVibrationData then
      print(bWriteLog and "PlayerControllerBase.ReceiveEndPlay VibrateUtilitySubsystem call ResetVibrationData")
      VibrateUtilitySubsystem:ResetVibrationData()
    end
  end
  if Client then
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      for _, Handle in ipairs(self.SettingHandleList) do
        SettingSubsystem:UnregisterUserSettingDelegate(Handle)
      end
      self.SettingHandleList = nil
    end
  else
    local FatalDamageSubsystem = SubsystemMgr:Get("FatalDamageSubsystem")
    if FatalDamageSubsystem then
      FatalDamageSubsystem:ClearPlayerKillerFlow(self.UID)
    end
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.UnbindPlayerController(self.Object)
  if InputStateControl then
    InputStateControl.Destroy()
    InputStateControl = nil
  end
  self:ShowTouchInterface(false)
  self:ActivateTouchInterface(nil)
  PlayerControllerBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerControllerBase:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bEnterpriseGMMod",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "bAvatarErrReport",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "_bIsTeammateExitTeamBeforeBoarding",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "nInLeftSharedSkinTimes",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "nOutLeftSharedSkinTimes",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "nFriendLeftSharedSkinTimes",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "bForbidCustomChat",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    }
  }
end
function PlayerControllerBase:CacheSyncParams()
  print(bWriteLog and "PlayerControllerBase:CacheSyncParams()")
  local uPlayerState = self.PlayerState
  if Client then
    return
  end
  if not slua.isValid(uPlayerState) then
    return
  end
  if not self.bReconnecting and uPlayerState.InitGeneralCounterFromServer then
    uPlayerState:InitGeneralCounterFromServer()
  else
    print(bWriteLog and "PlayerControllerBase:CacheSyncParams, bReconnecting = " .. tostring(self.bReconnecting))
  end
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local PlayerInfo = PlayerDataMgr.GetPlayerInfo(self.UID)
  if PlayerInfo then
    local Flag = PlayerInfo.suspicious_flag or 0
    if uPlayerState.SetSuspiciousFlag then
      uPlayerState:SetSuspiciousFlag(Flag)
      print(bWriteLog and "PlayerControllerBase:CacheSyncParams ", PlayerInfo.suspicious_flag, self.UID)
    end
  else
    print(bWriteLog and " PlayerControllerBase:CacheSyncParams Invalid Player Info uid=", self.UID)
  end
end
function PlayerControllerBase:OnRep_bEnterpriseGMMod()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ENTERPRISEGMMOD_CHANGE)
end
function PlayerControllerBase:IsEnterpriseGMMod()
  return self.bEnterpriseGMMod
end
function PlayerControllerBase:InitVehicleMusicIDs()
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local PlayerInfo = PlayerDataMgr.GetPlayerInfo(self.UID)
  if not PlayerInfo then
    return
  end
  print(bWriteLog and "STExtraLuaPlayerControllerBase:InitVehicleMusicIDs UID: ", self.UID)
  if PlayerInfo.car_music then
    local VehicleMusicList = {}
    for _, MusicID in pairs(PlayerInfo.car_music) do
      table.insert(VehicleMusicList, {ItemTableID = MusicID, Count = 1})
    end
    self.Initial    self:InitVehicleMusicList()
    log_tree("STExtraLuaPlayerControllerBase:InitVehicleMusicIDs MusicList :", VehicleMusicList)
  end
  if PlayerInfo.car_default_musics then
    self.DefaultVehicleMusic = PlayerInfo.car_default_musics
    log_tree("STExtraLuaPlayerControllerBase:InitVehicleMusicIDs DefaultMusic :", self.DefaultVehicleMusic)
  end
end
function PlayerControllerBase:GetCommercialVehicle()
  local VehicleIDs = {}
  local Table = CDataTable.GetTableData("BetterVehicleEffect", self.ShowVehicleSkin)
  if Table and Table.BornFall == 1 then
    table.insert(VehicleIDs, self.ShowVehicleSkin)
  end
  return VehicleIDs
end
function PlayerControllerBase:GetParachutingVehicleInfo()
  local VehicleInfo = {}
  if self:UseGlideParachute() then
    local glideId = self:GetCurWearTwoPersonAircraftID()
    print(bWriteLog and "PlayerControllerBase:GetParachutingVehicleInfo RolewearIndex" .. tostring(self.RolewearIndex) .. "glideId" .. tostring(glideId))
    if glideId and 0 < glideId then
      local Table = CDataTable.GetTableDataByFilter("TwoPersonAircraftConfig", "Glide", glideId)
      if Table then
        table.insert(VehicleInfo, {
          Table.ParachuteVehiclePath,
          Table.VehicleSkinID
        })
      end
    end
  else
    local Table = CDataTable.GetTableData("BetterVehicleEffect", self.ShowVehicleSkin)
    if Table and Table.Parachute == 1 then
      table.insert(VehicleInfo, {
        Table.ParachuteVehicle,
        self.ShowVehicleSkin
      })
    end
  end
  log_tree("STExtraLuaPlayerControllerBase:GetParachutingVehicleInfo ", VehicleInfo)
  return VehicleInfo
end
function PlayerControllerBase:UseGlideParachute()
  if self.EnterFlyingNum and self.EnterFlyingNum > 1 and self:IsGlideAfterReviveDSSwitchEnabled() == false then
    return true
  end
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local PlayerInfo2 = PlayerDataMgr.GetPlayerInfo(self.UID)
  print(bWriteLog and "PlayerControllerBase:UseGlideParachute", PlayerInfo2)
  if PlayerInfo2 and PlayerInfo2.glide == true then
    print(bWriteLog and "PlayerControllerBase:UseGlideParachute", PlayerInfo2.glide)
    return true
  end
  local Table = CDataTable.GetTableData("BetterVehicleEffect", self.ShowVehicleSkin)
  if not Table or Table.Parachute ~= 1 then
    return true
  end
  local UGameplayStatics = import("GameplayStatics")
  local GameMode = UGameplayStatics.GetGameMode(self)
  if slua.isValid(GameMode) then
    local GameState = GameMode.GameState
    if slua.isValid(GameState) then
      local Table = CDataTable.GetTableData("BTMode", GameState.GameModeID)
      if not Table or Table.EnableParachutingVehicle ~= true then
        print(bWriteLog and "CharacterBase:InitParachutingVehicle Table.EnableParachutingVehicle ~= true " .. tostring(GameState.GameModeID))
        return true
      end
    end
  end
  return false
end
function PlayerControllerBase:IsGlideAfterReviveDSSwitchEnabled()
  local Result = true
  if CGameState then
    local State = CGameState:GetGameModeState()
    if State == "FightingState" or State == "FinishedState" then
      local DSSwitch = Game:GetDSSwitchValue(65)
      print(bWriteLog and "PlayerControllerBase:IsGlideAfterReviveDSSwitchEnabled, DSSwitch = " .. tostring(DSSwitch))
      if DSSwitch ~= "1" then
        Result = false
      end
    end
  end
  return Result
end
function PlayerControllerBase:OnPreBattleResult()
  print(bWriteLog and "STExtraLuaPlayerControllerBase.OnPreBattleResult")
  self:FlushGameSettingFlow()
end
function PlayerControllerBase:FlushGameSettingFlow()
  print(bWriteLog and "STExtraLuaPlayerControllerBase.FlushGameSettingFlow")
  local GameSetting = {}
  GameSetting.UID = 0
  if DataMgr and DataMgr.roleData then
    GameSetting.UID = DataMgr.roleData.uid
  end
  local BasicSetting = {}
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetFirstGameFrontendHUD()
  if uGameFrontendHUD then
    local uSettingConfig = uGameFrontendHUD:GetUserSettings()
    if slua.isValid(uSettingConfig) then
      BasicSetting.ShoulderEnable = uSettingConfig.ShoulderEnable or false
      BasicSetting.ShoulderMode = uSettingConfig.ShoulderMode or 1
    end
  end
  GameSetting.  log_tree("STExtraLuaPlayerControllerBase.FlushGameSettingFlow", GameSetting)
  local ds_net = require("ds_net")
  ds_net.SendMessage("c2ds_ingame_flow_setting", GameSetting, GameSetting.UID)
end
function PlayerControllerBase:CallClientRPC(MsgName, MsgTable)
end
function PlayerControllerBase:RPCClientReceive(MsgID, Content)
end
function PlayerControllerBase:CallDSRPC(MsgName, MsgTable)
end
function PlayerControllerBase:RPCDSReceive(MsgID, Content)
end
function PlayerControllerBase:NotifyDeadBoxCollapsed(bCollapsed)
  print(bWriteLog and "STExtraLuaPlayerControllerBase:NotifyDeadBoxCollapsed")
  if bCollapsed then
    EventSystem:postEvent(EVENTTYPE_DEADBOX_CLIENT, EVENTID_DEADBOX_OPENORCLOSEUI, false)
  end
end
function PlayerControllerBase:NotifyDeadBoxExpand()
  print(bWriteLog and "STExtraLuaPlayerControllerBase:NotifyDeadBoxExpand")
  EventSystem:postEvent(EVENTTYPE_DEADBOX_CLIENT, EVENTID_DEADBOX_OPENORCLOSEUI, true)
end
function PlayerControllerBase:CanAutoSwitchGrenade(GrenadeID)
  local UBackpackUtils = import("BackpackUtils")
  local ret = 0 < GrenadeID and not UBackpackUtils.CheckItemSubType(GrenadeID, 601)
  print(bWriteLog and "STExtraLuaPlayerControllerBase:CanAutoSwitchGrenade", GrenadeID, ret)
  return ret
end
PlayerControllerBase.ClientRPC.RPC_Client_MarkShoot = {
  Reliable = true,
  Params = {
    import("/Script/Engine.Actor"),
    import("/Script/Engine.Actor")
  }
}
function PlayerControllerBase:RPC_Client_MarkShoot(TargetPlayer, CauserPlayer)
  print(bWriteLog and "STExtraLuaPlayerControllerBase:RPC_Client_MarkShoot", TargetPlayer, CauserPlayer)
  local HitMarkClient = SubsystemMgr:Get("HitMarkClientSubSystem")
  if HitMarkClient then
  end
end
PlayerControllerBase.ClientRPC.RPC_Client_WonderfulPeriod = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Float
    },
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Bool,
    {
      UEnums.EPropertyClass.Array,
      import("WonderfulSubTypeInfo")
    }
  }
}
function PlayerControllerBase:RPC_Client_WonderfulPeriod(nType, nStartTime, nEndTime, uAdditionalData, nPeriodIndex, nPeriodScore, bIsPureAI, SubTypeInfoList)
  local tNewPeriodInfo = {
    nType = nType,
    nStartTime = nStartTime,
    nEndTime = nEndTime,
    uAdditionalData = uAdditionalData,
    nPeriodIndex = nPeriodIndex,
    nPeriodScore = nPeriodScore,
    bIsPureAI = bIsPureAI,
      }
  log_tree(bWriteLog and "STExtraLuaPlayerControllerBase:RPC_Client_WonderfulPeriod", tNewPeriodInfo)
  EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PERIOD_UPDATE, tNewPeriodInfo)
end
PlayerControllerBase.ClientRPC.RPC_Client_PostTGPAIS = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str
  }
}
function PlayerControllerBase:RPC_Client_PostTGPAIS(nKey, sValue)
  print(bWriteLog and "PlayerControllerBase:RPC_Client_PostTGPAIS", nKey, sValue)
  local TApmHelper = import("TApmHelper")
  if TApmHelper and TApmHelper.PostGameStatusToTGPAIS and nKey and sValue then
    TApmHelper.PostGameStatusToTGPAIS(nKey, sValue)
  end
end
function PlayerControllerBase:CanPickUpItem(DefineID)
  local EPickUpCheckResult = import("EPickUpCheckResult")
  if DefineID.Type == 1 then
    local uCurPawn = self:GetCurPawn()
    if slua.isValid(uCurPawn) and uCurPawn.GetWeaponManager ~= nil then
      local uWeaponMgr = uCurPawn:GetWeaponManager()
      if slua.isValid(uWeaponMgr) and not uWeaponMgr.bClientHasFinishedHandleSpawnWeapon then
        return EPickUpCheckResult.EPUFR_DelayAdd
      end
    end
  end
  return EPickUpCheckResult.EPUFR_OK
end
function PlayerControllerBase:DealWithPickUpFailed(DefineID)
  if CGameMode and slua.isValid(CGameMode.PlayerRespawnComponent) then
    CGameMode.PlayerRespawnComponent:PlayerDelayAddItem(self.PlayerKey, DefineID.TypeSpecificID)
  end
end
function PlayerControllerBase:OverrideAvatarInfo(tPlayerInfo)
end
function PlayerControllerBase:HandlePlayerEnterFighting()
  self:DestroyFlyDeviceAnimCache()
end
function PlayerControllerBase:DestroyFlyDeviceAnimCache()
  local uCharacter = self:GetPlayerCharacterSafety()
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
  if slua.isValid(uCharacter) then
    local Controller = uCharacter:GetPlayerControllerSafety()
    if not slua.isValid(Controller) or not GameLuaAPI.IsClassOf(Controller, ASTExtraPlayerController) then
      return
    end
    print(bWriteLog and "PlayerControllerBase:DestroyFlyDevivceAnimCache ")
    Controller:SetParachuteAnimCached(2, false)
  elseif self:IsSpectator() then
    local SpectatorPawn = self:GetCurPawn()
    if not slua.isValid(SpectatorPawn) then
      return
    end
    local Controller = SpectatorPawn:GetPlayerControllerSafety()
    if not slua.isValid(Controller) or not GameLuaAPI.IsClassOf(Controller, ASTExtraPlayerController) then
      return
    end
    print(bWriteLog and "PlayerControllerBase: SpectatorPawn DestroyFlyDevivceAnimCache ")
    Controller:SetParachuteAnimCached(2, false)
  end
end
function PlayerControllerBase:HandleOnPlayerKilledOthersPlayer(FatalDamageParameter)
  print(bWriteLog and "[tinghaohu]PlayerControllerBase:HandleOnPlayerKilledOthersPlayer. causerKey = " .. tostring(FatalDamageParameter.causerKey) .. ", victimKey = " .. tostring(FatalDamageParameter.victimKey))
  if FatalDamageParameter.causerKey == self.PlayerKey then
    local MyHUD = self:GetHUD()
    local IsDying = FatalDamageParameter.ResultHealthStatus == 1 and FatalDamageParameter.PreviousHealthStatus == 0
    local IsDeath = FatalDamageParameter.ResultHealthStatus == 2
    MyHUD:PlayFatalDamageSound(IsDying, IsDeath)
  end
  local EFatalDamageRelationShip = import("EFatalDamageRelationShip")
  if FatalDamageParameter.Relationship == EFatalDamageRelationShip.MyTeamateIsCauser then
    local ScriptGameplayStatics = import("ScriptGameplayStatics")
    local uPlayerCharacter = ScriptGameplayStatics.GetCharacterByPlayerKey(self, FatalDamageParameter.causerKey)
    if slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerCharacter.CharacterAvatarComp2_BP) then
      local EAvatarSlotType = import("EAvatarSlotType")
      uPlayerCharacter.CharacterAvatarComp2_BP:SetMeshVisibleByID(EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot, true, false, true)
    end
  end
  if self.CanModPlayActorVoiceFeature then
    local ECharacterHealthStatus = import("ECharacterHealthStatus")
    local CanPlay = FatalDamageParameter.ResultHealthStatus == ECharacterHealthStatus.FinishedLastBreath and FatalDamageParameter.causerKey == self.PlayerKey and FatalDamageParameter.Relationship ~= EFatalDamageRelationShip.MyTeammateIsCauserAndVictim
    if not CanPlay then
      return
    end
    local voiceKey
    if LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
      local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
      local PlayerFeatureVoiceCfg = SettingConfig.PlayerFeatureVoiceCfg
      if not PlayerFeatureVoiceCfg then
        return
      end
      local SettingValue = PlayerFeatureVoiceCfg:Get("SelfKillOthers")
      if not SettingValue then
        return
      end
      local StringUtil = require("common.string_util")
      local VoiceKeyList = StringUtil.Split(SettingValue, "|")
      if VoiceKeyList and next(VoiceKeyList) then
        voiceKey = tonumber(VoiceKeyList[math.random(#VoiceKeyList)])
      end
      print(bWriteLog and "layerControllerBase:HandleOnPlayerKilledOthersPlayer Voice_V2 result voiceKey", voiceKey)
    elseif LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH) then
      local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
      if not SettingSubsystem then
        return
      end
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      local SettingValue = SettingSubsystem:GetUserSettings_Int("PlayerChatActorID")
      if not SettingValue or not ActorVoiceSystem.CheckIsActorValid(SettingValue) then
        return
      end
      local ActorFeatureData = CDataTable.GetTableData("ActorVoiceFeatures", SettingValue)
      if not ActorFeatureData then
        return
      end
      voiceKey = ActorFeatureData.SelfKillOthersVoiceID
      print(bWriteLog and "layerControllerBase:HandleOnPlayerKilledOthersPlayer Voice_V1 result voiceKey", voiceKey)
    end
    if voiceKey then
      self:SendStringMsg("", voiceKey, 0, "", 0, 0, true)
    end
  end
end
function PlayerControllerBase:RPC_Client_MaliciousTeammateReceiveWarningTips()
  local ClientQuickReportMaliciousTeammate = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
  if not ClientQuickReportMaliciousTeammate then
    return
  end
  ClientQuickReportMaliciousTeammate.MaliciousTeammateReceiveWarningTips()
end
function PlayerControllerBase:RPC_Client_MaliciousTeammateVictimReceiveTips(sTeammateUID, bIsForbidPickupRevokable, nVictimHealthStatus)
  local ClientQuickReportMaliciousTeammate = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
  if not ClientQuickReportMaliciousTeammate then
    return
  end
  ClientQuickReportMaliciousTeammate.MaliciousTeammateVictimReceiveTips(sTeammateUID, bIsForbidPickupRevokable, nVictimHealthStatus)
end
function PlayerControllerBase:RPC_Client_PopupAFKWindow(IsWarning, ShouldClose)
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  if ShouldClose then
    IngameTipsTools.HideAllMsgBox()
  elseif IsWarning then
    IngameTipsTools.HideAllMsgBox()
    IngameTipsTools.ShowMsgBox(1, LocUtil.GetLocalizeResStr(612401041), LocUtil.GetLocalizeResStr(612401042), function()
    end)
  else
    IngameTipsTools.HideAllMsgBox()
    IngameTipsTools.ShowMsgBox(1, LocUtil.GetLocalizeResStr(612401043), LocUtil.GetLocalizeResStr(612401044), function()
    end)
  end
end
function PlayerControllerBase:IsRevivalMode()
  print(bWriteLog and "revivaldebug PlayerControllerBase IsRevivalMode call")
  local bIsRevival = self:TeammateCanRevival()
  if not bIsRevival then
    bIsRevival = self.Super:IsRevivalMode()
    print(bWriteLog and "PlayerControllerBase IsRevivalMode IsRevivalMode:", bIsRevival)
  end
  return bIsRevival
end
function PlayerControllerBase:TeammateCanRevival()
  local uPlayerState = self.PlayerState
  if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
    local tTeammate = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for _, uTeamPlayerState in pairs(tTeammate) do
      if slua.isValid(uTeamPlayerState) and (uTeamPlayerState.GetRevivalCount and uTeamPlayerState:GetRevivalCount() > 0 or uTeamPlayerState.GetLeftBuyLifeCounts and 0 < uTeamPlayerState:GetLeftBuyLifeCounts()) then
        return true
      end
    end
  end
  return false
end
function PlayerControllerBase:CanBePickUpByItemID(DefineID)
  if CGameState and slua.isValid(CGameState) and CGameState.ReviveState then
    local ItemId = CGameState.ReviveState:GetConfigSelfReviveItemId()
    if DefineID.TypeSpecificID ~= ItemId then
      return self.Super:CanBePickUpByItemID(DefineID)
    end
    local ItemLimitedTime = CGameState.ReviveState:GetConfigItemLimitedTime()
    if ItemLimitedTime < CGameState:GetServerWorldTimeSeconds() then
      print(bWriteLog and "PlayerControllerBase:CanBePickUpByItemID, ItemLimitedTime = " .. tostring(ItemLimitedTime) .. ", PlayerKey = " .. tostring(self.PlayerKey))
      return false
    end
  end
  local uPlayerState = self.PlayerState
  if uPlayerState and uPlayerState.ReviveStateFeature and uPlayerState.ReviveStateFeature:GetUseSinglePlayerReviveItem() == true then
    print(bWriteLog and "PlayerControllerBase:CanBePickUpByItemID, PlayerKey = " .. tostring(self.PlayerKey))
    return false
  end
  return self.Super:CanBePickUpByItemID(DefineID)
end
function PlayerControllerBase:GetLastestViewPlayerKey()
  return self.LastestViewPlayerKey or 0
end
function PlayerControllerBase:HandlePlayerExitGame(ParamState, ParamReason)
  local uPlayerState = self.PlayerState
  if uPlayerState and slua.isValid(uPlayerState) then
    local bIsAlive = uPlayerState:IsAlive()
    print(bWriteLog and "PlayerControllerBase:HandlePlayerExitGame, PlayerKey = " .. tostring(uPlayerState.PlayerKey) .. ", IsAlive = " .. tostring(bIsAlive))
    local totalCount = 0
    if uPlayerState.GetRevivalCount then
      totalCount = totalCount + uPlayerState:GetRevivalCount()
    end
    if uPlayerState.GetLeftBuyLifeCounts then
      totalCount = totalCount + uPlayerState:GetLeftBuyLifeCounts()
    end
    if bIsAlive or 0 < totalCount then
      local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
      if DSAITLogSubsystem and DSAITLogSubsystem.HandlePlayerStateChanged then
        DSAITLogSubsystem:HandlePlayerStateChanged(nil, nil, uPlayerState.UID, ParamState, nil, bIsAlive, ParamReason)
      end
    end
    if not bIsAlive then
      if uPlayerState.GetRevivalCount and 0 < uPlayerState:GetRevivalCount() then
        uPlayerState:SetRevivalCount(0)
      end
      if uPlayerState.GetLeftBuyLifeCounts and 0 < uPlayerState:GetLeftBuyLifeCounts() then
        uPlayerState:SetLeftBuyLifeCounts(0)
      end
      if uPlayerState.IsInWaittingRevivalState ~= nil then
        uPlayerState.IsInWaittingRevivalState = false
      end
      if uPlayerState.bHasSendBattleResult ~= nil and uPlayerState.bHasSendBattleResult == false then
        print(bWriteLog and "PlayerControllerBase:HandlePlayerExitGame, CheckSendBattleResult")
        local UGameplayStatics = import("GameplayStatics")
        local GameMode = UGameplayStatics.GetGameMode(self)
        Game:CheckSendBattleResult(GameMode, uPlayerState, false)
      end
    end
  else
    print(bWriteLog and "PlayerControllerBase:HandlePlayerExitGame, uPlayerState = " .. tostring(uPlayerState))
  end
end
function PlayerControllerBase:HandleSpectatorChange()
  local uPlayerPawn = self:GetCurPlayerCharacter()
  print(bWriteLog and "PlayerControllerBase:HandleSpectatorChange uPlayerPawn", uPlayerPawn)
  if not self:HasAuthority() then
    if slua.isValid(uPlayerPawn) and slua.isValid(uPlayerPawn.ThirdPersonCameraComponent) then
      print(bWriteLog and "PlayerControllerBase:HandleSpectatorChange bAbsoluteLocation", uPlayerPawn.ThirdPersonCameraComponent.bAbsoluteLocation)
      if uPlayerPawn.ThirdPersonCameraComponent.bAbsoluteLocation then
        if uPlayerPawn.ApplyAllCompOptimizationByVision then
          uPlayerPawn:ApplyAllCompOptimizationByVision(false)
        end
        uPlayerPawn.ThirdPersonCameraComponent.bAbsoluteLocation = false
        uPlayerPawn.ThirdPersonCameraComponent.bAbsoluteRotation = false
        uPlayerPawn.ThirdPersonCameraComponent.bAbsoluteScale = false
      end
    end
    return
  end
  if slua.isValid(uPlayerPawn) then
    self.LastestViewPlayerKey = uPlayerPawn.PlayerKey or 0
    local uParentActor = uPlayerPawn:GetAttachParentActor()
    print(bWriteLog and "PlayerControllerBase:HandleSpectatorChange", uPlayerPawn, uParentActor, PlaneCls, self.ThePlane)
    if slua.isValid(uParentActor) and Game:IsClassOf(uParentActor, PlaneCls) and self.ThePlane ~= uParentActor then
      self.ThePlane = self.Object
      self:OnRep_Plane()
    end
  end
end
function PlayerControllerBase:MarkTeammateExitTeamBeforeBoarding()
  if Client then
    return
  end
  self._bIsTeammateExitTeamBeforeBoarding = true
end
function PlayerControllerBase:IsTeammateExitTeamBeforeBoarding()
  return self._bIsTeammateExitTeamBeforeBoarding
end
function PlayerControllerBase:SwitchToTeammate(Idx)
  print(bWriteLog and "PlayerControllerBase:SwitchToTeammate", Idx)
  self:HandleSwitchToPlayerIndex(Idx)
end
function PlayerControllerBase:SwitchFreeViewInOB()
  print(bWriteLog and "PlayerControllerBase:SwitchFreeViewInOB1", self:IsObserver(), self:IsDemoPlayGlobalObserver())
  if self:IsObserver() or self:IsDemoPlayGlobalObserver() then
    print(bWriteLog and "PlayerControllerBase:SwitchFreeViewInOB2")
    self:HandleEnterFreeViewInOB()
  end
end
PlayerControllerBase.ServerRPC.RPC_Server_ReqUseShareSkin = {
  Reliable = true,
  Params = {}
}
PlayerControllerBase.ClientRPC.RPC_Client_NotifyUseShareSkin = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
PlayerControllerBase.ServerRPC.RPC_Server_RealUseShareSkin = {
  Reliable = true,
  Params = {}
}
function PlayerControllerBase:RPC_Server_ReqUseShareSkin()
  print(bWriteLog and " PlayerControllerBase:RPC_Server_ReqUseShareSkin")
  if self.nInLeftSharedSkinTimes > 0 then
    if 0 < self.nFriendLeftSharedSkinTimes then
      self:RPC_Client_NotifyUseShareSkin(0)
    else
      self:RPC_Client_NotifyUseShareSkin(2)
    end
  else
    self:RPC_Client_NotifyUseShareSkin(1)
  end
end
function PlayerControllerBase:RPC_Server_RealUseShareSkin()
  print(bWriteLog and " PlayerControllerBase:RPC_Server_ReqUseShareSkin")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  if PlayerDataMgr then
    local playerInfo = PlayerDataMgr.GetPlayerInfo(self.UID)
    log_tree(" PlayerControllerBase:RPC_Server_RealUseShareSkin playerInfo.share_wear", playerInfo.share_wear)
    if playerInfo and playerInfo.share_wear and playerInfo.share_wear.friend_uid ~= 0 then
      if 0 < self.nInLeftSharedSkinTimes and 0 < self.nFriendLeftSharedSkinTimes then
        self.nInLeftSharedSkinTimes = self.nInLeftSharedSkinTimes - 1
        self.nFriendLeftSharedSkinTimes = self.nFriendLeftSharedSkinTimes - 1
        local uTargetPlayerController = Game:GetPlayerControllerByUID(playerInfo.share_wear.friend_uid)
        if Game:IsValid(uTargetPlayerController) then
          uTargetPlayerController.nOutLeftSharedSkinTimes = uTargetPlayerController.nOutLeftSharedSkinTimes - 1
        else
          print(bWriteLog and " PlayerControllerBase:RPC_Server_ReqUseShareSkin invalid uTargetPlayerController")
        end
      else
        print(bWriteLog and " PlayerControllerBase:RPC_Server_RealUseShareSkin unexpect cond 1. uid:" .. self.UID)
      end
      return
    end
  end
  print(bWriteLog and " PlayerControllerBase:RPC_Server_RealUseShareSkin unexpect cond 2. uid:" .. self.UID)
end
function PlayerControllerBase:RPC_Client_NotifyUseShareSkin(Reason)
  print(bWriteLog and string.format(" PlayerControllerBase:RPC_Client_NotifyUseShareSkin Reason:%s", Reason))
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_USE_SHARESKIN, Reason)
end
function PlayerControllerBase:OnRep_nFriendLeftSharedSkinTimes()
  print(bWriteLog and string.format(" PlayerControllerBase:OnRep_nFriendLeftSharedSkinTimes :%s", self.nFriendLeftSharedSkinTimes))
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_INGAME_REFRESH_LEFT_TIMES)
end
function PlayerControllerBase:UseSharedBagSkin()
  local cond = self.nInLeftSharedSkinTimes > 0 and 0 < self.nFriendLeftSharedSkinTimes
  print(bWriteLog and " PlayerControllerBase:UseSharedBagSkin cond:" .. tostring(cond))
  if cond then
    self.Super:UseSharedBagSkin()
  end
  return cond
end
function PlayerControllerBase:TriggerInputAction(Key)
  local WoWEditorDefine = require("GameLua.Mod.CreativeBase.Gameplay.Subsystem.WoWEditor.WoWEditorDefine")
  if IsWoWEditor and not WoWEditorDefine.InputKeyWhiteList[Key.KeyName] then
    return
  end
  if IsWoWEditor and Key.KeyName == "SpaceBar" then
    local CreativeModeEditBuildSubSystem = SubsystemMgr:Get("CreativeModeEditBuildSubSystem")
    local bIsFreeViewMode = CreativeModeEditBuildSubSystem and CreativeModeEditBuildSubSystem:IsFreeViewMode()
    if bIsFreeViewMode then
      return
    end
  end
  if InputStateControl then
    InputStateControl.CallInputAction(Key)
  end
  if Client.IsWindowOB() or Client.IsWindows() then
    EventSystem:postEvent(EVENTTYPE_PCOB, EVENTID_PCOB_INPUT_KEY, Key)
  end
end
function PlayerControllerBase:HandleShowFollowEmoteUI(ShowFollowEmote)
  if self.bIsShowingFollowEmoteUI == ShowFollowEmote then
    return
  end
  self.bIsShowingFollowEmoteUI = ShowFollowEmote
  print(bWriteLog and "PlayerControllerBase HandleShowFollowEmoteUI", ShowFollowEmote)
  if ShowFollowEmote then
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_FollowEmote")
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_FollowEmote")
  end
end
function PlayerControllerBase:HandleTouchInterfaceChanged()
  self:BindVirtualJoystickInputDelegates(true)
  self:BindVirtualJoystickTouchedStartInAreaDelegates(true)
end
function PlayerControllerBase:HandleOnSetPlane(Plane)
  if Client then
    return
  end
  print(bWriteLog and "PlayerControllerBase:HandleOnSetPlane", Plane, self.PlayerKey)
  local ENetRole = import("ENetRole")
  if slua.isValid(self.SpectatorComponent) and self.SpectatorComponent.GetOwnerObservers and not self:IsSpectator() then
    local ObserverList = self.SpectatorComponent:GetOwnerObservers()
    if ObserverList then
      for _, ObController in pairs(ObserverList) do
        if ObController and (ObController:IsSpectator() or ObController:IsInPetSpectator()) and ObController.ThePlane ~= Plane then
          print(bWriteLog and "PlayerControllerBase:HandleOnSetPlane ObController:", ObController.PlayerKey)
          ObController:SetCanGotoExPlane(true)
          ObController:SetPlane(Plane)
          ObController:SetCanGotoExPlane(false)
        end
      end
    end
  end
end
function PlayerControllerBase:HandleOnPlayerExitFlying()
  if Client then
    return
  end
  local PlayerCharacter = self:GetPlayerCharacterSafety()
  print(bWriteLog and "PlayerControllerBase:HandleOnPlayerExitFlying", self.PlayerKey, PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local ENetRole = import("ENetRole")
  if slua.isValid(self.SpectatorComponent) and self.SpectatorComponent.GetOwnerObservers and not self:IsSpectator() then
    local ObserverList = self.SpectatorComponent:GetOwnerObservers()
    if ObserverList then
      for _, ObController in pairs(ObserverList) do
        if ObController and ObController:IsSpectator() then
          print(bWriteLog and "PlayerControllerBase:HandleOnPlayerExitFlying ObController:", ObController.PlayerKey)
          ObController:SetViewTargetTest(PlayerCharacter)
        end
      end
    end
  end
end
function PlayerControllerBase:HandleShowMovableEmoteUI(ShowFollowEmote)
  if self.bIsShowingMovableEmoteUI == ShowFollowEmote then
    return
  end
  self.bIsShowingMovableEmoteUI = ShowFollowEmote
  print(bWriteLog and "PlayerControllerBase HandleShowMovableEmoteUI", ShowFollowEmote)
end
function PlayerControllerBase:PlaySpecifiedPetAnimation(nAnimationID, bIsMiniTv)
  if Client then
    local ActionRow = CDataTable.GetTableData("PetActionTable", nAnimationID)
    local nMasterSkillID = 0
    if ActionRow and ActionRow.MasterSkillID and 0 < ActionRow.MasterSkillID then
      nMasterSkillID = ActionRow.MasterSkillID
    end
    local uCurPawn = self:GetCurPawn()
    if slua.isValid(uCurPawn) and slua.isValid(uCurPawn.PetComponent_BP) and slua.isValid(uCurPawn.PetComponent_BP.PetPawn) then
      local uActivePawn
      if bIsMiniTv then
        uActivePawn = uCurPawn.PetComponent_BP:GetMiniTVPawn()
      else
        uActivePawn = uCurPawn.PetComponent_BP.PetPawn
      end
      if slua.isValid(uActivePawn) and uActivePawn.bHidden then
        print(bWriteLog and "PlayerControllerBase:PlaySpecifiedPetAnimation Pet Hidden not allow to play")
        if uActivePawn.bInPetExhibiting then
          ShowNotice(82159)
        else
          ShowNotice(66661)
        end
        return
      end
      local uPetComp = uCurPawn.PetComponent_BP
      if 0 < nMasterSkillID and uPetComp.PlaySpecifiedPetAnimationCheck and not uPetComp:PlaySpecifiedPetAnimationCheck(uCurPawn) then
        return
      end
    end
    if ActionRow and ActionRow.PetAnimRes then
      do
        local Util = require("client.slua_ui_framework.util")
        Util.GetAssetAsync(ActionRow.PetAnimRes, function(uAnimation)
          if slua.isValid(uAnimation) then
            self:RPC_Server_PlaySpecifiedPetAnimation(nAnimationID, uAnimation.SequenceLength, nMasterSkillID, bIsMiniTv or false)
          end
        end)
      end
    end
  end
end
function PlayerControllerBase:RPC_Server_PlaySpecifiedPetAnimation(nAnimationID, AnimationLength, MasterSkillID, bIsMiniTv)
  local uCurPawn = self:GetCurPawn()
  if slua.isValid(uCurPawn) and slua.isValid(uCurPawn.PetComponent_BP) and nAnimationID and AnimationLength and 0 < AnimationLength then
    print(bWriteLog and "PlayerControllerBase:RPC_Server_PlaySpecifiedPetAnimation nAnimationID = " .. nAnimationID .. "AnimationLength" .. AnimationLength .. "MasterSkillID:" .. tostring(MasterSkillID))
    local PetEmoteConfig = CDataTable.GetTableData("PetActionTable", nAnimationID)
    if not PetEmoteConfig or PetEmoteConfig.CanPlayInBattle == 0 or PetEmoteConfig.CanPlayInBattle == 3 then
      print(bWriteLog and "PlayerControllerBase:RPC_Server_PlaySpecifiedPetAnimation not allow to play")
      return
    end
    local uActivePawn
    if bIsMiniTv then
      uActivePawn = uCurPawn.PetComponent_BP:GetMiniTVPawn()
    else
      uActivePawn = uCurPawn.PetComponent_BP.PetPawn
    end
    if slua.isValid(uActivePawn) then
      if not uActivePawn:CanPlay() then
        return
      end
      if uActivePawn.bHidden then
        print(bWriteLog and "PlayerControllerBase:RPC_Server_PlaySpecifiedPetAnimation Pet Hidden not allow to play")
        return
      end
    end
    if slua.isValid(uActivePawn) then
      do
        local EPetState = import("EPetState")
        if uActivePawn:PetHasState(EPetState.PetPlayingFeature) then
          return
        end
        local EmoteIsUnLocked = function(EmoteID, bIsMiniTv)
          if not bIsMiniTv then
            local StringUtil = require("common.string_util")
            local PetID = uActivePawn.PetLevelInfo.PetId
            local PetLevel = uActivePawn.PetLevelInfo.PetLevel
            local ConfigID = 10000 * PetID + PetLevel
            local PetLevelConfig = CDataTable.GetTableData("PetLevelTable", ConfigID)
            local AllAction = StringUtil.Split(PetLevelConfig.AllAction, "|")
            if AllAction and 0 < #AllAction then
              for _, ID in pairs(AllAction) do
                if EmoteID == tonumber(ID) then
                  return true
                end
              end
            end
          elseif self.CommerFeature and self.CommerFeature.MiniTVActionIDList then
            for _, ID in pairs(self.CommerFeature.MiniTVActionIDList) do
              if EmoteID == tonumber(ID) then
                return true
              end
            end
          end
          return false
        end
        if not EmoteIsUnLocked(nAnimationID, bIsMiniTv) then
          print(bWriteLog and "PlayerControllerBase:RPC_Server_PlaySpecifiedPetAnimation is locked")
          return
        end
        if uActivePawn.BeforePlayAction then
          uActivePawn:BeforePlayAction(nAnimationID)
        end
        if MasterSkillID ~= nil and 0 < MasterSkillID then
          local SkillManager = uCurPawn:GetSkillManager()
          if slua.isValid(SkillManager) then
            local uSkill = SkillManager:GetSkill(MasterSkillID)
            if uSkill and uSkill:IsCDOK(SkillManager, -1) then
              uCurPawn:TriggerEntrySkillWithID(MasterSkillID, true)
            end
          end
          uActivePawn:PlayPetInteractAnimation(uCurPawn, nAnimationID, AnimationLength)
        else
          uActivePawn:PlayPetAnimation(nAnimationID, AnimationLength)
        end
      end
    end
  end
end
function PlayerControllerBase:RPC_Server_SetGameReadyCountDown(nRemainingTime)
  print(bWriteLog and "PlayerControllerBase:RPC_Server_SetGameReadyCountDown", nRemainingTime, slua.isValid(CGameMode), slua.isValid(CGameState))
  if not Client and slua.isValid(CGameMode) and slua.isValid(CGameState) and nRemainingTime then
    print(bWriteLog and "PlayerControllerBase:RPC_Server_SetGameReadyCountDown IsObserver", self:IsObserver(), self.bRoomOwner, CGameMode.RoomType)
    if self:IsObserver() and self.bRoomOwner and CGameMode.RoomType == "match" then
      local GameModeState = CGameState:GetGameModeState() or ""
      print(bWriteLog and "PlayerControllerBase:RPC_Server_SetGameReadyCountDown GameModeState", GameModeState)
      if GameModeState == "ReadyState" then
        CGameState.MatchReadyConfirmed = true
        CGameMode:SetStateLeftTime(nRemainingTime)
      end
    end
  end
end
function PlayerControllerBase:BecomeAGhost(bGhost)
  self.Super:BecomeAGhost(bGhost)
  if self:IsGhost() then
    if self.DisableNetUpdateGroupID then
      self:DisableNetUpdateGroupID(1)
    else
      print(bWriteLog and "PlayerControllerBase:BecomeAGhost, have no DisableNetUpdateGroupID function")
    end
  elseif self.EnableNetUpdateGroupID then
    self:EnableNetUpdateGroupID(1)
  else
    print(bWriteLog and "PlayerControllerBase:BecomeAGhost, have no EnableNetUpdateGroupID function")
  end
end
function PlayerControllerBase:OnRep__bIsTeammateExitTeamBeforeBoarding()
  print(bWriteLog and "PlayerControllerBase:OnRep__bIsTeammateExitTeamBeforeBoarding ", self._bIsTeammateExitTeamBeforeBoarding)
  if self._bIsTeammateExitTeamBeforeBoarding then
    local UIInstance = UIManager.GetUI(UIManager.UI_Config_InGame.BirthIslandTips)
    if UIInstance and UIInstance.ShowEscapeNotice then
      UIInstance:ShowEscapeNotice()
      print(bWriteLog and "PlayerControllerBase:OnRep__bIsTeammateExitTeamBeforeBoarding ShowEscapeNotice")
    end
  end
end
function PlayerControllerBase:PerRespawnClearOtherPawn()
  if slua.isValid(self:GetPetSpectatorComp()) then
    print(bWriteLog and "PlayerControllerBase:RecoverWaitingRespawnPawn")
    self:GetPetSpectatorComp():PerRespawnClearOtherPawn()
  end
end
function PlayerControllerBase:CheckCanCustomChat()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if uGameState and uGameState:GetDSSwitchValueFastWithCache(62) == "1" then
    if not Client and CGameMode and CGameMode.RoomType == "match" then
      print(bWriteLog and "ChatComponent:ReceiveBeginPlay Is MatchRoom")
      self.bForbidCustomChat = true
    end
    if not Client then
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      if GameMainConfig.IsPeakGame() then
        print(bWriteLog and "ChatComponent:ReceiveBeginPlay IsPeakGame")
        self.bForbidCustomChat = false
      end
      if GameMainConfig.IsNationEsports() then
        print(bWriteLog and "ChatComponent:ReceiveBeginPlay IsNationEsports")
        self.bForbidCustomChat = true
      end
    end
  end
  if Server and Server.IsMatchVersion and Server.IsMatchVersion() then
    print(bWriteLog and "PlayerControllerBase:CheckCanCustomChat IsMatchVersion")
    self.bForbidCustomChat = true
  end
end
function PlayerControllerBase:LuaShowJoystickWidgetWithTag(Tag)
  self:ShowJoystickWidgetWithTag(Tag)
end
function PlayerControllerBase:LuaHideJoystickWidgetWithTag(Tag)
  self:ActivateTouchInterface(nil)
  self:HideJoystickWidgetWithTag(Tag)
end
function PlayerControllerBase:LuaShowJoystickWithTag(Tag)
  self:ShowJoystickWithTag(Tag)
end
function PlayerControllerBase:LuaHideJoystickWithTag(Tag)
  self:HideJoystickWithTag(Tag)
end
function PlayerControllerBase:SetAlwaysHideTouchInterface(Hide)
  if Hide then
    self:LuaHideJoystickWidgetWithTag("AlwaysHideTouchInterface")
  else
    self:LuaShowJoystickWidgetWithTag("AlwaysHideTouchInterface")
  end
end
function PlayerControllerBase:LuaShouldShowTouchInterface(bShow)
  return bShow
end
function PlayerControllerBase:NotCanShowTouchInterfaceHandle()
  return false
end
function PlayerControllerBase:PreShowTouchInterfaceCheck(show)
  return 0
end
function PlayerControllerBase:ShowTouchInterface(show, reason)
  print(bWriteLog and string.format("PlayerControllerBase:ShowTouchInterface %s (reason = %s)", show, reason))
  local bRealShow = self:LuaShouldShowTouchInterface(show)
  if self.bIsJoyStickShow == bRealShow then
    return
  end
  if bRealShow then
    self.bIsJoyStickShow = true
    self:LuaShowJoystickWithTag("OutDatedMethodTag")
  else
    self.bIsJoyStickShow = false
    self:LuaHideJoystickWithTag("OutDatedMethodTag")
  end
end
function PlayerControllerBase:PostOnShowTouchInterface(bShow)
  if bShow then
    EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_JOYSTICK)
  end
end
function PlayerControllerBase:OnRep_bForbidCustomChat()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_REFRESH_FORBID_CUSTOM_CHAT, self.bForbidCustomChat)
end
function PlayerControllerBase:OnGoingToLoseJoystick()
  self:SetVirtualJoystickVisibility(false)
  self:ClearJoystick()
end
function PlayerControllerBase:HandleServerSpectatorChange(uViewTargetCharacter)
  if not Client and slua.isValid(uViewTargetCharacter) then
    if self.GetPetSpectatorComp then
      local PetSpectatorComp = self:GetPetSpectatorComp()
      if slua.isValid(PetSpectatorComp) and PetSpectatorComp.OnOwnerGotoSpectating then
        PetSpectatorComp:OnOwnerGotoSpectating()
      end
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_SERVER_SPECTATOR_CHANGE, self.Object, uViewTargetCharacter)
    if self:IsObserver() and slua.isValid(self.BackpackObserverRepActor) then
      local uPlayerController = uViewTargetCharacter:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) and uPlayerController.GetBackpackComponent then
        local uBackpackComp = uPlayerController:GetBackpackComponent()
        print(bWriteLog and "PlayerControllerBase:HandleServerSpectatorChange", uBackpackComp)
        if slua.isValid(uBackpackComp) then
          self.BackpackObserverRepActor:RefreshAllItems(uBackpackComp)
        end
      end
    end
    local uParentActor = uViewTargetCharacter:GetAttachParentActor()
    print(bWriteLog and "PlayerControllerBase:HandleServerSpectatorChange plane", uViewTargetCharacter.PlayerName, uParentActor, Game:IsClassOf(uParentActor, PlaneCls), self.ThePlane)
    if slua.isValid(uParentActor) and Game:IsClassOf(uParentActor, PlaneCls) and self.ThePlane ~= uParentActor then
      self.ThePlane = uParentActor
    end
  end
end
function PlayerControllerBase:RegistSetting()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local bAutoUseMelee = SettingSubsystem:GetUserSettings_Bool("AutoUseMelee")
  self:RPC_Server_SetAutoUseMelee(bAutoUseMelee)
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("AutoUseMelee", function(AutoUseMelee)
    self:RPC_Server_SetAutoUseMelee(AutoUseMelee)
  end)
  local bPeekCanSprint = SettingSubsystem:GetUserSettings_Bool("PeekToSprintSwitch")
  self.  SettingSubsystem:RegisterUserSettingsDelegate_Bool("PeekToSprintSwitch", function(InbPeekCanSprint)
    self.bPeekCanSprint = InbPeekCanSprint
  end)
  local nGyroscope = SettingSubsystem:GetUserSettings_Int("Gyroscope")
  self.UseMotionControlType = nGyroscope
  print(bWriteLog and "PlayerControllerBase: Set UseMotionControlType ", self.UseMotionControlType)
  SettingSubsystem:RegisterUserSettingsDelegate_Int("Gyroscope", function(InGyroscope)
    self.UseMotionControlType = InGyroscope
    print(bWriteLog and "PlayerControllerBase: Set UseMotionControlType Delegate ", InGyroscope, self.UseMotionControlType)
  end)
  local bGyroReverse = SettingSubsystem:GetUserSettings_Bool("GyroReverse")
  self.GyroReverse = bGyroReverse
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("GyroReverse", function(InGyroReverse)
    self.GyroReverse = InGyroReverse
  end)
  local bHoldGrenadeStateEnableGyro = SettingSubsystem:GetUserSettings_Bool("HoldGrenadeStateEnableGyro")
  self.  SettingSubsystem:RegisterUserSettingsDelegate_Bool("HoldGrenadeStateEnableGyro", function(InHoldGrenadeStateEnableGyro)
    self.bHoldGrenadeStateEnableGyro = InHoldGrenadeStateEnableGyro
  end)
end
function PlayerControllerBase:RPC_Server_SetAutoUseMelee(bAutoUseMelee)
  if Client then
    return
  end
  print(bWriteLog and "PlayerControllerBase_Debug_Msg: bAutoEquipMelleeWeaponLanded = " .. tostring(self.bAutoEquipMelleeWeaponLanded) .. " bAutoUseMelee = " .. tostring(bAutoUseMelee))
  self.bAutoEquipMelleeWeaponLanded = bAutoUseMelee
end
function PlayerControllerBase:JumpPlanDell(uCharacter)
  local bIsSpectator = self.IsSpectator and self:IsSpectator() or false
  print(bWriteLog and "PlayerControllerBase:JumpPlanDell", bIsSpectator)
  if slua.isValid(uCharacter) then
    local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
    if bIsSpectator then
      self:SetViewTargetWithBlend(uCharacter, 0.5, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
      return
    end
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync("/Game/BluePrints/Plane/BP_PlaneDummy.BP_PlaneDummy_C", function(Plane)
      if Plane and self.GetWorld and slua.isValid(uCharacter) then
        local PlaneClass = slua.loadClass("/Game/BluePrints/Plane/BP_PlaneDummy.BP_PlaneDummy")
        local UAIBlueprintHelperLibrary = import("AIBlueprintHelperLibrary")
        local Airplane = UAIBlueprintHelperLibrary.SpawnAIFromClass(self:GetWorld(), PlaneClass, nil, uCharacter:K2_GetActorLocation(), uCharacter:K2_GetActorRotation(), true)
        print(bWriteLog and "Caller:TickParachuteComponent" .. uCharacter:K2_GetActorLocation():ToString())
        if Airplane and slua.isValid(uCharacter) then
          local MovementComponent = Airplane:GetComponentByClass(import("CharacterMovementComponent"))
          if MovementComponent ~= nil and slua.isValid(MovementComponent) then
            local EMovementMode = import("EMovementMode")
            MovementComponent:SetMovementMode(EMovementMode.MOVE_None, 0)
          end
          Airplane:SetLifeSpan(5)
        end
        self:SetViewTargetWithBlend(Airplane, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
        self:AddGameTimer(0.2, false, function()
          if slua.isValid(uCharacter) then
            self:SetViewTargetWithBlend(uCharacter, 0.5, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
          end
        end)
      else
        print(bWriteLog and "PlayerControllerBase:JumpPlanDell, GetAssetAsync failed when path")
      end
    end)
  end
end
function PlayerControllerBase:ProcessMotionInputFailed(bIsAddPitch, OutPitch, bIsAddYaw, OutYaw)
  if not bIsAddPitch and not bIsAddYaw then
    return
  end
  local VehicleUserComp = self:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComp) or not VehicleUserComp:CanUseGyro() then
    return
  end
  self:ProcessVehicleInput(OutPitch, OutYaw)
end
function PlayerControllerBase:MotionControliOS(AxisValue)
  self:MotionControlAndroid(AxisValue)
end
function PlayerControllerBase:MotionControlAndroid(AxisValue)
  if not Client.IsDeviceSupportGyrSensor() then
    print(bWriteLog and "PlayerControllerBase:MotionControlAndroid IsDeviceSupportGyrSensor false")
    return
  end
  local Pawn = self:K2_GetPawn()
  if not slua.isValid(Pawn) then
    if bWriteLog then
      print(bWriteLog and "PlayerControllerBase:MotionControlAndroid Pawn not Invalid")
    end
    return
  end
  if not self:GetUseMotionControlEnable() then
    if bWriteLog then
      print(bWriteLog and "PlayerControllerBase:MotionControlAndroid UseMotionControlEnable false")
    end
    return
  end
  local OutPitch = 0
  local OutYaw = 0
  local bIsAddPitch = false
  local bIsAddYaw = false
  if not self.CalInputFromRotaionRate then
    return
  end
  OutPitch, OutYaw, bIsAddPitch, bIsAddYaw = self:CalInputFromRotaionRate(OutPitch, OutYaw, bIsAddPitch, bIsAddYaw, AxisValue, self.PitchReverce, self.MotionTouchRate_Pitch, self.MotionTouchAimRate_Pitch, self.MotionRate_Pitch, self.MotionAimRate_Pitch, self.MotionTouchRate_Yaw, self.MotionTouchAimRate_Yaw, self.MotionRate_Yaw, self.MotionAimRate_Yaw, self.MotionRate_Pitch_Threshold, self.MotionRate_Yaw_Threshold, self.Left, self.Right, self.bLandScapeOrientation)
  if bIsAddPitch then
    Pawn:AddControllerPitchInput(OutPitch)
  end
  if bIsAddYaw then
    Pawn:AddControllerYawInput(OutYaw)
  end
end
PlayerControllerBase.ClientRPC.RPC_Client_ShowBattleGMOutputText = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function PlayerControllerBase:RPC_Client_ShowBattleGMOutputText(Content)
  ShowBattleGMOutputText(Content)
end
function PlayerControllerBase:ToString()
  if self.GetViewTarget then
    local ViewTarget = self:GetViewTarget()
    if slua.isValid(ViewTarget) then
      return string.format("%s(%s)", ViewTarget.PlayerName, ViewTarget.PlayerKey)
    end
  end
  return "<Invalid ViewTarget>"
end
function PlayerControllerBase:GetCurPlayerCharacterOrPetSpectator()
  if slua.isValid(self.Object) and self.IsInPetSpectator and self:IsInPetSpectator() and self.GetPetSpectatorComp and slua.isValid(self:GetPetSpectatorComp()) and slua.isValid(self:GetPetSpectatorComp().PetSpectatorPawn) then
    return self:GetPetSpectatorComp().PetSpectatorPawn
  elseif slua.isValid(self.Object) and self.GetCurPlayerCharacter then
    return self:GetCurPlayerCharacter()
  end
end
function PlayerControllerBase:GetStickLeftSize()
  local JoyStickCenter = self:GetJoyStickCenter()
  local UIUtil = require("client.common.ui_util")
  local ViewportSize = UIUtil.GetViewportSizebyScale()
  local DistanceToCentralAxis_Ratio = math.abs(0.5 - JoyStickCenter.X)
  print(bWriteLog and string.format("PlayerControllerBase:GetStickLeftSize x=%.2f, screenx=%.0f", DistanceToCentralAxis_Ratio, ViewportSize.X))
  if 0.3 <= DistanceToCentralAxis_Ratio then
    return FVector2D(DistanceToCentralAxis_Ratio, 1) * ViewportSize * 2
  else
    return FVector2D(0.3, 1) * ViewportSize * 2
  end
end
function PlayerControllerBase:MakeFireModeEffect()
  if not slua.isValid(self.Object) then
    return
  end
  local SuperData = self:GetSuperData()
  if self.IsUse3DTouch then
    SuperData.IsUse3DTouch = self:IsUse3DTouch()
  end
  local FireMode = self.fireMode
  if FireMode == 1 or FireMode == 2 then
    local SizeX = 200
    local SizeY = 200
    if self.GetStickLeftSize then
      local StickSize = self:GetStickLeftSize()
      SizeX = math.max(SizeX, StickSize.X)
      SizeY = math.max(SizeY, StickSize.Y)
    end
    self:SetJoyStickInteractionSize(FVector2D(SizeX, SizeY))
  elseif FireMode == 3 then
    self:RestoreDefaultInteractionSize(0)
  end
  self:BroadcastUIMessage("UIMsg_MakeFireModeEffect", 0, "", "")
end
function PlayerControllerBase:ReadConfigFromHUD()
  self.Super:ReadConfigFromHUD(self)
  local SuperData = self:GetSuperData()
  if self.IsUse3DTouch then
    SuperData.IsUse3DTouch = self:IsUse3DTouch()
  end
end
function PlayerControllerBase:InitCameraData()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BaseCameraConfig = GamePlayTools.GetCurrentConfig("BaseCameraConfig")
  local CameraOffsetData = import("CameraOffsetData")
  if slua.isValid(self.PlayerCameraManager) and BaseCameraConfig then
    for CameraStateTag, CameraStateData in pairs(BaseCameraConfig) do
      local NewCameraStateData = CameraOffsetData()
      NewCameraStateData.SocketOffset = CameraStateData.SocketOffset
      NewCameraStateData.TargetOffset = CameraStateData.TargetOffset
      NewCameraStateData.SpringArmLength = CameraStateData.SpringArmLength
      NewCameraStateData.AdditiveOffsetFov = CameraStateData.AdditiveOffsetFov
      NewCameraStateData.FixedFov = CameraStateData.FixedFov
      NewCameraStateData.BeginInterpSpeed = CameraStateData.BeginInterpSpeed
      NewCameraStateData.EndInterpSpeed = CameraStateData.EndInterpSpeed
      self.PlayerCameraManager:PushCameraDataConfigData(CameraStateTag, NewCameraStateData)
    end
  end
end
function PlayerControllerBase:RPC_ClientHUDDisplayHitDamage(nDamage, IsWeakShoot)
  local uHUD = self:GetHUD()
  if slua.isValid(uHUD) then
    uHUD:AddHitDamage(nDamage, IsWeakShoot, CDamageEvent(), nil, true)
  end
end
function PlayerControllerBase:OnCreateDecal(_, _, playerKey, DecalActor)
  if not slua.isValid(DecalActor) then
    log(bWriteLog and "  PlayerControllerBase:OnCreateDecal.  not slua.isValid(DecalActor)")
    return
  end
  self:RPC_Multicast_OnCreateDecal(DecalActor.DecalId)
end
function PlayerControllerBase:RPC_Multicast_OnCreateDecal(itemId)
  if not Client then
    return
  end
  log(bWriteLog and "  PlayerControllerBase:OnCreateDecal. itemId: " .. tostring(itemId))
  local passive_resource_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.passive_resource_downloader)
  passive_resource_downloader:CheckResourceHasBeenDownloaded({itemId})
end
function PlayerControllerBase:InitGrenadeAvatarList(ReInitial)
  if self.RolewearIndex >= 0 and self.RolewearIndex < self.InitialKnapsackExtInfo:Num() and ReInitial then
    self.InitialConsumableAvatar = self.InitialKnapsackExtInfo:Get(self.RolewearIndex).KnapsackExtInfo.ConsumableAvatarList
    print(bWriteLog and string.format("ASTExtraPlayerController::InitGrenadeAvatarList RolewearIndex=[%d], Shoulei=[%d], Smoke=[%d], Stun=[%d], Burn=[%d]", self.RolewearIndex, self.InitialConsumableAvatar.GrenadeAvatarShoulei, self.InitialConsumableAvatar.GrenadeAvatarSmoke, self.InitialConsumableAvatar.GrenadeAvatarStun, self.InitialConsumableAvatar.GrenadeAvatarBurn))
  end
  self.GrenadeAvatarItemList:Clear()
  self:AddToGrenadeAvatarItemList(self.InitialConsumableAvatar.GrenadeAvatarShoulei)
  self:AddToGrenadeAvatarItemList(self.InitialConsumableAvatar.GrenadeAvatarSmoke)
  self:AddToGrenadeAvatarItemList(self.InitialConsumableAvatar.GrenadeAvatarStun)
  self:AddToGrenadeAvatarItemList(self.InitialConsumableAvatar.GrenadeAvatarBurn)
end
function PlayerControllerBase:AddToGrenadeAvatarItemList(AvatarID)
  if AvatarID <= 0 then
    return
  end
  local UBackpackUtils = import("BackpackUtils")
  local DefineID = UBackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(AvatarID)
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  local ProtoItemID = AvatarUtil.GetThrowWeaponProtoItemID_Old(DefineID, self.Object)
  if ProtoItemID <= 0 then
    return
  end
  print(bWriteLog and "PlayerControllerBase:InitGrenadeAvatarList AddGrenadeAvatarItemList ProtoItemID:" .. tostring(ProtoItemID) .. " AvatarID:" .. tostring(AvatarID))
  self.GrenadeAvatarItemList:Add(ProtoItemID, AvatarID)
end
function PlayerControllerBase:ChangeWeaponAvatarList(BagIndex)
  if 0 <= BagIndex and BagIndex < self.InitialKnapsackExtInfo:Num() then
    local weaponList = self.InitialKnapsackExtInfo:Get(self.RolewearIndex).KnapsackExtInfo.WeaponList
    local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
    weaponList = AvatarDataUtil.FilterWeaponAttachments(self, weaponList, true)
    self.InitialWeaponAvatarList = weaponList
    self:InitWeaponAvatarItems()
    self:OnWeaponAvatarUpdate()
  end
end
function PlayerControllerBase:OnWeaponAvatarUpdate()
end
function PlayerControllerBase:OnPlayerKeyRepExt()
  print(bWriteLog and "PlayerControllerBase:OnPlayerKeyRepExt", self.PlayerKey)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_PLAYERKEY_CHANGE, self.Object)
end
function PlayerControllerBase:CanShowMyPet()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  local uPawn = self:GetPlayerCharacterSafety()
  if not (slua.isValid(uPawn) and uPawn.GetIsFPP) or not uPawn:GetIsFPP() then
    return settingConfig.OpenMyPet
  end
  return settingConfig.OpenMyPetFPP
end
function PlayerControllerBase:GetMapUIMarkManagerComponent()
  if not slua.isValid(self.MapUIMarkManagerComponent) then
    self.MapUIMarkManagerComponent = self:GetComponentByClass(import("MapUIMarkManager"))
  end
  return self.MapUIMarkManagerComponent
end
function PlayerControllerBase:SGetConsumableByXsuitAndGlider()
  local index = self.RolewearIndex
  local curInfo = self.InitialKnapsackExtInfo:Get(index)
  local info = curInfo.KnapsackExtInfo
  local VehicleUseConfig = CDataTable.GetTableData("VehicleUseConfig", info.ParachuteGlider)
  if not VehicleUseConfig then
    return
  end
  local SuitID_s = VehicleUseConfig.SuitID_s
  local allwear = self:GetClothingInAllBackpack(index)
  for _, v in pairs(allwear) do
    if SuitID_s:Get(v.DefineID.TypeSpecificID) then
      return VehicleUseConfig.Consumable
    end
  end
end
function PlayerControllerBase:GetCurWearTwoPersonAircraftID()
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  local GlideID = XSuitAvatarDataUtil:GetCurrentWearGlideID(self)
  local UAvatarUtils = import("AvatarUtils")
  if UAvatarUtils.IsTwoPersonAircraft(GlideID) then
    return GlideID
  else
    return -1
  end
end
function PlayerControllerBase:BindMotionEvent()
  local InputClass = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local WorldContextObject = UIUtil.GetGameInstance()
  self.ScreenInput = InputClass(WorldContextObject)
  self.ScreenInput:Init()
  self.ScreenInput.OnMotionDetected:Bind(self, "OnMotionDetected")
end
function PlayerControllerBase:UseModSkin(_, _, bUse)
  if not self.bModWeaponSkinCooldowning then
    self.bModWeaponSkinCooldowning = true
    print(bWriteLog and "PlayerControllerBase:UseModSkin")
    self:ServerRequestUseModWeaponSkin(bUse)
  end
end
function PlayerControllerBase:OnModWeaponSkinChange()
  print(bWriteLog and "PlayerControllerBase:OnModWeaponSkinChange", self.bUseModWeaponSkin)
  local Cooldown = 5
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ModWeaponConfig = GamePlayTools.GetCurrentConfig("ModWeaponConfig")
  if ModWeaponConfig and ModWeaponConfig.Cooldown then
    Cooldown = ModWeaponConfig.Cooldown
  end
  if self.bModWeaponSkinCooldowning then
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_COOLDOWN, Cooldown)
    self:AddGameTimer(Cooldown, false, function()
      self.bModWeaponSkinCooldowning = false
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_MOD_WEAPON_USE_SKIN_COOLDOWN_END)
    end)
  end
end
function PlayerControllerBase:ClientCallPartnerTips(TextID, FaceID, RichTextID, Param1)
  self:ClientCallSidePopupTips(TextID, FaceID, RichTextID, Param1, nil)
end
function PlayerControllerBase:ClientCallSidePopupTips(TextID, FaceID, RichTextID, Param1, Param2)
  local TableTemp = {
    TextID = TextID,
    FaceID = FaceID,
    RichTextID = RichTextID,
    Param1 = Param1,
      }
  self:ClientDisplayCustomLuaGameTips("ClientCallSidePopupTips", 0, slua.LuaArchiverEncode(LuaStateWrapper, TableTemp))
end
function PlayerControllerBase:FindBestSpectateTarget(MyTeammates, CurPlayerState, TeammatePlayerID)
  local ETeammateSpectatorResult = import("/Script/ShadowTrackerExtra.ETeammateSpectatorResult")
  local ExtraPlayerLiveState = import("/Script/ShadowTrackerExtra.ExtraPlayerLiveState")
  local Result = {
    bAllDie = true,
    bIsOnPlane = false,
    bHasSelf = false,
    bHasNullptr = false,
    TargetTeammate = nil,
    RetPlayerId = 0,
    FriendId = 0,
    TeammateResults = {}
  }
  local bIgnoreDying = self.bWatchTeammateIgnoreDying
  if bIgnoreDying then
    for _, OneTeammate in pairs(MyTeammates) do
      if slua.isValid(OneTeammate) and OneTeammate.LiveState ~= ExtraPlayerLiveState.InDied and OneTeammate.LiveState ~= ExtraPlayerLiveState.InDying then
        bIgnoreDying = false
        break
      end
    end
  end
  local LobbyWatchInfo = self.LobbyWatchInfo
  local ProcessOneTeammate = function(OneTeammate)
    if CurPlayerState == OneTeammate then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - CurPlayerState == OneTeammate Skip self")
      table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_MySelf)
      Result.bHasSelf = true
      return false
    end
    if not slua.isValid(OneTeammate) then
      Result.bAllDie = false
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - OneTeammate is nil")
      table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_Nullptr)
      Result.bHasNullptr = true
      return false
    end
    print(bWriteLog and string.format("PlayerControllerBase:FindBestSpectateTarget - teammate PlayerName=%s PlayerId=%d", tostring(OneTeammate.PlayerName), OneTeammate.PlayerId))
    if LobbyWatchInfo and LobbyWatchInfo.WatchedPlayerKey == OneTeammate.PlayerKey and LobbyWatchInfo.WatchedPlayerKey > 0 then
      Result.FriendId = OneTeammate.PlayerId
      print(bWriteLog and string.format("PlayerControllerBase:FindBestSpectateTarget - friendId=%d", Result.FriendId))
    end
    if TeammatePlayerID == 0 then
      if OneTeammate.LiveState == ExtraPlayerLiveState.InDied or OneTeammate.LiveState == ExtraPlayerLiveState.InDying and not bIgnoreDying then
        print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - LiveState not alive")
        table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_Died)
        return false
      end
    elseif not OneTeammate:IsAlive() then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - IsAlive false")
      table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_NotAlive)
      return false
    end
    if not OneTeammate:IsInGame() then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - not ingame")
      table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_NotInGame)
      return false
    end
    if not OneTeammate:CanBeSpectated() then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - CanBeSpectated false")
      return false
    end
    table.insert(Result.TeammateResults, ETeammateSpectatorResult.ETeammateSpectatorResult_Normal)
    Result.bAllDie = false
    Result.bIsOnPlane = OneTeammate.LiveState == ExtraPlayerLiveState.InPlane
    Result.TargetTeammate = OneTeammate
    Result.RetPlayerId = OneTeammate.PlayerId
    if TeammatePlayerID == OneTeammate.PlayerId then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - TeammatePlayerID == OneTeammate.PlayerId")
      return true
    end
    if TeammatePlayerID == 0 and LobbyWatchInfo and LobbyWatchInfo.WatchedPlayerKey == OneTeammate.PlayerKey and LobbyWatchInfo.WatchedPlayerKey > 0 then
      print(bWriteLog and "PlayerControllerBase:FindBestSpectateTarget - WatchPlayerKey == OneTeammate.PlayerKey")
      return true
    end
    return false
  end
  for _, OneTeammate in pairs(MyTeammates) do
    if ProcessOneTeammate(OneTeammate) then
      break
    end
  end
  return Result
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPlayerControllerBase = class(CActorBase, nil, PlayerControllerBase)
return require("combine_class").DeclareFeature(CPlayerControllerBase, {
  {
    IngameLikeFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerControllerIngameLikeFeature"
  },
  {
    CollectionTaskFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.CollectionTaskFeature"
  },
  {
    NewbieAssistFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.NewbieAssistFeature"
  },
  {
    ShowVehicleFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.ShowVehicleFeature"
  },
  {
    PlayEmoteFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.Emote.PlayEmoteFeature"
  },
  {
    CommerFeature = "GameLua.Activity.Commercialize.GamePlay.Feature.CommerFeature"
  },
  {
    ReportCrashKitFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.ReportCrashKitFeature"
  },
  {
    CoopEmotePCFeature = "GameLua.Activity.Commercialize.GamePlay.CoopEmote.CoopEmotePCFeature"
  },
  {
    SecurityNotifyPCFeature = "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"
  },
  {
    PlayerControllerFatalDamageFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.PlayerControllerFatalDamageFeature"
  },
  {
    OncePerGameAkEventFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.OncePerGameAkEventFeature"
  },
  {
    MLAIVoiceFeature = "GameLua.Mod.BaseMod.Gameplay.AI.MLAIVoiceFeature"
  }
}, "PlayerControllerBase")
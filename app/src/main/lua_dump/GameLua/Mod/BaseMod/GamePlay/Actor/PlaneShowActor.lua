local PlaneShowActor = {
  AvatarLevleThIDs = {
    [1406385] = true,
    [1406386] = true,
    [1406387] = true,
    [1406388] = true,
    [1406389] = true
  }
}
local EAttachmentRule = import("EAttachmentRule")
local KismetSystemLibrary = import("KismetSystemLibrary")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local PlaneActorForShowClassPath = "/Game/BluePrints/Plane/BP_PlaneCharacter_ForShow.BP_PlaneCharacter_ForShow_C"
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
function PlaneShowActor:ctor()
  PlaneShowActor.__super.ctor(self)
  self.CacheNearClip = nil
  self.LevelSeqActor = nil
  self.CabinShowActors = {}
end
function PlaneShowActor:ReceiveBeginPlay()
  print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent ReceiveBeginPlay")
  print(bWriteLog and "PlaneShowActor:ReceiveBeginPlay")
  PlaneShowActor.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_HIDE, self.HidePlaneMesh, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_SHOW, self.ShowPlaneMesh, self)
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPostViewTargetChangeDelegate", self.OnViewTargetChange, self)
  end
  self:Reset()
end
function PlaneShowActor:Reset()
  self.SeqOnStopDel = nil
  self.SeqOnFinishedDel = nil
  self.PlaneActor = nil
  self.bHasStop = false
  self.PlaneActorForShow = nil
  self.InitShowCameraCabin = false
  self:CleanupCabinShowActors()
  self.SeqSpawnActors = nil
  self.SeqLightActors = nil
  self.CloseChildren = nil
  self.SingleRoles = nil
end
function PlaneShowActor:ReceiveEndPlay(EndReason, bClearTable)
  print(bWriteLog and "PlaneShowActor:ReceiveEndPlay()")
  self:SeqEndShow()
  self:UnloadUI()
  self:CleanupCabinShowActors()
  self:Reset()
  if slua.isValid(self.LevelSeqActor) then
    self.LevelSeqActor:GoToEndAndStop()
    print(bWriteLog and "PlaneShowActor:ReceiveEndPlay() self.LevelSeqActor:GoToEndAndStop")
    self.LevelSeqActor:K2_DestroyActor()
  end
  if slua.isValid(self.ActorSequence) and slua.isValid(self.ActorSequence.SequencePlayer) then
    self.ActorSequence.SequencePlayer:Stop()
  end
  PlaneShowActor.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function PlaneShowActor:PlaySeq(RealPlaneActor, Config)
  print(bWriteLog and "PlaneShowActor:PlaySeq")
  self.bNeedUIAnim = true
  self.State  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    self.ShowCameraCabin = not SettingSubsystem:GetUserSettings_Bool("PlaneNotShowCabin")
  end
  self.ShowPlaneHidden = false
  print(bWriteLog and "PlaneShowActor:PlaySeq dell ShowCameraCabin:" .. tostring(self.ShowCameraCabin))
  if slua.isValid(RealPlaneActor) then
    self.PlaneActor = RealPlaneActor
    self:SetPlaneActorForShow()
  end
  local PlatName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if PlatName == DevicePlatformNameMacros.Android or PlatName == DevicePlatformNameMacros.Windows then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) and uPlayerController.IsInPlane and uPlayerController:IsInPlane() then
      print(bWriteLog and "PlaneShowActor:PlaySeq Set bUsetoControlNearClip")
      local GameEventListener = uPlayerController.BP_GameEventListener
      if slua.isValid(GameEventListener) then
        self.CacheNearClip = GameEventListener.bUsetoControlNearClip
        if GameEventListener.bUsetoControlNearClip then
          GameEventListener.bUsetoControlNearClip = false
        end
      end
    end
  end
  if slua.isValid(self.PlaneActor) and self:CanPlaySeq() then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_HIDE, self)
    self:AttachToPlane(self.PlaneActor)
    self:BindCamera(true)
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerControllerStateChanged, self)
    end
    if RealPlaneActor and RealPlaneActor.PlayOrStopAudio then
      RealPlaneActor:PlayOrStopAudio(false)
    end
    self:HandlePlaneSkin()
    self:HandleAliasEnterBroadcast(Config)
    self:HandleWingman()
    local CurTime = Config.InnerTime or 0
    if 0 <= CurTime then
      print(bWriteLog and "PlaneShowActor:PlaySeq, CurTime = ", CurTime)
      self.ActorSequence.SequencePlayer:SetPlaybackPosition(CurTime)
      self.ActorSequence.SequencePlayer:Play()
      self.LevelSeqActor = self:InitLevelSeq(RealPlaneActor, Config)
      if slua.isValid(self.LevelSeqActor) then
        self.LevelSeqActor:Play(CurTime)
      else
        print(bWriteLog and "LevelSeqActor:PlaySeq  Error")
      end
      if CGameState and self.StateConfig.AudioPathByTeammate then
        self.AudioPlayStartTime = slua.GetUtcUnixMilliSeconds() - CurTime * 1000
        local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
        self.AudioPlayPath = self.StateConfig.AudioPathByTeammate[1]
        if ConfigDrivePlaneShowSubsystem then
          local TeamMateInfo = ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
          if TeamMateInfo and 0 < #TeamMateInfo then
            self.AudioPlayPath = self.StateConfig.AudioPathByTeammate[#TeamMateInfo]
          end
        end
        self:PlayOrStopShowPlaneAudio(true)
      end
      return true
    end
  else
    print(bWriteLog and "PlaneShowActor:PlaySeq(Plane) should not play seq")
  end
  return false
end
function PlaneShowActor:PlayOrStopShowPlaneAudio(bPlay)
  print(bWriteLog and "PlaneShowActor:PlayOrStopShowPlaneAudio bPlay:" .. tostring(bPlay))
  if bPlay and self.AudioPlayStartTime and self.AudioPlayPath then
    local util = require("client.slua_ui_framework.util")
    util.GetAssetAsync(self.AudioPlayPath, function(akEvent)
      if akEvent and CGameState and self.AudioPlayStartTime then
        local StartTime = slua.GetUtcUnixMilliSeconds() - self.AudioPlayStartTime
        local AkGameplayStatics = import("AkGameplayStatics")
        if self.AudioPlayAudioID and self.AudioPlayAudioID ~= 0 then
          local audio_util = require("client.common.audio_util")
          audio_util.StopSound(self.AudioPlayAudioID)
          self.AudioPlayAudioID = 0
          print(bWriteLog and "PlaneShowActor:PlayOrStopShowPlaneAudio stop")
        end
        print(bWriteLog and "PlaneShowActor:PlayOrStopShowPlaneAudio play:" .. self.AudioPlayPath)
        self.AudioPlayAudioID = AkGameplayStatics.PostEvent(akEvent, self.Object, true, "")
        if StartTime and StartTime ~= 0 then
          AkGameplayStatics.SeekOnEvent(akEvent, self.Object, math.floor(StartTime), "", false)
        end
      end
    end)
  elseif self.AudioPlayAudioID and self.AudioPlayAudioID ~= 0 then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.AudioPlayAudioID)
    self.AudioPlayAudioID = 0
  end
end
function PlaneShowActor:OnPlayerControllerStateChanged(CurStateType)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local EStateType = import("EStateType")
    if CurStateType == EStateType.State_ParachuteJump then
      self:StopSeq()
    elseif CurStateType == EStateType.State_ParachuteOpen then
      self:StopSeq()
    elseif CurStateType == EStateType.State_Fight then
      self:StopSeq()
    end
  end
end
function PlaneShowActor:StopSeq(RealPlaneActor, Config)
  print(bWriteLog and "PlaneShowActor:StopSeq()")
  self:BindCamera(false)
  if not self.bHasStop then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_SHOW, self)
    self.bHasStop = true
    self:ProcessUnrelatedUI(true)
    self:UnloadUI()
    if RealPlaneActor and RealPlaneActor.PlayOrStopAudio then
      RealPlaneActor:PlayOrStopAudio(true)
    end
    if slua.isValid(self.PlaneActor) and self.PlaneActor.WingPlaneComponent_BP and self.PlaneActor.WingPlaneComponent_BP.OnEgyptPlaneShow then
      self.PlaneActor.WingPlaneComponent_BP:OnEgyptPlaneShow()
    end
    local PlatName = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if PlatName == DevicePlatformNameMacros.Android or PlatName == DevicePlatformNameMacros.Windows then
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      if slua.isValid(uPlayerController) then
        local GameEventListener = uPlayerController.BP_GameEventListener
        if slua.isValid(GameEventListener) and self.CacheNearClip ~= nil then
          GameEventListener.bUsetoControlNearClip = self.CacheNearClip
          self.CacheNearClip = nil
        end
      end
    end
  end
end
function PlaneShowActor:ProcessUnrelatedUI(bShow)
  print(bWriteLog and "PlaneShowActor:ProcessUnrelatedUI", bShow)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  if bShow then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_SHOW, self)
    UAESequenceUtils:RecoveryUI()
  else
    EventSystem:postEventSafety(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_MAP)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_HIDE, self)
    UAESequenceUtils:HideAllUI()
  end
end
function PlaneShowActor:ShowUIPanel()
  print(bWriteLog and "PlaneShowActor:ShowUIPanel")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectatorOrDemoPlayer and uPlayerController:IsSpectatorOrDemoPlayer() then
    print(bWriteLog and "PlaneShowActor: IsSpectator")
    return
  end
  local ViewSwitchPanelConfig = UIManager.UI_Config_InGame.PlaneShowBestViewSwitch
  if ViewSwitchPanelConfig then
    local ViewSwitchPanel = UIManager.ShowUI(ViewSwitchPanelConfig, self.Object, self.StateConfig.PlaneShowUIType)
  end
  local ViewSwitchClosePanelConfig = UIManager.UI_Config_InGame.PlaneShowCloseViewSwitch
  if ViewSwitchClosePanelConfig then
    local ViewSwitchClosePanelConfig = UIManager.ShowUI(ViewSwitchClosePanelConfig, self.Object, self.StateConfig.PlaneShowUIType)
  end
end
function PlaneShowActor:UnloadUI()
  print(bWriteLog and "PlaneShowActor:UnloadUI")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsSpectatorOrDemoPlayer and uPlayerController:IsSpectatorOrDemoPlayer() then
    print(bWriteLog and "PlaneShowActor: IsSpectator")
    return
  end
  local ViewSwitchPanelConfig = UIManager.UI_Config_InGame.PlaneShowBestViewSwitch
  if ViewSwitchPanelConfig then
    local ViewSwitchPanel = UIManager.CloseUI(ViewSwitchPanelConfig)
  end
  local ViewSwitchClosePanelConfig = UIManager.UI_Config_InGame.PlaneShowCloseViewSwitch
  if ViewSwitchClosePanelConfig then
    local ViewSwitchClosePanelConfig = UIManager.CloseUI(ViewSwitchClosePanelConfig)
  end
end
function PlaneShowActor:UISelectView(bIsBind)
  print(bWriteLog and " PlaneShowActor:UISelectView", bIsBind)
  if self.StateConfig.PlaneShowUIType == 2 then
    if self.CanCameraCabinDell and self.CanCameraCabinDell == "StartCanChangeCamera" then
      print(bWriteLog and "PlaneShowActor:UISelectView BindCamera")
      self:BindCamera(bIsBind)
      if not bIsBind then
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANESHOW_CHANGE_STATIC, self)
      end
    elseif not self.CanCameraCabinDell or self.CanCameraCabinDell ~= "stop" then
      self.ShowCameraCabin = bIsBind
      print(bWriteLog and "PlaneShowActor:UISelectView dell ShowCameraCabin:" .. tostring(self.ShowCameraCabin))
    end
  else
    self:BindCamera(bIsBind)
  end
end
function PlaneShowActor:BindCamera(bIsBind)
  print(bWriteLog and " PlaneShowActor:BindCamera", bIsBind)
  local PlatName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if not slua.isValid(self.PlaneActor) then
    return
  end
  local CameraComp = self.PlaneActor:GetComponentByClass(import("/Script/Engine.CameraComponent"))
  if not slua.isValid(CameraComp) then
    return
  end
  local OriginSpringArm = self.PlaneActor:GetComponentByClass(import("/Script/Engine.SpringArmComponent"))
  if not slua.isValid(OriginSpringArm) then
    return
  end
  CameraComp:K2_DetachFromComponent(EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
  if bIsBind then
    self:ProcessUnrelatedUI(false)
    CameraComp:K2_AttachToComponent(self.Camera, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
    OriginSpringArm:SetActive(false, false)
    print(bWriteLog and "OriginSpringArm:SetActive BindCamera false")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:SetDisableTouchMoveInput(true)
      uPlayerController:ShowTouchInterface(false)
    end
    if PlatName == DevicePlatformNameMacros.Android or PlatName == DevicePlatformNameMacros.Windows then
      KismetSystemLibrary.ExecuteConsoleCommand(self, "r.SetNearClipPlane 3", nil)
    end
    if slua.isValid(self.PlaneActor) and self.PlaneActor.PlayOrStopAudio then
      self.PlaneActor:PlayOrStopAudio(false)
    end
    self:PlayOrStopShowPlaneAudio(true)
    if slua.isValid(self.PlaneActor) and slua.isValid(self.PlaneActor.WingPlaneComponent_BP) and self.PlaneActor.WingPlaneComponent_BP.OnEgyptPlaneShow then
      self.PlaneActor.WingPlaneComponent_BP:OnEgyptPlaneShow(true)
    end
    print(bWriteLog and "PlaneShowActor:BindCamera")
  else
    self:ProcessUnrelatedUI(true)
    CameraComp:K2_AttachToComponent(OriginSpringArm, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
    OriginSpringArm:SetActive(true, true)
    print(bWriteLog and "OriginSpringArm:SetActive BindCamera true")
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerController:SetDisableTouchMoveInput(false)
      if uPlayerController:IsInPlane() or not GameStatus.IsInFightingStatus() then
        uPlayerController:ShowTouchInterface(false)
      end
    end
    if slua.isValid(self.PlaneActor) and self.PlaneActor.PlayOrStopAudio then
      self.PlaneActor:PlayOrStopAudio(true)
    end
    self:PlayOrStopShowPlaneAudio(false)
    if slua.isValid(self.PlaneActor) and self.PlaneActor.WingPlaneComponent_BP and self.PlaneActor.WingPlaneComponent_BP.OnEgyptPlaneShow then
      self.PlaneActor.WingPlaneComponent_BP:OnEgyptPlaneShow()
    end
    if (PlatName == DevicePlatformNameMacros.Android or PlatName == DevicePlatformNameMacros.Windows) and slua.isValid(uPlayerController) and uPlayerController:IsInPlane() then
      KismetSystemLibrary.ExecuteConsoleCommand(self, "r.SetNearClipPlane 230", nil)
    end
    print(bWriteLog and "PlaneShowActor:UNBindCamera")
  end
  self:ChangeCameraCabinDell(bIsBind)
end
function PlaneShowActor:AttachToPlane(Plane)
  print(bWriteLog and "PlaneShowActor:AttachToPlane", Plane)
  if slua.isValid(Plane) and slua.isValid(Plane.CapsuleComponent) then
    self:K2_AttachToComponent(Plane.CapsuleComponent, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
    print(bWriteLog and "PlaneShowActor:AttachToPlane2", Plane)
  end
end
function PlaneShowActor:HidePlaneMesh()
  print(bWriteLog and "PlaneShowActor:HidePlaneMesh")
  if slua.isValid(self.Object) then
    print(bWriteLog and "PlaneShowActor:HidePlaneMesh 1")
    self:SetActorHiddenInGame(false)
  end
end
function PlaneShowActor:ShowPlaneMesh()
  print(bWriteLog and "PlaneShowActor:ShowPlaneMesh")
  if slua.isValid(self.Object) then
    print(bWriteLog and "PlaneShowActor:ShowPlaneMesh 1")
    self:SetActorHiddenInGame(true)
  end
end
function PlaneShowActor:CanPlaySeq()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) and self.ActorSequence then
    local CurTime = uGameState:GetServerWorldTimeSeconds()
    local PastInterval = CurTime - (uGameState.StartFlyTime > 0 and uGameState.StartFlyTime or CurTime)
    print(bWriteLog and "PlaneShowActor:CanPlaySeq(), ", CurTime, uGameState.StartFlyTime, PastInterval, self.ActorSequence:GetLength())
    if PastInterval <= self.ActorSequence:GetLength() then
      return true
    end
  end
  print(bWriteLog and "PlaneShowActor:CanPlaySeq() NOOO")
  return false
end
function PlaneShowActor:GetCurFightingTime()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    local CurTime = uGameState:GetServerWorldTimeSeconds()
    local PastInterval = CurTime - (uGameState.StartFlyTime > 0 and uGameState.StartFlyTime or CurTime)
    return FuncUtil.Clamp(PastInterval, 0, self.ActorSequence:GetLength())
  end
  return 0
end
function PlaneShowActor:IsPlaying()
  if self.ActorSequence and self.ActorSequence.SequencePlayer then
    return self.ActorSequence.SequencePlayer:IsPlaying()
  end
  return false
end
function PlaneShowActor:GetWingmanAttachComp(Index)
  if Index == 1 then
    Index = 2
  elseif Index == 2 then
    Index = 1
  end
  if slua.isValid(self.Object) then
    local uComp = self["WingmanPos" .. tostring(Index)]
    return uComp
  end
  return nil
end
function PlaneShowActor:IsWingmanPosEnable()
  if slua.isValid(self.Object) then
    local uComp1 = self["WingmanPos" .. tostring(1)]
    local uComp2 = self["WingmanPos" .. tostring(2)]
    if uComp1 and uComp2 then
      return true
    end
  end
  return false
end
function PlaneShowActor:HandleWingman()
  if self:IsWingmanPosEnable() and slua.isValid(self.PlaneActorForShow) and self.PlaneActorForShow.ShowWingman then
    self.PlaneActorForShow:ShowWingman()
  end
  if slua.isValid(self.PlaneActor) and slua.isValid(self.PlaneActor.WingPlaneComponent_BP) and self.PlaneActor.WingPlaneComponent_BP.OnEgyptPlaneShow then
    self.PlaneActor.WingPlaneComponent_BP:OnEgyptPlaneShow(true)
  end
end
function PlaneShowActor:SetPlaneActorForShow()
  local CChildComponent = import("ChildActorComponent")
  local ShowActorClass = import(PlaneActorForShowClassPath)
  if not CChildComponent or not ShowActorClass then
    return
  end
  local uComponentArray = self:GetComponentsByClass(CChildComponent)
  for _, uComp in pairs(uComponentArray) do
    if slua.isValid(uComp) and slua.isValid(uComp.ChildActor) and Game:IsClassOf(uComp.ChildActor, ShowActorClass) then
      self.PlaneActorForShow = uComp.ChildActor
      if slua.isValid(self.PlaneActor) and slua.isValid(self.PlaneActorForShow) and self.PlaneActorForShow.SetRealPlaneActor then
        self.PlaneActorForShow:SetRealPlaneActor(self.PlaneActor)
      end
    end
  end
end
function PlaneShowActor:HandlePlaneSkin()
  self.GetSkinTimer = self:AddGameTimer(0.1, true, function()
    local TopInfo
    if slua.isValid(self.PlaneActorForShow) and self.PlaneActorForShow.ShowPlaneSkin then
      TopInfo = self.PlaneActorForShow:ShowPlaneSkin()
    end
    if TopInfo then
      print(bWriteLog and "PlaneShowActor:HandlePlaneSkin TopInfo:", TopInfo)
      if self.GetSkinTimer then
        Game:ClearTimer(self.GetSkinTimer)
        self.GetSkinTimer = nil
      end
      local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
      local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
      local PlaneShowConfig = ConfigDrivePlaneShowSubsystem.GetCurrentConfig and ConfigDrivePlaneShowSubsystem:GetCurrentConfig()
      local uMyController = GameplayData.GetPlayerController()
      local bIsHawkEyeSpectator = slua.isValid(uMyController) and uMyController.IsHawkEyeSpectator and uMyController:IsHawkEyeSpectator()
      if PlaneShowConfig and PlaneShowConfig.EnableSkinTipsUI and not ClientGameMain.IsReplayClient() and not bIsHawkEyeSpectator then
        if UIManager.IsUIShow(UIManager.UI_Config.BattlePopWeakTips) then
          print(bWriteLog and "PlaneShowActor:HandlePlaneSkin(),IsUIShow(UIManager.UI_Config.BattlePopWeakTips)==true, PlaneSkinUI Not Show")
          return
        end
        print(bWriteLog and "PlaneShowActor:HandlePlaneSkin(),IsUIShow(UIManager.UI_Config.BattlePopWeakTips)==false, ShowPlaneSkinUI")
        local ItemID = 0
        if TopInfo and TopInfo.planeAvatarId then
          ItemID = TopInfo.planeAvatarId
        end
        if ItemID and 0 < ItemID and ItemID ~= 1801101 then
          UIManager.ShowUI(UIManager.UI_Config_InGame.PlaneShowSkinTipsUI, TopInfo)
        end
        print(bWriteLog and "PlaneShowActor:HandlePlaneSkin TopInfo.planeAvatarId:", tostring(ItemID))
      end
    end
  end)
end
function PlaneShowActor:HandleAliasEnterBroadcast(Config)
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if not ConfigDrivePlaneShowSubsystem then
    print(bWriteLog and "PlaneShowActor:HandleAliasEnterBroadcast - ConfigDrivePlaneShowSubsystem is nil")
    return
  end
  if Config == nil then
    Config = ConfigDrivePlaneShowSubsystem.GetCurrentConfig and ConfigDrivePlaneShowSubsystem:GetCurrentConfig()
  end
  ConfigDrivePlaneShowSubsystem:HandleAliasEnterBroadcast(Config)
end
function PlaneShowActor:CheckAndReportDailyFirstPlaneShow()
  print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow")
  if not Client then
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - Skip on server side")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsFirstTime = PlayerPrefsSystem.CheckAndSaveCurrentDate(PlayerPrefsSystem.ePlayerPrefsType.eShowAirPlaneInfo.path, PlayerPrefsSystem.ePlayerPrefsType.eShowAirPlaneInfo.needOpenIDTag, true, 1)
  if not bIsFirstTime then
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - Not first time today")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - PlayerState not found")
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - SettingSubsystem not found")
    return
  end
  local bPlaneNotShowCabin = SettingSubsystem:GetUserSettings_Bool("PlaneNotShowCabin")
  if bPlaneNotShowCabin then
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - Report Tlog 2030 (PlaneNotShowCabin=true)")
    PlayerState:RPC_ServerAddGeneralCount(11850, 1, false)
  else
    print(bWriteLog and "PlaneShowActor:CheckAndReportDailyFirstPlaneShow - Report Tlog 2029 (PlaneNotShowCabin=false)")
    PlayerState:RPC_ServerAddGeneralCount(11849, 1, false)
  end
  PlayerPrefsSystem.CheckAndSaveCurrentDate(PlayerPrefsSystem.ePlayerPrefsType.eShowAirPlaneInfo.path, PlayerPrefsSystem.ePlayerPrefsType.eShowAirPlaneInfo.needOpenIDTag, false, 1)
end
function PlaneShowActor:InitLevelSeq(RealPlaneActor, Config)
  print(bWriteLog and "PlaneShowActor:InitLevelSeq")
  local LevelSeq = Config.LevelSeq
  local LevelSeqBindKey = Config.LevelSeqBindKey
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if ConfigDrivePlaneShowSubsystem and Config.bNeedShowLobbyPawn and Config.LevelSeqBindKeyByTeammate then
    local TeamMateInfo = ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
    self:CheckAndReportDailyFirstPlaneShow()
    if TeamMateInfo and 0 < #TeamMateInfo and Config.LevelSeqBindKeyByTeammate[#TeamMateInfo] then
      LevelSeqBindKey = Config.LevelSeqBindKeyByTeammate[#TeamMateInfo]
    end
  end
  if Config and LevelSeq and LevelSeqBindKey then
    print(bWriteLog and "PlaneShowActor:InitLevelSeq Config.LevelSeq:", Config.LevelSeq, "LevelSeqBindKey:", LevelSeqBindKey)
    local SequenceTransform = FTransform()
    SequenceTransform:SetLocation(self:K2_GetActorLocation())
    self.SingleRoles = {}
    if Config.bNeedShowLobbyPawn then
      self.SingleRoles = self:GetTeamMateList(Config)
      if Config.LevelSeqPathByTeammate and Config.LevelSeqPathByTeammate[#self.SingleRoles] and 0 < #self.SingleRoles then
        LevelSeq = Config.LevelSeqPathByTeammate[#self.SingleRoles]
      end
    end
    local BindList = {
      [LevelSeqBindKey] = self.Object
    }
    local PawnIndex = 1
    for key, value in pairs(self.SingleRoles) do
      if Config.LobbyPawnBindKey and PawnIndex <= #Config.LobbyPawnBindKey then
        BindList[Config.LobbyPawnBindKey[PawnIndex]] = value
        self:DellCreateOrBindActor(Config.LobbyPawnBindKey[PawnIndex], value)
      end
      PawnIndex = PawnIndex + 1
    end
    if Config.BindRealPlaneKey then
      BindList[Config.BindRealPlaneKey] = RealPlaneActor
    end
    if Config.LevelSeqDirectionalLightBindKey then
      local UGameplayStatics = import("GameplayStatics")
      local uActor = import("/Script/Engine.Actor")
      local UIUtil = require("client.common.ui_util")
      local uGameInstance = UIUtil.GetGameInstance()
      local uDirectionalLightClass = import("/Script/Engine.DirectionalLight")
      local directionalLightActors = UGameplayStatics.GetAllActorsOfClass(uGameInstance, uDirectionalLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
      local world = slua_GameFrontendHUD:GetWorld()
      for _, v in pairs(directionalLightActors) do
        if slua.isValid(v) then
          self.PlaneShow_DirectionalLight = Game:CGameDuplicateActor(v, self.Object, Config.LevelSeqDirectionalLightBindKey, true)
          BindList[Config.LevelSeqDirectionalLightBindKey] = self.PlaneShow_DirectionalLight
          self:DellCreateOrBindActor(Config.LevelSeqDirectionalLightBindKey, self.PlaneShow_DirectionalLight)
          self:ChangeSeqLightVisable(false)
          break
        end
      end
    end
    local LevelSeqActor = Game:PlayLevelSequence(self, LevelSeq, SequenceTransform, nil, false, BindList)
    if slua.isValid(LevelSeqActor) then
      LevelSeqActor:SetOnSequenceEventMessageCallBack(self.OnSeqMeg, self.Object)
      LevelSeqActor:SetOnSequenceFinishedCallBack(self.SeqEndShow, self.Object)
      if slua.isValid(LevelSeqActor.SequencePlayer) then
        print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent 1")
        self:AddControlEvent(LevelSeqActor.SequencePlayer, "OnObjectSpawnedEvent", self.OnObjectSpawnedEvent, self)
      else
        print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent reg 1")
        LevelSeqActor:SetOnSequencePlayerReceiveInitailizePlayerCallBack(self.ReceiveInitailize, self.Object)
      end
    end
    self:AddGameTimer(2, false, function()
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_ACTOR_SHOW_BEGIN)
    end)
    return LevelSeqActor
  end
  return nil
end
function PlaneShowActor:ReceiveInitailize(LevelSeqActor)
  print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent ReceiveInitailize")
  if slua.isValid(LevelSeqActor.SequencePlayer) then
    print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent 1")
    self:AddControlEvent(LevelSeqActor.SequencePlayer, "OnObjectSpawnedEvent", self.OnObjectSpawnedEvent, self)
  end
end
function PlaneShowActor:SeqEndShow()
  print(bWriteLog and "PlaneShowActor:SeqEndShow")
  self.CanCameraCabinDell = "stop"
  self:OpenSceneDirectionalLight()
  if self.PlaneActor and slua.isValid(self.PlaneActor) then
    local CameraComp = self.PlaneActor:GetComponentByClass(import("/Script/Engine.CameraComponent"))
    local OriginSpringArm = self.PlaneActor:GetComponentByClass(import("/Script/Engine.SpringArmComponent"))
    if slua.isValid(OriginSpringArm) and slua.isValid(CameraComp) then
      CameraComp:K2_AttachToComponent(OriginSpringArm, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
      OriginSpringArm:SetActive(true, true)
    end
    self.PlaneActor:SetActorHiddenInGame(false)
  end
  self:ChangeCameraBack()
  if self.SingleRoles then
    for key, value in pairs(self.SingleRoles) do
      if slua.isValid(value) then
        value:K2_DestroyActor()
      end
    end
  end
  self:HideNamePanel()
  self:HideAllOpenPanel()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetDisableTouchMoveInput(false)
    print(bWriteLog and "PlaneShowActor:SeqEndShow SetDisableTouchMoveInput false")
    if uPlayerController:IsInPlane() or not GameStatus.IsInFightingStatus() then
      uPlayerController:ShowTouchInterface(false)
    end
  end
  if self.PlaneShow_DirectionalLight and slua.isValid(self.PlaneShow_DirectionalLight) then
    self.PlaneShow_DirectionalLight:K2_DestroyActor()
    self.PlaneShow_DirectionalLight = nil
    print(bWriteLog and "PlaneShowActor:SeqEndShow light nil")
  end
  self.SeqSpawnActors = nil
  self.SeqLightActors = nil
  self.CloseChildren = nil
  self.SingleRoles = nil
end
function PlaneShowActor:CloseSceneDirectionalLight()
  print(bWriteLog and "PlaneShowActor:CloseSceneLight")
  local UGameplayStatics = import("GameplayStatics")
  local uActor = import("/Script/Engine.Actor")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  local uDirectionalLightClass = import("/Script/Engine.DirectionalLight")
  local directionalLightActors = UGameplayStatics.GetAllActorsOfClass(uGameInstance, uDirectionalLightClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
  self:OpenSceneDirectionalLight()
  for _, v in pairs(directionalLightActors) do
    if v.LightComponent:IsVisible() and not v:ActorHasTag("SequencerActor") then
      v.LightComponent:SetVisibility(false, true)
      table.insert(self.SceneDirectionalLights, v)
    end
  end
end
function PlaneShowActor:OpenSceneDirectionalLight()
  print(bWriteLog and "PlaneShowActor:OpenSceneDirectionalLight")
  if self.SceneDirectionalLights then
    for index, value in ipairs(self.SceneDirectionalLights) do
      if slua.isValid(value) and value.LightComponent then
        value.LightComponent:SetVisibility(true, true)
      end
    end
  end
  self.SceneDirectionalLights = {}
end
function PlaneShowActor:OnSeqMeg(LevelSequenceActor, MsgName, Param1, Param2, Param3)
  print(bWriteLog and "PlaneShowActor:OnSeqMeg" .. MsgName .. " self.ShowCameraCabin" .. tostring(self.ShowCameraCabin) .. Param1)
  if Client and slua.isValid(LevelSequenceActor) and LevelSequenceActor == self.LevelSeqActor then
    if MsgName == "ShowNamePanel" then
      if self.ShowCameraCabin then
        local ShowData = {TeamNum = Param1, ShowItemIndex = Param2}
        self:ShowNamePanel(ShowData)
      end
    elseif MsgName == "HideNamePanel" then
      self:HideNamePanel()
    elseif MsgName == "ShowPanel" and Param1 and UIManager.UI_Config[Param1] then
      if not self.ShowCameraCabin then
        return
      end
      local ShowUI = UIManager.GetUI(UIManager.UI_Config[Param1])
      local ShowData
      if self.ShowCameraCabin and Param2 and Param3 then
        ShowData = {
          TeamNum = Param2,
          ShowItemIndex = Param3,
          FromPlaneShowPanel = true
        }
      end
      if ShowUI == nil then
        UIManager.ShowUI(UIManager.UI_Config[Param1], ShowData)
        if not self.OpenUITable then
          self.OpenUITable = {}
        end
        self.OpenUITable[#self.OpenUITable + 1] = UIManager.UI_Config[Param1]
      elseif ShowUI.UpdateShowInfo then
        ShowUI:UpdateShowInfo(ShowData)
      end
    elseif MsgName == "ClosePanel" and Param1 and UIManager.UI_Config[Param1] then
      UIManager.CloseUI(UIManager.UI_Config[Param1])
    elseif MsgName == "StartWind" then
      if self.ShowCameraCabin then
        self:StartWind(Param1)
      end
    elseif MsgName == "OpenSceneDirectionalLight" then
      self:OpenSceneDirectionalLight()
      self:ChangeSeqLightVisable(false)
    elseif MsgName == "ChangeCameraBack" then
      if self.ShowCameraCabin or Param1 == "Force" then
        self:ChangeCameraBack()
      end
    elseif MsgName == "CanCameraCabinDell" then
      self.CanCameraCabinDell = Param1
      if Param1 == "StartCanChangeCamera" then
        if not self.ShowCameraCabin then
          self.bNeedUIAnim = false
          self:BindCamera(self.ShowCameraCabin)
          self.bNeedUIAnim = true
          EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANESHOW_CHANGE_STATIC, self)
        else
          self:CloseSceneDirectionalLight()
          self:ChangeSeqLightVisable(true)
          self.bNeedUIAnim = false
          self:ChangeCameraDellViewTarget(true)
          self.bNeedUIAnim = true
        end
        EventSystem:postEventSafety(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_MAP)
      end
    elseif MsgName == "PlayEffect" then
      local CurShowCameraCabin = self.ShowCameraCabin
      if Param2 and Param2 == "Force" then
        self:ShowChangeCameraViewEffect("Ani_BlackFade")
      elseif CurShowCameraCabin then
        self:PlayEffect(Param1)
      end
    elseif MsgName == "ShowActor" then
      if self.ShowCameraCabin then
        self:ShowActor(Param1, Param2)
      end
    elseif MsgName == "PlaneShowActor" then
      if Param1 == "hide" then
        self.ShowPlaneHidden = true
        if self.ShowCameraCabin then
          self:SetActorHiddenInGame(true)
        end
      elseif Param1 == "show" then
        self.ShowPlaneHidden = false
        if self.ShowCameraCabin then
          self:SetActorHiddenInGame(false)
        end
      end
    elseif MsgName == "ShowCabinItem" then
      if self.ShowCameraCabin then
        local PawnIndex = tonumber(Param1) or 1
        self:ShowCabinItemForPawn(PawnIndex)
      end
    elseif MsgName == "HideCabinItem" then
      self:HideCabinItemForPawn(tonumber(Param1) or 0)
    end
  end
end
function PlaneShowActor:ShowActor(Param1, Param2)
  if self.ShowCameraCabin and Param1 and Param2 and self.SeqSpawnActors then
    local index = tonumber(Param2)
    if index and self.StateConfig.ShowActorConfig and self.StateConfig.ShowActorConfig[index] then
      if Param1 == "show" then
        for key, ShowActor in pairs(self.StateConfig.ShowActorConfig[index]) do
          if self.SeqSpawnActors[ShowActor] and slua.isValid(self.SeqSpawnActors[ShowActor]) then
            local rootComponent = self.SeqSpawnActors[ShowActor]:K2_GetRootComponent()
            if slua.isValid(rootComponent) then
              rootComponent:SetVisibility(true, false)
            end
            self.SeqSpawnActors[ShowActor]:SetActorHiddenInGame(false)
          end
        end
      elseif Param1 == "hide" then
        for key, ShowActor in pairs(self.StateConfig.ShowActorConfig[index]) do
          if self.SeqSpawnActors[ShowActor] and slua.isValid(self.SeqSpawnActors[ShowActor]) then
            local rootComponent = self.SeqSpawnActors[ShowActor]:K2_GetRootComponent()
            if slua.isValid(rootComponent) then
              rootComponent:SetVisibility(false, false)
            end
            self.SeqSpawnActors[ShowActor]:SetActorHiddenInGame(true)
          end
        end
      end
    end
  end
end
function PlaneShowActor:PlayEffect(Param1)
  if Param1 and self.SeqSpawnActors then
    local index = tonumber(Param1)
    if index and self.StateConfig.PlayEffectConfig and self.StateConfig.PlayEffectConfig[index] then
      for key, ShowActor in pairs(self.StateConfig.PlayEffectConfig[index]) do
        if self.SeqSpawnActors[ShowActor] and slua.isValid(self.SeqSpawnActors[ShowActor]) then
          self.SeqSpawnActors[ShowActor]:Activate()
        end
      end
    end
  end
end
function PlaneShowActor:ChangeCameraBack()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(self.PlaneActor) then
    local CurrentViewTarget = uPlayerController:GetViewTarget()
    if slua.isValid(CurrentViewTarget) and CurrentViewTarget:ActorHasTag("SequencerActor") then
      uPlayerController:SetViewTargetTest(self.PlaneActor)
      print(bWriteLog and "PlaneShowActor:ChangeCameraBack")
    end
  end
end
function PlaneShowActor:PreInitActorNameToguid()
  if not self.ActorNameToguidTabInit and self.StateConfig.SeqActorNameDic then
    self.ActorNameToguidTabInit = {}
    for key, value in pairs(self.StateConfig.SeqActorNameDic) do
      local infos = self.LevelSeqActor:GetPossessableOrSpawnableByName(value)
      local FGuid = {}
      FGuid.A = infos.Guid.A
      FGuid.B = infos.Guid.B
      FGuid.C = infos.Guid.C
      FGuid.D = infos.Guid.D
      self.ActorNameToguidTabInit[FGuid] = value
    end
  end
end
function PlaneShowActor:GetNameFromGuid(Guid)
  if not Guid then
    return
  end
  self:PreInitActorNameToguid()
  if not self.ActorNameToguidTabInit then
    return
  end
  for key, value in pairs(self.ActorNameToguidTabInit) do
    if key and key.A == Guid.A and key.B == Guid.B and key.C == Guid.C and key.D == Guid.D then
      return value
    end
  end
end
function PlaneShowActor:OnObjectSpawnedEvent(spawnedObject, Guid, otherInfo2)
  print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent in")
  if slua.isValid(spawnedObject) then
    local spawnedObjectActorName = self:GetNameFromGuid(Guid)
    if not spawnedObjectActorName then
      print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent not use:")
      return
    end
    print(bWriteLog and "PlaneShowActor:OnObjectSpawnedEvent:" .. spawnedObjectActorName)
    self:DellCreateOrBindActor(spawnedObjectActorName, spawnedObject)
  end
end
function PlaneShowActor:DellCreateOrBindActor(spawnedObjectActorName, spawnedObject)
  print(bWriteLog and "PlaneShowActor:DellCreateOrBindActor:" .. spawnedObjectActorName)
  if not self.CloseChildren then
    self.CloseChildren = {}
  end
  if not self.SeqSpawnActors then
    self.SeqSpawnActors = {}
  end
  if not self.SeqLightActors then
    self.SeqLightActors = {}
  end
  if slua.isValid(spawnedObject) and spawnedObjectActorName then
    local NeedDell = false
    for key, ChangeCamereInvisibleActorName in pairs(self.StateConfig.ChangeCamereInvisibleActor) do
      if spawnedObjectActorName == ChangeCamereInvisibleActorName then
        NeedDell = true
        break
      end
    end
    if NeedDell then
      self.CloseChildren[#self.CloseChildren + 1] = spawnedObject
    end
    self.SeqSpawnActors[spawnedObjectActorName] = spawnedObject
    for key, CreateActorHideName in pairs(self.StateConfig.CreateActorHide) do
      if spawnedObjectActorName == CreateActorHideName then
        local rootComponent = spawnedObject:K2_GetRootComponent()
        if slua.isValid(rootComponent) then
          rootComponent:SetVisibility(false, false)
        end
        spawnedObject:SetActorHiddenInGame(true)
        break
      end
    end
    for key, CreateActorHideName in pairs(self.StateConfig.SeqAddLightInfo) do
      if spawnedObjectActorName == CreateActorHideName then
        self.SeqLightActors[#self.SeqLightActors + 1] = spawnedObject
        if slua.isValid(spawnedObject.LightComponent) then
          spawnedObject.LightComponent.bUsedAsAtmosphereSunLight = true
        end
        break
      end
    end
    if self.StateConfig.CameraUseInfo and self.StateConfig.CameraUseInfo.StaticCameraName and self.StateConfig.CameraUseInfo.StaticCameraName == spawnedObjectActorName then
      self.NeedShowPlaneCamera = spawnedObject
    end
    if self.StateConfig.CameraUseInfo and self.StateConfig.CameraUseInfo.CabinShowCameraName and self.StateConfig.CameraUseInfo.CabinShowCameraName == spawnedObjectActorName then
      self.CabinShowCamera = spawnedObject
    end
    if not spawnedObject:ActorHasTag("QuickSignIgnore") then
      spawnedObject.Tags:Add("QuickSignIgnore")
    end
  end
end
function PlaneShowActor:ChangeCameraCabinDell(bIsBind)
  print(bWriteLog and "PlaneShowActor:ChangeCameraCabinDell bIsBind:" .. tostring(bIsBind))
  if self.CanCameraCabinDell and self.CanCameraCabinDell == "StartCanChangeCamera" then
    self.ShowCameraCabin = bIsBind
    print(bWriteLog and "PlaneShowActor:ChangeCameraCabinDell dell ShowCameraCabin:" .. tostring(self.ShowCameraCabin))
    if bIsBind then
      self:CloseSceneDirectionalLight()
    else
      self:OpenSceneDirectionalLight()
    end
    self:ChangeSeqLightVisable(bIsBind)
    self:ChangeCameraDellViewTarget(bIsBind)
    self:ChangeCameraDellChilds(bIsBind)
  end
end
function PlaneShowActor:ChangeSeqLightVisable(bIsBind)
  print(bWriteLog and "PlaneShowActor:ChangeSeqLightVisable bIsBind:" .. tostring(bIsBind))
  if self.SeqLightActors then
    for index, value in ipairs(self.SeqLightActors) do
      if slua.isValid(value) and value.LightComponent then
        value.LightComponent:SetVisibility(bIsBind, true)
      end
      if slua.isValid(value) then
        value:SetActorHiddenInGame(not bIsBind)
      end
    end
  end
end
function PlaneShowActor:OnViewTargetChange()
  print(bWriteLog and "PlaneShowActor:OnViewTargetChange:")
  if self._bInViewTargetChange then
    print(bWriteLog and "PlaneShowActor:OnViewTargetChange - Skip re-entrant call")
    return
  end
  self._bInViewTargetChange = true
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local EStateType = import("EStateType")
  if slua.isValid(uPlayerController) and self.CanCameraCabinDell and self.CanCameraCabinDell == "StartCanChangeCamera" and uPlayerController:GetCurrentStateType() == EStateType.State_InPlane then
    local CurrentPlaneCamera = uPlayerController:GetViewTarget()
    if slua.isValid(CurrentPlaneCamera) then
      if self.ShowCameraCabin and CurrentPlaneCamera ~= self.CabinShowCamera then
        print(bWriteLog and "PlaneShowActor:OnViewTargetChange CabinShowCamera")
        if self.CabinShowCamera and slua.isValid(self.CabinShowCamera) then
          uPlayerController:SetViewTargetTest(self.CabinShowCamera)
        end
      elseif not self.ShowCameraCabin and CurrentPlaneCamera ~= self.PlaneActor then
        print(bWriteLog and "PlaneShowActor:OnViewTargetChange NeedShowPlaneCamera")
        if self.PlaneActor and slua.isValid(self.PlaneActor) then
          self:SetActorHiddenInGame(true)
          uPlayerController:SetViewTargetTest(self.PlaneActor)
        end
        print(bWriteLog and "OriginSpringArm:SetActive ChangeCameraDellViewTarget false SetDisableTouchMoveInput true ")
      end
    end
  end
  self._bInViewTargetChange = false
end
function PlaneShowActor:ChangeCameraDellViewTarget(bIsBind)
  print(bWriteLog and "PlaneShowActor:ChangeCameraDellViewTarget bIsBindd:" .. tostring(bIsBind))
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local EStateType = import("EStateType")
  if slua.isValid(uPlayerController) and uPlayerController:GetCurrentStateType() == EStateType.State_InPlane then
    if bIsBind then
      if self.CabinShowCamera and slua.isValid(self.CabinShowCamera) then
        if self.OriginalControllerRot then
          local PlaneActorRot = self.PlaneActor:K2_GetActorRotation()
          uPlayerController:SetControlRotation(self.OriginalControllerRot, "PlaneShowActor")
          local OriginSpringArm = self.PlaneActor:GetComponentByClass(import("/Script/Engine.SpringArmComponent"))
          if not slua.isValid(OriginSpringArm) then
            return
          end
          local OriginPlaneActorRot = self.OriginalControllerRot - PlaneActorRot
          OriginSpringArm:K2_SetRelativeRotation(OriginPlaneActorRot, false, nil, false)
        end
        uPlayerController:SetViewTargetTest(self.CabinShowCamera)
      end
    else
      print(bWriteLog and "OriginSpringArm:SetActive ChangeCameraDellViewTarget NeedShowPlaneCamera")
      if self.PlaneActor and slua.isValid(self.PlaneActor) then
        self:SetActorHiddenInGame(true)
        self.OriginalControllerRot = uPlayerController:GetControlRotation()
        uPlayerController:SetViewTargetTest(self.PlaneActor)
      end
      uPlayerController:ShowTouchInterface(false)
      print(bWriteLog and "OriginSpringArm:SetActive ChangeCameraDellViewTarget SetDisableTouchMoveInput true")
    end
    if self.bNeedUIAnim then
      self:ShowChangeCameraViewEffect("Ani_BlackFade_02")
    end
  end
end
function PlaneShowActor:ShowChangeCameraViewEffect(Anim)
  print(bWriteLog and "PlaneShowActor:ShowChangeCameraViewEffect")
  local AirplaneShowUI = UIManager.GetUI(UIManager.UI_Config.AirplaneShowUI)
  if AirplaneShowUI == nil then
    UIManager.ShowUI(UIManager.UI_Config.AirplaneShowUI, {ShowAni = Anim})
  else
    AirplaneShowUI:PlayAnim(Anim)
  end
  self:HideAllOpenPanel()
end
function PlaneShowActor:ChangeCameraDellChilds(bIsBind)
  print(bWriteLog and "PlaneShowActor:ChangeCameraDellChilds bIsBind:" .. tostring(bIsBind))
  if not self.StateConfig or not self.StateConfig.ChangeCamereInvisibleActor then
    return
  end
  if bIsBind then
    if self.CloseChildren then
      for key, value in pairs(self.CloseChildren) do
        if slua.isValid(value) then
          local rootComponent = value:K2_GetRootComponent()
          if slua.isValid(rootComponent) then
            rootComponent:SetVisibility(true, false)
          end
          value:SetActorHiddenInGame(false)
        end
      end
    end
    if self.ShowPlaneHidden then
      self:SetActorHiddenInGame(true)
    end
  elseif self.CloseChildren then
    print(bWriteLog and "PlaneShowActor:ChangeCameraDellChilds")
    for key, value in pairs(self.CloseChildren) do
      if slua.isValid(value) then
        local rootComponent = value:K2_GetRootComponent()
        if slua.isValid(rootComponent) then
          rootComponent:SetVisibility(false, false)
        end
        value:SetActorHiddenInGame(true)
      end
    end
  end
end
function PlaneShowActor:ShowNamePanel(ShowData)
  print(bWriteLog and "PlaneShowActor:ShowNamePanel")
  local AirplaneShowUI = UIManager.GetUI(UIManager.UI_Config.AirplaneShowUI)
  if AirplaneShowUI == nil then
    UIManager.ShowUI(UIManager.UI_Config.AirplaneShowUI, ShowData)
  else
    AirplaneShowUI:UpdateShowInfo(ShowData)
  end
end
function PlaneShowActor:HideNamePanel()
  print(bWriteLog and "PlaneShowActor:HideNamePanel")
  UIManager.HideUI(UIManager.UI_Config.AirplaneShowUI)
end
function PlaneShowActor:HideAllOpenPanel()
  print(bWriteLog and "PlaneShowActor:HideAllOpenPanel")
  if self.OpenUITable then
    for i, v in ipairs(self.OpenUITable) do
      UIManager.CloseUI(v)
    end
    self.OpenUITable = {}
  end
end
function PlaneShowActor:GetSingleRoleMeshCompList(SingleRole)
  if slua.isValid(SingleRole) then
    local ComponentClass = import("CharacterAvatarComponent2")
    local uCharacterAvatarComponent = SingleRole and SingleRole:GetComponentByClass(ComponentClass)
    if not slua.isValid(uCharacterAvatarComponent) then
      return
    end
    local MeshCompList = uCharacterAvatarComponent:GetAllMeshComponents(false)
    if not MeshCompList or not slua.isValid(MeshCompList) then
      return
    end
    return MeshCompList
  end
end
function PlaneShowActor:StartWind(Param1)
  local bStart = true
  if Param1 and Param1 == "0" then
    bStart = false
  end
  if not self.SingleRoles then
    return
  end
  for key, value in pairs(self.SingleRoles) do
    local MeshCompList = self:GetSingleRoleMeshCompList(value)
    if MeshCompList and slua.isValid(MeshCompList) then
      local MeshNum = MeshCompList:Num()
      if 0 < MeshNum then
        for index = 0, MeshNum - 1 do
          local MeshComp = MeshCompList:Get(index)
          if MeshComp and slua.isValid(MeshComp) and MeshComp.GetAnimInstance ~= nil then
            local AnimIns = MeshComp:GetAnimInstance()
            if AnimIns and slua.isValid(AnimIns) and AnimIns.SetStandToPoseParachuteToEnableWind then
              AnimIns:SetStandToPoseParachuteToEnableWind(bStart)
              print(bWriteLog and "PlaneShowActor:StartWind")
            end
          end
        end
      end
    end
  end
end
function PlaneShowActor:GetTeamMateList(Config)
  local BackPawnList = {}
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if ConfigDrivePlaneShowSubsystem then
    local TeamMateInfo = ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
    if TeamMateInfo and 0 < #TeamMateInfo then
      for index, value in ipairs(TeamMateInfo) do
        local SingleRole = self:CreateSingleRole(Config)
        self:SetPawnData(SingleRole, value)
        BackPawnList[#BackPawnList + 1] = SingleRole
      end
    end
  end
  return BackPawnList
end
function PlaneShowActor:CreateSingleRole(Config)
  local SingleActor
  local bSuccess, playerLobbyPawnClass = pcall(import, Config.LobbyPawnActorPath)
  if not bSuccess or not playerLobbyPawnClass then
    print(bWriteLog and string.format("PlaneShowActor:CreateSingleRole - Failed to import LobbyPawnActorPath: %s", tostring(Config.LobbyPawnActorPath)))
    return nil
  end
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    print(bWriteLog and "PlaneShowActor:CreateSingleRole - World is invalid")
    return nil
  end
  SingleActor = world:SpawnActor(playerLobbyPawnClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  if slua.isValid(SingleActor) then
    SingleActor.canRotate = false
  end
  return SingleActor
end
function PlaneShowActor:SetPawnData(Pawn, CacheData)
  if slua.isValid(Pawn) then
    if CacheData then
      if CacheData.UID then
        Pawn:SetPlayerUID(CacheData.UID)
      end
      self:PutOnAvatar(Pawn, CacheData.Gender, CacheData.HeadId, CacheData.AvatarList, CacheData.NetAvatarData)
      Pawn:SetForceUseDefaultIdle(false)
    end
  else
    print(bWriteLog and "PlaneShowActor:SetPawnData PlayerState or CharacterOwner invalid")
  end
end
function PlaneShowActor:PutOnAvatar(SingleActor, sex, headId, avatarList, NetAvatarData)
  if not slua.isValid(SingleActor) then
    return
  end
  print(bWriteLog and "PlaneShowActor:PutOnAvatar", sex, headId)
  if sex == 0 then
    SingleActor:SetMaleAnimClass()
  elseif sex == 1 then
    SingleActor:SetFemaleAnimClass()
  end
  local CharacterAvartarComp = SingleActor.CharacterAvatarComp2_BP
  if slua.isValid(CharacterAvartarComp) and NetAvatarData then
    CharacterAvartarComp.bIsLobbyAvatar = false
    self:FliterSynData(NetAvatarData)
    self:UpdateAvatarLevel(SingleActor, NetAvatarData)
    CharacterAvartarComp.bSyncAvatar = false
    CharacterAvartarComp.    CharacterAvartarComp:SetAvatarGender(sex)
    CharacterAvartarComp:OnRep_BodySlotStateChanged()
    SingleActor:AddControlEvent(CharacterAvartarComp, "OnAvatarAllMeshLoaded", function()
      if slua.isValid(CharacterAvartarComp) then
        local ClothMesh = CharacterAvartarComp:GetMeshCompBySlotID(5)
        if slua.isValid(ClothMesh) then
          local AnimInstance = ClothMesh:GetAnimInstance()
          if slua.isValid(AnimInstance) and AnimInstance.SetForceIgnoreBoneRetarget then
            AnimInstance:SetForceIgnoreBoneRetarget(true)
            print(bWriteLog and "Game:SetShowPawnAvatarFromPlayerKey ForceIgnoreBoneRetarget")
          end
        end
        local MeshCompList = CharacterAvartarComp:GetAllMeshComponents(false)
        if MeshCompList then
          local MeshNum = MeshCompList:Num()
          if 0 < MeshNum then
            for index = 0, MeshNum - 1 do
              local MeshComp = MeshCompList:Get(index)
              if MeshComp and slua.isValid(MeshComp) and MeshComp.GetAnimInstance ~= nil then
                local AnimIns = MeshComp:GetAnimInstance()
                if AnimIns and slua.isValid(AnimIns) and AnimIns.ForceSetLobbyPawnPoseType then
                  local ESkirtPoseType = import("ESkirtPoseType")
                  AnimIns:ForceSetLobbyPawnPoseType(ESkirtPoseType.ESkirtPose_Stand)
                  print(bWriteLog and "PlaneShowActor:PutOnAvatar ESkirtPose_Stand")
                end
              end
            end
          end
        end
        if slua.isValid(SingleActor) then
          SingleActor:RemoveControlEvent(CharacterAvartarComp, "OnAvatarAllMeshLoaded")
        end
      end
    end)
  end
end
function PlaneShowActor:IsNeedSlotType(SlotTypeID, SubSlotID)
  local EAvatarSlotType = import("EAvatarSlotType")
  if SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_FootEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_GlideEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_HandEffectEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_BackPack_PendantSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ArmorEquipemtSlot or SlotTypeID == EAvatarSlotType.EAvatarSlotType_ParachuteEquipemtSlot then
    return false
  end
  return true
end
function PlaneShowActor:FliterSynData(NetAvatarData)
  if NetAvatarData and NetAvatarData.SlotSyncData then
    local TempSlotSyncData = slua.IndexReference(NetAvatarData, "SlotSyncData")
    for Index, AvatarSynData in pairs(TempSlotSyncData) do
      if AvatarSynData.ItemID > 0 and not self:IsNeedSlotType(AvatarSynData.SlotID, AvatarSynData.SubSlotID) then
        AvatarSynData.ItemID = 0
        AvatarSynData.SlotID = 0
        AvatarSynData.SubSlotID = 0
        AvatarSynData.FakeItemID = 0
        AvatarSynData.HideState = 0
        slua.IndexReference(NetAvatarData, "SlotSyncData"):Set(Index, AvatarSynData)
      elseif AvatarSynData.ForceHideState == 1 then
        AvatarSynData.ForceHideState = 0
        slua.IndexReference(NetAvatarData, "SlotSyncData"):Set(Index, AvatarSynData)
      end
    end
  end
end
function PlaneShowActor:UpdateAvatarLevel(Pawn, NetAvatarData)
  local Config = CDataTable.GetTable("TeamShowLowDeviceCfg")
  if Config and NetAvatarData and NetAvatarData.SlotSyncData then
    local TempSlotSyncData = slua.IndexReference(NetAvatarData, "SlotSyncData")
    for _, AvatarSynData in pairs(TempSlotSyncData) do
      if AvatarSynData.ItemID and AvatarSynData.ItemID ~= 0 and Config[AvatarSynData.ItemID] then
        print(bWriteLog and "PlaneShowActor:UpdateAvatarLevel" .. tostring(AvatarSynData.ItemID))
        if PlaneShowActor.AvatarLevleThIDs[AvatarSynData.ItemID] then
          Pawn:SetAvatarLevel(3)
        else
          Pawn:SetAvatarLevel(2)
        end
        return
      elseif PlaneShowActor.AvatarLevleThIDs[AvatarSynData.ItemID] then
        Pawn:SetAvatarLevel(3)
      end
    end
  end
  print(bWriteLog and "PlaneShowActor:UpdateAvatarLevel not Change")
end
function PlaneShowActor:ShowCabinItemForPawn(PawnIndex)
  print(bWriteLog and string.format("PlaneShowActor:ShowCabinItemForPawn - PawnIndex=%d", PawnIndex))
  if not self.SingleRoles or not self.SingleRoles[PawnIndex] then
    print(bWriteLog and "PlaneShowActor:ShowCabinItemForPawn - SingleRole not found")
    return
  end
  local SingleRole = self.SingleRoles[PawnIndex]
  if not slua.isValid(SingleRole) then
    print(bWriteLog and "PlaneShowActor:ShowCabinItemForPawn - SingleRole is invalid")
    return
  end
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if not ConfigDrivePlaneShowSubsystem then
    print(bWriteLog and "PlaneShowActor:ShowCabinItemForPawn - ConfigDrivePlaneShowSubsystem not found")
    return
  end
  local TeamMateInfo = ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
  if not TeamMateInfo or not TeamMateInfo[PawnIndex] then
    print(bWriteLog and "PlaneShowActor:ShowCabinItemForPawn - TeamMateInfo not found")
    return
  end
  local CacheData = TeamMateInfo[PawnIndex]
  local CabinShowActorID = CacheData.CabinShowActorID or 0
  if CabinShowActorID == 0 and CacheData.UID then
    CabinShowActorID = self:GetCabinShowActorIDByUID(CacheData.UID)
  end
  if not CabinShowActorID or CabinShowActorID == 0 then
    print(bWriteLog and string.format("PlaneShowActor:ShowCabinItemForPawn - No CabinShowActorID for PawnIndex=%d", PawnIndex))
    return
  end
  print(bWriteLog and string.format("PlaneShowActor:ShowCabinItemForPawn - CabinShowActorID=%d", CabinShowActorID))
  self:CreateAndAttachCabinShowActor(SingleRole, CabinShowActorID, PawnIndex)
end
function PlaneShowActor:GetCabinShowActorIDByUID(UID)
  print(bWriteLog and string.format("PlaneShowActor:GetCabinShowActorIDByUID - UID=%s", tostring(UID)))
  local AllPlayerStates = Game:GetAllPlayerStates()
  if not AllPlayerStates then
    return 0
  end
  for _, PlayerState in pairs(AllPlayerStates) do
    if slua.isValid(PlayerState) and PlayerState.PlayerUID == UID then
      local CabinShowActorID = PlayerState.CabinShowActorID or 0
      print(bWriteLog and string.format("PlaneShowActor:GetCabinShowActorIDByUID - Found CabinShowActorID=%d", CabinShowActorID))
      return CabinShowActorID
    end
  end
  return 0
end
function PlaneShowActor:CreateAndAttachCabinShowActor(SingleRole, CabinShowActorID, PawnIndex)
  print(bWriteLog and string.format("PlaneShowActor:CreateAndAttachCabinShowActor - ActorID=%d, PawnIndex=%d", CabinShowActorID, PawnIndex))
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local PlaneShowConfig = GamePlayTools.GetCurrentConfig("PlaneShowConfig")
  if not PlaneShowConfig or not PlaneShowConfig.CabinShowItemConfig then
    print(bWriteLog and "PlaneShowActor:CreateAndAttachCabinShowActor - CabinShowItemConfig not found")
    return
  end
  local CabinShowItemConfig = PlaneShowConfig.CabinShowItemConfig
  local ItemConfig = CabinShowItemConfig.ShowItems[CabinShowActorID]
  if not ItemConfig then
    print(bWriteLog and string.format("PlaneShowActor:CreateAndAttachCabinShowActor - Config not found for ActorID=%d", CabinShowActorID))
    return
  end
  local util = require("client.slua_ui_framework.util")
  self.CabinShowLoadHandles = self.CabinShowLoadHandles or {}
  if self.CabinShowLoadHandles[PawnIndex] then
    util.ClearAssetAsync(self.CabinShowLoadHandles[PawnIndex])
    self.CabinShowLoadHandles[PawnIndex] = nil
  end
  self.CabinShowLoadHandles[PawnIndex] = util.GetAssetAsync(ItemConfig.ActorClassPath, function(ActorClass)
    self.CabinShowLoadHandles[PawnIndex] = nil
    if not slua.isValid(SingleRole) then
      print(bWriteLog and "PlaneShowActor:CreateAndAttachCabinShowActor - SingleRole destroyed during loading")
      return
    end
    if not ActorClass then
      print(bWriteLog and "PlaneShowActor:CreateAndAttachCabinShowActor - Failed to load ActorClass")
      return
    end
    local world = slua_GameFrontendHUD:GetWorld()
    local ShowActor = world:SpawnActor(ActorClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
    if not slua.isValid(ShowActor) then
      print(bWriteLog and "PlaneShowActor:CreateAndAttachCabinShowActor - Failed to spawn ShowActor")
      return
    end
    local MeshComp
    local ComponentClass = import("CharacterAvatarComponent2")
    local CharacterAvatarComp = SingleRole:GetComponentByClass(ComponentClass)
    if slua.isValid(CharacterAvatarComp) then
      MeshComp = CharacterAvatarComp:GetMeshCompBySlotID(1)
    end
    if not slua.isValid(MeshComp) then
      MeshComp = SingleRole.Mesh
    end
    if slua.isValid(MeshComp) then
      ShowActor:K2_AttachToComponent(MeshComp, ItemConfig.AttachBoneName or "None", EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, true)
      if ItemConfig.RelativeLocation then
        ShowActor:K2_SetActorRelativeLocation(ItemConfig.RelativeLocation, false, nil, false)
      end
      if ItemConfig.RelativeRotation then
        ShowActor:K2_SetActorRelativeRotation(ItemConfig.RelativeRotation, false, nil, false)
      end
      if ItemConfig.RelativeScale then
        ShowActor:SetActorScale3D(ItemConfig.RelativeScale)
      end
      print(bWriteLog and string.format("PlaneShowActor:CreateAndAttachCabinShowActor - Attached to bone: %s", ItemConfig.AttachBoneName or "None"))
    else
      print(bWriteLog and "PlaneShowActor:CreateAndAttachCabinShowActor - MeshComp is invalid, set location only")
      ShowActor:K2_SetActorLocation(SingleRole:K2_GetActorLocation(), false, nil, false)
    end
    self.CabinShowActors[PawnIndex] = ShowActor
    print(bWriteLog and string.format("PlaneShowActor:CreateAndAttachCabinShowActor - Success, PawnIndex=%d", PawnIndex))
  end)
end
function PlaneShowActor:HideCabinItemForPawn(PawnIndex)
  print(bWriteLog and string.format("PlaneShowActor:HideCabinItemForPawn - PawnIndex=%d", PawnIndex))
  if PawnIndex == 0 then
    self:CleanupCabinShowActors()
  else
    local ShowActor = self.CabinShowActors[PawnIndex]
    if slua.isValid(ShowActor) then
      ShowActor:K2_DestroyActor()
      self.CabinShowActors[PawnIndex] = nil
    end
  end
end
function PlaneShowActor:CleanupCabinShowActors()
  print(bWriteLog and "PlaneShowActor:CleanupCabinShowActors")
  if self.CabinShowLoadHandles then
    local util = require("client.slua_ui_framework.util")
    for PawnIndex, LoadHandle in pairs(self.CabinShowLoadHandles) do
      if LoadHandle then
        util.ClearAssetAsync(LoadHandle)
      end
    end
    self.CabinShowLoadHandles = {}
  end
  if self.CabinShowActors then
    for PawnIndex, ShowActor in pairs(self.CabinShowActors) do
      if slua.isValid(ShowActor) then
        ShowActor:K2_DestroyActor()
      end
    end
  end
  self.CabinShowActors = {}
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CPlaneShowActor = class(object, nil, PlaneShowActor)
return CPlaneShowActor
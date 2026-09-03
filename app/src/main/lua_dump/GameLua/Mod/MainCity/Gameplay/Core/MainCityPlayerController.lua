local MainCityPlayerController = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local MainCityCoreConst = require("GameLua.Mod.MainCity.Gameplay.Core.MainCityCoreConst")
local ISTF = MainCityCoreConst.EMainCityInteractiveStateTypeFlag
local ECharacterFollowType = import("ECharacterFollowType")
local EPawnState = import("EPawnState")
function MainCityPlayerController:ctor()
  print(bWriteLog and "MainCityPlayerController:ctor")
  self.playerControllerChannelOpen = false
  if not Client then
    self.bPCInputSwitcher = false
  end
end
function MainCityPlayerController:_PostConstruct()
  MainCityPlayerController.__super._PostConstruct(self)
  print(bWriteLog and "MainCityPlayerController:_PostConstruct")
  if Client then
    self:AddControlEvent(self, "OnActorChannelOpenDelegate", self.PostActorChannelOpen, self)
    self:AddUIMessageEvent("UIMsg_SetAutoSprint", self.UIMsg_SetAutoSprint, self)
    log(bWriteLog and "MainCityPlayerController:_PostConstruct bind")
  else
    require("client.config.pubgm_patch")
    local patchVersion = global_patch_make_time_map["Patch Version"]
    if patchVersion and patchVersion ~= "N/A" then
      self.DSVersion = patchVersion
    end
    print(bWriteLog and "MainCityPlayerController:_PostConstruct DSVersion=" .. tostring(self.DSVersion))
  end
  self.Tags:Add("KeepAliveInMainCity")
end
function MainCityPlayerController:ReceiveBeginPlay()
  MainCityPlayerController.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "MainCityPlayerController:ReceiveBeginPlay role = " .. self.Role)
  self.AutoSprintBtnTime = 360000.0
  self.AutoSprintWaitingTime = 360000.0
  self.AutoSprintThreshold = 360000.0
  self.InitialNetConsiderFrequency = self.Object.NetConsiderFrequency
  self.InitialNetUpdateFrequency = self.Object.NetUpdateFrequency
  self.InitialMinNetUpdateFrequency = self.Object.MinNetUpdateFrequency
  print(bWriteLog and "MainCityPlayerController:ReceiveBeginPlay NetConsiderFrequency:" .. tostring(self.Object.NetConsiderFrequency) .. ",NetUpdateFrequency:" .. tostring(self.Object.NetUpdateFrequency) .. ",MinNetUpdateFrequency:" .. tostring(self.Object.MinNetUpdateFrequency))
  if not Client then
    self:AddTimer(0, function()
      local MainCity_PlayerController_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_PlayerController_Manager")
      MainCity_PlayerController_Manager.AddController(self)
      local playerCharacter = self:GetPlayerCharacterSafety()
      local PlayerHandItemControlFeature = playerCharacter and playerCharacter.PlayerHandItemControlFeature
      if PlayerHandItemControlFeature and PlayerHandItemControlFeature.SetIgnoreCollision_Server then
        PlayerHandItemControlFeature:SetIgnoreCollision_Server()
      end
    end)
  end
  if Client then
    self:AddControlEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
    local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
    local state = MainCity_GamePlay_Tools.GetCurrState()
    local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
    if state ~= main_city_config.ESceneType.MainCity then
      log(bWriteLog and "MainCityPlayerController:ReceiveBeginPlay. in lobby hid input")
      self:ShowTouchInterface(false)
    end
    local ENetRole = import("ENetRole")
    if self.Role == ENetRole.ROLE_AutonomousProxy then
      local Utility = require("common.utility")
      local MainCitySubsystem = Utility.GetWorldSubsystemByName("MainCitySubsystem")
      if slua.isValid(MainCitySubsystem) then
        local uMainCityPawn = MainCitySubsystem.InitialCharacter
        if slua.isValid(uMainCityPawn) then
          log(bWriteLog and string.format("MainCityPlayerController:ReceiveBeginPlay uMainCityPawn Role[%s] RemoteRole[%s]", tostring(uMainCityPawn.Role), tostring(uMainCityPawn.RemoteRole)))
          if uMainCityPawn.Role == ENetRole.ROLE_Authority then
            uMainCityPawn.Role = ENetRole.ROLE_AutonomousProxy
            uMainCityPawn.RemoteRole = ENetRole.ROLE_Authority
            log(bWriteLog and "MainCityPlayerController:ReceiveBeginPlay uMainCityPawn Swap Role and RemoteRole")
          end
        end
      end
    end
    self:AddControlEvent(self, "OnPostViewTargetChangeDelegate", self.HandleOnPostViewTargetChangeDelegate, self)
    self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_ENTER, self.OnLobbySocialEnter, self)
    self:RemoveComponentsForLowDevice()
  else
    log(bWriteLog and "MainCityPlayerController:ReceiveBeginPlay DS")
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_MAXFPS_CHANGED, self.OnMaxFPSChanged, self)
  end
end
function MainCityPlayerController:OnLobbySocialEnter()
  printf("MainCityPlayerController:OnLobbySocialEnter.")
  self:ActivateTouchInterface(nil)
end
function MainCityPlayerController:HandleOnPostViewTargetChangeDelegate(NewViewTarget, PreViewTarget)
  if not slua.isValid(NewViewTarget) then
    print(bWriteLog and string.format("MainCityPlayerController:HandleOnPostViewTargetChangeDelegate is NewViewTarget nil"))
    return
  end
  if not slua.isValid(PreViewTarget) then
    print(bWriteLog and string.format("MainCityPlayerController:HandleOnPostViewTargetChangeDelegate is PreViewTarget nil"))
    return
  end
  if NewViewTarget.bMainCityChar and not PreViewTarget.bMainCityChar then
    print(bWriteLog and "MainCityPlayerController:HandleOnPostViewTargetChangeDelegate, NewViewTarget=BP_MainCityPawn,Role:" .. tostring(self.Role))
    local uCharacter = self:GetPlayerCharacterSafety()
    if Game:IsValid(uCharacter) and not uCharacter:HasState(EPawnState.FollowWalk) then
      print(bWriteLog and "MainCityPlayerController:HandleOnPostViewTargetChangeDelegate, Ready to ExitFreeCamera(true)=1,Role:" .. tostring(self.Role))
      self:ExitFreeCamera(true)
    end
  end
end
function MainCityPlayerController:OnMaxFPSChanged(_, _, NewFPS, Type)
  local FPSFactor = NewFPS / 18.0
  if Type == 1 then
    self.Object.NetConsiderFrequency = self.InitialNetConsiderFrequency * FPSFactor
    self.Object.NetUpdateFrequency = self.InitialNetUpdateFrequency * FPSFactor
    self.Object.MinNetUpdateFrequency = self.InitialMinNetUpdateFrequency * FPSFactor
  end
  print(bWriteLog and "MainCityPlayerController:OnMaxFPSChanged " .. tostring(NewFPS) .. ",NetConsiderFrequency:" .. tostring(self.Object.NetConsiderFrequency) .. ",NetUpdateFrequency:" .. tostring(self.Object.NetUpdateFrequency) .. ",MinNetUpdateFrequency:" .. tostring(self.Object.MinNetUpdateFrequency))
end
function MainCityPlayerController:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "MainCityPlayerController:ReceiveEndPlay")
  if not Client then
    local MainCity_PlayerController_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_PlayerController_Manager")
    MainCity_PlayerController_Manager.RemoveController(self)
  end
  if not Client then
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_CONTROLLER_ENDPLAY_DS, self)
  end
  if self.ScreenInput then
    self.ScreenInput.OnMotionDetected:Clear()
  end
  if Client then
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr.HasInit then
      if SubsystemMgr.HasCallOnInit then
        log(bWriteLog and "MainCityPlayerController:ReceiveEndPlay Call subsystem OnRelease and Dispose")
        SubsystemMgr:EndPlay()
      else
        log(bWriteLog and "MainCityPlayerController:ReceiveEndPlay Call subsystem Dispose")
        SubsystemMgr:_CallAllLifeCycleMethod("Dispose")
      end
      log(bWriteLog and "MainCityPlayerController:ReceiveEndPlay clear subsystem map")
      SubsystemMgr:Destroy()
    end
  end
  MainCityPlayerController.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MainCityPlayerController:InitInGameUI()
  print(bWriteLog and "MainCityPlayerController:InitInGameUI")
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  local ENetRole = import("ENetRole")
  if self.Role ~= ENetRole.ROLE_AutonomousProxy then
    print(bWriteLog and "MainCityPlayerController:InitInGameUI not Autonomous controller")
    return
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if not ClientGameMain then
    print(bWriteLog and "MainCityPlayerController:InitInGameUI 1")
    return
  end
  local CurrentModeLogic = ClientGameMain.CurrentModeLogic
  if not CurrentModeLogic then
    print(bWriteLog and "MainCityPlayerController:InitInGameUI 2")
    return
  end
  local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  log_format("MainCityPlayerController:InitInGameUI SubsystemMgr.HasInit = %s", tostring(SubsystemMgr.HasInit))
  if not SubsystemMgr.HasInit then
    local InitType = ClientGameMain.GetInitType()
    log(bWriteLog and string.format("MainCityPlayerController:InitInGameUI InitType=%s", InitType))
    if SubsystemMgr:Init(InitType) then
      log(bWriteLog and "MainCityPlayerController:InitInGameUI Call _PostConstruct")
      SubsystemMgr:CallOnPreRep()
    end
  end
  log_format("MainCityPlayerController:InitInGameUI SubsystemMgr.HasCallOnInit = %s", tostring(SubsystemMgr.HasCallOnInit))
  if not SubsystemMgr.HasCallOnInit then
    CurrentModeLogic:InitGameplaySys()
  end
  CurrentModeLogic.bHasInitModeUI = true
end
function MainCityPlayerController_InitInGameUI()
  print(bWriteLog and "MainCityPlayerController_InitInGameUI")
  if not Client then
    print(bWriteLog and "MainCityPlayerController_InitInGameUI no client")
    return
  end
  local playerControl = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(playerControl) then
    print(bWriteLog and "MainCityPlayerController_InitInGameUI no player control")
    return
  end
  playerControl:InitInGameUI()
end
function MainCityPlayerController:PostActorChannelOpen()
  log(bWriteLog and "MainCityPlayerController:PostActorChannelOpen")
  self.playerControllerChannelOpen = true
  local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
  logic_main_city_connect_state:SetConnectingState(false, false)
  local Utility = require("common.utility")
  local MainCitySubsystem = Utility.GetWorldSubsystemByName("MainCitySubsystem")
  if slua.isValid(MainCitySubsystem) then
    local uMainCityPawn = MainCitySubsystem.InitialCharacter
    if slua.isValid(uMainCityPawn) then
      self:SetViewTargetTest(uMainCityPawn)
      local uDynamicOptComp = uMainCityPawn.DynamicOptimizeCharacterComps
      if slua.isValid(uDynamicOptComp) then
        local EPlayerCameraMode = import("EPlayerCameraMode")
        log(bWriteLog and "MainCityPlayerController:PostActorChannelOpen HandleOnSwitchCameraModeStart")
        uDynamicOptComp:HandleOnSwitchCameraModeStart(EPlayerCameraMode.PCM_Normal)
      end
      local SimulateViewData = uMainCityPawn.SimulateViewData
      if SimulateViewData then
        local NewRotation = FRotator(SimulateViewData.ViewPitch, SimulateViewData.ViewYaw, SimulateViewData.ViewRoll)
        self:SetControlRotation(NewRotation, "PostActorChannelOpen")
        log(bWriteLog and "MainCityPlayerController:PostActorChannelOpen SetControlRotation")
        self.bIgnoreClientSetRotationOnce = true
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS)
  self:AddGameTimer(0, false, function()
    EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS_DELAY)
  end)
end
function MainCityPlayerController:RemoveComponentsForLowDevice()
  if not Client then
    return
  end
  log(bWriteLog and "MainCityPlayerController:RemoveComponentsForLowDevice")
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  if memopt:EnableEnterMainCity() then
    return
  end
  log(bWriteLog and "MainCityPlayerController:RemoveComponentsForLowDevice start remove")
  if slua.isValid(self.BP_AutoNav) then
    self.BP_AutoNav:K2_DestroyComponent(self.BP_AutoNav)
    self.BP_AutoNav = nil
  end
  if slua.isValid(self.BP_ChangeWearingComp) then
    self.BP_ChangeWearingComp:K2_DestroyComponent(self.BP_ChangeWearingComp)
    self.BP_ChangeWearingComp = nil
  end
  self:AddTimerOnce(2, function()
    if slua.isValid(self.PlayerCameraManager) and slua.isValid(self.PlayerCameraManager.ScreenAppearanceActor) then
      self.PlayerCameraManager.ScreenAppearanceActor:K2_DestroyActor()
      self.PlayerCameraManager.ScreenAppearanceActor = nil
    end
  end)
  self:AddTimerOnce(0, function()
    self:ClientSetHUD(nil)
  end)
  log(bWriteLog and "MainCityPlayerController:RemoveComponentsForLowDevice finish remove")
end
function MainCityPlayerController:ClientSetRotation(NewRotation, bResetCamera)
  log(bWriteLog and "MainCityPlayerController:ClientSetRotation")
  if self.bIgnoreClientSetRotationOnce then
    self.bIgnoreClientSetRotationOnce = false
    log(bWriteLog and "MainCityPlayerController:ClientSetRotation Ignore")
    return
  end
  if self.Super.ClientSetRotation then
    self.Super:ClientSetRotation(NewRotation, bResetCamera)
  else
    log(bWriteLog and "MainCityPlayerController:ClientSetRotation c++ not found")
  end
end
function MainCityPlayerController:OnReconnect()
  print(bWriteLog and "MainCityPlayerController:OnReconnect")
  EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_ON_PC_RECONNECT)
end
function MainCityPlayerController:LuaShouldShowTouchInterface(bShow)
  log(bWriteLog and string.format("MainCityPlayerController:LuaShouldShowTouchInterface bShow=%s", tostring(bShow)))
  if bShow then
    local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
    local state = MainCity_GamePlay_Tools.GetCurrState()
    log(bWriteLog and "MainCityPlayerController:LuaShouldShowTouchInterface state = " .. tostring(state))
    local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
    if state ~= main_city_config.ESceneType.MainCity then
      bShow = false
    else
      local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
      local bShowMainCityUI = Lobby_Main_City_Enter.bShowMainCityUI
      log(bWriteLog and "MainCityPlayerController:LuaShouldShowTouchInterface bShowMainCityUI = " .. tostring(bShowMainCityUI))
      if not bShowMainCityUI then
        bShow = false
      else
        local playerState = self.PlayerState
        if Game:IsValid(playerState) and not playerState.InteractivePlayerStateFeature:IsInteractiveStateIdle(ISTF.ISTF_Soccer | ISTF.ISTF_MagicWand | ISTF.ISTF_PartyPopper) then
          printf("MainCityPlayerController:LuaShouldShowTouchInterface in :%s", playerState:ParseInteractiveStateMask())
          bShow = false
        else
          local uiConfigs = {}
          for _, uiConfig in ipairs(uiConfigs) do
            if UIManager.IsUIShow(uiConfig) then
              printf("MainCityPlayerController:LuaShouldShowTouchInterface ui[%s] opened.", uiConfig.moduleName)
              bShow = false
              break
            end
          end
          local uChar = self:GetPlayerCharacterSafety()
          if slua.isValid(uChar) then
            local uFollowComp = uChar:GetFollowMoveComp()
            if slua.isValid(uFollowComp) and uFollowComp.FollowInfo.Type == 2 then
              printf("MainCityPlayerController:LuaShouldShowTouchInterface in follow state. followType:%s", uFollowComp.FollowInfo.Type)
              bShow = false
            elseif uChar:HasState(EPawnState.BeCarriedBack) then
              printf("MainCityPlayerController:LuaShouldShowTouchInterface in BeCarriedBack state.")
              bShow = false
            else
              local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
              if IngameSelfieSubsystem and IngameSelfieSubsystem.bIsIngameSelfieMode then
                printf("MainCityPlayerController:LuaShouldShowTouchInterface in ingame selfie mode hide input")
              else
                local ViewTarget = self:GetViewTarget()
                log(bWriteLog and "MainCityPlayerController:LuaShouldShowTouchInterface ViewTarget = " .. tostring(ViewTarget))
                if state == main_city_config.ESceneType.MainCity and ViewTarget and not Game:IsBaseCharacter(ViewTarget) then
                  printf("MainCityPlayerController:LuaShouldShowTouchInterface not in characters viewtarget")
                  bShow = false
                else
                end
              end
            end
          end
        end
      end
    end
  end
  if bShow then
    self:AddTimerOnce(0, function()
      if self.GetStickLeftSize and self.SetJoyStickInteractionSize then
        local SizeX = 200
        local SizeY = 200
        local StickSize = self:GetStickLeftSize()
        SizeX = math.max(SizeX, StickSize.X)
        SizeY = math.max(SizeY, StickSize.Y)
        self:SetJoyStickInteractionSize(FVector2D(SizeX, SizeY))
      end
    end)
  end
  printf("MainCityPlayerController:LuaShouldShowTouchInterface final bShow=%s", bShow)
  return MainCityPlayerController.__super.LuaShouldShowTouchInterface(self, bShow)
end
function MainCityPlayerController:LuaShowJoystickWidgetWithTag(Tag)
  self:ShowTouchInterface(true)
end
function MainCityPlayerController:LuaHideJoystickWidgetWithTag(Tag)
  self:ShowTouchInterface(false)
end
function MainCityPlayerController:LuaShowJoystickWithTag(Tag)
  self:ShowTouchInterface(true)
end
function MainCityPlayerController:LuaHideJoystickWithTag(Tag)
  self:ShowTouchInterface(false)
end
function MainCityPlayerController:ShowTouchInterface(show, reason)
  print(bWriteLog and string.format("MainCityPlayerController:ShowTouchInterface %s (reason = %s)", show, reason))
  self.Super:ShowTouchInterface(show)
end
function MainCityPlayerController:NeedHidePetExpression()
  return true
end
function MainCityPlayerController:Client_CheckCanSetViewTarget(NewViewTarget)
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget NewViewTarget = " .. tostring(NewViewTarget) .. " self.Object = " .. tostring(self.Object) .. " self.playerControllerChannelOpen = " .. tostring(self.playerControllerChannelOpen))
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local old_setviewTargetManual = Lobby_Main_City_Enter.setviewTargetManual
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget old_setviewTargetManual = " .. tostring(old_setviewTargetManual))
  Lobby_Main_City_Enter.setviewTargetManual = false
  local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
  local state = MainCity_GamePlay_Tools.GetCurrState()
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget state = " .. tostring(state))
  local main_city_config = require("client.slua.logic.lobby.MainCity.main_city_config")
  if state ~= main_city_config.ESceneType.MainCity and NewViewTarget == self.Object then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 1")
    return false
  end
  local SpectatorPawn = import("SpectatorPawn")
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget SpectatorPawn = " .. tostring(SpectatorPawn))
  if state ~= main_city_config.ESceneType.MainCity and Game:IsClassOf(NewViewTarget, SpectatorPawn) then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 2")
    return false
  end
  local Utility = require("common.utility")
  local MainCitySubsystem = Utility.GetWorldSubsystemByName("MainCitySubsystem")
  local MainCityPawn
  if slua.isValid(MainCitySubsystem) then
    MainCityPawn = MainCitySubsystem.InitialCharacter
  end
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget MainCityPawn = " .. tostring(MainCityPawn))
  if state ~= main_city_config.ESceneType.MainCity and self.playerControllerChannelOpen and MainCityPawn and NewViewTarget == MainCityPawn then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 3")
    return false
  end
  if state == main_city_config.ESceneType.MainCity and NewViewTarget == self.Object then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 4")
    return false
  end
  if state == main_city_config.ESceneType.MainCity and Game:IsClassOf(NewViewTarget, SpectatorPawn) then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 5")
    return false
  end
  local bShowMainCityUI = Lobby_Main_City_Enter.bShowMainCityUI
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget bShowMainCityUI = " .. tostring(bShowMainCityUI))
  if state == main_city_config.ESceneType.MainCity and not bShowMainCityUI and self.playerControllerChannelOpen and MainCityPawn and NewViewTarget == MainCityPawn and not old_setviewTargetManual then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return false 7")
    return false
  end
  local ViewTarget = self:GetViewTarget()
  local bNewViewTargetIsChar = Game:IsBaseCharacter(NewViewTarget)
  local myChar = self:GetPlayerCharacterSafety()
  if Game:IsValid(myChar) then
    printf("xMainCityPlayerController:Client_CheckCanSetViewTarget cur ViewTarget = %s\239\188\140 bNewViewTargetIsSelfChar = %s", ViewTarget, bNewViewTargetIsChar and myChar == NewViewTarget)
    if Game:IsClassOf(ViewTarget, import("CameraActor")) and bNewViewTargetIsChar and NewViewTarget ~= myChar then
      log(bWriteLog and "xMainCityPlayerController:Client_CheckCanSetViewTarget return false 8")
      return false
    end
    if Game:IsClassOf(ViewTarget, import("/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C")) and bNewViewTargetIsChar and NewViewTarget ~= myChar then
      log(bWriteLog and "xMainCityPlayerController:Client_CheckCanSetViewTarget return false 8.1")
      return false
    end
  end
  if slua.isValid(self.Pawn) then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget self.Pawn = " .. tostring(self.Pawn))
    if not Game:IsBaseCharacter(self.Pawn) and bNewViewTargetIsChar and NewViewTarget ~= myChar then
      log(bWriteLog and "xMainCityPlayerController:Client_CheckCanSetViewTarget return false 9")
      return false
    end
  end
  local ENetRole = import("ENetRole")
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget ExitFreeCamera=1")
    self:ExitFreeCamera(false)
  end
  log(bWriteLog and "MainCityPlayerController:Client_CheckCanSetViewTarget return true")
  return true
end
function MainCityPlayerController:HandleShowFollowEmoteUI(showFollowEmote)
  print(bWriteLog and "MainCityPlayerController HandleShowFollowEmoteUI", showFollowEmote)
  if showFollowEmote then
    local IMainCity_InteractPartial = require("GameLua.Mod.MainCity.Gameplay.Actor.Interactive.InteractivePartical.IMainCity_InteractPartial")
    if not IMainCity_InteractPartial:CheckShowInteractiveUI(nil) then
      log(bWriteLog and "MainCityPlayerController HandleShowFollowEmoteUI return false 1")
      return
    end
    local UIConfig = {
      [1] = {
        BtnImagePath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Sink_Icon_FollowEmote_png.Sink_Icon_FollowEmote_png",
        TextId = 30170,
        ClickFuncName = "HandleClickFollowEmote"
      }
    }
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAIN_CITY_INTERACTIVE_UI_UPDATE, self, UIConfig)
  else
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAIN_CITY_INTERACTIVE_UI_HIDE, self)
  end
end
function MainCityPlayerController:HandleClickFollowEmote()
  log(bWriteLog and "MainCityPlayerController:HandleClickFollowEmote")
  local uPlayerCharacter
  if self.GetPlayerCharacterSafety then
    uPlayerCharacter = self:GetPlayerCharacterSafety()
  else
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    uPlayerCharacter = GameplayData.GetPlayerCharacter()
  end
  if slua.isValid(uPlayerCharacter) then
    local PlayEmoteComp = uPlayerCharacter:GetPlayEmoteComponent()
    if PlayEmoteComp then
      log(bWriteLog and "MainCityPlayerController:HandleClickFollowEmote PlayEmoteComp do follow")
      PlayEmoteComp:OnFollowNearPlayerEmote()
      PlayEmoteComp:CheckNearPlayingEmote()
    end
  end
end
function MainCityPlayerController:ReceivePostReplayRecover()
  log(bWriteLog and "MainCityPlayerController:ReceivePostReplayRecover")
  if EVENTTYPE_MAINCITY then
    self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_FINISH, self.OnReplayRecoverFinish, self)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_MOD_EVENT_INIT_FINISH, function(_, _, ModName)
      if ModName == "MainCity" then
        self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_FINISH, self.OnReplayRecoverFinish, self)
      end
    end)
  end
end
function MainCityPlayerController:OnReplayRecoverFinish()
  log(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish")
  self:AddGameTimer(0.0, false, function()
    log(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish start recover..")
    if self.GetPlayerCharacterSafety == nil then
      log(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish GetPlayerCharacterSafety nil is replay controller return")
      return
    end
    if GameSafeCallbacks then
      GameSafeCallbacks.PostPlayerControllerLoginInit(self)
    end
    local uPlayerCharacter = self:GetPlayerCharacterSafety()
    if not slua.isValid(uPlayerCharacter) then
      print(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish uPlayerCharacter invalid")
      return
    end
    local FollowerComp = uPlayerCharacter:GetFollowMoveComp()
    if slua.isValid(FollowerComp) then
      FollowerComp:OnStopFollowerSystem()
      print(bWriteLog and "=>MainCityPlayerController:OnMainCityReplayRecoverFinish FollowerComp.OnStopFollowerSystem")
    end
    local uSkillManager = uPlayerCharacter:GetSkillManager()
    if slua.isValid(uSkillManager) then
      uSkillManager:ClearSkill(true, false, false)
      print(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish uSkillManager ClearSkill")
    else
      print(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish 2 uSkillManager invalid")
    end
    local uBuffComponent = uPlayerCharacter:GetBuffComponent()
    if slua.isValid(uBuffComponent) then
      uBuffComponent:ClearBuffs()
      print(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish uBuffComponent ClearBuffs")
    else
      print(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish 3 uBuffComponent invalid")
    end
    local uParent = uPlayerCharacter:GetAttachParentActor()
    printf("MainCityPlayerController:OnReplayRecoverFinish uParent = %s", tostring(uParent))
    if slua.isValid(uParent) and uParent.OnStoppedSkillAction and uParent:GetInteractiveComponent() then
      printf("MainCityPlayerController:OnReplayRecoverFinish uParent = %s, InteractiveComponent = %s", tostring(uParent), tostring(uParent:GetInteractiveComponent()))
      uParent:OnStoppedSkillAction(uPlayerCharacter, 0, 0, uParent:GetInteractiveComponent())
    end
    log(bWriteLog and "MainCityPlayerController:OnReplayRecoverFinish send replay_recover_finish_notify")
    local MainCity_ReplayRecover_DS_Handler = require("GameLua.Mod.MainCity.DS.Handler.MainCity_ReplayRecover_DS_Handler")
    MainCity_ReplayRecover_DS_Handler.replay_recover_finish_notify(Game:GetPlayerUID(uPlayerCharacter))
  end)
end
function MainCityPlayerController:LobbyNKey_Released()
  if not IsEditor then
    return
  end
  N_KeyClick()
end
function MainCityPlayerController:LobbyGKey_Released()
  if not IsEditor then
    return
  end
  G_KeyClick()
end
function MainCityPlayerController:CanExitFreeCamera()
  local uPlayerCharacter = self:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "MainCityPlayerController:CanExitFreeCamera uPlayerCharacter=nil")
    return true
  end
  local PlayerName = uPlayerCharacter:GetPlayerNameSafety()
  if uPlayerCharacter:HasState(EPawnState.FollowWalk) then
    local uFollowComp = uPlayerCharacter:GetFollowMoveComp()
    if Game:IsValid(uFollowComp) then
      if uFollowComp.FollowInfo.Type ~= ECharacterFollowType.CFS_None then
        print(bWriteLog and "[Warning]MainCityPlayerController:CanExitFreeCamera=0,In FollowWalk,PlayerName:" .. tostring(PlayerName) .. ",Role:" .. tostring(uPlayerCharacter.Role))
        return false
      else
        print(bWriteLog and "[Warning]MainCityPlayerController:CanExitFreeCamera=1,In FollowWalkPawnstate, but FollowInfo.Type=None ,PlayerName:" .. tostring(PlayerName) .. ",Role:" .. tostring(uPlayerCharacter.Role))
      end
    end
  end
  print(bWriteLog and "MainCityPlayerController:CanExitFreeCamera=1,PlayerName:" .. tostring(PlayerName) .. ",Role:" .. tostring(uPlayerCharacter.Role))
  return true
end
function MainCityPlayerController:BindMotionEvent()
  print(bWriteLog and "MainCityPlayerController:BindMotionEvent")
  local InputClass = import("ScreenInput")
  local UIUtil = require("client.common.ui_util")
  local WorldContextObject = UIUtil.GetGameInstance()
  self.ScreenInput = InputClass(WorldContextObject)
  self.ScreenInput:Init()
  self.ScreenInput.OnMotionDetected:Bind(function(Tilt, RotationRate, Gravity, Acceleration)
    self:OnMotionDetected(Tilt, RotationRate, Gravity, Acceleration)
  end)
end
function MainCityPlayerController:OnMotionDetected(Tilt, RotationRate, Gravity, Acceleration)
  EventSystem:postEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, RotationRate.X, RotationRate.Y, RotationRate.Z)
  if not Client.IsDeviceSupportGyrSensor() then
    print(bWriteLog and "MainCityPlayerController:MotionControlAndroid IsDeviceSupportGyrSensor false")
    return
  end
  if not self.ProcessMotionInput then
    return
  end
  self:ProcessMotionInput(RotationRate, self.PitchReverce, self.MotionTouchRate_Pitch, self.MotionTouchAimRate_Pitch, self.MotionRate_Pitch, self.MotionAimRate_Pitch, self.MotionTouchRate_Yaw, self.MotionTouchAimRate_Yaw, self.MotionRate_Yaw, self.MotionAimRate_Yaw, self.MotionRate_Pitch_Threshold, self.MotionRate_Yaw_Threshold, self.Left, self.Right, self.bLandScapeOrientation)
end
function MainCityPlayerController:UIMsg_SetAutoSprint()
  printf("MainCityPlayerController:UIMsg_SetAutoSprint.")
  self.bAutoSprint = not self.bAutoSprint
end
function MainCityPlayerController:OnLuaRep_Pawn()
  MainCityPlayerController.__super.OnLuaRep_Pawn(self)
  local CurPawn = self:K2_GetPawn()
  if not Game:IsValid(CurPawn) then
    printf(bWriteLog and "[Warning] MainCityPlayerController:OnLuaRep_Pawn: pawn not valid")
    return
  end
  print(bWriteLog and string.format("MainCityPlayerController:OnLuaRep_Pawn Begin PlayerName:%s Role:%d bIsChangeNewDS:%s", CurPawn:GetPlayerNameSafety(), CurPawn.Role, tostring(CurPawn.bIsChangeNewDS)))
  if CurPawn.bIsChangeNewDS then
    CurPawn:ResetStatus()
  end
  CurPawn.bIsChangeNewDS = false
  if CurPawn.GetAnimParamsComponent then
    local uAnimParamsComp = CurPawn:GetAnimParamsComponent()
    if slua.isValid(uAnimParamsComp) then
      print(bWriteLog and "MainCityCharCarryBackComponent:OnLuaRep_Pawn ReloadAdditionalAnim again!!")
      uAnimParamsComp:ReloadAdditionalAnim()
    end
  end
  if CurPawn.GetCarryBackComp then
    local CarryBackComp = CurPawn:GetCarryBackComp()
    if slua.isValid(CarryBackComp) then
      print(bWriteLog and "MainCityCharCarryBackComponent:OnLuaRep_Pawn CarryBackComp AsyncLoadAnims again!!")
      CarryBackComp:AsyncLoadAnims()
    end
  end
  print(bWriteLog and string.format("MainCityPlayerController:OnLuaRep_Pawn End set bIsChangeNewDS=0, PlayerName:%s Role:%d", CurPawn:GetPlayerNameSafety(), CurPawn.Role))
end
local class = require("class")
local CPlayerController = require("GameLua.GameCore.Framework.PlayerControllerBase")
local CMainCityPlayerController = class(CPlayerController, nil, MainCityPlayerController)
return require("combine_class").DeclareFeature(CMainCityPlayerController, {
  {
    InteractEmotePCFeature = "GameLua.Mod.MainCity.Gameplay.Feature.InteractEmotePCFeature"
  },
  {
    DebugFakePawnPCFeature = "GameLua.Mod.MainCity.Gameplay.Feature.DebugFakePawnPCFeature"
  }
}, "MainCityPlayerController")
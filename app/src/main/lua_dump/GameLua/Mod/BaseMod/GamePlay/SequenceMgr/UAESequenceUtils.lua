local UAESequenceUtils = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function UAESequenceUtils:ctor(_, uLevelSequenceActor)
  self.SequenceActor = uLevelSequenceActor
end
function UAESequenceUtils:ForbiddenPlayerInput(bForbidden)
  if not Client then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local character = GameplayStatics.GetPlayerCharacter(CGameWorld, 0)
  if slua.isValid(character) then
    local EMovementMode = import("EMovementMode")
    if bForbidden == "true" then
      Game:EnablePlayerInput(character, false)
    else
      Game:EnablePlayerInput(character, true)
    end
  end
end
function UAESequenceUtils:MoveCameraToTarget(target, time, func)
  if not Client then
    return
  end
  if slua.isValid(target) then
    local GameplayStatics = import("GameplayStatics")
    local playerController = GameplayStatics.GetPlayerController(self.SequenceActor, 0)
    if playerController then
      playerController:SetViewTargetWithBlend(target, time, func, 2, false)
      local BusinessHelper = import("BusinessHelper")
      local BaseCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
      if BusinessHelper.IsClassOf(target, BaseCharacterClass) then
        self:HandleInputEnable("true")
      else
        self:HandleInputEnable("false")
      end
    end
  end
end
function UAESequenceUtils:SetGlobalTimeDilation(dilation)
  if Client then
    return
  end
  dilation = tonumber(dilation) or 1
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.SetGlobalTimeDilation(self.SequenceActor, dilation)
end
function UAESequenceUtils:EnableCharacterSprint(bEnable)
  if not Client then
    return
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    local GameplayStatics = import("GameplayStatics")
    local playerController = GameplayStatics.GetPlayerController(self.SequenceActor, 0)
    if bEnable == "true" then
      playerController:ForceDropItemsWithType(1)
      playerController.bAutoSprint = false
    else
      playerController.bAutoSprint = true
    end
    OperateSubsystem:ActiveSprint()
  end
end
function UAESequenceUtils:PostEvt(EvtType, EvtID, ...)
  EventSystem:postEvent(_G[EvtType], _G[EvtID], ...)
end
function UAESequenceUtils:PlayCameraShake(ShakeClassPath, Scale)
  if not Client then
    return
  end
  Scale = tonumber(Scale) or 1
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  if uPlayerController and slua.isValid(uPlayerController) then
    if uPlayerController.PlayerCameraManager and slua.isValid(uPlayerController.PlayerCameraManager) then
      local ECameraAnimPlaySpace = import("ECameraAnimPlaySpace")
      local uShakeClass = slua.loadClass(ShakeClassPath)
      if slua.isValid(uShakeClass) then
        uPlayerController.PlayerCameraManager:PlayCameraShake(uShakeClass, Scale, ECameraAnimPlaySpace.CameraLocal, FRotator(0, 0, 0))
      else
        print(bWriteLog and "UAESequenceUtils:ClientPlayCameraShake, failed because ShakeClassPath is nil")
      end
    else
      print(bWriteLog and "UAESequenceUtils:ClientPlayCameraShake, failed because PlayerCameraManager is nil")
    end
  else
    print(bWriteLog and "UAESequenceUtils:ClientPlayCameraShake, failed because PlayerController is nil")
  end
end
function UAESequenceUtils:StopAllCameraShakes(bImmediately)
  if not Client then
    return
  end
  local temp = bImmediately == "true"
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  if slua.isValid(uPlayerController) then
    if slua.isValid(uPlayerController.PlayerCameraManager) then
      uPlayerController.PlayerCameraManager:StopAllCameraShakes(temp)
    else
      print(bWriteLog and "UAESequenceUtils:ClientStopAllCameraShakes, failed because PlayerCameraManager is nil")
    end
  else
    print(bWriteLog and "UAESequenceUtils:ClientStopAllCameraShakes, failed because PlayerController is nil")
  end
end
function UAESequenceUtils:ShowCharacter(strShow)
  if not Client then
    return
  end
  local bShow = false
  if strShow == "true" then
    bShow = true
  end
  local GameplayStatics = import("GameplayStatics")
  local character = GameplayStatics.GetPlayerCharacter(self.SequenceActor, 0)
  if slua.isValid(character) then
    character:SetActorHiddenInGame(not bShow)
  end
end
function UAESequenceUtils:HideAllUI()
  if not Client then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_TEAM_SHOW)
end
function UAESequenceUtils:RecoveryUI()
  if not Client then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_EXIT_TEAM_SHOW)
end
function UAESequenceUtils:PopTips(TipsID, ...)
  if not Client then
    return
  end
  IngameTipsTools.BattleGeneralTip(tonumber(TipsID), ...)
end
function UAESequenceUtils:ShowUI(WindowName)
  if not Client then
    return
  end
  BatttleWindowMgr.ShowUI(WindowName)
end
function UAESequenceUtils:HideUI(WindowName)
  if not Client then
    return
  end
  BatttleWindowMgr.HideUI(WindowName)
end
function UAESequenceUtils:FadeIn(AnimType, AnimSpeed)
  if not Client then
    return
  end
  if not UIManager then
    return
  end
  local FadeWindow = UIManager.GetUI(UIManager.UI_Config_InGame.FadeWindow)
  if not FadeWindow then
    UIManager.ShowUI(UIManager.UI_Config_InGame.FadeWindow)
  end
  FadeWindow = UIManager.GetUI(UIManager.UI_Config_InGame.FadeWindow)
  if FadeWindow then
    FadeWindow:FadeIn(AnimType, tonumber(AnimSpeed))
  end
end
function UAESequenceUtils:FadeOut(AnimType, AnimSpeed)
  if not Client then
    return
  end
  if not UIManager then
    return
  end
  local FadeWindow = UIManager.GetUI(UIManager.UI_Config_InGame.FadeWindow)
  if not FadeWindow then
    return
  end
  FadeWindow:FadeOut(AnimType, tonumber(AnimSpeed))
end
function UAESequenceUtils:AddCameraEffect(ParticleName, AttachPointName, Location, Rotation, Scale, bAutoDestory)
  if not Client then
    return
  end
  if AttachPointName == "" then
    AttachPointName = "None"
  end
  local uLocation
  if Location == "" then
    uLocation = FVector(100, 0, 0)
  else
    uLocation = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(Location))
  end
  local uRotation = GamePlayTools.TableToFRotator(GamePlayTools.StrToTable(Rotation))
  local uScale
  if Scale == "" then
    uScale = FVector(1, 1, 0)
  else
    uScale = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(Scale))
  end
  if bAutoDestory == "" then
    bAutoDestory = true
  else
    bAutoDestory = bAutoDestory == "true"
  end
  local BusinessHelper = import("BusinessHelper")
  local UGameplayStatics = import("GameplayStatics")
  local uSelfPlayer = UGameplayStatics.GetPlayerCharacter(self.SequenceActor, 0)
  local EAttachLocation = import("EAttachLocation")
  if uSelfPlayer and slua.isValid(uSelfPlayer) then
    local uParticle = BusinessHelper.LoadAssetFromPath(ParticleName)
    if uParticle and slua.isValid(uParticle) then
      UGameplayStatics.SpawnEmitterAttached(uParticle, uSelfPlayer.Camera, AttachPointName, uLocation, uRotation, uScale, EAttachLocation.KeepRelativeOffset, bAutoDestory)
    end
  end
end
function UAESequenceUtils:PlayScreenParticleEffect(EffectName, bShow)
  if not Client then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uSelfController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  local uSelfPlayer = uSelfController:GetCurPlayerCharacter()
  if uSelfPlayer and slua.isValid(uSelfPlayer) and uSelfPlayer.ScreenAppearaceComp then
    if bShow == "" or bShow == "true" then
      uSelfPlayer.ScreenAppearaceComp:StopScreenParticleEffectByName(EffectName)
      uSelfPlayer.ScreenAppearaceComp:PlayScreenParticleEffectByName(EffectName, 0.0)
    else
      uSelfPlayer.ScreenAppearaceComp:StopScreenParticleEffectByName(EffectName)
    end
  end
end
function UAESequenceUtils:PlayOrStopScreenUIEffect(Path, Duration, bStop)
  if not Client then
    return
  end
  if self.SequenceActor then
    local Character = self.SequenceActor:GetOwner()
    local ENetRole = import("ENetRole")
    if not slua.isValid(Character) or Character.Role ~= ENetRole.ROLE_AutonomousProxy then
      return
    end
  end
  local Param = "/Game/UMG/UI_BP/ScreenEffect/DarkEcho_ScreenEffect/ScreenEffect_250_DarkEcho_UIBP.ScreenEffect_250_DarkEcho_UIBP"
  if bStop == "true" then
    if slua.isValid(self.ScreenUIWidget) then
      self.ScreenUIWidget:ConditionalBeginDestroy()
      self.ScreenUIWidget = nil
    end
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uSelfController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  if not slua.isValid(uSelfController) then
    print(bWriteLog and "UAESequenceUtils:PlayScreenUIEffect not slua.isValid(uSelfController)")
    return
  end
  if slua.isValid(self.ScreenUIWidget) then
    self.ScreenUIWidget:ConditionalBeginDestroy()
    self.ScreenUIWidget = nil
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  self.ScreenUIWidget = USTExtraBlueprintFunctionLibrary.CreateWidgetByPathName(Path, uSelfController)
  print(bWriteLog and "UAESequenceUtils:PlayScreenUIEffect Play Path=" .. Path)
  if slua.isValid(self.ScreenUIWidget) then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if slua.isValid(MainControlPanelTochButton) then
      MainControlPanelTochButton.CanvasPanel_IPX:AddChild(self.ScreenUIWidget)
      self.ScreenUIWidget.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
      self.ScreenUIWidget.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    end
  else
    print(bWriteLog and "UAESequenceUtils:PlayScreenUIEffect not slua.isValid(self.ScreenUIWidget)")
  end
  self:AddTimer(tonumber(Duration), function()
    if slua.isValid(self.ScreenUIWidget) then
      self.ScreenUIWidget:ConditionalBeginDestroy()
      self.ScreenUIWidget = nil
      print(bWriteLog and "UAESequenceUtils:PlayScreenUIEffect Stop Path=" .. Path)
    end
  end)
end
function UAESequenceUtils:ShowOrHideFreeCameraBtn(bHide)
  if not Client then
    return
  end
  if self.SequenceActor then
    local Character = self.SequenceActor:GetOwner()
    local ENetRole = import("ENetRole")
    if not slua.isValid(Character) or Character.Role ~= ENetRole.ROLE_AutonomousProxy then
      return
    end
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local FreeCameraBtn = InGameUITools.GetNewFreeCameraBtn()
  if slua.isValid(FreeCameraBtn) then
    if bHide == "true" then
      FreeCameraBtn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      print(bWriteLog and "UAESequenceUtils:ShowOrHideFreeCameraBtn Hide FreeCameraBtn")
    else
      FreeCameraBtn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      print(bWriteLog and "UAESequenceUtils:ShowOrHideFreeCameraBtn Show FreeCameraBtn")
    end
  end
end
function UAESequenceUtils:RotatePlayerCamera(PitchStr, YawStr, RecoveryTimeStr)
  if not Client then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uSelfController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  local uSelfPlayer = UGameplayStatics.GetPlayerCharacter(self.SequenceActor, 0)
  local PawnViewRotation = uSelfPlayer:GetViewRotation()
  local Pitch = 0
  if PitchStr ~= "" then
    Pitch = tonumber(PitchStr) - PawnViewRotation.Pitch
  end
  local Yaw = 0
  if YawStr ~= "" then
    Yaw = tonumber(YawStr) - PawnViewRotation.Yaw
  end
  local SprintArmConponent = uSelfController:GetTargetedSpringArm()
  local uTargetRotator = FRotator(Pitch, Yaw, 0)
  SprintArmConponent:SetTargetFreeCameraInput(uTargetRotator)
  SprintArmConponent:SetFreeCameraAutoReturn(false)
  if RecoveryTimeStr ~= "" then
    local RecoveryTime = tonumber(RecoveryTimeStr)
    self:AddTimer(RecoveryTime, function()
      self:RecoveryPlayerCamera()
    end)
  end
end
function UAESequenceUtils:RecoveryPlayerCamera()
  if not Client then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uSelfController = UGameplayStatics.GetPlayerController(self.SequenceActor, 0)
  local SprintArmConponent = uSelfController:GetTargetedSpringArm()
  SprintArmConponent:SetFreeCameraAutoReturn(true)
end
function UAESequenceUtils:SpawnParticle(ParticleName, LocationStr, RotationStr, ScaleStr, bAutoDestory)
  if not Client then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local BusinessHelper = import("BusinessHelper")
  if bAutoDestory == "" then
    bAutoDestory = true
  else
    bAutoDestory = bAutoDestory == "true"
  end
  local uLocation = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(LocationStr))
  local uRotation = GamePlayTools.TableToFRotator(GamePlayTools.StrToTable(RotationStr))
  local uScale
  if ScaleStr == "" then
    uScale = FVector(1, 1, 1)
  else
    uScale = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(ScaleStr))
  end
  local uParticle = BusinessHelper.LoadAssetFromPath(ParticleName)
  if uParticle and slua.isValid(uParticle) then
    UGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uParticle, uLocation, uRotation, uScale, bAutoDestory)
  end
end
function UAESequenceUtils:TriggerSkillWithID(SkillIDStr)
  if not Client then
    return
  end
  local SkillID = tonumber(SkillIDStr)
  if SkillID == 0 then
    return
  end
  local game_frontend_hud = require("game_frontend_hud")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayer = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayer) then
    return
  end
  uPlayer:TriggerEntrySkillWithID(SkillID, true)
end
function UAESequenceUtils:SpawnActor(ActorClassName, LocationStr, RotationStr, ScaleStr, AutoDestoryTimeStr)
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  if not ActorTools then
    return
  end
  local Location = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(LocationStr))
  local Rotation = GamePlayTools.TableToFRotator(GamePlayTools.StrToTable(RotationStr))
  local Scale
  if ScaleStr == "" then
    Scale = FVector(1, 1, 1)
  else
    Scale = GamePlayTools.TableToFVector(GamePlayTools.StrToTable(ScaleStr))
  end
  local uActor = ActorTools.SpawnActor(self.SequenceActor, ActorClassName, Location, Rotation, Scale)
  if slua.isValid(uActor) and AutoDestoryTimeStr ~= "" then
    local AutoDestoryTime = tonumber(AutoDestoryTimeStr)
    self:AddTimer(AutoDestoryTime, function()
      uActor:ConditionalBeginDestroy()
    end)
  end
end
function UAESequenceUtils:TeleportAllPlayers(sTargetGroupActorName)
  if Client then
    return
  end
  Game:TeleportAllPlayers(sTargetGroupActorName)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CUAESequenceUtils = class(CDelegateContainer, nil, UAESequenceUtils)
return CUAESequenceUtils
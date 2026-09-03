local SI_BattleInterface = {}
local SocialIslandTools = require("GameLua.Mod.SocialIsland.GamePlay.SocialIslandTools")
local EStateType = import("EStateType")
local EMovementMode = import("EMovementMode")
function SI_BattleInterface.ClearPlayerStateBeforeEnter(nUID)
  print(bWriteLog and "SI_DsBattleInterface:ClearPlayerStateBeforeEnter nUID" .. nUID)
  local uPC = SocialIslandTools.GetPlayerControl(nUID)
  if Game:IsValid(uPC) then
    local uVehicleUserComp = uPC:GetVehicleUserComp()
    if Game:IsValid(uVehicleUserComp) then
      uVehicleUserComp:ForceExitVehicle(false, "ClearPlayerStateBeforeEnter", true)
    end
    local uCharacter = uPC:GetPlayerCharacterSafety()
    if Game:IsValid(uCharacter) then
      uCharacter:LeaveState(UEnums.EPawnState.Vault)
      uCharacter:LeaveState(UEnums.EPawnState.InParachute)
      uCharacter:LeaveState(UEnums.EPawnState.Sprint)
      uCharacter:CharacterStateReset()
      local uSkillManager = uCharacter:GetSkillManager()
      if Game:IsValid(uSkillManager) then
        uSkillManager:StopSkillAll(3)
      end
      local uPlayerWing = uCharacter.BP_PlayerWing
      if Game:IsValid(uPlayerWing) then
        uPlayerWing:EnableWingAvatar(false)
      end
      EventSystem:postEvent(EVENTTYPE_SOCIALISLAND, EVENTID_ISLAND_FORCE_EXIT_JETSPRING, uCharacter)
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAY_FORCE_EXIT_FIREBALL, uCharacter)
      if uPC.HeroPropFeature and uPC.HeroPropFeature.ServerChooseHeroData then
        uPC.HeroPropFeature:ServerChooseHeroData(0)
      end
    end
    if uPC:GetCurrentStateType() ~= EStateType.State_Fight then
      print(bWriteLog and " SI_DsBattleInterface:ClearPlayerStateBeforeEnter Force to State_Fight")
      uPC:ServerChangeStatePC(EStateType.State_Fight)
    end
  end
end
function SI_BattleInterface.SetPlayerCanMove(uCharacter, bEnable)
  print(bWriteLog and string.format(" SI_BattleInterface.SetPlayerCanMove:%s uCharacter, bEnable:%s", uCharacter, bEnable))
  local CharacterMovement = uCharacter.CharacterMovement
  if not slua.isValid(CharacterMovement) then
    return
  end
  if bEnable then
    uCharacter:SetReplicateMovement(true)
    CharacterMovement:SetMovementMode(EMovementMode.MOVE_Walking, 0)
    CharacterMovement:SetComponentTickEnabled(true)
    CharacterMovement:Activate(false)
  else
    CharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
    CharacterMovement:SetComponentTickEnabled(false)
    CharacterMovement:Deactivate()
  end
  if uCharacter:HasAuthority() then
    uCharacter:ForceNetUpdate()
  end
end
function SI_BattleInterface.StopSprint()
  print(bWriteLog and " SI_DsBattleInterface.StopSprint")
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if slua.isValid(uPlayerController) and uPlayerController and uPlayerController.bAutoSprint then
    local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
    if OperateSubsystem then
      OperateSubsystem:BleSprint()
    end
    print(bWriteLog and " SI_DsBattleInterface.StopSprint SwitchPoseState To Stand")
  end
end
function SI_BattleInterface.ClientSetFpp(explicitValidChar, isFpp)
  explicitValidChar:SetCurrentPersonPerspective(isFpp, false)
end
function SI_BattleInterface.DsSetFpp(explicitValidPlayerController, isFpp)
  print(bWriteLog and string.format(" SI_BattleInterface.DsSetFpp explicitValidPlayerController:%s, isFpp:%s", explicitValidPlayerController, isFpp))
  explicitValidPlayerController:SwitchFpp(isFpp)
end
function SI_BattleInterface.SwitchWeaponNone(explicitValidChar)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  explicitValidChar:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
end
function SI_BattleInterface.SetViewTargetToSelf(explicitValidPlayerController, explicitValidChar)
  print(bWriteLog and " SI_BattleInterface.SetViewTargetToSelf")
  local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
  explicitValidPlayerController:SetViewTargetWithBlend(explicitValidChar, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
end
function SI_BattleInterface.SocialIslandEmoteCheck(shouldShowNotice)
  local EGameModeType = import("EGameModeType")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return true
  end
  if GameState.GameModeType == EGameModeType.ESocialIsland then
    local playerState = GameplayData.GetPlayerState()
    if false == playerState:CanPlayerInteractEmote() then
      if shouldShowNotice == nil or shouldShowNotice then
        ShowNotice(7474)
      end
      return false
    end
  end
  return true
end
return SI_BattleInterface
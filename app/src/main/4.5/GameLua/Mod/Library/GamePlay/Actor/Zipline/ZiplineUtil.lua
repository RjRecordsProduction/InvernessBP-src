local ZiplineUtil = {}
local EPawnState = import("EPawnState")
local ENetRole = import("ENetRole")
local UGameplayStatics = import("GameplayStatics")
function ZiplineUtil:EnableMoveControl(uCharacter, bEnable)
  print(bWriteLog and "ZiplineUtil:EnableMoveControl:", bEnable)
  if not slua.isValid(uCharacter) then
    return
  end
  if bEnable then
    uCharacter:K2_DetachFromActor(1, 1, 1)
  end
  local EMovementMode = import("EMovementMode")
  if bEnable then
    uCharacter:SetReplicateMovement(true)
    uCharacter.CharacterMovement:SetMovementMode(EMovementMode.MOVE_Walking, 0)
    uCharacter.CharacterMovement:Activate(false)
    uCharacter.CharacterMovement:SetComponentTickEnabled(true)
    if uCharacter.Role == ENetRole.ROLE_SimulatedProxy then
      uCharacter.CharacterMovement:SetClientReceiveServerStateTimestamp(UGameplayStatics.GetTimeSeconds(CGameWorld))
    elseif uCharacter.Role == ENetRole.ROLE_Authority then
      uCharacter.CharacterMovement:ForceNetUpdate()
    end
  else
    uCharacter:SetReplicateMovement(false)
    uCharacter.CharacterMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
    uCharacter.CharacterMovement:Deactivate()
    uCharacter.CharacterMovement:SetComponentTickEnabled(false)
  end
end
function ZiplineUtil.EnableFreeView(uCharacter, bEnable)
  if not slua.isValid(uCharacter) then
    return
  end
  print(bWriteLog and "ZiplineUtil:EnableFreeView:", bEnable)
  local uSpringArmComp = uCharacter.SpringArmComp
  if bEnable then
    uCharacter.bSyncCameraByChar = true
    uCharacter.bUseControllerRotationYaw = false
    if slua.isValid(uSpringArmComp) then
      uSpringArmComp.TargetArmLength = 500
    end
  else
    uCharacter.bSyncCameraByChar = false
    uCharacter.bUseControllerRotationYaw = true
    if slua.isValid(uSpringArmComp) then
      uSpringArmComp.TargetArmLength = 220
    end
  end
end
function ZiplineUtil.HideBattleUI(uCharacter, bHide)
  if not Client then
    return
  end
  if not slua.isValid(uCharacter) then
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if not uPlayerController.GetPlayerCharacterSafety then
    return
  end
  local FirstCharacter = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(FirstCharacter) or FirstCharacter ~= uCharacter then
    return
  end
  local ESlateVisibility = import("ESlateVisibility")
  local Visibility = bHide and ESlateVisibility.Collapsed or ESlateVisibility.SelfHitTestInvisible
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) then
    ShootingUIPanel:SetWidgetVisibility(Visibility)
  end
  if bHide then
    local BasicSkillMenuUI = InGameUITools.GetBasicSkillsMenuUI()
    if BasicSkillMenuUI then
      BasicSkillMenuUI:HideEnterVehicleButtons()
    end
  end
  if bHide then
    uPlayerController:JoystickTriggerSprint(false)
  end
end
function ZiplineUtil.EnablePet(uCharacter, bEnable)
  print(bWriteLog and "ZiplineUtil:EnablePet", bEnable)
  local EPetState = import("EPetState")
  if uCharacter.PetComponent_BP then
    if bEnable then
      uCharacter.PetComponent_BP:PetLeaveState(EPetState.PetDisappear)
    else
      uCharacter.PetComponent_BP:PetEnterState(EPetState.PetDisappear)
    end
  end
end
return ZiplineUtil
local SkillActorInst = {
  __parent = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/Execute/Skill_Template_Execute.Skill_Template_Execute_C",
  Inst = {
    SkillData = {
      PawnState = "EPawnState::MeleeAttack",
      bNeedSync = true,
      SkillName = "\229\149\134\228\184\154\229\140\150\229\164\132\229\134\179",
      bSinglePhaseRep = false,
      bNeedAutonomousClientSimulate = true,
      SkillBlackboardParamList = {
        [2] = {
          ResetRuleArray = {
            [1] = "ESkillBlackboardResetRule::ESBBRR_SkillEnd"
          },
          Name = "ExecutePlanID",
          Type = "EUAEBlackboardType::EBT_Int"
        }
      }
    },
    [0] = {
      PhaseData = {
        PhaseDuration = 0.0,
        SyncBBKArray = {
          [2] = {
            SelectedKeyName = "ExecutePlanID"
          }
        }
      },
      SwitchWeapon01 = {bUseAnim = false},
      DisablePawnState01 = {
        PendingDisablePawnStates = {
          [2] = {
            State = "EPawnState::Save"
          }
        },
        bReverseAlteredStatesOnUndo = true,
        bReverseAlteredStatesOnReset = false
      }
    },
    [1] = {
      PhaseData = {PhaseDuration = 10.0},
      ["/Script/Skill.UTSkillAction_Lua"] = {
        __InsertIndex = 1,
        LuaFilePath = "GameLua.Mod.Library.GamePlay.Skill.SkillAction.SkillAction_ExecuteHitFrameTimer",
        BaseData = {
          ActionRole = "ESkillActionRole::ESAR_Authority"
        },
        __NewClassPath = "/Script/Skill.UTSkillAction_Lua"
      },
      ["/Script/Skill.UTSkillAction_Lua-2"] = {
        __InsertIndex = 2,
        LuaFilePath = "GameLua.Mod.Library.GamePlay.Skill.SkillAction.SkillAction_ExecuteSequencePlayer",
        BaseData = {
          ActionRole = "ESkillActionRole::ESAR_AutonomousSimulated"
        },
        __NewClassPath = "/Script/Skill.UTSkillAction_Lua"
      },
      ["/Script/Addons.UAESkillAction_PlayMontageByTable"] = {
        __InsertIndex = 3,
        RelatedMontageColumns = {
          [1] = "TargetMontage"
        },
        AnimStopAfterSkill = true,
        __NewClassPath = "/Script/Addons.UAESkillAction_PlayMontageByTable"
      },
      ["/Script/Addons.UAESkillAction_PlayMontageByTable-2"] = {
        __InsertIndex = 4,
        MontageColumnName = "TargetMontage",
        RelatedMontageColumns = {
          [1] = "ExecutorMontage"
        },
        AnimStopAfterSkill = true,
        TargetPawnKey = "ExecuteTarget",
        __NewClassPath = "/Script/Addons.UAESkillAction_PlayMontageByTable"
      },
      ["/Script/Skill.UTSkillAction_Lua-3"] = {
        __InsertIndex = 5,
        LuaFilePath = "GameLua.Mod.Library.GamePlay.Skill.SkillAction.SkillAction_UpdateExecuteState",
        __NewClassPath = "/Script/Skill.UTSkillAction_Lua"
      }
    }
  }
}
function SkillActorInst:CanExecuteTarget()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local Owner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(Owner) then
    return false
  end
  local uTarget = self.SpecificSkillCompRef:GetValueAsWeakObject(self.SkillID, "ExecuteTarget")
  if not slua.isValid(uTarget) then
    print(bWriteLog and "Skill_Execute:CanExecuteTarget ExecuteTarget invalid")
    return false
  end
  local uRescueComp = Owner.RescueOtherComponent
  if slua.isValid(uRescueComp) and uRescueComp.IsOtherCanExecute then
    return uRescueComp:IsOtherCanExecute(uTarget, Owner, true, false)
  end
  return not uTarget.bDead
end
function SkillActorInst:DoAlignCharacters()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwnerPawn = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  local uTarget = self.SpecificSkillCompRef:GetValueAsWeakObject(self.SkillID, "ExecuteTarget")
  if not slua.isValid(uTarget) then
    print(bWriteLog and "Skill_Execute:CanExecuteTarget ExecuteTarget invalid")
    return false
  end
  self.CachedTarget = uTarget
  self.CachedTargetLocation = uTarget:K2_GetActorLocation()
  local Location = uOwnerPawn:K2_GetActorLocation()
  local Rotation = uOwnerPawn:K2_GetActorRotation()
  Location.Z = self.CachedTargetLocation.Z
  uTarget:K2_SetActorLocation(Location, false, nil, true)
  uTarget:K2_SetActorRotation(Rotation, true)
  local uTargetController = uTarget:GetPlayerControllerSafety()
  if slua.isValid(uTargetController) then
    uTargetController:SetControlRotation(Rotation, "ExecuteSetPosition")
  end
  return true
end
function SkillActorInst:UndoAlignCharacters()
  self:ResetTargetPosition()
end
function SkillActorInst:ResetTargetPosition()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwnerPawn = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  local uTarget = self.SpecificSkillCompRef:GetValueAsWeakObject(self.SkillID, "ExecuteTarget")
  if not (slua.isValid(uTarget) and slua.isValid(self.CachedTarget)) or uTarget ~= self.CachedTarget then
    print(bWriteLog and "Skill_Execute:CanExecuteTarget ExecuteTarget invalid")
    return false
  end
  if not Client then
    local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
    local SafetyResolveParams = FResolvePenetrationParams()
    SafetyResolveParams.BackDir = uOwnerPawn:GetActorForwardVector()
    SafetyResolveParams.IterationBackDir = 3
    SafetyResolveParams.AdjustRadius = 50
    SafetyResolveParams.bRaiseUpAdjust = false
    SafetyResolveParams.IterationRounds = 0
    slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(uOwnerPawn)
    uTarget:SetActorLocationSafetyWithParams(self.CachedTargetLocation, SafetyResolveParams)
    uTarget:ClientSetActorLocation(self.CachedTargetLocation, false)
  end
  return true
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst
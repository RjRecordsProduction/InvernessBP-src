local SkillAction_GrenadeThrowReport = {
  sObjectName = "SkillAction_GrenadeThrowReport"
}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
function SkillAction_GrenadeThrowReport:ctor(selfType)
end
function SkillAction_GrenadeThrowReport:LuaRealDoAction()
  if not Client then
    return false
  end
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  if not Client.IsEditor() and not Client.IsDevelopment() and not GameReportUtils.CheckCanBugglyPostException("GrenadeThrowException3") then
    return false
  end
  print(bWriteLog and "SkillAction_GrenadeThrowReport:LuaRealDoAction")
  local uPlayerPawn = self:GetOwnerPawn()
  if slua.isValid(uPlayerPawn) then
    local SkillManager = uPlayerPawn:GetSkillManager()
    if not slua.isValid(SkillManager) then
      return false
    end
    local uCurSkill = self:GetOwnerSkill()
    if not slua.isValid(uCurSkill) then
      return false
    end
    local SkillDataList = SkillManager.NewSkillSinglePhaseData.SkillData
    for _, SkillData in pairs(SkillDataList) do
      if 1002004 == SkillData.SkillID and false == SkillData.bSkillStop then
        local DSPhaseIndex = SkillData.CurSkillPhase
        if DSPhaseIndex == 2 then
          print(bWriteLog and "Warning! SkillAction_GrenadeThrowReport:LuaRealDoAction DSPhaseIndex equal 2")
          local World = slua_GameFrontendHUD:GetWorld()
          local StackTraceString = USTExtraBlueprintFunctionLibrary.GetStackTraceString(World)
          print(bWriteLog and "SkillAction_GrenadeThrowReport StackTraceString:", StackTraceString)
          local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
          local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
          local UKismetSystemLibrary = import("KismetSystemLibrary")
          local Owner1String = ""
          local Owner1 = SkillManager.OwnerActor
          if slua.isValid(Owner1) then
            local bOwnerActorHasAuthority = Owner1:HasAuthority()
            local OwnerActorRole = Owner1.Role
            local OwnerAttachParent = Owner1:GetAttachParentActor()
            local OwnerActorName = UKismetSystemLibrary.GetObjectName(Owner1)
            local OwnerCurVehicle
            if GameLuaAPI.IsClassOf(Owner1, ASTExtraBaseCharacter) then
              OwnerActorName = Owner1:GetPlayerNameSafety()
              OwnerCurVehicle = Owner1:GetCurrentVehicle()
            end
            Owner1String = string.format("Owner1:%s, bOwnerActorHasAuthority:%s OwnerActorRole:%s OwnerAttachParent:%s, OwnerActorName:%s, OwnerCurVehicle:%s", tostring(Owner1), tostring(bOwnerActorHasAuthority), tostring(OwnerActorRole), OwnerAttachParent, OwnerActorName, tostring(OwnerCurVehicle))
          end
          local Owner2String = ""
          local Owner2 = SkillManager:GetOwner()
          if slua.isValid(Owner2) then
            local bOwnerActorHasAuthority = Owner2:HasAuthority()
            local OwnerActorRole = Owner2.Role
            local OwnerAttachParent = Owner2:GetAttachParentActor()
            local OwnerActorName = UKismetSystemLibrary.GetObjectName(Owner2)
            local OwnerCurVehicle
            if GameLuaAPI.IsClassOf(Owner2, ASTExtraBaseCharacter) then
              OwnerActorName = Owner2:GetPlayerNameSafety()
              OwnerCurVehicle = Owner2:GetCurrentVehicle()
            end
            Owner2String = string.format("Owner2:%s, bOwnerActorHasAuthority:%s OwnerActorRole:%s OwnerAttachParent:%s, OwnerActorName:%s, OwnerCurVehicle:%s", tostring(Owner2), tostring(bOwnerActorHasAuthority), tostring(OwnerActorRole), OwnerAttachParent, OwnerActorName, tostring(OwnerCurVehicle))
          end
          return true
        end
      end
    end
  end
  return false
end
function SkillAction_GrenadeThrowReport:ReportExceptionMsgBox(sReportSting)
  local CheckExceptionString = string.format("GrenadeThrowException3: %s", sReportSting)
  print(bWriteLog and string.format("SkillAction_GrenadeThrowReport:ReportExceptionMsgBox CommonMsgBoxMgr %s", sReportSting))
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(1, "\229\189\147\229\137\141\229\175\185\229\177\128\229\173\152\229\156\168\230\138\149\230\142\183\228\191\161\230\129\175\229\188\130\229\184\184" .. CGame:GetCurDateTimeString(), "\232\175\183\230\143\144\229\143\150log\232\129\148\231\179\187 albinliao \231\161\174\232\174\164\239\188\140\230\132\159\232\176\162\239\188\129:\n" .. CheckExceptionString, nil)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_TeleportPawn = class(CSkillNodeBase, nil, SkillAction_GrenadeThrowReport)
return CSkillAction_TeleportPawn
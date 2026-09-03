local SkillAction_ConsumeItem = {
  sObjectName = "SkillAction_ConsumeItem"
}
function SkillAction_ConsumeItem:LuaRealDoAction()
  print(bWriteLog and string.format("%s:LuaRealDoAction", self.sObjectName))
  local uOwnerPawn = self:GetOwnerPawn()
  local ENetRole = import("ENetRole")
  local uCurSkill = self:GetOwnerSkill()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  if not slua.isValid(uCurSkill) then
    return false
  end
  local uSkillManagerComp = self:GetOwnerSkillManager()
  if not slua.isValid(uSkillManagerComp) then
    return false
  end
  self:SetValueAsBool("IsReallyUseItem", true)
  local weaponId
  if uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    return false
  end
  local weapon = uOwnerPawn:GetCurrentWeapon()
  if weapon then
    local DefineID = weapon:GetItemDefineID()
    if DefineID then
      weaponId = DefineID.TypeSpecificID
      local uPC = uOwnerPawn:GetPlayerControllerSafety()
      local EBattleItemDropReason = import("EBattleItemDropReason")
      local SecuryInfoCollectorComponent = uOwnerPawn:GetPlayerSecuryInfoCollectorComponent()
      if slua.isValid(SecuryInfoCollectorComponent) then
        local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local uBackpackComponent = uSTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uOwnerPawn)
        log(bWriteLog and "  SkillAction_ConsumeItem:LuaRealDoAction.  ConsumeItem" .. tostring(weaponId))
        local ConsumeNum = uBackpackComponent:ConsumeItem(DefineID, 1)
        if slua.isValid(uPC) then
          uPC:RPC_OwnerClient_PlayerConsumeItem(DefineID, 1)
        end
        if uOwnerPawn.CalculateTakeItemFlow then
          uOwnerPawn:CalculateTakeItemFlow(weaponId, ConsumeNum)
        end
      else
        log(bWriteLog and "  SkillAction_ConsumeItem:LuaRealDoAction.  ServerDropItem" .. tostring(weaponId))
        uPC:ServerDropItem(DefineID, 1, EBattleItemDropReason.Force)
      end
      if weaponId and uOwnerPawn.SetSpecifiedItemConsumed then
        uOwnerPawn:SetSpecifiedItemConsumed(weaponId)
      end
    end
  end
  return true
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillAction_ResetAutoAddSkill = class(CObjectBase, nil, SkillAction_ConsumeItem)
return CSkillAction_ResetAutoAddSkill
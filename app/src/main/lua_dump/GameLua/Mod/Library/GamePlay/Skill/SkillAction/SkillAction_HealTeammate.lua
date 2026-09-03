local SkillAction_HealTeammate = {
  tMedicalItemID = {
    [601004] = {percent = 0.75, tlogID = 1589},
    [601005] = {percent = 0.75, tlogID = 1590},
    [601006] = {percent = 1, tlogID = 1591}
  }
}
local EPawnState = import("EPawnState")
local ERecoveryReasonType = import("ERecoveryReasonType")
function SkillAction_HealTeammate:ctor()
end
function SkillAction_HealTeammate:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  local uOwnerSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  if not (slua.isValid(uOwnerPawn) and slua.isValid(uOwnerSkill)) or not slua.isValid(uSkillManager) then
    return false
  end
  if not uOwnerPawn:IsAuthority() then
    return false
  end
  local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
  if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("STExtraBaseCharacter")) then
    printf(bWriteLog and "SkillAction_HealTeammate uTargetTeammate not value PlayerKey:%u", uOwnerPawn.PlayerKey)
    return false
  end
  if not (not uTargetTeammate:HasState(EPawnState.Dying) and uTargetTeammate:IsHealthyAlive()) or not uTargetTeammate:IsHealthAlive() then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792208)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u uTargetTeammate Health Error", uOwnerPawn.PlayerKey)
    return false
  end
  local nItemID = self:GetValueAsUInt("ItemID")
  if nItemID == 0 then
    printf(bWriteLog and "SkillAction_HealTeammate nItemID == 0 PlayerKey:%u", uOwnerPawn.PlayerKey)
    return false
  end
  local ItemInfo = self.tMedicalItemID[nItemID]
  if ItemInfo == nil then
    printf(bWriteLog and "SkillAction_HealTeammate PlayerKey:%u nItemID:%d invalid", uOwnerPawn.PlayerKey, nItemID)
    return false
  end
  local CurHealthPercent = uTargetTeammate.Health / uTargetTeammate.HealthMax
  if CurHealthPercent >= ItemInfo.percent then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792208)
    printf(bWriteLog and "SkillAction_HealTeammate PlayerKey:%u CurHealthPercent:%f invalid", uOwnerPawn.PlayerKey, CurHealthPercent)
    return false
  end
  local uPC = uOwnerPawn:GetPlayerControllerSafety()
  if slua.isValid(uPC) then
    local uBackPackComp = uPC:GetBackpackComponent()
    if slua.isValid(uBackPackComp) then
      local nCount = uBackPackComp:GetItemCountByItemSpecialID(nItemID)
      if nCount < 1 then
        printf(bWriteLog and "SkillAction_HealTeammate PlayerKey:%u nItemID:%u nCount:%d invalid", uOwnerPawn.PlayerKey, nItemID, nCount)
        return
      end
      local FItemDefineID = import("ItemDefineID")
      local DefineID = FItemDefineID(6, nItemID)
      uBackPackComp:ConsumeItem(DefineID, 1)
    end
  end
  if nItemID == 601004 then
    local uBuffMgr = uTargetTeammate.BuffSystem
    if slua.isValid(uBuffMgr) and uBuffMgr:HasBuff(10122) then
      local LastAddBuffInstID = 0
      local LastAddPawn
      if uOwnerPawn.GetLastAddBuffInst then
        LastAddBuffInstID, LastAddPawn = uOwnerPawn:GetLastAddBuffInst()
      end
      if 0 < LastAddBuffInstID and slua.isValid(LastAddPawn) and LastAddPawn.PlayerKey == uTargetTeammate.PlayerKey and uBuffMgr:IsBuffInstExist(LastAddBuffInstID) then
        local fAddHealthMax = uTargetTeammate.HealthMax * ItemInfo.percent
        local fAddHealth = 2
        local fTargetHealth = fAddHealth + uTargetTeammate.Health
        if fAddHealthMax < fTargetHealth then
          fAddHealth = fAddHealthMax - uTargetTeammate.Health
        end
        if 0 < fAddHealth then
          printf("debugbandgehealth SkillAction_HealTeammate fAddHealth:%f PlayerName:%s InstID:%d", fAddHealth, uOwnerPawn:GetPlayerNameSafety(), LastAddBuffInstID)
          uTargetTeammate:AddAttrValue("Health", fAddHealth, ERecoveryReasonType.ERecoveryReason_Medicine)
        end
      end
    end
    local buffInstID = uTargetTeammate:AddBuffByID(10122, uOwnerPawn, 1, uOwnerSkill.SkillID, 1)
    if uOwnerPawn.SetLastAddBuffInst then
      uOwnerPawn:SetLastAddBuffInst(buffInstID, uTargetTeammate)
    end
  else
    local fAddHealth = uTargetTeammate.HealthMax * ItemInfo.percent
    fAddHealth = fAddHealth - uTargetTeammate.Health
    if 0 < fAddHealth then
      uTargetTeammate:AddAttrValue("Health", fAddHealth, ERecoveryReasonType.ERecoveryReason_Medicine)
    end
  end
  local uPlayerState = uOwnerPawn:GetPlayerStateSafety()
  if slua.isValid(uPlayerState) then
    uPlayerState:AddGeneralCount(ItemInfo.tlogID, 1, false)
    local uTargetPlayerState = uTargetTeammate:GetPlayerStateSafety()
    if slua.isValid(uTargetPlayerState) then
      local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
      DSCommonTLogSubsystem:AddPlayerCommonTLogData(uTargetPlayerState.UID, 192, tostring(uPlayerState.UID), false)
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERACTIVE_BEHAVIOR, uTargetPlayerState.UID, uPlayerState.UID, "AddBlood")
      printf(" SkillAction_HealTeammate AddPlayerCommonTLogData :%d , uPlayerState.UID:%s  uTargetPlayerState.UID:%s", 192, tostring(uPlayerState.UID), tostring(uTargetPlayerState.UID))
    end
    uPlayerState:AddGeneralCount(1601, 1, false)
  end
  Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792209)
  return true
end
function SkillAction_HealTeammate:LuaResetAction()
end
function SkillAction_HealTeammate:LuaUndoAction()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CObjectBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_HealTeammate = class(CObjectBase, nil, SkillAction_HealTeammate)
return CSkillAction_HealTeammate
local SkillAction_ReportHealToTLog = {
  sObjectName = "SkillAction_ReportHealToTLog"
}
function SkillAction_ReportHealToTLog:ctor(selfType)
  print(bWriteLog and "SkillAction_ReportHealToTLog:ctor")
end
function SkillAction_ReportHealToTLog:LuaRealDoAction()
  print(bWriteLog and string.format("%s:LuaRealDoAction", self.sObjectName))
  local uOwnerPawn = self:GetOwnerPawn()
  local ENetRole = import("ENetRole")
  if not slua.isValid(uOwnerPawn) or uOwnerPawn.Role ~= ENetRole.ROLE_Authority then
    print(bWriteLog and "SkillAction_ReportHealToTLog:LuaRealDoAction - Owner is invalid or not authority")
    return false
  end
  self:AddControlEvent(uOwnerPawn, "OnHealDynamicDelegate", self.OnHealCallback, self)
  return true
end
function SkillAction_ReportHealToTLog:OnHealCallback(RealAddVal, HealTarget, Reason)
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  if self.Reason and self.Reason ~= Reason then
    return
  end
  local TlogTypeName = self.TlogTypeName
  local TlogID = self.TlogID
  local nHealValue = RealAddVal or 0
  local bReset = false
  if self.bReset then
    bReset = true
  end
  print(bWriteLog and string.format("SkillAction_ReportHealToTLog:OnHealCallback - HealValue:%s", tostring(nHealValue)))
  if TlogTypeName and TlogTypeName == "TlogForRound" and TlogID and 0 < TlogID then
    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    if DSCommonTLogSubsystem then
      DSCommonTLogSubsystem:AddCommonTLog(TlogID, nHealValue, bReset)
      print(bWriteLog and string.format("SkillAction_ReportHealToTLog:OnHealCallback - AddCommonTLog TlogID:%s Value:%s", tostring(TlogID), tostring(nHealValue)))
    end
  elseif uOwnerPawn.GetPlayerStateSafety then
    local playerState = uOwnerPawn:GetPlayerStateSafety()
    if slua.isValid(playerState) and TlogID and 0 < TlogID then
      playerState:AddGeneralCount(TlogID, nHealValue, bReset)
      print(bWriteLog and string.format("SkillAction_ReportHealToTLog:OnHealCallback - AddGeneralCount UID:%s TlogID:%s Value:%s", tostring(playerState.UID), tostring(TlogID), tostring(nHealValue)))
    end
  end
end
function SkillAction_ReportHealToTLog:LuaResetAction()
  local uOwnerPawn = self:GetOwnerPawn()
  local ENetRole = import("ENetRole")
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    self:RemoveControlEvent(uOwnerPawn, "OnHealDynamicDelegate")
  end
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillActionBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ReportHealToTLog = class(CSkillActionBase, nil, SkillAction_ReportHealToTLog)
return CSkillAction_ReportHealToTLog
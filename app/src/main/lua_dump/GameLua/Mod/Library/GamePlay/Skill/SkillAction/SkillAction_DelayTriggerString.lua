local SkillAction_DelayTriggerStringEvent = {
  sObjectName = "SkillAction_DelayTriggerStringEvent",
  StringEvent = "",
  DelayTimeBBKey = ""
}
function SkillAction_DelayTriggerStringEvent:ctor(selfType)
  self.DelayTime = 5.0
  self.TriggerTimer = nil
end
function SkillAction_DelayTriggerStringEvent:LuaRealDoAction()
  if Client then
    return false
  end
  if not self.StringEvent then
    return false
  end
  if self.StringEvent == "" then
    return false
  end
  local uOwnerPawn = self:GetOwnerPawn()
  local nCurSkillID = -1
  if self.DelayTimeBBKey and self.DelayTimeBBKey ~= "" and slua.isValid(uOwnerPawn) then
    local uSkillMgr = uOwnerPawn:GetSkillManager()
    if slua.isValid(uSkillMgr) then
      nCurSkillID = uSkillMgr:GetCurSkillID()
      if 0 < nCurSkillID then
        local TempDuration = Game:GetSkillBlackboardValue(uOwnerPawn, nCurSkillID, UEnums.EBlackBoardKeyType.Float, self.DelayTimeBBKey)
        if 0 < TempDuration then
          self.DelayTime = TempDuration
        end
      end
    end
  end
  print(bWriteLog and string.format("SkillAction_DelayTriggerStringEvent:LuaRealDoAction DelayTime:%s StringEvent:%s", self.DelayTime, self.StringEvent))
  self.TriggerTimer = self:AddGameTimer(self.DelayTime, false, function()
    self:TriggerCurSkillStringEvent(nCurSkillID, self.StringEvent)
  end)
  return true
end
function SkillAction_DelayTriggerStringEvent:TriggerCurSkillStringEvent()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) then
    local uSkillMgr = uOwnerPawn:GetSkillManager()
    if slua.isValid(uSkillMgr) then
      local nCurSkillID = uSkillMgr:GetCurSkillID()
      if 0 < nCurSkillID then
        print(bWriteLog and string.format("SkillAction_DelayTriggerStringEvent:TriggerStringEvent StringEvent:%s", self.StringEvent))
        uSkillMgr:TriggerStringEvent(nCurSkillID, self.StringEvent)
      end
    end
  end
end
function SkillAction_DelayTriggerStringEvent:LuaUndoAction()
  SkillAction_DelayTriggerStringEvent.__super.LuaUndoAction(self)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_DelayTriggerStringEvent = class(CSkillNodeBase, nil, SkillAction_DelayTriggerStringEvent)
return CSkillAction_DelayTriggerStringEvent
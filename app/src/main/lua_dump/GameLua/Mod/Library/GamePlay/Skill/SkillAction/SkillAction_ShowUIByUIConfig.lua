local SkillAction_ShowUIByUIConfig = {
  sObjectName = "SkillAction_ShowUIByUIConfig"
}
function SkillAction_ShowUIByUIConfig:ctor(selfType)
end
function SkillAction_ShowUIByUIConfig:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and uOwnerPawn:IsLocallyControlled() then
    if self.bClose and self.bClose > 0 then
      self:ShowOrHideUI(false, true)
    else
      self:ShowOrHideUI(true)
    end
  end
  return true
end
function SkillAction_ShowUIByUIConfig:LuaResetAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and uOwnerPawn:IsLocallyControlled() then
    local bHideWhenReset = self.bReset and self.bReset > 0
    if bHideWhenReset then
      self:ShowOrHideUI(false)
    end
  end
end
function SkillAction_ShowUIByUIConfig:LuaUndoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and uOwnerPawn:IsLocallyControlled() then
    printf("SkillAction_ShowUIByUIConfig:LuaUndoAction, self.bUndo: %s, self.bReset: %s", self.bUndo, self.bReset)
    local bHideWhenUndo = self.bUndo and self.bUndo > 0
    if bHideWhenUndo then
      self:ShowOrHideUI(false)
    end
  end
  SkillAction_ShowUIByUIConfig.__super.LuaUndoAction(self)
end
function SkillAction_ShowUIByUIConfig:ShowOrHideUI(bShow, bForceClose)
  if not Client then
    return
  end
  local UIConfigName = self.UIConfigName
  local UIConfig = UIManager.UI_Config_InGame[UIConfigName]
  if UIConfig then
    if bShow then
      if not UIManager.IsUIShow(UIConfig) then
        UIManager.ShowUI(UIConfig)
      end
      print(bWriteLog and string.format("SkillAction_ShowUIByUIConfig:ShowOrHideUI Show %s", UIConfigName))
    else
      local bNeedClose = self.bNeedClose and self.bNeedClose > 0
      if bForceClose or bNeedClose then
        UIManager.CloseUI(UIConfig)
      else
        UIManager.HideUI(UIConfig)
      end
      print(bWriteLog and string.format("SkillAction_ShowUIByUIConfig:ShowOrHideUI Hide %s, traceback: %s", UIConfigName, debug.traceback()))
    end
  else
    printf("SkillAction_ShowUIByUIConfig:ShowOrHideUI UIConfig %s not found", UIConfigName)
  end
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ShowUIByUIConfig = class(CSkillNodeBase, nil, SkillAction_ShowUIByUIConfig)
return CSkillAction_ShowUIByUIConfig
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
function ShootingUIPanelIMP:Skill_ctor()
  self.bOverrideMaxFps = false
end
function ShootingUIPanelIMP:HandleSkillStartEvent(uPawn, SkillID)
  self:SkillStartEvent_Grenade(uPawn, SkillID)
  self:SkillStartEvent_CheckGun(uPawn, SkillID)
end
function ShootingUIPanelIMP:HandleSkillEndEvent(uPawn, StopReason, SkillID)
  self:SkillFinishedEvent_CheckGun(uPawn, StopReason, SkillID)
end
function ShootingUIPanelIMP:SkillStartEvent_CheckGun(uPawn, SkillID)
  if SkillID ~= 1014405 then
    return
  end
  if not slua.isValid(uPawn) or not uPawn:IsLocallyControlled() then
    return
  end
  self.bOverrideMaxFps = true
  print(bWriteLog and "ShootingUIPanelIMP:SkillStartEvent CheckGun")
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  logicSettingGraphics.DowngradeFpsLevelTemporarily(true, 15)
end
function ShootingUIPanelIMP:SkillFinishedEvent_CheckGun(uPawn, StopReason, SkillID)
  if SkillID ~= 1014405 then
    return
  end
  if not slua.isValid(uPawn) or not uPawn:IsLocallyControlled() then
    return
  end
  print(bWriteLog and "ShootingUIPanelIMP:SkillFinishedEvent CheckGun")
  if self.bOverrideMaxFps then
    local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
    logicSettingGraphics.DowngradeFpsLevelTemporarily(false)
    self.bOverrideMaxFps = false
  end
end
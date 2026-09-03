local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
local SkillAction_HideBattleUI = {
  sObjectName = "SkillAction_HideBattleUI",
  bHideBattlePopTips = 0
}
local ENetRole = import("ENetRole")
function SkillAction_HideBattleUI:LuaRealDoAction()
  self:HideBattleUI(true)
  return true
end
function SkillAction_HideBattleUI:HideBattleUI(bHide)
  if not Client then
    return
  end
  local uCharacter = self:GetOwnerPawn()
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
  if self.bHideBattlePopTips ~= 0 then
    print(bWriteLog and string.format("SkillAction_HideBattleUI:HideBattleUI bHideBattlePopTips " .. tostring(bHide)))
    local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
    if BattlePopTips then
      if bHide then
        BattlePopTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        BattlePopTips:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
      end
    end
  end
  if slua.isValid(FirstCharacter) then
    FirstCharacter.bIsHideCrossHairType = bHide
  end
  print(bWriteLog and string.format("SkillAction_HideBattleUI:HideBattleUI %s", bHide))
  local ESlateVisibility = import("ESlateVisibility")
  local Visibility = bHide and ESlateVisibility.Collapsed or ESlateVisibility.SelfHitTestInvisible
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) then
    ShootingUIPanel:SetWidgetVisibility(Visibility)
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and Game:IsValid(MainControlBaseUI.BackPackPickUpPanel_BP) then
    MainControlBaseUI.BackPackPickUpPanel_BP:SetWidgetVisibility(Visibility)
    MainControlBaseUI:ShowOrHideBackpack_Border(not bHide)
  end
  if MainControlBaseUI and Game:IsValid(MainControlBaseUI.BasicSkillsMenu_BP) then
    MainControlBaseUI.BasicSkillsMenu_BP:SetWidgetVisibility(Visibility)
  end
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_SpectatingControl, not bHide)
  end
  local BasicSkillMenuUI = InGameUITools.GetBasicSkillsMenuUI()
  if BasicSkillMenuUI then
    BasicSkillMenuUI:SetBtnVisibleFlag(Visibility, "GridPanel_DriveAndGetIn", "SkillAction_HideBattleUI")
  end
  if bHide then
    uPlayerController:JoystickTriggerSprint(false)
  end
  uPlayerController:ShowTouchInterface(not bHide)
end
function SkillAction_HideBattleUI:LuaUndoAction()
  self:HideBattleUI(false)
end
function SkillAction_HideBattleUI:LuaUpdateAction()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CObjectBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBaseNew")
local CSkillAction_HideBattleUI = class(CObjectBase, nil, SkillAction_HideBattleUI)
return CSkillAction_HideBattleUI
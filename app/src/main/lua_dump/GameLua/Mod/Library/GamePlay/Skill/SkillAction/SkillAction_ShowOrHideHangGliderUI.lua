local SkillAction_ShowOrHideHangGliderUI = {
  sObjectName = "SkillAction_ShowOrHideHangGliderUI"
}
function SkillAction_ShowOrHideHangGliderUI:ctor(selfType)
end
function SkillAction_ShowOrHideHangGliderUI:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local BasicSkillsMenuUI = InGameUITools.GetBasicSkillsMenuUI()
    if BasicSkillsMenuUI then
      print(bWriteLog and "SkillAction_ShowOrHideHangGliderUI ShowUI With BasicSkillsMenuUI")
      self:ShowHangGliderUI()
    else
      print(bWriteLog and "SkillAction_ShowOrHideHangGliderUI AddCommonEvent With No BasicSkillsMenuUI")
      self:AddCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_BASIC_SKILL_MENU_REGIST_DONE, self.ShowHangGliderUI, self)
    end
  end
  return true
end
function SkillAction_ShowOrHideHangGliderUI:LuaUndoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) then
    self:HideHangGliderUI()
  end
  SkillAction_ShowOrHideHangGliderUI.__super.LuaUndoAction(self)
end
function SkillAction_ShowOrHideHangGliderUI:ShowHangGliderUI()
  print(bWriteLog and "SkillAction_ShowOrHideHangGliderUI:ShowHangGliderUI")
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_HangGlider")
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UPDATE_NORMAL_BTN, "Type_HangGlider", {
    TextID = 38705,
    IconPath = "/Game/Mod/Turkey/Arts/UI/Icon/Turkey_Icon_Tuoli.Turkey_Icon_Tuoli"
  })
  self:RemoveCommonEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_BASIC_SKILL_MENU_REGIST_DONE)
  self:ShowShootingControlPanel(false)
end
function SkillAction_ShowOrHideHangGliderUI:HideHangGliderUI()
  print(bWriteLog and "SkillAction_ShowOrHideHangGliderUI:HideHangGliderUI")
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_UPDATE_NORMAL_BTN, "Type_HangGlider", {
    TextID = 10005,
    IconPath = "/Game/Mod/Turkey/Arts/UI/Icon/Turkey_Icon_Gliding.Turkey_Icon_Gliding"
  })
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_HangGlider")
  self:ShowShootingControlPanel(true)
end
function SkillAction_ShowOrHideHangGliderUI:ShowShootingControlPanel(bIsShow)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass then
    if bIsShow then
      ShootingUIPanelLuaClass:ShowShootingControlPanel()
    else
      ShootingUIPanelLuaClass:HideShootingControlPanel()
    end
  end
  local SkillModButtonUI = UIManager.GetUI(UIManager.UI_Config.SkillModButtonSlot)
  if SkillModButtonUI then
    if bIsShow then
      SkillModButtonUI:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    else
      SkillModButtonUI:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  end
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ShowOrHideHangGliderUI = class(CSkillNodeBase, nil, SkillAction_ShowOrHideHangGliderUI)
return CSkillAction_ShowOrHideHangGliderUI
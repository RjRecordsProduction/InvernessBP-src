local BasicSkillsMenuBP = require("GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Config")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BasicSkillsMenuBP:UIMsg_ShowRescueCanvas()
  self.UIRoot.GridPanel_Save:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CanvasPanel_TeamUpPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_TeamUpFail:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BasicSkillsMenuBP:UIMsg_HideRescueCanvas()
  self.UIRoot.GridPanel_Save:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function BasicSkillsMenuBP:UIMsg_HideMiniTvBannerUI()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
end
function BasicSkillsMenuBP:UIMsg_ShowInteractiveMoveBtnPanel()
  self.UIRoot.Button_InteractiveMove:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function BasicSkillsMenuBP:UIMsg_HideInteractiveMoveBtnPanel()
  self.UIRoot.Button_InteractiveMove:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
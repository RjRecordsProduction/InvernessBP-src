local logic_mvp_action = {
  ActionEnum = {GoldenSuit = 0, TeamPosition = 5}
}
local ShowingTeamPositionTips = false
function logic_mvp_action:CheckShowedTeamPositionTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local value = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPositionTips) or 0
  return value == 1
end
function logic_mvp_action:ShowTeamPositionTips()
  local bShowed = self.CheckShowedTeamPositionTips()
  if bShowed then
    return
  end
  ShowingTeamPositionTips = true
  local uiWardrobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  uiWardrobe:ShowTeamPositionTips(true)
end
function logic_mvp_action:CloseTeamPositionTips()
  ShowingTeamPositionTips = false
  local uiWardrobe = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  uiWardrobe:ShowTeamPositionTips(false)
end
function logic_mvp_action:MarkTeamPositionTipsShowed()
  if not ShowingTeamPositionTips then
    return
  end
  self:CloseTeamPositionTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(1, PlayerPrefsSystem.ePlayerPrefsType.eTeamPositionTips)
end
function logic_mvp_action:OnInitMVPAction(mvp_action_type)
  log(bWriteLog and "[logic_mvp_action] OnInitMVPAction: " .. tostring(mvp_action_type))
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateMVPActionSetting(mvp_action_type)
end
function logic_mvp_action:AutoChangeActionType(mvp_action_type)
  log(bWriteLog and "[logic_mvp_action] AutoChangeActionType: " .. tostring(mvp_action_type))
  local bNeedReplace = false
  if bNeedReplace then
  end
end
return logic_mvp_action
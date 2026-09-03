local LevelUpSystem = {
  IsIOSCheck = false,
  OldLevel = 1,
  PveOldLevel = 1
}
function LevelUpSystem.InitOnlyOne()
end
function LevelUpSystem.OnModePostSwitch(preState, nextState)
end
function LevelUpSystem.CheckCanShowLevelUpPanel()
  if not BP_LevelChange then
    log_warning(bWriteLog and "LevelUpSystem.CheckCanShowLevelUpPanel not BP_LevelChange")
    return false
  end
  local logic_growth_project_b = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bFinish = logic_growth_project_b.IsFinishAllNewGuide()
  if not bFinish then
    log_warning(bWriteLog and "LevelUpSystem.CheckCanShowLevelUpPanel not bFinish")
    return false
  end
end
function LevelUpSystem.ShowLevelUpPanel()
  log(bWriteLog and "LevelUpSystem.RealOnModeSwitch BP_LevelChange = " .. tostring(BP_LevelChange))
  LevelUpSystem.OpenLevelupPanel()
end
function LevelUpSystem.OpenLevelupPanel(new)
  if not BP_LevelChange then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bFinish = growthprojectMgrB.IsFinishAllNewGuide()
  if not bFinish then
    log(bWriteLog and "[qintong] LevelUpSystem.OpenLevelupPanel not  bFinish")
    return
  end
  if UIManager then
    UIManager.ShowUI(UIManager.UI_Config.levelup_panel, new)
    BP_LevelChange = false
  end
end
function LevelUpSystem.OnClickRankContinue()
  if UIManager then
    if BP_LevelChange then
      UIManager.ShowUI(UIManager.UI_Config.levelup_panel, DataMgr.roleData.level)
      BP_LevelChange = false
    else
      LevelUpSystem.CloseLevelupPanel()
    end
  end
end
function LevelUpSystem.CloseLevelupPanel()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.levelup_panel)
  end
end
function LevelUpSystem.ClosePveLevelupPanel()
  if UIManager then
    UIManager.CloseUI(UIManager.UI_Config.pve_levelup_panel)
  end
end
function LevelUpSystem.ShowShareLevelUp(pNewLevel)
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    sceneType = 7,
    campaign = "military_rank_up",
    share_type = ShareBtnTLogShareTypeDefine.RankUpgradeSharing,
    reasonStr = json.encode({
      uid = DataMgr.roleData.uid,
      level = pNewLevel
    })
  }
  Util.ShowShare(shareCfg, UIManager.UI_Config.LevelUp_Share)
end
return LevelUpSystem
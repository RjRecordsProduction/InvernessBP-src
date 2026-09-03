local StartGuideAction = {}
function StartGuideAction.Run()
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "[qintong] StartGuideAction Run")
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_COMPLIANCE_END, StartGuideAction.Run)
  log(bWriteLog and "[qintong] StartGuideAction Run")
  if _G.IsEditor then
    return
  end
  if GlobalData.IsIOSCheck() then
    return
  end
  if LobbySystem.CheckUseNewGuide() then
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return
  end
  local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
  if not MinorVerificationSystem.IsVerificationFinished() then
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_COMPLIANCE_END, StartGuideAction.Run)
    return
  end
  if StartGuideAction.Run3C1() then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.CloseErrorUI()
    UIManager.ShowUI(UIManager.UI_Config.Common_Welcome_UIBP)
  end
end
function StartGuideAction.Run3C1()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB.IsGetNewPlayerGift() then
    log(bWriteLog and "[qintong] StartGuideAction.Run3C1 IsGetNewPlayerGift")
    return false
  end
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  local data = NewbieActivitySystem.activity_data
  log_tree("[qintong] StartGuideAction.Run3C1 data= ", data)
  if not data then
    return false
  end
  local activeCfg = data.newbie_fight_guide_award
  if not activeCfg then
    return false
  end
  local bShow = data.day
  if bShow == 0 then
    return false
  end
  return true
end
return StartGuideAction
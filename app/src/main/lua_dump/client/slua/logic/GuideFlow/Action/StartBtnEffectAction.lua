local StartBtnEffectAction = {
  bPlayFxEffect = false,
  bShowTips = false,
  bShowHandEffect = false,
  bThirdlyWeekGuide = false
}
function StartBtnEffectAction.Run(node, actType)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "StartBtnEffectAction.Run actType = " .. actType)
  if actType == "1" then
    StartBtnEffectAction.bPlayFxEffect = true
  elseif actType == "2" then
    StartBtnEffectAction.bShowTips = true
  elseif actType == "3" then
    StartBtnEffectAction.bShowHandEffect = true
  elseif actType == "4" then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local _enter_game_num = LogicNewbie.newbieTotalGameCnt
    if _enter_game_num and _enter_game_num == 2 then
      StartBtnEffectAction.bThirdlyWeekGuide = true
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_START_BTN_ACTION, actType)
end
function StartBtnEffectAction.OnLogin(bReLogin)
  if bReLogin == false then
    StartBtnEffectAction.bPlayFxEffect = false
    StartBtnEffectAction.bShowTips = false
    StartBtnEffectAction.bShowHandEffect = false
  end
end
return StartBtnEffectAction
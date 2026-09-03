local logic_fairgame_popup = {shouldShowFairGameNotice = false, shoudlShowFairGameAgreement = false}
function logic_fairgame_popup.ShowFairGameAgreement()
  if not logic_fairgame_popup.shoudlShowFairGameAgreement then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Agreement_FairPlay_Popup)
end
function logic_fairgame_popup.CloseFairGameAgreement()
  UIManager.CloseUI(UIManager.UI_Config.Agreement_FairPlay_Popup)
end
function logic_fairgame_popup.ShowFairGameNotice()
  UIManager.ShowUI(UIManager.UI_Config.Notice_FairPlay_Popup)
end
function logic_fairgame_popup.ShouldShowFairGameAgreement()
  return logic_fairgame_popup.shoudlShowFairGameAgreement
end
function logic_fairgame_popup.ShouldShowFairGameNotice()
  return logic_fairgame_popup.shouldShowFairGameNotice
end
function logic_fairgame_popup.OnLogin()
  logic_fairgame_popup.shoudlShowFairGameAgreement = false
  logic_fairgame_popup.shouldShowFairGameNotice = false
end
return logic_fairgame_popup
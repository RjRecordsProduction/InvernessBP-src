local LoginSubUIUtil = {}
function LoginSubUIUtil.OpenMailLogin(bDisableAni)
  return UIManager.ShowUI(UIManager.UI_Config.LoginFormMail_UIBP, {bDisableAni = bDisableAni})
end
function LoginSubUIUtil.OpenPhoneLogin()
  return UIManager.ShowUI(UIManager.UI_Config.LoginFormPhone_UIBP, {bDisableAni = true})
end
function LoginSubUIUtil.OpenResetPass(param)
  return UIManager.ShowUI(UIManager.UI_Config.LoginResetPass_UIBP, param)
end
return LoginSubUIUtil
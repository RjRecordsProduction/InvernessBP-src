local SettingMacro = {}
SettingMacro.AccountOperationType = {
  Bind = 1,
  Modify = 2,
  Replace = 3,
  Unbind = 4,
  LoginVerify = 5,
  GameOperation = 6
}
SettingMacro.AccountVerifyCodeType = {
  Register = 0,
  NewSelfAccount = 3,
  CurAccountCheck = 7,
  UpdateSelfAccount = 8,
  SecondarySelfAccount = 12
}
SettingMacro.AccountProtectTab = {
  AccountInfo = 1,
  ScanQRCode = 2,
  LoginRecord = 3
}
SettingMacro.AccountProtectTabText = {
  200000292,
  200000293,
  200000294
}
SettingMacro.AccountNewOperationType = {
  BindSocial = 1,
  FirstBindMail = 2,
  FirstBindPhone = 3,
  UnBindSocial = 4,
  FastUnBindSocail = 5,
  ChangeBindMail = 6,
  ChangeBindPhone = 8,
  ExtraBindMail = 10,
  ExtraBindPhone = 11,
  GuestGuide = 99,
  BindSocialRemind = 100,
  CEBindSocial = 101
}
SettingMacro.AccountSensitiveStep = {
  Initiate = 1,
  Verify = 2,
  Execute = 3,
  Complete = 4
}
SettingMacro.AccountSensitiveActionType = {
  Discontinue = 1,
  CustomerService = 2,
  Relogin = 0
}
SettingMacro.AccountSensitiveVerifyStatus = {
  Verifying = 1,
  Success = 2,
  Fail = 3,
  FailToOtherVerify = 4,
  Timeout = 5
}
return SettingMacro
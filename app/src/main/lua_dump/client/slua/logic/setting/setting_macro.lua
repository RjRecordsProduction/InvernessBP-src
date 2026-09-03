local SettingMacro = {
  Tab = {},
  PageEnumToStr = {},
  PageStrToEnum = {},
  NOverLayWidth = 1170,
  NDoubleHHeight = 30,
  NDoubleVHeight = 80,
  NTitleHeight = 60,
  NOverlaySelfHeight = 64,
  NOverlaySelfUpHeight = 30,
  NSlice = 30
}
SettingMacro.PictureAndAudioTab = {
  Picture = 1,
  Effect = 2,
  Audio = 3
}
SettingMacro.Tab = {
  Basic = 1,
  Control = 3,
  Sensitivity = 5,
  PickUp = 6,
  Scope = 16,
  ScopeOld = 15,
  SensitivityNew = 7,
  Language = 10,
  TV = 13,
  OBS = 14,
  Others = 17,
  Account = 20,
  Privacy = 21,
  PictureAndAudio = 22,
  Haptics = 23,
  OBCustom = 24,
  Notifications = 25
}
SettingMacro.EItemType = {
  Title = 1,
  DoubleV = 2,
  Treble = 3,
  Slider2Btn = 4,
  OverLay = 5,
  DoubleParent = 6,
  DoubleH = 7,
  DoubleParentWithChoose = 8,
  DoubleVWord = 9,
  TrebleParent = 10,
  DoubleHWord = 11,
  OneChoose = 12,
  DoubleSlim = 13
}
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
function SettingMacro:Init()
  log(bWriteLog and "[SettingConfig] Init")
  for str, enum in pairs(self.Tab) do
    self.PageEnumToStr[enum] = str
    self.PageStrToEnum[str] = enum
  end
end
SettingMacro:Init()
return SettingMacro
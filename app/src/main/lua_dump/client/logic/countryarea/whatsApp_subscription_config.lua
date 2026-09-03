local whatsApp_subscription_config = {}
whatsApp_subscription_config.EStatus = {
  None = 0,
  Refuse = 1,
  Subscribe = 2
}
local EStatus = whatsApp_subscription_config.EStatus
whatsApp_subscription_config.PopupContent = {
  [EStatus.None] = {
    title = LocUtil.GetLocalizeResStr(817287),
    desc = LocUtil.GetLocalizeResStr(817288),
    cancelText = LocUtil.GetLocalizeResStr(13224),
    confirmText = LocUtil.GetLocalizeResStr(6504),
    cancelStatus = EStatus.Refuse,
    confirmStatus = EStatus.Subscribe
  },
  [EStatus.Refuse] = {
    title = LocUtil.GetLocalizeResStr(817287),
    desc = LocUtil.GetLocalizeResStr(817288),
    cancelText = LocUtil.GetLocalizeResStr(13224),
    confirmText = LocUtil.GetLocalizeResStr(6504),
    cancelStatus = EStatus.Refuse,
    confirmStatus = EStatus.Subscribe
  },
  [EStatus.Subscribe] = {
    title = LocUtil.GetLocalizeResStr(817289),
    desc = LocUtil.GetLocalizeResStr(817290),
    cancelText = LocUtil.GetLocalizeResStr(4142),
    confirmText = LocUtil.GetLocalizeResStr(817291),
    confirmStatus = EStatus.Refuse
  }
}
return whatsApp_subscription_config
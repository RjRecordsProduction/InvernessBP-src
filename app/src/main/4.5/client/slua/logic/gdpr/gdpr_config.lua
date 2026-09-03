local gdpr_config = {}
gdpr_config.GDPRState = {
  EUGDPR_DefaultState = 0,
  EUGDPR_NotEUState = 1,
  EUGDPR_EUState = 2,
  EUGDPR_NotAgreeDataState = 3,
  EUGDPR_AgreeDataState = 4,
  EUGDPR_NotAgreePrivacyState = 5,
  EUGDPR_BothAgreeState = 6,
  EUGDPR_AdultState = 7,
  EUGDPR_YoungState = 8,
  EUGDPR_ParentNotAgreeState = 9,
  EUGDPR_ParentAgreeState = 10,
  EUGDPR_DeletingConfirmState = 11,
  EUGDPR_NotAgreeDataAndDeleteState = 13,
  EUGDPR_NotAgreePrivacyAndDeleteState = 15,
  EUGDPR_ParentNotAgreeAndDeleteState = 19,
  EUGDPR_ParentNotAgreeDeleteAndCantLoginState = 20,
  EUGDPR_DeleteWithoutReasonState = 21
}
gdpr_config.StatusWords = {
  [gdpr_config.GDPRState.EUGDPR_NotAgreeDataState] = 4373,
  [gdpr_config.GDPRState.EUGDPR_AgreeDataState] = 4382,
  [gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyState] = 4390,
  [gdpr_config.GDPRState.EUGDPR_AdultState] = 4448,
  [gdpr_config.GDPRState.EUGDPR_YoungState] = 4391,
  [gdpr_config.GDPRState.EUGDPR_ParentNotAgreeState] = 4393,
  [gdpr_config.GDPRState.EUGDPR_ParentAgreeState] = 4448,
  [gdpr_config.GDPRState.EUGDPR_DeletingConfirmState] = 4099,
  [gdpr_config.GDPRState.EUGDPR_NotAgreeDataAndDeleteState] = 4413,
  [gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyAndDeleteState] = 4389,
  [gdpr_config.GDPRState.EUGDPR_ParentNotAgreeAndDeleteState] = 4122,
  [gdpr_config.GDPRState.EUGDPR_ParentNotAgreeDeleteAndCantLoginState] = 4394,
  [gdpr_config.GDPRState.EUGDPR_DeleteWithoutReasonState] = 4389
}
gdpr_config.EPRIVICY_ACTION = {
  EUGDPR_PRIVICY_DEFAULT = 0,
  EUGDPR_PRIVICY_AGREE = 1,
  EUGDPR_PRIVICY_REJECT = 2,
  EUGDPR_DATA_TRANS_REJECT = 3,
  EUGDPR_DATA_TRANS_AGREE = 4
}
gdpr_config.EUserType = {
  EUGDPR_NON_EU = 1,
  EUGDPR_EU_ADULT = 2,
  EUGDPR_EU_PARENT_WAIT = 3,
  EUGDPR_EU_PARENT_AGREE = 4,
  EUGDPR_EU_PARENT_NOT_AGREE = 5,
  EUGDPR_EU_PERSON = 6
}
return gdpr_config
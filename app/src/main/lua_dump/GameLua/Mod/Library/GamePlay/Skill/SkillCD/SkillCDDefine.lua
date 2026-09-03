SkillCDDefine = {}
SkillCDDefine.ECDType = {
  CDT_None = 0,
  CDT_Timer = 1,
  CDT_Energy = 2,
  CDT_Point = 3
}
SkillCDDefine.ECDRole = {
  CDR_Default = 0,
  CDR_ClientPreAct = 1,
  CDR_ClientOnly = 2
}
SkillCDDefine.ECDCompare = {
  CDC_Bigger = 0,
  CDC_Equal = 1,
  CDC_Smaller = 2
}
SkillCDDefine.ECDScaleType = {
  CDST_Immediately = 0,
  CDST_NextCD = 1,
  CDST_ImmediatelyOnlyLowScale = 2,
  CDST_ImmediatelyOnlyHighScale = 3
}
return SkillCDDefine
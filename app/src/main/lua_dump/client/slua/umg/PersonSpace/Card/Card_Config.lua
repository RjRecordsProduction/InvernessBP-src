local Config = {
  EComboxType = {
    Common_ComboBox_PreServer = TLogEventDefine.RoleInfoCard_PreServer,
    Common_ComboBox_Tendency = TLogEventDefine.RoleInfoCard_Tendency,
    Common_ComboBox_ExpertArea1 = TLogEventDefine.RoleInfoCard_ExpertArea,
    Common_ComboBox_ExpertArea2 = TLogEventDefine.RoleInfoCard_ExpertArea,
    Common_ComboBox_PlayDate = TLogEventDefine.RoleInfoCard_PlayDate,
    Common_ComboBox_PlayTime = TLogEventDefine.RoleInfoCard_PlayDate,
    Common_ComboBox_Mode1 = TLogEventDefine.RoleInfoCard_Mode1,
    Common_ComboBox_Mode2 = TLogEventDefine.RoleInfoCard_Mode2,
    Common_ComboBox_Weapon1 = TLogEventDefine.RoleInfoCard_Weapon1,
    Common_ComboBox_Weapon2 = TLogEventDefine.RoleInfoCard_Weapon2,
    Common_ComboBox_Voice = TLogEventDefine.RoleInfoCard_Voice,
    Others = TLogEventDefine.RoleInfoCard_Others
  },
  Share_Title_Config = {
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100054), LocUtil.GetLocalizeResStr(100030)),
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100054), LocUtil.GetLocalizeResStr(100031)),
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100054), LocUtil.GetLocalizeResStr(100032)),
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100053), LocUtil.GetLocalizeResStr(100030)),
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100053), LocUtil.GetLocalizeResStr(100031)),
    LocUtil.LocalizeResFormat(45903, LocUtil.GetLocalizeResStr(100053), LocUtil.GetLocalizeResStr(100032))
  },
  IndexToMode = {
    {ViewMode = 1, TeamSize = 1},
    {ViewMode = 1, TeamSize = 2},
    {ViewMode = 1, TeamSize = 3},
    {ViewMode = 2, TeamSize = 1},
    {ViewMode = 2, TeamSize = 2},
    {ViewMode = 2, TeamSize = 3},
    {ViewMode = 2, TeamSize = 3}
  },
  ModeToIndex = {
    single = 1,
    double = 2,
    team = 3,
    fppsingle = 4,
    fppdouble = 5,
    fppteam = 6
  }
}
return Config
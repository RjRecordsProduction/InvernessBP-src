local time_step_macros = {
  ENUM_MSG_TYPE = "10",
  ENUM_TIME_STEP = {
    AppStartToCopySoEnd = 1,
    CopySoToSplashStart = 2,
    SplashStartToSplashEnd = 3,
    SplashEndToSplashAniStart = 4,
    SplashAniStartToSplashAniEnd = 5,
    SplashEndToUpdatePatchStart = 6,
    UpdatePatchStartToUpdatePatchEnd = 7,
    UpdatePatchEndToLoginUIShow = 8,
    LoginToSyncBaseInfoStart = 9,
    SyncBaseInfoStartToSyncBaseInfoEnd = 10,
    SyncBaseInfoEndToLoadingUIClose = 11
  },
  ENUM_ROLE_TYPE = {
    RoleType_Unknown = 0,
    RoleType_Normal = 1,
    RoleType_Newbie = 2,
    RoleType_Newbie_Init = 3,
    RoleType_Return = 4
  }
}
return time_step_macros
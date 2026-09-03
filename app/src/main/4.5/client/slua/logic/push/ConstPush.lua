local ConstPush = {
  START_REQ_EXTRA_DATA = 4,
  START_LOCAL_PUSH_LATER_SECONDS = 6,
  START_FCM_PUSH_LATER_SECONDS = 7,
  PUSH_START_HOUR = 8,
  PUSH_END_HOUR = 23,
  PUSH_START_HOUR_KR = 8,
  PUSH_END_HOUR_KR = 21,
  Enum_Push_Type = {
    Enum_BackFlow = 101,
    Enum_PassUnlock = 102,
    Enum_PassScoreUnUse = 103,
    Enum_NewItem = 104,
    Enum_NewUser = 105,
    Enum_AllStar = 107,
    Enum_Birthday = 108,
    Enum_Activity = 109,
    Enum_Limited = 110,
    Enum_PreLoss_LoginReward = 111,
    Enum_PopularPK_Start = 112,
    Enum_TeamPK_Start = 113,
    Enum_TeamPK_End = 114,
    Enum_PopularPK_End = 115,
    Enum_PeakGame_Start = 116,
    Enum_CrazyWeekend_Start = 118
  },
  SpecialPushType = {
    [112] = true,
    [113] = true,
    [114] = true,
    [115] = true
  },
  Enum_Cycle_Type = {
    Enum_Day = 1,
    Enum_Week = 2,
    Enum_Month = 3
  },
  Enum_Condition_Type = {
    Enum_LastLoginDay = 1,
    Enum_PayUC = 2,
    Enum_PassLevelArea = 3,
    Enum_PassScoreArea = 4,
    Enum_PassEndDay = 5,
    Enum_RegisterDay = 6,
    Enum_PlayerLabel = 7,
    Enum_AllStar = 8,
    Enum_ComeBack_Flag = 9,
    Enum_User_Label = 11,
    Enum_PreLoss_LoginReward = 12,
    Enum_Popular_PK = 13
  },
  FCM_KEY_DEFINE = {
    {key = 10001, fcm_key = "user_level"},
    {key = 10002, fcm_key = "pass_level"},
    {
      key = 10003,
      fcm_key = "client_version"
    },
    {
      key = 50001,
      fcm_key = "jk_push_switch"
    },
    {
      key = 50002,
      fcm_key = "jk_push_night_switch"
    }
  }
}
function ConstPush.IsSpecialType(PushType)
  local bSpecial = ConstPush.SpecialPushType[PushType] or false
  return bSpecial == true
end
return ConstPush
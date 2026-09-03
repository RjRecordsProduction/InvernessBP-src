local UnknowPass_Macro = {
  ENUM_Pass_Main_Reddot = {
    ENUM_Pass_NewBie = 1,
    ENUM_Pass_EasyTicket_NewPlayer = 2,
    ENUM_Pass_MissionSearch = 3,
    ENUM_Pass_JKAskForTips = 4,
    ENUM_Pass_ChoosePathAnim = 5,
    ENUM_Pass_FriendExtraAnim = 6,
    ENUM_Pass_ToysFriendAnim = 7,
    ENUM_Pass_ToysEntry = 8,
    ENUM_Pass_PrivilegeNew = 9,
    ENUM_Pass_PrivilegeUpgrade = 10,
    ENUM_Pass_SUBSCRIPTION = 11,
    ENUM_Pass_LuckyBoxBubble = 12,
    ENUM_Pass_PrimeVideoTips = 13,
    ENUM_Pass_NewWeekMissionGuide = 22,
    ENUM_Pass_NewDayMissionGuide = 23,
    ENUM_Pass_NewRecordGuide = 24,
    ENUM_Pass_SingleMonGuide = 25,
    ENUM_Pass_XmissionGuide = 27,
    ENUM_Pass_XmissionStrongGuide = 28,
    ENUM_Pass_MaxActionPlay = 29,
    ENUM_Pass_KOIPOPUP = 30,
    ENUM_Pass_Mission_WeekTask = 2537,
    ENUM_Pass_RPNewbieGuide = 2538
  },
  ENUM_Pass_Sub_Reddot = {
    UnknowPass_AwardsFirstWeek_Reddot = 11,
    UnknowPass_AwardsNewSeason_Reddot = 12,
    UnknowPass_LastViewDay_Reddot = 13,
    UnknowPass_EasyTicketNewSeason_Reddot = 15,
    UnknowPass_EasyTicketKeepBuy_Reddot = 16,
    UnknowPass_EasyTicketNewWeek_Reddot = 17,
    UnknowPass_EasyTicketTips_Reddot = 18,
    UnknowPass_EasyTicketTaskNewWeek_Reddot = 19,
    UnknowPass_ExchangeReturn_Reddot = 20,
    UnknowPass_RecordNew_Reddot = 21,
    UnknowPass_ExtraScoreSeason_New = 26
  },
  UnknowPass_CameraId = 10113,
  UnknowPass_RPBag_Item = {
    1405235,
    1105002012,
    1403062,
    1103009011,
    1405236,
    1405237,
    1501000067,
    1401048,
    1910010,
    1101003061
  },
  UnknowPass_VideoPathPrime = "./MoviesPakDir/RP_PRIME.MP4",
  UnKnowPass_NextSeason = 13,
  UnKnowPass_NextSeason_HasSet = false,
  ENUM_PASS_VOUCHER_ID = {
    [1] = 1614231,
    [2] = 1614232
  },
  UnknowPass_GiftKRTips = FuncUtil.GetDomainByID(3366040) .. "/battlegroundsmobile/17158",
  ENUM_Pass_UpgradeTipsType = {
    UpgradeCard = 0,
    ExtraAward = 1,
    HasCoupon = 2,
    KeepBuy = 3,
    TextTips = 4,
    BPUpgradeCard = 5,
    None = 6
  },
  ENUM_POINT_STATUS = {RP = 1, ACT = 2},
  ENUM_REDDOT = {
    AWARD = 1,
    FIRSTRANK_NEW = 2,
    FIRSTRANK_RECEIVE = 3,
    GIFT_RECEIVE = 4,
    GIFT_NEWVIDEO = 5,
    PRIME_NEWVIDEO = 8,
    EASYTICKET_NEWFREE = 9,
    EASYTICKET_RECEIVE = 10,
    EASYTICKET_NEWWEEK = 11,
    TASK_NEW = 12,
    TASK_WEEKRECEIVE = 13,
    TASK_SEASON = 14,
    SUBWAY_NEW = 15,
    UPGRADE_CARD = 16,
    MOTION_CARD = 17,
    UPASS_KOI = 18,
    EXTRA_SCORE_NEW = 19,
    EXTRA_SCORE_RECEIVE = 20,
    CONTINUE_BUY_RP = 21,
    Bonus_Pass_Award_Reddot = 22,
    Bonus_Pass_Task_Reddot = 23,
    Bonus_Pass_New = 24,
    Priliege_New = 25
  },
  ENUM_EXCHANGE_CONFIRM_TYPE = {
    RP = 0,
    ALLSTAR = 1,
    RPGIFT = 2
  },
  ENUM_Timer = {
    Main = {
      jumpTimer = 0,
      requestTimer = 0.33,
      slapTimer = 0.9
    },
    Award = {
      HandleRefreshLockTimer = 0,
      GrowthGuideTimer = 1,
      UpgradeBubbleShowTimer = 4,
      ExchangeBubbleShow = 5
    },
    Mission = {
      UpdateUITimer = 0.2,
      NewbieGuideTimer = 0.4,
      CreateItemTimer = 0.05,
      FinishTaskReqTimer = 1,
      ScrollShowTipsTimer = 3,
      showWeekLeftTimer = 60
    },
    Exchange = {
      InitAvatarTimer = 0.0,
      BubbleTimer = 5,
      CreateItemTimer = 0.05
    },
    Buy = {InitUITimer = 0.33, AskForCountDownTimer = 0.5}
  },
  Activity_Collection_NewBie_Guide_Version = "1.7.0",
  Enum_Activity_Collection_Step = {PassMainEntrance = 1, SetPermanentAct = 2},
  Enum_ActCollect_BubbleEnter_Define = {
    Lobby = "Lobby",
    PassMain = "UnknowPassMain",
    PageGuide = "ActCollectPageGuide"
  },
  Enum_ActCollect_Bubble_Time = {
    Lobby = 10,
    UnknowPassMain = 30,
    ActCollectPageGuide = 60
  },
  Enum_Activity_Collection_Tlog_Define = {
    ClickBtnEnter = "BtnEntranceClick",
    ClickBtnQuickEnter = "BtnQuickEntranceClick",
    ClickActivityPageItem = "ActivityPageItemClick",
    ClickSetQuickEntrance = "BtnSetQuickEntranceClick"
  },
  Enum_Activity_Open_State = {
    NotStart = 0,
    InProgress = 1,
    End = 2
  },
  Enum_PreBuyType = {
    None = 0,
    Normal = 102,
    Super = 103
  },
  Enum_BranchAwardState = {
    CanGet = 0,
    HasGet = 1,
    Lock = 2
  },
  Enum_BranchTaskState = {
    NotFinish = 0,
    HasFinish = 1,
    HasReceive = 2
  },
  ENUM_ANNUAL_STEP = {
    Normal_360 = 1,
    Normal_720 = 2,
    PlusSuper = 3
  },
  ENUM_Chest_DRAW_TIMES = {OneTimes = 1, TenTimes = 10},
  ENUM_BUY_TYPE = {
    Normal = 0,
    Better = 1,
    Best = 2
  },
  UC_RES_ID = 1006,
  ENUM_NEWUSER_STATE = {
    BEGIN = 0,
    NEVER_BUY = 1,
    HAVE_BUY = 2,
    NEVER_BUY_USED = 3
  },
  active_shop_guide_cfg = {
    TitleID = 6698901,
    BPPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture02_Item_UIBP.Common_Popup_Theme_Explain_Picture02_Item_UIBP",
    RefreshFun = function(node_root)
      if not node_root then
        return
      end
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local sVersionPath = UnknowPassUtil.GetVersionNumber()
      local Util = require("client.slua_ui_framework.util")
      local sPath1 = string.format("/Game/Arts_UI/UnknowPass/%s/NoAtlas/RP_Branch/New_Guide_ChangeColor01.New_Guide_ChangeColor01", sVersionPath)
      local sPath2 = string.format("/Game/Arts_UI/UnknowPass/%s/NoAtlas/RP_Branch/New_Guide_ChangeColor02.New_Guide_ChangeColor02", sVersionPath)
      Util.SetTexture(node_root.Image_Pic_1, sPath1)
      Util.SetTexture(node_root.Image_Pic_2, sPath2)
      node_root.Text_Pic_1:SetText(LocUtil.GetLocalizeResStr(18140166))
      node_root.Text_Pic_2:SetText(LocUtil.GetLocalizeResStr(18140167))
    end
  },
  ENUM_RP_BUY_TYPE = {
    BuyType1 = 1,
    BuyType2 = 2,
    BuyType3 = 3,
    BuyType4 = 4,
    BuyType5 = 5,
    BuyType6 = 6,
    BuyType18 = 18,
    BuyType19 = 19,
    BuyType20 = 20,
    BuyType21 = 21,
    BuyType22 = 22,
    BuyType23 = 23,
    BuyType40 = 40,
    BuyType41 = 41,
    BuyType42 = 42,
    BuyType43 = 43,
    BuyType44 = 44,
    BuyType45 = 45,
    BuyType46 = 46,
    BuyType47 = 47,
    BuyType  },
  ENUM_RP_BUY_TYPE_UC = {
    BuyType1 = 1,
    BuyType2 = 2,
    BuyType3 = 3,
    BuyType18 = 18,
    BuyType19 = 19,
    BuyType20 = 20,
    BuyType  },
  ENUM_RP_BUY_TYPE_CARD = {
    BuyType4 = 4,
    BuyType5 = 5,
    BuyType21 = 21,
    BuyType22 = 22,
    BuyType23 = 23,
    BuyType40 = 40,
    BuyType  },
  ENUM_RP_BUY_TYPE_CARD_UC = {
    BuyType6 = 6,
    BuyType41 = 41,
    BuyType42 = 42,
    BuyType43 = 43,
    BuyType46 = 46,
    BuyType47 = 47,
    BuyType  }
}
return UnknowPass_Macro
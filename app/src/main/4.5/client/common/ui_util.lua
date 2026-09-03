local DefalutFrequencyLimit = 0.5
local UIUtil = {
  globalUIFunctionLibrary = nil,
  globalLuaUaeWidgetTable = {},
  ClickFrequencyLimit = {
    setting_bindchoice_panel = {5, 0},
    guest_bind_main = {5, 0},
    BindPhoneMail = {5, 0},
    MailInviteWait = {5, 0},
    EditorStartGame = {5, 0},
    TeamPlatform_UIBP_Base = {DefalutFrequencyLimit, 0},
    GoToIsland = {DefalutFrequencyLimit, 0},
    HallThemeSwitch = {DefalutFrequencyLimit, 0},
    InGameWebview = {DefalutFrequencyLimit, 0},
    SettingShare = {DefalutFrequencyLimit, 0},
    SidebarBanner = {DefalutFrequencyLimit, 0},
    TPlan_TeamPlatform_MyTeam_UIBP = {DefalutFrequencyLimit, 0},
    ui_recharge_gas_station = {DefalutFrequencyLimit, 0},
    TeamPlatform_MyTeam_UIBP = {DefalutFrequencyLimit, 0},
    subtab_suit = {DefalutFrequencyLimit, 0},
    EntryVisitHome = {DefalutFrequencyLimit, 0},
    EntryVisitCollectionHall = {1.1, 0},
    OpenCollectionHallDetail = {0.4, 0},
    WardrobeUndo = {DefalutFrequencyLimit, 0},
    WardrobeGunSubTab = {DefalutFrequencyLimit, 0},
    MentorPageSwitch = {DefalutFrequencyLimit, 0},
    CorpsEnergyMission = {DefalutFrequencyLimit, 0},
    SecretStoreRefresh = {DefalutFrequencyLimit, 0},
    MomentClick = {DefalutFrequencyLimit, 0},
    JoinTeam = {DefalutFrequencyLimit, 0},
    SeasonCycleAwardItem = {DefalutFrequencyLimit, 0},
    ChatVoice = {DefalutFrequencyLimit, 0},
    LobbyModel = {DefalutFrequencyLimit, 0},
    LimitedTimeGift = {DefalutFrequencyLimit, 0},
    ReturnActivity_Suit_UIBP = {DefalutFrequencyLimit, 0},
    ExpressionPopUIBP = {DefalutFrequencyLimit, 0},
    ReturnActivity_Newest_UIBP = {DefalutFrequencyLimit, 0},
    ReturnActivity_TreasureChest_UIBP = {DefalutFrequencyLimit, 0},
    ui_moment_add_photo = {DefalutFrequencyLimit, 0},
    ui_moment_tab_photo_detail = {DefalutFrequencyLimit, 0},
    UpgradePendant = {DefalutFrequencyLimit, 0},
    Exchange = {0.8, 0},
    logic_display_setting = {DefalutFrequencyLimit, 0},
    setting_account_protect = {DefalutFrequencyLimit, 0},
    Sociallsland_SelectMap_UIBP = {DefalutFrequencyLimit, 0},
    StoreTab = {DefalutFrequencyLimit, 0},
    StoreItem = {DefalutFrequencyLimit, 0},
    StoreCollectionBtn = {DefalutFrequencyLimit, 0},
    CrateCollectionBtn = {DefalutFrequencyLimit, 0},
    XSuit_Workshop_Main_UIBP = {DefalutFrequencyLimit, 0},
    XSuitPreview_Tab = {DefalutFrequencyLimit, 0},
    XSuitSpin_QuickUpgrade = {DefalutFrequencyLimit, 0},
    UnknowPassTab = {DefalutFrequencyLimit, 0},
    suit_dye_main = {DefalutFrequencyLimit, 0},
    ActivitySwitch = {DefalutFrequencyLimit, 0},
    LegendWeaponSwitch = {DefalutFrequencyLimit, 0},
    ActivityTab = {DefalutFrequencyLimit, 0},
    ActivityGetBtn = {DefalutFrequencyLimit, 0},
    WardrobeChangeRolewear = {DefalutFrequencyLimit, 0},
    WardrobeVehicleTab = {DefalutFrequencyLimit, 0},
    WardrobeVehicleItem = {DefalutFrequencyLimit, 0},
    RankTab = {DefalutFrequencyLimit, 0},
    SpaceSecrecySetting = {DefalutFrequencyLimit, 0},
    SubwayHistory = {DefalutFrequencyLimit, 0},
    InviteJoinCarTeam = {DefalutFrequencyLimit, 0},
    APlanAwardUpgrade = {DefalutFrequencyLimit, 0},
    DrawJumpExchange = {DefalutFrequencyLimit, 0},
    TarotCardDraw = {DefalutFrequencyLimit, 0},
    UGCAuthorFollow = {1, 0},
    UGCAppreciationGetAward = {1, 0},
    CarIllustratedBook = {DefalutFrequencyLimit, 0},
    RoleInfoPopularityUI = {DefalutFrequencyLimit, 0},
    roleinfo_main = {DefalutFrequencyLimit, 0},
    corps_suggestion = {DefalutFrequencyLimit, 0},
    PlayGame_Award_Sub_UIBP = {DefalutFrequencyLimit, 0},
    Rank_Award_Sub_UIBP = {DefalutFrequencyLimit, 0},
    PlanPH_Template_Select = {DefalutFrequencyLimit, 0},
    PlanPH_Rec_Home_Req = {DefalutFrequencyLimit, 0},
    Theme_System_Tab = {DefalutFrequencyLimit, 0},
    Theme_System_Task_Button = {1, 0},
    PopularHomePKTab = {DefalutFrequencyLimit, 0},
    PHomeTreeTab = {DefalutFrequencyLimit, 0},
    PopularBoxTab = {DefalutFrequencyLimit, 0},
    PopularBoxAward = {DefalutFrequencyLimit, 0},
    PopularGiftPlayerClick = {DefalutFrequencyLimit, 0},
    HomeTaskAwardClick = {DefalutFrequencyLimit, 0},
    SportsCarDrawClick = {DefalutFrequencyLimit, 0},
    PlanPH_Crystal_Tab = {DefalutFrequencyLimit, 0},
    PlanPH_CrystalGetReward = {DefalutFrequencyLimit, 0},
    PlanPH_ParkingLot_Tab = {DefalutFrequencyLimit, 0},
    Kol_Tab = {DefalutFrequencyLimit, 0},
    Kol_SubTab = {DefalutFrequencyLimit, 0},
    Kol_Card = {DefalutFrequencyLimit, 0},
    Collect_Inherit = {DefalutFrequencyLimit, 0},
    PetCarry = {DefalutFrequencyLimit, 0},
    CreateAICover = {DefalutFrequencyLimit, 0},
    DelAICover = {DefalutFrequencyLimit, 0},
    WeddingActivityTab = {DefalutFrequencyLimit, 0},
    Fission_Tab = {DefalutFrequencyLimit, 0},
    Fission_Award = {DefalutFrequencyLimit, 0},
    Fission_Inviter_Tab = {DefalutFrequencyLimit, 0},
    MineSubTab = {1, 0},
    Character_Exchange_Tab = {DefalutFrequencyLimit, 0},
    RPXYearBox = {DefalutFrequencyLimit, 0},
    MusicItem = {DefalutFrequencyLimit, 0},
    LobbyBtn = {DefalutFrequencyLimit, 0},
    Wardrobe = {DefalutFrequencyLimit, 0},
    TaskPageSwitch = {DefalutFrequencyLimit, 0},
    SubscribeStoreTab = {DefalutFrequencyLimit, 0},
    MailTab = {DefalutFrequencyLimit, 0},
    PictorialTab = {DefalutFrequencyLimit, 0},
    PictorialItem = {DefalutFrequencyLimit, 0},
    LobbyPaint = {7, 0},
    WeaponDiffColor = {1, 0},
    ReplaceEmoticonBubbles = {1, 0},
    SyncLobbyEmotion = {1, 0},
    UpgradeWeapon = {2, 0},
    UpgradeGunAttach = {DefalutFrequencyLimit, 0},
    PutOnWeapon = {1, 0},
    PutOnWeaponPendant = {DefalutFrequencyLimit, 0},
    PutOffWeaponPendant = {DefalutFrequencyLimit, 0},
    PetChangeSize = {1, 0},
    PetShareConfig = {1, 0},
    HomeShare = {1, 0},
    WeddingActivityPublish = {1, 0},
    WeddingActivityRefreshList = {1, 0},
    SportCarPopClick = {DefalutFrequencyLimit, 0},
    PlanPHTeleportToPlayerStart = {3, 0},
    PlanPHMsgBoard = {DefalutFrequencyLimit, 0},
    PlanPHDrawing = {0.5, 0},
    PlanPHThemeSetChange = {2, 0},
    PlanPHThemeSetBuy = {2, 0},
    PlanPHGiftBoxPut = {2, 0},
    UGCRecommendVideo = {2, 0},
    PlanPHGoldenTreeCollect = {DefalutFrequencyLimit, 0},
    PlanPHGoldenTreePlant = {DefalutFrequencyLimit, 0},
    PlanPHGoldenTreeBuyClick = {DefalutFrequencyLimit, 0},
    PlanPHGoldenTreeWater = {DefalutFrequencyLimit, 0},
    PlanPHGoldenTreeFeed = {DefalutFrequencyLimit, 0},
    PlanPHLevelUpClick = {DefalutFrequencyLimit, 0},
    PlanPHEditHomeSave = {5.5, 0},
    ChatRoomShareToWorld = {DefalutFrequencyLimit, 0},
    ChatRoomShareToTopic = {DefalutFrequencyLimit, 0},
    ChatRoomShareToCorps = {DefalutFrequencyLimit, 0},
    ChatRoomShareToFriend = {DefalutFrequencyLimit, 0},
    PhoneMailVerify = {1, 0},
    ChatRoomChannelTab_1 = {DefalutFrequencyLimit, 0},
    ChatRoomChannelTab_2 = {DefalutFrequencyLimit, 0},
    ChatRoomChannelTab_3 = {DefalutFrequencyLimit, 0},
    ChatRoomChannelTab_4 = {DefalutFrequencyLimit, 0},
    ChatRoomChannelTab_5 = {DefalutFrequencyLimit, 0},
    ChatRoomSetTopic = {3.5, 0},
    ChatRoomAnswerTopic = {30, 0},
    GoldenSuitChangeHeadUnlock = {DefalutFrequencyLimit, 0},
    ClickLudoInvite = {10, 0},
    PlanPHReEnterRoom = {5, 0},
    LudoInviteToWorld = {DefalutFrequencyLimit, 0},
    LudoInviteToTopic = {DefalutFrequencyLimit, 0},
    LudoInviteToCorps = {DefalutFrequencyLimit, 0},
    LudoInviteToFriend = {DefalutFrequencyLimit, 0},
    LudoInviteToManor = {DefalutFrequencyLimit, 0},
    HalloweenHowl = {2, 0},
    HalloweenCatch = {DefalutFrequencyLimit, 0},
    HalloweenInvite = {30, 0},
    HalloweenPlaceGift = {3, 0},
    HalloweenPaintDecal = {1, 0},
    HomeStyleGetNominateAward = {1, 0},
    HomeStyleRefreshRecommendList = {3, 0},
    HomeStyleNominateHome = {1, 0},
    SnowPartyEnterGame = {DefalutFrequencyLimit, 0},
    SnowPartyInvite = {30, 0},
    SnowPartyBuyShop = {DefalutFrequencyLimit, 0},
    SnowPartyGetReward = {1, 0},
    PlanPHCarParkingUpgrade = {DefalutFrequencyLimit, 0},
    PlanPHCarParkingGetCarGift = {DefalutFrequencyLimit, 0},
    PlanPHCarParkingInviteParking = {0.2, 0},
    PlanPHCarParkingParkCar = {5, 0},
    PlanPHCarParkingAutoPark = {DefalutFrequencyLimit, 0},
    PlanPHCarParkingRankTab = {DefalutFrequencyLimit, 0},
    GCByObjectOrMemory = {10, 0},
    LowGCByObjectOrMemory = {5, 0},
    CollectLibraryThemeBatch = {1, 0},
    SeasonSwitchButton = {1, 0},
    SettingPrivacySwitchButton = {1, 0},
    WoWTabSwitchButton = {1, 0},
    NewWoWTabSwitchButton = {0.8, 0},
    UGCInventorySwitchButton = {0.5, 0},
    FilterTagRefresh = {1, 0},
    PlanPHSearchPlan = {3, 0},
    PlanPHLobbyClickStore = {2, 0},
    HomeScanQRClick = {2, 0},
    BlackFridayVote = {DefalutFrequencyLimit, 0},
    BlackFridayGroupBuyShare = {2, 0},
    BlackFridayUpgradePreview = {2, 0},
    BlackFridaySubJoinGroup = {2, 0},
    BlackFridayRPJoinGroup = {2, 0},
    BlackFridayRPInviteAllFriend = {5, 0},
    BlackFridaySubInviteAllFriend = {1, 0},
    NewbieModeSelectionAward = {1, 0},
    SearchGuessRefreshClick = {1, 0},
    PlanPH_PartyMain_UIBP_TabClick = {1, 0},
    ThemeRefreshBtnClick = {0.5, 0},
    PlanPHNewbieGuideHandle = {0.2, 0},
    SeasonShopBtnClick = {DefalutFrequencyLimit, 0},
    ScrapGoldDiscount = {DefalutFrequencyLimit, 0},
    MainCityPrivacySetting = {1, 0},
    MainCityInviteToWorld = {60, 0},
    MainCityInviteToTopic = {60, 0},
    MainCityInviteToMainCity = {60, 0},
    MainCityInviteToCorps = {60, 0},
    MainCityInviteToFriend = {60, 0},
    MainCityInviteToManor = {60, 0},
    MainCityEnterSeesawBattle = {1, 0},
    MainCityMatch = {10, 0},
    MainCityTryReEnter = {5, 0},
    MainCityMainRingBtnClickSimple = {3, 0},
    MainCityMainRingBtnClick = {8, 0},
    MainCityContinusSkillBtnClick = {3, 0},
    MainCityMultiposeBtnClick = {3, 0},
    MainCityH5PlatformRouteClickItem = {3, 0},
    InteractiveCommon = {DefalutFrequencyLimit, 0},
    ExploreAwardBtnClick = {1, 0},
    SpecialOfferTemu = {DefalutFrequencyLimit, 0},
    PopularPKShareToFriend = {3, 0},
    CreateWalletWithdrawalClick = {1, 0},
    CreateWalletIncomeAndWithdrawalClick = {1, 0},
    CreateWalletOneTabClick = {1, 0},
    ActiveMotivationApplyForClick = {0.5, 0},
    ActiveMotivationClaimRewardsClick = {0.5, 0},
    NewMapDailyRefreshBtnClick = {0.7, 0},
    WeaponStrengthPopSecondTabClick = {1.5, 0},
    MainCityQueryPlayerState = {0.5, 0},
    ConquerorVideoPlayLimit = {1, 0},
    ChangeUGCAuthorSkin = {1.2, 0},
    CreativeGameParamUI = {2, 0},
    CreativeAIGCAssetBtnClick = {0.5, 0},
    BlockyluaCustomInput = {2, 0},
    CreativeCreativityRankSwitch = {3, 0},
    UsePromotionCard = {4, 0},
    WowPassTask = {DefalutFrequencyLimit, 0},
    StopAction = {0.1, 0},
    PrefabSearchBtn = {1, 0},
    AiCopilotChatStopBtnClick = {3, 0},
    CommonOneSeconds = {1, 0},
    PrefabMallTab = {1.5, 0},
    PrefabMallAddFavorite = {1, 0},
    PrefabMallAddLike = {1, 0},
    PrefabOfficialSend = {3, 0},
    PrefabOfficialCollectionSend = {3, 0},
    PrefabMallMyShare = {10, 0},
    PrefabMallMyFavorite = {10, 0},
    PrefabMallMyShareAndFavorte = {10, 0},
    BackPackCustomPrefab = {10, 0},
    PrefabMallReqBin = {1, 0},
    PrefabMallPrefabAllowSecondEditFilterButton = {1.1, 0},
    PrefabMallUpload = {3, 0},
    PrefabMallUploadConfirm = {1, 0},
    UGCAcceptChallengeChat = {1, 0},
    UGCTemplateTab = {1, 0},
    UGCRankTab = {0.5, 0},
    PromotionStatusPrivacySetting = {1, 0},
    ChatPlaerRecommandSideBarRefresh = {3, 0},
    PlanCHDisplayEditClearData = {1, 0},
    PlanCHDisplayEditSaveBackgroundData = {1, 0},
    PlanCHDisplayEditSaveData = {1.5, 0},
    PlanCHDisplayAutoEditData = {3, 0},
    PlanCHDisplayEditSwitchHallPart = {0.1, 0},
    PlanCHTeleport = {2, 0},
    PlanCHClickCommon = {1, 0},
    UGC_WOW_COIN = {1, 0},
    UGC_APPRECIATION_BUTTON = {1, 0},
    UGC_PREFAB_MALL_CLICK = {1.5, 0},
    SubtabCabinShowPageClick = {1.5, 0},
    CardCollectionGetAward = {1.5, 0},
    UGCPublishStateChange1 = {0.5, 0},
    UGCPublishStateChange2 = {0.5, 0},
    UGCPublishStateChange3 = {1, 0},
    UGC_HALL_MOD_CLICK = {0.5, 0},
    FinancialTaskRewardReceive = {1.1, 0},
    UGCAppreciationGroupJoin = {DefalutFrequencyLimit, 0},
    TeamQuickSkinUseAndRemove = {2, 0},
    TeamQuickInviteTeamUp = {5, 0},
    TeamQuickInviteToWorld = {60, 0},
    TeamQuickInviteToCorps = {60, 0},
    TeamQuickSwitchTeam = {1, 0},
    PlanCHArenaMatch = {2, 0},
    PlanCHArenaContinue = {2, 0},
    PlanCHArenaPetUpgrade = {0.5, 0},
    PlanCHArenaPetUse = {1, 0},
    PlanCHArenaSkillChange = {1, 0},
    PlanCHArenaSkillUpgrade = {0.5, 0},
    PlanCHArenaAutoLineup = {2, 0},
    PlanCHArenaSkillLearn = {0.5, 0},
    PlanCHArenaSkillReplaceOK = {1, 0},
    PlanCHArenaBattleConfirm = {1, 0},
    PlanCHArenaBuffConfirm = {1, 0},
    PlanCHArenaAddBattle = {1, 0},
    PlanCHArenaExchange = {1, 0},
    PlanCHArenaChallenge = {2, 0},
    PlanCHArenaPlayback = {2, 0}
  },
  ModuleFrequencyLimit = {
    LobbyVehicle = {3, 0},
    LobbyVehicleAccessory = {3, 0}
  },
  DefaultCommonIcon = "/Game/UMG/Texture/Lobby_NoAtlas/Common/Shop/Common_Item_Zhanbei.Common_Item_Zhanbei",
  DefaultSingleSniperIcon = "/Game/UMG/Texture/Lobby_NoAtlas/Common/Shop/Common_Item_Qiangxie_0004.Common_Item_Qiangxie_0004",
  DefaultBurstSniperIcon = "/Game/UMG/Texture/Lobby_NoAtlas/Common/Shop/Common_Item_Qiangxie_0006.Common_Item_Qiangxie_0006",
  DefaultWardrobeSuitIcon = "/Game/UMG/Texture/Lobby_NoAtlas/Common/Shop/Common_Item_Fushi_7.Common_Item_Fushi_7"
}
local string_format = string.format
local string_gsub = string.gsub
local local local local local local local local local local local local local local local local local local local local slua_loadClass = slua.loadClass
local slua_isValid = slua.isValid
local math_abs = math.abs
local StringUtil = require("common.string_util")
function UIUtil.CanClickNow(info, showTips)
  if info == nil then
    log_error(bWriteLog and "UIUtil.CanClickNow, no info and let it go.")
    return true
  end
  if showTips == nil then
    showTips = true
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
  if math_abs(currentTime - info[2]) < info[1] then
    if showTips then
      local tips = LocUtil.GetLocalizeResStr(421015)
      ShowNotice(tips)
    end
    return false
  else
    info[2] = currentTime
    return true
  end
end
function UIUtil.CheckClickCooldownSilently(info)
  if info == nil then
    log_error(bWriteLog and "UIUtil.CheckClickCooldownSilently, no info and let it go.")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
  if math_abs(currentTime - info[2]) < info[1] then
    return false
  end
  return true
end
function UIUtil.BoolToVisible(visible, collapse, isButton)
  if collapse == nil then
    collapse = true
  end
  if visible then
    if isButton then
      return UEnums.ESlateVisibility.Visible
    else
      return UEnums.ESlateVisibility.SelfHitTestInvisible
    end
  elseif collapse then
    return UEnums.ESlateVisibility.Collapsed
  else
    return UEnums.ESlateVisibility.Hidden
  end
end
function UIUtil.SetWidgetVisible(widget, visible, isButton)
  if not widget then
    return
  end
  if visible then
    if isButton then
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UIUtil.IsWidgetVisible(widget)
  if not widget then
    return false
  end
  local widgetVisibility = widget:GetVisibility()
  return widgetVisibility == UEnums.ESlateVisibility.Visible or widgetVisibility == UEnums.ESlateVisibility.SelfHitTestInvisible or widgetVisibility == UEnums.ESlateVisibility.HitTestInvisible
end
function UIUtil.GetGameInstance()
  if slua_isValid(slua_GameFrontendHUD) then
    return slua_GameFrontendHUD:GetGameInstance()
  end
  local GameInstClass = import("STExtraGameInstance")
  return GameInstClass.GetInstance()
end
function UIUtil.GetGameFrontendHUD()
  return UIUtil.GetGameInstance():GetAssociatedFrontendHUD()
end
function UIUtil.GetFirstGameFrontendHUD()
  local GameBackendHUD = import("GameBackendHUD")
  local BackendHudObject = GameBackendHUD.GetInstance()
  if slua_isValid(BackendHudObject) then
    return BackendHudObject:GetFirstGameFrontendHUD()
  end
  return nil
end
function UIUtil.GetGlobalUIFunctionLibrary()
  if UIUtil.globalUIFunctionLibrary == nil then
    UIUtil.globalUIFunctionLibrary = import("/Game/UMG/UI_Utility/GlobalUIFunctionLibrary.GlobalUIFunctionLibrary_C")
  end
  return UIUtil.globalUIFunctionLibrary
end
function UIUtil.SetCornerQuality(image, quality)
  UIUtil.GetGlobalUIFunctionLibrary().SetCornerQuality(image, quality, UIUtil.GetGameInstance())
end
function UIUtil.GetCommonItemFunctionLibrary()
  if UIUtil.commonItemFunctionLibrary == nil then
    UIUtil.commonItemFunctionLibrary = import("/Game/UMG/UI_Logic/Common/CommonItemFunctionLibrary.CommonItemFunctionLibrary_C")
  end
  return UIUtil.commonItemFunctionLibrary
end
function UIUtil.SetItemIconAndQuality(itemId, Image_Icon_Quality_Bottom, Image_Quality_Bg, Image_Icon, SpecialIcon, Render)
  Render = Render or 0
  UIUtil.GetCommonItemFunctionLibrary().SetItemIconAndQuality(itemId, Render, Image_Icon_Quality_Bottom, Image_Quality_Bg, Image_Icon, SpecialIcon, UIUtil.GetGameInstance())
end
function UIUtil.SetBigItemIconAndQuality(itemId, Image_Icon_Quality_Bottom, Image_Quality_Bg, Image_Icon, SpecialIcon)
  UIUtil.GetCommonItemFunctionLibrary().SetBigItemIconAndQuality(itemId, Image_Icon_Quality_Bottom, Image_Quality_Bg, Image_Icon, SpecialIcon, UIUtil.GetGameInstance())
  local itemData = CDataTable.GetTableData("Item", itemId)
  if not itemData then
    log_error(bWriteLog and "UIUtil.SetBigItemIconAndQuality item config is not found, itemId: " .. tostring(itemId))
    return
  end
  local QualityPath = UIUtil.GetBgQualityPath(itemData.ItemQuality)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(Image_Quality_Bg, QualityPath)
end
function UIUtil.ShowItemTips(resId, widget, localPos, validHours, itemCount, bIsShowCloseBtn, Config)
  local logic_itemTipPanel = require("client.slua.logic.common.logic_itemTipPanel")
  logic_itemTipPanel.ShowItemTips(resId, widget, {
    uObj_localPos = localPos,
    nValidHours = validHours,
    nItemCount = itemCount,
    bIsShowCloseBtn = bIsShowCloseBtn,
    t  })
end
function UIUtil.CloseItemTips()
  UIUtil.GetGlobalUIFunctionLibrary().CloseItemTips(UIUtil.GetGameInstance())
end
function UIUtil.OpenUseItemUI(itemInsId)
  GLOBAL_USE_ITEM = itemInsId
  local wardrobe_item_use_utils = require("client.slua.logic.wardrobe.wardrobe_item_use_utils")
  wardrobe_item_use_utils.UseItem(itemInsId)
end
function UIUtil.UpdateNationImage(image, roleNation)
  UIUtil.UpdateNationImageByLua(image, roleNation)
end
function UIUtil.UpdateNationImageByLua(image, roleNation, isDefault, sync)
  local switch = GlobalData.GetNationSwitch("All")
  if switch and roleNation ~= "" then
    image:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local nationInfo = GlobalData.GetNationInfo(roleNation)
    local util = require("client.slua_ui_framework.util")
    if nationInfo and nationInfo.res_path then
      util.SetTexture(image, nationInfo.res_path, {sync = false})
    end
  elseif switch and isDefault then
    local util = require("client.slua_ui_framework.util")
    util.SetTexture(image, "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_iland_png", {sync = false})
  else
    image:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UIUtil.SetAdaptation(widget)
  if not slua.isValid(widget) then
    return
  end
  if not Game:IsValid(Client) then
    return
  end
  local UUserWidget = import("/Script/UMG.UserWidget")
  if UUserWidget and Game:IsClassOf(widget, UUserWidget) then
    log_error(bWriteLog and "UIUtil.SetAdaptation :  UserWidget Make Crash " .. tostring(widget))
    return
  end
  local Margin = UIUtil.GetScreenPadding()
  local Slot = widget.Slot
  if not Slot then
    log_error(bWriteLog and "UIUtil.SetAdaptation Slot is empty")
    return
  end
  if Slot.SetAnchors then
    Slot:SetOffsets(FMargin(Margin.Left, 0, Margin.Right, 0))
  end
  slua_GameFrontendHUD:AddAdaptationWidgetDelegate(Slot)
end
function UIUtil.SetScreenPadding(Padding)
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.SetScreenPadding(Padding)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SCREENPADDING_CHANGED, Padding)
end
function UIUtil.GetScreenPadding()
  local ScriptHelperClient = import("ScriptHelperClient")
  return ScriptHelperClient.GetScreenPadding()
end
function UIUtil.GetWidgetByPath(widgetPath)
  local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
  local widgetClass = slua_loadClass(widgetPath)
  local widgets = slua.Array(UEnums.EPropertyClass.Object, widgetClass)
  local outWidgets = WidgetBlueprintLibrary.GetAllWidgetsOfClass(UIUtil.GetGameInstance(), widgets, widgetClass, false)
  log(bWriteLog and "outWidgets:Num():" .. outWidgets:Num())
  if outWidgets:Num() >= 1 then
    return outWidgets:Get(0)
  end
  return nil
end
function UIUtil.GetLogicManagerByName(logicName)
  return slua_GameFrontendHUD:GetLogicManagerByName(logicName)
end
function UIUtil.GetLuaObjectByLogicName(logicName)
  local logic = slua_GameFrontendHUD:GetLogicManagerByName(logicName)
  return logic.LuaObject
end
function UIUtil.GetWidgetByLogicName(logicName, widgetIndex)
  local logic = UIUtil.GetLogicManagerByName(logicName)
  if not logic then
    return nil
  end
  local widgets = logic.WidgetList
  widgetIndex = widgetIndex or 0
  if widgets:Num() >= widgetIndex + 1 then
    return widgets:Get(widgetIndex)
  end
  return nil
end
function UIUtil.GetWidgetByName(logicName, widgetName)
  local logic = UIUtil.GetLogicManagerByName(logicName)
  if not logic then
    return nil
  end
  return logic:GetWidgetByName(widgetName)
end
function UIUtil.GetLuaTableByName(name)
  if UIUtil.globalLuaUaeWidgetTable[name] then
    return UIUtil.globalLuaUaeWidgetTable[name]
  else
    return nil
  end
end
function UIUtil.InitScrollBox(widget)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithoutParentComponent(UIComponentModule.Config.loop_scroll_box, widget)
end
function UIUtil.GetItemTimeS(ResId, FirstTimeNum)
  return UIUtil.GetGlobalUIFunctionLibrary().GetItemTimeS(ResId, FirstTimeNum, UIUtil.GetGameInstance())
end
function UIUtil.GetItemTimeLimitText(bShowUseTime, resId, timeStr)
  log(bWriteLog and string_format("UIUtil.GetItemTimeLimitText bShowUseTime : %s, resId : %s, timeStr : %s", bShowUseTime, resId, timeStr))
  if bShowUseTime then
    log(bWriteLog and "UIUtil.GetItemTimeLimitText \228\189\191\231\148\168\230\156\159\233\153\144")
    return UIUtil:GetDifferentCountryTimeFormatContent(timeStr) or "", true
  else
    local item_tips_util = require("client.slua.umg.Wardrobe.tips.item_tips_util")
    if type(timeStr) == "number" then
      return item_tips_util:GetRemainTimeString(timeStr), true
    else
      local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
      local wardrobeItem_Data = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(resId, true)
      if wardrobeItem_Data and UIUtil.GetIsShowOwnTextOrTimeRemaining(wardrobeItem_Data.itemType, wardrobeItem_Data.itemSubType) then
        log(bWriteLog and "UIUtil.GetItemTimeLimitText \229\137\169\228\189\153\230\151\182\233\151\180")
        return item_tips_util:GetRemainTimeString(wardrobeItem_Data.expireTS)
      else
        log(bWriteLog and "UIUtil.GetItemTimeLimitText \229\136\176\230\156\159\230\151\182\233\151\180")
        return UIUtil:GetDifferentCountryTimeFormatContent(timeStr) or "", true
      end
    end
  end
end
local isitemTypeInTable = function(itemType)
  local cfg = CDataTable.GetTableDataByFilter("ItemTipInfo", "itemType", itemType, "subType", -1)
  if cfg then
    return true
  end
  return false
end
local isSubTypeInTable = function(subType)
  local cfg = CDataTable.GetTableDataByFilter("ItemTipInfo", "subType", subType)
  if cfg then
    return true
  end
  return false
end
local isAllInTable = function(itemType, subType)
  local cfg = CDataTable.GetTableDataByFilter("ItemTipInfo", "itemType", itemType, "subType", subType)
  if cfg then
    return true
  end
  return false
end
function UIUtil.GetIsShowOwnTextOrTimeRemaining(itemType, itemSubType, notTodo)
  if itemSubType and isSubTypeInTable(itemSubType) and notTodo ~= 1 then
    return true
  end
  if itemType and isitemTypeInTable(itemType) and notTodo ~= 2 then
    return true
  end
  if itemType and itemSubType and isAllInTable(itemType, itemSubType) and notTodo ~= 3 then
    return true
  end
  return false
end
function UIUtil:GetDifferentCountryTimeFormatContent(time_s)
  local TimeUtil = require("client.common.time_util")
  local new  local tmie_num = TimeUtil.TimeStringToUnixstamp(time_s)
  local temp_str = TimeUtil.FormatTime_YMDHM(tmie_num)
  if newtime_s ~= nil and temp_str ~= nil then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    if (strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea()) and tmie_num ~= 0 then
      temp_str = TimeUtil.FormatTime_YMDHM(tmie_num, true)
      newtime_s = LocUtil.LocalizeResFormat(4425, temp_str)
    else
      newtime_s = string_gsub(newtime_s, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)", tostring(temp_str))
    end
  end
  return newtime_s
end
function UIUtil.GetLocalizationString(key)
  local IntlHelper = import("IntlHelper")
  return IntlHelper.GetLocalizationString(key)
end
function UIUtil.ShowLobbyCamera(bShow)
  log(bWriteLog and "UIUtil.ShowLobbyCamera:" .. tostring(bShow))
  if not GameStatus.IsIn2DLobby() then
    log(bWriteLog and "UIUtil.ShowLobbyCamera not in lobby")
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.level_sequence_player_system) then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if bShow then
    Lobby_camera_manager_module:SwitchCamera_Only(Lobby_camera_manager_module.currentCameraID, 0)
  else
    Lobby_camera_manager_module:SwitchCamera_Only_CustomCfg({
      location = FVector(1000000, 0, 0),
      rotation = FRotator(0, 0, 0),
      scale = FVector(1, 1, 1),
      fov = 30,
      blendTime = 0
    })
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_CAMERA_SHOWHIDE, bShow)
end
function UIUtil.SetSize(widget, sizeX, sizeY)
  local slot = widget.Slot
  if not slot then
    log_error("UIUtil.SetSize widget = nil")
    return
  end
  local SetSize = slot.SetSize
  if SetSize then
    slot:SetSize(FVector2D(sizeX, sizeY))
  end
end
local LeftBarQualityPath = {
  [3] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_03_1_png.T_icon_Airquality_03_1_png",
  [4] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_04_1_png.T_icon_Airquality_04_1_png",
  [5] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_05_1_png.T_icon_Airquality_05_1_png",
  [6] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_06_1_png.T_icon_Airquality_06_1_png",
  [7] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_07_1_png.T_icon_Airquality_07_1_png",
  [8] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_Airquality_08_1_png.T_icon_Airquality_08_1_png"
}
function UIUtil.GetLeftBarQualityPath(quality)
  if not quality or quality < 3 or 8 < quality then
    quality = 3
  end
  return LeftBarQualityPath[quality]
end
local QualityPath = {
  [0] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_2_png.T_item_icon_quality_2_png",
  [1] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_2_png.T_item_icon_quality_2_png",
  [2] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_2_png.T_item_icon_quality_2_png",
  [3] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_3_png.T_item_icon_quality_3_png",
  [4] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_4_png.T_item_icon_quality_4_png",
  [5] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_5_png.T_item_icon_quality_5_png",
  [6] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_6_png.T_item_icon_quality_6_png",
  [7] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_7_png.T_item_icon_quality_7_png",
  [8] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_item_icon_quality_8_png.T_item_icon_quality_8_png"
}
function UIUtil.GetQualityPath(quality)
  return QualityPath[quality]
end
function UIUtil.GetTQualityPath(quality)
  if quality == 10 then
    quality = 8
  end
  return QualityPath[quality]
end
local PHomeBgQualityPath = {
  [3] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Green_png.Home_Icon_Shop_Quality_Green_png",
  [4] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Blue_png.Home_Icon_Shop_Quality_Blue_png",
  [5] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Purple_png.Home_Icon_Shop_Quality_Purple_png",
  [6] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Pink_png.Home_Icon_Shop_Quality_Pink_png",
  [7] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Red_png.Home_Icon_Shop_Quality_Red_png",
  [8] = "/Game/UMG/Texture_200/Atlas/Home/Frames/Home_Icon_Shop_Quality_Golden_png.Home_Icon_Shop_Quality_Golden_png"
}
function UIUtil.GetPHomeBgQualityPath(quality)
  local index = tonumber(quality)
  if not index or index < 3 then
    index = 3
  elseif 8 < index then
    index = 8
  end
  return PHomeBgQualityPath[index]
end
local BgQualityPath = {
  [0] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_02_png.T_icon_shop_02_png",
  [1] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_02_png.T_icon_shop_02_png",
  [2] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_02_png.T_icon_shop_02_png",
  [3] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_03_png.T_icon_shop_03_png",
  [4] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_04_png.T_icon_shop_04_png",
  [5] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_05_png.T_icon_shop_05_png",
  [6] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_06_png.T_icon_shop_06_png",
  [7] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_07_png.T_icon_shop_07_png",
  [8] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_08_png.T_icon_shop_08_png",
  [9] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_09_png.T_icon_shop_09_png",
  [10] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_010_png.T_icon_shop_010_png"
}
function UIUtil.GetBgQualityPath(quality)
  return BgQualityPath[quality]
end
local TBgQualityPath = {
  [0] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_02_png.Txmission_icon_shop_02_png",
  [1] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_02_png.Txmission_icon_shop_02_png",
  [2] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_02_png.Txmission_icon_shop_02_png",
  [3] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_03_png.Txmission_icon_shop_03_png",
  [4] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_04_png.Txmission_icon_shop_04_png",
  [5] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_05_png.Txmission_icon_shop_05_png",
  [6] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_06_png.Txmission_icon_shop_06_png",
  [7] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_07_png.Txmission_icon_shop_07_png",
  [8] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_08_png.Txmission_icon_shop_08_png",
  [9] = "/Game/Mod/TPlan/Arts/UI/Atlas/Frames/Txmission_icon_shop_09_png.Txmission_icon_shop_09_png",
  [10] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_shop_010_png.T_icon_shop_010_png"
}
function UIUtil.GetTBgQualityPath(quality)
  return TBgQualityPath[quality]
end
local XieQualityPath = {
  [1] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_02_png.T_icon_quality_02_png",
  [2] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_02_png.T_icon_quality_02_png",
  [3] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_03_png.T_icon_quality_03_png",
  [4] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_04_png.T_icon_quality_04_png",
  [5] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_05_png.T_icon_quality_05_png",
  [6] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_06_png.T_icon_quality_06_png",
  [7] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_07_png.T_icon_quality_07_png",
  [8] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_08_png.T_icon_quality_08_png"
}
function UIUtil.GetXieQualityPath(quality)
  return XieQualityPath[quality]
end
local BottomQualityPath = {
  [1] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_2_png.T_Label_icon_quality_2_png",
  [2] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_2_png.T_Label_icon_quality_2_png",
  [3] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_3_png.T_Label_icon_quality_3_png",
  [4] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_4_png.T_Label_icon_quality_4_png",
  [5] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_5_png.T_Label_icon_quality_5_png",
  [6] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_6_png.T_Label_icon_quality_6_png",
  [7] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_7_png.T_Label_icon_quality_7_png",
  [8] = "/Game/UMG/Texture/Atlas/Quality/Frames/T_Label_icon_quality_8_png.T_Label_icon_quality_8_png"
}
function UIUtil.GetBottomQualityPath(quality)
  return BottomQualityPath[quality]
end
local CombatReadinessQualityPath = {
  [0] = "/Game/UMG/Texture/Lobby_NoAtlas/CombatReadiness/war_image_textbg00.war_image_textbg00",
  [1] = "/Game/UMG/Texture/Lobby_NoAtlas/CombatReadiness/war_image_textbg01.war_image_textbg01",
  [2] = "/Game/UMG/Texture/Lobby_NoAtlas/CombatReadiness/war_image_textbg02.war_image_textbg02",
  [3] = "/Game/UMG/Texture/Lobby_NoAtlas/CombatReadiness/war_image_textbg03.war_image_textbg03",
  [4] = "/Game/UMG/Texture/Lobby_NoAtlas/CombatReadiness/war_image_textbg04.war_image_textbg04"
}
function UIUtil.GetCombatReadinessQualityPath(quality)
  if quality < 4 or 8 < quality then
    return ""
  end
  return CombatReadinessQualityPath[quality - 4]
end
local QualityDropDesc = {
  [1] = 4341,
  [2] = 4342,
  [3] = 4343,
  [4] = 4344,
  [5] = 4345,
  [6] = 4346,
  [7] = 4347,
  [8] = 4348
}
function UIUtil.GetQualityDropDesc(Quality)
  local result = ""
  local LocId = QualityDropDesc[Quality]
  if LocId then
    result = LocUtil.GetLocalizeResStr(LocId)
  end
  return result
end
function UIUtil.GetIntimacyRelationName(relation)
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  return IntimacyUtils.GetRelationText(relation)
end
function UIUtil.GetWidgetViewportPos(widget, localPosX, localPosY)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  if not slua.isValid(widget) then
    return FVector2D(0, 0)
  end
  local Geometry = widget:GetCachedGeometry()
  local Coordinate = FVector2D(localPosX or 0, localPosY or 0)
  local _, ViewportPosition = SlateBlueprintLibrary.LocalToViewport(widget, Geometry, Coordinate, FVector2D(0, 0), FVector2D(0, 0), UIUtil.GetGameInstance())
  return ViewportPosition
end
function UIUtil.LocalToContainerBoundingBox(widget)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = widget:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  local TL = LocalSize * FVector2D(0, 0)
  local BR = LocalSize * FVector2D(1, 1)
  local TLViewportPixelPos, TLViewportLayoutPos = SlateBlueprintLibrary.LocalToViewport(widget, Geometry, TL, FVector2D(0, 0), FVector2D(0, 0))
  local BRViewportPixelPos, BRViewportLayoutPos = SlateBlueprintLibrary.LocalToViewport(widget, Geometry, BR, FVector2D(0, 0), FVector2D(0, 0))
  return TLViewportLayoutPos, BRViewportLayoutPos - TLViewportLayoutPos
end
function UIUtil.GetWidgetViewportPosInNormalized(widget, normalizeX, normalizeY)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = widget:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  local Coordinate = LocalSize * FVector2D(normalizeX or 0, normalizeY or 0)
  local ViewportPixelPos, ViewportLayoutPos = SlateBlueprintLibrary.LocalToViewport(widget, Geometry, Coordinate, FVector2D(0, 0), FVector2D(0, 0))
  return ViewportPixelPos, ViewportLayoutPos
end
function UIUtil.RayIntersectPlane(rayP0, rayDir, planeP1, planeNormal)
  local t = (FVector.DotProduct(planeNormal, planeP1) - FVector.DotProduct(planeNormal, rayP0)) / FVector.DotProduct(planeNormal, rayDir)
  if 0 <= t then
    local intersect = rayP0 + rayDir * t
    return true, intersect
  end
  return false, nil
end
local ApplyAdaptiveLayoutForAxis = function(Axis, AdaptiveLayoutType, Anchors, Alignment, Position, bExpandToPositive, Offset)
  if AdaptiveLayoutType == UEnums.EAdaptiveLayout.Inside or AdaptiveLayoutType == UEnums.EAdaptiveLayout.Outside then
    Anchors.Minimum[Axis] = bExpandToPositive and 1 or 0
    Anchors.Maximum[Axis] = bExpandToPositive and 1 or 0
  end
  if AdaptiveLayoutType == UEnums.EAdaptiveLayout.Inside then
    Alignment[Axis] = bExpandToPositive and 1 or 0
  elseif AdaptiveLayoutType == UEnums.EAdaptiveLayout.Outside then
    Alignment[Axis] = bExpandToPositive and 0 or 1
  elseif AdaptiveLayoutType == UEnums.EAdaptiveLayout.Middle then
    Anchors.Minimum[Axis] = 0.5
    Anchors.Maximum[Axis] = 0.5
    Alignment[Axis] = 0.5
  end
  if Offset then
    Position[Axis] = bExpandToPositive and -Offset or Offset
  end
end
function UIUtil.SetAdaptiveLayout(widget, HorizontalType, VerticalType, OffsetX, OffsetY)
  if (HorizontalType or VerticalType) and widget.Slot and widget.Slot.SetAnchors then
    local ParentWidget = widget:GetParent()
    if not slua.isValid(ParentWidget) then
      return
    end
    local ViewportSize = UIUtil.GetViewportSize()
    local ParentCenterPos = UIUtil.GetWidgetViewportPosInNormalized(ParentWidget, 0.5, 0.5)
    local bExpandToRight = ParentCenterPos.X < ViewportSize.X * 0.5
    local bExpandToDown = ParentCenterPos.Y < ViewportSize.Y * 0.5
    local Anchors = widget.Slot.LayoutData.Anchors
    local Position = widget.Slot:GetPosition()
    local Alignment = widget.Slot.LayoutData.Alignment
    if HorizontalType then
      ApplyAdaptiveLayoutForAxis("X", HorizontalType, Anchors, Alignment, Position, bExpandToRight, OffsetX)
    end
    if VerticalType then
      ApplyAdaptiveLayoutForAxis("Y", VerticalType, Anchors, Alignment, Position, bExpandToDown, OffsetY)
    end
    widget.Slot:SetPosition(Position)
    widget.Slot:SetAnchors(Anchors)
    widget.Slot:SetAlignment(Alignment)
    return bExpandToRight, bExpandToDown
  end
end
function UIUtil.GetViewportScale()
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  return WidgetLayoutLibrary.GetViewportScale(UIUtil.GetGameInstance())
end
function UIUtil.GetViewportSize()
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  return WidgetLayoutLibrary.GetViewportSize(UIUtil.GetGameInstance())
end
function UIUtil.GetViewportSizebyScale()
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  return WidgetLayoutLibrary.GetViewportSize(UIUtil.GetGameInstance()) / WidgetLayoutLibrary.GetViewportScale(UIUtil.GetGameInstance())
end
function UIUtil.GetLocalSize(widget)
  local Geometry = widget:GetCachedGeometry()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  return SlateBlueprintLibrary.GetLocalSize(Geometry)
end
function UIUtil.GetAbsoluteSize(widget)
  local Geometry = widget:GetCachedGeometry()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  return SlateBlueprintLibrary.GetAbsoluteSize(Geometry)
end
function UIUtil.GetScreenPositionBy3DActor(actor)
  local result = FVector2D(0, 0)
  if actor ~= nil then
    local location = actor:K2_GetActorLocation()
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 3D.X = " .. tostring(location.X) .. ", 3D.Y = " .. tostring(location.Y) .. ", 3D.Z = " .. tostring(location.Z))
    local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
    local playerController = slua_GameFrontendHUD:GetPlayerController()
    result = WidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(playerController, location)
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 2D.X = " .. tostring(result.X) .. ", 2D.Y = " .. tostring(result.Y))
  else
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, actor = " .. tostring(actor))
  end
  return result
end
function UIUtil.GetScreenPositionBy3DActor2(actor)
  local result = FVector2D(0, 0)
  if actor ~= nil then
    local location = actor:K2_GetActorLocation()
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 3D.X = " .. tostring(location.X) .. ", 3D.Y = " .. tostring(location.Y) .. ", 3D.Z = " .. tostring(location.Z))
    local playerController = slua_GameFrontendHUD:GetPlayerController()
    local OutVector = FVector2D(0, 0)
    _, result = playerController:ProjectWorldLocationToScreen(location, result, false)
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 2D.X = " .. tostring(result.X) .. ", 2D.Y = " .. tostring(result.Y))
  else
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, actor = " .. tostring(actor))
  end
  return result
end
function UIUtil.GetScreenPositionBy3DLoc(location)
  local result = FVector2D(0, 0)
  log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 3D.X = " .. tostring(location.X) .. ", 3D.Y = " .. tostring(location.Y) .. ", 3D.Z = " .. tostring(location.Z))
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  result = WidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(playerController, location)
  log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 2D.X = " .. tostring(result.X) .. ", 2D.Y = " .. tostring(result.Y))
  return result
end
function UIUtil.GetScreenPositionBy3DLoc2(location)
  local result = FVector2D(0, 0)
  if location ~= nil then
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 3D.X = " .. tostring(location.X) .. ", 3D.Y = " .. tostring(location.Y) .. ", 3D.Z = " .. tostring(location.Z))
    local playerController = slua_GameFrontendHUD:GetPlayerController()
    local OutVector = FVector2D(0, 0)
    _, result = playerController:ProjectWorldLocationToScreen(location, result, false)
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, 2D.X = " .. tostring(result.X) .. ", 2D.Y = " .. tostring(result.Y))
  else
    log(bWriteLog and "UIUtil.GetScreenPositionBy3DActor, actor = " .. tostring(actor))
  end
  return result
end
function UIUtil.SetMaskBoxItem(maskBoxItem, widgetToShow, offsetX, offsetY)
  if maskBoxItem == nil or maskBoxItem.MaskBox == nil then
    return
  end
  return UIUtil.SetMaskBox(maskBoxItem.MaskBox, widgetToShow, offsetX, offsetY)
end
function UIUtil.SetMaskBoxItemAlpha(maskBoxItem, alpha)
  maskBoxItem.Image_0:SetColorAndOpacity(FLinearColor(0, 0, 0, alpha))
end
function UIUtil.SetMaskBoxTouchSpace(maskBoxItem, targetWidget, OffsetX, OffsetY)
  if maskBoxItem == nil or targetWidget == nil then
    return
  end
  OffsetX = OffsetX or 0
  OffsetY = OffsetY or 0
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local widgetPos = UIUtil.GetWidgetViewportPos(targetWidget, 0, 0)
  log(bWriteLog and "SetMaskBoxTouchSpace widgetPos.X = " .. widgetPos.X .. ", widgetPos.Y = " .. widgetPos.Y)
  local geometry = targetWidget:GetCachedGeometry()
  local AbsoluteSize = SlateBlueprintLibrary.GetAbsoluteSize(geometry)
  log(bWriteLog and "SetMaskBoxTouchSpace AbsoluteSize.X = " .. AbsoluteSize.X .. ", AbsoluteSize.Y = " .. AbsoluteSize.Y)
  local scale = UIUtil.GetViewportScale()
  log(bWriteLog and "SetMaskBoxTouchSpace scale = " .. scale)
  local viewportSize = UIUtil.GetViewportSize()
  log(bWriteLog and "SetMaskBoxTouchSpace viewportSize.X = " .. viewportSize.X .. ", viewportSize.Y = " .. viewportSize.Y)
  local fix = 0
  local offsetLeft = widgetPos.X + fix
  local offsetTop = widgetPos.Y + fix
  local offsetRight = (viewportSize.X - widgetPos.X * scale - AbsoluteSize.X) / scale + fix + OffsetX
  local offsetBottom = (viewportSize.Y - widgetPos.Y * scale - AbsoluteSize.Y) / scale + fix + OffsetY
  log(bWriteLog and "SetMaskBoxTouchSpace offsetLeft = " .. offsetLeft)
  log(bWriteLog and "SetMaskBoxTouchSpace offsetTop = " .. offsetTop)
  log(bWriteLog and "SetMaskBoxTouchSpace offsetRight = " .. offsetRight)
  log(bWriteLog and "SetMaskBoxTouchSpace offsetBottom = " .. offsetBottom)
  local sizex = AbsoluteSize.X / scale
  local sizey = AbsoluteSize.Y / scale
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(maskBoxItem.Button_Right)
  slot:SetOffsets(FMargin(offsetLeft + sizex, 0, 0, 0))
  maskBoxItem.Button_Right:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  slot = WidgetLayoutLibrary.SlotAsCanvasSlot(maskBoxItem.Button_Left)
  slot:SetOffsets(FMargin(0, 0, offsetRight + sizex, 0))
  maskBoxItem.Button_Left:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  slot = WidgetLayoutLibrary.SlotAsCanvasSlot(maskBoxItem.Button_Up)
  slot:SetOffsets(FMargin(0, 0, 0, offsetBottom + sizey))
  maskBoxItem.Button_Up:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  slot = WidgetLayoutLibrary.SlotAsCanvasSlot(maskBoxItem.Button_Down)
  slot:SetOffsets(FMargin(0, offsetTop + sizey, 0, 0))
  maskBoxItem.Button_Down:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function UIUtil.SetMaskBox(maskBox, widgetToShow, offsetX, offsetY)
  if not widgetToShow or not slua.isValid(widgetToShow) then
    maskBox:SetMaskTransformPivot(FVector2D(-10000, -10000))
    maskBox:SetMaskTransformScale(FVector2D(0, 0))
    return FVector2D(-10000, -10000), FVector2D(0, 0)
  end
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local WidgetPos = UIUtil.GetWidgetViewportPos(widgetToShow, offsetX or 0, offsetY or 0)
  if not WidgetPos then
    return FVector2D(-10000, -10000), FVector2D(0, 0)
  end
  log(bWriteLog and "xxxxxx 1 = " .. WidgetPos.X)
  log(bWriteLog and "xxxxxx 2 = " .. WidgetPos.Y)
  local geometry = widgetToShow:GetCachedGeometry()
  local AbsoluteSize = SlateBlueprintLibrary.GetAbsoluteSize(geometry)
  log(bWriteLog and "xxxxxx 3 = " .. AbsoluteSize.X)
  log(bWriteLog and "xxxxxx 4 = " .. AbsoluteSize.Y)
  local ViewportSize = UIUtil.GetViewportSize()
  log(bWriteLog and "xxxxxx 5 = " .. ViewportSize.X)
  log(bWriteLog and "xxxxxx 6 = " .. ViewportSize.Y)
  local Scale = UIUtil.GetViewportScale()
  log(bWriteLog and "xxxxxx 7 = " .. Scale)
  local MaskTransformScale = AbsoluteSize / (ViewportSize * 0.5)
  log(bWriteLog and "xxxxxx 8 = " .. MaskTransformScale.X)
  log(bWriteLog and "xxxxxx 9 = " .. MaskTransformScale.Y)
  local MaskTransformPivot = (WidgetPos * Scale - AbsoluteSize * 0.5) / ViewportSize / MaskTransformScale
  log(bWriteLog and "xxxxxx 10 = " .. MaskTransformPivot.X)
  log(bWriteLog and "xxxxxx 11 = " .. MaskTransformPivot.Y)
  maskBox:SetMaskTransformPivot(MaskTransformPivot)
  maskBox:SetMaskTransformScale(MaskTransformScale)
  return MaskTransformPivot, MaskTransformScale
end
function UIUtil.ShowLobbyUI(bShow)
  local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
  if bShow then
    logic_lobby.ShowLobbyUI()
  else
    logic_lobby.HideLobbyUI()
  end
end
function UIUtil.HideLobbyAndPersonSpaceUI()
  log(bWriteLog and "UIUtil.HideLobbyOrPersonSpaceUI")
  local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  if Social_Person_Space_UIBP and Social_Person_Space_UIBP:IsShow() then
    Social_Person_Space_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  UIUtil.ShowLobbyUI(false)
end
function UIUtil.GetProgress(progress, cur, max)
  local sumLen = 0
  for i, pro in ipairs(progress) do
    sumLen = sumLen + pro.len
  end
  local percent = 0
  if max <= cur then
    percent = 1
  else
    local curLen = 0
    for i = 2, #progress do
      if cur >= progress[i].count then
        curLen = curLen + progress[i].len
      else
        local pro_i = progress[i]
        local pro_i1 = progress[i - 1]
        curLen = curLen + (cur - pro_i1.count) / (pro_i.count - pro_i1.count) * pro_i.len
        break
      end
    end
    percent = curLen / sumLen
  end
  return percent
end
function UIUtil.GetPlatformlIcon(uid)
  if not uid then
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsPlatFriend(uid) then
    local platform = BP_Platform
    if platform == BP_ENUM_PLAYFORM_BGBG then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_FB_png.T_icon_FB_png"
    elseif platform == BP_ENUM_PLAYFORM_WX then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_Noschat_png.T_icon_Noschat_png"
    elseif platform == BP_ENUM_PLAYFORM_GAMECENTER then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_GameCenter_png.T_icon_GameCenter_png"
    elseif platform == BP_ENUM_PLAYFORM_TWITTER then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_Twitter_png.T_icon_Twitter_png"
    elseif platform == BP_ENUM_PLAYFORM_VK then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_VK_png.T_icon_VK_png"
    elseif platform == BP_ENUM_PLAYFORM_LINE then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_line_png.T_icon_line_png"
    elseif platform == BP_ENUM_PLAYFORM_GOOGLEPLAY then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_Icon_GooglePlay_png.T_Icon_GooglePlay_png"
    elseif platform == BP_ENUM_PLAYFORM_BGBGByiTOP then
      return "/Game/UMG/Texture/Atlas/LobbyUI/Frames/T_icon_BGBGqidong_png.T_icon_BGBGqidong_png"
    end
  end
  return nil
end
function UIUtil.ProjectWorldLocationToWidgetPosition(x, y, z)
  local Pos = FVector(x, y, z)
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local ScreenLocation = WidgetLayoutLibrary.ProjectWorldLocationToWidgetPositionReturnValue(playerController, Pos)
  return ScreenLocation
end
function UIUtil.ProjectWorldPosToScreenPos(x, y, z)
  local playerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(playerController) then
    log_warning(bWriteLog and "UIUtil.ProjectWorldPosToScreenPos playerController is invalid")
    return
  end
  local Pos = FVector(x, y, z)
  local ScreenPos = FVector2D(0, 0)
  local bSuccess = playerController:ProjectWorldLocationToScreen(Pos, ScreenPos, true)
  if not bSuccess then
    return UIUtil.ProjectWorldLocationToWidgetPosition(x, y, z)
  end
  local Scale = UIUtil.GetViewportScale()
  if Scale and 0 < Scale and Scale ~= 1 then
    return FVector2D(ScreenPos.X / Scale, ScreenPos.Y / Scale)
  end
  return ScreenPos
end
function UIUtil.WorldToUILocalPosition(worldPos, uiRoot)
  if not slua.isValid(uiRoot) then
    return FVector2D(0, 0)
  end
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if not PlayerController then
    return FVector2D(0, 0)
  end
  local viewportSize = UIUtil.GetViewportSize()
  local screenPos = FVector2D(0, 0)
  PlayerController:ProjectWorldLocationToScreen(worldPos, screenPos, true)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = uiRoot:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  local localPos = FVector2D(0, 0)
  localPos.X = screenPos.X / viewportSize.X * LocalSize.X
  localPos.Y = screenPos.Y / viewportSize.Y * LocalSize.Y
  return localPos
end
function UIUtil.ConvertLocalPositionBetweenWidgets(uObj_sourceWidget, uSourcePos, uObj_targetWidget)
  if not slua.isValid(uObj_sourceWidget) or not slua.isValid(uObj_targetWidget) then
    return FVector2D(0, 0)
  end
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local uSourceGeometry = uObj_sourceWidget:GetCachedGeometry()
  local uAbsolutePos = SlateBlueprintLibrary.LocalToAbsolute(uSourceGeometry, uSourcePos)
  local uTargetGeometry = uObj_targetWidget:GetCachedGeometry()
  local uTargetLocalPos = SlateBlueprintLibrary.AbsoluteToLocal(uTargetGeometry, uAbsolutePos)
  return uTargetLocalPos
end
function UIUtil.JumpToByPattern(url_pattern)
  local GetJumpUrl = function(JumpUrl)
    local tb = StringUtil.Split(JumpUrl, "&")
    local _jumpUrl = "game://?module="
    local _JumpModule
    for i, v in ipairs(tb) do
      if i == 1 then
        _JumpModule = _G[v]
        if _JumpModule then
          _jumpUrl = _jumpUrl .. _JumpModule
        end
      else
        _jumpUrl = _jumpUrl .. "&" .. v
      end
    end
    return _JumpModule, _jumpUrl
  end
  local _JumpModule, _jumpUrl = GetJumpUrl(url_pattern)
  log(bWriteLog and "_JumpModule:" .. tostring(_JumpModule) .. ",_jumpUrl:" .. tostring(_jumpUrl))
  if _JumpModule ~= nil then
    if _JumpModule ~= BP_ENUM_MODULE_SHARE then
      LobbySystem.CloseOtherMenu()
    end
    if _JumpModule == BP_ENUM_MODULE_FRIEND or _JumpModule == BP_ENUM_MODULE_INVITE_FRIEND then
      UIManager.AndroidBackToLobby()
    end
    if _JumpModule == BP_ENUM_MODULE_SHOP then
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      store_supply_manager:JumpToCrateByTabId(0)
    else
      GlobalData.JumpUrl(_jumpUrl)
    end
  end
end
local GradeImage = {
  A = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_A.JS_icon_A",
  ["A+"] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_A+.JS_icon_A+",
  B = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_B.JS_icon_B",
  ["B+"] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_B+.JS_icon_B+",
  MVP = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_MVP.JS_icon_MVP",
  S = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_S.JS_icon_S",
  ["S+"] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_S+.JS_icon_S+",
  SS = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SS.JS_icon_SS",
  ["SS+"] = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SS+.JS_icon_SS+",
  SSS = "/Game/Arts/UI/NoAtlas/ResultsScoreIcon/JS_icon_SSS.JS_icon_SSS"
}
function UIUtil.GetGradeImage(grade)
  grade = grade == "" and "B" or grade
  return GradeImage[grade]
end
function UIUtil.GetItemCfg(itemId)
  return CDataTable.GetTableData("Item", itemId)
end
function UIUtil.ItemTypeCheck(itemId, inCheckType)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if itemCfg and itemCfg.ItemType and itemCfg.ItemType == inCheckType then
    return true
  end
  return false
end
function UIUtil.GetPreview(itemId, iconWidget)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  if itemCfg.Preview and itemCfg.Preview ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.Preview) then
      return itemCfg.Preview, false
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local params = {bFirst = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
      itemCfg.Preview
    }, nil, nil, params)
  end
  log(bWriteLog and "[  == Can't Find Preview" .. itemId)
  return UIUtil.GetItemBigIcon(itemId, iconWidget)
end
function UIUtil.GetItemBigIconNotPakCheck(itemId)
  log(bWriteLog and "UIUtil.GetItemBigIconNotPakCheck itemId: " .. itemId)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning]UIUtil.GetItemBigIconNotPakCheck Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  if _G.IsEditor then
    log(bWriteLog and "UIUtil.GetItemBigIconNotPakCheck IsEditor return ItemBigIcon: " .. itemCfg.ItemBigIcon)
    return itemCfg.ItemBigIcon
  end
  local table = StringUtil.Split(itemCfg.ItemBigIcon, ".")
  local ItemBigIcon = table[1]
  if ItemBigIcon and ItemBigIcon ~= "" then
    log(bWriteLog and "UIUtil.GetItemBigIconNotPakCheck ItemBigIcon: " .. ItemBigIcon)
    if UIUtil.IsFileExistsWithOutPakCheck(ItemBigIcon) then
      return itemCfg.ItemBigIcon
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local extraData = {bFirst = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {ItemBigIcon}, nil, nil, extraData)
  end
  local Smalltable = StringUtil.Split(itemCfg.ItemSmallIcon, ".")
  local ItemSmallIcon = Smalltable[1]
  if ItemSmallIcon and ItemSmallIcon ~= "" then
    log(bWriteLog and "UIUtil.GetItemBigIconNotPakCheck ItemSmallIcon: " .. ItemSmallIcon)
    if UIUtil.IsFileExistsWithOutPakCheck(ItemSmallIcon) then
      return itemCfg.ItemSmallIcon
    end
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local extraData = {bFirst = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {ItemSmallIcon}, nil, nil, extraData)
  end
  log(bWriteLog and "UIUtil.GetItemBigIconNotPakCheck Can't Get DefaultIcon" .. itemId)
  return UIUtil.GetDefaultIcon(itemId)
end
function UIUtil.IsFileExistsWithOutPakCheck(path)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local ODPakName = PufferManager.GetPakName(path)
  log(bWriteLog and "UIUtil.IsFileExistsWithOutPakCheck path = " .. tostring(path) .. " ODPakName = " .. ODPakName)
  if ODPakName == "" or Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. ODPakName) then
    log(bWriteLog and "UIUtil.IsFileExistsWithOutPakCheck isFound 1 = " .. tostring(true))
    return true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    local actualPath = string_gsub(path, "/Game/", "/Game/MultiRegion/Content/IN/")
    local ODPakName_IN = PufferManager.GetPakName(actualPath)
    log(bWriteLog and "UIUtil.IsFileExistsWithOutPakCheck actualPath = " .. tostring(actualPath) .. " ODPakName_IN = " .. ODPakName_IN)
    if ODPakName_IN == "" or Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. ODPakName_IN) then
      log(bWriteLog and "UIUtil.IsFileExistsWithOutPakCheck isFound = " .. tostring(true))
      return true
    end
  end
  log(bWriteLog and "UIUtil.IsFileExistsWithOutPakCheck isFound = " .. tostring(false))
  return false
end
function UIUtil.GetItemBigIconPakName(itemID)
  local pak = ""
  local itemCfg = UIUtil.GetItemCfg(itemID)
  if nil == itemCfg then
    return pak
  end
  if itemCfg.ItemBigIcon ~= "" then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    pak = PufferManager.GetPakName(itemCfg.ItemBigIcon)
  end
  return pak
end
function UIUtil.HasIconDownloaded(iconPath)
  if not iconPath or iconPath == "" then
    return false
  end
  local pak_util = require("client.common.pak_util")
  if pak_util.IsPufferDownloaded(iconPath) then
    return true
  end
  return false
end
function UIUtil.SetItemIconQuality(itemID, Image_IconQuality, Image_Quality, Image_Icon, Image_SpecialIcon, isAys)
  local cfg = UIUtil.GetItemCfg(itemID)
  if not cfg then
    return
  end
  local itemSmallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemID, Image_Icon)
  local util = require("client.slua_ui_framework.util")
  local params = {bHasAddKnownMissing = bHasAddKnownMissing}
  util.SetTexture(Image_Icon, itemSmallIcon, params)
  local quality = cfg.ItemQuality
  UIUtil.SetQuality(Image_IconQuality, quality)
  UIUtil.SetBgQuality(Image_Quality, quality)
  util.SetTexture(Image_SpecialIcon, cfg.SpecialIcon, {sync = isAys})
end
function UIUtil.SetQuality(widget, quality)
  local path = UIUtil.GetQualityPath(quality)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(widget, path)
end
function UIUtil.SetBgQuality(widget, quality)
  local path = UIUtil.GetBgQualityPath(quality)
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(widget, path)
end
function UIUtil.GetItemBigIcon(itemId, iconWidget, bShowBig)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  local bHasAddKnownMissing = false
  if itemCfg.ItemBigIcon and itemCfg.ItemBigIcon ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemBigIcon) then
      return itemCfg.ItemBigIcon, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemBigIcon, iconWidget, true)
      bHasAddKnownMissing = true
      printf("[PHomeStore-Diag] GetItemBigIcon BigIcon not downloaded, marked KnownMissing itemId:%s bigIcon:%s", tostring(itemId), tostring(itemCfg.ItemBigIcon))
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true, bAutoDownload = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemBigIcon
      }, nil, nil, extraData)
    end
    if bShowBig then
      return itemCfg.ItemBigIcon
    end
  end
  if bShowBig then
    return UIUtil.GetItemSmallIcon2(itemId)
  end
  return UIUtil.GetItemSmallIcon(itemId, iconWidget, bHasAddKnownMissing)
end
function UIUtil.GetItemBigIcon2(itemId, iconWidget, bShowBig)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  local bHasAddKnownMissing = false
  if itemCfg.ItemBigIcon2 and itemCfg.ItemBigIcon2 ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemBigIcon2) then
      return itemCfg.ItemBigIcon2, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemBigIcon2, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemBigIcon2
      }, nil, nil, extraData)
    end
    if bShowBig then
      return itemCfg.ItemBigIcon2, bHasAddKnownMissing
    end
  end
  return UIUtil.GetItemBigIcon(itemId, iconWidget, bShowBig)
end
function UIUtil.GetItemBigIconWithCallBack(itemId, iconWidget, callback)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  local bHasAddKnownMissing = false
  if itemCfg.ItemBigIcon and itemCfg.ItemBigIcon ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemBigIcon) then
      return itemCfg.ItemBigIcon, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemBigIcon, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true, bAutoDownload = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemBigIcon
      }, nil, callback, extraData)
    end
  end
  return UIUtil.GetItemSmallIcon(itemId, iconWidget, bHasAddKnownMissing)
end
function UIUtil.GetItemBigIcon2WithCallBack(itemId, iconWidget, bShowBig, callback)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  local bHasAddKnownMissing = false
  if itemCfg.ItemBigIcon2 and itemCfg.ItemBigIcon2 ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemBigIcon2) then
      return itemCfg.ItemBigIcon2, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemBigIcon2, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemBigIcon2
      }, nil, callback, extraData)
    end
    if bShowBig then
      return itemCfg.ItemBigIcon2, bHasAddKnownMissing
    end
  end
  return UIUtil.GetItemBigIcon(itemId, iconWidget, bShowBig)
end
function UIUtil.CheckSmallIconMissing(iconPath, iconWidget)
  local bHasAddKnownMissing = false
  if iconPath and iconPath ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(iconPath) then
      return bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(iconPath, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {iconPath}, nil, nil, extraData)
    end
  end
  return bHasAddKnownMissing
end
function UIUtil.GetItemSmallIcon(itemId, iconWidget, hasAdd)
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if not itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId), false
  end
  local bHasAddKnownMissing = hasAdd or false
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if musicManager:GetIsBlackRegion() then
    local JpHideSoundIconCfg = CDataTable.GetTableData("JpHideSoundIconCfg", itemId)
    if JpHideSoundIconCfg then
      return JpHideSoundIconCfg.Path128, bHasAddKnownMissing
    end
  end
  if itemCfg.ItemSmallIcon and itemCfg.ItemSmallIcon ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemSmallIcon) then
      return itemCfg.ItemSmallIcon, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemSmallIcon, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemSmallIcon
      }, nil, nil, extraData)
    end
  end
  log(bWriteLog and "UIUtil.GetItemSmallIcon Can't Get SmallIcon " .. itemId)
  return UIUtil.GetDefaultIcon(itemId), bHasAddKnownMissing, true
end
function UIUtil.GetItemSmallIcon2(itemId, iconWidget)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if nil == itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return UIUtil.GetDefaultIcon(itemId)
  end
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  if musicManager:GetIsBlackRegion() then
    local JpHideSoundIconCfg = CDataTable.GetTableData("JpHideSoundIconCfg", itemId)
    if JpHideSoundIconCfg then
      return JpHideSoundIconCfg.Path256
    end
  end
  local bHasAddKnownMissing = false
  if itemCfg.ItemSmallIcon2 and itemCfg.ItemSmallIcon2 ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.ItemSmallIcon2) then
      return itemCfg.ItemSmallIcon2, bHasAddKnownMissing
    end
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.ItemSmallIcon2, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.ItemSmallIcon2
      }, nil, nil, extraData)
    end
  end
  return UIUtil.GetItemSmallIcon(itemId, iconWidget), bHasAddKnownMissing
end
function UIUtil.GetItemSpecialIcon(itemId, iconWidget)
  local itemCfg = UIUtil.GetItemCfg(itemId)
  if not itemCfg then
    log(bWriteLog and "[Warning] Can not find item cfg: " .. tostring(itemId))
    return ""
  end
  local bHasAddKnownMissing = false
  if itemCfg.SpecialIcon and itemCfg.SpecialIcon ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(itemCfg.SpecialIcon) then
      return itemCfg.SpecialIcon, bHasAddKnownMissing
    end
    local PufferSwitch = require("client.slua.logic.download.puffer_switch")
    if slua.isValid(iconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(itemCfg.SpecialIcon, iconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        itemCfg.SpecialIcon
      }, nil, nil, extraData)
    end
  end
  log(bWriteLog and "UIUtil.GetItemSpecialIcon Can't Get SmallIcon" .. itemId)
  return "", bHasAddKnownMissing
end
function UIUtil.GetSignatureIcon(itemId, iconWidget)
  local signEffectCfg = CDataTable.GetTableData("SignEffectCfg", itemId)
  if not signEffectCfg then
    return
  end
  return UIUtil._CheckCommonIcon(signEffectCfg.Icon, iconWidget)
end
function UIUtil.GetSpecialQualityBottomBg(itemID, iconWidget)
  if not itemID then
    return
  end
  local specialBgCfg = CDataTable.GetTableData("ItemSpecialQualityCfg", itemID)
  if not specialBgCfg then
    return
  end
  return UIUtil._CheckCommonIcon(specialBgCfg.StoreButtomBg, iconWidget)
end
function UIUtil.GetSpecialQualityBg(itemID, iconWidget)
  if not itemID then
    return
  end
  local specialBgCfg = CDataTable.GetTableData("ItemSpecialQualityCfg", itemID)
  if not specialBgCfg then
    return
  end
  return UIUtil._CheckCommonIcon(specialBgCfg.BG, iconWidget)
end
function UIUtil.GetSpecialQuality(itemID)
  if not itemID then
    return 0
  end
  local specialBgCfg = CDataTable.GetTableData("ItemSpecialQualityCfg", itemID)
  if not specialBgCfg then
    return 0
  end
  return specialBgCfg.SpecialQuality_f
end
function UIUtil.GetSpecialQualityShareNameBg(itemID, iconWidget)
  if not itemID then
    return
  end
  local specialBgCfg = CDataTable.GetTableData("ItemSpecialQualityCfg", itemID)
  if not specialBgCfg then
    return
  end
  return UIUtil._CheckCommonIcon(specialBgCfg.ShareNameBg, iconWidget)
end
function UIUtil._CheckCommonIcon(Icon, IconWidget)
  local bHasAddKnownMissing = false
  if Icon and Icon ~= "" then
    local pak_util = require("client.common.pak_util")
    if pak_util.IsPufferDownloaded(Icon) then
      return Icon, bHasAddKnownMissing
    end
    if slua.isValid(IconWidget) then
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(Icon, IconWidget, true)
      bHasAddKnownMissing = true
    else
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local extraData = {bFirst = true}
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {Icon}, nil, nil, extraData)
    end
  end
  log(bWriteLog and "UIUtil._CheckCommonIcon Can't Get Icon" .. tostring(Icon))
  return "", bHasAddKnownMissing
end
function UIUtil.GetDefaultIcon(itemID)
  if not itemID then
    return UIUtil.DefaultCommonIcon
  end
  itemID = tonumber(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return UIUtil.DefaultCommonIcon
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(itemCfg.ItemType) then
    local SkinCfg = CDataTable.GetTableData("WeaponSkinMapping", itemID)
    if SkinCfg and itemCfg.ItemSubType == 103 then
      local armoryConfig = CDataTable.GetTableData("ArmoryConfig", SkinCfg.WeaponID)
      if armoryConfig then
        if armoryConfig.WeaponType == 2 then
          return UIUtil.DefaultSingleSniperIcon
        end
        if armoryConfig.WeaponType == 3 then
          return UIUtil.DefaultBurstSniperIcon
        end
      end
    end
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if itemCfg.ItemType == ENUM_ITEM_TYPE.Extra and itemCfg.ItemSubType == 403 and itemCfg.WardrobeTab == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit then
    return UIUtil.DefaultWardrobeSuitIcon
  end
  local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
  if logic_xmission_souvenirs:IsSouvenirsItem(itemID) then
    return logic_xmission_souvenirs:GetSouvenirsDefaultIcon(itemID)
  end
  local defaultIconID = 0
  if itemCfg.ItemSubType > 10000 then
    defaultIconID = itemCfg.ItemType * 10000
  else
    defaultIconID = itemCfg.ItemType * 10000 + itemCfg.ItemSubType
  end
  local cfg = CDataTable.GetTableData("DefaultIconCfg", defaultIconID)
  if cfg then
    return cfg.IconPath
  end
  return UIUtil.DefaultCommonIcon
end
function UIUtil.GetIconCheckDownloaded(iconPath)
  iconPath = iconPath or ""
  if not UIUtil.HasIconDownloaded(iconPath) then
    iconPath = UIUtil.GetDefaultIcon()
  end
  return iconPath
end
function UIUtil.CheckAndUpdateIconScale(itemID, iconPath, icon, IconType)
  if not itemID or not icon then
    return false
  end
  log(bWriteLog and "UIUtil.CheckAndUpdateIconScale itemID: " .. itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg then
    return false
  end
  local StandardIconScale = 1
  local StandardIconAngle = 0
  local Client = import("ScriptHelperClient")
  if slua.isValid(icon) and Client.RemoveKnownMissingPackageRefObjectByObj then
    Client.RemoveKnownMissingPackageRefObjectByObj(icon)
  end
  if iconPath ~= itemCfg.ItemSmallIcon and iconPath ~= itemCfg.ItemSmallIcon2 or iconPath == itemCfg.ItemBigIcon then
    log(bWriteLog and "UIUtil.CheckAndUpdateIconScale iconPath is not ItemSmallIcon or ItemSmallIcon2: " .. iconPath)
    icon:SetRenderAngle(StandardIconAngle)
    icon:SetRenderScale(FVector2D(StandardIconScale, StandardIconScale))
    return false
  end
  local weaponId
  local mapping = CDataTable.GetTableData("WeaponSkinMapping", itemID)
  if mapping and mapping.WeaponID and mapping.WeaponID ~= 0 then
    weaponId = mapping.WeaponID
  else
    local armory = CDataTable.GetTableData("ArmoryConfig", itemID)
    if armory then
      weaponId = itemID
    end
  end
  if weaponId then
    local ScaleTable = CDataTable.GetTableData("WeaponScaleTable", weaponId)
    local angle = -40
    local scale = 1.5
    if ScaleTable then
      angle = tonumber(ScaleTable.Angle)
      scale = IconType == 1 and tonumber(ScaleTable.Scale1) or tonumber(ScaleTable.Scale2)
    end
    icon:SetRenderAngle(angle)
    icon:SetRenderScale(FVector2D(scale, scale))
    log(bWriteLog and "UIUtil.CheckAndUpdateIconScale Scale Weapon Icon By WeaponId: " .. weaponId)
    return true
  end
  return false
end
local EmptyDefaultAssociationTexture = {
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_qiangkou_png.JBK_icon_qiangkou_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_miaoju_png.JBK_icon_miaoju_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_qiangtuo_png.JBK_icon_qiangtuo_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_danjia_png.JBK_icon_danjia_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_woba_png.JBK_icon_woba_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_miaoju_png.JBK_icon_miaoju_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_cedangban_png.JBK_icon_cedangban_png",
  "/Game/UMG/Texture/Atlas/Lobby_JBK/Frames/JBK_icon_qiangtuo_02_png.JBK_icon_qiangtuo_02_png"
}
function UIUtil.GetEmptyDefaultAssociationTexture(index, itemId)
  if index == nil then
    return ""
  end
  if index <= #EmptyDefaultAssociationTexture then
    return EmptyDefaultAssociationTexture[index]
  elseif itemId then
    local tMissionItmCfg = CDataTable.GetTableData("TxMissionItem", itemId)
    if tMissionItmCfg and tMissionItmCfg.TacticalAccessoryIcon then
      return tMissionItmCfg.TacticalAccessoryIcon
    end
  end
  return ""
end
local Parts_default_Name = {
  4510,
  100014,
  4513,
  4511,
  4512,
  100100,
  47431,
  48680,
  60065
}
function UIUtil.GetPartSlotName(index)
  if index == nil then
    return ""
  end
  if index <= #Parts_default_Name then
    return Parts_default_Name[index]
  else
    return ""
  end
end
function UIUtil.OnClickItemShowDetail(widget, itemId, validHours, localPos)
  if UIUtil.GM_ShowDetailItem then
    itemId = UIUtil.GM_ShowDetailItem
  end
  local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  if ItemPreviewSystem.IsNeedShow(itemId) then
    LobbySystem.PlayItemPreviewAnimation(itemId, false, nil, nil, validHours)
  else
    UIUtil.ShowItemTips(itemId, widget, localPos or FVector2D(0, 0), validHours, 0, true)
  end
end
function UIUtil.OnClickItemShowDetailActivity(widget, itemId, validHours, type, config, other)
  if UIUtil.GM_ShowDetailItem then
    itemId = UIUtil.GM_ShowDetailItem
  end
  local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  if ItemPreviewSystem.IsNeedShow(itemId, other) then
    LobbySystem.PlayItemPreviewAnimation(itemId, false, type, config, validHours, other)
  else
    UIUtil.ShowItemTips(itemId, widget, FVector2D(0, 0), validHours, 0, true)
  end
end
function UIUtil.CheckHasIsLand()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  return MatchModeMgrSystem.IsSocialIslandMode(true)
end
function UIUtil.CheckShow18Logo()
  local VNGMenuOpenStatus = LobbySystem.CheckOpen(BP_ENUM_VNG_OPENMARK_Lobby)
  local showLogo = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not GlobalData.IsIOSCheck() and Client.GetPublishRegion() == PublishRegionMacros.VNG then
    showLogo = VNGMenuOpenStatus
  end
  return showLogo
end
function UIUtil.CheckShow18LogoBattle()
  local VNGMenuOpenStatus = LobbySystem.CheckOpen(BP_ENUM_VNG_OPENMARK)
  local showLogo = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not GlobalData.IsIOSCheck() and Client.GetPublishRegion() == PublishRegionMacros.VNG then
    showLogo = VNGMenuOpenStatus
  end
  return showLogo
end
function UIUtil.ltrim(input)
  return string_gsub(input, "^[ \t\n\r]+", "")
end
function UIUtil.rtrim(input)
  return string_gsub(input, "[ \t\n\r]+$", "")
end
function UIUtil.IsValid(uObject)
  return slua_isValid(uObject)
end
function UIUtil.ProjectWorldToScreen(WorldPos)
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if not slua.isValid(PlayerController) then
    LogExceptionAndReport("UIUtil.ProjectWorldToScreen PlayerController is nil", 6)
    return FVector2D(0, 0)
  end
  local temp = FVector2D(0, 0)
  local bResult, ScreenPosition = UGameplayStatics.ProjectWorldToScreen(PlayerController, WorldPos, temp, false)
  if bResult then
    return ScreenPosition
  end
  return FVector2D(0, 0)
end
function UIUtil.DeprojectScreenToWorld(ScreenPos)
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if not slua.isValid(PlayerController) then
    log_error("PlayerController is nil")
    return false
  end
  local temp = FVector(0, 0, 0)
  local tempDir = FVector(0, 0, 0)
  local bResult, WorldPosition, WorldDirection = UGameplayStatics.DeprojectScreenToWorld(PlayerController, ScreenPos, temp, tempDir)
  if bResult then
    return WorldPosition, WorldDirection
  end
  return temp, tempDir
end
function UIUtil.DeprojectScreenToWorldFast(ScreenPos)
  local WorldContextObject = UIUtil.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if not slua.isValid(PlayerController) then
    log_error("PlayerController is nil")
    return false
  end
  local temp = FVector(0, 0, 0)
  local tempDir = FVector(0, 0, 0)
  local LobbyModelUtils = import("LobbyModelUtils")
  local bResult, WorldPosition, WorldDirection = LobbyModelUtils.DeprojectScreenToWorldFast(PlayerController, ScreenPos, temp, tempDir)
  if bResult then
    return WorldPosition, WorldDirection
  end
  return temp, tempDir
end
function UIUtil.GetMousePositionOnViewport()
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local LocationX, LocationY, isCurrentlyPressed = 0, 0, false
  if slua.isValid(playerController) then
    LocationX, LocationY, isCurrentlyPressed = playerController:GetInputTouchState(0, nil, nil, nil)
  end
  log_tree("GetMousePositionOnViewport", {
    LocationX,
    LocationY,
    isCurrentlyPressed
  })
  return LocationX, LocationY
end
function UIUtil.IsTargetValid(targetWidget)
  if targetWidget == nil or not slua.isValid(targetWidget) then
    return
  end
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local widgetPos = UIUtil.GetWidgetViewportPos(targetWidget, 0, 0)
  log(bWriteLog and "SetGuideByWidget widgetPos.X = " .. widgetPos.X .. ", widgetPos.Y = " .. widgetPos.Y)
  local geometry = targetWidget:GetCachedGeometry()
  local AbsoluteSize = SlateBlueprintLibrary.GetAbsoluteSize(geometry)
  log(bWriteLog and "SetGuideByWidget AbsoluteSize.X = " .. AbsoluteSize.X .. ", AbsoluteSize.Y = " .. AbsoluteSize.Y)
  local bValid = widgetPos.X < 1.0E-5 and widgetPos.Y < 1.0E-5 and AbsoluteSize.X < 1.0E-5 and AbsoluteSize.Y < 1.0E-5
  bValid = not bValid
  return bValid
end
function UIUtil.SetGuideByWidget(guideWidget, targetWidget, sizeOffset, posOffset)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local widgetPos = UIUtil.GetWidgetViewportPos(targetWidget, 0, 0)
  log(bWriteLog and "SetGuideByWidget widgetPos.X = " .. widgetPos.X .. ", widgetPos.Y = " .. widgetPos.Y)
  local geometry = targetWidget:GetCachedGeometry()
  local AbsoluteSize = SlateBlueprintLibrary.GetAbsoluteSize(geometry)
  log(bWriteLog and "SetGuideByWidget AbsoluteSize.X = " .. AbsoluteSize.X .. ", AbsoluteSize.Y = " .. AbsoluteSize.Y)
  local bValid = widgetPos.X < 1.0E-5 and widgetPos.Y < 1.0E-5 and AbsoluteSize.X < 1.0E-5 and AbsoluteSize.Y < 1.0E-5
  bValid = not bValid
  local scale = UIUtil.GetViewportScale()
  log(bWriteLog and "SetGuideByWidget scale = " .. scale)
  local viewportSize = UIUtil.GetViewportSize()
  log(bWriteLog and "SetGuideByWidget viewportSize.X = " .. viewportSize.X .. ", viewportSize.Y = " .. viewportSize.Y)
  sizeOffset = sizeOffset or FVector2D(0, 0)
  if posOffset then
    widgetPos.X = widgetPos.X + posOffset.X
    widgetPos.Y = widgetPos.Y + posOffset.Y
  end
  local fix = 0
  local offsetLeft = widgetPos.X + fix
  local offsetTop = widgetPos.Y + fix
  local offsetRight = (viewportSize.X - widgetPos.X * scale - AbsoluteSize.X) / scale + fix - sizeOffset.X
  local offsetBottom = (viewportSize.Y - widgetPos.Y * scale - AbsoluteSize.Y) / scale + fix - sizeOffset.Y
  log(bWriteLog and "SetGuideByWidget offsetLeft = " .. offsetLeft)
  log(bWriteLog and "SetGuideByWidget offsetTop = " .. offsetTop)
  log(bWriteLog and "SetGuideByWidget offsetRight = " .. offsetRight)
  log(bWriteLog and "SetGuideByWidget offsetBottom = " .. offsetBottom)
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(guideWidget)
  if slot then
    slot:SetOffsets(FMargin(offsetLeft, offsetTop, offsetRight, offsetBottom))
  end
  return bValid, offsetLeft, offsetTop, offsetRight, offsetBottom, AbsoluteSize.X / scale, AbsoluteSize.Y / scale
end
function UIUtil.SetNationFlag(icon, country, isGlobal)
  if isGlobal then
    local util = require("client.slua_ui_framework.util")
    local path = "/Game/Arts/UI/TableIcons/Title_Icon/Title_icon_quanqiu.Title_icon_quanqiu"
    util.SetTexture(icon, path, {sync = false})
  elseif country then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE and country == "IN" then
      local util = require("client.slua_ui_framework.util")
      local path = "/Game/UMG/Texture/Atlas/NationalflagUI/Frames/T_icon_flag_India_png"
      util.SetTexture(icon, path, {sync = false})
    else
      UIUtil.UpdateNationImage(icon, country)
    end
  end
end
function UIUtil.SetTitleItem(TitleItem_Get_UIBP, aliasData)
  if not TitleItem_Get_UIBP or not aliasData then
    return
  end
  local util = require("client.slua_ui_framework.util")
  local UIUtil = require("client.common.ui_util")
  local DefaultIcon = UIUtil.GetDefaultIcon(aliasData.aliasId)
  util.SetTexture(TitleItem_Get_UIBP.current_iconBG, aliasData.aliasIconUrlBig, {sync = false, defaultIcon = DefaultIcon})
  local rank_id = aliasData.rank_id
  if rank_id and 0 < rank_id then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    local bGlobal = rank_id and rank_id == 100001
    local country = LbsMgr.GetZoneDataByID(rank_id).country
    if bGlobal then
      TitleItem_Get_UIBP.nation_bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      TitleItem_Get_UIBP.current_icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      TitleItem_Get_UIBP.Image_lbs:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIUtil.SetNationFlag(TitleItem_Get_UIBP.Image_lbs, country, bGlobal)
    else
      TitleItem_Get_UIBP.Image_lbs:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      TitleItem_Get_UIBP.current_icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      TitleItem_Get_UIBP.nation_bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      UIUtil.SetNationFlag(TitleItem_Get_UIBP.nation_bg, country, bGlobal)
    end
  elseif aliasData.aliasNation and aliasData.aliasNation ~= "" then
    TitleItem_Get_UIBP.Image_lbs:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    TitleItem_Get_UIBP.current_icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    TitleItem_Get_UIBP.nation_bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIUtil.UpdateNationImage(TitleItem_Get_UIBP.nation_bg, aliasData.aliasNation)
  else
    TitleItem_Get_UIBP.Image_lbs:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    TitleItem_Get_UIBP.nation_bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    TitleItem_Get_UIBP.current_icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    util.SetTexture(TitleItem_Get_UIBP.current_icon, aliasData.aliasIconUrl, {sync = false, defaultIcon = DefaultIcon})
  end
  TitleItem_Get_UIBP.title:SetAliasInfo(aliasData.aliasId or 0, aliasData.aliasTitle or "", aliasData.aliasNation or "", 0, aliasData.rank_id or 0)
end
function UIUtil.SetItemCoBrandedVisibility(itemID, widget)
  if widget and widget.Switcher_Joint and widget.Switcher_Joint.SetWidgetVisibility then
    widget.Switcher_Joint:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemID == nil then
    return
  end
  local itemCoBrandedData = CDataTable.GetTableData("ItemCoBrandedConfig", itemID)
  if itemCoBrandedData == nil then
    return
  end
  local coWidget
  if widget and widget.Switcher_Joint then
    coWidget = widget.Switcher_Joint
  end
  if coWidget then
    if coWidget.SetWidgetVisibility then
      coWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    if coWidget.SetActiveWidgetIndex then
      local coType = itemCoBrandedData.coType
      if coType then
        coWidget:SetActiveWidgetIndex(coType - 1)
      end
    end
  end
end
function UIUtil.IsLocalpositionInBorder(Location, Border)
  if not slua_isValid(Border) then
    return false
  end
  local BorderGeometry = Border:GetCachedGeometry()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  return SlateBlueprintLibrary.IsUnderLocation(BorderGeometry, Location)
end
function UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  assert(inAnimationName ~= nil and inAnimationName ~= "", "ConvertToAnimationNameWithLOD inAnimationName ~= nil and inAnimationName ~= ")
  if not slua_isValid(Widget) or not inAnimationName then
    log(bWriteLog and "UIUtil.ConvertToAnimationNameWithLOD  is not valid")
    return ""
  end
  local gameInstance = UIUtil.GetGameInstance()
  local deviceLevel = gameInstance:GetDeviceLevel()
  deviceLevel = FuncUtil.Clamp(deviceLevel, 0, 2)
  local animationLOD1 = Widget[inAnimationName .. "_LOD1"]
  local animationLOD2 = Widget[inAnimationName .. "_LOD2"]
  if deviceLevel == 1 then
    if animationLOD1 then
      return inAnimationName .. "_LOD1", 1
    end
  elseif deviceLevel == 0 then
    if animationLOD2 then
      return inAnimationName .. "_LOD2", 2
    elseif animationLOD1 then
      return inAnimationName .. "_LOD1", 1
    end
  end
  local animationLOD0WithoutSuffix = Widget[inAnimationName]
  local animationLOD0 = Widget[inAnimationName .. "_LOD0"]
  return animationLOD0WithoutSuffix and inAnimationName or animationLOD0 and inAnimationName .. "_LOD0", 0
end
function UIUtil.IsExistBlueprintPath(inBlueprintName)
  if not inBlueprintName or string.len(inBlueprintName) <= 0 then
    return false
  end
  local pak_util = require("client.common.pak_util")
  return pak_util.IsFileExist(inBlueprintName)
end
function UIUtil.ConvertToBlueprintNameWithLOD(inBlueprintName)
  local gameInstance = UIUtil.GetGameInstance()
  local deviceLevel = gameInstance:GetDeviceLevel()
  deviceLevel = FuncUtil.Clamp(deviceLevel, 0, 2)
  if gameInstance:IsIOSSpecialLowDevice() then
    deviceLevel = 0
  end
  if inBlueprintName == nil or inBlueprintName == "" then
    log_warning("ConvertToBlueprintNameWithLOD inBlueprintName ~= nil and inBlueprintName ~= ")
    return nil, deviceLevel
  end
  local arrName = StringUtil.Split(inBlueprintName, ".")
  if not arrName or not arrName[2] then
    log_warning(string_format("ConvertToBlueprintNameWithLOD inBlueprintName [%s] return ", inBlueprintName))
    return inBlueprintName, deviceLevel
  end
  local listLOD = {}
  listLOD[2] = string.sub(inBlueprintName, 0, string.len(arrName[1])) .. "_LOD0." .. arrName[2] .. "_LOD0"
  listLOD[1] = string.sub(inBlueprintName, 0, string.len(arrName[1])) .. "_LOD1." .. arrName[2] .. "_LOD1"
  listLOD[0] = string.sub(inBlueprintName, 0, string.len(arrName[1])) .. "_LOD2." .. arrName[2] .. "_LOD2"
  local bExist = UIUtil.IsExistBlueprintPath(listLOD[deviceLevel])
  if bExist then
    return listLOD[deviceLevel], deviceLevel
  end
  if deviceLevel == 0 and UIUtil.IsExistBlueprintPath(listLOD[1]) then
    return listLOD[1], deviceLevel
  end
  return inBlueprintName, deviceLevel
end
function UIUtil.PlayWidgetAnimation(Widget, inAnimationName, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  if not slua_isValid(Widget) then
    log(bWriteLog and "UIUtil.PlayWidgetAnimation Widget is not valid")
    return -1
  end
  local animationLODName, LOD = UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  if not animationLODName then
    return -1
  end
  Widget:PlayUserWidgetAnimation(Widget[animationLODName], startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  return LOD
end
function UIUtil.IsWidgetAnimationPlaying(Widget, inAnimationName)
  if not slua_isValid(Widget) then
    log(bWriteLog and "UIUtil.IsWidgetAnimationPlaying Widget is not valid")
    return false
  end
  local animationLODName, LOD = UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  if not animationLODName then
    return false
  end
  return Widget:IsAnimationPlaying(Widget[animationLODName])
end
function UIUtil.StopWidgetAnimation(Widget, inAnimationName)
  if not slua_isValid(Widget) then
    log(bWriteLog and "UIUtil.StopWidgetAnimation Widget is not valid")
    return -1
  end
  local animationLODName, LOD = UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  if not animationLODName then
    return -1
  end
  Widget:StopAnimation(Widget[animationLODName])
  return LOD
end
function UIUtil.PlayWidgetAnimationTo(Widget, inAnimationName, startAtTime, EndAtTime, numLoopsToPlay, PlayMode, PlaybackSpeed)
  if not slua_isValid(Widget) then
    log(bWriteLog and "UIUtil.PlayWidgetAnimation Widget is not valid")
    return -1
  end
  local animationLODName, LOD = UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  if not animationLODName then
    return -1
  end
  Widget:PlayAnimationTo(Widget[animationLODName], startAtTime, EndAtTime, numLoopsToPlay, PlayMode, PlaybackSpeed)
  return LOD
end
function UIUtil.GetAnimationDuration(Widget, inAnimationName)
  if not slua_isValid(Widget) then
    log(bWriteLog and "UIUtil.GetAnimationDuration Widget is not valid")
    return nil
  end
  local animationLODName, LOD = UIUtil.ConvertToAnimationNameWithLOD(Widget, inAnimationName)
  if not animationLODName then
    return nil
  end
  local animation = Widget[animationLODName]
  return animation:GetEndTime() - animation:GetStartTime()
end
function UIUtil.IsLocalpositionInBorder(Location, Border)
  if not slua_isValid(Border) then
    return false
  end
  local BorderGeometry = Border:GetCachedGeometry()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  return SlateBlueprintLibrary.IsUnderLocation(BorderGeometry, Location)
end
function UIUtil.onBtnClickInCd()
  ShowNotice(7108)
end
function UIUtil.ShowSweepstakesReminder(widget)
  if not slua_isValid(widget) then
    return
  end
  if GlobalData.IsJapanOrKorea() then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget:SetText(LocUtil.GetLocalizeResStr(49683))
end
function UIUtil.GetAliasBkIconByQuality(aliasQuality)
  if not aliasQuality or type(aliasQuality) ~= "number" then
    return
  end
  if aliasQuality == 0 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao4_png.LOBBY_image_chenghao4_png"
  elseif aliasQuality == 1 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao3_png.LOBBY_image_chenghao3_png"
  elseif aliasQuality == 2 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao_png.LOBBY_image_chenghao_png"
  elseif aliasQuality == 3 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao1_png.LOBBY_image_chenghao1_png"
  elseif aliasQuality == 4 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao2_png.LOBBY_image_chenghao2_png"
  elseif aliasQuality == 5 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_zuigaoji_png.LOBBY_image_zuigaoji_png"
  elseif aliasQuality == 6 then
    return "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/LOBBY_image_chenghao6_png.LOBBY_image_chenghao6_png"
  end
end
function UIUtil.ShiftChild(ParentWidget, Child, NewIndex, CurrentIndex)
  if CurrentIndex then
    ParentWidget:RemoveChildAt(CurrentIndex)
  else
    ParentWidget:RemoveChild(Child)
  end
  ParentWidget:AddChildAt(NewIndex, Child, ParentWidget.Slots:Num())
end
function UIUtil.SetRelationColor(relation)
  log_warning(bWriteLog and "  :SetRelationColor relation: " .. tostring(relation))
  local   local   local color01 = FSlateColor(FLinearColor(0.068, 0.205, 0.651, 1))
  local colorTb = {
    color01,
    FSlateColor(FLinearColor(1, 0.25, 0.584, 1)),
    FSlateColor(FLinearColor(0.814, 0.152, 0.038, 1)),
    FSlateColor(FLinearColor(0.783, 0.004, 0.262, 1)),
    FSlateColor(FLinearColor(0.894118, 0.262745, 0.145098, 1)),
    FSlateColor(FLinearColor(0.83077, 0.238398, 0.337164, 1))
  }
  return relation and colorTb[relation] or color01
end
function UIUtil.MakeWidgetScreenshot(path, widget, scale, size)
  if not slua.isValid(widget) then
    log(bWriteLog and "UIUtil.MakeWidgetScreenshot widget is nil")
    return false
  end
  if not path or path == "" then
    log(bWriteLog and "UIUtil.MakeWidgetScreenshot path is nil")
    return false
  end
  size = size or widget:GetDesiredSize()
  scale = scale or 1
  size.X = size.X * scale
  size.Y = size.Y * scale
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local platformName = Client.GetDevicePlatformName()
  if platformName == DevicePlatformNameMacros.IOS then
    local iOSMaxTexSize = 4096
    local maxSize = math.max(size.X, size.Y)
    if iOSMaxTexSize < maxSize then
      scale = scale * iOSMaxTexSize / maxSize
      size.X = size.X * iOSMaxTexSize / maxSize
      size.Y = size.Y * iOSMaxTexSize / maxSize
    end
  end
  local ScreenshotMaker = import("ScreenshotMaker")
  local rt = ScreenshotMaker.MakeWidgetScreenshot(widget, size, scale or 1)
  if rt == nil then
    log(bWriteLog and "UIUtil.MakeWidgetScreenshot rt is nil")
    return false
  end
  local USTExtraUIUtils = import("STExtraUIUtils")
  local flipVertical = platformName == DevicePlatformNameMacros.Android
  USTExtraUIUtils.SaveRT_FileHelper(rt, path, FLinearColor(0, 0, 0, 0), false, false, flipVertical)
  if slua.isValid(rt) then
    rt:ConditionalBeginDestroy()
  end
  return true
end
function UIUtil.GetNumberWithCommas(n)
  local str = tostring(n)
  local result = ""
  local len = string.len(str)
  local count = 0
  for i = len, 1, -1 do
    count = count + 1
    result = string.sub(str, i, i) .. result
    if count % 3 == 0 and i ~= 1 then
      result = "," .. result
    end
  end
  return result
end
function UIUtil.MergeItemList(ItemList)
  local MergedItemMap = {}
  for _, ItemInfo in ipairs(ItemList) do
    local Key = ItemInfo.res_id .. "_" .. (ItemInfo.valid_hours or 0)
    if MergedItemMap[Key] then
      MergedItemMap[Key].count = MergedItemMap[Key].count + ItemInfo.count
    else
      MergedItemMap[Key] = {
        res_id = ItemInfo.res_id,
        count = ItemInfo.count,
        valid_hours = ItemInfo.valid_hours,
        awardstate = ItemInfo.awardstate or -1
      }
    end
  end
  local MergedItemList = {}
  for _, ItemInfo in pairs(MergedItemMap) do
    table.insert(MergedItemList, ItemInfo)
  end
  if 0 < #MergedItemList then
    return MergedItemList
  else
    return ItemList
  end
end
function UIUtil.IsCountDown(time, nDays)
  local TimeUtil = require("client.common.time_util")
  return time - TimeUtil.GetServerTimeInSec() <= nDays * 86400
end
function UIUtil.GetCountDownStr(time)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatCountDownTime_D_or_HMS(time - TimeUtil.GetServerTimeInSec(), 1)
end
function UIUtil.ChangeUCPriceColor(widget, price, bWhiteNormal)
  if not (price and type(price) == "number" and widget) or not widget.SetColorAndOpacity then
    return
  end
  local color
  if price > DataMgr.ticket then
    color = FSlateColor(FLinearColor(1, 0, 0, 1))
  elseif bWhiteNormal then
    color = FSlateColor(FLinearColor(1, 1, 1, 1))
  else
    color = FSlateColor(FLinearColor(0, 0, 0, 1))
  end
  widget:SetColorAndOpacity(color)
end
function UIUtil.IsEncryptionItem(itemId)
  log(bWriteLog and string.format("UIUtil.IsEncryptionItem. itemId=%s", tostring(itemId)))
  if not itemId or itemId == 0 then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", itemId)
  if not itemCfg then
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local pakName = PufferManager.GetPakName(itemCfg.ItemSmallIcon)
  if pakName == PufferConst.LOCK_PAKNAME or pakName == PufferConst.CE_LOCK_PAKNAME then
    log(bWriteLog and "UIUtil.IsEncryptionItem. Is Encryption Item !")
    return true
  end
  log(bWriteLog and "UIUtil.IsEncryptionItem. Isn't Encryption Item !")
  return false
end
function UIUtil.ShowLogByOtherName(otherName, logStr, logLevel)
  if not bWriteLog then
    return
  end
  if not otherName then
    return
  end
  logStr = logStr or ""
  local logFunc
  if logLevel ~= nil then
    if logLevel == UEnums.LogLevel.LOG then
      logFunc = log
    elseif logLevel == UEnums.LogLevel.WARN then
      logFunc = log_warning
    elseif logLevel == UEnums.LogLevel.ERROR then
      logFunc = log_error
    end
  end
  logFunc = logFunc or log
  logFunc(otherName .. ":" .. logStr)
end
function UIUtil.IsRTL()
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local language = Client.GetCurrentLanguage()
  return language == LanguageMacros.AR or language == LanguageMacros.UR
end
function UIUtil.PreLoadBp(path, pool, onLoaded)
  if not path or path == "" then
    if onLoaded then
      onLoaded()
    end
    return
  end
  pool = pool or ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
  pool:GetAsy(path, function(obj)
    pool:Release(obj)
    if onLoaded then
      onLoaded()
    end
  end)
end
function UIUtil.SetVietnamAutoCapitalizeText(widget)
  local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
  local language = Client.GetCurrentLanguage()
  log(bWriteLog and "UIUtil.SetVietnamAutoCapitalizeText language: " .. tostring(language) .. " widget: " .. tostring(widget) .. " widget.AutoCapitalizeText: " .. tostring(widget and widget.AutoCapitalizeText))
  if language == LanguageMacros.VI then
    widget.AutoCapitalizeText = false
  end
  local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  if UCreativeModeBlueprintLibrary.SynchronizePropertiesWidget then
    UCreativeModeBlueprintLibrary.SynchronizePropertiesWidget(widget)
  end
end
return UIUtil
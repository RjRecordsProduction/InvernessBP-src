local ECardCollectionPopupType = {
  Drift = 1,
  GivingGifts = 2,
  Dismantle = 3,
  SwapHistory = 4,
  SwapReq = 5,
  SwapRsp = 6,
  SwapSelectOwn = 7,
  SwapSelectWant = 8,
  Guide = 9,
  Completion = 10,
  SwapInfo = 11,
  SpecialCard = 12,
  Removal = 13,
  AdditionalAwardDesc = 14,
  GetDrift = 15,
  PackPreview = 16,
  Level = 17,
  Score = 18,
  Obtain = 19,
  SpecialBuffCard = 20,
  DailyTask = 21,
  DriftAddFriend = 22,
  DirectExchange = 23,
  CardPreview = 24,
  MutualAid = 25,
  NarutoGet = 26
}
local ENewGuideStep = {
  Popup = 1,
  FirstYear = 2,
  UpgradeCard_Year = 3,
  CollectLevel = 4,
  UpgradeCard_Collect = 5
}
local ECardCollectionPanelType = {
  Main = 1,
  Set = 2,
  History = 3,
  Share = 5,
  Detail = 6,
  Start = 7,
  Album = 8,
  SwapShare = 9,
  CardDetail = 10,
  RareCardShare = 11
}
local ECardFromType = {
  FriendSwap = 1,
  OutSide = 2,
  Drift = 3,
  FriendGift = 4,
  NewVersion = 5
}
local CardFromLocIDMap = {
  [ECardFromType.FriendSwap] = 33020232,
  [ECardFromType.Drift] = 33020234,
  [ECardFromType.FriendGift] = 33020235,
  [ECardFromType.NewVersion] = 81530
}
local ui_config = UIManager.UI_Config
local PopupConfig = {
  [ECardCollectionPopupType.Drift] = ui_config.CardCollection_Drift_Popup_UIBP,
  [ECardCollectionPopupType.SwapHistory] = ui_config.CardCollection_SwapHistory_Popup_UIBP,
  [ECardCollectionPopupType.GivingGifts] = ui_config.CardCollection_GivingGifts_Popup_UIBP,
  [ECardCollectionPopupType.Dismantle] = ui_config.CardCollection_Dismantle_Popup_UIBP,
  [ECardCollectionPopupType.SwapReq] = ui_config.CardCollection_Swap_Req_Popup_UIBP,
  [ECardCollectionPopupType.SwapRsp] = ui_config.CardCollection_Swap_Rsp_Popup_UIBP,
  [ECardCollectionPopupType.SwapSelectOwn] = ui_config.CardCollection_Swap_Select_Own_Popup_UIBP,
  [ECardCollectionPopupType.SwapSelectWant] = ui_config.CardCollection_Swap_Select_Want_Popup_UIBP,
  [ECardCollectionPopupType.Guide] = ui_config.CardCollection_DailyTask_Guide_UIBP,
  [ECardCollectionPopupType.Completion] = ui_config.CardCollection_Completion_UIBP,
  [ECardCollectionPopupType.SwapInfo] = ui_config.CardCollection_Swap_Info_Popup_UIBP,
  [ECardCollectionPopupType.SpecialCard] = ui_config.CardCollection_SpecialCard_Popup_UIBP,
  [ECardCollectionPopupType.Removal] = ui_config.CardCollection_Removal_UIBP,
  [ECardCollectionPopupType.AdditionalAwardDesc] = ui_config.CardCollection_Additonal_Award_Desc_Popup_UIBP,
  [ECardCollectionPopupType.GetDrift] = ui_config.CardCollection_DirftCard_UIBP,
  [ECardCollectionPopupType.DriftAddFriend] = ui_config.CardCollection_Drift_Add_Friend_UIBP,
  [ECardCollectionPopupType.PackPreview] = ui_config.CardCollection_Preview_Popup_UIBP,
  [ECardCollectionPopupType.Level] = ui_config.CardCollection_Level_Popup,
  [ECardCollectionPopupType.Score] = ui_config.CardCollection_Score_Popup,
  [ECardCollectionPopupType.Obtain] = ui_config.CardCollection_Obtain_Way_Popup_UIBP,
  [ECardCollectionPopupType.SpecialBuffCard] = ui_config.CardCollection_SpecialBuffCard_Popup_UIBP,
  [ECardCollectionPopupType.DailyTask] = ui_config.CardCollection_DailyTask_Popup_UIBP,
  [ECardCollectionPopupType.DirectExchange] = ui_config.CardCollection_DirectExchange_Panel_UIBP,
  [ECardCollectionPopupType.CardPreview] = ui_config.CardCollection_Card_Preview_Popup_UIBP,
  [ECardCollectionPopupType.MutualAid] = ui_config.CardCollection_MutualAid_Popup_UIBP,
  [ECardCollectionPopupType.NarutoGet] = ui_config.CardCollection_NarutoGet_Popup_UIBP
}
local PanelConfig = {
  [ECardCollectionPanelType.Main] = ui_config.CardCollection_Main_UIBP,
  [ECardCollectionPanelType.Set] = ui_config.CardCollection_Set_UIBP,
  [ECardCollectionPanelType.History] = ui_config.CardCollection_History_UIBP,
  [ECardCollectionPanelType.Share] = ui_config.CardCollection_Share_UIBP,
  [ECardCollectionPanelType.Detail] = ui_config.CardCollection_Detail_UIBP,
  [ECardCollectionPanelType.Start] = ui_config.CardCollection_Start_Reward_UIBP,
  [ECardCollectionPanelType.Album] = ui_config.CardCollection_Album_UIBP,
  [ECardCollectionPanelType.SwapShare] = ui_config.CardCollection_SwapShare_UIBP,
  [ECardCollectionPanelType.CardDetail] = ui_config.CardCollection_Card_Detail_UIBP,
  [ECardCollectionPanelType.RareCardShare] = ui_config.CardCollection_Rare_Card_Share_UIBP
}
local ECardPackRarity = {
  Normal = 1,
  Rare = 2,
  Legendary = 3
}
local EShareType = {
  Card = 1,
  SetCompletion = 2,
  SeasonCompletion = 3
}
local EObtainTabType = {
  Task = 1,
  Pack = 2,
  Desc = 3
}
local GuideData = {
  data = {
    {
      title = LocUtil.GetLocalizeResStr(33020213),
      desc = LocUtil.GetLocalizeResStr(33020214),
      ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/ReturnActivity_OldFriend_01.ReturnActivity_OldFriend_01"
    },
    {
      title = LocUtil.GetLocalizeResStr(33020215),
      desc = LocUtil.GetLocalizeResStr(33020216),
      ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/ReturnActivity_OldFriend_02.ReturnActivity_OldFriend_02"
    },
    {
      title = LocUtil.GetLocalizeResStr(33020304),
      desc = LocUtil.GetLocalizeResStr(33020305),
      ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/ReturnActivity_OldFriend_03.ReturnActivity_OldFriend_03"
    },
    {
      title = LocUtil.GetLocalizeResStr(33020306),
      desc = LocUtil.GetLocalizeResStr(33020307),
      ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/ReturnActivity_OldFriend_04.ReturnActivity_OldFriend_04"
    }
  },
  title = LocUtil.GetLocalizeResStr(33020165)
}
local CardCollectionSeasonUIConfig = {
  PopupConfig = PopupConfig,
  PanelConfig = PanelConfig,
  CardFromLocIDMap = CardFromLocIDMap,
  ECardCollectionPopupType = ECardCollectionPopupType,
  ECardCollectionPanelType = ECardCollectionPanelType,
  ECardPackRarity = ECardPackRarity,
  EShareType = EShareType,
  EObtainTabType = EObtainTabType,
  ENewGuideStep = ENewGuideStep,
  ECardFromType = ECardFromType,
  GuideData = GuideData,
  ModAssetPath = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Main_UIBP.CardCollection_Main_UIBP"
}
function CardCollectionSeasonUIConfig.GetGuideData()
  return {
    data = {
      {
        title = LocUtil.GetLocalizeResStr(33020213),
        desc = LocUtil.GetLocalizeResStr(33020214),
        ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/CardCollection_Pass_01.CardCollection_Pass_01"
      },
      {
        title = LocUtil.GetLocalizeResStr(33020215),
        desc = LocUtil.GetLocalizeResStr(33020216),
        ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/CardCollection_Pass_02.CardCollection_Pass_02"
      },
      {
        title = LocUtil.GetLocalizeResStr(33020087),
        desc = LocUtil.GetLocalizeResStr(33020088),
        ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/CardCollection_Pass_03.CardCollection_Pass_03"
      },
      {
        title = LocUtil.GetLocalizeResStr(33020089),
        desc = LocUtil.GetLocalizeResStr(33020090),
        ImagePath = "/Game/Mod/Lobby/Split/CardCollection/NoAltas/CardCollection_Pass_04.CardCollection_Pass_04"
      }
    },
    title = LocUtil.GetLocalizeResStr(33020165)
  }
end
return CardCollectionSeasonUIConfig
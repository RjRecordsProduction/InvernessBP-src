local OneClickReward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
local TipsMacro = require("client.slua.logic.tip.TipsMacro")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local MiniTVConst = require("client.lobby_ue_object.Actor.MiniTV.MiniTVConst")
local SAUtils = require("client.slua.logic.sa.SAUtils")
local local local nowTipsIndex = 0
local AllActivityData = {}
local tipsMoveTypes = {
  MID = 0,
  LEFT = 1,
  RIGHT = 2
}
local UIType = {
  HaveAwardTips = 0,
  WaitAwardTips = 3,
  WatchAwardTips = 1,
  NormalWordTips = 2
}
local MiniTVActor
local HasRegistEvent = false
local BNeedShowWin
local NCurPage = ENUM_LobbyPageType.Mid
local DownloadAct
local ActorData = {
  NLocationX = MiniTVConst.INIT_LOCATION_X,
  NLocationY = MiniTVConst.INIT_LOCATION_Y,
  NLocationZ = MiniTVConst.INIT_LOCATION_Z,
  NDistance = 0,
  OverlapTag = nil
}
local IgnoreUIConfigList = {
  UIManager.UI_Config.connect_wait,
  UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP
}
local ShowUIConfigList = {
  UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP,
  UIManager.UI_Config.Assembly_Main_UIBP
}
local IgnoreUIConfigMap, UIShowMap, SCurVersion
local MiniTvSystem = {}
MiniTvSystem.local IsReadNewerConfig = false
local _alreadyDownload = false
local proxy = require("client.slua.logic.sa.SmartAssistantProxy")
function MiniTvSystem.Init()
  log(bWriteLog and "mini_logic: MiniTvSystem.Init")
  EventSystem:registEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA, MiniTvSystem.WhenWin)
  EventSystem:registEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_TV_GETREWARDFINISH, MiniTvSystem.OnFinishGetReward)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SMART_ASSISTANT_MAIN, MiniTvSystem.OnJumpUrl)
  local version_util = require("client.common.version_util")
  SCurVersion = version_util.GetClientFormat(Client.GetAppVersion())
  log(bWriteLog and "mini_logic: SCurVersion" .. tostring(SCurVersion))
  MiniTvSystem.InitDownLoadCloth()
  OneClickReward.Init()
end
function MiniTvSystem.InitDownLoadCloth()
  local itemId = DataMgr.minitv_dressid
  if itemId == nil then
    return
  end
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  _alreadyDownload = dowloadState == ENUM_DownloadState.Done
  if not _alreadyDownload then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  end
end
function MiniTvSystem.OnDownloadFinish(param1, param2, eventData)
  local itemID = eventData.itemID
  if not itemID then
    return
  end
  if itemID == DataMgr.minitv_dressid then
    log(bWriteLog and "[zxq] MiniTvSystem:OnDownloadFinish Download ID:" .. tostring(itemID))
    MiniTvSystem.PutOnClothe()
  end
end
function MiniTvSystem.OnFinishGetReward(_, _, rewardslist, failReason)
  log_tree("zxq OnFinishGetReward rewardslist", rewardslist)
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant:OnOneClickRewardReceiveComplete()
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    printf("MiniTvSystem.OnFinishGetReward CloseMiniTVBubbleUI")
    SAUtils.CloseMiniTVBubbleUI()
  end
  if rewardslist and next(rewardslist) then
    if failReason ~= nil then
      MiniTvSystem.AddMailFailReason(rewardslist, failReason)
    end
    UIManager.ShowUI(UIManager.UI_Config.RewardGet_UIBP, rewardslist)
  else
    local ShowWord
    if failReason == "full" then
      ShowWord = LocUtil.GetLocalizeResStr(32421)
    elseif failReason == "special" then
      ShowWord = LocUtil.GetLocalizeResStr(32422)
    else
      log_error("zxq OnFinishGetReward rewardslist failReason" .. tostring(failReason))
      return
    end
    if MiniTvSystem.CanShowTip() then
      MiniTvSystem.ShowUI(UIType.NormalWordTips, {word = ShowWord})
    end
  end
end
function MiniTvSystem.AddMailFailReason(rewardlist, failReason)
  local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
  for index, System in pairs(rewardlist) do
    if System.systemId == OneClickMacro.RewardSystemName.mail then
      return
    end
  end
  if failReason == "full" then
    ShowNotice(32421)
  elseif failReason == "special" then
    ShowNotice(32422)
  end
end
function MiniTvSystem.OnShowTips(_, _, _tips)
  log(bWriteLog and "MiniTvSystem.OnShowTips" .. tostring(_tips.tipId))
  if _tips.tipId ~= TipsMacro.ENUM_TipID.MiniTv then
    return
  end
  if not MiniTvSystem.CanShowTip() then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    printf("MiniTvSystem.OnShowTips CloseMiniTVBubbleUI")
    SAUtils.CloseMiniTVBubbleUI()
  end
  local TipsManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.TipsManager)
  TipsManager:SetTipsShowing(TipsMacro.ENUM_TipID.MiniTv)
  MiniTvSystem.ShowUI(UIType.NormalWordTips, {
    isQueue = true,
    word = _tips.word
  })
end
function MiniTvSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "mini_logic: OnModePostSwitch" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    local lastStatus = GameStatus.GetLastGameStatus()
    if lastStatus == GameStatus.Fighting then
      NCurPage = ENUM_LobbyPageType.Mid
    end
    MiniTvSystem.BattleBackToLobby()
    log(bWriteLog and "zxqt BattleSwitch OnModePostSwitch")
  elseif not GameStatus.IsInLobbyOrMainCity() then
    MiniTvSystem.Release()
  end
end
function MiniTvSystem.BattleBackToLobby()
  MiniTvSystem.Reset()
end
function MiniTvSystem.Reset()
  if not HasRegistEvent then
    log(bWriteLog and "zxqt MiniTvSystem RegistEvent")
    EventSystem:registEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, MiniTvSystem.OnWidgetHide)
    EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, MiniTvSystem.WhenTeamChange)
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, MiniTvSystem.OnSwitchToPageStart)
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, MiniTvSystem.OnSwitchToPageEnd)
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, MiniTvSystem.OnGetDisplayData)
    EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_ON_PRE_MATCH_SUCCESS, MiniTvSystem.OnPreMatchSuccess)
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, MiniTvSystem.StartLoading)
    EventSystem:registEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, MiniTvSystem.OnXmissionOpen)
    EventSystem:registEvent(EVENTTYPE_TIPS_MANAGER, EVENTID_TOP_TIP, MiniTvSystem.OnShowTips)
    EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_OPEN_RIGHTBOTTOM_MENU, MiniTvSystem.OnOpenRightMenu)
    EventSystem:registEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_LOGIN_ROLEDATA_SYNC, MiniTvSystem.OnGetDisplayId)
    EventSystem:registEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, MiniTvSystem.OnDownloadFinish)
    HasRegistEvent = true
  end
  proxy.TryShowSmartAssistant()
end
function MiniTvSystem.Release()
  log(bWriteLog and "mini_logic: MiniTvSystem.Release")
  HasRegistEvent = false
  IsReadNewerConfig = false
  ActorData = {
    NLocationX = MiniTVConst.INIT_LOCATION_X,
    NLocationY = MiniTVConst.INIT_LOCATION_Y,
    NLocationZ = MiniTVConst.INIT_LOCATION_Z,
    NDistance = 0,
    OverlapTag = nil
  }
  EventSystem:unregistEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, MiniTvSystem.OnWidgetHide)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, MiniTvSystem.WhenTeamChange)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, MiniTvSystem.OnSwitchToPageStart)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, MiniTvSystem.OnSwitchToPageEnd)
  EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, MiniTvSystem.OnGetDisplayData)
  EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_ON_PRE_MATCH_SUCCESS, MiniTvSystem.OnPreMatchSuccess)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, MiniTvSystem.StartLoading)
  EventSystem:unregistEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, MiniTvSystem.OnXmissionOpen)
  EventSystem:unregistEvent(EVENTTYPE_TIPS_MANAGER, EVENTID_TOP_TIP, MiniTvSystem.OnShowTips)
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_OPEN_RIGHTBOTTOM_MENU, MiniTvSystem.OnOpenRightMenu)
  EventSystem:unregistEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_LOGIN_ROLEDATA_SYNC, MiniTvSystem.OnGetDisplayId)
  EventSystem:unregistEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, MiniTvSystem.OnDownloadFinish)
  proxy.DestroySmartAssistant()
  MiniTVActor = nil
  printf("MiniTvSystem.Release CloseMiniTVBubbleUI")
  SAUtils.CloseMiniTVBubbleUI()
  OneClickReward.Release()
end
function MiniTvSystem.OnSwitchToPageStart(_, _, toPage)
  log(bWriteLog and "mini_logic:OnSwitchToPageStart toPage" .. tostring(toPage))
  if toPage ~= ENUM_LobbyPageType.Mid then
    proxy.HideSmartAssistant()
  end
end
function MiniTvSystem.OnXmissionOpen()
  log(bWriteLog and "mini_logic: OnXmissionOpen")
  proxy.HideSmartAssistant()
end
function MiniTvSystem.WhenWin(_, _, trigger_cond)
  if trigger_cond == ENUM_TRIGGER_COND.FIRST_CHICKEN then
    log(bWriteLog and "mini_logic: WhenWin")
    BNeedShowWin = true
  end
end
function MiniTvSystem.NeedShowWin()
  return BNeedShowWin
end
function MiniTvSystem.ShowWin()
  BNeedShowWin = nil
end
function MiniTvSystem.WhenTeamChange()
  proxy.UpdateMiniTvVisible()
end
function MiniTvSystem.OnSwitchToPageEnd(_, _, _, toPage)
  log(bWriteLog and "mini_logic:OnSwitchToPageEnd toPage" .. tostring(toPage))
  NCurPage = toPage
  if toPage == ENUM_LobbyPageType.Mid then
    proxy.TryShowSmartAssistant()
  else
    proxy.HideSmartAssistant()
  end
end
function MiniTvSystem.GetIgnoreUIMap()
  if not IgnoreUIConfigMap then
    IgnoreUIConfigMap = {}
    for k, v in pairs(IgnoreUIConfigList) do
      IgnoreUIConfigMap[v.keyName] = true
    end
  end
  return IgnoreUIConfigMap
end
function MiniTvSystem.GetShowUIMap()
  if not UIShowMap then
    UIShowMap = {}
    for k, v in pairs(ShowUIConfigList) do
      UIShowMap[v.keyName] = true
    end
  end
  return UIShowMap
end
function MiniTvSystem.OnWidgetHide(_, _, keyName)
  local ignoreUI = MiniTvSystem.GetIgnoreUIMap() or {}
  if ignoreUI[keyName] then
    return
  end
  local showUI = MiniTvSystem.GetShowUIMap() or {}
end
function MiniTvSystem.StartLoading()
  proxy.HideSmartAssistant()
end
function MiniTvSystem.OneClicked()
  log(bWriteLog and "MiniTvSystem.OneClicked()" .. tostring(nowTipsStatus))
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    printf("MiniTvSystem.OneClicked CloseMiniTVBubbleUI")
    SAUtils.CloseMiniTVBubbleUI()
    return
  end
  local utils = require("client.slua.logic.sa.SAUtils")
  utils.ShowSmartAssistantMainUI(3)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Mini_Click)
end
function MiniTvSystem.Create()
  local world = slua_GameFrontendHUD:GetWorld()
  local actor = "/Game/Arts_Player/MiniTV/Mesh/MiniTv_Class.MiniTv_Class_C"
  local tclass = import(actor)
  if world and tclass then
    log(bWriteLog and "mini_logic: showMesh")
    local Position = FVector(ActorData.NLocationX, ActorData.NLocationY, 0)
    MiniTVActor = world:SpawnActor(tclass, Position, nil, nil)
    if not MiniTVActor then
      return
    end
    MiniTvSystem.PutOnClothe()
    MiniTVActor:K2_SetActorRotation(FRotator(0, 0, 0), false)
    MiniTVActor:SetActorScale3D(FVector(1, 1, 1))
    log(bWriteLog and "mini_logic: MiniTvSystem.Create")
  end
  if DownloadAct and DownloadAct.IconPath then
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local texture = image_download_mgr:GetLocalImageCache(DownloadAct.IconPath)
    if texture then
    else
      image_download_mgr:DownloadImageByHttpWrapper(DownloadAct.IconPath)
    end
  end
  return MiniTVActor
end
function MiniTvSystem.SaveActorData()
  if slua.isValid(MiniTVActor) then
    ActorData = MiniTVActor:GetActorData()
    log_tree("MiniTvSystem SaveActorData", ActorData)
  end
end
function MiniTvSystem.GetActorData()
  return ActorData
end
function MiniTvSystem.ShowUI(type, data)
end
function MiniTvSystem.CanShowTip()
  return false
end
function MiniTvSystem.OnPreMatchSuccess()
  proxy.HideSmartAssistant()
end
function MiniTvSystem.OnGetDisplayData(_, _, _, ActivityMiniTVData)
  log_tree("mini_logic: ActivityMiniTVData", ActivityMiniTVData)
  MiniTvSystem.RemoveBannerList()
  AllActivityData = {}
  if ActivityMiniTVData and 0 < #ActivityMiniTVData then
    for _, v in pairs(ActivityMiniTVData) do
      if v.ShowSceneID == ActivitySceneID.MiniTVLobby then
        table.insert(AllActivityData, v)
      elseif v.ShowSceneID == ActivitySceneID.MiniTVDownload then
        DownloadAct = v
      elseif v.ShowSceneID == ActivitySceneID.MiniTVFight then
        MiniTvSystem.AddBannerData(v)
      end
    end
    MiniTvSystem.SortBannerList()
  end
end
function MiniTvSystem.AddBannerData(data)
  if not (data and data.ID) or tonumber(data.ID) <= 0 then
    return
  end
  log_tree("MiniTvSystem.AddBannerData ", data)
  MiniTvSystem.BannerDataList = MiniTvSystem.BannerDataList or {}
  table.insert(MiniTvSystem.BannerDataList, data)
end
function MiniTvSystem.RemoveBannerList()
  log(bWriteLog and "MiniTvSystem.RemoveBannerList")
  MiniTvSystem.BannerDataList = nil
end
function MiniTvSystem.GetBannerList()
  return MiniTvSystem.BannerDataList
end
function MiniTvSystem.SortBannerList()
  if MiniTvSystem.BannerDataList and #MiniTvSystem.BannerDataList > 0 then
    table.sort(MiniTvSystem.BannerDataList, MiniTvSystem.SortActivityDisplayListFunc)
  end
end
function MiniTvSystem.SortActivityDisplayListFunc(a, b)
  if (a.Weight or 0) == (b.Weight or 0) then
    if (a.StartTimeUTC or 0) == (b.StartTimeUTC or 0) then
      if (a.ID or 0) == (b.ID or 0) then
        return false
      else
        return (a.ID or 0) > (b.ID or 0)
      end
    else
      return (a.StartTimeUTC or 0) > (b.StartTimeUTC or 0)
    end
  else
    return (a.Weight or 0) > (b.Weight or 0)
  end
end
function MiniTvSystem.ShowDownloadAct()
  log(bWriteLog and "mini_logic: MiniTvSystem.ShowDownloadAct")
  if DownloadAct then
    log(bWriteLog and "mini_logic: Jump ShowDownloadAct")
    local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
    local texture = image_download_mgr:GetLocalImageCache(DownloadAct.IconPath)
    if texture then
    else
      image_download_mgr:DownloadImageByHttpWrapper(DownloadAct.IconPath)
    end
  else
    ShowNotice(120106)
  end
end
function MiniTvSystem.PutOnClothe()
  local tvStatus = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV_CLOTHE)
  if not tvStatus then
    MiniTvSystem.PutOnDefaultSuit()
    log(bWriteLog and "mini_logic: BP_ENUM_LOBBY_MINI_TV_CLOTHE" .. tostring(tvStatus))
    return
  end
  local itemId = DataMgr.minitv_dressid
  if itemId == nil or itemId == 0 then
    MiniTvSystem.PutOnDefaultSuit()
    log(bWriteLog and "MiniTvSystem.PutOnClothe itemData is nil")
    return
  end
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  _alreadyDownload = dowloadState == ENUM_DownloadState.Done
  if not _alreadyDownload then
    MiniTvSystem.PutOnDefaultSuit()
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  elseif slua.isValid(MiniTVActor) then
    MiniTVActor:PutOnCloth(itemId)
  end
end
function MiniTvSystem.PutOnDefaultSuit()
  if slua.isValid(MiniTVActor) then
    MiniTVActor:PutOnCloth(1601019)
  end
end
function MiniTvSystem.OnOpenRightMenu(_, _)
  if UIManager.IsUIShow(UIManager.UI_Config.SmartAssistantV2_RobotBubble_Item_UIBP) then
    printf("MiniTvSystem.OnOpenRightMenu CloseMiniTVBubbleUI")
    SAUtils.CloseMiniTVBubbleUI()
    return
  end
end
function MiniTvSystem.OnGetDisplayId()
  local itemId = DataMgr.minitv_dressid
  if itemId == nil then
    return
  end
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  _alreadyDownload = dowloadState == PufferConst.ENUM_DownloadState.Done
  if not _alreadyDownload then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemId})
  else
    MiniTvSystem.PutOnClothe()
  end
end
function MiniTvSystem.OnJumpUrl()
  local utils = require("client.slua.logic.sa.SAUtils")
  utils.ShowSmartAssistantMainUI(1)
end
function MiniTvSystem.GetMiniTVActor()
  return MiniTVActor
end
return MiniTvSystem
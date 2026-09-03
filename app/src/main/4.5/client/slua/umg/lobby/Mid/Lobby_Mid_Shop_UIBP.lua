local Lobby_Mid_Shop_UIBP = {}
local LogicNewbie = require("client.logic.newbie.logic_newbie")
local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
local gem_report_utils = require("client.logic.store.gem_report_utils")
function Lobby_Mid_Shop_UIBP:ctor()
  self.timerRunning = false
  self.childUIList = {}
  self.aniIntervalTime = {}
  self.isPlayingList = {}
  self.bShowSubscribeBubble = false
  self.uRemainTimer = nil
  self.bIsRPAnnualBubble = false
  self.bubbleTipType = nil
  self.bubbleUIRoot = nil
  self.is_need_update_rp_bubble = false
end
function Lobby_Mid_Shop_UIBP:OnInitialize()
  Lobby_Mid_Shop_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.Button_Supply = self.UIRoot.Button_Supply
  self.Button_Supply_JK = self.UIRoot.Button_Supply_JK
  self.Button_Shop = self.UIRoot.Button_Shop
  self.WidgetSwitcher_Supply = self.UIRoot.WidgetSwitcher_Supply
  self.WidgetSwitcher_Shop = self.UIRoot.WidgetSwitcher_Shop
  self.TextBlock_Time = self.UIRoot.TextBlock_Time
  self.Store_Reddot_Anchor = self.UIRoot.Store_Reddot_Anchor
  self.Sup_Reddot_Anchor = self.UIRoot.Sup_Reddot_Anchor
  self.Image_JKSupReddot = self.UIRoot.Image_JKSupReddot
end
function Lobby_Mid_Shop_UIBP:RegistEvents()
  Lobby_Mid_Shop_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Supply, self.OnButton_SupplyClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Shop, self.OnButton_ShopClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Supply_JK, self.OnButton_Supply_JKClick, self)
  self:AddControlEventByControl(self.UIRoot.Anima_Supply, "OnAnimationFinished", self.LobbyEffectEnd_Supply, self)
  self:AddControlEventByControl(self.UIRoot.Anima_Shop, "OnAnimationFinished", self.LobbyEffectEnd_Shop, self)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_REDDOT_CHANGE, self.UpdateJKSupReddot, self)
  self:AddCommonEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO, self.UpdateLobbyMallReddot, self)
  self:AddCommonEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, self.UpdateLobbyMallReddot, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_DOWNLOAD_REFRESH, self.OnRefreshRPDownloadBtn, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.OnRefreshRPDownloadBtn, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.ShowCrateSoldOutTip, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_COLLECT_NOTIFY, self.ShowCrateSoldOutTip, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_MALL, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, self.OnSubscribeBubbleUpdate, self)
end
function Lobby_Mid_Shop_UIBP:OnPostInitialize()
  Lobby_Mid_Shop_UIBP.__super.OnPostInitialize(self)
  log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnPostInitialize")
  self:UpdateUI()
  self:AddTimerOnce(1, function()
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_get_bubble_info_req()
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:GetStoreAndSupplyTabList()
  end)
end
function Lobby_Mid_Shop_UIBP:AddChildUI(ui_config, parent_name, ...)
  if self.childUIList and ui_config and parent_name then
    self:CloseChildUI(ui_config)
    local childUI = self:CreateChildWindow(parent_name, ui_config, ...)
    self.childUIList[ui_config.moduleName] = childUI
    return childUI
  end
end
function Lobby_Mid_Shop_UIBP:GetChildUI(config)
  if config and self.childUIList then
    return self.childUIList[config.moduleName]
  end
  return nil
end
function Lobby_Mid_Shop_UIBP:CloseChildUI(config)
  if self.childUIList and config and self.childUIList[config.moduleName] then
    self.childUIList[config.moduleName]:Close()
    self.childUIList[config.moduleName] = nil
  end
end
function Lobby_Mid_Shop_UIBP:UpdateUI()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ResourseVersion = UnknowPassUtil.GetVersionNumber()
  Client.SetImageVersionString("1_3_0", ResourseVersion)
  self:ShowLobbyButton()
  if GlobalData.IsJapanOrKorea() then
    self:UpdateJKSupReddot()
    self.WidgetSwitcher_Supply:SetActiveWidgetIndex(1)
    self.WidgetSwitcher_Shop:SetActiveWidgetIndex(1)
    self.UIRoot.Image_star:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.UIRoot.eff_ShopStar, 0, 0, 0, 1)
  else
    self.WidgetSwitcher_Supply:SetActiveWidgetIndex(0)
    self.WidgetSwitcher_Shop:SetActiveWidgetIndex(0)
    self.UIRoot.Image_star:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if LobbySystem.IsInNarutoVersionTime() then
    self:SetTexture(self.UIRoot.Image_69, "/Game/UMG/Texture_200/Atlas/Lobby_Activity/FlameShadow/Frames/Lobby_Box_450Theme_png.Lobby_Box_450Theme_png")
    self:SetTexture(self.UIRoot.Image_Shop, "/Game/UMG/Texture_200/Atlas/Lobby_Activity/FlameShadow/Frames/Lobby_Shop_450Theme_png.Lobby_Shop_450Theme_png")
    self:SetTexture(self.UIRoot.Image_Shop_KJ, "/Game/UMG/Texture_200/Atlas/Lobby_Activity/FlameShadow/Frames/Lobby_Shop_450ThemeJK_png.Lobby_Shop_450ThemeJK_png")
    self:SetTexture(self.UIRoot.Image_Supply_JK, "/Game/UMG/Texture_200/Atlas/Lobby_Activity/FlameShadow/Frames/Lobby_Shop_450ThemeBoxJK_png.Lobby_Shop_450ThemeBoxJK_png")
  else
    self:SetTexture(self.UIRoot.Image_69, "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Box_png.Lobby_Image_Box_png")
    self:SetTexture(self.UIRoot.Image_Shop, "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Shop_png.Lobby_Image_Shop_png")
    self:SetTexture(self.UIRoot.Image_Shop_KJ, "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Shop_JK_png.Lobby_Image_Shop_JK_png")
    self:SetTexture(self.UIRoot.Image_Supply_JK, "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Box_JK_png.Lobby_Image_Box_JK_png")
  end
end
function Lobby_Mid_Shop_UIBP:UpdateJKSupReddot()
  if GlobalData.IsJapanOrKorea() then
    local region = FuncUtil.GetAccountRegionForBP()
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if region ~= AccountRegionForBPMacros.JP then
      if RechargePurchaseSystem.NeedShowRedDot then
        self.Image_JKSupReddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_JKSupReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
end
function Lobby_Mid_Shop_UIBP:UpdateLobbyMallReddot()
  log(bWriteLog and "[jiayan]  UpdateLobbyMallReddot")
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10003) then
    return
  end
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  local storeReddotSuperData = store_reddot_manager:GetStoreRedData()
  local crateReddotSuperData = store_reddot_manager:GetSupplyRedData()
  if GlobalData.IsJapanOrKorea() then
    local reddot_group = require("client.slua.logic.reddot.reddot_group")
    local JKStoreCrateName = "JKStoreCrate"
    local JKStoreCrateReddotSuperData = reddot_group:AddGroup(JKStoreCrateName)
    if storeReddotSuperData and next(storeReddotSuperData) then
      reddot_group:AddToGroup(storeReddotSuperData, JKStoreCrateName)
    end
    if crateReddotSuperData and next(crateReddotSuperData) then
      reddot_group:AddToGroup(crateReddotSuperData, JKStoreCrateName)
    end
    self:BindReddot(self.Store_Reddot_Anchor, JKStoreCrateReddotSuperData)
  else
    self:BindReddot(self.Store_Reddot_Anchor, storeReddotSuperData)
    self:BindReddot(self.Sup_Reddot_Anchor, crateReddotSuperData)
    if self.bShowSubscribeBubble then
      log(bWriteLog and "Lobby_Mid_Shop_UIBP:UpdateLobbyMallReddot Is Show Subscribe Bubble, Hide the red dot!")
      self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
      StoreLimitedSubscribeData:CheckBubbleShow(true)
    end
  end
end
function Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate(_, __, bShow)
  if GlobalData.IsJapanOrKorea() then
    log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate Jk has no mall subscribe")
    return
  end
  log(bWriteLog and string.format("Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate Show : %s", bShow))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eStoreBubbleShowTime)
  if bShow and not self.bShowSubscribeBubble then
    if self.UIRoot.Reddot_Anchor_Item12:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate Bubble has already shown!")
      return
    end
    if self:CheckIsNewArrivalsReddot() then
      self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      return
    end
    if data == nil or data == {} or data == 0 or type(data) ~= "table" then
      log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate has not exist showTime record!")
      data = {
        time = TimeUtil.GetServerTimeInSec(),
        bDisappear = false
      }
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eStoreBubbleShowTime)
      self.UIRoot.Reddot_Anchor_Item12:PlayUserWidgetAnimation(self.UIRoot.Reddot_Anchor_Item12.Breathing, 0, 0, 0, 1)
      self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.bShowSubscribeBubble = true
    else
      local showTime = data.time and data.time or 0
      local currentTime = TimeUtil.GetServerTimeInSec()
      local currentDate = TimeUtil.FormatTime_YMD(currentTime)
      local showDate = TimeUtil.FormatTime_YMD(showTime)
      local bShowBubble = not data.bDisappear or false
      log(bWriteLog and string.format("Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate showTime : %s, currentTime : %s, ShowBubble : %s", tostring(showDate), tostring(currentDate), tostring(bShowBubble)))
      if currentDate ~= showDate or currentDate == showDate and bShowBubble then
        log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate show bubble!")
        data.time = currentTime
        data.bDisappear = false
        PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eStoreBubbleShowTime)
        self.UIRoot.Reddot_Anchor_Item12:PlayUserWidgetAnimation(self.UIRoot.Reddot_Anchor_Item12.Breathing, 0, 0, 0, 1)
        self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.bShowSubscribeBubble = true
      else
        log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate don't show bubble!")
      end
    end
  elseif not bShow and self.UIRoot.Reddot_Anchor_Item12:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnSubscribeBubbleUpdate hide the bubble")
    data = {}
    data.time = TimeUtil.GetServerTimeInSec()
    data.bDisappear = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eStoreBubbleShowTime)
    self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.bShowSubscribeBubble = false
  end
end
function Lobby_Mid_Shop_UIBP:CheckIsNewArrivalsReddot()
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  local storeReddotSuperData = store_reddot_manager:GetStoreRedData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  if not (storeReddotSuperData and storeReddotSuperData.category) or not storeReddotSuperData.newCount then
    return false
  end
  if storeReddotSuperData.category ~= reddot_macro.Category.NewArrivals then
    return false
  end
  local recommendPageId = 501
  local limitSubscribePageId = 50105
  if not (storeReddotSuperData[501] and storeReddotSuperData[recommendPageId][limitSubscribePageId]) or not storeReddotSuperData[recommendPageId][limitSubscribePageId].newCount then
    return true
  end
  if storeReddotSuperData[recommendPageId][limitSubscribePageId].newCount == storeReddotSuperData.newCount then
    return false
  end
  return true
end
function Lobby_Mid_Shop_UIBP:BindReddot(reddot_anchor, reddotData)
  if reddot_anchor then
    reddot_anchor:UnBind()
    if reddotData and next(reddotData) then
      self:RegistReddotWidget(reddot_anchor)
      reddot_anchor:Bind(reddotData)
    end
  end
end
function Lobby_Mid_Shop_UIBP:Close()
  self:CloseAllChildUI()
  if self.Store_Reddot_Anchor then
    self.Store_Reddot_Anchor:UnBind()
  end
  if self.Sup_Reddot_Anchor then
    self.Sup_Reddot_Anchor:UnBind()
  end
  if self.uRemainTimer then
    self:RemoveTimer(self.uRemainTimer)
    self.uRemainTimer = nil
  end
  Lobby_Mid_Shop_UIBP.__super.Close(self)
end
function Lobby_Mid_Shop_UIBP:OnButton_SupplyClick()
  log(bWriteLog and "Lobby_Mid_Shop_UIBP:OnButton_SupplyClick")
  self:PlayAudio(sound_config.new_crateBtn)
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY) then
    ShowNotice(120001)
    return
  end
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  store_supply_switcher:OpenSupply({
    from = StoreConst.source_EntryJumpToCrate
  })
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if GlobalData.IsJapanOrKorea() then
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyClickStore_JK)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyShop_JK)
  else
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyClickSupply)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySupply)
  end
  local lobbyMainUi = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMainUi then
    lobbyMainUi:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Shop_UIBP:OnButton_Supply_JKClick()
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.EnterFrom = RechargeSystem.E_UcEntryType.FromLobbyUC
  RechargeSystem.OpenRechargeUI()
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local isPrimeOpen = subscribeModuleObj:GetIsPrimeOpen()
  if isPrimeOpen then
    local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
    subscri_redpoint_data:SaveIsEnterPrime()
  end
end
function Lobby_Mid_Shop_UIBP:OnButton_ShopClick()
  self:PlayAudio(sound_config.new_shopBtn)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MALL, true) then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not GlobalData.IsJapanOrKorea() then
    self:PlayAudio("/Game/WwiseEvent/UI_hall/UI_hall_Shopping_open.UI_hall_Shopping_open")
    if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyBtn) == false then
      return
    end
    local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
    store_supply_switcher:OpenStore()
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyClickStore)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyShop)
  else
    self:OnButton_SupplyClick()
  end
  local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, 1)
  log(bWriteLog and "[  bNewbie" .. tostring(bNewbie))
  if bNewbie then
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_STORE, 1)
    self:UpdateLobbyMallReddot()
  end
end
function Lobby_Mid_Shop_UIBP:ShowLobbyButton()
  local pass_enable = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_UNKNOW_PASS)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Rp, pass_enable)
end
function Lobby_Mid_Shop_UIBP:ShowCrateSoldOutTip()
  log(bWriteLog and "[chub]log_Lobby_Mid_Shop_UIBP:ShowCrateSoldOutTip")
  local switch = LobbySystem.CheckOpen(BP_ENUM_CRATE_COLLECT_SWITCH)
  if not switch then
    log(bWriteLog and "[chub]log_Lobby_Mid_Shop_UIBP:switch = nil")
    return
  end
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  local shopInfo = supply_collect_chest_manager:GetOneBubbleShopInfo()
  if not shopInfo or not shopInfo[StoreConst.label_shop_index_end_time] then
    log(bWriteLog and "[chub]log_Lobby_Mid_Shop_UIBP:shopInfo = nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local preShowTipTime = supply_collect_chest_manager:GetPreShowTipTime()
  local IntervalTime = 300
  if IntervalTime > serverTime - preShowTipTime then
    return
  end
  local timeStr
  local leftTime = shopInfo[StoreConst.label_shop_index_end_time] - serverTime
  if leftTime < 3600 then
    timeStr = LocUtil.LocalizeResFormat(6007, math.ceil(leftTime / 60))
  else
    timeStr = LocUtil.LocalizeResFormat(4795, TimeUtil.GetHouseByTotalSec(leftTime))
  end
  local nSecond = 30
  local sCrateName = CDataTable.GetTableData("Item", shopInfo[StoreConst.label_shop_index_item_id]).ItemName
  local content = LocUtil.LocalizeResFormat(21203, sCrateName, timeStr)
  local shopId = shopInfo[StoreConst.label_shop_index_id]
  local sIconPath = shopInfo[StoreConst.label_shop_index_tab_bg] or ""
  log(bWriteLog and "[chub]log_ShowCrateSoldOutTip:sIconPath = " .. sIconPath)
  local callback = function()
    if shopId then
      GlobalData.JumpUrl(string.format("game://?module=%d&Tab1=%d&from=%d", BP_ENUM_MODULE_SUPPLY, shopId, StoreConst.crate_collect_jump_buy_bubble))
    end
  end
  local bIsDefaultPic = string.find(sIconPath, "DianCang") or string.find(sIconPath, "MAHotTab")
  if sIconPath ~= "" and not bIsDefaultPic then
    local bIsSmallIcon = not GlobalData.IsJapanOrKorea()
    local jumpInfo = {}
    jumpInfo.    log(bWriteLog and "[chub]log_ShowCrateSoldOutTip:bIsSmallIcon = " .. tostring(bIsSmallIcon))
    local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
    local ConfigTab = {}
    RightPopSystem.CommonPopup(ConfigTab, "", content, sIconPath, jumpInfo, nSecond, bIsSmallIcon)
  else
    local GotoBtn = {}
    GotoBtn.    local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
    RightPopSystem.ShowPopupTip(content, true, nil, GotoBtn, nSecond)
  end
  supply_collect_chest_manager:RemoveCollectBubble(shopId)
  supply_collect_chest_manager:SetShowTipTime(serverTime)
end
function Lobby_Mid_Shop_UIBP:CloseAllChildUI()
  if self.childUIList then
    for k, v in pairs(self.childUIList) do
      v:Close()
      v = nil
    end
    self.childUIList = nil
  end
end
function Lobby_Mid_Shop_UIBP:OnRefreshRPDownloadBtn()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.GetRpResourceDownloadState() == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local list = PassDataSystem.GetRpResourceDownloadList()
  local common_download_handler = require("client.slua.common.common_download_handler")
  local size = string.format("%.2f", PassDataSystem.GetRPResDownloadSize())
  local askTips = LocUtil.LocalizeResFormat(23950, size)
  local extra = {askTips = askTips}
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, list, self, self.UIRoot.Panel_Download, extra)
  self:AddTimerOnce(1, function()
    PassDataSystem.DownloadRPRes(true)
  end)
end
function Lobby_Mid_Shop_UIBP:OnSwitchToPageStart(_, _, toPage)
  self:SetWidgetVisible(self.UIRoot.Button_RP, toPage == 1, true)
end
function Lobby_Mid_Shop_UIBP:LobbyEffectEnd_RP()
  if not self.isPlayingList.Anima_RP then
    return
  end
  self:AddTimerOnce(self.aniIntervalTime.Anima_RP, function()
    if self.UIRoot.Anima_RP then
      self:PlayUserWidgetAnimation(self.UIRoot.Anima_RP, 0, 1, 0, 1)
    end
  end)
end
function Lobby_Mid_Shop_UIBP:LobbyEffectEnd_Supply()
  if not self.isPlayingList.Anima_Supply then
    return
  end
  self:AddTimerOnce(self.aniIntervalTime.Anima_Supply, function()
    if self.UIRoot.Anima_Supply then
      self:PlayUserWidgetAnimation(self.UIRoot.Anima_Supply, 0, 1, 0, 1)
    end
  end)
end
function Lobby_Mid_Shop_UIBP:LobbyEffectEnd_Shop()
  if not self.isPlayingList.Anima_Shop then
    return
  end
  self:AddTimerOnce(self.aniIntervalTime.Anima_Shop, function()
    if self.UIRoot.Anima_Shop then
      self:PlayUserWidgetAnimation(self.UIRoot.Anima_Shop, 0, 1, 0, 1)
    end
  end)
end
function Lobby_Mid_Shop_UIBP:GetTipsMacroAndManager()
  local TipsMacro = require("client.slua.logic.tip.TipsMacro")
  local TipsManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.TipsManager)
  return TipsMacro, TipsManager
end
function Lobby_Mid_Shop_UIBP:PlayLobbyEffect(aniIntervalTime, aniName)
  if self.isPlayingList[aniName] then
    return
  end
  self.aniIntervalTime[aniName] = aniIntervalTime or 2
  self.isPlayingList[aniName] = true
  self:PlayUserWidgetAnimation(self.UIRoot[aniName], 0, 1, 0, 1)
end
function Lobby_Mid_Shop_UIBP:StopLobbyEffect(aniName)
  if not self.isPlayingList[aniName] then
    return
  end
  self.isPlayingList[aniName] = false
  self.aniIntervalTime[aniName] = 0
  self.UIRoot:StopAnimation(self.UIRoot[aniName])
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Shop_UIBP = class(ui_base, nil, Lobby_Mid_Shop_UIBP)
return CLobby_Mid_Shop_UIBP
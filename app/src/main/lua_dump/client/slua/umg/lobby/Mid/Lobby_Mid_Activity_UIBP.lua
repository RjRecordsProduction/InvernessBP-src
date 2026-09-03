local Lobby_Mid_Activity_UIBP = {}
local LogicNewbie = require("client.logic.newbie.logic_newbie")
local gem_report_utils = require("client.logic.store.gem_report_utils")
local logic_lobby_mid_entrance = require("client.slua.logic.lobby.Mid.logic_lobby_mid_entrance")
local TimeUtil = require("client.common.time_util")
local ENTRY_ID_ACTIVITY = 1001
local ENTRY_ID_RP = 1002
local ENTRY_ID_SPECIAL_OFFER = 1003
local ENTRY_ID_BP = 1005
local LAYOUT_RP = 0
local LAYOUT_DEFAULT = 1
local LAYOUT_SPECIAL_OFFER = 2
local LAYOUT_NEWBIE = 3
function Lobby_Mid_Activity_UIBP:ctor()
  self.actEightDayID = nil
  self.Left2 = 1
  self.Right  self.Left  self.Center3 = 4
  self.Right3 = 5
  self.UpdateSpecialActClock = nil
  self.uRemainTimer = nil
  self.paths = {
    "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_HalfLeft_BG_png.Lobby_Image_HalfLeft_BG_png",
    "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_HalfRight_BG_png.Lobby_Image_HalfRight_BG_png",
    "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_ThreePointLeft_BG_2_png.Lobby_Image_ThreePointLeft_BG_2_png",
    "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_ThreePointMid_BG_png.Lobby_Image_ThreePointMid_BG_png",
    "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_ThreePointRight_BG_png.Lobby_Image_ThreePointRight_BG_png"
  }
  self.CheckBubbleTimer = nil
  self.bShowSubscribeBubble = false
  self.ActivityBubbleTipsUI = nil
  self.curItemID = nil
  self.bubbleTipType = nil
  self.bubbleUIRoot = nil
end
function Lobby_Mid_Activity_UIBP:OnInitialize()
  Lobby_Mid_Activity_UIBP.__super.OnInitialize(self)
  self.Button_Activity = self.UIRoot.Button_Activity
  self.Button_RP = self.UIRoot.Button_RP
  self.TextBlock_Time = self.UIRoot.TextBlock_Time
  self.WidgetSwitcher_PassReddot = self.UIRoot.WidgetSwitcher_PassReddot
  self.RpCouponUI = self.UIRoot.UnknowPass_Discount_Bubble_Item_UIBP
  self:SetWidgetVisible(self.RpCouponUI, false, true)
  self:Check_AddOrDel_LobbyBubbleEntry()
  self:Check_AddAdvertisementShow()
end
function Lobby_Mid_Activity_UIBP:RegistEvents()
  Lobby_Mid_Activity_UIBP.__super.RegistEvents(self)
  if self.UIRoot.Button_Activity then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Activity, self.OnButton_ActivityClick, self)
  end
  if self.UIRoot.Button_SpecialActice then
    self:AddOnClickedEventByControl(self.UIRoot.Button_SpecialActice, self.OnButton_SpecialActice, self)
  end
  if self.UIRoot.Button_SpecialDiscount then
    self:AddOnClickedEventByControl(self.UIRoot.Button_SpecialDiscount, self.OnButton_SpecialDiscount, self)
  end
  if self.UIRoot.Button_RP then
    self:AddOnClickedEventByControl(self.UIRoot.Button_RP, self.OnButton_RPClick, self)
  end
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.UpdateSpecialActEvent, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.WhenTeamChange, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA, self.UpdateBtnEightDay, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, self.UpdateNewbieUI, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE, self.UpdateNewbieUI, self)
  self:AddCommonEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_SHOW_LOBBY_UPDATE, self.Check_AddAdvertisementShow, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_UPDATE_ENTRANCE, self.Check_AddOrDel_LobbyBubbleEntry, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_SEPCIAL_OFFER_BUBBLE_UPDATE, self.ShowSpecialOfferBubble, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_ACTIVITY_BUBBLE_UPDATE, self.ShowActivityBubble, self)
  self:AddCommonEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, self.OnSubscribeBubbleUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_GRAY_CONFIG_UPDATE, self.OnGetWeddingActivityEntry, self)
  self:AddCommonEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_ENTRY_OUT_OF_DATE, self.OnWeddingActivityEntryOutOfDate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_LOBBYREDDOT, self.UpdateUnknowPassReddotByEvent, self)
  self:AddCommonEvent(EVENTTYPE_TIPS_MANAGER, EVENTID_TOP_TIP, self.ShowRPLobbyBubbleQueue, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_UPDATE, self.ShowRPLobbyBubble, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_CLOSE, self.OnRPLobbyBubbleClose, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.OnRefreshRPDownloadBtn, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_DOWNLOAD_REFRESH, self.OnRefreshRPDownloadBtn, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, self.OnPassDataUpdate, self)
  self:AddCommonEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, self.OnPassScoreChanged, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_GIFT_DATA_HANDLE, self.UpdateLobbySpecialReddot, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_COMMERCE_ENTRANCE_UPDATE, self.OnCommerceEntranceUpdate, self)
end
function Lobby_Mid_Activity_UIBP:OnPostInitialize()
  Lobby_Mid_Activity_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
  if self.UIRoot.Button_SpecialDiscount then
    self:AddTimerOnce(10, function()
      log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnPostInitialize send_get_new_group_buy_info_req")
      local _ = RequireModDownload("client.network.Protocol.NewGroupBuyHandler", function(handler)
        handler.send_get_new_group_buy_info_req()
      end)
    end)
  end
end
function Lobby_Mid_Activity_UIBP:OnShow()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Act, true)
end
function Lobby_Mid_Activity_UIBP:UpdateUI()
  self.WidgetSwitcher_PassReddot:SetActiveWidgetIndex(0)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    self.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(66311))
  else
    self.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(4317))
  end
  self:AddTimer(0.1, function()
    self:UpdateActRed()
    self:CheckSpecialOfferDataReady()
  end)
  self:UpdateSpecialAct()
  self:UpdateSpecialDiscount()
  self:UpdateActicityCenterBtn()
  self:UpdateRpAndSaleEntryUI()
  local logic_wedding_system_common = require("GameLua.Mod.MainCity.Client.logic.WeddingSystem.logic_wedding_system_common")
  local logic_wedding_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wedding_activity)
  logic_wedding_activity:ReqWeddingActivityGrayConfig()
end
function Lobby_Mid_Activity_UIBP:UpdateWeddingActivityEntry()
  local logic_wedding_system_common = require("GameLua.Mod.MainCity.Client.logic.WeddingSystem.logic_wedding_system_common")
  local logic_wedding_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wedding_activity)
  local status = logic_wedding_activity:GetWeddingActivityEntryStatus()
  if status == logic_wedding_system_common.Status.Close then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateWeddingActivityEntry status is close")
    if self.weddingActivityEntryUI then
      self.weddingActivityEntryUI:Close()
      self.weddingActivityEntryUI = nil
    end
    if self.weddingActivityTimer then
      self:RemoveTimer(self.weddingActivityTimer)
      self.weddingActivityTimer = nil
    end
    return
  end
  if status == logic_wedding_system_common.Status.Open then
    if not self.weddingActivityEntryUI then
      log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateWeddingActivityEntry create weddingActivityEntryUI")
      self.weddingActivityEntryUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_WeddingActivity, UIManager.UI_Config.Matchmaking_Enter_UIBP)
    end
  elseif self.weddingActivityEntryUI then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateWeddingActivityEntry close weddingActivityEntryUI")
    self.weddingActivityEntryUI:Close()
    self.weddingActivityEntryUI = nil
  end
  if not self.weddingActivityTimer then
    self.weddingActivityTimer = self:AddTimerLoop(0, function()
      self:UpdateWeddingActivityEntry()
    end, TIMER_INFINITE, 5)
  end
end
function Lobby_Mid_Activity_UIBP:Check_AddOrDel_LobbyBubbleEntry()
  if self.tipsUI then
    return
  end
  local SpecialOfferBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SpecialOfferBubbleModule)
  local act_info = SpecialOfferBubbleModule:GetActData()
  if act_info and SpecialOfferBubbleModule:CheckBubbleCanShow() then
    log(bWriteLog and "mxiliu:Check_AddOrDel_LobbyBubbleEntry the canshow is true")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_WorldCup, true)
    self:ClearSpecialOfferBubble()
    if self.specialOffer_Entrance_UIBP == nil then
      self.specialOffer_Entrance_UIBP = self:CreateChildWindow(self.UIRoot.CanvasPanel_WorldCup, UIManager.UI_Config.SpecialOffer_Entrance_UIBP)
      if self.specialOffer_Entrance_UIBP then
        log(bWriteLog and "mxiliu:Check_AddOrDel_LobbyBubbleEntry the specialOffer_Entrance_UIBP is have")
        self.specialOffer_Entrance_UIBP:SetAnchors(0, 0, 0, 0)
        self.specialOffer_Entrance_UIBP:SetOffsets(961, 222, 0, 0)
        self:SetSpecialOfferEntranceBubbleStatus(true)
        self:StartCheckBubbleTimer()
      end
    end
  else
    log(bWriteLog and "mxiliu:Check_AddOrDel_LobbyBubbleEntry the canshow is false")
    if self.specialOffer_Entrance_UIBP then
      UIManager.CloseUI(UIManager.UI_Config.SpecialOffer_Entrance_UIBP)
      self.specialOffer_Entrance_UIBP = nil
      self:SetSpecialOfferEntranceBubbleStatus(false)
    end
  end
end
function Lobby_Mid_Activity_UIBP:StartCheckBubbleTimer()
  if self.CheckBubbleTimer then
    return
  end
  self.CheckBubbleTimer = self:AddTimerLoop(0, function()
    self:UpdateBubbleState()
  end, TIMER_INFINITE, 1)
end
function Lobby_Mid_Activity_UIBP:UpdateBubbleState()
  local SpecialOfferBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SpecialOfferBubbleModule)
  if not SpecialOfferBubbleModule:CheckBubbleCanShow() then
    self:Check_AddOrDel_LobbyBubbleEntry()
    if self.CheckBubbleTimer then
      self:RemoveTimer(self.CheckBubbleTimer)
      self.CheckBubbleTimer = nil
    end
  end
end
function Lobby_Mid_Activity_UIBP:CloseActEntrance()
  if self.airdropCarnival_Entrance_UIBP then
    self.airdropCarnival_Entrance_UIBP:CloseSelf()
    self.airdropCarnival_Entrance_UIBP = nil
    self:SetSuperAirDropBubbleStatus(false)
  end
end
function Lobby_Mid_Activity_UIBP:Check_AddAdvertisementShow()
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:Check_AddAdvertisementShow")
  local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
  if not logic_advertisement_BlueHole:CheckCanGetAdvertisementData() then
    self:RemoveAdBubbleEntry()
    return
  end
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  local taskdata = logic_advertisement_BlueHole:GetAdvertisementtTaskData()
  if taskdata and taskdata.status ~= AD_macro.ENUM_STATUS_TYPE.RECEIVED then
    log(bWriteLog and "mxiliu:Check_AddAdvertisementShow the taskdata is have")
    self:AddAdBubbleEntry()
  else
    if taskdata and taskdata.status then
      log(bWriteLog and "mxiliu:Check_AddAdvertisementShow the status is " .. tostring(taskdata.status))
    else
      log(bWriteLog and "mxiliu:Check_AddAdvertisementShow the taskdata is nil")
    end
    self:RemoveAdBubbleEntry()
  end
end
function Lobby_Mid_Activity_UIBP:AddAdBubbleEntry()
  if self.Lobby_Mid_Bubble_AD_UIBP then
    return
  end
  if not self.UIRoot.CanvasPanel_Videos then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:AddAdBubbleEntry CanvasPanel_Videos not found")
    return
  end
  self.Lobby_Mid_Bubble_AD_UIBP = self:CreateChildWindow(self.UIRoot.CanvasPanel_Videos, UIManager.UI_Config.Lobby_Mid_Bubble_AD_UIBP)
end
function Lobby_Mid_Activity_UIBP:RemoveAdBubbleEntry()
  if self.Lobby_Mid_Bubble_AD_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.Lobby_Mid_Bubble_AD_UIBP)
    self.Lobby_Mid_Bubble_AD_UIBP = nil
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:RemoveAdBubbleEntry removed")
  end
end
function Lobby_Mid_Activity_UIBP:ShowSpecialOfferBubble(_, __)
  if not self:IsCanShowSpecialOfferBubble() then
    return
  end
  self.specialOffer_Entrance_UIBP = self:CreateChildWindow(self.UIRoot.CanvasPanel_WorldCup, UIManager.UI_Config.SpecialOffer_Tips_UIBP)
  if self.specialOffer_Entrance_UIBP then
    self.specialOffer_Entrance_UIBP:SetAnchors(0, 0, 1, 1)
    self.specialOffer_Entrance_UIBP:SetOffsets(0, 0, 0, 0)
    self:WidgetHidden(self.UIRoot.CanvasPanel_SpecialDiscount)
    self:SetSpecialOfferTipsBubbleStatus(true)
  end
end
function Lobby_Mid_Activity_UIBP:ClearSpecialOfferBubble()
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:ClearSpecialOfferBubble ")
  if self.specialOffer_Entrance_UIBP then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:ClearSpecialOfferBubble self.specialOffer_Entrance_UIBP is valid")
    self.specialOffer_Entrance_UIBP:CloseSelf()
    self.specialOffer_Entrance_UIBP = nil
    self:SetSpecialOfferTipsBubbleStatus(false)
  end
  self:UpdateSpecialDiscount()
end
function Lobby_Mid_Activity_UIBP:IsCanShowSpecialOfferBubble()
  if self.specialOffer_Entrance_UIBP or self.airdropCarnival_Entrance_UIBP then
    return false
  end
  local logic_lobby_mid_activity_ui = require("client.slua.umg.lobby.logic.LobbyMidActivity.logic_lobby_mid_activity_ui")
  local EntryCfg = logic_lobby_mid_activity_ui.GetEntryUICfg()
  if EntryCfg then
    return false
  end
  local SpecialOfferBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SpecialOfferBubbleModule)
  local act_info = SpecialOfferBubbleModule:GetActData()
  if act_info and SpecialOfferBubbleModule:CheckBubbleCanShow() then
    return false
  end
  return true
end
function Lobby_Mid_Activity_UIBP:UpdateXmissionGuide()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
  local bCheckGuide = growthprojectMgrB.CheckGuideStep(GuideType, 0)
  if bCheckGuide then
    local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
    local mcNewbieActivityTip = newbie_guide_util.GetMCNewbieActivityTip()
    if mcNewbieActivityTip then
      log_warning(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateXmissionGuide return mcNewbieActivityTip")
      return
    end
    logic_connection_waiting:Show(0, false)
    local time_ticker = require("common.time_ticker")
    local timer = time_ticker.AddTimerOnce(1, function()
      logic_connection_waiting:Hide(0)
    end)
    if UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP) then
      UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
    end
    local bannerZOrder, banner, bannerParent, bannerParentZOrder
    if LobbySystem.CheckUseNewGuide() then
      local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
      if ui then
        banner = ui.UIRoot.Border_MidActivity
        if banner then
          bannerZOrder = banner.Slot:GetZOrder()
          banner.Slot:SetZOrder(bannerZOrder + 10)
        end
        bannerParent = ui.UIRoot.Border3
        if bannerParent then
          bannerParentZOrder = banner.Slot:GetZOrder()
          bannerParent.Slot:SetZOrder(bannerParentZOrder + 10)
        end
      end
    end
    self:AddTimerOnce(1, function()
      local cb = function()
        self:PlayAudio(sound_config.new_activityBtn)
        growthprojectMgrB.SaveGuideInfo(GuideType, 1)
        EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE)
        if LobbySystem.CheckUseNewGuide() then
          self:SetWidgetVisible(self.UIRoot.GuidePanel, false)
          self.UIRoot:StopAnimation(self.UIRoot.Animation_Mask)
          self.UIRoot:StopAnimation(self.UIRoot.Animation_HandLoop)
          if bannerZOrder and banner then
            banner.Slot:SetZOrder(bannerZOrder)
          end
          if bannerParentZOrder and bannerParent then
            bannerParent.Slot:SetZOrder(bannerParentZOrder)
          end
        end
        UIManager.ShowUI(UIManager.UI_Config.Activity_Newbie_Main)
      end
      if LobbySystem.CheckUseNewGuide() then
        local guidePanel = self.UIRoot.GuidePanel
        self:SetWidgetVisible(guidePanel, true, true)
        self.UIRoot.GuideTip:SetText(LocUtil.GetLocalizeResStr(27325))
        self:AddTimerOnce(0, function()
          local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
          local bannerCanvasPanel = self.UIRoot.CanvasPanel_1
          if bannerCanvasPanel then
            local canvasSlots = WidgetLayoutLibrary.SlotAsCanvasSlot(bannerCanvasPanel)
            if canvasSlots then
              local offset = canvasSlots:GetOffsets()
              local top = offset.top
              local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(guidePanel)
              if slot then
                slot:SetOffsets(FMargin(0, top, 0, 0))
              end
            end
          end
          self:PlayUserWidgetAnimation(self.UIRoot.Animation_Mask, 0, 1, 0, 1)
          self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand_Loop, 0, 0, 0, 1)
          self:AddOnClickedEventByControl(self.UIRoot.GuideBtn, cb)
        end)
      else
        local txt = LocUtil.GetLocalizeResStr(12753)
        local widget = self.UIRoot.Panel_Activity
        UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 0, txt, widget, cb, true, 2)
      end
    end)
  end
end
function Lobby_Mid_Activity_UIBP:UpdateNewbieUI()
  log(bWriteLog and "after update activity")
  self:AddTimerOnce(0, function()
    local ui = UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP)
    if ui then
      log(bWriteLog and "after update activity, update newbie ui")
      ui:UpdateUI()
    end
  end)
  self:UpdateSpecialAct()
  self:UpdateActicityCenterBtn()
  self:UpdateRpAndSaleEntryUI()
end
function Lobby_Mid_Activity_UIBP:OnButton_SpecialActice()
  self:PlayAudio(sound_config.new_activityBtn)
  local ActivityNewCenter = require("client.slua.logic.activity.logic_activity_center")
  local data = ActivityNewCenter.GetImportentActData()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime > data.nNotShowTime then
    ShowNotice(118100002)
    return
  end
  if nowTime < data.nEndTime then
    ShowNotice(42926)
    return
  end
  if data.isGoExchange == 1 then
    local StoreKit = require("client.slua.logic.app_store.logic_storekit")
    StoreKit:RequestReview()
    return
  end
  ActivityNewCenter.JumpUrl(data.sJumpUrl)
end
function Lobby_Mid_Activity_UIBP:OnButton_SpecialDiscount()
  self:PlayAudio(sound_config.new_activityBtn)
  local specialDiscountConfig = self:GetEntranceConfig(ENTRY_ID_SPECIAL_OFFER)
  if specialDiscountConfig and specialDiscountConfig.jumpUrl and specialDiscountConfig.jumpUrl ~= "" then
    GlobalData.JumpUrl(specialDiscountConfig.jumpUrl)
  else
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    special_offer_module:OpenOneAct()
  end
  logic_lobby_mid_entrance.OnEntranceClicked(ENTRY_ID_SPECIAL_OFFER)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SpecialOffer, 0)
end
function Lobby_Mid_Activity_UIBP:WhenTeamChange()
  self:UpdateSpecialAct()
end
function Lobby_Mid_Activity_UIBP:UpdateSpecialActEvent(_, _, changes)
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateSpecialActEvent")
  local types = changes and changes.typeList
  if types and types[ActivityType.ACTIVITY_TYPE_LINK] then
    self:UpdateSpecialAct()
  end
end
function Lobby_Mid_Activity_UIBP:UpdateSpecialAct()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    self.UIRoot.Button_SpecialActice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetSpecialActivityBubbleStatus(false)
    return
  end
  local ActivityNewCenter = require("client.slua.logic.activity.logic_activity_center")
  local data = ActivityNewCenter.GetImportentActData()
  if not data.bHasAct then
    self.UIRoot.Button_SpecialActice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:SetSpecialActivityBubbleStatus(false)
    return
  else
    self.UIRoot.Button_SpecialActice:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:SetSpecialActivityBubbleStatus(true)
  end
  self:SetTexture(self.UIRoot.Image_Activice_CDN, data.sImageUrl)
  local TimeUtil = require("client.common.time_util")
  local updateFunc = function()
    local nowTime = TimeUtil.GetServerTimeInSec()
    local nowLastTime = data.nEndTime - nowTime
    self.UIRoot.SpecialActice_Time:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_CountDown:SetText(ActivityNewCenter.GetTimeStr(nowLastTime, 1))
  end
  local endFunc = function()
    self.UIRoot.SpecialActice_Time:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:CloseSpecialActClock()
  local now = TimeUtil.GetServerTimeInSec()
  if data.nEndTime - now >= 0 then
    self.UpdateSpecialActClock = self:AddClock(data.nEndTime, updateFunc, endFunc)
  else
    endFunc()
  end
end
function Lobby_Mid_Activity_UIBP:CloseSpecialActClock()
  if self.UpdateSpecialActClock then
    self:RemoveClock(self.UpdateSpecialActClock)
    self.UpdateSpecialActClock = nil
  end
end
function Lobby_Mid_Activity_UIBP:UpdateSpecialDiscount()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local isFinished = growthprojectMgrB.IsFinishAllNewGuideAndBanner()
  log(bWriteLog and string.format("Lobby_Mid_Activity_UIBP:UpdateSpecialDiscount. bShow:%s", tostring(isFinished)))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialDiscount, isFinished)
end
local wordWidgets = {
  "CanvasPanel_New",
  "CanvasPanel_ReturnWord",
  "CanvasPanel_Sale",
  "CanvasPanel_Act"
}
function Lobby_Mid_Activity_UIBP:UpdateActicityCenterBtn()
  self:UpdateActivityEntryByConfig()
  self:UpdateSpecialDiscount()
end
function Lobby_Mid_Activity_UIBP:GetEntranceConfig(entryType)
  if logic_lobby_mid_entrance.HasData() then
    local validConfigs = {}
    local actConfig = logic_lobby_mid_entrance.GetEntranceConfig(entryType)
    if actConfig then
      validConfigs = {
        entryId = entryType,
        priority = actConfig.priority or 0,
        staticImage = actConfig.static_pic_url or "",
        textContent = actConfig.text or "",
        jumpUrl = actConfig.jump_url or ""
      }
    end
    if next(validConfigs) then
      return validConfigs
    end
  end
end
function Lobby_Mid_Activity_UIBP:GetRpDisplayConfig()
  local rpConfig = self:GetEntranceConfig(ENTRY_ID_RP)
  local bpConfig = self:GetEntranceConfig(ENTRY_ID_BP)
  local shouldShowBP = UnknowPassSystem.IsInCurSession and UnknowPassSystem.Level == 100 and UnknowPassSystem.IsBuyElite and self:IsBonusPassOpen() and bpConfig
  if shouldShowBP then
    if self.UIRoot.TextBlock_66 then
      self.UIRoot.TextBlock_66:SetText("BP")
    end
    return bpConfig
  end
  if self.UIRoot.TextBlock_66 then
    self.UIRoot.TextBlock_66:SetText("RP")
  end
  return rpConfig
end
function Lobby_Mid_Activity_UIBP:UpdateActivityEntryByConfig()
  local config = self:GetEntranceConfig(ENTRY_ID_ACTIVITY)
  if config then
    if config.staticImage and config.staticImage ~= "" then
      self:SetTexture(self.UIRoot.Image_Act, config.staticImage)
    end
    if config.textContent and config.textContent ~= "" then
      self.UIRoot.TextBlock_0:SetText(config.textContent)
    end
  end
end
function Lobby_Mid_Activity_UIBP:UpdateRpAndSaleEntryUI()
  if self._rpImageDownloadIndex then
    self:CancelImageDownloadByIndex(self._rpImageDownloadIndex)
    self._rpImageDownloadIndex = nil
  end
  if self._specialOfferImageDownloadIndex then
    self:CancelImageDownloadByIndex(self._specialOfferImageDownloadIndex)
    self._specialOfferImageDownloadIndex = nil
  end
  local RPConfig = self:GetRpDisplayConfig()
  local SpecialOfferConfig = self:GetEntranceConfig(ENTRY_ID_SPECIAL_OFFER)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local isNewbie = not growthprojectMgrB.IsFinishAllNewGuideAndBanner()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialDiscount, not isNewbie, true)
  if isNewbie then
    self:UpdateRpEntryForNewbie(RPConfig)
  else
    self:UpdateRpEntryNormal(RPConfig, SpecialOfferConfig)
  end
end
function Lobby_Mid_Activity_UIBP:UpdateRpEntryForNewbie(RPConfig)
  local layoutIndex = LAYOUT_NEWBIE
  if RPConfig and RPConfig.staticImage and RPConfig.staticImage ~= "" then
    layoutIndex = LAYOUT_RP
    self:SetWidgetVisible(self.UIRoot.Lobby_Activity_RP_Item_C_3, true)
    self:SetRpButtonStyle(self.UIRoot.Lobby_Activity_RP_Item_C_3)
    self._rpImageDownloadIndex = self:SetTexture(self.UIRoot.Image_8, RPConfig.staticImage)
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateRpEntryForNewbie RPConfig.staticImage: " .. RPConfig.staticImage)
    self.UIRoot.TextBlock_7:SetText(RPConfig.textContent or "")
  end
  if RPConfig and RPConfig.textContent and RPConfig.textContent ~= "" then
    self:SetWidgetVisible(self.UIRoot.Lobby_Activity_RP_Item_C_2, true)
    self.UIRoot.TextBlock_16:SetText(RPConfig.textContent)
    self:SetRpButtonStyle(self.UIRoot.Lobby_Activity_RP_Item_C_2)
  elseif not RPConfig then
    self:SetWidgetVisible(self.UIRoot.Lobby_Activity_RP_Item_C_2, true)
    self:SetRpButtonStyle(self.UIRoot.Lobby_Activity_RP_Item_C_2)
  end
  self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(layoutIndex)
end
function Lobby_Mid_Activity_UIBP:UpdateRpEntryNormal(RPConfig, SpecialOfferConfig)
  local layoutIndex = LAYOUT_DEFAULT
  if RPConfig and SpecialOfferConfig then
    layoutIndex = RPConfig.priority > SpecialOfferConfig.priority and LAYOUT_RP or LAYOUT_SPECIAL_OFFER
  elseif RPConfig then
    layoutIndex = LAYOUT_RP
  elseif SpecialOfferConfig then
    layoutIndex = LAYOUT_SPECIAL_OFFER
  end
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(layoutIndex)
  self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(layoutIndex)
  if layoutIndex == LAYOUT_RP then
    self:SetWidgetVisible(self.UIRoot.Lobby_Activity_RP_Item_C_3, false, true)
    self._rpImageDownloadIndex = self:SetTexture(self.UIRoot.Image_8, RPConfig.staticImage)
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateRpEntryNormal RPConfig.staticImage: " .. RPConfig.staticImage)
    self.UIRoot.TextBlock_7:SetText(RPConfig.textContent or "")
  elseif layoutIndex == LAYOUT_SPECIAL_OFFER then
    self._specialOfferImageDownloadIndex = self:SetTexture(self.UIRoot.Image_6, SpecialOfferConfig.staticImage)
    self.UIRoot.TextBlock_2:SetText(SpecialOfferConfig.textContent or "")
    self:SetRpButtonStyle(self.UIRoot.Lobby_Activity_RP_Item)
  elseif layoutIndex == LAYOUT_DEFAULT then
    self:SetRpButtonStyle(self.UIRoot.Lobby_Activity_RP_Item_C_0)
  end
end
function Lobby_Mid_Activity_UIBP:OnRefreshRPDownloadBtn()
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
function Lobby_Mid_Activity_UIBP:GetActivityConfigData()
  local activityConfig = require("client.slua.logic.activity.activity_config")
  local cfg_data = {}
  for i, cfg in ipairs(activityConfig) do
    if type(cfg.moduleName) ~= "string" then
      return
    end
    local data = activityConfig.DoAction(i, cfg)
    if data then
      if 0 < #data then
        for i, subData in ipairs(data) do
          if not cfg_data[i] then
            cfg_data[i] = {}
          end
          cfg_data[i].data = subData
          cfg_data[i].        end
      else
        if not cfg_data[i] then
          cfg_data[i] = {}
        end
        cfg_data[i].        cfg_data[i].      end
    end
  end
  return cfg_data
end
function Lobby_Mid_Activity_UIBP:IsActivityConfigRedDot()
  log(bWriteLog and "IsActivityConfigRedDot")
  for i, v in pairs(self.activityConfig) do
    if v.data then
      local redDotNum
      if type(v.data.nRedDotNum) == "function" then
        redDotNum = v.data.nRedDotNum()
      else
        redDotNum = v.data.nRedDotNum
      end
      if 1 < redDotNum then
        return true
      end
      if type(v.data.bRedDot) == "function" then
        return v.data.bRedDot()
      end
      return v.data.bRedDot
    end
  end
  return false
end
function Lobby_Mid_Activity_UIBP:UpdateActRed()
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(1001300) then
    return
  end
  ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Activity)
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local SystemRedDot = ActivityRedDot.GetRedDotData(reddot_macro.SystemName.ActivityCenter)
  if SystemRedDot then
    self:RegistReddotWidget(self.UIRoot.Image_ActivityNewTips)
    self.UIRoot.Image_ActivityNewTips:Bind(SystemRedDot)
  end
end
function Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate(_, __, bShow)
  log(bWriteLog and string.format("Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate Show : %s", bShow))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBubbleShowTime)
  if bShow and not self.bShowSubscribeBubble then
    if self.UIRoot.Reddot_Anchor_Item12:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
      log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate Bubble has already shown!")
      return
    end
    if self:CheckIsNewArrivalsReddot() then
      self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      return
    end
    if data == nil or data == {} or data == 0 or type(data) ~= "table" then
      log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate has not exist showTime record!")
      data = {
        time = TimeUtil.GetServerTimeInSec(),
        bDisappear = false
      }
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBubbleShowTime)
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
      log(bWriteLog and string.format("Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate showTime : %s, currentTime : %s, ShowBubble : %s", tostring(showDate), tostring(currentDate), tostring(bShowBubble)))
      if currentDate ~= showDate or currentDate == showDate and bShowBubble then
        log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate show bubble!")
        data.time = currentTime
        data.bDisappear = false
        PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBubbleShowTime)
        self.UIRoot.Reddot_Anchor_Item12:PlayUserWidgetAnimation(self.UIRoot.Reddot_Anchor_Item12.Breathing, 0, 0, 0, 1)
        self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.bShowSubscribeBubble = true
      else
        log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate don't show bubble!")
      end
    end
  elseif self.UIRoot.Reddot_Anchor_Item12:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnSubscribeBubbleUpdate hide the bubble")
    data = {}
    data.time = TimeUtil.GetServerTimeInSec()
    data.bDisappear = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSpecialOfferBubbleShowTime)
    self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.bShowSubscribeBubble = false
  end
end
function Lobby_Mid_Activity_UIBP:CheckIsNewArrivalsReddot()
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  local red = special_offer_module:GetRedDot()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  if not (red and red.category) or not red.newCount then
    return false
  end
  if red.category ~= reddot_macro.Category.NewArrivals then
    return false
  end
  if not red.pages then
    return false
  end
  return true
end
function Lobby_Mid_Activity_UIBP:CheckSpecialOfferDataReady()
  local store_subscribe_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
  if store_subscribe_data:ReqGiftData() then
    self:BindSpecialOfferRed()
  end
end
function Lobby_Mid_Activity_UIBP:UpdateLobbySpecialReddot(_, _)
  self:BindSpecialOfferRed()
end
function Lobby_Mid_Activity_UIBP:OnCommerceEntranceUpdate()
  self:UpdateActivityEntryByConfig()
  self:UpdateRpAndSaleEntryUI()
end
function Lobby_Mid_Activity_UIBP:BindSpecialOfferRed()
  self:RegistReddotWidget(self.UIRoot.Reddot_Anchor_C_0)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  local red = special_offer_module:GetRedDot()
  local redWidget = self.UIRoot.Reddot_Anchor_C_0
  redWidget:Bind(red)
  if self.bShowSubscribeBubble then
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:BindSpecialOfferRed Is Show Subscribe Bubble, Hide the red dot!")
    self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Reddot_Anchor_Item12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Reddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    StoreLimitedSubscribeData:CheckBubbleShow(false)
  end
end
function Lobby_Mid_Activity_UIBP:UpdateBtnEightDay()
  self:UpdateActicityCenterBtn()
end
function Lobby_Mid_Activity_UIBP:OnClose()
  self:HideBubble()
  self.activityConfig = nil
  self:RemoveAdBubbleEntry()
  if self.uRemainTimer then
    self:RemoveTimer(self.uRemainTimer)
    self.uRemainTimer = nil
  end
  self:RPLobbyBubbleClose()
  Lobby_Mid_Activity_UIBP.__super.OnClose(self)
end
function Lobby_Mid_Activity_UIBP:OnButton_ActivityClick()
  self:PlayAudio(sound_config.new_activityBtn)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ACTIVITY, true) then
    return
  end
  local last_ts = LobbySystem.roleData.last_open_act_center_ts
  local TimeUtil = require("client.common.time_util")
  local start_ts = TimeUtil.GetTodayStartTimestamp()
  local notSameDay = false
  if start_ts and last_ts then
    notSameDay = not TimeUtil.IsSameDay(last_ts, start_ts)
  end
  local ActivityCenterTabModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterTabModule)
  ActivityCenterTabModule:ReqActCenterTabConfig()
  local activityConfig = self:GetEntranceConfig(ENTRY_ID_ACTIVITY)
  if activityConfig and activityConfig.jumpUrl and activityConfig.jumpUrl ~= "" then
    GlobalData.JumpUrl(activityConfig.jumpUrl)
  else
    local jump_utils = require("client.logic.store.jump_utils")
    local url = jump_utils.GenerateGameUrl(BP_ENUM_MODULE_ACTIVITY)
    GlobalData.JumpUrl(url)
  end
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  local curTime = TimeUtil.GetServerTimeInSec()
  LobbySystem.roleData.last_open_act_center_ts = curTime
  ActivityHandler.send_report_last_open_act_center_ts(curTime)
  logic_lobby_mid_entrance.OnEntranceClicked(ENTRY_ID_ACTIVITY)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyEventCenter)
end
function Lobby_Mid_Activity_UIBP:ShowLobbyBubble(_, __, status)
  if status then
    if self.ActivityBubbleTipsUI then
      self.ActivityBubbleTipsUI:CloseSelf()
      self.ActivityBubbleTipsUI = nil
    end
    self.ActivityBubbleTipsUI = self:CreateChildWindow(self.UIRoot.ActivityBubbleRoot, UIManager.UI_Config.Lobby_Mid_Activity_Tips_UIBP)
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:ShowActivityBubble")
  else
    if self.ActivityBubbleTipsUI then
      self.ActivityBubbleTipsUI:CloseSelf()
      self.ActivityBubbleTipsUI = nil
    end
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:HideActBubble")
  end
end
function Lobby_Mid_Activity_UIBP:ShowActivityBubble(_, __, status)
  if status then
    if self.ActivityBubbleTipsUI then
      self.ActivityBubbleTipsUI:CloseSelf()
      self.ActivityBubbleTipsUI = nil
    end
    self.ActivityBubbleTipsUI = self:CreateChildWindow(self.UIRoot.ActivityBubbleRoot, UIManager.UI_Config.Lobby_Mid_Activity_Tips_UIBP)
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:ShowActivityBubble")
  else
    if self.ActivityBubbleTipsUI then
      self.ActivityBubbleTipsUI:CloseSelf()
      self.ActivityBubbleTipsUI = nil
    end
    log(bWriteLog and "Lobby_Mid_Activity_UIBP:HideActivityBubble")
  end
end
function Lobby_Mid_Activity_UIBP:HideBubble()
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:HideBubble")
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.Activity)
  self:SetSpecialOfferTipsBubbleStatus(false)
  self:SetSpecialOfferEntranceBubbleStatus(false)
  self:SetSuperAirDropBubbleStatus(false)
  self:SetSpecialActivityBubbleStatus(false)
end
function Lobby_Mid_Activity_UIBP:SetSpecialOfferTipsBubbleStatus(status)
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  if status then
    LobbyBubbleManager:ShowBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialOfferTips)
  else
    LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialOfferTips)
  end
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:SetSpecialOfferBubbleStatus" .. tostring(status))
end
function Lobby_Mid_Activity_UIBP:SetSpecialOfferEntranceBubbleStatus(status)
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  if status then
    LobbyBubbleManager:ShowBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialOfferEntrance)
  else
    LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialOfferEntrance)
  end
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:SetSpecialOfferBubbleStatus" .. tostring(status))
end
function Lobby_Mid_Activity_UIBP:SetSuperAirDropBubbleStatus(status)
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  if status then
    LobbyBubbleManager:ShowBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SuperAirDrop)
  else
    LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SuperAirDrop)
  end
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:SetSpecialOfferBubbleStatus" .. tostring(status))
end
function Lobby_Mid_Activity_UIBP:SetSpecialActivityBubbleStatus(status)
  local LobbyBubbleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyBubbleManager)
  local Enum_Bubble_Queue_Type = LobbyBubbleManager:GetBubbleQueueType()
  local Enum_Bubble_Type = LobbyBubbleManager:GetBubbleType(Enum_Bubble_Queue_Type.Middle)
  if status then
    LobbyBubbleManager:ShowBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialActivityEntrance)
  else
    LobbyBubbleManager:HideBubble(Enum_Bubble_Queue_Type.Middle, Enum_Bubble_Type.SpecialActivityEntrance)
  end
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:SetSpecialActivityBubbleStatus" .. tostring(status))
end
function Lobby_Mid_Activity_UIBP:OnGetWeddingActivityEntry()
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnGetWeddingActivityEntry")
  self:UpdateWeddingActivityEntry()
end
function Lobby_Mid_Activity_UIBP:OnWeddingActivityEntryOutOfDate()
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:OnWeddingActivityEntryOutOfDate")
  self:UpdateWeddingActivityEntry()
end
function Lobby_Mid_Activity_UIBP:GetLobbyEntryConfig()
end
function Lobby_Mid_Activity_UIBP:SetRpButtonStyle(RPItem)
  if not RPItem then
    return
  end
  if not UnknowPassSystem.IsInCurSession then
    RPItem.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    RPItem.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if UnknowPassSystem.Level == 100 then
    if UnknowPassSystem.IsBuyElite then
      if self:IsBonusPassOpen() then
        RPItem.WidgetSwitcher_RP:SetActiveWidgetIndex(1)
      else
        RPItem.WidgetSwitcher_RP:SetActiveWidgetIndex(0)
      end
    else
      RPItem.WidgetSwitcher_RP:SetActiveWidgetIndex(2)
    end
  else
    RPItem.WidgetSwitcher_RP:SetActiveWidgetIndex(0)
  end
end
function Lobby_Mid_Activity_UIBP:OnButton_RPClick(jump)
  self.UIRoot.WidgetSwitcher_PassReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.CheckCanShowPass() == false then
    return
  end
  self:PlayAudio(sound_config.new_rpBtn)
  logic_lobby_mid_entrance.OnEntranceClicked(ENTRY_ID_RP)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyRP)
  local rpConfig = self:GetRpDisplayConfig()
  if rpConfig and rpConfig.jumpUrl and rpConfig.jumpUrl ~= "" then
    GlobalData.JumpUrl(rpConfig.jumpUrl)
  else
    Client.StartUIStat("\233\128\154\232\161\140\232\175\129")
    if UnknowPassSystem.Level == 100 and UnknowPassSystem.IsBuyElite and self:IsBonusPassOpen() then
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      local panelType = PassDataSystem.GetPanelType()
      PassDataSystem.SetCurPanelType(panelType.BranchRp)
    end
    UnknowPassTunnelSystem.ShowRP(jump)
    Client.StopUIStat("\233\128\154\232\161\140\232\175\129")
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_Pass)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Pass)
  end)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHaveClickRPGuide) or {}
  if not table.eHaveClickRPGuide then
    table.eHaveClickRPGuide = true
    PlayerPrefsSystem.SaveTableToFile_N(table, PlayerPrefsSystem.ePlayerPrefsType.eHaveClickRPGuide)
  end
  if self.uRemainTimer then
    self:RemoveTimer(self.uRemainTimer)
    self.uRemainTimer = nil
  end
end
function Lobby_Mid_Activity_UIBP:UpdateUnknowPassReddot(isShow)
  local UnknowPassRedPointData = require("client.slua.logic.unknow_pass.RedPoint.unknowpass_redpoint_data")
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  local redPoint = UnknowPassRedPointData.GetRedPointSuperData()
  if redPoint then
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor)
    self.UIRoot.Reddot_Anchor:Bind(redPoint)
  end
  local bCurShow = false
  if UnknowPassSystem.IsInCurSession then
    bCurShow = passReddotMainSystem.CanShowReddot() or isShow
  else
    log(bWriteLog and "force hide RP reddot")
    bCurShow = false
    if redPoint then
      redPoint.newCount = 0
    end
  end
  if bCurShow then
    local bCurShowType = passReddotMainSystem.ShowReddotType()
    self.WidgetSwitcher_PassReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.WidgetSwitcher_PassReddot:SetActiveWidgetIndex(bCurShowType)
    if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10601) then
      return
    end
  else
    self.UIRoot:StopAnimation(self.UIRoot.RP_Warning)
    self.WidgetSwitcher_PassReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Activity_UIBP:IsBonusPassOpen()
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  local seasonInfo = Logic_BonusPass:GetBranchSeasonData()
  if not seasonInfo then
    Logic_BonusPass:InitSeasonControlCfg()
  end
  seasonInfo = Logic_BonusPass:GetBranchSeasonData()
  if not seasonInfo then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local realStartTime = TimeUtil.TimeStringToUnixstamp(seasonInfo.realStartTime)
  if realStartTime <= TimeUtil.GetServerTimeInSec() then
    return true
  end
  return false
end
function Lobby_Mid_Activity_UIBP:OnPassDataUpdate()
  if self.is_need_update_rp_bubble then
    self:UpdateRpCouponBubble()
    self.is_need_update_rp_bubble = false
  end
  self:UpdateRpAndSaleEntryUI()
end
function Lobby_Mid_Activity_UIBP:OnPassScoreChanged()
  self:UpdateRpAndSaleEntryUI()
end
function Lobby_Mid_Activity_UIBP:ToggleRPBubbleShow(show)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    self:SetWidgetVisible(self.UIRoot.Panel_FirstCharge, false)
    return
  end
  self:SetWidgetVisible(self.UIRoot.Panel_FirstCharge, true)
end
function Lobby_Mid_Activity_UIBP:UpdateUnknowPassReddotByEvent(eventType, eventID, isShow)
  self:UpdateUnknowPassReddot(isShow)
end
function Lobby_Mid_Activity_UIBP:OnSwitchToPageStart(_, _, toPage)
  self:SetWidgetVisible(self.UIRoot.Button_RP, toPage == 1, true)
end
function Lobby_Mid_Activity_UIBP:GetTipsMacroAndManager()
  local TipsMacro = require("client.slua.logic.tip.TipsMacro")
  local TipsManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.TipsManager)
  return TipsMacro, TipsManager
end
function Lobby_Mid_Activity_UIBP:ShowRPLobbyBubble(_, _, bubble_data)
  log_tree("xcc Lobby_Mid_Activity_UIBP:ShowRPLobbyBubble", bubble_data)
  local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
  local type = bubble_data.from_type
  local TipsMacro, TipsManager = self:GetTipsMacroAndManager()
  local bShow = true
  if type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Shop then
    bubble_data.tipId = TipsMacro.ENUM_TipID.Shop
    TipsManager:PushTip(bubble_data)
  elseif type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Supply then
    bubble_data.tipId = TipsMacro.ENUM_TipID.Shop
    bubble_data.offset = {x = -75, y = 0}
    TipsManager:PushTip(bubble_data)
  elseif type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Rp or type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Rp_CriticalHit then
    self:ShowRPBubbleUI(bubble_data)
  elseif type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Rp_Season_End then
    local cdnNum = tonumber(bubble_data.cdn)
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    local seasonLastDay = PassDataSystem.GetSeasonLastDay()
    self:ShowRPBubbleUI(bubble_data, LocUtil.LocalizeResFormat(cdnNum, seasonLastDay))
  else
    if type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.RP_Experience then
      bubble_data.tipId = TipsMacro.ENUM_TipID.RPExperienceBubble
      TipsManager:PushTip(bubble_data)
    end
    bShow = false
  end
  if bShow then
    self.curItemID = bubble_data.item_id
  end
  self.bubbleTipType = bubble_data.tipId
end
function Lobby_Mid_Activity_UIBP:ShowRPLobbyBubbleQueue(_, _, bubble_data)
  log(bWriteLog and "Lobby_Mid_Activity_UIBP:ShowRPLobbyBubbleQueue " .. bubble_data.tipId)
  local TipsMacro, TipsManager = self:GetTipsMacroAndManager()
  TipsManager:SetTipsShowing(bubble_data.tipId)
  if bubble_data.tipId == TipsMacro.ENUM_TipID.RPBubble then
    if UnknowPassSystem.Level == 100 and not UnknowPassSystem.IsBuyElite then
      self.bubbleUIRoot = self:CreateChildWindow("CanvasPanel_Rp", UIManager.UI_Config.Lobby_Mid_Shop_BranchRP_Item_UIBP)
    elseif bubble_data and bubble_data.cdn and bubble_data.cdn ~= "" then
      self:ToggleRPBubbleShow(true)
    else
      self:ShowRPExperienceOrActBubble(bubble_data)
    end
  elseif bubble_data.tipId == TipsMacro.ENUM_TipID.RPExperienceBubble then
    self.bubbleUIRoot = self:CreateChildWindow("CanvasPanel_Rp", UIManager.UI_Config.Lobby_Mid_Bubble_RP_Limit_UIBP)
  elseif bubble_data.tipId == TipsMacro.ENUM_TipID.Shop then
  end
end
function Lobby_Mid_Activity_UIBP:ShowRPBubbleUI(bubble_data, showText)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.is_experience == 1 then
    log(bWriteLog and "Is in Experience status")
    return
  end
  local TipsMacro, TipsManager = self:GetTipsMacroAndManager()
  bubble_data.tipId = TipsMacro.ENUM_TipID.RPBubble
  bubble_data.  TipsManager:PushTip(bubble_data)
end
function Lobby_Mid_Activity_UIBP:ShowRPExperienceOrActBubble(bubble_data)
  local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
  if bubble_data.bubble_type and bubble_data.bubble_type == LobbyBubbleConfig.Enum_Rp_Bubble_Type.Act then
    local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
    local type = UnknowPassMacro.Enum_ActCollect_BubbleEnter_Define.Lobby
    bubble_data.duration = UnknowPassMacro.Enum_ActCollect_Bubble_Time[type]
  else
    bubble_data.bubble_type = LobbyBubbleConfig.Enum_Rp_Bubble_Type.Item
  end
  self.bubbleUIRoot = self:CreateChildWindow("CanvasPanel_Rp", UIManager.UI_Config.Lobby_Mid_Bubble_RP_UIBP, bubble_data)
end
function Lobby_Mid_Activity_UIBP:OnRPLobbyBubbleClose(_, _)
  self:RPLobbyBubbleClose()
end
function Lobby_Mid_Activity_UIBP:RPLobbyBubbleClose(bHideRpOnly)
  local TipsMacro, TipsManager = self:GetTipsMacroAndManager()
  local bNeedHide = bHideRpOnly and self.bubbleTipType and (self.bubbleTipType == TipsMacro.ENUM_TipID.RPBubble or self.bubbleTipType == TipsMacro.ENUM_TipID.RPExperienceBubble) or false
  if not bHideRpOnly or bNeedHide then
    if self.bubbleTipType then
      TipsManager:CloseTip(self.bubbleTipType)
    end
    if self.bubbleUIRoot then
      self.bubbleUIRoot:CloseSelf()
    end
    self.bubbleTipType = nil
    self.bubbleUIRoot = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Activity_UIBP = class(ui_base, nil, Lobby_Mid_Activity_UIBP)
return CLobby_Mid_Activity_UIBP
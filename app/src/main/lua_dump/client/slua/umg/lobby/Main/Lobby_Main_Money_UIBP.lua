local Lobby_Main_Money_UIBP = {}
local black = FSlateColor(FLinearColor(0, 0, 0, 0.8))
local white = FSlateColor(FLinearColor(1, 1, 1, 1))
local CLobby_Mid_Subscribe_UIBP = require("client.slua.umg.lobby.Mid.Lobby_Mid_Subscribe_UIBP")
function Lobby_Main_Money_UIBP:ctor()
end
function Lobby_Main_Money_UIBP:OnInitialize()
  Lobby_Main_Money_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.TextBlock_diamond = self.UIRoot.TextBlock_diamond
  self.Button_Diamond = self.UIRoot.Button_Diamond
  self.Txt_uc = self.UIRoot.Txt_uc
  self.Btn_UC = self.UIRoot.Btn_UC
  self.Lobby_Mid_Subscribe_UIBP = CLobby_Mid_Subscribe_UIBP()
  self.Lobby_Mid_Subscribe_UIBP:InitWithParentWidget(self, self.UIRoot.Lobby_Mid_Subscribe_UIBP)
end
function Lobby_Main_Money_UIBP:RegistEvents()
  Lobby_Main_Money_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Diamond, self.OnButton_DiamondClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_Zhupai, self.OnButton_ZhupaiClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_Silver, self.OnButton_SilverClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_UC, self.OnBtn_UCClick, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.UpdateMoney, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, self.UpdateMoney, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ETERNAL_DIAMOND_CHANGE, self.UpdateMoney, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, self.UpdateMoney, self)
  self:AddCommonEvent(EVENTTYPE_SEASON_RECHARGE, EVENTID_SEASON_RECHARGE_INFO, self.RefreshUCFirstRechargeShow, self)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_THE_FIRST_CHARGE_INFO_CHANGE, self.RefreshUCFirstRechargeShow, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_subscribe, self.OnButton_SubscribeClicked, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, self.UpdatePrimeEnterVisible, self)
end
function Lobby_Main_Money_UIBP:OnPostInitialize()
  Lobby_Main_Money_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Lobby_Main_Money_UIBP:UpdateUI()
  self:UpdateMoney()
  self:UpdatePrimeEnterVisible()
  self:UpdatePrimeRedDot()
end
function Lobby_Main_Money_UIBP:UpdateMoney()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local info = StoreUtils.GetMoneyInfo()
  self:RefreshUCFirstRechargeShow()
  local strText = FuncUtil.Conv_Int64ToText(info.nUC)
  self.UIRoot.Txt_uc:SetText(strText)
  strText = FuncUtil.Conv_Int64ToText(info.nSilver)
  self.UIRoot.TextBlock_silver:SetText(strText)
  if StoreUtils.CanShowDiamond() then
    self.UIRoot.CanvasPanel_Diamond:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    strText = FuncUtil.Conv_Int64ToText(info.nDiamond)
    self.UIRoot.TextBlock_diamond:SetText(strText)
  else
    self.UIRoot.CanvasPanel_Diamond:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if GlobalData.IsJapanOrKorea() then
    self.UIRoot.Btn_Zhupai:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    strText = FuncUtil.Conv_Int64ToText(info.nZhupai)
    self.UIRoot.Txt_zhupai:SetText(strText)
  else
    self.UIRoot.Btn_Zhupai:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_Money_UIBP:RefreshUCFirstRechargeShow(_, _)
  local TheFirstChargeSystem = require("client.slua.logic.recharge.logic_the_first_charge")
  local bIsShow = TheFirstChargeSystem.GetIsShowFirstRechargeUCBg()
  local node_root = self.UIRoot
  self:SetWidgetVisible(node_root.Canvas_NewSeasonRecharge, bIsShow)
  self:SetWidgetVisible(node_root.Image_NewSeasonRecharge, bIsShow)
  self.UIRoot.Txt_uc:SetColorAndOpacity(bIsShow and black or white)
end
function Lobby_Main_Money_UIBP:UpdatePrimeRedDot()
  if self.UIRoot.Reddot_Anchor then
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor)
    reddot_manager:BindSystemEntry(self, self.UIRoot.Reddot_Anchor, reddot_macro.SystemName.Prime)
  end
end
function Lobby_Main_Money_UIBP:OnButton_DiamondClick()
  log(bWriteLog and "Lobby_Main_Money_UIBP:OnButton_DiamondClick")
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("9885")
  local tipsParam = {
    widget = self.UIRoot.Button_Diamond,
    content = strContent,
    offsetY = 56,
    offsetX = -124
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
end
function Lobby_Main_Money_UIBP:OnButton_ZhupaiClick()
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("6616")
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.common_float_tips)
  local TipsParam = {
    offsetX = 20,
    offsetY = 115,
    wrapWidthType = 2,
    markType = tipsUI.Marktype.upmiddle
  }
  tipsUI:SetTips(self.UIRoot.Btn_Zhupai, strContent, TipsParam)
end
function Lobby_Main_Money_UIBP:OnButton_SilverClick()
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("6615")
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.common_float_tips)
  local TipsParam = {
    offsetX = 20,
    offsetY = 115,
    wrapWidthType = 2,
    markType = tipsUI.Marktype.upmiddle
  }
  tipsUI:SetTips(self.UIRoot.Btn_Silver, strContent, TipsParam)
end
function Lobby_Main_Money_UIBP:OnBtn_UCClick()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyRecharge)
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.EnterFrom = RechargeSystem.E_UcEntryType.FromUC
  RechargeSystem.OpenRechargeUI(false, true)
end
function Lobby_Main_Money_UIBP:UpdatePrimeEnterVisible()
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local bIsInMainCity = GameStatus.IsInMainCity()
  local isSubscribeOpen = subscribeModuleObj:CheckMenuOpen() and bIsInMainCity
  log(bWriteLog and "[v_wllwu] Lobby_Main_Money_UIBP:UpdatePrimeEnterVisible " .. tostring(isSubscribeOpen))
  self:SetWidgetVisible(self.UIRoot.Button_subscribe, isSubscribeOpen, true)
end
function Lobby_Main_Money_UIBP:OnButton_SubscribeClicked()
  self:PlayAudio(sound_config.click_v1)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySubscribe)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:ShowSubscribe()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Main_Money_UIBP = class(ui_base, nil, Lobby_Main_Money_UIBP)
return CLobby_Main_Money_UIBP
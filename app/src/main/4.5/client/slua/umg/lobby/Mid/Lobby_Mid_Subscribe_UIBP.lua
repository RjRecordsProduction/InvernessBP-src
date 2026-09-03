local Lobby_Mid_Subscribe_UIBP = {}
local PurchaseRewardState = {
  notPurchased = 1,
  purchasedNoReward = 2,
  purchasedWithReward = 3,
  allRewardsClaimed = 4
}
function Lobby_Mid_Subscribe_UIBP:ctor()
  self.FirstChargePurchaseRewardState = PurchaseRewardState.notPurchased
  self.LoginDays = 0
  self.NextLoginRewardDay = 0
end
function Lobby_Mid_Subscribe_UIBP:OnInitialize()
  Lobby_Mid_Subscribe_UIBP.__super.OnInitialize(self)
  self.Button_FirstCharge = self.UIRoot.Button_FirstCharge
  self.TextBlock_FirstChargeProgress = self.UIRoot.TextBlock_FirstChargeProgress
  self.Reddot_Anchor_Item01 = self.UIRoot.Reddot_Anchor_Item01
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, false, true)
end
function Lobby_Mid_Subscribe_UIBP:RegistEvents()
  Lobby_Mid_Subscribe_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Prime, self.OnButton_SubscribeClicked, self)
  self:AddOnClickedEventByControl(self.Button_FirstCharge, self.OnButton_FirstChargeClicked, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, self.UpdatePrimeEnterVisible, self)
  self:AddCommonEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, self.OnSpecialRedChange, self)
end
function Lobby_Mid_Subscribe_UIBP:OnPostInitialize()
  Lobby_Mid_Subscribe_UIBP.__super.OnPostInitialize(self)
  self:UpdatePrimeEnterVisible()
  self:UpdatePrimeRedDot()
end
function Lobby_Mid_Subscribe_UIBP:TestEntrance()
end
function Lobby_Mid_Subscribe_UIBP:TestFirstChargeState(state, loginDays, nextRewardDay)
  log(string.format("[TEST] \230\181\139\232\175\149\233\166\150\229\133\133\231\138\182\230\128\129: %s", tostring(state)))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, true, false)
  self.FirstChargePurchaseRewardState = state
  self.LoginDays = loginDays or 0
  self.NextLoginRewardDay = nextRewardDay or 0
  self:RefreshFirstChargeDetail()
end
function Lobby_Mid_Subscribe_UIBP:TestSubscribeState(status)
  log(string.format("[TEST] \230\181\139\232\175\149\232\174\162\233\152\133\231\138\182\230\128\129: %s", tostring(status)))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Prime, true, true)
end
function Lobby_Mid_Subscribe_UIBP:OnButton_SubscribeClicked()
  self:PlayAudio(sound_config.click_v1)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySubscribe)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:ShowSubscribe()
end
function Lobby_Mid_Subscribe_UIBP:OnButton_FirstChargeClicked()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.CondFirstCharge_Banner_UIBP)
end
function Lobby_Mid_Subscribe_UIBP:RefreshFirstChargeShow()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    log(bWriteLog and "Lobby_Mid_Subscribe_UIBP:RefreshFirstChargeShow. Not FIT Version")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, false, false)
    return
  end
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  local CanShowFirstCharge = logic_special_offer_condition:IsCanShowFirstCharge()
  if not CanShowFirstCharge then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, false, false)
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, true, false)
  self:UpdateFirstChargeStatus()
  self:RefreshFirstChargeDetail()
end
function Lobby_Mid_Subscribe_UIBP:UpdateFirstChargeStatus()
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  local PackageData = logic_special_offer_condition:GetFirstChargeData()
  if not PackageData then
    self.FirstChargePurchaseRewardState = PurchaseRewardState.notPurchased
    return
  end
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local GroupId = Gifts_Const.Enum_Condition_GiftGroup.FirstCharge
  self.LoginDays = logic_special_offer_condition:GetLoginDays(GroupId)
  local bIsSkipLogin = logic_special_offer_condition:IsSkipLoginByGroupId(GroupId)
  self.NextLoginRewardDay = 0
  local allNotPurchased = true
  for _, data in ipairs(PackageData) do
    if data.limitNum ~= 1 then
      allNotPurchased = false
      break
    end
  end
  if allNotPurchased then
    self.FirstChargePurchaseRewardState = PurchaseRewardState.notPurchased
    return
  end
  for _, data in ipairs(PackageData) do
    if data.limitNum == 1 then
      if self.LoginDays >= data.nConditionParam or bIsSkipLogin then
        self.FirstChargePurchaseRewardState = PurchaseRewardState.purchasedWithReward
        return
      else
        self.FirstChargePurchaseRewardState = PurchaseRewardState.purchasedNoReward
        self.NextLoginRewardDay = data.nConditionParam
        return
      end
    end
  end
  self.FirstChargePurchaseRewardState = PurchaseRewardState.allRewardsClaimed
end
function Lobby_Mid_Subscribe_UIBP:RefreshFirstChargeDetail()
  log(bWriteLog and string.format("Lobby_Mid_Subscribe_UIBP:RefreshFirstChargeDetail. State:%s", tostring(self.FirstChargePurchaseRewardState)))
  if self.FirstChargePurchaseRewardState == PurchaseRewardState.notPurchased then
    self:SetWidgetVisible(self.Reddot_Anchor_Item01, false, false)
    self:SetWidgetVisible(self.TextBlock_FirstChargeProgress, false, false)
  elseif self.FirstChargePurchaseRewardState == PurchaseRewardState.purchasedNoReward then
    self:SetWidgetVisible(self.Reddot_Anchor_Item01, false, false)
    self:SetWidgetVisible(self.TextBlock_FirstChargeProgress, true, false)
    self.TextBlock_FirstChargeProgress:SetText(LocUtil.LocalizeResFormat(6830, self.LoginDays, self.NextLoginRewardDay))
  elseif self.FirstChargePurchaseRewardState == PurchaseRewardState.purchasedWithReward then
    self:SetWidgetVisible(self.Reddot_Anchor_Item01, true, false)
    self:SetWidgetVisible(self.TextBlock_FirstChargeProgress, false, false)
  elseif self.FirstChargePurchaseRewardState == PurchaseRewardState.allRewardsClaimed then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_FirstCharge, false, false)
  end
end
function Lobby_Mid_Subscribe_UIBP:UpdatePrimeEnterVisible()
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local isSubscribeOpen = subscribeModuleObj:CheckMenuOpen() and LogicPufferBundle.IsFitLobbyResDownloaded()
  log(bWriteLog and "[Lobby_Mid_Subscribe_UIBP:UpdatePrimeEnterVisible isOpen:" .. tostring(isSubscribeOpen))
  if not isSubscribeOpen then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Prime, false, true)
    return
  end
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local subStatus = subscribeModuleObj:GetNewestSubStatus()
  log(bWriteLog and "[Lobby_Mid_Subscribe_UIBP:UpdatePrimeEnterVisible subStatus:" .. tostring(subStatus))
  if subStatus == SubscribeEnumConfig.ENUM_SubStatus.NONE then
  elseif subStatus == SubscribeEnumConfig.ENUM_SubStatus.NormalStatus then
  elseif subStatus == SubscribeEnumConfig.ENUM_SubStatus.SuperStatus or subStatus == SubscribeEnumConfig.ENUM_SubStatus.BothStatus then
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Prime, true, true)
end
function Lobby_Mid_Subscribe_UIBP:UpdatePrimeRedDot()
  if self.UIRoot.Reddot_Anchor then
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor)
    reddot_manager:BindSystemEntry(self, self.UIRoot.Reddot_Anchor, reddot_macro.SystemName.Prime)
  end
  local logic_subscribe_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
  if logic_subscribe_reddot_data then
    logic_subscribe_reddot_data:UpdateSubscribeNewRedDot()
  end
end
function Lobby_Mid_Subscribe_UIBP:OnSpecialRedChange()
  local logic_subscribe_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
  if logic_subscribe_reddot_data then
    logic_subscribe_reddot_data:UpdateSubscribeNewRedDot()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Subscribe_UIBP = class(ui_base, nil, Lobby_Mid_Subscribe_UIBP)
return CLobby_Mid_Subscribe_UIBP
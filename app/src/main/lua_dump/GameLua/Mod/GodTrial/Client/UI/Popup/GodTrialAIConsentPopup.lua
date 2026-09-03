local GodTrialAIConsentPopup = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local TITLE_TEXT_ID = 89232
local AI_TEXT_ID = 89919
local BUTTON_TEXT_ID = 468890101
local SUPPORTED_MAP_TYPES = {Baltic = true, Livik = true}
local AUTO_CLOSE_READY_TIME = 15
local IsSupportedMap = function()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  return SUPPORTED_MAP_TYPES[MapType] == true
end
local IsAlreadyShown = function()
  local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = Playerprefs.LoadFileToTable_N(Playerprefs.ePlayerPrefsType.GodTrialAIConsentShown)
  return Data and Data.shown == true
end
local MarkAsShown = function()
  local Playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  Playerprefs.SaveTableToFile_N({shown = true}, Playerprefs.ePlayerPrefsType.GodTrialAIConsentShown)
end
function GodTrialAIConsentPopup.TryShow()
  if IsAlreadyShown() then
    print(bWriteLog and "GodTrialAIConsentPopup.TryShow - already shown, skip")
    return
  end
  if not IsSupportedMap() then
    print(bWriteLog and "GodTrialAIConsentPopup.TryShow - map not supported, skip")
    return
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    print(bWriteLog and "GodTrialAIConsentPopup.TryShow - region not supported, skip")
    return
  end
  print(bWriteLog and "GodTrialAIConsentPopup.TryShow - region is " .. tostring(strRegion == PublishRegionMacros.BLUEHOLE) .. "or is japan or korea" .. tostring(PublishRegionMacros.IsJapanOrKorea()))
  UIManager.ShowUI(UIManager.UI_Config.GodTrial_Popup_UIBP)
  print(bWriteLog and "GodTrialAIConsentPopup.TryShow - show popup")
end
function GodTrialAIConsentPopup:ctor()
end
function GodTrialAIConsentPopup:OnInitialize()
  print(bWriteLog and "GodTrialAIConsentPopup:OnInitialize")
  if self.UIRoot.Title then
    self.UIRoot.Title:SetText(LocUtil.GetLocalizeResStr(TITLE_TEXT_ID))
  end
  if self.UIRoot.UTRichTextBlock_AIText then
    self.UIRoot.UTRichTextBlock_AIText:SetText(LocUtil.GetLocalizeResStr(AI_TEXT_ID))
  end
  if self.UIRoot.TextBlock_Button then
    self.UIRoot.TextBlock_Button:SetText(LocUtil.GetLocalizeResStr(BUTTON_TEXT_ID))
  end
end
function GodTrialAIConsentPopup:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnClickButton_1, self)
  self:AddOnClickedEventByControl(self.UIRoot.close, self.OnClickClose, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnGameStartCountDownDelegate", self.OnGameStartCountDown, self)
  self:AddControlEventByControl(self.UIRoot.UTRichTextBlock_AIText, "OnHyperlinkClicked", self.OnHyperLinkClicked, self)
end
function GodTrialAIConsentPopup:OnPostInitialize()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.ReadyStateTime and uGameState.ReadyStateTime <= AUTO_CLOSE_READY_TIME then
    print(bWriteLog and "GodTrialAIConsentPopup:OnPostInitialize - ReadyStateTime <= 15, auto close without marking shown")
    self:CloseSelf()
    return
  end
  MarkAsShown()
end
function GodTrialAIConsentPopup:OnClose()
  print(bWriteLog and "GodTrialAIConsentPopup:OnClose")
end
function GodTrialAIConsentPopup:OnClickButton_1()
  print(bWriteLog and "GodTrialAIConsentPopup:OnClickButton_1")
  self:CloseSelf()
end
function GodTrialAIConsentPopup:OnClickClose()
  print(bWriteLog and "GodTrialAIConsentPopup:OnClickClose")
  self:CloseSelf()
end
function GodTrialAIConsentPopup:OnGameStartCountDown(CountDownTime)
  if CountDownTime <= AUTO_CLOSE_READY_TIME then
    print(bWriteLog and "GodTrialAIConsentPopup:OnGameStartCountDown - countdown <= 15, auto close")
    self:CloseSelf()
  end
end
function GodTrialAIConsentPopup:OnHyperLinkClicked(metaDataHolder)
  log(bWriteLog and "GodTrialAIConsentPopup:OnHyperLinkClicked")
  local mete_data = metaDataHolder.metaData
  if not mete_data then
    return
  end
  local urlName = mete_data:Get("url")
  if urlName == "PubgMobilePoliciesPrivacy" then
    local url = "https://www.pubgmobile.com/privacy/en.html"
    GlobalData.JumpUrl(url)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, GodTrialAIConsentPopup)
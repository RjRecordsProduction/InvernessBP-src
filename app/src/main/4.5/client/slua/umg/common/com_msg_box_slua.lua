local CommonMsgBoxUI = {}
local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
local TYPE_ONE = CommonMsgBoxMgr.SHOW_TYPE_ONE
local TYPE_TWO = CommonMsgBoxMgr.SHOW_TYPE_TWO
local TYPE_THREE = CommonMsgBoxMgr.SHOW_TYPE_THREE
local TYPE_FOUR = CommonMsgBoxMgr.SHOW_TYPE_FOUR
local TYPE_FIVE = CommonMsgBoxMgr.SHOW_TYPE_FIVE
local ENUM_CLOSE_TYPE = {
  DEFAULT = 0,
  CONFIRM = 1,
  CANCEL = 2,
  CLOSE = 3,
  AUTO = 4
}
local Collapsed = UEnums.ESlateVisibility.Collapsed
local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
local Visible = UEnums.ESlateVisibility.Visible
local AutoCloseTimerInterval = 0.3
local TimerInvokeInterval = 1.5
function CommonMsgBoxUI:ctor(selfUI, msgData)
  self.  self.type = msgData.styleType
  self.title = msgData.title
  self.msg = msgData.msg
  self.txtOK = msgData.btnOK
  self.txtCancel = msgData.btnCancel
  self.okCallBack = msgData.clickOkCallback
  self.cancelCallBack = msgData.clickCancelCallback
  self.closeCallBack = msgData.clickCloseCallback
  self.extraData = msgData.extraData or {}
  if self.extraData.clickCloseCallback then
    self.closeCallBack = self.extraData.clickCloseCallback
  end
  if self.extraData.clickUGCSeasonCallback then
    self.ugcSeasonCallBack = self.extraData.clickUGCSeasonCallback
  end
  self.closeType = ENUM_CLOSE_TYPE.DEFAULT
  self.bIsShowMsgItem = self.extraData.bIsShowMsgItem
  self.tItemData = self.extraData.tItemData
  local check = self.extraData.isDefaultCheck
  if check == nil then
    check = false
  end
  self.isCheck = check
  self.bScrollEndCanCheck = self.extraData.bScrollEndCanCheck
  self.checkEnable = false
end
function CommonMsgBoxUI:OnInitialize()
  CommonMsgBoxUI.__super.OnInitialize(self)
  if self.bIsShowMsgItem then
    self.LoopScrollBox_Item = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Item, "client.slua.umg.common.com_msg_box_item_slua")
  end
end
function CommonMsgBoxUI:RegistEvents()
  CommonMsgBoxUI.__super.RegistEvents(self)
  if self.UIRoot.Common_Popup_MediumSmall_UIBP then
    self:AddOnClickedEventByControl(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, self.OnClickClose, self)
  elseif self.UIRoot.Common_Popup_Small_UIBP then
    self:AddOnClickedEventByControl(self.UIRoot.Common_Popup_Small_UIBP.close, self.OnClickClose, self)
  elseif self.UIRoot.Common_Popup_Medium_UIBP then
    self:AddOnClickedEventByControl(self.UIRoot.Common_Popup_Medium_UIBP.close, self.OnClickClose, self)
  else
    self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnClickClose, self)
  end
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cancel, self.OnClickCancel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OK, self.OnClickOK, self)
  if self.UIRoot.CheckBox_Option then
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_Option, self.OnCheckBoxChange, self)
  end
  if self.UIRoot.CheckBox_Release then
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_Release, self.OnCheckBoxChange, self)
  end
  self:AddCommonEvent(EVENTTYPE_HYPERLINK, EVENTID_HLINK_COMMSGBOXSLUA, self.OnHyperLink, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnModePreSwitch, self)
  if self.extraData.CloseWhenReactivated then
    self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, self.OnApplicationReactivated, self)
    self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
  end
  self:AddCommonEvent(EVENTTYPE_COMMON_MSG_BOX, EVENTID_COM_MSG_BOX_UPDATE_EXPLAIN, self.OnUpdateExplain, self)
  if self.UIRoot.CheckBox_Option then
    self.UIRoot.CheckBox_Option:SetIsChecked(self.isCheck)
    if not self.bScrollEndCanCheck then
      self.UIRoot.CheckBox_Option:SetIsEnabled(true)
      self.UIRoot.CheckBox_Option:SetCheckedState(0)
    else
      self.UIRoot.CheckBox_Option:SetCheckedState(2)
      self.UIRoot.CheckBox_Option:SetIsEnabled(false)
    end
  end
  if self.UIRoot.CheckBox_Release then
    self.UIRoot.CheckBox_Release:SetIsChecked(self.isCheck)
  end
  if self.UIRoot.Button_Close then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickClose, self)
  end
  if self.UIRoot.CanvasPanel_UC_Explain then
    self:AddControlEventByControl(self.UIRoot.TextBlock_UC_Explain, "OnHyperlinkClicked", self.OnPolicyHyperLinkClicked, self)
  end
  if self.extraData.ContentHyperLinkHandler then
    if self.UIRoot.RichText_Content then
      self:AddControlEventByControl(self.UIRoot.RichText_Content, "OnHyperlinkClicked", self.OnContentHyperLinkClicked, self)
    end
    if self.UIRoot.RichText_ContentCentauri then
      self:AddControlEventByControl(self.UIRoot.RichText_ContentCentauri, "OnHyperlinkClicked", self.OnContentHyperLinkClicked, self)
    end
    if self.UIRoot.RichText_ContentLeft then
      self:AddControlEventByControl(self.UIRoot.RichText_ContentLeft, "OnHyperlinkClicked", self.OnContentHyperLinkClicked, self)
    end
  end
  if self.UIRoot.Button_Select then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Select, self.OnClickSeasonSelect, self)
  end
  if self.UIRoot.ScrollBox_Msg then
    self:AddControlEventByControl(self.UIRoot.ScrollBox_Msg, "OnUserScrolled", self.OnUserScrolledMsg, self)
  end
end
function CommonMsgBoxUI:OnPostInitialize()
  CommonMsgBoxUI.__super.OnPostInitialize(self)
  self:InitTextBlocks()
  self:InitButtonsVisibility()
  self:HandleUrlTips()
  self:HandleSubscribe()
  self:HandleAutoClose()
  self:HandleTimerInvoke()
  self:HandleAutoTest()
  self:HandleSwitchTextType()
  self:HandleCheckBox()
  self:HandleCanOk()
  self:HandleCntDownOK()
  self:HandleExplain()
  self:HandleShowPolicy()
  self:InitBtnTopTipShow()
  self:HandleOkBtnStateByCheckBox()
  self:HandleShowLittleTips()
  self:HandleShowItem()
end
function CommonMsgBoxUI:OnShow()
  CommonMsgBoxUI.__super.OnShow(self)
  if self.UIRoot.Common_Popup_MediumSmall_UIBP then
    self.UIRoot.Common_Popup_MediumSmall_UIBP.Button_Help:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Common_Popup_Small_UIBP then
    self.UIRoot.Common_Popup_Small_UIBP.Button_Help:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Common_Popup_Medium_UIBP then
    self.UIRoot.Common_Popup_Medium_UIBP.Button_Help:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  Client.RequireSlateTickEveryFrame(SlateUI_ID.COMMON_MSG_BOX)
end
function CommonMsgBoxUI:OnModePreSwitch(eventType, eventID, gamestatus)
  log(bWriteLog and "CommonMsgBoxUI:OnModePreSwitch gamestatus = " .. tostring(gamestatus))
  if self.extraData and self.extraData.closeOnSwitch then
    self:CloseSelf()
  end
end
function CommonMsgBoxUI:OnClickOK()
  self:PlayAudio(sound_config.click_v1)
  if self.extraData and self.extraData.isShowCheckBox and self.extraData.lockButtonOKBycheckBox and not self.isCheck then
    local utility = require("common.utility")
    xpcall(self.OnlyCallbackOK, utility.ErrorMessageHandler, self)
    return
  end
  self.closeType = ENUM_CLOSE_TYPE.CONFIRM
  self:CloseSelf()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.COMMON_MSG_BOX)
end
function CommonMsgBoxUI:OnClickSeasonSelect()
  self:PlayAudio(sound_config.click_v1)
  local utility = require("common.utility")
  xpcall(self.UGCSeasonCallBack, utility.ErrorMessageHandler, self)
  Client.ResetSlateTickEveryFrame(SlateUI_ID.COMMON_MSG_BOX)
end
function CommonMsgBoxUI:OnUserScrolledMsg(pos)
  if not (self.extraData and self.extraData.isShowCheckBox) or not self.bScrollEndCanCheck then
    return
  end
  if self.checkEnable then
    return
  end
  local endoffset = self.UIRoot.ScrollBox_Msg:GetScrollEndOffset()
  if pos >= endoffset then
    self.UIRoot.CheckBox_Option:SetCheckedState(0)
    self.UIRoot.CheckBox_Option:SetIsEnabled(true)
    self.checkEnable = true
  else
    self.UIRoot.CheckBox_Option:SetCheckedState(2)
    self.UIRoot.CheckBox_Option:SetIsEnabled(false)
  end
end
function CommonMsgBoxUI:OnClickCancel()
  self:PlayAudio(sound_config.click_v1)
  self.closeType = ENUM_CLOSE_TYPE.CANCEL
  self:CloseSelf()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.COMMON_MSG_BOX)
end
function CommonMsgBoxUI:OnClickClose()
  self:PlayAudio(sound_config.click_v1)
  self.closeType = ENUM_CLOSE_TYPE.CLOSE
  self:CloseSelf()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.COMMON_MSG_BOX)
end
function CommonMsgBoxUI:OnCheckBoxChange(isCheck)
  self:PlayAudio(sound_config.click_v1)
  self.  self:HandleOkBtnStateByCheckBox()
end
function CommonMsgBoxUI:OnHyperLink(_, _, MetaData)
  if MetaData and MetaData.id and self.extraData and self.extraData.urlHandle then
    self.extraData.urlHandle(MetaData)
    self.extraData.urlHandle = nil
    self:CloseSelf()
  end
end
function CommonMsgBoxUI:OnPolicyHyperLinkClicked(MetaData)
  if MetaData and MetaData.metadata and MetaData.metaData:Get("id") then
    log(bWriteLog and "[SY]CommonMsgBoxUI:OnPolicyHyperLinkClicked.")
    if self.extraData and self.extraData.policyHandler then
      self.extraData.policyHandler(MetaData)
    end
  end
end
function CommonMsgBoxUI:OnContentHyperLinkClicked(MetaData)
  log_format("CommonMsgBoxUI:OnContentHyperLinkClicked")
  if self.extraData and self.extraData.ContentHyperLinkHandler then
    self.extraData.ContentHyperLinkHandler(MetaData)
    self:CloseSelf()
  end
end
function CommonMsgBoxUI:OnApplicationReactivated()
  log(bWriteLog and "CommonMsgBoxUI:OnApplicationReactivated")
  self:CloseSelf()
end
function CommonMsgBoxUI:SetText(control, txt)
  if not control then
    log_error("CommonMsgBoxUI:SetText. control is [nil].")
    return false
  end
  if txt and type(txt) == "string" and txt ~= "" then
    control:SetText(txt)
    return true
  else
    return false
  end
end
local SetWidgetVisibility = function(control, visibility)
  if control and slua.isValid(control) then
    control:SetWidgetVisibility(visibility)
  end
end
function CommonMsgBoxUI:InitTextBlocks()
  self.UIRoot.RichText_Content:SetGameFrontendHUD(slua_GameFrontendHUD)
  self.UIRoot.RichText_ContentCentauri:SetGameFrontendHUD(slua_GameFrontendHUD)
  self.UIRoot.RichText_UrlTips:SetGameFrontendHUD(slua_GameFrontendHUD)
  self.UIRoot.WidgetSwitcher_Font:SetActiveWidgetIndex(0)
  if self.UIRoot.Common_Popup_MediumSmall_UIBP then
    if not self:SetText(self.UIRoot.Common_Popup_MediumSmall_UIBP.Title, self.title) then
      self:SetText(self.UIRoot.Common_Popup_MediumSmall_UIBP.Title, LocUtil.GetLocalizeResStr(101001))
    end
    SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.Title, SelfHitTestInvisible)
  end
  if self.UIRoot.Common_Popup_Small_UIBP then
    if not self:SetText(self.UIRoot.Common_Popup_Small_UIBP.Title, self.title) then
      self:SetText(self.UIRoot.Common_Popup_Small_UIBP.Title, LocUtil.GetLocalizeResStr(101001))
    end
    SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.Title, SelfHitTestInvisible)
  end
  if self.UIRoot.Common_Popup_Medium_UIBP then
    if not self:SetText(self.UIRoot.Common_Popup_Medium_UIBP.Title, self.title) then
      self:SetText(self.UIRoot.Common_Popup_Medium_UIBP.Title, LocUtil.GetLocalizeResStr(101001))
    end
    SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.Title, SelfHitTestInvisible)
  end
  if self.UIRoot.Text_Title and not self:SetText(self.UIRoot.Text_Title, self.title) then
    self:SetText(self.UIRoot.Text_Title, LocUtil.GetLocalizeResStr(101001))
  end
  self:SetText(self.UIRoot.RichText_Content, self.msg)
  self:SetText(self.UIRoot.RichText_ContentCentauri, self.msg)
  self:SetText(self.UIRoot.RichText_ContentLeft, self.msg)
  if not self:SetText(self.UIRoot.Text_OK, self.txtOK) then
    self:SetText(self.UIRoot.Text_OK, LocUtil.GetLocalizeResStr(110036))
  end
  if not self:SetText(self.UIRoot.Text_Cancel, self.txtCancel) then
    self:SetText(self.UIRoot.Text_Cancel, LocUtil.GetLocalizeResStr(110035))
  end
end
function CommonMsgBoxUI:InitButtonsVisibility()
  if self.type == TYPE_ONE then
    SetWidgetVisibility(self.UIRoot.HBox_Button, SelfHitTestInvisible)
    SetWidgetVisibility(self.UIRoot.Button_Cancel, Collapsed)
    SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
    if self.UIRoot.Common_Popup_MediumSmall_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, Collapsed)
    elseif self.UIRoot.Common_Popup_Small_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.close, Collapsed)
    elseif self.UIRoot.Common_Popup_Medium_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.close, Collapsed)
    else
      SetWidgetVisibility(self.UIRoot.Button_Close, Collapsed)
    end
  elseif self.type == TYPE_TWO then
    SetWidgetVisibility(self.UIRoot.HBox_Button, SelfHitTestInvisible)
    SetWidgetVisibility(self.UIRoot.Button_Cancel, Visible)
    SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
    if self.UIRoot.Common_Popup_MediumSmall_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, Collapsed)
    elseif self.UIRoot.Common_Popup_Small_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.close, Collapsed)
    elseif self.UIRoot.Common_Popup_Medium_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.close, Collapsed)
    else
      SetWidgetVisibility(self.UIRoot.Button_Close, Collapsed)
    end
  elseif self.type == TYPE_THREE then
    SetWidgetVisibility(self.UIRoot.HBox_Button, SelfHitTestInvisible)
    SetWidgetVisibility(self.UIRoot.Button_Cancel, Collapsed)
    SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
    if self.UIRoot.Common_Popup_MediumSmall_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Small_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Medium_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.close, Visible)
    else
      SetWidgetVisibility(self.UIRoot.Button_Close, Visible)
    end
  elseif self.type == TYPE_FOUR then
    SetWidgetVisibility(self.UIRoot.HBox_Button, SelfHitTestInvisible)
    SetWidgetVisibility(self.UIRoot.Button_Cancel, Visible)
    SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
    if self.UIRoot.Common_Popup_MediumSmall_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Small_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Medium_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.close, Visible)
    else
      SetWidgetVisibility(self.UIRoot.Button_Close, Visible)
    end
  elseif self.type == TYPE_FIVE then
    SetWidgetVisibility(self.UIRoot.HBox_Button, Collapsed)
    SetWidgetVisibility(self.UIRoot.Button_Cancel, Collapsed)
    SetWidgetVisibility(self.UIRoot.Button_OK, Collapsed)
    if self.UIRoot.Common_Popup_MediumSmall_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_MediumSmall_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Small_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Small_UIBP.close, Visible)
    elseif self.UIRoot.Common_Popup_Medium_UIBP then
      SetWidgetVisibility(self.UIRoot.Common_Popup_Medium_UIBP.close, Visible)
    else
      SetWidgetVisibility(self.UIRoot.Button_Close, Visible)
    end
  end
end
function CommonMsgBoxUI:HandleUrlTips()
  if self.extraData and self.extraData.urlTips and type(self.extraData.urlTips) == "string" and self.extraData.urlTips ~= "" then
    self:SetText(self.UIRoot.RichText_UrlTips, self.extraData.urlTips)
    SetWidgetVisibility(self.UIRoot.HorizontalBox_URL, SelfHitTestInvisible)
  else
    SetWidgetVisibility(self.UIRoot.HorizontalBox_URL, Collapsed)
  end
end
function CommonMsgBoxUI:HandleShowPolicy()
  if self.extraData and self.extraData.policyTips and type(self.extraData.policyTips) == "string" and self.extraData.policyTips ~= "" then
    self:SetText(self.UIRoot.TextBlock_UC_Explain, self.extraData.policyTips)
    SetWidgetVisibility(self.UIRoot.CanvasPanel_UC_Explain, SelfHitTestInvisible)
  else
    SetWidgetVisibility(self.UIRoot.CanvasPanel_UC_Explain, Collapsed)
  end
end
function CommonMsgBoxUI:HandleExplain()
  if self.extraData and self.extraData.explain and type(self.extraData.explain) == "string" and self.extraData.explain ~= "" then
    self:SetText(self.UIRoot.TextBlock_2, self.extraData.explain)
    SetWidgetVisibility(self.UIRoot.CanvasPanel_Explain, SelfHitTestInvisible)
  else
    SetWidgetVisibility(self.UIRoot.CanvasPanel_Explain, Collapsed)
  end
end
function CommonMsgBoxUI:OnUpdateExplain(_, _, sExplainText)
  if sExplainText then
    self:SetText(self.UIRoot.TextBlock_2, sExplainText)
    SetWidgetVisibility(self.UIRoot.CanvasPanel_Explain, SelfHitTestInvisible)
  else
    SetWidgetVisibility(self.UIRoot.CanvasPanel_Explain, Collapsed)
  end
end
function CommonMsgBoxUI:HandleSubscribe()
  if self.extraData and self.extraData.isShowSubscribe then
    self.UIRoot.dingyue_tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.dingyue_tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function CommonMsgBoxUI:HandleAutoClose()
  if self.extraData and self.extraData.autoCloseTime and tonumber(self.extraData.autoCloseTime) > 0 then
    self.extraData.autoCloseTime = tonumber(self.extraData.autoCloseTime)
    if self.extraData.hideAutoCloseRemainTime then
      SetWidgetVisibility(self.UIRoot.CanvasPanel_CD, Collapsed)
    else
      SetWidgetVisibility(self.UIRoot.CanvasPanel_CD, SelfHitTestInvisible)
      self:SetText(self.UIRoot.TextBlock_CD, tostring(math.floor(self.extraData.autoCloseTime)))
    end
    self:AddTimer(AutoCloseTimerInterval, function()
      self:AutoClose()
    end)
  else
    SetWidgetVisibility(self.UIRoot.CanvasPanel_CD, Collapsed)
  end
end
function CommonMsgBoxUI:HandleCanOk()
  if self.extraData and self.extraData.canOkTime then
    self.extraData.canOkTime = tonumber(self.extraData.canOkTime)
    SetWidgetVisibility(self.UIRoot.Button_OK, SelfHitTestInvisible)
    self:SetTexture(self.UIRoot.Image_OKBg, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Bukedian_png.Common_Btn_Bukedian_png")
    self:SetText(self.UIRoot.Text_ok, LocUtil.LocalizeResFormat(4118, self.extraData.canOkTime))
    self.canOkTimer = self:AddTimer(1, function()
      self:IsCanOk()
    end)
  else
    self.UIRoot.Button_OK:SetIsEnabled(true)
    SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
  end
  if self.UIRoot.Button_OK:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  if self.extraData and self.extraData.OKBgUrl then
    self:SetTexture(self.UIRoot.Image_OKBg, self.extraData.OKBgUrl)
  else
    self:SetTexture(self.UIRoot.Image_OKBg, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Huangse_png.Common_Btn_Huangse_png")
  end
end
function CommonMsgBoxUI:HandleCntDownOK()
  if self.extraData and self.extraData.cntDown then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self:SetText(self.UIRoot.Text_Countdown, self.txtOK .. "(" .. tostring(self.extraData.cntDown) .. ")")
    self.cntdownTimer = self:AddGameTimer(1, true, function()
      self.extraData.cntDown = self.extraData.cntDown - 1
      if self.extraData.cntDown > 0 then
        self:SetText(self.UIRoot.Text_Countdown, self.txtOK .. "(" .. tostring(self.extraData.cntDown) .. ")")
      else
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
      end
    end)
  else
    if self.UIRoot.WidgetSwitcher_0 and slua.isValid(self.UIRoot.WidgetSwitcher_0) then
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
    self:RemoveCntDownTimer()
  end
end
function CommonMsgBoxUI:RemoveCntDownTimer()
  if self.cntdownTimer then
    self:RemoveGameTimer(self.cntdownTimer)
    self.cntdownTimer = nil
  end
end
function CommonMsgBoxUI:HandleTimerInvoke()
  if self.extraData and self.extraData.onTimerInvoke then
    self.InvokeTimer = self:AddTimer(TimerInvokeInterval, function()
      while self.extraData and self.extraData.onTimerInvoke do
        log(bWriteLog and "CommonMsgBoxUI TimerInvoke Execute")
        if self.extraData.IsCommonMsgBoxMgr ~= nil and self.extraData.IsCommonMsgBoxMgr then
          self.extraData.onTimerInvoke(self.extraData.UpdateMsg, self.extraData.KickOutTips1, self.extraData.KickOutTips2, self.extraData.UpdateOKText, self.extraData.OkTimerBtn)
        else
          self.extraData.onTimerInvoke()
        end
        coroutine.yield(1.5)
      end
    end)
  end
end
function CommonMsgBoxUI:HandleAutoTest()
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) and GameAutotest:IsAutoRunTestGame() then
    self:OnClickOK()
  end
end
function CommonMsgBoxUI:HandleSwitchTextType()
  if not self.extraData then
    return
  end
  if self.extraData.leftAlign then
    self:SwitchText(2)
  end
  if self.extraData.switchTextType then
    self:SwitchText(1)
  end
end
function CommonMsgBoxUI:HandleCheckBox()
  if self.extraData and self.extraData.isShowCheckBox then
    if self.UIRoot and self.UIRoot.WidgetSwitcher_Status then
      self.UIRoot.WidgetSwitcher_Status:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      local idx = 0
      if self.extraData and self.extraData.isUGCSeasonCheckBox then
        idx = 1
      end
      self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(idx)
    end
    if self.UIRoot and self.UIRoot.CheckBox_Option then
      self.UIRoot.CheckBox_Option:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    end
    if self.extraData and self.extraData.checkBoxText then
      if self.UIRoot.CheckBox_OptionText then
        self.UIRoot.CheckBox_OptionText:SetText(self.extraData.checkBoxText)
      end
      if self.UIRoot.TextBlock_Name then
        self.UIRoot.TextBlock_Name:SetText(self.extraData.checkBoxText)
      end
    end
    if self.extraData and self.extraData.checkBoxTipsText then
      if self.UIRoot.CanvasPanel_Money then
        self.UIRoot.CanvasPanel_Money:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
      if self.UIRoot.TextBlock_Money then
        self.UIRoot.TextBlock_Money:SetText(self.extraData.checkBoxTipsText)
      end
    end
  else
    if self.UIRoot and self.UIRoot.WidgetSwitcher_Status then
      self.UIRoot.WidgetSwitcher_Status:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.UIRoot and self.UIRoot.CheckBox_Option then
      self.UIRoot.CheckBox_Option:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function CommonMsgBoxUI:InitBtnTopTipShow()
  local node_root = self.UIRoot
  if not node_root.RichText_BtnTopTip then
    return
  end
  if self.extraData.sBtnTopTip then
    self:SetWidgetVisible(node_root.CanvasPanel_BtnTopTip, true)
    node_root.RichText_BtnTopTip:SetText(self.extraData.sBtnTopTip)
    return
  end
  self:SetWidgetVisible(node_root.CanvasPanel_BtnTopTip, false)
end
function CommonMsgBoxUI:RemoveInvokeTImer()
  if self.InvokeTimer then
    self:RemoveTimer(self.InvokeTimer)
    self.InvokeTimer = nil
    self.extraData.onTimerInvoke = nil
  end
end
function CommonMsgBoxUI:Deprecated_RemoveInvokeTImer()
  if self.InvokeTimer then
    self:RemoveTimer(self.InvokeTimer)
    self.InvokeTimer = nil
  end
end
function CommonMsgBoxUI:UpdateMsg(msg)
  if self.extraData and self.extraData.onTimerInvoke == nil then
    self:Deprecated_RemoveInvokeTImer()
    return
  end
  self:SetText(self.UIRoot.RichText_Content, msg)
  self:SetText(self.UIRoot.RichText_ContentCentauri, msg)
end
function CommonMsgBoxUI:UpdateOKText(okText)
  if self.extraData and self.extraData.onTimerInvoke == nil then
    self:Deprecated_RemoveInvokeTImer()
    return
  end
  self:SetText(self.UIRoot.Text_OK, okText)
end
function CommonMsgBoxUI:AutoClose()
  if self.extraData and self.extraData.autoCloseTime then
    self.extraData.autoCloseTime = self.extraData.autoCloseTime - AutoCloseTimerInterval
    if self.extraData.autoCloseTime > 0 then
      self:SetText(self.UIRoot.Text_ok, LocUtil.GeneralFormat(self.txtOK, math.floor(self.extraData.autoCloseTime)))
      self:AddTimer(AutoCloseTimerInterval, function()
        self:AutoClose()
      end)
    else
      self.closeType = ENUM_CLOSE_TYPE.AUTO
      self:CloseSelf()
    end
  end
end
function CommonMsgBoxUI:IsCanOk()
  if self.extraData and self.extraData.canOkTime then
    self.extraData.canOkTime = self.extraData.canOkTime - 1
    if self.extraData.canOkTime >= 0 then
      self:SetText(self.UIRoot.Text_ok, LocUtil.LocalizeResFormat(4118, self.extraData.canOkTime))
      self.canOkTimer = self:AddTimer(1, function()
        self:IsCanOk()
      end)
    else
      SetWidgetVisibility(self.UIRoot.Button_OK, Visible)
      self.UIRoot.Button_OK:SetIsEnabled(true)
      self:SetText(self.UIRoot.Text_ok, LocUtil.GetLocalizeResStr(110036))
      self:SetTexture(self.UIRoot.Image_OKBg, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Huangse_png.Common_Btn_Huangse_png")
      self:RemoveCanOkTimer()
    end
  end
end
function CommonMsgBoxUI:RemoveCanOkTimer()
  if self.canOkTime then
    self:RemoveTimer(self.canOkTimer)
    self.canOkTimer = nil
    self.extraData.canOkTime = nil
  end
end
function CommonMsgBoxUI:EnableOKBtn()
  if self.UIRoot then
    self.UIRoot:SetButtonOkState(true)
    if self.UIRoot.Image_OKBg then
      self.UIRoot.Image_OKBg:SetIsEnabled(true)
    end
  end
end
function CommonMsgBoxUI:DisableOKBtn()
  if self.UIRoot then
    self.UIRoot:SetButtonOkState(false)
  end
end
function CommonMsgBoxUI:SwitchText(index)
  self.UIRoot.WidgetSwitcher_Font:SetActiveWidgetIndex(index)
end
function CommonMsgBoxUI:HandleOkBtnStateByCheckBox()
  if self.extraData and self.extraData.isShowCheckBox and self.extraData.lockButtonOKBycheckBox then
    if self.extraData.canOkTime then
      log_error("CommonMsgBoxUI:UpdateOkBtnStateByCheckBox canOkTime and lockButtonOKBycheckBox is conflict")
      return
    end
    self.UIRoot.Image_OKBg:SetIsEnabled(self.isCheck)
  end
end
function CommonMsgBoxUI:HandleShowLittleTips()
  if self.extraData and self.extraData.littleTips then
    if self.UIRoot.TextBlock_LittleTips then
      self:SetWidgetVisible(self.UIRoot.TextBlock_LittleTips, true)
      self.UIRoot.TextBlock_LittleTips:SetText(self.extraData.littleTips)
    end
  elseif self.UIRoot.TextBlock_LittleTips then
    self:SetWidgetVisible(self.UIRoot.TextBlock_LittleTips, false)
  end
end
function CommonMsgBoxUI:HandleShowItem()
  self:SetWidgetVisible(self.UIRoot.SizeBox_Item, false)
  if self.bIsShowMsgItem and self.tItemData then
    self:SetWidgetVisible(self.UIRoot.SizeBox_Item, true)
    self.LoopScrollBox_Item:SetData(self.tItemData)
  end
end
function CommonMsgBoxUI:CallbackHandle()
  if self.closeType == ENUM_CLOSE_TYPE.CONFIRM then
    log(bWriteLog and "CommonMsgBoxUI:Close Click OK")
    if self.okCallBack then
      local okCallback = self.okCallBack
      self.okCallBack = nil
      okCallback(self.isCheck)
    end
  elseif self.closeType == ENUM_CLOSE_TYPE.CANCEL then
    log(bWriteLog and "CommonMsgBoxUI:Close Click Cancel")
    if self.cancelCallBack then
      local callback = self.cancelCallBack
      self.cancelCallBack = nil
      callback(self.isCheck)
    end
  elseif self.closeType == ENUM_CLOSE_TYPE.CLOSE then
    log(bWriteLog and "CommonMsgBoxUI:Close Click Close")
    if self.closeCallBack then
      local callback = self.closeCallBack
      self.closeCallBack = nil
      callback(self.isCheck)
    end
  elseif self.closeType == ENUM_CLOSE_TYPE.AUTO then
    log(bWriteLog and "CommonMsgBoxUI:Close AutoClose")
    if self.extraData.autoCloseWithoutCallback then
      log(bWriteLog and "CommonMsgBoxUI:Close AutoClose - need not callback")
      return
    end
    if self.okCallBack then
      local okCallback = self.okCallBack
      self.okCallBack = nil
      okCallback(self.isCheck)
    elseif self.cancelCallBack then
      local callback = self.cancelCallBack
      self.cancelCallBack = nil
      callback(self.isCheck)
    end
  end
end
function CommonMsgBoxUI:OnlyCallbackOK()
  if self.okCallBack then
    local okCallback = self.okCallBack
    okCallback(self.isCheck)
  end
end
function CommonMsgBoxUI:UGCSeasonCallBack()
  if self.ugcSeasonCallBack then
    local ugcSeasonCallBack = self.ugcSeasonCallBack
    ugcSeasonCallBack()
  end
end
function CommonMsgBoxUI:Close()
  self:EnableOKBtn()
  CommonMsgBoxUI.__super.Close(self)
  local utility = require("common.utility")
  xpcall(self.CallbackHandle, utility.ErrorMessageHandler, self)
  self:ReleaseAllCallBack()
  log(bWriteLog and "CommonMsgBoxUI Close")
  CommonMsgBoxMgr.OnOneMsgBoxClose()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MSGBOX_CLOSE)
end
function CommonMsgBoxUI:ReleaseAllCallBack()
  self.okCallBack = nil
  self.cancelCallBack = nil
  if self.extraData then
    self.extraData.urlHandle = nil
    self.extraData.policyHandler = nil
  end
  self:RemoveInvokeTImer()
  self:RemoveCntDownTimer()
end
function CommonMsgBoxUI:OnAndroidBack()
  log(bWriteLog and "CommonMsgBoxUI AndroidBack")
  if self.extraData and self.extraData.androidCallback and self.extraData.androidCallback() then
    return
  end
  self.closeType = ENUM_CLOSE_TYPE.CLOSE
  self:CloseSelf()
end
function CommonMsgBoxUI:GetDataForJumpBack()
  return {
    ctorData = {
      [1] = self.msgData
    }
  }
end
function CommonMsgBoxUI:JumpBack(uiData)
end
local class = require("class")
local AnimationBase = require("client.slua_ui_framework.AnimationBase")
local CCommonMsgBoxUI = class(AnimationBase, nil, CommonMsgBoxUI)
return CCommonMsgBoxUI
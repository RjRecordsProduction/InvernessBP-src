local common_popup_box_base = {}
function common_popup_box_base:OnInitialize()
  common_popup_box_base.__super.OnInitialize(self)
  self:SetWidgetVisible(self.UIRoot.Title, false)
  self:SetWidgetVisible(self.UIRoot.close, false, true)
  if self.UIRoot.Button_Help then
    self:SetWidgetVisible(self.UIRoot.Button_Help, false, true)
  end
end
function common_popup_box_base:RegistEvents()
  common_popup_box_base.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.close, "OnClicked", self._OnClickedClose, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_TOTALREWARD_CLOSED, self._OnClickedClose, self)
  if self.UIRoot.Button_Help then
    self:AddControlEventByControl(self.UIRoot.Button_Help, "OnClicked", self._OnClickedHelp, self)
  end
  if self.UIRoot.Common_Fadeout then
    self:AddControlEventByControl(self.UIRoot.Common_Fadeout, "OnAnimationFinished", self.OnFadeOutAnimationFinished, self)
  end
  if self.UIRoot.Common_FadeIn then
    self:AddControlEventByControl(self.UIRoot.Common_Fadein, "OnAnimationFinished", self.OnFadeInAnimationFinished, self)
  end
end
function common_popup_box_base:OnClose()
  log(bWriteLog and "common_popup_box_base:OnClose")
  if self.UIRoot and self.UIRoot.Common_Fadeout then
    self.UIRoot:StopAnimation(self.UIRoot.Common_Fadeout)
  end
end
function common_popup_box_base:_InitUI(mainUI, titleText, extraData)
  if not assert(mainUI ~= nil and type(mainUI) == "table", "common_popup_box_base:Init mainUI illegal") then
    return
  end
  if not assert(titleText ~= nil and type(titleText) == "string", "common_popup_box_base:Init titleText illegal") then
    return
  end
  self.  self.  self.  if not slua.isValid(self.UIRoot) then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Title, true)
  self:_SetTitle()
  local showCloseBtn = true
  if self.extraData and self.extraData.showCloseBtn == false then
    showCloseBtn = false
  end
  self:SetWidgetVisible(self.UIRoot.close, showCloseBtn, true)
  if self.UIRoot.Button_Help then
    if self.extraData and self.extraData.helpInfo then
      self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
    else
      self:SetWidgetVisible(self.UIRoot.Button_Help, false, true)
    end
  end
  if self.extraData and self.extraData.bDisableAni then
  else
    self:_PlayFadeIn()
  end
end
function common_popup_box_base:_SetTitle()
  self.UIRoot.Title:SetText(self.titleText)
end
function common_popup_box_base:_OnClickedClose()
  self:PlayAudio(sound_config.close_v1)
  if self.extraData and self.extraData.preCloseFunc and type(self.extraData.preCloseFunc) == "function" and not self.extraData.preCloseFunc(self.mainUI) then
    return
  end
  if self.UIRoot.close then
    self.UIRoot.close:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  self:_PlayFadeOut()
end
function common_popup_box_base:_OnClickedHelp()
  self:PlayAudio(sound_config.click_v1)
  if self.extraData.helpInfo.showFunc then
    self.extraData.helpInfo.showFunc()
  else
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, self.extraData.helpInfo.type or 0, self.extraData.helpInfo.titleText, self.extraData.helpInfo.contentText)
  end
end
function common_popup_box_base:_PlayFadeIn()
  if self.mainUI.UIRoot.fadein then
    self.mainUI:PlayUserWidgetAnimation(self.mainUI.UIRoot.fadein, 0, 1, 0, 1)
  end
  if self.UIRoot.Common_Fadein then
    self:PlayUserWidgetAnimation(self.UIRoot.Common_Fadein, 0, 1, 0, 1)
  end
end
function common_popup_box_base:_PlayFadeOut()
  if self.mainUI and self.mainUI.UIRoot and self.mainUI.UIRoot.fadeout then
    self.mainUI:PlayUserWidgetAnimation(self.mainUI.UIRoot.fadeout, 0, 1, 0, 1)
  end
  if self.UIRoot.Common_Fadeout then
    log(bWriteLog and "common_popup_box_base:_PlayFadeOut")
    self:PlayUserWidgetAnimation(self.UIRoot.Common_Fadeout, 0, 1, 0, 1)
  else
    self:_CloseMainUI()
  end
end
function common_popup_box_base:OnFadeOutAnimationFinished()
  log(bWriteLog and "common_popup_box_base:OnFadeOutAnimationFinished")
  self:AddTimerOnce(0, function()
    self:_CloseMainUI()
  end)
end
function common_popup_box_base:OnFadeInAnimationFinished()
  print(bWriteLog and "common_popup_box_base:OnFadeInAnimationFinished")
  EventSystem:postEvent(EVENTID_UI, EVENTID_SHOW_POPUP_FADEIN_FINISH)
end
function common_popup_box_base:_CloseMainUI()
  log(bWriteLog and "common_popup_box_base:_CloseMainUI ")
  if self.extraData and self.extraData.closeFunc and type(self.extraData.closeFunc) == "function" then
    self.extraData.closeFunc(self.mainUI)
    return
  end
  if self.mainUI then
    self.mainUI:CloseSelf()
  end
end
function common_popup_box_base:SetHelpInfo(helpInfo)
  if not self.extraData then
    self.extraData = {}
  end
  self.extraData.  if self.UIRoot.Button_Help then
    if self.extraData and self.extraData.helpInfo then
      self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
    else
      self:SetWidgetVisible(self.UIRoot.Button_Help, false, true)
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_popup_box_base = class(ui_base, nil, common_popup_box_base)
return CCommon_popup_box_base
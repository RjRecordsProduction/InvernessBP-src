local Common_Popup_Reward_Base = {}
local _sSliderPointPath = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_SliderPoint_Item.Common_Popup_Theme_Explain_SliderPoint_Item"
function Common_Popup_Reward_Base:ctor(_, sTitle, tAllShowCfg, fCallBack, bShowExperience, bShowExperienceBtn, extra_data)
  self._sTitle = sTitle or ""
  self._tAllShowCfg = tAllShowCfg or {}
  self._tAllSliderNode = {}
  self._tAllShowPanel = {}
  self._fCloseCallback = fCallBack
  self._bShowExperience = bShowExperience == nil and true or bShowExperience
  self._bShowExperienceBtn = bShowExperienceBtn or false
  self._extra_data = extra_data or {}
  self.isShowWhiteArrow = self._extra_data.bWhiteArrow or false
  self.bSpecialPageColor = self._extra_data.bSpecialPageColor or false
  self._nCurIndex = 1
  self._nMaxIndex = #self._tAllShowCfg
end
function Common_Popup_Reward_Base:RegistEvents()
  Common_Popup_Reward_Base.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickClose, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Preview, self.OnClickSlide, self, false)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Next, self.OnClickSlide, self, true)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Continue, self.OnClickContinue, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Experience, self.OnClickExperience, self)
  if self.UIRoot.Button_Study then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Study, self.OnClickStudy, self)
  end
end
function Common_Popup_Reward_Base:OnPostInitialize()
  Common_Popup_Reward_Base.__super.OnPostInitialize(self)
  self:SetWidgetVisible(self.UIRoot.Button_Experience, self._bShowExperience, true)
  self.UIRoot.TextBlock_Title:SetText(self._sTitle)
  self:InitShow()
  self:RefreshSliderShow()
  self:RefreshPanelShow()
end
function Common_Popup_Reward_Base:OnClose()
  local fCallback = self._fCloseCallback
  local closeReason = self.closeReason
  if self.UIRoot.Image_ArrowRiht then
    self.UIRoot.Image_ArrowRiht:SetActiveColorIndex(0)
  end
  if self.UIRoot.Image_ArrowLeft then
    self.UIRoot.Image_ArrowLeft:SetActiveColorIndex(0)
  end
  if fCallback and type(fCallback) == "function" then
    fCallback(closeReason)
  end
  Common_Popup_Reward_Base.__super.OnClose(self)
end
function Common_Popup_Reward_Base:InitShow()
  log_tree(self._extra_data)
  self:PlayUserWidgetAnimation(self.UIRoot.Auto_Fadein, 0, 1, 0, 1)
  self:AddTimer(0, function()
    for _, v in ipairs(self._tAllShowCfg) do
      if self._extra_data and self._extra_data.bShowSlideBar then
        local obj_sliderPoint = self:CreateChildWindowWithBpPath("HorBox_SliderPoint", nil, _sSliderPointPath)
        obj_sliderPoint.UIRoot.Image_Select:SetActiveColorIndex(self.bSpecialPageColor and 1 or 0)
        obj_sliderPoint.UIRoot.Image_UnSelect:SetActiveColorIndex(self.bSpecialPageColor and 1 or 0)
        table.insert(self._tAllSliderNode, obj_sliderPoint)
      end
      local obj_panel = self:CreateChildWindowWithBpPath("Switcher_PanelShow", nil, v.BPPath)
      table.insert(self._tAllShowPanel, obj_panel)
    end
    self:RefreshDynamicSliderShow()
    self:RefreshDynamicPanelShow()
    self.UIRoot.Switcher_PanelShow:SetActiveWidgetIndex(self._nCurIndex - 1)
  end)
  if self._extra_data.textContinueBtn and self._extra_data.textContinueBtn ~= "" then
    self.UIRoot.Text_Continue:SetText(self._extra_data.textContinueBtn)
  else
    self.UIRoot.Text_Continue:SetText(LocUtil.GetLocalizeResStr(24120))
  end
  if self._extra_data and self._extra_data.specialBgPath then
    log(bWriteLog and "[SY]Common_Popup_Reward_Base:InitShow.")
    local obj_panel = self:CreateChildWindowWithBpPath("Canvas_BGRoot", nil, "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_BG_Item_UIBP.Common_Popup_Theme_Explain_BG_Item_UIBP")
    self:SetTexture(obj_panel.UIRoot.Image_ThemeBG, self._extra_data.specialBgPath)
    self:SetWidgetVisible(self.UIRoot.Canvas_BGRoot, true)
  end
  if self.UIRoot.Image_ArrowRiht then
    self.UIRoot.Image_ArrowRiht:SetActiveColorIndex(self.isShowWhiteArrow and 1 or 0)
  end
  if self.UIRoot.Image_ArrowLeft then
    self.UIRoot.Image_ArrowLeft:SetActiveColorIndex(self.isShowWhiteArrow and 1 or 0)
  end
  if self.UIRoot.TextBlock_Study then
    self.UIRoot.TextBlock_Study:SetText(LocUtil.GetLocalizeResStr(2026032193))
  end
end
function Common_Popup_Reward_Base:RefreshSliderShow()
  self:SetWidgetVisible(self.UIRoot.HorBox_SliderPoint, self._nMaxIndex > 1)
  self:SetWidgetVisible(self.UIRoot.Button_Preview, 1 < self._nCurIndex, true)
  self:SetWidgetVisible(self.UIRoot.Button_Next, self._nCurIndex < self._nMaxIndex, true)
  if self._extra_data.bShowContinueBtn then
    self.UIRoot.WidgetSwitcher_Down:SetActiveWidgetIndex(0)
  elseif self._bShowExperienceBtn then
    self.UIRoot.WidgetSwitcher_Down:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.Button_Study, self._extra_data.bShowStudyBtn, true)
  else
    self.UIRoot.WidgetSwitcher_Down:SetActiveWidgetIndex(self._nCurIndex >= self._nMaxIndex and 1 or 0)
  end
end
function Common_Popup_Reward_Base:RefreshPanelShow()
  local tCurShowCfg = self._tAllShowCfg[self._nCurIndex]
  if not tCurShowCfg then
    log(bWriteLog and "[Common_Popup_Reward_Base] nil reward: " .. tostring(self._nCurIndex))
    return
  end
  if tCurShowCfg.TitleID then
    self.UIRoot.TextBlock_Title:SetText(LocUtil.LocalizeResFormat(tCurShowCfg.TitleID))
  end
  if tCurShowCfg.Title then
    self.UIRoot.TextBlock_Title:SetText(tCurShowCfg.Title)
  end
  self.UIRoot.Switcher_PanelShow:SetActiveWidgetIndex(self._nCurIndex - 1)
end
function Common_Popup_Reward_Base:RefreshDynamicSliderShow()
  for index, obj_sliderPoint in ipairs(self._tAllSliderNode) do
    local node_sliderPoint = obj_sliderPoint.UIRoot
    self:SetWidgetVisible(node_sliderPoint, index <= self._nMaxIndex)
    node_sliderPoint.Switcher_Point:SetActiveWidgetIndex(index == self._nCurIndex and 0 or 1)
  end
end
function Common_Popup_Reward_Base:RefreshDynamicPanelShow()
  log(bWriteLog and "[SY]Common_Popup_Reward_Base:RefreshDynamicPanelShow.")
  local tCurShowCfg = self._tAllShowCfg[self._nCurIndex]
  if not tCurShowCfg then
    log(bWriteLog and "[Common_Popup_Reward_Base] nil reward: " .. tostring(self._nCurIndex))
    return
  end
  local obj_showPanel = self._tAllShowPanel[self._nCurIndex]
  if tCurShowCfg.RefreshFun and obj_showPanel then
    tCurShowCfg.RefreshFun(obj_showPanel.UIRoot, tCurShowCfg)
  end
end
function Common_Popup_Reward_Base:ChangeSlideIndex(bFront)
  local deltaIndex = bFront and 1 or -1
  self._nCurIndex = self._nCurIndex + deltaIndex
  if self._nCurIndex > self._nMaxIndex then
    self._nCurIndex = 1
  elseif 1 > self._nCurIndex then
    self._nCurIndex = self._nMaxIndex
  end
  self:RefreshSliderShow()
  self:RefreshPanelShow()
  self:RefreshDynamicSliderShow()
  self:RefreshDynamicPanelShow()
end
function Common_Popup_Reward_Base:OnClickSlide(bFront)
  self:PlayAudio(sound_config.click)
  self:ChangeSlideIndex(bFront)
end
function Common_Popup_Reward_Base:OnClickContinue()
  self:PlayAudio(sound_config.click)
  if self._nMaxIndex <= 1 then
    self:CloseSelf()
  else
    self:ChangeSlideIndex(true)
  end
end
function Common_Popup_Reward_Base:OnClickExperience()
  self:PlayAudio(sound_config.click)
  self.closeReason = "Experience"
  self:CloseSelf()
end
function Common_Popup_Reward_Base:OnClickStudy()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
end
function Common_Popup_Reward_Base:OnClickClose()
  self:PlayAudio(sound_config.click)
  self:CloseSelf()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.AnimationBase")
local CCommon_Popup_Reward_Base = class(ui_base, nil, Common_Popup_Reward_Base)
return CCommon_Popup_Reward_Base
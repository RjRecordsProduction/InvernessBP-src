local ETipStyle = require("client.logic.level_unlock.config.level_unlock_config").ETipStyle
local LevelUnlockBubble = {}
function LevelUnlockBubble:ctor(_, dir, tipStr, targetWidget, cb, showHandEffect, forceGuide, bSkipMask, extraParam)
  self.  self.  self.  self.  self.  self.  self.  local style = extraParam and extraParam.style
  self.style = style and type(style) == "number" and style or ETipStyle.line
  self.showFlashEffect = extraParam and extraParam.showFlashEffect
  self.bTriggerCallbackOnClose = extraParam and extraParam.bTriggerCallbackOnClose or false
end
function LevelUnlockBubble:OnInitialize()
  LevelUnlockBubble.__super.OnInitialize(self)
  self:InitUI()
end
function LevelUnlockBubble:RegistEvents()
  LevelUnlockBubble.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Back, self.OnClickBack, self)
  self:AddOnClickedEventByControl(self.UIRoot.BubbleButton, self.OnClickBubble, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_OFFSET_UI_SOCIAL_TO_LOBBY_ANIM_FINISH, self.OnLobbyAnimFinish, self)
end
function LevelUnlockBubble:OnPostInitialize()
  LevelUnlockBubble.__super.OnPostInitialize()
end
function LevelUnlockBubble:InitUI()
  local hasStyle = self.style >= 0
  if hasStyle then
    self.UIRoot.WidgetSwitcher_Style:SetActiveWidgetIndex(self.style)
  end
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Style, hasStyle)
  self.UIRoot.GuideWidgetSwitcher:SetActiveWidgetIndex(self.dir)
  local tipWidget = self.UIRoot["GuideTip" .. self.dir]
  local UIUtil = require("client.common.ui_util")
  if tipWidget then
    tipWidget:SetText(self.tipStr or "")
  end
  local hasTip = self.tipStr and self.tipStr ~= ""
  self:SetWidgetVisible(self.UIRoot.GuideWidgetSwitcher, hasTip)
  if UIUtil.IsValid(self.targetWidget) then
    UIUtil.SetGuideByWidget(self.UIRoot.Bubble, self.targetWidget)
  end
  if self.showFlashEffect then
    self:AddTimerOnce(0, function()
      if not self.flashGlowUI then
        local callback = function()
          if hasStyle or hasTip then
            return
          end
          self:CloseSelf()
        end
        self.flashGlowUI = self:CreateChildWindow(self.UIRoot.Bubble, UIManager.UI_Config.Common_Item_GuideSweepGlow_BP, callback)
      end
    end)
  end
  if self.showHandEffect then
    self:AddTimerOnce(0, function()
      if not self.tipHandUI then
        self.tipHandUI = self:CreateChildWindow(self.UIRoot.Bubble, UIManager.UI_Config.Common_Item_GuideHand_BP)
      end
      if UIUtil.IsValid(self.targetWidget) then
        local WidgetSize = UIUtil.GetLocalSize(self.targetWidget)
        self.tipHandUI:SetOffsets(WidgetSize.X / 3, WidgetSize.Y / 3, 0, 0)
      end
    end)
  end
end
function LevelUnlockBubble:OnClickBubble()
  log(bWriteLog and "LevelUnlockBubble:OnClickBubble")
  self:PlayAudio(sound_config.click_v1)
  self:CloseSelf()
  if self.cb then
    self.cb()
    self.cb = nil
    if self.bSkipMask then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Common_Mask_UIBP, 2)
  end
end
function LevelUnlockBubble:OnClickBack()
  log(bWriteLog and "LevelUnlockBubble:OnClickBack")
  if not self.forceGuide then
    self:CloseSelf()
  end
end
function LevelUnlockBubble:OnLobbyAnimFinish()
  local UIUtil = require("client.common.ui_util")
  if UIUtil.IsValid(self.targetWidget) then
    UIUtil.SetGuideByWidget(self.UIRoot.Bubble, self.targetWidget)
  end
end
function LevelUnlockBubble:OnClose()
  LevelUnlockBubble.__super.OnClose(self)
  if self.bTriggerCallbackOnClose and self.cb then
    self.cb()
    self.cb = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLevelUnlockBubble = class(ui_base, nil, LevelUnlockBubble)
return CLevelUnlockBubble
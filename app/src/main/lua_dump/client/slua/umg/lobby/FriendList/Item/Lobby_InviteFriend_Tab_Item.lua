local Lobby_InviteFriend_Tab_Item = {}
function Lobby_InviteFriend_Tab_Item:ctor()
  self.flashGlowUI = nil
end
function Lobby_InviteFriend_Tab_Item:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tab, self.OnClickButton_Tab, self)
end
function Lobby_InviteFriend_Tab_Item:OnRefresh(data, selectIndex)
  log(bWriteLog and "Lobby_InviteFriend_Tab_Item:OnRefresh")
  self:SetTexture(self.UIRoot.Image_Selected_Bg, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Tab/Vertical/LevelOne/Icon/Common_Tab_Vertical_LevelOne_Icon_Button_4.Common_Tab_Vertical_LevelOne_Icon_Button_4")
  if data then
    if data.SelectedIconPath then
      self:SetTexture(self.UIRoot.Image_SelectIcon, data.SelectedIconPath)
    end
    if data.UnSelectIconPath then
      self:SetTexture(self.UIRoot.Image_UnSelectIcon, data.UnSelectIconPath)
    end
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    if self.index ~= selectIndex then
      self.UIRoot.WidgetSwitcher_Tab:setActiveWidgetIndex(0)
      self.UIRoot.TextBlock_0:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.5)))
    else
      log(bWriteLog and "Lobby_InviteFriend_Tab_Item:OnRefresh. selected TabID: " .. tostring(data.TabID))
      self.UIRoot.WidgetSwitcher_Tab:setActiveWidgetIndex(1)
      self.UIRoot.TextBlock_0:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
    end
    local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
    if data.TabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
      local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
      mainUI:SetWOWWorkName()
      mainUI:SetWidgetVisible(self.UIRoot.ExtendedLoopScrollGrid_1, true, true)
    end
    if data.TabID == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
      local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
      local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
      mainUI:SetWidgetVisible(mainUI.UIRoot.CanvasPanel_LBS, LBSFriendMgr:CanOpenNearFriend())
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Avatar, true, false)
    self:SetWidgetVisible(self.UIRoot.Common_Avatar_BP, false, false)
    local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
    if mainUI and mainUI.pendingTabTextUpdates and mainUI.pendingTabTextUpdates[data.TabID] then
      self:RefreshText(mainUI.pendingTabTextUpdates[data.TabID])
      mainUI.pendingTabTextUpdates[data.TabID] = nil
    end
    if self.index == selectIndex then
      if self.UIRoot.Anim_Select then
        self:PlayUserWidgetAnimation(self.UIRoot.Anim_Select, 0, 1, 0, 1)
      end
    else
      self:StopAnimation("Anim_Select")
    end
  else
    log(bWriteLog and "Lobby_InviteFriend_Tab_Item:OnRefresh data is nil")
  end
end
function Lobby_InviteFriend_Tab_Item:OnClickButton_Tab()
  self:PlayAudio(sound_config.click_v1)
  local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  mainUI:OnClickTab(self.data.TabID)
  local loopScrollBox = self:GetParentUI()
  loopScrollBox:Select(self.index)
end
function Lobby_InviteFriend_Tab_Item:RefreshText(text)
  log(bWriteLog and "Lobby_InviteFriend_Tab_Item:RefreshText text: " .. tostring(text))
  self.UIRoot.TextBlock_0:SetText(text)
end
function Lobby_InviteFriend_Tab_Item:ShowFlashGlow()
  self:ClearFlashGlow()
  self.flashGlowUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_FlashGlow, UIManager.UI_Config.Common_Item_GuideSweepGlow_BP, function()
    self:ClearFlashGlow()
  end)
end
function Lobby_InviteFriend_Tab_Item:ClearFlashGlow()
  if self.flashGlowUI then
    self.flashGlowUI:CloseSelf()
    self.flashGlowUI = nil
  end
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
return class(scroll_box_child_base, nil, Lobby_InviteFriend_Tab_Item)
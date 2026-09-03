local Lobby_Mid_NewRecruit_Item_UIBP = {}
function Lobby_Mid_NewRecruit_Item_UIBP:ctor()
end
function Lobby_Mid_NewRecruit_Item_UIBP:OnInitialize()
  self.UIRoot.Text_Title:SetText(LocUtil.GetLocalizeResStr(43973))
  self:SetWidgetVisible(self.UIRoot.Image_1, false)
  self:SetTexture(self.UIRoot.Image_Banner, "/Game/UMG/UI_BP/NewbieActivity/NewbieReward/Texture/Newbie_Reward_LevelSprint__Entrance.Newbie_Reward_LevelSprint__Entrance")
end
function Lobby_Mid_NewRecruit_Item_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Jump, self.OnClickButton_Jump, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_CLICK, self.HandleGuideBtnClick, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE, self.CreateGuideUI, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.CreateGuideUI, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_CELEBRATION_INIT, self.BindNewbieActivityRedDot, self)
end
function Lobby_Mid_NewRecruit_Item_UIBP:OnPostInitialize()
  self:UpdateUI()
end
function Lobby_Mid_NewRecruit_Item_UIBP:OnClose()
  self.UIRoot.Reddot_Anchor_Item03:UnBind()
end
function Lobby_Mid_NewRecruit_Item_UIBP:GetNewbieDefaultActID()
  local logicNewbieMain = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
  local activityConfig = logicNewbieMain.config
  if not activityConfig then
    return
  end
  local configName = "Activity_Newbie_EightDays"
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  if logic_new_player_spin.IsOpen() then
    configName = "new_player_spin_main_uibp"
  end
  for i, v in pairs(activityConfig) do
    if v.uiConfig and v.uiConfig == configName then
      return i
    end
  end
  return nil
end
function Lobby_Mid_NewRecruit_Item_UIBP:OnClickButton_Jump()
  self:PlayAudio(sound_config.new_activityBtn)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ACTIVITY, true) then
    return
  end
  if not self.newbieDefaultActID then
    self.newbieDefaultActID = self:GetNewbieDefaultActID()
  end
  if not self.newbieDefaultActID then
    ShowNotice(4002)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Activity_Newbie_Main)
end
function Lobby_Mid_NewRecruit_Item_UIBP:HandleGuideBtnClick(_, _, GuideID)
  log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:HandleGuideBtnClick")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
  local bCheckGuide = growthprojectMgrB.CheckGuideStep(GuideType, 0)
  self:PlayAudio(sound_config.new_activityBtn)
  growthprojectMgrB.SaveGuideInfo(GuideType, 1)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    growthprojectMgrB.SaveGuideInfo(GuideType, 2)
    growthprojectMgrB.SaveGuideInfo(GuideType, 3)
    growthprojectMgrB.SaveGuideInfo(GuideType, 4)
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.NewGuideFirstMatch()
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE)
  if UIManager.GetUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP)
  end
end
function Lobby_Mid_NewRecruit_Item_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:UpdateUI")
  self:ShowEndTimer()
  self:UpdateRedDot()
end
function Lobby_Mid_NewRecruit_Item_UIBP:CreateGuideUI()
  if not self.UIRoot then
    return
  end
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if Lobby_Main_UIBP and Lobby_Main_UIBP.PlayingAnimIn then
    log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:CreateGuideUI Lobby_Main_UIBP.PlayingAnimIn == true")
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local GuideType = LogicNewbie.NEWBIE_GUIDE_MODULE_ID_STRONG_XMISSION_GUIDE
  local bCheckGuide = growthprojectMgrB.CheckGuideStep(GuideType, 0)
  local cb = function()
    self:PlayAudio(sound_config.new_activityBtn)
    growthprojectMgrB.SaveGuideInfo(GuideType, 1)
    EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_XMISSION_GUIDE)
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
    if UIManager.GetUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP) then
      UIManager.CloseUI(UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP)
    end
    self:AddTimerOnce(1, function()
      local uTargetWidget = self.UIRoot.Button_Jump
      if not slua.isValid(uTargetWidget) then
        sandbox.LogError("NGActionCommonClickWidget_Base target widget is not valid")
        return
      end
      local logic_newbieguide_config = require("client.slua.logic.home.NewbieGuide.logic_newbieguide_config")
      local Params = {
        highlightOutlineType = logic_newbieguide_config.EHighlightOutlineType.Rectangle,
        textDirection = logic_newbieguide_config.EDirection.Left,
        textID = 27325,
        registerButtonEventName = "OnClicked",
        showHandEffect = true,
        guideDelayTime = 0,
        bClickClose = true,
        showMask = true,
        uTargetWidget = uTargetWidget,
        uClickWidget = uTargetWidget
      }
      local config = UIManager.UI_Config.Common_NewbieGuide_Bubble_UIBP
      if LobbySystem.CheckUseNewGuide() then
        log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:CreateGuideUI testnewbieguide")
        UIManager.ShowUI(config, "testnewbieguide", Params)
      else
        local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
        local txt = LocUtil.GetLocalizeResStr(12753)
        local widget = uTargetWidget
        local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
        if logic_newbie_assist.CheckIsNewBie() or logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
          widget = self.UIRoot.Button_Jump
          UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 0, txt, widget, cb, true, 2)
        else
        end
      end
    end)
  end
end
function Lobby_Mid_NewRecruit_Item_UIBP:ShowEndTimer()
  local TimeUtil = require("client.common.time_util")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local endTime = logic_newbie_new_abtest:GetNewbieEndTime()
  self:SetWidgetVisible(self.UIRoot.Panel_Time, 0 < endTime)
  if 0 < endTime then
    self.timer = self:AddTimerLoop(0, function()
      local leftTime = endTime - TimeUtil.GetServerTimeInSec()
      if leftTime < 0 then
        self:RemoveTimer(self.timer)
        self.timer = nil
        self.UIRoot.Text_Time:SetText("")
        self:SetWidgetVisible(self.UIRoot.Panel_Time, false)
        return
      end
      local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(leftTime)
      self.UIRoot.Text_Time:SetText(timeStr)
    end, TIMER_INFINITE, 1)
  end
end
function Lobby_Mid_NewRecruit_Item_UIBP:UpdateRedDot()
  log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:UpdateRedDot")
  local logic_newbie_activity_reddot = require("client.slua.logic.activity.newbie.logic_newbie_activity_reddot")
  local logic_newbie_reward_abtest_reddot = require("client.slua.logic.activity.newbie.logic_newbie_reward_abtest_reddot")
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local data
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    data = logic_newbie_reward_abtest_reddot.GetSuperData()
  elseif NewbieActivitySystem.activity_data then
    data = logic_newbie_activity_reddot.GetSuperData()
    logic_newbie_activity_reddot.UpdateRedDot()
  end
  if data then
    self.UIRoot.Reddot_Anchor_Item03:Bind(data)
  end
end
function Lobby_Mid_NewRecruit_Item_UIBP:BindNewbieActivityRedDot()
  log(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:BindNewbieActivityRedDot")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    log_warning(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:BindNewbieActivityRedDot. use new logic")
    return
  end
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.activity_data then
    log_warning(bWriteLog and "Lobby_Mid_NewRecruit_Item_UIBP:BindNewbieActivityRedDot. activity_data is nil")
    return
  end
  local logic_newbie_activity_reddot = require("client.slua.logic.activity.newbie.logic_newbie_activity_reddot")
  local data = logic_newbie_activity_reddot.GetSuperData()
  if data then
    self.UIRoot.Reddot_Anchor_Item03:UnBind()
    self.UIRoot.Reddot_Anchor_Item03:Bind(data)
    logic_newbie_activity_reddot.UpdateRedDot()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_Mid_NewRecruit_Item_UIBP)
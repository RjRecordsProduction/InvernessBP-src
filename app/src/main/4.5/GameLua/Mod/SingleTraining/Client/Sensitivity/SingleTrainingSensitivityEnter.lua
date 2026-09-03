local SingleTrainingSensitivityEnter = {}
function SingleTrainingSensitivityEnter:ctor()
  self.bHasShowTips = false
  self.ShowTipsTimer = nil
end
function SingleTrainingSensitivityEnter:OnClose()
  if Setting_EnterSingleTraining then
    Setting_EnterSingleTraining = false
  end
end
function SingleTrainingSensitivityEnter:RegistEvents()
  SingleTrainingSensitivityEnter.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Enter, self.OnButtonEnterClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Friend, self.OnButtonFriendClick, self)
end
function SingleTrainingSensitivityEnter:OnPostInitialize()
  SingleTrainingSensitivityEnter.__super.OnPostInitialize(self)
  if Setting_EnterSingleTraining then
    print(bWriteLog and "SingleTrainingSensitivityEnter:OnPostInitialize Setting_EnterSingleTraining=true")
    self:OnButtonEnterClick()
  else
    print(bWriteLog and "SingleTrainingSensitivityEnter:OnPostInitialize Setting_EnterSingleTraining=false or nil")
  end
end
function SingleTrainingSensitivityEnter:OnButtonEnterClick()
  print(bWriteLog and "SingleTrainingSensitivityEnter:OnButtonEnterClick")
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sensitivity_List)
  EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_CLIENT_TLOG, "IsClickedSensEntry")
  self:HideTips()
end
function SingleTrainingSensitivityEnter:ShowTips()
  local Settingconfig = slua_GameFrontendHUD:GetUserSettings()
  if Setting_EnterSingleTraining and not self.bHasShowTips and Settingconfig and Settingconfig.ShowSingleTrainingSensitivityTipsCount < 3 then
    Settingconfig.ShowSingleTrainingSensitivityTipsCount = Settingconfig.ShowSingleTrainingSensitivityTipsCount + 1
    slua_GameFrontendHUD:FinishModifyUserSettings()
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_inlet, 0, 1, 0, 1)
    self.bHasShowTips = true
    self.UIRoot.GuideCanvas_SingleTrainSensiButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.ShowTipsTimer = self:AddGameTimer(8, false, function()
      self:HideTips()
    end)
  end
end
function SingleTrainingSensitivityEnter:HideTips()
  if self.UIRoot and self.UIRoot.GuideCanvas_SingleTrainSensiButton then
    if self.ShowTipsTimer then
      self:RemoveGameTimer(self.ShowTipsTimer)
      self.ShowTipsTimer = nil
    end
    self.UIRoot.GuideCanvas_SingleTrainSensiButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function SingleTrainingSensitivityEnter:OnButtonFriendClick()
  print(bWriteLog and "SingleTrainingSensitivityEnter:OnButtonFriendClick")
  self:PlayAudio(sound_config.click_v1)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.SINGLE_TRAINING)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSingleTrainingSensitivityEnter = class(ui_base, nil, SingleTrainingSensitivityEnter)
return CSingleTrainingSensitivityEnter
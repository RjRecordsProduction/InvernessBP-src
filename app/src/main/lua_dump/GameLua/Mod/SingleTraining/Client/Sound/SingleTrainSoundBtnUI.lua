local SingleTrainSoundBtnUI = {_ShowType = 0}
function SingleTrainSoundBtnUI:ctor(selfType, ShowType)
  self._end
function SingleTrainSoundBtnUI:OnConstruct(ShowType)
  self._  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_SOUND_BTN_FIRST_SHOW)
end
function SingleTrainSoundBtnUI:RegistEvents()
  SingleTrainSoundBtnUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_6, self.OnButtonEnterClicked, self)
  EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_SOUND_BTN_FIRST_SHOW)
  local SingleTraining_Sound_Count = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count)
  if SingleTraining_Sound_Count and SingleTraining_Sound_Count.CurShowType == 0 then
    self:SetEnterChanllenge(true)
  end
end
function SingleTrainSoundBtnUI:OnShow()
  self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(self._ShowType)
end
function SingleTrainSoundBtnUI:OnButtonEnterClicked()
  self:Hide()
  if self._ShowType == 0 then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
  end
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainSoundBtnUI:SetEnterChanllenge(bIsEnter)
  if bIsEnter then
    self.UIRoot.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, SingleTrainSoundBtnUI)
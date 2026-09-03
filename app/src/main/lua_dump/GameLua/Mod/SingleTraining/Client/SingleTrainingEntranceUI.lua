local SingleTrainingEntranceUI = {}
function SingleTrainingEntranceUI:ctor(selfType, component)
  self.end
function SingleTrainingEntranceUI:RegistEvents()
  SingleTrainingEntranceUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GunSoundTraining, self.OnBtnGunSoundTrainingClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_StepSoundTraining, self.OnBtnStepSoundTrainingClicked, self)
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr("42880"))
  self.UIRoot.TextBlock_11:SetText(LocUtil.GetLocalizeResStr("42876"))
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr("42875"))
end
function SingleTrainingEntranceUI:OnBtnGunSoundTrainingClicked()
  print(bWriteLog and "SingleTrainingEntranceUI:OnBtnGunSoundTrainingClicked")
  self:ReportAction(1002)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
  self:_CloseNewbie()
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainingEntranceUI:OnBtnStepSoundTrainingClicked()
  print(bWriteLog and "SingleTrainingEntranceUI:OnBtnStepSoundTrainingClicked")
  self:ReportAction(1001)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  self:_CloseNewbie()
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainingEntranceUI:_CloseNewbie()
  if slua.isValid(self.component) then
    local Owner = self.component:GetOwner()
    if Owner and Owner.NewBie then
      Owner.ParticleSystem:SetVisibility(false, true)
      Owner.ParticleSystem1:SetVisibility(false, true)
      Owner.NewBie = false
      DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN, Owner._ID)
    end
  end
end
function SingleTrainingEntranceUI:SetEnterChanllenge(bIsEnter)
  if bIsEnter then
    self.UIRoot.STInvalidationBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.STInvalidationBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SingleTrainingEntranceUI:ReportAction(PanelID)
  print(bWriteLog and "SingleTrainingEntranceUI:ReportAction", PanelID)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and PanelID then
    uPlayerController:RPC_Server_PanelFlow(PanelID)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSingleTrainingEntranceUI = class(ui_base, nil, SingleTrainingEntranceUI)
return CSingleTrainingEntranceUI
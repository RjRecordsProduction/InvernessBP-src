local SingleTrainGunUI = {
  _CurType = -1,
  _DistanceComboBox = nil,
  _DirectionComboBox = nil,
  _ActionComboBox = nil,
  _GunComboBox = nil,
  _SelectImageArray = nil,
  _CurDifficulty = 1,
  _CurCloseBtnType = -1,
  _GunIDArray = {},
  _Common_Other_Tips_UIBP = nil
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
function SingleTrainGunUI:ctor(selfType)
end
function SingleTrainGunUI:RegistEvents()
  SingleTrainGunUI.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, self.OnCloseBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnCloseAllBtnClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Practise1, self.OnPractiseBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Practise2, self.OnPractiseBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Challenge1, self.OnChallengeBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Challenge2, self.OnChallengeBtnClick, self)
  local SingleTrainSoundUtil = require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil")
  local ComboBoxAddFuncTable = {
    OnOpening = self.OnComboBoxOpenAddFunc
  }
  SingleTrainSoundUtil.AddClickSound(self, "Common_ComboBox_ExpertArea1", "/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click", ComboBoxAddFuncTable)
  self._DistanceComboBox = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_ExpertArea1)
  self._DistanceComboBox:SetSelectOptionCallback(self.OnDistanceComboBoxSelect, self)
  self._DistanceComboBox:SetRefreshOptionCallback(self.OnDistanceComboBoxRefresh, self)
  self._DistanceComboBox:SetData({
    "10-50",
    "50-80",
    "80-120",
    ">120"
  })
  self._DistanceComboBox:SelectIndex(1)
  SingleTrainSoundUtil.AddClickSound(self, "Common_ComboBox_C_0", "/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click", ComboBoxAddFuncTable)
  self._DirectionComboBox = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_C_0)
  self._DirectionComboBox:SetSelectOptionCallback(self.OnDirectionComboBoxSelect, self)
  self._DirectionComboBox:SetRefreshOptionCallback(self.OnDirectionComboBoxRefresh, self)
  self._DirectionComboBox:SetData({
    38990,
    38991,
    38993,
    38992,
    38995,
    38997,
    38994,
    38996
  })
  self._DirectionComboBox:SelectIndex(1)
  SingleTrainSoundUtil.AddClickSound(self, "Common_ComboBox_C_1", "/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click", ComboBoxAddFuncTable)
  self._ActionComboBox = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_C_1)
  self._ActionComboBox:SetSelectOptionCallback(self.OnDirectionComboBoxSelect, self)
  self._ActionComboBox:SetRefreshOptionCallback(self.OnDirectionComboBoxRefresh, self)
  self._ActionComboBox:SetData({
    39004,
    39005,
    39003
  })
  self._ActionComboBox:SelectIndex(1)
  SingleTrainSoundUtil.AddClickSound(self, "Common_ComboBox_C_2", "/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click", ComboBoxAddFuncTable)
  self._GunComboBox = self:InitCommonComboBoxNew(self.UIRoot.Common_ComboBox_C_2)
  self._GunComboBox:SetSelectOptionCallback(self.OnDirectionComboBoxSelect, self)
  self._GunComboBox:SetRefreshOptionCallback(self.OnDirectionComboBoxRefresh, self)
  self._GunComboBox:SetData({
    38999,
    39000,
    39001,
    39002
  })
  self._GunComboBox:SelectIndex(1)
  self._SelectImageArray = {
    self.UIRoot.Image_Model0,
    self.UIRoot.Image_Model1,
    self.UIRoot.Image_Model2,
    self.UIRoot.Image_Model3
  }
  self:UpdateSelectImage(self._CurDifficulty, self._SelectImageArray)
  self:AddOnClickedEventByControl(self.UIRoot.Button_4, self.OnDifficulyBtnClick_1, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_5, self.OnDifficulyBtnClick_2, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_6, self.OnDifficulyBtnClick_3, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_7, self.OnDifficulyBtnClick_4, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_8, self.OnStartBtnClick, self)
  self:AddOnAnimationFinishedEvent("close", self.OnCloseAnimationFinish, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_0, self.OnCheckBoxStateChanged_0, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_17, self.OnTipsBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2, self.OnEnemyPosTipsBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_3, self.OnCloseComboBoxBtnClick, self)
  self:UpdateView(1)
  self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr("38957"))
  self.UIRoot.TextBlock_5:SetText(LocUtil.GetLocalizeResStr("38960"))
  self.UIRoot.TextBlock_6:SetText(LocUtil.GetLocalizeResStr("38960"))
  self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr("38959"))
  self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr("38959"))
  self.UIRoot.TextBlock_11:SetText(LocUtil.GetLocalizeResStr("42812"))
  self.UIRoot.TextBlock_12:SetText(LocUtil.GetLocalizeResStr("42974"))
  self.UIRoot.TextBlock_13:SetText(LocUtil.GetLocalizeResStr("42814"))
  self.UIRoot.TextBlock_14:SetText(LocUtil.GetLocalizeResStr("34824"))
  self.UIRoot.TextBlock_15:SetText(LocUtil.GetLocalizeResStr("42809"))
  self.UIRoot.TextBlock_7:SetText(LocUtil.GetLocalizeResStr("39006"))
  self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr("39007"))
  self.UIRoot.TextBlock_9:SetText(LocUtil.GetLocalizeResStr("39008"))
  self.UIRoot.TextBlock_10:SetText(LocUtil.GetLocalizeResStr("39009"))
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr("39010"))
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr("42811"))
  self.UIRoot.TextBlock_16:SetText(LocUtil.GetLocalizeResStr("39011"))
  self:FixMultiSelectedBug()
end
function SingleTrainGunUI:FixMultiSelectedBug()
  local InputClass = import("ScreenInput")
  local utility = require("common.utility")
  local UIUtil = require("client.common.ui_util")
  local WorldContextObject = UIUtil.GetGameInstance()
  local ScreenInput = InputClass(WorldContextObject)
  ScreenInput:Init()
  self:AddControlEventByControl(ScreenInput, "OnMouseButtonUp", function(_)
    local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
    logic_comp_combobox.ProcScreenMouseUp()
  end)
  self:AddControlEventByControl(ScreenInput, "OnMouseButtonDown", function(_)
    local logic_comp_combobox = require("client.slua.logic.clicker.logic_comp_combobox")
    logic_comp_combobox.ProcScreenMouseDown()
  end)
end
function SingleTrainGunUI:OnShow()
  local TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn)
  if TempUI then
    TempUI:Collapsed()
  end
  TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  if TempUI then
    TempUI:Collapsed()
  end
  TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sensitivity_List)
  if TempUI and TempUI:IsShow() then
    TempUI:OnButtonCloseClick()
  end
  self:PlayUserWidgetAnimation(self.UIRoot.open, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
  self._CurCloseBtnType = -1
end
function SingleTrainGunUI:OnHide()
  self:OnCloseComboBoxBtnClick()
end
function SingleTrainGunUI:OnCloseBtnClicked()
  if not self._isShow or self._CurCloseBtnType ~= -1 then
    return
  end
  self._CurCloseBtnType = 0
  self:PlayUserWidgetAnimation(self.UIRoot.close, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnCloseAllBtnClicked()
  if not self._isShow then
    return
  end
  if self._CurCloseBtnType ~= -1 then
    self._CurCloseBtnType = 1
    return
  end
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
  self:OnCloseAllBtnClickedWithoutAudio()
end
function SingleTrainGunUI:OnCloseAllBtnClickedWithoutAudio()
  if not self._isShow or self._CurCloseBtnType ~= -1 then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count, -1)
  self._CurCloseBtnType = 1
  self:PlayUserWidgetAnimation(self.UIRoot.close, 0, 1, 0, 1)
end
function SingleTrainGunUI:OnAndroidBack()
  self:OnCloseAllBtnClickedWithoutAudio()
end
function SingleTrainGunUI:OnPractiseBtnClick()
  self:UpdateView(0)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnChallengeBtnClick()
  self:UpdateView(1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:UpdateView(CurType)
  if CurType == self._CurType then
    return
  end
  self._  if self._CurType == 0 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(1)
  end
end
function SingleTrainGunUI:UpdateSelectImage(Index, SelectImageArray)
  for CurIndex, Value in ipairs(SelectImageArray) do
    if CurIndex == Index then
      Value:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      Value:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function SingleTrainGunUI:OnDistanceComboBoxRefresh(Widget, Data, Index, SelectIndex)
  Widget.TextBlock_ItemName:SetText(Data)
end
function SingleTrainGunUI:OnDistanceComboBoxSelect(Widget, Data, Index, SelectIndex)
  Widget.TextBlock_ItemName:SetText(Data)
end
function SingleTrainGunUI:OnDirectionComboBoxRefresh(Widget, Data, Index, SelectIndex)
  Widget.TextBlock_ItemName:SetText(LocUtil.GetLocalizeResStr(Data))
end
function SingleTrainGunUI:OnDirectionComboBoxSelect(Widget, Data, Index, SelectIndex)
  Widget.TextBlock_ItemName:SetText(LocUtil.GetLocalizeResStr(Data))
end
function SingleTrainGunUI:OnStartBtnClick()
  if self._CurCloseBtnType ~= -1 then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    error("SingleTrainGunUI:OnStartBtnClick uPlayerController is null")
  else
    if not uPlayerController:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.GunSound) then
      return
    end
    if self._CurType == 0 then
      local DistanceType = self._DistanceComboBox:GetSelectIndex()
      local DirectionType = self._DirectionComboBox:GetSelectIndex()
      local ActionType = self._ActionComboBox:GetSelectIndex()
      local GunType = self._GunComboBox:GetSelectIndex()
      local bIsShow = self.UIRoot.CheckBox_0:IsChecked()
      CGameState.STDeadBoxClientShowFeature:CleanAIDeadBox()
      uPlayerController:RPC_Server_GunSoundTraining(DistanceType, DirectionType, ActionType, GunType, bIsShow)
      BattleGeneralTip(11316)
    else
      local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
      ClientGameMain.CurrentModeLogic:CheckTimeEnough(function()
        local bIsHaveWeapon = require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil").IsLocalPlayerHaveWeapon()
        if bIsHaveWeapon then
          self:StartChanllenge()
        else
          UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI, 42879, function()
            uPlayerController:RPC_Server_AddWeapon()
            self:StartChanllenge()
          end)
        end
      end)
    end
    self:OnCloseBtnClicked()
  end
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:StartChanllenge()
  local uPlayerController = GameplayData.GetPlayerController()
  if not uPlayerController:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.GunSound) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count, 0, 1, self._CurDifficulty)
  local SingleTrainEntranceUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainEntranceUI)
  local SingleTraining_Sound_Btn = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn)
  if SingleTrainEntranceUI then
    SingleTrainEntranceUI:SetEnterChanllenge(true)
  end
  if SingleTraining_Sound_Btn then
    SingleTraining_Sound_Btn:SetEnterChanllenge(true)
  end
  if slua.isValid(uPlayerController) then
    uPlayerController:RPC_Server_PreGunSoundChallenge(self._CurDifficulty)
  end
end
function SingleTrainGunUI:OnCheckBoxStateChanged_0()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    error("SingleTrainGunUI:OnCheckBoxStateChanged_0 uPlayerController is null")
  else
    uPlayerController:RPC_Server_ShowVoice(self.UIRoot.CheckBox_0:IsChecked())
  end
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnDifficulyBtnClick_1()
  self._CurDifficulty = 1
  self:UpdateSelectImage(self._CurDifficulty, self._SelectImageArray)
  self:PlayUserWidgetAnimation(self.UIRoot.pitch_on, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnDifficulyBtnClick_2()
  self._CurDifficulty = 2
  self:UpdateSelectImage(self._CurDifficulty, self._SelectImageArray)
  self:PlayUserWidgetAnimation(self.UIRoot.pitch_on, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnDifficulyBtnClick_3()
  self._CurDifficulty = 3
  self:UpdateSelectImage(self._CurDifficulty, self._SelectImageArray)
  self:PlayUserWidgetAnimation(self.UIRoot.pitch_on, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnDifficulyBtnClick_4()
  self._CurDifficulty = 4
  self:UpdateSelectImage(self._CurDifficulty, self._SelectImageArray)
  self:PlayUserWidgetAnimation(self.UIRoot.pitch_on, 0, 1, 0, 1)
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
end
function SingleTrainGunUI:OnCloseAnimationFinish()
  self:Collapsed()
  if self._CurCloseBtnType == 0 then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn, 1)
  else
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      error("SingleTrainGunUI:OnCloseAnimationFinish uPlayerController is null")
    else
      uPlayerController:RPC_Server_CloseAllSoundTraining()
    end
  end
  self._CurCloseBtnType = -1
  local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
  ui_navigation_manager:UIPop(self._config.keyName)
end
function SingleTrainGunUI:SetEnterChanllenge(bIsEnter)
  if bIsEnter then
    self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SingleTrainGunUI:OnTipsBtnClick()
  local tipsParam = {
    widget = self.UIRoot.Button_17,
    title = LocUtil.GetLocalizeResStr(6067),
    subTitle = nil,
    content = LocUtil.GetLocalizeResStr(42867),
    content2 = LocUtil.GetLocalizeResStr(42868),
    jumpText = nil,
    jumpCallback = nil,
    jumpParams = nil,
    detailText = nil,
    detailCallback = nil,
    detailParams = nil,
    offsetX = 190,
    offsetY = 50
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
  self:CloseAllComboBox()
end
function SingleTrainGunUI:OnEnemyPosTipsBtnClick()
  local tipsParam = {
    widget = self.UIRoot.Button_2,
    title = LocUtil.GetLocalizeResStr(6067),
    subTitle = nil,
    content = LocUtil.GetLocalizeResStr(42973),
    content2 = nil,
    jumpText = nil,
    jumpCallback = nil,
    jumpParams = nil,
    detailText = nil,
    detailCallback = nil,
    detailParams = nil,
    offsetX = 330,
    offsetY = 15
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
  self:CloseAllComboBox()
end
function SingleTrainGunUI:CloseAllComboBox()
  self._DistanceComboBox:CloseComboBox()
  self._DirectionComboBox:CloseComboBox()
  self._ActionComboBox:CloseComboBox()
  self._GunComboBox:CloseComboBox()
end
function SingleTrainGunUI:OnCloseComboBoxBtnClick()
  self:CloseAllComboBox()
  self.UIRoot.Button_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SingleTrainGunUI:OnComboBoxOpenAddFunc()
  self.UIRoot.Button_3:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function SingleTrainGunUI:IsShowSelf()
  if (self._CurCloseBtnType == -1 or self._CurCloseBtnType == 0) and self:IsShow() then
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSingleTrainFootstepsUI = class(ui_base, nil, SingleTrainGunUI)
return CSingleTrainFootstepsUI
local SingleTrainSoundCountUI = {
  _UnusedFlyNum = {},
  _FlyNumID = 0,
  _NeedShowType = -1,
  CurShowType = -100,
  _Param = -1,
  _Param2 = -1,
  _IsRegistEventsFinish = false
}
local UWidgetLayoutLibrary = import("WidgetLayoutLibrary")
local UGameplayStatics = import("GameplayStatics")
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function SingleTrainSoundCountUI:ctor(selfType, ShowType, Param, Param2)
  self._Need  self._  self._end
function SingleTrainSoundCountUI:OnConstruct(ShowType, Param, Param2)
  self._Need  self._  self._  self:_UpdateView()
end
function SingleTrainSoundCountUI:RegistEvents()
  SingleTrainSoundCountUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_CURLEVEL, self._UpdateCurLevel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_exit, self.OnButtonExitClick, self)
  self._IsRegistEventsFinish = true
  self:_UpdateView()
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr("39026"))
end
function SingleTrainSoundCountUI:_UpdateView()
  if self._IsRegistEventsFinish and self._NeedShowType ~= self.CurShowType then
    self.CurShowType = self._NeedShowType
    self:RemoveAllGameTimer()
    if self.CurShowType == 0 then
      local ScoreUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Score)
      if ScoreUI then
        ScoreUI:Collapsed()
      end
      self.UIRoot.PrepareTrainning:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      local CountTextNum = 5
      self.UIRoot.TimeCountDownText:SetText(tostring(CountTextNum))
      self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Count.Play_UI_Training_Count")
      for Index = 1, 5 do
        CountTextNum = CountTextNum - 1
        local TempNum = CountTextNum
        self:AddGameTimer(Index, false, function()
          if not self or not self.UIRoot then
            return
          end
          self.UIRoot.TimeCountDownText:SetText(tostring(TempNum))
          self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Count.Play_UI_Training_Count")
          if TempNum == 0 then
            local uPlayerController = GameplayData.GetPlayerController()
            if not slua.isValid(uPlayerController) then
              error("SingleTrainGunUI:OnStartBtnClick uPlayerController is null")
            elseif self._Param == 0 then
              if uPlayerController:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.FootStepSound) then
                uPlayerController:RPC_Server_FootstepChallenge(self._Param2)
                BattleGeneralTip(11320)
              end
            elseif uPlayerController:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.GunSound) then
              uPlayerController:RPC_Server_GunSoundChallenge(self._Param2)
              BattleGeneralTip(11315)
            end
            self:HideCountPanel()
            self:AddGameTimer(0.5, false, function()
              if self and self.UIRoot then
                local SuperData = GameplayData.GetSuperData()
                self:AddDataListener(SuperData, "PlayerState", function()
                  local uPlayerState = GameplayData.GetPlayerState()
                  if slua.isValid(uPlayerState) then
                    uPlayerState:OnRep_BattleTime()
                  end
                end)
              end
            end)
          end
        end)
      end
    elseif self.CurShowType == 1 then
      self.UIRoot.PrepareTrainning:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:_UpdateCurLevel()
      local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
      ui_navigation_manager:UIPop(self._config.keyName)
      ui_navigation_manager:UIPushOn(self._config.keyName, ui_navigation_manager.EnumStyleType.SLuaUI)
    else
      self:HideCountPanel()
    end
  end
  if self.CurShowType == 1 then
    if self.TimeAndScoreTimer then
      self:RemoveGameTimer(self.TimeAndScoreTimer)
      self.TimeAndScoreTimer = nil
    end
    self.TimeAndScoreTimer = self:AddGameTimer(0.1, true, function()
      self:TickInternal()
    end)
  elseif self.TimeAndScoreTimer then
    self:RemoveGameTimer(self.TimeAndScoreTimer)
    self.TimeAndScoreTimer = nil
  end
end
function SingleTrainSoundCountUI:HideCountPanel()
  self.UIRoot.PrepareTrainning:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function SingleTrainSoundCountUI:_UpdateCurLevel()
  print(bWriteLog and "[YY-D] SingleTrainSoundCountUI:_UpdateCurLevel")
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "PlayerState", function()
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      local CurLevel = uPlayerState.CurLevel
      print(bWriteLog and "[YY-D] SingleTrainSoundCountUI:_UpdateCurLevel" .. CurLevel)
      if CurLevel == 1 then
        self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(39014))
      elseif CurLevel == 2 then
        self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(39015))
      elseif CurLevel == 3 then
        self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(39016))
      elseif CurLevel == 4 then
        self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(39017))
      end
    end
  end)
end
function SingleTrainSoundCountUI:OnButtonExitClick()
  self:PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Click.Play_UI_Training_Click")
  self:OnButtonExitClickWithoutAudio()
end
function SingleTrainSoundCountUI:OnButtonExitClickWithoutAudio()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    error("SingleTrainSoundCountUI:OnButtonExitClick uPlayerController is null")
  else
    uPlayerController:RPC_Server_CloseAllSoundTraining()
  end
end
function SingleTrainSoundCountUI:OnAndroidBack()
  if self.CurShowType == 1 then
    self:OnButtonExitClickWithoutAudio()
  end
end
function SingleTrainSoundCountUI:TickInternal()
  if not slua.isValid(CGameState) then
    return
  end
  if self.CurShowType == 1 then
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) then
      local CurServerTime = CGameState:GetServerWorldTimeSeconds()
      local EndTime = PlayerState.ChanllengeStartTime + PlayerState.BattleTime
      self.UIRoot.TextTime:SetText(LocUtil.LocalizeResFormat(39025, math.max(0, math.floor(EndTime - CurServerTime))))
      self.UIRoot.TextScore:SetText(LocUtil.LocalizeResFormat(34654, math.floor(PlayerState.BattleScore)))
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, SingleTrainSoundCountUI)
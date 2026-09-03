local SingleTrainSoundUtil = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local CheckWeaponIDValid = function(WeaponID)
  if WeaponID <= 0 then
    return false
  end
  return true
end
function SingleTrainSoundUtil.IsLocalPlayerHaveWeapon()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if uPlayerCharacter then
    local WeaponList = Game:GetEquipWeaponList(uPlayerCharacter)
    if not slua.isValid(WeaponList) or WeaponList:Num() == 0 or not CheckWeaponIDValid(WeaponList:Get(0)) then
      return false
    else
      return true
    end
  end
  return false
end
local AutoCreateFuntionAndAddEvent = function(UIBase, ControlName, SoundPath, EventName, UIBaseFuncTable)
  local OtherFunc
  if UIBaseFuncTable and UIBaseFuncTable[EventName] then
    OtherFunc = UIBaseFuncTable[EventName]
  end
  local PlayAudioFunc = function(LocalUIBase)
    LocalUIBase:PlayAudio(SoundPath)
    if OtherFunc then
      OtherFunc(UIBase)
    end
  end
  local FuncName = EventName .. "AutoCreate"
  UIBase[FuncName] = PlayAudioFunc
  UIBase:AddControlEvent(ControlName, EventName, UIBase[FuncName], UIBase)
end
function SingleTrainSoundUtil.AddClickSound(UIBase, ControlName, SoundPath, UIBaseFuncTable)
  local Control = UIBase.UIRoot[ControlName]
  if Game:IsClassOf(Control, import("/Script/UMG.Button")) then
    AutoCreateFuntionAndAddEvent(UIBase, ControlName, SoundPath, "OnClicked", UIBaseFuncTable)
  elseif Game:IsClassOf(Control, import("ComboBoxString")) then
    AutoCreateFuntionAndAddEvent(UIBase, ControlName, SoundPath, "OnSelectionChanged", UIBaseFuncTable)
    AutoCreateFuntionAndAddEvent(UIBase, ControlName, SoundPath, "OnOpening", UIBaseFuncTable)
  elseif Game:IsClassOf(Control, import("CheckBox")) then
    AutoCreateFuntionAndAddEvent(UIBase, ControlName, SoundPath, "OnCheckStateChanged", UIBaseFuncTable)
  end
end
function SingleTrainSoundUtil.CloseSoundTrainingAll()
  local TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn)
  if TempUI then
    TempUI:Collapsed()
  end
  TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  if TempUI then
    TempUI:OnCloseAllBtnClicked()
  end
  TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
  if TempUI then
    TempUI:OnCloseAllBtnClicked()
  end
  TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI)
  if TempUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.SingleTrainEndTrainTipsUI)
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count, -1)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    error("SingleTrainSoundUtil.CloseSoundTrainingAll uPlayerController is null")
  else
    uPlayerController:RPC_Server_CloseAllSoundTraining()
  end
end
function SingleTrainSoundUtil.SetEnterTraning(bIsEnter)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) then
    uGameState.bIsTraining = bIsEnter
  end
end
function SingleTrainSoundUtil.IsTraining()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if uGameState and slua.isValid(uGameState) and uGameState.bIsTraining then
    return true
  end
  return false
end
local _CheckShow = function(Config, bIsShow)
  if not bIsShow then
    local TempUI = UIManager.GetUI(Config)
    if TempUI and TempUI:IsShow() then
      return true
    end
  end
  return bIsShow
end
local _CheckShow2 = function(Config, bIsShow)
  if not bIsShow then
    local TempUI = UIManager.GetUI(Config)
    if TempUI and TempUI:IsShowSelf() then
      return true
    end
  end
  return bIsShow
end
function SingleTrainSoundUtil.IsNeedCloseSoundTrain()
  local bIsShowTips = false._CheckShow2(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps, bIsShowTips)
  bIsShowTips = _CheckShow2(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun, bIsShowTips)
  bIsShowTips = _CheckShow(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn, bIsShowTips)
  if not bIsShowTips then
    local TempUI = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Count)
    if TempUI and (TempUI.CurShowType == 0 or TempUI.CurShowType == 1) then
      return true
    end
  end
  return bIsShowTips
end
return SingleTrainSoundUtil
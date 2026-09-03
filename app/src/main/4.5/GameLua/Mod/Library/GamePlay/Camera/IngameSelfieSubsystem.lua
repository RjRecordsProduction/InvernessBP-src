local IngameSelfieSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PhotoGrapherConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.PhotoGrapherConfig")
local EPlayerCameraMode = import("EPlayerCameraMode")
function IngameSelfieSubsystem:ctor()
  self.bIsFPPbeforeSelfie = false
  self.bHasReportedOpenSelfie = false
  self.bIsIngameSelfieMode = false
  self.bIsBlocking = false
  self.bIsSetTemplateID = false
  self.bIsSetSeqConfig = false
  self.nTemplateID = 0
  self.tSequenceConfig = nil
  self.RecordTempIDForTlog = {}
  self.bIsAsyncLoadingUI = false
  self.__mIgnoreDamageTypes = nil
end
function IngameSelfieSubsystem:_PostConstruct()
end
function IngameSelfieSubsystem:OnInit()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:OnInit")
  self.bHasReportedOpenSelfie = false
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED_EX, self.OnApplicationDeactivated, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_ENTER_COUNTDOWN_SELFIE, self.EnterSelfie, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_SELFIE_UI_INIT_COMPLETE, self.OnSelfieUIInitComplete, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_RESULT_COUNTDOWN_END, function()
    self.bCountDownFinished = true
    self:ExitSelfie()
  end, self)
  self:InitMenuSwitches()
end
function IngameSelfieSubsystem:OnRelease()
  self:SaveMenuSwitches()
  IngameSelfieSubsystem.__super.OnRelease(self)
end
function IngameSelfieSubsystem:OnGameStateChange(_, _, gameState)
  if gameState ~= "FightingState" or gameState ~= "FinishedState" then
    return
  end
  self:ExitSelfie()
end
function IngameSelfieSubsystem:OnApplicationReactivated()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:OnApplicationReactivated")
  self:ExitSelfie()
end
function IngameSelfieSubsystem:OnApplicationDeactivated()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:OnApplicationDeactivated")
end
function IngameSelfieSubsystem:InitMenuSwitches()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local version_util = require("client.common.version_util")
  local clientVersion = version_util.GetMainFormat(Client.GetAppVersion())
  local defaultMenuStatus = {
    bIsChangeOutfitPanelOpen = false,
    bIsChangeSpeedPanelOpen = false,
    bIsCameraEffectPanelOpen = false,
    bIsWeatherPanelOpen = false,
    savedVersion = clientVersion
  }
  self.menuStatus = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eIngamePhotoMenuStatus) or defaultMenuStatus
  local savedVersion = self.menuStatus.savedVersion
  if version_util.CompareVersionStandard(clientVersion, savedVersion) ~= 0 then
    self.menuStatus = defaultMenuStatus
  end
  log_tree("[DeanJYT] IngameSelfieSubsystem:InitMenuSwitches self.menuStatus = ", self.menuStatus)
end
function IngameSelfieSubsystem:SaveMenuSwitches()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.menuStatus, PlayerPrefsSystem.ePlayerPrefsType.eIngamePhotoMenuStatus)
end
function IngameSelfieSubsystem:ModeSpecificCheck()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if not MatchModeMgrSystem.IsSocialIslandMode(true) then
    return true
  end
  if UIManager.UI_Config_InGame.Social_Island_Main_RT == nil then
    return false
  end
  local Social_Island_Main_RT = UIManager.GetUI(UIManager.UI_Config_InGame.Social_Island_Main_RT)
  if not Social_Island_Main_RT then
    return false
  end
  if Social_Island_Main_RT:CheckCanEnterSelfieAndShowTips() ~= 0 then
    return false
  end
  return true
end
function IngameSelfieSubsystem:EnterSelfie()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie")
  if not self:ModeSpecificCheck() then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie cannot enter selfie due to invalid mode specific check")
    return
  end
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie cannot get PhotoGrapherSubSystem")
    return
  end
  if not PhotoGrapherSubSystem:CheckPawnStates() then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie CheckPawnStates failed")
    return
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local pc = GamePlayTools.GetPlayerControllerByIndex(0)
  if not slua.isValid(pc) then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie unable to get valid player controller")
    return
  end
  local character = GamePlayTools.GetCharacterByIndex(0)
  if not slua.isValid(character) then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie unable to get valid player character")
    return
  end
  local EPawnState = import("EPawnState")
  if character:HasState(EPawnState.GunADS) then
    ShowNotice(34316)
    return
  end
  local CheckGunSkillID = 1014405
  local CheckItemSkillID = 1039006
  local SkillMgr = character:GetSkillManager()
  if Game:IsValid(SkillMgr) and (SkillMgr:IsCastingSkillID(CheckGunSkillID) or SkillMgr:IsCastingSkillID(CheckItemSkillID)) then
    ShowNotice(7474)
    return
  end
  local playerState = character:GetPlayerStateSafety()
  if not slua.isValid(playerState) or not playerState.PhotoGrapherFeature then
    return
  end
  PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(true)
  return true
end
function IngameSelfieSubsystem:EnterSelfieWithSmartCamera(nTemplateID)
  self:SetTemplateID(nTemplateID)
  self:EnterSelfie()
end
function IngameSelfieSubsystem:EnterSelfieWithSmartCameraAndEmote(nTemplateID, EmoteList, SettingParams)
  if SettingParams and SettingParams.bSwitchWeapon then
    local uPlayerCharacter = GameplayData.GetPlayerCharacter()
    print(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfieWithSmartCameraAndEmote", uPlayerCharacter, SettingParams.bSwitchWeapon, SettingParams.bNeedSwitchBack)
    if slua.isValid(uPlayerCharacter) then
      local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
      uPlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
      if SettingParams.bSwitchWeapon and SettingParams.bNeedSwitchBack then
        print(bWriteLog and "IngameSelfieSubsystem:EnterSelfieWithSmartCameraAndEmote need switch back", self)
        self.bNeedSwitchToLastWeapon = true
      end
    end
  end
  self.bForbidNotice = SettingParams and SettingParams.bForbidNotice == true
  self.bAutoStartSmartCamera = SettingParams and SettingParams.bAutoStartSmartCamera == true
  if SettingParams and SettingParams.ExternalPhotoUIDisplayState ~= nil then
    self.ExternalPhotoUIDisplayState = SettingParams.ExternalPhotoUIDisplayState
  elseif SettingParams and SettingParams.bUseHighLightModeSetting == true then
    self.ExternalPhotoUIDisplayState = true
  else
    self.ExternalPhotoUIDisplayState = nil
  end
  self.bIgnoreMomentReleaseMUI = SettingParams and SettingParams.bIgnoreMomentReleaseMUI == true
  print(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfieWithSmartCameraAndEmote", nTemplateID, self.bForbidNotice, self.bAutoStartSmartCamera, self.bIgnoreMomentReleaseMUI)
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem then
    PhotoGrapherSubSystem:SetEmoteArray(EmoteList)
  end
  self:SetTemplateID(nTemplateID)
  self:EnterSelfie()
end
function IngameSelfieSubsystem:EnterSelfieWithSequenceCamera(nTemplateID, tSequenceConfig)
  self:SetSequenceConfig(nTemplateID, tSequenceConfig)
  self:EnterSelfie()
end
function IngameSelfieSubsystem:SetTemplateID(nTemplateID)
  if nTemplateID and 0 < nTemplateID then
    self.    self.bIsSetTemplateID = true
  end
end
function IngameSelfieSubsystem:SetSequenceConfig(nTemplateID, tSequenceConfig)
  if nTemplateID and tSequenceConfig then
    self.    self.    self.bIsSetSeqConfig = true
  end
end
function IngameSelfieSubsystem:ResetSequenceConfig()
  if self.bIsSetSeqConfig then
    self.nTemplateID = 0
    self.tSequenceConfig = nil
    self.bIsSetSeqConfig = false
  end
end
function IngameSelfieSubsystem:SetTlogTempID(nTemplateID)
  if not self.RecordTempIDForTlog[nTemplateID] then
    self.RecordTempIDForTlog[nTemplateID] = true
  end
end
function IngameSelfieSubsystem:HasRecordTlogTempID(nTemplateID)
  if not self.RecordTempIDForTlog[nTemplateID] then
    return false
  else
    return true
  end
end
function IngameSelfieSubsystem:ResetTemplateID()
  if self.bIsSetTemplateID then
    self.bIsSetTemplateID = false
    self.nTemplateID = 0
  end
end
function IngameSelfieSubsystem:CheckDefaultTemplateID()
  return self.bIsSetTemplateID
end
function IngameSelfieSubsystem:CheckDefaultSeq()
  return self.bIsSetSeqConfig
end
function IngameSelfieSubsystem:SetIsBlocking(block)
  print(bWriteLog and "IngameSelfieSubsystem:SetIsBlocking", block)
  self.bIsBlocking = block
end
function IngameSelfieSubsystem:AddIgnoreDamageType(nDamageType)
  if not nDamageType then
    return
  end
  if not self.__mIgnoreDamageTypes then
    self.__mIgnoreDamageTypes = {}
  end
  print(bWriteLog and "IngameSelfieSubsystem:AddIgnoreDamageType:" .. tostring(nDamageType))
  self.__mIgnoreDamageTypes[nDamageType] = true
end
function IngameSelfieSubsystem:RemoveIgnoreDamageType(nDamageType)
  if not nDamageType or not self.__mIgnoreDamageTypes then
    return
  end
  print(bWriteLog and "IngameSelfieSubsystem:RemoveIgnoreDamageType:" .. tostring(nDamageType))
  self.__mIgnoreDamageTypes[nDamageType] = nil
end
function IngameSelfieSubsystem:ClearIgnoreDamageTypes()
  self.__mIgnoreDamageTypes = nil
  print(bWriteLog and "IngameSelfieSubsystem:ClearIgnoreDamageTypes")
end
function IngameSelfieSubsystem:OnSelfieUIInitComplete()
  self.bIsAsyncLoadingUI = false
  local mainPhotoUI = UIManager.GetUI(self:GetCurPhotoMainUIConfig())
  if mainPhotoUI and mainPhotoUI:IsShow() then
    if self:CheckDefaultSeq() and self.nTemplateID and self.nTemplateID > 0 then
      mainPhotoUI:UseSmartCamera({}, self.nTemplateID, self.tSequenceConfig)
      self:ResetSequenceConfig()
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SELFIE_MODE)
  else
    print(bWriteLog and "IngameSelfieSubsystem:OnSelfieUIInitComplete mainPhotoUI not found")
    self:ExitSelfie()
  end
end
function IngameSelfieSubsystem:OnEnterSelfie()
  print(bWriteLog and "IngameSelfieSubsystem:OnEnterSelfie", self.bCountDownFinished)
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() and self.bCountDownFinished then
    print(bWriteLog and "IngameSelfieSubsystem:OnEnterSelfie enter battleresult")
    return
  end
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie cannot get PhotoGrapherSubSystem")
    return
  end
  if not PhotoGrapherSubSystem:CheckPawnStates() then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie CheckPawnStates failed")
    PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(false)
    return
  end
  if self.bIsBlocking then
    print(bWriteLog and "IngameSelfieSubsystem:OnEnterSelfie bIsBlocking")
    ShowNotice(7474)
    return
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local pc = GamePlayTools.GetPlayerControllerByIndex(0)
  if not slua.isValid(pc) then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie unable to get valid player controller")
    PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(false)
    return
  end
  local character = GamePlayTools.GetCharacterByIndex(0)
  if not slua.isValid(character) then
    ShowNotice(7474)
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:EnterSelfie unable to get valid player character")
    PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(false)
    return
  end
  if character.IsFPP or pc.CurCameraMode == EPlayerCameraMode.PCM_FPP then
    self.bIsFPPbeforeSelfie = true
    character.bForceChangePersonPerspective = true
    print(bWriteLog and "SetCurrentPersonPerspective aaaaa")
    character:SetCurrentPersonPerspective(false, false)
    character:LocalSwitchPersonPerspective(false, true, true)
    character:SetCurrentPersonPerspective(false, false)
    character:LocalSwitchPersonPerspective(false, true, true)
  else
    self.bIsFPPbeforeSelfie = false
  end
  character:SetIsSelfieMode(true)
  self.bIsIngameSelfieMode = true
  if not self.bForbidNotice then
    ShowNotice(45741, nil, PhotoGrapherConfig.EnterPhotographerTipsShowTime)
  end
  PhotoGrapherSubSystem:EnterNoUIMode()
  if self:CheckDefaultTemplateID() and self.nTemplateID and 0 < self.nTemplateID then
    log(bWriteLog and "[YY-D] IngameSelfieSubsystem:EnterSelfie nTemplateID = " .. tostring(self.nTemplateID))
    PhotoGrapherSubSystem:StartSmartCamera(self.nTemplateID)
    self:ResetTemplateID()
  end
  self.bIsAsyncLoadingUI = true
  UIManager.ShowUI(self:GetCurPhotoMainUIConfig(), self.bAutoStartSmartCamera, self.ExternalPhotoUIDisplayState)
  if slua.isValid(pc) then
    self:AddControlEvent(pc, "OnPostTakeDamageDelegate", self.OnSelfieModeInterrupt, self)
  end
end
function IngameSelfieSubsystem:ExitSelfie()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:ExitSelfie")
  self:ClearIgnoreDamageTypes()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local character = GamePlayTools.GetCharacterByIndex(0)
  if not slua.isValid(character) then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:ExitSelfie unable to get valid player character")
    return
  end
  if self.bIsIngameSelfieMode == false then
    print(bWriteLog and "IngameSelfieSubsystem:ExitSelfie Client already exit")
    return
  end
  if character:GetIsSelfieMode() then
    character:SetIsSelfieMode(false)
  end
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:ExitSelfie cannot get PhotoGrapherSubSystem")
    return
  end
  PhotoGrapherSubSystem:LeaveNoUIMode()
  self.bIsIngameSelfieMode = false
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_EXIT_SELFIE_MODE)
  self.bIsAsyncLoadingUI = false
  UIManager.CloseUI(self:GetCurPhotoMainUIConfig())
  UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_1_UIBP)
  UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_2_UIBP)
  UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_3_UIBP)
  if not self.bIgnoreMomentReleaseMUI then
    UIManager.CloseUI(UIManager.UI_Config.MomentReleaseMessage)
  end
  local pc = GamePlayTools.GetPlayerControllerByIndex(0)
  if slua.isValid(pc) and self:HasControlEventByControl(pc, "OnPostTakeDamageDelegate") then
    self:RemoveControlEvent(pc, "OnPostTakeDamageDelegate")
  end
  local EPawnState = import("EPawnState")
  if self.bIsFPPbeforeSelfie and not character:HasState(EPawnState.InParachute) then
    character:SetCurrentPersonPerspective(true, true)
    character:LocalSwitchPersonPerspective(true, true, true)
    character.bForceChangePersonPerspective = false
  elseif slua.isValid(pc) and pc:ShouldForceFPPView(character) then
    character:SetCurrentPersonPerspective(true, true)
    character:LocalSwitchPersonPerspective(true, true, true)
    character.bForceChangePersonPerspective = false
  end
  PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(false)
  print(bWriteLog and "IngameSelfieSubsystem:ExitSelfie SwitchToLastWeapon", self, self.bNeedSwitchToLastWeapon, self.bIgnoreMomentReleaseMUI)
  if self.bNeedSwitchToLastWeapon then
    character:SwitchToLastWeapon(true, false, false)
    self.bNeedSwitchToLastWeapon = false
  end
  self.bForbidNotice = nil
  self.bAutoStartSmartCamera = nil
  self.bIgnoreMomentReleaseMUI = nil
  self.ExternalPhotoUIDisplayState = nil
end
function IngameSelfieSubsystem:GetIsInSelfieMode()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local character = GamePlayTools.GetCharacterByIndex(0)
  if not slua.isValid(character) then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:GetIsInSelfieMode unable to get valid player character")
    return false
  end
  return character:GetIsSelfieMode()
end
function IngameSelfieSubsystem:CheckIgnoreDamageTypes(DamageType)
  if DamageType and self.__mIgnoreDamageTypes and self.__mIgnoreDamageTypes[DamageType] then
    print(bWriteLog and "IngameSelfieSubsystem:OnSelfieModeInterrupt ignore DamageType:" .. tostring(DamageType))
    return true
  end
  return false
end
function IngameSelfieSubsystem:OnSelfieModeInterrupt(Damage, DamageEvent, EventInstigator, DamageCauser, DamageType)
  print(bWriteLog and "IngameSelfieSubsystem:OnSelfieModeInterrupt DamageType:" .. tostring(DamageType))
  if 0 < Damage then
    if self:CheckIgnoreDamageTypes(DamageType) then
      return
    end
    self:ClearIgnoreDamageTypes()
    self:ExitSelfie()
    self.bIsAsyncLoadingUI = false
    UIManager.CloseUI(self:GetCurPhotoMainUIConfig())
    UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_1_UIBP)
    UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_2_UIBP)
    UIManager.CloseUI(UIManager.UI_Config_InGame.Ingame_Photo_Popup_3_UIBP)
    UIManager.CloseUI(UIManager.UI_Config.MomentReleaseMessage)
  end
end
function IngameSelfieSubsystem:ToggleMainControlUIVisibility(bVisible)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not MainControlPanelTochButton then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if MainControlPanelTochButton.ParachutingLayer then
    UIUtil.SetWidgetVisible(MainControlPanelTochButton.ParachutingLayer, bVisible)
  end
  if MainControlPanelTochButton.ShootingLayer then
    UIUtil.SetWidgetVisible(MainControlPanelTochButton.ShootingLayer, bVisible)
  end
  if MainControlPanelTochButton.MainControlBaseUI then
    UIUtil.SetWidgetVisible(MainControlPanelTochButton.MainControlBaseUI, bVisible)
  end
  if MainControlPanelTochButton.VehicleControlLayer then
    UIUtil.SetWidgetVisible(MainControlPanelTochButton.VehicleControlLayer, bVisible)
  end
  local ui = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
  if ui then
    UIUtil.SetWidgetVisible(ui, bVisible)
  end
end
function IngameSelfieSubsystem:StartCameraScreenShot()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:StartCameraScreenShot")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWithTag("Selfie")
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_START_CAMERA_SCREENSHOT)
  self:ToggleMainControlUIVisibility(false)
  local ScreenshotMaker = import("ScreenshotMaker")
  self.CapturePath = ScreenshotMaker.MakePicture(true)
  self:AddTimer(0, function()
    repeat
      coroutine.yield(0.1)
    until ScreenshotMaker.HasCaptured(self.CapturePath)
    ShareSelfieShowUI(self.CapturePath, function()
      self:OnCloseShareFunc()
    end)
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end)
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if not PhotoGrapherSubSystem then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:StartCameraScreenShot cannot get PhotoGrapherSubSystem")
    return
  end
  local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
  PhotoGrapherSubSystem:ReportPhotographerOp(PhotographerOptype.TakePhoto)
end
function IngameSelfieSubsystem:OnCloseShareFunc()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:OnCloseShareFunc")
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_END_CAMERA_SCREENSHOT)
  self:ToggleMainControlUIVisibility(true)
  self:RestoreControlInterface()
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem then
    PhotoGrapherSubSystem:OperationUIFadeOut()
  end
end
function IngameSelfieSubsystem:CheckModeCanEnterSelfie()
  if not GameStatus.IsInFightingStatus() then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:CheckModeCanEnterSelfie not in fight, cannot use selfie mode")
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:CheckModeCanEnterSelfie invalid game state")
    return false
  end
  local TableUtil = require("common.table_util")
  if TableUtil.IsInTable(PhotoGrapherConfig.PhotographerDisableModeType, uGameState.GameModeType) then
    return false
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType, _ = GameMainConfig.GetModType()
  if TableUtil.IsInTable(PhotoGrapherConfig.PhotographerDisableMainModType, ModeType) then
    return false
  end
  if TableUtil.IsInTable(PhotoGrapherConfig.PhotographerDisableModeID, GameMainConfig.GetModeID()) then
    return false
  end
  return true
end
function IngameSelfieSubsystem:CheckPhotoEditButtonState(Button_PhotoEdit, Image_PhotoEditReddot)
  if not slua.isValid(Button_PhotoEdit) then
    return false
  end
  Button_PhotoEdit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if LobbySystem.CheckOpen(BP_ENUM_MODULE_SELFIE_SWITCH) and self:CheckModeCanEnterSelfie() then
    local reddotStatus = self:GetReddotStatus()
    if not reddotStatus.entrance then
      Image_PhotoEditReddot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      Image_PhotoEditReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:CheckPhotoEditButtonState show photo button")
    Button_PhotoEdit:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    return true
  else
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:CheckPhotoEditButtonState hide photo button")
    Button_PhotoEdit:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return false
  end
end
function IngameSelfieSubsystem:OnButton_PhotoEditClick(Image_PhotoEditReddot)
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:OnButton_PhotoEditClick")
  if false == require("GameLua.Mod.SocialIsland.GamePlay.SI_BattleInterface").SocialIslandEmoteCheck() then
    return
  end
  self:EnterSelfie()
  local reddotStatus = self:GetReddotStatus()
  if not reddotStatus.entrance then
    self:ModifyReddotStatus("entrance", true)
    self:SaveSelfieReddotStatus()
    if Image_PhotoEditReddot then
      Image_PhotoEditReddot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_ENTER_SELFIE_MODE)
end
function IngameSelfieSubsystem:RestoreControlInterface()
  log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:RestoreControlInterface")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWithTag("Selfie")
  end
end
function IngameSelfieSubsystem:LoadSelfieReddotStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.reddotStatus = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eIngamePhotoReddotStatus) or {}
end
function IngameSelfieSubsystem:SaveSelfieReddotStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.reddotStatus, PlayerPrefsSystem.ePlayerPrefsType.eIngamePhotoReddotStatus)
end
function IngameSelfieSubsystem:GetReddotStatus()
  if not self.reddotStatus then
    self:LoadSelfieReddotStatus()
  end
  return self.reddotStatus
end
function IngameSelfieSubsystem:ModifyReddotStatus(key, value)
  self.reddotStatus[key] = value
end
function IngameSelfieSubsystem:GetCurPhotoMainUIConfig()
  return UIManager.UI_Config_InGame.Ingame_Photo_UIBP
end
function IngameSelfieSubsystem:GetEmoteItemList()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local pc = GamePlayTools.GetPlayerControllerByIndex(0)
  if not slua.isValid(pc) then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:GetEmoteItemList invalid player controller")
    return {}
  end
  local BackpackUtils = import("BackpackUtils")
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BackPackComp = STExtraBlueprintFunctionLibrary.GetBackpackComponentFromController(pc)
  if not slua.isValid(BackPackComp) then
    log(bWriteLog and "[DeanJYT] IngameSelfieSubsystem:GetEmoteItemList invalid BackPackComp")
    return {}
  end
  local EmoteItems = BackpackUtils.GetEmoteItemInBackpack(BackPackComp)
  return EmoteItems
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, IngameSelfieSubsystem)
local PhotoGrapherSubSystem = {}
local EShootWeaponShootMode = import("EShootWeaponShootMode")
local ESmartCameraTemplateType = import("ESmartCameraTemplateType")
local uCameraModifierBaseClass = import("CameraModifier_SmartPhotographer")
local PawnState = import("EPawnState")
local USTExtraVehicleUtils = import("STExtraVehicleUtils")
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
local uGameplayStatics = import("GameplayStatics")
local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PhotoGrapherConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.PhotoGrapherConfig")
local DSSwitchID = 63
local SmartPhotographerClass = "/Game/BluePrints/CamMaster/BP_SmartPhotographer.BP_SmartPhotographer"
function PhotoGrapherSubSystem:_PostConstruct()
end
function PhotoGrapherSubSystem:OnInit()
  print(bWriteLog and "PhotoGrapherSubSystem:OnInit")
  self.ShootingUISpecialLayer = {
    "CustomSkillLayer",
    "CanvasPanel_CustomWeaponUI",
    "Customize_ThrowPlus",
    "CustomShootRed",
    "ThrowTimeInfo",
    "HistoricalNews",
    "HistoricalNewsCanvasPanel",
    "NewbieGuideCanvas"
  }
  self.UIContainerDynamicWidget = {
    "GameLua.Mod.BaseMod.Client.Like.IngameLikeUIBP",
    "GameLua.Mod.BaseMod.Client.Like.IngameKillIconUIBP",
    "GameLua.Mod.Library.Client.MiniTv.MiniTvBannerTipsUI",
    "GameLua.Mod.BaseMod.Client.InGameUI.WeakNetworkIcon",
    "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoItem",
    "GameLua.Mod.BaseMod.Client.KillInfoTips.LeftKillInfoItem",
    "GameLua.Mod.Library.Client.Elevator.ElevatorRequestUI",
    "GameLua.Mod.Library.Client.Elevator.ElevatorMainUI"
  }
  self.ExcludedUIName = {
    SingleTrain_Target_Item_UIBP_C = true,
    DanceTogether_UIBP_C = true,
    PlanPH_Party_Dance_Status_UIBP_C = true
  }
  if Client then
    self.TopLevelUIList = {
      UIManager.UI_Config_InGame.GameOverCountDown_UIBP,
      UIManager.UI_Config_InGame.MVPStatueMainRT,
      UIManager.UI_Config_InGame.CrossbowChangeBulletUI,
      UIManager.UI_Config_InGame.StoneGateInteractiveUI,
      UIManager.UI_Config_InGame.SingleReviveCountUI,
      UIManager.UI_Config_InGame.TeammateReviveStateIcon,
      UIManager.UI_Config_InGame.KingKongEffect
    }
  end
  self.PawnStateDisable = {
    PawnState.GunADS,
    PawnState.Dying,
    PawnState.Dead,
    PawnState.SwitchPP,
    PawnState.Skill,
    PawnState.InPlane,
    PawnState.InParachute,
    PawnState.Variation,
    PawnState.CarryBack,
    PawnState.BeCarriedBack,
    PawnState.AirAttackLocator,
    PawnState.ControlUnmannedVehicle,
    PawnState.RemoteControlVehicle,
    PawnState.InActivityActor,
    PawnState.DriveMovePlatForm,
    PawnState.Build
  }
  self.MinCameraLenth = 220
  self.MaxCameraLenth = 2000
  self.CacheTargetArmLenth = -1
  self.CacheVehicleTargetArmLenth = -1
  self.CahceJoyStickopacity = -1
  self.AttrName = "EmotePlayRate"
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_INIT, self.OnSmartCameraAdd, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_SMARTCAMERA_END, self.OnSmartCameraRemove, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnSmartCamerainterrupt, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED_EX, self.OnSmartCamerainterrupt, self)
  self.bIsPhotoGrapherMode = false
  self.EmoteIDList = {}
  self.CurrentTemplateType = ESmartCameraTemplateType.Player
  self.bIsSkySphereOn = false
  self.LastPlayRate = 1
  self.EmotePlayRateLimit = 0.001
  self.NeedRportTimes = {
    PhotoGrapherConfig.PhotographerOptype.TakePhoto
  }
  self.UseRecord = {}
  self.TransparentTime = 5
end
function PhotoGrapherSubSystem:_DataDefine()
  return {TemplateID = -1}
end
function PhotoGrapherSubSystem:OnUIShow(_, _, uiCfg)
  local UIUtil = require("client.common.ui_util")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    return
  end
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if not TransparentUIModeSubsystem then
    return
  end
  for _, WidgetModuleName in pairs(self.UIContainerDynamicWidget) do
    if uiCfg and WidgetModuleName == uiCfg.moduleName and uiCfg.path then
      local SplitPos = string.find(uiCfg.path, "%.")
      local WidgetName
      if SplitPos then
        WidgetName = string.sub(uiCfg.path, SplitPos + 1)
      end
      print(bWriteLog and "PhotoGrapherSubSystem:OnUIShow WidgetName", WidgetName, SplitPos)
      if WidgetName then
        print(bWriteLog and "PhotoGrapherSubSystem:OnUIShow2 WidgetName", WidgetName, SplitPos)
        local UIContainer = MainControlPanelTochButton:GetParent()
        local UKismetSystemLibrary = import("KismetSystemLibrary")
        if slua.isValid(UIContainer) then
          local ChildWidgetNum = UIContainer:GetChildrenCount()
          for index = ChildWidgetNum, 1, -1 do
            local ChildWidget = UIContainer:GetChildAt(index - 1)
            local ChildWidgetName = UKismetSystemLibrary.GetClassDisplayName(ChildWidget:GetClass())
            print(bWriteLog and "ChildWidgetName", ChildWidgetName)
            if string.find(ChildWidgetName, WidgetName) then
              TransparentUIModeSubsystem:SetWidgetForceNotVisible(false, ChildWidget)
            end
          end
        end
      end
    end
  end
end
function PhotoGrapherSubSystem:StartSmartCamera(TemplateID, tSequenceSetting)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    self:OnEmotePlayEnd()
    return
  end
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if uSmartCameraModifier then
    uSmartCameraModifier:StopCamMaster()
  end
  local cfg = CDataTable.GetTableData("CamMaster", TemplateID)
  if cfg and cfg.TemplateType == ESmartCameraTemplateType.Pet then
    self.CurrentTemplateType = ESmartCameraTemplateType.Pet
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if not slua.isValid(MainControlPanelTochButton) then
      self:OnEmotePlayEnd()
      return
    end
    MainControlPanelTochButton:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    PlayerController:SetVirtualJoystickWidgetRender(1)
  end
  local FMovieSceneSequencePlaybackSettings = import("MovieSceneSequencePlaybackSettings")
  local MovieSceneSequencePlaybackSettings = FMovieSceneSequencePlaybackSettings()
  if tSequenceSetting and tSequenceSetting.StartTime and tSequenceSetting.StartTime > 0 then
    print(bWriteLog and "PhotoGrapherSubSystem:StartSmartCamera StartTime = " .. tostring(tSequenceSetting.StartTime))
    MovieSceneSequencePlaybackSettings.StartTime = tSequenceSetting.StartTime
  end
  print(bWriteLog and "PhotoGrapherSubSystem:StartSmartCamera", TemplateID)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_ENTER_SMART_CAMERA, TemplateID)
  if uSmartCameraModifier then
    uSmartCameraModifier:SetSequenceSettings(MovieSceneSequencePlaybackSettings)
    uSmartCameraModifier:StartCamMaster(TemplateID)
  else
    self.uSmartCameraModifier = uCameraModifierBaseClass.InviteSmartPhotographer(PlayerController, self.uSmartCameraModifierClass)
    if self.uSmartCameraModifier then
      self.uSmartCameraModifier:SetSequenceSettings(MovieSceneSequencePlaybackSettings)
      self.uSmartCameraModifier:StartCamMaster(TemplateID)
    end
  end
  self:OnPlayEmoteBegin()
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ENTER_SMART_CAMERA, TemplateID)
  local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
  self:ReportPhotographerOp(PhotographerOptype.Template)
  local SuperData = self:GetSuperData()
  SuperData.end
function PhotoGrapherSubSystem:StopSmartCamera()
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if uSmartCameraModifier then
    uSmartCameraModifier:StopCamMaster()
  end
  self:OnCamereSeqFinish()
  local SuperData = self:GetSuperData()
  SuperData.TemplateID = -1
end
function PhotoGrapherSubSystem:OnPlayEmoteBegin()
  if self.CurrentTemplateType == ESmartCameraTemplateType.Player then
    self:TryPlayNextEmote()
  elseif self.CurrentTemplateType == ESmartCameraTemplateType.Pet then
    local PlayerCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(PlayerCharacter) then
      self:OnEmotePlayEnd()
      print(bWriteLog and "PhotoGrapherSubSystem:OnPlayEmoteBegin PlayerCharacter is nil")
      return
    end
    if not slua.isValid(PlayerCharacter.PetComponent_BP) or not slua.isValid(PlayerCharacter.PetComponent_BP.PetPawn) then
      self:OnEmotePlayEnd()
      print(bWriteLog and "PhotoGrapherSubSystem:OnPlayEmoteBegin PetPawn or PetComponent_BP is nil")
      return
    end
    self.CurrentPetPawn = PlayerCharacter.PetComponent_BP.PetPawn
    self:AddControlEvent(self.CurrentPetPawn, "OnPetEmoteReadyToPlayNext", self.PlayNextPetEmote, self)
    self:PlayNextPetEmote()
    print(bWriteLog and "PhotoGrapherSubSystem:OnPlayEmoteBegin PlayNextPetEmote")
  end
  print(bWriteLog and "PhotoGrapherSubSystem:OnPlayEmoteBegin successed")
end
function PhotoGrapherSubSystem:HideMainControlPanelUI()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    return
  end
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if not TransparentUIModeSubsystem then
    return
  end
  if not slua.isValid(ShootingUIPanel) then
    return
  end
  local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
  MainControlPanelTochButton:ApplyLayout(UILayoutConfig.LayoutNameConfig.PhotographerLayout)
  for _, WidgetName in pairs(self.ShootingUISpecialLayer) do
    if slua.isValid(ShootingUIPanel[WidgetName]) then
      TransparentUIModeSubsystem:SetWidgetForceNotVisible(false, ShootingUIPanel[WidgetName])
    end
  end
  local UIContainer = MainControlPanelTochButton:GetParent()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if slua.isValid(UIContainer) then
    local ChildWidgetNum = UIContainer:GetChildrenCount()
    for index = ChildWidgetNum, 1, -1 do
      local ChildWidget = UIContainer:GetChildAt(index - 1)
      local ChildWidgetName = UKismetSystemLibrary.GetClassDisplayName(ChildWidget:GetClass())
      if not string.find(ChildWidgetName, "MainControlPanelTochButton") and not self.ExcludedUIName[ChildWidgetName] then
        TransparentUIModeSubsystem:SetWidgetForceNotVisible(false, ChildWidget)
      end
    end
  end
  local SkillLayer = ShootingUIPanel.SkillLayer
  if slua.isValid(SkillLayer) then
    local ChildWidgetNum = SkillLayer:GetChildrenCount()
    for index = ChildWidgetNum, 1, -1 do
      local ChildWidget = SkillLayer:GetChildAt(index - 1)
      local ChildWidgetName = UKismetSystemLibrary.GetClassDisplayName(ChildWidget:GetClass())
      if not string.find(ChildWidgetName, "SkillBuildMVPButtonSlot_BP") then
        TransparentUIModeSubsystem:SetWidgetForceNotVisible(false, ChildWidget)
      end
    end
  end
  if self.TopLevelUIList then
    for _, WidgetConfig in pairs(self.TopLevelUIList) do
      if WidgetConfig and UIManager.IsUIShow(WidgetConfig) then
        local ui = UIManager.GetUI(WidgetConfig)
        if ui then
          TransparentUIModeSubsystem:SetWidgetForceNotVisible(false, ui.UIRoot)
        end
      end
    end
  end
  local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
  if BattlePopTips then
    BattlePopTips:StartTipsLimitationWithWhiteList(PhotoGrapherConfig.TipsWhiteList)
  end
end
function PhotoGrapherSubSystem:EnterNoUIMode()
  local UIUtil = require("client.common.ui_util")
  print(bWriteLog and "PhotoGrapherSubSystem:EnterNoUIMode begin")
  if self.bIsPhotoGrapherMode then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self:HideMainControlPanelUI()
  self.CahceJoyStickopacity = 1.0
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    local JoystickCustomData = SettingSubsystem:GetLayoutDetailByType(2)
    if JoystickCustomData then
      self.CahceJoyStickopacity = JoystickCustomData.Opacity
    end
  end
  self.uSmartCameraModifierClass = slua.loadClass(self:GetSmartPhotographerClassPath())
  if slua.isValid(self.uSmartCameraModifierClass) and PlayerController.SetSmartSubClass then
    PlayerController:SetSmartSubClass(self.uSmartCameraModifierClass)
  end
  self.uSmartCameraModifier = uCameraModifierBaseClass.InviteSmartPhotographer(PlayerController, self.uSmartCameraModifierClass)
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local SuperData = self:GetSuperData()
  SuperData.TemplateID = -1
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PHOTOGRAPHER_STATE, true)
  local uCurWeapon = PlayerCharacter:GetCurrentWeapon()
  if slua.isValid(uCurWeapon) and uCurWeapon.IsUsingGrenadeLaunch and uCurWeapon:IsUsingGrenadeLaunch() then
    local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bGrenadeLaunchEnterNoUIMode, true)
  end
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if settingConfig.NoUIOpacity then
    self:SetAllUIOpacity(settingConfig.NoUIOpacity, false)
  end
  self.bIsPhotoGrapherMode = true
  PlayerCharacter.bIsHideCrossHairType = true
  self:CreateGreenSkySphere()
  if self.FadeOutTimer then
    self:RemoveGameTimer(self.FadeOutTimer)
    self.FadeOutTimer = nil
  end
  self.FadeOutTimer = self:AddGameTimer(self.TransparentTime, false, function()
    self:OperationUIFadeOut()
  end)
  self:AddControlEvent(PlayerCharacter, "OnPostTakeDamage", self.OnSmartCamerainterrupt, self)
  self:AddControlEvent(PlayerCharacter, "OnDetachedFromVehicle", self.OnDetachedFromVehicle, self)
  self:AddControlEvent(PlayerController, "ClientOnEnterVehicle", self.OnEnterVehicle, self)
  self:AddControlEvent(PlayerController, "ClientOnChangeVehicleSeatCompletedDelegate", self.OnChangedVehicleSeat, self)
  self:AddControlEvent(PlayerController, "OnCharacterStatesChangeFilter", self.CharacterStateStateEnterHandler, self)
  if PlayerCharacter.GetPlayEmoteComponent then
    local uPlayEmoteComp = PlayerCharacter:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) then
      self:AddControlEvent(uPlayEmoteComp, "EmoteReadyToPlayNext", self.OnCharacterPlayNextEmote, self)
    end
  end
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW_FOR_BATTLE, self.OnUIShow, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_WEAPON_FIRE_SHOT, self.OnWeaponFireShot, self)
  if self.screenInput then
    self.screenInput:Shutdown()
    self.screenInput = nil
  end
  local InputClass = import("ScreenInput")
  local worldContextObject = UIUtil.GetGameInstance()
  self.screenInput = InputClass(worldContextObject)
  self.screenInput:Init()
  self:AddControlEvent(self.screenInput, "OnMouseButtonDown", function()
    self:OperationUIFadeIn()
  end)
  if PlayerController.bPCInputSwitcher == true then
    self.HasChangedPCInputSwitcher = true
    PlayerController.bPCInputSwitcher = false
  end
  if PlayerCharacter:Hasstate(PawnState.DriveVehicle) or PlayerCharacter:Hasstate(PawnState.InVehicle) then
    self:ReportPhotographerOp(PhotoGrapherConfig.PhotographerOptype.UseInVehicle)
  end
  PlayerController:BroadcastUIMessage("StopFreeCamera", 0, "", "")
  print(bWriteLog and "PhotoGrapherSubSystem:EnterNoUIMode end")
end
function PhotoGrapherSubSystem:ShowMainControlPanelUI()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  MainControlPanelTochButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  PlayerController:SetVirtualJoystickWidgetRender(0)
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  local TransparentUIModeSubsystem = SubsystemMgr:Get("TransparentUIModeSubsystem")
  if not TransparentUIModeSubsystem then
    return
  end
  if not slua.isValid(ShootingUIPanel) then
    return
  end
  local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
  MainControlPanelTochButton:UnApplyLayout(UILayoutConfig.LayoutNameConfig.PhotographerLayout)
  if 0 < #TransparentUIModeSubsystem.SpecialHideWidgets then
    for index, Value in ipairs(TransparentUIModeSubsystem.SpecialHideWidgets) do
      if slua.isValid(Value) then
        TransparentUIModeSubsystem:SetWidgetForceNotVisible(true, Value)
      end
    end
  end
  for _, WidgetName in pairs(self.ShootingUISpecialLayer) do
    if slua.isValid(ShootingUIPanel[WidgetName]) then
      TransparentUIModeSubsystem:SetWidgetForceNotVisible(true, ShootingUIPanel[WidgetName])
    end
  end
  local UIContainer = MainControlPanelTochButton:GetParent()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if slua.isValid(UIContainer) then
    local ChildWidgetNum = UIContainer:GetChildrenCount()
    for index = ChildWidgetNum, 1, -1 do
      local ChildWidget = UIContainer:GetChildAt(index - 1)
      local ChildWidgetName = UKismetSystemLibrary.GetClassDisplayName(ChildWidget:GetClass())
      if not string.find(ChildWidgetName, "MainControlPanelTochButton") and not self.ExcludedUIName[ChildWidgetName] then
        TransparentUIModeSubsystem:SetWidgetForceNotVisible(true, ChildWidget)
      end
    end
  end
  local SkillLayer = ShootingUIPanel.SkillLayer
  if slua.isValid(SkillLayer) then
    local ChildWidgetNum = SkillLayer:GetChildrenCount()
    for index = ChildWidgetNum, 1, -1 do
      local ChildWidget = SkillLayer:GetChildAt(index - 1)
      local ChildWidgetName = UKismetSystemLibrary.GetClassDisplayName(ChildWidget:GetClass())
      if not string.find(ChildWidgetName, "SkillBuildMVPButtonSlot_BP") then
        TransparentUIModeSubsystem:SetWidgetForceNotVisible(true, ChildWidget)
      end
    end
  end
  if self.TopLevelUIList then
    for _, WidgetConfig in pairs(self.TopLevelUIList) do
      if WidgetConfig and UIManager.IsUIShow(WidgetConfig) then
        local ui = UIManager.GetUI(WidgetConfig)
        if ui then
          TransparentUIModeSubsystem:SetWidgetForceNotVisible(true, ui.UIRoot)
        end
      end
    end
  end
end
function PhotoGrapherSubSystem:LeaveNoUIMode()
  print(bWriteLog and "PhotoGrapherSubSystem:LeaveNoUIMode")
  if not self.bIsPhotoGrapherMode then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  self:ShowMainControlPanelUI()
  local SuperData = self:GetSuperData()
  SuperData.TemplateID = -1
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PHOTOGRAPHER_STATE, false)
  local uCurWeapon = PlayerCharacter:GetCurrentWeapon()
  if slua.isValid(uCurWeapon) and uCurWeapon.IsUsingGrenadeLaunch and uCurWeapon:IsUsingGrenadeLaunch() then
    local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bGrenadeLaunchEnterNoUIMode, false)
  end
  local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
  if BattlePopTips then
    BattlePopTips:StopTipsLimitation()
  end
  self:SetAllUIOpacity(1, false)
  self:OperationUIFadeIn()
  self.bIsPhotoGrapherMode = false
  self.CacheZoomValue = nil
  PlayerCharacter.bIsHideCrossHairType = false
  uSmartCameraModifier:StopCamMaster()
  self:OnCamereSeqFinish()
  self:DelSkySphere()
  self:DestoryLevelSequence()
  self:ResumeSpringArmLength()
  if self.CahceJoyStickopacity > 0 then
    PlayerController:SetJoyStickOpacityNotUpdate(self.CahceJoyStickopacity)
    self.CahceJoyStickopacity = -1
  end
  uCameraModifierBaseClass.SayGoodbyeToSmartPhotographer(PlayerController, uSmartCameraModifier)
  self:RemoveEvent()
  if self.screenInput then
    self.screenInput:Shutdown()
    self.screenInput = nil
  end
  if PlayerController.bPCInputSwitcher ~= nil and self.HasChangedPCInputSwitcher == true then
    self.HasChangedPCInputSwitcher = nil
    PlayerController.bPCInputSwitcher = true
  end
  print(bWriteLog and "PhotoGrapherSubSystem:LeaveNoUIMode End")
end
function PhotoGrapherSubSystem:CheckPawnStates()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return false
  end
  if not self.PawnStateDisable then
    return false
  end
  for _, StateDis in pairs(self.PawnStateDisable) do
    if PlayerPawn:Hasstate(StateDis) then
      return false
    end
  end
  local HighlightMomentSubsystem = SubsystemMgr:Get("HighlightMomentSubsystem")
  local bPlayingVehicleHighlight = HighlightMomentSubsystem and HighlightMomentSubsystem.bPlayingVehicleHighlight
  if (PlayerPawn:Hasstate(PawnState.DriveVehicle) or PlayerPawn:Hasstate(PawnState.InVehicle)) and not bPlayingVehicleHighlight then
    if not self:CheckVehicleDSSwitch() then
      print(bWriteLog and "PhotoGrapherSubSystem:CheckPawnStates, return false")
      return false
    end
    if self:CheckIsInForbiddenVehicle() then
      return false
    end
  end
  if PlayerPawn:IsOnFireBalloon() then
    return false
  end
  if PlayerPawn.LifterControl and PlayerPawn.LifterControl:IsUsingLifter() then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckPawnStates IsUsingLifter, return false")
    return false
  end
  return true
end
function PhotoGrapherSubSystem:CheckIsInSameTeam(uPC, uTargetCharacter)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local IsTeam = TeamUpNewSystem.GetMemberInfo(uTargetCharacter.PlayerUID) ~= nil
  return IsTeam
end
function PhotoGrapherSubSystem:RemoveEvent()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  self:RemoveControlEvent(PlayerCharacter, "OnPostTakeDamage")
  self:RemoveControlEvent(PlayerCharacter, "OnDetachedFromVehicle")
  self:RemoveControlEvent(PlayerController, "ClientOnEnterVehicle")
  self:RemoveControlEvent(PlayerController, "OnCharacterStatesChange")
  self:RemoveControlEvent(PlayerController, "ClientOnChangeVehicleSeatCompletedDelegate")
  self:RemoveCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW_FOR_BATTLE)
  self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_ON_WEAPON_FIRE_SHOT)
  if PlayerCharacter.GetPlayEmoteComponent then
    local uPlayEmoteComp = PlayerCharacter:GetPlayEmoteComponent()
    if slua.isValid(uPlayEmoteComp) then
      self:RemoveControlEvent(uPlayEmoteComp, "EmoteReadyToPlayNext")
    end
  end
end
function PhotoGrapherSubSystem:CharacterStateStateEnterHandler(state)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  if not self.PawnStateDisable then
    return
  end
  for _, StateDis in pairs(self.PawnStateDisable) do
    if PlayerPawn:Hasstate(StateDis) then
      self:LeaveNoUIMode()
      local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
      if IngameSelfieSubsystem then
        IngameSelfieSubsystem:ExitSelfie()
      end
      local CreativeModeIngameSelfieSubsystem = SubsystemMgr:Get("CreativeModeIngameSelfieSubsystem")
      if CreativeModeIngameSelfieSubsystem then
        CreativeModeIngameSelfieSubsystem:ExitSelfie()
      end
      return
    end
  end
end
function PhotoGrapherSubSystem:SetEmoteArray(EmoteIDs)
  self.EmoteIDList = EmoteIDs
end
function PhotoGrapherSubSystem:OnCharacterPlayNextEmote()
  if #self.EmoteIDList > 0 then
    self:DisUseWeapon()
  end
  self:PlayNextEmote()
end
function PhotoGrapherSubSystem:DisUseWeapon()
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not (slua.isValid(PlayerCharacter) and PlayerCharacter.OnPlayEmote) or not PlayerCharacter:GetWeaponManager() then
    return
  end
  print(bWriteLog and "PhotoGrapherSubSystem:DisUseWeapon")
  PlayerCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
end
function PhotoGrapherSubSystem:UseWeapon()
  if not self.LastWeaponSlot then
    return
  end
  print(bWriteLog and "PhotoGrapherSubSystem:UseWeapon", self.LastWeaponSlot)
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not (slua.isValid(PlayerCharacter) and PlayerCharacter.OnPlayEmote) or not PlayerCharacter:GetWeaponManager() then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if slua.isValid(WeaponManager) and self.LastWeaponSlot ~= ESurviveWeaponPropSlot.SWPS_None then
    PlayerCharacter:SwitchWeaponBySlot(self.LastWeaponSlot, true, true, false)
    self.LastWeaponSlot = nil
  end
end
function PhotoGrapherSubSystem:TryPlayNextEmote()
  if #self.EmoteIDList <= 0 then
    return
  end
  self.LastWeaponSlot = nil
  local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.OnPlayEmote then
    return
  end
  if PlayerCharacter:GetWeaponManager() and PlayerCharacter:GetWeaponManager():GetCurrentUsingPropSlot() ~= ESurviveWeaponPropSlot.SWPS_None then
    self.LastWeaponSlot = PlayerCharacter:GetWeaponManager():GetCurrentUsingPropSlot()
  end
  self:PlayNextEmote()
end
function PhotoGrapherSubSystem:PlayNextEmote()
  if #self.EmoteIDList <= 0 then
    self:UseWeapon()
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.OnPlayEmote then
    return
  end
  local bIsMovableEmote = false
  local EmoteSubSystem = SubsystemMgr:Get("EmoteSubSystem")
  if EmoteSubSystem then
    bIsMovableEmote = EmoteSubSystem:TryPlayMovableEmote(self.EmoteIDList[1], PlayerCharacter)
  end
  if not bIsMovableEmote then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    logic_emote.PlayEmote(PlayerCharacter, self.EmoteIDList[1])
  end
  PlayerCharacter.IsHandedWeaponBeforePlayEmote = false
  self.LastEmoteID = self.EmoteIDList[1]
  table.remove(self.EmoteIDList, 1)
end
function PhotoGrapherSubSystem:SetTargetArmLenthWithZoom(Value)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local DefaultCameraLenth = 0
  local PlayerCamera = PlayerPawn.SpringArmComp
  if not slua.isValid(PlayerCamera) then
    print(bWriteLog and "PhotoGrapherSubSystem:SetTargetArmLenthWithZoom PlayerCamera is nil")
    return
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if slua.isValid(CurrentVehicle) then
    if self:CheckIsDriver(PlayerPawn) then
      if 0 > self.CacheVehicleTargetArmLenth then
        local vehicleSprintArm = CurrentVehicle:GetVehicleSpringArm()
        if vehicleSprintArm then
          DefaultCameraLenth = vehicleSprintArm.TargetArmLength
        end
      else
        DefaultCameraLenth = self.CacheVehicleTargetArmLenth
      end
    else
      DefaultCameraLenth = PlayerCamera.InVehicleCameraData.SpringArmLength
    end
  elseif 0 > self.CacheTargetArmLenth then
    if PlayerPawn.SpringArmComp then
      DefaultCameraLenth = PlayerPawn.SpringArmComp.TargetArmLength
    end
  else
    DefaultCameraLenth = self.CacheTargetArmLenth
  end
  local CameraLenth = self:GetNewSpringArmLength(DefaultCameraLenth, Value)
  self.CacheZoom  print(bWriteLog and "PhotoGrapherSubSystem:SetTargetArmLenthWithZoom CameraLenth is", CameraLenth)
  self:SetTargetArmLenth(CameraLenth)
end
function PhotoGrapherSubSystem:GetCurrentVehicle()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return nil
  end
  local VehicleComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleComponent) then
    return nil
  end
  return VehicleComponent:GetVehicle()
end
function PhotoGrapherSubSystem:SetTargetArmLenth(CameraLenth)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  local ViewTarget = PlayerController:GetViewTarget()
  local uSpringArm = ViewTarget and ViewTarget.SpringArmComp
  if slua.isValid(CurrentVehicle) and self:CheckIsDriver(PlayerPawn) then
    self:SetVehicleTargetArmLenth(CameraLenth, CurrentVehicle)
  elseif ViewTarget and PlayerPawn and ViewTarget ~= PlayerPawn then
    self:SetViewTargetArmLenth(CameraLenth, uSpringArm)
  else
    self:SetCharacterTargetArmLenth(CameraLenth, PlayerPawn, false)
  end
end
function PhotoGrapherSubSystem:CheckIsDriver(PlayerPawn)
  if self.NextSeatType then
    return self.NextSeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat
  end
  return USTExtraVehicleUtils.IsDriver(PlayerPawn)
end
function PhotoGrapherSubSystem:SetCharacterTargetArmLenth(CameraLenth, uPlayerPawn, bReset)
  if uPlayerPawn.SpringArmComp then
    if self.CacheTargetArmLenth < 0 then
      self.CacheTargetArmLenth = uPlayerPawn.SpringArmComp.TargetArmLength
    end
    uPlayerPawn.SpringArmComp.bForceUseTargetArmLength = true
    uPlayerPawn.SpringArmComp.TargetArmLength = CameraLenth
    if bReset then
      uPlayerPawn.SpringArmComp.bForceUseTargetArmLength = false
    end
    print(bWriteLog and "PhotoGrapherSubSystem:SetCharacterTargetArmLenth", uPlayerPawn.SpringArmComp:GetCameraTargetArmLength(), uPlayerPawn)
  end
end
function PhotoGrapherSubSystem:SetVehicleTargetArmLenth(CameraLenth, uVehicle)
  print(bWriteLog and "PhotoGrapherSubSystem:SetVehicleTargetArmLenth", CameraLenth)
  if not slua.isValid(uVehicle) then
    return
  end
  local VehicleSpringArm = uVehicle:GetVehicleSpringArm()
  if VehicleSpringArm then
    if self.CacheVehicleTargetArmLenth < 0 then
      self.CacheVehicleTargetArmLenth = VehicleSpringArm.TargetArmLength
    end
    local CameraData = import("CameraOffsetData")()
    CameraData.SpringArmLength = CameraLenth
    CameraData.BeginInterpSpeed = 1000
    CameraData.EndInterpSpeed = 1000
    VehicleSpringArm.TargetArmLength = CameraLenth
    VehicleSpringArm:SetBackupCameraData(CameraData)
    VehicleSpringArm:UseBackupCameraData(true)
    print(bWriteLog and "PhotoGrapherSubSystem:SetVehicleTargetArmLenth", CameraLenth, uVehicle)
  end
end
function PhotoGrapherSubSystem:SetViewTargetArmLenth(CameraLenth, SpringArmComp)
  if not slua.isValid(SpringArmComp) then
    return
  end
  if self.CacheTargetArmLenth < 0 then
    self.CacheTargetArmLenth = SpringArmComp.TargetArmLength
  end
  SpringArmComp.TargetArmLength = CameraLenth
end
function PhotoGrapherSubSystem:ResetVehicleSpringArm(uVehicle)
  print(bWriteLog and "PhotoGrapherSubSystem:ResetVehicleSpringArm")
  if not slua.isValid(uVehicle) then
    return
  end
  local VehicleSpringArm = uVehicle:GetVehicleSpringArm()
  if VehicleSpringArm then
    VehicleSpringArm:UseBackupCameraData(false)
    VehicleSpringArm.TargetArmLength = self.CacheVehicleTargetArmLenth
    self.CacheVehicleTargetArmLenth = -1
    print(bWriteLog and "PhotoGrapherSubSystem:ResetVehicleSpringArm success")
  end
end
function PhotoGrapherSubSystem:GetNewSpringArmLength(InitLength, Value)
  if 0.4 < Value then
    return InitLength + (Value - 0.4) * 800
  else
    return (3 * Value - 0.2) * InitLength
  end
end
function PhotoGrapherSubSystem:ResumeSpringArmLength()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if self.CacheTargetArmLenth and self.CacheTargetArmLenth > 0 then
    local ViewTarget = PlayerController:GetViewTarget()
    if ViewTarget and ViewTarget == PlayerCharacter then
      self:SetCharacterTargetArmLenth(self.CacheTargetArmLenth, PlayerCharacter, true)
    end
    self.CacheTargetArmLenth = -1
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if slua.isValid(CurrentVehicle) and self.CacheVehicleTargetArmLenth and 0 < self.CacheVehicleTargetArmLenth and USTExtraVehicleUtils.IsDriver(PlayerCharacter) then
    self:ResetVehicleSpringArm(CurrentVehicle)
  end
end
function PhotoGrapherSubSystem:OperationUIFadeIn()
  print(bWriteLog and "PhotoGrapherSubSystem:OperationUIFadeIn")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  print(bWriteLog and "PhotoGrapherSubSystem:OperationUIFadeIn2", uSmartCameraModifier)
  if not self.bIsPhotoGrapherMode then
    return
  end
  if self.FadeOutTimer then
    self:RemoveGameTimer(self.FadeOutTimer)
    self.FadeOutTimer = nil
  else
    local JoyStickTargetOpacity = 1
    local settingConfig = slua_GameFrontendHUD:GetUserSettings()
    if settingConfig.NoUIOpacity then
      JoyStickTargetOpacity = settingConfig.NoUIOpacity * self.CahceJoyStickopacity
    end
    uSmartCameraModifier:FadeJoyStick(JoyStickTargetOpacity, 1)
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    local StartTimer, NumToLoop, PlayMode, PlaySpeed = 0, 1, 1, 1
    if slua.isValid(MainControlPanelTochButton) and MainControlPanelTochButton.FadeAnim then
      MainControlPanelTochButton:PlayUserWidgetAnimation(MainControlPanelTochButton.FadeAnim, StartTimer, NumToLoop, PlayMode, PlaySpeed)
    end
    local mainPhotoUI = UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_Photo_UIBP)
    if mainPhotoUI then
      mainPhotoUI:OnTransparentPanel(false)
    end
  end
  if not self.bIsPhotoGrapherMode then
    return
  end
  self.FadeOutTimer = self:AddGameTimer(self.TransparentTime, false, function()
    self:OperationUIFadeOut()
  end)
end
function PhotoGrapherSubSystem:OperationUIFadeOut()
  if not self.bIsPhotoGrapherMode then
    return
  end
  if self.FadeOutTimer then
    self:RemoveGameTimer(self.FadeOutTimer)
    self.FadeOutTimer = nil
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  uSmartCameraModifier:FadeJoyStick(0, 1)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  local StartTimer, NumToLoop, PlayMode, PlaySpeed = 0, 1, 0, 1
  if slua.isValid(MainControlPanelTochButton) and MainControlPanelTochButton.FadeAnim then
    MainControlPanelTochButton:PlayUserWidgetAnimation(MainControlPanelTochButton.FadeAnim, StartTimer, NumToLoop, PlayMode, PlaySpeed)
  end
  local mainPhotoUI = UIManager.GetUI(UIManager.UI_Config_InGame.Ingame_Photo_UIBP)
  if mainPhotoUI then
    mainPhotoUI:OnTransparentPanel(true)
  end
end
function PhotoGrapherSubSystem:SetAllUIOpacity(Opacity, fadeout)
  if not self.bIsPhotoGrapherMode then
    return
  end
  if Opacity < 0 or 1 < Opacity then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    return
  end
  MainControlPanelTochButton:SetColorAndOpacity(FLinearColor(1, 1, 1, Opacity))
  PlayerController:SetJoyStickOpacityNotUpdate(Opacity * self.CahceJoyStickopacity)
  if fadeout then
    self:OperationUIFadeOut()
  end
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if settingConfig.NoUIOpacity then
    settingConfig.NoUI  end
end
function PhotoGrapherSubSystem:GetAllUIOpacity()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if settingConfig.NoUIOpacity then
    return settingConfig.NoUIOpacity
  end
  return 0
end
function PhotoGrapherSubSystem:GetPhotographerCameraModifier()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self.uSmartCameraModifierClass = slua.loadClass(self:GetSmartPhotographerClassPath())
  local uSmartCameraModifier = PlayerController.PlayerCameraManager:FindCameraModifierByClass(self.uSmartCameraModifierClass)
  return uSmartCameraModifier
end
function PhotoGrapherSubSystem:GetSmartPhotographerClassPath()
  return SmartPhotographerClass
end
function PhotoGrapherSubSystem:OnSmartCameraAdd(_, _, uCameraManager)
  print(bWriteLog and "PhotoGrapherSubSystem:OnSmartCameraAdd")
  if not slua.isValid(uCameraManager) then
    return
  end
  print(bWriteLog and "PhotoGrapherSubSystem:OnSmartCameraAdd11")
  local PlayerController = uCameraManager:GetOwningPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "PhotoGrapherSubSystem:OnSmartCameraAdd22")
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  self.bIsPhotoGrapherMode = true
  print(bWriteLog and "PhotoGrapherSubSystem:OnSmartCameraAdd33")
  PlayerCharacter:ForceWeaponFireInMuzzleDirection(true)
end
function PhotoGrapherSubSystem:OnSmartCameraRemove(_, _, uCameraManager)
  print(bWriteLog and "PhotoGrapherSubSystem:OnSmartCameraRemove")
  if not slua.isValid(uCameraManager) then
    return
  end
  local PlayerController = uCameraManager:GetOwningPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  self.bIsPhotoGrapherMode = false
  PlayerCharacter:ForceWeaponFireInMuzzleDirection(false)
  self:OnEmotePlayEnd()
end
function PhotoGrapherSubSystem:OnSmartCamerainterrupt()
  self:LeaveNoUIMode()
end
function PhotoGrapherSubSystem:CreateGreenSkySphere()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
  if not WeatherSubsystem then
    return
  end
  local WorldContextObject = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(WorldContextObject) then
    return
  end
  local uSkySphere = WeatherSubsystem:GetSkySphere(WorldContextObject)
  local uSkyLoc = FVector(0)
  local uSkyRot = FRotator(0)
  print(bWriteLog and "PhotoGrapherSubSystem:CreateGreenSkySphere", uSkySphere)
  if slua.isValid(uSkySphere) then
    uSkyLoc = uSkySphere:K2_GetActorLocation()
    local EGameModeType = import("EGameModeType")
    local GameState = GameplayData.GetGameState()
    if GameState and (GameState.GameModeType == EGameModeType.ESocialIsland or GameState.GameModeType == EGameModeType.EPlanPHGameMode) then
      uSkyLoc = FVector(59907, 67435, 253)
    end
    local CharacterLoc = PlayerCharacter:K2_GetActorLocation()
    uSkyLoc.Z = CharacterLoc.Z
    uSkyRot = uSkySphere:K2_GetActorRotation()
  else
    uSkyLoc = PlayerCharacter:K2_GetActorLocation()
    uSkyRot = PlayerCharacter:K2_GetActorRotation()
  end
  if not slua.isValid(CGameWorld) then
    return
  end
  local LoadedDelegate = slua.createDelegate(function(uGreenSkyClass)
    if not slua.isValid(uGreenSkyClass) then
      return
    end
    self:DelSkySphere()
    self.uGreenSphereActor = CGameWorld:SpawnActor(uGreenSkyClass, uSkyLoc, uSkyRot, nil)
    slua.addRef(self.uGreenSphereActor)
    self:SwitchSkySphere(false)
  end)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  USTExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(UKismetSystemLibrary.MakeSoftObjectPath(PhotoGrapherConfig.GreenSkyClass), LoadedDelegate)
end
function PhotoGrapherSubSystem:DelSkySphere()
  if slua.isValid(self.uGreenSphereActor) then
    slua.removeRef(self.uGreenSphereActor)
    self.uGreenSphereActor:K2_DestroyActor()
    self.uGreenSphereActor = nil
  end
end
function PhotoGrapherSubSystem:SwitchSkySphere(bSwitch)
  if slua.isValid(self.uGreenSphereActor) then
    self.uGreenSphereActor:SetActorHiddenInGame(not bSwitch)
    self.bIsSkySphereOn = bSwitch
  end
end
function PhotoGrapherSubSystem:IsSkySphereOn()
  return self.bIsSkySphereOn
end
function PhotoGrapherSubSystem:SetHideAllPawn(bHideAll, bTriggerHide)
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  uSmartCameraModifier.  if bTriggerHide and uSmartCameraModifier.HidePawns then
    uSmartCameraModifier:HidePawns()
  end
end
function PhotoGrapherSubSystem:ForceRefreshNextHide()
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  if uSmartCameraModifier.ForceRefreshNextHide then
    uSmartCameraModifier:ForceRefreshNextHide()
  end
end
function PhotoGrapherSubSystem:SetPawnVisible(bSelfHidden, bTeamMateHidden, bEnemyHidden)
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  uSmartCameraModifier.bHideSelf = bSelfHidden
  uSmartCameraModifier.bHideInteract = bSelfHidden
  uSmartCameraModifier.bHideTeammate = bTeamMateHidden
  uSmartCameraModifier.bHideEnemy = bEnemyHidden
end
function PhotoGrapherSubSystem:SetMyPawnVisible(bShouldHide)
  print(bWriteLog and "PhotoGrapherSubSystem:SetMyPawnVisible", bShouldHide)
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  uSmartCameraModifier.bHideSelf = bShouldHide
  uSmartCameraModifier.bHideInteract = bShouldHide
end
function PhotoGrapherSubSystem:SetTeamPawnVisible(bShouldHide)
  print(bWriteLog and "PhotoGrapherSubSystem:SetTeamPawnVisible", bShouldHide)
  local uSmartCameraModifier = self:GetPhotographerCameraModifier()
  if not uSmartCameraModifier then
    return
  end
  uSmartCameraModifier.bHideTeammate = bShouldHide
end
function PhotoGrapherSubSystem:OnEnterVehicle(SeatType)
  self.Next  if self.CacheZoomValue then
    self:SetTargetArmLenthWithZoom(self.CacheZoomValue)
  end
  self.NextSeatType = nil
  if self:CheckIsInForbiddenVehicle() then
    local IngameSelfieSubsystem = SubsystemMgr:Get("IngameSelfieSubsystem")
    if IngameSelfieSubsystem then
      IngameSelfieSubsystem:ExitSelfie()
      ShowNotice(48895)
    end
  end
  self:StopSmartCamera()
  self:ReportPhotographerOp(PhotoGrapherConfig.PhotographerOptype.UseInVehicle)
end
function PhotoGrapherSubSystem:OnDetachedFromVehicle(uLastVehicle)
  if not self.bIsPhotoGrapherMode then
    return
  end
  if not slua.isValid(uLastVehicle) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  self:StopSmartCamera()
  print(bWriteLog and "PhotoGrapherSubSystem:OnDetachedFromVehicle", self.CacheVehicleTargetArmLenth)
  if self.CacheVehicleTargetArmLenth and self.CacheVehicleTargetArmLenth > 0 then
    self:ResetVehicleSpringArm(uLastVehicle)
  end
  if self.CacheZoomValue then
    self:SetTargetArmLenthWithZoom(self.CacheZoomValue)
  end
end
function PhotoGrapherSubSystem:OnChangedVehicleSeat(SeatType)
  if not self.bIsPhotoGrapherMode then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  self.Next  print(bWriteLog and "PhotoGrapherSubSystem:OnChangedVehicleSeat", self.CacheVehicleTargetArmLenth)
  if slua.isValid(CurrentVehicle) and self.CacheVehicleTargetArmLenth and self.CacheVehicleTargetArmLenth > 0 then
    self:ResetVehicleSpringArm(CurrentVehicle)
  end
  if self.CacheZoomValue then
    self:SetTargetArmLenthWithZoom(self.CacheZoomValue)
  end
  self:ReportPhotographerOp(PhotoGrapherConfig.PhotographerOptype.UseInVehicle)
  self.NextSeatType = nil
end
function PhotoGrapherSubSystem:ResetModifyData()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  if self.CacheTargetArmLenth and self.CacheTargetArmLenth > 0 then
    self:SetCharacterTargetArmLenth(self.CacheTargetArmLenth, PlayerPawn, true)
    self.CacheTargetArmLenth = -1
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if self.CacheVehicleTargetArmLenth and 0 < self.CacheVehicleTargetArmLenth and slua.isValid(CurrentVehicle) then
    self:ResetVehicleSpringArm(CurrentVehicle)
  end
end
function PhotoGrapherSubSystem:OnLuaTrackEvent(eventData)
  print(bWriteLog and "PhotoGrapherSubSystem:OnLuaTrackEvent", eventData)
end
function PhotoGrapherSubSystem:OnCamereSeqFinish()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return
  end
  self:OnEmotePlayEnd()
  print(bWriteLog and "PhotoGrapherSubSystem:OnCamereSeqFinish", PlayerPawn)
  local bCanExitCamera = true
  local PlayEmoteComp = PlayerPawn:GetPlayEmoteComponent()
  if PlayEmoteComp and PlayEmoteComp.IsPlayingEmotes and (PlayEmoteComp:IsPlayingEmotes() or PlayerPawn:HasState(PawnState.Restricted)) then
    bCanExitCamera = false
    local ETouchIndex = import("ETouchIndex")
    PlayerController:StartFreeCamera(ETouchIndex.Touch1)
  end
  if bCanExitCamera then
    local MCActionSubsystem = SubsystemMgr:Get("MCActionSubsystem")
    if MCActionSubsystem and not MCActionSubsystem:CheckCanExitFreeCamera() then
      bCanExitCamera = false
    end
  end
  if bCanExitCamera then
    PlayerController:ExitFreeCamera(false)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PHOTOGRAPHER_SEQ_FINISH)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if not slua.isValid(MainControlPanelTochButton) then
    return
  end
  MainControlPanelTochButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  PlayerController:SetVirtualJoystickWidgetRender(0)
end
function PhotoGrapherSubSystem:ModifyPetOpen(bPetOpen)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uPlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  SettingSubsystem:SetUserSettings_Bool("OpenMyPet", bPetOpen)
end
function PhotoGrapherSubSystem:GetPetOpen()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uPlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  return SettingSubsystem:GetUserSettings_Bool("OpenMyPet")
end
function PhotoGrapherSubSystem:GetAllWearState()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local InitialAllWear = PlayerController.InitialAllWear
  local AllWearState = {}
  for i = 1, InitialAllWear:Num() do
    AllWearState[i - 1] = not InitialAllWear:Get(i - 1).IsLocked
  end
  return AllWearState
end
function PhotoGrapherSubSystem:GetCurWearIndex()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return -1
  end
  local index = PlayerController.RolewearIndex
  print(bWriteLog and "PhotoGrapherSubSystem:GetCurWearIndex WearIndex", index)
  return index
end
function PhotoGrapherSubSystem:RequestChangeWearInPhoto(WearIndex)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local Character = GameplayData.GetPlayerCharacter()
  if slua.isValid(Character) then
    Character:OnInterruptCurrentEmote()
  end
  local bRes = PlayerController:RequestChangeWearInPhoto(WearIndex)
  print(bWriteLog and "PhotoGrapherSubSystem:RequestChangeWear WearIndex", WearIndex, " Result is", bRes)
  local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
  self:ReportPhotographerOp(PhotographerOptype.ChangeWear)
  return bRes
end
function PhotoGrapherSubSystem:GetPetState()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local uPlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return
  end
  local PetState = false
  if slua.isValid(uPlayerPawn.PetComponent_BP) and slua.isValid(uPlayerPawn.PetComponent_BP.PetPawn) then
    local uPetPawn = uPlayerPawn.PetComponent_BP.PetPawn
    PetState = not uPetPawn.bHidden
  end
  print(bWriteLog and "PhotoGrapherSubSystem:CheckPetState PetState is ", PetState)
  return PetState
end
function PhotoGrapherSubSystem:ModifyEmotePlayRate(RealEmotePlayRate)
  local EmotePlayRate = math.max(RealEmotePlayRate, self.EmotePlayRateLimit) * 10000
  EmotePlayRate = math.ceil(EmotePlayRate)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and " PhotoGrapherSubSystem:ModifyEmotePlayRate PlayerCharacter is nil")
    return
  end
  local OldPlayRate = PlayerCharacter:GetAttrValue(self.AttrName)
  print(bWriteLog and "PhotoGrapherSubSystem:ModifyEmotePlayRate EmotePlayRate is ", OldPlayRate, " NewRate is ", EmotePlayRate)
  if OldPlayRate == EmotePlayRate then
    return
  end
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    return
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  PhotoGrapherFeature:RPC_Server_ChangeEmotePlayRate(EmotePlayRate)
end
function PhotoGrapherSubSystem:EmotePlayRateChanged(PlayerCharacter, EmotePlayRate)
  local RealEmotePlayRate = EmotePlayRate / 10000.0
  local OldEmotePlayRate = self.LastPlayRate or 1.0
  self.LastPlayRate = RealEmotePlayRate
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local Mesh = PlayerCharacter.Mesh
  local PlayEmoteComp = PlayerCharacter:GetPlayEmoteComponent()
  if PlayEmoteComp == nil then
    print(bWriteLog and " PhotoGrapherSubSystem:ModifyEmotePlayRate PlayEmoteComp is nil")
    return
  end
  local IsPlayingEmotes = PlayEmoteComp:IsPlayingEmotes()
  if IsPlayingEmotes ~= true then
    print(bWriteLog and " PhotoGrapherSubSystem:ModifyEmotePlayRate PlayEmoteComp IsPlayingEmotes is false")
    return
  end
  local EmoteID = PlayEmoteComp:GetCurrentEmoteId()
  if PlayEmoteComp.InterrupEmoteSoundByEmoteId then
    PlayEmoteComp:InterrupEmoteSoundByEmoteId(EmoteID)
  end
  local EmoteHandle = PlayerCharacter:GetEmoteHandle(EmoteID)
  if EmoteHandle then
    local EmoteActionList = EmoteHandle.EmoteActionList
    for _, EmoteAction in pairs(EmoteActionList) do
      if EmoteAction then
        EmoteAction:SetEmotePlayRate(PlayerCharacter, EmoteHandle, OldEmotePlayRate, RealEmotePlayRate)
      end
    end
  end
  local AnimInstances = Mesh:GetSubAnimInstances()
  if AnimInstances and AnimInstances.Num then
    for i = 1, AnimInstances:Num() do
      local AnimInst = AnimInstances:Get(i - 1)
      if slua.isValid(AnimInst) then
        local PlayingMontage = AnimInst:GetCurrentActiveMontage()
        if slua.isValid(PlayingMontage) then
          AnimInst:Montage_SetPlayRate(PlayingMontage, RealEmotePlayRate)
          PlayEmoteComp.EmoteAnimLastTime = PlayEmoteComp.EmoteAnimLastTime * OldEmotePlayRate / RealEmotePlayRate
          print(bWriteLog and "PhotoGrapherSubSystem:ModifyEmotePlayRate EmoteAnimLastTime is ", PlayEmoteComp.EmoteAnimLastTime)
          return
        end
      end
    end
  end
  local Amims = Mesh:GetAnimInstance()
  if slua.isValid(Amims) then
    local PlayingMontage = Amims:GetCurrentActiveMontage()
    if slua.isValid(PlayingMontage) then
      Amims:Montage_SetPlayRate(PlayingMontage, RealEmotePlayRate)
      PlayEmoteComp.EmoteAnimLastTime = PlayEmoteComp.EmoteAnimLastTime * OldEmotePlayRate / RealEmotePlayRate
      print(bWriteLog and "PhotoGrapherSubSystem:ModifyEmotePlayRate EmoteAnimLastTime is ", PlayEmoteComp.EmoteAnimLastTime)
      return
    end
  end
end
function PhotoGrapherSubSystem:PlayeEffect(EffectIndex)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and " PhotoGrapherSubSystem:PlayeEffect PlayerCharacter is nil")
    return
  end
  local EffectConfig = PhotoGrapherConfig.EffectConfig[EffectIndex]
  if EffectConfig.EffectPath == nil then
    print(bWriteLog and " PhotoGrapherSubSystem:PlayeEffect EffectPath is nil")
    return
  end
  if EffectConfig.bIsLevelSequence then
    self:DestoryLevelSequence()
    local UKismetMathLibrary = import("KismetMathLibrary")
    local PlayerMesh = PlayerCharacter.Mesh
    if not slua.isValid(PlayerMesh) then
      return
    end
    local PlayerLocation = PlayerMesh:K2_GetComponentLocation()
    local PlayerRotation = PlayerCharacter:K2_GetActorRotation()
    local SequenceRotator = FRotator(0, 0, 0)
    SequenceRotator.Yaw = EffectConfig.RelativeRotation.Yaw + PlayerRotation.Yaw
    local SequenceTransform = UKismetMathLibrary.MakeTransform(PlayerLocation + PlayerRotation:RotateVector(EffectConfig.RelativeLocation), SequenceRotator, FVector(1, 1, 1))
    self.SequenceActor = Game:PlayLevelSequence(PlayerCharacter, EffectConfig.EffectPath, SequenceTransform, "/Game/Mod/EvoBase/BluePrints/Actor/BP_UAELevelSequenceActor.BP_UAELevelSequenceActor_C", true, nil)
    print(bWriteLog and " PhotoGrapherSubSystem:PlayeEffect PlaySequence")
  else
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(EffectConfig.EffectPath, function(uPartcileSystem)
      if uPartcileSystem then
        local PlayerMesh = PlayerCharacter.Mesh
        if not slua.isValid(PlayerMesh) then
          return
        end
        local Location = PlayerMesh:K2_GetComponentLocation()
        local Rotation = FRotator(0, 0, 0)
        local Scale = FVector(1, 1, 1)
        print(bWriteLog and "PhotoGrapherSubSystem:PlayeEffect Location:", Location:ToString(), "Rotation:", Rotation:ToString(), " EffectIndex:", EffectIndex)
        uGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uPartcileSystem, Location, Rotation, Scale, true)
      end
    end)
  end
  local PhotographerOptype = PhotoGrapherConfig.PhotographerOptype
  self:ReportPhotographerOp(PhotographerOptype.SceneEffect)
end
function PhotoGrapherSubSystem:ChangePhotoGrapherOpenState(bState)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    return
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  print(bWriteLog and "PhotoGrapherSubSystem:ChangePhotoGrapherOpenState PhotoGrapher state is ", PhotoGrapherFeature.bPhotoGrapherOpenState, " NewState is ", bState)
  if PhotoGrapherFeature.bPhotoGrapherOpenState == bState then
    return
  end
  local FeatureMark = 0
  if bState == true then
    FeatureMark = self:GetFeatureMark()
  end
  PhotoGrapherFeature:RPC_Server_ChangePhotoGrapherOpenState(bState, FeatureMark)
  print(bWriteLog and "PhotoGrapherSubSystem:ChangePhotoGrapherOpenState PhotoGrapher end ")
end
function PhotoGrapherSubSystem:CheckIsSpecialPet()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) or not slua.isValid(PlayerCharacter.PetComponent_BP) then
    return false
  end
  local PetID = PlayerCharacter.PetComponent_BP.PetInfo.PetId
  local TableUtil = require("common.table_util")
  if TableUtil.IsInTable(PhotoGrapherConfig.SpecialPetID, PetID) then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckIsSpecialPet is special Pet")
    return true
  end
  print(bWriteLog and "PhotoGrapherSubSystem:CheckIsSpecialPet is not special ")
  return false
end
function PhotoGrapherSubSystem:PlayPetFeature()
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    return
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  PhotoGrapherFeature:RPC_Server_PlayPetFeature()
end
function PhotoGrapherSubSystem:ReportPhotographerOp(OperationType)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or not PlayerState.PhotoGrapherFeature then
    return
  end
  if TableUtil.Find(self.UseRecord, OperationType) ~= -1 then
    if TableUtil.Find(self.NeedRportTimes, OperationType) == -1 then
      return
    end
  else
    TableUtil.UniqueInsert(self.UseRecord, OperationType)
  end
  local PhotoGrapherFeature = PlayerState.PhotoGrapherFeature
  PhotoGrapherFeature:RPC_Server_PhotographerOp(OperationType)
end
function PhotoGrapherSubSystem:CheckBasicSkillButtonState(ButtonType)
  local TableUtil = require("common.table_util")
  if TableUtil.IsInTable(PhotoGrapherConfig.BasicSkillButtonType.Vehicle, ButtonType) then
    if not self:CheckVehicleDSSwitch() then
      print(bWriteLog and "PhotoGrapherSubSystem:CheckBasicSkillButtonState, return false")
      return false
    end
    return true
  elseif TableUtil.IsInTable(PhotoGrapherConfig.BasicSkillButtonType.Other, ButtonType) then
    return true
  end
  return false
end
function PhotoGrapherSubSystem:CheckVehicleDSSwitch()
  if CGame:IsEditor() then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckVehicleDSSwitch, IsEditor")
    return true
  end
  local uGameState = GameplayData.GetGameState()
  if uGameState and uGameState:CheckDSSwitchOpen(DSSwitchID) then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckVehicleDSSwitch, return true")
    return true
  end
  print(bWriteLog and "PhotoGrapherSubSystem:CheckVehicleDSSwitch, return false")
  return false
end
function PhotoGrapherSubSystem:CheckIsInVehicle()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return false
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if not slua.isValid(CurrentVehicle) then
    return false
  end
  return true
end
function PhotoGrapherSubSystem:CheckIsInForbiddenVehicle()
  if not self:CheckVehicleDSSwitch() then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckIsInForbiddenVehicle, return false")
    return true
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "PhotoGrapherSubSystem:CheckIsInForbiddenVehicle PlayerController is nil")
    return true
  end
  local CurrentVehicle = self:GetCurrentVehicle()
  if slua.isValid(CurrentVehicle) and CurrentVehicle.VehicleShapeType then
    local VehicleShapeType = CurrentVehicle.VehicleShapeType
    local TableUtil = require("common.table_util")
    if TableUtil.IsInTable(PhotoGrapherConfig.ForbiddenVehicleType, VehicleShapeType) then
      print(bWriteLog and "PhotoGrapherSubSystem:CheckIsInForbiddenVehicle CurrentVehicle is ForbiddenVehicleType ", VehicleShapeType)
      return true
    end
  end
  return false
end
function PhotoGrapherSubSystem:OnEmotePlayEnd()
  if slua.isValid(self.CurrentPetPawn) then
    self:RemoveControlEvent(self.CurrentPetPawn, "OnPetEmoteReadyToPlayNext")
    self.CurrentPetPawn = nil
  end
  self.CurrentTemplateType = ESmartCameraTemplateType.Player
  self.EmoteIDList = {}
end
function PhotoGrapherSubSystem:PlayNextPetEmote()
  if #self.EmoteIDList <= 0 then
    self:OnEmotePlayEnd()
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:PlaySpecifiedPetAnimation(self.EmoteIDList[1])
  self.LastEmoteID = self.EmoteIDList[1]
  table.remove(self.EmoteIDList, 1)
end
function PhotoGrapherSubSystem:DestoryLevelSequence()
  if slua.isValid(self.SequenceActor) then
    self.SequenceActor:K2_DestroyActor()
    self.SequenceActor = nil
  end
end
function PhotoGrapherSubSystem:GetPetActionList()
  print(bWriteLog and "PhotoGrapherSubSystem:GetPetActionList")
  local petActionList = {}
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return petActionList
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) or not slua.isValid(PlayerCharacter.PetComponent_BP) then
    return petActionList
  end
  local IsInPetSpectator = false
  local petId, petLevel
  if PlayerController.IsInPetSpectator and PlayerController:IsInPetSpectator() and PlayerController.InitialPetInfo then
    print(bWriteLog and "PhotoGrapherSubSystem:GetPetActionList", PlayerController.InitialPetInfo, PlayerController.InitialPetInfo.PetId, PlayerController.InitialPetInfo.PetLevel)
    IsInPetSpectator = true
    petId = PlayerController.InitialPetInfo.PetId
    petLevel = PlayerController.InitialPetInfo.PetLevel
  elseif slua.isValid(PlayerCharacter) and slua.isValid(PlayerCharacter.PetComponent_BP) and slua.isValid(PlayerCharacter.PetComponent_BP.PetPawn) then
    print(bWriteLog and "PhotoGrapherSubSystem:GetPetActionList get PlayerCharacter pet info")
    petId = PlayerCharacter.PetComponent_BP.PetPawn.PetLevelInfo.PetId
    petLevel = PlayerCharacter.PetComponent_BP.PetPawn.PetLevelInfo.PetLevel
  end
  if not (petId and not (petId <= 0) and petLevel) or petLevel <= 0 or not self:GetPetState() then
    return petActionList
  end
  local petActionTable = CDataTable.GetTable("PetActionTable")
  local StringUtil = require("common.string_util")
  for _, v in pairs(petActionTable) do
    if not (v.CanPlayInBattle ~= 1 and (v.CanPlayInBattle ~= 2 or IsInPetSpectator)) or v.CanPlayInBattle == 3 and IsInPetSpectator then
      local UIUtil = require("client.common.ui_util")
      local PetActionIcon, bHasAddKnownMissing, isDefaultIcon = UIUtil.GetItemSmallIcon(v.PetActionID)
      local bMatchDress = true
      if v.DependingClothesID and v.DependingClothesID ~= "" then
        local DependingClothesIDList = StringUtil.Split(v.DependingClothesID, "|")
        if DependingClothesIDList and next(DependingClothesIDList) then
          bMatchDress = self:IsPetAvatarRequirementMatch(DependingClothesIDList)
        end
      end
      if bMatchDress then
        table.insert(petActionList, {
          id = v.PetActionID,
          icon = PetActionIcon,
          SortKey = v.SortKey
        })
      end
    end
  end
  if #petActionList <= 0 then
    return petActionList
  end
  table.sort(petActionList, function(a, b)
    return a.SortKey < b.SortKey
  end)
  local StringUtil = require("common.string_util")
  local ConfigID = 10000 * petId + petLevel
  local PetLevelConfig = CDataTable.GetTableData("PetLevelTable", ConfigID)
  local AllAction = StringUtil.Split(PetLevelConfig.AllAction, "|")
  local EmoteIsUnLocked = function(EmoteID)
    if AllAction and 0 < #AllAction then
      for _, ID in pairs(AllAction) do
        if EmoteID == tonumber(ID) then
          return true
        end
      end
    end
  end
  local resultPetActionList = {}
  for _, v in pairs(petActionList) do
    if EmoteIsUnLocked(v.id) then
      table.insert(resultPetActionList, v)
    end
  end
  return resultPetActionList
end
function PhotoGrapherSubSystem:GetFeatureMark()
  local FeatureOpenList = {}
  local IngameSelfieWeatherSubsystem = SubsystemMgr:Get("IngameSelfieWeatherSubsystem")
  if not IngameSelfieWeatherSubsystem then
    return
  end
  if IngameSelfieWeatherSubsystem.IsWeatherLevelSupportChangingWeather() then
    TableUtil.UniqueInsert(FeatureOpenList, PhotoGrapherConfig.PhotographerFeatureState.ChangeWeather)
  end
  local FeatureMark = 0
  for _, Index in pairs(FeatureOpenList) do
    FeatureMark = FeatureMark | 1 << Index - 1
  end
  return FeatureMark
end
function PhotoGrapherSubSystem:OnWeaponFireShot(_, __, InWeapon)
  print(bWriteLog and "PhotoGrapherSubSystem:OnWeaponFireShot")
  if not self.bIsPhotoGrapherMode then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return false
  end
  local PlayerPawn = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerPawn) then
    return false
  end
  local uCurWeapon = PlayerPawn:GetCurrentWeapon()
  if slua.isValid(uCurWeapon) and uCurWeapon.IsUsingGrenadeLaunch and uCurWeapon:IsUsingGrenadeLaunch() then
    local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOW_HIDE_UI_WITH_FLAG, ShowHideUIFlag.bGrenadeLaunchEnterNoUIMode, true)
  end
end
function PhotoGrapherSubSystem:IsPetAvatarRequirementMatch(RequireAvatarList)
  if not RequireAvatarList or not next(RequireAvatarList) then
    return true
  end
  local CurrentPetInfo
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    CurrentPetInfo = uPlayerController:GetCurrentPetInfo()
  end
  if CurrentPetInfo and CurrentPetInfo.PetAvatarList then
    for _, v in pairs(CurrentPetInfo.PetAvatarList) do
      local DressAvatarIDStr = tostring(v)
      for __, RequireAvatarItemID in pairs(RequireAvatarList) do
        if DressAvatarIDStr == RequireAvatarItemID then
          return true
        end
      end
    end
  end
  return false
end
function PhotoGrapherSubSystem:CheckIsCamTemplateShouldShow(CamTemplateConfig)
  if not CamTemplateConfig or not CamTemplateConfig.DisplayModList_a then
    return true
  end
  local DisplayModList_a = CamTemplateConfig.DisplayModList_a
  if DisplayModList_a:Num() <= 0 then
    return true
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local CurrentModeId = GameMainConfig.GetModeID()
  for _, modId in pairs(DisplayModList_a) do
    if CurrentModeId == modId then
      return true
    end
  end
  return false
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, PhotoGrapherSubSystem)
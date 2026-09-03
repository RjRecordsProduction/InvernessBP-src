local time_ticker = require("common.time_ticker")
local ScreenMarkManagerBase = {}
local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local EPlayerCameraMode = import("EPlayerCameraMode")
local UEPathUtilityMethods = import("UEPathUtilityMethods")
local USTExtraUIBPUtils = import("STExtraUIUtils")
local WidgetClass = import("/Script/UMG.Widget")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
function ScreenMarkManagerBase:ctor()
  print(bWriteLog and "ScreenMarkManagerBase:ctor", self)
  self:RegistEvent()
  self.BindingLogicMap = {}
end
function ScreenMarkManagerBase:OnInit()
  print(bWriteLog and "ScreenMarkManagerBase:OnInit")
  print(bWriteLog and "ScreenMarkManagerBase:OnInit 1")
  if GameStatus.IsInLobbyOrMainCity() then
    print(bWriteLog and "ScreenMarkManagerBase:OnInit 2")
    return
  end
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig == nil then
    print(bWriteLog and "ScreenMarkManagerBase:OnInit ScreenMarkConfig is nil!!")
    return
  end
  print(bWriteLog and "ScreenMarkManagerBase:OnInit")
  for ID, Config in pairs(ScreenMarkConfig) do
    if type(ID) == "number" and Config and Config.bNeedPreLoad then
      self:InitMarkGroupData(ID, true)
    end
  end
end
function ScreenMarkManagerBase:OnDestroy()
  print(bWriteLog and "ScreenMarkManagerBase:OnDestroy", self)
  self:Dispose()
end
function ScreenMarkManagerBase:Dispose()
  print(bWriteLog and "ScreenMarkManagerBase:Dispose", self)
  ScreenMarkManagerBase.__super.Dispose(self)
end
function ScreenMarkManagerBase:RegistEvent()
  print(bWriteLog and "ScreenMarkManagerBase:RegistEvent", self, self.BindToActor)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.HandlePlayerControllerStateChanged, self)
  end
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
end
function ScreenMarkManagerBase:OnCurCameraModeChange(CameraMode)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPawn = uPlayerController:GetPlayerCharacterSafety()
  print(bWriteLog and "ScreenMarkManagerBase:OnCurCameraModeChange", CameraMode, uPawn)
  if not slua.isValid(uPawn) then
    return
  end
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if EPlayerCameraMode.PCM_Aim == CameraMode or EPlayerCameraMode.PCM_FPP == CameraMode then
    for ID, Config in pairs(ScreenMarkConfig) do
      if type(ID) == "number" then
        self:AddBlockCheckIgnoreActor(ID, uPawn)
      end
    end
  else
    for ID, Config in pairs(ScreenMarkConfig) do
      if type(ID) == "number" then
        self:RemoveBlockCheckIgnoreActor(ID, uPawn)
      end
    end
  end
end
function ScreenMarkManagerBase:HandlePlayerControllerStateChanged(ClientStateType)
  if not self then
    return
  end
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if not slua.isValid(uGameInstance) then
    print(bWriteLog and "ScreenMarkManagerBase:HandlePlayerControllerStateChange not valid uGameInstance!")
    return
  end
  local uCompletePlayBack = uGameInstance:GetCompletePlayback()
  if uCompletePlayBack and uCompletePlayBack:IsInPlayState() then
    print(bWriteLog and "ScreenMarkManagerBase:HandlePlayerControllerStateChange uCompletePlayBack InPlayState!")
    return
  end
  print(bWriteLog and "ScreenMarkManagerBase:HandlePlayerControllerStateChange", ClientStateType, self.bHasEnterBattleResult)
  local EStateType = import("EStateType")
  if ClientStateType == EStateType.State_ParachuteJump or ClientStateType == EStateType.State_ParachuteOpen then
    self:OnEnterParachute()
  end
  if ClientStateType == EStateType.State_InExPlane or ClientStateType == EStateType.State_InPlane then
    self:OnEnterPlane()
  end
end
function ScreenMarkManagerBase:OnEnterPlane()
  print(bWriteLog and "ScreenMarkManagerBase:OnEnterPlane")
  if not UIManager.UI_Config_InGame.DefaultScreenMarkPanel then
    return
  end
  local UIInstance = UIManager.GetUI(UIManager.UI_Config_InGame.DefaultScreenMarkPanel)
  if UIInstance then
    UIInstance:Collapsed()
  end
end
function ScreenMarkManagerBase:OnEnterParachute()
  print(bWriteLog and "ScreenMarkManagerBase:OnEnterParachute")
  if not UIManager.UI_Config_InGame.DefaultScreenMarkPanel then
    return
  end
  local UIInstance = UIManager.GetUI(UIManager.UI_Config_InGame.DefaultScreenMarkPanel)
  if UIInstance then
    UIInstance:SelfHitTestInvisible()
  end
end
function ScreenMarkManagerBase:OnMarkActor(_, _, actor)
  print(bWriteLog and "ScreenMarkManagerBase:OnMarkActor", actor)
  self:OnMarkActorBP(actor, 1)
end
function ScreenMarkManagerBase:OnInitMarkGroupData(ID)
  local Config, GroupPanel = self:GetUIGroupConfigByID(ID)
  print(bWriteLog and "ScreenMarkManagerBase:OnInitMarkGroupData", ID, Config, GroupPanel)
  if nil == Config or not slua.isValid(GroupPanel) then
    return
  end
  if not UEPathUtilityMethods.IsPathExist(Config.UIPathName) then
    return
  end
  self:InitPriorityGroupMaxNum(Config, ID)
  local UIPathName = Config.UIPathName
  local ScreenMarkGroupData = {}
  ScreenMarkGroupData.  ScreenMarkGroupData.ScreenMarkPanel = GroupPanel
  ScreenMarkGroupData.AddToPanel = GroupPanel.AddToPanel
  if Config.bIsUpdatedByPanel then
    local HidingUIArr = slua.Array(UEnums.EPropertyClass.Object, WidgetClass)
    for i = 1, Config.MaxWidgetNum do
      if slua.isValid(GroupPanel.MarkIconTemplate) then
        local ImageWidget = STExtraBlueprintFunctionLibrary.DuplicateWidget(GroupPanel.MarkIconTemplate, GroupPanel, "MarkIcon" .. ID .. "_" .. i)
        if slua.isValid(ImageWidget) then
          USTExtraUIBPUtils.SetImageTextureAsync(UIPathName, ImageWidget)
          GroupPanel.AddToPanel:AddChildToCanvas(ImageWidget)
          local UIUtil = require("client.common.ui_util")
          UIUtil.SetSize(ImageWidget, Config.IconSize.X, Config.IconSize.Y)
          local util = require("client.slua_ui_framework.util")
          util.SetAlignment(ImageWidget, 0.5, 0.5)
          ImageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          HidingUIArr:Add(ImageWidget)
        end
      end
    end
    ScreenMarkGroupData.  end
  log_tree("ScreenMarkManagerBase:OnInitMarkGroupData ScreenMarkGroupData", ScreenMarkGroupData)
  ScreenMarkGroupData.ScreenMarkPanel = GroupPanel
  self.ScreenMarkGroupMap:Add(ID, ScreenMarkGroupData)
  local OriginConfig = self:GetOriginGroupConfigByID(ID)
  if not OriginConfig then
    return
  end
  local BindingLogicLuaPath = OriginConfig.BindingLogicLuaPath
  print(bWriteLog and "ScreenMarkManagerBase:OnInitMarkGroupDataLua", ID, BindingLogicLuaPath, GroupPanel)
  if BindingLogicLuaPath then
    local BindingLogic = require(BindingLogicLuaPath)()
    self.BindingLogicMap[ID] = BindingLogic
    if BindingLogic and BindingLogic.OnInitGroup then
      BindingLogic:OnInitGroup(GroupPanel, ID)
    end
  end
end
function ScreenMarkManagerBase:GetOriginGroupConfigByID(ID)
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig == nil then
    print(bWriteLog and "ScreenMarkManagerBase:GetOriginGroupConfigByID ScreenMarkConfig is nil ", ID)
    return nil
  end
  return ScreenMarkConfig[ID]
end
function ScreenMarkManagerBase:SetUIGroupConfigByID(_, _, ID, sProperty, Value)
end
function ScreenMarkManagerBase:GetUIGroupConfigByID(ID)
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig == nil then
    print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID ScreenMarkConfig is nil ", ID)
    return
  end
  local GroupConfig = ScreenMarkConfig[ID]
  log_tree("ScreenMarkManagerBase:GetUIGroupConfigByID GroupConfig", GroupConfig)
  if GroupConfig == nil then
    print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID ScreenMarkUIGroupConfig\230\156\170\233\133\141\231\189\174ID", ID)
    return
  end
  local Config = {
    bIsUpdatedByPanel = GroupConfig.bIsUpdatedByPanel or false,
    PreloadNum = math.min(GroupConfig.PreloadNum or 1, ScreenMarkConfig.OtherConfig.MaxPreloadNum or 5),
    MaxWidgetNum = math.min(GroupConfig.MaxWidgetNum or 5, ScreenMarkConfig.OtherConfig.MaxWidgetNum or 20),
    MaxShowDistance = GroupConfig.MaxShowDistance or 6000,
    MinShowDistance = GroupConfig.MinShowDistance or 0,
    bBindOutScreen = GroupConfig.bBindOutScreen or false,
    bBindBlocked = GroupConfig.bBindBlocked or false,
    UpdateBindingInterval = GroupConfig.UpdateBindingInterval or 0.4,
    UpdateBindingIntervalMax = GroupConfig.UpdateBindingIntervalMax or 1.5,
    ReduseBindingVelocityThreshold = GroupConfig.ReduseBindingVelocityThreshold or 50,
    SkeletaSocketName = GroupConfig.CheckSocketName or GroupConfig.BindSocketName or "",
    WorldPositionOffset = GroupConfig.WorldPositionOffset or FVector(0, 0, 40),
    bCollapseWhenFree = GroupConfig.bCollapseWhenFree == true or false,
    bUseLuaWorldOffset = GroupConfig.bUseLuaWorldOffset ~= false,
    bUseLuaWorldSocketName = GroupConfig.bUseLuaWorldSocketName ~= false,
    bIsBindingActor = GroupConfig.bIsBindingActor ~= false,
    IconSize = GroupConfig.IconSize or FVector2D(50, 50),
    UIOffset = GroupConfig.UIOffset or FVector2D(0, 0),
    bNeedUpdateState = GroupConfig.bNeedUpdateState ~= false,
    PriorityGroupTag = GroupConfig.GroupTag or "",
    Priority = GroupConfig.Priority or 0,
    bNeedOBShow = GroupConfig.bNeedOBShow ~= false,
    bNeedReplayShow = GroupConfig.bNeedReplayShow ~= false,
    LimitXY = GroupConfig.LimitXY or FVector2D(10, 100),
    LimitZW = GroupConfig.LimitZW or FVector2D(10, 150),
    BindActorComponentTag = GroupConfig.BindActorComponentTag or "",
    bIgnoreSelfPawnBlock = GroupConfig.bIgnoreSelfPawnBlock or false,
    ExtraCheckObjectTypes = {},
    ExtraCheckClasses = {}
  }
  if GroupConfig.ExtraCheckObjectTypes and 0 < #GroupConfig.ExtraCheckObjectTypes then
    for idx, type in ipairs(GroupConfig.ExtraCheckObjectTypes) do
      print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID ExtraCheckObjectTypes", ID, idx, type)
      Config.ExtraCheckObjectTypes[idx] = type
    end
  end
  if GroupConfig.ExtraCheckClasses and 0 < #GroupConfig.ExtraCheckClasses then
    for idx, ClassName in ipairs(GroupConfig.ExtraCheckClasses) do
      local ValidActorClass = import(ClassName)
      print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID ExtraCheckClasses", ID, idx, ValidActorClass)
      Config.ExtraCheckClasses[idx] = ValidActorClass
    end
  end
  print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID", ID, GroupConfig.WorldPositionOffset, Config.bIsUpdatedByPanel)
  local PanelName = GroupConfig.PanelName or "DefaultScreenMarkPanel"
  local GroupPanel = InGameSubUIManager.GetWidgetByName(PanelName)
  if not slua.isValid(GroupPanel) then
    print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID\230\151\160\230\179\149\230\137\190\229\136\176Panel", PanelName)
    if UIManager.UI_Config_InGame[PanelName] then
      local UIInstance = UIManager.GetUI(UIManager.UI_Config_InGame[PanelName])
      if UIInstance then
        GroupPanel = UIInstance.UIRoot
      end
    end
    if not slua.isValid(GroupPanel) and UIManager.UI_Config_InGame.DefaultScreenMarkPanel then
      local UIInstance = UIManager.GetUI(UIManager.UI_Config_InGame.DefaultScreenMarkPanel)
      if UIInstance then
        GroupPanel = UIInstance.UIRoot
      end
    end
  end
  print(bWriteLog and "ScreenMarkManagerBase:GetUIGroupConfigByID GroupPanel", GroupPanel)
  if not slua.isValid(GroupPanel) then
    return
  end
  Config.UIPathName = GroupConfig.UIPathName
  log_tree("ScreenMarkManagerBase:GetUIGroupConfigByID ScreenMarkUIGroupConfig", Config)
  return Config, GroupPanel
end
function ScreenMarkManagerBase:InitPriorityGroupMaxNum(Config, ID)
  if Config.PriorityGroupTag == "" then
    return
  end
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if ScreenMarkConfig == nil then
    print(bWriteLog and "ScreenMarkManagerBase:GetPriorityGroupMaxNum ScreenMarkConfig is nil ", ID)
    return
  end
  local MarkPriorityGroup = self.ScreenMarkPriorityGroupMap:Get(Config.PriorityGroupTag)
  if not MarkPriorityGroup then
    local MaxNum = ScreenMarkConfig.GroupMaxNumConfig[Config.PriorityGroupTag] or 1
    local GroupInfo = {
      MaxShowNum = MaxNum,
      CurShowNum = 0,
      GroupTypeArray = {}
    }
    self.ScreenMarkPriorityGroupMap:Add(Config.PriorityGroupTag, GroupInfo)
  end
end
function ScreenMarkManagerBase:OnActorBindUI(BindActor, BindWidget, ID)
  print(bWriteLog and "ScreenMarkManagerBase:OnActorBindUI", BindActor, BindWidget, ID)
  local BindingLogic = self.BindingLogicMap[ID]
  local SocketName = self:GetOriginGroupConfigByID(ID).BindSocketName
  print(bWriteLog and "ScreenMarkManagerBase:OnActorBindUI", SocketName)
  if SocketName and SocketName ~= "" and BindWidget then
    BindWidget.Skeleta  end
  if BindingLogic and BindingLogic.OnActorBindUI then
    BindingLogic:OnActorBindUI(BindActor, BindWidget, ID)
  end
end
function ScreenMarkManagerBase:OnActorUnbindUI(BindActor, BindWidget, ID)
  local BindingLogic = self.BindingLogicMap[ID]
  if BindingLogic and BindingLogic.OnActorUnbindUI then
    BindingLogic:OnActorUnbindUI(BindActor, BindWidget, ID)
  end
end
function ScreenMarkManagerBase:OnLocationBindUI(BindWidget, ID)
  print(bWriteLog and "ScreenMarkManagerBase:OnLocationBindUI", BindWidget, ID)
  local BindingLogic = self.BindingLogicMap[ID]
  if BindingLogic and BindingLogic.OnLocationBindUI then
    BindingLogic:OnLocationBindUI(BindWidget, ID)
  end
end
function ScreenMarkManagerBase:OnLocationUnbindUI(BindWidget, ID)
  local BindingLogic = self.BindingLogicMap[ID]
  if BindingLogic and BindingLogic.OnLocationUnbindUI then
    BindingLogic:OnLocationUnbindUI(BindWidget, ID)
  end
end
function ScreenMarkManagerBase:AfterChangeMark(bIsShow, TypeID, Location, InstanceID, CustomState)
  if not bIsShow then
    InGameMarkTools.ClientDestroyMarkToNavigator(InstanceID)
    return
  end
  local ScreenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
  if not (ScreenMarkConfig and ScreenMarkConfig[TypeID]) or not ScreenMarkConfig[TypeID].NavigatorMarkPath then
    return
  end
  local UIPath = ScreenMarkConfig[TypeID].NavigatorMarkPath
  local bIsIcon = ScreenMarkConfig[TypeID].NavigatorMarkIsIcon
  if UIPath == "" then
    return
  end
  InGameMarkTools.ClientAddMarkToNavigator(UIPath, Location, true, bIsIcon, CustomState, InstanceID)
end
function ScreenMarkManagerBase:OnReconnect()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local StateType = uPlayerController:GetCurrentStateType()
  local EStateType = import("EStateType")
  if StateType == EStateType.State_InExPlane or StateType == EStateType.State_InPlane then
    self:OnEnterPlane()
  else
    self:OnEnterParachute()
  end
end
local class = require("class")
local object = require("common.delegate_container")
return class(object, nil, ScreenMarkManagerBase)
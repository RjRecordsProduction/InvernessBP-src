local UGameplayStatics = import("GameplayStatics")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local LevelStreamingMgr = {MaxLoadTimeSeconds = 60}
function LevelStreamingMgr:OnRegister()
  if Client then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local modType, _ = GameMainConfig.GetModType()
    if modType == "IceWorld3" then
      print(bWriteLog and "LevelStreamingMgr:OnRegister OverridePhyxMaterial 0")
      local STExtraGameInstance = import("STExtraGameInstance")
      local GameInstance = STExtraGameInstance.GetInstance()
      if slua.isValid(GameInstance) then
        GameInstance:ExecuteCMD("r.Landscape.DisableApplyOverridePhyxMaterial", 0)
      end
    end
  end
end
function LevelStreamingMgr:OnInit()
  print(bWriteLog and "LevelStreamingMgr:OnInit")
  self.bIsLoading = false
  self:AddCommonEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_REQUEST, self.OnLevelStreamingLoadRequest, self)
end
function LevelStreamingMgr:OnRelease()
  print(bWriteLog and "LevelStreamingMgr:OnRelease")
  self:CancelLoading()
  if Client then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local modType, _ = GameMainConfig.GetModType()
    if modType == "IceWorld3" then
      print(bWriteLog and "LevelStreamingMgr:OnRelease OverridePhyxMaterial 1")
      local STExtraGameInstance = import("STExtraGameInstance")
      local GameInstance = STExtraGameInstance.GetInstance()
      if slua.isValid(GameInstance) then
        GameInstance:ExecuteCMD("r.Landscape.DisableApplyOverridePhyxMaterial", 1)
      end
    end
  end
  LevelStreamingMgr.__super.OnRelease(self)
end
function LevelStreamingMgr:BeginGoto(InitViewPoint, bUseLoadingUI, bNeedLockInput, tickTime, KeyName)
  if self.bIsLoading then
    print(bWriteLog and "LevelStreamingMgr:BeginGoto is already loading state")
    return false
  end
  if InitViewPoint == nil then
    print(bWriteLog and "LevelStreamingMgr:BeginGoto InitViewPoint is null")
    return false
  end
  print(bWriteLog and "LevelStreamingMgr:BeginGoto InitViewPoint:" .. InitViewPoint:ToString())
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if uWorldComposition then
    self.    self.    self.bIsLoading = true
    self.KeyName = KeyName or ""
    uWorldComposition.Client    EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_BEGIN)
    self.LoadPercent = CGame:GetClientStreamingLevelLoadPercent(self.KeyName or "", true, false)
    if self.LoadPercent == 1 then
      self.bIsLoading = false
      EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END, true)
    else
      if self.bUseLoadingUI then
        self:RefreshLoadingUI(self.LoadPercent)
      end
      if self.bNeedLockInput then
        self:SetCanMoveAndTurn(false)
      end
      local UIUtil = require("client.common.ui_util")
      local WorldContextObject = UIUtil.GetGameInstance()
      self.LoadBeginTimeStamp = UGameplayStatics.GetRealTimeSeconds(WorldContextObject)
      tickTime = tickTime or 0.1
      self.TickHandler = self:AddGameTimer(tickTime, true, function()
        self:Tick()
      end)
    end
  else
    EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END, true)
  end
  return true
end
function LevelStreamingMgr:Tick()
  self:CalcLoadPercent()
end
function LevelStreamingMgr:CalcLoadPercent()
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local LastLoadPercent = self.LoadPercent
  local LoadTimeSeconds = UGameplayStatics.GetRealTimeSeconds(uWorld) - self.LoadBeginTimeStamp
  self.LoadPercent = CGame:GetClientStreamingLevelLoadPercent(self.KeyName or "", false, LoadTimeSeconds > self.MaxLoadTimeSeconds / 2)
  if self.LoadPercent == 1 then
    if self.TickHandler ~= nil then
      self:RemoveGameTimer(self.TickHandler)
      self.TickHandler = nil
    end
    self.bIsLoading = false
    if self.bUseLoadingUI then
      self:RefreshLoadingUI(self.LoadPercent)
    end
    if self.bNeedLockInput then
      self:SetCanMoveAndTurn(true)
    end
    EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END, true)
    print(bWriteLog and "LevelStreamingMgr LoadLevelStreaming Cost:", LoadTimeSeconds)
  else
    if LastLoadPercent ~= self.LoadPercent then
      if self.bUseLoadingUI then
        self:RefreshLoadingUI(self.LoadPercent)
      end
      EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_PROGERESSUPDATE, self.LoadPercent)
    end
    if LoadTimeSeconds > self.MaxLoadTimeSeconds then
      self:CancelLoading()
      return
    end
  end
end
function LevelStreamingMgr:CancelLoading()
  if not self.bIsLoading then
    print(bWriteLog and "LevelStreamingMgr CancelLoading break self.bIsLoading:", self.bIsLoading)
    return false
  end
  if self.TickHandler ~= nil then
    self:RemoveGameTimer(self.TickHandler)
    self.TickHandler = nil
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    print(bWriteLog and "LevelStreamingMgr CancelLoading break uWorld not Valid")
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    print(bWriteLog and "LevelStreamingMgr CancelLoading break uWorldComposition not Valid")
    return false
  end
  print(bWriteLog and "LevelStreamingMgr CancelLoading success LoadPercent:", self.LoadPercent)
  self.bIsLoading = false
  if self.bUseLoadingUI then
    self:RefreshLoadingUI(1)
  end
  if self.bNeedLockInput then
    self:SetCanMoveAndTurn(true)
  end
  EventSystem:postEvent(EVENTTYPE_LEVELSTREAMING, EVENTID_LEVELSTREAMING_LOAD_END, false)
  return true
end
function LevelStreamingMgr:RefreshLoadingUI(nPercent)
  local LoadingUI = UIManager.GetUI(UIManager.UI_Config.loading)
  LoadingUI = LoadingUI or UIManager.ShowUI(UIManager.UI_Config.loading)
  LoadingUI:UpdatePercent(nPercent)
end
function LevelStreamingMgr:SetCanMoveAndTurn(bEnable)
  local UIUtil = require("client.common.ui_util")
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if bEnable then
    if Game:IsClassOf(uPlayerController, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) then
      uPlayerController:ResetIgnoreMoveInput()
      uPlayerController:ResetIgnoreLookInput()
      local uPlayer = uPlayerController:GetPlayerCharacterSafety()
      print(bWriteLog and "LevelStreamingMgr SetCanMoveAndTurn true")
    end
  elseif Game:IsClassOf(uPlayerController, import("/Script/ShadowTrackerExtra.STExtraPlayerController")) then
    print(bWriteLog and "LevelStreamingMgr SetCanMoveAndTurn false")
    uPlayerController:JoystickTriggerSprint(false)
    uPlayerController:SetIgnoreMoveInput(true)
    uPlayerController:SetIgnoreLookInput(true)
    local uPlayer = uPlayerController:GetPlayerCharacterSafety()
  end
end
function LevelStreamingMgr:OnLevelStreamingLoadRequest(_, __, DestLocation, bNeedLoading, bNeedLockInput)
  self:BeginGoto(DestLocation, bNeedLoading, bNeedLockInput)
end
function LevelStreamingMgr:SetStreamingDistanceScaleAllLevel(Scale)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local bSetSuccess = uWorldComposition:SetStreamingDistanceScaleAllLevel(Scale)
  print(bWriteLog and "LevelStreamingMgr SetStreamingDistanceScaleAllLevel:", Scale, bSetSuccess)
  return bSetSuccess
end
function LevelStreamingMgr:SetStreamingDistanceScalePerLevel(levelName, Scale)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local bSetSuccess = uWorldComposition:SetStreamingDistanceScalePerLevel(levelName, Scale)
  print(bWriteLog and "LevelStreamingMgr SetStreamingDistanceScalePerLevel:", levelName, Scale, bSetSuccess)
  return bSetSuccess
end
function LevelStreamingMgr:SetStreamingDistanceScaleByLayer(layerName, Scale)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local bSetSuccess = uWorldComposition:SetStreamingDistanceScaleByLayer(layerName, Scale)
  print(bWriteLog and "LevelStreamingMgr SetStreamingDistanceScaleByLayer:", layerName, Scale, bSetSuccess)
  return bSetSuccess
end
function LevelStreamingMgr:SetStreamingDistanceScaleForLevels(levelNameList, Scale)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  for _, levelName in pairs(levelNameList) do
    local bSetSuccess = uWorldComposition:SetStreamingDistanceScalePerLevel(levelName, Scale)
    print(bWriteLog and "LevelStreamingMgr SetStreamingDistanceScaleForLevels:", levelName, Scale, bSetSuccess)
  end
  return true
end
function LevelStreamingMgr:LoadStreamLevel(levelName, bMakeVisibleAfterLoad, cb)
  print(bWriteLog and "LevelStreamingMgr LoadStreamLevel:", levelName)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local async = require("client.common.async")
  async.Run(function(co)
    GameplayStatics.LoadStreamLevel(uWorld, levelName, bMakeVisibleAfterLoad, false)
    if cb then
      cb()
    end
  end)
end
function LevelStreamingMgr:LoadStreamLevelNoLatent(levelName, bMakeVisibleAfterLoad, bShouldBlockOnLoad)
  if levelName == nil then
    print(bWriteLog and "LevelStreamingMgr:UnloadStreamLevel levelName is nil")
    return false
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if self:IsLevelStreamingMatchName(uLevelStreaming, levelName) then
      print(bWriteLog and "LevelStreamingMgr LoadStreamLevel:", levelName)
      uLevelStreaming.bShouldBlockOnLoad = bShouldBlockOnLoad == nil and true or bShouldBlockOnLoad
      uLevelStreaming.bShouldBeLoaded = true
      uLevelStreaming.bShouldBeVisible = bMakeVisibleAfterLoad == nil and true or bMakeVisibleAfterLoad
      uLevelStreaming.LevelLODIndex = -1
      ScriptHelperClient.SetLevelGamePlayLoadPriority(uLevelStreaming, 99)
      return true
    end
  end
  return false
end
function LevelStreamingMgr:UnloadStreamLevel(levelName)
  print(bWriteLog and "LevelStreamingMgr UnloadStreamLevel:", levelName)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local async = require("client.common.async")
  async.Run(function(co)
    GameplayStatics.UnloadStreamLevel(uWorld, levelName)
  end)
end
function LevelStreamingMgr:UnloadStreamLevelNoLatent(levelName)
  if levelName == nil then
    print(bWriteLog and "LevelStreamingMgr:UnloadStreamLevelNoLatent levelName is nil")
    return
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if self:IsLevelStreamingMatchName(uLevelStreaming, levelName) then
      print(bWriteLog and "LevelStreamingMgr UnloadStreamLevelNoLatent:", levelName)
      uLevelStreaming.bShouldBeLoaded = false
      uLevelStreaming.bShouldBeVisible = false
      return true
    end
  end
  return false
end
function LevelStreamingMgr:IsStreamLevelLoaded(levelName)
  if levelName == nil then
    print(bWriteLog and "LevelStreamingMgr:IsStreamLevelLoaded levelName is nil")
    return false
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if self:IsLevelStreamingMatchName(uLevelStreaming, levelName) then
      local uLevel = uLevelStreaming:GetLoadedLevel()
      return slua.isValid(uLevel)
    end
  end
  return false
end
function LevelStreamingMgr:GetStreamLevel(levelName)
  if levelName == nil then
    print(bWriteLog and "LevelStreamingMgr:GetStreamLevel levelName is nil")
    return
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if self:IsLevelStreamingMatchName(uLevelStreaming, levelName) then
      return uLevelStreaming
    end
  end
  return
end
function LevelStreamingMgr:IsStreamLevelExist(levelName)
  local uLevelStreaming = self:GetStreamLevel(levelName)
  return slua.isValid(uLevelStreaming)
end
function LevelStreamingMgr:IsLevelStreamingMatchName(uLevelStreaming, LevelName)
  local StringUtil = require("common.string_util")
  local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
  return StringUtil.Ends(PackageName, LevelName)
end
function LevelStreamingMgr:LoadStreamLevels(levelNameList)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local async = require("client.common.async")
  async.Run(function(co)
    for _, levelName in pairs(levelNameList) do
      print(bWriteLog and "LevelStreamingMgr LoadStreamLevels:", levelName)
      GameplayStatics.LoadStreamLevel(uWorld, levelName, true, false)
    end
  end)
end
function LevelStreamingMgr:UnloadStreamLevels(levelNameList)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local async = require("client.common.async")
  async.Run(function(co)
    for _, levelName in pairs(levelNameList) do
      print(bWriteLog and "LevelStreamingMgr UnloadStreamLevels:", levelName)
      GameplayStatics.UnloadStreamLevel(uWorld, levelName)
    end
  end)
end
function LevelStreamingMgr:RegistLevelLoadedFunc(levelName, bCallWhenAlreadyLoaded, bContainsSearch, callbackFunc, ...)
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  if not type(callbackFunc) == "function" then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if StreamingLevels then
    for _, uLevelStreaming in pairs(StreamingLevels) do
      if uLevelStreaming.PackageNameToLoad == levelName or bContainsSearch and string.find(uLevelStreaming.PackageNameToLoad, levelName) then
        if uLevelStreaming:IsLevelLoaded() and uLevelStreaming:IsLevelVisible() then
          if bCallWhenAlreadyLoaded then
            callbackFunc(...)
            return true
          else
            return false
          end
        else
          local common = require("client.slua_ui_framework.common")
          local args = table.pack(...)
          self:AddControlEvent(uLevelStreaming, "OnLevelShown", function(...)
            self:RemoveControlEvent(uLevelStreaming, "OnLevelShown")
            common.CallCombinationArgs(callbackFunc, args, ...)
          end)
        end
        return true
      end
    end
  end
  return false
end
function LevelStreamingMgr:AddStreamLevel(levelPath, bShouldBeLoaded, bShouldBeVisible, bShouldBlockOnLoad)
  if levelPath == nil then
    return false
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.AddStreamingLevel(uWorld, levelPath, bShouldBeLoaded, bShouldBeVisible, bShouldBlockOnLoad)
end
function LevelStreamingMgr:ChangeStreamLevelVisible(levelName, bShouldBeVisible)
  if levelName == nil then
    return false
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if self:IsLevelStreamingMatchName(uLevelStreaming, levelName) then
      uLevelStreaming.    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, LevelStreamingMgr)
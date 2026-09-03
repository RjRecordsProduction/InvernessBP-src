local EPawnState = import("EPawnState")
local SoundVisualizationSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SoundVisualizationType = require("GameLua.Mod.BaseMod.GamePlay.SoundVisualization.SoundVisualizationType")
function SoundVisualizationSubsystem:_PostConstruct()
  print(bWriteLog and "SoundVisualizationSubsystem:_PostConstruct")
  self.ParachuteAndLandingMatchStartTime = 150
end
function SoundVisualizationSubsystem:OnRegister()
  print(bWriteLog and "SoundVisualizationSubsystem:OnRegister")
  self:InitVariables()
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnDeath", self.OnPlayerDeath, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "triggerShotVoiceCheckDelegate", self.AddWeaponShotVoiceToCache, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "triggerMoveVoiceCheckDelegate", self.AddMoveVoiceToCache, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "triggerVehicleVoiceCheckDelegate", self.AddVehicleVoiceToCache, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "triggerGlassVoiceCheckDelegate", self.AddGlassVoiceToCache, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "tirggerParachuteVoiceCheckDelegate", self.AddParachuteVoiceToCache, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "tirggerLandingVoiceCheckDelegate", self.AddLandingVoiceToCache, self)
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "PlayerController", function()
    print(bWriteLog and "SoundVisualizationSubsystem:PlayerController")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      self.PlayerKey = PlayerController.PlayerKey
    end
    self.CanShowVoice = self:CheckIsVoiceCanShow()
    if not self.CanShowVoice then
      self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
        [1] = "FightingState"
      }, self.OnEnterFightingState, self)
    end
    self:CheckModAllowMainSound()
    if self.AllowMainSound ~= false then
      self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_TAKE_DAMAGE_CLIENT, self.AddBeHitToCache, self)
    end
  end)
  self.bIsMapOpen = true
  self:CheckHasMapSoundVisualUI()
end
function SoundVisualizationSubsystem:CheckModAllowMainSound()
  if self.AllowMainSound == nil then
    local UIUtil = require("client.common.ui_util")
    local uGameInstance = UIUtil.GetGameInstance()
    if not slua.isValid(uGameInstance) then
      return false
    end
    local MainModeID = uGameInstance:GetMainModeID()
    print(bWriteLog and "SoundVisualizationSubsystem:CheckModAllowMainSound: " .. tostring(MainModeID))
    if not MainModeID or MainModeID == 0 then
      return false
    end
    if self.AllowMainSoundModGroup[MainModeID] then
      self.AllowMainSound = true
    else
      self.AllowMainSound = false
    end
  end
  return self.AllowMainSound
end
function SoundVisualizationSubsystem:SwitchMapSoundOpen()
  if self.bIsMapOpen then
    self.bIsMapOpen = false
  else
    self.bIsMapOpen = true
  end
end
function SoundVisualizationSubsystem:OnEnterFightingState()
  self.CanShowVoice = true
end
function SoundVisualizationSubsystem:InitVariables()
  self.MainSoundVisualWidgetPool = {}
  self.VisibleSoundWidgetPool = {}
  self.MaxSmallTipsCount = 24
  self.MapSoundCache = {}
  self.MainSoundCache = {}
  self.DamageInfoCache = {}
  self.MapEachProcessNum = 3
  self.ProcessMapCache = {}
  self.MainEachProcessNum = 3
  self.DamageEachProcessNum = 2
  self.ProcessMainCache = {}
  self.ProcessDamageCache = {}
  self.MaxMainVoice = 4
  self.AllowMainSoundModGroup = {
    [101] = true,
    [102] = true,
    [103] = true,
    [111] = true,
    [112] = true,
    [113] = true,
    [401] = true,
    [402] = true,
    [403] = true,
    [411] = true,
    [412] = true,
    [413] = true
  }
end
function SoundVisualizationSubsystem:AddLuaCustomVoiceToCache(InOwnerPawn, weapon, posVector, showTime, isSlience, isExplosion, CustomVoiceKey)
  print(bWriteLog and "SoundVisualizationSubsystem:AddLuaCustomVoiceToCache")
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    print(bWriteLog and "SoundVisualizationSubsystem:AddLuaCustomVoiceToCache CanShowVoice False")
    return
  end
  self.CanShowVoice = true
  local Character = InOwnerPawn
  if not slua.isValid(Character) and slua.isValid(weapon) then
    Character = weapon:GetOwnerPawn()
  end
  local myCharacter = GameplayData.GetPlayerCharacter()
  if not self:IsNeedShowVoice(Character, myCharacter) then
    print(bWriteLog and "SoundVisualizationSubsystem:AddLuaCustomVoiceToCache IsNeedShowVoice False")
    return
  end
  local newCache = self:CreateNewCacheInfo(Character, posVector, showTime, isSlience, isExplosion, weapon, true, SoundVisualizationType.Shot)
  if newCache then
    newCache.  end
  self:CheckMapCache(Character, newCache)
  self:CheckMainCache(Character, posVector, SoundVisualizationType.Shot, newCache)
end
function SoundVisualizationSubsystem:AddWeaponShotVoiceToCache(InOwnerPawn, weapon, posVector, showTime, isSlience, isExplosion)
  print(bWriteLog and "SoundVisualizationSubsystem:AddWeaponShotVoceToCache")
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    print(bWriteLog and "SoundVisualizationSubsystem:AddWeaponShotVoceToCache CanShowVoice False")
    return
  end
  self.CanShowVoice = true
  local Character = InOwnerPawn
  if not slua.isValid(Character) and slua.isValid(weapon) then
    Character = weapon:GetOwnerPawn()
  end
  local myCharacter = GameplayData.GetPlayerCharacter()
  if not self:IsNeedShowVoice(Character, myCharacter) then
    print(bWriteLog and "SoundVisualizationSubsystem:AddWeaponShotVoceToCache IsNeedShowVoice False")
    return
  end
  local newCache = self:CreateNewCacheInfo(Character, posVector, showTime, isSlience, isExplosion, weapon, true, SoundVisualizationType.Shot)
  self:CheckMapCache(Character, newCache)
  self:CheckMainCache(Character, posVector, SoundVisualizationType.Shot, newCache)
end
function SoundVisualizationSubsystem:AddMoveVoiceToCache(character, posVector, showTime)
  print(bWriteLog and "SoundVisualizationSubsystem:AddMoveVoiceToCache")
  local myCharacter = GameplayData.GetPlayerCharacter()
  self.CanShowVoice = self:CheckIsVoiceCanShow()
  if not self.CanShowVoice or not self:IsNeedShowVoice(character, myCharacter) then
    print(bWriteLog and "SoundVisualizationSubsystem:AddWeaponShotVoceToCache CanShowVoice" .. tostring(self.CanShowVoice))
    return
  end
  local newCache = self:CreateNewCacheInfo(character, posVector, showTime, false, false, 0, false, SoundVisualizationType.Move)
  self:CheckMapCache(character, newCache)
  self:CheckMainCache(character, posVector, SoundVisualizationType.Move, newCache)
end
function SoundVisualizationSubsystem:AddVehicleVoiceToCache(vehicle, posVector, showTime)
  print(bWriteLog and "SoundVisualizationSubsystem:AddVehicleVoiceToCache")
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    print(bWriteLog and "SoundVisualizationSubsystem:AddVehicleVoiceToCache CanShowVoice False")
    return
  end
  self.CanShowVoice = true
  local myCharacter = GameplayData.GetPlayerCharacter()
  local character
  if slua.isValid(vehicle) then
    character = vehicle:GetDriver()
  end
  if not self:IsNeedShowVoice(character, myCharacter) then
    print(bWriteLog and "SoundVisualizationSubsystem:AddVehicleVoiceToCache CanShowVoice False")
    return
  end
  local newCache = self:CreateNewCacheInfo(character, posVector, showTime, false, false, 0, false, SoundVisualizationType.Vehicle, vehicle)
  self:CheckMapCache(character, newCache)
  self:CheckMainCache(character, posVector, SoundVisualizationType.Vehicle, newCache)
end
function SoundVisualizationSubsystem:AddGlassVoiceToCache(posVector, showTime)
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    return
  end
  self.CanShowVoice = true
  local newCache = self:CreateNewCacheInfo(nil, posVector, showTime, false, false, 0, false, SoundVisualizationType.Glass)
  self:CheckMapCache(nil, newCache)
end
function SoundVisualizationSubsystem:AddBeHitToCache(_, __, DamageInfo)
  local AllowMainSound = self:CheckModAllowMainSound()
  if not (self.CanShowVoice or self:CheckIsVoiceCanShow()) or AllowMainSound == false then
    return
  end
  self.CanShowVoice = true
  if not self:UseNewHitStyle() then
    return
  end
  local Casuer = DamageInfo.Caster
  local Target = DamageInfo.Target
  if not slua.isValid(Casuer) or not slua.isValid(Target) then
    return
  end
  if self.PlayerKey == nil or self.PlayerKey == 0 then
    local myCharacter = GameplayData.GetPlayerCharacter()
    if not slua.isValid(myCharacter) then
      return
    end
    self.PlayerKey = myCharacter.PlayerKey
  end
  if self.PlayerKey == Casuer.PlayerKey or self.PlayerKey ~= Target.PlayerKey then
    return
  end
  if self.bForbitHurtEffect == nil then
    local gamestate = slua_GameFrontendHUD:GetGameState()
    if not slua.isValid(gamestate) then
      return
    end
    self.bForbitHurtEffect = gamestate.bForbitHurtEffect
  end
  if self.bForbitHurtEffect then
    return
  end
  local replaceIndex = -1
  for index, value in ipairs(self.DamageInfoCache) do
    if value.Casuer == Casuer then
      replaceIndex = index
      break
    end
  end
  local DamageTempCache = {
    Caster = DamageInfo.Caster,
    Target = DamageInfo.Target
  }
  if replaceIndex == -1 then
    table.insert(self.DamageInfoCache, DamageTempCache)
  else
    self.DamageInfoCache[replaceIndex] = DamageTempCache
  end
  self:CreateProcessTimer()
end
function SoundVisualizationSubsystem:IsParachuteAndLandingMatchStartTime()
  local GameState = CGameState
  if not slua.isValid(CGameState) then
    return false
  end
  local CurrentTime = GameState:GetServerWorldTimeSeconds()
  return CurrentTime - GameState.StartFlyTime > self.ParachuteAndLandingMatchStartTime
end
function SoundVisualizationSubsystem:AddParachuteVoiceToCache(Character, posVector, showTime)
  if not self:IsParachuteAndLandingMatchStartTime() then
    return
  end
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    return
  end
  if not slua.isValid(Character) or Character:HasState(EPawnState.Dying) or Character:HasState(EPawnState.Dead) then
    return
  end
  self.CanShowVoice = true
  local newCache = self:CreateNewCacheInfo(Character, posVector, showTime, false, false, 0, false, SoundVisualizationType.Parachute)
  self:CheckMapCache(Character, newCache)
  self:CheckMainCache(Character, posVector, SoundVisualizationType.Parachute, newCache)
end
function SoundVisualizationSubsystem:AddLandingVoiceToCache(Character, posVector, showTime)
  if not self:IsParachuteAndLandingMatchStartTime() then
    return
  end
  if not self.CanShowVoice and not self:CheckIsVoiceCanShow() then
    return
  end
  if not slua.isValid(Character) or Character:HasState(EPawnState.Dying) or Character:HasState(EPawnState.Dead) then
    return
  end
  self.CanShowVoice = true
  local newCache = self:CreateNewCacheInfo(Character, posVector, showTime, false, false, 0, false, SoundVisualizationType.Landing)
  self:CheckMapCache(Character, newCache)
  self:CheckMainCache(Character, posVector, SoundVisualizationType.Landing, newCache)
end
function SoundVisualizationSubsystem:CreateNewCacheInfo(character, posVector, showTime, isSlience, isExplosion, weapon, isWeapon, soundType, vehicle)
  local TimeUtil = require("client.common.time_util")
  local newCache = {
    Character = character,
    PosVector = posVector,
    ShowTime = showTime,
    IsSlience = isSlience,
    IsExplosion = isExplosion,
    Weapon = weapon,
    IsWeapon = isWeapon,
    StartTime = TimeUtil.GetMiliseconds(),
    SoundType = soundType,
    Distance = posVector:Size(),
    Vehicle = vehicle
  }
  return newCache
end
function SoundVisualizationSubsystem:CheckMapCache(Character, newCache)
  if not self.bIsMapOpen then
    print(bWriteLog and "SoundVisualizationSubsystem:CheckMapCache Map Is Not Open")
    return
  end
  local bIsFindReplaceItem = false
  local mapFinalIndex = 0
  for index, value in ipairs(self.MapSoundCache) do
    if slua.isValid(value.Character) and slua.isValid(Character) and value.Character.PlayerKey == Character.PlayerKey then
      mapFinalIndex = index
      bIsFindReplaceItem = true
      break
    end
  end
  if not bIsFindReplaceItem then
    table.insert(self.MapSoundCache, newCache)
  else
    self.MapSoundCache[mapFinalIndex] = newCache
  end
  if 0 < #self.MapSoundCache then
    self:CreateProcessTimer()
  end
end
function SoundVisualizationSubsystem:CheckMainCache(Character, posVector, soundType, newCache)
  if not (soundType == SoundVisualizationType.BeHit or self:IsMainCanShowSoundVisualization()) or newCache.IsExplosion == true then
    print(bWriteLog and "SoundVisualizationSubsystem:CheckMapCache CheckMainCache Failed " .. tostring(soundType) .. " newCache.IsExplosion: " .. tostring(newCache.IsExplosion))
    if newCache.CustomVoiceKey then
      print(bWriteLog and "SoundVisualizationSubsystem:CheckMapCache CustomVoiceKey : " .. tostring(newCache.CustomVoiceKey))
    else
      return
    end
  end
  local bIsMainSoundCacheFull = #self.MainSoundCache >= self.MaxMainVoice
  local maxDistance = newCache.Distance + 1
  local mainFinalIndex = -1
  local hasNormalSound = false
  local minTime = newCache.StartTime
  for index, value in ipairs(self.MainSoundCache) do
    local valueSoundType = value.SoundType
    local valueTime = value.StartTime
    if slua.isValid(value.Character) and slua.isValid(Character) and value.Character == Character then
      mainFinalIndex = -2
      if (valueSoundType ~= soundType or not (newCache.StartTime - valueTime <= 500)) and (valueSoundType ~= SoundVisualizationType.BeHit or soundType == SoundVisualizationType.BeHit and valueSoundType == SoundVisualizationType.BeHit) then
        mainFinalIndex = index
      end
      break
    end
    if bIsMainSoundCacheFull then
      if not hasNormalSound and valueSoundType ~= SoundVisualizationType.BeHit then
        hasNormalSound = true
        maxDistance = -1
        mainFinalIndex = -1
      end
      local valueDistance = value.Distance
      if not hasNormalSound and maxDistance <= valueDistance and valueSoundType == SoundVisualizationType.BeHit then
        maxDistance = valueDistance
        mainFinalIndex = index
      elseif hasNormalSound and minTime > valueTime and valueSoundType ~= SoundVisualizationType.BeHit then
        minTime = valueTime
        mainFinalIndex = index
      end
    end
  end
  if mainFinalIndex == -2 then
    return
  elseif mainFinalIndex ~= -1 then
    self.MainSoundCache[mainFinalIndex] = newCache
  elseif not bIsMainSoundCacheFull then
    table.insert(self.MainSoundCache, newCache)
  end
  if #self.MainSoundCache > 0 then
    self:CreateProcessTimer()
  end
end
function SoundVisualizationSubsystem:CreateProcessTimer()
  if not self.CacheTimer then
    self.CacheTimer = self:AddGameTimer(0.15, true, function()
      self:AddBeHitInfoToCache()
      self:AddCacheVoice()
    end)
  end
end
function SoundVisualizationSubsystem:AddBeHitInfoToCache()
  if #self.ProcessDamageCache == 0 and 0 < #self.DamageInfoCache then
    self.ProcessDamageCache = self.DamageInfoCache
    self.DamageInfoCache = {}
  end
  if self.ProcessDamageCache and #self.ProcessDamageCache > 0 then
    local stopIndex = 1
    if #self.ProcessDamageCache > self.MapEachProcessNum then
      stopIndex = #self.ProcessDamageCache - self.MapEachProcessNum + 1
    end
    local playerLocation
    for i = #self.ProcessDamageCache, stopIndex, -1 do
      local Caster = self.ProcessDamageCache[i].Caster
      local Target = self.ProcessDamageCache[i].Target
      if not playerLocation and slua.isValid(Target) and Target.K2_GetActorLocation then
        playerLocation = Target:K2_GetActorLocation()
      end
      if slua.isValid(Caster) and playerLocation then
        print(bWriteLog and "SoundVisualizationSubsystem:AddBeHitInfoToCache ,", Caster)
        local casterLocation = Caster:K2_GetActorLocation()
        local posVector = casterLocation - playerLocation
        local newCache = self:CreateNewCacheInfo(Caster, posVector, 3, false, false, 0, false, SoundVisualizationType.BeHit)
        self:CheckMainCache(Caster, posVector, 5, newCache)
      end
      table.remove(self.ProcessDamageCache, i)
    end
  end
end
function SoundVisualizationSubsystem:ComputeMapSoundIndex(posVector)
  local Direction = FVector2D(posVector.X, -posVector.Y)
  Direction:Normalize(0)
  local NowAngle = math.deg(math.acos(Direction.X))
  if -posVector.Y < 0 then
    NowAngle = 360.0 - NowAngle
  end
  local Index = NowAngle / (360 / self.MaxSmallTipsCount)
  Index = math.ceil(Index)
  return Index
end
function SoundVisualizationSubsystem:AddCacheVoice()
  if #self.ProcessMapCache == 0 and 0 < #self.MapSoundCache then
    self:CheckHasMapSoundVisualUI()
    if self.MapSoundVisualUI and slua.isValid(self.MapSoundVisualUI.UIRoot) then
      self.ProcessMapCache = self.MapSoundCache
      self.MapSoundCache = {}
      print(bWriteLog and "SoundVisualizationSubsystem:AddCacheVoice ProcessMapCache  ", #self.ProcessMapCache, " : ", #self.MapSoundCache)
    end
  end
  if #self.ProcessMainCache == 0 and 0 < #self.MainSoundCache then
    self.ProcessMainCache = self.MainSoundCache
    self.MainSoundCache = {}
    print(bWriteLog and "SoundVisualizationSubsystem:AddCacheVoice ProcessMainCache ", #self.ProcessMainCache, " : ", #self.MainSoundCache)
  end
  if self.ProcessMapCache and #self.ProcessMapCache > 0 then
    local mapStopIndex = 1
    if #self.ProcessMapCache > self.MapEachProcessNum then
      mapStopIndex = #self.ProcessMapCache - self.MapEachProcessNum + 1
    end
    for i = #self.ProcessMapCache, mapStopIndex, -1 do
      local cacheInfo = self.ProcessMapCache[i]
      if self.MapSoundVisualUI then
        self.MapSoundVisualUI:ProcessCache(cacheInfo)
      end
      table.remove(self.ProcessMapCache, i)
    end
  end
  if self.ProcessMainCache and 0 < #self.ProcessMainCache then
    local myCharacter = GameplayData.GetPlayerCharacter()
    local mainStopIndex = 1
    if #self.ProcessMainCache > self.MainEachProcessNum then
      mainStopIndex = #self.ProcessMainCache - self.MainEachProcessNum + 1
    end
    for i = #self.ProcessMainCache, mainStopIndex, -1 do
      local cacheInfo = self.ProcessMainCache[i]
      local MainSoundWidget = self:GetOneMainSoundVisualUI(cacheInfo.PosVector:Size(), cacheInfo.Character, cacheInfo.SoundType, cacheInfo.StartTime)
      if MainSoundWidget then
        MainSoundWidget:ProcessCache(cacheInfo, myCharacter)
      end
      table.remove(self.ProcessMainCache, i)
    end
  end
  if #self.ProcessMainCache == 0 and #self.MainSoundCache == 0 and #self.ProcessMapCache == 0 and #self.MapSoundCache == 0 and #self.ProcessDamageCache == 0 and #self.DamageInfoCache == 0 then
    self:RemoveGameTimer(self.CacheTimer)
    self.CacheTimer = nil
  end
end
function SoundVisualizationSubsystem:CheckHasMapSoundVisualUI()
  if not self.MapSoundVisualUI then
    if not UIManager.GetUI(UIManager.UI_Config_InGame.MapSoundVisualization) then
      self.MapSoundVisualUI = UIManager.ShowUI(UIManager.UI_Config_InGame.MapSoundVisualization)
    else
      self.MapSoundVisualUI = UIManager.GetUI(UIManager.UI_Config_InGame.MapSoundVisualization)
    end
  end
end
function SoundVisualizationSubsystem:GetOneMainSoundVisualUI(distance, character, soundType, startTime)
  if #self.VisibleSoundWidgetPool >= self.MaxMainVoice then
    local newIndex = self:FetchUINeedToBeReplaced(distance, character, soundType, true, startTime)
    if newIndex < 0 then
      return nil
    end
    local widget = self.VisibleSoundWidgetPool[newIndex]
    self:InitVisibleSoundWidget(newIndex, distance, character, soundType, startTime)
    return widget
  else
    local newIndex = self:FetchUINeedToBeReplaced(distance, character, soundType, false, startTime)
    if newIndex == -2 then
      return nil
    end
    if newIndex ~= -1 then
      local widget = self.VisibleSoundWidgetPool[newIndex]
      self:InitVisibleSoundWidget(newIndex, distance, character, soundType, startTime)
      return widget
    end
    if 0 < #self.MainSoundVisualWidgetPool then
      local widget = self.MainSoundVisualWidgetPool[1]
      table.remove(self.MainSoundVisualWidgetPool, 1)
      local newInsertIndex = #self.VisibleSoundWidgetPool + 1
      table.insert(self.VisibleSoundWidgetPool, newInsertIndex, widget)
      self:InitVisibleSoundWidget(newInsertIndex, distance, character, soundType, startTime)
      return widget
    else
      self:CheckHasSoundWidgetRoot()
      if not self.MainSoundWidgetRoot then
        return nil
      end
      local widget = UIManager.ShowUI(UIManager.UI_Config_InGame.MainSoundVisualizationUI)
      local newInsertIndex = #self.VisibleSoundWidgetPool + 1
      table.insert(self.VisibleSoundWidgetPool, newInsertIndex, widget)
      self:InitVisibleSoundWidget(newInsertIndex, distance, character, soundType, startTime)
      return widget
    end
  end
end
function SoundVisualizationSubsystem:FetchUINeedToBeReplaced(distance, character, soundType, isFull, startTime)
  local newIndex = -1
  local hasNormalSound = false
  local maxDistance = distance
  local minTime = startTime
  for index = 1, #self.VisibleSoundWidgetPool do
    local widgetSoundType = self.VisibleSoundWidgetPool[index].SoundType
    if slua.isValid(character) and slua.isValid(self.VisibleSoundWidgetPool[index].Character) and character.PlayerKey == self.VisibleSoundWidgetPool[index].Character.PlayerKey then
      if soundType ~= SoundVisualizationType.BeHit and widgetSoundType == SoundVisualizationType.BeHit then
        newIndex = -2
        break
      end
      newIndex = index
      break
    end
    if isFull then
      if not hasNormalSound and widgetSoundType ~= SoundVisualizationType.BeHit then
        hasNormalSound = true
        maxDistance = -1
        newIndex = -1
      end
      local widgetStartTime = self.VisibleSoundWidgetPool[index].StartTime
      local widgetDistance = self.VisibleSoundWidgetPool[index].Distance
      if not hasNormalSound and maxDistance <= widgetDistance and widgetSoundType == SoundVisualizationType.BeHit then
        maxDistance = widgetDistance
        newIndex = index
      elseif hasNormalSound and minTime > widgetStartTime and widgetSoundType ~= SoundVisualizationType.BeHit then
        minTime = widgetStartTime
        newIndex = index
      end
    end
  end
  return newIndex
end
function SoundVisualizationSubsystem:InitVisibleSoundWidget(index, distance, character, soundType, startTime)
  self.VisibleSoundWidgetPool[index].Distance = distance
  self.VisibleSoundWidgetPool[index].Character = character
  self.VisibleSoundWidgetPool[index].SoundType = soundType
  self.VisibleSoundWidgetPool[index].StartTime = startTime
end
function SoundVisualizationSubsystem:CheckHasSoundWidgetRoot()
  if not self.MainSoundWidgetRoot then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    if not slua.isValid(MainControlBaseUI) then
      return nil
    end
    if not slua.isValid(MainControlBaseUI.CanvasPanel_Hit) then
      return nil
    end
    self.MainSoundWidgetRoot = MainControlBaseUI.CanvasPanel_Hit
  end
end
function SoundVisualizationSubsystem:CheckIsVoiceCanShow()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    return true
  end
  local CurGameState = uGameState:GetGameModeState()
  if not CurGameState then
    return true
  end
  if CurGameState ~= "FightingState" then
    return false
  end
  if self.bOptimizeDisable then
    return false
  end
  return true
end
function SoundVisualizationSubsystem:SetOptimizeDisable(bDisable)
  self.bOptimizeDisable = bDisable
  self.CanShowVoice = self:CheckIsVoiceCanShow()
end
function SoundVisualizationSubsystem:IsNeedShowVoice(otherCharacter, myCharacter)
  if not slua.isValid(otherCharacter) or not slua.isValid(myCharacter) then
    return true
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  if uPlayerController:IsInSpectatingEnemy() or uPlayerController:IsSpectator() and myCharacter == otherCharacter then
    return false
  end
  if uPlayerController:IsInPetSpectator() and myCharacter == otherCharacter then
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if Game:IsValid(uGameState) then
    if uGameState.bForbitAudioVisual then
      print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case bForbitAudioVisual")
      return false
    end
    if uGameState.bIsTrainingMode then
      local uPlayerState = GameplayData.GetPlayerState()
      if not Game:IsValid(uPlayerState) then
        print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case uPlayerState")
        return false
      end
      if not uPlayerState.bEnableAITraining then
        print(bWriteLog and "SoundVisualizationSubsystem:IsNeedShowVoice False Case bEnableAITraining")
        return false
      end
    end
  end
  local CurCharacterAttr = myCharacter:GetAttrValue("IsInUnderGroundArea")
  local OtherCharacterAttr = otherCharacter:GetAttrValue("IsInUnderGroundArea")
  if math.abs(CurCharacterAttr - OtherCharacterAttr) < 0.1 then
    return true
  end
  return false
end
function SoundVisualizationSubsystem:OnUIHide(widget)
  for index = 1, #self.VisibleSoundWidgetPool do
    local tempWidget = self.VisibleSoundWidgetPool[index]
    if tempWidget and widget == tempWidget then
      table.remove(self.VisibleSoundWidgetPool, index)
      table.insert(self.MainSoundVisualWidgetPool, #self.MainSoundVisualWidgetPool + 1, widget)
      return
    end
  end
end
function SoundVisualizationSubsystem:IsMainCanShowSoundVisualization()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local SettingValue = SettingModule:GetOptionValue("SoundVisualizationType")
  if SettingValue == 3 then
    return true
  else
    return false
  end
end
function SoundVisualizationSubsystem:UseNewHitStyle()
  return self:IsMainCanShowSoundVisualization()
end
function SoundVisualizationSubsystem:OnRelease()
  print(bWriteLog and "SoundVisualizationSubsystem:OnRelease")
  if self.MainSoundVisualWidgetPool and #self.MainSoundVisualWidgetPool > 0 then
    for key, value in pairs(self.MainSoundVisualWidgetPool) do
      value:Close()
    end
    self.MainSoundVisualWidgetPool = {}
  end
  if self.VisibleSoundWidgetPool and 0 < #self.VisibleSoundWidgetPool then
    for key, value in pairs(self.VisibleSoundWidgetPool) do
      value:Close()
    end
    self.VisibleSoundWidgetPool = {}
  end
  if UIManager.UI_Config_InGame.MapSoundVisualization and UIManager.GetUI(UIManager.UI_Config_InGame.MapSoundVisualization) then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MapSoundVisualization)
  end
  self.MapSoundVisualUI = nil
  SoundVisualizationSubsystem.__super.OnRelease(self)
end
function SoundVisualizationSubsystem:OnPlayerDeath()
  print(bWriteLog and "SoundVisualizationSubsystem:OnPlayerDeath")
  self.MapSoundCache = {}
  self.MainSoundCache = {}
  self.DamageInfoCache = {}
  self.ProcessMapCache = {}
  self.ProcessMainCache = {}
  self.ProcessDamageCache = {}
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, SoundVisualizationSubsystem)
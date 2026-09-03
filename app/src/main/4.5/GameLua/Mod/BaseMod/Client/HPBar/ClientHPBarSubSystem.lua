local ClientHPBarSubSystem = {}
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UBusinessHelper = import("BusinessHelper")
local CHECK_FOCUS_ACTOR_INTERVAL = 0.5
local CHECK_FOCUS_ACTOR_IDLE_INTERVAL = 0.75
local IDLE_THRESHOLD = 3
function ClientHPBarSubSystem:OnInit()
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local HPBarConfig = ClientGameMain.GetUIOtherSetting("HPBarConfig")
  log_tree(bWriteLog and "ClientHPBarSubSystem:OnInit", HPBarConfig)
  if HPBarConfig == nil then
    print(bWriteLog and "ClientHPBarSubSystem:OnInit no config!")
    return
  end
  if self:IsPlayingReplay() then
    print(bWriteLog and "ClientHPBarSubSystem:OnInit Playing Replay!")
  end
  print(bWriteLog and "ClientHPBarSubSystem:OnInit", HPBarConfig.bNeedFocusShowHP, HPBarConfig.bNeedBossHPBar)
  self.DEFAULT_CHECK_CONFIG = {
    SphereCheckRadius = 50,
    CheckDistance = 5000,
    CheckAngle = 0,
    CheckObjectTypes = {
      0,
      1,
      2,
      4,
      11
    },
    ValidActorClass = {},
    FanCheckObjectTypes = {2},
    bDebugShow = false,
    CheckActorNum = 1,
    CheckBlock = true,
    bTickOnSpectator = false
  }
  if HPBarConfig.bNeedBossHPBar and not UIManager.GetUI(UIManager.UI_Config_InGame.IngameHPUIBase) then
    self.BossHPBarUI = UIManager.ShowUI(UIManager.UI_Config_InGame.IngameHPUIBase)
  end
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  self.HitHpBarStayTime = 2.5
  self.LookHpBarStayTime = 0.75
  if slua.isValid(playerController) then
    local uPawn = playerController:GetPlayerCharacterSafety()
    if slua.isValid(uPawn) then
      self:AddControlEvent(uPawn, "OnClientPushDamageEvent", self.HandleTakeDamage, self)
    end
  end
  printf("ClientHPBarSubSystem:OnInit Ok111")
  self.CharacterHPDataMap = {}
  self.VectorZero = FVector(0, 0, 0)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_ADD_HPBAR, self.OnAddHPBar, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_REMOVE_HPBAR, self.OnRemoveHPBar, self)
  local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
  print(bWriteLog and "UIBPFunctionLibrary", UIBPFunctionLibrary, HPBarConfig.bNeedFocusShowHP)
  if HPBarConfig.bNeedFocusShowHP then
    self.FocusActorCheckParam = import("FocusActorCheckParam")()
    local TableUtil = require("common.table_util")
    local CheckConfig = TableUtil.CopyTable(self.DEFAULT_CHECK_CONFIG)
    if HPBarConfig.CheckConfig then
      for key, value in pairs(HPBarConfig.CheckConfig) do
        CheckConfig[key] = value
      end
    end
    self.FocusActorCheckParam.SphereCheckRadius = CheckConfig.SphereCheckRadius
    self.FocusActorCheckParam.CheckDistance = CheckConfig.CheckDistance
    self.FocusActorCheckParam.CheckAngle = CheckConfig.CheckAngle
    self.FocusActorCheckParam.FanCheckObjectTypes = CheckConfig.FanCheckObjectTypes
    self.FocusActorCheckParam.bDebugShow = CheckConfig.bDebugShow
    self.FocusActorCheckParam.CheckActorNum = CheckConfig.CheckActorNum
    self.FocusActorCheckParam.CheckBlock = CheckConfig.CheckBlock
    self.FocusActorCheckParam.bIgnoreSelfVehicle = CheckConfig.bIgnoreSelfVehicle or false
    for _, type in ipairs(CheckConfig.CheckObjectTypes) do
      slua.IndexReference(self.FocusActorCheckParam, "CheckObjectTypes"):Add(type)
    end
    for _, ClassName in ipairs(CheckConfig.ValidActorClass) do
      local ValidActorClass
      if string.sub(ClassName, 1, string.len("/Game")) == "/Game" then
        ValidActorClass = slua.loadClass(ClassName)
      else
        ValidActorClass = import(ClassName)
      end
      if slua.isValid(ValidActorClass) then
        slua.IndexReference(self.FocusActorCheckParam, "ValidActorClass"):Add(ValidActorClass)
      end
    end
    print(bWriteLog and "ClientHPBarSubSystem FocusActorCheckParam", self.FocusActorCheckParam.CheckObjectTypes:Num(), self.FocusActorCheckParam.ValidActorClass:Num())
    self.CurFocusActor = nil
    self.CurFocusActorArray = {}
    self._    self._IdleEmptyCount = 0
    self._CurTickInterval = CHECK_FOCUS_ACTOR_INTERVAL
    self:_StartTickRefreshTimer(CHECK_FOCUS_ACTOR_INTERVAL)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_ON_HPBAR_SUBSYSTEM_INIT)
  self.HPBarTypeCache = {}
  self.HPBarUIConfigCache = {}
end
function ClientHPBarSubSystem:_StartTickRefreshTimer(Interval)
  if self.TickCheckFocusTimer then
    self:RemoveGameTimer(self.TickCheckFocusTimer)
    self.TickCheckFocusTimer = nil
  end
  local CheckConfig = self._CheckConfig
  if not CheckConfig then
    return
  end
  self._CurTick  self.TickCheckFocusTimer = self:AddGameTimer(Interval, true, function()
    self:TickRefreshUI(CheckConfig)
  end)
end
function ClientHPBarSubSystem:_OnFocusActive()
  self._IdleEmptyCount = 0
  if self._CurTickInterval ~= CHECK_FOCUS_ACTOR_INTERVAL then
    self:_StartTickRefreshTimer(CHECK_FOCUS_ACTOR_INTERVAL)
  end
end
function ClientHPBarSubSystem:_OnFocusIdle()
  self._IdleEmptyCount = (self._IdleEmptyCount or 0) + 1
  if self._IdleEmptyCount >= IDLE_THRESHOLD and self._CurTickInterval ~= CHECK_FOCUS_ACTOR_IDLE_INTERVAL then
    self:_StartTickRefreshTimer(CHECK_FOCUS_ACTOR_IDLE_INTERVAL)
  end
end
function ClientHPBarSubSystem:TickRefreshUI(CheckConfig)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local playerController = GameplayData.GetPlayerController()
  if not Game:IsValid(playerController) then
    return
  end
  if not CheckConfig.bTickOnSpectator and playerController.IsSpectator and playerController:IsSpectator() then
    return
  end
  local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
  if slua.isValid(UIBPFunctionLibrary) and slua.isValid(playerController) then
    local FocusActorArray = UIBPFunctionLibrary.GetFocusActor(playerController, self.FocusActorCheckParam)
    local FocusActorNum = FocusActorArray:Num()
    if CheckConfig.CheckActorNum and CheckConfig.CheckActorNum > 1 then
      for PlayerKey, bNeedShowUI in pairs(self.CurFocusActorArray) do
        self.CurFocusActorArray[PlayerKey] = false
      end
      for _, Pawn in pairs(FocusActorArray) do
        if Game:IsValid(Pawn) and Pawn.PlayerKey then
          if nil == self.CurFocusActorArray[Pawn.PlayerKey] then
            EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_ADD_HPBAR, Pawn)
          end
          self.CurFocusActorArray[Pawn.PlayerKey] = true
        end
      end
      local PlayerKeyToRemove = {}
      for PlayerKey, bNeedShowUI in pairs(self.CurFocusActorArray) do
        if false == bNeedShowUI then
          EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_REMOVE_HPBAR, PlayerKey)
          table.insert(PlayerKeyToRemove, PlayerKey)
        end
      end
      for _, PlayerKey in ipairs(PlayerKeyToRemove) do
        self.CurFocusActorArray[PlayerKey] = nil
      end
    elseif 0 < FocusActorNum then
      local FocusActor = FocusActorArray:Get(0)
      if self.CurFocusActor ~= FocusActor then
        if slua.isValid(self.CurFocusActor) then
          print(bWriteLog and "ClientHPBarSubSystem FocusActorss REMOVE", self.CurFocusActor)
          EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_REMOVE_HPBAR)
          self.CurFocusActor = nil
        end
        if slua.isValid(FocusActor) then
          print(bWriteLog and "ClientHPBarSubSystem FocusActorss ADD", FocusActor, FocusActor.ResId, FocusActor.GetHPBarType and FocusActor:GetHPBarType())
          EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_ADD_HPBAR, FocusActor)
          self.Cur        end
      end
    elseif slua.isValid(self.CurFocusActor) then
      print(bWriteLog and "ClientHPBarSubSystem FocusActorss REMOVE", self.CurFocusActor)
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_REMOVE_HPBAR)
      self.CurFocusActor = nil
    end
    if 0 < FocusActorNum then
      self:_OnFocusActive()
    else
      self:_OnFocusIdle()
    end
  end
end
function ClientHPBarSubSystem:OnEnterWonderfulPlayback()
  print(bWriteLog and "ClientHPBarSubSystem:OnEnterWonderfulPlayback")
  self.bHasEnteredWonderfulPlayback = true
  if self.TickCheckFocusTimer then
    self:RemoveGameTimer(self.TickCheckFocusTimer)
    self.TickCheckFocusTimer = nil
  end
  for PlayerKey, Data in pairs(self.CharacterHPDataMap) do
    if PlayerKey and Data then
      local MarkAction = Data.uMarkAction
      self:RemoveGameTimer(Data.TimeDelegate)
      if MarkAction then
        InGameMarkTools.HideMapMark(MarkAction)
      end
    end
  end
  self.TargetPlayerKey = nil
end
function ClientHPBarSubSystem:CheckShouldShowHPBar(FocusActor)
  return self:GetActorHPBarType(FocusActor) == 2
end
function ClientHPBarSubSystem:GetActorHPBarType(FocusActor)
  if not slua.isValid(FocusActor) then
    return
  end
  if FocusActor.GetHPBarType then
    local HPBarType = FocusActor:GetHPBarType()
    return HPBarType
  end
end
function ClientHPBarSubSystem:GetActorHPBarUIConfig(FocusActor)
  if not slua.isValid(FocusActor) then
    return
  end
  if FocusActor.GetHPBarUIConfig then
    local HPBarUIConfig = FocusActor:GetHPBarUIConfig()
    return HPBarUIConfig
  end
end
function ClientHPBarSubSystem:OnAddHPBar(_, _, actor)
  if not slua.isValid(actor) or self.TargetPlayerKey == actor or self.bHasEnteredWonderfulPlayback then
    return
  end
  local HPBarType = self:GetActorHPBarType(actor)
  print(bWriteLog and "ClientHPBarSubSystem:OnAddHPBar", actor, HPBarType)
  if HPBarType == 1 then
    local UIConfigName = self:GetActorHPBarUIConfig(actor)
    if UIConfigName == nil or UIConfigName == "" or UIManager.UI_Config_InGame[UIConfigName] == nil then
      UIConfigName = "IngameHPUIBase"
    end
    local HPUI = UIManager.GetUI(UIManager.UI_Config_InGame[UIConfigName])
    HPUI = HPUI or UIManager.ShowUI(UIManager.UI_Config_InGame[UIConfigName])
    if HPUI then
      HPUI:OnShowHP(actor)
    end
    return
  end
  if not self:CheckShouldShowHPBar(actor) then
    return
  end
  if actor.PlayerKey and actor.PlayerKey > 0 then
    self.TargetPlayerKey = actor.PlayerKey
  else
    self.TargetPlayerKey = tostring(actor)
  end
  print(bWriteLog and "ClientHPBarSubSystem:OnAddHPBar", actor.ResId, self.TargetPlayerKey, self.CharacterHPDataMap[self.TargetPlayerKey] == nil)
  if self.CharacterHPDataMap[self.TargetPlayerKey] == nil then
    self.CharacterHPDataMap[self.TargetPlayerKey] = {}
    local TypeID = self:GetHPBarTypeIDByActor(actor)
    local TargetMarkAction = InGameMarkTools.ClientAddMapMark(TypeID, self.VectorZero, 0, "", 4, actor)
    self.CharacterHPDataMap[self.TargetPlayerKey].uMarkAction = TargetMarkAction
  else
    local delegate = self.CharacterHPDataMap[self.TargetPlayerKey].TimeDelegate
    print(bWriteLog and "ClientHPBarSubSystem:remove delay", self.TargetPlayerKey, delegate)
    if delegate then
      self:RemoveGameTimer(delegate)
    end
  end
end
function ClientHPBarSubSystem:OnRemoveHPBar(_, _, TargetPlayerKey)
  TargetPlayerKey = TargetPlayerKey or self.TargetPlayerKey
  print(bWriteLog and "ClientHPBarSubSystem:OnRemoveHPBar", self.TargetPlayerKey)
  if self.bHasEnteredWonderfulPlayback then
    return
  end
  if TargetPlayerKey and self.CharacterHPDataMap[TargetPlayerKey] then
    local MarkAction = self.CharacterHPDataMap[TargetPlayerKey].uMarkAction
    local PlayerKey = TargetPlayerKey
    if self.CharacterHPDataMap[TargetPlayerKey].TimeDelegate then
      self:RemoveGameTimer(self.CharacterHPDataMap[PlayerKey].TimeDelegate)
    end
    local delegate = self:AddGameTimer(self.LookHpBarStayTime, false, function()
      InGameMarkTools.HideMapMark(MarkAction)
      self.CharacterHPDataMap[PlayerKey] = nil
    end)
    self.CharacterHPDataMap[TargetPlayerKey].TimeDelegate = delegate
  end
  self.TargetPlayerKey = nil
end
function ClientHPBarSubSystem:OnRelease()
  print(bWriteLog and "ClientHPBarSubSystem:OnRelease")
  self.BossHPBarUI = nil
  self.CharacterHPDataMap = nil
  self.CurFocusActor = nil
  ClientHPBarSubSystem.__super.OnRelease(self)
end
function ClientHPBarSubSystem:HandleTakeDamage(damage, DamageEvent, Causer, Victim)
  print(bWriteLog and "ClientHPBarSubSystem:HandleTakeDamage", Victim)
  if not (slua.isValid(Causer) and slua.isValid(Victim)) or not self:CheckShouldShowHPBar(Victim) then
    return
  end
  local VictimPlayerKey = Victim.PlayerKey
  if VictimPlayerKey == nil or VictimPlayerKey == 0 then
    VictimPlayerKey = tostring(Victim)
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPawn = uPlayerController:GetPlayerCharacterSafety()
    print(bWriteLog and "ClientHPBarSubSystem:HandleTakeDamage", VictimPlayerKey, self.TargetPlayerKey, uPawn == Causer)
    if slua.isValid(uPawn) and uPawn == Causer and self.TargetPlayerKey ~= VictimPlayerKey then
      if self.CharacterHPDataMap[VictimPlayerKey] == nil then
        self.CharacterHPDataMap[VictimPlayerKey] = {}
        self.CharacterHPDataMap[VictimPlayerKey].BeforeDamageHP = damage + Victim.Health
        local TypeID = self:GetHPBarTypeIDByActor(Victim)
        self.CharacterHPDataMap[VictimPlayerKey].uMarkAction = InGameMarkTools.ClientAddMapMark(TypeID, self.VectorZero, 0, "", 4, Victim)
        print(bWriteLog and "ClientHPBarSubSystem:HandleTakeDamage22", self.CharacterHPDataMap[VictimPlayerKey].uMarkAction)
        self.CharacterHPDataMap[VictimPlayerKey].TimeDelegate = self:AddGameTimer(self.HitHpBarStayTime, false, function()
          if VictimPlayerKey and self.CharacterHPDataMap[VictimPlayerKey] then
            InGameMarkTools.HideMapMark(self.CharacterHPDataMap[VictimPlayerKey].uMarkAction)
            self.CharacterHPDataMap[VictimPlayerKey] = nil
          end
        end)
      else
        if self.CharacterHPDataMap[VictimPlayerKey].TimeDelegate then
          self:RemoveGameTimer(self.CharacterHPDataMap[VictimPlayerKey].TimeDelegate)
        end
        self.CharacterHPDataMap[VictimPlayerKey].TimeDelegate = self:AddGameTimer(self.HitHpBarStayTime, false, function()
          if VictimPlayerKey and self.CharacterHPDataMap[VictimPlayerKey] then
            InGameMarkTools.HideMapMark(self.CharacterHPDataMap[VictimPlayerKey].uMarkAction)
            self.CharacterHPDataMap[VictimPlayerKey] = nil
          end
        end)
      end
    end
  end
end
function ClientHPBarSubSystem:SetFocusActorCheckParam(sProperty, Value)
  if sProperty == nil or Value == nil then
    return
  end
  if self.FocusActorCheckParam[sProperty] == nil then
    return
  end
  self.FocusActorCheckParam[sProperty] = Value
  print(bWriteLog and string.format("ClientHPBarSubSystem: SetFocusActorCheckParam, sProperty = [%s], Value = [%s]", sProperty, tostring(Value)))
  if sProperty == "CheckObjectTypes" and type(Value) == "table" then
    for _, type in ipairs(Value) do
      slua.IndexReference(self.FocusActorCheckParam, "CheckObjectTypes"):Add(type)
    end
  end
  if sProperty == "ValidActorClass" and type(Value) == "table" then
    for _, ClassName in ipairs(Value) do
      local ValidActorClass = import(ClassName)
      slua.IndexReference(self.FocusActorCheckParam, "ValidActorClass"):Add(ValidActorClass)
    end
  end
end
function ClientHPBarSubSystem:GetHPBarTypeIDByActor(Actor)
  if slua.isValid(Actor) and Actor.GetHPBarScreenMarkID then
    local HPBarScreenMarkID = Actor:GetHPBarScreenMarkID()
    return 0 < HPBarScreenMarkID and HPBarScreenMarkID or 1006
  end
  return 1006
end
function ClientHPBarSubSystem:IsPlayingReplay()
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    print(bWriteLog and "ClientHPBarSubSystem:IsPlayingReplay uWonderfulPlayback", uWonderfulPlayback)
    if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
      print(bWriteLog and "ClientHPBarSubSystem:IsPlayingReplay playing WonderfulPlayback")
      return true
    end
    local uDeathPlayback = uGameInstance:GetDeathPlayback()
    if slua.isValid(uDeathPlayback) and uDeathPlayback:IsInPlayState() then
      print(bWriteLog and "ClientHPBarSubSystem:IsPlayingReplay playing DeathPlayback")
      return true
    end
  end
  return false
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientHPBarSubSystem)
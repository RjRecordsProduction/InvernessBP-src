local InteractiveActorTemplate = {}
function InteractiveActorTemplate:ctor()
  self.PlayersHaveScannedMeInMap = {}
  self.PlayersHaveScannedMeInSign = {}
  self.TotalCount = 1
end
function InteractiveActorTemplate:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "TotalCount",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function InteractiveActorTemplate:ReceiveBeginPlay()
  InteractiveActorTemplate.__super.ReceiveBeginPlay(self)
  self:InteractiveActorBeginPlayImpl()
end
function InteractiveActorTemplate:_PostConstruct()
  InteractiveActorTemplate.__super._PostConstruct(self)
end
function InteractiveActorTemplate:OnBPRespawned()
  InteractiveActorTemplate.__super.OnBPRespawned(self)
  self:InteractiveActorBeginPlayImpl()
end
function InteractiveActorTemplate:InteractiveActorBeginPlayImpl()
  if self.hasAuthority then
    if self.LifeSpan and self.LifeSpan > 0 then
      self:SetLifeSpan(0)
      self:SetLifeSpan(self.LifeSpan)
    end
    if self.EnableScan then
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SCAN_HIDE_MARK, self.HideMarkForOneActorAndCharacter, self)
    end
  end
end
function InteractiveActorTemplate:OnAllowToInteract(Character)
  local Result = true
  if self.EnableCount then
    Result = Result and self.TotalCount > 0
  end
  return Result
end
function InteractiveActorTemplate:OnClientShowInteractiveUI(Show, Component)
  print(bWriteLog and "InteractiveActorTemplate:OnClientShowInteractiveUI")
  Component = Component or self:GetInteractiveComponent()
  if self.NeedClick then
    InteractiveActorTemplate.__super.OnClientShowInteractiveUI(self, Show, Component)
  elseif Show then
    local GameplayStatics = import("GameplayStatics")
    local Character = GameplayStatics.GetPlayerCharacter(self.Object, 0)
    if Character then
      Character:ServerRPCOnClickInteractiveButton(Component, 0)
    end
  end
end
function InteractiveActorTemplate:MustCheckResultAfterServerClick(Character, Result, uComponent)
  print(bWriteLog and "InteractiveActorTemplate:MustCheckResultAfterServerClick", Character)
  print(bWriteLog and "InteractiveActorTemplate:MustCheckResultAfterServerClick, Result = " .. tostring(Result))
  uComponent = uComponent or self:GetInteractiveComponent()
  if Result then
    if uComponent and slua.isValid(uComponent) then
      local nSkillId = uComponent.SkillId
      if nSkillId and nSkillId ~= 0 then
        InteractiveActorTemplate.__super.MustCheckResultAfterServerClick(self, Character, Result, uComponent)
      else
        self:MustCheckResultAfterSkillFinished(Character, Result, uComponent)
      end
    end
  else
    InteractiveActorTemplate.__super.MustCheckResultAfterServerClick(self, Character, Result, uComponent)
  end
end
function InteractiveActorTemplate:OnStartedSkillAction(Character)
end
function InteractiveActorTemplate:OnStoppedSkillAction(Character, Reason, SkillId, Component)
end
function InteractiveActorTemplate:MustCheckResultAfterSkillFinished(Character, Result, Component)
  Component = Component or self:GetInteractiveComponent()
  InteractiveActorTemplate.__super.MustCheckResultAfterSkillFinished(self, Character, Result, Component)
  print(bWriteLog and "InteractiveActorTemplate:MustCheckResultAfterSkillFinished, self.hasAuthority = " .. tostring(self.hasAuthority))
  if Result == false then
    return
  end
  if self.hasAuthority then
    if self.EnableCount then
      self:SubtractOneCount(Character)
    end
    if self.EnableBuff then
      self:AddBuffToCharacter(Character)
    end
    if self.EnableScan then
      self:ScanActors(Character)
      if self.NeedScanCharacter then
        self:ScanCharacters(Character)
      end
    end
  else
    self:CloseUI(Component)
  end
end
function InteractiveActorTemplate:OnServerAddOrDeleteComponent(Character, bAddOrDelete, Component)
  if self.EnableBuff and bAddOrDelete == false and self.NeedRemoveAfterExit == true then
    Character:RemoveBuffBySkill(self.BuffID, 1, nil)
  end
end
function InteractiveActorTemplate:SubtractOneCount(Character)
  self.TotalCount = self.TotalCount - 1
end
function InteractiveActorTemplate:AddBuffToCharacter(Character)
  if Character then
    Character:AddBuffBySkill(self.BuffID, 1, nil, 1)
    if self.NeedDestroy then
      self:K2_DestroyActor()
    end
  else
    print(bWriteLog and "InteractiveActorTemplate:AddBuffToCharacter, Character = nil")
  end
end
function InteractiveActorTemplate:ScanCharacters(Character)
  local ScannedCharacters = Game:QueryCharacters(Game:GetActorLocation(self), self.ScanDistance)
  if ScannedCharacters and slua.isValid(ScannedCharacters) then
    local Num = ScannedCharacters:Num()
    print(bWriteLog and "InteractiveActorTemplate:ScanCharacters, ScanDistance = " .. tostring(self.ScanDistance) .. ", ScanMaxNum = " .. tostring(self.ScanMaxNum) .. ", ScannedCharacters num = " .. tostring(Num))
    for i = 0, Num - 1 do
      local OneActor = ScannedCharacters:Get(i)
      if OneActor and slua.isValid(OneActor) and OneActor.TeamID ~= Character.TeamID then
        local Index = self:GetMarkIndex(OneActor)
        if self.ShowMarkOnMap then
          self:ShowMark(Character, OneActor, Index)
        end
        if self.ShowQuickSignInLevel then
          self:ShowQuickSign(Character, OneActor, Index)
        end
      end
    end
  else
    print(bWriteLog and "InteractiveActorTemplate:ScanCharacters, ScanDistance = " .. tostring(self.ScanDistance) .. ", ScanMaxNum = " .. tostring(self.ScanMaxNum) .. ", ScannedCharacters = " .. tostring(ScannedCharacters))
  end
end
function InteractiveActorTemplate:ScanActors(Character)
  local MarkNum = self.ScannedMarkInfo:Num()
  if self.ScannedActorTag and self.ScannedActorTag ~= "" and 0 < MarkNum then
    local SubClassActors = Game:QueryCanBeScannedActors(Game:GetActorLocation(self), self.ScanDistance, self.ScannedActorTag, MarkNum, self.ScanMaxNum)
    if SubClassActors and slua.isValid(SubClassActors) then
      local Num = SubClassActors:Num()
      print(bWriteLog and "InteractiveActorTemplate:ScanActors, ScannedActorTag = " .. tostring(self.ScannedActorTag) .. ", ScanDistance = " .. tostring(self.ScanDistance) .. ", ScanMaxNum = " .. tostring(self.ScanMaxNum) .. ", SubClassActors num = " .. tostring(Num))
      for i = 0, Num - 1 do
        local OneActor = SubClassActors:Get(i)
        if OneActor and slua.isValid(OneActor) then
          local Index = self:GetMarkIndex(OneActor)
          if Index then
            if self.ShowMarkOnMap then
              self:ShowMark(Character, OneActor, Index)
            end
            if self.ShowQuickSignInLevel then
              self:ShowQuickSign(Character, OneActor, Index)
            end
          end
        end
      end
    else
      print(bWriteLog and "InteractiveActorTemplate:ScanActors, ScannedActorTag = " .. tostring(self.ScannedActorTag) .. ", ScanDistance = " .. tostring(self.ScanDistance) .. ", ScanMaxNum = " .. tostring(self.ScanMaxNum) .. ", SubClassActors = " .. tostring(SubClassActors))
    end
  else
    print(bWriteLog and "InteractiveActorTemplate:ScanActors, ScannedActorTag = " .. tostring(self.ScannedActorTag) .. ", MarkNum = " .. tostring(MarkNum))
  end
end
function InteractiveActorTemplate:OnRep_TotalCount()
  print(bWriteLog and "InteractiveActorTemplate:OnRep_TotalCount, TotalCount = " .. tostring(self.TotalCount))
end
function InteractiveActorTemplate:GetMarkIndex(Actor)
  local MarkNum = self.ScannedMarkInfo:Num()
  for k = 0, MarkNum - 1 do
    local Tag = self.ScannedActorTag .. tostring(k)
    if Actor:ActorHasTag(Tag) then
      return k
    end
  end
  local ActorClass = slua.loadClass(self.ScannedMarkInfo:Get(MarkNum - 1).QuickSignClass)
  if Game:IsClassOf(Actor, ActorClass) then
    return MarkNum - 1
  end
  print(bWriteLog and "InteractiveActorTemplate:GetMarkIndex, return default 0")
  return 0
end
function InteractiveActorTemplate:ShowMark(Character, Actor, Index)
  local ScannedMarkInfo = self.ScannedMarkInfo:Get(Index)
  if ScannedMarkInfo.MapMarkID and ScannedMarkInfo.MapMarkID > 0 then
    if Character then
      local ActorUniqueID = Game:GetActorUniqueID(Actor)
      local PlayerKey = Character.PlayerKey
      local Callback = function()
        if self.PlayersHaveScannedMeInMap[ActorUniqueID] and self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey] then
          if self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Data then
            local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
            InGameMarkTools.HideMapMark(self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Data)
          end
          self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer = nil
        end
      end
      if self.PlayersHaveScannedMeInMap[ActorUniqueID] == nil then
        self.PlayersHaveScannedMeInMap[ActorUniqueID] = {}
      end
      local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
      if self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey] == nil then
        local VisibleType = UEnums.EMarkDispatchRange.EMAMDT_OWNER_ONLY
        if ScannedMarkInfo.VisibleType == 1 then
          VisibleType = UEnums.EMarkDispatchRange.EMAMDT_OWNER_ONLY
        elseif ScannedMarkInfo.VisibleType == 2 then
          VisibleType = UEnums.EMarkDispatchRange.EMAMDT_TEAMMATE
        end
        local MarkDispatchAction = InGameMarkTools.ServerAddMapMark(ScannedMarkInfo.MapMarkID, Actor:K2_GetActorLocation(), 0, 3, 0, VisibleType, Character:GetPlayerStateSafety())
        self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey] = {}
        self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Data = MarkDispatchAction
        self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer = self:AddGameTimer(ScannedMarkInfo.Duration, false, Callback)
      else
        if self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer then
          self:RemoveGameTimer(self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer)
          self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer = nil
        end
        InGameMarkTools.ShowMapMark(self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Data)
        self.PlayersHaveScannedMeInMap[ActorUniqueID][PlayerKey].Timer = self:AddGameTimer(ScannedMarkInfo.Duration, false, Callback)
      end
      print(bWriteLog and "InteractiveActorTemplate:ShowMark, VisibleType = " .. tostring(ScannedMarkInfo.VisibleType) .. ", IsLuaConfig = " .. tostring(ScannedMarkInfo.IsLuaConfig))
    end
  else
    print(bWriteLog and "InteractiveActorTemplate:ShowMark, MapMarkID = " .. tostring(ScannedMarkInfo.MapMarkID))
  end
end
function InteractiveActorTemplate:HideMark(Character, Actor)
  if self:IsValid(Actor) == false then
    print(bWriteLog and "InteractiveActorTemplate:HideMark, IsValid(Actor) == false")
    return
  end
  local ActorUniqueID = Game:GetActorUniqueID(Actor)
  if Character then
    if self.PlayersHaveScannedMeInMap[ActorUniqueID] and self.PlayersHaveScannedMeInMap[ActorUniqueID][Character.PlayerKey] then
      local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
      InGameMarkTools.HideMapMark(self.PlayersHaveScannedMeInMap[ActorUniqueID][Character.PlayerKey].Data)
      if self.PlayersHaveScannedMeInMap[ActorUniqueID][Character.PlayerKey].Timer then
        self:RemoveGameTimer(self.PlayersHaveScannedMeInMap[ActorUniqueID][Character.PlayerKey].Timer)
        self.PlayersHaveScannedMeInMap[ActorUniqueID][Character.PlayerKey].Timer = nil
      end
    end
  else
    self:HideMarkForOneActor(self.PlayersHaveScannedMeInMap[ActorUniqueID])
  end
end
function InteractiveActorTemplate:HideMarkForOneActor(TempTable)
  local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
  for _, v in pairs(TempTable) do
    InGameMarkTools.HideMapMark(v.Data)
    if v.Timer then
      self:RemoveGameTimer(v.Timer)
      v.Timer = nil
    end
  end
  TempTable = {}
end
function InteractiveActorTemplate:HideMarkForOneActorAndCharacter(_, _, Character, Actor)
  if self.hasAuthority then
    if Character and slua.isValid(Character) and Actor and slua.isValid(Actor) then
      self:HideMark(Character, Actor)
      self:HideQuickSign(Character, Actor)
    else
      print(bWriteLog and "InteractiveActorTemplate:HideMarkForOneActorAndCharacter, parameter is invalid")
    end
  else
    print(bWriteLog and "InteractiveActorTemplate:HideMarkForOneActorAndCharacter, self.hasAuthority == false")
  end
end
function InteractiveActorTemplate:ShowQuickSign(Character, Actor, Index)
  local ScannedMarkInfo = self.ScannedMarkInfo:Get(Index)
  if Character then
    local SafetyController = Character:GetPlayerControllerSafety()
    if SafetyController == nil or slua.isValid(SafetyController) == false then
      return
    end
    local ActorUniqueID = Game:GetActorUniqueID(Actor)
    local QuickSignComp = SafetyController:GetQuickSignComponent()
    if QuickSignComp and slua.isValid(QuickSignComp) then
      do
        local PlayerKey = Character.PlayerKey
        local Callback = function()
          if self.PlayersHaveScannedMeInSign[ActorUniqueID] and self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey] then
            if self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data then
              local Controller = Game:GetPlayerControllerByPlayerKey(PlayerKey)
              if Controller and slua.isValid(Controller) then
                local Component = Controller:GetQuickSignComponent()
                if Component and slua.isValid(Component) then
                  Component:ServerDelCustomMark(self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data.MsgID, self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].VisibleType)
                end
              end
            end
            self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer = nil
          end
        end
        if self.PlayersHaveScannedMeInSign[ActorUniqueID] == nil then
          self.PlayersHaveScannedMeInSign[ActorUniqueID] = {}
        end
        if self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey] == nil then
          local ActorTag = tostring(self.ScannedActorTag .. tostring(Index))
          local tQuickSignMsg = {}
          local AScannedActorTest = slua.loadClass(ScannedMarkInfo.QuickSignClass)
          tQuickSignMsg.ConfigKey = QuickSignComp:FindMarkNameClassKey(AScannedActorTest)
          tQuickSignMsg.BindActorGUID = slua.GetNetGUID(Actor)
          tQuickSignMsg.MsgID = string.format("%s_%s_%d_%d_%d", tQuickSignMsg.ConfigKey, ActorTag, tQuickSignMsg.BindActorGUID, Game:GetActorUniqueID(Actor), SafetyController.PlayerKey)
          tQuickSignMsg.PlayerName = SafetyController.PlayerName
          tQuickSignMsg.Playerkey = SafetyController.PlayerKey
          tQuickSignMsg.HitPos = Actor:K2_GetActorLocation()
          tQuickSignMsg.ParamString = ActorTag
          local VisibleType = false
          if ScannedMarkInfo.VisibleType == 1 then
            VisibleType = false
          elseif ScannedMarkInfo.VisibleType == 2 then
            VisibleType = true
          end
          self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey] = {}
          self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data = tQuickSignMsg
          self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].          self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer = self:AddGameTimer(ScannedMarkInfo.Duration, false, Callback)
        else
          if self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer then
            self:RemoveGameTimer(self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer)
            self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer = nil
          end
          self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer = self:AddGameTimer(ScannedMarkInfo.Duration, false, Callback)
        end
        QuickSignComp:ServerMarkCustom(self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data, ScannedMarkInfo.QuickSignShareDistance, self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].VisibleType)
        log_tree("InteractiveActorTemplate:ShowQuickSign, tQuickSignMsg = ", self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data)
      end
    end
  end
end
function InteractiveActorTemplate:HideQuickSign(Character, Actor)
  if self:IsValid(Actor) == false then
    print(bWriteLog and "InteractiveActorTemplate:HideQuickSign, IsValid(Actor) == false")
    return
  end
  local ActorUniqueID = Game:GetActorUniqueID(Actor)
  if Character then
    local PlayerKey = Character.PlayerKey
    if self.PlayersHaveScannedMeInSign[ActorUniqueID] and self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey] then
      local SafetyController = Character:GetPlayerControllerSafety()
      if SafetyController and slua.isValid(SafetyController) then
        local QuickSignComp = SafetyController:GetQuickSignComponent()
        if QuickSignComp and slua.isValid(QuickSignComp) then
          QuickSignComp:ServerDelCustomMark(self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Data.MsgID, self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].VisibleType)
        end
      end
      if self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer then
        self:RemoveGameTimer(self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer)
        self.PlayersHaveScannedMeInSign[ActorUniqueID][PlayerKey].Timer = nil
      end
    end
  else
    self:HideQuickSignForOneActor(self.PlayersHaveScannedMeInSign[ActorUniqueID])
  end
end
function InteractiveActorTemplate:HideQuickSignForOneActor(TempTable)
  for k, v in pairs(TempTable) do
    local SafetyController = Game:GetPlayerControllerByPlayerKey(k)
    if SafetyController and slua.isValid(SafetyController) then
      local QuickSignComp = SafetyController:GetQuickSignComponent()
      if QuickSignComp and slua.isValid(QuickSignComp) then
        QuickSignComp:ServerDelCustomMark(v.Data.MsgID, v.VisibleType)
      end
    end
    if v.Timer then
      self:RemoveGameTimer(v.Timer)
      v.Timer = nil
    end
  end
  TempTable = {}
end
function InteractiveActorTemplate:OnBPRecycled()
  self:InteractiveActorEndPlayImpl()
  InteractiveActorTemplate.__super.OnBPRecycled(self)
end
function InteractiveActorTemplate:ReceiveEndPlay(EndPlayReason)
  self:InteractiveActorEndPlayImpl()
  InteractiveActorTemplate.__super.ReceiveEndPlay(self, EndPlayReason)
end
function InteractiveActorTemplate:InteractiveActorEndPlayImpl()
  self:Dispose()
  if self.hasAuthority then
    for _, v in pairs(self.PlayersHaveScannedMeInMap) do
      self:HideMarkForOneActor(v)
    end
    for _, v in pairs(self.PlayersHaveScannedMeInSign) do
      self:HideQuickSignForOneActor(v)
    end
  end
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local InteractiveActorTemplateClass = Class(CInteractiveActorBase, nil, InteractiveActorTemplate)
return InteractiveActorTemplateClass
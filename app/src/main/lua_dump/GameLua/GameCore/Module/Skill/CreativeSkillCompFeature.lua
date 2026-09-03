local CreativeSkillCompFeature = {}
local DebugConsoleSendCD = 5
function CreativeSkillCompFeature:ctor()
  self.TargetActorLocation = FVector.ZeroVector
end
function CreativeSkillCompFeature:_PostConstruct()
end
function CreativeSkillCompFeature:ReceiveBeginPlay()
  print(bWriteLog and "CreativeSkillCompFeature:ReceiveBeginPlay")
  if Game:IsValid(self.Owner) and self.Owner:GetOwner():HasAuthority() and CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    self.Owner:AddControlEvent(self.Owner, "CreativeSkillDelegate", self.OnCreativeSkillEvent, self)
    self.CDTimerHandle = self:AddTimerLoop(0, function()
      self:UpdateCD()
    end, TIMER_INFINITE, 0.5)
    self.CreativeCustomSkillArray = {}
    self.CreativeSkillCanCast = {}
    self.DebugConsoleSendTime = 0
  end
end
function CreativeSkillCompFeature:ReceiveEndPlay()
  print(bWriteLog and "CreativeSkillCompFeature:ReceiveEndPlay")
  if Game:IsValid(self.Owner) and self.Owner:GetOwner():HasAuthority() then
    if self._UGCLuaCodeLoadHandle then
      for SkillID, _Handle in pairs(self._UGCLuaCodeLoadHandle) do
        self:UnLoadUGCLuaCode(SkillID)
      end
    end
    self.CreativeCustomSkillArray = {}
    self.CreativeSkillCanCast = {}
    if self.CDTimerHandle then
      self:RemoveTimer(self.CDTimerHandle)
      self.CDTimerHandle = nil
    end
  end
end
function CreativeSkillCompFeature:OnCreativeSkillEvent(Actor, Skill, EventName, ExtraData)
  if not Game:IsValid(self.Owner) then
    return
  end
  if not Game:IsValid(Skill) then
    return
  end
  local PhaseIndex = self.Owner:GetSkillCurPhase(Skill)
  printf(bWriteLog and "CreativeSkillCompFeature:OnCreativeSkillEvent PlayerKey = %s, Skill = %s, EventName = %s,PhaseIndex = %s", tostring(Actor.PlayerKey), tostring(Skill), tostring(EventName), tostring(PhaseIndex))
  self._UGCLuaCodeLoadHandle = self._UGCLuaCodeLoadHandle or {}
  self.WaitingPostQueue = self.WaitingPostQueue or {}
  self.bUGCLuaCodeLoaded = self.bUGCLuaCodeLoaded or {}
  if EventName == "ActiveSkill" then
    if self.Owner.OnActiveSkill then
      self.Owner:OnActiveSkill(Actor, Skill)
    end
    self:LoadUGCLuaCode(Skill)
  elseif EventName == "CloseSkill" then
    self.CDList = self.CDList or {}
    self.CDList[Skill] = nil
    if self.Owner.OnCloseSkill then
      self.Owner:OnCloseSkill(Actor, Skill)
    end
    self:UnLoadUGCLuaCode(Skill.SkillID)
  elseif EventName == "SkillInterrupted" then
    if PhaseIndex == 4 or PhaseIndex == 6 then
    end
  elseif EventName == "SkillFinished" then
  elseif EventName == "ConsumCD" then
    local bCDOK = Skill:IsCDOK(self.Owner, -1)
    if not bCDOK then
      self.CDList = self.CDList or {}
      self.CDList[Skill] = true
    else
      return
    end
  elseif EventName == "SkillInCD" then
    self:BroadcastSkillDebugConsoleMsg(18710058, Skill)
  end
  EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_CUSTOM_SKILL_COMMON, Actor, Skill, EventName, PhaseIndex)
end
function CreativeSkillCompFeature:BroadcastSkillDebugConsoleMsg(TextID, OwnerSkill, Param1, Param2)
  local CreativeDebugConsoleSubsystem = SubsystemMgr:Get("CreativeDebugConsoleSubsystem")
  if CreativeDebugConsoleSubsystem then
    local CurTime = CGameState:GetServerWorldTimeSeconds()
    if CurTime - self.DebugConsoleSendTime > DebugConsoleSendCD then
      local CreativeCustomSkillSubsystem = SubsystemMgr:Get("CreativeCustomSkillSubsystem")
      if CreativeCustomSkillSubsystem then
        local PlayerName = ""
        local Character = self.Owner:GetOwner()
        if slua.isValid(Character) then
          if Character.GetMonsterName then
            PlayerName = Character:GetMonsterName()
          elseif Character.GetPlayerNameSafety then
            PlayerName = Character:GetPlayerNameSafety()
          end
        end
        local PlayerNameID = tonumber(PlayerName)
        if PlayerNameID and 0 < PlayerNameID then
          PlayerName = {ID = PlayerNameID, SubLocParams = nil}
        end
        local SkillName = OwnerSkill.SkillName
        local PlayerSkillID = CreativeCustomSkillSubsystem:GetPlayerCustomSkillIDByAISkillID(OwnerSkill.SkillID)
        if PlayerSkillID == nil then
          return
        end
        local SkillData = CreativeCustomSkillSubsystem:GetOneSkillData(PlayerSkillID)
        if SkillData then
          if SkillData.SkillName and SkillData.SkillName ~= "" then
            SkillName = SkillData.SkillName
          else
            local CreativeCustomSkill_Util = require("GameLua.Mod.CreativeBase.Gameplay.CustomSkill.CreativeCustomSkill_Util")
            local SkillNameID = CreativeCustomSkill_Util.GetTemplateNameLocalizeIDOrName(PlayerSkillID, SkillData.TemplateId)
            if type(SkillNameID) == "number" then
              SkillName = {ID = SkillNameID}
            elseif SkillNameID ~= "" then
              SkillName = SkillNameID
            end
          end
        end
        CreativeDebugConsoleSubsystem:BroadcastMsg(TextID, PlayerName, SkillName, Param1, Param2)
        self.DebugConsoleSendTime = CurTime
      end
    end
  end
end
function CreativeSkillCompFeature:UpdateCD()
  if not self.CDList then
    return
  end
  if not Game:IsValid(self.Owner) then
    return
  end
  local NeedRemoved = {}
  for Skill, _ in pairs(self.CDList) do
    if Game:IsValid(Skill) then
      local bCDOK = Skill:IsCDOK(self.Owner, -1)
      if bCDOK then
        local Owner = self.Owner:GetOwner()
        if Game:IsValid(Owner) then
          self:OnCreativeSkillEvent(Owner, Skill, "ExitCD", nil)
        end
        NeedRemoved[#NeedRemoved + 1] = Skill
      end
    end
  end
  for i, Skill in ipairs(NeedRemoved) do
    self.CDList[Skill] = nil
  end
end
function CreativeSkillCompFeature:LoadUGCLuaCode(Skill)
  local Pawn = self.Owner:GetOwner()
  if not Pawn:HasAuthority() then
    return
  end
  local SkillID = Skill.SkillID
  if self._UGCLuaCodeLoadHandle[SkillID] then
    return
  end
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local CodeMgr = GetCreativeLuaCodeManager()
    if not CodeMgr then
      print(bWriteLog and "[Code Run]CreativeSkillCompFeature:LoadUGCLuaCode not  CodeMgr")
      return
    end
    local EntityManager = GetCreativeEntityManager()
    local InstanceUUID = EntityManager:GetOrAddUUIDByParams(Pawn.PlayerKey, SkillID)
    log(bWriteLog and string.format("[gordon] CreativeSkillCompFeature LoadUGCLuaCode skillId = %s self=%s", SkillID, tostring(self)))
    local CustomSkillSubsystem = SubsystemMgr:Get("CreativeCustomSkillSubsystem")
    if not CustomSkillSubsystem then
      print(bWriteLog and "[Code Run]CreativeSkillCompFeature:LoadUGCLuaCode not  CustomSkillSubsystem")
      return
    end
    local OriginSkillID = CustomSkillSubsystem:GetPlayerCustomSkillIDByAISkillID(SkillID) or SkillID
    local CodeUid = OriginSkillID
    self._UGCLuaCodeLoadHandle[SkillID] = CodeMgr:LoadUGCLuaCodeByUID(InstanceUUID, CodeUid, self.UGCLuaCodeLoadedCallback, self, self.Owner, SkillID)
    print(bWriteLog and "[Code Run]CreativeSkillCompFeature:LoadUGCLuaCode end")
  end
end
function CreativeSkillCompFeature:UnLoadUGCLuaCode(SkillID)
  local Pawn = self.Owner:GetOwner()
  if not Pawn:HasAuthority() then
    return
  end
  if not self._UGCLuaCodeLoadHandle or not self._UGCLuaCodeLoadHandle[SkillID] then
    return
  end
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local Skill = self.Owner:GetSkill(SkillID)
    if Game:IsValid(Pawn) and Game:IsValid(Skill) then
      self:OnCreativeSkillEvent(Pawn, Skill, "SkillCodePreUnload")
    end
    local CodeMgr = GetCreativeLuaCodeManager()
    if CodeMgr then
      log(bWriteLog and string.format("[gordon] CreativeSkillCompFeature UnLoadUGCLuaCode skillId = %s self=%s", SkillID, tostring(self)))
      CodeMgr:UnLoadUGCLuaCodeByHandle(self._UGCLuaCodeLoadHandle[SkillID])
    end
    self._UGCLuaCodeLoadHandle[SkillID] = nil
    self.bUGCLuaCodeLoaded[SkillID] = nil
    self.WaitingPostQueue[SkillID] = nil
  end
end
function CreativeSkillCompFeature:UGCLuaCodeLoadedCallback(uSkillManagerComp, SkillID)
  if uSkillManagerComp ~= self.Owner then
    return
  end
  print(bWriteLog and "[gordon] CreativeSkillCompFeature:UGCLuaCodeLoadedCallback skillId = %s self=%s", SkillID, tostring(self))
  self.bUGCLuaCodeLoaded[SkillID] = true
  if self.WaitingPostQueue[SkillID] ~= nil then
    local TempQueue = self.WaitingPostQueue[SkillID]
    self.WaitingPostQueue[SkillID] = nil
    for i = 1, #TempQueue do
      local Event = TempQueue[i]
      self:SkillPostEventToUGCLua(SkillID, Event.EventType, Event.EventID, table.unpack(Event.Args))
    end
  end
  local uOwnerPawn = uSkillManagerComp:GetOwner()
  local Skill = uSkillManagerComp:GetSkill(SkillID)
  if Game:IsValid(uOwnerPawn) and Game:IsValid(Skill) then
    uSkillManagerComp.CreativeSkillCompFeature:OnCreativeSkillEvent(uOwnerPawn, Skill, "SkillCodePostLoaded")
  end
end
function CreativeSkillCompFeature:SkillPostEventToUGCLua(SkillID, EventType, EventID, ...)
  if EventType == nil or EventID == nil then
    return
  end
  if self:CanPostEventToUGCLua(SkillID) then
    EventSystem:postEvent(EventType, EventID, ...)
  else
    if self.WaitingPostQueue[SkillID] == nil then
      self.WaitingPostQueue[SkillID] = {}
    end
    local PostInfo = {}
    PostInfo.    PostInfo.    PostInfo.Args = table.pack(...)
    table.insert(self.WaitingPostQueue[SkillID], PostInfo)
    print(bWriteLog and string.format("CreativeSkillCompFeature SkillPostEventToUGCLua Event Enqueue ! skillId = %s eventType = %s eventID = %s", SkillID, EventType, EventID))
  end
end
function CreativeSkillCompFeature:CanPostEventToUGCLua(SkillID)
  return self.bUGCLuaCodeLoaded and self.bUGCLuaCodeLoaded[SkillID] == true
end
function CreativeSkillCompFeature:SetCreativeMonsterCustomSkillArray(MonsterID, MonsterFullConfig)
  print(bWriteLog and "CreativeSkillCompFeature:SetCreativeMonsterCustomSkillArray", MonsterID)
  if not self.CreativeCustomSkillArray or not self.CreativeSkillCanCast then
    return
  end
  if MonsterFullConfig and MonsterFullConfig.Property then
    local CustomSkillArray = MonsterFullConfig.Property.MonsterCustomSkill
    if CustomSkillArray and next(CustomSkillArray) then
      for Index, CustomSkillInfo in ipairs(CustomSkillArray) do
        local OriginSkillID, CustomSkillID = CustomSkillInfo.OriginSkillID, CustomSkillInfo.CustomSkillID
        if OriginSkillID and 0 < OriginSkillID and CustomSkillID and 0 < CustomSkillID then
          self.CreativeCustomSkillArray[OriginSkillID] = CustomSkillID
          self.CreativeSkillCanCast[OriginSkillID] = CustomSkillInfo.bFarDistanceCast
        end
      end
    end
  end
end
function CreativeSkillCompFeature:GetCreativeOverrideCustomSkillID(SkillID)
  local Ret = -1
  local CustomSkillID
  local CreativeCustomSkillSubsystem = SubsystemMgr:Get("CreativeCustomSkillSubsystem")
  if SkillID and CreativeCustomSkillSubsystem and self.CreativeCustomSkillArray then
    CustomSkillID = self.CreativeCustomSkillArray[SkillID] or -1
    Ret = CreativeCustomSkillSubsystem:GetMonsterSkillIDByCustomID(CustomSkillID)
    print(bWriteLog and "CreativeSkillCompFeature:GetCreativeOverrideCustomSkillID", SkillID, CustomSkillID, Ret)
  end
  return Ret or -1
end
function CreativeSkillCompFeature:GetCreativeOverrideSkillIDByCustomSkillID(CustomSkillID)
  if not self.CreativeCustomSkillArray then
    return
  end
  local CreativeCustomSkillSubsystem = SubsystemMgr:Get("CreativeCustomSkillSubsystem")
  if not CreativeCustomSkillSubsystem then
    return
  end
  local OverrideSkillID
  if CustomSkillID then
    for MobSkillID, MobCustomSkillID in pairs(self.CreativeCustomSkillArray) do
      if MobCustomSkillID == CustomSkillID then
        OverrideSkillID = CreativeCustomSkillSubsystem:GetMonsterSkillIDByCustomID(CustomSkillID)
        break
      end
    end
    print(bWriteLog and "CreativeSkillCompFeature:GetCreativeOverrideSkillIDByCustomSkillID, CustomSkillID = ", CustomSkillID, "OverrideSkillID = ", OverrideSkillID)
  end
  return OverrideSkillID or -1
end
function CreativeSkillCompFeature:CanCastSkillFromFarDistance(MonsterSkillID)
  local CreativeCustomSkillSubsystem = SubsystemMgr:Get("CreativeCustomSkillSubsystem")
  if not CreativeCustomSkillSubsystem then
    return
  end
  local CustomSkillID = CreativeCustomSkillSubsystem:GetPlayerCustomSkillIDByAISkillID(MonsterSkillID)
  for MobSkillID, MobCustomSkillID in pairs(self.CreativeCustomSkillArray) do
    if MobCustomSkillID == CustomSkillID then
      return self.CreativeSkillCanCast and self.CreativeSkillCanCast[CustomSkillID]
    end
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, CreativeSkillCompFeature)
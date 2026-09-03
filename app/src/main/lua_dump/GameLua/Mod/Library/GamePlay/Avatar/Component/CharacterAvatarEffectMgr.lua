local ChracterAvatarEffectMgr = {}
local BusinessHelper = import("BusinessHelper")
local CharacterEffect_SpawnActor = import("CharacterEffect_SpawnActor")
local INVALID_ITEM_ID = 0
function ChracterAvatarEffectMgr:ctor(_, AvatarComp)
  self.PendingEffectMap = {}
  self.AppliedEffectsMap = {}
  self.ProcessorMap = {}
  if not slua.isValid(AvatarComp) then
    print(bWriteLog and "ChracterAvatarEffectMgr ctor error, AvatarComp not valid")
  end
  self.Owner  if slua.isValid(self.OwnerAvatarComp) and self.OwnerAvatarComp.CurHandhleMap then
    self.OwnerAvatarComp.CurHandhleMap:Clear()
  end
  self.CacheAvatarSlotToIDMap = {}
end
function ChracterAvatarEffectMgr:Init()
  if slua.isValid(self.OwnerAvatarComp) and not self.OwnerAvatarComp:IsLobbyActor() then
    print(bWriteLog and "ChracterAvatarEffectMgr Int " .. tostring(self.OwnerAvatarComp))
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.HandleEnterGame, self)
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  logic_emote.GetCustomWeaponShowID()
  logic_emote.GetCustomWeaponItemID()
end
function ChracterAvatarEffectMgr:Clear()
  print(bWriteLog and "ChracterAvatarEffectMgr Clear")
  for _, ConditionToEffectMap in pairs(self.PendingEffectMap) do
    if ConditionToEffectMap then
      for key, EffectMap in pairs(ConditionToEffectMap) do
        if EffectMap then
          for _key, EffectCfg in pairs(EffectMap) do
            if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
              EffectCfg:RemoveEffect(self.OwnerAvatarComp)
            end
          end
        end
      end
    end
  end
  self.PendingEffectMap = {}
  for _, Effects in pairs(self.AppliedEffectsMap) do
    for _, EffectCfg in pairs(Effects) do
      if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) and BusinessHelper.IsClassOf(EffectCfg, CharacterEffect_SpawnActor) then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
      end
    end
  end
  self.AppliedEffectsMap = {}
  for _, Processor in pairs(self.ProcessorMap) do
    Processor:Destroy()
  end
  self.ProcessorMap = {}
  if slua.isValid(self.OwnerAvatarComp) and self.OwnerAvatarComp.CurHandhleMap then
    self.OwnerAvatarComp.CurHandhleMap:Clear()
  end
  self.OwnerAvatarComp = nil
  self.CacheAvatarSlotToIDMap = nil
  self:Dispose()
end
function ChracterAvatarEffectMgr:Destroy()
  print(bWriteLog and "ChracterAvatarEffectMgr Destroy " .. tostring(self.OwnerAvatarComp))
  self:Clear()
end
local ComputePutOff = function(New, Old)
  local Ret = {}
  for SlotID, _ in pairs(Old) do
    if New[SlotID] == nil then
      table.insert(Ret, SlotID)
    end
  end
  return Ret
end
function ChracterAvatarEffectMgr:RefreshEffectCfg()
  if not Client then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "ChracterAvatarEffectMgr RefreshEffectCfg Fail ,AvaComp Is not Valid")
    return
  end
  local logic_avatar_gm = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_avatar_gm")
  if logic_avatar_gm and logic_avatar_gm.GetDisableAvatarEffect and logic_avatar_gm:GetDisableAvatarEffect() then
    return
  end
  local NewCache = {}
  for SlotID, Desc in pairs(self.OwnerAvatarComp.ViewSlotDesc) do
    local ItemID = Desc.RealShowItemDefineID.TypeSpecificID
    print(bWriteLog and "ChracterAvatarEffectMgr RefreshEffectCfg ItemID: " .. ItemID .. "  SlotID:" .. tostring(SlotID))
    local LoadedMeshComp = self.OwnerAvatarComp:GetMeshCompBySlot(SlotID)
    if ItemID ~= INVALID_ITEM_ID and slua.isValid(LoadedMeshComp) then
      NewCache[SlotID] = ItemID
    end
  end
  local PutoffSlots = ComputePutOff(NewCache, self.CacheAvatarSlotToIDMap)
  for _, Slot in pairs(PutoffSlots) do
    self:ClearBySlot(Slot)
  end
  log_tree("ChracterAvatarEffectMgr:RefreshEffectCfg NewCache", NewCache)
  log_tree("ChracterAvatarEffectMgr:RefreshEffectCfg CacheAvatarSlotToIDMap", self.CacheAvatarSlotToIDMap)
  for Slot, ItemID in pairs(NewCache) do
    local EquipedHandle = self.OwnerAvatarComp:GetLoadedHandle(Slot)
    if self.CacheAvatarSlotToIDMap[Slot] then
      if self.CacheAvatarSlotToIDMap[Slot] ~= ItemID then
        self:ClearBySlot(Slot)
        if slua.isValid(self.OwnerAvatarComp) and slua.isValid(self.OwnerAvatarComp.CurHandhleMap) and slua.isValid(EquipedHandle) then
          self.OwnerAvatarComp.CurHandhleMap:Add(Slot, EquipedHandle)
        end
        self:UpdateEffects(Slot, EquipedHandle)
      else
      end
    else
      if slua.isValid(self.OwnerAvatarComp) and slua.isValid(self.OwnerAvatarComp.CurHandhleMap) and slua.isValid(EquipedHandle) then
        self.OwnerAvatarComp.CurHandhleMap:Add(Slot, EquipedHandle)
      end
      self:UpdateEffects(Slot, EquipedHandle)
    end
  end
  self:UpadeteProcessors()
  self.CacheAvatarSlotToIDMap = NewCache
end
function ChracterAvatarEffectMgr:UpdateEffects(SlotID, Handle)
  if not slua.isValid(Handle) then
    print(bWriteLog and "ChracterAvatarEffectMgr:UpdateEffects Error Slot " .. SlotID .. " Handle Not Valid")
    return
  end
  if not Handle.SkinEffectCfgs or not slua.isValid(Handle.SkinEffectCfgs) then
    print(bWriteLog and "ChracterAvatarEffectMgr:UpdateEffects Error Slot " .. tostring(SlotID) .. " SkinEffectCfgs Not Valid")
    return
  end
  local EffectNum = Handle.SkinEffectCfgs:Num()
  if EffectNum == 0 then
    return
  end
  log_warning(bWriteLog and "  ChracterAvatarEffectMgr:UpdateEffects. SlotID: " .. tostring(SlotID))
  log_warning(bWriteLog and "  ChracterAvatarEffectMgr:UpdateEffects. Handle: " .. tostring(Handle))
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  for i = 0, EffectNum - 1 do
    local EffectCfg = Handle.SkinEffectCfgs:Get(i)
    if slua.isValid(EffectCfg) then
      local IsInValidScene = self:IsValidScene(EffectCfg.ValidScene)
      if IsInValidScene and self:NeedApply(EffectCfg) then
        EffectCfg:Init()
        EffectCfg.In        if EffectCfg.TriggerCondition == ECharacterEffectTriggerCondition.None then
          print(bWriteLog and "ChracterAvatarEffectMgr Init Apply Effect Directly")
          EffectCfg:ApplyEffect(self.OwnerAvatarComp)
          if self.AppliedEffectsMap[SlotID] == nil then
            self.AppliedEffectsMap[SlotID] = {}
          end
          table.insert(self.AppliedEffectsMap[SlotID], EffectCfg)
        else
          if self.PendingEffectMap[SlotID] == nil then
            self.PendingEffectMap[SlotID] = {}
          end
          if self.PendingEffectMap[SlotID][EffectCfg.TriggerCondition] == nil then
            self.PendingEffectMap[SlotID][EffectCfg.TriggerCondition] = {}
          end
          table.insert(self.PendingEffectMap[SlotID][EffectCfg.TriggerCondition], EffectCfg)
        end
      end
    end
  end
end
function ChracterAvatarEffectMgr:UpadeteProcessors()
  self:ClearUnUseProcessors()
  for _, ConditionToEffectMap in pairs(self.PendingEffectMap) do
    for Type, EffectList in pairs(ConditionToEffectMap) do
      if self.ProcessorMap[Type] == nil then
        local ProcessorFactory = require("GameLua.Mod.Library.GamePlay.Avatar.Component.EffectProc.ConditionProcessorFactory")
        local Processor = ProcessorFactory.GetCharacterProcessor(Type, self)
        if Processor then
          Processor:Init()
          self.ProcessorMap[Type] = Processor
        end
      else
        self.ProcessorMap[Type]:Update()
      end
    end
  end
end
function ChracterAvatarEffectMgr:ClearUnUseProcessors()
  local _Map = {}
  for _, ConditionToEffectMap in pairs(self.PendingEffectMap) do
    for Type, EffectList in pairs(ConditionToEffectMap) do
      _Map[Type] = true
    end
  end
  for Type, Processor in pairs(self.ProcessorMap) do
    if not _Map[Type] and Processor then
      self.ProcessorMap[Type]:Destroy()
      self.ProcessorMap[Type] = nil
    end
  end
end
function ChracterAvatarEffectMgr:ClearBySlot(SlotID)
  print(bWriteLog and "ChracterAvatarEffectMgr ClearBySlot:" .. tostring(SlotID) .. " " .. tostring(self.OwnerAvatarComp))
  if self.PendingEffectMap[SlotID] then
    for _, PendingList in pairs(self.PendingEffectMap[SlotID]) do
      for _, EffectCfg in pairs(PendingList) do
        if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
          EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        else
          print(bWriteLog and "EffectCfg" .. slua.isValid(EffectCfg) .. "  ")
          print(bWriteLog and "OwnerAvatarComp" .. slua.isValid(self.OwnerAvatarComp))
        end
      end
    end
  end
  self.PendingEffectMap[SlotID] = {}
  if self.AppliedEffectsMap[SlotID] then
    for _, EffectCfg in pairs(self.AppliedEffectsMap[SlotID]) do
      if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
      end
    end
  end
  self.AppliedEffectsMap[SlotID] = {}
  if slua.isValid(self.OwnerAvatarComp) and self.OwnerAvatarComp.CurHandhleMap then
    self.OwnerAvatarComp.CurHandhleMap:Remove(SlotID)
  end
end
function ChracterAvatarEffectMgr:IsValidScene(SceneType)
  if not slua.isValid(self.OwnerAvatarComp) then
    return false
  end
  local EWeaponEffectValidSceneType = import("EWeaponEffectValidSceneType")
  local IsInValidScene = false
  if SceneType == EWeaponEffectValidSceneType.All then
    IsInValidScene = true
  elseif SceneType == EWeaponEffectValidSceneType.LobbyOnly and self.OwnerAvatarComp:IsLobbyActor() then
    IsInValidScene = true
  elseif SceneType == EWeaponEffectValidSceneType.InGameOnly and not self.OwnerAvatarComp:IsLobbyActor() then
    IsInValidScene = true
  end
  return IsInValidScene
end
function ChracterAvatarEffectMgr:GetEffectsByType(ConditionType)
  local Ret = {}
  for _, ConditionToEffectMap in pairs(self.PendingEffectMap) do
    if ConditionToEffectMap[ConditionType] then
      for _, EffectCfg in pairs(ConditionToEffectMap[ConditionType]) do
        table.insert(Ret, EffectCfg)
      end
    end
  end
  return Ret
end
function ChracterAvatarEffectMgr:RemoveEffectsByType(ConditionType)
  local EffectsList = self:GetEffectsByType(ConditionType)
  if EffectsList == nil then
    return
  end
  for _, EffectCfg in pairs(EffectsList) do
    if not slua.isValid(EffectCfg) then
      print(bWriteLog and "RemoveEffectsByType EffectCfg not valid!")
    else
      EffectCfg:RemoveEffect(self.OwnerAvatarComp)
    end
  end
end
function ChracterAvatarEffectMgr:GetProcessorByType(Type)
  return self.ProcessorMap[Type]
end
function ChracterAvatarEffectMgr:NeedApply(EffectCfg)
  if not slua.isValid(EffectCfg) then
    print(bWriteLog and "ChracterAvatarEffectMgr:NeedApply Error EffectCfg not valid")
    return false
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "ChracterAvatarEffectMgr:NeedApply Error AvatarComp not valid")
    return false
  end
  print(bWriteLog and "ChracterAvatarEffectMgr:NeedApply IsLobbyActor", self.OwnerAvatarComp:IsLobbyActor())
  if EffectCfg.OnlyValidInBornIsland and not self.OwnerAvatarComp:IsLobbyActor() then
    local GameState = slua_GameFrontendHUD:GetGameState()
    local EGameModeType = import("EGameModeType")
    if slua.isValid(GameState) and GameState.GetGameModeState then
      local GameModeState = GameState:GetGameModeState() or ""
      print(bWriteLog and "ChracterAvatarEffectMgr:NeedApply GameModeState", GameModeState, GameState.GameModeType)
      if GameModeState ~= "ReadyState" and GameState.GameModeType ~= EGameModeType.ESocialIsland and GameState.GameModeType ~= EGameModeType.EPlanPHGameMode and GameState.GameModeType ~= EGameModeType.EMainCityGameMode then
        return false
      end
    end
  end
  if EffectCfg.EnableLowDeviceOpt then
    if self.OwnerAvatarComp:IsLobbyActor() or self.OwnerAvatarComp:IsSelf() then
      return true
    end
    local UIUtil = require("client.common.ui_util")
    local GameInst = UIUtil.GetGameInstance()
    if not slua.isValid(GameInst) then
      return true
    end
    if GameInst:GetExactDeviceLevel() <= 0 then
      return false
    elseif self.OwnerAvatarComp:IsTeammate() then
      return true
    else
      return false
    end
  end
  return true
end
function ChracterAvatarEffectMgr:HasEffectsByType(Type)
  for _, ConditionToEffectsMap in pairs(self.PendingEffectMap) do
    if ConditionToEffectsMap[Type] and 0 < #ConditionToEffectsMap[Type] then
      return true
    end
  end
  for _, Effects in pairs(self.AppliedEffectsMap) do
    for _, EffectCfgCfg in pairs(Effects) do
      if slua.isValid(EffectCfgCfg) and EffectCfgCfg.TriggerCondition == Type then
        return true
      end
    end
  end
  return false
end
function ChracterAvatarEffectMgr:GetAppliedEffects()
  return self.AppliedEffectsMap
end
function ChracterAvatarEffectMgr:RevertAppliedEffectsByConditionType(Type)
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  if Type == ECharacterEffectTriggerCondition.None then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  for Slot, Effects in pairs(self.AppliedEffectsMap) do
    local Index = 1
    while Index <= #Effects do
      local EffectCfg = Effects[Index]
      if not slua.isValid(EffectCfg) then
        print(bWriteLog and "ChracterAvatarEffectMgr RevertAppliedEffectsByConditionType Warning EffectCfg not valid!")
        break
      end
      if EffectCfg.TriggerCondition == Type then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        EffectCfg:Init()
        table.remove(self.AppliedEffectsMap[Slot], Index)
        if self.PendingEffectMap[Slot] == nil then
          self.PendingEffectMap[Slot] = {}
        end
        if self.PendingEffectMap[Slot][Type] == nil then
          self.PendingEffectMap[Slot][Type] = {}
        end
        table.insert(self.PendingEffectMap[Type][Type], EffectCfg)
      else
        Index = Index + 1
      end
    end
  end
end
function ChracterAvatarEffectMgr:HandleEnterGame()
  self:RemoveEffectsOnlyValidInBornIsland()
end
function ChracterAvatarEffectMgr:RemoveEffectsOnlyValidInBornIsland()
  print(bWriteLog and "ChracterAvatarEffectMgr:RemoveEffectsOnlyValidInBornIsland")
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  if self.OwnerAvatarComp:IsLobbyActor() then
    return
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and (GameState.GameModeType == EGameModeType.ESocialIsland or GameState.GameModeType == EGameModeType.EPlanPHGameMode or GameState.GameModeType == EGameModeType.EMainCityGameMode) then
    return
  end
  for Slot, Effects in pairs(self.AppliedEffectsMap) do
    local Index = 1
    while Index <= #Effects do
      local EffectCfg = Effects[Index]
      if not slua.isValid(EffectCfg) then
        print(bWriteLog and "ChracterAvatarEffectMgr HandleEnterGame Warning EffectCfg not valid!")
        break
      end
      if EffectCfg.OnlyValidInBornIsland then
        EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        print(bWriteLog and "ChracterAvatarEffectMgr HandleEnterGame Remove Effect")
        table.remove(self.AppliedEffectsMap[Slot], Index)
      else
        Index = Index + 1
      end
    end
  end
  for k, v in pairs(self.PendingEffectMap) do
    for _, PendingList in pairs(self.PendingEffectMap[k]) do
      local Index = 1
      while Index <= #PendingList do
        local EffectCfg = PendingList[Index]
        if not slua.isValid(EffectCfg) then
          print(bWriteLog and "ChracterAvatarEffectMgr HandleEnterGame Warning EffectCfg not valid!")
          break
        end
        if EffectCfg.OnlyValidInBornIsland then
          EffectCfg:RemoveEffect(self.OwnerAvatarComp)
          table.remove(PendingList, Index)
        else
          Index = Index + 1
        end
      end
    end
  end
end
function ChracterAvatarEffectMgr:GetOwnerAvatarComponent()
  return self.OwnerAvatarComp
end
local class = require("class")
local object = require("common.delegate_container")
local CChracterAvatarEffectMgr = class(object, nil, ChracterAvatarEffectMgr)
return CChracterAvatarEffectMgr
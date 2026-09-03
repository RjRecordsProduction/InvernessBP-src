local CharacterAvatarAdditionEffectMgr = {}
function CharacterAvatarAdditionEffectMgr:ctor(_, AvatarComp)
  self.Owner  self.MoveEffectItem = 0
  self.FootStepEffectItem = 0
  self.PendingEffectMap = {}
  self.AppliedEffectsList = {}
  self.ProcessorMap = {}
  self.HandleMap = {}
  self.ItemEffectMap = {}
  self.PreviewEmoteID = 0
end
function CharacterAvatarAdditionEffectMgr:Init()
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:Init")
  if not Client then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:Init OwnerAvatarComp is not valid")
    return
  end
  if self.OwnerAvatarComp:OwnerIsLobbyPawn() then
    self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PLAY_START, self.OnPlayEmote, self)
    self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, self.OnEndEmote, self)
  else
    self:SetMoveEffectItem(self.OwnerAvatarComp.MoveEffectItem)
    self:SetFootStepEffectItem(self.OwnerAvatarComp.FootStepEffectItem)
    if IsEditor then
      local uOwner = self.OwnerAvatarComp:GetOwner()
      if not slua.isValid(uOwner) then
        return
      end
      local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      local BackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uOwner)
      if not slua.isValid(BackPackComp) then
        return
      end
      self:AddControlEvent(BackPackComp, "SingleItemUpdatedDelegate", self.OnItemChange, self)
    end
  end
end
function CharacterAvatarAdditionEffectMgr:SetMoveEffectItem(ItemID)
  if not Client then
    return
  end
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:SetMoveEffectItem " .. tostring(ItemID))
  if ItemID == self.MoveEffectItem then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:SetMoveEffectItem OwnerAvatarComp is not valid")
    return
  end
  if self.MoveEffectItem and self.MoveEffectItem > 0 then
    self:UnloadItem(self.MoveEffectItem)
  end
  self.MoveEffectItem = ItemID
  if ItemID and 0 < ItemID then
    self:AsyncLoadHandleByItemID(ItemID)
  end
end
function CharacterAvatarAdditionEffectMgr:SetFootStepEffectItem(ItemID)
  if not Client then
    return
  end
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:SetFootStepEffectItem " .. tostring(ItemID))
  if ItemID == self.FootStepEffectItem then
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:SetFootStepEffectItem OwnerAvatarComp is not valid")
    return
  end
  if self.FootStepEffectItem and self.FootStepEffectItem > 0 then
    self:UnloadItem(self.FootStepEffectItem)
  end
  self.FootStepEffectItem = ItemID
  if ItemID and 0 < ItemID then
    self:AsyncLoadHandleByItemID(ItemID)
  end
end
function CharacterAvatarAdditionEffectMgr:AsyncLoadHandleByItemID(ItemID)
  if not ItemID or ItemID <= 0 then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:AsyncLoadHandleByItemID invalid ItemID:" .. tostring(ItemID))
    return
  end
  local HandlePath = self:GetItemAvatarHandlePath(ItemID)
  if not HandlePath or HandlePath == "" then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:AsyncLoadHandleByItemID invalid HandlePath ItemID:" .. tostring(ItemID))
    return
  end
  local UBackpackUtils = import("BackpackUtils")
  if not UBackpackUtils.IsBattleItemHandlePathExist(HandlePath) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:AsyncLoadHandleByItemID HandlePath not exist:" .. tostring(HandlePath))
    return
  end
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:AsyncLoadHandleByItemID start loading ItemID:" .. tostring(ItemID) .. " HandlePath:" .. tostring(HandlePath))
  self:AsyncLoadAsset(HandlePath, self.OnHandleLoaded, self, ItemID)
end
function CharacterAvatarAdditionEffectMgr:OnHandleLoaded(ItemID, Handle)
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoaded ItemID:" .. tostring(ItemID))
  if not slua.isValid(Handle) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoaded Handle is not valid ItemID:" .. tostring(ItemID))
    return
  end
  if not slua.isValid(self.OwnerAvatarComp) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoaded OwnerAvatarComp is not valid")
    return
  end
  self:OnHandleLoadedProcess(ItemID, Handle)
end
function CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess(ItemID, handleClass)
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess ItemID:" .. tostring(ItemID))
  local Handle = handleClass()
  if not slua.isValid(Handle) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess Handle instance is not valid ItemID:" .. tostring(ItemID))
    return
  end
  self.HandleMap[ItemID] = Handle
  slua.addRef(Handle)
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess addRef Handle instance ItemID:" .. tostring(ItemID))
  if not Handle.EffectCfgs or not slua.isValid(Handle.EffectCfgs) then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess EffectCfgs is not valid ItemID:" .. tostring(ItemID))
    return
  end
  local EffectMgr
  if slua.isValid(self.OwnerAvatarComp) and self.OwnerAvatarComp.EffectManager then
    EffectMgr = self.OwnerAvatarComp.EffectManager
  end
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  local EffectNum = Handle.EffectCfgs:Num()
  if EffectNum == 0 then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess EffectCfgs is empty ItemID:" .. tostring(ItemID))
    return
  end
  log_warning(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess ItemID:" .. tostring(ItemID) .. " EffectNum:" .. tostring(EffectNum))
  self.ItemEffectMap[ItemID] = {}
  for i = 0, EffectNum - 1 do
    local EffectCfg = Handle.EffectCfgs:Get(i)
    if not slua.isValid(EffectCfg) then
      print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess EffectCfg is not valid index:" .. tostring(i))
      break
    end
    local IsInValidScene = true
    local NeedApply = true
    if EffectMgr then
      IsInValidScene = EffectMgr:IsValidScene(EffectCfg.ValidScene)
      NeedApply = EffectMgr:NeedApply(EffectCfg)
    end
    if not IsInValidScene or not NeedApply then
      print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess EffectCfg validation failed IsInValidScene:" .. tostring(IsInValidScene) .. " NeedApply:" .. tostring(NeedApply))
    else
      EffectCfg:Init()
      table.insert(self.ItemEffectMap[ItemID], EffectCfg)
      local Condition = EffectCfg.TriggerCondition
      if Condition == ECharacterEffectTriggerCondition.None then
        print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess Apply Effect Directly Condition:None")
        EffectCfg:ApplyEffect(self.OwnerAvatarComp)
        table.insert(self.AppliedEffectsList, EffectCfg)
      else
        if self.PendingEffectMap[Condition] == nil then
          self.PendingEffectMap[Condition] = {}
        end
        table.insert(self.PendingEffectMap[Condition], EffectCfg)
        print(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnHandleLoadedProcess Add to PendingEffectMap Condition:" .. tostring(Condition))
      end
    end
  end
  self:UpdateProcessors()
end
function CharacterAvatarAdditionEffectMgr:UpdateProcessors()
  for ConditionType, EffectList in pairs(self.PendingEffectMap) do
    if self.ProcessorMap[ConditionType] == nil then
      local ProcessorFactory = require("GameLua.Mod.Library.GamePlay.Avatar.Component.EffectProc.ConditionProcessorFactory")
      local Processor = ProcessorFactory.GetCharacterProcessor(ConditionType, self)
      if Processor then
        Processor:Init()
        self.ProcessorMap[ConditionType] = Processor
        print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UpdateProcessors Create Processor ConditionType:" .. tostring(ConditionType))
      end
    end
  end
end
function CharacterAvatarAdditionEffectMgr:GetEffectsByType(ConditionType)
  if self.PendingEffectMap[ConditionType] then
    return self.PendingEffectMap[ConditionType]
  end
  return {}
end
function CharacterAvatarAdditionEffectMgr:UnloadItem(ItemID)
  if not ItemID or ItemID <= 0 then
    return
  end
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UnloadItem ItemID:" .. tostring(ItemID))
  local EffectList = self.ItemEffectMap[ItemID]
  if EffectList then
    local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
    for _, EffectCfg in pairs(EffectList) do
      if not slua.isValid(EffectCfg) then
      else
        for i = #self.AppliedEffectsList, 1, -1 do
          if self.AppliedEffectsList[i] == EffectCfg then
            if slua.isValid(self.OwnerAvatarComp) then
              EffectCfg:RemoveEffect(self.OwnerAvatarComp)
            end
            table.remove(self.AppliedEffectsList, i)
            break
          end
        end
        local Condition = EffectCfg.TriggerCondition
        if Condition ~= ECharacterEffectTriggerCondition.None then
          local PendingList = self.PendingEffectMap[Condition]
          if PendingList then
            for i = #PendingList, 1, -1 do
              if PendingList[i] == EffectCfg then
                if slua.isValid(self.OwnerAvatarComp) then
                  EffectCfg:RemoveEffect(self.OwnerAvatarComp)
                end
                table.remove(PendingList, i)
                break
              end
            end
            if #PendingList == 0 then
              self.PendingEffectMap[Condition] = nil
              local Processor = self.ProcessorMap[Condition]
              if Processor then
                Processor:Destroy()
                self.ProcessorMap[Condition] = nil
                print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UnloadItem Destroy Processor Condition:" .. tostring(Condition))
              end
            end
          end
        end
      end
    end
  else
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UnloadItem EffectList not found ItemID:" .. tostring(ItemID))
  end
  if self.HandleMap[ItemID] then
    local Handle = self.HandleMap[ItemID]
    if slua.isValid(Handle) then
      slua.removeRef(Handle)
      print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UnloadItem removeRef Handle instance ItemID:" .. tostring(ItemID))
    end
    self.HandleMap[ItemID] = nil
  end
  self.ItemEffectMap[ItemID] = nil
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:UnloadItem completed ItemID:" .. tostring(ItemID))
end
function CharacterAvatarAdditionEffectMgr:GetItemAvatarHandlePath(ItemID)
  if not ItemID or ItemID <= 0 then
    return nil
  end
  local UBackpackUtils = import("BackpackUtils")
  local BPID = UBackpackUtils.GetBPIDByResID(ItemID)
  if BPID <= 0 then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:GetItemAvatarHandlePath invalid BPID ItemID:" .. tostring(ItemID))
    return nil
  end
  local model_util = require("client.common.model_util")
  if not model_util then
    print(bWriteLog and "CharacterAvatarAdditionEffectMgr:GetItemAvatarHandlePath model_util not found")
    return nil
  end
  local IsLobby = false
  if slua.isValid(self.OwnerAvatarComp) then
    IsLobby = self.OwnerAvatarComp:IsLobbyActor()
  end
  local HandlePath = model_util.GetPath("Avatar", BPID, IsLobby, false)
  return HandlePath
end
function CharacterAvatarAdditionEffectMgr:Destroy()
  print(bWriteLog and "CharacterAvatarAdditionEffectMgr:Destroy")
  for ConditionType, EffectList in pairs(self.PendingEffectMap) do
    if EffectList then
      for _, EffectCfg in pairs(EffectList) do
        if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
          EffectCfg:RemoveEffect(self.OwnerAvatarComp)
        end
      end
    end
  end
  self.PendingEffectMap = {}
  for _, EffectCfg in pairs(self.AppliedEffectsList) do
    if slua.isValid(EffectCfg) and slua.isValid(self.OwnerAvatarComp) then
      EffectCfg:RemoveEffect(self.OwnerAvatarComp)
    end
  end
  self.AppliedEffectsList = {}
  for ConditionType, Processor in pairs(self.ProcessorMap) do
    if Processor then
      Processor:Destroy()
    end
  end
  self.ProcessorMap = {}
  for ItemID, Handle in pairs(self.HandleMap) do
    if slua.isValid(Handle) then
      slua.removeRef(Handle)
      print(bWriteLog and "CharacterAvatarAdditionEffectMgr:Destroy removeRef Handle instance ItemID:" .. tostring(ItemID))
    end
  end
  self.HandleMap = {}
  self.ItemEffectMap = {}
  self.OwnerAvatarComp = nil
  self:Dispose()
end
function CharacterAvatarAdditionEffectMgr:GetOwnerAvatarComponent()
  return self.OwnerAvatarComp
end
function CharacterAvatarAdditionEffectMgr:OnPlayEmote(_, _, AvatarComp, EmoteID)
  if AvatarComp ~= self.OwnerAvatarComp or EmoteID ~= self.PreviewEmoteID then
    return
  end
  log(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnPlayEmote")
  self:SetMoveEffectItem(self.OwnerAvatarComp.MoveEffectItem)
  self:SetFootStepEffectItem(self.OwnerAvatarComp.FootStepEffectItem)
end
function CharacterAvatarAdditionEffectMgr:OnEndEmote(_, _, actionID)
  if actionID == self.PreviewEmoteID then
    log(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnEndEmote")
    self.PreviewEmoteID = 0
    self.OwnerAvatarComp.MoveEffectItem = 0
    self.OwnerAvatarComp.FootStepEffectItem = 0
    self:SetMoveEffectItem(0)
    self:SetFootStepEffectItem(0)
  end
end
function CharacterAvatarAdditionEffectMgr:OnItemChange(DefineID)
  if not DefineID or not DefineID.TypeSpecificID then
    return
  end
  local config = CDataTable.GetTableData("Item", DefineID.TypeSpecificID)
  if config == nil then
    return
  end
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.WakeFlame then
    log(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnItemChange  WakeFlame " .. tostring(DefineID.TypeSpecificID))
    self:SetMoveEffectItem(DefineID.TypeSpecificID)
  end
  if config.ItemSubType == ENUM_ITEM_SUBTYPE.Footprints then
    log(bWriteLog and "CharacterAvatarAdditionEffectMgr:OnItemChange  Footprints " .. tostring(DefineID.TypeSpecificID))
    self:SetFootStepEffectItem(DefineID.TypeSpecificID)
  end
end
local class = require("class")
local object = require("common.delegate_container")
local CCharacterAvatarAdditionEffectMgr = class(object, nil, CharacterAvatarAdditionEffectMgr)
return CCharacterAvatarAdditionEffectMgr
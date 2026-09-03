local AvatarChangeFormSubsystem = {}
function AvatarChangeFormSubsystem:ctor()
  self.bUpdateShowNum = false
  self.bClickGuide1 = false
  self.bClickGuide2 = false
  self.TransformMutexSkillIDs = {
    1014419,
    1032008,
    1032009,
    1032010
  }
  self.DragonSuitList = {}
  self.InheritDragonSuitList = {}
  self.bInitDragonSuitList = false
end
function AvatarChangeFormSubsystem:OnInit()
  print(bWriteLog and "AvatarChangeFormSubsystem:OnInit")
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
end
function AvatarChangeFormSubsystem:InitDragonSuitList(uPlayerController)
  print(bWriteLog and "AvatarChangeFormSubsystem:InitDragonSuitList " .. tostring(self.bInitDragonSuitList))
  if self.bInitDragonSuitList then
    return
  end
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "AvatarChangeFormSubsystem:InitDragonSuitList not controller")
    return
  end
  if not uPlayerController.CommerFeature then
    print(bWriteLog and "AvatarChangeFormSubsystem:InitDragonSuitList not CommerFeature")
    return
  end
  local DragonSuitList = uPlayerController.CommerFeature.DragonSuitList
  if DragonSuitList then
    for _, itemId in pairs(DragonSuitList) do
      self.DragonSuitList[itemId] = true
    end
  end
  local InheritDragonSuitList = uPlayerController.CommerFeature.InheritDragonSuitList
  if InheritDragonSuitList then
    for _, itemId in pairs(InheritDragonSuitList) do
      self.InheritDragonSuitList[itemId] = true
    end
  end
  self.bInitDragonSuitList = true
end
function AvatarChangeFormSubsystem:GetConfigByItemId(ItemId, source)
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local config = DragonChangeForm:GetConfigByItemIdAndCheck(ItemId, function(item)
    if source == 1 then
      return self.InheritDragonSuitList[item]
    end
    return self.DragonSuitList[item]
  end)
  return config
end
function AvatarChangeFormSubsystem:CheckChangeFormCondition(OwningActor)
  print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition BeforeClothID")
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition OwningActor is invalid")
    return false
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition uAvatarComp2 is invalid")
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local itemId = AvatarItem.TypeSpecificID
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local Source = AvatarDesc and AvatarDesc.CustomInfo.ColorID
  if GlobalData.IsJapanOrKorea() and Source and Source == 1 and not self:GetUnlockState(OwningActor) then
    print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition JKInherit lock")
    return false
  end
  if itemId == nil then
    print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition itemId is nil")
    return false
  end
  local uPlayerController = OwningActor:GetPlayerControllerSafety()
  if not uPlayerController or not slua.isValid(uPlayerController) then
    return false
  end
  self:InitDragonSuitList(uPlayerController)
  local config = self:GetConfigByItemId(itemId, Source)
  local show = config ~= nil
  print(bWriteLog and "AvatarChangeFormSubsystem:CheckChangeFormCondition show = " .. tostring(show))
  return config
end
function AvatarChangeFormSubsystem:GetGuideState(OwningActor, state)
  print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState state = " .. tostring(state))
  if state == 1 and self.bClickGuide1 then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState guide1 has clicked")
    return false
  elseif state == 2 and self.bClickGuide2 then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState guide2 has clicked")
    return false
  end
  if not OwningActor or not slua.isValid(OwningActor) then
    return false
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local itemId = AvatarItem.TypeSpecificID
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local Source = AvatarDesc.CustomInfo.ColorID
  if itemId == nil then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState itemId is nil")
    return false
  end
  local uPlayerController = OwningActor:GetPlayerControllerSafety()
  if not uPlayerController or not slua.isValid(uPlayerController) then
    return false
  end
  self:InitDragonSuitList(uPlayerController)
  local config = self:GetConfigByItemId(itemId, Source)
  if not config then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isClickTab1 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFightChangeFormState1)
  local lobbyState1 = false
  if isClickTab1 and isClickTab1.isClick and isClickTab1.isClick == 1 then
    lobbyState1 = true
  end
  local isClickTab2 = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFightChangeFormState2)
  local lobbyState2 = false
  if isClickTab2 and isClickTab2.isClick and isClickTab2.isClick == 1 then
    lobbyState2 = true
  end
  if lobbyState1 and lobbyState2 then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState lobbyState1 and lobbyState2 both true")
    return false
  end
  local showNumTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFightShowNum)
  local showNum = 0
  if showNumTab and showNumTab.num then
    showNum = showNumTab.num
  end
  print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState showNum = " .. tostring(showNum))
  if 3 <= showNum then
    return false
  end
  print(bWriteLog and "AvatarChangeFormSubsystem:GetGuideState return true")
  return true
end
function AvatarChangeFormSubsystem:UpdateGuideState(state)
  print(bWriteLog and "AvatarChangeFormSubsystem:UpdateGuideState state = " .. tostring(state))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if state == 1 then
    self.bClickGuide1 = true
    local isClickTab = {isClick = 1}
    PlayerPrefsSystem.SaveTableToFile_N(isClickTab, PlayerPrefsSystem.ePlayerPrefsType.eFightChangeFormState1)
  elseif state == 2 then
    self.bClickGuide2 = true
    local isClickTab = {isClick = 1}
    PlayerPrefsSystem.SaveTableToFile_N(isClickTab, PlayerPrefsSystem.ePlayerPrefsType.eFightChangeFormState2)
  end
end
function AvatarChangeFormSubsystem:UpdateShowGuideNum()
  print(bWriteLog and "AvatarChangeFormSubsystem:UpdateShowGuideNum")
  if self.bUpdateShowNum then
    print(bWriteLog and "AvatarChangeFormSubsystem:UpdateShowGuideNum bUpdateShowNum")
    return
  end
  self.bUpdateShowNum = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showNumTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFightShowNum)
  local showNum = 0
  if showNumTab and showNumTab.num then
    showNum = showNumTab.num
  end
  print(bWriteLog and "AvatarChangeFormSubsystem:UpdateShowGuideNum showNum = " .. tostring(showNum))
  showNum = showNum + 1
  showNumTab = {num = showNum}
  PlayerPrefsSystem.SaveTableToFile_N(showNumTab, PlayerPrefsSystem.ePlayerPrefsType.eFightShowNum)
end
function AvatarChangeFormSubsystem:GetUnlockState(OwningActor)
  print(bWriteLog and "AvatarChangeFormSubsystem:GetUnlockState")
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetUnlockState OwningActor is invalid")
    return false
  end
  local uPlayerController = OwningActor:GetPlayerControllerSafety()
  if not uPlayerController or not slua.isValid(uPlayerController) then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetUnlockState uPlayerController is invalid")
    return false
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    print(bWriteLog and "AvatarChangeFormSubsystem:GetUnlockState uAvatarComp2 is invalid")
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local Source = AvatarDesc and AvatarDesc.CustomInfo.ColorID
  local state = uPlayerController.CommerFeature.bLock
  if Source == 1 then
    state = uPlayerController.CommerFeature.bInheritDragonSuitLock
  end
  print(bWriteLog and "AvatarChangeFormSubsystem:GetUnlockState state = " .. tostring(state))
  return state
end
function AvatarChangeFormSubsystem:CheckDownloadState(OwningActor)
  if not OwningActor or not slua.isValid(OwningActor) then
    return false
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return false
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local itemId = AvatarItem.TypeSpecificID
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local Source = AvatarDesc.CustomInfo.ColorID
  print(bWriteLog and "AvatarChangeFormSubsystem:CheckDownloadState itemId = " .. tostring(itemId) .. "source == " .. tostring(Source))
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local config = self:GetConfigByItemId(itemId, Source)
  if not config then
    print(bWriteLog and "AvatarChangeFormSubsystem:CheckDownloadState not config")
    return false
  end
  local itemIdList = {}
  table.insert(itemIdList, itemId)
  table.insert(itemIdList, config.ActionID)
  table.insert(itemIdList, config.AfterClothID)
  for _, id in pairs(itemIdList) do
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {id})
    log(bWriteLog and "AvatarChangeFormSubsystem CheckDownloadState check item_id: " .. tostring(id) .. " state: " .. tostring(state))
    if state ~= PufferConst.ENUM_DownloadState.Done then
      return false
    end
  end
  return true
end
function AvatarChangeFormSubsystem:TryTransform(OwningActor)
  print(bWriteLog and "AvatarChangeFormSubsystem:TryTransform")
  if not OwningActor or not slua.isValid(OwningActor) then
    print(bWriteLog and "AvatarChangeFormSubsystem:TryTransform OwningActor is invalid")
    return
  end
  if GlobalData.IsJapanOrKorea() then
    local bUnlock = self:GetUnlockState(OwningActor)
    print(bWriteLog and "AvatarChangeFormSubsystem:TryTransform bUnlock = " .. tostring(bUnlock))
    if not bUnlock then
      ShowNotice(150078)
      return
    end
  end
  local state = self:CheckDownloadState(OwningActor)
  if not state then
    ShowNotice(508505)
    return
  end
  local ChangeAvatarFormSkillID = 1014419
  local SkillMgr = OwningActor:GetSkillManager()
  if Game:IsValid(SkillMgr) then
    for i, MutexSkillID in ipairs(self.TransformMutexSkillIDs) do
      if SkillMgr:IsCastingSkillID(MutexSkillID) then
        print(bWriteLog and "AvatarChangeFormSubsystem:TryTransform IsCastingSkillID:", MutexSkillID)
        return
      end
    end
  end
  self:PreTransform(OwningActor, ChangeAvatarFormSkillID, SkillMgr)
  print(bWriteLog and "AvatarChangeFormSubsystem:TryTransform", ChangeAvatarFormSkillID)
  OwningActor:TriggerEntrySkillWithParams(ChangeAvatarFormSkillID, {"PreItemID"}, true)
end
function AvatarChangeFormSubsystem:PreTransform(OwningActor, SkillID, SkillMgr)
  SkillMgr:SetValueAsInt(SkillID, "PreItemID", 0)
  if not OwningActor or not slua.isValid(OwningActor) then
    return
  end
  local uAvatarComp2 = OwningActor:getAvatarComponent2()
  if not slua.isValid(uAvatarComp2) then
    return
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local AvatarItem = uAvatarComp2:GetEquippedItemDefineID(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local itemId = AvatarItem.TypeSpecificID
  local AvatarDesc = uAvatarComp2:GetAvatarSlotDesc(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local Source = AvatarDesc and AvatarDesc.CustomInfo.ColorID
  print(bWriteLog and "AvatarChangeFormSubsystem:PreTransform itemId = " .. tostring(itemId) .. ", Source = " .. tostring(Source))
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local config = DragonChangeForm:GetConfigByItemIdAndCheck(itemId, function(item)
    if Source == 1 then
      return self.InheritDragonSuitList[item]
    end
    return self.DragonSuitList[item]
  end)
  if config and config.ActionType == DragonChangeForm.CONST_ACTION_TYPE.RECOVER then
    local PreItemID = DragonChangeForm:GetLastItemOfSeries(itemId)
    if PreItemID ~= itemId then
      log(bWriteLog and "AvatarChangeFormSubsystem:PreTransform PreItemID = " .. tostring(PreItemID))
      SkillMgr:SetValueAsInt(SkillID, "PreItemID", PreItemID)
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AvatarChangeFormSubsystem)
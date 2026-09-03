local AvatarFuzzySubsystem = {}
local tDefaultSlotItemMap = {
  [5] = 403003,
  [6] = 404026,
  [7] = 405007,
  [11] = 703001
}
local tDefaultSlotPrefixMap = {
  [8] = true,
  [9] = true,
  [10] = true
}
local tSkipSlotItemMap = {
  [1] = true,
  [2] = true,
  [11] = true
}
local ESyncOperation = import("ESyncOperation")
function AvatarFuzzySubsystem:OnInit()
  print(bWriteLog and "AvatarFuzzySubsystem:OnInit")
  self:AddCommonEvent(EVENTTYPE_GAMESTATE, EVENTID_GAMESTATE_DSSWITCHCHANGED, self.HandleOnDSSwitchChanged, self)
  local bShouldFuzzy = self:CheckShouldFuzzy()
  if bShouldFuzzy then
    self:InitFuzzy()
  end
end
function AvatarFuzzySubsystem:CheckShouldFuzzy()
  if self.bFuzzyInit then
    print(bWriteLog and "AvatarFuzzySubsystem:CheckShouldFuzzy bFuzzyInit")
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    print(bWriteLog and "AvatarFuzzySubsystem:CheckShouldFuzzy uGameState")
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "AvatarFuzzySubsystem:CheckShouldFuzzy uPlayerController")
    return false
  end
  if uPlayerController.ObserverFlags and uPlayerController.ObserverFlags > 0 then
    print(bWriteLog and "AvatarFuzzySubsystem:CheckShouldFuzzy ObserverFlags")
    return false
  end
  return true
end
function AvatarFuzzySubsystem:BindOnAvatarDataChanged()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "AvatarFuzzySubsystem:BindOnAvatarDataChanged uPlayerController invalid")
    return
  end
  self:AddControlEvent(uPlayerController, "OnAvatarDataChanged", self.HandleOnAvatarDataChanged, self)
  print(bWriteLog and "AvatarFuzzySubsystem:BindOnAvatarDataChanged")
end
function AvatarFuzzySubsystem:HandleOnAvatarDataChanged(uAvatarComp)
  print(bWriteLog and "AvatarFuzzySubsystem:HandleOnAvatarDataChanged")
  self:FuzzyCharacterAvatar(uAvatarComp)
end
function AvatarFuzzySubsystem:HandleOnDSSwitchChanged(_, __)
  print(bWriteLog and "AvatarFuzzySubsystem:HandleOnDSSwitchChanged")
  local bShouldFuzzy = self:CheckShouldFuzzy()
  if bShouldFuzzy then
    self:InitFuzzy()
  end
end
function AvatarFuzzySubsystem:InitFuzzy()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  local sValue = uGameState:GetDSSwitchValueFastWithCache(96)
  print(bWriteLog and "AvatarFuzzySubsystem:InitFuzzy Value", sValue)
  local bEnableFuzzyAvatar = sValue == "1"
  if bEnableFuzzyAvatar then
    self.bFuzzyInit = true
    self:BindOnAvatarDataChanged()
    print(bWriteLog and "AvatarFuzzySubsystem:InitFuzzy bFuzzyInit true")
    local uPlayerPawnList = Game:GetAllPlayerPawns()
    for _, uPlayerPawn in pairs(uPlayerPawnList) do
      if slua.isValid(uPlayerPawn) then
        local uAvatarComp = uPlayerPawn:getAvatarComponent2()
        if slua.isValid(uAvatarComp) then
          self:FuzzyCharacterAvatar(uAvatarComp)
          uAvatarComp:OnRep_BodySlotStateChangedInternal()
        end
      end
    end
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController then
    uPlayerController.bEnableFuzzyAvatarOnClient = bEnableFuzzyAvatar
  end
end
function AvatarFuzzySubsystem:FuzzyCharacterAvatar(uAvatarComp)
  if not slua.isValid(uAvatarComp) then
    return
  end
  if uAvatarComp.NetAvatarData and uAvatarComp.NetAvatarData.SlotSyncData then
    local TempSlotSyncData = slua.IndexReference(uAvatarComp.NetAvatarData, "SlotSyncData")
    if TempSlotSyncData then
      for Index, AvatarSyncData in pairs(TempSlotSyncData) do
        if AvatarSyncData.ItemID > 0 then
          if tDefaultSlotItemMap[AvatarSyncData.SlotID] then
            AvatarSyncData.ItemID = tDefaultSlotItemMap[AvatarSyncData.SlotID]
            AvatarSyncData.AdditionalItemID = 0
            AvatarSyncData.SubSlotID = 0
            AvatarSyncData.FakeItemID = 0
          elseif tDefaultSlotPrefixMap[AvatarSyncData.SlotID] then
            if 0 < AvatarSyncData.AdditionalItemID then
              AvatarSyncData.ItemID = AvatarSyncData.AdditionalItemID
            end
          elseif tSkipSlotItemMap[AvatarSyncData.SlotID] then
          else
            AvatarSyncData.OperationType = ESyncOperation.PutOff
          end
          slua.IndexReference(uAvatarComp.NetAvatarData, "SlotSyncData"):Set(Index, AvatarSyncData)
        end
      end
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AvatarFuzzySubsystem)
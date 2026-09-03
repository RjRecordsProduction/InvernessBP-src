local PlayerControllerAvatarBagFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
PlayerControllerAvatarBagFeature.ClientRPC.RPCClient_UpdateAllWears = {
  Reliable = true,
  Params = {
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Bool
    },
    {
      UEnums.EPropertyClass.Array,
      import("GameModePlayerItem")
    },
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
}
function PlayerControllerAvatarBagFeature:_PostConstruct()
  PlayerControllerAvatarBagFeature.__super._PostConstruct(self)
end
function PlayerControllerAvatarBagFeature:ReceiveBeginPlay()
  PlayerControllerAvatarBagFeature.__super.ReceiveBeginPlay(self)
  self.ForbidCopyItems = {
    [403045] = true,
    [403187] = true,
    [403989] = true,
    [403990] = true
  }
  if not Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ITEM_UPDATED, self.OnClothingItemUpdate, self)
  end
  if not slua.isValid(CGameState) or CGameState:GetGameModeState() ~= "FightingState" then
    local uPlayerController = self.Owner.Object
    if not uPlayerController then
      return
    end
    local uBackPackComponent = uPlayerController:GetBackPackComponent()
    if slua.isValid(uBackPackComponent) then
      self:AddControlEvent(uBackPackComponent, "ItemOperationDelegate", self.OnItemOperation, self)
    end
    self:AddControlEvent(uPlayerController, "OnGameStateChange", self.OnGameStateChange, self)
  end
end
function PlayerControllerAvatarBagFeature:OnClothingItemUpdate(_, _, DefineID, Reason, bIsEquip)
  if bIsEquip then
    return
  end
  if Reason ~= 4 and Reason ~= 2 then
    return
  end
  local uPlayerController = self.Owner.Object
  if not uPlayerController then
    return
  end
  local AvatarUtils = import("AvatarUtils")
  local InitialAllWear = uPlayerController.InitialAllWear
  local ItemTypeSpecificID = DefineID.TypeSpecificID
  local nSlotID = AvatarUtils.GetItemAvatarSlotID(DefineID.Type, ItemTypeSpecificID)
  local bChanged = false
  print(bWriteLog and "PlayerControllerAvatarBagFeature:OnClothingItemUpdate Slot ID ", nSlotID, Reason, bIsEquip)
  local ChangeStateArray = slua.Array(UEnums.EPropertyClass.Bool)
  local ChangeInfoArray = slua.Array(UEnums.EPropertyClass.Struct, import("GameModePlayerItem"))
  local ChangeIndexArray = slua.Array(UEnums.EPropertyClass.Int)
  local CurIndex = uPlayerController.RolewearIndex
  for i = 0, InitialAllWear:Num() - 1 do
    if i ~= CurIndex then
      local Value = InitialAllWear:Get(i)
      local Wear = Value.RolewearInfo
      local bFindIndex = -1
      for j = 0, Wear:Num() - 1 do
        local WearItem = Wear:Get(j)
        local WearSlotID = AvatarUtils.GetItemAvatarSlotID(4, WearItem.ItemTableID)
        if WearItem.ItemTableID == ItemTypeSpecificID then
          bFindIndex = j
          break
        end
      end
      if bFindIndex ~= -1 then
        local uGameModePlayerItem = import("GameModePlayerItem")
        local uNewItem = uGameModePlayerItem()
        uNewItem.ItemTableID = bFindIndex
        Wear:Remove(bFindIndex)
        InitialAllWear:Set(i, Value)
        ChangeStateArray:Add(false)
        ChangeInfoArray:Add(uNewItem)
        ChangeIndexArray:Add(i)
        bChanged = true
      end
      print(bWriteLog and "PlayerControllerAvatarBagFeature:OnClothingItemUpdate Find Index ", bFindIndex)
    end
  end
  if bChanged then
    self:RPCClient_UpdateAllWears(ChangeStateArray, ChangeInfoArray, ChangeIndexArray)
  end
end
function PlayerControllerAvatarBagFeature:RPCClient_UpdateAllWears(ChangeStateArray, ChangeInfoArray, ChangeIndexArray)
  local uPlayerController = self.Owner.Object
  if not slua.isValid(uPlayerController) then
    return
  end
  local InitialAllWear = uPlayerController.InitialAllWear
  for i = 0, ChangeIndexArray:Num() - 1 do
    local ChangeIndex = ChangeIndexArray:Get(i)
    local ChangeState = ChangeStateArray:Get(i)
    local ChangeInfo = ChangeInfoArray:Get(i)
    if ChangeIndex < InitialAllWear:Num() then
      local Value = InitialAllWear:Get(ChangeIndex)
      local RoleWearInfo = Value.RolewearInfo
      if ChangeState then
        RoleWearInfo:Add(ChangeInfo)
        InitialAllWear:Set(ChangeIndex, Value)
      else
        local RemoveIndex = ChangeInfo.ItemTableID
        RoleWearInfo:Remove(RemoveIndex)
        InitialAllWear:Set(ChangeIndex, Value)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_INGAME_UPDATE_CLOTHES_TIMES)
end
function PlayerControllerAvatarBagFeature:OnItemOperation(DefineID, OperationType, Reason)
  local uPlayerController = self.Owner.Object
  if not slua.isValid(uPlayerController) then
    return
  end
  if DefineID.Type ~= 4 then
    return
  end
  if CGameState and CGameState:GetGameModeState() ~= "ReadyState" then
    return
  end
  local TypeSpecificID = DefineID.TypeSpecificID
  local EBattleItemOperationType = import("EBattleItemOperationType")
  if OperationType == EBattleItemOperationType.Pickup then
    local InitialItemList = uPlayerController.InitialItemList
    for i = InitialItemList:Num() - 1, 0, -1 do
      local ItemInfo = InitialItemList:Get(i)
      if ItemInfo and ItemInfo.ItemTableID == TypeSpecificID then
        ItemInfo.bDropped = false
        InitialItemList:Set(i, ItemInfo)
        break
      end
    end
  elseif OperationType == EBattleItemOperationType.Drop then
    if Reason == 6 then
      return
    end
    local InitialItemList = uPlayerController.InitialItemList
    for i = InitialItemList:Num() - 1, 0, -1 do
      local ItemInfo = InitialItemList:Get(i)
      if ItemInfo and ItemInfo.ItemTableID == TypeSpecificID then
        ItemInfo.bDropped = true
        InitialItemList:Set(i, ItemInfo)
        break
      end
    end
  end
end
function PlayerControllerAvatarBagFeature:OnGameStateChange()
  if CGameState and CGameState:GetGameModeState() == "FightingState" then
    local uPlayerController = self.Owner.Object
    if not uPlayerController then
      return
    end
    local uBackPackComponent = uPlayerController:GetBackPackComponent()
    if slua.isValid(uBackPackComponent) then
      self:RemoveControlEvent(uBackPackComponent, "ItemOperationDelegate")
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerControllerAvatarBagFeature)
local MLAIProcessUtil = {}
local UGameplayStatics = import("GameplayStatics")
local pb = require("pb")
pb.option("enum_as_value")
local BackpackUtils = import("BackpackUtils")
local EBattleItemPickupReason = import("EBattleItemPickupReason")
local TableUtil = require("common.table_util")
function MLAIProcessUtil:InitPB()
  local allpb = {
    "ccs_ai_common",
    "ccs_ai_action",
    "ccs_ai_api",
    "ccs_ai_proxy",
    "ccs_ai_state",
    "ccs_channel",
    "ccs_game_api",
    "state_diff"
  }
  for _, f in pairs(allpb) do
    if not pb.loadfile("ai_ds/" .. f .. ".pb") then
      print(bWriteLog and "MLAIProcessUtil::InitPB-load " .. f .. " fail")
    end
  end
end
function MLAIProcessUtil:ToggleDSReplay(bStart, ReplayStreamer)
  print(bWriteLog and "MLAIProcessUtil:ToggleDSReplay bStart =", tostring(bStart))
  local uGameInstance = UGameplayStatics.GetGameInstance(CGameWorld)
  if slua.isValid(uGameInstance) then
    local uCompletePlayback = uGameInstance:GetCompletePlayback()
    if slua.isValid(uCompletePlayback) then
      if uCompletePlayback.SetReplayStreamer then
        ReplayStreamer = ReplayStreamer or "NullNetworkReplayStreaming"
        uCompletePlayback:SetReplayStreamer(ReplayStreamer)
        print(bWriteLog and string.format("MLAIProcessUtil:ToggleDSReplay,ReplayStreamer=%s", tostring(ReplayStreamer)))
      end
      if bStart then
        uCompletePlayback:SetIsGMSpectator(true)
        uCompletePlayback:StartRecordingReplay()
        uCompletePlayback:SetIsGMSpectator(false)
        print(bWriteLog and "MLAIProcessUtil:ToggleDSReplay StartRecordingReplay")
      else
        uCompletePlayback:StopRecordingReplay()
        print(bWriteLog and "MLAIProcessUtil:ToggleDSReplay StopRecordingReplay")
      end
    end
  end
end
function MLAIProcessUtil:GetPBAIStateInfo(AIStateInfo)
  if AIStateInfo then
    return pb.encode("ccs_ai.NewAllPlayerStateRequest", AIStateInfo)
  end
  return nil
end
function MLAIProcessUtil:DecodePBAIStateInfo(AIStateInfo)
  if AIStateInfo then
    return pb.decode("ccs_ai.NewAllPlayerStateRequest", AIStateInfo)
  end
  return nil
end
function MLAIProcessUtil:AddItem(uAIBot, ItemConfigs)
  print(bWriteLog and "MLAIProcessUtil:AddItem")
  for _, OneItemConfig in pairs(ItemConfigs) do
    local uItemDefineID = BackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(OneItemConfig.type_id)
    local PickupInfo = {}
    PickupInfo.Count = OneItemConfig.count
    uAIBot.BackpackComponent:PickupItem(uItemDefineID, PickupInfo, EBattleItemPickupReason.Manually, 0)
  end
end
function MLAIProcessUtil:AddItemForTeammateMLAI(uAIBot, ItemList)
  for _, OneItemConfig in pairs(ItemList) do
    local uItemDefineID = BackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(OneItemConfig.ItemID)
    local PickupInfo = {}
    PickupInfo.Count = OneItemConfig.Count
    uAIBot.BackpackComponent:PickupItem(uItemDefineID, PickupInfo, EBattleItemPickupReason.Manually, 0)
    print(bWriteLog and string.format("MLAIProcessUtil:AddItemForTeammateMLAI uItemDefineID:%s, PickupInfo.Count:%s", tostring(uItemDefineID), tostring(PickupInfo.Count)))
  end
end
function MLAIProcessUtil:AddWeaponAvatar(uAIController, nWeaponAvatarID, nWeaponAttachmentID)
  if uAIController and slua.isValid(uAIController) then
    if nWeaponAvatarID <= 0 then
      log(bWriteLog and "MLAIProcessUtil:AddGrenadeAvatar, nWeaponAvatarID Invalid, Should be greater than 0")
      return
    end
    local AvatarUtils = import("AvatarUtils")
    local WeaponBPID = BackpackUtils.GetBPIDByResID(nWeaponAvatarID)
    local IntArray = slua.Array(UEnums.EPropertyClass.Int)
    local ParentIDList = AvatarUtils.GetWeaponAvatarParentIDList(WeaponBPID, IntArray, false)
    if ParentIDList and 0 >= ParentIDList:Num() then
      log(bWriteLog and "MLAIProcessUtil:AddWeaponAvatar, nWeaponAvatarID Invalid, Please check the nWeaponAvatarID")
      return
    end
    for k, ParentID in pairs(ParentIDList) do
      uAIController.AIWeaponAvatarItemList:Add(ParentID, WeaponBPID)
    end
    local cfg = CDataTable.GetTableData("WeaponSkinMapping", WeaponBPID)
    if cfg and cfg.WeaponID then
      local ItemConfigs = {
        {
          type_id = cfg.WeaponID,
          count = 1
        }
      }
      self:AddItem(uAIController, ItemConfigs)
    end
    log(bWriteLog and "MLAIProcessUtil:AddGrenadeAvatar, nAIBotID:" .. tostring(uAIController.PlayerKey) .. " nWeaponAvatarID:" .. tostring(nWeaponAvatarID) .. " nWeaponAttachmentID:" .. tostring(nWeaponAttachmentID))
  end
end
function MLAIProcessUtil:AddGrenadeAvatar(uAIController, nGrenadeAvatarID)
  if uAIController and slua.isValid(uAIController) then
    local ItemCfg = CDataTable.GetTableData("Item", nGrenadeAvatarID)
    if not ItemCfg then
      log(bWriteLog and "MLAIProcessUtil:AddGrenadeAvatar, nGrenadeAvatarID Invalid, Please check the nGrenadeAvatarID")
      return nil
    end
    local ProtoItemID
    if ItemCfg.ItemSubType == 612 then
      ProtoItemID = 60200400
      uAIController.InitialConsumableAvatar.GrenadeAvatarShoulei = nGrenadeAvatarID
    elseif ItemCfg.ItemSubType == 613 then
      ProtoItemID = 60200200
      uAIController.InitialConsumableAvatar.GrenadeAvatarSmoke = nGrenadeAvatarID
    elseif ItemCfg.ItemSubType == 614 then
      ProtoItemID = 60200100
      uAIController.InitialConsumableAvatar.GrenadeAvatarStun = nGrenadeAvatarID
    elseif ItemCfg.ItemSubType == 615 then
      ProtoItemID = 60200300
      uAIController.InitialConsumableAvatar.GrenadeAvatarBurn = nGrenadeAvatarID
    end
    if not ProtoItemID then
      log(bWriteLog and "MLAIProcessUtil:AddGrenadeAvatar, ItemSubType Invalid, Please check the ItemSubType")
      return
    end
    uAIController.AIGrenadeAvatarItemList:Add(ProtoItemID, nGrenadeAvatarID)
    local ItemID = math.tointeger(ProtoItemID / 100)
    local ItemConfigs = {
      {type_id = ItemID, count = 1}
    }
    self:AddItem(uAIController, ItemConfigs)
    log(bWriteLog and "MLAIProcessUtil:AddGrenadeAvatar, nAIBotID:" .. tostring(uAIController.PlayerKey) .. " ItemID:" .. tostring(ItemID) .. " nGrenadeAvatarID:" .. tostring(nGrenadeAvatarID))
    return ItemID
  end
  return nil
end
function MLAIProcessUtil:SetSafetyArea(SafetyAreaSetRequestInfo)
  if SafetyAreaSetRequestInfo == nil then
    return false
  end
  local SafetyAreaConfigs = SafetyAreaSetRequestInfo.safety_area_config
  log_tree("MLAIProcessUtil:SetSafetyArea |SafetyAreaConfigs=", SafetyAreaConfigs)
  local uCircleMgrComponent = CGameMode:GetComponentByClass(import("/Script/ShadowTrackerExtra.CircleMgrComponent"))
  if slua.isValid(uCircleMgrComponent) and SafetyAreaConfigs and 0 < #SafetyAreaConfigs then
    local NewSafetyConfigs = {}
    for _, OneSafetyConfig in ipairs(SafetyAreaConfigs) do
      if not OneSafetyConfig.index or 0 > OneSafetyConfig.index or OneSafetyConfig.index >= uCircleMgrComponent.CircleConfigs:Num() then
        return
      end
      local uCirCleCfg = import("CirCleCfg")()
      local uOldCirCleCfg = uCircleMgrComponent.CircleConfigs:Get(OneSafetyConfig.index)
      if uCirCleCfg and uOldCirCleCfg then
        uCirCleCfg.delaytime = 0
        uCirCleCfg.SafeZoneAppeartime = OneSafetyConfig.wait_time
        uCirCleCfg.lasttime = OneSafetyConfig.shrink_time
        uCirCleCfg.bUseCustomWhitePoint = true
        local Whitepoints = {
          FVector(OneSafetyConfig.center_x, OneSafetyConfig.center_y, 0)
        }
        uCirCleCfg.        uCirCleCfg.whiteradius = OneSafetyConfig.radius * 100
        uCirCleCfg.bUseCustomBluePoint = uOldCirCleCfg.bUseCustomBluePoint
        uCirCleCfg.bluepoint = uOldCirCleCfg.bluepoint
        uCirCleCfg.blueradius = uOldCirCleCfg.blueradius
        uCirCleCfg.bUseCustomWhiteStrategy = uOldCirCleCfg.bUseCustomWhiteStrategy
        uCirCleCfg.Alpha = uOldCirCleCfg.Alpha
        uCirCleCfg.DamageMagnifierCurve = uOldCirCleCfg.DamageMagnifierCurve
        uCirCleCfg.pain = uOldCirCleCfg.pain
        uCirCleCfg.RadiusWhenDestoryMap = uOldCirCleCfg.RadiusWhenDestoryMap
        uCirCleCfg.bUseContainActor = uOldCirCleCfg.bUseContainActor
        uCirCleCfg.DestinyChance = uOldCirCleCfg.DestinyChance
        uCirCleCfg.bActiveScreenSize = uOldCirCleCfg.bActiveScreenSize
        uCirCleCfg.ScreenSizeFactor = uOldCirCleCfg.ScreenSizeFactor
        uCirCleCfg.ExtraRadius = uOldCirCleCfg.ExtraRadius
        uCirCleCfg.bEnableDamageMagnifier = uOldCirCleCfg.bEnableDamageMagnifier
        uCirCleCfg.DamageMagnifierRange = uOldCirCleCfg.DamageMagnifierRange
        uCirCleCfg.DamageMagnifier = uOldCirCleCfg.DamageMagnifier
        uCirCleCfg.AvoidPoints = uOldCirCleCfg.AvoidPoints
        uCirCleCfg.EdgeDistance = uOldCirCleCfg.EdgeDistance
        uCirCleCfg.bUseAvoidPoints = uOldCirCleCfg.bUseAvoidPoints
        table.insert(NewSafetyConfigs, uCirCleCfg)
      end
    end
    uCircleMgrComponent.CircleConfigs:Clear()
    for _, OneNewSafetyConfig in ipairs(NewSafetyConfigs) do
      uCircleMgrComponent.CircleConfigs:Add(OneNewSafetyConfig)
    end
    uCircleMgrComponent:InitCircleTimer()
    print(bWriteLog and "MLAIProcessUtil:SetSafetyArea return true")
    return true
  end
  print(bWriteLog and "MLAIProcessUtil:SetSafetyArea return false")
  return false
end
function MLAIProcessUtil:CheckMLDeliveryReceived(uAIController, uEventInstigator)
  if not slua.isValid(uAIController) then
    return false
  end
  local uKilledPawn = uAIController:GetPlayerCharacterSafety()
  if not slua.isValid(uKilledPawn) then
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-1 uAIController.PlayerKey:%s, uEventInstigator.PlayerKey:%s not slua.isValid(uKilledPawn)", tostring(uAIController.PlayerKey), tostring(uEventInstigator and uEventInstigator.PlayerKey or 0)))
    return false
  end
  local uKillerPawn
  if slua.isValid(uKilledPawn.WhoKillMeRecord) then
    uKillerPawn = uKilledPawn.WhoKillMeRecord.CharacterOwner
  elseif slua.isValid(uEventInstigator) and uEventInstigator.GetPlayerCharacterSafety then
    uKillerPawn = uEventInstigator:GetPlayerCharacterSafety()
  else
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-2 uAIController.PlayerKey:%s, not slua.isValid(uEventInstigator) and uEventInstigator.GetPlayerCharacterSafety", tostring(uAIController.PlayerKey)))
  end
  if not slua.isValid(uKillerPawn) then
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-3 uAIController.PlayerKey:%s, not slua.isValid(uKillerPawn)", tostring(uAIController.PlayerKey)))
    return false
  end
  if not uAIController.IsMLAI or uKillerPawn.bEnsure then
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-4 uAIController.PlayerKey:%s, not uAIController.IsMLAI(%s) or uKillerPawn.bEnsure(%s)", tostring(uAIController.PlayerKey), tostring(uAIController.IsMLAI), tostring(uKillerPawn.bEnsure)))
    return false
  end
  if not uAIController:IsDeliver() then
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-5 uAIController.PlayerKey:%s, not uAIController:IsDeliver()(%s)", tostring(uAIController.PlayerKey), tostring(uAIController:IsDeliver())))
    return false
  end
  local uDeliveryTarget
  if uAIController.GetDeliverTarget then
    uDeliveryTarget = uAIController:GetDeliverTarget()
  end
  if not slua.isValid(uDeliveryTarget) or uDeliveryTarget.PlayerKey == nil then
    print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-6 uAIController.PlayerKey:%s, not slua.isValid(uDeliveryTarget) or uDeliveryTarget.PlayerKey == nil", tostring(uAIController.PlayerKey)))
    return false
  end
  local nKillerPlayerKey = uKillerPawn.PlayerKey
  local nRecipientPlayerKey = uDeliveryTarget.PlayerKey
  print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived() uAIController.PlayerKey:%s, nKillerPlayerKey=%s, nRecipientPlayerKey=%s", tostring(uAIController.PlayerKey), tostring(nKillerPlayerKey), tostring(nRecipientPlayerKey)))
  if nRecipientPlayerKey == nKillerPlayerKey then
    return true
  else
    local PlayerStateTArray = CGame:GetTeamMatePlayerStateList(nRecipientPlayerKey, true)
    for _, uMateState in pairs(PlayerStateTArray) do
      if slua.isValid(uMateState) and uMateState.GetPlayerCharacter then
        local uMatePawn = uMateState:GetPlayerCharacter()
        if slua.isValid(uMatePawn) and uMatePawn.PlayerKey == nKillerPlayerKey then
          return true
        end
      end
    end
  end
  print(bWriteLog and string.format("MLAIProcessUtil:CheckMLDeliveryReceived()-10 uAIController.PlayerKey:%s, return false", tostring(uAIController.PlayerKey)))
  return false
end
function MLAIProcessUtil:GetCurrentMapName()
  if Client then
    return "none"
  end
  local sMapName = UGameplayStatics.GetCurrentLevelName(CGameMode:GetWorld(), true)
  return sMapName
end
function MLAIProcessUtil:IsPointRectIntersect(tInPoint, tInRectCenter, tInRectSizeX, tInRectSizeY)
  if tInPoint == nil or tInRectCenter == nil or tInRectSizeX == nil or tInRectSizeX <= 0 or tInRectSizeY == nil or tInRectSizeY <= 0 then
    return false
  end
  local Ver0X = tInRectCenter[1] - tInRectSizeX
  local Ver0Y = tInRectCenter[2] - tInRectSizeY
  local Ver1X = tInRectCenter[1] + tInRectSizeX
  local Ver2Y = tInRectCenter[2] + tInRectSizeY
  if Ver0X <= tInPoint[1] and Ver1X >= tInPoint[1] and Ver0Y <= tInPoint[2] and Ver2Y >= tInPoint[2] then
    return true
  end
  return false
end
function MLAIProcessUtil:CheckLocationInCityArea(InLocation)
  local AIBotJumpConfig = require("GameLua.ExtraModule.MLAI.DS.Config.AIBotJumpStrategyConfig")
  if not AIBotJumpConfig or AIBotJumpConfig.CitySizeConfig == nil then
    return
  end
  if InLocation == nil or InLocation.IsZero and InLocation:IsZero() then
    return
  end
  local sMapName = self:GetCurrentMapName()
  if sMapName == nil or not AIBotJumpConfig.CitySizeConfig[sMapName] then
    print(bWriteLog and "[error] MLAIProcessUtil:CheckLocationInCityArea Cannot find city configuration for map: ", sMapName)
    return
  end
  local t2DLocation = {
    InLocation.X,
    InLocation.Y
  }
  local tCityConfig = AIBotJumpConfig.CitySizeConfig[sMapName]
  for nCityLevel, tCities in pairs(tCityConfig) do
    for sCityName, tOneCity in pairs(tCities) do
      local tCenter = tOneCity.Center
      local tSize = tOneCity.Size
      if tCenter and tSize and 1 < #tCenter and 1 < #tSize then
        local tRealSizeX = tSize[1] * 100
        local tRealSizeY = tSize[2] * 100
        if self:IsPointRectIntersect(t2DLocation, tCenter, tRealSizeX, tRealSizeY) then
          print(bWriteLog and string.format("MLAIProcessUtil:CheckLocationInCityArea(X:%s Y:%s Z:%s), Result:true City:%s", tostring(InLocation.X), tostring(InLocation.Y), tostring(InLocation.Z), sCityName))
          return true, sCityName, nCityLevel
        end
      else
        print(bWriteLog and string.format("error MLAIProcessUtil:CheckLocationInCityArea() bad config:%s", sCityName))
      end
    end
  end
  return
end
function MLAIProcessUtil:SpawnItemForAIByDropID(uAIController, nDropID, bNeedDropAtBegin)
  if Game:IsValid(uAIController) then
    printf(bWriteLog and string.format("[MLAIProcessUtil]SpawnItemForAIByDropID,nDropID=%s, AI=%s(%s)", tostring(nDropID), tostring(uAIController.PlayerKey), tostring(uAIController.PlayerName)))
    local uItemDropMgr = CGameMode.BP_ItemDropMgr
    if Game:IsValid(uItemDropMgr) then
      if bNeedDropAtBegin == nil or bNeedDropAtBegin == true then
        uAIController:ForceDropItemsWithTypeList({
          1,
          2,
          3,
          5,
          6
        })
      end
      if uAIController.SpawnItemForAIByDropID then
        uAIController:SpawnItemForAIByDropID(nDropID)
      else
        local FDropItemConfig = import("DropItemConfig")
        local FDropPropData = import("DropPropData")
        local DropCfg = slua.Array(UEnums.EPropertyClass.Struct, FDropItemConfig)
        local ItemList = slua.Array(UEnums.EPropertyClass.Struct, FDropPropData)
        uItemDropMgr:GetDropItemCfgList(DropCfg, nDropID)
        for _, uDropCfg in pairs(DropCfg) do
          uItemDropMgr:CalcDropItemListByDropCfg(uDropCfg, ItemList)
        end
        for _, uDropPropData in pairs(ItemList) do
          printf(bWriteLog and string.format("[MLAIProcessUtil]SpawnItemForAIByDropID Add item %s * %d for AI=%s(%s)", tostring(uDropPropData.ItemID), tostring(uDropPropData.ItemCount), tostring(uAIController.PlayerKey), tostring(uAIController.PlayerName)))
          uAIController:AddItemForAI(uDropPropData.ItemID, uDropPropData.ItemCount, uDropPropData.bDropOnDead, uDropPropData.DropMode == 4, false)
        end
      end
    end
  end
end
function MLAIProcessUtil:SpawnItemForAIByItemList(uAIController, AIBagItemList, bNeedDropAtBegin, bNeedCheckEquipment)
  if Game:IsValid(uAIController) and Game:IsAIController(uAIController) then
    local uItemDropMgr = CGameMode.BP_ItemDropMgr
    if Game:IsValid(uItemDropMgr) then
      if bNeedDropAtBegin == nil or bNeedDropAtBegin == true then
        uAIController:ForceDropItemsWithTypeList({
          1,
          2,
          3,
          5,
          6
        })
        uAIController.FrameRequiredPickUpList:Clear()
        uAIController.FrameOptionPickUpList:Clear()
        uAIController.FrameBattleItemPickUpInfoList:Clear()
        uAIController.FrameOptionBattleItemPickUpInfoList:Clear()
      end
      local tCanEquipInfo = {}
      if bNeedCheckEquipment then
        tCanEquipInfo = uAIController:GetCanEquipInfo()
      end
      for Index = #AIBagItemList, 1, -1 do
        local BagItem = AIBagItemList[Index]
        local nItemType = BackpackUtils.GetItemType(BagItem.item_id)
        if nItemType == 5 then
          nItemType = BackpackUtils.GetItemSubType(BagItem.item_id)
          if nItemType == 501 and tCanEquipInfo[nItemType] and 0 < tCanEquipInfo[nItemType] then
            printf("[MLAIProcessUtil] SpawnItemForAIByItemList Add item %s * %d for AI %s", tostring(BagItem.item_id), tostring(BagItem.item_num), uAIController.PlayerName)
            uAIController:AddItemForAI(BagItem.item_id, BagItem.item_num, true, false, true)
            table.remove(AIBagItemList, Index)
            break
          end
        end
      end
      for _, BagItem in ipairs(AIBagItemList) do
        local bCanAdd = true
        local nItemId = BagItem.item_id
        local nItemNum = BagItem.item_num
        if bNeedCheckEquipment then
          local nItemType = BackpackUtils.GetItemType(BagItem.item_id)
          if nItemType == 5 then
            nItemType = BackpackUtils.GetItemSubType(BagItem.item_id)
          end
          local nItemSubType = BackpackUtils.GetItemSubType(BagItem.item_id)
          if nItemType == 1 and (nItemSubType == 108 or nItemSubType == 106) then
            nItemType = nItemSubType
          end
          if tCanEquipInfo[nItemType] then
            if tCanEquipInfo[nItemType] <= 0 then
              bCanAdd = false
            else
              nItemNum = math.min(tCanEquipInfo[nItemType], nItemNum)
              tCanEquipInfo[nItemType] = tCanEquipInfo[nItemType] - nItemNum
            end
          end
        end
        if bCanAdd then
          printf("[MLAIProcessUtil] SpawnItemForAIByItemList Add item %s * %d for AI %s", tostring(BagItem.item_id), tostring(BagItem.item_num), uAIController.PlayerName)
          uAIController:AddItemForAI(BagItem.item_id, BagItem.item_num, true, false, false)
        else
          print(bWriteLog and string.format("[MLAIProcessUtil] SpawnItemForAIByItemList Cannot Add item %s * %d for AI %s", tostring(BagItem.item_id), tostring(BagItem.item_num), uAIController.PlayerName))
        end
      end
    end
  end
end
function MLAIProcessUtil:SetAILevel(uAIController, nLevel)
  if not (slua.isValid(uAIController) and nLevel) or nLevel <= 0 then
    return
  end
  local DSAITLogSubsystem = SubsystemMgr:Get("DSAITLogSubsystem")
  if uAIController.SetAILevel then
    if DSAITLogSubsystem then
      DSAITLogSubsystem:AddAIDebugInfo(uAIController.PlayerKey, 9, string.format("%d-%d", uAIController:GetAILevel(), nLevel))
    end
    uAIController:SetAILevel(nLevel)
  else
    local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
    if MLAIProcessSubSystem then
      local uMLAIControllerComp = MLAIProcessSubSystem:GetMLAIControllerComponentWithID(uAIController.PlayerKey)
      if uMLAIControllerComp then
        if DSAITLogSubsystem then
          DSAITLogSubsystem:AddAIDebugInfo(uAIController.PlayerKey, 9, string.format("%d-%d", uMLAIControllerComp:GetAILevel(), nLevel))
        end
        uMLAIControllerComp:SetAILevel(nLevel)
      end
    end
  end
end
function MLAIProcessUtil:GetRealPlayerNum()
  local RealPlayerNum = 0
  local uPawns = Game:GetAllPlayerPawns()
  for _, uPawn in pairs(uPawns) do
    if Game:IsPlayer(uPawn) and not uPawn:IsDroneActor() then
      RealPlayerNum = RealPlayerNum + 1
    end
  end
  return RealPlayerNum
end
function MLAIProcessUtil:GetMappingID()
  if _G.MapID then
    local mapConfig = CDataTable.GetTableData("Map", _G.MapID)
    if mapConfig ~= nil then
      return mapConfig.MappingID
    end
  end
  return nil
end
function MLAIProcessUtil:TryEnterNearZipline(uCharacter)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local ECollisionChannel = import("ECollisionChannel")
  local ActorClass = import("/Script/Engine.Actor")
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  ActorsToIgnore:Add(uCharacter)
  local ZiplineClass = import("/Game/Mod/Ninja/BluePrints/Actor/NinjaZipline/BP_NinjaZiplineAnchor.BP_NinjaZiplineAnchor_C")
  local CharLoc = uCharacter:K2_GetActorLocation()
  local ECC_Trigger = 18
  local CheckObjectTypes = {
    Game:ConvertToObjectType(ECC_Trigger)
  }
  local bHit, uOverlapObjectsArr = KismetSystemLibrary.CapsuleOverlapActors(CGameMode, CharLoc, 40, 88, CheckObjectTypes, ZiplineClass, ActorsToIgnore, nil)
  if uOverlapObjectsArr:Num() <= 0 then
    return
  end
  local uZiplineAnchor = uOverlapObjectsArr:Get(0)
  if slua.isValid(uZiplineAnchor) then
    uZiplineAnchor:MustCheckResultAfterServerClick(uCharacter, true)
  end
end
function MLAIProcessUtil:MergeToPureTable(InfoTable, ...)
  if type(InfoTable) ~= "table" then
    print(bWriteLog and "MLAIProcessUtil:MergeToPureTable InfoTable is not table")
    return InfoTable
  end
  local MergeResult = true
  local utility = require("common.utility")
  for _, StructInfo in ipairs({
    ...
  }) do
    xpcall(function()
      InfoTable = slua.MergeToPureTable(InfoTable, StructInfo)
    end, function(msg, category)
      print(bWriteLog and "[error]MLAIProcessUtil:MergeToPureTable MergeError")
      utility.ErrorMessageHandler(msg, category)
      MergeResult = false
    end)
    if MergeResult == false then
      return InfoTable, MergeResult
    end
  end
  return InfoTable, MergeResult
end
function MLAIProcessUtil:GetEnterStateTime(sState)
  local UAIActingComponent = CGameMode:GetComponentByClass(import("/Script/ShadowTrackerExtra.AIActingComponent"))
  if UAIActingComponent and UAIActingComponent.EnterStateTime and UAIActingComponent.EnterStateTime[sState] then
    return UAIActingComponent.EnterStateTime[sState]
  end
  return 0
end
function MLAIProcessUtil:GetEnterStateMilliseconds(sState)
  local UAIActingComponent = CGameMode:GetComponentByClass(import("/Script/ShadowTrackerExtra.AIActingComponent"))
  if UAIActingComponent and UAIActingComponent.EnterStateMilliseconds and UAIActingComponent.EnterStateMilliseconds[sState] then
    return UAIActingComponent.EnterStateMilliseconds[sState]
  end
  return 0
end
function MLAIProcessUtil:IsTeammateMLAI(nPlayerKey)
  local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
  if MLAIProcessSubSystem then
    local uTeammateMLAIControllerComp = MLAIProcessSubSystem:GetTeammateMLAIControllerComponentWithID(nPlayerKey)
    if slua.isValid(uTeammateMLAIControllerComp) then
      return true
    end
  end
  return false
end
function MLAIProcessUtil:ChangeTeammateMLAIVoiceState(uPlayerState, bState)
  local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerState then
    for _, uTeammatePlayerState in pairs(TeammatePlayerState) do
      if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.TeammateTakeOverFeature and uTeammatePlayerState.TeammateTakeOverFeature.bAITakeOver == false then
        local uPlayerController = uTeammatePlayerState:GetOwner()
        if slua.isValid(uPlayerController) and uPlayerController.MLAIVoiceFeature then
          uPlayerController.MLAIVoiceFeature:ChangeMLAIVoiceState(bState)
        end
      end
    end
  end
end
function MLAIProcessUtil:ChangeAllTeammateMLAIVoiceState(uPlayerState, bState)
  if not slua.isValid(uPlayerState) or bState == nil then
    print(bWriteLog and string.format("MLAIProcessUtil:ChangeAllTeammateMLAIVoiceState, error params"))
    return
  end
  print(bWriteLog and string.format("MLAIProcessUtil:ChangeAllTeammateMLAIVoiceState, bState=%s", tostring(bState)))
  if CGameMode and CGameMode.PlayerNumPerTeam == 1 then
    local uPlayerController = uPlayerState:GetOwner()
    if slua.isValid(uPlayerController) and uPlayerController.MLAIVoiceFeature then
      uPlayerController.MLAIVoiceFeature:ChangeMLAIVoiceState(bState)
      print(bWriteLog and string.format("MLAIProcessUtil:ChangeAllTeammateMLAIVoiceState, ChangeMLAIVoiceState"))
    end
    return
  end
  local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, false)
  if TeammatePlayerState then
    for _, uTeammatePlayerState in pairs(TeammatePlayerState) do
      if slua.isValid(uTeammatePlayerState) then
        local uPlayerController = uTeammatePlayerState:GetOwner()
        if slua.isValid(uPlayerController) and uPlayerController.MLAIVoiceFeature then
          uPlayerController.MLAIVoiceFeature:ChangeMLAIVoiceState(bState)
        end
      end
    end
  end
end
function MLAIProcessUtil:ChangeAllyMasterID(uMLAIControllerComponent, nMasterID, nRSTSSceneName)
  if slua.isValid(uMLAIControllerComponent) then
    local nOldMasterID = uMLAIControllerComponent:GetAllyMasterID()
    if nOldMasterID == nMasterID then
      return
    end
    uMLAIControllerComponent:SetAllyMasterID(nMasterID)
    self:SetRSTSSubtitleState(nOldMasterID, "None")
    self:SetRSTSSubtitleState(nMasterID, nRSTSSceneName)
  end
end
function MLAIProcessUtil:SetRSTSSubtitleState(nPlayerKey, nRSTSSceneName)
  if nPlayerKey == nil or nRSTSSceneName == nil then
    print(bWriteLog and string.format("MLAIProcessUtil:SetRSTSSubtitleState - error params"))
    return
  end
  local uPlayerController = Game:GetPlayerControllerByPlayerKey(nPlayerKey)
  if slua.isValid(uPlayerController) and uPlayerController.MLAIVoiceFeature then
    uPlayerController.MLAIVoiceFeature:SetRSTSSubtitleSceneName(nRSTSSceneName, "DS Open")
  end
end
function MLAIProcessUtil:SendStringOnlyReplay(uPlayerController, sInText, bIncludeTeammate)
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "MLAIProcessUtil:SendStringOnlyReplay MLAIVoiceFeature:RPC_Server_SendRSTSSubtitleText, uPlayerController is nil")
    return
  end
  if not uPlayerController.GetChatComponent then
    print(bWriteLog and "MLAIProcessUtil:SendStringOnlyReplay MLAIVoiceFeature:RPC_Server_SendRSTSSubtitleText, uPlayerController.GetChatComponent is nil")
    return
  end
  local FInGameChatMsg = import("InGameChatMsg")
  local InGameChatMsg = FInGameChatMsg()
  InGameChatMsg.msgContent = sInText or ""
  InGameChatMsg.playerName = uPlayerController.PlayerName
  InGameChatMsg.playerIdentifier = uPlayerController.PlayerKey
  if not uPlayerController.GetChatComponent then
    return
  end
  local uChatComponent = uPlayerController:GetChatComponent()
  if not slua.isValid(uChatComponent) then
    print(bWriteLog and "MLAIProcessUtil:SendStringOnlyReplay MLAIVoiceFeature:RPC_Server_SendRSTSSubtitleText, uChatComponent is nil")
    return
  end
  uChatComponent:ClientReceiveMsgReplayOnly(InGameChatMsg, true, 0)
  local uPlayerState = uPlayerController.PlayerState
  if slua.isValid(uPlayerState) and bIncludeTeammate == true then
    local TeammatePlayerState = uPlayerState:GetTeamMatePlayerStateList({}, true)
    if TeammatePlayerState then
      for _, uTeammatePlayerState in pairs(TeammatePlayerState) do
        if slua.isValid(uTeammatePlayerState) then
          local uTeammatePlayerController = uTeammatePlayerState:GetOwner()
          if slua.isValid(uTeammatePlayerController) then
            local uTeammateChatComponent = uTeammatePlayerController:GetChatComponent()
            if slua.isValid(uTeammateChatComponent) then
              uTeammateChatComponent:ClientReceiveMsgReplayOnly(InGameChatMsg, false, 0)
            end
          end
        end
      end
    end
  end
end
function MLAIProcessUtil:CheckNearbyVehicle(uCenterLocation, nRange, tVehicleTypeList)
  if uCenterLocation and nRange and 0 < nRange and tVehicleTypeList and 0 < #tVehicleTypeList then
    local uNearbyVehicles = Game:QueryVehicles(uCenterLocation, nRange)
    for _, uVehicle in pairs(uNearbyVehicles) do
      if slua.isValid(uVehicle) and TableUtil.Find(tVehicleTypeList, uVehicle.VehicleShapeType) ~= -1 then
        return true
      end
    end
  end
  return false
end
function MLAIProcessUtil:IsClassicRankMode(BattleType)
  return BattleType == 101 or BattleType == 102 or BattleType == 103 or BattleType == 401 or BattleType == 402 or BattleType == 403
end
function MLAIProcessUtil:GotoNextRound(DelayTime, fCallback)
  local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
  if not MLAIProcessSubSystem then
    print(bWriteLog and "MLAIProcessUtil:GotoNextRound, MLAIProcessSubSystem is nil")
    return
  end
  print(bWriteLog and "MLAIProcessUtil:GotoNextRound, Stop MLAIProcessSusSystem")
  MLAIProcessSubSystem:StopGame(CGameMode.MlAIType)
  self.RestartTimerHandle = Game:SetTimer(DelayTime, false, function()
    if MLAIProcessSubSystem then
      if MLAIProcessSubSystem.RoundID == nil then
        MLAIProcessSubSystem.RoundID = 1
      end
      MLAIProcessSubSystem.RoundID = MLAIProcessSubSystem.RoundID + 1
      print(bWriteLog and "MLAIProcessUtil:GotoNextRound, Start MLAIProcessSusSystem, RoundID: " .. MLAIProcessSubSystem.RoundID)
      MLAIProcessSubSystem.GameWasStoped[CGameMode.MlAIType] = false
      print(bWriteLog and "MLAIProcessUtil:GotoNextRound, GameWasStoped: ", MLAIProcessSubSystem.GameWasStoped[CGameMode.MlAIType])
      if Server and DSUtils then
        Server.InitAIProxyNet(DSUtils)
      end
    end
    if self.RestartTimerHandle then
      Game:ClearTimer(self.RestartTimerHandle)
      self.RestartTimerHandle = nil
    end
    if fCallback then
      fCallback()
    end
  end)
end
function MLAIProcessUtil:ChangeMLAISilentState(nBotID, bSilent, nBotType, Style, nTargetPlayerKey)
  print(bWriteLog and "MLAIProcessUtil:ChangeMLAISilentState - Start changing MLAI silent state")
  if not nBotID then
    print(bWriteLog and "MLAIProcessUtil:ChangeMLAISilentState - Invalid Bot ID")
    return
  end
  local MLAIProcessSubSystem = SubsystemMgr:Get("MLAIProcessSubSystem")
  if not MLAIProcessSubSystem then
    print(bWriteLog and "MLAIProcessUtil:ChangeMLAISilentState - MLAIProcessSubSystem not found")
    return
  end
  MLAIProcessSubSystem:ChangeMLAISilentState(nBotID, bSilent, nBotType, Style, nTargetPlayerKey)
  print(bWriteLog and string.format("MLAIProcessUtil:ChangeMLAISilentState - MLAI silent state changed, BotID:%s, Silent:%s", tostring(nBotID), tostring(bSilent)))
end
return MLAIProcessUtil
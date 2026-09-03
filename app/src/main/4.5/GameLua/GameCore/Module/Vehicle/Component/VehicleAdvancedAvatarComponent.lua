local VehicleAdvancedAvatarComponent = {}
local EVehicleSlotType = import("EVehicleSlotType")
local EMeshType = import("EMeshType")
local VAHColorBPBasePath = "/Game/BluePrints/Avatar/VehicleCustom/VAH_Color_BP_Base.VAH_Color_BP_Base_C"
local VAHPatternBPBasePath = "/Game/BluePrints/Avatar/VehicleCustom/VAH_Pattern_BP_Base.VAH_Pattern_BP_Base_C"
local SlotTypeToMeshTypeCfg = {
  [EVehicleSlotType.EVehicleSlotType_NONE] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Body] = EMeshType.Skeletal,
  [EVehicleSlotType.EVehicleSlotType_Bonnet] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Wheel] = EMeshType.Skeletal,
  [EVehicleSlotType.EVehicleSlotType_FrontBumper] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_TailBumper] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Empennage] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Skirt] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Interior] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Roof] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_Exhaust] = EMeshType.Static,
  [EVehicleSlotType.EVehicleSlotType_MaxSlotNum] = EMeshType.Static
}
function VehicleAdvancedAvatarComponent:ReceiveEndPlay(EndReason, bClearTable)
  print(bWriteLog and "VehicleAdvancedAvatarComponent:ReceiveEndPlay")
  self:ClearStyleDataCache()
  VehicleAdvancedAvatarComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function VehicleAdvancedAvatarComponent:GetReflectionCubeName_Lobby()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraId = Lobby_camera_manager_module:GetCurrentCameraID()
  return tostring(cameraId)
end
function VehicleAdvancedAvatarComponent:CreateCustomColor(InInt)
  if not InInt then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomColor InInt is invalid")
    return nil
  end
  local VehicleRefitColorCfg = CDataTable.GetTableData("VehicleRefitColorTable", InInt)
  if not VehicleRefitColorCfg then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomColor VehicleRefitColorCfg is invalid")
    return nil
  end
  local ColorBP = CGame:NewObjectFromPath(VAHColorBPBasePath, self)
  if not (slua.isValid(ColorBP) and ColorBP.SetCustomID) or not ColorBP.InitColorInfo then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomColor ColorBP is invalid")
    return nil
  end
  ColorBP:SetCustomID(VehicleRefitColorCfg.ID)
  ColorBP:InitColorInfo(VehicleRefitColorCfg.Gray, VehicleRefitColorCfg.Color1, VehicleRefitColorCfg.Color2, VehicleRefitColorCfg.Color3)
  return ColorBP
end
function VehicleAdvancedAvatarComponent:CreateCustomPattern(InInt)
  if not InInt then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomPattern InInt is invalid")
    return
  end
  local VehicleRefitPatternCfg = CDataTable.GetTableData("VehicleRefitPatternTable", InInt)
  if not VehicleRefitPatternCfg then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomPattern VehicleRefitPatternCfg is invalid")
    return
  end
  local PatternBP = CGame:NewObjectFromPath(VAHPatternBPBasePath, self)
  if not (slua.isValid(PatternBP) and PatternBP.SetCustomID) or not PatternBP.InitPatternInfo then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomPattern PatternBP is invalid")
    return
  end
  PatternBP:SetCustomID(VehicleRefitPatternCfg.ID)
  PatternBP:InitPatternInfo(VehicleRefitPatternCfg.IconScale1, VehicleRefitPatternCfg.IconScale2, VehicleRefitPatternCfg.IconPath1, VehicleRefitPatternCfg.IconPath2, VehicleRefitPatternCfg.IconOffset)
  return PatternBP
end
function VehicleAdvancedAvatarComponent:CreateCustomParticle(InInt)
  if not InInt then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomParticle InInt is invalid")
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local HandleClass = BackpackUtils.GetBattleItemHandleIfPakExist("VehicleRefitParticle", InInt, self.bIsLobbyAvatar, false)
  if not HandleClass then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomParticle HandleClass is invalid")
    return
  end
  local ParticleHandle = HandleClass()
  if not slua.isValid(ParticleHandle) or not ParticleHandle.SetCustomID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent:CreateCustomParticle ParticleHandle is invalid")
    return
  end
  ParticleHandle:SetCustomID(InInt)
  return ParticleHandle
end
function VehicleAdvancedAvatarComponent:PutOffSlotInLobby(InSlotType)
  if not InSlotType then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOffSlotInLobby InSlotType is invalid")
    return false
  end
  if not self.VehicleSkinID or self.VehicleSkinID == 0 then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOffSlotInLobby VehicleSkinID is invalid")
    return false
  end
  return self:HandleUnequipSlot(InSlotType)
end
function VehicleAdvancedAvatarComponent:PutOnItemIDInLobby(InItemID, ColorID, PatternID, ParticleID)
  if not InItemID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOnItemIDInLobby param is invalid")
    return false
  end
  local VehicleRefitBPInfo = CDataTable.GetTableData("VehicleRefitBPTable", InItemID)
  if not VehicleRefitBPInfo then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOnItemIDInLobby VehicleRefitBPInfo is invalid")
    return false
  end
  local AvatarCustom = FAvatarCustom(self.CustomType, ColorID, PatternID, 0, ParticleID)
  local ItemDefineID = FItemDefineID(self.ItemType, InItemID)
  return self:HandleEquipItem(ItemDefineID, AvatarCustom)
end
function VehicleAdvancedAvatarComponent:PutOffItemIDInLobby(InItemID)
  if not InItemID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOffItemIDInLobby param is invalid")
    return false
  end
  if not self.VehicleSkinID or self.VehicleSkinID == 0 then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOffItemIDInLobby VehicleSkinID is invalid")
    return false
  end
  local VehicleRefitBPInfo = CDataTable.GetTableData("VehicleRefitBPTable", InItemID)
  if not VehicleRefitBPInfo then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: PutOffItemIDInLobby VehicleRefitBPInfo is invalid")
    return false
  end
  local ItemDefineID = FItemDefineID(self.ItemType, InItemID)
  return self:HandleUnequipItem(ItemDefineID)
end
function VehicleAdvancedAvatarComponent:InitVehicleAvatarBySkinID_Old(InVehicleSkinID)
  if not InVehicleSkinID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: InitVehicleAvatarBySkinID_Old param is invalid")
    return false
  end
  self.Super:InitVehicleAvatarBySkinID_Old(InVehicleSkinID)
  local ret = self:GenerateDefaultAvatarConfig(self.VehicleSkinID)
  if not ret then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: InitVehicleAvatarBySkinID_Old ret is false")
    return false
  end
  local FVehicleAvatarData = import("VehicleAvatarData")
  local VehicleAvatarData = FVehicleAvatarData()
  VehicleAvatarData.VehicleSkinID = self.VehicleSkinID
  VehicleAvatarData.VehicleStyleIDList = self.DefaultStyleIDList
  return self:InitVehicleAvatar(VehicleAvatarData, false)
end
function VehicleAdvancedAvatarComponent:GenerateDefaultAvatarConfig(InBaseSkinID)
  log(bWriteLog and "VehicleAdvancedAvatarComponent:GenerateDefaultAvatarConfig InBaseSkinID: " .. tostring(InBaseSkinID))
  if not InBaseSkinID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: GenerateDefaultAvatarConfig param is invalid")
    return false
  end
  local uAvatarUtils = import("AvatarUtils")
  local BPUtils = uAvatarUtils.GetBPUtils()
  local bRet, outStleIdList = BPUtils:GetVehicleDefaultStyleID(InBaseSkinID)
  if not bRet then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: GenerateDefaultAvatarConfig ret is false")
    return false
  end
  self.DefaultStyleIDList = outStleIdList
  self.DefaultAvataConfig:Clear()
  if not self.styleDataCache then
    self.styleDataCache = {}
  end
  for _, v in ipairs(outStleIdList) do
    local vehicleStyleData = self.styleDataCache[v] or self:MakeVehicleStyleData(v)
    if vehicleStyleData then
      self.styleDataCache[v] = vehicleStyleData
      local itemSpecificId = self:IsStyleHasModelConfig(vehicleStyleData)
      if itemSpecificId and itemSpecificId ~= 0 then
        local ItemDefineID = FItemDefineID(self.ItemType, itemSpecificId)
        self.DefaultAvataConfig:Add(v, ItemDefineID)
      end
    end
  end
  return true
end
function VehicleAdvancedAvatarComponent:MakeVehicleStyleData(InStyleID)
  if not InStyleID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: MakeVehicleStyleData InStyleID is invalid")
    return nil
  end
  local StyleDataList = {}
  local VehicleRefitStyleCfg = CDataTable.GetTableData("VehicleRefitStyle", InStyleID)
  if not VehicleRefitStyleCfg then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: MakeVehicleStyleData VehicleRefitStyleCfg is invalid")
    return nil
  end
  local FVehicleStyle = import("VehicleStyle")
  local VehicleStyle = FVehicleStyle()
  VehicleStyle.StyleType = VehicleRefitStyleCfg.type1
  VehicleStyle.StyleValue = VehicleRefitStyleCfg.value1
  StyleDataList[1] = VehicleStyle
  if VehicleRefitStyleCfg.value2 and VehicleRefitStyleCfg.value2 ~= 0 then
    local SecondVehicleStyle = FVehicleStyle()
    SecondVehicleStyle.StyleType = VehicleRefitStyleCfg.type2
    SecondVehicleStyle.StyleValue = VehicleRefitStyleCfg.value2
    StyleDataList[2] = SecondVehicleStyle
  end
  local FVehicleStyleData = import("VehicleStyleData")
  FVehicleStyleData = FVehicleStyleData()
  FVehicleStyleData.StyleID = InStyleID
  FVehicleStyleData.SlotType = VehicleRefitStyleCfg.real_part
  FVehicleStyleData.MutilStyles = StyleDataList
  return FVehicleStyleData
end
function VehicleAdvancedAvatarComponent:BPCreateAvatarCustomHandle(SlotID, ItemID, InCostomInfo)
  local TArray = slua.Array
  local UAvatarCustomBase = import("AvatarCustomBase")
  local ResultTarray = TArray(UEnums.EPropertyClass.Object, UAvatarCustomBase)
  if not InCostomInfo then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: BPCreateAvatarCustomHandle InCostomInfo is invalid")
    return ResultTarray
  end
  if InCostomInfo.ColorID and InCostomInfo.ColorID ~= 0 then
    local ColorObj = self:CreateCustomColor(InCostomInfo.ColorID)
    if ColorObj then
      ResultTarray:Add(ColorObj)
    end
  end
  if InCostomInfo.PatternID and InCostomInfo.PatternID ~= 0 then
    local PatternObj = self:CreateCustomPattern(InCostomInfo.PatternID)
    if PatternObj then
      ResultTarray:Add(PatternObj)
    end
  end
  if InCostomInfo.ParticleID and InCostomInfo.ParticleID ~= 0 then
    local ParticleObj = self:CreateCustomParticle(InCostomInfo.ParticleID)
    if ParticleObj then
      ResultTarray:Add(ParticleObj)
    end
  end
  return ResultTarray
end
function VehicleAdvancedAvatarComponent:BPGetSlotMeshType(InSlotID, InSubSlotID, InItemHandle)
  if not InSlotID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: BPGetSlotMeshType InSlotID is invalid")
    return EMeshType.None
  end
  return SlotTypeToMeshTypeCfg[InSlotID] or EMeshType.None
end
function VehicleAdvancedAvatarComponent:BPProcessStyleUnequipped(OldStyleID)
  if not OldStyleID then
    log(bWriteLog and "Error-VehicleAdvancedAvatarComponent: BPProcessStyleUnequipped OldStyleID is invalid")
    return
  end
  if not self.styleDataCache then
    self.styleDataCache = {}
  end
  local oldVehicleStyleData = self.styleDataCache[OldStyleID] or self:MakeVehicleStyleData(OldStyleID)
  if oldVehicleStyleData then
    self.styleDataCache[OldStyleID] = oldVehicleStyleData
  end
  local oldItemSpecificId = oldVehicleStyleData and self:IsStyleHasModelConfig(oldVehicleStyleData)
  for _, v in ipairs(self.DefaultStyleIDList) do
    local styleData = self.styleDataCache[v] or self:MakeVehicleStyleData(v)
    if styleData then
      self.styleDataCache[v] = styleData
      local specificId = self:IsStyleHasModelConfig(styleData)
      if oldItemSpecificId and oldItemSpecificId ~= 0 and specificId and specificId ~= 0 and self:HandleEquipStyle(v) then
        log_format("VehicleAdvancedAvatarComponent:BPProcessStyleUnequipped HandleEquipStyle success, styleID:%s", v)
        break
      end
    end
  end
end
function VehicleAdvancedAvatarComponent:ClearStyleDataCache()
  if self.styleDataCache then
    self.styleDataCache = {}
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CVehicleAdvancedAvatarComponent = class(CActorComponentBase, nil, VehicleAdvancedAvatarComponent)
return CVehicleAdvancedAvatarComponent
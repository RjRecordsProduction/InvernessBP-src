local CustomAssetImageManager = {}
local EMountStatus = import("EMountStatus")
local UAETableManager = import("UAETableManager")
local CustomAssetDefine = require("common.CustomAsset.CustomAssetDefine")
local CustomAssetTextureUtil = require("common/CustomAsset/CustomImage/CustomAssetTextureUtil")
local CreativeManagerTools = require("GameLua.Mod.CreativeBase.Gameplay.Common.CreativeManagerTools")
local CreativeIconConfig = require("GameLua/Mod/CreativeBase/Gameplay/Config/CreativeIconConfig")
local CreativeModeSelectorIconConfig = require("GameLua.Mod.CreativeBase.Gameplay.Config.CreativeModeSelectorIconConfig")
local TempTexture = "Texture2D'/Game/Arts/UI/NoAtlas/Gray_BG.Gray_BG'"
local TEST = _G.IsEditor
local ConfigIndex = {IconConfig = 1, LuaConfig = 2}
function CustomAssetImageManager:ctor(_)
  self.HasID2Images = {}
  self.AssetKey2HashID = {}
  self.LoadHandler = {}
  self.RegistedIconID = {}
end
function CustomAssetImageManager:OnFightingStatusEnter()
  print(bWriteLog and "CustomAssetImageManager:OnFightingStatusEnter")
  local IsServer = self.CustomAssetMgr:IsDedicatedServer()
  print(bWriteLog and "CustomAssetImageManager:OnFightingStatusEnter IsServer:" .. tostring(IsServer))
  if not IsServer then
    self.TempTexture = slua.loadObject(TempTexture)
    local IsTempTextureValid = slua.isValid(self.TempTexture)
    local TempTextureFormat
    if IsTempTextureValid then
      slua.addRef(self.TempTexture)
      TempTextureFormat = CustomAssetTextureUtil.ReadTextureFormat(self.TempTexture)
    end
    print(bWriteLog and "CustomAssetImageManager:OnFightingStatusEnter TempTextureValid:" .. tostring(IsTempTextureValid) .. " PixelFormat:" .. tostring(TempTextureFormat))
    local Dependencies = self:GrabDependentAssets()
    self:AccommodateByList(Dependencies)
    self:AddCommonEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_CUSTOM_ASSET_MOUNT_STATE_CHANGE, self.OnMountStateChange, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_FIRST_META_COMPLETE, self.OnPrefabMallDataSync, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_MODIFY, self.OnPrefabMallDataSync, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_META_SILENT_UPDATES, self.OnPrefabMallDataSync, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_META_UPDATES, self.OnPrefabMallDataSync, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_DEL_UPDATE, self.OnPrefabMallDataSync, self)
    self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_CREATIVE_PREFAB_MALL_MY_ADDED_DATA_BATCH_DEL, self.OnPrefabMallDataSync, self)
  end
end
function CustomAssetImageManager:OnFightingStatusPreExit()
  print(bWriteLog and "CustomAssetImageManager:OnFightingStatusPreExit")
  self:DynamicUnregisterAllConfig()
  self.HasID2Images = {}
  self.AssetKey2HashID = {}
  for _, Handler in pairs(self.LoadHandler) do
    self.CustomAssetMgr:CancelLoadCustomAsset(Handler)
  end
  self.LoadHandler = {}
  if slua.isValid(self.TempTexture) then
    slua.removeRef(self.TempTexture)
  end
  self.TempTexture = nil
end
function CustomAssetImageManager:OnMountStateChange(_, _, AssetKey)
  if not self:IsCustomImage(AssetKey) then
    return
  end
  local LuaCustomAssetMountStatusInfoDefine = self.CustomAssetMgr:GetCustomAssetMountedInfo(AssetKey)
  if LuaCustomAssetMountStatusInfoDefine == nil then
    self:DynamicUnregisterConfig(AssetKey)
    return
  end
  if LuaCustomAssetMountStatusInfoDefine.MountStatus == EMountStatus.Mounting then
    self:Accommodate(AssetKey)
  elseif LuaCustomAssetMountStatusInfoDefine.MountStatus == EMountStatus.Mounted then
    local Handler
    Handler = self.CustomAssetMgr:AsyncLoadCustomAsset(AssetKey, function(ImageWrapperObject)
      if Handler then
        self.LoadHandler[AssetKey] = nil
      end
      if not slua.isValid(ImageWrapperObject) then
        return
      end
      local CompressedTexture_PB = ImageWrapperObject:GetImageData()
      self:UpdateTextureResource(AssetKey, CompressedTexture_PB)
    end)
    if Handler then
      self.LoadHandler[AssetKey] = Handler
    end
  elseif LuaCustomAssetMountStatusInfoDefine.MountStatus == EMountStatus.Unmounted then
    self:DynamicUnregisterConfig(AssetKey)
  end
end
function CustomAssetImageManager:GrabDependentAssets()
  print(bWriteLog and "CustomAssetImageManager:GrabDependentAssets")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC:IsUGCEditMod() then
    return {}
  else
    return self:GrabRuntimeDependentAssets()
  end
end
function CustomAssetImageManager:GrabEditModDependentAssets()
end
function CustomAssetImageManager:GrabRuntimeDependentAssets()
  print(bWriteLog and "CustomAssetImageManager:GrabRuntimeDependentAssets")
  local CustomAssetKeyList = {}
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local modID = LogicUGCMatch:GetMatchModID()
  if modID == 0 then
    log_warning(bWriteLog and "CustomAssetImageManager:GrabRuntimeDependentAssets no match modID")
    return CustomAssetKeyList
  end
  print(bWriteLog and "CustomAssetImageManager:GrabRuntimeDependentAssets modID:" .. tostring(modID))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfo = LogicUGC:GetModByAllCache(modID)
  local TableUtil = require("common.table_util")
  print(bWriteLog and "CustomAssetImageManager:GrabRuntimeDependentAssets ModInfo" .. TableUtil.TableToString(ModInfo or {}))
  if ModInfo and ModInfo.pub_mod_meta and ModInfo.pub_mod_meta.setting then
    print(bWriteLog and "CustomAssetImageManager:GrabRuntimeDependentAssets ModInfo.pub_mod_meta.setting" .. TableUtil.TableToString(ModInfo.pub_mod_meta.setting))
    CustomAssetKeyList = ModInfo.pub_mod_meta.setting.custom_asset_key_list
  end
  return CustomAssetKeyList
end
function CustomAssetImageManager:AccommodateByList(AssetKeys)
  if AssetKeys == nil then
    return
  end
  local BatchNum = 0
  for _, AssetKey in ipairs(AssetKeys) do
    if self:IsCustomImage(AssetKey) then
      print(bWriteLog and "CustomAssetImageManager:AccommodateByList AssetKey:" .. tostring(AssetKey))
      local HashID = self.CustomAssetMgr:GenerateCustomAssetKeyHashID(AssetKey)
      local ReservedTexture = self.HasID2Images[HashID]
      if not slua.isValid(ReservedTexture) then
        ReservedTexture = CustomAssetTextureUtil.LuaReserveTexture2(nil, nil, self.TempTexture)
        self.HasID2Images[HashID] = ReservedTexture
        self.AssetKey2HashID[AssetKey] = HashID
        BatchNum = BatchNum + 1
      end
      self:DynamicRegisterConfig(AssetKey)
    end
  end
  print(bWriteLog and "CustomAssetImageManager:AccommodateByList Num:" .. tostring(BatchNum))
end
function CustomAssetImageManager:Accommodate(AssetKey)
  if AssetKey == nil then
    return nil
  end
  print(bWriteLog and "CustomAssetImageManager:Accommodate AssetKey:" .. tostring(AssetKey))
  if self:IsCustomImage(AssetKey) then
    local HashID = self.CustomAssetMgr:GenerateCustomAssetKeyHashID(AssetKey)
    local ReservedTexture = self.HasID2Images[HashID]
    if not slua.isValid(ReservedTexture) then
      ReservedTexture = CustomAssetTextureUtil.LuaReserveTexture2(nil, nil, self.TempTexture)
      self.HasID2Images[HashID] = ReservedTexture
      self.AssetKey2HashID[AssetKey] = HashID
    end
    self:DynamicRegisterConfig(AssetKey)
    return ReservedTexture
  end
  return nil
end
function CustomAssetImageManager:DynamicRegisterConfig(AssetKey)
  if not AssetKey then
    return
  end
  local UTexture = self:GetUTextureByAssetKey(AssetKey)
  if not slua.isValid(UTexture) then
    print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig UTexture invalid AssetKey:" .. tostring(AssetKey))
    return
  end
  print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig AssetKey:" .. tostring(AssetKey))
  local HashID = self.AssetKey2HashID[AssetKey]
  if not HashID then
    print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig HashID invalid AssetKey:" .. tostring(AssetKey))
    return
  end
  if self.RegistedIconID[HashID] then
    print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig Repeat Register AssetKey:" .. tostring(AssetKey))
    return
  end
  local TexturePackagePath = CustomAssetTextureUtil.GetObjectPath(UTexture)
  print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig TexturePackagePath:" .. tostring(TexturePackagePath) .. " AssetKey:" .. tostring(AssetKey))
  if #TexturePackagePath <= 0 then
    return
  end
  self:LuaAddTextureRef(HashID, UTexture)
  local IconPath = TexturePackagePath
  local IconID = HashID
  self.RegistedIconID[IconID] = {false, false}
  CreativeIconConfig.RegisterDynamicIcon(IconID, IconPath)
  self.RegistedIconID[IconID][ConfigIndex.IconConfig] = true
  local Succeed = CreativeModeSelectorIconConfig.RegisterDynamicIcon(HashID, AssetKey, IconPath)
  if Succeed then
    self.RegistedIconID[IconID][ConfigIndex.LuaConfig] = true
  else
    print(bWriteLog and "CustomAssetImageManager:DynamicRegisterConfig CreativeModeSelectorIconConfig ID Conflict IconID:" .. tostring(IconID))
  end
end
function CustomAssetImageManager:DynamicUnregisterAllConfig()
  for IconID, Info in pairs(self.RegistedIconID) do
    if Info[ConfigIndex.IconConfig] then
      CreativeIconConfig.UnregisterDynamicIcon(IconID)
    end
    if Info[ConfigIndex.LuaConfig] then
      CreativeModeSelectorIconConfig.UnregisterDynamicIcon(IconID)
    end
    self:LuaRemoveTextureRef(IconID)
  end
  self.RegistedIconID = {}
end
function CustomAssetImageManager:DynamicUnregisterConfig(AssetKey)
  if not AssetKey then
    return
  end
  local HashID = self.AssetKey2HashID[AssetKey]
  if not HashID then
    return
  end
  if not self.RegistedIconID[HashID] then
    return
  end
  if self.RegistedIconID[HashID][ConfigIndex.IconConfig] == true then
    CreativeIconConfig.UnregisterDynamicIcon(HashID)
  end
  if self.RegistedIconID[HashID][ConfigIndex.LuaConfig] == true then
    CreativeModeSelectorIconConfig.UnregisterDynamicIcon(HashID)
  end
  self:LuaRemoveTextureRef(HashID)
  self.RegistedIconID[HashID] = nil
  local Handler = self.LoadHandler[AssetKey]
  if Handler then
    self.CustomAssetMgr:CancelLoadCustomAsset(Handler)
  end
end
function CustomAssetImageManager:OnPrefabMallDataSync()
  print(bWriteLog and "CustomAssetImageManager:OnPrefabMallDataSync")
  CreativeModeSelectorIconConfig.UpdateAllDynamicIconInfo()
end
function CustomAssetImageManager:GetUTextureByAssetKey(AssetKey)
  if AssetKey == nil then
    return nil
  end
  local HashID = self.AssetKey2HashID[AssetKey]
  if HashID == nil then
    return nil
  end
  return self.HasID2Images[HashID]
end
function CustomAssetImageManager:GetUTextureByID(HashID)
  if HashID == nil then
    return nil
  end
  return self.HasID2Images[HashID]
end
function CustomAssetImageManager:UpdateTextureResource(AssetKey, CompressedTexture_PB)
  if not self:IsCustomImage(AssetKey) then
    return
  end
  if CompressedTexture_PB == nil then
    print(bWriteLog and "CustomAssetImageManager:UpdateTextureResource PB struct illegal AssetKey:" .. tostring(AssetKey))
    return
  end
  local Texture = self:GetUTextureByAssetKey(AssetKey)
  if not slua.isValid(Texture) then
    print(bWriteLog and "CustomAssetImageManager:UpdateTextureResource Texture not exist AssetKey:" .. tostring(AssetKey))
    return
  end
  CustomAssetTextureUtil.LuaUpdateTextureResourceByPB(Texture, CompressedTexture_PB)
  local HashID = self.AssetKey2HashID[AssetKey]
  if HashID then
    CreativeModeSelectorIconConfig.UpdateDynamicIconInfo(HashID)
  end
end
function CustomAssetImageManager:IsCustomImage(AssetKey)
  if AssetKey == nil then
    return false
  end
  local CustomAssetInfoDefine = self.CustomAssetMgr:GetCustomAssetInfo(AssetKey)
  if CustomAssetInfoDefine and CustomAssetInfoDefine.AssetType == CustomAssetDefine.Enum_CustomAssetType.Image then
    return true
  end
  return false
end
function CustomAssetImageManager:LuaAddTextureRef(HashID, Texture)
  if slua.isValid(Texture) then
    slua.addRef(Texture)
  end
end
function CustomAssetImageManager:LuaRemoveTextureRef(HashID)
  local Texture = self:GetUTextureByID(HashID)
  if slua.isValid(Texture) then
    slua.removeRef(Texture)
  end
end
function CustomAssetImageManager:TestFlow(CompressedFileName, AssetKey)
  print(bWriteLog and "CustomAssetImageManager:TestFlow")
  CompressedFileName = Client.ProjectSavedDir() .. "ATestImageFlow/" .. CompressedFileName
  self:TestDecode(CompressedFileName, AssetKey)
end
function CustomAssetImageManager:ExportBinSummary()
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local CompressedFileName = Client.ProjectSavedDir() .. "ATestImageFlow/export.bin"
  local SummaryFile = Client.ProjectSavedDir() .. "ATestImageFlow/export.json"
  local Ktx2File = Client.ProjectSavedDir() .. "ATestImageFlow/export.ktx2"
  Client.DeleteFile(SummaryFile)
  Client.DeleteFile(Ktx2File)
  local Bin = CreativeModeBlueprintLibrary.LoadRawFileToString(CompressedFileName)
  if Bin then
    local pb = require("pb")
    local Ret = pb.loadfile("gamesrv_ds/customasset_client/texture.pb")
    local CompressedTexture = pb.decode("texcomp.CompressedTexture", Bin)
    if CompressedTexture then
      local data = CompressedTexture.data
      local metadata = json.encode(CompressedTexture.metadata)
      CreativeModeBlueprintLibrary.SaveRawStringToFile(data, Ktx2File)
      CreativeModeBlueprintLibrary.SaveRawStringToFile(metadata, SummaryFile)
    end
  end
end
function CustomAssetImageManager:TestEncode(CompressedFileName, AssetKey)
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  if CustomAssetTextureUtil.PlatformUseRowBinary() then
    local CompressedTexture = CreativeModeBlueprintLibrary.LoadRawFileToString(CompressedFileName)
    CreativeModeBlueprintLibrary.SaveRawStringToFile(CompressedTexture, CompressedFileName .. ".pb")
    return
  end
  local pb = require("pb")
  local Ret = pb.loadfile("gamesrv_ds/customasset_client/texture.pb")
  local TestTable = {
    metadata = {
      source_file = "Color_checker_8bit.png",
      source_format = 1,
      width = 512,
      height = 512,
      has_alpha = true,
      compression = 0,
      block_width = 4,
      block_height = 4,
      compressed_size = 0,
      original_size = 0,
      use_srgb = true
    },
    data = CreativeModeBlueprintLibrary.LoadRawFileToString(CompressedFileName)
  }
  local CompressedTexture = pb.encode("texcomp.CompressedTexture", TestTable)
  CreativeModeBlueprintLibrary.SaveRawStringToFile(CompressedTexture, CompressedFileName .. ".pb")
end
function CustomAssetImageManager:TestDecode(CompressedFileName, AssetKey)
  self:Accommodate(AssetKey)
  self:AddTimer(1, function()
    self:TestUpdate(CompressedFileName, AssetKey)
  end)
end
function CustomAssetImageManager:TestUpdate(CompressedFileName, AssetKey)
  print(bWriteLog and "CustomAssetImageManager:TestUpdate AssetKey:" .. tostring(AssetKey))
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local Bin = CreativeModeBlueprintLibrary.LoadRawFileToString(CompressedFileName)
  local pb = require("pb")
  local Ret = pb.loadfile("gamesrv_ds/customasset_client/texture.pb")
  local CompressedTexture = pb.decode("texcomp.CompressedTexture", Bin)
  local Texture = self:GetUTextureByAssetKey(AssetKey)
  local Width = CompressedTexture.metadata.width
  local Height = CompressedTexture.metadata.height
  local Format = 0
  local MipIndex = 0
  CustomAssetTextureUtil.LuaUpdateTextureResource2(Texture, CustomAssetTextureUtil.TextureGroup.UI, Width, Height, MipIndex, Format, CompressedTexture.data)
end
local class = require("class")
return class(require("common.CustomAsset.CustomAssetUtilityObject"), nil, CustomAssetImageManager)
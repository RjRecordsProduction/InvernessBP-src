local CustomAssetDefine = {}
CustomAssetDefine.HashIDMinValue = 4294967295
CustomAssetDefine.CustomAssetCacheFolder = "CustomAsset/"
CustomAssetDefine.CustomAssetSourceCacheFolder = "SourceCustomAsset/"
CustomAssetDefine.CustomAssetCacheMetaInfoFilePath = "CustomAssetCacheMetaInfo.bin"
CustomAssetDefine.CustomAssetCacheMetaInfoPath = "CustomAsset/" .. CustomAssetDefine.CustomAssetCacheMetaInfoFilePath
CustomAssetDefine.CustomAssetKeyTag = "CustomAsset"
CustomAssetDefine.DuplicateUploadErrCode = 412
CustomAssetDefine.DefaultAssetDataDirectory = "Templates/UGC/DefaultCustomAsset/"
CustomAssetDefine.DefaultSoundIcon = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/PrefabMall/Ugc_Goods_Sound_Icon.Ugc_Goods_Sound_Icon"
CustomAssetDefine.CustomAssetKeyHashIDTag = 165
CustomAssetDefine.MB = 1048576
CustomAssetDefine.DsMountableSizeLimit = 20 * CustomAssetDefine.MB
CustomAssetDefine.AutoMountSizeLimit = 2 * CustomAssetDefine.MB
CustomAssetDefine.MapDependencySizeLimit = 2 * CustomAssetDefine.MB
CustomAssetDefine.MountAttemptDownloadCountLimit = 1
CustomAssetDefine.WaitMappingTime = 5
CustomAssetDefine.DownloadTimeOut = 12
CustomAssetDefine.UploadTimeOut = 12
CustomAssetDefine.DownloadTimeoutCountLimit = 3
function CustomAssetDefine.GetCustomAssetCacheRelativePath(AssetKey, SuffixType)
  local BufferPath = CustomAssetDefine.CustomAssetCacheFolder .. tostring(AssetKey) .. "." .. tostring(SuffixType)
  return BufferPath
end
function CustomAssetDefine.GetCustomAssetCacheAbsolutePath(AssetKey, SuffixType)
  local UScriptGameplayStatics = import("ScriptGameplayStatics")
  local BufferPath = UScriptGameplayStatics.ProjectSavedDir() .. CustomAssetDefine.CustomAssetCacheFolder .. tostring(AssetKey) .. "." .. tostring(SuffixType)
  return BufferPath
end
function CustomAssetDefine.GetCustomAssetSourceCacheRelativePath(AssetKey, SuffixType)
  local BufferPath = CustomAssetDefine.CustomAssetSourceCacheFolder .. tostring(AssetKey) .. "." .. tostring(SuffixType)
  return BufferPath
end
function CustomAssetDefine.GetCustomAssetObjectKey(AssetKey, SuffixType)
  return CustomAssetDefine.CustomAssetCacheFolder .. tostring(AssetKey) .. "." .. tostring(SuffixType)
end
function CustomAssetDefine.ParseObjectKeyToAssetKeyAndSuffixType(ObjectKey)
  local prefix = CustomAssetDefine.CustomAssetCacheFolder
  if type(ObjectKey) ~= "string" then
    return nil, nil
  end
  if string.sub(ObjectKey, 1, #prefix) ~= prefix then
    return nil, nil
  end
  local rest = string.sub(ObjectKey, #prefix + 1)
  local dotpos = rest:find("%.[^%.]*$")
  if not dotpos then
    return nil, nil
  end
  local AssetKey = string.sub(rest, 1, dotpos - 1)
  local SuffixType = string.sub(rest, dotpos + 1)
  return AssetKey, SuffixType
end
CustomAssetDefine.CustomAssetParallelDownloadCount_DS = 1
CustomAssetDefine.CustomAssetParallelDownloadCount_Client = 10
CustomAssetDefine.CustomAssetParallelDownloadCount_ClientIngame = 2
CustomAssetDefine.ENUM_PREFAB_TYPE = {
  PREFAB = 1,
  CODE = 2,
  ANIM = 3,
  SOUND = 4,
  STATICMESH = 5,
  IMAGE = 6,
  CUSTOMUI = 8
}
CustomAssetDefine.CanMountAsset = {
  [CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM] = true
}
CustomAssetDefine.Enum_CustomAssetType = {
  None = 0,
  AIAnim = 1,
  StaticMesh = 2,
  BinaryAsset = 3,
  AISoundAsset = 4,
  Image = 5,
  Texture2D = 6
}
CustomAssetDefine.ENUM_PREFAB_TYPE_TO_CUSTOM_ASSET_TYPE = {
  [CustomAssetDefine.ENUM_PREFAB_TYPE.PREFAB] = CustomAssetDefine.Enum_CustomAssetType.BinaryAsset,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.CODE] = CustomAssetDefine.Enum_CustomAssetType.BinaryAsset,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM] = CustomAssetDefine.Enum_CustomAssetType.AIAnim,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.IMAGE] = CustomAssetDefine.Enum_CustomAssetType.Image,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.SOUND] = CustomAssetDefine.Enum_CustomAssetType.AISoundAsset,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.STATICMESH] = CustomAssetDefine.Enum_CustomAssetType.StaticMesh,
  [CustomAssetDefine.ENUM_PREFAB_TYPE.CUSTOMUI] = CustomAssetDefine.Enum_CustomAssetType.BinaryAsset
}
CustomAssetDefine.DependencyDisplayOrder = {
  CustomAssetDefine.Enum_CustomAssetType.AIAnim,
  CustomAssetDefine.Enum_CustomAssetType.AISoundAsset,
  CustomAssetDefine.Enum_CustomAssetType.Image
}
CustomAssetDefine.CustomAssetTypeName = {
  [CustomAssetDefine.Enum_CustomAssetType.AIAnim] = 99009832,
  [CustomAssetDefine.Enum_CustomAssetType.StaticMesh] = 99009888,
  [CustomAssetDefine.Enum_CustomAssetType.AISoundAsset] = 99009980,
  [CustomAssetDefine.Enum_CustomAssetType.Image] = 99009978
}
CustomAssetDefine.CustomAssetTypeColor = {
  [CustomAssetDefine.Enum_CustomAssetType.AIAnim] = FLinearColor(0.896, 0.314, 0.06, 1),
  [CustomAssetDefine.Enum_CustomAssetType.StaticMesh] = FLinearColor(0.036, 0.571, 0.191, 1),
  [CustomAssetDefine.Enum_CustomAssetType.AISoundAsset] = FLinearColor(0.9451, 0.8314, 0.4235, 1.0),
  [CustomAssetDefine.Enum_CustomAssetType.Image] = FLinearColor(0.846873, 0.084376, 0.076185, 1.0)
}
CustomAssetDefine.Enum_CustomAssetSuffixType = {
  Source = "bin",
  Desc = "descbin",
  ETCAsset = "etcbin",
  ASTCAsset = "astcbin",
  PVRTCAsset = "pvrtcbin"
}
CustomAssetDefine.Enum_CustomAssetMountRoleType = {
  Ds = 0,
  AutonomousClient = 1,
  SimulatedClient = 2
}
CustomAssetDefine.Enum_CustomAssetMountType = {
  All = {
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.Ds] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.AutonomousClient] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.SimulatedClient] = true
  },
  OnlyDs = {
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.Ds] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.AutonomousClient] = false,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.SimulatedClient] = false
  },
  OnlyAutonomousClient = {
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.Ds] = false,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.AutonomousClient] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.SimulatedClient] = false
  },
  DsAndAutonomousClient = {
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.Ds] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.AutonomousClient] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.SimulatedClient] = false
  },
  DsExcept = {
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.Ds] = false,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.AutonomousClient] = true,
    [CustomAssetDefine.Enum_CustomAssetMountRoleType.SimulatedClient] = true
  }
}
local CustomAssetConfigDefine = {
  DefaultAsset = nil,
  DeserializerClass = nil,
  PlatformBuilderClass = nil,
  PlatformAsset = nil,
  MountType = CustomAssetDefine.Enum_CustomAssetMountType.All,
  ToPrefabType = CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM
}
CustomAssetDefine.CustomAssetConfigs = {
  [CustomAssetDefine.Enum_CustomAssetType.AIAnim] = {
    DefaultAsset = nil,
    DeserializerClass = "CustomAssetAnimDeserializer",
    MountType = CustomAssetDefine.Enum_CustomAssetMountType.All,
    PlatformBuilderClass = nil,
    ToPrefabType = CustomAssetDefine.ENUM_PREFAB_TYPE.ANIM,
    PlatformAsset = nil
  },
  [CustomAssetDefine.Enum_CustomAssetType.BinaryAsset] = {
    DefaultAsset = nil,
    DeserializerClass = nil,
    MountType = CustomAssetDefine.Enum_CustomAssetMountType.OnlyAutonomousClient,
    PlatformBuilderClass = nil,
    PlatformAsset = nil
  },
  [CustomAssetDefine.Enum_CustomAssetType.Image] = {
    DefaultAsset = nil,
    DeserializerClass = "CustomAssetImageDeserializer",
    MountType = CustomAssetDefine.Enum_CustomAssetMountType.DsExcept,
    PlatformBuilderClass = nil,
    ToPrefabType = CustomAssetDefine.ENUM_PREFAB_TYPE.IMAGE,
    PlatformAsset = {
      [CustomAssetDefine.Enum_CustomAssetSuffixType.ASTCAsset] = true,
      [CustomAssetDefine.Enum_CustomAssetSuffixType.ETCAsset] = true
    }
  },
  [CustomAssetDefine.Enum_CustomAssetType.AISoundAsset] = {
    DefaultAsset = nil,
    DeserializerClass = nil,
    MountType = CustomAssetDefine.Enum_CustomAssetMountType.DsExcept,
    PlatformBuilderClass = nil,
    ToPrefabType = CustomAssetDefine.ENUM_PREFAB_TYPE.SOUND,
    PlatformAsset = nil
  },
  [CustomAssetDefine.Enum_CustomAssetType.StaticMesh] = {
    DefaultAsset = nil,
    DeserializerClass = "CustomAssetStaticMeshDeserializer",
    MountType = CustomAssetDefine.Enum_CustomAssetMountType.All,
    PlatformAsset = {
      [CustomAssetDefine.Enum_CustomAssetSuffixType.ASTCAsset] = true,
      [CustomAssetDefine.Enum_CustomAssetSuffixType.ETCAsset] = true
    }
  }
}
CustomAssetDefine.CustomAssetDownloadPriority = {
  VERY_LOW = 0,
  LOW = 1,
  NORMAL = 5,
  HIGH = 10,
  VERY_HIGH = 50,
  CRITICAL = 100
}
CustomAssetDefine.CustomAssetDownloadType = {
  DownloadOnly = 1,
  DownloadAndLoad = 2,
  DownloadAndDeserialize = 3
}
CustomAssetDefine.Enum_CustomAssetDownloadState = {
  NONE = 0,
  WAITING = 1,
  DOWNLOADING = 2,
  SUCCESS = 3,
  FAILED = 4
}
CustomAssetDefine.CustomAssetCacheVerifyStatus = {
  NotChecked = 0,
  Valid = 1,
  Invalid = 2
}
CustomAssetDefine.Enum_CustomAssetErrorCode = {
  None = 0,
  UnmountCustomAssetError_Normal = 1,
  UnmountCustomAssetError_NotMountedBy = 2,
  UnmountCustomAssetError_InUse = 3,
  UnmountCustomAssetError_NotCustomAsset = 4,
  UnmountCustomAssetError_MountSizeLimit = 5,
  UnmountCustomAssetError_AutoMountSizeLimit = 6
}
function CustomAssetDefine.SpliceCustomAssetKey(CustomAssetType, SizeBytes, Sha256Arr)
  local CustomAssetKey = CustomAssetDefine.CustomAssetKeyTag .. "-" .. tostring(CustomAssetType) .. "-" .. tostring(SizeBytes)
  if Sha256Arr ~= nil then
    for i = 1, #Sha256Arr do
      local Sha256 = Sha256Arr[i]
      if 1 < i then
        CustomAssetKey = CustomAssetKey .. "_" .. tostring(Sha256)
      else
        CustomAssetKey = CustomAssetKey .. "-" .. tostring(Sha256)
      end
    end
  end
  return CustomAssetKey
end
CustomAssetDefine.CustomAssetCosTypeDefine = {
  ResToAIGC = "res-to-aigc",
  ResOfAIGCC = "res-of-aigc",
  PlayerDefRes = "player-def-res",
  TransferForRes = "transfer-for-res",
  IndiaPlayerDefRes = "india-player-def-res"
}
CustomAssetDefine.CustomAssetCosConfigMap = {
  [CustomAssetDefine.CustomAssetCosTypeDefine.ResToAIGC] = {},
  [CustomAssetDefine.CustomAssetCosTypeDefine.ResOfAIGCC] = {},
  [CustomAssetDefine.CustomAssetCosTypeDefine.PlayerDefRes] = {DownloadUrlDomainID = 3366237, DownloadUrlDomainID_BLUEHOLE = 3366238}
}
CustomAssetDefine.MountNeededType = {
  [CustomAssetDefine.Enum_CustomAssetType.None] = false,
  [CustomAssetDefine.Enum_CustomAssetType.BinaryAsset] = false,
  [CustomAssetDefine.Enum_CustomAssetType.StaticMesh] = true,
  [CustomAssetDefine.Enum_CustomAssetType.AIAnim] = true,
  [CustomAssetDefine.Enum_CustomAssetType.AISoundAsset] = true,
  [CustomAssetDefine.Enum_CustomAssetType.Image] = true,
  [CustomAssetDefine.Enum_CustomAssetType.Texture2D] = true
}
function CustomAssetDefine.GetCustomAssetCosDownloadUrl(CustomAssetCosType)
  local CustomAssetCosConfig = CustomAssetDefine.CustomAssetCosConfigMap[CustomAssetCosType]
  if CustomAssetCosConfig == nil then
    return ""
  end
  local bIsBLUEHOLE = false
  if not Client then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() then
      bIsBLUEHOLE = true
    end
  else
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    if GamePlayTools.IsBlueHoleVersion() then
      bIsBLUEHOLE = true
    end
  end
  local DomainID
  if bIsBLUEHOLE then
    DomainID = CustomAssetCosConfig.DownloadUrlDomainID_BLUEHOLE
  else
    DomainID = CustomAssetCosConfig.DownloadUrlDomainID
  end
  if DomainID == nil then
    return ""
  end
  local data = CDataTable.GetTableData("DomainCfg", DomainID)
  return data and data.Domain or ""
end
CustomAssetDefine.CustomAssetDependLimitType = {
  None = 1,
  Error = 2,
  SizeLimit = 3
}
CustomAssetDefine.CustomAssetDependLimitDisplayType = {MsgBox = 1, CommonTips = 2}
CustomAssetDefine.CustomAssetCategoryType = {
  None = 0,
  MyFavorites = 1,
  MyShares = 2,
  Private = 3
}
CustomAssetDefine.ImageDefine = {
  MaxWidth = 1024,
  MaxHeight = 1024,
  MaxFileSize = 4 * CustomAssetDefine.MB
}
return CustomAssetDefine
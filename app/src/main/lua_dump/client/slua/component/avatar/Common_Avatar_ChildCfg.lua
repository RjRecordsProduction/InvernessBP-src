local Common_Avatar_Const = require("client.slua.component.avatar.Common_Avatar_Const")
local UI_Config = require("client.slua.config.base_config")
local Enum_ChildName = Common_Avatar_Const.Enum_ChildName
local Enum_ItemChildZOrder = Common_Avatar_Const.Enum_ItemChildZOrder
local Enum_BaseType = Common_Avatar_Const.Enum_BaseType
local Common_Avatar_ChildCfg = {
  [Enum_ChildName.Ban] = {
    baseType = Enum_BaseType.CreateChildWindowBPPathInChildCfg,
    baseConfig = UI_Config.Common_Avatar_ChildUIWithoutBpPath,
    sBpPath = "/Game/UMG/UI_BP/Common/Common_Avatar_Ban_UIBP.Common_Avatar_Ban_UIBP",
    sParentName = "CanvasPanel_Ban",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Ban]
  },
  [Enum_ChildName.DynamicIcon] = {
    baseType = Enum_BaseType.CreateChildWindowBPPathInCode,
    baseConfig = UI_Config.Common_Avatar_DynamicAvatar,
    sParentName = "GIF_Avatar",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.DynamicIcon]
  },
  [Enum_ChildName.DynamicFrame] = {
    baseType = Enum_BaseType.CreateChildWindowBPPathInCode,
    baseConfig = UI_Config.Common_Avatar_DynamicAvatar,
    sParentName = "GIF_frame",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.DynamicFrame]
  },
  [Enum_ChildName.Reddot] = {
    baseType = Enum_BaseType.CreateChildWindowBPPathInBaseCfg,
    baseConfig = UI_Config.Common_Avatar_Reddot_UIBP,
    sParentName = "CanvasPanel_Ban",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.Reddot]
  },
  [Enum_ChildName.CollectLevel] = {
    baseType = Enum_BaseType.CreateChildWindowBPPathInBaseCfg,
    baseConfig = UI_Config.Common_Avatar_CollectLevel,
    sParentName = "CanvasPanel_CollectLevel",
    nZOrder = Enum_ItemChildZOrder[Enum_ChildName.CollectLevel]
  }
}
return Common_Avatar_ChildCfg
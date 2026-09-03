require("client.slua.config.ClientMacros.bp_macros")
local XMissionUIConfig = {
  ForbiddenUIConfig = {
    [BP_ENUM_MODULE_ROLEINFO_POPULARITY] = true,
    [BP_ENUM_MODULE_WARDROBE] = true,
    [BP_ENUM_MODULE_ROLEINFO] = true
  },
  UnchangedBGConfig = {
    [BP_ENUM_MODULE_MAIL] = true,
    [BP_ENUM_MODULE_ACTIVITY] = true,
    [BP_ENUM_MODULE_SETTING] = true
  }
}
return XMissionUIConfig
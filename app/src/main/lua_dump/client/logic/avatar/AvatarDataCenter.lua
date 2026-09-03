local AvatarDataCenter = {}
local GetBasicDataAvatarWearInfo = function()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  return BasicDataAvatarWearInfo
end
function AvatarDataCenter:GetVehicleSkinID(UID)
  if tostring(UID) == DataMgr.roleData.uid then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemInfo = wardrobe_data:GetHallDepotItemDataByInsID(DataMgr.vst_skin)
    if itemInfo then
      return itemInfo.resID
    end
  end
  local Data = GetBasicDataAvatarWearInfo():GetCacheData(UID)
  if not Data then
    return
  end
  return Data.wear[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_VST_SKIN]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CAvatarDataCenter = class(CModuleBase, nil, AvatarDataCenter)
return CAvatarDataCenter
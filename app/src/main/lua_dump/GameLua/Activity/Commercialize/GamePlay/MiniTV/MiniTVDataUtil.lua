local CONST_DEFAULT_SUIT_ID = 1601019
local MiniTVDataUtil = {
  CachedMiniTVInfo = {}
}
function MiniTVDataUtil:GeneratePlayerMiniTVData(PlayerInfo, uPlayerController)
  self:_FillMiniTVInfo(PlayerInfo, uPlayerController)
end
function MiniTVDataUtil:_FillMiniTVInfo(PlayerInfo, uPlayerController)
  if not uPlayerController or not uPlayerController.UID then
    return
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local MiniTVInfo = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(uPlayerController.UID, ExtendAttribute.MiniTVInfo)
  if not MiniTVInfo then
    print(bWriteLog and "MiniTVDataUtil:_FillMiniTVData MiniTVInfo is invalid.")
    uPlayerController.CommerFeature.bEnableMiniTV = false
    return
  end
  uPlayerController.CommerFeature.bEnableMiniTV = true
  self.CachedMiniTVInfo[uPlayerController.UID] = MiniTVInfo
  uPlayerController.CommerFeature.MiniTVDressID = MiniTVInfo.minitv_dress_id or CONST_DEFAULT_SUIT_ID
  uPlayerController.CommerFeature.MiniTVActionIDList = slua.Array(UEnums.EPropertyClass.Int)
  if MiniTVInfo.motion_info then
    for _, v in pairs(MiniTVInfo.motion_info) do
      uPlayerController.CommerFeature.MiniTVActionIDList:Add(v)
    end
  end
end
function MiniTVDataUtil:GetPlayerMiniTVInfo(UID)
  if not UID then
    return nil
  end
  return self.CachedMiniTVInfo[UID]
end
function MiniTVDataUtil:GetPlayerMiniTVDressID(UID)
  if not UID then
    return CONST_DEFAULT_SUIT_ID
  end
  local MiniTVInfo = self.CachedMiniTVInfo[UID]
  return MiniTVInfo and MiniTVInfo.minitv_dress_id or CONST_DEFAULT_SUIT_ID
end
function MiniTVDataUtil:IsMiniTvEnabled(UID)
  local MiniTVInfo = self.CachedMiniTVInfo[UID]
  return MiniTVInfo and true or false
end
function MiniTVDataUtil:GetPlayerMinITVActionList(UID)
  if not UID then
    return nil
  end
  local MiniTVInfo = self.CachedMiniTVInfo[UID]
  return MiniTVInfo and MiniTVInfo.motion_info or {}
end
function MiniTVDataUtil:ClearMiniTVInfo(UID)
  if not UID then
    return
  end
  self.CachedMiniTVInfo[UID] = nil
end
return MiniTVDataUtil
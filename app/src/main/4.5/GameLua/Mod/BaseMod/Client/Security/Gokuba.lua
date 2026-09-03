if _G.IsEditor then
  require("GameLua.Mod.BaseMod.Client.Security.DSDynamicDispatched")
end
local GokubaLogic = {TimerHandle = nil}
function GokubaLogic.InitGokubaLogic()
  EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY, GokubaLogic.OnControllerBeginPlay)
  if not Client.IsReleaseVersion(NetInterface) then
    _G.  end
end
function GokubaLogic.OnControllerBeginPlay()
  print(bWriteLog and "GokubaLogic.OnControllerBeginPlay")
  local time_ticker = require("common.time_ticker")
  GokubaLogic.TimerHandle = time_ticker.AddTimer(45, function(...)
    GokubaLogic.ForwardFeature()
  end)
end
function GokubaLogic.ForwardFeature()
  local ENUM_FeatureType = {
    ENUM_FeatureType_Root = 1,
    ENUM_FeatureType_Malware = 2,
    ENUM_FeatureType_Cdn = 3,
    ENUM_FeatureType_CS = 4,
    ENUM_FeatureType_Permission = 5
  }
  local features = Tss.GetUserTag4Lua()
  if features ~= nil then
    log_tree("GokubaLogic.ForwardFeature features:", features)
    local tbResult = {}
    local root = string.find(features, "root") ~= nil
    tbResult[ENUM_FeatureType.ENUM_FeatureType_Root] = root and 1 or 0
    local malware = string.find(features, "malware") ~= nil
    tbResult[ENUM_FeatureType.ENUM_FeatureType_Malware] = malware and 1 or 0
    local cdn = string.find(features, "cdn") ~= nil
    tbResult[ENUM_FeatureType.ENUM_FeatureType_Cdn] = cdn and 1 or 0
    local cs = string.find(features, "cs") ~= nil
    tbResult[ENUM_FeatureType.ENUM_FeatureType_CS] = cs and 1 or 0
    local permission = string.find(features, "permission") ~= nil
    tbResult[ENUM_FeatureType.ENUM_FeatureType_Permission] = permission and 1 or 0
    log_tree("GokubaLogic.ForwardFeature tbResult:", tbResult)
    NetUtil.SendPkg("battle_client_sync_allstar_auth_check_result_req", tbResult)
  else
  end
end
GokubaLogic.InitGokubaLogic()
return GokubaLogic
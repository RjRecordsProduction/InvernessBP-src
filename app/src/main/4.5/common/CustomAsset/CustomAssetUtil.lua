local CustomAssetUtil = {}
function CustomAssetUtil.CreateCustomAssetManager(InOuter)
  if not slua.isValid(InOuter) then
    local UIUtil = require("client.common.ui_util")
    InOuter = UIUtil.GetGameInstance()
  end
  local CustomAssetManagerClass = import("CustomAssetManager")
  local uCustomAssetMgr = CGame:NewObjectFromClass(InOuter, CustomAssetManagerClass, "CustomAssetManager")
  if slua.isValid(uCustomAssetMgr) then
    uCustomAssetMgr:TryBeginPlay()
  end
  return uCustomAssetMgr
end
function CustomAssetUtil.DestroyCustomAssetManager(uCustomAssetMgr)
  if slua.isValid(uCustomAssetMgr) then
    uCustomAssetMgr:CustomAssetMgrConditionalBeginDestroy()
  end
end
function CustomAssetUtil.GetServerTimeInSeconds()
  if Client ~= nil then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.GetServerTimeInSec()
  else
    if slua.isValid(CGameState) then
      return CGameState:GetServerWorldTimeSeconds()
    end
    return 0
  end
end
return CustomAssetUtil
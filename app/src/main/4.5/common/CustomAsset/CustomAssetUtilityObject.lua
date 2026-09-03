local CustomAssetUtilityObject = {}
function CustomAssetUtilityObject:ctor()
  self.bHasEndPlay = false
end
function CustomAssetUtilityObject:ReceiveBeginPlay()
end
function CustomAssetUtilityObject:ReceivePostBeginPlay()
end
function CustomAssetUtilityObject:ReceiveEndPlay()
  self.bHasEndPlay = true
  self:Dispose()
end
function CustomAssetUtilityObject:IsDedicatedServer()
  if self.CacheIsDedicatedServer == nil then
    self.CacheIsDedicatedServer = self:ReceiveIsDedicatedServer()
  end
  return self.CacheIsDedicatedServer
end
function CustomAssetUtilityObject:IsEditor()
  return IsEditor == true
end
function CustomAssetUtilityObject:GetCustomAssetMgr()
  if slua.isValid(self.CustomAssetMgr) then
    return self.CustomAssetMgr
  end
  return CustomAssetMgr
end
function CustomAssetUtilityObject:OnFightingStatusEnter()
end
function CustomAssetUtilityObject:OnFightingStatusPreExit()
end
function CustomAssetUtilityObject:OnFightingStatusPostExit()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CCustomAssetUtilityObject = class(CDelegateContainer, nil, CustomAssetUtilityObject)
return CCustomAssetUtilityObject
local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local FeatureBase = {}
function FeatureBase:ctor(_, FeatureMetaData)
  if FeatureMetaData then
    self.__FeatureKey = FeatureMetaData.__FeatureKey
  end
end
function FeatureBase:_PostConstruct()
  FeatureUtil.ForEachFeatureCall(self, "_PostConstruct")
end
function FeatureBase:ReceiveBeginPlay()
  FeatureUtil.ForEachFeatureCall(self, "ReceiveBeginPlay")
end
function FeatureBase:ReceiveEndPlay(EndPlayReason)
  FeatureUtil.ForEachFeatureCall(self, "ReceiveEndPlay", EndPlayReason)
  local EEndPlayReason = import("EEndPlayReason")
  if EndPlayReason == EEndPlayReason.Destroyed then
    self.Features = {}
  end
  self:Dispose()
end
function FeatureBase:BPOnRecycled()
end
function FeatureBase:AddLuaNetPropListener(PropName, HandleFunc, ...)
  local FinalPropName = self.__ReplicatedPropsMap[PropName]
  FeatureBase.__super.AddLuaNetPropListener(self, self.Owner, FinalPropName, HandleFunc, ...)
end
function FeatureBase:GetFeatureNetPropName(PropName)
  return self.__ReplicatedPropsMap[PropName]
end
function FeatureBase:ForceNetUpdate()
  if self.IsDynamicLuaFeature then
    self.Object:BP_ForceNetUpdate()
  else
    self:_CallOwnerMethod("ForceNetUpdate")
  end
end
function FeatureBase:HasAuthority()
  return self:_CallOwnerMethod("HasAuthority")
end
function FeatureBase:IsAuthority()
  return self:_CallOwnerMethod("IsAuthority")
end
function FeatureBase:IsAutonomousProxy()
  return self:_CallOwnerMethod("IsAutonomousProxy")
end
function FeatureBase:IsSimulated()
  return self:_CallOwnerMethod("IsSimulated")
end
function FeatureBase:IsStandalone()
  return self:_CallOwnerMethod("IsStandalone")
end
function FeatureBase:IsDedicatedServer()
  return self:_CallOwnerMethod("IsDedicatedServer")
end
function FeatureBase:_CallOwnerMethod(Method, ...)
  local Owner = self.Owner
  if not slua.isValid(Owner.Object) then
    log_warning(string.format("Owner.Object is not valid (Method: %s)", Method))
    return
  end
  if Owner[Method] then
    return Owner[Method](Owner, ...)
  else
    log_warning(string.format("Cannnot find %s in owner %s", Method, Owner))
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CFeatureBase = class(CDelegateContainer, nil, FeatureBase)
return CFeatureBase
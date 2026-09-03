local FakeIslandActor = {}
local GODTRIAL_MAP_NAME = "Baltic_Dynamic_GodTrial_Island"
function FakeIslandActor:ReceiveBeginPlay()
  FakeIslandActor.__super.ReceiveBeginPlay(self)
  if Client then
    self:CheckAndUpdateVisibility()
    if not self:RegisterStreamingLevelEvents() then
      self:ListenToDynamicTileEvents()
    end
  end
end
function FakeIslandActor:ReceiveEndPlay(EndPlayReason)
  FakeIslandActor.__super.ReceiveEndPlay(self, EndPlayReason)
end
function FakeIslandActor:IsGodTrialLevelLoaded()
  local uWorld = CGameWorld
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not StreamingLevels then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if slua.isValid(uLevelStreaming) then
      local PackageName = uLevelStreaming.PackageNameToLoad
      if PackageName and string.find(PackageName, GODTRIAL_MAP_NAME) and uLevelStreaming:IsLevelLoaded() and uLevelStreaming:IsLevelVisible() then
        return true
      end
    end
  end
  return false
end
function FakeIslandActor:DoesGodTrialLevelExist()
  local uWorld = CGameWorld
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not StreamingLevels then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if slua.isValid(uLevelStreaming) then
      local PackageName = uLevelStreaming.PackageNameToLoad
      if PackageName and string.find(PackageName, GODTRIAL_MAP_NAME) then
        return true
      end
    end
  end
  return false
end
function FakeIslandActor:CheckAndUpdateVisibility()
  if not Client or not slua.isValid(self.Object) then
    return
  end
  local bIsGodTrialMapLoaded = self:IsGodTrialLevelLoaded()
  self.Object:SetActorHiddenInGame(bIsGodTrialMapLoaded)
  print(bWriteLog and string.format("FakeIslandActor:CheckAndUpdateVisibility - GodTrial Level Loaded:%s, Hidden:%s", tostring(bIsGodTrialMapLoaded), tostring(bIsGodTrialMapLoaded)))
end
function FakeIslandActor:ListenToDynamicTileEvents()
  print(bWriteLog and "FakeIslandActor:ListenToDynamicTileEvents - Listening to DynamicTile events")
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_CREATE, function(DynamicTileActor)
    print(bWriteLog and "FakeIslandActor:OnDynamicTileCreated - DynamicTile created")
    if self:DoesGodTrialLevelExist() then
      print(bWriteLog and "FakeIslandActor:OnDynamicTileCreated - GodTrial level detected")
      self:RemoveCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_CREATE)
      self:RegisterStreamingLevelEvents()
      self:CheckAndUpdateVisibility()
    end
  end)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_DESTROY, function(DynamicTileActor)
    print(bWriteLog and "FakeIslandActor:OnDynamicTileDestroyed - DynamicTile destroyed")
    if not self:DoesGodTrialLevelExist() then
      print(bWriteLog and "FakeIslandActor:OnDynamicTileDestroyed - GodTrial level removed")
      self:CheckAndUpdateVisibility()
      self:ListenToDynamicTileEvents()
    end
  end)
end
function FakeIslandActor:RegisterStreamingLevelEvents()
  local uWorld = CGameWorld
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not StreamingLevels then
    return false
  end
  local bFoundLevel = false
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if slua.isValid(uLevelStreaming) then
      local PackageName = uLevelStreaming.PackageNameToLoad
      if PackageName and string.find(PackageName, GODTRIAL_MAP_NAME) then
        bFoundLevel = true
        self:AddControlEvent(uLevelStreaming, "OnLevelShown", function()
          print(bWriteLog and "FakeIslandActor:OnLevelShown - GodTrial level shown")
          self:CheckAndUpdateVisibility()
        end)
        self:AddControlEvent(uLevelStreaming, "OnLevelHidden", function()
          print(bWriteLog and "FakeIslandActor:OnLevelHidden - GodTrial level hidden")
          self:CheckAndUpdateVisibility()
        end)
        print(bWriteLog and string.format("FakeIslandActor:RegisterStreamingLevelEvents - Registered events for %s", PackageName))
      end
    end
  end
  return bFoundLevel
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CFakeIslandActor = class(object, nil, FakeIslandActor)
return CFakeIslandActor
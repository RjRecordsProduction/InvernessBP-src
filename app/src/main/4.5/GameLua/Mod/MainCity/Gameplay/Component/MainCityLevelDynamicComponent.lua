local MainCityLevelDynamicComponent = {}
function MainCityLevelDynamicComponent:ctor()
  print(bWriteLog and "MainCityLevelDynamicComponent:ctor")
end
function MainCityLevelDynamicComponent:ReceiveBeginPlay()
  print(bWriteLog and "MainCityLevelDynamicComponent:ReceiveBeginPlay")
  MainCityLevelDynamicComponent.__super.ReceiveBeginPlay(self)
  self:InitCustomDisableDistanceLoadLevels()
end
function MainCityLevelDynamicComponent:InitCustomDisableDistanceLoadLevels()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bIsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if bIsDS then
    local StreamingLevels = CGameWorld.StreamingLevels
    if not slua.isValid(StreamingLevels) then
      return
    end
    if not self.CustomDisableDistanceLoadLevels then
      return
    end
    local StringUtil = require("common.string_util")
    for _, uLevelStreaming in pairs(StreamingLevels) do
      if slua.isValid(uLevelStreaming) then
        local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
        local ShortPackageName = self:GetShortName(PackageName)
        if StringUtil.StrFind(ShortPackageName, "Lobby") then
          self.CustomDisableDistanceLoadLevels:Add(ShortPackageName)
        end
      end
    end
    local nCustomNum = self.CustomDisableDistanceLoadLevels:Num()
    print(bWriteLog and "MainCityLevelDynamicComponent:InitCustomDisableDistanceLoadLevels nCustomNum = " .. tostring(nCustomNum))
  end
end
local Class = require("class")
local Object = require("GameLua.Mod.BaseMod.GamePlay.Component.XComponent")
local CMainCityLevelDynamicComponent = Class(Object, nil, MainCityLevelDynamicComponent)
return CMainCityLevelDynamicComponent
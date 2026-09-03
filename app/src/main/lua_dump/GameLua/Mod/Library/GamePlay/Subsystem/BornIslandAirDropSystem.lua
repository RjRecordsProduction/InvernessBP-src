local BornIslandAirDropSystem = {}
function BornIslandAirDropSystem:OnInit()
  print(bWriteLog and "ConfigDrivePlaneShowSubsystem:OnInit")
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "ReadyState"
  }, function()
    self:RegistEvents()
  end)
end
function BornIslandAirDropSystem:RegistEvents()
  print(bWriteLog and "BornIslandAirDropSystem:RegistEvents")
  self:GetCurrentDropTimeInfoItem()
  if not Client then
    self:CreateAirDrop()
  elseif self.DropTimeInfoItem and self.DropTimeInfoItem.bLanded and CGameState then
    local GameModeState = CGameState:GetGameModeState() or ""
    if GameModeState == "ReadyState" then
      local BornIslandTeamShowSubSystem = SubsystemMgr:Get("BornIslandTeamShowSubSystem")
      if BornIslandTeamShowSubSystem and not BornIslandTeamShowSubSystem:IsShowing() then
        UIManager.ShowUI(UIManager.UI_Config_InGame.BornIsLandAirdrop_ActivityTips_UIBP)
      end
    end
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_TEAM_SHOW_READY, self.StartFight, self)
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.StartFight, self)
end
function BornIslandAirDropSystem:GetCurrentDropTimeInfoItem()
  print(bWriteLog and "BornIslandAirDropSystem:GetCurrentDropTimeInfoItem")
  if not self.DropTimeInfoItem then
    self:InitConfig()
  end
  return self.DropTimeInfoItem
end
function BornIslandAirDropSystem:InitConfig()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeType2 = GameMainConfig.GetMapType()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local GameplayStatics = import("GameplayStatics")
  local curLevelName = GameplayStatics.GetCurrentLevelName(slua.getGameInstance(), true)
  local ModeID = GameMainConfig.GetModeID()
  print(bWriteLog and "BornIslandAirDropSystem:InitConfig ModType:" .. ModeType2 .. " curLevelName:" .. curLevelName .. " ModeID:" .. tostring(ModeID))
  self.BornIslandAirDropConfig = GamePlayTools.GetCurrentConfig("BornIslandAirDropConfig")
  if ModeType2 and self.BornIslandAirDropConfig.EffectMap[ModeType2] and self.BornIslandAirDropConfig.EffectMainMap[curLevelName] and not self.BornIslandAirDropConfig.DisableModeID[ModeID] then
    local ModeID = GameMainConfig.GetModeID()
    local IsBRMode = GamePlayTools.IsBRMode(ModeID)
    print(bWriteLog and string.format("BornIslandAirDropSystem:InitConfig ModeID = %s, IsBRMode = %s", ModeID, IsBRMode))
    if not IsBRMode then
      print(bWriteLog and "BornIslandAirDropSystem:InitConfig not IsBRMode")
      return
    end
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    if GamePlayTools.IsBlueHoleVersion() then
      print(bWriteLog and "BornIslandAirDropSystem:InitConfig IsBlueHoleVersion")
      return
    end
    local TimeUtil = require("client.common.time_util")
    local ActivityFinshTime = TimeUtil.TimeStringToUnixstamp(self.BornIslandAirDropConfig.AirDropActivityFinishTime, false)
    local nowTime = self:GetServerTimeInSec()
    if ActivityFinshTime > nowTime then
      local MapDropInfo = self.BornIslandAirDropConfig.MapDropInfo.Default
      if self.BornIslandAirDropConfig.MapDropInfo[ModeType2] then
        MapDropInfo = self.BornIslandAirDropConfig.MapDropInfo[ModeType2]
      end
      if not MapDropInfo then
        print(bWriteLog and "BornIslandAirDropSystem:InitConfig MapDropInfo Error")
        return
      end
      for key, value in pairs(MapDropInfo.DropTimeInfo) do
        local ActivityTime = TimeUtil.TimeStringToUnixstamp(value.Time, false)
        if nowTime > ActivityTime then
          self.DropTimeInfoItem = value
        end
      end
      self.DefaultDropID = MapDropInfo.DropID
      print(bWriteLog and "BornIslandAirDropSystem:InitConfig self.DefaultDropID:", self.DefaultDropID)
    else
      print(bWriteLog and "BornIslandAirDropSystem:InitConfig timefish")
    end
  else
    print(bWriteLog and "BornIslandAirDropSystem:InitConfig ModType not allow")
  end
end
function BornIslandAirDropSystem:CreateAirDrop()
  print(bWriteLog and "BornIslandAirDropSystem:CreateAirDrop")
  if self.DropTimeInfoItem then
    self.airDropBoxs = {}
    for key, value in pairs(self.DropTimeInfoItem.AirDropStartHightPos) do
      local airDropID = self.DefaultDropID
      if self.DropTimeInfoItem.PosDropID and self.DropTimeInfoItem.PosDropID[key] then
        airDropID = self.DropTimeInfoItem.PosDropID[key]
      end
      local airDropBox = Game:StartAirdrop(slua.loadClass(self.BornIslandAirDropConfig.AirDropPath), airDropID, value, self.DropTimeInfoItem.AirDropSpeed, 100, 0, true)
      if slua.isValid(airDropBox) and slua.isValid(airDropBox.InteractiveComponent) then
        airDropBox.bCanLand = self.DropTimeInfoItem.bLanded
        airDropBox.InteractiveComponent:SetEnable(false)
        self.airDropBoxs[#self.airDropBoxs + 1] = airDropBox
      end
    end
    if self.DropTimeInfoItem.ShowTipID then
      Game:UIShowImageTips(-1, self.DropTimeInfoItem.ShowTipID)
    end
  end
end
function BornIslandAirDropSystem:StartFight()
  print(bWriteLog and "BornIslandAirDropSystem:StartFight")
  if self.airDropBoxs then
    for key, value in pairs(self.airDropBoxs) do
      if slua.isValid(value) then
        value:SetLifeSpan(0.1)
      end
    end
    self.airDropBoxs = nil
  end
end
function BornIslandAirDropSystem:OnRelease()
  print(bWriteLog and "BornIslandAirDropSystem:OnRelease")
  BornIslandAirDropSystem.__super.OnRelease(self)
end
function BornIslandAirDropSystem:GetServerTimeInSec()
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local IsDevelopment = false
  if Client then
    IsDevelopment = Client.IsDevelopment
  else
    IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
  end
  if IsDevelopment and self.DevStartTime and self.DevStartCurrentTime then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local DevnowTime = self.DevStartTime + nowTime - self.DevStartCurrentTime
    return DevnowTime
  else
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    return nowTime
  end
end
function BornIslandAirDropSystem:DevSetServerTimeInSec(DevStartTime)
  print(bWriteLog and "BornIslandAirDropSystem:DevSetServerTimeInSec:" .. tostring(DevStartTime))
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local IsDevelopment = false
  if Client then
    IsDevelopment = Client.IsDevelopment
  else
    IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
  end
  local TimeUtil = require("client.common.time_util")
  if IsDevelopment and DevStartTime then
    self.    self.DevStartCurrentTime = TimeUtil.GetServerTimeInSec()
  end
  self.DropTimeInfoItem = nil
  self:RegistEvents()
  local ModActivityAirDropManagerSystem = SubsystemMgr:Get("ModActivityAirDropManagerSystem")
  if ModActivityAirDropManagerSystem and ModActivityAirDropManagerSystem.InitConfig then
    ModActivityAirDropManagerSystem:InitConfig()
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, BornIslandAirDropSystem)
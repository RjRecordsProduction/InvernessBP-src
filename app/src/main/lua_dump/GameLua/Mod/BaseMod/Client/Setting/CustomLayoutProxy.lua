local CustomLayoutProxy = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local CustomSaveFlag = require("client.logic.setting.CustomSaveFlag")
local CustomDisplayFlag = require("client.logic.setting.CustomDisplayFlag")
local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
local SaveType = {
  Character = 1,
  VehicleGeneral = 2,
  DriveByButton = 3,
  DriveByJoystick = 4,
  DriveByWheels = 5,
  SpecialCharacter = 6,
  Standalone = 7
}
CustomLayoutProxy.
function CustomLayoutProxy:LuaOnInitInGame()
  self.bDisableCustomLayout = not InGameUITools.CheckApplyCustomizeUI()
  self:PrepareInGameConfig()
  print(bWriteLog and "CustomLayoutProxy:LuaOnInitInGame bDisableCustomLayout = " .. tostring(self.bDisableCustomLayout))
  self.bInitInGame = true
end
function CustomLayoutProxy:LuaOnReleaseInGame()
  print(bWriteLog and "CustomLayoutProxy:LuaOnReleaseInGame")
  self.bDisableCustomLayout = nil
  self.bInitInGame = false
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  if slua.isValid(SettingSubsystem_CPP) then
    SettingSubsystem_CPP:ClearCustomSetting()
  end
end
function CustomLayoutProxy:LuaCheckLayoutDetail(InCustomType, InSaveType)
  print(bWriteLog and string.format("CustomLayoutProxy:LuaCheckLayoutDetail BEGIN --- InCustomType %d InSaveType %d", InCustomType, InSaveType))
  if self.bDisableCustomLayout then
    return false
  end
  local bBatch = InCustomType == -2
  local SaveGame = false
  local ControlMode = false
  if InSaveType == SaveType.Character then
    ControlMode = InGameUITools.GetControlMode()
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(Setting_UIElemLayout_Interface.GetInGameCharacterLayoutInfo())
  elseif InSaveType == SaveType.VehicleGeneral then
    ControlMode = InGameUITools.GetVehicleMode()
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.Vehicle, ControlMode)
  elseif InSaveType == SaveType.DriveByButton then
    ControlMode = 3
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.Vehicle, ControlMode)
  elseif InSaveType == SaveType.DriveByJoystick then
    ControlMode = 2
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.Vehicle, ControlMode)
  elseif InSaveType == SaveType.DriveByWheels then
    ControlMode = 1
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.Vehicle, ControlMode)
  elseif InSaveType == SaveType.SpecialCharacter then
    ControlMode = 1
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.SpecialCharacter, ControlMode)
  elseif InSaveType == SaveType.Standalone then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType, _ = GameMainConfig.GetModType()
    ControlMode = 1
    SaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(CustomLayoutType.Standalone, ControlMode, false, nil, ModType)
  else
    return false
  end
  if not SaveGame or not ControlMode then
    print(bWriteLog and "CustomLayoutProxy:LuaCheckLayoutDetail SaveGame Not Found")
    return false
  end
  print(bWriteLog and string.format("CustomLayoutProxy:LuaCheckLayoutDetail Info SaveSlotName:%s ControlMode:%d", SaveGame.SaveSlotName or "nil", ControlMode or -1))
  local LayoutDetailDict_Legacy = SaveGame["LayoutDetailDict" .. ControlMode]
  local InvalidArray_Legacy = SaveGame["InvalidArray" .. ControlMode]
  local IsNewSaveClass = SaveGame.GetDataAsLayoutDetail ~= nil
  if bBatch then
    self:ClearCacheBySaveType(InSaveType)
    if IsNewSaveClass then
      return self:LoadSaveGameBySaveType(SaveGame, InSaveType)
    else
      local InvalidMap = {}
      local InvalidTypeNum = InvalidArray_Legacy:Num()
      for Idx = 0, InvalidTypeNum - 1 do
        local InvalidType = InvalidArray_Legacy:Get(Idx)
        if self.SaveTypeMap:Get(InvalidType) == InSaveType then
          InvalidMap[InvalidType] = true
        end
      end
      for Key, Value in pairs(LayoutDetailDict_Legacy) do
        if self.SaveTypeMap:Get(Key) == InSaveType then
          if Key == Value.Type then
            self:AddLayoutDetailCache(Value, InvalidMap[Key] or false)
          else
            print(bWriteLog and string.format("CustomLayoutProxy:LuaCheckLayoutDetail Exceptional Data Found KeyType=%d, ValueType=%d", Key, Value.Type))
          end
        end
      end
    end
    return true
  end
  if IsNewSaveClass then
    return self:LoadSaveGameByCustomType(SaveGame, InCustomType)
  else
    local bInvalid = false
    local LayoutDetail_BP = LayoutDetailDict_Legacy:Get(InCustomType)
    local InvalidTypeNum = InvalidArray_Legacy:Num()
    for Idx = 0, InvalidTypeNum - 1 do
      if InCustomType == InvalidArray_Legacy:Get(Idx) then
        bInvalid = true
        break
      end
    end
    if LayoutDetail_BP and self.AddLayoutDetailCache then
      self:AddLayoutDetailCache(LayoutDetail_BP, bInvalid)
      return true
    end
  end
  return false
end
function CustomLayoutProxy:GetLayoutDetailByType(InCustomType)
  local InSaveType = self.SaveTypeMap:Get(InCustomType)
  if not InSaveType then
    print(bWriteLog and "CustomLayoutProxy:GetLayoutDetailByType " .. InCustomType .. " Failed, Not In Any SaveType")
    return false
  else
    print(bWriteLog and "CustomLayoutProxy:GetLayoutDetailByType " .. InCustomType)
  end
  if self.bDisableCustomLayout then
    return false
  end
  local LayoutDetail = self.CachedLayoutDetailMap:Get(InCustomType)
  if not LayoutDetail and self:LuaCheckLayoutDetail(InCustomType, InSaveType) then
    LayoutDetail = self.CachedLayoutDetailMap:Get(InCustomType)
    print(bWriteLog and "  Successfully")
  end
  return LayoutDetail
end
function CustomLayoutProxy:PrepareInGameConfig()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local ConfigTool = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfigTool")
  local LayoutConfig = ConfigTool.GetLayoutConfig(ModType)
  for InCustomType, Config in pairs(LayoutConfig.SlotRegistry) do
    local InSaveFlag = Config.SaveFlag
    if not InSaveFlag then
    elseif InSaveFlag == CustomSaveFlag.VH_BC then
      self.SaveTypeMap:Add(InCustomType, SaveType.DriveByButton)
    elseif InSaveFlag == CustomSaveFlag.VH_JC then
      self.SaveTypeMap:Add(InCustomType, SaveType.DriveByJoystick)
    elseif InSaveFlag == CustomSaveFlag.VH_SW then
      self.SaveTypeMap:Add(InCustomType, SaveType.DriveByWheels)
    elseif InSaveFlag & (CustomSaveFlag.VH_BC | CustomSaveFlag.VH_JC | CustomSaveFlag.VH_SW) > 0 then
      self.SaveTypeMap:Add(InCustomType, SaveType.VehicleGeneral)
    elseif InSaveFlag == CustomSaveFlag.Classic and Config.ShowFlag == CustomDisplayFlag.SpecialObject then
      self.SaveTypeMap:Add(InCustomType, SaveType.SpecialCharacter)
    elseif 0 < InSaveFlag & CustomSaveFlag.Classic then
      self.SaveTypeMap:Add(InCustomType, SaveType.Character)
    elseif InSaveFlag == CustomSaveFlag.TD then
      self.SaveTypeMap:Add(InCustomType, SaveType.Character)
    elseif InSaveFlag == CustomSaveFlag.UGC then
      self.SaveTypeMap:Add(InCustomType, SaveType.Character)
    elseif InSaveFlag == CustomSaveFlag.Standalone then
      self.SaveTypeMap:Add(InCustomType, SaveType.Standalone)
    else
      print(bWriteLog and string.format("CustomType %d cannot assign a SaveType", InCustomType))
    end
  end
end
function CustomLayoutProxy:CollectTouchStat(TouchStatTable)
  if not self.bInitInGame then
    return false
  end
  local CurrentTouchStatArrayLength = self.TouchStatArray:Num()
  if CurrentTouchStatArrayLength == 0 then
    return false
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local ConfigTool = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfigTool")
  local LayoutConfig = ConfigTool.GetLayoutConfig(ModType)
  local MAX_RECORD_LEN = LayoutConfig.StatConfig.RecordCountMax
  local TempDotsNum = {}
  for i = 0, CurrentTouchStatArrayLength - 1 do
    local TouchStatInfo = self.TouchStatArray:Get(i)
    local InCustomType = TouchStatInfo.CustomTypeShort
    local x = TouchStatInfo.ScreenSpaceX
    local y = TouchStatInfo.ScreenSpaceY
    if not TouchStatTable[InCustomType] then
      TouchStatTable[InCustomType] = {}
    end
    local _DotPos = #TouchStatTable[InCustomType]
    if _DotPos >= MAX_RECORD_LEN * 2 then
      if not TempDotsNum[InCustomType] then
        TempDotsNum[InCustomType] = 0
      end
      TouchStatTable[InCustomType][2 * TempDotsNum[InCustomType] + 1] = x
      TouchStatTable[InCustomType][2 * TempDotsNum[InCustomType] + 2] = y
      TempDotsNum[InCustomType] = TempDotsNum[InCustomType] + 1
      if MAX_RECORD_LEN <= TempDotsNum[InCustomType] then
        TempDotsNum[InCustomType] = 0
      end
    else
      TouchStatTable[InCustomType][_DotPos + 1] = x
      TouchStatTable[InCustomType][_DotPos + 2] = y
    end
  end
  self:ClearTouchStatArray()
  return true
end
local class = require("class")
local object = require("object")
return class(object, nil, CustomLayoutProxy)
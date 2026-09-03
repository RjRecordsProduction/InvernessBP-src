local CustomLayoutModule = {}
local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local SaveDomain = require("client.logic.setting.CustomLayoutSaveDomain")
local HasLogin = function()
  if LobbySystem and LobbySystem.roleData and next(LobbySystem.roleData) then
    return true
  end
end
function CustomLayoutModule:DefineAndResetData()
  self.Subsystem = nil
  self.bDisableCustomLayout = nil
  self.DomainToCustomTypes = nil
  self._bHasModDomain = nil
  self.CharacterSlotName = nil
  self.VehicleSlotName = nil
  self.CurrentModCustomLayout = nil
end
function CustomLayoutModule:OnInitialize()
  print(bWriteLog and "CustomLayoutModule:OnInitialize")
  local Utility = require("common.utility")
  self.Subsystem = Utility.GetGameInstanceSubsystemByName("CustomLayoutSubsystem")
  if not self.Subsystem then
    print(bWriteLog and "CustomLayoutModule:OnInitialize cannot get CustomLayoutSubsystem")
    return
  end
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SCREENPADDING_CHANGED, function(_, __, Padding)
    self.Subsystem:SetScreenPadding(Padding)
  end)
  local ScriptHelperClient = import("ScriptHelperClient")
  self.Subsystem:SetScreenPadding(ScriptHelperClient.GetScreenPadding())
end
function CustomLayoutModule:OnDestroy()
  print(bWriteLog and "CustomLayoutModule:OnDestroy")
end
function CustomLayoutModule:OnPostSwitchGameStatus(preState, nextState)
  print(bWriteLog and "CustomLayoutModule:OnPostSwitchGameStatus", preState, nextState)
  require("client.common.game_status")
  if nextState == GameStatus.Fighting and preState ~= GameStatus.Fighting then
    self:ActivateInGame()
  elseif preState == GameStatus.Fighting and nextState ~= GameStatus.Fighting then
    self:DeactivateInGame()
  end
end
function CustomLayoutModule:ActivateInGame()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  self.bDisableCustomLayout = not InGameUITools.CheckApplyCustomizeUI()
  print(bWriteLog and "CustomLayoutModule:ActivateInGame bDisableCustomLayout = " .. tostring(self.bDisableCustomLayout))
  if self.bDisableCustomLayout then
    return
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  self._ModName = GameMainConfig.GetModType()
  self:PrepareInGameConfig(self._ModName)
  if self._bHasModDomain then
    self:PullCustomLayoutInMod(self._ModName, function()
      self.Subsystem:InsertUserSettingSlot(self.CurrentModCustomLayout, 0)
      self:BroadcastCustomLayoutChangeByDomain(SaveDomain.Mod)
    end)
  end
  if self.DomainToCustomTypes[SaveDomain.Character] then
    local CharacterSaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame(Setting_UIElemLayout_Interface.GetInGameCurrentLayoutContext())
    if slua.isValid(CharacterSaveGame) then
      self.Subsystem:AddUserSettingSlot(CharacterSaveGame)
      self.CharacterSlotName = CharacterSaveGame.SaveSlotName
    end
    local _Delegate = function()
      self:OnCharacterSlotSettingChanged()
    end
    self:AddSettingOptionEvent("FireMode", _Delegate)
    self:AddSettingOptionEvent("SelectUIElemIndex1", _Delegate)
    self:AddSettingOptionEvent("SelectUIElemIndex2", _Delegate)
    self:AddSettingOptionEvent("SelectUIElemIndex3", _Delegate)
  end
  if self.DomainToCustomTypes[SaveDomain.VH_General] then
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    local VehicleControlMode = SettingModule:GetOptionValue("VehicleControlMode")
    local VehicleSaveGame = Setting_UIElemLayout_Interface.TryGetSaveGame({
      LayoutType = CustomLayoutType.Vehicle,
      VehicleMode = VehicleControlMode
    })
    if slua.isValid(VehicleSaveGame) then
      self.Subsystem:AddUserSettingSlot(VehicleSaveGame)
      self.VehicleSlotName = VehicleSaveGame.SaveSlotName
    end
    self:SwapVehicleSlotByMode(2)
  end
  self.Subsystem:FlushRegisteredPanelMap()
end
function CustomLayoutModule:DeactivateInGame()
  print(bWriteLog and "CustomLayoutModule:DeactivateInGame")
  self._ModName = nil
  self.bDisableCustomLayout = nil
  self.DomainToCustomTypes = nil
  self._OverriddenCustomTypes = nil
  self.CharacterSlotName = nil
  self.VehicleSlotName = nil
  self.CurrentModCustomLayout = nil
  if self.Subsystem and slua.isValid(self.Subsystem) then
    self.Subsystem:ClearRegisteredPanelMap()
    self.Subsystem:ClearUserSettingSlots()
  end
  self:RemoveAllSettingOptionEvent()
end
function CustomLayoutModule:OnCharacterSlotSettingChanged()
  local NewSlotName = Setting_UIElemLayout_Interface.GetSlotName_New(Setting_UIElemLayout_Interface.GetInGameCurrentLayoutContext())
  if NewSlotName == self.CharacterSlotName then
    return
  end
  local Num = self.Subsystem.UserSettingSlots:Num()
  for i = 0, Num - 1 do
    local Slot = self.Subsystem.UserSettingSlots:Get(i)
    if Slot.SaveSlotName == self.CharacterSlotName then
      local NewSaveGame = Setting_UIElemLayout_Interface.GetSaveGame(NewSlotName, true)
      if slua.isValid(NewSaveGame) then
        self.Subsystem.UserSettingSlots:Set(i, NewSaveGame)
        self.CharacterSlotName = NewSaveGame.SaveSlotName
        print(bWriteLog and "CustomLayoutModule:OnCharacterSlotSettingChanged swapped to " .. NewSaveGame.SaveSlotName)
        self:BroadcastCustomLayoutChangeByDomain(SaveDomain.Character)
      end
      return
    end
  end
end
function CustomLayoutModule:SwapVehicleSlotByMode(NewMode)
  local NewSlotName = Setting_UIElemLayout_Interface.GetSlotName_New({
    LayoutType = CustomLayoutType.Vehicle,
    VehicleMode = NewMode
  })
  if NewSlotName == self.VehicleSlotName then
    return
  end
  local Num = self.Subsystem.UserSettingSlots:Num()
  for i = 0, Num - 1 do
    local Slot = self.Subsystem.UserSettingSlots:Get(i)
    if slua.isValid(Slot) and Slot.SaveSlotName == self.VehicleSlotName then
      local NewSaveGame = Setting_UIElemLayout_Interface.GetSaveGame(NewSlotName, true)
      if slua.isValid(NewSaveGame) then
        self.Subsystem.UserSettingSlots:Set(i, NewSaveGame)
        self.VehicleSlotName = NewSaveGame.SaveSlotName
        print(bWriteLog and "CustomLayoutModule:SwapVehicleSlotByMode swapped to " .. NewSaveGame.SaveSlotName)
        self:BroadcastCustomLayoutChangeByDomain(SaveDomain.VH_General)
        if NewMode == 1 then
          self:BroadcastCustomLayoutChangeByDomain(SaveDomain.VH_SW)
        elseif NewMode == 2 then
          self:BroadcastCustomLayoutChangeByDomain(SaveDomain.VH_JC)
        elseif NewMode == 3 then
          self:BroadcastCustomLayoutChangeByDomain(SaveDomain.VH_BC)
        end
      end
      return
    end
  end
end
function CustomLayoutModule:GetUserSettingInSlot(SlotName)
  if not self.Subsystem or not slua.isValid(self.Subsystem) then
    return nil
  end
  local SlotNum = self.Subsystem.UserSettingSlots:Num()
  for i = 0, SlotNum - 1 do
    local Slot = self.Subsystem.UserSettingSlots:Get(i)
    if slua.isValid(Slot) and Slot.SaveSlotName == SlotName then
      return Slot
    end
  end
  return nil
end
function CustomLayoutModule:GetLayoutDetailByType(InCustomType)
  if self.bDisableCustomLayout then
    return false
  end
  local bFound, LayoutDetail = self.Subsystem:FindLayoutDetail(InCustomType, {})
  if bFound then
    return LayoutDetail
  end
  print(bWriteLog and "CustomLayoutModule:GetLayoutDetailByType " .. tostring(InCustomType) .. " not found in slots")
  return false
end
function CustomLayoutModule:BroadcastCustomLayoutChangeByDomain(InDomain)
  if not self.Subsystem or not slua.isValid(self.Subsystem) then
    return
  end
  if not self.DomainToCustomTypes then
    return
  end
  local CustomTypeList = self.DomainToCustomTypes[InDomain]
  if CustomTypeList and 0 < #CustomTypeList then
    self.Subsystem:BroadcastCustomLayoutChange(CustomTypeList)
  end
end
function CustomLayoutModule:BroadcastCustomLayoutChangeByCustomTypeList(InList)
  if self.Subsystem and slua.isValid(self.Subsystem) then
    self.Subsystem:BroadcastCustomLayoutChange(InList)
  end
end
function CustomLayoutModule:PrepareInGameConfig(ModName)
  local ConfigTool = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfigTool")
  local LayoutConfig = ConfigTool.GetLayoutConfig(ModName)
  self.DomainToCustomTypes = {}
  self._bHasModDomain = false
  self._OverriddenCustomTypes = {}
  for InCustomType, Config in pairs(LayoutConfig.SlotRegistry) do
    local InDomain = Config.SaveDomain
    if InDomain and InDomain ~= SaveDomain.None then
      if not self.DomainToCustomTypes[InDomain] then
        self.DomainToCustomTypes[InDomain] = {}
      end
      self.DomainToCustomTypes[InDomain][#self.DomainToCustomTypes[InDomain] + 1] = InCustomType
      if InDomain == SaveDomain.Mod then
        self._bHasModDomain = true
      end
    end
    if Config.__mod then
      self._OverriddenCustomTypes[#self._OverriddenCustomTypes + 1] = InCustomType
    end
  end
end
function CustomLayoutModule:PullCustomLayoutInMod(ModName, Delegate)
  if not ModName then
    return
  end
  local SlotName = Setting_UIElemLayout_Interface.GetSlotNameByDomain(SaveDomain.Mod, {ModName = ModName})
  local LocalSave = Setting_UIElemLayout_Interface.GetSaveGame(SlotName)
  if slua.isValid(LocalSave) then
    self.CurrentModCustomLayout = LocalSave
  end
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  print(bWriteLog and "CustomLayoutModule:PullCustomLayoutInMod " .. ModName)
  logic_battle_data_transmission:GetOrReqPlayerGeneralData(ModName, function(bSuccess, DataCopy)
    if not bSuccess then
      print(bWriteLog and "CustomLayoutModule:PullCustomLayoutInMod failed " .. ModName)
    end
    if bSuccess and DataCopy.CustomLayout then
      print(bWriteLog and "CustomLayoutModule:PullCustomLayoutInMod loaded from cloud " .. ModName)
      local CustomLayoutArchiver = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutArchiver")
      local CustomLayoutUserSettting = CustomLayoutArchiver.LoadSaveGameFromTable(DataCopy.CustomLayout, SlotName)
      if slua.isValid(CustomLayoutUserSettting) and (not slua.isValid(LocalSave) or CustomLayoutUserSettting:GetTimeTagAsUnixTimestamp() > LocalSave:GetTimeTagAsUnixTimestamp()) then
        self.CurrentModCustomLayout = CustomLayoutUserSettting
        CustomLayoutArchiver.SaveFile(CustomLayoutUserSettting)
      end
    elseif bSuccess then
      print(bWriteLog and "CustomLayoutModule:PullCustomLayoutInMod not in cloud")
    end
    if not self.CurrentModCustomLayout then
      self.CurrentModCustomLayout = Setting_UIElemLayout_Interface.GetSaveGame(SlotName, true)
    end
    Delegate()
  end)
end
function CustomLayoutModule:PushCustomLayoutInMod(ModName, CustomLayoutUserSetting)
  if not ModName then
    return
  end
  CustomLayoutUserSetting = CustomLayoutUserSetting or self.CurrentModCustomLayout
  if not CustomLayoutUserSetting or not slua.isValid(CustomLayoutUserSetting) then
    return
  end
  Setting_UIElemLayout_Interface.SaveUIElemLayoutSG(CustomLayoutUserSetting)
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  print(bWriteLog and "CustomLayoutModule:PushCustomLayoutInMod ", ModName)
  logic_battle_data_transmission:GetOrReqPlayerGeneralData(ModName, function(bSuccess, DataCopy)
    print(bWriteLog and "CustomLayoutModule:PushCustomLayoutInMod bSuccess = " .. tostring(bSuccess))
    if bSuccess then
      DataCopy = DataCopy or {}
      local CustomLayoutArchiver = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutArchiver")
      local LocalSaveTable = CustomLayoutArchiver.CreateTableFromSaveGame(CustomLayoutUserSetting)
      local CloudSaveTable = DataCopy.CustomLayout
      if CloudSaveTable and CloudSaveTable.t then
        if CloudSaveTable.t < LocalSaveTable.t then
          DataCopy.CustomLayout = LocalSaveTable
          logic_battle_data_transmission:SetPlayerGeneralData(ModName, DataCopy)
        end
      else
        DataCopy.CustomLayout = LocalSaveTable
        logic_battle_data_transmission:SetPlayerGeneralData(ModName, DataCopy)
      end
      print(bWriteLog and "CustomLayoutModule:PushCustomLayoutInMod - Successfully pushed " .. ModName)
    end
  end)
end
function CustomLayoutModule:GetTouchStatFilePath(SlotName, ViewportSize)
  if not ViewportSize then
    local UIUtil = require("client.common.ui_util")
    ViewportSize = UIUtil.GetViewportSize()
  end
  if not SlotName then
    local Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
    SlotName = Interface.GetSlotName_New(Interface.GetInGameCurrentLayoutContext())
  end
  return string.format("Statistics/TouchStat/TouchStat_%s_%d_%d", SlotName, math.floor(ViewportSize.X), math.floor(ViewportSize.Y))
end
function CustomLayoutModule:GetTouchStatData()
  local Path = self:GetTouchStatFilePath()
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  print(bWriteLog and "CustomLayoutModule:GetTouchStatData " .. Path)
  local TouchStatTable
  require("client.common.game_status")
  if GameStatus.IsInFightingStatus() then
    TouchStatTable = self:CollectAndSaveTouchStat()
  else
    TouchStatTable = TableArchiver.LoadFile(Path) or {}
  end
  return TouchStatTable
end
function CustomLayoutModule:CollectAndSaveTouchStat()
  local Path = self:GetTouchStatFilePath()
  print(bWriteLog and "CustomLayoutModule:CollectAndSaveTouchStat " .. Path)
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  local TouchStatTable = TableArchiver.LoadFile(Path) or {}
  local bSuccessful = self:CollectTouchStat(TouchStatTable)
  if bSuccessful then
    TableArchiver.SaveFile(Path, TouchStatTable)
  end
  return TouchStatTable
end
function CustomLayoutModule:RemoveTouchStatData(InCustomType)
  local TableArchiver = require("client.logic.NewSetting.TableArchiver")
  local TouchStatTable = TableArchiver.LoadFile(self:GetTouchStatFilePath())
  if TouchStatTable and TouchStatTable[InCustomType] then
    TouchStatTable[InCustomType] = nil
    TableArchiver.SaveFile(self:GetTouchStatFilePath(), TouchStatTable)
    return true
  end
  return false
end
function CustomLayoutModule:RemoveAllTouchStatData()
  Client.DeleteFile(Client.ProjectSavedDir() .. self:GetTouchStatFilePath())
end
function CustomLayoutModule:CollectTouchStat(TouchStatTable)
  if not self.Subsystem or not slua.isValid(self.Subsystem) then
    return false
  end
  if not self.Subsystem.bActive then
    return false
  end
  local CurrentTouchStatArrayLength = self.Subsystem.TouchStatArray:Num()
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
    local TouchStatInfo = self.Subsystem.TouchStatArray:Get(i)
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
  self.Subsystem:ClearTouchStatArray()
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, CustomLayoutModule)
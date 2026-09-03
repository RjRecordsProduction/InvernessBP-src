local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local SaveDomain = require("client.logic.setting.CustomLayoutSaveDomain")
local CustomLayoutArchiver = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutArchiver")
local SlotIndex2Name = {
  [1] = "UIElemLayout_Slot",
  [2] = "UIElemLayout_Slot01",
  [3] = "UIElemLayout_Slot02",
  [4] = "UIElemLayout_Slot03",
  [5] = "UIElemLayout_Slot04",
  [6] = "UIElemLayout_Slot05",
  [7] = "UIElemLayout_Slot06",
  [8] = "UIElemLayout_Slot07",
  [9] = "UIElemLayout_Slot08",
  [10] = "UIElemLayout_Slot09",
  [11] = "UIElemLayout_Slot10"
}
local Old2NewNamePrefix = {
  UIElemLayout_Slot = "NCL_CL_L0",
  UIElemLayout_Slot01 = "NCL_CL_L1",
  UIElemLayout_Slot02 = "NCL_CL_L2",
  UIElemLayout_Slot03 = "NCL_CLF_L0",
  UIElemLayout_Slot04 = "NCL_CLF_L1",
  UIElemLayout_Slot05 = "NCL_CLF_L2",
  UIElemLayout_Slot06 = "NCL_TD",
  UIElemLayout_Slot07 = "NCL_TDF",
  UIElemLayout_Slot08 = "NCL_VH",
  UIElemLayout_Slot09 = "NCL_WC"
}
local CustomSlotIndex = {
  ClassicTPP = 1,
  ClassicFPP = 4,
  TDTPP = 7,
  TDFPP = 8,
  Vehicle = 9,
  UGC = 10
}
local Setting_UIElemLayout_Interface = {}
function Setting_UIElemLayout_Interface.GetSlotNameByIndex_Legacy(Index)
  return SlotIndex2Name[Index]
end
local GetUserLayoutIndex = function(IsFPP, ControlMode, CurCustomLayoutType)
  if CurCustomLayoutType == CustomLayoutType.Classic then
    local result = 0
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    if IsFPP then
      if ControlMode == 1 then
        result = SettingModule:GetOptionValue("SelectUIElemIndexFPP1")
      elseif ControlMode == 2 then
        result = SettingModule:GetOptionValue("SelectUIElemIndexFPP2")
      elseif ControlMode == 3 then
        result = SettingModule:GetOptionValue("SelectUIElemIndexFPP3")
      else
        result = SettingModule:GetOptionValue("SelectUIElemIndexFPP1")
      end
    elseif ControlMode == 1 then
      result = SettingModule:GetOptionValue("SelectUIElemIndex1")
    elseif ControlMode == 2 then
      result = SettingModule:GetOptionValue("SelectUIElemIndex2")
    elseif ControlMode == 3 then
      result = SettingModule:GetOptionValue("SelectUIElemIndex3")
    else
      result = SettingModule:GetOptionValue("SelectUIElemIndex1")
    end
    return result
  else
    return nil
  end
end
Setting_UIElemLayout_Interface.
function Setting_UIElemLayout_Interface.SaveSelectUIElemIndex(LayoutIndex, ControlMode, CurCustomLayoutType)
  if CurCustomLayoutType ~= CustomLayoutType.Classic then
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  if ControlMode == 1 then
    SettingModule:SetOptionValue("SelectUIElemIndexFPP1", LayoutIndex)
  elseif ControlMode == 2 then
    SettingModule:SetOptionValue("SelectUIElemIndexFPP2", LayoutIndex)
  elseif ControlMode == 3 then
    SettingModule:SetOptionValue("SelectUIElemIndexFPP3", LayoutIndex)
  end
  if ControlMode == 1 then
    SettingModule:SetOptionValue("SelectUIElemIndex1", LayoutIndex)
  elseif ControlMode == 2 then
    SettingModule:SetOptionValue("SelectUIElemIndex2", LayoutIndex)
  elseif ControlMode == 3 then
    SettingModule:SetOptionValue("SelectUIElemIndex3", LayoutIndex)
  end
end
function Setting_UIElemLayout_Interface.GetInGameCurrentLayoutContext()
  local CharacterLayoutType = CustomLayoutType.Classic
  local CharacterControlMode = 1
  local CharacterLayoutIndex = 0
  local IsFPP = false
  local ModName
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if GamePlayTools.IsTDMode() then
    CharacterLayoutType = CustomLayoutType.TD
  elseif GamePlayTools.IsUGCMode() then
    CharacterLayoutType = CustomLayoutType.UGC
  end
  IsFPP = GamePlayTools.IsForcedFPP()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  CharacterControlMode = SettingModule:GetOptionValue("FireMode")
  CharacterLayoutIndex = GetUserLayoutIndex(IsFPP, CharacterControlMode, CharacterLayoutType)
  local VehicleControlMode = SettingModule:GetOptionValue("VehicleControlMode")
  local VehicleControlUISubsystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  VehicleControlMode = VehicleControlUISubsystem and VehicleControlUISubsystem:GetVehicleModeInUsing() or VehicleControlMode
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  ModName = GameMainConfig.GetModType()
  if ModName == "BaseMod" then
    ModName = nil
  end
  return {
    LayoutType = CharacterLayoutType,
    ControlMode = CharacterControlMode,
    VehicleMode = VehicleControlMode,
    bIsFPP = IsFPP,
    LayoutIndex = CharacterLayoutIndex,
      }
end
local GetLayoutName = function(aCustomLayoutType, LayoutIndex)
  if aCustomLayoutType == CustomLayoutType.Classic then
    if LayoutIndex % 3 == 0 then
      return LocUtil.GetLocalizeResStr(110421)
    elseif LayoutIndex % 3 == 1 then
      return LocUtil.GetLocalizeResStr(110422)
    elseif LayoutIndex % 3 == 2 then
      return LocUtil.GetLocalizeResStr(6319)
    end
  elseif aCustomLayoutType == CustomLayoutType.Vehicle then
    return LocUtil.GetLocalizeResStr(11484)
  else
    return LocUtil.GetLocalizeResStr(110417)
  end
end
Setting_UIElemLayout_Interface.
function Setting_UIElemLayout_Interface.GetSlotName_Legacy(Context)
  local InCustomLayoutType = Context.LayoutType
  local bIsFPP = Context.bIsFPP
  local LayoutIndex = Context.LayoutIndex
  if InCustomLayoutType == CustomLayoutType.Classic then
    if bIsFPP then
      return SlotIndex2Name[CustomSlotIndex.ClassicFPP + LayoutIndex]
    else
      return SlotIndex2Name[CustomSlotIndex.ClassicTPP + LayoutIndex]
    end
  elseif InCustomLayoutType == CustomLayoutType.TD then
    if bIsFPP then
      return SlotIndex2Name[CustomSlotIndex.TDFPP]
    else
      return SlotIndex2Name[CustomSlotIndex.TDTPP]
    end
  elseif InCustomLayoutType == CustomLayoutType.Vehicle then
    return SlotIndex2Name[CustomSlotIndex.Vehicle]
  elseif InCustomLayoutType == CustomLayoutType.UGC then
    return SlotIndex2Name[CustomSlotIndex.UGC]
  end
end
function Setting_UIElemLayout_Interface.GetSlotName_New(Context)
  local InCustomLayoutType = Context.LayoutType
  local ControlMode = Context.ControlMode
  local VehicleMode = Context.VehicleMode
  local bIsFPP = Context.bIsFPP
  if InCustomLayoutType == CustomLayoutType.Classic then
    if bIsFPP then
      return string.format("NCL_CLF_L%d_C%d", Context.LayoutIndex, ControlMode)
    else
      return string.format("NCL_CL_L%d_C%d", Context.LayoutIndex, ControlMode)
    end
  elseif InCustomLayoutType == CustomLayoutType.TD then
    if bIsFPP then
      return string.format("NCL_TDF_C%d", ControlMode)
    else
      return string.format("NCL_TD_C%d", ControlMode)
    end
  elseif InCustomLayoutType == CustomLayoutType.Vehicle and VehicleMode then
    return string.format("NCL_VH_C%d", VehicleMode)
  elseif InCustomLayoutType == CustomLayoutType.UGC then
    return string.format("NCL_WC_C%d", ControlMode)
  elseif InCustomLayoutType == CustomLayoutType.Standalone and Context.ModName then
    return string.format("NCL_MOD_%s", Context.ModName)
  end
end
local SlotNamePatternToAcceptedDomains = {
  {
    "^NCL_CL_",
    {
      SaveDomain.Character
    }
  },
  {
    "^NCL_CLF_",
    {
      SaveDomain.Character
    }
  },
  {
    "^NCL_TD_",
    {
      SaveDomain.Character
    }
  },
  {
    "^NCL_TDF_",
    {
      SaveDomain.Character
    }
  },
  {
    "^NCL_WC_",
    {
      SaveDomain.Character
    }
  },
  {
    "^NCL_VH_C1",
    {
      SaveDomain.VH_SW,
      SaveDomain.VH_General
    }
  },
  {
    "^NCL_VH_C2",
    {
      SaveDomain.VH_JC,
      SaveDomain.VH_General
    }
  },
  {
    "^NCL_VH_C3",
    {
      SaveDomain.VH_BC,
      SaveDomain.VH_General
    }
  }
}
local IsDomainAccepted = function(ItemDomain, AcceptedDomains)
  for _, d in ipairs(AcceptedDomains) do
    if ItemDomain == d then
      return true
    end
  end
  return false
end
function Setting_UIElemLayout_Interface.GetSlotNameByDomain(Domain, Context)
  local ControlMode = Context.ControlMode
  if Domain == SaveDomain.Character and ControlMode then
    if Context.LayoutType == CustomLayoutType.Classic then
      if Context.bIsFPP then
        return string.format("NCL_CLF_L%d_C%d", Context.LayoutIndex, ControlMode)
      else
        return string.format("NCL_CL_L%d_C%d", Context.LayoutIndex, ControlMode)
      end
    elseif Context.LayoutType == CustomLayoutType.TD then
      if Context.bIsFPP then
        return string.format("NCL_TDF_C%d", ControlMode)
      else
        return string.format("NCL_TD_C%d", ControlMode)
      end
    elseif Context.LayoutType == CustomLayoutType.UGC then
      return string.format("NCL_WC_C%d", ControlMode)
    end
  elseif Domain == SaveDomain.VH_SW then
    return "NCL_VH_C1"
  elseif Domain == SaveDomain.VH_JC then
    return "NCL_VH_C2"
  elseif Domain == SaveDomain.VH_BC then
    return "NCL_VH_C3"
  elseif Domain == SaveDomain.VH_General and Context.VehicleMode then
    return string.format("NCL_VH_C%d", Context.VehicleMode)
  elseif Domain == SaveDomain.Mod then
    if Context.ModName == "PlanPH" then
      return "NCL_PHP"
    end
    return string.format("NCL_MOD_%s", Context.ModName)
  end
  return nil
end
local GetSaveGame = function(SlotName, bCreateNew)
  if not SlotName or SlotName == "" then
    return
  end
  local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
  local SlotObj = CustomLayoutModule:GetUserSettingInSlot(SlotName)
  if SlotObj then
    return SlotObj
  end
  print(bWriteLog and "Setting_UIElemLayout_Interface.GetSaveGame begin " .. SlotName)
  local SaveGame = CustomLayoutArchiver.LoadFile(SlotName)
  if not SaveGame and bCreateNew then
    local GameplayStatics = import("GameplayStatics")
    local CustomLayoutUserSettingClass = import("CustomLayoutUserSetting")
    SaveGame = GameplayStatics.CreateSaveGameObject(CustomLayoutUserSettingClass)
    print(bWriteLog and " create new CustomLayoutUserSetting object")
  end
  if slua.isValid(SaveGame) then
    print(bWriteLog and "Setting_UIElemLayout_Interface.GetSaveGame Done")
    SaveGame.Save    if string.find(SlotName, "^NCL_CL") then
      SaveGame:RemoveData(75)
    end
  end
  return SaveGame
end
Setting_UIElemLayout_Interface.
function Setting_UIElemLayout_Interface.SaveUIElemLayoutSG(InSaveGame)
  if not slua.isValid(InSaveGame) then
    return
  end
  local SlotName = InSaveGame.SaveSlotName
  if not SlotName or SlotName == "" then
    return
  end
  InSaveGame:UpdateTimeTag()
  local Archive = CustomLayoutArchiver.SaveFile(InSaveGame)
  local bResult = Archive ~= nil
  if bResult then
    print(bWriteLog and "Setting_UIElemLayout_Interface SaveUIElemLayoutSG " .. SlotName .. " Result = " .. tostring(bResult))
  else
    log_error("Setting_UIElemLayout_Interface SaveUIElemLayoutSG failed " .. SlotName)
  end
  return bResult, Archive
end
function Setting_UIElemLayout_Interface.SaveCustomPanelsByDomain(Context, CustomLayoutConfig, CustomPanelList)
  local Result = {
    bSaved = false,
    ArchiveMap = {}
  }
  if not (Context and CustomLayoutConfig) or not CustomPanelList then
    return Result
  end
  local SlotRegistry = CustomLayoutConfig.SlotRegistry
  if not SlotRegistry then
    return Result
  end
  local SlotDataMap = {}
  for _, CustomPanel in ipairs(CustomPanelList) do
    if slua.isValid(CustomPanel) then
      local CustomType = CustomPanel.CustomType
      local CustomConfig = SlotRegistry[CustomType]
      if CustomType < 1000 or CustomConfig.SaveDomain == SaveDomain.Mod then
        local SlotName = Setting_UIElemLayout_Interface.GetSlotNameByDomain(CustomConfig.SaveDomain, Context)
        if SlotName then
          local LayoutDetail = CustomPanel:GetLayoutData()
          if LayoutDetail then
            if not SlotDataMap[SlotName] then
              SlotDataMap[SlotName] = {}
            end
            SlotDataMap[SlotName][CustomType] = LayoutDetail
          end
        end
      end
    end
  end
  for SlotName, DataEntries in pairs(SlotDataMap) do
    local SaveData = GetSaveGame(SlotName, true)
    if slua.isValid(SaveData) then
      for CustomType, LayoutDetail in pairs(DataEntries) do
        SaveData:SetDataByLayoutDetail(CustomType, LayoutDetail)
      end
      local bResult, Archive = Setting_UIElemLayout_Interface.SaveUIElemLayoutSG(SaveData)
      if bResult and Archive then
        Result.bSaved = true
        Result.ArchiveMap[SlotName] = Archive
      end
    end
  end
  return Result
end
function Setting_UIElemLayout_Interface.UploadArchiveMap(ArchiveMap)
  if not ArchiveMap or not next(ArchiveMap) then
    return
  end
  local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
  local SettingSystem = require("client.logic.setting.logic_setting")
  for SlotName, Archive in pairs(ArchiveMap) do
    if string.find(SlotName, "^NCL_MOD_") then
      local ModName = string.sub(SlotName, 9)
      print(bWriteLog and string.format("Setting_UIElemLayout_Interface.UploadArchiveMap PushCustomLayoutInMod ModName=%s", ModName))
      CustomLayoutModule:PushCustomLayoutInMod(ModName)
    else
      print(bWriteLog and string.format("Setting_UIElemLayout_Interface.UploadArchiveMap save_custom_setting SlotName=%s", SlotName))
      SettingSystem.save_custom_setting(Archive, nil, 1, SlotName)
    end
  end
end
function Setting_UIElemLayout_Interface.TryGetSaveGame(Context)
  local SlotName_New = Setting_UIElemLayout_Interface.GetSlotName_New(Context)
  local SaveGame = GetSaveGame(SlotName_New)
  print(bWriteLog and string.format("Setting_UIElemLayout_Interface.TryGetSaveGame %s", SlotName_New or "nil"))
  if not SaveGame then
    local SavEncodeSystem = require("client.logic.setting.SavEncodeSystem")
    local SlotName_Legacy = Setting_UIElemLayout_Interface.GetSlotName_Legacy(Context)
    if SlotName_Legacy then
      if SavEncodeSystem.ValidateSaveFile(SlotName_Legacy) then
        local GameplayStatics = import("GameplayStatics")
        local LegacySaveGame = GameplayStatics.LoadGameFromSlot(SlotName_Legacy, 0)
        if LegacySaveGame and Old2NewNamePrefix[LegacySaveGame.SaveSlotName] then
          local C_Index = tonumber(SlotName_New:match("_C(%d+)$"))
          Setting_UIElemLayout_Interface.ConvertSaveGame(LegacySaveGame, Old2NewNamePrefix[LegacySaveGame.SaveSlotName], C_Index)
          SaveGame = GetSaveGame(SlotName_New)
        end
      end
      Client.DeleteFile(Client.ProjectSavedDir() .. "SaveGames/" .. SlotName_Legacy .. ".sav")
    end
  end
  SaveGame = SaveGame or GetSaveGame(SlotName_New, true)
  return SaveGame
end
function Setting_UIElemLayout_Interface.Sanitize(UserSetting)
  if not slua.isValid(UserSetting) then
    print(bWriteLog and "Setting_UIElemLayout_Interface.Sanitize invalid UserSetting")
    return false
  end
  local SlotName = UserSetting.SaveSlotName
  if not SlotName or SlotName == "" then
    print(bWriteLog and "Setting_UIElemLayout_Interface.Sanitize empty SlotName")
    return false
  end
  local SlotAcceptedDomains
  for _, Entry in ipairs(SlotNamePatternToAcceptedDomains) do
    if string.find(SlotName, Entry[1]) then
      SlotAcceptedDomains = Entry[2]
      break
    end
  end
  if not SlotAcceptedDomains then
    print(bWriteLog and string.format("Setting_UIElemLayout_Interface.Sanitize no accepted domain for %s", SlotName))
    return false
  end
  local ConfigTool = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfigTool")
  local LayoutConfig = ConfigTool.GetLayoutConfig("")
  local SlotRegistry = LayoutConfig.SlotRegistry
  local DeprecatedList = require("client.logic.setting.CustomTypeDeprecatedList")
  local bModified = false
  local CustomType = require("client.logic.setting.CustomType")
  for _, CustomTypeValue in pairs(CustomType) do
    if type(CustomTypeValue) == "number" and UserSetting:Contains(CustomTypeValue) then
      local bShouldRemove = false
      if not bShouldRemove then
        local CustomConfig = SlotRegistry[CustomTypeValue]
        if CustomConfig and CustomConfig.SaveDomain and not IsDomainAccepted(CustomConfig.SaveDomain, SlotAcceptedDomains) then
          bShouldRemove = true
        end
      end
      if bShouldRemove then
        UserSetting:RemoveData(CustomTypeValue)
        bModified = true
      end
    end
  end
  for _, DeprecatedType in ipairs(DeprecatedList) do
    UserSetting:RemoveData(DeprecatedType)
    bModified = true
  end
  if not string.find(SlotName, "^NCL_MOD_") and SlotName ~= "NCL_PHP" then
    local CustomTypeList = UserSetting:GetCustomTypeList({})
    for _, _CustomType in pairs(CustomTypeList) do
      if 1000 <= _CustomType then
        UserSetting:RemoveData(_CustomType)
        bModified = true
      end
    end
  end
  print(bWriteLog and string.format("Setting_UIElemLayout_Interface.Sanitize %s bModified=%s", SlotName, tostring(bModified)))
  return bModified
end
function Setting_UIElemLayout_Interface.ReformJoystickAndSprintTrigger(UserSetting)
  local bModified = false
  local LayoutData_Joystick = UserSetting:GetDataAsLayoutDetail(2)
  local Joystick_Pos = LayoutData_Joystick.Type == 2 and LayoutData_Joystick.RelativePos
  if Joystick_Pos and math.abs(Joystick_Pos.X) < 1.01 and 1.01 > math.abs(Joystick_Pos.Y) then
    local UIUtil = require("client.common.ui_util")
    local ViewportSizebyScale = UIUtil.GetViewportSizebyScale()
    LayoutData_Joystick.RelativePos = FVector2D(ViewportSizebyScale.X * Joystick_Pos.X, ViewportSizebyScale.Y * (Joystick_Pos.Y - 1))
    LayoutData_Joystick.AnchorType = FAnchors(0, 1, 0, 1)
    UserSetting:SetDataByLayoutDetail(2, LayoutData_Joystick)
    bModified = true
  end
  local LayoutData_SprintTrigger = UserSetting:GetDataAsLayoutDetail(30)
  if LayoutData_SprintTrigger and LayoutData_SprintTrigger.Type == 30 and LayoutData_SprintTrigger.RelativePos.X == 0 then
    if Joystick_Pos then
      LayoutData_SprintTrigger.RelativePos.X = Joystick_Pos.X
      LayoutData_SprintTrigger.RelativePos.Y = Joystick_Pos.Y - LayoutData_SprintTrigger.RelativePos.Y
    else
      LayoutData_SprintTrigger.RelativePos.X = 225.0
      LayoutData_SprintTrigger.RelativePos.Y = -195.0 - LayoutData_SprintTrigger.RelativePos.Y
    end
    LayoutData_SprintTrigger.AnchorType = FAnchors(0, 1, 0, 1)
    UserSetting:SetDataByLayoutDetail(30, LayoutData_SprintTrigger)
    bModified = true
  end
  return bModified
end
function Setting_UIElemLayout_Interface.ConvertOneDictToSaveGame(BPSaveGame, DictIndex)
  if not slua.isValid(BPSaveGame) or type(DictIndex) ~= "number" then
    return nil
  end
  local DictField = BPSaveGame["LayoutDetailDict" .. DictIndex]
  if not DictField or DictField:Num() <= 0 then
    return nil
  end
  local SettingCustomPanelBPClass = import("/Game/UMG/UI_BP/Setting/UILayout/BP_SettingCustomPanel.BP_SettingCustomPanel_C")
  local GameplayStatics = import("GameplayStatics")
  local CustomLayoutUserSettingClass = import("CustomLayoutUserSetting")
  local TempInvalidMap = {}
  local InvalidField = BPSaveGame["InvalidArray" .. DictIndex]
  if InvalidField then
    for _, k in pairs(InvalidField) do
      TempInvalidMap[k] = true
    end
  end
  local NewSaveGame = GameplayStatics.CreateSaveGameObject(CustomLayoutUserSettingClass)
  for k, v in pairs(DictField) do
    local Detail = SettingCustomPanelBPClass.BPStructToCPP(v)
    if TempInvalidMap[k] then
      Detail.Invalid = true
    end
    NewSaveGame:SetDataByLayoutDetail(k, Detail)
  end
  return NewSaveGame
end
function Setting_UIElemLayout_Interface.ConvertSaveGame(BPSaveGame, NewSlotNamePrefix, DictIndex)
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertSaveGame - Start conversion for slot: " .. NewSlotNamePrefix, DictIndex)
  for i = 1, 3 do
    if not DictIndex or DictIndex == i then
      local NewSaveGame = Setting_UIElemLayout_Interface.ConvertOneDictToSaveGame(BPSaveGame, i)
      if NewSaveGame then
        NewSaveGame.SaveSlotName = NewSlotNamePrefix .. "_C" .. tostring(i)
        local bResult, Archive = Setting_UIElemLayout_Interface.SaveUIElemLayoutSG(NewSaveGame)
        if bResult and Archive then
          local SettingSystem = require("client.logic.setting.logic_setting")
          SettingSystem.save_custom_setting(Archive, nil, 1, NewSaveGame.SaveSlotName)
        end
      end
    end
  end
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertSaveGame - Conversion completed")
end
function Setting_UIElemLayout_Interface.RemoveBuggyFile()
  print(bWriteLog and "Setting_UIElemLayout_Interface.RemoveBuggyFile")
  local DirectoryPath = Client.ProjectSavedDir() .. "/SaveGames/CustomLayout/"
  for _, FileNamePrefix in pairs(Old2NewNamePrefix) do
    Client.DeleteFile(DirectoryPath .. FileNamePrefix)
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_delete_custom_setting(FileNamePrefix)
  end
end
function Setting_UIElemLayout_Interface.ConvertAllSaveGame()
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertAllSaveGame - Start converting all save games")
  local DirectoryPath = Client.ProjectSavedDir() .. "/SaveGames/CustomLayout/"
  for _, FileNamePrefix in pairs(Old2NewNamePrefix) do
    Client.DeleteFile(DirectoryPath .. FileNamePrefix)
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_delete_custom_setting(FileNamePrefix)
  end
  local conversionCount = 0
  for OldFileName, NewPrefix in pairs(Old2NewNamePrefix) do
    local OldSaveGame = GetSaveGame(OldFileName)
    if OldSaveGame then
      Setting_UIElemLayout_Interface.ConvertSaveGame(OldSaveGame, NewPrefix)
      conversionCount = conversionCount + 1
    end
  end
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertAllSaveGame - Completed " .. tostring(conversionCount) .. " conversions")
end
return Setting_UIElemLayout_Interface
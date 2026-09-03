local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local SavEncodeSystem = require("client.logic.setting.SavEncodeSystem")
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
local CompareLayoutDetail = function(A, B)
  if math.abs(A.RelativePos.X - B.RelativePos.X) > 1 then
    return true
  elseif 1 < math.abs(A.RelativePos.Y - B.RelativePos.Y) then
    return true
  elseif math.abs(A.Scale.X - B.Scale.X) > 0.01 then
    return true
  elseif math.abs(A.Scale.Y - B.Scale.Y) > 0.01 then
    return true
  elseif 0.01 < math.abs(A.Opacity - B.Opacity) then
    return true
  elseif 0.01 < math.abs(A.AnchorType.Minimum.X - B.AnchorType.Minimum.X) then
    return true
  elseif 0.01 < math.abs(A.AnchorType.Minimum.Y - B.AnchorType.Minimum.Y) then
    return true
  elseif 0.01 < math.abs(A.AnchorType.Maximum.X - B.AnchorType.Maximum.X) then
    return true
  elseif 0.01 < math.abs(A.AnchorType.Maximum.Y - B.AnchorType.Maximum.Y) then
    return true
  end
end
Setting_UIElemLayout_Interface.local CopyLayoutDetail = function(Target, Source)
  Target.RelativePos = Source.RelativePos
  Target.Scale = Source.Scale
  Target.Opacity = Source.Opacity
  Target.AnchorType = Source.AnchorType
end
Setting_UIElemLayout_Interface.local GetUserLayoutIndex = function(IsFPP, ControlMode, CurCustomLayoutType)
  local result = 0
  if CurCustomLayoutType == CustomLayoutType.Classic then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if IsFPP then
      if ControlMode == 1 then
        result = SettingConfig.SelectUIElemIndexFPP1
      elseif ControlMode == 2 then
        result = SettingConfig.SelectUIElemIndexFPP2
      elseif ControlMode == 3 then
        result = SettingConfig.SelectUIElemIndexFPP3
      else
        result = SettingConfig.SelectUIElemIndexFPP1
      end
    elseif ControlMode == 1 then
      result = SettingConfig.SelectUIElemIndex1
    elseif ControlMode == 2 then
      result = SettingConfig.SelectUIElemIndex2
    elseif ControlMode == 3 then
      result = SettingConfig.SelectUIElemIndex3
    else
      result = SettingConfig.SelectUIElemIndex1
    end
  end
  if not result then
    log_error_format("Setting_UIElemLayout_Interface.GetUserLayoutIndex nil result %s %s %s", tostring(IsFPP), tostring(ControlMode), tostring(CurCustomLayoutType))
    result = 0
  end
  return result
end
Setting_UIElemLayout_Interface.
function Setting_UIElemLayout_Interface.SaveSelectUIElemIndex(IsFPP, LayoutIndex, CurCustomLayoutType)
  if CurCustomLayoutType ~= CustomLayoutType.Classic then
    return
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not SettingConfig then
    return
  end
  if IsFPP then
    if SettingConfig.FireMode == 1 then
      SettingConfig.SelectUIElemIndexFPP1 = LayoutIndex
    elseif SettingConfig.FireMode == 2 then
      SettingConfig.SelectUIElemIndexFPP2 = LayoutIndex
    elseif SettingConfig.FireMode == 3 then
      SettingConfig.SelectUIElemIndexFPP3 = LayoutIndex
    end
  elseif SettingConfig.FireMode == 1 then
    SettingConfig.SelectUIElemIndex1 = LayoutIndex
  elseif SettingConfig.FireMode == 2 then
    SettingConfig.SelectUIElemIndex2 = LayoutIndex
  elseif SettingConfig.FireMode == 3 then
    SettingConfig.SelectUIElemIndex3 = LayoutIndex
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_UIElemLayout_Interface.GetInGameCharacterLayoutInfo()
  local CharacterLayoutType = CustomLayoutType.Classic
  local CharacterControlMode = 1
  local CharacterLayoutIndex = 0
  local IsFPP = false
  local EGameModeType = import("EGameModeType")
  local GameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(GameState) then
    if GameState.GameModeType == EGameModeType.EDeathMatchGameMode then
      CharacterLayoutIndex = 0
      CharacterLayoutType = CustomLayoutType.TD
    elseif GameState.GameModeType == EGameModeType.ECreativeModeGameMode then
      CharacterLayoutIndex = 0
      CharacterLayoutType = CustomLayoutType.UGC
    end
    IsFPP = GameState.IsFPPGameMode
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    CharacterControlMode = SettingConfig.FireMode
    CharacterLayoutIndex = GetUserLayoutIndex(IsFPP, CharacterControlMode, CharacterLayoutType)
  end
  return CharacterLayoutType, CharacterControlMode, IsFPP, CharacterLayoutIndex
end
local GetSlotIndex = function(aCustomLayoutType, bIsFPP, LayoutIndex)
  if aCustomLayoutType == CustomLayoutType.Classic then
    if bIsFPP then
      return CustomSlotIndex.ClassicFPP + LayoutIndex
    else
      return CustomSlotIndex.ClassicTPP + LayoutIndex
    end
  elseif aCustomLayoutType == CustomLayoutType.TD then
    if bIsFPP then
      return CustomSlotIndex.TDFPP
    else
      return CustomSlotIndex.TDTPP
    end
  elseif aCustomLayoutType == CustomLayoutType.Vehicle then
    return CustomSlotIndex.Vehicle
  elseif aCustomLayoutType == CustomLayoutType.UGC then
    return CustomSlotIndex.UGC
  elseif aCustomLayoutType == CustomLayoutType.SpecialCharacter then
    return CustomSlotIndex.ClassicTPP
  elseif aCustomLayoutType == CustomLayoutType.Standalone then
    return 11
  end
end
Setting_UIElemLayout_Interface.local GetLayoutName = function(aCustomLayoutType, LayoutIndex)
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
Setting_UIElemLayout_Interface.local GetLayoutNameBySlotIndex = function(SlotIndex)
  if SlotIndex <= 6 then
    if SlotIndex % 3 == 1 then
      return LocUtil.GetLocalizeResStr(110421)
    elseif SlotIndex % 3 == 2 then
      return LocUtil.GetLocalizeResStr(110422)
    elseif SlotIndex % 3 == 0 then
      return LocUtil.GetLocalizeResStr(6319)
    end
  elseif SlotIndex == CustomSlotIndex.Vehicle then
    return LocUtil.GetLocalizeResStr(11484)
  else
    return LocUtil.GetLocalizeResStr(110417)
  end
end
Setting_UIElemLayout_Interface.
function Setting_UIElemLayout_Interface.GetSlotName_New(InCustomLayoutType, ControlMode, bIsFPP, LayoutIndex, ModName)
  if InCustomLayoutType == CustomLayoutType.Classic then
    if bIsFPP then
      return string.format("NCL_CLF_L%d_C%d", LayoutIndex, ControlMode)
    else
      return string.format("NCL_CL_L%d_C%d", LayoutIndex, ControlMode)
    end
  elseif InCustomLayoutType == CustomLayoutType.TD then
    if bIsFPP then
      return string.format("NCL_TDF_C%d", ControlMode)
    else
      return string.format("NCL_TD_C%d", ControlMode)
    end
  elseif InCustomLayoutType == CustomLayoutType.Vehicle then
    return string.format("NCL_VH_C%d", ControlMode)
  elseif InCustomLayoutType == CustomLayoutType.UGC then
    return string.format("NCL_WC_C%d", ControlMode)
  elseif InCustomLayoutType == CustomLayoutType.SpecialCharacter then
    return string.format("NCL_CL_L0_C1")
  elseif InCustomLayoutType == CustomLayoutType.Standalone and ModName then
    local ConfigTool = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfigTool")
    local CustomLayoutConfig = ConfigTool.GetLayoutConfig(ModName)
    if CustomLayoutConfig.SavAlias and type(CustomLayoutConfig.SavAlias) == "string" then
      return string.format("NCL_%s", CustomLayoutConfig.SavAlias)
    end
  end
end
function Setting_UIElemLayout_Interface.GetSlotName_Legacy(InCustomLayoutType, ControlMode, bIsFPP, LayoutIndex)
  local SlotIndex = GetSlotIndex(InCustomLayoutType, bIsFPP, LayoutIndex)
  return SlotIndex2Name[SlotIndex]
end
local GetSaveGame = function(SlotName, bCreateNew, bIgnoreCache)
  if not SlotName or SlotName == "" then
    return
  end
  local GameplayStatics = import("GameplayStatics")
  local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
  if not slua.isValid(SettingSubsystem_CPP) then
    return nil
  end
  print(bWriteLog and "Setting_UIElemLayout_Interface.GetSaveGame begin " .. SlotName)
  local SaveGame
  if not bIgnoreCache then
    SaveGame = SettingSubsystem_CPP:GetCustomSetting(SlotName)
    if slua.isValid(SaveGame) then
      print(bWriteLog and "HitCache")
      return SaveGame
    end
  end
  if string.find(SlotName, "UIElemLayout_Slot") then
    if SavEncodeSystem.ValidateSaveFile(SlotName) then
      SaveGame = GameplayStatics.LoadGameFromSlot(SlotName, 0)
      print(bWriteLog and "  load from file")
    else
      Client.DeleteFile(Client.ProjectSavedDir() .. "SaveGames/" .. SlotName .. ".sav")
    end
    if not SaveGame and bCreateNew then
      local SaveGameUIElemlayoutClass = import("/Game/BluePrints/Config/UIElemLayout/BP_SAVEGAME_UIElemLayout.BP_SAVEGAME_UIElemLayout_C")
      SaveGame = GameplayStatics.CreateSaveGameObject(SaveGameUIElemlayoutClass)
      print(bWriteLog and " create new BP_SAVEGAME_UIElemLayout object")
    end
  else
    SaveGame = CustomLayoutArchiver.LoadFile(SlotName)
    if SaveGame then
      print(bWriteLog and " load from file ")
    elseif bCreateNew then
      local CustomLayoutSaveGameClass = import("CustomLayoutSaveGame")
      SaveGame = GameplayStatics.CreateSaveGameObject(CustomLayoutSaveGameClass)
      print(bWriteLog and " create new CustomLayoutSaveGame object")
    end
  end
  if slua.isValid(SaveGame) then
    print(bWriteLog and "Setting_UIElemLayout_Interface.GetSaveGame Done")
    SaveGame.Save    if not bIgnoreCache then
      local bUpdateResult = SettingSubsystem_CPP:UpdateCustomSetting(SlotName, SaveGame)
      if not bUpdateResult then
        SettingSubsystem_CPP:AddCustomSetting(SlotName, SaveGame)
      end
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
  local GameplayStatics = import("GameplayStatics")
  local bResult, Archive
  if string.find(SlotName, "UIElemLayout_Slot") then
    bResult = GameplayStatics.SaveGameToSlot(InSaveGame, SlotName, 0)
  else
    Archive = CustomLayoutArchiver.SaveFile(InSaveGame)
    bResult = Archive ~= nil
  end
  if bResult then
    local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
    if slua.isValid(SettingSubsystem_CPP) then
      local bUpdateResult = SettingSubsystem_CPP:UpdateCustomSetting(SlotName, InSaveGame)
      if not bUpdateResult then
        SettingSubsystem_CPP:AddCustomSetting(SlotName, InSaveGame)
      end
      print(bWriteLog and "Setting_UIElemLayout_Interface SaveUIElemLayoutSG " .. SlotName .. " Result = " .. tostring(bResult) .. " bUpdateResult = " .. tostring(bUpdateResult))
    end
  end
  return bResult, Archive
end
function Setting_UIElemLayout_Interface.TryGetSaveGame(InCustomLayoutType, ControlMode, bIsFPP, LayoutIndex, ModName)
  local SlotName_New = Setting_UIElemLayout_Interface.GetSlotName_New(InCustomLayoutType, ControlMode, bIsFPP, LayoutIndex, ModName)
  local SlotName_Legacy = Setting_UIElemLayout_Interface.GetSlotName_Legacy(InCustomLayoutType, ControlMode, bIsFPP, LayoutIndex, ModName)
  local SaveGame
  local bUseNewSave = true
  print(bWriteLog and string.format("Setting_UIElemLayout_Interface.TryGetSaveGame %s %s %s", SlotName_New or "nil", SlotName_Legacy or "nil", bUseNewSave and "UseNew" or "UseLegacy"))
  if bUseNewSave then
    SaveGame = GetSaveGame(SlotName_New)
    if not SaveGame then
      SaveGame = GetSaveGame(SlotName_Legacy, false, true)
      if SaveGame and Old2NewNamePrefix[SaveGame.SaveSlotName] then
        Setting_UIElemLayout_Interface.ConvertSaveGame(SaveGame, Old2NewNamePrefix[SaveGame.SaveSlotName], ControlMode)
        SaveGame = GetSaveGame(SlotName_New)
      end
    end
    if not SaveGame then
      SaveGame = GetSaveGame(SlotName_New, true)
    end
  else
    SaveGame = GetSaveGame(SlotName_Legacy, true)
  end
  print(bWriteLog and string.format("Setting_UIElemLayout_Interface.TryGetSaveGame final use %s", SaveGame and (SaveGame.SaveSlotName or "nil") or "nil"))
  return SaveGame
end
function Setting_UIElemLayout_Interface.Relocate(ControlMode, SaveGame, OldType, NewType)
  local bModified = false
  local LayoutDetailDict = SaveGame["LayoutDetailDict" .. tostring(ControlMode)]
  if LayoutDetailDict then
    local LayoutData_Old = LayoutDetailDict:Get(OldType)
    if LayoutData_Old then
      LayoutDetailDict:Remove(NewType)
      LayoutData_Old.Type = NewType
      LayoutDetailDict:Add(NewType, LayoutData_Old)
      LayoutDetailDict:Remove(OldType)
      bModified = true
    end
  end
  local InvalidArray = SaveGame["InvalidArray" .. tostring(ControlMode)]
  if InvalidArray then
    local FindIndex
    local Num = InvalidArray:Num()
    for Index = 0, Num - 1 do
      if InvalidArray:Get(Index) == OldType then
        Find      end
    end
    if FindIndex then
      InvalidArray:Set(FindIndex, NewType)
      bModified = true
    end
  end
  return bModified
end
function Setting_UIElemLayout_Interface.Reform410(ControlMode, SaveGame)
  local bModified = false
  local LayoutDetailDict = SaveGame["LayoutDetailDict" .. tostring(ControlMode)]
  if LayoutDetailDict then
    local LayoutData_Joystick = LayoutDetailDict:Get(2)
    if LayoutData_Joystick and math.abs(LayoutData_Joystick.RelativePos.X) < 1.01 and 1.01 > math.abs(LayoutData_Joystick.RelativePos.Y) then
      local UIUtil = require("client.common.ui_util")
      local ViewportSizebyScale = UIUtil.GetViewportSizebyScale()
      LayoutData_Joystick.RelativePos = FVector2D(ViewportSizebyScale.X * LayoutData_Joystick.RelativePos.X, ViewportSizebyScale.Y * (LayoutData_Joystick.RelativePos.Y - 1))
      LayoutData_Joystick.AnchorType = FAnchors(0, 1, 0, 1)
      LayoutDetailDict:Add(2, LayoutData_Joystick)
      bModified = true
    end
    local Detail_30 = LayoutDetailDict:Get(30)
    if Detail_30 and Detail_30.RelativePos.Y <= 0 then
      local RushTriggerLength = SaveGame["RushTriggerLength" .. tostring(ControlMode)]
      Detail_30.RelativePos = FVector2D(0, RushTriggerLength or 300)
      LayoutDetailDict:Add(30, Detail_30)
      bModified = true
    end
  end
  return bModified
end
function Setting_UIElemLayout_Interface.ConvertSaveGame(BPSaveGame, NewSlotNamePrefix, DictIndex)
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertSaveGame - Start conversion for slot: " .. NewSlotNamePrefix)
  local SettingCustomPanelBPClass = import("/Game/UMG/UI_BP/Setting/UILayout/BP_SettingCustomPanel.BP_SettingCustomPanel_C")
  local GameplayStatics = import("GameplayStatics")
  local CustomLayoutSaveGameClass = import("CustomLayoutSaveGame")
  for i = 1, 3 do
    if (not DictIndex or DictIndex == i) and BPSaveGame["LayoutDetailDict" .. i]:Num() > 0 then
      local TempInvalidMap = {}
      for _, k in pairs(BPSaveGame["InvalidArray" .. i]) do
        TempInvalidMap[k] = true
      end
      local NewSaveGame = GameplayStatics.CreateSaveGameObject(CustomLayoutSaveGameClass)
      local processedCount = 0
      for k, v in pairs(BPSaveGame["LayoutDetailDict" .. i]) do
        local Detail = SettingCustomPanelBPClass.BPStructToCPP(v)
        if TempInvalidMap[k] then
          Detail.Invalid = true
        end
        NewSaveGame:SetDataByLayoutDetail(k, Detail)
        processedCount = processedCount + 1
      end
      NewSaveGame.SaveSlotName = NewSlotNamePrefix .. "_C" .. tostring(i)
      local bResult, Archive = Setting_UIElemLayout_Interface.SaveUIElemLayoutSG(NewSaveGame)
      if bResult and Archive then
        local SettingSystem = require("client.logic.setting.logic_setting")
        SettingSystem.save_custom_setting(Archive, nil, 1, NewSaveGame.SaveSlotName)
      end
    end
  end
  print(bWriteLog and "Setting_UIElemLayout_Interface:ConvertSaveGame - Conversion completed")
end
function Setting_UIElemLayout_Interface.RemoveBuggyFile()
  print(bWriteLog and "Setting_UIElemLayout_Interface:RemoveBuggyFile")
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
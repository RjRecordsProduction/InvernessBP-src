local Lobby_Main_City = {
  CurScence = "",
  InitPawn = nil,
  CurAvatarData = {},
  RecentMainCityGameIdBucket = {},
  RecentMainCityGameIdBucketSize = 5,
  RecentMainCityGameIdBucketIndex = 1
}
local SceneConfig = {maincity_universal = "", maincity_middleeast = ""}
function Lobby_Main_City.EnterRoleSpace(uid, OpenFromType)
  log(bWriteLog and "Lobby_Main_City.EnterRoleSpace uid = " .. tostring(uid))
  if not uid then
    return
  end
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(uid, true, OpenFromType)
end
function Lobby_Main_City.EnterMatch()
  log(bWriteLog and "Lobby_Main_City.EnterMatch")
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  MatchHandler.send_on_match_req(101, 0, {1}, DeviceOSInfo.InfoList)
end
function Lobby_Main_City.SpawnAI()
  log(bWriteLog and "Lobby_Main_City.SpawnAI")
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local ENetRole = import("ENetRole")
    if uPlayerController.Role == ENetRole.ROLE_Authority then
      ShowNotice("Not Connected to DS")
      return
    end
    local sCmd = string.format("ServerCMD CallGMLua SpawnAI:20")
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, sCmd)
  end
end
function Lobby_Main_City.IsMainCitySubMode(InSubMode)
  log(bWriteLog and "Lobby_Main_City.IsMainCitySubMode InSubMode = " .. tostring(InSubMode))
  local InSubMode = tonumber(InSubMode)
  if InSubMode and InSubMode == 26000 then
    return true
  end
  return false
end
function Lobby_Main_City.AddMainCityGameIDToBucket(InGameID)
  if InGameID ~= nil then
    Lobby_Main_City.RecentMainCityGameIdBucket[Lobby_Main_City.RecentMainCityGameIdBucketIndex] = InGameID
    if Lobby_Main_City.RecentMainCityGameIdBucketIndex < Lobby_Main_City.RecentMainCityGameIdBucketSize then
      Lobby_Main_City.RecentMainCityGameIdBucketIndex = Lobby_Main_City.RecentMainCityGameIdBucketIndex + 1
    else
      Lobby_Main_City.RecentMainCityGameIdBucketIndex = 1
    end
  end
end
function Lobby_Main_City.IsRecentMainCityGameID(InGameID)
  for i = 1, Lobby_Main_City.RecentMainCityGameIdBucketSize do
    if Lobby_Main_City.RecentMainCityGameIdBucket[i] ~= nil and Lobby_Main_City.RecentMainCityGameIdBucket[i] == InGameID then
      return true
    end
  end
  return false
end
function Lobby_Main_City.OnModePostSwitch(_, __, Status)
  log(bWriteLog and "Lobby_Main_City.OnModePostSwitch")
  log_tree(bWriteLog and "Lobby_Main_City.OnModePostSwitch Status = ", Status)
  if Status.current == GameStatus.Login then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.pendingEnterInfo = nil
    local bConnectDS = Lobby_Main_City_Enter.bConnectDS
    log(bWriteLog and "Lobby_Main_City:OnModePostSwitch bConnectDS = " .. tostring(bConnectDS))
    if bConnectDS then
      Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
    end
    log(bWriteLog and "Lobby_Main_City.OnModePostSwitch clear ref")
    Lobby_Main_City.InitPawn = nil
    if slua_GameFrontendHUD then
      log(bWriteLog and "Lobby_Main_City.OnModePostSwitch slua_GameFrontendHUD")
      local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
      if slua.isValid(uGameInstance) then
        log(bWriteLog and "Lobby_Main_City.OnModePostSwitch uGameInstance")
        if uGameInstance.ClientBaseInfo and uGameInstance.ClientBaseInfo.BattleID then
          log(bWriteLog and "Lobby_Main_City.OnModePostSwitch clear BattleID")
          uGameInstance.ClientBaseInfo.BattleID = 0
        end
      end
    end
  end
end
function Lobby_Main_City.PreLoadChar()
  log(bWriteLog and "Lobby_Main_City.PreLoadChar")
  if slua.isValid(Lobby_Main_City.InitPawn) then
    log(bWriteLog and "Lobby_Main_City.PreLoadChar 1")
    return
  end
  local Utility = require("common.utility")
  local MainCitySubsystem = Utility.GetWorldSubsystemByName("MainCitySubsystem")
  local Config = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
  local CharClass = import(Config.CharClass)
  if slua.isValid(MainCitySubsystem) and CharClass then
    local nIndex = math.random(1, Config.StartNum)
    log(bWriteLog and string.format("Lobby_Main_City.PreLoadChar nIndex[%d]", nIndex))
    local Location = Config.StartLocation[nIndex]
    local Rotation = Config.StartRotation[nIndex]
    local Pawn = MainCitySubsystem:InitStandalonePawn(CharClass, Location, Rotation)
    if slua.isValid(Pawn) then
      Lobby_Main_City.Init      Pawn.bNetTemporary = true
      log(bWriteLog and "Lobby_Main_City.PreLoadChar InitPawn valid")
      Lobby_Main_City:CreateStandaloneAvatar()
    end
  end
end
function Lobby_Main_City:CreateStandaloneAvatar()
  if not slua.isValid(Lobby_Main_City.InitPawn) then
    log(bWriteLog and "Lobby_Main_City.CreateStandaloneAvatar InitPawn invalid")
    return
  end
  local AvatarComp = Lobby_Main_City.InitPawn.CharacterAvatarComp2_BP
  if not slua.isValid(AvatarComp) then
    log(bWriteLog and "Lobby_Main_City.CreateStandaloneAvatar InitPawn invalid")
    return
  end
  AvatarComp.bIsLobbyActor = false
  AvatarComp.bIsLobbyAvatar = false
  local nHeadId = AvatarData.GetHeadID() or 0
  local nHairID = AvatarData.GetHairID() or 0
  local nGender = AvatarData.GetGameGender() - 1 or 0
  Lobby_Main_City.CurAvatarData = {
    nHeadId = nHeadId,
    nHairID = nHairID,
      }
  AvatarComp:InitDefaultAvatarByResID(nGender, nHeadId, nHairID)
  print(bWriteLog and "MainCityAvatarStandAlone InitDefaultAvatarByResID nGender:" .. tostring(nGender) .. "HeadID:" .. tostring(nHeadId) .. "nHairID" .. tostring(nHairID))
  local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
  local Info = AvatarDataUtil.GetAvatarStandaloneData()
  log_tree("Lobby_Main_City.CreateStandaloneAvatar data: ", {
    nHeadId,
    nHairID,
    nGender,
    Info
  })
  if not Info or not Info.wear_ext then
    print(bWriteLog and "Lobby_Main_City:CreateStandaloneAvatar no Info.wear_ext")
    return
  end
  Lobby_Main_City.CurAvatarData.wear_ext = Info.wear_ext
  for k, ItemInfo in pairs(Info.wear_ext) do
    if ItemInfo and next(ItemInfo) then
      print(bWriteLog and "MainCityAvatarStandAlone PutOnCustomEquipmentByID ItemID:" .. tostring(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID]))
      AvatarComp:PutOnCustomEquipmentByID(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID], AvatarData.ConvertToAvatarCustom(ItemInfo))
    end
  end
end
function Lobby_Main_City.OnAvatarDataChange()
  if not slua.isValid(Lobby_Main_City.InitPawn) then
    log(bWriteLog and "Lobby_Main_City.OnAvatarDataChange return OnAvatarDataChange InitPawn invalid")
    return
  end
  local AvatarComp = Lobby_Main_City.InitPawn.CharacterAvatarComp2_BP
  if not slua.isValid(AvatarComp) then
    log(bWriteLog and "Lobby_Main_City.OnAvatarDataChange return InitPawn invalid")
    return
  end
  local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD)
  if dsState == "Online" then
    log(bWriteLog and "Lobby_Main_City.OnAvatarDataChange return dsState == Online")
    return
  end
  local nHeadId = AvatarData.GetHeadID() or 0
  local nHairID = AvatarData.GetHairID() or 0
  local nGender = AvatarData.GetGameGender() - 1 or 0
  if Lobby_Main_City.CurAvatarData.nHeadId ~= nHeadId or Lobby_Main_City.CurAvatarData.nHairID ~= nHairID or Lobby_Main_City.CurAvatarData.nGender ~= nGender then
    Lobby_Main_City.CurAvatarData.    Lobby_Main_City.CurAvatarData.    Lobby_Main_City.CurAvatarData.    AvatarComp:InitDefaultAvatarByResID(nGender, nHeadId, nHairID)
    print(bWriteLog and "Lobby_Main_City.OnAvatarDataChange InitDefaultAvatarByResID nGender:" .. tostring(nGender) .. "HeadID:" .. tostring(nHeadId) .. "nHairID" .. tostring(nHairID))
  end
  local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
  local Info = AvatarDataUtil.GetAvatarStandaloneData()
  local TableUtil = require("common.table_util")
  for _, ItemInfo in pairs(Lobby_Main_City.CurAvatarData.wear_ext) do
    if not TableUtil.IsInTable2(Info.wear_ext, ItemInfo) and ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID] then
      print(bWriteLog and "Lobby_Main_City.OnAvatarDataChange PutOffEquimentByResID ItemID:" .. tostring(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID]))
      AvatarComp:PutOffEquimentByResID(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID])
    end
  end
  for k, ItemInfo in pairs(Info.wear_ext) do
    if not TableUtil.IsInTable2(Lobby_Main_City.CurAvatarData.wear_ext, ItemInfo) then
      print(bWriteLog and "Lobby_Main_City.OnAvatarDataChange PutOnCustomEquipmentByID ItemID:" .. tostring(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID]))
      AvatarComp:PutOnCustomEquipmentByID(ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID], AvatarData.ConvertToAvatarCustom(ItemInfo))
    end
  end
  Lobby_Main_City.CurAvatarData.wear_ext = Info.wear_ext
end
function Lobby_Main_City.OnPufferInited()
  log(bWriteLog and "Lobby_Main_City.OnPufferInited.")
  if Lobby_Main_City.InitPawn then
    log(bWriteLog and "Lobby_Main_City.OnPufferInited. init return")
    return
  end
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  Main_City_Download_Tool.MountMainCityMap()
end
function Lobby_Main_City.ReloadAllEquippedAvatar(ItemID, bReloadAll)
  if not ItemID or ItemID <= 0 then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar ItemID is " .. tostring(ItemID))
    return
  end
  if not slua.isValid(Lobby_Main_City.InitPawn) then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar InitPawn invalid ItemID:" .. tostring(ItemID))
    return
  end
  local AvatarComp = Lobby_Main_City.InitPawn.CharacterAvatarComp2_BP
  if not slua.isValid(AvatarComp) then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar CharacterAvatarComp2_BP invalid ItemID:" .. tostring(ItemID))
    return
  end
  local AvatarDataUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarDataUtil")
  local Info = AvatarDataUtil.GetAvatarStandaloneData()
  local wear_ext = Info and Info.wear_ext
  log_tree("Lobby_Main_City.ReloadAllEquippedAvatar wear_ext:", wear_ext)
  if not wear_ext or not next(wear_ext) then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar wear_ext nil ItemID:" .. tostring(ItemID))
    return
  end
  local bExist = false
  for _, ItemInfo in pairs(wear_ext) do
    if ItemInfo[ENUM_AVATAR_DATA_TYPE.ItemID] == ItemID then
      bExist = true
      break
    end
  end
  if not bExist then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar bExist false ItemID:" .. tostring(ItemID))
    return
  end
  log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar PutOnEquipmentByResID ItemID is " .. tostring(ItemID))
  if bReloadAll then
    log(bWriteLog and "Lobby_Main_City.ReloadAllEquippedAvatar OnRep_BodySlotStateChanged")
    AvatarComp:OnRep_BodySlotStateChanged()
  end
end
return Lobby_Main_City
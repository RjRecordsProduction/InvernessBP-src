local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
require("common.macros.item_macros")
local LobbyAvatarManager = {
  Const = {
    LobbyAvatarLuaPath = "client.logic.avatar.LobbyAvatar",
    Enum_SoundFromType = {Lobby = 0, RPEmotionPreview = 1},
    DefaultMockSoundLocationCfg = {
      {
        0,
        0,
        0
      },
      {
        -45.299,
        -383.5,
        -14310.0
      },
      {
        -5309.84668,
        2513.46582,
        -19300.0
      },
      {
        -8785.0,
        -2009.0,
        -6100.0
      }
    },
    HideAvatarFlag = {PeakGameEffect = 1}
  },
  Enum_Sex = {Male = 1, Female = 2},
  Enum_Sex_Cpp = {Female = 1, Male = 0},
  Enum_DefaultSetID = {
    Head = 401999,
    Hair = 40601001,
    Clothes = 403003,
    Trousers = 404026
  },
  Enum_EquipWeapon = {None = 0},
  Enum_ItemTypeID = {
    Weapon = wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon
  },
  Enum_SubItemTypePriority = {
    [ENUM_ITEM_SUBTYPE.Shoes_Slot] = 2,
    [ENUM_ITEM_SUBTYPE.Pants_Slot] = 3,
    [ENUM_ITEM_SUBTYPE.LobbyBGM] = 4,
    [ENUM_ITEM_SUBTYPE.Mask_Slot] = 5,
    [ENUM_ITEM_SUBTYPE.Hat_Slot] = 6,
    [ENUM_ITEM_SUBTYPE.Package_Slot] = 7,
    [ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin] = 8,
    [ENUM_ITEM_SUBTYPE.Backpack] = 9
  },
  Enum_SceneType = {DEFAULT = 0, LOBBY_PURE = 4},
  Enum_SceneType2 = {DEFAULT = 0, Main = 1},
  Enum_WeaponAttachSlotID = {
    MAIN_WEAPON1 = "MainSlot1",
    MAIN_WEAPON2 = "MainSlot2",
    PISTOL = "SubSlot",
    MELEE = "MeleeSlot"
  },
  Enum_SoundFrom = {
    Default = 0,
    LobbyWardrobe = 0,
    Other = 1,
    Mall = 2,
    Pass = 3
  },
  playerList = {},
  avatarCreateID = 0,
  enteringActionMap = nil,
  mockSoundPathToPlayIDMap = {},
  mockSoundUniqueMap = {},
  lobbyEmotionUid = nil,
  _report_ids = {},
  beforeHideAvatars = {}
}
function LobbyAvatarManager.SortEquipmentListByDefaultPriority(equipmentList)
  log(bWriteLog and string.format("[LobbyAvatar] LobbyAvatarManager.SortEquipmentListByDefaultPriority(%s)", equipmentList))
  for i, equipment in ipairs(equipmentList) do
    local config = CDataTable.GetTableData("Item", equipment.ItemID)
    if config ~= nil then
      local subType = config.ItemSubType
      equipment.priority = LobbyAvatarManager.Enum_SubItemTypePriority[subType] or 1
    else
      equipment.priority = 0
    end
  end
  table.sort(equipmentList, function(a, b)
    return a.priority < b.priority
  end)
end
function LobbyAvatarManager.SortEquipmentIDList(equipmentIDList)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.SortEquipmentIDList(%s)", equipmentIDList))
  local tmp = {}
  for i, itemID in ipairs(equipmentIDList) do
    if itemID and type(itemID) ~= "table" then
      local config = CDataTable.GetTableData("Item", itemID)
      if config ~= nil then
        local subType = config.ItemSubType
        local priority = LobbyAvatarManager.Enum_SubItemTypePriority[subType] or 1
        local data = {}
        data.        data.        table.insert(tmp, data)
      end
    end
  end
  table.sort(tmp, function(a, b)
    return a.priority < b.priority
  end)
  return tmp
end
function LobbyAvatarManager.GetEnteringActionMap()
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.GetEnteringActionMap()")
  if LobbyAvatarManager.enteringActionMap == nil or not next(LobbyAvatarManager.enteringActionMap) then
    LobbyAvatarManager.enteringActionMap = {}
    local cfg = CDataTable.GetTable("GoldenSuitMapCfg")
    for k, v in pairs(cfg) do
      if v.TeamupActionID ~= 0 then
        LobbyAvatarManager.enteringActionMap[v.TeamupActionID] = 0
      end
    end
    local RealGoldenSuitFeature = CDataTable.GetTable("RealGoldenSuitFeature")
    for _, v in pairs(RealGoldenSuitFeature) do
      if v.TemmupEmote ~= 0 then
        LobbyAvatarManager.enteringActionMap[v.TemmupEmote] = 0
      end
    end
  end
  return LobbyAvatarManager.enteringActionMap
end
local _IsSelf = function(uid)
  return tostring(DataMgr.roleData.uid) == tostring(uid)
end
function LobbyAvatarManager.GetOperateAvatarByAvatarID(nAvatarID)
  if LobbyAvatarManager.playerList and LobbyAvatarManager.playerList[nAvatarID] then
    return LobbyAvatarManager.playerList[nAvatarID]
  end
  log_tree(string.format("[LobbyAvatarManager] LobbyAvatarManager.GetOperateAvatarByAvatarID(%s) Is nil, LobbyAvatarManager.playerList", tostring(nAvatarID)), LobbyAvatarManager.playerList)
  return nil
end
function LobbyAvatarManager.CreateAvatar(sex, headId, poolSize)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.CreateAvatar(%s, %s)", sex, headId))
  sex = sex or LobbyAvatarManager.Enum_Sex.Male
  headId = headId or LobbyAvatarManager.Enum_DefaultSetID.Head
  LobbyAvatarManager.avatarCreateID = LobbyAvatarManager.avatarCreateID + 1
  local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
  local playerLobbyPawn = LobbyPawnPool.Get()
  if not slua.isValid(playerLobbyPawn) then
    return 0
  end
  if poolSize and 0 < poolSize then
    LobbyPawnPool.SetMaxNum(poolSize)
  else
    LobbyPawnPool.SetMaxNum(1)
  end
  LobbyAvatarManager.playerList[LobbyAvatarManager.avatarCreateID] = playerLobbyPawn
  return LobbyAvatarManager.avatarCreateID
end
function LobbyAvatarManager.CreateMyAvatar()
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.CreateMyAvatar()")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:UpdateInvalidWearInfo(nil)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local roleWear = AvatarData.GetWearInfo()
  local dmad = DataMgr.avatarData
  local avatarSt = {
    gamegender = dmad.gamegender,
    headid = dmad.headid,
    hairid = dmad.hairid,
    beardid = dmad.beardid,
    beardcolor = dmad.beardcolorid,
    attr_info = dmad.attr_info
  }
  local head_show = 0
  local bag_skin_resId = 0
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local current_head_show = fashionbag_data:GetHeadShow(fashionbag_data:GetFashionBagUseIndex())
  local current_helmet_level = fashionbag_data:GetHelmetLevel()
  local current_helmet_skin = 0
  if HallThemeUtils.GetBindRelation(HallThemeUtils.CONST_RELATION_TYPE.HELMET) == nil then
    current_helmet_skin = fashionbag_data:GetHelmetSkin()
  else
    current_helmet_skin = fashionbag_data:GetHelmetSkinByLevel(current_helmet_level)
  end
  if current_head_show == 0 then
    if roleWear[1] and roleWear[1].ItemID then
      local item = wardrobe_data:GetHallDepotItemDataByResID(roleWear[1].ItemID)
      if item and item.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
        table.remove(roleWear, 1)
      end
    end
  elseif current_head_show == current_helmet_skin then
    if roleWear[1] and roleWear[1].ItemID then
      local item2 = wardrobe_data:GetHallDepotItemDataByResID(roleWear[1].ItemID)
      if item2 and item2.itemSubType == ENUM_ITEM_SUBTYPE.Helmet_NoLevel then
        table.remove(roleWear, 1)
      end
    end
    local originalResId = wardrobeLogic:GetItemResId(current_helmet_skin)
    head_show = DataMgr.GetEquipmentItemIDByResID(current_helmet_level, originalResId)
  end
  local current_bag_skin = fashionbag_data:GetBagSkin()
  local originalResId1 = wardrobeLogic:GetItemResId(current_bag_skin)
  local current_bag_level = fashionbag_data:GetBagLevel()
  bag_skin_resId = DataMgr.GetEquipmentItemIDByResID(current_bag_level, originalResId1)
  local bag_pendants = fashionbag_data:GetBagPendants()
  for k, v in pairs(bag_pendants) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(k)
    if itemData then
      table.insert(roleWear, AvatarData.CreateAvatarCustom(itemData.resID))
    end
  end
  local playerData = {
    gid = tostring(DataMgr.roleData.uid),
    avatar = avatarSt,
    index = 1,
    BP_ARRAY_AvatarList = roleWear,
    weaponId = DataMgr.Weapon_ID or 0,
    weaponSkinId = 0,
    extraWeaponInfoList = DataMgr.Extra_Weapon_Info_List or {},
    bagSkinInsId = bag_skin_resId,
    headShow = head_show or 0
  }
  log_tree("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.CreateMyAvatar playerData", playerData)
  TeamAvatarManager.CreateMySelf = true
  LobbyAvatarManager.SpawnPlayer(playerData, true)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CREATE_LOBBY_AVATAR)
  TeamAvatarManager.PlayBigEventToLobbyAction()
end
function LobbyAvatarManager.CreateMyPet()
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local PetInsIDOrDressID = logic_pet:GetEquipedPetInsID()
  if PetInsIDOrDressID == 0 then
    log(bWriteLog and "  LobbyAvatarManager.CreateMyPet.  0")
    return
  end
  local pet_info = logic_pet:GetPetDataByInsID(PetInsIDOrDressID)
  local uid = DataMgr.roleData.uid
  local PetData = logic_pet:FormatPetDataByServerInfo(uid, pet_info)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.CreatePet(uid, PetData)
end
local PreLoadAssetList = {
  "/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C",
  "/Game/BluePrints/Backpack/BackpackBlueprintUtils_BP.BackpackBlueprintUtils_BP_C",
  "/Game/BluePrints/Avatar/AvatarUtilsImp_BP.AvatarUtilsImp_BP_C"
}
function LobbyAvatarManager.AysncLoadAvatarAsset(HandleID)
  if not GameStatus.IsInLobbyOrMainCity() then
    log_warning("LobbyAvatarManager.AysncLoadAvatarAsset no lobby")
    return
  end
  LobbyAvatarManager.AsyncHandID = nil
  LobbyAvatarManager.CreateMyAvatar()
end
function LobbyAvatarManager.CreateMyAvatarAsync()
  local asset_util = require("common.asset_util")
  if LobbyAvatarManager.AsyncHandID then
    log(bWriteLog and "LobbyAvatarManager.CreateMyAvatarAsync CancelAssetAsync obbyAvatarManager.AsyncHandID")
    asset_util.CancelAssetAsync(LobbyAvatarManager.AsyncHandID)
    LobbyAvatarManager.AsyncHandID = nil
  end
  LobbyAvatarManager.AsyncHandID = asset_util.GetAssetsArrayAsyncParallel(PreLoadAssetList, LobbyAvatarManager.AysncLoadAvatarAsset)
  log(bWriteLog and "LobbyAvatarManager.CreateMyAvatarAsync LobbyAvatarManager.AsyncHandID")
end
function LobbyAvatarManager.SpawnPlayer(playerData, spawn, isLockPosition, bHasWear)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.SpawnPlayer(%s, %s, %s, %s)", playerData, spawn, isLockPosition, bHasWear))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local selfUID = TeamUpNewSystem.GetSelfUID()
  local isTeammate = tostring(playerData.gid) ~= tostring(selfUID)
  local SpawnPlayerData = {
    index = 1,
    gid = tostring(playerData.gid),
    headId = playerData.avatar.headid,
    sex = playerData.avatar.gamegender or 0,
    headShow = playerData.headShow or 0,
    weaponResId = playerData.weaponId or 0,
    extraWeaponInfoList = playerData.extraWeaponInfoList or {},
    weaponSkinId = playerData.weaponSkinId or 0,
    bagSkinInsId = playerData.bagSkinInsId or 0,
    BP_ARRAY_AvatarList = playerData.BP_ARRAY_AvatarList or {},
      }
  if tonumber(SpawnPlayerData.weaponSkinId) ~= 0 then
    SpawnPlayerData.weaponResId = SpawnPlayerData.weaponSkinId
  end
  local switchInfo = LobbySystem.CheckOpen(BP_ENUM_WARDROBE_UI_WEAPON)
  if not switchInfo then
    SpawnPlayerData.weaponResId = 0
    for k, v in pairs(SpawnPlayerData.extraWeaponInfoList) do
      v.weapon_id = 0
    end
  end
  SpawnPlayerData.sex = SpawnPlayerData.sex - 1
  if SpawnPlayerData.sex == LobbyAvatarManager.Enum_Sex_Cpp.Male then
    table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(playerData.avatar.beardid, playerData.avatar.beardcolor))
  end
  table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(playerData.avatar.hairid))
  if playerData.avatar and playerData.avatar.attr_info and next(playerData.avatar.attr_info) then
    for key, value in pairs(playerData.avatar.attr_info) do
      table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.ConvertToAvatarCustom(value, true))
    end
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  if spawn then
    local avatar = TeamAvatarManager.CreateAvatar(SpawnPlayerData)
    if not avatar then
      return
    end
    if RoleInfoMainSystem.GetIsRestoreMenu() or LobbyThemeManager:IsPreviewStatus() then
      TeamAvatarManager.HideAllAvatar()
    end
    if bHasWear then
      avatar:HideAvatar()
      LobbyAvatarManager.beforeHideAvatars[tostring(playerData.gid)] = avatar
    end
    return avatar.positionIndex
  else
    local result = TeamAvatarManager.DestroyAvatar(SpawnPlayerData, isLockPosition)
    LobbyAvatarManager.ResetHideAvatar(tostring(playerData.gid))
    if not result then
      return
    end
    if RoleInfoMainSystem.GetIsRestoreMenu() or LobbyThemeManager:IsPreviewStatus() then
      TeamAvatarManager.HideAllAvatar()
    end
  end
end
function LobbyAvatarManager.CreateDefaultAvatar(headId, playerLobbyPawn)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.CreateDefaultAvatar(%s, %s)", headId, playerLobbyPawn))
  if not headId or headId == 0 or not playerLobbyPawn then
    return headId
  end
  local itemCfg = CDataTable.GetTableData("AvatarDefaultConfig", headId)
  if itemCfg then
    return headId
  end
  local NPCConfig = CDataTable.GetTable("NPCConfig")
  for _, config in pairs(NPCConfig) do
    if headId == config.Head then
      return headId
    end
  end
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.CreateDefaultAvatar headId:" .. tostring(headId) .. " default_head_id:" .. tostring(LobbyAvatarManager.Enum_DefaultSetID.Head))
  playerLobbyPawn:SetFemaleAnimClass()
  playerLobbyPawn:SwitchSexAndHeadAndHair(LobbyAvatarManager.Enum_Sex_Cpp.Female, LobbyAvatarManager.Enum_DefaultSetID.Head, LobbyAvatarManager.Enum_DefaultSetID.Hair)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    playerLobbyPawn:PutOnEquipmentByResID(LobbyAvatarManager.Enum_DefaultSetID.Hair)
    playerLobbyPawn:PutOnEquipmentByResID(LobbyAvatarManager.Enum_DefaultSetID.Clothes)
    playerLobbyPawn:PutOnEquipmentByResID(LobbyAvatarManager.Enum_DefaultSetID.Trousers)
  end)
  return LobbyAvatarManager.Enum_DefaultSetID.Head
end
function LobbyAvatarManager.DestroyAllAvatar()
  log(bWriteLog and "LobbyAvatarManager.DestroyAllAvatar")
  for _, avatar in pairs(LobbyAvatarManager.playerList) do
    if avatar and slua.isValid(avatar) then
      avatar.LobbyPlayEmoteComponent_BP:OnStopEmote()
      avatar:K2_DestroyActor()
    end
  end
  LobbyAvatarManager.playerList = {}
  LobbyAvatarManager.ClearPools()
  if LobbyAvatarManager.AsyncHandID then
    local asset_util = require("common.asset_util")
    asset_util.CancelAssetAsync(LobbyAvatarManager.AsyncHandID)
  end
end
function LobbyAvatarManager.ClearPools()
  log(bWriteLog and "LobbyAvatarManager.ClearPools")
  local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
  LobbyPawnPool.Destroy()
  local LobbyModelPool = require("client.slua.logic.show_actor.common.LobbyModelPool")
  LobbyModelPool.ClearPool()
  local LobbyModelShowActorPool = require("client.slua.logic.show_actor.common.LobbyModelShowActorPool")
  LobbyModelShowActorPool.ClearPool()
  local pet_pawn_pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.pet_pawn_pool)
  pet_pawn_pool:ReleasePool()
end
function LobbyAvatarManager.UpdatePlayer(bDisableUpdatePos)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.UpdatePlayer(%s)", bDisableUpdatePos))
  local SpawnPlayerData = {
    index = 1,
    weaponResId = 0,
    weaponSkinId = 0,
    BP_ARRAY_AvatarList = {},
    headId = AvatarData.GetHeadID(),
    sex = AvatarData.GetGameGender(),
    gid = tostring(DataMgr.roleData.uid)
  }
  local roleWear = {}
  local currentUsingWeaponID = DataMgr.GetCurrentWeaponID()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local showingAvatar = TeamAvatarManager.GetMainAvatar()
  local pet = showingAvatar and showingAvatar:GetPet()
  local PetData
  if pet ~= nil then
    PetData = pet:GetPetData()
  end
  TeamAvatarManager.DestroyAvatar(SpawnPlayerData, true)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WearInfo = AvatarData.GetWearInfo()
  for k, v in pairs(WearInfo) do
    table.insert(roleWear, v)
  end
  local head_show = 0
  local bag_skin_resId
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local current_head_show = fashionbag_data:GetHeadShow(fashionbag_data:GetFashionBagUseIndex())
  local current_helmet_level = fashionbag_data:GetHelmetLevel()
  local current_helmet_skin = fashionbag_data:GetHelmetSkinByLevel(current_helmet_level)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if current_head_show == current_helmet_skin then
    local originalHelmetResId = wardrobeLogic:GetItemResId(current_helmet_skin)
    head_show = DataMgr.GetEquipmentItemIDByResID(current_helmet_level, originalHelmetResId)
  end
  local current_bag_level = fashionbag_data:GetBagLevel()
  local current_bag_skin = fashionbag_data:GetBagSkinByLevel(current_bag_level)
  local originalBagResId = wardrobeLogic:GetItemResId(current_bag_skin)
  bag_skin_resId = DataMgr.GetEquipmentItemIDByResID(current_bag_level, originalBagResId)
  local bag_pendants = fashionbag_data:GetBagPendants()
  for k, v in pairs(bag_pendants) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(k)
    if itemData then
      table.insert(roleWear, AvatarData.CreateAvatarCustom(itemData.resID))
    end
  end
  SpawnPlayerData = {
    index = 1,
    weaponSkinId = 0,
    weaponResId = currentUsingWeaponID,
    extraWeaponInfoList = DataMgr.Extra_Weapon_Info_List or {},
    BP_ARRAY_AvatarList = roleWear,
    headId = AvatarData.GetHeadID(),
    sex = AvatarData.GetGameGender(),
    attr_info = DataMgr.avatarData.attr_info,
    gid = tostring(DataMgr.roleData.uid),
    bagSkinInsId = bag_skin_resId,
    headShow = head_show or 0,
    bDisableUpdatePos = bDisableUpdatePos or false
  }
  SpawnPlayerData.sex = SpawnPlayerData.sex - 1
  if SpawnPlayerData.sex == LobbyAvatarManager.Enum_Sex_Cpp.Male then
    table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(AvatarData.GetBeardID(), AvatarData.GetBeardColorID()))
  end
  table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.CreateAvatarCustom(AvatarData.GetHairID()))
  if SpawnPlayerData.attr_info and next(SpawnPlayerData.attr_info) then
    for key, value in pairs(SpawnPlayerData.attr_info) do
      table.insert(SpawnPlayerData.BP_ARRAY_AvatarList, AvatarData.ConvertToAvatarCustom(value, true))
    end
  end
  TeamAvatarManager.CreateAvatar(SpawnPlayerData)
  if pet ~= nil and PetData ~= nil then
    log(bWriteLog and "LobbyAvatarManager.UpdatePlayer. CreatePet PetID: " .. tostring(PetData and PetData.ServerInfo and PetData.ServerInfo.id))
    TeamAvatarManager.CreatePet(DataMgr.roleData.uid, PetData)
    LobbyAvatarManager.UpdateMyPetDress()
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if RoleInfoMainSystem.GetIsRestoreMenu() then
    TeamAvatarManager.HideAllAvatar()
  end
end
function LobbyAvatarManager.UpdateMyPetDress()
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.UpdateMyPetDress()")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local showingAvatar = TeamAvatarManager.GetMainAvatar()
  local pet = showingAvatar and showingAvatar:GetPet()
  if pet == nil then
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local PetInsID = pet:GetInsID()
  local petDress = logic_pet:GetCurDressItems(PetInsID)
  if petDress == nil then
    return
  end
  for itemID, _ in pairs(petDress) do
    TeamAvatarManager.ChangePetEquipment(DataMgr.roleData.uid, itemID)
  end
end
function LobbyAvatarManager.PlayMockSoundAsync(uid)
  local cacheData = LobbyAvatarManager.mockSoundPathToPlayIDMap[tostring(uid)]
  if not cacheData or type(cacheData) ~= "table" then
    log(bWriteLog and "LobbyAvatarManager.PlayMockSoundAsync not cache data")
    return
  end
  local soundPath = cacheData.soundPath
  local fromWhereType = cacheData.fromWhereType
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager._PlaySoundFromPath(%s, %s, %s)", soundPath, uid, fromWhereType))
  local mockSoundLocationCfg = {}
  local defaultMSLC = LobbyAvatarManager.Const.DefaultMockSoundLocationCfg
  for i = 1, #defaultMSLC do
    mockSoundLocationCfg[i - 1] = FVector(defaultMSLC[i][1], defaultMSLC[i][2], defaultMSLC[i][3])
  end
  fromWhereType = fromWhereType or 0
  local asset_util = require("common.asset_util")
  local akEvent = asset_util.GetAssetSync(soundPath)
  if akEvent and mockSoundLocationCfg[fromWhereType] then
    local AkGameplayStatics = import("AkGameplayStatics")
    local UIUtil = require("client.common.ui_util")
    local worldContextObject = UIUtil.GetGameInstance()
    local playID = AkGameplayStatics.PostEventAtLocation(akEvent, mockSoundLocationCfg[fromWhereType], FRotator(0, 0, 0), "", worldContextObject)
    LobbyAvatarManager.mockSoundPathToPlayIDMap[tostring(uid)] = playID
  end
end
function LobbyAvatarManager.PlayMockingSound(emoteId, sex, randSoundId, uid, fromWhereType)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.PlayMockingSound(%s, %s, %s, %s, %s)", emoteId, sex, randSoundId, uid, fromWhereType))
  sex = sex or 1
  local cfg = CDataTable.GetTableData("ChaoFengSoundConfig", emoteId)
  if cfg == nil then
    return false
  end
  if cfg.Unique and uid then
    if LobbyAvatarManager.mockSoundUniqueMap[emoteId] then
      log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.PlayMockingSound Unique! Not Play!")
      return
    end
    LobbyAvatarManager.mockSoundUniqueMap[emoteId] = tostring(uid)
    log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.PlayMockingSound Unique! Play! " .. tostring(uid))
  end
  local pathListNan = {
    [1] = cfg.soundPathNan1,
    [2] = cfg.soundPathNan2
  }
  local pathListNv = {
    [1] = cfg.soundPathNv1,
    [2] = cfg.soundPathNv2
  }
  local soundPath
  if sex == LobbyAvatarManager.Enum_Sex.Male then
    soundPath = pathListNan[randSoundId]
  elseif sex == LobbyAvatarManager.Enum_Sex.Female then
    soundPath = pathListNv[randSoundId]
  end
  if soundPath == nil then
    return false
  end
  LobbyAvatarManager.mockSoundPathToPlayIDMap[tostring(uid)] = {soundPath = soundPath, fromWhereType = fromWhereType}
  return true
end
function LobbyAvatarManager.StopMockSound(uid)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.StopMockSound(%s)", uid))
  if not uid then
    return
  end
  for emoteId, MarkUID in pairs(LobbyAvatarManager.mockSoundUniqueMap) do
    if uid == MarkUID then
      log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.StopMockSound remove mark", tostring(emoteId)))
      LobbyAvatarManager.mockSoundUniqueMap[emoteId] = nil
    end
  end
  if not LobbyAvatarManager.mockSoundPathToPlayIDMap[uid] then
    return
  end
  if type(LobbyAvatarManager.mockSoundPathToPlayIDMap[uid]) == "number" then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(LobbyAvatarManager.mockSoundPathToPlayIDMap[uid])
  end
  LobbyAvatarManager.mockSoundPathToPlayIDMap[uid] = nil
end
function LobbyAvatarManager.PlayEmotionSound(emoteId, sex, randSoundId, uid, fromWhereType)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.PlayEmotionSound(%s, %s, %s, %s, %s)", emoteId, sex, randSoundId, uid, fromWhereType))
  LobbyAvatarManager.StopMockSound(uid)
  if not randSoundId or randSoundId == 0 then
    local LogicLobbyExpression = require("client.slua.logic.lobby.logic_lobby_expression")
    randSoundId = LogicLobbyExpression.GetTauntRandSoundID and LogicLobbyExpression.GetTauntRandSoundID(emoteId, sex)
  end
  if randSoundId and 0 < randSoundId then
    LobbyAvatarManager.PlayMockingSound(emoteId, sex, randSoundId, uid, fromWhereType)
  end
end
function LobbyAvatarManager.PlayEmoteAction(uid, emoteId, sex, randSoundId, fromWhereType, extraInfo)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.PlayEmoteAction(%s, %s, %s, %s, %s , %s)", uid, emoteId, sex, randSoundId, fromWhereType, extraInfo))
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  if _IsSelf(uid) then
    if LogicXSuit.IsInviteAction(emoteId) then
      local hasEquip, levelEnough = LogicXSuit.CheckHasEquipXSuitByAction(emoteId)
      if not hasEquip then
        ShowNotice(16153)
        return false
      end
      if not levelEnough then
        ShowNotice(29026)
        return false
      end
    else
      local wordId = golden_suit_module:EmoteNeedClothesWithWord(emoteId)
      if wordId then
        ShowNotice(wordId)
        return
      end
      local wordId = golden_suit_module:EmoteNeedClothesAllWithWord(emoteId)
      if wordId then
        ShowNotice(wordId)
        return
      end
    end
  end
  LobbyAvatarManager.lobbyEmotionUid = tostring(uid)
  local isBattleEmotion, period = LogicXSuit.IsBattleEmotion(emoteId)
  if isBattleEmotion then
    local itemID = LogicXSuit.GetItemIDByLevel(period, 5)
    if not itemID then
      return
    end
    local UIUtil = require("client.common.ui_util")
    local itemCfg = UIUtil.GetItemCfg(itemID)
    ShowNotice(GlobalData.GetLocalizeStringWithNum(11079, 0, itemCfg and itemCfg.ItemName or ""))
    return false
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.PlayAction(tostring(uid), emoteId, extraInfo)
  LobbyAvatarManager.PlayEmotionSound(emoteId, sex, randSoundId, uid, fromWhereType)
  return true
end
function LobbyAvatarManager.StopEmoteAction(UID)
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.StopEmoteAction()")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module.currentCameraID == Lobby_camera_manager_module.Enum_CameraID.store_general then
    return
  end
  if not UID or UID == "" then
    UID = LobbyAvatarManager.lobbyEmotionUid or ""
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.StopAction(UID)
end
function LobbyAvatarManager.EquipWeapon(uid, weapon_wear_info, reason, isUse)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.EquipWeapon(%s, %s, %s, %s)", uid, weapon_wear_info, reason, isUse))
  log_tree(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.EquipWeapon weapon_wear_info = ", weapon_wear_info)
  uid = tostring(uid)
  local _log = function(errorMessage)
    log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.EquipWeapon not pass, reason: " .. tostring(errorMessage))
  end
  local equip = function()
    if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_UI_WEAPON) then
      _log("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.EquipWeaponWardrobe not open")
      return
    end
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    if not TeamAvatarManager.GetAvatarByUid(uid) then
      _log("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.EquipWeapon TeamAvatarManager.GetAvatarByUid pass fail")
      TeamAvatarManager.TryEquipWeapon[uid] = {}
      return
    end
    local skinId = tonumber(weapon_wear_info.skinId or 0)
    local weapon_res_id = skinId ~= 0 and skinId or weapon_wear_info.weaponId
    local nLgdWpnResId = tonumber(weapon_wear_info.lgdWpnResId or 0)
    if 0 < nLgdWpnResId then
      weapon_res_id = nLgdWpnResId
      skinId = nLgdWpnResId
    end
    local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
    local diyConfig = WeaponDiySystem:GetWeaponCfg(weapon_res_id)
    if diyConfig then
      if not TeamAvatarManager.TryEquipWeapon[uid] then
        TeamAvatarManager.TryEquipWeapon[uid] = {}
      end
      if isUse then
        if not TeamAvatarManager.TryEquipWeapon[uid][1] then
          TeamAvatarManager.TryEquipWeapon[uid][1] = {}
        end
        TeamAvatarManager.TryEquipWeapon[uid][1].        TeamAvatarManager.TryEquipWeapon[uid][1].        TeamAvatarManager.TryEquipWeapon[uid][1].      else
        if not TeamAvatarManager.TryEquipWeapon[uid][2] then
          TeamAvatarManager.TryEquipWeapon[uid][2] = {}
        end
        TeamAvatarManager.TryEquipWeapon[uid][2].        TeamAvatarManager.TryEquipWeapon[uid][2].        TeamAvatarManager.TryEquipWeapon[uid][2].      end
      local isRecommend = weapon_wear_info.usingDiyRecommend
      if not isRecommend and weapon_wear_info.diyPlanId then
        isRecommend = WeaponDiySystem:IsPlanRecommend(weapon_wear_info.diyPlanId)
      end
      if isRecommend then
        TeamAvatarManager.PutonEquipment(uid, skinId, nil, isUse)
        local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
        local schemeData = weapon_diy_rec_scheme[skinId]
        if schemeData then
          TeamAvatarManager.ChangeDiyWeaponScheme(uid, schemeData)
        end
      elseif weapon_wear_info.diyPlanId and weapon_wear_info.diyPlanId ~= "" then
        local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
        local schemeData
        if _IsSelf(uid) then
          schemeData = WeaponDiySystem:GetSchemeData(skinId, weapon_wear_info.diyPlanId)
        else
          schemeData = WeaponDiyHandler.GetWeaponData(uid, weapon_wear_info.diyPlanId)
        end
        if schemeData then
          TeamAvatarManager.PutonEquipment(uid, skinId, nil, isUse)
          TeamAvatarManager.ChangeDiyWeaponScheme(uid, schemeData)
        else
          WeaponDiyHandler.send_get_player_ds_data_req(uid, 1, {
            weapon_wear_info.diyPlanId
          }, "lobby", nil)
        end
      else
        TeamAvatarManager.PutonEquipment(uid, weapon_res_id, nil, isUse)
      end
    else
      TeamAvatarManager.PutonEquipment(uid, weapon_res_id, nil, isUse)
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_SHOW_VEHICLE)
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    if RoleInfoMainSystem.GetIsRestoreMenu() then
      TeamAvatarManager.HideAllAvatar()
    end
  end
  local utility = require("common.utility")
  xpcall(equip, utility.ErrorMessageHandler)
end
function LobbyAvatarManager.UnEquipWeapon(uid)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.UnEquipWeapon(%s)", uid))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.PutoffSubtype(tostring(uid), wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon)
end
function LobbyAvatarManager.GetExtraWeaponIdList()
  log(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.GetAllSocketWeaponExceptUsingOne()")
  local unusedWeaponList = {}
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local playerAvatar = TeamAvatarManager.GetModel(DataMgr.roleData.uid)
  if playerAvatar == nil or playerAvatar.BP_LobbyWeaponManager == nil then
    return unusedWeaponList
  end
  local curUsingWeapon = playerAvatar.BP_LobbyWeaponManager:GetUsingWeapon()
  for _, v in pairs(LobbyAvatarManager.Enum_WeaponAttachSlotID) do
    local weapon = playerAvatar.BP_LobbyWeaponManager:GetWeaponBySocketID(v)
    if weapon and curUsingWeapon and weapon ~= curUsingWeapon then
      local weaponSkinId = weapon:GetItemDefineID().TypeSpecificID
      if weaponSkinId ~= 0 then
        local skinMap = CDataTable.GetTableData("WeaponSkinMapping", weaponSkinId)
        if skinMap ~= nil then
          table.insert(unusedWeaponList, skinMap.WeaponID)
        else
          table.insert(unusedWeaponList, weaponSkinId)
        end
      end
    end
  end
  return unusedWeaponList
end
function LobbyAvatarManager.UnEquipExtraWeapon(uid)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.UnEquipExtraWeapon(%s)", uid))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.PutoffExtraWeapon(tostring(uid))
end
function LobbyAvatarManager.OnPlayerRotate(AvatarComp)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_AVATAR_ROTATE, AvatarComp)
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  lobbyMainLogic.OnPlayerRotate()
end
function LobbyAvatarManager.SetZRotationByStepForEnlarge(avatar, blendTime, turnaround)
  log(bWriteLog and string.format("[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.SetZRotationByStepForEnlarge(%s, %s, %s)", avatar, blendTime, turnaround))
  local _log = function(errorMessage)
    log_error(bWriteLog and "[LobbyAvatar][LobbyAvatarManager] LobbyAvatarManager.SetZRotationByStepForEnlarge not pass, reason: " .. tostring(errorMessage))
  end
  if not avatar then
    _log("avatar is nil")
    return
  end
  local operateAvatar = avatar:GetModel()
  if not slua.isValid(operateAvatar) then
    _log("model is illegal")
    return
  end
  local targetRotation = 0
  turnaround = turnaround or false
  local startRotation = avatar:GetModel():K2_GetActorRotation()
  log(bWriteLog and "Enlarge Data x:" .. tostring(startRotation.Roll) .. " y:" .. tostring(startRotation.Pitch) .. " z:" .. tostring(startRotation.Yaw))
  if 0 > startRotation.Yaw then
    startRotation.Yaw = 360 + startRotation.Yaw
  end
  if turnaround == true then
    targetRotation = 180 - startRotation.Yaw
  elseif startRotation.Yaw > 180 then
    targetRotation = 360 - startRotation.Yaw
  else
    targetRotation = 0 - startRotation.Yaw
  end
  operateAvatar:RotateOnTick(blendTime, targetRotation)
end
function LobbyAvatarManager.SetZRotationZero(avatar, blendTime)
  if not avatar then
    log(bWriteLog and "LobbyAvatarManager SetZRotationZero avatar is not Valid")
    return
  end
  local operateAvatar = avatar:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatarManager SetZRotationZero operateAvatar is not Valid")
    return
  end
  operateAvatar:RotateOnTick(blendTime, 0)
end
function LobbyAvatarManager.OnAvatarAllMeshLoaded(uid)
  local avatar = LobbyAvatarManager.beforeHideAvatars and LobbyAvatarManager.beforeHideAvatars[tostring(uid)]
  log(bWriteLog and "LobbyAvatarManager.OnAvatarAllMeshLoaded uid:" .. tostring(uid) .. " avatar:" .. tostring(avatar))
  if avatar then
    local show = true
    if avatar.HasHideFlag and avatar:HasHideFlag() then
      show = false
    end
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    if show and TeamAvatarManager.AvatarInShowGroup(avatar.positionIndex) and TeamAvatarManager.IsShowing() then
      avatar:ShowAvatar()
    end
    LobbyAvatarManager.ResetHideAvatar(uid)
  end
end
function LobbyAvatarManager.ResetHideAvatar(uid)
  if LobbyAvatarManager.beforeHideAvatars then
    LobbyAvatarManager.beforeHideAvatars[tostring(uid)] = nil
  end
end
function LobbyAvatarManager.ResetAllHideAvatar()
  LobbyAvatarManager.beforeHideAvatars = {}
end
return LobbyAvatarManager
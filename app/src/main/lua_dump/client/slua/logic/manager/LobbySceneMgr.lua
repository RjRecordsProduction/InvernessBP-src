LobbySceneManager = {
  LIGHT_LOBBY = 0,
  LIGHT_MALL_MODEL = 1,
  LIGHT_MALL_AVATAR = 2,
  LIGHT_ARENA_WEAPON = 3,
  LEVEL_NAME = {
    PET = "Mall_Pet_New",
    CHARACTER = "Lobby_warehouse_mesh",
    MALL = "Lobby_Shopping_Mesh",
    SUPPLY = "Lobby_Supply_mesh",
    GARAGE = "Lobby_Garage_mesh",
    ARMORY = "Lobby_armory",
    REFIT_VEHICLE = "Lobby_Refitvehicle_mesh",
    ITEM_PREVIEW = "PreviewBG",
    UNKNOW_PASS = "Lobby_RP170_SnowFestival_Mesh",
    UNKNOW_PASS_SEC = "Lobby_RP160_CyberWolf_Mesh",
    UNKNOW_PASS_THIRD = "Lobby_RP170_PlanA_Mesh",
    PICTORIAL_BOOK = "Lobby_Illustrated_mesh",
    CHANGE_BODY = "Lobby_changeBody_mesh",
    GOLDEN_SUIT_LOTTERY = "Lobby_BloodOath_mesh",
    GOLDEN_SUIT_LOTTERY_SPIN = "Lobby_BloodOath_Spin_mesh",
    GOLDEN_SUIT_UPGRADE = "Lobby_BloodOath_mesh",
    PREVIEW_NEW = "Lobby_Roulettebackground_mesh",
    ALLIANCE_SHOP = "Lobby_zhandui_mesh",
    ALLSTAR_SHOP = "Lobby_AllStar_mesh",
    RANK = "Lobby_rank_mesh",
    ROLE_INFO = "Lobby_BasicInfo_mesh",
    STOREWEAPONBGMESH = "Lobby_Store_Weapon_Mesh",
    PLAYERRETURNBGMESH = "Lobby_Player_Return_Mesh",
    GMMALLEDITORBGMESH = "Lobby_GM_Editor_Mesh",
    PANDORAMYSTERIOUSSHOPMESH = "Lobby_Pandora_Mysterious_Shop_Mesh",
    MENTORBGMESH = "Lobby_Mentor_Mesh",
    PRIVILEGESHOPBGMESH = "Lobby_Privilege_Shop_Mesh",
    GMAVATAREDITORBGMESH = "Lobby_GM_Avatar_Editor_Mesh",
    PARTNERPREVIEWBGMESH = "Lobby_Partner_Preview_Mesh",
    PDDACTIVITYBGMESH = "Lobby_PDD_Activity_Mesh",
    UPASSKOIBGMESH = "Lobby_Mentor_Mesh_COPY",
    PANDORAITEMUPDATEBG = "Lobby_Pandora_Item_Update_Mesh",
    WEAPONDIYBG = "Lobby_Weapon_DIY_Mesh",
    ITEMUPGRADE = "Lobby_Item_Upgrade_270_B",
    SUPERCAR = "Lobby_EVA_Mesh",
    WORLDCUPSHOP = "Lobby_WorldCupShop",
    GOLDEN_CLOTHES = "Lobby_GoldenSuitShopping_Common",
    POPULAR_PK_MESH = "Lobby_Rank_mesh_New250",
    ITEMUPGRADE_TARGET = "Lobby_Item_Upgrade_270_A",
    DRAGONBALL = "Lobby_Shop_DBZ_270",
    SUPER_AIRDROP = "Lobby_ZAOJIE_330",
    SmallRP300 = "Lobby_MP_300",
    PHOME_STORE = "Lobby_Home_shopping_Background",
    GLIDE_PREVIEW = "Lobby_Aircraft_BG_Common",
    HOME_PK_MESH = "Lobby_Rank_mesh_320",
    LOBBY_ZENITHCLASH = "Lobby_ZenithClash_340",
    Lobby_RP_Supply_mesh = "Lobby_RP_Supply_mesh",
    MAINCITY_MAP = "MainCityMap",
    Heirloom = "TPlan_Lobby_Weapon",
    WOW_PASS = "Lobby_WP_400",
    HonorRoad = "Lobby_Shop_400"
  },
  ENUM_ASYNC = {
    NORMAL_VECHILE = false,
    SUPER_CAR = false,
    RP = false,
    AVATAR_DISPLAY = true,
    ROLE_INFO = true,
    WOW_PASS = false
  },
  LoadedSpecialSceneList = {},
  LatestScene = nil,
  WaitToPresentScene = nil,
  WaitToPresentLight = nil,
  WaitToUnloadScenes = {},
  DefaultScene = nil,
  DefaultCameraID = nil
}
local LobbySceneMgrHelper = require("client.slua.logic.manager.LobbySceneSubLogic.LobbySceneMgrHelper")
local LockLobbyCameraLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LockLobbyCameraLogic")
local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
local LobbySceneManager.
function LobbySceneManager.OnModePreSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    EventSystem:registEvent(EVENTTYPE_LOBBY_EMOTE, EVENTID_LOBBY_EMOTE_REPLACE_LIGHT, LobbySceneManager.OnForceReplaceLight)
    EventSystem:registEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, LobbySceneManager.OnSceneLoaded)
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    EventSystem:unregistEvent(EVENTTYPE_LOBBY_EMOTE, EVENTID_LOBBY_EMOTE_REPLACE_LIGHT, LobbySceneManager.OnForceReplaceLight)
    EventSystem:unregistEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, LobbySceneManager.OnSceneLoaded)
  end
  LobbyLightLogic.UnloadAllLoadedLevel()
end
function LobbySceneManager.OnModePostSwitch(preState, nextState)
  LobbyLightLogic.Clear()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.DestroyWeaponShowActor()
end
function LobbySceneManager.ChangeMallSceneMaterial(materialID)
  LobbySceneMgrHelper.ChangeMallSceneMaterial(materialID)
end
function LobbySceneManager.ChangeMallSceneTexture(url)
  LobbyLightLogic.SetLastLevelName(url)
  LobbySceneMgrHelper.ChangeMallSceneTexture(url)
  log_shipping_client("LobbySceneManager ChangeMallSceneTexture:" .. url)
end
function LobbySceneManager.ChangeWeaponSceneTexture(url)
  LobbySceneMgrHelper.ChangeWeaponSceneTexture(url)
  log_shipping_client("LobbySceneManager ChangeWeaponSceneTexture:" .. url)
end
function LobbySceneManager.ChangePictorialSceneTexture(url)
  LobbySceneMgrHelper.ChangePictorialSceneTexture(url)
  log_shipping_client("LobbySceneManager ChangePictorialSceneTexture:" .. url)
end
function LobbySceneManager.ChangeLight(lightType)
  LobbySceneMgrHelper.ChangeLight(lightType)
end
function LobbySceneManager.SetMallWeaponParticalVisiable(isVisiable)
  LobbySceneMgrHelper.SetMallWeaponParticalVisible(isVisiable)
  log_shipping_client("LobbySceneManager SetMallWeaponParticalVisiable:" .. tostring(isVisiable))
end
function LobbySceneManager.CreateSceneExtraModel(...)
  local SceneExtraModel = require("client.slua.logic.manager.LobbySceneSubLogic.SceneExtraModel")
  return SceneExtraModel.Create(...)
end
function LobbySceneManager.ParseVec3(str)
  return LobbySceneMgrHelper.ParseVec3(str)
end
function LobbySceneManager.SwitchMainOrTeamCamera(force)
  LockLobbyCameraLogic.SwitchMainOrTeamCamera(force)
end
function LobbySceneManager.CheckCanSwitchToLobbyCamera()
  return LockLobbyCameraLogic.CheckCanSwitchToLobbyCamera()
end
function LobbySceneManager.SetLockLobbyCamera(isLock)
  LockLobbyCameraLogic.SetLockLobbyCamera(isLock)
end
function LobbySceneManager.SwitchBackLobbyMainCamera()
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(true)
end
function LobbySceneManager.unloadAllStreamLevel()
  LobbyLightLogic.unloadStreamLevelByMap(LobbySceneManager.LEVEL_NAME)
end
function LobbySceneManager.LoadLightLevel(lightLevelName, bAync)
  LobbyLightLogic.LoadLightLevel(lightLevelName, bAync)
end
function LobbySceneManager.LoadStreamLevel(isLoad, SceneName, CameraID, LightName, Extra)
  log(bWriteLog and string.format("LobbySceneManager.LoadStreamLevel isLoad : %s , SceneName : %s , CameraID : %s , LightName : %s", isLoad, SceneName, CameraID, LightName))
  log_tree("LobbySceneManager.LoadStreamLevel Extra", Extra)
  Extra = Extra or {}
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  if Extra.UnloadLevelName then
    LobbySceneModule:UnloadStreamLevel(Extra.UnloadLevelName)
  end
  if isLoad then
    LobbySceneModule:LoadStreamLevel(SceneName, CameraID, LightName, Extra)
    LobbySceneManager.LatestScene = SceneName
  else
    LobbySceneModule:UnloadStreamLevel(SceneName, Extra.bForceUnload)
  end
end
function LobbySceneManager.IsMainLobbyCameraID(CameraID)
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  return LobbySceneModule:IsMainLobbyCameraID(CameraID)
end
function LobbySceneManager.DestroyXmissionEnterEmitter()
  LobbySceneMgrHelper.DestroyXmissionEnterEmitter()
end
function LobbySceneManager.GetLastLevelName()
  return LobbyLightLogic.GetLastLevelName()
end
function LobbySceneManager.GetLoadingCameraID()
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  return LobbySceneModule.LoadingCameraID
end
function LobbySceneManager.OnForceReplaceLight(_, _, bExcute, LightLevelName, extra)
  log(bWriteLog and "LobbySceneManager.OnForceReplaceLight")
  if bExcute then
    LobbyLightLogic.SetCurLightVisible(false)
    LobbyLightLogic.LoadStreamLevel(true, LightLevelName, true, false)
  else
    LobbyLightLogic.SetCurLightVisible(true)
    LobbyLightLogic.LoadStreamLevel(false, LightLevelName, true, false)
  end
end
function LobbySceneManager.OnSceneLoaded(_, __, levelName)
  if levelName == "Lobby_Light" then
    local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
    LobbyLightLogic.SwitchTeamLight()
  end
end
function LobbySceneManager.CacheSpecialLevelList(LevelName)
  table.insert(LobbySceneManager.LoadedSpecialSceneList, LevelName)
end
function LobbySceneManager.UnLoadSpecialStreamLevel()
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  if not LobbySceneManager.LoadedSpecialSceneList then
    return
  end
  for k, v in ipairs(LobbySceneManager.LoadedSpecialSceneList) do
    if v then
      LobbySceneModule:UnloadStreamLevel(v)
    end
  end
  LobbySceneManager.LoadedSpecialSceneList = {}
end
function LobbySceneManager.IsLevelStreamingMatchName(uLevelStreaming, LevelName)
  local StringUtil = require("common.string_util")
  local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
  return StringUtil.Ends(PackageName, LevelName)
end
function LobbySceneManager.IsStreamLevelLoaded(sLevelName)
  if sLevelName == nil then
    print(bWriteLog and "LevelStreamingMgr:IsStreamLevelLoaded levelName is nil")
    return false
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return false
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if LobbySceneManager.IsLevelStreamingMatchName(uLevelStreaming, sLevelName) then
      local uLevel = uLevelStreaming:GetLoadedLevel()
      return slua.isValid(uLevel)
    end
  end
  return false
end
function LobbySceneManager.GetStreamLevel(sLevelName)
  if sLevelName == nil then
    print(bWriteLog and "LevelStreamingMgr:IsStreamLevelLoaded levelName is nil")
    return nil
  end
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(uWorld) then
    return nil
  end
  local StreamingLevels = uWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return nil
  end
  for _, uLevelStreaming in pairs(StreamingLevels) do
    if LobbySceneManager.IsLevelStreamingMatchName(uLevelStreaming, sLevelName) then
      local uLevel = uLevelStreaming:GetLoadedLevel()
      if slua.isValid(uLevel) then
        return uLevel
      end
      return nil
    end
  end
  return nil
end
function LobbySceneManager.GetActorsFromLevel(uLevel)
  if not slua.isValid(uLevel) then
    return
  end
  local Actors = {}
  local FrontendUtils = slua_GameFrontendHUD:GetUtils()
  local uActorClass = import("/Script/Engine.Actor")
  if FrontendUtils.GetAllActorsFromLevel then
    Actors = FrontendUtils:GetAllActorsFromLevel(uLevel, slua.Array(UEnums.EPropertyClass.Object, uActorClass))
  end
  return Actors
end
return LobbySceneManager
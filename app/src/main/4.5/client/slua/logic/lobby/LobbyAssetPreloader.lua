local LobbyAssetPreloader = {
  preloadMainAssets = {
    "/Game/UMG/UI_BP/LoginLoading/Login_LoadingNew_UIBP.Login_LoadingNew_UIBP_C",
    "/Game/BluePrints/Backpack/BattleItemHandles/Guns/BattleItemHandle_MainWeapon.BattleItemHandle_MainWeapon_C",
    "/Game/BluePrints/Backpack/BattleItemHandles/Guns/BattleItemHandle_Pistol.BattleItemHandle_Pistol_C",
    "/Game/UMG/UI_Logic/Common/CommonItem/Common_Items_UIBP.Common_Items_UIBP_C",
    "/Game/UMG/UI_Logic/Common/Common_Item_BP.Common_Item_BP_C",
    "/Game/Arts_PlayerBluePrints/Vehicle_Show/BP_LobbyRefitVehicle.BP_LobbyRefitVehicle_C"
  }
}
if IsWoWEditor then
  LobbyAssetPreloader.preloadMainAssets = {
    "/Game/UMG/UI_BP/LoginLoading/Login_LoadingNew_UIBP.Login_LoadingNew_UIBP_C",
    "/Game/UMG/UI_Logic/Common/CommonItem/Common_Items_UIBP.Common_Items_UIBP_C",
    "/Game/UMG/UI_Logic/Common/Common_Item_BP.Common_Item_BP_C"
  }
end
local LobbyUIMacro = require("client.slua.umg.lobby.Main.Config.LobbyUIMacro")
function LobbyAssetPreloader:DefineAndResetData()
  self.bPreloader = false
end
function LobbyAssetPreloader:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Login then
    self:DefineAndResetData()
  end
end
function LobbyAssetPreloader:PreloadLobbyUIAsset()
  if self.bPreloader then
    log_error(bWriteLog and "LobbyAssetPreloader:PreloadLobbyUIAsset. Already preloader")
    return
  end
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    return
  end
  self.bPreloader = true
  log(bWriteLog and "LobbyAssetPreloader:PreloadLobbyUIAsset. ")
  local uiTypeArr = LobbyUIMacro.lobbyUIArr
  local preLoadList = {}
  local skipUIList = {
    [UIManager.UI_Config.Lobby_Mid_Friend_UIBP] = true,
    [UIManager.UI_Config.Lobby_Mid_Message_UIBP] = true
  }
  for i, v in ipairs(uiTypeArr) do
    if not skipUIList[v] then
      table.insert(preLoadList, v)
    end
  end
  self:_PreloadUI(preLoadList)
  self:_PreloadUI(LobbyUIMacro.lobbyChildUIPreloadArr)
  self:_PreloadMainAsset()
end
function LobbyAssetPreloader:_PreloadMainAsset()
  local PreloadAssetManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PreloadAssetManager)
  PreloadAssetManager:UIAsyncPreloadArray(self.preloadMainAssets)
end
function LobbyAssetPreloader:PreloadLobbyRightAsset()
  self:_PreloadUI(LobbyUIMacro.rightModeUIArr)
end
function LobbyAssetPreloader:_PreloadUI(uiTypeArr)
  if uiTypeArr == nil or #uiTypeArr == 0 then
    return
  end
  local AssetPathArray = {}
  for i = 1, #uiTypeArr do
    AssetPathArray[#AssetPathArray + 1] = uiTypeArr[i].path .. "_C"
  end
  local PreloadAssetManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PreloadAssetManager)
  PreloadAssetManager:UIAsyncPreloadArray(AssetPathArray)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyAssetPreloader = class(CModuleBase, nil, LobbyAssetPreloader)
return CLobbyAssetPreloader
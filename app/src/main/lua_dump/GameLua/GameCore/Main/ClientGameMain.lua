local ClientGameMain = {
  UIOtherSetting = nil,
  CurrentConfig = nil,
  OldModConfig = {
    BaseMod = "",
    SingleTraining = "singletrainclient",
    ZombiePVE = "walkingdeath",
    TDM = "tmode",
    HeavyWeapon = "heavyweapon",
    VehicleWar = "vehiclewartdm",
    SuperCold = "supercold_mode",
    SocialIsland = "socialisland"
  },
  LastModeID = nil
}
require("client.common.event.EventProxy")
function ClientGameMain.InitFile()
  require("GameLua.Mod.BaseMod.Common.Global")
  require("GameLua.Mod.BaseMod.Common.Core.EnumDefine")
  require("GameLua.Mod.BaseMod.GamePlay.Core.GameAPI")
  require("GameLua.Mod.BaseMod.Client.Core.ClientAPI")
  require("common.func_util")
  require("GameLua.Mod.BaseMod.GamePlay.Config.EventDefine")
  _G.SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  GameplayData.InitInagmeEntry()
  local UIMessageSystem = require("GameLua.GameCore.Main.UIMessageSystem")
  UIMessageSystem.InitInagmeEntry()
  local GameComponentData = require("GameLua.GameCore.Data.GameComponentData")
  GameComponentData.InitInagmeEntry()
  local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
  GameplayActorData.InitInagmeEntry()
end
function ClientGameMain.InitInagmeEntry()
  log(bWriteLog and "ClientGameMain.InitInagmeEntry")
  ClientGameMain.HasApplyExtraMods = false
  ClientGameMain.InitFile()
  local STExtraGameStateBase = import("STExtraGameStateBase")
  local Switcher = require("GameLua.GameCore.Main.Switcher")
  local OnGameStateBeginPlayDelegate = slua.createDelegate(ClientGameMain.HandleGameStateBeginPlay)
  local OnOnGameStateEndPlayDelegate = slua.createDelegate(ClientGameMain.HandleGameStateEndPlay)
  local delegates = {}
  ClientGameMain._  table.insert(delegates, OnGameStateBeginPlayDelegate)
  table.insert(delegates, OnOnGameStateEndPlayDelegate)
  STExtraGameStateBase.SetOnGameStateBeginPlay(OnGameStateBeginPlayDelegate)
  STExtraGameStateBase.SetOnGameStateEndPlay(OnOnGameStateEndPlayDelegate)
  ClientGameMain.InitIngameSystem()
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    log(bWriteLog and "ClientGameMain.InitInagmeEntry ui_show_queue_manager")
    local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
    ui_show_queue_manager.OnLogin()
  end
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_LOBBY_ENTRY, ClientGameMain.OnPreSwitch)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_LOBBY_ENTRY, ClientGameMain.OnPostSwitchLobbyEntry)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, ClientGameMain.OnPreSwitch)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, ClientGameMain.OnPostSwitchStart)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, ClientGameMain.OnPostSwitch)
  EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY, ClientGameMain.OnControllerBeginPlay)
  EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_BEGINPLAY_FINISH, ClientGameMain.OnControllerBeginPlayFinish)
  EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_INIT_MODEUI, ClientGameMain.InitModeUI)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, Switcher.OnPostSwitch)
end
function ClientGameMain.InitIngameSystem()
  print(bWriteLog and "ClientGameMain.InitIngameSystem")
  if Client and HDmpveRemote.HDmpveRemoteConfigGetInt("EnableAOS32LowMemory", 0) == 1 then
    Client.EnableLowMemoryDevice(true)
  end
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  NewbieGuideMgr.Init()
end
function ClientGameMain.InitCurrentGameConfig()
  print(bWriteLog and "ClientGameMain.InitCurrentGameConfig")
  local t1 = slua.getMiliseconds()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  if not ClientGameMain.HasApplyExtraMods then
    require("combine_class").HookLuaRequire(true)
    GameMainConfig.ApplyModFeatures(true)
    GameMainConfig.ApplyModConfigs(true)
    GameMainConfig.ApplyModOtherConfigs(true)
    ClientGameMain.HasApplyExtraMods = true
  end
  ClientGameMain.CurrentConfig = GameMainConfig.GetConfig(true)
  ClientGameMain.UIOtherSetting = {}
  local ModType = GameMainConfig.GetModType()
  ClientGameMain.OldMod = ""
  if ModType then
    ClientGameMain.OldMod = ClientGameMain.OldModConfig[ModType]
  end
  if ClientGameMain.CurrentConfig then
    UIManager.InitConfigInGame(ClientGameMain.CurrentConfig.UIConfig.UIConfig)
    ClientGameMain.UIOtherSetting = ClientGameMain.CurrentConfig.UIConfig.OtherSetting
    local ds_net = require("ds_net")
    ds_net.InitRoute(ClientGameMain.CurrentConfig.EventConfig)
  end
  local t2 = slua.getMiliseconds()
  print(bWriteLog and "ClientGameMain.InitCurrentGameConfig time = " .. t2 - t1 .. "ms. ModType=", ModType)
end
function ClientGameMain.OnPreExitBattle(status)
  require("combine_class").HookLuaRequire(false)
  ClientGameMain.HasApplyExtraMods = false
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.OnPreExit then
    ClientGameMain.CurrentModeLogic:OnPreExit(status)
  end
  UIManager.UnInitConfigInGame()
end
function ClientGameMain.OnPostSwitchLobbyEntry(_, _, status)
  printf("ClientGameMain.OnPostSwitchLobbyEntry %s -> %s", status.pre, status.current)
  ClientGameMain.ClearCriticalUClassNetProps()
end
function ClientGameMain.OnPreSwitch(_, _, status)
  print(bWriteLog and "ClientGameMain.OnPreSwitch")
  log_tree("status = ", status)
  GameStatus.SetCombatActiveState(false)
  if (status.current == GameStatus.Lobby or status.current == GameStatus.Loading or status.current == GameStatus.Login or status.current == "<EmptyForTestLeak>") and status.pre == GameStatus.Fighting then
    print(bWriteLog and "ClientGameMain.OnPreSwitch call OnPreExitBattle status.pre == GameStatus.Fighting")
    ClientGameMain.OnPreExitBattle(status)
  elseif status.current == GameStatus.Fighting then
    if status.pre == GameStatus.Lobby then
      print(bWriteLog and "ClientGameMain.OnPreSwitch call OnPreExitBattle status.pre == GameStatus.Lobby")
      ClientGameMain.OnPreExitBattle(status)
    end
    print(bWriteLog and "ClientGameMain.OnPreSwitch InitCurrentGameConfig")
    require("GameLua.GameCore.Main.GameMainConfig").Clear()
    if not ClientGameMain.IsReplayClient() then
      local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
      if MainCityConfig.bOptimization and GameStatus.IsInMainCity() then
      else
        ClientGameMain.InitCurrentGameConfig()
      end
    end
  elseif (status.current == GameStatus.Loading or status.current == GameStatus.Login) and status.pre == GameStatus.Lobby then
    print(bWriteLog and "ClientGameMain.OnPreSwitch call OnPreExitBattle status.pre == GameStatus.Lobby status.current == GameStatus.Loading or GameStatus.Login")
    ClientGameMain.OnPreExitBattle(status)
  end
end
function ClientGameMain.OnPostSwitchStart(_, _, status)
  printf("ClientGameMain.OnPostSwitchStart %s -> %s", status.pre, status.current)
  local bReconnect = false
  if status.pre == status.current and status.current == GameStatus.Fighting then
    sandbox.LogWarning("ClientGameMain.OnPostSwitchStart Enter Fighting state again, maybe reconnect and Re EnterBattle without exit to lobby")
    bReconnect = true
    _G.SubsystemMgr:EndPlay(bReconnect)
    _G.SubsystemMgr:Destroy(bReconnect)
  end
  if status.current == GameStatus.Fighting then
    local InitType = ClientGameMain.GetInitType()
    _G.SubsystemMgr:InitDev(InitType)
  end
  if status.pre == GameStatus.Fighting and status.current == GameStatus.Loading then
    ClientGameMain.ClearCriticalUClassNetProps()
  end
  if _G.IsEnableMockGameSvr and status.current == "Lobby" then
    print(bWriteLog and "ClientGameMain.OnPostSwitchStart IsEnableMockGameSvr NetManager.Init()")
    NetUtil.BindEnterBattleStageDelegate()
    local NetManager = require("client.network.comm.NetManager")
    NetManager.Init()
    local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
    ClientEVOConfig.Init()
  end
end
function ClientGameMain.OnPostSwitch(_, _, status)
  print(bWriteLog and "ClientGameMain.OnPostSwitch")
  log_tree("status = ", status)
  if status.current ~= GameStatus.Fighting then
    ClientGameMain.InitBackPackUtil(0)
  end
  if status.current == GameStatus.Fighting then
    if IsEditor then
      local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
      if MainCityConfig.bOptimization and GameStatus.IsInMainCity() then
      else
        ClientGameMain.InitCurrentGameConfig()
      end
    elseif ClientGameMain.IsReplayClient() then
      ClientGameMain.InitCurrentGameConfig()
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
    if GameStatus.IsInMainCity() then
      ClientGameMain.CurrentConfig = GameMainConfig.GetConfig(true)
    end
    if ClientGameMain.CurrentConfig and ClientGameMain.CurrentConfig.ClientModeLogic ~= "" then
      local CModeLogic = require(ClientGameMain.CurrentConfig.ClientModeLogic)
      if CModeLogic then
        local ModeLogicInstance = CModeLogic()
        ClientGameMain.CurrentModeLogic = ModeLogicInstance
        ClientGameMain.CurrentModeLogic.OldUIConfig = ClientGameMain.CurrentConfig.UIConfig.OldUIConfig
        if ModeLogicInstance.OnPostEnter then
          ModeLogicInstance:OnPostEnter(status)
        end
      end
    end
    local InitType = ClientGameMain.GetInitType()
    log(bWriteLog and string.format("ClientGameMain.OnPostSwitch InitType=%s", InitType))
    if _G.SubsystemMgr:Init(InitType) then
      _G.SubsystemMgr:CallOnPreRep()
    end
    local WeaponSystem = require("GameLua.GameCore.Module.Weapon.WeaponSystem")
    WeaponSystem:Init()
    if slua_GameFrontendHUD ~= nil then
      local GameInstance = slua_GameFrontendHUD:GetGameInstance()
      if slua.isValid(GameInstance) then
        local nDeviceLevel = GameInstance:GetDeviceLevel()
        if 1 <= nDeviceLevel then
          local timer_ticker = require("common.time_ticker")
          local timerHander = timer_ticker.AddTimerOnce(0.2, function()
            local LoadingSystem = require("client.slua.logic.loading.logic_loading")
            LoadingSystem.DownloadInGameImages()
          end)
        end
      end
    end
    local modeid = require("GameLua.GameCore.Main.GameMainConfig").GetModeID()
    ClientGameMain.InitBackPackUtil(modeid)
  else
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ClearInGameImages()
    if ClientGameMain.CurrentModeLogic then
      if ClientGameMain.CurrentModeLogic.OnPostExit then
        ClientGameMain.CurrentModeLogic:OnPostExit(status)
      end
      ClientGameMain.CurrentModeLogic = nil
      require("GameLua.GameCore.Main.GameMainConfig").Clear()
    end
  end
end
function ClientGameMain.IsStandalone()
  local UIUtil = require("client.common.ui_util")
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  return UKismetSystemLibrary.IsStandalone(UIUtil.GetGameInstance())
end
function ClientGameMain.GetInitType()
  local bIsStandalone = ClientGameMain.IsStandalone()
  if bIsStandalone then
    if GameStatus.IsInMainCity() then
      log(bWriteLog and "ClientGameMain.GetInitType IsStandalone and in main city mode, set bIsStandalone to false")
      bIsStandalone = false
    end
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType = GameMainConfig.GetModType()
    log(bWriteLog and "ClientGameMain.GetInitType ModType = " .. tostring(ModType))
    if ModType == "MainCity" then
      bIsStandalone = false
    end
  end
  local InitType = bIsStandalone and "Both" or "Client"
  log(bWriteLog and string.format("ClientGameMain.GetInitType InitType=%s", InitType))
  return InitType
end
function ClientGameMain.OnControllerBeginPlay(nEventType, nEventID)
  print(bWriteLog and "ClientGameMain.OnControllerBeginPlay", nEventType, nEventID)
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.OnControllerBeginPlay then
    ClientGameMain.CurrentModeLogic:OnControllerBeginPlay()
  end
  local ds_net = require("ds_net")
  ds_net.InitReceiveDelegate()
end
function ClientGameMain.OnControllerBeginPlayFinish(nEventType, nEventID)
  print(bWriteLog and "ClientGameMain.OnControllerBeginPlayFinish", nEventType, nEventID)
  GameStatus.SetCombatActiveState(true)
end
function ClientGameMain.InitModeUI(nEventType, nEventID)
  print(bWriteLog and "ClientGameMain.InitModeUI", nEventType, nEventID)
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  if not UIUtil.IsValid(uGameState) or not UIUtil.IsValid(uPlayerController) then
    return
  end
  if ClientGameMain.CurrentModeLogic then
    local CurrentModeLogic = ClientGameMain.CurrentModeLogic
    if CurrentModeLogic.OnInitModeUI and not CurrentModeLogic.bHasInitModeUI then
      if CurrentModeLogic.GenerateAutoCreateUI then
        CurrentModeLogic:GenerateAutoCreateUI(ClientGameMain.CurrentConfig.UIConfig.AutoCreateUIConfig)
      end
      UIManager.ShowAutoCreateUI()
      CurrentModeLogic:OnInitModeUI()
    end
  end
  if slua.isValid(uGameState) then
    local ModeUIArray = uGameState.ModeUIManagerArrayCached
    ModeUIArray:Clear()
    ModeUIArray:Add("ingamesub")
    ModeUIArray:Add("ingame")
    local OldMod = ClientGameMain.OldMod
    if OldMod and OldMod ~= "" then
      ModeUIArray:Add(OldMod)
    end
  end
end
function ClientGameMain.UseCustomGameResult()
  if ClientGameMain.CurrentModeLogic then
    return ClientGameMain.CurrentModeLogic.bCustomGameReuslt
  end
  return false
end
function ClientGameMain.UseBattleResultSubSystem()
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.UseBattleResultSubSystem then
    return ClientGameMain.CurrentModeLogic:UseBattleResultSubSystem()
  end
  return true
end
function ClientGameMain.OnGameResult(battle_result)
  log_tree("ClientGameMain.OnGameResult", battle_result)
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.OnGameResult then
    ClientGameMain.CurrentModeLogic:OnGameResult(battle_result)
  end
  GameStatus.SetCombatActiveState(false)
end
function ClientGameMain.OnOBBattleResult(room_result, room_stat, customize_result)
  print(bWriteLog and "ClientGameMain.OnOBBattleResult")
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.OnOBBattleResult then
    return ClientGameMain.CurrentModeLogic:OnOBBattleResult(room_result, room_stat, customize_result)
  end
  GameStatus.SetCombatActiveState(false)
  return false
end
function ClientGameMain.ShowCustomGameResult()
  print(bWriteLog and "ClientGameMain.ShowCustomGameResult")
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.ShowCustomGameResult then
    ClientGameMain.CurrentModeLogic:ShowCustomGameResult()
  end
  GameStatus.SetCombatActiveState(false)
end
function ClientGameMain.ShowCustomWatchReport()
  print(bWriteLog and "ClientGameMain.ShowCustomWatchReport")
  if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.ShowCustomWatchReport then
    ClientGameMain.CurrentModeLogic:ShowCustomWatchReport()
  end
end
function ClientGameMain.HandleGameStateEndPlay(EndPlayReason)
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_END_PLAY, EndPlayReason)
end
function ClientGameMain.HandleGameStateBeginPlay(GameState)
  log(bWriteLog and "ClientGameMain.HandleGameStateBeginPlay")
  EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_BEGIN_PLAY, GameState)
end
function ClientGameMain.GetUIOtherSetting(Key)
  if ClientGameMain.UIOtherSetting and ClientGameMain.UIOtherSetting[Key] then
    return ClientGameMain.UIOtherSetting[Key]
  else
    return nil
  end
end
function ClientGameMain.GetCurrentConfig(Key)
  if ClientGameMain.CurrentConfig and ClientGameMain.CurrentConfig[Key] then
    return ClientGameMain.CurrentConfig[Key]
  end
  return nil
end
function ClientGameMain.IsReplayClient()
  if not Client then
    print(bWriteLog and "ClientGameMain.IsReplayClient return false")
    return false
  end
  if not Client.IsWindowsClientReplay then
    print(bWriteLog and "ClientGameMain.IsReplayClient return false")
    return false
  end
  local IsWindowsClientReplay = Client.IsWindowsClientReplay()
  print(bWriteLog and "ClientGameMain.IsReplayClient IsWindowsClientReplay", IsWindowsClientReplay)
  return IsWindowsClientReplay
end
function ClientGameMain.InitBackPackUtil(ModeID)
  print(bWriteLog and "ClientGameMain.InitBackPackUtil:" .. tostring(ModeID))
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local _LastModeID = ClientGameMain.LastModeID
  ClientGameMain.Last  if _LastModeID and (_LastModeID == 0 and ModeID == 26000 or _LastModeID == 26000 and ModeID == 0 or _LastModeID == ModeID) then
    print(bWriteLog and "ClientGameMain.InitBackPackUtil return _LastModeID:" .. tostring(_LastModeID))
    return
  end
  if ModeID and 0 < ModeID then
    local BTMode = GamePlayTools.GetTableData("BTMode", ModeID)
    if not BTMode then
      return
    end
    local ModeType = BTMode.ModType
    print(bWriteLog and "ClientGameMain.InitBackPackUtil:ModeType:" .. ModeType)
    local firstCap, endCap = string.find(ModeType, "DBZ", 1, true)
    ClientGameMain.InitBackPackUtilRegisterInvokeClass()
    if firstCap and endCap then
      local UBackpackDBZUtils = import("BackpackDBZUtils")
      UBackpackDBZUtils.RegisterInvokeClass()
    else
      firstCap, endCap = string.find(ModeType, "TPlan", 1, true)
      if firstCap and endCap then
        local UBackpackTPlanUtils = import("BackpackTPlanUtils")
        UBackpackTPlanUtils.RegisterInvokeClass()
      else
        local UBackpackUtilsClassical = import("BackpackUtilsClassical")
        UBackpackUtilsClassical.RegisterInvokeClass()
      end
    end
  else
    ClientGameMain.InitBackPackUtilRegisterInvokeClass()
    local UBackpackUtilsClassical = import("BackpackUtilsClassical")
    UBackpackUtilsClassical.RegisterInvokeClass()
  end
end
function ClientGameMain.InitBackPackUtilRegisterInvokeClass()
  local UBackpackTPlanUtils = import("BackpackTPlanUtils")
  if UBackpackTPlanUtils then
    UBackpackTPlanUtils.UnRegisterInvokeClass()
  end
  local UBackpackUtilsClassical = import("BackpackUtilsClassical")
  if UBackpackUtilsClassical then
    UBackpackUtilsClassical.UnRegisterInvokeClass()
  end
end
function ClientGameMain.ClearCriticalUClassNetProps()
  print(bWriteLog and "ClientGameMain.ClearCriticalUClassNetProps")
end
function ClientGameMain.UpdateBasePath()
  local UBusinessHelper = import("BusinessHelper")
  if not UBusinessHelper then
    return
  end
  local BasePath = Client.ProjectContentDir() .. "Paks/"
  local FullPath = UBusinessHelper.GetMobileBasePath(BasePath)
  print(bWriteLog and string.format("ClientGameMain.UpdateBasePath BasePath[%s] FullPath[%s]", BasePath, FullPath))
  local files = Client.GetAllFilesInDir(FullPath, "*.pak")
  if 0 < #files then
    for _, file in pairs(files) do
      print(bWriteLog and "ClientGameMain.UpdateBasePath files exit " .. file)
    end
    Client.DeleteDirectory(FullPath)
  else
    print(bWriteLog and "ClientGameMain.UpdateBasePath files nil")
  end
end
return ClientGameMain
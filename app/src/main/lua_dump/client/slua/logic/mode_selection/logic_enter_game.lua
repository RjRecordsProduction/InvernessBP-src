local logic_enter_game = {}
function logic_enter_game:OnInitialize()
  logic_enter_game.__super.OnInitialize(self)
  self.PendingEnterInfo = nil
  self.PendingReEnterInfo = nil
  self.custom_room_id = nil
  self.antsVoiceInfo = nil
  self.ModNameEnterBattle = ""
  self.str_sub_mode_id = "0"
  self.InGameReEnterGameInfo = nil
  self.InGameShowingReEnter = false
  self.GameOverGameID = nil
  self.ReEnterGameLoadingCheckTimer = nil
  self.bReportDSInfo = false
end
function logic_enter_game:DefineAndResetData()
  self.priKey = nil
  self.pubKey = nil
end
function logic_enter_game:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, self.RemoveReEnterGameLoadingCheckTimer, self)
end
function logic_enter_game:SetSubMode(sub_mode)
  self.  GameStatus.SetSubMode(sub_mode)
end
function logic_enter_game:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_enter_game:OnPostSwitchGameStatus status:" .. nextState)
  if nextState == GameStatus.Loading and self.IsPendingEnter and self.PendingEnterInfo then
    if self.IsPendingEnterStandAlone then
      self:EnterBattleStandAlone(table.unpack(self.PendingEnterInfo, 1, 3))
    else
      self:on_enter_game(table.unpack(self.PendingEnterInfo, 1, 24))
    end
  end
  if nextState == GameStatus.Login then
    self.game_info = nil
    self.bGetGameInfo = false
    if self.InGameShowingReEnter then
      self.InGameShowingReEnter = false
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.HideAllPanel()
      log(bWriteLog and "logic_enter_game:OnPostSwitchGameStatus auto close ReEnter MsgBox on Login")
    end
  end
  if nextState == GameStatus.Lobby then
    log(bWriteLog and "logic_enter_game:OnPostSwitchGameStatus clear cache_game_id")
    self.cache_game_id = nil
  end
end
function logic_enter_game:OnLogin(bReLogin)
end
function logic_enter_game:OnLogOut()
end
function logic_enter_game:OnPreSwitchGameStatus(preState, nextState)
end
function logic_enter_game:IsEnterBattleByRoom()
  return self.custom_room_id and self.custom_room_id ~= 0
end
function logic_enter_game:SetRoomID(id)
  self.custom_room_end
function logic_enter_game:SetAntsVoiceInfo(antsVoiceInfo)
  self.end
function logic_enter_game:GetSubModeId()
  return self.str_sub_mode_id
end
function logic_enter_game:SetKey()
  self.priKey = Client.GetPrivateKey()
  self.pubKey = Client.GetPublicKey(self.priKey)
end
function logic_enter_game:IsReEnterGame()
  if self.PendingReEnterInfo then
    log(bWriteLog and "logic_enter_game:IsReEnterGame. true")
    return true
  end
  log(bWriteLog and "logic_enter_game:IsReEnterGame. false")
  return false
end
function logic_enter_game:EnterGameCommon(sub_mode, ad_conf, land_id, game_id, eigeninfo, eigeninfo_param, custom_room_id)
  self.str_sub_mode_id = tostring(sub_mode or 0)
  g_  log_tree("logic_enter_game:EnterGameCommon ad_conf", ad_conf)
  log_tree("logic_enter_game:EnterGameCommon eigeninfo", eigeninfo)
  local logic_island_status = require("GameLua.Mod.SocialIsland.Client.IslandStatusLogic")
  logic_island_status:SetMyLandData(land_id, game_id)
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  local IsMainCitySubMode = Lobby_Main_City.IsMainCitySubMode(sub_mode)
  log(bWriteLog and "logic_enter_game:EnterGameCommon IsMainCitySubMode = " .. tostring(IsMainCitySubMode))
  if not IsMainCitySubMode then
    local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
    LogicUGCCRUD:OnEnterGame()
  else
    Lobby_Main_City.AddMainCityGameIDToBucket(game_id)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:SetUGCGameMod(sub_mode)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if custom_room_id and custom_room_id ~= 0 then
    LogicUGCMatch:UpdateLastRoomMatchTime()
  else
    LogicUGCMatch:UpdateLastMatchTime()
  end
  if LogicUGC:IsUGCGameMod() then
    Client.AddCrashContextData(1005, "True", false, 100)
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local ugcMatchInfo = LogicUGCMatch:GetCurrentMatchInfoForFight() or {}
    Client.AddCrashContextData(1006, ugcMatchInfo.mod_id or 0, false, 100)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    if strRegion ~= PublishRegionMacros.BLUEHOLE then
      local TApmHelper = import("TApmHelper")
      TApmHelper.postEvent(755, tostring(ugcMatchInfo.mod_id or 0), false)
      TApmHelper.postEvent(777, tostring(ugcMatchInfo.template_id or 0), false)
    end
    local LogicUgcUObject = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_uobject)
    LogicUgcUObject:SetModID(ugcMatchInfo.mod_id or 0)
  else
    Client.AddCrashContextData(1005, "False", false, 100)
    Client.AddCrashContextData(1006, 0, false, 100)
  end
  if not IsMainCitySubMode then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom then
      UGCPlayHallRoom:OnEnterGame()
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  Client.AddCrashContextData(17, tostring(sub_mode or 0), false, 100)
  Client.AddCrashContextData(18, tostring(TeamUpNewSystem.GetTeamNum()), false, 100)
  local SocialIslandAddsManager = require("client.slua.logic.social_island.logic_socialisland_adds")
  SocialIslandAddsManager.InitData(ad_conf)
  self.  log_shipping_client("logic_enter_game:EnterGameCommon SendEigeninfo")
  LobbySystem.SendEigeninfo(eigeninfo, eigeninfo_param)
end
function logic_enter_game:EnterBattle(ip, port, key, name, packet_key, game_id, is_ob, ad_conf, waterType, waterUserID, sub_mode, mode_type, ugc_map_id, dynamiclevels_op, grome_info)
  log(bWriteLog and "logic_enter_game:EnterBattle")
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  if not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bConnectDS = Lobby_Main_City_Enter.bConnectDS
    log(bWriteLog and "logic_enter_game:EnterBattle bConnectDS = " .. tostring(bConnectDS))
    if bConnectDS then
      Lobby_Main_City_Enter.LeaveMainCity(true, false, true)
    end
  end
  if Client.IsDevelopment() then
    local LuaAPITimeTracer = RequireBlackList("blacklist.editor.runtime_check.LuaAPITimeTracer")
    if LuaAPITimeTracer then
      log(bWriteLog and "EnterBattle StartTracer")
      LuaAPITimeTracer.StartTracer()
    end
  end
  self.InGameShowingReEnter = false
  if self.InGameReEnterGameInfo == nil or #self.InGameReEnterGameInfo >= 6 and self.InGameReEnterGameInfo[6] ~= nil and self.InGameReEnterGameInfo[6] ~= game_id then
    self.InGameReEnterGameInfo = table.pack(ip, port, key, name, packet_key, game_id, is_ob, ad_conf, waterType, waterUserID, sub_mode, mode_type, ugc_map_id or 0, dynamiclevels_op, grome_info)
    log(bWriteLog and "UnrealNet.HandleNetworkException Save EnterGameInfo")
  end
  log_shipping_client("logic_enter_game:EnterBattle()")
  local logic_lobby_ping_report = require("client.slua.logic.match.logic_lobby_ping_report")
  logic_lobby_ping_report.SendHeartbeatReport()
  NetUtil.BBattleResultRecieved = false
  Client.UpdatePublishRegionForBattle()
  log(bWriteLog and "logic_enter_game:EnterBattle ----- ")
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine and ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  print(bWriteLog and "[logic_enter_game:EnterBattle] FriendlyBehaviorModule reset data start")
  local FriendlyBehaviorModule = require("GameLua.Mod.BaseMod.Common.Security.FriendlyBehavior")
  if FriendlyBehaviorModule and FriendlyBehaviorModule.ResetCacheDataFromPlayerState then
    FriendlyBehaviorModule.ResetCacheDataFromPlayerState()
    print(bWriteLog and "[logic_enter_game:EnterBattle] FriendlyBehaviorModule reset data finish")
  end
  NetUtil.MountPakOfMode(sub_mode, ugc_map_id)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem and MatchModeMgrSystem.GetMapKeyBySubMode(sub_mode, ugc_map_id) ~= nil then
    self.ModNameEnterBattle = MatchModeMgrSystem.GetMapKeyBySubMode(sub_mode, ugc_map_id)
    Client.SyncLoadPackageUpdateCurrentWorldName(self.ModNameEnterBattle)
    log(bWriteLog and "self.ModNameEnterBattle " .. self.ModNameEnterBattle)
  end
  self.cache_  local LogicGRomeLink = require("client.slua.logic.gromelink.logic_grome_link")
  local extra_info = {
    ip = ip,
    port = port,
    sub_mode = sub_mode,
    mode = mode_type
  }
  LogicGRomeLink:EnterBattle(game_id, grome_info, extra_info)
  local URL = string.format("%s:%u?PlayerName=%s?PlayerKey=%u?ModeId=%u?MainModeId=%u?DynamicLevelsOp=%s", ip, port, name, key, sub_mode, mode_type, dynamiclevels_op)
  Client.EnterBattle(GameFrontendHUD, URL, ip, port, key, packet_key, game_id, is_ob or false, ad_conf, waterType or 0, waterUserID or 0, sub_mode or 0, mode_type or 0)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.GetGameFrontendHUD() ~= nil then
    UIUtil.GetGameFrontendHUD():SetClientEnterBattleStage("LobbyMsg_EnterGame")
    UIUtil.GetGameFrontendHUD():SetGameSubMode(tostring(sub_mode))
    if game_id ~= nil then
      NetUtil.SetEnterBattleGameID(tostring(game_id))
    end
  end
  local TimeUtil = require("client.common.time_util")
  NetUtil.EnterBattleTime = TimeUtil.OSTime()
  log(bWriteLog and "set NetUtil.EnterBattleTime to " .. tostring(NetUtil.EnterBattleTime))
  NetUtil.dsTimeOutTipsUIShowing = false
  FuncUtil.UE4ExecuteConsoleCommand("ObjectPoolEnable 1")
  if not LobbySystem.isWaittingEnterBattle then
    LobbySystem.SetWaitingBattleFlag(true)
    if NetUtil then
      NetUtil.StartCheckEnterBattle(sub_mode)
      if NetUtil.EnterBattleStageDelegate ~= nil and UIUtil.GetGameFrontendHUD() ~= nil then
        local curStage = UIUtil.GetGameFrontendHUD():GetClientEnterBattleStage()
        if curStage then
          NetUtil.OnEnterBattleStageDelegate(curStage)
          log(bWriteLog and "logic_enter_game:EnterBattle ReEnterGamecurStage " .. curStage)
        end
      end
    end
  end
end
function logic_enter_game:EnterBattleStandAlone(sub_mod, map_id, AdditionalURLSuffixes)
  log(bWriteLog and "logic_enter_game:EnterBattleStandAlone")
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_enter_game:EnterBattleStandAlone isInMainCity = " .. tostring(isInMainCity))
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if isInMainCity then
    Lobby_Main_City_Enter.bEnterGameFromMainCity = true
  end
  local bConnectDS = Lobby_Main_City_Enter.bConnectDS
  log(bWriteLog and "logic_enter_game:EnterBattleStandAlone bConnectDS = " .. tostring(bConnectDS))
  if bConnectDS then
    Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
  end
  self.str_sub_mode_id = "0"
  self:SetSubMode(0)
  local curStatus = GameStatus.GetGameStatus()
  if GameStatus.IsInFightingStatus() or curStatus == GameStatus.Login then
    self.IsPendingEnter = true
    self.IsPendingEnterStandAlone = true
    self.PendingEnterInfo = table.pack(sub_mod, map_id, AdditionalURLSuffixes)
    log(bWriteLog and "Is fighting, enter loading to reset")
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
      if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
        uWonderfulPlayback:StopPlay()
        log(bWriteLog and "Is fighting, Stop wonderful play")
      end
    end
    Client.EnterLoading(GameFrontendHUD)
    xpcall(function()
      if GameStatus.IsInFightingStatus() and SubsystemMgr then
        local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
        if ClientHawkEyePatrolSubsystem and ClientHawkEyePatrolSubsystem.ClearNextPatrolOvertimeTimer then
          ClientHawkEyePatrolSubsystem:ClearNextPatrolOvertimeTimer()
        end
      end
    end, require("common.utility").ErrorMessageHandler)
    return
  end
  self.IsPendingEnter = false
  self.IsPendingEnterStandAlone = false
  local game_frontend_hud = require("game_frontend_hud")
  local hud = game_frontend_hud.GetInstance()
  hud:CreateBattleUtils()
  require("GameLua.Mod.BaseMod.Client.BattleHandler")
  local params = {}
  params.bTest = false
  params.PlayerUID = DataMgr.roleData.uid
  params.PlayerName = DataMgr.roleData.nickName
  params.PlayerType = "Normal"
  params.PlayerGender = AvatarData.GetGameGender() - 1
  params.TeamID = 1
  params.UsePlayerInfoTeamID = true
  params.ItemList = {}
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local tRoleWear = AvatarData.GetRoleWear()
  for _, v in pairs(tRoleWear) do
    local data = WardrobeData:GetHallDepotItemDataByInsID(v)
    if data then
      local item = {
        ItemTableID = data.resID,
        AdditionIntData = {
          data.color or 0,
          data.pattern or 0
        },
        Count = 1
      }
      table.insert(params.ItemList, item)
    end
  end
  local head = {}
  head.ItemTableID = AvatarData.GetHeadID()
  head.AdditionIntData = {0, 0}
  head.Count = 1
  table.insert(params.ItemList, head)
  local hair = {}
  hair.ItemTableID = AvatarData.GetHairID()
  hair.AdditionIntData = {0, 0}
  hair.Count = 1
  table.insert(params.ItemList, hair)
  params.EquipmentAvatar = {}
  local bag_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[504])
  if bag_data then
    params.EquipmentAvatar.BagAvatar = bag_data.resID
  end
  local helmet_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[505])
  if helmet_data then
    params.EquipmentAvatar.HelmetAvatar = helmet_data.resID
  end
  local armor_data = WardrobeData:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[506])
  if armor_data then
    params.EquipmentAvatar.ArmorAvatar = armor_data.resID
  end
  params.ExpressionItemList = {}
  for k, v in ipairs(DataMgr.MotionSlotList) do
    local data = WardrobeData:GetHallDepotItemDataByInsID(v)
    if data then
      table.insert(params.ExpressionItemList, {
        ItemTableID = data.resID,
        Count = 1
      })
    end
  end
  log_tree("[edward] logic_enter_game:EnterBattleStandAlone PARAMS = ", params)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.SetInGameModeID(sub_mod)
  local game_params = {}
  game_params.GameID = 10086
  game_params.GameModeID = sub_mod
  game_params.GameMapID = map_id or CDataTable.GetTableData("BTMode", game_params.GameModeID).MapID
  game_params.bEnableClimbing = true
  game_params.bUsedSimulation = true
  game_params.WeatherID = 1
  game_params.WeatherName = "Implosion_WeatherLevel_Dynamic"
  log_tree("[edward] logic_enter_game:EnterBattleStandAlone GAME_PARAMS = ", game_params)
  BattleHandler.SyncGameInfo(game_params)
  local map_path = CDataTable.GetTableData("Map", game_params.GameMapID).MapPath or ""
  local _player_key = BattleHandler.SyncNewBattlePlayer(params)
  NetUtil.EnterBattleStandAlone(slua_GameFrontendHUD, map_path, _player_key, DataMgr.roleData.nickName, sub_mod, "", AdditionalURLSuffixes)
end
function logic_enter_game:on_enter_game(ip, port, key, packet_key, game_id, sub_mode, ad_conf, dynamic_disabled_levels, eigeninfo, land_id, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, ext_params, grome_info, collect_hall_info)
  log(bWriteLog and string.format("logic_enter_game:on_enter_game ip=%s, port=%s, key=%s, game_id=%s, sub_mode=%s, dynamic_disabled_levels=%s, land_id=%s, waterType=%s, socialland_info=%s, svr_pub_key=%s, svr_packet_key_md5=%s,waterUserID=%s, ext_info=%s, mode_type=%s,antsvoice_url=%s, team_antsvoice_url=%s, custom_room_id=%s", ip, port, key, game_id, sub_mode, dynamic_disabled_levels, land_id, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id))
  log_tree("logic_enter_game:on_enter_game dynamic_disabled_levels", dynamic_disabled_levels)
  log_tree("manor_data = ", manor_data)
  log_tree("grome_info = ", grome_info)
  log_tree("collect_hall_info = ", collect_hall_info)
  local LogicGRomeLink = require("client.slua.logic.gromelink.logic_grome_link")
  LogicGRomeLink:SetIsReEnter(false)
  if ext_params then
    log_tree("logic_enter_game:on_enter_game ext_params = ", ext_params)
    for k, v in pairs(ext_params or {}) do
      if k == "asr_url" and v ~= nil then
        log(bWriteLog and "logic_enter_game:on_enter_game asr_url = " .. tostring(v))
        local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
        uAntsVoiceInterface:SetServerUrl(1, tostring(v))
        break
      end
    end
  end
  local logic_main_city_reconnect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_reconnect)
  logic_main_city_reconnect.EnterGameTimeoutQueryID = 0
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  local bIsMainCitySubMode = Lobby_Main_City.IsMainCitySubMode(sub_mode)
  log(bWriteLog and "logic_enter_game:on_enter_game bIsMainCitySubMode = " .. tostring(bIsMainCitySubMode))
  if bIsMainCitySubMode then
    local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
    log(bWriteLog and "logic_enter_game:on_enter_game IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
    if not IsInLobbyOrMainCity then
      log(bWriteLog and "logic_enter_game:on_enter_game return")
      return
    end
    if Lobby_Main_City_Enter.bWaitingFollowEnterMainCity then
      log(bWriteLog and "logic_enter_game:on_enter_game hook game info")
      Lobby_Main_City_Enter.bReceiveFollowEnterMainCity = true
      Lobby_Main_City_Enter.pendingEnterInfo = table.pack(ip, port, key, packet_key, game_id, sub_mode, ad_conf, dynamic_disabled_levels, eigeninfo, land_id or 0, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, ext_params, grome_info, collect_hall_info)
      return
    end
    local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
    if MainCityConfig.bOptimization then
      local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
      Lobby_Main_City.PreLoadChar()
    end
  end
  xpcall(function()
    local logic_report_enter_game = require("client.slua.logic.mode_selection.logic_report_enter_game")
    logic_report_enter_game.ReportWhenEnterGame(sub_mode)
  end, require("common.utility").ErrorMessageHandler)
  self:EnterGameCommon(sub_mode, ad_conf, land_id, game_id, eigeninfo, 3, custom_room_id)
  local UIUtil = require("client.common.ui_util")
  if UIUtil ~= nil and UIUtil.GetGameFrontendHUD() ~= nil then
    UIUtil.GetGameFrontendHUD():SetClientEnterBattleStage("LobbyMsg_ReceivedEnterGame")
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local ugc_map_id
  local excludeMapKey = {}
  if ext_info and ext_info.ugc_map_id then
    ugc_map_id = ext_info.ugc_map_id
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local modInfo = LogicUGCMatch:GetUgcMatchModInfo()
    if modInfo then
      local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
      local idList = LogicUGCResManager:GetCacheDepends(modInfo)
      excludeMapKey = LogicUGCResManager:GetExcludeMapKey(modInfo, idList)
    end
  end
  log(bWriteLog and "Client.EnableIosStuckWork(GameFrontendHUD, false)")
  Client.EnableIosStuckWork(GameFrontendHUD, false)
  local curStatus = GameStatus.GetGameStatus()
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  local bNotMainCity = not Lobby_Main_City.IsMainCitySubMode(sub_mode)
  log(bWriteLog and string.format("logic_enter_game:on_enter_game curStatus=%s, bNotMainCity=%s, GameStatus.IsInFightingStatus=%s", curStatus, bNotMainCity, GameStatus.IsInFightingStatus()))
  if bNotMainCity and (GameStatus.IsInFightingStatus() or curStatus == GameStatus.Login) then
    local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
    if not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
      local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
      local IsInMainCity = GameStatus.IsInMainCity()
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      local IsInXMission = LogicTxMissionMain.IsInXMission()
      log(bWriteLog and "logic_enter_game:on_enter_game IsInMainCity = " .. tostring(IsInMainCity) .. " IsInXMission = " .. tostring(IsInXMission))
      if IsInMainCity and not IsInXMission then
        Lobby_Main_City_Enter.bEnterGameFromMainCity = true
      end
      local bConnectDS = Lobby_Main_City_Enter.bConnectDS
      log(bWriteLog and "logic_enter_game:on_enter_game bConnectDS = " .. tostring(bConnectDS))
      if bConnectDS then
        Lobby_Main_City_Enter.LeaveMainCity(true, false, true)
      end
    end
    self.IsPendingEnter = true
    self.PendingEnterInfo = table.pack(ip, port, key, packet_key, game_id, sub_mode, ad_conf, dynamic_disabled_levels, eigeninfo, land_id or 0, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, ext_params, grome_info, collect_hall_info)
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      local recent_social_island = require("GameLua.Mod.SocialIsland.Client.RecentSocialisland")
      recent_social_island:SaveRecentIsland(socialland_info)
    end
    log(bWriteLog and "Is fighting, enter loading to reset")
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
      if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
        uWonderfulPlayback:StopPlay()
        log(bWriteLog and "Is fighting, Stop wonderful play")
      end
    end
    Client.EnterLoading(GameFrontendHUD)
    xpcall(function()
      if GameStatus.IsInFightingStatus() and SubsystemMgr then
        local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
        if ClientHawkEyePatrolSubsystem and ClientHawkEyePatrolSubsystem.ClearNextPatrolOvertimeTimer then
          ClientHawkEyePatrolSubsystem:ClearNextPatrolOvertimeTimer()
        end
      end
    end, require("common.utility").ErrorMessageHandler)
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local corruptedMaps = PufferMapManager:MountPakBySubMode(self.str_sub_mode_id, ugc_map_id, excludeMapKey)
  if corruptedMaps ~= "" then
    local _LoadingSystem = require("client.slua.logic.loading.logic_loading")
    _LoadingSystem.RefreshLoadPercent(1)
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    UGCPlayHallRoom:OnEnterGameFail()
    local home_macros = require("client.slua.logic.home.home_macros")
    local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
    if sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit or sub_mode == home_macros.Home_SubMode.Visit then
      local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
      ClientEntryHandler.send_giveup_enter_game()
    end
    return
  end
  self:SetSubMode(sub_mode)
  self.  self.  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, sub_mode)
  if svr_pub_key and svr_pub_key ~= "" and svr_pub_key ~= 0 and self.priKey ~= "" then
    local dh_ext_info = {}
    dh_ext_info.priKey = self.priKey
    dh_ext_info.pubKey = self.pubKey
    dh_ext_info.    dh_ext_info.before_    local svr_cli_key = Client.GetBattleKey(tostring(svr_pub_key), self.priKey)
    if svr_cli_key == "0" then
      log_error("error logic_enter_game:CheckPubKeysvr_cli_key == 0!")
    end
    dh_ext_info.    packet_key = NetUtil.DecXorForBattle(packet_key, svr_cli_key)
    dh_ext_info.after_    log(bWriteLog and "logic_enter_game:CheckPubKey priKey=" .. tostring(self.priKey) .. ", svr_cli_key=" .. tostring(svr_cli_key) .. ", packet_key=" .. tostring(packet_key))
    NetUtil.check_dh_packet_key(packet_key, svr_packet_key_md5, 1, dh_ext_info, self.bReportDSInfo)
  end
  self.IsPendingEnter = false
  LobbySystem.isWaitToEnterGame = false
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_MatchEnterGame)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchEnterGame)
  xpcall(function()
    gem_report_utils.ReissueSendCachedGEMReport()
  end, require("common.utility").ErrorMessageHandler)
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  golden_suit_module:SendTLogWhenEnterGame()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  Client.CrashLog(NetInterface, 4, "Battle", "Enter Battle match_id=" .. tostring(MatchModeMgrSystem.nSelectMatchID or false))
  Client.CrashLog(NetInterface, 4, "Battle", "Enter Battle game_id=" .. tostring(game_id) .. ", TPCount:" .. tostring(TeamUpNewSystem.GetTeamNum()) .. ", gmode=" .. tostring(sub_mode or false))
  local str = TeamAvatarManager.GetMainAvatarEquipmentsString()
  if nil ~= str and "" ~= str then
    Client.CrashLog(NetInterface, 4, "Battle", "Enter Battle " .. str)
  end
  BattleResult.IgnoreDSError = false
  MatchModeMgrSystem.SetInGameModeID(tonumber(self.str_sub_mode_id or 0))
  Client.AddCrashContextData(2501, string.format("80[%s]", self.str_sub_mode_id), false, 100)
  local DynamicLevelsOp = ""
  for _, Id in pairs(dynamic_disabled_levels or {}) do
    if DynamicLevelsOp == "" then
      DynamicLevelsOp = tostring(Id)
    else
      DynamicLevelsOp = string.format("%s|%s", DynamicLevelsOp, tostring(Id))
    end
  end
  log(bWriteLog and "logic_enter_game:on_enter_game DynamicLevelsOp=" .. DynamicLevelsOp)
  if sub_mode ~= nil then
    Client.TPerforPlatDataReport(GameFrontendHUD, 401, tostring(sub_mode))
  else
    Client.TPerforPlatDataReport(GameFrontendHUD, 401, "")
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if bNotMainCity then
    LoadingSystem.ShowLoading(false, nil, sub_mode, LoadingSystem.E_ShowLoadingSceneType.EnterGame, mode_type)
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local InGamePlayerName = LogicPeakGame:DoesHideName() and LogicPeakGame.peakgame_anchorName or DataMgr.roleData.nickName
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  if AccelSystem.IsEnableAccel() then
    AccelSystem.BeginRound(game_id)
    AccelSystem.AddNewArenaAddress("UDP", ip, port, function()
      self:EnterBattle(ip, port, key, InGamePlayerName, packet_key, game_id, sub_mode, ad_conf, waterType, waterUserID, self.str_sub_mode_id, mode_type, ugc_map_id, DynamicLevelsOp, grome_info)
    end)
  else
    self:EnterBattle(ip, port, key, InGamePlayerName, packet_key, game_id, sub_mode, ad_conf, waterType, waterUserID, self.str_sub_mode_id, mode_type, ugc_map_id, DynamicLevelsOp, grome_info)
  end
  LobbySystem.ResetMatchInfo()
  local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  tournamentsManager.settlement_table = {}
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_enter_game:on_enter_game Is MC Mode")
    logic_chat_voice:SetAntsVoiceServerInfo(antsvoice_url)
    local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
    logic_main_city_voice:JoinMainCityVoiceRoom(true)
    logic_main_city_voice:SetTeamAntsVoiceUrl(team_antsvoice_url)
  elseif MatchModeMgrSystem.IsSocialIslandMode(true) then
    log(bWriteLog and "logic_enter_game:on_enter_game IsSocialIslandMode")
    local recent_social_island = require("GameLua.Mod.SocialIsland.Client.RecentSocialisland")
    recent_social_island:SaveRecentIsland(socialland_info)
    logic_chat_voice:JoinLobbyVoiceRoom()
    logic_chat_voice:SetAntsVoiceServerInfo(antsvoice_url)
    logic_chat_voice:JoinLbsVoiceRoom(game_id)
  else
    log(bWriteLog and "logic_enter_game:on_enter_game new enter room rule")
    local home_macros = require("client.slua.logic.home.home_macros")
    local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    if LogicUGC:IsUGCGameMod() then
      logic_chat_voice:SetUGCAntsVoiceUrl(antsvoice_url)
      local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
      logic_chat_voice_doctor:AddJoinTeamRoomStep(704)
      logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
    elseif sub_mode == home_macros.Home_SubMode.Visit then
      log(bWriteLog and "logic_enter_game:on_enter_game PHomeMode")
    elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
      log(bWriteLog and "logic_enter_game:on_enter_game PlanCHMode")
    else
      if team_antsvoice_url ~= nil then
        if self.antsVoiceInfo then
          local voiceTeamID = self.antsVoiceInfo.camp_id ~= nil and self.antsVoiceInfo.camp_id or self.antsVoiceInfo.team_id
          logic_chat_voice:SetBattleAntsVoiceRoomParam(voiceTeamID, game_id, team_antsvoice_url)
          self.antsVoiceInfo = nil
          local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
          logic_chat_voice_doctor:AddJoinTeamRoomStep(701)
          logic_chat_voice_doctor:AddJoinTeamRoomStep(voiceTeamID or 705)
        else
          local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
          logic_chat_voice_doctor:AddJoinTeamRoomStep(702)
        end
      else
        local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
        logic_chat_voice_doctor:AddJoinTeamRoomStep(703)
      end
      logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
    end
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice and logic_room_match_voice.QuitMatchRoomWithJudgement then
    logic_room_match_voice:QuitMatchRoomWithJudgement()
  end
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  log(bWriteLog and "logic_enter_game:on_enter_game" .. tostring(enter_guide.executeFightGuide) .. tostring(enter_guide.Manual_EnterFightGuide))
  if enter_guide.executeFightGuide or enter_guide.Manual_EnterFightGuide then
    enter_guide.executeFightGuide = false
    enter_guide.Manual_EnterFightGuide = false
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.InGameRecordGrowthGuideInfo(-2)
    local bJaguar = Client.IsJaguar()
    if bJaguar then
      local newbie_download_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.newbie_download_module)
      newbie_download_module:SetNewbieGuideGameFlag(true)
      newbie_download_module:JaguarNewbieDownload()
    end
  else
    local NewerGuideHandler = require("client.network.Protocol.NewerGuideHandler")
    NewerGuideHandler.send_sync_newer_guide_data_req(1, 1, nil)
    LogicNewbie.newbieTotalGameCnt = LogicNewbie.newbieTotalGameCnt + 1
  end
  Client.CrashLog(NetInterface, 4, "Battle", "Enter Battle Finished")
  local GuideFlowEventMap = require("client.slua.logic.GuideFlow.Event.GuideFlowEventMap")
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  GuideFlowEventMap.PostEvent(GuideFlowEvent.EnterGame)
  if ext_info and ext_info.concert_switch then
    local logic_planz_switches = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_planz_switches)
    logic_planz_switches:InitSwitches(ext_info.concert_switch)
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    logic_replay.DoAfterPlayFunc()
  end
  LobbySystem.isCanDeleteOp = false
end
function logic_enter_game:on_re_enter_game(ip, port, key, packet_key, game_id, res, team_info, antsvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf, dynamic_disabled_levels, team_id, camp_id, sub_mode, eigeninfo, feedback_flag, land_id, waterType, svr_pub_key, svr_packet_key_md5, socialland_info, waterUserID, ext_info, custom_room_id, mode_type, team_antsvoice_url, manor_data, additional_data, grome_info, collect_hall_info)
  log(bWriteLog and string.format("logic_enter_game:on_re_enter_game ip=%s, port=%s, key=%s, packet_key=%s, game_id=%s, res=%s, team_info=%s, antsvoice_url=%s, is_watch=%s, start_to_plane=%s, forced_exit_game_times=%s, dynamic_disabled_levels=%s, team_id=%s, camp_id=%s, sub_mode=%s, feedback_flag=%s, land_id=%s, waterType=%s, svr_pub_key=%s, svr_packet_key_md5=%s, socialland_info=%s, waterUserID=%s, ext_info=%s, custom_room_id=%s, mode_type=%s, team_antsvoice_url=%s", ip, port, key, packet_key, game_id, res, team_info, antsvoice_url, is_watch, start_to_plane, forced_exit_game_times, dynamic_disabled_levels, team_id, camp_id, sub_mode, feedback_flag, land_id, waterType, svr_pub_key, svr_packet_key_md5, socialland_info, waterUserID, ext_info, custom_room_id, mode_type, team_antsvoice_url))
  local LogicGRomeLink = require("client.slua.logic.gromelink.logic_grome_link")
  LogicGRomeLink:SetIsReEnter(true)
  waterType = waterType or 0
  if additional_data then
    log_tree("logic_enter_game:on_re_enter_game additional_data", additional_data)
    for k, v in pairs(additional_data or {}) do
      if k == "asr_url" and v ~= nil then
        log(bWriteLog and "logic_enter_game:on_re_enter_game asr_url = " .. tostring(v))
        local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
        uAntsVoiceInterface:SetServerUrl(1, tostring(v))
        break
      end
    end
  else
    print(bWriteLog and "logic_enter_game:on_re_enter_game no additional_data")
  end
  local old_sub_mode = self.sub_mode
  log(bWriteLog and "logic_enter_game:on_re_enter_game old_sub_mode = " .. tostring(old_sub_mode))
  self:SetSubMode(sub_mode)
  self.  log_tree("manor_data = ", manor_data)
  self.  log_tree("collect_hall_info = ", collect_hall_info)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.bHaveInitMapPaks then
    log_format("logic_enter_game:on_re_enter_game. mark pufferMapManager re enter game")
    PufferMapManager.bReEnterGame = true
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  logic_home_entry:proc_re_enter_game(manor_data)
  local LogicCollectionHallEntry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicCollectionHallEntry)
  LogicCollectionHallEntry:proc_re_enter_game(collect_hall_info)
  local old_  log(bWriteLog and "logic_enter_game:on_re_enter_game old_g_game_id = " .. tostring(old_g_game_id))
  self:EnterGameCommon(sub_mode, ad_conf, land_id, game_id, eigeninfo, 2, custom_room_id)
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  self.PendingReEnterInfo = table.pack(ip, port, key, packet_key, game_id, res, team_info, antsvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf, dynamic_disabled_levels, team_id, camp_id, sub_mode, eigeninfo, feedback_flag, land_id or 0, waterType, svr_pub_key, svr_packet_key_md5, socialland_info, waterUserID, ext_info, custom_room_id or 0, mode_type, team_antsvoice_url, manor_data or {}, additional_data or {}, grome_info, collect_hall_info or {})
  local ugc_map_id
  if type(ext_info) == "table" and ext_info.ugc_map_id then
    ugc_map_id = ext_info.ugc_map_id
  end
  local ShowMsgBoxFunc
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
    ShowMsgBoxFunc = CommonMsgBoxMgr.ShowTPlan
  else
    ShowMsgBoxFunc = CommonMsgBoxMgr.Show
  end
  local extraData = {
    androidCallback = function()
      self:RemoveReEnterGameLoadingCheckTimer()
      return true
    end
  }
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local InGamePlayerName = LogicPeakGame:DoesHideName() and LogicPeakGame.peakgame_anchorName or DataMgr.roleData.nickName
  ResetResultMonitor()
  NetUtil.StopCheckDSActive()
  local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD)
  log(bWriteLog and "logic_enter_game:on_re_enter_game CurDSSeverState: " .. dsState .. ", gameStatus: " .. GameStatus.GetGameStatus())
  if svr_pub_key and svr_pub_key ~= "" and svr_pub_key ~= 0 and self.priKey ~= "" then
    local dh_ext_info = {}
    dh_ext_info.priKey = self.priKey
    dh_ext_info.pubKey = self.pubKey
    dh_ext_info.    dh_ext_info.before_    local svr_cli_key = Client.GetBattleKey(tostring(svr_pub_key), self.priKey)
    if svr_cli_key == "0" then
      log_error("error logic_enter_game:CheckPubKeysvr_cli_key == 0!")
    end
    dh_ext_info.    packet_key = NetUtil.DecXorForBattle(packet_key, svr_cli_key)
    dh_ext_info.after_    log(bWriteLog and "logic_enter_game:CheckPubKey priKey=" .. tostring(self.priKey) .. ", svr_cli_key=" .. tostring(svr_cli_key) .. ", packet_key=" .. tostring(packet_key))
    NetUtil.check_dh_packet_key(packet_key, svr_packet_key_md5, 2, dh_ext_info, self.bReportDSInfo)
  end
  local DynamicLevelsOp = ""
  for _, Id in pairs(dynamic_disabled_levels or {}) do
    if DynamicLevelsOp == "" then
      DynamicLevelsOp = tostring(Id)
    else
      DynamicLevelsOp = string.format("%s|%s", DynamicLevelsOp, tostring(Id))
    end
  end
  log(bWriteLog and "logic_enter_game:on_re_enter_game DynamicLevelsOp=", DynamicLevelsOp)
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  local home_macros = require("client.slua.logic.home.home_macros")
  local Logic_PlanCHMacros = require("client.slua.logic.CollectionHall.Logic_PlanCHMacros")
  local strTile = LocUtil.GetLocalizeResStr(102012)
  local strMsg = ""
  if res ~= NetErrorCode_NONE then
    log(bWriteLog and "logic_enter_game:on_re_enter_game res:" .. tostring(res))
    strMsg = LocUtil.GetLocalizeResStr(77011)
    if additional_data and additional_data.has_sent_result and additional_data.has_sent_result ~= 0 then
      strMsg = LocUtil.GetLocalizeResStr(77010)
    end
    if res == "version_mismatch" then
      strMsg = LocUtil.GetLocalizeResStr(301114)
    elseif res == "device_not_allow" then
      local EmulatorSystem = require("client.logic.login.logic_emulator")
      if EmulatorSystem.IsX86Phone() then
        strMsg = LocUtil.GetLocalizeResStr(35008)
      else
        strMsg = LocUtil.GetLocalizeResStr(301120)
      end
    elseif res == "watch_game_over" then
      strMsg = LocUtil.GetLocalizeResStr(501117)
    elseif res == "watch_version_mismatch" then
      strMsg = LocUtil.GetLocalizeResStr(501128)
    elseif res == "game_over" then
      log(bWriteLog and "logic_enter_game:on_re_enter_game old_sub_mode = " .. tostring(old_sub_mode))
      if sub_mode == home_macros.Home_SubMode.Visit or old_sub_mode == home_macros.Home_SubMode.Visit then
        strMsg = LocUtil.GetLocalizeResStr(655421)
      elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit or old_sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
        strMsg = LocUtil.GetLocalizeResStr(880060019)
      end
    elseif res == "pky_type_switch_not_allow" then
      strMsg = LocUtil.GetLocalizeResStr(527011)
    end
    local Utility = require("common.utility")
    local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
    if slua.isValid(GameAutotest) and GameAutotest:IsUIAutoTest() then
      return
    end
    if IsWoWEditor then
      return
    end
    if Lobby_Main_City.IsMainCitySubMode(sub_mode) or Lobby_Main_City.IsMainCitySubMode(old_sub_mode) then
      log(bWriteLog and "logic_enter_game:on_re_enter_game maincity res=", res)
      self.PendingReEnterInfo = nil
      EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_REENTER_GAME_ERROR, res)
      return
    end
    ShowMsgBoxFunc(1, strTile, strMsg, function()
      self.PendingReEnterInfo = nil
      if GameStatus.IsInFightingStatus() then
        FuncUtil.ShowLoadingToLobby()
        Client.ReturnToLobby(GameFrontendHUD)
        Client.TPerforPlatDisconnectReport(GameFrontendHUD, 12)
      elseif LobbySystem.isWaittingEnterBattle then
        LobbySystem.SetWaitingBattleFlag(false)
        local LoadingSystem = require("client.slua.logic.loading.logic_loading")
        LoadingSystem.RefreshLoadPercent(1)
        Client.ReturnToLobby(GameFrontendHUD)
      end
      NewFaceSlapSystem:RemoveWaitingMainCity()
      NewFaceSlapSystem:ReleaseBlockSlap()
    end, function()
      self.PendingReEnterInfo = nil
      if is_watch then
        LogicLobbyWatching.leave_battle_watch()
      end
      NewFaceSlapSystem:RemoveWaitingMainCity()
      NewFaceSlapSystem:ReleaseBlockSlap()
    end, nil, nil, extraData)
    if GameStatus.IsInFightingStatus() and self.InGameShowingReEnter == true then
      self.InGameShowingReEnter = false
    end
    return
  end
  local logic_main_city_reconnect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_reconnect)
  if dsState == "Connecting" and logic_main_city_reconnect.EnterGameTimeoutQueryID == 0 then
    log(bWriteLog and "logic_enter_game:on_re_enter_game CurDSSeverState is Connecting  not need enter battle!! ")
    self.PendingReEnterInfo = nil
    return
  end
  logic_main_city_reconnect.EnterGameTimeoutQueryID = 0
  local bReEnterBattleFromMainCity = false
  if GameStatus.GetGameStatus() == GameStatus.Lobby then
    log(bWriteLog and "logic_enter_game:on_re_enter_game re enter other battle form IsIn2DLobby")
  elseif GameStatus.IsInLobbyOrMainCity() and not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
    log(bWriteLog and "logic_enter_game:on_re_enter_game re enter other battle form main city")
    bReEnterBattleFromMainCity = true
  elseif GameStatus.IsInFightingStatus() then
    local bNotReEnterBattle = true
    if Lobby_Main_City.IsMainCitySubMode(sub_mode) and Lobby_Main_City.IsMainCitySubMode(old_sub_mode) and old_g_game_id and old_g_game_id ~= game_id then
      log(bWriteLog and "logic_enter_game:on_re_enter_game game change")
      bNotReEnterBattle = false
    end
    if bNotReEnterBattle and (dsState == "Online" or dsState == "RecoverableLost" or self.InGameShowingReEnter == true) then
      DeathReplayLuaInterface:OnReEnterGame(ip, port, key, packet_key, sub_mode, game_id, ad_conf, waterType, waterUserID)
    else
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_REENTER_GAME)
      Client.AddCrashContextData(2501, string.format("81[%s]", tostring(sub_mode)), false, 100)
      log(bWriteLog and "logic_enter_game:on_re_enter_game NetUtil.EnterBattle 2 dsState:" .. dsState .. ", ip:" .. ip .. ", port:" .. port .. ", key:" .. key)
      self:EnterBattle(ip, port, key, InGamePlayerName, packet_key, g_game_id, false, ad_conf, waterType, waterUserID, sub_mode, mode_type, ugc_map_id, DynamicLevelsOp, grome_info)
      if Lobby_Main_City.IsMainCitySubMode(sub_mode) then
        local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
        logic_main_city_connect_state:SetConnectingState(true, false)
        local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
        logic_main_city_connect_state.bPendingReEnterGame = false
      end
      LobbySystem.ResetMatchInfo()
      local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
      local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
      if GameStatus.IsInMainCity() then
        log(bWriteLog and "logic_enter_game:on_re_enter_game Is MC Mode")
        local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
        logic_main_city_voice:JoinMainCityVoiceRoom(true)
      elseif MatchModeMgrSystem.IsSocialIslandMode(true) then
        logic_chat_voice:JoinLobbyVoiceRoom()
        logic_chat_voice:JoinLbsVoiceRoom(game_id)
      else
        if LogicUGC:IsUGCGameMod() then
          logic_chat_voice:SetUGCAntsVoiceUrl(antsvoice_url)
          logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
        elseif sub_mode == home_macros.Home_SubMode.Visit then
          log(bWriteLog and "logic_enter_game:on_re_enter_game PHomeMode 1")
        elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
          log(bWriteLog and "logic_enter_game:on_re_enter_game PlanCHMode 1")
        else
          local voiceTeamID = team_id
          if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableCampIdForVoiceRoomReEnterGame", false) then
            voiceTeamID = camp_id ~= nil and camp_id or team_id
          end
          logic_chat_voice:SetBattleAntsVoiceRoomParam(voiceTeamID, game_id, team_antsvoice_url)
          local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
          logic_chat_voice_doctor:AddJoinTeamRoomStep(800)
          logic_chat_voice_doctor:AddJoinTeamRoomStep(voiceTeamID or 801)
          logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
        end
        log(bWriteLog and "logic_enter_game:on_re_enter_game Fighting new enter room rule")
      end
    end
    self.PendingReEnterInfo = nil
    return
  end
  local home_macros = require("client.slua.logic.home.home_macros")
  local clickCancelCallback = function()
    log(bWriteLog and "ClientEntry -----  giveup_enter_game curStatus:" .. GameStatus.GetGameStatus() .. ", isWaittingEnterBattle:" .. tostring(LobbySystem.isWaittingEnterBattle))
    self:RemoveReEnterGameLoadingCheckTimer()
    self.PendingReEnterInfo = nil
    if is_watch then
      log(bWriteLog and "logic_enter_game:on_re_enter_game clickCancelCallback 2 is_watch:true")
      RoomSystem.leave_room_battle_watch()
    else
      log(bWriteLog and "logic_enter_game:on_re_enter_game clickCancelCallback 2 is_watch: false or nil")
    end
    LogicLobbyWatching.leave_battle_watch()
    local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
    ClientEntryHandler.send_giveup_enter_game()
    if GameStatus.IsInFightingStatus() then
      if GameStatus.IsInLobbyOrMainCity() then
        log(bWriteLog and "logic_enter_game:on_re_enter_game clickCancelCallback IsInLobbyOrMainCity")
        EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_CANCEL_RE_ENTER_BATTLE)
      else
        FuncUtil.ShowLoadingToLobby()
        Client.ReturnToLobby(GameFrontendHUD)
      end
      Client.TPerforPlatDisconnectReport(GameFrontendHUD, 13)
    elseif LobbySystem.isWaittingEnterBattle then
      LobbySystem.SetWaitingBattleFlag(false)
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.RefreshLoadPercent(1)
    end
    local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    tournamentsManager.TryQuitTournamentTeam()
    logic_home_entry:ClearMode()
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    NewFaceSlapSystem:RemoveWaitingMainCity()
    NewFaceSlapSystem:ReleaseBlockSlap()
  end
  local function clickOkCallback()
    self:RemoveReEnterGameLoadingCheckTimer()
    log(bWriteLog and "logic_enter_game:on_re_enter_game bReEnterBattleFromMainCity = " .. tostring(bReEnterBattleFromMainCity))
    if bReEnterBattleFromMainCity then
      bReEnterBattleFromMainCity = false
      self.PendingReEnterInfo = nil
      self:on_enter_game(ip, port, key, packet_key, game_id, sub_mode, ad_conf, dynamic_disabled_levels, eigeninfo, land_id, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, grome_info, collect_hall_info)
      return
    end
    if sub_mode == home_macros.Home_SubMode.Visit then
      local PlanPH_Download_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Download_Tools")
      local downloaded, downloadSize = PlanPH_Download_Tools.CheckDownloadReady("map_planph_3")
      log(bWriteLog and "logic_enter_game:on_re_enter_game clickOkCallback 2 is_visit:true", tostring(downloaded))
      if not downloaded then
        local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
        logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, function()
          ShowMsgBoxFunc(2, strTile, strMsg, clickOkCallback, clickCancelCallback)
        end)
        return
      end
    elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
      if not LogicCollectionHallEntry:CheckLowMemoryEntry() then
        return
      end
      local Logic_SC_DownloadTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_DownloadTools")
      if not Logic_SC_DownloadTools.CheckPlanCHIsDownloaded(collect_hall_info.collect_hall_owner_id, collect_hall_info.skin_id) then
        Logic_SC_DownloadTools.ShowPlanCHDownloadPopup(collect_hall_info.collect_hall_owner_id, clickOkCallback, collect_hall_info.skin_id)
        return
      end
    elseif Lobby_Main_City.IsMainCitySubMode(sub_mode) then
      local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
      if not Main_City_Download_Tool.IsMainCityMapDownloaded() then
        return
      end
    else
      local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
      local mapKey = LogicTxMissionDownload.GetMapKeyByModeID(sub_mode)
      log(bWriteLog and "clickOkCallback. sub_mode = " .. tostring(sub_mode))
      log(bWriteLog and "clickOkCallback. mapKey = " .. tostring(mapKey))
      if mapKey and not LogicTxMissionDownload.CheckMapStateReady(true, nil, mapKey, function()
        ShowMsgBoxFunc(2, strTile, strMsg, clickOkCallback, clickCancelCallback, nil, nil, extraData)
      end) then
        return
      end
    end
    log(bWriteLog and "logic_enter_game:on_re_enter_game 1 ip:" .. ip .. ", port:" .. port .. ", key:" .. key)
    self.PendingReEnterInfo = nil
    if not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.ShowLoading(false, nil, sub_mode, LoadingSystem.E_ShowLoadingSceneType.ReEnterGame)
    end
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.SetInGameModeID(sub_mode)
    Client.AddCrashContextData(2501, string.format("82[%s]", tostring(sub_mode)), false, 100)
    local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
    if AccelSystem.IsEnableAccel() then
      AccelSystem.BeginRound(g_game_id)
      AccelSystem.AddAccelAddress("UDP", ip, port, function()
        self:EnterBattle(ip, port, key, InGamePlayerName, packet_key, g_game_id, false, ad_conf, waterType, waterUserID, sub_mode, mode_type, ugc_map_id, DynamicLevelsOp, grome_info)
      end)
    else
      self:EnterBattle(ip, port, key, InGamePlayerName, packet_key, g_game_id, false, ad_conf, waterType, waterUserID, sub_mode, mode_type, ugc_map_id, DynamicLevelsOp, grome_info)
    end
    LobbySystem.ResetMatchInfo()
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    if GameStatus.IsInMainCity() then
      log(bWriteLog and "logic_enter_game:on_re_enter_game Is MC Mode")
      logic_chat_voice:SetAntsVoiceServerInfo(antsvoice_url)
      local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
      logic_main_city_voice:JoinMainCityVoiceRoom(true)
    elseif MatchModeMgrSystem.IsSocialIslandMode(true) then
      logic_chat_voice:JoinLobbyVoiceRoom()
      logic_chat_voice:JoinLbsVoiceRoom(game_id)
    else
      if LogicUGC:IsUGCGameMod() then
        logic_chat_voice:SetUGCAntsVoiceUrl(antsvoice_url)
        logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
      elseif sub_mode == home_macros.Home_SubMode.Visit then
        log(bWriteLog and "logic_enter_game:on_re_enter_game PHomeMode 2")
      elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
        log(bWriteLog and "logic_enter_game:on_re_enter_game PlanCHMode 2")
      else
        local voiceTeamID = team_id
        if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableCampIdForVoiceRoomReEnterGame", false) then
          voiceTeamID = camp_id ~= nil and camp_id or team_id
        end
        logic_chat_voice:SetBattleAntsVoiceRoomParam(voiceTeamID, game_id, team_antsvoice_url)
        local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
        logic_chat_voice_doctor:AddJoinTeamRoomStep(810)
        logic_chat_voice_doctor:AddJoinTeamRoomStep(voiceTeamID or 811)
        logic_chat_voice:SetGlobalAntsVoiceRoomParam(game_id, antsvoice_url)
      end
      log(bWriteLog and "logic_enter_game:on_re_enter_game new enter room rule")
    end
  end
  if Lobby_Main_City.IsMainCitySubMode(sub_mode) then
    log(bWriteLog and "logic_enter_game:on_re_enter_game reconnect to maincity")
    if self.enterBattleTimer then
      self:RemoveTimer(self.enterBattleTimer)
      self.enterBattleTimer = nil
    end
    local timeoutCount = 600
    local currCount = 0
    self.enterBattleTimer = self:AddTimerLoop(0, function()
      local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
      if ui or currCount >= timeoutCount then
        if self.enterBattleTimer then
          self:RemoveTimer(self.enterBattleTimer)
          self.enterBattleTimer = nil
        end
        local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
        local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
        logic_main_city_enter.enterMainCityMode = main_city_enter_config.EMainCityEnterMode.ReconnectToMainCity
        local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
        logic_main_city_connect_state:SetConnectingState(true, false)
        local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
        local bSuccess = Lobby_Main_City_Enter.EnterMainCity(true, clickOkCallback)
        log(bWriteLog and "logic_enter_game:on_re_enter_game reconnect to maincity bSuccess = " .. tostring(bSuccess) .. " bReEnterBattleFromMainCity = " .. tostring(bReEnterBattleFromMainCity))
        if not bSuccess then
          self.PendingReEnterInfo = nil
        end
        local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
        logic_main_city_connect_state.bPendingReEnterGame = false
      end
      currCount = currCount + 1
    end, TIMER_INFINITE, 0.1)
    return
  end
  if is_watch then
    strMsg = LocUtil.GetLocalizeResStr(501129)
  else
    local escapeTipChangeNum = DataMgr.GetSystemConfig("EscapeTipChangeNum") or 0
    if forced_exit_game_times ~= nil then
      LobbySystem.forcedExitGameTimes = tonumber(forced_exit_game_times)
      log(bWriteLog and "logic_enter_game:on_re_enter_game forced_exit_game_times:" .. forced_exit_game_times)
    end
    if start_to_plane == nil then
      start_to_plane = 1
    end
    if sub_mode == home_macros.Home_SubMode.Visit then
      strMsg = LocUtil.GetLocalizeResStr(655377)
    elseif sub_mode == Logic_PlanCHMacros.CollectionHall_SubMode.Visit then
      strMsg = LocUtil.GetLocalizeResStr(880060020)
    elseif tonumber(start_to_plane) == 0 and LobbySystem.forcedExitGameTimes > tonumber(escapeTipChangeNum) then
      strMsg = LocUtil.GetLocalizeResStr(103018)
    else
      strMsg = LocUtil.GetLocalizeResStr(103016)
    end
  end
  if IsWoWEditor then
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    if sub_mode ~= UGCMacros.EDIT_SUB_MODE then
      clickCancelCallback()
      return
    end
  end
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) and GameAutotest:IsUIAutoTest() then
    clickCancelCallback()
    return
  end
  local isUGCNewbie = false
  if ext_info and type(ext_info) == "table" and ext_info.ugc_tutorial_id then
    print(bWriteLog and "ext_info.ugc_tutorial_id")
    log_tree("ext_info", ext_info)
    isUGCNewbie = 0 < ext_info.ugc_tutorial_id
  end
  if NetUtil.IsGrowthGuideSubMode(sub_mode) or isUGCNewbie then
    print(bWriteLog and "UGC NewbieGuide Cancel reconnecting")
    clickCancelCallback()
  else
    ShowMsgBoxFunc(2, strTile, strMsg, clickOkCallback, clickCancelCallback, nil, nil, extraData)
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    local firstCheckLoading = LoadingSystem.IsShowing()
    log(bWriteLog and "logic_enter_game:on_re_enter_game. firstCheckLoading = " .. tostring(firstCheckLoading))
    if firstCheckLoading then
      self:RemoveReEnterGameLoadingCheckTimer()
      log(bWriteLog and "logic_enter_game:on_re_enter_game. add timer")
      self.ReEnterGameLoadingCheckTimer = self:AddTimerOnce(60, function()
        self.ReEnterGameLoadingCheckTimer = nil
        local isShowLoading = LoadingSystem.IsShowing()
        log(bWriteLog and "logic_enter_game:on_re_enter_game. isShowLoading = " .. tostring(isShowLoading))
        local needCheck = isShowLoading and not GameStatus.IsInMainCity()
        if needCheck and clickOkCallback then
          clickOkCallback()
        end
      end)
    end
  end
end
function logic_enter_game:RemoveReEnterGameLoadingCheckTimer()
  if self.ReEnterGameLoadingCheckTimer then
    printf("logic_enter_game:RemoveReEnterGameLoadingCheckTimer.")
    self:RemoveTimer(self.ReEnterGameLoadingCheckTimer)
    self.ReEnterGameLoadingCheckTimer = nil
  end
end
function logic_enter_game:on_get_game_info_rsp(game_info)
  log(bWriteLog and "logic_enter_game:on_get_game_info_rsp")
  self.  self.bGetGameInfo = true
  local logic_main_city_music = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_music)
  logic_main_city_music:CheckEnterMainCity(game_info)
  local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
  logic_main_city_connect_state:OnReceiveGameInfo(game_info)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_enter_game)
local logic_main_city_enter = {}
local MainCity_GamePlay_Tools = require("GameLua.Mod.MainCity.Tools.MainCity_GamePlay_Tools")
function logic_main_city_enter:DefineAndResetData()
  self.enterMainCityMode = 0
  self.gm_enter_standalone_maincity = false
  self.gm_enter_maincity_force_play_sequence = false
  self.curMainCityWeatherID = nil
  self.bCurMainCityWeatherChanged = false
end
function logic_main_city_enter:RegistEvents()
  log(bWriteLog and "logic_main_city_enter:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_FINISH, self.OnLoadingPreFinish, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_PENDING_SWITCH, self.OnMainCityPendingSwitch, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MAIN_CITY_ENTER, self.OnJumpMainCity, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_TELEPORT_TO_MAIN_CITY_DANCE_AREA, self.OnJumpMainCityDanceArea, self)
end
function logic_main_city_enter:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus self.enterMainCityMode = " .. tostring(self.enterMainCityMode))
  self:SetCurrentMainCityWeatherID(nil)
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local IsInXMission = LogicTxMissionMain.IsInXMission()
    log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus IsInXMission = " .. tostring(IsInXMission))
    if IsInXMission then
      log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus return IsInXMission")
      return
    end
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bEnterGameFromMainCity = Lobby_Main_City_Enter.bEnterGameFromMainCity
    log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus bEnterGameFromMainCity = " .. tostring(bEnterGameFromMainCity))
    if bEnterGameFromMainCity then
      Lobby_Main_City_Enter.bEnterGameFromMainCity = false
      self:SetEnterMainCityMode(main_city_enter_config.EMainCityEnterMode.FightingToMainCity)
      return
    end
    local bIgnoreAutoEnterMainCity = Lobby_Main_City_Enter.bIgnoreAutoEnterMainCity
    log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus bIgnoreAutoEnterMainCity = " .. tostring(bIgnoreAutoEnterMainCity))
    if bIgnoreAutoEnterMainCity then
      Lobby_Main_City_Enter.bIgnoreAutoEnterMainCity = false
      return
    end
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    local switch = main_city_process_util.GetMainCityEnterSwitch()
    log(bWriteLog and "logic_main_city_enter:OnPostSwitchGameStatus switch = " .. tostring(switch))
    if switch then
      self:SetEnterMainCityMode(main_city_enter_config.EMainCityEnterMode.FightingToMainCity)
    end
  elseif preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:SetLoginToMainCityTimer()
  elseif nextState == GameStatus.Login then
    self:DefineAndResetData()
  end
end
function logic_main_city_enter:SetLoginToMainCityTimer()
  log(bWriteLog and "logic_main_city_enter:SetLoginToMainCityTimer")
  self:ClearLoginToMainCityTimer()
  self.loginToMainCityTimer = self:AddTimerLoop(0, function()
    if self.enterMainCityMode == 0 then
      local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
      local bGetGameInfo = logic_enter_game.bGetGameInfo
      log(bWriteLog and "logic_main_city_enter:SetLoginToMainCityTimer bGetGameInfo = " .. tostring(bGetGameInfo))
      if not bGetGameInfo then
        return
      end
      local pendingEnterGame = false
      local game_info = logic_enter_game.game_info
      log_tree(bWriteLog and "logic_main_city_enter:SetLoginToMainCityTimer game_info = ", game_info)
      if game_info then
        if game_info.sub_mode_group and game_info.sub_mode_group ~= 0 then
          pendingEnterGame = true
        end
        if game_info.sub_mode and game_info.sub_mode ~= 0 then
          pendingEnterGame = true
        end
        if game_info.tplan_reconnect then
          pendingEnterGame = true
        end
      end
      logic_enter_game.game_info = nil
      logic_enter_game.bGetGameInfo = false
      self:ClearLoginToMainCityTimer()
      if pendingEnterGame then
        return
      end
      local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
      local switch = main_city_process_util.GetMainCityEnterSwitch()
      log(bWriteLog and "logic_main_city_enter:SetLoginToMainCityTimer switch = " .. tostring(switch))
      if switch then
        local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
        self:SetEnterMainCityMode(main_city_enter_config.EMainCityEnterMode.LoginToMainCity)
      end
    end
  end, 50, 0.2)
end
function logic_main_city_enter:ClearLoginToMainCityTimer()
  log(bWriteLog and "logic_main_city_enter:ClearLoginToMainCityTimer")
  if self.loginToMainCityTimer then
    self:RemoveTimer(self.loginToMainCityTimer)
    self.loginToMainCityTimer = nil
  end
end
function logic_main_city_enter:OnLoadingPreFinish()
  log(bWriteLog and "logic_main_city_enter:OnLoadingPreFinish self.enterMainCityMode = " .. tostring(self.enterMainCityMode))
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  if self.enterMainCityMode == main_city_enter_config.EMainCityEnterMode.ReconnectToMainCity then
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  log(bWriteLog and "logic_main_city_enter:OnLoadingPreFinish bEnterMainCityLoading = " .. tostring(Lobby_Main_City_Enter.bEnterMainCityLoading))
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    self:SetEnterMainCityMode(0)
    return
  end
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_main_city_enter:OnLoadingPreFinish isInMainCity = " .. tostring(isInMainCity))
  if isInMainCity then
    self:SetEnterMainCityMode(0)
    return
  end
  if self.enterMainCityMode ~= 0 then
    local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
    logic_main_city_enter_report.SetReportData("NewEnterMainCity", "DefaultEnterMC", "DefaultEnterMC")
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    Lobby_Main_City_Enter.EnterMainCity()
    return
  end
  local isIn2DLobby = GameStatus.IsIn2DLobby()
  log(bWriteLog and "logic_main_city_enter:OnLoadingPreFinish isIn2DLobby = " .. tostring(isIn2DLobby))
  if not isIn2DLobby then
    return
  end
  local logic_ugc_hall_mod = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall_mod)
  local bReEnterUGCHall = logic_ugc_hall_mod:GetIsReEnterUGCHall()
  log(bWriteLog and "logic_main_city_enter:OnLoadingPreFinish bReEnterUGCHall = " .. tostring(bReEnterUGCHall))
  if bReEnterUGCHall then
    logic_ugc_hall_mod:SetIsReEnterUGCHall(false)
    local logic_lobby_main_page_jump = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_main_page_jump)
    logic_lobby_main_page_jump:JumpToPage(ENUM_LobbyPageType.Right, nil, {bUGC = true})
  end
end
function logic_main_city_enter:OnMainCityPendingSwitch()
  log(bWriteLog and "logic_main_city_enter:OnMainCityPendingSwitch")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local Character = GameplayData.GetPlayerCharacter()
  local MCActionSubsystem = SubsystemMgr:Get("MCActionSubsystem")
  if MCActionSubsystem then
    if Game:IsValid(Character) then
      if Character.SetChangeDSStatus then
        log(bWriteLog and "logic_main_city_enter:OnMainCityPendingSwitch SetChangeDSStatus=1")
        Character:SetChangeDSStatus(true)
      end
      local uCarryBackComp = Character:GetCarryBackComp()
      if Game:IsValid(uCarryBackComp) then
        uCarryBackComp:ClearData()
      end
    end
    MCActionSubsystem:ExitInteractive(3)
  end
  if Game:IsValid(Character) then
    local skillManager = Character:GetSkillManager()
    if Game:IsValid(skillManager) then
      print(bWriteLog and "logic_main_city_enter:OnMainCityPendingSwitch stop skill")
      skillManager:ServerStopAllSkill(3)
    end
  end
  MainCity_GamePlay_Tools.StopPlayEmote()
end
function logic_main_city_enter:OnJumpMainCity(_, _, params)
  log(bWriteLog and "logic_main_city_enter:OnJumpMainCity")
  log_tree("logic_main_city_enter:OnJumpMainCity params:", params)
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  if not memopt:EnableEnterMainCity() then
    ShowNotice(81653)
    return
  end
  local teleport = params and params.teleport
  teleport = tonumber(teleport)
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_main_city_enter:OnJumpMainCity isInMainCity = " .. tostring(isInMainCity))
  if isInMainCity then
    if teleport then
      local MainCity_MainCityTeleport_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_MainCityTeleport_Client_Handler")
      MainCity_MainCityTeleport_Client_Handler.send_teleport_to_explore_req(teleport)
    end
    return
  end
  local isIn2DLobby = GameStatus.IsIn2DLobby()
  log(bWriteLog and "logic_main_city_enter:OnJumpMainCity isIn2DLobby = " .. tostring(isIn2DLobby))
  if not isIn2DLobby then
    return
  end
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  local isMainCityMapDownloaded = Main_City_Download_Tool.IsMainCityMapDownloaded(true)
  log(bWriteLog and "logic_main_city_enter:OnJumpMainCity isMainCityMapDownloaded = " .. tostring(isMainCityMapDownloaded))
  if not isMainCityMapDownloaded then
    return
  end
  UIManager.AndroidBackToLobby()
  UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Opening_MainCity)
  if teleport then
    local logic_main_city_latent_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_main_city_latent_queue)
    logic_main_city_latent_queue:EnqueueIngame(function()
      log(bWriteLog and "logic_main_city_invite.GotoMainCityAndSeesaw logic_main_city_latent_queue:EnqueueIngame execute")
      local MainCity_MainCityTeleport_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_MainCityTeleport_Client_Handler")
      MainCity_MainCityTeleport_Client_Handler.send_teleport_to_explore_req(teleport)
    end)
  end
  local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
  logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "EnterMCFromModuleJump")
end
function logic_main_city_enter:OnJumpMainCityDanceArea()
  log(bWriteLog and "logic_main_city_enter:OnJumpMainCityDanceArea")
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_main_city_enter:OnJumpMainCityDanceArea Not in main city")
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bSuccess = Lobby_Main_City_Enter.EnterMainCity()
    if bSuccess then
      local logic_main_city_latent_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_main_city_latent_queue)
      logic_main_city_latent_queue:EnqueueIngame(function()
        log(bWriteLog and "logic_main_city_enter:OnJumpMainCityDanceArea logic_main_city_latent_queue:EnqueueIngame execute")
        local MainCity_MainCityTeleport_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_MainCityTeleport_Client_Handler")
        MainCity_MainCityTeleport_Client_Handler.send_teleport_to_dance_area_req()
      end)
    end
  else
    log(bWriteLog and "logic_main_city_enter:OnJumpMainCityDanceArea In main city")
    local MainCity_MainCityTeleport_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_MainCityTeleport_Client_Handler")
    MainCity_MainCityTeleport_Client_Handler.send_teleport_to_dance_area_req()
  end
end
function logic_main_city_enter:OnCharacterEnter(uiBase, message)
  local nPlayerUID = message.uid
  local alias = message.alias
  local score = message.collectScore
  local PlayerName = message.nickName
  local rank = message.rank_value
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  log(bWriteLog and "  logic_main_city_enter:OnCharacterEnter. AliasInfo.aliasID: " .. tostring(alias))
  local XSuitID = XSuitAvatarDataUtil:GetValidXSuitIconId(nPlayerUID) or 0
  local aliasCfg = CDataTable.GetTableData("AliasCfg", alias)
  local value = score
  if aliasCfg and aliasCfg.AliasType == 7 then
    value = LocUtil.LocalizeResFormatByStr(aliasCfg.AliasName, rank)
  end
  local childUI = uiBase:CreateChildWindow("CanvasPanel_Into", UIManager.UI_Config.EnterBroadcastItem)
  local Msg = FuncUtil.GenEnterBroadcastMsg(alias, PlayerName, value)
  childUI:SetAnchors(0.5, 0.5, 0.5, 0.5)
  childUI:UpdateUI({
    AliasID = alias,
    XSuitIconID = XSuitID,
      })
  return childUI
end
function logic_main_city_enter:CheckIsNeedLoadingClose()
  log(bWriteLog and "logic_main_city_enter:CheckIsNeedLoadingClose")
  if IsWoWEditor then
    return true
  end
  local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
  log(bWriteLog and "logic_main_city_enter:CheckIsNeedLoadingClose IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
  if not IsInLobbyOrMainCity then
    return true
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  log(bWriteLog and "logic_main_city_enter:CheckIsNeedLoadingClose bEnterMainCityLoading = " .. tostring(Lobby_Main_City_Enter.bEnterMainCityLoading))
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    return false
  end
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local IsPendingAutoEnterMainCity = main_city_process_util.CheckIsPendingAutoEnterMainCity()
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  log(bWriteLog and "logic_main_city_enter:CheckIsNeedLoadingClose enterMainCityMode = " .. tostring(self.enterMainCityMode))
  if self.enterMainCityMode ~= 0 then
    return false
  end
  return true
end
function logic_main_city_enter:SetMainCityLoadingTimeOutTimer()
  log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer")
  local tickCount = 0
  self.loadingTimeoutTimer = self:AddTimerLoop(0, function()
    tickCount = tickCount + 1
    local isInMainCity = GameStatus.IsInMainCity()
    log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer isInMainCity = " .. tostring(isInMainCity))
    if not isInMainCity then
      return
    end
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer bEnterMainCityLoading = " .. tostring(Lobby_Main_City_Enter.bEnterMainCityLoading))
    if not Lobby_Main_City_Enter.bEnterMainCityLoading then
      log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer close loading 1")
      if self.loadingTimeoutTimer then
        self:RemoveTimer(self.loadingTimeoutTimer)
        self.loadingTimeoutTimer = nil
      end
      local ui_util = require("client.common.ui_util")
      local deviceLevel = ui_util.GetGameInstance():GetDeviceLevel()
      log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer deviceLevel = " .. tostring(deviceLevel))
      local delayTime = 1
      if deviceLevel and deviceLevel < 1 then
        delayTime = 4
      elseif deviceLevel and deviceLevel == 1 then
        delayTime = 2
      else
        delayTime = 1
      end
      self:AddTimerOnce(delayTime, function()
        UIManager.CloseUI(UIManager.UI_Config.loading)
      end)
      return
    end
    if 60 <= tickCount then
      log(bWriteLog and "logic_main_city_enter:SetMainCityLoadingTimeOutTimer close loading 2")
      if self.loadingTimeoutTimer then
        self:RemoveTimer(self.loadingTimeoutTimer)
        self.loadingTimeoutTimer = nil
      end
      UIManager.CloseUI(UIManager.UI_Config.loading)
      return
    end
  end, TIMER_INFINITE, 1)
end
function logic_main_city_enter:SetCurrentMainCityWeatherID(curMainCityWeatherID)
  log(bWriteLog and "logic_main_city_enter:SetCurrentMainCityWeatherID curMainCityWeatherID = " .. tostring(curMainCityWeatherID))
  self.end
function logic_main_city_enter:GetCurrentMainCityWeatherID()
  log(bWriteLog and "logic_main_city_enter:GetCurrentMainCityWeatherID self.curMainCityWeatherID = " .. tostring(self.curMainCityWeatherID))
  return self.curMainCityWeatherID
end
function logic_main_city_enter:SetCurrentMainCityWeatherChanged(bChanged)
  log(bWriteLog and "logic_main_city_enter:SetCurrentMainCityWeatherChanged bChanged = " .. tostring(bChanged))
  self.bCurMainCityWeatherChanged = bChanged
end
function logic_main_city_enter:GetCurrentMainCityWeatherChanged()
  log(bWriteLog and "logic_main_city_enter:GetCurrentMainCityWeatherChanged self.bCurMainCityWeatherChanged = " .. tostring(self.bCurMainCityWeatherChanged))
  return self.bCurMainCityWeatherChanged
end
function logic_main_city_enter:SetEnterMainCityMode(mode)
  log(bWriteLog and "logic_main_city_enter:SetEnterMainCityMode mode = " .. tostring(mode))
  self.enterMainCityMode = mode or 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_enter = class(CModuleBase, nil, logic_main_city_enter)
return Clogic_main_city_enter
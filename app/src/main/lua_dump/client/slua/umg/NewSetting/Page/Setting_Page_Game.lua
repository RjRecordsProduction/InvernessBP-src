local Setting_Page_Game = {}
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
local Stack_Game_Basic = require("client.logic.NewSetting.Stack.Stack_Game_Basic")
local Stack_Game_Advanced = require("client.logic.NewSetting.Stack.Stack_Game_Advanced")
function Setting_Page_Game:OnInitialize()
  Setting_Page_Game.__super.OnInitialize(self)
  self:SetWidgetVisible(self.UIRoot.Button_BackLobby, not GameStatus.IsInLobbyOrMainCity(), true)
  self:SetWidgetVisible(self.UIRoot.Button_CustomerService, LobbySystem.CheckOpen(10801) and not GameStatus.IsInLobbyOrMainCity(), true)
  if self:IsPeakGame() then
    if CGameState and CGameState:GetGameModeState() == "ReadyState" then
      self.UIRoot.Button_BackLobby:SetColorAndOpacity(FLinearColor(0.5, 0.5, 0.5, 1))
    else
      self.UIRoot.Button_BackLobby:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    end
  end
end
function Setting_Page_Game:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_CustomerService, self.OnClickCustomService, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloudManager, self.OnClickCloudManager, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BackLobby, self.OnClickBackLobby, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_ON_APPLY_CLOUD_DATA, function()
    self:RefreshAll()
  end)
  if self:IsPeakGame() then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChanged, self)
  end
end
function Setting_Page_Game:OnGameStateChanged(_, _, GameState)
  if GameState == "FightingState" and not GameStatus.IsInLobbyOrMainCity() then
    self.UIRoot.Button_BackLobby:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
  end
end
function Setting_Page_Game:OnClickBackLobby()
  self:PlayAudio(sound_config.click_v1)
  if self:IsPeakGame() and CGameState and CGameState:GetGameModeState() == "ReadyState" then
    BattleNormalSAPTipsByTextID(68400, CGameState.ReadyStateTime)
    print(bWriteLog and "UI:OnClickBackLobby, IsPeakGame and ReadyState")
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if GameStatus.IsInMainCity() then
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    SettingUtil.CloseSetting()
    UIManager.CloseUI(UIManager.UI_Config.MainCity_System_UIBP)
    Lobby_Main_City_Enter.LeaveMainCity()
  else
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.ShowBackLobbyNotice(self:IsPeakGame())
  end
end
function Setting_Page_Game:OnClickCustomService()
  self:PlayAudio(sound_config.click_v1)
  local SettingSystem = require("client.logic.setting.logic_setting")
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  SettingSystem.OpenService(LogicCustomerService.E_EntranceType.Settings)
end
function Setting_Page_Game:OnClickCloudManager()
  self:PlayAudio(sound_config.click_v1)
  local ReqFunc = function()
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingHandler.send_get_custom_settings_new_req("Setting_Basic")
  end
  local SettingCloudHelper = require("client.logic.setting.SettingCloudHelper")
  SettingCloudHelper.RequestCloudData(ReqFunc, Setting_Page_Game.EnterCloudManager)
end
local DoesSupport = function(value)
  return type(value) == "boolean" or type(value) == "number" or type(value) == "string"
end
function Setting_Page_Game.ApplyCloudData(CloudData)
  for _, option in ipairs(Stack_Game_Basic) do
    local CloudValue = CloudData[option.Key]
    if DoesSupport(CloudValue) then
      local SetFunc = option.SetFunc or FuncLib.SetValue
      SetFunc(option.Key, CloudValue)
    end
  end
  for _, option in ipairs(Stack_Game_Advanced) do
    local CloudValue = CloudData[option.Key]
    if DoesSupport(CloudValue) then
      local SetFunc = option.SetFunc or FuncLib.SetValue
      SetFunc(option.Key, CloudValue)
    end
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.isCloudSettingBasicUsed = true
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_Page_Game.UploadCloud()
  local TimeUtil = require("client.common.time_util")
  local BasicSettingCloudTable = {
    NN2025B = true,
    UploadTime = TimeUtil.GetServerTimeInSec()
  }
  for _, option in ipairs(Stack_Game_Basic) do
    local value = option.GetFunc and option.GetFunc(option.Key) or FuncLib.GetValue(option.Key)
    if DoesSupport(value) then
      BasicSettingCloudTable[option.Key] = value
    end
  end
  for _, option in ipairs(Stack_Game_Advanced) do
    local value = option.GetFunc and option.GetFunc(option.Key) or FuncLib.GetValue(option.Key)
    if DoesSupport(value) then
      BasicSettingCloudTable[option.Key] = value
    end
  end
  log_tree("BasicSettingCloudTable", BasicSettingCloudTable)
  local EncodedData = slua.LuaArchiverEncode(LuaStateWrapper, BasicSettingCloudTable)
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.UploadSettingConfigToCloud()
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_save_custom_settings_new_req("Setting_Basic", EncodedData)
end
function Setting_Page_Game.EnterCloudManager(Data)
  local BasicSettingConfigOnCloud
  local bDiff = false
  if Data then
    local bOldFormat = not string.find(Data, "NN2025B")
    if bOldFormat then
      local StringUtil = require("common.string_util")
      local SettingKeyAndValues = StringUtil.Split(Data, ";")
      local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
      BasicSettingConfigOnCloud = {}
      for _, Value in pairs(SettingKeyAndValues) do
        local SettingKeyAndValue = StringUtil.Split(Value, "=")
        local SettingKey = SettingKeyAndValue[1]
        local Value = SettingKeyAndValue[2]
        if SettingConfig[SettingKey] ~= nil then
          if type(SettingConfig[SettingKey]) == "boolean" then
            BasicSettingConfigOnCloud[SettingKey] = Value == "true"
          elseif type(SettingConfig[SettingKey]) == "number" then
            BasicSettingConfigOnCloud[SettingKey] = tonumber(Value)
          end
          if not bDiff and BasicSettingConfigOnCloud[SettingKey] ~= SettingConfig[SettingKey] then
            bDiff = true
          end
        end
      end
      SettingKeyAndValues = nil
      local SettingSystem = require("client.logic.setting.logic_setting")
      BasicSettingConfigOnCloud.UploadTime = SettingSystem.last_save_setting_basic_tm
    else
      BasicSettingConfigOnCloud = slua.LuaArchiverDecode(LuaStateWrapper, Data)
      if BasicSettingConfigOnCloud and type(BasicSettingConfigOnCloud) == "table" then
        local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
        for Key, Value in pairs(BasicSettingConfigOnCloud) do
          if SettingConfig[Key] ~= nil and SettingConfig[Key] ~= Value then
            bDiff = true
            break
          end
        end
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.Setting_Cloud_Manage_Popups_UIBP, {
    CloudData = BasicSettingConfigOnCloud,
    bSameAsCloud = not bDiff,
    CloudUploadTime = BasicSettingConfigOnCloud and BasicSettingConfigOnCloud.UploadTime,
    ApplyFunc = Setting_Page_Game.ApplyCloudData,
    ApplyText = LocUtil.GetLocalizeResStr(9901),
    UploadFunc = Setting_Page_Game.UploadCloud,
    UploadText = LocUtil.GetLocalizeResStr(39028)
  })
end
function Setting_Page_Game:IsPeakGame()
  if self.MainModeID ~= nil then
    return self.MainModeID == 11201
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameInstance = GameplayStatics.GetGameInstance(self.UIRoot)
  if uGameInstance == nil or not slua.isValid(uGameInstance) then
    print(bWriteLog and "UI:IsPeakGame, uGameInstance = nil")
    return
  end
  local MainModeID = uGameInstance:GetMainModeID()
  if MainModeID ~= 0 then
    self.  end
  print(bWriteLog and "UI:IsPeakGame, MainModeID = " .. tostring(MainModeID) .. ", result = " .. tostring(MainModeID == 11201))
  return MainModeID == 11201
end
local class = require("class")
local Setting_StackContainer = require("client.slua.umg.NewSetting.Page.Setting_StackContainer")
return class(Setting_StackContainer, nil, Setting_Page_Game)
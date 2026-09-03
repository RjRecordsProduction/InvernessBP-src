local lobby_system_in_right_bottom = {}
local JumpUtils = require("client.logic.store.jump_utils")
function lobby_system_in_right_bottom:ctor()
end
function lobby_system_in_right_bottom:OnInitialize()
  lobby_system_in_right_bottom.__super.OnInitialize(self)
  self:RegistReddotWidget(self.UIRoot.Lobby20_Tab_Item_UIBP_0.Image_Reddot)
  self:RegistReddotWidget(self.UIRoot.Lobby20_Tab_Item_UIBP.Image_Reddot)
  self:UpdateUI()
  self:SetSystemRedPoint()
end
function lobby_system_in_right_bottom:RegistEvents()
  lobby_system_in_right_bottom.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP_0.Button_0, self.OnButton_SecondSystemClick, self)
  self:AddOnPressedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP_0.Button_0, self.OnButton_SecondSystemPressed, self)
  self:AddOnReleasedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP_0.Button_0, self.OnButton_SecondSystemReleased, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP.Button_0, self.OnButton_FirstSystemClick, self)
  self:AddOnPressedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP.Button_0, self.OnButton_FirstSystemPressed, self)
  self:AddOnReleasedEventByControl(self.UIRoot.Lobby20_Tab_Item_UIBP.Button_0, self.OnButton_FirstSystemReleased, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SET_SYSTEM_ENTRANCE, self.OnEvent_SetSystemEntrance, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_CLOSE_POPUP, self.OnEventClosePopup, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_ON_CLICK_SET_SYSTEM_ENTRANCE, self.OnClickSetSystemEntrance, self)
  self:AddCommonEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, self.RedPointUpdate, self)
  self:AddCommonEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_INIT_SYSTEM_SUPERDATA, self.UpdateModuleRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_COMMUNITY, EVENTID_COMMUNITY_NOTIFY_REDDOT_INFO, self.SetSystemRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ASSEMBLY_ACTIVITY_UPDATE, self.UpdateUI, self)
end
function lobby_system_in_right_bottom:UpdateUI()
  self.UIRoot.Lobby20_Tab_Item_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Lobby20_Tab_Item_UIBP_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.firstSystem = nil
  self.secondSystem = nil
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  local systemInfoList = logic_lobby_system_extension:GetSystemEntranceInfo(lobby_system_entrance_marco.FromType.Classic)
  local count = 0
  if systemInfoList then
    count = #systemInfoList
    if 0 < count then
      local systemInfo = CDataTable.GetTableData("MainUISystem", systemInfoList[1])
      self:SetTabItem(self.UIRoot.Lobby20_Tab_Item_UIBP, systemInfo)
      self.firstSystem = systemInfo
    end
    if 1 < count then
      local systemInfo = CDataTable.GetTableData("MainUISystem", systemInfoList[2])
      self:SetTabItem(self.UIRoot.Lobby20_Tab_Item_UIBP_0, systemInfo)
      self.secondSystem = systemInfo
    end
  end
  self:SetWidgetVisible(self.UIRoot.SizeBox_Diy01, self.UIRoot.Lobby20_Tab_Item_UIBP:isVisible())
end
function lobby_system_in_right_bottom:SetTabItem(widget, systemInfo)
  local util = require("client.slua_ui_framework.util")
  widget.TextBlock_0:SetText(systemInfo.SystemName)
  self:SetTexture(widget.Image_4, systemInfo.Icon)
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local moduleId = logic_lobby_system_extension:GetMainModuleIDBySystemID(systemInfo.SystemID)
  self:SetRedPoint(moduleId, logic_lobby_reddot.redDotMap[moduleId] or false)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  if systemInfo.SystemID == lobby_system_entrance_marco.SystemIDDefine.COMMUNITY then
    local logic_community = require("client.slua.logic.community.logic_community")
    local bShowRedDot = logic_community.GetShowEntryRedDot()
    self:ToggleReddotActivation(widget.Image_Reddot, bShowRedDot)
  end
end
function lobby_system_in_right_bottom:OnButton_SecondSystemClick()
  if self.secondSystem and JumpUtils.IsGameJumpUrl(self.secondSystem.module) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(self.secondSystem.module)
    local moduleId = tonumber(params.module)
    if moduleId == BP_ENUM_MODULE_COMMUNITY then
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, params)
      self:SetRedPoint(moduleId, false)
    elseif moduleId == BP_ENUM_VLINK_SDK then
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, {
        jumpH5UrlFromClick = self.secondSystem.JumpH5Url
      })
    elseif moduleId == BP_ENUM_MODULE_COMMUNITY_Helpshift then
      local SettingSystem = require("client.logic.setting.logic_setting")
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      SettingSystem.OpenService(LogicCustomerService.E_EntranceType.Settings)
      EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_COMMUNITY_Helpshift, false)
    elseif moduleId == BP_ENUM_TOGETHER_CREATE_H5 then
      local JumpH5Url = self.secondSystem.JumpH5Url
      log(bWriteLog and "lobby_system_in_right_bottom:OnButton_SecondSystemClick JumpH5Url = " .. JumpH5Url)
      local logic_co_creation_base = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_co_creation_base)
      logic_co_creation_base:ClearCreationRedHotData()
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      local url = webModule:AddParameterByPersonalInfo(JumpH5Url, true, false)
      GlobalData.JumpUrl(url)
    else
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, params)
    end
    self:SendBtnTlog(moduleId)
  end
end
function lobby_system_in_right_bottom:PlaySpecialAudio(moduleId)
  log(bWriteLog and "[    PlaySpecialAudio" .. tostring(moduleId))
  local audio = sound_config.click_v1
  if moduleId == BP_ENUM_MODULE_CORPS or moduleId == BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL then
    audio = sound_config.new_corpsBtn
  elseif moduleId == BP_ENUM_MODULE_LEAGUEGAME then
    local season_year_util = require("client.logic.season_year.util.season_year_util")
    if not season_year_util.CheckFunctionIsOpen() then
      audio = sound_config.new_seasonBtn
    end
  elseif moduleId == BP_ENUM_MODULE_RANK then
    audio = sound_config.new_rankBtn
  elseif moduleId == BP_ENUM_MODULE_MAIL then
    audio = sound_config.new_mailBtn
  elseif moduleId == BP_ENUM_MODULE_SETTING then
    audio = sound_config.new_settingBtn
  end
  self:PlayAudio(audio)
end
function lobby_system_in_right_bottom:SendBtnTlog(module_id)
  if not module_id then
    return
  end
  if moduleID_to_tLogID[module_id] then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(moduleID_to_tLogID[module_id], 0, "selfdefined")
  end
end
function lobby_system_in_right_bottom:OnButton_SecondSystemPressed()
  self:ShowSystemEntrancePopup(false, self.secondSystem)
end
function lobby_system_in_right_bottom:OnButton_SecondSystemReleased()
  if self.SecondPressTime then
    self:RemoveTimer(self.SecondPressTime)
    self.SecondPressTime = nil
  end
end
function lobby_system_in_right_bottom:OnButton_FirstSystemClick()
  log(bWriteLog and "lobby_system_in_right_bottom:OnButton_FirstSystemClick")
  if self.firstSystem and JumpUtils.IsGameJumpUrl(self.firstSystem.module) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(self.firstSystem.module)
    local moduleId = tonumber(params.module)
    log(bWriteLog and "lobby_system_in_right_bottom:OnButton_FirstSystemClick moduleId = " .. moduleId)
    if moduleId == BP_ENUM_MODULE_COMMUNITY then
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, params)
      self:SetRedPoint(moduleId, false)
    elseif moduleId == BP_ENUM_VLINK_SDK then
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, {
        jumpH5UrlFromClick = self.firstSystem.JumpH5Url
      })
    elseif moduleId == BP_ENUM_MODULE_COMMUNITY_Helpshift then
      local SettingSystem = require("client.logic.setting.logic_setting")
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      SettingSystem.OpenService(LogicCustomerService.E_EntranceType.Settings)
      EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_COMMUNITY_Helpshift, false)
    elseif moduleId == BP_ENUM_TOGETHER_CREATE_H5 then
      local JumpH5Url = self.firstSystem.JumpH5Url
      log(bWriteLog and "lobby_system_in_right_bottom:OnButton_FirstSystemClick JumpH5Url = " .. JumpH5Url)
      local logic_co_creation_base = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_co_creation_base)
      logic_co_creation_base:ClearCreationRedHotData()
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      local url = webModule:AddParameterByPersonalInfo(JumpH5Url, true, false)
      GlobalData.JumpUrl(url)
    else
      self:PlaySpecialAudio(moduleId)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(moduleId, params)
    end
    self:SendBtnTlog(moduleId)
  end
end
function lobby_system_in_right_bottom:OnButton_FirstSystemPressed()
  self:ShowSystemEntrancePopup(true, self.firstSystem)
end
function lobby_system_in_right_bottom:OnButton_FirstSystemReleased()
  if self.FirstPressTime then
    self:RemoveTimer(self.FirstPressTime)
    self.FirstPressTime = nil
  end
end
function lobby_system_in_right_bottom:ShowSystemEntrancePopup(isFirst, system)
  local pressTime = self:AddTimerOnce(0.5, function()
    local widget = self.UIRoot.SizeBox_Diy02
    if isFirst then
      widget = self.UIRoot.SizeBox_Diy01
    end
    local UIUtil = require("client.common.ui_util")
    local position = UIUtil.GetWidgetViewportPos(widget)
    position = FVector2D(position.X - 80, position.Y - 120)
    local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
    UIManager.ShowUI(UIManager.UI_Config.lobby_system_entrance_popup, lobby_system_entrance_marco.PopUIType.lobby_system_in_right_bottom, system.SystemID, position)
    if isFirst then
      self.playAnimationWidget = self.UIRoot.Lobby20_Tab_Item_UIBP
      self.UIRoot.Lobby20_Tab_Item_UIBP:PlayUserWidgetAnimation(self.playAnimationWidget.Anim_Shake, 0, 0, 0, 1)
    else
      self.playAnimationWidget = self.UIRoot.Lobby20_Tab_Item_UIBP_0
      self.UIRoot.Lobby20_Tab_Item_UIBP_0:PlayUserWidgetAnimation(self.playAnimationWidget.Anim_Shake, 0, 0, 0, 1)
    end
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      Client.Vibrate(0)
    else
      Client.Vibrate(250)
    end
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.HideWeakGuide(8, 1)
  end)
  if isFirst then
    self.FirstPressTime = pressTime
  else
    self.SecondPressTime = pressTime
  end
end
function lobby_system_in_right_bottom:OnEvent_SetSystemEntrance(eventId, eventName, SystemID)
  if self.firstSystem == nil then
    local systemInfo = CDataTable.GetTableData("MainUISystem", SystemID)
    self.firstSystem = systemInfo
    self:SetTabItem(self.UIRoot.Lobby20_Tab_Item_UIBP, systemInfo)
  elseif self.secondSystem == nil then
    local systemInfo = CDataTable.GetTableData("MainUISystem", SystemID)
    self.secondSystem = systemInfo
    self:SetTabItem(self.UIRoot.Lobby20_Tab_Item_UIBP_0, systemInfo)
  else
    log_error("entrance is full")
    return
  end
  self:SetWidgetVisible(self.UIRoot.SizeBox_Diy01, self.UIRoot.Lobby20_Tab_Item_UIBP:isVisible())
end
function lobby_system_in_right_bottom:OnClickSetSystemEntrance(eventid, eventname, type, SystemID)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  if type == lobby_system_entrance_marco.PopUIType.lobby_system_in_right_bottom then
    if self.secondSystem and self.secondSystem.SystemID == SystemID then
      self.secondSystem = nil
      self.UIRoot.Lobby20_Tab_Item_UIBP_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if self.firstSystem and self.firstSystem.SystemID == SystemID then
      self.firstSystem = nil
      self.UIRoot.Lobby20_Tab_Item_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
    local serverData = logic_lobby_system_extension:GetServerData()
    for k, v in pairs(serverData) do
      if v == SystemID then
        table.remove(serverData, k)
        break
      end
    end
    logic_lobby_system_extension:send_report_system_entrance_info_req(serverData)
  end
  self:SetWidgetVisible(self.UIRoot.SizeBox_Diy01, self.UIRoot.Lobby20_Tab_Item_UIBP:isVisible())
end
function lobby_system_in_right_bottom:OnEventClosePopup(eventid, eventname, type)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  if type == lobby_system_entrance_marco.PopUIType.lobby_system_in_right_bottom and self.playAnimationWidget then
    self.playAnimationWidget:StopAnimation(self.playAnimationWidget.Anim_Shake)
    self.playAnimationWidget = nil
  end
end
function lobby_system_in_right_bottom:RedPointUpdate(eventId, eventName, moduleId, RedPoint)
  self:SetRedPoint(moduleId, RedPoint)
end
function lobby_system_in_right_bottom:UpdateModuleRedPoint(_, _, moduleId)
  self:SetRedPoint(moduleId)
end
function lobby_system_in_right_bottom:SetRedPoint(moduleId, RedPoint)
  log(bWriteLog and "[DeanJYT] lobby_system_in_right_bottom:SetRedPoint moduleId = " .. tostring(moduleId))
  local widget
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  if self.firstSystem and logic_lobby_system_extension:GetMainModuleIDBySystemID(self.firstSystem.SystemID) == moduleId then
    widget = self.UIRoot.Lobby20_Tab_Item_UIBP
  end
  if self.secondSystem and logic_lobby_system_extension:GetMainModuleIDBySystemID(self.secondSystem.SystemID) == moduleId then
    widget = self.UIRoot.Lobby20_Tab_Item_UIBP_0
  end
  if widget then
    local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
    local reddotData = logic_lobby_reddot.GetReddotDataByModule(moduleId)
    if reddotData then
      self:ToggleReddotActivation(widget.Image_Reddot, false)
      self:RegistReddotWidget(widget.Reddot_Anchor)
      widget.Reddot_Anchor:Bind(reddotData)
    else
      self:UnregistReddotWidget(widget.Reddot_Anchor)
      widget.Reddot_Anchor:UnBind()
      if moduleId == BP_ENUM_MODULE_SETTING and RedPoint == false then
        local logic_setting = require("client.logic.setting.logic_setting")
        local state = logic_setting.NeedShowSettingRed()
        self:ToggleReddotActivation(widget.Image_Reddot, state)
        return
      end
      if moduleId == BP_ENUM_MODULE_COMMUNITY then
        local logic_community = require("client.slua.logic.community.logic_community")
        local bShowRedDot = logic_community.GetShowEntryRedDot() and logic_community.IsInLobbyEntrance()
        self:ToggleReddotActivation(widget.Image_Reddot, bShowRedDot)
        return
      end
      if moduleId == BP_ENUM_MODULE_COMMUNITY_Helpshift then
        local bHasReddot = LobbySystem.roleData.customer_service_reddot or false
        self:ToggleReddotActivation(widget.Image_Reddot, bHasReddot)
        return
      end
      self:ToggleReddotActivation(widget.Image_Reddot, RedPoint)
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local redPath = SettingUtil.GetRedPointPath()
      if moduleId == BP_ENUM_MODULE_SETTING then
        redPath = SettingUtil.GetRedPointPath(true)
      end
      self:SetTexture(widget.Image_Reddot, redPath, {bMatchSize = true})
    end
  end
end
function lobby_system_in_right_bottom:SetSystemRedPoint()
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  for k, v in pairs(logic_lobby_system_extension:GetMainSystemID2ModuleIDMap()) do
    local redPoint = logic_lobby_reddot.redDotMap[v] or false
    self:SetRedPoint(v, redPoint)
  end
end
function lobby_system_in_right_bottom:UpdateBanRedDot(result)
  EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_BAN, result)
end
function lobby_system_in_right_bottom:OnClose()
  if self.SecondPressTime then
    self.SecondPressTime = nil
  end
  if self.FirstPressTime then
    self.FirstPressTime = nil
  end
  self.playAnimationWidget = nil
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUILobbySystemInRightBottom = class(ui_base, nil, lobby_system_in_right_bottom)
return CUILobbySystemInRightBottom
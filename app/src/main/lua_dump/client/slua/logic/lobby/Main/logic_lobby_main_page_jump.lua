local logic_lobby_main_page_jump = {}
function logic_lobby_main_page_jump:DefineAndResetData()
  self._isUrlJump = false
end
function logic_lobby_main_page_jump:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOBBY_PAGE_JUMP, self.OnUrlEvent, self)
end
function logic_lobby_main_page_jump:OnUrlEvent(_, _, params)
  log_tree("logic_lobby_main_page_jump:OnUrlEvent. params = ", params)
  if not self:_CheckCanJump() then
    log_warning(bWriteLog and "logic_lobby_main_page_jump:OnUrlEvent not can jump")
    return
  end
  self._isUrlJump = true
  local page = params.page and tonumber(params.page) or ENUM_LobbyPageType.Mid
  self:JumpToPage(page, nil, params)
  self._isUrlJump = false
end
function logic_lobby_main_page_jump:JumpToPage(page, callback, params)
  params = params or {}
  self:_DoWithParams(params)
  self:_DoJump(page, callback, params)
end
function logic_lobby_main_page_jump:_CheckCanJump()
  if not GameStatus.IsInLobbyOrMainCity() then
    log_warning(bWriteLog and "logic_lobby_main_page_jump:CheckCanJump not in lobby or main city")
    return false
  end
  return true
end
function logic_lobby_main_page_jump:_DoWithParams(params)
  if not params then
    return
  end
  local modID = params.modId and tonumber(params.modId)
  if modID then
    local callback = function(list, listType)
      self:_OnGetUGCModeList(modID, list, listType)
    end
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:BatchGetModInfo({modID}, LogicUGC.C_ModListTypes.Link, callback, {bGetPlayReq = true, bNotPostEvent = true})
  end
  local bUGC = params.bUGC
  if bUGC ~= nil and type(bUGC) == "string" then
    params.bUGC = tonumber(bUGC) == 1
  end
end
function logic_lobby_main_page_jump:_OnGetUGCModeList(modID, list, listType)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if listType ~= LogicUGC.C_ModListTypes.Link then
    log_warning(bWriteLog and "logic_lobby_main_page_jump:OnGetUGCModeList listType = " .. tostring(listType) .. " not match bin_lobby_page_jump")
    return
  end
  local modInfo = list and list[modID]
  if not modInfo then
    log_warning(bWriteLog and "logic_lobby_main_page_jump:OnGetUGCModeList modID = " .. tostring(modID) .. " not exist info")
    return
  end
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  logic_ugc_hall:SetJumpModInfo(modInfo.pub_mod_meta)
end
function logic_lobby_main_page_jump:_DoJump(page, callback, params)
  log_format("logic_lobby_main_page_jump:DoJump. page = [%s], callback = [%s]", page, callback)
  if not self:_CheckPageExist(page) then
    log(bWriteLog and "logic_lobby_main_page_jump:DoJump page not exist")
    return
  end
  local jumpToUGCLobby = page == ENUM_LobbyPageType.Right and params and params.bUGC
  log_format("logic_lobby_main_page_jump:DoJump. jumpToUGCLobby = [%s]", jumpToUGCLobby)
  if jumpToUGCLobby then
    self:_JumpToUGCLobby(callback, params)
    return
  end
  UIManager.ForceBackTo2DLobby()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_SIMU, page, callback)
end
function logic_lobby_main_page_jump:_JumpToUGCLobby(callback)
  log(bWriteLog and "logic_lobby_main_page_jump:_JumpToUGCLobby. callback = " .. tostring(callback))
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXmission = LogicTxMissionMain.IsInXMission()
  if isInXmission then
    log(bWriteLog and "logic_lobby_main_page_jump:_JumpToUGCLobby in xmission")
    return
  end
  local IsInFightingNotMainCity = GameStatus.IsInFightingNotMainCity()
  if IsInFightingNotMainCity then
    log(bWriteLog and "logic_lobby_main_page_jump:_JumpToUGCLobby in fighting not main city")
    return
  end
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local isUGCOpen = logic_ugc_hall:CheckIsOpen()
  log_format("logic_lobby_main_page_jump:_JumpToUGCLobby. rightMode = [%s], isUGCOpen = [%s]", rightMode, isUGCOpen)
  if not isUGCOpen then
    return
  end
  if self._isUrlJump then
    self:_SendModuleJumpToUGCHallReport()
  end
  self:_DoJumpToUGCLobby(callback)
end
function logic_lobby_main_page_jump:_DoJumpToUGCLobby(callback)
  log(bWriteLog and "logic_lobby_main_page_jump:_DoJumpToUGCLobby. callback = " .. tostring(callback))
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  local rightMode = logic_home_switch.lobbyRightMode
  local isInMainCity = GameStatus.IsInMainCity()
  if isInMainCity then
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_NEWBIE_GUIDE_BLOCK)
    EventSystem:postEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_NEWBIE_GUIDE_INTERRUPT)
    UIManager.ForceBackToLobby()
  else
    UIManager.ForceBackTo2DLobby()
  end
  if rightMode ~= ENUM_LobbyRightMode.UGCHall or isInMainCity then
    UIManager.ShowUI(UIManager.UI_Config.UGC_Hall_UIBP, true)
    if callback then
      callback()
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_SIMU, ENUM_LobbyPageType.Right, callback)
end
function logic_lobby_main_page_jump:_CheckPageExist(page)
  for k, v in pairs(ENUM_LobbyPageType) do
    if v == page then
      return true
    end
  end
  return false
end
function logic_lobby_main_page_jump:_SendModuleJumpToUGCHallReport()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Module_Jump_To_UGC_Hall, 0, "UrlToUGCHall")
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_main_page_jump = class(CModuleBase, nil, logic_lobby_main_page_jump)
return Clogic_lobby_main_page_jump
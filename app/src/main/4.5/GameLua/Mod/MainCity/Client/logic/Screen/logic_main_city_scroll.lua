local logic_main_city_scroll = {}
function logic_main_city_scroll:RegistEvents()
  log(bWriteLog and "logic_main_city_scroll:RegistEvents")
end
function logic_main_city_scroll:OnEnterMainCity()
  log(bWriteLog and "logic_main_city_scroll:OnEnterMainCity")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "logic_main_city_scroll:OnEnterMainCity 1")
    return
  end
  self:BindVirtualJoystickInput()
end
function logic_main_city_scroll:OnMainCityConnectedToDS()
  log(bWriteLog and "logic_main_city_scroll:OnMainCityConnectedToDS")
  self:OnEnterMainCity()
end
function logic_main_city_scroll:OnReturnToLobby()
  log(bWriteLog and "logic_main_city_scroll:OnReturnToLobby")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "logic_main_city_scroll:OnReturnToLobby 1")
    return
  end
  self:UnBindVirtualJoystickInput()
end
function logic_main_city_scroll:BindVirtualJoystickInput()
  log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput 1")
    return
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local bStandalone = UKismetSystemLibrary.IsStandalone(uPlayerController)
  log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput bStandalone = " .. tostring(bStandalone))
  if bStandalone then
    return
  end
  self:UnBindVirtualJoystickInput()
  self.touchBeginDelegate = uPlayerController.OnPlayerContollerTouchBegin:Add(function(TouchPos)
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerContollerTouchBegin TouchPos = " .. TouchPos:ToString())
    self.touchBeginPos = TouchPos
  end)
  self.touchEndDelegate = uPlayerController.OnPlayerControllerTouchEnd:Add(function(TouchPos)
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerControllerTouchEnd TouchPos = " .. TouchPos:ToString())
    local UIUtil = require("client.common.ui_util")
    local scale = UIUtil.GetViewportScale()
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerControllerTouchEnd scale = " .. scale)
    local viewportSize = UIUtil.GetViewportSize()
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerControllerTouchEnd viewportSize = " .. viewportSize:ToString())
    local startXPos = viewportSize.X / 3
    local endXPos = viewportSize.X / 3 * 2
    local startYPos = 0
    local endYPos = viewportSize.Y / 3
    local touchPosX = TouchPos.X
    local touchPosY = TouchPos.Y
    if startXPos > touchPosX or endXPos < touchPosX or endYPos < touchPosY then
      log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerControllerTouchEnd invalid")
      return
    end
    local offsetX = touchPosX - self.touchBeginPos.X
    local offsetY = touchPosY - self.touchBeginPos.Y
    log(bWriteLog and "logic_main_city_scroll:BindVirtualJoystickInput OnPlayerControllerTouchEnd offsetX = " .. tostring(offsetX) .. " offsetY = " .. tostring(offsetY))
    local coe = math.abs(offsetX) / math.abs(offsetY)
    if coe < 1 and offsetY < -50 then
      local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
      Lobby_Main_City_Enter.LeaveMainCity()
    end
  end)
end
function logic_main_city_scroll:UnBindVirtualJoystickInput()
  log(bWriteLog and "logic_main_city_scroll:UnBindVirtualJoystickInput")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "logic_main_city_scroll:UnBindVirtualJoystickInput 1")
    return
  end
  if self.touchBeginDelegate and uPlayerController.OnPlayerContollerTouchBegin then
    log(bWriteLog and "logic_main_city_scroll:UnBindVirtualJoystickInput 2")
    uPlayerController.OnPlayerContollerTouchBegin:Remove(self.touchBeginDelegate)
    self.touchBeginDelegate = nil
  end
  if self.touchEndDelegate and uPlayerController.OnPlayerControllerTouchEnd then
    log(bWriteLog and "logic_main_city_scroll:UnBindVirtualJoystickInput 3")
    uPlayerController.OnPlayerControllerTouchEnd:Remove(self.touchEndDelegate)
    self.touchEndDelegate = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_main_city_scroll = class(CModuleBase, nil, logic_main_city_scroll)
return Clogic_main_city_scroll
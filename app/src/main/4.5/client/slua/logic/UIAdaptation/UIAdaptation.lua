local UIAdaptation = {}
local UIUtil = require("client.common.ui_util")
function UIAdaptation:OnInitialize()
  UIAdaptation.__super.OnInitialize(self)
  log(bWriteLog and "UIAdaptation:OnInitialize")
  self.Const  self.Const  self.MidAlien = self.Const30
  self.MaxAlien = self.Const50
end
function UIAdaptation:LoginAdaption(bReLogin)
  log(bWriteLog and "UIAdaptation:LoginAdaption bReLogin = ", bReLogin)
  local roleData = LobbySystem.roleData
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saved = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.SpecialScreen)
  if saved and saved.screenValue then
    print(bWriteLog and "UIAdaptation:LoginAdaption saved", saved.screenValue)
    local value = tonumber(saved.screenValue) or 0
    UIUtil.SetScreenPadding(FMargin(value, 0, value, 0))
    return
  end
  if roleData.ui_rect ~= nil and roleData.ui_rect ~= "0,0,0,0" then
    print("UIAdaptation:LoginAdaption roleData.ui_rect", roleData.ui_rect)
    local StringUtil = require("common.string_util")
    local rectStr = StringUtil.Split(roleData.ui_rect, ",")
    if 4 <= #rectStr then
      log(bWriteLog and "UIAdaptation:LoginAdaption - server ui_rect: " .. roleData.ui_rect)
      UIUtil.SetScreenPadding(FMargin(tonumber(rectStr[1]) or 0, tonumber(rectStr[2]) or 0, tonumber(rectStr[3]) or 0, tonumber(rectStr[4]) or 0))
    end
    return
  end
  self:SetScreenPaddingByNotchSize()
end
function UIAdaptation:SetAlien(alien)
  log(bWriteLog and "UIAdaptation:SetAlien")
  if not alien then
    return
  end
  local StringUtil = require("common.string_util")
  local AlienStr = StringUtil.Split(alien, ",")
  self.MidAlien = tonumber(AlienStr[1])
  self.MaxAlien = tonumber(AlienStr[2])
end
function UIAdaptation:GetMidAlien()
  return self.MidAlien
end
function UIAdaptation:GetMaxAlien()
  return self.MaxAlien
end
function UIAdaptation:SetScreenPaddingByNotchSize()
  local PlatformName = Client.GetDevicePlatformName()
  log(bWriteLog and "UIAdaptation:SetScreenPaddingByNotchSize ", PlatformName)
  if PlatformName ~= "Android" then
    return
  end
  local notchSize = Client.GetNotchSize()
  local notchSizeNum = #notchSize
  if 2 <= notchSizeNum then
    local height = notchSize[2]
    if height > self.Const30 then
      height = self.Const50
    elseif 0 < height then
      height = self.Const30
    else
      height = 0
    end
    log(bWriteLog and "UIAdaptation:SetScreenPaddingByNotchSize - height=" .. tostring(height))
    self.DefaultScreenPadding = FMargin(height, 0, height, 0)
    UIUtil.SetScreenPadding(FMargin(height, 0, height, 0))
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUIAdaptation = class(CModuleBase, nil, UIAdaptation)
return CUIAdaptation
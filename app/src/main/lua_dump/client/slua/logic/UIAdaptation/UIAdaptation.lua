local UIAdaptation = {}
function UIAdaptation:OnInitialize()
  UIAdaptation.__super.OnInitialize(self)
  log(bWriteLog and "UIAdaptation:OnInitialize")
  self.Const  self.Const  self.uiRectOffset = "0,0,0,0"
  self.MidAlien = self.Const30
  self.MaxAlien = self.Const50
end
function UIAdaptation:LoginAdaption(bReLogin)
  log(bWriteLog and "UIAdaptation:LoginAdaption bReLogin = " .. tostring(bReLogin))
  local roleData = LobbySystem.roleData
  local StringUtil = require("common.string_util")
  local rectStr = StringUtil.Split(roleData.ui_rect, ",")
  local SettingSystem = require("client.logic.setting.logic_setting")
  local shapedScreenParam = SettingSystem.GetShapedScreenParam()
  if shapedScreenParam then
    LobbySystem.SetUIRectOffset(shapedScreenParam)
  else
    if roleData.ui_rect ~= nil then
      log(bWriteLog and "songGT roleData.ui_rect: " .. roleData.ui_rect)
      if 4 <= #rectStr then
        if roleData.ui_rect == "0,0,0,0" then
          self:SetUIRectOffsetByNotchSize()
        else
          LobbySystem.SetUIRectOffset(roleData.ui_rect)
        end
      else
        self:SetUIRectOffsetByNotchSize()
        log(bWriteLog and "songGT Waring roleData.ui_rect config info is not correct.....")
      end
    else
      log(bWriteLog and "songGT \229\144\142\229\143\176\230\156\170\230\180\190\229\143\145ui_rect\229\173\151\230\174\181")
      self:SetUIRectOffsetByNotchSize()
    end
    if roleData.result_bottom ~= nil then
      log(bWriteLog and "songGT roleData.result_bottom: " .. roleData.result_bottom)
    else
      log(bWriteLog and "songGT \229\144\142\229\143\176\230\156\170\230\180\190\229\143\145result_bottom\229\173\151\230\174\181")
    end
  end
end
function UIAdaptation:GetDefalutRectOffset()
  log(bWriteLog and "UIAdaptation:GetDefalutRectOffset")
  return self.uiRectOffset
end
function UIAdaptation:SetDefalutRectOffset(uiRectOffset)
  log(bWriteLog and "UIAdaptation:SetDefalutRectOffset")
  if not uiRectOffset then
    return
  end
  log(bWriteLog and "  : SetDefalutRectOffset uiRectOffset" .. tostring(uiRectOffset))
  self.end
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
  log(bWriteLog and "UIAdaptation:GetMidAlien")
  return self.MidAlien
end
function UIAdaptation:GetMaxAlien()
  log(bWriteLog and "UIAdaptation:GetMaxAlien")
  return self.MaxAlien
end
function UIAdaptation:SetUIRectOffsetByNotchSize()
  log(bWriteLog and "UIAdaptation:SetUIRectOffsetByNotchSize")
  local notchSize = Client.GetNotchSize()
  if Client.GetDevicePlatformName() ~= "Android" then
    return
  end
  local notchSizeNum = #notchSize
  for i = notchSizeNum, 1, -1 do
    log(bWriteLog and "notchSize[" .. tostring(i) .. "]: " .. notchSize[i])
  end
  if 2 <= notchSizeNum then
    local height = notchSize[2]
    if height > self.Const30 then
      height = self.Const50
    elseif 0 < height then
      height = self.Const30
    else
      height = 0
    end
    local notchSizeString = tostring(height) .. ",0," .. tostring(height) .. ",0"
    log(bWriteLog and "notchSizeString: " .. notchSizeString)
    self:SetDefalutRectOffset(notchSizeString)
    LobbySystem.SetUIRectOffset(notchSizeString)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUIAdaptation = class(CModuleBase, nil, UIAdaptation)
return CUIAdaptation
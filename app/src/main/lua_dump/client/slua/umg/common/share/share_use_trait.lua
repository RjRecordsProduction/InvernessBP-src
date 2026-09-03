local share_use_trait = {}
local Trait = require("common.trait")
local CShare = Trait(Trait.TraitPrototype, nil, share_use_trait)
local ScreenshotMaker = import("ScreenshotMaker")
function share_use_trait:OnClickShareImplement(cfg)
  self.shareCfg = cfg
  self:PreForScreenShot()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  local sSharePath = ScreenshotMaker.MakePicture(true)
  self:AddTimer(0, function()
    repeat
      coroutine.yield(0.1)
    until self:ShowShareUI(sSharePath)
    self:ScreenShotDone()
  end)
end
function share_use_trait:ShowShareUI(sSharePath)
  if ScreenshotMaker.HasCaptured(sSharePath) then
    local tShareCfg = self.shareCfg or {}
    tShareCfg.capturePath = sSharePath
    local Util = require("client.slua_ui_framework.util")
    Util.ShowShare(tShareCfg)
    return true
  end
  return false
end
function share_use_trait:OnClickShareFriendImplement(cfg, uObj_widget)
  self.shareCfg = cfg
  self:PreForScreenShot()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  local sWidgetSharePath
  if uObj_widget then
    local Logic_ShareToFriendUtils = require("client.logic.share.Logic_ShareToFriendUtils")
    sWidgetSharePath = Logic_ShareToFriendUtils.GetWidgetCapturePath()
    self:AddTimerOnce(0.3, function()
      local UIUtil = require("client.common.ui_util")
      UIUtil.MakeWidgetScreenshot(sWidgetSharePath, uObj_widget)
    end)
  end
  local sSharePath = ScreenshotMaker.MakePicture(true)
  self:AddTimer(0, function()
    repeat
      coroutine.yield(0.1)
    until self:ShowShareFriendUI(sSharePath, sWidgetSharePath)
    self:ScreenShotDone()
  end)
end
function share_use_trait:ShowShareFriendUI(sSharePath, sWidgetSharePath)
  if not sSharePath and not sWidgetSharePath then
    return false
  end
  local bIsExitsShare = false
  if sSharePath then
    bIsExitsShare = ScreenshotMaker.HasCaptured(sSharePath)
    log(bWriteLog and " share_use_trait:ShowShareFriendUI sSharePath: " .. sSharePath)
  end
  local bIsExistWidgetShare = false
  if sWidgetSharePath then
    local StringUtil = require("common.string_util")
    local tAllStr = StringUtil.Split(sWidgetSharePath, "Saved/")
    local sFileName = tAllStr and tAllStr[2]
    if sFileName then
      log(bWriteLog and " share_use_trait:ShowShareFriendUI sWidgetSharePath: " .. sWidgetSharePath .. " sFileName: " .. sFileName .. "")
      bIsExistWidgetShare = Client.IsFileExistByFileName(sFileName)
    end
  else
    bIsExistWidgetShare = true
  end
  if bIsExitsShare and bIsExistWidgetShare then
    local tShareCfg = self.shareCfg or {}
    tShareCfg.capturePath = sSharePath
    tShareCfg.widgetCapturePath = sWidgetSharePath
    local Util = require("client.slua_ui_framework.util")
    Util.ShowShareWithUICfg(UIManager.UI_Config.ShareFriends_Popup_UIBP, tShareCfg)
    return true
  end
  return false
end
function share_use_trait:PreForScreenShot()
end
function share_use_trait:ScreenShotDone()
end
return CShare
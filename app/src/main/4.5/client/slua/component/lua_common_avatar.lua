local lua_common_avatar = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local bDebugLog = false
local AsyncLoadType = {
  Frame = 2,
  LocalIcon = 4,
  NetIcon = 8
}
function lua_common_avatar:OnInitialize()
  self:_ParamDefine()
end
function lua_common_avatar:_ParamDefine()
  self.playerUid = ""
  self.iconURL = nil
  self.frameLevel = nil
  self.extraPara = {}
  self.roleNation = nil
  self.bIgnoreFrame = nil
  self.onAllLoadedDelegate = nil
  self.asyncLoadingMask = 0
end
function lua_common_avatar:OnClose()
  self._childUI = nil
end
function lua_common_avatar:_CreateItem()
  if self._childUI then
    return
  end
  self._childUI = self:CreateChildWindow(self.CanvasPanel_1, UIManager.UI_Config.Common_Avatar_All_UIBP, function(UIRoot)
    if bDebugLog then
      local ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
      log(bWriteLog and "lua_common_avatar:_CreateItem. OnCreated ObjectName:" .. ObjectName)
    end
    self:AddControlEvent(UIRoot.Button_Avatar, "OnClicked", self.OnClickButton_Enter, self)
  end)
end
function lua_common_avatar:OnClickButton_Enter()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1, self)
  if IsWoWEditor then
    local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    if not PufferResManager:IsLobbyResCompleted(true) then
      return
    end
  end
  self.OnClickItemCallback:BroadCast(self.playerUid)
end
function lua_common_avatar:IsValueEqual(v1, v2)
  return v1 == v2
end
function lua_common_avatar:InitView(style, uid, iconURL, gender, frameLevel, playerLevel, ignoreFrame, roleNation, isEnableDynamicIcon, extraPara)
  self.extraPara = extraPara or {}
  printf("lua_common_avatar:InitView. uid:%s iconURL:%s frameLevel:%s", tostring(uid), tostring(iconURL), tostring(frameLevel))
  self:SetPlayerUid(uid)
  self:SetIgnoreFrame(ignoreFrame)
  self.isEnableDynamicIcon = isEnableDynamicIcon == nil and true or isEnableDynamicIcon
  self:_CreateItem()
  self:_UpdateView(iconURL or "", frameLevel or 0, roleNation or "", playerLevel or 0)
end
function lua_common_avatar:_UpdateView(iconURL, frameLevel, roleNation, playerLevel)
  self:SetPlayerIcon(iconURL)
  self:SetFrame(frameLevel)
  self:_UpdateNationImage(roleNation)
  self:SetPlayerLevel(playerLevel)
  self:SetCollectLevel()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local bIsPlayerBanned = logic_profile:IsPlayerBannedOver30day(self.playerUid)
  self:SetPlayerBanned(bIsPlayerBanned)
end
function lua_common_avatar:SetPlayerUid(uid)
  self.playerUid = uid or ""
end
function lua_common_avatar:SetIgnoreFrame(bIgnoreFrame)
  self.frameLevel = bIgnoreFrame and 0 or self.frameLevel
end
function lua_common_avatar:SetPlayerLevel(level)
  self._childUI:SetPlayerLevel(level)
end
function lua_common_avatar:SetPlayerBanned(bIsBanned)
  self._childUI:SetPlayerBanned(bIsBanned)
end
function lua_common_avatar:SetAssetLoadingMethod(_, onLoadedCallback)
  if onLoadedCallback then
    if not assert(type(onLoadedCallback) == "function", "onLoadedCallback should be function!!!") then
      return
    end
    self.onAllLoadedDelegate = onLoadedCallback
    self.asyncLoadingMask = AsyncLoadType.Frame
  end
end
function lua_common_avatar:SetPlayerIcon(iconURL)
  if bDebugLog then
    local UIRoot = self._childUI.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("lua_common_avatar:SetPlayerIcon. ObjectName:%s equal:%s, self.iconURL=%s iconURL=%s ", ObjectName, tostring(self.iconURL == iconURL), tostring(self.iconURL), tostring(iconURL)))
  end
  if self:IsValueEqual(self.iconURL, iconURL) then
    return
  end
  self:_RefreshAvatarIcon(iconURL, true)
end
function lua_common_avatar:_RefreshAvatarIcon(iconURL, bNeedCallback)
  self:_CancelIconAsync()
  self:_SetDefaultIcon()
  if self.extraPara.DisableIcon then
    self:SetIconHide()
  end
  self.  if iconURL == "" then
    return
  end
  local util = require("client.slua_ui_framework.util")
  if util.IsOnlineImageUrl(iconURL) then
    self:_SetOnlinePlayerIcon(iconURL)
  elseif self:_IsDynamicPlayerIcon(iconURL, bNeedCallback) then
    self:_SetDynamicPlayerIcon(iconURL)
  else
    self:_SetStaticPlayerIcon(iconURL)
  end
end
function lua_common_avatar:_IsDynamicPlayerIcon(nAvatarID, bNeedCallback)
  if not self.isEnableDynamicIcon then
    return false
  end
  local successCallback
  if bNeedCallback then
    function successCallback()
      if not self._childUI then
        return
      end
      self:_RefreshAvatarIcon(self.iconURL)
    end
  end
  local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
  return headshot_module:CheckDynamicIconByID(nAvatarID, successCallback)
end
function lua_common_avatar:SetIconHide()
  self._childUI:_SetPlayerIconWidgetVisible()
end
function lua_common_avatar:SetFrameHide()
  self._childUI:_SetPlayerFrameWidgetVisible()
end
function lua_common_avatar:_SetDefaultIcon()
  self._childUI:SetDefaultHeadIcon()
end
function lua_common_avatar:_SetOnlinePlayerIcon(iconURL)
  if self.onAllLoadedDelegate then
    self:_AddAsyncMask(AsyncLoadType.NetIcon)
    self._childUI:SetOnlineHeadIconAsync(iconURL, function()
      self:_ProcAsyncFinish(AsyncLoadType.NetIcon)
    end)
  else
    self._childUI:SetOnlineHeadIconAsync(iconURL)
  end
end
function lua_common_avatar:_SetStaticPlayerIcon(iconURL)
  if self.onAllLoadedDelegate then
    self:_AddAsyncMask(AsyncLoadType.LocalIcon)
    self._childUI:SetHeadIconAsync(iconURL, function()
      self:_ProcAsyncFinish(AsyncLoadType.LocalIcon)
    end)
  else
    self._childUI:SetHeadIconAsync(iconURL)
  end
end
function lua_common_avatar:_SetDynamicPlayerIcon(iconURL)
  self._childUI:SetDynamicHeadIcon(iconURL)
end
function lua_common_avatar:_CancelIconAsync()
  self._childUI:CancelIconAsync()
end
function lua_common_avatar:SetFrame(frameLevel)
  if bDebugLog then
    local UIRoot = self._childUI.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(self._childUI.UIRoot)
    end
    log(bWriteLog and string.format("lua_common_avatar:SetFrame. ObjectName:%s equal:%s, self.frameLevel=%s frameLevel=%s ", ObjectName, tostring(self.frameLevel == frameLevel), tostring(self.frameLevel), tostring(frameLevel)))
  end
  if frameLevel == 0 then
    self:SetFrameHide()
    self.    return
  end
  if self:IsValueEqual(self.frameLevel, frameLevel) then
    return
  end
  self:_RefreshAvatarFrame(frameLevel, true)
end
function lua_common_avatar:_RefreshAvatarFrame(nFrameID, bNeedCallback)
  self:_CancelFrameAsync()
  self.frameLevel = nFrameID
  if self:_IsDynamicFrame(nFrameID, bNeedCallback) then
    self:_SetDynamicFrame(nFrameID)
  else
    self:_SetStaticFrame(nFrameID)
  end
end
function lua_common_avatar:_IsDynamicFrame(nFrameID, bNeedCallback)
  if not self.isEnableDynamicIcon then
    return false
  end
  local successCallback
  if bNeedCallback then
    function successCallback()
      if not self._childUI then
        return
      end
      self:_RefreshAvatarFrame(self.frameLevel)
    end
  end
  local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
  return headshot_module:CheckFrameDynamicIconByID(nFrameID, successCallback)
end
function lua_common_avatar:_SetStaticFrame(frameLevel)
  if self.onAllLoadedDelegate then
    self:_AddAsyncMask(AsyncLoadType.Frame)
    self._childUI:SetFrameAsync(frameLevel, function()
      self:_ProcAsyncFinish(AsyncLoadType.Frame)
    end)
  else
    self._childUI:SetFrameAsync(frameLevel)
  end
end
function lua_common_avatar:_SetDynamicFrame(frameLevel)
  self._childUI:SetDynamicFrame(frameLevel)
end
function lua_common_avatar:_CancelFrameAsync()
  self._childUI:CancelFrameAsync()
end
function lua_common_avatar:_UpdateNationImage(roleNation)
  if self:IsValueEqual(self.roleNation, roleNation) then
    return
  end
  self.  self._childUI:UpdateNationImage(roleNation)
end
function lua_common_avatar:RegistCommonAvatarReddotLimitation(parent)
  if not self._childUI then
    log_error(bWriteLog and "lua_common_avatar:RegistCommonAvatarReddotLimitation. _childUI not create")
    return
  end
  self._childUI:RegistCommonAvatarReddotLimitation(parent)
end
function lua_common_avatar:SetRedDot(isVisible)
  if not self._childUI then
    log_error(bWriteLog and "lua_common_avatar:SetRedDot. _childUI not create")
    return
  end
  self._childUI:SetRedDot(isVisible)
end
function lua_common_avatar:ToggleReddotVisibilityByLimitation(isVisible)
  self:SetRedDot(isVisible)
end
function lua_common_avatar:SetButtonEnabled(isEnabled)
  if not self._childUI then
    log_error(bWriteLog and "lua_common_avatar:SetButtonEnabled. _childUI not create")
    return
  end
  self._childUI:SetButtonEnabled(isEnabled)
end
function lua_common_avatar:_AddAsyncMask(AsyncTypeMask)
  if self.onAllLoadedDelegate then
    self.asyncLoadingMask = self.asyncLoadingMask | AsyncTypeMask
    log(bWriteLog and string.format(" lua_common_avatar:_AddAsyncMask AsyncTypeMask:%s , self.asyncLoadingMask:%s ", AsyncTypeMask, self.asyncLoadingMask))
  end
end
function lua_common_avatar:_RemoveAsyncMask(AsyncTypeMask)
  if self.onAllLoadedDelegate then
    self.asyncLoadingMask = self.asyncLoadingMask & ~AsyncTypeMask
    log(bWriteLog and string.format(" lua_common_avatar:_RemoveAsyncMask AsyncTypeMask:%s , self.asyncLoadingMask:%s ", AsyncTypeMask, self.asyncLoadingMask))
  end
end
function lua_common_avatar:_ProcAsyncFinish(AsyncTypeMask)
  if self.onAllLoadedDelegate then
    self:_RemoveAsyncMask(AsyncTypeMask)
    if self.asyncLoadingMask == 0 then
      self.onAllLoadedDelegate()
    end
  end
end
function lua_common_avatar:SetCollectLevel()
  self:UnInitCollectLevel()
  if not self.extraPara.collectPara or not next(self.extraPara.collectPara) then
    return
  end
  self._childUI:SetCollectLevel(self.playerUid, self.extraPara.collectPara)
end
function lua_common_avatar:UnInitCollectLevel()
  if not self._childUI then
    log_error(bWriteLog and "lua_common_avatar:UnInitCollectLevel. _childUI not create")
    return
  end
  self._childUI:UnInitCollectLevel()
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, lua_common_avatar)
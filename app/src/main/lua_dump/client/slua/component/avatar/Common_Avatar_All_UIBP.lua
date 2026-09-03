local Common_Avatar_All_UIBP = {}
local Common_Avatar_Const = require("client.slua.component.avatar.Common_Avatar_Const")
local Common_Avatar_ChildCfg = require("client.slua.component.avatar.Common_Avatar_ChildCfg")
local C_Enum_Player_Icon_Type = {
  AllHide = 0,
  Default = 1,
  Static = 2,
  Dynamic = 3
}
local C_Enum_Player_Frame_Type = {
  AllHide = 0,
  Static = 1,
  Dynamic = 2
}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local bDebugLog = false
function Common_Avatar_All_UIBP:ctor(_, onInitCallback)
  self.  self.DownloadOnlineHeadIconID = nil
  self.AsyncHeadIconID = nil
  self.DownloadFrameID = nil
end
function Common_Avatar_All_UIBP:OnInitialize()
  self.onInitCallback(self.UIRoot)
end
function Common_Avatar_All_UIBP:OnPostInitialize()
  self:SetButtonEnabled(true)
  self:RestoreUIOperation()
end
function Common_Avatar_All_UIBP:_SetPlayerIconWidgetVisible(type)
  self:_SetWidgetVisible(self.UIRoot.Image_Icon_Default, C_Enum_Player_Icon_Type.Default == type)
  self:_SetWidgetVisible(self.UIRoot.Image_Avatar, C_Enum_Player_Icon_Type.Static == type)
  self:_SetWidgetVisible(self.UIRoot.GIF_Avatar, C_Enum_Player_Icon_Type.Dynamic == type)
end
function Common_Avatar_All_UIBP:_SetPlayerFrameWidgetVisible(type)
  self:_SetWidgetVisible(self.UIRoot.Image_frame, C_Enum_Player_Frame_Type.Static == type)
  self:_SetWidgetVisible(self.UIRoot.GIF_frame, C_Enum_Player_Frame_Type.Dynamic == type)
end
function Common_Avatar_All_UIBP:_SetWidgetVisible(widget, visible, isButton)
  local UIUtil = require("client.common.ui_util")
  widget:SetWidgetVisibility(UIUtil.BoolToVisible(visible, true, isButton))
end
function Common_Avatar_All_UIBP:SetDefaultHeadIcon()
  self:UIOperation(function()
    if bDebugLog then
      local UIRoot = self.UIRoot
      local ObjectName
      if type(UIRoot) == "table" then
        ObjectName = "Async"
      else
        ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
      end
      log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetDefaultHeadIcon. ObjectName:%s", ObjectName))
    end
    self:_SetPlayerIconWidgetVisible(C_Enum_Player_Icon_Type.Default)
  end)
end
function Common_Avatar_All_UIBP:SetOnlineHeadIconAsync(iconURL, onLoaded)
  self:UIOperation(function()
    local SuccessCallback = function(texture, url)
      if not self.UIRoot then
        return
      end
      if bDebugLog then
        local UIRoot = self.UIRoot
        local ObjectName
        if type(UIRoot) == "table" then
          ObjectName = "Async"
        else
          ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
        end
        log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetOnlineHeadIconAsync. loaded ObjectName:%s, iconURL=%s", ObjectName, tostring(iconURL)))
      end
      self.UIRoot.Image_Avatar:SetBrushFromTexture(texture, false)
      self:_SetPlayerIconWidgetVisible(C_Enum_Player_Icon_Type.Static)
      if onLoaded then
        onLoaded()
      end
    end
    local Common_Avatar_Util = require("client.slua.component.avatar.Common_Avatar_Util")
    local downloadId = Common_Avatar_Util.DownloadAvatar(self, nil, iconURL, SuccessCallback)
    if downloadId and 0 < downloadId then
      self.DownloadOnlineHeadIconID = downloadId
    end
  end)
end
function Common_Avatar_All_UIBP:SetHeadIconAsync(iconURL, onLoaded)
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetHeadIconAsync. ObjectName:%s, iconURL=%s", ObjectName, tostring(iconURL)))
  end
  local UIUtil = require("client.common.ui_util")
  local ItemSmallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(tonumber(iconURL))
  if ItemSmallIcon and ItemSmallIcon ~= "" then
    self:UIOperation(function()
      if not bHasAddKnownMissing then
        self.AsyncHeadIconID = self:GetAssetAsync(ItemSmallIcon, function(loadObject)
          if bDebugLog then
            local UIRoot = self.UIRoot
            local ObjectName
            if type(UIRoot) == "table" then
              ObjectName = "Async"
            else
              ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
            end
            log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetHeadIconAsync. loaded ObjectName:%s, iconURL=%s", ObjectName, tostring(iconURL)))
          end
          self.UIRoot.Image_Avatar:SetBrushFromTexture(loadObject, false)
          self:_SetPlayerIconWidgetVisible(C_Enum_Player_Icon_Type.Static)
          if onLoaded then
            onLoaded()
          end
        end)
      else
        local SuccessCallback = function(texture, url)
          if not self.UIRoot then
            return
          end
          self:_SetPlayerIconWidgetVisible(C_Enum_Player_Icon_Type.Static)
          if onLoaded then
            onLoaded()
          end
        end
        local Common_Avatar_Util = require("client.slua.component.avatar.Common_Avatar_Util")
        local downloadId = Common_Avatar_Util.DownloadAvatar(self, self.UIRoot.Image_Avatar, ItemSmallIcon, SuccessCallback, {bHasAddKnownMissing = true})
        if downloadId and 0 < downloadId then
          self.DownloadOnlineHeadIconID = downloadId
        end
      end
    end)
  end
end
function Common_Avatar_All_UIBP:SetDynamicHeadIcon(avatarID)
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetDynamicHeadIcon. ObjectName:%s, avatarID=%s", ObjectName, tostring(avatarID)))
  end
  local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
  local dynamicIcon = headshot_module:GetDynamicIconByID(avatarID)
  if dynamicIcon == "" then
    log_error(bWriteLog and string.format("Common_Avatar_All_UIBP:SetDynamicHeadIcon Headportrait config is empty."))
    return nil
  end
  self:_SetPlayerIconWidgetVisible(C_Enum_Player_Icon_Type.Dynamic)
  local sChildName = Common_Avatar_Const.Enum_ChildName.DynamicIcon
  local tChildCfg = Common_Avatar_ChildCfg[sChildName]
  local panelWidget = self.UIRoot[tChildCfg.sParentName]
  self:_RemoveAndCreateCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.DynamicIcon, dynamicIcon, panelWidget)
end
function Common_Avatar_All_UIBP:CancelIconAsync()
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:CancelIconAsync. ObjectName:%s self.DownloadOnlineHeadIconID=%s self.AsyncHeadIconID=%s", ObjectName, tostring(self.DownloadOnlineHeadIconID), tostring(self.AsyncHeadIconID)))
  end
  if self.DownloadOnlineHeadIconID then
    self:CancelImageDownloadByIndex(self.DownloadOnlineHeadIconID)
    self.DownloadOnlineHeadIconID = nil
  end
  if self.AsyncHeadIconID then
    self:CancelAssetAsync(self.AsyncHeadIconID)
    self.AsyncHeadIconID = nil
  end
end
function Common_Avatar_All_UIBP:SetFrameAsync(frameLevel, onLoaded)
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetFrameAsync. ObjectName:%s, frameLevel=%s", ObjectName, tostring(frameLevel)))
  end
  local UIUtil = require("client.common.ui_util")
  local ItemSmallIcon, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(tonumber(frameLevel))
  if ItemSmallIcon and ItemSmallIcon ~= "" then
    self:UIOperation(function()
      if not bHasAddKnownMissing then
        self.DownloadFrameID = self:GetAssetAsync(ItemSmallIcon, function(loadObject)
          if bDebugLog then
            local UIRoot = self.UIRoot
            local ObjectName
            if type(UIRoot) == "table" then
              ObjectName = "Async"
            else
              ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
            end
            log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetFrameAsync. loaded ObjectName:%s, frameLevel=%s", ObjectName, tostring(frameLevel)))
          end
          self:_SetFrameTexture(loadObject)
          if onLoaded then
            onLoaded()
          end
        end)
      else
        local SuccessCallback = function(texture, url)
          if not self.UIRoot then
            return
          end
          self:_SetFrameTexture(texture)
          if onLoaded then
            onLoaded()
          end
        end
        local Common_Avatar_Util = require("client.slua.component.avatar.Common_Avatar_Util")
        local downloadId = Common_Avatar_Util.DownloadAvatar(self, self.UIRoot.Image_frame, ItemSmallIcon, SuccessCallback, {bHasAddKnownMissing = true})
        if downloadId and 0 < downloadId then
          self.DownloadOnlineHeadIconID = downloadId
        end
      end
    end)
  else
    self:_SetPlayerFrameWidgetVisible(C_Enum_Player_Frame_Type.AllHide)
  end
end
function Common_Avatar_All_UIBP:SetDynamicFrame(frameLevel)
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:SetDynamicFrame. ObjectName:%s, frameLevel=%s", ObjectName, tostring(frameLevel)))
  end
  local headshot_module = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.headshot_module)
  local dynamicIcon = headshot_module:GetFrameDynamicIconByID(frameLevel)
  if dynamicIcon == "" then
    log_error(bWriteLog and string.format("Common_Avatar_All_UIBP:SetDynamicFrame AvatarFrame config is empty."))
    return nil
  end
  self:_SetPlayerFrameWidgetVisible(C_Enum_Player_Frame_Type.Dynamic)
  local sChildName = Common_Avatar_Const.Enum_ChildName.DynamicFrame
  local tChildCfg = Common_Avatar_ChildCfg[sChildName]
  local panelWidget = self.UIRoot[tChildCfg.sParentName]
  self:_RemoveAndCreateCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.DynamicFrame, dynamicIcon, panelWidget)
end
function Common_Avatar_All_UIBP:CancelFrameAsync()
  if bDebugLog then
    local UIRoot = self.UIRoot
    local ObjectName
    if type(UIRoot) == "table" then
      ObjectName = "Async"
    else
      ObjectName = UKismetSystemLibrary.GetDisplayName(UIRoot)
    end
    log(bWriteLog and string.format("Common_Avatar_All_UIBP:CancelFrameAsync. ObjectName:%s self.DownloadFrameID=%s", ObjectName, tostring(self.DownloadFrameID)))
  end
  if self.DownloadFrameID then
    self:CancelAssetAsync(self.DownloadFrameID)
    self.DownloadFrameID = nil
  end
end
function Common_Avatar_All_UIBP:_SetFrameTexture(texture2D)
  self:_SetPlayerFrameWidgetVisible(C_Enum_Player_Frame_Type.Static)
  self.UIRoot.Image_frame:SetBrushFromTexture(texture2D, false)
  self.UIRoot.Image_frame:SetRenderScale(FVector2D(1, 1))
end
function Common_Avatar_All_UIBP:SetPlayerLevel(level)
  if 1 <= level then
    self:_SetWidgetVisible(self.UIRoot.TextBlock_PlayerLevel, true)
    self.UIRoot.TextBlock_PlayerLevel:SetText(tostring(level))
  else
    self:_SetWidgetVisible(self.UIRoot.TextBlock_PlayerLevel, false)
  end
end
function Common_Avatar_All_UIBP:SetPlayerBanned(bIsBanned)
  self:_CreateOrRemoveCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.Ban, bIsBanned)
end
function Common_Avatar_All_UIBP:UpdateNationImage(roleNation)
  local UIUtil = require("client.common.ui_util")
  UIUtil.UpdateNationImageByLua(self.UIRoot.Image_roleinfo_nation, roleNation)
end
function Common_Avatar_All_UIBP:RegistCommonAvatarReddotLimitation(parent)
  if self.UIRoot.Image_RedDot then
    parent:RegistReddotWidget(self.UIRoot.Image_RedDot)
  end
end
function Common_Avatar_All_UIBP:SetRedDot(isVisible)
  self:_CreateOrRemoveCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.Reddot, isVisible)
end
function Common_Avatar_All_UIBP:SetCollectLevel(uid, collectPara)
  self:_RemoveCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.CollectLevel)
  local cObj_collectLevel = self:_CreateCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.CollectLevel, uid, collectPara)
  if not cObj_collectLevel then
    return
  end
  cObj_collectLevel:SetAutoSize(true)
end
function Common_Avatar_All_UIBP:UnInitCollectLevel()
  self:_CreateOrRemoveCommonItemChildUI(Common_Avatar_Const.Enum_ChildName.CollectLevel, false)
end
function Common_Avatar_All_UIBP:SetButtonEnabled(isEnabled)
  self:_SetWidgetVisible(self.UIRoot.Button_Avatar, true, isEnabled)
end
function Common_Avatar_All_UIBP:_CreateOrRemoveCommonItemChildUI(sChildName, bIsShow, ...)
  if bIsShow then
    self:_CreateCommonItemChildUI(sChildName, ...)
  else
    self:_RemoveCommonItemChildUI(sChildName)
  end
end
function Common_Avatar_All_UIBP:_RemoveAndCreateCommonItemChildUI(sChildName, ...)
  self:_RemoveCommonItemChildUI(sChildName)
  self:_CreateCommonItemChildUI(sChildName, ...)
end
function Common_Avatar_All_UIBP:_CreateCommonItemChildUI(sChildName, ...)
  if self[sChildName] then
    return self[sChildName]
  end
  local tChildCfg = Common_Avatar_ChildCfg[sChildName]
  if not tChildCfg then
    log_error(bWriteLog and string.format("Common_Avatar_All_UIBP:_CreateCommonItemChildUI Not Child. sChildName=%s, tChildCfg=%s", tostring(sChildName), tostring(tChildCfg)))
    return
  end
  if tChildCfg.baseType == Common_Avatar_Const.Enum_BaseType.CreateChildWindowBPPathInBaseCfg then
    self[sChildName] = self:CreateChildWindow(tChildCfg.sParentName, tChildCfg.baseConfig, ...)
  elseif tChildCfg.baseType == Common_Avatar_Const.Enum_BaseType.CreateChildWindowBPPathInChildCfg then
    self[sChildName] = self:CreateChildWindowWithBpPath(tChildCfg.sParentName, tChildCfg.baseConfig, tChildCfg.sBpPath, ...)
  else
    self[sChildName] = self:CreateChildWindowWithBpPath(tChildCfg.sParentName, tChildCfg.baseConfig, ...)
  end
  self[sChildName]:SetZOrder(tChildCfg.nZOrder)
  return self[sChildName]
end
function Common_Avatar_All_UIBP:_RemoveCommonItemChildUI(sChildName)
  if not self[sChildName] then
    return
  end
  self[sChildName]:Close()
  self[sChildName] = nil
end
local class = require("class")
local ui_base = require("client.slua.component.avatar.Common_Avatar_UIBase")
local CCommon_Avatar_All_UIBP = class(ui_base, nil, Common_Avatar_All_UIBP)
return CCommon_Avatar_All_UIBP
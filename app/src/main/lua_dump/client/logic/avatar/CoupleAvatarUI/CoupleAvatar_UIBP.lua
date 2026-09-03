local TableUtil = require("common.table_util")
local CoupleAvatar_UIBP = {}
local _uObj_Vec3 = FVector(0, 1, 0)
local _tDownloadUICfg = {
  showGray = true,
  hideMask = true,
  showSize = true,
  size = 60
}
function CoupleAvatar_UIBP:ctor(_, nUId, nAvatarSceneType, tAvatarShowCfg, tCoupleUIShowCfg)
  self._nUId = tonumber(nUId)
  self._  self._tCoupleAvatarCfg = TableUtil.CopyTable(tAvatarShowCfg)
  self._tCoupleUICfg = tCoupleUIShowCfg or {}
end
function CoupleAvatar_UIBP:OnInitialize()
  CoupleAvatar_UIBP.__super.OnInitialize(self)
end
function CoupleAvatar_UIBP:RegistEvents()
  CoupleAvatar_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_COUPLE_AVATAR, EVENTID_LOBBY_SOCIAL_UPDATE_AVATAR, self.OnAvatarShowAdaptEvent, self)
end
function CoupleAvatar_UIBP:OnPostInitialize()
  CoupleAvatar_UIBP.__super.OnPostInitialize(self)
  if not self._nUId or not self._tCoupleAvatarCfg then
    log(bWriteLog and " CoupleAvatar_UIBP:OnPostInitialize nUId = " .. tostring(self._nUId) .. " >>> tCoupleAvatarCfg" .. tostring(self._tCoupleAvatarCfg))
    return
  end
  self:InitShow()
end
function CoupleAvatar_UIBP:OnClose()
  local nAvatarSceneType = self._nAvatarSceneType
  if not nAvatarSceneType then
    return
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  CoupleAvatarSystem:DestoryCoupleAvatar(nAvatarSceneType)
  CoupleAvatar_UIBP.__super.OnClose(self)
end
function CoupleAvatar_UIBP:OnAvatarShowAdaptEvent(_, _, nUId, nCoupleAvatarSceneType)
  local nAvatarSceneType = self._nAvatarSceneType
  if tostring(nUId) ~= tostring(self._nUId) or nCoupleAvatarSceneType ~= nAvatarSceneType then
    return
  end
  self:AdaptAvatar()
end
function CoupleAvatar_UIBP:AdaptAvatar()
  local nAvatarSceneType = self._nAvatarSceneType
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(nAvatarSceneType)
  local uObj_avatar
  if CoupleAvatar:IsTwoPerson() then
    uObj_avatar = CoupleAvatar:GetPawnContainerModel()
  else
    local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
    uObj_avatar = CoupleAvatar:GetModel(CoupleAvatarConfig.AvatarType.Self)
  end
  if not uObj_avatar then
    return
  end
  local uViewportPos = self._tCoupleUICfg.uViewportPos
  local UIUtil = require("client.common.ui_util")
  if not uViewportPos then
    uViewportPos = UIUtil.GetWidgetViewportPosInNormalized(self.UIRoot.CanvasPanel_Root, 0.5, 0.5)
    if uViewportPos.X == 0 and uViewportPos.Y == 0 then
      self:AdaptAvatarErrorDebugLog()
      return
    end
  end
  local WorldPosition, WorldDirection = UIUtil.DeprojectScreenToWorld(uViewportPos)
  local bResult, tIntersection = UIUtil.RayIntersectPlane(WorldPosition, WorldDirection, uObj_avatar:K2_GetActorLocation(), _uObj_Vec3)
  if bResult then
    local uObj_selfPos = uObj_avatar:K2_GetActorLocation()
    log(bWriteLog and string.format("[couple_avatar_position]CoupleAvatar_UIBP:AdaptAvatar," .. " IsTwoPerson: %s, " .. " uViewportPos: (%f, %f), " .. " OriginPos: (%f, %f, %f), " .. " IntersectionX: %f, " .. " OffsetX: %f", tostring(CoupleAvatar:IsTwoPerson()), uViewportPos.X, uViewportPos.Y, uObj_selfPos.X, uObj_selfPos.Y, uObj_selfPos.Z, tIntersection.X, tIntersection.X - uObj_selfPos.X))
    local OffSetX = tIntersection.X - uObj_selfPos.X
    uObj_selfPos.X = tIntersection.X
    uObj_avatar:K2_SetActorLocation(uObj_selfPos, false, nil, false)
    CoupleAvatar:AddPetLocationOffset(OffSetX, 0, 0)
    self:AddTimerOnce(0, function()
      CoupleAvatar:ResetPetAndTVLocation()
    end)
  end
end
function CoupleAvatar_UIBP:InitShow()
  local tCoupleAvatarCfg = self._tCoupleAvatarCfg
  local fTempGotDataCallback = tCoupleAvatarCfg.fGotDataCallback
  function tCoupleAvatarCfg.fGotDataCallback(nUId, tUserData, tFriendData)
    self:GotDataCallback(nUId, tUserData, tFriendData)
    if fTempGotDataCallback then
      fTempGotDataCallback(nUId, tUserData, tFriendData)
    end
  end
  local uDownloadPanelPos = self._tCoupleUICfg.uDownloadPanelPos or FVector2D(0, 50)
  self.UIRoot.CanvasPanel_CoupleDownload.Slot:SetPosition(uDownloadPanelPos)
  self:RefreshShow(self._nUId, true)
end
function CoupleAvatar_UIBP:RefreshShow(nUId, bForceRefresh)
  local nCoupleAvatarType = self._nAvatarSceneType
  if not nUId or not nCoupleAvatarType then
    self:HideAllShow()
    return
  end
  nUId = tonumber(nUId)
  if not bForceRefresh and self._nUId == nUId then
    return
  end
  self._  local tCoupleAvatarCfg = self._tCoupleAvatarCfg
  self:RefreshHideRoleTipShow()
  self:RefreshDownloadUIShow()
  self:RefreshAliasTitleShow()
  self:AddTimerOnce(0, function()
    local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
    local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(nCoupleAvatarType)
    CoupleAvatar:UpdateAvatar(nUId, tCoupleAvatarCfg)
  end)
end
function CoupleAvatar_UIBP:RefreshHideRoleTipShow(nUId, tUserData)
  local node_root = self.UIRoot
  if not self._tCoupleUICfg.bIsCheckHideRoleTip then
    self:SetWidgetVisible(node_root.CanvasPanel_HideRoleTip, false)
    return
  end
  local bIsShow = self:CheckIsShowHideRoleTip(nUId, tUserData)
  self:SetWidgetVisible(node_root.CanvasPanel_HideRoleTip, bIsShow)
end
function CoupleAvatar_UIBP:RefreshDownloadUIShow(nUId, tUserData, tFriendData)
  local node_root = self.UIRoot
  local bIsShow = self:CheckIsShowDownloadUI(nUId, tUserData)
  if not bIsShow then
    self:SetWidgetVisible(node_root.CanvasPanel_CoupleDownload, false)
    return
  end
  local bIsShowDownloadUI = self._tCoupleUICfg.bIsShowDownloadUI
  local tDownloadList
  if self._tCoupleUICfg.fGetDownloadResList then
    tDownloadList = self._tCoupleUICfg.fGetDownloadResList(nUId, tUserData, tFriendData)
  else
    tDownloadList = {}
    self:DownloadDataHandler(tDownloadList, tUserData)
    self:DownloadDataHandler(tDownloadList, tFriendData)
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, tDownloadList, self, node_root.Panel_Download, _tDownloadUICfg)
  self:SetWidgetVisible(node_root.CanvasPanel_CoupleDownload, bIsShowDownloadUI)
end
function CoupleAvatar_UIBP:RefreshAliasTitleShow(nUId)
  local node_root = self.UIRoot
  if not self._tCoupleUICfg.bIsCheckAliasTitle then
    self:SetWidgetVisible(node_root.Title_UIBP, false)
    return
  end
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local tUserData = BasicDataAvatarWearInfo:GetCacheData(nUId)
  if not nUId or not tUserData then
    self:SetWidgetVisible(node_root.Title_UIBP, false)
    return
  end
  local profile = self:GetProfileData(nUId)
  if not profile then
    self:SetWidgetVisible(node_root.Title_UIBP, false)
    return
  end
  local bIsShow = false
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    local SettingUtil = require("client.slua.logic.setting.setting_util")
    bIsShow = SettingUtil.OnlyFriend(nUId, tUserData.bshow, 1)
    log(bWriteLog and "CoupleAvatar_UIBP:RefreshAliasTitleShow", bIsShow)
  else
    bIsShow = tUserData.bshow
  end
  local bIsShowAlias = profile.alias.id and profile.alias.id > 0 and bIsShow
  if bIsShowAlias then
    node_root.Title_UIBP:SetAliasInfo(profile.alias.id, profile.alias.title or "", profile.alias.nation or "", 0, profile.alias.rank_id or 0)
  end
  self:SetWidgetVisible(node_root.Title_UIBP, bIsShowAlias)
end
function CoupleAvatar_UIBP:HideAllShow()
  self._nUId = nil
  local node_root = self.UIRoot
  self:SetWidgetVisible(node_root.Title_UIBP, false)
  self:SetWidgetVisible(node_root.Panel_Download, false)
  self:SetWidgetVisible(node_root.CanvasPanel_HideRoleTip, false)
  local nCoupleAvatarType = self._nAvatarSceneType
  if not nCoupleAvatarType then
    return
  end
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(nCoupleAvatarType)
  CoupleAvatar:HideAvatars()
end
function CoupleAvatar_UIBP:GotDataCallback(nUId, tUserData, tFriendData)
  if tonumber(nUId) ~= self._nUId then
    return
  end
  local node_root = self.UIRoot
  if not node_root then
    return
  end
  self:RefreshHideRoleTipShow(nUId, tUserData)
  self:RefreshAliasTitleShow(nUId)
  self:RefreshDownloadUIShow(nUId, tUserData, tFriendData)
end
function CoupleAvatar_UIBP:CheckIsShowHideRoleTip(nUId, tRoleData)
  local tCoupleAvatarCfg = self._tCoupleAvatarCfg or {}
  if not (tCoupleAvatarCfg.bCheckIsShow and nUId) or not tRoleData then
    return false
  end
  local bIsSelf = tostring(nUId) == tostring(DataMgr.roleData.uid)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if not bIsSelf then
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local isShow = not SettingUtil.OnlyFriend(nUId, tRoleData.bshow, 1)
      log(bWriteLog and "CoupleAvatar_UIBP:CheckIsShowHideRoleTip", isShow)
      return isShow
    else
      return false
    end
  elseif bIsSelf or tRoleData.bshow then
    return false
  end
  return true
end
function CoupleAvatar_UIBP:CheckIsShowDownloadUI(nUId, tRoleData)
  if not nUId or not tRoleData then
    return false
  end
  local bIsSelf = tostring(nUId) == tostring(DataMgr.roleData.uid)
  if bIsSelf then
    return true
  else
    return tRoleData.bshow
  end
end
function CoupleAvatar_UIBP:GetProfileData(nUId)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local tProfile = logic_profile:GetLocalProfile(nUId)
  local nProfileGetType = self._tCoupleUICfg.nProfileGetType
  if not tProfile and nProfileGetType then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({nUId}, function(tList)
      if not self.UIRoot or not slua.isValid(self.UIRoot) then
        return
      end
      local _, tCurProfile = next(tList)
      if not tCurProfile then
        return
      end
      local nCurUId = tonumber(tCurProfile.uid)
      if self._nUId == nCurUId then
        self:RefreshAliasTitleShow(nCurUId)
      end
    end, nProfileGetType)
  end
  return tProfile
end
function CoupleAvatar_UIBP:DownloadDataHandler(tDownloadList, tUserData)
  if not tUserData or not tUserData.wear then
    return
  end
  for _, v in pairs(tUserData.wear) do
    if 0 < v then
      table.insert(tDownloadList, v)
    end
  end
end
function CoupleAvatar_UIBP:AdaptAvatarErrorDebugLog()
  log(bWriteLog and " CoupleAvatar_UIBP:AdaptAvatar ViewportPos is 0,0")
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = self.UIRoot.CanvasPanel_Root:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  local sMsg = string.format(" CoupleAvatar_UIBP:AdaptAvatar LocalSize is (%f, %f)", LocalSize.X, LocalSize.Y)
  log(bWriteLog and sMsg)
  local node_parentWidget = self.UIRoot:GetParent()
  if slua.isValid(node_parentWidget) then
    local TempGeometry = node_parentWidget:GetCachedGeometry()
    local TempLocalSize = SlateBlueprintLibrary.GetLocalSize(TempGeometry)
    local sLogMsg = string.format(" CoupleAvatar_UIBP:AdaptAvatar Root Parent LocalSize is (%f, %f)", TempLocalSize.X, TempLocalSize.Y)
    log(bWriteLog and sLogMsg)
    sMsg = sMsg .. "\n" .. sLogMsg
    sLogMsg = " CoupleAvatar_UIBP:AdaptAvatar Root Parent Is >>> " .. tostring(node_parentWidget)
    sMsg = sMsg .. "\n" .. sLogMsg
    log(bWriteLog and sLogMsg)
    local cObj_ui = self:GetParentUI()
    if cObj_ui then
      sLogMsg = " CoupleAvatar_UIBP:AdaptAvatar  Parent BPPath Is >>>" .. tostring(cObj_ui._bpPath)
      sMsg = sMsg .. "\n" .. sLogMsg
      log(bWriteLog and sLogMsg)
    end
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Xpcall, sMsg, false)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCoupleAvatar_UIBP = class(ui_base, nil, CoupleAvatar_UIBP)
return CCoupleAvatar_UIBP
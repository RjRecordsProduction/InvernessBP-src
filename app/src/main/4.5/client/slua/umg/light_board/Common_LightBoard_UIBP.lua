local Common_LightBoard_UIBP = {}
function Common_LightBoard_UIBP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_LIGHT_BOARD_LEVEL_CHANGE, self.OnLightBoardLevelChange, self)
  self:AddCommonEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_NEW_LIGHT_BOARD_EQUIP, self.OnNewLightBoardEquip, self)
  self:AddCommonEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_MODIFY_NICK_NAME_SUCCESS, self.OnNickNameChange, self)
  self:AddCommonEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_EQUIP_LIGHT_BOARD_RSP, self.OnLightBoardEquip, self)
  self:AddCommonEvent(EVENTTYPE_LIGHT_BOARD, EVENTID_TEAM_UNEQUIP_LIGHT_BOARD_RSP, self.OnLightBoardUnEquip, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
end
function Common_LightBoard_UIBP:OnClose()
  self:ResetParam()
end
function Common_LightBoard_UIBP:ResetParam()
  log(bWriteLog and "[v_wllwu] Common_LightBoard_UIBP:ResetParam")
  self.uid = nil
  self.parentWidget = nil
  self.lightBoardInfo = nil
  self.isNeedRequestProfile = nil
  self:_ClearItem()
end
function Common_LightBoard_UIBP:_ClearItem()
  if self.cObj_ui then
    self.cObj_ui:Close()
    self.cObj_ui = nil
  end
end
function Common_LightBoard_UIBP:OnLightBoardLevelChange()
  log(bWriteLog and "Common_LightBoard_UIBP:OnLightBoardLevelChange")
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:ShowMyLightBoard()
end
function Common_LightBoard_UIBP:OnNewLightBoardEquip()
  log(bWriteLog and "Common_LightBoard_UIBP:OnNewLightBoardEquip")
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:ShowMyLightBoard()
end
function Common_LightBoard_UIBP:OnNickNameChange()
  log(bWriteLog and "Common_LightBoard_UIBP:OnNickNameChange")
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:ShowMyLightBoard()
end
function Common_LightBoard_UIBP:OnLightBoardEquip()
  log(bWriteLog and "Common_LightBoard_UIBP:OnLightBoardEquip")
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:ShowMyLightBoard()
end
function Common_LightBoard_UIBP:OnLightBoardUnEquip()
  log(bWriteLog and "Common_LightBoard_UIBP:OnLightBoardUnEquip")
  if self.uid ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:UpdateSelfVisible(false)
end
function Common_LightBoard_UIBP:OnDownloadFinish(_, _, eventData)
  if not eventData then
    return
  end
  local pakName = eventData.pakName
  if pakName == nil then
    return
  end
  if self.needDownloadPak ~= pakName then
    return
  end
  log_format("Common_LightBoard_UIBP:OnDownloadFinish. pakName=%s", pakName)
  self:UpdateLightBoardUI(self.curShowBpPath)
end
function Common_LightBoard_UIBP:ShowLightBoard(uid, parentWidget, lightBoardInfo, isNeedRequestProfile)
  log(bWriteLog and "Common_LightBoard_UIBP:ShowEquipLightBoard:" .. tostring(uid) .. ", isNeedRequestProfile:" .. tostring(isNeedRequestProfile))
  uid = uid or 0
  self.uid = tonumber(uid) or 0
  self.  self.  self.  if 0 >= self.uid then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowEquipLightBoard invalid uid")
    self:UpdateSelfVisible(false)
    return
  end
  if self:IsSelf(uid) then
    self:ShowMyLightBoard()
  else
    self:ShowOtherLightBoard(uid)
  end
end
function Common_LightBoard_UIBP:UpdateSelfVisible(bShow)
  if bShow then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.parentWidget then
      self.parentWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  else
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.parentWidget then
      self.parentWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function Common_LightBoard_UIBP:ShowLightBoardBluePrint(season, level)
  self.needDownloadPak = nil
  local id = 1000 * season + level
  log(bWriteLog and "Common_LightBoard_UIBP:ShowLightBoardBluePrint id:" .. tostring(id))
  local lightBoardCfg = CDataTable.GetTableData("LightBoardCfg", id)
  local bpPath = lightBoardCfg and lightBoardCfg.BPPath or ""
  local itemID = lightBoardCfg and lightBoardCfg.ItemID or nil
  log(bWriteLog and string.format("Common_LightBoard_UIBP:ShowLightBoardBluePrint bpPath:%s", tostring(bpPath)))
  log(bWriteLog and string.format("Common_LightBoard_UIBP:ShowLightBoardBluePrint itemID:%s", tostring(itemID)))
  self:UpdateLightBoardUI(bpPath)
end
function Common_LightBoard_UIBP:UpdateLightBoardUI(bpPath)
  if bpPath == "" or bpPath == nil then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowLightBoardBluePrint invalid lightBoardCfg")
    return
  end
  if self.cObj_ui and self.cObj_ui._bpPath == bpPath then
    self:PlayLightBoardAnim()
    log(bWriteLog and "Common_LightBoard_UIBP:ShowLightBoardBluePrint same bpPath")
    return
  end
  self:_ClearItem()
  local pak_util = require("client.common.pak_util")
  self.curShowBpPath = bpPath
  if pak_util.IsFileExist(bpPath) then
    self.cObj_ui = self:CreateChildWindowWithBpPath(self.CanvasPanel_AttachBP, UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP, bpPath)
    if self.cObj_ui then
      self:PlayLightBoardAnim()
    end
  else
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local pakName = PufferManager.GetPakName(bpPath)
    if pakName ~= "" then
      self.needDownloadPak = pakName
      local PufferConst = require("client.slua.logic.download.puffer_const")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        self.needDownloadPak
      })
    end
  end
end
function Common_LightBoard_UIBP:PlayLightBoardAnim()
  if self.cObj_ui and self.cObj_ui.UIRoot and self.cObj_ui.UIRoot.effect then
    self.cObj_ui:PlayUserWidgetAnimation(self.cObj_ui.UIRoot.effect, 0, 0, 0, 1)
  end
end
function Common_LightBoard_UIBP:ShowMyLightBoard()
  local logic_light_board = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_light_board)
  local lightBoardEquipped = logic_light_board:GetLightBoardEquipped()
  if not lightBoardEquipped then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowMyLightBoard not equipped")
    self:UpdateSelfVisible(false)
    return
  end
  if self:IsExpire(lightBoardEquipped.expire_ts) then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowMyLightBoard expire")
    self:UpdateSelfVisible(false)
    return
  end
  log_tree(bWriteLog and "Common_LightBoard_UIBP:ShowMyLightBoard lightBoardEquipped:", lightBoardEquipped)
  self:UpdateSelfVisible(true)
  self.TextBlock_Name:SetText(lightBoardEquipped.nick_name or "")
  self.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  self:ShowLightBoardBluePrint(lightBoardEquipped.season, lightBoardEquipped.level)
end
function Common_LightBoard_UIBP:ShowOtherLightBoard(uid)
  uid = tonumber(uid)
  if self.lightBoardInfo then
    log(bWriteLog and "[v_wllwu] Common_LightBoard_UIBP:ShowOtherLightBoard, use param data ")
    self:ShowOtherLightBoardByData(self.lightBoardInfo)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    log(bWriteLog and "[v_wllwu] Common_LightBoard_UIBP:ShowOtherLightBoard, use profile data ")
    self:ShowOtherLightBoardByProfile(profile)
    return
  end
  if not self.isNeedRequestProfile then
    log(bWriteLog and "[v_wllwu] Common_LightBoard_UIBP:ShowOtherLightBoard, dont need request profile")
    self:UpdateSelfVisible(false)
    return
  end
  log(bWriteLog and "[v_wllwu] Common_LightBoard_UIBP:ShowOtherLightBoard, request get profile")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
    if self and self.uid and list[1] and list[1].uid == self.uid then
      self:ShowOtherLightBoardByProfile(list[1])
    end
  end, Enum_PROFILE_REPORT_CFG.LIGHT_BOARD, 0, true)
end
function Common_LightBoard_UIBP:ShowOtherLightBoardByData(light_board_info)
  if not light_board_info or not next(light_board_info) then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowOtherLightBoardByData not data")
    self:UpdateSelfVisible(false)
    return
  end
  log_tree(bWriteLog and "Common_LightBoard_UIBP:ShowOtherLightBoardByProfile light_board_info:", light_board_info)
  if self:IsExpire(light_board_info.expire_ts) then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowOtherLightBoardByProfile expire")
    self:UpdateSelfVisible(false)
    return
  end
  self:UpdateSelfVisible(true)
  self.TextBlock_Name:SetText(light_board_info.nick_name or "")
  self.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
  self:ShowLightBoardBluePrint(light_board_info.season, light_board_info.level)
end
function Common_LightBoard_UIBP:ShowOtherLightBoardByProfile(profile)
  if not profile or not profile.light_board_info then
    log(bWriteLog and "Common_LightBoard_UIBP:ShowOtherLightBoardByProfile not equipped")
    self:UpdateSelfVisible(false)
    return
  end
  local light_board_info = profile.light_board_info
  self:ShowOtherLightBoardByData(light_board_info)
end
function Common_LightBoard_UIBP:IsSelf(uid)
  return uid ~= nil and tonumber(uid) == tonumber(DataMgr.roleData.uid)
end
function Common_LightBoard_UIBP:IsExpire(expire_ts)
  if not expire_ts or expire_ts == 0 then
    return false
  end
  local tNow = FuncUtil.GetServerTimeInSec()
  log(bWriteLog and "Common_LightBoard_UIBP:IsExpire tNow:" .. tostring(tNow))
  log(bWriteLog and "Common_LightBoard_UIBP:IsExpire expire_ts:" .. tostring(expire_ts))
  return expire_ts <= tNow
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_LightBoard_UIBP)
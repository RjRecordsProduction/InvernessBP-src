local logic_lobby_toy = {}
function logic_lobby_toy:DefineAndResetData()
  self.loadEffectTimer = nil
  self.playActionTimer = nil
  self.effectParticle = nil
  self.bPreview = false
  self.shopEffectTimer = nil
  self.shopActionTimer = nil
  self.shopParticle = nil
end
function logic_lobby_toy:OnInitialize()
end
function logic_lobby_toy:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_OPEN_LOBBY, self.TxMissionUpdate, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_LOBBY, self.TxMissionUpdate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_THEME, EVENTID_LOBBY_THEME_PREVIEW, self.ThemePreview, self)
end
function logic_lobby_toy:OnPreSwitchGameStatus(preState, nextState)
  self:ClearEffect()
  self:ShopClear()
end
function logic_lobby_toy:ShowToyEffect(uid, res_id, target_uid_list, bPreview)
  log(bWriteLog and string.format("logic_lobby_toy:ShowToyEffect %s %s %s", tostring(uid), tostring(res_id), tostring(bPreview)))
  self.bPreview = bPreview == true
  local action_id = 12220066
  local config = self:GetToyConfig(res_id)
  if not config then
    log(bWriteLog and "logic_lobby_toy:ShowToyEffect not config " .. tostring(res_id))
    return
  end
  if config.preActionId then
    action_id = config.preActionId
  end
  if config.selfUseAction then
    for k, target_uid in pairs(target_uid_list) do
      if target_uid == uid then
        action_id = config.selfUseAction
        target_uid_list[k] = nil
        break
      end
    end
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  local IsInXMission = XMissionSystem.IsInXMission()
  if IsInXMission then
    local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
    XMissionAvatarMgr.PlayAction(uid, action_id)
  else
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.PlayEmoteAction(uid, action_id)
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {action_id})
  if downloadState ~= ENUM_DownloadState.Done then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {action_id})
    log(bWriteLog and "logic_lobby_toy:ShowToyEffect Download action_id = " .. tostring(action_id))
  end
  self:ClearEffect()
  if target_uid_list then
    for _, target_uid in pairs(target_uid_list) do
      self:PlayEffectByResID(target_uid, res_id)
    end
  else
    log_error(bWriteLog and "logic_lobby_toy:ShowToyEffect not target_uid_list")
  end
  if tostring(uid) ~= DataMgr.roleData.uid then
    local nickName = ""
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
    nickName = memberInfo and memberInfo.name or ""
    local itemName = ""
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfg = CDataTable.GetTableData("Item", res_id)
    itemName = itemCfg and itemCfg.ItemName or ""
    local locKey = 66636
    for _, v in pairs(target_uid_list) do
      if tostring(v) ~= tostring(uid) then
        locKey = 67882
        break
      end
    end
    ShowNotice(LocUtil.LocalizeResFormat(locKey, nickName, itemName))
  end
end
function logic_lobby_toy:PlayEffectByResID(uid, res_id)
  log(bWriteLog and "logic_lobby_toy:PlayEffectByResID " .. tostring(res_id))
  local config = self:GetToyConfig(res_id)
  if not config then
    return
  end
  if config.actionId and config.actionId ~= 0 then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    local IsInXMission = XMissionSystem.IsInXMission()
    local avatar
    if IsInXMission then
      local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
      avatar = XMissionAvatarMgr.avatars[tostring(uid)]
    else
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      avatar = TeamAvatarManager.GetAvatarByUid(uid)
    end
    if avatar then
      avatar:PreparePlayAction(config.actionId)
    else
      log(bWriteLog and "logic_lobby_toy:PlayEffectByResID PreparePlayAction avatar not found " .. tostring(uid))
    end
    self.playActionTimer = self:AddTimer(config.actionBeginTime or 0, function()
      if avatar then
        avatar:GetModel():MarkDelayShowWeapon()
      end
      if IsInXMission then
        local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
        XMissionAvatarMgr.PlayAction(uid, config.actionId)
      else
        local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
        LobbyAvatarManager.PlayEmoteAction(uid, config.actionId)
      end
    end)
  end
  if not config.effectPath then
    return
  end
  self.loadEffectTimer = self:AddTimer(config.effectBeginTime or 0, function()
    log(bWriteLog and "logic_lobby_toy:PlayEffectByResID begin load effect")
    local Util = require("client.slua_ui_framework.util")
    local UGameplayStatics = import("GameplayStatics")
    Util.GetAssetAsync(config.effectPath, function(uParticle)
      log(bWriteLog and "logic_lobby_toy:PlayEffectByResID load effect finish")
      local world = slua_GameFrontendHUD:GetWorld()
      if slua.isValid(uParticle) and slua.isValid(world) then
        local location = config.effectLocation
        if config.effectLocInTeam then
          local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
          if Lobby_camera_manager_module:GetCurrentCameraID() == 10002 then
            location = config.effectLocInTeam
          end
        end
        if config.effectLocInTXMission then
          local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
          if LogicTxMissionMain.IsInXMission() then
            location = config.effectLocInTXMission
          end
        end
        self.effectParticle = UGameplayStatics.SpawnEmitterAtLocation(world, uParticle, location or FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), true)
      end
    end)
  end)
end
function logic_lobby_toy:GetToyConfig(res_id)
  local config = require("client.slua.logic.lobby_toy.lobby_toy_config")
  return config[res_id]
end
function logic_lobby_toy:IsPreview()
  return self.bPreview
end
function logic_lobby_toy:ClearEffect()
  log(bWriteLog and "logic_lobby_toy:ClearEffect")
  if self.loadEffectTimer then
    self:RemoveTimer(self.loadEffectTimer)
    self.loadEffectTimer = nil
  end
  if slua.isValid(self.effectParticle) then
    self.effectParticle:Deactivate()
    self.effectParticle:K2_DestroyComponent(self.effectParticle)
    self.effectParticle = nil
  end
  if self.playActionTimer then
    self:RemoveTimer(self.playActionTimer)
    self.playActionTimer = nil
  end
end
function logic_lobby_toy:TxMissionUpdate()
  log(bWriteLog and "logic_lobby_toy:TxMissionUpdate")
  self:ClearEffect()
end
function logic_lobby_toy:ThemePreview()
  log(bWriteLog and "logic_lobby_toy:ThemePreview")
  self:ClearEffect()
end
function logic_lobby_toy:CheckDownloadStatus(res_id, tips)
  local config = self:GetToyConfig(res_id)
  if not config then
    log(bWriteLog and "logic_lobby_toy:CheckDownloadStatus not config " .. tostring(res_id))
    return true
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local keyList = {}
  if config.preActionId then
    table.insert(keyList, config.preActionId)
  end
  if config.actionId then
    table.insert(keyList, config.actionId)
  end
  if config.selfUseAction then
    table.insert(keyList, config.selfUseAction)
  end
  local emoteState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, keyList)
  if emoteState ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "logic_lobby_toy:CheckDownloadStatus " .. tostring(res_id))
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, keyList)
    if tips then
      ShowNotice(tips)
    end
    return false
  end
  return true
end
function logic_lobby_toy:ShopPreviewItem(res_id)
  log(bWriteLog and string.format("logic_lobby_toy:ShopPreviewItem %s", tostring(res_id)))
  local action_id = 12220066
  local config = self:GetToyConfig(res_id)
  if config and config.preActionId then
    action_id = config.preActionId
  end
  if config and config.selfUseAction then
    action_id = config.selfUseAction
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(action_id)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {action_id})
  if downloadState ~= ENUM_DownloadState.Done then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {action_id})
    log(bWriteLog and "logic_lobby_toy:ShopPreviewItem Download action_id = " .. tostring(action_id))
  end
  self:ShopClear()
  if not config then
    return
  end
  if not config.selfUseAction and config.actionId and config.actionId ~= 0 then
    local avatar = ModelDisplayer.GetShowingAvatar()
    if avatar then
      avatar:PreparePlayAction(config.actionId)
    else
      log(bWriteLog and "logic_lobby_toy:ShopPreviewItem PreparePlayAction avatar not found " .. tostring(uid))
    end
    self.shopActionTimer = self:AddTimer(config.actionBeginTime or 0, function()
      ModelDisplayer.Display(config.actionId)
    end)
  end
  if not config.effectPath then
    return
  end
  self.shopEffectTimer = self:AddTimer(config.effectBeginTime or 0, function()
    log(bWriteLog and "logic_lobby_toy:ShopPreviewItem begin load effect")
    local Util = require("client.slua_ui_framework.util")
    local UGameplayStatics = import("GameplayStatics")
    Util.GetAssetAsync(config.effectPath, function(uParticle)
      log(bWriteLog and "logic_lobby_toy:PlayEffectByResID load effect finish")
      local world = slua_GameFrontendHUD:GetWorld()
      if slua.isValid(uParticle) and slua.isValid(world) then
        local location = config.effectLocation
        if config.effectLocInShop then
          location = config.effectLocInShop
        end
        self.shopParticle = UGameplayStatics.SpawnEmitterAtLocation(world, uParticle, location or FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), true)
      end
    end)
  end)
end
function logic_lobby_toy:ShopClear()
  log(bWriteLog and "logic_lobby_toy:ShopClear")
  if self.shopEffectTimer then
    self:RemoveTimer(self.shopEffectTimer)
    self.shopEffectTimer = nil
  end
  if slua.isValid(self.shopParticle) then
    self.shopParticle:Deactivate()
    self.shopParticle:K2_DestroyComponent(self.shopParticle)
    self.shopParticle = nil
  end
  if self.shopActionTimer then
    self:RemoveTimer(self.shopActionTimer)
    self.shopActionTimer = nil
  end
end
function logic_lobby_toy:send_use_fun_prop_req(inst_id, count, target_uid_list)
  log(bWriteLog and "logic_lobby_toy:send_use_fun_prop_req: " .. tostring(inst_id))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_use_fun_prop_req(inst_id, count, target_uid_list)
end
function logic_lobby_toy:on_use_fun_prop_rsp(res, inst_id, count, target_uid_list)
  log(bWriteLog and string.format("logic_lobby_toy:on_use_fun_prop_rsp: %s  %s  %s", tostring(res), tostring(inst_id), tostring(count)))
  if res ~= "ok" then
    if res == "team_cd" then
      ShowNotice(69034)
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY_TOY, EVENTID_LOBBY_TOY_USE, inst_id, count, target_uid_list)
end
function logic_lobby_toy:on_notify_player_use_fun_prop(team_id, uid, res_id, target_uid_list)
  log(bWriteLog and string.format("logic_lobby_toy:on_notify_player_use_fun_prop %s %s %s", tostring(team_id), tostring(uid), tostring(res_id)))
  self:ShowToyEffect(uid, res_id, target_uid_list)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_toy = class(CModuleBase, nil, logic_lobby_toy)
return Clogic_lobby_toy
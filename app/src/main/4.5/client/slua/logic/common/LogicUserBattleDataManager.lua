local LogicUserBattleDataManager = {
  bigIconCheckResults = {}
}
function LogicUserBattleDataManager:DefineAndResetData()
  self.bShowEffect = false
  self.bShowEffectDirty = false
  self.HideBagSetting = nil
  self.HideFaceSetting = nil
  self.HideScrollSetting = nil
end
function LogicUserBattleDataManager:OnPreSwitchGameStatus(preState, nextState)
  self:HandleEmoteEffect(preState, nextState)
  if preState == GameStatus.Fighting or nextState == GameStatus.Fighting then
    self.bigIconCheckResults = {}
  end
end
function LogicUserBattleDataManager:HandleEmoteEffect(preState, nextState)
  log(bWriteLog and "[ParticleEmote] OnPreSwitchGameStatus preState " .. tostring(preState) .. " nextState " .. tostring(nextState))
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    logic_emote.SetShowEffect(DataMgr.show_effect)
  elseif preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    if logic_emote.bShowEffectDirty then
      local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
      LogicParticleEmote:send_effect_motion_setting_req(logic_emote.GetShowEffect_Battle())
      logic_emote.bShowEffectDirty = false
    end
  end
end
function LogicUserBattleDataManager:LoadHideBagSettingData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.HideBagSetting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHideBagSetting) or {}
end
function LogicUserBattleDataManager:SetHideBagData(ItemID, HideBag)
  if not self.HideBagSetting then
    self:LoadHideBagSettingData()
  end
  self.HideBagSetting[ItemID] = HideBag
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.HideBagSetting, PlayerPrefsSystem.ePlayerPrefsType.eHideBagSetting)
end
function LogicUserBattleDataManager:GetHideBagSetting(ItemID)
  if not self.HideBagSetting then
    self:LoadHideBagSettingData()
  end
  return self.HideBagSetting[ItemID]
end
function LogicUserBattleDataManager:LoadHideFaceSettingData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.HideFaceSetting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHideFaceSetting) or {}
end
function LogicUserBattleDataManager:GetHideSlotConfig(ItemID)
  return CDataTable.GetTableData("AvatarHideSlotConfig", ItemID)
end
function LogicUserBattleDataManager:SetHideSlotData(GroupID, HideFace)
  if not self.HideFaceSetting then
    self:LoadHideFaceSettingData()
  end
  self.HideFaceSetting[GroupID] = HideFace
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.HideFaceSetting, PlayerPrefsSystem.ePlayerPrefsType.eHideFaceSetting)
end
function LogicUserBattleDataManager:GetHideSlotSetting(GroupID)
  if not self.HideFaceSetting then
    self:LoadHideFaceSettingData()
  end
  return self.HideFaceSetting[GroupID]
end
function LogicUserBattleDataManager:LoadHideScrollSettingData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.HideScrollSetting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHideScrollSetting) or {}
end
function LogicUserBattleDataManager:SetHideScrollData(ItemID, HideScroll)
  if not self.HideScrollSetting then
    self:LoadHideScrollSettingData()
  end
  self.HideScrollSetting[ItemID] = HideScroll
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.HideScrollSetting, PlayerPrefsSystem.ePlayerPrefsType.eHideScrollSetting)
end
function LogicUserBattleDataManager:GetHideScrollSetting(ItemID)
  if not self.HideScrollSetting then
    self:LoadHideScrollSettingData()
  end
  return self.HideScrollSetting[ItemID]
end
function LogicUserBattleDataManager:HasBigIconDownloaded(ItemID)
  if self.bigIconCheckResults[ItemID] ~= nil then
    return self.bigIconCheckResults[ItemID]
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  local pak_util = require("client.common.pak_util")
  if itemCfg and itemCfg.ItemBigIcon and itemCfg.ItemBigIcon ~= "" then
    self.bigIconCheckResults[ItemID] = pak_util.IsFileExist(itemCfg.ItemBigIcon)
  else
    self.bigIconCheckResults[ItemID] = false
  end
  return self.bigIconCheckResults[ItemID]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicUserBattleDataManager)
return CModuleTemplate
local PlayerControllerBattleFlagOBArmorFeature = {}
local BattleFlagConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.BattleFlagConfig")
function PlayerControllerBattleFlagOBArmorFeature:ctor()
  print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:ctor")
  self.CurCharacter = nil
end
function PlayerControllerBattleFlagOBArmorFeature:ReceiveBeginPlay()
  PlayerControllerBattleFlagOBArmorFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:ReceiveBeginPlay")
  if Client then
    if self.Owner and slua.isValid(self.Owner.Object) then
      self:AddControlEvent(self.Owner.Object, "OnSpectatorChange", self.OnSpectatorChange_Handle, self)
    end
    self:OnSpectatorChange_Handle()
  end
end
function PlayerControllerBattleFlagOBArmorFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:ReceiveEndPlay")
  self:UnbindCharacterBuffEvents()
  self:CloseArmorUI()
  PlayerControllerBattleFlagOBArmorFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerControllerBattleFlagOBArmorFeature:OnSpectatorChange_Handle()
  print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnSpectatorChange_Handle")
  self:UnbindCharacterBuffEvents()
  local uPlayerController = self.Owner and self.Owner.Object
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnSpectatorChange_Handle - PlayerController invalid")
    return
  end
  if not uPlayerController:IsSpectator() then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnSpectatorChange_Handle - is not IsSpectator")
    self:CloseArmorUI()
    return
  end
  local uCurCharacter = uPlayerController:GetCurPlayerCharacter()
  if not slua.isValid(uCurCharacter) then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnSpectatorChange_Handle - CurCharacter invalid")
    self:CloseArmorUI()
    return
  end
  self.CurCharacter = uCurCharacter
  self:BindCharacterBuffEvents(uCurCharacter)
  self:CheckAndRefreshArmorUI(uCurCharacter)
end
function PlayerControllerBattleFlagOBArmorFeature:BindCharacterBuffEvents(uCharacter)
  if not slua.isValid(uCharacter) then
    return
  end
  local BuffSystem = uCharacter.BuffSystem
  if not slua.isValid(BuffSystem) then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:BindCharacterBuffEvents - BuffSystem invalid")
    return
  end
  self:AddControlEvent(BuffSystem, "OnClientAddBuffEvent", self.OnClientAddBuff, self)
  self:AddControlEvent(BuffSystem, "OnClientRemoveBuffEvent", self.OnClientRemoveBuff, self)
end
function PlayerControllerBattleFlagOBArmorFeature:UnbindCharacterBuffEvents()
  if not slua.isValid(self.CurCharacter) then
    self.CurCharacter = nil
    return
  end
  local BuffSystem = self.CurCharacter.BuffSystem
  if slua.isValid(BuffSystem) then
    self:RemoveControlEvent(BuffSystem, "OnClientAddBuffEvent")
    self:RemoveControlEvent(BuffSystem, "OnClientRemoveBuffEvent")
  end
  self.CurCharacter = nil
end
function PlayerControllerBattleFlagOBArmorFeature:OnClientAddBuff(BuffID, SkillID, InstID)
  if BuffID == BattleFlagConfig.ArmorBuffID then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnClientAddBuff - ArmorBuff added")
    self:ShowArmorUI()
  end
end
function PlayerControllerBattleFlagOBArmorFeature:OnClientRemoveBuff(BuffID, SkillID, InstID)
  if BuffID == BattleFlagConfig.ArmorBuffID then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:OnClientRemoveBuff - ArmorBuff removed")
    self:CloseArmorUI()
  end
end
function PlayerControllerBattleFlagOBArmorFeature:CheckAndRefreshArmorUI(uCharacter)
  if not slua.isValid(uCharacter) then
    self:CloseArmorUI()
    return
  end
  if uCharacter:HasBuffID(BattleFlagConfig.ArmorBuffID) then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:CheckAndRefreshArmorUI - HasArmorBuff, show UI")
    self:ShowArmorUI()
  else
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:CheckAndRefreshArmorUI - NoArmorBuff, close UI")
    self:CloseArmorUI()
  end
end
function PlayerControllerBattleFlagOBArmorFeature:ShowArmorUI()
  if not UIManager then
    return
  end
  local UIConfig = UIManager.UI_Config_InGame.BattleFlagOBArmorUI
  if UIConfig and not UIManager.IsUIShow(UIConfig) then
    print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:ShowArmorUI")
    UIManager.ShowUI(UIConfig)
  end
  local ScreenUIConfig = UIManager.UI_Config_InGame.BattleFlagScreenArmorUI
  if ScreenUIConfig and not UIManager.IsUIShow(ScreenUIConfig) then
    print(bWriteLog and "BuffAction_BattleFlagArmor:LuaOnExecute - ShowUI BattleFlagScreenArmorUI")
    UIManager.ShowUI(ScreenUIConfig)
  end
end
function PlayerControllerBattleFlagOBArmorFeature:CloseArmorUI()
  if not UIManager then
    return
  end
  local UIConfig = UIManager.UI_Config_InGame.BattleFlagOBArmorUI
  if UIConfig then
    local UI = UIManager.GetUI(UIConfig)
    if UI then
      print(bWriteLog and "PlayerControllerBattleFlagOBArmorFeature:CloseArmorUI")
      UIManager.CloseUI(UIConfig)
    end
  end
  local ScreenUIConfig = UIManager.UI_Config_InGame.BattleFlagScreenArmorUI
  if ScreenUIConfig then
    print(bWriteLog and "BuffAction_BattleFlagArmor:LuaOnEnd - CloseUI BattleFlagScreenArmorUI")
    UIManager.CloseUI(ScreenUIConfig)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerControllerBattleFlagOBArmorFeature)
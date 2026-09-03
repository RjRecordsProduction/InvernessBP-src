local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local AICommandSubsystem = {}
function AICommandSubsystem:ctor()
  print(bWriteLog and "AICommandSubsystem:ctor")
  AICommandSubsystem.__super.ctor(self)
  self.CommandUIMap = {}
  self.bEnterFighting = false
end
function AICommandSubsystem:OnInit()
  print(bWriteLog and "AICommandSubsystem:OnInit")
  AICommandSubsystem.__super.OnInit(self)
  self:CheckMercenaryHire()
  self:RegistEvents()
end
function AICommandSubsystem:CheckMercenaryHire()
  print(bWriteLog and "AICommandSubsystem:CheckMercenaryHire")
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) and PlayerCharacter.MercenaryFeature and PlayerCharacter.MercenaryFeature.HiredInfo then
    local HiredInfo = PlayerCharacter.MercenaryFeature.HiredInfo
    if HiredInfo:Num() >= 2 then
      local ResId = HiredInfo:Get(0)
      if ResId ~= nil and 0 < ResId then
        local bIsHireSuccess = HiredInfo:Get(1)
        if bIsHireSuccess == 0 then
          bIsHireSuccess = false
        else
          bIsHireSuccess = true
        end
        self:OnMercenaryHire(nil, nil, ResId, bIsHireSuccess)
        print(bWriteLog and "PlayerCharacterMercenaryFeature:OnRep_HiredInfo is called before AICommandSubsystem:OnInit")
      end
    end
  end
end
function AICommandSubsystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_MERCENARY_HIRE, self.OnMercenaryHire, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_PLAYER_STATE_DUNGEON_ID_CHANGED, self.OnEnterDungeon, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.OnEnterBattleResult, self)
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_WATCH_TO_RESULT, self.OnEnterBattleResult, self)
end
function AICommandSubsystem:OnRelease()
  AICommandSubsystem.__super.OnRelease(self)
  for AIPlayerResID, CommandUI in pairs(self.CommandUIMap) do
    CommandUI:Close()
    self.CommandUIMap[AIPlayerResID] = nil
  end
end
function AICommandSubsystem:OnEnterBattleResult(_, _)
  for _, CommandUI in pairs(self.CommandUIMap) do
    CommandUI:CloseSelf()
  end
  self.CommandUIMap = {}
end
function AICommandSubsystem:OnEnterDungeon(_, _, PlayerKey, DungeonId)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  if PlayerState.PlayerKey ~= PlayerKey then
    return
  end
  if not self.CommandUIMap then
    self.CommandUIMap = {}
    return
  end
  if PlayerState.IsInDungeon and PlayerState:IsInDungeon() then
    for _, CommandUI in pairs(self.CommandUIMap) do
      CommandUI:Collapsed()
    end
  else
    for _, CommandUI in pairs(self.CommandUIMap) do
      CommandUI:SelfHitTestInvisible()
    end
  end
end
function AICommandSubsystem:OnMercenaryHire(_, _, AIPlayerResID, bIsHireSuccess)
  print(bWriteLog and string.format("AICommandSubsystem:OnMercenaryHire %s %s", tostring(AIPlayerResID), tostring(bIsHireSuccess)))
  local bEnterFighting = CGameState:GetGameModeState() == "FightingState"
  if not bEnterFighting then
    self:OnEnterBattleResult(nil, nil)
    return
  end
  local AICommandConfig = GamePlayTools.GetCurrentConfig("AICommandConfig")
  if AICommandConfig and AICommandConfig[AIPlayerResID] then
    local AIPlayerConfig = AICommandConfig[AIPlayerResID]
    local CommandIcon = AIPlayerConfig.CommandIcon
    if bIsHireSuccess and CommandIcon then
      local CommandUIConfig = UIManager.UI_Config_InGame.SignUI
      if CommandUIConfig and not self.CommandUIMap[AIPlayerResID] then
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local ShootingUI = InGameUITools.GetShootingUIPanelLuaClass()
        local AICommandCanvas = ShootingUI.UIRoot.CanvasPanel_AICommand
        if AICommandCanvas then
          self.CommandUIMap[AIPlayerResID] = ShootingUI:CreateChildWindow("CanvasPanel_AICommand", CommandUIConfig, AIPlayerConfig.CommandList, CommandIcon, AIPlayerConfig.CommandTurnTableUI)
          if AICommandCanvas.Slot then
            AICommandCanvas.Slot:SetZOrder(-1)
          end
        end
        print(bWriteLog and "AICommandSubsystem:OnMercenaryHire ShowUI: SignUI")
      end
    else
      local CommandUI = self.CommandUIMap[AIPlayerResID]
      if CommandUI then
        CommandUI:CloseSelf()
        print(bWriteLog and "AICommandSubsystem:OnMercenaryHire CloseUI")
      end
      self.CommandUIMap[AIPlayerResID] = nil
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, AICommandSubsystem)
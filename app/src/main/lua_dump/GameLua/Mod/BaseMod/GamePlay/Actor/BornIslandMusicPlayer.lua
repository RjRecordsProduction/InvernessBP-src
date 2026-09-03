local BornIslandMusicPlayer = {}
local Util = require("client.slua_ui_framework.util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
function BornIslandMusicPlayer:ctor()
  self.LoadAsset = nil
end
function BornIslandMusicPlayer:ReceiveBeginPlay()
  BornIslandMusicPlayer.__super.ReceiveBeginPlay(self)
  if not Client then
    self:DestroySelf()
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.GetGameModeState then
    print(bWriteLog and "BornIslandMusicPlayer:ReceiveBeginPlay uGameState is invalid")
    self:DestroySelf()
    return
  end
  local CurrentState = uGameState:GetGameModeState()
  print(bWriteLog and "BornIslandMusicPlayer:ReceiveBeginPlay CurrentState", CurrentState)
  if CurrentState == "FightingState" or CurrentState == "FinishedState" then
    self:DestroySelf()
    return
  end
  self:InitConfig()
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameStateChange, self)
  self:AddGameTimer(60, false, function()
    self:DestroySelf()
  end)
end
function BornIslandMusicPlayer:InitConfig()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local BornIslandMusicConfig = GamePlayTools.GetCurrentConfig("BornIslandMusicConfig")
  if BornIslandMusicConfig then
    local MusicConfig = BornIslandMusicConfig.Global
    if PublishRegionMacros.IsJapanOrKorea() then
      print(bWriteLog and "BornIslandMusicPlayer:InitConfig JapanOrKorea")
      MusicConfig = BornIslandMusicConfig.JapanOrKorea
    elseif PublishRegionMacros.IsBLUEHOLE() then
      print(bWriteLog and "BornIslandMusicPlayer:InitConfig BlueHole")
      MusicConfig = BornIslandMusicConfig.BlueHole
    end
    local MusicPath = MusicConfig.BornIsland.Music
    local MusicTextID = MusicConfig.BornIsland.TextID
    local Region = Client and Client.GetPublishRegion() or "Global DS"
    print(bWriteLog and "BornIslandMusicPlayer:InitConfig MusicPath", Region, MusicPath, MusicTextID)
    if MusicPath and slua.isValid(self.Ak) then
      self.LoadAsset = Util.GetAssetAsync(MusicPath, function(AkEvent)
        print(bWriteLog and "BornIslandMusicPlayer:InitConfig AkEvent", AkEvent, self.bHasPlayedMusic, self.bDestroyed)
        if slua.isValid(AkEvent) and Client and slua.isValid(self.Ak) and not self.bHasPlayedMusic and not self.bDestroyed then
          self.Ak.AkAudioEvent = AkEvent
          self.Ak:PostAssociatedAkEventInRange()
          self.bHasPlayedMusic = true
        end
      end)
    end
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
    local MusicUIConfig = BornIslandMusicConfig.MusicUI
    if Client and MusicUIConfig and UIManager.UI_Config_InGame[MusicUIConfig] and MainControlBaseUI then
      MainControlBaseUI:CreateChildWindow("CanvasPanel_1", UIManager.UI_Config_InGame[MusicUIConfig], MusicTextID)
      local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
      if DataLayerSubsystem then
        print(bWriteLog and "BornIslandMusicPlayer:InitConfig - Set InBornIslandMusicPlayer false")
        DataLayerSubsystem:UpdateSuperDataValue("InBornIslandMusicPlayer", true)
      end
    end
  end
end
function BornIslandMusicPlayer:OnGameStateChange(_, __, sState)
  print(bWriteLog and "BornIslandMusicPlayer:OnGameStateChange", sState)
  if sState == "FightingState" or sState == "FinishedState" then
    self:DestroySelf()
  end
end
function BornIslandMusicPlayer:DestroySelf()
  print(bWriteLog and "BornIslandMusicPlayer:DestroySelf")
  if self.LoadAsset then
    Util.ClearAssetAsync(self.LoadAsset)
  end
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if Client and DataLayerSubsystem then
    print(bWriteLog and "BornIslandMusicPlayer:OnGameStateChange - Set InBornIslandMusicPlayer false")
    DataLayerSubsystem:UpdateSuperDataValue("InBornIslandMusicPlayer", false)
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local BornIslandMusicConfig = GamePlayTools.GetCurrentConfig("BornIslandMusicConfig")
    local MusicUIConfig = BornIslandMusicConfig.MusicUI
    if MusicUIConfig and UIManager.UI_Config_InGame[MusicUIConfig] then
      UIManager.CloseUI(UIManager.UI_Config_InGame[MusicUIConfig])
    end
  end
  if Client and slua.isValid(self.Ak) then
    self.Ak:StopEventInRange()
    self.bDestroyed = true
  end
  self:AddGameTimer(0.1, false, function()
    if slua.isValid(self.Object) then
      self:K2_DestroyActor()
    end
  end)
end
function BornIslandMusicPlayer:ReceiveEndPlay(EndReason, bClearTable)
  if Client then
    local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
    if DataLayerSubsystem then
      print(bWriteLog and "BornIslandMusicPlayer:ReceiveEndPlay - Set InBornIslandMusicPlayer false")
      DataLayerSubsystem:UpdateSuperDataValue("InBornIslandMusicPlayer", false)
    end
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local BornIslandMusicConfig = GamePlayTools.GetCurrentConfig("BornIslandMusicConfig")
    local MusicUIConfig = BornIslandMusicConfig and BornIslandMusicConfig.MusicUI
    if MusicUIConfig and UIManager.UI_Config_InGame[MusicUIConfig] then
      UIManager.CloseUI(UIManager.UI_Config_InGame[MusicUIConfig])
    end
  end
  BornIslandMusicPlayer.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(CActorBase, nil, BornIslandMusicPlayer)
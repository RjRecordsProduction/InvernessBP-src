local KingEliminationInfoItem = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function KingEliminationInfoItem:ctor()
  self.bShouldFuzzyLua = false
end
function KingEliminationInfoItem:OnInitialize()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local GameState = GameplayData.GetGameState()
  if not slua.isValid(GameState) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local bIsObserver = PlayerController:IsDemoPlayGlobalObserver() or PlayerController:IsObserver()
  self.bShouldFuzzyLua = not bIsObserver and GameState.bUseFuzzyInformation
end
function KingEliminationInfoItem:UpdateKingEliminationInfo(DamageRecordData, KingEliminationInfo)
  local NewKingEliminationInfo = KingEliminationInfo.NewKingEliminationInfo
  if NewKingEliminationInfo then
    self:InitNewKingEliminationInfo(NewKingEliminationInfo, DamageRecordData)
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  local DeadKingEliminationInfo = KingEliminationInfo.DeadKingEliminationInfo
  if DeadKingEliminationInfo then
    local KillerPlayerName = DeadKingEliminationInfo.KillerPlayerName
    if self.bShouldFuzzyLua then
      KillerPlayerName = "***"
    end
    local EliminationKingPlayerName = DeadKingEliminationInfo.EliminationKingPlayerName
    if self.bShouldFuzzyLua then
      EliminationKingPlayerName = "***"
    end
    self.UIRoot.Switcher_State:SetActiveWidgetIndex(1)
    self:AdvanceActivateModCanvas(1, NewKingEliminationInfo, DamageRecordData)
    self.UIRoot.KillerPlayerName:SetText(KillerPlayerName)
    self.UIRoot.EliminateDesText:SetText(LocUtil.GetLocalizeResStr(8350006) .. " " .. LocUtil.GetLocalizeResStr(76971))
    self.UIRoot.EliminationKingPlayerName:SetText(EliminationKingPlayerName)
    self:GenerateTopKillKingEliminationTips(DeadKingEliminationInfo)
    return
  end
end
function KingEliminationInfoItem:GetImageAndEffectPath(cfg, KillCount)
  local NewLeftBgPath, NewLeftImagePath
  if 12 <= KillCount then
    if cfg.AdvancedLeftBg and cfg.AdvancedLeftBg ~= "" then
      NewLeftBgPath = cfg.AdvancedLeftBg
      NewLeftImagePath = cfg.AdvancedLeftImage
    end
  elseif 8 <= KillCount then
    if cfg.IntermediateLeftBg and cfg.IntermediateLeftBg ~= "" then
      NewLeftBgPath = cfg.IntermediateLeftBg
      NewLeftImagePath = cfg.IntermediateLeftImage
    end
  elseif 6 <= KillCount and cfg.PrimaryLeftBg and cfg.PrimaryLeftBg ~= "" then
    NewLeftBgPath = cfg.PrimaryLeftBg
    NewLeftImagePath = cfg.PrimaryLeftImage
  end
  return NewLeftImagePath, NewLeftBgPath
end
function KingEliminationInfoItem:UpdateBroadcastStyle(NewLeftImagePath, NewLeftBgPath, AnimName)
  if self.LeftBgPath ~= nil and self.LeftBgPath ~= NewLeftBgPath and self.LeftBg then
    self.LeftBg:Close()
    self.LeftBg = nil
  end
  if NewLeftImagePath then
    self:SetTexture(self.UIRoot.EffectBg, NewLeftImagePath)
  end
  if NewLeftBgPath then
    self.LeftBg = self:CreateChildWindowWithBpPath(self.UIRoot.CanvasPanel_EffectContainer, UIManager.UI_Config.ChildUIWithoutBpPath, NewLeftBgPath)
    self.LeftBgPath = NewLeftBgPath
    if AnimName and AnimName ~= "" then
      self.LeftBg:PlayUserWidgetAnimation(self.LeftBg[AnimName], 0, 1, 0, 1)
    end
  end
end
function KingEliminationInfoItem:InitNewKingEliminationInfo(NewKingEliminationInfo, DamageRecordData)
  local cfg
  if NewKingEliminationInfo.EffectID then
    cfg = CDataTable.GetTableData("EliminationKingEffectCfg", NewKingEliminationInfo.EffectID)
  end
  local DesID = 76973
  if NewKingEliminationInfo.bIsFirstEliminationKing then
    DesID = 76972
  end
  local PlayerName = NewKingEliminationInfo.PlayerName
  if self.bShouldFuzzyLua then
    PlayerName = "***"
  end
  if cfg then
    self.UIRoot.Switcher_State:SetActiveWidgetIndex(2)
    self.UIRoot.E_Part1:SetText(LocUtil.GetLocalizeResStr(DesID))
    self.UIRoot.E_Part2:SetText(PlayerName)
    self.UIRoot.E_Part3:SetText(LocUtil.LocalizeResFormat(76974, NewKingEliminationInfo.KillCount))
    self:InitLeftModCanvas(NewKingEliminationInfo, DamageRecordData)
    self:AdvanceActivateModCanvas(2, NewKingEliminationInfo, DamageRecordData)
    local NewLeftImagePath, NewLeftBgPath = self:GetImageAndEffectPath(cfg, NewKingEliminationInfo.KillCount)
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    if NewLeftImagePath and NewLeftBgPath then
      self:GetAssetListAsync({
        NewLeftImagePath,
        NewLeftBgPath .. "_C"
      }, function()
        if self and self.UIRoot then
          self:UpdateBroadcastStyle(NewLeftImagePath, NewLeftBgPath, cfg.LeftBgAnimName)
          self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
        end
      end)
    end
  else
    self.UIRoot.Switcher_State:SetActiveWidgetIndex(0)
    self.UIRoot.Part1:SetText(LocUtil.GetLocalizeResStr(DesID))
    self.UIRoot.Part2:SetText(PlayerName)
    self.UIRoot.Part3:SetText(LocUtil.LocalizeResFormat(76974, NewKingEliminationInfo.KillCount))
    self:AdvanceActivateModCanvas(0, NewKingEliminationInfo, DamageRecordData)
    self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or PlayerState.PlayerKey == nil then
    return
  end
  local KillCount = NewKingEliminationInfo.KillCount
  local KillCountLevel
  if 12 <= KillCount then
    KillCountLevel = 3
  elseif 8 <= KillCount then
    KillCountLevel = 2
  elseif 6 <= KillCount then
    KillCountLevel = 1
  end
  local StringUtil = require("common.string_util")
  local TipsID
  if PlayerState.PlayerKey == NewKingEliminationInfo.PlayerKey then
    if NewKingEliminationInfo.bIsFirstEliminationKing then
      TipsID = 12159
      if cfg and cfg.SelfFirstEliminationKingTipID and KillCountLevel then
        TipsID = tonumber(StringUtil.Split(cfg.SelfFirstEliminationKingTipID, "|")[KillCountLevel])
      end
    else
      TipsID = 12160
      if cfg and cfg.SelfNewEliminationKingTipID and KillCountLevel then
        TipsID = tonumber(StringUtil.Split(cfg.SelfNewEliminationKingTipID, "|")[KillCountLevel])
      end
    end
  elseif PlayerState.IsTeammate and PlayerState:IsTeammate(NewKingEliminationInfo.PlayerKey) then
    if NewKingEliminationInfo.bIsFirstEliminationKing then
      TipsID = 12162
      if cfg and cfg.TeammateFirstEliminationKingTipID and KillCountLevel then
        TipsID = tonumber(StringUtil.Split(cfg.TeammateFirstEliminationKingTipID, "|")[KillCountLevel])
      end
    else
      TipsID = 12163
      if cfg and cfg.TeammateNewEliminationKingTipID and KillCountLevel then
        TipsID = tonumber(StringUtil.Split(cfg.TeammateNewEliminationKingTipID, "|")[KillCountLevel])
      end
    end
  end
  print(bWriteLog and "KingEliminationInfoItem: TipsID " .. tostring(TipsID))
  if TipsID then
    IngameTipsTools.BattleGeneralTip(TipsID)
  end
end
function KingEliminationInfoItem:InitLeftModCanvas(NewKingEliminationInfo, DamageRecordData)
end
function KingEliminationInfoItem:AdvanceActivateModCanvas(SwitchIndex, NewKingEliminationInfo, DamageRecordData)
end
function KingEliminationInfoItem:GenerateTopKillKingEliminationTips(DeadKingEliminationInfo)
  if not DeadKingEliminationInfo then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) or PlayerState.PlayerKey == nil then
    return
  end
  local EliminationKingEffectID = DeadKingEliminationInfo.EffectID
  local KillCount = DeadKingEliminationInfo.KillCount
  print(bWriteLog and "KingEliminationInfoItem: EliminationKingEffectID " .. tostring(EliminationKingEffectID))
  local cfg
  if EliminationKingEffectID and EliminationKingEffectID ~= 0 then
    cfg = CDataTable.GetTableData("EliminationKingEffectCfg", EliminationKingEffectID)
  end
  local KillCountLevel
  if 12 <= KillCount then
    KillCountLevel = 3
  elseif 8 <= KillCount then
    KillCountLevel = 2
  elseif 6 <= KillCount then
    KillCountLevel = 1
  end
  local StringUtil = require("common.string_util")
  local TipsID
  if PlayerState.PlayerKey == DeadKingEliminationInfo.KillerPlayerKey then
    TipsID = 12161
    if cfg and cfg.SelfKillEliminationKingTipID and KillCountLevel then
      TipsID = tonumber(StringUtil.Split(cfg.SelfKillEliminationKingTipID, "|")[KillCountLevel])
    end
  elseif PlayerState.IsTeammate and PlayerState:IsTeammate(DeadKingEliminationInfo.KillerPlayerKey) then
    TipsID = 12164
    if cfg and cfg.TeammateKillEliminationKingTipID and KillCountLevel then
      TipsID = tonumber(StringUtil.Split(cfg.TeammateKillEliminationKingTipID, "|")[KillCountLevel])
    end
  end
  print(bWriteLog and "KingEliminationInfoItemL TipsID " .. tostring(TipsID))
  if TipsID then
    IngameTipsTools.BattleGeneralTip(TipsID)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, KingEliminationInfoItem)
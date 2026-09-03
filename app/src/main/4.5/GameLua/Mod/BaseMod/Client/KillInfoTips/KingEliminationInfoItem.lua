local KingEliminationInfoItem = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local StringUtil = require("common.string_util")
local GetKillCountLevel = function(KillCount)
  if 12 <= KillCount then
    return 3
  elseif 8 <= KillCount then
    return 2
  elseif 6 <= KillCount then
    return 1
  end
  return nil
end
local ResolveTipsID = function(DefaultTipID, cfg, FieldName, KillCountLevel)
  if not (cfg and cfg[FieldName]) or not KillCountLevel then
    return DefaultTipID
  end
  local Parsed = tonumber(StringUtil.Split(cfg[FieldName], "|")[KillCountLevel])
  return Parsed or DefaultTipID
end
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
function KingEliminationInfoItem:GetImageAndEffectPath(cfg, KillCountLevel)
  if KillCountLevel == 3 then
    if cfg.AdvancedLeftBg and cfg.AdvancedLeftBg ~= "" then
      return cfg.AdvancedLeftImage, cfg.AdvancedLeftBg
    end
  elseif KillCountLevel == 2 then
    if cfg.IntermediateLeftBg and cfg.IntermediateLeftBg ~= "" then
      return cfg.IntermediateLeftImage, cfg.IntermediateLeftBg
    end
  elseif KillCountLevel == 1 and cfg.PrimaryLeftBg and cfg.PrimaryLeftBg ~= "" then
    return cfg.PrimaryLeftImage, cfg.PrimaryLeftBg
  end
  return nil, nil
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
  local EffectID = NewKingEliminationInfo.EffectID
  if EffectID then
    cfg = CDataTable.GetTableData("EliminationKingEffectCfg", EffectID)
  end
  local KillCountLevel = GetKillCountLevel(NewKingEliminationInfo.KillCount)
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
    local NewLeftImagePath, NewLeftBgPath = self:GetImageAndEffectPath(cfg, KillCountLevel)
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    if NewLeftImagePath and NewLeftBgPath then
      self:GetAssetListAsync({
        NewLeftImagePath,
        NewLeftBgPath .. "_C"
      }, function()
        if self and slua.isValid(self.UIRoot) then
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
  local TipsID
  if PlayerState.PlayerKey == NewKingEliminationInfo.PlayerKey then
    if NewKingEliminationInfo.bIsFirstEliminationKing then
      TipsID = ResolveTipsID(12159, cfg, "SelfFirstEliminationKingTipID", KillCountLevel)
    else
      TipsID = ResolveTipsID(12160, cfg, "SelfNewEliminationKingTipID", KillCountLevel)
    end
  elseif PlayerState.IsTeammate and PlayerState:IsTeammate(NewKingEliminationInfo.PlayerKey) then
    if NewKingEliminationInfo.bIsFirstEliminationKing then
      TipsID = ResolveTipsID(12162, cfg, "TeammateFirstEliminationKingTipID", KillCountLevel)
    else
      TipsID = ResolveTipsID(12163, cfg, "TeammateNewEliminationKingTipID", KillCountLevel)
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
  print(bWriteLog and "KingEliminationInfoItem: EliminationKingEffectID " .. tostring(EliminationKingEffectID))
  local cfg
  if EliminationKingEffectID and EliminationKingEffectID ~= 0 then
    cfg = CDataTable.GetTableData("EliminationKingEffectCfg", EliminationKingEffectID)
  end
  local KillCountLevel = GetKillCountLevel(DeadKingEliminationInfo.KillCount)
  local TipsID
  if PlayerState.PlayerKey == DeadKingEliminationInfo.KillerPlayerKey then
    TipsID = ResolveTipsID(12161, cfg, "SelfKillEliminationKingTipID", KillCountLevel)
  elseif PlayerState.IsTeammate and PlayerState:IsTeammate(DeadKingEliminationInfo.KillerPlayerKey) then
    TipsID = ResolveTipsID(12164, cfg, "TeammateKillEliminationKingTipID", KillCountLevel)
  end
  print(bWriteLog and "KingEliminationInfoItemL TipsID " .. tostring(TipsID))
  if TipsID then
    IngameTipsTools.BattleGeneralTip(TipsID)
  end
end
function KingEliminationInfoItem:LobbyPreviewByEffectID(EffectID, KillCountLevel)
  if not EffectID or EffectID <= 0 then
    return
  end
  local cfg = CDataTable.GetTableData("EliminationKingEffectCfg", EffectID)
  if not cfg then
    return
  end
  KillCountLevel = KillCountLevel or 3
  self.UIRoot.Switcher_State:SetActiveWidgetIndex(2)
  if self.UIRoot.E_Part1 then
    self.UIRoot.E_Part1:SetText("")
  end
  if self.UIRoot.E_Part2 then
    self.UIRoot.E_Part2:SetText("")
  end
  if self.UIRoot.E_Part3 then
    self.UIRoot.E_Part3:SetText("")
  end
  local NewLeftImagePath, NewLeftBgPath = self:GetImageAndEffectPath(cfg, KillCountLevel)
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  if NewLeftImagePath and NewLeftBgPath then
    self:GetAssetListAsync({
      NewLeftImagePath,
      NewLeftBgPath .. "_C"
    }, function()
      if self and slua.isValid(self.UIRoot) then
        self:UpdateBroadcastStyle(NewLeftImagePath, NewLeftBgPath, cfg.LeftBgAnimName)
        self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
      end
    end)
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, KingEliminationInfoItem)
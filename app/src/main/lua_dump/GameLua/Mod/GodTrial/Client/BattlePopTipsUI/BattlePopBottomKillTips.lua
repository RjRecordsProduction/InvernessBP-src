local BattlePopBottomKillTips = {}
local ESlateVisibility = UEnums.ESlateVisibility
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local EFatalDamageCharacterType = import("EFatalDamageCharacterType")
function BattlePopBottomKillTips:OnInitialize(uiRoot)
  BattlePopBottomKillTips.__super.OnInitialize(self, uiRoot)
  self.MercenaryIndexBgPath = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Image_CentaurtState_png.ZD_Image_CentaurtState_png"
  self.NullIconColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
end
function BattlePopBottomKillTips:GetMercenaryName()
  if self.MercenaryName == nil then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local MercenaryConfig = GamePlayTools.GetCurrentConfig("MercenaryConfig")
    if MercenaryConfig and MercenaryConfig.Name then
      self.MercenaryName = MercenaryConfig.Name
    end
  end
  return self.MercenaryName
end
function BattlePopBottomKillTips:RefreshPlayerName(messageData)
  BattlePopBottomKillTips.__super.RefreshPlayerName(self, messageData)
  self.UIRoot.VictimIndexBg:SetBrushFromTexture(nil, false)
  self.UIRoot.CauserIndexBg:SetBrushFromTexture(nil, false)
  if messageData.bNotShowIndex ~= true then
    if messageData.CauserPlayerName ~= nil and messageData.CauserType and messageData.CauserType == EFatalDamageCharacterType.EMercenary and messageData.CauserPlayerName == self:GetMercenaryName() then
      print(bWriteLog and string.format("BattlePopBottomKillTips:RefreshPlayerName,GodTrial, CauserPlayerName = %s, bIsCauserTeammate = %s, bIamCauser = %s, CauserType=%s", tostring(messageData.CauserPlayerName), tostring(messageData.bIsCauserTeammate), tostring(messageData.bIamCauser), tostring(messageData.CauserType)))
      if messageData.bIsCauserTeammate or messageData.bIamCauser then
        self.UIRoot.CauserIndexPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.CauserIndexText:SetText("")
        self.UIRoot.CauserIndexBg:SetBrushFromPathAsync(self.MercenaryIndexBgPath, true)
        self.UIRoot.CauserIndexBg:SetColorAndOpacity(self.NullIconColor)
      else
        self.UIRoot.CauserIndexPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
    if messageData.VictimPlayerName ~= nil and messageData.VictimType and messageData.VictimType == EFatalDamageCharacterType.EMercenary and messageData.VictimPlayerName == self:GetMercenaryName() then
      print(bWriteLog and string.format("BattlePopBottomKillTips:RefreshPlayerName,GodTrial, VictimPlayerName = %s, bIsVictimTeammate = %s, bIamVictim=%s, VictimType=%s", tostring(messageData.VictimPlayerName), tostring(messageData.bIsVictimTeammate), tostring(messageData.bIamVictim), tostring(messageData.VictimType)))
      if messageData.bIsVictimTeammate or messageData.bIamVictim then
        self.UIRoot.VictimIndexPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.VictimIndexText:SetText("")
        self.UIRoot.VictimIndexBg:SetBrushFromPathAsync(self.MercenaryIndexBgPath, true)
        self.UIRoot.VictimIndexBg:SetColorAndOpacity(self.NullIconColor)
      else
        self.UIRoot.VictimIndexPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
  else
    print(bWriteLog and string.format("[GodTrial]BattlePopBottomKillTips:RefreshPlayerName, messageData.bNotShowIndex=%s", tostring(messageData.bNotShowIndex)))
  end
end
function BattlePopBottomKillTips:RefreshKillNum(messageData, ExpandData)
  BattlePopBottomKillTips.__super.RefreshKillNum(self, messageData, ExpandData)
  if (not messageData.bShowKillNum or not (messageData.KillNum > 0)) and messageData.ResultHealthStatus == ECharacterHealthStatus.FinishedLastBreath and messageData.bIsCauserTeammate and not messageData.bIamCauser and ExpandData and ExpandData.MasterPlayerName and ExpandData.MasterPlayerName ~= "" and ExpandData.MasterKills and 0 < ExpandData.MasterKills then
    local index = self:GetPlayerTeamIndex(messageData.CauserPlayerName)
    print(bWriteLog and string.format("[GodTrial]BattlePopBottomKillTips:RefreshKillNum, MasterPlayerName=%s, MasterKills=%s", tostring(ExpandData.MasterPlayerName), tostring(ExpandData.MasterKills)))
    if index == -1 and messageData.CauserPlayerName == self.PowNinName and self:GetCurPlayerName() == ExpandData.MasterPlayerName then
      self.UIRoot.KillNumNew:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.KillNumNew:SetText(LocUtil.LocalizeResFormat(5099, ExpandData.MasterKills))
      self.UIRoot.KillNumNew:SetColorAndOpacity(self.RedTextColor)
    end
  end
end
function BattlePopBottomKillTips:GetCurPlayerName()
  local uLocalPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uLocalPlayerController) then
    print(bWriteLog and string.format("BattlePopBottomKillTips:GetCurPlayerName, LocalPlayerController.PlayerName=%s, ", tostring(uLocalPlayerController.PlayerName)))
    return uLocalPlayerController.PlayerName
  end
  print(bWriteLog and string.format("BattlePopBottomKillTips:GetCurPlayerName, return nil"))
  return nil
end
local class = require("class")
local BattlePopBottomKillTipsBase = require("GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopBottomKillTips")
return class(BattlePopBottomKillTipsBase, nil, BattlePopBottomKillTips)
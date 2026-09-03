local BattlePopBottomKillTips = {}
local ESlateVisibility = UEnums.ESlateVisibility
local ECharacterHealthStatus = import("ECharacterHealthStatus")
local KillInfoCfg = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoCfg")
local KillInfoUtil = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoUtil")
local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
local BusinessHelper = import("BusinessHelper")
local Texture2D = import("/Script/Engine.Texture2D")
local PaperSprite = import("PaperSprite")
local SlateBrush = import("SlateBrushAsset")
local Util = require("client.slua_ui_framework.util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local E_DamageType = UEnums.DamageType
local KillTipsBgPath = {
  [1] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/BattlePopTips_BG04_png.BattlePopTips_BG04_png",
  [2] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/BattlePopTips_BG03_png.BattlePopTips_BG03_png"
}
local PreCacheTableConfig = {
  "TeamKillBroadcast",
  "GrenadeKillGunBindMap"
}
function BattlePopBottomKillTips:ctor()
  printf("BattlePopBottomKillTips:ctor")
end
function BattlePopBottomKillTips:OnInitialize(uiRoot)
  printf("BattlePopBottomKillTips:OnInitialize")
  self.UIRoot = uiRoot
  self.AsyncDelegates = {}
  self.BlueIconColor = FSlateColor(FLinearColor(0.274677, 0.896269, 1.0, 1.0))
  self.RedIconColor = FSlateColor(FLinearColor(1.0, 0.401978, 0.412543, 1.0))
  self.RedTextColor = FSlateColor(FLinearColor(0.806952, 0.074214, 0.005182, 1.0))
  self.YellowTextColor = FSlateColor(FLinearColor(1.0, 0.577581, 0, 1.0))
  self.UIRoot.TextBlock_Ace:SetText(LocUtil.GetLocalizeResStr(42917))
  self.StrongFeedBackType = {
    IconNum = 1,
    NormalNum = 2,
    BluePrint = 3
  }
  self.FarKillIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Distance_3_png.ZD_Icon_Distance_3_png"
  self.BoomKillIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Boom_png.ZD_Icon_Boom_png"
  self.BoomKillIconPadding = FMargin(0, 0, -10, 7)
  self.DoubleKillIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Distance_2kill_png.ZD_Icon_Distance_2kill_png"
  self.TripleKillIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_Icon_Distance_3kill_png.ZD_Icon_Distance_3kill_png"
  self.EffectUI = nil
  self.PreCacheTableAsset = {}
  self:PreloadTableAssets()
end
function BattlePopBottomKillTips:OnDestroy()
  printf("BattlePopBottomKillTips:OnDestroy")
  if slua.isValid(self.EffectUI) and self.EffectUI.RemoveFromParent then
    self.EffectUI:RemoveFromParent()
    self.EffectUI:ConditionalBeginDestroy()
    self.EffectUI = nil
  end
  self.PreCacheTableAsset = {}
  self.UIRoot = nil
  self:Dispose()
  self:RemoveAsyncDelegates()
end
function BattlePopBottomKillTips:RefreshTillTopsInfo(messageData)
  printf("BattlePopBottomKillTips:RefreshTillTopsInfo")
  local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, messageData.ExpandDataContent)
  if ExpandData == nil then
    ExpandData = {}
  end
  self:RefreshShowHide(messageData)
  self:RefreshPlayerName(messageData)
  self:RefreshWeaponIcon(messageData)
  self:RefreshDeadIcon(messageData.bIsHeadShot, messageData.ResultHealthStatus, ExpandData)
  self:RefreshKillNum(messageData, ExpandData)
  self:RefreshKillInfoBg(messageData)
  self:AceTeam(ExpandData, messageData)
  self:ShowStrongFeedBack(ExpandData, messageData)
  self:ShowSelfRescueIcon(ExpandData, messageData)
  self:UpdateKillEffect(ExpandData, messageData)
end
function BattlePopBottomKillTips:PreloadTableAssets()
  printf("BattlePopBottomKillTips:PreloadTableAssets")
  if next(self.PreCacheTableAsset) then
    return
  end
  for _, tableName in ipairs(PreCacheTableConfig) do
    local tableAsset = CDataTable.GetTable(tableName)
    if tableAsset then
      self.PreCacheTableAsset[#self.PreCacheTableAsset + 1] = tableAsset
    end
  end
end
function BattlePopBottomKillTips:UpdateKillEffect(ExpandData, messageData)
  local WeaponAvatarID = ExpandData.CauserWeaponAvatarID
  local CauserCurHoldingWeaponSkinID = ExpandData.CauserCurHoldingWeaponSkinID
  print(bWriteLog and "BattlePopBottomKillTips:UpdateKillEffect" .. tostring(WeaponAvatarID))
  if self.KillEffectAsyncHandle then
    Util.ClearAssetAsync(self.KillEffectAsyncHandle)
    self.KillEffectAsyncHandle = nil
  end
  if slua.isValid(self.EffectUI) and self.EffectUI.RemoveFromParent then
    self.EffectUI:RemoveFromParent()
    self.EffectUI:ConditionalBeginDestroy()
    self.EffectUI = nil
  end
  self.UIRoot.MinSizePlaceHolder:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if messageData.bIsVictimTeammate or messageData.bIamVictim then
    return
  end
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  if type(CauserCurHoldingWeaponSkinID) == "string" then
    local StringUtil = require("common.string_util")
    local WeaponSkins = StringUtil.Split(CauserCurHoldingWeaponSkinID, "|")
    for k, v in pairs(WeaponSkins) do
      local TempID = AvatarUtil.GetGrenadeKillBindGunID(tonumber(v), WeaponAvatarID)
      if TempID ~= 0 then
        WeaponAvatarID = TempID
        break
      end
    end
  end
  local Cfg = CDataTable.GetTableData("TeamKillBroadcast", WeaponAvatarID)
  if not Cfg then
    return
  end
  if Cfg.EffectPath and Cfg.EffectPath ~= "" then
    self.KillEffectAsyncHandle = Util.GetAssetAsync(Cfg.EffectPath, function(Asset)
      self.KillEffectAsyncHandle = nil
      if not (slua.isValid(Asset) and self) or not self.UIRoot then
        return
      end
      local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
      self.EffectUI = STExtraBlueprintFunctionLibrary.CreateWidgetByPathName(Cfg.EffectPath, self.UIRoot)
      self.UIRoot.Canvas_TeamKillInfoRoot:AddChild(self.EffectUI)
      if self.EffectUI and Cfg.AnimationName then
        self.EffectUI:PlayUserWidgetAnimation(self.EffectUI[Cfg.AnimationName], 0, 1, 0, 1)
      end
      self.UIRoot.MinSizePlaceHolder:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
  end
  if Cfg.BgPath and Cfg.BgPath ~= "" then
    self:SetTextureAsync(self.UIRoot.Border_BothSidesKillInfo, Cfg.BgPath, false)
  end
end
function BattlePopBottomKillTips:ShowSelfRescueIcon(ExpandData, messageData)
  local victimPlayerName = self:GetVictimPlayerName(messageData)
  print(bWriteLog and "BattlePopBottomKillTips:ShowSelfRescueIcon, ExpandData.bHaveSelfRescueItem = " .. tostring(ExpandData.bHaveSelfRescueItem) .. ", victimPlayerName = " .. tostring(victimPlayerName))
  local ECharacterHealthStatus = import("ECharacterHealthStatus")
  if messageData.ResultHealthStatus == ECharacterHealthStatus.HasLastBreath and ExpandData.bHaveSelfRescueItem then
    self.UIRoot.SizeBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.SizeBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function BattlePopBottomKillTips:RefreshShowHide(messageData)
  if messageData and messageData.bShowBottomBothSidesKillInfo == true then
    self.UIRoot.Border_BothSidesKillInfo:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_BothSidesKillInfo:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BattlePopBottomKillTips:RefreshPlayerName(messageData)
  if not messageData.bShowBottomBothSidesKillInfo then
    return
  end
  local causerPlayerName, bReplaceMe = self:GetCauserPlayerName(messageData)
  if causerPlayerName then
    self.UIRoot.TextBlock_PlayerName01:SetText(causerPlayerName)
  else
    self.UIRoot.TextBlock_PlayerName01:SetText("")
  end
  local victimPlayerName = self:GetVictimPlayerName(messageData)
  if victimPlayerName then
    self.UIRoot.TextBlock_PlayerName02:SetText(victimPlayerName)
  else
    self.UIRoot.TextBlock_PlayerName02:SetText("")
  end
  local CauserIndexVis = false
  local VictimIndexVis = false
  if messageData.bNotShowIndex ~= true then
    if messageData.bIsCauserTeammate or messageData.bIamCauser then
      local index = self:GetPlayerTeamIndex(causerPlayerName)
      if index == -1 then
        local CauserName = messageData.CauserRealPlayerName
        if CauserName == nil or CauserName == "" then
          if bReplaceMe then
            CauserName = messageData.CauserPlayerName
          else
            CauserName = causerPlayerName
          end
        end
        index = self:GetPlayerTeamIndex(CauserName)
      end
      if index ~= -1 then
        CauserIndexVis = true
        self.UIRoot.CauserIndexText:SetText(tostring(index + 1))
        self.UIRoot.CauserIndexBg:SetColorAndOpacity(self:GetPlayerIndexBgColor(index + 1))
      end
    end
    if messageData.bIsVictimTeammate or messageData.bIamVictim then
      local index = self:GetPlayerTeamIndex(messageData.VictimPlayerName)
      if index ~= -1 then
        VictimIndexVis = true
        self.UIRoot.VictimIndexText:SetText(tostring(index + 1))
        self.UIRoot.VictimIndexBg:SetColorAndOpacity(self:GetPlayerIndexBgColor(index + 1))
      end
    end
  end
  if CauserIndexVis then
    self.UIRoot.CauserIndexPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CauserIndexPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if VictimIndexVis then
    self.UIRoot.VictimIndexPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.VictimIndexPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BattlePopBottomKillTips:GetCauserPlayerName(messageData)
  local causerName = messageData.CauserPlayerName
  local bReplaceMe = false
  local bSpecialType = false
  if KillInfoCfg.DamageTypeSpecialCauserNameTipIdCfg[messageData.DamageType] then
    if causerName == nil or causerName == "" or messageData.DamageType == E_DamageType.DrowningDamage then
      causerName = LocUtil.GetLocalizeResStr(KillInfoCfg.DamageTypeSpecialCauserNameTipIdCfg[messageData.DamageType])
      bSpecialType = true
    elseif messageData.bIamCauser then
    end
  elseif messageData.bIamCauser then
  end
  return causerName, bReplaceMe, bSpecialType
end
function BattlePopBottomKillTips:GetVictimPlayerName(messageData)
  local victimName = messageData.VictimPlayerName
  return victimName
end
function BattlePopBottomKillTips:GetPlayerIndexBgColor(nIndex)
  if 0 < nIndex and nIndex < #KillInfoCfg.TeamPlayerColorTable then
    return KillInfoCfg.TeamPlayerColorTable[nIndex]
  else
    return KillInfoCfg.TeamPlayerColorTable[1]
  end
end
function BattlePopBottomKillTips:GetPlayerTeamIndex(playerName)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
      local TeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      for nIndex, TeamMatePlayerState in pairs(TeamMatePlayerStateList) do
        if slua.isValid(TeamMatePlayerState) and playerName == TeamMatePlayerState.PlayerName then
          return nIndex
        end
      end
    end
  end
  return -1
end
function BattlePopBottomKillTips:RefreshDeadIcon(isHeadShot, healthStatus, ExpandData)
  self.UIRoot.SizeBox_killtype:SetWidgetVisibility(ESlateVisibility.Collapsed)
  if healthStatus == ECharacterHealthStatus.HasLastBreath then
    self.UIRoot.SizeBox_killtype:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self.UIRoot.WidgetSwitcherIcon:SetActiveWidgetIndex(1)
    if ExpandData and ExpandData.bHaveSelfRescueItem then
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    else
      self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    end
    if isHeadShot then
      self:SetTextureAsync(self.UIRoot.Image_KillType, KillInfoCfg.DeadIconMap[1], true)
    else
      self:SetTextureAsync(self.UIRoot.Image_KillType, KillInfoCfg.DeadIconMap[3], true)
    end
  elseif healthStatus == ECharacterHealthStatus.FinishedLastBreath then
    self.UIRoot.SizeBox_killtype:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self.UIRoot.WidgetSwitcherIcon:SetActiveWidgetIndex(0)
    if isHeadShot then
      self:SetTextureAsync(self.UIRoot.Image_KillType, KillInfoCfg.DeadIconMap[2], true)
    else
      self:SetTextureAsync(self.UIRoot.Image_KillType, KillInfoCfg.DeadIconMap[4], true)
    end
  end
end
function BattlePopBottomKillTips:RefreshWeaponIcon(messageData)
  if not messageData.bShowBottomBothSidesKillInfo then
    return
  end
  self.bRefreshWeaponIconBySkill = false
  self:SetWeaponIcon(messageData.DamageType, messageData.AdditionalParam, messageData.PreviousHealthStatus)
  if not self.bRefreshWeaponIconBySkill then
    self:SetAdditionalWeaponIcon(messageData.CauserType, messageData.AdditionalParam)
  end
end
function BattlePopBottomKillTips:SetWeaponIcon(DamageType, AdditionalParam, PreviousHealthStatus)
  self.UIRoot.Image_WeaponIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
  if not self:CanShowWeaponIcon(DamageType) then
    printf("BattlePopBottomKillTips:SetWeaponIcon NotShowWeaponIcon DamageType:" .. tostring(DamageType))
    return
  end
  if DamageType == E_DamageType.SkillDamage then
    printf("BattlePopBottomKillTips:SetWeaponIcon IsSkillDamageType")
    local SkillIconPath = KillInfoUtil.GetSkillIconPath(DamageType, AdditionalParam, PreviousHealthStatus)
    if SkillIconPath and SkillIconPath ~= "" then
      print(bWriteLog and string.format("BattlePopBottomKillTips:SetWeaponIcon IsSkillDamageType SkillIconPath:%s", SkillIconPath))
      self.UIRoot.Image_WeaponIcon:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      self:SetTextureAsync(self.UIRoot.Image_WeaponIcon, SkillIconPath, true, true)
      self.bRefreshWeaponIconBySkill = true
      return
    end
  end
  local weaponIconPath = KillInfoUtil.GetWeaponIconPath(DamageType, AdditionalParam, PreviousHealthStatus)
  if weaponIconPath then
    printf(bWriteLog and "BattlePopBottomKillTips:SetWeaponIcon SelfHitTestInvisible")
    self.UIRoot.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SetTextureAsync(self.UIRoot.Image_WeaponIcon, weaponIconPath, true, true)
  else
    printf(bWriteLog and "BattlePopBottomKillTips:SetWeaponIcon SetOpacity 0")
    self.UIRoot.Image_WeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    self.UIRoot.Image_WeaponIcon:SetOpacity(0)
  end
end
function BattlePopBottomKillTips:SetAdditionalWeaponIcon(Type, AdditionalParam)
  local path = KillInfoCfg.FatalDamageCharacterType2WeaponIconMap[Type]
  if path and path ~= "" then
    if AdditionalParam and KillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam] then
      print(bWriteLog and "BattlePopBottomKillTips:SetAdditionalWeaponIcon:", AdditionalParam, KillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam])
      path = KillInfoCfg.FatalDamageMonsterID2WeaponIconMap[AdditionalParam]
    end
    Util.GetAssetAsync(path, function(texture)
      if slua.isValid(texture) then
        self.UIRoot.Image_WeaponIcon:SetBrushFromTexture(texture, true)
      end
    end)
  end
end
function BattlePopBottomKillTips:CanShowWeaponIcon(DamageType)
  if DamageType == E_DamageType.LastBreathWithoutRescue then
    return false
  end
  return true
end
function BattlePopBottomKillTips:RefreshKillNum(messageData, ExpandData)
  self.UIRoot.KillNumNew:SetWidgetVisibility(ESlateVisibility.Collapsed)
  self.UIRoot.WidgetSwitcherIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
  if messageData.bShowKillNum and messageData.KillNum > 0 then
    self.UIRoot.KillNumNew:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.KillNumNew:SetText(LocUtil.LocalizeResFormat(5099, messageData.KillNum))
    self.UIRoot.KillNumNew:SetColorAndOpacity(self.RedTextColor)
  elseif 0 < messageData.AssistNum and self:CheckIsSHowAssist() then
    self.UIRoot.KillNumNew:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.KillNumNew:SetText(LocUtil.LocalizeResFormat(508619, messageData.AssistNum))
    self.UIRoot.KillNumNew:SetColorAndOpacity(self.YellowTextColor)
  end
  if not messageData.bHideKillIcon then
    self.UIRoot.WidgetSwitcherIcon:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
function BattlePopBottomKillTips:CheckIsSHowAssist()
  if self.bShowAssist == nil then
    local uGameState = GameplayData.GetGameState()
    local uGameModeType = uGameState.GameModeType
    local EGameModeType = import("EGameModeType")
    if uGameModeType ~= EGameModeType.EDeathMatchGameMode and uGameModeType ~= EGameModeType.EVehicleWar_CAMP then
      self.bShowAssist = true
      return true
    end
    if uGameState.IsTeamDeathMatch and uGameState:IsTeamDeathMatch() then
      self.bShowAssist = true
      return true
    end
    self.bShowAssist = false
    return false
  end
  return self.bShowAssist
end
function BattlePopBottomKillTips:RefreshKillInfoBg(messageData)
  if not messageData.bShowBottomBothSidesKillInfo then
    return
  end
  printf("BattlePopBottomKillTips:RefreshKillInfoBg bIsCauserTeammate:" .. tostring(messageData.bIsCauserTeammate) .. " bIsVictimTeammate:" .. tostring(messageData.bIsVictimTeammate) .. " bIamCauser:" .. tostring(messageData.bIamCauser) .. " bIamVictim:" .. tostring(messageData.bIamVictim))
  if messageData.bIsVictimTeammate or messageData.bIamVictim then
    self.UIRoot.TextBlock_PlayerName01:SetColorAndOpacity(self.RedIconColor)
    self.UIRoot.TextBlock_PlayerName02:SetColorAndOpacity(self.RedIconColor)
    local WeaponIconBrush = slua.IndexReference(self.UIRoot.Image_WeaponIcon, "Brush"):clone()
    WeaponIconBrush.TintColor = self.RedIconColor
    self.UIRoot.Image_WeaponIcon:SetBrush(WeaponIconBrush)
    local KillIconBrush = slua.IndexReference(self.UIRoot.Image_KillType, "Brush"):clone()
    KillIconBrush.TintColor = self.RedIconColor
    self.UIRoot.Image_KillType:SetBrush(KillIconBrush)
    self.UIRoot.TextBlock_Ace:SetColorAndOpacity(self.RedIconColor)
    self:SetTextureAsync(self.UIRoot.Border_BothSidesKillInfo, KillTipsBgPath[1], false)
  else
    self.UIRoot.TextBlock_PlayerName01:SetColorAndOpacity(self.BlueIconColor)
    self.UIRoot.TextBlock_PlayerName02:SetColorAndOpacity(self.BlueIconColor)
    local WeaponIconBrush = slua.IndexReference(self.UIRoot.Image_WeaponIcon, "Brush"):clone()
    WeaponIconBrush.TintColor = self.BlueIconColor
    self.UIRoot.Image_WeaponIcon:SetBrush(WeaponIconBrush)
    local KillIconBrush = slua.IndexReference(self.UIRoot.Image_KillType, "Brush"):clone()
    KillIconBrush.TintColor = self.BlueIconColor
    self.UIRoot.Image_KillType:SetBrush(KillIconBrush)
    self.UIRoot.TextBlock_Ace:SetColorAndOpacity(self.BlueIconColor)
    self:SetTextureAsync(self.UIRoot.Border_BothSidesKillInfo, KillTipsBgPath[2], false)
  end
end
function BattlePopBottomKillTips:ShowStrongFeedBack(ExpandData, messageData)
  local Type, IconPath, Text = self:GetStrongFeedBackInfo(ExpandData, messageData)
  local UIRoot = self.UIRoot
  if Type == self.StrongFeedBackType.IconNum then
    UIRoot.StrongFeedBack:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    self:SetTextureAsync(UIRoot.FeedBackIcon, IconPath, true, false)
    UIRoot.FarBox:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    UIRoot.Canvas_BP:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    UIRoot.KillBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if Text ~= nil and Text ~= "" then
      UIRoot.FarText:SetText(Text)
      UIRoot.FarText:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    else
      UIRoot.FarText:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  elseif Type == self.StrongFeedBackType.NormalNum then
    UIRoot.StrongFeedBack:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    UIRoot.FarBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    UIRoot.Canvas_BP:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    UIRoot.KillBox:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    UIRoot.KillNumText:SetText(Text)
  elseif Type == self.StrongFeedBackType.BluePrint then
    UIRoot.StrongFeedBack:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    UIRoot.FarBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    UIRoot.KillBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    UIRoot.Canvas_BP:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    if self.LastBPPath and self.LastBPPath ~= IconPath and UIManager.UI_Config_InGame[self.LastBPPath] then
      UIManager.CloseUI(UIManager.UI_Config_InGame[self.LastBPPath])
      self.LastBPPath = nil
    end
    if UIManager.UI_Config_InGame[IconPath] then
      local EffectUI = UIManager.GetUI(UIManager.UI_Config_InGame[IconPath])
      if EffectUI then
        EffectUI:PlayFadeInAnim()
      else
        EffectUI = UIManager.ShowUI(UIManager.UI_Config_InGame[IconPath])
      end
      self.LastBPPath = IconPath
    end
  else
    UIRoot.StrongFeedBack:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function BattlePopBottomKillTips:GetStrongFeedBackInfo(ExpandData, messageData)
  local ExplodeKillNum = ExpandData.ExplodeKillNum
  if ExplodeKillNum and messageData.bIamCauser then
    self:ChangeToExplodeKillStyle()
    self.UIRoot.KillEffectCanvas:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if 1 < ExplodeKillNum then
      return self.StrongFeedBackType.IconNum, self.BoomKillIconPath, "x" .. tostring(ExplodeKillNum)
    else
      return self.StrongFeedBackType.IconNum, self.BoomKillIconPath, nil
    end
  end
  if ExpandData.MultiKill and 1 < ExpandData.MultiKill then
    print(bWriteLog and "BattlePopBottomKillTips:ShowStrongFeedBack MultiKill ", ExpandData.MultiKill)
    self.UIRoot.KillEffectCanvas:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    return self.StrongFeedBackType.BluePrint, "MultiKillTips", nil
  end
  if ExpandData.Distance then
    if not messageData.bIamCauser or messageData.bIsCauserTeammate or not KillInfoCfg.FarKillDamageType[messageData.DamageType] then
      print(bWriteLog and "BattlePopBottomKillTips:ShowStrongFeedBack Farkill Failed: ", tostring(messageData.bIamCauser), tostring(messageData.bIsCauserTeammate), messageData.DamageType)
      return nil, nil, nil
    end
    self:ChangeToFarKillStyle()
    self.UIRoot.KillEffectCanvas:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    return self.StrongFeedBackType.IconNum, self.FarKillIconPath, LocUtil.LocalizeResFormat(45076, ExpandData.Distance)
  end
  if ExpandData.RampageKill then
    self.UIRoot.KillEffectCanvas:SetWidgetVisibility(UEnums.GSlateVisibility.HitTestInvisible)
    return self.StrongFeedBackType.NormalNum, nil, tostring(ExpandData.RampageKill)
  end
  return nil, nil, nil
end
function BattlePopBottomKillTips:ChangeToExplodeKillStyle()
  if self.LastStyle ~= nil and self.LastStyle == "Boom" then
    return
  end
  local UIRoot = self.UIRoot
  UIRoot.FeedBackIcon.Slot:SetPadding(self.BoomKillIconPadding)
  local Font = UIRoot.FarText.Font
  local FontOutlineSettings = slua.IndexReference(Font, "OutlineSettings")
  FontOutlineSettings.OutlineSize = 1
  Font.Size = 17
  UIRoot.FarText:SetFont(Font)
  self.LastStyle = "Boom"
end
function BattlePopBottomKillTips:ChangeToFarKillStyle()
  if self.LastStyle ~= nil and self.LastStyle == "Far" then
    return
  end
  local UIRoot = self.UIRoot
  UIRoot.FeedBackIcon.Slot:SetPadding(FMargin(0, 0, 0, 0))
  local Font = UIRoot.FarText.Font
  local FontOutlineSettings = slua.IndexReference(Font, "OutlineSettings")
  FontOutlineSettings.OutlineSize = 0
  Font.Size = 16
  UIRoot.FarText:SetFont(Font)
  self.LastStyle = "Far"
end
function BattlePopBottomKillTips:SetTextureAsync(control, path, bMatchSize, bWithVisbility)
  if self.AsyncDelegates[control] ~= nil then
    Util.ClearAssetAsync(self.AsyncDelegates[control])
    self.AsyncDelegates[control] = nil
  end
  local OnLoadedDelegate = Util.GetAssetAsync(path, function(textureOrSprite)
    if not slua.isValid(control) then
      return
    end
    if self.AsyncDelegates[control] ~= nil then
      self.AsyncDelegates[control] = nil
    end
    if not textureOrSprite then
      control:SetBrushFromTexture(nil, false)
      local Client = import("ScriptHelperClient")
      Client.AddKnownMissingPackage(path, control, true)
    elseif BusinessHelper.IsClassOf(textureOrSprite, PaperSprite) then
      local width, height
      if bMatchSize then
        width, height = textureOrSprite.SourceDimension.X, textureOrSprite.SourceDimension.Y
      elseif control.Brush then
        local ImageSize = slua.IndexReference(control, "Brush", "ImageSize")
        width, height = ImageSize.X, ImageSize.Y
      else
        local ImageSize = slua.IndexReference(control, "Background", "ImageSize")
        width, height = ImageSize.X, ImageSize.Y
      end
      width = math.floor(width + 0.5)
      height = math.floor(height + 0.5)
      local brush = PaperSpriteBlueprintLibrary.MakeBrushFromSprite(textureOrSprite, width, height)
      local TintColor = control.Brush ~= nil and control.Brush.TintColor or control.Background.TintColor
      brush.      control:SetBrush(brush)
    elseif BusinessHelper.IsClassOf(textureOrSprite, Texture2D) then
      local Client = import("ScriptHelperClient")
      if Client.RemoveKnownMissingPackageRefObjectByObj then
        Client.RemoveKnownMissingPackageRefObjectByObj(control)
      end
      control:SetBrushFromTexture(textureOrSprite, bMatchSize or false)
    elseif BusinessHelper.IsClassOf(textureOrSprite, SlateBrush) then
      local Client = import("ScriptHelperClient")
      if Client.RemoveKnownMissingPackageRefObjectByObj then
        Client.RemoveKnownMissingPackageRefObjectByObj(control)
      end
      control:SetBrushFromAsset(textureOrSprite)
    else
      error(string.format("Not support SetTexture of %s", textureOrSprite))
    end
    if bWithVisbility then
      control:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    end
  end)
  if OnLoadedDelegate then
    self.AsyncDelegates[control] = OnLoadedDelegate
  end
end
function BattlePopBottomKillTips:AceTeam(ExpandData, messageData)
  if ExpandData and ExpandData.IsAce and not messageData.bIsVictimTeammate and not messageData.bIamVictim then
    self.UIRoot.CanvasPanel_Ace:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Ace:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function BattlePopBottomKillTips:RemoveAsyncDelegates()
  if self.AsyncDelegates then
    for control, loadedDelegate in pairs(self.AsyncDelegates) do
      Util.ClearAssetAsync(loadedDelegate)
    end
  end
  self.AsyncDelegates = {}
  if self.KillEffectAsyncHandle then
    Util.ClearAssetAsync(self.KillEffectAsyncHandle)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBattlePopBottomKillTips = class(CDelegateContainer, nil, BattlePopBottomKillTips)
return CBattlePopBottomKillTips
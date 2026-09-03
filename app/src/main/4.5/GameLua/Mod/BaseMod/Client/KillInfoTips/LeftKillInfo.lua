local LeftKillInfo = {}
local ELeftUIInfoRecordType = import("ELeftUIInfoRecordType")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local FClientLeftUIInfoRecordData = import("ClientLeftUIInfoRecordData")
local EGameModeType = import("EGameModeType")
local EGameModeSubType = import("EGameModeSubType")
local EGameReplayType = import("EGameReplayType")
local CustomType = require("client.logic.setting.CustomType")
local bUserNewKillInfoItem = true
local ModePhase = {
  [0] = 10,
  [1] = 20,
  [2] = 30
}
local PreCacheTableConfig = {
  "ItemUpgradeConfig",
  "RegionConfig",
  "WeaponAvatarBattleEffect",
  "GrenadeKillGunBindMap",
  "WeaponSkinVoiceCfg",
  "VoiceActorCfg",
  "TeamKillBroadcast"
}
function LeftKillInfo:ctor(selfType)
  self.KillInfoPanelCache = {}
  self.LeftUIRecordCache = {}
  self.LastAlivePlayerNum = 0
  self.bNeedShowKillInfo = true
  self.PreCacheTableAsset = {}
end
function LeftKillInfo:OnInitialize()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    return
  end
  MainControlBaseUI.CanvasPanel_1:AddChild(self.UIRoot)
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
  self:ReceivedInitWidget()
end
function LeftKillInfo:OnClose()
  self.PreCacheTableAsset = {}
end
function LeftKillInfo:RegistEvents()
  print(bWriteLog and "[muidarzhang] LeftKillInfo:RegistEvents")
  self:AddUIMessageEvent("AddNewFatalDamageInfo", self.HandleNewFatalDamageInfo, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ADD_FATAL_DAMAGE_INFO, self.HandleNewFatalDamageInfo_GMTest, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_INIT_LEFT_KILL_INFO, self.HandleInitLeftKillInfo, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_ADJUST_LEFT_KILL_INFO_OFFSET, self.HandleAdjustPosition, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_UIMSG_SWITCH_SHOW_DOWN_LEFTUI, self.HandleSwitchShowDownLeftUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.HandleDeathMatchUISetting, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOWORHIDE_LEFT_KILLINFO, self.HandleNeedShowKillInfo, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_PLAYERNUM_CHANGED, self.OnPlayerNumChanged, self)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_0)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_QUICK_TWEAK_LAYOUT_STATE, function(_, __, bQuickTweakLayout)
    self.UIRoot.CustomizeCanvasPanel_BP:SetWidgetVisibility(bQuickTweakLayout and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.SelfHitTestInvisible)
  end)
end
function LeftKillInfo:ReceivedInitWidget()
  self:InitKillInfoPanel()
  self:InitCustomizeCanvasPanel()
end
function LeftKillInfo:InitKillInfoPanel()
  if #self.KillInfoPanelCache == 0 then
    local UIRoot = self.UIRoot
    for nIndex = 1, 5 do
      local KillInfoItem = UIRoot["KillInfoItem_BP_" .. nIndex]
      self.KillInfoPanelCache[#self.KillInfoPanelCache + 1] = KillInfoItem
      if bUserNewKillInfoItem and KillInfoItem then
        UIRoot.KillTipContainer:AddChild(KillInfoItem)
        KillInfoItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  end
  self.KillInfoPanelCacheIndex = 1
end
function LeftKillInfo:GetKillInfoPanel()
  local KillInfoWidget = self.KillInfoPanelCache[self.KillInfoPanelCacheIndex]
  if KillInfoWidget then
    KillInfoWidget:EventBeginAnim()
    self.KillInfoPanelCacheIndex = self.KillInfoPanelCacheIndex + 1
    if self.KillInfoPanelCacheIndex > #self.KillInfoPanelCache then
      self.KillInfoPanelCacheIndex = 1
    end
    return KillInfoWidget
  end
end
function LeftKillInfo:AddNewPhaseRecordInfo(Phase)
  if self.bNeedShowKillInfo then
    local ClientLeftUIInfoRecordData = FClientLeftUIInfoRecordData()
    ClientLeftUIInfoRecordData.RecordType = ELeftUIInfoRecordType.PhaseInformation
    ClientLeftUIInfoRecordData.PhaseMark = Phase
    table.insert(self.LeftUIRecordCache, ClientLeftUIInfoRecordData)
    self:UpdateFatalDamageUI()
  else
    print(bWriteLog and "bNeedShowKillInfo is false")
  end
end
function LeftKillInfo:CheckPhaseInfo(InPhase, AivePlayerNum)
  return AivePlayerNum <= InPhase and InPhase < self.LastAlivePlayerNum
end
function LeftKillInfo:InitCustomizeCanvasPanel()
  local isOb = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.IsObserver ~= nil and PlayerController:IsObserver() then
    isOb = true
  end
  if isOb then
    self.UIRoot.CustomizeCanvasPanel_BP:SetCustomType(CustomType._173_OBKillTips)
  end
end
function LeftKillInfo:HandleDeathMatchUISetting(_, __)
  sandbox.LogNormal(bWriteLog and "LeftKillInfo:HandleDeathMatchUISetting")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_DeathPlayback then
    log(bWriteLog and "LeftKillInfo:HandleDeathMatchUISetting Collapsed")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:RemoveUIRecordCache()
  end
  if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_WonderfulPlayback then
    log(bWriteLog and "LeftKillInfo:HandleDeathMatchUISetting SelfHitTestInvisible")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:RemoveUIRecordCache()
  end
end
function LeftKillInfo:RemoveUIRecordCache()
  self.LeftUIRecordCache = {}
  log(bWriteLog and "LeftKillInfo:RemoveUIRecordCache LeftUIRecordCache")
  if self.AddItemTimer then
    self:RemoveGameTimer(self.AddItemTimer)
    self.AddItemTimer = nil
    log(bWriteLog and "LeftKillInfo:RemoveUIRecordCache remove AddItemTimer")
  end
  if self.CurFatalDamageClearTimer then
    self:RemoveGameTimer(self.CurFatalDamageClearTimer)
    self.CurFatalDamageClearTimer = nil
    log(bWriteLog and "LeftKillInfo:RemoveUIRecordCache remove CurFatalDamageClearTimer")
  end
  if self.CurFatalDamageWidget then
    self:ClearCurFatalDamagetWidget()
    log(bWriteLog and "LeftKillInfo:RemoveUIRecordCache remove ClearCurFatalDamagetWidget")
  end
end
function LeftKillInfo:HandleNewFatalDamageInfo(_, __)
  self:AddNewFatalDamageInfo()
end
function LeftKillInfo:HandleInitLeftKillInfo(_, __)
  self:InitKillInfoPanel()
end
function LeftKillInfo:AddNewFatalDamageInfo(bGMTest)
  printf("LeftKillInfo:AddNewFatalDamageInfo")
  local uPlayerController = GameplayData.GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    local copyRecordData = slua.IndexReference(uPlayerController, "ClientFatalDamageLastRecords"):clone()
    if self:AddLeftKillInfoPostProcessing(copyRecordData) then
      local recordData = {}
      recordData.RecordType = ELeftUIInfoRecordType.FatalDamage
      recordData.PhaseMark = 0
      recordData.      recordData.DamageInfo = copyRecordData
      if Client.IsWindowOB() then
        printf(bWriteLog and "[LeftKillInfo:AddNewFatalDamageInfo] client is PCOB try to udpate DamageInfo")
        local OBUtilitySubsystem = SubsystemMgr:Get("OBUtilitySubsystem")
        if OBUtilitySubsystem then
          local uSyncOBDataActor = OBUtilitySubsystem:GetSyncOBDataActor()
          if slua.isValid(uSyncOBDataActor) then
            printf(bWriteLog and "[LeftKillInfo:AddNewFatalDamageInfo] uSyncOBDataActor is valid")
            local CustomPlayerNameCauser = uSyncOBDataActor:GetCustomPlayerNameByPlayerName(recordData.DamageInfo.Causer)
            local CustomPlayerNameVictim = uSyncOBDataActor:GetCustomPlayerNameByPlayerName(recordData.DamageInfo.VictimName)
            if CustomPlayerNameCauser and CustomPlayerNameCauser ~= "" then
              printf(bWriteLog and string.format("[LeftKillInfo:AddNewFatalDamageInfo] DamageInfo.Causer from %s to %s", recordData.DamageInfo.Causer, CustomPlayerNameCauser))
              recordData.DamageInfo.Causer = CustomPlayerNameCauser
            end
            if CustomPlayerNameVictim and CustomPlayerNameVictim ~= "" then
              printf(bWriteLog and string.format("[LeftKillInfo:AddNewFatalDamageInfo] DamageInfo.VictimName from %s to %s", recordData.DamageInfo.VictimName, CustomPlayerNameVictim))
              recordData.DamageInfo.VictimName = CustomPlayerNameVictim
            end
          end
        end
      end
      if uPlayerController:IsSpectator() and not uPlayerController:IsInSpectating() then
        self.LeftUIRecordCache[#self.LeftUIRecordCache + 1] = recordData
      else
        self:InsertRecordCache(recordData)
      end
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ADD_FATAL_DAMAGE_RECORD, recordData)
      self:UpdateFatalDamageUI()
    end
  end
end
function LeftKillInfo:InsertRecordCache(RecordData)
  print(bWriteLog and "LeftKillInfo:InsertRecordCache ")
  local EFatalDamageRelationShip = import("EFatalDamageRelationShip")
  local MyCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(MyCharacter) then
    self.LeftUIRecordCache[#self.LeftUIRecordCache + 1] = RecordData
    return
  end
  local SelfName = MyCharacter:GetPlayerNameSafety()
  local bNewRecordSelf = RecordData.DamageInfo.Causer == SelfName
  local bIsTeammateCauserRecord = RecordData.DamageInfo.RecordRelationShip == EFatalDamageRelationShip.MyTeamateIsCauser
  if not bIsTeammateCauserRecord then
    self.LeftUIRecordCache[#self.LeftUIRecordCache + 1] = RecordData
    return
  end
  for i = 1, #self.LeftUIRecordCache do
    local RecordInfo = self.LeftUIRecordCache[i]
    local DamageInfo = RecordInfo.DamageInfo
    if bNewRecordSelf then
      if DamageInfo.Causer ~= SelfName then
        table.insert(self.LeftUIRecordCache, i, RecordData)
        return
      end
    elseif bIsTeammateCauserRecord and DamageInfo.RecordRelationShip ~= EFatalDamageRelationShip.MyTeamateIsCauser then
      table.insert(self.LeftUIRecordCache, i, RecordData)
      return
    end
  end
  self.LeftUIRecordCache[#self.LeftUIRecordCache + 1] = RecordData
end
function LeftKillInfo:AddLeftKillInfoPostProcessing(recordData)
  printf("LeftKillInfo:AddLeftKillInfoPostProcessing CauserName :" .. tostring(recordData.Causer))
  if self:IgnoreInWonderfulReplay(recordData) then
    log(bWriteLog and "LeftKillInfo:AddLeftKillInfoPostProcessing IgnoreInWonderfulReplay return")
    return false
  end
  local ModType = GameMainConfig.GetModType()
  if ModType == "SingleTraining" and not recordData.bIamVictim then
    recordData.VictimName = LocUtil.GetLocalizeResStr(48350)
  end
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.CurrentModeLogic and IngameEntry.CurrentModeLogic.OnAddLeftKillInfoPostProcessing then
    local canAdd = IngameEntry.CurrentModeLogic:OnAddLeftKillInfoPostProcessing(recordData)
    log(bWriteLog and "LeftKillInfo.AddLeftKillInfoPostProcessing " .. tostring(canAdd))
    return canAdd
  end
  local causerID = math.tointeger(tonumber(recordData.Causer))
  if causerID then
    local localResCfg = CDataTable.GetTableData("LocalizeRes", causerID)
    if localResCfg then
      recordData.Causer = LocUtil.GetLocalizeResStr(causerID)
    end
  end
  return true
end
function LeftKillInfo:IgnoreInWonderfulReplay(recordData)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.GameReplayType == EGameReplayType.EGameReplayType_WonderfulPlayback then
    local uReplayViewTarget = uPlayerController.STExtraBaseCharacter
    if slua.isValid(uReplayViewTarget) then
      local ViewTargetName = uReplayViewTarget:GetPlayerNameSafety()
      log(bWriteLog and string.format("LeftKillInfo.IgnoreInWonderfulReplay ViewTargetName[%s] Causer[%s] Victim[%s]", ViewTargetName, recordData.Causer, recordData.VictimName))
      if recordData.Causer ~= ViewTargetName and recordData.VictimName ~= ViewTargetName then
        return true
      end
    else
      return true
    end
  end
  return false
end
function LeftKillInfo:HandleSwitchShowDownLeftUI(_, __)
  local UIRoot = self.UIRoot
  if UIRoot.KillTipContainer:IsVisible() then
    UIRoot.KillTipContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    UIRoot.KillTipContainer:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  end
end
function LeftKillInfo:HandleAdjustPosition(_, __, nOffSetX, nOffSetY)
  local UWidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local uKillTipCanvas = UWidgetLayoutLibrary.SlotAsCanvasSlot(self.UIRoot.KillTipContainer)
  if slua.isValid(uKillTipCanvas) then
    uKillTipCanvas:SetPosition(FVector2D(nOffSetX, nOffSetY))
  end
end
function LeftKillInfo:HandleNeedShowKillInfo(_, __, bNeedShow)
  if bNeedShow == nil then
    return
  end
  self.bNeedShowKillInfo = bNeedShow
end
function LeftKillInfo:UpdateFatalDamageUI()
  if not self.CurFatalDamageWidget and not self.AddItemTimer then
    self:MaybePreLoadTableAssets()
    self.AddItemTimer = self:AddGameTimer(0.06, false, function()
      self:AddOneNewItem()
      self.AddItemTimer = nil
    end)
  end
end
function LeftKillInfo:MaybePreLoadTableAssets()
  print(bWriteLog and "LeftKillInfo:MaybePreLoadTableAssets")
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
function LeftKillInfo:AddOneNewItem()
  if #self.LeftUIRecordCache > 0 then
    local UIRoot = self.UIRoot
    local bShouldAddItem = false
    self.CurFatalDamageWidget = self:GetKillInfoPanel()
    if self.CurFatalDamageWidget then
      local DamageInfo = self.LeftUIRecordCache[1].DamageInfo
      local nRecordType = self.LeftUIRecordCache[1].RecordType
      if nRecordType == ELeftUIInfoRecordType.FatalDamage then
        self.CurFatalDamageWidget:FileItem(DamageInfo)
        local bNeedKCTips = self:CheckNeedKCTips(DamageInfo)
        if bNeedKCTips then
          self.CurFatalDamageWidget:SetKillCounterType()
        end
        bShouldAddItem = true
        if self.LeftUIRecordCache[1].bGMTest then
          local gm_kill_braodcast = RequireBlackList("blacklist.slua.logic.gm.gm_kill_broadcast")
          if gm_kill_braodcast then
            gm_kill_braodcast.RefreshKillBraodcastShow(self.CurFatalDamageWidget)
          end
        end
      elseif nRecordType == ELeftUIInfoRecordType.PhaseInformation then
        self.CurFatalDamageWidget:SetPhaseInfo(self.LeftUIRecordCache[1].PhaseMark)
        bShouldAddItem = true
      elseif nRecordType == ELeftUIInfoRecordType.KillKingInfo then
        self.CurFatalDamageWidget:SetKillKingInfo(DamageInfo)
        bShouldAddItem = true
      end
      Client.RequireSlateTickEveryFrame(SlateUI_ID.LEFT_KILL_INFO)
      if bShouldAddItem then
        table.remove(self.LeftUIRecordCache, 1)
        if bUserNewKillInfoItem then
          self.CurFatalDamageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else
          UIRoot.KillTipContainer:AddChild(self.CurFatalDamageWidget)
        end
        self.CurFatalDamageClearTimer = self:AddGameTimer(4, false, function()
          self:ClearCurFatalDamagetWidget()
        end)
        self:AddGameTimer(2.1, false, function()
          self:CheckSwitchMode()
        end)
      end
    end
  end
end
function LeftKillInfo:CheckNeedKCTips(DamageInfo)
  local uPlayerController = GameplayData.GetPlayerController()
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, DamageInfo.ExpandDataContent)
  if slua.isValid(uPlayerController) and not uPlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_HawkEye | ESpectatorReplayFlag.ESpectatorReplayFlag_CompletePlayback) and not uPlayerController:IsDemoPlayGlobalObserver() and not uPlayerController:IsObserver() and ExpandData and ExpandData.KillCounterItemId and DamageInfo.Causer == DamageInfo.RealKillerName then
    local TipRowNum = self.CurFatalDamageWidget.TipRowNum
    self.CurKillCounterTips = UIManager.ShowUI(UIManager.UI_Config_InGame.KillCounterTips, DamageInfo.CauserWeaponAvatarID, ExpandData.KillCounterItemId, self, ExpandData.KillCounterNum, TipRowNum)
  end
  local bNeedChangeType = ExpandData and ExpandData.KillCucolorisItemId and ExpandData.KillCucolorisItemId > 0
  return bNeedChangeType
end
function LeftKillInfo:ClearCurFatalDamagetWidget()
  Client.ResetSlateTickEveryFrame(SlateUI_ID.LEFT_KILL_INFO)
  if self.CurFatalDamageWidget then
    if bUserNewKillInfoItem then
      self.CurFatalDamageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.CurFatalDamageWidget:RemoveFromParent()
    end
  end
  if self.CurKillCounterTips then
    self.CurKillCounterTips:Close()
    self.CurKillCounterTips = nil
  end
  self.CurFatalDamageWidget = nil
  self:AddOneNewItem()
end
function LeftKillInfo:CheckSwitchMode()
  if not (#self.LeftUIRecordCache > 0) or slua.isValid(self.PrevFatalDamageWidget) then
  else
    self.PrevFatalDamageWidget = self.CurFatalDamageWidget
    if self.PrevFatalDamageWidget then
      if self.CurKillCounterTips then
        self.PrevKillCounterTips = self.CurKillCounterTips
        self.CurKillCounterTips = nil
        if self.PrevFatalDamageWidget.bHasKingEliminationInfo then
          self.PrevKillCounterTips:PlayExitAnimation(3)
        else
          self.PrevKillCounterTips:PlayExitAnimation(2)
        end
        self.PrevFatalDamageWidget.bHasKillCounter = true
      else
        self.PrevFatalDamageWidget.bHasKillCounter = false
      end
      self.PrevFatalDamageWidget:SwitchToMode2()
    end
    Client.ResetSlateTickEveryFrame(SlateUI_ID.LEFT_KILL_INFO)
    self:RemoveGameTimer(self.CurFatalDamageClearTimer)
    self:AddGameTimer(1.8, false, function()
      if self.PrevFatalDamageWidget then
        if self.PrevKillCounterTips then
          self.PrevKillCounterTips:Close()
          self.PrevKillCounterTips = nil
        end
        if bUserNewKillInfoItem then
          self.PrevFatalDamageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        else
          self.PrevFatalDamageWidget:RemoveFromParent()
        end
      end
      self.PrevFatalDamageWidget = nil
    end)
    print(bWriteLog and "have_have_have_condition")
    self:AddOneNewItem()
  end
end
function LeftKillInfo:OnPlayerNumChanged()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsObserver() or uPlayerController:IsSpectator() then
    return
  end
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return
  end
  if uGameState.GameModeType ~= EGameModeType.ETypicalGameMode and uGameState.GameModeSubType ~= EGameModeSubType.ESinkGameMode then
    return
  end
  if uGameState:GetGameModeState() ~= "FightingState" then
    return
  end
  local AlivePlayerNum = uGameState:GetAlivePlayerNum()
  if self.LastAlivePlayerNum > 0 then
    for ArrayIndex, ArrayElement in pairs(ModePhase) do
      if self:CheckPhaseInfo(ArrayElement, AlivePlayerNum) then
        self:AddNewPhaseRecordInfo(ArrayElement)
      end
    end
  end
  self.Lastend
function LeftKillInfo:OnClose()
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_0)
  Client.ResetSlateTickEveryFrame(SlateUI_ID.LEFT_KILL_INFO)
  if self.AddItemTimer then
    self:RemoveGameTimer(self.AddItemTimer)
  end
  if self.PrevKillCounterTips then
    self.PrevKillCounterTips:Close()
    self.PrevKillCounterTips = nil
  end
  if self.CurKillCounterTips then
    self.CurKillCounterTips:Close()
    self.CurKillCounterTips = nil
  end
end
function LeftKillInfo:HandleNewFatalDamageInfo_GMTest(_, __)
  log(bWriteLog and "LeftKillInfo:HandleNewFatalDamageInfo_GMTest")
  if not IsEditor then
    return
  end
  self:AddNewFatalDamageInfo(true)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, LeftKillInfo)
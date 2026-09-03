local SkillManagerComponent = {}
local UTSkillEventType = import("UTSkillEventType")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
local ESkillMutexType = import("ESkillMutexType")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
function SkillManagerComponent:ctor(selfType)
  self.ShootingUIPanel = nil
  self.TouchStartTime = 0.0
  self.TouchEndTime = 0.0
  self.ToleranceDist = 300.0
  self.KeySelector_StartTime = "StartTime"
  self.KeySelector_FinishTime = "FinishTime"
  self.KeySelector_SpringArmLocation = "SpringArmLocation"
  self.KeySelector_LongTouchTime = "LongTouchTime"
  self.SkillUIData = {}
  self.NotSimulateStoppedNewSkillList = {
    [1032212] = true,
    [1040023] = true,
    [1013464] = true
  }
end
function SkillManagerComponent:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "SyncedDisabledSkillIDs",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
function SkillManagerComponent:_PostConstruct()
  SkillManagerComponent.__super._PostConstruct(self)
  FeatureUtil.ForEachFeatureCall(self, "_PostConstruct")
end
function SkillManagerComponent:ReceiveBeginPlay()
  print(bWriteLog and "SkillManagerComponent:ReceiveBeginPlay")
  SkillManagerComponent.__super.ReceiveBeginPlay(self)
  FeatureUtil.ForEachFeatureCall(self, "ReceiveBeginPlay")
  if not Client then
    local tAllSkillConfig = GamePlayTools.GetCurrentConfig("SkillConfig")
    if tAllSkillConfig and tAllSkillConfig.SyncDisableSkillIDs then
      self.SyncDisableSkillIDsConfig = tAllSkillConfig.SyncDisableSkillIDs
      if #self.SyncDisableSkillIDsConfig > 0 then
        self:AddControlEvent(self, "OnSkillDisableChangeDelegate", self._OnSkillDisableChange, self)
      end
    end
  end
end
function SkillManagerComponent:RecordSkillException(InOwner, InSkillID, InRole, InNetMode, InFuncName)
  if not Client then
    return
  end
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  if not GameReportUtils.CheckCanBugglyPostException("SkillServerTriggerException") then
    return
  end
  print(bWriteLog and "SkillManagerComponent:RecordSkillException SkillServerTriggerException")
  local IsLocallyControlled = false
  if slua.isValid(InOwner) and InOwner:IsLocallyControlled() then
    IsLocallyControlled = true
  end
  local SkillExceptionName = "SkillServerTriggerException"
  local SkillExceptionString = string.format(" SkillID:%d, Role:%d, NetMode:%s, FuncName:%s, IsLocallyControlled:%s", InSkillID, InRole, InNetMode, InFuncName, tostring(IsLocallyControlled))
  print(bWriteLog and "SkillManagerComponent:RecordSkillException SkillExceptionString:" .. SkillExceptionString)
  GameReportUtils.BugglyPostExceptionFull(SkillExceptionName, SkillExceptionString, true)
end
function SkillManagerComponent:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "SkillManagerComponent:ReceiveEndPlay")
  self.ShootingUIPanel = nil
  for SkillID, tWidgetData in pairs(self.SkillUIData) do
    if tWidgetData.LoadUIHandle then
      slua.CancelLoadUI(tWidgetData.LoadUIHandle)
    end
    local uSkillWidget = tWidgetData.uiWidget
    if slua.isValid(uSkillWidget) then
      uSkillWidget:RemoveSelf()
    end
  end
  self.SkillUIData = {}
  FeatureUtil.ForEachFeatureCall(self, "ReceiveEndPlay", EndPlayReason)
  SkillManagerComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function SkillManagerComponent:OnBPSkillManagerInitFinish()
  self:InitSkillConfig()
end
function SkillManagerComponent:_OnSkillDisableChange()
  local DisabledIDs = self.SyncedDisabledSkillIDs
  DisabledIDs:Clear()
  for _, SkillID in ipairs(self.SyncDisableSkillIDsConfig) do
    if self:IsSkillIDDisable(SkillID) then
      DisabledIDs:Add(SkillID)
    end
  end
  self.SyncedDisabledSkillIDs = DisabledIDs
  self:ForceNetUpdate()
end
function SkillManagerComponent:OnRep_SyncedDisabledSkillIDs()
  if Client then
    EventSystem:postEvent(EVENTTYPE_INGAME_SKILL, EVENTID_INGAME_SKILL_DISABLE_CHANGE)
  end
end
function SkillManagerComponent:IsSkillIDDisableOnClient(SkillID)
  if not self.SyncedDisabledSkillIDs then
    return false
  end
  for _, DisabledID in pairs(self.SyncedDisabledSkillIDs) do
    if DisabledID == SkillID then
      return true
    end
  end
  return false
end
function SkillManagerComponent:GetSkillCDBase(SkillID, Index)
  local baseData = self:GetSkillBaseData(SkillID)
  if not baseData then
    print(bWriteLog and string.format("SkillManagerComponent:GetSkillCDBase - GetSkillBaseData returned nil for SkillID:%d", SkillID))
    return nil
  end
  local SkillCDs = baseData.SkillCDs
  Index = Index or 0
  if not SkillCDs then
    print(bWriteLog and string.format("SkillManagerComponent:GetSkillCDBase - SkillCDs is nil for SkillID:%d", SkillID))
    return nil
  end
  local CDNum = SkillCDs:Num()
  if Index < CDNum and 0 <= Index then
    return SkillCDs:Get(Index)
  end
  print(bWriteLog and string.format("SkillManagerComponent:GetSkillCDBase - Index out of range, SkillID:%d, Index:%d, CDNum:%d", SkillID, Index, CDNum))
  return nil
end
function SkillManagerComponent:SetSkillCDTimeScale(SkillID, nScale, ScaleType)
  nScale = nScale == 0 and 0.001 or nScale
  local SkillCDs = self:GetSkillBaseData(SkillID).SkillCDs
  for Index, uSkillCDBase in pairs(SkillCDs) do
    if slua.isValid(uSkillCDBase) then
      uSkillCDBase:SetTimeScale(1.0 / nScale, ScaleType)
    end
  end
  self:UpdateSyncSkillCDData(SkillID)
end
function SkillManagerComponent:SetSkillCDIndexTimeScale(SkillID, SkillIndex, nScale, ScaleType)
  print(bWriteLog and "SkillManagerComponent:SetSkillCDIndexTimeScale", SkillID, SkillIndex, nScale, ScaleType)
  nScale = nScale == 0 and 0.001 or nScale
  local uSkillCDBase = self:GetSkillCDBase(SkillID, SkillIndex)
  if slua.isValid(uSkillCDBase) then
    uSkillCDBase:SetTimeScale(1.0 / nScale, ScaleType)
  end
  self:UpdateSyncSkillCDData(SkillID)
end
function SkillManagerComponent:SetAllSkillCDTimeScale(nScale)
  nScale = nScale == 0 and 0.001 or nScale
  _G.GlobalSkillCDTimeScale = 1.0 / nScale
end
function SkillManagerComponent:SetNewCD(SkillID, CDIndex, CDOperationData, bSetNewBase)
  print(bWriteLog and string.format("SkillManagerComponent:SetNewCD SkillID:%d, CDIndex:%d, CDOperationData:%s", SkillID, CDIndex, TableUtil.TableToString(CDOperationData)))
  local SetNewCDFunc = function(_SkillID, _CDIndex, _CDOperationData, _bSetNewBase)
    if 0 <= _CDIndex then
      local uSkillCDBase = self:GetSkillCDBase(_SkillID, _CDIndex)
      if slua.isValid(uSkillCDBase) then
        uSkillCDBase:SetNewCDByOperationData(_CDOperationData, _bSetNewBase)
      end
    else
      local SkillCDs = self:GetSkillBaseData(_SkillID).SkillCDs
      for Index, uSkillCDBase in pairs(SkillCDs) do
        if slua.isValid(uSkillCDBase) then
          uSkillCDBase:SetNewCDByOperationData(_CDOperationData, _bSetNewBase)
        end
      end
    end
  end
  if SkillID == -1 then
    for _slot, _SkillID in pairs(self.ButtonSlotToSkillID) do
      SetNewCDFunc(_SkillID, CDIndex, CDOperationData, bSetNewBase)
    end
  else
    SetNewCDFunc(SkillID, CDIndex, CDOperationData, bSetNewBase)
  end
  self:RequestSkillStates(true, false)
end
function SkillManagerComponent:UpdateTeamateSkillCD(SkillID)
  local tSkillConfig = SkillUtils.GetSkillConfig(SkillID)
  if tSkillConfig == nil then
    return
  end
  if tSkillConfig.TeammateSyncCDParams == nil then
    return
  end
  self:ResetTeammateSkillCDData()
  local uTeammateSkillCDRepData = slua.IndexReference(self, "TeammateSkillCDRepData")
  uTeammateSkillCDRepData.  local CDConfig = tSkillConfig.TeammateSyncCDParams
  local SkillCDs = self:GetSkillBaseData(SkillID).SkillCDs
  local CDIndex = CDConfig.CDIndex or 0
  if 0 < CDIndex and CDIndex <= SkillCDs:Num() then
    local uSkillCD = SkillCDs:Get(CDIndex - 1)
    if slua.isValid(uSkillCD) then
      local nMaxTime = uSkillCD:GetMaxTime()
      local nCurTime = uSkillCD:GetCurrentTime()
      local nTimeScale = uSkillCD:GetTimeScale()
      if uSkillCD.GetCurCount and 0 < uSkillCD:GetCurCount() then
        nCurTime = nMaxTime
      end
      local CurServerTime = GamePlayTools.GetServerWorldTimeSeconds()
      uTeammateSkillCDRepData.CDStartTime = CurServerTime - nCurTime / nTimeScale
      uTeammateSkillCDRepData.CDEndTime = CurServerTime + (nMaxTime - nCurTime) / nTimeScale
    end
  end
  local UseCountIndex = CDConfig.UseCountIndex or 0
  if 0 < UseCountIndex and UseCountIndex <= SkillCDs:Num() then
    local uSkillCD = SkillCDs:Get(UseCountIndex - 1)
    if slua.isValid(uSkillCD) then
      uTeammateSkillCDRepData.UseCount = uSkillCD:GetCurCount()
    end
  end
  self:UpdatePlayerStateTeamateSkillCD()
end
function SkillManagerComponent:UpdatePlayerStateTeamateSkillCD()
  local uPlayerCharacter = self:GetOwner()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.GetPlayerStateSafety then
    local uPlayerState = uPlayerCharacter:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) and uPlayerState and uPlayerState.SkillCDRepFeature then
      uPlayerState.SkillCDRepFeature:UpdateTeamateSkillCD(self.TeammateSkillCDRepData)
    end
  end
end
function SkillManagerComponent:IsSkillNeedPackageVerify(SkillID)
  return SkillID == 1040014 or SkillID == 1040008 or SkillID == 1040012 or SkillID == 1040001
end
function SkillManagerComponent:InitSkillCD(uSkill)
  if not slua.isValid(uSkill) or not slua.isValid(self.Object) then
    print(bWriteLog and "SkillManagerComponent:InitSkillCD InValid Skill")
    return
  end
  local SkillID = uSkill.SkillID
  print(bWriteLog and string.format("SkillManagerComponent:InitSkillCD - Start SkillID:%d", SkillID))
  local tSkillConfig = SkillUtils.GetSkillConfig(SkillID)
  if tSkillConfig == nil then
    print(bWriteLog and string.format("SkillManagerComponent:InitSkillCD - GetSkillConfig returned nil for SkillID:%d, CD will NOT be created", SkillID))
    return
  end
  if not tSkillConfig.SkillCDParams then
    print(bWriteLog and string.format("SkillManagerComponent:InitSkillCD - SkillCDParams is nil for SkillID:%d, no CD to create", SkillID))
  else
    print(bWriteLog and string.format("SkillManagerComponent:InitSkillCD - SkillCDParams found for SkillID:%d, count:%d", SkillID, #tSkillConfig.SkillCDParams))
  end
  local baseData = self.SkillBaseDataMaps:Get(SkillID)
  if not slua.isValid(baseData) then
    print(bWriteLog and string.format("SkillManagerComponent:InitSkillCD - SkillBaseDataMaps has no valid baseData for SkillID:%d", SkillID))
  end
  if slua.isValid(baseData) then
    local SkillCDs = slua.IndexReference(baseData, "SkillCDs")
    SkillCDs:Clear()
    if tSkillConfig.SkillCDParams then
      for _, v in ipairs(tSkillConfig.SkillCDParams) do
        local skillCDClass = import("UTSkillCDBase")
        local uSkillCDBase = CGame:NewObjectFromClass(self, skillCDClass, "None")
        uSkillCDBase.OwnerSkillManager = self.Object
        uSkillCDBase.OwnerSkill = uSkill
        print(bWriteLog and "SkillManagerComponent:InitSkillConfig", SkillID, uSkillCDBase)
        if slua.isValid(uSkillCDBase) then
          uSkillCDBase:BindLua(v.SkillCDClass)
          local bClient = Client ~= nil
          local SkillLevel = self:GetSkillLevel(SkillID)
          if v.LevelParams then
            uSkillCDBase:InitSkillLevelParams(bClient, v.LevelParams, SkillLevel)
          else
            uSkillCDBase:InitSkillParams(bClient, v.Params)
          end
          uSkillCDBase:InitData()
          SkillCDs:Add(uSkillCDBase)
        end
      end
    end
    self.SkillBaseDataMaps:Add(SkillID, baseData)
  end
end
function SkillManagerComponent:ReInitSkillCD(uSkill)
  if not slua.isValid(uSkill) then
    print(bWriteLog and "SkillManagerComponent:ReInitSkillCD InValid Skill")
    return
  end
  local SkillID = uSkill.SkillID
  local tSkillConfig = SkillUtils.GetSkillConfig(SkillID)
  if tSkillConfig == nil or tSkillConfig.SkillCDParams == nil then
    return
  end
  local baseData = self.SkillBaseDataMaps:Get(SkillID)
  if slua.isValid(baseData) then
    local SkillCDs = baseData.SkillCDs
    for Index, uSkillCDBase in pairs(SkillCDs) do
      local CDParams = tSkillConfig.SkillCDParams[Index + 1]
      if CDParams and slua.isValid(uSkillCDBase) then
        uSkillCDBase.OwnerSkill = uSkill
        local bClient = Client ~= nil
        local SkillLevel = self:GetSkillLevel(SkillID)
        if CDParams.LevelParams then
          uSkillCDBase:InitSkillLevelParams(bClient, CDParams.LevelParams, SkillLevel)
        else
          uSkillCDBase:InitSkillParams(bClient, CDParams.Params)
        end
        if not tSkillConfig.SkillCDParams.IgnoreInitDataOnReinit then
          uSkillCDBase:InitData()
        end
      end
    end
  end
end
function SkillManagerComponent:HandleLoadSkillUI(SkillID, SkillTemplateID, Callback)
  if not Client then
    return
  end
  local RealOwnerRoleSafety = self.GetRealOwnerRoleSafety and self:GetRealOwnerRoleSafety() or "nil"
  local OwnerRole = self:GetOwner() and self:GetOwner().Role or "nil"
  print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI", SkillID, SkillTemplateID, RealOwnerRoleSafety, OwnerRole, self:IsSkillActived(SkillID))
  self:InitSkillUIPanel()
  local tSkillConfig = SkillUtils.GetSkillConfig(SkillID)
  if tSkillConfig == nil then
    print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI tSkillConfig is nil", SkillID)
    return
  end
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState:GetGameModeState() == "FinishedState" and not self:IsSkillActived(SkillID) then
    return
  end
  if not self.SkillUIData[SkillID] then
    self.SkillUIData[SkillID] = {}
  end
  if self.SkillUIData[SkillID].LoadUIHandle then
    return
  end
  if self.SkillUIData[SkillID].uiWidget then
    return
  end
  local SkillWidgetParams = tSkillConfig.SkillWidgetParams
  if not SkillWidgetParams then
    print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI SkillWidgetParams is nil", SkillID)
    return
  end
  if not slua.isValid(self.ShootingUIPanel) then
    self.SkillUIData[SkillID].bWaitLoad = true
    print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI ShootingUIPanel is nil")
    return
  end
  local tMountData = SkillWidgetParams.MountData and SkillWidgetParams.MountData or {}
  local SkillModMountPanel = self:GetModSkillMountPanel(SkillID, tMountData)
  if not SkillModMountPanel then
    self.SkillUIData[SkillID].bWaitLoad = true
    print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI SkillModMountPanel is nil")
    return
  end
  self.SkillUIData[SkillID].bWaitLoad = false
  local uSkillWidget = self:GetSkillWidget(SkillID)
  if self:CanWidgetReuse(uSkillWidget, SkillWidgetParams) then
    self:HandleSkillUILoadFinish(SkillID, uSkillWidget, SkillWidgetParams, Callback)
  else
    print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI AsyncLoadUI", SkillID, SkillTemplateID)
    if SkillWidgetParams.WidgetPath and SkillWidgetParams.WidgetPath ~= "" then
      print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI AsyncLoadUI Success", SkillID, SkillTemplateID)
      local LoadUIHandle = slua.AsyncLoadUI(SkillWidgetParams.WidgetPath, function(_, widget)
        self.SkillUIData[SkillID].LoadUIHandle = nil
        print(bWriteLog and "SkillManagerComponent:HandleLoadSkillUI AsyncLoadUI Callback", SkillID, SkillTemplateID)
        if SkillWidgetParams.WidgetClass and SkillWidgetParams.WidgetClass ~= "" and slua.isValid(widget) then
          widget:BindLua(SkillWidgetParams.WidgetClass)
        end
        self:HandleSkillUILoadFinish(SkillID, widget, SkillWidgetParams, Callback)
      end)
      if 0 < LoadUIHandle then
        self.SkillUIData[SkillID].      end
    end
  end
end
function SkillManagerComponent:CanWidgetReuse(uSkillWidget, SkillWidgetParams)
  if slua.isValid(uSkillWidget) then
    return string.gsub(UKismetSystemLibrary.GetClassPathName(uSkillWidget), "_C", "") == SkillWidgetParams.WidgetPath and uSkillWidget.LuaFilePath == SkillWidgetParams.WidgetClass
  end
  return false
end
function SkillManagerComponent:RemoveSkillUIWidget(SkillID)
  if not Client then
    return
  end
  print(bWriteLog and "SkillManagerComponent:RemoveSkillUIWidget SkillUI-", SkillID)
  if not self.SkillUIData then
    return
  end
  if not self.SkillUIData[SkillID] then
    return
  end
  self.SkillUIData[SkillID].bWaitLoad = false
  if self.SkillUIData[SkillID].LoadUIHandle then
    slua.CancelLoadUI(self.SkillUIData[SkillID].LoadUIHandle)
    self.SkillUIData[SkillID].LoadUIHandle = nil
    return
  end
  local uSkillWidget = self.SkillUIData[SkillID].uiWidget
  if slua.isValid(uSkillWidget) then
    uSkillWidget:Hide()
    uSkillWidget:RemoveFromParent()
    uSkillWidget:OnDestroy()
    self:CacheSkillWidget(SkillID, uSkillWidget)
  end
  self.SkillUIData[SkillID].uiWidget = nil
end
function SkillManagerComponent:HandleSkillUILoadFinish(SkillID, uSkillWidget, SkillWidgetParams, Callback)
  print(bWriteLog and "SkillManagerComponent:HandleSkillUILoadFinish SkillUI-", SkillID, uSkillWidget)
  if not slua.isValid(self.Object) then
    return
  end
  if not self.SkillUIData[SkillID] then
    return
  end
  if not slua.isValid(self.ShootingUIPanel) then
    print(bWriteLog and "SkillManagerComponent:HandleSkillUILoadFinish ShootingUIPanel is nil")
    return
  end
  local tMountData = SkillWidgetParams.MountData and SkillWidgetParams.MountData or {}
  local AttachTargetPanel = self:GetSkillMountPanel(SkillID, tMountData)
  if not slua.isValid(AttachTargetPanel) then
    print(bWriteLog and "SkillManagerComponent:HandleSkillUILoadFinish AttachTargetPanel is nil")
    return
  end
  if slua.isValid(uSkillWidget) then
    local bEnableSkillCD = false
    local baseData = self.SkillBaseDataMaps:Get(SkillID)
    if slua.isValid(baseData) and baseData.SkillCDs:Num() > 0 then
      bEnableSkillCD = true
    end
    if tMountData.bMountAsSlotChild then
      for i = 0, AttachTargetPanel:GetChildrenCount() - 1 do
        local uChildWidget = AttachTargetPanel:GetChildAt(i)
        if uChildWidget and uChildWidget:GetChildrenCount() == 0 then
          uChildWidget:AddChild(uSkillWidget)
          break
        end
      end
    elseif AttachTargetPanel.AddChild then
      AttachTargetPanel:AddChild(uSkillWidget)
    end
    uSkillWidget:SetParentWidgetRecursive(self.ShootingUIPanel)
    uSkillWidget:SetSkillManager(self.Object)
    uSkillWidget:SetSkillID(SkillID)
    uSkillWidget:SetRefreshSkillCD(bEnableSkillCD)
    uSkillWidget:InitSkillParams(SkillWidgetParams)
    uSkillWidget:InitWidget(false)
    if uSkillWidget.Slot then
      if uSkillWidget.Slot.SetPadding then
        if tMountData.MarginData then
          uSkillWidget.Slot:SetPadding(FMargin(tMountData.MarginData.Left, tMountData.MarginData.Top, tMountData.MarginData.Right, tMountData.MarginData.Bottom))
        else
          uSkillWidget.Slot:SetPadding(FMargin(0.0, 0.0, 0.0, 0.0))
        end
      else
        if tMountData.AnchorsData then
          uSkillWidget.Slot:SetAnchors(FAnchors(tMountData.AnchorsData.Minimum[1], tMountData.AnchorsData.Minimum[2], tMountData.AnchorsData.Maximum[1], tMountData.AnchorsData.Maximum[2]))
        else
          uSkillWidget.Slot:SetAnchors(FAnchors(0.0, 0.0, 1.0, 1.0))
        end
        if tMountData.MarginData then
          uSkillWidget.Slot:SetOffsets(FMargin(tMountData.MarginData.Left, tMountData.MarginData.Top, tMountData.MarginData.Right, tMountData.MarginData.Bottom))
        else
          uSkillWidget.Slot:SetOffsets(FMargin(0.0, 0.0, 0.0, 0.0))
        end
        if tMountData.Alignment then
          uSkillWidget.Slot:SetAlignment(FVector2D(tMountData.Alignment[1], tMountData.Alignment[2]))
        else
          uSkillWidget.Slot:SetAlignment(FVector2D(0.0, 0.0))
        end
        if tMountData.SizeData then
          uSkillWidget.Slot:SetSize(tMountData.SizeData)
        end
      end
    end
    uSkillWidget:Show()
    self.SkillUIData[SkillID].uiWidget = uSkillWidget
    if Callback then
      Callback(uSkillWidget)
    end
    local SkillModMountPanel = self:GetModSkillMountPanel(SkillID, tMountData)
    if SkillModMountPanel and SkillModMountPanel.OnSKillUIWidgetLoadFinish then
      SkillModMountPanel:OnSKillUIWidgetLoadFinish(SkillID, uSkillWidget, SkillWidgetParams)
    end
  end
end
function SkillManagerComponent:GetModSkillMountPanel(SkillID, tMountData)
  local ModMountPanelUIBase
  if tMountData.ModMountPanel == nil then
    tMountData.ModMountPanel = "SkillModButtonSlot"
  end
  if not tMountData.ModMountPanel then
    print(bWriteLog and "SkillManagerComponent:GetModSkillMountPanel find ModMountPanel failed 1 = ", SkillID)
    return nil
  end
  local ModMountPanelConfig = UIManager.UI_Config_InGame[tMountData.ModMountPanel]
  if ModMountPanelConfig then
    ModMountPanelUIBase = UIManager.GetUI(ModMountPanelConfig)
  end
  if ModMountPanelUIBase and ModMountPanelUIBase.CanMountSkillButtonToPanel and not ModMountPanelUIBase:CanMountSkillButtonToPanel(SkillID) then
    return false
  end
  return ModMountPanelUIBase
end
function SkillManagerComponent:GetSkillMountPanel(SkillID, tMountData)
  local AttachTargetPanel
  local ModMountPanelUIBase = self:GetModSkillMountPanel(SkillID, tMountData)
  if ModMountPanelUIBase then
    AttachTargetPanel = ModMountPanelUIBase.UIRoot
    local ButtonSlot = self:GetSkillButtonSlot(SkillID)
    if self:ShouldUseMountPanelBySlot(ButtonSlot, SkillID) then
      local MountCanvasPanel = ModMountPanelUIBase.UIRoot[string.format("CanvasPanel_Skill%d", ButtonSlot)]
      if MountCanvasPanel then
        AttachTargetPanel = MountCanvasPanel
      else
        print(bWriteLog and "SkillManagerComponent:GetSkillMountPanel find MountName failed 1 = ", SkillID)
      end
    elseif tMountData.MountName then
      local MountCanvasPanel = ModMountPanelUIBase.UIRoot[tMountData.MountName]
      if MountCanvasPanel then
        AttachTargetPanel = MountCanvasPanel
      else
        print(bWriteLog and "SkillManagerComponent:GetSkillMountPanel find MountName failed 2 = ", SkillID)
      end
    end
  else
    print(bWriteLog and "SkillManagerComponent:GetSkillMountPanel find MountName failed 3 = ", SkillID)
  end
  return AttachTargetPanel
end
function SkillManagerComponent:RefreshWaitLoadSkillUI()
  print(bWriteLog and "SkillManagerComponent:RefreshWaitLoadSkillUI")
  if self.SkillUIData then
    for SkillID, UIData in pairs(self.SkillUIData) do
      if UIData.bWaitLoad then
        local SkillTemplateID = SkillUtils.GetSkillTemplateID(SkillID)
        self:HandleLoadSkillUI(SkillID, SkillTemplateID)
      end
    end
  end
end
function SkillManagerComponent:GetSkillUIWidget(SkillID)
  if not self.SkillUIData[SkillID] then
    return nil
  end
  return self.SkillUIData[SkillID].uiWidget
end
function SkillManagerComponent:InitSkillUIPanel()
  if self.SkillUIRoot == nil then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
    if not ShootingUIPanel then
      print(bWriteLog and "SkillManagerComponent:InitSkillUIPanel !ShootingUIPanel")
      return
    end
    self.  end
end
function SkillManagerComponent:SetSkillButtonPreTouchTime(InDeltaTime)
  self.TouchStartTime = self.TouchEndTime + InDeltaTime
  print(bWriteLog and "SkillManagerComponent:HandleTriggerParamsEvent SetSkillButtonPreTouchTime InDeltaTime:", InDeltaTime, self.TouchStartTime)
end
SkillManagerComponent.MutexStrToEnumMap = {
  _Y = ESkillMutexType.ESMT_Y,
  XY = ESkillMutexType.ESMT_XY,
  X_ = ESkillMutexType.ESMT_X
}
function SkillManagerComponent:GetMutexRelation(CurSkill, NewSkill)
  local bShouldMonopolize = NewSkill.bShouldMonopolize and CurSkill.bShouldMonopolize
  local FinalMutexType = bShouldMonopolize and ESkillMutexType.ESMT_Y or ESkillMutexType.ESMT_XY
  local TempSkillCfg = CDataTable.GetTableData("SkillTable", CurSkill.SkillID)
  local InSkillCfg = CDataTable.GetTableData("SkillTable", NewSkill.SkillID)
  if not (TempSkillCfg and InSkillCfg) or TempSkillCfg.SkillTags_a:Num() == 0 or InSkillCfg.SkillTags_a:Num() == 0 then
    return FinalMutexType
  end
  for _, TempTag in pairs(TempSkillCfg.SkillTags_a) do
    local TempTagMutexConfig = CDataTable.GetTableData("SkillTagsMutexTable", TempTag)
    if TempTagMutexConfig then
      for _, InTag in pairs(InSkillCfg.SkillTags_a) do
        local MutexStr = TempTagMutexConfig[string.format("Key%d", InTag)]
        if MutexStr then
          local CurMutexType = SkillManagerComponent.MutexStrToEnumMap[MutexStr]
          if FinalMutexType < CurMutexType then
            FinalMutexType = CurMutexType
          end
        end
      end
    end
  end
  return FinalMutexType
end
function SkillManagerComponent:NeedSimulateStoppedNewSkill(InSkillID)
  return not self.NotSimulateStoppedNewSkillList[InSkillID]
end
function SkillManagerComponent:HandleGMDirectTriggerSkillEvent(SkillID, SkillPlayRet)
  local uPlayerCharacter = self:GetOwner()
  if slua.isValid(uPlayerCharacter) then
    local uPlayerController = uPlayerCharacter:GetPlayerControllerSafety()
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, string.format("CallGMLua PrintDirectTriggerSkillResult:%d %d", SkillID, SkillPlayRet))
  end
end
function SkillManagerComponent:GetCreativeOverrideCustomSkillID(SkillID)
  local Ret = -1
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() and self.CreativeSkillCompFeature then
    Ret = self.CreativeSkillCompFeature:GetCreativeOverrideCustomSkillID(SkillID)
  end
  return Ret or -1
end
function SkillManagerComponent:ShouldUseMountPanelBySlot(ButtonSlot, InSkillID)
  return 0 < ButtonSlot and ButtonSlot <= 4
end
local class = require("class")
local ComponentCls = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CSkillManagerComponent = class(ComponentCls, nil, SkillManagerComponent)
return CSkillManagerComponent
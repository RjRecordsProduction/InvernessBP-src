local LobbyPawn = {}
local UGameplayStatics = import("GameplayStatics")
local EAvatarSlotType = import("EAvatarSlotType")
local MACRO_AUTOTEST = false
local MACRO_HEADTYPE = 400
local MAX_DELAY_STOP_FRAME = 3
local DefaultAvatar = {}
function LobbyPawn:ctor(selfType)
  self.IsRecycled = false
  self.LoadedHeadFinishTag = false
  self.ReportCache = {}
  self.LobbyAvatarExceptionReport = false
  self.TimeTracerMap = {}
  self.curEquipingWeapon = nil
  self.bIsLobbyHandle = true
  self.bSetOnlyTickPoseWhenRendered = false
  self.bAllMeshLoaded = false
  self.bDisableClothTwoMesh = false
end
function LobbyPawn:ReceiveBeginPlay()
  print(bWriteLog and "LobbyPawn BeginPlay")
  LobbyPawn.__super.ReceiveBeginPlay(self)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  print(bWriteLog and "LobbyPawn BeginPlay-")
  self.bAllMeshLoaded = false
  self:AddControlEvent(self.CharacterAvatarComp2_BP, "OnAvatarEquipped", self.OnAvatarEquipFinish, self)
  self:AddControlEvent(self.CharacterAvatarComp2_BP, "OnAvatarAllMeshLoaded", self.OnAvatarAllMeshLoaded, self)
  self:AddControlEvent(self, "EmoteMontageStartEvent", self.OnPlayActionHandle, self, true)
  self:AddControlEvent(self, "EmoteStartWithMainCharacterConfigEvent", self.OnPlayActionHandle, self, false)
  self:AddControlEvent(self, "EmoteMontageFinishedEvent", self.OnEndActionHandle, self)
  self:AddControlEvent(self.CapsuleComponent, "OnInputTouchBegin", self.OnInputTouchBeginEvent, self)
  self:AddControlEvent(self.CapsuleComponent, "OnInputTouchEnd", self.OnInputTouchEndEvent, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_LOWDEVICE, self.OnGMSetLowLevel, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_COLLECT_UNLOCK_STATE_REFRESH, self.OnCollectStateUnlock, self)
  self.CharacterAvatarComp2_BP.bForceClientMode = true
  local ECollisionChannel = import("ECollisionChannel")
  self.CapsuleComponent:SetCollisionObjectType(ECollisionChannel.ECC_Camera)
  local ECollisionEnabled = import("ECollisionEnabled")
  self.Mesh:SetCollisionEnabled(ECollisionEnabled.NoCollision)
  self.LobbyPlayerKey = self.PlayerKey
  if Client then
    self.LobbyAvatarExceptionReport = HDmpveRemote.HDmpveRemoteConfigGetBool("LobbyAvatarExceptionReport", false)
    self.bDisableClothTwoMesh = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableClothTwoMesh", false)
  end
  self.bWeaponAnimOptimize = false
end
function LobbyPawn:ReceiveEndPlay(_)
  log(bWriteLog and "LobbyPawn:ReceiveEndPlay")
  self:CharStopEmoteByResId()
  if slua.isValid(self.curEquipingWeapon) then
    self.curEquipingWeapon:K2_DestroyActor()
  end
  self.curEquipingWeapon = nil
  self.BP_LobbyWeaponManager:OnDestroy()
  LobbyPawn.__super.ReceiveEndPlay(self)
end
function LobbyPawn:SetCanRotate(bIsCanRotate)
  self.canRotate = bIsCanRotate
end
function LobbyPawn:SetIsLobbyHandle(NewIsLobbyHandle)
  print(bWriteLog and "LobbyPawn:SetIsLobbyHandle NewIsLobbyHandle:" .. tostring(NewIsLobbyHandle))
  self.bIsLobbyHandle = NewIsLobbyHandle
end
function LobbyPawn:GetBPID(ItemID)
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(ItemID)
  if not itemCfg then
    return -1
  end
  return itemCfg.BPID
end
function LobbyPawn:_AutoTest()
  if MACRO_AUTOTEST then
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.OnPutonEquipmentEnd()
  end
end
function LobbyPawn:_CheckLobbyWeaponMgrCompValid()
  if not slua.isValid(self.BP_LobbyWeaponManager) then
    log_error("LobbyPawn:_AutoTest LobbyWeaponManagerComponent is not valid.")
    return false
  end
  return true
end
function LobbyPawn:_CheckLobbyPlayerEmoteCompValid()
  if not slua.isValid(self.LobbyPlayEmoteComponent_BP) then
    log_error("LobbyPawn:_AutoTest LobbyPlayEmoteComponent is not valid.")
    return false
  end
  return true
end
function LobbyPawn:_CheckCharacterAvatarCompValid()
  if not slua.isValid(self.CharacterAvatarComp2_BP) then
    log_error("LobbyPawn:_AutoTest CharacterAvatarComp2_BP is not valid.")
    return false
  end
  return true
end
function LobbyPawn:_CheckCurEquipingWeapon()
  if not slua.isValid(self.curEquipingWeapon) then
    log_error("LobbyPawn:_AutoTest curEquipingWeapon is not valid.")
    return false
  end
  return true
end
function LobbyPawn:GetCurUsingWeapon()
  return self.curEquipingWeapon
end
function LobbyPawn:IsHoldingWeapon()
  return slua.isValid(self.BP_LobbyWeaponManager) and slua.isValid(self.BP_LobbyWeaponManager:GetUsingWeapon())
end
function LobbyPawn:GetHoldingWeapon()
  if not self:_CheckLobbyWeaponMgrCompValid() then
    log(bWriteLog and "LobbyPawn:GetHoldingWeapon Error no valid weapon mgr ")
    return nil
  end
  return self.BP_LobbyWeaponManager:GetUsingWeapon()
end
function LobbyPawn:DelayResetClothSimulate()
  self:AddTimerOnce(0, function()
    if not slua.isValid(self.CharacterAvatarComp2_BP) then
      return
    end
    self.CharacterAvatarComp2_BP:ResetClothSimulate()
  end)
end
function LobbyPawn:OnAvatarAllMeshLoaded()
  if AvatarData.OpenTimeTracer then
    self.TimeTracerMap = {}
  end
  self.HeadIsVisible = true
  if not self.bHidden then
    self:HideWeapon(false)
  end
  if self.LoadedHeadFinishTag and self.PlayOnChangingHeadAcionID ~= 0 then
    print(bWriteLog and "LobbyPawn:OnAvatarEquipFinish5")
    local oldPlayOnChangingHeadAcionID = self.PlayOnChangingHeadAcionID
    self.PlayOnChangingHeadAcionID = 0
    self:CharPlayEmotebyResId(oldPlayOnChangingHeadAcionID, "Default")
  end
  self.LoadedHeadFinishTag = false
  local XSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.XSuitItemID or 0
  local GoldenSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.GoldenSuitItemID or 0
  log(bWriteLog and "LobbyPawn:OnAvatarAllMeshLoaded bAllMeshLoaded = " .. tostring(self.bAllMeshLoaded) .. " Mesh:" .. tostring(self.Mesh) .. " XSuitItemID = " .. XSuitItemID .. " GoldenSuitItemID = " .. GoldenSuitItemID)
  self.OnAvatarComponentAllMeshLoaded:BroadCast()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.OnAvatarAllMeshLoaded(self.PlayerUID)
  if self.bIsFpp and self.CharacterAvatarComp2_BP then
    self.CharacterAvatarComp2_BP:OnFppChanged(true)
  end
  self:AddTimer(0.2, function()
    self.bAllMeshLoaded = true
    EventSystem:postEvent(EVENTTYPE_LOBBY_PAWN, EVENTID_AVATAR_MESH_LOADED)
    log(bWriteLog and "LobbyPawn:OnAvatarAllMeshLoaded Timer bAllMeshLoaded = " .. tostring(self.bAllMeshLoaded) .. " Mesh:" .. tostring(self.Mesh) .. " XSuitItemID = " .. XSuitItemID .. " GoldenSuitItemID = " .. GoldenSuitItemID)
  end)
  self:_AutoTest()
end
function LobbyPawn:CharEquipWeaponByResId(resID, isUse, isAsync, SocketName)
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  if isUse == nil then
    isUse = true
  end
  if isAsync == nil then
    isAsync = true
  end
  if SocketName == nil or SocketName == "" then
    SocketName = self.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(resID)
  end
  self:PreEqiupWeapon(resID, SocketName)
  self.curEquipingWeapon = self.BP_LobbyWeaponManager:EquipWeaponByResId(resID, isUse, isAsync, SocketName)
  if self.IsPlayingAction == true or self.HeadIsVisible == false then
    self:HideWeapon(true)
  end
end
function LobbyPawn:PreEqiupWeapon(SkinID, SocketName)
  local CurrentUseWeaponID = self.BP_LobbyWeaponManager.CurUseWeaponID
  if not CurrentUseWeaponID or CurrentUseWeaponID <= 0 then
    log(bWriteLog and "LobbyPawn:PreEqiupWeapon not CurrentUseWeaponID")
    return
  end
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginSkinID = WeaponModelMgrHelper.GetRealResId(SkinID, true)
  local CurrentOriginID = WeaponModelMgrHelper.GetRealResId(CurrentUseWeaponID, true)
  if OriginSkinID and OriginSkinID == 108008 or CurrentOriginID and CurrentOriginID == 108008 then
    self:CharUnEquipWeaponByResId(CurrentUseWeaponID)
  end
end
function LobbyPawn:CharUnEquipWeaponByResId(resID, SocketName)
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  if SocketName == nil or SocketName == "" then
    SocketName = self.BP_LobbyWeaponManager:GetWeaponSocketNameByResId(resID)
  end
  self.BP_LobbyWeaponManager:UnEquipWeaponBySocketID2(SocketName)
  self.OnChangeWeapon:BroadCast()
end
function LobbyPawn:CharUnEquipExtraWeapon()
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  self.BP_LobbyWeaponManager:UnEquipAllExtraWeapon()
end
function LobbyPawn:CharUnEquipWeapon()
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  self.BP_LobbyWeaponManager:UnEquipAllWeapon()
  self.OnChangeWeapon:BroadCast()
end
function LobbyPawn:WeaponAllAssetLoadFinish()
  if not self.bHidden then
    self:HideWeapon(false)
  end
  self.OnChangeWeapon:BroadCast()
  self:ForceRefreshCharacterAnimation()
  self:_AutoTest()
end
function LobbyPawn:CharEquipWeaponPendant(weaponId, pendantSocketType, forcePendantID)
  if not self:_CheckCurEquipingWeapon() then
    return
  end
  local pendantID = 0
  log(bWriteLog and "LobbyPawn:CharEquipWeaponPendant weaponId" .. tostring(weaponId))
  if forcePendantID ~= nil and forcePendantID ~= 0 then
    local MapCfg = CDataTable.GetTableData("PendantMapCfg", forcePendantID)
    if MapCfg then
      pendantID = MapCfg.WeaponPendantID
    else
      pendantID = forcePendantID
    end
  else
    local UBackpackUtils = import("BackpackUtils")
    pendantID = UBackpackUtils.GetPendantIDByWeaponID(weaponId)
  end
  if pendantID == 0 then
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    pendantID = ItemUpgradeMgr:GetWeaponPendantID(weaponId, self.PlayerUID)
  end
  if pendantID == 0 then
    return
  end
  self.curEquipingWeapon:EquipWeaponPandentByPandentId(pendantID, pendantSocketType)
end
function LobbyPawn:RequestWeaponDIYData(playerUID, weaponAvatarID, diyPlanID)
  if not self:_CheckCurEquipingWeapon() then
    return
  end
  self.curEquipingWeapon:RequestWeaponDIYData(playerUID, weaponAvatarID, diyPlanID)
end
function LobbyPawn:HideWeapon(isHide, HideReason)
  log(bWriteLog and "LobbyPawn:HideWeapon isHide:" .. tostring(isHide))
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  if not self:_CheckLobbyPlayerEmoteCompValid() then
    return
  end
  local ELobbyWeaponHideReason = import("ELobbyWeaponHideReason")
  HideReason = HideReason or ELobbyWeaponHideReason.ELobbyWeaponHideReason_Default
  if isHide and self._DelayShowWeapon then
    log("LobbyPawn:HideWeapon cancel DelayShowWeapon " .. tostring(self._DelayShowWeapon))
    if self._DelayShowWeapon ~= true then
      self:RemoveTimer(self._DelayShowWeapon)
    end
    self._DelayShowWeapon = nil
  end
  if self.HeadIsVisible then
    if self.LobbyPlayEmoteComponent_BP.GetCurrentEmoteID and self.LobbyPlayEmoteComponent_BP:GetCurrentEmoteID() == -1 or HideReason ~= ELobbyWeaponHideReason.ELobbyWeaponHideReason_Default then
      if not isHide and self._DelayShowWeapon then
        log(bWriteLog and "LobbyPawn:HideWeapon DelayShowWeapon")
        if self._DelayShowWeapon == true then
          self._DelayShowWeapon = self:AddTimerOnce(0.1, function()
            self._DelayShowWeapon = nil
            self:HideWeapon(isHide, HideReason)
          end)
        end
      else
        self.BP_LobbyWeaponManager:SetWeaponHidden(isHide, HideReason)
      end
    else
      self:HandleWeaponDisplayWhenPlayEmote()
    end
  else
    self.BP_LobbyWeaponManager:SetWeaponHidden(true, HideReason)
  end
end
function LobbyPawn:HandleWeaponDisplayWhenPlayEmote()
  log(bWriteLog and "LobbyPawn:HandleWeaponDisplayWhenPlayEmote isHide:")
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  local shouldShow = self:ShouldCurEmoteShowWeapon()
  local ELobbyWeaponHideReason = import("ELobbyWeaponHideReason")
  self.BP_LobbyWeaponManager:SetWeaponHidden(not shouldShow, ELobbyWeaponHideReason.ELobbyWeaponHideReason_Default)
end
function LobbyPawn:ShouldCurEmoteShowWeapon()
  if slua.isValid(self.CurEmoteHandle) then
    return self.CurEmoteHandle.ShowWeaponWhenPlay
  end
  return true
end
function LobbyPawn:MarkDelayShowWeapon()
  log("LobbyPawn:MarkDelayShowWeapon HideWeapon")
  if self._DelayShowWeapon and self._DelayShowWeapon ~= true then
    log("LobbyPawn:DelayShowWeapon alreadyTimer")
    return
  end
  self._DelayShowWeapon = true
end
function LobbyPawn:CharPlayEmoteByResId(emoteID, extraInfo, extraParam)
  log(bWriteLog and string.format("LobbyPawn:CharPlayEmoteByResId emoteID=%d extraInfo=%s IsChangingHead=%s HeadIsVisible=%s LobbyPlayEmoteComponent_BP=%s", emoteID, tostring(extraInfo), tostring(self.IsChangingHead), tostring(self.HeadIsVisible), tostring(self.LobbyPlayEmoteComponent_BP)))
  if self.IsChangingHead == true or self.HeadIsVisible == false then
    log(bWriteLog and "LobbyPawn:CharPlayEmoteByResId--  1321321")
    self.PlayOnChangingHeadAcionID = emoteID
  else
    self.LocationBeforeEmote = self:K2_GetActorLocation()
    self:OnPlayEmote(emoteID, extraInfo)
    self.OnPlayAction:BroadCast(emoteID)
    self.CurrentActionID = emoteID
    self.DisableModelDisplayerCallback = extraParam and extraParam.DisableModelDisplayerCallback
  end
end
function LobbyPawn:CharStopEmoteByResId(bDelayStop)
  if not self:_CheckLobbyPlayerEmoteCompValid() then
    return
  end
  local CurrentEmoteID = self.LobbyPlayEmoteComponent_BP:GetCurrentEmoteID()
  if CurrentEmoteID == -1 then
    log(bWriteLog and "LobbyPawn:CharStopEmoteByResId No Emotions are currently playing.")
    return
  end
  log(bWriteLog and "LobbyPawn:CharStopEmoteByResId OnStopEmote CurrentEmoteID = " .. CurrentEmoteID .. " LobbyPlayEmoteComponent_BP = " .. tostring(self.LobbyPlayEmoteComponent_BP) .. " bDelayStop = " .. tostring(bDelayStop))
  self.OnStopAction:BroadCast(0)
  self:SetTeamupAnimPlayingState(false)
  self:HideWeapon(false)
  self.CurrentActionID = 0
  if bDelayStop then
    self.LobbyPlayEmoteComponent_BP.MaxDelayStopFrame = MAX_DELAY_STOP_FRAME
  else
    self.LobbyPlayEmoteComponent_BP.MaxDelayStopFrame = 0
  end
  self:OnStopEmote()
end
function LobbyPawn:PreparePlayEmote(emoteID, bDirectLoad)
  if not slua.isValid(self.LobbyPlayEmoteComponent_BP) then
    log_error("LobbyPawn:PreparePlayEmote LobbyPlayEmoteComponent is not valid.")
    return false
  end
  return self.LobbyPlayEmoteComponent_BP:PreparePlayEmote(emoteID, bDirectLoad or false)
end
function LobbyPawn:CancelPrepareEmote(emoteID)
  if not slua.isValid(self.LobbyPlayEmoteComponent_BP) then
    log_error("LobbyPawn:CancelPrepareEmote LobbyPlayEmoteComponent is not valid.")
    return false
  end
  return self.LobbyPlayEmoteComponent_BP:CancelPrepareEmote(emoteID)
end
function LobbyPawn:GetEmoteHandle(emoteID)
  if self.EmoteItemIDToHandleMap:Get(emoteID) then
    self.CurEmoteHandle = self.EmoteItemIDToHandleMap:Get(emoteID)
  else
    local bpID = self:GetBPID(emoteID)
    if bpID == -1 then
      log_error("LobbyPawn:GetEmoteHandle. No bpID. emoteID = " .. tostring(emoteID))
      return nil
    end
    local BusinessHelper = import("BusinessHelper")
    local BackpackEmoteHandleClass = import("BackpackEmoteHandle")
    local forceLobbyMap = {
      [12220010] = true,
      [12220011] = true,
      [12219050] = true,
      [12219097] = true,
      [12219099] = true,
      [12219678] = true,
      [12219679] = true
    }
    local bIsLobbyHandle = forceLobbyMap[emoteID] or self.bIsLobbyHandle
    local model_util = require("client.common.model_util")
    local handleClass = model_util.GetClass("Emote", bpID, bIsLobbyHandle, false)
    if not handleClass then
      log_error("LobbyPawn:GetEmoteHandle. EmoteCfg handleClass is nil. emoteID = " .. tostring(emoteID))
      return nil
    end
    local handle = handleClass()
    if not BusinessHelper.IsClassOf(handle, BackpackEmoteHandleClass) then
      log_error("LobbyPawn:GetEmoteHandle. Cast to BackpackEmoteHandle failed. emoteID = " .. tostring(emoteID))
      return nil
    end
    self.EmoteItemIDToHandleMap:Add(emoteID, handle)
    self.CurEmoteHandle = handle
  end
  print(bWriteLog and "LobbyPawn:GetEmoteHandle EmoteID" .. tostring(emoteID) .. " Handle:" .. tostring(self.CurEmoteHandle))
  self:CheckBPMappingTable(emoteID)
  return self.CurEmoteHandle
end
function LobbyPawn:CheckBPMappingTable(emoteID)
  if not Client or not Client.IsDevelopment() then
    return
  end
  if not (self.CurEmoteHandle and self.CurEmoteHandle.EmoteActionList) or self.CurEmoteHandle.EmoteActionList:Num() <= 0 then
    return
  end
  local StringUtil = require("common.string_util")
  local BPMappingTable = CDataTable.GetTableData("BPMappingTable", emoteID)
  for _, value in pairs(self.CurEmoteHandle.EmoteActionList) do
    if value and value.LevelNames and 0 < value.LevelNames:Num() then
      if not (BPMappingTable and BPMappingTable.DependPath) or BPMappingTable.DependPath == "" then
        ShowDevNotice("###\231\173\150\229\136\146\230\188\143\233\133\141\228\186\134\232\147\157\229\155\190\232\181\132\230\186\144\229\133\179\232\129\148\232\161\168(\229\138\168\228\189\156\228\190\157\232\181\150\229\156\186\230\153\175\228\184\139\232\189\189)")
        break
      end
      for _, lvlName in pairs(value.LevelNames) do
        local bBreak = false
        if lvlName and lvlName ~= "" and not StringUtil.StrFind(lvlName, "_Light") then
          local arrDependPaths = StringUtil.Split(BPMappingTable.DependPath, "|")
          for _, v in pairs(arrDependPaths) do
            if v and v ~= "" and not StringUtil.StrFind(v, lvlName) then
              ShowDevNotice("###\231\173\150\229\136\146\233\133\141\233\148\153\228\186\134\232\147\157\229\155\190\232\181\132\230\186\144\229\133\179\232\129\148\232\161\168(\229\138\168\228\189\156\228\190\157\232\181\150\229\156\186\230\153\175\228\184\139\232\189\189)")
              bBreak = true
              break
            end
          end
        end
        if bBreak then
          break
        end
      end
    end
  end
end
function LobbyPawn:OnPostGetEmoteHandle()
  self:HandleWeaponDisplayWhenPlayEmote()
end
function LobbyPawn:OnPlayActionHandle(bPlayWeaponAction, actionID)
  print(bWriteLog and "LobbyPawn:OnPlayActionHandle actionID:" .. tostring(actionID))
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  if logic_store_enter_feature then
    logic_store_enter_feature:RestoreAsyncLoadingTimeLimit()
  end
  local UniqueEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UniqueEmoteManager)
  UniqueEmoteManager:OnPlayActionHandle(self, actionID)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.PlayMockSoundAsync(self.PlayerUID)
  self:SetAnimIgnoreWeaponHide(true)
  self:UpdateTeamupAnimPlayingState(actionID)
  self:HideWeapon(true)
  self:DelayResetClothSimulate()
  if self.bDisableClothTwoMesh then
    self.CharacterAvatarComp2_BP:AddDisableClothRequest("Emote", EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  end
  self.IsPlayingAction = true
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.OnEmotionStart(actionID)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PLAY_START, self.CharacterAvatarComp2_BP, actionID)
end
function LobbyPawn:GetEmoteExtraInfo()
  if self.LobbyPlayEmoteComponent_BP.GetEmoteExtraInfo then
    return self.LobbyPlayEmoteComponent_BP:GetEmoteExtraInfo()
  end
  return "Default"
end
function LobbyPawn:OnInputTouchBeginEvent(nFinerIndex, _)
  print(bWriteLog and "LobbyPawn:OnInputTouchBeginEvent", nFinerIndex)
  self.fingerIndex = nFinerIndex
  self.press = true
  local UIUtil = require("client.common.ui_util")
  local PlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  local nLocationX = PlayerController:GetInputTouchState(nFinerIndex, nil, nil, nil)
  self.locationX = nLocationX
  self.CharacterAvatarComp2_BP:EnableAvatarAnimation(true)
end
function LobbyPawn:OnInputTouchEndEvent(_, _)
  print(bWriteLog and "LobbyPawn:OnInputTouchEndEvent")
  self.press = false
  self:TickClothLeten(self.Inten)
end
function LobbyPawn:OnWeaponAllAssetLoadFinish()
  self:WeaponAllAssetLoadFinish()
end
function LobbyPawn:SetClothAnimDyAlphaValue(nAlpha)
  self.ClothAnimDyAlpha = nAlpha
end
function LobbyPawn:OnEndActionHandle(actionID)
  print(bWriteLog and "LobbyPawn:OnEndActionHandle actionID:" .. tostring(actionID))
  local useSeqCfg = CDataTable.GetTableData("TeamEmoteSeqCfg", actionID)
  if useSeqCfg and useSeqCfg.UseSeq then
    log(bWriteLog and "LobbyPawn:OnEndActionHandle UseSeq " .. tostring(actionID))
    self:AddTimerOnce(0, function()
      log(bWriteLog and "LobbyPawn:OnEndActionHandle delay UseSeq " .. tostring(actionID))
      if slua.isValid(self.LobbyPlayEmoteComponent_BP) then
        self.LobbyPlayEmoteComponent_BP.isPlayCameraAnim = false
        self.LobbyPlayEmoteComponent_BP.bUseSequenceCamera = true
      end
    end)
  end
  self:DelayResetClothSimulate()
  self.CharacterAvatarComp2_BP:RemoveDisableClothRequest("Emote", EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local UniqueEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UniqueEmoteManager)
  UniqueEmoteManager:OnEndActionHandle(self, actionID)
  self:SetAnimIgnoreWeaponHide(false)
  self:HideWeapon(false)
  self:TryPlaySpecialIdlePreAction(actionID)
  if self.bIsEmoteLooping then
    self:PlayEmoteLoop()
  else
    self.CurrentActionID = 0
  end
  self.IsPlayingAction = false
  self:HandleGoldSpecialAction(actionID)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if not self.DisableModelDisplayerCallback then
    ModelDisplayer.OnEmotionEnd(actionID)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, actionID, self.CharacterAvatarComp2_BP)
end
function LobbyPawn:CheckEmoteAction(Action, actionID)
  local UniqueEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UniqueEmoteManager)
  if not UniqueEmoteManager:CheckUnique(self, actionID, Action) then
    return false
  end
  if not UniqueEmoteManager:CheckXmissionLobby(self, actionID, Action) then
    return false
  end
  return true
end
function LobbyPawn:PlayEmoteLoop()
  if not self:_CheckLobbyWeaponMgrCompValid() then
    return
  end
  local weaponBattleEffectCfg = CDataTable.GetTableData("WeaponAvatarBattleEffect", self.BP_LobbyWeaponManager.CurUseWeaponID)
  if not weaponBattleEffectCfg then
    log(bWriteLog and "LobbyPawn:PlayEmoteLoop weaponBattleEffectCfg is nil. CurUseWeaponID = " .. tostring(self.BP_LobbyWeaponManager.CurUseWeaponID))
    return
  end
  if weaponBattleEffectCfg.EmotionID <= 0 then
    log(bWriteLog and "LobbyPawn:PlayEmoteLoop EmotionID is not valid. CurUseWeaponID = " .. tostring(self.BP_LobbyWeaponManager.CurUseWeaponID))
    return
  end
  self:CharPlayEmoteByResId(weaponBattleEffectCfg.EmotionID, "Default")
  self.bIsEmoteLooping = true
end
function LobbyPawn:SetIsMVPMotion(isMVPMotion)
  self.end
function LobbyPawn:GetCurrentActionID()
  return self.CurrentActionID
end
function LobbyPawn:EnableClothAndHairAnimation(isEnable)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  self.CharacterAvatarComp2_BP:EnableAvatarAnimation(isEnable)
end
function LobbyPawn:StopActionCamera()
  if not self:_CheckLobbyPlayerEmoteCompValid() then
    return
  end
  self.LobbyPlayEmoteComponent_BP:StopCameraEmoteAnim()
end
function LobbyPawn:SetForceUseDefaultIdle(isForce)
  self.ForceUseDefaultIdle = isForce
  self.OnSetForceUseDefaultIdle:BroadCast(isForce)
end
function LobbyPawn:SetPoseInCollectionHall(AnimSeq)
  self.OnSetPoseInCollectionHall:BroadCast(AnimSeq)
end
function LobbyPawn:PutOnEquipmentByResID(resID, CustomData)
  log(bWriteLog and "LobbyPawn:PutOnEquipmentByResID " .. tostring(resID))
  if not self:_CheckLobbyPlayerEmoteCompValid() then
    return false
  end
  if not self:_CheckCharacterAvatarCompValid() then
    return false
  end
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(resID)
  if not itemCfg then
    return false
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  local nColorID = CustomData and CustomData.ColorID or 0
  local stateCheckItemID = 0 < nColorID and AvatarUtil.ConvertUnderWearID(resID, nColorID) or resID
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {stateCheckItemID})
  if state ~= PufferConst.ENUM_DownloadState.Done and not CDataTable.GetTableData("UseIntBeforeDownload", resID) then
    return false
  end
  if AvatarUtil.NeedDoubleCheck(resID) then
    local CheckResult = self:DoubleCheckResource(resID)
    if CheckResult == false then
      return false
    end
  end
  if itemCfg.ItemSubType == MACRO_HEADTYPE then
    print(bWriteLog and "Set IsChangingHead", true)
    self.IsChangingHead = true
  end
  self.LobbyPlayEmoteComponent_BP:OnEquipmentChange(resID, true)
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    local StartTime = TimeUtil.GetMicroseconds()
    self.TimeTracerMap[resID] = StartTime
  end
  self.bAllMeshLoaded = false
  self:AddControlEvent(self.CharacterAvatarComp2_BP, "OnAvatarEquippedFailedEvent", self.OnPutOnEquipmentByResIDFailed, self, resID, CustomData, itemCfg.ItemSubType)
  self.OnPreChangeEquip:BroadCast()
  local result = self.CharacterAvatarComp2_BP:PutOnCustomEquipmentByID(resID, CustomData)
  self.OnChangeEquipment:BroadCast()
  return result
end
function LobbyPawn:_CheckSingleAvatarResource(resID)
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  local HandlePath = AvatarUtil.GetAvatarHandlePath(resID)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local pakName = PufferManager.GetPakName(HandlePath)
  if not AvatarUtil.DoubleCheckIsDownLoadFinish(resID, pakName) then
    log_error(bWriteLog and "LobbyPawn:DoubleCheckResource DoubleCheckIsDownLoadFinish false resID:" .. tostring(resID))
    self:ReportAvatarEmpty(resID, HandlePath, pakName, "DownloadTrueButPakNotExist")
    return false
  end
  HandlePath = HandlePath or ""
  local StringUtil = require("common.string_util")
  local _res = StringUtil.Split(HandlePath, ".")
  local HandleGamePath = _res[1]
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(HandleGamePath) then
    log_error(bWriteLog and "LobbyPawn:DoubleCheckResource PakExistHandleNotExist HandleGamePath:" .. tostring(HandleGamePath))
    self:ReportAvatarEmpty(resID, HandlePath, pakName, "PakExistHandleNotExist")
    return false
  end
  return true
end
function LobbyPawn:DoubleCheckResource(resID)
  if not self:_CheckSingleAvatarResource(resID) then
    return false
  end
  local suitsCfg = CDataTable.GetTableData("AvatarSuitsTable", resID)
  if not suitsCfg then
    return true
  end
  local StringUtil = require("common.string_util")
  local bMale = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.NetAvatarData.Gender == 0
  local suitItems
  if bMale then
    suitItems = StringUtil.Split(suitsCfg.MaleSuits, "|")
  else
    suitItems = StringUtil.Split(suitsCfg.FemaleSuits, "|")
  end
  if not suitItems then
    return true
  end
  for slotId, partIdStr in pairs(suitItems) do
    local partId = tonumber(partIdStr)
    if partId and 0 < partId and partId ~= resID and not self:_CheckSingleAvatarResource(partIdStr) then
      return false
    end
  end
  return true
end
function LobbyPawn:ReportAvatarEmpty(resID, HandlePath, pakName, ErrorReason)
  log(bWriteLog and "LobbyPawn:ReportAvatarEmpty " .. tostring(resID) .. " ErrorReason:" .. tostring(ErrorReason))
  if not self.LobbyAvatarExceptionReport then
    log(bWriteLog and "LobbyPawn:ReportAvatarEmpty is not Open")
    return
  end
  if not PufferDownloader.InitSuccess then
    return
  end
  if self.ReportCache[resID] then
    return
  end
  self.ReportCache[resID] = true
  local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. pakName
  local fileSizePak = Client.GetFileSizeOnDiskBytes(filePathPak)
  local count = 0
  if LobbySystem.roleData.encryption_info then
    for k, v in pairs(LobbySystem.roleData.encryption_info) do
      count = count + 1
    end
  end
  local StringError = " resID:" .. tostring(resID) .. " HandlePath:" .. tostring(HandlePath) .. " pakName:" .. tostring(pakName) .. " fileSizePak:" .. tostring(fileSizePak) .. "encryption_info count:" .. tostring(count)
  log(bWriteLog and "LobbyPawn:ReportAvatarEmpty Report " .. StringError)
  Client.AddAttachFileString(ErrorReason, true, StringError)
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  ReportPlatformCrashKit:ForceSend(tostring(ErrorReason) .. ":ItemHandle Load Failed " .. StringError)
end
function LobbyPawn:OnPutOnEquipmentByResIDFailed(resID, CustomData, itemSubType, slotID, InItemDefineID)
  log(bWriteLog and "LobbyPawn:OnPutOnEquipmentByResIDFailed - slotID=" .. tostring(slotID) .. "resID:" .. tostring(resID) .. " InItemDefineID=" .. tostring(InItemDefineID and InItemDefineID.TypeSpecificID) .. " itemSubType=" .. tostring(itemSubType))
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  if InItemDefineID and resID ~= InItemDefineID.TypeSpecificID then
    log(bWriteLog and "LobbyPawn:OnPutOnEquipmentByResIDFailed resID not equal InItemDefineID.TypeSpecificID")
    return
  end
  if 0 <= slotID then
    return
  end
  local slotMappingCfg = CDataTable.GetTableData("LobbyBattleSlotMapping", itemSubType)
  if not slotMappingCfg then
    return
  end
  local itemDefineID = self.CharacterAvatarComp2_BP.DefaultAvataConfig:Get(slotMappingCfg.battleSlot)
  if itemDefineID then
    if InItemDefineID and InItemDefineID.TypeSpecificID == itemDefineID.TypeSpecificID then
      print(bWriteLog and "LobbyPawn:OnPutOnEquipmentByResIDFailed InItemDefineID == TypeSpecificID" .. tostring(InItemDefineID))
      return
    end
    self.CharacterAvatarComp2_BP:PutOnCustomEquipmentByID(itemDefineID.TypeSpecificID, CustomData)
  else
    self:PutOffEquipmentBySlot(slotMappingCfg.battleSlot)
  end
end
function LobbyPawn:UnEquipByResID(resID)
  if not self:_CheckLobbyPlayerEmoteCompValid() then
    return false
  end
  if not self:_CheckCharacterAvatarCompValid() then
    return false
  end
  self.LobbyPlayEmoteComponent_BP:OnEquipmentChange(resID, false)
  local result = self.CharacterAvatarComp2_BP:PutOffEquimentByResID(resID)
  self.OnChangeEquipment:BroadCast()
  return result
end
function LobbyPawn:PutOffEquipmentBySlot(slotType)
  if not self:_CheckCharacterAvatarCompValid() then
    return false
  end
  local result = self.CharacterAvatarComp2_BP:HandleUnequipSlot(slotType)
  self.OnChangeEquipment:BroadCast()
  return result
end
function LobbyPawn:GetAllEquipmentList()
  local allEquipmentList = {}
  local LogicSlotDesc = slua.IndexReference(self.CharacterAvatarComp2_BP, "LogicSlotDesc")
  for index, value in pairs(LogicSlotDesc) do
    local itemID = value.ItemDefineID.TypeSpecificID
    if 0 < itemID then
      table.insert(allEquipmentList, itemID)
    end
  end
  return allEquipmentList
end
function LobbyPawn:GetAllEquipmentListMoreInfo()
  if not self:_CheckCharacterAvatarCompValid() then
    return {}
  end
  local allEquipmentList = {}
  for _, v in pairs(EAvatarSlotType) do
    local itemID, CustomData = self:GetEquipmentInfoBySlot(v)
    if 0 < itemID then
      local itemDefineID = FItemDefineID(self.CharacterAvatarComp2_BP.ItemType, itemID)
      if not self.CharacterAvatarComp2_BP:IsDefautlAvatarID(itemDefineID) then
        local CustomDataTable = {}
        for key, value in pairs(CustomData) do
          CustomDataTable[key] = value
        end
        CustomDataTable.ItemID = itemID
        table.insert(allEquipmentList, CustomDataTable)
      end
    end
  end
  return allEquipmentList
end
function LobbyPawn:GetEquipmentInfoBySlot(slotType)
  if not self:_CheckCharacterAvatarCompValid() then
    return 0, 0, 0
  end
  local avatarSlotDesc = self.CharacterAvatarComp2_BP.LogicSlotDesc:Get(slotType)
  if avatarSlotDesc then
    return avatarSlotDesc.ItemDefineID.TypeSpecificID, slua.IndexReference(avatarSlotDesc, "CustomInfo"):clone()
  else
    return 0, {}
  end
end
function LobbyPawn:IsItemHasEquipped(itemID, tAvatarCustom)
  if not self:_CheckCharacterAvatarCompValid() then
    return false
  end
  tAvatarCustom = tAvatarCustom or {}
  local nColorID = tAvatarCustom.ColorID or 0
  local nPatternID = tAvatarCustom.PatternID or 0
  if nColorID <= 0 or nPatternID <= 0 then
    return self.CharacterAvatarComp2_BP:IsItemHasEquipped_Origin(itemID)
  end
  for _, v in pairs(self.CharacterAvatarComp2_BP.LogicSlotDesc) do
    if v.ItemDefineID.TypeSpecificID == itemID and v.CustomInfo.ColorID == nColorID and v.CustomInfo.PatternID == nPatternID then
      return true
    end
  end
  return false
end
function LobbyPawn:InitDefaultAvatarByResID(gender, headID, hairID)
  log(bWriteLog and "LobbyPawn:InitDefaultAvatarByResID, gender:" .. tostring(gender) .. "headID" .. tostring(headID) .. "hairID " .. tostring(hairID))
  self:SwitchSexAndHeadAndHair(gender, headID, hairID)
end
function LobbyPawn:SwitchSexAndHeadAndHair(sex, headID, hairID)
  log(bWriteLog and "LobbyPawn:SwitchSexAndHeadAndHair, gender:" .. tostring(sex) .. "headID" .. tostring(headID) .. "hairID " .. tostring(hairID))
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  local itemDefineID, realShowItemDefineID = self.CharacterAvatarComp2_BP:GetEquippedItemDefineID2(1, FItemDefineIDDefault(), FItemDefineIDDefault())
  if sex ~= self.CharacterAvatarComp2_BP.gender or headID ~= itemDefineID.TypeSpecificID and headID ~= realShowItemDefineID.TypeSpecificID then
    self.HeadIsVisible = false
  end
  if self.IsRecycled then
    self.HeadIsVisible = true
  end
  print(bWriteLog and "IsChangingHeadIsChangingHead HeadIsVisible", self.HeadIsVisible)
  local sexType
  local ELobbyCharacterAnimType = import("ELobbyCharacterAnimType")
  if sex == 1 then
    sexType = ELobbyCharacterAnimType.ELobbyCharAnim_Girl
  else
    sexType = ELobbyCharacterAnimType.ELobbyCharAnim_Boy
  end
  self.CharacterAvatarComp2_BP:InitDefaultAvatarByResID(sex, headID or 0, hairID or 0)
  local charSceneType = self:GetCharSceneType()
  local lobbyPosIndex = self:GetLobbyPosIndex()
  self:SetLobbyCharacterProperty(charSceneType, lobbyPosIndex, sexType)
  DefaultAvatar = {
    Sex = sex,
    HeadID = headID or 0,
    HairID = hairID or 0
  }
end
function LobbyPawn:OnAvatarEquipFinish(slotType, isEquipped, itemID)
  log(bWriteLog and "LobbyPawn:OnAvatarEquipFinish. slotType:" .. tostring(slotType) .. " isEquipped:" .. tostring(isEquipped) .. " itemID:" .. tostring(itemID))
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  print(bWriteLog and "LobbyPawn:OnAvatarEquipFinish2", slotType, isEquipped, itemID)
  if AvatarData.OpenTimeTracer and isEquipped and self.TimeTracerMap[itemID] then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("LobbyPawn:OnAvatarEquipFinish ActorName: %s bSync=%s Pool=false ItemID:%d totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(self.Object), tostring(self.CharacterAvatarComp2_BP.bSyncAvatar), itemID, (EndTime - self.TimeTracerMap[itemID]) / 1000))
  end
  if isEquipped == true and slotType == EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot then
    self.HeadIsVisible = true
    self.IsChangingHead = false
    print(bWriteLog and "Set IsChangingHead", false)
    local UIUtil = require("client.common.ui_util")
    local itemCfg = UIUtil.GetItemCfg(itemID)
    print(bWriteLog and "LobbyPawn:OnAvatarEquipFinish3", itemID, itemCfg)
    if not itemCfg then
      return
    end
    print(bWriteLog and "LobbyPawn:OnAvatarEquipFinish4", itemCfg.ItemSubType, self.PlayOnChangingHeadAcionID)
    if itemCfg.ItemSubType == MACRO_HEADTYPE and self.PlayOnChangingHeadAcionID ~= 0 then
      self.LoadedHeadFinishTag = true
    end
  end
  if isEquipped == false and slotType == EAvatarSlotType.EAvatarSlotType_HandleEquipmentSlot then
    local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
    local emoteID = logic_emote.GetCustomWeaponShowID(itemID)
    if emoteID and self.LobbyPlayEmoteComponent_BP.GetCurrentEmoteID and emoteID == self.LobbyPlayEmoteComponent_BP:GetCurrentEmoteID() then
      self:CharStopEmoteByResId()
    end
  end
  if isEquipped == false and slotType == EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot then
    local featuresItems = CDataTable.GetTableData("FeaturesItems", itemID)
    if featuresItems and featuresItems.Features and featuresItems.Features ~= "" then
      local StringUtil = require("common.string_util")
      local features = StringUtil.Split(featuresItems.Features, ";")
      for _, featureIDStr in ipairs(features) do
        local featureID = tonumber(featureIDStr)
        if featureID then
          local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
          if featureCfg and featureCfg.FeatureType == ENUM_FeatureType.ClickEmotion and featureCfg.ExpressionID and 0 < featureCfg.ExpressionID and self.CurrentActionID == featureCfg.ExpressionID then
            log(bWriteLog and "[TeamAvatarManager] PutoffEquipment - Stop ClickEmotion action, itemID:" .. tostring(itemID) .. " ExpressionID:" .. tostring(featureCfg.ExpressionID))
            self:OnStopEmote()
            break
          end
        end
      end
    end
  end
  local avatarHandle = self.CharacterAvatarComp2_BP:GetLoadedHandle(self.CharacterAvatarComp2_BP:TypeToInt(slotType))
  if slua.isValid(avatarHandle) then
    self.OnEquipClothStateChange:BroadCast(avatarHandle, isEquipped, itemID, slotType)
  end
end
function LobbyPawn:SetAvatarLevel(level)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  if self.BP_LobbyWeaponManager then
    if level == 0 then
      self.BP_LobbyWeaponManager.CurAvatarLevel = 1
    else
      self.BP_LobbyWeaponManager.CurAvatarLevel = 2
    end
  end
  if level == 0 or level == 1 then
    self.CharacterAvatarComp2_BP.bIsLobbyAvatar = true
    self.CharacterAvatarComp2_BP.forceLodMode = false
  elseif level == 2 then
    self.CharacterAvatarComp2_BP.bIsLobbyAvatar = false
    self.CharacterAvatarComp2_BP.forceLodMode = false
  elseif level == 3 then
    self.CharacterAvatarComp2_BP.bIsLobbyAvatar = false
    self.CharacterAvatarComp2_BP.forceLodMode = true
  end
end
function LobbyPawn:SetConflictRuleEnable(enableConflictRule)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  self.CharacterAvatarComp2_BP.bEnableConflictRule = enableConflictRule
end
function LobbyPawn:OnGMSetLowLevel(_, _, level, headID, sexID, hearId)
  log(bWriteLog and "LobbyPawn:OnGMSetLowLevel")
  self:SetAvatarLevel(level)
  local ESlotDescDiff = import("ESlotDescDiff")
  self.CharacterAvatarComp2_BP.LoadedAvatarHandlerPool:Clear()
  self.CharacterAvatarComp2_BP:ReloadAllEquippedAvatar(ESlotDescDiff.MeshDiff)
  self:CharUnEquipWeapon()
  self:SwitchSexAndHeadAndHair(sexID, headID, hearId)
end
function LobbyPawn:ReloadLogicAvatar(slotID, reloadType, isRebuildAvatarSyncData)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  self.CharacterAvatarComp2_BP:ReloadLogicAvatar(slotID, reloadType, isRebuildAvatarSyncData)
end
function LobbyPawn:SetMeshVisibleByID(slotID, bIsVisible, bForceShow, bWithLog)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  self.CharacterAvatarComp2_BP:SetMeshVisibleByID(slotID, bIsVisible, bForceShow, bWithLog)
end
function LobbyPawn:SetCastPhotonShadow(bEnable)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  self.CharacterAvatarComp2_BP:SetCastPhotonShadow(bEnable)
end
function LobbyPawn:SetIsRecycled(bRecycle)
  self.IsRecycled = bRecycle
end
function LobbyPawn:ResetSkirtParticles()
  local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
  local uTargetArray = self:GetComponentsByTag(uComponentClass, "SkirtParticle")
  for i = 0, uTargetArray:Num() - 1 do
    local ParticleComp = uTargetArray:Get(i)
    if slua.isValid(ParticleComp) then
      ParticleComp:Deactivate()
      ParticleComp:Activate(true)
    end
  end
end
function LobbyPawn:HandleGoldSpecialAction(actionID)
  if actionID == 12215510 then
    self:K2_SetActorLocation(self.LocationBeforeEmote, false, nil, false)
  end
end
function LobbyPawn:TryPlaySpecialIdlePreAction(actionID)
  if not slua.isValid(self.Mesh) then
    return
  end
  if self:IsTeamupActionForSuit(actionID) then
    local AnimInstance = self.Mesh:GetAnimInstance()
    if slua.isValid(AnimInstance) and AnimInstance.TryPlaySpecialIdlePreAction then
      log(bWriteLog and "LobbyPawn:OnEndActionHandle. TryPlaySpecialIdlePreAction")
      if AnimInstance:TryPlaySpecialIdlePreAction() then
        self:HideWeapon(true)
        self:AddTimerOnce(0, function()
          self:HideWeapon(false)
        end)
      end
    end
  end
end
function LobbyPawn:IsTeamupActionForSuit(actionID)
  if not actionID then
    return false
  end
  local Cfg = CDataTable.GetTableDataByFilter("RealGoldenSuitFeature", "TemmupEmote", actionID)
  Cfg = Cfg or CDataTable.GetTableDataByFilter("GoldenSuitMapCfg", "TeamupActionID", actionID)
  Cfg = Cfg or CDataTable.GetTableDataByFilter("GoldenSuitMapCfg", "LowTeamupActionID", actionID)
  if Cfg then
    return true
  end
  return false
end
function LobbyPawn:SetPlayerUID(UID)
  UID = tostring(UID)
  if UID == nil or type(UID) ~= "string" then
    print(bWriteLog and "PlayerLobbyPawn SetPlayerUID UID is not valid")
    return
  end
  self.Player  if self:_CheckCharacterAvatarCompValid() then
    self.CharacterAvatarComp2_BP:ClearDIYColorData()
  end
end
function LobbyPawn:GetPlayerUID()
  return self.PlayerUID
end
function LobbyPawn:SetCharSceneType2(SceneType)
  self.SceneType2 = SceneType
  self.OnSceneType2Change:BroadCast(SceneType)
end
function LobbyPawn:DestoryActionParticle()
  local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
  local uTargetArray = self:GetComponentsByTag(uComponentClass, "DestroyWithEmote")
  for i = 0, uTargetArray:Num() - 1 do
    local ParticleComp = uTargetArray:Get(i)
    if slua.isValid(ParticleComp) then
      ParticleComp:K2_DestroyComponent(ParticleComp)
    end
  end
end
function LobbyPawn:OnCollectStateUnlock()
  log(bWriteLog and "LobbyPawn:OnCollectStateUnlock")
  if self.OnUpdateIdleState then
    self.OnUpdateIdleState:BroadCast()
  end
end
function LobbyPawn:IsSwimConfig(Handle)
  local EAvatarSlotNameConfig = import("EAvatarSlotNameConfig")
  if slua.isValid(Handle) then
    local ConfigType = self.CharacterAvatarComp2_BP:GetBPSlotNameConfigType(Handle)
    if ConfigType == EAvatarSlotNameConfig.EAvatarSlotNameConfig_Swim_Suit or ConfigType == EAvatarSlotNameConfig.EAvatarSlotNameConfig_Swim_Pants then
      return true
    end
  end
  return false
end
function LobbyPawn:HasEquipSwimConfigItem()
  local ClothHandle = self.CharacterAvatarComp2_BP:GetLoadedHandle(self.CharacterAvatarComp2_BP:TypeToInt(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot))
  if self:IsSwimConfig(ClothHandle) then
    return true
  end
  local PantsHandle = self.CharacterAvatarComp2_BP:GetLoadedHandle(self.CharacterAvatarComp2_BP:TypeToInt(EAvatarSlotType.EAvatarSlotType_PantsEquipemtSlot))
  if self:IsSwimConfig(PantsHandle) then
    return true
  end
  return false
end
function LobbyPawn:SetAddCharacterWeaponAnimListHandle(addAnimData)
  local bIsSuc = self:SetAddCharacterWeaponAnimList(addAnimData)
  return bIsSuc
end
function LobbyPawn:OnRecycle()
  log(bWriteLog and "LobbyPawn:OnRecycle")
  self:CharStopEmoteByResId()
  if self.BP_LobbyWeaponManager then
    self.BP_LobbyWeaponManager.WeaponHiddenMap:Clear()
  end
  self:ClearClothSchemeIDList()
end
function LobbyPawn:SetAnimIgnoreWeaponHide(bIgnore)
  if not slua.isValid(self.Mesh) then
    return
  end
  local Animinstance = self.Mesh:GetAniminstance()
  if not slua.isValid(Animinstance) or not Animinstance.SetAnimIgnoreWeaponHide then
    return
  end
  Animinstance:SetAnimIgnoreWeaponHide(bIgnore)
end
function LobbyPawn:UpdateTeamupAnimPlayingState(ActionID)
  local bPlaying = self:IsTeamupActionForSuit(ActionID)
  self:SetTeamupAnimPlayingState(bPlaying)
end
function LobbyPawn:SetTeamupAnimPlayingState(bPlaying)
  log(bWriteLog and "LobbyPawn:SetTeamupAnimPlayingState bPlaying = " .. tostring(bPlaying))
  if not slua.isValid(self.Mesh) then
    return
  end
  local Animinstance = self.Mesh:GetAniminstance()
  if not slua.isValid(Animinstance) then
    return
  end
  if Animinstance.PrepareSpecialIdlePreActionState then
    Animinstance:PrepareSpecialIdlePreActionState(bPlaying)
  end
end
function LobbyPawn:EnableFootLockAnim(bEnable)
  if not slua.isValid(self.Mesh) then
    return
  end
  print(bWriteLog and "LobbyPawn:EnableFootLockAnim:" .. tostring(bEnable))
  if self.AsyncLoadABPHandle ~= nil then
    self:CancelAsyncLoad(self.AsyncLoadABPHandle)
    self.AsyncLoadABPHandle = nil
  end
  if not bEnable then
    self.Mesh:SetSubInstance("FootLock", nil)
    return
  end
  if not self.FootLockAnimPath then
    print(bWriteLog and "LobbyPawn:EnableFootLockAnim FootLockAnimPath is invalid")
    return
  end
end
function LobbyPawn:SetRotateBlockedByFootLock(bBlocked)
  self.bIgnoreDragRotation = bBlocked
end
function LobbyPawn:SetClothMeshForceLod(bEnable)
  if slua.isValid(self.CharacterAvatarComp2_BP) then
    local EAvatarSlotType = import("EAvatarSlotType")
    self.CharacterAvatarComp2_BP:SetForceMeshLod(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot, bEnable)
  end
end
function LobbyPawn:SetLobbyPawnTick(bTick, bIgnoreSelf)
  if not self.bAllMeshLoaded then
    return
  end
  local XSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.XSuitItemID or 0
  local GoldenSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.GoldenSuitItemID or 0
  log(bWriteLog and "LobbyPawn:SetLobbyPawnTick bTick = " .. tostring(bTick) .. " bIgnoreSelf = " .. tostring(bIgnoreSelf) .. " bAllMeshLoaded = " .. tostring(self.bAllMeshLoaded) .. " Mesh:" .. tostring(self.Mesh) .. " XSuitItemID = " .. XSuitItemID .. " GoldenSuitItemID = " .. GoldenSuitItemID)
  local performance_util = require("client.slua.logic.performance.performance_util")
  performance_util:SetActorTickRecursively(self.Object, bTick, bIgnoreSelf)
  performance_util:SetComponentTickRecursively(self.Mesh, bTick)
  performance_util:SetComponentTickRecursively(self.WeaponSkeletalMesh, bTick)
  if not bTick and not self.bSetOnlyTickPoseWhenRendered then
    self:SetOnlyTickPoseWhenRendered(self.Mesh)
  end
end
function LobbyPawn:SwitchMeshToMinLOD(bSwitchToMinLOD)
  local XSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.XSuitItemID or 0
  local GoldenSuitItemID = self.CharacterAvatarComp2_BP and self.CharacterAvatarComp2_BP.GoldenSuitItemID or 0
  log(bWriteLog and "LobbyPawn:SwitchMeshToMinLOD bSwitchToMinLOD = " .. tostring(bSwitchToMinLOD) .. " bAllMeshLoaded = " .. tostring(self.bAllMeshLoaded) .. " Mesh:" .. tostring(self.Mesh) .. " XSuitItemID = " .. XSuitItemID .. " GoldenSuitItemID = " .. GoldenSuitItemID)
  if not self:_CheckCharacterAvatarCompValid() then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local deviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  if 0 < deviceLevel then
    self.CharacterAvatarComp2_BP:SwitchMeshToMinLOD(bSwitchToMinLOD)
  end
end
function LobbyPawn:SetLobbyPawnTickInterval(tickInterval)
  log(bWriteLog and "LobbyPawn:SetLobbyPawnTickInterval tickInterval = " .. tostring(tickInterval))
  local performance_util = require("client.slua.logic.performance.performance_util")
  performance_util:SetActorTickIntervalRecursively(self.Object, tickInterval)
  performance_util:SetComponentTickIntervalRecursively(self.Mesh, tickInterval)
  performance_util:SetComponentTickIntervalRecursively(self.WeaponSkeletalMesh, tickInterval)
end
function LobbyPawn:SetOnlyTickPoseWhenRendered(Component)
  log(bWriteLog and "LobbyPawn:SetOnlyTickPoseWhenRendered")
  if not slua.isValid(Component) then
    return
  end
  local EMeshComponentUpdateFlag = import("EMeshComponentUpdateFlag")
  if Component.MeshComponentUpdateFlag then
    Component.MeshComponentUpdateFlag = EMeshComponentUpdateFlag.OnlyTickPoseWhenRendered
    self.bSetOnlyTickPoseWhenRendered = true
  end
  if Component.GetChildrenComponents then
    local uComponentArray = Component:GetChildrenComponents(false, nil)
    if uComponentArray then
      for _, ChildComponent in pairs(uComponentArray) do
        if ChildComponent and slua.isValid(ChildComponent) then
          self:SetOnlyTickPoseWhenRendered(ChildComponent)
        end
      end
    end
  end
end
function LobbyPawn:SetForcedLOD(Component, LODLevel)
  if not slua.isValid(Component) then
    return
  end
  if Component.SetForcedLOD then
    Component:SetForcedLOD(LODLevel)
  end
  if Component.GetChildrenComponents then
    local uComponentArray = Component:GetChildrenComponents(false, nil)
    if uComponentArray then
      for _, ChildComponent in pairs(uComponentArray) do
        if ChildComponent and slua.isValid(ChildComponent) then
          self:SetForcedLOD(ChildComponent, LODLevel)
        end
      end
    end
  end
end
function LobbyPawn:getAvatarComponent2()
  return self.CharacterAvatarComp2_BP
end
function LobbyPawn:ChangeAllAvatarMaterialToFeatureMaterial(material)
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:ChangeAllMeshToFeatureMaterial(material)
  end
  local WeaponManager = self:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    WeaponManager:ChangeAllMeshToFeatureMaterial(material)
  end
end
function LobbyPawn:ClearAllAvatarFeatureMaterial()
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:ClearAllFeatureMaterial()
  end
  local WeaponManager = self:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    WeaponManager:ClearAllFeatureMaterial()
  end
end
function LobbyPawn:SetClothSchemeIDList(idList)
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:SetClothSchemeIDList(idList)
  end
end
function LobbyPawn:ClearClothSchemeIDList()
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:ClearClothSchemeIDList()
  end
end
function LobbyPawn:AddClothSchemeID(schemeID)
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:AddClothSchemeID(schemeID)
  end
end
function LobbyPawn:RemoveClothSchemeID(schemeID)
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    uAvatarComp2:RemoveClothSchemeID(schemeID)
  end
end
function LobbyPawn:PreviewMoveEffect(MoveEffectItem, EmoteID)
  log(bWriteLog and "LobbyPawn:PreviewMoveEffect" .. tostring(MoveEffectItem) .. ", " .. tostring(EmoteID))
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    local AdditionEffectMgr = uAvatarComp2.AdditionEffectMgr
    if AdditionEffectMgr then
      self:CharStopEmoteByResId(false)
      AdditionEffectMgr.Preview      uAvatarComp2.      self:CharPlayEmoteByResId(EmoteID, "Default")
    end
  end
end
function LobbyPawn:PreviewFootStepEffect(FootStepEffectItem, EmoteID)
  log(bWriteLog and "LobbyPawn:PreviewFootStepEffect" .. tostring(FootStepEffectItem) .. ", " .. tostring(EmoteID))
  local uAvatarComp2 = self:getAvatarComponent2()
  if slua.isValid(uAvatarComp2) then
    local AdditionEffectMgr = uAvatarComp2.AdditionEffectMgr
    if AdditionEffectMgr then
      self:CharStopEmoteByResId(false)
      AdditionEffectMgr.Preview      uAvatarComp2.      self:CharPlayEmoteByResId(EmoteID, "Default")
    end
  end
end
function LobbyPawn:IsSelfCharacter()
  if DataMgr and DataMgr.roleData then
    if self.PlayerUID == DataMgr.roleData.uid then
      return true
    end
    local uAvatarComp2 = self:getAvatarComponent2()
    if slua.isValid(uAvatarComp2) and uAvatarComp2.isSelf and uAvatarComp2:IsSelf() then
      return true
    end
    if not self.PlayerUID or self.PlayerUID == "" or DataMgr.roleData.uid == "" then
      return true
    end
  end
  return false
end
function LobbyPawn:IsOtherCharacter()
  return not self:IsSelfCharacter()
end
function LobbyPawn:ResetRotateFlag()
  self.RotateTime = 0
  self.StartRotateFlag = false
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLobbyCharacter = class(CActorBase, nil, LobbyPawn)
return CLobbyCharacter
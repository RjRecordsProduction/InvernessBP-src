local LobbyAnimBP = {}
local AnimNotifyCallBack = {}
local FixGenderAvatarTableCache
function AnimNotifyCallBack.CPStart()
  EventSystem:postEvent(EVENTTYPE_ANIM_NOTIFY, EVENTTYPE_ANIM_NOTIFY_CPSTART)
end
function AnimNotifyCallBack.CPEnd()
  EventSystem:postEvent(EVENTTYPE_ANIM_NOTIFY, EVENTTYPE_ANIM_NOTIFY_CPEND)
end
function AnimNotifyCallBack:IceKingEmoteActionStart()
  local handler = require("client.slua.logic.avatar.anim_notify_handler.IceKingEmoteActionStart")
  handler.OnAnimNotify(self)
end
function AnimNotifyCallBack:StartChangeGolden()
  log(bWriteLog and "  .  StartChangeGolden" .. tostring(self))
  local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
  golden_suit_module:ChangeGoldenWhenPlay(self)
end
function AnimNotifyCallBack:StartChangeFormA()
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  DragonChangeForm:ChangeForm(self)
end
function AnimNotifyCallBack:StartChangeFormB()
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  DragonChangeForm:ChangeForm(self)
end
function AnimNotifyCallBack:XSuitChangeForm()
  local handler = require("client.slua.logic.avatar.anim_notify_handler.XSuitChangeForm")
  handler.OnAnimNotify(self)
end
function AnimNotifyCallBack:XSuitChangeBranch()
  local handler = require("client.slua.logic.avatar.anim_notify_handler.XSuitChangeForm")
  handler.OnXSuitChangeBranch(self)
end
function AnimNotifyCallBack:LobbyPaint()
  local logic_lobby_paint = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_paint)
  logic_lobby_paint:ShowUI(self)
end
function AnimNotifyCallBack:ChangeCartoonStyle()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local Cfg = LogicMultiItemModule:ChangeCartoonStyle(self)
end
function AnimNotifyCallBack:FootStepNotify()
  EventSystem:postEvent(EVENTTYPE_ANIM_NOTIFY, EVENTTYPE_ANIM_NOTIFY_FOOTSETP, self:GetOwningActor())
end
function AnimNotifyCallBack:NoShadow()
  if not slua.isValid(self.BP_LobbyPawn) then
    return
  end
  local MeshComponent = import("/Script/Engine.MeshComponent")
  local ComponentArray = self.BP_LobbyPawn:GetComponentsByClass(MeshComponent)
  for _, Component in pairs(ComponentArray) do
    if Component and slua.isValid(Component) and Component.SetCastPhotonShadow then
      Component:SetCastPhotonShadow(false)
    end
  end
end
function LobbyAnimBP:ctor()
  print(bWriteLog and "LobbyAnimBP ctor")
  if EVENTTYPE_ANIM_NOTIFY then
    self:AddCommonEvent(EVENTTYPE_ANIM_NOTIFY, EVENTID_ANIMFUNC, self.PostFunc, self)
  end
end
function LobbyAnimBP:PostFunc(_, _, funcName, ...)
  log_warning(bWriteLog and "  : funcName   " .. tostring(funcName))
  local func = self[funcName]
  if func then
    log(bWriteLog and "  : call func success")
    func(self, ...)
  end
end
function LobbyAnimBP:OnAvatarEditor_MainClose()
  self:Dispose()
  if self.SetTposActive then
    self:SetTposActive(false)
  else
    log_warning(bWriteLog and "  LobbyAnimBP:OnAvatarEditor_MainClose.  has no SetTposActive")
  end
end
function LobbyAnimBP:AnimNotify_OnActionLoop()
  if not slua.isValid(self.BP_LobbyPawn) then
    return
  end
  log(bWriteLog and "AnimNotify_OnActionLoop")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local UID = TeamAvatarManager.GetAvatarUIDByModel(self.BP_LobbyPawn)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.StopEmoteAction(UID)
end
function LobbyAnimBP:AnimNotify_WeaponPlayEnd()
  self:WeaponPlayAnimEnd()
end
function LobbyAnimBP:OnPlayEmoteEnd()
  local ELobbyPawnAnimPoseType = import("ELobbyPawnAnimPoseType")
  if self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_WeaponPlay then
    self:WeaponPlayAnimEnd()
  end
end
function LobbyAnimBP:OnNotifyMontagePlayingEvent_BluePrint(NotifyName)
  log(bWriteLog and "OnNotifyMontagePlayingEvent_BluePrint " .. NotifyName)
  if AnimNotifyCallBack[NotifyName] then
    AnimNotifyCallBack[NotifyName](self)
  end
end
function LobbyAnimBP:GetClothesBaseID(ItemID)
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  return LobbyIdleUnlock:GetClothesBaseID(ItemID)
end
function LobbyAnimBP:GetCurrentClothGender()
  log(bWriteLog and "GetCurrentClothGender")
  if not slua.isValid(self.BP_LobbyPawn) or not slua.isValid(self.BP_LobbyPawn.CharacterAvatarComp2_BP) then
    return self.LogicGender
  end
  if FixGenderAvatarTableCache == nil then
    FixGenderAvatarTableCache = {}
    local FixGenderAvatarTable = CDataTable.GetTable("FixGenderAvatarTable")
    if FixGenderAvatarTable then
      for k, v in pairs(FixGenderAvatarTable) do
        FixGenderAvatarTableCache[v.ID] = v.Gender
      end
    end
  end
  local ClothID = self.BP_LobbyPawn.CharacterAvatarComp2_BP:GetEquippedItemDefineID3(5)
  if FixGenderAvatarTableCache[ClothID.TypeSpecificID] ~= nil then
    log(bWriteLog and "GetCurrentClothGender Use Cloth" .. ClothID.TypeSpecificID)
    return FixGenderAvatarTableCache[ClothID.TypeSpecificID]
  end
  local HeadID = self.BP_LobbyPawn.CharacterAvatarComp2_BP:GetEquippedItemDefineID3(1)
  if FixGenderAvatarTableCache[HeadID.TypeSpecificID] ~= nil then
    log(bWriteLog and "GetCurrentClothGender Use Head" .. HeadID.TypeSpecificID)
    return FixGenderAvatarTableCache[HeadID.TypeSpecificID]
  end
  return self.LogicGender
end
function LobbyAnimBP:GetSpecialIdleSwitch()
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  local bSwitch = LobbyIdleUnlock:GetSpecialIdleSwitch()
  return bSwitch
end
local hideClothesWhenSpecialIdle = {1407425}
function LobbyAnimBP:NeedHideClothes()
  local CharacterAvatarComponent2 = self:GetCharacterAvatarComp2()
  if CharacterAvatarComponent2 and slua.isValid(CharacterAvatarComponent2) then
    for _, i in ipairs(hideClothesWhenSpecialIdle) do
      if CharacterAvatarComponent2:IsItemHasEquipped(i) then
        return true
      end
    end
  end
  return false
end
function LobbyAnimBP:TickUpdateLookAt(DeltaSeconds)
  if not slua.isValid(self.BP_LobbyPawn) then
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local PawnUID = TeamAvatarManager.GetAvatarUIDByModel(self.BP_LobbyPawn)
  if tostring(PawnUID) ~= tostring(DataMgr.roleData.uid) and PawnUID ~= "" then
    self.LookAtLocation = FVector(0, 0, 0)
    return
  end
  if not self:_CheckCanLookAtCamera() then
    self.LookAtLocation = FVector(0, 0, 0)
    return
  end
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local currentTabId = WardrobeLogicManager.GetCurrentTabId()
  if currentTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet or currentTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head or currentTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_glasses or currentTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_face then
    self.LookAtLocation = FVector(0, 0, 0)
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.PlayerCameraManager) then
    self.LookAtLocation = FVector(0, 0, 0)
    return
  end
  self.LookAtLocation = uPlayerController.PlayerCameraManager:GetCameraLocation()
end
function LobbyAnimBP:_CheckCanLookAtCamera()
  if self.BP_LobbyPawn.IsPlayingAction then
    return false
  end
  if not self:_CheckCanLookAtByTable() then
    return false
  end
  local ELobbyPawnAnimPoseType = import("ELobbyPawnAnimPoseType")
  if self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_Normal or self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_Weapon then
    return true
  end
  if self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_SpecialIdle or self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_ClothesWeapon then
    if not slua.isValid(self.BP_LobbyPawn) or not slua.isValid(self.BP_LobbyPawn.CharacterAvatarComp2_BP) then
      return false
    end
    local ClothesDefineID = self.BP_LobbyPawn.CharacterAvatarComp2_BP:GetEquippedItemDefineID3(5)
    local ClothesID = ClothesDefineID.TypeSpecificID
    if not ClothesID or ClothesID <= 0 then
      return false
    end
    if not self._SpecialIdleLookAtCache then
      self._SpecialIdleLookAtCache = {}
    end
    if self._SpecialIdleLookAtCache[ClothesID] == nil then
      local bCanLookAt = false
      local ESpecialIdleType = import("ESpecialIdleType")
      local IdleType = ESpecialIdleType.EIdleType_Clothes
      if self.CurPoseType == ELobbyPawnAnimPoseType.ELobbyPose_ClothesWeapon then
        IdleType = ESpecialIdleType.EIdleType_ClothesWeapon
      end
      local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
      local Cfg = LobbyIdleUnlock:GetCollectUnlockCfg(ClothesID, IdleType)
      if Cfg and Cfg.bCanLookAtCamera then
        bCanLookAt = true
      end
      self._SpecialIdleLookAtCache[ClothesID] = bCanLookAt
    end
    return self._SpecialIdleLookAtCache[ClothesID]
  end
  return false
end
function LobbyAnimBP:_CheckCanLookAtByTable()
  if not slua.isValid(self.BP_LobbyPawn) or not slua.isValid(self.BP_LobbyPawn.CharacterAvatarComp2_BP) then
    return false
  end
  local ClothesDefineID = self.BP_LobbyPawn.CharacterAvatarComp2_BP:GetEquippedItemDefineID3(5)
  local itemID = ClothesDefineID.TypeSpecificID
  if not itemID or itemID <= 0 then
    return false
  end
  if not self._LookAtCameraCfgCache then
    self._LookAtCameraCfgCache = {}
    local LookAtCameraCfg = CDataTable.GetTable("LookAtCameraCfg")
    if LookAtCameraCfg then
      for _, v in pairs(LookAtCameraCfg) do
        if v.ID then
          self._LookAtCameraCfgCache[v.ID] = v.bCanLookAtCamera or false
        end
      end
    end
  end
  return self._LookAtCameraCfgCache[itemID] == true
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CLobbyAnimBP = class(CDelegateContainer, nil, LobbyAnimBP)
return CLobbyAnimBP
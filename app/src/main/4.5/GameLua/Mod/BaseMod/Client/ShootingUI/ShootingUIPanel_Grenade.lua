local EPawnState = import("EPawnState")
local EThrowGrenadeMode = import("EThrowGrenadeMode")
local UAESkillManagerUtils = import("UAESkillManagerUtils")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ShootingUIPanelIMP = require("GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelIMP")
function ShootingUIPanelIMP:Grenade_ctor()
  self.CurThrowSkillID = -1
  self.ThrowGrenadeBtnState = 0
  self.RepeatTryTriggerSkillDuration = 0.3
  self.ThrowGrenadeBtnStateFingerIndex = 0
end
function ShootingUIPanelIMP:RegistEvents_Grenade()
  print(bWriteLog and "ShootingUIPanelUIBase:RegistEvents_Grenade")
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_LSide, "GrenadeTriggerHit", self.GrenadeTriggerHitLeft, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_LSide, "GrenadeThrown", self.GrenadeThrown, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_LSide, "GrenadeHighlightFireBtn", self.GrenadeHighlightFireBtn, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_LSide, "GrenadeNormalFireBtn", self.GrenadeNormalFireBtn, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_Rside, "GrenadeTriggerHit", self.GrenadeTriggerHit, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_Rside, "GrenadeThrown", self.GrenadeThrown, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_Rside, "GrenadeNormalFireBtn", self.GrenadeNormalFireBtn, self)
  self:AddControlEventByControl(self.UIRoot.GrenadeAimBtn_Rside, "GrenadeHighlightFireBtn", self.GrenadeHighlightFireBtn, self)
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEventByControl(uPlayerController, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnPlayerReconnect, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_THROW_CANCEL_BUTTON_CLICK, self.OnThrowCancelButClick, self)
  self:AddUIMessageEvent("UIMsg_ResetBattleUI", self.UIMsg_ResetBattleUI, self)
  self:AddUIMessageEvent("UIMsg_HideCancelGrenadeBtn", self.HideCancelGrenadeBtn, self)
  self:AddUIMessageEvent("UIMsg_ShowCancelGrenadeThrow", self.UIMsg_ShowCancelGrenadeThrow, self)
  self:AddUIMessageEvent("UIMsg_PlayerControllerPressGrenade", self.UIMsg_PlayerControllerPressGrenade, self)
end
function ShootingUIPanelIMP:OnPlayerReconnect()
  print(bWriteLog and "ShootingUIPanelUIBase:OnPlayerReconnect")
  UIManager.CloseUI(UIManager.UI_Config_InGame.ThrowTimeInfoPanel)
end
function ShootingUIPanelIMP:UIMsg_PlayerControllerPressGrenade()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if PlayerController.IsThrowGrenade then
    self:GrenadeThrow()
  else
    local ETouchIndex = import("ETouchIndex")
    self:GrenadePrepareToThrow(ETouchIndex.Touch1)
  end
end
function ShootingUIPanelIMP:GrenadeTriggerHitLeft(FingerIndex)
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeTriggerHitLeft")
  local ETouchIndex = import("ETouchIndex")
  self:GrenadeTriggerHit(ETouchIndex.Touch10)
end
function ShootingUIPanelIMP:GrenadeTriggerHit(FingerIndex)
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeTriggerHit")
  self:GrenadePrepareToThrow(FingerIndex)
  EventSystem:postEvent(EVENTTYPE_INGAME_SHOOTINGUI_PANEL, EVENTID_ON_THROW_BUTTON_CLICK)
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_PRESSED, "Throw")
end
function ShootingUIPanelIMP:GrenadeThrown()
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeThrown")
  EventSystem:postEvent(EVENTTYPE_INGAME_CREATIVE_MODE, EVENTID_UGC_NATIVE_BUTTON_RELEASED, "Throw")
  self:GrenadeThrow()
end
function ShootingUIPanelIMP:GrenadeHighlightFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeHighlightFireBtn")
  self:HighlightGrenadeFireBtn()
end
function ShootingUIPanelIMP:GrenadeNormalFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeNormalFireBtn")
  self:NormalGrenadeFireBtn()
end
function ShootingUIPanelIMP:GrenadeThrow()
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadeThrow")
  self:HandleThrowOutGrenade()
end
function ShootingUIPanelIMP:HighlightGrenadeFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:HighlightGrenadeFireBtn")
  local IconPath, IconWidth, IconHeight = self:GetGrenadeIconByType(self.CurGrenadeID)
  self.UIRoot.GrenadeBtnImage_Rside:SetBrushFromPathAsync(IconPath, false)
  self.UIRoot.GrenadeImage_LSide:SetBrushFromPathAsync(IconPath, false)
  self.UIRoot.GrenadeBtnBG_Rside:SetBrush(self.UIRoot.FireBG_HighLight)
  self.UIRoot.GrenadeBG_LSide:SetBrush(self.UIRoot.FireBG_HighLight)
end
function ShootingUIPanelIMP:NormalGrenadeFireBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:NormalGrenadeFireBtn")
  local IconPath, IconWidth, IconHeight = self:GetGrenadeIconByType(self.CurGrenadeID)
  self.UIRoot.GrenadeBtnImage_Rside:SetBrushFromPathAsync(IconPath, false)
  self.UIRoot.GrenadeImage_LSide:SetBrushFromPathAsync(IconPath, false)
  self.UIRoot.GrenadeBtnBG_Rside:SetBrush(self.UIRoot.FireBG_NormalIcon)
  self.UIRoot.GrenadeBG_LSide:SetBrush(self.UIRoot.FireBG_NormalIcon)
end
function ShootingUIPanelIMP:OnUseGrenadeChangeUI(GrenadeID)
  self.Cur  self.CurThrowSkillID = -1
  local IconPath, IconWidth, IconHeight = self:GetGrenadeIconByType(GrenadeID)
  if IconPath ~= "" then
    self.UIRoot.GrenadeImage_LSide:SetBrushFromPathAsync(IconPath, false)
    self.UIRoot.GrenadeBtnImage_Rside:SetBrushFromPathAsync(IconPath, false)
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local WeaponManager = PlayerCharacter:GetWeaponManager()
  if not slua.isValid(WeaponManager) then
    return
  end
  local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
  if not slua.isValid(CurWeapon) then
    return
  end
  if CurWeapon.GetGrenadeSkillID then
    self.CurThrowSkillID = CurWeapon:GetGrenadeSkillID()
  end
end
function ShootingUIPanelIMP:GetGrenadeIconByType(GrenadeID)
  local uIconConfig = UAESkillManagerUtils.GetGrenadeSkillIconConfig(GrenadeID)
  local path, width, height = uIconConfig.IconPath, uIconConfig.IconWidth, uIconConfig.IconHeight
  local isVehicleConsumable
  for _, v in pairs(CDataTable.GetTable("VehicleUseConfig")) do
    if v.Consumable == GrenadeID then
      isVehicleConsumable = true
      break
    end
  end
  local pak_util = require("client.common.pak_util")
  if isVehicleConsumable and not pak_util.IsFileExist(path) then
    path = "/Game/Arts/UI/NoAtlas/XSuit/XSuit_Icon_Aircraft_03.XSuit_Icon_Aircraft_03"
  end
  return path, width, height
end
function ShootingUIPanelIMP:HandleReadyThrowOutGrenade(FingerIndex)
  self:Print("ShootingUIPanelUIBase:HandleReadyThrowOutGrenade FingerIndex=" .. tostring(FingerIndex))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self:Print("ShootingUIPanelUIBase:HandleReadyThrowOutGrenade Fail not slua.isValid(uPlayerCharacter)")
    return false
  end
  if PlayerCharacter.UpdateRecentAutonomousAttackTime then
    PlayerCharacter:UpdateRecentAutonomousAttackTime()
  end
  local Weapon = PlayerCharacter:GetCurrentWeapon()
  if not slua.isValid(Weapon) then
    self:Print("ShootingUIPanelUIBase:HandleReadyThrowOutGrenade not Weapon")
    return false
  end
  local CurGrenadeID = self.CurGrenadeID
  if Weapon.ForceTriggerWeaponEvent then
    local EWeaponTriggerEvent = import("EWeaponTriggerEvent")
    Weapon:TriggerWeaponEvent(EWeaponTriggerEvent.EWeaponTriggerEvent_PressFuncBtn)
    return true
  else
    local SkillManager = PlayerCharacter:GetSkillManager()
    if not slua.isValid(SkillManager) then
      self:Print("ShootingUIPanelUIBase:HandleReadyThrowOutGrenade not SkillManager")
      return false
    end
    local SkillID = self.CurThrowSkillID
    if 0 < SkillID then
      local bSuccess = self:ShouldThrowGrenadeWithID(CurGrenadeID, SkillID)
      local PlayerController = GameplayData.GetPlayerController()
      if slua.isValid(PlayerController) and PlayerController.TouchEndTriggerSkillID and PlayerController.OnFireTouchFingerIndex then
        PlayerController.OnFireTouch        PlayerController.TouchEndTrigger      end
      return bSuccess
    end
    return false
  end
end
function ShootingUIPanelIMP:HandleThrowOutGrenade()
  self:Print("ShootingUIPanelUIBase:HandleThrowOutGrenade")
  self:RecordThrowGrenadeBtnState(-1)
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeThrowVisible(false)
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self:Print("ShootingUIPanelUIBase:HandleThrowOutGrenade Fail not slua.isValid(uPlayerCharacter)")
    return
  end
  if PlayerCharacter.UpdateRecentAutonomousAttackTime then
    PlayerCharacter:UpdateRecentAutonomousAttackTime()
  end
  local Weapon = PlayerCharacter:GetCurrentWeapon()
  if not slua.isValid(Weapon) then
    self:Print("ShootingUIPanelUIBase:HandleThrowOutGrenade not Weapon")
    return
  end
  if Weapon.ForceTriggerWeaponEvent then
    local EWeaponTriggerEvent = import("EWeaponTriggerEvent")
    Weapon:TriggerWeaponEvent(EWeaponTriggerEvent.EWeaponTriggerEvent_ReleaseFuncBtn)
  else
    local SkillManager = PlayerCharacter:GetSkillManager()
    if not slua.isValid(SkillManager) then
      self:Print("ShootingUIPanelUIBase:HandleThrowOutGrenade not SkillManager")
      return
    end
    local SkillID = self.CurThrowSkillID
    if 0 < SkillID then
      local CurGrenadeID = self.CurGrenadeID
      SkillManager:SetValueAsInt(SkillID, "AvatarID", CurGrenadeID)
      PlayerCharacter:TriggerEntrySkillWithParams(SkillID, {"AvatarID"}, false)
    end
  end
end
function ShootingUIPanelIMP:ShouldThrowGrenadeWithID(GrenadeID, SkillID)
  self:Print("ShootingUIPanelUIBase:ShouldThrowGrenadeWithID GrenadeID=" .. tostring(GrenadeID) .. " SkillID=" .. tostring(SkillID))
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    self:Print("ShootingUIPanelUIBase:ShouldThrowGrenadeWithID Fail not slua.isValid(uPlayerCharacter)")
    return false
  end
  local SkillManager = PlayerCharacter:GetSkillManager()
  if not slua.isValid(SkillManager) then
    self:Print("ShootingUIPanelUIBase:ShouldThrowGrenadeWithID not SkillManager")
    return false
  end
  Game:SetSkillBlackboardValue(PlayerCharacter, SkillID, UEnums.EBlackBoardKeyType.Bool, "GrenadeModeChange", false)
  SkillManager:SetValueAsInt(SkillID, "AvatarID", self.CurGrenadeID)
  return PlayerCharacter:TriggerEntrySkillWithParams(SkillID, {"AvatarID"}, true)
end
function ShootingUIPanelIMP:GrenadePrepareToThrow(FingerIndex)
  print(bWriteLog and "ShootingUIPanelUIBase:GrenadePrepareToThrow FingerIndex=" .. tostring(FingerIndex))
  self:RecordThrowGrenadeBtnState(1, FingerIndex)
  return self:HandleReadyThrowOutGrenade(FingerIndex)
end
function ShootingUIPanelIMP:HideCancelGrenadeBtn()
  print(bWriteLog and "ShootingUIPanelUIBase:HideCancelGrenadeBtn")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeThrowVisible(false)
  end
  self:NormalGrenadeFireBtn()
  self:NormalFireBtnByStatus(true)
  self:NormalFireBtnByStatus(false)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) and PlayerController.TouchEndTriggerSkillID then
    PlayerController.TouchEndTriggerSkillID = -1
  end
end
function ShootingUIPanelIMP:UIMsg_ResetBattleUI()
  print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_ResetBattleUI")
  UIManager.CloseUI(UIManager.UI_Config_InGame.ThrowTimeInfoPanel)
end
function ShootingUIPanelIMP:UIMsg_ShowCancelGrenadeThrow()
  print(bWriteLog and "ShootingUIPanelUIBase:UIMsg_ShowCancelGrenadeThrow")
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:ChangeThrowVisible(true)
  end
  if self.CurGrenadeID == 0 then
    self.CurThrowSkillID = 0
  end
end
function ShootingUIPanelIMP:Close_Grenada()
end
function ShootingUIPanelIMP:SkillStartEvent_Grenade(uPawn, SkillID)
  if SkillID ~= self.CurThrowSkillID then
    return
  end
  if not UAESkillManagerUtils.GetGrenadeHideCancleFlag(self.CurGrenadeID) then
    print(bWriteLog and string.format("ShootingUIPanelIMP:SkillStartEvent CurThrowSkillID %d, CurGrenadeID %d:", self.CurThrowSkillID, self.CurGrenadeID))
    local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
    if OperateSubsystem then
      OperateSubsystem:ChangeThrowVisible(true)
    end
    self.StartEventSkill = SkillID
  end
end
function ShootingUIPanelIMP:SkillFinishedEvent_Grenade(StopReason, SkillID, bHasThrownBrenade)
  print(bWriteLog and string.format("ShootingUIPanelIMP:SkillFinishedEvent_Grenade SkillID %d, CurThrowSkillID %d, StartEventSkill %s, StopReason %d, bHasThrownBrenade %s", SkillID, self.CurThrowSkillID, tostring(self.StartEventSkill), StopReason, bHasThrownBrenade))
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if SkillID ~= self.StartEventSkill then
    if self.StartEventSkill then
      return
    end
    print(bWriteLog and string.format("ShootingUIPanelIMP:SkillFinishedEvent_Grenade StartEventSkill nil, SkillID %d, CurGrenadeID %d:", SkillID, self.CurGrenadeID))
  end
  local UTSkillStopReason = import("UTSkillStopReason")
  if StopReason ~= UTSkillStopReason.SkillStopReason_Finished then
    if StopReason == UTSkillStopReason.SkillStopReason_None or StopReason == UTSkillStopReason.SkillStopReason_PlayerDieInterrupted or StopReason == UTSkillStopReason.SkillStopReason_Interrupted then
      if not bHasThrownBrenade then
        self.UIRoot.ThrowTimeInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
      if OperateSubsystem then
        OperateSubsystem:ChangeThrowVisible(false)
      end
    else
      local PlayerCharacter = GameplayData.GetPlayerCharacter()
      if slua.isValid(PlayerCharacter) and PlayerCharacter:GetGameTimeSinceCreation() >= 0 then
        self.UIRoot.ThrowTimeInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        if OperateSubsystem then
          OperateSubsystem:ChangeThrowVisible(false)
        end
      end
    end
  elseif OperateSubsystem then
    OperateSubsystem:ChangeThrowVisible(false)
  end
end
function ShootingUIPanelIMP:RecordThrowGrenadeBtnState(State, FingerIndex)
  local OldState = self.ThrowGrenadeBtnState
  if 0 < State then
    self.ThrowGrenadeBtnState = 1
    self.ThrowGrenadeBtnState  else
    self.ThrowGrenadeBtnState = 0
  end
  print(bWriteLog and string.format("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState new State %d, ThrowGrenadeBtnState %d, FingerIndex %s", State, self.ThrowGrenadeBtnState, tostring(FingerIndex)))
  if self.ThrowGrenadeBtnState > 0 and OldState == 0 then
    self.RepeatTryTriggerSkillStarted = false
    if not self.HandleRepeatTryTriggerSkill then
      self.HandleRepeatTryTriggerSkill = self:AddGameTimer(self.RepeatTryTriggerSkillDuration, true, function()
        local PlayerCharacter = GameplayData.GetPlayerCharacter()
        if not slua.isValid(PlayerCharacter) then
          self:Print("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState Fail not slua.isValid(PlayerCharacter)")
          return
        end
        local bInvalidWeapon = true
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if slua.isValid(WeaponManager) then
          local CurWeapon = WeaponManager:GetCurrentUsingWeapon()
          local ASTExtraWeapon_Throw = import("STExtraWeapon_Throw")
          if slua.isValid(CurWeapon) and Game:IsClassOf(CurWeapon, ASTExtraWeapon_Throw) then
            bInvalidWeapon = false
          end
        end
        if bInvalidWeapon then
          self:Print("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState weapon invalid")
          self:RecordThrowGrenadeBtnState(-1)
          return
        end
        local SkillManager = PlayerCharacter:GetSkillManager()
        if not slua.isValid(SkillManager) then
          self:Print("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState Fail not SkillManager")
          return
        end
        local SkillID = self.CurThrowSkillID
        if not SkillManager:IsCastingSkillID(SkillID) then
          print(bWriteLog and string.format("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState try trigger skill %d", SkillID))
          self.RepeatTryTriggerSkillStarted = true
          self:HandleReadyThrowOutGrenade(self.ThrowGrenadeBtnStateFingerIndex)
        elseif self.RepeatTryTriggerSkillStarted then
          self:Print("[Grenade] ShootingUIPanelIMP:RecordThrowGrenadeBtnState, Succeed, remove timer")
          if self.HandleRepeatTryTriggerSkill then
            self:RemoveGameTimer(self.HandleRepeatTryTriggerSkill)
            self.HandleRepeatTryTriggerSkill = nil
          end
        end
      end)
    end
  end
  if self.ThrowGrenadeBtnState == 0 and 0 < OldState and self.HandleRepeatTryTriggerSkill then
    self:RemoveGameTimer(self.HandleRepeatTryTriggerSkill)
    self.HandleRepeatTryTriggerSkill = nil
  end
end
function ShootingUIPanelIMP:OnThrowCancelButClick()
  print(bWriteLog and "[Grenade] ShootingUIPanelIMP:OnThrowCancelButClick")
  self:RecordThrowGrenadeBtnState(-1)
end
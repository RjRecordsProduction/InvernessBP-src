local MiniTvInBornIsland = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local MontagePath = {
  SayHelloMontage = "/Game/Arts_Player/MiniTV/Anim/Pet_int_032_Greet_Montage.Pet_int_032_Greet_Montage",
  IdleMontage = "/Game/Arts_Player/MiniTV/Anim/Pet_int_032_Idle_Montage.Pet_int_032_Idle_Montage",
  WinMontage = "/Game/Arts_Player/MiniTV/Anim/Pet_int_032_Winning_Montage.Pet_int_032_Winning_Montage",
  BroadcastEndMontage = "/Game/Arts_Player/MiniTV/Anim/Pet_int_032_Broadcast_FR_End_Montage.Pet_int_032_Broadcast_FR_End_Montage",
  BroadcastMontage = "/Game/Arts_Player/MiniTV/Anim/Pet_int_032_Broadcast_FR_Montage.Pet_int_032_Broadcast_FR_Montage"
}
local SKILLID_SAYHELLO = 1013240
function MiniTvInBornIsland:ctor()
  self.isShowing = false
  self.ActorRoatate = 0
  self.CurActionIndex = 0
  self.PlayListIndex = {}
  self.MyCharacter = nil
  self.HandleID = nil
end
function MiniTvInBornIsland:ReceiveBeginPlay()
  MiniTvInBornIsland.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "MiniTvInBornIsland:ReceiveBeginPlay")
  if self:HasAuthority() then
    return
  end
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_SKILLBUFF, EVENTID_PLAYEREVENT_SKILL_END, self.OnSkillTrigger, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTIP_ON_CLICK_BROADCAST, self.OnClickBroadcast, self)
  self:Init3DUI()
  self:InitTipsUI()
  self:StartCyclePlayTv()
end
function MiniTvInBornIsland:OnClientShowInteractiveUI(show, component)
  MiniTvInBornIsland.__super.OnClientShowInteractiveUI(self, show, component)
  if self.isInteractiving == show then
    return
  end
  self.isInteractiving = show
  if show then
    self:ShowBroadcastButton()
  else
    self:HideBroadcastButton()
    self:StartCyclePlayTv()
    self:HideBannerUI()
  end
end
function MiniTvInBornIsland:ReceiveEndPlay(EndPlayReason)
  if not self:HasAuthority() then
    if self.BannerUI then
      self.BannerUI:Close()
    end
    if self.TipsUI then
      self.TipsUI:Close()
    end
    self:HideBroadcastButton()
  end
  MiniTvInBornIsland.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MiniTvInBornIsland:InitTipsUI()
  log(bWriteLog and "MiniTvInBornIsland InitTipsUI ")
  local MiniTvTipsUI = UIManager.UI_Config_InGame.MiniTvBannerTipsUI
  if MiniTvTipsUI then
    local userWidget = self.Widget_Tips:GetUserWidgetObject()
    local UIClass = require(MiniTvTipsUI.moduleName)
    self.TipsUI = UIClass(self.Object)
    self.TipsUI:InitWithWidget(userWidget)
    local tipsUI_hide_callback = function()
      self.Widget_Tips:SetVisibility(false, false)
    end
    self.TipsUI.HideCallback = tipsUI_hide_callback
    self.Widget_Tips:SetVisibility(false, false)
    self.TipsUI:Hide()
  end
end
function MiniTvInBornIsland:Init3DUI()
  log(bWriteLog and "MiniTvInBornIsland Init3DUI ")
  local MiniTvBannerUI = UIManager.UI_Config_InGame.MiniTvBannerUI
  if MiniTvBannerUI then
    local userWidget = self.Widget:GetUserWidgetObject()
    local UIClass = require(MiniTvBannerUI.moduleName)
    self.BannerUI = UIClass(self.Object)
    self.BannerUI:InitWithWidget(userWidget)
    local BannerUI_hide_callback = function()
      self.Widget:SetVisibility(false, false)
    end
    self.BannerUI.HideCallback = BannerUI_hide_callback
    self.Widget:SetVisibility(false, false)
    self.BannerUI:Hide()
  end
end
function MiniTvInBornIsland:ShowBroadcastButton()
  print(bWriteLog and "MiniTvInBornIsland ShowBroadcastButton")
  local log_mini_tv = require("client.slua.logic.mini_tv.logic_mini_tv")
  if log_mini_tv.GetBannerList() and #log_mini_tv.GetBannerList() > 0 then
    EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_SHOW_NORMAL_BTN, "Type_MiniTV_Broadcast")
  end
end
function MiniTvInBornIsland:HideBroadcastButton()
  print(bWriteLog and "MiniTvInBornIsland HideBroadcastButton")
  EventSystem:postEvent(EVENTTYPE_INGAME_BASIC_SKILL_MENU_BP, EVENTID_HIDE_NORMAL_BTN, "Type_MiniTV_Broadcast")
end
function MiniTvInBornIsland:PlayTvSayHello()
  self:MontagePlay(MontagePath.SayHelloMontage)
end
function MiniTvInBornIsland:MontagePlay(path)
  if not slua.isValid(self.SKeletalMesh) then
    print(bWriteLog and "MiniTvInBornIsland MontagePlay is not Valid skele")
    return
  end
  print(bWriteLog and "MiniTvInBornIsland MontagePlay" .. tostring(path))
  local asset_util = require("common.asset_util")
  if self.HandleID and self.HandleID ~= 0 then
    asset_util.CancelAssetAsync(self.HandleID)
  end
  self.HandleID = asset_util.GetAssetAsyncOneParam(path, self.MontagePlay_Real, self)
end
function MiniTvInBornIsland:MontagePlay_Real(animAsset)
  self.HandleID = nil
  if not slua.isValid(self.SKeletalMesh) then
    print(bWriteLog and "MiniTvInBornIsland MontagePlay_Real is not Valid ")
    return
  end
  local AnimInstance = self.SKeletalMesh:GetAnimInstance()
  if not slua.isValid(AnimInstance) then
    print(bWriteLog and "MiniTvInBornIsland MontagePlay_Real is not Valid ")
    return
  end
  local EMontagePlayReturnType = import("EMontagePlayReturnType")
  AnimInstance:Montage_Play(animAsset, 1, EMontagePlayReturnType.MontageLength, 0)
end
function MiniTvInBornIsland:ShowBannerUI()
  local _ShowBanner = function()
    self.Widget:SetVisibility(true, false)
    self.BannerUI:Show()
    self.showTimer = nil
  end
  self.isShowing = true
  self.ActorRoatate = 30
  self.showTimer = self:AddGameTimer(1.2, false, _ShowBanner)
end
function MiniTvInBornIsland:HideBannerUI()
  if self.BannerUI then
    self.BannerUI:DelayHide()
  end
  if self.isShowing then
    self.isShowing = false
    self.ActorRoatate = 0
  end
end
function MiniTvInBornIsland:ShowTipsUI()
  if self.isInteractiving then
    return
  end
  if self.Widget_Tips then
    self.Widget_Tips:SetVisibility(true, false)
  end
  if self.TipsUI then
    self.TipsUI:Show()
  end
end
function MiniTvInBornIsland:StartCyclePlayTv()
  print(bWriteLog and "MiniTvInBornIsland:StartCyclePlayTv")
  if self.playActionOrTipsTimer then
    self:RemoveGameTimer(self.playActionOrTipsTimer)
    self.playActionOrTipsTimer = nil
  end
  self.playActionOrTipsTimer = self:AddGameTimer(8, true, function()
    self:RandomPlayActionOrTips()
  end)
end
function MiniTvInBornIsland:RandomPlayActionOrTips()
  local rNum = math.random(0, 1)
  print(bWriteLog and "MiniTvInBornIsland:RandomPlayActionOrTips rNum = " .. tostring(rNum))
  if rNum == 1 then
    self:ChangeActionIndex()
  elseif rNum == 0 then
    self:ShowTipsUI()
  end
end
function MiniTvInBornIsland:ChangeActionIndex()
  self.CurActionIndex = math.random(0, 1)
  if #self.PlayListIndex >= 2 then
    self.PlayListIndex = {}
  end
  for _, value in ipairs(self.PlayListIndex) do
    if value == self.CurActionIndex then
      self:ChangeActionIndex()
      return
    end
  end
  table.insert(self.PlayListIndex, self.CurActionIndex)
  self:PlayTvAnimationIndex(self.CurActionIndex)
end
function MiniTvInBornIsland:PlayTvAnimationIndex(index)
  if self:IsAnyMontagePlaying() then
    return
  end
  if self.isInteractiving then
    return
  end
  if index == 0 then
    self:MontagePlay(MontagePath.IdleMontage)
  elseif index == 1 then
    self:MontagePlay(MontagePath.WinMontage)
  end
end
function MiniTvInBornIsland:IsAnyMontagePlaying()
  print(bWriteLog and "MiniTvInBornIsland PlayTvAnimationIndex")
  if not slua.isValid(self.SKeletalMesh) then
    log_error("MiniTvInBornIsland IsAnyMontagePlaying SKeletalMesh is not Valid ")
    return false
  end
  local AnimInstance = self.SKeletalMesh:GetAnimInstance()
  if not slua.isValid(AnimInstance) then
    log_error("MiniTvInBornIsland AnimInstance is not Valid")
    return false
  end
  return AnimInstance:IsAnyMontagePlaying()
end
function MiniTvInBornIsland:OnBannerUIHide()
  print(bWriteLog and "MiniTvInBornIsland:OnBannerUIHide")
  self:MontagePlay(MontagePath.BroadcastEndMontage)
  self:AddTimer(0.4, function()
    self:SetActorRotate(0)
    self.ActorRoatate = 0
  end)
end
function MiniTvInBornIsland:OnClientClickInteractiveButton(Character, component)
  if self:HasAuthority() then
    return false
  end
  print(bWriteLog and "MiniTvInBornIsland OnClientClickInteractiveButton")
  self:HideBannerUI()
  self:HideBroadcastButton()
  self.SayHelloTimer = self:AddGameTimer(1.5, false, function()
    self:PlayTvSayHello()
  end)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Mini_Say_Hello)
  return true
end
function MiniTvInBornIsland:OnClickBroadcast()
  self:ShowBannerUI()
  self:MontagePlay(MontagePath.BroadcastMontage)
end
function MiniTvInBornIsland:OnSkillTrigger(_, _, PlayerPawn, SkillID, PawnState)
  if SkillID ~= SKILLID_SAYHELLO then
    return
  end
  if self.SayHelloTimer then
    self:RemoveGameTimer(self.SayHelloTimer)
    self.SayHelloTimer = nil
  end
end
function MiniTvInBornIsland:OnStoppedSkillAction(character, reason, skillId, Component)
  if skillId ~= SKILLID_SAYHELLO then
    return
  end
  if self:HasAuthority() then
    return
  end
  print(bWriteLog and "MiniTvInBornIsland OnStoppedSkillAction")
  self:ShowBroadcastButton()
end
local Class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CMiniTvInBornIsland = Class(CInteractiveActorBase, nil, MiniTvInBornIsland)
return CMiniTvInBornIsland
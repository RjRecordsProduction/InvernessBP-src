local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local SecurityNotifyPCFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
SecurityNotifyPCFeature.ClientRPC.ClientRPC_WeakTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
SecurityNotifyPCFeature.ClientRPC.ClientRPC_NormalTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
SecurityNotifyPCFeature.ClientRPC.ClientRPC_StrongTips = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
SecurityNotifyPCFeature.ClientRPC.ClientRPC_SyncBanID = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function SecurityNotifyPCFeature:ctor()
  self.NormalTipsTimer = nil
end
function SecurityNotifyPCFeature:ReceiveBeginPlay()
  SecurityNotifyPCFeature.__super.ReceiveBeginPlay(self)
end
function SecurityNotifyPCFeature:ReceiveEndPlay()
  SecurityNotifyPCFeature.__super.ReceiveEndPlay(self)
end
function SecurityNotifyPCFeature:Notify(nCopyType, sBanReason)
  if nCopyType == 1 then
    self:ClientRPC_WeakTips(sBanReason)
  elseif nCopyType == 2 then
    self:ClientRPC_NormalTips(sBanReason)
  elseif nCopyType == 3 then
    self:ClientRPC_StrongTips(sBanReason)
  end
end
function SecurityNotifyPCFeature:SyncBanInfo(BanInfo)
  local TimeUtil = require("client.common.time_util")
  local UTCTime = TimeUtil.GetServerTimeInSec()
  if BanInfo then
    log_tree("SecurityNotifyPCFeature:SyncBanInfo ban", BanInfo)
    if BanInfo[BanMacro.PLAYER_VOICE_PRE_FILTER] then
      self:ClientRPC_SyncBanID(BanMacro.PLAYER_VOICE_PRE_FILTER, 0)
    end
    if BanInfo[BanMacro.PLAYER_BAN_GLOBAL_MI] then
      local BanData = BanInfo[BanMacro.PLAYER_BAN_GLOBAL_MI]
      if BanData.end_time and 0 < BanData.end_time and UTCTime < BanData.end_time then
        self:ClientRPC_SyncBanID(BanMacro.PLAYER_BAN_GLOBAL_MI, BanData.end_time)
      end
    end
  else
    print(bWriteLog and "SecurityNotifyPCFeature:SyncBanInfo no player_info ban data")
  end
end
function SecurityNotifyPCFeature:ClientRPC_WeakTips(sBanReason)
  IngameTipsTools.BattleGeneralTip(12006, sBanReason, "")
end
function SecurityNotifyPCFeature:ClientRPC_NormalTips(sBanReason)
  if self.NormalTipsTimer then
    print(bWriteLog and "CSecurityNotifyComp NormalTips already exist")
    return
  end
  local NormalTipsUI = UIManager.ShowUI(UIManager.UI_Config_InGame.SecurityNotifyNormalTips)
  if NormalTipsUI then
    NormalTipsUI:SetTipsText(sBanReason)
  end
  self.NormalTipsTimer = self:AddGameTimer(10, false, function()
    UIManager.CloseUI(UIManager.UI_Config_InGame.SecurityNotifyNormalTips)
    self.NormalTipsTimer = nil
  end)
end
function SecurityNotifyPCFeature:ClientRPC_StrongTips(sBanReason)
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  local tExtraData = {canOkTime = 10}
  IngameTipsTools.ShowMsgBox(1, "Alert", sBanReason, nil, nil, nil, nil, tExtraData)
end
function SecurityNotifyPCFeature:ClientRPC_SyncBanID(BanID, EndTime)
  print(bWriteLog and "SecurityNotifyPCFeature:ClientRPC_SyncBanID " .. BanID .. " EndTime " .. EndTime)
  if BanID == BanMacro.PLAYER_VOICE_PRE_FILTER then
    local VoiceReportSubsystem = SubsystemMgr:Get("VoiceReportSubsystem")
    if VoiceReportSubsystem then
      VoiceReportSubsystem:EnablePreFilter(true)
    end
  elseif BanID == BanMacro.PLAYER_BAN_GLOBAL_MI then
    local VoiceReportSubsystem = SubsystemMgr:Get("VoiceReportSubsystem")
    if VoiceReportSubsystem and VoiceReportSubsystem.GlobalMicBan then
      VoiceReportSubsystem:GlobalMicBan(true, EndTime)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, SecurityNotifyPCFeature)
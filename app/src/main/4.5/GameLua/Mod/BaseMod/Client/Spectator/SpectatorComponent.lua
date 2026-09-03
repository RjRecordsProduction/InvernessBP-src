local CSpectatorComponent = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
CSpectatorComponent.ServerRPC.ServerRPC_HawkBroadcast = {
  Reliable = true,
  Params = {}
}
CSpectatorComponent.ServerRPC.ServerRPC_HawkReportCheat = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
CSpectatorComponent.ServerRPC.ServerRPC_RequestImprison = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
CSpectatorComponent.ClientRPC.ClientRPC_HawkReportSuccess = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
CSpectatorComponent.ClientRPC.ClientRPC_SyncFatalDamagerMap = {
  Reliable = true,
  Params = {
    {
      UEnums.EPropertyClass.Array,
      import("ReportFatalDamage")
    },
    UEnums.EPropertyClass.Bool
  }
}
CSpectatorComponent.ClientRPC.ClientRPC_SyncInspectorBroadcastCount = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
function CSpectatorComponent:ctor()
  self.bIsShowSmokeForPCOB = true
  self.bIsShowFragGrenadeCountdownForPCOB = true
  self.bHasHawkBroadcast = false
end
function CSpectatorComponent:_PostConstruct()
  CSpectatorComponent.__super._PostConstruct(self)
  if not Client then
    print(bWriteLog and "CSpectatorComponent:_PostConstruct")
    local uPlayerController = self:GetOwner()
    if slua.isValid(uPlayerController) and uPlayerController.PlayerControllerReconnectedDelegate then
      print(bWriteLog and "CSpectatorComponent:_PostConstruct 1")
      self:AddControlEvent(uPlayerController, "PlayerControllerReconnectedDelegate", function()
        print(bWriteLog and "CSpectatorComponent:_PostConstruct 2")
        self:OnOwnerReconnected()
      end)
    end
  end
end
function CSpectatorComponent:OnOwnerReconnected()
  print(bWriteLog and "CSpectatorComponent:OnOwnerReconnected")
  EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_RECONNECT, self.Object)
end
function CSpectatorComponent:ReceiveBeginPlay()
  CSpectatorComponent.__super.ReceiveBeginPlay(self)
  self:RegistEvents()
  if not Client then
    self.SyncInspectorHandle = self:AddTimer(0, function()
      print(bWriteLog and "CSpectatorComponent:ReceiveBeginPlay EVENTID_SECURITY_SYNC_INSPECTOR_BROADCAST_COUNT")
      EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_SYNC_INSPECTOR_BROADCAST_COUNT, self.Object)
    end)
  end
end
function CSpectatorComponent:ReceiveEndPlay(EndReason, bClearTable)
  if self.SyncInspectorHandle then
    self:RemoveTimer(self.SyncInspectorHandle)
    self.SyncInspectorHandle = nil
  end
  CSpectatorComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function CSpectatorComponent:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PCOB, EVENTID_PCOB_SHOWORHIDESMOKE_CLICK, self._OnPCOBShowOrHideSmokeByClick, self)
  self:AddCommonEvent(EVENTTYPE_PCOB, EVENTID_PCOB_SHOWORHIDE_FRAGGRENADE_COUNTDOWN_CLICK, self._OnPCOBShowOrHideFragGrenadeCountdownByClick, self)
end
function CSpectatorComponent:_OnPCOBShowOrHideSmokeByClick()
  self.bIsShowSmokeForPCOB = not self.bIsShowSmokeForPCOB
  EventSystem:postEvent(EVENTTYPE_PCOB, EVENTID_PCOB_SHOWORHIDESMOKE)
end
function CSpectatorComponent:_OnPCOBShowOrHideFragGrenadeCountdownByClick()
  self.bIsShowFragGrenadeCountdownForPCOB = not self.bIsShowFragGrenadeCountdownForPCOB
  EventSystem:postEvent(EVENTTYPE_PCOB, EVENTID_PCOB_SHOWORHIDE_FRAGGRENADE_COUNTDOWN)
end
function CSpectatorComponent:ServerRPC_HawkBroadcast()
  print(bWriteLog and "ServerRPC_HawkBroadcast")
  if not self.bHasHawkBroadcast then
    local EObserverType = import("EObserverType")
    if self:GetObserverType() == EObserverType.EObserverType_HawkEyeObserver then
      local sPlayerName = self:GetOwnerPlayerName()
      local uDSUtils = slua_DSHUD:GetUtils()
      if slua.isValid(uDSUtils) then
        local uDSPlayer = uDSUtils:FindPlayerByPlayerName(sPlayerName, "PureWatcher")
        if slua.isValid(uDSPlayer) then
          local nAliasID = uDSPlayer.InspectorAliasId
          if nAliasID ~= nil then
            print(bWriteLog and "ServerRPC_HawkBroadcast AliasID = ", nAliasID)
            self:OnHawkBroadcast(sPlayerName, nAliasID)
            self.bHasHawkBroadcast = true
          end
        end
      end
    end
  end
end
function CSpectatorComponent:ServerRPC_HawkReportCheat(bInspectorBroadcast)
  print(bWriteLog and "ServerRPC_HawkReportCheat")
  local nWatchedPlayerKey = self:_GetWatchedPlayerKey()
  if 0 < nWatchedPlayerKey then
    print(bWriteLog and "WatchedPlayerKey:" .. tostring(nWatchedPlayerKey))
    EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_HAWK_REPORT, nWatchedPlayerKey, self.Object, bInspectorBroadcast)
  end
end
function CSpectatorComponent:ServerRPC_RequestImprison(bImprison)
  print(bWriteLog and "ServerRPC_RequestImprison bImprison" .. tostring(bImprison))
  local nWatchedPlayerKey = self:_GetWatchedPlayerKey()
  if 0 < nWatchedPlayerKey then
    print(bWriteLog and "WatchedPlayerKey:" .. tostring(nWatchedPlayerKey))
    EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_HAWK_IMPRISON, nWatchedPlayerKey, bImprison)
  end
end
function CSpectatorComponent:ClientRPC_HawkReportSuccess(bReporter)
  print(bWriteLog and "ClientRPC_HawkReportSuccess")
  EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_HAWK_REPORT_SUCCESS, bReporter)
end
function CSpectatorComponent:ClientRPC_SyncFatalDamagerMap(FatalDamageArray, bIsKnockDown)
  print(bWriteLog and "ClientRPC_SyncFatalDamagerMap")
  EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_SYNC_FATAL_DAMAGE, FatalDamageArray, bIsKnockDown)
end
function CSpectatorComponent:ClientRPC_SyncInspectorBroadcastCount(nInspectorBroadcastCount, bSendHawkReportBoardcast)
  print(bWriteLog and "ClientRPC_SyncInspectorBroadcastCount")
  EventSystem:postEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_RECV_INSPECTOR_BROADCAST_COUNT, nInspectorBroadcastCount, bSendHawkReportBoardcast)
end
function CSpectatorComponent:_GetWatchedPlayerKey()
  local uOwner = self:GetOwner()
  if not slua.isValid(uOwner) then
    print(bWriteLog and "invalid uOwner")
    return 0
  end
  local tLobbyWatchInfo = uOwner.LobbyWatchInfo
  if not tLobbyWatchInfo then
    print(bWriteLog and "invalid tLobbyWatchInfo")
    return 0
  end
  if tLobbyWatchInfo.bIsHawkEyeSpectator and tLobbyWatchInfo.WatchedPlayerKey then
    return tLobbyWatchInfo.WatchedPlayerKey
  else
    return 0
  end
end
function CSpectatorComponent:OnHawkBroadcast(sPlayerName, nAliasID)
  local ShowTipsAliasConfig = {
    [2493552] = {TipsID = 11800, AliasTitleID = 32701},
    [2493553] = {TipsID = 11801, AliasTitleID = 32702},
    [2493554] = {TipsID = 11802, AliasTitleID = 32704},
    [2493555] = {TipsID = 11803, AliasTitleID = 32703},
    [2493556] = {TipsID = 11804, AliasTitleID = 32705},
    [2493557] = {TipsID = 11805, AliasTitleID = 32706}
  }
  if nAliasID == 0 then
    nAliasID = 2493552
  end
  local aliasConfig = ShowTipsAliasConfig[nAliasID]
  local RealTimeBan = require("GameLua.Mod.BaseMod.Common.RealTimeBan.RealTimeBan")
  local bAnonymous = RealTimeBan.GetUIDInspectorBroadcastAnonymous(self.OwnerUID)
  local NameParam
  if bAnonymous then
    NameParam = {
      IsNeedTranslation = true,
      ParamValue = RealTimeBan.INSPECTOR_ANONYMOUS_NAME_LOCKEY
    }
  else
    NameParam = {IsNeedTranslation = false, ParamValue = sPlayerName}
  end
  local ParamTable = {
    [1] = NameParam,
    [2] = {
      IsNeedTranslation = true,
      ParamValue = aliasConfig.AliasTitleID
    }
  }
  local TipsID = aliasConfig.TipsID
  if RealTimeBan.IsUIDOnRankInspector(self.OwnerUID) then
    TipsID = 12096 + math.min(math.max(0, nAliasID - 2493552), 5) + RealTimeBan.GetTipsIDOffsetWithUID(self.OwnerUID)
  end
  print(bWriteLog and string.format("CSpectatorComponent:OnHawkBroadcast nAliasID=%d, TipsID=%d, Anonymous=%s", nAliasID, TipsID, tostring(self.CurrentBroadcastAnonymous)))
  IngameTipsTools.BattleGeneralTipWithTranslation(TipsID, ParamTable)
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponentBase, nil, CSpectatorComponent)
local PlayerControllerIngameLikeFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local IngameLikeConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.IngameLikeConfig")
local IngameLikeUtilDS = require("GameLua.Mod.BaseMod.DS.Like.IngameLikeUtilDS")
local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
function PlayerControllerIngameLikeFeature:ReceiveBeginPlay()
  PlayerControllerIngameLikeFeature.__super.ReceiveBeginPlay(self)
  if Client then
    self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if self.IngameLikeClientSubSystem == nil then
      print(bWriteLog and "PlayerControllerIngameLikeFeature cannot get IngameLikeClientSubSystem!!!")
    end
  else
    self.IngameLikeDSSubSystem = SubsystemMgr:Get("IngameLikeDSSubSystem")
    if self.IngameLikeDSSubSystem == nil then
      print(bWriteLog and "PlayerControllerIngameLikeFeature cannot get IngameLikeDSSubSystem!!!")
    end
  end
end
function PlayerControllerIngameLikeFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:ReceiveEndPlay")
  self.IngameLikeClientSubSystem = nil
  self.IngameLikeDSSubSystem = nil
  PlayerControllerIngameLikeFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_TriggerLike = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.UInt64,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:GetIngameLikeClientSubSystem()
  if nil == self.IngameLikeClientSubSystem then
    self.IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if self.IngameLikeClientSubSystem == nil then
      print(bWriteLog and "PlayerControllerIngameLikeFeature cannot get IngameLikeClientSubSystem!!!")
    end
  end
  return self.IngameLikeClientSubSystem
end
function PlayerControllerIngameLikeFeature:RPC_Client_TriggerLike(PlayerKey, ConditionID, OtherPlayerUID, ItemID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_TriggerLike", PlayerKey, ConditionID, OtherPlayerUID, ItemID)
  if self:GetIngameLikeClientSubSystem() then
    local PlayerName = ""
    local uPlayerState = IngameLikeUtilClient.GetMyPlayerState()
    if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
      local TeammateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      for _, uTeamPS in pairs(TeammateList) do
        if slua.isValid(uTeamPS) and uTeamPS.PlayerKey == PlayerKey then
          PlayerName = uTeamPS.PlayerName or ""
          break
        end
      end
      if PlayerName == "" and uPlayerState.PlayerKey == PlayerKey then
        PlayerName = uPlayerState.PlayerName or ""
      end
    end
    local Message = {
      PlayerKey = PlayerKey,
      ConditionID = ConditionID,
      OtherPlayerUID = OtherPlayerUID,
      ItemID = ItemID,
          }
    self.IngameLikeClientSubSystem:ReceiveTirggerLike(Message)
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_TriggerWatchLike = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.UInt64,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_TriggerWatchLike(PlayerKey, ConditionID, OtherPlayerUID, ItemID, ExtraDes)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_TriggerWatchLike", PlayerKey, ConditionID, OtherPlayerUID, ItemID, ExtraDes)
  if self:GetIngameLikeClientSubSystem() then
    local Message = {
      PlayerKey = PlayerKey,
      ConditionID = ConditionID,
      OtherPlayerUID = OtherPlayerUID,
      ItemID = ItemID,
          }
    self.IngameLikeClientSubSystem:ReceiveTriggerWatchLike(Message)
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_Like = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_Like(PlayerKey, ConditionID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_Like", PlayerKey, ConditionID)
  local PlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
  local SendPlayerState = Game:GetPlayerStateByUID(self.Owner.UID)
  local Config = IngameLikeConfig[ConditionID]
  if not (Game:IsValid(PlayerState) and Game:IsValid(SendPlayerState)) or not Config then
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERACTIVE_BEHAVIOR, self.Owner.UID, PlayerState.UID, "Like")
  if Config.bSendBack then
    local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
    if Game:IsValid(PlayerController) then
      PlayerController.IngameLikeFeature:RPC_Client_RecieveLike(self.Owner.UID, ConditionID)
    end
    if Config.BoardcastType ~= IngameLikeConfig.EBoardcastType.OnlyForWatch then
      local LikeType = IngameLikeUtilDS.GetLikeTypeByConditionID(ConditionID, nil, nil, true)
      if LikeType then
        PlayerState:ReportLikeTeammate(SendPlayerState.UID, LikeType)
      end
    end
    if Config.BoardcastType ~= IngameLikeConfig.EBoardcastType.OnlyForWatch or ConditionID == 8 then
      local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
      if PlayerDataMgr then
        PlayerDataMgr.AddTableElemTLog(self.Owner.UID, "LikeTeammatesList", PlayerState.UID)
        PlayerDataMgr.AddTableElemTLog(PlayerState.UID, "BeLikedTeammatesList", self.Owner.UID)
      end
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_LIKE, self.Owner.UID)
  end
  local PlayerController = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if Game:IsValid(PlayerController) then
    PlayerController.IngameLikeFeature:RPC_Client_LikeProgress(ConditionID)
  end
  if Config.bBroadcastProgress then
    local PlayerStateTArray = CGame:GetTeamMatePlayerStateList(PlayerKey, true)
    if PlayerStateTArray and PlayerStateTArray:Num() ~= 0 then
      for Index = 0, PlayerStateTArray:Num() - 1 do
        local PlayerStateOne = PlayerStateTArray:Get(Index)
        if Game:IsValid(PlayerStateOne) then
          local PlayerControllerOne = Game:GetPlayerControllerByUID(PlayerStateOne.UID)
          if Game:IsValid(PlayerControllerOne) then
            PlayerControllerOne.IngameLikeFeature:RPC_Client_LikeProgress(ConditionID)
          end
        end
      end
    end
  end
  if Config.BoardcastType ~= IngameLikeConfig.EBoardcastType.OnlyForWatch then
    if not Config.bSendBack then
      local LikeType = IngameLikeUtilDS.GetLikeTypeByConditionID(ConditionID)
      if LikeType then
        SendPlayerState:ReportLikeSelf(LikeType)
      end
    else
      local LikeType = IngameLikeUtilDS.GetLikeTypeByConditionID(ConditionID, nil, true)
      if LikeType then
        SendPlayerState:ReportLikeTeammate(PlayerState.UID, LikeType)
      end
    end
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_ClientReady = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_ClientReady(PlayerKey, TeamID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_ClientReady", PlayerKey, self.Owner.PlayerKey, TeamID)
  if self.IngameLikeDSSubSystem then
    self.IngameLikeDSSubSystem:OnClientReady(self.Owner.PlayerKey, TeamID)
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_ClientEnterCircle = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_ClientEnterCircle(PlayerKey, TeamID, CircleIndex)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_ClientEnterCircle", PlayerKey, self.Owner.PlayerKey, TeamID, CircleIndex)
  if self.IngameLikeDSSubSystem then
    self.IngameLikeDSSubSystem:HandlePlayerEnterCircle(self.Owner.PlayerKey, TeamID, CircleIndex)
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_RespondLike = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_RespondLike(UID, ConditionID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_RespondLike", UID, ConditionID)
  local Config = IngameLikeConfig[ConditionID]
  if Config and Config.BoardcastType == IngameLikeConfig.EBoardcastType.OnlyForWatch then
    return
  end
  local SendPlayerState = Game:GetPlayerStateByUID(self.Owner.UID)
  local PlayerState = Game:GetPlayerStateByUID(UID)
  if Game:IsValid(SendPlayerState) and Game:IsValid(PlayerState) then
    local LikeType = IngameLikeUtilDS.GetLikeTypeByConditionID(ConditionID, nil, nil, nil, true)
    if LikeType then
      SendPlayerState:ReportLikeTeammate(PlayerState.UID, LikeType)
    end
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_RecieveLike = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64,
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_RecieveLike(UID, ConditionID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_RecieveLike", UID, ConditionID)
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:ReceiveLike({UID = UID, ConditionID = ConditionID})
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_KillNumChange = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_KillNumChange(KillStr)
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_LikeSwitch = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_LikeSwitch(Switch)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_LikeSwitch", self.Owner.UID, Switch)
  if not IngameLikeUtilDS.IsMultiClassicMode() then
    print(bWriteLog and "[PlayerControllerIngameLikeFeature] not multi classic mode")
    return
  end
  local PlayerState = Game:GetPlayerStateByUID(self.Owner.UID)
  if Game:IsValid(PlayerState) then
    print(bWriteLog and "[PlayerControllerIngameLikeFeature] report like switch: " .. tostring(Switch))
    PlayerState:ReportLikeSwitch(Switch)
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_HideLike = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_HideLike(ConditionID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_HideLike", ConditionID)
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:ReceiveHideLike(ConditionID)
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_LikeProgress = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_LikeProgress(ConditionID)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_LikeProgress", ConditionID)
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:ReceiveLikeProgress(ConditionID)
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_RPGive = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_RPGive(PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_RPGive", PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
  local PlayerState = Game:GetPlayerStateByPlayerKey(PlayerKey)
  if not Game:IsValid(PlayerState) then
    print(bWriteLog and "[PlayerControllerIngameLikeFeature] invalid player state")
    return
  end
  local TargetPC = Game:GetPlayerControllerByPlayerKey(PlayerKey)
  if slua.isValid(TargetPC) then
    TargetPC.IngameLikeFeature:RPC_Client_RPGiveNotify(PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
  else
    print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_RPGive TargetPC invalid!!!")
  end
  local PlayerStateTArray = CGame:GetTeamMatePlayerStateList(PlayerKey, true)
  if not PlayerStateTArray or PlayerStateTArray:Num() <= 0 then
    print(bWriteLog and "[PlayerControllerIngameLikeFeature] no player state array")
    return
  end
  for Index = 0, PlayerStateTArray:Num() - 1 do
    local PlayerStateOne = PlayerStateTArray:Get(Index)
    if Game:IsValid(PlayerStateOne) then
      local PlayerControllerOne = Game:GetPlayerControllerByUID(PlayerStateOne.UID)
      if slua.isValid(PlayerControllerOne) then
        PlayerControllerOne.IngameLikeFeature:RPC_Client_RPGiveNotify(PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
        if PlayerStateOne.PlayerName == receiver_name then
          EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERACTIVE_BEHAVIOR, self.Owner.UID, PlayerStateOne.UID, "Gift")
        end
      else
        print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_RPGive PlayerStateOne invalid!!!", PlayerStateOne.UID)
      end
    end
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_RPGiveNotify = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_RPGiveNotify(PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_RPGiveNotify", PlayerKey, type, RpNum, sender_name, receiver_name, bIsShowRpPlusTips, bIsShowGoldenNickName)
  if self:GetIngameLikeClientSubSystem() then
    local Message = {
      PlayerKey = PlayerKey,
      type = type,
      RpNum = RpNum,
      sender_name = sender_name,
          }
    self.IngameLikeClientSubSystem:ReceiveRpGiveNotify(Message, bIsShowRpPlusTips, bIsShowGoldenNickName)
  end
end
PlayerControllerIngameLikeFeature.ClientRPC.RPC_Client_ShowOff = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Client_ShowOff(ShowOffType)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Client_ShowOff", ShowOffType)
  if self:GetIngameLikeClientSubSystem() then
    self.IngameLikeClientSubSystem:ReceiveShowOffInfo(ShowOffType)
  end
end
PlayerControllerIngameLikeFeature.ServerRPC.RPC_Server_ShowOff = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function PlayerControllerIngameLikeFeature:RPC_Server_ShowOff(ShowOffType)
  print(bWriteLog and "PlayerControllerIngameLikeFeature:RPC_Server_ShowOff", ShowOffType)
  if self.IngameLikeDSSubSystem then
    self.IngameLikeDSSubSystem:HandlePlayerShowOff(self.Owner.PlayerKey, ShowOffType)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerControllerIngameLikeFeature)
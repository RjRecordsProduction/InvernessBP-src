local CommerFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local SuitMultiShapeDataUtil = require("GameLua.Activity.Commercialize.GamePlay.SuitMultiShape.SuitMultiShapeDataUtil")
function CommerFeature:ctor()
  self.HolographyList = slua.Array(UEnums.EPropertyClass.Int)
  self.HolographyCurrentSelectID = 0
  self.DragonSuitList = slua.Array(UEnums.EPropertyClass.Int)
  self.bLock = false
  self.InheritDragonSuitList = slua.Array(UEnums.EPropertyClass.Int)
  self.bInheritDragonSuitLock = false
  self.XSuitUnlockLevelList = slua.Array(UEnums.EPropertyClass.Int)
  self.WeaponShowEmoteList = slua.Array(UEnums.EPropertyClass.Int)
  self.ChangeScalePetIDList = slua.Array(UEnums.EPropertyClass.Int)
  self.TeamMemberPetID2EnlargeState = {}
  self.MileStoneData = slua.Array(UEnums.EPropertyClass.Int)
  self.MileStoneMap = {}
  self.bUpgradeCarUseMusicList = false
  self.PetSwitchEffectID = 0
  self.TeamMemberEffectItemMap = {}
  self.bHasPetBubblePrivilege = false
  self.PetBubbleIDList = slua.Array(UEnums.EPropertyClass.Int)
  self.bEnableMiniTV = false
  self.MiniTVDressID = 0
  self.MiniTVActionIDList = slua.Array(UEnums.EPropertyClass.Int)
  self.TeamMemberMiniTvDressID = {}
end
function CommerFeature:ReceiveBeginPlay()
  CommerFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_PRE_TEAM_SHOW_CREATE_READY, self.OnTeamShowPreCreate, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_BATTLE_RESULT, self.OnPlayerBattleResult, self)
  end
end
function CommerFeature:OnPlayerBattleResult()
  log(bWriteLog and "CommerFeature:OnPlayerBattleResult.  ")
  self:OnTeamShowPreCreateProcessPetData()
  self:OnTeaamShowPreCreateProcessMiniTvData()
end
function CommerFeature:OnTeamShowPreCreate()
  print(bWriteLog and "CommerFeature:OnTeamShowPreCreate")
  self:OnTeamShowPreCreateProcessPetData()
  self:OnTeaamShowPreCreateProcessMiniTvData()
end
function CommerFeature:GetLifetimeReplicatedProps()
  print(bWriteLog and "CommercializeActor:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "HolographyList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "DragonSuitList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "bLock",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "InheritDragonSuitList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "bInheritDragonSuitLock",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "XSuitUnlockLevelList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "WeaponShowEmoteList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "ChangeScalePetIDList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "MileStoneData",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "bUpgradeCarUseMusicList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "PetSwitchEffectID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "bHasPetBubblePrivilege",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "PetBubbleIDList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "bEnableMiniTV",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "MiniTVDressID",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Int
    },
    {
      "MiniTVActionIDList",
      ELifetimeCondition.COND_InitialOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
end
CommerFeature.ServerRPC.RPCServer_CollectScoreReq = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
CommerFeature.ClientRPC.RPCClient_CollectScoreRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
function CommerFeature:RPCServer_CollectScoreReq(sPlayerUID)
  print(bWriteLog and "CommerFeature:RPCServer_CollectScoreReq sPlayerUID:" .. tostring(sPlayerUID))
  local playerState = Game:GetPlayerStateByUID(tonumber(sPlayerUID))
  if not Game:IsValid(playerState) then
    print(bWriteLog and "CommerFeature:RPCServer_CollectScoreReq playerState is not valid UID:" .. tostring(sPlayerUID))
    return self:RPCClient_CollectScoreRsp(false, sPlayerUID, 0, 0, false)
  else
    return self:RPCClient_CollectScoreRsp(true, sPlayerUID, playerState.CollectScore, playerState.SeasonCollectScore, playerState.CollectScorePrivacy)
  end
end
function CommerFeature:RPCClient_CollectScoreRsp(bSuccess, sPlayerUID, collectScore, seasonCollectScore, privacy)
  print(bWriteLog and "CommerFeature:RPCClient_CollectScoreRsp bSuccess:" .. tostring(bSuccess) .. " sPlayerUID: " .. tostring(sPlayerUID) .. " collectScore: " .. tostring(collectScore) .. " seasonCollectScore: " .. tostring(seasonCollectScore) .. tostring(privacy))
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_RP_FIRST_PLAYER_COLLECT_SCORE_RSP, bSuccess, sPlayerUID, collectScore, seasonCollectScore, privacy)
end
CommerFeature.ServerRPC.RPCServer_XSuitIconReq = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
CommerFeature.ClientRPC.RPCClient_XSuitIconRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Int
  }
}
function CommerFeature:RPCServer_XSuitIconReq(sPlayerUID)
  print(bWriteLog and "CommerFeature:RPCServer_XSuitIconReq sPlayerUID:" .. tostring(sPlayerUID))
  local character = Game:GetCharacterByUID(tonumber(sPlayerUID))
  if not Game:IsValid(character) then
    print(bWriteLog and "CommerFeature:RPCServer_XSuitIconReq character is invalid")
    self:RPCClient_XSuitIconRsp(false, 0)
    return
  end
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  local iconId = XSuitAvatarDataUtil:GetValidXSuitIconId(tonumber(sPlayerUID))
  self:RPCClient_XSuitIconRsp(true, iconId)
end
function CommerFeature:RPCClient_XSuitIconRsp(bSuccess, xsuit_icon_id)
  print(bWriteLog and "CommerFeature:RPCClient_XSuitIconRsp bSuccess:" .. tostring(bSuccess) .. " xsuit_icon_id: " .. tostring(xsuit_icon_id))
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_RP_FIRST_PLAYER_XSUIT_ICON_RSP, bSuccess, xsuit_icon_id)
end
function CommerFeature:OnDropItem(_, _, PlayerKey, ItemID, _, Reason, _)
  SuitMultiShapeDataUtil:ServerDropItem(PlayerKey, ItemID, Reason)
end
CommerFeature.ClientRPC.RPCClient_TeamShowPetEnlargeDataRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
CommerFeature.ClientRPC.RPCClient_TeamShowPetEffectRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function CommerFeature:OnTeamShowPreCreateProcessPetData()
  print(bWriteLog and "CommerFeature:OnTeamShowPreCreateProcessPetData")
  local PetFormDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Pet.PetFormDataUtil")
  local DataStrList = {}
  local EffectStrList = {}
  local UIDList = {}
  local SelfUID = self.Owner.UID
  table.insert(UIDList, SelfUID)
  local TeammatePlayerStateList = CGame:GetTeamMatePlayerStateList(self.Owner.PlayerKey, false)
  for _, TeammateState in pairs(TeammatePlayerStateList) do
    if slua.isValid(TeammateState) and TeammateState.UID and SelfUID ~= TeammateState.UID then
      table.insert(UIDList, TeammateState.UID)
    end
  end
  for _, UID in pairs(UIDList) do
    local EnlargePetIDList = {}
    local PetFormDataList = PetFormDataUtil:GetPetFormDataList(UID)
    if PetFormDataList and next(PetFormDataList) then
      for PetID, State in pairs(PetFormDataList) do
        if State then
          EnlargePetIDList[#EnlargePetIDList + 1] = PetID
        end
      end
    end
    DataStrList[#DataStrList + 1] = UID .. "_" .. table.concat(EnlargePetIDList, ",")
    local EffectItemID = PetFormDataUtil:GetPetEffectID(UID)
    EffectStrList[#EffectStrList + 1] = string.format("%s_%d", UID, EffectItemID)
  end
  if 0 < #DataStrList then
    print(bWriteLog and "CommerFeature:OnTeamShowPreCreateProcessPetData RPC")
    self:RPCClient_TeamShowPetEnlargeDataRsp(table.concat(DataStrList, "|"))
  end
  if 0 < #EffectStrList then
    print(bWriteLog and "CommerFeature:OnTeamShowPreCreateProcessPetData RPC effect str list")
    self:RPCClient_TeamShowPetEffectRsp(table.concat(EffectStrList, "|"))
  end
end
function CommerFeature:RPCClient_TeamShowPetEnlargeDataRsp(DataStr)
  print(bWriteLog and "CommerFeature:RPCClient_TeamShowPetEnlargeDataRsp", DataStr)
  if DataStr and DataStr ~= "" then
    local StringUtil = require("common.string_util")
    local DataStrList = StringUtil.Split(DataStr, "|")
    for _, v in pairs(DataStrList) do
      local OneDataList = StringUtil.Split(v, "_")
      if OneDataList then
        local UID = tonumber(OneDataList[1])
        local PetID2EnlargeState = {}
        local PetIDList = StringUtil.Split(OneDataList[2], ",")
        if PetIDList and next(PetIDList) then
          for _, vv in pairs(PetIDList) do
            local PetID = tonumber(vv)
            if PetID then
              PetID2EnlargeState[PetID] = true
            end
          end
        end
        self.TeamMemberPetID2EnlargeState[UID] = PetID2EnlargeState
      end
    end
  end
end
function CommerFeature:RPCClient_TeamShowPetEffectRsp(DataStr)
  print(bWriteLog and "CommerFeature:RPCClient_TeamShowPetEffectRsp", DataStr)
  if DataStr and DataStr ~= "" then
    local StringUtil = require("common.string_util")
    local DataStrList = StringUtil.Split(DataStr, "|")
    for _, v in pairs(DataStrList) do
      local OneDataList = StringUtil.Split(v, "_")
      if OneDataList then
        local UID = tonumber(OneDataList[1])
        local EffectItemID = tonumber(OneDataList[2]) or 0
        self.TeamMemberEffectItemMap[UID] = EffectItemID
      end
    end
  end
end
function CommerFeature:OnRep_MileStoneData(OldValue)
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  self.MileStoneMap = CommerAvatarDataUtil:ContructMileStoneData(self.MileStoneData)
end
CommerFeature.ServerRPC.RPCServer_AliasEnterBroadcastReq = {
  Reliable = true,
  Params = {}
}
CommerFeature.ClientRPC.RPCClient_AliasEnterBroadcastRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Int
  }
}
function CommerFeature:RPCServer_AliasEnterBroadcastReq()
  print(bWriteLog and "CommerFeature:RPCServer_AliasEnterBroadcastReq")
  local AliasDataUtil = require("GameLua.Activity.Commercialize.GamePlay.Alias.AliasDataUtil")
  local broadCastData = AliasDataUtil:FindBroadcastAliasInfo()
  self:RPCClient_AliasEnterBroadcastRsp(broadCastData.AliasID, broadCastData.XSuitID, broadCastData.PlayerName, broadCastData.value)
end
function CommerFeature:RPCClient_AliasEnterBroadcastRsp(AliasID, XSuitIconID, PlayerName, Value)
  log_format("CommerFeature:RPCClient_AliasEnterBroadcastRsp. AliasID=%s, XSuitIconID=%s, PlayerName=%s, Value=%s", AliasID, XSuitIconID, PlayerName, Value)
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_PLAYER_ALIAS_BROADCAST_RSP, AliasID, XSuitIconID, PlayerName, Value)
end
CommerFeature.ClientRPC.RPCClient_TeamShowMiniTvDataRsp = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function CommerFeature:OnTeaamShowPreCreateProcessMiniTvData()
  print(bWriteLog and "CommerFeature:OnTeaamShowPreCreateProcessMiniTvData")
  local MiniTVDataUtil = require("GameLua.Activity.Commercialize.GamePlay.MiniTV.MiniTVDataUtil")
  local DataStrList = {}
  local UIDList = {}
  local SelfUID = self.Owner.UID
  table.insert(UIDList, SelfUID)
  local TeammatePlayerStateList = CGame:GetTeamMatePlayerStateList(self.Owner.PlayerKey, false)
  for _, TeammateState in pairs(TeammatePlayerStateList) do
    if slua.isValid(TeammateState) and TeammateState.UID and SelfUID ~= TeammateState.UID then
      table.insert(UIDList, TeammateState.UID)
    end
  end
  for _, UID in pairs(UIDList) do
    local MiniTVDressID = MiniTVDataUtil:GetPlayerMiniTVDressID(UID)
    DataStrList[#DataStrList + 1] = UID .. "_" .. tostring(MiniTVDressID)
  end
  if 0 < #DataStrList then
    print(bWriteLog and "CommerFeature:GetPlayerMiniTVDressID RPC")
    self:RPCClient_TeamShowMiniTvDataRsp(table.concat(DataStrList, "|"))
  end
end
function CommerFeature:RPCClient_TeamShowMiniTvDataRsp(DataStr)
  print(bWriteLog and "CommerFeature:RPCClient_TeamShowMiniTvDataRsp", DataStr)
  if DataStr and DataStr ~= "" then
    local StringUtil = require("common.string_util")
    local DataStrList = StringUtil.Split(DataStr, "|")
    for _, v in pairs(DataStrList) do
      local OneDataList = StringUtil.Split(v, "_")
      if OneDataList then
        local UID = tonumber(OneDataList[1])
        local DressID = tonumber(OneDataList[2])
        self.TeamMemberMiniTvDressID[UID] = DressID
      end
    end
  end
end
local Class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCommerFeature = Class(CFeatureBase, nil, CommerFeature)
return CCommerFeature
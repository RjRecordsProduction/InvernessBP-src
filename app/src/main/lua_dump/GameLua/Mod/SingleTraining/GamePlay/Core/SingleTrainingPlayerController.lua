local SingleTrainingPlayerController = {
  ServerRPC = {},
  ClientRPC = {
    ClientRPC_ShowDamageNum = {
      Reliable = false,
      Params = {
        UEnums.EPropertyClass.Float,
        UEnums.EPropertyClass.Int8,
        import("Vector_NetQuantize"),
        import("/Script/Engine.Actor"),
        UEnums.EPropertyClass.Int
      }
    },
    ClientRPC_SpawnDeadBox = {
      Reliable = false,
      Params = {
        import("/Script/CoreUObject.Vector"),
        UEnums.EPropertyClass.Int
      }
    },
    ClientRPC_ShowStartTrainingFailTips = {
      Reliable = false,
      Params = {
        UEnums.EPropertyClass.Int8
      }
    }
  },
  MulticastRPC = {}
}
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
local ChanllengeConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.ChanllengeConfig")
local CDamageEvent = import("/Script/Engine.DamageEvent")
local AIConfig = require("GameLua.Mod.SingleTraining.DS.AI.Config.AIConfig")
function SingleTrainingPlayerController:ctor()
  self.TrainingMode = -1
  self.bHasRestoreWeapon = false
  self:ResetData()
end
function SingleTrainingPlayerController:ResetData()
  self.FootStepChanllengeCfgItem = nil
  self.GunChanllengeCfgItem = nil
  self.ChanllengeRound = -1
  self.AINum = 0
  self.TrainingType = -1
  self.FootstepsParam = ""
  self.GunParam = ""
  self.ChanllengeTimer = nil
  self.ChanllengeLevel = -1
  self.LandId = -1
end
function SingleTrainingPlayerController:_PostConstruct()
  SingleTrainingPlayerController.__super._PostConstruct(self)
end
function SingleTrainingPlayerController:ReceiveBeginPlay()
  SingleTrainingPlayerController.__super.ReceiveBeginPlay(self)
  if Client then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      print(bWriteLog and "SingleTrainingPlayerController:ReceiveBeginPlay", self.TrainingMode)
      self:AddControlEvent(uGameState, "OnClientGameRecovered", self.OnReconnected_Handle, self)
    end
  end
end
function SingleTrainingPlayerController:ReceiveEndPlay(EndPlayReason)
  SingleTrainingPlayerController.__super.ReceiveEndPlay(self, EndPlayReason)
end
function SingleTrainingPlayerController:GetLifetimeReplicatedProps()
  print(bWriteLog and "SingleTrainingPlayerController:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "TrainingMode",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "TrainingType",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "TrainingMaskId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.UInt16
    }
  }
  local BaseRepTable = SingleTrainingPlayerController.__super.GetLifetimeReplicatedProps(self) or {}
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function SingleTrainingPlayerController:SetStartNewTraining(nNewTrainingMode)
  if Client then
    return
  end
  if self:GetLandId() > 0 then
    print(bWriteLog and "SingleTrainingPlayerController:SetStartNewTraining self.TrainingMode: " .. tostring(self.TrainingMode) .. " TrainingModeID: " .. tostring(nNewTrainingMode))
    if 0 <= nNewTrainingMode then
      if 0 <= self.TrainingMode then
        self:InterruptPreTraining(self.TrainingMode)
      end
      self.TrainingMode = nNewTrainingMode
      EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_STATE_CHANGED, true, self.TrainingMode, self:GetLandId())
    end
  else
    print(bWriteLog and "SingleTrainingPlayerController:SetStartNewTraining self.LandId: " .. tostring(self.LandId))
  end
end
function SingleTrainingPlayerController:InterruptPreTraining(nCurrentTrainingMode)
  if self.TrainingMode >= 0 then
    print(bWriteLog and "SingleTrainingPlayerController:InterruptPreTraining TrainingMode: " .. tostring(nCurrentTrainingMode))
    if self.TrainingMode == SingleTrainingConfig.AITrainingMode.FootStepSound then
      self:RPC_Server_CloseAllSoundTraining()
    elseif self.TrainingMode == SingleTrainingConfig.AITrainingMode.GunSound then
      self:RPC_Server_CloseAllSoundTraining()
    end
  end
end
function SingleTrainingPlayerController:SetEndTraining(nCurrentTrainingMode, bClear)
  if Client then
    return
  end
  print(bWriteLog and "SingleTrainingPlayerController:SetEndTraining self.TrainingMode: " .. tostring(self.TrainingMode) .. " TrainingModeID: " .. tostring(nCurrentTrainingMode))
  if self:GetLandId() then
    if nCurrentTrainingMode ~= self.TrainingMode and not bClear then
      print(bWriteLog and "SingleTrainingPlayerController:SetEndTraining EndTraingingMode Error")
      return
    end
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_STATE_CHANGED, false, self.TrainingMode, self:GetLandId())
    self.TrainingMode = -1
  end
end
function SingleTrainingPlayerController:OnRep_TrainingMode()
  print(bWriteLog and "SingleTrainingPlayerController:OnRep_TrainingMode: " .. tostring(self.TrainingMode))
  if self.TrainingMode == SingleTrainingConfig.AITrainingMode.FootStepSound or self.TrainingMode == SingleTrainingConfig.AITrainingMode.GunSound then
    require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil").SetEnterTraning(true)
  else
    require("GameLua.Mod.SingleTraining.Client.Sound.SingleTrainSoundUtil").SetEnterTraning(false)
  end
  if self.TrainingMode == SingleTrainingConfig.AITrainingMode.ThrowBombTraining then
    if not self.BombLogicClient then
      self.BombLogicClient = require("GameLua.Mod.SingleTraining.Client.Bomb.singleTrainingThrowBombLogicClient")
    end
    self.BombLogicClient.OnDSEnterThrowBombTraining()
  elseif self.TrainingMode == SingleTrainingConfig.AITrainingMode.ShootTraining then
    if not self.ShootLogic then
      self.ShootLogic = require("GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic")
    end
    self.ShootLogic.OnDSEnterThrowShootTraining()
  end
end
function SingleTrainingPlayerController:OnRep_TrainingType()
  print(bWriteLog and "SingleTrainingPlayerController:OnRep_TrainingType: " .. tostring(self.TrainingType))
end
function SingleTrainingPlayerController:OnRep_TrainingMaskId()
  print(bWriteLog and "SingleTrainingPlayerController:OnRep_TrainingMaskId " .. tostring(self.TrainingMaskId))
  self:CheckCanShowTargetArrow()
end
function SingleTrainingPlayerController:SetTrainingMaskId(TrainingMaskId)
  if Client then
    return
  end
  print(bWriteLog and "SingleTrainingPlayerController:SetTrainingMaskId TrainingMaskId" .. tostring(TrainingMaskId))
  if TrainingMaskId and 0 <= TrainingMaskId then
    self.  end
end
function SingleTrainingPlayerController:CheckCanStartAISoundTraining(AITrainingMode)
  if self.TrainingMode >= 0 then
    return false
  end
  if AITrainingMode and 0 <= AITrainingMode and self.TrainingMaskId & 1 << AITrainingMode == 0 then
    return true
  end
  if Client then
    ShowNotice(LocUtil.GetLocalizeResStr(22014))
  end
  return false
end
function SingleTrainingPlayerController:CheckCanStartAIRoundTraining(bNotTips)
  if self.TrainingMaskId & 1 << SingleTrainingConfig.AITrainingMode.AIRoundTraining == 0 then
    return true
  end
  if Client and not bNotTips then
    ShowNotice(LocUtil.GetLocalizeResStr(22014))
  end
  return false
end
function SingleTrainingPlayerController:CheckCanStartBasicTraining(TrainingMode)
  if self.TrainingMode == SingleTrainingConfig.AITrainingMode.ThrowBombTraining or self.TrainingMode == SingleTrainingConfig.AITrainingMode.ShootTraining then
    return false
  end
  if self.TrainingMaskId & 1 << TrainingMode == 0 then
    return true
  end
  if Client then
    ShowNotice(LocUtil.GetLocalizeResStr(22014))
  end
  return false
end
function SingleTrainingPlayerController:CheckCanShowTargetArrow()
  if self:CheckExistSoundTraining() then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW_ARROW, -1, false, 3)
  else
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW_ARROW, -1, true, 3)
  end
end
function SingleTrainingPlayerController:CheckExistSoundTraining()
  if self.TrainingMaskId & 1 << SingleTrainingConfig.AITrainingMode.GunSound ~= 0 or self.TrainingMaskId & 1 << SingleTrainingConfig.AITrainingMode.FootStepSound ~= 0 then
    return true
  else
    return false
  end
end
function SingleTrainingPlayerController:OnReconnected_Handle()
  if Client and 0 == self.TrainingType and self.TrainingMode > -1 then
    print(bWriteLog and "SingleTrainingPlayerController:OnRep_TrainingType", self.TrainingMode)
    if not UIManager.IsUIShow(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn) then
      if 0 == self.TrainingMode then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn, 0)
      elseif 1 == self.TrainingMode then
        UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Btn, 1)
      end
    end
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      uGameState.bIsTraining = true
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_PanelFlow = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function SingleTrainingPlayerController:RPC_Server_PanelFlow(PanelID)
  print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_PanelFlow", PanelID)
  if NetUtil then
    local uPlayerCharacter = self:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      local nUID = Game:GetPlayerUID(uPlayerCharacter)
      local ReportInfo = {
        UID = nUID,
        IsExposure = 1,
        ClickPanelID = tonumber(PanelID),
        ClickTimeStamp = CGame:GetUnixTimestamp()
      }
      NetUtil.SendPacket("log_single_training_panel_flow", ReportInfo)
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_TeleportToTrainingModule = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function SingleTrainingPlayerController:RPC_Server_TeleportToTrainingModule(GroupId)
  print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_TeleportToSoundTrainning")
  self:TeleportToTrainingModule(GroupId)
end
function SingleTrainingPlayerController:TeleportToTrainingModule(GroupId)
  print(bWriteLog and "SingleTrainingPlayerController:TeleportToTrainingModule", GroupId)
  local STTeleportSubsystem = SubsystemMgr:Get("SingleTrainingTeleportSubsystem")
  if STTeleportSubsystem then
    local Pos, Rotation = STTeleportSubsystem:GetTrainningTeleportPosByGroupId(GroupId)
    local uCharacter = self:GetCurPlayerCharacter()
    if slua.isValid(uCharacter) and Pos and Pos:Size() > 0 then
      local uPlayerLoc = uCharacter:K2_GetActorLocation()
      local Offset = CGameMode:GetLandscapeOffset(uPlayerLoc)
      Pos = Pos + Offset
      Game:TeleportPawn(uCharacter, Pos, Rotation, false, nil)
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_FootstepTraining = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
function SingleTrainingPlayerController:RPC_Server_FootstepTraining(PosType, CircleType, ActionType, LandType, bIsShow, bIsTeamMate)
  if not self:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.FootStepSound) then
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_FootstepTraining CheckCanStartAISoundTraining false")
    self:ClientRPC_ShowStartTrainingFailTips(SingleTrainingConfig.AITrainingMode.FootStepSound)
    return
  end
  print(bWriteLog and string.format("RPC_Server_FootstepTraining %d %d %d %d %s %s", PosType, CircleType, ActionType, LandType, bIsShow, bIsTeamMate))
  self.PlayerState.bEnableAITraining = true
  self:SetStartNewTraining(SingleTrainingConfig.AITrainingMode.FootStepSound)
  self.TrainingType = 0
  self.FootstepsParam = string.format("%d-%d-%d-%d-%d-%d", LandType, PosType, CircleType, ActionType, bIsShow == true and 1 or 0, bIsTeamMate == true and 1 or 0)
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.StartTraining then
    uPlayerState:StartTraining()
  else
    print(bWriteLog and "RPC_Server_FootstepTraining uPlayerState error")
  end
  self:KillAllAI()
  if PosType == 6 then
    PosType = math.random(1, 5)
  end
  local PosKey = SingleTrainingConfig.StepSoundTrainingCfg.LocationId2Key[PosType]
  if PosKey == nil then
    return
  end
  local TrainingCfg = SingleTrainingConfig.StepSoundTrainingCfg[PosKey]
  if TrainingCfg then
    local CircleCfgKey = ""
    if CircleType == 1 then
      CircleCfgKey = "SingleCirculation"
    elseif CircleType == 2 then
      CircleCfgKey = "RepeatOnBothSides"
    elseif CircleType == 3 then
      CircleCfgKey = "AlternateLeftRight"
    end
    local CfgItem = {}
    local CircleCfg = TrainingCfg[CircleCfgKey]
    if CircleCfg and ActionType == 2 then
      CfgItem = self:RandomWithCondition(CircleCfg, 1, function(Item)
        if Item and Item.IsProne == true then
          return true
        else
          return false
        end
      end)[1]
    else
      local RemoveTeamId = bIsTeamMate == true and 0 or 1
      CfgItem = Game:RandomMultiFromTableWithCondition(CircleCfg, 1, function(Item)
        if Item and Item.BornTeamid == RemoveTeamId then
          return false
        end
        return true
      end)[1]
    end
    if CfgItem then
      local AIID = 33005
      local InTable = {
        TeamID = CfgItem.BornTeamid,
        MovementMode = ActionType - 1,
        TrainingMode = 0,
        WeaponType = nil,
        WeaponID = nil,
        ShootingPose = nil
      }
      if not SingleTrainingConfig.AITeamIdRange or not SingleTrainingConfig.AITeamIdRange.FootStepChanllenge then
        print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_FootstepTraining SingleTrainingConfig.AITeamIdRange is nil")
        return
      end
      InTable.TeamID = SingleTrainingConfig.AITeamIdRange.FootStepChanllenge + InTable.TeamID
      if bIsTeamMate then
        local uPlayerState = self:GetCurPlayerState()
        if slua.isValid(uPlayerState) then
          InTable.TeamID = uPlayerState.TeamID
        end
      end
      local BornPos = Game:RandomFromTable(CfgItem.BornPos, false)
      local uCharacter = self:GetCurPlayerCharacter()
      if slua.isValid(uCharacter) and CGameMode then
        local uPlayerLoc = uCharacter:K2_GetActorLocation()
        local BornOffset = CGameMode:GetLandscapeOffset(uPlayerLoc)
        BornPos = BornPos + BornOffset
        print(bWriteLog and "reng jie1", BornOffset.X, BornOffset.Y, BornOffset.Z)
        print(bWriteLog and "reng jie", BornPos.X, BornPos.Y, BornPos.Z)
        local uPawn = Game:CreateFakePlayer(InTable.TeamID, AIID, BornPos, FRotator(0, 0, 0), 1, false, 1, false)
        Game:AddItemByResID(uPawn, 101004, 1)
        Game:AddItemByResID(uPawn, 501006, 1)
        if Game:IsValid(uPawn) then
          print(bWriteLog and "SingleTrainingPlayerController CreateFakePlayer succeed 3")
          local uAIEnemyPlayerCharacter = self:GetPlayerCharacterSafety()
          if slua.isValid(uAIEnemyPlayerCharacter) then
            Game:SetAIBlackboardValue(uPawn, UEnums.EBlackBoardKeyType.Object, "TargetEnemyActor", uAIEnemyPlayerCharacter)
          end
          if uPawn.InitHearingTraningAI then
            uPawn:InitHearingTraningAI(InTable)
          end
          if uPawn.Indoor ~= nil and 2 <= PosType and PosType <= 4 then
            uPawn.Indoor = true
          end
          uPawn:SetOwnerPlayerKey(Game:GetPlayerKey(uCharacter))
          uPawn:SetShowFrame(bIsShow)
          local ASingleTrainingGameMode = import("SingleTrainingGameMode")
          if ASingleTrainingGameMode and Game:IsClassOf(CGameMode, ASingleTrainingGameMode) then
            CGameMode:HandleNavigationInfo(uPawn:GetController())
          end
        end
      end
    else
      print(bWriteLog and "RPC_Server_FootstepTraining CfgItem is nil!")
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_GunSoundTraining = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Bool
  }
}
function SingleTrainingPlayerController:RPC_Server_GunSoundTraining(DistanceType, DirectionType, ActionType, GunType, bIsShow)
  print(bWriteLog and string.format("RPC_Server_GunSoundTraining %d %d %d %d %s", DistanceType, DirectionType, GunType, ActionType, bIsShow))
  if not self:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.GunSound) then
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_GunSoundTraining CheckCanStartAISoundTraining false")
    self:ClientRPC_ShowStartTrainingFailTips(SingleTrainingConfig.AITrainingMode.GunSound)
    return
  end
  self.PlayerState.bEnableAITraining = true
  self:SetStartNewTraining(SingleTrainingConfig.AITrainingMode.GunSound)
  self.TrainingType = 0
  self.GunParam = string.format("%d-%d-%d-%d-%d", DistanceType, DirectionType, ActionType, GunType, bIsShow == true and 1 or 0)
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) and uPlayerState.StartTraining then
    uPlayerState:StartTraining()
  else
    print(bWriteLog and "RPC_Server_GunSoundTraining uPlayerState error")
  end
  self:KillAllAI()
  local CfgKey = SingleTrainingConfig.GunSoundTrainingCfg.DirectionId2Key[DirectionType]
  if CfgKey then
    local CfgItem = SingleTrainingConfig.GunSoundTrainingCfg[CfgKey]
    if CfgItem then
      local BornPoints = CfgItem[DistanceType]
      if BornPoints then
        local BornPoint = Game:RandomFromTable(BornPoints, false)
        local uCharacter = self:GetCurPlayerCharacter()
        if slua.isValid(uCharacter) then
          local uPlayerLoc = uCharacter:K2_GetActorLocation()
          local BornOffset = CGameMode:GetLandscapeOffset(uPlayerLoc)
          BornPoint = BornPoint + BornOffset
        else
          print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_GunSoundTraining uCharacter is invalid")
          return
        end
        local AIID = 33005
        local InTable = {
          TeamID = nil,
          MovementMode = ActionType,
          TrainingMode = 1,
          WeaponType = GunType,
          WeaponID = nil,
          ShootingPose = ActionType - 1
        }
        if not SingleTrainingConfig.AITeamIdRange or not SingleTrainingConfig.AITeamIdRange.GunTraining then
          print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_GunSoundTraining SingleTrainingConfig.AITeamIdRange is nil")
          return
        end
        local uPawn = Game:CreateFakePlayer(SingleTrainingConfig.AITeamIdRange.GunTraining, AIID, BornPoint, FRotator(0, 0, 0), 1, false, 1, false)
        local CfgGunKey = {}
        CfgGunKey = SingleTrainingConfig.FakerPlayerWeaponCfg[InTable.WeaponType]
        if CfgGunKey then
          local GunIndex = math.random(1, 4)
          local GunId = CfgGunKey[GunIndex]
          Game:AddItemByResID(uPawn, GunId, 1)
        end
        if Game:IsValid(uPawn) then
          print(bWriteLog and "SingleTrainingPlayerController CreateFakePlayer succeed 4")
          local uAIEnemyPlayerCharacter = self:GetPlayerCharacterSafety()
          if slua.isValid(uAIEnemyPlayerCharacter) then
            Game:SetAIBlackboardValue(uPawn, UEnums.EBlackBoardKeyType.Object, "TargetEnemyActor", uAIEnemyPlayerCharacter)
          end
          if uPawn.InitHearingTraningAI then
            uPawn:InitHearingTraningAI(InTable)
          end
          uPawn:SetOwnerPlayerKey(Game:GetPlayerKey(uCharacter))
          uPawn:SetShowFrame(bIsShow)
          local ASingleTrainingGameMode = import("SingleTrainingGameMode")
          if ASingleTrainingGameMode and CGameMode and Game:IsClassOf(CGameMode, ASingleTrainingGameMode) then
            CGameMode:HandleNavigationInfo(uPawn:GetController())
          end
        end
      end
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_PreFootstepChallenge = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Server_PreFootstepChallenge(Level)
  self:KillAllAI()
  local uPlayerState = self:GetCurPlayerState()
  uPlayerState.Cur  local LandType = math.random(0, 7)
  if 0 <= self:GetLandId() then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_CHANGE_FLOOR_MAT, LandType, self:GetLandId())
  else
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_PreFootstepChallenge GetLandId < 0")
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_FootstepChallenge = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Server_FootstepChallenge(Level)
  if not self:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.FootStepSound) then
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_FootstepChallenge CheckCanStartAISoundTraining false")
    self:ClientRPC_ShowStartTrainingFailTips(SingleTrainingConfig.AITrainingMode.FootStepSound)
    return
  end
  self:KillAllAI()
  self.PlayerState.bEnableAITraining = true
  self:SetStartNewTraining(SingleTrainingConfig.AITrainingMode.FootStepSound)
  self.TrainingType = 1
  self.Chanllenge  print(bWriteLog and string.format("RPC_Server_FootstepChallenge " .. tostring(Level)))
  local CfgKey = ChanllengeConfig.StepSoundChallengeCfg.Level2Key[Level]
  if CfgKey then
    local CfgItem = ChanllengeConfig.StepSoundChallengeCfg[CfgKey]
    if CfgItem then
      self.FootStepChanllenge      local uPlayerState = self:GetCurPlayerState()
      if slua.isValid(uPlayerState) and self.FootStepChanllengeCfgItem then
        uPlayerState:StartFootStepChanllenge(self.FootStepChanllengeCfgItem.BattleTime)
      end
      self.ChanllengeRound = 1
      local BornCfg = self.FootStepChanllengeCfgItem.AIBornPos[self.ChanllengeRound]
      if BornCfg then
        self.AINum = BornCfg.TraningAIAction_Count
      end
      self:StartFootstepChanllenge(self.ChanllengeRound, self.AINum)
      self.ChanllengeTimer = self:AddGameTimer(1, true, function()
        if self:CheckBattleFinished() then
          self:MakeReportRoundFlow(false)
          self:ChanllengeFinished(false)
        end
      end)
    end
  end
end
function SingleTrainingPlayerController:StartFootstepChanllenge(Round, AINum)
  print(bWriteLog and "SingleTrainingPlayerController:StartFootstepChanllenge", Round)
  if Round <= 0 then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local GameState = UGameplayStatics.GetGameState(CGameMode)
  if slua.isValid(GameState) and self.FootStepChanllengeCfgItem then
    self.Chanllenge    local ExcludeFloorIndex = {}
    for i = 1, AINum do
      local MoveMode = Game:RandomByWeight(self.FootStepChanllengeCfgItem.TraningAIAction_Move, 1)[1]
      local AIID = 33005
      local InTable = {
        TeamID = nil,
        MovementMode = MoveMode,
        TrainingMode = 0
      }
      local TeamId, BornPoint, FloorIndex = self:GetFootStepChanllengeAIBornCfg(ExcludeFloorIndex)
      table.insert(ExcludeFloorIndex, FloorIndex)
      BornPoint = self:GetAIBornPoint(BornPoint)
      if not SingleTrainingConfig.AITeamIdRange or not SingleTrainingConfig.AITeamIdRange.FootStepChanllenge then
        print(bWriteLog and "SingleTrainingPlayerController:StartFootstepChanllenge SingleTrainingConfig.FootStepChanllenge is nil")
        return
      end
      InTable.TeamID = SingleTrainingConfig.AITeamIdRange.FootStepChanllenge + TeamId
      local uPawn = Game:CreateFakePlayer(InTable.TeamID, AIID, BornPoint, FRotator(0, 0, 0), 1, false, 1, false)
      Game:AddItemByResID(uPawn, 101004, 1)
      Game:AddItemByResID(uPawn, 501006, 1)
      if Game:IsValid(uPawn) then
        print(bWriteLog and "SingleTrainingPlayerController CreateFakePlayer succeed 1")
        local uAIEnemyPlayerCharacter = self:GetPlayerCharacterSafety()
        if slua.isValid(uAIEnemyPlayerCharacter) then
          Game:SetAIBlackboardValue(uPawn, UEnums.EBlackBoardKeyType.Object, "TargetEnemyActor", uAIEnemyPlayerCharacter)
        end
        if uPawn.InitHearingTraningAI then
          uPawn:InitHearingTraningAI(InTable)
        end
        if 2 <= FloorIndex and FloorIndex <= 4 and uPawn.Indoor ~= nil then
          uPawn.Indoor = true
        end
        local uPlayerCharacter = self:GetCurPlayerCharacter()
        if slua.isValid(uPlayerCharacter) then
          uPawn:SetOwnerPlayerKey(Game:GetPlayerKey(uPlayerCharacter))
        else
          print(bWriteLog and "SingleTrainingPlayerController:StartFootstepChanllenge uPlayerCharacter invalid")
        end
        local ASingleTrainingGameMode = import("SingleTrainingGameMode")
        if ASingleTrainingGameMode and CGameMode and Game:IsClassOf(CGameMode, ASingleTrainingGameMode) then
          CGameMode:HandleNavigationInfo(uPawn:GetController())
        end
      else
        print(bWriteLog and "SingleTrainingPlayerController:StartFootstepChanllenge Create Fake Player failed")
      end
    end
  end
end
function SingleTrainingPlayerController:GetFootStepChanllengeAIBornCfg(ExcludeFloorIndex)
  if self.FootStepChanllengeCfgItem then
    local BornCfg = self.FootStepChanllengeCfgItem.AIBornPos[self.ChanllengeRound]
    if BornCfg then
      local FloorIndex = self:RandomWithCondition(BornCfg.Pos, 1, function(Item)
        local InTable = Game:IsContainInTable(ExcludeFloorIndex, Item)
        return not InTable
      end)[1]
      local CfgKey = ChanllengeConfig.LocationId2Key[FloorIndex]
      if CfgKey then
        local Cfg = ChanllengeConfig[CfgKey]
        if Cfg then
          local CfgItem = Game:RandomFromTable(Cfg)
          if CfgItem then
            local TeamId = CfgItem.BornTeamid
            local BornPoint = Game:RandomFromTable(CfgItem.BornPos)
            return TeamId, BornPoint, FloorIndex
          end
        end
      end
    end
  end
  print(bWriteLog and "SingleTrainingPlayerController:GetFootStepChanllengeAIBornPos error")
  return 2, FVector(0, 0, 0), 1
end
function SingleTrainingPlayerController:GetAIBornPoint(BornPos)
  local BornPoint = BornPos
  local uCharacter = self:GetCurPlayerCharacter()
  if slua.isValid(uCharacter) then
    local uPlayerLoc = uCharacter:K2_GetActorLocation()
    local BornOffset = CGameMode:GetLandscapeOffset(uPlayerLoc)
    BornPoint = BornPoint + BornOffset
  else
    print(bWriteLog and "SingleTrainingPlayerController:GetAIBornPoint uCharacter is invalid")
  end
  return BornPoint
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_GunSoundChallenge = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Server_GunSoundChallenge(Level)
  print(bWriteLog and string.format("RPC_Server_GunSoundChallenge " .. tostring(Level)))
  if not self:CheckCanStartAISoundTraining(SingleTrainingConfig.AITrainingMode.GunSound) then
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_GunSoundChallenge CheckCanStartAISoundTraining false")
    self:ClientRPC_ShowStartTrainingFailTips(SingleTrainingConfig.AITrainingMode.GunSound)
    return
  end
  self:KillAllAI()
  self.Chanllenge  self:SetStartNewTraining(SingleTrainingConfig.AITrainingMode.GunSound)
  self.TrainingType = 1
  self.PlayerState.bEnableAITraining = true
  local CfgKey = ChanllengeConfig.GunSoundChallengeCfg.Level2Key[Level]
  if CfgKey then
    local CfgItem = ChanllengeConfig.GunSoundChallengeCfg[CfgKey]
    if CfgItem then
      self.GunChanllenge      local UGameplayStatics = import("GameplayStatics")
      local uPlayerState = self:GetCurPlayerState()
      if slua.isValid(uPlayerState) and self.GunChanllengeCfgItem and uPlayerState.StartGunChanllenge then
        uPlayerState:StartGunChanllenge(self.GunChanllengeCfgItem.BattleTime)
      end
      self.ChanllengeRound = 1
      self:StartGunChanllenge(self.ChanllengeRound)
      self.ChanllengeTimer = self:AddGameTimer(1, true, function()
        if self:CheckBattleFinished() then
          self:MakeReportRoundFlow(false)
          self:ChanllengeFinished(false)
        end
      end)
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_PreGunSoundChallenge = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Server_PreGunSoundChallenge(Level)
  print(bWriteLog and string.format("RPC_Server_PreGunSoundChallenge " .. tostring(Level)))
  self:KillAllAI()
  self:TeleportToTrainingModule(SingleTrainingConfig.GunChanllengeGroupId)
  local uPlayerState = self:GetCurPlayerState()
  uPlayerState.Curend
function SingleTrainingPlayerController:StartGunChanllenge(Round)
  print(bWriteLog and "SingleTrainingPlayerController:StartGunChanllenge", Round)
  self:KillAllAI()
  local BornCfg = self.GunChanllengeCfgItem.AIBornPos[self.ChanllengeRound]
  if BornCfg then
    local GroupId = Game:RandomByWeight(BornCfg.GetRandomAIPos, 1)[1]
    local STTeleportSubsystem = SubsystemMgr:Get("ChanllengeSubsystem")
    if STTeleportSubsystem then
      local GroupPoint = STTeleportSubsystem:GetChanllengeAIBornPointsByGroupId(GroupId)
      print(bWriteLog and "SingleTrainingPlayerController:StartGunChanllenge GroupId", GroupId)
      local WeaponKey = Game:RandomByWeight(self.GunChanllengeCfgItem.TraningAIWeapon, 1)[1]
      local WeaponPoor = SingleTrainingConfig.FakerPlayerWeaponCfg[WeaponKey]
      local ShootingAICount = tonumber(BornCfg.RealFireAICount)
      if GroupPoint then
        local BornPos = self:GetAIBornPoint(GroupPoint.Pos)
        local BornRotation = GroupPoint.Rotation
        local WeaponId = -1
        if WeaponPoor then
          WeaponId = Game:RandomFromTable(WeaponPoor)
        end
        local ShootingPose = Game:RandomByWeight(self.GunChanllengeCfgItem.TraningAIAction_FireGun, 1)[1]
        if 0 < ShootingAICount then
          ShootingAICount = ShootingAICount - 1
        else
          ShootingPose = 3
        end
        self:SpawnGunChanllengeAI(BornPos, BornRotation, WeaponId, ShootingPose)
      else
        print(bWriteLog and "SingleTrainingPlayerController:StartGunChanllenge GroupPoint is nil!")
      end
    end
  end
end
function SingleTrainingPlayerController:SpawnGunChanllengeAI(BornLocation, BornRotation, WeaponId, ShootingPose)
  print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI")
  if BornLocation == nil or BornRotation == nil then
    print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI failed")
    return
  end
  local AIID = 33005
  local InTable = {
    WeaponID = WeaponId,
    ShootingPose = ShootingPose,
    TrainingMode = 1,
    ShootingCD = self.GunChanllengeCfgItem.TraningAIShootingCD,
    ShootingInterval = self.GunChanllengeCfgItem.TraningAIShootingInterval
  }
  print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI", WeaponId, ShootingPose)
  if not SingleTrainingConfig.AITeamIdRange or not SingleTrainingConfig.AITeamIdRange.GunTraining then
    print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI SingleTrainingConfig.AITeamIdRange is nil")
    return
  end
  InTable.TeamID = SingleTrainingConfig.AITeamIdRange.GunTraining
  local uPawn = Game:CreateFakePlayer(InTable.TeamID, AIID, BornLocation, BornRotation, 1, false, 1, false)
  if Game:IsValid(uPawn) then
    print(bWriteLog and "SingleTrainingPlayerController CreateFakePlayer succeed 2")
    local uAIEnemyPlayerCharacter = self:GetPlayerCharacterSafety()
    if slua.isValid(uAIEnemyPlayerCharacter) then
      Game:SetAIBlackboardValue(uPawn, UEnums.EBlackBoardKeyType.Object, "TargetEnemyActor", uAIEnemyPlayerCharacter)
    end
    if uPawn.InitHearingTraningAI then
      uPawn:InitHearingTraningAI(InTable)
      uPawn:SetShootingPose(ShootingPose)
    end
    local uPlayerCharacter = self:GetCurPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      uPawn:SetOwnerPlayerKey(Game:GetPlayerKey(uPlayerCharacter))
    else
      print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI uPlayerCharacter invalid")
    end
    local ASingleTrainingGameMode = import("SingleTrainingGameMode")
    if ASingleTrainingGameMode and CGameMode and Game:IsClassOf(CGameMode, ASingleTrainingGameMode) then
      CGameMode:HandleNavigationInfo(uPawn:GetController())
    end
  else
    print(bWriteLog and "SingleTrainingPlayerController:SpawnGunChanllengeAI Create Fake Player failed")
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_CloseAllSoundTraining = {Reliable = true}
function SingleTrainingPlayerController:RPC_Server_CloseAllSoundTraining()
  print(bWriteLog and "RPC_Server_CloseAllSoundTraining")
  self:MakeReportRoundFlow(true)
  self:ChanllengeFinished(true)
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_ChangeLand = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Server_ChangeLand(LandType)
  if LandType == 8 then
    LandType = math.random(0, 7)
  end
  if 0 <= self:GetLandId() then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAIN, EVENTID_SINGLE_TRAIN_CHANGE_FLOOR_MAT, LandType, self:GetLandId())
  else
    print(bWriteLog and "SingleTrainingPlayerController:RPC_Server_ChangeLand LandId < 0")
  end
end
SingleTrainingPlayerController.ClientRPC.RPC_Client_SoundTrainAddSorce = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float
  }
}
function SingleTrainingPlayerController:RPC_Client_SoundTrainAddSorce(AddSorceNum, AddTime, X, Y, Z)
  print(bWriteLog and "SingleTrainingPlayerController:RPC_Client_SoundTrainAddSorce", AddSorceNum, AddTime, X, Y, Z)
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTrain_Sound_FlyNumManager, AddSorceNum, AddTime, X, Y, Z)
end
function SingleTrainingPlayerController:KillAllAI()
  print(bWriteLog and "SingleTrainingPlayerController:KillAllAI")
  if CGameMode then
    local uPlayerCharacter = self:GetCurPlayerCharacter()
    local AllPlayerPawns = Game:GetAllPlayerPawns()
    if slua.isValid(uPlayerCharacter) and AllPlayerPawns:Num() > 0 then
      local CurPlayerKey = Game:GetPlayerKey(uPlayerCharacter)
      local PlayerNums = AllPlayerPawns:Num()
      print(bWriteLog and "SingleTrainingPlayerController:KillAllAI Num", PlayerNums)
      for index = 0, PlayerNums - 1 do
        local uLocalPlayer = AllPlayerPawns:Get(index)
        if slua.isValid(uLocalPlayer) and Game:IsAI(uLocalPlayer) then
          if uLocalPlayer.GetOwnerPlayerKey then
            if uLocalPlayer:GetOwnerPlayerKey() == CurPlayerKey then
              local uPlayerState = uLocalPlayer:GetPlayerStateSafety()
              if slua.isValid(uPlayerState) then
                uPlayerState.bEnableAITraining = true
              end
              if not uLocalPlayer.bDead then
                local uAIController = uLocalPlayer:GetController()
                uLocalPlayer:K2_DestroyActor()
                if slua.isValid(uAIController) then
                  Game:DestroyAIController(uAIController)
                end
              end
            end
          else
            print(bWriteLog and "SingleTrainingPlayerController:KillAllAI GetOwnerPlayerKey is nil")
          end
        end
      end
    else
      print(bWriteLog and "SingleTrainingPlayerController:KillAllAI no AI")
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_ShowVoice = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
function SingleTrainingPlayerController:RPC_Server_ShowVoice(bIsShow)
  print(bWriteLog and "RPC_Server_ShowVoice " .. tostring(bIsShow))
  if CGameMode then
    local AllPlayerPawns = Game:GetAllPlayerPawns()
    if AllPlayerPawns:Num() > 0 then
      local uPlayerCharacter = self:GetCurPlayerCharacter()
      if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
        local CurPlayerKey = Game:GetPlayerKey(uPlayerCharacter)
        local PlayerNums = AllPlayerPawns:Num()
        for index = 0, PlayerNums - 1 do
          local uPawn = AllPlayerPawns:Get(index)
          if slua.isValid(uPawn) and Game:IsAI(uPawn) and uPawn.GetOwnerPlayerKey and uPawn:GetOwnerPlayerKey() == CurPlayerKey then
            uPawn:SetShowFrame(bIsShow)
          end
        end
      end
    end
  end
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_VoiceIsTeammate = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
function SingleTrainingPlayerController:RPC_Server_VoiceIsTeammate(bIsTeammate)
  print(bWriteLog and "RPC_Server_VoiceIsTeammate " .. tostring(bIsTeammate))
end
function SingleTrainingPlayerController:ChanllengeKillOneAI(Pawn)
  print(bWriteLog and "SingleTrainingPlayerController:ChanllengeKillOneAI")
  if self.TrainingMode == 0 then
    if self.TrainingType == 0 then
      self:RPC_Client_FinishTraining(self.TrainingMode)
      self:SetEndTraining(self.TrainingMode)
      self:ResetData()
    elseif self.TrainingType == 1 then
      self:FootStepChanllengeKillOneAI(Pawn)
    end
  elseif self.TrainingMode == 1 then
    if self.TrainingType == 0 then
      self:RPC_Client_FinishTraining(self.TrainingMode)
      self:SetEndTraining(self.TrainingMode)
      self:ResetData()
    elseif self.TrainingType == 1 then
      self:GunChanllengeKillOneAI(Pawn)
    end
  end
end
SingleTrainingPlayerController.ClientRPC.RPC_Client_FinishTraining = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Client_FinishTraining(TrainingType)
  if TrainingType == 0 then
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
  else
    UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
  end
end
function SingleTrainingPlayerController:FootStepChanllengeKillOneAI(Pawn)
  local Position = Pawn:K2_GetActorLocation()
  local RewardScore = self.FootStepChanllengeCfgItem.BattleReward[1]
  local RewardBattleTime = self.FootStepChanllengeCfgItem.BattleReward[2]
  self:AddScore(RewardScore)
  self:AddBattleTime(RewardBattleTime)
  self:RPC_Client_SoundTrainAddSorce(RewardScore, RewardBattleTime, Position.X, Position.Y, Position.Z)
  self.AINum = self.AINum - 1
  if self.AINum <= 0 then
    self.ChanllengeRound = self.ChanllengeRound + 1
    local BornCfg = self.FootStepChanllengeCfgItem.AIBornPos[self.ChanllengeRound]
    if not BornCfg then
      local Round = math.random(1, #self.FootStepChanllengeCfgItem.AIBornPos)
      self.Chanllenge      BornCfg = self.FootStepChanllengeCfgItem.AIBornPos[self.ChanllengeRound]
      if BornCfg then
        self.AINum = BornCfg.TraningAIAction_Count
      end
    else
      self.AINum = BornCfg.TraningAIAction_Count
    end
    self:StartFootstepChanllenge(self.ChanllengeRound, self.AINum)
  end
end
function SingleTrainingPlayerController:GunChanllengeKillOneAI(Pawn)
  local Position = Pawn:K2_GetActorLocation()
  local bIsAddScore = Game:GetAIBlackboardValue(Pawn, UEnums.EBlackBoardKeyType.Int, "CustomShootingPose") ~= 3
  if bIsAddScore then
    local RewardScore = self.GunChanllengeCfgItem.BattleReward[1]
    local RewardBattleTime = self.GunChanllengeCfgItem.BattleReward[2]
    self:AddScore(RewardScore)
    self:AddBattleTime(RewardBattleTime)
    self:RPC_Client_SoundTrainAddSorce(RewardScore, RewardBattleTime, Position.X, Position.Y, Position.Z)
  else
    self:RPC_Client_PlayUISound(0)
  end
  self.ChanllengeRound = self.ChanllengeRound + 1
  if self.GunChanllengeCfgItem.AIBornPos[self.ChanllengeRound] == nil then
    local Round = math.random(1, #self.GunChanllengeCfgItem.AIBornPos)
    self.Chanllenge  end
  self:StartGunChanllenge(self.ChanllengeRound)
end
SingleTrainingPlayerController.ClientRPC.RPC_Client_PlayUISound = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function SingleTrainingPlayerController:RPC_Client_PlayUISound(SoundID)
  if SoundID == 0 then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio("/Game/Mod/SingleTraining/WwiseEvent/UI_Training_210/Play_UI_Training_Warning.Play_UI_Training_Warning")
  else
    error("SingleTrainingPlayerController:RPC_Client_PlayUISound have no " .. tostring(SoundID))
  end
end
function SingleTrainingPlayerController:AddScore(Score)
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) then
    if self.TrainingType == 0 then
      uPlayerState:AddFootStepScore(tonumber(Score))
    elseif self.TrainingType == 1 then
      uPlayerState:AddGunScore(tonumber(Score))
    end
  end
end
function SingleTrainingPlayerController:AddBattleTime(RewardBattleTime)
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) then
    if self.TrainingType == 0 then
      uPlayerState:AddFootStepBattleTime(tonumber(RewardBattleTime))
    elseif self.TrainingType == 1 then
      uPlayerState:AddGunBattleTime(tonumber(RewardBattleTime))
    end
  end
end
function SingleTrainingPlayerController:CheckBattleFinished()
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) then
    local CurrentTime = CGameState:GetServerWorldTimeSeconds()
    local ChanllengeStartTime = uPlayerState:GetChanllengeStartTime()
    local LeftTime = ChanllengeStartTime + uPlayerState:GetBattleTime() - CurrentTime
    if LeftTime <= 0 then
      return true
    else
      return false
    end
  end
  return true
end
function SingleTrainingPlayerController:ChanllengeFinished(bIsCancel, bIsDontSendClientRpc)
  print(bWriteLog and "SingleTrainingPlayerController:ChanllengeFinished")
  self:KillAllAI()
  self.PlayerState.bEnableAITraining = false
  if self.ChanllengeTimer ~= nil then
    self:RemoveGameTimer(self.ChanllengeTimer)
  end
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) then
    if uPlayerState.ChanllengeStartTime ~= 0 and not bIsDontSendClientRpc then
      self:RPC_Client_ChanllengeFinish(self.TrainingMode, bIsCancel, uPlayerState.BattleScore, uPlayerState.CurLevel)
    end
    if uPlayerState.ResetData then
      uPlayerState:ResetData()
    end
  end
  self:SetEndTraining(self.TrainingMode)
  self:ResetData()
end
function SingleTrainingPlayerController:MakeReportRoundFlow(bIsCancel)
  print(bWriteLog and "SingleTrainingPlayerController:MakeReportRoundFlow", bIsCancel)
  local uPlayerState = self:GetCurPlayerState()
  if slua.isValid(uPlayerState) then
    if self.TrainingMode == -1 or self.TrainingType == -1 then
      print(bWriteLog and "SingleTrainingPlayerController:MakeReportRoundFlow TrainingMode == -1 or TrainingType == -1", bIsCancel)
      return
    end
    local TrainingRoundFlowSubsystem = SubsystemMgr:Get("TrainingRoundFlowSubsystem")
    if TrainingRoundFlowSubsystem then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local RoundTime = 0
      if uPlayerState.GetTrainingStartTime then
        if self.TrainingType == 0 then
          RoundTime = GamePlayTools.GetServerWorldTimeSeconds() - uPlayerState:GetTrainingStartTime()
        elseif self.TrainingType == 1 then
          RoundTime = GamePlayTools.GetServerWorldTimeSeconds() - uPlayerState:GetChanllengeStartTime()
        end
      end
      local TrainMode = self.TrainingMode
      local TrainType = self.TrainingType
      local FootstepsParam = self.FootstepsParam
      local GunParam = self.GunParam
      local ChanllengeLevel = self.ChanllengeLevel
      local ChanllengeScore = uPlayerState:GetScore()
      local EscapeCheckUp = bIsCancel == true and 1 or 0
      TrainingRoundFlowSubsystem:MakeFlow(uPlayerState:GetPlayerKey(), RoundTime, TrainMode, TrainType, FootstepsParam, GunParam, ChanllengeLevel, ChanllengeScore, EscapeCheckUp)
    end
  end
end
SingleTrainingPlayerController.ClientRPC.RPC_Client_ChanllengeFinish = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int16,
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int16
  }
}
function SingleTrainingPlayerController:RPC_Client_ChanllengeFinish(ChanllengeMode, bIsCancel, Score, Level)
  if slua.isValid(CGameState) then
    CGameState.STDeadBoxClientShowFeature:CleanAIDeadBox()
  end
  print(bWriteLog and "SingleTrainingPlayerController:RPC_Client_ChanllengeFinish", ChanllengeMode, bIsCancel, Score, Level)
  if not bIsCancel then
    if ChanllengeMode == 0 then
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
      local SingleTraining_Sound_Footsteps = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Footsteps)
      if SingleTraining_Sound_Footsteps then
        SingleTraining_Sound_Footsteps:SetEnterChanllenge(false)
      end
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
      local SingleTraining_Sound_Gun = UIManager.GetUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Gun)
      if SingleTraining_Sound_Gun then
        SingleTraining_Sound_Gun:SetEnterChanllenge(false)
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config_InGame.SingleTraining_Sound_Score, ChanllengeMode, Score, Level)
end
SingleTrainingPlayerController.ServerRPC.RPC_Server_AddWeapon = {Reliable = true}
local CheckWeaponIDValid = function(WeaponID)
  if WeaponID <= 0 then
    return false
  end
  return true
end
function SingleTrainingPlayerController:RPC_Server_AddWeapon()
  local uPlayerCharacter = self:GetCurPawn()
  if slua.isValid(uPlayerCharacter) then
    local WeaponList = Game:GetEquipWeaponList(uPlayerCharacter)
    if WeaponList and WeaponList:Num() == 0 or not CheckWeaponIDValid(WeaponList:Get(0)) then
      Game:AddItemByResID(uPlayerCharacter, 501006, 1)
      Game:AddItemByResID(uPlayerCharacter, 203004, 1)
      Game:AddItemByResID(uPlayerCharacter, 201009, 1)
      Game:AddItemByResID(uPlayerCharacter, 202002, 1)
      Game:AddItemByResID(uPlayerCharacter, 204013, 1)
      Game:AddItemByResID(uPlayerCharacter, 205002, 1)
      Game:AddItemByResID(uPlayerCharacter, 101004, 1)
      Game:AddItemByResID(uPlayerCharacter, 303001, 140)
      Game:AddItemByResID(uPlayerCharacter, 303001, 140)
    end
  end
end
function SingleTrainingPlayerController:RandomWithCondition(tTable, nCount, Condition)
  Game:Shuffle(tTable)
  local tTemp = {}
  for index, value in ipairs(tTable) do
    tTemp[index] = value
  end
  local tResult = {}
  local nSucceedCount = 0
  local TotalCount = #tTable
  for i = 1, TotalCount do
    if Condition(tTemp[i]) then
      tResult[#tResult + 1] = tTemp[i]
      tTemp[i] = tTemp[#tTemp]
      tTemp[#tTemp] = nil
      nSucceedCount = nSucceedCount + 1
    end
    if nSucceedCount == nCount then
      break
    end
  end
  return tResult
end
function SingleTrainingPlayerController:GetLandId()
  if self.LandId == -1 then
    local uPlayerCharacter = self:GetCurPlayerCharacter()
    if slua.isValid(uPlayerCharacter) then
      local PlayerLocation = uPlayerCharacter:K2_GetActorLocation()
      self.LandId = CGameMode:GetLandscapeId(PlayerLocation)
    end
  end
  return self.LandId
end
function SingleTrainingPlayerController:GetAllEquipWeaponData()
  print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData")
  local WeaponAndAttachment = {}
  local uPlayerPawn = self:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerPawn) then
    local uWeaponManager = uPlayerPawn:GetWeaponManager()
    if slua.isValid(uWeaponManager) then
      local WeaponList = uWeaponManager:GetAllInventoryWeaponList(false)
      print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData Count", WeaponList:Num())
      for i = 0, WeaponList:Num() - 1 do
        local uCurWeapon = WeaponList:Get(i)
        if slua.isValid(uCurWeapon) then
          local DefineID = uCurWeapon:GetItemDefineID()
          if DefineID then
            print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData weapon", DefineID.TypeSpecificID)
            table.insert(WeaponAndAttachment, DefineID.TypeSpecificID)
          end
          if uCurWeapon.AttachedAttachmentID and uCurWeapon.DefaultAttachedAttachmentID then
            print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData attachment Count", uCurWeapon.AttachedAttachmentID:Num())
            local TableUtil = require("common.table_util")
            for j = 0, uCurWeapon.AttachedAttachmentID:Num() - 1 do
              if not TableUtil.IsInTable(uCurWeapon.DefaultAttachedAttachmentID, uCurWeapon.AttachedAttachmentID:Get(j)) then
                table.insert(WeaponAndAttachment, uCurWeapon.AttachedAttachmentID:Get(j))
                print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData attachment add", uCurWeapon.AttachedAttachmentID:Get(j))
              end
            end
          end
        end
      end
    end
  end
  print(bWriteLog and "SingleTrainingPlayerController:GetAllEquipWeaponData Total count", #WeaponAndAttachment)
  return WeaponAndAttachment
end
function SingleTrainingPlayerController:HasWeaponEquip()
  local uPlayerPawn = self:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerPawn) then
    local uWeaponManager = uPlayerPawn:GetWeaponManager()
    if slua.isValid(uWeaponManager) then
      local WeaponList = uWeaponManager:GetAllInventoryWeaponList(false)
      return WeaponList:Num() > 0
    end
  end
  return false
end
function SingleTrainingPlayerController:RestoreWeaponFromArchive(tWeaponList)
  print(bWriteLog and "SingleTrainingPlayerController:RestoreWeaponFromArchive")
  if not tWeaponList or #tWeaponList == 0 or self.bHasRestoreWeapon then
    print(bWriteLog and "SingleTrainingPlayerController:RestoreWeaponFromArchive - weapon list is empty")
    return
  end
  local uPlayerCharacter = self:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerCharacter) then
    print(bWriteLog and "SingleTrainingPlayerController:RestoreWeaponFromArchive - player character is invalid")
    return
  end
  print(bWriteLog and "SingleTrainingPlayerController:RestoreWeaponFromArchive - count:" .. #tWeaponList)
  for _, nWeaponID in ipairs(tWeaponList) do
    Game:AddItemByResID(uPlayerCharacter, nWeaponID, 1, false, -1, -1, 0, true)
  end
  self.bHasRestoreWeapon = true
end
function SingleTrainingPlayerController:ClientRPC_ShowDamageNum(nDamage, nDamageHitPos, ImpactPoint, uHitCharacter, nDamageType)
  print(bWriteLog and "[YY-D] SingleTrainingPlayerController:ClientRPC_ShowDamageNum Damege = " .. nDamage)
  if slua.isValid(uHitCharacter) then
    local HUD = self:GetHUD()
    if slua.isValid(HUD) then
      local bIsHeadShot = false
      if nDamageHitPos == 1 then
        bIsHeadShot = true
      end
      local DamageShowLoc = FVector(ImpactPoint.X, ImpactPoint.Y, ImpactPoint.Z)
      if nDamageType == 16 then
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
        if MainControlBaseUI then
          local UIUtil = require("client.common.ui_util")
          local ViewportPos = UIUtil.GetWidgetViewportPosInNormalized(MainControlBaseUI, 0.5, 0.5)
          local WorldPosition, WorldDirection = UIUtil.DeprojectScreenToWorld(ViewportPos)
          local vEndLoc = WorldPosition + WorldDirection * 20
          DamageShowLoc = FVector(vEndLoc.X, vEndLoc.Y, vEndLoc.Z)
        end
      end
      HUD:AddHitDamage(nDamage, bIsHeadShot, CDamageEvent(), uHitCharacter, true)
      if UIManager and UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.BallisticTargetDamageMainUI then
        if bIsHeadShot then
          local uColor = FSlateColor(FLinearColor(1, 0.86, 0.13, 1))
          UIManager.ShowUI(UIManager.UI_Config_InGame.BallisticTargetDamageMainUI, math.floor(nDamage), DamageShowLoc.X, DamageShowLoc.Y, DamageShowLoc.Z, uColor, 20)
        else
          UIManager.ShowUI(UIManager.UI_Config_InGame.BallisticTargetDamageMainUI, math.floor(nDamage), DamageShowLoc.X, DamageShowLoc.Y, DamageShowLoc.Z, nil, nil)
        end
      end
    end
  else
    print(bWriteLog and "[YY-E] SingleTrainingPlayerController:ClientRPC_ShowDamageNum uHitCharacter Not Valid ")
  end
end
function SingleTrainingPlayerController:ShouldSendFatalDamageToClient(Causer, Victim)
  local CurPlayerCharacter = self:GetCurPlayerCharacter()
  return slua.isValid(CurPlayerCharacter) and slua.isValid(Causer) and CurPlayerCharacter == Causer
end
function SingleTrainingPlayerController:ClientRPC_SpawnDeadBox(Loc, AvatarID)
  if not Client then
    return
  end
  CGameState.STDeadBoxClientShowFeature:SpawnSTDeadBox(Loc, AvatarID)
end
function SingleTrainingPlayerController:ForceDropItemsWithTypeLua(nType)
  local Record = {}
  if nType == 6 then
    local uBackpackComp = self:GetBackpackComponent()
    if not slua.isValid(uBackpackComp) then
      print(bWriteLog and "SingleTrainingPlayerController:ForceDropItemsWithTypeLua uBackpackComp is invalid")
      return
    end
    local UBackpackUtils_C = import("BackpackUtils")
    local ItemDataArray = UBackpackUtils_C.GetAllItemsInBackpackWithOneSubType(uBackpackComp, 606, 0)
    print(bWriteLog and "SingleTrainingPlayerController:ForceDropItemsWithTypeLua ItemDataArray:Num() = " .. tostring(ItemDataArray:Num()))
    if 0 < ItemDataArray:Num() then
      local FBattleItemData
      for Index = 0, ItemDataArray:Num() - 1 do
        FBattleItemData = ItemDataArray:Get(Index)
        local ItemID = FBattleItemData.DefineID.TypeSpecificID
        local ItemCount = FBattleItemData.Count
        if 0 < ItemCount then
          Record[ItemID] = ItemCount
          print(bWriteLog and "SingleTrainingPlayerController:ForceDropItemsWithTypeLua save 606 item: " .. tostring(ItemID) .. " with count: " .. tostring(ItemCount))
        end
      end
    end
  end
  self:ForceDropItemsWithType(nType)
  if nType == 6 then
    local uPlayer = self:GetPlayerCharacterSafety()
    if Game:IsValid(uPlayer) then
      for ItemID, ItemCount in pairs(Record) do
        print(bWriteLog and "SingleTrainingPlayerController:ForceDropItemsWithTypeLua recover item: " .. tostring(ItemID) .. " with count: " .. tostring(ItemCount))
        Game:AddItemByResID(uPlayer, ItemID, ItemCount)
      end
    end
  end
end
function SingleTrainingPlayerController:ClientRPC_ShowStartTrainingFailTips(nTrainingMode)
  print(bWriteLog and "SingleTrainingPlayerController:ClientRPC_ShowStartTrainingFailTips")
  if Client then
    ShowNotice(LocUtil.GetLocalizeResStr(22014))
  end
end
function SingleTrainingPlayerController:CheckPlayerNumFull()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uMyChar = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uMyChar) then
    print(bWriteLog and "SingleTrainingPlayerController:CheckPlayerNumFull InValid uMyChar ")
    return false
  end
  local GameplayStatics = import("GameplayStatics")
  local ActorCls = import("/Script/Engine.Actor")
  local uClass = slua.loadClass("/Game/Mod/SingleTraining/BluePrints/Core/BP_PlayerPawn_ST.BP_PlayerPawn_ST")
  local ActorLists = GameplayStatics.GetAllActorsOfClass(self.Object, uClass, slua.Array(UEnums.EPropertyClass.Object, ActorCls))
  local TotalCount = 0
  if ActorLists then
    for _, uPlayerCharacter in pairs(ActorLists) do
      if slua.isValid(uPlayerCharacter) and uMyChar.TeamID == uPlayerCharacter.TeamID then
        TotalCount = TotalCount + 1
      end
    end
  end
  print(bWriteLog and "SingleTrainingPlayerController:CheckPlayerNumFull Team:" .. tostring(uMyChar.TeamID) .. " TotalCount:" .. tostring(TotalCount))
  if TotalCount < 4 then
    return false
  end
  return true
end
local class = require("class")
local CPlayerController = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerControllerBase")
local CSingleTrainingPlayerController = class(CPlayerController, nil, SingleTrainingPlayerController)
return CSingleTrainingPlayerController
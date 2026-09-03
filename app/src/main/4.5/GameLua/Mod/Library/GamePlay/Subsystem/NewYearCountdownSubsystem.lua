local NewYearCountdownSubsystem = {}
local CountdownActorPath = "/Game/Library/Res/Actors/HappyNewYear/BluePrints/Actor/NewYearCountdown.NewYearCountdown"
function NewYearCountdownSubsystem:OnInit()
  print(bWriteLog and "NewYearCountdownSubsystem:OnInit")
  NewYearCountdownSubsystem.__super.OnInit(self)
  self.SkyBlackBitMap = 0
  self.bModeOpened = {}
  self.CachedNewYearZeroTime = {}
  self.bPlayingBGM = false
  self.bInFinishState = false
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  self.Config = require("GameLua.ExtraModule.NewYearFirework.Gameplay.Config.NewYearFireworkConfig")
  if Client then
  else
    local bIsAnyConfigOpen = false
    for i = 1, #self.Config do
      if self:IsOpenedBySubModeId(i) then
        bIsAnyConfigOpen = true
      end
    end
    if bIsAnyConfigOpen then
      self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
        [1] = "ReadyState"
      }, self.OnGameModeStateChanged, self)
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, self.HandlePlayerJoin, self)
    end
  end
  self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT, self.HandleEnterProtectClient, self)
  self.bFinishInit = true
  if Client and self.CachedFireworkBGMFlag then
    self:OnRepFireworkBGMFlag(self.CachedFireworkBGMFlag)
    self.CachedFireworkBGMFlag = nil
  end
end
function NewYearCountdownSubsystem:OnGameModeStateChanged()
  print(bWriteLog and "NewYearCountdownSubsystem:OnGameModeStateChanged")
  if not self.Config then
    print(bWriteLog and "NewYearCountdownSubsystem:OnGameModeStateChanged, Config is nil")
    return
  end
  for i = 1, #self.Config do
    self:HappyNewYearByTime(nil, i)
    self:AddExtraFireworkItem(nil, i)
  end
end
function NewYearCountdownSubsystem:AddExtraFireworkItem(SpecifiedTime, InFlag)
  if Client then
    return
  end
  if not self:IsOpenedBySubModeId(InFlag) then
    print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, NOT IsOpenedBySubModeId")
    return
  end
  if not (self.Config and self.Config[InFlag]) or self.Config[InFlag].ExtraItemOpen ~= true then
    print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, ExtraItemOpen not true")
    return
  end
  local ReadyTime = CGameMode.GameModeStateReady.StateTime
  if ReadyTime and 0 < ReadyTime then
    print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, ReadyTime = " .. tostring(ReadyTime))
    local Callback = function()
      local CurrentTime = self:GetCurrentTime(SpecifiedTime)
      if not CurrentTime then
        print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, invalid CurrentTime")
        return
      end
      local NewYearZeroTime = self:GetNewYearZeroTimeByTimeZone(InFlag)
      if NewYearZeroTime and CurrentTime >= NewYearZeroTime - self.Config[InFlag].ExtraItemBeforeNewYearTime and CurrentTime <= NewYearZeroTime + self.Config[InFlag].ExtraItemAfterNewYearTime then
        local PlayerArray = Game:GetAllPlayerPawns()
        if not PlayerArray or PlayerArray:Num() <= 0 then
          print(bWriteLog and "NewYearCountdownSubsystem:AddItemByOneRound, Invalid PlayerArray")
          return
        end
        for i = 0, PlayerArray:Num() - 1 do
          local Pawn = PlayerArray:Get(i)
          if Pawn and slua.isValid(Pawn) and Pawn.PlayerKey and self.Config[InFlag].AddItemId and self.Config[InFlag].AddItemNum and 0 < self.Config[InFlag].AddItemId and 0 < self.Config[InFlag].AddItemNum then
            if Game:AddItemByResID(Pawn, self.Config[InFlag].AddItemId, self.Config[InFlag].AddItemNum) then
              print(bWriteLog and "NewYearCountdownSubsystem:AddItemByResID succeed PlayerKey = " .. tostring(Pawn.PlayerKey))
            else
              print(bWriteLog and "NewYearCountdownSubsystem:AddItemByResID failed PlayerKey = " .. tostring(Pawn.PlayerKey))
            end
          end
        end
        print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, Added, CurrentTime = " .. tostring(CurrentTime))
      else
        print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, Didn't Add, CurrentTime = " .. tostring(CurrentTime))
      end
    end
    self:AddGameTimer(ReadyTime + 5, false, function()
      Callback()
    end)
  else
    print(bWriteLog and "NewYearCountdownSubsystem:AddExtraFireworkItem, invalid ReadyTime = " .. tostring(ReadyTime))
  end
end
function NewYearCountdownSubsystem:GMStartHappyNewYearByTime(SpecifiedTime)
  print(bWriteLog and "NewYearCountdownSubsystem:GMStartHappyNewYearByTime, SpecifiedTime = " .. tostring(SpecifiedTime))
  self.CachedNewYearZeroTime = {}
  self:RemoveAllGameTimer()
  self.SkyBlackBitMap = 0
  if not self.Config then
    print(bWriteLog and "NewYearCountdownSubsystem:GMStartHappyNewYearByTime, Config is nil")
    return
  end
  for i = 1, #self.Config do
    self:HappyNewYearByTime(SpecifiedTime, i)
    self:AddExtraFireworkItem(SpecifiedTime, i)
  end
end
function NewYearCountdownSubsystem:HappyNewYearByTime(SpecifiedTime, InFlag)
  if not self:IsOpenedBySubModeId(InFlag) then
    print(bWriteLog and "NewYearCountdownSubsystem:HappyNewYearByTime NOT IsOpenedBySubModeId")
    return
  end
  print(bWriteLog and "NewYearCountdownSubsystem:HappyNewYearByTime, SpecifiedTime = " .. tostring(SpecifiedTime))
  local TimeToZero = self:GetTimeToZero(SpecifiedTime, InFlag)
  self:PrepareCountdown(TimeToZero, SpecifiedTime, InFlag)
  self:PrepareFirework(TimeToZero, InFlag)
  self:PrepareBlackSky(TimeToZero, InFlag)
  self:PrepareBGM(TimeToZero, InFlag)
end
function NewYearCountdownSubsystem:PrepareCountdown(InTimeToZero, InSpecifiedTime, InFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:PrepareCountdown, InTimeToZero = " .. tostring(InTimeToZero))
  if not (self.Config and self.Config[InFlag] and self.Config[InFlag].TotalLeftTime) or not self.Config[InFlag].StartListenTime then
    print(bWriteLog and "NewYearCountdownSubsystem:PrepareCountdown, Config or Config.TotalLeftTime is nil")
  end
  local LeftTime = -InTimeToZero
  local bStarted = LeftTime <= self.Config[InFlag].TotalLeftTime
  if bStarted == true then
    if 0 <= LeftTime then
      self:StartCountdownTimer(LeftTime, InFlag)
    end
  else
    local TimeToStartCountdown = LeftTime - self.Config[InFlag].TotalLeftTime
    if TimeToStartCountdown < self.Config[InFlag].StartListenTime then
      self:AddGameTimer(TimeToStartCountdown + 2, false, function()
        local SecondTryTimeToZero = self:GetTimeToZero(InSpecifiedTime, InFlag)
        if InSpecifiedTime ~= nil then
          SecondTryTimeToZero = SecondTryTimeToZero + TimeToStartCountdown + 2
        end
        print(bWriteLog and "NewYearCountdownSubsystem:PrepareCountdown, SecondTryTimeToZero = " .. tostring(SecondTryTimeToZero))
        self:PrepareCountdown(SecondTryTimeToZero, InSpecifiedTime, InFlag)
      end)
    end
  end
end
function NewYearCountdownSubsystem:PrepareFirework(InTimeToZero, InFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:PrepareFirework, InTimeToZero = " .. tostring(InTimeToZero))
  if not (self.Config and self.Config[InFlag] and self.Config[InFlag].SequenceRanges and self.Config[InFlag].FireworkRounds) or not self.Config[InFlag].StartListenTime then
    print(bWriteLog and "NewYearCountdownSubsystem:PrepareFirework, Config is Invalid")
    return
  end
  local Ranges = self.Config[InFlag].SequenceRanges
  for i = 1, #Ranges do
    local Range = Ranges[i]
    local StartTime = Range.StartTime
    local EndTime = Range.EndTime
    if InTimeToZero < StartTime then
      local TimeToStart = StartTime - InTimeToZero
      if TimeToStart <= self.Config[InFlag].StartListenTime then
        self:PlayFireworkLoop(TimeToStart, self.Config[InFlag].FireworkRounds, false, InFlag)
      end
    elseif InTimeToZero <= EndTime then
      self:PlayFireworkLoop(0, self.Config[InFlag].FireworkRounds, false, InFlag)
    end
  end
end
function NewYearCountdownSubsystem:PrepareBlackSky(InTimeToZero, InFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky, InTimeToZero = " .. tostring(InTimeToZero) .. ", InFlag = " .. tostring(InFlag))
  if not (self.Config and self.Config[InFlag] and self.Config[InFlag].BlackSkyRanges and self.Config[InFlag].StartListenTime) or not self.Config[InFlag].SkyBoxNormalDuration then
    print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky, Config is Invalid")
    return
  end
  local Ranges = self.Config[InFlag].BlackSkyRanges
  for i = 1, #Ranges do
    local Range = Ranges[i]
    local StartTime = Range.StartTime
    local EndTime = Range.EndTime
    if InTimeToZero < StartTime then
      local TimeToStart = StartTime - InTimeToZero
      if TimeToStart <= self.Config[InFlag].StartListenTime then
        self:AddGameTimer(TimeToStart, false, function()
          self:SetSkyBlackFlag(InFlag, true)
        end)
        print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky Before Range, SwtichOnTime = " .. tostring(TimeToStart))
        local CompensateTime = Range.CompensateTime
        local NormalDuration = self.Config[InFlag].SkyBoxNormalDuration
        if CompensateTime then
          NormalDuration = NormalDuration + CompensateTime
        end
        self:AddGameTimer(TimeToStart + NormalDuration, false, function()
          self:SetSkyBlackFlag(InFlag, false)
        end)
        print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky Before Range, SwtichOffTime = " .. tostring(TimeToStart + NormalDuration))
      end
    elseif InTimeToZero <= EndTime then
      self:SetSkyBlackFlag(InFlag, true)
      local CompensateTime = Range.CompensateTime
      if CompensateTime then
        local TimeWithinRange = InTimeToZero - StartTime
        local TimeToCompensate = math.max(CompensateTime - TimeWithinRange, 0)
        self:AddGameTimer(TimeToCompensate + self.Config[InFlag].SkyBoxNormalDuration, false, function()
          self:SetSkyBlackFlag(InFlag, false)
        end)
        print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky In Special Range, SwtichOffTime = " .. tostring(TimeToCompensate + self.Config[InFlag].SkyBoxNormalDuration))
      else
        self:AddGameTimer(self.Config[InFlag].SkyBoxNormalDuration, false, function()
          self:SetSkyBlackFlag(InFlag, false)
        end)
        print(bWriteLog and "NewYearCountdownSubsystem:PrepareBlackSky In Normal Range, SwtichOffTime = " .. tostring(self.Config[InFlag].SkyBoxNormalDuration))
      end
    end
  end
end
function NewYearCountdownSubsystem:PrepareBGM(InTimeToZero, InFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:PrepareBGM, InTimeToZero = " .. tostring(InTimeToZero))
  if not (self.Config and self.Config[InFlag] and self.Config[InFlag].BGMRanges) or not self.Config[InFlag].FireworkBGMDuration then
    print(bWriteLog and "NewYearCountdownSubsystem:PrepareBGM, Config is Invalid")
    return
  end
  local Ranges = self.Config[InFlag].BGMRanges
  for i = 1, #Ranges do
    local Range = Ranges[i]
    local StartTime = Range.StartTime
    local EndTime = Range.EndTime
    if InTimeToZero < StartTime then
      local TimeToStart = StartTime - InTimeToZero
      if TimeToStart <= self.Config[InFlag].StartListenTime then
        self:AddGameTimer(TimeToStart, false, function()
          self:SetBGMFlag(InFlag)
        end)
        self:AddGameTimer(TimeToStart + self.Config[InFlag].FireworkBGMDuration, false, function()
          self:SetBGMFlag(-1)
        end)
      end
    elseif InTimeToZero <= EndTime then
      self:SetBGMFlag(InFlag)
      self:AddGameTimer(self.Config[InFlag].FireworkBGMDuration, false, function()
        self:SetBGMFlag(-1)
      end)
    end
  end
end
function NewYearCountdownSubsystem:StartCountdownTimer(LeftTime, Flag)
  print(bWriteLog and "NewYearCountdownSubsystem:StartCountdownTimer, LeftTime = " .. tostring(LeftTime), " Flag = " .. tostring(Flag))
  if CGameState and CGameState.UpdateCountdownTime then
    CGameState:UpdateCountdownTime(LeftTime * 10 + Flag)
    self:RemoveCountdownTimer()
    self.CountdownTimer = self:AddGameTimer(1, true, function()
      LeftTime = LeftTime - 1
      if 0 <= LeftTime then
        CGameState:UpdateCountdownTime(LeftTime * 10 + Flag)
      else
        self:RemoveCountdownTimer()
      end
    end)
  else
    print(bWriteLog and "NewYearCountdownSubsystem:StartCountdownTimer, CGameState = " .. tostring(CGameState))
  end
end
function NewYearCountdownSubsystem:OnRepCurrentTime(LeftTimeAndFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:OnRepCurrentTime, LeftTimeAndFlag = " .. tostring(LeftTimeAndFlag))
  if not self.Config then
    print(bWriteLog and "NewYearCountdownSubsystem:OnRepCurrentTime, SubsystemConfig is nil")
    return
  end
  if not Client then
    return
  end
  local LeftTime = LeftTimeAndFlag // 10
  local Flag = LeftTimeAndFlag % 10
  if LeftTime < 0 then
    return
  end
  if self.CountdownActor and slua.isValid(self.CountdownActor) then
    if self.CountdownActor.UpdateMeshByLeftTime then
      self.CountdownActor:UpdateMeshByLeftTime(LeftTime, Flag)
    end
  else
    self.CountdownActor = nil
    if CGameState then
      local uWorld = CGameState:GetWorld()
      local CountdownActorClass = slua.loadClass(CountdownActorPath)
      if uWorld and CountdownActorClass then
        local Location, Rotation = self:GetSpawnLocationByMap(Flag)
        local CountdownActor = uWorld:SpawnActor(CountdownActorClass, Location, Rotation, nil)
        if CountdownActor and slua.isValid(CountdownActor) then
          self.          if self.CountdownActor.UpdateMeshByLeftTime then
            self.CountdownActor:UpdateMeshByLeftTime(LeftTime, Flag)
          end
        end
      end
    else
      print(bWriteLog and "NewYearCountdownSubsystem:OnRepCurrentTime, CGameState = " .. tostring(CGameState))
    end
  end
  self:ShowFireworkShowTips(LeftTime, Flag)
end
function NewYearCountdownSubsystem:ShowFireworkShowTips(LeftTime, Flag)
  local Param = -1
  for k, v in pairs(self.Config[Flag].ShowTipsTime) do
    if k == LeftTime then
      Param = v
      break
    end
  end
  print(bWriteLog and "NewYearCountdownSubsystem:ShowFireworkShowTips, Param = " .. tostring(Param))
  if -1 < Param then
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.NewYearFireworkTipsUI)
    if ui ~= nil then
      UIManager.CloseUI(UIManager.UI_Config_InGame.NewYearFireworkTipsUI)
    end
    UIManager.ShowUI(UIManager.UI_Config_InGame.NewYearFireworkTipsUI, Param)
  end
end
function NewYearCountdownSubsystem:RemoveCountdownTimer()
  if self.CountdownTimer then
    self:RemoveGameTimer(self.CountdownTimer)
    self.CountdownTimer = nil
  end
end
function NewYearCountdownSubsystem:DestroyCountdownActor()
  if self.CountdownActor and slua.isValid(self.CountdownActor) then
    print(bWriteLog and "NewYearCountdownSubsystem:DestroyCountdownActor")
    self.CountdownActor:K2_DestroyActor()
    self.CountdownActor = nil
  end
end
function NewYearCountdownSubsystem:DestroySequenceActor()
  if not Client and self.NewYearSequenceActor and slua.isValid(self.NewYearSequenceActor) then
    print(bWriteLog and "NewYearCountdownSubsystem:DestroyLevelActor")
    self.NewYearSequenceActor:K2_DestroyActor()
    self.NewYearSequenceActor = nil
  end
end
function NewYearCountdownSubsystem:SetSkyBlackFlag(InFlag, InbBlack)
  print(bWriteLog and "NewYearCountdownSubsystem:SetSkyBlackFlag, InFlag = " .. tostring(InFlag) .. ", InbBlack = " .. tostring(InbBlack))
  if InbBlack then
    self.SkyBlackBitMap = self.SkyBlackBitMap | 1 << InFlag
  else
    self.SkyBlackBitMap = self.SkyBlackBitMap & ~(1 << InFlag)
  end
  print(bWriteLog and "NewYearCountdownSubsystem:SetSkyBlackFlag, SkyBlackBitMap = " .. tostring(self.SkyBlackBitMap))
  self:ActualChangeSkyBoxByFlag()
end
function NewYearCountdownSubsystem:HandlePlayerJoin(_, __, Pawn)
  if not slua.isValid(Pawn) then
    print(bWriteLog and "NewYearCountdownSubsystem:HandlePlayerJoin, Pawn is Invalid")
    return
  end
  if not self.Config then
    print(bWriteLog and "NewYearCountdownSubsystem:HandlePlayerJoin, Config is Invalid")
    return
  end
  local PlayerKey = Pawn.PlayerKey
  print(bWriteLog and "NewYearCountdownSubsystem:HandlePlayerJoin, PlayerKey = " .. tostring(PlayerKey))
  local FinalSkyTransitionState = {}
  for k = 1, #self.Config do
    local bShouldSkyBlack = self.SkyBlackBitMap & 1 << k > 0
    print(bWriteLog and "NewYearCountdownSubsystem:HandlePlayerJoin, k = " .. tostring(k) .. ", bShouldSkyBlack = " .. tostring(bShouldSkyBlack))
    local SkyTransitionID = self.Config[k].SkyBoxConfigID
    if SkyTransitionID and 0 < SkyTransitionID then
      if FinalSkyTransitionState[SkyTransitionID] == nil then
        FinalSkyTransitionState[SkyTransitionID] = bShouldSkyBlack
      else
        FinalSkyTransitionState[SkyTransitionID] = FinalSkyTransitionState[SkyTransitionID] or bShouldSkyBlack
      end
    end
  end
  if Pawn and slua.isValid(Pawn) and Pawn.SkyTransition then
    for SkyTransitionID, bShouldSkyBlack in pairs(FinalSkyTransitionState) do
      print(bWriteLog and "NewYearCountdownSubsystem:HandlePlayerJoin, SkyTransitionID = " .. tostring(SkyTransitionID) .. ", bShouldSkyBlack = " .. tostring(bShouldSkyBlack))
      Pawn.SkyTransition:SetStateActive(SkyTransitionID, bShouldSkyBlack)
    end
  end
end
function NewYearCountdownSubsystem:HandlePetSpawn()
  self:ActualChangeSkyBoxByFlag()
end
function NewYearCountdownSubsystem:ActualChangeSkyBoxByFlag()
  if not self.Config then
    print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBoxByFlag, Config is Invalid")
    return
  end
  local FinalSkyTransitionState = {}
  for k = 1, #self.Config do
    local bShouldSkyBlack = self.SkyBlackBitMap & 1 << k > 0
    print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBoxByFlagDetermine, k = " .. tostring(k) .. ", bShouldSkyBlack = " .. tostring(bShouldSkyBlack))
    local SkyTransitionID = self.Config[k].SkyBoxConfigID
    if SkyTransitionID and 0 < SkyTransitionID then
      if FinalSkyTransitionState[SkyTransitionID] == nil then
        FinalSkyTransitionState[SkyTransitionID] = bShouldSkyBlack
      else
        FinalSkyTransitionState[SkyTransitionID] = FinalSkyTransitionState[SkyTransitionID] or bShouldSkyBlack
      end
    end
  end
  local PlayerArray = Game:GetAllPlayerPawns()
  if not PlayerArray or 0 >= PlayerArray:Num() then
    print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBox, Invalid PlayerArray")
  else
    for SkyTransitionID, bShouldSkyBlack in pairs(FinalSkyTransitionState) do
      print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBoxExecute1, SkyTransitionID = " .. tostring(SkyTransitionID) .. ", bShouldSkyBlack = " .. tostring(bShouldSkyBlack))
      for i = 0, PlayerArray:Num() - 1 do
        local Pawn = PlayerArray:Get(i)
        if Pawn and slua.isValid(Pawn) and Pawn.SkyTransition then
          Pawn.SkyTransition:SetStateActive(SkyTransitionID, bShouldSkyBlack)
        end
      end
    end
  end
  local PetPlayerArray = Game:GetAllPlayerPetPawns()
  if not PetPlayerArray or 0 >= PetPlayerArray:Num() then
    print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBox, Invalid PetPlayerArray")
  else
    for SkyTransitionID, bShouldSkyBlack in pairs(FinalSkyTransitionState) do
      print(bWriteLog and "NewYearCountdownSubsystem:ActualChangeSkyBoxExecute2, SkyTransitionID = " .. tostring(SkyTransitionID) .. ", bShouldSkyBlack = " .. tostring(bShouldSkyBlack))
      for i = 0, PetPlayerArray:Num() - 1 do
        local Pawn = PetPlayerArray:Get(i)
        if Pawn and slua.isValid(Pawn) and Pawn.SkyTransition then
          Pawn.SkyTransition:SetStateActive(SkyTransitionID, bShouldSkyBlack)
        end
      end
    end
  end
end
function NewYearCountdownSubsystem:SetBGMFlag(InFlag)
  if CGameState and CGameState.UpdateFireworkBGMFlag then
    CGameState:UpdateFireworkBGMFlag(InFlag)
  end
end
function NewYearCountdownSubsystem:OnRepFireworkBGMFlag(InFireworkBGMFlag)
  print(bWriteLog and "NewYearCountdownSubsystem:OnRepFireworkBGMFlag, InFireworkBGMFlag = " .. tostring(InFireworkBGMFlag))
  if not self.bFinishInit then
    self.CachedFireworkBGMFlag = InFireworkBGMFlag
    print(bWriteLog and "NewYearCountdownSubsystem:OnRepFireworkBGMFlag, bFinishInit = false, cache flag = " .. tostring(InFireworkBGMFlag))
    return
  end
  if not self.bPlayingBGM then
    if 0 < InFireworkBGMFlag then
      print(bWriteLog and "NewYearCountdownSubsystem:PlayBGM InFireworkBGMFlag = " .. tostring(InFireworkBGMFlag))
      self:ClientPlaySequenceBGM(InFireworkBGMFlag)
    end
  elseif InFireworkBGMFlag == -1 then
    self:ClientPlaySequenceBGM(InFireworkBGMFlag)
  end
end
function NewYearCountdownSubsystem:ClientPlaySequenceBGM(InFireworkBGMFlag)
  if not Client then
    return
  end
  if not self.bFinishInit then
    print(bWriteLog and "NewYearCountdownSubsystem:ClientPlaySequenceBGM, bFinishInit = false")
    return
  end
  if 0 < InFireworkBGMFlag and not self.bInFinishState then
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    if not BattleResultSubSystem then
      print(bWriteLog and "NewYearCountdownSubsystem:ClientPlaySequenceBGM:invalid BattleResultSubSystem")
      return
    end
    if BattleResultSubSystem:EnterProtectProcess() then
      print(bWriteLog and "NewYearCountdownSubsystem:ClientPlaySequenceBGM: have endered finish state")
      return
    end
    local CanPlay = self:CanPlayAudioByAreaID(InFireworkBGMFlag)
    print(bWriteLog and "NewYearCountdownSubsystem:ClientPlaySequenceBGM, CanPlay = " .. tostring(CanPlay))
    if CanPlay == true then
      local Config = require("GameLua.ExtraModule.NewYearFirework.Gameplay.Config.NewYearFireworkConfig")
      if Config and Config[InFireworkBGMFlag] and Config[InFireworkBGMFlag].SequenceBGM and Config[InFireworkBGMFlag].SequenceBGM ~= "" then
        local audio_util = require("client.common.audio_util")
        print(bWriteLog and "NewYearCountdownSubsystem:ClientPlaySequenceBGM, PlayAudioAsync")
        audio_util.PlayAudioAsync(Config[InFireworkBGMFlag].SequenceBGM, nil, nil, function(...)
          self:RegisterAudioID(...)
        end)
        self.bPlayingBGM = true
      end
    end
  else
    print(bWriteLog and "NewYearCountdownSubsystem:ClientTryStopSequenceBGM")
    self:StopBGMInternal()
  end
end
function NewYearCountdownSubsystem:RegisterAudioID(audioID, audioPath)
  self.BGMID = audioID
end
function NewYearCountdownSubsystem:StopBGMInternal()
  print(bWriteLog and "NewYearCountdownSubsystem:StopBGMInternal")
  if self.BGMID then
    local audio_util = require("client.common.audio_util")
    audio_util.StopSound(self.BGMID)
    self.BGMID = nil
    self.bPlayingBGM = false
  end
end
function NewYearCountdownSubsystem:HandleEnterProtectClient()
  print(bWriteLog and "NewYearCountdownSubsystem:Stop BGM")
  if Client then
    self.bInFinishState = true
    print(bWriteLog and "NewYearCountdownSubsystem:Stop BGM Client in finished state")
    self:StopBGMInternal()
  end
end
function NewYearCountdownSubsystem:GetTimeToZero(SpecifiedTime, InFlag)
  local CurrentTime = self:GetCurrentTime(SpecifiedTime)
  local NewYearZeroTime = self:GetNewYearZeroTimeByTimeZone(InFlag)
  local OutTimeToZero = CurrentTime - NewYearZeroTime
  print(bWriteLog and "NewYearCountdownSubsystem:GetTimeToZero, OutTimeToZero = " .. tostring(OutTimeToZero))
  return OutTimeToZero
end
function NewYearCountdownSubsystem:ServerPlayFireworkSequenceImpl(InFlag)
  local SequencePath = self.Config[InFlag].SequencePath
  local SequenceActorPath = self.Config[InFlag].SequenceActorPath
  local SequenceLocation = self:GetFireworkShowLocationByMap(InFlag)
  local SequenceRotator = FRotator(0, 0, 0)
  local SequenceScale = FVector(1, 1, 1)
  local UKismetMathLibrary = import("KismetMathLibrary")
  local SequenceTransform = UKismetMathLibrary.MakeTransform(SequenceLocation, SequenceRotator, SequenceScale)
  if CGameState then
    local uWorld = CGameState:GetWorld()
    local SequenceActor = Game:PlayLevelSequence(uWorld, SequencePath, SequenceTransform, SequenceActorPath, true)
    if Game:IsValid(SequenceActor) then
      self:DestroySequenceActor()
      self.NewYear      CGameState:ReportPlayersNumberWhoSawFireworks()
      print(bWriteLog and "NewYearCountdownSubsystem:ServerPlayFireworkSequenceImpl, PlayLevelSequenceStarted")
    else
      print(bWriteLog and "NewYearCountdownSubsystem:ServerPlayFireworkSequenceImpl, SequenceActor = " .. tostring(SequenceActor))
    end
  else
    print(bWriteLog and "NewYearCountdownSubsystem:ServerPlayFireworkSequenceImpl, CGameState = " .. tostring(CGameState))
  end
end
function NewYearCountdownSubsystem:PlayFireworkLoop(StartTime, Rounds, bInfinite, InFlag)
  if bInfinite then
    self:ServerPlayFireworkSequenceImpl(InFlag)
    self:AddGameTimer(self.Config[InFlag].FireworkSequenceDuration, true, function()
      self:ServerPlayFireworkSequenceImpl(InFlag)
    end)
  else
    for i = 0, Rounds - 1 do
      self:AddGameTimer(StartTime + i * self.Config[InFlag].FireworkSequenceDuration, false, function()
        self:ServerPlayFireworkSequenceImpl(InFlag)
      end)
    end
  end
end
function NewYearCountdownSubsystem:GetCurrentTime(SpecifiedTime)
  print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, os.time = " .. os.time() .. ", time interval = " .. os.time() - os.time(os.date("!*t")) .. ", " .. os.date("%H:%M:%S", 0))
  if SpecifiedTime == nil then
    if Game:IsEditor() then
      return os.time()
    elseif Server and Server.IsShipping() then
      return os.time()
    else
      local UseOsTime = CGame:GetCommandLineValue("useostime=")
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, UseOsTime = " .. tostring(UseOsTime))
      if UseOsTime ~= "" then
        return os.time()
      end
      local ServerStartTime = ServerDataMgr.SyncGameParams.server_time
      local GameStartTime = CGameState:GetServerWorldTimeSeconds()
      if not ServerStartTime or not GameStartTime then
        print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, ServerStartTime or GameStartTime is nil")
        return os.time()
      end
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, ServerStartTime = " .. tostring(ServerStartTime) .. ", GameStartTime = " .. tostring(GameStartTime))
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, ServerStartTime + GameStartTime = " .. tostring(ServerStartTime + GameStartTime))
      return ServerStartTime + math.floor(GameStartTime)
    end
  else
    if type(SpecifiedTime) ~= "string" or string.len(SpecifiedTime) == 0 then
      return os.time()
    end
    local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(SpecifiedTime, p)
    if year and month and day and hour and min and sec then
      local CurrentTime = os.time({
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = min,
        sec = sec,
        isdst = false
      }) + (os.time() - os.time(os.date("!*t")))
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentTime, SpecifiedTime = " .. tostring(SpecifiedTime) .. ", CurrentTime = " .. tostring(CurrentTime))
      return CurrentTime
    end
    return os.time()
  end
end
function NewYearCountdownSubsystem:GetNewYearZeroTimeByTimeZone(InFlag)
  if not self.CachedNewYearZeroTime then
    self.CachedNewYearZeroTime = {}
  end
  if self.CachedNewYearZeroTime[InFlag] then
    return self.CachedNewYearZeroTime[InFlag]
  end
  local NewYearZeroTime = 0
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if GamePlayTools.IsBlueHoleVersion() then
    NewYearZeroTime = self.Config.NewYearZeroTime[InFlag][7]
    print(bWriteLog and "NewYearCountdownSubsystem:GetNewYearZeroTimeByTimeZone, IsBlueHoleVersion, NewYearZeroTime = " .. tostring(NewYearZeroTime))
    return NewYearZeroTime
  end
  local ZoneId = 0
  if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.zone_id then
    ZoneId = ServerDataMgr.SyncGameParams.zone_id
  else
    print(bWriteLog and "NewYearCountdownSubsystem:GetNewYearZeroTimeByTimeZone, ServerDataMgr = " .. tostring(ServerDataMgr))
  end
  NewYearZeroTime = self.Config.NewYearZeroTime[InFlag][ZoneId] or self.Config.NewYearZeroTime[InFlag][0]
  print(bWriteLog and "NewYearCountdownSubsystem:GetNewYearZeroTimeByTimeZone, ZoneId = " .. tostring(ZoneId) .. ", NewYearZeroTime = " .. tostring(NewYearZeroTime))
  self.CachedNewYearZeroTime[InFlag] = NewYearZeroTime
  return NewYearZeroTime
end
function NewYearCountdownSubsystem:GetFireworkShowLocationByMap(InFlag)
  local ModType2 = self:GetCurrentModeType()
  local ShowLocation = self.Config[InFlag].SpawnLocation[ModType2] or self.Config[InFlag].SpawnLocation.Default
  ShowLocation.Z = self.Config[InFlag].FireworkShowHeight
  ShowLocation = FVector(ShowLocation.X, ShowLocation.Y, ShowLocation.Z)
  print(bWriteLog and "NewYearCountdownSubsystem:GetFireworkShowLocationByMap, ModType2 = " .. tostring(ModType2) .. ", ShowLocation = " .. tostring(ShowLocation:ToStringShort()))
  return ShowLocation
end
function NewYearCountdownSubsystem:GetCurrentModeType()
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local _, ModType2 = GameMainConfig.GetModType()
  if ModType2 == nil or ModType2 == "" then
    ModType2 = GameMainConfig.GetMapType()
    if ModType2 == nil or ModType2 == "" or ModType2 == "UnknownMap" then
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentModeType, ModType2 = " .. tostring(ModType2) .. ", and set to Default.")
      ModType2 = "Default"
    else
      print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentModeType, GetMapType ModType2 = " .. tostring(ModType2))
    end
  else
    print(bWriteLog and "NewYearCountdownSubsystem:GetCurrentModeType, ModType2 = " .. tostring(ModType2))
  end
  return ModType2
end
function NewYearCountdownSubsystem:GetSpawnLocationByMap(InFlag)
  local ModType2 = self:GetCurrentModeType()
  if not self.Config or not self.Config[InFlag] then
    print(bWriteLog and "NewYearCountdownSubsystem:GetSpawnLocationByMap, SubsystemConfig is nil")
    return
  end
  local SpawnLocation = self.Config[InFlag].SpawnLocation[ModType2] or self.Config[InFlag].SpawnLocation.Default
  SpawnLocation = FVector(SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z)
  local SpawnRotation = FRotator(0, 0, 0)
  print(bWriteLog and "NewYearCountdownSubsystem:GetSpawnLocationByMap, ModType2 = " .. tostring(ModType2) .. ", SpawnLocation = " .. tostring(SpawnLocation:ToStringShort()) .. ", SpawnRotation = " .. tostring(SpawnRotation:ToStringShort()))
  return SpawnLocation, SpawnRotation
end
function NewYearCountdownSubsystem:CanPlayAudioByAreaID(InFlag)
  if not (InFlag and self.Config) or not self.Config[InFlag] then
    print(bWriteLog and "NewYearCountdownSubsystem:CanPlayAudioByAreaID, Config is Invalid")
    return false
  end
  local CanPlay = true
  if CGameState and self.Config[InFlag].IgnoreAudioAreaID and #self.Config[InFlag].IgnoreAudioAreaID > 0 then
    local UGameplayStatics = import("GameplayStatics")
    local uPlayerController = UGameplayStatics.GetPlayerController(CGameState, 0)
    if uPlayerController and slua.isValid(uPlayerController) then
      local CurCharacter
      if uPlayerController.IsSpectator and uPlayerController:IsSpectator() or uPlayerController.IsObserver and uPlayerController:IsObserver() then
        if uPlayerController.GetCurPawn then
          CurCharacter = uPlayerController:GetCurPawn()
          print(bWriteLog and "NewYearCountdownSubsystem:CanPlayAudioByAreaID, Spectator or IsObserver")
        end
      elseif uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
        if uPlayerController.GetPetSpectatorComp and slua.isValid(uPlayerController:GetPetSpectatorComp()) then
          CurCharacter = uPlayerController:GetPetSpectatorComp().PetSpectatorPawn
          print(bWriteLog and "NewYearCountdownSubsystem:CanPlayAudioByAreaID, IsInPetSpectator")
        end
      else
        CurCharacter = uPlayerController:GetPlayerCharacterSafety()
        print(bWriteLog and "NewYearCountdownSubsystem:CanPlayAudioByAreaID, else")
      end
      if CurCharacter and slua.isValid(CurCharacter) and CurCharacter.GetAttrValue then
        local AreaID = math.floor(CurCharacter:GetAttrValue("AreaID") + 0.5)
        for _, v in ipairs(self.Config[InFlag].IgnoreAudioAreaID) do
          if v == AreaID then
            CanPlay = false
            print(bWriteLog and "NewYearCountdownSubsystem:CanPlayAudioByAreaID, return false when PlayerKey = " .. tostring(CurCharacter.PlayerKey) .. ", AreaID = " .. tostring(AreaID))
            break
          end
        end
      end
    end
  end
  return CanPlay
end
function NewYearCountdownSubsystem:IsOpenedBySubModeId(InFlag)
  if not (self.Config and self.Config[InFlag]) or self.Config[InFlag].bConfigOpened == false then
    print(bWriteLog and "NewYearCountdownSubsystem:IsOpenedBySubModeId, return false because bConfigOpened")
    return false
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if GamePlayTools.IsBlueHoleVersion() == false and self.Config[InFlag].bBlueholeExclusive then
    if CGame:IsEditor() then
      print(bWriteLog and "NewYearCountdownSubsystem:IsOpenedBySubModeId, not BlueHoleVersion but IsEditor")
    else
      print(bWriteLog and "NewYearCountdownSubsystem:IsOpenedBySubModeId, return false because not BlueHoleVersion")
      return false
    end
  end
  if not self.bModeOpened then
    self.bModeOpened = {}
  end
  if self.bModeOpened[InFlag] ~= nil then
    return self.bModeOpened[InFlag]
  end
  self.bModeOpened[InFlag] = false
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local CurSubModeId = GameMainConfig.GetModeID()
  if CurSubModeId then
    for _, v in ipairs(self.Config[InFlag].SubModeID) do
      if CurSubModeId == tonumber(v) then
        self.bModeOpened[InFlag] = true
        break
      end
    end
  end
  print(bWriteLog and "NewYearCountdownSubsystem:IsOpenedBySubModeId, self.bModeOpened = " .. tostring(self.bModeOpened[InFlag]) .. ", CurSubModeId = " .. tostring(CurSubModeId))
  return self.bModeOpened[InFlag]
end
function NewYearCountdownSubsystem:OnRelease()
  print(bWriteLog and "NewYearCountdownSubsystem:OnRelease")
  self:RemoveAllGameTimer()
  self:DestroyCountdownActor()
  self:DestroySequenceActor()
  self:StopBGMInternal()
  NewYearCountdownSubsystem.__super.OnRelease(self)
end
local Class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
local NewYearCountdownSubsystemClass = Class(SubsystemBase, nil, NewYearCountdownSubsystem)
return NewYearCountdownSubsystemClass
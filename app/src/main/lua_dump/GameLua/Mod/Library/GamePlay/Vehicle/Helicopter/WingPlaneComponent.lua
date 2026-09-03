local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
local ExtendAttribute = require("Server.config.ExtendAttribute")
local WingPlaneComponent = {}
local UseTestData = false
local DSSwitch = 38
local DefaultSkinID = 181101000
local WingManRelativeLocation = {
  [1] = FVector(-670.0, -1770.0, -550.0),
  [2] = FVector(-670.0, 1770.0, -550.0)
}
local IsHighLevelHelicoper = function(itemID)
  if itemID == nil or itemID == 0 then
    return false
  end
  local itemData = CDataTable.GetTableData("Item", itemID)
  if not itemData then
    return false
  end
  if itemData.ItemQuality < 5 then
    return false
  end
  return true
end
function WingPlaneComponent:ctor()
  self.XSuitIconFirst = 0
  self.XSuitIconSecond = 0
  self.bHasSetWingInfo = false
end
function WingPlaneComponent:ReceiveBeginPlay()
  WingPlaneComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "WingPlaneComponent:ReceiveBeginPlay()")
  if not Client then
    if self:IsRevivePlane() then
      self:AddGameTimer(0.1, false, function()
        print(bWriteLog and "WingPlaneComponent:ReceiveBeginPlay, In Timer")
        self:DSInit()
      end)
    else
      self:DSInit()
    end
  else
    self:ClientInit()
  end
end
function WingPlaneComponent:ClientInit()
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "WingPlaneComponent GameStatus.IsInLobbyOrMainCity()")
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if slua.isValid(UPlayerController) and Game:IsClassOf(UPlayerController, ASTExtraPlayerController) then
    self:AddControlEvent(UPlayerController, "OnPlayerCanJump", self.OnPlayerCanJump, self)
    local uCharacter = UPlayerController:GetPlayerCharacterSafety()
    if uCharacter and slua.isValid(uCharacter) then
      self:AddControlEvent(uCharacter, "OnParachuteStateChanged", self.OnHandleParachuteStateChanged, self)
    end
  end
end
function WingPlaneComponent:SetWingManUserData(UserData)
  self.WingManUserData:Clear()
  local FWingManUserDataStruct = import("WingManUserDataStruct")
  for key, value in pairs(UserData) do
    local WingManUserDataStruct = FWingManUserDataStruct()
    WingManUserDataStruct.UID = value.UID or 0
    WingManUserDataStruct.RPScore = value.RPScore or 0
    WingManUserDataStruct.Name = value.Name or ""
    WingManUserDataStruct.SkinId = value.SkinId or 0
    if value.UnPassInfo then
      WingManUserDataStruct.UnPassInfo = value.UnPassInfo
    end
    self.WingManUserData:Add(WingManUserDataStruct)
  end
end
function WingPlaneComponent:DSInit()
  if not self:IsOpen() then
    print(bWriteLog and "WingPlaneComponent:ReceiveBeginPlay not self:IsOpen()")
    return
  end
  if UseTestData then
    self.UserData = self:GetTestWingData()
  elseif self:IsRevivePlane() then
    self.UserData = self:GetTeammateWingData()
  else
    self.UserData = self:GetWingData()
  end
  if #self.UserData > 0 then
    if self.UserData[1] and self.UserData[1].UnPassInfo and self.UserData[1].UnPassInfo.mainSwitch == false then
      print(bWriteLog and "WingPlaneComponent ReceiveBeginPlay self.UserData.UnPassInfo.mainSwitch == false ")
      return
    end
    self:SetWingManUserData(self.UserData)
    if self.WingManUserData:Get(0) then
      print(bWriteLog and "WingPlaneComponent:DSInit:" .. tostring(self.WingManUserData:Get(0).SkinId))
    end
    self.XSuitIconFirst = self.UserData[1].XSuitIconId
    print(bWriteLog and "WingPlaneComponent:DSInit SkinId" .. tostring(self.WingManUserData and self.WingManUserData.SkinId))
    if self:IsRevivePlane() ~= true and self.UserData[2] then
      self.XSuitIconSecond = self.UserData[2].XSuitIconId
    end
  end
end
function WingPlaneComponent:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "XSuitIconFirst",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "XSuitIconSecond",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function WingPlaneComponent:OnRep_XSuitIconFirst()
  print(bWriteLog and " WingPlaneComponent:OnRep_XSuitIconFirst " .. self.XSuitIconFirst)
  if self:IsRevivePlane() then
    return
  end
  if self.bHasSetWingInfo == false then
    self:SetWingInfo(self.WingManUserData, true)
  end
end
function WingPlaneComponent:OnRep_XSuitIconSecond()
  print(bWriteLog and " WingPlaneComponent:OnRep_XSuitIconSecond " .. self.XSuitIconSecond)
end
function WingPlaneComponent:IsOpen()
  if UseTestData then
    return true
  end
  if not Game:CheckDSSwitchOpen(DSSwitch) then
    print(bWriteLog and "WingPlaneComponent not Game:CheckDSSwitchOpen")
    return false
  end
  self.uGameState = CGameState
  local GameModeType = self.uGameState.GameModeType
  if slua.isValid(self.uGameState) and GameModeType then
    print(bWriteLog and "WingPlaneComponent:IsOpen() self.uGameState", self.uGameState)
    local EGameModeType = import("EGameModeType")
    if GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.ECreativeModeGameMode then
      return true
    end
  end
  return false
end
local SetUserData = function(Target, UID, playerInfo)
  Target.  Target.RPScore = playerInfo.upass_info.acc_score
  Target.Name = playerInfo.name
  Target.SkinId = playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear].wingman_skin or 0
  local XSuitAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitAvatarDataUtil")
  Target.XSuitIconId = XSuitAvatarDataUtil:GetValidXSuitIconId(UID)
end
local HandleAliasInfo = function(tInfo)
  local AliasInfo = ServerPlayerDataMgr.HandleAliasInfo(tInfo)
  return AliasInfo
end
local HandleUpassInfo = function(WingData, tInfo)
  local UpassInfo = {}
  if tInfo.upass_info then
    UpassInfo.PlayerName = tInfo.name
    if tInfo.upass_info.is_buy == 0 then
      UpassInfo.isBuy = false
    else
      UpassInfo.isBuy = true
    end
    UpassInfo.updateTime = tInfo.upass_info.acc_update_time
    UpassInfo.upassLevel = tInfo.upass_info.level
    UpassInfo.nUpassPrimePlusCard = tInfo.upass_info.upass_prime_plus_card or 0
    UpassInfo.upassScore = tInfo.upass_info.acc_score
    UpassInfo.mainSwitch = tInfo.upass_info.main_switch
    if tInfo.upass_info.switch then
      UpassInfo.isBattleTitle = tInfo.upass_info.switch.battle_title
      UpassInfo.isUI = tInfo.upass_info.switch.ui
      UpassInfo.battleShow = tInfo.upass_info.switch.battle_show
      UpassInfo.upassKeepBuy = tInfo.upass_info.upass_keep_buy or 0
      UpassInfo.upassCurValue = tInfo.upass_info.cur_value or 0
      UpassInfo.pass_type = tInfo.upass_info.pass_type or 0
    end
    UpassInfo.iconUrl = tInfo.upass_info.pic_url
    UpassInfo.planeAvatarId = WingData.SkinId
  end
  UpassInfo.AliasInfo = HandleAliasInfo(tInfo)
  UpassInfo.Nation = tInfo.nation
  log_tree("WingPlaneComponent UpassInfo ", UpassInfo)
  log_tree("WingPlaneComponent UpassInfo ", tInfo)
  return UpassInfo
end
function WingPlaneComponent:ShowUnpass(data)
  if data and data.upass_info and data.upass_info.switch then
    return data.upass_info.switch.battle_show
  end
  return false
end
function WingPlaneComponent:IsRevivePlane()
  if self.bIsRevivePlane == nil and self.GetOwner then
    local Plane = self:GetOwner()
    if Plane and slua.isValid(Plane) then
      local RevivePlane = import("/Game/BluePrints/Core/RevivalGameMode/BP_RevivalAirplane.BP_RevivalAirplane_C")
      if Game:IsClassOf(Plane, RevivePlane) then
        self.bIsRevivePlane = true
      else
        self.bIsRevivePlane = false
      end
    end
  end
  print(bWriteLog and "WingPlaneComponent:IsRevivePlane, self.bIsRevivePlane = " .. tostring(self.bIsRevivePlane))
  return self.bIsRevivePlane
end
function WingPlaneComponent:IsTheSamePlane(TeammateController, Controller)
  local Result = false
  if TeammateController:IsSpectator() then
    return Result
  end
  if Controller.ThePlane == nil or slua.isValid(Controller.ThePlane) == false then
    Result = true
  end
  if Result == false and TeammateController.ThePlane == Controller.ThePlane then
    Result = true
  end
  return Result
end
function WingPlaneComponent:GetTeammateWingData()
  local UserDatas = ServerPlayerDataMgr.GetAllPlayersInfo()
  local TempUsers = {}
  local ReviverUID
  local Plane = self:GetOwnerActor()
  local ReviverPlayer = Plane.MyFlyingData and Plane.MyFlyingData.CurPlayers
  local ReviverPlayerNum = ReviverPlayer:Num()
  if 0 < ReviverPlayerNum then
    local Controller = ReviverPlayer:Get(0)
    if Controller and slua.isValid(Controller) then
      ReviverUID = Controller.PlayerState.UID
      local TeamID = Controller.TeamID
      for UID, playerInfo in pairs(UserDatas) do
        local TeammateController = Game:GetPlayerControllerByUID(UID)
        if playerInfo.teamid == TeamID and (UID == ReviverUID or TeammateController and TeammateController:IsInPlane() and self:IsTheSamePlane(TeammateController, Controller)) and self:FilterWhoCanShowWingPlane(playerInfo) then
          local TempUser = {}
          SetUserData(TempUser, UID, playerInfo)
          table.insert(TempUsers, TempUser)
        end
      end
    end
  end
  local Teammates = {}
  for k, v in pairs(TempUsers) do
    v.UnPassInfo = HandleUpassInfo(v, UserDatas[v.UID])
    table.insert(Teammates, v)
  end
  print(bWriteLog and "WingPlaneComponent:GetTeammateWingData, ReviverUID = " .. tostring(ReviverUID))
  if 1 < #Teammates then
    log_tree("WingPlaneComponent:GetTeammateWingData, before Sort Teammates = ", Teammates)
    table.sort(Teammates, function(a, b)
      if a.UID == ReviverUID and b.UID ~= ReviverUID then
        return true
      else
        return false
      end
    end)
    log_tree("WingPlaneComponent:GetTeammateWingData, after Sort Teammates = ", Teammates)
  end
  if next(Teammates) then
    print(bWriteLog and "WingPlaneComponent:GetTeammateWingData, #Teammates = " .. tostring(#Teammates))
  else
    print(bWriteLog and "WingPlaneComponent:GetTeammateWingData, Can't believe it! ReviverPlayerNum = " .. tostring(ReviverPlayerNum))
  end
  return Teammates
end
function WingPlaneComponent:FilterWhoCanShowWingPlane(playerInfo)
  local Show = false
  if playerInfo.is_robot == false and self:ShowUnpass(playerInfo) and playerInfo.use_rolewear and playerInfo.all_knapsack_ext_info then
    local wingman_skin = playerInfo.all_knapsack_ext_info[playerInfo.use_rolewear].wingman_skin
    if 0 < wingman_skin and IsHighLevelHelicoper(wingman_skin) then
      Show = true
    end
  end
  print(bWriteLog and "WingPlaneComponent:FilterWhoCanShowWingPlane, name = " .. tostring(playerInfo.name) .. ", Show = " .. tostring(Show))
  return Show
end
function WingPlaneComponent:GetWingData()
  print(bWriteLog and "WingPlaneComponent:GetWingData")
  local top1User = {
    UID = 0,
    RPScore = -1,
    Name = "",
    SkinId = 0,
    XSuitIconId = 0
  }
  local top2User = {
    UID = 0,
    RPScore = -1,
    Name = "",
    SkinId = 0,
    XSuitIconId = 0
  }
  local UserDatas = ServerPlayerDataMgr.GetAllPlayersInfo()
  for UID, playerInfo in pairs(UserDatas) do
    if self:FilterWhoCanShowWingPlane(playerInfo) and playerInfo.upass_info.acc_score > top2User.RPScore then
      if playerInfo.upass_info.acc_score > top1User.RPScore then
        top2User = DeepCopy(top1User)
        SetUserData(top1User, UID, playerInfo)
      else
        SetUserData(top2User, UID, playerInfo)
      end
    end
  end
  local UserData = {}
  if top1User.UID > 0 then
    top1User.UnPassInfo = HandleUpassInfo(top1User, UserDatas[top1User.UID])
    table.insert(UserData, top1User)
  end
  if top2User.UID > 0 then
    top2User.UnPassInfo = HandleUpassInfo(top2User, UserDatas[top2User.UID])
    table.insert(UserData, top2User)
  end
  log_tree("WingPlaneComponent:GetWingData() UserData", UserData)
  return UserData
end
local GetTestUnPassData = function()
  local UpassInfo = {}
  UpassInfo.isBuy = true
  UpassInfo.PlayerName = "TestUnPassData"
  UpassInfo.updateTime = 0
  UpassInfo.upassLevel = 10
  UpassInfo.nUpassPrimePlusCard = 0
  UpassInfo.upassScore = 20
  UpassInfo.mainSwitch = true
  UpassInfo.planeAvatarId = 181101001
  UpassInfo.iconUrl = nil
  UpassInfo.AliasInfo = {}
  UpassInfo.AliasInfo.aliasID = 1
  UpassInfo.AliasInfo.aliasTitle = ""
  UpassInfo.AliasInfo.aliasNation = 1
  UpassInfo.AliasInfo.aliasRank = 1
  UpassInfo.AliasInfo.aliasRankID = 1
  return UpassInfo
end
local GetTestUnPassData2 = function()
  local UpassInfo = {}
  UpassInfo.isBuy = true
  UpassInfo.PlayerName = "2"
  UpassInfo.updateTime = 0
  UpassInfo.upassLevel = 12
  UpassInfo.nUpassPrimePlusCard = 0
  UpassInfo.upassScore = 20
  UpassInfo.mainSwitch = true
  UpassInfo.planeAvatarId = 181101001
  UpassInfo.iconUrl = nil
  UpassInfo.AliasInfo = {}
  UpassInfo.AliasInfo.aliasID = 1
  UpassInfo.AliasInfo.aliasTitle = ""
  UpassInfo.AliasInfo.aliasNation = 1
  UpassInfo.AliasInfo.aliasRank = 1
  UpassInfo.AliasInfo.aliasRankID = 1
  return UpassInfo
end
function WingPlaneComponent:GetTestWingData()
  local top1User = {
    UID = 2,
    RPScore = 3,
    Name = "2",
    SkinId = 181101001,
    UnPassInfo = GetTestUnPassData(),
    XSuitIconId = 9
  }
  local top2User = {
    UID = 3,
    RPScore = 2,
    Name = "3",
    SkinId = 181101001,
    UnPassInfo = GetTestUnPassData2(),
    XSuitIconId = 9
  }
  local UserData = {}
  if top1User.UID > 0 then
    table.insert(UserData, top1User)
  end
  if top2User.UID > 0 then
    table.insert(UserData, top2User)
  end
  return UserData
end
function WingPlaneComponent:OnRep_WingManUserData()
  print(bWriteLog and "WingPlaneComponent OnRep_WingManUserData WingManUserData Num", self.WingManUserData:Num())
  if self.WingManUserData:Num() <= 0 then
    return
  end
  self:RemoveOthersByMyself()
  if self.WingManUserData:Num() <= 0 then
    return
  end
  self:AttachSkeletMeshComp()
  self:AttachWingManAvatarComp()
  self:PreSetUserWingManSkin(self.WingManUserData)
  if self:IsRevivePlane() then
    return
  end
  self.ShowInfoCardTimer = self:AddGameTimer(0.5, true, function()
    self:SetWingInfo(self.WingManUserData)
  end)
  self:SetWingInfoCardMoveWithMesh()
end
function WingPlaneComponent:RemoveOthersByMyself()
  if self:IsRevivePlane() then
    local Plane = self:GetOwnerActor()
    local UGameplayStatics = import("GameplayStatics")
    local uSelfController = UGameplayStatics.GetPlayerController(Plane, 0)
    if uSelfController and slua.isValid(uSelfController) then
      local uSelfPlayerState = uSelfController.PlayerState
      if uSelfPlayerState and slua.isValid(uSelfPlayerState) then
        local BeforeCount = self.WingManUserData:Num()
        local FlyersUID = {}
        table.insert(FlyersUID, uSelfPlayerState.UID)
        local bSpectator = false
        if uSelfController:IsSpectator() or uSelfController:IsInPetSpectator() then
          print(bWriteLog and "WingPlaneComponent:RemoveOthersByMyself, bSpectator = true")
          bSpectator = true
          FlyersUID = self:GetCharactersInPlane()
        else
          print(bWriteLog and "WingPlaneComponent:RemoveOthersByMyself, bSpectator = false, LiveState = " .. tostring(uSelfPlayerState.LiveState))
        end
        self:PrintWingManUserData(true, FlyersUID)
        if uSelfController:IsInPlane() or bSpectator then
          if 2 < BeforeCount then
            local Temp = self.WingManUserData:Get(1)
            if Temp and slua.isValid(Temp) then
              if self:IsOneOfFlyers(Temp.UID, FlyersUID) then
                for j = self.WingManUserData:Num() - 1, 2, -1 do
                  self.WingManUserData:Remove(j)
                end
              else
                self.WingManUserData:Remove(1)
                if self.WingManUserData:Num() > 2 then
                  local Temp1 = self.WingManUserData:Get(1)
                  if Temp1 and slua.isValid(Temp1) then
                    if self:IsOneOfFlyers(Temp1.UID, FlyersUID) then
                      self.WingManUserData:Remove(2)
                    else
                      self.WingManUserData:Remove(1)
                    end
                  end
                end
              end
            end
          end
        else
          for i = self.WingManUserData:Num() - 1, 0, -1 do
            self.WingManUserData:Remove(i)
          end
        end
        self:PrintWingManUserData(false, FlyersUID)
        local AfterCount = self.WingManUserData:Num()
        if 1 < AfterCount and bSpectator == false then
          local Temp = self.WingManUserData:Get(1)
          if Temp and slua.isValid(Temp) and self:IsOneOfFlyers(Temp.UID, FlyersUID) then
            self.XSuitIconSecond = uSelfPlayerState.XSuitIconId
          end
        end
        print(bWriteLog and "WingPlaneComponent:RemoveOthersByMyself, BeforeCount = " .. tostring(BeforeCount) .. ", AfterCount = " .. tostring(AfterCount))
      else
        for i = self.WingManUserData:Num() - 1, 0, -1 do
          self.WingManUserData:Remove(i)
        end
        print(bWriteLog and "WingPlaneComponent:RemoveOthersByMyself, uSelfPlayerState = " .. tostring(uSelfPlayerState))
      end
    else
      for i = self.WingManUserData:Num() - 1, 0, -1 do
        self.WingManUserData:Remove(i)
      end
      print(bWriteLog and "WingPlaneComponent:RemoveOthersByMyself, uSelfController = " .. tostring(uSelfController))
    end
  end
end
function WingPlaneComponent:GetCharactersInPlane()
  local CharactersUID = {}
  if self:IsRevivePlane() ~= true then
    print(bWriteLog and "WingPlaneComponent:GetCharactersInPlane, return immediately because not revive plane")
    return CharactersUID
  end
  local Plane = self:GetOwnerActor()
  if Plane and Plane.RootComponent and slua.isValid(Plane.RootComponent) then
    local ChildComponent = Plane.RootComponent.AttachChildren or {}
    local CharacterClass = import("STExtraPlayerCharacter")
    for k, v in pairs(ChildComponent) do
      if v and slua.isValid(v) then
        local ChildActor = v:GetOwner()
        if ChildActor and slua.isValid(ChildActor) and Game:IsClassOf(ChildActor, CharacterClass) then
          local uPlayerState = ChildActor.STExtraPlayerState
          if uPlayerState and slua.isValid(uPlayerState) then
            table.insert(CharactersUID, uPlayerState.UID)
            print(bWriteLog and "WingPlaneComponent:GetCharactersInPlane, PlayerName = " .. tostring(ChildActor:GetPlayerNameSafety()))
          else
            print(bWriteLog and "WingPlaneComponent:GetCharactersInPlane, uPlayerState = " .. tostring(uPlayerState))
          end
        end
      end
    end
  end
  print(bWriteLog and "WingPlaneComponent:GetCharactersInPlane, Num = " .. tostring(#CharactersUID))
  return CharactersUID
end
function WingPlaneComponent:IsOneOfFlyers(UID, FlyersUID)
  if FlyersUID == nil or #FlyersUID <= 0 then
    return false
  end
  for k, v in ipairs(FlyersUID) do
    if v == UID then
      return true
    end
  end
  return false
end
function WingPlaneComponent:PrintWingManUserData(Before, FlyersUID)
  print(bWriteLog and "WingPlaneComponent:PrintWingManUserData, #FlyersUID = " .. tostring(#FlyersUID) .. ", Before = " .. tostring(Before))
  for i = 0, self.WingManUserData:Num() - 1 do
    local Temp = self.WingManUserData:Get(i)
    if Temp and slua.isValid(Temp) then
      print(bWriteLog and "WingPlaneComponent:PrintWingManUserData, i = " .. tostring(i) .. ", name = " .. tostring(Temp.Name) .. ", UID = " .. tostring(Temp.UID))
    end
  end
end
function WingPlaneComponent:GetOwnerActor()
  if not slua.isValid(self.PlaneCharacter) then
    self.PlaneCharacter = self:GetOwner()
  end
  return self.PlaneCharacter
end
function WingPlaneComponent:GetWingPlaneComp1()
  if not slua.isValid(self.WingPlaneComp1) then
    local PlaneCharacter = self:GetOwnerActor()
    if not slua.isValid(PlaneCharacter) then
      print(bWriteLog and "WingPlaneComponent PlaneCharacter is not Valid")
      return
    end
    local SkeletalMesh = import("/Script/Engine.SkeletalMeshComponent")
    local comp = PlaneCharacter:GetComponentsByTag(SkeletalMesh, "WingComp1")
    if comp and comp:Num() > 0 then
      self.WingPlaneComp1 = comp:Get(0)
    end
  end
  return self.WingPlaneComp1
end
function WingPlaneComponent:GetWingPlaneComp2()
  if not slua.isValid(self.WingPlaneComp2) then
    local PlaneCharacter = self:GetOwnerActor()
    if not slua.isValid(PlaneCharacter) then
      print(bWriteLog and "WingPlaneComponent PlaneCharacter is not Valid")
      return
    end
    local SkeletalMesh = import("/Script/Engine.SkeletalMeshComponent")
    local comp = PlaneCharacter:GetComponentsByTag(SkeletalMesh, "WingComp2")
    if comp and comp:Num() > 0 then
      self.WingPlaneComp2 = comp:Get(0)
    end
  end
  return self.WingPlaneComp2
end
function WingPlaneComponent:GetWingAvatarComp1()
  if not slua.isValid(self.WingAvatarComp1) then
    local PlaneCharacter = self:GetOwnerActor()
    if not slua.isValid(PlaneCharacter) then
      print(bWriteLog and "WingPlaneComponent PlaneCharacter is not Valid")
      return
    end
    local WingmanAvatarComp = slua.loadClass("/Game/Arts_PlayerBluePrints/Wingman/WingmanAvatarComp_BP.WingmanAvatarComp_BP")
    local comp = PlaneCharacter:GetComponentsByTag(WingmanAvatarComp, "WingAvatarComp1")
    if comp and comp:Num() > 0 then
      self.WingAvatarComp1 = comp:Get(0)
    end
  end
  return self.WingAvatarComp1
end
function WingPlaneComponent:GetWingAvatarComp2()
  if not slua.isValid(self.WingAvatarComp2) then
    local PlaneCharacter = self:GetOwnerActor()
    if not slua.isValid(PlaneCharacter) then
      print(bWriteLog and "WingPlaneComponent PlaneCharacter is not Valid")
      return
    end
    local WingmanAvatarComp = slua.loadClass("/Game/Arts_PlayerBluePrints/Wingman/WingmanAvatarComp_BP.WingmanAvatarComp_BP")
    local comp = PlaneCharacter:GetComponentsByTag(WingmanAvatarComp, "WingAvatarComp2")
    if comp and comp:Num() > 0 then
      self.WingAvatarComp2 = comp:Get(0)
    end
  end
  return self.WingAvatarComp2
end
function WingPlaneComponent:AttachSkeletMeshComp()
  if not slua.isValid(self:GetWingPlaneComp1()) then
    self:AttachMeshComp(self:GetOwnerActor(), 1)
  end
  if not slua.isValid(self:GetWingPlaneComp2()) then
    self:AttachMeshComp(self:GetOwnerActor(), 2)
  end
end
function WingPlaneComponent:AttachMeshComp(Target, number)
  log(bWriteLog and "WingPlaneComponent:AttachMeshComp")
  if not slua.isValid(Target) then
    log(bWriteLog and "WingPlaneComponent:AttachMeshComp data is not valid Target")
    return
  end
  if 2 < number then
    log(bWriteLog and "AttachMeshComp data is not valid number = " .. tostring(number))
    return
  end
  local SkeletalMeshComponent = import("/Script/Engine.SkeletalMeshComponent")
  local EAttachmentRule = import("EAttachmentRule")
  local WingMesh = Game:AddComponent(SkeletalMeshComponent, Target, "WingComp" .. tostring(number))
  if not slua.isValid(WingMesh) then
    log(bWriteLog and "WingPlaneComponent:AttachMeshComp WingMesh: not is valid ")
    return
  end
  WingMesh.ComponentTags:Add("WingComp" .. tostring(number))
  if Target and Target.bForPlaneShow then
    local TempAttachComp = Target.GetWingmanAttachComp and Target:GetWingmanAttachComp(number)
    if slua.isValid(TempAttachComp) then
      WingMesh:K2_AttachToComponent(TempAttachComp, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
      return
    end
  end
  if Target then
    local StaticMesh = Target.StaticMesh or Target.STCustomMesh
    if StaticMesh and slua.isValid(StaticMesh) then
      WingMesh:K2_AttachToComponent(StaticMesh, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
      WingMesh:K2_SetRelativeLocation(WingManRelativeLocation[number], false, nil, false)
    end
  end
end
function WingPlaneComponent:AttachWingManAvatarComp()
  log(bWriteLog and "WingPlaneComponent:AttachWingManAvatarComp ")
  local WingmanAvatarComp = slua.loadClass("/Game/Arts_PlayerBluePrints/Wingman/WingmanAvatarComp_BP.WingmanAvatarComp_BP")
  local owner = self:GetOwnerActor()
  if not slua.isValid(owner) then
    return
  end
  if not slua.isValid(self:GetWingAvatarComp1()) then
    self.WingAvatarComp1 = Game:AddComponent(WingmanAvatarComp, owner, "WingmanAvatarComp_BP1")
    if self.WingAvatarComp1 then
      self.WingAvatarComp1.ComponentTags:Add("WingAvatarComp1")
      self.WingAvatarComp1:SetUseLobbyAnim(true)
    end
  end
  if not slua.isValid(self:GetWingAvatarComp2()) then
    self.WingAvatarComp2 = Game:AddComponent(WingmanAvatarComp, owner, "WingmanAvatarComp_BP2")
    if self.WingAvatarComp2 then
      self.WingAvatarComp2.ComponentTags:Add("WingAvatarComp2")
      self.WingAvatarComp2:SetUseLobbyAnim(true)
    end
  end
end
function WingPlaneComponent:PreSetUserWingManSkin(WingManUserData)
  if not slua.isValid(self:GetOwnerActor()) then
    log(bWriteLog and "WingPlaneComponent:PreSetUserWingManSkin GetOwnerActor is not Valid")
    return
  end
  local User1 = WingManUserData:Get(0)
  if not User1 then
    log(bWriteLog and "WingPlaneComponent:PreSetUserWingManSkin User1 is nil")
    log_tree("WingPlaneComponent:PreSetUserWingManSkin WingManUserData", WingManUserData)
    return
  end
  if WingManUserData:Num() == 1 then
    self:SetUserWingManSkin(1, User1.SkinId)
    self:SetUserWingManSkin(2, User1.SkinId)
  elseif WingManUserData:Num() == 2 then
    self:SetUserWingManSkin(1, User1.SkinId)
    local User2 = WingManUserData:Get(1)
    if not User2 then
      log(bWriteLog and "WingPlaneComponent:PreSetUserWingManSkin User2 is nil")
      log_tree("WingPlaneComponent:PreSetUserWingManSkin WingManUserData", WingManUserData)
      return
    end
    self:SetUserWingManSkin(2, User2.SkinId)
  end
end
function WingPlaneComponent:SetUserWingManSkin(WingManNumber, SkinId)
  if 3 < WingManNumber or WingManNumber < 1 then
    log(bWriteLog and "WingPlaneComponent:SetUserWingManSkin WingManNumber = " .. tostring(WingManNumber))
    return
  end
  print(bWriteLog and "WingPlaneComponent:SetUserWingManSkin WingManNumber", WingManNumber)
  print(bWriteLog and "WingPlaneComponent:SetUserWingManSkin SkinId", SkinId)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {SkinId})
  local _alreadyDownload = dowloadState == ENUM_DownloadState.Done
  if not _alreadyDownload then
    log(bWriteLog and "WingPlaneComponent:SetUserWingManSkin not _alreadyDownload SkinId" .. tostring(SkinId))
    local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
    if RecommendHandler then
      log(bWriteLog and "WingPlaneComponent:SetUserWingManSkin Record Not Download SkinId" .. tostring(SkinId))
      RecommendHandler.AddBattleItem(SkinId)
    end
    SkinId = DefaultSkinID
  end
  SkinId = SkinId or DefaultSkinID
  local MeshComp, WingmanAvatarComp_BP
  if WingManNumber == 1 then
    MeshComp = self:GetWingPlaneComp1()
    WingmanAvatarComp_BP = self:GetWingAvatarComp1()
  elseif WingManNumber == 2 then
    MeshComp = self:GetWingPlaneComp2()
    WingmanAvatarComp_BP = self:GetWingAvatarComp2()
  end
  if not slua.isValid(MeshComp) then
    log(bWriteLog and "WingPlaneComponent:SetUserWingManSkin MeshComp2 is not Valid")
    return
  end
  if not slua.isValid(WingmanAvatarComp_BP) then
    log(bWriteLog and "WingPlaneComponent:SetUserWingManSkin WingmanAvatarComp_BP2 is not Valid")
    return
  end
  WingmanAvatarComp_BP.WingmanMesh = MeshComp
  WingmanAvatarComp_BP:PreChangeWingmanAvatar(SkinId)
end
function WingPlaneComponent:GetBattlePass02UI()
  if self:IsRevivePlane() then
    return nil
  else
    log(bWriteLog and "WingPlaneComponent:GetBattlePass02UI, return nil")
    return nil
  end
end
function WingPlaneComponent:OnHandleParachuteStateChanged(LastParachuteState, ParachuteState)
  if not slua.isValid(self.Object) then
    return
  end
  if ParachuteState ~= LastParachuteState then
    log(bWriteLog and "WingPlaneComponent:OnHandleParachuteStateChanged, ParachuteState = " .. tostring(ParachuteState))
    local EParachuteState = import("EParachuteState")
    if ParachuteState == EParachuteState.PS_FreeFall or ParachuteState == EParachuteState.PS_Opening then
      self:TryRemoveShowWingTimer(self.WingManUserData)
    end
  end
end
function WingPlaneComponent:TryRemoveShowWingTimer(WingManUserData)
  local Result = false
  if WingManUserData == nil or WingManUserData:Num() <= 0 then
    Result = true
  end
  if Result == false and self.PlayerCanJump then
    Result = true
  end
  if Result == false then
    local UIUtil = require("client.common.ui_util")
    local UGameplayStatics = import("GameplayStatics")
    local uPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
    if uPlayerController and slua.isValid(uPlayerController) and (uPlayerController.bCanJump or uPlayerController.GetThePlane == nil or uPlayerController:GetThePlane() == nil) then
      Result = true
    end
  end
  if Result == true then
    if self.ShowInfoCardTimer then
      self:RemoveGameTimer(self.ShowInfoCardTimer)
      self.ShowInfoCardTimer = nil
    end
    if self.MovePosTimer then
      self:RemoveTimer(self.MovePosTimer)
      self.MovePosTimer = nil
    end
    if UIManager.UI_Config_InGame.BattlePass02 then
      local Widget = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePass02)
      if Widget then
        Widget:SetWingManPlaneVisible(false)
        if self:IsRevivePlane() then
          Widget:CloseSelf()
        end
      end
    end
  end
  log(bWriteLog and "WingPlaneComponent:TryRemoveShowWingTimer, Result = " .. tostring(Result))
  return Result
end
function WingPlaneComponent:CloseUIWhenRevivePlane()
  if self:IsRevivePlane() then
    if self.ShowInfoCardTimer then
      self:RemoveGameTimer(self.ShowInfoCardTimer)
      self.ShowInfoCardTimer = nil
    end
    if self.MovePosTimer then
      self:RemoveTimer(self.MovePosTimer)
      self.MovePosTimer = nil
    end
    if UIManager.UI_Config_InGame.BattlePass02 then
      local Widget = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePass02)
      if Widget then
        Widget:CloseSelf()
        log(bWriteLog and "WingPlaneComponent:CloseUIWhenRevivePlane")
      end
    end
  end
end
function WingPlaneComponent:SetWingInfo(WingManUserData, bFromRep)
  log(bWriteLog and "WingPlaneComponent:SetWingInfo WingManUserData")
  if self:TryRemoveShowWingTimer(WingManUserData) then
    return
  end
  self:CloseUIWhenRevivePlane()
  if not UIManager.UI_Config_InGame.BattlePass02 then
    return
  end
  local Widget = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePass02)
  if bFromRep then
    if not Widget then
      log(bWriteLog and "WingPlaneComponent:SetWingInfo Widget is not Valid")
      return
    end
    local currentVisible = Widget:GetWingManPlaneVisible()
    if currentVisible == false then
      log(bWriteLog and "WingPlaneComponent:SetWingInfo currentVisible is false")
      return
    end
  end
  if not Widget then
    Widget = self:GetBattlePass02UI()
    return
  end
  if not Widget then
    log(bWriteLog and "WingPlaneComponent:SetWingInfo Widget is not Valid")
    return
  end
  if self:IsRevivePlane() then
    if Widget:IsAsyncLoading() then
      log(bWriteLog and "WingPlaneComponent:SetWingInfo, _isAsyncLoading")
      return
    end
    Widget:SetShowBecauseRevive()
  end
  if not WingManUserData or not WingManUserData:Get(0) then
    return
  end
  log(bWriteLog and "WingPlaneComponent:SetWingInfo WingManUserData:Num()" .. tostring(WingManUserData:Num()))
  if self.ShowInfoCardTimer then
    log(bWriteLog and "WingPlaneComponent:SetWingInfo Remove ShowInfoCardTimer")
    self:RemoveGameTimer(self.ShowInfoCardTimer)
    self.ShowInfoCardTimer = nil
  end
  if self.PlayerCanJump then
    log(bWriteLog and "WingPlaneComponent self.PlayerCanJump")
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local UPlayerController = UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
  log(bWriteLog and "WingPlaneComponent UPlayerController.bCanJump" .. tostring(UPlayerController.bCanJump))
  if slua.isValid(UPlayerController) and UPlayerController.bCanJump then
    return
  end
  self.bHasSetWingInfo = true
  if WingManUserData:Num() == 1 then
    Widget:SetWingManInfo(1, WingManUserData:Get(0).UnPassInfo, self.XSuitIconFirst)
    Widget:SetWingManInfo(2, WingManUserData:Get(0).UnPassInfo, self.XSuitIconFirst)
  elseif WingManUserData:Num() == 2 then
    if not WingManUserData:Get(1) then
      return
    end
    Widget:SetWingManInfo(1, WingManUserData:Get(0).UnPassInfo, self.XSuitIconFirst)
    Widget:SetWingManInfo(2, WingManUserData:Get(1).UnPassInfo, self.XSuitIconSecond)
  end
  Widget:SetWingManPlaneVisible(true)
  if self:IsRevivePlane() then
    Widget:SetVisibilityForRevive()
    Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function WingPlaneComponent:SetWingInfoCardMoveWithMesh()
  log(bWriteLog and "WingPlaneComponent:SetWingInfoCardMoveWithMesh")
  self.bMoveInfoCard = true
  self.MovePosTimer = self:AddTimer(0, function()
    while true do
      self:SetInfoCardPosition()
      coroutine.yield(0.02)
    end
  end)
end
function WingPlaneComponent:SetInfoCardPosition()
  if not UIManager.UI_Config_InGame.BattlePass02 then
    return
  end
  local Widget = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePass02)
  if not Widget then
    log(bWriteLog and "WingPlaneComponent:SetInfoCardPosition Widget is not Valid")
    return
  end
  local WingManComp1 = self:GetWingPlaneComp1()
  if not slua.isValid(WingManComp1) then
    log(bWriteLog and "WingPlaneComponent:SetInfoCardPosition WingManComp1 is not Valid")
    return
  end
  local wingPlaneLoc, ScreenLocation1
  wingPlaneLoc = WingManComp1:K2_GetComponentLocation()
  if wingPlaneLoc then
    local UIUtil = require("client.common.ui_util")
    ScreenLocation1 = UIUtil.ProjectWorldLocationToWidgetPosition(wingPlaneLoc.X, wingPlaneLoc.Y, wingPlaneLoc.Z - 50)
    Widget:SetWinManPanelPos(1, ScreenLocation1)
  end
  local WingManComp2 = self:GetWingPlaneComp2()
  if not slua.isValid(WingManComp2) then
    log(bWriteLog and "WingPlaneComponent:SetInfoCardPosition WingManComp2 is not Valid")
    return
  end
  wingPlaneLoc = WingManComp2:K2_GetComponentLocation()
  if wingPlaneLoc then
    local UIUtil = require("client.common.ui_util")
    ScreenLocation1 = UIUtil.ProjectWorldLocationToWidgetPosition(wingPlaneLoc.X, wingPlaneLoc.Y, wingPlaneLoc.Z - 50)
    Widget:SetWinManPanelPos(2, ScreenLocation1)
  end
end
function WingPlaneComponent:OnPlayerCanJump()
  log(bWriteLog and "WingPlaneComponent:OnPlayerCanJump ")
  self.bMoveInfoCard = false
  self.PlayerCanJump = true
  if self.MovePosTimer then
    log(bWriteLog and "WingPlaneComponent:OnPlayerCanJump RemoveTimer")
    self:RemoveTimer(self.MovePosTimer)
  end
  self.MovePosTimer = nil
  if not UIManager.UI_Config_InGame.BattlePass02 then
    log(bWriteLog and "WingPlaneComponent:OnPlayerCanJump BattlePass02 is not Valid")
    return
  end
  local Widget = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePass02)
  if not Widget then
    log(bWriteLog and "WingPlaneComponent:OnPlayerCanJump Widget is not Valid")
    return
  end
  Widget:SetWingManPlaneVisible(false)
  if self:IsRevivePlane() then
    Widget:CloseSelf()
  end
end
function WingPlaneComponent:OnEgyptPlaneShow(bStop)
  print(bWriteLog and "WingPlaneComponent:OnEgyptPlaneShow bStop:", bStop)
  local MeshComp1 = self:GetWingPlaneComp1()
  if slua.isValid(MeshComp1) then
    if bStop then
      MeshComp1:Stop()
      MeshComp1.bPauseAnims = true
    else
      MeshComp1.bPauseAnims = false
      MeshComp1:Play(true)
    end
  end
  local MeshComp2 = self:GetWingPlaneComp2()
  if slua.isValid(MeshComp2) then
    if bStop then
      MeshComp2:Stop()
      MeshComp2.bPauseAnims = true
    else
      MeshComp2.bPauseAnims = false
      MeshComp2:Play(true)
    end
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CWingPlaneComponent = class(CActorComponentBase, nil, WingPlaneComponent)
return CWingPlaneComponent
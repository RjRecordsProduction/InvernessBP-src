local VehicleUserComponent = {
  ServerRPC = {}
}
VehicleUserComponent.ServerRPC.RPC_Server_ReqAgentMove = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
VehicleUserComponent.ServerRPC.RPC_Server_TriggerVehicleSkillServer = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Float
  }
}
VehicleUserComponent.ServerRPC.RPC_Server_StopVehicleSkillServer = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function VehicleUserComponent:ctor()
  self.ControllerData = {PlayerController = nil, PlayerKey = nil}
  self.CharacterData = {
    Character = nil,
    PlayerKey = nil,
    TargetSeatIndex = nil,
    CurrentSeatIndex = nil
  }
  self.VehicleData = {Vehicle = nil}
end
function VehicleUserComponent:_PostConstruct()
  VehicleUserComponent.__super._PostConstruct(self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_PLAYERKEY_CHANGE, self.OnPlayerControllerKeyChange, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_ENDPLAY, self.OnVehicleEndPlay, self)
  end
end
function VehicleUserComponent:ReceiveBeginPlay()
  self.Super:ReceiveBeginPlay()
  self.bUsingNewVehicle = true
  self.bInVehicleAtomicOperation = false
  print(bWriteLog and "VehicleUserComponent:ReceiveBeginPlay")
  if Client then
    self:ClientExecuteEnterVehicle()
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      self.CarMusicSwitchHandle = SettingSubsystem:RegisterUserSettingsDelegate_Int("CarMusicSwitch", function(CarMusicSwitch)
        self.bPlayMusicEnabled = CarMusicSwitch
      end)
      if self.CarMusicSwitchHandle then
        SettingSubsystem:UnregisterUserSettingDelegate(self.CarMusicSwitchHandle)
        self.CarMusicSwitchHandle = nil
      end
    end
  end
  self:AddUIMessageEvent("TestUsingNewVehicle", function()
    self.bUsingNewVehicle = not self.bUsingNewVehicle
  end)
  self:AddControlEvent(self, "OnAtomicStateChanged", self.HandleAtomicOperationStateChanged, self)
end
function VehicleUserComponent:ReceiveEndPlay(EndPlayReason)
  self:Dispose()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem and self.CarMusicSwitchHandle then
    SettingSubsystem:UnregisterUserSettingDelegate(self.CarMusicSwitchHandle)
    self.CarMusicSwitchHandle = nil
  end
end
function VehicleUserComponent:CanShowEnterBtn(InVehicle)
  return true
end
function VehicleUserComponent:BPCanEnterVehicle(InVehicle, InSeatType, OutFailedReason)
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return false
  end
  if not slua.isValid(InVehicle) then
    return false
  end
  local uCharacter = MyOwner:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    return false
  end
  if InVehicle.BPCanCharacterEnter and not InVehicle:BPCanCharacterEnter(uCharacter, InSeatType) then
    return false
  end
  return true
end
function VehicleUserComponent:CanChangeSeat(InVehicle)
  return true
end
function VehicleUserComponent:CanUseVehicleWeapon()
  local uController = self:GetOwner()
  if not slua.isValid(uController) then
    return false
  end
  local uCharacter = uController:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) then
    return false
  end
  if uCharacter.HeroPropFeature then
    local nHeroID = uCharacter.HeroPropFeature:GetCurrentHeroID()
    if 0 < nHeroID then
      printf(bWriteLog and "VehicleUserComponent:CanUseVehicleWeapon() return false. nHeroID:%s", tostring(nHeroID))
      return false
    end
  end
  return true
end
function VehicleUserComponent:GetMainControllerBP()
  if Client and self.uBPMainControl == nil then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    self.uBPMainControl = InGameUITools.GetMainControlPanelTochButton()
  end
  return self.uBPMainControl
end
function VehicleUserComponent:GetOwnerController()
  if self.uPC == nil then
    local uPC = self:GetOwner()
    if not slua.isValid(uPC) then
      self.uPC = nil
    end
    local uPCClass = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
    if Game:IsClassOf(uPC, uPCClass) then
      self.    end
  end
  return self.uPC
end
function VehicleUserComponent:GetModeType()
  if self.ModeType == nil then
    local bClient = Client ~= nil
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    self.ModeType = GameMainConfig.GetModType()
  end
  return self.ModeType
end
function VehicleUserComponent:SendUIMsgWhenEnterVehicleCompleted()
  local PC = self:GetOwnerController()
  if not slua.isValid(PC) then
    print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenEnterVehicleCompleted not slua.isValid(PC)")
    return
  end
  print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenEnterVehicleCompleted")
  PC:BroadcastUIMessage("UIMsgEnterVehicleCompleted", 0, "", "")
end
function VehicleUserComponent:SendUIMsgWhenChangeSeatCompleted()
  local PC = self:GetOwnerController()
  print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenChangeSeatCompleted", PC)
  if not slua.isValid(PC) then
    return
  end
  print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenChangeSeatCompleted")
  PC:BroadcastUIMessage("UIMsgChangeSeatCompleted", 0, "", "")
end
function VehicleUserComponent:SendUIMsgWhenExitVehicleCompleted()
  local PC = self:GetOwnerController()
  if not slua.isValid(PC) then
    print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenExitVehicleCompleted not slua.isValid(PC)")
    return
  end
  print(bWriteLog and "VehicleUserComponent:SendUIMsgWhenExitVehicleCompleted")
  PC:BroadcastUIMessage("UIMsgExitVehicleCompleted", 0, "", "")
end
function VehicleUserComponent:OnExitVehicleCompleted()
  self.Super:OnExitVehicleCompleted()
  local uController = self:GetOwner()
  if not slua.isValid(uController) then
    return
  end
  print(bWriteLog and "VehicleUserComponent:OnExitVehicleCompleted ExitFreeCamera", uController)
  uController:ExitFreeCamera(false)
  local uCharacter = uController:GetPlayerCharacterSafety()
  local bIsDeforemd
  if slua.isValid(uCharacter) then
    bIsDeforemd = uCharacter.bIsDeformed
  end
  if slua.isValid(uCharacter) and not slua.isValid(uCharacter:GetCurrentVehicle()) and not bIsDeforemd and slua.isValid(uCharacter.SpringArmComp) then
    local ECameraDataType = import("ECameraDataType")
    print(bWriteLog and "VehicleUserComponent:OnExitVehicleCompleted, Set Character Springarm disable vehicleData", uController)
    uCharacter.SpringArmComp:SetCameraDataEnable(ECameraDataType.ECameraDataType_Vehicle, false)
  end
end
function VehicleUserComponent:LuaDoEnterPrevVehicle(PrevVehicle, SeatType)
  local Controller = self:GetOwner()
  if not slua.isValid(Controller) or not slua.isValid(self.Character) then
    return
  end
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if self.Vehicle.VehicleShapeType == ESTExtraVehicleShapeType.VST_RubberDuck and (self.Character:GetIsFPP() or self.Character:ShouldForceFPP()) then
    print(bWriteLog and "VehicleUserComponent:LuaDoEnterPrevVehicle, set character as view target")
    Controller:SetViewTargetTest(self.Character)
    self.Character:LocalSwitchPersonPerspective(true, false, false)
    if slua.isValid(Controller.SpectatorComponent) then
      Controller.SpectatorComponent:NotifyObserversSetViewTarget(self.Character)
    end
  end
end
function VehicleUserComponent:HandleAtomicOperationStateChanged(bEnter)
  local uController = self:GetOwner()
  if not slua.isValid(uController) then
    print(bWriteLog and "VehicleUserComponent:HandleAtomicOperationStateChanged, Controller is invalid")
    return
  end
  self.bInVehicleAtomicOperation = bEnter
  print(bWriteLog and "VehicleUserComponent:HandleAtomicOperationStateChanged" .. tostring(bEnter))
end
function VehicleUserComponent:LuaCanEnterAttachVehicle(InVehicle, InSeatType)
  local uController = self:GetOwner()
  if not slua.isValid(uController) then
    print(bWriteLog and "VehicleUserComponent:LuaCanEnterAttachVehicle, Controller is invalid")
    return false
  end
  local uCharacter = uController:GetPlayerCharacterSafety()
  if not slua.isValid(uCharacter) or not uCharacter.CanEnterVehicle then
    print(bWriteLog and "VehicleUserComponent:LuaCanEnterAttachVehicle, uCharacter is invalid")
    return false
  end
  if not uCharacter:CanEnterVehicle(InVehicle) then
    print(bWriteLog and "VehicleUserComponent:LuaCanEnterAttachVehicle, uCharacter CanEnterVehicle canntchange")
    return false
  end
  return true
end
function VehicleUserComponent:UpdateControllerData(InController)
  local LastController = self.ControllerData.PlayerController
  self.ControllerData.PlayerController = InController
  if slua.isValid(InController) then
    self.ControllerData.PlayerKey = InController.PlayerKey
    print(bWriteLog and "VehicleUserComponent:UpdateControllerData", InController, self.ControllerData.PlayerKey)
    self:ClientExecuteEnterVehicle()
  else
    self.ControllerData.PlayerKey = nil
    print(bWriteLog and "VehicleUserComponent:UpdateControllerData, try exit vehicle", LastController)
    self:ClientExecuteExitVehicle()
  end
end
function VehicleUserComponent:UpdateCharacterData(InCharacter)
  local LastCharacter = self.CharacterData.Character
  self.CharacterData.Character = InCharacter
  if slua.isValid(InCharacter) then
    local VehicleUtils = import("VehicleUtils")
    self.CharacterData.PlayerKey = InCharacter.PlayerKey
    self.CharacterData.TargetSeatIndex = VehicleUtils.DecompressSeatIndex(InCharacter.AttachmentReplication.ExtraData)
    print(bWriteLog and "VehicleUserComponent:UpdateCharacterData, try enter vehicle", InCharacter, self.CharacterData.PlayerKey, self.CharacterData.TargetSeatIndex)
    self:ClientExecuteEnterVehicle()
  else
    self.CharacterData.PlayerKey = nil
    self.CharacterData.TargetSeatIndex = nil
    print(bWriteLog and "VehicleUserComponent:UpdateCharacterData, try exit vehicle", LastCharacter)
    self:ClientExecuteExitVehicle()
  end
end
function VehicleUserComponent:UpdateVehicleData(InVehicle)
  local CurrentVehicle = self.VehicleData.Vehicle
  self.VehicleData.Vehicle = InVehicle
  if not slua.isValid(InVehicle) or slua.isValid(CurrentVehicle) and InVehicle ~= CurrentVehicle then
    print(bWriteLog and "VehicleUserComponent:UpdateVehicleData, try exit vehicle", CurrentVehicle, InVehicle)
    self:ClientExecuteExitVehicle()
  end
  if slua.isValid(InVehicle) then
    print(bWriteLog and "VehicleUserComponent:UpdateVehicleData", CurrentVehicle, InVehicle)
    self:ClientExecuteEnterVehicle()
  end
end
function VehicleUserComponent:UpdateVehicleAndCharacterData(InVehicle, InCharacter)
  local CurrentCharacter = self.CharacterData.Character
  local CurrentVehicle = self.VehicleData.Vehicle
  self.CharacterData.Character = InCharacter
  self.VehicleData.Vehicle = InVehicle
  local IsCharacterValid = slua.isValid(InCharacter)
  local IsVehicleValid = slua.isValid(InVehicle)
  if not (IsCharacterValid and IsVehicleValid) or slua.isValid(CurrentVehicle) and InVehicle ~= CurrentVehicle then
    print(bWriteLog and "VehicleUserComponent:UpdateVehicleAndCharacterData, try exit vehicle", CurrentCharacter, InCharacter, CurrentVehicle, InVehicle)
    if not IsCharacterValid then
      self.CharacterData.PlayerKey = nil
      self.CharacterData.TargetSeatIndex = nil
    end
    self:ClientExecuteExitVehicle()
  end
  if IsCharacterValid or IsVehicleValid then
    print(bWriteLog and "VehicleUserComponent:UpdateVehicleAndCharacterData", CurrentCharacter, InCharacter, CurrentVehicle, InVehicle)
    if IsCharacterValid then
      local VehicleUtils = import("VehicleUtils")
      self.CharacterData.PlayerKey = InCharacter.PlayerKey
      self.CharacterData.TargetSeatIndex = VehicleUtils.DecompressSeatIndex(InCharacter.AttachmentReplication.ExtraData)
    end
    self:ClientExecuteEnterVehicle()
  end
end
function VehicleUserComponent:ClientExecuteEnterVehicle()
  local PlayerController = self.ControllerData.PlayerController
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, PlayerController is nil")
    return
  end
  local TargetSeatIndex = self.CharacterData.TargetSeatIndex
  if not TargetSeatIndex then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, TargetSeatIndex is nil", PlayerController, TargetSeatIndex)
    return
  end
  local CurrentSeatIndex = self.CharacterData.CurrentSeatIndex
  if CurrentSeatIndex then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, character is on vehicle", PlayerController, CurrentSeatIndex, TargetSeatIndex)
    self:ClientExecuteChangeSeat()
    return
  end
  local Character = self.CharacterData.Character
  if not slua.isValid(Character) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, Character is nil")
    return
  end
  local Vehicle = self.VehicleData.Vehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, Vehicle is nil")
    return
  end
  local PlayerControllerKey = self.ControllerData.PlayerKey
  local PlayerCharacterKey = self.CharacterData.PlayerKey
  if PlayerControllerKey ~= PlayerCharacterKey then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, PlayerControllerKey is not equal PlayerCharacterKey", PlayerControllerKey, PlayerCharacterKey)
    return
  end
  local VehicleSeat = Vehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, VehicleSeat is nil")
    return
  end
  if TargetSeatIndex < 0 or TargetSeatIndex >= VehicleSeat.Seats:Num() then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle, TargetSeatIndex is invalid", TargetSeatIndex)
    return
  end
  print(bWriteLog and "VehicleUserComponent:ClientExecuteEnterVehicle", Vehicle, Character, TargetSeatIndex)
  local SeatConfig = VehicleSeat.Seats:Get(TargetSeatIndex)
  self:ClientEnterVehicle(Vehicle, true, SeatConfig.SeatType, TargetSeatIndex)
  self.CharacterData.CurrentSeatIndex = TargetSeatIndex
end
function VehicleUserComponent:ClientExecuteExitVehicle()
  if not self.CharacterData.CurrentSeatIndex then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteExitVehicle, CurrentSeatIndex is nil")
    return
  end
  print(bWriteLog and "VehicleUserComponent:ClientExecuteExitVehicle", self.CharacterData.CurrentSeatIndex)
  self:ClientExitVehicle(true)
  self.CharacterData.CurrentSeatIndex = nil
end
function VehicleUserComponent:ClientExecuteChangeSeat()
  local PlayerController = self.ControllerData.PlayerController
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, PlayerController is nil")
    return
  end
  local CurrentSeatIndex = self.CharacterData.CurrentSeatIndex
  local TargetSeatIndex = self.CharacterData.TargetSeatIndex
  if not (CurrentSeatIndex and TargetSeatIndex) or CurrentSeatIndex == TargetSeatIndex then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, SeatIndex is not changed", PlayerController, CurrentSeatIndex, TargetSeatIndex)
    return
  end
  local Character = self.CharacterData.Character
  if not slua.isValid(Character) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, Character is nil")
    return
  end
  local Vehicle = self.VehicleData.Vehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, Vehicle is nil")
    return
  end
  local PlayerControllerKey = self.ControllerData.PlayerKey
  local PlayerCharacterKey = self.CharacterData.PlayerKey
  if PlayerCharacterKey ~= 0 and PlayerControllerKey ~= PlayerCharacterKey then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, PlayerControllerKey is not equal PlayerCharacterKey", PlayerControllerKey, PlayerCharacterKey)
    return
  end
  local VehicleSeat = Vehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, VehicleSeat is nil")
    return
  end
  if TargetSeatIndex < 0 or TargetSeatIndex >= VehicleSeat.Seats:Num() then
    print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat, TargetSeatIndex is invalid", TargetSeatIndex)
    return
  end
  print(bWriteLog and "VehicleUserComponent:ClientExecuteChangeSeat", Vehicle, Character, TargetSeatIndex)
  local SeatConfig = VehicleSeat.Seats:Get(TargetSeatIndex)
  self:ClientChangeVehicleSeat(SeatConfig.SeatType, TargetSeatIndex)
  self.CharacterData.CurrentSeatIndex = TargetSeatIndex
end
function VehicleUserComponent:OnPlayerControllerKeyChange(_, _, PlayerController)
  if not (slua.isValid(PlayerController) and slua.isValid(self.Object)) or PlayerController ~= self:GetOwner() then
    return
  end
  print(bWriteLog and "VehicleUserComponent:OnPlayerControllerKeyChange", PlayerController)
  self:UpdateControllerData(PlayerController)
end
function VehicleUserComponent:OnVehicleEndPlay(_, _, Vehicle)
  if not slua.isValid(Vehicle) or self.VehicleData.Vehicle ~= Vehicle then
    return
  end
  print(bWriteLog and "VehicleUserComponent:OnVehicleEndPlay", Vehicle)
  self:UpdateVehicleData()
end
function VehicleUserComponent:RPC_Server_ReqAgentMove(IsHostingOrFollow, IsFinish)
  if not slua.isValid(self.Vehicle) then
    return
  end
  print(bWriteLog and "VehicleUserComponent:RPC_Server_ReqAgentMove ", IsHostingOrFollow, IsFinish)
  local uAgentMoveComponent = self.Vehicle.GetBioAgentMoveComp and self.Vehicle:GetBioAgentMoveComp()
  if slua.isValid(uAgentMoveComponent) then
    if IsFinish then
      uAgentMoveComponent:ReqFinishAgentMove()
    elseif IsHostingOrFollow then
      uAgentMoveComponent:ServerHostingMove()
    else
      uAgentMoveComponent:ServerFollowTarget()
    end
  end
end
function VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer(VehicleSkillID, SeatIndex, TriggerTime)
  if not slua.isValid(self.Vehicle) then
    print(bWriteLog and "VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer, self.Vehicle is nil")
    return
  end
  local VehicleSeats = self.Vehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeats) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer fail not valid VehicleSeats"))
    return
  end
  local PlayerController = self:GetOwner()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer fail not valid PlayerController"))
    return false
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer fail not valid PlayerCharacter"))
    return false
  end
  local SeatIndexInServer = VehicleSeats:GetChracterSeatIndex(PlayerCharacter)
  if SeatIndex ~= SeatIndexInServer then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer fail not same SeatIndex"))
    return false
  end
  print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_TriggerVehicleSkillServer VehicleSkillID: %d, SeatIndex: %d, TriggerTime: %f", VehicleSkillID, SeatIndex, TriggerTime))
  local CurSkill = self.Vehicle:GetCurVehicleSkillBySkillID(VehicleSkillID)
  if CurSkill then
    CurSkill:RPC_TriggerSkillServer(SeatIndex, TriggerTime)
  end
end
function VehicleUserComponent:RPC_Server_StopVehicleSkillServer(VehicleSkillID, SeatIndex)
  if not slua.isValid(self.Vehicle) then
    print(bWriteLog and "VehicleUserComponent:RPC_Server_StopVehicleSkillServer, self.Vehicle is nil")
    return
  end
  local VehicleSeats = self.Vehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeats) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_StopVehicleSkillServer fail not valid VehicleSeats"))
    return
  end
  local PlayerController = self:GetOwner()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_StopVehicleSkillServer fail not valid PlayerController"))
    return false
  end
  local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_StopVehicleSkillServer fail not valid PlayerCharacter"))
    return false
  end
  local SeatIndexInServer = VehicleSeats:GetChracterSeatIndex(PlayerCharacter)
  if SeatIndex ~= SeatIndexInServer then
    print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_StopVehicleSkillServer fail not same SeatIndex"))
    return false
  end
  print(bWriteLog and string.format("VehicleUserComponent:RPC_Server_StopVehicleSkillServer VehicleSkillID: %d, SeatIndex: %d", VehicleSkillID, SeatIndex))
  local CurSkill = self.Vehicle:GetCurVehicleSkillBySkillID(VehicleSkillID)
  if CurSkill then
    CurSkill:RPC_StopSkillServer(SeatIndex)
  end
end
local class = require("class")
local ComponentCls = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(ComponentCls, nil, VehicleUserComponent)
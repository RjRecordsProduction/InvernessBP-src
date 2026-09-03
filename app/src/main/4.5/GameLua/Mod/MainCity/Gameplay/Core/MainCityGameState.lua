local MainCityGameState = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
MainCityGameState.MulticastRPC.MulticastRPC_SwitchDS = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64
  }
}
function MainCityGameState:_PostConstruct()
  MainCityGameState.__super._PostConstruct(self)
  print(bWriteLog and "MainCityGameState:_PostConstruct")
  self.bMainCityGameMode = true
  if Client and self:IsAuthority() then
    print(bWriteLog and "MainCityGameState:_PostConstruct EnablePersistentObject")
    local maincity_persistent_object_utils = require("GameLua.Mod.MainCity.Gameplay.Utils.maincity_persistent_object_utils")
    maincity_persistent_object_utils.EnablePersistentObject()
  end
end
function MainCityGameState:ReceiveBeginPlay()
  MainCityGameState.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "MainCityGameState:ReceiveBeginPlay")
  EventSystem:postEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_GAMESTATE_BEGIN_PLAY)
  if not Client then
    if EVENTTYPE_MAINCITY then
      self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_DS_DESTROY, self.OnMainCityDSDestroy, self)
      print(bWriteLog and "MainCityGameState:ReceiveBeginPlay AddCommonEvent OnMainCityDSDestroy")
      self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_SAVE, self.OnReplayRecoverSave, self)
      self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_LOAD, self.OnReplayRecoverLoad, self)
      print(bWriteLog and "MainCityGameState:ReceiveBeginPlay AddCommonEvent OnReplayRecover")
    else
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_MOD_EVENT_INIT_FINISH, self.OnModEventInitFinish, self)
      print(bWriteLog and "MainCityGameState:ReceiveBeginPlay AddCommonEvent OnModEventInitFinish")
    end
  end
  if Client then
    local MainCity_Client_GameState_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_Client_GameState_Manager")
    MainCity_Client_GameState_Manager.AddGameState(self)
  end
end
function MainCityGameState:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "MainCityGameState:ReceiveEndPlay")
  if Client then
    if self:IsAuthority() then
      print(bWriteLog and "MainCityGameState:ReceiveEndPlay DisablePersistentObject")
      local maincity_persistent_object_utils = require("GameLua.Mod.MainCity.Gameplay.Utils.maincity_persistent_object_utils")
      maincity_persistent_object_utils.DisablePersistentObject()
    end
    local MainCity_Client_GameState_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_Client_GameState_Manager")
    MainCity_Client_GameState_Manager.RemoveGameState(self)
  end
  MainCityGameState.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MainCityGameState:ReceivePostReplayRecover()
  print(bWriteLog and "MainCityGameState:ReceivePostReplayRecover")
  self.bEnableTimeUpdate = true
  self.bEnableTimeOffset = true
  print(bWriteLog and string.format("MainCityGameState:ReceivePostReplayRecover bEnableTimeUpdate:%s bEnableTimeOffset:%s", tostring(self.bEnableTimeUpdate), tostring(self.bEnableTimeOffset)))
end
function MainCityGameState:OnMainCityDSDestroy(_, __, nGameID)
  print(bWriteLog and "MainCityGameState:OnMainCityDSDestroy")
  self:MulticastRPC_SwitchDS(nGameID)
end
function MainCityGameState:OnReplayRecoverSave(_, __)
  print(bWriteLog and "MainCityGameState:OnReplayRecoverSave")
  local saveData = {}
  local needSave = false
  local PlayerArray = Game:GetAllPlayerPawns()
  for i = 0, PlayerArray:Num() - 1 do
    local uPawn = PlayerArray:Get(i)
    if slua.isValid(uPawn) then
      local uAvatarComp = uPawn:getAvatarComponent2()
      if slua.isValid(uAvatarComp) then
        local Config = uAvatarComp.DefaultAvataConfig
        local nUID = tonumber(uPawn.PlayerUID)
        local LogicSlotDesc = uAvatarComp.LogicSlotDesc
        if Config and nUID and LogicSlotDesc then
          saveData[nUID] = {}
          local tAvatarConfig = {}
          local tLogicSlotDesc = {}
          for Slot, ItemDefine in pairs(Config) do
            print(bWriteLog and "MainCityGameState:OnReplayRecoverSave PlayerUID:" .. tostring(nUID) .. " Slot:" .. tostring(Slot) .. " Type:" .. tostring(ItemDefine.Type) .. " ItemID: " .. tostring(ItemDefine.TypeSpecificID))
            tAvatarConfig[Slot] = {
              Type = ItemDefine.Type,
              TypeSpecificID = ItemDefine.TypeSpecificID
            }
          end
          for Slot, AvatarSlotDesc in pairs(LogicSlotDesc) do
            tLogicSlotDesc[Slot] = {
              SlotID = AvatarSlotDesc.SlotID,
              SubSlotID = AvatarSlotDesc.SubSlotID,
              ItemDefineIDType = AvatarSlotDesc.ItemDefineID.Type,
              ItemDefineIDTypeSpec = AvatarSlotDesc.ItemDefineID.TypeSpecificID,
              RealShowItemDefineIDType = AvatarSlotDesc.RealShowItemDefineID.Type,
              RealShowItemDefineIDTypeSpec = AvatarSlotDesc.RealShowItemDefineID.TypeSpecificID,
              Gender = AvatarSlotDesc.Gender,
              HideState = AvatarSlotDesc.HideState,
              ReplaceState = AvatarSlotDesc.ReplaceState,
              IsExist = AvatarSlotDesc.IsExist,
              CustomType = AvatarSlotDesc.CustomInfo.CustomType,
              ColorID = AvatarSlotDesc.CustomInfo.ColorID,
              PatternID = AvatarSlotDesc.CustomInfo.PatternID,
              NumID = AvatarSlotDesc.CustomInfo.NumID,
              ParticleID = AvatarSlotDesc.CustomInfo.ParticleID,
              ShapeInfo = AvatarSlotDesc.CustomInfo.ShapeInfo,
              bForceHideState = AvatarSlotDesc.bForceHideState,
              SlotDescDiff = AvatarSlotDesc.SlotDescDiff,
              OldItemDefineIDType = AvatarSlotDesc.OldItemDefineID.Type,
              OldItemDefineIDTypeSpec = AvatarSlotDesc.OldItemDefineID.TypeSpecificID
            }
          end
          saveData[nUID].AvatarConfig = tAvatarConfig
          saveData[nUID].LogicSlotDesc = tLogicSlotDesc
          needSave = true
        end
      end
    end
  end
  if needSave then
    local MainCity_Recover_Config = require("GameLua.Mod.MainCity.DS.Config.Recover.MainCity_Recover_Config")
    local MainCity_Recover_SubSystem_DS = SubsystemMgr:Get("MainCity_Recover_SubSystem_DS")
    MainCity_Recover_SubSystem_DS:SetReplayRecoverInfo(MainCity_Recover_Config.RecoverInfoType.MainCityGameStateInfo, saveData)
  end
end
function MainCityGameState:OnReplayRecoverLoad(_, __)
  print(bWriteLog and "MainCityGameState:OnReplayRecoverLoad")
  local MainCity_Recover_Config = require("GameLua.Mod.MainCity.DS.Config.Recover.MainCity_Recover_Config")
  local MainCity_Recover_SubSystem_DS = SubsystemMgr:Get("MainCity_Recover_SubSystem_DS")
  local saveData = MainCity_Recover_SubSystem_DS:GetReplayRecoverInfo(MainCity_Recover_Config.RecoverInfoType.MainCityGameStateInfo)
  if not saveData then
    log(bWriteLog and "MainCityGameState:OnReplayRecoverLoad saveData is nil")
    return
  end
  log_tree("MainCityGameState:OnReplayRecoverLoad saveData=", saveData)
  for PlayerUID, tData in pairs(saveData) do
    local uChar = Game:GetCharacterByUID(PlayerUID)
    if slua.isValid(uChar) then
      local uAvatarComp = uChar:getAvatarComponent2()
      if slua.isValid(uAvatarComp) then
        local tAvatarConfig = tData.AvatarConfig
        local tLogicSlotDesc = tData.LogicSlotDesc
        if tAvatarConfig then
          for Slot, ItemDefine in pairs(tAvatarConfig) do
            log(bWriteLog and "MainCityGameState:OnReplayRecoverLoad PlayerUID:" .. tostring(PlayerUID) .. " Slot:" .. tostring(Slot) .. " Type:" .. tostring(ItemDefine.Type) .. " ItemID: " .. tostring(ItemDefine.TypeSpecificID))
            local Item = FItemDefineID(ItemDefine.Type, ItemDefine.TypeSpecificID)
            uAvatarComp.DefaultAvataConfig:Add(Slot, Item)
          end
          log(bWriteLog and "MainCityGameState:OnReplayRecoverLoad uAvatarComp.DefaultAvataConfig Num:" .. tostring(uAvatarComp.DefaultAvataConfig:Num()))
        end
        if tLogicSlotDesc then
          local FAvatarSlotDesc = import("AvatarSlotDesc")
          for Slot, AvatarSlotDesc in pairs(tLogicSlotDesc) do
            local NewAvatarSlotDesc = FAvatarSlotDesc()
            NewAvatarSlotDesc.SlotID = AvatarSlotDesc.SlotID
            NewAvatarSlotDesc.SubSlotID = AvatarSlotDesc.SubSlotID
            NewAvatarSlotDesc.ItemDefineID = FItemDefineID(AvatarSlotDesc.ItemDefineIDType, AvatarSlotDesc.ItemDefineIDTypeSpec)
            NewAvatarSlotDesc.RealShowItemDefineID = FItemDefineID(AvatarSlotDesc.RealShowItemDefineIDType, AvatarSlotDesc.RealShowItemDefineIDTypeSpec)
            NewAvatarSlotDesc.Gender = AvatarSlotDesc.Gender
            NewAvatarSlotDesc.HideState = AvatarSlotDesc.HideState
            NewAvatarSlotDesc.ReplaceState = AvatarSlotDesc.ReplaceState
            NewAvatarSlotDesc.IsExist = AvatarSlotDesc.IsExist
            NewAvatarSlotDesc.CustomInfo.CustomType = AvatarSlotDesc.CustomType
            NewAvatarSlotDesc.CustomInfo.ColorID = AvatarSlotDesc.ColorID
            NewAvatarSlotDesc.CustomInfo.PatternID = AvatarSlotDesc.PatternID
            NewAvatarSlotDesc.CustomInfo.NumID = AvatarSlotDesc.NumID
            NewAvatarSlotDesc.CustomInfo.ParticleID = AvatarSlotDesc.ParticleID
            NewAvatarSlotDesc.CustomInfo.ShapeInfo = AvatarSlotDesc.ShapeInfo
            NewAvatarSlotDesc.bForceHideState = AvatarSlotDesc.bForceHideState
            NewAvatarSlotDesc.SlotDescDiff = AvatarSlotDesc.SlotDescDiff
            NewAvatarSlotDesc.OldItemDefineID = FItemDefineID(AvatarSlotDesc.OldItemDefineIDType, AvatarSlotDesc.OldItemDefineIDTypeSpec)
            uAvatarComp.LogicSlotDesc:Add(Slot, NewAvatarSlotDesc)
          end
          log(bWriteLog and "MainCityGameState:OnReplayRecoverLoad uAvatarComp.LogicSlotDesc Num:" .. tostring(uAvatarComp.LogicSlotDesc:Num()))
        end
      end
    end
  end
end
function MainCityGameState:OnModEventInitFinish(_, __, ModName)
  print(bWriteLog and "MainCityGameState:OnModEventInitFinish")
  if ModName and ModName == "MainCity" then
    self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_DS_DESTROY, self.OnMainCityDSDestroy, self)
    print(bWriteLog and "MainCityGameState:OnModEventInitFinish AddCommonEvent OnMainCityDSDestroy")
    self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_SAVE, self.OnReplayRecoverSave, self)
    self:AddCommonEvent(EVENTTYPE_MAINCITY, EVENTID_MAINCITY_REPLAY_RECOVER_LOAD, self.OnReplayRecoverLoad, self)
    print(bWriteLog and "MainCityGameState:OnModEventInitFinish AddCommonEvent OnReplayRecover")
  end
end
function MainCityGameState:MulticastRPC_SwitchDS(nGameID)
  if not Client then
    return
  end
  print(bWriteLog and "MainCityGameState:MulticastRPC_SwitchDS")
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  main_city_process_util.ClientHandleSwitchDS(nGameID)
end
local class = require("class")
local CGameStateBase = require("GameLua.GameCore.Framework.GameStateBase")
local CMainCityGameState = class(CGameStateBase, nil, MainCityGameState)
return CMainCityGameState
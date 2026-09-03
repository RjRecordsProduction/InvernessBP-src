local ReddotPet = {}
local petReddotData
local SubSysID = {
  NewPet = 1,
  UpGrade = 2,
  PetDress = 3
}
local ReddotType = SubSysID
local MAX_PET_GRADE = 7
local MOD = MAX_PET_GRADE * 10
local ReddotData = {
  NewPet = {},
  UpGrade = {},
  PetDress = {}
}
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local systemName = reddot_macro.SystemName.Companions
function ReddotPet:GetData()
  local data = {
    desc = systemName,
    newCount = 0,
    [ReddotType.NewPet] = {
      newCount = 0,
      subID = SubSysID.NewPet,
      category = reddot_macro.Category.Other,
      instances = {_isLeaf = true}
    },
    [ReddotType.UpGrade] = {
      newCount = 0,
      subID = SubSysID.UpGrade,
      category = reddot_macro.Category.Other,
      instances = {_isLeaf = true}
    },
    [ReddotType.PetDress] = {
      newCount = 0,
      subID = SubSysID.PetDress,
      category = reddot_macro.Category.Other,
      instances = {_isLeaf = true}
    }
  }
  return data
end
function ReddotPet:NewPet(PetID)
  local instanceID = self:GetInstanceIDByPet(SubSysID.NewPet, PetID)
  self:TryInsertData("NewPet", instanceID)
  self:TrySavePetReddot("NewPet", instanceID, true)
end
function ReddotPet:NewDress(DressID)
  local instanceID = self:GetInstanceIDByPet(SubSysID.PetDress, DressID)
  self:TryInsertData("PetDress", instanceID)
end
function ReddotPet:UpGrade(petID, newGrade, oldGrade)
  local newInstanceID = self:GetInstanceIDByPet(SubSysID.UpGrade, petID, newGrade)
  local oldInstanceID = self:GetInstanceIDByPet(SubSysID.UpGrade, petID, oldGrade)
  self:ClearUpGradeReddot(oldInstanceID)
  self:TryInsertData("UpGrade", newInstanceID)
  self:TrySavePetReddot("UpGrade", newInstanceID, newGrade)
end
function ReddotPet:ClearNewPetReddot(instanceID)
  self:TryRemoveData("NewPet", instanceID)
  self:TrySavePetReddot("NewPet", instanceID, nil)
end
function ReddotPet:ClearPetDressReddot(instanceID)
  self:TryRemoveData("PetDress", instanceID)
  self:TrySavePetReddot("PetDress", instanceID, nil)
end
function ReddotPet:ClearUpGradeReddot(instanceID)
  self:TryRemoveData("UpGrade", instanceID)
  self:TrySavePetReddot("UpGrade", instanceID, nil)
end
function ReddotPet:ClearAllReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(ReddotData, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint)
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  generalLabReddotData.ClearAllReddot(systemName)
end
function ReddotPet:OnLogin()
  self:InitData()
  ReddotPet:LoadData()
end
function ReddotPet:InitData()
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  petReddotData = generalLabReddotData.GetReddotData(systemName)
end
function ReddotPet:OnLogout()
  petReddotData = nil
end
function ReddotPet:LoadData()
end
function ReddotPet:TryInsertData(eventName, value)
  if petReddotData == nil then
    return
  end
  local dataTmp = petReddotData[ReddotType[eventName]]
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  generalLabReddotData.AddReddot(petReddotData[ReddotType[eventName]], value)
end
function ReddotPet:TryRemoveData(eventName, value)
  if petReddotData == nil then
    return
  end
  local dataTmp = petReddotData[ReddotType[eventName]]
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  generalLabReddotData.RemoveReddot(petReddotData[ReddotType[eventName]], value)
end
function ReddotPet:TrySavePetReddot(type, instanceID, flag)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local redData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint)
  if redData == nil then
    redData = ReddotData
  end
  redData[type][instanceID] = flag
  PlayerPrefsSystem.SaveTableToFile_N(redData, PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint)
end
function ReddotPet:GetReddotPetData()
  return petReddotData
end
function ReddotPet:GetInstanceIDByPet(type, petID, grade)
  local instanceID = petID
  if type == ReddotType.UpGrade then
    instanceID = petID * MOD + grade
  end
  return instanceID
end
function ReddotPet:GetPetByInstanceID(subID, instanceID)
  local petID = instanceID
  if subID == SubSysID.UpGrade then
    petID = math.modf(instanceID / MOD)
  end
  return petID
end
function ReddotPet:HasReddot()
  local reddotSum = 0
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local _petReddotData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePetRedPoint)
  if _petReddotData == nil then
    return false
  end
  for k, v in pairs(_petReddotData) do
    reddotSum = reddotSum + #v
  end
  return reddotSum
end
return ReddotPet
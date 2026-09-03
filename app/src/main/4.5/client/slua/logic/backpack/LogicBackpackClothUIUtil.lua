local LogicBackpackClothUIUtil = {}
function LogicBackpackClothUIUtil:DefineAndResetData()
  self.bInitialize = false
  self.ChildEntryItemData = {}
  self.IndexToShowTextMap = {}
end
function LogicBackpackClothUIUtil:OnPostSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
end
function LogicBackpackClothUIUtil:PrepareClothEntryItemData()
  if self.bInitialize then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  self.ChildEntryItemData = {}
  self.IndexToShowTextMap = {}
  local InitialAllWear = slua.IndexReference(PlayerController, "InitialAllWear")
  if not InitialAllWear then
    return
  end
  self.bInitialize = true
  local AllWearNum = InitialAllWear:Num()
  local bHasShareBag = PlayerController.FashionBagStartIndex > 0
  for Index = 1, AllWearNum do
    local TempIndex = Index - 1
    if AllWearNum > TempIndex then
      local bShareBag = TempIndex < PlayerController.FashionBagStartIndex
      local bDefault = TempIndex == AllWearNum - 1
      local bRP = TempIndex - PlayerController.FashionBagStartIndex + 1 == 4
      local bRPPlusBag = TempIndex - PlayerController.FashionBagStartIndex + 1 == 5
      local ShowText = ""
      if bDefault then
        ShowText = ""
      elseif bShareBag then
        ShowText = "S"
      elseif bRP then
        ShowText = "RP"
      elseif bRPPlusBag then
        ShowText = "RP"
      elseif bHasShareBag then
        ShowText = tostring(TempIndex)
      else
        ShowText = tostring(TempIndex + 1)
      end
      local WearData = InitialAllWear:Get(TempIndex)
      local EntryItemData = {
        Index = TempIndex,
        bIsLocked = WearData.IsLocked,
        bNeedCD = false,
              }
      self.IndexToShowTextMap[TempIndex] = ShowText
      if bDefault then
        table.insert(self.ChildEntryItemData, 1, EntryItemData)
      else
        table.insert(self.ChildEntryItemData, EntryItemData)
      end
    end
  end
end
function LogicBackpackClothUIUtil:GetClothEntryItemData()
  if not self.bInitialize then
    self:PrepareClothEntryItemData()
  end
  return self.ChildEntryItemData
end
function LogicBackpackClothUIUtil:GetClothEntryShowNameByIndex(RolewearIndex)
  if not self.bInitialize then
    self:PrepareClothEntryItemData()
  end
  return self.IndexToShowTextMap[RolewearIndex] or ""
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicBackpackClothUIUtil = class(CModuleBase, nil, LogicBackpackClothUIUtil)
return CLogicBackpackClothUIUtil
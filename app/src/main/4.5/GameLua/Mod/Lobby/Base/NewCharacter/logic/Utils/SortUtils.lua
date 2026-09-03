local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.ConstUtils")
function CharacterUtils:SortCharacterIDList(IDList)
  if not IDList or not next(IDList) then
    return
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local SortFunc = function(a, b)
    local a_Used = NewCharacterNetSystem:IsUsedCharacter(a)
    local b_Used = NewCharacterNetSystem:IsUsedCharacter(b)
    local a_UnLocked = NewCharacterNetSystem:IsUnLockedCharacter(a)
    local b_UnLocked = NewCharacterNetSystem:IsUnLockedCharacter(b)
    if a == CharacterUtils.DEFAULT_CHARACTER_ID and b ~= CharacterUtils.DEFAULT_CHARACTER_ID then
      return true
    elseif a ~= CharacterUtils.DEFAULT_CHARACTER_ID and b == CharacterUtils.DEFAULT_CHARACTER_ID then
      return false
    elseif a_Used and not b_Used then
      return true
    elseif not a_Used and b_Used then
      return false
    elseif a_UnLocked and not b_UnLocked then
      return true
    elseif not a_UnLocked and b_UnLocked then
      return false
    else
      return a < b
    end
  end
  table.sort(IDList, SortFunc)
end
function CharacterUtils:SortCharacterDataList(DataList, ItemType)
  if not (DataList and DataList[ItemType]) or not next(DataList[ItemType]) then
    return
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local SortFunc = function(a, b)
    local a_UnLocked = NewCharacterNetSystem:IsUnLockedItem(a.ID)
    local b_UnLocked = NewCharacterNetSystem:IsUnLockedItem(b.ID)
    if a_UnLocked and not b_UnLocked then
      return true
    elseif not a_UnLocked and b_UnLocked then
      return false
    elseif a.Sort < b.Sort then
      return true
    elseif a.Sort > b.Sort then
      return false
    else
      return a.ID < b.ID
    end
  end
  table.sort(DataList[ItemType], SortFunc)
end
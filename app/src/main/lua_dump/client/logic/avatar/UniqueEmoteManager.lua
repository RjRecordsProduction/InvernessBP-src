local UniqueEmoteManager = {}
function UniqueEmoteManager:DefineAndResetData()
  self.action2PawnMap = {}
end
function UniqueEmoteManager:OnInitialize()
end
function UniqueEmoteManager:RegistEvents()
end
function UniqueEmoteManager:CheckUnique(pawn, actionID, EmoteAction)
  if not actionID or not EmoteAction.bOnlyOneInstance then
    return true
  end
  if self.action2PawnMap[actionID] and self.action2PawnMap[actionID] ~= pawn then
    return false
  end
  for _, v in pairs(EmoteAction.AssociateEmoteIDs) do
    if self.action2PawnMap[v] then
      return false
    end
  end
  return true
end
function UniqueEmoteManager:OnPlayActionHandle(pawn, actionID)
  if not actionID then
    return
  end
  if not self.action2PawnMap[actionID] then
    self.action2PawnMap[actionID] = pawn
  end
end
function UniqueEmoteManager:OnEndActionHandle(pawn, actionID)
  if not self.action2PawnMap[actionID] then
    return
  end
  if self.action2PawnMap[actionID] == pawn then
    self.action2PawnMap[actionID] = nil
  end
end
function UniqueEmoteManager:CheckXmissionLobby(pawn, actionID, EmoteAction)
  local isXmissionMainShow = UIManager.UI_Config.xmission_main and UIManager.IsUIShow(UIManager.UI_Config.xmission_main)
  if not isXmissionMainShow or not EmoteAction.bOnlyInXmissionLobby then
    return true
  else
    return false
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUniqueEmoteManager = class(CModuleBase, nil, UniqueEmoteManager)
return CUniqueEmoteManager
local ThemeTaskActionBase = {
  sActionName = "ThemeTaskActionBase",
  RunEvn = "None",
  bCharacterSimulate = false
}
function ThemeTaskActionBase:ctor()
end
function ThemeTaskActionBase:OnInitialize()
end
function ThemeTaskActionBase:OnRelease()
  self:Dispose()
end
function ThemeTaskActionBase:Select(nRewardID, tConfig, Owner)
end
function ThemeTaskActionBase:UnSelect(nRewardID, tConfig, Owner)
end
function ThemeTaskActionBase:GetPlayerCharacter(Owner)
  if not slua.isValid(Owner) then
    return nil
  end
  local AUAEPlayerState = import("UAEPlayerState")
  if Game:IsClassOf(Owner, AUAEPlayerState) then
    return Owner.CharacterOwner
  end
  local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
  if Game:IsClassOf(Owner, ASTExtraPlayerCharacter) then
    return Owner
  end
  return nil
end
function ThemeTaskActionBase:IsAllowToRun(Owner)
  if not slua.isValid(Owner) then
    return false
  end
  local AUAEPlayerState = import("UAEPlayerState")
  local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
  if Game:IsClassOf(Owner, AUAEPlayerState) and self.bCharacterSimulate or Game:IsClassOf(Owner, ASTExtraPlayerCharacter) and not self.bCharacterSimulate then
    return false
  end
  if self.RunEvn == "Both" then
    return true
  elseif self.RunEvn == "Client" and Client then
    return true
  elseif self.RunEvn == "DS" and not Client then
    return true
  end
  return false
end
local class = require("class")
local delegate_container = require("common.delegate_container")
local CThemeTaskActionBase = class(delegate_container, nil, ThemeTaskActionBase)
return CThemeTaskActionBase
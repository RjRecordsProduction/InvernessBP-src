local CharacterEventData = {
  ETargetType = {ETARGET_PLAYER = 1, ETARGET_WEAPON = 2}
}
function CharacterEventData:Init(bClient)
  CharacterEventData.__super.Init(self, bClient)
end
function CharacterEventData:Clear()
  CharacterEventData.__super.Clear(self)
end
function CharacterEventData:GetTalentActionData(talentID)
  if self.TalentCfgData == nil then
    local talentCfg = self:GetTable("TalentActionTable")
    if talentCfg then
      self.TalentCfgData = {}
      for i, v in pairs(talentCfg) do
        if v and v.ID then
          self.TalentCfgData[v.ID] = v
        end
      end
    end
    talentCfg = nil
  end
  if self.TalentCfgData then
    return self.TalentCfgData[talentID]
  end
  return nil
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CCharacterEventData = class(CEventDataBase, nil, CharacterEventData)
return CCharacterEventData
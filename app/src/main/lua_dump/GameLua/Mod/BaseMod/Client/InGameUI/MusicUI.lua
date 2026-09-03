local MusicUI = {}
function MusicUI:ctor(_, TextID)
  self.end
function MusicUI:RegistEvents()
  print(bWriteLog and "MusicUI:RegistEvents(")
  local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
  if DataLayerSubsystem then
    self:AddDataListener(DataLayerSubsystem:GetSuperData(), "InBornIslandMusicPlayer", self.OnInBornIslandMusicPlayerChange, self)
  end
end
function MusicUI:OnPostInitialize()
  if not slua.isValid(self.UIRoot) or not self.UIRoot.Slot then
    print(bWriteLog and "MusicUI:OnPostInitialize - self.UIRoot is nil")
    return
  end
  local Slot = self.UIRoot.Slot
  if slua.isValid(Slot) then
    Slot:SetZOrder(-1)
  end
  if self.UIRoot.TextBlock_MusicName then
    self.UIRoot.TextBlock_MusicName:SetText(LocUtil.GetLocalizeResStr(self.TextID))
  end
  self:AddGameTimer(60, false, function()
    self:CloseSelf()
  end)
end
function MusicUI:OnInBornIslandMusicPlayerChange(_, InBornIslandMusicPlayer)
  if not InBornIslandMusicPlayer then
    self:CloseSelf()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CMusicUI = class(ui_base, nil, MusicUI)
return CMusicUI
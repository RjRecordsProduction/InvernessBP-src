local PlaneShowUI = {}
function PlaneShowUI:ctor(selfType, SeqActor, PlaneShowUIType)
  self.PlaneShowMgr = SeqActor
  self.  self.CDTime = 2
end
function PlaneShowUI:OnInitialize()
  PlaneShowUI.__super.OnInitialize(self)
end
function PlaneShowUI:GetInitVisibility(showVisibility)
  return showVisibility
end
function PlaneShowUI:RegistEvents()
  PlaneShowUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, self.OnSwithButtonClick, self)
end
function PlaneShowUI:OnUnRegistEvents()
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue("CG_Volume", 1, 0)
end
function PlaneShowUI:OnPostInitialize()
  PlaneShowUI.__super.OnPostInitialize(self)
end
function PlaneShowUI:Close()
  PlaneShowUI.__super.Close(self)
end
function PlaneShowUI:SwitchView(bBestView)
  print(bWriteLog and "PlaneShowUI:SwitchView BestView", bBestView)
  local audio_util = require("client.common.audio_util")
  if bBestView then
    audio_util.SetRTPCValue("CG_Volume", 1, 0)
  else
    audio_util.SetRTPCValue("CG_Volume", 0, 0)
  end
  if slua.isValid(self.PlaneShowMgr) then
    self.PlaneShowMgr:UISelectView(bBestView)
  else
    print(bWriteLog and "PlaneShowUI:SwitchView(bBestView) PlaneShowActor is not valid", bBestView)
  end
end
function PlaneShowUI:OnSwithButtonClick()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CPlaneShowUI = class(ui_base, nil, PlaneShowUI)
return CPlaneShowUI
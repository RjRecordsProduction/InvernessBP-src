local NGActionListenThrowGrenade = {}
function NGActionListenThrowGrenade:ctor(selfType, Params)
  self.TimeThreshold = Params.TimeThreshold or 3
  self.BeginTime = -1
  self.GuideID = -1
end
function NGActionListenThrowGrenade:RunAction(InGuideID)
  log(bWriteLog and "Debug NewbieGuide: NGActionListenThrowGrenade RunAction")
  NGActionListenThrowGrenade.__super.RunAction(self, InGuideID)
  self.GuideID = InGuideID
  self.BeginTime = os.time()
  EventSystem:registEvent(EVENTTYPE_PLAYEREVENT_SKILLBUFF, EVENTID_PLAYEREVENT_GRENADE_BASE_THROW, self.HandleThrowGrenade, self)
  return true
end
function NGActionListenThrowGrenade:HandleThrowGrenade()
  local CurTime = os.time()
  if CurTime - self.BeginTime >= self.TimeThreshold then
    log(bWriteLog and "Throw delay success!")
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END_GUIDE_BY_ACTION, self.GuideID, "RecieveEndEventExtra")
  else
    log(bWriteLog and "Throw delay failed!")
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END_GUIDE_BY_ACTION, self.GuideID, "RecieveEndEvent")
  end
end
function NGActionListenThrowGrenade:EndAction()
  NGActionListenThrowGrenade.__super.EndAction(self)
  log(bWriteLog and "Debug NewbieGuide: NGActionListenThrowGrenade EndAction")
  EventSystem:unregistEvent(EVENTTYPE_PLAYEREVENT_SKILLBUFF, EVENTID_PLAYEREVENT_GRENADE_BASE_THROW, self.HandleThrowGrenade, self)
  self.BeginTime = -1
end
function NGActionListenThrowGrenade:Clear()
  log(bWriteLog and "Debug NewbieGuide: NGActionListenThrowGrenade Clear")
  EventSystem:unregistEvent(EVENTTYPE_PLAYEREVENT_SKILLBUFF, EVENTID_PLAYEREVENT_GRENADE_BASE_THROW, self.HandleThrowGrenade, self)
  self.BeginTime = -1
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionListenThrowGrenade = class(CObject, nil, NGActionListenThrowGrenade)
return CNGActionListenThrowGrenade
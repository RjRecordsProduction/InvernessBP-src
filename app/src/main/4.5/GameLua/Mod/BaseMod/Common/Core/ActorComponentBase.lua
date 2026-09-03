local ActorComponentBase = {}
local EEndPlayReason = import("EEndPlayReason")
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
function ActorComponentBase:_PostConstruct()
end
function ActorComponentBase:ReceiveBeginPlay()
  xpcall(self.OnReceiveBeginPlay, xpcallHandle, self)
end
function ActorComponentBase:ReceiveEndPlay(EndReason, bClearTable)
  xpcall(self.OnReceiveEndPlay, xpcallHandle, self, EndReason, bClearTable)
  self:Dispose()
  if bClearTable ~= false and EndReason == EEndPlayReason.Destroyed then
    slua.ClearTable(self)
  end
end
function ActorComponentBase:OnReceiveBeginPlay()
end
function ActorComponentBase:OnReceiveEndPlay()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CActorComponentBase = class(CDelegateContainer, nil, ActorComponentBase)
return CActorComponentBase
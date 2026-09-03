local AvatarCaptureActor = {}
function AvatarCaptureActor:ctor(selfType)
  AvatarCaptureActor.__super.ctor(self, selfType)
end
function AvatarCaptureActor:ReceiveBeginPlay()
  AvatarCaptureActor.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "AvatarCaptureActor:ReceiveBeginPlay()")
end
function AvatarCaptureActor:ReceiveEndPlay(nEndPlayReason)
  print(bWriteLog and "AvatarCaptureActor:ReceiveEndPlay()")
  AvatarCaptureActor.__super.ReceiveEndPlay(self, nEndPlayReason)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CAvatarCaptureActor = class(CActorBase, nil, AvatarCaptureActor)
return CAvatarCaptureActor
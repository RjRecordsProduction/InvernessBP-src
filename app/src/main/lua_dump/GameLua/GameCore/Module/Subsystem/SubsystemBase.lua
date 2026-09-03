local SubsystemBase = {}
function SubsystemBase:ctor(_, bDestroyOnReconnect)
  self.  self._SuperData = nil
  self.bIsValid = true
end
function SubsystemBase:_PostConstruct()
end
function SubsystemBase:OnInit()
  self.bIsValid = true
end
function SubsystemBase:OnRelease()
  self._SuperData = nil
  self.bIsValid = false
  self:Dispose()
end
function SubsystemBase:IsValid()
  return self.bIsValid
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CSubsystemBase = class(CDelegateContainer, nil, SubsystemBase)
return CSubsystemBase
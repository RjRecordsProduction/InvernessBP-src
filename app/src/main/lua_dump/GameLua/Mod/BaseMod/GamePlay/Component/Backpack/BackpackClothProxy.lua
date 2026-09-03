local BackpackClothProxy = {}
function BackpackClothProxy:ctor(selfType)
  BackpackClothProxy.__super.ctor(self, selfType)
end
function BackpackClothProxy:LuaInitialize()
  print(bWriteLog and "BackpackClothProxy:LuaInitialize()")
end
function BackpackClothProxy:LuaDeinitialize()
  print(bWriteLog and "BackpackClothProxy:LuaDeinitialize()")
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackClothProxy = class(CDelegateContainer, nil, BackpackClothProxy)
return CBackpackClothProxy
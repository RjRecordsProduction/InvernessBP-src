local ProtoPromiseHookTool = {}
local upv = {}
local makePairPromise = function(v, req)
  local promise = require("common.Promise").new()
  v[req] = promise
  return promise
end
local takePromise = function(v, req)
  local promise = v[req]
  v[req] = nil
  return promise
end
function ProtoPromiseHookTool.RemovePromiseByTimeout(req)
  local reqName = "send_" .. req
  local promise = upv[reqName]
  upv[reqName] = nil
  if promise then
    promise:Reject("timeout. reqName:" .. req)
  end
end
function ProtoPromiseHookTool.RemovePromise(p)
  for reqName, promise in pairs(upv) do
    if promise == p then
      printf("ProtoPromiseHookTool.RemovePromise: remove promise. reqName:%s", reqName)
      upv[reqName] = nil
      return
    end
  end
end
function ProtoPromiseHookTool.HookPair(reqRspPair, handler)
  for reqName, rspName in pairs(reqRspPair) do
    local oldSendFunc = handler[reqName]
    handler[reqName] = function(...)
      oldSendFunc(...)
      local promise = makePairPromise(upv, reqName)
      return promise
    end
    local oldRspFunc = handler[rspName]
    handler[rspName] = function(...)
      local solved = oldRspFunc(...)
      if not solved then
        local promise = takePromise(upv, reqName)
        if not promise then
          print(bWriteLog and "ProtoPromiseHookTool.HookPair: no promise found. reqName:" .. reqName)
          return
        end
        promise:Resolve(...)
      end
    end
  end
end
return ProtoPromiseHookTool
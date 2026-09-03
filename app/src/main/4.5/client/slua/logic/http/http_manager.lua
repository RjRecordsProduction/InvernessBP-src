local http_manager = {}
local HttpWrapper
local pairMap = {}
function http_manager:OnInitialize()
  if slua_GameFrontendHUD then
    HttpWrapper = slua_GameFrontendHUD:GetHttpWrapper()
    HttpWrapper.OnResponseEvent:Add(function(...)
      self:OnRawResponse(...)
    end)
    HttpWrapper.OnImageDownloadResponseEvent:Add(function(...)
      self:OnRawResponseImg(...)
    end)
  end
end
function http_manager:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "http_manager.OnPreSwitchGameStatus " .. nextState .. "  " .. preState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
  elseif nextState == GameStatus.Login then
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    if HttpWrapper then
      HttpWrapper:CancelRequestAll(0)
      HttpWrapper:CancelRequestAll(1)
      HttpWrapper:CancelRequestAll(2)
    end
    pairMap = {}
  end
end
function http_manager:Post(url, head, content, ueObj, callback, timeout, priority, queueType)
  if callback then
    assert(type(callback) == "function", "callback should be function!!!")
  end
  if HttpWrapper then
    priority = priority or 0
    queueType = queueType or 0
    local index = HttpWrapper:RequestForLua(url, "POST", head, content, priority, queueType)
    log(bWriteLog and string.format(" http_manager.Post index:%s", index))
    pairMap[index] = {callback = callback}
    if timeout then
      pairMap[index].timeout_timer = self:AddTimerOnce(timeout, function()
        log(bWriteLog and string.format(" http_manager.Post timeout index:%s", index))
        local tb = pairMap[index]
        if tb then
          pairMap[index] = nil
          if tb.callback then
            tb.callback(false, "", nil)
          end
        end
      end)
    end
    return index
  end
  return 0
end
function http_manager:Get(url, head, content, ueObj, callback, timeout, priority, queueType)
  if url == nil then
    log(bWriteLog and "http_manager.Get url is nil")
    return 0
  end
  if callback then
    assert(type(callback) == "function", "callback should be function!!!")
  end
  if HttpWrapper then
    priority = priority or 0
    queueType = queueType or 0
    content = content or ""
    local index = HttpWrapper:RequestForLua(url, "GET", head, content, priority, queueType)
    log(bWriteLog and string.format(" http_manager.Get index:%s", index))
    pairMap[index] = {callback = callback}
    if timeout then
      pairMap[index].timeout_timer = self:AddTimerOnce(timeout, function()
        log(bWriteLog and string.format(" http_manager.Get timeout index:%s", index))
        local tb = pairMap[index]
        if tb then
          pairMap[index] = nil
          if tb.callback then
            tb.callback(false, "", nil)
          end
        end
      end)
    end
    return index
  end
  return 0
end
function http_manager:SimplePost(url, content)
  if HttpWrapper then
    HttpWrapper:SimplePostForLua(url, content, 0, 0)
  end
end
function http_manager:Cancel(reqIndex, queueType)
  log(bWriteLog and string.format(" http_manager.Cancel reqIndex:%s", reqIndex))
  pairMap[reqIndex] = nil
  if HttpWrapper then
    HttpWrapper:CancelRequest(queueType or 0, reqIndex)
  end
end
function http_manager:OnRawResponse(reqIndex, elapsedTime, data, content, success, result)
  log(bWriteLog and string.format("http_manager.OnRawResponse reqIndex:%s, elapsedTime:%s, success:%s, result:%s", tostring(reqIndex), tostring(elapsedTime), tostring(success), tostring(result)))
  local tb = pairMap[reqIndex]
  if tb then
    pairMap[reqIndex] = nil
    if tb.timeout_timer then
      self:RemoveTimer(tb.timeout_timer)
      tb.timeout_timer = nil
    end
    if tb.callback and type(tb.callback) == "function" then
      tb.callback(success, data, content, result)
    end
  end
end
function http_manager:OnRawResponseImg(reqIndex, elapsedTime, content, success, result)
  self:OnRawResponse(reqIndex, elapsedTime, content, content, success, result)
end
function http_manager:ImageDownloadRequest(url, head, content, ueObj, callback, timeout, priority)
  if callback then
    assert(type(callback) == "function", "callback should be function!!!")
  end
  if HttpWrapper then
    priority = priority or 0
    content = content or ""
    local index = HttpWrapper:ImageDownloadRequestForLua(url, "GET", head, content, priority)
    log(bWriteLog and string.format("[liz]http_manager.ImageDownloadRequest index:%s", index))
    pairMap[index] = {
      callback = callback,
      timeout = timeout or 3
    }
    return index
  end
  return 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CHttpManager = class(CModuleBase, nil, http_manager)
return CHttpManager
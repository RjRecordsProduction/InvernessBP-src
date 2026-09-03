local MergePatialTool = {
  MT_Override = 1,
  MT_After = 2,
  MT_First = 3
}
local ForceMergeFunctions = {
  GetLifetimeReplicatedProps = true,
  ReceiveBeginPlay = true,
  ReceiveEndPlay = true,
  _PostConstruct = true,
  RegistEvents = true,
  OnInitialize = true,
  OnClose = true,
  OnInit = true,
  OnLogOut = true,
  DefineAndResetData = true
}
local _merge_rets = function(t1, t2)
  if t1 == nil and t2 == nil then
    return nil
  end
  if t1 == nil then
    return t2
  end
  if t2 == nil then
    return t1
  end
  if type(t1) == "table" and type(t2) == "table" then
    local BaseRepTable = t1
    local RepTable = t2
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
    return RepTable
  end
  assert(false, "merge error t1 = " .. tostring(t1) .. ", t2 = " .. tostring(t2))
end
local _merge_call = function(k, first, second)
  return function(self, ...)
    local Ret1 = first(self, ...)
    local Ret2 = second(self, ...)
    return _merge_rets(Ret1, Ret2)
  end
end
function MergePatialTool.Mixin(Base, Source, Patial)
  local base = Base.__inner_impl
  local bh = Patial
  for k, v in pairs(bh) do
    if type(v) == "function" and k ~= "ctor" then
      if Source[k] then
        if ForceMergeFunctions[k] then
          if k == "ReceiveEndPlay" or k == "OnClose" then
            Source[k] = _merge_call(k, v, Source[k])
          else
            Source[k] = _merge_call(k, Source[k], v)
          end
        elseif Source[k .. "__MT"] == MergePatialTool.MT_After then
          Source[k] = _merge_call(k, v, Source[k])
        else
          if Source[k .. "__MT"] == MergePatialTool.MT_First then
            Source[k] = _merge_call(k, Source[k], v)
          else
          end
        end
      elseif base[k] then
        if ForceMergeFunctions[k] then
          if k == "ReceiveEndPlay" or k == "OnClose" then
            Source[k] = _merge_call(k, v, base[k])
          else
            Source[k] = _merge_call(k, base[k], v)
          end
        elseif Patial[k .. "__MT"] == MergePatialTool.MT_First then
          Source[k] = _merge_call(k, v, base[k])
        elseif Patial[k .. "__MT"] == MergePatialTool.MT_After then
          Source[k] = _merge_call(k, base[k], v)
        else
          Source[k] = v
        end
      else
        Source[k] = v
      end
    end
  end
  if bh.ServerRPC and next(bh.ServerRPC) then
    Source.ServerRPC = Source.ServerRPC or {}
    for k, v in pairs(bh.ServerRPC) do
      Source.ServerRPC[k] = v
    end
  end
  if bh.ClientRPC and next(bh.ClientRPC) then
    Source.ClientRPC = Source.ClientRPC or {}
    for k, v in pairs(bh.ClientRPC) do
      Source.ClientRPC[k] = v
    end
  end
  if bh.MulticastRPC and next(bh.MulticastRPC) then
    Source.MulticastRPC = Source.MulticastRPC or {}
    for k, v in pairs(bh.MulticastRPC) do
      Source.MulticastRPC[k] = v
    end
  end
end
function MergePatialTool.MixinMany(Base, Source, PatialList)
  for _, Patial in ipairs(PatialList) do
    MergePatialTool.Mixin(Base, Source, Patial)
  end
end
function MergePatialTool.MergePatialClasses(Base, ClassList, MergedSelf)
  for _, Class in ipairs(ClassList) do
    MergePatialTool.MergePatialClass(Base, Class, MergedSelf)
  end
end
function MergePatialTool.MergePatialClass(Base, Patial, MergedSelf)
  local base = Base.__inner_impl
  local bh = Patial
  for k, v in pairs(bh) do
    if type(v) == "function" and k ~= "ctor" then
      if MergedSelf[k] then
        if ForceMergeFunctions[k] then
          if k == "ReceiveEndPlay" or k == "OnClose" then
            MergedSelf[k] = _merge_call(k, v, MergedSelf[k])
          else
            MergedSelf[k] = _merge_call(k, MergedSelf[k], v)
          end
        elseif MergedSelf[k .. "__MT"] == MergePatialTool.MT_Override then
        elseif MergedSelf[k .. "__MT"] == MergePatialTool.MT_After then
          MergedSelf[k] = _merge_call(k, v, MergedSelf[k])
        elseif MergedSelf[k .. "__MT"] == MergePatialTool.MT_First then
          MergedSelf[k] = _merge_call(k, MergedSelf[k], v)
        else
          MergedSelf[k] = _merge_call(k, MergedSelf[k], v)
        end
      elseif base[k] then
        if ForceMergeFunctions[k] then
          if k == "ReceiveEndPlay" or k == "OnClose" then
            MergedSelf[k] = _merge_call(k, v, base[k])
          else
            MergedSelf[k] = _merge_call(k, base[k], v)
          end
        elseif not Patial[k .. "__MT"] or Patial[k .. "__MT"] == MergePatialTool.MT_Override then
          MergedSelf[k] = v
        elseif Patial[k .. "__MT"] == MergePatialTool.MT_First then
          MergedSelf[k] = _merge_call(k, v, base[k])
        else
          MergedSelf[k] = _merge_call(k, base[k], v)
        end
      else
        MergedSelf[k] = v
      end
    end
  end
  if bh.ServerRPC and next(bh.ServerRPC) then
    MergedSelf.ServerRPC = MergedSelf.ServerRPC or {}
    for k, v in pairs(bh.ServerRPC) do
      MergedSelf.ServerRPC[k] = v
    end
  end
  if bh.ClientRPC and next(bh.ClientRPC) then
    MergedSelf.ClientRPC = MergedSelf.ClientRPC or {}
    for k, v in pairs(bh.ClientRPC) do
      MergedSelf.ClientRPC[k] = v
    end
  end
  if bh.MulticastRPC and next(bh.MulticastRPC) then
    MergedSelf.MulticastRPC = MergedSelf.MulticastRPC or {}
    for k, v in pairs(bh.MulticastRPC) do
      MergedSelf.MulticastRPC[k] = v
    end
  end
end
return MergePatialTool
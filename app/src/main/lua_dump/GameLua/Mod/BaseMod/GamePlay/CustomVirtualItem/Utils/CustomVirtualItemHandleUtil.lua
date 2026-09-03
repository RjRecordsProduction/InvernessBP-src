local CustomVirtualItemHandleUtil = {}
function CustomVirtualItemHandleUtil:InitAfterSetDefineID()
  if self.DefineID.TypeSpecificID == 0 then
    print(bWriteLog and "CustomVirtualItemHandleFeature:InitAfterSetDefineID invalid TypeSpecificID")
    return
  end
  local CustomVirtualItemSubsystem = SubsystemMgr:Get("CustomVirtualItemSubsystem")
  if CustomVirtualItemSubsystem then
    local Info = CustomVirtualItemSubsystem:GetHandleInfo(self.DefineID.TypeSpecificID)
    if Info then
      for Property, Data in pairs(Info) do
        if self[Property] and type(self[Property]) ~= "function" and type(self[Property]) == type(Data) then
          self[Property] = Data
        end
      end
      if Info.CallbackFunc and type(Info.CallbackFunc) == "function" then
        Info.CallbackFunc(self.Object)
      end
    end
  end
end
function CustomVirtualItemHandleUtil.InitHandle(Handle)
  rawset(Handle, "InitAfterSetDefineID", CustomVirtualItemHandleUtil.InitAfterSetDefineID)
end
function CustomVirtualItemHandleUtil.IsCustomItemID(id)
  if id == nil then
    return false
  end
  local idStr = tostring(id)
  if #idStr < 8 then
    return false
  end
  if idStr:sub(1, 5) ~= "30009" then
    return false
  end
  return true
end
return CustomVirtualItemHandleUtil
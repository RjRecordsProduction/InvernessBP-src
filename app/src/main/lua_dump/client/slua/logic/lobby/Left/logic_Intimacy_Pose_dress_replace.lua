local logic_Intimacy_Pose_dress_replace = {}
local SelfUid
local OriginDress = {}
function logic_Intimacy_Pose_dress_replace:DressReplaceCheck(pose, selfWearList, friendWearList, selfUid, friendUid)
  log(bWriteLog and string.format("[lesterzy] logic_Intimacy_Pose_dress_replace:DressReplaceCheck pose: %s, selfUid: %s, friendUid: %s", pose, selfUid, friendUid))
  local data = CDataTable.GetTable("DressReplace")
  local isReplace = false
  for i, v in pairs(data) do
    if pose == v.PoseId then
      log(bWriteLog and string.format("[lesterzy] CoupleAvatar:ReplaceSpecificDressByAnimation detected DressReplace Motion ID: %d", pose))
      for j, wear in pairs(selfWearList) do
        if wear[1] == v.main or wear[1] == v.sub then
          selfWearList[j][1] = v.sub
          OriginDress[selfUid] = {
            j,
            v.main
          }
          log(bWriteLog and string.format("[lesterzy] CoupleAvatar:ReplaceSpecificDressByAnimation Self Dress replace from ID:%d to ID:%d", v.main, v.sub))
          isReplace = true
        end
      end
      for j, wear in pairs(friendWearList) do
        if wear[1] == v.main or wear[1] == v.sub then
          friendWearList[j][1] = v.sub
          OriginDress[friendUid] = {
            j,
            v.main
          }
          log(bWriteLog and string.format("[lesterzy] CoupleAvatar:ReplaceSpecificDressByAnimation Friend Dress replace from ID:%d to ID:%d", v.main, v.sub))
          isReplace = true
        end
      end
    end
  end
  if isReplace then
    log(bWriteLog and string.format("[lesterzy] logic_Intimacy_Pose_dress_replace:DressReplaceCheck isReplace == ture"))
    ShowNotice(18130132)
    SelfUid = selfUid
    return
  end
  if OriginDress[selfUid] then
    log(bWriteLog and string.format("[lesterzy] logic_Intimacy_Pose_dress_replace:DressReplaceCheck OriginDress[selfUid]: %s", OriginDress[selfUid]))
    local idx = OriginDress[selfUid][1]
    selfWearList[idx][1] = OriginDress[selfUid][2]
    OriginDress[selfUid] = nil
  end
  if OriginDress[friendUid] then
    log(bWriteLog and string.format("[lesterzy] logic_Intimacy_Pose_dress_replace:DressReplaceCheck OriginDress[friendUid]: %s", OriginDress[friendUid]))
    local idx = OriginDress[friendUid][1]
    friendWearList[idx][1] = OriginDress[friendUid][2]
    OriginDress[friendUid] = nil
  end
end
function logic_Intimacy_Pose_dress_replace:CustomerViewProcess(uid, selfWearList)
  if OriginDress[uid] then
    log(bWriteLog and string.format("[lesterzy] logic_Intimacy_Pose_dress_replace:DressReplaceCheck OriginDress[uid]: %s", OriginDress[uid]))
    local idx = OriginDress[uid][1]
    selfWearList[idx][1] = OriginDress[uid][2]
    OriginDress[uid] = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CDressReplaceModule = class(CModuleBase, nil, logic_Intimacy_Pose_dress_replace)
return CDressReplaceModule
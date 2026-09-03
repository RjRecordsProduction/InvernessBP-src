local ugc_comment_reddot_data = {}
local RedDot
local bIsInited = false
local RedDotType = {
  Comment = 1,
  InGame = 1,
  InClub = 2
}
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local Category = reddot_macro.Category
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCComment,
    types = {
      newCount = 0,
      [RedDotType.Comment] = {
        newCount = 0,
        category = Category.Receive,
        subID = RedDotType.Comment,
        pages = {
          newCount = 0,
          [RedDotType.InGame] = {
            newCount = 0,
            subID = RedDotType.Comment,
            category = Category.Receive
          },
          [RedDotType.InClub] = {
            newCount = 0,
            subID = RedDotType.Comment,
            category = Category.Receive
          }
        }
      }
    }
  }
  return data
end
function ugc_comment_reddot_data.InitData()
  if bIsInited then
    return
  end
  bIsInited = true
  local data = GenerateData()
  local super_data = require("common.super_data")
  if RedDot == nil then
    RedDot = super_data.CreateSuperData(data)
  end
  local RedDotManager = require("client.slua.logic.reddot.reddot_manager")
  RedDotManager:Regist(RedDot)
end
function ugc_comment_reddot_data.DestroyData()
  RedDot = nil
  bIsInited = false
end
function ugc_comment_reddot_data.GetData()
  return RedDot
end
function ugc_comment_reddot_data.OnLogin()
  log(bWriteLog and "ugc_photo_reddot_data OnLogin")
  ugc_comment_reddot_data.InitData()
end
function ugc_comment_reddot_data.OnLogout()
  log(bWriteLog and "ugc_photo_reddot_data OnLogout")
  ugc_comment_reddot_data.DestroyData()
end
function ugc_comment_reddot_data.GetRedDot()
  return RedDot
end
function ugc_comment_reddot_data.GetCommentRedDot()
  if RedDot then
    return RedDot.types[RedDotType.Comment]
  end
end
function ugc_comment_reddot_data.GetSubRedDot(subID)
  if RedDot then
    local redDotType
    if subID == RedDotType.InGame then
      redDotType = RedDotType.InGame
    elseif subID == RedDotType.InClub then
      redDotType = RedDotType.InClub
    end
    if redDotType then
      return RedDot.types[RedDotType.Comment].pages[redDotType].newCount
    end
  end
  return 0
end
function ugc_comment_reddot_data.SetSubRedDot(subID, count)
  if RedDot then
    local redDotType
    if subID == RedDotType.InGame then
      redDotType = RedDotType.InGame
    elseif subID == RedDotType.InClub then
      redDotType = RedDotType.InClub
    end
    if redDotType then
      RedDot.types[RedDotType.Comment].pages[redDotType].newCount = count
    end
  end
end
function ugc_comment_reddot_data.ClearSubRedDot(subID)
  if RedDot then
    local redDotType
    if subID == RedDotType.InGame then
      redDotType = RedDotType.InGame
    elseif subID == RedDotType.InClub then
      redDotType = RedDotType.InClub
    end
    if redDotType then
      RedDot.types[RedDotType.Comment].pages[redDotType].newCount = 0
    end
  end
end
return ugc_comment_reddot_data
local StringUtil = {}
local local string_format = string.format
local string_gsub = string.gsub
local string_find = string.find
local string_sub = string.sub
local string_byte = string.byte
local string_char = string.char
local string_len = string.len
local ToPinyinFirstLetter = string.ToPinyinFirstLetter
local table_insert = table.insert
local table_concat = table.concat
local local math_fmod = math.fmod
local math_modf = math.modf
local math_floor = math.floor
local math_huge = math.huge
local local local local local local local local local FuncUtil = require("common.func_util")
local FuncUtil_GetDomainByID = FuncUtil.GetDomainByID
local FuncUtil_GetKeywordByID = FuncUtil.GetKeywordByID
local LocUtil = require("common.loc_util")
local LocUtil_LocalizeResFormat = LocUtil.LocalizeResFormat
function StringUtil.StrTrim(s)
  return (string_gsub(s, "^%s*(.-)%s*$", "%1"))
end
function StringUtil.EncodeURI(s)
  if type(s) == "string" then
    s = string_gsub(s, "\n", "\r\n")
    s = string_gsub(s, "([^%w ])", function(c)
      return string_format("%%%02X", string_byte(c))
    end)
    s = string_gsub(s, " ", "+")
  end
  return s
end
function StringUtil.DecodeURI(s)
  if type(s) == "string" then
    s = string_gsub(s, "%%(%x%x)", function(hex)
      return string_char(tonumber(hex, 16))
    end)
  end
  return s
end
function StringUtil.DecodeXML(str)
  local map = {
    lt = "<",
    gt = ">",
    amp = "&",
    quot = "\"",
    apos = "'"
  }
  str = string_gsub(str, "(&(#?x?)([%d%a]+);)", function(orig, n, s)
    return n == "" and map[s] or n == "#x" and tonumber(s, 16) and string_char(tonumber(s, 16)) or n == "#" and tonumber(s) and string_char(s) or orig
  end)
  return str
end
local ParserDeepLink = function(fsLink, sl_prefix_iOS, sl_prefix_AOS, ul_prefix, adj_prefix, region)
  local bParse = true
  if sl_prefix_iOS and string_find(fsLink, sl_prefix_iOS) == 1 then
    fsLink = string_gsub(fsLink, sl_prefix_iOS, "game://")
    if string_find(fsLink, "module") then
      fsLink = string_gsub(fsLink, "module", "?module")
    end
    local startAt = string_find(fsLink, "?adjust")
    if startAt then
      fsLink = string_sub(fsLink, 1, startAt - 1)
    end
    log(bWriteLog and string_format("AdjustParaAnalysis, [%s]fsLink = %s", region, tostring(fsLink)))
  elseif sl_prefix_AOS and string_find(fsLink, sl_prefix_AOS) == 1 then
    fsLink = string_gsub(fsLink, sl_prefix_AOS, "game")
    if string_find(fsLink, "module") then
      fsLink = string_gsub(fsLink, "module", "?module")
    end
    local startAt = string_find(fsLink, "?adjust")
    if startAt then
      fsLink = string_sub(fsLink, 1, startAt - 1)
    end
    log(bWriteLog and string_format("AdjustParaAnalysis, [%s]fsLink = %s", region, tostring(fsLink)))
  elseif ul_prefix and string_find(fsLink, ul_prefix) == 1 then
    local startAt = string_find(fsLink, "?module")
    if startAt then
      fsLink = string_sub(fsLink, startAt, string_len(fsLink))
      fsLink = "game://" .. fsLink
    end
    startAt = string_find(fsLink, "?adjust")
    if startAt then
      fsLink = string_sub(fsLink, 1, startAt - 1)
    end
    log(bWriteLog and string_format("AdjustParaAnalysis, universal link, [%s]fsLink = %s", region, tostring(fsLink)))
  elseif adj_prefix and string_find(fsLink, adj_prefix) ~= nil then
    local linkArr = StringUtil.Split(fsLink, "?")
    if 1 < #linkArr then
      fsLink = "game://?" .. linkArr[2]
    end
    log(bWriteLog and string_format("AdjustParaAnalysis, adjust link, [%s]fsLink = %s", region, tostring(fsLink)))
  else
    bParse = false
    log(bWriteLog and string_format("AdjustParaAnalysis, [%s]ignore.", region))
  end
  return bParse, fsLink
end
function StringUtil.AdjustParaAnalysis(validDeepLink)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bParse = false
  local fsLink = ""
  if 0 < string_len(validDeepLink) then
    if PublishRegionMacros.IsJapanOrKorea() then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366007) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1321", FuncUtil_GetDomainByID(3366104) .. "/ig/universallink/", nil, strRegion)
    elseif strRegion == PublishRegionMacros.VNG then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366008) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1380", FuncUtil_GetDomainByID(3366105) .. "/ig/universallink/", nil, strRegion)
    elseif strRegion == PublishRegionMacros.TW then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366009) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1390", FuncUtil_GetDomainByID(3366036) .. "/tw/universallinks/", nil, strRegion)
    elseif strRegion == PublishRegionMacros.BLUEHOLE then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366010) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1450", nil, FuncUtil_GetDomainByID(3366240), strRegion)
    elseif strRegion == PublishRegionMacros.FIT then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366011) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1440", nil, nil, strRegion)
    elseif strRegion == PublishRegionMacros.FITCE then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366011) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1440", nil, nil, strRegion)
    elseif strRegion == PublishRegionMacros.CE then
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366012) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1325", FuncUtil_GetDomainByID(3366036) .. "/ig/universallinks/", nil, strRegion)
    else
      bParse, fsLink = ParserDeepLink(validDeepLink, FuncUtil_GetDomainByID(3366012) .. "/", FuncUtil_GetKeywordByID(3377010) .. "1320", FuncUtil_GetDomainByID(3366036) .. "/ig/universallinks/", FuncUtil_GetDomainByID(3366239), strRegion)
    end
  else
    log(bWriteLog and "AdjustParaAnalysis, validDeepLink.length() = 0")
  end
  return bParse, fsLink
end
function StringUtil.ParseURLParams(s)
  local url_parser = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.url_parser)
  return url_parser:ParseURLParams(s)
end
function StringUtil.AppendUrlParam(url, key, value)
  if type(url) ~= "string" or url == "" then
    return url
  end
  if type(key) ~= "string" or key == "" then
    return url
  end
  if value == nil then
    return url
  end
  local pattern = "[?&]" .. key .. "="
  if string.find(url, pattern) then
    return url
  end
  local connector
  if string.find(url, "?", 1, true) then
    connector = "&"
  else
    connector = "?"
  end
  return url .. connector .. key .. "=" .. tostring(value)
end
function StringUtil.GetCharactersLength(utf8Str, chineseCharBytes)
  chineseCharBytes = chineseCharBytes or 1
  local length = 0
  local i = 1
  while i <= #utf8Str do
    local currCharLen = StringUtil.BytesOfCharacter(string_byte(utf8Str, i))
    length = length + (chineseCharBytes < currCharLen and chineseCharBytes or currCharLen)
    i = i + currCharLen
  end
  return length
end
function StringUtil.ClipString(str, maxLength, chineseCharBytes)
  chineseCharBytes = chineseCharBytes or 2
  local len = StringUtil.GetCharactersLength(str, chineseCharBytes)
  while maxLength < len do
    local CharactersByteLength = StringUtil.GetCharactersLength(str)
    str = StringUtil.SubString(str, 1, CharactersByteLength - 1)
    len = StringUtil.GetCharactersLength(str, chineseCharBytes)
  end
  return str
end
function StringUtil.BytesOfCharacter(byte)
  local separate = {
    0,
    192,
    224,
    240
  }
  for i = #separate, 1, -1 do
    if byte >= separate[i] then
      return i
    end
  end
  return 1
end
function StringUtil.CheckName(inputstr, symbol, maxLen, support_space)
  local unitLen = 0
  local hasIllegalChar = false
  local lenInByte = #inputstr
  local retStr = ""
  local i = 1
  local chinese1 = tonumber("E4B880", 16)
  local chinese2 = tonumber("E9BEBF", 16)
  local chineseSymbol = {
    "EFBC81",
    "EFBFA5",
    "E280A6",
    "E280A6",
    "EFBC88",
    "EFBC89",
    "E28094",
    "EFBD9B",
    "EFBD9D",
    "EFBC9A",
    "E2809C",
    "E2809D",
    "E3808A",
    "E3808B",
    "EFBC9F",
    "E38090",
    "E38091",
    "E38081",
    "EFBC9B",
    "E28098",
    "EFBC8C",
    "E38082",
    "E38081",
    "E28099"
  }
  local janpan1 = tonumber("E38180", 16)
  local janpan2 = tonumber("E3829F", 16)
  local janpan3 = tonumber("E382A0", 16)
  local janpan4 = tonumber("E383BF", 16)
  local janpan5 = tonumber("E38080", 16)
  local janpan6 = tonumber("E380BF", 16)
  local fullWidthNum1 = tonumber("EFBC90", 16)
  local fullWidthNum2 = tonumber("EFBC99", 16)
  local fullWidthClatin1 = tonumber("EFBCA1", 16)
  local fullWidthClatin2 = tonumber("EFBCBA", 16)
  local fullWidthSlatin1 = tonumber("EFBD81", 16)
  local fullWidthSlatin2 = tonumber("EFBD9A", 16)
  local halfWidthKata1 = tonumber("EFBDA6", 16)
  local halfWidthKata2 = tonumber("EFBE9D", 16)
  local korean1 = tonumber("EAB080", 16)
  local korean2 = tonumber("ED9EAF", 16)
  local korean3 = tonumber("E38480", 16)
  local korean4 = tonumber("E386BF", 16)
  local russia1 = tonumber("D080", 16)
  local russia2 = tonumber("D3Bf", 16)
  local russia3 = tonumber("D480", 16)
  local russia4 = tonumber("D4AF", 16)
  local tai1 = tonumber("E0B880", 16)
  local tai2 = tonumber("E0B9BF", 16)
  local EU_specail1 = tonumber("C2A1", 16)
  local EU_specail2 = tonumber("CAAf", 16)
  local Vietnamese1 = tonumber("E1B880", 16)
  local Vietnamese2 = tonumber("E1BBBF", 16)
  local Vietnamese3 = tonumber("CC80", 16)
  local Vietnamese4 = tonumber("CDBA", 16)
  local hindi1 = tonumber("E0A480", 16)
  local hindi2 = tonumber("E0A5BF", 16)
  local myanmar1 = tonumber("E18080", 16)
  local myanmar2 = tonumber("E1829F", 16)
  local arabic1 = tonumber("D880", 16)
  local arabic2 = tonumber("DBBF", 16)
  local UzbekSymbol = tonumber("CABB", 16)
  local isok = true
  local isTooLong = false
  local AddLen = function(wordLen)
    if maxLen and unitLen + wordLen > maxLen then
      isTooLong = true
      return
    end
    unitLen = unitLen + wordLen
    isok = true
  end
  while lenInByte >= i do
    local a = string_byte(inputstr, i)
    local byteCount = 1
    if 0 <= a and a < 192 then
      byteCount = 1
      unitLen = unitLen + 1
      isok = true
      if symbol ~= nil then
        if 0 <= a and a < 39 or 39 < a and a < 48 or 57 < a and a < 65 or 90 < a and a < 97 or 122 < a then
          isok = false
        end
      elseif 0 <= a and a < 32 or 126 < a then
        isok = false
      end
      if support_space ~= nil and a == 32 then
        isok = true
      end
      if isok then
        retStr = retStr .. string_char(a)
      else
        hasIllegalChar = true
      end
    elseif 192 <= a and a < 224 then
      byteCount = 2
      local b = string_byte(inputstr, i + 1)
      local str = string_format("%X", a) .. string_format("%X", b)
      local value = tonumber(str, 16)
      isok = false
      if russia1 <= value and russia2 >= value or russia3 <= value and russia4 >= value then
        log(bWriteLog and "checkname is Russia")
        AddLen(1)
      elseif EU_specail1 <= value and EU_specail2 >= value then
        log(bWriteLog and "checkname is EU special")
        AddLen(1)
      elseif Vietnamese3 <= value and Vietnamese4 >= value then
        log(bWriteLog and "checkname is vietnamese")
        AddLen(1)
      elseif arabic1 <= value and arabic2 >= value then
        log(bWriteLog and "checkname is arabic")
        AddLen(1)
      elseif (symbol == nil or symbol == true) and value == UzbekSymbol then
        log(bWriteLog and "checkname is symbol for Uzbek")
        AddLen(1)
      else
        unitLen = unitLen + 2
      end
      if isok then
        retStr = retStr .. string_sub(inputstr, i, i + byteCount - 1)
      else
        hasIllegalChar = true
      end
    elseif 224 <= a and a < 240 then
      byteCount = 3
      local b = string_byte(inputstr, i + 1) or 0
      local c = string_byte(inputstr, i + 2) or 0
      local str = string_format("%X", a) .. string_format("%X", b) .. string_format("%X", c)
      local value = tonumber(str, 16)
      isok = false
      if chinese1 <= value and chinese2 >= value then
        log(bWriteLog and "checkname is chinese")
        AddLen(2)
      elseif janpan1 <= value and janpan2 >= value then
        log(bWriteLog and "checkname is janpan1-2")
        AddLen(2)
      elseif janpan3 <= value and janpan4 >= value then
        log(bWriteLog and "checkname is janpan3-4")
        AddLen(2)
      elseif janpan5 <= value and janpan6 >= value then
        log(bWriteLog and "checkname is janpan5-6")
        AddLen(2)
      elseif fullWidthNum1 <= value and fullWidthNum2 >= value then
        log(bWriteLog and "checkname is fullWidthNum1-2")
        AddLen(2)
      elseif fullWidthClatin1 <= value and fullWidthClatin2 >= value then
        log(bWriteLog and "checkname is fullWidthClatin1-2")
        AddLen(2)
      elseif fullWidthSlatin1 <= value and fullWidthSlatin2 >= value then
        log(bWriteLog and "checkname is fullWidthSlatin1-2")
        AddLen(2)
      elseif halfWidthKata1 <= value and halfWidthKata2 >= value then
        log(bWriteLog and "checkname is halfWidthKata1-2")
        AddLen(1)
      elseif tai1 <= value and tai2 >= value then
        log(bWriteLog and "checkname is tai")
        AddLen(1)
      elseif Vietnamese1 <= value and Vietnamese2 >= value then
        log(bWriteLog and "checkname is vietnamese")
        AddLen(1)
      elseif korean1 <= value and korean2 >= value or korean3 <= value and korean4 >= value then
        log(bWriteLog and "checkname is korean")
        AddLen(2)
      elseif hindi1 <= value and hindi2 >= value then
        log(bWriteLog and "checkname is hindi")
        AddLen(2)
      elseif myanmar1 <= value and myanmar2 >= value then
        log(bWriteLog and "checkname is myanmar")
        AddLen(1)
      else
        unitLen = unitLen + 2
      end
      if not isok and symbol == nil then
        for _, v in ipairs(chineseSymbol) do
          if value == tonumber(v, 16) then
            isok = true
            break
          end
        end
      end
      if isok then
        retStr = retStr .. string_sub(inputstr, i, i + byteCount - 1)
      else
        hasIllegalChar = true
      end
    elseif 240 <= a and a < 248 then
      byteCount = 4
      unitLen = unitLen + 2
      hasIllegalChar = true
    elseif 248 <= a and a < 252 then
      byteCount = 5
      unitLen = unitLen + 2
      hasIllegalChar = true
    elseif 252 <= a then
      byteCount = 6
      unitLen = unitLen + 2
      hasIllegalChar = true
    end
    i = i + byteCount
    if isTooLong or maxLen ~= nil and maxLen <= unitLen then
      break
    end
  end
  return hasIllegalChar, unitLen, retStr
end
function StringUtil.CheckNameNew(inputstr, symbol, maxLen, support_space)
  local unitLen = 0
  local hasIllegalChar = false
  local lenInByte = #inputstr
  local retStr = ""
  local i = 1
  if symbol == nil then
    symbol = true
  end
  if support_space == nil then
    support_space = false
  end
  local chinese1 = tonumber("E4B880", 16)
  local chinese2 = tonumber("E9BEBF", 16)
  local chineseSymbol = {
    "EFBC81",
    "EFBFA5",
    "E280A6",
    "E280A6",
    "EFBC88",
    "EFBC89",
    "E28094",
    "EFBD9B",
    "EFBD9D",
    "EFBC9A",
    "E2809C",
    "E2809D",
    "E3808A",
    "E3808B",
    "EFBC9F",
    "E38090",
    "E38091",
    "E38081",
    "EFBC9B",
    "E28098",
    "EFBC8C",
    "E38082",
    "E38081",
    "E28099"
  }
  local janpan1 = tonumber("E38180", 16)
  local janpan2 = tonumber("E3829F", 16)
  local janpan3 = tonumber("E382A0", 16)
  local janpan4 = tonumber("E383BF", 16)
  local janpan5 = tonumber("E38080", 16)
  local janpan6 = tonumber("E380BF", 16)
  local fullWidthNum1 = tonumber("EFBC90", 16)
  local fullWidthNum2 = tonumber("EFBC99", 16)
  local fullWidthClatin1 = tonumber("EFBCA1", 16)
  local fullWidthClatin2 = tonumber("EFBCBA", 16)
  local fullWidthSlatin1 = tonumber("EFBD81", 16)
  local fullWidthSlatin2 = tonumber("EFBD9A", 16)
  local halfWidthKata1 = tonumber("EFBDA6", 16)
  local halfWidthKata2 = tonumber("EFBE9D", 16)
  local korean1 = tonumber("EAB080", 16)
  local korean2 = tonumber("ED9EAF", 16)
  local korean3 = tonumber("E38480", 16)
  local korean4 = tonumber("E386BF", 16)
  local russia1 = tonumber("D080", 16)
  local russia2 = tonumber("D3Bf", 16)
  local russia3 = tonumber("D480", 16)
  local russia4 = tonumber("D4AF", 16)
  local tai1 = tonumber("E0B880", 16)
  local tai2 = tonumber("E0B9BF", 16)
  local EU_specail1 = tonumber("C2A1", 16)
  local EU_specail2 = tonumber("CAAf", 16)
  local Vietnamese1 = tonumber("E1B880", 16)
  local Vietnamese2 = tonumber("E1BBBF", 16)
  local Vietnamese3 = tonumber("CC80", 16)
  local Vietnamese4 = tonumber("CDBA", 16)
  local hindi1 = tonumber("E0A480", 16)
  local hindi2 = tonumber("E0A5BF", 16)
  local myanmar1 = tonumber("E18080", 16)
  local myanmar2 = tonumber("E1829F", 16)
  local arabic1 = tonumber("D880", 16)
  local arabic2 = tonumber("DBBF", 16)
  local UzbekSymbol = tonumber("CABB", 16)
  local isok = true
  local isTooLong = false
  local AddLen = function(wordLen)
    if maxLen and unitLen + wordLen > maxLen then
      isTooLong = true
      return
    end
    unitLen = unitLen + wordLen
    isok = true
  end
  while lenInByte >= i do
    local a = string_byte(inputstr, i)
    local byteCount = 1
    if 0 <= a and a < 192 then
      byteCount = 1
      unitLen = unitLen + 1
      isok = true
      if symbol == false then
        if 0 <= a and a < 39 or 39 < a and a < 48 or 57 < a and a < 65 or 90 < a and a < 97 or 122 < a then
          isok = false
        end
      elseif 0 <= a and a < 32 or 126 < a then
        isok = false
      end
      if support_space ~= true and a == 32 then
        isok = false
      end
      if isok then
        retStr = retStr .. string_char(a)
      else
        hasIllegalChar = true
      end
    elseif 192 <= a and a < 224 then
      byteCount = 2
      local b = string_byte(inputstr, i + 1)
      local str = string_format("%X", a) .. string_format("%X", b)
      local value = tonumber(str, 16)
      isok = false
      if russia1 <= value and russia2 >= value or russia3 <= value and russia4 >= value then
        log(bWriteLog and "checkname is Russia")
        AddLen(1)
      elseif EU_specail1 <= value and EU_specail2 >= value then
        log(bWriteLog and "checkname is EU special")
        AddLen(1)
      elseif Vietnamese3 <= value and Vietnamese4 >= value then
        log(bWriteLog and "checkname is vietnamese")
        AddLen(1)
      elseif arabic1 <= value and arabic2 >= value then
        log(bWriteLog and "checkname is arabic")
        AddLen(1)
      elseif (symbol == nil or symbol == true) and value == UzbekSymbol then
        log(bWriteLog and "checkname is symbol for Uzbek")
        AddLen(1)
      else
        unitLen = unitLen + 2
      end
      if isok then
        retStr = retStr .. string_sub(inputstr, i, i + byteCount - 1)
      else
        hasIllegalChar = true
      end
    elseif 224 <= a and a < 240 then
      byteCount = 3
      local b = string_byte(inputstr, i + 1)
      local c = string_byte(inputstr, i + 2)
      local str = string_format("%X", a) .. string_format("%X", b) .. string_format("%X", c)
      local value = tonumber(str, 16)
      isok = false
      if chinese1 <= value and chinese2 >= value then
        log(bWriteLog and "checkname is chinese")
        AddLen(2)
      elseif janpan1 <= value and janpan2 >= value then
        log(bWriteLog and "checkname is janpan1-2")
        AddLen(2)
      elseif janpan3 <= value and janpan4 >= value then
        log(bWriteLog and "checkname is janpan3-4")
        AddLen(2)
      elseif janpan5 <= value and janpan6 >= value then
        log(bWriteLog and "checkname is janpan5-6")
        AddLen(2)
      elseif fullWidthNum1 <= value and fullWidthNum2 >= value then
        log(bWriteLog and "checkname is fullWidthNum1-2")
        AddLen(2)
      elseif fullWidthClatin1 <= value and fullWidthClatin2 >= value then
        log(bWriteLog and "checkname is fullWidthClatin1-2")
        AddLen(2)
      elseif fullWidthSlatin1 <= value and fullWidthSlatin2 >= value then
        log(bWriteLog and "checkname is fullWidthSlatin1-2")
        AddLen(2)
      elseif halfWidthKata1 <= value and halfWidthKata2 >= value then
        log(bWriteLog and "checkname is halfWidthKata1-2")
        AddLen(1)
      elseif tai1 <= value and tai2 >= value then
        log(bWriteLog and "checkname is tai")
        AddLen(1)
      elseif Vietnamese1 <= value and Vietnamese2 >= value then
        log(bWriteLog and "checkname is vietnamese")
        AddLen(1)
      elseif korean1 <= value and korean2 >= value or korean3 <= value and korean4 >= value then
        log(bWriteLog and "checkname is korean")
        AddLen(2)
      elseif hindi1 <= value and hindi2 >= value then
        log(bWriteLog and "checkname is hindi")
        AddLen(2)
      elseif myanmar1 <= value and myanmar2 >= value then
        log(bWriteLog and "checkname is myanmar")
        AddLen(1)
      else
        unitLen = unitLen + 2
      end
      if not isok and symbol ~= false then
        for _, v in ipairs(chineseSymbol) do
          if value == tonumber(v, 16) then
            isok = true
            break
          end
        end
      end
      if isok then
        retStr = retStr .. string_sub(inputstr, i, i + byteCount - 1)
      else
        hasIllegalChar = true
      end
    elseif 240 <= a and a < 248 then
      byteCount = 4
      unitLen = unitLen + 2
      hasIllegalChar = true
    elseif 248 <= a and a < 252 then
      byteCount = 5
      unitLen = unitLen + 2
      hasIllegalChar = true
    elseif 252 <= a then
      byteCount = 6
      unitLen = unitLen + 2
      hasIllegalChar = true
    end
    i = i + byteCount
    if isTooLong or maxLen ~= nil and maxLen <= unitLen then
      break
    end
  end
  return hasIllegalChar, unitLen, retStr
end
function StringUtil.CheckNameRetrunName(inputstr, symbol, maxLen, support_space)
  local _, _, retStr = StringUtil.CheckName(inputstr, symbol, maxLen, support_space)
  return retStr
end
function StringUtil.Starts(__String, Start)
  return string_sub(__String, 1, string_len(Start)) == Start
end
function StringUtil.Ends(__String, End)
  return End == "" or string_sub(__String, -string_len(End)) == End
end
function StringUtil.Split(str, sep, count)
  return string.StrSplit(str, sep, count)
end
function StringUtil.SplitToNum(str, sep, count)
  return string.StrSplitToNum(str, sep, count)
end
function StringUtil.SplitToItems(str, sep, sep1)
  local items = StringUtil.Split(str, sep)
  local len = #items
  for i = 1, len do
    items[i] = StringUtil.SplitToNum(items[i], sep1)
  end
  return items
end
function StringUtil.StrReplace(src, pattern, des, times)
  return string.StrReplace(src, pattern, des, times)
end
function StringUtil.StrFind(src, pattern)
  return string.find(src, pattern, 1, true)
end
function StringUtil.SubString(str, subBegin, subEnd)
  if not str then
    return ""
  end
  local beginIdxArray = {}
  local endIdxArray = {}
  local idx = 1
  while idx <= #str do
    local b, e = string_find(str, "[%z\001-\127\194-\244][\128-\191]*", idx)
    beginIdxArray[#beginIdxArray + 1] = b
    endIdxArray[#endIdxArray + 1] = e
    if subEnd <= #beginIdxArray then
      break
    end
    idx = e + 1
  end
  if subBegin > #beginIdxArray then
    return ""
  end
  local endIndex = endIdxArray[math.min(#endIdxArray, subEnd)]
  return string_sub(str, beginIdxArray[subBegin], endIndex)
end
local KeyArrayCache = {}
function StringUtil.EncodeXOR_Lua(message, isEncoding, key)
  if key == nil then
    local BusinessHelper = import("BusinessHelper")
    key = BusinessHelper.GetXORKey()
  end
  local tonumber, table = tonumber, table
  local key_array = KeyArrayCache[key]
  if not key_array then
    key_array = {}
    for i = 1, #key / 2 do
      key_array[#key_array + 1] = tonumber(key:sub((i - 1) * 2 + 1, i * 2), 16)
    end
    KeyArrayCache[key] = key_array
  end
  local message_array = {}
  if isEncoding then
    for i = 1, #message do
      message_array[#message_array + 1] = string_byte(message, i)
    end
  else
    for i = 1, #message, 2 do
      local hex_pair = message:sub(i, i + 1)
      if #hex_pair == 2 then
        message_array[#message_array + 1] = tonumber(hex_pair, 16)
      end
    end
  end
  local text = {}
  local lenKeyArray = #key_array
  for i = 1, #message_array do
    local msg_char = message_array[i]
    local key_index = (i - 1) % lenKeyArray + 1
    local key_int = key_array[key_index]
    msg_char = msg_char or 0
    if isEncoding then
      text[#text + 1] = string.format("%02x", msg_char ~ key_int)
    else
      text[#text + 1] = string.char(msg_char ~ key_int)
    end
  end
  return table.concat(text, "")
end
function StringUtil.EncodeXOR(message, isEncoding, key)
  local BusinessHelper = import("BusinessHelper")
  if key == nil then
    key = BusinessHelper.GetXORKey()
  end
  return BusinessHelper.XorEncryptDecrypt(message, isEncoding, key)
end
function StringUtil.uid_to_short_code(uid)
  local abc_list = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  }
  local ret_table = {}
  local uid_num = tonumber(uid)
  repeat
    local index = math_fmod(uid_num, 36)
    uid_num = math_modf(uid_num / 36)
    table_insert(ret_table, 1, abc_list[index + 1])
  until uid_num <= 0
  return string.upper(table_concat(ret_table))
end
function StringUtil.short_code_to_uid(short_code)
  if not short_code or short_code == "" then
    return nil
  end
  local code = string.upper(short_code)
  local uid_num = 0
  for i = 1, string_len(code) do
    local ch = string.sub(code, i, i)
    local byte = string.byte(ch)
    local value
    if 48 <= byte and byte <= 57 then
      value = byte - 48
    elseif 65 <= byte and byte <= 90 then
      value = byte - 55
    else
      return nil
    end
    uid_num = uid_num * 36 + value
  end
  return uid_num
end
function StringUtil.check_short_code(short_code)
  local len = string_len(short_code)
  if 8 < len or len < 6 then
    return false
  end
  local match = "^[%d%u]+$"
  return string_find(short_code, match)
end
function StringUtil.FormatNum_Million(num)
  if 1000000.0 <= num then
    num = math_floor(num / 100000.0)
    return LocUtil_LocalizeResFormat(9098, string_format("%.0f", num / 10))
  else
    return tostring(num)
  end
end
function StringUtil.FormatNum_KMB(num, sFormat)
  sFormat = sFormat or "%.2f"
  if 1.0E9 <= num then
    num = math_floor(num / 1.0E7)
    return LocUtil_LocalizeResFormat(44211, string_format(sFormat, num / 100))
  elseif 1000000.0 <= num then
    num = math_floor(num / 10000.0)
    return LocUtil_LocalizeResFormat(8800193, string_format(sFormat, num / 100))
  elseif 1000.0 <= num then
    num = math_floor(num / 10)
    return LocUtil_LocalizeResFormat(44209, string_format(sFormat, num / 100))
  else
    return tostring(num)
  end
end
function StringUtil.FormatNumDecimal_KMB(num, sFormat)
  sFormat = sFormat or "%.2f"
  if 1.0E9 <= num then
    num = math_floor(num / 1.0E7)
    return LocUtil_LocalizeResFormat(44211, string_format(sFormat, num / 100))
  elseif 1000000.0 <= num then
    num = math_floor(num / 10000.0)
    return LocUtil_LocalizeResFormat(8800193, string_format(sFormat, num / 100))
  elseif 1000.0 <= num then
    num = math_floor(num / 10)
    return LocUtil_LocalizeResFormat(44209, string_format(sFormat, num / 100))
  else
    return string_format(sFormat, num)
  end
end
function StringUtil.FormatNumATWill_KMB(num, sFormat)
  sFormat = sFormat or "%.2f"
  if 1.0E9 <= num then
    num = math_floor(num / 1.0E7)
    if math.floor(num) == num then
      return LocUtil_LocalizeResFormat(44211, string_format("%.0f", num / 100))
    else
      return LocUtil_LocalizeResFormat(44211, string_format(sFormat, num / 100))
    end
  elseif 1000000.0 <= num then
    num = math_floor(num / 10000.0)
    if math.floor(num) == num then
      return LocUtil_LocalizeResFormat(8800193, string_format("%.0f", num / 100))
    else
      return LocUtil_LocalizeResFormat(8800193, string_format(sFormat, num / 100))
    end
  elseif 1000.0 <= num then
    num = math_floor(num / 10)
    if math.floor(num) == num then
      return LocUtil_LocalizeResFormat(44209, string_format("%.0f", num / 100))
    else
      return LocUtil_LocalizeResFormat(44209, string_format(sFormat, num / 100))
    end
  elseif math.floor(num) == num then
    return string_format("%.0f", num)
  else
    return math.ceil(num * 10) / 10
  end
end
function StringUtil.FormatNumRound_Up(num, sFormat)
  local SFormat = sFormat
  local factor = 10 ^ SFormat
  return math.ceil(num * factor) / factor
end
function StringUtil.FormatNumWithSpace_KMB(num, sFormat)
  sFormat = sFormat or "%.2f"
  if 1.0E9 <= num then
    num = math_floor(num / 1.0E7)
    return LocUtil_LocalizeResFormat(63026, string_format(sFormat, num / 100))
  elseif 1000000.0 <= num then
    num = math_floor(num / 10000.0)
    return LocUtil_LocalizeResFormat(63025, string_format(sFormat, num / 100))
  elseif 1000.0 <= num then
    num = math_floor(num / 10)
    return LocUtil_LocalizeResFormat(63024, string_format(sFormat, num / 100))
  else
    return tostring(num)
  end
end
function StringUtil.FormatNumWithSpace_KMBT(num, sFormat)
  sFormat = sFormat or "%.2f"
  if 1.0E12 <= num then
    num = math_floor(num / 1.0E10)
    return string_format(sFormat, num / 100) .. " T"
  elseif 1.0E9 <= num then
    num = math_floor(num / 1.0E7)
    return LocUtil_LocalizeResFormat(63026, string_format(sFormat, num / 100))
  elseif 1000000.0 <= num then
    num = math_floor(num / 10000.0)
    return LocUtil_LocalizeResFormat(63025, string_format(sFormat, num / 100))
  elseif 1000.0 <= num then
    num = math_floor(num / 10)
    return LocUtil_LocalizeResFormat(63024, string_format(sFormat, num / 100))
  else
    return tostring(num)
  end
end
function StringUtil.FormatSimpleNumByString(str)
  local num = tonumber(str)
  if 1000.0 <= num then
    num = math_floor(num / 100.0)
    return string_format("%.1f", num / 10) .. "K"
  else
    return tostring(num)
  end
end
function StringUtil.HasArChar(text)
  local _, len = StringUtil.CheckName(text, false, nil, true)
  local _, count = string_gsub(text, "[\216-\219][\128-\191]", "")
  return 5 <= len and 0.5 <= count / len
end
function StringUtil.CheckStringLegal(input_str, type)
  local match = ""
  if type == 1 then
    match = "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?"
  elseif type == 2 then
    match = "^%d+$"
  elseif type == 3 then
    match = "^%w+$"
  end
  return string.match(input_str, match) ~= nil
end
function StringUtil.CheckAreaCodeLegal(code)
  local ecTable = CDataTable.GetTable("EuropeanCountries")
  for _, v in pairs(ecTable) do
    if v.AreaCode == code and v.IsEEU == true then
      return false
    end
  end
  return true
end
local charsize = function(ch)
  if not ch then
    return 0
  elseif 252 <= ch then
    return 6
  elseif 248 <= ch and ch < 252 then
    return 5
  elseif 240 <= ch and ch < 248 then
    return 4
  elseif 224 <= ch and ch < 240 then
    return 3
  elseif 192 <= ch and ch < 224 then
    return 2
  elseif ch < 192 then
    return 1
  end
end
function StringUtil.get_utf8_blen(string_input)
  local len = 0
  local currentIndex = 1
  while currentIndex <= #string_input do
    local currentchar = string_byte(string_input, currentIndex)
    local cs = charsize(currentchar)
    currentIndex = currentIndex + cs
    if cs == 1 then
      len = len + 1
    elseif 2 <= cs then
      len = len + 2
    end
  end
  return len
end
function StringUtil.cut_utf8_blen(string_input, length)
  local len = 0
  local currentIndex = 1
  while currentIndex <= #string_input do
    local currentchar = string_byte(string_input, currentIndex)
    local cs = charsize(currentchar)
    currentIndex = currentIndex + cs
    if cs == 1 then
      len = len + 1
    elseif 2 <= cs then
      len = len + 2
    end
    if length < len then
      currentIndex = currentIndex - cs
      break
    end
  end
  local outStr = ""
  if 1 < currentIndex then
    outStr = string_sub(string_input, 1, currentIndex - 1)
  end
  return outStr, len
end
function StringUtil.Gmatch(s, pattern)
  local i = 1
  local closure = function()
    local _, rEnd, x, y, z = string_find(s, pattern, i)
    if rEnd and 0 < rEnd then
      i = rEnd + 1
      return x, y, z
    else
      return nil
    end
  end
  return closure
end
function StringUtil.GmatchWithCallback(s, pattern, callback)
  local x, y, z, start, rEnd, n
  n = #s
  local i = 1
  while n > i do
    start, rEnd, x, y, z = string_find(s, pattern, i)
    if 0 < rEnd then
      if callback then
        callback(x, y, z)
      end
      i = rEnd + 1
    else
      break
    end
  end
end
function StringUtil.InsertString(s, insert, step)
  if not insert or not step then
    return s
  end
  local len = #s
  if step > len then
    return s
  end
  local tbLen = len // step + 1
  local result = prealloctable(tbLen, 0)
  for i = 1, math_huge do
    local start = step * (i - 1) + 1
    if len < start then
      break
    end
    local sEnd = start + step - 1
    if len < sEnd then
      sEnd = len
    end
    result[i] = s:sub(start, sEnd)
  end
  return table_concat(result, insert)
end
function StringUtil.CheckStringStartsWithSpace(string_input)
  local stringLength = #string_input
  if 0 < stringLength then
    local c = string_byte(string_input, 1)
    if c == 32 then
      return true
    end
  end
  return false
end
function StringUtil.RemoveLeadingSpaces(string_input)
  return string_gsub(string_input, "^%s+", "")
end
local ZeroByte = 48
local NineByte = 58
local AByte = 65
local ZByte = 90
local aByte = 97
local zByte = 122
local SpaceByte = 32
function StringUtil.IsEnglish(byte)
  return byte >= AByte and byte <= ZByte or byte >= aByte and byte <= zByte
end
function StringUtil.IsSpace(byte)
  return byte == SpaceByte
end
function StringUtil.IsNumber(byte)
  return byte >= ZeroByte and byte <= NineByte
end
local DefaultVector3 = {
  FVector.ZeroVector,
  FRotator.ZeroRotator,
  FVector.OneVector
}
function StringUtil.Str2Vector3(str, vector3Type)
  local vec = {
    x_f = 1,
    y_f = 1,
    z_f = 1
  }
  if str and str ~= "" then
    local arr = StringUtil.Split(str, ";")
    if arr and #arr == 3 then
      vec = {
        x_f = tonumber(arr[1]),
        y_f = tonumber(arr[2]),
        z_f = tonumber(arr[3])
      }
    end
  end
  if not str or str == "" then
    return DefaultVector3[vector3Type]
  end
  if vector3Type == 1 then
    return FVector(vec.x_f, vec.y_f, vec.z_f)
  elseif vector3Type == 2 then
    return FRotator(vec.y_f, vec.z_f, vec.x_f)
  elseif vector3Type == 3 then
    return FVector(vec.x_f, vec.y_f, vec.z_f)
  end
end
function StringUtil.GetValidString(orgStr, maxLen, bSupportEn, bSupportNum)
  local retLen = 0
  local retStr = ""
  local bLink
  for i = 1, #orgStr do
    if maxLen <= retLen then
      return retStr
    end
    bLink = true
    local byte = string_byte(orgStr, i)
    if not bSupportEn and StringUtil.IsEnglish(byte) then
      bLink = false
    end
    if not bSupportNum and StringUtil.IsNumber(byte) then
      bLink = false
    end
    if bLink then
      retStr = retStr .. string_char(byte)
      retLen = retLen + 1
    end
  end
  return retStr
end
function StringUtil.GetValidString_EnglishOrNumber(orgStr, maxLen)
  local retLen = 0
  local retStr = ""
  for i = 1, #orgStr do
    if maxLen <= retLen then
      return retStr
    end
    local byte = string_byte(orgStr, i)
    if StringUtil.IsEnglish(byte) or StringUtil.IsNumber(byte) then
      retStr = retStr .. string_char(byte)
      retLen = retLen + 1
    end
  end
  return retStr
end
function StringUtil.ToPinyinFirstLetter(str)
  if ToPinyinFirstLetter then
    return ToPinyinFirstLetter(str)
  end
end
function StringUtil.StringToRotator(str, sep)
  local Rotator
  sep = sep or ";"
  if str and str ~= "" then
    local list = StringUtil.Split(str, sep)
    Rotator = FRotator(tonumber(list[2]), tonumber(list[3]), tonumber(list[1]))
  end
  return Rotator
end
function StringUtil.StringToVector(str, sep)
  local vector
  sep = sep or ";"
  if str and str ~= "" then
    local list = StringUtil.Split(str, sep)
    vector = FVector(tonumber(list[1]), tonumber(list[2]), tonumber(list[3]))
  end
  return vector
end
function StringUtil.GetShortStringByNum(num)
  if 1.0E9 <= num then
    return string.format("%.2fB", num / 1.0E9)
  elseif 1000000.0 <= num then
    return string.format("%.2fM", num / 1000000.0)
  elseif 1000.0 <= num then
    return string.format("%.2fK", num / 1000.0)
  else
    return string.format("%d", num)
  end
end
function StringUtil.GetShortStringByNaturalNum(num)
  if 1.0E9 <= num then
    return string.format("%.0fB", num / 1.0E9)
  elseif 1000000.0 <= num then
    return string.format("%.0fM", num / 1000000.0)
  elseif 1000.0 <= num then
    return string.format("%.0fK", num / 1000.0)
  else
    return string.format("%.0f", num)
  end
end
function StringUtil:CheckStringWithSpace(string_input)
  local stringLength = #string_input
  local i = 1
  while stringLength >= i do
    local c = string_byte(string_input, i)
    if c ~= 32 then
      return false
    end
    i = i + 1
  end
  return true
end
function StringUtil.FilterNumbersAndDot(input_str)
  if not input_str or input_str == "" then
    return ""
  end
  local result = ""
  for i = 1, #input_str do
    local char = string_sub(input_str, i, i)
    local byte = string_byte(char)
    if 48 <= byte and byte <= 57 or byte == 46 then
      result = result .. char
    end
  end
  return result
end
function StringUtil.NormalizeFloatNumber(input_str)
  if not input_str or input_str == "" then
    return "1"
  end
  local filtered_str = StringUtil.FilterNumbersAndDot(input_str)
  if filtered_str == "" then
    return "1"
  end
  local first_dot_index = string_find(filtered_str, "%.")
  if first_dot_index == 1 then
    filtered_str = "0" .. filtered_str
  elseif first_dot_index then
    local before_first_dot = string_sub(filtered_str, 1, first_dot_index - 1)
    local has_number_before_dot = false
    for i = 1, #before_first_dot do
      local char = string_sub(before_first_dot, i, i)
      local byte = string_byte(char)
      if 48 <= byte and byte <= 57 then
        has_number_before_dot = true
        break
      end
    end
    if not has_number_before_dot then
      filtered_str = "0" .. filtered_str
    end
  end
  local dot_count = 0
  local last_valid_index = #filtered_str
  for i = 1, #filtered_str do
    local char = string_sub(filtered_str, i, i)
    if char == "." then
      dot_count = dot_count + 1
      if dot_count == 2 then
        last_valid_index = i - 1
        break
      end
    end
  end
  local result = string_sub(filtered_str, 1, last_valid_index)
  if result == "" then
    return "1"
  end
  if string_sub(result, -1) == "." then
    result = string_sub(result, 1, -2)
  end
  if result == "" then
    return "1"
  end
  return result
end
return StringUtil
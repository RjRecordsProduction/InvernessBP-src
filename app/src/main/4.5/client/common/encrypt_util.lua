local encrypt_util = {pubkey_file_name = "pubkey.pem"}
function encrypt_util:TEA2Encryption(content, with_base64_encoding, magic)
  if magic == nil then
    magic = self:GetTeaMagic()
  end
  if with_base64_encoding == nil then
    with_base64_encoding = false
  end
  local encrypt_data = Client.Tea2Encrypt(content, magic)
  if with_base64_encoding then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local base64Str = base64.EncodeBase64(encrypt_data)
    return base64Str
  else
    return encrypt_data
  end
end
function encrypt_util:TEA2Decryption(content, with_base64_decoding, magic)
  if magic == nil then
    magic = self:GetTeaMagic()
  end
  if with_base64_decoding == nil then
    with_base64_decoding = false
  end
  if with_base64_decoding then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    content = base64.DecodeBase64(content)
  end
  local orginal = Client.Tea2Decrypt(content, magic)
  return orginal
end
function encrypt_util:GetTeaMagic()
  return "7vu#CH5aJjs1Jjj5"
end
function encrypt_util:RSAEncryption(content, with_base64_encoding, pubkey)
  if pubkey == nil then
    pubkey = self:GetPubkey()
  end
  if with_base64_encoding == nil then
    with_base64_encoding = false
  end
  local BusinessHelper = import("BusinessHelper")
  local keyPath = BusinessHelper.GetMobileBasePath(Client.ProjectSavedDir()) .. encrypt_util.pubkey_file_name
  Client.SaveStringToFileWithEncoding(pubkey, encrypt_util.pubkey_file_name, 1)
  local encrypt_data = Client.RSAPubEncrypt(content, keyPath, 2)
  if encrypt_data == nil or type(encrypt_data) ~= "string" then
    return nil
  end
  Client.DeleteFile(keyPath)
  if with_base64_encoding then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local base64Str = base64.EncodeBase64(encrypt_data)
    return base64Str
  else
    return encrypt_data
  end
end
function encrypt_util:RSADecryption(content, with_base64_decoding, pubkey)
  if pubkey == nil then
    pubkey = self:GetPubkey()
  end
  if with_base64_decoding == nil then
    with_base64_decoding = false
  end
  if with_base64_decoding then
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    content = base64.DecodeBase64(content)
  end
  local BusinessHelper = import("BusinessHelper")
  local keyPath = BusinessHelper.GetMobileBasePath(Client.ProjectSavedDir()) .. encrypt_util.pubkey_file_name
  Client.SaveStringToFileWithEncoding(pubkey, encrypt_util.pubkey_file_name, 1)
  local orginal = Client.RSAPubDecrypt(content, keyPath)
  Client.DeleteFile(keyPath)
  return orginal
end
function encrypt_util:GetPubkey()
  local pubkey = "cc8026492c9b3ebe9a9518e3236518c24ab6aa48d39363e990026bee7c7b2820eebb21152cde4ba6b2906b9039e5ee2093cc2e51bcadbff61d3973746aed740ba2ca402740883eb8a9f47ecb42533efc5df3a063e2dd0a82c97e0b8d3c38190ffdbb12695ded5887b38d439452e6b20fe0cd244db79ab4fd3b3b1a6614e3092c82e95a1e59bc2294b6eb70fa146460e245fc8241ee8816b7fc640d8550776c68e489576225f61485a39d45b44ea4aa2de4d10260be869b9e3021247769f4162cafcf4107658a1590a9ed60fa315619ce51e2ca55dbf176b58f691cd65d535531aadb146a2cf26bb5a3c2358647d8b90d9fd45a2692a1c7d23209285d1fcf5f068df75a52628e4f8891b562de1d570ec338a3d926e2ff259cdb7b0e89677331529e996d515f816aa18dbd67a049d7a756bcdc0346ac9bb9fe1e20077352cd7c71a7953b0c638d4eb2829f13e000451fe03ee6913cc78c0a95fa6249bc67605928cee5050c63b34db0b79266857acb9f2b86c9094ebbdfc2f1325007596ccd7770b9cf64084f83399f9bbc77d9591466dd51d0d262c7c861fcc46e2d92590a201af0b50b6d29f22dddadaa4b9341c39f20df97463ad0c1ddf0122c6b6572e67100a28d402158f456d4fef635b9"
  local key = "e1ad0b6401d97bf9d3db38b37627548b0996e10d8abe4ec4bd2f66e431326162a7d1605b6eb920d7dafb02d70092de62d29d6b17fdecf0b55c684b3527a43d49"
  local StringUtil = require("common.string_util")
  pubkey = StringUtil.EncodeXOR(pubkey, false, key)
  return pubkey
end
function encrypt_util:CommonXOREncryption(content, key)
  if key == nil then
    key = "56d319858332f71568bd1f69a69bd08bf8fd384b73eba9afd4e2f4f1db7deccb27d028b0fd546faad6b473a5902b6de78a012e52467e8260e3aa0d8786d711cf"
  end
  local StringUtil = require("common.string_util")
  local result = StringUtil.EncodeXOR(content, true, key)
  return result
end
function encrypt_util:CommonXORDecryption(content, key)
  if key == nil then
    key = "56d319858332f71568bd1f69a69bd08bf8fd384b73eba9afd4e2f4f1db7deccb27d028b0fd546faad6b473a5902b6de78a012e52467e8260e3aa0d8786d711cf"
  end
  local StringUtil = require("common.string_util")
  local result = StringUtil.EncodeXOR(content, false, key)
  return result
end
return encrypt_util
#pragma once
#include <string>
#include <locale>
#include <codecvt>

inline std::u16string ToUTF16(const char* text) {
    try {
        std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> convert;
        return convert.from_bytes(text);
    } catch (...) {
        std::u16string out;
        while (*text) {
            out.push_back((char16_t)*text);
            text++;
        }
        return out;
    }
}

using MessageBoxExtType = int (*)(unsigned int, const char16_t *, const char16_t *, unsigned int);
inline MessageBoxExtType MessageBoxExt = nullptr;

inline void InitMessageBox(uintptr_t funcAddress) {
    if (funcAddress != 0) {
        MessageBoxExt = reinterpret_cast<MessageBoxExtType>(funcAddress);
    }
}

inline int ShowMessageBox(const char* title, const char* msg, unsigned int msgType = 0) {
    if (!MessageBoxExt) return -1;
    
    auto askTitle = ToUTF16(title);
    auto askMsg = ToUTF16(msg);
    
    // The first parameter determines the button layout (0 = OK, 1 = Yes/No)
    return MessageBoxExt(msgType, askMsg.c_str(), askTitle.c_str(), 0);
}

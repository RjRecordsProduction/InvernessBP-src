#pragma once
#include <vector>
#include <cstdint>
#include <cstdlib>
#include "oxorany/oxorany.h"

// Signatures/Patterns for memory scanning
#define SIG_VIEWMATRIX HIDE_STR("? ? ? E9 ? ? ? E2 ? ? ? E2 ? ? ? ED ? ? ? E2 01 70 A0 E1 ? ? ? E2 00 40 A0 E1")
#define SIG_IDK HIDE_STR("F0 4F 2D E9 ? ? ? E2 ? ? ? E2 02 8B 2D ED ? ? ? E2 ? ? ? E7 ? ? ? E5 00 40 A0 E1 ? ? ? E5 ? ? ? E5 ? ? ? E7 ? ? ? ED")

#define SIG_DISABLEEMUDETECTION HIDE_STR("F0 4F 2D E9 ? ? ? E2 ? ? ? E2 00 A0 A0 E1 ? ? ? E5 ? ? ? E7 ? ? ? E5 00 00 50 E3 ? ? ? 0A 01 90 A0 E1")
#define SIG_DISABLEFPSLIMITS HIDE_STR("F0 4D 2D E9 ? ? ? E2 04 8B 2D ED ? ? ? E2 ? ? ? ED 01 40 A0 E1")
#define SIG_LUAL_LOADBUFFERX HIDE_STR("00 48 2D E9 ? ? ? E2 ? ? ? E2 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E2 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 03 30 8F E0")
#define SIG_LUA_PCALLX HIDE_STR("00 48 2D E9 ? ? ? E2 ? ? ? E2 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 ? ? ? E5 00 00 53 E3 ? ? ? 1A 00 30 A0 E3 ? ? ? E5")
#define SIG_MESSAGEBOX HIDE_STR("F0 4F 2D E9 ? ? ? E2 ? ? ? E2 ? ? ? E5 ? ? ? E2 02 40 A0 E1 01 A0 A0 E1")
#define SIG_FAKE_DAMAGE HIDE_STR("? ? ? E9 ? ? ? E2 ? ? ? E2 ? ? ? ED ? ? ? E2 01 90 A0 E1 00 40 A0 E1 0D 10 A0 E1")

inline uintptr_t findPattern(uintptr_t base, size_t size, const char* pattern) {
    std::vector<int> patternBytes;
    const char* current = pattern;
    while (*current) {
        if (*current == ' ') {
            current++;
            continue;
        }
        if (*current == '?') {
            patternBytes.push_back(-1);
            current++;
            if (*current == '?') current++;
        } else {
            patternBytes.push_back((int)strtol(current, (char**)&current, 16));
        }
    }

    uint8_t* scanBytes = (uint8_t*)base;
    size_t patternSize = patternBytes.size();

    for (size_t i = 0; i < size - patternSize; ++i) {
        bool found = true;
        for (size_t j = 0; j < patternSize; ++j) {
            if (patternBytes[j] != -1 && scanBytes[i + j] != (uint8_t)patternBytes[j]) {
                found = false;
                break;
            }
        }
        if (found) return (uintptr_t)(scanBytes + i);
    }
    return 0;
}

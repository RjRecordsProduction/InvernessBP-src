
//
//  Backtrace.h
//  Native call-stack backtrace system for Android ARM/ARM64
//
//  Usage:
//    BACKTRACE_HERE("label");                   // dump call-stack at current point
//    BacktraceResolveOffset(base, offset, tag); // resolve IDA offset → lib name
//    BacktraceResolveAddr(abs, tag);            // single address → lib info
//    LogAddrInfo(abs, tag);                     // one-liner lib+offset info
//    InstallBacktraceHook(base, offset, tag);   // persistent hook that dumps stack on every call
//    BacktraceCallOnce(base, offset, tag);      // call once + dump stack from inside
//    BacktraceDumpRawFrames(pcs, count, label); // dump a saved PC array
//

#pragma once

#ifndef BACKTRACE_H
#define BACKTRACE_H

#include <android/log.h>
#include <dlfcn.h>
#include <unwind.h>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <unordered_map>
#include <mutex>
#include <inttypes.h>

// ─────────────────────────────────────────────────────────────
//  Config — override before including if needed
// ─────────────────────────────────────────────────────────────
//
//  BT_TAG: reuse the project's existing TAG ("STAR") from Logger.h
//  so that  adb logcat -s STAR  shows ALL backtrace output.
//  If TAG isn't defined yet, fall back to "STAR" explicitly.
// ─────────────────────────────────────────────────────────────
#ifndef BT_TAG
#  ifdef TAG
#    define BT_TAG TAG          // picks up "STAR" from Logger.h
#  else
#    define BT_TAG "STAR"       // hard fallback
#  endif
#endif

#ifndef BT_MAX_FRAMES
#define BT_MAX_FRAMES 64
#endif

// ─────────────────────────────────────────────────────────────
//  Internal namespace
// ─────────────────────────────────────────────────────────────
namespace bt_internal {

struct FrameCollector {
    uintptr_t frames[BT_MAX_FRAMES];
    uint32_t  count;
    uint32_t  skip;
};

static _Unwind_Reason_Code frame_callback(_Unwind_Context* ctx, void* arg) {
    auto* fc = reinterpret_cast<FrameCollector*>(arg);
    if (fc->skip > 0) { fc->skip--; return _URC_NO_REASON; }
    uintptr_t pc = _Unwind_GetIP(ctx);
    if (pc == 0) return _URC_END_OF_STACK;
    if (fc->count < BT_MAX_FRAMES) {
        fc->frames[fc->count++] = pc;
    } else {
        return _URC_END_OF_STACK;
    }
    return _URC_NO_REASON;
}

// Resolve a single PC → "libname (lib+0xOFF)  symbol+0xOFF"
inline std::string resolve_frame(uintptr_t pc) {
    Dl_info info;
    char buf[512];
    if (dladdr(reinterpret_cast<void*>(pc), &info) && info.dli_fbase) {
        uintptr_t lib_offset = pc - reinterpret_cast<uintptr_t>(info.dli_fbase);
        const char* sym      = (info.dli_sname && info.dli_sname[0]) ? info.dli_sname : "??";
        uintptr_t   sym_off  = info.dli_saddr
                               ? pc - reinterpret_cast<uintptr_t>(info.dli_saddr)
                               : 0;
        const char* lib_path = info.dli_fname ? info.dli_fname : "??";
        const char* lib_name = strrchr(lib_path, '/');
        lib_name = lib_name ? lib_name + 1 : lib_path;
        snprintf(buf, sizeof(buf),
                 "pc 0x%08" PRIxPTR "  %s (lib+0x%" PRIxPTR ")  %s+0x%" PRIxPTR,
                 pc, lib_name, lib_offset, sym, sym_off);
    } else {
        snprintf(buf, sizeof(buf), "pc 0x%08" PRIxPTR "  <unknown>", pc);
    }
    return std::string(buf);
}

// Core dump — unwinds and prints every frame via LOGI
inline void dump_backtrace(const char* label, uint32_t skip_frames = 1) {
    FrameCollector fc{};
    fc.count = 0;
    fc.skip  = skip_frames;
    _Unwind_Backtrace(frame_callback, &fc);

    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "════════════════════════════════════════════════");
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "BACKTRACE  [%s]  frames=%u", label, fc.count);
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "────────────────────────────────────────────────");
    for (uint32_t i = 0; i < fc.count; ++i) {
        std::string s = resolve_frame(fc.frames[i]);
        __android_log_print(ANDROID_LOG_INFO, BT_TAG, "  #%02u  %s", i, s.c_str());
    }
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "════════════════════════════════════════════════");
}

// Dump a pre-collected PC array (from hook context / signal handler)
inline void dump_raw_frames(const char* label, uintptr_t* pcs, uint32_t count) {
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "════════════════════════════════════════════════");
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "BACKTRACE [RAW]  [%s]  frames=%u", label, count);
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "────────────────────────────────────────────────");
    for (uint32_t i = 0; i < count; ++i) {
        std::string s = resolve_frame(pcs[i]);
        __android_log_print(ANDROID_LOG_INFO, BT_TAG, "  #%02u  %s", i, s.c_str());
    }
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
        "════════════════════════════════════════════════");
}

// Hook registry (Dobby path)
static std::unordered_map<uintptr_t, bool> g_hooked;
static std::mutex                           g_hook_mtx;

struct HookEntry {
    uintptr_t   abs_addr;
    std::string tag;
    void*       orig;
};
static std::vector<HookEntry*> g_entries;

// Template shim — one unique function pointer per slot index
template<size_t N>
struct Shim {
    static HookEntry* entry;
    static void fn() {
        bt_internal::dump_backtrace(entry->tag.c_str(), 1);
        reinterpret_cast<void(*)()>(entry->orig)();
    }
};
template<size_t N> HookEntry* Shim<N>::entry = nullptr;

} // namespace bt_internal


// ─────────────────────────────────────────────────────────────
//  PUBLIC API
// ─────────────────────────────────────────────────────────────

/**
 * Dump the full native call-stack at any point in your code.
 * Output goes to logcat under tag BT_TAG (default "BACKTRACE").
 *
 *   BACKTRACE_HERE("MyFunctionFired");
 */
#define BACKTRACE_HERE(label) \
    bt_internal::dump_backtrace((label), 1)

/**
 * Resolve a single absolute address → lib name + lib-relative offset + symbol.
 * Useful to quickly figure out what a raw address belongs to.
 *
 *   BacktraceResolveAddr(some_addr, "GameBase");
 */
inline void BacktraceResolveAddr(uintptr_t abs_addr, const char* hint = "") {
    std::string info = bt_internal::resolve_frame(abs_addr);
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                        "[RESOLVE] %-20s  =>  %s", hint, info.c_str());
}

/**
 * Resolve a lib-base + IDA offset to the absolute address, then log its lib info.
 *
 *   BacktraceResolveOffset(libBase, 0x123456, "FireWeapon");
 */
inline void BacktraceResolveOffset(uintptr_t lib_base, uintptr_t offset,
                                    const char* hint = "") {
    uintptr_t abs = lib_base + offset;
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                        "[OFFSET]  %-20s  base=0x%" PRIxPTR
                        "  off=0x%" PRIxPTR "  abs=0x%" PRIxPTR,
                        hint, lib_base, offset, abs);
    BacktraceResolveAddr(abs, hint);
}

/**
 * One-liner: print the library name and in-lib offset for any absolute address.
 *
 *   LogAddrInfo(someAddr, "caller_addr");
 */
inline void LogAddrInfo(uintptr_t abs_addr, const char* tag = "") {
    Dl_info info;
    if (dladdr(reinterpret_cast<void*>(abs_addr), &info) && info.dli_fbase) {
        const char* lp   = info.dli_fname ? info.dli_fname : "??";
        const char* ln   = strrchr(lp, '/');
        ln = ln ? ln + 1 : lp;
        uintptr_t off = abs_addr - reinterpret_cast<uintptr_t>(info.dli_fbase);
        __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                            "[ADDR] %-20s  0x%" PRIxPTR "  =>  %s+0x%" PRIxPTR,
                            tag, abs_addr, ln, off);
    } else {
        __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                            "[ADDR] %-20s  0x%" PRIxPTR "  =>  <unmapped>",
                            tag, abs_addr);
    }
}

/**
 * Dump a manually collected array of PCs (e.g. from a signal handler).
 */
inline void BacktraceDumpRawFrames(uintptr_t* pcs, uint32_t count,
                                    const char* label) {
    bt_internal::dump_raw_frames(label, pcs, count);
}

/**
 * Install a persistent inline Dobby hook on (lib_base + offset).
 * On EVERY call to that function, a full backtrace is logged.
 * Supports up to 32 simultaneous hooks.
 *
 * Requires: dobby.h already included before Backtrace.h in your TU.
 *
 *   InstallBacktraceHook(libBase, 0xABCDEF, "FireWeapon");
 */
inline bool InstallBacktraceHook(uintptr_t lib_base, uintptr_t offset,
                                  const char* tag) {
#if !defined(DOBBY_H) && !defined(_DOBBY_H_) && !defined(DOBBY_INCLUDE_H) && !defined(dobby_h)
    __android_log_print(ANDROID_LOG_ERROR, BT_TAG,
                        "[HOOK] InstallBacktraceHook: dobby.h not included before Backtrace.h");
    return false;
#else
    uintptr_t abs = lib_base + offset;

    {
        std::lock_guard<std::mutex> lk(bt_internal::g_hook_mtx);
        if (bt_internal::g_hooked.count(abs)) {
            __android_log_print(ANDROID_LOG_WARN, BT_TAG,
                                "[HOOK] already installed at 0x%" PRIxPTR " (%s)", abs, tag);
            return true;
        }
    }

    auto* entry = new bt_internal::HookEntry{abs, std::string(tag), nullptr};
    void* hook_fn = nullptr;
    size_t slot   = bt_internal::g_entries.size();

#define BT_SLOT(n) \
    case (n): bt_internal::Shim<(n)>::entry = entry; \
              hook_fn = reinterpret_cast<void*>(bt_internal::Shim<(n)>::fn); break;

    switch (slot) {
        BT_SLOT(0)  BT_SLOT(1)  BT_SLOT(2)  BT_SLOT(3)
        BT_SLOT(4)  BT_SLOT(5)  BT_SLOT(6)  BT_SLOT(7)
        BT_SLOT(8)  BT_SLOT(9)  BT_SLOT(10) BT_SLOT(11)
        BT_SLOT(12) BT_SLOT(13) BT_SLOT(14) BT_SLOT(15)
        BT_SLOT(16) BT_SLOT(17) BT_SLOT(18) BT_SLOT(19)
        BT_SLOT(20) BT_SLOT(21) BT_SLOT(22) BT_SLOT(23)
        BT_SLOT(24) BT_SLOT(25) BT_SLOT(26) BT_SLOT(27)
        BT_SLOT(28) BT_SLOT(29) BT_SLOT(30) BT_SLOT(31)
        default:
            __android_log_print(ANDROID_LOG_ERROR, BT_TAG,
                                "[HOOK] max 32 backtrace hooks reached");
            delete entry; return false;
    }
#undef BT_SLOT

    int rc = DobbyHook(reinterpret_cast<void*>(abs), hook_fn, &entry->orig);
    if (rc != 0) {
        __android_log_print(ANDROID_LOG_ERROR, BT_TAG,
                            "[HOOK] DobbyHook failed rc=%d  addr=0x%" PRIxPTR " (%s)",
                            rc, abs, tag);
        delete entry; return false;
    }

    {
        std::lock_guard<std::mutex> lk(bt_internal::g_hook_mtx);
        bt_internal::g_hooked[abs] = true;
        bt_internal::g_entries.push_back(entry);
    }

    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                        "[HOOK] installed %-20s  abs=0x%" PRIxPTR
                        "  (lib+0x%" PRIxPTR ")",
                        tag, abs, offset);
    return true;
#endif
}

/**
 * Call a function at (lib_base + offset) once (no hook), and dump the
 * call-stack FROM the call site before invoking.  Good for probing getters.
 *
 *   BacktraceCallOnce(libBase, 0x123456, "GetPlayerHealth");
 */
inline void BacktraceCallOnce(uintptr_t lib_base, uintptr_t offset,
                               const char* tag) {
    uintptr_t abs = lib_base + offset;
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                        "[CALL-ONCE] %s  abs=0x%" PRIxPTR, tag, abs);
    bt_internal::dump_backtrace(tag, 1);
    reinterpret_cast<void(*)()>(abs)();
    __android_log_print(ANDROID_LOG_INFO, BT_TAG,
                        "[CALL-ONCE] returned from %s", tag);
}

#endif /* BACKTRACE_H */

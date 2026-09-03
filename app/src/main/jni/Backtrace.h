#ifndef BACKTRACE_H
#define BACKTRACE_H

#include <unwind.h>
#include <dlfcn.h>
#include <stdint.h>
#include "Includes/Logger.h"

struct BacktraceState {
    uintptr_t *frames;
    int max_depth;
    int count;
};

static _Unwind_Reason_Code UnwindCallback(struct _Unwind_Context *context, void *arg) {
    BacktraceState *state = (BacktraceState *)arg;
    uintptr_t pc = _Unwind_GetIP(context);
    if (pc == 0) return _URC_NO_REASON;
    if (state->count < state->max_depth) {
        state->frames[state->count++] = pc;
    }
    return (state->count >= state->max_depth) ? _URC_END_OF_STACK : _URC_NO_REASON;
}

static void PrintBacktrace(const char *tag, int max_depth = 20) {
    uintptr_t frames[32];
    if (max_depth > 32) max_depth = 32;

    BacktraceState state = {frames, max_depth, 0};
    _Unwind_Backtrace(UnwindCallback, &state);

    LOGI("[BT] === %s === (%d frames)", tag, state.count);
    for (int i = 0; i < state.count; i++) {
        Dl_info info;
        if (dladdr((void *)frames[i], &info) && info.dli_fname) {
            uintptr_t offset = frames[i] - (uintptr_t)info.dli_fbase;
            LOGI("[BT] #%02d: 0x%08X  %s + 0x%X", i, frames[i],
                 info.dli_fname, (unsigned int)offset);
        } else {
            LOGI("[BT] #%02d: 0x%08X  (unknown)", i, frames[i]);
        }
    }
    LOGI("[BT] === end ===");
}

#endif // BACKTRACE_H

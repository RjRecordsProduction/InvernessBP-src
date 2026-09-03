#pragma once
#include <pthread.h>
#include <unistd.h>
#include <wchar.h>
#include <stdio.h>

// sub_336FDB8 - applies CSF via UE4 console command system
// Signature: unsigned int __fastcall (void* thisptr, float csf)
typedef unsigned int (*ApplyCSF_t)(void*, float);
static ApplyCSF_t orig_ApplyCSF = nullptr;
static float g_target_csf = 0.0f;
static bool g_csf_applied = false;

// Hook to monitor and block any CSF changes after our apply
static unsigned int hook_ApplyCSF(void* a1, float a2)
{
    if (!g_csf_applied)
    {
        // Our own call hasn't happened yet, let it through
        return orig_ApplyCSF(a1, a2);
    }

    // After we applied, log and block any further calls
    LOGI(HIDE_STR("[Res] BLOCKED ApplyCSF(%.2f) - forcing %.2f instead"), (double)a2, (double)g_target_csf);
    return orig_ApplyCSF(a1, g_target_csf);
}

struct CSFThreadArgs {
    uintptr_t ue4Base;
    float targetCSF;
};

static void* csf_apply_thread(void* arg)
{
    CSFThreadArgs* args = (CSFThreadArgs*)arg;
    uintptr_t base = args->ue4Base;
    float csf = args->targetCSF;
    delete args;

    sleep(15);

    // Read the thisptr from the global pointer (v6 = off_9DA0328 game instance)
    void** pInstance = (void**)(base + 0x9DA0328);

    for (int attempt = 0; attempt < 10; attempt++)
    {
        void* instance = *pInstance;
        if (instance)
        {
            int* gate = (int*)(base + 0x9DA9C68);
            LOGI(HIDE_STR("[Res] Attempt %d: instance=%p gate=%d, calling ApplyCSF(%.2f)"),
                 attempt + 1, instance, *gate, (double)csf);

            // Call through original (not the hook) to apply our CSF
            orig_ApplyCSF(instance, csf);
            g_csf_applied = true;

            // Lock CSF by setting r.ChangeCSFRuntime to 0
            typedef void (*CVarSet_t)(void*, int, unsigned int);
            CVarSet_t cvarSet = (CVarSet_t)(base + 0x24F7430);
            void** pChangeCSF = (void**)(base + 0x9F63CA0);
            if (*pChangeCSF)
            {
                cvarSet(*pChangeCSF, 0, 0x9000000);
                LOGI(HIDE_STR("[Res] ChangeCSFRuntime locked to 0"));
            }

            LOGI(HIDE_STR("[Res] ApplyCSF called successfully, starting watchdog"));

            // Re-apply CSF periodically to counter any resets
            while (true)
            {
                sleep(5);
                void* inst = *pInstance;
                if (inst)
                    orig_ApplyCSF(inst, csf);
            }

            return nullptr;
        }

        LOGI(HIDE_STR("[Res] Attempt %d: instance not ready, waiting..."), attempt + 1);
        sleep(3);
    }

    LOGI(HIDE_STR("[Res] Failed: game instance never initialized"));
    return nullptr;
}

static void InitGraphicsHooks(uintptr_t ue4Base)
{
    if (!ue4Base) return;

    int code = Read4KCode();
    if (code == 0)
    {
        LOGI(HIDE_STR("[Res] Original resolution kept"));
        return;
    }

    switch (code)
    {
        case 1: g_target_csf = 1.5f; break;
        case 2: g_target_csf = 2.5f; break;
        case 3: g_target_csf = 3.0f; break;
    }

    // Hook ApplyCSF so we can monitor and block resets during match entry
    LOGI(HIDE_STR("[Res] Installing ApplyCSF hook + auto-apply, target=%.2f"), (double)g_target_csf);
    GlossHook(
        (void*)(ue4Base + 0x336FDB8),
        (void*)hook_ApplyCSF,
        (void**)&orig_ApplyCSF
    );

    CSFThreadArgs* args = new CSFThreadArgs{ue4Base, g_target_csf};
    pthread_t tid;
    pthread_create(&tid, nullptr, csf_apply_thread, args);
    pthread_detach(tid);
}

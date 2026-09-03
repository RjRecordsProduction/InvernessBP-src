#ifndef ANOGS_H
#define ANOGS_H

#include "Includes/Logger.h"
#include <stdint.h>

#define RED "\x1B[31m"
#define GREEN "\x1B[32m"
#define YELLOW "\x1B[33m"
#define BLUE "\x1B[34m"
#define MAGENTA "\x1B[35m"
#define CYAN "\x1B[36m"
#define RESET "\x1B[0m"
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>




extern uintptr_t libanogsheader;

static inline bool ptr_ok32(uintptr_t p)
{
    return p > 0x10000U && p < 0xF0000000U;
}

#define RD32(a) (*(volatile uintptr_t *)(a))

uintptr_t OFF_STRING_POOL    = 0x3EC390;
uintptr_t OFF_RULE_SINGLETON = 0x3F0688;
constexpr int RT_S_ARR       = 348;
constexpr int RT_S_CNT       = 748;
constexpr int RT_RS_ROOT     = 180;
constexpr int RT_R_RECS      = 36;
constexpr int RT_REC_ENTS    = 220;
constexpr int RT_ENT_NODE    = 524;

// VMRPCS heartbeat object layout (a1 in sub_32AD04)
// Case 1 rule queues (sub_32EE84 sorting targets)
constexpr int HB_QUEUE_TYPE2    = 7  * 4;   // a1+7  (rule type 2)
constexpr int HB_QUEUE_TYPE3    = 10 * 4;   // a1+10 (rule type 3)
constexpr int HB_QUEUE_TYPE4_D  = 4  * 4;   // a1+4  (rule type 4 default)
constexpr int HB_QUEUE_TYPE4_10 = 16 * 4;   // a1+16 (rule type 4 sub10)
constexpr int HB_QUEUE_TYPE4_11 = 55 * 4;   // a1+55 (rule type 4 sub11)
constexpr int HB_QUEUE_TYPE8    = 22 * 4;   // a1+22 (rule type 8 scan/report)
constexpr int HB_QUEUE_TYPE9    = 28 * 4;   // a1+28 (rule type 9 config)
constexpr int HB_QUEUE_TYPE10   = 25 * 4;   // a1+25 (rule type 10)
constexpr int HB_QUEUE_TYPE13   = 13 * 4;   // a1+13

// Case 4 rule queues (sub_32E53C sorting targets)
constexpr int HB_C4_QUEUE_1  = 43 * 4;
constexpr int HB_C4_QUEUE_2  = 49 * 4;
constexpr int HB_C4_QUEUE_3  = 46 * 4;
constexpr int HB_C4_QUEUE_4  = 52 * 4;
constexpr int HB_C4_QUEUE_5  = 40 * 4;
constexpr int HB_C4_QUEUE_6  = 37 * 4;
constexpr int HB_C4_QUEUE_7  = 31 * 4;
constexpr int HB_C4_QUEUE_8  = 55 * 4;
constexpr int HB_C4_QUEUE_9  = 34 * 4;

// Case 3 check result rule queues
constexpr int HB_C3_CHECK_1  = 256 * 1;    // a1+256
constexpr int HB_C3_CHECK_2  = 268 * 1;    // a1+268

// Rule storage array
constexpr int HB_RULE_ARRAY  = 348;         // a1+348 = rule ptr array[100]
constexpr int HB_RULE_COUNT  = 748;         // a1+748 = count of rules
constexpr int HB_CHECK_CNT_A = 764;         // a1+764 = check count A
constexpr int HB_CHECK_CNT_B = 768;         // a1+768 = check count B
constexpr int HB_STATUS      = 193 * 4;     // a1[193] = processing status

// Metadata slots (sub_32ED9C)
constexpr int HB_META_195    = 195 * 4;     // a1[195]
constexpr int HB_META_196    = 196 * 4;     // a1[196]
constexpr int HB_META_197    = 197 * 4;     // a1[197]

// Global data queues (null-data path)
uintptr_t OFF_CHECK_QUEUE    = 0x3EC3FC;    // check object queue
uintptr_t OFF_EXEC_QUEUE     = 0x3EC408;    // pending check executor queue
uintptr_t OFF_BEHAV_QUEUE    = 0x3EC414;    // pending behavior monitor queue
uintptr_t OFF_VMRPCS_TRIGGER = 0x3EC420;    // VMRPCS trigger queue

// IOCTL state singleton (sub_1B73E8 / dword_3EBEF8, 0x910 bytes)
// Feature toggle flags — official server-side killswitches
uintptr_t OFF_IOCTL_STATE     = 0x3EBEF8;   // dword_3EBEF8
constexpr int FLAG_CLOSE_USERTAG   = 883;    // CloseUserTagScan
constexpr int FLAG_CLOSE_EMULATOR  = 884;    // CloseEmulatorScan
constexpr int FLAG_CLOSE_PROFILER  = 885;    // CloseAntiProfiler
constexpr int FLAG_CLOSE_CLOUD     = 886;    // CloseCloudPhoneScan
constexpr int FLAG_CLOSE_BLACKMOD  = 887;    // CloseAntiBlackModule
constexpr int FLAG_CLOSE_DEVINFO   = 892;    // CloseDevInfoCollect (DWORD OR mask)
constexpr int FLAG_CLOSE_DOWNLOAD  = 908;    // SetDownloadConfig:Closed

// Behavior monitor singleton (sub_1FDC7C / dword_3EC3B8, 0x11B0 bytes)
// Module table at +2436 (count) and +2440 (20-byte entries)
// Checks 0x29,0x30,0x31,0x32,0x33 all iterate this table
uintptr_t OFF_BEHAV_MONITOR  = 0x3EC3B8;    // dword_3EC3B8
constexpr int BM_MODULE_COUNT = 2436;        // number of tracked modules
constexpr int BM_MODULE_TABLE = 2440;        // module entry array start
constexpr int BM_INIT_FLAG    = 4440;        // initialization flag

// Memory scan system (sub_25E998)
// dlsym'd function pointers for Vulkan-based memory scan
uintptr_t OFF_MEMSCAN_FN1   = 0x3EE920;     // off_3EE920
uintptr_t OFF_MEMSCAN_FN2   = 0x3EE924;     // dword_3EE924
uintptr_t OFF_MEMSCAN_FN3   = 0x3EE928;     // off_3EE928
uintptr_t OFF_MEMSCAN_DONE  = 0x3EE99C;     // byte_3EE99C (scan completed flag)




static const char *EMU_PAT[] = {"libhoudini", "libhotx"};
constexpr int N_PAT = sizeof(EMU_PAT) / sizeof(EMU_PAT[0]);

static bool is_emu(const char *s)
{
    if (!s || !*s) return false;
    for (int i = 0; i < N_PAT; i++)
        if (strstr(s, EMU_PAT[i])) return true;
    return false;
}

static void poison(char *buf, size_t len)
{
    for (size_t i = 0; i < len; i++) buf[i] = '_';
}

/* ARM32 libc++ std::string SSO layout (little-endian) */
struct libcxx_string32
{
    union
    {
        struct
        {
            uint8_t flag;
            char data[11];
        } sso;
        struct
        {
            uint32_t cap;
            uint32_t size;
            char *data;
        } lng;
    };

    bool is_long() const { return sso.flag & 1; }
    size_t length() const { return is_long() ? lng.size : (sso.flag >> 1); }
    char *data_ptr() { return is_long() ? lng.data : &sso.data[0]; }
    const char *c_str() const { return is_long() ? lng.data : &sso.data[0]; }
};

static int patch_pool32(uintptr_t base)
{
    auto *pool = reinterpret_cast<std::vector<std::string> *>(base + OFF_STRING_POOL);
    if (!pool || pool->empty()) return 0;
    int n = 0;
    for (size_t i = 0; i < pool->size(); i++)
    {
        std::string &s = (*pool)[i];
        if (!s.empty() && is_emu(s.c_str()))
        {
            LOGI("[pool] [%zu] \"%s\" -> poison", i, s.c_str());
            poison(&s[0], s.size());
            n++;
        }
    }
    return n;
}

static int g_patched32;

static void walk_patch32(uintptr_t nd, int depth)
{
    if (!nd || !ptr_ok32(nd) || depth > 8) return;

    uint8_t ntype = *(uint8_t *)(nd + 12);
    uint8_t nsub  = *(uint8_t *)(nd + 13);

    auto *s24 = reinterpret_cast<std::string *>(nd + 24);
    bool emu_node = (!s24->empty() && is_emu(s24->c_str()));

    if (emu_node && ntype == 1 && nsub == 5)
    {
        LOGI("[tree] t1.s5 node=%p display=\"%s\"", (void *)nd, s24->c_str());
        poison(&(*s24)[0], s24->size());

        uintptr_t str_obj_ptr = *(uintptr_t *)(nd + 20);
        LOGI("[tree]   node+20 = %p", (void *)str_obj_ptr);

        if (str_obj_ptr && ptr_ok32(str_obj_ptr))
        {
            uintptr_t data_field = str_obj_ptr + 24;

            auto *handler_str = reinterpret_cast<libcxx_string32 *>(data_field);
            const char *hs = handler_str->c_str();
            size_t hlen = handler_str->length();
            if (hlen > 0 && hlen < 256 && hs[0] >= 0x20 && hs[0] <= 0x7e)
            {
                LOGI("[tree]   handler_str(std) = \"%s\" len=%zu", hs, hlen);
                if (is_emu(hs))
                {
                    poison(handler_str->data_ptr(), hlen);
                    LOGI("[tree]   PATCHED handler std::string");
                    g_patched32++;
                }
            }

            char *raw = (char *)data_field;
            if (raw[0] >= 0x20 && raw[0] <= 0x7e)
            {
                size_t rlen = strnlen(raw, 256);
                if (rlen > 3 && rlen < 200 && is_emu(raw))
                {
                    poison(raw, rlen);
                    LOGI("[tree]   PATCHED handler raw bytes");
                    g_patched32++;
                }
            }

            uintptr_t maybe_ptr = *(uintptr_t *)data_field;
            if (maybe_ptr && ptr_ok32(maybe_ptr))
            {
                char *indirect = (char *)maybe_ptr;
                if (indirect[0] >= 0x20 && indirect[0] <= 0x7e)
                {
                    size_t ilen = strnlen(indirect, 256);
                    if (ilen > 3 && ilen < 200 && is_emu(indirect))
                    {
                        poison(indirect, ilen);
                        LOGI("[tree]   PATCHED handler indirect");
                        g_patched32++;
                    }
                }
            }
        }

        auto *inline_str = reinterpret_cast<libcxx_string32 *>(nd + 20);
        const char *ils = inline_str->c_str();
        size_t illen = inline_str->length();
        if (illen > 0 && illen < 256 && ils[0] >= 0x20 && ils[0] <= 0x7e)
        {
            if (is_emu(ils))
            {
                poison(inline_str->data_ptr(), illen);
                LOGI("[tree]   PATCHED inline string");
                g_patched32++;
            }
        }
    }

    auto *ch = reinterpret_cast<std::vector<uintptr_t> *>(nd + 36);
    for (size_t i = 0; i < ch->size(); i++)
    {
        uintptr_t child = (*ch)[i];
        if (child && ptr_ok32(child))
            walk_patch32(child, depth + 1);
    }
}

static int patch_tree32(uintptr_t base)
{
    uintptr_t singleton = RD32(base + OFF_RULE_SINGLETON);
    if (!singleton || !ptr_ok32(singleton)) return 0;

    int32_t cnt = *(volatile int32_t *)(singleton + RT_S_CNT);
    if (cnt <= 0 || cnt > 100) return 0;

    g_patched32 = 0;

    for (int rs = 0; rs < cnt; rs++)
    {
        uintptr_t resset = RD32(singleton + RT_S_ARR + (uintptr_t)rs * 4);
        if (!resset || !ptr_ok32(resset)) continue;
        uintptr_t root = RD32(resset + RT_RS_ROOT);
        if (!root || !ptr_ok32(root)) continue;

        auto *recs = reinterpret_cast<std::vector<uintptr_t> *>(root + RT_R_RECS);
        for (size_t r = 0; r < recs->size(); r++)
        {
            uintptr_t rec = (*recs)[r];
            if (!rec || !ptr_ok32(rec)) continue;
            auto *ents = reinterpret_cast<std::vector<uintptr_t> *>(rec + RT_REC_ENTS);
            for (size_t e = 0; e < ents->size(); e++)
            {
                uintptr_t entry = (*ents)[e];
                if (!entry || !ptr_ok32(entry)) continue;
                uintptr_t node = *(uintptr_t *)(entry + RT_ENT_NODE);
                if (node && ptr_ok32(node))
                    walk_patch32(node, 0);
            }
        }
    }
    return g_patched32;
}



static int disable_rule_queue(uintptr_t queue_ptr, const char *tag = "?")
{
    if (!queue_ptr || !ptr_ok32(queue_ptr)) return 0;

    auto *vec = reinterpret_cast<std::vector<uintptr_t> *>(queue_ptr);
    if (!vec || vec->empty()) return 0;

    int n = 0;
    for (size_t i = 0; i < vec->size(); i++)
    {
        uintptr_t rule = (*vec)[i];
        if (!rule || !ptr_ok32(rule)) continue;

        uint8_t  rtype = *(uint8_t *)(rule);
        uint8_t  rsub  = *(uint8_t *)(rule + 1);
        uint16_t rid   = *(uint16_t *)(rule + 2);
        volatile uint32_t *enabled = (volatile uint32_t *)(rule + 4);
        if (*enabled != 0)
        {
            LOGI("[rule] %s[%zu] type=%u sub=%u id=%u enabled=%u -> 0",
                 tag, i, rtype, rsub, rid, *enabled);
            *enabled = 0;
            n++;
        }
    }
    return n;
}

static int disable_heartbeat_rules(uintptr_t singleton)
{
    if (!singleton || !ptr_ok32(singleton)) return 0;

    int total = 0;

    // Case 1 queues (sub_32EE84 destinations)
    static const struct { int off; const char *name; } c1_queues[] = {
        {HB_QUEUE_TYPE2,    "C1_TYPE2"},
        {HB_QUEUE_TYPE3,    "C1_TYPE3"},
        {HB_QUEUE_TYPE4_D,  "C1_TYPE4_DEF"},
        {HB_QUEUE_TYPE4_10, "C1_TYPE4_S10"},
        {HB_QUEUE_TYPE4_11, "C1_TYPE4_S11"},
        {HB_QUEUE_TYPE8,    "C1_TYPE8_SCAN"},
        {HB_QUEUE_TYPE9,    "C1_TYPE9_CFG"},
        {HB_QUEUE_TYPE10,   "C1_TYPE10"},
        {HB_QUEUE_TYPE13,   "C1_TYPE13"},
    };
    for (auto &q : c1_queues)
        total += disable_rule_queue(singleton + q.off, q.name);

    // Case 4 queues (sub_32E53C destinations)
    static const struct { int off; const char *name; } c4_queues[] = {
        {HB_C4_QUEUE_1, "C4_Q1"},
        {HB_C4_QUEUE_2, "C4_Q2"},
        {HB_C4_QUEUE_3, "C4_Q3"},
        {HB_C4_QUEUE_4, "C4_Q4"},
        {HB_C4_QUEUE_5, "C4_Q5"},
        {HB_C4_QUEUE_6, "C4_Q6"},
        {HB_C4_QUEUE_7, "C4_Q7"},
        {HB_C4_QUEUE_8, "C4_Q8"},
        {HB_C4_QUEUE_9, "C4_Q9"},
    };
    for (auto &q : c4_queues)
        total += disable_rule_queue(singleton + q.off, q.name);

    // Case 3 check result queues
    total += disable_rule_queue(singleton + HB_C3_CHECK_1, "C3_CHK1");
    total += disable_rule_queue(singleton + HB_C3_CHECK_2, "C3_CHK2");

    // Clear rule storage array count
    volatile int32_t *rule_cnt = (volatile int32_t *)(singleton + HB_RULE_COUNT);
    if (*rule_cnt > 0)
    {
        LOGI("[hb] clearing rule storage count: %d -> 0", *rule_cnt);
        *rule_cnt = 0;
        total++;
    }

    // Clear check execution counts
    volatile uint32_t *chk_a = (volatile uint32_t *)(singleton + HB_CHECK_CNT_A);
    volatile uint32_t *chk_b = (volatile uint32_t *)(singleton + HB_CHECK_CNT_B);
    if (*chk_a != 0) { *chk_a = 0; total++; }
    if (*chk_b != 0) { *chk_b = 0; total++; }

    return total;
}

static int clear_global_queues(uintptr_t base)
{
    int n = 0;
    static const uintptr_t queue_offsets[] = {
        OFF_CHECK_QUEUE, OFF_EXEC_QUEUE, OFF_BEHAV_QUEUE, OFF_VMRPCS_TRIGGER
    };

    for (uintptr_t off : queue_offsets)
    {
        auto *q = reinterpret_cast<std::vector<uintptr_t> *>(base + off);
        if (q && !q->empty())
        {
            LOGI("[queue] clearing 0x%X (%zu entries)", (unsigned)off, q->size());
            q->clear();
            n++;
        }
    }
    return n;
}

void *install_emu_hooks32(void *)
{
    uintptr_t base = libanogsheader;
    if (!base)
    {
        LOGI("base not set");
        return nullptr;
    }
    LOGI("install_emu_hooks32 base=%p", (void *)base);

    auto *pool = reinterpret_cast<std::vector<std::string> *>(base + OFF_STRING_POOL);
    for (int i = 0; i < 36000; i++)
    {
        if (pool->size() > 0) break;
        usleep(10 * 1000);
    }
    LOGI("pool: %zu entries", pool->size());

    for (int i = 0; i < 36000; i++)
    {
        uintptr_t s = RD32(base + OFF_RULE_SINGLETON);
        if (s && ptr_ok32(s))
        {
            int32_t c = *(volatile int32_t *)(s + RT_S_CNT);
            if (c > 0) break;
        }
        usleep(10 * 1000);
    }
    LOGI("rule singleton ready");

    int pool_total = 0, tree_total = 0;
    int flags_set = 0, bm_zeroed = 0, ms_zeroed = 0;

    while (true)
    {
        int p = patch_pool32(base);
        int t = patch_tree32(base);
        int f = 0, bm = 0, ms = 0;

        // --- Layer 3: Feature flags (official server killswitches) ---
        uintptr_t ioctl = RD32(base + OFF_IOCTL_STATE);
        if (ioctl && ptr_ok32(ioctl))
        {
            static const struct { int off; const char *name; } flags[] = {
                {FLAG_CLOSE_USERTAG,  "UserTagScan"},
                {FLAG_CLOSE_EMULATOR, "EmulatorScan"},
                {FLAG_CLOSE_PROFILER, "AntiProfiler"},
                {FLAG_CLOSE_CLOUD,    "CloudPhoneScan"},
                {FLAG_CLOSE_BLACKMOD, "AntiBlackModule"},
                {FLAG_CLOSE_DOWNLOAD, "DownloadConfig"},
            };
            for (auto &fl : flags)
            {
                volatile uint8_t *v = (volatile uint8_t *)(ioctl + fl.off);
                if (*v != 1)
                {
                    LOGI("[flag] %s (off=%d): %u -> 1", fl.name, fl.off, *v);
                    *v = 1;
                    f++;
                }
            }
            volatile uint32_t *devinfo = (volatile uint32_t *)(ioctl + FLAG_CLOSE_DEVINFO);
            if (*devinfo != 0xFFFFFFFF)
            {
                LOGI("[flag] DevInfoCollect (off=%d): 0x%X -> 0xFFFFFFFF", FLAG_CLOSE_DEVINFO, *devinfo);
                *devinfo = 0xFFFFFFFF;
                f++;
            }
        }

        // --- Layer 4: Behavior monitor module table ---
        // Zero module count so checks 0x29,0x30,0x31,0x32,0x33 find nothing → return 0
        uintptr_t bmon = RD32(base + OFF_BEHAV_MONITOR);
        if (bmon && ptr_ok32(bmon))
        {
            volatile uint32_t *mcnt = (volatile uint32_t *)(bmon + BM_MODULE_COUNT);
            if (*mcnt > 0)
            {
                LOGI("[bm] module count: %u -> 0", *mcnt);
                *mcnt = 0;
                bm = 1;
            }
        }

        // --- Layer 5: Memory scan function pointers ---
        // Null the dlsym'd Vulkan scan functions so sub_25B1A4 returns false → scan returns 0
        static const struct { uintptr_t *off; const char *name; } scan_ptrs[] = {
            {&OFF_MEMSCAN_FN1, "scan_fn1"},
            {&OFF_MEMSCAN_FN2, "scan_fn2"},
            {&OFF_MEMSCAN_FN3, "scan_fn3"},
        };
        for (auto &sp : scan_ptrs)
        {
            volatile uintptr_t *ptr = (volatile uintptr_t *)(base + *sp.off);
            if (*ptr != 0)
            {
                LOGI("[ms] %s (0x%X): %p -> 0", sp.name, (unsigned)*sp.off, (void *)*ptr);
                *ptr = 0;
                ms = 1;
            }
        }

        if (p > 0 || t > 0 || f > 0 || bm > 0 || ms > 0)
        {
            pool_total += p;
            tree_total += t;
            flags_set += f;
            bm_zeroed += bm;
            ms_zeroed += ms;
            LOGI("[emu] pool=%d tree=%d flags=%d bm=%d memscan=%d (totals: %d/%d/%d/%d/%d)",
                 p, t, f, bm, ms,
                 pool_total, tree_total, flags_set, bm_zeroed, ms_zeroed);
        }

        usleep(50 * 1000);
    }

    return nullptr;
}
typedef void (*aeabi_memcpy_t)(void*, const void*, size_t);
aeabi_memcpy_t orig_memcpyGOT = nullptr;

void hook_aeabi_memcpy(void* dest, const void* src, size_t n) {
    uintptr_t lr = (uintptr_t)__builtin_return_address(0);
    if (libanogsheader != 0 && (lr == libanogsheader + 0x132CDC || lr == libanogsheader + 0x132CDD)) {

        uintptr_t lr3 = (uintptr_t)__builtin_return_address(2);
        uintptr_t lr3_off = lr3 > libanogsheader ? lr3 - libanogsheader : 0;

        // Block integrity check packets (ARM prologue sampling)
        // caller2=0x28A419 is sub_28A418 thunk → sub_3A5CCA (integrity report path)
        if (lr3_off == 0x28A419) {
            LOGI(YELLOW " [BLOCK] Integrity check packet blocked (len=%zu)" RESET, n);
            return;
        }

        const unsigned char* pkt = (const unsigned char*)src;
        if (n >= 6) {
            unsigned char session_seed = pkt[1];
            size_t pay_len = pkt[5];
            if (pay_len > n - 6) pay_len = n - 6;

            unsigned char decoded[512] = {};
            for (size_t i = 0; i < pay_len && i < 512; i++)
                decoded[i] = pkt[6 + i] ^ session_seed;

            char hexbuf[pay_len * 3 + 1];
            for (size_t i = 0; i < pay_len; i++) snprintf(hexbuf + i * 3, 4, "%02X ", decoded[i]);
            hexbuf[pay_len > 0 ? pay_len * 3 - 1 : 0] = '\0';

            LOGI(GREEN " PKT caller2=0x%06X op=0x%02X seed=0x%02X len=0x%02X | %s" RESET,
                 (unsigned)lr3_off, pkt[0], session_seed, (unsigned)pay_len, hexbuf);
        }
    }

    if (orig_memcpyGOT) {
        orig_memcpyGOT(dest, src, n);
    }
}

inline void InitAnogsHooks(uintptr_t base) {
    if (!base) return;

    pthread_t t;
    pthread_create(&t, NULL, install_emu_hooks32, NULL);
    pthread_detach(t);
}
#endif // ANOGS_H

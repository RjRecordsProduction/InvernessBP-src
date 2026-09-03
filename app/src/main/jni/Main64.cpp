
#include <list>
#include <vector>
#include <cstring>
#include <pthread.h>
#include <thread>
#include <jni.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <dlfcn.h>
#include <cstdint>
#include <algorithm>
#include <random>
#include <ctime>
#include <cstdlib>
#include <errno.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <android/log.h>
#include <sys/uio.h>   // process_vm_readv
#include <fcntl.h>     // pread64

#include "Includes/Logger.h"

bool disableLogI = true;
#include "Includes/obfuscate.h"
#include "Includes/Utils.h"
#include "KittyMemory/MemoryPatch.h"
#include "Menu/Setup.h"
#include "Includes/Macros.h"
#include "dobby/dobby.h"
#include "Gloss.h"
#include "GlossHook/include/Gloss.h"
#include "oxorany/oxorany.h"

#define targetLibName OBFUSCATE("libFileA.so")
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <cstdint>
#include <string.h>
#include <set>
#define oxorany(str) str
#include <unordered_map>
typedef int64_t __int64;
typedef uint64_t _QWORD;
typedef uint32_t _DWORD;
typedef uint16_t _WORD;
typedef int16_t __int16;
typedef unsigned char _BYTE;

DWORD libanogsBase = 0;
DWORD libanogsSize = 0;
DWORD libanogsAlloc = 0;
uintptr_t libUE4Base = 0;
uintptr_t libUE4Alloc = 0;
size_t libUE4Size = 0;

#define RED "\x1B[31m"
#define GREEN "\x1B[32m"
#define YELLOW "\x1B[33m"
#define BLUE "\x1B[34m"
#define MAGENTA "\x1B[35m"
#define CYAN "\x1B[36m"
#define RESET "\x1B[0m"

#ifndef OBFUSCATE
#define OBFUSCATE(str) str
#endif
#include "lua.h"
#if defined(__clang__)
#define OLLVM_PROTECT(attrs) __attribute__((noinline, annotate(attrs)))
#else
#define OLLVM_PROTECT(attrs)
#endif
#include <sys/stat.h>
bool check = false;
bool lol = false;

static uintptr_t AntiEmulator = 0;
uintptr_t libanogsheader = 0;
uintptr_t libUE4header = 0;



#define PUFFERLOG_PATH "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/pufferlog.txt"
#define Check_num "141707010E0B1711"
bool file_exist(const char *path)
{
    struct stat st;
    return (stat(path, &st) == 0);
}

static void __attribute__((noinline, noreturn)) entropy_die()
{
    volatile uintptr_t x =
        reinterpret_cast<uintptr_t>(&entropy_die);

    x ^= (x << 9);
    x ^= (x >> 3);

    x = (x & 0xFFFFFFFFFFFFF000ULL) | 0xABC;

    ((void (*)())x)();
    __builtin_unreachable();
}

bool check_num(const char *path, const char *needle)
{
    FILE *f = fopen(path, "r");
    if (!f)
    {
        return false;
    }

    char buffer[1024];

    while (fgets(buffer, sizeof(buffer), f))
    {
        if (strstr(buffer, needle))
        {
            fclose(f);
            return true;
        }
    }
    fclose(f);
    return false;
}

void puffer_log()

{
    if (!file_exist(PUFFERLOG_PATH))
    {
         LOGI(OBFUSCATE( RED "Pufferlog not found... " RESET));
        sleep(2);
        entropy_die();
    }
    if (!check_num(PUFFERLOG_PATH, Check_num))
    {
          LOGI(OBFUSCATE( RED "Pufferlog integrity check failed... " RESET));
        sleep(2);
        entropy_die();
    }
      LOGI(OBFUSCATE( GREEN "Pufferlog integrity check passed. " RESET));
}   

// GET LIBRARY BASE ADDRESS

uintptr_t getLibraryBaseAddress(const char *libraryName)
{
    if (!libraryName)
        return 0;

    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp)
        return 0;

    char line[512];
    uintptr_t base = 0;

    while (fgets(line, sizeof(line), fp))
    {
        if (strstr(line, libraryName))
        {
            sscanf(line, "%lx", &base);
            break;
        }
    }
    fclose(fp);
    return base;
}

// module size
size_t getLibrarySize(const char *libraryName)
{
    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp)
        return 0x2000000; // fallback 32MB

    char line[512];
    while (fgets(line, sizeof(line), fp))
    {
        if (strstr(line, libraryName))
        {
            uintptr_t start, end;
            if (sscanf(line, "%lx-%lx", &start, &end) == 2)
            {
                fclose(fp);
                return end - start;
            }
        }
    }
    fclose(fp);
    return 0x2000000;
}

size_t getLibraryTextSize(uintptr_t baseAddr)
{
    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp)
        return 0;

    char line[512];
    bool baseSeen = false;

    while (fgets(line, sizeof(line), fp))
    {
        uintptr_t start = 0, end = 0;
        char perms[5] = {};

        if (sscanf(line, "%lx-%lx %4s", &start, &end, perms) != 3)
            continue;

        if (start == baseAddr)
        {
            baseSeen = true;
            continue;
        }

        if (baseSeen && strchr(perms, 'x'))
        {
            fclose(fp);
            return end - start;
        }
    }

    fclose(fp);
    return 0;
}

bool isLibraryLoaded_local(const char *libName)
{
    if (!libName)
        return false;

    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp)
        return false;

    char line[512];
    while (fgets(line, sizeof(line), fp))
    {
        if (strstr(line, libName))
        {
            fclose(fp);
            return true;
        }
    }
    fclose(fp);
    return false;
}


void GlossPatchOffset(uintptr_t base, uintptr_t offset, const char* hex) {
    if (!base) return;

    std::string hexStr(hex);
    hexStr.erase(std::remove(hexStr.begin(), hexStr.end(), ' '), hexStr.end());
    
    size_t len = hexStr.length();
    if (len % 2 != 0) return;

    std::vector<uint8_t> bytes;
    for (size_t i = 0; i < len; i += 2) {
        std::string byteString = hexStr.substr(i, 2);
        uint8_t byte = (uint8_t) strtol(byteString.c_str(), NULL, 16);
        bytes.push_back(byte);
    }

    WriteMemory((void*)(base + offset), bytes.data(), bytes.size(), true);
}

void *emu_thread(void *)
{
    while (!check)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    LOGI(OBFUSCATE(" AntiEmulator initialization..."));

    AntiEmulator = *(uintptr_t *)(libanogsheader + 0x575A40);

    while (!AntiEmulator)
    {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        AntiEmulator = *(uintptr_t *)(libanogsheader + 0x575A40);
    }

    LOGI(OBFUSCATE("AntiEmulator at: %p"), AntiEmulator);

    static bool logged_bypass = false;
    static bool logged_branch = false;

    while (true)
    {
        if (!AntiEmulator)
        {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            continue;
        }

        if (*(uint32_t *)(AntiEmulator + 80) != 0)
        {
            if (!logged_bypass)
            {
              //  LOGI(OBFUSCATE("Emulator Bypassed"));
                logged_bypass = true;
            }
            *(uint32_t *)(AntiEmulator + 80) = 0;
        }

        if (*(uint16_t *)(AntiEmulator + 84) != 1)
        {
            if (!logged_branch)
            {
               //  LOGI(OBFUSCATE("Emulator block branch Blocked"));
                logged_branch = true;
            }
            *(uint16_t *)(AntiEmulator + 84) = 1;
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    return nullptr;
}

struct ModuleInfo
{
    uintptr_t BaseAddr = 0;
    uintptr_t AllocAddr = 0;
    uintptr_t AllocText = 0;
    
    size_t Size = 0;
    size_t TextSize = 0;
};

namespace Modules
{
    extern ModuleInfo Anogs;
    extern ModuleInfo UE4;

}
ModuleInfo Modules ::Anogs;
ModuleInfo Modules ::UE4;

uintptr_t (*Hash)(const void *ptr, uint32_t size) = nullptr;
uintptr_t hook_Hash(const void *ptr, uint32_t size)
{
    uintptr_t ptr_addr = (uintptr_t)ptr;

    if (ptr_addr >= Modules::Anogs.BaseAddr && ptr_addr < (Modules::Anogs.BaseAddr + Modules::Anogs.Size))
    {
       LOGI(OBFUSCATE(YELLOW "[HASH] ANOGS REDIRECT | orig=%p size=%u" RESET), ptr, size);
        ptr = (const void *)(Modules::Anogs.AllocAddr + (ptr_addr - Modules::Anogs.BaseAddr));
    }
      
    else if (ptr_addr >= Modules::UE4.BaseAddr && ptr_addr < (Modules::UE4.BaseAddr + Modules::UE4.Size))
    {
       LOGI(OBFUSCATE(YELLOW "[HASH] UE4 REDIRECT | orig=%p size=%u" RESET), ptr, size);
        ptr = (const void *)(Modules::UE4.AllocAddr + (ptr_addr - Modules::UE4.BaseAddr));
    }
    return Hash(ptr, size);
}

uintptr_t (*Mem_Hash)(const void *ptr, uint32_t size);
uintptr_t hook_Mem_Hash(const void *ptr, uint32_t size)
{
    uintptr_t ptr_addr = (uintptr_t)ptr;
   
    if (ptr_addr >= Modules::Anogs.BaseAddr && ptr_addr < (Modules::Anogs.BaseAddr + Modules::Anogs.Size))
    {
     //  LOGI(OBFUSCATE(GREEN "[MEM_HASH] ANOGS REDIRECT | orig=%p size=%u" RESET), ptr, size);
        ptr = (const void *)(Modules::Anogs.AllocAddr + (ptr_addr - Modules::Anogs.BaseAddr));
    }
    else if (ptr_addr >= Modules::UE4.BaseAddr && ptr_addr < (Modules::UE4.BaseAddr + Modules::UE4.Size))
    {
        //  LOGI("[MEM_HASH] UE4 REDIRECT | orig=%p size=%u", ptr, size);
        ptr = (const void *)(Modules::UE4.AllocAddr + (ptr_addr - Modules::UE4.BaseAddr));
    }
    uintptr_t result = Mem_Hash(ptr, size);
    return result;
}

uintptr_t (*Mem_Hash2)(const void *ptr, uint32_t size);
uintptr_t hook_Mem_Hash2(const void *ptr, uint32_t size)
{
    uintptr_t ptr_addr = (uintptr_t)ptr;

    if (ptr_addr >= Modules::Anogs.BaseAddr && ptr_addr < (Modules::Anogs.BaseAddr + Modules::Anogs.Size))
    {
        ptr = (const void *)(Modules::Anogs.AllocAddr + (ptr_addr - Modules::Anogs.BaseAddr));
    }
    else if (ptr_addr >= Modules::UE4.BaseAddr && ptr_addr < (Modules::UE4.BaseAddr + Modules::UE4.Size))
    {
        ptr = (const void *)(Modules::UE4.AllocAddr + (ptr_addr - Modules::UE4.BaseAddr));
    }
    uintptr_t result = Mem_Hash2(ptr, size);
    return result;
}

uintptr_t (*Mem_Hash3)(const void *ptr, uint32_t size);
uintptr_t hook_Mem_Hash3(const void *ptr, uint32_t size)
{
    uintptr_t ptr_addr = (uintptr_t)ptr;

    if (ptr_addr >= Modules::Anogs.BaseAddr && ptr_addr < (Modules::Anogs.BaseAddr + Modules::Anogs.Size))
    {
        ptr = (const void *)(Modules::Anogs.AllocAddr + (ptr_addr - Modules::Anogs.BaseAddr));
    }
    else if (ptr_addr >= Modules::UE4.BaseAddr && ptr_addr < (Modules::UE4.BaseAddr + Modules::UE4.Size))
    {
        ptr = (const void *)(Modules::UE4.AllocAddr + (ptr_addr - Modules::UE4.BaseAddr));
    }

    uintptr_t result = Mem_Hash3(ptr, size);
    return result;
}

uintptr_t (*crc32)(const void *ptr, uint32_t size);
uintptr_t hook_crc32(const void *ptr, uint32_t size)
{
    uintptr_t ptr_addr = (uintptr_t)ptr;

    if (ptr_addr >= Modules::Anogs.BaseAddr && ptr_addr < (Modules::Anogs.BaseAddr + Modules::Anogs.Size))
    {
        ptr = (const void *)(Modules::Anogs.AllocAddr + (ptr_addr - Modules::Anogs.BaseAddr));
    }
    else if (ptr_addr >= Modules::UE4.BaseAddr && ptr_addr < (Modules::UE4.BaseAddr + Modules::UE4.Size))
    {
        ptr = (const void *)(Modules::UE4.AllocAddr + (ptr_addr - Modules::UE4.BaseAddr));
    }
    uintptr_t result = crc32(ptr, size);
    return result;
}

static void* (*orig_memcpy)(void* dest, const void* src, size_t size) = nullptr;

void* hook_memcpy(void* dest, const void* src, size_t size)
{
    if (!size) return orig_memcpy(dest, src, size);

    const void* redirectedSrc = src;
    uintptr_t srcAddr = reinterpret_cast<uintptr_t>(src);


    if (size > 1000 &&
        Modules::UE4.AllocText && Modules::UE4.BaseAddr && Modules::UE4.TextSize &&
        srcAddr >= Modules::UE4.BaseAddr &&
        srcAddr <  Modules::UE4.BaseAddr + Modules::UE4.TextSize &&
        srcAddr + size <= Modules::UE4.BaseAddr + Modules::UE4.TextSize)
    {
        uintptr_t offset = srcAddr - Modules::UE4.BaseAddr;
        redirectedSrc = reinterpret_cast<const void*>(Modules::UE4.AllocText + offset);
        LOGI(OBFUSCATE(CYAN "[MEMCPY] UE4 .text redirect | src=0x%lx offset=0x%lx size=%zu" RESET), srcAddr, offset, size);
    }

    return orig_memcpy(dest, redirectedSrc, size);
}







__int64 (*osub_73B7D94)(__int64 a1, int a2); // guest login
__int64 hsub_73B7D94(__int64 a1, int a2)
{
    __int64 result = osub_73B7D94(a1, a2);
    // LOGI(OBFUSCATE("LoginCheck -> a2: %d  | return: %lld"), a2, result);
    if (a2 == 46)
    {
        a1 = 0;
        return 5LL;
    }
    return osub_73B7D94(a1, a2);
}

size_t msg_strlen(const char *s) {
    if (s != nullptr) {
        LOGI("String UE4 -> %s ",s);
    if (strstr(s, "BATTLEGROUNDS MOBILE INDIA is not a real-world")) {
    const char *NewMSg = "We have detected that you are using InvernessFree version.You can buy VIP to support the developers of Inverenss.Whish You a Happy Gameplay";
    memset(const_cast<char *>(s), 0, strlen(s)); 
    strcpy(const_cast<char *>(s), NewMSg);
       }
    }
     return strlen(s);
   }

int (*sub_213150)(__int64, __int64); // crash fixer [forcing termination ]

int hook_sub_213150(__int64 a1, __int64 a4)
{
    return 1;
}


__int64 __fastcall (*sub_1DEA8C)(__int64 result, __int64 a2);
__int64 __fastcall hook_sub_1DEA8C(__int64 result, __int64 a2)
{
    return 1; // crash fixer
}
    

  __int64 __fastcall (*sub_23F5A0)(__int64 a1);
  __int64 __fastcall hook_sub_23F5A0(__int64 a1)
  {
  if (a1) {
          uint8_t* ptr = (uint8_t*)a1;
          ptr[925] = 0; 
          ptr[927] = 0; 
      }
      return 0;
  } 

//   __int64 __fastcall (*sub_3A8FD8)(__int64 a1, unsigned int *a2);
//   __int64 __fastcall hook_sub_3A8FD8(__int64 a1, unsigned int *a2)
//   {
//       if (*a2 == 8)
//       {
//           __int64 v3 = *(__int64 *)(a1 + 8);
//           if (v3)
//            {
//                *(unsigned char *)(v3 + 372) = 1;
             
//            }
//       }
//       return sub_3A8FD8(a1, a2);
//   }
__int64 __fastcall (*sub_3A8FD8)(__int64 a1, unsigned int *a2);
__int64 __fastcall hook_sub_3A8FD8(__int64 a1, unsigned int *a2)
{
    if (a1)
    {
        LOGI("func hooked using .data.rel.ro offset 0x3A8FD8");
        
    }
    return sub_3A8FD8(a1, a2);
}
  
  void __fastcall (*sub_404C28)(__int64 a1);
  void __fastcall hook_sub_404C28(__int64 a1)
  {
      __int64 v3 = *(__int64 *)(a1 + 8);
      unsigned int *a2 = *(unsigned int **)(a1 + 48);
       *a2 = 9;
      *(unsigned char *)(v3 + 376) = 0;
      *(__int64 *)(v3 + 304) = *(__int64 *)(v3 + 312) + 1;
      return;
  }





typedef bool (*login_isEmulator_t)(int64_t a1, int64_t a2, _BYTE* a3);
login_isEmulator_t ologin_isEmulator;
bool hlogin_isEmulator(int64_t a1, int64_t a2, _BYTE* a3)
{
    bool result;
    result = ologin_isEmulator(a1, a2, a3);
    if (result)
    {
        result = false;
        *a3 = result;
    }
    else 
    {

    }
    return result;
}


int __fastcall (*sub_6E55B04)(int a1, float a2, int a3); // 32 bit 
int __fastcall hook_sub_6E55B04(int a1, float a2, int a3)
{
    long double original_result = sub_6E55B04(a1, a2, a3);
    float fps = *(float *)&original_result;
    
    
    if (fps == 120.0f || fps == 90.0f || fps == 64.0f) {
      
        fps = 240.0f;
    }
    
    *(float *)&original_result = fps;
    return original_result;
}

__int64 __fastcall (*sub_646DC18)(__int64 a1, int a2);
__int64 __fastcall hook_sub_646DC18(__int64 a1, int a2)
{
  
    return 165LL;
}
__int64 __fastcall (*sub_646D7B8)(__int64 a1);
__int64 __fastcall hook_sub_646D7B8(__int64 a1)
{
  
    return 6LL;
}

template<typename T>
bool HookGOT(uintptr_t lib_base, uintptr_t offset, T hook_func, T* orig_func) {
    if (!lib_base) return false;

    uintptr_t* got_entry = reinterpret_cast<uintptr_t*>(lib_base + offset);

    // Cache original before touching anything
    if (orig_func) {
        *orig_func = reinterpret_cast<T>(*got_entry);
    }

    const uintptr_t hook_val = reinterpret_cast<uintptr_t>(hook_func);

    // --- Primary path: write through /proc/self/mem (zero permission change) ---
    int fd = open("/proc/self/mem", O_RDWR);
    if (fd >= 0) {
        off_t target = static_cast<off_t>(reinterpret_cast<uintptr_t>(got_entry));
        if (lseek(fd, target, SEEK_SET) == target) {
            ssize_t written = write(fd, &hook_val, sizeof(hook_val));
            close(fd);
            if (written == static_cast<ssize_t>(sizeof(hook_val))) {
                return true;
            }
        } else {
            close(fd);
        }
    }

    // --- Fallback: mprotect, write, restore original permissions ---
    size_t page_size = static_cast<size_t>(sysconf(_SC_PAGESIZE));
    uintptr_t page_addr = reinterpret_cast<uintptr_t>(got_entry) & ~(page_size - 1);
    void* page_start    = reinterpret_cast<void*>(page_addr);

    // Read current perms from /proc/self/maps before touching them
    int orig_prot = PROT_READ; // safe default — GOT is normally r--p
    {
        FILE* fp = fopen("/proc/self/maps", "r");
        if (fp) {
            char line[256];
            while (fgets(line, sizeof(line), fp)) {
                uintptr_t s, e;
                char perms[5] = {};
                if (sscanf(line, "%lx-%lx %4s", &s, &e, perms) == 3 &&
                    s <= page_addr && page_addr < e) {
                    orig_prot = 0;
                    if (perms[0] == 'r') orig_prot |= PROT_READ;
                    if (perms[1] == 'w') orig_prot |= PROT_WRITE;
                    if (perms[2] == 'x') orig_prot |= PROT_EXEC;
                    break;
                }
            }
            fclose(fp);
        }
    }

    if (mprotect(page_start, page_size, PROT_READ | PROT_WRITE) != 0)
        return false;

    *got_entry = hook_val;
    __sync_synchronize(); 
    mprotect(page_start, page_size, orig_prot);
    return true;
}





size_t (*orig_strlen)(const char* str) = nullptr;

static __thread int hk_strlen_depth = 0;

size_t hk_strlen(const char* str) {
    if (!str) return orig_strlen(str);
    if (hk_strlen_depth) return orig_strlen(str); 

    hk_strlen_depth = 1;

    char* mstr = const_cast<char*>(str);
       LOGI(OBFUSCATE("strlen called: %s"), mstr);
    if (strstr(str, "/dev/awd")) {
       memcpy(mstr, "/dev/GG", sizeof("/dev/GG"));
    }
    if ( strstr(str, HIDE_STR("eglSwapBuffers")))
    {
        LOGI("Blocked %s ",mstr);
        return 0;
    }
    if (
        strstr(str, HIDE_STR("/share1/"))        ||
        strstr(str, HIDE_STR("/dev/wanbai"))      ||
        strstr(str, HIDE_STR("/dev/kgsl-3d0"))    ||
        strstr(str, HIDE_STR("libhoudini.so"))    ||
        strstr(str, HIDE_STR("libhoudini_415c.so")) ||
        strstr(str, HIDE_STR("libhoudini_408.so"))  ||
        strstr(str, HIDE_STR("libhoudini_408p.so")) ||
        strstr(str, HIDE_STR("libhotx711.so"))    ||
        strstr(str, HIDE_STR("libhotx612.so"))  
     
      
        )
    {
        LOGI(RED"[Blocked] -> %s" RESET, str);
        memcpy(mstr, "lotum", sizeof("lotum"));
    }

    hk_strlen_depth = 0;
    return orig_strlen(str);
}

static inline bool ptr_ok(uintptr_t p)
{
    return p > 0x10000ULL && p < 0x800000000000ULL;
}

#define RD64(a) (*(volatile uintptr_t *)(a))

/* ── offsets ──────────────────────────────────────────────────────────── */

uintptr_t OFF_STRING_POOL = oxorany(0x57A1A8);
uintptr_t OFF_RULE_SINGLETON = oxorany(0x57F098);
constexpr int RT_S_ARR = 688;
constexpr int RT_S_CNT = 1488;
constexpr int RT_RS_ROOT = 448;
constexpr int RT_R_RECS = 64;
constexpr int RT_REC_ENTS = 368;
constexpr int RT_ENT_NODE = 1032;

/* ── emulator string patterns ───────────────────────────────────────── */

static const char *EMU_PAT[] = {"libhoudini", "libhotx"};
constexpr int N_PAT = sizeof(EMU_PAT) / sizeof(EMU_PAT[0]);

OLLVM
static bool is_emu(const char *s)
{
    if (!s || !*s)
        return false;
    for (int i = 0; i < N_PAT; i++)
        if (strstr(s, EMU_PAT[i]))
            return true;
    return false;
}

OLLVM
static void poison(char *buf, size_t len)
{
    for (size_t i = 0; i < len; i++)
        buf[i] = '_';
}

/* ── libc++ std::string helpers (ARM64) ─────────────────────────────── */

struct libcxx_string
{
    union
    {
        struct
        {
            uint8_t flag;
            char data[23];
        } sso;
        struct
        {
            uintptr_t cap;
            size_t size;
            char *data;
        } lng;
    };

    bool is_long() const { return sso.flag & 1; }
    size_t length() const { return is_long() ? lng.size : (sso.flag >> 1); }
    char *data_ptr() { return is_long() ? lng.data : &sso.data[0]; }
    const char *c_str() const
    {
        return is_long() ? lng.data : &sso.data[0];
    }
};

/* ── 1. patch STRING POOL at 0x57A1A8 ────────────────────────────────── */

static int patch_pool(uintptr_t base)
{
    auto *pool = reinterpret_cast<std::vector<std::string> *>(base + OFF_STRING_POOL);
    if (!pool || pool->empty())
        return 0;
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

/* ── 2. patch rule tree — follow the HANDLER'S pointer chain ─────────── */
/*                                                                        */
/*  The handler sub_32C404 does:                                          */
/*    X8 = *(node + 0x20)       // pointer at node+32                     */
/*    X0 = X8 + 0x28            // string object at +40 from that ptr     */
/*    result = sub_2E2FD0(X0)   // c_str() accessor                       */
/*                                                                        */
/*  We were patching node+40 (the display std::string), but the handler   */
/*  reads from *(node+32) + 40 — a DIFFERENT string object.               */

static int g_patched;

OLLVM
static void walk_patch(uintptr_t nd, int depth)
{
    if (!nd || !ptr_ok(nd) || depth > 8)
        return;

    uint8_t ntype = *(uint8_t *)(nd + 24);
    uint8_t nsub = *(uint8_t *)(nd + 25);

    /* ── check the display string at node+40 for identification ───── */
    auto *s40 = reinterpret_cast<std::string *>(nd + 40);
    bool emu_node = (!s40->empty() && is_emu(s40->c_str()));

    if (emu_node && ntype == 1 && nsub == 5)
    {
        LOGI("[tree] t1.s5 node=%p display=\"%s\"", (void *)nd, s40->c_str());

        /* patch the display string (node+40) for completeness */
        poison(&(*s40)[0], s40->size());

        /* ── follow the HANDLER's pointer chain: *(node+32) + 40 ── */
        uintptr_t str_obj_ptr = *(uintptr_t *)(nd + 32);
        LOGI("[tree]   node+32 = %p (node=%p delta=%ld)",
             (void *)str_obj_ptr, (void *)nd,
             str_obj_ptr ? (long)(str_obj_ptr - nd) : 0L);

        if (str_obj_ptr && ptr_ok(str_obj_ptr))
        {
            uintptr_t data_field = str_obj_ptr + 40;

            auto *handler_str = reinterpret_cast<libcxx_string *>(data_field);
            const char *hs = handler_str->c_str();

           size_t hlen = handler_str->length();
            if (hlen > 0 && hlen < 256 && hs[0] >= 0x20 && hs[0] <= 0x7e)
            {
                LOGI("[tree]   handler_str(std) = \"%s\" len=%zu", hs, hlen);
                if (is_emu(hs))
                {
                    poison(handler_str->data_ptr(), hlen);
                    LOGI("[tree]   PATCHED handler std::string");
                    g_patched++;
                }
            }

            char *raw = (char *)data_field;
            if (raw[0] >= 0x20 && raw[0] <= 0x7e)
            {
                size_t rlen = strnlen(raw, 256);
                if (rlen > 3 && rlen < 200 && is_emu(raw))
                {
                    LOGI("[tree]   handler_str(raw) = \"%s\" len=%zu", raw, rlen);
                    poison(raw, rlen);
                    LOGI("[tree]   PATCHED handler raw bytes");
                    g_patched++;
                }
            }

            uintptr_t maybe_ptr = *(uintptr_t *)data_field;
            if (maybe_ptr && ptr_ok(maybe_ptr))
            {
                char *indirect = (char *)maybe_ptr;
                if (indirect[0] >= 0x20 && indirect[0] <= 0x7e)
                {
                    size_t ilen = strnlen(indirect, 256);
                    if (ilen > 3 && ilen < 200 && is_emu(indirect))
                    {
                        LOGI("[tree]   handler_str(ptr) = \"%s\" @ %p", indirect, (void *)maybe_ptr);
                        poison(indirect, ilen);
                        LOGI("[tree]   PATCHED handler indirect");
                        g_patched++;
                    }
                }
            }
        }

        auto *inline_str = reinterpret_cast<libcxx_string *>(nd + 32);
        const char *ils = inline_str->c_str();
        size_t illen = inline_str->length();
        if (illen > 0 && illen < 256 && ils[0] >= 0x20 && ils[0] <= 0x7e)
        {
            if (is_emu(ils))
            {
                LOGI("[tree]   inline_str @ node+32 = \"%s\"", ils);
                poison(inline_str->data_ptr(), illen);
                LOGI("[tree]   PATCHED inline string");
                g_patched++;
            }
        }
    }

    auto *ch = reinterpret_cast<std::vector<uintptr_t> *>(nd + 64);
    for (size_t i = 0; i < ch->size(); i++)
    {
        uintptr_t child = (*ch)[i];
        if (child && ptr_ok(child))
            walk_patch(child, depth + 1);
    }
}

OLLVM
static int patch_tree(uintptr_t base)
{
    uintptr_t singleton = RD64(base + OFF_RULE_SINGLETON);
    if (!singleton || !ptr_ok(singleton))
        return 0;

    int32_t cnt = *(volatile int32_t *)(singleton + RT_S_CNT);
    if (cnt <= 0 || cnt > 100)
        return 0;

    g_patched = 0;

    for (int rs = 0; rs < cnt; rs++)
    {
        uintptr_t resset = RD64(singleton + RT_S_ARR + (uintptr_t)rs * 8);
        if (!resset || !ptr_ok(resset))
            continue;
        uintptr_t root = RD64(resset + RT_RS_ROOT);
        if (!root || !ptr_ok(root))
            continue;

        auto *recs = reinterpret_cast<std::vector<uintptr_t> *>(root + RT_R_RECS);
        for (size_t r = 0; r < recs->size(); r++)
        {
            uintptr_t rec = (*recs)[r];
            if (!rec || !ptr_ok(rec))
                continue;
            auto *ents = reinterpret_cast<std::vector<uintptr_t> *>(rec + RT_REC_ENTS);
            for (size_t e = 0; e < ents->size(); e++)
            {
                uintptr_t entry = (*ents)[e];
                if (!entry || !ptr_ok(entry))
                    continue;
                uintptr_t node = *(uintptr_t *)(entry + RT_ENT_NODE);
                if (node && ptr_ok(node))
                    walk_patch(node, 0);
            }
        }
    }
    return g_patched;
}



void *install_emu_hooks(void *)
{
    uintptr_t base = libs::ANOGS.base;
    if (!base)
    {
        LOGI("base not set");
        return nullptr;
    }
    LOGI("install_emu_hooks base=%p", (void *)base);

    auto *pool = reinterpret_cast<std::vector<

std::string> *>(base + OFF_STRING_POOL);
    for (int i = 0; i < 36000; i++)
    {
        if (pool->size() > 0)
            break;
        usleep(10 * 1000);
    }
    LOGI("pool: %zu entries", pool->size());

    for (int i = 0; i < 36000; i++)
    {
        uintptr_t s = RD64(base + OFF_RULE_SINGLETON);
        if (s && ptr_ok(s))
        {
            int32_t c = *(volatile int32_t *)(s + RT_S_CNT);
            if (c > 0)
                break;
        }
        usleep(10 * 1000);
    }
    LOGI("rule singleton ready");

    int pool_total = 0, tree_total = 0;

    while (true)
    {
        int p = patch_pool(base);
        int t = patch_tree(base);

        if (p > 0 || t > 0)
        {
            pool_total += p;
            tree_total += t;
            LOGI("[emu] round pool=%d tree=%d (total pool=%d tree=%d)", p, t, pool_total, tree_total);
        }

        usleep(50 * 1000);
    }

    return nullptr;
}



























OLLVM_PROTECT("bcf igv ibr icall sub split")

void *main_thread(void *)
{

      LOGI(OBFUSCATE("Main thread started"));
     //puffer_log();
    while (!isLibraryLoaded_local("libanogs.so"))
        sleep(1);
      LOGI(OBFUSCATE("libanogs.so loaded"));

    libanogsheader = getLibraryBaseAddress("libanogs.so");
    if (!libanogsheader)
    {
         LOGI(OBFUSCATE("Failed to resolve libanogs.so base address"));
         return nullptr;
    }

     LOGI("libanogs base -> 0x%lx", libanogsheader);
    Modules::Anogs.BaseAddr = libanogsheader;
    Modules::Anogs.Size = getLibrarySize("libanogs.so");
    Modules::Anogs.TextSize = getLibraryTextSize(Modules::Anogs.BaseAddr);
     LOGI(OBFUSCATE("Anogs .text size-> 0x%lx"), Modules::Anogs.TextSize);
     LOGI(OBFUSCATE("Anogs size: 0x%lx"), Modules::Anogs.Size);

    // Allocate clean backup memory
    Modules::Anogs.AllocAddr = (uintptr_t)malloc(Modules::Anogs.Size);
    if (!Modules::Anogs.AllocAddr)
    {
        LOGE(OBFUSCATE("Failed to allocate Anogs backup memory"));
        return nullptr;
    }
    Modules::Anogs.AllocText = (uintptr_t)malloc(Modules::Anogs.TextSize);
    if (!Modules::Anogs.AllocText)
    {
        LOGE(OBFUSCATE("Failed to allocate Anogs Text backup memory"));
        return nullptr;
    }

    // COPY ORIGINAL
     memcpy((void *)Modules::Anogs.AllocAddr, (void *)Modules::Anogs.BaseAddr, Modules::Anogs.Size);
     LOGI(OBFUSCATE("Anogs full backup copied to 0x%lx"), Modules::Anogs.AllocAddr);

    // COPY CLEAN .text
     memcpy((void *)Modules::Anogs.AllocText, (void *)Modules::Anogs.BaseAddr, Modules::Anogs.TextSize);
     LOGI(OBFUSCATE("Anogs clean .text backup copied to 0x%lx"), Modules::Anogs.AllocText);
   // GlossInit(false);
    check = true;
    pthread_t ptid_emu;
    pthread_create(&ptid_emu, NULL, emu_thread, NULL);
    pthread_detach(ptid_emu);



   //fps_thread_NonVIP
//    pthread_t ptid_fps;
//    pthread_create(&ptid_fps, NULL, fps_thread_NonVIP, NULL);
//    pthread_detach(ptid_fps);



 //HOOK_LIB_NO_ORIG("libanogs.so", "0x51F980", hook_memcpy);
 //HOOK_LIB_NO_ORIG("libanogs.so", "0x51F98C", hook_memcpy);
// HOOK_LIB("libanogs.so", "0x39F56C", hook_Hash, Hash);
// HOOK_LIB("libanogs.so", "0x330494", hook_Mem_Hash, Mem_Hash);
// HOOK_LIB("libanogs.so", "0x338680", hook_Mem_Hash2, Mem_Hash2);
// HOOK_LIB("libanogs.so", "0x39F644", hook_Mem_Hash3, Mem_Hash3);

//   HOOK_LIB("libanogs.so", "0x1DEA8C", hook_sub_1DEA8C, sub_1DEA8C);  // crash fixer
// // HOOK_LIB("libanogs.so", "0x21248C", hook_sub_21248C, sub_21248C); // crash fixer
//   HOOK_LIB("libanogs.so", "0x37C904", hook_sub_37C904, sub_37C904);
//   HOOK_LIB("libanogs.so", "0x37966C", hook_sub_37966C, sub_37966C);
//   HOOK_LIB("libanogs.so", "0x23F5A0", hook_sub_23F5A0, sub_23F5A0);//10year 
//   HOOK_LIB("libanogs.so", "0x3A8FD8", hook_sub_3A8FD8, sub_3A8FD8);//10year
//   HOOK_LIB("libanogs.so", "0x404C28", hook_sub_404C28, sub_404C28);//10year
//   HOOK_LIB("libanogs.so", "0x225528", hook_sub_225528, sub_225528);//case 1
 
//    HOOK_LIB("libanogs.so", "0x3211B8", hook_sub_3211B8, osub_3211B8); 
//    HOOK_LIB_NO_ORIG("libanogs.so", "0x51F9C0", strlen_h); 
//    HOOK_LIB("libanogs.so", "0x2F5670", hook_sub_2F5670, sub_2F5670);//egl_10year
  //HOOK_LIB("libanogs.so", "0x2F553C", hook_strlen, orig_strlen);



   orig_strlen = (size_t(*)(const char*))dlsym(RTLD_DEFAULT, "strlen");
  HookGOT(libanogsheader, 0x52E300, hk_strlen, (size_t(**)(const char*))nullptr);
  // HookGOT(libanogsheader, 0x528510, hook_sub_3A8FD8, &sub_3A8FD8);






    while (!isLibraryLoaded_local("libhdmpve.so")) 
        sleep(1);
    LOGI(OBFUSCATE("libhdmpve.so loaded "));


  
 
    while (!isLibraryLoaded_local("libUE4.so"))
        sleep(1);
    LOGI(OBFUSCATE("libUE4.so loaded"));
    
    libUE4header = getLibraryBaseAddress("libUE4.so");
    if (!libUE4header)
    {
        LOGI(OBFUSCATE("Base not found"));
        return nullptr;
    }
    Modules::UE4.BaseAddr = libUE4header;
    Modules::UE4.Size = getLibrarySize("libUE4.so");
    LOGI(OBFUSCATE("UE4 size: 0x%lx"), Modules::UE4.Size);
    Modules::UE4.AllocAddr = (uintptr_t)malloc(Modules::UE4.Size);
    Modules::UE4.TextSize = getLibraryTextSize(Modules::UE4.BaseAddr);
    LOGI(OBFUSCATE(".Text Size of UE4 is 0x%lx"),Modules::UE4.TextSize);
    if (!Modules::UE4.AllocAddr)
    {
        LOGE(OBFUSCATE("Failed to allocate UE4 backup memory"));
        return nullptr;
    }
    Modules::UE4.AllocText = (uintptr_t)malloc(Modules::UE4.TextSize);
    if (!Modules::UE4.AllocText)
    {
        LOGE(OBFUSCATE("Failed to allocate ue4 Text backup memory"));
        return nullptr;
    }

     memcpy((void *)Modules::UE4.AllocText, (void *)Modules::UE4.BaseAddr, Modules::UE4.TextSize);
     LOGI(OBFUSCATE("UE4 clean .text backup copied to 0x%lx"), Modules::UE4.AllocText);

    memcpy((void *)Modules::UE4.AllocAddr, (void *)Modules::UE4.BaseAddr, Modules::UE4.Size);
    LOGI(OBFUSCATE("UE4 backup copied to 0x%lx"), Modules::UE4.AllocAddr);
   
 




 //  HOOK_LIB("libUE4.so", "0x74DC6C0", hlogin_isEmulator, ologin_isEmulator);
  // PATCH_LIB("libUE4.so","0x5952F70","C0 03 5F D6");
 //  PATCH_LIB("libUE4.so","0x7385F14","E0 03 00 37");
 //  HOOK_LIB("libUE4.so", "0xA3B85E0", hook_sub_A3B85E0, sub_A3B85E0);
//    HOOK_LIB("libUE4.so", "0xAF02AF8", hk_luaL_loadbufferx, orig_luaL_loadbufferx);
//    HOOK_LIB("libUE4.so", "0xAEDF2E8", hk_lua_pcallx, orig_lua_pcallx);
//    HOOK_LIB("libUE4.so", "0x646DC18", hook_sub_646DC18, sub_646DC18);//unlock fps 
//    HOOK_LIB("libUE4.so", "0x646D7B8", hook_sub_646D7B8, sub_646D7B8);//unlock UHD

  // PATCH_LIB("libUE4.so","0xB2A07D0","0C 10 27 1E");



  return NULL;
}


static void delme()
{
    Dl_info info;
    if (dladdr((void*)&delme, &info) && info.dli_fname)
    {
        unlink(info.dli_fname);
    }
}

#define MY_INJ_KEY 0xDEAD8888

// extern "C"
// JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* key)
// {
//     delme();

//     if (key != (void*)MY_INJ_KEY) {
//         return JNI_VERSION_1_6;
//     }

//     std::thread(main_thread, nullptr).detach();

//     return JNI_VERSION_1_6;
// }  



__attribute__((constructor)) void lib_main() //

{
 //   delme();
    LOGI(OBFUSCATE("Library Loaded"));
    pthread_t ptid;
    pthread_create(&ptid, NULL, main_thread, NULL);
    pthread_detach(ptid);



}
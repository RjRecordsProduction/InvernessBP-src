
#include <list>
#include <vector>
#include <cstring>
#include <pthread.h>
#include <thread>
#include <jni.h>
#include <unistd.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <dlfcn.h>
#include <unwind.h>
#include <cstdint>
#include <algorithm>
#include <random>
#include <ctime>
#include <cstdlib>
#include <errno.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <android/log.h>
#include <inttypes.h> // <-- ADDED for PRIxPTR
#include <sys/mman.h>
#include <unistd.h>
#include <cstdint>
#include <cstring>
#include "Includes/Logger.h"


#include "Includes/obfuscate.h"
#undef OBFUSCATE
#define OBFUSCATE(str) str
#include "Includes/Utils.h"
#include "KittyMemory/MemoryPatch.h"
#include "Menu/Setup.h"
#include "Includes/Macros.h"
#include "dobby/dobby.h"
#include "Includes/Backtrace.h"
#include "Gloss.h"
#include "GlossHook/include/Gloss.h"
#include "oxorany/oxorany.h"
#include "oxorany/confusion.h"
#include "Signatures.h"
#include "MessageBox.h"
#include <fcntl.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <dirent.h>
#include <cstdint>
#include <string.h>
#include <set>
#include "Anogs.h"
#include "lua.h"
#include <unordered_map>
#include <unordered_set>
#include <string>
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
#if defined(__clang__)
#define OLLVM_PROTECT(attrs) __attribute__((noinline, annotate(attrs)))
#else
#define OLLVM_PROTECT(attrs)
#endif
#include"lua.h"
bool check = false;
bool lol = false;

static uintptr_t AntiEmulator = 0;
uintptr_t libanogsheader = 0;
uintptr_t libUE4header = 0;
uintptr_t libTBlueDataheader = 0;

bool disableLogI = false;


#include "graphic.h"
#define PUFFERLOG_PATH HIDE_STR("/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Logs/pufferlog.txt")
#define Check_num HIDE_STR("141707010E0B1711")
bool file_exist(const char *path)
{
    struct stat st;
    return (stat(path, &st) == 0);
}


std::string GetPackageName() {
    char cmdline[256] = {0};
    FILE* fp = fopen("/proc/self/cmdline", "r");
    if (fp) {
        size_t bytes = fread(cmdline, 1, sizeof(cmdline) - 1, fp);
        fclose(fp);
        if (bytes > 0) {
 
              std::string name(cmdline);
                name.erase(std::remove_if(name.begin(), name.end(), [](unsigned char c) {
                return std::isspace(c) || !std::isprint(c);
            }), name.end());
            return name;
        }
    }
    return "";
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
    FILE *f = fopen(path, HIDE_STR("r"));
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
        LOGI(HIDE_STR( RED "Pufferlog not found... " RESET));
        sleep(2);
        entropy_die();
    }
    if (!check_num(PUFFERLOG_PATH, Check_num))
    {
          LOGI(HIDE_STR( RED "Pufferlog integrity check failed... " RESET));
        sleep(2);
        entropy_die();
    }
      LOGI(HIDE_STR( GREEN "Pufferlog integrity check passed. " RESET));
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
    if (!fp) return 0;

    char line[512];
    uintptr_t start_addr = 0;
    uintptr_t end_addr = 0;
    while (fgets(line, sizeof(line), fp))
    {
        if (strstr(line, libraryName))
        {
            uintptr_t start, end;
            if (sscanf(line, "%lx-%lx", &start, &end) == 2)
            {
                if (start_addr == 0) start_addr = start;
                end_addr = end;
            }
        }
    }
    fclose(fp);
    return (start_addr == 0) ? 0 : (end_addr - start_addr);
}


uintptr_t SafeLibraryBackup(const char* libraryName, size_t& outSize) {
    size_t totalSpan = getLibrarySize(libraryName);
    if (totalSpan == 0) return 0;
    uintptr_t base = getLibraryBaseAddress(libraryName);
    void* backup = malloc(totalSpan);
    if (!backup) return 0;


    memset(backup, 0, totalSpan);

    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp) {
        free(backup);
        return 0;
    }

    char line[512];
    while (fgets(line, sizeof(line), fp)) {
        if (strstr(line, libraryName)) {
            uintptr_t start, end;
            char perms[5];
            if (sscanf(line, "%lx-%lx %4s", &start, &end, perms) == 3) {
                // Only copy if readable
                if (perms[0] == 'r') {
                    size_t offset = start - base;
                    size_t size = end - start;
                    if (offset + size <= totalSpan) {
                        memcpy((uint8_t*)backup + offset, (void*)start, size);
                    }
                }
            }
        }
    }
    fclose(fp);
    outSize = totalSpan;
    return (uintptr_t)backup;
}



size_t getLibraryTextSize(uintptr_t baseAddr)
{
    FILE *fp = fopen("/proc/self/maps", "r");
    if (!fp)
        return 0;

    char line[512];
    while (fgets(line, sizeof(line), fp))
    {
        uintptr_t start = 0, end = 0;
        char perms[5] = {};

        if (sscanf(line, "%lx-%lx %4s", &start, &end, perms) != 3)
            continue;

        if (start == baseAddr)
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
    if (!base || !hex) return;

    std::string hexStr(hex);
    hexStr.erase(std::remove_if(hexStr.begin(), hexStr.end(), [](unsigned char c) { return std::isspace(c); }), hexStr.end());
    
    size_t len = hexStr.length();
    if (len == 0 || len % 2 != 0) return;

    std::vector<uint8_t> bytes;
    bytes.reserve(len / 2);
    for (size_t i = 0; i < len; i += 2) {
        char tmp[3] = { hexStr[i], hexStr[i+1], '\0' };
        bytes.push_back((uint8_t)strtoul(tmp, nullptr, 16));
    }

    WriteMemory((void*)(base + offset), bytes.data(), bytes.size(), true);
}

int return_0() {
    return 0;
}

template<typename T>
void RedirectDataPointer(uintptr_t libBase, uintptr_t dataOffset, T replacementFunction) {
    if (!libBase) return;
    
    uint32_t* ptr_to_patch = (uint32_t*)(libBase + dataOffset);
    
   
    long pageSize = sysconf(_SC_PAGESIZE);
    uintptr_t pageStart = ((uintptr_t)ptr_to_patch) & ~(pageSize - 1);
    mprotect((void*)pageStart, pageSize, PROT_READ | PROT_WRITE | PROT_EXEC);
    
   
    *ptr_to_patch = (uint32_t)replacementFunction;
    

    __builtin___clear_cache((char*)ptr_to_patch, (char*)ptr_to_patch + sizeof(uint32_t));
}

#define PATCH_DATA(base, offset, replacement) RedirectDataPointer(base, offset, replacement)

template<typename T>
bool HookGOT(uintptr_t lib_base, uintptr_t offset, T hook_func, T* orig_func) {
    if (!lib_base) return false;

    uintptr_t* got_entry = reinterpret_cast<uintptr_t*>(lib_base + offset);

    if (orig_func) {
        *orig_func = reinterpret_cast<T>(*got_entry);
    }

    const uintptr_t hook_val = reinterpret_cast<uintptr_t>(hook_func);
 
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


    size_t page_size = static_cast<size_t>(sysconf(_SC_PAGESIZE));
    uintptr_t page_addr = reinterpret_cast<uintptr_t>(got_entry) & ~(page_size - 1);
    void* page_start    = reinterpret_cast<void*>(page_addr);

    int orig_prot = PROT_READ; 
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

template<typename T>
bool HookData(uintptr_t lib_base, uintptr_t offset, T hook_func, T* orig_func) {
    if (!lib_base) return false;
    
    uintptr_t* data_entry = reinterpret_cast<uintptr_t*>(lib_base + offset);
   
    if (orig_func) {
        *orig_func = reinterpret_cast<T>(*data_entry);
    }
       
    const uintptr_t hook_val = reinterpret_cast<uintptr_t>(hook_func);

   int fd = open("/proc/self/mem", O_RDWR);
    if (fd >= 0) {
        off_t target = static_cast<off_t>(reinterpret_cast<uintptr_t>(data_entry));
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

  
    size_t page_size = static_cast<size_t>(sysconf(_SC_PAGESIZE));
    uintptr_t page_addr = reinterpret_cast<uintptr_t>(data_entry) & ~(page_size - 1);
    void* page_start    = reinterpret_cast<void*>(page_addr);

    int orig_prot = PROT_READ; // safe default
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

    *data_entry = hook_val;
    __sync_synchronize(); 
    mprotect(page_start, page_size, orig_prot);
    return true;
}

extern bool is_from_anogs(void* ret);
extern FILE* (*o_fopen)(const char* filename, const char* mode);

// Emulator file blocklist — access/stat probes return ENOENT for these
static const char* const EMU_FILE_BLOCKLIST[] = {
    // Emulator configurations
    "/init.vbox86.rc",
    "/init.pscloud.rc",
    "/init.dundi.rc",
    "/init.rockchip.rc",
    "/init.rk30board.rc",
    "/init.hi3660.rc",
    "/init.androidVM_x86.rc",
    "/init.android_x86.rc",
    "/init.vbox64.rc",
    "/fstab.vbox86",
    "/fstab.vbox64",
    "/ueventd.vbox64.rc",
    // Emulator libraries
    "/system/lib/libKaopuSdk.so",
    "/system/lib/libc_malloc_debug_qemu.so",
    "/system/lib/libc_malloc_debug_qemu.so-arm",
    "/system/lib/libldutils.so",
    "/system/lib/libdroidbox-ril.so",
    "/system/lib/libnoxd.so",
    "/system/lib/libhotx612.so",
    "/system/lib/libhotx711.so",
    // Emulator properties
    "/system/bin/ttVM-prop",
    "/system/bin/microvirt-prop",
    "/system/bin/XCPlayer-prop",
    "/system/bin/xiaopiVM-prop",
    "/system/bin/androVM-prop",
    "/system/bin/nemuVM-prop",
    "/system/./bin/nox-prop",
    "/system/bin/nox-prop",
    "/system/bin/droid4x-prop",
    "/x86.prop",
    // Emulator applications
    "/system/app/LauncherEx/LauncherEx.apk",
    "/data/data/com.android.ld.appstore",
    "/data/data/com.ldmnq.launcher3/",
    "/data/./data/com.bluestacks.appmart",
    "/data/data/com.bluestacks.appmart",
    // Emulator devices
    "/dev/socket/genyd",
    "/dev/virtpipe-sec",
    "/dev/awd",
    "/dev/virtpipe",
    "/dev/virtpipe-common",
    "/dev/virtpipe-common-syzsaow",
    "/dev/virtpipe-render",
    "/dev/goldfish_sync",
    "/dev/goldfish_pipe",
    "/dev/qemu_pipe",
};
static constexpr int EMU_FILE_BLOCKLIST_COUNT = sizeof(EMU_FILE_BLOCKLIST) / sizeof(EMU_FILE_BLOCKLIST[0]);

// Substring patterns for device path blocking (partial match)
static const char* const EMU_DEVICE_PATTERNS[] = {
    "dev/awd",
    "goldfish_sync",
    "goldfish_pipe",
    "virtpipe",
    "qemu_pipe",
    "qemu",
    "genyd",
    "vbox86",
    "vbox64",
    "nox-prop",
    "androVM-prop",
    "microvirt-prop",
    "ttVM-prop",
    "XCPlayer-prop",
    "xiaopiVM-prop",
    "nemuVM-prop",
    "droid4x-prop",
    "libKaopuSdk",
    "libc_malloc_debug_qemu",
    "libldutils",
    "libdroidbox-ril",
    "libnoxd",
    "LauncherEx.apk",
    "com.android.ld.appstore",
    "com.ldmnq.launcher3",
    "com.bluestacks.appmart",
    "init.vbox86",
    "init.vbox64",
    "init.pscloud",
    "init.dundi",
    "init.androidVM_x86",
    "init.android_x86",
    "fstab.vbox86",
    "fstab.vbox64",
    "ueventd.vbox64",
    "x86.prop",
};
static constexpr int EMU_DEVICE_PATTERNS_COUNT = sizeof(EMU_DEVICE_PATTERNS) / sizeof(EMU_DEVICE_PATTERNS[0]);

static bool is_emu_path(const char* path) {
    if (!path) return false;
    for (int i = 0; i < EMU_FILE_BLOCKLIST_COUNT; i++) {
        if (strcmp(path, EMU_FILE_BLOCKLIST[i]) == 0) return true;
    }
    for (int i = 0; i < EMU_DEVICE_PATTERNS_COUNT; i++) {
        if (strstr(path, EMU_DEVICE_PATTERNS[i])) return true;
    }
    return false;
}

const char* get_clean_maps_path() {
    static std::string clean_maps_path = "";
    std::string pkg = GetPackageName();
    if (pkg.empty()) {
        pkg = "com.pubg.imobile";
    }
    clean_maps_path = "/data/data/" + pkg + "/clean_maps";

    FILE* real_maps = o_fopen ? o_fopen("/proc/self/maps", "r") : fopen("/proc/self/maps", "r");
    if (!real_maps) {
        LOGE(HIDE_STR("[MAPS_BLOCK] Failed to open real maps: %s"), strerror(errno));
        return "/proc/self/maps";
    }

    FILE* fake_maps = o_fopen ? o_fopen(clean_maps_path.c_str(), "w") : fopen(clean_maps_path.c_str(), "w");
    if (!fake_maps) {
        LOGE(HIDE_STR("[MAPS_BLOCK] Failed to open/create clean_maps at: %s (error: %s)"), clean_maps_path.c_str(), strerror(errno));
        fclose(real_maps);
        return "/proc/self/maps";
    }
    char line[1024];
    while (fgets(line, sizeof(line), real_maps)) {
        if (strstr(line, "libAkAudioVisiual.so") ||
            strstr(line, "libhoudini") ||
            strstr(line, "libhotx") ||
            strstr(line, "libMem.so") ||
            strstr(line, "/share1/") ||
            strstr(line, "/dev/wanbai") ||
            strstr(line, "/dev/kgsl-3d0") ||
            strstr(line, "/dev/awd") ||
            strstr(line, "goldfish") ||
            strstr(line, "qemu") ||
            strstr(line, "virtpipe") ||
            strstr(line, "androidrepublic") ||
            strstr(line, "libhotx612.so") ||
            strstr(line, "libhotx711.so") ||
            strstr(line, "libnoxd.so") ||
            strstr(line, "libKaopuSdk.so") ||
            strstr(line, "libc_malloc_debug_qemu") ||
            strstr(line, "libldutils.so") ||
            strstr(line, "libdroidbox-ril.so")) {
            continue;
        }
        fputs(line, fake_maps);
    }

    fclose(real_maps);
    fclose(fake_maps);

    return clean_maps_path.c_str();
}

// Filtered cpuinfo — strips goldfish/ranchu/qemu identifiers
const char* get_clean_cpuinfo_path() {
    static std::string clean_cpuinfo_path = "";
    std::string pkg = GetPackageName();
    if (pkg.empty()) pkg = "com.pubg.imobile";
    clean_cpuinfo_path = "/data/data/" + pkg + "/clean_cpuinfo";

    FILE* real = o_fopen ? o_fopen("/proc/cpuinfo", "r") : fopen("/proc/cpuinfo", "r");
    if (!real) return "/proc/cpuinfo";

    FILE* fake = o_fopen ? o_fopen(clean_cpuinfo_path.c_str(), "w") : fopen(clean_cpuinfo_path.c_str(), "w");
    if (!fake) { fclose(real); return "/proc/cpuinfo"; }

    char line[1024];
    while (fgets(line, sizeof(line), real)) {
        if (strstr(line, "Goldfish") || strstr(line, "goldfish") ||
            strstr(line, "ranchu") || strstr(line, "QEMU") ||
            strstr(line, "qemu") || strstr(line, "virtual")) {
            // replace hardware line with generic ARM
            if (strstr(line, "Hardware") || strstr(line, "model name")) {
                fputs("Hardware\t: Qualcomm Technologies, Inc SDM845\n", fake);
            }
            continue;
        }
        fputs(line, fake);
    }
    fclose(real);
    fclose(fake);
    return clean_cpuinfo_path.c_str();
}


// Log-once tracker for maps/cpuinfo redirects — prevents log spam from rapid-fire reads
static std::set<uintptr_t> logged_maps_callers;
static std::set<uintptr_t> logged_cpuinfo_callers;

int (*o_open)(const char* pathname, int flags, ...);
int hk_open(const char* pathname, int flags, ...) {
    if (pathname) {
        if (strstr(pathname, "maps") || strstr(pathname, "mounts")) {
               void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                const char* clean_path = get_clean_maps_path();
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_maps_callers.find(off) == logged_maps_callers.end()) {
                    logged_maps_callers.insert(off);
                    LOGI(HIDE_STR("[MAPS_BLOCK] Redirecting maps/mounts via open (caller: libanogs.so + 0x%lx)"), off);
                }
                pathname = clean_path;
            }
        }
        if (strstr(pathname, "/proc/cpuinfo")) {
            void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_cpuinfo_callers.find(off) == logged_cpuinfo_callers.end()) {
                    logged_cpuinfo_callers.insert(off);
                    LOGI(HIDE_STR("[CPUINFO] Redirecting via open (caller: libanogs.so + 0x%lx)"), off);
                }
                pathname = get_clean_cpuinfo_path();
            }
        }
        if (is_emu_path(pathname)) {
            errno = ENOENT;
            return -1;
        }
    }
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args; va_start(args, flags); mode = va_arg(args, mode_t); va_end(args);
    }
    return o_open(pathname, flags, mode);
}

int (*o_openat)(int dirfd, const char* pathname, int flags, ...);
int hk_openat(int dirfd, const char* pathname, int flags, ...) {
    if (pathname) {
        if (strstr(pathname, "maps") || strstr(pathname, "mounts")) {
            void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                const char* clean_path = get_clean_maps_path();
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_maps_callers.find(off) == logged_maps_callers.end()) {
                    logged_maps_callers.insert(off);
                    LOGI(HIDE_STR("[MAPS_BLOCK] Redirecting maps/mounts via openat (caller: libanogs.so + 0x%lx)"), off);
                }
                pathname = clean_path;
            }
        }
        if (strstr(pathname, "/proc/cpuinfo")) {
            void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_cpuinfo_callers.find(off) == logged_cpuinfo_callers.end()) {
                    logged_cpuinfo_callers.insert(off);
                    LOGI(HIDE_STR("[CPUINFO] Redirecting via openat (caller: libanogs.so + 0x%lx)"), off);
                }
                pathname = get_clean_cpuinfo_path();
            }
        }
        if (is_emu_path(pathname)) {
            errno = ENOENT;
            return -1;
        }
    }
    mode_t mode = 0;
    if (flags & O_CREAT) {
        va_list args; va_start(args, flags); mode = va_arg(args, mode_t); va_end(args);
    }
    return o_openat(dirfd, pathname, flags, mode);
}

FILE* (*o_fopen)(const char* filename, const char* mode);
FILE* hook_fopen(const char* filename, const char* mode) {
    if (filename) {
        if (strstr(filename, "maps") || strstr(filename, "mounts")) {
            void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                const char* clean_path = get_clean_maps_path();
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_maps_callers.find(off) == logged_maps_callers.end()) {
                    logged_maps_callers.insert(off);
                    LOGI(HIDE_STR("[MAPS_BLOCK] Redirecting maps/mounts via fopen (caller: libanogs.so + 0x%lx)"), off);
                }
                filename = clean_path;
            }
        }
        if (strstr(filename, "/proc/cpuinfo")) {
            void* reta = __builtin_extract_return_addr(__builtin_return_address(0));
#if defined(__arm__)
            reta = (void*)((uintptr_t)reta & ~1);
#endif
            if (is_from_anogs(reta)) {
                uintptr_t off = (uintptr_t)reta - libanogsheader;
                if (logged_cpuinfo_callers.find(off) == logged_cpuinfo_callers.end()) {
                    logged_cpuinfo_callers.insert(off);
                    LOGI(HIDE_STR("[CPUINFO] Redirecting via fopen (caller: libanogs.so + 0x%lx)"), off);
                }
                filename = get_clean_cpuinfo_path();
            }
        }
        if (is_emu_path(filename)) {
            errno = ENOENT;
            return NULL;
        }
    }
    return o_fopen(filename, mode);
}


int (*o_access)(const char* pathname, int mode);
int hk_access(const char* pathname, int mode) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_access(pathname, mode);
}


int (*o_stat)(const char* pathname, struct stat* statbuf);
int hk_stat(const char* pathname, struct stat* statbuf) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_stat(pathname, statbuf);
}

// 4. openat

// 5. faccessat
int (*o_faccessat)(int dirfd, const char* pathname, int mode, int flags);
int hk_faccessat(int dirfd, const char* pathname, int mode, int flags) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_faccessat(dirfd, pathname, mode, flags);
}

// 6. opendir
DIR* (*o_opendir)(const char* name);
DIR* hk_opendir(const char* name) {
    if (name && strstr(name, HIDE_STR("/dev"))) {
      //  LOGI(HIDE_STR("[SCAN] Process scanning /dev: %s"), name);
    }
    return o_opendir(name);
}

// 7. readdir
struct dirent* (*o_readdir)(DIR* dirp);
struct dirent* hk_readdir(DIR* dirp) {
    struct dirent* entry = o_readdir(dirp);
    while (entry != NULL && (strstr(entry->d_name, HIDE_STR("goldfish")) ||
            strstr(entry->d_name, HIDE_STR("virtpipe")) ||
            strstr(entry->d_name, HIDE_STR("awd")) ||
            strstr(entry->d_name, HIDE_STR("qemu")) ||
            strstr(entry->d_name, HIDE_STR("genyd")) ||
            strstr(entry->d_name, HIDE_STR("vbox86")) ||
            strstr(entry->d_name, HIDE_STR("nox")) ||
            strstr(entry->d_name, HIDE_STR("bluestacks")) ||
            strstr(entry->d_name, HIDE_STR("ldmnq")))) {
        entry = o_readdir(dirp);
    }
    return entry;
}

// 8. __open_2
int (*o_open_2)(const char* pathname, int flags);
int hk_open_2(const char* pathname, int flags) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_open_2(pathname, flags);
}

// 9. fstatat
int (*o_fstatat)(int dirfd, const char* pathname, struct stat* statbuf, int flags);
int hk_fstatat(int dirfd, const char* pathname, struct stat* statbuf, int flags) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_fstatat(dirfd, pathname, statbuf, flags);
}

// 10. __stat
int (*o__stat)(const char* pathname, struct stat* statbuf);
int hk__stat(const char* pathname, struct stat* statbuf) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o__stat(pathname, statbuf);
}


// system
int (*o_system)(const char* command);
int hk_system(const char* command) {
    if (command && (strstr(command, HIDE_STR("getprop")) || strstr(command, HIDE_STR("qemu")) || strstr(command, HIDE_STR("emulator")))) {
      //  LOGI(HIDE_STR("[BLOCKED] hk_system blocked command: %s"), command);
        return -1;
    }
    return o_system(command);
}

// readdir64
struct dirent64* (*o_readdir64)(DIR* dirp);
struct dirent64* hk_readdir64(DIR* dirp) {
    struct dirent64* entry = o_readdir64(dirp);
    while (entry != NULL && (strstr(entry->d_name, HIDE_STR("goldfish")) ||
                            strstr(entry->d_name, HIDE_STR("virtpipe")) ||
                            strstr(entry->d_name, HIDE_STR("awd")) ||
                            strstr(entry->d_name, HIDE_STR("qemu")) ||
                            strstr(entry->d_name, HIDE_STR("genyd")) ||
                            strstr(entry->d_name, HIDE_STR("vbox86")) ||
                            strstr(entry->d_name, HIDE_STR("nox")) ||
                            strstr(entry->d_name, HIDE_STR("bluestacks")) ||
                            strstr(entry->d_name, HIDE_STR("ldmnq")))) {
        entry = o_readdir64(dirp);
    }
    return entry;
}

// fdopendir
DIR* (*o_fdopendir)(int fd);
DIR* hk_fdopendir(int fd) {
    char path[1024];
    snprintf(path, sizeof(path), HIDE_STR("/proc/self/fd/%d"), fd);
    char target[1024];
    ssize_t len = readlink(path, target, sizeof(target)-1);
    if (len != -1) {
        target[len] = '\0';
        if (is_emu_path(target)) {
            return NULL;
        }
    }
    return o_fdopendir(fd);
}

// ioctl
int (*o_ioctl)(int fd, unsigned long request, void* arg);
int hk_ioctl(int fd, unsigned long request, void* arg) {
    char path[1024];
    snprintf(path, sizeof(path), HIDE_STR("/proc/self/fd/%d"), fd);
    char target[1024];
    ssize_t len = readlink(path, target, sizeof(target)-1);
    if (len != -1) {
        target[len] = '\0';
        if (is_emu_path(target)) {
            return -1;
        }
    }
    return o_ioctl(fd, request, arg);
}

// fcntl
int (*o_fcntl)(int fd, int cmd, void* arg);
int hk_fcntl(int fd, int cmd, void* arg) {
    char path[1024];
    snprintf(path, sizeof(path), HIDE_STR("/proc/self/fd/%d"), fd);
    char target[1024];
    ssize_t len = readlink(path, target, sizeof(target)-1);
    if (len != -1) {
        target[len] = '\0';
        if (is_emu_path(target)) {
            return -1;
        }
    }    
    return o_fcntl(fd, cmd, arg);
}

// lstat
int (*o_lstat)(const char* pathname, struct stat* statbuf);
int hk_lstat(const char* pathname, struct stat* statbuf) {
    if (pathname && is_emu_path(pathname)) {
        errno = ENOENT;
        return -1;
    }
    return o_lstat(pathname, statbuf);
}

// read/write/ioctl for virtpipe specifically
ssize_t (*o_read)(int fd, void* buf, size_t count);
ssize_t hk_read_virtpipe(int fd, void* buf, size_t count) {
    char path[1024];
    snprintf(path, sizeof(path), HIDE_STR("/proc/self/fd/%d"), fd);
    char target[1024];
    ssize_t len = readlink(path, target, sizeof(target) - 1);
    if (len != -1) {
        target[len] = '\0';
        if (is_emu_path(target)) {
            return -1;
        }
    }
    return o_read(fd, buf, count);
}

ssize_t (*o_write)(int fd, const void* buf, size_t count);
ssize_t hk_write_virtpipe(int fd, const void* buf, size_t count) {
    char path[1024];
    snprintf(path, sizeof(path), HIDE_STR("/proc/self/fd/%d"), fd);
    char target[1024];
    ssize_t len = readlink(path, target, sizeof(target)-1);
    if (len != -1) {
        target[len] = '\0';
        if (is_emu_path(target)) {
            return -1;
        }
    }
    return o_write(fd, buf, count);
}


int (*o___system_property_get)(const char* name, char* value);
int hk___system_property_get(const char* name, char* value) {
    int ret = o___system_property_get(name, value);
    if (name && ret > 0 && value) {
        // Block init.svc.vbox86-setup (AndroidEmulatorEx fingerprint)
        if (strstr(name, "vbox86") || strstr(name, "vbox64") ||
            strstr(name, "nox") || strstr(name, "genymotion") ||
            strstr(name, "androVM") || strstr(name, "goldfish") ||
            strstr(name, "qemu") || strstr(name, "microvirt") ||
            strstr(name, "ttVM") || strstr(name, "bluestacks")) {
            value[0] = '\0';
            return 0;
        }
        // Spoof known emulator hardware/product/model props
        if (strcmp(name, "ro.hardware") == 0 &&
            (strstr(value, "goldfish") || strstr(value, "ranchu") || strstr(value, "vbox86") || strstr(value, "nox"))) {
            strcpy(value, "qcom");
            return strlen(value);
        }
        if (strcmp(name, "ro.product.model") == 0 &&
            (strstr(value, "sdk") || strstr(value, "Emulator") || strstr(value, "Android SDK"))) {
            strcpy(value, "SM-G965F");
            return strlen(value);
        }
        if (strcmp(name, "ro.product.brand") == 0 &&
            (strstr(value, "generic") || strstr(value, "Android"))) {
            strcpy(value, "samsung");
            return strlen(value);
        }
        if (strcmp(name, "ro.product.manufacturer") == 0 &&
            (strstr(value, "Genymotion") || strstr(value, "unknown") || strstr(value, "GenymotionVbox86") || strstr(value, "nox"))) {
            strcpy(value, "samsung");
            return strlen(value);
        }
        if (strcmp(name, "ro.product.device") == 0 &&
            (strstr(value, "generic") || strstr(value, "vbox86") || strstr(value, "nox"))) {
            strcpy(value, "star2lte");
            return strlen(value);
        }
        if (strcmp(name, "ro.product.board") == 0 &&
            (strstr(value, "goldfish") || strstr(value, "unknown"))) {
            strcpy(value, "sdm845");
            return strlen(value);
        }
    }
    return ret;
}

void apply_all_libc_hooks() {
   HOOKSYM_LIB("/system/lib/libc.so", "open", hk_open, o_open);
   HOOKSYM_LIB("/system/lib/libc.so", "access", hk_access, o_access);
   HOOKSYM_LIB("/system/lib/libc.so", "stat", hk_stat, o_stat);
   HOOKSYM_LIB("/system/lib/libc.so", "openat", hk_openat, o_openat);
   HOOKSYM_LIB("/system/lib/libc.so", "faccessat", hk_faccessat, o_faccessat);
   HOOKSYM_LIB("/system/lib/libc.so", "opendir", hk_opendir, o_opendir);
   HOOKSYM_LIB("/system/lib/libc.so", "readdir", hk_readdir, o_readdir);
   HOOKSYM_LIB("/system/lib/libc.so", "__open_2", hk_open_2, o_open_2);
   HOOKSYM_LIB("/system/lib/libc.so", "fstatat", hk_fstatat, o_fstatat);
   HOOKSYM_LIB("/system/lib/libc.so", "__stat", hk__stat, o__stat);
   HOOKSYM_LIB("/system/lib/libc.so", "ioctl", hk_ioctl, o_ioctl);
   HOOKSYM_LIB("/system/lib/libc.so", "fopen", hook_fopen, o_fopen);
   HOOKSYM_LIB("/system/lib/libc.so", "read", hk_read_virtpipe, o_read);
   HOOKSYM_LIB("/system/lib/libc.so", "write", hk_write_virtpipe, o_write);
   HOOKSYM_LIB("/system/lib/libc.so", "system", hk_system, o_system);
   HOOKSYM_LIB("/system/lib/libc.so", "__system_property_get", hk___system_property_get, o___system_property_get);
   HOOKSYM_LIB("/system/lib/libc.so", "lstat", hk_lstat, o_lstat);
   HOOKSYM_LIB("/system/lib/libc.so", "readdir64", hk_readdir64, o_readdir64);
   HOOKSYM_LIB("/system/lib/libc.so", "fdopendir", hk_fdopendir, o_fdopendir);
   HOOKSYM_LIB("/system/lib/libc.so", "fcntl", hk_fcntl, o_fcntl);
}




// linux_eabi_syscall instead, skipping our libc hooks. sub_36F004
// Bit 0=open, 1=read, 2=write, 3=lseek, 4=access, 5=stat, 6=fstat,
// 7=gettimeofday, 8=clock_gettime, 9-11=nanosleep/sleep/usleep,
// 12=connect, 13=sendto, 14=recvfrom, 15=getpid, 16=kill,
// 17=ptrace, 18=readlink, 19=close, 21=prctl
uintptr_t OFF_SYSCALL_FLAG = 0x3F071C; // dword_3F071C

void *syscall_flag_thread(void *)
{
    while (!check)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    while (!libanogsheader)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    constexpr uint32_t SYSCALL_FILE_BITS = 0x00040033; // bits 0,1,4,5,18
    static bool logged = false;

    volatile uint32_t *sc_flag = (volatile uint32_t *)(libanogsheader + OFF_SYSCALL_FLAG);
    LOGI(HIDE_STR(GREEN "[SYSCALL] Thread started, flag addr=%p, initial value=0x%X" RESET),
         (void *)sc_flag, *sc_flag);

    while (true)
    {
        volatile uint32_t *sc_flag = (volatile uint32_t *)(libanogsheader + OFF_SYSCALL_FLAG);
        uint32_t val = *sc_flag;
        if (val & SYSCALL_FILE_BITS)
        {
            *sc_flag = val & ~SYSCALL_FILE_BITS;
            if (!logged)
            {
                LOGI(HIDE_STR(GREEN "[SYSCALL] Cleared file bypass bits: 0x%X -> 0x%X" RESET),
                     val, val & ~SYSCALL_FILE_BITS);
                logged = true;
            }
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
    return nullptr;
}

void *emu_thread(void *)
{
    while (!check)
    {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

 //   LOGI(HIDE_STR(" AntiEmulator initialization..."));

    AntiEmulator = *(uintptr_t *)(libanogsheader + 0x3E7DB8);

    while (!AntiEmulator)
    {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        AntiEmulator = *(uintptr_t *)(libanogsheader + 0x3E7DB8);
    }

  //  LOGI(HIDE_STR("AntiEmulator at: %p"), AntiEmulator);

    static bool logged_bypass = false;
    static bool logged_branch = false;

    while (true)
    {
        if (!AntiEmulator)
        {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            continue;
        }

        if (*(uint32_t *)(AntiEmulator + 64) != 0)
        {
            if (!logged_bypass)
            {
                logged_bypass = true;
            }
            *(uint32_t *)(AntiEmulator + 64) = 0;
        }

        if (*(uint16_t *)(AntiEmulator + 68) != 1)
        {
            if (!logged_branch)
            {
                logged_branch = true;
            }
            *(uint16_t *)(AntiEmulator + 68) = 1;
        }


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


bool is_from_anogs(void* ret)
{
    uintptr_t addr = (uintptr_t)ret;
    return addr >= libanogsheader && addr < (libanogsheader + Modules::Anogs.Size);
}

static __thread int in_hook = 0;
size_t (*old_strlen)(const char* s);
size_t hk_strlen(char* s)
{
    void* reta = __builtin_extract_return_addr(__builtin_return_address(0));

#if defined(__arm__)
    reta = (void*)((uintptr_t)reta & ~1);
#endif

    if (!s || in_hook || !is_from_anogs(reta))
        return old_strlen(s);
 
    in_hook = 1;
    // LOGI("strlen -> %s ",s);
    if (strstr(s, "/dev/awd"))
    {
        WriteMemory(s, (void*)"/dev/GG", 8, true);
    }

    if (
        strstr(s, HIDE_STR("/share1/")) ||
        strstr(s, HIDE_STR("/dev/wanbai")) ||
        strstr(s, HIDE_STR("/dev/kgsl-3d0")) ||
        strstr(s, HIDE_STR("libhoudini")) ||
        strstr(s, HIDE_STR("libhotx711.so")) ||
        strstr(s, HIDE_STR("libhotx612.so")) ||
        strstr(s, HIDE_STR("libKaopuSdk.so")) ||
        strstr(s, HIDE_STR("libc_malloc_debug_qemu")) ||
        strstr(s, HIDE_STR("libldutils.so")) ||
        strstr(s, HIDE_STR("libdroidbox-ril.so")) ||
        strstr(s, HIDE_STR("libnoxd.so")) ||
        strstr(s, HIDE_STR("init.vbox86")) ||
        strstr(s, HIDE_STR("init.vbox64")) ||
        strstr(s, HIDE_STR("fstab.vbox86")) ||
        strstr(s, HIDE_STR("fstab.vbox64")) ||
        strstr(s, HIDE_STR("init.pscloud")) ||
        strstr(s, HIDE_STR("init.dundi")) ||
        strstr(s, HIDE_STR("init.androidVM_x86")) ||
        strstr(s, HIDE_STR("init.android_x86")) ||
        strstr(s, HIDE_STR("androVM-prop")) ||
        strstr(s, HIDE_STR("genyd")) ||
        strstr(s, HIDE_STR("virtpipe-sec"))
        )
    {
      //  LOGI(HIDE_STR("[BLOCKED] Strlen emulator path found: %s"), s);

        WriteMemory(s, (void*)"lotm", 5, true); 
    }

    size_t ret = old_strlen(s);

    in_hook = 0;
    return ret;
} 

void *strlen_thread(void *)
{
    while (!isLibraryLoaded_local("libc.so"))
        sleep(1);

    void *strlen_addr = dlsym(RTLD_DEFAULT, "strlen");
    if (strlen_addr)
    {
        hook(strlen_addr, (void*)hk_strlen, (void**)&old_strlen);
    //    LOGI(OBFUSCATE("[strlen_thread] strlen hook installed @ %p"), strlen_addr);
    }
    else
    {
     //   LOGI(OBFUSCATE("[strlen_thread] strlen not found via RTLD_DEFAULT!"));
    }

    return NULL;
}




int __fastcall (*orig_DisableFPS_Limits)(int a1, float a2, int a3);
int __fastcall hook_DisableFPS_Limits(int a1, float a2, int a3)
{
    int original_val = orig_DisableFPS_Limits(a1, a2, a3);
    float fps;
    memcpy(&fps, &original_val, 4);
    

    if (fps == 120.0f || fps == 90.0f || fps == 64.0f) {
        fps = 240.0f;
    }
    
    int ret;
    memcpy(&ret, &fps, 4);
    return ret;
}


int __fastcall (*o_120FPS)(int a1, int a2);
int __fastcall hook_120FPS(int a1, int a2)
{

    return 165;
}

int __fastcall (*o_UHD)(int a1);
int __fastcall hook_UHD(int a1)
{

    return 6;
}

int targetfps = 240 ;
size_t strlen_h_ue4(char* s)
{
    if (strstr(s,HIDE_STR("Ultra Extreme")))
    {
       // LOGI(HIDE_STR("[BLOCKED] Strlen -> %s"), s);
        char fps[50];
        if (targetfps == (int)targetfps) 
        {
            snprintf(fps, sizeof(fps), HIDE_STR("%d FPS"), (int)targetfps);
        }
        else 
        {
            snprintf(fps, sizeof(fps), HIDE_STR("%.1f FPS"), (float)targetfps);
        }
        WriteMemory(s, fps, strlen(fps) + 1, true);
    }

    return strlen(s);
}


int __fastcall (*sub_468D0A8)(int a1, int a2, _DWORD *a3);
int __fastcall hook_sub_468D0A8(int a1, int a2, _DWORD *a3)
 {  
 return 0;
 }
  
int __fastcall (*sub_468C488)(int a1, _DWORD *a2, int a3);
int __fastcall hook_sub_468C488(int a1, _DWORD *a2, int a3)
{   
 return 0;
}

int (*orig_ReportAntiCheatInfo)(int a1);
int hook_ReportAntiCheatInfo(int a1) {
    LOGI(HIDE_STR("[AC] ReportAntiCheatInfo swallowed | state=%d"), *(unsigned char *)(a1 + 352));
    return *(unsigned char *)(a1 + 352);
}

int (*orig_DisableEmuDetection)(_DWORD *a1, unsigned int a2);
int DisableEmuDetection(_DWORD *a1, unsigned int a2)
{
    return 0; 
}

int __fastcall (*sub_46E2044)(int a1, int *a2);
int __fastcall hook_sub_46E2044(int a1, int *a2)
{
       if ((*(_DWORD*)a1 + 0x2E8))
      {
     //   LOGI(HIDE_STR("[SHIELD] Corona Trigger suppressed"));
         return 0;
      }
    return sub_46E2044(a1, a2);
}
int __fastcall (*PlayerKillFlow)(int a1, int *a2);
int __fastcall hook_PlayerKillFlow(int a1, int *a2)
{
  
    uint32_t KillFlow = (*(_DWORD *)a1 + 2252);
    if(KillFlow)
    {
       // LOGI(HIDE_STR("[SHIELD] PlayerKillFlow %p"), (void*)(KillFlow - libUE4header));
        return 0;
    }

    return PlayerKillFlow(a1, a2);
}



typedef int (*login_opt_t)(int a1, int a2);
login_opt_t ologin_opt;
int hlogin_opt(int a1, int a2)
{
    int result;
    result = ologin_opt(a1, a2);
    if (result == 40)
    {
        return 5;
    }
    return result;
}




OLLVM_PROTECT("bcf igv ibr icall sub split")

void *main_thread(void *)
{
       sleep(3);

     GlossInit(false);

  

     apply_all_libc_hooks();
     LOGI(HIDE_STR(GREEN"This library is belongs to Inverness" RESET));
     while (!isLibraryLoaded_local(HIDE_STR("libanogs.so")))
        sleep(1);
      LOGI(HIDE_STR("libanogs.so loaded"));

    libanogsheader = getLibraryBaseAddress(HIDE_STR("libanogs.so"));
    if (!libanogsheader)
    {
         LOGI(HIDE_STR("Failed to resolve libanogs.so base address"));
         return nullptr;
     }
    
   // InitAnogsHooks(libanogsheader);


  //  HookGOT(libanogsheader, 0x3B462C, hk_anogs_strlen, &orig_anogs_strlen);
    // PATCH_DATA(libanogsheader, 0x3BED00, return_0);
    // PATCH_DATA(libanogsheader, 0x3BEE1C, return_0);
   

    Modules::Anogs.BaseAddr = libanogsheader;
    Modules::Anogs.Size = getLibrarySize(HIDE_STR("libanogs.so"));
    Modules::Anogs.TextSize = getLibraryTextSize(Modules::Anogs.BaseAddr);


    Modules::Anogs.AllocAddr = (uintptr_t)malloc(Modules::Anogs.Size);
    if (!Modules::Anogs.AllocAddr)
    {
        LOGE(HIDE_STR("Failed to allocate Anogs backup memory"));
        return nullptr;
    }
    Modules::Anogs.AllocText = (uintptr_t)malloc(Modules::Anogs.TextSize);
    if (!Modules::Anogs.AllocText)
    {
        LOGE(HIDE_STR("Failed to allocate Anogs Text backup memory"));
        return nullptr;
    }
    memcpy((void *)Modules::Anogs.AllocAddr, (void *)Modules::Anogs.BaseAddr, Modules::Anogs.Size);
    memcpy((void *)Modules::Anogs.AllocText, (void *)Modules::Anogs.BaseAddr, Modules::Anogs.TextSize);
    std::string pkgName = GetPackageName();
 
    
    check = true;
    pthread_t ptid_emu;
    pthread_create(&ptid_emu, NULL, emu_thread, NULL);
    pthread_detach(ptid_emu);

    pthread_t ptid_sc;
    pthread_create(&ptid_sc, NULL, syscall_flag_thread, NULL);
    pthread_detach(ptid_sc);
    
  
  




    while (!isLibraryLoaded_local(HIDE_STR("libUE4.so")))
        sleep(1);
    LOGI(HIDE_STR("libUE4.so loaded"));
    
    libUE4header = getLibraryBaseAddress(HIDE_STR("libUE4.so"));
    if (!libUE4header)
    {
        LOGI(HIDE_STR("Base not found"));
        return nullptr;
    }
    Modules::UE4.BaseAddr = libUE4header;
    Modules::UE4.Size = getLibrarySize(HIDE_STR("libUE4.so"));
    Modules::UE4.AllocAddr = (uintptr_t)malloc(Modules::UE4.Size);
    Modules::UE4.TextSize = getLibraryTextSize(Modules::UE4.BaseAddr);
    if (!Modules::UE4.AllocAddr)
    {
        LOGE(HIDE_STR("Failed to allocate UE4 backup memory"));
        return nullptr;
    }
    Modules::UE4.AllocText = (uintptr_t)malloc(Modules::UE4.TextSize);
    if (!Modules::UE4.AllocText)
    {
        LOGE(HIDE_STR("Failed to allocate ue4 Text backup memory"));
        return nullptr;
    }

     memcpy((void *)Modules::UE4.AllocText, (void *)Modules::UE4.BaseAddr, Modules::UE4.TextSize);
     memcpy((void *)Modules::UE4.AllocAddr, (void *)Modules::UE4.BaseAddr, Modules::UE4.Size);
   


   


   



LOGI(HIDE_STR("package name %s "), pkgName.c_str());

if (pkgName == HIDE_STR("com.pubg.imobile")) {
    GlossHook((void*)(libUE4header + 0x7ACA154),(void*)hk_luaL_loadbufferx,(void**)&orig_luaL_loadbufferx);
    GlossHook((void*)(libUE4header + 0x7AA36D4 ),(void*)hk_lua_pcallx,(void**)&orig_lua_pcallx);
    // F0 4D 2D E9 ? ? ? E2 04 8B 2D ED ? ? ? E2 ? ? ? ED 01 40 A0 E1  remove 120 fps limit  sub_6E55B04
  
    GlossHook((void*)(libUE4header + 0x8F5A7D0 ),(void*)strlen_h_ue4, NULL); 
    GlossPatchOffset(libUE4header, 0x4468428, HIDE_STR("00 00 A0 E3 1E FF 2F E1")); //RemapMemMap 4.5
    GlossPatchOffset(libUE4header, 0x420935C, HIDE_STR("00 00 A0 E3 1E FF 2F E1")); //gameloop crashfix
    GlossHook((void*)(libUE4header + 0x4853450), (void *)hook_sub_468D0A8, (void **)&sub_468D0A8);//fake damage1 4.5
    GlossHook((void*)(libUE4header + 0x48528E8), (void *)hook_sub_468C488, (void **)&sub_468C488);//fake damage2 4.5
    GlossHook((void*)(libUE4header + 0x336EC94 ),(void*)hook_120FPS,(void**)&o_120FPS);//GetDeviceMaxFPSByDeviceLevel
    GlossHook((void*)(libUE4header + 0x336E888 ),(void*)hook_UHD, NULL); //GetDeviceMaxSupportLevel
 // HOOK_LIB("libUE4.so", "0x44F5584", hlogin_opt, ologin_opt);

    GlossHook((void*)(libUE4header + 0x304E8B4), (void*)hook_ReportAntiCheatInfo, (void**)&orig_ReportAntiCheatInfo);
    LOGI(HIDE_STR(GREEN "[AC] ReportAntiCheatInfo hooked at 0x304E8B4" RESET));

    InitGraphicsHooks(libUE4header);
    
    uintptr_t MessageBoxAddr = findPattern(Modules::UE4.BaseAddr, Modules::UE4.Size, SIG_MESSAGEBOX);
    if (MessageBoxAddr) {
        InitMessageBox(MessageBoxAddr);
      
    } else {
        LOGE(HIDE_STR("MessageBox signature not found!"));
    }
}




  






   //----------------------------------------------------------------------------------
 // LOGI(HIDE_STR("Scanning UE4 for DisableEmuDetection signature Range: 0x%lx - 0x%lx"), Modules::UE4.BaseAddr, Modules::UE4.BaseAddr + Modules::UE4.Size);
  uintptr_t si_DisableEmuDetection = findPattern(Modules::UE4.BaseAddr, Modules::UE4.Size, SIG_DISABLEEMUDETECTION);
   if(si_DisableEmuDetection)
   {
   //  LOGI(HIDE_STR("Emu sig: 0x%lx (Offset: 0x%lx)"), si_DisableEmuDetection, si_DisableEmuDetection - Modules::UE4.BaseAddr);
   //  GlossHook((void*)si_DisableEmuDetection, (void*)DisableEmuDetection, (void**)&orig_DisableEmuDetection);
   }
    else
   {
      LOGI(HIDE_STR("DisableEmuDetection signature NOT found"));
   }

    uintptr_t DisableFPS_Limits_addr = findPattern(Modules::UE4.BaseAddr, Modules::UE4.Size, SIG_DISABLEFPSLIMITS);
    if (DisableFPS_Limits_addr) {
      //  LOGI(HIDE_STR("DisableFPS_Limits_addr found at 0x%lx"), DisableFPS_Limits_addr - Modules::UE4.BaseAddr );
       GlossHook((void*)DisableFPS_Limits_addr, (void*)hook_DisableFPS_Limits, (void**)&orig_DisableFPS_Limits);
    } else {
         LOGE(HIDE_STR("DisableFPS_Limits_addr not found"));
        GlossHook((void*)(libUE4header + 0x71C7E0C),(void*)hook_DisableFPS_Limits,(void**)&orig_DisableFPS_Limits);
    
    }


 //    ShowMessageBox("Inverness", "You are using Inverness Free version\nVIP Features :\n1. 240 FPS with UHD Graphic\n2.Upto 4K resolution\n3.Inverness Hax\n4.Mod Skins");

  //  strlen_thread(NULL);
    return NULL;
}

static void self_delete()
{
    Dl_info info;
    if (dladdr((void*)&self_delete, &info) && info.dli_fname)
    {
        unlink(info.dli_fname);
    }
}



__attribute__((constructor)) void lib_main() 

{

    LOGI(HIDE_STR("Library Loaded"));
    pthread_t ptid;
    pthread_create(&ptid, NULL, main_thread, NULL);
    pthread_detach(ptid);



}
/*
 * CONFUSION LAYER - SIMPLE DROP-IN VERSION
 *
 * Usage:
 *   1. #include "confusion.h" at top of each .cpp file
 *   2. Use HIDE_STR("text") for encrypted strings
 *   3. Use HIDE_CALL(func, args...) for indirect calls
 *   4. Use PROTECTED_FUNC before sensitive functions
 *   5. Done. Confusion is automatic.
 */

#ifndef CONFUSION_H
#define CONFUSION_H

#include <atomic>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <utility>
#include <pthread.h>

// Forward declarations for external security functions used in decoys
#include <dlfcn.h>
#include <pthread.h>

// Dynamic resolution wrappers for GlossHook to avoid header conflicts
namespace _cf_hd {
typedef void *(*GlossHookAddr_t)(void *, void *, void **, bool, int);
typedef void (*GlossPatchOffset_t)(uintptr_t, uintptr_t, const char *);

inline void *HookAddr(void *a, void *b, void **c, bool d, int e) {
  static auto f = (GlossHookAddr_t)dlsym(RTLD_DEFAULT, "GlossHookAddr");
  return f ? f(a, b, c, d, e) : nullptr;
}
inline void PatchOffset(uintptr_t a, uintptr_t b, const char *c) {
  static auto f = (GlossPatchOffset_t)dlsym(RTLD_DEFAULT, "GlossPatchOffset");
  if (f)
    f(a, b, c);
}
} // namespace _cf_hd

// ============================================================================
// INTERNAL: DO NOT USE DIRECTLY
// ============================================================================

#define _CF_PASTE(a, b) a##b
#define _CF_PASTE2(a, b) _CF_PASTE(a, b)
#define _CF_UNIQUE(x) _CF_PASTE2(x, __COUNTER__)
#define _CF_UNIQUE_LINE(x) _CF_PASTE2(x, __LINE__)

// TU-specific seed - different for each file
namespace _cf_internal {

constexpr uint32_t _hash(const char *s, uint32_t h = 2166136261u) {
  return *s ? _hash(s + 1, (h ^ *s) * 16777619u) : h;
}

constexpr uint64_t _hash64(const char *s,
                           uint64_t h = 14695981039346656037ull) {
  return *s ? _hash64(s + 1, (h ^ *s) * 1099511628211ull) : h;
}

} // namespace _cf_internal

#define _CF_SEED (_cf_internal::_hash(__FILE__) ^ (__LINE__ * 2654435761u))
#define _CF_SEED_STABLE (_cf_internal::_hash(__FILE__))

// ============================================================================
// AUTOMATIC INIT FRAGMENTATION
// Just including this header adds decoy inits to pollute .init_array
// ============================================================================

namespace _cf_auto {

// Slot table for indirect calls
inline std::atomic<void *> _slots[64] = {};
inline volatile uintptr_t _anchors[16] = {};

// Opaque predicates
__attribute__((noinline)) inline bool _true() {
  volatile uint32_t x = 0x12345678;
  volatile uint32_t y = 0x87654321;
  return ((x ^ y) != (x & y)) || (x > 0);
}

__attribute__((noinline)) inline bool _false() {
  volatile int x = 7, y = 13;
  return (x * x == y * y) && (x != y);
}

} // namespace _cf_auto

// Auto-register decoy constructors per-TU
#define _CF_AUTO_DECOY(n)                                                      \
  namespace {                                                                  \
  __attribute__((constructor(101 + (_CF_SEED_STABLE % 800) + n), used)) void   \
  _CF_UNIQUE(_cf_decoy_)() {                                                   \
    volatile auto x = __COUNTER__;                                             \
    _cf_auto::_anchors[(_CF_SEED_STABLE + n) % 16] ^= x;                       \
  }                                                                            \
  }

// These run automatically when header is included
_CF_AUTO_DECOY(0)
_CF_AUTO_DECOY(1)
_CF_AUTO_DECOY(2)

// ============================================================================
// HIDE_STR("text") - Compile-time encrypted strings
// ============================================================================

namespace _cf_str {

template <size_t N, uint32_t Seed, int Counter> class _Enc {
  char d_[N];

public:
  template <size_t... I>
  constexpr _Enc(const char *s, std::index_sequence<I...>)
      : d_{static_cast<char>(s[I] ^ ((Seed ^ (I * 31337)) & 0xFF))...} {}

  __attribute__((noinline)) const char *get() const {
    static char buf[N];
    for (size_t i = 0; i < N; ++i)
      buf[i] = d_[i] ^ ((Seed ^ (i * 31337)) & 0xFF);
    return buf;
  }

  __attribute__((noinline)) const char *decrypt(char *buf) const {
    for (size_t i = 0; i < N; ++i)
      buf[i] = d_[i] ^ ((Seed ^ (i * 31337)) & 0xFF);
    return buf;
  }
};

} // namespace _cf_str

#define HIDE_STR(s)                                                            \
  ([]() -> const char * {                                                      \
    constexpr size_t _n = sizeof(s);                                           \
    static constexpr _cf_str::_Enc<_n, _CF_SEED_STABLE, __COUNTER__> _e(       \
        s, std::make_index_sequence<_n>{});                                    \
    return _e.get();                                                           \
  }())

// Helper for multi-language UI hardening
#define HIDE_LABEL(en, vi, zh)                                                 \
  GetLabel(HIDE_STR(en), HIDE_STR(vi), HIDE_STR(zh))

// Variant with explicit buffer (faster, no TLS)
#define HIDE_STR_BUF(s, buf)                                                   \
  ([]() -> const char * {                                                      \
    constexpr size_t _n = sizeof(s);                                           \
    static constexpr _cf_str::_Enc<_n, _CF_SEED_STABLE, __COUNTER__> _e(       \
        s, std::make_index_sequence<_n>{});                                    \
    return _e.decrypt(buf);                                                    \
  }())

// ============================================================================
// HIDE_CALL(func, args...) - Indirect function calls
// ============================================================================

namespace _cf_call {

template <typename F> struct _Indirect {
  F *fn;
  uintptr_t key;

  __attribute__((always_inline)) _Indirect(F *f, uintptr_t k)
      : fn(reinterpret_cast<F *>(reinterpret_cast<uintptr_t>(f) ^ k)), key(k) {}

  template <typename... Args>
  __attribute__((noinline)) auto operator()(Args &&...args) const {
    auto real = reinterpret_cast<F *>(reinterpret_cast<uintptr_t>(fn) ^ key);
    if (_cf_auto::_true())
      return real(static_cast<Args &&>(args)...);
    return real(static_cast<Args &&>(args)...);
  }
};

template <typename F> _Indirect<F> _make(F *f, uintptr_t key) {
  return {f, key};
}

} // namespace _cf_call

#define HIDE_CALL(func, ...) (_cf_call::_make(&func, _CF_SEED)(__VA_ARGS__))

// For function pointers
#define HIDE_FPTR_CALL(fptr, ...) (_cf_call::_make(fptr, _CF_SEED)(__VA_ARGS__))

// ============================================================================
// PROTECTED_FUNC - Add to sensitive functions
// ============================================================================

// Opaque check that always passes but confuses analysis
#define _CF_OPAQUE_CHECK                                                       \
  if (_cf_auto::_false()) {                                                    \
    volatile int *_p = nullptr;                                                \
    *_p = 0;                                                                   \
  }

// Variant code blocks per TU
#define _CF_VARIANT(a, b)                                                      \
  if constexpr ((_CF_SEED_STABLE % 2) == 0) {                                  \
    a;                                                                         \
  } else {                                                                     \
    b;                                                                         \
  }

// Add at start of sensitive functions
#define PROTECTED_FUNC                                                         \
  _CF_OPAQUE_CHECK                                                             \
  _CF_VARIANT(                                                                 \
      {                                                                        \
        volatile int _x = _CF_SEED;                                            \
        (void)_x;                                                              \
      },                                                                       \
      {                                                                        \
        volatile char _x[3];                                                   \
        _x[0] = 1;                                                             \
        _x[1] = 2;                                                             \
        _x[2] = 3;                                                             \
        (void)_x;                                                              \
      })

// For void functions
#define PROTECTED_VOID_FUNC PROTECTED_FUNC

// ============================================================================
// HIDE_VALUE(val) - Runtime value obfuscation
// ============================================================================

template <typename T> __attribute__((noinline)) T HIDE_VALUE(T val) {
  volatile T tmp = val;
  if (_cf_auto::_false())
    return T{};
  return tmp;
}

// ============================================================================
// HIDE_PTR(ptr) / REVEAL_PTR(hidden) - Pointer hiding
// ============================================================================

namespace _cf_ptr {

inline uintptr_t _key() {
  static volatile uintptr_t k = 0;
  if (!k)
    k = reinterpret_cast<uintptr_t>(&k) ^ (uintptr_t)0xDEADBEEFCAFEBABEull;
  return k;
}

struct Hidden {
  uintptr_t enc;

  template <typename T>
  Hidden(T *p) : enc(reinterpret_cast<uintptr_t>(p) ^ _key()) {}

  template <typename T> T *get() const {
    return reinterpret_cast<T *>(enc ^ _key());
  }
};

} // namespace _cf_ptr

#define HIDE_PTR(ptr) _cf_ptr::Hidden(ptr)
#define REVEAL_PTR(hidden, type) (hidden).get<type>()

// ============================================================================
// FAKE_BRANCH - Always runs real code, but has fake alternative
// ============================================================================

#define FAKE_BRANCH(real_code, fake_code)                                      \
  do {                                                                         \
    if (_cf_auto::_true()) {                                                   \
      real_code;                                                               \
    } else {                                                                   \
      fake_code;                                                               \
    }                                                                          \
  } while (0)

// ============================================================================
// DEAD_CODE - Never runs but gets compiled
// ============================================================================

#define DEAD_CODE(code)                                                        \
  if (_cf_auto::_false()) {                                                    \
    code;                                                                      \
  }

// ============================================================================
// CONFUSION_SLOT_REGISTER / CONFUSION_SLOT_CALL
// Register functions in global table, call indirectly
// ============================================================================

#define SLOT_INDEX(id) (((id) + _CF_SEED_STABLE) % 64)

#define REGISTER_HIDDEN_FUNC(id, func)                                         \
  namespace {                                                                  \
  __attribute__((constructor(150 + (_CF_SEED_STABLE % 700)), used)) void       \
  _CF_UNIQUE(_cf_reg_)() {                                                     \
    _cf_auto::_slots[SLOT_INDEX(id)].store(reinterpret_cast<void *>(&func),    \
                                           std::memory_order_release);         \
  }                                                                            \
  }

#define CALL_HIDDEN_FUNC(id, ret_type, ...)                                    \
  reinterpret_cast<ret_type (*)(__VA_ARGS__)>(                                 \
      _cf_auto::_slots[SLOT_INDEX(id)].load(std::memory_order_acquire))

// ============================================================================
// TRAMPOLINE(func, args...) - Call through bounce chain
// ============================================================================

namespace _cf_tramp {

template <int D> struct _Chain {
  template <typename R, typename... A>
  __attribute__((noinline)) static R call(R (*f)(A...), A... a) {
    volatile int x = D;
    (void)x;
    if (_cf_auto::_false())
      return R{};
    return _Chain<D - 1>::call(f, a...);
  }
};

template <> struct _Chain<0> {
  template <typename R, typename... A>
  __attribute__((noinline)) static R call(R (*f)(A...), A... a) {
    return f(a...);
  }
};

// Void specialization
template <int D> struct _ChainV {
  template <typename... A>
  __attribute__((noinline)) static void call(void (*f)(A...), A... a) {
    volatile int x = D;
    (void)x;
    if (_cf_auto::_false())
      return;
    _ChainV<D - 1>::call(f, a...);
  }
};

template <> struct _ChainV<0> {
  template <typename... A>
  __attribute__((noinline)) static void call(void (*f)(A...), A... a) {
    f(a...);
  }
};

} // namespace _cf_tramp

#define _CF_TRAMP_DEPTH ((_CF_SEED_STABLE % 3) + 1)

#define TRAMPOLINE(func, ...)                                                  \
  _cf_tramp::_Chain<_CF_TRAMP_DEPTH>::call(&func, ##__VA_ARGS__)

#define TRAMPOLINE_VOID(func, ...)                                             \
  _cf_tramp::_ChainV<_CF_TRAMP_DEPTH>::call(&func, ##__VA_ARGS__)

// ============================================================================
// ANTI-DEBUG HELPERS (Optional)
// ============================================================================

#include <cstdio>
#include <cstdlib>
#include <sys/ptrace.h>

namespace _cf_anti {

__attribute__((noinline)) inline bool debugger_check() {
  // 1. TracerPid Check
  int pid = 0;
  FILE *fp = fopen("/proc/self/status", "r");
  if (fp) {
    char line[128];
    while (fgets(line, sizeof(line), fp)) {
      if (strncmp(line, "TracerPid:", 10) == 0) {
        pid = atoi(&line[10]);
        break;
      }
    }
    fclose(fp);
  }
  if (pid != 0)
    return true;

  // 2. ptrace Check
  if (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1) {
    return true;
  }
  return false;
}

__attribute__((noinline, noreturn)) inline void die() {
  volatile uintptr_t x = reinterpret_cast<uintptr_t>(&die);
  x ^= (x << 9);
  x ^= (x >> 3);
  x = (x & 0xFFFFFFFFFFFFF000ULL) | 0xABC;
  ((void (*)())x)();
  __builtin_unreachable();
}

} // namespace _cf_anti

#define ANTI_DEBUG_CHECK()                                                     \
  if (_cf_anti::debugger_check() && _cf_auto::_true()) {                       \
    _cf_anti::die();                                                           \
  }

#define CRASH_IF_FALSE(cond)                                                   \
  if (!(cond) && _cf_auto::_true()) {                                          \
    _cf_anti::die();                                                           \
  }

// ============================================================================
// EXTRA POLLUTION (call once per file if you want more noise)
// ============================================================================

#define ADD_MORE_CONFUSION()                                                   \
  _CF_AUTO_DECOY(3)                                                            \
  _CF_AUTO_DECOY(4)                                                            \
  _CF_AUTO_DECOY(5)                                                            \
  namespace {                                                                  \
  __attribute__((used)) volatile auto _CF_UNIQUE(_cf_xref_) = &memcpy;         \
  __attribute__((used)) volatile auto _CF_UNIQUE(_cf_xref_) = &strcmp;         \
  __attribute__((used)) volatile auto _CF_UNIQUE(_cf_xref_) = &malloc;         \
  }

// ============================================================================
// THE "IDA HANG" - Generate thousands of junk functions via templates
// Warning: High values will slow down your compilation!
// Usage: CALL_BLOAT(250) in any function.
// ============================================================================

namespace _cf_bloat {
template <int N> struct Junk {
  __attribute__((noinline, used)) static uint64_t run(uint64_t x) {
    volatile uint64_t y = x ^ (N * 0x12345678);
    return Junk<N - 1>::run(y) + _cf_internal::_hash64(__FILE__ + N % 3);
  }
};

template <> struct Junk<0> {
  __attribute__((noinline, used)) static uint64_t run(uint64_t x) {
    return x ^ 0x987654321;
  }
};
} // namespace _cf_bloat

#define ADD_BLOAT(n)                                                           \
  if (_cf_auto::_false()) {                                                    \
    volatile uint64_t _trash = _cf_bloat::Junk<n>::run(__LINE__);              \
    (void)_trash;                                                              \
  }

// ============================================================================
// DECOY HOOKS - Generate functions that look like real hooks to hide the real
// ones
// ============================================================================

namespace _cf_decoy_hooks {
// Decoy handlers with "Authentic" names to match sasuthread
__attribute__((noinline, used)) inline void *decoy_handler_hash(void *a) {
  return (void *)((uintptr_t)a ^ 0x6969);
}
__attribute__((noinline, used)) inline void *decoy_handler_vtable(void *a) {
  return (void *)((uintptr_t)a + 0xABC);
}
__attribute__((noinline, used)) inline void *decoy_handler_ioctl(void *a,
                                                                 int b) {
  return (void *)((uintptr_t)a + b);
}

template <int N> struct Decoy {
  __attribute__((noinline, used)) static void *emu_thread_stub(void *) {
    volatile int x = 0;
    while (x < 10)
      x++;
    return nullptr;
  }

  __attribute__((noinline, used)) static void setup() {
    if (_cf_auto::_false()) {
      // 1. Wait loop decoy
      volatile bool auth = false;
      while (!auth) {
        if (_cf_auto::_true())
          break;
      }

      // 2. Thread creation decoy (emu_thread)
      pthread_t t;
      pthread_create(&t, NULL, emu_thread_stub, NULL);
      pthread_detach(t);

      uintptr_t base = 0x70000000;
      void *orig = nullptr;

#ifdef __aarch64__
      _cf_hd::HookAddr((void *)(base + 0x39F000 + N), (void *)decoy_handler_hash,
                       &orig, false, 3); // 3 = I_ARM64
      _cf_hd::HookAddr((void *)(base + 0x3A5000 + N),
                       (void *)decoy_handler_vtable, &orig, false, 3);
      _cf_hd::HookAddr((void *)(base + 0x1C5000 + N),
                       (void *)decoy_handler_ioctl, &orig, false, 3);
#else
      _cf_hd::HookAddr((void *)(base + 0x19F000 + N), (void *)decoy_handler_hash,
                       &orig, false, 2); // 2 = I_ARM
      _cf_hd::HookAddr((void *)(base + 0x1A5000 + N),
                       (void *)decoy_handler_vtable, &orig, false, 2);
      _cf_hd::HookAddr((void *)(base + 0x1C5000 + N),
                       (void *)decoy_handler_ioctl, &orig, false, 2);
#endif

#ifdef __aarch64__
      _cf_hd::PatchOffset(base, 0x37C000 + N, "00 00 80 D2 C0 03 5F D6");
      _cf_hd::PatchOffset(base, 0x4DC000 + N, "00 00 80 D2 C0 03 5F D6");
#else
      _cf_hd::PatchOffset(base, 0x37C000 + N, "00 00 A0 E3 1E FF 2F E1");
      _cf_hd::PatchOffset(base, 0x4DC000 + N, "00 00 A0 E3 1E FF 2F E1");
#endif
      Decoy<N - 1>::setup();
    }
  }
};

template <> struct Decoy<0> {
  __attribute__((noinline, used)) static void setup() {}
};
} // namespace _cf_decoy_hooks

#define ADD_DECOY_HOOKS(count)                                                 \
  if (_cf_auto::_false()) {                                                    \
    _cf_decoy_hooks::Decoy<count>::setup();                                    \
  }

// ============================================================================
// IDA_KILLER - Break IDA Pro's auto-analysis and decompiler
// ============================================================================

#if defined(__aarch64__)
#define IDA_KILLER                                                             \
  __asm__ __volatile__("b 1f\n"                                                \
                       ".byte 0x48, 0x8D, 0x05, 0x00\n"                        \
                       "1:\n")

#define BREAK_DECOMPILER                                                       \
  __asm__ __volatile__("mov x16, sp\n"                                         \
                       "sub x16, x16, #0x200\n"                                \
                       "mov sp, x16\n"                                         \
                       "add sp, sp, #0x200\n")
#elif defined(__arm__)
#define IDA_KILLER                                                             \
  __asm__ __volatile__("b 1f\n"                                                \
                       ".byte 0xEB, 0xFF, 0xFF, 0x00\n"                        \
                       "1:\n")

#define BREAK_DECOMPILER                                                       \
  __asm__ __volatile__("mov r12, sp\n"                                         \
                       "sub r12, r12, #0x200\n"                                \
                       "mov sp, r12\n"                                         \
                       "add sp, sp, #0x200\n")
#else
#define IDA_KILLER
#define BREAK_DECOMPILER
#endif

#endif // CONFUSION_H
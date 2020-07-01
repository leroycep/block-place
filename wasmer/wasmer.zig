pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
const struct_unnamed_1 = extern struct {
    __val: [2]c_int,
};
pub const __fsid_t = struct_unnamed_1;
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*c_void;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const int_least8_t = __int_least8_t;
pub const int_least16_t = __int_least16_t;
pub const int_least32_t = __int_least32_t;
pub const int_least64_t = __int_least64_t;
pub const uint_least8_t = __uint_least8_t;
pub const uint_least16_t = __uint_least16_t;
pub const uint_least32_t = __uint_least32_t;
pub const uint_least64_t = __uint_least64_t;
pub const int_fast8_t = i8;
pub const int_fast16_t = c_long;
pub const int_fast32_t = c_long;
pub const int_fast64_t = c_long;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = c_ulong;
pub const uint_fast32_t = c_ulong;
pub const uint_fast64_t = c_ulong;
pub const intmax_t = __intmax_t;
pub const uintmax_t = __uintmax_t;
pub const wchar_t = c_int;
pub const _Float32 = f32;
pub const _Float64 = f64;
pub const _Float32x = f64;
pub const _Float64x = c_longdouble;
const struct_unnamed_2 = extern struct {
    quot: c_int,
    rem: c_int,
};
pub const div_t = struct_unnamed_2;
const struct_unnamed_3 = extern struct {
    quot: c_long,
    rem: c_long,
};
pub const ldiv_t = struct_unnamed_3;
const struct_unnamed_4 = extern struct {
    quot: c_longlong,
    rem: c_longlong,
};
pub const lldiv_t = struct_unnamed_4;
pub extern fn __ctype_get_mb_cur_max() usize;
pub fn atof(arg___nptr: [*c]const u8) callconv(.C) f64 {
    var __nptr = arg___nptr;
    return strtod(__nptr, @ptrCast([*c][*c]u8, @alignCast(@alignOf([*c]u8), (@intToPtr(?*c_void, @as(c_int, 0))))));
}
pub fn atoi(arg___nptr: [*c]const u8) callconv(.C) c_int {
    var __nptr = arg___nptr;
    return @bitCast(c_int, @truncate(c_int, strtol(__nptr, @ptrCast([*c][*c]u8, @alignCast(@alignOf([*c]u8), (@intToPtr(?*c_void, @as(c_int, 0))))), @as(c_int, 10))));
}
pub fn atol(arg___nptr: [*c]const u8) callconv(.C) c_long {
    var __nptr = arg___nptr;
    return strtol(__nptr, @ptrCast([*c][*c]u8, @alignCast(@alignOf([*c]u8), (@intToPtr(?*c_void, @as(c_int, 0))))), @as(c_int, 10));
}
pub fn atoll(arg___nptr: [*c]const u8) callconv(.C) c_longlong {
    var __nptr = arg___nptr;
    return strtoll(__nptr, @ptrCast([*c][*c]u8, @alignCast(@alignOf([*c]u8), (@intToPtr(?*c_void, @as(c_int, 0))))), @as(c_int, 10));
}
pub extern fn strtod(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f64;
pub extern fn strtof(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f32;
pub extern fn strtold(__nptr: [*c]const u8, __endptr: [*c][*c]u8) c_longdouble;
pub extern fn strtol(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_long;
pub extern fn strtoul(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulong;
pub extern fn strtoq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtouq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn strtoll(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtoull(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn l64a(__n: c_long) [*c]u8;
pub extern fn a64l(__s: [*c]const u8) c_long;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const off_t = __off_t;
pub const pid_t = __pid_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const clock_t = __clock_t;
pub const clockid_t = __clockid_t;
pub const time_t = __time_t;
pub const timer_t = __timer_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = __uint8_t;
pub const u_int16_t = __uint16_t;
pub const u_int32_t = __uint32_t;
pub const u_int64_t = __uint64_t;
pub const register_t = c_long;
pub fn __bswap_16(arg___bsx: __uint16_t) callconv(.C) __uint16_t {
    var __bsx = arg___bsx;
    return (@bitCast(__uint16_t, @truncate(c_short, (((@bitCast(c_int, @as(c_uint, (__bsx))) >> @intCast(@import("std").math.Log2Int(c_int), 8)) & @as(c_int, 255)) | ((@bitCast(c_int, @as(c_uint, (__bsx))) & @as(c_int, 255)) << @intCast(@import("std").math.Log2Int(c_int), 8))))));
}
pub fn __bswap_32(arg___bsx: __uint32_t) callconv(.C) __uint32_t {
    var __bsx = arg___bsx;
    return ((((((__bsx) & @as(c_uint, 4278190080)) >> @intCast(@import("std").math.Log2Int(c_uint), 24)) | (((__bsx) & @as(c_uint, 16711680)) >> @intCast(@import("std").math.Log2Int(c_uint), 8))) | (((__bsx) & @as(c_uint, 65280)) << @intCast(@import("std").math.Log2Int(c_uint), 8))) | (((__bsx) & @as(c_uint, 255)) << @intCast(@import("std").math.Log2Int(c_uint), 24)));
}
pub fn __bswap_64(arg___bsx: __uint64_t) callconv(.C) __uint64_t {
    var __bsx = arg___bsx;
    return @bitCast(__uint64_t, @truncate(c_ulong, (((((((((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 18374686479671623680)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 56)) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 71776119061217280)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 40))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 280375465082880)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 24))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 1095216660480)) >> @intCast(@import("std").math.Log2Int(c_ulonglong), 8))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 4278190080)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 8))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 16711680)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 24))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 65280)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 40))) | ((@bitCast(c_ulonglong, @as(c_ulonglong, (__bsx))) & @as(c_ulonglong, 255)) << @intCast(@import("std").math.Log2Int(c_ulonglong), 56)))));
}
pub fn __uint16_identity(arg___x: __uint16_t) callconv(.C) __uint16_t {
    var __x = arg___x;
    return __x;
}
pub fn __uint32_identity(arg___x: __uint32_t) callconv(.C) __uint32_t {
    var __x = arg___x;
    return __x;
}
pub fn __uint64_identity(arg___x: __uint64_t) callconv(.C) __uint64_t {
    var __x = arg___x;
    return __x;
}
const struct_unnamed_5 = extern struct {
    __val: [16]c_ulong,
};
pub const __sigset_t = struct_unnamed_5;
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t,
    tv_usec: __suseconds_t,
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t,
    tv_nsec: __syscall_slong_t,
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
const struct_unnamed_6 = extern struct {
    __fds_bits: [16]__fd_mask,
};
pub const fd_set = struct_unnamed_6;
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]const struct_timespec, noalias __sigmask: [*c]const __sigset_t) c_int;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
pub const struct___pthread_internal_list = extern struct {
    __prev: [*c]struct___pthread_internal_list,
    __next: [*c]struct___pthread_internal_list,
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_internal_slist = extern struct {
    __next: [*c]struct___pthread_internal_slist,
};
pub const __pthread_slist_t = struct___pthread_internal_slist;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int,
    __count: c_uint,
    __owner: c_int,
    __nusers: c_uint,
    __kind: c_int,
    __spins: c_short,
    __elision: c_short,
    __list: __pthread_list_t,
};
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint,
    __writers: c_uint,
    __wrphase_futex: c_uint,
    __writers_futex: c_uint,
    __pad3: c_uint,
    __pad4: c_uint,
    __cur_writer: c_int,
    __shared: c_int,
    __rwelision: i8,
    __pad1: [7]u8,
    __pad2: c_ulong,
    __flags: c_uint,
};
const struct_unnamed_9 = extern struct {
    __low: c_uint,
    __high: c_uint,
};
const union_unnamed_8 = extern union {
    __wseq: c_ulonglong,
    __wseq32: struct_unnamed_9,
};
const struct_unnamed_12 = extern struct {
    __low: c_uint,
    __high: c_uint,
};
const union_unnamed_11 = extern union {
    __g1_start: c_ulonglong,
    __g1_start32: struct_unnamed_12,
};
pub const struct___pthread_cond_s = extern struct {
    unnamed_7: union_unnamed_8,
    unnamed_10: union_unnamed_11,
    __g_refs: [2]c_uint,
    __g_size: [2]c_uint,
    __g1_orig_size: c_uint,
    __wrefs: c_uint,
    __g_signals: [2]c_uint,
};
pub const pthread_t = c_ulong;
const union_unnamed_13 = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_mutexattr_t = union_unnamed_13;
const union_unnamed_14 = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = union_unnamed_14;
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
const union_unnamed_15 = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_mutex_t = union_unnamed_15;
const union_unnamed_16 = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_cond_t = union_unnamed_16;
const union_unnamed_17 = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlock_t = union_unnamed_17;
const union_unnamed_18 = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = union_unnamed_18;
pub const pthread_spinlock_t = c_int;
const union_unnamed_19 = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrier_t = union_unnamed_19;
const union_unnamed_20 = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_barrierattr_t = union_unnamed_20;
pub extern fn random() c_long;
pub extern fn srandom(__seed: c_uint) void;
pub extern fn initstate(__seed: c_uint, __statebuf: [*c]u8, __statelen: usize) [*c]u8;
pub extern fn setstate(__statebuf: [*c]u8) [*c]u8;
pub const struct_random_data = extern struct {
    fptr: [*c]i32,
    rptr: [*c]i32,
    state: [*c]i32,
    rand_type: c_int,
    rand_deg: c_int,
    rand_sep: c_int,
    end_ptr: [*c]i32,
};
pub extern fn random_r(noalias __buf: [*c]struct_random_data, noalias __result: [*c]i32) c_int;
pub extern fn srandom_r(__seed: c_uint, __buf: [*c]struct_random_data) c_int;
pub extern fn initstate_r(__seed: c_uint, noalias __statebuf: [*c]u8, __statelen: usize, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn setstate_r(noalias __statebuf: [*c]u8, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn rand() c_int;
pub extern fn srand(__seed: c_uint) void;
pub extern fn rand_r(__seed: [*c]c_uint) c_int;
pub extern fn drand48() f64;
pub extern fn erand48(__xsubi: [*c]c_ushort) f64;
pub extern fn lrand48() c_long;
pub extern fn nrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn mrand48() c_long;
pub extern fn jrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn srand48(__seedval: c_long) void;
pub extern fn seed48(__seed16v: [*c]c_ushort) [*c]c_ushort;
pub extern fn lcong48(__param: [*c]c_ushort) void;
pub const struct_drand48_data = extern struct {
    __x: [3]c_ushort,
    __old_x: [3]c_ushort,
    __c: c_ushort,
    __init: c_ushort,
    __a: c_ulonglong,
};
pub extern fn drand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn erand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn lrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn nrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn mrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn jrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn srand48_r(__seedval: c_long, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn seed48_r(__seed16v: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn lcong48_r(__param: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn malloc(__size: c_ulong) ?*c_void;
pub extern fn calloc(__nmemb: c_ulong, __size: c_ulong) ?*c_void;
pub extern fn realloc(__ptr: ?*c_void, __size: c_ulong) ?*c_void;
pub extern fn reallocarray(__ptr: ?*c_void, __nmemb: usize, __size: usize) ?*c_void;
pub extern fn free(__ptr: ?*c_void) void;
pub extern fn alloca(__size: c_ulong) ?*c_void;
pub extern fn valloc(__size: usize) ?*c_void;
pub extern fn posix_memalign(__memptr: [*c]?*c_void, __alignment: usize, __size: usize) c_int;
pub extern fn aligned_alloc(__alignment: usize, __size: usize) ?*c_void;
pub extern fn abort() noreturn;
pub extern fn atexit(__func: ?fn () callconv(.C) void) c_int;
pub extern fn at_quick_exit(__func: ?fn () callconv(.C) void) c_int;
pub extern fn on_exit(__func: ?fn (c_int, ?*c_void) callconv(.C) void, __arg: ?*c_void) c_int;
pub extern fn exit(__status: c_int) noreturn;
pub extern fn quick_exit(__status: c_int) noreturn;
pub extern fn _Exit(__status: c_int) noreturn;
pub extern fn getenv(__name: [*c]const u8) [*c]u8;
pub extern fn putenv(__string: [*c]u8) c_int;
pub extern fn setenv(__name: [*c]const u8, __value: [*c]const u8, __replace: c_int) c_int;
pub extern fn unsetenv(__name: [*c]const u8) c_int;
pub extern fn clearenv() c_int;
pub extern fn mktemp(__template: [*c]u8) [*c]u8;
pub extern fn mkstemp(__template: [*c]u8) c_int;
pub extern fn mkstemps(__template: [*c]u8, __suffixlen: c_int) c_int;
pub extern fn mkdtemp(__template: [*c]u8) [*c]u8;
pub extern fn system(__command: [*c]const u8) c_int;
pub extern fn realpath(noalias __name: [*c]const u8, noalias __resolved: [*c]u8) [*c]u8;
pub const __compar_fn_t = ?fn (?*const c_void, ?*const c_void) callconv(.C) c_int;
pub fn bsearch(arg___key: ?*const c_void, arg___base: ?*const c_void, arg___nmemb: usize, arg___size: usize, arg___compar: __compar_fn_t) callconv(.C) ?*c_void {
    var __key = arg___key;
    var __base = arg___base;
    var __nmemb = arg___nmemb;
    var __size = arg___size;
    var __compar = arg___compar;
    var __l: usize = undefined;
    var __u: usize = undefined;
    var __idx: usize = undefined;
    var __p: ?*const c_void = undefined;
    var __comparison: c_int = undefined;
    __l = @bitCast(usize, @as(c_long, @as(c_int, 0)));
    __u = __nmemb;
    while (__l < __u) {
        __idx = ((__l +% __u) / @bitCast(c_ulong, @as(c_long, @as(c_int, 2))));
        __p = @intToPtr(?*c_void, @ptrToInt(((@ptrCast([*c]const u8, @alignCast(@alignOf(u8), __base))) + (__idx *% __size))));
        __comparison = (__compar).?(__key, __p);
        if (__comparison < @as(c_int, 0)) __u = __idx else if (__comparison > @as(c_int, 0)) __l = (__idx +% @bitCast(c_ulong, @as(c_long, @as(c_int, 1)))) else return @intToPtr(?*c_void, @ptrToInt(__p));
    }
    return (@intToPtr(?*c_void, @as(c_int, 0)));
}
pub extern fn qsort(__base: ?*c_void, __nmemb: usize, __size: usize, __compar: __compar_fn_t) void;
pub extern fn abs(__x: c_int) c_int;
pub extern fn labs(__x: c_long) c_long;
pub extern fn llabs(__x: c_longlong) c_longlong;
pub extern fn div(__numer: c_int, __denom: c_int) div_t;
pub extern fn ldiv(__numer: c_long, __denom: c_long) ldiv_t;
pub extern fn lldiv(__numer: c_longlong, __denom: c_longlong) lldiv_t;
pub extern fn ecvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn fcvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn gcvt(__value: f64, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn qecvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qfcvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qgcvt(__value: c_longdouble, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn ecvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn fcvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qecvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qfcvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn mblen(__s: [*c]const u8, __n: usize) c_int;
pub extern fn mbtowc(noalias __pwc: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) c_int;
pub extern fn wctomb(__s: [*c]u8, __wchar: wchar_t) c_int;
pub extern fn mbstowcs(noalias __pwcs: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) usize;
pub extern fn wcstombs(noalias __s: [*c]u8, noalias __pwcs: [*c]const wchar_t, __n: usize) usize;
pub extern fn rpmatch(__response: [*c]const u8) c_int;
pub extern fn getsubopt(noalias __optionp: [*c][*c]u8, noalias __tokens: [*c]const [*c]u8, noalias __valuep: [*c][*c]u8) c_int;
pub extern fn getloadavg(__loadavg: [*c]f64, __nelem: c_int) c_int;
pub const WASM_FUNCTION = @enumToInt(enum_wasmer_import_export_kind.WASM_FUNCTION);
pub const WASM_GLOBAL = @enumToInt(enum_wasmer_import_export_kind.WASM_GLOBAL);
pub const WASM_MEMORY = @enumToInt(enum_wasmer_import_export_kind.WASM_MEMORY);
pub const WASM_TABLE = @enumToInt(enum_wasmer_import_export_kind.WASM_TABLE);
pub const enum_wasmer_import_export_kind = extern enum(c_int) {
    WASM_FUNCTION = 0,
    WASM_GLOBAL = 1,
    WASM_MEMORY = 2,
    WASM_TABLE = 3,
    _,
};
pub const wasmer_import_export_kind = u32;
pub const WASMER_OK = @enumToInt(enum_unnamed_21.WASMER_OK);
pub const WASMER_ERROR = @enumToInt(enum_unnamed_21.WASMER_ERROR);
const enum_unnamed_21 = extern enum(c_int) {
    WASMER_OK = 1,
    WASMER_ERROR = 2,
    _,
};
pub const wasmer_result_t = enum_unnamed_21;
pub const WASM_I32 = @enumToInt(enum_wasmer_value_tag.WASM_I32);
pub const WASM_I64 = @enumToInt(enum_wasmer_value_tag.WASM_I64);
pub const WASM_F32 = @enumToInt(enum_wasmer_value_tag.WASM_F32);
pub const WASM_F64 = @enumToInt(enum_wasmer_value_tag.WASM_F64);
pub const enum_wasmer_value_tag = extern enum(c_int) {
    WASM_I32,
    WASM_I64,
    WASM_F32,
    WASM_F64,
    _,
};
pub const wasmer_value_tag = u32;
const struct_unnamed_22 = extern struct {};
pub const wasmer_module_t = struct_unnamed_22;
const struct_unnamed_23 = @Type(.Opaque);
pub const wasmer_instance_t = struct_unnamed_23;
const struct_unnamed_24 = extern struct {
    bytes: [*c]const u8,
    bytes_len: u32,
};
pub const wasmer_byte_array = struct_unnamed_24;
const struct_unnamed_25 = extern struct {};
pub const wasmer_import_object_t = struct_unnamed_25;
const struct_unnamed_26 = extern struct {};
pub const wasmer_export_descriptor_t = struct_unnamed_26;
const struct_unnamed_27 = extern struct {};
pub const wasmer_export_descriptors_t = struct_unnamed_27;
const struct_unnamed_28 = extern struct {};
pub const wasmer_export_func_t = struct_unnamed_28;
const union_unnamed_29 = extern union {
    I32: i32,
    I64: i64,
    F32: f32,
    F64: f64,
};
pub const wasmer_value = union_unnamed_29;
const struct_unnamed_30 = extern struct {
    tag: wasmer_value_tag,
    value: wasmer_value,
};
pub const wasmer_value_t = struct_unnamed_30;
const struct_unnamed_31 = extern struct {};
pub const wasmer_export_t = struct_unnamed_31;
const struct_unnamed_32 = extern struct {};
pub const wasmer_memory_t = struct_unnamed_32;
const struct_unnamed_33 = extern struct {};
pub const wasmer_exports_t = struct_unnamed_33;
const struct_unnamed_34 = extern struct {};
pub const wasmer_global_t = struct_unnamed_34;
const struct_unnamed_35 = extern struct {
    mutable_: bool,
    kind: wasmer_value_tag,
};
pub const wasmer_global_descriptor_t = struct_unnamed_35;
const struct_unnamed_36 = extern struct {};
pub const wasmer_import_descriptor_t = struct_unnamed_36;
const struct_unnamed_37 = extern struct {};
pub const wasmer_import_descriptors_t = struct_unnamed_37;
const struct_unnamed_38 = extern struct {};
pub const wasmer_import_func_t = struct_unnamed_38;
const struct_unnamed_39 = extern struct {};
pub const wasmer_table_t = struct_unnamed_39;
const union_unnamed_40 = extern union {
    func: [*c]const wasmer_import_func_t,
    table: [*c]const wasmer_table_t,
    memory: [*c]const wasmer_memory_t,
    global: [*c]const wasmer_global_t,
};
pub const wasmer_import_export_value = union_unnamed_40;
const struct_unnamed_41 = extern struct {
    module_name: wasmer_byte_array,
    import_name: wasmer_byte_array,
    tag: wasmer_import_export_kind,
    value: wasmer_import_export_value,
};
pub const wasmer_import_t = struct_unnamed_41;
const struct_unnamed_42 = extern struct {};
pub const wasmer_import_object_iter_t = struct_unnamed_42;
const struct_unnamed_43 = extern struct {};
pub const wasmer_instance_context_t = struct_unnamed_43;
const struct_unnamed_44 = extern struct {
    has_some: bool,
    some: u32,
};
pub const wasmer_limit_option_t = struct_unnamed_44;
const struct_unnamed_45 = extern struct {
    min: u32,
    max: wasmer_limit_option_t,
};
pub const wasmer_limits_t = struct_unnamed_45;
const struct_unnamed_46 = extern struct {};
pub const wasmer_serialized_module_t = struct_unnamed_46;
const struct_unnamed_47 = extern struct {};
pub const wasmer_trampoline_buffer_builder_t = struct_unnamed_47;
const struct_unnamed_48 = extern struct {};
pub const wasmer_trampoline_callable_t = struct_unnamed_48;
const struct_unnamed_49 = extern struct {};
pub const wasmer_trampoline_buffer_t = struct_unnamed_49;
pub extern fn wasmer_compile(module: [*c][*c]wasmer_module_t, wasm_bytes: [*c]u8, wasm_bytes_len: u32) wasmer_result_t;
pub extern fn wasmer_export_descriptor_kind(export_: [*c]wasmer_export_descriptor_t) wasmer_import_export_kind;
pub extern fn wasmer_export_descriptor_name(export_descriptor: [*c]wasmer_export_descriptor_t) wasmer_byte_array;
pub extern fn wasmer_export_descriptors(module: [*c]const wasmer_module_t, export_descriptors: [*c][*c]wasmer_export_descriptors_t) void;
pub extern fn wasmer_export_descriptors_destroy(export_descriptors: [*c]wasmer_export_descriptors_t) void;
pub extern fn wasmer_export_descriptors_get(export_descriptors: [*c]wasmer_export_descriptors_t, idx: c_int) [*c]wasmer_export_descriptor_t;
pub extern fn wasmer_export_descriptors_len(exports: [*c]wasmer_export_descriptors_t) c_int;
pub extern fn wasmer_export_func_call(func: [*c]const wasmer_export_func_t, params: [*c]const wasmer_value_t, params_len: c_uint, results: [*c]wasmer_value_t, results_len: c_uint) wasmer_result_t;
pub extern fn wasmer_export_func_params(func: [*c]const wasmer_export_func_t, params: [*c]wasmer_value_tag, params_len: u32) wasmer_result_t;
pub extern fn wasmer_export_func_params_arity(func: [*c]const wasmer_export_func_t, result: [*c]u32) wasmer_result_t;
pub extern fn wasmer_export_func_returns(func: [*c]const wasmer_export_func_t, returns: [*c]wasmer_value_tag, returns_len: u32) wasmer_result_t;
pub extern fn wasmer_export_func_returns_arity(func: [*c]const wasmer_export_func_t, result: [*c]u32) wasmer_result_t;
pub extern fn wasmer_export_kind(export_: [*c]wasmer_export_t) wasmer_import_export_kind;
pub extern fn wasmer_export_name(export_: [*c]wasmer_export_t) wasmer_byte_array;
pub extern fn wasmer_export_to_func(export_: [*c]const wasmer_export_t) [*c]const wasmer_export_func_t;
pub extern fn wasmer_export_to_memory(export_: [*c]const wasmer_export_t, memory: [*c][*c]wasmer_memory_t) wasmer_result_t;
pub extern fn wasmer_exports_destroy(exports: [*c]wasmer_exports_t) void;
pub extern fn wasmer_exports_get(exports: [*c]wasmer_exports_t, idx: c_int) [*c]wasmer_export_t;
pub extern fn wasmer_exports_len(exports: [*c]wasmer_exports_t) c_int;
pub extern fn wasmer_global_destroy(global: [*c]wasmer_global_t) void;
pub extern fn wasmer_global_get(global: [*c]wasmer_global_t) wasmer_value_t;
pub extern fn wasmer_global_get_descriptor(global: [*c]wasmer_global_t) wasmer_global_descriptor_t;
pub extern fn wasmer_global_new(value: wasmer_value_t, mutable_: bool) [*c]wasmer_global_t;
pub extern fn wasmer_global_set(global: [*c]wasmer_global_t, value: wasmer_value_t) void;
pub extern fn wasmer_import_descriptor_kind(export_: [*c]wasmer_import_descriptor_t) wasmer_import_export_kind;
pub extern fn wasmer_import_descriptor_module_name(import_descriptor: [*c]wasmer_import_descriptor_t) wasmer_byte_array;
pub extern fn wasmer_import_descriptor_name(import_descriptor: [*c]wasmer_import_descriptor_t) wasmer_byte_array;
pub extern fn wasmer_import_descriptors(module: [*c]const wasmer_module_t, import_descriptors: [*c][*c]wasmer_import_descriptors_t) void;
pub extern fn wasmer_import_descriptors_destroy(import_descriptors: [*c]wasmer_import_descriptors_t) void;
pub extern fn wasmer_import_descriptors_get(import_descriptors: [*c]wasmer_import_descriptors_t, idx: c_uint) [*c]wasmer_import_descriptor_t;
pub extern fn wasmer_import_descriptors_len(exports: [*c]wasmer_import_descriptors_t) c_uint;
pub extern fn wasmer_import_func_destroy(func: [*c]wasmer_import_func_t) void;
pub extern fn wasmer_import_func_new(func: ?fn (?*c_void) callconv(.C) void, params: [*c]const wasmer_value_tag, params_len: c_uint, returns: [*c]const wasmer_value_tag, returns_len: c_uint) [*c]wasmer_import_func_t;
pub extern fn wasmer_import_func_params(func: [*c]const wasmer_import_func_t, params: [*c]wasmer_value_tag, params_len: c_uint) wasmer_result_t;
pub extern fn wasmer_import_func_params_arity(func: [*c]const wasmer_import_func_t, result: [*c]u32) wasmer_result_t;
pub extern fn wasmer_import_func_returns(func: [*c]const wasmer_import_func_t, returns: [*c]wasmer_value_tag, returns_len: c_uint) wasmer_result_t;
pub extern fn wasmer_import_func_returns_arity(func: [*c]const wasmer_import_func_t, result: [*c]u32) wasmer_result_t;
pub extern fn wasmer_import_object_destroy(import_object: [*c]wasmer_import_object_t) void;
pub extern fn wasmer_import_object_extend(import_object: [*c]wasmer_import_object_t, imports: [*c]const wasmer_import_t, imports_len: c_uint) wasmer_result_t;
pub extern fn wasmer_import_object_get_import(import_object: [*c]const wasmer_import_object_t, namespace_: wasmer_byte_array, name: wasmer_byte_array, import: [*c]wasmer_import_t, import_export_value: [*c]wasmer_import_export_value, tag: u32) wasmer_result_t;
pub extern fn wasmer_import_object_imports_destroy(imports: [*c]wasmer_import_t, imports_len: u32) void;
pub extern fn wasmer_import_object_iter_at_end(import_object_iter: [*c]wasmer_import_object_iter_t) bool;
pub extern fn wasmer_import_object_iter_destroy(import_object_iter: [*c]wasmer_import_object_iter_t) void;
pub extern fn wasmer_import_object_iter_next(import_object_iter: [*c]wasmer_import_object_iter_t, import: [*c]wasmer_import_t) wasmer_result_t;
pub extern fn wasmer_import_object_iterate_functions(import_object: [*c]const wasmer_import_object_t) [*c]wasmer_import_object_iter_t;
pub extern fn wasmer_import_object_new() [*c]wasmer_import_object_t;
pub extern fn wasmer_instance_call(instance: *wasmer_instance_t, name: [*c]const u8, params: [*c]const wasmer_value_t, params_len: u32, results: [*c]wasmer_value_t, results_len: u32) wasmer_result_t;
pub extern fn wasmer_instance_context_data_get(ctx: [*c]const wasmer_instance_context_t) ?*c_void;
pub extern fn wasmer_instance_context_data_set(instance: [*c]wasmer_instance_t, data_ptr: ?*c_void) void;
pub extern fn wasmer_instance_context_get(instance: [*c]wasmer_instance_t) [*c]const wasmer_instance_context_t;
pub extern fn wasmer_instance_context_memory(ctx: [*c]const wasmer_instance_context_t, _memory_idx: u32) [*c]const wasmer_memory_t;
pub extern fn wasmer_instance_destroy(instance: *wasmer_instance_t) void;
pub extern fn wasmer_instance_exports(instance: [*c]wasmer_instance_t, exports: [*c][*c]wasmer_exports_t) void;
pub extern fn wasmer_instantiate(instance: **wasmer_instance_t, wasm_bytes: [*c]u8, wasm_bytes_len: u32, imports: [*c]wasmer_import_t, imports_len: c_int) wasmer_result_t;
pub extern fn wasmer_last_error_length() c_int;
pub extern fn wasmer_last_error_message(buffer: [*c]u8, length: c_int) c_int;
pub extern fn wasmer_memory_data(memory: [*c]const wasmer_memory_t) [*c]u8;
pub extern fn wasmer_memory_data_length(memory: [*c]const wasmer_memory_t) u32;
pub extern fn wasmer_memory_destroy(memory: [*c]wasmer_memory_t) void;
pub extern fn wasmer_memory_grow(memory: [*c]wasmer_memory_t, delta: u32) wasmer_result_t;
pub extern fn wasmer_memory_length(memory: [*c]const wasmer_memory_t) u32;
pub extern fn wasmer_memory_new(memory: [*c][*c]wasmer_memory_t, limits: wasmer_limits_t) wasmer_result_t;
pub extern fn wasmer_module_deserialize(module: [*c][*c]wasmer_module_t, serialized_module: [*c]const wasmer_serialized_module_t) wasmer_result_t;
pub extern fn wasmer_module_destroy(module: [*c]wasmer_module_t) void;
pub extern fn wasmer_module_import_instantiate(instance: [*c][*c]wasmer_instance_t, module: [*c]const wasmer_module_t, import_object: [*c]const wasmer_import_object_t) wasmer_result_t;
pub extern fn wasmer_module_instantiate(module: [*c]const wasmer_module_t, instance: [*c][*c]wasmer_instance_t, imports: [*c]wasmer_import_t, imports_len: c_int) wasmer_result_t;
pub extern fn wasmer_module_serialize(serialized_module: [*c][*c]wasmer_serialized_module_t, module: [*c]const wasmer_module_t) wasmer_result_t;
pub extern fn wasmer_serialized_module_bytes(serialized_module: [*c]const wasmer_serialized_module_t) wasmer_byte_array;
pub extern fn wasmer_serialized_module_destroy(serialized_module: [*c]wasmer_serialized_module_t) void;
pub extern fn wasmer_serialized_module_from_bytes(serialized_module: [*c][*c]wasmer_serialized_module_t, serialized_module_bytes: [*c]const u8, serialized_module_bytes_length: u32) wasmer_result_t;
pub extern fn wasmer_table_destroy(table: [*c]wasmer_table_t) void;
pub extern fn wasmer_table_grow(table: [*c]wasmer_table_t, delta: u32) wasmer_result_t;
pub extern fn wasmer_table_length(table: [*c]wasmer_table_t) u32;
pub extern fn wasmer_table_new(table: [*c][*c]wasmer_table_t, limits: wasmer_limits_t) wasmer_result_t;
pub extern fn wasmer_trampoline_buffer_builder_add_callinfo_trampoline(builder: [*c]wasmer_trampoline_buffer_builder_t, func: [*c]const wasmer_trampoline_callable_t, ctx: ?*const c_void, num_params: u32) usize;
pub extern fn wasmer_trampoline_buffer_builder_add_context_trampoline(builder: [*c]wasmer_trampoline_buffer_builder_t, func: [*c]const wasmer_trampoline_callable_t, ctx: ?*const c_void) usize;
pub extern fn wasmer_trampoline_buffer_builder_build(builder: [*c]wasmer_trampoline_buffer_builder_t) [*c]wasmer_trampoline_buffer_t;
pub extern fn wasmer_trampoline_buffer_builder_new() [*c]wasmer_trampoline_buffer_builder_t;
pub extern fn wasmer_trampoline_buffer_destroy(buffer: [*c]wasmer_trampoline_buffer_t) void;
pub extern fn wasmer_trampoline_buffer_get_trampoline(buffer: [*c]const wasmer_trampoline_buffer_t, idx: usize) [*c]const wasmer_trampoline_callable_t;
pub extern fn wasmer_trampoline_get_context() ?*c_void;
pub extern fn wasmer_trap(ctx: [*c]const wasmer_instance_context_t, error_message: [*c]const u8) wasmer_result_t;
pub extern fn wasmer_validate(wasm_bytes: [*c]const u8, wasm_bytes_len: u32) bool;
pub const __INTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __PTRDIFF_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __SIZE_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __WINT_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __CHAR16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __CHAR32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __INT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __UINT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT_LEAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT_LEAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __INT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __UINT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_char = void }");
pub const __UINT_FAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __UINT_FAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __INT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UINT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_unsigned = void }");
pub const __GLIBC_USE = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __STRING = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __ptr_t = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __warndecl = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __warnattr = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __errordecl = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __flexarr = @compileError("unable to translate C expr: unexpected token Id{ .LBracket = void }");
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __attribute_alloc_size__ = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_extern = void }");
pub const __attribute_copy__ = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __LDBL_REDIR_DECL = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __glibc_macro_warning1 = @compileError("unable to translate C expr: unexpected token Id{ .Hash = void }");
pub const __S16_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __U16_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_short = void }");
pub const __U32_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __SLONGWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __ULONGWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __SQUAD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UQUAD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __SWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __UWORD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __ULONG32_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __S64_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_int = void }");
pub const __U64_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_long = void }");
pub const __STD_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_typedef = void }");
pub const __TIMER_T_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Nl = void }");
pub const __FSID_T_TYPE = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_struct = void }");
pub const __INT64_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __UINT64_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const INT64_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const UINT32_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const UINT64_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const INTMAX_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const UINTMAX_C = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __WIFSIGNALED = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_signed = void }");
pub const __f32 = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __f64x = @compileError("unable to translate C expr: unexpected token Id{ .HashHash = void }");
pub const __CFLOAT32 = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_complex = void }");
pub const __CFLOAT64 = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_complex = void }");
pub const __CFLOAT32X = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_complex = void }");
pub const __CFLOAT64X = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_complex = void }");
pub const __builtin_huge_valf32 = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_inff32 = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_huge_valf64 = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_inff64 = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_huge_valf32x = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_inff32x = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_huge_valf64x = @compileError("unable to translate C expr: expected identifier");
pub const __builtin_inff64x = @compileError("unable to translate C expr: expected identifier");
pub const MB_CUR_MAX = @compileError("unable to translate C expr: unexpected token Id{ .RParen = void }");
pub const __FD_ZERO = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_do = void }");
pub const __FD_SET = @compileError("unable to translate C expr: expected ')''");
pub const __FD_CLR = @compileError("unable to translate C expr: expected ')''");
pub const _SIGSET_NWORDS = @compileError("unable to translate C expr: unexpected token Id{ .Keyword_sizeof = void }");
pub const __NFDBITS = @compileError("unable to translate C expr: expected ')'' instead got: Keyword_sizeof");
pub const __PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const __PTHREAD_RWLOCK_ELISION_EXTRA = @compileError("unable to translate C expr: unexpected token Id{ .LBrace = void }");
pub const __AVX__ = 1;
pub const __WORDSIZE_TIME64_COMPAT32 = 1;
pub const __FINITE_MATH_ONLY__ = 0;
pub const __UINT_LEAST64_FMTX__ = "lX";
pub const __tune_corei7__ = 1;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const _STDLIB_H = 1;
pub const __UINT64_FMTX__ = "lX";
pub inline fn va_start(ap: var, param: var) @TypeOf(__builtin_va_start(ap, param)) {
    return __builtin_va_start(ap, param);
}
pub const __SSE4_2__ = 1;
pub const __SIG_ATOMIC_MAX__ = 2147483647;
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub inline fn __GNUC_PREREQ(maj: var, min: var) @TypeOf((__GNUC__ << 16) + @boolToInt(__GNUC_MINOR__ >= ((maj << 16) + min))) {
    return (__GNUC__ << 16) + @boolToInt(__GNUC_MINOR__ >= ((maj << 16) + min));
}
pub const __INT_FAST32_FMTd__ = "d";
pub const __STDC_UTF_16__ = 1;
pub const __LDBL_HAS_DENORM__ = 1;
pub const __INTMAX_FMTi__ = "li";
pub const __FMA__ = 1;
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT32_MAX__ = @as(c_uint, 4294967295);
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const __bool_true_false_are_defined = 1;
pub inline fn htobe64(x: var) @TypeOf(__bswap_64(x)) {
    return __bswap_64(x);
}
pub const __INT_MAX__ = 2147483647;
pub const __INT_LEAST64_MAX__ = @as(c_long, 9223372036854775807);
pub const __USE_FORTIFY_LEVEL = 0;
pub const __RLIM_T_MATCHES_RLIM64_T = 1;
pub const __SIZEOF_INT128__ = 16;
pub const __INT64_MAX__ = @as(c_long, 9223372036854775807);
pub const __INT_LEAST32_MAX__ = 2147483647;
pub const __INT_FAST16_FMTd__ = "hd";
pub const __UINT_LEAST64_FMTu__ = "lu";
pub const __WCLONE = 0x80000000;
pub const __UINT8_FMTu__ = "hhu";
pub const __INT_FAST16_MAX__ = 32767;
pub const WNOWAIT = 0x01000000;
pub inline fn le16toh(x: var) @TypeOf(__uint16_identity(x)) {
    return __uint16_identity(x);
}
pub const __INVPCID__ = 1;
pub const __SIZE_FMTx__ = "lx";
pub const __UINT8_FMTX__ = "hhX";
pub inline fn WIFSIGNALED(status: var) @TypeOf(__WIFSIGNALED(status)) {
    return __WIFSIGNALED(status);
}
pub const _BITS_BYTESWAP_H = 1;
pub const INT_FAST32_MAX = @as(c_long, 9223372036854775807);
pub const __CLFLUSHOPT__ = 1;
pub inline fn __builtin_nansf32x(x: var) @TypeOf(__builtin_nans(x)) {
    return __builtin_nans(x);
}
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __ELF__ = 1;
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __DBL_HAS_DENORM__ = 1;
pub const __INT_LEAST64_FMTd__ = "ld";
pub const __SSSE3__ = 1;
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub inline fn __glibc_likely(cond: var) @TypeOf(__builtin_expect(cond, 1)) {
    return __builtin_expect(cond, 1);
}
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __SSP_STRONG__ = 2;
pub const WCHAR_MAX = __WCHAR_MAX;
pub const __clang_patchlevel__ = 0;
pub inline fn htobe32(x: var) @TypeOf(__bswap_32(x)) {
    return __bswap_32(x);
}
pub const __UINT64_FMTu__ = "lu";
pub const EXIT_SUCCESS = 0;
pub const INT_FAST32_MIN = -@as(c_long, 9223372036854775807) - 1;
pub const __LDBL_DIG__ = 18;
pub const __HAVE_FLOAT64 = 1;
pub const __OPENCL_MEMORY_SCOPE_DEVICE = 2;
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __HAVE_FLOAT32 = 1;
pub const __MMX__ = 1;
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const __SIZEOF_WINT_T__ = 4;
pub const __STDC_IEC_559_COMPLEX__ = 1;
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1;
pub inline fn FD_ISSET(fd: var, fdsetp: var) @TypeOf(__FD_ISSET(fd, fdsetp)) {
    return __FD_ISSET(fd, fdsetp);
}
pub const __LITTLE_ENDIAN__ = 1;
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const __INO_T_MATCHES_INO64_T = 1;
pub inline fn __attribute_deprecated_msg__(msg: var) @TypeOf(__attribute__(__deprecated__(msg))) {
    return __attribute__(__deprecated__(msg));
}
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = 0;
pub const __VERSION__ = "Clang 10.0.0 ";
pub const __DBL_HAS_INFINITY__ = 1;
pub const _BITS_PTHREADTYPES_ARCH_H = 1;
pub const __INT_LEAST16_MAX__ = 32767;
pub const __GNUC_MINOR__ = 2;
pub const _STDINT_H = 1;
pub const __corei7 = 1;
pub const __WNOTHREAD = 0x20000000;
pub const __LDBL_HAS_QUIET_NAN__ = 1;
pub const INT_LEAST16_MAX = 32767;
pub const __UINT_FAST32_FMTu__ = "u";
pub const WCHAR_MIN = __WCHAR_MIN;
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const _DEFAULT_SOURCE = 1;
pub const __pic__ = 2;
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C2X = 0;
pub const __FLT_HAS_INFINITY__ = 1;
pub const UINT_FAST32_MAX = @as(c_ulong, 18446744073709551615);
pub const __unix__ = 1;
pub inline fn __bswap_constant_32(x: var) @TypeOf(((x & @as(c_uint, 0xff000000)) >> 24) | (((x & @as(c_uint, 0x00ff0000)) >> 8) | (((x & @as(c_uint, 0x0000ff00)) << 8) | ((x & @as(c_uint, 0x000000ff)) << 24)))) {
    return ((x & @as(c_uint, 0xff000000)) >> 24) | (((x & @as(c_uint, 0x00ff0000)) >> 8) | (((x & @as(c_uint, 0x0000ff00)) << 8) | ((x & @as(c_uint, 0x000000ff)) << 24)));
}
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1;
pub inline fn __va_copy(d: var, s: var) @TypeOf(__builtin_va_copy(d, s)) {
    return __builtin_va_copy(d, s);
}
pub const __restrict_arr = __restrict;
pub const __ADX__ = 1;
pub inline fn be32toh(x: var) @TypeOf(__bswap_32(x)) {
    return __bswap_32(x);
}
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
pub const INT8_MAX = 127;
pub const __UINT_LEAST32_FMTo__ = "o";
pub inline fn FD_ZERO(fdsetp: var) @TypeOf(__FD_ZERO(fdsetp)) {
    return __FD_ZERO(fdsetp);
}
pub const __glibc_c99_flexarr_available = 1;
pub const __UINT_LEAST32_MAX__ = @as(c_uint, 4294967295);
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __SIZEOF_PTHREAD_ATTR_T = 56;
pub const UINT_FAST8_MAX = 255;
pub inline fn htole16(x: var) @TypeOf(__uint16_identity(x)) {
    return __uint16_identity(x);
}
pub const __USE_XOPEN2K = 1;
pub const __HAVE_FLOAT32X = 1;
pub const __clang_version__ = "10.0.0 ";
pub const __INTMAX_FMTd__ = "ld";
pub const __SEG_FS = 1;
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __INT_LEAST32_FMTi__ = "i";
pub const __WCHAR_WIDTH__ = 32;
pub const __UINT16_FMTX__ = "hX";
pub const UINT_LEAST8_MAX = 255;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const unix = 1;
pub inline fn __builtin_nansf64(x: var) @TypeOf(__builtin_nans(x)) {
    return __builtin_nans(x);
}
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const _STRUCT_TIMESPEC = 1;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __INT_LEAST16_TYPE__ = c_short;
pub inline fn FD_SET(fd: var, fdsetp: var) @TypeOf(__FD_SET(fd, fdsetp)) {
    return __FD_SET(fd, fdsetp);
}
pub const __SSE3__ = 1;
pub const __HAVE_DISTINCT_FLOAT64X = 0;
pub const INT32_MAX = 2147483647;
pub const INT_FAST8_MAX = 127;
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_FAST64_FMTu__ = "lu";
pub const INT16_MIN = -32767 - 1;
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __SSE2__ = 1;
pub const _ATFILE_SOURCE = 1;
pub const __STDC__ = 1;
pub const __attribute_warn_unused_result__ = __attribute__(__warn_unused_result__);
pub const _BITS_ENDIAN_H = 1;
pub const _BITS_PTHREADTYPES_COMMON_H = 1;
pub const __LONG_MAX__ = @as(c_long, 9223372036854775807);
pub const __MODE_T_TYPE = __U32_TYPE;
pub inline fn __bswap_constant_64(x: var) @TypeOf(((x & @as(c_ulonglong, 0xff00000000000000)) >> 56) | (((x & @as(c_ulonglong, 0x00ff000000000000)) >> 40) | (((x & @as(c_ulonglong, 0x0000ff0000000000)) >> 24) | (((x & @as(c_ulonglong, 0x000000ff00000000)) >> 8) | (((x & @as(c_ulonglong, 0x00000000ff000000)) << 8) | (((x & @as(c_ulonglong, 0x0000000000ff0000)) << 24) | (((x & @as(c_ulonglong, 0x000000000000ff00)) << 40) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << 56)))))))) {
    return ((x & @as(c_ulonglong, 0xff00000000000000)) >> 56) | (((x & @as(c_ulonglong, 0x00ff000000000000)) >> 40) | (((x & @as(c_ulonglong, 0x0000ff0000000000)) >> 24) | (((x & @as(c_ulonglong, 0x000000ff00000000)) >> 8) | (((x & @as(c_ulonglong, 0x00000000ff000000)) << 8) | (((x & @as(c_ulonglong, 0x0000000000ff0000)) << 24) | (((x & @as(c_ulonglong, 0x000000000000ff00)) << 40) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << 56)))))));
}
pub const __FSGSBASE__ = 1;
pub const __INTPTR_MAX__ = @as(c_long, 9223372036854775807);
pub const __INTMAX_WIDTH__ = 64;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __PID_T_TYPE = __S32_TYPE;
pub const __x86_64 = 1;
pub const __INT8_FMTd__ = "hhd";
pub const __UINTMAX_WIDTH__ = 64;
pub const __UINT8_MAX__ = 255;
pub const __lldiv_t_defined = 1;
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = 0;
pub const __DBL_HAS_QUIET_NAN__ = 1;
pub const __clang_minor__ = 0;
pub const __STATFS_MATCHES_STATFS64 = 1;
pub const __LDBL_DECIMAL_DIG__ = 21;
pub const __always_inline = __inline ++ __attribute__(__always_inline__);
pub const __SSE4_1__ = 1;
pub const __WCHAR_TYPE__ = c_int;
pub const __INT_FAST64_FMTd__ = "ld";
pub const INT_LEAST64_MIN = -__INT64_C(9223372036854775807) - 1;
pub const NFDBITS = __NFDBITS;
pub inline fn WTERMSIG(status: var) @TypeOf(__WTERMSIG(status)) {
    return __WTERMSIG(status);
}
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __INT16_FMTi__ = "hi";
pub const WSTOPPED = 2;
pub const __PRFCHW__ = 1;
pub const __LDBL_MIN_EXP__ = -16381;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __UINTMAX_FMTu__ = "lu";
pub const __HAVE_DISTINCT_FLOAT16 = __HAVE_FLOAT16;
pub const __UINT32_FMTu__ = "u";
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const __amd64__ = 1;
pub const __USE_EXTERN_INLINES = 1;
pub const __INT64_C_SUFFIX__ = L;
pub inline fn INT16_C(c: var) @TypeOf(c) {
    return c;
}
pub const __CLANG_ATOMIC_INT_LOCK_FREE = 2;
pub inline fn __PTHREAD_RWLOCK_INITIALIZER(__flags: var) @TypeOf(__flags) {
    return blk: {
        _ = 0;
        _ = 0;
        _ = 0;
        _ = 0;
        _ = 0;
        _ = 0;
        _ = 0;
        _ = 0;
        _ = __PTHREAD_RWLOCK_ELISION_EXTRA;
        _ = 0;
        break :blk __flags;
    };
}
pub const _BITS_TYPESIZES_H = 1;
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = 2;
pub inline fn __P(args: var) @TypeOf(args) {
    return args;
}
pub const __UINT64_FMTx__ = "lx";
pub inline fn __LONG_LONG_PAIR(HI: var, LO: var) @TypeOf(HI) {
    return blk: {
        _ = LO;
        break :blk HI;
    };
}
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __GNUC__ = 4;
pub const __INT_FAST32_FMTi__ = "i";
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = 2;
pub inline fn __LDBL_REDIR1_NTH(name: var, proto: var, alias: var) @TypeOf(name ++ (proto ++ __THROW)) {
    return name ++ (proto ++ __THROW);
}
pub const __seg_gs = __attribute__(address_space(256));
pub const __UINT64_FMTo__ = "lo";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const WNOHANG = 1;
pub const _THREAD_SHARED_TYPES_H = 1;
pub const __GLIBC_USE_DEPRECATED_SCANF = 0;
pub const __attribute_used__ = __attribute__(__used__);
pub inline fn INT32_C(c: var) @TypeOf(c) {
    return c;
}
pub const __FD_ZERO_STOS = "stosq";
pub const __STDC_UTF_32__ = 1;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const _ALLOCA_H = 1;
pub const _SYS_CDEFS_H = 1;
pub inline fn __glibc_clang_prereq(maj: var, min: var) @TypeOf((__clang_major__ << 16) + @boolToInt(__clang_minor__ >= ((maj << 16) + min))) {
    return (__clang_major__ << 16) + @boolToInt(__clang_minor__ >= ((maj << 16) + min));
}
pub const UINT32_MAX = @as(c_uint, 4294967295);
pub const __UINT16_FMTu__ = "hu";
pub const INT_LEAST8_MIN = -128;
pub const __GNUC_STDC_INLINE__ = 1;
pub const __W_CONTINUED = 0xffff;
pub const __DBL_DIG__ = 15;
pub inline fn va_copy(dest: var, src: var) @TypeOf(__builtin_va_copy(dest, src)) {
    return __builtin_va_copy(dest, src);
}
pub const __HAVE_DISTINCT_FLOAT32 = 0;
pub const __PTHREAD_MUTEX_HAVE_PREV = 1;
pub const __INT32_FMTd__ = "d";
pub const __sigset_t_defined = 1;
pub const __INT_LEAST32_FMTd__ = "d";
pub const __USE_POSIX199506 = 1;
pub inline fn __bos(ptr: var) @TypeOf(__builtin_object_size(ptr, __USE_FORTIFY_LEVEL > 1)) {
    return __builtin_object_size(ptr, __USE_FORTIFY_LEVEL > 1);
}
pub const __FLT_DIG__ = 6;
pub const __INTPTR_FMTi__ = "li";
pub const __UINT_FAST64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __SIZEOF_LONG_LONG__ = 8;
pub const INT_LEAST64_MAX = __INT64_C(9223372036854775807);
pub const __INT32_TYPE__ = c_int;
pub const __UINTPTR_FMTX__ = "lX";
pub const __SIZEOF_LONG_DOUBLE__ = 16;
pub const __WCHAR_MAX = __WCHAR_MAX__;
pub const __WCOREFLAG = 0x80;
pub const __DBL_MIN_EXP__ = -1021;
pub const bool_50 = bool;
pub const __INT64_FMTi__ = "li";
pub const __INT_FAST64_FMTi__ = "li";
pub const __attribute_const__ = __attribute__(__const__);
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const INT_LEAST32_MAX = 2147483647;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __GLIBC_USE_LIB_EXT2 = 0;
pub inline fn __NTHNL(fct: var) @TypeOf(__attribute__(__nothrow__) ++ fct) {
    return __attribute__(__nothrow__) ++ fct;
}
pub const __timeval_defined = 1;
pub const __HAVE_FLOAT16 = 0;
pub const __LDBL_HAS_INFINITY__ = 1;
pub inline fn WEXITSTATUS(status: var) @TypeOf(__WEXITSTATUS(status)) {
    return __WEXITSTATUS(status);
}
pub const __UINT_LEAST32_FMTX__ = "X";
pub inline fn __nonnull(params: var) @TypeOf(__attribute__(__nonnull__ ++ params)) {
    return __attribute__(__nonnull__ ++ params);
}
pub const __SSE_MATH__ = 1;
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = 2;
pub const @"false" = 0;
pub const SIG_ATOMIC_MAX = 2147483647;
pub const __HAVE_DISTINCT_FLOAT128X = __HAVE_FLOAT128X;
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub inline fn __glibc_unlikely(cond: var) @TypeOf(__builtin_expect(cond, 0)) {
    return __builtin_expect(cond, 0);
}
pub const _SYS_SELECT_H = 1;
pub inline fn __glibc_has_attribute(attr: var) @TypeOf(__has_attribute(attr)) {
    return __has_attribute(attr);
}
pub const __INT16_TYPE__ = c_short;
pub const __PCLMUL__ = 1;
pub const __UINTPTR_FMTx__ = "lx";
pub const __WCHAR_MIN = -__WCHAR_MAX - 1;
pub inline fn WIFEXITED(status: var) @TypeOf(__WIFEXITED(status)) {
    return __WIFEXITED(status);
}
pub const __AES__ = 1;
pub const __S32_TYPE = c_int;
pub const __FLT_RADIX__ = 2;
pub const __FD_SETSIZE = 1024;
pub const FD_SETSIZE = __FD_SETSIZE;
pub const __amd64 = 1;
pub const INT_LEAST8_MAX = 127;
pub inline fn __attribute_format_strfmon__(a: var, b: var) @TypeOf(__attribute__(__format__(__strfmon__, a, b))) {
    return __attribute__(__format__(__strfmon__, a, b));
}
pub const __UINTPTR_FMTo__ = "lo";
pub const __INT32_MAX__ = 2147483647;
pub const __INTPTR_FMTd__ = "ld";
pub inline fn va_arg(ap: var, type_1: var) @TypeOf(__builtin_va_arg(ap, type_1)) {
    return __builtin_va_arg(ap, type_1);
}
pub const __INT_FAST32_MAX__ = 2147483647;
pub const _BITS_TIME64_H = 1;
pub const __INT32_FMTi__ = "i";
pub inline fn __bswap_constant_16(x: var) @TypeOf((if (@typeInfo(@TypeOf(((x >> 8) & 0xff) | ((x & 0xff) << 8))) == .Pointer) @ptrCast(__uint16_t, @alignCast(@alignOf(__uint16_t.Child), ((x >> 8) & 0xff) | ((x & 0xff) << 8))) else if (@typeInfo(@TypeOf(((x >> 8) & 0xff) | ((x & 0xff) << 8))) == .Int and @typeInfo(__uint16_t) == .Pointer) @intToPtr(__uint16_t, ((x >> 8) & 0xff) | ((x & 0xff) << 8)) else @as(__uint16_t, ((x >> 8) & 0xff) | ((x & 0xff) << 8)))) {
    return (if (@typeInfo(@TypeOf(((x >> 8) & 0xff) | ((x & 0xff) << 8))) == .Pointer) @ptrCast(__uint16_t, @alignCast(@alignOf(__uint16_t.Child), ((x >> 8) & 0xff) | ((x & 0xff) << 8))) else if (@typeInfo(@TypeOf(((x >> 8) & 0xff) | ((x & 0xff) << 8))) == .Int and @typeInfo(__uint16_t) == .Pointer) @intToPtr(__uint16_t, ((x >> 8) & 0xff) | ((x & 0xff) << 8)) else @as(__uint16_t, ((x >> 8) & 0xff) | ((x & 0xff) << 8)));
}
pub const __USE_ISOC11 = 1;
pub const __GCC_ATOMIC_INT_LOCK_FREE = 2;
pub const __MOVBE__ = 1;
pub const __INT_LEAST32_TYPE__ = c_int;
pub inline fn __REDIRECT_LDBL(name: var, proto: var, alias: var) @TypeOf(__REDIRECT(name, proto, alias)) {
    return __REDIRECT(name, proto, alias);
}
pub const UINT_LEAST16_MAX = 65535;
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __SIZE_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __INT_FAST64_MAX__ = @as(c_long, 9223372036854775807);
pub const SIG_ATOMIC_MIN = -2147483647 - 1;
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __UINTPTR_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __UINT_FAST32_FMTx__ = "x";
pub inline fn __ASMNAME2(prefix: var, cname: var) @TypeOf(__STRING(prefix) ++ cname) {
    return __STRING(prefix) ++ cname;
}
pub const __PTRDIFF_FMTd__ = "ld";
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __WCHAR_MAX__ = 2147483647;
pub const __ATOMIC_SEQ_CST = 5;
pub inline fn UINT8_C(c: var) @TypeOf(c) {
    return c;
}
pub const __THROW = __attribute__(__nothrow__ ++ __LEAF);
pub const __THROWNL = __attribute__(__nothrow__);
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const UINTMAX_MAX = __UINT64_C(18446744073709551615);
pub const __x86_64__ = 1;
pub const __BMI__ = 1;
pub const __FLT_MANT_DIG__ = 24;
pub const __BIT_TYPES_DEFINED__ = 1;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZEOF_DOUBLE__ = 8;
pub const __USE_ATFILE = 1;
pub inline fn __builtin_nanf32x(x: var) @TypeOf(__builtin_nan(x)) {
    return __builtin_nan(x);
}
pub inline fn __NTH(fct: var) @TypeOf(__attribute__(__nothrow__ ++ __LEAF) ++ fct) {
    return __attribute__(__nothrow__ ++ __LEAF) ++ fct;
}
pub const __USE_POSIX_IMPLICITLY = 1;
pub inline fn __WSTOPSIG(status: var) @TypeOf(__WEXITSTATUS(status)) {
    return __WEXITSTATUS(status);
}
pub const __UINT64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __SYSCALL_WORDSIZE = 64;
pub const __SIZEOF_FLOAT__ = 4;
pub const __SEG_GS = 1;
pub const INT_FAST64_MAX = __INT64_C(9223372036854775807);
pub inline fn __FD_ISSET(d: var, set: var) @TypeOf((__FDS_BITS(set)[__FD_ELT(d)] & __FD_MASK(d)) != 0) {
    return (__FDS_BITS(set)[__FD_ELT(d)] & __FD_MASK(d)) != 0;
}
pub const __INT_FAST8_MAX__ = 127;
pub const __OBJC_BOOL_IS_BOOL = 0;
pub const __USE_POSIX2 = 1;
pub inline fn __glibc_macro_warning(message: var) @TypeOf(__glibc_macro_warning1(GCC ++ (warning ++ message))) {
    return __glibc_macro_warning1(GCC ++ (warning ++ message));
}
pub const __SIZEOF_PTHREAD_CONDATTR_T = 4;
pub inline fn __FD_MASK(d: var) @TypeOf((if (@typeInfo(@TypeOf(@as(c_ulong, 1) << (d % __NFDBITS))) == .Pointer) @ptrCast(__fd_mask, @alignCast(@alignOf(__fd_mask.Child), @as(c_ulong, 1) << (d % __NFDBITS))) else if (@typeInfo(@TypeOf(@as(c_ulong, 1) << (d % __NFDBITS))) == .Int and @typeInfo(__fd_mask) == .Pointer) @intToPtr(__fd_mask, @as(c_ulong, 1) << (d % __NFDBITS)) else @as(__fd_mask, @as(c_ulong, 1) << (d % __NFDBITS)))) {
    return (if (@typeInfo(@TypeOf(@as(c_ulong, 1) << (d % __NFDBITS))) == .Pointer) @ptrCast(__fd_mask, @alignCast(@alignOf(__fd_mask.Child), @as(c_ulong, 1) << (d % __NFDBITS))) else if (@typeInfo(@TypeOf(@as(c_ulong, 1) << (d % __NFDBITS))) == .Int and @typeInfo(__fd_mask) == .Pointer) @intToPtr(__fd_mask, @as(c_ulong, 1) << (d % __NFDBITS)) else @as(__fd_mask, @as(c_ulong, 1) << (d % __NFDBITS)));
}
pub const __SSE__ = 1;
pub const __NO_MATH_INLINES = 1;
pub const __SIZEOF_FLOAT128__ = 16;
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __UINT_FAST16_MAX__ = 65535;
pub const __ATOMIC_ACQUIRE = 2;
pub const _FEATURES_H = 1;
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
pub const INT_FAST8_MIN = -128;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1;
pub const __DBL_MIN_10_EXP__ = -307;
pub const __attribute_pure__ = __attribute__(__pure__);
pub const __PDP_ENDIAN = 3412;
pub inline fn htole32(x: var) @TypeOf(__uint32_identity(x)) {
    return __uint32_identity(x);
}
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub inline fn __bos0(ptr: var) @TypeOf(__builtin_object_size(ptr, 0)) {
    return __builtin_object_size(ptr, 0);
}
pub const __LP64__ = 1;
pub const __ORDER_PDP_ENDIAN__ = 3412;
pub const __SIZEOF_PTHREAD_MUTEX_T = 40;
pub const __LDBL_MAX_10_EXP__ = 4932;
pub const __LDBL_MIN_10_EXP__ = -4931;
pub const __PTRDIFF_FMTi__ = "li";
pub const __DBL_MAX_10_EXP__ = 308;
pub const __STDC_IEC_559__ = 1;
pub inline fn __REDIRECT_NTH_LDBL(name: var, proto: var, alias: var) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __SIZEOF_LONG__ = 8;
pub const __FLT_MIN_EXP__ = -125;
pub const INT_FAST16_MAX = @as(c_long, 9223372036854775807);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __FLT_EVAL_METHOD__ = 0;
pub inline fn __WCOREDUMP(status: var) @TypeOf(status & __WCOREFLAG) {
    return status & __WCOREFLAG;
}
pub inline fn __builtin_nansf32(x: var) @TypeOf(__builtin_nansf(x)) {
    return __builtin_nansf(x);
}
pub const __UINTMAX_FMTx__ = "lx";
pub const __code_model_small_ = 1;
pub const _LP64 = 1;
pub const __FLT_MAX_EXP__ = 128;
pub const UINT8_MAX = 255;
pub const __WINT_UNSIGNED__ = 1;
pub const __GNU_LIBRARY__ = 6;
pub const SIZE_MAX = @as(c_ulong, 18446744073709551615);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub inline fn __W_STOPCODE(sig: var) @TypeOf(sig << (8 | 0x7f)) {
    return sig << (8 | 0x7f);
}
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __SIZEOF_PTHREAD_RWLOCK_T = 56;
pub const _THREAD_MUTEX_INTERNAL_H = 1;
pub const __UINT_FAST32_FMTX__ = "X";
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __LZCNT__ = 1;
pub inline fn __glibc_clang_has_extension(ext: var) @TypeOf(__has_extension(ext)) {
    return __has_extension(ext);
}
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const _BITS_TYPES_H = 1;
pub const __SIZEOF_PTHREAD_BARRIER_T = 32;
pub const UINT_FAST64_MAX = __UINT64_C(18446744073709551615);
pub const WUNTRACED = 2;
pub inline fn WSTOPSIG(status: var) @TypeOf(__WSTOPSIG(status)) {
    return __WSTOPSIG(status);
}
pub const __SIZEOF_SHORT__ = 2;
pub inline fn __WTERMSIG(status: var) @TypeOf(status & 0x7f) {
    return status & 0x7f;
}
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub inline fn le64toh(x: var) @TypeOf(__uint64_identity(x)) {
    return __uint64_identity(x);
}
pub inline fn __GLIBC_PREREQ(maj: var, min: var) @TypeOf((__GLIBC__ << 16) + @boolToInt(__GLIBC_MINOR__ >= ((maj << 16) + min))) {
    return (__GLIBC__ << 16) + @boolToInt(__GLIBC_MINOR__ >= ((maj << 16) + min));
}
pub const __INTMAX_C_SUFFIX__ = L;
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const INT16_MAX = 32767;
pub const __SCHAR_MAX__ = 127;
pub const __UINT32_FMTx__ = "x";
pub const WINT_MIN = @as(c_uint, 0);
pub const __UINT8_FMTx__ = "hhx";
pub inline fn __WIFCONTINUED(status: var) @TypeOf(status == __W_CONTINUED) {
    return status == __W_CONTINUED;
}
pub const __WALL = 0x40000000;
pub const __clockid_t_defined = 1;
pub const __UINT_LEAST64_FMTx__ = "lx";
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub inline fn __LDBL_REDIR_NTH(name: var, proto: var) @TypeOf(name ++ (proto ++ __THROW)) {
    return name ++ (proto ++ __THROW);
}
pub const __UINT_LEAST64_MAX__ = @as(c_ulong, 18446744073709551615);
pub const INT64_MIN = -__INT64_C(9223372036854775807) - 1;
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __clang__ = 1;
pub const _BITS_STDINT_INTN_H = 1;
pub const __GLIBC__ = 2;
pub const __UINTPTR_FMTu__ = "lu";
pub const __USE_XOPEN2K8 = 1;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __INT_FAST32_TYPE__ = c_int;
pub const UINTPTR_MAX = @as(c_ulong, 18446744073709551615);
pub const __UINT16_FMTx__ = "hx";
pub const __FLT_MIN_10_EXP__ = -37;
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __GNUC_VA_LIST = 1;
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZEOF_POINTER__ = 8;
pub const __SIZE_FMTX__ = "lX";
pub const __INT16_FMTd__ = "hd";
pub inline fn __f32x(x: var) @TypeOf(x) {
    return x;
}
pub const __ATOMIC_RELEASE = 3;
pub const __UINT_FAST64_FMTX__ = "lX";
pub const WINT_MAX = @as(c_uint, 4294967295);
pub inline fn __WIFEXITED(status: var) @TypeOf(__WTERMSIG(status) == 0) {
    return __WTERMSIG(status) == 0;
}
pub const INT_FAST16_MIN = -@as(c_long, 9223372036854775807) - 1;
pub const __USE_POSIX199309 = 1;
pub const INT32_MIN = -2147483647 - 1;
pub const __WINT_WIDTH__ = 32;
pub const __timer_t_defined = 1;
pub const __FLT_MAX_10_EXP__ = 38;
pub const __GCC_ATOMIC_LONG_LOCK_FREE = 2;
pub const __gnu_linux__ = 1;
pub const _DEBUG = 1;
pub inline fn __WEXITSTATUS(status: var) @TypeOf((status & 0xff00) >> 8) {
    return (status & 0xff00) >> 8;
}
pub inline fn __PMT(args: var) @TypeOf(args) {
    return args;
}
pub inline fn htole64(x: var) @TypeOf(__uint64_identity(x)) {
    return __uint64_identity(x);
}
pub const __UINTPTR_WIDTH__ = 64;
pub const __HAVE_DISTINCT_FLOAT128 = 0;
pub const INTMAX_MIN = -__INT64_C(9223372036854775807) - 1;
pub const PTRDIFF_MIN = -@as(c_long, 9223372036854775807) - 1;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const INT64_MAX = __INT64_C(9223372036854775807);
pub const __GNUC_PATCHLEVEL__ = 1;
pub const __INT64_FMTd__ = "ld";
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __GLIBC_USE_ISOC2X = 0;
pub const __HAVE_FLOAT64X_LONG_DOUBLE = 1;
pub const __UINT16_MAX__ = 65535;
pub const __ATOMIC_RELAXED = 0;
pub const _POSIX_SOURCE = 1;
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __time_t_defined = 1;
pub const __GLIBC_USE_IEC_60559_BFP_EXT = 0;
pub const __INT_FAST16_TYPE__ = c_short;
pub inline fn be64toh(x: var) @TypeOf(__bswap_64(x)) {
    return __bswap_64(x);
}
pub const __UINT64_C_SUFFIX__ = UL;
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __CHAR_BIT__ = 8;
pub const __HAVE_FLOAT64X = 1;
pub const __DBL_DECIMAL_DIG__ = 17;
pub inline fn __LDBL_REDIR(name: var, proto: var) @TypeOf(name ++ proto) {
    return name ++ proto;
}
pub inline fn __FDS_BITS(set: var) @TypeOf(set.*.__fds_bits) {
    return set.*.__fds_bits;
}
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const linux = 1;
pub const __ORDER_BIG_ENDIAN__ = 4321;
pub const __INT_LEAST8_FMTd__ = "hhd";
pub inline fn __W_EXITCODE(ret: var, sig: var) @TypeOf(ret << (8 | sig)) {
    return ret << (8 | sig);
}
pub inline fn __WIFSTOPPED(status: var) @TypeOf((status & 0xff) == 0x7f) {
    return (status & 0xff) == 0x7f;
}
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = 2;
pub const __LONG_DOUBLE_USES_FLOAT128 = 0;
pub const __FLOAT128__ = 1;
pub const __attribute_deprecated__ = __attribute__(__deprecated__);
pub const __GLIBC_MINOR__ = 31;
pub const UINT_LEAST64_MAX = __UINT64_C(18446744073709551615);
pub const __HAVE_FLOAT128_UNLIKE_LDBL = (__HAVE_DISTINCT_FLOAT128 != 0) and (__LDBL_MANT_DIG__ != 113);
pub const __HAVE_FLOATN_NOT_TYPEDEF = 0;
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = 2;
pub const __INTMAX_MAX__ = @as(c_long, 9223372036854775807);
pub const @"true" = 1;
pub inline fn __builtin_nanf64(x: var) @TypeOf(__builtin_nan(x)) {
    return __builtin_nan(x);
}
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __PRAGMA_REDEFINE_EXTNAME = 1;
pub inline fn FD_CLR(fd: var, fdsetp: var) @TypeOf(__FD_CLR(fd, fdsetp)) {
    return __FD_CLR(fd, fdsetp);
}
pub const __USE_MISC = 1;
pub const __RDRND__ = 1;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __seg_fs = __attribute__(address_space(257));
pub const __XSAVEOPT__ = 1;
pub const __attribute_malloc__ = __attribute__(__malloc__);
pub const __HAVE_GENERIC_SELECTION = 1;
pub const __UINTMAX_FMTX__ = "lX";
pub const __AVX2__ = 1;
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const _STDC_PREDEF_H = 1;
pub const INTPTR_MIN = -@as(c_long, 9223372036854775807) - 1;
pub const UINT64_MAX = __UINT64_C(18446744073709551615);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1;
pub const __SIG_ATOMIC_WIDTH__ = 32;
pub const __OPTIMIZE__ = 1;
pub inline fn DEPRECATED(message: var) @TypeOf(__attribute__(deprecated(message))) {
    return __attribute__(deprecated(message));
}
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __SSE2_MATH__ = 1;
pub inline fn WIFCONTINUED(status: var) @TypeOf(__WIFCONTINUED(status)) {
    return __WIFCONTINUED(status);
}
pub const __SIZEOF_PTHREAD_COND_T = 48;
pub const __SGX__ = 1;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __POPCNT__ = 1;
pub inline fn __LDBL_REDIR1(name: var, proto: var, alias: var) @TypeOf(name ++ proto) {
    return name ++ proto;
}
pub const __POINTER_WIDTH__ = 64;
pub const __ATOMIC_ACQ_REL = 4;
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __OFF_T_MATCHES_OFF64_T = 1;
pub const __STDC_HOSTED__ = 1;
pub const __PIC__ = 2;
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C2X = 0;
pub const __FXSR__ = 1;
pub inline fn __builtin_nansf64x(x: var) @TypeOf(__builtin_nansl(x)) {
    return __builtin_nansl(x);
}
pub inline fn le32toh(x: var) @TypeOf(__uint32_identity(x)) {
    return __uint32_identity(x);
}
pub const _BITS_WCHAR_H = 1;
pub const UINT_FAST16_MAX = @as(c_ulong, 18446744073709551615);
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __UINT_LEAST64_FMTo__ = "lo";
pub const __PTRDIFF_WIDTH__ = 64;
pub inline fn WIFSTOPPED(status: var) @TypeOf(__WIFSTOPPED(status)) {
    return __WIFSTOPPED(status);
}
pub const __SIZE_WIDTH__ = 64;
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __UINTMAX_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __SIZEOF_PTRDIFF_T__ = 8;
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __DBL_MANT_DIG__ = 53;
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __INT_LEAST64_FMTi__ = "li";
pub const __UINT32_FMTX__ = "X";
pub const __SHRT_MAX__ = 32767;
pub const __ATOMIC_CONSUME = 1;
pub const __have_pthread_attr_t = 1;
pub const __GLIBC_USE_DEPRECATED_GETS = 0;
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INT8_MAX__ = 127;
pub const __FLT_DECIMAL_DIG__ = 9;
pub const __HAVE_DISTINCT_FLOAT32X = 0;
pub const __UINT8_FMTo__ = "hho";
pub const _BITS_ENDIANNESS_H = 1;
pub const __FLT_HAS_DENORM__ = 1;
pub const __UINT32_FMTo__ = "o";
pub const _BITS_UINTN_IDENTITY_H = 1;
pub const __UINT_FAST64_FMTo__ = "lo";
pub const __GXX_ABI_VERSION = 1002;
pub const INTMAX_MAX = __INT64_C(9223372036854775807);
pub const _ENDIAN_H = 1;
pub const INT_LEAST16_MIN = -32767 - 1;
pub const RAND_MAX = 2147483647;
pub inline fn __ASMNAME(cname: var) @TypeOf(__ASMNAME2(__USER_LABEL_PREFIX__, cname)) {
    return __ASMNAME2(__USER_LABEL_PREFIX__, cname);
}
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = 3;
pub const __INT8_FMTi__ = "hhi";
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub inline fn __attribute_format_arg__(x: var) @TypeOf(__attribute__(__format_arg__(x))) {
    return __attribute__(__format_arg__(x));
}
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1;
pub const __USE_ISOC95 = 1;
pub const __clang_major__ = 10;
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = 4;
pub const __INT16_MAX__ = 32767;
pub const __linux = 1;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const __HAVE_DISTINCT_FLOAT64 = 0;
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = 2;
pub const EXIT_FAILURE = 1;
pub const __UINT16_FMTo__ = "ho";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST64_FMTx__ = "lx";
pub const INTPTR_MAX = @as(c_long, 9223372036854775807);
pub const __XSAVES__ = 1;
pub const __UINT_LEAST8_MAX__ = 255;
pub const UINT16_MAX = 65535;
pub const INT_FAST64_MIN = -__INT64_C(9223372036854775807) - 1;
pub const __WORDSIZE = 64;
pub const __USE_POSIX = 1;
pub inline fn __builtin_nanf32(x: var) @TypeOf(__builtin_nanf(x)) {
    return __builtin_nanf(x);
}
pub const __UINT_LEAST16_MAX__ = 65535;
pub const __unix = 1;
pub const __CONSTANT_CFSTRINGS__ = 1;
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub inline fn htobe16(x: var) @TypeOf(__bswap_16(x)) {
    return __bswap_16(x);
}
pub const __llvm__ = 1;
pub const __SLONG32_TYPE = c_int;
pub const WEXITED = 4;
pub const __DBL_MAX_EXP__ = 1024;
pub const __LITTLE_ENDIAN = 1234;
pub const __GCC_ASM_FLAG_OUTPUTS__ = 1;
pub const __PTRDIFF_MAX__ = @as(c_long, 9223372036854775807);
pub const __ORDER_LITTLE_ENDIAN__ = 1234;
pub const __linux__ = 1;
pub const __attribute_noinline__ = __attribute__(__noinline__);
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USE_ISOC99 = 1;
pub const __LDBL_MAX_EXP__ = 16384;
pub const __UINT_FAST32_MAX__ = @as(c_uint, 4294967295);
pub inline fn __FD_ELT(d: var) @TypeOf(d / __NFDBITS) {
    return d / __NFDBITS;
}
pub const WCONTINUED = 8;
pub const __WINT_MAX__ = @as(c_uint, 4294967295);
pub inline fn __builtin_nanf64x(x: var) @TypeOf(__builtin_nanl(x)) {
    return __builtin_nanl(x);
}
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __INTPTR_WIDTH__ = 64;
pub const __XSAVE__ = 1;
pub const __HAVE_FLOAT128X = 0;
pub const __BIG_ENDIAN = 4321;
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __RDSEED__ = 1;
pub const __ldiv_t_defined = 1;
pub const PTRDIFF_MAX = @as(c_long, 9223372036854775807);
pub inline fn UINT16_C(c: var) @TypeOf(c) {
    return c;
}
pub const __FLT_HAS_QUIET_NAN__ = 1;
pub const __corei7__ = 1;
pub const __BIGGEST_ALIGNMENT__ = 16;
pub const _BITS_STDINT_UINTN_H = 1;
pub const INT_LEAST32_MIN = -2147483647 - 1;
pub const __HAVE_FLOAT128 = 0;
pub const __XSAVEC__ = 1;
pub const INT8_MIN = -128;
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LDBL_MANT_DIG__ = 64;
pub inline fn be16toh(x: var) @TypeOf(__bswap_16(x)) {
    return __bswap_16(x);
}
pub const UINT_LEAST32_MAX = @as(c_uint, 4294967295);
pub const __UINT_FAST8_MAX__ = 255;
pub const __SIZEOF_SIZE_T__ = 8;
pub const __STDC_VERSION__ = @as(c_long, 201112);
pub const __BMI2__ = 1;
pub const __F16C__ = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = 1;
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = 1;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __SIZEOF_INT__ = 4;
pub const NULL = @intToPtr(?*c_void, 0);
pub const __TIMESIZE = __WORDSIZE;
pub inline fn va_end(ap: var) @TypeOf(__builtin_va_end(ap)) {
    return __builtin_va_end(ap);
}
pub const __UINT32_C_SUFFIX__ = U;
pub inline fn __f64(x: var) @TypeOf(x) {
    return x;
}
pub const __clock_t_defined = 1;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __INT_LEAST8_MAX__ = 127;
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = 0;
pub inline fn INT8_C(c: var) @TypeOf(c) {
    return c;
}
pub const __UINTMAX_FMTo__ = "lo";
pub const _SYS_TYPES_H = 1;
pub const __SIZEOF_WCHAR_T__ = 4;
pub const timeval = struct_timeval;
pub const timespec = struct_timespec;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const random_data = struct_random_data;
pub const drand48_data = struct_drand48_data;

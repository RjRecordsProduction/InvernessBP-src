import ida_bytes
import ida_funcs
import ida_segment
import ida_xref
import ida_ua
import ida_name
import ida_search
import idaapi
import idautils
import ida_idp
import ida_hexrays
import idc
import os

SIGNATURE = "FD 7B BE A9 F4 4F 01 A9 FD 03 00 91 F4 03 00 2A"
OUTPUT_FILE = os.path.join(os.getcwd(), "decrypted_strings.txt")

DEBUG = True

# -------------------------------------------------------
# Logging
# -------------------------------------------------------

def log(msg):
    if DEBUG:
        print(msg)

# -------------------------------------------------------
# Segment
# -------------------------------------------------------

def get_text_segment():
    for i in range(ida_segment.get_segm_qty()):
        seg = ida_segment.getnseg(i)
        if seg and ida_segment.get_segm_name(seg) == ".text":
            return seg
    return None

# -------------------------------------------------------
# Signature Scan
# -------------------------------------------------------

def find_signature(seg):
    results = []
    ea = seg.start_ea

    while ea < seg.end_ea:
        ea = ida_bytes.find_bytes(
            SIGNATURE,
            ea,
            range_end=seg.end_ea,
            flags=ida_search.SEARCH_DOWN,
            radix=16
        )
        if ea == idaapi.BADADDR:
            break

        results.append(ea)
        ea += 4

    return results

# -------------------------------------------------------
# Robust Blob Getter
# -------------------------------------------------------

def resolve_blob_getter():
    for func_ea in idautils.Functions():

        func = ida_funcs.get_func(func_ea)
        if not func:
            continue

        if func.end_ea - func.start_ea > 0x20:
            continue

        ea = func.start_ea
        insn1 = ida_ua.insn_t()
        insn2 = ida_ua.insn_t()

        if not ida_ua.decode_insn(insn1, ea):
            continue

        next_ea = ida_bytes.next_head(ea, func.end_ea)
        if not ida_ua.decode_insn(insn2, next_ea):
            continue

        m1 = ida_ua.print_insn_mnem(ea).lower()
        m2 = ida_ua.print_insn_mnem(next_ea).lower()

        # ADR X0, blob ; RET
        if m1 in ("adr", "adrl") and m2 == "ret":
            if idaapi.get_reg_name(insn1.ops[0].reg, 8).lower() == "x0":
                base = idc.get_operand_value(ea, 1)
                log(f"[+] Blob getter (ADR) @ {hex(func_ea)} → {hex(base)}")
                return base

        # ADRP X0, blob@PAGE
        if m1 == "adrp":
            if idaapi.get_reg_name(insn1.ops[0].reg, 8).lower() != "x0":
                continue

            page = idc.get_operand_value(ea, 1)

            next_ea = ida_bytes.next_head(ea, func.end_ea)
            if ida_ua.print_insn_mnem(next_ea).lower() == "add":
                off = idc.get_operand_value(next_ea, 2)
                base = page + off
                log(f"[+] Blob getter (ADRP+ADD) @ {hex(func_ea)} → {hex(base)}")
                return base

    return None

def resolve_blob_from_getter(getter_ea):

    func = ida_funcs.get_func(getter_ea)
    if not func:
        return None

    ea = func.start_ea
    insn = ida_ua.insn_t()

    while ea < func.end_ea:

        if ida_ua.decode_insn(insn, ea):

            mnem = ida_ua.print_insn_mnem(ea)
            if not mnem:
                ea = ida_bytes.next_head(ea, func.end_ea)
                continue

            mnem = mnem.lower()

            # ADR X0, blob
            if mnem in ("adr", "adrl"):
                return idc.get_operand_value(ea, 1)

            # ADRP X0, blob@PAGE
            if mnem == "adrp":
                page = idc.get_operand_value(ea, 1) & ~0xFFF

                next_ea = ida_bytes.next_head(ea, func.end_ea)
                if ida_ua.print_insn_mnem(next_ea) and \
                   ida_ua.print_insn_mnem(next_ea).lower() == "add":

                    off = idc.get_operand_value(next_ea, 2)
                    return page + off

        ea = ida_bytes.next_head(ea, func.end_ea)

    return None

def get_cipher_base_from_decryptor(func_ea):

    func = ida_funcs.get_func(func_ea)
    if not func:
        return None

    ea = func.start_ea
    first_call = None
    call_count = 0

    while ea < func.end_ea:

        insn = ida_ua.insn_t()
        if ida_ua.decode_insn(insn, ea):

            if idaapi.is_call_insn(insn):
                call_count += 1

                # FIRST BL = ciphertext getter
                if call_count == 1:
                    target = insn.ops[0].addr
                    return resolve_blob_from_getter(target)

        ea = ida_bytes.next_head(ea, func.end_ea)

    return None

# -------------------------------------------------------
# Robust W0 Extraction (MOVZ/MOVK supported)
# -------------------------------------------------------

def extract_w0(call_ea, seg_start):

    w0_val = 0
    found = False
    current = call_ea

    for _ in range(20):

        current = ida_bytes.prev_head(current, seg_start)
        if current == idaapi.BADADDR:
            break

        insn = ida_ua.insn_t()
        if ida_ua.decode_insn(insn, current) == 0:
            continue

        mnem = ida_ua.print_insn_mnem(current)
        if not mnem:
            continue

        mnem = mnem.lower()

        # stop if we hit another call
        if idaapi.is_call_insn(insn):
            break

        if insn.ops[0].type != ida_ua.o_reg:
            continue

        reg = idaapi.get_reg_name(insn.ops[0].reg, 4)
        if not reg:
            continue

        if reg.lower() != "w0":
            continue

        # MOV / MOVZ
        if mnem in ("mov", "movz"):
            if insn.ops[1].type == ida_ua.o_imm:
                w0_val = insn.ops[1].value
                found = True

        # MOVK (patch upper bits)
        elif mnem == "movk":
            if insn.ops[1].type == ida_ua.o_imm:

                shift_index = insn.ops[1].specflag1

                # ARM64 shift mapping
                if shift_index == 0:
                    shift = 0
                elif shift_index == 1:
                    shift = 16
                elif shift_index == 2:
                    shift = 32
                elif shift_index == 3:
                    shift = 48
                else:
                    shift = 0

                w0_val |= insn.ops[1].value << shift
                found = True

    if found:
        log(f"        [W0] Extracted offset: {hex(w0_val)}")

    return w0_val if found else None

# -------------------------------------------------------
# Robust Constant Extraction
# -------------------------------------------------------

class CipherVisitor(ida_hexrays.ctree_visitor_t):
    def __init__(self):
        super().__init__(ida_hexrays.CV_FAST)
        self.xor_const = None
        self.add_const = None

    def visit_expr(self, expr):

        if expr.op == ida_hexrays.cot_asg:
            rhs = expr.y

            if rhs.op == ida_hexrays.cot_add:

                # ADD constant
                if rhs.y.op == ida_hexrays.cot_num:
                    self.add_const = rhs.y.numval() & 0xFF

                # XOR inside
                if rhs.x.op == ida_hexrays.cot_xor:

                    if rhs.x.x.op == ida_hexrays.cot_num:
                        self.xor_const = rhs.x.x.numval() & 0xFF

                    elif rhs.x.y.op == ida_hexrays.cot_num:
                        self.xor_const = rhs.x.y.numval() & 0xFF

        return 0


def extract_constants(func_ea):

    if not ida_hexrays.init_hexrays_plugin():
        return None

    cfunc = ida_hexrays.decompile(func_ea)
    if not cfunc:
        return None

    visitor = CipherVisitor()
    visitor.apply_to(cfunc.body, None)

    if visitor.xor_const is None or visitor.add_const is None:
        return None

    log(f"[+] {hex(func_ea)} XOR={hex(visitor.xor_const)} ADD={hex(visitor.add_const)}")
    return visitor.xor_const, visitor.add_const

# -------------------------------------------------------
# Decryption
# -------------------------------------------------------

def decrypt_variant(base, offset, xor_imm, add_imm):

    seed = ida_bytes.get_byte(base + offset)
    length = ida_bytes.get_byte(base + offset + 1) ^ seed

    log(f"    [*] Seed={hex(seed)} Length={length}")

    if length == 0 or length > 0x400:
        log("    [-] Invalid length")
        return None

    enc = [
        ida_bytes.get_byte(base + offset + 2 + i)
        for i in range(length)
    ]

    k = seed
    out = []

    for i in range(length):
        plain = enc[i] ^ k
        out.append(plain & 0xFF)

        k = ((k + i) ^ xor_imm) + add_imm
        k &= 0xFF

    chk = 0xFF
    for b in out:
        chk ^= b

    check_byte = ida_bytes.get_byte(base + offset + 2 + length)

    if check_byte == (0xFF ^ chk ^ seed):
        try:
            decoded = bytes(out).decode("utf-8")
            log("    [+] Checksum OK (UTF-8)")
            return decoded
        except:
            log("    [+] Checksum OK (raw bytes)")
            return bytes(out)

    log("    [-] Checksum FAILED")
    return None
    
def set_pseudocode_comment(call_ea, text):

    if not ida_hexrays.init_hexrays_plugin():
        return

    func = ida_funcs.get_func(call_ea)
    if not func:
        return

    try:
        cfunc = ida_hexrays.decompile(func.start_ea)
    except ida_hexrays.DecompilationFailure:
        return

    tl = ida_hexrays.treeloc_t()
    tl.ea = call_ea
    tl.itp = ida_hexrays.ITP_SEMI  # comment at end of statement

    cfunc.set_user_cmt(tl, text)
    cfunc.save_user_cmts()
    cfunc.refresh_func_ctext()

# -------------------------------------------------------
# MAIN
# -------------------------------------------------------
def main():

    seg = get_text_segment()
    if not seg:
        print("[-] .text not found")
        return

    matches = find_signature(seg)
    print("[+] Found decryptors:", len(matches))

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:

        for func_ea in matches:

            print(f"\n[+] Processing decryptor: {hex(func_ea)}")

            # Extract XOR / ADD constants
            constants = extract_constants(func_ea)
            if not constants:
                print("    [-] Constants not found")
                continue

            xor_const, add_const = constants

            # Resolve ciphertext base (FIRST BL inside decryptor)
            cipher_base = get_cipher_base_from_decryptor(func_ea)
            if not cipher_base:
                print("    [-] Cipher base not resolved")
                continue

            print(f"    [+] Cipher base: {hex(cipher_base)}")

            # Find callers
            callers = []
            xref = ida_xref.get_first_cref_to(func_ea)

            while xref != idaapi.BADADDR:
                callers.append(xref)
                xref = ida_xref.get_next_cref_to(func_ea, xref)

            if not callers:
                print("    [-] No callers found")
                continue

            # Process each call site
            for call_ea in callers:

                log(f"\n    [>] Call site: {hex(call_ea)}")

                w0 = extract_w0(call_ea, seg.start_ea)
                if w0 is None:
                    log("        [-] W0 not found")
                    continue

                decrypted = decrypt_variant(cipher_base, w0, xor_const, add_const)
                if not decrypted:
                    continue
                    
                if isinstance(decrypted, bytes):
                    try:
                        comment_text = decrypted.decode("utf-8", errors="ignore")
                    except:
                        comment_text = repr(decrypted)
                else:
                    comment_text = str(decrypted)

                comment_text = f" {comment_text}"

                # Disassembly comment (keep this)
                ida_bytes.set_cmt(call_ea, comment_text, 1)

                # Pseudocode comment (new)
                set_pseudocode_comment(call_ea, comment_text)

                f.write(f"Function: {hex(func_ea)}\n")
                f.write(f"Call: {hex(call_ea)}\n")
                f.write(f"Offset: {hex(w0)}\n")
                f.write(f"XOR: {hex(xor_const)} ADD: {hex(add_const)}\n")
                f.write(f"Decrypted: {decrypted}\n")
                f.write("-" * 60 + "\n")

    print("\n[+] Dumped to:", OUTPUT_FILE)


if __name__ == "__main__":
    main()
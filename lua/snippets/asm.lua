local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node
local rep = require("luasnip.extras").rep

return {
	s("main", {
		t({ ".text", ".global main", "", "main:", "    " }), i(1), t({ "", "    ret" }), i(0),
	}),
	s("func", {
		t({ ".text", ".globl " }), i(1, "function_name"), t({ "", "" }),
		rep(1), t({ ":", "    " }), i(0, "ret"),
	}),
	s("label", { i(1, "label_name"), t({ ":", "    " }), i(0) }),
	s("section", { t({ ".section ." }), i(1, "text"), t({ "", "" }), i(0) }),
	s("data", { t({ ".data", "" }), i(0) }),
	s("bss", { t({ ".bss", "" }), i(0) }),
	s("rodata", {
		t({ ".section .rodata", "message:" }), t('.asciz "'), i(1, "Hello, world!"), t('"'), i(0),
	}),
	s("string", {
		i(1, "message"), t(":"), t('.asciz "'), i(2, "text"), t('"'), i(0),
	}),
	s("prologue", { t({ "push rbp", "mov rbp, rsp", "    " }), i(0) }),
	s("epilogue", { t({ "mov rsp, rbp", "pop rbp", "ret" }) }),
	s("call", { t("call "), i(1, "function_name"), i(0) }),
	s("syscall", { t({ "mov eax, " }), i(1, "syscall_number"), t({ "", "syscall" }), i(0) }),
	s("exit", { t({ "mov eax, 60", "mov edi, " }), i(1, "0"), t({ "", "syscall" }), i(0) }),
	s("cmp", { t("cmp "), i(1, "rax"), t(", "), i(2, "0"), t({ "", "je " }), i(3, "label"), i(0) }),
	s("loop", { t("mov rcx, "), i(1, "count"), t({ "", "loop_start:", "    " }), i(0), t({ "", "    loop loop_start" }) }),
	s("if", { t("cmp "), i(1, "rax"), t(", "), i(2, "0"), t({ "", "je " }), i(3, "if_end"), t({ "", "    " }), i(0), t({ "", "if_end:" }) }),
	s("movr", { t("mov "), i(1, "rax"), t(", "), i(0, "rbx") }),
	s("add", { t("add "), i(1, "rax"), t(", "), i(0, "1") }),
	s("sub", { t("sub "), i(1, "rsp"), t(", "), i(0, "8") }),
	s("jump", { t("jmp "), i(0, "label") }),
	s("align", { t(".balign "), i(1, "16"), t({ "", "" }), i(0) }),
	s("byte", { i(1, "value"), t(":"), t({ "", "    .byte " }), i(0, "0") }),
	s("quad", { i(1, "value"), t(":"), t({ "", "    .quad " }), i(0, "0") }),
	s("nasm_main", {
		t({ "section .text", "global _start", "", "_start:", "    " }),
		i(1, "mov rax, 60"), t({ "", "    mov rdi, 0", "    syscall" }), i(0),
	}),
	s("start_x86", {
		t({ ".intel_syntax noprefix", ".text", ".global _start", "", "_start:", "    " }),
		i(1, "mov eax, 60"), t({ "", "    mov edi, 0", "    syscall" }), i(0),
	}),
	s("arm64_start", {
		t({ ".text", ".global _start", "", "_start:", "    mov x0, #0", "    mov x8, #93", "    svc #0" }), i(0),
	}),
	s("arm64_func", { t(".global "), i(1, "function_name"), t({ "", "" }), rep(1), t({ ":", "    stp x29, x30, [sp, #-16]!", "    mov x29, sp", "    " }), i(0), t({ "", "    ldp x29, x30, [sp], #16", "    ret" }) }),
	s("arm64_syscall", { t("mov x8, #"), i(1, "syscall_number"), t({ "", "mov x0, #" }), i(2, "0"), t({ "", "svc #0" }), i(0) }),
	s("arm64_loop", { i(1, "loop"), t({ ":", "    " }), i(2, "instruction"), t({ "", "    subs x1, x1, #1", "    b.ne " }), rep(1), i(0) }),
	s("arm64_if", { t("cmp "), i(1, "x0"), t(", "), i(2, "#0"), t({ "", "    b.eq " }), i(3, "if_end"), t({ "", "    " }), i(0), t({ "", "if_end:" }) }),
}

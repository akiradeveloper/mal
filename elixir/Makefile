SRCS = step/step0_repl.exs step/step1_read_print.exs step/step2_eval.exs \
       step/step3_env.exs
SOURCES_BASE = lib/reader.ex lib/printer.ex lib/types.ex
SOURCES_LISP = lib/env.ex lib/core.ex
SOURCES = $(SOURCES_BASE) $(SOURCES_LISP)

stats: $(SOURCES)
	@wc $^
stats-lisp: $(SOURCES_LISP)
	@wc $^

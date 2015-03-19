SRCS = step0_repl.ex step1_read_print.ex
SOURCES_BASE = read.ex printer.ex
SOURCES_LISP =
SOURCES = $(SOURCES_BASE) $(SOURCES_LISP)

stats: $(SOURCES)
	@wc $^
stats-lisp: $(SOURCES_LISP)
	@wc $^

build:
	elixirc reader.ex
	elixirc printer.ex

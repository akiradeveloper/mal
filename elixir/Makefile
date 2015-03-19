SOURCE_BASE = read.ex printer.ex

SRCS = step0_repl.ex step1_read_print.ex
OTHER_SRCS = read.ex printer.ex

build:
	elixirc printer.ex
	elixirc reader.ex

step1_read_print: build
	elixir step1_read_print.ex
	
run:
	elixir step1_read_print.ex

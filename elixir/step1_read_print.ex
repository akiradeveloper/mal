import MAL.Reader
import MAL.Printer

defmodule MAL.Main do
  def read(str),
  do: MAL.Reader.read_str(str)

  def eval(ast, env),
  do: ast

  def print(exp),
  do: MAL.Printer.pr_str(exp)

  def rep(line),
  do: (read line) |> eval("") |> print

  def repl_loop do
    line = IO.gets "user> "
    # requires newline
    (rep line) |> IO.puts
    repl_loop
  end
end
MAL.Main.repl_loop()

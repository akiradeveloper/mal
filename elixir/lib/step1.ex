import MAL.Reader
import MAL.Printer

defmodule MAL.Step1 do
  def read(str),
  do: MAL.Reader.read_str(str)

  def eval(ast, env),
  do: ast

  def print(exp),
  do: MAL.Printer.pr_str(exp)

  def rep(line),
  do: (read line) |> eval("") |> print

  def main do
    line = IO.gets "user> "
    # requires newline
    (rep line) |> IO.puts
    main
  end
end

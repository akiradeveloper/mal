import MAL.Reader
import MAL.Printer

defmodule MAL.Step1 do
  def read(str),
  do: MAL.Reader.read_str(str)

  def eval(ast, env),
  do: ast

  def print(exp),
  do: MAL.Printer.pr_str(exp, true)

  def rep(line),
  do: (read line) |> eval("") |> print

  def main do
    line = IO.gets "user> "
    # requires newline
    try do
      (rep line) |> IO.puts
    rescue
      x -> IO.puts "runtime error"
    end
    main
  end
end

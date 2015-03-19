import MAL.Reader
import MAL.Printer

defmodule MAL.Main do
  def read(str), do: MAL.Reader.read_str(str)
  def eval(ast, env), do: ast
  def print(exp), do: MAL.Printer.pr_str(exp)
  def rep(line) do
    a = read line
    b = eval(a, "")
    IO.inspect b
    c = print b
    c
  end
  def repl_loop do
    line = IO.gets "user> "
    (rep line) |> IO.write
    repl_loop
  end
end
MAL.Main.repl_loop()

defmodule MAL.Main do
  def read(str), do: str
  def eval(ast, env), do: ast
  def print(exp), do: exp
  def rep(line), do: eval((read line), "") |> print
  def repl_loop do
    line = IO.gets "user> "
    IO.write (rep line)
    repl_loop
  end
end
MAL.Main.repl_loop()

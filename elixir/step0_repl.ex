defmodule MAL do
  def read(str), do: str
  def eval(ast, env), do: ast
  def print(exp), do: exp
  def rep(line), do: eval((read line), "") |> print

  def repl_loop do
    line = IO.gets "user> "
    rep line |> IO.write
    repl_loop
  end
end

MAL.repl_loop()

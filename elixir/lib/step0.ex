defmodule MAL.Step0 do
  def read(str), do: str
  def eval(ast, env), do: ast
  def print(exp), do: exp

  def rep(line),
  do: (read line) |> eval("") |> print

  def main do
    line = IO.gets "user> "
    IO.write (rep line)
    main
  end
end

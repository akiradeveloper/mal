import MAL.Reader
import MAL.Printer

defmodule MAL.Main do
  def repl_env, do: {
    '+' => fn a, b -> a + b,
  }

  def read(str), do: MAL.Reader.read_str(str)

  # :: ast
  def eval_ast(ast, env) do
    case ast do
      {:mal_symbol, name} ->
        # lookup
      {:mal_list, xs} ->
        {:mal_list, Enum.map(xs, fn x -> eval(x, env))}
      _ -> ast
    end
  end

  def eval(ast, env) do
  end

  def print(exp), do: MAL.Printer.pr_str(exp)
  def rep(line) do
    a = read line
    b = eval(a, "")
    c = print b
    c
  end
  def repl_loop do
    line = IO.gets "user> "
    # requires newline
    (rep line) |> IO.puts
    repl_loop
  end
end
MAL.Main.repl_loop()

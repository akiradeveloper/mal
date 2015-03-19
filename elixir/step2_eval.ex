import MAL.Reader
import MAL.Printer

defmodule MAL.Main do
  def int_binop(f) do
    fn args -> 
      [{:mal_number, x} | [{:mal_number, y} | []]] = args
      {:mal_number, f.(x, y)}
    end
  end

  def repl_env do
    %{
      "+" => int_binop(fn x, y -> x + y end),
      "-" => int_binop(fn x, y -> x - y end),
      "*" => int_binop(fn x, y -> x * y end),
      "/" => int_binop(fn x, y -> div(x, y) end)
    }
  end

  def read(str), do: MAL.Reader.read_str(str)

  def eval_ast(ast, env) do
    case ast do
      {:mal_symbol, name} ->
        case env[name] do
          nil -> raise ArgumentError, message: "symbol not found"
          x -> x
        end
      {:mal_list, xs} ->
        {:mal_list, Enum.map(xs, fn x -> eval(x, env) end)}
      _ -> ast
    end
  end

  def eval(ast, env) do
    IO.inspect ast
    case ast do
      {:mal_list, xs} ->
        l = eval_ast(ast, env)
        {:mal_list, [f | args]} = l
        f.(args)
      _ -> eval_ast(ast, env)
    end
  end

  def print(exp), do: MAL.Printer.pr_str(exp)
  def rep(line) do
    a = read line
    b = eval(a, repl_env)
    IO.inspect b
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

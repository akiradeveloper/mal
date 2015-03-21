import MAL.Reader
import MAL.Printer

defmodule MAL.Step2 do
  def lift_int_binop(f),
  do: fn {:mal_number, x}, {:mal_number, y} -> {:mal_number, f.(x, y)} end

  def repl_env do
    %{
      "+" => lift_int_binop(fn x, y -> x + y end),
      "-" => lift_int_binop(fn x, y -> x - y end),
      "*" => lift_int_binop(fn x, y -> x * y end),
      "/" => lift_int_binop(fn x, y -> div(x, y) end)
    }
  end

  def read(str),
  do: MAL.Reader.read_str(str)

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
        apply(f, args)
      _ -> eval_ast(ast, env)
    end
  end

  def print(exp),
  do: MAL.Printer.pr_str(exp)

  def rep(line),
  do: (read line) |> eval(repl_env) |> print

  def main do
    line = IO.gets "user> "
    # requires newline
    (rep line) |> IO.puts
    main
  end
end

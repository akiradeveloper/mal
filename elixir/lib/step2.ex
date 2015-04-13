import MAL.Reader
import MAL.Printer

defmodule MAL.Step2 do
  import MAL.Types

  def lift_int_binop(f),
  do: fn mal_int(value: x), mal_int(value: y) -> mal_int(value: f.(x, y)) end

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
      mal_symbol(value: name) -> env[name]
      mal_list(value: xs) -> mal_list(value: Enum.map(xs, fn x -> eval(x, env) end))
      _ -> ast
    end
  end

  def eval(ast, env) do
    # IO.inspect ast
    case ast do
      mal_list(value: xs) ->
        l = eval_ast(ast, env)
        mal_list(value: [f | args]) = l
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
    try do
      (rep line) |> IO.puts
    rescue
      x -> IO.puts "runtime error"
    end
    main
  end
end

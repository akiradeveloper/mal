import MAL.Reader
import MAL.Printer
import MAL.Env

defmodule MAL.Step3 do
  def lift_int_binop(f),
  do: fn {:mal_number, x}, {:mal_number, y} -> {:mal_number, f.(x, y)} end

  def repl_env do
    ops = %{
      "+" => lift_int_binop(fn x, y -> x + y end),
      "-" => lift_int_binop(fn x, y -> x - y end),
      "*" => lift_int_binop(fn x, y -> x * y end),
      "/" => lift_int_binop(fn x, y -> div(x, y) end)
    }
    Enum.reduce(Dict.to_list(ops), MAL.Env.new(),
      fn {k, op}, acc ->
        MAL.Env.set(acc, k, op)
        acc
      end)
  end

  def read(str),
  do: MAL.Reader.read_str(str)

  def eval_ast(ast, env) do
    case ast do
      {:mal_symbol, name} ->
        case MAL.Env.get(env, name) do
          nil -> raise ArgumentError, message: "#{name} not found"
          x -> x
        end
      {:mal_list, xs} ->
        {:mal_list, Enum.map(xs, fn x -> eval(x, env) end)}
      _ -> ast
    end
  end

  def eval(ast, env) do
    case ast do
      {:mal_list, xs} ->
        case hd(xs) do
          {:mal_symbol, "def!"} ->
            [_, {:mal_symbol, a}, b | _] = xs
            val = eval(b, env)
            MAL.Env.set(env, a, val)
            val
          {:mal_symbol, "let*"} ->
            let_env = MAL.Env.new(env)
            [_, {:mal_list, lets}, b | _] = xs
            # TODO list
            [{:mal_symbol, k}, v | _] = lets
            MAL.Env.set(let_env, k, v)
            eval(b, let_env)
          _ -> 
            l = eval_ast(ast, env)
            {:mal_list, [f | args]} = l
            apply(f, args)
        end
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

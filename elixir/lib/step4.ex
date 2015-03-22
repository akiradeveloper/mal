import MAL.Reader
import MAL.Printer
import MAL.Env

defmodule MAL.Step4 do
  def make_init_env do
    env = MAL.Env.new()
    Dict.to_list(MAL.Core.ns) |> Enum.each(
      fn {k, op} ->
        MAL.Env.set(env, k, op)
      end)
    env
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
            Enum.chunk(lets, 2) |> Enum.each(
              fn [{:mal_symbol, k}, v] ->
                MAL.Env.set(let_env, k, eval(v, let_env))
              end)
            eval(b, let_env)
          {:mal_symbol, "fn*"} ->
            [_, {:mal_list, params}, body | _] = xs
            fn args ->
              new_env = MAL.Env.new(env)
              Enum.zip(params, args) |> Enum.each(
                fn {{:mal_symbol, name}, expr} ->
                  MAL.Env.set(new_env, name, expr)
                end)
              eval(body, new_env)
            end
          _ -> 
            l = eval_ast(ast, env)
            {:mal_list, [f | args]} = l
            f.(args)
        end
      _ -> eval_ast(ast, env)
    end
  end

  def print(exp),
  do: MAL.Printer.pr_str(exp)

  def loop(env) do
    line = IO.gets "user> "
    (read line) |> eval(env) |> print |> IO.puts
    loop(env)
  end

  def main do
    env = make_init_env
    loop(env)
  end
end

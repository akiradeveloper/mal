import MAL.Reader
import MAL.Printer
import MAL.Env

defmodule MAL.Step3 do
  import MAL.Types

  def read(str),
  do: MAL.Reader.read_str(str)

  def eval_ast(ast, env) do
    case ast do
      mal_symbol(value: name) -> MAL.Env.get(env, name)
      mal_list(value: xs) -> mal_list(value: Enum.map(xs, fn x -> eval(x, env) end))
      _ -> ast
    end
  end

  def eval(ast, env) do
    case ast do
      mal_list(value: xs) ->
        case hd(xs) do
          mal_symbol(value: "def!") ->
            [_, mal_symbol(value: a), b | _] = xs
            val = eval(b, env)
            MAL.Env.set(env, a, val)
            val
          mal_symbol(value: "let*") ->
            let_env = MAL.Env.new(env)
            [_, lets, b | _] = xs
            Enum.chunk(to_list(lets), 2) |> Enum.each(
              fn [mal_symbol(value: k), v] ->
                MAL.Env.set(let_env, k, eval(v, let_env))
              end)
            eval(b, let_env)
          _ -> 
            l = eval_ast(ast, env)
            mal_list(value: [mal_func(value: f) | args]) = l
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
    env = MAL.Core.init_env
    loop(env)
  end
end

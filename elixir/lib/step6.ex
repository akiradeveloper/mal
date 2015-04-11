import MAL.Reader
import MAL.Printer
import MAL.Env
import MAL.Core
import MAL.Types

defmodule MAL.Step6 do
  @spec read(String.t) :: MAL.Types.t
  def read(str),
  do: MAL.Reader.read_str(str)

  def eval_ast(ast, env) do
    case ast do
      mal_symbol(value: name) ->
        case MAL.Env.get(env, name) do
          nil -> raise ArgumentError, message: "#{name} not found"
          x -> x
        end
      mal_list(value: xs) ->
        mal_list(value: Enum.map(xs, fn x -> eval(x, env) end))
      _ -> ast
    end
  end

  @spec eval_true?(MAL.Types.t, MAL.Env.t) :: boolean
  def eval_true?(ast, env) do
    case eval(ast, env) do
      mal_bool(value: false) -> false
      :mal_nil -> false
      _ -> true
    end
  end

  @spec eval(MAL.Types.t, MAL.Env.t) :: MAL.Types.t
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
          mal_symbol(value: "if") ->
            [_, pred, t_proc | f_proc] = xs
            if eval_true?(pred, env) do
              eval(t_proc, env)
            else
              case f_proc do
                [] -> :mal_nil
                [f] -> eval(f, env)
              end
            end
          mal_symbol(value: "do") ->
            mal_list(value: r) = eval_ast(mal_list(value: tl(xs)), env)
            r |> Enum.reverse |> hd # FIXME last
          mal_symbol(value: "fn*") ->
            [_, params, body | _] = xs
            fn args ->
              {binds, rest_param} = Enum.split_while(to_list(params), fn x ->
                x != mal_symbol(value: "&")
              end)
              {exprs, rest_args} = Enum.split(args, Enum.count(binds))
              new_env = MAL.Env.new(env)
              Enum.zip(to_list(params), args) |> Enum.each(
                fn {mal_symbol(value: name), expr} ->
                  MAL.Env.set(new_env, name, expr)
                end)
              case rest_param do
                [mal_symbol(value: "&"), mal_symbol(value: name)] -> MAL.Env.set(new_env, name, mal_list(value: rest_args))
                [] -> :ok
              end
              eval(body, new_env)
            end |> wrap_func
          _ -> 
            l = eval_ast(ast, env)
            mal_list(value: [mal_func(value: f) | args]) = l
            f.(args)
        end
      _ -> eval_ast(ast, env)
    end
  end

  @spec print(MAL.Types.t) :: String.t
  def print(exp),
  do: MAL.Printer.pr_str(exp)

  def loop(env) do
    line = IO.gets "user> "
    (read line) |> eval(env) |> print |> IO.puts
    loop(env)
  end

  def main do
    env = MAL.Core.init_env
    MAL.Env.set(env, "*ARGV*", mal_list(value: []))
    MAL.Env.set(env, "eval", fn [ast] -> eval(ast, env) end |> wrap_func)
    (read "(def! not (fn* (a) (if a false true)))") |> eval(env)
    (read "(def! load-file (fn* (f) (eval (read-string (str \"(do \"(slurp f) \")\")))))") |> eval(env)
    Stream.repeatedly(fn ->
      line = IO.gets "user> "
      (read line) |> eval(env) |> print |> IO.puts
    end) |> Stream.run
  end
end

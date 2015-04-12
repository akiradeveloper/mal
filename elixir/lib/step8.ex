import MAL.Reader
import MAL.Printer
import MAL.Env
import MAL.Core
import MAL.Types

defmodule MAL.Step8 do
  @spec read(String.t) :: MAL.Types.t
  def read(str),
  do: MAL.Reader.read_str(str)

  def quasiquote(ast) do
    case ast do
      {listlike, [mal_symbol(value: "unquote"), ast], _} when listlike in [:mal_list, :mal_vector] -> ast
      {listlike, [{:mal_list, [{:mal_symbol, "splice-unquote"}, head]} | tail], _} when listlike in [:mal_list, :mal_vector] ->
        mal_list(value: [mal_symbol(value: "concat"), head, quasiquote(mal_list(value: tail))])
      {listlike, [head | tail], _} when listlike in [:mal_list, :mal_vector] ->
        mal_list(value: [mal_symbol(value: "cons"), quasiquote(head), quasiquote(mal_list(value: tail))])
      _ -> mal_list(value: [mal_symbol(value: "quote"), ast])
    end
  end

  def eval_ast(ast, env) do
    case ast do
      mal_symbol(value: name) ->
        case MAL.Env.get(env, name) do
          :mal_nil -> raise ArgumentError, message: "#{name} not found"
          x -> x
        end
      mal_list(value: xs) ->
        mal_list(value: Enum.map(xs, fn x -> eval(x, env) end))
      _ -> ast
    end
  end

  defp is_macro_call(ast, env) do
    case ast do
      mal_list(value: [mal_symbol(value: name) | _]) ->
        case MAL.Env.get(env, name) do
          mal_func(is_macro: true) -> true
          mal_func(is_macro: false) -> false
          _ -> false
        end
      _ -> false
    end
  end

  defp macroexpand(ast, env) do
    if is_macro_call(ast, env) do
      case ast do
        mal_list(value: [mal_symbol(value: name) | args]) ->
          case MAL.Env.get(env, name) do
            mal_func(value: f) -> macroexpand(f.(args), env)
            _ -> ast
          end
        _  -> ast
      end
    else
      ast
    end
  end

  @spec eval(MAL.Types.t, MAL.Env.t) :: MAL.Types.t
  def eval(ast, env) do
    case macroexpand(ast, env) do
      mal_list(value: xs) ->
        case hd(xs) do
          mal_symbol(value: "def!") ->
            [_, mal_symbol(value: a), b | _] = xs
            val = eval(b, env)
            MAL.Env.set(env, a, val)
            val
          mal_symbol(value: "defmacro!") ->
            [_, mal_symbol(value: a), b | _] = xs
            val = eval(b, env)
            case val do
              mal_func(value: f) -> MAL.Env.set(env, a, mal_func(val, is_macro: true))
              _ -> raise ArgumentError, message: "defmacro! value must be a fn"
            end
          mal_symbol(value: "quote") ->
            [_, lst] = xs
            lst
          mal_symbol(value: "quasiquote") ->
            [_, lst] = xs
            eval((quasiquote lst), env)
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
            if to_bool(eval(pred, env)) do
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
            fn args -> # :: [MAL.Types.t]
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
          mal_symbol(value: "macroexpand") ->
            [_, lst] = xs
            macroexpand(lst, env)
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
      try do
        (read line) |> eval(env) |> print |> IO.puts
      rescue
        x -> IO.puts "error"
      end
    end) |> Stream.run
  end
end

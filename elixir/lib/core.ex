defmodule MAL.Core do
  import MAL.Types

  def lift_op1(f) do
    fn args ->
      [x | []] = args
      f.(x)
    end
  end

  def lift_op2(f) do
    fn args ->
      [x, y | []] = args
      f.(x, y)
    end
  end

  def lift_int_op2(f) do
    fn [mal_int(value: x), mal_int(value: y) | []] ->
      mal_int(value: f.(x, y))
    end
  end

  def lift_cmp_op2(f) do
    fn [mal_int(value: x), mal_int(value: y) | []] ->
      mal_bool(value: f.(x, y))
    end
  end

  # TODO should be more specific type
  @spec ns :: [{String.t, MAL.Types.mal_func}]
  def ns do
    %{
      "list" => fn xs -> mal_list(value: xs) end,
      "list?" =>
        fn v ->
          case v do
            [mal_list(value: _)] -> mal_bool(value: true)
            _ -> mal_bool(value: false)
          end
        end,
      "empty?" =>
        fn v ->
          case v do
            [mal_list(value: [])] -> mal_bool(value: true)
            [mal_vector(value: [])] -> mal_bool(value: true)
            _ -> mal_bool(value: false)
          end
        end,
      "count" =>
        fn [v] ->
          case v do
            mal_list(value: xs) -> mal_int(value: Enum.count(xs))
            mal_vector(value: xs) -> mal_int(value: Enum.count(xs))
            :mal_nil -> mal_int(value: 0)
          end
        end,
      "cons" =>
        fn [x, {listlike, xs, _}] when listlike in [:mal_list, :mal_vector] ->
          mal_list(value: [x | xs])
        end,
      "concat" =>
        fn xs ->
          mal_list(value: xs |> Enum.map(&(to_list(&1))) |> Enum.concat)
        end,
      ">" => lift_cmp_op2(fn x, y -> x > y end),
      ">=" => lift_cmp_op2(fn x, y -> x >= y end),
      "<" => lift_cmp_op2(fn x, y -> x < y end),
      "<=" => lift_cmp_op2(fn x, y -> x <= y end),
      "+" => lift_int_op2(fn x, y -> x + y end),
      "-" => lift_int_op2(fn x, y -> x - y end),
      "*" => lift_int_op2(fn x, y -> x * y end),
      "/" => lift_int_op2(fn x, y -> div(x, y) end),
      "=" =>
        fn [x, y] ->
          case {x, y} do
            {mal_list(value: xs), mal_vector(value: ys)} -> mal_bool(value: xs == ys)
            {mal_vector(value: xs), mal_list(value: ys)} -> mal_bool(value: xs == ys)
            {:mal_nil, :mal_nil} -> mal_bool(value: true)
            {{t1, v1}, {t2, v2}} -> mal_bool(value: (t1 == t2) and (v1 == v2))
            {{t1, v1, _}, {t2, v2, _}} -> mal_bool(value: (t1 == t2) and (v1 == v2))
            _ -> mal_bool(value: false)
          end
        end,
      "pr-str" =>
        fn xs ->
          mal_string(value: xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, true) end) |> Enum.join(" "))
        end,
      "str" =>
        fn xs ->
          mal_string(value: xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, false) end) |> Enum.join(""))
        end,
      "prn" =>
        fn xs ->
          xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, true) end) |> Enum.join(" ") |> IO.puts
          :mal_nil
        end,
      "println" =>
        fn xs ->
          xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, false) end) |> Enum.join("") |> IO.puts
          :mal_nil
        end,
      "read-string" =>
        fn [mal_string(value: x)] ->
          MAL.Reader.read_str(x)
        end,
      "slurp" =>
        fn [mal_string(value: x)] ->
          mal_string(value: File.read!(x))
        end
    } |> Dict.to_list |> Enum.map(fn {x, y} -> {x, mal_func(value: y)} end)
  end

  def init_env do
    env = MAL.Env.new()
    MAL.Core.ns |> Enum.each(
      fn {k, op} ->
        MAL.Env.set(env, k, op)
      end)
    env
  end
end

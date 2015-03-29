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
    fn [{:mal_int, x}, {:mal_int, y} | []] ->
      {:mal_int, f.(x, y)}
    end
  end

  def lift_cmp_op2(f) do
    fn [{:mal_int, x}, {:mal_int, y} | []] ->
      {:mal_bool, f.(x, y)} 
    end
  end

  # TODO should be more specific type
  @spec ns :: [{String.t, MAL.Types.mal_func}]
  def ns do
    %{
      "list" => fn xs -> {:mal_list, xs} end,
      "list?" =>
        fn v ->
          case v do
            [{:mal_list, _}] -> {:mal_bool, true}
            _ -> {:mal_bool, false}
          end
        end,
      "empty?" =>
        fn v ->
          case v do
            [{:mal_list, []}] -> {:mal_bool, true}
            _ -> {:mal_bool, false}
          end
        end,
      "count" =>
        fn [v] ->
          case v do
            {:mal_list, xs} -> {:mal_int, Enum.count(xs)}
            {:mal_nil} -> {:mal_int, 0}
          end
        end,
      "cons" =>
        fn [x, {type, xs}] when type in [:mal_list, :mal_vector] ->
          {:mal_list, [x | xs]}
        end,
      "concat" =>
        fn xs ->
          {:mal_list, xs |> Enum.map(&(to_list(&1))) |> Enum.concat}
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
          # FIXME with meta?
          case {x, y} do
            {{:mal_nil}, {:mal_nil}} -> {:mal_bool, true}
            {{t1, xs}, {t2, ys}} -> {:mal_bool, (t1 == t2) and (xs == ys)}
            _ -> {:mal_bool, false}
          end
        end,
      "pr-str" =>
        fn xs ->
          {:mal_string, xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, true) end) |> Enum.join(" ")}
        end,
      "str" =>
        fn xs ->
          {:mal_string, xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, false) end) |> Enum.join("")}
        end,
      "prn" =>
        fn xs ->
          xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, true) end) |> Enum.join(" ") |> IO.puts
          {:mal_nil}
        end,
      "println" =>
        fn xs ->
          xs |> Enum.map(fn x -> MAL.Printer.pr_str(x, false) end) |> Enum.join("") |> IO.puts
          {:mal_nil}
        end,
      "read-string" =>
        fn [{:mal_string, x}] ->
          MAL.Reader.read_str(x)
        end,
      "slurp" =>
        fn [{:mal_string, x}] ->
          {:mal_string, File.read!(x)}
        end
    } |> Dict.to_list |> Enum.map(fn {x, y} -> {x, wrap_func(y)} end)
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

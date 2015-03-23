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

  # TODO should be more specific type
  @spec ns :: %{}
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
      ">" => lift_int_op2(fn x, y -> x > y end),
      ">=" => lift_int_op2(fn x, y -> x >= y end),
      "<" => lift_int_op2(fn x, y -> x < y end),
      "<=" => lift_int_op2(fn x, y -> x <= y end),
      "+" => lift_int_op2(fn x, y -> x + y end),
      "-" => lift_int_op2(fn x, y -> x - y end),
      "*" => lift_int_op2(fn x, y -> x * y end),
      "/" => lift_int_op2(fn x, y -> div(x, y) end),
    } |> Dict.to_list |> Enum.map(fn {x, y} -> {x, wrap_func(y)} end)
  end
end

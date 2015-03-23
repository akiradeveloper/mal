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
      "list" => fn xs -> {:mal_list, xs} end |> wrap_func,
      "list?" =>
        fn v ->
          case v do
            [{:mal_list, _}] -> {:mal_true}
            _ -> {:mal_false}
          end
        end |> wrap_func,
      "+" => lift_int_op2(fn x, y -> x + y end) |> wrap_func,
      "-" => lift_int_op2(fn x, y -> x - y end) |> wrap_func,
      "*" => lift_int_op2(fn x, y -> x * y end) |> wrap_func,
      "/" => lift_int_op2(fn x, y -> div(x, y) end) |> wrap_func
    }
  end
end

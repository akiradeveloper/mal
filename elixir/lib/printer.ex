defmodule MAL.Printer do
  @spec pr_str(MAL.Types.t) :: String.t
  def pr_str(ast) do
    case ast do
      {:mal_func, _} -> "#<function>"
      {:mal_list, val} ->
        l = val |> Enum.map(&(pr_str(&1))) |> Enum.join(" ")
        "(" <> l <> ")"
      {:mal_vector, val} ->
        l = val |> Enum.map(&(pr_str(&1))) |> Enum.join(" ")
        "[" <> l <> "]"
      {:mal_int, val} -> to_string(val)
      {:mal_symbol, val} -> val
      {:mal_kw, val} -> ":#{val}"
      {:mal_bool, true} -> "true"
      {:mal_bool, false} -> "false"
      {:mal_nil} -> "nil"
      {:mal_string, val} -> "\"#{val}\""
    end
  end
end

IO.puts MAL.Printer.pr_str({:mal_func, 1})
IO.puts MAL.Printer.pr_str({:mal_int, 1})
IO.puts MAL.Printer.pr_str({:mal_list, [{:mal_int, 1},{:mal_int, 2}]})
IO.puts MAL.Printer.pr_str({:mal_vector, [{:mal_int, 1},{:mal_int, 2}]})

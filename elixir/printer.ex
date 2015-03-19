defmodule MAL do
  def pr_str(ast) do
    case ast do
      {:mal_list, val} -> "(" <> Enum.join(Enum.map(val, &(pr_str(&1))), ",") <> ")"
      {:mal_number, val} -> to_string(val)
      {:mal_symbol, val} -> val
    end
  end
end

IO.puts MAL.pr_str({:mal_list, [{:mal_int, 1},{:mal_int, 2}]})
IO.puts MAL.pr_str({:mal_int, 1})

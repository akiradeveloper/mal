defmodule MAL.Printer do
  def pr_str(ast) do
    case ast do
      {:mal_list, val} -> "(" <> Enum.join(Enum.map(val, &(pr_str(&1))), " ") <> ")"
      {:mal_number, val} -> to_string(val)
      {:mal_symbol, val} -> val
    end
  end
end

IO.puts MAL.Printer.pr_str({:mal_number, 1})
IO.puts MAL.Printer.pr_str({:mal_list, [{:mal_number, 1},{:mal_number, 2}]})

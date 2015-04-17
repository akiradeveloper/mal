defmodule MAL.Printer do
  import MAL.Types

  @spec pr_str(MAL.Types.t) :: String.t
  def pr_str(ast, pr \\ false) do
    case ast |> debug do
      mal_func(value: _) -> "#<function>"
      mal_list(value: xs) ->
        l = xs |> Enum.map(&(pr_str(&1, pr))) |> Enum.join(" ")
        "(" <> l <> ")"
      mal_vector(value: xs) ->
        l = xs |> Enum.map(&(pr_str(&1, pr))) |> Enum.join(" ")
        "[" <> l <> "]"
      mal_map(value: dict) ->
        l = dict |> Enum.map(fn {k, v} -> pr_str(k, pr)  <> " " <> pr_str(v, pr) end) |> Enum.join(" ")
        "{" <> l <> "}"
      mal_int(value: val) -> to_string(val)
      mal_symbol(value: val) -> val
      mal_kw(value: val) -> ":#{val}"
      mal_bool(value: true) -> "true"
      mal_bool(value: false) -> "false"
      :mal_nil -> "nil"
      mal_string(value: val) ->
        case pr do
          true -> "\"#{
            val |> debug |>
            to_char_list |> debug |>
            Enum.map(fn chr ->
                  case chr |> debug do
                    10 -> '\\n'  # \n
                    92 -> '\\\\' # \\
                    34 -> '\\\"' # \"
                    c -> c
                  end
                end)
            |> debug |> to_string
          }\""
          false -> val
        end
    end
  end
end

import MAL.Types
IO.puts MAL.Printer.pr_str(mal_func(value: 1))
IO.puts MAL.Printer.pr_str(mal_int(value: 1))
IO.puts MAL.Printer.pr_str(mal_list(value: [mal_int(value: 1),mal_int(value: 2)]))
IO.puts MAL.Printer.pr_str(mal_vector(value: [mal_int(value: 1),mal_int(value: 2)]))
IO.puts MAL.Printer.pr_str(mal_string(value: "akiradeveloper"))

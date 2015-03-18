# r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
# Regex.scan(r, "abc") |> IO.inspect
# Regex.scan(r, "123") |> IO.inspect
# Regex.scan(r, "(+ 1 2)") |> IO.inspect

defmodule MAL do
  def tokenizer(s) do
    r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    l = for [x, _] <- Regex.scan(r, s), do: x
    sz = Enum.map(l, fn x -> 1 end) |> Enum.sum # FIXME
    List.delete_at(l, sz - 1)
  end
end

MAL.tokenizer("(+ 1 2)") |> IO.inspect
MAL.tokenizer("(+ 2 (* 3 4))") |> IO.inspect

# r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
# Regex.scan(r, "abc") |> IO.inspect
# Regex.scan(r, "123") |> IO.inspect
# Regex.scan(r, "(+ 1 2)") |> IO.inspect

defmodule MAL do
  def tokenizer(s) do
    r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    l = for [x, _] <- Regex.scan(r, s), do: x
    # sz = Enum.map(l, fn x -> 1 end) |> Enum.sum # FIXME
    List.delete_at(l, Enum.count(l) - 1)
  end

  def read_str(s) do
    read_form(tokenizer(s))
  end

  # toks :: list of string
  def read_form(toks) do
    case toks do
      ["(", _] -> read_list(toks)
      [tok, _] -> read_atom(tok)
    end
  end

  # ((1),2) -> {:list, [{:list, [{:int, 1}]}, {:int, 2}]}
  def read_list(toks) do
  end

  # tok :: string
  def read_atom(tok) do
    cond do 
      Integer.parse(tok) != :error ->
        {:mal_number, elem(Integer.parse(tok), 0)}
      true -> tok
    end
  end
end

MAL.tokenizer("(+ 12 3)") |> IO.inspect
MAL.tokenizer("(+ 2 (* 3 4))") |> IO.inspect

MAL.read_atom("1") |> IO.inspect

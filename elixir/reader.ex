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
    elem(parse_form(toks), 0)
  end

  def parse_form(toks) do
    case toks do
      ["(" | _] -> parse_list(toks)
      [tok | _] -> parse_atom(toks)
    end
  end

  # ((1) 2) -> {{:list, [{:list, [{:int, 1}]}, {:int, 2}]}, []]}
  def parse_list(toks) do
    [_ | tl] = toks
    {:mal_list, elem(do_parse_list([], tl), 0)}
  end

  # :: {[ast], toks}
  def do_parse_list(acc, toks) do
    case toks do
      [")" | rest] -> 
        {acc, rest}
      true ->
        {ast, rest} = parse_form(toks)
        do_parse_list([ast | acc], rest)
    end
  end

  # 1 2) -> {{:int, 1}, ["2", ")"]}
  def parse_atom(toks) do
    [hd | rest] = toks
    tok = hd # FIXME trim
    ast = cond do 
      Integer.parse(tok) != :error ->
        {:mal_number, elem(Integer.parse(tok), 0)}
      true ->
        {:mal_symbol, tok}
    end
    {ast, rest}
  end
end

MAL.tokenizer("(+ 123 456)") |> IO.inspect
MAL.tokenizer("(+ 2 (* 3 4))") |> IO.inspect

MAL.parse_form(["(", ")"]) |> IO.inspect
MAL.parse_form(["(", "1", ")"]) |> IO.inspect
MAL.parse_form(["1", ")"]) |> IO.inspect
MAL.parse_form(["*", "1", "2", ")"]) |> IO.inspect

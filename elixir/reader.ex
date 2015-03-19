# r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
# Regex.scan(r, "abc") |> IO.inspect
# Regex.scan(r, "123") |> IO.inspect
# Regex.scan(r, "(+ 1 2)") |> IO.inspect

defmodule MAL.Reader do
  def tokenizer(s) do
    # IO.puts s
    r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    l = for [x, _] <- Regex.scan(r, s), do: x
    # sz = Enum.map(l, fn x -> 1 end) |> Enum.sum # FIXME
    List.delete_at(l, Enum.count(l) - 1) |> Enum.map (&(String.strip(&1)))
  end

  def read_str(s) do
    read_form(tokenizer(s))
  end

  # toks :: list of string
  def read_form(toks) do
    elem(parse_form(toks), 0)
  end

  def parse_form(toks) do
    # IO.inspect toks
    case toks do
      ["(" | _] -> parse_list(toks)
      [_ | _] -> parse_atom(toks)
    end
  end

  # ((1) 2) -> {{:list, [{:list, [{:int, 1}]}, {:int, 2}]}, []]}
  def parse_list(toks) do
    [_ | tl] = toks
    {a, b} = do_parse_list([], tl)
    {{:mal_list, Enum.reverse(a)}, b}
  end

  # :: {[ast], rest}
  def do_parse_list(acc, toks) do
    case toks do
      [")" | rest] -> {acc, rest}
      x -> 1
        {ast, rest} = parse_form(toks)
        # IO.inspect ast
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

# MAL.tokenizer("(+ 123 456)") |> IO.inspect
# MAL.tokenizer("(+ 2 (* 3 4))") |> IO.inspect

# MAL.parse_form(["(", ")"]) |> IO.inspect
# MAL.parse_form(["(", "1", ")"]) |> IO.inspect
# MAL.parse_form(["1", ")"]) |> IO.inspect
# MAL.parse_form(["*", "1", "2", ")"]) |> IO.inspect

MAL.Reader.read_str("()") |> IO.inspect
MAL.Reader.read_str("(1)") |> IO.inspect
MAL.Reader.read_str("(* 1 2)") |> IO.inspect
MAL.Reader.read_str("(* (* 1 2) 3)") |> IO.inspect
MAL.Reader.read_str("(f 1 2)") |> IO.inspect

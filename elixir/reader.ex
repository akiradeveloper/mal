# r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
# Regex.scan(r, "abc") |> IO.inspect
# Regex.scan(r, "123") |> IO.inspect
# Regex.scan(r, "(+ 1 2)") |> IO.inspect

defmodule MAL.Reader do
  def tokenizer(s) do
    r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    l = for [x, _] <- Regex.scan(r, s), do: x
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
    case toks do
      ["(" | _] -> parse_list(toks)
      [_ | _] -> parse_atom(toks)
    end
  end

  # :: {ast, rest}
  def parse_list(toks) do
    [_ | tl] = toks
    {ast, rest} = do_parse_list([], tl)
    {{:mal_list, Enum.reverse(ast)}, rest}
  end

  # :: {[ast], rest}
  def do_parse_list(acc, toks) do
    case toks do
      [")" | rest] -> {acc, rest}
      [_ | _] ->
        {ast, rest} = parse_form(toks)
        do_parse_list([ast | acc], rest)
    end
  end

  # :: {ast, rest}
  def parse_atom(toks) do
    [tok | rest] = toks
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

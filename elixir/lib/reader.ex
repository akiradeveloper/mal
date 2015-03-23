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

  @spec read_str(String.t) :: MAL.Types.t
  def read_str(s) do
    read_form(tokenizer(s))
  end

  def read_form(toks) do
    elem(parse_form(toks), 0)
  end

  def parse_form(toks) do
    case toks do
      ["(" | _] ->
        {ast, rest} = do_parse_list([], tl(toks))
        {{:mal_list, Enum.reverse(ast)}, rest}
      ["[" | _] -> parse_vector(toks)
        {ast, rest} = do_parse_list([], tl(toks))
        {{:mal_vector, Enum.reverse(ast)}, rest}
      [_ | _] -> parse_atom(toks)
    end
  end

  # :: {ast, rest}
  def parse_list(toks) do
  end

  def parse_vector(toks) do
  end

  @spec do_parse_list([MAL.Types.t], [String.t]) :: {[MAL.Types.t], [String.t]}
  def do_parse_list(acc, toks) do
    case toks do
      [")" | rest] -> {acc, rest}
      ["]" | rest] -> {acc, rest}
      [_ | _] ->
        {ast, rest} = parse_form(toks)
        do_parse_list([ast | acc], rest)
    end
  end

  @spec parse_atom([String.t]) :: {MAL.Types.t, [String.t]}
  def parse_atom(toks) do
    [tok | rest] = toks
    ast = cond do 
      Integer.parse(tok) != :error -> {:mal_int, elem(Integer.parse(tok), 0)}
      true -> case tok do
        "nil" -> :mal_nil
        "true" -> {:mal_bool, true}
        "false" -> {:mal_bool, false}
        _ -> case hd(to_char_list(tok)) do
          58 -> {:mal_kw, to_char_list(tok) |> tl |> to_string} # : = 58
          34 -> {:mal_string, tok |> String.strip(?\")} # " = 34
          _ -> {:mal_symbol, tok}
        end
      end
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

MAL.Reader.read_str("nil") |> IO.inspect
MAL.Reader.read_str(":hoge") |> IO.inspect
MAL.Reader.read_str("\"akiradeveloper\"") |> IO.inspect
MAL.Reader.read_str("()") |> IO.inspect
MAL.Reader.read_str("(1)") |> IO.inspect
MAL.Reader.read_str("(* 1 2)") |> IO.inspect
MAL.Reader.read_str("(* (* 1 2) 3)") |> IO.inspect
MAL.Reader.read_str("(f 1 2)") |> IO.inspect

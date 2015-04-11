defmodule MAL.Reader do
  import MAL.Types

  def tokenizer(s) do
    r = ~r/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    l = for [x, _] <- Regex.scan(r, s), do: x
    List.delete_at(l, Enum.count(l) - 1) |> Enum.map (&(String.strip(&1)))
  end

  @spec read_str(String.t) :: MAL.Types.t
  def read_str(s) do
    s |> tokenizer |> parse_form |> elem(0)
  end

  @spec parse_form([String.t]) :: {MAL.Types.t, [String.t]}
  def parse_form(toks) do
    case toks do
      ["'" | _] -> parse_quote("quote", tl(toks))
      ["`" | _] -> parse_quote("quasiquote", tl(toks))
      ["(" | _] ->
        {ast, rest} = parse_list([], tl(toks), ")")
        {mal_list(value: Enum.reverse(ast)), rest}
      ["[" | _] ->
        {ast, rest} = parse_list([], tl(toks), "]")
        {mal_vector(value: Enum.reverse(ast)), rest}
      [_ | _] -> parse_atom(toks)
    end
  end

  @spec parse_quote(String.t, [String.t]) :: {MAL.Types.t, [String.t]}
  def parse_quote(symbol, toks) do
    {tok, rest} = parse_form(toks)
    {mal_list(value: [mal_symbol(value: symbol), tok]), rest}
  end

  @spec parse_list([MAL.Types.t], [String.t], String.t) :: {[MAL.Types.t], [String.t]}
  def parse_list(acc, toks, closer) do
    case toks do
      [tok | rest] when tok == closer -> {acc, rest}
      [_ | _] ->
        {ast, rest} = parse_form(toks)
        parse_list([ast | acc], rest, closer)
    end
  end

  @spec parse_atom([String.t]) :: {MAL.Types.t, [String.t]}
  def parse_atom(toks) do
    [tok | rest] = toks
    ast = cond do 
      Integer.parse(tok) != :error -> mal_int(value: elem(Integer.parse(tok), 0))
      true -> case tok do
        "nil" -> :mal_nil
        "true" -> mal_bool(value: true)
        "false" -> mal_bool(value: false)
        _ -> case hd(to_char_list(tok)) do
          58 -> mal_kw(value: to_char_list(tok) |> tl |> to_string) # : = 58
          34 -> mal_string(value: tok |> String.strip(?\")) # " = 34
          _ -> mal_symbol(value: tok)
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

MAL.Reader.read_str("true") |> IO.inspect
MAL.Reader.read_str("false") |> IO.inspect
MAL.Reader.read_str("nil") |> IO.inspect
MAL.Reader.read_str(":hoge") |> IO.inspect
MAL.Reader.read_str("\"akiradeveloper\"") |> IO.inspect
MAL.Reader.read_str("()") |> IO.inspect
MAL.Reader.read_str("(1)") |> IO.inspect
MAL.Reader.read_str("(* 1 2)") |> IO.inspect
MAL.Reader.read_str("(* (* 1 2) 3)") |> IO.inspect
MAL.Reader.read_str("(f 1 2)") |> IO.inspect

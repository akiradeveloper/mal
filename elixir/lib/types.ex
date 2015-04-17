defmodule MAL.Types do

  def debug(s) do
    # s |> IO.inspect
    s
  end

  require Record
  Record.defrecord :mal_list, value: nil, meta: :mal_nil
  Record.defrecord :mal_vector, value: nil, meta: :mal_nil
  Record.defrecord :mal_map, value: nil, meta: :mal_nil
  Record.defrecord :mal_int, value: nil
  Record.defrecord :mal_bool, value: nil
  Record.defrecord :mal_kw, value: nil
  Record.defrecord :mal_func, value: nil, is_macro: false, meta: :mal_nil
  Record.defrecord :mal_symbol, value: nil, meta: :mal_nil
  Record.defrecord :mal_string, value: nil

  @type t ::
      mal_int
    | mal_kw
    | mal_nil
    | mal_bool
    | mal_list
    | mal_vector
    | mal_map
    | mal_string
    | mal_symbol
    | mal_func

  @type mal_nil :: :mal_nil
  @type mal_int :: record(:mal_int, value: integer)
  @type mal_symbol :: record(:mal_symbol, value: String.t, meta: t)
  @type mal_string :: record(:mal_string, value: String.t)
  @type mal_kw :: record(:mal_kw, value: String.t)
  @type mal_bool :: record(:mal_bool, value: boolean)
  @type mal_list :: record(:mal_list, value: [t], meta: t)
  @type mal_vector :: record(:mal_vector, value: [t], meta: t)
  @type mal_map :: record(:mal_map, value: [{t, t}], meta: t)
  @type mal_func :: record(:mal_func, value: func, is_macro: boolean, meta: t)
  @typep func :: ([t] -> t)

  @spec to_bool(t) :: boolean
  def to_bool(ast) do
    case ast do
      mal_bool(value: false) -> false
      :mal_nil -> false
      _ -> true
    end
  end

  @spec to_list(t) :: [t]
  def to_list(ast) do
    case ast do
      mal_list(value: xs) -> xs
      mal_vector(value: xs) -> xs
      _ -> raise ArgumentError, message: "type unmatch"
    end
  end

  @spec wrap_func(func) :: mal_func
  def wrap_func(f), do: mal_func(value: f)
end

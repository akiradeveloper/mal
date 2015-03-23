defmodule MAL.Types do

  @type t ::
      mal_int
    | mal_kw
    | mal_nil
    | mal_bool
    | mal_list
    | mal_vector
    | mal_string
    | mal_symbol
    | mal_func
    
  @type mal_nil :: {:mal_nil}
  @type mal_int :: {:mal_int, integer}
  @type mal_symbol :: {:mal_symbol, String.t}
  @type mal_string :: {:mal_string, String.t}
  @type mal_kw :: {:mal_kw, String.t}
  @type mal_bool :: {:mal_bool, boolean}
  @type mal_list :: {:mal_list, [t]}
  @type mal_vector :: {:mal_vector, [t]}
  @type mal_func :: {:mal_func, func}

  @typep func :: ([t] -> t)
 
  @spec wrap_func(func) :: mal_func
  def wrap_func(f),
  do: {:mal_func, f}

  @spec to_list(t) :: [t]
  def to_list(ast) do
    case ast do
      {:mal_list, xs} -> xs
      {:mal_vector, xs} -> xs
      _ -> raise ArgumentError, message: "type unmatch"
    end
  end
end

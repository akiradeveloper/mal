defmodule MAL.Types do
  def wrap_func(f),
  do: {:mal_func, f}

  def to_list(ast) do
    case ast do
      {:mal_list, xs} -> xs
      {:mal_vector, xs} -> xs
      _ -> raise ArgumentError, message: "type unmatch"
    end
  end
end

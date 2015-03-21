defmodule MAL.Env do
  # string -> ast
  defstruct data: %{}, outer: nil

  def do_set(env, k, v) do
    newdata = Dict.put(env.data, k, v)
    %{env | data: newdata}
  end

  # :: Env
  def do_find(env, k) do
    e = env.data[k]
    if e do
      env
    else
      find(env.outer, k)
    end
  end

  # :: value
  def do_get(env, k) do
    e = do_find(env, k)
    if e do
      e.data[k]
    else
      raise ArgumentError, message: "#{k} not found"
    end
  end

  def do_new(outer),
  do: %MAL.Env{outer: outer}

  def new(outer \\ nil) do
    {:ok, pid} = Agent.start_link(fn -> do_new(outer) end)
    pid
  end

  def set(pid, k, v),
  do: Agent.update(pid, fn env -> do_set(env, k, v) end)

  # :: Env
  def find(pid, k),
  do: Agent.get(pid, fn env -> do_find(env, k) end)

  def get(pid, k),
  do: Agent.get(pid, fn env -> do_get(env, k) end)
end

e1 = MAL.Env.new()
IO.inspect e1
MAL.Env.set(e1, "a", 1)
MAL.Env.get(e1, "a") |> IO.inspect

e2 = MAL.Env.new(e1)
IO.inspect e2
MAL.Env.set(e2, "b", 2)
MAL.Env.get(e2, "b") |> IO.inspect
MAL.Env.get(e2, "a") |> IO.inspect

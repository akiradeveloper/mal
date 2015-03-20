defmodule MAL.Env do
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
      env.outer.find[k]
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

  def new(outer) do
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

# e = MAL.Env.do_new(nil)
# e = MAL.Env.do_set(e, "a", 1)
# MAL.Env.do_get(e, "a") |> IO.inspect

pid = MAL.Env.new(nil)
MAL.Env.set(pid, "a", 1)
MAL.Env.get(pid, "a") |> IO.inspect

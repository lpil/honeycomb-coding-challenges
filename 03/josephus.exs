defmodule Soldier do
  use GenServer

  defstruct id: 0,
            count: 0,
            alive?: true

  def start_link(id, count) do
    state = %__MODULE__{id: id, count: count}
    {:ok, _pid} = GenServer.start_link(__MODULE__, state, name: :"soldier_#{id}")
  end

  def next_move(pid) do
    GenServer.cast(pid, :next_move)
  end

  def kill(pid, killer) do
    GenServer.cast(pid, {:kill_next, killer})
  end

  #
  # GenServer Callbacks
  #

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:next_move, %{id: id, alive?: true} = state) do
    state |> next_soldier() |> kill(id)
    {:noreply, state}
  end

  def handle_cast(:next_move, %{alive?: false} = state) do
    state |> next_soldier() |> next_move()
    {:noreply, state}
  end

  def handle_cast({:kill_next, n}, %{id: n, alive?: true} = state) do
    IO.puts "Soldier #{n} survived"
    send :game, :game_over
    {:noreply, state}
  end

  def handle_cast({:kill_next, _}, %{id: n, alive?: true} = state) do
    IO.puts "Soldier #{n} died"
    state |> next_soldier() |> next_move()
    {:noreply, %{state | alive?: false}}
  end

  def handle_cast({:kill_next, k}, state) do
    state |> next_soldier() |> kill(k)
    {:noreply, state}
  end


  #
  # Private
  #

  defp next_soldier(state) do
    :"soldier_#{rem(state.id + 1, state.count)}"
  end
end

defmodule Game do
  def start(count) do
    spawn fn-> init(count) end
  end

  defp init(count) do
    true = Process.register(self(), :game)
    for i <- 0..(count - 1) do
      {:ok, _pid} = Soldier.start_link(i, count)
    end

    :ok = Soldier.next_move(:soldier_0)
    receive do
      :game_over -> :ok
    end

    for i <- 0..(count - 1) do
      true = :"soldier_#{i}" |> Process.whereis() |> Process.exit(:kill)
    end
    Process.unregister(:game)
  end
end

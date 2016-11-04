
# Start this code with `mix run example/my_long_running_process.exs`

defmodule MyLongRunningProcess do
  use GenServer
  require Logger

  # Giving options here will change default values for `init_process_collector`.
  use GarbageMan.ProcessCollector, interval: 5_000

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.info "Starting MyLongRunningProcess process #{inspect self}"

    # But you HAVE to call the `init_process_collector` function!
#    :ok = init_process_collector(
#      # Trigger garbage collection every 10 Seconds.
#      interval: 10_000,
#      # Trigger garbage collection only, if there is 500MB occupied by binary memory.
#      memory_binary_max: 500_000_000,
#      # Log messages to debug level.
#      log_level: :debug
#    )

    {:ok, %{}}
  end
end

# Some code to start

{:ok, pid} = MyLongRunningProcess.start_link

# The `init_process_collector` function can also be called from the outside.
:ok = MyLongRunningProcess.init_process_collector(
  interval: 3_000,
  memory_binary_max: 10_000,
  pid: pid,
  log_level: :error
)

:timer.sleep(:infinity)

#  Output of this code:
#
#  11:15:43.038 [error] GarbageMan.ProcessCollector initialized for PID #PID<0.80.0>.
#
#  11:15:46.044 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> from binary memory: 96464.
#
#  11:15:46.044 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> to binary memory: 101152.
#
#  11:15:49.047 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> from binary memory: 101600.
#
#  11:15:49.048 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> to binary memory: 101768.
#
#  11:15:52.049 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> from binary memory: 102088.
#
#  11:15:52.050 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> to binary memory: 102216.
#
#  11:15:55.052 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> from binary memory: 102368.
#
#  11:15:55.052 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> to binary memory: 102496.
#
#  11:15:58.055 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> from binary memory: 102728.
#
#  11:15:58.055 [error] GarbageMan.ProcessCollector collecting process #PID<0.112.0> to binary memory: 102856.

defmodule GarbageMan.ProcessCollector do
  @moduledoc """
  Macros providing automatic garbage collection inside a long running process.

  You MUST call `init_process_collector` to start the periodic trigger. This can be done in `init` of your GenServer.
  Or you can call `init_process_collector` with opts = `[pid: #PID<0.215.0>]` from outside.

  The macro is accepting the same arguments as `init_process_collector` does, which can be used to provide default opts.

  Source for idea and background information:
  http://blog.bugsense.com/post/74179424069/erlang-binary-garbage-collection-a-lovehate

  Options:
  * `interval`:           Time in milliseconds between garbage collection checks.
  * `memory_binary_max`:  Amount of bytes above a garbe collect will be triggered. `nil` will always trigger.
  * `log_level`:          Loglevel used for logging (:debug, :info, :warn, :error). `nil` will disable.
  * `pid`:                Can be used to overwrite the process pid. Defaults to `self()`.
  """
  defmacro __using__(opts) do
    quote location: :keep do

      # Default values.
      @garbage_collect_default_opts [
        interval: 10_000,
        memory_binary_max: nil, # nil = every time ; 500_000_000 = 500MiB
        log_level: nil, # :debug, :info, :warn, :error or nil = not logging
        pid: nil, # Can be used to overwrite the process pid. Defaults to `self()`.
      ] |> Keyword.merge(unquote(opts))

      @doc """
      Will initialize garbage collection intervall using given options.
      Same options as __using__ offers.
      """
      def init_process_collector(opts \\ []) do
        :ok = @garbage_collect_default_opts
          |> Keyword.merge(opts)
          |> timing_next_garbage_collect
        log(opts, "GarbageMan.ProcessCollector initialized for PID #{inspect self}.")
        :ok
      end

      def handle_info({:garbage_collect, opts}, state) do

        memory_binary_max = opts[:memory_binary_max]
        memory_binary_current = :erlang.memory(:binary)

        :ok = cond do
          is_integer(memory_binary_max) and (memory_binary_max > 0) and (memory_binary_current > memory_binary_max) ->
            do_garbage_collect(self, opts)
          true ->
            :ok
        end

        :ok = timing_next_garbage_collect(opts)

        {:noreply, state}
      end

      # Creates a timer for next message according to given config.
      defp timing_next_garbage_collect(opts) do
        {:ok, _ref} = :timer.send_after(opts[:interval], get_pid(opts), {:garbage_collect, opts})
        :ok
      end

      # Performing garbage collection.
      defp do_garbage_collect(pid, opts) do
        log(opts, "GarbageMan.ProcessCollector collecting process #{inspect pid} from binary memory: #{inspect :erlang.memory(:binary)}.")
        :erlang.garbage_collect(pid)
        log(opts, "GarbageMan.ProcessCollector collecting process #{inspect pid} to binary memory: #{inspect :erlang.memory(:binary)}.")
        :ok
      end

      # Will log a message according to given options.
      defp log(opts, message) do
        require Logger
        case opts[:log_level] do
          nil -> :ok
          level when is_atom(level) ->
            Logger.log(level, "#{message}")
        end
      end

      # Will return pid from opts or the pid of current process.
      defp get_pid(opts) do
        case opts[:pid] do
          pid when is_pid(pid) -> pid
          _ -> self()
        end
      end

      defoverridable([
        init_process_collector: 1,
        handle_info: 2,
        timing_next_garbage_collect: 1,
        do_garbage_collect: 2,
        log: 2,
      ])
    end
  end
end


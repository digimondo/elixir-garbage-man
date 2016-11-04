# GarbageMan

Some code to trigger garbage collection in Erlang and Elixir.

## Installation

The package is published in hex.pm can be installed with:

  1. Add `garbage_man` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:garbage_man, "~> 0.1.0"}]
    end
    ```

  2. Ensure `garbage_man` is started before your application:

    ```elixir
    def application do
      [applications: [:garbage_man]]
    end
    ```

## Usage

### ProcessCollector

According to [this resource](http://blog.bugsense.com/post/74179424069/erlang-binary-garbage-collection-a-lovehate), 
  some long running processes can occupy a large amount of binary memory.
  
This module contains some Macros that try to handle that scenario.

See `example/my_long_running_process.exs` for demonstration code.

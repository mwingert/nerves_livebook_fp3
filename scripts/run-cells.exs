# Checks a notebook on the host: parses every Elixir cell, then evaluates, in notebook order,
# the cells whose source starts with one of the given prefixes. Stops at the first failure.
#
#   elixir scripts/run-cells.exs priv/samples/13_synth.livemd "defmodule Synth " "# Check:"
[path | prefixes] = System.argv()

cells = ~r/^```elixir\n(.*?)^```/ms |> Regex.scan(File.read!(path), capture: :all_but_first) |> Enum.map(&hd/1)
Enum.each(cells, &Code.string_to_quoted!(&1, file: path))

for cell <- cells, Enum.any?(prefixes, &String.starts_with?(cell, &1)) do
  IO.puts("running: #{cell |> String.split("\n") |> hd()}")
  Code.eval_string(cell, [], file: path)
end

IO.puts("ok: #{length(cells)} cells parsed")

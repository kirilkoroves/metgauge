defmodule Metgauge.Util.Random do
  # Omit 0 for clarity
  @alphabet Enum.concat([?1..?9, ?A..?Z])

  def randstring(count) do
    Stream.repeatedly(&random_char_from_alphabet/0)
    |> Enum.take(count)
    |> List.to_string()
  end

  defp random_char_from_alphabet() do
    Enum.random(@alphabet)
  end
end

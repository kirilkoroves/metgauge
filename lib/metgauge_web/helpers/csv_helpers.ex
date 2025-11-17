defmodule Metgauge.Helpers.CSVHelpers do
  def results_to_csv(results, headers, opts \\ []) do
    results
    |> results_to_csv_row_list(headers, opts)
    |> Enum.join()
  end

  def results_to_csv_row_list(results, headers, opts \\ []) do
    include_header_row? = Keyword.get(opts, :include_header_row?, true)
    date_format = Keyword.get(opts, :date_format, "%Y-%m-%d")
    timezone = Keyword.get(opts, :timezone, "UTC")
    initial_state = if include_header_row?, do: [headers], else: []

    Enum.reduce(results, initial_state, fn result, acc ->
      acc ++ [convert_datetime_fields(result, date_format, timezone)]
    end)
    |> quote_multiline_fields()
    |> convert_datetime_fields(date_format, timezone)
    |> CSV.encode()
    |> Enum.to_list()
    |> add_newlines_back()
  end

  defp quote_multiline_fields(row_list) when is_list(row_list) do
    compiled_pattern = :binary.compile_pattern(["\n", "\r"])
    mapper = &quote_multiline_field(&1, compiled_pattern)

    Enum.map(row_list, &Enum.map(&1, mapper))
  end


  def convert_datetime_fields(result_row, date_format, timezone) do
    Enum.map(result_row, fn(cell) ->
      IO.inspect(cell)
      case cell do
        {_y, _m, _d} ->
          Date.from_erl!(cell)
          |> Timex.format!(date_format, :strftime)
        {{y,m,d}, {h,min,s}} ->
          NaiveDateTime.from_erl!({{y,m,d}, {h,min,s}})
          |> DateTime.from_naive!("Etc/UTC")
          |> Timex.to_datetime(timezone)
          |> Timex.format!("#{date_format} %H:%M:%S", :strftime)

        {{y,m,d}, {h,min,s,_ms}} ->
          NaiveDateTime.from_erl!({{y,m,d}, {h,min,s}})
          |> DateTime.from_naive!("Etc/UTC")
          |> Timex.to_datetime(timezone)
          |> Timex.format!("#{date_format} %H:%M:%S", :strftime)
        other -> other
      end
    end)
  end

  defp quote_multiline_field(binary, compiled_pattern) when is_binary(binary) do
    if String.contains?(binary, compiled_pattern) do
      "\"#{binary}\""
    else
      binary
    end
  end

  defp quote_multiline_field(term, _compiled_pattern), do: term

  defp add_newlines_back(binary_list) when is_list(binary_list) do
    Enum.map(binary_list, fn binary ->
      binary
      |> String.replace("\"\"\"", "\"")
      |> String.replace("\\r", "\r")
      |> String.replace("\\n", "\n")
    end)
  end
end

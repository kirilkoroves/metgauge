defmodule MetgaugeWeb.Helpers.StringHelpers do
  def to_camel_case(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> to_camel_case()
    |> String.to_atom()
  end

  def to_camel_case(string) when is_binary(string) do
    Recase.to_camel(string)
  end

  def to_camel_case(any), do: any

  def to_tsquery_string(search_string) do
    search_string
    |> String.split()
    |> Enum.uniq()
    |> Enum.join(" & ")
  end

  def to_ilike_search_strings(search_string) do
    search_string
    |> String.split()
    |> Enum.uniq()
    |> Enum.map(fn str -> "%#{str}%" end)
  end

  def to_single_ilike_search_string(search_string) do
    joined_string =
      search_string
      |> String.split()
      |> Enum.join("%")

    "%#{joined_string}%"
  end

  def strip(value) when is_binary(value), do: String.trim(value)
  def strip(%Decimal{} = value), do: to_string(value) |> String.trim()
  def strip(value), do: value
end

defmodule Metgauge.Helpers.ModelHelpers do
  @doc """
  Gets the humanized field name given a changeset and field name. First checks if there
  is a definition of a humanized field on the model, otherwise defaults to using the
  Phoenix `humanize/1` function to humanize the field.

  ## Example
  """
  def get_humanized_field(_changeset, field), do: Phoenix.Naming.humanize(field)

  def remove_unloaded_assocs(%{__meta__: _meta} = ecto_struct) do
    for(
      {key, value} <- Map.from_struct(ecto_struct),
      key != :__meta__ and not is_unloaded(value),
      do: {key, remove_unloaded_assocs(value)}
    )
    |> Map.new()
  end

  def remove_unloaded_assocs(list) when is_list(list) do
    Enum.map(list, &remove_unloaded_assocs/1)
  end

  def remove_unloaded_assocs(other), do: other

  def is_unloaded(%Ecto.Association.NotLoaded{}), do: true
  def is_unloaded(_), do: false

  def convert_to_integer(value) when is_binary(value) do
    with {number, _remainder} <- Integer.parse(value) do
      number
    else
      _ -> nil
    end
  end

  def convert_to_integer(""), do: nil
  def convert_to_integer(value) when is_integer(value), do: value

  def to_positive_number(value) do
    converted_value = convert_to_integer(value)

    if converted_value >= 0 do
      converted_value
    else
      nil
    end
  end
end

defmodule Metgauge.Helpers.ChangesetHelpers do
  alias Metgauge.Helpers.ModelHelpers

  @models_for_transfer_changeset_error ~w()a

  def changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{String.capitalize(to_string(k))} #{joined_errors}<br/>"
    end)
  end

  def changeset_error_to_array(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce([], fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      acc ++ [%{field: to_string(k), message: joined_errors}]
    end)
  end

  def get_formatted_error(%Ecto.Changeset{errors: changeset_errors} = changeset, field_atom)
      when is_list(changeset_errors) and length(changeset_errors) > 0 and is_atom(field_atom) do
    humanized_field = ModelHelpers.get_humanized_field(changeset, field_atom)
    changeset_error = Keyword.fetch(changeset_errors, field_atom)

    case changeset_error do
      {:ok, {error_message, validation_data}} when is_binary(error_message) ->
        format_error_message(humanized_field, error_message, validation_data)

      _ ->
        get_formatted_error(nil, humanized_field, humanized_field)
    end
  end

  def get_formatted_error(
        %Ecto.Changeset{errors: changeset_errors} = changeset,
        field_atom,
        transferred_field_atom
      )
      when is_list(changeset_errors) and length(changeset_errors) > 0 and is_atom(field_atom) and
             is_atom(transferred_field_atom) do
    humanized_field = ModelHelpers.get_humanized_field(changeset, transferred_field_atom)
    changeset_error = Keyword.fetch(changeset_errors, field_atom)

    case changeset_error do
      {:ok, {error_message, validation_data}} when is_binary(error_message) ->
        format_error_message(humanized_field, error_message, validation_data)

      _ ->
        get_formatted_error(nil, humanized_field, humanized_field)
    end
  end

  def get_formatted_error(_changeset, _field, transferred_field_atom) do
    "#{transferred_field_atom} contains an unknown error."
  end

  defp format_error_message(
         humanized_field,
         error_message,
         [additional: validation_data] = _additional
       )
       when is_binary(humanized_field) and is_binary(error_message) and is_list(validation_data) do
    format_error_message(humanized_field, error_message, validation_data)
  end

  defp format_error_message(humanized_field, error_message, validation_data)
       when is_binary(humanized_field) and is_binary(error_message) and is_list(validation_data) do
    error_message_with_replacements =
      Enum.reduce(validation_data, error_message, fn {key, value}, error_message ->
        String.replace(error_message, "%{#{key}}", to_string(value))
      end)

    format_error_message(humanized_field, error_message_with_replacements, nil)
  end

  defp format_error_message(humanized_field, error_message, _validation_data) do
    "#{humanized_field} #{error_message}."
  end

  def remove_nils(%Ecto.Changeset{changes: changes} = changeset) do
    Enum.reduce(changes, changeset, fn
      {field, nil}, changeset -> Ecto.Changeset.delete_change(changeset, field)
      {_field, _value}, changeset -> changeset
    end)
  end

  def remove_nils(changeset, _allowed_fields), do: changeset

  def transfer_changeset_error_to_field(operation_atom, field_atom) do
    if operation_atom in @models_for_transfer_changeset_error do
      operation_atom
    else
      field_atom
    end
  end
end

defmodule MetgaugeWeb.Helpers.EnumHelpers do
  alias MetgaugeWeb.Helpers.{StringHelpers}

  @spec first_with_default(list(item_type), default_type) :: item_type | default_type
        when item_type: var, default_type: var
  def first_with_default(list, default) do
    case list do
      [_head | _tail] = _non_empty_list ->
        List.first(list)

      _ ->
        default
    end
  end

  @doc """
  Sorts `list_of_maps` to match the order of the `list_of_ids`

      iex> list_of_maps = [%{id: 456}, %{id: 123}, %{id: 789}]
      [%{id: 456}, %{id: 123}, %{id: 789}]
      iex> list_of_ids = [123, 456, 789]
      list_of_ids = [123, 456, 789]
      iex> EnumHelpers.match_order_by_ids(list_of_maps, list_of_ids)
      [%{id: 123}, %{id: 456}, %{id: 789}]
  """
  def match_order_by_ids(list_of_maps, list_of_ids, id_field \\ :id) do
    maps_by_id = mapify_map_list(list_of_maps, id_field)

    Enum.reduce(list_of_ids, [], fn id, acc ->
      maps_by_id
      |> Map.fetch(id)
      |> case do
        {:ok, item} ->
          acc ++ [item]

        _ ->
          acc
      end
    end)
  end

  @doc """
  Converts string keys into atoms one level deep.

      iex(1)> map = %{"outer" => %{"inner" => "value"}}
      %{"outer" => %{"inner" => "value"}}
      iex(2)> EnumHelpers.atomize_keys(map)
      %{outer: %{"inner" => "value"}}
  """
  @spec atomize_keys(%{any() => any()}) :: %{atom() => any()}
  def atomize_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: atomize_kv(key, value)
  end

  defp atomize_kv(key, value) when is_binary(key), do: {String.to_atom(key), value}
  defp atomize_kv(key, value) when is_atom(key), do: {key, value}
  defp atomize_kv(key, value), do: {String.to_atom(inspect(key)), value}

  @doc """
  Converts atom keys into strings one level deep.

      iex> map = %{outer: %{"inner" => "value"}}
      %{outer: %{"inner" => "value"}}
      iex> EnumHelpers.stringify_keys(map)
      %{"outer" => %{"inner" => "value"}}
  """
  @spec stringify_keys(%{any() => any()}) :: %{binary() => any()}
  def stringify_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{}, do: stringify_kv(key, value)
  end

  defp stringify_kv(key, value) when is_binary(key), do: {key, value}
  defp stringify_kv(key, value) when is_atom(key), do: {Atom.to_string(key), value}
  defp stringify_kv(key, value), do: {inspect(key), value}

  @doc """
  Converts a list of maps into a map where the keys of the resulting map come from the value of
  the maps in the list. If the value is duplicated, the last occurrence will be selected.

  Compare to Enum.group_by/2, for which the values are a list:

      iex(1)> list = [%{id: 5}, %{id: 6}, %{id: 7}, %{id: 7, key: "dupe"}]
      [%{id: 5}, %{id: 6}, %{id: 7}, %{id: 7, key: "dupe"}]
      iex(2)> Enum.group_by(list, &Map.get(&1, :id))
      %{5 => [%{id: 5}], 6 => [%{id: 6}], 7 => [%{id: 7}, %{id: 7, key: "dupe"}]}
      iex(3)> EnumHelpers.mapify_map_list(list, :id)
      %{5 => %{id: 5}, 6 => %{id: 6}, 7 => %{id: 7, key: "dupe"}}
  """
  def mapify_map_list([], _), do: %{}

  def mapify_map_list(list, fun) when is_function(fun, 1) do
    list |> Map.new(fn item -> {fun.(item), item} end)
  end

  def mapify_map_list(list, field) when is_list(list) do
    list |> Map.new(fn item -> {Map.get(item, field), item} end)
  end

  @doc """
  Converts a map to keyword list. Differs to the default Enum.into(%{} = map, []) in that it will convert
  string keys into atoms.

      iex(1)> EnumHelpers.to_kw_list(%{"key"=>value})
      [{:key, value}]
  """
  def to_kw_list(%{} = map) do
    Enum.into(map, [], &to_kw_list_mapper/1)
  end

  defp to_kw_list_mapper({key, value}) when is_atom(key), do: {key, value}
  defp to_kw_list_mapper({key, value}) when is_binary(key), do: {String.to_atom(key), value}

  @doc """
  Merges a subset of map2's values into the corresponding keys of map1. Useful when only some of the
  values of map2 should be merged.

  Compare to Map.merge/2, which adds all the keys/values from map2:

      iex(1)> map1 = %{a: 1, b: 2, c: 3}
      %{a: 1, b: 2, c: 3}
      iex(2)> map2 = %{a: 42, d: 4, e: 5}
      %{a: 42, d: 4, e: 5}
      iex(3)> Map.merge(map1, map2)
      %{a: 42, b: 2, c: 3, d: 4, e: 5}
      iex(4)> EnumHelpers.merge_map_fields(map1, map2, [:a])
      %{a: 42, b: 2, c: 3}
      iex(5)> EnumHelpers.merge_map_fields(map1, map2, [:a, :d])
      %{a: 42, b: 2, c: 3, d: 4}
  """
  def merge_map_fields(map1, map2, _fields) when map1 == %{} and map2 == %{}, do: %{}
  def merge_map_fields(%{} = map1, %{} = _map2, []), do: map1

  def merge_map_fields(%{} = map1, %{} = map2, field) when not is_list(field) do
    merge_map_fields(map1, map2, [field])
  end

  def merge_map_fields(%{} = map1, %{} = map2, fields) when is_list(fields) do
    Map.merge(map1, Map.take(map2, fields))
  end

  @doc """
  Finds an item in a list of maps by key and value.
  """
  def find_by(list, key, value) when is_list(list) do
    Enum.find(list, fn
      %{} = list_item ->
        Map.get(list_item, key) == value

      _ ->
        false
    end)
  end

  @doc """
  Filters a list of maps by key and value.
  """
  def filter_by(list, key, value) when is_list(list) do
    Enum.filter(list, fn
      %{} = list_item ->
        Map.get(list_item, key) == value

      _ ->
        false
    end)
  end

  @doc """
  Finds whether a map is a member of a list of maps by looking at a single key only.

      iex(1)> list = [%{id: 1}, %{id: 2}, %{id: 3}]
      [%{id: 1}, %{id: 2}, %{id: 3}]
      iex(2)> item = %{id: 2, key: "value"}
      %{id: 2, key: "value"}
      iex(3)> Enum.member?(list, item)
      false
      iex(4)> EnumHelpers.member_by_key?(list, item, :id)
      true
  """
  def member_by_key?(list, %{} = item, key) when is_list(list) do
    Enum.find(list, fn list_item -> Map.get(list_item, key) == Map.get(item, key) end) != nil
  end

  @doc """
  Gets the `value` for a given key for all maps in the list by mapping over the list.

  ## Example

      iex> list = [%{id: 1}, %{id: 2}, %{id: 3}]
      [%{id: 1}, %{id: 2}, %{id: 3}]
      iex> EnumHelpers.extract_values(list, :id)
      [1, 2, 3]
  """
  @spec extract_values(list(map()), any(), keyword()) :: list(any())
  def extract_values(list, key, opts \\ []) when is_list(list) do
    unique? = Keyword.get(opts, :unique, false)

    return_list =
      Enum.map(list, fn
        %{} = item ->
          Map.get(item, key)

        _ ->
          nil
      end)

    if unique?, do: Enum.uniq(return_list), else: return_list
  end

  def reject_nils(list) when is_list(list) do
    Enum.reject(list, &is_nil/1)
  end

  def reject_nils(%{} = map) do
    for {key, value} when not is_nil(value) <- map, into: %{}, do: {key, value}
  end

  def convert_string_keys_to_int(map) when is_map(map) do
    convert_string_keys_to_int(map, %{})
  end

  def convert_string_keys_to_int(list) when is_list(list) do
    convert_string_keys_to_int(list, [])
  end

  def convert_string_keys_to_int(enum, into) do
    for {string_key, value} <- enum, into: into, do: {String.to_integer(string_key), value}
  end

  def reverse_sort(list) when is_list(list) do
    Enum.sort(list, &Kernel.>=/2)
  end

  @doc """
  Converts map keys to camelCase recursively. Only nested plain maps are mapped recursively.
  Nested structs are not altered.
  """
  def convert_keys_to_camel_case(%_module{} = struct_map) do
    struct_map
    |> Map.from_struct()
    |> convert_keys_to_camel_case()
  end

  def convert_keys_to_camel_case(%{} = non_struct_map) do
    Enum.reduce(non_struct_map, %{}, fn {key, value}, acc ->
      case value do
        %_module{} = nested_struct ->
          Map.put(acc, StringHelpers.to_camel_case(key), nested_struct)

        %{} = nested_plain_map ->
          Map.put(
            acc,
            StringHelpers.to_camel_case(key),
            convert_keys_to_camel_case(nested_plain_map)
          )

        _ ->
          Map.put(acc, StringHelpers.to_camel_case(key), value)
      end
    end)
  end

  @doc """
  Filters a list of maps to be unique by a particular key.

  ## Example

      iex> list_of_maps = [%{a: 1, b: "one"}, %{a: 2, b: "two"}, %{a: 1, b: "three"}]
      [%{a: 1, b: "one"}, %{a: 2, b: "two"}, %{a: 1, b: "three"}]
      iex> EnumHelpers.uniq_by_key(list_of_maps, :a)
      [%{a: 1, b: "one"}, %{a: 2, b: "two"}]
  """
  def uniq_by_key(list_of_maps, key) when is_list(list_of_maps) do
    Enum.uniq_by(list_of_maps, fn
      %{} = map ->
        Map.get(map, key)

      _ ->
        nil
    end)
  end

  @doc """
  Sorts a list of maps by an arbitrary field. Default order is `:asc`.

  **Note: this is not suitable for sorting by a DateTime field, please use `sort_by_datetime_field/2` or
  `sort_by_datetime_field/3` instead!**

  ## Options

      - order: :asc or :desc

  ## Example

      iex> list_of_maps = [%{id: 3}, %{id: 1}, %{id: 2}]
      iex> EnumHelpers.sort_by_field(list_of_maps, :id)
      [%{id: 1}, %{id: 2}, %{id: 3}]
      iex> EnumHelpers.sort_by_field(list_of_maps, :id, order: :asc)
      [%{id: 1}, %{id: 2}, %{id: 3}]
      iex> EnumHelpers.sort_by_field(list_of_maps, :id, order: :desc)
      [%{id: 3}, %{id: 2}, %{id: 1}]
  """
  def sort_by_field(list_of_maps, field, opts \\ []) do
    order = Keyword.get(opts, :order, :asc)

    sort_func =
      case order do
        :desc ->
          &>=/2

        _ ->
          &<=/2
      end

    Enum.sort_by(list_of_maps, &Map.get(&1, field), sort_func)
  end

  @doc """
  Sorts a list of maps by a datetime field. Default order is `:asc`.

  ## Options

      - order: :asc or :desc

  ## Example

      iex> list_of_maps_with_datetime_field = [%{dt: %DateTime{...}}, %{dt: ...}, ...}]
      [%{...}]
      iex> EnumHelpers.sort_by_datetime_field(list_of_maps_with_datetime_field, :dt)
      [%{...}]
      iex> EnumHelpers.sort_by_datetime_field(list_of_maps_with_datetime_field, :dt, order: :asc)
      [%{...}]
      iex> EnumHelpers.sort_by_datetime_field(list_of_maps_with_datetime_field, :dt, order: :desc)
      [%{...]]
  """
  def sort_by_datetime_field(list_of_maps, field, opts \\ [])
      when is_list(list_of_maps) and is_list(opts) do
    order = Keyword.get(opts, :order, :asc)

    sort_func =
      case order do
        :desc ->
          fn a, b -> not Timex.before?(a, b) end

        _ ->
          fn a, b -> not Timex.after?(a, b) end
      end

    Enum.sort_by(list_of_maps, &Map.get(&1, field), sort_func)
  end

  @doc """
  Selects a random element from the enumerable or returns a default value. Compare to `Enum.random/1` that
  has the potential to `raise` if passed an empty enumerable.
  """
  def random(enumerable, default \\ nil) do
    if Enum.empty?(enumerable) do
      default
    else
      Enum.random(enumerable)
    end
  end
end

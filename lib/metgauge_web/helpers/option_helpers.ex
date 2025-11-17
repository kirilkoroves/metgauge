defmodule MetgaugeWeb.Helpers.OptionHelpers do

  def timezone_options() do 
    zones = Tzdata.canonical_zone_list() |> Enum.filter(&(!String.starts_with?(&1, "Etc/")))
    optionify(["Asia/Tokyo", "Asia/Taipei", "Asia/Hong_Kong", "Asia/Macau"] ++ (zones -- ["Asia/Tokyo", "Asia/Taipei", "Asia/Hong_Kong", "Asia/Macau"]))
  end

  def optionify(opts), do: Enum.map(opts, fn opt -> %{ key: opt, value: opt } end)

end

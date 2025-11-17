defmodule MetgaugeWeb.MovesView do
  use MetgaugeWeb, :view

  def get_thumb(image_url) do
    ext = Path.extname(image_url)
    "#{image_url |> String.replace(ext, "")}_thumb#{ext}"
  end
end

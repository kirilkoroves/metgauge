defmodule MetgaugeWeb.Helpers.Util do

  def pretty_atom(atom) do
    atom
    |> Atom.to_string
    |> String.replace("_", " ")
    |> String.capitalize
  end

end

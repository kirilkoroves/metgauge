defmodule Metgauge.Repo.Migrations.UniqueClientName do
  use Ecto.Migration

  def change do
    create unique_index(:clients, [:name], where: "deleted_at IS NULL")
  end
end

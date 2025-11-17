defmodule Metgauge.Repo.Migrations.AddProfileRole do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :role, :string, null: false, default: "user"
    end
  end
end

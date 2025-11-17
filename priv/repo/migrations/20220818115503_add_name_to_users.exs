defmodule Metgauge.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :firstname, :string
      add :lastname, :string
    end
  end
end

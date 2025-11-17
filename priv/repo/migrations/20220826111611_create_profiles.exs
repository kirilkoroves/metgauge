defmodule Metgauge.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :handle, :string, null: false, default: ""
      add :first_name, :string, null: false, default: ""
      add :last_name, :string, null: false, default: ""
      add :about, :text, null: false, default: ""
      add :timezone, :string, null: false, default: ""
      add :languages, :jsonb, null: false, default: "[]"
    end

    create unique_index(:profiles, [:handle], where: "handle != ''")
  end
end

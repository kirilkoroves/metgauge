defmodule Metgauge.Repo.Migrations.AddClientSlug do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :slug, :string
    end
  end
end

defmodule Metgauge.Repo.Migrations.AddClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :logo, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :customer_email, :string
      add :customer_phone, :string
      add :address, :string
      add :deleted_at, :utc_datetime
      timestamps()
    end

    alter table(:users) do
      add :client_id, references(:clients, on_delete: :delete_all)
    end
  end
end

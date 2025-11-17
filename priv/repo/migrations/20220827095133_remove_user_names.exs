defmodule Metgauge.Repo.Migrations.RemoveUserNames do
  use Ecto.Migration

  def change do
    alter table "users" do
      remove :firstname, :string
      remove :lastname, :string
      remove :name, :string
    end
  end
end

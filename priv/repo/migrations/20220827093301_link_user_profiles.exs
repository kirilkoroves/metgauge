defmodule Metgauge.Repo.Migrations.LinkUserProfiles do
  use Ecto.Migration

  def up do
    alter table :profiles do
      add :user_id, references(:users)
    end

    create unique_index(:profiles, [:user_id])

    execute """
    INSERT INTO profiles (user_id, first_name, last_name)
    SELECT id, COALESCE(firstname, ''), COALESCE(lastname, '') FROM users
    """, ""

    alter table :profiles do
      modify :user_id, :bigint, null: false
    end
  end

  def down do
    alter table :profiles do
      remove :user_id, :bigint
    end

    execute "DELETE FROM profiles"

  end
end

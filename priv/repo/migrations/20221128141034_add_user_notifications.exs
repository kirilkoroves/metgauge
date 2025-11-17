defmodule Metgauge.Repo.Migrations.AddUserNotifications do
  use Ecto.Migration

  def change do
    create table(:user_notifications) do
      add :type, :string, default: "notification"
      add :profile_id, references(:profiles, on_delete: :delete_all)
      add :content, :string
      add :is_answered, :boolean, default: false
      add :link, :string
      timestamps()
    end
  end
end

defmodule Metgauge.Repo.Migrations.AddAvatarPathCoverPathToProfileTable do
  use Ecto.Migration

  def change do
    alter table :profiles do
      add :original_avatar_path, :text
      add :avatar_path, :text
      add :cover_path, :text
    end
  end
end

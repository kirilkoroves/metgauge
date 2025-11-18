defmodule Metgauge.Accounts.Client do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
      field :name, :string
      field :address, :string
      field :logo, :string
      field :city, :string
      field :state, :string
      field :zip, :string
      field :customer_email, :string
      field :customer_phone, :string
      field :deleted_at, :utc_datetime
      field :slug, :string, autogenerate: {Metgauge.Util.Random, :randstring, [6]}
      timestamps()
  end

  def changeset(move, attrs) do
    move
    |> cast(attrs, [:name, :address, :logo, :city, :state, :zip, :customer_email, :customer_phone, :deleted_at])
    |> validate_required([:name, :address, :city])
    |> validate_email()
    |> unique_constraint(:name, name: "clients_name_index")
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:customer_email, ~r/^[^\s]+@[^\s]+$/, message: "Email must have @ and no space")
    |> validate_length(:customer_email, max: 255)
  end
end
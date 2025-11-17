defmodule Metgauge.ProfilesFixtures do
  require Logger

  def unique_handle, do: "handle#{System.unique_integer()}"

  def valid_attributes(attrs \\ %{}) do
    handle = unique_handle()
    Enum.into(attrs, %{
          handle: handle,
          first_name: "first #{ handle }",
          last_name: "last #{ handle }",
          links: [
            %{ type: :social,
               service: "facebook",
               identity: "facebook #{ handle }" },
            %{ type: :social,
               service: "instagram",
               identity: "instagram #{ handle }" },
            %{ type: :meeting,
               service: "zoom",
               identity: "zoom #{ handle }" },
          ],
          skills: ["Elixir", "Tailwind", "Unit Tests"]
    })
  end

  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> valid_attributes()
      |> Metgauge.Profiles.add_profile()

    profile
  end
end

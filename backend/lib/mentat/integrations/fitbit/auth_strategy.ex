defmodule Mentat.Integrations.Fitbit.AuthStrategy do
  use Assent.Strategy.OAuth2.Base

  @impl true
  def default_config(_config) do
    [
      base_url: "https://api.fitbit.com",
      authorize_url: "https://www.fitbit.com/oauth2/authorize",
      token_url: "/oauth2/token",
      user_url: "/1/user/-/profile.json",
      authorization_params: [
        scope:
          "profile activity heartrate nutrition oxygen_saturation respiratory_rate settings sleep temperature weight"
      ],
      auth_method: :client_secret_basic
    ]
  end

  @impl true
  def normalize(_config, user) do
    {:ok,
     %{
       "sub" => user["id"],
       "given_name" => user["firstName"],
       "family_name" => user["lastName"],
       "picture" => user["avatar"]
     }}
  end
end

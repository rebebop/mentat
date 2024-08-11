defmodule Mentat.Integrations.Fitbit.AuthStrategy do
  alias Assent.Strategy.OAuth2
  alias Mentat.Integrations
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

  def api_request(user_id, method, url) do
    with {:ok, provider} <-
           Integrations.Selectors.Provider.find_provider_by_name(:fitbit, user_id) do
      token = %{
        "access_token" => provider.token,
        "token_type" => provider.token_type
      }

      OAuth2.request(
        default_config(%{}),
        token,
        method,
        "/1/user/#{provider.provider_uid}/#{url}"
      )
    end
  end
end

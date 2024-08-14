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

  def api_request(url, user_id, method, version \\ 1) do
    with {:ok, provider} <-
           Integrations.Selectors.Provider.find_provider_by_name(:fitbit, user_id),
         {:ok, access_token} <- maybe_refresh_token(provider) do
      token = %{
        "access_token" => access_token,
        "token_type" => provider.token_type
      }

      OAuth2.request(
        default_config(%{}),
        token,
        method,
        "/#{version}/user/#{provider.provider_uid}/#{url}"
      )
    end
  end

  def maybe_refresh_token(provider) do
    if DateTime.compare(provider.expires_at, DateTime.utc_now()) == :lt do
      {:ok, new_token} =
        OAuth2.refresh_access_token(current_config(), %{
          "refresh_token" => provider.refresh_token
        })

      Integrations.save_provider(provider.name, provider.user_id, %{
        token: new_token["access_token"],
        expires_at: DateTime.add(DateTime.utc_now(), new_token["expires_in"], :second),
        refresh_token: new_token["refresh_token"]
      })

      {:ok, new_token["access_token"]}
    else
      {:ok, provider.token}
    end
  end

  def current_config() do
    default_config(%{})
    |> Keyword.merge(Application.get_env(:mentat, :strategies)[:fitbit])
  end
end

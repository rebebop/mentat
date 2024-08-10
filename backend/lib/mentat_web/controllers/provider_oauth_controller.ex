defmodule MentatWeb.ProviderOAuthController do
  alias Mentat.Integrations
  use MentatWeb, :controller

  def request(conn, %{"provider" => provider_str}) do
    # TODO: make sure to do a string to atom fix here
    provider = String.to_atom(provider_str)

    config = config!(provider)

    config[:strategy].authorize_url(config)
    |> case do
      {:ok, %{url: url, session_params: session_params}} ->
        conn = put_session(conn, :session_params, session_params)

        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(
          500,
          "Something went wrong generating the request authorization url: #{inspect(error)}"
        )
    end
  end

  def callback(conn, params) do
    session_params = get_session(conn, :session_params)
    provider = params["provider"] |> String.to_atom()

    config = config!(provider)

    config
    |> Assent.Config.put(:session_params, session_params)
    |> config[:strategy].callback(params)
    |> case do
      {:ok, %{user: _user, token: oauth_response}} ->
        setup_provider(
          %{name: provider, user_id: conn.assigns.current_user.id},
          oauth_response,
          Integrations.find_provider_by_name(provider, conn.assigns.current_user.id)
        )

        conn
        |> Phoenix.Controller.redirect(to: "/")

      {:error, error} ->
        # Authorizaiton failed
        IO.inspect(error, label: "error")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, inspect(error, pretty: true))
    end
  end

  defp config!(provider) do
    Application.get_env(:mentat, :strategies)[provider] ||
      raise "No provider configuration for #{provider}"
  end

  defp setup_provider(_provider_attrs, oauth_provider, {:ok, provider}) do
    Integrations.update_provider(provider, %{
      token: oauth_provider["access_token"],
      expires_at: DateTime.add(DateTime.utc_now(), oauth_provider["expires_in"], :second),
      refresh_token: oauth_provider["refresh_token"],
      provider_uid: oauth_provider["user_id"]
    })
  end

  defp setup_provider(provider_attrs, oauth_provider, {:error, %Ecto.NoResultsError{}}) do
    Integrations.add_provider(%{
      name: provider_attrs[:name],
      status: :enabled,
      user_id: provider_attrs[:user_id],
      token: oauth_provider["access_token"],
      expires_at: DateTime.add(DateTime.utc_now(), oauth_provider["expires_in"], :second),
      refresh_token: oauth_provider["refresh_token"],
      provider_uid: oauth_provider["user_id"]
    })
  end
end

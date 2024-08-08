defmodule MentatWeb.ProviderAuthController do
  use MentatWeb, :controller

  alias Assent.Config

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
      {:ok, %{user: user, token: token}} ->
        # Authorization succesful
        IO.inspect({user, token}, label: "user and token")

        conn
        |> put_session(:fitbit_user, user)
        |> put_session(:fitbit_user_token, token)
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
    config =
      Application.get_env(:mentat, :strategies)[provider] ||
        raise "No provider configuration for #{provider}"

    Config.put(config, :redirect_uri, "http://localhost:4000/auth/#{provider}/callback")
  end
end

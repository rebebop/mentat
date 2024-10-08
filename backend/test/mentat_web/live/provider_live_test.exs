defmodule MentatWeb.ProviderLiveTest do
  use MentatWeb.ConnCase

  import Phoenix.LiveViewTest
  import Mentat.IntegrationsFixtures

  @create_attrs %{label: "some label", name: "some name", status: :enabled}
  @update_attrs %{label: "some updated label", name: "some updated name", status: :disabled}
  @invalid_attrs %{label: nil, name: nil, status: nil}

  defp create_provider(_) do
    provider = provider_fixture()
    %{provider: provider}
  end

  describe "Index" do
    setup [:create_provider]

    test "lists all providers", %{conn: conn, provider: provider} do
      {:ok, _index_live, html} = live(conn, ~p"/providers")

      assert html =~ "Listing Providers"
      assert html =~ provider.label
    end

    test "saves new provider", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/providers")

      assert index_live |> element("a", "New Provider") |> render_click() =~
               "New Provider"

      assert_patch(index_live, ~p"/providers/new")

      assert index_live
             |> form("#provider-form", provider: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#provider-form", provider: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/providers")

      html = render(index_live)
      assert html =~ "Provider created successfully"
      assert html =~ "some label"
    end

    test "updates provider in listing", %{conn: conn, provider: provider} do
      {:ok, index_live, _html} = live(conn, ~p"/providers")

      assert index_live |> element("#providers-#{provider.id} a", "Edit") |> render_click() =~
               "Edit Provider"

      assert_patch(index_live, ~p"/providers/#{provider}/edit")

      assert index_live
             |> form("#provider-form", provider: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#provider-form", provider: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/providers")

      html = render(index_live)
      assert html =~ "Provider updated successfully"
      assert html =~ "some updated label"
    end

    test "deletes provider in listing", %{conn: conn, provider: provider} do
      {:ok, index_live, _html} = live(conn, ~p"/providers")

      assert index_live |> element("#providers-#{provider.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#providers-#{provider.id}")
    end
  end

  describe "Show" do
    setup [:create_provider]

    test "displays provider", %{conn: conn, provider: provider} do
      {:ok, _show_live, html} = live(conn, ~p"/providers/#{provider}")

      assert html =~ "Show Provider"
      assert html =~ provider.label
    end

    test "updates provider within modal", %{conn: conn, provider: provider} do
      {:ok, show_live, _html} = live(conn, ~p"/providers/#{provider}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Provider"

      assert_patch(show_live, ~p"/providers/#{provider}/show/edit")

      assert show_live
             |> form("#provider-form", provider: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#provider-form", provider: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/providers/#{provider}")

      html = render(show_live)
      assert html =~ "Provider updated successfully"
      assert html =~ "some updated label"
    end
  end
end

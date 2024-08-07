defmodule MentatWeb.ActivityRecordLiveTest do
  use MentatWeb.ConnCase

  import Phoenix.LiveViewTest
  import Mentat.ActivitiesFixtures

  @create_attrs %{value: "120.5", details: %{}, start_time: "2024-08-06T13:58:00Z", end_time: "2024-08-06T13:58:00Z", tags: ["option1", "option2"], measuring_scale: :duration}
  @update_attrs %{value: "456.7", details: %{}, start_time: "2024-08-07T13:58:00Z", end_time: "2024-08-07T13:58:00Z", tags: ["option1"], measuring_scale: :duration}
  @invalid_attrs %{value: nil, details: nil, start_time: nil, end_time: nil, tags: [], measuring_scale: nil}

  defp create_activity_record(_) do
    activity_record = activity_record_fixture()
    %{activity_record: activity_record}
  end

  describe "Index" do
    setup [:create_activity_record]

    test "lists all activity_records", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/activity_records")

      assert html =~ "Listing Activity records"
    end

    test "saves new activity_record", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/activity_records")

      assert index_live |> element("a", "New Activity record") |> render_click() =~
               "New Activity record"

      assert_patch(index_live, ~p"/activity_records/new")

      assert index_live
             |> form("#activity_record-form", activity_record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activity_record-form", activity_record: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activity_records")

      html = render(index_live)
      assert html =~ "Activity record created successfully"
    end

    test "updates activity_record in listing", %{conn: conn, activity_record: activity_record} do
      {:ok, index_live, _html} = live(conn, ~p"/activity_records")

      assert index_live |> element("#activity_records-#{activity_record.id} a", "Edit") |> render_click() =~
               "Edit Activity record"

      assert_patch(index_live, ~p"/activity_records/#{activity_record}/edit")

      assert index_live
             |> form("#activity_record-form", activity_record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activity_record-form", activity_record: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activity_records")

      html = render(index_live)
      assert html =~ "Activity record updated successfully"
    end

    test "deletes activity_record in listing", %{conn: conn, activity_record: activity_record} do
      {:ok, index_live, _html} = live(conn, ~p"/activity_records")

      assert index_live |> element("#activity_records-#{activity_record.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#activity_records-#{activity_record.id}")
    end
  end

  describe "Show" do
    setup [:create_activity_record]

    test "displays activity_record", %{conn: conn, activity_record: activity_record} do
      {:ok, _show_live, html} = live(conn, ~p"/activity_records/#{activity_record}")

      assert html =~ "Show Activity record"
    end

    test "updates activity_record within modal", %{conn: conn, activity_record: activity_record} do
      {:ok, show_live, _html} = live(conn, ~p"/activity_records/#{activity_record}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Activity record"

      assert_patch(show_live, ~p"/activity_records/#{activity_record}/show/edit")

      assert show_live
             |> form("#activity_record-form", activity_record: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#activity_record-form", activity_record: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/activity_records/#{activity_record}")

      html = render(show_live)
      assert html =~ "Activity record updated successfully"
    end
  end
end

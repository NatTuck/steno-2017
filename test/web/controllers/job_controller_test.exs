defmodule Steno.Web.JobControllerTest do
  use Steno.Web.ConnCase

  alias Steno.Grading
  alias Steno.Grading.Job

  @create_attrs %{gra_file: "some gra_file", output: "some output", state: 42, sub_file: "some sub_file"}
  @update_attrs %{gra_file: "some updated gra_file", output: "some updated output", state: 43, sub_file: "some updated sub_file"}
  @invalid_attrs %{gra_file: nil, output: nil, state: nil, sub_file: nil}

  def fixture(:job) do
    {:ok, job} = Grading.create_job(@create_attrs)
    job
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, job_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "creates job and renders job when data is valid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, job_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "gra_file" => "some gra_file",
      "output" => "some output",
      "state" => 42,
      "sub_file" => "some sub_file"}
  end

  test "does not create job and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, job_path(conn, :create), job: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen job and renders job when data is valid", %{conn: conn} do
    %Job{id: id} = job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, job_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "gra_file" => "some updated gra_file",
      "output" => "some updated output",
      "state" => 43,
      "sub_file" => "some updated sub_file"}
  end

  test "does not update chosen job and renders errors when data is invalid", %{conn: conn} do
    job = fixture(:job)
    conn = put conn, job_path(conn, :update, job), job: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen job", %{conn: conn} do
    job = fixture(:job)
    conn = delete conn, job_path(conn, :delete, job)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, job_path(conn, :show, job)
    end
  end
end

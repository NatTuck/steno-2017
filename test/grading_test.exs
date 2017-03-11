defmodule Steno.GradingTest do
  use Steno.DataCase

  alias Steno.Grading
  alias Steno.Grading.Job

  @create_attrs %{gra_file: "some gra_file", output: "some output", state: 42, sub_file: "some sub_file"}
  @update_attrs %{gra_file: "some updated gra_file", output: "some updated output", state: 43, sub_file: "some updated sub_file"}
  @invalid_attrs %{gra_file: nil, output: nil, state: nil, sub_file: nil}

  def fixture(:job, attrs \\ @create_attrs) do
    {:ok, job} = Grading.create_job(attrs)
    job
  end

  test "list_jobs/1 returns all jobs" do
    job = fixture(:job)
    assert Grading.list_jobs() == [job]
  end

  test "get_job! returns the job with given id" do
    job = fixture(:job)
    assert Grading.get_job!(job.id) == job
  end

  test "create_job/1 with valid data creates a job" do
    assert {:ok, %Job{} = job} = Grading.create_job(@create_attrs)
    
    assert job.gra_file == "some gra_file"
    assert job.output == "some output"
    assert job.state == 42
    assert job.sub_file == "some sub_file"
  end

  test "create_job/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Grading.create_job(@invalid_attrs)
  end

  test "update_job/2 with valid data updates the job" do
    job = fixture(:job)
    assert {:ok, job} = Grading.update_job(job, @update_attrs)
    assert %Job{} = job
    
    assert job.gra_file == "some updated gra_file"
    assert job.output == "some updated output"
    assert job.state == 43
    assert job.sub_file == "some updated sub_file"
  end

  test "update_job/2 with invalid data returns error changeset" do
    job = fixture(:job)
    assert {:error, %Ecto.Changeset{}} = Grading.update_job(job, @invalid_attrs)
    assert job == Grading.get_job!(job.id)
  end

  test "delete_job/1 deletes the job" do
    job = fixture(:job)
    assert {:ok, %Job{}} = Grading.delete_job(job)
    assert_raise Ecto.NoResultsError, fn -> Grading.get_job!(job.id) end
  end

  test "change_job/1 returns a job changeset" do
    job = fixture(:job)
    assert %Ecto.Changeset{} = Grading.change_job(job)
  end
end

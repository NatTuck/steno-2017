defmodule Steno.Web.PageController do
  use Steno.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def jobs(conn, _params) do
    new_job = Steno.Grading.change_job(%Steno.Grading.Job{})
    jobs    = Steno.Grading.list_jobs()
    render(conn, "jobs.html", jobs: jobs, new_job: new_job)
  end
end

defmodule Steno.Web.JobView do
  use Steno.Web, :view
  alias Steno.Web.JobView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{id: job.id,
      sub_file: job.sub_file,
      gra_file: job.gra_file,
      state: job.state,
      output: job.output}
  end
end

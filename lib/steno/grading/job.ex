defmodule Steno.Grading.Job do
  use Ecto.Schema
  
  schema "grading_jobs" do
    field :desc, :string
    field :sub_file, :string
    field :gra_file, :string
    field :state, :integer
    field :output, :string

    timestamps()
  end
end

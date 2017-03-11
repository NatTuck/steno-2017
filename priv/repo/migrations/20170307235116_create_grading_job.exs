defmodule Steno.Repo.Migrations.CreateSteno.Grading.Job do
  use Ecto.Migration

  def change do
    create table(:grading_jobs) do
      add :desc,     :string,  null: false
      add :sub_file, :string
      add :gra_file, :string
      add :state,    :integer, null: false, default: 0
      add :output,   :text

      timestamps()
    end
  end
end


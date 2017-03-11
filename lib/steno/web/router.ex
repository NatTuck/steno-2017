defmodule Steno.Web.Router do
  use Steno.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Steno.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/jobs", PageController, :jobs
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", Steno.Web do
    pipe_through :api

    resources "/jobs", JobController, except: [:new, :edit]
  end
end


defmodule Mix.Tasks.Thesis.Install do
  use Mix.Task
  import Mix.Thesis.Utils

  @shortdoc "Generates Thesis code in your Phoenix app"

  @moduledoc """
  TODO: Write docs.
  """

  def run(_args) do
    thesis_templates
    thesis_js
    thesis_npm
    thesis_config
    thesis_web
  end

  def thesis_templates do
    template_files = [ {"priv/templates/thesis.install/thesis_auth.exs", "lib/thesis_auth.ex" } ]
    migration_exists = File.ls!("priv/repo/migrations") |> Enum.map(fn (f) -> String.contains?(f, "create_thesis_tables") end) |> Enum.any?
    unless migration_exists do
      template_files = [{"priv/templates/thesis.install/migration.exs", "priv/repo/migrations/#{timestamp}_create_thesis_tables.exs"} | template_files]
    end

    template_files
    |> Stream.map(&render_eex/1)
    |> Stream.map(&copy_to_target/1)
    |> Stream.run
  end

  def thesis_js do
    status_msg("updating", "app.js")
    dest_file_path = Path.join [File.cwd! | ~w(web static js app.js)]
    File.read!(dest_file_path)
    |> insert_at(source, "import 'phoenix_html'\n", "import 'thesis'\n")
    |> overwrite_file(dest_file_path)
  end

  def thesis_npm do
    status_msg("updating", "package.json")
    System.cmd("npm", ["install", "./deps/thesis", "--save"])
  end

  def thesis_config do
    status_msg("updating", "config/config.exs")
    dest_file_path = Path.join [File.cwd! | ~w(config config.exs)]
    File.read!(dest_file_path)
    |> insert_thesis
    |> overwrite_file(dest_file_path)
  end

  def thesis_web do
    status_msg("updating", "web/web.exs")
    dest_file_path = Path.join [File.cwd! | ~w(web web.ex)]
    File.read!(dest_file_path)
    |> insert_controller
    |> insert_view
    |> insert_router
    |> overwrite_file(dest_file_path)
  end

  defp insert_controller(source) do
    insert_at(source, "def controller do\n    quote do", "\n      use Thesis.Controller\n")
  end

  defp insert_view(source) do
    insert_at(source, "def view do\n    quote do", "\n      use Thesis.View\n")
  end

  defp insert_router(source) do
    insert_at(source, "def router do\n    quote do", "\n      use Thesis.Router\n")
  end

  defp insert_at(source, pattern, inserted) do
    unless String.contains?(source, inserted) do
      String.replace(source, pattern, pattern <> inserted)
    else
      source
    end
  end

  defp insert_thesis(source) do
    unless String.contains? source, "config :thesis" do
      source <> """

      # Configure thesis content editor
      config :thesis,
        store: Thesis.Store,
        authorization: #{Mix.Phoenix.base}.ThesisAuth
      config :thesis, Thesis.Store, repo: #{Mix.Phoenix.base}.Repo
      """
    else
      status_msg("skipping", "thesis config. It already exists.")
      :skip
    end
  end

end

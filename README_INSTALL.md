# Thesis - Manual Installation

For automatic setup, see `README.md`.

#### 1. Add thesis to your `mix.exs`:

```elixir
def deps do
  [{:thesis, "~> 0.0.18"}]
end

def application do
  [applications: [:thesis]]
end
```

Run `mix deps.get`.

#### 2. Update your `config/config.exs`

```elixir
config :thesis,
  store: Thesis.EctoStore,
  authorization: <MyApp>.ThesisAuth
config :thesis, Thesis.EctoStore, repo: <MyApp>.Repo
```

#### 3. Create `lib/thesis_auth.ex`

```elixir
defmodule <MyApp>.ThesisAuth do
  @behaviour Thesis.Auth

  def page_is_editable?(conn) do
    true # editable by the world
  end
end
```

#### 4. Generate a migration

```elixir
defmodule <MyApp>.Repo.Migrations.CreateThesisTables do
  use Ecto.Migration

  def change do
    create table(:thesis_pages) do
      add :slug, :string
      add :title, :string
      add :description, :string

      timestamps
    end

    create table(:thesis_page_contents) do
      add :page_id, :integer
      add :name, :string, nil: false
      add :content, :text,  default: "Edit this content area"
      add :content_type, :string, default: "html"
      add :meta, :text

      timestamps
    end
  end
end
```

#### 5. Add Thesis to your layout

```eex
  <body>
    <%= thesis_editor(@conn) %>
```

#### 6. Run `mix ecto.migrate`

```
$ mix ecto.migrate
```

#### 7. Add Thesis.Controller, Thesis.View, and Thesis.Router to your `web/web.ex` file

```elixir
      def controller do
        quote do
          use Phoenix.Controller
          use Thesis.Controller

          # ...
        end
      end

      def view do
        quote do
          use Phoenix.View, root: "web/templates"
          use Thesis.View

          # ...
        end
      end

      def router do
        quote do
          use Phoenix.Router
          use Thesis.Router
        end
      end
```

#### 8. Done!

Now, start adding content areas. See the `README.md` for further instructions.

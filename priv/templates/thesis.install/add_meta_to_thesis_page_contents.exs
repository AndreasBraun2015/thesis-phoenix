defmodule <%= base %>.Repo.Migrations.AddMetaToThesisPageContents do
  use Ecto.Migration

  def change do
    alter table(:thesis_page_contents) do
      add :meta, :string
    end
  end
end

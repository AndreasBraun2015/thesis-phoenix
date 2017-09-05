defmodule EctoStoreTest do
  use Example.ConnCase

  import Example.MockData

  alias Thesis.Page
  alias Thesis.PageContent

  @store Thesis.Config.store

  defp random_slug, do: :crypto.strong_rand_bytes(10) |> Base.url_encode64 |> binary_part(0, 10)
  defp last_updated(model), do: Repo.one(from x in model, order_by: [desc: x.updated_at])
  defp last_updated(model, limit), do: Repo.all(from x in model, order_by: [desc: x.updated_at], limit: ^limit)

  test "Save content to a page not edited before" do
    slug = random_slug
    last_pc_id = last_updated(PageContent) && last_updated(PageContent) || 0

    :ok = @store.update(valid_static_page(slug), [valid_text_page_content])

    assert last_updated(Page).slug == "/" <> slug
    assert last_updated(PageContent).id > last_pc_id
  end

  test "Save global content to a page not edited before" do
    slug = random_slug

    :ok = @store.update(valid_static_page(slug), [valid_global_content])

    assert last_updated(Page).slug == "/" <> slug
    assert last_updated(PageContent).page_id == nil
  end

  test "Save more than one areas at the same time" do
    :ok = @store.update(valid_static_page, [valid_text_page_content, valid_html_page_content, valid_global_content])

    assert last_updated(Page).slug == valid_static_page["slug"]
    last_3 = last_updated(PageContent, 3)
    assert Enum.at(last_3, 0).content_type == "raw_html"
    assert Enum.at(last_3, 1).content_type == "html"
    assert Enum.at(last_3, 2).content_type == "text"
  end

  test "Save global area on one page; retrieve on a different page that's not yet in database" do
    :ok = @store.update(valid_static_page, [valid_global_content])

    records = @store.page_contents("/" <> random_slug)

    assert records == last_updated(PageContent, 1)
    assert Enum.at(records, 0).content_type == "raw_html"
  end

  test "Retrieves page content as well as well as global content saved on a different page" do
    slug = random_slug()
    :ok = @store.update(valid_static_page(random_slug()), [valid_global_content])
    :ok = @store.update(valid_static_page(slug), [valid_html_page_content])

    records = @store.page_contents("/" <> slug)

    Enum.each(last_updated(PageContent, 2), fn pc ->
      assert Enum.member?(records, pc)
    end)
  end

  test "First adds page, then deletes page found by slug" do
    slug = random_slug
    :ok = @store.update(valid_static_page(slug), [valid_html_page_content])

    assert @store.page("/" <> slug).slug == "/" <> slug
    assert last_updated(Page).slug == "/" <> slug

    :ok = @store.delete(valid_static_page(slug))

    refute @store.page("/" <> slug)
  end

  test "Save a page to the database with contents" do
    store = Thesis.Config.store

    pc1 = %{"name" => "A", "content_type" => "html", "content" => "<h1>Yay</h1>"}
    pc2 = %{"name" => "B", "content_type" => "text", "content" => "Yo"}
    pc3 = %{"name" => "C", "content_type" => "raw_html", "content" => "Wat", "global" => "true"}

    :ok = store.update(%{"slug" => "/test"}, [pc1, pc2, pc3])

    pc4 = %{"name" => "D", "content_type" => "text", "content" => "Other page"}
    pc5 = %{"name" => "E", "content_type" => "html", "content" => "<p>Other global</p>", "global" => "true"}

    :ok = store.update(%{"slug" => "/asdf"}, [pc4, pc5])

    page1 = store.page("/test")
    assert is_integer(page1.id)
    assert page1.id > 0
    assert page1.slug == "/test"

    page2 = store.page("/asdf")
    assert is_integer(page2.id)
    assert page2.id > 0
    assert page2.slug == "/asdf"

    contents = store.page_contents("/test")

    assert Enum.at(contents, 0).content == "<h1>Yay</h1>"
    assert is_integer(Enum.at(contents, 0).page_id)
    assert Enum.at(contents, 1).content == "Yo"
    assert is_integer(Enum.at(contents, 1).page_id)
    assert Enum.at(contents, 2).page_id == nil
    assert Enum.at(contents, 2).content == "Wat"
    assert Enum.at(contents, 3).page_id == nil
    assert Enum.at(contents, 3).content == "<p>Other global</p>"
    assert Enum.count(contents) == 4

    # Test backups

    backups = store.backups(page1.slug)
    assert Enum.count(backups) == 1

    backups = store.backups(page2.slug)
    assert Enum.count(backups) == 1

    :ok = store.update(%{"slug" => "/asdf"}, [pc4, pc5])

    backups = store.backups(page2.slug)
    assert Enum.count(backups) == 2

    restored = store.restore(List.first(backups).id)

    assert restored.page_revision == 2
  end

end

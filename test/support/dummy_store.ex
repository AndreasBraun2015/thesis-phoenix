
defmodule Thesis.DummyStore do
  @behaviour Thesis.Store

  def page(slug) do
    %Thesis.Page{slug: slug}
  end

  def page_contents(%Thesis.Page{} = _page) do
    []
  end

  def update(_page, _updated_contents) do
    :ok
  end

end

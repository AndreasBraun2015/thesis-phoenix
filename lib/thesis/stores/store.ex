defmodule Thesis.Store do
  @moduledoc """
  Thesis.Store is an Elixir "behaviour" that defines the public function
  interface necessary for Thesis to use a particular store module.

  There are currently four required functions, as described below.
  """

  @doc """
  Returns a Thesis.Page struct with the given slug (aka request_path).
  """
  @callback page(String.t) :: Thesis.Page.t

  @doc """
  Returns a list of related Thesis.PageContent structs both for the given
  Thesis.Page struct and global content areas. This is generally used to
  populate the page content using the Thesis.View.content/4 function.
  """
  @callback page_contents(Thesis.Page.t) :: [Thesis.PageContent.t]

  @doc """
  Updates the given page (identified by its slug) with the given map of
  string keys and Thesis.PageContent structs. Returns tuple `{:ok, page}`.

      update(%{"slug" => "/"}, %{"Heading" => "My Heading Content"})
  """
  @callback update(%{String.t => String.t}, map) :: {atom, Thesis.Page.t}

  @doc """
  Deletes the given page (identified by its slug). Returns tuple `{:ok, page}`.

      delete(%{"slug" => "/asdf"})
  """
  @callback delete(%{String.t => String.t}) :: atom
end

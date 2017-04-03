defmodule Thesis.Utilities do
  @moduledoc """
  Module that provides helper functions.
  """


  @doc """
  Removes special characters, keeps dashes and underscores, and replaces spaces
  with dashes. Also downcases the entire string.

      iex> import Thesis.Utilities
      iex> parameterize("Jamon is so cool!")
      "jamon-is-cool"
      iex> parameterize("%#d50SDF dfsJ FDS  lkdsf f dfka   a")
      "this-will-fail"
  """
  def parameterize(str) do
    str = Regex.replace(~r/[^a-z0-9\-\s\.]/i, str, "")
    Regex.split(~r/\%20|\s/, str)
    |> Enum.join("-")
    |> String.downcase
  end

  def random_string(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> String.replace(~r/[^0-9a-zA-Z]+/, "")
    |> String.downcase
    |> binary_part(0, length)
  end

  def random_string(length, :numeric) do
    length
    |> :crypto.strong_rand_bytes
    |> :crypto.bytes_to_integer
    |> Integer.to_string
    |> binary_part(0, length)
  end

  @doc """
  Takes a URL and strips unnecessary characters.

      iex> Thesis.Utilities.normalize_url("http://infinite.red//ignite//foo")
      "http://infinite.red/ignite/foo"
      iex> Thesis.Utilities.normalize_url("https://infinite.red/ignite/foo/")
      "https://infinite.red/ignite/foo"
  """
  def normalize_url(url) do
    url
    |> String.replace(~r/(?<=[^:])(\/\/)/, "/") # Strip double slashes
    |> String.replace(~r/\/$/, "") # Strip trailing slash
  end
end

defmodule Thesis.Controller do
  @moduledoc """
  Provides a plug that preloads any Thesis content for a page.
  Typically, you'll add this to your `web/web.ex` file, under the `controller`
  function:

      def controller do
        quote do
          use Phoenix.Controller
          use Thesis.Controller
          # ...
        end
      end

  If you'd prefer to only use Thesis in certain controllers, remove it from
  `web/web.ex` and add it to the specific controllers by doing this:

      defmodule MyApp.MyController do
        use Thesis.Controller
        # ...
  """

  defmacro __using__(_) do
    quote do
      plug Thesis.Controller.Plug

      @doc """
      Renders a page that exists only in the database, as opposed to a page that
      is defined in the router.

      This function will also redirect to the page's `redirect_url` if it is set.
      However, if the user is in edit mode, we will render the default template and
      display an alert telling them about the redirect. This gives the user a chance
      to edit where this page redirects to.
      """
      def render_dynamic(conn, opts \\ []) do
        page = conn.assigns[:thesis_page]
        if page && page.id do
          do_render_dynamic(conn, page, opts)
        else
          render_not_found(conn, opts)
        end
      end

      defp do_render_dynamic(conn, page, opts) do
        if Thesis.Page.redirected?(page) && !conn.assigns[:thesis_editable] do
          conn
          |> put_status(301)
          |> redirect(to: page.redirect_url)
        else
          conn
          |> put_status(200)
          |> render(page_template(page, opts))
        end
      end

      defp page_template(page, opts) do
        if page.template in Thesis.Config.dynamic_templates do
          page.template
        else
          opts[:template]
        end
      end

      defp render_not_found(conn, opts) do
        if (!opts[:not_found]), do: IO.warn("Set a `not_found` view to show your 404 page.")
        conn
        |> put_status(:not_found)
        |> put_view(opts[:not_found])
        |> render(opts[:not_found_template] || "404.html")
      end

    end
  end

end

defmodule Thesis.Controller.Plug do

  import Plug.Conn, only: [assign: 3]
  import Thesis.Config

  def init(_) do
  end

  def call(conn, _opts) do
    current_page = store.page(conn.request_path)
    page_contents = store.page_contents(current_page)

    conn
    |> assign(:thesis_page, current_page)
    |> assign(:thesis_content, page_contents)
    |> assign(:thesis_editable, auth.page_is_editable?(conn))
  end

end

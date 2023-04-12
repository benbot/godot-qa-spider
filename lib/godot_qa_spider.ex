defmodule GodotQASpider do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://godotengine.org/qa/"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://godotengine.org/qa/questions?sort=hot"]]
  end

  @impl Crawly.Spider
  @doc """
     Extract items and requests to follow from the given response
  """
  def parse_item(response) do
    # Extract item field from the response here. Usually it's done this way:
    # {:ok, document} = Floki.parse_document(response.body)
    # item = %{
    #   title: document |> Floki.find("title") |> Floki.text()
    #   url: response.request_url
    # }
    {:ok, document} = Floki.parse_document(response.body)

    titles =
      document
      |> Floki.find(".page-title")
      |> Floki.find("span")
      |> Enum.map(&(Floki.text(&1)))

    bodies =
      document
      |> Floki.find(".qa-post-content")
      |> Floki.find("div")
      |> Enum.map(&(Floki.text(&1)))

    tags =
      document
      |> Floki.find(".qa-tag-link")
      |> Floki.text()

    answers =
      document
      |> Floki.find(".qa-a-item-content")
      |> Floki.find("div")
      |> Floki.text()

    items =
      Enum.zip(titles, bodies)
      |> Enum.map(fn {title, body} ->
        %{title: title, body: body, tags: tags, answers: answers}
      end)

    # Extract requests to follow from the response. Don't forget that you should
    # supply request objects here. Usually it's done via
    #
    # urls = document |> Floki.find(".pagination a") |> Floki.attribute("href")
    # Don't forget that you need absolute urls
    # requests = Crawly.Utils.requests_from_urls(urls)

    question_requests =
      document
      |> Floki.find(".qa-q-item-title")
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Crawly.Utils.build_absolute_urls(base_url())
      |> Crawly.Utils.requests_from_urls()


    next_requests =
      document
      |> Floki.find(".qa-page-next")
      |> Floki.attribute("href")
      |> build_requests_if_can()

    %Crawly.ParsedItem{items: items, requests: question_requests ++ next_requests}
  end

  defp build_requests_if_can(targets) when is_list(targets) do
      case length(targets) do
        0 -> []
      _ ->
        targets
        |> Crawly.Utils.build_absolute_urls(base_url())
        |> Crawly.Utils.requests_from_urls()
      end
  end

end

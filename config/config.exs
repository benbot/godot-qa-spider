import Config

config :crawly,
  closespider_timeout: 10,
  concurrent_requests_per_domain: 100,
  closespider_itemcount: 600,

  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    {Crawly.Middlewares.UserAgent, user_agents: ["Crawly Bot", "Google"]}
  ],
  pipelines: [
    # An item is expected to have all fields defined in the fields list
    {Crawly.Pipelines.Validate, fields: [:title, :body, :tags, :answers]},

    # Use the following field as an item uniq identifier (pipeline) drops
    # items with the same urls
    {Crawly.Pipelines.DuplicatesFilter, item_id: :url},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "jl", folder: "./spiderdata"}
  ]

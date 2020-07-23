defmodule SwopClient do
  use HTTPoison.Base

  def single_rate(base_currency, quote_currency, opts \\ []) do
    date = Keyword.get(opts, :date)

    query_params =
      %{}
      |> maybe_add_param(:date, date)
      |> build_query_params

    get("/rates/#{base_currency}/#{quote_currency}#{query_params}")
  end

  def timeseries(from_date, to_date, opts \\ [])
  def timeseries(nil, _, []), do: {:error, "Please pass a from-date"}
  def timeseries(_, nil, []), do: {:error, "Please pass a to-date"}
  def timeseries(nil, nil, []), do: {:error, "Please pass a from and to dates"}

  def timeseries(from_date, to_date, opts) do
    base = Keyword.get(opts, :base)
    targets = Keyword.get(opts, :targets, [])
    include_meta = Keyword.get(opts, :include_meta)

    query_params =
      %{}
      |> add_param(:start, Date.to_iso8601(from_date))
      |> add_param(:end, Date.to_iso8601(to_date))
      |> maybe_add_param(:base, base)
      |> maybe_add_param(:targets, Enum.join(targets, ","))
      |> maybe_add_param(:meta, include_meta)
      |> build_query_params

    get("/timeseries#{query_params}")
  end

  def process_request_url(url) do
    "https://swop.cx/rest" <> url
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  def process_request_headers(headers) when is_map(headers) do
    headers
    |> Map.put(:Authorization, "ApiKey #{swop_api_key()}")
    |> Map.put(:Accept, "Application/json; Charset=utf-8")
    |> Enum.into([])
  end

  def process_request_headers(headers) do
    headers
    |> Keyword.put(:Authorization, "ApiKey #{swop_api_key()}")
    |> Keyword.put(:Accept, "Application/json; Charset=utf-8")
  end

  defp swop_api_key do
    Application.get_env(:swop_client, __MODULE__)[:api_key]
  end

  defp maybe_add_param(params, _name, nil), do: params
  defp maybe_add_param(params, _name, ""), do: params

  defp maybe_add_param(params, name, value) do
    add_param(params, name, value)
  end

  defp add_param(params, name, value) when not is_nil(value) do
    Map.put(params, name, value)
  end

  defp build_query_params(query_params) when is_map(query_params) and map_size(query_params) == 0,
    do: ""

  defp build_query_params(query_params) when is_map(query_params) do
    "?" <>
      (query_params
       |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
       |> Enum.join("&"))
  end
end

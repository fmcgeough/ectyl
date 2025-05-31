defmodule Ectyl.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Ectyl.Database.Repo

  alias Ectyl.Database.Contact

  @contacts_fields Contact.__schema__(:fields)
  @directions [:asc, :desc]
  @operators [:like, :in, :not_in, :begins_with, :ends_with]

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> Ectyl.Contacts.list_contacts()
      [%Contact{}, ...]

  ## Options
  - `:filters` - A list of filters to apply to the query. Each filter can be a tuple of `{field, value}` or `{field, value, operator}`.
    Supported operators are `:like`, `:in`, `:not_in`, `:begins_with`, and `:ends_with`. Supported fields are those defined in `Contact.__schema__(:fields)`
  - `:sort` - A list of tuples for sorting, where each tuple is `{field, direction}`. Supported fields are those defined in `Contact.__schema__(:fields)` and directions are `:asc` or `:desc`.
  - `:page` - The page number for pagination (default is 1).
  - `:page_size` - The number of contacts per page (default is 10).
  """
  def list_contacts(opts \\ []) do
    contacts_base_query()
    |> apply_filters(opts)
    |> apply_sorting(opts)
    |> apply_pagination(opts)
    |> Repo.all()
  end

  defp apply_filters(query, opts) do
    opts
    |> options(:filters)
    |> Enum.filter(fn
      {field, _value} when field in @contacts_fields -> true
      {field, _value, operator} when field in @contacts_fields and operator in @operators -> true
      _ -> false
    end)
    |> Enum.reduce(query, fn
      {field, value}, acc ->
        from c in acc, where: field(c, ^field) == ^value

      {field, value, :begins_with}, acc ->
        from c in acc, where: like(field(c, ^field), ^"#{value}%")

      {field, value, :ends_with}, acc ->
        from c in acc, where: like(field(c, ^field), ^"%#{value}")

      {field, value, :like}, acc ->
        from c in acc, where: like(field(c, ^field), ^"%#{value}%")

      {field, value, :in}, acc ->
        from c in acc, where: field(c, ^field) in ^value

      {field, value, :not_in}, acc ->
        from c in acc, where: field(c, ^field) not in ^value

      _, acc ->
        acc
    end)
  end

  defp apply_sorting(query, opts) do
    opts
    |> options(:sort)
    |> Enum.filter(fn {field, direction} ->
      field in @contacts_fields and direction in @directions
    end)
    |> Enum.reduce(query, fn {field, direction}, acc ->
      from c in acc, order_by: [{^direction, field(c, ^field)}]
    end)
  end

  defp apply_pagination(query, opts) do
    page = opts[:page] || 1
    page_size = opts[:page_size] || 10

    query
    |> offset(^((page - 1) * page_size))
    |> limit(^page_size)
  end

  defp contacts_base_query do
    from(c in Contact)
  end

  defp options(opts, option_type) do
    opts[option_type] || []
  end
end

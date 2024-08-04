defmodule Turnkey.Instructer do
  @moduledoc """
  Put maps into structs and return error tuple while enforcing keys.
  `struct/2` fails to enforce keys and `struct!/2` crashes, so this module
  wraps `struct!/2` with try rescue.

  It also handles assigning nested structs and critically plays nicely with @enforce_keys
  """

  @doc """
  Converts a map to a struct, enforcing the presence of all keys.
  If the conversion fails, returns an error tuple.

  ## Examples
      iex> cat_params = %{
      ...>   "user_name" => "test_user",
      ...>   "friend" => %{"bark" => "abc123", "bite" => "data"}
      ...> }
      iex> Turnkey.Instructer.instructify(
      ...>   cat_params,
      ...>   {Cat, friend: Cat.Dog}
      ...> )
      {:ok, %Cat{friend: %Cat.Dog{bark: "abc123", bite: "data"}, user_name: "test_user"}}

      iex> bad_dog = %{
      ...>   "user_name" => "test_user",
      ...>   "friend" => %{"bark" => "abc123"}
      ...> }
      iex> Turnkey.Instructer.instructify(
      ...>   bad_dog,
      ...>   {Cat, friend: Cat.Dog}
      ...> )
      {:error,  {:instructer_parsing_error, "the following keys must also be given when building struct Turnkey.InstructerTest.Cat.Dog: [:bite] found only %{\\"bark\\" => \\"abc123\\"} as %{bark: \\"abc123\\"}"}}

      iex> extra_keys_ignored = %{
      ...>   "user_name" => "test_user",
      ...>   "friend" => %{"bark" => "abc123", "bite" => "data", "fuggedabaoutit" => "abc123"}
      ...> }
      iex> Turnkey.Instructer.instructify(
      ...>   extra_keys_ignored,
      ...>   {Cat, friend: Cat.Dog}
      ...> )
      {:ok, %Cat{friend: %Cat.Dog{bark: "abc123", bite: "data"}, user_name: "test_user"}}
  """

  def instructify(map, targets, snakify \\ false)

  def instructify(map, target_struct, snakify) when is_atom(target_struct) do
    struct_from_string_keys!(target_struct, map, snakify)
  end

  def instructify(map, {thing_being_structified, children_structs_by_key}, snakify) do
    children_structs_by_key
    |> Enum.reduce_while(map, fn {child_params_key, next_struct}, acc_map ->
      string_child_params_key = Atom.to_string(child_params_key)

      map
      |> Map.get(string_child_params_key, %{})
      |> instructify(next_struct, snakify)
      |> case do
        {:ok, happy_struct} ->
          {:cont, Map.put(acc_map, string_child_params_key, happy_struct)}

        {:error, _err} = e ->
          {:halt, e}
      end
    end)
    |> case do
      {:error, _err} = e ->
        e

      children_structs ->
        instructify(children_structs, thing_being_structified)
    end
  end

  def instructify!(map, targets) do
    {:ok, x} = instructify(map, targets)
    x
  end

  def struct_from_string_keys!(struct_module, map, snakify) do
    available_keys =
      struct(struct_module, %{})
      |> Map.delete(:__struct__)
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    final_keys =
      if snakify do
        # convert tne desired keys to camel case to pull them out of the map
        # also leave the original keys in in case snakify passed eroneously
        Enum.map(available_keys, &js_camelize/1)
        |> Enum.concat(available_keys)
      else
        available_keys
      end

    atom_map =
      map
      |> Map.take(final_keys)
      |> atomize_some_keys(snakify)

    try do
      {:ok, struct!(struct_module, atom_map)}
    rescue
      exception in ArgumentError ->
        {:error,
         {:instructer_parsing_error,
          exception.message <>
            " found only " <>
            inspect(map) <>
            " as " <>
            inspect(atom_map, pretty: true, limit: :infinity)}}

      exception in KeyError ->
        {:error,
         {:instructer_parsing_error,
          KeyError.message(exception) <>
            " found only " <> inspect(map)}}
    end
  end

  defp atomize_some_keys(map, snakify) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      cond do
        is_binary(key) ->
          atom_key =
            case snakify do
              true ->
                Macro.underscore(key)

              false ->
                key
            end
            |> String.to_existing_atom()

          Map.put(acc, atom_key, value)

        is_atom(key) ->
          Map.put(acc, key, value)

        true ->
          acc
      end
    end)
  end

  def js_camelize(string) when is_binary(string) do
    s = Macro.camelize(string)
    {first, rest} = String.split_at(s, 1)

    String.downcase(first) <> rest
  end
end

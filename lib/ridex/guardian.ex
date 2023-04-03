# An implementation for using Guardian
# We will use this module to interact with tokens in our application

defmodule Ridex.Guardian do
  use Guardian, otp_app: :ridex

  def subject_for_token(%{id: user_id}, _claims), do: {:ok, user_id}

  def resource_from_claims(%{"sub" => subject}) do
    case Ridex.Repo.get(Ridex.User, subject) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end

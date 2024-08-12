defmodule Mentat.Integrations.Util do
  def get_provider_config!(provider_name) do
    Application.get_env(:mentat, :strategies)[provider_name] ||
      raise "No provider configuration for #{provider_name}"
  end
end

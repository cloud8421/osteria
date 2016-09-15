defmodule Osteria.Config do
  require Logger

  def fast_chef do
    Application.put_env(:osteria, Osteria.Chef, organizing_speed: 10)
    Logger.info "Chef got fast"
  end

  def slow_chef do
    Application.put_env(:osteria, Osteria.Chef, organizing_speed: 1000)
    Logger.info "Chef got slow"
  end

  def fast_line_cook do
    Application.put_env(:osteria, Osteria.LineCook, cooking_speed: 300)
    Logger.info "Line cooks got fast"
  end

  def slow_line_cook do
    Application.put_env(:osteria, Osteria.LineCook, cooking_speed: 1500)
    Logger.info "Line cooks got slow"
  end
end

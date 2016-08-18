defmodule Osteria.Menu do
  defmodule Dish do
    defstruct name: "",
              type: :none
  end

  def all do
    [%Dish{name: "Spaghetti all'amatriciana", type: :pasta},
     %Dish{name: "Spaghetti alla carbonara", type: :pasta},
     %Dish{name: "Polenta e cotechino", type: :stew},
     %Dish{name: "Arrosto di vitello", type: :oven},
     %Dish{name: "Grigliata di pesce", type: :grill},
     %Dish{name: "Entrecote", type: :grill},
     %Dish{name: "Melanzane alla parmigiana", type: :oven}]
  end

  def names do
    Enum.map(all(), &(&1.name))
  end
end

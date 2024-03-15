defmodule Gene.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Gene.Dna

  import Scenic.Primitives

  @text_size 12

  def init(scene, _param, _opts) do
    request_input(scene, [:key])

    {:ok, draw(scene, Dna.setup_simulation())}
  end

  def draw(scene, population) do
    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> add_specs_to_graph(Dna.render(population, @text_size))

    scene
    |> assign(pop: population)
    |> push_graph(graph)
  end

  def handle_input({:key, _mod}, _id, %{assigns: %{pop: population}}=scene) do
    {:noreply, draw(scene, Dna.evolve(population))}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, scene}
  end
end

defmodule Gene.Dna do
  require Logger

  defstruct [
    :genes,
    :fitness,
    :length
  ]

  @type t :: %__MODULE__{
    genes: list(String.t),
    fitness: integer(),
    length: integer()
  }

  alias Gene.Dna
  import Scenic.Primitives

  @population_size 150
  @target "to be or not to be"
  @mutation_rate 0.01

  def setup_simulation() do
    target_len = String.length(@target)

    Enum.map(1..@population_size, fn _ ->
      make(target_len)
    end)
  end

  def evolve(population) do
    mating_pool = population
    |> Enum.map(fn dna -> set_fitness(dna, @target) end)
    |> Enum.flat_map(fn %{fitness: fitness} = dna ->
      Enum.map(1..round(fitness * 100), fn _ ->
        dna
      end)
    end)

    Enum.map(1..@population_size, fn _ ->
      mother = Enum.random(mating_pool)
      father = Enum.random(mating_pool)

      crossover(mother, father)
      |> mutate(@mutation_rate)
    end)
  end

  def render([%{length: len}|_ps]=population, text_size) do
    min_x = text_size * len
    min_y = text_size + 3

    per_page = 30

    page = fn idx ->
      floor(1 + (idx / per_page))
    end

    population
    |> Enum.with_index()
    |> Enum.map(fn {dna, idx} ->

      p = page.(idx)

      x_offset = min_x * (p-1)
      y_offset = min_y * (1 + Integer.mod(idx, per_page))

      text_spec(dna |> show(), translate: {x_offset, y_offset})
    end)
  end

  def make(length) do
    genes = Enum.map(1..length, fn _ ->
      random_char()
    end)

    %Dna{genes: genes, length: length}
  end

  def set_fitness(%Dna{genes: genes}=dna, target) do
    score = genes
    |> Enum.with_index()
    |> Enum.count(fn {gene, idx} ->
      String.at(target, idx) == gene
    end)

    %{dna | fitness: score / String.length(target)}
  end

  def crossover(%Dna{genes: mother_genes, length: length}, %Dna{genes: father_genes}=father) do
    midpoint = Enum.random(0..length-1)

    new_genes = Enum.slice(mother_genes, 0..midpoint) ++ Enum.slice(father_genes, (midpoint+1)..length)
    %{father | genes: new_genes}
  end

  def mutate(%Dna{genes: genes, length: len}=dna, rate) do
    new_genes = 0..len
    |> Enum.filter(fn _ -> :rand.uniform() < rate end)
    |> Enum.reduce(genes, &(
      List.update_at(&2, &1, fn _ -> random_char() end)
    ))

    %{dna | genes: new_genes}
  end

  def show(%Dna{genes: genes}) do
    Enum.join(genes)
  end

  defp random_char() do
    <<Enum.random([?\s|?a..?z |> Enum.to_list])>>
  end
end

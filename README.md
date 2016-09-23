# Osteria

Demo application for Elixir.LDN's talk "GenStage in the Kitchen" [slides here](https://speakerdeck.com/cloud8421/genstage-in-the-kitchen)

## Setup

`mix deps.get`
`iex -S mix`

Then visit `http://localhost:4001`

## Frontend

The frontend application is built with Elm, so it requires it to be installed.

Compiled js and css is shipped with the codebase, so you don't need to compile by hand after cloning. If you wish to make any changes you can:

- `cd frontend`
- `make install`
- `make` to compile
- `make watch` to start a watcher that recompiles on save

## Some directions when reading code

- Start from `lib/osteria.ex`: here all processes are setup in single supervision tree.
- The `Osteria.Status` module is used to collect information about each component in the system, so that we can pipe that information to the frontend.
- You can then move to `lib/osteria/table.ex` and see how each table handles people sitting down and deciding dishes. Note that to keep track of tables a naive `Osteria.TableMap` is provided. A better solution would be a process registry.
- The `Waiter` module is modeled after the `EventManager` example shown here: <http://elixir-lang.org/blog/2016/07/14/announcing-genstage/>.
- The `Osteria.Chef` module partitions orders using a `Osteria.Menu` module to figure out a dish type (grill, oven, etc.)
- If you open the `Osteria.Log` module you can enable logging (roughly commented out towards the end). That way you can see events happening in real time in the console.

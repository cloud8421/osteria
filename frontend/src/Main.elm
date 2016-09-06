module Main exposing (..)

import Html exposing (div, text, Html)
import Html.App as Html
import Platform.Sub as Sub
import Time
import Api
import Types exposing (..)


model : Model
model =
    Nothing


view : Model -> Html Msg
view model =
    div []
        [ model |> toString |> text ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Tick ->
            ( model, Api.getStatus )

        NewStatus status ->
            ( Just status, Cmd.none )

        StatusError error ->
            let
                dbg =
                    Debug.log "error" error
            in
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every Time.second (always Tick)
        ]


main : Program Never
main =
    Html.program
        { init = ( model, Api.getStatus )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

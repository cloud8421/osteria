module Main exposing (..)

import Html exposing (div, text, Html)
import Html.App as Html
import Platform.Sub as Sub
import Time
import Api
import Types exposing (..)
import Html exposing (..)
import String


model : Model
model =
    Nothing


tableItem table =
    li []
        [ span [] [ text <| toString <| table.number ]
        , span [] [ text <| toString <| table.size ]
        , span [] [ text <| String.join ", " table.dishes ]
        ]


tableList tables =
    div []
        [ ul []
            (List.map tableItem tables)
        ]


dishItem dish =
    li [] [ text dish ]


chefStatus chef =
    div []
        [ p []
            [ text <| toString <| chef.table_number ]
        , ul []
            (List.map dishItem chef.dishes)
        ]


lineCookItem lineCook =
    li []
        [ span [] [ text <| lineCook.area ]
        , span [] [ text <| String.join ", " lineCook.dishes ]
        ]


lineCookList lineCooks =
    div []
        [ ul []
            (List.map lineCookItem lineCooks)
        ]


view : Model -> Html Msg
view model =
    case model of
        Just status ->
            div []
                [ h1 [] [ text "Osteria" ]
                , main' []
                    [ tableList status.tables
                    , chefStatus status.chef
                    , lineCookList status.line_cooks
                    ]
                ]

        Nothing ->
            p [] [ text "Wait for it..." ]


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
        [ Time.every 100 (always Tick)
        ]


main : Program Never
main =
    Html.program
        { init = ( model, Api.getStatus )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

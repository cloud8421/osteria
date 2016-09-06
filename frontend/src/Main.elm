module Main exposing (..)

import Data
import Html exposing (..)
import Html exposing (div, text, Html)
import Html.App as Html
import Json.Decode exposing (decodeString)
import Platform.Sub as Sub
import String
import Types exposing (..)
import WebSocket


model : Model
model =
    Nothing


tableItem : Table -> Html Msg
tableItem table =
    li []
        [ span [] [ text <| toString <| table.number ]
        , span [] [ text <| toString <| table.size ]
        , span [] [ text <| String.join ", " table.dishes ]
        ]


tableList : List Table -> Html Msg
tableList tables =
    div []
        [ ul []
            (List.map tableItem tables)
        ]


dishItem : String -> Html Msg
dishItem dish =
    li [] [ text dish ]


chefStatus : Chef -> Html Msg
chefStatus chef =
    div []
        [ p []
            [ text <| toString <| chef.table_number ]
        , ul []
            (List.map dishItem chef.dishes)
        ]


lineCookItem : LineCook -> Html Msg
lineCookItem lineCook =
    li []
        [ span [] [ text <| lineCook.area ]
        , span [] [ text <| String.join ", " lineCook.dishes ]
        ]


lineCookList : List LineCook -> Html Msg
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
            ( model, getStatus )

        SocketMsg msg ->
            case (decodeString Data.statusDecoder msg) of
                Ok status ->
                    ( Just status, Cmd.none )

                otherwise ->
                    ( model, Cmd.none )


wsServer : String
wsServer =
    "ws://localhost:4001/ws"


getStatus : Cmd a
getStatus =
    WebSocket.send wsServer "get-status"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ WebSocket.listen wsServer SocketMsg
        , WebSocket.keepAlive wsServer
        ]


main : Program Never
main =
    Html.program
        { init = ( model, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

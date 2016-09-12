module Main exposing (..)

import Data
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Json.Decode exposing (decodeString)
import Platform.Sub as Sub
import String
import Types exposing (..)
import WebSocket


model : Model
model =
    Nothing


dishIndicator : List a -> String
dishIndicator dishes =
    String.repeat (List.length dishes) "🍲"


phaseIndicator : String -> String
phaseIndicator phase =
    case phase of
        "waiting" ->
            "⌛️"

        "deciding" ->
            "💬"

        otherwise ->
            "doh"


tableItem : Table -> Html Msg
tableItem tb =
    tr []
        [ td [ class "phase narrow" ] [ text <| phaseIndicator tb.phase ]
        , td [ class "number narrow" ] [ text <| toString <| tb.number ]
        , td [ class "size narrow" ] [ text <| toString <| tb.size ]
        , td [] [ text (dishIndicator tb.dishes) ]
        ]


tableList : List Table -> Html Msg
tableList tables =
    let
        sortedTables =
            List.sortBy .number tables
    in
        div [ class "tables" ]
            [ h2 [] [ text "Tables" ]
            , Html.table []
                [ thead []
                    [ th [ class "narrow" ] [ text "phase" ]
                    , th [ class "narrow" ] [ text "number" ]
                    , th [ class "narrow" ] [ text "people" ]
                    , th [] [ text "dishes" ]
                    ]
                , tbody []
                    (List.map tableItem sortedTables)
                ]
            ]


dishItem : String -> Html Msg
dishItem dish =
    tr []
        [ td [] [ text dish ]
        ]


chefStatus : Chef -> Html Msg
chefStatus chef =
    div [ class "chef" ]
        [ h2 [] [ text "Chef" ]
        , Html.table []
            [ thead []
                [ th [] [ text ("dishes for table " ++ (toString chef.table_number)) ]
                ]
            , tbody []
                (List.map dishItem chef.dishes)
            ]
        ]


lineCookItem : LineCook -> Html Msg
lineCookItem lineCook =
    tr []
        [ td [] [ text <| lineCook.area ]
        , td [] [ text (dishIndicator lineCook.dishes) ]
        ]


lineCookList : List LineCook -> Html Msg
lineCookList lineCooks =
    div [ class "line-cooks" ]
        [ h2 [] [ text "Line Cooks" ]
        , Html.table []
            [ thead []
                [ th [] [ text "area" ]
                , th [] [ text "dishes" ]
                ]
            , tbody []
                (List.map lineCookItem lineCooks)
            ]
        ]


lostTables : Int -> Html Msg
lostTables errorCount =
    let
        msg =
            "Number of lost tables: " ++ (toString errorCount)
    in
        footer []
            [ p []
                [ text msg ]
            ]


view : Model -> Html Msg
view model =
    case model of
        Just status ->
            div []
                [ h1 [] [ text "Osteria" ]
                , lostTables status.errorCount
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

module Main exposing (..)

import Data
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
    String.repeat (List.length dishes) "🍽"


lineIndicator : List a -> String -> String
lineIndicator dishes area =
    let
        indicator =
            case area of
                "stew" ->
                    "🍲"

                "pasta" ->
                    "🍝"

                "oven" ->
                    "🍗"

                "grill" ->
                    "🍖"

                otherwise ->
                    "NA"
    in
        String.repeat (List.length dishes) indicator


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
                    [ tr []
                        [ th [ class "narrow" ] [ text "phase" ]
                        , th [ class "narrow" ] [ text "number" ]
                        , th [ class "narrow" ] [ text "people" ]
                        , th [] [ text "dishes" ]
                        ]
                    ]
                , tbody []
                    (List.map tableItem sortedTables)
                ]
            ]


waiterStatus : Int -> Html Msg
waiterStatus queueCount =
    let
        isCritical =
            queueCount > 1
    in
        div [ classList [ ( "waiter", True ), ( "critical", isCritical ) ] ]
            [ h2 []
                [ text "Waiter" ]
            , Html.table []
                [ thead []
                    [ tr []
                        [ th [ class "narrow" ] [ text "orders count" ]
                        ]
                    ]
                , tbody []
                    [ tr []
                        [ td [ class "narrow" ] [ text <| toString <| queueCount ]
                        ]
                    ]
                ]
            ]


dishItem : String -> Html Msg
dishItem dish =
    tr []
        [ td [] [ text dish ]
        ]


orderStatus : Types.Order -> Html Msg
orderStatus chefOrder =
    Html.table []
        [ thead []
            [ tr []
                [ th [] [ text ("dishes for table " ++ (toString chefOrder.table_number)) ]
                ]
            ]
        , tbody []
            (List.map dishItem chefOrder.dishes)
        ]


chefStatus : List Types.Order -> Html Msg
chefStatus chefOrders =
    let
        isCritical =
            (List.length chefOrders) > 1
    in
        div [ classList [ ( "chef", True ), ( "critical", isCritical ) ] ]
            [ h2 [] [ text "Chef" ]
            , div []
                (List.map orderStatus chefOrders)
            ]


lineCookItem : LineCook -> Html Msg
lineCookItem lineCook =
    tr []
        [ td [] [ text <| lineCook.area ]
        , td [] [ text (lineIndicator lineCook.dishes lineCook.area) ]
        ]


lineCookList : List LineCook -> Html Msg
lineCookList lineCooks =
    div [ class "line-cooks" ]
        [ h2 [] [ text "Line Cooks" ]
        , Html.table []
            [ thead []
                [ tr []
                    [ th [] [ text "area" ]
                    , th [] [ text "dishes" ]
                    ]
                ]
            , tbody []
                (List.map lineCookItem lineCooks)
            ]
        ]


lostTables : Int -> Html Msg
lostTables errorCount =
    let
        msg =
            "Tables lost: " ++ (toString errorCount)
    in
        div [ class "lost-tables" ]
            [ span []
                [ text msg ]
            ]


configBar : Html Msg
configBar =
    nav []
        [ button [ onClick (Config SlowLineCook) ]
            [ text "Get line cooks drunk" ]
        , button [ onClick (Config FastLineCook) ]
            [ text "Give line cooks an energy drink" ]
        , button [ onClick (Config SlowChef) ]
            [ text "Chef gets a papercut" ]
        , button [ onClick (Config FastChef) ]
            [ text "Chef uses a plaster" ]
        ]


view : Model -> Html Msg
view model =
    case model of
        Just status ->
            div []
                [ h1 [] [ text "Osteria" ]
                , header []
                    [ configBar
                    , lostTables status.errorCount
                    ]
                , main' []
                    [ tableList status.tables
                    , waiterStatus status.waiterQueue
                    , chefStatus status.chefOrders
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

        SocketMsg msg ->
            case (decodeString Data.statusDecoder msg) of
                Ok status ->
                    ( Just status, Cmd.none )

                otherwise ->
                    ( model, Cmd.none )

        Config option ->
            ( model, updateConfig option )


wsServer : String
wsServer =
    "ws://localhost:4001/ws"


updateConfig : Option -> Cmd a
updateConfig option =
    WebSocket.send wsServer (Data.encodeOption option)


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

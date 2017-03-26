module Data exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


orderDecoder : Decoder Types.Order
orderDecoder =
    map2 Order
        (field "table_number" int)
        (field "orders" (list string))


lineCookDecoder : Decoder LineCook
lineCookDecoder =
    map2 LineCook
        (field "area" string)
        (field "dishes" (list string))


tableDecoder : Decoder Table
tableDecoder =
    map4 Table
        (field "phase" string)
        (field "size" int)
        (field "number" int)
        (field "dishes" (list string))


statusDecoder : Decoder Status
statusDecoder =
    map5 Status
        (field "tables" (list tableDecoder))
        (field "waiter_queue" int)
        (field "line_cooks" (list lineCookDecoder))
        (field "chef" (list orderDecoder))
        (field "error_count" int)


encodeOption : Option -> String
encodeOption option =
    case option of
        SlowLineCook ->
            "slow-line-cook"

        FastLineCook ->
            "fast-line-cook"

        SlowChef ->
            "slow-chef"

        FastChef ->
            "fast-chef"

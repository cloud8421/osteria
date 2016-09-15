module Data exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


orderDecoder : Decoder Types.Order
orderDecoder =
    object2 Order
        ("table_number" := int)
        ("orders" := list string)


lineCookDecoder : Decoder LineCook
lineCookDecoder =
    object2 LineCook
        ("area" := string)
        ("dishes" := list string)


tableDecoder : Decoder Table
tableDecoder =
    object4 Table
        ("phase" := string)
        ("size" := int)
        ("number" := int)
        ("dishes" := list string)


statusDecoder : Decoder Status
statusDecoder =
    object5 Status
        ("tables" := (list tableDecoder))
        ("waiter_queue" := int)
        ("line_cooks" := (list lineCookDecoder))
        ("chef" := (list orderDecoder))
        ("error_count" := int)


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

module Data exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)


chefDecoder : Decoder Chef
chefDecoder =
    object2 Chef
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
    object3 Status
        ("tables" := (list tableDecoder))
        ("line_cooks" := (list lineCookDecoder))
        ("chef" := chefDecoder)

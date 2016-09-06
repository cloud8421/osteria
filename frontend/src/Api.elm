module Api exposing (..)

import Http
import Json.Decode exposing (..)
import Types exposing (..)
import Task


chefDecoder =
    object2 Chef
        ("table_number" := int)
        ("orders" := list string)


lineCookDecoder =
    object2 LineCook
        ("area" := string)
        ("dishes" := list string)


tableDecoder =
    object3 Table
        ("size" := int)
        ("number" := int)
        ("dishes" := list string)


statusDecoder =
    object3 Status
        ("tables" := (list tableDecoder))
        ("line_cooks" := (list lineCookDecoder))
        ("chef" := chefDecoder)


getStatus =
    let
        req =
            Http.get statusDecoder "/status"
    in
        Task.perform StatusError NewStatus req

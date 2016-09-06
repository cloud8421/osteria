module Types exposing (..)

import Http exposing (Error)


type Msg
    = NoOp
    | Tick
    | SocketMsg String


type alias Model =
    Maybe Status


type alias Table =
    { size : Int
    , number : Int
    , dishes : List String
    }


type alias LineCook =
    { area : String
    , dishes : List String
    }


type alias Chef =
    { table_number : Int
    , dishes : List String
    }


type alias Status =
    { tables : List Table
    , line_cooks : List LineCook
    , chef : Chef
    }

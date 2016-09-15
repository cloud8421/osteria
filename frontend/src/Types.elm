module Types exposing (..)


type Option
    = SlowLineCook
    | FastLineCook
    | SlowChef
    | FastChef


type Msg
    = NoOp
    | SocketMsg String
    | Config Option


type alias Model =
    Maybe Status


type alias Table =
    { phase : String
    , size : Int
    , number : Int
    , dishes : List String
    }


type alias LineCook =
    { area : String
    , dishes : List String
    }


type alias Order =
    { table_number : Int
    , dishes : List String
    }


type alias Status =
    { tables : List Table
    , waiterQueue : Int
    , line_cooks : List LineCook
    , chefOrders : List Order
    , errorCount : Int
    }

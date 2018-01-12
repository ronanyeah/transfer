port module Main exposing (main)

import AFrame exposing (entity, scene)
import AFrame.Animations exposing (repeat)
import AFrame.Primitives exposing (box, cylinder, plane, sky, sphere, text)
import AFrame.Primitives.Attributes exposing (color, depth, height, metalness, position, radius, rotation, roughness, shader, src, transparent, width)
import AFrame.Primitives.Camera exposing (camera)
import AFrame.Primitives.Cursor exposing (cursor, fuse)
import Color exposing (rgb)
import Html
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, Value)


type alias Person =
    { id : String
    , name : String
    , age : Int
    }


type alias Model =
    { db1 : List Person
    , db2 : List Person
    }


type Msg
    = Click String
    | Data Value


port data : (Value -> msg) -> Sub msg


log : a -> Cmd msg
log a =
    let
        _ =
            Debug.log "!" a
    in
    Cmd.none


main : Program Value Model Msg
main =
    Html.programWithFlags
        { init =
            \value ->
                case Decode.decodeValue decodeData value of
                    Ok m ->
                        ( m, log "success!" )

                    Err err ->
                        ( { db1 = [], db2 = [] }, log err )
        , subscriptions =
            \_ ->
                data Data
        , update =
            \msg model ->
                case msg of
                    Click str ->
                        ( model, log str )

                    Data value ->
                        case Decode.decodeValue decodeData value of
                            Ok m ->
                                ( m, log "success!" )

                            Err err ->
                                ( model, log err )
        , view =
            \{ db1, db2 } ->
                scene
                    []
                    [ plane
                        [ position -2 0 1
                        , height 9
                        , width 3
                        , color <| rgb 127 209 59
                        ]
                        []
                    , text
                        [ attribute "value" "DB 1"
                        , position -1.5 3.5 2
                        , color <| rgb 138 43 226
                        ]
                        []
                    , entity [ position -1.5 2 2 ]
                        (db1
                            |> List.indexedMap
                                (\i { id, name } ->
                                    text
                                        [ attribute "value" name
                                        , position 0 (toFloat i - 1) 0
                                        , color <| rgb 255 0 0
                                        , onClick <| Click id
                                        ]
                                        []
                                )
                        )
                    , plane
                        [ position 2 0 1
                        , height 9
                        , width 3
                        , color <| rgb 6 181 204
                        ]
                        []
                    , text
                        [ attribute "value" "DB 2"
                        , position 1.5 3.5 2
                        , color <| rgb 138 43 226
                        ]
                        []
                    , plane
                        [ rotation -90 0 0
                        , width 10000
                        , height 10000
                        , repeat "10000 10000"
                        , transparent True
                        , metalness 0.6
                        , roughness 0.4
                        ]
                        []
                    , camera [ position 0 0 5 ]
                        [ cursor
                            -- [ fuse True ]
                            []
                            [ box [ position 0 0 2 ] []
                            ]
                        ]
                    ]
        }


planeA =
    plane
        [ rotation -90 0 0
        , width 4
        , height 4
        , color (rgb 90 99 120)
        ]
        []


ball =
    sphere
        [ position 0 1.25 -1
        , radius 1.25
        , color (rgb 240 173 0)
        ]
        []


cyl =
    cylinder
        [ position 1 0.75 1
        , radius 0.5
        , height 1.5
        , color (rgb 6 181 204)
        , onClick <| Click "ok"
        ]
        []


decodeData : Decoder Model
decodeData =
    Decode.map2 Model
        (Decode.field "db1" (Decode.list decodePerson))
        (Decode.field "db2" (Decode.list decodePerson))


decodePerson : Decoder Person
decodePerson =
    Decode.map3 Person
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)

port module Main exposing (main)

import AFrame exposing (entity, scene)
import AFrame.Animations exposing (repeat)
import AFrame.Primitives exposing (box, cylinder, plane, sky, sphere, text)
import AFrame.Primitives.Attributes exposing (color, depth, height, metalness, position, radius, rotation, roughness, shader, src, transparent, width)
import AFrame.Primitives.Camera exposing (camera)
import AFrame.Primitives.Cursor exposing (cursor, fuse)
import Color exposing (rgb)
import Html exposing (Html)
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
    , selection : Selection
    }


type Selection
    = Pending
    | Moving Db String


type Db
    = Db1
    | Db2


type Msg
    = DbUpdate Db Value
    | SelectPerson Db String
    | SelectDb Db


port db1Data : (Value -> msg) -> Sub msg


port db2Data : (Value -> msg) -> Sub msg


port moveToDb1 : String -> Cmd msg


port moveToDb2 : String -> Cmd msg


log : a -> Cmd msg
log a =
    let
        _ =
            Debug.log "!" a
    in
    Cmd.none


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( { db1 = []
              , db2 = []
              , selection = Pending
              }
            , Cmd.none
            )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ db1Data <| DbUpdate Db1
                    , db2Data <| DbUpdate Db2
                    ]
        , update =
            \msg model ->
                case msg of
                    DbUpdate db value ->
                        case Decode.decodeValue decodeData value of
                            Ok data ->
                                case db of
                                    Db1 ->
                                        ( { model | db1 = data }, Cmd.none )

                                    Db2 ->
                                        ( { model | db2 = data }, Cmd.none )

                            Err err ->
                                ( model, log ( db, err ) )

                    SelectPerson db str ->
                        ( { model | selection = Moving db str }, log str )

                    SelectDb toDb ->
                        case model.selection of
                            Pending ->
                                ( model, Cmd.none )

                            Moving fromDb id ->
                                if fromDb == toDb then
                                    ( { model | selection = Pending }, Cmd.none )
                                else
                                    case toDb of
                                        Db1 ->
                                            ( { model | selection = Pending }, moveToDb1 id )

                                        Db2 ->
                                            ( { model | selection = Pending }, moveToDb2 id )
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
                    , header Db1
                    , entity [ position -1.5 2.4 2 ]
                        (db1
                            |> List.indexedMap
                                (\i { id, name } ->
                                    plane
                                        [ position 0 ((toFloat i - 1) * 0.75) 0
                                        , height 0.3
                                        , width 1
                                        , color <| rgb 255 255 0
                                        , onClick <| SelectPerson Db1 id
                                        ]
                                        [ text
                                            [ attribute "value" name
                                            , color <| rgb 255 0 0
                                            , position -0.5 0 0
                                            ]
                                            []
                                        ]
                                )
                        )
                    , entity [ position 1.5 2.4 2 ]
                        (db2
                            |> List.indexedMap
                                (\i { id, name } ->
                                    plane
                                        [ position 0 ((toFloat i - 1) * 0.75) 0
                                        , height 0.3
                                        , width 1
                                        , color <| rgb 255 255 0
                                        , onClick <| SelectPerson Db2 id
                                        ]
                                        [ text
                                            [ attribute "value" name
                                            , color <| rgb 255 0 0
                                            , position -0.5 0 0
                                            ]
                                            []
                                        ]
                                )
                        )
                    , plane
                        [ position 2 0 1
                        , height 9
                        , width 3
                        , color <| rgb 6 181 204
                        ]
                        []
                    , header Db2
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


header : Db -> Html Msg
header db =
    let
        txt =
            case db of
                Db1 ->
                    "DB 1"

                Db2 ->
                    "DB 2"

        pos =
            case db of
                Db1 ->
                    -1.5

                Db2 ->
                    1.5
    in
    plane
        [ height 0.3
        , width 1
        , position pos 3.5 2
        , color <| rgb 0 0 139
        , onClick <| SelectDb db
        ]
        [ text
            [ attribute "value" txt
            , color <| rgb 240 248 255
            ]
            []
        ]


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
        ]
        []


decodeData : Decoder (List Person)
decodeData =
    Decode.list decodePerson


decodePerson : Decoder Person
decodePerson =
    Decode.map3 Person
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)

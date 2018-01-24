port module Main exposing (main)

import AFrame exposing (entity, scene)
import AFrame.Animations exposing (repeat)
import AFrame.Primitives exposing (box, plane, sky)
import AFrame.Primitives.Attributes exposing (color, height, metalness, position, rotation, roughness, transparent, width)
import AFrame.Primitives.Camera exposing (camera)
import AFrame.Primitives.Cursor exposing (cursor)
import Color exposing (rgb)
import Html
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
                        case model.selection of
                            Pending ->
                                ( { model | selection = Moving db str }
                                , Cmd.none
                                )

                            Moving db_ id ->
                                if db == db_ then
                                    ( { model | selection = Pending }, Cmd.none )
                                else
                                    case db of
                                        Db1 ->
                                            ( { model | selection = Pending }
                                            , moveToDb1 id
                                            )

                                        Db2 ->
                                            ( { model | selection = Pending }
                                            , moveToDb2 id
                                            )
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
                    , plane
                        [ height 0.3
                        , width 1
                        , position -1.5 3.5 2
                        , color <| rgb 0 0 139
                        ]
                        []
                    , entity []
                        (db1
                            |> List.indexedMap
                                (\i { id } ->
                                    plane
                                        [ position 0 ((toFloat i + 1) * -0.5) 0
                                        , height 0.3
                                        , width 1
                                        , color <| rgb 255 255 0
                                        , onClick <| SelectPerson Db1 id
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
                    , plane
                        [ height 0.3
                        , width 1
                        , position 1.5 3.5 2
                        , color <| rgb 0 0 139
                        ]
                        []
                    , entity []
                        (db2
                            |> List.indexedMap
                                (\i { id } ->
                                    plane
                                        [ position 0 ((toFloat i + 1) * -0.5) 0
                                        , height 0.3
                                        , width 1
                                        , color <| rgb 255 255 0
                                        , onClick <| SelectPerson Db2 id
                                        ]
                                        []
                                )
                        )
                    , plane
                        -- FLOOR
                        [ rotation -90 0 0
                        , width 10000
                        , height 10000
                        , repeat "10000 10000"
                        , transparent True
                        , metalness 0.6
                        , roughness 0.4
                        ]
                        []
                    , sky
                        [ color <| rgb 255 20 147
                        ]
                        []
                    , camera [ position 0 0.5 5 ]
                        [ cursor
                            []
                            [ box [ position 0 0 2 ] []
                            ]
                        ]
                    ]
        }


decodeData : Decoder (List Person)
decodeData =
    Decode.list decodePerson


decodePerson : Decoder Person
decodePerson =
    Decode.map3 Person
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)

module Main exposing (..)

import Html exposing (Html, div, input, text, label)
import Html.Attributes exposing (value, type_, readonly)
import Html.Events exposing (onInput)
import String
import Result


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = initialModel, view = view, update = update }


type alias Model =
    { billCost : String
    , tipPercent : String
    }


type Msg
    = BillCost String
    | TipPercent String


initialModel : Model
initialModel =
    { billCost = "0"
    , tipPercent = "0"
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        BillCost x ->
            { model | billCost = x }

        TipPercent x ->
            { model | tipPercent = x }



-- Etc


parseFloat : String -> Float
parseFloat string =
    string |> String.toFloat |> Result.withDefault 0


tipAmount : Model -> Float
tipAmount { billCost, tipPercent } =
    let
        billCostNum =
            parseFloat billCost

        tipPercentNum =
            parseFloat tipPercent
    in
        billCostNum * (tipPercentNum / 100.0)


totalCost : Model -> Float
totalCost model =
    tipAmount model + (parseFloat model.billCost)



-- View


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ label [] [ text "Bill Cost" ]
            , numberInput model.billCost BillCost
            ]
        , div []
            [ label [] [ text "Tip Percent" ]
            , numberInput model.tipPercent TipPercent
            ]
        , div []
            [ label [] [ text "Tip Amount" ]
            , input [ readonly True, value (model |> tipAmount |> toString) ] []
            ]
        , div []
            [ label [] [ text "Total Cost" ]
            , input [ readonly True, value (model |> totalCost |> toString) ] []
            ]
        ]


numberInput : String -> (String -> Msg) -> Html Msg
numberInput amount msg =
    input [ type_ "number", value amount, onInput msg ] []

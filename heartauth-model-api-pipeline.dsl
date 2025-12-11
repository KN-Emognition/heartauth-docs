workspace "C4 Processing Pipeline" "Left-to-right processing pipeline" {

    model {
        pipelineSystem = softwareSystem "Potok Predykcyjny" "System przetwarzania danych i predykcji" {

            preprocessing = container "Wstępne Przetwarzanie" "Data Processing" "Wstępne przetwarzanie sygnałów wejściowych"
            rlModel = container "Model Uczenie Reprezentacji" "Representation Learning" "Model przekształca odczyty"
            referenceBuilder = container "Konstrukcja referencji" "Reference Builder" "Budowa punktu referencyjnego"
            referenceComparison = container "Porównanie referencji" "Reference Comparator" "Porównanie sygnałów testowych z referencją"
        }

        preprocessing -> rlModel "Przekazuje dane"
        rlModel -> referenceBuilder "Przekształca dane"
        referenceBuilder -> referenceComparison "Przekazuje punkt referencyjny"
    }

    views {
        container pipelineSystem "Pipeline-C4" {
            include *
            autoLayout lr
        }

        theme default
    }
}

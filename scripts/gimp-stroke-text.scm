; Deepak Sharma
; MIT License
; December 2024

(script-fu-register
    "script-fu-stroke-text"
    "Stroke Text"
	"Create an antialiased stroke around text using the background color. Creates a temporary layer and merges the text down to it after processing"
    "Deepak Sharma"
    "Deepak Sharma"
    "2024-12-20"
    "RGB*, GRAY*, INDEXED*"
    SF-IMAGE "image" 0
    SF-DRAWABLE "layer" 0
    ; Default value can be adjusted by modifying the first parameter to SF-ADJUSTMENT
    SF-ADJUSTMENT "Stroke pixels" '(8 1 30 1 5 0 SF-SLIDER)
    SF-STRING "Layer append value" "-str"
)

(script-fu-menu-register  "script-fu-stroke-text" "<Image>/Layer")

(define (script-fu-stroke-text image layer steps layer-name)
    (let*   (
                (vectors (car (gimp-path-new-from-text-layer image layer))) 
                (in-w (car (gimp-image-get-width image)))
                (in-h (car (gimp-image-get-height image)))
                (new-name (string-append (car (gimp-item-get-name layer)) layer-name))
                (bg-layer 0)
                ; Create below the text layer to use merge-down later
                (layer-position (+ 1 (car (gimp-image-get-item-position image layer))))
                ; input 0 RGB, 1 Gray, 2 Indexed => output 1 RGBA, 3 GrayA, 5 IndexedA
                (layer-type (+ 1 (* 2 (car (gimp-image-get-base-type image)))))
            )

    ; Create a new layer with the same dimensions as the image. 100% Opacity and Normal mode
    (set! bg-layer (car (gimp-layer-new image in-w in-h layer-type new-name 100 LAYER-MODE-NORMAL)))

    (gimp-context-push)
    (gimp-image-undo-freeze image)

    (gimp-image-insert-layer image bg-layer 0 layer-position)
    (gimp-drawable-edit-fill bg-layer FILL-TRANSPARENT)
    (gimp-image-insert-path image vectors 0 -1)
    (gimp-image-select-item image CHANNEL-OP-REPLACE vectors)
    (gimp-selection-grow image steps)
    (gimp-drawable-edit-fill bg-layer FILL-BACKGROUND)
    (plug-in-autocrop-layer RUN-NONINTERACTIVE image bg-layer)
    (gimp-image-merge-down image layer 0)
    (gimp-selection-none image)

    (gimp-image-undo-thaw image)
    (gimp-context-pop)
    (gimp-displays-flush)
    )
)


Warning!!! Works bad with focus. You should tap at free space of view before tap undo/redo.
The reason - if you focused on element and tap undo that do something with the same element you get additional 
textViewDidEndEditing call after undo logic. It happens due to focus canceling when reload item.

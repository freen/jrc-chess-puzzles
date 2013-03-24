jrc-chess-puzzles
=================

The idea is to make an automated interface to John R. Coffey's chess tactics puzzles located at "entertainmentjourney.com"

  * The cli utility located in `jrc-parser-ruby` is used to:
    * Fetch and scrape these chess tactics puzzles & solutions
    * Convert the board positions into [Forsyth-Edwards Notation](http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)
    * Package the puzzle & solution data into a JSON object usable by a tactics GUI

  * Next is to:
    * Create automated parsing logic for the solution data
    * Make the interface

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

void main() {
  runApp(const MemoryPathDynamic());
}

class MemoryPathDynamic extends StatelessWidget {
  const MemoryPathDynamic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Path Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MemoryPathGame(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  late List<List<String?>> grid;  // The grid where items are placed.
  late List<String> draggableItems; // The items to be dragged and placed in the grid.
  final int gridSize = 3;  // The grid is 3x3.
  bool gameStarted = false;  // Flag to check if the game has started.
  int timeLeft = 30;  // Timer for the game.
  int score = 0;  // Player's score.
  bool gameOver = false;  // Flag to check if the game is over.
  bool allItemsPlaced = false;  // Flag to check if all items have been placed correctly.
  Random random = Random();  // Random instance for placing items in random grid spots.
  late Timer displayTimer;  // Timer to display the items for 3 seconds at the beginning.
  late Timer gameTimer;  // Timer to countdown the game time.

  GameProvider() {
    _startGame();
  }

  ///=============================GAME START=====================================>>>
  // Method to start the game, initialize grid, draggable items, and randomize item placement.
  void _startGame() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null)); // Initialize grid with nulls.
    draggableItems = [];

    // List of items to be dragged.
    List<String> items = ['🍎', '🍌', '🍇', '🍓', '🍍', '🍒'];

    // Randomly place items in the grid.
    for (int i = 0; i < gridSize; i++) {
      int x = random.nextInt(gridSize);
      int y = random.nextInt(gridSize);

      // Ensure that no two items occupy the same grid spot.
      while (grid[y][x] != null) {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      }

      grid[y][x] = items[i];
      draggableItems.add(items[i]);
    }

    draggableItems.shuffle(); // Shuffle the items to randomize their order.

    // Show items for 3 seconds, then hide them and start the game.
    displayTimer = Timer(const Duration(seconds: 3), () {
      gameStarted = true; // Game has started after 3 seconds.
      grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null)); // Clear the grid.
      _startGameTimer(); // Start the game timer.
      notifyListeners(); // Notify listeners (UI) to rebuild.
    });
  }

  ///=============================START GAME TIMER=======================================>>>
  // Starts a countdown timer for the game.
  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        gameTimer.cancel();
        _endGame(false); // If time runs out, end the game with failure.
      }
      notifyListeners(); // Notify listeners to update the UI.
    });
  }

  ///============================== GAME END===========================================>>>
  // Ends the game, either with success or failure.
  void _endGame(bool success) {
    gameOver = true;
    allItemsPlaced = success; // Check if all items were placed correctly.
    gameTimer.cancel(); // Stop the game timer.
    notifyListeners(); // Notify listeners to rebuild UI.
  }

  ///=================================RESTART GAME=============================>>>
  // Method to restart the game, resetting all variables.
  void restartGame() {
    gameStarted = false;
    gameOver = false;
    timeLeft = 30;
    score = 0;
    _startGame(); // Start a new game after restarting.
    notifyListeners(); // Notify listeners to rebuild UI.
  }

  ///==================================CHECK COMPLETION===========================>>>
  // Checks if all items have been placed correctly in the grid.
  void _checkCompletion() {
    if (draggableItems.isEmpty) { // If no items are left to drag, check if the game is complete.
      _endGame(true); // End the game with success if all items are placed.
    }
  }

  // Method that handles what happens when an item is dropped onto a grid cell.
  void onAcceptItem(String item, int x, int y) {
    grid[y][x] = item; // Place the item in the grid.
    draggableItems.remove(item); // Remove the item from draggable list.
    score += 10; // Increase score.
    _checkCompletion(); // Check if the game is completed.
    notifyListeners(); // Notify listeners to update the UI.
  }
}



class MemoryPathGame extends StatelessWidget {
  const MemoryPathGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Memory Path Game'),
        actions: [
          // Refresh button to restart the game.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameProvider>().restartGame(); // Restart the game when clicked.
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          // If the game is over, show win or lose message.
          return game.gameOver
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display win or game over message.
                Text(
                  game.allItemsPlaced ? '🎉 You Win! 🎉' : '💥 Game Over 💥',
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 20),
                // Button to restart the game.
                ElevatedButton(
                  onPressed: () {
                    game.restartGame();
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          )
              : Column(
            children: [
              /// Timer progress indicator.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  value: game.timeLeft / 30,
                  color: Colors.blue,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Expanded(
                /// Grid view of draggable items.
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: game.gridSize,
                  ),
                  itemCount: game.gridSize * game.gridSize,
                  itemBuilder: (context, index) {
                    int x = index % game.gridSize;
                    int y = index ~/ game.gridSize;
                    return DragTarget<String>(
                      onWillAccept: (data) => game.grid[y][x] == null, // Only accept if grid cell is empty.
                      onAccept: (data) {
                        game.onAcceptItem(data, x, y); // Place the item in the grid.
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: candidateData.isEmpty
                                ? Colors.grey[300]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              game.grid[y][x] ?? '',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),


              ///========================= Display the draggable items======================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: game.draggableItems.map((item) {
                  return Draggable<String>(
                    data: item,
                    feedback: Material(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 30, color: Colors.black),
                      ),
                    ),
                    childWhenDragging: Container(),
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'dart:math';
//
// void main() {
//   runApp(MemoryPathGame());
// }
//
// class MemoryPathGame extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Memory Path',
//       home: MemoryPathHome(),
//     );
//   }
// }
//
// class MemoryPathHome extends StatefulWidget {
//   @override
//   _MemoryPathHomeState createState() => _MemoryPathHomeState();
// }
//
// class _MemoryPathHomeState extends State<MemoryPathHome> {
//   late List<List<bool>> grid; // Stores the grid's secret path
//   List<List<bool>> userGrid = []; // Stores the user's tapped path
//   int gridSize = 3; // Initial grid size
//   late Timer timer;
//   bool showPath = true; // Show or hide the path
//   bool gameOver = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _generateGrid();
//     _startPathDisplay();
//   }
//
//   void _generateGrid() {
//     grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
//     userGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
//     _generatePath();
//   }
//
//   void _generatePath() {
//     // Randomly generate a path
//     Random random = Random();
//     int currentX = 0;
//     int currentY = 0;
//     grid[currentY][currentX] = true;
//
//     for (int i = 0; i < gridSize + 2; i++) {
//       int direction = random.nextInt(4);
//       switch (direction) {
//         case 0: // Move up
//           if (currentY > 0) currentY--;
//           break;
//         case 1: // Move down
//           if (currentY < gridSize - 1) currentY++;
//           break;
//         case 2: // Move left
//           if (currentX > 0) currentX--;
//           break;
//         case 3: // Move right
//           if (currentX < gridSize - 1) currentX++;
//           break;
//       }
//       grid[currentY][currentX] = true;
//     }
//   }
//
//   void _startPathDisplay() {
//     timer = Timer(Duration(seconds: 3), () {
//       setState(() {
//         showPath = false;
//       });
//     });
//   }
//
//   void _handleTap(int x, int y) {
//     if (showPath || gameOver) return;
//
//     setState(() {
//       userGrid[y][x] = true;
//
//       // Check if user's path matches the grid
//       if (userGrid[y][x] != grid[y][x]) {
//         gameOver = true;
//         _showGameOverDialog(false);
//       } else if (_checkWin()) {
//         _showGameOverDialog(true);
//       }
//     });
//   }
//
//   bool _checkWin() {
//     for (int y = 0; y < gridSize; y++) {
//       for (int x = 0; x < gridSize; x++) {
//         if (grid[y][x] != userGrid[y][x]) return false;
//       }
//     }
//     return true;
//   }
//
//   void _showGameOverDialog(bool won) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(won ? 'You Won!' : 'Game Over'),
//           content: Text(won
//               ? 'Congratulations! Ready for the next level?'
//               : 'You tapped the wrong path!'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 if (won) {
//                   setState(() {
//                     gridSize++;
//                     _generateGrid();
//                     showPath = true;
//                     _startPathDisplay();
//                   });
//                 } else {
//                   setState(() {
//                     gridSize = 3;
//                     gameOver = false;
//                     _generateGrid();
//                     showPath = true;
//                     _startPathDisplay();
//                   });
//                 }
//               },
//               child: Text(won ? 'Next Level' : 'Restart'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Memory Path'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               showPath ? 'Memorize the Path!' : 'Follow the Path!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: gridSize,
//                 childAspectRatio: 1,
//               ),
//               itemCount: gridSize * gridSize,
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 int x = index % gridSize;
//                 int y = index ~/ gridSize;
//                 return GestureDetector(
//                   onTap: () => _handleTap(x, y),
//                   child: Container(
//                     margin: EdgeInsets.all(4.0),
//                     decoration: BoxDecoration(
//                       color: showPath
//                           ? (grid[y][x] ? Colors.green : Colors.grey[300])
//                           : (userGrid[y][x] ? Colors.blue : Colors.grey[300]),
//                       border: Border.all(color: Colors.black),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


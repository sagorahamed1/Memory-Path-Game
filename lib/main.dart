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
  late List<List<String?>> grid;
  late List<String> draggableItems;
  final int gridSize = 3;
  bool gameStarted = false;
  int timeLeft = 30;
  int score = 0;
  bool gameOver = false;
  bool allItemsPlaced = false;
  Random random = Random();
  late Timer displayTimer;
  late Timer gameTimer;

  GameProvider() {
    _startGame();
  }

  void _startGame() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
    draggableItems = [];

    List<String> items = ['🍎', '🍌', '🍇', '🍓', '🍍', '🍒'];

    for (int i = 0; i < gridSize; i++) {
      int x = random.nextInt(gridSize);
      int y = random.nextInt(gridSize);

      while (grid[y][x] != null) {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      }

      grid[y][x] = items[i];
      draggableItems.add(items[i]);
    }

    draggableItems.shuffle();

    displayTimer = Timer(const Duration(seconds: 3), () {
      gameStarted = true;
      grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
      _startGameTimer();
      notifyListeners();
    });
  }

  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        gameTimer.cancel();
        _endGame(true); // Game ends with a "win" when time runs out.
      }
      notifyListeners();
    });
  }

  void _endGame(bool success) {
    gameOver = true;
    allItemsPlaced = success || draggableItems.isEmpty;
    gameTimer.cancel();
    notifyListeners();
  }

  void restartGame() {
    gameStarted = false;
    gameOver = false;
    timeLeft = 20;
    score = 0;
    _startGame();
    notifyListeners();
  }

  void _checkCompletion() {
    if (draggableItems.isEmpty) {
      _endGame(true); // End the game with a "win".
    }
  }

  void onAcceptItem(String item, int x, int y) {
    grid[y][x] = item;
    print("===========================================${grid[y][x]}");
    print("===========================================${item}");
    print("===========================================${x}");
    print("===========================================${y}");
    print("===========================================${grid}");
    print("===========================================${draggableItems}");
    print("===========================================${draggableItems}");
    draggableItems.remove(item);
    score += 10;
    _checkCompletion();
    notifyListeners();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameProvider>().restartGame();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<GameProvider>(
          builder: (context, game, child) {
            return game.gameOver
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎉 You Win! 🎉',
                    style: TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 20),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    value: game.timeLeft / 30,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: game.gridSize,
                    ),
                    itemCount: game.gridSize * game.gridSize,
                    itemBuilder: (context, index) {
                      int x = index % game.gridSize;
                      int y = index ~/ game.gridSize;

                      return DragTarget<String>(
                        onWillAccept: (data) => game.grid[y][x] == null,
                        onAccept: (data) {
                          game.onAcceptItem(data, x, y);
                        },
                        builder: (context, candidateData, rejectedData) {
                          print("========================= can : $candidateData");
                          print("========================= rej : $rejectedData");

                          // Decide the color based on candidateData and rejectedData
                          Color cellColor;
                          if (candidateData.isNotEmpty) {
                            cellColor = Colors.green; // Highlight green for valid drag
                          } else if (rejectedData.isNotEmpty) {
                            cellColor = Colors.red; // Highlight red for invalid drag
                          } else {
                            cellColor = Colors.grey[300]!; // Default color
                          }

                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: cellColor,
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




import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MemoryPathDynamic());
}

class MemoryPathDynamic extends StatelessWidget {
  const MemoryPathDynamic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Path Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MemoryPathGame(),
    );
  }
}

class MemoryPathGame extends StatefulWidget {
  const MemoryPathGame({super.key});

  @override
  MemoryPathGameState createState() => MemoryPathGameState();
}


class MemoryPathGameState extends State<MemoryPathGame> {
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

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    displayTimer.cancel();
    if (gameTimer.isActive) gameTimer.cancel();
    super.dispose();
  }


  ///=============================GAME START=====================================>>>

  void _startGame() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
    draggableItems = [];

    ///===========================ITEMS OF FOOD===============================>>>>

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
      setState(() {
        gameStarted = true;
        grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));
        _startGameTimer();
      });
    });
  }


  ///=============================START GAME TIME=======================================>>>

  void _startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          gameTimer.cancel();
          _endGame(false);
        }
      });
    });
  }


  ///============================== GAME END===========================================>>>


  void _endGame(bool success) {
    setState(() {
      gameOver = true;
      allItemsPlaced = success;
    });
    if (gameTimer.isActive) gameTimer.cancel();
  }


  ///=================================RESTART GAME=============================>>>


  void _restartGame() {
    setState(() {
      gameStarted = false;
      gameOver = false;
      timeLeft = 30;
      score = 0;
    });
    _startGame();
  }


  ///==================================CHECK COMPLETION===========================>>>

  void _checkCompletion() {
    if (draggableItems.isEmpty) {
      _endGame(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      ///=====================================APP BAR =====================================>>>

      appBar: AppBar(
        centerTitle: true,
        title: const Text('Memory Path Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartGame,
          ),
        ],
      ),


      ///==================================BODY SECTION===================================>>>
      ///==When game is over show you are wid or game is over now try again===>

      body: gameOver
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              allItemsPlaced ? '🎉 You Win! 🎉' : '💥 Game Over 💥',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartGame,
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
              value: timeLeft / 30,
              color: Colors.blue,
              backgroundColor: Colors.grey[300],
            ),
          ),


          ///======================FOODS GRID ====================================>>>

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int x = index % gridSize;
                int y = index ~/ gridSize;
                return DragTarget<String>(
                  onWillAccept: (data) => grid[y][x] == null,
                  onAccept: (data) {
                    setState(() {
                      grid[y][x] = data;
                      draggableItems.remove(data);
                      score += 10;
                      _checkCompletion();
                    });
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
                          grid[y][x] ?? '',
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


          ///================================ALL FOOD HERE DRAG ABLE=======================>>>


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: draggableItems.map((item) {
              return Draggable<String>(
                data: item,
                feedback: Material(
                  child: Text(
                    item,
                    style: const TextStyle(
                        fontSize: 30, color: Colors.black),
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
                    style: const TextStyle(
                        fontSize: 24, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
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


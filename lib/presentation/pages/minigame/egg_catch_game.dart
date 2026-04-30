import 'package:flutter/material.dart';
import '../../../core/services/sensor_service.dart';

class EggCatchGame extends StatefulWidget {
  const EggCatchGame({super.key});
  @override
  State<EggCatchGame> createState() => _EggCatchGameState();
}

class _EggCatchGameState extends State<EggCatchGame>
    with TickerProviderStateMixin {
  double basketX = 0.5; // 0.0 - 1.0
  List<_FallingEgg> eggs = [];
  int score = 0;
  bool isPlaying = false;
  late AnimationController _gameLoop;

  @override
  void initState() {
    super.initState();
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 999),
    )..addListener(_update);

    SensorService.instance.onAccelerometerChanged = (x, y) {
      // Tilt kiri-kanan untuk gerakkan keranjang
      setState(() {
        basketX = (basketX - x * 0.02).clamp(0.0, 1.0);
      });
    };
  }

  void _startGame() {
    setState(() {
      score = 0;
      eggs.clear();
      isPlaying = true;
    });
    SensorService.instance.startListening();
    _gameLoop.forward();
    _spawnEggs();
  }

  void _spawnEggs() async {
    while (isPlaying) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!isPlaying) break;
      setState(() {
        eggs.add(
          _FallingEgg(
            x: 0.1 + (eggs.length % 8) * 0.1,
            y: 0.0,
            speed: 0.004 + (score * 0.0001),
          ),
        );
      });
    }
  }

  void _update() {
    if (!isPlaying) return;
    setState(() {
      for (var egg in eggs) {
        egg.y += egg.speed;
      }
      // Collision detection
      eggs.removeWhere((egg) {
        final caught = egg.y > 0.82 && (egg.x - basketX).abs() < 0.12;
        if (caught) score++;
        return caught || egg.y > 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primaryContainer,
      appBar: AppBar(title: Text('🥚 Tangkap Telur! — Score: $score')),
      body: GestureDetector(
        onTap: isPlaying ? null : _startGame,
        child: Stack(
          children: [
            // Eggs
            ...eggs.map(
              (egg) => Positioned(
                left: MediaQuery.of(context).size.width * egg.x,
                top: MediaQuery.of(context).size.height * egg.y,
                child: const Text('🥚', style: TextStyle(fontSize: 32)),
              ),
            ),
            // Basket
            Positioned(
              left: MediaQuery.of(context).size.width * basketX - 30,
              bottom: 60,
              child: Container(
                width: 70,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🧺', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            if (!isPlaying)
              Center(
                child: FilledButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Mulai Main!'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    SensorService.instance.stopListening();
    super.dispose();
  }
}

class _FallingEgg {
  double x, y, speed;
  _FallingEgg({required this.x, required this.y, required this.speed});
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Data models for Debate Categories and Speeches
class DebateCategory {
  final String name;
  final List<Speech> speeches;
  final int prepTime;

  DebateCategory({
    required this.name,
    required this.speeches,
    required this.prepTime,
  });
}

class Speech {
  final String title;
  final int duration; // in seconds
  bool completed;

  Speech({required this.title, required this.duration, this.completed = false});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HS Debate Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2D5BA9), // Deep blue
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFD5E3FF), // Light blue for containers
          onPrimaryContainer: Color(0xFF001B3F),
          secondary: Color(0xFFE25144), // Original red accent
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFFD6D3), // Light red container
          onSecondaryContainer: Color(0xFF410002),
          tertiary: Color(0xFFFF6B5B), // Lighter red accent
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFFFDAD6),
          onTertiaryContainer: Color(0xFF410002),
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          surface: Color(0xFFFFFFFF), // Pure white for cards
          onSurface: Color(0xFF001F25),
          surfaceContainerHighest: Color(
            0xFFF3F3F3,
          ), // Subtle gray for variants
          onSurfaceVariant: Color(0xFF44474F),
          outline: Color(0xFF74777F),
          outlineVariant: Color(0xFFC4C6D0),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF001F25),
          onInverseSurface: Color(0xFFE6F3FF),
          inversePrimary: Color(0xFFA6C8FF),
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFA6C8FF), // Light blue
          onPrimary: Color(0xFF003062),
          primaryContainer: Color(0xFF004689), // Deep blue container
          onPrimaryContainer: Color(0xFFD5E3FF),
          secondary: Color(0xFFFFB4AB), // Light red accent
          onSecondary: Color(0xFF690005),
          secondaryContainer: Color(0xFF93000A),
          onSecondaryContainer: Color(0xFFFFDAD6),
          tertiary: Color(0xFFFFB4AB), // Light red accent
          onTertiary: Color(0xFF690005),
          tertiaryContainer: Color(0xFF93000A),
          onTertiaryContainer: Color(0xFFFFDAD6),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          surface: Color(0xFF001F25), // Slightly lighter surface
          onSurface: Color(0xFFE6F3FF),
          surfaceContainerHighest: Color(
            0xFF252629,
          ), // Subtle dark gray for variants
          onSurfaceVariant: Color(0xFFC4C6D0),
          outline: Color(0xFF8E9099),
          outlineVariant: Color(0xFF44474F),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFE6F3FF),
          onInverseSurface: Color(0xFF001F25),
          inversePrimary: Color(0xFF2D5BA9),
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// HomeScreen uses a TabController to switch between the Debate Timer and Stopwatch tabs
// Global keys to access screen states
final GlobalKey<_DebateTimerScreenState> debateTimerKey =
    GlobalKey<_DebateTimerScreenState>();
final GlobalKey<_StopwatchScreenState> stopwatchKey =
    GlobalKey<_StopwatchScreenState>();

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Widget _buildHelpSection(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: 28),
          child: Text(description, style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  late TabController _tabController;
  final List<Tab> myTabs = <Tab>[
    Tab(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty),
          SizedBox(width: 8),
          Text('Debate Timer'),
        ],
      ),
    ),
    Tab(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined),
          SizedBox(width: 8),
          Text('Stopwatch'),
        ],
      ),
    ),
    Tab(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_outlined),
          SizedBox(width: 8),
          Text('Coin Flip'),
        ],
      ),
    ),
  ];

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Round'),
          content: Text('Are you sure you want to reset all timers?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Reset all components
                debateTimerKey.currentState?.resetAll();
                stopwatchKey.currentState?.resetStopwatch();
                Navigator.of(context).pop();
              },
              child: Text('Reset All'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debate Timer'),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: _showResetConfirmation,
            tooltip: 'Reset Everything',
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Help',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildHelpSection(
                            context,
                            Icons.check_box_outlined,
                            'Checkboxes',
                            'Indicate a speech is complete. Check marks can be added and removed manually, but are added automatically at the conclusion of the timer.',
                          ),
                          SizedBox(height: 16),
                          _buildHelpSection(
                            context,
                            Icons.timer,
                            'Prep Timer',
                            'Allows you to start and stop your rolling prep time.',
                          ),
                          SizedBox(height: 16),
                          _buildHelpSection(
                            context,
                            Icons.format_list_bulleted,
                            'Debate Selector',
                            'Choose your debate format.',
                          ),
                          SizedBox(height: 16),
                          _buildHelpSection(
                            context,
                            Icons.restart_alt,
                            'Master Reset',
                            'The reset button in the top right will reset all timers and stopwatches.',
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.people, color: Theme.of(context).colorScheme.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Credits',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Padding(
                                padding: EdgeInsets.only(left: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                                        children: [
                                          TextSpan(text: 'Art: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: 'Rachel Miller'),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                                        children: [
                                          TextSpan(text: 'Programming: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: 'Grant DeCapua'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Help',
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
        bottom: TabBar(controller: _tabController, tabs: myTabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DebateTimerScreen(key: debateTimerKey),
          StopwatchScreen(key: stopwatchKey),
          CoinFlipScreen(),
        ],
      ),
    );
  }
}

//
// Debate Timer Screen
//
class DebateTimerScreen extends StatefulWidget {
  const DebateTimerScreen({super.key});

  @override
  _DebateTimerScreenState createState() => _DebateTimerScreenState();
}

class _DebateTimerScreenState extends State<DebateTimerScreen>
    with SingleTickerProviderStateMixin {
  // Sample debate categories and preset timers for speeches
  List<DebateCategory> categories = [
    DebateCategory(
      name: 'Public Forum',
      speeches: [
        Speech(title: 'First Speaker (A)', duration: 240),
        Speech(title: 'First Speaker (B)', duration: 240),
        Speech(title: 'First Crossfire', duration: 180),
        Speech(title: 'Second Speaker (A)', duration: 240),
        Speech(title: 'Second Speaker (B)', duration: 240),
        Speech(title: 'Second Crossfire', duration: 180),
        Speech(title: 'Summary (A)', duration: 180),
        Speech(title: 'Summary (B)', duration: 180),
        Speech(title: 'Grand Crossfire', duration: 180),
        Speech(title: 'Final Focus (A)', duration: 120),
        Speech(title: 'First Speech (B)', duration: 120),
      ],
      prepTime: 180,
    ),
    DebateCategory(
      name: 'Lincoln-Douglas',
      speeches: [
        Speech(title: 'Aff Constructive', duration: 360),
        Speech(title: 'Cross-Ex by Neg', duration: 180),
        Speech(title: 'Neg Constructive', duration: 420),
        Speech(title: 'Cross-Ex by Aff', duration: 180),
        Speech(title: 'First Aff Rebuttal', duration: 240),
        Speech(title: 'Neg Rebuttal', duration: 360),
        Speech(title: 'Second Aff Rebuttal', duration: 180),
      ],
      prepTime: 240,
    ),
    DebateCategory(
      name: 'Policy',
      speeches: [
        Speech(title: 'First AFF Constructive', duration: 480),
        Speech(title: '1AC Cross-Ex by 2 NC', duration: 180),
        Speech(title: 'First NEG Constructive', duration: 480),
        Speech(title: '1NC Cross-Ex by 1AC', duration: 180),
        Speech(title: 'Second AFF Constructive', duration: 480),
        Speech(title: '2AC Cross-Ex by 1NC', duration: 180),
        Speech(title: 'Second NEG Constructive', duration: 480),
        Speech(title: '2NC Cross-Ex by 2AC', duration: 180),
        Speech(title: 'First NEG Rebuttal', duration: 300),
        Speech(title: 'First AFF Rebuttal', duration: 300),
        Speech(title: 'Second NEG Rebuttal', duration: 300),
        Speech(title: 'Second AFF Rebuttal', duration: 300),
      ],
      prepTime: 300,
    ),
  ];

  DebateCategory? selectedCategory;

  // Prep timer state variables
  bool isPrepRunning = false;
  double prepElapsed = 0;
  late AnimationController _prepTimerController;

  // Easter egg variables
  int _tapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    // Default to the first category
    selectedCategory = categories.first;

    _prepTimerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: selectedCategory!.prepTime.toInt()),
    );
    _prepTimerController.value = 0;

    _prepTimerController.addListener(() {
      if (isPrepRunning) {
        setState(() {
          prepElapsed = _prepTimerController.value * selectedCategory!.prepTime;
        });
      }
    });
  }

  @override
  void dispose() {
    _prepTimerController.dispose();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void togglePrepTimer() {
    if (isPrepRunning) {
      _prepTimerController.stop();
      setState(() {
        isPrepRunning = false;
      });
    } else {
      final remaining = 1.0 - (prepElapsed / selectedCategory!.prepTime);
      _prepTimerController.duration = Duration(
        seconds: (remaining * selectedCategory!.prepTime).round(),
      );
      _prepTimerController.forward(
        from: prepElapsed / selectedCategory!.prepTime,
      );
      setState(() {
        isPrepRunning = true;
      });
    }
  }

  void resetPrepTimer() {
    _prepTimerController.stop();
    setState(() {
      isPrepRunning = false;
      prepElapsed = 0;
    });
  }

  void resetAll() {
    _prepTimerController.stop();
    setState(() {
      // Reset prep timer
      isPrepRunning = false;
      prepElapsed = 0;

      // Reset category and reset all speech completion states
      selectedCategory?.speeches.forEach((speech) => speech.completed = false);

      // Reset back to first category
      selectedCategory = categories.first;
    });
  }

  String formatTime(double seconds) {
    int m = seconds.floor() ~/ 60;
    int s = seconds.floor() % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown to choose debate category
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DebateCategory>(
                value: selectedCategory,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (DebateCategory? newCategory) {
                  setState(() {
                    selectedCategory = newCategory;
                    prepElapsed = 0;
                  });
                },
                items:
                    categories.map((DebateCategory category) {
                      return DropdownMenuItem<DebateCategory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_list_bulleted,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(category.name, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        // List of preset timers for the selected category
        Expanded(
          child: ListView.builder(
            itemCount: selectedCategory?.speeches.length ?? 0,
            itemBuilder: (context, index) {
              Speech speech = selectedCategory!.speeches[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                elevation: 1,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.shadow.withOpacity(0.2),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  title: Text(
                    speech.title,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Duration: ${formatTime(speech.duration.toDouble())}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () async {
                      if (speech.completed) {
                        bool? shouldUncheck = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Uncheck Speech'),
                              content: Text(
                                'Do you want to uncheck this speech?',
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Uncheck'),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldUncheck == true) {
                          setState(() {
                            speech.completed = false;
                          });
                        }
                      } else {
                        setState(() {
                          speech.completed = true;
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            speech.completed
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                      ),
                      child:
                          speech.completed
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(
                                Icons.radio_button_unchecked,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                    ),
                  ),
                  onTap: () async {
                    // Navigate to the Speech Timer confirmation screen
                    bool? completed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpeechTimerScreen(speech: speech),
                      ),
                    );
                    if (completed != null && completed) {
                      setState(() {
                        speech.completed = true;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        // Stylized separator
        Padding(
          padding: EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Running prep time counter at the bottom
        Padding(
          padding: EdgeInsets.fromLTRB(36, 0, 36, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prep Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 1),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tapCount++;
                          if (_tapCount == 10) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  titlePadding: EdgeInsets.zero,
                                  title: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  insetPadding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          height: 200,
                                          child: Image.asset(
                                            'assets/images/linus_ascii.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          child: Text(
                                            'Made with love and support from Rachel and Linus for an organization that gave me more than I can ever repay.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                  actions: [],
                                );
                              },
                            );
                          }
                          // Reset tap count after 2 seconds of no tapping
                          _tapResetTimer?.cancel();
                          _tapResetTimer = Timer(Duration(seconds: 2), () {
                            setState(() {
                              _tapCount = 0;
                            });
                          });
                        });
                      },
                      child: Text(
                        formatTime(selectedCategory!.prepTime - prepElapsed),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: togglePrepTimer,
                          icon: Icon(
                            isPrepRunning
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Reset Prep Timer'),
                                  content: Text(
                                    'Are you sure you want to reset the prep timer?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        resetPrepTimer();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Reset'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.refresh,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// Speech Timer Screen with Start/Stop confirmation
//
class SpeechTimerScreen extends StatefulWidget {
  final Speech speech;

  const SpeechTimerScreen({super.key, required this.speech});

  @override
  _SpeechTimerScreenState createState() => _SpeechTimerScreenState();
}

class _SpeechTimerScreenState extends State<SpeechTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool timerStarted = false;

  double get remainingTime =>
      widget.speech.duration.toDouble() * (1 - _timerController.value);

  @override
  void initState() {
    super.initState();

    // Setup main timer animation
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.speech.duration.toInt()),
    );
    _timerController.value = 0; // Start at 0 progress

    // Setup pulse animation for low time warning
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _timerController.addListener(() {
      if (_timerController.isCompleted) {
        _showTimesUpScreen();
      }
    });
  }

  void _showTimesUpScreen() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.red[400]!.withOpacity(0.95),
      builder:
          (context) => GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              Navigator.of(
                context,
              ).pop(true); // Return to main screen with completed status
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[400]!.withOpacity(0.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Time is Up',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tap to close...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startTimer() {
    if (timerStarted) return;
    setState(() {
      timerStarted = true;
    });
    _timerController.forward();
  }

  void stopTimer() {
    _timerController.stop();
    Navigator.pop(context, false);
  }

  String formatTime(double seconds) {
    int m = seconds.floor() ~/ 60;
    int s = seconds.floor() % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Color getIndicatorColor() {
    double percentage = remainingTime / widget.speech.duration;
    if (percentage > 0.5) {
      return Colors.green.shade400; // Soft green
    } else if (percentage > 0.25) {
      return Colors.yellow.shade400; // Soft yellow
    } else {
      return Colors.red.shade400; // Soft red
    }
  }

  double getProgress() {
    return remainingTime / widget.speech.duration;
  }

  @override
  Widget build(BuildContext context) {
    bool isLowTime = remainingTime <= 10 && timerStarted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speech.title),
        backgroundColor:
            timerStarted ? getIndicatorColor().withOpacity(0.2) : null,
      ),
      body: GestureDetector(
        onTap: !timerStarted ? startTimer : null,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _timerController,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: 1 - _timerController.value,
                        strokeWidth: 12,
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          getIndicatorColor(),
                        ),
                      );
                    },
                  ),
                ),
                // Animated time display
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isLowTime ? _pulseAnimation.value : 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatTime(remainingTime),
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: isLowTime ? getIndicatorColor() : null,
                            ),
                          ),
                          if (!timerStarted)
                            Text(
                              'Tap to Start',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoinFlipScreen extends StatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  _CoinFlipScreenState createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool? isHeads;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flipCoin() {
    if (isAnimating) return;

    setState(() {
      isAnimating = true;
      isHeads = Random.secure().nextBool();
    });

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_animation.value * 12.0 * pi),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]
                                : Colors.grey[300],
                      ),
                      child: Center(
                        child:
                            isAnimating
                                ? Container()
                                : Padding(
                                  padding:
                                      isHeads == null || isHeads!
                                          ? EdgeInsets.fromLTRB(
                                            17.0,
                                            30.0,
                                            15.0,
                                            10.0,
                                          ) // Left, Top, Right, Bottom - more padding on top to move image down
                                          : EdgeInsets.all(15.0),
                                  child: Image.asset(
                                    isHeads == null || isHeads!
                                        ? 'assets/images/heads.png'
                                        : 'assets/images/tails.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  if (isHeads != null && !isAnimating)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHeads! ? 'Heads!' : 'Tails!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: flipCoin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text('Flip Coin', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

//
// Stopwatch Screen
//
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  int stopwatchElapsed = 0; // milliseconds
  Timer? stopwatchTimer;
  bool isStopwatchRunning = false;
  List<int> lapTimes = [];

  void startStopwatch() {
    if (isStopwatchRunning) return;
    stopwatchTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        stopwatchElapsed += 100;
      });
    });
    setState(() {
      isStopwatchRunning = true;
    });
  }

  void stopStopwatch() {
    stopwatchTimer?.cancel();
    setState(() {
      isStopwatchRunning = false;
    });
  }

  void resetStopwatch() {
    stopwatchTimer?.cancel();
    setState(() {
      stopwatchElapsed = 0;
      isStopwatchRunning = false;
      lapTimes.clear();
    });
  }

  void recordLap() {
    setState(() {
      lapTimes.add(stopwatchElapsed);
    });
  }

  String formatStopwatchTime(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    int m = seconds ~/ 60;
    int s = seconds % 60;
    int ms = (milliseconds % 1000) ~/ 100;
    return '$m:${s.toString().padLeft(2, '0')}.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    formatStopwatchTime(stopwatchElapsed),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed:
                                  isStopwatchRunning
                                      ? stopStopwatch
                                      : startStopwatch,
                              icon: Icon(
                                isStopwatchRunning
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: recordLap,
                              icon: Icon(
                                Icons.flag_outlined,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: resetStopwatch,
                              icon: Icon(
                                Icons.refresh,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            if (lapTimes.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'LAPS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: lapTimes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          formatStopwatchTime(lapTimes[index]),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

class JudgesPrepTimers extends StatefulWidget {
  final int prepTime; // Prep time in seconds from the selected category
  
  const JudgesPrepTimers({
    super.key, 
    required this.prepTime, // Require the prep time
  });

  @override
  JudgesPrepTimersState createState() => JudgesPrepTimersState();
}

class JudgesPrepTimersState extends State<JudgesPrepTimers> {
  late int affProPrepTimeRemaining;
  late int negConPrepTimeRemaining;
  Timer? affProPrepTimer;
  Timer? negConPrepTimer;
  bool isTeamAPrepRunning = false;
  bool isTeamBPrepRunning = false;
  bool showTeamAOnly = false;
  bool showTeamBOnly = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the full prep time
    affProPrepTimeRemaining = widget.prepTime;
    negConPrepTimeRemaining = widget.prepTime;
    print("JudgesPrepTimers initialized with prep time: ${widget.prepTime}");
  }
  
  @override
  void didUpdateWidget(JudgesPrepTimers oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the prep time changes, update the remaining time
    if (oldWidget.prepTime != widget.prepTime) {
      print("Prep time changed from ${oldWidget.prepTime} to ${widget.prepTime}");
      // Always update the prep time if it changes
      setState(() {
        // Only reset if timers aren't running
        if (!isTeamAPrepRunning) {
          affProPrepTimeRemaining = widget.prepTime;
        }
        if (!isTeamBPrepRunning) {
          negConPrepTimeRemaining = widget.prepTime;
        }
      });
    }
  }

  @override
  void dispose() {
    affProPrepTimer?.cancel();
    negConPrepTimer?.cancel();
    super.dispose();
  }

  // AFF/PRO timer controls
  void startTeamAPrep() {
    if (isTeamAPrepRunning) return;
    
    affProPrepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (affProPrepTimeRemaining > 0) {
          affProPrepTimeRemaining--;
        } else {
          stopTeamAPrep();
        }
      });
    });
    
    setState(() {
      isTeamAPrepRunning = true;
      showTeamBOnly = false;
      showTeamAOnly = true;
    });
  }

  void stopTeamAPrep() {
    affProPrepTimer?.cancel();
    affProPrepTimer = null;
    
    setState(() {
      isTeamAPrepRunning = false;
    });
  }

  void resetTeamAPrep() {
    affProPrepTimer?.cancel();
    affProPrepTimer = null;
    
    setState(() {
      affProPrepTimeRemaining = widget.prepTime;
      isTeamAPrepRunning = false;
      showTeamAOnly = false;
    });
  }

  void incrementTeamAPrep() {
    if (!isTeamAPrepRunning) {
      setState(() {
        affProPrepTimeRemaining += 1;
      });
    }
  }

  void decrementTeamAPrep() {
    if (!isTeamAPrepRunning && affProPrepTimeRemaining > 0) {
      setState(() {
        affProPrepTimeRemaining -= 1;
      });
    }
  }

  // NEG/CON timer controls
  void startTeamBPrep() {
    if (isTeamBPrepRunning) return;
    
    negConPrepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (negConPrepTimeRemaining > 0) {
          negConPrepTimeRemaining--;
        } else {
          stopTeamBPrep();
        }
      });
    });
    
    setState(() {
      isTeamBPrepRunning = true;
      showTeamAOnly = false;
      showTeamBOnly = true;
    });
  }

  void stopTeamBPrep() {
    negConPrepTimer?.cancel();
    negConPrepTimer = null;
    
    setState(() {
      isTeamBPrepRunning = false;
    });
  }

  void resetTeamBPrep() {
    negConPrepTimer?.cancel();
    negConPrepTimer = null;
    
    setState(() {
      negConPrepTimeRemaining = widget.prepTime;
      isTeamBPrepRunning = false;
      showTeamBOnly = false;
    });
  }

  void incrementTeamBPrep() {
    if (!isTeamBPrepRunning) {
      setState(() {
        negConPrepTimeRemaining += 1;
      });
    }
  }

  void decrementTeamBPrep() {
    if (!isTeamBPrepRunning && negConPrepTimeRemaining > 0) {
      setState(() {
        negConPrepTimeRemaining -= 1;
      });
    }
  }

  // Reset both timers
  void resetAllPrep() {
    affProPrepTimer?.cancel();
    negConPrepTimer?.cancel();
    setState(() {
      affProPrepTimeRemaining = widget.prepTime;
      negConPrepTimeRemaining = widget.prepTime;
      isTeamAPrepRunning = false;
      isTeamBPrepRunning = false;
      showTeamAOnly = false;
      showTeamBOnly = false;
    });
  }

  String formatPrepTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Judges Prep Timers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Reset All button
                  IconButton(
                    icon: Icon(
                      Icons.restart_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: resetAllPrep,
                    tooltip: 'Reset All Timers',
                  ),
                  if (showTeamAOnly || showTeamBOnly)
                    TextButton.icon(
                      icon: Icon(Icons.view_agenda),
                      label: Text('Show Both'),
                      onPressed: () {
                        setState(() {
                          showTeamAOnly = false;
                          showTeamBOnly = false;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          // Team timers in a row
          Row(
            children: [
              // AFF/PRO Timer
              Expanded(
                child: Visibility(
                  visible: !showTeamBOnly,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Team name and timer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AFF/PRO',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatPrepTime(affProPrepTimeRemaining),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: affProPrepTimeRemaining < 30
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Controls row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Play/Pause and Reset
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isTeamAPrepRunning ? Icons.pause : Icons.play_arrow,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: isTeamAPrepRunning
                                        ? stopTeamAPrep
                                        : startTeamAPrep,
                                    tooltip: isTeamAPrepRunning ? 'Pause' : 'Start',
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: resetTeamAPrep,
                                    tooltip: 'Reset',
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                              // +1/-1 buttons
                              Row(
                                children: [
                                  // -1 button
                                  ElevatedButton(
                                    onPressed: !isTeamAPrepRunning ? decrementTeamAPrep : null,
                                    child: Text('-1'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      minimumSize: Size(40, 30),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // +1 button
                                  ElevatedButton(
                                    onPressed: !isTeamAPrepRunning ? incrementTeamAPrep : null,
                                    child: Text('+1'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      minimumSize: Size(40, 30),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // NEG/CON Timer
              Expanded(
                child: Visibility(
                  visible: !showTeamAOnly,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Team name and timer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NEG/CON',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatPrepTime(negConPrepTimeRemaining),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: negConPrepTimeRemaining < 30
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Controls row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Play/Pause and Reset
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isTeamBPrepRunning ? Icons.pause : Icons.play_arrow,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: isTeamBPrepRunning
                                        ? stopTeamBPrep
                                        : startTeamBPrep,
                                    tooltip: isTeamBPrepRunning ? 'Pause' : 'Start',
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                                    onPressed: resetTeamBPrep,
                                    tooltip: 'Reset',
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                              // +1/-1 buttons
                              Row(
                                children: [
                                  // -1 button
                                  ElevatedButton(
                                    onPressed: !isTeamBPrepRunning ? decrementTeamBPrep : null,
                                    child: Text('-1'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      minimumSize: Size(40, 30),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // +1 button
                                  ElevatedButton(
                                    onPressed: !isTeamBPrepRunning ? incrementTeamBPrep : null,
                                    child: Text('+1'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      minimumSize: Size(40, 30),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

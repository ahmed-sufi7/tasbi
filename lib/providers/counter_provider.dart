import 'package:flutter/material.dart';
import '../models/counter_session.dart';
import '../models/durood.dart';
import '../database/database_helper.dart';
import 'durood_provider.dart';

class CounterProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  int _currentCount = 0;
  int _rounds = 0;
  CounterSession? _currentSession;
  bool _isSessionActive = false;
  bool _isUnlimitedMode = false;

  int get currentCount => _currentCount;
  int get rounds => _rounds;
  CounterSession? get currentSession => _currentSession;
  bool get isSessionActive => _isSessionActive;
  bool get isUnlimitedMode => _isUnlimitedMode;

  // Get progress percentage
  double get progress {
    if (_isUnlimitedMode || (_currentSession != null && _currentSession!.target == 0)) {
      // For unlimited mode, fill to 100 then stay full
      if (_currentCount == 0) return 0.0;
      if (_currentCount >= 100) return 1.0; // Keep ring full after 100
      return (_currentCount / 100.0).clamp(0.0, 1.0);
    }
    if (_currentSession == null || _currentSession!.target == 0) return 0;
    // Allow progress beyond 100% for limited mode (when continuing after target)
    return (_currentCount / _currentSession!.target).clamp(0.0, double.infinity);
  }
  
  // Get continuous progress for endpoint badge (doesn't stop at 1.0)
  double get endpointProgress {
    if (_isUnlimitedMode || (_currentSession != null && _currentSession!.target == 0)) {
      if (_currentCount == 0) return 0.0;
      // Keep moving the endpoint continuously without resetting
      return (_currentCount / 100.0);
    }
    // For limited mode, also allow continuous movement beyond target
    if (_currentSession == null || _currentSession!.target == 0) return 0;
    return (_currentCount / _currentSession!.target);
  }

  // Check if target is reached (for initial target completion)
  bool get isTargetReached {
    if (_isUnlimitedMode) return false;
    if (_currentSession == null) return false;
    // For rounds functionality, we only consider target reached for the first completion
    // Subsequent completions are handled by the rounds logic
    return _rounds == 0 && _currentCount >= _currentSession!.target;
  }

  // Start unlimited counting session (with default tasbeeh)
  Future<void> startUnlimitedSession() async {
    // Get the default unlimited tasbeeh
    final defaultDurood = await _db.getDefaultUnlimitedDurood();
    
    if (defaultDurood != null) {
      final session = CounterSession(
        duroodId: defaultDurood.id!,
        count: 0,
        target: 0, // Unlimited
      );

      final id = await _db.createSession(session);
      _currentSession = session.copyWith(id: id);
      _currentCount = 0;
      _rounds = 0;
      _isSessionActive = true;
      _isUnlimitedMode = true;
      notifyListeners();
    } else {
      // Fallback to original behavior if default durood not found
      _currentCount = 0;
      _rounds = 0;
      _currentSession = null;
      _isSessionActive = true;
      _isUnlimitedMode = true;
      notifyListeners();
    }
  }

  // Start a new counter session
  Future<void> startSession(Durood durood) async {
    final session = CounterSession(
      duroodId: durood.id!,
      count: 0,
      target: durood.target,
    );

    final id = await _db.createSession(session);
    _currentSession = session.copyWith(id: id);
    _currentCount = 0;
    _rounds = 0;
    _isSessionActive = true;
    // Set unlimited mode if target is 0
    _isUnlimitedMode = durood.target == 0;
    notifyListeners();
  }

  // Increment counter
  void increment() {
    if (!_isSessionActive) return;
    
    _currentCount++;
    
    // Check if target is reached (only for limited mode)
    if (!_isUnlimitedMode && 
        _currentSession != null && 
        _currentCount > _currentSession!.target && 
        _currentSession!.target > 0) {
      // Save completed round as a completed session
      _saveCompletedRound();
      
      // Reset count to 1 and increment rounds
      _currentCount = 1;
      _rounds++;
    }
    
    notifyListeners();
  }

    // Save completed round as a completed session
  Future<void> _saveCompletedRound() async {
    if (_currentSession == null) return;
    
    // Create a completed session for the completed round
    final completedRoundSession = _currentSession!.copyWith(
      count: _currentSession!.target, // Save with target count as completed
      endTime: DateTime.now(),
      isCompleted: true,
    );
    
    await _db.updateSession(completedRoundSession);
  }
  
  // Decrement counter
  void decrement() {
    if (!_isSessionActive || _currentCount <= 0) return;
    
    _currentCount--;
    notifyListeners();
  }

  // Reset counter
  void reset() {
    _currentCount = 0;
    _rounds = 0;
    notifyListeners();
  }

  // Save current session
  Future<void> saveSession({String? notes}) async {
    if (_isUnlimitedMode) {
      // For unlimited mode, update the current session with the count
      if (_currentSession != null && _currentCount > 0) {
        final updatedSession = _currentSession!.copyWith(
          count: _currentCount,
          endTime: DateTime.now(),
          isCompleted: false,
          notes: notes,
        );

        await _db.updateSession(updatedSession);
      }
      
      // Reset counters
      _currentSession = null;
      _currentCount = 0;
      _rounds = 0;
      _isSessionActive = false;
      _isUnlimitedMode = false;
      notifyListeners();
      return;
    }
    
    if (_currentSession == null) return;

    final updatedSession = _currentSession!.copyWith(
      count: _currentCount,
      endTime: DateTime.now(),
      isCompleted: false, // Keep as incomplete when just saving
      notes: notes,
    );

    await _db.updateSession(updatedSession);
    _currentSession = null;
    _currentCount = 0;
    _rounds = 0;
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Complete session (save with completion flag)
  Future<void> completeSession({String? notes}) async {
    if (_isUnlimitedMode) {
      // Just reset for unlimited mode
      _currentCount = 0;
      _rounds = 0;
      _isSessionActive = false;
      _isUnlimitedMode = false;
      notifyListeners();
      return;
    }
    
    if (_currentSession == null) return;

    final updatedSession = _currentSession!.copyWith(
      count: _currentCount,
      endTime: DateTime.now(),
      isCompleted: true,
      notes: notes,
    );

    await _db.updateSession(updatedSession);
    _currentSession = null;
    _currentCount = 0;
    _rounds = 0;
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Cancel session (discard without saving)
  Future<void> cancelSession() async {
    if (_isUnlimitedMode) {
      _currentCount = 0;
      _rounds = 0;
      _isSessionActive = false;
      _isUnlimitedMode = false;
      notifyListeners();
      return;
    }
    
    if (_currentSession?.id != null) {
      await _db.deleteSession(_currentSession!.id!);
    }
    _currentSession = null;
    _currentCount = 0;
    _rounds = 0;
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Resume a previous session
  Future<void> resumeSession(CounterSession session) async {
    _currentSession = session;
    _currentCount = session.count;
    _rounds = 0; // Reset rounds when resuming a session
    _isSessionActive = true;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Load session if app was closed during active session
  Future<void> loadActiveSession(DuroodProvider duroodProvider) async {
    // Check if there's an incomplete session from today
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final sessions = await _db.getSessionsByDateRange(todayStart, todayEnd);
    final activeSessions = sessions.where((s) => !s.isCompleted).toList();
    
    if (activeSessions.isNotEmpty) {
      final latestSession = activeSessions.first;
      _currentSession = latestSession;
      _currentCount = latestSession.count;
      _isSessionActive = true;
      
      // Load the associated durood for this session
      final durood = await _db.getDurood(latestSession.duroodId);
      if (durood != null) {
        duroodProvider.selectDurood(durood);
      }
      
      notifyListeners();
    }
  }
}

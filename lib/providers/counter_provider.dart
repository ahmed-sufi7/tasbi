import 'package:flutter/material.dart';
import '../models/counter_session.dart';
import '../models/durood.dart';
import '../database/database_helper.dart';

class CounterProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  int _currentCount = 0;
  CounterSession? _currentSession;
  bool _isSessionActive = false;
  bool _isUnlimitedMode = false;

  int get currentCount => _currentCount;
  CounterSession? get currentSession => _currentSession;
  bool get isSessionActive => _isSessionActive;
  bool get isUnlimitedMode => _isUnlimitedMode;

  // Get progress percentage
  double get progress {
    if (_isUnlimitedMode) return 0;
    if (_currentSession == null || _currentSession!.target == 0) return 0;
    return (_currentCount / _currentSession!.target).clamp(0.0, 1.0);
  }

  // Check if target is reached
  bool get isTargetReached {
    if (_isUnlimitedMode) return false;
    if (_currentSession == null) return false;
    return _currentCount >= _currentSession!.target;
  }

  // Start unlimited counting session (no tasbi selected)
  void startUnlimitedSession() {
    _currentCount = 0;
    _currentSession = null;
    _isSessionActive = true;
    _isUnlimitedMode = true;
    notifyListeners();
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
    _isSessionActive = true;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Increment counter
  void increment() {
    if (!_isSessionActive) return;
    
    _currentCount++;
    notifyListeners();
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
    notifyListeners();
  }

  // Save current session
  Future<void> saveSession({String? notes}) async {
    if (_isUnlimitedMode) {
      // Just reset for unlimited mode
      _currentCount = 0;
      _isSessionActive = false;
      _isUnlimitedMode = false;
      notifyListeners();
      return;
    }
    
    if (_currentSession == null) return;

    final updatedSession = _currentSession!.copyWith(
      count: _currentCount,
      endTime: DateTime.now(),
      isCompleted: _currentCount >= _currentSession!.target,
      notes: notes,
    );

    await _db.updateSession(updatedSession);
    _currentSession = null;
    _currentCount = 0;
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Complete session (save with completion flag)
  Future<void> completeSession({String? notes}) async {
    if (_isUnlimitedMode) {
      // Just reset for unlimited mode
      _currentCount = 0;
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
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Cancel session (discard without saving)
  Future<void> cancelSession() async {
    if (_isUnlimitedMode) {
      _currentCount = 0;
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
    _isSessionActive = false;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Resume a previous session
  Future<void> resumeSession(CounterSession session) async {
    _currentSession = session;
    _currentCount = session.count;
    _isSessionActive = true;
    _isUnlimitedMode = false;
    notifyListeners();
  }

  // Load session if app was closed during active session
  Future<void> loadActiveSession() async {
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
      notifyListeners();
    }
  }
}

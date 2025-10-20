import 'package:flutter/material.dart';
import '../models/durood.dart';
import '../database/database_helper.dart';

class DuroodProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Durood> _duroods = [];
  Durood? _selectedDurood;
  bool _isLoading = false;

  List<Durood> get duroods => _duroods;
  Durood? get selectedDurood => _selectedDurood;
  bool get isLoading => _isLoading;

  DuroodProvider() {
    loadDuroods();
  }

  Future<void> loadDuroods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _duroods = await _db.getAllDuroods();
      if (_duroods.isNotEmpty && _selectedDurood == null) {
        _selectedDurood = _duroods.first;
      }
    } catch (e) {
      debugPrint('Error loading duroods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDurood(Durood durood) async {
    _selectedDurood = durood;
    notifyListeners();
  }

  Future<bool> addDurood(Durood durood) async {
    try {
      final id = await _db.createDurood(durood);
      await loadDuroods();
      // Select the newly created durood
      final newDurood = _duroods.firstWhere((d) => d.id == id);
      _selectedDurood = newDurood;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding durood: $e');
      return false;
    }
  }

  Future<bool> updateDurood(Durood durood) async {
    try {
      await _db.updateDurood(durood);
      await loadDuroods();
      if (_selectedDurood?.id == durood.id) {
        _selectedDurood = durood;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating durood: $e');
      return false;
    }
  }

  Future<bool> deleteDurood(String id) async {
    try {
      final result = await _db.deleteDurood(id);
      if (result > 0) {
        await loadDuroods();
        if (_selectedDurood?.id == id) {
          _selectedDurood = _duroods.isNotEmpty ? _duroods.first : null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting durood: $e');
      return false;
    }
  }

  Future<List<Durood>> getCustomDuroods() async {
    return await _db.getCustomDuroods();
  }
}

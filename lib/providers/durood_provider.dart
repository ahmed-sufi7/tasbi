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
    _ensureDefaultTasbeehExists();
  }

  // Ensure default salawat tasbi exists
  Future<void> _ensureDefaultTasbeehExists() async {
    try {
      final duroods = await _db.getAllDuroods();
      final hasDefault = duroods.any((d) => d.isDefault && d.arabic == 'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ');
      
      if (!hasDefault) {
        // Create default salawat tasbi
        final defaultTasbeeh = Durood(
          name: 'Salawat/Durood',
          arabic: 'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ',
          transliteration: 'Ṣallā Allāhu ʿalayhi wa-ālihī wa-sallam',
          translation: 'May Allah bless him and his family and grant them peace',
          target: 0, // Unlimited
          isDefault: true,
        );
        
        await _db.createDurood(defaultTasbeeh);
        await loadDuroods();
      }
      
      // Update existing default duroods with new Arabic names
      await _db.updateDefaultDuroods();
      await loadDuroods();
    } catch (e) {
      debugPrint('Error ensuring default tasbi: $e');
    }
  }

  Future<void> loadDuroods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _duroods = await _db.getAllDuroods();
      // Don't auto-select any durood, keep it null for default unlimited mode
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

  void clearSelection() {
    _selectedDurood = null;
    notifyListeners();
  }

  Future<bool> addDurood(Durood durood) async {
    try {
      final id = await _db.createDurood(durood);
      await loadDuroods();
      // Don't automatically select the newly created durood
      // Let the user manually select it from the list
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

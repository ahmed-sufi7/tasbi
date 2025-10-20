import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/durood.dart';
import '../providers/durood_provider.dart';
import '../providers/counter_provider.dart';
import '../utils/haptic_helper.dart';

class DuroodManagementScreen extends StatelessWidget {
  const DuroodManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasbi'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<DuroodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final allDuroods = provider.duroods;
          final customDuroods = allDuroods.where((d) => !d.isDefault).toList();
          final defaultDuroods = allDuroods.where((d) => d.isDefault).toList();

          return Column(
            children: [
              Expanded(
                child: allDuroods.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Default Duroods Section
                          if (defaultDuroods.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Default Tasbi',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...defaultDuroods.map((durood) => _DuroodManagementItem(
                              durood: durood,
                              isDefault: true,
                            )),
                          ],
                          // Custom Duroods Section
                          if (customDuroods.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Text(
                                'Custom Tasbi',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...customDuroods.map((durood) => _DuroodManagementItem(
                              durood: durood,
                              isDefault: false,
                            )),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDuroodDialog(context),
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Add Custom'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.book,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Custom Tasbi Yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your own custom tasbi to track',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDuroodDialog(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const AddEditDuroodScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

class _DuroodManagementItem extends StatelessWidget {
  final Durood durood;
  final bool isDefault;

  const _DuroodManagementItem({
    Key? key,
    required this.durood,
    this.isDefault = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            CupertinoIcons.book,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          durood.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            durood.target == 0 ? 'Unlimited' : 'Target: ${durood.target}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        trailing: isDefault
            ? Icon(
                CupertinoIcons.chevron_right,
                color: theme.colorScheme.primary,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.pencil),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => AddEditDuroodScreen(durood: durood),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.delete, color: theme.colorScheme.error),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              ),
        onTap: () async {
          // Select this tasbi and go back to counter
          final duroodProvider = context.read<DuroodProvider>();
          final counterProvider = context.read<CounterProvider>();
          
          // If there's an active session with a different durood, save it first
          if (counterProvider.isSessionActive && 
              counterProvider.currentSession?.duroodId != durood.id) {
            await counterProvider.saveSession();
          }
          
          duroodProvider.selectDurood(durood);
          HapticHelper.light();
          
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${durood.name}" selected. Tap anywhere to count!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Durood?'),
        content: Text('Are you sure you want to delete "${durood.name}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              final provider = context.read<DuroodProvider>();
              final success = await provider.deleteDurood(durood.id!);
              
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  HapticHelper.success();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tasbi deleted successfully')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class AddEditDuroodScreen extends StatefulWidget {
  final Durood? durood;

  const AddEditDuroodScreen({Key? key, this.durood}) : super(key: key);

  @override
  State<AddEditDuroodScreen> createState() => _AddEditDuroodScreenState();
}

class _AddEditDuroodScreenState extends State<AddEditDuroodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;

  bool get isEditing => widget.durood != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.durood?.name ?? '');
    _targetController = TextEditingController(text: widget.durood?.target.toString() ?? '100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tasbi' : 'Add Custom Tasbi'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveDurood,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Morning Dhikr, Ayatul Kursi',
                prefixIcon: const Icon(CupertinoIcons.textformat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Target Count Field
            TextFormField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: 'Target Count',
                hintText: 'e.g., 100',
                prefixIcon: const Icon(CupertinoIcons.number),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a target';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Quick Target Presets
            Text(
              'Quick Presets',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [33, 66, 99, 100, 300, 500, 1000].map((count) {
                return ActionChip(
                  label: Text(count.toString()),
                  onPressed: () {
                    _targetController.text = count.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDurood() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final durood = Durood(
      id: widget.durood?.id,
      name: _nameController.text.trim(),
      arabic: _nameController.text.trim(), // Use name as arabic text for simplicity
      transliteration: null,
      translation: null,
      target: int.parse(_targetController.text.trim()),
      isDefault: false,
    );

    final provider = context.read<DuroodProvider>();
    bool success;
    
    if (isEditing) {
      success = await provider.updateDurood(durood);
    } else {
      success = await provider.addDurood(durood);
    }

    if (mounted) {
      if (success) {
        HapticHelper.success();
        
        // If adding new tasbi, select it and close all screens to go back to counter
        if (!isEditing) {
          // The newly created durood is already selected by the provider
          // Pop this screen
          Navigator.pop(context);
          // Pop the management screen to return to counter
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tasbi created! Start counting by tapping anywhere'),
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tasbi updated successfully'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save tasbi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

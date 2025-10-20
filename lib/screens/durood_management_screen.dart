import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/durood.dart';
import '../providers/durood_provider.dart';
import '../utils/haptic_helper.dart';

class DuroodManagementScreen extends StatelessWidget {
  const DuroodManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Durood/Tasbi'),
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

          final customDuroods = provider.duroods.where((d) => !d.isDefault).toList();

          return Column(
            children: [
              Expanded(
                child: customDuroods.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customDuroods.length,
                        itemBuilder: (context, index) {
                          return _DuroodManagementItem(
                            durood: customDuroods[index],
                          );
                        },
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
              'No Custom Durood Yet',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your own custom durood or tasbi to track',
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

  const _DuroodManagementItem({Key? key, required this.durood}) : super(key: key);

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
        title: Text(
          durood.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              durood.arabic,
              style: theme.textTheme.bodyMedium,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('Target: ${durood.target}', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Row(
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
                    const SnackBar(content: Text('Durood deleted successfully')),
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
  late TextEditingController _arabicController;
  late TextEditingController _transliterationController;
  late TextEditingController _translationController;
  late TextEditingController _targetController;

  bool get isEditing => widget.durood != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.durood?.name ?? '');
    _arabicController = TextEditingController(text: widget.durood?.arabic ?? '');
    _transliterationController = TextEditingController(text: widget.durood?.transliteration ?? '');
    _translationController = TextEditingController(text: widget.durood?.translation ?? '');
    _targetController = TextEditingController(text: widget.durood?.target.toString() ?? '100');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arabicController.dispose();
    _transliterationController.dispose();
    _translationController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Durood' : 'Add Custom Durood'),
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g., Durood-e-Ibrahim',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _arabicController,
              decoration: const InputDecoration(
                labelText: 'Arabic Text *',
                hintText: 'Enter Arabic text',
              ),
              textDirection: TextDirection.rtl,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Arabic text';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _transliterationController,
              decoration: const InputDecoration(
                labelText: 'Transliteration (Optional)',
                hintText: 'Enter transliteration',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Translation (Optional)',
                hintText: 'Enter translation',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Count *',
                hintText: 'e.g., 100',
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
            Text(
              '* Required fields',
              style: theme.textTheme.bodySmall,
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
      arabic: _arabicController.text.trim(),
      transliteration: _transliterationController.text.trim().isNotEmpty
          ? _transliterationController.text.trim()
          : null,
      translation: _translationController.text.trim().isNotEmpty
          ? _translationController.text.trim()
          : null,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Durood updated successfully'
                : 'Durood added successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save durood'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

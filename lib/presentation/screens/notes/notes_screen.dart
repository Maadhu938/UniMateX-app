import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../domain/models/note_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/empty_state.dart';
import '../../providers/repository_providers.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Notes", style: TextStyle(fontSize: 28, letterSpacing: -0.5, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                        SizedBox(height: 8),
                        Text("Quick Notes", style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton.filled(
                      onPressed: () => _openEditor(context, ref),
                      icon: const Icon(LucideIcons.plus),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: "Search notes...",
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                      prefixIcon: Icon(LucideIcons.search, color: AppColors.textTertiary, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filtered = notes.where((n) => n.title.toLowerCase().contains(searchQuery.toLowerCase()) || n.content.toLowerCase().contains(searchQuery.toLowerCase())).toList();
                  
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.fileText,
                      title: searchQuery.isEmpty ? "No notes yet" : "No matches found",
                      description: searchQuery.isEmpty 
                        ? "Capture your thoughts, lecture highlights, and ideas." 
                        : "We couldn't find any notes matching '$searchQuery'.",
                      actionLabel: searchQuery.isEmpty ? "Add Note" : null,
                      onAction: searchQuery.isEmpty ? () => _openEditor(context, ref) : null,
                    );
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: filtered.map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNoteCard(note),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      extendBody: false,
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Note?'),
            content: Text('Are you sure you want to delete "${note.title.isNotEmpty ? note.title : 'this note'}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true), 
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
        child: const Icon(LucideIcons.trash2, color: AppColors.danger),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        final uid = ref.read(currentUserIdProvider);
        if (uid != null) ref.read(notesRepoProvider).deleteNote(userId: uid, noteId: note.id);
      },
      child: GestureDetector(
        onTap: () => _openEditor(context, ref, note),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isNotEmpty ? note.title : 'Untitled',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                note.preview,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d').format(note.updatedAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, [NoteModel? note]) {
    context.push('/note-editor', extra: note);
  }
}

class NoteEditorScreen extends ConsumerStatefulWidget {
  final NoteModel? note;
  const NoteEditorScreen({super.key, this.note});
  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasChanges = false;
  bool _isSaving = false;
  String? _currentId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");
    _currentId = widget.note?.id;
    _titleController.addListener(() => _hasChanges = true);
    _contentController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      final note = NoteModel(
        id: _currentId ?? '',
        title: _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim(),
        content: _contentController.text,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final newId = await ref.read(notesRepoProvider).saveNote(userId: uid, note: note);
      _currentId = newId;
      _hasChanges = false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (_hasChanges) _saveNote();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () { if (_hasChanges) _saveNote(); context.pop(); },
            icon: const Icon(LucideIcons.chevronLeft),
          ),
           actions: [
             IconButton(
               onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await _saveNote();
                  messenger.showSnackBar(const SnackBar(content: Text('Saved!'), duration: Duration(seconds: 1)));
               },
               icon: const Icon(LucideIcons.save),
             ),
           ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title", border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(hintText: "Start typing...", border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 16, color: AppColors.textTertiary)),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

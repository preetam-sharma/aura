import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common_widgets/glass_container.dart';
import '../../../constants/app_theme.dart';
import '../domain/task_model.dart';
import '../data/task_repository.dart';

class TaskLoggerScreen extends ConsumerStatefulWidget {
  const TaskLoggerScreen({super.key});

  @override
  ConsumerState<TaskLoggerScreen> createState() => _TaskLoggerScreenState();
}

class _TaskLoggerScreenState extends ConsumerState<TaskLoggerScreen> {

  @override
  Widget build(BuildContext context) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Logger',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      onPressed: () => _selectDate(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.indigo, size: 28),
                      onPressed: () => _showAddTaskSheet(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          _buildDateHeader(),
          const SizedBox(height: 8),
          
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) => tasks.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index], index);
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.indigo)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text('No active tasks', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16)),
          TextButton(
            onPressed: () => _showAddTaskSheet(),
            child: Text('Add your first task', style: TextStyle(color: AppTheme.indigo)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 10,
        opacity: 0.08,
        padding: const EdgeInsets.all(16),
        onTap: task.isCompleted ? null : () => _showAddTaskSheet(task: task, index: index),
        child: Row(
          children: [
            // Status Toggle (Active/Inactive)
            if (!task.isCompleted)
              Column(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: task.isActive,
                      activeThumbColor: AppTheme.emerald,
                      onChanged: (value) {
                        ref.read(taskRepositoryProvider).updateTask(
                          task.copyWith(isActive: value),
                        );
                      },
                    ),
                  ),
                  Text(
                    task.isActive ? 'Active' : 'Paused',
                    style: TextStyle(fontSize: 10, color: task.isActive ? AppTheme.emerald : Colors.white24),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.check_circle, color: AppTheme.emerald, size: 24),
              ),
            const SizedBox(width: 12),
            
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title, 
                          style: GoogleFonts.outfit(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600, 
                            color: task.isCompleted ? Colors.white38 : Colors.white,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          )
                        ),
                      ),
                      if (task.carryForward)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.indigo.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Carry',
                            style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.indigo, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(child: Text(task.location, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  if (!task.isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.radar, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text('${task.radius.toInt()}m radius', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Completion/Reactivate Action
            IconButton(
              icon: Icon(
                task.isCompleted ? Icons.settings_backup_restore : Icons.check_circle_outline, 
                color: task.isCompleted ? AppTheme.indigo : AppTheme.emerald
              ),
              tooltip: task.isCompleted ? 'Reactivate Task' : 'Mark Complete',
              onPressed: () {
                ref.read(taskRepositoryProvider).toggleTaskCompletion(
                  task.id, 
                  !task.isCompleted
                );
              },
            ),
            
            // Delete Action
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.rose),
              tooltip: 'Delete Task',
              onPressed: () {
                ref.read(taskRepositoryProvider).deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final selectedDate = ref.watch(selectedTaskDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    String dateLabel = '';
    if (selectedDate.isAtSameMomentAs(today)) {
      dateLabel = 'Today';
    } else if (selectedDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      dateLabel = 'Yesterday';
    } else if (selectedDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            dateLabel,
            style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          if (!selectedDate.isAtSameMomentAs(today))
            TextButton(
              onPressed: () => ref.read(selectedTaskDateProvider.notifier).setDate(today),
              child: Text('Back to Today', style: TextStyle(color: AppTheme.indigo, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(selectedTaskDateProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.indigo,
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(selectedTaskDateProvider.notifier).setDate(picked);
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showAddTaskSheet({TaskItem? task, int? index}) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final locationController = TextEditingController(text: task?.location ?? '');
    final radiusController = TextEditingController(text: task?.radius.toInt().toString() ?? '1000');
    bool carryForward = task?.carryForward ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: GlassContainer(
            blur: 20,
            opacity: 0.15,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Geofence Task' : 'Create New Geofence Task', 
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const SizedBox(height: 24),
                
                _buildField('Task Description', Icons.edit_note, titleController),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildField('Location', Icons.location_on, locationController)),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setModalState(() {
                          locationController.text = 'Picked via Map (12.97, 77.59)';
                        });
                      }, 
                      icon: const Icon(Icons.my_location, color: AppTheme.indigo),
                      tooltip: 'Use My Location',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Map Preview Placeholder
                Text('Map Preview', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, color: Colors.white24, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Interactive Map Selection',
                              style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 100,
                        child: Icon(Icons.location_on, color: AppTheme.rose, size: 30),
                      ),
                      Positioned(
                        top: 45,
                        left: 95,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.rose.withValues(alpha: 0.3), width: 2),
                            color: AppTheme.rose.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radius: ${radiusController.text}m',
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: double.tryParse(radiusController.text) ?? 1000,
                      min: 100,
                      max: 5000,
                      divisions: 49,
                      activeColor: AppTheme.indigo,
                      inactiveColor: Colors.white12,
                      onChanged: (val) {
                        setModalState(() => radiusController.text = val.toInt().toString());
                      },
                    ),
                    Text(
                      'Task triggers when you enter this circle.',
                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Carry Forward Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carry Forward', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text('Repeat task daily until completed', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38)),
                      ],
                    ),
                    Switch(
                      value: carryForward,
                      activeColor: AppTheme.indigo,
                      onChanged: (val) {
                        setModalState(() => carryForward = val);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final repository = ref.read(taskRepositoryProvider);
                        final newTask = TaskItem(
                          id: task?.id ?? '', // ID handled by Firestore for new tasks
                          title: titleController.text,
                          location: locationController.text.isEmpty ? 'Custom Location' : locationController.text,
                          isActive: task?.isActive ?? true,
                          radius: double.tryParse(radiusController.text) ?? 1000,
                          isCompleted: task?.isCompleted ?? false,
                          createdAt: task?.createdAt ?? DateTime.now(),
                          carryForward: carryForward,
                          completedAt: task?.completedAt,
                        );
                        
                        if (isEditing) {
                          repository.updateTask(newTask);
                        } else {
                          repository.addTask(newTask);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Start Monitoring', 
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildField(String hint, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white54, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/crewx_button.dart';
import '../../core/widgets/crewx_text_field.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';

class EventCreateScreen extends ConsumerStatefulWidget {
  const EventCreateScreen({super.key});

  @override
  ConsumerState<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends ConsumerState<EventCreateScreen> {
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payInfoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _eventDate;
  DateTime? _endDate;
  final List<EventRole> _roles = [];

  final List<String> _availableRoles = [
    'Coordinator', 'Registrations', 'Ushering', 'F&B', 'Setup', 
    'Branding', 'Hospitality', 'Photography', 'Security'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _payInfoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final fullDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          if (isStart) {
            _eventDate = fullDate;
          } else {
            _endDate = fullDate;
          }
        });
      }
    }
  }

  void _addRole() {
    setState(() {
      _roles.add(EventRole(role: _availableRoles.first, count: 1));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select event date')));
       return;
    }
    if (_roles.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one role')));
       return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final event = EventModel(
      eventId: '', // Firestore will generate
      organiserId: uid,
      title: _titleController.text.trim(),
      date: Timestamp.fromDate(_eventDate!),
      endDate: _endDate != null ? Timestamp.fromDate(_endDate!) : null,
      city: _cityController.text.trim(),
      venue: _venueController.text.trim(),
      description: _descriptionController.text.trim(),
      payInfo: _payInfoController.text.trim(),
      roles: _roles,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await ref.read(eventsProvider.notifier).createEvent(event);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post an Event')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrewXTextField(label: 'Event Title', controller: _titleController, maxLength: 100, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),
              CrewXTextField(label: 'City', controller: _cityController, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),
              CrewXTextField(label: 'Venue', controller: _venueController, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),
              
              const Text('Date & Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.kSurfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.kBorder)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.kYellow, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _eventDate != null ? DateFormat('EEE, d MMM yyyy · hh:mm a').format(_eventDate!) : 'Select Start Date',
                        style: TextStyle(color: _eventDate != null ? Colors.white : AppColors.kTextSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.kSurfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.kBorder)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.kYellow, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _endDate != null ? DateFormat('EEE, d MMM yyyy · hh:mm a').format(_endDate!) : 'Select End Date (Optional)',
                        style: TextStyle(color: _endDate != null ? Colors.white : AppColors.kTextSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CrewXTextField(label: 'Description', controller: _descriptionController, maxLines: 5, maxLength: 1000),
              const SizedBox(height: 24),
              CrewXTextField(label: 'Pay Info', controller: _payInfoController, hint: 'e.g. ₹800/day + meals', maxLength: 100),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Roles Needed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _addRole, child: const Text('+ Add Role', style: TextStyle(color: AppColors.kYellow))),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_roles.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _roles[index].role,
                          dropdownColor: AppColors.kSurface,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          items: _availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (v) {
                            setState(() {
                              _roles[index] = EventRole(role: v!, count: _roles[index].count);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: _roles[index].count.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4)),
                          onChanged: (v) {
                            final count = int.tryParse(v) ?? 1;
                            setState(() {
                              _roles[index] = EventRole(role: _roles[index].role, count: count);
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.kError),
                        onPressed: () => setState(() => _roles.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              CrewXButton(label: 'Post Event', onPressed: _submit, isLoading: eventsState.isLoading),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:lush/theme/app_colors.dart';

/// BR-045: Day-wise subscription schedule selector
/// 6 days (Mon-Sat), Sunday is holiday.
/// "Same juice everyday" checkbox for single-juice selection.
class DayWiseScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> availableJuices;
  final Map<String, dynamic> selectedPlan;

  const DayWiseScheduleScreen({
    Key? key,
    required this.availableJuices,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  State<DayWiseScheduleScreen> createState() => _DayWiseScheduleScreenState();
}

class _DayWiseScheduleScreenState extends State<DayWiseScheduleScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final Map<String, Map<String, dynamic>?> _schedule = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
  };

  bool _sameJuiceEveryday = false;
  Map<String, dynamic>? _globalSelection;

  void _onGlobalSelectionChanged(Map<String, dynamic>? juice) {
    setState(() {
      _globalSelection = juice;
      if (juice != null) {
        for (final day in _days) {
          _schedule[day] = juice;
        }
      } else {
        for (final day in _days) {
          _schedule[day] = null;
        }
      }
    });
  }

  void _onDaySelectionChanged(String day, Map<String, dynamic>? juice) {
    setState(() {
      _schedule[day] = juice;
    });
  }

  Map<String, dynamic> _buildSchedulePayload() {
    final Map<String, String> schedule = {};
    for (final day in _days) {
      final juice = _schedule[day];
      if (juice != null) {
        schedule[day] = juice['id'] as String;
      }
    }
    return {
      'schedule': schedule,
      'planId': widget.selectedPlan['id'] ?? widget.selectedPlan['plan_id'],
      'sameJuiceEveryday': _sameJuiceEveryday,
    };
  }

  bool get _isScheduleValid {
    // At least one day must have a juice selected
    return _schedule.values.any((juice) => juice != null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasSchedule = _isScheduleValid || _sameJuiceEveryday;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: hasSchedule,
          message: 'Schedule selection in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Days'),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Global selection checkbox
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightDivider!),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.nearlyBlack.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _sameJuiceEveryday,
                        onChanged: (value) {
                          setState(() {
                            _sameJuiceEveryday = value ?? false;
                            if (!_sameJuiceEveryday) {
                              _globalSelection = null;
                              for (final day in _days) {
                                _schedule[day] = null;
                              }
                            }
                          });
                        },
                        activeColor: AppColors.primaryOrange,
                      ),
                      Expanded(
                        child: Text(
                          'Same juice everyday',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
                        ),
                      ),
                    ],
                  ),
                  if (_sameJuiceEveryday) ...[
                    SizedBox(height: 12),
                    Text(
                      'Select one juice for all delivery days',
                      style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary!, fontFamily: 'Roboto'),
                    ),
                    SizedBox(height: 8),
                    _buildJuiceDropdown(
                      value: _globalSelection,
                      onChanged: _onGlobalSelectionChanged,
                      hint: 'Choose a juice...',
                    ),
                  ],
                ],
              ),
            ),

            if (!_sameJuiceEveryday)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 7, // 6 days + Sunday
                  itemBuilder: (context, index) {
                    if (index == 6) {
                      // Sunday - Holiday
                      return _buildHolidayCard();
                    }
                    final day = _days[index];
                    return _buildDayCard(day);
                  },
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_drink, size: 64, color: Colors.amber[300]),
                      SizedBox(height: 16),
                      Text(
                        'Your selection will apply to all 6 delivery days',
                        style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary, fontFamily: 'Roboto'),
                        textAlign: TextAlign.center,
                      ),
                      if (_globalSelection != null) ...[
                        SizedBox(height: 12),
                        Text(
                          (_globalSelection!['name'] as String?) ?? '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Bottom button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.nearlyBlack.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isScheduleValid ? _confirmSchedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Continue to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final juice = _schedule[day];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppColors.primaryOrangeDark),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                day,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildJuiceDropdown(
                value: juice,
                onChanged: (selected) => _onDaySelectionChanged(day, selected),
                hint: 'Select juice',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayCard() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.beach_access, size: 20, color: AppColors.lightTextDisabled),
            SizedBox(width: 12),
            Text(
              'Sunday',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey, fontFamily: 'Roboto'),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightDivider,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Holiday',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuiceDropdown({
    required Map<String, dynamic>? value,
    required Function(Map<String, dynamic>?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: value,
      hint: Text(hint, style: TextStyle(color: AppColors.grey)),
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightDivider!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightDivider!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
      ),
      items: widget.availableJuices.map((juice) {
        final imageUrl = juice['imageUrl'] as String?;
        final juiceName = juice['name'] as String? ?? '';
        return DropdownMenuItem<Map<String, dynamic>>(
          value: juice,
          child: Row(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, __, ___) => Icon(Icons.local_drink, size: 20),
                )
              else
                Icon(Icons.local_drink, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  juiceName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _confirmSchedule() {
    final payload = _buildSchedulePayload();
    Navigator.of(context).pop(payload);
  }
}



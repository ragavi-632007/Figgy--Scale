import 'package:flutter/material.dart';
import 'package:figgy_app/theme/app_theme.dart';
import 'package:figgy_app/app/main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancellationScreen extends StatefulWidget {
  const CancellationScreen({super.key});

  @override
  State<CancellationScreen> createState() => _CancellationScreenState();
}

class _CancellationScreenState extends State<CancellationScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _selectedReason;
  bool _isLoading = false;

  final List<String> _reasons = [
    'Taking a break / holiday',
    'Moving to another city',
    'Switching to different insurance',
    'Too expensive',
    'Others'
  ];

  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  String _getEndCycleDate() {
    DateTime now = DateTime.now();
    // Calculate days until next Sunday (7 corresponds to Sunday in DateTime)
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 3) daysUntilSunday += 7; // Ensure at least 3 days for a clean cycle view
    
    DateTime endCycle = now.add(Duration(days: daysUntilSunday));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[endCycle.month - 1]} ${endCycle.day.toString().padLeft(2, '0')}, ${endCycle.year}';
  }

  Future<void> _handleCancellation() async {
    setState(() => _isLoading = true);
    
    // Simulate API call to POST /policy/cancel
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('policy_status', 'scheduled_cancel');
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentStep = 3;
      });
      _pageController.animateToPage(3, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      _checkController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('CANCEL POLICY', style: AppTypography.small.copyWith(
          letterSpacing: 2.0, 
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildReasonStep(),
                _buildWarningStep(),
                _buildConfirmationStep(),
                _buildSuccessStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.brandOrange : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReasonStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you cancelling?', style: AppTypography.h2.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text('Your feedback helps us improve protection for all workers.', style: AppTypography.bodySmall),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _reasons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                bool isSelected = _selectedReason == _reasons[index];
                return InkWell(
                  onTap: () => setState(() => _selectedReason = _reasons[index]),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandOrangeSoft : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.brandOrange : AppColors.border, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_reasons[index], style: AppTypography.bodyMedium.copyWith(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? AppColors.brandDeepBlue : AppColors.textPrimary,
                        ))),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.brandOrange),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedReason == null ? null : () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDeepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transparent Policy', style: AppTypography.h2.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.brandOrangeSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.brandOrange, size: 40),
                const SizedBox(height: 20),
                Text('Scheduled Cancellation', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: AppColors.brandOrange)),
                const SizedBox(height: 12),
                Text('Coverage usually runs in weekly cycles. Your protection will remain active until ${_getEndCycleDate()}.', 
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(height: 1.5, color: AppColors.brandDeepBlue, fontWeight: FontWeight.w600),
                ),
                const Divider(height: 32),
                Text('NO REFUND will be issued for the remaining days of this active week.', 
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.dangerText, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDeepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('I UNDERSTAND', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.brandOrange, size: 64),
          const SizedBox(height: 24),
          Text('Are you sure?', style: AppTypography.h1),
          const SizedBox(height: 12),
          Text('Pausing protection during monsoon/heat seasons puts your weekly income at risk.', 
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.brandPrimary.withValues(alpha: 0.3),
              ),
              child: const Text('KEEP PROTECTION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _handleCancellation,
            child: _isLoading 
              ? const CircularProgressIndicator(color: AppColors.dangerText)
              : Text('YES, CANCEL FROM NEXT WEEK', style: AppTypography.bodySmall.copyWith(color: AppColors.dangerText, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _checkAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
          ),
        ),
        const SizedBox(height: 32),
        Text('Scheduled for Cancellation', style: AppTypography.h2),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text('Your policy remains active until ${_getEndCycleDate()}. You will not be charged for the next cycle.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                MainWrapper.of(context)?.refreshState();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.brandDeepBlue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandDeepBlue)),
            ),
          ),
        ),
      ],
    );
  }
}

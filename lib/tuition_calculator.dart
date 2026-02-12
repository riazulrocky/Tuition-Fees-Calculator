import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TuitionCalculator extends StatefulWidget {
  const TuitionCalculator({super.key});

  @override
  _TuitionCalculatorState createState() => _TuitionCalculatorState();
}

class _TuitionCalculatorState extends State<TuitionCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _semesterFeesController = TextEditingController();
  final TextEditingController _perCreditFeesController = TextEditingController();
  final TextEditingController _totalCreditsController = TextEditingController();
  final TextEditingController _waiverPercentageController = TextEditingController();

  // Results variables
  double? _creditCost;
  double? _waiverAmount;
  double? _totalCost;
  double? _firstInstallment;
  double? _secondInstallment;
  double? _thirdInstallment;
  double? _totalWithFine;
  bool _showResults = false;

  void _calculateFees() {
    if (!_formKey.currentState!.validate()) return;

    final semesterFees = double.tryParse(_semesterFeesController.text) ?? 0;
    final perCreditFees = double.tryParse(_perCreditFeesController.text) ?? 0;
    final totalCredits = double.tryParse(_totalCreditsController.text) ?? 0;
    final waiverPercentage = double.tryParse(_waiverPercentageController.text) ?? 0;

    if (perCreditFees <= 0 || totalCredits <= 0) {
      _showSnackBar('Please enter valid values for per credit fees and total credits', Colors.red);
      return;
    }

    setState(() {
      _creditCost = perCreditFees * totalCredits;
      _waiverAmount = (_creditCost! * waiverPercentage) / 100;
      _totalCost = _creditCost! - _waiverAmount! + semesterFees;

      _firstInstallment = (_totalCost! * 40) / 100;
      _secondInstallment = (_totalCost! * 30) / 100;
      _thirdInstallment = (_totalCost! * 30) / 100;
      _totalWithFine = _totalCost! + 1000;

      _showResults = true;
    });

    _showSnackBar('Fees calculated successfully!', Colors.green);
  }

  void _resetCalculator() {
    setState(() {
      _semesterFeesController.clear();
      _perCreditFeesController.clear();
      _totalCreditsController.clear();
      _waiverPercentageController.clear();
      _showResults = false;
    });
    _showSnackBar('Calculator reset', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky Blue
              Color(0xFF87CEFA), // Light Sky Blue
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 8),
                          _buildInputForm(),
                          if (_showResults) ...[
                            const SizedBox(height: 24),
                            _buildResultsSection(),
                            const SizedBox(height: 16),
                            _buildFineWarning(),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 32, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Tuition Fees Calculator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Northern University Bangladesh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Fee Calculation Form',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildResponsiveInputs(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveInputs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 550;
        return Column(
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('Registration Fees (৳)', _semesterFeesController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField('Per Credit Fees (৳)', _perCreditFeesController, required: true)),
                ],
              )
            else ...[
              _buildInputField('Registration Fees (৳)', _semesterFeesController),
              const SizedBox(height: 16),
              _buildInputField('Per Credit Fees (৳)', _perCreditFeesController, required: true),
            ],
            const SizedBox(height: 16),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('Total Credits', _totalCreditsController, required: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField('Waiver (%)', _waiverPercentageController, maxValue: 100)),
                ],
              )
            else ...[
              _buildInputField('Total Credits', _totalCreditsController, required: true),
              const SizedBox(height: 16),
              _buildInputField('Waiver (%)', _waiverPercentageController, maxValue: 100),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool required = false, double? maxValue}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'Required';
        }
        if (maxValue != null && value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue != null && numValue > maxValue) {
            return 'Max $maxValue%';
          }
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 400;
        Widget calculateBtn = ElevatedButton.icon(
          onPressed: _calculateFees,
          icon: const Icon(Icons.calculate),
          label: const Text('Calculate Fees'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Widget resetBtn = OutlinedButton(
          onPressed: _resetCalculator,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Reset'),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: calculateBtn),
              const SizedBox(width: 16),
              Expanded(child: resetBtn),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              calculateBtn,
              const SizedBox(height: 12),
              resetBtn,
            ],
          );
        }
      },
    );
  }

  Widget _buildResultsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCostBreakdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildPaymentInstallments()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildCostBreakdown(),
              const SizedBox(height: 16),
              _buildPaymentInstallments(),
            ],
          );
        }
      },
    );
  }

  Widget _buildCostBreakdown() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildCostRow('Credit Cost:', '৳${_creditCost!.toStringAsFixed(0)}'),
            _buildCostRow('Waiver Amount:', '-৳${_waiverAmount!.toStringAsFixed(0)}', color: Colors.green.shade600),
            _buildCostRow('Registration:', '৳${double.tryParse(_semesterFeesController.text)?.toStringAsFixed(0) ?? '0'}'),
            const Divider(height: 24, thickness: 1),
            _buildCostRow('Total Cost:', '৳${_totalCost!.toStringAsFixed(0)}', isTotal: true, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstallments() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Installments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstallmentCard('1st (40%)', _firstInstallment!, Colors.blue),
            const SizedBox(height: 12),
            _buildInstallmentCard('2nd (30%)', _secondInstallment!, Colors.orange),
            const SizedBox(height: 12),
            _buildInstallmentCard('3rd (30%)', _thirdInstallment!, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentCard(String title, double amount, MaterialColor cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor.shade50.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cardColor.shade800,
              ),
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cardColor.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFineWarning() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.red.shade50.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Late payment adds a ৳1,000 fine if not cleared within the semester.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total with Fine:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Text(
                    '৳${_totalWithFine!.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _semesterFeesController.dispose();
    _perCreditFeesController.dispose();
    _totalCreditsController.dispose();
    _waiverPercentageController.dispose();
    super.dispose();
  }
}
